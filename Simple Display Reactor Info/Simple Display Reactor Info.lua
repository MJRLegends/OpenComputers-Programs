----------- Made BY MJRLegends (Please dont claim as your own code) -----------
local component = require("component")
local gpu = component.gpu
local reactor1 = component.br_reactor

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

	-- Begin Reactor 1
	draw_text(1,1, "Reactor #: 1", colors.lime, colors.black)

	draw_text(1,2, "Active: ", colors.lime, colors.black)
	draw_text(1,3, string.format("bool",reactor1.getActive()), colors.lime, colors.black)

	if reactor1.isActivelyCooled then
		draw_text(1,4, "RF/T: ", colors.white, colors.black)
	else
		draw_text(1,4, "Hot Fluid/T: ", colors.white, colors.black)

	end
	draw_text(1,5, "" ..reactor1.getEnergyProducedLastTick(), colors.lime, colors.black)


	draw_text(1,6, "Casing Heat: ", colors.white, colors.black)
	draw_text(1,7, "" ..reactor1.getCasingTemperature(), colors.lime, colors.black)

	draw_text(1,8, "Fuel Heat: ", colors.white, colors.black)
	draw_text(1,9, "" ..reactor1.getFuelTemperature(), colors.lime, colors.black)

	draw_text(1,10, "Fuel: ", colors.white, colors.black)
	draw_text(1,11, "" ..reactor1.getFuelAmount(), colors.lime, colors.black)

	draw_text(1,12, "Waste: ", colors.white, colors.black)
	draw_text(1,13, "" ..reactor1.getWasteAmount(), colors.lime, colors.black)

	draw_text(1,14, "Fuel Reactivity: ", colors.white, colors.black)
	draw_text(1,15, "" ..reactor1.getFuelReactivity(), colors.lime, colors.black)

	draw_text(1,16, "Fuel Comsumption: ", colors.white, colors.black)
	draw_text(1,17, "" ..reactor1.getFuelConsumedLastTick(), colors.lime, colors.black)

	if reactor1.isActivelyCooled()then
		draw_text(1,18, "Water Tank: : ", colors.white, colors.black)
		draw_text(1,19, "" ..reactor1.getCoolantAmount(), colors.lime, colors.black)
		
		draw_text(1,20, "Hot Fluid: ", colors.white, colors.black)
		draw_text(1,21, "" ..reactor1.getHotFluidAmount(), colors.lime, colors.black)
	else
		draw_text(1,18, "RF Stored: ", colors.white, colors.black)
		draw_text(1,19, "" ..reactor1.getEnergyStored(), colors.lime, colors.black)
	end

	-- End Reactor 1
  os.sleep(1)

end