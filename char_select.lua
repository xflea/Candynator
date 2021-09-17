local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"
local physics = require "physics"

local sound_board = require("sound_board")

local sceneGroup

io.output():setvbuf("no")

require "ssk2.loadSSK"
_G.ssk.init( { } )

local pGet = ssk.persist.get 
local pSet = ssk.persist.set

----- records unlocks -----

local record_unlock_pepper = 15000
local record_unlock_choco = 50000

---------------------------

local function leggiHighscore()
	return pGet("score.json", "highScore")
end

local function buttonBuilder(nameBtn, funcBtn, img, pos_x, pos_y)
	nameBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="assets/char/".. img ..".png",
		overFile="assets/char/".. img ..".png",
		width=70, height=70,
		onRelease = funcBtn	-- event listener function
	}
	nameBtn.x = display.contentCenterX + pos_x
	nameBtn.y = display.contentCenterY + pos_y

	uiGroup:insert( nameBtn )

end

--------------------------------------------

-- forward declarations and other locals
local weaponCandy, weaponChoco, playLevel3
_G.char_selected = nil

local function weaponCandyBtnRelease()

	_G.char_selected = "jelly"
	sound_board:playSound("menu_select")
	composer.gotoScene( "level1" )
	
	return true
end

local function weaponChocoBtnRelease()

	_G.char_selected = "choco"
	sound_board:playSound("menu_select")
	composer.gotoScene( "level1")
	
	return true
end

local function weaponPepperBtnRelease()

	_G.char_selected = "pepper"
	sound_board:playSound("menu_select")
	composer.gotoScene( "level1")
	
	return true
end

local function backBtnRelease()

	composer.gotoScene( "menu","slideRight", 500 )
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

	fallingCandyGroup = display.newGroup()
	sceneGroup:insert(fallingCandyGroup)

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

	local titleLogo = display.newText ("Weapon select", display.contentCenterX, display.contentCenterY - 100, "assets/fonts/candy.ttf", 55)
	titleLogo:setFillColor( 230, 0, 0 )

	local weaponLockedLabelPepper = display.newText ("Unlock at\n" .. "   " .. record_unlock_pepper, display.contentCenterX, display.contentCenterY + 120, "assets/fonts/marsh.ttf", 20)

	local weaponLockedLabelChoco = display.newText ("Unlock at\n" .. "   " .. record_unlock_choco, display.contentCenterX + 130, display.contentCenterY + 120, "assets/fonts/marsh.ttf", 20)

	if(leggiHighscore() > record_unlock_choco) then
		weaponChoco = buttonBuilder(weaponChoco, weaponChocoBtnRelease, "pg2", 130, 30)
		weaponLockedLabelChoco.isVisible = false
	else
		weaponChoco = buttonBuilder(weaponChoco, nil, "char_locked", 130, 30)
	end

	if(leggiHighscore() > record_unlock_pepper) then
		weaponPepper = buttonBuilder(weaponPepper, weaponPepperBtnRelease, "pg3", 0, 30)
		weaponLockedLabelPepper.isVisible = false
	else
		weaponPepper = buttonBuilder(weaponPepper, nil, "char_locked", 0, 30)
	end
	
	
	weaponCandy = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="assets/char/pg1.png",
		overFile="assets/char/pg1.png",
		width=70, height=70,
		onRelease = weaponCandyBtnRelease	-- event listener function
	}
	weaponCandy.x = display.contentCenterX - 130
	weaponCandy.y = display.contentCenterY + 30

	backButton = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="assets/btn_pause/dietro.png",
		width=50, height=50,
		onRelease = backBtnRelease	-- event listener function
	}
	backButton.x = display.contentCenterX - 270
	backButton.y = display.contentCenterY - 140
	
	-- all display objects must be inserted into group
	uiGroup:insert( titleLogo )
	uiGroup:insert( weaponCandy )
	uiGroup:insert( backButton )
	uiGroup:insert( weaponLockedLabelChoco )
	uiGroup:insert( weaponLockedLabelPepper )

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