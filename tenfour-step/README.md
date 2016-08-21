
#tenfour-step
A collection of [Reaper](http://www.reaper.fm/) actions for an efficient MIDI editing workflow. My goal is to create fundamental actions that are practical and simple to understand. Sometimes an ultra efficient workflow can mean sophisticated actions that require a lot of learning or a certain mindset that don't necessarily translate well to other workflows.

I want to avoid that. I want to create actions that would slip into any workflow. So I try to keep things non-destructive, intuitive, and fundamental. Trying to hit the "sweet spot" of usability. I don't want to have to memorize anything or try to predict what an action will do.

##Quick Start / Tutorial
Tenfour-step is a bunch of actions for step-recording note-by-note. What used to rely on "modes" (like step recording being enabled), or many keystrokes, now is reduced to a single keystroke.

Example: Hold a chord on your MIDI keyboard, and hit "5" on your computer keyboard to step-record the chord you're playing to the current track.

Here's a 3-minute video I made to quickly demonstrate what this script does: https://www.youtube.com/watch?v=07gs0X6StM4

I should probably make more videos as I make updates. Reading goes against my principle of making everything as intuitive & simple as possible.

##Dev Status
Pre-Alpha.

As of Aug 2016, I just started this and I am making pretty sweeping changes at the moment, trying to figure out exactly the right combination of features. For example I gave up on the concept of "add dotted length". I think it's much simpler to just extend the duration by a specified length. When things settle in and big changes slow down, then I would feel comfortable saying it's stable.

Things definitely work, and I'm using it. But it cannot be considered stable without more testing under different configurations and workflows.

##Installation
Copy the "tenfour-step" folder to your Reaper scripts directory. The result on Mac should look be:

    /Users/carl/Library/Application Support/REAPER/Scripts/tenfour-step

The scripts should work equally well on Windows, though I haven't tested it, and I don't know where the scripts directory is on Windows.

Once the files are copied, you can immediately assign the scripts to key bindings via the Action List. Or, to use my default keys, edit / import the packaged `tenfour-step-main.ReaperKeyMap` and `tenfour-step-midieditor.ReaperKeyMap`.


##List of Scripts & Default Keybindings
| Key   | Script |
|----------|-------------|
| shift+4 | tenfour-extendHeldNotesAtEditCursor_Eighth.lua |
| shift+6 | tenfour-extendHeldNotesAtEditCursor_Half.lua |
| shift+5 | tenfour-extendHeldNotesAtEditCursor_Quarter.lua |
| shift+3 | tenfour-extendHeldNotesAtEditCursor_Sixteenth.lua |
| shift+2 | tenfour-extendHeldNotesAtEditCursor_Thirtysecond.lua |
| shift+7 | tenfour-extendHeldNotesAtEditCursor_Whole.lua |

| Key   | Script |
|----------|-------------|
| 4 | tenfour-insertHeldNotesAtEditCursor_Eighth.lua |
| 6 | tenfour-insertHeldNotesAtEditCursor_Half.lua |
| 5 | tenfour-insertHeldNotesAtEditCursor_Quarter.lua |
| 3 | tenfour-insertHeldNotesAtEditCursor_Sixteenth.lua |
| 2 | tenfour-insertHeldNotesAtEditCursor_Thirtysecond.lua |
| 7 | tenfour-insertHeldNotesAtEditCursor_Whole.lua |

| Key   | Script |
|----------|-------------|
| shift+left | tenfour-moveCursorLeftByGridSizeAndAlterDurationOfHeldNotes.lua |
| shift+right | tenfour-moveCursorRightByGridSizeAndAlterDurationOfHeldNotes.lua |
| enter | tenfour-replaceChordAtEditCursorWithPlayingChord.lua |
| shift+enter | tenfour-replaceChordAtEditCursorWithPlayingChordPreservingOriginalOctave.lua |
| alt+down | tenfour-rotateVoicingDownAtEditCursor.lua |
| alt+up | tenfour-rotateVoicingUpAtEditCursor.lua |
| Z | tenfour-unarmAllTracksExceptSelectedTrack.lua |








##Technical Info / Caveats
* `tenfour-MIDIChordState` will end up being tacked on to every track this uses.
* It also means the first time you run the script, it won't do anything. It will act like you haven't pressed anything. Nothing was listening.


##[TODO](TODO.md)


##Questions / Contact
Feel free to contact me via twitter [@tenfour2](https://twitter.com/tenfour2). I am pretty new to Reaper so don't hesitate to give me feedback / tips / design ideas / feature requests / criticism / patches.

Official repository at https://github.com/thenfour/ReaperScripts


##Change Log
https://github.com/thenfour/ReaperScripts/commits/master


##Background / Motivation Rant
While I have made this code public, the ongoing intention is for my own use. So there may be actions that are indeed useless to other users. Or actions that have bugs I'll never fix because I don't use it that way. Feel free to send me feature requests / suggestions / patches.

I have spent most of my composing time in [Renoise](http://renoise.com/), and arranging scores in [Finale](http://www.finalemusic.com/). Both are very different from a horizontal DAW like Reaper, and have certain workflow characteristics I wanted to bring to Reaper.

Renoise is excellent for drum programming. Its vertical orientation means I can see each drum on its own track, but in a space-efficient way so I can see a whole overview of the drum pattern. When I switched to Reaper I felt pretty restricted regarding drums. I find myself forced to use a drum kit style approach, which imposes tons of limitations. Whereas Renoise lets of be as complex as you want and you'll never lose accuracy in the DAW, Reaper's piano roll gets harder and harder to read the more complex the drum pattern is. Renoise lets you keep each drum sample on different tracks yet they all remain in view. Reaper layers them all on top of each other so they easily get in the way of each other. In the end I'm forced for practical reasons to use a general MIDI style drum kit, and simply abandon techniques I found accessible on Renoise.

And Finale is especially good for composing melodies. In particular, its Quick Edit mode lets me keep my right hand on the MIDI keyboard, my left hand on the computer keyboard, and I can write an entire song this way, barely ever touching the mouse.

My workflow in Finale was something like this

1. Play around and find a melody on my keyboard. OK I think I got something that works.
2. Hold a note
3. Press "5" to step-record it as a quarter note.
4. Hold the next note, maybe play around more on the keyboard.
5. Press "4" to step-record it as an eighth note.

Step recording is already possible in Reaper, but it's a mode you must turn on / off. And you must set a global "note length". So my above workflow would go more like this:

1. Ensure step recording is disabled
2. Play around and find a melody.
3. Turn step recording on.
4. Ensure I have the right note length selected
5. Hit a note.
6. Disable step recording
7. Play around more on the keyboard
8. Re-enable step recording
9. Select eighth note length
10. Hit a note.

This is a lot of actions, but even more important is the fact that it relies on "modes". I don't want to have to keep track of what "mode" I'm in. I want to *always* have the freedom to play around on the keyboard, and *always* have the option of step recording with a single keystroke. Tenfour-step accomplishes this.

A minor benefit is that it allows me to make sure I hit the right velocity BEFORE committing it to my track. With native step recording, if I hit the note too softly, I have to undo and try again. With tenfour-step, I hit the note until I get it right, then record it when it's perfect.

Live recording is also not my preferred method of entry, because it means setting up metronome / countoff, and then tweaking afterwards. I find it faster to get perfect results with step recording.

I haven't quite solved the drum programming issues is Reaper, but as I work, I may find more and more ways to improve things. In an ideal world, Reaper would have a full-on "tracker view". I have seen forum threads where it's been proposed but there appears to be not much momentum for its implementation. I might consider an extension that allows something like a tracker view.

As for Finale though, its workflow is more action-oriented and translates perfectly to the way Reaper supports scripts. Most of tenfour-step is the result of this inspiration.