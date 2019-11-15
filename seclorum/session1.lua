math.randomseed(os.clock())

local noteNum = synth:addParameter("_polyNote", 0.0)
local gate = synth:addParameter("_polyGate", 0.0)
local noteVelocity = synth:addParameter("_polyVelocity", 0.0)
local voiceNumber = synth:addParameter("_polyVoiceNumber", 0.0)

function rando() 
	return math.random(0,100) * 0.1
end

print("rando 1:", rando())
print("rando 2:", rando())

local gain = synth:addParameter("OSC.Gain", rando())
local sine = synth:addParameter("OSC.Sine", 1.0)
local square = synth:addParameter("OSC.Square", 1.0)
local triangle = synth:addParameter("OSC.Triangle", 1.0)
local sineP = synth:addParameter("OSC.SinePitch", 1.0)
local squareP = synth:addParameter("OSC.SquarePitch", 1.0)
local triangleP = synth:addParameter("OSC.TrianglePitch", 1.0)
local lpCutoff = synth:addParameter("LP.Frequency", 1.0)
local lpQ = synth:addParameter("LP.Resonance", 0.2)
lpQ.min(0.2)
lpQ.max(0.5)
local hpCutoff = synth:addParameter("HP.Frequency", 1.0)
local hpQ = synth:addParameter("HP.Resonance", 1.0)
local lfoFreq = synth:addParameter("LFO.Frequency", 1.0)

local lfo = SineWave():freq(lfoFreq * 100)

local voiceFreq = ControlMidiToFreq():input(noteNum)
local tone0 = SineWave():freq(voiceFreq * sineP) * lfo
local tone1 = SquareWave():freq(voiceFreq * squareP) * (FixedValue(1.0) - lfo)
local tone2 = TriangleWave():freq(voiceFreq * triangleP)
local mix = ((tone0 * sine) + (tone1 * square) + (tone2 * triangle)) * 0.3 * gain;

local lpf = LPF24():cutoff(FixedValue(10000) * lpCutoff):Q(FixedValue(20) * lpQ)
local hpf = HPF24():cutoff(FixedValue(10000) * hpCutoff):Q(FixedValue(20) * hpQ)

local env = ADSR()
:attack(synth:addParameter("Envelope.Attack1",0.1))
:decay(synth:addParameter("Envelope.Decay", 0.5))
:sustain(synth:addParameter("Envelope.Sustain",8))
:release(synth:addParameter("Envelope.Release",0.2))
:doesSustain(1)
:trigger(gate)

synth:setOutputGen(
  					(hpf:input(lpf:input(mix)) * env)
  									* 
  					(FixedValue(0.02) + noteVelocity * 0.005)
  				)
