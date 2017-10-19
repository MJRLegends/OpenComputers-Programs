----------- Made BY MJRLegends (Please dont claim as your own code) -----------
local component = require("component")
local gpu = component.gpu
local turbine = component.br_turbine

local colors = { blue = 0x4286F4, purple = 0xB673d6, red = 0xC14141, green = 0xDA841,
black = 0x000000, yellow = 0xffdb4d, white = 0xFFFFFF, grey = 0x47494C,
lightGray = 0xBBBBBB, lightBlue = 0x66d9ff, gray = 0x595959, lime = 0x80cd32}

gpu.setResolution(132,38)
gpu.setBackground(colors.black)
gpu.fill(1, 1, 132, 38, " ")

displayW=132
displayH=38

function clearScreen()
  gpu.fill(0, 0, displayW, displayH, " ")
end

function draw_text(x, y, text, text_color, bg_color)
  gpu.setBackground(bg_color)
  gpu.setForeground(bg_color)
  gpu.fill(x, y, displayW, 1, " ")
  gpu.setForeground(text_color)
  gpu.set(x, y, text)
end

while true do
	clearScreen()

	-- Begin Turbine 1
	draw_text(1,1, "Turbine #: 1", colors.lime, colors.black)

	draw_text(1,2, "Active: ", colors.lime, colors.black)
	draw_text(1,3, string.format("bool",turbine.getActive()), colors.lime, colors.black)

	draw_text(1,4, "RF/T: ", colors.white, colors.black)
	draw_text(1,5, "" ..turbine.getEnergyProducedLastTick(), colors.lime, colors.black)

	draw_text(1,6, "RF Stored: ", colors.white, colors.black)
	draw_text(1,7, "" ..turbine.getEnergyStored(), colors.lime, colors.black)

	draw_text(1,8, "Rotor Speed ", colors.white, colors.black)
	draw_text(1,9, "" ..turbine.getRotorSpeed(), colors.lime, colors.black)

	draw_text(1,10, "Fluid Rate: ", colors.white, colors.black)
	draw_text(1,11, "" ..turbine.getInputAmount(), colors.lime, colors.black)

	-- End Turbine1
  os.sleep(1)

end