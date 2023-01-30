local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();
local bling = require("bling")
local dpi = beautiful.xresources.apply_dpi

local playerctl = bling.signal.playerctl.lib {
  player = { "nuclear", "%any" }
}

return function()
  local view = wibox.container.margin();
  view.left = config.global.m;
  view.right = config.global.m;

  local title = wibox.widget.textbox("Media");
  title.font = config.fonts.tlb;
  title.forced_height = config.hub.i + config.global.m + config.global.m;
  view.title = title

  local close = wibox.widget.textbox(config.icons.close);
  close.font = config.fonts.il;
  close.forced_height = config.global.slider;
  close:buttons(gears.table.join(
    awful.button({}, 1, function() if root.elements.hub then root.elements.hub.close() end end)
  ));
  view.close = close

  local vol_font_size = (dpi(13) * 0.88)

  local vol_heading = wibox.widget.textbox('Volume');
  vol_heading.font = config.fonts.d .. vol_font_size;

  local vol_footer = wibox.widget.textbox('test');
  vol_footer.font = config.fonts.tsl;
  vol_footer.align = 'right';

  local vol_slider = wibox.widget.slider();
  vol_slider.bar_shape = function(c,w,h) gears.shape.rounded_rect(c,w,h,config.global.slider/2) end;
  vol_slider.bar_height = config.global.slider;
  vol_slider.bar_color = config.colors.b..'26';
  vol_slider.bar_active_color = config.colors.w;
  vol_slider.handle_shape = gears.shape.circle;
  vol_slider.handle_width = config.global.slider;
  vol_slider.handle_color = config.colors.w;
  vol_slider.handle_border_width = 1;
  vol_slider.handle_border_color = config.colors.x7;
  vol_slider.minimum = 0;
  vol_slider.maximum = 100;
  vol_slider:connect_signal('property::value', function()
    awful.spawn.with_shell(config.commands.setvol.. ' ' ..tostring(vol_slider.value));
    vol_heading.markup = 'Volume: <span font="'..config.fonts.tll..'">'..vol_slider.value..'</span>';
  end);

  local mute = wibox.widget.textbox();
  mute.font = config.fonts.i .. vol_font_size;

  local album_icon = wibox.widget.imagebox();
  album_icon.clip_shape = rounded();
  album_icon.forced_height = dpi(140);
  album_icon.forced_width = dpi(140);
  album_icon.resize = true;

  local spotify_icon = wibox.widget {
    layout = wibox.container.background,
    bg = config.colors.w,
    forced_height = dpi(140),
    forced_width = dpi(140),
    shape = rounded(),
    {
      layout = wibox.container.place,
      valign = "center",
      halign = "center",
      {
        widget = wibox.widget.textbox,
        font = config.fonts.i..' 70',
        text = config.icons.spot,
      }
    }
  };

  spotify_icon:connect_signal('mouse::enter', function(self)
   self.forced_height = dpi(142)
   self.forced_width = dpi(142)
  end)

  spotify_icon:connect_signal('mouse::leave', function(self)
   self.forced_height = dpi(140)
   self.forced_width = dpi(140)
  end)

  spotify_icon:buttons(
    awful.button({}, 1, function()
      awful.spawn.with_shell(config.commands.spotify_play)
    end)
  )

  local icon = spotify_icon;

  local spotify_title = wibox.widget.textbox('Nothing playing');
  local spotify_message = wibox.widget.textbox('');
  spotify_message.font = config.fonts.tml;
  spotify_title.font = config.fonts.tlb;

  local playback_font = config.fonts.i .. '28'

  local play = wibox.widget.textbox();
  play.font = playback_font;
  play.text = config.icons.play;

  play:connect_signal('mouse::enter', function()
    play.markup = '<span foreground="'..config.colors.w..'">'..play.text..'</span>';
  end);

  play:connect_signal('mouse::leave', function()
    play.text = play.text;
  end);

  local next = wibox.widget.textbox(config.icons.next);
  next.font = playback_font;

  next:connect_signal('mouse::enter', function()
    next.markup = '<span foreground="'..config.colors.w..'">'..next.text..'</span>';
  end);

  next:connect_signal('mouse::leave', function()
    next.text = next.text;
  end);

  local prev = wibox.widget.textbox(config.icons.prev);
  prev.font = playback_font;

  prev:connect_signal('mouse::enter', function()
    prev.markup = '<span foreground="'..config.colors.w..'">'..prev.text..'</span>';
  end);

  prev:connect_signal('mouse::leave', function()
    prev.text = prev.text;
  end);

  local spotify = wibox.layout.align.horizontal();
  spotify.third = nil;
  spotify.first = icon;
  spotify.second = wibox.widget {
    layout = wibox.layout.align.vertical,
    {
      layout = wibox.container.margin,
      left = config.global.m,
      {
        layout = wibox.layout.fixed.vertical,
        { layout = wibox.container.constraint, spotify_title },
        { layout = wibox.container.constraint, spotify_message },
      }
    },
    nil,
    {
      layout = wibox.layout.flex.horizontal,
      { layout = wibox.container.place, halign = 'right', prev },
      { layout = wibox.container.place, play },
      { layout = wibox.container.place, halign = 'left', next },
    }
  };

  local media_progress = wibox.container.background()
  media_progress.bg = config.colors.x1

  local media_container = wibox.widget {
    layout = wibox.container.background,
    shape = rounded(),
    bg = config.colors.b,
    forced_width = (config.hub.w - config.hub.nw) - (config.global.m*2),
    {
      layout = wibox.container.margin,
      margins = config.global.m,
      spotify
    }
  }

  local function player_exit()
    play.text = config.icons.play
    spotify_title.text = 'Nothing playing'
    spotify_message.text = ''
    media_progress.visible = false
  end

  playerctl:connect_signal("exit", function(_) player_exit() end)

  playerctl:connect_signal("position", function(_, interval, length, player_name)
    media_progress.visible = true
    local max_width = (config.hub.w - config.hub.nw) - (config.global.m*2)
    local current_progress = math.floor(interval / length * max_width)
    media_progress.forced_width = current_progress

    if length > 0 then
      media_container.bg = config.colors.b .. '98'
    else
      media_container.bg = config.colors.b
    end
  end)

  playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, new, player_name)
    if album_path ~= '' then
      album_icon:set_image(gears.surface.load_uncached(album_path))
      spotify.first = album_icon
    else
      spotify.first = icon
    end

    if title ~= '' then
      spotify_title.text = title
      spotify_message.text = artist
    else
      player_exit()
    end
  end)

  playerctl:connect_signal("playback_status", function(_, playing, player_name)
    play.text = playing and config.icons.pause or config.icons.play
  end)


  play:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.spawn.with_shell(config.commands.play);
    end)
  ));

  next:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.spawn.with_shell(config.commands.next);
    end)
  ));

  prev:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.spawn.with_shell(config.commands.prev);
    end)
  ));

  function mute_handling()
    awful.spawn.easy_async_with_shell(config.commands.ismuted, function(o,e,r,c)
      if c == 0 then
        vol_slider.bar_active_color = config.colors.b..'26';
        vol_heading.markup = 'Volume <span font="'..config.fonts.dl..vol_font_size..'">(muted)</span>';
        mute.text = config.icons.vol_mute
      else
        vol_slider.bar_active_color = config.colors.w;
        vol_heading.markup = 'Volume: <span font="'..config.fonts.dl..vol_font_size..'">'..vol_slider.value..'</span>';
        mute.text = config.icons.vol_1
      end;
    end);
  end

  view.refresh = function()
    local temp_vol = vol_slider.value;

    awful.spawn.easy_async_with_shell(config.commands.audiosrc, function(o)
      if o then vol_footer.markup = 'Output: <span font="'..config.fonts.d..'10">'..o:gsub("^%s*(.-)%s*$", "%1")..'</span>' end;
    end);

    awful.spawn.easy_async_with_shell(config.commands.vol, function(o)
      vol_slider:set_value(tonumber(o));
    end);

    mute_handling()
  end

  mute:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.spawn.easy_async_with_shell(config.commands.mute, view.refresh);
    end)
  ));

  view:setup {
    layout = wibox.container.background,
    fg = config.colors.xf,
    {
      layout = wibox.layout.fixed.vertical,
      spacing = config.global.m,
      {
        layout = wibox.layout.align.horizontal,
        nil,
        {
          layout = wibox.container.place,
          title
        },
        close
      },
      {
        layout = wibox.container.background,
        bg = config.colors.b,
        shape = rounded(),
        {
          layout = wibox.layout.fixed.vertical,
          {
            layout = wibox.container.margin,
            margins = config.global.m,
            {
              layout = wibox.layout.align.horizontal,
              vol_heading,
              nil,
              mute,
            }
          },
          {
            layout = wibox.container.margin,
            left = config.global.m,
            right = config.global.m,
            bottom = config.global.m,
            forced_height = config.global.slider + (config.global.m*2),
            vol_slider
          },
          {
            layout = wibox.container.margin,
            left = config.global.m,
            right = config.global.m,
            vol_footer,
          },
          {
            layout = wibox.container.margin,
            left = config.global.m,
            right = config.global.m,
            bottom = config.global.m,
            mic_footer,
          }
        }
      },
      {
        {
          layout = wibox.container.background,
          shape = rounded(),
          forced_height = dpi(140) + config.global.m, -- cannot be computed (album_icon + config.global.m)
          forced_width = (config.hub.w - config.hub.nw) - (config.global.m*2),
          {
            layout = wibox.layout.fixed.horizontal,
            media_progress
          }
        },
        media_container,
        layout = wibox.layout.stack
      },
      id ="view_background_role"
    }
  }

  return view;
end
