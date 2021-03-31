Class = require 'class'
require 'Bird'
require 'Pipe'
anim8 = require 'anim8'

WINDOW_WIDTH = 1080 
WINDOW_HEIGHT = 576
max_FPS = 60

background = love.graphics.newImage('/Graphics/F_BIRD_BG(Long).png')


background_scroll = 0
LOOPING_POINT = 1733
SCROLL_SPEEDS = {0, 100}
for i = 3, 50 do
	SCROLL_SPEEDS[i] = SCROLL_SPEEDS[i-1]*1.1
end

GRAVITY = 15
JUMP_HEIGHT = 5.7


PIPE_X_GAP = 300
PIPE_PAIR_GAP = 750


SCORE = 0

game_state = 'start'


function love.load()

	min_dt = 1/max_FPS
    next_time = love.timer.getTime()
	love.graphics.setDefaultFilter('nearest', 'nearest')

	jump_anim_img = love.graphics.newImage('/Graphics/F_BIRD_2(Anim).png')
	-- jump_anim_img = love.graphics.newImage('/Graphics/ANIM(2).png')
	grid = anim8.newGrid(46, 44, jump_anim_img:getWidth(), jump_anim_img:getHeight())
	jump_anim = anim8.newAnimation(grid(1,1, 2,1, 3,1), 0.125)
	-- grid = anim8.newGrid(46, 51, jump_anim_img:getWidth(), jump_anim_img:getHeight())
	-- jump_anim = anim8.newAnimation(grid(1,1, 2,1), 2)

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = true,
		vsync = false
		})

	love.window.setTitle('Flappy Bird')

	math.randomseed(os.time())
	random_loc = math.random(WINDOW_HEIGHT*0.4,WINDOW_HEIGHT*0.95)

	large_font = love.graphics.setNewFont('/Graphics/flappy.ttf', 72)
 	medium_font = love.graphics.setNewFont('/Graphics/flappy.ttf', 48)
	
	jump_sound = love.audio.newSource('/Graphics/F_BIRD_JUMP.ogg', 'static')
	-- jump_sound = love.audio.newSource('/Graphics/JUMP_2.wav', 'static')
	collide_sound = love.audio.newSource('/Graphics/F_BIRD_GO.ogg', 'static')
	-- GO_sound = love.audio.newSource('/Graphics/GO_2.wav', 'static')	
	score_sound = love.audio.newSource('/Graphics/F_BIRD_SCORE.wav', 'static')

	bg_music = love.audio.newSource( '/Graphics/Flappy Bird Theme Song.ogg', 'static' )
	bg_music:setLooping(true)
	bg_music:setVolume(0.1)
	bg_music:play()

	pipes = {Pipe(WINDOW_WIDTH*0.5, 
		random_loc,
		'/Graphics/F_BIRD_PIPEUP.png'),}

	first_pipe_pair = Pipe(pipes[1].x, pipes[1].y - PIPE_PAIR_GAP, '/Graphics/F_BIRD_PIPEDOWN.png')
	first_pipe_pair.scored = true 

	table.insert(pipes, first_pipe_pair)

	player = Bird(WINDOW_WIDTH*0.05, WINDOW_HEIGHT/2)

	love.keyboard.keysPressed = {}


end





function love.draw()

	
	love.graphics.setColor(255, 255, 255, 255)

	if game_state == 'start' then 
		SCORE = 0
		player:reset(WINDOW_WIDTH*0.05, WINDOW_HEIGHT/2)
		GRAVITY = 0
		SCROLL_SPEED = SCROLL_SPEEDS[1]
		love.graphics.draw(background, -background_scroll, 0)
		jump_anim:gotoFrame(1)
		jump_anim:draw(jump_anim_img, player.x, player.y)

		for index, value in pairs(pipes) do 
			value:draw()
		end

		love.graphics.setFont(medium_font)
		love.graphics.printf('PRESS SPACE TO JUMP!', 0, WINDOW_HEIGHT/2, WINDOW_WIDTH, 'center')
	end

	if game_state == 'play' then 

		love.graphics.draw(background, -background_scroll, 0)
		
		if player.dy < 0 then
			jump_anim:draw(jump_anim_img, player.x, player.y)
			-- jump_anim:pauseAtEnd()
			-- jump_anim:gotoFrame(1)
		else

			jump_anim:gotoFrame(2)
			jump_anim:draw(jump_anim_img, player.x, player.y)
		end
		

		for index, value in pairs(pipes) do 
			value:draw()
		end
	end

	if game_state == 'game_over' then 
		love.graphics.draw(background, -background_scroll, 0)
		jump_anim:pause()
		jump_anim:draw(jump_anim_img, player.x, player.y)
		for index, value in pairs(pipes) do 
			value:draw()
		end
		love.graphics.setFont(large_font)
		love.graphics.printf('GAME OVER', 0, WINDOW_HEIGHT*0.4, WINDOW_WIDTH, 'center')

		love.graphics.setFont(medium_font)
		love.graphics.printf('PRESS ENTER TO REPLAY!', 0, WINDOW_HEIGHT*0.6, WINDOW_WIDTH, 'center')
	end

	show_score()
	displayFPS()

	local cur_time = love.timer.getTime()
    if next_time <= cur_time then
      next_time = cur_time
      return
    end

    love.timer.sleep(next_time - cur_time)


end





function love.update(dt)


	jump_anim:update(dt)
	player:update(dt)

	if game_state == 'start' then 
		SCROLL_SPEED = SCROLL_SPEEDS[1]
	end

	if game_state == 'play' then 
		if SCORE == 0 then 
			SCROLL_SPEED = SCROLL_SPEEDS[2]
		elseif SCORE % 5 == 0 then 
			SCROLL_SPEED = SCROLL_SPEEDS[SCORE/5 + 2]
		end
	end

	background_scroll = background_scroll + SCROLL_SPEED*dt

	if background_scroll >= LOOPING_POINT then 
		background_scroll = 0
	end

	
	
	for key, value in pairs(pipes) do 
		if value.x < -value.width then 
			table.remove(pipes, key)
		end
	end

	for key, value in pairs(pipes) do 
		if not value.scored then 
			if value.x + value.width < player.x  then 
				value.scored = true
				SCORE = SCORE + 1
				love.audio.play(score_sound)
			end
		end
	end

	while #pipes < 8 do 

		-- math.randomseed(os.time())
		random_loc = math.random(WINDOW_HEIGHT*0.4,WINDOW_HEIGHT*0.9)

		new_pipe = Pipe(pipes[#pipes].x + PIPE_X_GAP, 
			random_loc, 
			'/Graphics/F_BIRD_PIPEUP.png')

		pipe_pair = Pipe(new_pipe.x, new_pipe.y - PIPE_PAIR_GAP,'/Graphics/F_BIRD_PIPEDOWN.png')
		pipe_pair.scored = true

		table.insert(pipes, new_pipe)
		table.insert(pipes, pipe_pair)
	end

	for index, value in pairs(pipes) do 
		value:move(dt)
	end

	if game_state == 'play' then
		for i = 1, #pipes do 
			if player:is_collided_with(pipes[i]) then 
				-- to_jump = false 
				SCROLL_SPEED = SCROLL_SPEEDS[1]
				game_state = 'game_over'
				love.audio.play(collide_sound)
				-- love.audio.play(GO_sound)
			end
		end

		if player.y > WINDOW_HEIGHT + player.height then
			SCROLL_SPEED = SCROLL_SPEEDS[1]
			game_state = 'game_over'
			-- love.audio.play(GO_sound)
		end
	end

	love.keyboard.keysPressed = {}

	next_time = next_time + min_dt
end

function love.keyboard.wasPressed(key)
	if love.keyboard.keysPressed[key] then 
		return true
	else
		return false
	end
end

function love.keypressed(key)
	love.keyboard.keysPressed[key] = true

	if key == 'escape' then 
		love.event.quit()
	end

	if key == 'space' then 

		if game_state == 'start' then 
			game_state = 'play'
			GRAVITY = 15
		end

	end

	if key == 'return' then 
		if game_state == 'game_over' then 

			game_state = 'start'

			jump_anim:resume()

			pipes = {Pipe(WINDOW_WIDTH*0.5, 
			random_loc, 
			'/Graphics/F_BIRD_PIPEUP.png'),}

			first_pipe_pair = Pipe(pipes[1].x, pipes[1].y - PIPE_PAIR_GAP, '/Graphics/F_BIRD_PIPEDOWN.png')
			first_pipe_pair.scored = true 

			table.insert(pipes, first_pipe_pair)
		end
	end
end



function love.resize(w, h)

	love.graphics.scale(w/WINDOW_WIDTH, h/WINDOW_HEIGHT)
end

function displayFPS()
    -- simple FPS display across all states

    fps_font = love.graphics.setNewFont('/Graphics/flappy.ttf', 24)
	love.graphics.setFont(fps_font)
    love.graphics.setColor(30, 170, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), WINDOW_WIDTH*0.05, WINDOW_HEIGHT*0.95)
end


function show_score()
	love.graphics.setFont(medium_font)
	love.graphics.printf(tostring(SCORE), WINDOW_WIDTH*0.05, WINDOW_HEIGHT*0.05, WINDOW_WIDTH, 'left')
end

