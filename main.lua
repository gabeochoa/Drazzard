function love.load()
	require 'entity'
	require 'wall'
	require 'block'
	require 'button'
	require 'item'
	require 'Room'

	love.graphics.setBackgroundColor(30, 25, 35)

	math.randomseed(os.time())
	-- global variables
	enemies_killed = 0
	debug = false
	translateX = 0
	translateY = 0
	tilesize = 32

	music_started = false

	current_room = nil

	gamestate = "mainmenu"
	isPaused = false
	score = 0

	-- initial class instances
	player = Entity.create("Me!", 100*tilesize, 100*tilesize)
	enemy = Entity.create("Enemy!", 300, 500)

	-- buttons
	main_menu_button = Button.create("<- Main Menu", "mainmenu", 10, 10)
	back_to_game_button = Button.create("<- Back to Game", "game", 10, 10)
	game_button = Button.create("Start", "game", love.graphics.getWidth()/2-100, love.graphics.getHeight()/2 + 25, true)
	how_to_play_button = Button.create("Controls", "howtoplay", love.graphics.getWidth()/2-100, love.graphics.getHeight()/2 + 25 + 75, true)
	credits_button = Button.create("Credits", "credits", love.graphics.getWidth()/2-100, love.graphics.getHeight()/2 + 25 + 75 + 75, true)

	-- items/perks
	items = { 
		Item.create("+ FOV", "eye", "FOV", 5, 100, 200),
		Item.create("+ Range", "range", "RANGE", 5, 375, 200),
		Item.create("+ Gold", "gold", "GOLD", 5, 650, 200),

		Item.create("+ Health", "health", "HEALTH", 99999, 100, 400),
		Item.create("+ Damage", "damage", "DAMAGE", 99999, 375, 400),
		Item.create("+ Stamina", "boots", "MANA", 99999, 650, 400)
	 }

	rooms = {}	
	halls = {}

	entities = { player }	
	--spawnEnemy(2)
	walls = {
		Wall.create("stone", 0, 0, 20, 1),
		Wall.create("stone", 0, 1, 1, 10),
		Wall.create("stone", 3, 3, 3, 1),
		Wall.create("stone", 3, 6, 7, 1),
		Wall.create("stone", 10, 4, 1, 8),

	}

	walls = {}
	
	blocks = {}
	notice = ""

	generateFloor()
	-- visuals
	main_logo = love.graphics.newImage("assets/sprites/GUI/mainlogos.png")
	
	-- stone tiles
	stone_tile = love.graphics.newImage("assets/sprites/tiles/stone_tile.png")
	stone_tile_alt = love.graphics.newImage("assets/sprites/tiles/stone_tile_alt.png")
	stone_tile_alt2 = love.graphics.newImage("assets/sprites/tiles/stone_tile_alt2.png")

	stone_tile_NW = love.graphics.newImage("assets/sprites/tiles/stone_tile_NW.png")
	stone_tile_NE = love.graphics.newImage("assets/sprites/tiles/stone_tile_NE.png")
	stone_tile_SW = love.graphics.newImage("assets/sprites/tiles/stone_tile_SW.png")
	stone_tile_SE = love.graphics.newImage("assets/sprites/tiles/stone_tile_SE.png")

	stone_tile_N = love.graphics.newImage("assets/sprites/tiles/stone_tile_N.png")
	stone_tile_E = love.graphics.newImage("assets/sprites/tiles/stone_tile_E.png")
	stone_tile_S = love.graphics.newImage("assets/sprites/tiles/stone_tile_S.png")
	stone_tile_W = love.graphics.newImage("assets/sprites/tiles/stone_tile_W.png")
	stone_tile_SIDE = love.graphics.newImage("assets/sprites/tiles/stone_tile_SIDE.png")
	stone_tile_SIDEalt = love.graphics.newImage("assets/sprites/tiles/stone_tile_SIDEalt.png")

	-- halls/bridges
	hall_tile = love.graphics.newImage("assets/sprites/tiles/hall_tile.png")
	hall_tile_H = love.graphics.newImage("assets/sprites/tiles/hall_tile_H.png")
	hall_tile_N = love.graphics.newImage("assets/sprites/tiles/hall_tile_N.png")
	hall_tile_S = love.graphics.newImage("assets/sprites/tiles/hall_tile_S.png")

	-- mist
	mist = love.graphics.newImage("assets/sprites/tiles/mist.png")





	canvas = love.graphics.newCanvas(500*tilesize, 500*tilesize)
	love.graphics.setCanvas(canvas)
		canvas:clear()
		for k,v in ipairs(walls) do
			for i=0,v.w/tilesize-1 do
		        for j=0,v.h/tilesize-1 do
		        	--love.graphics.draw(stone_tile, v.x + tilesize*i, v.y + tilesize*j)
		       	end
		   	end
		end

		for k,v in ipairs(rooms) do
			for i=0,(v.w-1)/tilesize do
		        for j=0,(v.h)/tilesize do
		        	if math.random() < .05 then
		        		if math.random() < .5 then
		        			love.graphics.draw(stone_tile_alt, v.x + tilesize*i, v.y + tilesize*j, 0)
		           		else
		        			love.graphics.draw(stone_tile_alt2, v.x + tilesize*i, v.y + tilesize*j, 0)
		           		end
		           	else
		        		love.graphics.draw(stone_tile, v.x + tilesize*i, v.y + tilesize*j, 0)
		           	end

		           	if i == 0 then
		        		love.graphics.draw(stone_tile_W, v.x + tilesize*i, v.y + tilesize*j, 0)
		        	elseif i == v.w/tilesize-1 then
		        		love.graphics.draw(stone_tile_E, v.x + tilesize*i, v.y + tilesize*j, 0)
		        	end

		        	if j == 0 then
		        		love.graphics.draw(stone_tile_N, v.x + tilesize*i, v.y + tilesize*j, 0)
		        	elseif j == v.h/tilesize-1 then
		        		love.graphics.draw(stone_tile_S, v.x + tilesize*i, v.y + tilesize*j, 0)
		        	elseif j == v.h/tilesize then
		        		love.graphics.draw(stone_tile_SIDEalt, v.x + tilesize*i, v.y + tilesize*j, 0)
		        	end

		        	if j == 0 and i == 0 then
		        		love.graphics.draw(stone_tile_NW, v.x + tilesize*i, v.y + tilesize*j, 0)
		        	elseif j == 0 and i == v.w/tilesize-1 then
		        		love.graphics.draw(stone_tile_NE, v.x + tilesize*i, v.y + tilesize*j, 0)
		        	end

		        	if j == v.h/tilesize-1 and i == 0 then
		        		love.graphics.draw(stone_tile_SW, v.x + tilesize*i, v.y + tilesize*j, 0)
		        	elseif j == v.h/tilesize-1 and i == v.w/tilesize-1 then
		        		love.graphics.draw(stone_tile_SE, v.x + tilesize*i, v.y + tilesize*j, 0)
		        	end
		        	--love.graphics.rectangle("line", v.x + tilesize*i, v.y + tilesize*j, 32, 32)
		       	end
		   	end
		end

		for k,v in ipairs(halls) do
			for i=0,v.w/tilesize-1 do
		        for j=0,v.h/tilesize-1 do
		        	if v.w > v.h then
		        		love.graphics.draw(hall_tile_H, v.x + tilesize*i, v.y + tilesize*j)
		        	else
		        		love.graphics.draw(hall_tile, v.x + tilesize*i, v.y + tilesize*j)
		        	end
		       	end
		   	end
		end


	love.graphics.setCanvas()

	-- font
	font = love.graphics.newFont("assets/misc/pf_tempesta_five.ttf", 14)
    love.graphics.setFont(font)

    -- audio
	do
	    -- will hold the currently playing sources
	    local sources = {}
	 
	    -- check for sources that finished playing and remove them
	    -- add to love.update
	    function love.audio.update()
	        local remove = {}
	        for _,s in pairs(sources) do
	            if s:isStopped() then
	                remove[#remove + 1] = s
	            end
	        end
	 
	        for i,s in ipairs(remove) do
	            sources[s] = nil
	        end
	    end
	 
	    -- overwrite love.audio.play to create and register source if needed
	    local play = love.audio.play
	    function love.audio.play(what, how, loop)
	        local src = what
	        if type(what) ~= "userdata" or not what:typeOf("Source") then
	            src = love.audio.newSource(what, how)
	            src:setLooping(loop or false)
	        end
	 
	        play(src)
	        sources[src] = src
	        return src
	    end
	 
	    -- stops a source
	    local stop = love.audio.stop
	    function love.audio.stop(src)
	        if not src then return end
	        stop(src)
	        sources[src] = nil
	    end
	end
	sword_sound = love.audio.newSource("assets/sounds/powerup.wav", "static")
end

function love.update(dt)
	if gamestate == "mainmenu" then
		buttons = { game_button, how_to_play_button, credits_button }
	elseif gamestate == "game" then

		if not music_started then
			--love.audio.play("assets/sounds/bg_music.mp3")
			--music_started = true
		end

		buttons = {  }
		if not isPaused then
			notice = ""
			checkKeys(dt)

			for k,v in ipairs(entities) do
				v:update(dt)
				if v ~= player and distance(v.x+v.w/2, v.y+v.h/2, player.x+player.w/2, player.y+player.h/2) < v.range then
					player.health = player.health - v.damage * dt
				end
			end
			for k,v in ipairs(halls) do
				v:update(dt)
			end
			for k,v in ipairs(rooms) do
				v:update(dt)
			end
			for k,v in ipairs(walls) do
				v:update(dt)
			end
			for k,v in ipairs(blocks) do
				v:update(dt)
			end
			for k,v in ipairs(buttons) do
				v:update(dt)
			end

		else
			notice = "PAUSED"
			if (player.health <= 0) then
				notice = "GAME OVER, BUB!\nHit 'R' to try again!"
			end
		end
	elseif gamestate == "shop" then
		buttons = { back_to_game_button }
	elseif gamestate == "howtoplay" then
		buttons = { main_menu_button }
	elseif gamestate == "credits" then
		buttons = { main_menu_button }
	end
end

function love.draw(dt)

	if gamestate == "mainmenu" then
		love.graphics.draw(main_logo, love.graphics.getWidth()/2 - 485)
	elseif gamestate == "game" then
		love.graphics.push()
		translateX = love.graphics.getWidth()/2-player.x-player.w/2
		translateY = love.graphics.getHeight()/2-player.y-player.h/2
		love.graphics.translate(translateX, translateY)
		-----------------------------------
		love.graphics.draw(canvas)

		local angle = math.atan2((love.mouse.getY()-translateY - (player.y+player.h/2)), (love.mouse.getX()-translateX - (player.x+player.w/2)))
		love.graphics.setColor(255, 255, 255, 60)
		love.graphics.arc("line", player.x+player.w/2, player.y+player.h/2, player.range, angle-player.fov, angle+player.fov)
		love.graphics.setColor(255, 255, 255, 255)

		for k,v in ipairs(entities) do
			v:draw(dt)
			local mouse_angle = math.atan2((love.mouse.getY()-translateY - (player.y+player.h/2)), (love.mouse.getX()-translateX - (player.x+player.w/2)))
			local entity_angle = math.atan2( (v.y+v.h/2) - (player.y+player.h/2), (v.x+v.w/2) - (player.x+player.w/2))
			if v ~= player and distance(player.x+player.w/2, player.y+player.h/2, v.x+v.w/2, v.y+v.h/2) < player.range and math.abs(mouse_angle-entity_angle) < player.fov then
				--love.graphics.setColor(255, 100, 100, 255)
				--love.graphics.arc("fill", player.x+player.w/2, player.y+player.h/2, player.range, entity_angle-.01, entity_angle+.01)
				--love.graphics.setColor(255, 255, 255, 255)
			end
		end
		for k,v in ipairs(halls) do
			v:draw(dt)
		end	
		for k,v in ipairs(rooms) do
			v:draw(dt)
		end
		for k,v in ipairs(walls) do
			v:draw(dt)
		end
		for k,v in ipairs(blocks) do
			v:draw(dt)
		end
		-- GUI
		love.graphics.circle("line", 0,0,5)
		love.graphics.circle("line", love.mouse.getX()-translateX, love.mouse.getY()-translateY, 5)
		--love.graphics.line(player.x+player.w/2, player.y+player.h/2, love.mouse.getX()-translateX, love.mouse.getY()-translateY)

		-- DEBUG
		love.graphics.pop()

		-- GUI
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle("fill", 10, 10, player.health * (100/player.total_health), 10)
		love.graphics.setColor(0, 200, 200)
		love.graphics.rectangle("fill", 10, 25, player.mana * (100/player.total_mana), 10)
		love.graphics.setColor(255, 255, 255)
		
		love.graphics.print("Score: "..score, 10, 40)
		love.graphics.print("Gold: "..player.gold, 10, 55)
		love.graphics.print("enemies_killed: "..enemies_killed, 700, 60)
		
		if debug then
			love.graphics.print("Entities: "..#entities, 800, 30)
			love.graphics.print("Actual:"..math.floor(love.mouse.getX()-translateX)..","..math.floor(love.mouse.getY()-translateY), love.mouse.getX() + 15, love.mouse.getY()-15)
			love.graphics.print("Screen:"..love.mouse.getX()..","..love.mouse.getY(), love.mouse.getX() + 15, love.mouse.getY())
		end
	elseif gamestate == "shop" then

		love.graphics.printf("Welcome to the shop!", 0, 25, love.graphics.getWidth(), 'center')
		love.graphics.printf("Gold: "..player.gold, 0, 40, love.graphics.getWidth(), 'center')

		for k,v in ipairs(items) do
			v:draw(dt)
		end

	elseif gamestate == "howtoplay" then

		love.graphics.printf("How To Play", 0, 25, love.graphics.getWidth(), 'center')

		love.graphics.printf("WASD ... Move", 0, 150, love.graphics.getWidth(), 'center')
		love.graphics.printf("Shift ... Sprint", 0, 175, love.graphics.getWidth(), 'center')
		love.graphics.printf("Left Click ... Sword Attack", 0, 200, love.graphics.getWidth(), 'center')
		love.graphics.printf("Escape ... Shop/Pause", 0, 200, love.graphics.getWidth(), 'center')



	elseif gamestate == "credits" then

		love.graphics.printf("Credits", 0, 25, love.graphics.getWidth(), "center")

		love.graphics.printf("--[ Code & Title Art ]--", 0, 90, love.graphics.getWidth(), "center")
		love.graphics.printf("Simeon Videnov", 0, 120, love.graphics.getWidth(), "center")
		love.graphics.printf("(http://simeon.io)", 0, 140, love.graphics.getWidth(), "center")

		love.graphics.printf("--[ Sprites ]--", 0, 170, 450, "center")		
		love.graphics.printf("Buch\n(http://opengameart.org/users/buch)", 0, 200, 400, "center")

		love.graphics.printf("--[ Music ]--", 450, 170, 400, "center")
		love.graphics.printf("Rolemusic - 'Besos y Abrazos'\n(http://freemusicarchive.org/music/Rolemusic/) ", 450, 200, 400, "center")

		love.graphics.printf("-- Font --", 0, 350, love.graphics.getWidth(), "center")
		love.graphics.printf("Yusuke Kamiyamane - 'PF Tempesta Five'", 0, 370, love.graphics.getWidth(), "center")
		love.graphics.printf("(http://p.yusukekamiyamane.com/)", 0, 390, love.graphics.getWidth(), "center")

		love.graphics.printf("-- Tools --", 0, 450, love.graphics.getWidth(), "center")
		love.graphics.printf("Made with Lua and Love2D framework", 0, 470, love.graphics.getWidth(), "center")
		love.graphics.printf("(http://lua.org & http://love2d.org)", 0, 490, love.graphics.getWidth(), "center")

	elseif gamestate == "gameover" then

		love.graphics.printf("-- Game Over --", 0, 150, love.graphics.getWidth(), "center")
		love.graphics.printf("(You tried your best)", 0, 170, love.graphics.getWidth(), "center")

		love.graphics.printf("Score: "..score, 0, 220, love.graphics.getWidth(), "center")
		love.graphics.printf("Gold: "..player.gold, 0, 240, love.graphics.getWidth(), "center")
		love.graphics.printf("Enemies slain: "..enemies_killed, 0, 260, love.graphics.getWidth(), "center")

		love.graphics.printf("Press 'R' to restart", 0, 320, love.graphics.getWidth(), "center")

	
	end

	for k,v in ipairs(buttons) do
		v:draw(dt)
	end

	love.graphics.print("FPS: "..love.timer.getFPS(), 700, 0)
	love.graphics.print("gamestate: "..gamestate, 700, 15)
	love.graphics.print("#rooms: "..#rooms, 700, 30)
	love.graphics.printf(notice, 0, 10, love.graphics.getWidth(), 'center')

end

function love.mousepressed(x, y, button)

	if button == 'l' then

		if gamestate == "mainmenu" or gamestate == "credits"then
			for k,v in ipairs(buttons) do
				if checkCollision(v.x, v.y, v.w, v.h, love.mouse.getX(), love.mouse.getY(), 1, 1) then
					gamestate = v.path
				end
			end
		elseif gamestate == "game" then
			if player.mana >= 5 and not isPaused then
				for k,v in ipairs(entities) do
					local mouse_angle = math.atan2((love.mouse.getY()-translateY - (player.y+player.h/2)), (love.mouse.getX()-translateX - (player.x+player.w/2)))
					local entity_angle = math.atan2( (v.y+v.h/2) - (player.y+player.h/2), (v.x+v.w/2) - (player.x+player.w/2))
					if v ~= player then
						if distance(v.x+v.w/2, v.y+v.h/2, player.x+player.w/2, player.y+player.h/2) < player.range and math.abs(mouse_angle-entity_angle) < player.fov then
							v.health = v.health - player.damage
							love.audio.play("assets/sounds/sword_hit.wav")
						else
							love.audio.play("assets/sounds/sword_swing.wav")
						end
					end
				end
			end
		elseif gamestate == "howtoplay" then
			for k,v in ipairs(buttons) do
				if checkCollision(v.x, v.y, v.w, v.h, love.mouse.getX(), love.mouse.getY(), 1, 1) then
					gamestate = v.path
					if isPaused then isPaused = not isPaused end
				end
			end	
		elseif gamestate == "shop" then
			for k,v in ipairs(buttons) do
				if checkCollision(v.x, v.y, v.w, v.h, love.mouse.getX(), love.mouse.getY(), 1, 1) then
					gamestate = v.path
					if isPaused then isPaused = not isPaused end
				end
			end	

			for k,v in ipairs(items) do
				if checkCollision(v.x, v.y, v.w, v.h, love.mouse.getX(), love.mouse.getY(), 1, 1) then
					if player.gold >= v.cost and v.level < v.max_level then
						player.gold = player.gold - v.cost
						v.level = v.level + 1
						if v.var == "FOV" then
							player.fov = player.fov + .3
							v.cost = v.cost + 50
						elseif v.var == "RANGE" then
							player.range = player.range + 20
							v.cost = v.cost + 50
						elseif v.var == "DAMAGE" then
							player.damage = player.damage * 2
							v.cost = v.cost + 300
						elseif v.var == "HEALTH" then
							player.total_health = player.total_health * 1.3
							player.health = player.total_health
							player.regen = player.regen + 5
							v.cost = v.cost + 300
						elseif v.var == "MANA" then
							player.total_mana = player.total_mana * 1.3
							player.mana = player.total_mana
							v.cost = v.cost + 300
						elseif v.var == "GOLD" then
							player.gold_boost = player.gold_boost + .5
							v.cost = v.cost + 300
						end
					else
						notice = "Not enough gold!"
					end
				end
			end	
		end
	end

	if button == 'r' and player.mana >= 50 and not isPaused then
   		player.x = love.mouse.getX() - translateX
   		player.y = love.mouse.getY() - translateY
   		player.mana = player.mana - (distance(player.xScreen+player.w/2, player.yScreen+player.h/2, love.mouse.getX(), love.mouse.getY())/10)
    end
end

function love.mousereleased(x, y, button)
   if button == 'l' then
   end
end

function love.keypressed(key)
	if key == 'escape' and player.health > 0 and gamestate ~= "mainmenu" then
		isPaused = not isPaused
		if gamestate == "game" then gamestate = "shop" elseif gamestate == "shop" then gamestate = "game" end
	end

	if key == 'r' and player.health <= 0 then 
		love.load()
		gamestate = "game"
	end

	if key == '1' then
		table.insert(entities, Entity.create("Enemy!", math.random(0, 500), math.random(0, 500)))
	end

	if key == '2' then
		debug = not debug
	end

	if key == '3' then
		generateHalls()
	end

	if key == '4' then
		generateFloor()
	end
end

function love.keyreleased(key)

end

function love.focus(f)
  if not f then
    print("LOST FOCUS")
  else
    print("GAINED FOCUS")
  end
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end


function mouseHoversOver(thing)
	mX = love.mouse.getX()
	mY = love.mouse.getY()

	return mX > thing.x and
			mX < thing.x + thing.w and
			mY > thing.y and
			mY < thing.y + thing.h
end

function checkKeys(dt)
	local speed = 100
	player.dx = 0
	player.dy = 0
	player.sprinting = false
	if love.keyboard.isDown("lshift") and player.mana > 0 then 
		player.sprinting = true
		speed = 150
	end
	if love.keyboard.isDown("d") and player:canMove("right") and not player:collidingRight() then
		player.dx = speed
	end
	if love.keyboard.isDown("a") and player:canMove("left") and not player:collidingLeft() then
		player.dx = -speed
	end
	if love.keyboard.isDown("s") and player:canMove("bottom") and not player:collidingBottom() then
		player.dy = speed
	end
	if love.keyboard.isDown("w") and player:canMove("top") and not player:collidingTop() then
		player.dy = -speed
	end
end

function spawnEnemy(num, xPos, yPos)
	local x = xPos or 200
	local y = yPos or tilesize
	for i=1,num do
		table.insert(entities, Entity.create("Enemy!", x, y))
	end
end


function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function contains(list, value)
	for k,v in ipairs(list) do
		if v == value then
			return true
		else
			return false
		end
	end
end


function generateMap()
	-- relative points
	local x = 100
	local y = 100
	-- center
	rooms = {
		Room.create("stone", "room", x, y, 11, 11),
		Room.create("stone", "room", x+4, y+3, 3, 3)
	}
end

function generateFloor()
	rooms = {}
	halls = {}
	-- generates grid of rooms
	for i=1, 10 do
		for j=1, 10 do
			local w = math.random(5, 8)
			local h = math.random(5, 8)
			local r = Room.create("stone", "room", i*10-w/2, j*10-h/2, w, h)
			table.insert(rooms, r)
		end
	end
	generateHalls()
end

function generateHalls()

	for k,v in ipairs(rooms) do
		num = math.random()
		if num < .25 then -- left
			local h = Room.create("stone", "hall", (v.x)/tilesize-4, (v.y+v.h/2)/tilesize-1, 4, 1)
			table.insert(halls, h)
		elseif num < .5 then -- right
			local h = Room.create("stone", "hall", (v.x+v.w)/tilesize, (v.y+v.h/2)/tilesize-1, 4, 1)
			table.insert(halls, h)
		elseif num < .75 then -- top
			local h = Room.create("stone", "hall", (v.x+v.w/2)/tilesize-1, (v.y)/tilesize-4, 1, 4)
			table.insert(halls, h)
		elseif num < 1 then -- bottom
			local h = Room.create("stone", "hall", (v.x+v.w/2)/tilesize-1, (v.y+v.h)/tilesize, 1, 4)
			table.insert(halls, h)
		end	
	end


	-- generates halls for rooms
	--[[for i=1,2 do
		for k,v in ipairs(rooms) do
			num = math.random()
			if num < .25 then -- left
				local h = Room.create("stone", "hall", (v.x)/tilesize-4, (v.y+v.h/2)/tilesize-1, 4, 1)
				table.insert(halls, h)
			elseif num < .5 then -- right
				local h = Room.create("stone", "hall", (v.x+v.w)/tilesize, (v.y+v.h/2)/tilesize-1, 4, 1)
				table.insert(halls, h)
			elseif num < .75 then -- top
				local h = Room.create("stone", "hall", (v.x+v.w/2)/tilesize-1, (v.y)/tilesize-4, 1, 4)
				table.insert(halls, h)
			elseif num < 1 then -- bottom
				local h = Room.create("stone", "hall", (v.x+v.w/2)/tilesize-1, (v.y+v.h)/tilesize, 1, 4)
				table.insert(halls, h)
			end
		end
	end

	-- removes halls at edges
	for k,v in ipairs(halls) do
		for i,j in ipairs(rooms) do
			if checkCollision(v.x, v.y, v.w, v.h, j.x, j.y, j.w, j.h) then
				v.status = "old"
			end
		end
	end]]
end

function distance(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end

