local animator_ = {
    images = {},
    states = {},
    timer = 0,
    interval = 0,
    position = 0,
    currentState = ""
}

function animator_:new(file)
    local object = {}
    setmetatable(object, {__index = animator_})
    local data = require(file)
        for name, image in pairs(data.images) do
        object.images[name] = love.graphics.newImage(image)
    end

    for name, state in pairs(data.states) do
        state.offsetX, state.offsetY = state.offsetX or 0, state.offsetY or 0

        local quad = {}
        for i = 1, state.frameCount do
            table.insert(quad, love.graphics.newQuad(state.offsetX + (i - 1)*state.frameWidth, state.offsetY, state.frameWidth, state.frameHeight, object.images[state.image]))
        end

        object.states[name] = {
            image = state.image,
            quad = quad,
            playMode = state.playMode or "looping",
            delay = state.delay,
            event = {},
            paused = false
        }
    end

    object.event_ = {}
    object.currentState = data.defaultState
    object.interval = object.states[object.currentState].delay
    if object.states[object.currentState].playMode == "reversing" then object.position = #object.states[object.currentState].quad + 1 end
    return object
end

function animator_:update(dt)
    self.timer = self.paused and self.timer or (self.timer - dt)
    if self.timer <= 0 then
        self.timer = self.timer + self.interval

        local state = self.states[self.currentState]
        self.position = self.position + 1*((state.playMode == "looping") and 1 or -1)
        if self.position == 0 then
            self.position = #state.quad
        elseif self.position > #state.quad then
            self.position = 1
        end

        for _, event in pairs(state.event) do
            if event.frame == self.position then table.insert(self.event_, {timer = event.delay, callback = event.callback}) end
        end
    end

    for i, event in ipairs(self.event_) do
        event.timer = event.timer - dt
        if event.timer <= 0 then
            event.callback()
            table.remove(self.event_, i)
        end
    end
end

function animator_:draw(x, y, r, sx, sy, ox, oy)
    local state = self.states[self.currentState]
    love.graphics.draw(self.images[state.image], state.quad[self.position], x, y, r, sx, sy, ox, oy)
end

function animator_:setEvent(frame, state, name, delay)
    delay = delay or 0

    self.states[state].event[name] = {
        frame = frame,
        delay = delay,
        callback = function() end
    }
    
    return self
end

function animator_:on(state, name, callback)
    self.states[state].event[name].callback = callback
end

function animator_:setState(state, frame)
    frame = frame or 1

    self.currentState = state
    self.position = frame
    self.timer = 0
    self.interval = self.states[state].delay
end

function animator_:pause() self.paused = true end
function animator_:resume() self.paused = false end
function animator_:getState(state) return self.currentState end
function animator_:getStateFrame() return self.states[self.currentState].quad[self.position] end

local keyframe = {}

function keyframe.new(file)
    return animator_:new(file)
end

return keyframe