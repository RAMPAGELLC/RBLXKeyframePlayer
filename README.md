# RBLXKeyframePlayer
**Experimental Project Notice**: This project is currently experimental and incomplete. There might be issues or unimplemented features. Use it at your own risk.

## Overview
KeyframePlayer is a Luau-based utility that provides functionality to play custom keyframe sequences in Roblox. It attempts to replicate some aspects of the AnimationTrack behavior in Roblox, but allows for greater flexibility and customization.

KeyframePlayer can be used to play sequences of animations using keyframes, where each keyframe represents a specific pose for a humanoid character. It features custom play controls, including playback speed, fade-in/out, and looping support.

### Features
- Play custom keyframe sequences.
- Adjustable speed and weight for animations.
- Ability to pause, resume, and stop animations.
- Experimental support for interpolating poses between keyframes.
- Custom signals for tracking events like animation ended, stopped, looped, etc.

## Installation
Include the `KeyframePlayer` module in your Roblox project, and require it wherever you need to create and play keyframe sequences for a humanoid.

```lua
local KeyframePlayer = require(path.to.KeyframePlayer)
```

## Creating an Animation
To create an animation instance, call `KeyframePlayer.new()` with a `Humanoid` and a `KeyframeSequence` as arguments:

```lua
local animation = KeyframePlayer.new(humanoid, keyframeSequence)
```

## Methods and Usage
### `Animation.new(humanoid: Humanoid, keyframeSequence: KeyframeSequence)`
**Description**: Creates a new fake `Animation` instance / replica.

**Arguments**:
- `humanoid`: The `Humanoid` object to which the animation will be applied.
- `keyframeSequence`: A `KeyframeSequence` containing the keyframes for the animation.

### `Animation:Play(fadeTime: number?, weight: number?, speed: number?)`
**Description**: Plays the animation with optional parameters for fade-in time, weight, and playback speed.

**Arguments**:
- `fadeTime` (optional): How long the fade-in should take (defaults to `0.1`).
- `weight` (optional): The blend weight for the animation (defaults to `1.0`).
- `speed` (optional): The speed at which to play the animation (defaults to `1.0`).

**Example**:
```lua
animation:Play(0.5, 1.0, 1.2)
```

### `Animation:Stop(fadeTime: number?)`
**Description**: Stops the animation with an optional fade-out time.

**Arguments**:
- `fadeTime` (optional): Duration for the fade-out effect (defaults to `0.1`).

**Example**:
```lua
animation:Stop(0.5)
```

### `Animation:Pause()`
**Description**: Pauses the animation playback.

**Example**:
```lua
animation:Pause()
```

### `Animation:Resume()`
**Description**: Resumes the animation from its current `TimePosition`.

**Example**:
```lua
animation:Resume()
```

### `Animation:AdjustSpeed(newSpeed: number)`
**Description**: Adjusts the speed of the animation.

**Arguments**:
- `newSpeed`: The new speed value for the animation (must be greater than `0`).

**Example**:
```lua
animation:AdjustSpeed(1.5)
```

### `Animation:AdjustWeight(weight: number, fadeTime: number?)`
**Description**: Adjusts the blending weight of the animation, with optional fade time.

**Arguments**:
- `weight`: The target weight for blending.
- `fadeTime` (optional): Duration to interpolate to the new weight.

**Example**:
```lua
animation:AdjustWeight(0.8, 0.3)
```

### `Animation:GetTimeOfKeyframe(keyFrameName: string): number`
**Description**: Retrieves the time position of a keyframe by its name.

**Arguments**:
- `keyFrameName`: The name of the keyframe to look for.

**Returns**: The time position of the keyframe or `0` if not found.

**Example**:
```lua
local time = animation:GetTimeOfKeyframe("JumpKeyframe")
```

### Event Signals (RBXScriptSignal's replica)
The following signals are available for tracking animation events:
- **MarkerReached**: Fires when a marker within the keyframe is reached.
- **DidLoop**: Fires when the animation loops.
- **Ended**: Fires when the animation ends naturally.
- **Stopped**: Fires when the animation is stopped manually.
- **Paused**: Fires when the animation is paused.

**Example**:
```lua
animation.Ended:Connect(function()
    print("Animation has ended!")
end)
```

## Known Issues and Limitations
- The interpolation logic between keyframes is still experimental and may not work as expected in all cases.
- Currently, only certain types of keyframe attributes (like `CFrame` for `Motor6D`) are supported.
- This implementation does not fully support all features available in Roblox's built-in AnimationTracks.

## Contribution
This project is open for contributions. Feel free to create a pull request or raise an issue on the GitHub repository.

## License
This project is licensed under the MIT License. See `LICENSE` for details.

