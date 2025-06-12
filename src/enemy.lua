local enemy = {}

local collision = require("src.collision")

-- enemy variables
enemy.amount = 0
enemy.count = 2
enemy.wave = 0
enemy.creatures = {} -- Store all enemy instances here

-- general variables
local timer = 0

-- spawn enemies
function enemy.spawn(amount)
	for i = 1, amount do
		local width = math.random(20, 40)
		local creature = {
			dir = math.random(0, 3),

			x = math.random(0, 1000),
			y = math.random(0, 1000),

			width = width,
			height = width,

			speed = (100 / (width * 1.5)) * 50,

			hp = width,

            score = width * math.random(0.5, 1.5) + 3
		}
		table.insert(enemy.creatures, creature)
	end

	enemy.amount = amount
	enemy.count = amount
end

-- reset all enemies
function enemy.reset(all)
    enemy.creatures = {}
    enemy.amount = 0
    if all then
        enemy.count = 2
    else
        enemy.count = 0
    end
end
-- move enemy
function enemy.movement_man(dt, player)
	for i, creature in ipairs(enemy.creatures) do
        local dx = player.x - creature.x
        local dy = player.y - creature.y
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist > 0 then
            creature.x = creature.x + (dx / dist) * creature.speed * dt
            creature.y = creature.y + (dy / dist) * creature.speed * dt
        end
	end
end


-- manage hp
function enemy.hp_man(player_projectile, player)
	if not player_projectile then
		return false
	end

	for i = #enemy.creatures, 1, -1 do
        local creature = enemy.creatures[i]

		local projectile_box = {
			x = player_projectile.x,
			y = player_projectile.y,
			width = 10,
			height = 10,
		}

		if not collision.check(projectile_box, creature) then
			goto continue
		end

		creature.hp = creature.hp - 2

		if creature.hp <= 0 then
			table.remove(enemy.creatures, i)
			enemy.count = enemy.count - 1
		end
        ::continue::
	end
end

function enemy.wave_man()
    if enemy.count <= 0 or enemy.wave == 0 then
        enemy.wave = enemy.wave + 1
        enemy.reset(false)
        local next_wave_amount = 2 + enemy.wave * 2
        enemy.spawn(next_wave_amount)
    end
end
-- look if enemy is in wall

function enemy.check_wall(walls)
	for _, creature in ipairs(enemy.creatures) do
		for _, circle in ipairs(walls.circles) do
			if not collision.check_circle(creature, circle) then
				-- Teleport enemy to a new random position
				creature.x = math.random(0, 1000)
				creature.y = math.random(0, 1000)
				break
			end
		end
	end
end


-- Draw all enemies
function enemy.draw()
	love.graphics.setColor(1, 0, 0, 1)
	for _, creature in ipairs(enemy.creatures) do
		love.graphics.rectangle("fill", creature.x, creature.y, creature.width, creature.height)
	end
end

-- Get all enemies for collision detection
function enemy.get_creatures()
	return enemy.creatures
end

return enemy
