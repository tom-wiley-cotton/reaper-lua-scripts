function main()
  -- Get number of tracks
  local num_tracks = reaper.CountTracks(0)
  
  -- First unselect all tracks
  for i = 0, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    reaper.SetTrackSelected(track, false)
  end
  
  -- Loop through all tracks and select those starting with '_'
  for i = 0, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    local _, track_name = reaper.GetTrackName(track, "")
    
    if track_name and track_name:len() > 0 then
      -- Check if track name starts with '_'
      if string.sub(track_name, 1, 1) == "_" then
        reaper.SetTrackSelected(track, true)
      end
    end
  end
  
  -- Update UI
  reaper.UpdateArrange()
end

-- Execute script
reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock("Select tracks starting with underscore", -1)
