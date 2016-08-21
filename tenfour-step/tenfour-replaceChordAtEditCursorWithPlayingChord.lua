--[[

this script will 

1. position your cursor at the start of a chord within a media item.
2. hold a chord on your MIDI keyboard
3. run this script

The existing notes will be replaced with the ones you're playing.
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

replaceChord(take, oldNotes, newNotes)

reaper.UpdateItemInProject(mediaItem)


DBG("}")
reaper.Undo_EndBlock("tenfour - Replace chord at edit cursor with playing chord", -1)

