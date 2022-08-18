scale = 5
pixels = {{true}}

function love.draw()
    love.graphics.clear(1,1,1,1)
    love.graphics.setColor(0, 0, 0, 1)
    local w, h, _ = love.window.getMode()
    for y, row in pairs(pixels) do
        for x, _ in pairs(row) do
            love.graphics.rectangle("fill", w / 2 + x * scale, h / 2 + y * scale, scale, scale)
        end
    end
end

row = 1
budget = 0
function love.update(dt)
    budget = budget + dt
    while budget > 0 do
        budget = budget - .02
        local check = {}
        for x in pairs(pixels[row]) do
            for dx = -1, 1 do
                check[x + dx] = (check[x + dx] or 0) + math.pow(10, 1 - dx)
            end
        end
        if row < 50 then
            row = row + 1
        else
            for x=1,50 do
                pixels[x]=pixels[x+1]
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
