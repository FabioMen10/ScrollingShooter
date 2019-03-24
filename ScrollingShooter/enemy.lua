Enemy = Object:extend()

function Enemy:new()
  self.img = love.graphics.newImage("assets/enemy.png")
  self.x = math.random(10, love.graphics.getWidth() - self.img:getWidth())
  self.y = -10
  self.speed = 200
end

function Enemy:move(dt)
  self.y = self.y + (self.speed * dt)
end

function Enemy:draw()
  love.graphics.draw(self.img, self.x, self.y)
end
