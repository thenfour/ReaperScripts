-- insert a QUARTER note at the edit cursor.


dofile(reaper.GetResourcePath().."/Scripts/tenfour-step/include/tenfour-foundation.lua")

reaper.Undo_BeginBlock()
DBG("tenfour")
DBG("{")

insertPlayingMIDINotesAtCursor({
	noteLengthQN = 1
})

reaper.Undo_EndBlock("tenfour - step record quarter note", -1)

DBG("}")
