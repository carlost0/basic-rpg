local walls = {
    {
        x = 100, y = 100, width = 500, height = 30
    },
    {
        x = 400, y = 300, width = 100, height = 300
    }
}

function walls.draw()
    love.graphics.setColor(1, 1, 1, 1)

    -- in love.draw()
    for _, wall in ipairs(walls) do
        love.graphics.rectangle("fill", wall.x, wall.y, wall.width, wall.height)
    end
end

return walls
