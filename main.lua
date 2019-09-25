function love.load()

    -- set the requirements
    require "colors"
    require "text"
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

    -- rotation variables
    ox = cellSize / 2
    oy = cellSize / 2
    a = 0
    rfactor = 0.75 -- rotation speed

    -- creating a food table object
    food = {x = 0, y = 0}

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
    foodEaten = 0
    levelChange = true
    colorLevel = 1
    speedLevel = 0 -- the speed increases every time the levels cycle
    speed = 0
    speedChange = false

    -- index for color rotation on food
    i = 1

    -- loading the music and audio files
    bgMusic = love.audio.newSource('Sports.wav', 'stream')
        bgMusic:setLooping(true)
        bgMusic:setVolume(0.2)
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
                end -- end if
            end -- end for foodY
        end -- end for foodX

        -- setting the new food position
        foodPosition = possibleFoodPositions[math.random(#possibleFoodPositions)]
        foodFlux(food, foodPosition.x, foodPosition.y) -- this doesn't work, but it should flux the food location

        -- after X food eaten, increase the levels

        -- increase level and colorLevel
        if foodLevel == 5 then
            foodLevel = 0
            level = level + 1
            levelChange = true
        end

        -- increase speed every 3 levels
        if level % 3 == 0 then
            speedLevel = speedLevel + 0.02
            speed = speed + 1
        end

        foodLevel = foodLevel + 1
        foodEaten = foodEaten + 1

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
        foodLevel = 0
        speedLevel = 0
        foodEaten = 0
        speed = 0
        moveFood()
    end -- end function

    reset() -- loading a reset of the game to start
end

----------------------------------------------------------------------------
function love.update(dt)

    timer = timer + dt
    flux.update(dt)

    -- math for the food rotation
    a = math.rad(math.floor(math.deg(a + rfactor * dt * 9)))


    i = i + 1
    if i > 5 then
        i = 1
    end

    -- starting the loop of the game
    if snakeAlive then
        local timerLimit = 0.15 - speedLevel -- time between moves
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

            love.graphics.setColor(1, 1, 1, .5)
            love.graphics.setFont(bigFont)
            love.graphics.print("GAME OVER!", 400, 400)

    elseif timer >= 3 then -- waiting for the game to reset

        --love.graphics.setColor(1, 1, 1, .5)
        --love.graphics.setFont(bigFont)
        --love.graphics.print("GAME OVER!", 400, 400)

        --if timer >= 5 then
        -- this is where some mid-game animation should happen or "game over" text

    reset()
        --end
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
            love.graphics.setColor(tileColorArray[row * column]) -- set box color
            love.graphics.rectangle('fill', (row - 1) * cellSize, (column - 1) * cellSize, cellSize, cellSize)
                love.graphics.setColor(lineColorArray[level]) -- set border color
                love.graphics.rectangle('line', (row - 1) * cellSize, (column - 1) * cellSize, cellSize, cellSize)
        end
    end

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
    love.graphics.setColor(lineColorArray[i])
    --drawCell(foodPosition.x, foodPosition.y) -- this is the old way
    rotateRect('fill', (foodPosition.x - 1) * cellSize, (foodPosition.y - 1) * cellSize, cellSize, cellSize, a, ox, oy)

    -- adding the glow effect to the canvas
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    effect.draw(function()
        love.graphics.draw(canvas, 0, 0, 0, 1, 1)
    end)

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
    --love.graphics.print(foodEaten + 2, 710, 30)

end -- end draw

-- other random functions down here
----------------------------------------------------------------------------

-- keypress function for the snake movement
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

-- drawing the food or whatever
function drawCell(x, y)
    love.graphics.rectangle('fill', (x - 1) * cellSize, (y - 1) * cellSize, cellSize - 1, cellSize - 1)
end

-- the rotation function to rotate the food
function rotateRect(mode, x, y, w, h, a, ox, oy)
  ox = ox or 0
  oy = oy or 0
  a = a or 0
  love.graphics.push()
  love.graphics.translate(x + w / 2, y + h / 2)
  love.graphics.rotate(a)
  love.graphics.rectangle(mode, -ox, -oy, w, h)
  love.graphics.pop()
end

function foodFlux(obj, fx, fy)
    flux.to(obj, 1, {x = fx}, {y = fy})
end
