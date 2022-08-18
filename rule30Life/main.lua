pixels = {{true}}
w = 500
h = 300
fade = {}
for y = 1, h do
    fade[y] = {}
    for x = 1, w do
        fade[y][x] = 0
    end
end

function love.draw()
    -- Compute scale
    sW, sH = love.graphics.getDimensions()
    scale = sW / w
    local scaleH = sH / h
    if scaleH < scale then
        scale = scaleH
    end
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.scale(scale, scale)
    for y = 0, h - 1 do
        if fade[y] then
            for x = 0, w - 1 do
                local fadeVal = fade[y][x]
                if fadeVal then
                    if fadeVal == 255 then
                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.rectangle("fill", x, y, 1, 1)
                    else
                        love.graphics.setColor(fadeVal / 512, 0, fadeVal / 512, 1)
                        love.graphics.rectangle("fill", x, y, 1, 1)
                    end
                end
            end
        end
    end
    love.graphics.scale()
end

row = 1
budget = 0
function love.update(dt)
    budget = budget + dt
    -- Prefer slowing down to dropping framerate too much
    if budget > .1 then
        budget = 1
    end
    -- Update the fading
    while budget > 0 do
        for y = 1, h do
            local row = pixels[y - h + 100]
            if row then
                for x = 1, w do
                    if row[x - w / 2] then
                        fade[y][x] = 255
                    elseif fade[y][x] > 0 then
                        fade[y][x] = fade[y][x] - 1
                    end
                end
            else
                for x = 1, w do
                    fade[y][x] = (fade[y][x] or 1) - 1
                end
            end
        end
        budget = budget - .02
        local check = {}
        for x in pairs(pixels[row]) do
            for dx = -1, 1 do
                check[x + dx] = (check[x + dx] or 0) + math.pow(10, 1 - dx)
            end
        end
        if row < 100 then
            row = row + 1
        else
            -- game of life
            local neighbors = {}
            for y, col in pairs(pixels) do
                if y <= 1 then
                    for x, _ in pairs(col) do
                        for dY = -1, 1 do
                            if neighbors[y + dY] == nil then
                                neighbors[y + dY] = {}
                            end
                            for dX = -1, 1 do
                                neighbors[y + dY][x + dX] = (neighbors[y + dY][x + dX] or 0) + 1
                            end
                        end
                        neighbors[y][x] = neighbors[y][x] - 1
                    end
                end
            end
            for y, row in pairs(neighbors) do
                if y < 1 then
                    for x, numNeighbors in pairs(row) do
                        if pixels[y] and pixels[y][x] then
                            if numNeighbors < 2 or numNeighbors > 3 then
                                pixels[y][x] = nil
                                if next(pixels[y]) == nil then
                                    pixels[y] = nil
                                end
                            end
                        else
                            if numNeighbors == 3 then
                                if pixels[y] == nil then
                                    pixels[y] = {}
                                end
                                pixels[y][x] = true
                            end
                        end
                    end
                end
            end
            -- shift up rule30
            for y = 1, 100 do
                pixels[y] = pixels[y + 1]
            end
        end
        if pixels[row] == nil then
            pixels[row] = {}
        end
        for x, v in pairs(check) do
            if v == 100 or v == 011 or v == 010 or v == 001 then
                pixels[row][x] = true
            end
        end
    end
end
function love.load()
    love.window.setMode(1000, 1000, {
        fullscreen = true
    })
end
