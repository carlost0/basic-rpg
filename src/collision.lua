collision = {}

function collision.check(a, b)
	if a == nil or b == nil then
		return false
	end

	return a.x < b.x + b.width and b.x < a.x + a.width and a.y < b.y + b.height and b.y < a.y + a.height
end

function collision.check_circle(r, c)
    if r == nil or c == nil then 
        return false
    end
    
    local closestX = math.max(r.x, math.min(c.x, r.x + r.width))
    local closestY = math.max(r.y, math.min(c.y, r.y + r.height))

    -- Calculate the distance between the circle's center and this closest point
    local distanceX = c.x - closestX
    local distanceY = c.y - closestY

    -- Calculate squared distance and compare with squared radius
    local distanceSquared = (distanceX * distanceX) + (distanceY * distanceY)

    return distanceSquared <= ((c.radius - 30) * (c.radius - 30))
end 

return collision
