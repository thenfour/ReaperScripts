-- insert a WHOLE note at the edit cursor.


dofile(reaper.GetResourcePath().."/Scripts/tenfour-step/include/tenfour-foundation.lua")
reaper.Undo_BeginBlock()
DBG("tenfour")
DBG("{")

insertPlayingMIDINotesAtCursor({
	noteLengthQN = 4
})

reaper.Undo_EndBlock("tenfour - step record whole note", -1)

DBG("}")
