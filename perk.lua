module(..., package.seeall)

local physics = require("physics")
local enemies = require("enemies")

local perkTable = {}
local enemyTable = enemies:getEnemyTable()

local moab

local fullVita

local candyPoints

local scudo

local speed
local rateo

function getPerkTable()
	return perkTable
end

--============================================  MOAB  ==================================================================================
function createMoab(sceneGroup, x, y)
	table.insert(perkTable, moab)

	moab = display.newImage(sceneGroup, "assets/perks/moab.png", x, y)
	timer.performWithDelay(10, function() 
		physics.addBody(moab, "static", {width = 40, height = 40, friction = 2, isSensor = true})
		end )
	moab.myName = "moab"
	sceneGroup:insert( moab )
end

function moabEffect()
	for i = #enemyTable, 1, -1 do
		display.remove(enemyTable[i])
		table.remove(enemyTable, i)			
	end
end
--=====================================  FULL VITA  ==================================================================================

function createFullVita(sceneGroup, x, y)
	table.insert(perkTable, fullVita)

	fullVita = display.newImage(sceneGroup, "assets/perks/fullVita2.png", x, y)
	timer.performWithDelay(10, function()
		physics.addBody(fullVita, "static", {width = 40, height = 40, friction = 2, isSensor = true})
		end )
	fullVita.myName = "fullVita"
	sceneGroup:insert( fullVita )
end

function fullVitaEffect()
	return 9999999
end

--=====================================  PUNTI CARAMELLA  ==================================================================================

function createCandyPoints(sceneGroup, x, y)
	table.insert(perkTable, candyPoints)

	candyPoints = display.newImage(sceneGroup, "assets/perks/points2.png", x, y)
	timer.performWithDelay(10, function()
		physics.addBody(candyPoints, "static", {width = 40, height = 40, friction = 2, isSensor = true})
		end )
	candyPoints.myName = "candyPoints"
	sceneGroup:insert( candyPoints )
end

function candyPointsEffect()
	_G.player_score = _G.player_score + 500
end

--===================================================  SCUDO  ==================================================================================

function createScudo(sceneGroup, x, y)
	table.insert(perkTable, scudo)

	scudo = display.newImage(sceneGroup, "assets/perks/scudo2.png", x, y)
	timer.performWithDelay(10, function()
		physics.addBody(scudo, "static", {width = 40, height = 40, friction = 2, isSensor = true})
		end )
	scudo.myName = "scudo"
	sceneGroup:insert( scudo )
end

function scudoEffect()
	_G.player_scudo = _G.player_scudo + 125
end