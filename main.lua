-- requirements
player = require("src.player")
walls = require("src.walls")
config = require("gameconf")
enemy = require("src.enemy")

-- keypresses
function love.keypressed(key)
    player.keypressed(key)
end

-- main loop
function love.update(dt)
    player.man(dt)
    player.update_projectile(dt)
    print(player.x, player.y)
end

function love.draw()
    -- player
    player.draw()

    -- enemy
    enemy.draw()

    -- projectile
    if player.projectile then
        love.graphics.rectangle("fill", player.projectile.x, player.projectile.y, 10, 10)
    end

    -- walls
    walls.draw()
end
