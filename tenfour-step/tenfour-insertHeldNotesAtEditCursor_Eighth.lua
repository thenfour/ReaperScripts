-- insert a EIGHTH note at the edit cursor.


dofile(reaper.GetResourcePath().."/Scripts/tenfour-step/include/tenfour-foundation.lua")

reaper.Undo_BeginBlock()
DBG("tenfour")
DBG("{")

insertPlayingMIDINotesAtCursor({
	noteLengthQN = 1/2
})

reaper.Undo_EndBlock("tenfour - step record eighth note", -1)

DBG("}")
