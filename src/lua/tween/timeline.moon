
local Timeline
Timeline = {

new: maker (tweens, labels, props) =>


--var Timeline = function(tweens, labels, props) {
  --this.initialize(tweens, labels, props);
--};
--var p = Timeline.prototype = new createjs.EventDispatcher();
	
	--p.ignoreGlobalPause = false;

	
	--p.duration = 0;

	
	--p.loop = false;

	
	

	
	--p.position = null;


	



	
	--p._paused = false;

	
	--p._tweens = null;

	
	--p._labels = null;
	
	
	--p._labelList = null;

	
	--p._prevPosition = 0;

	
	--p._prevPos = -1;

	
	--p._useTicks = false;


	
	--p.initialize = function(tweens, labels, props) {
		--this._tweens = [];
		--if (props) {
			--this._useTicks = props.useTicks;
			--this.loop = props.loop;
			--this.ignoreGlobalPause = props.ignoreGlobalPause;
			--props.onChange&&this.addEventListener("change", props.onChange);
		--}
		--if (tweens) { this.addTween.apply(this, tweens); }
		--this.setLabels(labels);
		--if (props&&props.paused) { this._paused=true; }
		--else { createjs.Tween._register(this,true); }
		--if (props&&props.position!=null) { this.setPosition(props.position, createjs.Tween.NONE); }
	--};


	
	--p.addTween = function(tween) {
		--var l = arguments.length;
		--if (l > 1) {
			--for (var i=0; i<l; i++) { this.addTween(arguments[i]); }
			--return arguments[0];
		--} else if (l == 0) { return null; }
		--this.removeTween(tween);
		--this._tweens.push(tween);
		--tween.setPaused(true);
		--tween._paused = false;
		--tween._useTicks = this._useTicks;
		--if (tween.duration > this.duration) { this.duration = tween.duration; }
		--if (this._prevPos >= 0) { tween.setPosition(this._prevPos, createjs.Tween.NONE); }
		--return tween;
	--};

	
	--p.removeTween = function(tween) {
		--var l = arguments.length;
		--if (l > 1) {
			--var good = true;
			--for (var i=0; i<l; i++) { good = good && this.removeTween(arguments[i]); }
			--return good;
		--} else if (l == 0) { return false; }

		--var tweens = this._tweens;
		--var i = tweens.length;
		--while (i--) {
			--if (tweens[i] == tween) {
				--tweens.splice(i, 1);
				--if (tween.duration >= this.duration) { this.updateDuration(); }
				--return true;
			--}
		--}
		--return false;
	--};

	
	--p.addLabel = function(label, position) {
		--this._labels[label] = position;
		--var list = this._labelList;
		--if (list) {
			--for (var i= 0,l=list.length; i<l; i++) { if (position < list[i].position) { break; } }
			--list.splice(i, 0, {label:label, position:position});
		--}
	--};

	
	--p.setLabels = function(o) {
		--this._labels = o ?  o : {};
	--};
	
	
	--p.getLabels = function() {
		--var list = this._labelList;
		--if (!list) {
			--list = this._labelList = [];
			--var labels = this._labels;
			--for (var n in labels) {
				--list.push({label:n, position:labels[n]});
			--}
			--list.sort(function (a,b) { return a.position- b.position; });
		--}
		--return list;
	--};
	
	
	--p.getCurrentLabel = function() {
		--var labels = this.getLabels();
		--var pos = this.position;
		--var l = labels.length;
		--if (l) {
			--for (var i = 0; i<l; i++) { if (pos < labels[i].position) { break; } }
			--return (i==0) ? null : labels[i-1].label;
		--}
		--return null;
	--};
	
	
	--p.gotoAndPlay = function(positionOrLabel) {
		--this.setPaused(false);
		--this._goto(positionOrLabel);
	--};

	
	--p.gotoAndStop = function(positionOrLabel) {
		--this.setPaused(true);
		--this._goto(positionOrLabel);
	--};

	
	--p.setPosition = function(value, actionsMode) {
		--if (value < 0) { value = 0; }
		--var t = this.loop ? value%this.duration : value;
		--var end = !this.loop && value >= this.duration;
		--if (t == this._prevPos) { return end; }
		--this._prevPosition = value;
		--this.position = this._prevPos = t; 
		--for (var i=0, l=this._tweens.length; i<l; i++) {
			--this._tweens[i].setPosition(t, actionsMode);
			--if (t != this._prevPos) { return false; } 
		--}
		--if (end) { this.setPaused(true); }
		--this.dispatchEvent("change");
		--return end;
	--};

	
	--p.setPaused = function(value) {
		--this._paused = !!value;
		--createjs.Tween._register(this, !value);
	--};

	
	--p.updateDuration = function() {
		--this.duration = 0;
		--for (var i=0,l=this._tweens.length; i<l; i++) {
			--var tween = this._tweens[i];
			--if (tween.duration > this.duration) { this.duration = tween.duration; }
		--}
	--};

	
	--p.tick = function(delta) {
		--this.setPosition(this._prevPosition+delta);
	--};

	
	--p.resolve = function(positionOrLabel) {
		--var pos = parseFloat(positionOrLabel);
		--if (isNaN(pos)) { pos = this._labels[positionOrLabel]; }
		--return pos;
	--};

	
	--p.toString = function() {
		--return "[Timeline]";
	--};

	
	--p.clone = function() {
		--throw("Timeline can not be cloned.")
	--};


	
	--p._goto = function(positionOrLabel) {
		--var pos = this.resolve(positionOrLabel);
		--if (pos != null) { this.setPosition(pos); }
	--};

}
framework.Timeline = Timeline
