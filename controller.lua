--[[QUESTA E' LA "CLASSE" DEDICATA AI JOISTICK LA USEREMO PER OGNI LIVELLO
    DOVREBBE ESSERE PIU' COMODO COSI' NO? :D:D]]
module(..., package.seeall)

local factory = require("controller.virtual_controller_factory")

local controller = factory:newController()

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local bottomMarg = display.contentHeight - display.screenOriginY
local rightMarg = display.contentWidth - display.screenOriginX


function js1()
	
	local js1Properties = {
		nToCRatio = 0.5,	
		radius = 30, 
		x = screenLeft + 80, 
		y = display.contentHeight - 45, 
		restingXValue = 0, 
		restingYValue = 0, 
		rangeX = 200, 
		rangeY = 200
	}

	local js1Name = "js1"

	js1 = controller:addJoystick(js1Name, js1Properties)

	return js1

end

function js2()

		local js2Properties = {
		nToCRatio = 0.5,	
		radius = 30, 
		x = rightMarg - 80, 
		y = display.contentHeight - 45, 
		restingXValue = 0, 
		restingYValue = 0, 
		rangeX = 600, 
		rangeY = 600
	}
	
	local js2Name = "js2"

	js2 = controller:addJoystick(js2Name, js2Properties)

	return js2

end

function setupController(displayGroup)

	controller:displayController(displayGroup)
	
end