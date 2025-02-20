function isFolder(track)
  local _, flags = reaper.GetTrackState(track)
  return flags & 1 == 1
end

function getFolderDepth(track)
  local depth = 0
  local parent = reaper.GetParentTrack(track)
  while parent do
    depth = depth + 1
    parent = reaper.GetParentTrack(parent)
  end
  return depth
end

function hasSubFolders(track)
  local track_idx = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER") - 1
  local num_tracks = reaper.CountTracks(0)
  local depth = 0
  local in_our_folder = false
  
  -- Loop through following tracks
  for i = track_idx + 1, num_tracks - 1 do
    local current_track = reaper.GetTrack(0, i)
    local _, flags = reaper.GetTrackState(current_track)
    
    -- First track after our folder is inside our hierarchy
    if i == track_idx + 1 then
      in_our_folder = true
    end
    
    -- If we're inside our folder's hierarchy
    if in_our_folder then
      -- Check if this track is a folder
      if flags & 1 == 1 then
        depth = depth + 1
        -- If we find a folder at depth 1, it's a direct subfolder
        if depth == 1 then
          return true
        end
      end
      
      -- Check if this track ends a folder
      if flags & 2 == 2 then
        depth = depth - 1
        -- If depth becomes negative, we've exited our folder
        if depth < 0 then
          break
        end
      end
    end
  end
  
  return false
end

function main()
  -- Get number of tracks
  local num_tracks = reaper.CountTracks(0)
  
  -- First unselect all tracks
  for i = 0, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    reaper.SetTrackSelected(track, false)
  end
  
  -- Loop through all tracks and select bottom level folders
  for i = 0, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    
    -- Check if it's a folder
    if isFolder(track) then
      -- If it has no subfolders, it's a bottom level folder
      if not hasSubFolders(track) then
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
reaper.Undo_EndBlock("Select bottom level folder tracks", -1)
