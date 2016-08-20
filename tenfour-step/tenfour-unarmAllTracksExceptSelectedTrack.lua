
dofile(reaper.GetResourcePath().."/Scripts/tenfour-step/include/tenfour-foundation.lua")
reaper.Undo_BeginBlock()
DBG("tenfour")
DBG("{")


local trackCount = reaper.GetNumTracks()

for i = 0, trackCount - 1 do
	local track = reaper.GetTrack(0, i)-- as MediaTrack

	local name, state = reaper.GetTrackState(track)
	-- Gets track state, returns track name.
	-- flags will be set to:
	-- &1=folder
	-- &2=selected
	-- &4=has fx enabled
	-- &8=muted
	-- &16=soloed
	-- &32=SIP'd (with &16)
	-- &64=rec armed
	if hasbit(state, 2) and not hasbit(state, 64) then
		reaper.SetMediaTrackInfo_Value(track, "I_RECARM", 0)
	end
end



DBG("}")
reaper.Undo_EndBlock("tenfour - Unarm all tracks except selected track", -1)

