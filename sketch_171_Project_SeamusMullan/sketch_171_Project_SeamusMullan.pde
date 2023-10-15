 //<>//

/*
 *
 *    ... . .- -- ..- ...            -- ..- .-.. .-.. .- -.
 *     _____                          _____     _ _
 *    |   __|___ ___ _____ _ _ ___   |     |_ _| | |___ ___
 *    |__   | -_| .'|     | | |_ -|  | | | | | | | | .'|   |
 *    |_____|___|__,|_|_|_|___|___|  |_|_|_|___|_|_|__,|_|_|
 *
 *    Created in 2023 by Seamus Mullan.
 */


import processing.sound.*;
import com.krab.lazy.*;
import java.io.File;

// Create UI and Audio I/O + parameters
LazyGui gui;
//Sound s;


// I'm using an arraylist so more samples can be added in the future (it makes the whole program customizable too!
ArrayList<SoundFile> windSamples = new ArrayList<SoundFile>();
ArrayList<SoundFile> birdSamples = new ArrayList<SoundFile>();
ArrayList<SoundFile> leavesSamples = new ArrayList<SoundFile>();
ArrayList<SoundFile> rainSamples = new ArrayList<SoundFile>();

// Audio parameters
float masterGain;
float windGain, birdGain, leavesGain, rainGain;

boolean lowPassToggle, reverbToggle;
float lowPassFreq, reverbAmount; // Reverb amount modulates multiple values to scale the reverb with one parameter

// Vislualizer Stuff
Waveform waveform;



public void setup() {
  size(800, 800, P2D);
  background(140, 180, 140);

  // Initialize UI Controls and Parameters
  gui = new LazyGui(this);
  //s = new Sound(this);

  masterGain = gui.slider("Master_gain", 50.0f, 0.0f, 100.0f); // Gain from 0% -> 100% on the output

  // Specific Gains for each section of ambience
  windGain = gui.slider("Wind_gain", 50.0f, 0.0f, 100.0f);
  birdGain = gui.slider("Bird_gain", 50.0f, 0.0f, 100.0f);
  leavesGain = gui.slider("Leaves_gain", 50.0f, 0.0f, 100.0f);
  rainGain = gui.slider("Rain_gain", 50.0f, 0.0f, 100.0f);


  fetchSamples();
}

void updateParameters() {
  masterGain = gui.slider("Master_gain", 50.0f, 0.0f, 100.0f);
  windGain = gui.slider("Wind_gain", 50.0f, 0.0f, 100.0f);
  birdGain = gui.slider("Bird_gain", 50.0f, 0.0f, 100.0f);
  leavesGain = gui.slider("Leaves_gain", 50.0f, 0.0f, 100.0f);
  rainGain = gui.slider("Rain_gain", 50.0f, 0.0f, 100.0f);
}


/* 

I'm well aware this system isn't that optimised, but since it's only called once on startup, it's not a huge perfomance hit and doesn't affect the program in runtime 

*/


// This function counts the amount of files in each dedicated sample folder so users can add extra and the values get recalculated!
int sampleCounter(int dirInt) {
  String[] sDir = {"bird_samples", "wind_samples", "leaves_samples", "rain_samples"}; // list of known sample folders relative to the sketch

  String directoryPath = dataPath(sDir[dirInt]);
  File directory = new File(directoryPath);
  File[] files = directory.listFiles();

  if (files != null) {
    int numberOfFiles = files.length;
    println("Number of files in the directory '" + sDir[dirInt] + "': " + numberOfFiles);
    return numberOfFiles;
  } else {
    println("Directory '" + sDir[dirInt] + "' not found or empty.");
    return 0;
  }
}


// This gets all the samples from each folder and adds them to their corresponding arraylist (defined at start)
void fetchSamples() {
  String windFolder = "wind_samples"; //1
  String birdFolder = "bird_samples"; //0
  String leavesFolder = "leaves_samples"; //2
  String rainFolder = "rain_samples"; //3


  // BIRDS
  for (int i = 1; i <= sampleCounter(0); i++) {
    // Format i so it reads 01 -> 09, This is because I splitted my files in Audacity after rendering them in my DAW (Digital Audio Workstation)
    // %02d -> default to zeros, 2 digits long, assume an integer for input
    String j = String.format("%02d", i);

    birdSamples.add(new SoundFile(this, dataPath(birdFolder + "/bird" + j + ".mp3")));
  }


  // WIND
  for (int i = 1; i <= sampleCounter(1); i++) {
    String j = String.format("%02d", i);

    windSamples.add(new SoundFile(this, dataPath(windFolder + "/wind" + j + ".mp3")));
  }


  // LEAVES
  for (int i = 1; i <= sampleCounter(2); i++) {
    String j = String.format("%02d", i);

    leavesSamples.add(new SoundFile(this, dataPath(leavesFolder + "/leaves" + j + ".mp3")));
  }


  // RAIN
  for (int i = 1; i <= sampleCounter(3); i++) {
    String j = String.format("%02d", i);

    rainSamples.add(new SoundFile(this, dataPath(rainFolder + "/rain" + j + ".mp3")));
  }
}


public void draw() {
  // Update all the parameters relevant to sliders
  //4D 61 64 65  42 79  53 65 61 6D 75 73  4D 75 6C 6C 61 6E (ASCII Hexadecimal)
  updateParameters();
  background(140, 180, 140);

  // Set the output gain for all sounds
  //s.volume(masterGain/100);
}
