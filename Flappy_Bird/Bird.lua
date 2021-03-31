Bird = Class {}

function Bird:init(x, y)
	self.image = love.graphics.newImage('/Graphics/F_BIRD_2(0).png')
	self.x = x
	self.y = y 
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.dy = 0
end

function Bird:reset(x, y)
	self.x = x
	self.y = y 
	self.dy = 0
end


function Bird:draw()
	love.graphics.draw(self.image, self.x, self.y)
end

function Bird:update(dt)
	self.dy = self.dy + GRAVITY*dt
	if love.keyboard.wasPressed('space') then 
		love.audio.play(jump_sound)
		if game_state == 'game_over' then 
			return 0
		else
			self.dy = - JUMP_HEIGHT
			
		end
	end
	self.y = self.y + self.dy
end

	
function Bird:is_collided_with(pipe)
	if self.x > pipe.x + pipe.width 
		or self.x + self.width < pipe.x then 

		return false
	end

	if self. y > pipe.y + pipe.height
		or self.y + self.height < pipe.y then 

		return false
	end

	return true
end

