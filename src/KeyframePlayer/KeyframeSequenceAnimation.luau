-- Copyright (c) 2024 RAMPAGE Interactive, all rights reserved.
-- Written by vq9o and Contributor(s)

-- GitHub: https://github.com/RAMPAGELLC/RBLXKeyframePlayer
-- License: MIT

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local types = require(script.Parent:WaitForChild("types"))
local GoodSignal = require(script.Parent:WaitForChild("GoodSignal"))

local DebugEnabled = true

local Animation = {}
Animation.__index = Animation

local function _debug(...)
	if RunService:IsStudio() and DebugEnabled then
		warn("KeyframePlayer Debug: ", ...)
	end
end

function Animation.new(humanoid: Humanoid, keyframeSequence: KeyframeSequence): types.KeyframeSequenceAnimation
	local self = setmetatable({}, Animation)
	self.Humanoid = humanoid
	self.Sequence = keyframeSequence

	-- Properties
	self.IsPlaying = false
	self.Looped = false
	self.Priority = keyframeSequence.Priority or 0
	self.Speed = 1
	self.TimePosition = 0
	self.WeightCurrent = 1
	self.WeightTarget = 1
	self.Length = self:GetSequenceLength()

	-- Event Signals
	self.MarkerReachedSignal = GoodSignal.new()
	self.DidLoopSignal = GoodSignal.new()
	self.EndedSignal = GoodSignal.new()
	self.StoppedSignal = GoodSignal.new()
	self.PausedSignal = GoodSignal.new()

	return self
end

-- Calculate the total length of the animation sequence
function Animation:GetSequenceLength(): number
	local maxTime = 0

	for _, keyframe in ipairs(self.Sequence:GetChildren()) do
		if keyframe:IsA("Keyframe") and keyframe.Time > maxTime then
			maxTime = keyframe.Time
		end
	end

	return maxTime
end

-- Resumes the animation from the current TimePosition
function Animation:Resume()
	if not self.IsPlaying then
		self.IsPlaying = true
		self:Play(nil, self.WeightCurrent, self.Speed)
	end
end

-- Pauses the animation without resetting TimePosition
function Animation:Pause()
	self.IsPlaying = false
	self.PausedSignal:Fire()
end

-- Adjusts the speed of the animation playback
function Animation:AdjustSpeed(newSpeed: number)
	if newSpeed > 0 then
		self.Speed = newSpeed
	end
end

-- Adjusts the weight with optional fadeTime
function Animation:AdjustWeight(weight: number, fadeTime: number?)
	self.WeightTarget = weight

	-- Interpolate WeightCurrent to WeightTarget if fadeTime provided
	if fadeTime then
		local startWeight = self.WeightCurrent
		local endTime = tick() + fadeTime

		while tick() < endTime and self.IsPlaying do
			local elapsed = math.min(1, (fadeTime - (endTime - tick())) / fadeTime)
			self.WeightCurrent = startWeight + ((weight - startWeight) * elapsed)
			RunService.Heartbeat:Wait()
		end
	else
		self.WeightCurrent = weight
	end
end
-- Returns the time of a keyframe by name
function Animation:GetTimeOfKeyframe(keyFrameName: string): number
	for _, keyframe in ipairs(self.Sequence:GetChildren()) do
		if keyframe.Name == keyFrameName then
			return keyframe.Time
		end
	end

	return 0
end

-- Event signals
function Animation:GetMarkerReachedSignal(name: string): types.GoodSignal
	return self.MarkerReachedSignal
end

function Animation:DidLoop(): types.GoodSignal
	return self.DidLoopSignal
end

function Animation:Ended(): types.GoodSignal
	return self.EndedSignal
end

function Animation:Stopped(): types.GoodSignal
	return self.StoppedSignal
end

function Animation:Paused(): types.GoodSignal
	return self.PausedSignal
end

function Animation:GetKeyframeAtTime(timePosition: number)
	local closestKeyframe = nil
	local closestTimeDifference = math.huge

	for _, keyframe in ipairs(self.Sequence:GetChildren()) do
		if keyframe:IsA("Keyframe") then
			local timeDifference = math.abs(keyframe.Time - timePosition)
			if timeDifference < closestTimeDifference then
				closestKeyframe = keyframe
				closestTimeDifference = timeDifference
			end
		end
	end

	return closestKeyframe
end

function Animation:Stop(fadeTime: number?)
	-- Default to Roblox's AnimationTrack fade out value if not provided
	fadeTime = fadeTime or 0.1

	if not self.IsPlaying then
		warn("Animation is not currently playing.")
		return
	end

	-- Set playback control to stop
	self.IsPlaying = false

	-- Use interpolation to smoothly fade out the animation
	local initialWeight = self.WeightCurrent
	local startTime = os.clock()
	local endTime = startTime + fadeTime

	coroutine.wrap(function()
		while os.clock() < endTime do
			local alpha = (os.clock() - startTime) / fadeTime
			self.WeightCurrent = initialWeight * (1 - alpha)
			RunService.Heartbeat:Wait()
		end
		self.WeightCurrent = 0
		self.StoppedSignal:Fire()
	end)()
end

-- Plays the animation with optional fadeTime, weight, and speed parameters
function Animation:Play(fadeTime: number?, weight: number?, speed: number?)
	-- Default to Roblox's AnimationTrack values if not provided
	fadeTime = fadeTime or 0.1 -- Default fade time for animations in Roblox
	weight = weight or 1.0 -- Default weight to fully blend the animation
	speed = speed or 1.0 -- Default playback speed

	if self.IsPlaying then
		warn("Animation is already playing.")
		return
	end

	-- Set playback controls with defaults
	self.IsPlaying = true
	self.Speed = speed
	self.WeightTarget = weight
	self.WeightCurrent = 0 -- Start from 0 to fade in

	-- Use interpolation to smoothly fade in the animation
	local initialWeight = self.WeightCurrent
	local startTime = os.clock()
	local endTime = startTime + fadeTime

	coroutine.wrap(function()
		while os.clock() < endTime and self.IsPlaying do
			local alpha = (os.clock() - startTime) / fadeTime
			self.WeightCurrent = initialWeight + (weight - initialWeight) * alpha
			self.TimePosition = self.TimePosition + (self.Speed * RunService.Heartbeat:Wait())
			self:ApplyInterpolatedPose(
				self.Humanoid,
				self:GetKeyframeAtTime(self.TimePosition),
				self:GetNextKeyframe(self:GetKeyframeAtTime(self.TimePosition)),
				alpha
			)
		end
		self.WeightCurrent = weight
		self:ApplyPose(self.Humanoid, self:GetKeyframeAtTime(self.TimePosition))
		self.MarkerReachedSignal:Fire("Play")

		-- Continue playback after fade-in
		while self.IsPlaying and self.TimePosition < self.Length do
			local nextKeyframe = self:GetNextKeyframe(self:GetKeyframeAtTime(self.TimePosition))
			if nextKeyframe then
				local waitTime = (nextKeyframe.Time - self.TimePosition) / math.abs(self.Speed)
				if waitTime > 0 then
					task.wait(waitTime)
				end
				self.TimePosition = nextKeyframe.Time
				self:ApplyPose(self.Humanoid, nextKeyframe)

				-- Fire marker signal if keyframe has markers
				for _, marker in ipairs(nextKeyframe:GetChildren()) do
					if marker:IsA("Marker") then
						self.MarkerReachedSignal:Fire(marker.Name)
					end
				end
			else
				break
			end

			-- Handle looping
			if self.Looped and self.TimePosition >= self.Length then
				self.DidLoopSignal:Fire()
				self.TimePosition = 0
			end

			RunService.Heartbeat:Wait() -- Yield each frame to avoid time exhaustion
		end

		-- Fire Ended signal when animation finishes without looping
		if not self.Looped then
			self:Stop()
			self.EndedSignal:Fire()
		end
	end)()
end

function Animation:ApplyPose(humanoid: Humanoid, keyframe)
	if not keyframe then
		warn("No valid keyframe found at this time position.")
		return
	end

	for _, pose in ipairs(keyframe:GetChildren()) do
		if pose:IsA("Pose") then
			local part = humanoid.Parent:FindFirstChild(pose.Name)
			if part and part:IsA("BasePart") then
				if part.Name == "HumanoidRootPart" then
					continue;
				end
				
				-- Find the correct Motor6D that connects to this part
				local motor = nil
				for _, descendant in ipairs(humanoid.Parent:GetDescendants()) do
					if descendant:IsA("Motor6D") and descendant.Part1 == part then
						motor = descendant
						break
					end
				end

				-- Apply the pose to the Motor6D
				if motor then
					motor.Transform = pose.CFrame
					_debug("Applied pose to motor:", motor.Name, "for part:", part.Name)
				else
					warn("Motor6D not found for part: " .. part.Name)
				end
			else
				warn("Part not found or not a BasePart: " .. tostring(pose.Name))
			end
		end
	end
end

function Animation:GetNextKeyframe(currentKeyframe)
	local nextKeyframe = nil
	for _, keyframe in ipairs(self.Sequence:GetChildren()) do
		if keyframe:IsA("Keyframe") and keyframe.Time > currentKeyframe.Time then
			if not nextKeyframe or keyframe.Time < nextKeyframe.Time then
				nextKeyframe = keyframe
			end
		end
	end
	return nextKeyframe
end

function Animation:ApplyInterpolatedPose(humanoid: Humanoid, currentKeyframe, nextKeyframe, alpha)
	if not currentKeyframe or not nextKeyframe then
		self:ApplyPose(humanoid, currentKeyframe or nextKeyframe)
		return
	end

	for _, currentPose in ipairs(currentKeyframe:GetChildren()) do
		if currentPose:IsA("Pose") then
			local nextPose = nextKeyframe:FindFirstChild(currentPose.Name)
			if nextPose and nextPose:IsA("Pose") then
				local part = humanoid.Parent:FindFirstChild(currentPose.Name)
				if part and part:IsA("BasePart") then
					local motor = nil
					for _, descendant in ipairs(humanoid.Parent:GetDescendants()) do
						if descendant:IsA("Motor6D") and descendant.Part1 == part then
							motor = descendant
							break
						end
					end

					if motor then
						local interpolatedCFrame = currentPose.CFrame:Lerp(nextPose.CFrame, alpha)
						motor.Transform = interpolatedCFrame
						_debug("Interpolated pose applied to motor:", motor.Name, "for part:", part.Name)
					else
						warn("Motor6D not found for part: " .. part.Name)
					end
				else
					warn("Part not found or not a BasePart: " .. tostring(currentPose.Name))
				end
			end
		end
	end
end

return Animation
