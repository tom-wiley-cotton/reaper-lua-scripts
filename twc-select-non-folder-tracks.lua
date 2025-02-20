-- Select all non-folder tracks
-- TWC Scripts

function Main()
  -- Clear current selection
  reaper.Main_OnCommand(40297, 0) -- Track: Unselect all tracks
  
  local project = 0
  local track_count = reaper.CountTracks(project)
  
  -- Select all non-folder tracks
  for i = 0, track_count - 1 do
    local track = reaper.GetTrack(project, i)
    local is_folder = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") > 0
    
    -- If this is not a folder track, select it
    if not is_folder then
      reaper.SetTrackSelected(track, true)
    end
  end
  
  reaper.UpdateArrange()
end

Main()
