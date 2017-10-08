
hs.window.animationDuration = 0
hs.window.highlight.ui.overlay=true
hs.window.highlight.ui.frameWidth = 10
hs.window.highlight.ui.frameColor = {0,0.6,1,0.5}
hs.application.enableSpotlightForNameSearches(true)
hs.dockicon.hide()

-- ----------------
-- Screens
-- ----------------

local macbook = "Color LCD"

-- ----------------
-- Modifiers
-- ----------------

local kHyper = {"cmd", "alt", "ctrl"}
local kPos = {"cmd", "alt"}
local kSize = {"ctrl", "alt"}
local kFocus = {"cmd"}

-- ----------------
-- Arrows
-- ----------------

local up = "up"
local right = "right"
local down = "down"
local left = "left"

-- ----------------
-- Reload Config
-- ----------------

hs.hotkey.bind(kHyper, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

-- ----------------------
-- App Launcher Shortcuts
-- ----------------------

hs.hotkey.bind(kHyper, "S", function()
  hs.application.launchOrFocus("System Preferences")
end)

-- ----------------------
-- Script Execution Shortcuts
-- ----------------------

hs.hotkey.bind(kHyper, "T", function()
  hs.execute("osascript AppleScripts/untagged.scpt")
  hs.alert.show("Ran untagged script")
end)


-- ----------------
-- Window Position
-- ----------------

local GRID = {w = 16, h = 16}
hs.grid.setGrid(GRID.w .. 'x' .. GRID.h)
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0

local pressed = {
  up = false,
  down = false,
  left = false,
  right = false
}

-- layoutTypes: "BigBrother", "Equal"

local layoutState = {
  margin = 15,
  layoutType = "BigBrother"
}

function getGridLimits(screen)
  frame = screen:frame()

  if frame.h > 1300 and frame.w > 800 then
    return {h = GRID.h-2, w = GRID.w-2, x = 1, y = 1}
  else
    return {h = GRID.h, w = GRID.w, x = 0, y = 0}
  end
end

hs.hotkey.bind(kPos, up, function ()
  pressed.up = true
  local win = hs.window.frontmostWindow()
  local screen = win:screen()
  local _grid = getGridLimits(screen)
  cell = hs.grid.get(win, screen)
  cell.h = (pressed.down and _grid.h or _grid.h/2)
  cell.y = _grid.y
  hs.grid.set(win, cell, sceen)
end, function () 
  pressed.up = false
end)


hs.hotkey.bind(kPos, right, function ()
  pressed.right = true
  local win = hs.window.frontmostWindow()
  local screen = win:screen()
  local _grid = getGridLimits(screen)
  cell = hs.grid.get(win, screen)
  cell.w = (pressed.left and _grid.w or _grid.w/2)
  cell.x = (pressed.left and _grid.x or _grid.w/2+1)
  hs.grid.set(win, cell, sceen)
end, function () 
  pressed.right = false
end)


hs.hotkey.bind(kPos, down, function ()
  pressed.down = true
  local win = hs.window.frontmostWindow()
  local screen = win:screen()
  local _grid = getGridLimits(screen)
  cell = hs.grid.get(win, screen)
  cell.h = (pressed.up and _grid.h or _grid.h/2)
  cell.y = (pressed.up and _grid.y or _grid.h/2+1)
  hs.grid.set(win, cell, sceen)
end, function () 
  pressed.down = false
end)


hs.hotkey.bind(kPos, left, function ()
  pressed.left = true
  local win = hs.window.frontmostWindow()
  local screen = win:screen()
  local _grid = getGridLimits(screen)
  cell = hs.grid.get(win, screen)
  cell.w = (pressed.right and _grid.w or _grid.w/2)
  cell.x = _grid.x

  hs.grid.set(win, cell, sceen)
end, function () 
  pressed.left = false
end)



-- ----------------
-- Layouts
-- ----------------

function setMargin(margin)
  layoutState.margin = margin
end

function setLayoutType(type)
  layoutState.layoutType = type
end

function decodeLayoutState()
  local layout = {}
  layout.margin = layoutState.margin
  if layoutState.layoutType == "BigBrother" then
    layout.columns = {"cw", 1}
  elseif layoutState.layoutType == "Equal" then
    layout.columns = {1, 1}
  end

  return layout
end

function applyGlobalLayout()
  local layout = decodeLayoutState()

  local windows = hs.fnutils.filter(hs.window.visibleWindows(), isWindowIncluded)
  local screen = hs.screen.mainScreen()
  local currentWin = hs.window.frontmostWindow()
  local frame = screen:frame()

  local m = layout.margin
  local c = {}

  for i=1, #layout.columns do
    if i <= #windows then
      table.insert(c, 0)
    end
  end

  local colWidth = (frame.w-m*(#c+1))/#c

  function height(colWindows)
      return (frame.h-2*m)/(colWindows) - m*(colWindows-1)/(colWindows)
  end

  if inArray(layout.columns, "cw") then
    for i=1, #c do
      if layout.columns[i] == "cw" then
        c[i] = 1
        currentWin:setFrameInScreenBounds({
          x=frame.x+m,
          y=frame.y+m,
          w=colWidth, 
          h=height(1)
        })
      else

        if i == #c then
          c[i] = #windows - sumArray(c)
        else
          c[i] = math.floor(#windows/(#c-1))
        end

        if #c == 1 then
          c[i] = 1
        end

        fixedWindows = 0
        j = 1
        while fixedWindows < c[i] do

          if windows[j] ~= currentWin then
            windows[j]:setFrameInScreenBounds({
              x=frame.x + m + (i-1)*(m+colWidth),
              y=frame.y + m + (fixedWindows)*(height(c[i])+m), 
              w=colWidth, 
              h=height(c[i])
            })

            fixedWindows = fixedWindows + 1
          end
          j = j + 1
        end
      end
    end
  end
end



function setAndApplyLayout(m, t)
  setMargin(m)
  setLayoutType(t)
  applyGlobalLayout()
end

hs.hotkey.bind(kPos, '1', function ()
  setAndApplyLayout(160, "BigBrother")
end)

hs.hotkey.bind(kPos, '2', function ()
  setAndApplyLayout(80, "BigBrother")
end)

hs.hotkey.bind(kPos, '3', function ()
  setAndApplyLayout(40, "BigBrother")
end)

hs.hotkey.bind(kPos, '4', function ()
  setAndApplyLayout(20, "BigBrother")
end)

hs.hotkey.bind(kPos, '5', function ()
  setAndApplyLayout(10, "BigBrother")
end)

hs.hotkey.bind(kPos, '6', function ()
  setAndApplyLayout(0, "BigBrother")
end)




function isWindowIncluded(win)
  onScreen = win:screen() == hs.screen.mainScreen()
  standard = win:isStandard()
  hasTitle = #win:title() > 0
  --isTiling = not excluded[win:id()]
  return onScreen and standard and hasTitle-- and isTiling
end

-- ----------------
-- Window Size
-- ----------------

hs.hotkey.bind(kSize, up, function()
  local win = hs.window.frontmostWindow()
  local screen = win:screen()
  cell = hs.grid.get(win, screen)

  if cell.y == 0 and cell.h > 1 then 
    hs.grid.resizeWindowShorter(win)
  elseif cell.y + cell.h == GRID.h and cell.h < GRID.h then
    hs.grid.pushWindowDown(win)
    hs.grid.resizeWindowTaller(win)
  else
    print("Wrong state in size up")
  end
end)

hs.hotkey.bind(kSize, right, function()
  local win = hs.window.frontmostWindow()
  local screen = win:screen()
  cell = hs.grid.get(win, screen)

  if cell.x == 0 and cell.w < GRID.w then 
    hs.grid.resizeWindowWider(win)
  elseif cell.x + cell.w == GRID.w and cell.w > 1 then
    hs.grid.resizeWindowThinner(win)
    hs.grid.pushWindowRight(win)
  else
    print("Wrong state in size right")
  end
end)

hs.hotkey.bind(kSize, down, function()
  local win = hs.window.frontmostWindow()
  local screen = win:screen()
  cell = hs.grid.get(win, screen)

  if cell.y == 0 and cell.h < GRID.h then 
    hs.grid.resizeWindowTaller(win)
  elseif cell.y + cell.h == GRID.h and cell.h > 1 then
    hs.grid.resizeWindowShorter(win)
    hs.grid.pushWindowDown(win)
  else
    print("Wrong state in size down")
  end
end)

hs.hotkey.bind(kSize, left, function()
  local win = hs.window.frontmostWindow()
  local screen = win:screen()
  cell = hs.grid.get(win, screen)

  if cell.x == 0 and cell.w > 1 then 
    hs.grid.resizeWindowThinner(win)
  elseif cell.x + cell.w == GRID.w and cell.w < GRID.w then
    hs.grid.pushWindowRight(win)
    hs.grid.resizeWindowWider(win)
  else
    print("Wrong state in size left")
  end
end)

-- ----------------
-- Focus Window
-- ----------------

hs.hotkey.bind(kFocus, up, function()
  local win = hs.window.frontmostWindow()
  win:focusWindowNorth(false, true)
end)

hs.hotkey.bind(kFocus, right, function()
  local win = hs.window.frontmostWindow()
  win:focusWindowEast()
end)

hs.hotkey.bind(kFocus, down, function()
  local win = hs.window.frontmostWindow()
  win:focusWindowSouth(false, true)
end)

hs.hotkey.bind(kFocus, left, function()
  local win = hs.window.frontmostWindow()
  win:focusWindowWest()
end)

hs.hotkey.bind(kFocus, "'", function()
  hs.eventtap.keyStroke('ctrl', 'f2')
end)



-- ----------------
-- Helpers
-- ----------------

function sumArray(t)
    local sum = 0
    for k,v in pairs(t) do
        sum = sum + v
    end

    return sum
end

function inArray(t, val)
  print(t)
  for i=1, #t do
    print(t[i])
    print(val)
    if t[i] == val then
      return true
    end
  end
  return false
end