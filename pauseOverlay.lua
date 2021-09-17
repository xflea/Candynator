
local composer = require ("composer")
local scene = composer.newScene()

local physics = require ("physics")

local level1 = require("level1")


local params

_G.canEnemyShot = false

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local bottomMarg = display.contentHeight - display.screenOriginY
local rightMarg = display.contentWidth - display.screenOriginX

local perspective = require("Camera.perspective")
local camera

local mainGroup

function btnTap(event)
	event.target.xScale = 0.95
	event.target.yScale = 0.95

	display.remove(mainGroup)
	_G.scena = ""
	_G.scena = event.target.destination
	composer.removeScene("pauseOverlay")
	composer.gotoScene("menu", {time = 800, effect = "fade"})

	return true

end

function retryBtnTap(event)
	event.target.xScale = 0.95
	event.target.yScale = 0.95
	_G.scena = ""
	_G.scena = event.target.destination
	display.remove(mainGroup)
	composer.removeScene("pauseOverlay")
	composer.gotoScene("char_select", {time = 800, effect = "fade"})

	return true

end

function catchBackgroundOverlay(event)
	return true
end

function scene:create(event)
	local group = self.view

	physics.pause()



	mainGroup = display.newGroup()
	group:insert(mainGroup)

	local backgroundOverlay = display.newRect(mainGroup, centerX , centerY , rightMarg + 1000, bottomMarg + 1000)
		backgroundOverlay:setFillColor(black)
		backgroundOverlay.alpha = 0.6
		backgroundOverlay.isHitTestable = true
		backgroundOverlay:addEventListener("tap", catchBackgroundOverlay)
		backgroundOverlay:addEventListener("touch", catchBackgroundOverlay)

	local pauseText = display.newText("PAUSE", centerX, centerY - 50, "assets/fonts/marsh.ttf", 50)
		pauseText:setFillColor(255, 255, 255)
		mainGroup:insert(pauseText)

	local retryBtn = display.newImage(mainGroup, "assets/btn_pause/dietro.png", centerX - 130, centerY + 50)
		params = event.params
		retryBtn.destination = "char_select"
		retryBtn:addEventListener("tap", retryBtnTap)

	local menuBtn = display.newImage(mainGroup, "assets/btn_pause/menu.png", centerX, centerY + 50)
		menuBtn.destination = "menu"
		menuBtn:addEventListener("tap", btnTap)

	local playBtn = display.newImage(mainGroup, "assets/btn_pause/play.png", centerX + 130, centerY + 50)
		local function hideOverlay(event)
			composer.hideOverlay("fade", 800)
			_G.canEnemyShot = true
			display.remove(mainGroup)
		end 
		playBtn:addEventListener("tap", hideOverlay)

	

	camera = perspective.createView()
	camera:toPoint(display.contentCenterX, display.contentCenterY)

	camera:add(mainGroup, 1, false)
	camera:setParallax(1)
end

-- Called immediately after scene has moved onscreen:
function scene:show( event )
	local group = self.view
 
	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
 
end
 
 
-- Called when scene is about to move offscreen:
function scene:hide( event )
	local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  -- Reference to the parent scene object
 
    if ( phase == "will" ) then
        -- Call the "resumeGame()" function in the parent scene
    end
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroy( event )
	local group = self.view

	physics.start()
 	
 
	-- INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	-- Remove listeners attached to the Runtime, timers, transitions, audio tracks
 
end
 
 
---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
 
-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "create", scene )
 
-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "show", scene )
 
-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "hide", scene )
 
-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroy", scene )
 
 
---------------------------------------------------------------------------------
 
return scene