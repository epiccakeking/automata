scale = 5
pixels = {}
for x = -100, 100 do
    for y = -100, 100 do
        if love.math.random(1, 3) == 1 then
            if pixels[x] == nil then
                pixels[x] = {}
            end
            pixels[x][y] = true
        end
    end
end

function love.draw()
    love.graphics.clear(1,1,1,1)
    love.graphics.setColor(0, 0, 0, 1)
    local w, h, _ = love.window.getMode()
    for x, col in pairs(pixels) do
        for y, _ in pairs(col) do
            love.graphics.rectangle("fill", w / 2 + x * scale, h / 2 + y * scale, scale, scale)
        end
    end
end

budget = 0
function love.update(dt)
    budget = budget + dt
    while budget > 0 do
        budget = budget - .05
        local neighbors = {}
        for x, col in pairs(pixels) do
            for y, _ in pairs(col) do
                for dX = -1, 1 do
                    if neighbors[x + dX] == nil then
                        neighbors[x + dX] = {}
                    end
                    for dY = -1, 1 do
                        neighbors[x + dX][y + dY] = (neighbors[x + dX][y + dY] or 0) + 1
                    end
                end
                neighbors[x][y] = neighbors[x][y] - 1
            end
        end
        for x, col in pairs(neighbors) do
            for y, numNeighbors in pairs(col) do
                if (not (pixels[x] == nil)) and (not (pixels[x][y] == nil)) then
                    if numNeighbors < 2 or numNeighbors > 3 then
                        pixels[x][y] = nil
                        if next(pixels[x]) == nil then
                            pixels[x] = nil
                        end
                    end
                else
                    if numNeighbors == 3 then
                        if pixels[x] == nil then
                            pixels[x] = {}
                        end
                        pixels[x][y] = true
                    end
                end
            end
        end
    end
end

function love.load()
    love.window.setMode(1000, 1000, {
        fullscreen = true
    })
end