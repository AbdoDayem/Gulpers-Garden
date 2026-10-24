@import "smuck"

// Dear Alex and Ge, i sincerely apologize for all the magic numbers.
// They mean nothing. Everything is arbitrary. They are all the result of trial and error
// window size
1024 => int WINDOW_SIZE;
// y position of waveform
5 => float WAVEFORM_Y;
// width of waveform and spectrum display
4 => float DISPLAY_WIDTH;
// waterfall depth
16 => int WATERFALL_DEPTH;


// sun rays
32   => int   NUM_RAYS;     // number of rays
1.5  => float RAY_START;   // ray base position (they start at sun position)
1.8  => float RAY_LEN;     // total length of live ray + history
0.15 => float RAY_WIDTH;   // ray base thickness
0.5 => float RAY_DECAY;   // adjustable fade
16    => int   HIST_DEPTH;  // past snapssuns per ray

Rays rays --> GG.scene();
rays.pos( @(-5, 3.3, -0.1) );

//sky background color
GG.scene().backgroundColor(@(0.3, 0.6, 1.0));
// window title
GWindow.title( "sndpeek ripoff" );
// uncomment to fullscreen
GWindow.fullscreen();
// position camera
GG.scene().camera().posZ(8.0);

// 3D models
GModel faucet("objects/antique_water_faucet-reduced.obj") --> GG.scene();
GModel wall("objects/grungy_brick_wall.obj") --> GG.scene();
GModel grass("objects/patch_of_grass.obj") --> GG.scene();

grass.pos( @(0, -2, -3.7) );
grass.rotY( Math.PI / 2 );     
grass.sca( @(0.08, 0.08, 0.08) );

faucet.pos( @(3.6, 2.5, 0.0) );
faucet.rotY( Math.PI / 2 );     
faucet.sca( @(7.5, 7.5, 7.5) );

wall.pos( @(5.2, 4.0, -3.0) );
wall.rotY( Math.PI / 2);
wall.sca( @(2.5, 2.5, 2.5) );

// "sun"
GG.bloom(true);
GG.bloomPass().intensity(0.2);
GCircle sun --> GG.scene();
sun.pos(@(-5, 3.3));
sun.color( @(1.0, 0.55, 0.05) * 10.0 );
sun.sca(2);

// gulper 
GPlane gulp --> GG.scene();
gulp.colorMap( Texture.load("objects/gulper.png") );
gulp.pos( @(2.7, -1.8, 0.1) );
gulp.rotZ(Math.PI + Math.PI/4);

// waveform renderer
GLines fake2 --> GG.scene(); fake2.width(.27); //just for looks
GLines fake1 --> GG.scene(); fake1.width(.27); //just for looks
GLines waveform --> GG.scene(); waveform.width(.29);

// position the water streams
waveform.posX(2.6);
fake1.posX(2.6);
fake2.posX(2.6);

// the water stream colors
waveform.color( @(0.1, 0.4, 1) );
fake1.color( @(0, 0.2, 1) );
fake2.color( @(0.1, 0.3, 1) );

// i dont think these do anything but oh well
fake1.mat().transparent(true);
fake2.mat().transparent(true);

// a still line to cover up the glitch-iness
vec2 still[2];
@(0, -DISPLAY_WIDTH/2) => still[0];
@(0,  DISPLAY_WIDTH/2) => still[1];
fake2.positions(still);

// DONT TOUCH, SNDPEEK STUFF
// accumulate samples from mic
adc => Flip accum => blackhole;
// take the FFT
adc => PoleZero dcbloke => FFT fft => blackhole;
// set DC blocker
.95 => dcbloke.blockZero;
// set size of flip
WINDOW_SIZE => accum.size;
// set window type and size
Windowing.hann(WINDOW_SIZE) => fft.window;
// set FFT size (will automatically zero pad)
WINDOW_SIZE*2 => fft.size;
// get a reference for our window for visual tapering of the waveform
Windowing.hann(WINDOW_SIZE) @=> float window[];
// DONT TOUCH, SNDPEEK STUFF

// sample array
float samples[0];
// FFT response
complex response[0];
vec2 positions1[WINDOW_SIZE];
vec2 positions2[WINDOW_SIZE];

// Score
ezScore beat;
ezScore melody;
ezPart part1;
ezPart part2;
beat.add(part1);
melody.add(part2);
Gain ga => NRev rev => dac;
basicInst inst1 => ga;
basicInst inst2 => ga;
inst1 => accum; 
inst1 => fft;
inst2 => accum; 
inst2 => fft;

// Lord help me im not a musician
// I dont know what the tapping sound is but im lowkey rocking with it so its a feature not a bug
ezNote c24(0.0, 2.0, 48, 0.7);
ezNote d24(0.0, 2.0, 50, 0.7);
ezNote e24(2.0, 2.0, 52, 0.7);
ezNote f24(2.0, 2.0, 53, 0.7);

ezMeasure m1([c24, e24]);
ezMeasure m2([c24, e24]);
ezMeasure m3([c24, e24]);
ezMeasure m4([c24, e24]);
ezMeasure m5([d24, e24]);
ezMeasure m6([d24, e24]);
ezMeasure m7([d24, e24]);
ezMeasure m8([d24, e24]);
ezMeasure m9([c24, f24]);
ezMeasure m10([c24, f24]);
ezMeasure m11([c24, f24]);
ezMeasure m12([c24, f24]);
ezMeasure m13([d24, f24]);
ezMeasure m14([d24, f24]);
ezMeasure m15([d24, f24]);
ezMeasure m16([d24, f24]);
part1.add([m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16]);

ezScorePlayer player1(beat);
player1.instruments(0, inst1);
true => player1.loop;

ezNote fakenote(0.0, 4.0, 60, 0.0);
ezMeasure m0([fakenote]);
ezMeasure m00([fakenote]);
ezMeasure m000([fakenote]);
ezMeasure m0000([fakenote]);

// idk music theory, this is just trial and error
ezMeasure m17("c e e d");
ezMeasure m18("d c e f");
ezMeasure m19("e g g");
ezMeasure m20("e f f d");
ezMeasure m21("d c e f");
ezMeasure m22("e f f");
ezMeasure m23("e g g");
ezMeasure m24("c e e d");
part2.add([m0, m00, m000, m0000, m17, m18, m19, m20, m21, m22, m23, m24]);

ezScorePlayer player2(melody);
player2.instruments(0, inst2);
true => player2.loop;

// Ripped off from Smuck tutorial
class basicInst extends ezInstrument
{
    // Set up signal chain
    //--------------------------------
    numVoices(10); // Allocate 10 voice polyphony for this instrument. Note: calling this function is important to tell the score player how many voices are available during playback
    SinOsc oscs[numVoices()];
    Gain g => outlet;                       // Chucking to outlet lets us connect our instrument to other signal chains after instantiation
    g.gain(0.1);
    for (0 => int i; i < numVoices(); i++)
    {
        oscs[i].gain(0);          // We want each osc to be silent before a note is played
        oscs[i] => g;
    }
    
    // Implement required noteOn and noteOff functions
    //--------------------------------

    // What our instrument does when a note is played (this function is called automatically by the score player)
    fun void noteOn(ezNote note, int voice) // noteOn and noteOff must have these arguments!
    {
        Std.mtof(note.pitch()) => oscs[voice].freq; // pitches are MIDI note numbers (e.g. 60 is middle C)
        note.velocity() => oscs[voice].gain; // ezNote velocities are float values 0.0-1.0
    }

    // What our instrument does when a note is released (this function is called automatically by the score player)
    fun void noteOff(ezNote note,int voice)
    {
        0 => oscs[voice].gain;
    }
}

// Ripped off from sndpeek
// map audio buffer to 3D positions
fun void map2waveform( float in[], vec2 out[], float bottom )
{
    if( in.size() != out.size() )
    {
        <<< "size mismatch in map2waveform()", "" >>>;
        return;
    }

    DISPLAY_WIDTH/2 => float top;
    top - bottom => float span;

    for (int i; i < in.size(); i++)
    {
        // gulper min for water
        bottom + span/WINDOW_SIZE*i => out[i].y;
        in[i] * 2 * window[i] => out[i].x;
    }
}

// Sunshine
class Rays extends GGen
{
    GGen rays[NUM_RAYS]; // rays
    GLines segs[NUM_RAYS * HIST_DEPTH]; // lines/segments size ray x segs per ray
    float level[NUM_RAYS]; // base level for rays
    float hist[NUM_RAYS * HIST_DEPTH]; // spectrum history
    float lvl[HIST_DEPTH + 1]; // levels for (current) segments
    0 => int head; // queuen't

    // Constructor & Make the rays do a spinny circle
    for( int i; i < NUM_RAYS; i++ )
    {
        rays[i] --> this; // ray into rays
        // rotate quarter circle
        rays[i].rotZ( -Math.PI/2 * i / (NUM_RAYS - 1) );
        
        for( int s; s < HIST_DEPTH; s++ )
        {
            segs[i*HIST_DEPTH + s] --> rays[i]; // segs into rays
            segs[i*HIST_DEPTH + s].width( RAY_WIDTH * 0.4 ); // width into segs
        }
    }

    fun void doStuff( complex spec[] )
    {
        // only top quarter of spectrum because lets be fr thats all that matters
        spec.size() / 6 => int usable;
        // split into buckets
        usable / NUM_RAYS => int group;
        // length of segs
        RAY_LEN / HIST_DEPTH => float segLen;

        for( int i; i < NUM_RAYS; i++ )
        {
            // get loudest freq in bucket
            0.0 => float m;
            for( i*group => int b; b < (i+1)*group; b++ )
                Math.max( m, (spec[b]$polar).mag ) => m;

            // if new sound higher amplitude then history, it replaces it
            // change 8 to make ray color more or less vibrant (it scales the amplitude)
            Math.max( Math.sqrt(m) * 8.0, level[i] * RAY_DECAY ) => level[i];
        }
        
        // Put level into spectrum history
        for( int i; i < NUM_RAYS; i++ ) 
        {
            Math.min( level[i], 1.0 ) => hist[i*HIST_DEPTH + head];
        }
        // advance the bootleg ouroboros queue
        (head + 1) % HIST_DEPTH => head;

        // theres probably a more efficient or sleak way to do the history but im tired
        for( int i; i < NUM_RAYS; i++ )
        {
            // put level for each segment
            Math.min( level[i], 1.0 ) => lvl[0];
            for( 1 => int k; k <= HIST_DEPTH; k++ )
            {
            // put old levels from history in current lvls
                hist[i*HIST_DEPTH + ((head - k + 2*HIST_DEPTH) % HIST_DEPTH)] => lvl[k]; 
            }
            // this is just so the tip of the ray stays as a tip
            //0.0 => lv[HIST_DEPTH];

            @(1.0, 0.9, 0.1) => vec3 sun; // Sun color
            @(0.3, 0.6, 1.0) => vec3 sky; // Sky color

            for(int s; s < HIST_DEPTH; s++)
            {
                // Points in the line to form a rectangle
                RAY_START + s * segLen => float x0;
                x0 + segLen => float x1;

                // adding 0.1 to level term so it doesnt look bad on startup
                RAY_WIDTH * 0.3 * (0.1 + lvl[s])  => float h0;
                RAY_WIDTH * 0.3 * (0.1 + lvl[s+1])  => float h1;

                // give points to the segment GLine
                vec2 pts[4];
                @(x0,  h0) => pts[0]; 
                @(x1,  h1) => pts[1];
                @(x1, -h1) => pts[2];
                @(x0, -h0) => pts[3];
                segs[i*HIST_DEPTH + s].positions(pts);

                //// Fading
                // 1 added so its always visible 
                1 + s/ HIST_DEPTH => float age;
                // average amp of segment for brightness 0.0-1.0
                (lvl[s] + lvl[s+1]) / 2 => float v;
                // exponential decay of ray color, 0.25 is brightness when no sound
                Math.pow(age, RAY_DECAY) * (0.25 + 0.75 * v) => float keep;
                // adding sky color to make it blend a bit better
                segs[i*HIST_DEPTH + s].color( @( sky.x * (1 - keep) + sun.x * keep, sky.y * (1 - keep)  + sun.y * keep, sky.z * (1 - keep)  + sun.z * keep ) );
            }
        }
    }
}

// Ripped off from sndpeek
// do audio stuff
fun void doAudio()
{
    while( true )
    {
        // upchuck to process accum
        accum.upchuck();
        // get the last window size samples (waveform)
        accum.output( samples );
        // upchuck to take FFT, get magnitude response
        fft.upchuck();
        // get spectrum (as complex values)
        fft.spectrum( response );
        // jump by samples
        WINDOW_SIZE::samp/2 => now;
    }
}
spork ~ doAudio();

// flashbang sound
// "the numbers mason, what do they mean"
// correction: mason is now responsible for all audio
fun void mason()
{
    SinOsc sin => accum;
    sin => fft;
    sin => dac;
    200 => sin.freq;
    100::ms => now;

    4000 => sin.freq;
    for (0 => int i; i < 200; i++)
    {
        0.3 * Math.exp(-i / 100.0) => sin.gain;
        10::ms => now;
    }
    0 => sin.gain;
    1::second => now;

    <<< "wait" >>>;
    Noise waterfall => Gain gai => dac;
    gai => accum;
    gai => fft;
    0.05 => gai.gain;
    0.05 => waterfall.gain;
    2::second => now;

    player1.play();
    player2.play();

    while (true)
    {
        1::second => now;
    }
} 

0 => int explode;
GPlane flash --> GG.scene();
flash.pos( @(0, 0, 6) );
flash.color( @(1, 1, 1) );
flash.sca(0);

fun void flashbang()
{
    1 => explode;
    gulp.sca(0);                
    flash.sca( @(50, 50, 1) );
    spork ~ mason();  
    for (int i; i < 30; i++)
    {
        0.1::second => now;     
        flash.alpha(1 - 0.03 * i);
         
    } 
    flash.sca(0);
    while(true)
    {
        1::second => now;
    }
}

// graphics render loop
while( true )
{
    GG.nextFrame() => now;

    -DISPLAY_WIDTH => float bottom;
    if (explode == 0)
    {
        if (GWindow.key(GWindow.Key_Up)) gulp.translateY(0.03);
        if (GWindow.key(GWindow.Key_Down)) gulp.translateY(-0.03); 

        // cap the gulper's movement
        if( gulp.posY() > 1.5) gulp.posY( 1.5 );
        if( gulp.posY() < -2.0 ) gulp.posY( -2.0 );

        (gulp.posY() + 2.0) / 3.5 => float h;
        gulp.sca( 1.0 + 0.8 * h * h );

        // gulper gulps the water stream
        Math.min( gulp.posY(), DISPLAY_WIDTH/2 - 0.1 ) => bottom;
        if( h > 0.98) {
            spork ~ flashbang();
            adc =< accum;
            adc =< dcbloke;
        }
    } 

    // keep the "still line" in sync
    @(0, bottom) => still[0];
    @(0, DISPLAY_WIDTH/2) => still[1];
    fake2.positions(still);

    fake1.positions(positions1);
    map2waveform(samples, positions1, bottom);
    waveform.positions(positions1);

    rays.doStuff(response);
}