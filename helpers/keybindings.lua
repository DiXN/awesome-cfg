local awful = require('awful');
local config = require('helpers.config');
local gears = require('gears');

-- MODKEY
modkey = 'Mod4'
alt = 'Mod1'

--GLOBAL KEYBINDS/BUTTONS
local key_bindings = gears.table.join({
  awful.key({ modkey }, "Return", function() awful.spawn(config.commands.terminal) end),
  awful.key({ modkey }, "c", function() awful.spawn(config.commands.editor) end),
  awful.key({ modkey, alt }, "b", function() awful.spawn(config.commands.browser) end),
  awful.key({ modkey }, "b", function() awful.spawn(config.commands.browser .. " --incognito") end),
  awful.key({ modkey }, "f", function() awful.spawn(config.commands.files) end),
  awful.key({ modkey }, "n", function() awful.spawn(config.commands.nvidia) end),
  awful.key({ modkey }, "space", function() awful.spawn(config.commands.rofi) end),

  awful.key({ modkey, "Shift" }, "q", function() if root.elements.powermenu then root.elements.powermenu.show() end end),
  awful.key({ modkey, "Control" }, "q", function() awesome.quit() end),
  awful.key({ modkey, "Shift" }, "l", function() if root.elements.powermenu then root.elements.powermenu.lock() end end),
  -- awful.key({ modkey, "Shift" }, "r", function() if root.elements.powermenu then root.elements.powermenu.lock(awesome.restart) end end),
  awful.key({ modkey, "Shift" }, "r", awesome.restart),

  awful.key({ modkey, "Shift"}, "b", function()
    local screen_idx = awful.screen.focused().index

    if bar_visibility[screen_idx] == true then
      root.elements.topbar.hide(screen_idx)
      bar_visibility[screen_idx] = false
    else
      root.elements.topbar.show(screen_idx)
      bar_visibility[screen_idx] = true
    end
  end),

  awful.key({ modkey }, "j", function() awful.client.focus.byidx(-1) end),
  awful.key({ modkey }, "k", function() awful.client.focus.byidx(1) end),
  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end),

  -- toggle client stack order
  awful.key({ modkey, "Shift" }, "s", function() bottom = not bottom end),
  awful.key({ modkey, "Shift" }, "Return", function() awful.client.setmaster(client.focus) end),

  -- Resize
  awful.key({ modkey }, "l", function() awful.tag.incmwfact(0.05) end),
  awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end),
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(1) end),
  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(-1) end),

  awful.key({ modkey }, "m", function() awful.layout.set(awful.layout.suit.max) end),
  awful.key({ modkey }, "t", function() awful.layout.set(awful.layout.suit.tile) end),
  awful.key({ modkey }, "a", function() awful.spawn("instantassist") end),
  awful.key({ modkey }, "v", function() root.elements.hub.enable_view_by_index(5, mouse.screen) end),

  -- Screenshot
  awful.key({ modkey }, "Print", function() awful.spawn.with_shell(config.commands.scrotclip) end),
  awful.key({ modkey, "Shift" }, "Print", function() awful.spawn.with_shell(config.commands.scrot) end),
  awful.key({ modkey, "Control" }, "Print", function() awful.spawn.with_shell(config.commands.scrotclipsave) end),

  awful.key {
    modifiers = { modkey, "Shift" },
    keygroup    = "numrow",
    description = "move focused client to tag",
    group       = "tag",
    on_press    = function (index)
      if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end,
  },

  awful.key({}, "XF86AudioRaiseVolume", function ()
      awful.util.spawn(config.commands.volup) end),
  awful.key({}, "XF86AudioLowerVolume", function()
      awful.util.spawn(config.commands.voldown) end),
  awful.key({}, "XF86AudioMute", function()
      awful.util.spawn(config.commands.mute) end),
  awful.key({modkey, "Shift", "Control"}, "d", function() awful.util.spawn(config.commands.voldown) end),
  awful.key({modkey, "Shift", "Control"}, "u", function() awful.util.spawn(config.commands.volup) end),
})

return key_bindings

