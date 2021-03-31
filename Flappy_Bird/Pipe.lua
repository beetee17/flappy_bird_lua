Pipe = Class {}

function Pipe:init(x, y, image)
	self.image = love.graphics.newImage(image)
	self.x = x
	self.y = y 
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.scored = false
end

function Pipe:draw()
	love.graphics.draw(self.image, self.x, self.y)
end

function Pipe:move(dt)
	self.x = self.x - SCROLL_SPEED*dt 
end


-- function Pipe:get_pair()
-- 	pair = Pipe(self.x, self.y, '/Graphics/F_BIRD_PIPEDOWN.png')
-- 	pair.scored = true
-- 	return pair
-- end
