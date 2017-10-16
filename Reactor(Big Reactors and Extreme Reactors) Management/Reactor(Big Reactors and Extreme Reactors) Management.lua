----------- Made BY MJRLegends (Please dont claim as your own code) -----------

-----------Variables---------------------
local filesystem = require("filesystem")
local component = require("component")
local keyboard = require("keyboard")
local event = require("event")
local gpu = component.gpu
local reactors = {}
local reactorsManagement = {}

local colors = { blue = 0x4286F4, purple = 0xB673d6, red = 0xC14141, green = 0xDA841,
black = 0x000000, yellow = 0xffdb4d, white = 0xFFFFFF, grey = 0x47494C, 
lightGray = 0xBBBBBB, lightBlue = 0x66d9ff, gray = 0x595959, lime = 0x80cd32}

gpu.setResolution(132,38)
gpu.setBackground(colors.black)
gpu.fill(1, 1, 132, 38, " ")

version = "1.0.0"

displayW=132
displayH=38

currentScreen = "main"
currentReactor = 1
currentRodNumber = 0

maxFluidTank = 50000
minLevelPower = 5000000
maxLevelPower = 9000000
minLevelSteam = maxFluidTank / 2
maxLevelSteam = maxFluidTank
currentPower = 0

-----------Draw Methods/Utils---------------------
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
  gpu.fill(x, y, displayW, 1, " ")
  gpu.setForeground(text_color)
  gpu.set(x, y, text)
end

function draw_textSetClear(x, y, text, text_color, bg_color, clearAmount)
  gpu.setBackground(bg_color)
  gpu.setForeground(bg_color)
  gpu.fill(x, y, clearAmount, 1, " ")
  gpu.setForeground(text_color)
  gpu.set(x, y, text)
end

function drawButton(x, y, length, message, bg_color)
    draw_line(x, y - 1, length, bg_color)
	draw_line(x, y, length, bg_color)
    draw_line(x, y + 1, length, bg_color)
	gpu.setForeground(colors.white)
	gpu.set(x, y, message)
end

function drawButtonSmall(x, y, length, message, bg_color)
	draw_line(x, y, length, bg_color)
	gpu.setForeground(colors.white)
	gpu.set(x, y, message)
end

function clearScreen()
  gpu.fill(x, y, displayW, displayH, " ")
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-----------Screens---------------------
function drawMainScreen()
    draw_text((displayW / 2)-16,1, "MJRLegends Reactor Management " .. "v"..version, colors.blue, colors.black)
	draw_text(0,2, string.rep("-", displayW), colors.blue, colors.black)
   
    numberOfActiveReactros = 0
    numberOfActivelyCooled = 0
    totalBufferedEnergy = 0
    totalBufferedSteam = 0
    totalBufferedFuel = 0
    totalBufferedWaste = 0
    totalBufferedFuelWasteMax = 0
   
    for i=1,#reactors,1 do
        tempReactor = reactors[i]
        if tempReactor.getActive() then
            numberOfActiveReactros = numberOfActiveReactros + 1
        end
        if tempReactor.isActivelyCooled() then
            numberOfActivelyCooled = numberOfActivelyCooled + 1
            totalBufferedSteam = totalBufferedSteam + math.floor(tempReactor.getHotFluidAmount())
        else           
            totalBufferedEnergy = totalBufferedEnergy + math.floor(tempReactor.getEnergyStored())
        end
        totalBufferedFuel = totalBufferedFuel + math.floor(tempReactor.getFuelAmount())
        totalBufferedWaste = totalBufferedWaste + math.floor(tempReactor.getWasteAmount())
        totalBufferedFuelWasteMax = totalBufferedFuelWasteMax + math.floor(tempReactor.getFuelAmountMax())
    end
   
    draw_text(1,3, "Number of Online Reactors: " .. numberOfActiveReactros .. "/" .. tablelength(reactors), colors.white, colors.black)
    draw_text(1,4, "Number of Actively Cooled: " .. numberOfActivelyCooled .. "/" .. tablelength(reactors), colors.white, colors.black)
    draw_text(0,5, string.rep("-", displayW), colors.blue, colors.black)
    draw_text(1,8, "Total Stored Energy: " .. totalBufferedEnergy .. " RF", colors.yellow, colors.black)
    draw_text(1,12, "Total Stored Steam: " .. totalBufferedSteam .. " mb", colors.yellow, colors.black)
    draw_text(1,16, "Total Stored Fuel: " .. totalBufferedFuel .. " mb", colors.yellow, colors.black)
    draw_text(1,20, "Total Stored Waste: " .. totalBufferedWaste .. " mb", colors.yellow, colors.black)

    progress_bar_multi_line(2, 9, displayW-2, totalBufferedEnergy, (10000000 * (tablelength(reactors) - numberOfActivelyCooled)), colors.red, colors.gray, 2, monitor)
    progress_bar_multi_line(2, 13, displayW-2, totalBufferedSteam, ((50000 * (tablelength(reactors))) - numberOfActivelyCooled), colors.lightGray, colors.gray, 2, monitor)
    progress_bar_multi_line(2, 17, displayW-2, totalBufferedFuel, totalBufferedFuelWasteMax, colors.yellow, colors.gray, 2, monitor)
    progress_bar_multi_line(2, 21, displayW-2, totalBufferedWaste, totalBufferedFuelWasteMax, colors.blue, colors.gray, 2, monitor)	
	drawButton(0, 36, displayW, string.rep(" ", (displayW / 2)-10) .. "Information Screen", colors.blue)
end

function drawDynamicHeader()
	draw_textSetClear(displayW - 40, 3, "Reactor: " .. currentReactor, colors.blue, colors.black, 10)
    draw_text((displayW / 2)-16,1, "MJRLegends Reactor Management " .. "v"..version, colors.blue, colors.black)
	draw_text(0,2, string.rep("-", displayW), colors.blue, colors.black)
	drawButtonSmall(displayW - 46, 3, 4, " <", colors.blue)
	drawButtonSmall(displayW - 16, 3, 4, " >", colors.blue)

	if currentScreen == "rods" then
		drawButton(6, 36, 20, "   Control Screen", colors.green)
	else
		drawButton(6, 36, 20, "   Control Screen", colors.blue)
	end
	drawButton((displayW/2) - 10, 36, 20, "     Main Menu", colors.purple)
	if currentScreen == "settings" then
		drawButton(displayW - 26, 36, 20, "  Settings Screen", colors.green)
	else
		drawButton(displayW - 26, 36, 20, "  Settings Screen", colors.blue)
	end
end

function drawControl()
  drawDynamicHeader()

  local reactor = reactors[currentReactor]
  -------------Title-------------------
  draw_text(2, 4, "Reactor Information", colors.blue, colors.black)

  -----------Casing Heat---------------------
  draw_text(2, 6, "Casing Heat: ", colors.yellow, colors.black)
  local maxVal = 5000
  local minVal = math.floor(reactor.getCasingTemperature())
  draw_text(23, 6, minVal.." C", colors.white, colors.black)

  if minVal < 500 then
    progress_bar(2, 7, displayW-2, minVal, maxVal, colors.lightBlue, colors.gray)
  elseif minVal < 1000 then
    progress_bar(2, 7, displayW-2, minVal, maxVal, colors.lime, colors.gray)
  elseif minVal < 1500 then
    progress_bar(2, 7, displayW-2, minVal, maxVal, colors.yellow, colors.gray)
  elseif minVal >= 1500 then
    progress_bar(2, 7, displayW-2, minVal, maxVal, colors.red, colors.gray)
  end

  -----------Fuel Heat---------------------
  draw_text(2, 9, "Fuel Heat: ", colors.yellow, colors.black)
  local maxVal = 5000
  local minVal = math.floor(reactor.getFuelTemperature())
  draw_text(23, 9, minVal.." C", colors.white, colors.black)

  if minVal < 500 then
    progress_bar(2, 10, displayW-2, minVal, maxVal, colors.lightBlue, colors.gray)
  elseif minVal < 1000 then
    progress_bar(2, 10, displayW-2, minVal, maxVal, colors.lime, colors.gray)
  elseif minVal < 1500 then
    progress_bar(2, 10, displayW-2, minVal, maxVal, colors.yellow, colors.gray)
  elseif minVal >= 1500 then
    progress_bar(2, 10, displayW-2, minVal, maxVal, colors.red, colors.gray)
  end

  -----------Water Tank---------------------
  if reactor.isActivelyCooled() then
    draw_text(2, 12, "Water Tank: ", colors.yellow, colors.black)
    local maxVal = reactor.getHotFluidAmountMax()
    local minVal = math.floor(reactor.getCoolantAmount())
    draw_text(23, 12, minVal.." mb", colors.white, colors.black)
    progress_bar(2, 13, displayW-2, minVal, maxVal, colors.blue, colors.gray)
  else
    -----------Power Storage---------------------
    draw_text(2, 12, "Power: ", colors.yellow, colors.black)
    local maxVal = 10000000
    local minVal = math.floor(reactor.getEnergyStored())
    draw_text(23, 12, math.floor((minVal/maxVal)*100).."% " .."="..minVal.." RF", colors.white, colors.black)
    progress_bar(2, 13, displayW-2, minVal, maxVal, colors.lightGray, colors.gray)
  end

  yValue = 13

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
    yValue = 14
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

function drawRodScreen()
	drawDynamicHeader()
  	local reactor = reactors[currentReactor]
	-------------ON/OFF-------------------
	draw_text(2, 6, "Reactor: ", colors.yellow, colors.black)
    if reactor.getActive() == true then
		drawButtonSmall(20, 6, 6, " ON ", colors.blue)
    else
		drawButtonSmall(20, 6, 6, "ON ", colors.grey)
    end
 
    if reactor.getActive() == true then
		drawButtonSmall(25, 6, 6, " OFF ", colors.grey)
    else
		drawButtonSmall(25, 6, 6, " OFF ", colors.blue)
    end 	
    -------------Title-------------------
    draw_text(2, 8, "Control Rods", colors.blue, colors.black)
    
    -------------Number of Control Rods-------------------
    draw_text(2, 10, "Number of Control Rods: "..reactor.getNumberOfControlRods(), colors.white, colors.black)
    
    -------------Control Rod Number/Selection-------------------
    draw_text(2, 13, "Rod "..currentRodNumber, colors.yellow, colors.black)
	drawButtonSmall(9, 13, 3, " - ", colors.blue)
	drawButtonSmall(15, 13, 3, " + ", colors.blue)

	drawButtonSmall(22, 13, 8, " Copy to All ", colors.blue)
    -------------Control Rod Level/Increase and Decrease-------------------
    local maxVal = 100
    local minVal = math.floor(reactor.getControlRodLevel(currentRodNumber))
    rodLevel = minVal
    draw_text(2, 15, minVal.." %", colors.white, colors.black)
    progress_bar(2, 17, displayW-2, maxVal-minVal, maxVal, colors.lightGray, colors.gray)
   
   	drawButtonSmall(8, 15, 4, " +1 ", colors.blue)
   	drawButtonSmall(13, 15, 4, " +5 ", colors.blue)
   	drawButtonSmall(18, 15, 4, " +10 ", colors.blue)
   	drawButtonSmall(24, 15, 4, " -1 ", colors.blue)
   	drawButtonSmall(29, 15, 4, " -5 ", colors.blue)
   	drawButtonSmall(34, 15, 4, " -10 ", colors.blue)
end
 
function drawSettingScreen()
	drawDynamicHeader()
  	local reactor = reactors[currentReactor]
    -------------Title-------------------
    draw_text(2, 6, "Settings", colors.blue, colors.black)
      
    -----------Reactor Management Enable/Disable---------------------
	draw_text(2, 8, "Reactor Management: ", colors.yellow, colors.black)
    if reactorsManagement[currentReactor] == true then
		drawButtonSmall(20, 8, 6, " ON ", colors.blue)
    else
		drawButtonSmall(20, 8, 6, "ON ", colors.grey)
    end
 
    if reactorsManagement[currentReactor] == true then
		drawButtonSmall(25, 8, 6, " OFF ", colors.grey)
    else
		drawButtonSmall(25, 8, 6, " OFF ", colors.blue)
    end 
   
    -----------Reactor MaxFluid Tank Level---------
    if reactor.isActivelyCooled() then
		draw_text(1, 10, "Max Fluid Tank Level:", colors.blue, colors.black)
        draw_text(22, 10, maxFluidTank.." mb", colors.white, colors.black)
		drawButtonSmall(1, 11, 6, "|+100|", colors.blue)
		drawButtonSmall(6, 11, 8, "|+1000|", colors.blue)
		drawButtonSmall(12, 11, 10, "|+10,000|", colors.blue)
		drawButtonSmall(1, 12, 6, "|-100|", colors.blue)
		drawButtonSmall(6, 12, 8, "|-1000|", colors.blue)
		drawButtonSmall(12, 12, 10, "|-10,000|", colors.blue)
    end
	
    -----------Reactor Levels Max/Min---------------------
    --[[if not reactor.isActivelyCooled() then
        monitor.setCursorPos(1,11)
        monitor.setTextColour(colours.blue)
        monitor.write("Power Management Levels: ", monitor)
 
        monitor.setCursorPos(1,12)
        monitor.setTextColour(colours.yellow)
        monitor.write("Min Level:", monitor)
        monitor.setTextColour(colours.white)
        local value = minLevelPower
        draw_text(12, 12, value.." RF", colors.white, colors.black)       
        monitor.setBackgroundColour(colours.blue)
        monitor.setCursorPos(1,13)
        monitor.write("|+1|", monitor)
     
        monitor.setCursorPos(5,13)
        monitor.write("|+100|", monitor)
       
        monitor.setCursorPos(11,13)
        monitor.write("|+1000|", monitor)
       
        monitor.setCursorPos(18,13)
        monitor.write("|+10k|", monitor)
     
        monitor.setCursorPos(24,13)
        monitor.write("|+100k|", monitor)
       
        monitor.setCursorPos(31,13)
        monitor.write("|+1mill|", monitor)
       
        monitor.setCursorPos(1,14)
        monitor.write("|-1|", monitor)
     
        monitor.setCursorPos(5,14)
        monitor.write("|-100|", monitor)
       
        monitor.setCursorPos(11,14)
        monitor.write("|-1000|", monitor)
       
        monitor.setCursorPos(18,14)
        monitor.write("|-10k|", monitor)
     
        monitor.setCursorPos(24,14)
        monitor.write("|-100k|", monitor)
       
        monitor.setCursorPos(31,14)
        monitor.write("|-1mill|", monitor)
       
       
        monitor.setBackgroundColour(colours.black)
       
        monitor.setCursorPos(1,15)
        monitor.setTextColour(colours.yellow)
        monitor.write("Max Level:", monitor)
        monitor.setTextColour(colours.white)
        local value = maxLevelPower
        draw_text(12, 15, value.." RF", colors.white, colors.black)       
        monitor.setBackgroundColour(colours.blue)
       
        monitor.setCursorPos(1,16)
        monitor.write("|+1|", monitor)
     
        monitor.setCursorPos(5,16)
        monitor.write("|+100|", monitor)
       
        monitor.setCursorPos(11,16)
        monitor.write("|+1000|", monitor)
       
        monitor.setCursorPos(18,16)
        monitor.write("|+10k|", monitor)
     
        monitor.setCursorPos(24,16)
        monitor.write("|+100k|", monitor)
       
        monitor.setCursorPos(31,16)
        monitor.write("|+1mill|", monitor)
       
        monitor.setCursorPos(1,17)
        monitor.write("|-1|", monitor)
     
        monitor.setCursorPos(5,17)
        monitor.write("|-100|", monitor)
       
        monitor.setCursorPos(11,17)
        monitor.write("|-1000|", monitor)
       
        monitor.setCursorPos(18,17)
        monitor.write("|-10k|", monitor)
     
        monitor.setCursorPos(24,17)
        monitor.write("|-100k|", monitor)
       
        monitor.setCursorPos(31,17)
        monitor.write("|-1mill|", monitor)
       
    else
        monitor.setCursorPos(1,14)
        monitor.setTextColour(colours.blue)
        monitor.write("Steam Management Levels: ", monitor)
 
        monitor.setCursorPos(1,15)
        monitor.setTextColour(colours.yellow)
        monitor.write("Min Level:", monitor)
        monitor.setTextColour(colours.white)
        local value = minLevelSteam
        draw_text(12, 15, value.." mb", colors.white, colors.black)
        monitor.setBackgroundColour(colours.blue)
       
        --Higher Values
        monitor.setCursorPos(1,16)
        monitor.write("|+1|", monitor)
     
        monitor.setCursorPos(5,16)
        monitor.write("|+100|", monitor)
       
        monitor.setCursorPos(11,16)
        monitor.write("|+1000|", monitor)
       
        monitor.setCursorPos(18,16)
        monitor.write("|+10,000|", monitor)
       
        --Lower Values
        monitor.setCursorPos(1,17)
        monitor.write("|-1|", monitor)
     
        monitor.setCursorPos(5,17)
        monitor.write("|-100|", monitor)
       
        monitor.setCursorPos(11,17)
        monitor.write("|-1000|", monitor)
       
        monitor.setCursorPos(18,17)
        monitor.write("|-10,000|", monitor)
       
        monitor.setBackgroundColour(colours.black)
       
        monitor.setCursorPos(1,18)
        monitor.setTextColour(colours.yellow)
        monitor.write("Max Level:", monitor)
        monitor.setTextColour(colours.white)
        local value = maxLevelSteam
        draw_text(12, 18, value.." mb", colors.white, colors.black)
       
        monitor.setBackgroundColour(colours.blue)
        monitor.setCursorPos(1,19)
        monitor.write("|+1|", monitor)
     
        monitor.setCursorPos(5,19)
        monitor.write("|+100|", monitor)
       
        monitor.setCursorPos(11,19)
        monitor.write("|+1000|", monitor)
       
        monitor.setCursorPos(18,19)
        monitor.write("|+10,000|", monitor)
       
        monitor.setCursorPos(1,20)
        monitor.write("|-1|", monitor)
     
        monitor.setCursorPos(5,20)
        monitor.write("|-100|", monitor)
       
        monitor.setCursorPos(11,20)
        monitor.write("|-1000|", monitor)
       
        monitor.setCursorPos(18,20)
        monitor.write("|-10,000|", monitor)
    end
    monitor.setBackgroundColour(colours.black)]]--
end

-----------Reactor Management---------------------
function management()
    for i=1,#reactors,1 do
        if reactorsManagement[i] == true then
		tempReactor = reactors[i]
            if not tempReactor.isActivelyCooled() then
                energy_stored = tempReactor.getEnergyStored()
                if energy_stored > maxLevelPower then
                    tempReactor.setActive(false)
                elseif energy_stored < minLevelPower then
                    tempReactor.setActive(true)
                end
            else
                if tempReactor.getHotFluidAmount() >= maxLevelSteam then
                    tempReactor.setActive(false)
                elseif tempReactor.getHotFluidAmount() <= minLevelSteam then
                    tempReactor.setActive(true)
                end
            end
        end
    end
end

-----------Init Reactors---------------------
function getReactors()
  local i = 1
  for address, type in component.list("br_reactor") do
	reactors[i] = component.proxy(address)
	i = i + 1
  end
  local reactorNumber = 1
  for i=1,#reactors,1 do
        table.insert(reactorsManagement, reactorNumber, true)
        reactorNumber = reactorNumber +1
    end
end
getReactors()

-----------Events---------------------
function checkxy(name,address,x,y,button,player)
	if currentScreen == "main" then
		if x >=0 and y >=35 and x <=displayW and y <=37 then
			gpu.setBackground(colors.black)
			gpu.setForeground(colors.black)
			gpu.fill(0, 0, displayW, displayH, " ")
			currentScreen = "control"	
			clearScreen()
		end
	else
		if x >=(displayW - 46) and y >=3 and x <=((displayW - 46)+4) and y <=3 then
			if not currentReactor == 1 then 
				currentReactor = currentReactor - 1
			else
				currentReactor = 1
			end
			currentRodNumber = 0
		elseif x >=(displayW - 16) and y >=3 and x <=((displayW - 16)+4) and y <=3 then
			if not tablelength(reactors) == currentReactor then 
				currentReactor = currentReactor + 1
			else
				currentReactor = tablelength(reactors)
			end
			currentRodNumber = 0
		elseif x >=((displayW/2) - 10) and y >=35 and x <=(((displayW/2) - 10) + 20) and y <=37 then
			gpu.setBackground(colors.black)
			gpu.setForeground(colors.black)
			gpu.fill(0, 0, displayW, displayH, " ")
			currentScreen = "main"
			clearScreen()
		elseif x >=(displayW - 26) and y >=35 and x <=((displayW - 26) + 20) and y <=37 then
			gpu.setBackground(colors.black)
			gpu.setForeground(colors.black)
			gpu.fill(0, 0, displayW, displayH, " ")
			currentScreen = "settings"
			clearScreen()
		elseif x >=6 and y >=35 and x <=(6 + 20) and y <=37 then
			gpu.setBackground(colors.black)
			gpu.setForeground(colors.black)
			gpu.fill(0, 0, displayW, displayH, " ")
			currentScreen = "rods"
			clearScreen()
		elseif currentScreen == "rods" then
		  	local reactor = reactors[currentReactor]
			local numberOfControlRods = reactor.getNumberOfControlRods()
			local rodLevel = math.floor(reactor.getControlRodLevel(currentRodNumber))
			
			
			if x > 20 and x < 26 and y == 6 then
				reactor.setActive(true)
			elseif x > 25 and x < 31 and y == 6 then
				reactor.setActive(false)
			elseif x > 15 and x < 18 and y == 13 then
				if currentRodNumber == numberOfControlRods - 1 then
					currentRodNumber = numberOfControlRods - 1
				else
					currentRodNumber = currentRodNumber + 1
				end
			elseif x > 9 and x < 12 and y == 13 then
				if currentRodNumber == 0 then
					currentRodNumber = 0
				else
					currentRodNumber = currentRodNumber - 1
				end
			elseif x > 22 and x < 30 and y == 13 then
				reactor.setAllControlRodLevels(math.floor(reactor.getControlRodLevel(currentRodNumber)))
			
			elseif x > 8 and x < 12 and y == 15 then
				if (rodLevel + 1) > 100 then
					rodLevel = 100
				else
					rodLevel = rodLevel + 1
				end
				reactor.setControlRodLevel(currentRodNumber, rodLevel)
			elseif x > 13 and x < 17 and y == 15 then
				if (rodLevel + 5) > 100 then
					rodLevel = 100
				else
					rodLevel = rodLevel + 5
				end
				reactor.setControlRodLevel(currentRodNumber, rodLevel)
			elseif x > 18 and x < 22 and y == 15 then
				if (rodLevel + 10) > 100 then
					rodLevel = 100
				else
					rodLevel = rodLevel + 10
				end
				reactor.setControlRodLevel(currentRodNumber, rodLevel)
			elseif x > 24 and x < 28 and y == 15 then
				if (rodLevel - 1) < 0 then
					rodLevel = 0
				else
					rodLevel = rodLevel - 1
				end
				reactor.setControlRodLevel(currentRodNumber, rodLevel)
			elseif x > 29 and x < 33 and y == 15 then
				if (rodLevel - 5) < 0 then
					rodLevel = 0
				else
					rodLevel = rodLevel - 5
				end
				reactor.setControlRodLevel(currentRodNumber, rodLevel)
			elseif x > 34 and x < 41 and y == 15 then
				if (rodLevel - 10) < 0 then
					rodLevel = 0
				else
					rodLevel = rodLevel - 10
				end
				reactor.setControlRodLevel(currentRodNumber, rodLevel)
			end
		elseif currentScreen == "settings" then
			if x > 20 and x < 24 and y == 8 then
				reactorsManagement[currentReactor] = true
			elseif x > 24 and x < 28 and y == 8 then
				reactorsManagement[currentReactor] = false
			end
		end
	end
end

event.listen("touch", checkxy)

-----------Main Loop---------------------
while true do
  management()
  if currentScreen == "main" then
	drawMainScreen()
  elseif currentScreen == "control" then
	drawControl()
  elseif currentScreen == "rods" then
	drawRodScreen()
  elseif currentScreen == "settings" then
	drawSettingScreen()
  end
  local event, address, arg1, arg2, arg3 = event.pull(1)
  if type(address) == "string" and component.isPrimary(address) then
    if event == "key_down" and arg2 == keyboard.keys.q then
      os.exit()
    end
  end
  os.sleep(1)
end
