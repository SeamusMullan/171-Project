/*
 *
 *    ... . .- -- ..- ...            -- ..- .-.. .-.. .- -.
 *     _____                          _____     _ _
 *    |   __|___ ___ _____ _ _ ___   |     |_ _| | |___ ___
 *    |__   | -_| .'|     | | |_ -|  | | | | | | | | .'|   |
 *    |_____|___|__,|_|_|_|___|___|  |_|_|_|___|_|_|__,|_|_|
 *
 *    Created in 2023 by Seamus Mullan.
 *    CS171 Year 1 Project
 *    Maynooth University
 */


// Samples inside the data folder created by Seamus Mullan


// Import libraries

//import processing.sound.*;
import com.krab.lazy.*; // https://github.com/KrabCode/LazyGui
import java.io.File;
import ddf.minim.*;
import ddf.minim.analysis.*;

// Create UI and Audio I/O + parameters
LazyGui gui;
boolean isPlaying = true; // To check if the audio is currently playing

// list of known directories for samples, each folder gets searched later in the file
String[] sDir = {"bird_samples", "wind_samples", "leaves_samples", "rain_samples"};

// I'm using an arraylist so more samples can be added the user, the ArrayList gets converted to fixed size array for playing sounds
ArrayList<AudioSample> windSamples = new ArrayList<AudioSample>();
ArrayList<AudioSample> birdSamples = new ArrayList<AudioSample>();
ArrayList<AudioSample> leavesSamples = new ArrayList<AudioSample>();
ArrayList<AudioSample> rainSamples = new ArrayList<AudioSample>();

ArrayList<AudioPlayer> playingBackgroundSounds = new ArrayList<AudioPlayer>();
ArrayList<AudioPlayer> backgroundSounds = new ArrayList<AudioPlayer>();
ArrayList<AudioSample> playingBirdSounds = new ArrayList<AudioSample>();

// Audio parameters
float masterGain;
float birdGain, bgGain;

//Waveform birdWaveform; // Waveform object to visualise the bird sounds

AudioOutput out;
FFT fft;
Minim minim;

int waveformSampleRate = 65536; // decently high detail, ran efficiently on my laptop (M2 Macbook Air 2022 13")


/*
 ################################################
 UI and Sample Loading
 ################################################
 */

public void setup() {
  // setup window and bg colour
  size(500, 600, P2D);
  background(140, 180, 140); // a nice light green

  // Initialize UI Controls and Parameters
  gui = new LazyGui(this);


  // Gain parameters for each category of sound (Name, Default, Min, Max)
  masterGain = gui.slider("Master_gain", 50.0f, 0.0f, 100.0f);
  birdGain = gui.slider("Bird_gain", 50.0f, 0.0f, 100.0f);
  bgGain = gui.slider("Wind_Rain_gain", 50.0f, 0.0f, 100.0f);
  isPlaying = gui.toggle("Mute", false);

  minim = new Minim(this);
  out = minim.getLineOut(); // used to display output audio
  fft = new FFT(out.bufferSize(), out.sampleRate());

  // search local dirs for samples (uses global sDirs array)
  fetchSamples();
  playBackgroundSound(backgroundSounds);
}

void togglePlayPause() {
  isPlaying = !isPlaying;
}

void updateParameters() {
  masterGain = gui.slider("Master_gain", 50.0f, 0.0f, 100.0f);
  birdGain = gui.slider("Bird_gain", 50.0f, 0.0f, 100.0f);
  bgGain = gui.slider("Wind_Rain_gain", 50.0f, 0.0f, 100.0f);
  isPlaying = gui.toggle("Mute", false);
}



/*
 ################################################
 Sample Fetching methods
 ################################################
 */



// This function gets the files in each dedicated sample folder so users can add their own samples!
File[] sampleCounter(int dirInt) {

  String directoryPath = dataPath(sDir[dirInt]);

  File directory = new File(directoryPath);
  File[] files = directory.listFiles();


  // this is debug info to make sure the files are being found.
  if (files != null) {
    int numberOfFiles = files.length;
    println("Number of files in the directory '" + sDir[dirInt] + "': " + numberOfFiles);
    return files;
  } else {
    println("Directory '" + sDir[dirInt] + "' not found or empty.");
    return files;
  }
}


// This gets all the samples from each folder and adds them to their corresponding arraylist
void fetchSamples() {
  
  // NON LOOPING FILES //
  File[][] allFiles = new File[sDir.length][];

  for (int i = 0; i < sDir.length; i++) {
    allFiles[i] = sampleCounter(i);
  }

  ArrayList[] allSamples = {birdSamples, windSamples, leavesSamples};
  ArrayList rainSamples = new ArrayList<AudioPlayer>();

  for (int i = 0; i < allFiles.length-1; i++) {
    for (File file : allFiles[i]) {
      // convert file to AudioSample and add to the correct arraylist
      allSamples[i].add(minim.loadSample(file.toString()));
    }
  }

  // rain sounds always at end of this list
  for (File file : allFiles[allFiles.length - 1]) {
    rainSamples.add(minim.loadFile(file.toString()));
  }

  // rain sounds are the only sounds that get looped during the runtime of the app
  // this means we can add them to the background sounds arraylist and make it loop later
  backgroundSounds.addAll(rainSamples);
}



/*
 ################################################
 Sample Playing Methods
 ################################################
 */

AudioSample lastSamplePlayed;

void playOneShot(AudioSample sample) {
  if (sample != null) {
    sample.trigger();
  }
}

void playLoopingSample(AudioPlayer sample) {
  if (sample != null && !playingBackgroundSounds.contains(sample)) {
    sample.cue(0);
    sample.loop();
  }
}



void playBackgroundSound(ArrayList<AudioPlayer> backgroundSounds) {
  AudioPlayer[] backgroundSoundsArray = backgroundSounds.toArray(new AudioPlayer[backgroundSounds.size()]);

  // Select and play all background sounds
  for (int i = 0; i < backgroundSoundsArray.length; i++) {
    playLoopingSample(backgroundSoundsArray[i]);
    playingBackgroundSounds.add(backgroundSoundsArray[i]);
  }
}


void playRandomBirdSample(ArrayList<AudioSample> sampleList, float amp) {
  if (sampleList.size() > 0) {
    // get a random sample in the birdSamples array
    int randomIndex = int(random(sampleList.size()));
    AudioSample randomSample = sampleList.get(randomIndex);

    if (randomSample != lastSamplePlayed) {
      randomSample.setGain(amp);
      randomSample.trigger();
      playingBirdSounds.add(randomSample);
      lastSamplePlayed = randomSample;
    }
  }
}




public void draw() {
  updateParameters();
  background(140, 180, 140);

  float chanceOfBirdNoise = 0.025f; // 3% chance every draw call (Stops samples overlapping)
  float randInt = random(0, 1);
  if (randInt <= chanceOfBirdNoise)
  {
    playRandomBirdSample(birdSamples, birdGain/100);
  }

  // convert gain values from 0 -> 100 % to -inf -> 0 dB
  float masterGainDB = map(masterGain, 0, 100, -100, 0);
  float birdGainDB = map(birdGain, 0, 100, -100, 0);
  float bgGainDB = map(bgGain, 0, 100, -100, 0);
  


  // set volume for samples
  for (AudioSample birdSound : playingBirdSounds) {
    birdSound.setGain(birdGain / 100);
  }
  for (AudioPlayer sound : playingBackgroundSounds) {
    sound.setGain(bgGain / 100);
  }

  // set gain of whole application
  if (!isPlaying) {
    out.setGain(masterGain/100);
  } else {
    out.setGain(0);
  }



  //birdWaveform.analyze();


  fft.forward(out.mix);


  // Draw the waveform to the screen
  stroke(100, 140, 100); // darker green
  strokeWeight(1);
  noFill();

  beginShape();
  for (int i = 0; i < fft.specSize(); i++)
  {
    // create vertex for each point in the fft
    vertex(map(i, 0, fft.specSize(), 0, width), map(fft.getBand(i), 0, 1, height, 0));
    
  }

   for(int i = 0; i < fft.specSize(); i++)
  {
    // draw the line for frequency band i, scaling it up a bit so we can see it
    line( i, height, i, height - fft.getBand(i)*8 );
  }
  endShape();
}
