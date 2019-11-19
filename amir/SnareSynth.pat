local noteNum = synth:addParameter("_polyNote", 0.0)
local gate = synth:addParameter("_polyGate", 0.0)
local noteVelocity = synth:addParameter("_polyVelocity", 0.0)
local voiceNumber = synth:addParameter("_polyVoiceNumber", 0.0)

local threshold = synth:addParameter("Global.threshold", -12):displayName("Threshold (dbFS)"):min(-60):max(0);
local ratio = synth:addParameter("Global.ratio", 2.0):displayName("Ratio"):min(1.0):max(64):logarithmic(1);
local attack = synth:addParameter("Global.attackTime", 0.001):displayName("Attack Time (s)"):min(0.001):max(0.1):logarithmic(true);
local release = synth:addParameter("Global.releaseTime", 0.05):displayName("Release Time (s)"):min(0.01):max(0.08):logarithmic(true);
local gain = synth:addParameter("Global.gain", 0):displayName( "Makeup Gain (dbFS)"):min(0):max(36);
local bypass = synth:addParameter("Global.bypass",0):parameterType(1);

local freq = ControlMidiToFreq():input(noteNum)

local hpNoise = LPF12():cutoff(8000.0):input(HPF24():cutoff(2000.0):input(Noise() * dBToLin(-18.0)));
local tones = SineWave():freq(freq) * dBToLin(-6.0) + SineWave():freq(freq * 2) * dBToLin(-18.0);

local toneADSR = ADSR()
  :attack(0.0005)
  :decay(0.03)
  :sustain(0,0)
  :release(0.01)
  :trigger(gate);
local noiseADSR = ADSR()
  :attack(0.001)
  :decay(0.25)
  :sustain(0,0)
  :release(0.25)
  :trigger(gate)

local noiseEnv = noiseADSR * noiseADSR;

local compressor = Compressor()
                        :attack(attack)
                        :release(0.06)
                        :threshold( ControlDbToLinear():input(threshold) )
                        :ratio( ratio )
                        :lookahead(0.001)
                        :makeupGain(ControlDbToLinear():input(gain))
                        :bypass(bypass);

local outputGen = compressor:input( ( tones * toneADSR ) + ( hpNoise * noiseEnv ) ) * 0.5;

synth:setOutputGen(outputGen);