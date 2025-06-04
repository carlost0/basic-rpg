collision = {}

function collision.check(a, b)
	if a == nil or b == nil then
		return false
	end

	return a.x < b.x + b.width and b.x < a.x + a.width and a.y < b.y + b.height and b.y < a.y + a.height
end

return collision
