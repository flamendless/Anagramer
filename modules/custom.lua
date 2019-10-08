local custom = {}
custom.print = {}
custom.rectangle = {}
custom.collisions = {}

function custom.collisions.circle(x,y,c,f,e)
	f = f or function () end
	e = e or function () end

	if (x - c.x)^2 + (y - c.y)^2 < c.r ^ 2 then
		f(x,y,c)
	else
		e(x,y,c)
	end
end

function custom.collisions.box(x,y,b,t,f,e)
	f = f or function () end
	e = e or function () end

	t = t or {}
	if 	x > b.x - (t[1] or 0) and
		y > b.y - (t[2] or 0) and
		x < (b.x + b.w) + (t[3] or 0) and
		y < (b.y + b.h) + (t[4] or 0) then

		f(x,y,b,t)
	else
		e(x,y,b,t)
	end
end

function custom.print.center(str, font, offx, offy)
	local offx = offx or 0
	local offy = offy or 0
	love.graphics.print(str,
		game.width/2 - font:getWidth(str)/2 + offx,
		game.height/2 - font:getHeight(str)/2 + offy)
end

function custom.print.header(str, font, offx, offy)
	local offx = offx or 0
	local offy = offy or 0
	love.graphics.print(str,
		game.width/2 - font:getWidth(str)/2 + offx,
		offy/2 - font:getHeight(str)/2)
end

function custom.print.footer(str, font, offx, offy)
	local offx = offx or 0
	local offy = offy or 0
	love.graphics.print(str,
		game.width/2 - font:getWidth(str)/2 + offx,
		game.height - font:getHeight(str) - offy)
end

function custom.rectangle.bar(rect_table)
	local rect = rect_table
	material.shadow.draw(rect.x, rect.y, rect.w, rect.h, false, false, 2)
	love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
	love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h)
end

function custom.rectangle.card(shadow_table, rect_table)
	local s = shadow_table
	local rect = rect_table
	material.shadow.draw(s.x, s.y, s.w, s.h, false, false, 3)
	love.graphics.polygon("fill", unpack(rect))
	love.graphics.polygon("line", unpack(rect))
end

return custom
