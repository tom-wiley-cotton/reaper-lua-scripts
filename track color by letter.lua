-- User configuration
local NAME_COLOR_DEPTH = 3  -- Tracks at this depth or shallower will be colored by their own name
                           -- Tracks deeper than this will inherit parent's color
                           -- Example: 3 means levels 0,1,2 get their own colors, 3+ inherit from parent
                           -- Minimum value is 1 (only root level gets own colors)

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

function getAllTracks()
  local tracks = {}
  local num_tracks = reaper.CountTracks(0)
  
  -- Collect all tracks
  for i = 0, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    local depth = getFolderDepth(track)
    local _, track_name = reaper.GetTrackName(track, "")
    table.insert(tracks, {track = track, depth = depth, name = track_name})
  end
  
  -- Sort tracks by depth (shallow to deep)
  table.sort(tracks, function(a, b) return a.depth < b.depth end)
  
  return tracks
end

function main()
  -- Get all tracks sorted by depth
  local tracks = getAllTracks()
  
  -- Process all tracks
  for _, track_info in ipairs(tracks) do
    local track = track_info.track
    local depth = track_info.depth
    local name = track_info.name
    
    if name and name:len() > 0 then
      if depth <= math.max(1, NAME_COLOR_DEPTH) - 1 then
        -- Color tracks up to NAME_COLOR_DEPTH-1 by their own first letter
        -- Example: NAME_COLOR_DEPTH=3 means depths 0,1,2 get own colors
        local first_letter = string.sub(name, 1, 1)
        local baseColor = getColorForLetter(first_letter)
        reaper.SetTrackColor(track, adjustColorForDepth(baseColor, depth))
      else
        -- For deeper tracks, color by nearest parent's color that has its own letter color
        local parent = reaper.GetParentTrack(track)
        while parent do
          local parent_depth = getFolderDepth(parent)
          -- Check if this parent should have its own letter color
          if parent_depth <= math.max(1, NAME_COLOR_DEPTH) - 1 then
            local _, parent_name = reaper.GetTrackName(parent, "")
            if parent_name and parent_name:len() > 0 then
              local parent_letter = string.sub(parent_name, 1, 1)
              local parentColor = getColorForLetter(parent_letter)
              reaper.SetTrackColor(track, adjustColorForDepth(parentColor, depth))
              break
            end
          end
          parent = reaper.GetParentTrack(parent)
        end
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
