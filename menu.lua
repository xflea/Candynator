-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local sound_board = require("sound_board")
local composer = require( "composer" )
local scene = composer.newScene()

io.output():setvbuf("no")

require "ssk2.loadSSK"
_G.ssk.init( { } )

ssk.persist.setDefault( "score.json", "highScore", 0 )

local pGet = ssk.persist.get 
local pSet = ssk.persist.set

---------------------------------------AUDIO OPTION------------------------------------------

local function leggiHighscore()
	return pGet("score.json", "highScore")
end

local function checkAudio()

	io.output():setvbuf("no")

	require "ssk2.loadSSK"
	_G.ssk.init( { } )

	ssk.persist.setDefault( "dataApp.json", "audioActivated", "on" )

	local pGet = ssk.persist.get 
	local pSet = ssk.persist.set

	if(pGet("dataApp.json", "audioActivated") == "on") then
		audioBtnOn.isVisible = true
		audioBtnOff.isVisible = false
		_G.can_audio_play = true
	elseif(pGet("dataApp.json", "audioActivated") == "off") then
		audioBtnOn.isVisible = false
		audioBtnOff.isVisible = true
		_G.can_audio_play = false
	end

end

local function tastoAudioPremuto()

	local pGet = ssk.persist.get 
	local pSet = ssk.persist.set

	if(pGet("dataApp.json", "audioActivated") == "on") then
		pSet("dataApp.json", "audioActivated", "off")
		audioBtnOn.isVisible = false
		audioBtnOff.isVisible = true
		_G.can_audio_play = false
	elseif(pGet("dataApp.json", "audioActivated") == "off") then
		pSet("dataApp.json", "audioActivated", "on")
		audioBtnOn.isVisible = true
		audioBtnOff.isVisible = false
		_G.can_audio_play = true
	end
end

--------------------------------------------------------------------------------------------

-- include Corona's "widget" library
local widget = require "widget"
local physics = require "physics"

local sceneGroup

-- forward declarations and other locals
local playBtn, scoresBtn, aboutBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()

	sound_board:playSound("menu_select")
	composer.gotoScene( "char_select", "slideLeft", 500 )
	
	return true	-- indicates successful touch
end

local function onAboutBtnRelease()

	sound_board:playSound("menu_select")	
	composer.gotoScene( "about", "slideLeft", 500 )
	
	return true	-- indicates successful touch
end

local function tastoHelpPremuto()

	sound_board:playSound("menu_select")	
	composer.gotoScene( "help", "slideLeft", 500 )
	
	return true	-- indicates successful touch
end

local function audioBtnRelease()

	checkAudio()	

	return true	-- indicates successful touch

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

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( backGroup, "assets/background.jpg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY

	local titleLogo = display.newText ("Candynator", display.contentCenterX, display.contentCenterY - 100, "assets/fonts/candy.ttf", 73)
	titleLogo:setFillColor( 230, 0, 0 )

	local currentHighscoreText = display.newText ("Current highscore: " .. leggiHighscore(), display.contentCenterX, display.contentCenterY - 10, "assets/fonts/marsh.ttf", 25)

	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		label="Play",
		labelColor = { default={255}, over={128} },
		defaultFile="assets/button.png",
		overFile="assets/button-over.png",
		width=154, height=50,
		font="assets/fonts/marsh.ttf",
		fontSize=25,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentHeight - 110

	aboutBtn = widget.newButton{
		label="About",
		labelColor = { default={255}, over={128} },
		defaultFile="assets/button.png",
		overFile="assets/button-over.png",
		width=154, height=50,
		font="assets/fonts/marsh.ttf",
		fontSize=25,
		onRelease = onAboutBtnRelease	-- event listener function
	}
	aboutBtn.x = display.contentCenterX
	aboutBtn.y = display.contentHeight - 50

	audioBtnOn = widget.newButton{
		defaultFile="assets/btn_menu/audio_on.png",
		width=50, height=50,
		onRelease = tastoAudioPremuto	-- event listener function
	}
	audioBtnOn.x = display.contentCenterX + 270
	audioBtnOn.y = display.contentCenterY - 140

	audioBtnOff = widget.newButton{
		defaultFile="assets/btn_menu/audio_off.png",
		width=50, height=50,
		onRelease = tastoAudioPremuto	-- event listener function
	}
	audioBtnOff.x = display.contentCenterX + 270
	audioBtnOff.y = display.contentCenterY - 140

	helpBtn = widget.newButton{
		defaultFile="assets/btn_menu/help.png",
		overFile="assets/btn_menu/help_pressed.png",
		width=50, height=50,
		onRelease = tastoHelpPremuto	-- event listener function
	}
	helpBtn.x = display.contentCenterX + 270
	helpBtn.y = display.contentCenterY - 80
	
	-- all display objects must be inserted into group
	uiGroup:insert( titleLogo )
	uiGroup:insert( playBtn )
	uiGroup:insert( aboutBtn )
	uiGroup:insert( audioBtnOn )
	uiGroup:insert( audioBtnOff )
	uiGroup:insert( helpBtn )
	uiGroup:insert( currentHighscoreText )

	checkAudio()

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

	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
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