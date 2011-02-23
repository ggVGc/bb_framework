dofile("class.lua")


BitmapAnim = Class:new
{
  currentFrame = 0,
  frameTime = 0,
  elapsedTime = 0,
  frames = {}
}

function BitmapAnim:init(imagePaths, timePerFrame)
  self.rot = 0
  self.pivX = 0.5
  self.pivY = 0.5
  self.scaleX  = 1
  self.scaleY = 1
  self.currentFrame = 1
  self.frameTime = timePerFrame
  self.elapsedTime = 0
  for x=1, #imagePaths do
    local p = imagePaths[x]
    table.insert(self.frames, framework.bitmapCreate(p))
  end
  --self.frames = imagePaths
  --for i in imagePaths do
    --trace(i)
    --local b = bitmapCreate(i)
    --self.frames.append(b)
  --end
end

function BitmapAnim:update(deltaMs)
  self.elapsedTime = self.elapsedTime + deltaMs

  while self.elapsedTime > self.frameTime do
    self.elapsedTime = self.elapsedTime - self.frameTime
    self:stepFrame()
  end
end

function BitmapAnim:draw(x, y)
  framework.bitmapDraw(self.frames[self.currentFrame], x, y, self.rot, self.pivX, self.pivY, self.scaleX, self.scaleY)
end


function BitmapAnim:stepFrame()
  self.currentFrame = self.currentFrame + 1
  if self.currentFrame > #self.frames then
    self.currentFrame = 1
  end
end

