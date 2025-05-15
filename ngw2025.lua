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
	local state={}
	
	state.track=peek(SOUND_STATE_ADDR)
	state.frame=peek(SOUND_STATE_ADDR+1)
	state.row=peek(SOUND_STATE_ADDR+2)

	return state
end

function getTrackPatterns(track,frame)
	local patterns={}
	
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

function getTotalNotes(track)
	local totalNotes=0
	for frame=0,15 do
		local patterns=getTrackPatterns(track,frame)
		
		local chNotes={}
		for row=0,15 do
			for i=0,1 do
				note=getPatternNote(patterns[i+1],row)
				if note == 1 then
					totalNotes=totalNotes+1
				end
			end
		end
	end
	return totalNotes
end
TOTAL_NOTES=getTotalNotes(1)

function getSoundRegister(channel)
	local sound = {}
	
	local value = peek(0xFF9C+18*channel+1)<<8|peek(0xFF9C+18*channel)
	sound.frequency = (value&0x0fff)
	sound.volume = (value&0xf000)>>12
	
	return sound
end

function drawComputer(beat)
	spr(8+(beat % 2)*2,
						CENTER.x+offset.x,
						CENTER.y+offset.y,
						14,2,0,0,2,2)
end

--function init()
musicplaying=false
endTrack=2
currentTrack=-1
measures=0
isDownBeat=false

score=0

player={
	x=PLAYER_ORIGIN.x,
	y=PLAYER_ORIGIN.y
}

leader={
	x=LEADER_ORIGIN.x,
	y=LEADER_ORIGIN.y
}

rowHits={
	L=false,
	R=false
}
--end

function mainGame()
	cls(13)
	print("Catch the music!!",74,100)
	--print("currentTrack: "..currentTrack, 30, 10)
	print("Score: "..score,95, 110)
	
	local state=getSoundState()
	--print("track: "..state.track,20,120)
	--print("frame: "..state.frame,80,120)
	--print("row: "..state.row,160,120)

	if state.track == 255 then
		musicplaying = false
	end

	local patterns=getTrackPatterns(state.track,state.frame)

	for p=1,4 do
		--print("p"..p..": "..patterns[p], p*30+30, 130)
	end
	
	local chNotes={}
	for i=0,3 do
		chNotes[i+1]=getPatternNote(patterns[i+1],state.row)
		--print("ch"..i.." note: "..chNotes[i+1], 50, 10+i*10)
	end
	
	local isLeaderPlaying={
		L=chNotes[1] >= 4,
		noteL=chNotes[1],
		R=chNotes[2] >= 4,
		noteR=chNotes[2]
	}
	
	local isPlayerPlaying={
		L=chNotes[3] >= 4,
		noteL=chNotes[3],
		R=chNotes[4] >= 4,
		noteR=chNotes[4]
	}
	
	if not isPlayerPlaying.L then
		rowHits.L=false
	end
	
	if not isPlayerPlaying.R then
		rowHits.R=false
	end
	
	-- TODO: clean up
	if currentTrack > 0 and isLeaderPlaying.L then
		spr(22,
							leader.x+offset.x-8,
							leader.y+offset.y-16-8,
							14,2,0,0,1,1)
	elseif currentTrack > 0 and isLeaderPlaying.R then
		spr(22,
							leader.x+offset.x+16+8,
							leader.y+offset.y-16-8,
							14,2,0,0,1,1)
	end
	
	if currentTrack > 0 and isPlayerPlaying.L then
		if btnp(2) and not rowHits.L then
				rowHits.L=true
				score=score+1
		end
		
		if rowHits.L then
			spr(7,
				player.x+offset.x, 
				player.y-24+offset.y,
				14,2,0,0,1,1)
		elseif not rowHits.L then
			spr(6,
				player.x+offset.x, 
				player.y-24+offset.y,
				14,2,0,0,1,1)
		end
		
	elseif currentTrack > 0 and isPlayerPlaying.R then
		if btnp(3) and not rowHits.R then
			rowHits.R=true
			score=score+1
		end
		
		if rowHits.R then
			spr(7,
				player.x+16+8+offset.x, 
				player.y-24+offset.y,
				14,2,0,0,1,1)
		elseif not rowHits.R then
			spr(6,
				player.x+16+8+offset.x, 
				player.y-24+offset.y,
				14,2,0,0,1,1)
		end
	end

	--only inc measures on first frame of downbeat
	if not isDownBeat and state.row % 4 == 0 then
		isDownBeat=true
		measures=measures+1
	end
	
	if state.row % 4 ~= 0 then
		isDownBeat=false
	end
	
	local beat=state.row % 4
	--print("measures: "..measures, 20, 20)
	if musicplaying then
		spr(97+beat, beat*4, 0, 14, 2, 0, 0, 1, 1)
	end
	
	drawComputer(beat)

	if currentTrack == 0 then
		print("Get ready"..string.rep(".",4-measures).."!", 84, 30, 2)
	end

	--octopi
	local bounce=t%60//30==0 and 0 or -3
	local playerSprite=33
	if btn(2) or btn(3) then
		playerSprite=playerSprite+4
	end
	local leaderSprite=65
	if currentTrack > 0 and (isLeaderPlaying.L or isLeaderPlaying.R) then
		leaderSprite=leaderSprite+4
	end
	
	spr(playerSprite,
						player.x+offset.x,
						player.y+offset.y+bounce,
						14,2,
						(btn(3) and 1 or 0),
						0,2,2)
	spr(leaderSprite,
						leader.x+offset.x,
						leader.y+offset.y+(isDownBeat and -5 or 0),
						14,2,
						(isLeaderPlaying.R and 1 or 0),
						0,2,2)
end

function gameEnd()
	cls(13)
	
	--local total=getTotalNotes(1)
	print("Game end!!",94,90)
	print("Score: "..score.."/"..TOTAL_NOTES,90,100)
	if score==TOTAL_NOTES then
		print("Perfect score!!!!!!",75,110,7)
	end
	
	drawComputer(0)
	
	spr(35,
						player.x+offset.x,
						player.y+offset.y+(t%60//20==0 and 0 or -10),
						14,2,0,0,2,2)
	spr(67,
						leader.x+offset.x,
						leader.y+offset.y+(t%60//20==1 and 0 or -10),
						14,2,0,0,2,2)
end


function TIC()
	-- ensure we only start the music a single time
 if not musicplaying and currentTrack+1 < endTrack then
  currentTrack = currentTrack+1
  music(currentTrack,0,0,false)
  musicplaying = true
 end

	if not musicplaying and currentTrack + 1 == endTrack then
		gameEnd()
	else
		mainGame()
	end

	--print(getTotalNotes(1), 20, 20)
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
-- 010:fffffffffcccccccfcfffffffcfffffffcff77fffcfffffffcf222f4fcffffff
-- 011:ffffffffcccccccfffffffcfffffffcf99ff11cfffffffcf444fffcfffffffcf
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 021:000000000cc222200cc2cc200c22c22000000000eee00eee00c0c0c00c0c0c00
-- 022:eeeeeceeeeeeecceeeeececeeeeeceececceceeccccceeeccccceeceecceeeee
-- 024:fcfffffffcccccccffffffffeeeeefffeffffffffffcfcfcffcfcfcfffffffff
-- 025:ffffffcfcccccccffffffffffffeeeeefffffffefcfcfcffcfcfcfffffffffff
-- 026:fcfffffffcccccccffffffffeeeeefffeffffffffffcfcfcffcfcfcfffffffff
-- 027:ffffffcfcccccccffffffffffffeeeeefffffffefcfcfcffcfcfcfffffffffff
-- 033:eeee3333e3e333333e3333333e33f3333e33f3333e3333333e3333443e333422
-- 034:3333eeee33333e3e333333e33f3333e33f3333e3333333e3333333e3433333e3
-- 035:e3ee33333ee333333e3333333e33ff333e3f33f33e3333333e3333443e333422
-- 036:3333ee3e33333ee3333333e333ff33e33f33f3e3333333e3333333e3433333e3
-- 037:e3ee33333ee333333e3333333e33ff333e33f3333e3333443e3334223e333422
-- 038:3333eeee33333eee333333ee3ff333ee3f3333ee333333ee433333ee433333e3
-- 044:e3ee33333ee333333e3333333e33f3333e33f3333e3333333e3333443e333422
-- 045:3333ee3e33333ee3333333e33f3333e33f3333e3333333e3333333e3433333e3
-- 049:3ee3342233ee3344e33ee333ee333333eeee33333ee33e33e333e33eeeee33ee
-- 050:43333ee33333ee33333ee33e333333ee333eeeee3e33eee333ee333ee333eeee
-- 051:3ee3342233ee3344e33ee333ee333333eeee33333ee33e33e333e33eeeee33ee
-- 052:43333ee33333ee33333ee33e333333ee333eeeee3e33eee333ee333ee333eeee
-- 053:3ee3334433ee3333e33ee333ee333333eeee3333eee33e33ee33e33e33ee33ee
-- 054:33333ee33333eee3333eee33333ee33e333333ee3e33eeee33ee33eee333ee33
-- 060:3ee3342233ee3344e33ee333ee333333eeee33333ee33e33e333e33eeeee33ee
-- 061:43333ee33333ee33333ee33e333333ee333eeeee3e33eee333ee333ee333eeee
-- 065:eeee1111e1e111111e1111111e1111b11e1111b11e1111111e1111111e111119
-- 066:1111eeee11111e1e111111e1111b11e1111b11e1111111e1991111e1449111e1
-- 067:e1ee11111ee111111e1111111e11bb111e1b11b11e1111111e1111111e111119
-- 068:1111ee1e11111ee1111111e111bb11e11b11b1e1111111e1991111e1449111e1
-- 069:e1ee11111ee111111e1111111e11bb111e11b1111e1111991e1119441e111944
-- 070:1111eeee11111eee111111ee1bb111ee1b1111ee111111ee911111ee911111e1
-- 076:e1ee11111ee111111e1111111e1111b11e1111b11e1111111e1111111e111119
-- 077:1111ee1e11111ee1111111e1111b11e1111b11e1111111e1991111e1449111e1
-- 081:1ee1111911ee1111e11ee111ee111111eeeee1111eee11e1e111ee11eeee111e
-- 082:44911ee19911ee11111ee11e111111ee1111eeee11e11ee1e11e111eee11eeee
-- 083:1ee1111911ee1111e11ee111ee111111eeeee1111eee11e1e111ee11eeee111e
-- 084:44911ee19911ee11111ee11e111111ee1111eeee11e11ee1e11e111eee11eeee
-- 085:1ee1119911ee1111e11ee111ee111111eeee1111eee11e11ee11e11e11ee11ee
-- 086:11111ee11111eee1111eee11111ee11e111111ee1e11eeee11ee11eee111ee11
-- 092:1ee1111911ee1111e11ee111ee111111eeeee1111eee11e1e111ee11eeee111e
-- 093:44911ee19911ee11111ee11e111111ee1111eeee11e11ee1e11e111eee11eeee
-- 097:eeeeeeeeeeeeeeeeeeeeeeeeeee88eeeeee88eeeeeeeeeeeeeeeeeeeeeeeeeee
-- 098:eeeeeeeeeeeeeeeeeeeeeeeeeeeaaeeeeeeaaeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 099:eeeeeeeeeeeeeeeeeeeeeeeeeeeaaeeeeeeaaeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 100:eeeeeeeeeeeeeeeeeeeeeeeeeeeaaeeeeeeaaeeeeeeeeeeeeeeeeeeeeeeeeeee
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
-- 000:4f0106400006100000000000000000000000000000000000400006400006400006400006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:00f100000000000000000000600006600006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:bf0106b00006100000000000000000000000000000000000000000000000600006600006600006600006000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:00f100000000000000000000900006100000800006800006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:400006100000000000000000600006100000000000000000400006400006400006400006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:000000000000400006100000000000000000600006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:bf0106b00006100000600006600006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:00f100000000000000000000000000800006800006100000400006400006400006400006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 059:455106100000000000000000400006100000000000000000400006100000000000000000400006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:c30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ec0320
-- 001:180000000180301000000301581000000581702000000702000000000000000000000000000000000000000000000000ec0320
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

