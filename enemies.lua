
module(..., package.seeall)

local physics = require("physics")

local enemyTable = {}
local maxEnemies = 5

local current

_G.wave = 0


function createEnemy(sceneGroup)
	if(#enemyTable >= maxEnemies) then
		return true
	end

	_G.wave = _G.wave + 1
	_G.textWave.text = _G.wave

	if(_G.wave >= 1 and _G.wave <= 3) then
		local num = 5 + _G.wave
		for i=num, 1, -1 do
			local spawnX = math.random(-233, 713)
			local spawnY = math.random(-313, 633)
			_G.newenemy = display.newImage(sceneGroup, "assets/enemies/marza.png", spawnX, spawnY)
			table.insert(enemyTable, newenemy)
			physics.addBody(newenemy, {radius = 15})
			newenemy.myName = "enemy"
			newenemy.life = 90
			newenemy.isBoss = false
			newenemy.points = 100
		end

	elseif(_G.wave>3 and _G.wave < 5) then
		local num = _G.wave*2
		for i=num, 1, -1 do
			local spawnX = math.random(-233, 713)
			local spawnY = math.random(-313, 633)
			_G.newenemy = display.newImage(sceneGroup, "assets/enemies/marza.png", spawnX, spawnY)
			table.insert(enemyTable, newenemy)
			physics.addBody(newenemy, {radius = 15})
			newenemy.myName = "enemy"
			newenemy.life = 90
			newenemy.isBoss = false
			newenemy.points = 150
		end

	elseif(_G.wave>5) then
		local num = 7 + _G.wave
		for i=num-1, 1, -1 do
			local spawnX = math.random(-233, 713)
			local spawnY = math.random(-313, 633)
			_G.newenemy = display.newImage(sceneGroup, "assets/enemies/marza.png", spawnX, spawnY)
			table.insert(enemyTable, newenemy)
			physics.addBody(newenemy, {radius = 15})
			newenemy.myName = "enemy"
			newenemy.life = 90
			newenemy.isBoss = false
			newenemy.points = 200
		end

		local spawnX = math.random(-233, 713)
		local spawnY = math.random(-313, 633)
		_G.newenemy = display.newImage(sceneGroup, "assets/enemies/marzaBoss.png", spawnX, spawnY)
		table.insert(enemyTable, newenemy)
		physics.addBody(newenemy, {radius = 15})
		newenemy.myName = "enemy"
		newenemy.life = 200
		newenemy.isBoss = true
		newenemy.points = 500
	end
end

function waveLoop(sceneGroup)
	if(#enemyTable==0) then
		createEnemy(sceneGroup)
	end

end

function getEnemyTable()
	return enemyTable
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

function moveEnemy(target)
	for i=#enemyTable, 1, -1 do
		current = enemyTable[i]
		if(current.y ~= nil and current.x ~= nil) then

			local velocityY = target.y - current.y
			if (velocityY > 100) then
				velocityY = 100
			elseif (velocityY < -100)then
				velocityY = -100
			end
	
			local velocityX = target.x - current.x
			if (velocityX > 100) then
				velocityX = 100
			elseif (velocityX < -100)then
				velocityX = -100
			end
	
	    	local  angleView = calculateAngle(velocityX, velocityY)
	    	if (angleView ~= nil) then
	    	    current.rotation = angleView
	    	    transition.to(current, {rotation = angleView})
	    	end
	
    		current:setLinearVelocity(velocityX,velocityY)
    	end
    end
end

function setCurrent()
	for i=#enemyTable, 1, -1 do
		table.remove(enemyTable, i)
	end
end