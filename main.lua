_G.love = require('love')

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
    love.graphics.setBackgroundColor(love.math.colorFromBytes(100,100,240))

    _G.pacman = {
        x = 200,
        y = 200,
        radius = 60,
        angle1 = AngleToRadians(TopAngle),
        angle2 = AngleToRadians(BelowAngle),
        IsOpen = false,
        direction = 0
    }

    _G.ScoreCard = {
        score = 0,
        maxScore = 5
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
    
    _G.wonGame = false

end

function GetNewLocationAfterRotation(radius, nwAn)
    return {
        xchange = radius * math.cos(nwAn),
        ychange = radius * math.sin(nwAn)
    }
end

function love.update(dt)
    if love.keyboard.isDown("a") then
        pacman.direction = 2
    elseif love.keyboard.isDown("w") then
        pacman.direction = 1
    elseif love.keyboard.isDown("s") then
        pacman.direction = 3
    elseif love.keyboard.isDown("d") then
        pacman.direction = 0
    end

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
        _G.ScoreCard.score = _G.ScoreCard.score + 1
        food.x = math.random(100, 600)
        food.y = math.random(100, 500)
    end
    food.IsEaten = isColli
end

function love.draw()

if not _G.wonGame then 
        love.graphics.setLineWidth(3)
    love.graphics.setLineStyle("smooth")
    love.graphics.setColor(love.math.colorFromBytes(200,200,100))
    love.graphics.arc("fill",pacman.x, pacman.y, pacman.radius, pacman.angle1, pacman.angle2, 50)

    love.graphics.setLineWidth(2)
    love.graphics.setColor(0,0,0)
    love.graphics.arc("line", pacman.x, pacman.y, pacman.radius, pacman.angle1, pacman.angle2, 50)

    love.graphics.setColor(1,0,0);
    love.graphics.circle("line", pacmanEye.x, pacmanEye.y, pacmanEye.radius);

    love.graphics.setColor(0, 0.4, 0)

    if not food.IsEaten then
        love.graphics.rectangle("fill", food.x, food.y, food.width, food.height);
    end
    
    love.graphics.setLineWidth(5)
    love.graphics.setLineStyle("rough")

    love.graphics.setColor(love.math.colorFromBytes(100,100,150))
    love.graphics.rectangle("line", 600, 0, 200, 100) 

    love.graphics.setColor(love.math.colorFromBytes(50,150,200))
    love.graphics.rectangle("fill", 600, 0, 200, 100) 

    love.graphics.setColor(0, 0, 0)
    local text1 = love.graphics.newText(love.graphics.newFont("fonts/PerfectPixel.ttf"),
        string.format("Score %d", _G.ScoreCard.score))
    
    love.graphics.setColor(love.math.colorFromBytes(100,0,100))
    local text2 = love.graphics.newText(love.graphics.newFont("fonts/PerfectPixel.ttf"),"MiniPacman")

    love.graphics.setLineStyle("rough")
    love.graphics.draw(text2,350,25,0,2,2,0,0,0,0)
    
    love.graphics.setColor(0,0,0)
    love.graphics.draw(text1, 640, 25, 0, 2, 2, 0, 0, 0, 0)

    
    if _G.ScoreCard.score == _G.ScoreCard.maxScore then _G.wonGame= true end
else 
    love.graphics.setBackgroundColor(love.math.colorFromBytes(0,0,0))

    love.graphics.setColor(love.math.colorFromBytes(255,255,255))
    local text = love.graphics.newText(love.graphics.newFont("fonts/PerfectPixel.ttf"),"You won")
    love.graphics.draw(text, 350, 250, 0, 2, 2, 0, 0, 0, 0)
end

end
