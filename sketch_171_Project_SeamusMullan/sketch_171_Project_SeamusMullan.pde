

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

// Create UI and Audio I/O + parameters
LazyGui gui;
//Sound s;

float masterGain;
float windGain, birdGain, leavesGain, rainGain;

boolean lowPassToggle, reverbToggle;
float lowPassFreq, reverbAmount; // Reverb amount modulates multiple values to scale the reverb with one parameter

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
}

void updateParameters() {
  masterGain = gui.slider("Master_gain", 50.0f, 0.0f, 100.0f);
  windGain = gui.slider("Wind_gain", 50.0f, 0.0f, 100.0f);
  birdGain = gui.slider("Bird_gain", 50.0f, 0.0f, 100.0f);
  leavesGain = gui.slider("Leaves_gain", 50.0f, 0.0f, 100.0f);
  rainGain = gui.slider("Rain_gain", 50.0f, 0.0f, 100.0f);
}

public void draw() {
  // Update all the parameters relevant to sliders
  //4D 61 64 65  42 79  53 65 61 6D 75 73  4D 75 6C 6C 61 6E (ASCII Hexadecimal)
  updateParameters();
  background(140, 180, 140);

  // Set the output gain for all sounds
  //s.volume(masterGain/100);
}
