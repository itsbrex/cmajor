//======================================================
//
//                        Freeverb
//          Faster version using fixed delays (20% gain)
//
//======================================================

declare name "freeverb -- a Schroeder reverb";
declare author "Yann Orlarey";
declare version "1.0";

// Constant Parameters
//--------------------

fixedgain    = 0.015;
scalewet     = 3.0;
scaledry     = 2.0;
scaledamp    = 0.4;
scaleroom    = 0.28;
offsetroom   = 0.7;
initialroom  = 0.5;
initialdamp  = 0.5;
initialwet   = 1.0/scalewet;
initialdry   = 0;
initialwidth = 1.0;
initialmode  = 0.0;
freezemode   = 0.5;
stereospread = 23;
allpassfeed  = 0.5;

// Filter Parametres
//------------------

combtuningL1 = 1116;
combtuningL2 = 1188;
combtuningL3 = 1277;
combtuningL4 = 1356;
combtuningL5 = 1422;
combtuningL6 = 1491;
combtuningL7 = 1557;
combtuningL8 = 1617;

allpasstuningL1 = 556;
allpasstuningL2 = 441;
allpasstuningL3 = 341;
allpasstuningL4 = 225;

// Control Sliders
//--------------------
// Damp: high-frequency filtering of echoes (especially active for large RoomSize values)
// RoomSize: room size
// Dry: original signal
// Wet: signal with reverberation

dampSlider     = hslider("damp [knob:1]",0.5, 0, 1, 0.025)*scaledamp;
roomsizeSlider = hslider("roomsize [knob:2]", 0.9, 0, 1, 0.025)*scaleroom + offsetroom;
wetSlider      = hslider("wet [knob:3]", 0.9, 0, 1, 0.025);
drySlider      = hslider("dry", 0, 0, 1, 0.025);
combfeed       = roomsizeSlider;

// Comb and Allpass filters
//-------------------------

allpass(dt,fb) = (_,_ <: (*(fb),_:+:@(dt)), -) ~ _ : (!,_);
comb(dt, fb, damp) = (+:@(dt)) ~ (*(1-damp) : (+ ~ *(damp)) : *(fb));

// Reverb components
//------------------

monoReverb(fb1, fb2, damp, spread)
    = _ <: comb(combtuningL1+spread, fb1, damp),
        comb(combtuningL2+spread, fb1, damp),
        comb(combtuningL3+spread, fb1, damp),
        comb(combtuningL4+spread, fb1, damp),
        comb(combtuningL5+spread, fb1, damp),
        comb(combtuningL6+spread, fb1, damp),
        comb(combtuningL7+spread, fb1, damp),
        comb(combtuningL8+spread, fb1, damp)
        :>
          allpass (allpasstuningL1+spread, fb2)
        : allpass (allpasstuningL2+spread, fb2)
        : allpass (allpasstuningL3+spread, fb2)
        : allpass (allpasstuningL4+spread, fb2)
        ;

stereoReverb(fb1, fb2, damp, spread)
    = + <: monoReverb(fb1, fb2, damp, 0), monoReverb(fb1, fb2, damp, spread);

// fxctrl : add an input gain and a wet-dry control to a stereo FX
//----------------------------------------------------------------
fxctrl(g,w,Fx) = _,_ <: (*(g),*(g) : Fx : *(w),*(w)), *(1-w), *(1-w) :> _,_;

// Freeverb
//---------
freeverb = vgroup("freeverb", fxctrl(fixedgain, wetSlider, stereoReverb(combfeed, allpassfeed, dampSlider, stereospread)));

process = freeverb;
