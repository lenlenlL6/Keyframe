
# Keyframe

**Keyframe** is a lightweight and flexible animation system for Love2D, designed for frame-by-frame sprite animation with support for per-frame events, state transitions, and custom playback modes.

## ✨ Features

- Frame-based sprite animation  
- Multiple animation states  
- Custom event callbacks per frame  
- Looping & reversing playback  
- Easy to integrate  
- Animation data loaded from Lua file

## 📦 Installation

1. Download or clone the repo:
   ```bash
   git clone https://github.com/lenlenlL6/Keyframe.git
   ```

2. Add the `Keyframe/` folder to your Love2D project.

3. Require the module:
   ```lua
   local keyframe = require("Keyframe.keyframe")
   ```

## 🧠 Usage

### 💾 Example Animation Data File (`player.lua`)

```lua
return {
    images = {
        player = "assets/player.png"
    },
    states = {
        idle = {
            image = "player",
            offsetX = 0,
            offsetY = 0,
            frameWidth = 32,
            frameHeight = 32,
            frameCount = 4,
            delay = 0.2,
            playMode = "looping"
        }
    },
    defaultState = "idle"
}
```

### 🎮 Code Example

```lua
local keyframe = require("Keyframe.keyframe")
local playerAnim

function love.load()
    playerAnim = keyframe.new("assets/player")
    playerAnim:setEvent(2, "idle", "step", 0.05):on("idle", "step", function()
        print("Footstep sound here!")
    end)
end

function love.update(dt)
    playerAnim:update(dt)
end

function love.draw()
    playerAnim:draw(100, 100)
end
```

## 🔄 Methods

- `animator:update(dt)`
- `animator:draw(x, y, r, sx, sy, ox, oy)`
- `animator:setEvent(frame, state, name, delay)`
- `animator:on(state, name, callback)`
- `animator:setState(state, frame)`
- `animator:getState()`
- `animator:getStateFrame()`
- `animator:pause()`
- `animator:resume()`

## 📝 License

MIT License. Free to use and modify.

---

## 💬 Feedback / Contributions

Feel free to submit issues or pull requests.  
If you use this in your game, I’d love to see it!
