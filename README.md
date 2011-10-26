# Loom

Loom is a modular, Ruby-based generative music framework for Ableton Live.

## Core Concepts

A *player* generates MIDI for each track.

Players have motifs and behaviors:

*Motifs* describe specific musical/stylistic ideas (patterns, rhythms).

*Behaviors* govern high-level player decisions and select motifs to use.

## Usage

To create a player in Live:

* create a MIDI track and give it any old instrument
* Before the instrument, insert a *MIDI Effect Rack*.
* Navigate to the "loom/m4l" directory in the Live file browser
* Drag any motif into the rack.
* Hit play. You're already generating music!

As you add more motifs to the rack, they will be randomly selected. Adjust their respective "weights" to set the probability that they'll be selected.

You can then add behaviors in the same way to the same rack.

So long as they're all in the same rack, they'll be treated as a single player. (You can actually put multiple racks on a same track to have multiple players.)
