--[[

this script will 

1. position your cursor at the start of a chord within a media item.
2. run this script

the HIGHEST note of the chord starting at the edit cursor will be transposed an octave LOWER.
basically inverting the chord DOWNWARDS.

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
local oldNotes = getNotesStartingAtCursor(take, track)-- returns sorted top to bottom
if #oldNotes < 1 then
	DBG("Can't nothing to rotate.")
	return
end


reaper.MIDI_SetNote(take, oldNotes[1].index, nil, nil, nil, nil, nil, oldNotes[1].pitch -12, nil, nil)


DBG("}")
reaper.Undo_EndBlock("tenfour - Rotate voicing down at edit cursor", -1)

