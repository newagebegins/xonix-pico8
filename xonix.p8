pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- map
m={}
m_lnd=1
m_sea=2
m_plr=3 -- player
m_ens=4 -- sea enemy
m_enl=5 -- land enemy
m_trl=6 -- player's sea trail

-- player
p={
 x=31,
 y=0,
 dx=0,
 dy=-1,
 in_sea=false,
 -- sea trail start coords
 tx=0,
 ty=0,
}

colors={
 [m_lnd]=1,
 [m_sea]=0,
 [m_plr]=11,
 [m_ens]=8,
 [m_enl]=9,
 [m_trl]=3,
}

-- enemies
ens={}
enl={}

function init_map()
 for y=0,63 do
  for x=0,63 do
   m[y]=m[y] or {}
   local is_land=
    y==0 or y==1 or
    y==62 or y==63 or
    x==0 or x==1 or
    x==62 or x==63
   if is_land then
    m[y][x]=m_lnd
   else
    m[y][x]=m_sea
   end
  end
 end

 m[p.y][p.x]=m_plr
end

function make_ens()
 local e={}
 while true do
  e.x=2+flr(rnd(64-2*2))
  e.y=2+flr(rnd(64-2*2))
  if m[e.y][e.x]==m_sea then
   break
  end
 end
 e.dx=rnd({-1,1})
 e.dy=rnd({-1,1})
 add(ens,e)
 m[e.y][e.x]=m_ens
end

function make_enl()
 local e={}
 e.x=31
 e.y=63
 e.dx=rnd({-1,1})
 e.dy=rnd({-1,1})
 add(enl,e)
 m[e.y][e.x]=m_enl
end

function init_enemies()
 for i=1,3 do
  make_ens()
 end
 make_enl() 
end

function _init()
 init_map()
 init_enemies()
end

-->8
function handle_input()
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
end

function hit_player()
 run()
end

function move_player()
 local bg=p.in_sea and m_trl
  or m_lnd
 m[p.y][p.x]=bg
 p.x+=p.dx
 p.y+=p.dy
 m[p.y][p.x]=m_plr
end

function expand_land()
 -- todo
end

function update_player()
 local nx=p.x+p.dx
 local ny=p.y+p.dy
 local to=m[ny] and m[ny][nx]
 if p.in_sea then
  if to==m_lnd then
   move_player()
   p.in_sea=false
   expand_land()
  elseif to==m_sea then
   move_player()
  elseif to==m_ens or
         to==m_enl or
         to==m_trl then
   hit_player()
  else
   assert(false)
  end
 else
  if to==nil then
   -- don't move
  elseif to==m_lnd then
   move_player()
  elseif to==m_sea then
   move_player()
   p.in_sea=true
   p.tx=p.x
   p.ty=p.y
  elseif to==m_ens or
         to==m_enl then
   hit_player()
  else
   assert(false)
  end
 end
end

function update_enl_h(e)
 local nx=e.x+e.dx
 local to=m[e.y] and m[e.y][nx]
 if to==nil or
    to==m_sea or
    to==m_ens or
    to==m_enl or
    to==m_trl then
  e.dx*=-1
 elseif to==m_lnd then
  m[e.y][e.x]=m_lnd
  e.x=nx
  m[e.y][e.x]=m_enl
 elseif to==m_plr then
  hit_player()
 else
  assert(false)
 end
end

function update_enl_v(e)
 local ny=e.y+e.dy
 local to=m[ny] and m[ny][e.x]
 if to==nil or
    to==m_sea or
    to==m_ens or
    to==m_enl or
    to==m_trl then
  e.dy*=-1
 elseif to==m_lnd then
  m[e.y][e.x]=m_lnd
  e.y=ny
  m[e.y][e.x]=m_enl
 elseif to==m_plr then
  hit_player()
 else
  assert(false)
 end
end

function update_enl(e)
 update_enl_h(e)
 update_enl_v(e)
end

function update_ens_h(e)
 local nx=e.x+e.dx
 local to=m[e.y] and m[e.y][nx]
 if to==m_lnd or
    to==m_enl or
    to==m_ens then
  e.dx*=-1
 elseif to==m_sea then
  m[e.y][e.x]=m_sea
  e.x=nx
  m[e.y][e.x]=m_ens
 elseif to==m_plr or
        to==m_trl then
  hit_player()
 else
  assert(false)
 end
end

function update_ens_v(e)
 local ny=e.y+e.dy
 local to=m[ny] and m[ny][e.x]
 if to==m_lnd or
    to==m_ens or
    to==m_enl then
  e.dy*=-1
 elseif to==m_sea then
  m[e.y][e.x]=m_sea
  e.y=ny
  m[e.y][e.x]=m_ens
 elseif to==m_plr or
        to==m_trl then
  hit_player()
 else
  assert(false)
 end
end

function update_ens(e)
 update_ens_h(e)
 update_ens_v(e)
end

function update_enemies()
 foreach(enl, update_enl)
 foreach(ens, update_ens)
end

function _update()
 handle_input()
 update_player()
 update_enemies()
end

-->8
function _draw()
 cls()
 for y=0,63 do
  for x=0,63 do
   rectfill(x*2,y*2,
            x*2+1,y*2+1,
            colors[m[y][x]])
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
