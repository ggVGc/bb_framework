
local Container
Container = {
new: maker ()=>

  --p.children = null;
  
  
  --p.mouseChildren = true;
  
  
  --p.tickChildren = true;

  --p.DisplayObject_initialize = p.initialize;
  
  --p.initialize = function() {
      --this.DisplayObject_initialize();
      --this.children = [];
  --};



  
  --p.isVisible = function() {
      --var hasContent = this.cacheCanvas || this.children.length;
      --return !!(this.visible && this.alpha > 0 && this.scaleX != 0 && this.scaleY != 0 && hasContent);
  --};

  
  --p.DisplayObject_draw = p.draw;

  
  --p.draw = function(ctx, ignoreCache) {
      --if (this.DisplayObject_draw(ctx, ignoreCache)) { return true; }
      
      --var list = this.children.slice(0);
      --for (var i=0,l=list.length; i<l; i++) {
          --var child = list[i];
          --if (!child.isVisible()) { continue; }
          
          
          --ctx.save();
          --child.updateContext(ctx);
          --child.draw(ctx);
          --ctx.restore();
      --}
      --return true;
  --};
  
  
  --p.addChild = function(child) {
      --if (child == null) { return child; }
      --var l = arguments.length;
      --if (l > 1) {
          --for (var i=0; i<l; i++) { this.addChild(arguments[i]); }
          --return arguments[l-1];
      --}
      --if (child.parent) { child.parent.removeChild(child); }
      --child.parent = this;
      --this.children.push(child);
      --return child;
  --};

  
  --p.addChildAt = function(child, index) {
      --var l = arguments.length;
      --var indx = arguments[l-1]; 
      --if (indx < 0 || indx > this.children.length) { return arguments[l-2]; }
      --if (l > 2) {
          --for (var i=0; i<l-1; i++) { this.addChildAt(arguments[i], indx+i); }
          --return arguments[l-2];
      --}
      --if (child.parent) { child.parent.removeChild(child); }
      --child.parent = this;
      --this.children.splice(index, 0, child);
      --return child;
  --};

  
  --p.removeChild = function(child) {
      --var l = arguments.length;
      --if (l > 1) {
          --var good = true;
          --for (var i=0; i<l; i++) { good = good && this.removeChild(arguments[i]); }
          --return good;
      --}
      --return this.removeChildAt(createjs.indexOf(this.children, child));
  --};

  
  --p.removeChildAt = function(index) {
      --var l = arguments.length;
      --if (l > 1) {
          --var a = [];
          --for (var i=0; i<l; i++) { a[i] = arguments[i]; }
          --a.sort(function(a, b) { return b-a; });
          --var good = true;
          --for (var i=0; i<l; i++) { good = good && this.removeChildAt(a[i]); }
          --return good;
      --}
      --if (index < 0 || index > this.children.length-1) { return false; }
      --var child = this.children[index];
      --if (child) { child.parent = null; }
      --this.children.splice(index, 1);
      --return true;
  --};

  
  --p.removeAllChildren = function() {
      --var kids = this.children;
      --while (kids.length) { kids.pop().parent = null; }
  --};

  
  --p.getChildAt = function(index) {
      --return this.children[index];
  --};
  
  
  --p.getChildByName = function(name) {
      --var kids = this.children;
      --for (var i=0,l=kids.length;i<l;i++) {
          --if(kids[i].name == name) { return kids[i]; }
      --}
      --return null;
  --};

  
  --p.sortChildren = function(sortFunction) {
      --this.children.sort(sortFunction);
  --};

  
  --p.getChildIndex = function(child) {
      --return createjs.indexOf(this.children, child);
  --};

  
  --p.getNumChildren = function() {
      --return this.children.length;
  --};
  
  
  --p.swapChildrenAt = function(index1, index2) {
      --var kids = this.children;
      --var o1 = kids[index1];
      --var o2 = kids[index2];
      --if (!o1 || !o2) { return; }
      --kids[index1] = o2;
      --kids[index2] = o1;
  --};
  
  
  --p.swapChildren = function(child1, child2) {
      --var kids = this.children;
      --var index1,index2;
      --for (var i=0,l=kids.length;i<l;i++) {
          --if (kids[i] == child1) { index1 = i; }
          --if (kids[i] == child2) { index2 = i; }
          --if (index1 != null && index2 != null) { break; }
      --}
      --if (i==l) { return; } 
      --kids[index1] = child2;
      --kids[index2] = child1;
  --};
  
  
  --p.setChildIndex = function(child, index) {
      --var kids = this.children, l=kids.length;
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
      
      --return (this.getObjectUnderPoint(x, y) != null);
  --};

  
  --p.getObjectsUnderPoint = function(x, y) {
      --var arr = [];
      --var pt = this.localToGlobal(x, y);
      --this._getObjectsUnderPoint(pt.x, pt.y, arr);
      --return arr;
  --};

  
  --p.getObjectUnderPoint = function(x, y) {
      --var pt = this.localToGlobal(x, y);
      --return this._getObjectsUnderPoint(pt.x, pt.y);
  --};
  
  
  --p.DisplayObject_getBounds = p.getBounds; 
  
  
  --p.getBounds = function() {
      --return this._getBounds(null, true);
  --};
  
  
  
  --p.getTransformedBounds = function() {
      --return this._getBounds();
  --};

  
  --p.clone = function(recursive) {
      --var o = new Container();
      --this.cloneProps(o);
      --if (recursive) {
          --var arr = o.children = [];
          --for (var i=0, l=this.children.length; i<l; i++) {
              --var clone = this.children[i].clone(recursive);
              --clone.parent = o;
              --arr.push(clone);
          --}
      --}
      --return o;
  --};

  
  --p.toString = function() {
      --return "[Container (name="+  this.name +")]";
  --};


  
  --p.DisplayObject__tick = p._tick;
  
  
  --p._tick = function(props) {
      --if (this.tickChildren) {
          --for (var i=this.children.length-1; i>=0; i--) {
              --var child = this.children[i];
              --if (child.tickEnabled && child._tick) { child._tick(props); }
          --}
      --}
      --this.DisplayObject__tick(props);
  --};

  
  --p._getObjectsUnderPoint = function(x, y, arr, mouse, activeListener) {
      --var ctx = createjs.DisplayObject._hitTestContext;
      --var mtx = this._matrix;
      --activeListener = activeListener || (mouse&&this._hasMouseEventListener());

      
      --var children = this.children;
      --var l = children.length;
      --for (var i=l-1; i>=0; i--) {
          --var child = children[i];
          --var hitArea = child.hitArea, mask = child.mask;
          --if (!child.visible || (!hitArea && !child.isVisible()) || (mouse && !child.mouseEnabled)) { continue; }
          --if (!hitArea && mask && mask.graphics && !mask.graphics.isEmpty()) {
              --var maskMtx = mask.getMatrix(mask._matrix).prependMatrix(this.getConcatenatedMatrix(mtx));
              --ctx.setTransform(maskMtx.a,  maskMtx.b, maskMtx.c, maskMtx.d, maskMtx.tx-x, maskMtx.ty-y);
              
              
              --mask.graphics.drawAsPath(ctx);
              --ctx.fillStyle = "#000";
              --ctx.fill();
              
              
              --if (!this._testHit(ctx)) { continue; }
              --ctx.setTransform(1, 0, 0, 1, 0, 0);
              --ctx.clearRect(0, 0, 2, 2);
          --}
          
          
          --if (!hitArea && child instanceof Container) {
              --var result = child._getObjectsUnderPoint(x, y, arr, mouse, activeListener);
              --if (!arr && result) { return (mouse && !this.mouseChildren) ? this : result; }
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
              --if (!this._testHit(ctx)) { continue; }
              --ctx.setTransform(1, 0, 0, 1, 0, 0);
              --ctx.clearRect(0, 0, 2, 2);
              --if (arr) { arr.push(child); }
              --else { return (mouse && !this.mouseChildren) ? this : child; }
          --}
      --}
      --return null;
  --};
  
  
  --p._getBounds = function(matrix, ignoreTransform) {
      --var bounds = this.DisplayObject_getBounds();
      --if (bounds) { return this._transformBounds(bounds, matrix, ignoreTransform); }
      
      --var minX, maxX, minY, maxY;
      --var mtx = ignoreTransform ? this._matrix.identity() : this.getMatrix(this._matrix);
      --if (matrix) { mtx.prependMatrix(matrix); }
      
      --var l = this.children.length;
      --for (var i=0; i<l; i++) {
          --var child = this.children[i];
          --if (!child.visible || !(bounds = child._getBounds(mtx))) { continue; }
          --var x1=bounds.x, y1=bounds.y, x2=x1+bounds.width, y2=y1+bounds.height;
          --if (x1 < minX || minX == null) { minX = x1; }
          --if (x2 > maxX || maxX == null) { maxX = x2; }
          --if (y1 < minY || minY == null) { minY = y1; }
          --if (y2 > maxY || maxY == null) { maxY = y2; }
      --}
      
      --return (maxX == null) ? null : this._rectangle.initialize(minX, minY, maxX-minX, maxY-minY);
  --};

}

framework.Container = Container
