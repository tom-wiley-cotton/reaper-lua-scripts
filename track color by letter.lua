function getColorForLetter(letter)
  -- Convert letter to uppercase for consistency
  letter = string.upper(letter)

  -- Define color mapping with crayon-style colors (from Example 1)
  local colors = {
    A = {255, 51, 204},    -- Hot Pink
    B = {0, 168, 255},     -- Sky Blue
    C = {127, 255, 0},     -- Lime Green
    D = {255, 128, 0},     -- Bright Orange
    E = {255, 255, 0},     -- Yellow
    F = {255, 0, 127},     -- Magenta
    G = {0, 255, 127},     -- Spring Green
    H = {255, 153, 51},    -- Tangerine
    I = {153, 51, 255},    -- Purple
    J = {255, 102, 178},   -- Bubble Gum
    K = {51, 255, 255},    -- Electric Blue
    L = {255, 204, 51},    -- Macaroni
    M = {255, 0, 0},       -- Cherry Red
    N = {102, 255, 178},   -- Mint
    O = {178, 102, 255},   -- Grape
    P = {255, 178, 102},   -- Peach
    Q = {102, 178, 255},   -- Cornflower
    R = {255, 51, 51},     -- Strawberry
    S = {51, 255, 51},     -- Shamrock
    T = {255, 153, 204},   -- Cotton Candy
    U = {153, 204, 255},   -- Periwinkle
    V = {204, 255, 153},   -- Sea Foam
    W = {255, 204, 153},   -- Apricot
    X = {204, 153, 255},   -- Amethyst
    Y = {255, 255, 153},   -- Banana
    Z = {153, 255, 204}    -- Aquamarine
  }

  return colors[letter]
end

function adjustColorForDepth(color, depth)
  -- Reduce saturation based on depth
  -- Move colors closer to grey with each level
  local greyValue = 128
  local factor = math.max(0.4, 1 - (depth * 0.2)) -- Reduce by 20% per level, minimum 40%
  
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

function colorChildTracks(parentTrack, baseColor, parentDepth)
  local depth = 0
  local track_idx = reaper.GetMediaTrackInfo_Value(parentTrack, "IP_TRACKNUMBER") - 1
  local num_tracks = reaper.CountTracks(0)
  
  -- Set parent track color
  reaper.SetTrackColor(parentTrack, adjustColorForDepth(baseColor, parentDepth))
  
  -- Loop through following tracks
  for i = track_idx + 1, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    local _, flags = reaper.GetTrackState(track)
    
    -- Update folder depth
    if flags & 1 == 1 then depth = depth + 1 end      -- Found a folder
    if flags & 2 == 2 then depth = depth - 1 end      -- Found a folder end
    
    -- If depth becomes negative, we've reached the end of our folder
    if depth < 0 then break end
    
    -- Get the actual depth of this track for color adjustment
    local trackDepth = parentDepth + (isFolder(track) and depth or depth + 1)
    
    -- Color the track
    reaper.SetTrackColor(track, adjustColorForDepth(baseColor, trackDepth))
  end
end

function main()
  -- Get number of tracks
  local num_tracks = reaper.CountTracks(0)
  
  -- Loop through all tracks
  for i = 0, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    
    -- Only process top-level folders
    if isFolder(track) and getFolderDepth(track) == 0 then
      local _, track_name = reaper.GetTrackName(track, "")
      
      if track_name and track_name:len() > 0 then
        -- Get first letter and corresponding base color
        local first_letter = string.sub(track_name, 1, 1)
        local baseColor = getColorForLetter(first_letter)
        
        -- Color the folder and all its children
        colorChildTracks(track, baseColor, 0)
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