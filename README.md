# Keyframe

**Keyframe** is a lightweight and flexible animation system for the LÖVE game engine. It's designed for creating data-driven, frame-by-frame sprite animations with support for multiple states, playback modes, and per-frame event callbacks.

## Features

-   Frame-based sprite animation
-   Multiple animation states
-   Custom event callbacks per frame
-   Looping & reversing playback modes
-   Data-driven animations from simple Lua files
-   Easy to integrate into any LÖVE project

## Installation

1.  Download `keyframe.lua` and add it to your project. For example, you can create a `libs` folder.
    ```
    my-love-project/
    ├── libs/
    │   └── keyframe.lua
    ├── main.lua
    └── conf.lua
    ```

2.  Require the module in your code:
    ```lua
    local keyframe = require("libs.keyframe")
    ```

## Usage

Create a Lua file that defines your animation data. This file will describe the spritesheets, animation states, and frame properties.

### 1. Create Animation Data (`player_anims.lua`)

This file returns a table containing the image paths and state definitions for an animated character.

```lua
-- player_anims.lua
return {
    -- A map of names to image file paths
    images = {
        player_sheet = "assets/player.png"
    },

    -- A map of animation states
    states = {
        idle = {
            image = "player_sheet",  -- Reference to the image declared above
            offsetX = 0,
            offsetY = 0,
            frameWidth = 32,
            frameHeight = 32,
            frameCount = 4,          -- Number of frames in this state
            delay = 0.2,             -- Time (in seconds) between frames
            playMode = "looping"     -- Can be "looping" or "reversing"
        },
        walk = {
            image = "player_sheet",
            offsetX = 0,
            offsetY = 32,            -- This animation starts on the second row of the spritesheet
            frameWidth = 32,
            frameHeight = 32,
            frameCount = 8,
            delay = 0.1,
            playMode = "looping"
        }
    },

    -- The default state to start with when the animator is created
    defaultState = "idle"
}
```

### 2. Use in Your Game (`main.lua`)

Load the animation data, update the animator in `love.update`, and draw it in `love.draw`. You can also attach event listeners to trigger actions on specific frames.

```lua
local keyframe = require("libs.keyframe")
local player

function love.load()
    -- Create a new animator by loading the data file
    player = keyframe.new("player_anims")

    -- Set up an event to fire on the 2nd frame of the "walk" animation
    -- We can use this to play a footstep sound, for example.
    player:setEvent(2, "walk", "step")
    player:on("walk", "step", function()
        print("Step!")
        -- love.audio.play(footstepSound)
    end)
end

function love.update(dt)
    -- Switch states based on input
    if love.keyboard.isDown("d") then
        player:setState("walk")
    else
        player:setState("idle")
    end

    -- Update the animator with the delta time
    player:update(dt)
end

function love.draw()
    love.graphics.print("Press 'd' to walk", 10, 10)
    
    -- Draw the player's current animation frame at position (100, 100)
    player:draw(100, 100)
end
```

## API Reference

### Creation
-   `keyframe.new(file)`
    Creates a new animator instance. Expects a path to a Lua data file (without the `.lua` extension).

### Core Loop
-   `animator:update(dt)`
    Updates the animation's timer and frame. Call this in `love.update(dt)`.
-   `animator:draw(x, y, r, sx, sy, ox, oy)`
    Draws the current animation frame. The arguments are passed directly to `love.graphics.draw`.

### State Management
-   `animator:setState(state, [frame])`
    Changes the current animation state. If the state is different from the current one, the animation resets. The optional `frame` argument can be used to start at a specific frame number.
-   `animator:getState()`
    Returns the name of the current animation state (e.g., `"idle"`).
-   `animator:getStateFrame()`
    Returns the LÖVE `Quad` for the currently displayed frame.
-   `animator:lock()`
    Prevents `setState` from changing the animation state until `unlock` is called. Useful for uninterruptible animations like attacks or dodges.
-   `animator:unlock()`
    Allows `setState` to change the animation state again.

### Playback Control
-   `animator:pause()`
    Pauses the animation timer. The animation will stop on the current frame.
-   `animator:resume()`
    Resumes a paused animation.

### Events
-   `animator:setEvent(frame, state, name, [delay])`
    Defines a named event that can be triggered.
    -   `frame`: The frame number (1-indexed) to trigger the event on.
    -   `state`: The animation state this event belongs to.
    -   `name`: A unique string to identify this event.
    -   `delay`: An optional delay in seconds before the callback fires.
-   `animator:on(state, name, callback)`
    Assigns a callback function to an event previously defined with `setEvent`. The callback will be executed when the event is triggered.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
