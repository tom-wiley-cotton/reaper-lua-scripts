function isFolder(track)
  local _, flags = reaper.GetTrackState(track)
  return flags & 1 == 1
end

function main()
  -- Get number of tracks
  local num_tracks = reaper.CountTracks(0)
  
  -- Loop through all tracks
  for i = 0, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    
    -- If it's a folder track, set to minimum height
    if isFolder(track) then
      reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", 0)
    end
  end
  
  -- Update UI
  reaper.UpdateArrange()
end

-- Execute script
reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock("Minimize folder tracks", -1)
