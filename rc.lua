local os = require('os');
local gears = require('gears');
local awful = require('awful');
local wibox = require('wibox');
local ruled = require('ruled');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local inspect = require('inspect')
require('./errors')();
require('./elements/fake')()


local capi = {
  awesome = awesome,
  screen = screen
}

-- ELEMENT STORE
root.elements = root.elements or {};

-- THEME
beautiful.useless_gap = 4;

-- MODKEY
modkey = 'Mod4';


-- LAYOUTS
tag.connect_signal('request::default_layouts', function()
  awful.layout.append_default_layouts({
    awful.layout.suit.tile,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating,
    awful.layout.suit.max,
    awful.layout.suit.fair,
  });
end);

-- TAGS/LAYOUTS
screen.connect_signal('request::desktop_decoration', function(s)
  local tags = {}
  local tag_size = 4

  for i = ((s.index - 1) * tag_size) + 1, s.index * tag_size, 1
  do
    tags[i - ((s.index - 1) * tag_size)] = i
  end

  awful.tag(tags, s, awful.layout.layouts[1])

  s.tags[1]:view_only();
end);

-- ELEMENTS
if not root.elements.hub then require('elements.hub')() end;
if not root.elements.topbar then require('elements.topbar')() end;
if not root.elements.tagswitcher then require('elements.tagswitch')() end;
if not root.elements.powermenu then require('elements.powermenu')() end;

local last_client = nil;
local bottom = true;

local bar_visibility = {};
awful.screen.connect_for_each_screen(function(s) bar_visibility[s.index] = true end);

--GLOBAL KEYBINDS/BUTTONS
awful.keyboard.append_global_keybindings({
  awful.key({ modkey }, "Return", function() awful.spawn(config.commands.terminal) end),
  awful.key({ modkey }, "c", function() awful.spawn(config.commands.editor) end),
  awful.key({ modkey }, "b", function() awful.spawn(config.commands.browser) end),
  awful.key({ modkey }, "f", function() awful.spawn(config.commands.files) end),
  awful.key({ modkey }, "n", function() awful.spawn(config.commands.nvidia) end),
  awful.key({ modkey }, "space", function() awful.spawn(config.commands.rofi) end),

  awful.key({ modkey, "Shift" }, "q", function() if root.elements.powermenu then root.elements.powermenu.show() end end),
  awful.key({ modkey, "Control" }, "q", function() awesome.quit() end),
  awful.key({ modkey, "Shift" }, "l", function() if root.elements.powermenu then root.elements.powermenu.lock() end end),
  -- awful.key({ modkey, "Shift" }, "r", function() if root.elements.powermenu then root.elements.powermenu.lock(awesome.restart) end end),
  awful.key({ modkey, "Shift" }, "r", awesome.restart),

  awful.key({ modkey, "Shift" }, "o",function()
    local geo = screen[1].geometry
    local new_width = math.ceil(geo.width/2)
    local new_width2 = geo.width - new_width
    screen[1]:fake_resize(geo.x, geo.y, new_width, geo.height)
    screen.fake_add(geo.x + new_width, geo.y, new_width2, geo.height)
  end),

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
  awful.key({ modkey }, "v", function() awful.spawn("quickmenu") end),

  -- Screenshot
  awful.key({ modkey }, "Print", function() awful.spawn.with_shell(config.commands.scrotclip) end),
  awful.key({ modkey, "Shift" }, "Print", function() awful.spawn.with_shell(config.commands.scrot) end),
  awful.key({ modkey, "Control" }, "Print", function() awful.spawn.with_shell(config.commands.scrotclipsave) end),
  awful.key({ modkey }, "v", function() awful.spawn("quickmenu") end),

  -- Toggle/hide fake screen
  awful.key({ modkey }, '-',
    function()
      fake.toggle_fake()
    end,
  { description = 'hide/show fake screen', group = 'fake screen' }),

  -- Create or remove
  awful.key({ modkey, "Control" }, 'f',
    function()
      if not fake.monitor_has_fake() then
        fake.create_fake()
        return
      end
      fake.remove_fake()
    end,
  { description = 'create/remove fake screen on focused', group = 'fake screen' }),

  -- Increase fake screen size
  awful.key({ modkey, "Control" }, 'Left',
    function()
      fake.resize_fake(-resize_amount)
    end,
  { description = 'resize fake screen', group = 'fake screen' }),

  -- Decrease fake screen size
  awful.key({ modkey, "Control" }, 'Right',
    function()
      fake.resize_fake(resize_amount)
    end,
    { description = 'resize fake screen', group = 'fake screen' }),

  -- Reset screen sizes to initial size
  awful.key({ modkey, altkey }, 'r',
    function()
      fake.reset_fake()
    end,
    { description = 'reset fake screen size', group = 'fake screen' }),

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

	--awful.key({}, "space", function () if root.elements.powermenu.prompt then prompt() end end),

  awful.key({}, "XF86AudioRaiseVolume", function ()
      awful.util.spawn(config.commands.volup) end),
  awful.key({}, "XF86AudioLowerVolume", function()
      awful.util.spawn(config.commands.voldown) end),
  awful.key({}, "XF86AudioMute", function()
      awful.util.spawn(config.commands.mute) end),
  awful.key({modkey, "Shift", "Control"}, "d", function() awful.util.spawn(config.commands.voldown) end),
  awful.key({modkey, "Shift", "Control"}, "u", function() awful.util.spawn(config.commands.volup) end),
});

awful.keygrabber {
  keybindings = {
    {{ modkey }, 'r', function() last_client = client.focus end}
  },
  stop_key           = modkey,
  stop_event         = 'release',
  stop_callback      = function()
    if last_client ~= nil then
      client.focus:swap(last_client)
      client.focus = last_client
    end;
  end,
  export_keybindings = true,
}

local function setup_columns(t)
  if t.col_count == nil then t.col_count = 2 end

  if t.layout.name == "tile" and t.col_count < 3 then
    awful.tag.incncol(1, t)
    t.master_width_factor = 0.38
    t.col_count = 3
  end
end

tag.connect_signal("property::layout", function(t) setup_columns(t) end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- TAG KEYBINDS
for i = 0, 9 do
  local spot = i;
  if(spot == 10) then spot = 0 end

  awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, spot, function()
      local tag = root.tags()[i];
      if tag then tag:view_only() end;
    end),
    awful.key({ modkey, 'Shift'}, spot, function()
      local tag = root.tags()[i];
        if tag and client.focus then client.focus:move_to_tag(tag) end;
        tag:view_only();
      end)
    });
  end

  awful.mouse.append_global_mousebindings({
    awful.button({}, 1, function()
      if root.elements.hub then root.elements.hub.close() end
    end),
    awful.button({}, 3, function()
      root.elements.hub.enable_view_by_index(5, mouse.screen);
    end),
  });

  client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
  end)

  -- CLIENT KEYBINDS & BUTTONS
  client.connect_signal("request::default_keybindings", function(c)
    awful.keyboard.append_client_keybindings({
      awful.key({ modkey }, "q", function (c) c.kill(c) end),
      awful.key({ modkey, "Control" }, "Right", function(c) c:move_to_screen(c.screen.index+1) end),
      awful.key({ modkey, "Control" }, "Left", function(c) c:move_to_screen(c.screen.index-1) end),
      awful.key({ modkey, "Control" }, "f", function(c) c.fullscreen = not c.fullscreen end),
      awful.key({ modkey, "Shift" }, "f", function(c)
        c.fake_full = not c.fake_full

        if c.fake_full then c.fullscreen = true end
      end),
    });
  end);

  client.connect_signal("request::default_mousebindings", function(c)
    awful.mouse.append_client_mousebindings({
      awful.button({}, 1, function (c)
        if root.elements.hub then root.elements.hub.close() end
        c:activate { context = "mouse_move", raise = true }
      end),
      awful.button({ modkey }, 1, function (c)
        if not c.floating then c.floating = true end
        c:activate { context = "mouse_click", action = "mouse_move" }
      end),
      awful.button({ modkey }, 3, function (c)
        c:activate { context = "mouse_click", action = "mouse_resize" }
      end),
      awful.button({ modkey }, 2, function (c)
        if c.floating then
          c.floating = false
          c:emit_signal("tiled")
        end
      end),
      awful.button({ modkey, "Shift" }, 4, function()
        awful.client.swap.byidx(1);
      end),
      awful.button({ modkey, "Shift" }, 5, function()
        awful.client.swap.byidx(-1);
      end),
      awful.button({ modkey }, 4, function()
        awful.client.focus.byidx(1);
      end),
      awful.button({ modkey }, 5, function()
        awful.client.focus.byidx(-1);
      end)
    });
  end);

  -- RULES
  ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
      id         = "global",
      rule       = { },
      properties = {
        focus     = awful.client.focus.filter,
        raise     = true,
        screen    = awful.screen.preferred,
        placement = awful.placement.no_overlap+awful.placement.no_offscreen
      }
    }

    -- Floating clients.
    ruled.client.append_rule {
      id       = "floating",
      rule_any = {
        instance = { "copyq", "pinentry" },
        class    = {
          "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
          "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
        },
        name    = {
          "Event Tester",
          "Media viewer"
        },
        role    = {
          "AlarmWindow",
          "ConfigManager",
          "pop-up",
        }
      },
      properties = { floating = true }
    }

    ruled.client.append_rule {
      id         = "titlebars",
      rule_any   = { type = { "normal", "dialog" } },
      properties = { titlebars_enabled = true      }
    }
  end);

  -- focuse previous client (https://www.reddit.com/r/awesomewm/comments/k5otdr/raise_2nd_highest_client_window_on_close/)
  screen.connect_signal('tag::history::update', function()
    gears.timer {
      timeout       = 0.1,
      single_shot   = true,
      autostart     = true,
      callback      = function()
        if mouse.current_client ~= nil then
          mouse.current_client:activate()
        else
          local t = awful.screen.focused().selected_tag
          local clients = t:clients()
          for _, c in ipairs(clients) do
            if c.minimized == false then
              c:activate()
              break
            end
          end
        end
      end
    }
  end)

  -- NOTIFICATIONS
  ruled.notification.connect_signal('request::rules', function()
    ruled.notification.append_rule {
      rule = {},
      properties = { timeout = 0 }
    }
  end);

  function count_clients()
    local n = 0

    if awful.tag.selected() ~= nil then
      for _, c in ipairs(awful.tag.selected():clients()) do
        n = n + 1
      end
    end

    return n
  end

  client.connect_signal("manage", function(c)
    if bottom then awful.client.setslave(c) end
    c.fake_full = true

    c:emit_signal("client_change")
  end)

  client.connect_signal("unmanage", function(c)
    c:emit_signal("client_change")
  end)

  client.connect_signal("client_change", function()
    local clients = count_clients()
    local screen_idx = awful.screen.focused().index

    if clients < 2 then
      if bar_visibility[screen_idx] == true then root.elements.topbar.tasklist()[screen_idx].visible = false end
    end
    if clients >= 2 then
      if bar_visibility[screen_idx] == true then root.elements.topbar.tasklist()[screen_idx].visible = true end
    end

    local t = awful.tag.selected()

    if clients > 2 then
      t.master_width_factor = 0.38
    else
      t.master_width_factor = 0.5
    end

    setup_columns(t)
  end)

  function bar_hygenie()
    local clients = count_clients()
    local screen_idx = awful.screen.focused().index

    if clients < 2 then
      if bar_visibility[screen_idx] == true then root.elements.topbar.tasklist()[screen_idx].visible = false end
    end

    if clients >= 2 then
      if bar_visibility[screen_idx] == true then root.elements.topbar.tasklist()[screen_idx].visible = true end
    end
  end

  local cached_layout = nil

  client.disconnect_signal("request::geometry", awful.ewmh.geometry)
  client.connect_signal("request::geometry", function(c, context, ...)
    if context ~= "fullscreen" then
      awful.ewmh.geometry(c, context, ...)
    else
      if c.fake_full then
        local geo = c:geometry()
        c:geometry({
          width = geo.width,
          height = geo.height - 1
        })

        cached_layout = awful.layout.get(awful.screen.focused())
        awful.layout.set(awful.layout.suit.floating)
      else
        awful.ewmh.geometry(c, context, ...)
      end
    end
  end)

  client.connect_signal("property::fullscreen", function(c)
    if c.fake_full and not c.fullscreen then
      if cached_layout ~= nil then awful.layout.set(awful.layout.suit.tile) end
      cached_layout = nil
    end
  end)

  -- switch to client of other tag
  client.connect_signal("request::activate", function(c)
    if c then
      local client_tag = c.first_tag
      local current_tag = awful.screen.focused().selected_tag

      if client_tag ~= current_tag then
        client_tag:view_only()
      end
    end
  end)

  client.connect_signal("property::floating", function(c)
    if c.floating and not c.fullscreen then
      c:raise()
      c.above = true
      c.ontop = true
      client.focus = c
    end
  end)

  client.connect_signal("tiled", function(c)
    c:lower()
    c.above = false
    c.ontop = false
  end)


  -- hide / show clients in tasklist
  tag.connect_signal('property::selected', function(t)
    bar_hygenie()
  end)

  -- SPAWNS
  awful.spawn.with_shell("$HOME/.config/awesome/scripts/screen.sh");
  awful.spawn.with_shell("$HOME/.config/awesome/scripts/wallpaper.sh");
  awful.spawn.with_shell("$HOME/.config/awesome/scripts/compositor.sh");
  awful.spawn.with_shell("nm-applet &");
  awful.spawn.with_shell('instantmouse s "$(iconf mousespeed)"');


  -- IDLE
  awful.spawn.with_line_callback(config.commands.idle, {
    stdout = function(o)
      if o == 'lock' and root.elements.powermenu then
        root.elements.powermenu.lock();
      elseif o == 'suspend' then
        awful.spawn(config.commands.suspend);
      end
    end
  });

  os.execute('sleep 0.1');
  if root.elements.topbar then root.elements.topbar.show() end;

  awful.layout.set(awful.layout.suit.max)
  awful.layout.set(awful.layout.suit.tile)

