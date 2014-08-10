local Matrix2D
Matrix2D_mt = {
  __tostring: (this)->
    return "[Matrix2D (a="..this.a.." b="..this.b.." c="..this.c.." d="..this.d.." tx="..this.tx.." ty="..this.ty..")]"

}
Matrix2D = {
new: (a, b, c, d, tx, ty) ->
  this = {}
  setmetatable(this, Matrix2D_mt)
  
  Matrix2D.identity = nil
  Matrix2D.DEG_TO_RAD = math.pi/180

  

  this.a = 1
  this.b = 0
  this.c = 0
  this.d = 1
  this.tx = 0
  this.ty = 0
  this.alpha = 1
  this.shadow  = nil
  this.compositeOperation = nil
  this.visible = true

-- constructor:
  
  this.initialize = (a,b,c,d,tx,ty) ->
    this.a = (a == nil) and 1 or a
    this.b = b or 0
    this.c = c or 0
    this.d = (d == nil) and 1 or d
    this.tx = tx or 0
    this.ty = ty or 0

  this.initialize a, b, c, d, tx, ty

-- public methods:
  
  this.prepend = (a, b, c, d, tx, ty) ->
    tx1 = this.tx
    if a ~= 1 or b ~= 0 or c ~= 0 or d ~= 1
      a1 = this.a
      c1 = this.c
      this.a  = a1*a+this.b*c
      this.b  = a1*b+this.b*d
      this.c  = c1*a+this.d*c
      this.d  = c1*b+this.d*d
    this.tx = tx1*a+this.ty*c+tx
    this.ty = tx1*b+this.ty*d+ty
    return this

  
  this.append = (a, b, c, d, tx, ty) ->
    a1 = this.a
    b1 = this.b
    c1 = this.c
    d1 = this.d
    this.a  = a*a1+b*c1
    this.b  = a*b1+b*d1
    this.c  = c*a1+d*c1
    this.d  = c*b1+d*d1
    this.tx = tx*a1+ty*c1+this.tx
    this.ty = tx*b1+ty*d1+this.ty
    return this

  
  this.prependMatrix = (matrix)->
    this.prepend(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty)
    this.prependProperties(matrix.alpha, matrix.shadow,  matrix.compositeOperation, matrix.visible)
    return this

  
  this.appendMatrix = (matrix)->
    this.append(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty)
    this.appendProperties(matrix.alpha, matrix.shadow,  matrix.compositeOperation, matrix.visible)
    return this

  
  this.prependTransform = (x, y, scaleX, scaleY, rotation, skewX, skewY, regX, regY) ->
    local cos
    local sin
    if rotation%360 != 0
      r = rotation*Matrix2D.DEG_TO_RAD
      cos = math.cos(r)
      sin = math.sin(r)
    else
      cos = 1
      sin = 0

    if (regX or regY)
      -- append the registration offset:
      this.tx -= regX
      this.ty -= regY

    if (skewX or skewY)
      -- TODO: can this be combined into a single prepend operation?
      skewX *= Matrix2D.DEG_TO_RAD
      skewY *= Matrix2D.DEG_TO_RAD
      this.prepend(cos*scaleX, sin*scaleX, -sin*scaleY, cos*scaleY, 0, 0)
      this.prepend(math.cos(skewY), math.sin(skewY), -math.sin(skewX), math.cos(skewX), x, y)
    else
      this.prepend(cos*scaleX, sin*scaleX, -sin*scaleY, cos*scaleY, x, y)
    return this

  
  this.appendTransform = (x, y, scaleX, scaleY, rotation, skewX, skewY, regX, regY)->
    local r, cos, sin
    if (rotation%360 != 0)
      r = rotation*Matrix2D.DEG_TO_RAD
      cos = math.cos(r)
      sin = math.sin(r)
    else
      cos = 1
      sin = 0

    if (skewX or skewY)
      -- TODO: can this be combined into a single append?
      skewX *= Matrix2D.DEG_TO_RAD
      skewY *= Matrix2D.DEG_TO_RAD
      this.append(math.cos(skewY), math.sin(skewY), -math.sin(skewX), math.cos(skewX), x, y)
      this.append(cos*scaleX, sin*scaleX, -sin*scaleY, cos*scaleY, 0, 0)
    else
      this.append(cos*scaleX, sin*scaleX, -sin*scaleY, cos*scaleY, x, y)

    if (regX or regY)
      -- prepend the registration offset:
      this.tx -= regX*this.a+regY*this.c
      this.ty -= regX*this.b+regY*this.d
    return this

  
  this.rotate = (angle) ->
    cos = math.cos(angle)
    sin = math.sin(angle)

    a1 = this.a
    c1 = this.c
    tx1 = this.tx

    this.a = a1*cos-this.b*sin
    this.b = a1*sin+this.b*cos
    this.c = c1*cos-this.d*sin
    this.d = c1*sin+this.d*cos
    this.tx = tx1*cos-this.ty*sin
    this.ty = tx1*sin+this.ty*cos
    return this

  
  this.skew = (skewX, skewY) ->
    skewX = skewX*Matrix2D.DEG_TO_RAD
    skewY = skewY*Matrix2D.DEG_TO_RAD
    this.append(math.cos(skewY), math.sin(skewY), -math.sin(skewX), math.cos(skewX), 0, 0)
    return this

  
  this.scale = (x, y) ->
    this.a *= x
    this.d *= y
    this.c *= x
    this.b *= y
    this.tx *= x
    this.ty *= y
    return this

  
  this.translate = (x, y) ->
    this.tx += x
    this.ty += y
    return this

  
  this.identity = () ->
    this.d = 1
    this.a = this.d
    this.alpha = this.a
    this.ty = 0
    this.tx = this.ty
    this.c = this.tx
    this.b = this.c
    this.compositeOperation = nil
    this.shadow = this.compositeOperation
    this.visible = true
    return this

  
  this.invert = ()->
    a1 = this.a
    b1 = this.b
    c1 = this.c
    d1 = this.d
    tx1 = this.tx
    n = a1*d1-b1*c1

    this.a = d1/n
    this.b = -b1/n
    this.c = -c1/n
    this.d = a1/n
    this.tx = (c1*this.ty-d1*tx1)/n
    this.ty = -(a1*this.ty-b1*tx1)/n
    return this

  
  this.isIdentity = ()->
    return this.tx == 0 and this.ty == 0 and this.a == 1 and this.b == 0 and this.c == 0 and this.d == 1

  
  this.transformPoint = (x, y, pt) ->
    pt = pt or {}
    pt.x = x*this.a+y*this.c+this.tx
    pt.y = x*this.b+y*this.d+this.ty
    return pt

  
  --this.decompose = function(target) {
      ---- TODO: it would be nice to be able to solve for whether the matrix can be decomposed into only scale/rotation
      ---- even when scale is negative
      --if (target == null) { target = {} }
      --target.x = this.tx
      --target.y = this.ty
      --target.scaleX = Math.sqrt(this.a * this.a + this.b * this.b)
      --target.scaleY = Math.sqrt(this.c * this.c + this.d * this.d)

      --skewX = Math.atan2(-this.c, this.d)
      --skewY = Math.atan2(this.b, this.a)

      --if (skewX == skewY) {
          --target.rotation = skewY/Matrix2D.DEG_TO_RAD
          --if (this.a < 0 && this.d >= 0) {
              --target.rotation += (target.rotation <= 0) ? 180 : -180
          --}
          --target.skewX = target.skewY = 0
      --} else {
          --target.skewX = skewX/Matrix2D.DEG_TO_RAD
          --target.skewY = skewY/Matrix2D.DEG_TO_RAD
      --}
      --return target
  --}

  
  this.reinitialize = (a, b, c, d, tx, ty, alpha, shadow, compositeOperation, visible)->
    this.initialize(a,b,c,d,tx,ty)
    this.alpha = alpha == nil and 1 or alpha
    this.shadow = shadow
    this.compositeOperation = compositeOperation
    this.visible = visible == nil and true or visible
    return this
  
  
  this.copy = (matrix) ->
    return this.reinitialize(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty, matrix.alpha, matrix.shadow, matrix.compositeOperation, matrix.visible)

  
  this.appendProperties = (alpha, shadow, compositeOperation, visible) ->
    this.alpha *= alpha
    this.shadow = shadow or this.shadow
    this.compositeOperation = compositeOperation or this.compositeOperation
    this.visible = this.visible and visible
    return this

  
  this.prependProperties = (alpha, shadow, compositeOperation, visible) ->
    this.alpha *= alpha
    this.shadow = this.shadow or shadow
    this.compositeOperation = this.compositeOperation or compositeOperation
    this.visible = this.visible and visible
    return this

  
  this.clone = () ->
    return (Matrix2D.new!).copy(this)


  -- this has to be populated after the class is defined:
  return this
}

Matrix2D.identity = Matrix2D.new!

framework.Matrix2D = Matrix2D
