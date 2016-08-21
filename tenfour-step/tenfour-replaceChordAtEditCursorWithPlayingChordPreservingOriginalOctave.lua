--[[

this script will 

1. position your cursor at the start of a chord within a media item.
2. hold a chord on your MIDI keyboard
3. run this script

The existing notes will be replaced with the ones you're playing.
The original octave will be preserved, so you don't have to spend much time searching for the right octave.
Original velocities & everything else preserved
If you are holding more notes than were originally held, we insert them.
If you are holding fewer notes than originally, we remove existing ones.


--]]


dofile(reaper.GetResourcePath().."/Scripts/tenfour-step/include/tenfour-foundation.lua")
reaper.Undo_BeginBlock()
DBG("tenfour")
DBG("{")

-- get context
local take = findExistingTake()
if not take then
	DBG("unable to create a take i guess; abandoning")
	return
end
local mediaItem = reaper.GetMediaItemTake_Item(take)
local track = reaper.GetMediaItemTake_Track(take)
local newNotes = getHeldNotes(track)-- an array of { note, chan, velocity }
if #newNotes < 1 then
	DBG("Not holding any notes. Ignore")
	return
end
local oldNotes = getNotesStartingAtCursor(take, track)-- oldNotes is an array of { index, pitch, velocity, channel, startPPQ, endPPQ }, sorted top to bottom
if #oldNotes < 1 then
	DBG("Can't replace a chord when there's no existing.")
	return
end

-- the algorithm we'll use:
-- find the center pitch of original
-- find the center pitch of new
-- shift octave until new is within 1 octave of old.
-- commit.
local i
local oldCenter = 0
for i = 1, #oldNotes do
	oldCenter = oldCenter + oldNotes[i].pitch
end
oldCenter = oldCenter / #oldNotes

-- find new center pitch.
local newCenter = 0
for i = 1, #newNotes do
	newCenter = newCenter + newNotes[i].note
end
newCenter = newCenter / #newNotes

-- and calculate the # of semitones to transpose
local corr = 12 * round((oldCenter - newCenter) / 12)
DBG("correction: "..corr)
-- and transpose the new pitches accordingly.
for i = 1, #newNotes do
	newNotes[i].note = newNotes[i].note + corr
end

replaceChord(take, oldNotes, newNotes)
reaper.UpdateItemInProject(mediaItem)


DBG("}")
reaper.Undo_EndBlock("tenfour - Replace chord at edit cursor with playing chord preserving original octave", -1)

