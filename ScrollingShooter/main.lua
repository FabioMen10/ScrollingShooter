debug = false

createEnemyTimerMax = 0.8

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
  x2 < x1 + w1 and
  y1 < y2 + h2 and
  y2 < y1 + h1
end

-- Loading
function love.load()
  Object = require "classic"
  require "player"
  require "enemy"
  require "bullet"

  player = Player()

  -- Entity Storage
  bullets = {} -- array of current bullets being drawn and updated
  enemies = {} -- array of current enemies on screen

  -- State of the game
  isAlive = true
  score = 0

  -- Timers
  -- We declare these here so we don't have to edit them multiple places
  canShoot = true
  canShootTimerMax = 0.4
  canShootTimer = canShootTimerMax

  if(createEnemyTimerMax >= 0.05) then
    createEnemyTimer = createEnemyTimerMax
  else
    createEnemyTimer = 0.05
  end

  gunSound = love.audio.newSource("assets/gun-sound.wav", "static")
  explosionSound = love.audio.newSource("assets/explosion.wav", "static")
end

-- Updating
function love.update(dt)
  -- I always start with an easy way to exit the game
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  -- Time out how far apart our shots can be.
  canShootTimer = canShootTimer - (1 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end

  -- Time out enemy creation
  createEnemyTimer = createEnemyTimer - (1 * dt)
  if createEnemyTimer < 0 and isAlive then
    createEnemyTimer = createEnemyTimerMax

    -- Create an enemy
    newEnemy = Enemy()
    table.insert(enemies, newEnemy)
  end

  -- update the positions of bullets
  for i, bullet in ipairs(bullets) do
    bullet:move(dt)

    if bullet.y < 0 then -- remove bullets when they pass off the screen
      table.remove(bullets, i)
    end
  end

  -- update the positions of enemies
  for i, enemy in ipairs(enemies) do
    enemy:move(dt)

    if enemy.y > love.graphics:getHeight() then -- remove enemies when they pass off the screen
      table.remove(enemies, i)
      createEnemyTimerMax = createEnemyTimerMax - createEnemyTimerMax / 2
    end
  end

  -- run our collision detection
  -- Since there will be fewer enemies on screen than bullets we'll loop them first
  -- Also, we need to see if the enemies hit our player
  for i, enemy in ipairs(enemies) do
    for j, bullet in ipairs(bullets) do
      if checkCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
        table.remove(bullets, j)
        table.remove(enemies, i)
        score = score + 1
        explosionSound:play()
      end
    end

    if checkCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
    and isAlive then
      table.remove(enemies, i)
      isAlive = false
    end
  end

  if love.keyboard.isDown('space', 'rctrl', 'lctrl') and canShoot and isAlive then
    player:shoot()
  end

  -- Horizontal movement
  if love.keyboard.isDown('left', 'a') then
    player:moveLeft(dt)
  elseif love.keyboard.isDown('right', 'd') then
    player:moveRight(dt)
  end

  -- Vertical movement
  if love.keyboard.isDown('up', 'w') then
    player:moveUp(dt)
  elseif love.keyboard.isDown('down', 's') then
    player:moveDown(dt)
  end

  -- Restart game
  if not isAlive and love.keyboard.isDown('r') then
    love.load()
  end
end

-- Drawing
function love.draw()
  for i, bullet in ipairs(bullets) do
    bullet:draw()
  end

  for i, enemy in ipairs(enemies) do
    enemy:draw()
  end

  if isAlive then
    player:draw()
  else
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth() / 2 - 50, love.graphics:getHeight() / 2 - 10)
  end

  -- Show the score
  love.graphics.setColor(0, 255, 0)
  love.graphics.print("Score: " .. score, love.graphics:getWidth() - 80, 10)
  love.graphics.setColor(255, 255, 255)

  -- Display FPS
  if debug then
    fps = tostring(love.timer.getFPS())
    love.graphics.print("Current FPS: "..fps, 9, 10)
  end
end
