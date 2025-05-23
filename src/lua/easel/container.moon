
local Container
Container = {
new: ->
  displayObj = framework.DisplayObject.new!
  self = displayObj
  self.children = {}
  self.mouseChildren = true
  self.tickChildren = true
  self.tickOnlyWhenVisible = true
  
  self.isVisible = ->
    --hasContent = self.cacheCanvas or #self.children>0
    hasContent = #self.children>0
    --return not not (self.visible and self.alpha > 0 and self.scaleX ~= 0 and self.scaleY ~= 0 and hasContent)
    return not not (self.visible and hasContent)

  self.draw = ->
    if not self.visible
      return
    --if displayObj.draw(ctx, ignoreCache)
      --return true
  
    --print 'Container draw, count:', #self.children
    for i=1, #self.children
      child = self.children[i]
      if not child.isVisible()
        continue

      if self.freezeTransform
        child.freezeTransform = self.freezeTransform
      child.draw!
    return true
  
  self.addChild = (child, ...)->
    if child == nil
      return child
    
    if child.parent
      child.parent.removeChild child
    child.parent = self
    _c_framework.DisplayObject_setParent child.dispObj, self.dispObj
    table.insert self.children, child
    if select('#', ...) > 0
      return self.addChild(...)
    else
      return child

  
  self.addChildAt = (child, index, ...)->
    --if index < 1 or index > #self.children
      --return arguments[l-1]
    if child.parent
      child.parent.removeChild(child)
    child.parent = self
    _c_framework.DisplayObject_setParent child.dispObj, self.dispObj
    table.insert self.children, index, child
    if select('#', ...) > 0
      return self.addChildAt(...)
    else
      return child

  
  self.removeChild = (child, ...)->
    if select('#', ...) > 0
      return self.removeChild(...)
    else
      return self.removeChildAt(_.indexOf(self.children, child))
    

  
  self.removeChildAt = (index, ...)->
    child = self.children[index]
    if child
      child.parent = nil
      child.dispObj.parent = nil
    table.remove(self.children, index)

    if select('#', ...) > 0
      return self.removeChildAt(...)
    else
      return true

  
  self.removeAllChildren = ->
    for i=#self.children,1,-1
      self.children[i].parent = nil
      table.remove self.children, i


  
  --p.getChildAt = function(index) {
      --return self.children[index];
  --};
  
  
  --p.getChildByName = function(name) {
      --var kids = self.children;
      --for (var i=0,l=kids.length;i<l;i++) {
          --if(kids[i].name == name) { return kids[i]; }
      --}
      --return nil;
  --};

  
  --p.sortChildren = function(sortFunction) {
      --self.children.sort(sortFunction);
  --};

  
  --p.getChildIndex = function(child) {
      --return createjs.indexOf(self.children, child);
  --};

  
  --p.getNumChildren = function() {
      --return self.children.length;
  --};
  
  
  --p.swapChildrenAt = function(index1, index2) {
      --var kids = self.children;
      --var o1 = kids[index1];
      --var o2 = kids[index2];
      --if (!o1 || !o2) { return; }
      --kids[index1] = o2;
      --kids[index2] = o1;
  --};
  
  
  --p.swapChildren = function(child1, child2) {
      --var kids = self.children;
      --var index1,index2;
      --for (var i=0,l=kids.length;i<l;i++) {
          --if (kids[i] == child1) { index1 = i; }
          --if (kids[i] == child2) { index2 = i; }
          --if (index1 != nil && index2 != nil) { break; }
      --}
      --if (i==l) { return; } 
      --kids[index1] = child2;
      --kids[index2] = child1;
  --};
  
  
  --p.setChildIndex = function(child, index) {
      --var kids = self.children, l=kids.length;
      --if (child.parent != self || index < 0 || index >= l) { return; }
      --for (var i=0;i<l;i++) {
          --if (kids[i] == child) { break; }
      --}
      --if (i==l || i == index) { return; }
      --kids.splice(i,1);
      --kids.splice(index,0,child);
  --};

  
  --p.contains = function(child) {
      --while (child) {
          --if (child == self) { return true; }
          --child = child.parent;
      --}
      --return false;
  --};

  
  --p.hitTest = function(x, y) {
      
      --return (self.getObjectUnderPoint(x, y) != nil);
  --};

  
  --p.getObjectsUnderPoint = function(x, y) {
      --var arr = [];
      --var pt = self.localToGlobal(x, y);
      --self._getObjectsUnderPoint(pt.x, pt.y, arr);
      --return arr;
  --};

  
  --p.getObjectUnderPoint = function(x, y) {
      --var pt = self.localToGlobal(x, y);
      --return self._getObjectsUnderPoint(pt.x, pt.y);
  --};
  
  
  --p.DisplayObject_getBounds = p.getBounds; 
  
  
  --p.getBounds = function() {
      --return self._getBounds(nil, true);
  --};
  
  
  
  --p.getTransformedBounds = function() {
      --return self._getBounds();
  --};

  
  --p.clone = function(recursive) {
      --var o = new Container();
      --self.cloneProps(o);
      --if (recursive) {
          --var arr = o.children = [];
          --for (var i=0, l=self.children.length; i<l; i++) {
              --var clone = self.children[i].clone(recursive);
              --clone.parent = o;
              --arr.push(clone);
          --}
      --}
      --return o;
  --};

  
  --p.toString = function() {
      --return "[Container (name="+  self.name +")]";
  --};


  
  self._tick = (props) ->
    if self.tickOnlyWhenVisible and not self.visible
      return false
    if self.tickEnabled and self.tickChildren
      for i=#self.children, 1, -1
        child = self.children[i]
        if child.tickEnabled and child._tick
          child._tick props
      return true
    return false
    --displayObj._tick(props)

  
  --p._getObjectsUnderPoint = function(x, y, arr, mouse, activeListener) {
      --var ctx = createjs.DisplayObject._hitTestContext;
      --var mtx = self._matrix;
      --activeListener = activeListener || (mouse&&self._hasMouseEventListener());

      
      --var children = self.children;
      --var l = children.length;
      --for (var i=l-1; i>=0; i--) {
          --var child = children[i];
          --var hitArea = child.hitArea, mask = child.mask;
          --if (!child.visible || (!hitArea && !child.isVisible()) || (mouse && !child.mouseEnabled)) { continue; }
          --if (!hitArea && mask && mask.graphics && !mask.graphics.isEmpty()) {
              --var maskMtx = mask.getMatrix(mask._matrix).prependMatrix(self.getConcatenatedMatrix(mtx));
              --ctx.setTransform(maskMtx.a,  maskMtx.b, maskMtx.c, maskMtx.d, maskMtx.tx-x, maskMtx.ty-y);
              
              
              --mask.graphics.drawAsPath(ctx);
              --ctx.fillStyle = "#000";
              --ctx.fill();
              
              
              --if (!self._testHit(ctx)) { continue; }
              --ctx.setTransform(1, 0, 0, 1, 0, 0);
              --ctx.clearRect(0, 0, 2, 2);
          --}
          
          
          --if (!hitArea && child instanceof Container) {
              --var result = child._getObjectsUnderPoint(x, y, arr, mouse, activeListener);
              --if (!arr && result) { return (mouse && !self.mouseChildren) ? self : result; }
          --} else {
              --if (mouse && !activeListener && !child._hasMouseEventListener()) { continue; }
              
              --child.getConcatenatedMatrix(mtx);
              
              --if (hitArea) {
                  --mtx.appendTransform(hitArea.x, hitArea.y, hitArea.scaleX, hitArea.scaleY, hitArea.rotation, hitArea.skewX, hitArea.skewY, hitArea.regX, hitArea.regY);
                  --mtx.alpha = hitArea.alpha;
              --}
              
              --ctx.globalAlpha = mtx.alpha;
              --ctx.setTransform(mtx.a,  mtx.b, mtx.c, mtx.d, mtx.tx-x, mtx.ty-y);
              --(hitArea||child).draw(ctx);
              --if (!self._testHit(ctx)) { continue; }
              --ctx.setTransform(1, 0, 0, 1, 0, 0);
              --ctx.clearRect(0, 0, 2, 2);
              --if (arr) { arr.push(child); }
              --else { return (mouse && !self.mouseChildren) ? self : child; }
          --}
      --}
      --return nil;
  --};
  
  
  --p._getBounds = function(matrix, ignoreTransform) {
      --var bounds = self.DisplayObject_getBounds();
      --if (bounds) { return self._transformBounds(bounds, matrix, ignoreTransform); }
      
      --var minX, maxX, minY, maxY;
      --var mtx = ignoreTransform ? self._matrix.identity() : self.getMatrix(self._matrix);
      --if (matrix) { mtx.prependMatrix(matrix); }
      
      --var l = self.children.length;
      --for (var i=0; i<l; i++) {
          --var child = self.children[i];
          --if (!child.visible || !(bounds = child._getBounds(mtx))) { continue; }
          --var x1=bounds.x, y1=bounds.y, x2=x1+bounds.width, y2=y1+bounds.height;
          --if (x1 < minX || minX == nil) { minX = x1; }
          --if (x2 > maxX || maxX == nil) { maxX = x2; }
          --if (y1 < minY || minY == nil) { minY = y1; }
          --if (y2 > maxY || maxY == nil) { maxY = y2; }
      --}
      
      --return (maxX == nil) ? nil : self._rectangle.initialize(minX, minY, maxX-minX, maxY-minY);
  --};

  return self
}

framework.Container = Container
