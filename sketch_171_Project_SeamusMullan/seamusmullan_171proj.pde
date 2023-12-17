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


// Samples inside the data folder created by Seamus Mullan using Kontakt 7 and Ableton Live 11
// The Project files were too large to include and were omitted


// Import libraries
import com.krab.lazy.*; // https://github.com/KrabCode/LazyGui
import java.io.File;
import java.util.HashMap;
import ddf.minim.*;
import ddf.minim.analysis.*;

// Create UI and Audio I/O thingies
LazyGui gui;
boolean isPlaying = true; // To check if the audio is currently playing

AudioOutput out;
FFT fft;
Minim minim;

int waveformSampleRate = 65536; // ran efficiently on my laptop (M2 Macbook Air 2022 13"), aka 2^16 samples

// used hashmaps since LazyGui slider objects are private and can't be accessed by their name
HashMap<String, AudioPlayer> oneShotPlayers = new HashMap<String, AudioPlayer>();
HashMap<String, AudioPlayer> loopingPlayers = new HashMap<String, AudioPlayer>();
HashMap<String, Object> sampleVolumes = new HashMap<String, Object>(); // Object -> the slider object

ArrayList<File[]> oneShotSamples = new ArrayList<File[]>(); // contains all samples to be randomly played during runtime
ArrayList<File[]> loopingSamples = new ArrayList<File[]>(); // contains all samples to be looped from beginning


/*
 ################################################
 Setup UI and Find Samples
 ################################################
 */

public void setup() {
  // setup window and bg colour
  size(500, 600, P2D);
  background(140, 180, 140); // a nice light green

  /*
    For each sound subfolder found, make a parameter that controls the volume of all the files in that directory
    Structure is as follows:
      - data
        - bird
          - bird1.mp3
          - bird2.mp3
          - ...
        - wind_rain
          - loop_wind1.mp3      -- this file *will* loop --
          - rain1.mp3           -- this file wont loop --
          - ...
        - *
          - *_1.mp3
          - *_2.mp3
          - ...
        - ...

      Parameters would be:
        - bird_gain
        - wind_rain_gain
        - *_gain
        - ...

      NOTE: the gui folder is ignored (manages LazyGui stuff)

    This way makes it possible for the user to add custom folders and sounds without having to change the code
  */

  minim = new Minim(this);
  out = minim.getLineOut();
  fft = new FFT(out.bufferSize(), out.sampleRate());

  // find all subdirs in the data folder (except the gui folder)
  findSamples(minim);

  // create a slider for each subfolder
  gui = new LazyGui(this);
  createSliders(gui);
  isPlaying = gui.toggle("Mute", false);

  playLoopingSamples();
}

// WORKING
void findSamples(Minim minim){
  // find all subdirs in the data folder (except the gui folder)
  // create array for all samples in each subfolder, append to relevant arraylist
  File[] subdirs = new File(sketchPath("data")).listFiles(File::isDirectory);

  for (File subdir : subdirs) {
    if (!subdir.getName().equals("gui")) {

      File[] samples = subdir.listFiles();
      for (File sample : samples) {
        // filter formats
        if (sample.getName().endsWith(".mp3") || sample.getName().endsWith(".wav")) {
          // assign to correct arraylist and make AudioPlayer instance
          if (sample.getName().contains("loop")) {
            loopingSamples.add(samples);
            loopingPlayers.put(sample.getName(), minim.loadFile(sample.getAbsolutePath()));
            // println("looping sample: " + sample.getName()); // debug
          } else {
            oneShotSamples.add(samples);
            oneShotPlayers.put(sample.getName(), minim.loadFile(sample.getAbsolutePath()));
            // println("one shot sample: " + sample.getName()); // debug
          }
        }
      }
    }
  }

  // print out sizes of the arraylists
  println("Found " + oneShotSamples.size() + " one shot samples");
  println("Found " + loopingSamples.size() + " looping samples");
}


void createSliders(LazyGui gui){
  // create a slider for each subfolder
  for (File[] samples : oneShotSamples) {
    String folderName = samples[0].getParentFile().getName();
    // gui.slider(Name, Default, Min, Max);
    sampleVolumes.put((folderName + "_gain"), gui.slider(folderName + "_gain", 50.0f, 0.0f, 100.0f));
  }
  for (File[] samples : loopingSamples) {
    String folderName = samples[0].getParentFile().getName();
    sampleVolumes.put((folderName + "_gain"),gui.slider(folderName + "_gain", 50.0f, 0.0f, 100.0f));
  }
}



/*
 ################################################
 Draw UI and Play Samples
 ################################################
 */

public void draw(){
  background(140, 180, 140); // a nice light green
  updateParameters();
  if (isPlaying) {
    playRandomOneShot();
  } else {
    // pause since minim.AudioPlayer resumes at the same point (like a cue)
    for (AudioPlayer player : oneShotPlayers.values()) {
      player.pause();
    }
    for (AudioPlayer player : loopingPlayers.values()) {
      player.pause();
    }
  }

}

void updateParameters(){
  // change volume of each sample from slider value
  
  println("Updating Samples");
  println(sampleVolumes.keySet()); // lists all the possible folders for samples
  println(sampleVolumes.values()); // lists all the slider objects

  for (String folderName : sampleVolumes.keySet()) {
    // sets volume = to slider object (which is how LazyGui works for some reason)
    float sampleGain = (float) sampleVolumes.get(folderName);

    // check if sample is a one shot or loops and update gain
    sampleGain = map(sampleGain, 0.0f, 100.0f, -40.0f, 0.0f); // convert to dB (for minim)

    if (oneShotPlayers.containsKey(folderName)) {
      // gets AudioPlayer for the folder and sets gain
      oneShotPlayers.get(folderName).setGain(sampleGain);
      println(sampleGain + " gain for sample: " + folderName);

    } else if (loopingPlayers.containsKey(folderName)) {
      loopingPlayers.get(folderName).setGain(sampleGain);
      println(sampleGain + " gain for sample: " + folderName);
    } else {
      println("No samples found for folder: " + folderName);
      }
  }

  isPlaying = gui.toggle("Mute");
}

void playRandomOneShot() {
  float chance = 0.025; // 2.5% chance of playing a sample each frame
  if (random(0, 1) < chance) {
    try {
      for (File[] samples : oneShotSamples) {
        int randomIndex = (int) random(samples.length);
        AudioPlayer player = oneShotPlayers.get(samples[randomIndex].getName());
        if (player != null) {
          player.play();
        }
      }
    } catch (Exception e) {
      // Handle null pointer exceptions and whatever else happens here
      // not fully sure why but if it works ¯\_(>.<)_/¯
      
      println("exception occurred: " + e.getMessage());
    }
  }
}

void playLoopingSamples(){
  try {
    for (File[] samples : loopingSamples) {
      // play all samples in the subfolder at once
      // loop infinitely (until the user mutes or quits the program)
      String name = new String();
      for (File sample : samples) {
        AudioPlayer player = loopingPlayers.get(sample.getName());
        if (player != null) {
          //player.loop();
        }
      }
    }
  } catch (Exception e) {\
    // same in oneshot function
    println("exception occurred: " + e.getMessage());
  }

  // play first sample for testing
  loopingPlayers.get(loopingSamples.get(0)[0].getName()).loop();
}
