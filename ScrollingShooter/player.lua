Player = Object:extend()

function Player:new()
  self.x = 200
  self.y = 710
  self.speed = 200
  self.img = love.graphics.newImage("assets/plane.png")
end

function Player:moveRight(dt)
  if self.x < (love.graphics.getWidth() - self.img:getWidth()) then
    self.x = self.x + (self.speed * dt)
  end
end

function Player:moveLeft(dt)
  if self.x > 0 then -- binds us to the map
    self.x = self.x - (self.speed * dt)
  end
end

function Player:moveUp(dt)
  if self.y > 0 then
    self.y = self.y - (self.speed * dt)
  end
end

function Player:moveDown(dt)
  if self.y < (love.graphics.getHeight() - self.img:getHeight()) then
    self.y = self.y + (self.speed * 0.5 * dt)
  end
end

function Player:shoot()
  -- Create some bullets
  newBullet = Bullet(self.x + (self.img:getWidth() / 2), self.y)
  table.insert(bullets, newBullet)
  canShoot = false
  canShootTimer = canShootTimerMax
  gunSound:play()
end

function Player:draw()
  love.graphics.draw(self.img, self.x, self.y)
end
