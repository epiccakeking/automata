possibleMoves = {"R", "L", "N"}
function randomizeMoves()
    moves = {}
    numMoves = love.math.random(2,10)
    for i = 1, numMoves do
        moves[i] = possibleMoves[love.math.random(1,3)]
    end
end
randomizeMoves()
pixels = {
    data = {}
}
scale = 5
function pixels:get(x, y)
    local p = self.data[x]
    if (p == nil) then
        return 1
    end
    return p[y] or 1
end

function pixels:inc(x, y)
    local n = self:get(x, y) % numMoves + 1
    if n == 1 then
        self:unset(x, y)
    else
        if self.data[x] == nil then
            self.data[x] = {}
        end
        self.data[x][y] = n
    end
end

function pixels:unset(x, y)
    if not (self.data[x] == nil) then
        self.data[x][y] = nil
        if next(self.data[x]) == nil then
            self.data[x] = nil
        end
    end
end

Ant = {
    x = 0,
    y = 0,
    r = 2
}
Ant.__index=Ant
function Ant:new()
    return setmetatable({}, Ant)
end

function Ant:walk()
    local index = pixels:get(self.x, self.y)
    local move = moves[index]
    if move == "R" then
        self.r = (self.r + 1) % 4
    elseif move == "L" then
        self.r = (self.r - 1) % 4
    end
    pixels:inc(self.x, self.y)
    if self.r == 0 then
        self.x = self.x + 1
    elseif self.r == 1 then
        self.y = self.y + 1
    elseif self.r == 2 then
        self.x = self.x - 1
    else
        self.y = self.y - 1
    end
end

ant = Ant:new()


function love.draw()
    love.graphics.clear(1,1,1,1)
    local w, h, _ = love.window.getMode()
    for x, col in pairs(pixels.data) do
        for y, v in pairs(col) do
            local c = (numMoves - v) / numMoves
            love.graphics.setColor(c, c, c, 1)
            love.graphics.rectangle("fill", w / 2 + x * scale, h / 2 + y * scale, scale, scale)
        end
    end
    love.graphics.print(moves, 10, 10)
end

boundsTimeout = 0
steps = 0
stepAllowance = 0
function love.update(dt)
    stepAllowance = stepAllowance + dt*1000
    while stepAllowance > 0 do
        stepAllowance = stepAllowance - 1
        steps = steps + 1
        ant:walk()
        if math.max(math.abs(ant.x), math.abs(ant.y)) > 100 then
            boundsTimeout = boundsTimeout + 1
        else
            boundsTimeout = 0
        end
        if steps > 20000 or boundsTimeout > 1000 then
            steps = 0
            stepAllowance = 0
            boundsTimeout = 0
            randomizeMoves()
            pixels.data={}
            ant = Ant:new()
        end
    end
end

function love.load()
    love.window.setMode(1000, 1000, {
        resizable = true
    })
end
