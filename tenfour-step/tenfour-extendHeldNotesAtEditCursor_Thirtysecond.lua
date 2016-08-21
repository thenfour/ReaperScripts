dofile(reaper.GetResourcePath().."/Scripts/tenfour-step/include/tenfour-foundation.lua")

reaper.Undo_BeginBlock()
DBG("tenfour")
DBG("{")

extendPlayingMIDINotesAtCursor({
	noteLengthQN = 1/8
})

reaper.Undo_EndBlock("tenfour - Extend held notes ending at cursor by thirty-second note", -1)

DBG("}")
