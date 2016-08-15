
dofile(reaper.GetResourcePath().."/Scripts/tenfour-step/include/tenfour-foundation.lua")
reaper.Undo_BeginBlock()
DBG("tenfour")
DBG("{")

moveCursorByGridSizeAndAlterDurationOfHeldNotes(-1)

DBG("}")
reaper.Undo_EndBlock("tenfour - move Cursor Left By Grid Size And Alter Duration Of Held Notes", -1)

