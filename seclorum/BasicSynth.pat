local noteNum = synth:addParameter("_polyNote", 0.0);
local gate = synth:addParameter("_polyGate", 0.0);
local noteVelocity = synth:addParameter("_polyVelocity", 0.0);
local voiceNumber = synth:addParameter("_polyVoiceNumber", 0.0);
local gain = synth:addParameter("Global.Gain", 0.5)
local sine = synth:addParameter("Global.Sine", 1.0);
local square = synth:addParameter("Global.Square", 1.0);
local sineP = synth:addParameter("Global.SinePitch", 1.0);
local squareP = synth:addParameter("Global.SquarePitch", 1.0);
local lpCutoff = synth:addParameter("LowPass.Frequency", 1.0);
local lpQ = synth:addParameter("LowPass.Resonance", 1.0);
local hpCutoff = synth:addParameter("HighPass.Frequency", 1.0);
local hpQ = synth:addParameter("HighPass.Resonance", 1.0);
local lfoFreq = synth:addParameter("LFO.Frequency", 1.0);
local lfoWet = synth:addParameter("LFO.Wet", 1.0);
local lfoDry = synth:addParameter("LFO.Dry", 1.0);


local voiceFreq = ControlMidiToFreq():input(noteNum)

local lfo = SineWave():freq(lfoFreq * 100)

local tone0 = SineWave():freq(voiceFreq * sineP) * sine * gain
local tone1 = SquareWave():freq(voiceFreq * squareP) * square * gain

local tone0LFO = tone0 * lfo
local tone1LFO = tone1 * (FixedValue(1.0) - lfo)

local tone0mix = ((tone0 * lfoDry) + (tone0LFO * lfoWet)) * 0.5
local tone1mix = ((tone1 * lfoDry) + (tone1LFO * lfoWet)) * 0.5

local mix = (tone0mix + tone1mix) * 0.5;

local lpf = LPF24():cutoff(FixedValue(10000) * lpCutoff):Q(FixedValue(20) * lpQ)
local hpf = HPF24():cutoff(FixedValue(10000) * hpCutoff):Q(FixedValue(20) * hpQ)

local env = ADSR()
:attack(synth:addParameter("Envelope.Attack1",0.1))
:decay(synth:addParameter("Envelope.Decay", 0 ))
:sustain(synth:addParameter("Envelope.Sustain",1))
:release(synth:addParameter("Envelope.Release",0.1))
:doesSustain(1)
:trigger(gate)

synth:setOutputGen((hpf:input(lpf:input(mix)) * env)
  * (FixedValue(0.02) + noteVelocity * 0.005));

