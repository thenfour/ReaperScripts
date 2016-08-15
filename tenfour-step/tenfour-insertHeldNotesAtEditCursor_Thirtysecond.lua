-- insert a 32nd note at the edit cursor.


dofile(reaper.GetResourcePath().."/Scripts/tenfour-step/include/tenfour-foundation.lua")

reaper.Undo_BeginBlock()
DBG("tenfour")
DBG("{")

insertPlayingMIDINotesAtCursor({
	noteLengthQN = 1/8
})

reaper.Undo_EndBlock("tenfour - step record thirty second note", -1)

DBG("}")
