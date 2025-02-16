function getColorForLetter(letter)
  -- Convert letter to uppercase for consistency
  letter = string.upper(letter)
  
  -- Define color mapping with more saturated base colors
  local colors = {
    A = {242, 102, 171},   -- Brighter Pink
    B = {102, 171, 242},   -- Brighter Sky Blue
    C = {133, 242, 102},   -- Brighter Lime
    D = {242, 152, 102},   -- Brighter Orange
    E = {242, 242, 102},   -- Brighter Yellow
    F = {242, 102, 152},   -- Brighter Magenta
    G = {102, 242, 152},   -- Brighter Spring Green
    H = {242, 171, 102},   -- Brighter Tangerine
    I = {152, 102, 242},   -- Brighter Purple
    J = {242, 133, 171},   -- Brighter Bubble Gum
    K = {102, 242, 242},   -- Brighter Electric Blue
    L = {242, 205, 102},   -- Brighter Macaroni
    M = {242, 102, 102},   -- Brighter Cherry Red
    N = {133, 242, 171},   -- Brighter Mint
    O = {171, 133, 242},   -- Brighter Grape
    P = {242, 171, 133},   -- Brighter Peach
    Q = {133, 171, 242},   -- Brighter Cornflower
    R = {242, 102, 102},   -- Brighter Strawberry
    S = {102, 242, 102},   -- Brighter Shamrock
    T = {242, 171, 205},   -- Brighter Cotton Candy
    U = {171, 205, 242},   -- Brighter Periwinkle
    V = {205, 242, 171},   -- Brighter Sea Foam
    W = {242, 205, 171},   -- Brighter Apricot
    X = {205, 171, 242},   -- Brighter Amethyst
    Y = {242, 242, 171},   -- Brighter Banana
    Z = {171, 242, 205}    -- Brighter Aquamarine
  }
  
  return colors[letter] or {128, 128, 128} -- Default grey if no match
end

function adjustColorForDepth(color, depth)
  -- Reduce saturation based on depth
  -- Move colors closer to grey with each level
  local greyValue = 128
  --                     \/ - minimum
  local factor = math.max(0.6, 1 - (depth * 0.1)) -- dimming by levle
  
  local r = math.floor(color[1] * factor + greyValue * (1 - factor))
  local g = math.floor(color[2] * factor + greyValue * (1 - factor))
  local b = math.floor(color[3] * factor + greyValue * (1 - factor))
  
  return reaper.ColorToNative(r, g, b)
end

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

function colorChildTracks(parentTrack, parentColor, parentDepth)
  local depth = 0
  local track_idx = reaper.GetMediaTrackInfo_Value(parentTrack, "IP_TRACKNUMBER") - 1
  local num_tracks = reaper.CountTracks(0)
  
  -- Loop through following tracks
  for i = track_idx + 1, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    local _, flags = reaper.GetTrackState(track)
    
    -- Update folder depth
    if flags & 1 == 1 then depth = depth + 1 end      -- Found a folder
    if flags & 2 == 2 then depth = depth - 1 end      -- Found a folder end
    
    -- If depth becomes negative, we've reached the end of our folder
    if depth < 0 then break end
    
    -- Get track name for folders
    local _, track_name = reaper.GetTrackName(track, "")
    
    if isFolder(track) and track_name and track_name:len() > 0 then
      -- Folders get their own color based on first letter
      local first_letter = string.sub(track_name, 1, 1)
      local folderColor = getColorForLetter(first_letter)
      reaper.SetTrackColor(track, adjustColorForDepth(folderColor, parentDepth + depth))
    else
      -- Non-folder tracks inherit parent color
      reaper.SetTrackColor(track, adjustColorForDepth(parentColor, parentDepth + depth + 1))
    end
  end
end

function main()
  -- Get number of tracks
  local num_tracks = reaper.CountTracks(0)
  
  -- Loop through all folder tracks
  for i = 0, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    
    -- Process all folder tracks
    if isFolder(track) then
      local _, track_name = reaper.GetTrackName(track, "")
      
      if track_name and track_name:len() > 0 then
        -- Get first letter and corresponding base color
        local first_letter = string.sub(track_name, 1, 1)
        local baseColor = getColorForLetter(first_letter)
        
        -- Set this folder's color and process its children
        local depth = getFolderDepth(track)
        reaper.SetTrackColor(track, adjustColorForDepth(baseColor, depth))
        colorChildTracks(track, baseColor, depth)
      end
    end
  end
  
  -- Update UI
  reaper.UpdateArrange()
end

-- Execute script
reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock("Color tracks by folder depth", -1)
