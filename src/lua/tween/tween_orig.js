
// public methods:
	/**
	 * Queues a wait (essentially an empty tween).
	 * @example
	 *	//This tween will wait 1s before alpha is faded to 0.
	 *	createjs.Tween.get(target).wait(1000).to({alpha:0}, 1000);
	 * @method wait
	 * @param {Number} duration The duration of the wait in milliseconds (or in ticks if <code>useTicks</code> is true).
	 * @param {Boolean} passive Tween properties will not be updated during a passive wait. This
	 * is mostly useful for use with Timeline's that contain multiple tweens affecting the same target
	 * at different times.
	 * @return {Tween} This tween instance (for chaining calls).
	 **/
	p.wait = function(duration, passive) {
		if (duration == null || duration <= 0) { return this; }
		var o = this._cloneProps(this._curQueueProps);
		return this._addStep({d:duration, p0:o, e:this._linearEase, p1:o, v:passive});
	};

	/**
	 * Queues a tween from the current values to the target properties. Set duration to 0 to jump to these value.
	 * Numeric properties will be tweened from their current value in the tween to the target value. Non-numeric
	 * properties will be set at the end of the specified duration.
	 * @example
	 *	createjs.Tween.get(target).to({alpha:0}, 1000);
	 * @method to
	 * @param {Object} props An object specifying property target values for this tween (Ex. <code>{x:300}</code> would tween the x
	 *      property of the target to 300).
	 * @param {Number} duration Optional. The duration of the wait in milliseconds (or in ticks if <code>useTicks</code> is true).
	 *      Defaults to 0.
	 * @param {Function} ease Optional. The easing function to use for this tween. Defaults to a linear ease.
	 * @return {Tween} This tween instance (for chaining calls).
	 */
	p.to = function(props, duration, ease) {
		if (isNaN(duration) || duration < 0) { duration = 0; }
		return this._addStep({d:duration||0, p0:this._cloneProps(this._curQueueProps), e:ease, p1:this._cloneProps(this._appendQueueProps(props))});
	};

	/**
	 * Queues an action to call the specified function.
	 *	@example
	 *   	//would call myFunction() after 1s.
	 *   	myTween.wait(1000).call(myFunction);
	 * @method call
	 * @param {Function} callback The function to call.
	 * @param {Array} params Optional. The parameters to call the function with. If this is omitted, then the function
	 *      will be called with a single param pointing to this tween.
	 * @param {Object} scope Optional. The scope to call the function in. If omitted, it will be called in the target's
	 *      scope.
	 * @return {Tween} This tween instance (for chaining calls).
	 */
	p.call = function(callback, params, scope) {
		return this._addAction({f:callback, p:params ? params : [this], o:scope ? scope : this._target});
	};

	// TODO: add clarification between this and a 0 duration .to:
	/**
	 * Queues an action to set the specified props on the specified target. If target is null, it will use this tween's
	 * target.
	 * @example
	 *	myTween.wait(1000).set({visible:false},foo);
	 * @method set
	 * @param {Object} props The properties to set (ex. <code>{visible:false}</code>).
	 * @param {Object} target Optional. The target to set the properties on. If omitted, they will be set on the tween's target.
	 * @return {Tween} This tween instance (for chaining calls).
	 */
	p.set = function(props, target) {
		return this._addAction({f:this._set, o:this, p:[props, target ? target : this._target]});
	};

	/**
	 * Queues an action to to play (unpause) the specified tween. This enables you to sequence multiple tweens.
	 * @example
	 *	myTween.to({x:100},500).play(otherTween);
	 * @method play
	 * @param {Tween} tween The tween to play.
	 * @return {Tween} This tween instance (for chaining calls).
	 */
	p.play = function(tween) {
		if (!tween) { tween = this; }
		return this.call(tween.setPaused, [false], tween);
	};

	/**
	 * Queues an action to to pause the specified tween.
	 * @method pause
	 * @param {Tween} tween The tween to play. If null, it pauses this tween.
	 * @return {Tween} This tween instance (for chaining calls)
	 */
	p.pause = function(tween) {
		if (!tween) { tween = this; }
		return this.call(tween.setPaused, [true], tween);
	};

	p.setPaused = function(value) {
		if (this._paused === !!value) { return this; }
		this._paused = !!value;
		Tween._register(this, !value);
		return this;
	};

	// tiny api (primarily for tool output):
	p.w = p.wait;
	p.t = p.to;
	p.c = p.call;
	p.s = p.set;

	/**
	 * Returns a string representation of this object.
	 * @method toString
	 * @return {String} a string representation of the instance.
	 */
	p.toString = function() {
		return "[Tween]";
	};

	/**
	 * @method clone
	 * @protected
	 */
	p.clone = function() {
		throw("Tween can not be cloned.")
	};

// private methods:
	/**
	 * @method _updateTargetProps
	 * @param {Object} step
	 * @param {Number} ratio
	 * @protected
	 */
	p._updateTargetProps = function(step, ratio) {
		var p0,p1,v,v0,v1,arr;
		if (!step && ratio == 1) {
			// GDS: when does this run? Just at the very end? Shouldn't.
			this.passive = false;
			p0 = p1 = this._curQueueProps;
		} else {
			this.passive = !!step.v;
			if (this.passive) { return; } // don't update props.
			// apply ease to ratio.
			if (step.e) { ratio = step.e(ratio,0,1,1); }
			p0 = step.p0;
			p1 = step.p1;
		}

		for (var n in this._initQueueProps) {
			if ((v0 = p0[n]) == null) { p0[n] = v0 = this._initQueueProps[n]; }
			if ((v1 = p1[n]) == null) { p1[n] = v1 = v0; }
			if (v0 == v1 || ratio == 0 || ratio == 1 || (typeof(v0) != "number")) {
				// no interpolation - either at start, end, values don't change, or the value is non-numeric.
				v = ratio == 1 ? v1 : v0;
			} else {
				v = v0+(v1-v0)*ratio;
			}

			var ignore = false;
			if (arr = Tween._plugins[n]) {
				for (var i=0,l=arr.length;i<l;i++) {
					var v2 = arr[i].tween(this, n, v, p0, p1, ratio, !!step&&p0==p1, !step);
					if (v2 == Tween.IGNORE) { ignore = true; }
					else { v = v2; }
				}
			}
			if (!ignore) { this._target[n] = v; }
		}

	};

	/**
	 * @method _runActions
	 * @param {Number} startPos
	 * @param {Number} endPos
	 * @param {Boolean} includeStart
	 * @protected
	 */
	p._runActions = function(startPos, endPos, includeStart) {
		var sPos = startPos;
		var ePos = endPos;
		var i = -1;
		var j = this._actions.length;
		var k = 1;
		if (startPos > endPos) {
			// running backwards, flip everything:
			sPos = endPos;
			ePos = startPos;
			i = j;
			j = k = -1;
		}
		while ((i+=k) != j) {
			var action = this._actions[i];
			var pos = action.t;
			if (pos == ePos || (pos > sPos && pos < ePos) || (includeStart && pos == startPos) ) {
				action.f.apply(action.o, action.p);
			}
		}
	};

	/**
	 * @method _appendQueueProps
	 * @param {Object} o
	 * @protected
	 */
	p._appendQueueProps = function(o) {
		var arr,oldValue,i, l, injectProps;
		for (var n in o) {
			if (this._initQueueProps[n] === undefined) {
				oldValue = this._target[n];

				// init plugins:
				if (arr = Tween._plugins[n]) {
					for (i=0,l=arr.length;i<l;i++) {
						oldValue = arr[i].init(this, n, oldValue);
					}
				}
				this._initQueueProps[n] = this._curQueueProps[n] = (oldValue===undefined) ? null : oldValue;
			} else {
				oldValue = this._curQueueProps[n];
			}
		}

		for (var n in o) {
			oldValue = this._curQueueProps[n];
			if (arr = Tween._plugins[n]) {
				injectProps = injectProps||{};
				for (i=0, l=arr.length;i<l;i++) {
					// TODO: remove the check for .step in the next version. It's here for backwards compatibility.
					if (arr[i].step) { arr[i].step(this, n, oldValue, o[n], injectProps); }
				}
			}
			this._curQueueProps[n] = o[n];
		}
		if (injectProps) { this._appendQueueProps(injectProps); }
		return this._curQueueProps;
	};

	/**
	 * @method _cloneProps
	 * @param {Object} props
	 * @protected
	 */
	p._cloneProps = function(props) {
		var o = {};
		for (var n in props) {
			o[n] = props[n];
		}
		return o;
	};

	/**
	 * @method _addStep
	 * @param {Object} o
	 * @protected
	 */
	p._addStep = function(o) {
		if (o.d > 0) {
			this._steps.push(o);
			o.t = this.duration;
			this.duration += o.d;
		}
		return this;
	};

	/**
	 * @method _addAction
	 * @param {Object} o
	 * @protected
	 */
	p._addAction = function(o) {
		o.t = this.duration;
		this._actions.push(o);
		return this;
	};

	/**
	 * @method _set
	 * @param {Object} props
	 * @param {Object} o
	 * @protected
	 */
	p._set = function(props, o) {
		for (var n in props) {
			o[n] = props[n];
		}
	};

	/**
	 * Installs a plugin, which can modify how certain properties are handled when tweened. See the CSSPlugin for an
	 * example of how to write TweenJS plugins.
	 * @method installPlugin
	 * @static
	 * @param {Object} plugin The plugin class to install
	 * @param {Array} properties An array of properties that the plugin will handle.
	 */
	Tween.installPlugin = function(plugin, properties) {
		var priority = plugin.priority;
		if (priority == null) { plugin.priority = priority = 0; }
		for (var i=0,l=properties.length,p=Tween._plugins;i<l;i++) {
			var n = properties[i];
			if (!p[n]) { p[n] = [plugin]; }
			else {
				var arr = p[n];
				for (var j=0,jl=arr.length;j<jl;j++) {
					if (priority < arr[j].priority) { break; }
				}
				p[n].splice(j,0,plugin);
			}
		}
	};

	/**
	 * Registers or unregisters a tween with the ticking system.
	 * @method _register
	 * @param {Tween} tween The tween instance to register or unregister.
	 * @param {Boolean} value If true, the tween is registered. If false the tween is unregistered. 
	 * @static
	 * @protected
	 */

