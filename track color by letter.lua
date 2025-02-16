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

function colorToNative(color)
  return reaper.ColorToNative(color[1], color[2], color[3])
end

function isFolder(track)
  local _, flags = reaper.GetTrackState(track)
  return flags & 1 == 1
end

function colorChildTracks(parentTrack, nativeColor)
  local depth = 0
  local track_idx = reaper.GetMediaTrackInfo_Value(parentTrack, "IP_TRACKNUMBER") - 1
  local num_tracks = reaper.CountTracks(0)
  
  -- Set parent track color
  reaper.SetTrackColor(parentTrack, nativeColor)
  
  -- Loop through following tracks
  for i = track_idx + 1, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    local _, flags = reaper.GetTrackState(track)
    
    -- Update folder depth
    if flags & 1 == 1 then depth = depth + 1 end      -- Found a folder
    if flags & 2 == 2 then depth = depth - 1 end      -- Found a folder end
    
    -- If depth becomes negative, we've reached the end of our folder
    if depth < 0 then break end
    
    -- Color the track with parent's color
    reaper.SetTrackColor(track, nativeColor)
  end
end

function main()
  -- Get number of tracks
  local num_tracks = reaper.CountTracks(0)
  local tracks_colored = 0
  
  -- Loop through tracks until we color 3 or run out
  for i = 0, math.min(num_tracks - 1, 2) do
    local track = reaper.GetTrack(0, i)
    local _, track_name = reaper.GetTrackName(track, "")
    
    if track_name and track_name:len() > 0 then
      -- Get first letter and corresponding color
      local first_letter = string.sub(track_name, 1, 1)
      local baseColor = getColorForLetter(first_letter)
      
      if baseColor then
        -- Convert color to native format
        local nativeColor = colorToNative(baseColor)
        
        -- Color the track and its children if it's a folder
        colorChildTracks(track, nativeColor)
      end
    end
  end
  
  -- Update UI
  reaper.UpdateArrange()
end

-- Execute script
reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock("Color first three tracks and children", -1)
