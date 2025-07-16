--[[

MIT License

Copyright (c) 2025 Karyl

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]

local animator_ = {}

function animator_:new(file)
    local object = {
        images = {},
        states = {},
        timer = 0,
        interval = 0,
        position = 0,
        currentState = "",
        locked = false
    }
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
    setmetatable(object, {__index = animator_})
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

function animator_:lock() self.locked = true end
function animator_:unlock() self.locked = false end

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
    if self.locked then return end

    self.currentState = state

    if frame then
        self.position = frame
        self.timer = 0
        self.interval = self.states[state].delay
    end
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
