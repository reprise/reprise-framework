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
		protected var m_startTime : int;
		protected var m_startValue : CSSProperty;
		protected var m_endValue : CSSProperty;
		protected var m_backupValue : CSSProperty;
		protected var m_lastUpdateTime : int;
		
		protected var m_propertyTransition : PropertyTransitionVO;

		
		//----------------------               Public Methods               ----------------------//
		public function CSSPropertyTransition(name : String, shortcut : String = null)
		{
			property = name;
			this.shortcut = shortcut;
			m_propertyTransition = TransitionVOFactory.transitionForPropertyName(name);
		}
		
		public function get startTime() : int
		{
			return m_startTime;
		}
		public function set startTime(startTime : int) : void
		{
			m_startTime = m_lastUpdateTime = startTime;
		}
		
		public function set startValue(value : CSSProperty) : void
		{
			m_startValue = value;
			currentValue = CSSProperty(value.clone(true));
			m_backupValue = CSSProperty(value.clone(true));
			if (m_endValue)
			{
				currentValue.setIsWeak(m_endValue.isWeak());
				m_backupValue.setIsWeak(m_endValue.isWeak());
			}
			m_propertyTransition.startValue = value.specifiedValue();
			m_propertyTransition.currentValue = currentValue.specifiedValue();
		}
		public function get startValue() : CSSProperty
		{
			return m_startValue;
		}
		
		public function set endValue(value : CSSProperty) : void
		{
			m_endValue = value;
			if (currentValue)
			{
				currentValue.setIsWeak(m_endValue.isWeak());
				m_backupValue.setIsWeak(m_endValue.isWeak());
			}
			m_propertyTransition.endValue = value.specifiedValue();
		}
		public function get endValue() : CSSProperty
		{
			return m_endValue;
		}
		
		public function updateValues(endValue : CSSProperty, 
			duration : CSSProperty, delay : CSSProperty, 
			startTime : int, frameDuration : int, context : Object) : void
		{
			var oldStart : CSSProperty = this.startValue;
			var oldEnd : CSSProperty = this.endValue;
			var oldCurrent : CSSProperty = this.currentValue;
			var oldStartTime : int = m_startTime;
			if (startTime - m_lastUpdateTime > frameDuration)
			{
				oldStartTime += startTime - m_lastUpdateTime - frameDuration;
			}
			
			this.endValue = endValue;
			this.duration = duration;
			this.delay = delay;
			m_startTime = m_lastUpdateTime = startTime;
			
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
				this.m_startTime -= timeOffset + (delay ? delay.specifiedValue() : 0);
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
						this.m_startTime -= spentDelay;
					}
					else
					{
						this.m_startTime -= delayValue;
					}
					this.m_startTime -=  spentDelay - delayValue;
				}
				else
				{
					//already moving, don't delay any further
					this.m_startTime -= delay ? delay.specifiedValue() : 0;
				}
			}
		}
		
		public function setValueForTimeInContext(
			time : int, frameDuration : int, context : Object) : void
		{
			var durationValue : int = duration.valueOf() as int;
			var delayValue : int = delay ? delay.specifiedValue() : 0;
			if (time - m_lastUpdateTime > frameDuration)
			{
				m_startTime += time - m_lastUpdateTime - frameDuration;
			}
			m_lastUpdateTime = time;
			var currentTime : int = time - m_startTime - delayValue;
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
			currentValue = m_backupValue;
			m_backupValue = backup;
			currentValue.setSpecifiedValue(
				m_propertyTransition.setCurrentValueToRatio(currentRatio));
		}
	}
}