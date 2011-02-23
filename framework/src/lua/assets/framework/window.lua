framework = framework or {}

framework.Window = 
{
  getWidth = function() return _c_framework.screenWidth() end,
  getHeight = function() return _c_framework.screenHeight() end
}


