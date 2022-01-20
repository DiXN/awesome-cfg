local gears = require('gears');
local awful = require('awful');
local beautiful = require('beautiful');
local xrdb = beautiful.xresources.get_current_theme();

local config = {
  global = {
    m = 10,
    r = 7,
    o = 0.35,
    slider = 30,
    user = gears.filesystem.get_configuration_dir()..'/user.png',
  },
  colors = {
    b = '#333538',
    t = '#00000000',
    w = '#fefefe',
    f = '#919fb585',
    xf = xrdb.foreground,
    xb = xrdb.background,
    x0 = xrdb.color0,
    x1 = xrdb.color1,
    x2 = xrdb.color2,
    x3 = xrdb.color3,
    x4 = xrdb.color4,
    x5 = xrdb.color5,
    x6 = xrdb.color6,
    x7 = xrdb.color7,
    x8 = xrdb.color8,
    x9 = xrdb.color9,
    x10 = xrdb.color10,
    x11 = xrdb.color11,
    x12 = xrdb.color12,
    x13 = xrdb.color13,
    x14 = xrdb.color14,
    x15 = xrdb.color15,
  },
  fonts = {
    is = "Material Design Icons Desktop 12",
    im = "Material Design Icons Desktop 14",
    il = "Material Design Icons Desktop 20",
    ixxl = "Material Design Icons Desktop 100",
    ts = "SF Pro Display 9",
    tm = "SF Pro Display 10",
    tl = "SF Pro Display 12",
    tsl = "SF Pro Display Light 9",
    tml = "SF Pro Display Light 10",
    tll = "SF Pro Display Light 12",
    tsb = "SF Pro Display Semibold 9",
    tmb = "SF Pro Display Semibold 10",
    tlb = "SF Pro Display Semibold 12",
    txlb = "SF Pro Rounded Semibold 15",
    txxlb = "SF Pro Rounded Semibold 25",
    mlb = "Operator Mono Lig Bold 12",
    mll = "Operator Mono Lig Light 12",
    m = "Operator Mono Lig",
    t = "SF Pro Rounded",
    i = "Material Design Icons Desktop ",
  },
  powermenu = {
    w = 500,
    h = 330,
    hh = 230,
    a = 100,
  },
  topbar = {
    h = 30,
    w = 30,
    dw = 275,
    utilities = {
      wifi = false,
      bt = true,
      lan = true,
      vol = true,
      bat = false,
      pac = true,
      mem = true,
      note = true,
      bat = false,
    },
  },
  tagswitcher= {
    h = 120,
  },
  hub = {
    i = 40,
    w = 800,
    h = 600,
    nw = 260,
  },
  icons = {
    arch = '󰣇',
    power = '󰐥',
    date = '󰸘',
    time = '󰅐',
    vol_mute = '󰝟',
    vol_1 = '󰕿',
    vol_2 = '󰖀',
    vol_3 = '󰕾',
    wifi = '󰖩',
    wifix = '󰖪',
    bt = '󰂯',
    btx = '󰂲',
    pac = '󰏗',
    mem = '󰍛',
    lan = '󰲝',
    lanx = '󰲜',
    note = '󰀠',
    web = '󰖟',
    system = '󰄨',
    display = '󰇄',
    media = '󰝚',
    theme = '󰸌',
    down = '󰳜',
    close = '󰅖',
    clear = '󰎟',
    lock = '󰍁',
    unlock = '󰍀',
    play = '󰐌',
    pause = '󰏥',
    next = '󰒭',
    prev = '󰒮',
    spot = '󰓇',
    restart = '󰜉',
    logout = '󰗽',
    suspend = '󰤄',
    bat10 = '󰁺',
    bat20 = '󰁻',
    bat30 = '󰁼',
    bat40 = '󰁽',
    bat50 = '󰁾',
    bat60 = '󰁿',
    bat70 = '󰂀',
    bat80 = '󰂁',
    bat90 = '󰂂',
    bat = '󰁹',
  },
  commands = {
    getbrightness = gears.filesystem.get_configuration_dir()..'scripts/getbrightness.sh',
    setbrightness = gears.filesystem.get_configuration_dir()..'scripts/setbrightness.sh',
    art = gears.filesystem.get_configuration_dir()..'scripts/albumart.sh',
    getwall = gears.filesystem.get_configuration_dir()..'scripts/wall.sh',
    resize = gears.filesystem.get_configuration_dir()..'scripts/resize.sh',
    cpucmd = gears.filesystem.get_configuration_dir()..'scripts/cpu.sh',
    ramcmd = gears.filesystem.get_configuration_dir()..'scripts/ram.sh',
    diskcmd = gears.filesystem.get_configuration_dir()..'scripts/disk.sh',
    wifiup = gears.filesystem.get_configuration_dir()..'scripts/wifiup.sh',
    lanup = gears.filesystem.get_configuration_dir()..'scripts/lanup.sh',
    btup = gears.filesystem.get_configuration_dir()..'scripts/btup.sh',
    btdevices = gears.filesystem.get_configuration_dir()..'scripts/btdevices.sh',
    btdevice = gears.filesystem.get_configuration_dir()..'scripts/btdevice.sh',
    spotify_state = gears.filesystem.get_configuration_dir()..'scripts/spotify.sh',
    idle = 'bash -c "xidlehook --not-when-audio --timer 500 \'echo lock\' \'\' --timer 9000 \'echo suspend\' \'\'"',
    proccmd = 'bash -c "ps -eo comm:50,%mem,%cpu --sort=-%cpu,-%mem | head -n 6"',
    synccmd = 'bash -c "yay -Syy"',
    updatescmd = 'bash -c "yay -Sup | wc -l"',
    ismuted = 'bash -c "pamixer --get-mute | diff <(echo \"true\") -"',
    vol = 'bash -c "pamixer --get-volume"',
    volup = 'pamixer -i 3',
    voldown = 'pamixer -d 3',
    setvol = 'pamixer --set-volume',
    mute = 'pamixer -t',
    ssid = 'bash -c "iwgetid -r"',
    setwall = 'nitrogen',
    browser = "brave",
    editor = "nvim",
    terminal = "alacritty",
    files = "nautilus",
    spotify = "spotify",
    nvidia = "nvidia-settings",
    rofi = "rofi -show drun -theme global",
    rofi2 = "rofi -show drun -theme launcher",
    software = "pamac-manager",
    pause = "spt playback -t",
    play = "spt playback -t",
    next = "spt playback --next",
    prev = "spt playback --previous",
    artist = gears.filesystem.get_configuration_dir()..'scripts/spotify.sh'..' artist',
    song = gears.filesystem.get_configuration_dir()..'scripts/spotify.sh'..' song',
    isplaying = 'spt playback -s 2>&1 | diff <(echo \"Error: no context available\") -',
    suspend = "systemctl suspend",
    restart = "systemctl reboot",
    shutdown = "systemctl poweroff",
    scrot = "mkdir -p ~/Pictures/scrot && scrot '%Y-%m-%d-%h-%m-%s_scrot.png' -e 'mv $f ~/Pictures/scrot/'",
    scrotclip = "sleep 0.2 && scrot -s -e 'xclip -selection clipboard -t image/png -i $f'",
    scrotclipsave = "mkdir -p ~/Pictures/scrot && sleep 0.2 && scrot -s -e 'mv $f ~/Pictures/scrot'",
    audiosrc = "pamixer --list-sinks | awk -F\\\" '{print $4}'",
    micsrc = "pamixer --list-sources | grep $(pacmd list-sources | grep '*' | awk '{print $3}' ) | awk -F\\\" '{print $4}'",
    batcmd = 'bash -c "acpi -V | grep -m 1 \'Battery 1\' | awk -F, \'{print $2}\' | sed \'s/%//\'"',
    secondary = 'xrandr --output HDMI-0 --mode 2560x1440 --right-of DP-4 --output DP-4 --off',
    secondthird = 'xrandr --output HDMI-0 --mode 2560x1440 --right-of DP-4 && xrandr --output DP-3 --mode 1360x768 --right-of HDMI-0 && xrandr --output DP-4 --off',
    switch_inputs = gears.filesystem.get_configuration_dir()..'scripts/hotplug_wrapper.sh'..' add',
  },
  notifications = {
    w = 200,
  },
  display = {
    sw = 120,
  },
  media = {
    nowplaying = nil,
  }
};

awful.spawn.easy_async_with_shell('which alacritty', function(o,e,r,c)
  if c == 0 then config.commands.terminal = 'alacritty' end;
end);

return config;
