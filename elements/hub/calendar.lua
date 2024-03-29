local os = require('os');
local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local rounded = require('helpers.rounded');
local xrdb = beautiful.xresources.get_current_theme();

return function()
  local view = wibox.container.margin();
  view.left = config.global.m;
  view.right = config.global.m;

  local title = wibox.widget.textbox("Calendar");
  title.font = config.fonts.tlb;
  title.forced_height = config.hub.i + config.global.m + config.global.m;

  local close = wibox.widget.textbox(config.icons.close);
  close.font = config.fonts.il;
  close.forced_height = config.hub.i;
  close:buttons(gears.table.join(
    awful.button({}, 1, function() if root.elements.hub then root.elements.hub.close() end end)
  ));

  local cal_container = wibox.container.background();
  cal_container.bg = config.colors.b;
  cal_container.shape = rounded();
  cal_container.forced_width = config.hub.w - config.hub.nw - (config.global.m*2);
  cal_container.forced_height = config.hub.w - config.hub.nw - (config.global.m*2);

  cal_container:setup {
    layout = wibox.container.place,
    valign = "center",
    halign = "center",
    {
      layout = wibox.layout.grid,
      horizontal_spacing = 30,
      vertical_spacing = 60,
      forced_num_cols = 2,
      forced_num_rows = 2,
      expand = true,
      left = config.global.m, right = config.global.m, bottom = config.global.m,
      {
        date = {month = os.date('*t').month - 1, year = os.date('*t').year},
        font = config.fonts.tll,
        widget = wibox.widget.calendar.month,
      },
      {
        date = os.date('*t'),
        font = config.fonts.tll,
        widget = wibox.widget.calendar.month,
      },
      {
        date = {month = os.date('*t').month + 1, year = os.date('*t').year},
        font = config.fonts.tll,
        widget = wibox.widget.calendar.month,
      },
      {
        date = {month = os.date('*t').month + 2, year = os.date('*t').year},
        font = config.fonts.tll,
        widget = wibox.widget.calendar.month,
      }
    }
  }

  view:setup {
    layout = wibox.container.background,
    fg = config.colors.xf,
    {
      layout = wibox.layout.align.vertical,
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
        layout = wibox.container.place,
        valign = "top",
        halign = "center",
        cal_container,
      }
    }
  }

  return view;
end
