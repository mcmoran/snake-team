function love.load()

    -- set the requirements
    require "colors"
    flux = require "flux"
    moonshine = require "moonshine"
    effect = moonshine(moonshine.effects.glow)
        effect.glow.min_luma = 1.5

    -- setting up the play area parameters
    gridXCount = 20 -- how many cells across
    gridYCount = 15 -- how many cells up and down
    cellCount = gridXCount * gridYCount -- how many cells there are
    cellSize = 40 -- the size of a cell

    -- size of the window
    love.window.setMode(gridXCount * cellSize, gridYCount * cellSize)

    -- setting a canvas for the background
    canvas = love.graphics.newCanvas(gridXCount * cellSize, gridYCount * cellSize)
    canvas:setFilter('nearest', 'nearest')

    -- setting a canvas for a color overlay on the background
    --overlay = love.graphics.newCanvas(gridXCount * cellSize, gridYCount * cellSize)
    --overlay:setFilter('nearest', 'nearest')

    -- segments of the snake to start the game (3 of them)
    snakeSegments = { {x = 3, y = 1},
                    {x = 2, y = 1},
                    {x = 1, y = 1} }

    -- setting the game play environment (timer, direction, randomizer)
    timer = 0
    directionQueue = {'right'}
    math.randomseed(os.time())

    -- setting up the color variables
    tileColorArray = {} -- empty array for random colors

    -- game levels
    level = 1
    foodLevel = 0
    levelChange = true
    colorLevel = 1
    speedLevel = 0 -- the speed increases every time the levels cycle
    speedChange = false

    -- loading the music and audio files
    bgMusic = love.audio.newSource('Sports.wav', 'stream')
        bgMusic:setLooping(true)
        bgMusic:setVolume(0.1)
        bgMusic:play()

    -- function to move the food
    function moveFood()
        local possibleFoodPositions = {}

        for foodX = 1, gridXCount do
            for foodY = 1, gridYCount do
                local possible = true

                -- if the food is in the snake, then it's not possible
                for segmentIndex, segment in ipairs(snakeSegments) do
                    if foodX == segment.x and foodY == segment.y then
                        possible = false
                    end
                end

                -- if it is possible, then place a random food.
                if possible then
                    table.insert(possibleFoodPositions, {x = foodX, y = foodY})

                    -- insert a new tile color array for each food placement
                    --tileColorArray = {}
                    --for tileNumber = 1, cellCount do
                    --    table.insert(tileColorArray, levelMap[level][math.random(1,5)])
                        --table.insert(tileColorArray, snakeLevel1[math.random(1,5)])
                    --end -- end for
                end -- end if
            end -- end for foodY

        end -- end for foodX

        -- setting the new food position
        foodPosition = possibleFoodPositions[math.random(#possibleFoodPositions)]

        -- adding a new food level and overall level
        if foodLevel == 3 then
            level = level + 1
            colorLevel = colorLevel + 1
            if colorLevel > 8 then
                speedChange = true
                colorLevel = 1
            end
            foodLevel = 1
            levelChange = true
        end
        foodLevel = foodLevel + 1

        if speedChange == true then
            speedLevel = speedLevel + 0.02
            speedChange = false
        end

    end -- end move food function

    -- reset function
    function reset()
        snakeSegments = {   {x = 3, y = 1},
                            {x = 2, y = 1},
                            {x = 1, y = 1} }
        directionQueue = {'right'}
        snakeAlive = true
        timer = 0
        level = 1
        colorLevel = 1
        foodLevel = 1
        speedLevel = 0
        moveFood()
    end -- end function

    reset() -- loading a reset of the game to start
end

----------------------------------------------------------------------------
function love.update(dt)
    timer = timer + dt

    -- starting the loop of the game
    if snakeAlive then
        local timerLimit = 0.15 - speedLevel
        if timer >= timerLimit then
            timer = timer - timerLimit

            -- sets a direction queue so the snake cant go back on itself
            if #directionQueue > 1 then
                table.remove(directionQueue, 1)
            end

            local nextXPosition = snakeSegments[1].x
            local nextYPosition = snakeSegments[1].y

            -- setting the right direction options for each coordinate
            if directionQueue[1] == 'right' then
                nextXPosition = nextXPosition + 1
                if nextXPosition > gridXCount then
                    nextXPosition = 1
                end
            elseif directionQueue[1] == 'left' then
                nextXPosition = nextXPosition - 1
                if nextXPosition < 1 then
                    nextXPosition = gridXCount
                end
            elseif directionQueue[1] == 'down' then
                nextYPosition = nextYPosition + 1
                if nextYPosition > gridYCount then
                    nextYPosition = 1
                end
            elseif directionQueue[1] == 'up' then
                nextYPosition = nextYPosition - 1
                if nextYPosition < 1 then
                    nextYPosition = gridYCount
                end
            end

            local canMove = true

            -- setting options for the snake to be unable to move
            for segmentIndex, segment in ipairs(snakeSegments) do
                if segmentIndex ~= #snakeSegments and nextXPosition == segment.x and nextYPosition == segment.y then
                    canMove = false
                end
            end

            -- if the snake can move then move the food and add a new segment
            if canMove then
                table.insert(snakeSegments, 1, {x = nextXPosition, y = nextYPosition})
                if snakeSegments[1].x == foodPosition.x and snakeSegments[1].y == foodPosition.y then
                    moveFood()
                else
                    table.remove(snakeSegments)
                end
            else
                snakeAlive = false
            end
        end
    elseif timer >= 2 then
        reset()
    end -- end game loop
end -- end update function

----------------------------------------------------------------------------
function love.draw()

    -- apparently this is important to have in here.  Not sure why.
    love.graphics.setBlendMode("alpha")

    -- if the level hasn't changed, then don't re-draw the grid
    if levelChange == true then
        levelChange = false
        tileColorArray = {}
        for tileNumber = 1, cellCount do
            table.insert(tileColorArray, levelMap[colorLevel][math.random(1,5)])
        end -- end for
    end

    -- setting up the grid
    for row = 1, gridXCount do
        for column = 1, gridYCount do
            love.graphics.setColor(0.1, 0.1, 0.1, 1) -- set border color
            love.graphics.rectangle('line', (row - 1) * cellSize, (column - 1) * cellSize, cellSize, cellSize)
            love.graphics.setColor(tileColorArray[row * column]) -- set box color
            love.graphics.rectangle('fill', (row - 1) * cellSize, (column - 1) * cellSize, cellSize, cellSize)
        end

    end

    -- change the overlay color to a random value when the level changes
    --if overlayChange == true then
--        love.graphics.setColor(math.random(.5, 1), math.random(.5, 1), math.random(.6, 1), .3) --overlayArray[level])
    --    love.graphics.rectangle('fill', 0, 0, gridXCount * cellSize, gridYCount * cellSize)
    --    overlayChange = false
    --end

    -- setting a canvas for the snake and food
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    -- draw the snake with trailing tail
    for segmentIndex, segment in ipairs(snakeSegments) do
        if snakeAlive then
            love.graphics.setColor(.5, .5, 0, (#snakeSegments) * (0.9 / segmentIndex))
        else
            love.graphics.setColor(1, 0, 0)
        end
        drawCell(segment.x, segment.y)
    end

    -- drawing food
    love.graphics.setColor(1, 1, 1, 1)
    drawCell(foodPosition.x, foodPosition.y)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    effect.draw(function()
        love.graphics.draw(canvas, 0, 0, 0, 1, 1)
    end)

    love.graphics.print('FPS: '.. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.print('Level: ' .. level, 10, 20)
    love.graphics.print('Food: ' .. foodLevel, 10, 30)
    love.graphics.print('Speed: ' .. speedLevel, 10, 40)
    --if overlayChange == true then
    --    love.graphics.print('Overlay: true', 10, 40)
    --else love.graphics.print('Overlay: false', 10, 40)
    --end

end -- end draw


----------------------------------------------------------------------------
function love.keypressed(key)
    if key == 'right'
        and directionQueue[#directionQueue] ~= 'right'
        and directionQueue[#directionQueue] ~= 'left' then
        table.insert(directionQueue, 'right')

    elseif key == 'left'
        and directionQueue[#directionQueue] ~= 'left'
        and directionQueue[#directionQueue] ~= 'right' then
        table.insert(directionQueue, 'left')

    elseif key == 'up'
        and directionQueue[#directionQueue] ~= 'up'
        and directionQueue[#directionQueue] ~= 'down' then
        table.insert(directionQueue, 'up')

    elseif key == 'down'
        and directionQueue[#directionQueue] ~= 'down'
        and directionQueue[#directionQueue] ~= 'up' then
        table.insert(directionQueue, 'down')

    elseif key == 'escape' then -- end game with escape
        love.event.push("quit")

    end
end

----------------------------------------------------------------------------
function drawCell(x, y)
    love.graphics.rectangle('fill', (x - 1) * cellSize, (y - 1) * cellSize, cellSize - 1, cellSize - 1)
end
