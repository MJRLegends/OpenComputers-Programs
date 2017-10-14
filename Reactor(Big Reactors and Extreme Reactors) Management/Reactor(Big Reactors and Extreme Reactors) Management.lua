local filesystem = require("filesystem")
local component = require("component")
local keyboard = require("keyboard")
local event = require("event")
local gpu = component.gpu
local reactor = component.br_reactor

local colors = { blue = 0x4286F4, purple = 0xB673d6, red = 0xC14141, green = 0xDA841,
black = 0x000000, yellow = 0xffdb4d, white = 0xFFFFFF, grey = 0x47494C, 
lightGray = 0xBBBBBB, lightBlue = 0x66d9ff, gray = 0x595959, lime = 0x80cd32}

gpu.setResolution(132,38)
gpu.setBackground(colors.black)
gpu.fill(1, 1, 132, 38, " ")

displayW=132
displayH=38
rods = false
setting = false
control = false

maxFluidTank = 50000
minLevelPower = 5000000
maxLevelPower = 9000000
minLevelSteam = maxFluidTank / 2
maxLevelSteam = maxFluidTank
currentPower = 0

function draw_line(x, y, length, color)
  gpu.setBackground(color)
  gpu.set(x, y, string.rep(" ", length))
end

function progress_bar(x, y, length, minVal, maxVal, bar_color, bg_color)
  draw_line(x, y, length, bg_color) --backgoround bar
  local barSize = math.floor((minVal/maxVal) * length)
  draw_line(x, y, barSize, bar_color)     --progress so far
end

function progress_bar_multi_line(x, y, length, minVal, maxVal, bar_color, bg_color, numberOFLine)
  local barSize = math.floor((minVal/maxVal) * length)
  y = y - 1
  for i=1,numberOFLine,1 do
    draw_line(x, y + i, length, bg_color) --background bar
    draw_line(x, y + i, barSize, bar_color)     --progress so far
  end
end

function draw_text(x, y, text, text_color, bg_color)
  gpu.setBackground(bg_color)
  gpu.setForeground(bg_color)
  gpu.fill(x, y, (displayW - x), y, " ")
  gpu.setForeground(text_color)
  gpu.set(x, y, text)
end


function drawMainStatic()
  draw_text(1,2, "MJRLegends Reactor Management V1.0.0", colors.blue, colors.black)
  draw_text(2, 5, "Casing Heat: ", colors.yellow, colors.black)
  draw_text(2, 8, "Fuel Heat: ", colors.yellow, colors.black)
end

function drawMain()

  -----------Casing Heat---------------------
  local maxVal = 5000
  local minVal = math.floor(reactor.getCasingTemperature())
  draw_text(23, 5, minVal.." C", colors.white, colors.black)

  if minVal < 500 then
    progress_bar(2, 6, displayW-2, minVal, maxVal, colors.lightBlue, colors.gray)
  elseif minVal < 1000 then
    progress_bar(2, 6, displayW-2, minVal, maxVal, colors.lime, colors.gray)
  elseif minVal < 1500 then
    progress_bar(2, 6, displayW-2, minVal, maxVal, colors.yellow, colors.gray)
  elseif minVal >= 1500 then
    progress_bar(2, 6, displayW-2, minVal, maxVal, colors.red, colors.gray)
  end

  -----------Fuel Heat---------------------
  local maxVal = 5000
  local minVal = math.floor(reactor.getFuelTemperature())
  draw_text(23, 8, minVal.." C", colors.white, colors.black)

  if minVal < 500 then
    progress_bar(2, 9, displayW-2, minVal, maxVal, colors.lightBlue, colors.gray)
  elseif minVal < 1000 then
    progress_bar(2, 9, displayW-2, minVal, maxVal, colors.lime, colors.gray)
  elseif minVal < 1500 then
    progress_bar(2, 9, displayW-2, minVal, maxVal, colors.yellow, colors.gray)
  elseif minVal >= 1500 then
    progress_bar(2, 9, displayW-2, minVal, maxVal, colors.red, colors.gray)
  end

  -----------Water Tank---------------------
  if reactor.isActivelyCooled() then
    draw_text(2, 11, "Water Tank: ", colors.yellow, colors.black)
    local maxVal = reactor.getHotFluidAmountMax()
    local minVal = math.floor(reactor.getCoolantAmount())
    draw_text(23, 11, minVal.." mb", colors.white, colors.black)
    progress_bar(2, 12, displayW-2, minVal, maxVal, colors.blue, colors.gray)
  else
    -----------Power Storage---------------------
    draw_text(2, 11, "Power: ", colors.yellow, colors.black)
    local maxVal = 10000000
    local minVal = math.floor(reactor.getEnergyStored())
    draw_text(23, 11, math.floor((minVal/maxVal)*100).."% " .."="..minVal.." RF", colors.white, colors.black)
    progress_bar(2, 12, displayW-2, minVal, maxVal, colors.lightGray, colors.gray)
  end

  yValue = 12

  -----------Steam Tank---------------------
  if reactor.isActivelyCooled() then
    draw_text(2, yValue +2, "Steam Tank: ", colors.yellow, colors.black)
    local maxVal = reactor.getHotFluidAmountMax()
    local minVal = math.floor(reactor.getHotFluidAmount())
    draw_text(23, yValue +2, minVal.." mb", colors.white, colors.black)
    progress_bar(2, yValue +3, displayW-2, minVal, maxVal, colors.lightGray, colors.gray)
  end
  if reactor.isActivelyCooled() then
    yValue = yValue + 4
  else
    yValue = 13
  end
  -------------Fuel-------------------
  draw_text(2, yValue+ 1, "Fuel: ", colors.yellow, colors.black)
  fuel = math.floor(reactor.getFuelAmount())
  draw_text(23, yValue + 1, fuel.." mb", colors.white, colors.black)

  -------------Waste-------------------
  draw_text(2, yValue+ 3, "Waste: ", colors.yellow, colors.black)
  waste = math.floor(reactor.getWasteAmount())
  draw_text(23, yValue+ 3, waste.." mb", colors.white, colors.black)

  -------------ProducedLastTick-------------------
  if reactor.isActivelyCooled() then
    draw_text(2, yValue+ 5, "Hot Fluid/T: ", colors.yellow, colors.black)
  else
    draw_text(2, yValue+ 5, "RF/T: ", colors.yellow, colors.black)
  end
  waste = math.floor(reactor.getEnergyProducedLastTick())
  if reactor.isActivelyCooled() then
    draw_text(23, yValue+ 5, waste.." mb", colors.white, colors.black)
  else
    draw_text(23, yValue+ 5, waste.." RF", colors.white, colors.black)
  end

  -------------Fuel Consumption-------------------
  draw_text(2, yValue+ 7, "Fuel Consumption: ", colors.yellow, colors.black)
  draw_text(23, yValue+ 7, reactor.getFuelConsumedLastTick().." mB/t", colors.white, colors.black)

  if not reactor.isActivelyCooled() then
    draw_text(2, yValue+ 9, "Power Usage(IO): ", colors.yellow, colors.black)
    draw_text(23, yValue+ 9, math.abs((currentPower-reactor.getEnergyStored())).." RF/T", colors.white, colors.black)
    currentPower = reactor.getEnergyStored()
  end
end

function management()
	if not reactor.isActivelyCooled() then
		energy_stored = reactor.getEnergyStored()
		if energy_stored > maxLevelPower then
			reactor.setActive(false)
		elseif energy_stored < minLevelPower then
			reactor.setActive(true)
		end
	else
		if reactor.getHotFluidAmount() >= maxLevelSteam then
			reactor.setActive(false)
		elseif reactor.getHotFluidAmount() <= minLevelSteam then
			reactor.setActive(true)
		end
	end
end

drawMainStatic()

function checkxy(_, _, x, y, _, _)
  for name, data in pairs(button) do
    if y >= data["ymin"] and y <= data["ymax"] then
      if x >= data["xmin"] and x <= data["xmax"] then
        data["func"]()
        return true
      end
    end
  end
  return false
end

event.listen("touch", checkxy)

while event.pull(0.05, "interrupted") == nil do
  management()
  drawMain()
  local event, address, arg1, arg2, arg3 = event.pull(1)
  if type(address) == "string" and component.isPrimary(address) then
    if event == "key_down" and arg2 == keyboard.keys.q then
      os.exit()
    end
  end
end