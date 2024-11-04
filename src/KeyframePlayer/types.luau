-- Copyright (c) 2024 RAMPAGE Interactive, all rights reserved.
-- Written by vq9o and Contributor(s)

-- GitHub: https://github.com/RAMPAGELLC/RBLXKeyframePlayer
-- License: MIT

export type void = nil;

export type GoodSignal = {
	Fire: (...any) -> (),
	Connect: (self: GoodSignal, handler: (...any) -> ()) -> GoodSignalConnection,
	Wait: (self: GoodSignal) -> ...any,
}

export type GoodSignalConnection = {
	Disconnect: (self: GoodSignalConnection) -> ()
}

export type KeyframeSequenceAnimation = {
	-- Properties
	IsPlaying: boolean,
	Length: number,
	Looped: boolean,
	Priority: number,
	Speed: number,
	TimePosition: number,
	WeightCurrent: number,
	WeightTarget: number,

	-- Event Signals
	MarkerReachedSignal: GoodSignal,
	DidLoopSignal: GoodSignal,
	EndedSignal: GoodSignal,
	StoppedSignal: GoodSignal,
	PausedSignal: GoodSignal,

	-- Methods
	new: (humanoid: Humanoid, keyframeSequence: KeyframeSequence) -> KeyframeSequenceAnimation;
	Play: (self: KeyframeSequenceAnimation, fadeTime: number?, weight: number?, speed: number?) -> (),
	Resume: (self: KeyframeSequenceAnimation) -> (),
	Stop: (self: KeyframeSequenceAnimation) -> (),
	Pause: (self: KeyframeSequenceAnimation) -> (),
	AdjustSpeed: (self: KeyframeSequenceAnimation, newSpeed: number) -> (),
	AdjustWeight: (self: KeyframeSequenceAnimation, weight: number, fadeTime: number?) -> (),
	GetTimeOfKeyframe: (self: KeyframeSequenceAnimation, keyFrameName: string) -> number,
	GetMarkerReachedSignal: (self: KeyframeSequenceAnimation, name: string) -> GoodSignal,
	DidLoop: (self: KeyframeSequenceAnimation) -> GoodSignal,
	Ended: (self: KeyframeSequenceAnimation) -> GoodSignal,
	Stopped: (self: KeyframeSequenceAnimation) -> GoodSignal,
	Paused: (self: KeyframeSequenceAnimation) -> GoodSignal,
	ApplyPose: (self: KeyframeSequenceAnimation, humanoid: Humanoid, keyframe: Keyframe) -> ();
    GetKeyframeAtTime: (timePosition: number) -> Keyframe?;
    GetSequenceLength: () -> number
}

return {};