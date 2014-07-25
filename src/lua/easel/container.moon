
local Container
Container = {
new: maker ()=>
  @children = {}
  @mouseChildren = true
  @tickChildren = true

  displayObj = framework.DisplayObject.new!
  setmetatable(@, {__index:displayObj})

  @isVisible = ->
    hasContent = @cacheCanvas or #@children>0
    return not not (@visible and @alpha > 0 and @scaleX ~= 0 and @scaleY ~= 0 and hasContent)

  @draw = (ctx, ignoreCache)->
    --if displayObj.draw(ctx, ignoreCache)
      --return true
  
    --print 'Container draw, count:', #@children

    for i=1, #@children
      child = @children[i]
      if not child.isVisible()
        continue
      
      --ctx.save!
      --child.updateContext ctx
      child.draw ctx
      --ctx.restore!
    return true
  
  
  @addChild = (...)->
    arguments = {...}
    child = arguments[1]
    if child == nil
      return child
    l = #arguments
    if l > 1
      for i=1,l
        @.addChild arguments[i]
      return arguments[l-1]
    
    if child.parent
      child.parent.removeChild child
    child.parent = @
    _.push @children, child
    return child

  
  @addChildAt = (...)->
    arguments = {...}
    child = arguments[1]
    index = arguments[2]
    l = #arguments
    indx = arguments[l]
    if indx < 1 or indx > #@children+1
      return arguments[l-1]
    if l > 2
      for i=1,l-1
        @.addChildAt(arguments[i], indx+i)
      return arguments[l-1]
    if child.parent
      child.parent.removeChild(child)
    child.parent = @
    table.insert @children, index, child
    return child

  
  @removeChild = (...)->
    arguments = {...}
    child = arguments[1]
    l = #arguments
    if l > 1
      good = true
      for i=1,l
        good = good and @.removeChild(arguments[i])
      return good
    return @.removeChildAt(_.indexOf(@children, child))

  
  @removeChildAt = (...)->
    arguments = {...}
    index = arguments[1]
    l = #arguments
    if l > 1
      a = {}
      for i=1,l
        a[i] = arguments[i]
      table.sort(a, (a, b)->b-a>0)
      good = true
      for i=1,l
        good = good and @.removeChildAt(a[i])
      return good
    
    if index < 1 or index > #@children
      return false
    child = @children[index]
    if child
      child.parent = nil
    table.remove(@children, index)
    return true

  
  --p.removeAllChildren = function() {
      --var kids = @children;
      --while (kids.length) { kids.pop().parent = nil; }
  --};

  
  --p.getChildAt = function(index) {
      --return @children[index];
  --};
  
  
  --p.getChildByName = function(name) {
      --var kids = @children;
      --for (var i=0,l=kids.length;i<l;i++) {
          --if(kids[i].name == name) { return kids[i]; }
      --}
      --return nil;
  --};

  
  --p.sortChildren = function(sortFunction) {
      --@children.sort(sortFunction);
  --};

  
  --p.getChildIndex = function(child) {
      --return createjs.indexOf(@children, child);
  --};

  
  --p.getNumChildren = function() {
      --return @children.length;
  --};
  
  
  --p.swapChildrenAt = function(index1, index2) {
      --var kids = @children;
      --var o1 = kids[index1];
      --var o2 = kids[index2];
      --if (!o1 || !o2) { return; }
      --kids[index1] = o2;
      --kids[index2] = o1;
  --};
  
  
  --p.swapChildren = function(child1, child2) {
      --var kids = @children;
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
      --var kids = @children, l=kids.length;
      --if (child.parent != this || index < 0 || index >= l) { return; }
      --for (var i=0;i<l;i++) {
          --if (kids[i] == child) { break; }
      --}
      --if (i==l || i == index) { return; }
      --kids.splice(i,1);
      --kids.splice(index,0,child);
  --};

  
  --p.contains = function(child) {
      --while (child) {
          --if (child == this) { return true; }
          --child = child.parent;
      --}
      --return false;
  --};

  
  --p.hitTest = function(x, y) {
      
      --return (@.getObjectUnderPoint(x, y) != nil);
  --};

  
  --p.getObjectsUnderPoint = function(x, y) {
      --var arr = [];
      --var pt = @.localToGlobal(x, y);
      --@._getObjectsUnderPoint(pt.x, pt.y, arr);
      --return arr;
  --};

  
  --p.getObjectUnderPoint = function(x, y) {
      --var pt = @.localToGlobal(x, y);
      --return @._getObjectsUnderPoint(pt.x, pt.y);
  --};
  
  
  --p.DisplayObject_getBounds = p.getBounds; 
  
  
  --p.getBounds = function() {
      --return @._getBounds(nil, true);
  --};
  
  
  
  --p.getTransformedBounds = function() {
      --return @._getBounds();
  --};

  
  --p.clone = function(recursive) {
      --var o = new Container();
      --@.cloneProps(o);
      --if (recursive) {
          --var arr = o.children = [];
          --for (var i=0, l=@children.length; i<l; i++) {
              --var clone = @children[i].clone(recursive);
              --clone.parent = o;
              --arr.push(clone);
          --}
      --}
      --return o;
  --};

  
  --p.toString = function() {
      --return "[Container (name="+  @name +")]";
  --};


  
  @_tick = (props) ->
    if @tickChildren
      for i=#@children, 1, -1
        child = @children[i]
        if child.tickEnabled and child._tick
          child._tick props
    --displayObj._tick(props)

  
  --p._getObjectsUnderPoint = function(x, y, arr, mouse, activeListener) {
      --var ctx = createjs.DisplayObject._hitTestContext;
      --var mtx = @_matrix;
      --activeListener = activeListener || (mouse&&@._hasMouseEventListener());

      
      --var children = @children;
      --var l = children.length;
      --for (var i=l-1; i>=0; i--) {
          --var child = children[i];
          --var hitArea = child.hitArea, mask = child.mask;
          --if (!child.visible || (!hitArea && !child.isVisible()) || (mouse && !child.mouseEnabled)) { continue; }
          --if (!hitArea && mask && mask.graphics && !mask.graphics.isEmpty()) {
              --var maskMtx = mask.getMatrix(mask._matrix).prependMatrix(@.getConcatenatedMatrix(mtx));
              --ctx.setTransform(maskMtx.a,  maskMtx.b, maskMtx.c, maskMtx.d, maskMtx.tx-x, maskMtx.ty-y);
              
              
              --mask.graphics.drawAsPath(ctx);
              --ctx.fillStyle = "#000";
              --ctx.fill();
              
              
              --if (!@._testHit(ctx)) { continue; }
              --ctx.setTransform(1, 0, 0, 1, 0, 0);
              --ctx.clearRect(0, 0, 2, 2);
          --}
          
          
          --if (!hitArea && child instanceof Container) {
              --var result = child._getObjectsUnderPoint(x, y, arr, mouse, activeListener);
              --if (!arr && result) { return (mouse && !@mouseChildren) ? this : result; }
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
              --if (!@._testHit(ctx)) { continue; }
              --ctx.setTransform(1, 0, 0, 1, 0, 0);
              --ctx.clearRect(0, 0, 2, 2);
              --if (arr) { arr.push(child); }
              --else { return (mouse && !@mouseChildren) ? this : child; }
          --}
      --}
      --return nil;
  --};
  
  
  --p._getBounds = function(matrix, ignoreTransform) {
      --var bounds = @.DisplayObject_getBounds();
      --if (bounds) { return @._transformBounds(bounds, matrix, ignoreTransform); }
      
      --var minX, maxX, minY, maxY;
      --var mtx = ignoreTransform ? @_matrix.identity() : @.getMatrix(@_matrix);
      --if (matrix) { mtx.prependMatrix(matrix); }
      
      --var l = @children.length;
      --for (var i=0; i<l; i++) {
          --var child = @children[i];
          --if (!child.visible || !(bounds = child._getBounds(mtx))) { continue; }
          --var x1=bounds.x, y1=bounds.y, x2=x1+bounds.width, y2=y1+bounds.height;
          --if (x1 < minX || minX == nil) { minX = x1; }
          --if (x2 > maxX || maxX == nil) { maxX = x2; }
          --if (y1 < minY || minY == nil) { minY = y1; }
          --if (y2 > maxY || maxY == nil) { maxY = y2; }
      --}
      
      --return (maxX == nil) ? nil : @_rectangle.initialize(minX, minY, maxX-minX, maxY-minY);
  --};

}

framework.Container = Container
