-- setting the fonts
mainFont = love.graphics.newFont("Quantum.otf", 30)
bigFont = love.graphics.newFont("Quantum.otf", 60)
smallFont = love.graphics.newFont("KeepCalm.ttf", 15)

function printStats()
    love.graphics.setColor(1, 1, 1, .5)
    love.graphics.setFont(mainFont)
    love.graphics.print('level', 10, 5)
    love.graphics.print('speed', 100, 5)
    love.graphics.print('length', 700, 5)

    love.graphics.setFont(bigFont)
    love.graphics.print(level, 30, 30)
    love.graphics.print(speed + 1, 120, 30)
    if foodEaten < 10 then
        love.graphics.print('0'..foodEaten + 2, 710, 30)
    else
        love.graphics.print(foodEaten + 2, 710, 30)
    end

end -- end printStats function

function readOut()
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(smallFont)
    --love.graphics.print('speed' ..speedLevel, 10, 400)
    --love.graphics.print('level: '..level, 10, 420)
end

function tweenWord()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('TWEEEEEN!', food.x + 30, food.y + 30)
end
