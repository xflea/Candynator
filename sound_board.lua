-- qui carico tutti i file audio

local M = {}

M.sounds = {
	enemy_damaged = audio.loadSound( "assets/audio/enemy_damaged.wav" ),
	ouch = audio.loadSound( "assets/audio/ouch.wav" ),
	pew = audio.loadSound( "assets/audio/pew.wav" ),
	enemy_pew = audio.loadSound( "assets/audio/enemy_pew.wav" ),
	menu_select = audio.loadSound( "assets/audio/menu_select.wav" ),
	perk = audio.loadSound( "assets/audio/perk.wav" ),
	game_over = audio.loadSound( "assets/audio/game_over.wav" )
}

function M:playSound(to_play)
	if (_G.can_audio_play == true) then
		audio.play(self.sounds[to_play])
	end
end

return M