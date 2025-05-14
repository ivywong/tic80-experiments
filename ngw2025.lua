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

player={x=MAX.x*0.67, y=CENTER.y}
leader={x=MAX.x*0.33, y=CENTER.y}

offset={x=-16,y=-16}

function TIC()

	--if btn(0) then y=y-1 end
	--if btn(1) then y=y+1 end
	if btnp(2) then player.x=player.x-1 end
	if btnp(3) then player.x=player.x+1 end

	cls(13)
	--spr(33+t%60//30*2,x,y,14,2,0,0,2,2)
	--computer
	spr(8,CENTER.x+offset.x,CENTER.y+offset.y,14,2,0,0,2,2)
	
	--octopi
	spr(33,player.x+offset.x,player.y+offset.y,14,2,0,0,2,2)
	spr(65,leader.x+offset.x,leader.y+offset.y,14,2,0,0,2,2)


	-- print("Catch the bugs!!",84,84)
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
-- 000:400006400006100000100000600006600006100000000000400006400006000000000000100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:100000100000100000100000000000000000000000000000000000000000000000000000000000000000000000000000000300
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

