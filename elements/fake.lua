local awful = require('awful');

local ratio = 3440 / 2560
local resize_amount = 10

fake = fake or {};
-- Table that holds all active fake screen variables
local screens = {}
local function monitor_has_fake()
  local scr = awful.screen.focused()
  if scr.has_fake or scr.is_fake then
    return true
  end
end

local function create_fake(s)
  local scr = s
  -- If screen was not passed, create on focused
  if not scr then
  -- Get focused screen
    scr = awful.screen.focused()
  end
  -- If already is or has fake
  if monitor_has_fake(scr) then
    return
  end
  -- Create variables
  local geo = scr.geometry
  local real_w = math.floor(geo.width * ratio)
  local fake_w = geo.width - real_w
  -- Index for cleaner code
  local index = tostring(scr.index)
  -- Set initial sizes into memory
  screens[index] = {}
  screens[index].geo = geo
  screens[index].real_w = real_w
  screens[index].fake_w = fake_w
  scr.fake = scr.fake or {}
  scr.fake.is_fake = true
  scr.is_fake = true
  scr.has_fake = true
  -- Change status
  scr.fake.status = 'open'
  -- Create if doesn't exist
  -- Resize screen
  scr:fake_resize(geo.x, geo.y, real_w, geo.height)
  -- Create fake for screen
  scr.fake = _G.screen.fake_add(
  geo.x + real_w,
  geo.y,
  fake_w,
  geo.height
  )
  scr.fake.parent = scr
  -- Mark screens
  -- Because memory leak
  collectgarbage('collect')
  -- Emit signal
  scr:emit_signal('fake_created')
end

local function remove_fake()
  -- Get focused screen
  local scr = awful.screen.focused()
  -- Ge real screen if fake was focused
  if scr.is_fake then
    scr = scr.parent
  end
  -- Index for cleaner code
  local index = tostring(scr.index)
  scr:fake_resize(
    screens[index].geo.x,
    screens[index].geo.y,
    screens[index].geo.width,
    screens[index].geo.height
  )
  -- Remove and handle variables
  scr.fake:fake_remove()
  scr.has_fake = false
  scr.fake = nil
  screens[index] = {}
  -- Because memory leak
  collectgarbage('collect')
  -- Emit signal
  scr:emit_signal('fake_created')
end

-- Toggle fake screen
local function toggle_fake()
  -- Get focused screen
  local scr = awful.screen.focused()
  -- If screen doesn't have fake or isn't fake
  if not scr.has_fake and not scr.is_fake then
    return
  end
  -- Ge real screen if fake was focused
  if scr.is_fake then scr = scr.parent end
  -- Index for cleaner code
  local index = tostring(scr.index)
  -- If fake was open
  if scr.fake.status == 'open' then
    -- Resize real screen to be initial size
    scr:fake_resize(
      screens[index].geo.x,
      screens[index].geo.y,
      screens[index].geo.width,
      screens[index].geo.height
    )
    -- Resize fake to 1px 'out of the view'
    -- It will show up on screen on right side of
    -- the screen we're handling
    scr.fake:fake_resize(
      screens[index].geo.width,
      screens[index].geo.y,
      1,
      screens[index].geo.height
    )
    -- Mark fake as hidden
    scr.fake.status = 'hidden'
  -- Fake was selected
  elseif scr.fake.status == 'hidden' then
    -- Resize screens
    scr:fake_resize(
      screens[index].geo.x,
      screens[index].geo.y,
      screens[index].real_w,
      screens[index].geo.height
    )
    scr.fake:fake_resize(
      screens[index].geo.x + screens[index].real_w,
      screens[index].geo.y,
      screens[index].fake_w,
      screens[index].geo.height
    )
    -- Mark fake as open
    scr.fake.status = 'open'
  end
  -- Because memory leak
  collectgarbage('collect')
end

-- Resize fake with given amount in pixels
local function resize_fake(amount)
  -- Get focused screen
  local scr = awful.screen.focused()
  -- Ge real screen if fake was focused
  if scr.is_fake then
    scr = scr.parent
  end
  -- Index for cleaner code
  local index = tostring(scr.index)
  -- Resize only if fake is open
  if scr.fake.status == 'open' then
    -- Modify width variables
    screens[index].real_w = screens[index].real_w + amount
    screens[index].fake_w = screens[index].fake_w - amount
    -- Resize screens
    scr:fake_resize(
      screens[index].geo.x,
      screens[index].geo.y,
      screens[index].real_w,
      screens[index].geo.height
    )
    scr.fake:fake_resize(
      screens[index].geo.x + screens[index].real_w,
      screens[index].geo.y,
      screens[index].fake_w,
      screens[index].geo.height
    )
  end
  -- Because memory leak
  collectgarbage('collect')
end

-- Reset screens to default value
local function reset_fake()
  -- Get focused screen
  local scr = awful.screen.focused()
  -- Ge real screen if fake was focused
  if scr.is_fake then
    scr = scr.parent
  end
  -- In case screen doesn't have fake
  if not scr.has_fake then
    return
  end
  -- Index for cleaner code
  local index = tostring(scr.index)
  if scr.fake.status == 'open' then
    screens[index].real_w = math.floor(screens[index].geo.width * ratio)
    screens[index].fake_w = screens[index].geo.width - screens[index].real_w
    scr:fake_resize(
      screens[index].geo.x,
      screens[index].geo.y,
      screens[index].real_w,
      screens[index].geo.height
    )
    scr.fake:fake_resize(
      screens[index].real_w,
      screens[index].geo.y,
      screens[index].geo.width - screens[index].real_w,
      screens[index].geo.height
    )
  end
  -- Because memory leak
  collectgarbage('collect')
end

return function()
  fake.resize_fake = resize_fake
  fake.reset_fake = reset_fake
  fake.remove_fake = remove_fake
  fake.create_fake = create_fake
  fake.toggle_fake = toggle_fake
  fake.monitor_has_fake = monitor_has_fake
end