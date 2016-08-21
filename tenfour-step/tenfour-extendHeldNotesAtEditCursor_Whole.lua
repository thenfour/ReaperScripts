dofile(reaper.GetResourcePath().."/Scripts/tenfour-step/include/tenfour-foundation.lua")

reaper.Undo_BeginBlock()
DBG("tenfour")
DBG("{")

extendPlayingMIDINotesAtCursor({
	noteLengthQN = 4
})

reaper.Undo_EndBlock("tenfour - Extend held notes ending at cursor by whole note", -1)

DBG("}")
