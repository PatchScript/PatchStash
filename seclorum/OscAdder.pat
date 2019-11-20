local noteNum = synth:addParameter("_polyNote", 0.0)
local gate = synth:addParameter("_polyGate", 0.0)
local noteVelocity = synth:addParameter("_polyVelocity", 0.0)
local voiceNumber = synth:addParameter("_polyVoiceNumber", 0.0)

local volume = synth:addParameter("Global.Volume", 0.5)
local attack = synth:addParameter("Global.Attack",0.1)
local decay = synth:addParameter("Global.Decay", 0 )
local sustain = synth:addParameter("Global.Sustain",1)
local release = synth:addParameter("Global.Release",0.1)

local lpCutoff = synth:addParameter("Filter.LP_Freq", 1.0)
local lpQ = synth:addParameter("Filter.LP_Q", 0.0)
local hpCutoff = synth:addParameter("Filter.HP_Freq", 0.0)
local hpQ = synth:addParameter("Filter.HP_Q", 0.0)

local voiceFreq = ControlMidiToFreq():input(noteNum)

function makeOSC(index, total, voiceFreq)
  local gain = synth:addParameter("Oscillator" .. index .. ".Gain", 1.0)
  local sine = synth:addParameter("Oscillator" .. index .. ".Sine", 0)
  local sineP = synth:addParameter("Oscillator" .. index .. ".SinePitch", 1.0 - (0.01 * (index / total)))
  local square = synth:addParameter("Oscillator" .. index .. ".Square", 0)
  local squareP = synth:addParameter("Oscillator" .. index .. ".SquarePitch", 1.0 - (0.01 * (index / total)))
  local triangle = synth:addParameter("Oscillator" .. index .. ".Triangle", 1.0)
  local triangleP = synth:addParameter("Oscillator" .. index .. ".TrianglePitch", 1.0 - (0.01 * (index / total)))
  return (
           (SineWave():freq(voiceFreq * sineP) * sine) +
           (SquareWave():freq(voiceFreq * squareP) * square) +
           (TriangleWave():freq(voiceFreq * triangleP) * triangle)
         ) * 0.33 * gain
end

local mix = Adder();
for i=1,10 do
	mix = mix + makeOSC(i,10,voiceFreq)     
end

local lpf = LPF24()
	:cutoff(FixedValue(10000) * lpCutoff)
	:Q(FixedValue(20) * lpQ)

local hpf = HPF24()
	:cutoff(FixedValue(10000) * hpCutoff)
	:Q(FixedValue(20) * hpQ)

local env = ADSR()
	:attack(attack)
	:decay(decay)
	:sustain(sustain)
	:release(release)
	:doesSustain(1)
	:trigger(gate)

synth:setOutputGen(((hpf:input(lpf:input(mix)) * env)
  * (FixedValue(0.02) + noteVelocity * 0.005)) * volume);


