-- Copyright (c) 2024 RAMPAGE Interactive, all rights reserved.
-- Written by vq9o and Contributor(s)

-- GitHub: https://github.com/RAMPAGELLC/RBLXKeyframePlayer
-- License: MIT

local types = require(script:WaitForChild("types"));
local KeyframeSequenceAnimation = require(script:WaitForChild("KeyframeSequenceAnimation"))

local KeyframePlayer = {}

function KeyframePlayer:LoadAnimation(humanoid: Humanoid, keyframeSequence: KeyframeSequence): types.KeyframeSequenceAnimation
    return KeyframeSequenceAnimation.new(humanoid, keyframeSequence)
end

return KeyframePlayer