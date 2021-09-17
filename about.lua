local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"
local physics = require "physics"

local sceneGroup

--------------------------------------------

local function backBtnRelease()

	composer.gotoScene( "menu","slideRight", 500)
	return true

end

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

function scene:create( event )

	local currScene = composer.getSceneName( "previous" )

	if(currScene~=nil) then 
		composer.removeScene( currScene, true )
	end
 
	composer.removeScene( currScene, true )

	local sceneGroup = self.view

	physics.start()

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

	local background = display.newImageRect( backGroup, "assets/background_about.png", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY

	backButton = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="assets/btn_pause/dietro.png",
		width=50, height=50,
		onRelease = backBtnRelease	-- event listener function
	}
	backButton.x = display.contentCenterX - 270
	backButton.y = display.contentCenterY - 140
	
	-- all display objects must be inserted into group
	uiGroup:insert( backButton )

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then

		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)

	elseif phase == "did" then
		physics.pause()
		-- Called when the scene is now off screen
		
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	-- da rivedere maybe
	--[[
	if (weaponCandy or weaponChoco) then
		weaponCandy:removeSelf()
		weaponCandy = nil

		weaponChoco:removeSelf()
		weaponChoco = nil
	end
	]]--
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene