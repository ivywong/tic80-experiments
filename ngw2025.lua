-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

t=0

CENTER={x=120,y=68}
MAX={x=240,y=136}

PLAYER_ORIGIN={x=MAX.x*0.67, y=CENTER.y}
LEADER_ORIGIN={x=MAX.x*0.33, y=CENTER.y}

offset={x=-16,y=-16}

SOUND_REGISTERS_ADDR=0x0FF9C
MUSIC_PATTERNS_ADDR=0x11164
MUSIC_TRACKS_ADDR=0x13E64
SOUND_STATE_ADDR=0x13FFC

function getSoundState()
	state={}
	
	state.track=peek(SOUND_STATE_ADDR)
	state.frame=peek(SOUND_STATE_ADDR+1)
	state.row=peek(SOUND_STATE_ADDR+2)

	return state
end

function getTrackPatterns(track,frame)
	patterns={}
	
	local value=0
	
	for i=2,0,-1 do
		value=value|peek(MUSIC_TRACKS_ADDR+51*track+3*frame+i)<<(i*8)
	end
	
	patterns={
		(value&0x3F)>>0,
		(value&0xFC0)>>6,
		(value&0x3F000)>>12,
		(value&0xFC0000)>>18
	}
	
	return patterns
end

function getPatternNote(pattern, row)
	-- get last four bits
	return peek(MUSIC_PATTERNS_ADDR+192*(pattern-1)+3*row)& 0x0F
end
	
function getSoundRegister(channel)
	sound = {}
	
	value = peek(0xFF9C+18*channel+1)<<8|peek(0xFF9C+18*channel)
	sound.frequency = (value&0x0fff)
	sound.volume = (value&0xf000)>>12
	
	return sound
end

musicplaying=false

function TIC()
	-- ensure we only start the music a single time
 if not musicplaying then
  music(0)
  musicplaying = true
 end
	
	player={
		x=PLAYER_ORIGIN.x,
		y=PLAYER_ORIGIN.y
	}
	
	leader={
		x=LEADER_ORIGIN.x,
		y=LEADER_ORIGIN.y
	}

	cls(13)
	print("Catch the music!!",74,104)
	
	if btn(2) then 
		-- player.x=player.x-16
		print("L!", 
			player.x+offset.x, 
			player.y-16+offset.y) 
	elseif btn(3) then
		-- player.x=player.x+16 
		print("R!", 
			player.x+16+8+offset.x, 
			player.y-16+offset.y)
	end
	
	if btnp(2) then 
		-- player.x=player.x-16
		print("hit!", 
			player.x+offset.x, 
			player.y-16+offset.y-10) 
	elseif btnp(3) then 
		-- player.x=player.x-16
		print("hit!", 
			player.x+16+8+offset.x, 
			player.y-16+offset.y-10) 
	end
	
	state=getSoundState()
	--print("track: "..state.track,20,120)
	--print("frame: "..state.frame,80,120)
	--print("row: "..state.row,160,120)

	patterns=getTrackPatterns(state.track,state.frame)

	for p=1,4 do
		--print("p"..p..": "..patterns[p], p*30+30, 130)
	end
	
	chNotes={}
	for i=0,3 do
		chNotes[i+1]=getPatternNote(patterns[i+1],state.row)
		--print("ch"..i.." note: "..chNotes[i+1], 50, 10+i*10)
	end
	
	-- TODO: clean up
	if chNotes[1] >= 4 then
		spr(22,
							leader.x+offset.x-8,
							leader.y+offset.y-16-8,
							14,2,0,0,1,1)
	elseif chNotes[2] >= 4 then
		spr(22,
							leader.x+offset.x+16+8,
							leader.y+offset.y-16-8,
							14,2,0,0,1,1)
	end
	
	if chNotes[3] >= 4 then 
		spr(6, 
			player.x+offset.x, 
			player.y-24+offset.y,
			14,2,0,0,1,1)
	elseif chNotes[4] >= 4 then
		spr(6,
			player.x+16+8+offset.x, 
			player.y-24+offset.y,
			14,2,0,0,1,1)
	end

	-- DRAW
	--spr(33+t%60//30*2,x,y,14,2,0,0,2,2)
	--computer
	spr(8,
						CENTER.x+offset.x,
						CENTER.y+offset.y,
						14,2,0,0,2,2)

	isDownBeat=state.row % 4 == 0
	beat=state.row % 4
	spr(10+beat, beat*4, 0, 14, 2, 0, 0, 1, 1)

	--octopi
	bounce=t%60//30==0 and 0 or -3
	spr(33,
						player.x+offset.x,
						player.y+offset.y+bounce,
						14,2,0,0,2,2)
	spr(65,
						leader.x+offset.x,
						leader.y+offset.y+(isDownBeat and -5 or 0),
						14,2,0,0,2,2)

	t=t+1
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 005:eeeeeceeeeeeecceeeeececeeeeeceececceceeccccceeeccccceeceecceeeee
-- 006:eeeee2eeeeeee22eeeee2e2eeeee2ee2e22e2ee22222eee22222ee2ee22eeeee
-- 007:eeeeeeeeee2eeeeee2e2eeeeee2eeeeeeeeeeeeeeeeee2eeeeeeeeeeeeeeeeee
-- 008:fffffffffcccccccfcfffffffcfffffffc77ff99fcfffffffcff222ffcffffff
-- 009:ffffffffcccccccfffffffcfffffffcfff11ffcfffffffcf4444ffcfffffffcf
-- 010:eeeeeeeeeeeeeeeeeeeeeeeeeee88eeeeee88eeeeeeeeeeeeeeeeeeeeeeeeeee
-- 011:eeeeeeeeeeeeeeeeeeeeeeeeeeeaaeeeeeeaaeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 012:eeeeeeeeeeeeeeeeeeeeeeeeeeeaaeeeeeeaaeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 013:eeeeeeeeeeeeeeeeeeeeeeeeeeeaaeeeeeeaaeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 021:000000000cc222200cc2cc200c22c22000000000eee00eee00c0c0c00c0c0c00
-- 022:eeeeeaeeeeeeeaaeeeeeaeaeeeeeaeeaeaaeaeeaaaaaeeeaaaaaeeaeeaaeeeee
-- 024:fcfffffffcccccccffffffffeeeeefffeffffffffffcfcfcffcfcfcfffffffff
-- 025:ffffffcfcccccccffffffffffffeeeeefffffffefcfcfcffcfcfcfffffffffff
-- 033:e3ee33333ee333333e3333333e33f3333e33f3333e3333333e3333443e333422
-- 034:3333ee3e33333ee3333333e33f3333e33f3333e3333333e3333333e3433333e3
-- 035:e3ee33333ee333333e3333333e3333333e33ff333e3333333e3333443e333422
-- 036:3333ee3e33333ee3333333e3333333e33ff333e3333333e3333333e3433333e3
-- 037:e3ee33333ee333333e3333333e33ff333e33f3333e3333333e3333443e333422
-- 038:3333ee3e33333ee3333333e33ff333e33f3333e3333333e3333333e3433333e3
-- 049:3ee3342233ee3344e33ee333ee333333eeee33333ee33e33e333e33eeeee33ee
-- 050:43333ee33333ee33333ee33e333333ee333eeeee3e33eee333ee333ee333eeee
-- 051:3ee3342233ee3344e33ee333ee333333eeee33333ee33e33e333e33eeeee33ee
-- 052:43333ee33333ee33333ee33e333333ee333eeeee3e33eee333ee333ee333eeee
-- 053:3ee3342233ee3344e33ee333ee333333eeee33333ee33e33e333e33eeeee33ee
-- 054:43333ee33333ee33333ee33e333333ee333eeeee3e33eee333ee333ee333eeee
-- 065:eaeeaaaaaeeaaaaaaeaaaaaaaeaaaafaaeaaaafaaeaaaaaaaeaaaaaaaeaaaaa9
-- 066:aaaaeeaeaaaaaeeaaaaaaaeaaaafaaeaaaafaaeaaaaaaaea99aaaaea449aaaea
-- 081:aeeaaaa9aaeeaaaaeaaeeaaaeeaaaaaaeeeeeaaaaeeeaaeaeaaaeeaaeeeeaaae
-- 082:449aaeea99aaeeaaaaaeeaaeaaaaaaeeaaaaeeeeaaeaaeeaeaaeaaaeeeaaeeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PATTERNS>
-- 000:4f0106400006100000100000100000100000100000000000400006400006000000000000100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:00f100000000100000100000600006600006100000000000000000000000000000000000100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:1800000001800000000000000000000000000000000000000000000000000000000000000000000000000000000000008d0300
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

