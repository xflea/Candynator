-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local sound_board = require("sound_board")

local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"
--------------------------------------------

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnReleaseMenu()
	
	sound_board:playSound("menu_select")
	composer.gotoScene( "menu","slideRight", 500)
	
	return true	-- indicates successful touch
end

local function onPlayBtnReleaseChar_Select()
	
	sound_board:playSound("menu_select")
	composer.gotoScene( "char_select","slideRight", 500)
	
	return true	-- indicates successful touch
end

local function onPlayBtnReleaseRetry()
	
	sound_board:playSound("menu_select")
	composer.gotoScene( "level1" )
	
	return true	-- indicates successful touch
end

function scene:create( event )

	local currScene = composer.getSceneName( "previous" )

	if(currScene~=nil) then 
		composer.removeScene( currScene, true )
	end
 
	composer.removeScene( currScene, true )

	local sceneGroup = self.view

	io.output():setvbuf("no")

	require "ssk2.loadSSK"
	_G.ssk.init( { } )

	local pGet = ssk.persist.get 
	local pSet = ssk.persist.set

	if(tonumber(_G.player_score) > pGet("score.json", "highScore")) then
		pSet("score.json", "highScore", tonumber(_G.player_score))
	end

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "assets/background.jpg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	
	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newImage( "assets/tommy.png")
	titleLogo.x = display.contentCenterX - 165
	titleLogo.y = display.contentCenterY

	local textFinale = display.newText ("Final score: " .. tonumber(_G.player_score), display.contentCenterX + 90, display.contentCenterY - 90, "assets/fonts/marsh.ttf", 50)
	local textHighscore = display.newText ("Highscore: "..tonumber(pGet("score.json", "highScore")), display.contentCenterX + 90, display.contentCenterY - 30, "assets/fonts/marsh.ttf", 30)
	
	-- create a widget button (which will loads level1.lua on release)
	charBtn = widget.newButton{
		label="Change weapon",
		labelColor = { default={255}, over={128} },
		defaultFile="assets/button.png",
		overFile="assets/button-over.png",
		width=200, height=40,
		font="assets/fonts/marsh.ttf",
		fontSize=25,
		onRelease = onPlayBtnReleaseChar_Select	-- event listener function
	}
	charBtn.x = display.contentCenterX + 90
	charBtn.y = display.contentCenterY + 25

	retryBtn = widget.newButton{
		label="Retry",
		labelColor = { default={255}, over={128} },
		defaultFile="assets/button.png",
		overFile="assets/button-over.png",
		width=154, height=40,
		font="assets/fonts/marsh.ttf",
		fontSize=25,
		onRelease = onPlayBtnReleaseRetry	-- event listener function
	}
	
	retryBtn.x = display.contentCenterX + 90
	retryBtn.y = display.contentCenterY + 75

	menuBtn = widget.newButton{
		label="Main menu",
		labelColor = { default={255}, over={128} },
		defaultFile="assets/button.png",
		overFile="assets/button-over.png",
		width=154, height=40,
		font="assets/fonts/marsh.ttf",
		fontSize=25,
		onRelease = onPlayBtnReleaseMenu	-- event listener function
	}
	
	menuBtn.x = display.contentCenterX + 90
	menuBtn.y = display.contentCenterY + 125
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( charBtn )
	sceneGroup:insert( retryBtn )
	sceneGroup:insert( menuBtn )
	sceneGroup:insert( textHighscore )
	sceneGroup:insert( textFinale )
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
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if menuBtn then
		menuBtn:removeSelf()	-- widgets must be manually removed
		menuBtn = nil
	end
	if charBtn then
		charBtn:removeSelf()	-- widgets must be manually removed
		charBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene