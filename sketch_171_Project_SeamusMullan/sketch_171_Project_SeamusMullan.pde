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

// All samples in data folder made by Seamus Mullan (using Kontakt 7 and Ableton Live 11)

// Import libraries
import processing.sound.*;
import com.krab.lazy.*;
import java.io.File;

// Create UI and Audio I/O + parameters
LazyGui gui;
Sound s;

boolean isPlaying = true; // To check if the audio is currently playing
float fadeSpeed = 0.001; // Speed at which the volume will fade
boolean fadingOut = false; // To check if we are currently fading out

// using an arraylist so more samples can by the user, the ArrayList then gets converted to a normal array for iterating and playing the sounds
// no leaves or wind samples are included in the project but you should be able to add samples as wav or mp3 files to your liking!
ArrayList<SoundFile> windSamples = new ArrayList<SoundFile>();
ArrayList<SoundFile> birdSamples = new ArrayList<SoundFile>();
ArrayList<SoundFile> leavesSamples = new ArrayList<SoundFile>();
ArrayList<SoundFile> rainSamples = new ArrayList<SoundFile>();

ArrayList<SoundFile> currentBackgroundSounds = new ArrayList<SoundFile>();
ArrayList<SoundFile> backgroundSounds = new ArrayList<SoundFile>();
ArrayList<SoundFile> playingBirdSounds = new ArrayList<SoundFile>();

// Audio parameters
float masterGain;
float birdGain, bgGain;

// used for visualiser
Waveform birdWaveform;

int samples =  65536; // This sample count ran efficiently on my PC, performance may vary on other devices

public void setup() {
  size(500, 400, P2D);
  background(140, 180, 140); // a nice pale green

  // Initialize UI Controls and Parameters
  gui = new LazyGui(this);
  s = new Sound(this);

  masterGain = gui.slider("Master_gain", 50.0f, 0.0f, 100.0f); // (Name, Default Val, Min, Max)
  birdGain = gui.slider("Bird_gain", 50.0f, 0.0f, 100.0f);
  bgGain = gui.slider("Wind_Rain_gain", 50.0f, 0.0f, 100.0f);
  isPlaying = gui.toggle("Muted", true);

  
  // search local dirs for samples to play, add to arraylists, start background audio
  fetchSamples();
  playBackgroundSound(backgroundSounds);
  println(); // makes reading debug messages easier
  
  // Instantiate the waveform object
  birdWaveform = new processing.sound.Waveform(this, samples);
  birdWaveform.input(birdSamples.get(0)); // stops console spam
}

void togglePlayPause() {
  isPlaying = !isPlaying;
}

void updateParameters() {
  masterGain = gui.slider("Master_gain", 50.0f, 0.0f, 100.0f);
  birdGain = gui.slider("Bird_gain", 50.0f, 0.0f, 100.0f);
  bgGain = gui.slider("Wind_Rain_gain", 50.0f, 0.0f, 100.0f);
  isPlaying = gui.toggle("Muted", false);
}

// This function gets the files in each dedicated sample folder so users can add their own samples!
File[] sampleCounter(int dirInt) {
  String[] sDir = {"bird_samples", "wind_samples", "leaves_samples", "rain_samples"}; // list of known sample folders for the app

  // counts files in each directory
  // this is debug info to make sure the files are being found.
  String directoryPath = dataPath(sDir[dirInt]);
  File directory = new File(directoryPath);
  File[] files = directory.listFiles();

  if (files != null) {
    int numberOfFiles = files.length;
    println("Number of files in the directory '" + sDir[dirInt] + "': " + numberOfFiles);
    return files;
  } else {
    println("Directory '" + sDir[dirInt] + "' not found or empty.");
    return files;
  }
}


// This gets all the samples from each folder and adds them to their corresponding arraylist (defined at start of program)
void fetchSamples() {
  File[][] allFiles = new File[][] {
    sampleCounter(0), // birdFiles
    sampleCounter(1), // windFiles
    sampleCounter(2), // leavesFiles
    sampleCounter(3)  // rainFiles
  };


  // final array of arraylists (yep its a mouthful)
  ArrayList[] allSamples = {birdSamples, windSamples, leavesSamples, rainSamples};

  for (int i = 0; i < allFiles.length; i++) {
    if (allFiles[i] != null) {
      for (File file : allFiles[i]) {
        if (allSamples[i] != null) {
          allSamples[i].add(new SoundFile(this, file.toString()));
        }
      }
    }
  }


  // rain sounds are the only sounds that get looped during the runtime of the app
  backgroundSounds.addAll(rainSamples);
}




/// PLAYING AUDIO ///
SoundFile lastSamplePlayed;

void playOneShot(SoundFile sample) {
  if (sample != null) {
    sample.play();
  }
}

// gets called on setup to start the wind, rain and leaves sounds (leaves blowing in the wind is called psithurism by the way!)
void playBackgroundSound(ArrayList<SoundFile> backgroundSounds) {

  // Convert the ArrayList to a normal array (more efficient than ArrayList)
  SoundFile[] backgroundSoundsArray = backgroundSounds.toArray(new SoundFile[backgroundSounds.size()]);

  // Select and play multiple background sounds
  for (int i = 0; i < backgroundSoundsArray.length; i++) {
    backgroundSoundsArray[i].loop();
    currentBackgroundSounds.add(backgroundSoundsArray[i]);
  }
}

// plays random sample from an array of samples
void playRandomBirdSample(ArrayList<SoundFile> sampleList, float amp) {
  if (sampleList.size() > 0) {

    int randomIndex = int(random(sampleList.size()));
    SoundFile randomSample = sampleList.get(randomIndex);
    // Convert the ArrayList to a normal array
    SoundFile[] birdSamplesArray = birdSamples.toArray(new SoundFile[birdSamples.size()]);

    // Check if the selected sample is different from the last one played
    if (randomSample != lastSamplePlayed) {
      randomSample.play(1, amp);
      playingBirdSounds.add(randomSample);

      // Set the waveform to the current sample (only one sample displayed at a time)
      birdWaveform.input(birdSamplesArray[randomIndex]);
      lastSamplePlayed = randomSample;
    }
  }
}

public void draw() {
  updateParameters();
  background(140, 180, 140); // that same pale green in setup()

  // these stop the console being spammed with messages about inaudible sounds (since the volume "can't be = to 0")
  birdGain += 0.000001f;
  bgGain += 0.000001f;

  // 3% chance a bird sample gets played every draw call (still a lot but stops audio from getting too loud too fast)
  float chanceOfBirdNoise = 0.03f;
  float randInt = random(0, 1);
  if (randInt <= chanceOfBirdNoise)
  {
    playRandomBirdSample(birdSamples, birdGain/100);
  }

  // update volumes for bird and background sounds
  for (SoundFile birdSound : playingBirdSounds) {
    birdSound.amp(birdGain / 100);
  }
  for (SoundFile sound : currentBackgroundSounds) {
    sound.amp(bgGain / 100);
  }

  if (isPlaying) { // check if muted
    s.volume(masterGain / 100);
  } else {
    s.volume(0);
  }

  // analyze the waveform of the bird samples
  birdWaveform.analyze();


  // Draw the waveform to the screen
  stroke(100, 140, 100);
  strokeWeight(1);
  noFill();

  beginShape();
  for (int i = 0; i < samples; i++)
  {
    vertex(
      map(i, 0, samples, 0, width),
      map(birdWaveform.data[i], -1, 1, 0, height)
      );
  }
  endShape();
}
