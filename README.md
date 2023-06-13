
Project contents:

* [tenfour-step](tenfour-step/README.md)
* [tenfour-noisegen]
* [tenfour-harmonizer]

# tenfour-midi_cc_curve

takes a single midi CC, and remaps its value based on input range, output range, and a curve.

# tenfour-midi_sanitize

filters incoming MIDI data and simplifies.

this allows quickly dropping MIDI files into the project and immediately use the note data, 
without worrying about noisy MIDI data like program changes, sysex stuff, or other weird CC data messing with your VSTi.

originally intended for exporting Finale MIDI, and importing directly into Reaper without any modification necessary.

but maybe the most general-purpose useful feature is mapping velocity based on input / output range.
 
