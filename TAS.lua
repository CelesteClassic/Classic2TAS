local TAS={}

--[[local function draw_time(x,y)
	if pico8.cart.time_ticking or (pico8.cart.level_index()<30 and pico8.cart.time_ticking==nil) then 
		pico8.cart.centiseconds=math.floor(100*pico8.cart.frames/30)
	end
	if TAS.showdebug and TAS.final_reproduce then
		local cs=pico8.cart.centiseconds
		local s=pico8.cart.seconds
		local m=pico8.cart.minutes
		--local h=math.floor(pico8.cart.minutes/60)

		pico8.cart.rectfill(x,y,x+32,y+6,0)
		pico8.cart.print((m<10 and "0"..m or m)..":"..(s<10 and "0"..s or s).."."..(cs<10 and "0"..cs or cs),x+1,y+1,7)
	end
end]]--

-- this is a comment
local function empty() 
end

local function clone(org,dst,seen)
	for i,o in pairs(org) do
		if type(o)=="table" and i~="type" then 
			dst[i]={}
			clone(o,dst[i],seen)
		elseif type(o)~="function" then
			dst[i]=o  
		end
	end
end
local function clone_function(fn)
  local dumped = string.dump(fn)
  local cloned = loadstring(dumped)
  local i = 1
  while true do
    local name = debug.getupvalue(fn, i)
    if not name then
      break
    end
    debug.upvaluejoin(cloned, i, fn, i)
    i = i + 1
  end
  setfenv(cloned,getfenv(fn))
  return cloned
end
local function get_state()
	local state={}
	local state_flag={}
	--[[
	state_flag.state_practice_time=TAS.practice_time
	state_flag.got_fruit=pico8.cart.got_fruit[pico8.cart.level_index+1]
	state_flag.has_dashed=pico8.cart.has_dashed
	state_flag.frames=pico8.cart.frames
	state_flag.seconds=pico8.cart.seconds
	state_flag.minutes=pico8.cart.minutes
	state_flag.has_key=pico8.cart.has_key
	state_flag.new_bg=pico8.cart.new_bg
	state_flag.flash_bg=pico8.cart.flash_bg
	state_flag.pause_player=pico8.cart.pause_player
	state_flag.max_djump=pico8.cart.max_djump
	state_flag.practice_timing=TAS.practice_timing
	state_flag.will_restart=pico8.cart.will_restart
	state_flag.delay_restart=pico8.cart.delay_restart
	state_flag.start=TAS.start
	state_flag.practice_timing=TAS.practice_timing
	state_flag.show_keys=TAS.show_keys
	state_flag.freeze=pico8.cart.freeze
	local objects=pico8.cart.objects
	for i,o in pairs(objects) do
		local s={}
		clone(o,s)
		table.insert(state,s)
			
	end
	]]
	return state, state_flag
end
TAS.get_state=get_state

local function set_state(state, state_flag)
	pico8.cart.got_fruit[pico8.cart.level_index()+1]=state_flag.got_fruit
	pico8.cart.has_dashed=state_flag.has_dashed
	pico8.cart.frames=state_flag.frames
	pico8.cart.seconds=state_flag.seconds
	pico8.cart.minutes=state_flag.minutes
	pico8.cart.has_key=state_flag.has_key
	pico8.cart.new_bg=state_flag.new_bg
	pico8.cart.flash_bg=state_flag.flash_bg
	pico8.cart.pause_player=state_flag.pause_player
	pico8.cart.max_djump=state_flag.max_djump
	pico8.cart.will_restart=state_flag.will_restart
	pico8.cart.delay_restart=state_flag.delay_restart
	TAS.practice_timing=state_flag.practice_timing
	TAS.show_keys=state_flag.show_keys
	pico8.cart.freeze=state_flag.freeze
	pico8.cart.objects={}
	for i,o in pairs(state) do
		local e = pico8.cart.init_object(o.type,o.x,o.y)
		clone(o,e)
	end
	TAS.start=state_flag.start
end
TAS.set_state=set_state


local function update()
	if TAS.advance_frame then
		TAS.advance_frame=false

		local seen_player=false
		for _,o in pairs(pico8.cart.objects) do
			if o.base==pico8.cart.player then 
				seen_player=true
			end
		end
		if seen_player and not TAS.active then 
			TAS.active=true
			TAS.frame=0
		elseif not seen_player then 
			TAS.active=false 
		end 
		
		if TAS.active then 
			TAS.frame=TAS.frame+1
		end 
		if TAS.prev_state.level_index~=-1 and TAS.prev_state.level_index~=pico8.cart.level_index then
			if TAS.save_reproduce then 
				if not TAS.final_reproduce then 
					TAS.save_reproduce=false
					TAS.reproduce=false
				end 
				TAS.save_file(true,TAS.frame)
				log("Saved cleaned file to "..love.filesystem.getRealDirectory(""))
			end 

			if not TAS.final_reproduce then
				TAS.active=false
				load_level(TAS.prev_state.level_index)
			else
				local numFrames=TAS.frame
				TAS.load_file(love.filesystem.newFile(("TAS/TAS%d.tas"):format(pico8.cart.level_index)))
				TAS.reproduce=true
				log(("%02d:%02d:%02d (%d)"):format(pico8.cart.minutes,pico8.cart.seconds,round(100*pico8.cart.frames/30)),TAS.frame)
			end
		end
		
		if not TAS.keypresses[TAS.frame+1] then
			TAS.keypresses[TAS.frame+1]={}
		end
	end 
	if TAS.reproduce then
		TAS.advance_frame=true
		local state, state_flag=get_state()
		TAS.states[TAS.current_frame]=state
		TAS.states_flags[TAS.current_frame]=state_flag
	end
	TAS.prev_state.level_index=pico8.cart.level_index
end
TAS.update=update

local function draw()
	if TAS.showdebug and not TAS.final_reproduce then
		--pico8.cart.camera(0,0)
		love.graphics.push()
		love.graphics.origin()
		pico8.cart.rectfill(1,1,13,7,0)
		pico8.cart.print(tostring(TAS.frame),2,2,7)
		local inputs_x=15
		pico8.cart.rectfill(inputs_x,1,inputs_x+24,11,0)
		if TAS.active then
			pico8.cart.rectfill(inputs_x + 12, 7, inputs_x + 14, 9, TAS.keypresses[TAS.frame][0] and 7 or 1) -- l
			pico8.cart.rectfill(inputs_x + 20, 7, inputs_x + 22, 9, TAS.keypresses[TAS.frame][1] and 7 or 1) -- r
			pico8.cart.rectfill(inputs_x + 16, 3, inputs_x + 18, 5, TAS.keypresses[TAS.frame][2] and 7 or 1) -- u
			pico8.cart.rectfill(inputs_x + 16, 7, inputs_x + 18, 9, TAS.keypresses[TAS.frame][3] and 7 or 1) -- d
			pico8.cart.rectfill(inputs_x + 2, 7, inputs_x + 4, 9, TAS.keypresses[TAS.frame][4] and 7 or 1) -- z
			pico8.cart.rectfill(inputs_x + 6, 7, inputs_x + 8, 9, TAS.keypresses[TAS.frame][5] and 7 or 1) -- x
		end
	end
	love.graphics.pop()
end
TAS.draw=draw

local function save_file(compress,idx)
	local file=love.filesystem.newFile("TAS"..tostring(TAS.prev_state.level_index)..".tas")

	file:open("w")
	local finish
	if(compress) then 
		finish=idx 
	else
		finish=#TAS.keypresses
	end
	for j=0,finish do
		local i=TAS.keypresses[j]
		local line=0
		for x=0,5 do
			if i[x] then
				if x==0 then
					line=line+1
				elseif x==1 then
					line=line+2
				elseif x==2 then
					line=line+4
				elseif x==3 then
					line=line+8
				elseif x==4 then
					line=line+16
				else
					line=line+32
				end
			end
		end
		file:write(tostring(line)..",")
	end
	file:close()
end
TAS.save_file=save_file

local function clear_pico8()
	pico8.cart.frames=0
	pico8.cart.seconds=0
	pico8.cart.minutes=0
	pico8.cart.deaths=0
	pico8.collected={}
end 

local function clear_state()
	TAS.states={}
	TAS.state_flags={}
	TAS.keypresses={}
	TAS.keypresses[0]={}
	TAS.frame=0
	TAS.prev_state={level_index=-1,deaths=pico8.cart.deaths}
	TAS.active=false
	TAS.save_reproduce=false
	TAS.reproduce=false
end
function load_level(idx)
	
	TAS.frame=0
	TAS.states={}
	TAS.states_flags={}
	if not TAS.final_reproduce then 
		pico8.collected={}
		pico8.cart.goto_level(idx)
	end 
end

local function load_file(file)
	TAS.keypresses={}
	local data=file:read()
	if data~=nil then
		local iterator=0
		for s in x:gmatch("([^,]+)") do
			TAS.keypresses[iterator]={}
			local c=tonumber(s)
			for i=0,5 do
				if math.floor(c/math.pow(2,i))%2==1 then
					TAS.keypresses[iterator][i]=true
				end
			end
			iterator=iterator+1
		end
	end
	TAS.reproduce=false
	TAS.save_reproduce=false
	TAS.advance_frame=false
	load_level(pico8.cart.level_index)
end
TAS.load_file=load_file
local function keypress(key)
	if key=='p' then
		TAS.reproduce=not TAS.reproduce
		TAS.save_reproduce=false
	elseif key=='e' then
		TAS.showdebug=not TAS.showdebug
	elseif key=='n' or key=='i' then
		TAS.final_reproduce=not TAS.final_reproduce
		if TAS.final_reproduce then
			clear_pico8()
			clear_state()
			pico8.cart.goto_level(1)
			TAS.load_file(love.filesystem.newFile("TAS/TAS1.tas"))
		end
		TAS.reproduce=TAS.final_reproduce
		TAS.save_reproduce=key=='i' and TAS.final_reproduce
	elseif key=='y' then
		for _,o in pairs(pico8.cart.objects) do
			if o.base==pico8.cart.player then
				log("----------------------------------")
				log("position: "..tostring(o.x)..", "..tostring(o.y))
				log("rem values: "..tostring(o.remainder_x)..", "..tostring(o.remainder_y))
				log("speed: "..tostring(o.speed_x)..", "..tostring(o.speed_y))
			end
		end
	end 
	if not TAS.final_reproduce then 
		if key=='f' or key=='s' or key=='r' then
			clear_state()
			local off=key=='f' and 1 or key=='s' and -1 or 0
			local new_idx=math.min(math.max(pico8.cart.level_index+off,1),8)
			load_level(new_idx)
		elseif key=='d' then
			TAS.reproduce=false
			TAS.save_reproduce=false
			load_level(pico8.cart.level_index)
		elseif key=='l' then
			TAS.advance_frame=true
			local state, state_flag=get_state()
			TAS.states[TAS.frame]=state
			TAS.states_flags[TAS.frame]=state_flag
		elseif key=='k' then
			if TAS.frame>0 then
				TAS.frame=TAS.frame-1
				set_state(TAS.states[TAS.frame], TAS.states_flags[TAS.frame])
			end
		elseif key=='up' then
			TAS.keypresses[TAS.frame][2]=not TAS.keypresses[TAS.frame][2]
		elseif key=='down' then
			TAS.keypresses[TAS.frame][3]=not TAS.keypresses[TAS.frame][3]
		elseif key=='left' then
			TAS.keypresses[TAS.frame][0]=not TAS.keypresses[TAS.frame][0]
		elseif key=='right' then
			TAS.keypresses[TAS.frame][1]=not TAS.keypresses[TAS.frame][1]
		elseif key=='c' or key=='z' then
			TAS.keypresses[TAS.frame][4]=not TAS.keypresses[TAS.frame][4]
		elseif key=='x' then
			TAS.keypresses[TAS.frame][5]=not TAS.keypresses[TAS.frame][5]
		elseif key=='m' then
			TAS.save_file(false)
			log("Saved file to "..love.filesystem.getRealDirectory(""))
		elseif key=='u' then 
			TAS.save_file(false)
			log("Saved uncleaned file to "..love.filesystem.getRealDirectory(""))
			TAS.reproduce=true 
			TAS.save_reproduce=true
		elseif key=='w' then 
			TAS.load_file(love.filesystem.newFile("TAS/TAS"..(pico8.cart.level_index)..".tas"))
		end
	end 
end
TAS.keypress=keypress

local function init() 
	--setfenv(draw_time,pico8.cart)
	--pico8.cart.draw_time=draw_time
	--[[local draw_orb=clone_function(pico8.cart.orb.draw)
	local draw_chest=clone_function(pico8.cart.big_chest.draw)
	local draw_time=clone_function(pico8.cart.draw_time)]]--
	
	if pico8.cart.draw_time~=nil then
		local draw_time=pico8.cart.draw_time
		pico8.cart.draw_time=function(...)
			local arg={...}
			if TAS.final_reproduce or pico8.cart.level_index==8 then 
				if arg[1]~=4 or arg[2]~=4 then --?
					draw_time(...)
				end
			end 
		end
	end
	local _draw=pico8.cart._draw
	pico8.cart._draw=function() 
		_draw()
		if pico8.cart.level_index<8 then
			pico8.cart.draw_time(1,1,7)
		end
	end
	load_level(1)
end
TAS.init=init
local function restart()
	TAS.frames=0
	TAS.advance_frame=false
	TAS.keypresses={}
	TAS.keypresses[1]={}
	TAS.states={}
	TAS.states_flags={}
	TAS.current_frame=0
	TAS.showdebug=true
	TAS.reproduce=false
	TAS.final_reproduce=false
	TAS.save_reproduce=false
	TAS.start=false
	TAS.prev_state={level_index=-1}
end
TAS.restart=restart
restart()
return TAS