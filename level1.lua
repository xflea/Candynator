local composer = require( "composer" )
local scene = composer.newScene()

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local bottomMarg = display.contentHeight - display.screenOriginY
local rightMarg = display.contentWidth - display.screenOriginX

local background

local bonusTable = {}
local maxBonus = 5

local player
local gameLoopTimer
local fireTimer
local movementTimer

local backGroup
local mainGroup
local uiGroup

--implemento la camera
local perspective = require("Camera.perspective")
local camera

local gioco_finito

local pauseBtn

local enemyTable

local perk = require("perk")
local sound_board = require("sound_board")

function endGame()

	gioco_finito = true
	_G.wave = 0

	sound_board:playSound("game_over")

	local scene = _G.scena

	enemies.setCurrent()

	camera:destroy()
	composer.gotoScene(scene, "zoomInOutFade", 500)

end

----------------VITA E BARRA DELLA VITA-------------

local max_player_lifes
local player_lifes

local healtBar
local damageBar

local scudino
local scudinoBis

--UPDATE BARRA DEL DANNO
function updateDamageBar()
	damageBar.x = rightMarg - 130 - player_lifes/2
	damageBar.width = max_player_lifes - player_lifes
end

function updateScudo()
	if(_G.player_scudo<=0) then 
		-- NESSUNO SCUDO
		display.remove(scudino)
		scudino = display.newImage(uiGroup, "assets/scudo0.png", rightMarg - 115, screenTop + 35)
	elseif(_G.player_scudo>0 and _G.player_scudo <= 60) then
		-- UNO SCUDO
		display.remove(scudino)
		scudino = display.newImage(uiGroup, "assets/scudo1.png", rightMarg - 115, screenTop + 35)
	elseif(_G.player_scudo>60 and _G.player_scudo <= 120) then 
		-- DUE SCUDI
		display.remove(scudino)
		scudino = display.newImage(uiGroup, "assets/scudo2.png", rightMarg - 115, screenTop + 35)
	elseif(_G.player_scudo>120) then
		-- TRE SCUDI
		display.remove(scudino)
		scudino = display.newImage(uiGroup, "assets/scudo3.png", rightMarg - 115, screenTop + 35)
	end
end

--ABBASSO LA VITA EFFETTIVA DEL PLAYER
function damagePlayer(danno)
	if(_G.player_scudo<=0) then
		player_lifes = player_lifes - danno
		updateDamageBar()
	else
		_G.player_scudo = _G.player_scudo - danno
	end
end

--CURO LA VITA FINO A 50
function autoHealt()
	if(player_lifes<=50) then
		player_lifes = player_lifes + 0.025
	end
end

local function controlloVitaTroppa()
	if (player_lifes >= max_player_lifes) then
		player_lifes = max_player_lifes
	end
	if(_G.player_scudo>=180) then
		_G.player_scudo = 180
	end

end

function curaPlayer(health)
	player_lifes = player_lifes + health
end

function controlloVita()
	if(player_lifes<=0) then
		_G.scena = "game_over"
		endGame()
	end
end

local function dropPerk(target)

	local random = math.random(70)

	if (random == 1 or random == 8) then
		perk.createScudo(mainGroup, target.x, target.y)
		scudo_spawn = false
	end

	if(random == 15 or random == 3) then
		perk.createFullVita(mainGroup, target.x, target.y)
	elseif(random == 19 or random == 18 or random == 17) then
		perk.createCandyPoints(mainGroup, target.x, target.y)
	end		

end

function ApplicaDanniNemici(target)
	target.life = target.life - danno_arma

	if (target.life < 1) then
		removeEnemy(target)
		_G.player_score = _G.player_score + 100
		textScore.text = _G.player_score
		dropPerk(target)
	end
end

function removeEnemy(target)
	display.remove(target)

	for i = #enemyTable, 1, -1 do
		if(enemyTable[i] == target) then
			table.remove(enemyTable, i)
			break
		end
	end
end

function removePerk(target)
	display.remove(target)
	for i = #bonusTable, 1, -1 do
		if(bonusTable[i] == target) then
			table.remove(bonusTable, i)
			break
		end
	end
end

function getDistance(objA, objB)
    -- Get the length for each of the components x and y
    local xDist = objB.x - objA.x
    local yDist = objB.y - objA.y

    return math.sqrt( (xDist ^ 2) + (yDist ^ 2) ) 
end

------------------------------------------------------------

if (_G.perk_selected == "life") then
	player_lifes = 150
	max_player_lifes = 150
end

local physics = require "physics"
physics.start()
physics.setGravity(0, 0)
--physics.setDrawMode("hybrid")-------------- usato per vedere bene i corpi fisici, se lo usate vedrete che schifo ho fatto con i muri verticali

local controller = require("controller")

local enemies = require("enemies")

system.activate("multitouch")

local js1 = controller.js1()
local js2 = controller.js2()

local function setupJS1()
	movementTimer = timer.performWithDelay(100, movePlayer, 0)
end

local function calculateAngle(sideX, sideY)
    if(sideX == 0 or sideY ==0) then
        return nil
    end
 
    local tanX = math.abs(sideY)/math.abs(sideX)
    local atanX = math.atan(tanX)
    local angleX = atanX * 180 / math.pi
 
    if(sideY < 0) then
        angleX = angleX * -1
    end
 
    if(sideX < 0 and sideY < 0) then
        angleX = 270 + math.abs(angleX)
    elseif(sideX < 0 and sideY > 0) then
        angleX = 270 - math.abs(angleX)
    elseif(sideX > 0 and sideY > 0) then
        angleX = 90 + math.abs(angleX)
    else
        angleX = 90 - math.abs(angleX)
    end
 
    return angleX
end

local sheetOptions =
{
	width = 45,
	height = 36,
	numFrames = 2
}

local sequence_Data = {
	{
		name = "stand",
		start = 1,
		count = 1,
		time = 0,
		loopCount = 1
	},
	{
		name = "shoot",
		start = 2,
		count = 1,
		time = 0,
		loopCount = 1
	}
}

local sheet_player = graphics.newImageSheet("assets/sprites/PlayerSprites.png", sheetOptions)

function movePlayer(event)

	if(gioco_finito==false) then
		local coords = js1:getXYValues()
		player:setLinearVelocity(coords.x, coords.y)

		if(js2:getXYValues().x == 0 and js2:getXYValues().y == 0) then
	    	local coordsD = js1:getXYValues()
	    	local angleView = calculateAngle(coordsD.x, coordsD.y)
	    	if(angleView ~= nil) then
				player:setSequence("stand")
	    		player:play()
	        	player.rotation = angleView
	        	transition.to(player, {rotation = angleView})
	    	end
		else
	    	local coordsD = js2:getXYValues()
	    	local  angleView = calculateAngle(coordsD.x, coordsD.y)
	    	player:setSequence("shoot")
	    	player:play()

	    	if (angleView ~= nil) then
	        	player.rotation = angleView
	        	transition.to(player, {rotation = angleView})
	    	end
		end

		if(js2:getXYValues().x == 0 and js2:getXYValues().y == 0) then

			player:setSequence("stand")
			player:play()
		end
	end
end

local function setupGun()
	if (_G.char_selected == "jelly") then
		fireTimer = timer.performWithDelay(400, fireSinglebullet, 0)
		danno_arma = 70
	elseif (_G.char_selected == "choco") then
		fireTimer = timer.performWithDelay(1000, fireSinglebullet, 0)
		danno_arma = 100
	elseif (_G.char_selected == "pepper") then
		fireTimer = timer.performWithDelay(850, fireSinglebullet, 0)
		danno_arma = 50
	end
end

local function setupEnemyGun()
	fireEnemyTimer = timer.performWithDelay(400, fireEnemybullet, 0)
end

function fireSinglebullet()

	if (_G.char_selected == "jelly") then
		if (js2:getXYValues() ~= nil) then

			local pos = js2:getXYValues()
			if(pos.x == 0 and pos.y == 0) then
				return true
			end

			local coloreBullet =  math.random(4)

			if (coloreBullet == 1) then
				coloreSparo = "assets/weapons/sparo_blue.png"
			elseif (coloreBullet == 2) then
				coloreSparo = "assets/weapons/sparo_red.png"
			elseif (coloreBullet == 3) then
				coloreSparo = "assets/weapons/sparo_pink.png"
			elseif (coloreBullet == 4) then
				coloreSparo = "assets/weapons/sparo_yellow.png"
			end

			local newbullet = display.newImage(mainGroup, coloreSparo, player.x, player.y)
			physics.addBody(newbullet, "dynamic", {isSensor = true})
			newbullet.isBullet = true
			newbullet.myName = "bullet"

			newbullet:toBack()

			transition.to(newbullet, {x = player.x + pos.x, y = player.y + pos.y, time = 300,
				onComplete = function() display.remove( newbullet ) end
			})

			sound_board:playSound("pew")

			newbullet:applyTorque( 1 )

			return true
		end
	elseif (_G.char_selected == "choco") then
		if (js2:getXYValues() ~= nil) then

			local pos = js2:getXYValues()
			if(pos.x == 0 and pos.y == 0) then
				return true
			end

			local newbullet = display.newImage(mainGroup, "assets/weapons/choco_gun.png", player.x, player.y)
			physics.addBody(newbullet, "dynamic", {isSensor = true})
			newbullet.isBullet = true
			newbullet.myName = "bullet"

			newbullet:toBack()

			transition.to(newbullet, {x = player.x + pos.x, y = player.y + pos.y, time = 600,
				onComplete = function() display.remove( newbullet ) end
			})

			sound_board:playSound("pew")

			newbullet:applyTorque( 3 )

			return true
		end
	elseif (_G.char_selected == "pepper") then
		if (js2:getXYValues() ~= nil) then

			local pos = js2:getXYValues()
			if(pos.x == 0 and pos.y == 0) then
				return true
			end

			local newbulletCentro = display.newImage(mainGroup, "assets/weapons/peppermint.png", player.x, player.y)
			physics.addBody(newbulletCentro, "dynamic", {isSensor = true})
			newbulletCentro.isBullet = true
			newbulletCentro.myName = "bullet"

			newbulletCentro:toBack()

			transition.to(newbulletCentro, {x = player.x + pos.x, y = player.y + pos.y, time = 500,
				onComplete = function() display.remove( newbulletCentro ) end
			})

			local newbulletDestra = display.newImage(mainGroup, "assets/weapons/peppermint.png", player.x, player.y)
			physics.addBody(newbulletDestra, "dynamic", {isSensor = true})
			newbulletDestra.isBullet = true
			newbulletDestra.myName = "bullet"

			newbulletDestra:toBack()

			transition.to(newbulletDestra, {x = player.x + pos.x + 250, y = player.y + pos.y + 250, time = 500,
				onComplete = function() display.remove( newbulletDestra ) end
			})

			local newbulletSinistra = display.newImage(mainGroup, "assets/weapons/peppermint.png", player.x, player.y)
			physics.addBody(newbulletSinistra, "dynamic", {isSensor = true})
			newbulletSinistra.isBullet = true
			newbulletSinistra.myName = "bullet"

			newbulletSinistra:toBack()

			transition.to(newbulletSinistra, {x = player.x + pos.x - 250, y = player.y + pos.y - 250, time = 500,
				onComplete = function() display.remove( newbulletSinistra ) end
			})

			sound_board:playSound("pew")

			return true
		end
	end

	if (getDistance(player,newbullet) > 400) then
		display.remove(bullet)
	end

end

function fireEnemybullet()

	if (_G.canEnemyShot == true) then

		local pos = js1:getXYValues()

		local oddShoot =  math.random(4)

		if (oddShoot == 2) then
			local newEnemybullet = display.newImage(mainGroup, "assets/enemies/enemy_bullet.png", _G.newenemy.x, _G.newenemy.y)
			physics.addBody(newEnemybullet, "dynamic", {isSensor = true})
			newEnemybullet.isBullet = true
			newEnemybullet.myName = "bullet_enemy"

			newEnemybullet:toBack()

			transition.to(newEnemybullet, {x = player.x + pos.x, y = player.y + pos.y, time = 600,
				onComplete = function() display.remove( newEnemybullet ) end
			})

			sound_board:playSound("enemy_pew")

		end

	end

end

local function gameLoop()

	-- comandi futuri
end

local function onCollision(event)

	if(event.phase == "began") then
		local ob1 = event.object1
		local ob2 = event.object2

		----
		enemyTable = enemies:getEnemyTable()
		bonusTable = perk:getPerkTable()

		------------------COLLISIONI---------------

		local targ

		if(ob1.myName == "player" and ob2.myName == "fullVita" or
			ob1.myName == "fullVita" and ob2.myName == "player")
		then
			if(ob1.myName == "fullVita") then
				targ = ob1
			else
				targ = ob2
			end
			sound_board:playSound("perk")
			curaPlayer(perk:fullVitaEffect())
			removePerk(targ)
		end

		if(ob1.myName == "player" and ob2.myName == "candyPoints" or
			ob1.myName == "candyPoints" and ob2.myName == "player")
		then
			if(ob1.myName == "candyPoints") then
				targ = ob1
			else
				targ = ob2
			end
			sound_board:playSound("perk")
			perk:candyPointsEffect()
			removePerk(targ)
		end

		if(ob1.myName == "player" and ob2.myName == "scudo" or
			ob1.myName == "scudo" and ob2.myName == "player")
		then
			if(ob1.myName == "scudo") then
				targ = ob1
			else
				targ = ob2
			end
			sound_board:playSound("perk")
			perk:scudoEffect()
			removePerk(targ)
		end

		if(ob1.myName == "player" and ob2.myName == "moab" or
			ob1.myName == "moab" and ob2.myName == "player")
		then
			if(ob1.myName == "moab") then
				targ = ob1
			else
				targ = ob2
			end
			sound_board:playSound("perk")
			perk:moabEffect()
			removePerk(targ)

			_G.player_score = _G.player_score+999
			textScore.text = _G.player_score
		end

		if((ob1.myName == "bullet" and ob2.myName == "enemy")
		or (ob1.myName == "enemy" and ob2.myName == "bullet"))
		then

			sound_board:playSound("enemy_damaged")

			local target
			if (ob1.myName == "enemy") then
				target = ob1
			else
				target = ob2
			end

			local proj
			if (ob1.myName == "bullet") then
				proj = ob1
			else
				proj = ob2
			end

			ApplicaDanniNemici(target)

			if ((ob1.myName == "enemy" or ob2.myName == "enemy") and (_G.char_selected == "jelly" or _G.char_selected == "pepper")) then
				display.remove(proj)
			end			

----------------------COLLISIONE ENEMY--------------

		elseif(ob1.myName == "player" and ob2.myName == "enemy" or
				ob1.myName == "enemy" and ob2.myName == "player")
		then
				sound_board:playSound("ouch")
				damagePlayer(10)
		elseif(ob1.myName == "player" and ob2.myName == "bullet_enemy" or ob1.myName == "bullet_enemy" and ob2.myName == "player") then
			sound_board:playSound("ouch")
			damagePlayer(20)

			if(ob1.myName == "bullet_enemy") then
				display.remove(ob1)
			else
				display.remove(ob2)
			end
		end
	end
end

--------------------------------------------PAUSA---------------------------------------------------

function pauseBtnTap(event)

	event.target.xScale = 0.95
	event.target.yScale = 0.95

	composer.showOverlay("pauseOverlay", {effect = "fade", params = {levelNum = "level1"}, isModal = true})

	return true
end

----------------------------------------------------------------------------------------------------

function initCamera()
	camera = perspective.createView()
	camera:toPoint(display.contentCenterX, display.contentCenterY)
	camera:setBounds(screenLeft + 145, screenLeft + 495, screenTop - 135, screenTop + 495)

	camera:add(player, 2, true)
	camera:add(uiGroup, 3, false)
	camera:add(mainGroup, 4, false)
	camera:add(backGroup, 5, false)
	camera:setParallax(0, 1, 0, 1, 1)
end

------------------------- QUI FINISCONO TUTTE LE FUNZIONI -----------------------------------------

local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create( event )

	_G.canEnemyShot = true

	local currScene = composer.getSceneName( "previous" )

	if(currScene~=nil) then 
		composer.removeScene( currScene, true )
	end
 
	composer.removeScene( currScene, true )

	gioco_finito = false
	_G.wave = 0
	_G.scena = ""
	_G.player_score = 0
	_G.player_scudo = 0

	enemyTable = {}

	max_player_lifes = 100
	player_lifes = max_player_lifes

	local sceneGroup = self.view

	physics.pause()

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)
	
	controller.setupController(uiGroup)

	_G.textWave = display.newText(_G.wave, centerX, screenTop + 25, "assets/fonts/marsh.ttf", 40)

	textPunteggio = display.newText("Score: ", screenLeft + 40, screenTop + 20, "assets/fonts/marsh.ttf", 20)

	_G.textScore = display.newText(_G.player_score, screenLeft + 110, screenTop + 20, "assets/fonts/marsh.ttf", 20 )

	--BARRA DELLA VITA
	healtBar = display.newRect(rightMarg - 130, screenTop + 20, max_player_lifes, 10)
	healtBar:setFillColor(000/255, 255/255, 000/250)
	healtBar.strokeWidth = 1
	healtBar:setStrokeColor(255, 255, 255, .5)

	--BARRA DEL DANNO
	damageBar = display.newRect(rightMarg - 130, screenTop + 20, 0, 10)
	damageBar:setFillColor(255/255, 000/255, 000/255)

	scudino = display.newCircle(uiGroup, rightMarg - 85, screenTop + 35, 7)
	scudino.alpha = 0.3

	player = display.newSprite(sheet_player, sequence_Data, display.contentCenterX, display.contentCenterY)
	player.x = display.contentCenterX
	player.y = display.contentCenterY
	player:setSequence("stand")
	player:play()
	physics.addBody(player, { density=1.0, bounce=0, radius = 15, isSensor = false})
	player.myName = "player"

	local background = display.newImage( backGroup, "assets/map/background.png", -1000, -1000 )
	background.anchorX = 0
	background.anchorY = 0

	local wall_top = display.newImage( mainGroup, "assets/map/wall.png", display.contentCenterX , display.contentCenterY + 500)
	physics.addBody(wall_top, "static", { density=1.0, bounce=0, isSensor = false})
	wall_top.myName = "wall_top"

	local wall_bottom = display.newImage( mainGroup, "assets/map/wall.png", display.contentCenterX , display.contentCenterY - 500)
	physics.addBody(wall_bottom, "static", { density=1.0, bounce=0, isSensor = false})
	wall_bottom.myName = "wall_bottom"

	local wall_left = display.newImage( mainGroup, "assets/map/wall.png", display.contentCenterX - 500 , display.contentCenterY)
	physics.addBody(wall_left, "static", { density=1.0, bounce=0, isSensor = false})
	wall_left.myName = "wall_left"
	wall_left.rotation = 90

	local wall_right = display.newImage( mainGroup, "assets/map/wall.png", display.contentCenterX + 500 , display.contentCenterY)
	physics.addBody(wall_right, "static", { density=1.0, bounce=0, isSensor = false})
	wall_right.myName = "wall_right"
	wall_right.rotation = 90

	pauseBtn = display.newImage(uiGroup, "assets/btn_pause/pausa.png", rightMarg - 40, screenTop + 40)
	pauseBtn.destination = "pauseOverlay"
	pauseBtn:addEventListener("tap", pauseBtnTap)

	enemies.setCurrent()
	enemies.createEnemy(mainGroup)
		
	setupGun()
	setupEnemyGun()
	setupJS1()
	
	backGroup:insert( background )
	uiGroup:insert( textScore )
	uiGroup:insert( textWave )
	uiGroup:insert( textPunteggio )
	uiGroup:insert( healtBar )
	uiGroup:insert( damageBar )


    --aggiungo gli strati della camera
    initCamera()
    print("crate")

end

function enterFrame(event)
	if(gioco_finito == false) then
		camera.damping = 10
		camera:setFocus(player)
		camera:track()
		controlloVita()
		updateDamageBar()
		updateScudo()
		autoHealt()
		controlloVitaTroppa()
		enemies.moveEnemy(player)
		enemies.waveLoop(mainGroup)
	end
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then


		-- Code here runs when the scene is still off screen (but is about to come on screen)
		print("will")
		Runtime:addEventListener( "enterFrame", enterFrame )

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		print("did")
		physics.start()
		Runtime:addEventListener("collision", onCollision)
		gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)
	end
end

-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		timer.cancel(fireEnemyTimer)
		timer.cancel(fireTimer)
		timer.cancel(movementTimer)
		timer.cancel(gameLoopTimer)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener("collision", onCollision)
		physics.pause()
		composer.removeScene("timerbasedexample")

	end
end

-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	--controller = nil
	camera:cancel()
	if(gioco_finito == false) then
		endGame()
	end

end

------------------ EVENTI // LISTENERS -------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene