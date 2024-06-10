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

mw=64 -- map width
mh=61 -- map height

score=0
full=0 -- land filled percent
lives=3

-- player
p={}
hit=false

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

num_ens=3

dirs={
 {x=0,y=-1},
 {x=1,y=0},
 {x=0,y=1},
 {x=-1,y=0}, 
}

is_game_over=false

timer_max=89
timer=timer_max
timer_spd=0.075

function v_add(v,w)
 return {x=v.x+w.x,y=v.y+w.y}
end

function init_map()
 for y=0,mh-1 do
  for x=0,mw-1 do
   m[y]=m[y] or {}
   local is_land=
    y==0 or y==1 or
    y==mh-2 or y==mh-1 or
    x==0 or x==1 or
    x==mw-2 or x==mw-1
   if is_land then
    m[y][x]=m_lnd
   else
    m[y][x]=m_sea
   end
  end
 end
end

function init_player()
 p.x=flr(mw/2)-1
 p.y=0
 p.dx=0
 p.dy=-1
 p.in_sea=false

 m[p.y][p.x]=m_plr
end

function remove_player()
 local bg=p.in_sea
          and m_sea or m_lnd
 m[p.y][p.x]=bg
end

function make_ens()
 local e={}
 while true do
  e.x=2+flr(rnd(mw-2*2))
  e.y=2+flr(rnd(mh-2*2))
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
 e.x=flr(mw/2)-1
 e.y=mh-1
 while m[e.y][e.x]!=m_lnd do
  e.x+=1
 end
 e.dx=rnd({-1,1})
 e.dy=rnd({-1,1})
 add(enl,e)
 m[e.y][e.x]=m_enl
end

function remove_enl()
 for e in all(enl) do
  m[e.y][e.x]=m_lnd
 end
 enl={}
end

function init_enemies()
 ens={}
 enl={}
 for i=1,num_ens do
  make_ens()
 end
 make_enl() 
end

function _init()
 init_map()
 init_player()
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
 hit=true
end

function process_hit()
 -- reset player
 remove_player()
 init_player()
 -- reset land enemies
 remove_enl()
 make_enl()
 -- remove the trail
 remove_trl()
 
 timer=timer_max
end

function move_player()
 local bg=p.in_sea and m_trl
  or m_lnd
 m[p.y][p.x]=bg
 p.x+=p.dx
 p.y+=p.dy
 m[p.y][p.x]=m_plr
end

function copy_map()
 local n={}
 for y=0,mh-1 do
  for x=0,mw-1 do
   n[y]=n[y] or {}
   n[y][x]=m[y][x]
  end
 end
 return n
end

function try_fill_(n,v)
 assert(n[v.y][v.x]==m_sea)
 n[v.y][v.x]=m_lnd
 for dir in all(dirs) do
  local w=v_add(v,dir)
  local x=n[w.y][w.x]
  if x==m_lnd then
   -- do nothing
  elseif x==m_sea then
   if not try_fill_(n,w) then
    return false
   end
  elseif x==m_plr then
   -- do nothing
  elseif x==m_ens then
   return false
  elseif x==m_enl then
   -- do nothing
  elseif x==m_trl then
   -- do nothing
  else
   assert(false)
  end
 end
 return true
end

function try_fill(v)
 local n=copy_map()
 if try_fill_(n,v) then
  m=n
  return true
 end
 return false
end

function fill_trl_(f)
 for y=2,mh-1-2 do
  for x=2,mw-1-2 do
   if m[y][x]==m_trl then
    m[y][x]=f
   end
  end
 end
end

function fill_trl()
 fill_trl_(m_lnd)
end

function remove_trl()
 fill_trl_(m_sea)
end

function get_lnd_count()
 local c=0
 for y=2,mh-1-2 do
  for x=2,mw-1-2 do
   local k=m[y][x]
   if k==m_lnd or
      k==m_enl or
      k==m_plr then
    c+=1
   end
  end
 end
 return c
end

function expand_land(v)
 local n1=get_lnd_count()
 for d in all(dirs) do
  local w=v_add(v,d)
  if m[w.y][w.x]==m_sea then
   if try_fill(w) then
    break
   end
  end
 end
 fill_trl()
 local n2=get_lnd_count()
 score+=(n2-n1)
end

function calc_full()
 local total=(mw-4)*(mh-4)
 local land=0
 for y=2,mh-3 do
  for x=2,mw-3 do
   if m[y][x]==m_lnd then
    land+=1
   end
  end
 end
 return flr((land/total)*100)
end

function update_player()
 local nx=p.x+p.dx
 local ny=p.y+p.dy
 local to=m[ny] and m[ny][nx]
 if p.in_sea then
  if to==m_lnd then
   local trl_end={x=p.x,y=p.y}
   move_player()
   p.in_sea=false
   expand_land(trl_end)
   full=calc_full()
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
  elseif to==m_ens or
         to==m_enl then
   hit_player()
  else
   assert(false)
  end
 end
end

function update_enl_h(e)
 if (hit) return
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
 if (hit) return
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
 if (hit) return
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
 if (hit) return
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

function update_timer()
 timer-=timer_spd
 if timer < 0 then
  timer+=timer_max
  make_enl()
 end
end

function update_game_over()
 if btn(❎) then
  run()
 end
end

function go_next_level()
 full=0
 num_ens+=1
 timer=timer_max

 init_map()
 init_player()
 init_enemies()
end

function update_game() 
 if full>=75 then
  go_next_level()
 end

 if hit then
  process_hit()
	
	 lives-=1 
	 if lives==0 then
	  is_game_over=true
	 else
   hit=false
	 end
 end

 handle_input()
 update_player()
 update_enemies()
 update_timer()
end

function _update()
 if is_game_over then
  update_game_over()
 else
  update_game()
 end
end

-->8
function draw_game_over()
 print("score:"..score.."\n\n"..
       "press ❎ to restart",
       0,
       10)
end

function draw_game()
 for y=0,mh-1 do
  for x=0,mw-1 do
   rectfill(x*2,y*2,
            x*2+1,y*2+1,
            colors[m[y][x]])
  end
 end
 color(7)
 print("score:"..score.." "..
       "xn:"..lives.." "..
       "full:"..full.."% "..
       "time:"..ceil(timer),
       0,
       128-5)
end

function _draw()
 cls()
 if is_game_over then
  draw_game_over()
 else
  draw_game()
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
