pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- tile types
t_land=1
t_sea=2

tiles={}
colors={}

function _init()
 colors[t_land]=12
 colors[t_sea]=0

 for r=0,63 do
  for c=0,63 do
   tiles[r] = tiles[r] or {}
   local is_land=
    r==0 or r==1 or
    r==62 or r==63 or
    c==0 or c==1 or
    c==62 or c==63
   if is_land then
    tiles[r][c]=t_land
   else
    tiles[r][c]=t_sea
   end
  end
 end
end

function _draw()
 cls()
 for r=0,63 do
  for c=0,63 do
   rectfill(c*2,r*2,
            c*2+1,r*2+1,
            colors[tiles[r][c]])
  end
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
