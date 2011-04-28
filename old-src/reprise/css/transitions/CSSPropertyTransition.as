/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.transitions
{
	import reprise.core.reprise;
	import reprise.css.CSSProperty;
	
	import flash.utils.getTimer;
	
	use namespace reprise;
	
	public class CSSPropertyTransition
	{
		//----------------------             Public Properties              ----------------------//
		public var property : String;
		public var shortcut : String;
		public var duration : CSSProperty;
		public var delay : CSSProperty;
		public var easing : Function;
		
		public var currentValue : CSSProperty;
		public var currentRatio : Number = 0;
		
		public var hasCompleted : Boolean;
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _startTime : int;
		protected var _startValue : CSSProperty;
		protected var _endValue : CSSProperty;
		protected var _backupValue : CSSProperty;
		protected var _lastUpdateTime : int;
		
		protected var _propertyTransition : PropertyTransitionVO;

		
		//----------------------               Public Methods               ----------------------//
		public function CSSPropertyTransition(name : String, shortcut : String = null)
		{
			property = name;
			this.shortcut = shortcut;
			_propertyTransition = TransitionVOFactory.transitionForPropertyName(name);
		}
		
		public function get startTime() : int
		{
			return _startTime;
		}
		public function set startTime(startTime : int) : void
		{
			_startTime = _lastUpdateTime = startTime;
		}
		
		public function set startValue(value : CSSProperty) : void
		{
			_startValue = value;
			currentValue = CSSProperty(value.clone(true));
			_backupValue = CSSProperty(value.clone(true));
			if (_endValue)
			{
				currentValue.setIsWeak(_endValue.isWeak());
				_backupValue.setIsWeak(_endValue.isWeak());
			}
			_propertyTransition.startValue = value.specifiedValue();
			_propertyTransition.currentValue = currentValue.specifiedValue();
		}
		public function get startValue() : CSSProperty
		{
			return _startValue;
		}
		
		public function set endValue(value : CSSProperty) : void
		{
			_endValue = value;
			if (currentValue)
			{
				currentValue.setIsWeak(_endValue.isWeak());
				_backupValue.setIsWeak(_endValue.isWeak());
			}
			_propertyTransition.endValue = value.specifiedValue();
		}
		public function get endValue() : CSSProperty
		{
			return _endValue;
		}
		
		public function updateValues(endValue : CSSProperty, 
			duration : CSSProperty, delay : CSSProperty, 
			startTime : int, frameDuration : int, context : Object) : void
		{
			var oldStart : CSSProperty = this.startValue;
			var oldEnd : CSSProperty = this.endValue;
			var oldCurrent : CSSProperty = this.currentValue;
			var oldStartTime : int = _startTime;
			if (startTime - _lastUpdateTime > frameDuration)
			{
				oldStartTime += startTime - _lastUpdateTime - frameDuration;
			}
			
			this.endValue = endValue;
			this.duration = duration;
			this.delay = delay;
			_startTime = _lastUpdateTime = startTime;
			
			//check if the current transition is just reversed and adjust time if true
			if (oldStart == endValue)
			{
				this.startValue = oldEnd;
				var durationValue : int = duration.valueOf() as int;
				var targetRatio : Number = 1 - currentRatio;
				var timeOffset : int = 0;
				var ratio : Number = 0;
				while (ratio < targetRatio)
				{
					timeOffset += 5;
					ratio = easing(timeOffset, 0, 1, durationValue);
				}
				this._startTime -= timeOffset + (delay ? delay.specifiedValue() : 0);
			}
			else
			{
				//let the transition start from the current value without adjusting time
				this.startValue = oldCurrent;
				if (currentRatio == 0)
				{
					//add new delay minus the delay already spent
					var spentDelay : int = getTimer() - oldStartTime;
					var delayValue : int = delay ? delay.specifiedValue() : 0;
					if (delayValue > spentDelay)
					{
						this._startTime -= spentDelay;
					}
					else
					{
						this._startTime -= delayValue;
					}
					this._startTime -=  spentDelay - delayValue;
				}
				else
				{
					//already moving, don't delay any further
					this._startTime -= delay ? delay.specifiedValue() : 0;
				}
			}
		}
		
		public function setValueForTimeInContext(
			time : int, frameDuration : int, context : Object) : void
		{
			var durationValue : int = duration.valueOf() as int;
			var delayValue : int = delay ? delay.specifiedValue() : 0;
			if (time - _lastUpdateTime > frameDuration)
			{
				_startTime += time - _lastUpdateTime - frameDuration;
			}
			_lastUpdateTime = time;
			var currentTime : int = time - _startTime - delayValue;
			if (currentTime < 0)
			{
				return;
			}
			if (durationValue <= currentTime)
			{
				hasCompleted = true;
				currentValue = endValue;
				return;
			}
			currentRatio = easing(currentTime, 0, 1, durationValue);
			//We need to change the currentValue property to be another object on each 
			//validation. If we don't the validation system doesn't know that anything 
			//really changed in the style because it compares object identities
			var backup : CSSProperty = currentValue;
			currentValue = _backupValue;
			_backupValue = backup;
			currentValue.setSpecifiedValue(
				_propertyTransition.setCurrentValueToRatio(currentRatio));
		}
	}
}