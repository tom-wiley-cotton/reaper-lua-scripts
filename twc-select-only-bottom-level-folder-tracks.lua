-- Select only direct parent folder tracks of non-folder tracks
-- TWC Scripts

function Main()
  -- Clear current selection
  reaper.Main_OnCommand(40297, 0) -- Track: Unselect all tracks
  
  local project = 0
  local track_count = reaper.CountTracks(project)
  local selected_parents = {}
  
  -- First pass: Find all direct parent folders of non-folder tracks
  for i = 0, track_count - 1 do
    local track = reaper.GetTrack(project, i)
    local is_folder = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") > 0
    
    -- If this is not a folder track
    if not is_folder then
      local parent = reaper.GetParentTrack(track)
      if parent then
        -- Store the parent track pointer in our table if not already present
        local parent_guid = reaper.GetTrackGUID(parent)
        selected_parents[parent_guid] = parent
      end
    end
  end
  
  -- Second pass: Select all unique parent folders we found
  for _, parent in pairs(selected_parents) do
    reaper.SetTrackSelected(parent, true)
  end
  
  reaper.UpdateArrange()
end

Main()
