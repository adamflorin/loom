# Loom

## Overview

Loom is a modular, Ruby-based generative music platform for Ableton Live.

While it has been used for performances and installations since late 2010, it is still in an early alpha stage of development. Caveat emptor!

http://adamflorin.com/loom

### Core Concepts

A *player* generates and plays back *gestures* (sequences of MIDI *events*) for the track it belongs to.

Each player is made up of *modules* which extend its core functionality—from the low-level morphologies of generated gestures, to how those gestures are sequenced in real time, to high-level player behaviors and reactions to external conditions.

Each module has inputs in the form of random number *generators* controlled by user input.

All players belong to a shared *environment*, which can govern overall musical form (not yet implemented!).

### Technology Stack

Loom is built on...

* ...Live because of its robust timing, MIDI controller integration, and full-featured music production environment.

* ...Ruby because of its ease of prototyping, intrinsic modularity, and mutability ("monkeypatchability"?).

Loom bridges these two technologies across a rather tall stack, leveraging the interface-building (and parameter storage) capabilities of Max For Live, the native MIDI & message-handling of Max, and the performance and stability of Java & JRuby along the way.

## Usage

See the [screencast](http://vimeo.com/31945050).

### Installing

Please see [INSTALLATION](INSTALLATION.md).

### Creating and editing players

To create a player in Live:

* create a MIDI track and give it any old instrument
* Before the instrument, insert a *MIDI Effect Rack*.
* Navigate to the `loom/m4l` directory in the Live file browser
* Drag any `player` module into the rack.
* Hit play. You're already generating music!

As you add more player modules to the rack, they will each add their own dimension of depth to the generated output. *Note*: you can only add each module once!

So long as they're all in the same rack, they'll be treated as a single player. (You can actually put multiple racks on a same track to have multiple players--as in the left and right hands of a piano, for example.)

### Setting up the environment

*Note*: the environment is not currently necessary unless you are modifying Ruby source and need to globally reload the system. The environment will contain more powerful features in future versions.

Drop the `environment` m4l device in the Master track. (It doesn't generate any MIDI or affect the audio. This is just a good global place to put it.)

To reload _all_ modules across _all_ players, hit `MASTER RELOAD` in the environment. It's recommended you map this to a key in Live (which unfortunately must be tapped 2x).


## Modules

* *Chromatic*: select a pitch set from the equal tempered MIDI scale, with range and position settings.
* *Pattern*: define a MIDI pattern as a series of pulses, with accent position and time scale.
* *Loop*: loop the last few gestures.
* *Syncopation*: vary note lengths based on Pattern's accent position.
* *Density*: probability of silence (rests) vs gestures.
