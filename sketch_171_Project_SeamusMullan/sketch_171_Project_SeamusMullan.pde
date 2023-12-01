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


// Import libraries
import processing.sound.*;
import com.krab.lazy.*;
import java.io.File;

// Create UI and Audio I/O + parameters
LazyGui gui;
Sound s;

boolean isPlaying = true; // To check if the audio is currently playing

// list of known directories for samples, each folder gets searched later in the file
String[] sDir = {"bird_samples", "wind_samples", "leaves_samples", "rain_samples"};

// I'm using an arraylist so more samples can be added the user, the ArrayList gets converted to fixed size array for playing sounds
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
Waveform birdWaveform; // Waveform object to visualise the bird sounds
int waveformSampleRate = 65536; // decently high quality, ran efficiently on my laptop (M2 Macbook Air 2022 13")


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
  s = new Sound(this);

  // Gain parameters for each category of sound (Name, Default, Min, Max)
  masterGain = gui.slider("Master_gain", 50.0f, 0.0f, 100.0f);
  birdGain = gui.slider("Bird_gain", 50.0f, 0.0f, 100.0f);
  bgGain = gui.slider("Wind_Rain_gain", 50.0f, 0.0f, 100.0f);
  isPlaying = gui.toggle("Mute", false);

  birdWaveform = new processing.sound.Waveform(this, waveformSampleRate);

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
  File[][] allFiles = new File[sDir.length][];

  for (int i = 0; i < sDir.length; i++) {
    allFiles[i] = sampleCounter(i); // Directly assign the output from sampleCounter to the array
  }

  ArrayList[] allSamples = {birdSamples, windSamples, leavesSamples, rainSamples};

  for (int i = 0; i < allFiles.length; i++) {
    for (File file : allFiles[i]) {
      allSamples[i].add(new SoundFile(this, file.toString()));
    }
  }

  // rain sounds are the only sounds that get looped during the runtime of the app
  backgroundSounds.addAll(rainSamples);
}





/*
 ################################################
 Sample Playing Methods
 ################################################
 */

SoundFile lastSamplePlayed;

void playOneShot(SoundFile sample) {
  if (sample != null) {
    sample.play();
  }
}


// gets called in setup (leaves blowing in the wind is called psithurism by the way!)
void playBackgroundSound(ArrayList<SoundFile> backgroundSounds) {
  
  for (SoundFile sound : currentBackgroundSounds) {
    sound.stop();
  }
  currentBackgroundSounds.clear();

  SoundFile[] backgroundSoundsArray = backgroundSounds.toArray(new SoundFile[backgroundSounds.size()]);
  
  // Select and play all background sounds
  for (int i = 0; i < backgroundSoundsArray.length; i++) {
    backgroundSoundsArray[i].loop();
    currentBackgroundSounds.add(backgroundSoundsArray[i]);
  }
}



void playRandomBirdSample(ArrayList<SoundFile> sampleList, float amp) {
  if (sampleList.size() > 0) {
    // get a random sample in the birdSamples array
    int randomIndex = int(random(sampleList.size()));
    SoundFile randomSample = sampleList.get(randomIndex);
    SoundFile[] birdSamplesArray = birdSamples.toArray(new SoundFile[birdSamples.size()]);

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
  // 4D 61 64 65 42 79 53 65 61 6D 75 73 4D 75 6C 6C 61 6E (ASCII Hexadecimal Tag)

  updateParameters();
  background(140, 180, 140);

  float chanceOfBirdNoise = 0.03f; // 3% chance every draw call (Stops too much overlap)
  float randInt = random(0, 1);
  if (randInt <= chanceOfBirdNoise)
  {
    playRandomBirdSample(birdSamples, birdGain/100);
  }

  for (SoundFile birdSound : playingBirdSounds) {
    birdSound.amp(birdGain / 100);
  }
  for (SoundFile sound : currentBackgroundSounds) {
    sound.amp(bgGain / 100);
  }

  if (!isPlaying) {
    s.volume(masterGain/100);
  } else {
    s.volume(0);
  }
  birdWaveform.analyze();


  // Draw the waveform to the screen
  stroke(100, 140, 100); // darker green
  strokeWeight(1);
  noFill();
  beginShape();
  for (int i = 0; i < waveformSampleRate; i++)
  {
    vertex(
      map(i, 0, waveformSampleRate, 0, width),
      map(birdWaveform.data[i], -1, 1, 0, height)
      );
  }
  endShape();
}
