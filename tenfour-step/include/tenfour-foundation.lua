--[[

TODO:
- better updating of the JSFX
- more professional function scoping/naming
--]]

----------------------------------------------------------------------------------
function DBG(str)
  --reaper.ShowConsoleMsg(str.."\n")
end


----------------------------------------------------------------------------------
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

----------------------------------------------------------------------------------
function hasbit(x, p)
  return x % (p + p) >= p       
end

----------------------------------------------------------------------------------
function setbit(x, p)
  return hasbit(x, p) and x or x + p
end

----------------------------------------------------------------------------------
function clearbit(x, p)
  return hasbit(x, p) and x - p or x
end



----------------------------------------------------------------------------------
local function IsInMIDIEditor()
	-- this is not as straight-forward as it should be.
	-- you can have an active MIDI editor, but it's totally hidden & you're focused in the
	-- arranger view. the only way I've found to detect this is:
	return reaper.GetCursorContext() == -1
end

----------------------------------------------------------------------------------
local function IsMultipleOf(a, b, slop)
	local d = a/b
	local intPart,fract = math.modf(d + (slop / 2))
	local ret = math.abs(fract) < math.abs(slop)
	return ret
end

----------------------------------------------------------------------------------
-- mapping of QN durations and command IDs for midi editor and main window

-- GRID (midi editor):
-- 1 = 40204
-- 1/2 = 40203
-- 1/4 = 40201
-- 1/8 = 40197
-- 1/16 = 40192
-- 1/32 = 40190
-- 1/64 = 41020

-- GRID (main):
-- 1 = 40781
-- 1/2 = 40780
-- 1/4 = 40779
-- 1/8 = 40778
-- 1/16 = 40776
-- 1/32 = 40775
-- 1/64 = 40774

local gridDivisions = {
	whole = { QN = 4, mecid = 40204, maincid = 40781, desc = "whole" },
	half = { QN = 2, mecid = 40203, maincid = 40780, desc = "half" },
	quarter = { QN = 1, mecid = 40201, maincid = 40779, desc = "quarter" },
	eighth = { QN = 1/2, mecid = 40197, maincid = 40778, desc = "eighth" },
	sixteenth = { QN = 1/4, mecid = 40192, maincid = 40776, desc = "sixteenth" },
	thirtysecond = { QN = 1/8, mecid = 40190, maincid = 40775, desc = "thirtysecond" },
	sixtyfourth = { QN = 1/16, mecid = 41020, maincid = 40774, desc = "sixtyfourth" },
}

-- returns one of the values in gridDivisions
local function findBestGridValueForTime(t, maxDivisionQN)
	local beatsSinceMeasure, _, _, _, _ = reaper.TimeMap2_timeToBeats(0, t)

	-- just pick a really small value to help rounding
	local leewayQN = gridDivisions.sixtyfourth.QN / 8.;

	if (gridDivisions.whole.QN <= maxDivisionQN) and IsMultipleOf(beatsSinceMeasure, gridDivisions.whole.QN, leewayQN) then
		return gridDivisions.whole
	elseif (gridDivisions.half.QN <= maxDivisionQN) and IsMultipleOf(beatsSinceMeasure, gridDivisions.half.QN, leewayQN) then
		return gridDivisions.half
	elseif (gridDivisions.quarter.QN <= maxDivisionQN) and IsMultipleOf(beatsSinceMeasure, gridDivisions.quarter.QN, leewayQN) then
		return gridDivisions.quarter
	elseif (gridDivisions.eighth.QN <= maxDivisionQN) and IsMultipleOf(beatsSinceMeasure, gridDivisions.eighth.QN, leewayQN) then
		return gridDivisions.eighth
	elseif (gridDivisions.sixteenth.QN <= maxDivisionQN) and IsMultipleOf(beatsSinceMeasure, gridDivisions.sixteenth.QN, leewayQN) then
		return gridDivisions.sixteenth
	elseif (gridDivisions.thirtysecond.QN <= maxDivisionQN) and IsMultipleOf(beatsSinceMeasure, gridDivisions.thirtysecond.QN, leewayQN) then
		return gridDivisions.thirtysecond
	elseif (gridDivisions.sixtyfourth.QN <= maxDivisionQN) and IsMultipleOf(beatsSinceMeasure, gridDivisions.sixtyfourth.QN, leewayQN) then
		return gridDivisions.sixtyfourth
	end

	return nil
end

----------------------------------------------------------------------------------

-- accepts an item from gridDivisions
local function setGridDivision(divData)
	if not divData then
		DBG("won't set grid division without data.")
		return
	end

	if divData.mecid then
		local midiEditor = reaper.MIDIEditor_GetActive()
	  local mode = reaper.MIDIEditor_GetMode(midiEditor)
	  if IsInMIDIEditor() and (mode ~= -1) then-- -1 if ME not focused
	  	DBG("running MIDI Editor command "..divData.mecid)
			reaper.MIDIEditor_OnCommand(midiEditor, divData.mecid)
		end
	end

	if divData.maincid then
	  DBG("running Main command "..divData.maincid)
		reaper.Main_OnCommand(divData.maincid, 0)
	end
end


-- considers the length of the note we just entered. never allows 
local function adjustGridToCursorAndInsertedNote(noteLengthQN)
	local divData = findBestGridValueForTime(reaper.GetCursorPosition(), noteLengthQN)
	setGridDivision(divData);
end



----------------------------------------------------------------------------------

function MoveEditCursorByGridSize(gridSteps)
	local maincid = 40646-- left
	local mecid = 40047
	if gridSteps == 1 then
		mecid = 40048
		maincid = 40647
	end

	local midiEditor = reaper.MIDIEditor_GetActive()
  local mode = reaper.MIDIEditor_GetMode(midiEditor)
  if IsInMIDIEditor() and (mode ~= -1) then-- -1 if ME not focused
		reaper.MIDIEditor_OnCommand(midiEditor, mecid)
		return
	end

	reaper.Main_OnCommand(maincid, 0)
end


----------------------------------------------------------------------------------
local jsfx={} --store details of helper effect
jsfx.name="tenfour-MIDIChordState"
jsfx.fn="tenfour-MIDIChordState"-- filename
jsfx.paramIndex_Active = 0
jsfx.paramIndex_NotesInBuffer = 1
jsfx.paramIndex_NoteQueryIndex = 2
jsfx.paramIndex_NoteValue = 3
jsfx.paramIndex_Channel = 4
jsfx.paramIndex_Velocity = 5
jsfx.body=[[
desc:tenfour-MIDIChordState

slider1:0<0,1,1{On,Off}>Active (eats notes)
slider2:0<0,127,1>Notes in buffer
slider3:0<0,1000,1>Note Query Index
slider4:0<0,127,1>Output Pitch
slider5:0<0,15,1>Output channel
slider6:0<0,127,1>Output velocity


@init
notebuf=0; //start pos of buffer
nb_width=3; //number of entries per note
buflen=0; //notes in buffer

function addRemoveNoteFromBuffer(m1,m2,m3)
( 
  s = m1&$xF0;
  c = m1&$xF; // channel
  n = m2;// note
  v = m3; // velocity
  
  init_buflen=buflen;
  
  i = -1;
  while // look for this note|channel already in the buffer
  (
    i = i+1;
    i < buflen && (notebuf[nb_width*i]|0 != n || notebuf[nb_width*i+1]|0 != c);
        );

    (s == $x90 && v > 0) ? // note-on, add to buffer
    ( 
      notebuf[nb_width*i] = n;
      notebuf[nb_width*i+1] = c;
      notebuf[nb_width*i+2] = v;
      i == buflen ? buflen = buflen+1;
    ) 
    : // note-off, remove from buffer
    (
      i < buflen ?
      (
         memcpy(notebuf+nb_width*i, notebuf+nb_width*(i+1),
                      nb_width*(buflen-i-1));  // delete the entry
         buflen = buflen-1;
       );
    );
    buflen==init_buflen ? -1; //return value for nothing added/removed
);


@slider
p=slider3*nb_width; //position in buffer
slider4=notebuf[p]; // note
slider5=notebuf[p+1]; // channel
slider6=notebuf[p+2]; // velocity


@block
while (midirecv(offset,msg1,msg2,msg3))
(
  (msg1&$xF0==$x90) ?
  	addRemoveNoteFromBuffer(msg1,msg2,msg3);

  (msg1&$xF0==$x80) ?
    addRemoveNoteFromBuffer(msg1,msg2,msg3);
  
  slider2=buflen;
  midisend(offset,msg1,msg2,msg3);
)
]]


----------------------------------------------------------------------------------
-- file op
local function createJSEffect(fn,str)
  local file=io.open(reaper.GetResourcePath().."/Effects/"..fn, "w")
  file:write(str)
  file:close()
end

-- file op
local function deleteJSEffect(fx)
  os.remove(reaper.GetResourcePath().."/Effects/"..fx.fn)
end

-- add the given fx to the given track.
local function getOrAddInputFx(track,fx,create_new)
  local idx=reaper.TrackFX_AddByName(track,fx.name,true,1)
  if idx==-1 or idx==nil then
    idx=reaper.TrackFX_AddByName(track,fx.fn,true,1)
    if (idx==nil or idx==-1) and create_new==true then
      createJSEffect(fx.fn,fx.body)
      idx=getOrAddInputFx(track,fx,false)
      return idx
    else 
      tr=nil
      return -1
    end
  end
  idx=idx|0x1000000 -- why the OR?
  --reaper.TrackFX_SetEnabled(track, idx, true)
  return idx
end


----------------------------------------------------------------------------------
-- returns the relevant take for the midi editor, or selected track, at edit cursor.
function findExistingTake()
	local take = nil

	local midiEditor = reaper.MIDIEditor_GetActive()
  local mode = reaper.MIDIEditor_GetMode(midiEditor)
  if IsInMIDIEditor() and (mode ~= -1) then-- -1 if ME not focused
		--DBG("In MIDI editor; mode "..mode)
    take = reaper.MIDIEditor_GetTake(midiEditor)
		if reaper.ValidatePtr(take, 'MediaItem_Take*') then--check that it's an actual take (in case of empty MIDI editor)
			return take
		end
		--DBG("no valid current take in midi editor.")
	end

	-- attempt to find take by selected track / cursor pos.
	--DBG("attempt to find take by selected track / cursor pos.")
	local selectedTrackCount = reaper.CountSelectedTracks(0)
	if selectedTrackCount < 1 then
		--DBG("no selected track anyway...")
		return nil
	end

	local track = reaper.GetSelectedTrack(0, 0)
	local cursorPos = reaper.GetCursorPosition()

	-- todo: is there a more efficient way to search for a media item
	local mediaItemCount = reaper.CountTrackMediaItems(track)
	for i = 0, mediaItemCount - 1 do
		local mediaItem = reaper.GetTrackMediaItem(track, i)
		local pos = reaper.GetMediaItemInfo_Value(mediaItem, "D_POSITION")
		local len = reaper.GetMediaItemInfo_Value(mediaItem, "D_LENGTH")
		--DBG("media item "..i.." / pos "..pos.." / len "..len.." / cursorpos "..cursorPos)
		if cursorPos >= pos and cursorPos <= (pos + len) then
			--DBG("this media item works fine.")
			return reaper.GetActiveTake(mediaItem)
		end
	end

	return nil
end


local function createTake(takeStart, takeEnd)
	local selectedTrackCount = reaper.CountSelectedTracks(0)
	if selectedTrackCount < 1 then
		DBG("no selected track to create a take...")
		return nil
	end
	local track = reaper.GetSelectedTrack(0, 0)
	local newItem = reaper.CreateNewMIDIItemInProj(track, takeStart, takeEnd)
	return reaper.GetActiveTake(newItem)
end


-- TECHNICALLY, this has a bug.
-- "media item end time" is different than "midi item extents". midi items can have a longer
-- length than their "extent".
local function ensureTakePosLastsUntil(take, requestedEndTime)
	local mediaItem = reaper.GetMediaItemTake_Item(take)

  local existingStartTime = reaper.GetMediaItemInfo_Value(mediaItem, "D_POSITION")
  local existingLength = reaper.GetMediaItemInfo_Value(mediaItem, "D_LENGTH")
  local existingEndTime = existingStartTime + existingLength
  if(existingEndTime >= requestedEndTime) then
  	--DBG("not adjusting take length. "..existingEndTime.." >= "..requestedEndTime)
  	return
  end

  local existingStartQN = reaper.TimeMap2_timeToQN(0, existingStartTime)

  local newEndQN = reaper.TimeMap2_timeToQN(0, requestedEndTime)

 	-- DBG("Adjusting take length because "..existingEndTime.." < "..requestedEndTime)
 	-- DBG("  existingEndTime: "..existingEndTime)
 	-- DBG("  requestedEndTime: "..requestedEndTime)
 	-- DBG("  existingStartTime: "..existingStartTime)
 	-- DBG("  existingStartQN: "..existingStartQN)
 	-- DBG("  newEndQN: "..newEndQN)

	reaper.MIDI_SetItemExtents(mediaItem, existingStartQN, newEndQN)

end


-- returns begin, end time for the measure
local function SnapToMeasure(time)
	local beatsSinceMeasure, _, cml, fullbeats, _ = reaper.TimeMap2_timeToBeats(0, time)
	local measureStartBeats = fullbeats - beatsSinceMeasure
	local measureStart = reaper.TimeMap2_beatsToTime(0, measureStartBeats)
	local nextMeasureStart = reaper.TimeMap2_beatsToTime(0, measureStartBeats + cml)
	return measureStart, nextMeasureStart
end


-- returns an array of { note, chan, velocity }
function getHeldNotes(track)

	local iHelper = getOrAddInputFx(track, jsfx, true)

	-- read the notes of the helper fx
	local heldNoteCount = reaper.TrackFX_GetParam(track, iHelper, jsfx.paramIndex_NotesInBuffer)
  local pitches={}

	if heldNoteCount < 1 then
		return pitches
	end

  for i = 1, heldNoteCount, 1 do
    reaper.TrackFX_SetParam(track, iHelper, jsfx.paramIndex_NoteQueryIndex, i - 1)
    -- now the plugin updates its sliders to give us the values for this index.
    pitches[#pitches+1] = {}
    pitches[#pitches].note, _, _ = reaper.TrackFX_GetParam(track, iHelper, jsfx.paramIndex_NoteValue)
    pitches[#pitches].chan = reaper.TrackFX_GetParam(track, iHelper, jsfx.paramIndex_Channel)
    pitches[#pitches].velocity = reaper.TrackFX_GetParam(track, iHelper, jsfx.paramIndex_Velocity)
    --DBG("   held note "..pitches[#pitches].note.." / vel "..pitches[#pitches].velocity)
  end
  return pitches
end

function insertPlayingMIDINotesAtCursor(options)
	local take = findExistingTake()
	local noteStartTime = reaper.GetCursorPosition()
	local noteStartQN = reaper.TimeMap2_timeToQN(0, noteStartTime)
	local noteEndTime = reaper.TimeMap2_QNToTime(0, noteStartQN + options.noteLengthQN)

	if not take then
		-- create starting at measure end, add note len, snap to measure end.
		local takeStart, _ = SnapToMeasure(noteStartTime)
		local _, takeEnd = SnapToMeasure(noteEndTime)
		take = createTake(takeStart, takeEnd)
	else
		local _, takeEnd = SnapToMeasure(noteEndTime)
		ensureTakePosLastsUntil(take, takeEnd)
	end

	if not take then
		DBG("unable to create a take i guess; abandoning")
		return
	end

	local mediaItem = reaper.GetMediaItemTake_Item(take)
	local track = reaper.GetMediaItemTake_Track(take)

	local pitches = getHeldNotes(track)
	if #pitches > 0 then
		-- you're holding notes on your MIDI keyboard; add them to the take

		local noteStartPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, noteStartTime)-- convert to PPQ
		local noteEndPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, noteEndTime)-- convert to PPQ

		-- insert them.
		for k,v in pairs(pitches) do
			DBG("  inserting note "..v.note.." from ["..noteStartPPQ.." -> "..noteEndPPQ.."]")
			reaper.MIDI_InsertNote(take, true, false, noteStartPPQ, noteEndPPQ, v.chan, v.note, v.velocity)
		end
	end

	reaper.UpdateItemInProject(mediaItem)-- make certain the project bounds has been updated to reflect the newly recorded item
	reaper.MoveEditCursor(noteEndTime - reaper.GetCursorPosition(), false)

	adjustGridToCursorAndInsertedNote(options.noteLengthQN)
end

----------------------------------------------------------------------------------
-- for functions that assume you just added notes.
-- your cursor should be sitting on the end of notes you're playing.
-- this function returns a bunch of info about the current status.
--
-- returns:
-- take, track, heldPitches, heldNoteIndices, oldDurationPPQ
function getExistingHeldNotesInfo()
	local take = findExistingTake()
	if not take then
		DBG("can't elongate notes; no available take.")
		return
	end

	local track = reaper.GetMediaItemTake_Track(take)

	local pitches = getHeldNotes(track)

	-- find the notes in the current take corresponding to that.
	-- basically enum notes and find ones that end near the cursor AND are being held
	local cursorTime = reaper.GetCursorPosition();
	local cursorPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, cursorTime)

	--Lua: integer retval, number notecntOut, number ccevtcntOut, number textsyxevtcntOut
	local ret, noteCount, _, _ = reaper.MIDI_CountEvts(take)
	--DBG("count events? ret="..ret..", noteCount="..noteCount)

	-- let's build a list of note indices corresponding to the notes you're holding down
	-- at the same time, figure out the duration of those notes. for simplicity, just take the first duration.
	local oldDurationPPQ
	local heldIndices = {}
	for i = 0, noteCount - 1 do
		local _, selected, muted, startppq, endppq, _, pitch, _ = reaper.MIDI_GetNote(take, i)
		--DBG("note "..i.." startppq="..startppq.." endppq="..endppq.." cursorppq="..cursorPPQ.." pitch="..pitch)
		for _,v in pairs(pitches) do
			if (v.note == pitch) and math.abs(endppq - cursorPPQ) < 5 then
				heldIndices[#heldIndices + 1] = i
				oldDurationPPQ = endppq - startppq
			end
		end
	end

	return take, track, pitches, heldIndices, oldDurationPPQ, cursorTime, cursorPPQ
end




----------------------------------------------------------------------------------
-- returns an array of { index, pitch, velocity, channel, startPPQ, endPPQ }, sorted from top to bottom
function getNotesStartingAtCursor(take, track)
	-- basically enum notes and find ones that start near the cursor
	local cursorTime = reaper.GetCursorPosition();
	local cursorPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, cursorTime)

	--Lua: integer retval, number notecntOut, number ccevtcntOut, number textsyxevtcntOut
	local ret, noteCount, _, _ = reaper.MIDI_CountEvts(take)

	-- let's build a list of note indices corresponding to the notes you're holding down
	-- at the same time, figure out the duration of those notes. for simplicity, just take the first duration.
	local notes = {}
	for i = 0, noteCount - 1 do
		local _, _, _, startPPQ, endPPQ, channel, pitch, velocity = reaper.MIDI_GetNote(take, i)
		--DBG("is note "..i..", ")
		if math.abs(startPPQ - cursorPPQ) < 5 then
			notes[#notes + 1] = {
				index = i,
				pitch = pitch,
				velocity = velocity,
				channel = channel,
				startPPQ = startPPQ,
				endPPQ = endPPQ
			}
		end
	end

	table.sort(notes, function(a, b)
		return a.pitch >= b.pitch
		end);

	return notes
end

----------------------------------------------------------------------------------
function addDotToHeldNotesDuration()
	local take, track, _, heldIndices, oldDurationPPQ, cursorTime, cursorPPQ = getExistingHeldNotesInfo()

	local take = findExistingTake()
	if not take then
		DBG("can't elongate notes; no available take.")
		return
	end
	if #heldIndices < 1 then
		DBG("no relevant notes to elongate; abandoning")
		return
	end

	-- we want to add a little bit to help nudge the algorithm. basically if your note length is 0.9999 beats, 
	-- we want it to satisfy the comparison "is at least a beat?"
	oldDurationPPQ = oldDurationPPQ + 1
	local oldDurationQN = reaper.MIDI_GetProjQNFromPPQPos(take, oldDurationPPQ)
	--DBG("old duration (QN): "..oldDurationQN..", ppq="..oldDurationPPQ)

	-- calculate the elongation / new end ppq
	-- in almost all cases, and even cases that aren't obvious, what you really want to do is subdivide the grid.
	-- so take the existing "ideal" grid, and just divide it in half.
	local dotDivData = findBestGridValueForTime(cursorTime, oldDurationQN)
	if not dotDivData then
		DBG("no suitable division found. maybe note too short.")
		return
	end

	--DBG("dot duration chosen QN: "..(dotDivData.QN/2)..", desc=half of "..dotDivData.desc)

	--local cursorTime = 
	--local cursorPPQ = 
	local cursorQN = reaper.MIDI_GetProjQNFromPPQPos(take, cursorPPQ)

	local newEndQN = cursorQN + (dotDivData.QN/2)
	local newEndPPQ = reaper.MIDI_GetPPQPosFromProjQN(take, newEndQN)
	local newEndTime = reaper.MIDI_GetProjTimeFromPPQPos(take, newEndPPQ)

	-- ensure the take is big enough to hold the new duration. snap it.
	local _, takeEnd = SnapToMeasure(newEndTime)
	ensureTakePosLastsUntil(take, takeEnd)

	for i = 1, #heldIndices do
		reaper.MIDI_SetNote(take, heldIndices[i], nil, nil, nil, newEndPPQ, nil, nil, nil, nil)
	end

	local mediaItem = reaper.GetMediaItemTake_Item(take)
	reaper.UpdateItemInProject(mediaItem)-- make certain the project bounds has been updated to reflect the newly recorded item
	reaper.MoveEditCursor(newEndTime - reaper.GetCursorPosition(), false)

	adjustGridToCursorAndInsertedNote(dotDivData.QN/2)

end


----------------------------------------------------------------------------------
function moveCursorByGridSizeAndAlterDurationOfHeldNotes(gridSteps)
	local take, track, _, heldIndices, oldDurationPPQ, cursorTime, cursorPPQ = getExistingHeldNotesInfo()

	local take = findExistingTake()
	if not take then
		DBG("can't change note duration; no available take.")
		MoveEditCursorByGridSize(gridSteps)
		return
	end
	if #heldIndices < 1 then
		DBG("no relevant notes to elongate; abandoning")
		MoveEditCursorByGridSize(gridSteps)
		return
	end

	local gridSizeQN, _, _ = reaper.MIDI_GetGrid(take)
	local cursorQN = reaper.MIDI_GetProjQNFromPPQPos(take, cursorPPQ)

	-- another option for finding the new cursor pos is reaper.SnapToGrid(ReaProject project, number time_pos)
	-- doubt it matters.
	local newEndQN = cursorQN + (gridSizeQN * gridSteps)
	local newEndPPQ = reaper.MIDI_GetPPQPosFromProjQN(take, newEndQN)
	local newEndTime = reaper.MIDI_GetProjTimeFromPPQPos(take, newEndPPQ)

	-- ensure the take is big enough to hold the new duration. snap it.
	local _, takeEnd = SnapToMeasure(newEndTime)
	ensureTakePosLastsUntil(take, takeEnd)

	-- no need to ever extend the media leftwards, because we don't allow setting negative durations.

	-- speaking of which, make sure NO notes will get negative durations.

	for i = 1, #heldIndices do
		reaper.MIDI_SetNote(take, heldIndices[i], nil, nil, nil, newEndPPQ, nil, nil, nil, nil)
	end

	local mediaItem = reaper.GetMediaItemTake_Item(take)
	reaper.UpdateItemInProject(mediaItem)-- make certain the project bounds has been updated to reflect the newly recorded item
	reaper.MoveEditCursor(newEndTime - reaper.GetCursorPosition(), false)
end



----------------------------------------------------------------------------------
-- oldNotes is an array of { index, pitch, velocity, channel, startPPQ, endPPQ }, sorted top to bottom
-- newNotes is an array of { note, chan, velocity }, also sorted top to bottom
-- this function replaces the pitches of oldNotes with newNotes.
-- if newNotes is bigger than oldNotes, then the last oldNote velocity & note length are used to insert new ones.
-- if oldNotes is bigger, than erase the remaining oldNotes.
-- another possibility is to use the recorded velocity, but i think in the spirit of replacing the voicing,
-- it's best to preserve the velocity that was previously recorded.
function replaceChord(take, oldNotes, newNotes)

	for i = 1, math.min(#oldNotes, #newNotes) do
	  -- replace old with new
	  -- reaper.MIDI_SetNote(MediaItem_Take take,
	  -- noteidx, selected, muted, startppqpos, endppqposIn, chanIn, pitch, velIn, noSort)
		reaper.MIDI_SetNote(take, oldNotes[i].index, nil, nil, nil, nil, nil, newNotes[i].note, nil, nil)
		DBG("Replacing note index "..oldNotes[i].index..", note "..oldNotes[i].pitch.." -> "..newNotes[i].note)
	end
	if #oldNotes > #newNotes then
		-- delete old notes. need to be careful though to only erase in descending index order.
		local indicesToDelete = {};
		for i = #newNotes+1, #oldNotes do
			indicesToDelete[#indicesToDelete+1] = oldNotes[i].index
		end
	
		table.sort(indicesToDelete, function(a,b) return a > b end)-- sort desc.

		for i = 1, #indicesToDelete do
			reaper.MIDI_DeleteNote(take, indicesToDelete[i])
			DBG("deleting note index "..indicesToDelete[i])
		end
	elseif #newNotes > #oldNotes then
		-- insert new notes. use velocity, channel, length of the last old note.
		for i = #oldNotes+1, #newNotes do
			local model = oldNotes[#oldNotes]
			-- take, selected, muted
			reaper.MIDI_InsertNote(take, true, false, model.startPPQ, model.endPPQ, model.channel, newNotes[i].note, model.velocity)
			DBG("Inserting note "..newNotes[i].note)
		end
	end


end







