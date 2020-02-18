/**
Functional example of using TrillRaw UGen.
(C) 2019 Jonathan Reus
(C) 2020 Rafaele Andrade

**/
s = Server.default;

s.options.numAnalogInChannels = 8; // can be 2, 4 or 8
s.options.numAnalogOutChannels = 8; // can be 2, 4 or 8
s.options.numDigitalChannels = 16;
s.options.maxLogins = 8;

s.options.pgaGainLeft = 5;     // sets the pregain for the left audio input (dB)
s.options.pgaGainRight = 5;    // sets the pregain for the right audio input (dB)
s.options.headphoneLevel = -1; // sets the headphone level (-dB)
s.options.speakerMuted = 1;    // set true to mute the speaker amp and draw a little less power
s.options.dacLevel = 0;       // sets the gain of the analog dac to (dB)
s.options.adcLevel = 0;       // sets the gain of the analog adc to (dB)

s.options.blockSize = 16;
s.options.numInputBusChannels = 10;
s.options.numOutputBusChannels = 2;


s.waitForBoot {
	~tr = {|t_updateTrill = 1.0|
	var numTouchPads = 26;
	var i2c_bus = 1; // I2C bus to use on BeagleBone, usually you want this to be 1
	var i2c_address = 0x18; // I2C address of Trill sensor
	var noiseThresh = 10; // noise threshold, int: 5-255 (255=highest threshold)
	var prescalerOpt = 4; // sensitivity option, int: 0-4 (!!!!!!!!!!!!!0=highest sensitivity, play with this for complex Trill Craft setups)
	var rawvals;
	var sig, ping,d1, gt, pc,ch ,step,t_trig_1;
	var ch1,pc1,gt1,step1,	t_trig_2 ;
	var ch2,pc2,gt2,step2,	t_trig_3 ;
	var ch3,pc3,gt3,step3,	t_trig_4 ;
	var mode ,	ch6,gt6;
	var lp0,lp1,lp2,lp3;
	
	rawvals = TrillRaw.kr(i2c_bus, i2c_address, noiseThresh, prescalerOpt, t_updateTrill);
	
	//-------------------------------------------------------- start-to-start interval button 
	ch = Trig.kr(Changed.kr(rawvals[1]),0.1);
	gt = Trig.kr(Changed.kr(ch),0.1); //attenuate the reset
	pc = Stepper.kr(Impulse.kr(10), gt,0.0,80);  //attenuate the data input
	
	 
	ch1 = Trig.kr(Changed.kr(rawvals[2]),0.1);
	gt1 = Trig.kr(Changed.kr(ch1),0.1); //attenuate the reset
	pc1 = Stepper.kr(Impulse.kr(10), gt1,0.0,80);  //attenuate the data input
	

	ch2 = Trig.kr(Changed.kr(rawvals[7]),0.1);
	gt2 = Trig.kr(Changed.kr(ch2),0.1); //attenuate the reset
	pc2 = Stepper.kr(Impulse.kr(10), gt2,0.0,80);  //attenuate the data input
	
	
	ch3 = Trig.kr(Changed.kr(rawvals[4]),0.1);
	gt3 = Trig.kr(Changed.kr(ch3),0.1); //attenuate the reset
	pc3 = Stepper.kr(Impulse.kr(10), gt3,0.0,80);  //attenuate the data input
	
	
	//--------------------------------------------------------counter button
	
	step = PulseCount.kr(ch, Impulse.kr(0.17));
	step1 = PulseCount.kr(ch1, Impulse.kr(0.17));
	step2 = PulseCount.kr(ch2, Impulse.kr(0.17));
	step3 = PulseCount.kr(ch3, Impulse.kr(0.17));
	
	t_trig_1 = Changed.kr(PulseCount.kr(ch, Impulse.kr(0.8)));
	t_trig_2 = Changed.kr(PulseCount.kr(ch1, Impulse.kr(0.8)));
	t_trig_3 = Changed.kr(PulseCount.kr(ch2, Impulse.kr(0.8)));
	t_trig_4 = Changed.kr(PulseCount.kr(ch3, Impulse.kr(0.8)));
	
	
		
	// ----------------------------------------------------- modebutton
	ch6 = Trig.kr(Changed.kr(rawvals[6]),0.1);
	mode = Stepper.kr(ch6, 0,0, 2,1);


	//	-----------------------------------------------------Long Press button

		lp0 = Stepper.kr(ch,0,1,20,1);
		lp1 = Stepper.kr(ch1,0,1,20,1);
		lp2 = Stepper.kr(ch2,0,1,20,1);
		lp3 = Stepper.kr(ch3,0,1,20,1);
	
	
	// ----------------------------------------------------- OSCSEND
	SendReply.kr(t_trig_1, "/trill", [pc,step,mode, lp0],101);
	SendReply.kr(t_trig_2, "/trill", [pc1,step1,mode,lp1],102);
	SendReply.kr(t_trig_3, "/trill", [pc2,step2,mode,lp2],103);
	SendReply.kr(t_trig_4, "/trill", [pc3,step3,mode,lp3],104);
	

	
	
	sig = SinOsc.ar((1..numTouchPads) * 50, mul: Lag.kr(rawvals.linlin(0.0, 300, 0.0, 1.0), 0.1)) * 0.6;
	sig = Splay.ar(sig);
	sig = CombL.ar(sig.sum, 0.2, 0.2, 3.0, mul: 0.4) + sig;
	
	ping = EnvGen.ar(Env.perc, t_updateTrill) * SinOsc.ar(440);
	
	sig + ping;
	}.play;

	OSCdef(\trill, {|msg| 
var id = msg[2], interval = msg[3], count = msg[4],mode = msg[5], lp = msg[6];

msg[2..].postln;

if (id == 101) {
	
if(count == 2 && ~pm == nil,{   //~pm == nil
while ( { interval < 4.5 } && { interval > 3 }, { ~pm = 1; "boing".postln });  //&&{ interval > 2 }
})

}

		
		
	}, "/trill");
};
