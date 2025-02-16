-- Exit if REAPER is not available
if not reaper then return end

function isFolder(track)
  local _, flags = reaper.GetTrackState(track)
  return flags & 1 == 1
end

function main()
  -- Get number of tracks
  local num_tracks = reaper.CountTracks(0)
  
  reaper.ShowConsoleMsg("Processing " .. num_tracks .. " tracks\n")
  
  -- Loop through all tracks
  for i = 0, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    
    -- If it's a folder track, set to minimum height
    if isFolder(track) then
      local _, name = reaper.GetTrackName(track)
      reaper.ShowConsoleMsg("Minimizing folder track: " .. name .. "\n")
      
      -- Try multiple height-related properties
      reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", 20)
      reaper.SetMediaTrackInfo_Value(track, "I_TCPH", 20)
      reaper.SetMediaTrackInfo_Value(track, "I_WNDH", 20)
      reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", 1)
      reaper.SetMediaTrackInfo_Value(track, "B_SHOWINMIXER", 1)
    end
  end
  
  -- Force UI updates
  reaper.TrackList_AdjustWindows(true)
  reaper.UpdateArrange()
  reaper.UpdateTimeline()
end

-- Execute script
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock("Minimize folder tracks", -1)
reaper.PreventUIRefresh(-1)
