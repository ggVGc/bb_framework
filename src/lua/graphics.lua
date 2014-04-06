framework = framework || {};
framework.Graphics = {}

function framework.Graphics.drawQuad(x,y,w,h,colour,rot,pivot)
  px = 0.5
  py = 0.5
  if pivot then
    px = pivot[1] or px
    py = pivot[2] or py
  end

  _c_framework.quadDrawCol(x, y, w, h,
    colour[1] or 0, colour[2] or 0, colour[3] or 0,colour[4] or 1,
    rot or 0, px, py)
end
