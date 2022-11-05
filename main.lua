_G.love = require('love')
-- local GameState = require('gameState')

PIE = 3.14
--- Converts angle to radians
---@param angle number
function AngleToRadians(angle)
    return (angle / 360) * 2 * PIE
end

function RadiansToAngle(radian)
    return (radian / (2 * PIE)) * 360
end

_G.TopAngle = 25
_G.BelowAngle = 335

--- func desc
---@param angle1 number
---@param angle2 number
function UpdatePacmanMouth(angle1, angle2)

    angle1 = RadiansToAngle(angle1)
    angle2 = RadiansToAngle(angle2)

    -- print(string.format("Angle1 %f Angle2 %f", angle1, angle2))

    if not (pacman.IsOpen) then
        angle1 = angle1 - 1
        angle2 = angle2 + 1
    else
        angle1 = angle1 + 1
        angle2 = angle2 - 1
    end

    if angle1 < 0 or angle2 > 360 then
        angle1 = 0
        angle2 = 360
        pacman.IsOpen = not pacman.IsOpen
    elseif angle1 > TopAngle or angle2 < BelowAngle then
        angle1 = TopAngle
        angle2 = BelowAngle
        pacman.IsOpen = not pacman.IsOpen
    end

    return {
        angle1 = AngleToRadians(angle1),
        angle2 = AngleToRadians(angle2)
    }
end

_G.Speed = 2

function UpdatePacmanPosition(x, y, direction)
    -- print(string.format("x %d y %d direction %d", x, y, direction))
    if direction == 0 then
        x = x + Speed
        if x == 800 then
            direction = 2
        end
    elseif direction == 1 then
        y = y - Speed
        if y == 0 then
            direction = 3
        end
    elseif direction == 2 then
        x = x - Speed
        if x == 0 then
            direction = 0
        end
    else
        y = y + Speed
        if y == 600 then
            direction = 1
        end
    end

    return {
        x = x,
        y = y,
        direction = direction
    }
end

function CheckIsCollding(xs, ys, widths, heights, xo, yo, ro)
    if math.abs((xs + (widths / 2)) - xo) <= ((widths / 2) + ro) and math.abs((ys + heights / 2) - yo) <=
        ((heights / 2) + ro) then
        return true
    else
        return false
    end
end

function love.load()
    love.graphics.setBackgroundColor(0.3, 0.3, 0.8)

    _G.pacman = {
        x = 200,
        y = 200,
        radius = 60,
        angle1 = AngleToRadians(TopAngle),
        angle2 = AngleToRadians(BelowAngle),
        IsOpen = false,
        direction = 0
    }

    _G.pacmanEye = {
        x = 225,
        y = 175,
        radius = 8,
        direction = 0
    }

    love.graphics.setColor(0.4, 0.4, 1)

    _G.food = {
        x = 550,
        y = 150,
        width = 100,
        height = 100,
        IsEaten = false
    }
end

function GetNewLocationAfterRotation(radius, nwAn)
    return {
        xchange = radius * math.cos(nwAn),
        ychange = radius * math.sin(nwAn)
    }
end

function love.update(dt)
    local pacmanStatePositionChange = UpdatePacmanPosition(pacman.x, pacman.y, pacman.direction);
    local pacmanStateChange = UpdatePacmanMouth(pacman.angle1, pacman.angle2);
    local changedAngle = pacmanStateChange.angle1 - pacman.angle1;
    pacman.angle1 = pacman.angle1 + changedAngle;
    pacman.angle2 = pacman.angle2 - changedAngle;

    local pacxch = pacman.x - pacmanStatePositionChange.x;
    local pacych = pacman.y - pacmanStatePositionChange.y;

    pacman.x = pacman.x - pacxch;
    pacman.y = pacman.y - pacych;
    pacman.direction = pacmanStatePositionChange.direction;

    pacmanEye.x = pacmanEye.x - pacxch;
    pacmanEye.y = pacmanEye.y - pacych;
    pacmanEye.direction = pacman.direction;

    local isColli = CheckIsCollding(food.x, food.y, food.width, food.height, pacman.x, pacman.y, pacman.radius)
    if food.IsEaten == true and isColli == false then
        food.x = math.random(100, 600)
        food.y = math.random(100, 500)
    end
    food.IsEaten = isColli
    -- local change = GetNewLocationAfterRotation(pacman.radius, pacmanStateChange.angle1)
    -- pacmanEye.x = pacmanEye.x + change.xchange;
    -- pacmanEye.y = pacmanEye.y + change.ychange;
end

function love.draw()
    -- love.graphics.print(string.format("Pacman x %d y %d", pacman.x, pacman.y))

    love.graphics.setColor(0.8, 0.4, 0.6)
    love.graphics.arc("fill", pacman.x, pacman.y, pacman.radius, pacman.angle1, pacman.angle2, 50)

    love.graphics.setColor(1, 1, 1);
    love.graphics.circle("line", pacmanEye.x, pacmanEye.y, pacmanEye.radius);

    if not food.IsEaten then
        love.graphics.rectangle("fill", food.x, food.y, food.width, food.height);
    end
end
