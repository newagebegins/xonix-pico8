pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- tile types
t_land=1
t_sea=2
t_player=3

tiles={}
colors={}
player={}

function _init()
 colors[t_land]=1
 colors[t_sea]=0
 colors[t_player]=11

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
 
 local p=player
 p.y=0
 p.x=31
 p.dx=0
 p.dy=0

 tiles[p.y][p.x]=t_player
end

function _update()
 local p=player

 if btn(➡️) then
  p.dx=1
  p.dy=0
 end
 if btn(⬅️) then
  p.dx=-1
  p.dy=0
 end
 if btn(⬆️) then
  p.dx=0
  p.dy=-1
 end
 if btn(⬇️) then
  p.dx=0
  p.dy=1
 end

 local nx=p.x+p.dx
 local ny=p.y+p.dy
 if 0<=nx and nx<=63 and
    0<=ny and ny<=63 and
    tiles[ny][nx]==t_land then
  tiles[p.y][p.x]=t_land
  p.x=nx
  p.y=ny
  tiles[p.y][p.x]=t_player
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
