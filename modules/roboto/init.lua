local roboto = {
  _VERSION     = 'roboto 0.0.0',
  _DESCRIPTION = 'Material World Roboto - Material Design Roboto font and sizes for LÖVE',
  _URL         = 'https://github.com/Positive07/material-world',
  _LICENSE     = 'MIT LICENSE - Copyright (c) 2017 Pablo A. Mayobre (Positive07)'
}

local path = (...):gsub('%.','/'):gsub('init$', '')

local light   = path..'/roboto-light.ttf'
local medium  = path..'/roboto-medium.ttf'
local regular = path..'/roboto-regular.ttf'

roboto.files = { -- Path and name of each font
  light   = {name = 'Roboto Light',   file = light  },
  medium  = {name = 'Roboto Medium',  file = medium },
  regular = {name = 'Roboto Regular', file = regular},
}

-- All three fonts should be available
for _,v in pairs(roboto.files) do
  local name, file = v.name, v.file
  if not love.filesystem.getInfo(file) then
    error("Material Love's '"..name.."' font is missing at path '"..file.."'", 1)
  end
end

--Material Design makes a distinction on mobile
local OS = love.system.getOS()
local n  = (OS == 'Android' or OS == 'iOS') and 0 or 1

local newFont = love.graphics.newFont
local tp = love.window.toPixels

roboto.font = {
  -- Display fonts
  display4 = newFont(light,  tp(112)),
  display3 = newFont(regular,tp(56)),
  display2 = newFont(regular,tp(45)),
  display1 = newFont(regular,tp(34)),
  headline = newFont(regular,tp(24)),
  title    = newFont(medium, tp(20)),
  subhead  = newFont(regular,tp(16 - n)),
  body2    = newFont(medium, tp(14 - n)),
  body1    = newFont(regular,tp(14 - n)),
  caption  = newFont(regular,tp(12)),
  button   = newFont(medium, tp(15)),
}

function roboto.get (name)
  if roboto.font[name] then
    return roboto.font[name]
  else
    error("The font '"..name.."' is not part of the Roboto set", 2)
  end
end

return setmetatable(roboto, {
  __call = function (self, name)
    return self.get(name)
  end,
  __index = function (self, index)
    return self.font[index]
  end
})
