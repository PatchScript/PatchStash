local noteNum = synth:addParameter("_polyNote", 0.0);
local gate = synth:addParameter("_polyGate", 0.0);
local noteVelocity = synth:addParameter("_polyVelocity", 0.0);
local voiceNumber = synth:addParameter("_polyVoiceNumber", 0.0);

local gain = synth:addParameter("Global.Gain", 0.5)

local gain0 = synth:addParameter("OSC0.Gain", 0.5)
local sine0 = synth:addParameter("OSC0.Sine", 1.0);
local square0 = synth:addParameter("OSC0.Square", 1.0);
local triangle0 = synth:addParameter("OSC0.Triangle", 1.0);
local sineP0 = synth:addParameter("OSC0.SinePitch", 1.0);
local squareP0 = synth:addParameter("OSC0.SquarePitch", 1.0);
local triangleP0 = synth:addParameter("OSC0.TrianglePitch", 1.0);

local gain1 = synth:addParameter("OSC1.Gain", 0.5)
local sine1 = synth:addParameter("OSC1.Sine", 1.0);
local square1 = synth:addParameter("OSC1.Square", 1.0);
local triangle1 = synth:addParameter("OSC1.Triangle", 1.0);
local sineP1 = synth:addParameter("OSC1.SinePitch", 1.0);
local squareP1 = synth:addParameter("OSC1.SquarePitch", 1.0);
local triangleP1 = synth:addParameter("OSC1.TrianglePitch", 1.0);

local lpCutoff = synth:addParameter("LowPass.Frequency", 1.0);
local lpQ = synth:addParameter("LowPass.Resonance", 1.0);
local hpCutoff = synth:addParameter("HighPass.Frequency", 1.0);
local hpQ = synth:addParameter("HighPass.Resonance", 1.0);
local lfoAmpFreq = synth:addParameter("LfoAmp.Frequency", 1.0);
local lfoPitchFreq = synth:addParameter("LfoPitch.Frequency", 1.0);

local voiceFreq = ControlMidiToFreq():input(noteNum)

local lfoAmp = SineWave():freq(lfoAmpFreq * 10)
local lfoPitch = SineWave():freq(lfoPitchFreq * 10)

local osc0 = (
  					(SineWave():freq(lfoPitch * voiceFreq * sineP0) * sine0) +
  					 (SquareWave():freq(lfoPitch * voiceFreq * squareP0) * square0) +
  					 (TriangleWave():freq(lfoPitch * voiceFreq * triangleP0) * triangle0)
					) * 0.3 * gain0 * lfoAmp * gain;

local osc1 = (
  					(SineWave():freq((FixedValue(1.0) - lfoPitch) * voiceFreq * sineP1) * sine1) +
  					 (SquareWave():freq((FixedValue(1.0) - lfoPitch) * voiceFreq * squareP1) * square1) +
  					 (TriangleWave():freq((FixedValue(1.0) - lfoPitch) * voiceFreq * triangleP1) * triangle1)
					) * 0.3 *  gain1 * lfoAmp * gain;


local mix = (osc0 + osc1) * 0.5;

local lpf = LPF24():cutoff(FixedValue(10000) * lpCutoff):Q(FixedValue(20) * lpQ)
local hpf = HPF24():cutoff(FixedValue(10000) * hpCutoff):Q(FixedValue(20) * hpQ)

local env = ADSR()
:attack(synth:addParameter("Envelope.Attack",0.1))
:decay(synth:addParameter("Envelope.Decay", 0 ))
:sustain(synth:addParameter("Envelope.Sustain",1))
:release(synth:addParameter("Envelope.Release",0.1))
:doesSustain(1)
:trigger(gate)

synth:setOutputGen((hpf:input(lpf:input(mix)) * env)
  * (FixedValue(0.02) + noteVelocity * 0.005));

