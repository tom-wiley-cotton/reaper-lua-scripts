-- Select parent tracks of selected tracks
-- TWC Scripts

function Main()
  local project = 0
  local selected_parents = {}
  
  -- Store current selected tracks
  local num_selected = reaper.CountSelectedTracks(project)
  
  -- For each selected track
  for i = 0, num_selected - 1 do
    local track = reaper.GetSelectedTrack(project, i)
    local parent = reaper.GetParentTrack(track)
    
    -- If track has a parent, store it
    if parent then
      local parent_guid = reaper.GetTrackGUID(parent)
      selected_parents[parent_guid] = parent
    end
  end
  
  -- Clear current selection
  reaper.Main_OnCommand(40297, 0) -- Track: Unselect all tracks
  
  -- Select all unique parent tracks
  for _, parent in pairs(selected_parents) do
    reaper.SetTrackSelected(parent, true)
  end
  
  reaper.UpdateArrange()
end

Main()
