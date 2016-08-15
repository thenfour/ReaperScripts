
dofile(reaper.GetResourcePath().."/Scripts/tenfour-step/include/tenfour-foundation.lua")
reaper.Undo_BeginBlock()
DBG("tenfour")
DBG("{")

addDotToHeldNotesDuration()

DBG("}")
reaper.Undo_EndBlock("tenfour - add dotted duration to held notes", -1)

