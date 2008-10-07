////////////////////////////////////////////////////////////////////////////////
//
//  Fork unstable media GmbH
//  Copyright 2006-2008 Fork unstable media GmbH
//  All Rights Reserved.
//
//  NOTICE: Fork unstable media permits you to use, modify, and distribute this
//  file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package reprise.css.transitions
{
	import reprise.core.reprise;
	import reprise.css.CSSProperty;
	
	import flash.utils.getTimer;
	
	use namespace reprise;
	
	public class CSSPropertyTransition
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public var property : String;
		public var shortcut : String;
		public var duration : CSSProperty;
		public var delay : CSSProperty;
		public var easing : Function;
		
		public var currentValue : CSSProperty;
		public var currentRatio : Number = 0;
		public var startTime : int;
		
		public var hasCompleted : Boolean;
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_startValue : CSSProperty;
		protected var m_endValue : CSSProperty;
		
		protected var m_propertyTransition : PropertyTransitionVO;
		
	
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSPropertyTransition(name : String, shortcut : String = null)
		{
			property = name;
			this.shortcut = shortcut;
			m_propertyTransition = TransitionVOFactory.transitionForPropertyName(name);
		}
		
		public function set startValue(value : CSSProperty) : void
		{
			m_startValue = value;
			currentValue = CSSProperty(value.clone(true));
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
			m_propertyTransition.endValue = value.specifiedValue();
		}
		public function get endValue() : CSSProperty
		{
			return m_endValue;
		}
		
		public function updateValues(endValue : CSSProperty, 
			duration : CSSProperty, delay : CSSProperty, 
			startTime : int, context : Object) : void
		{
			var oldStart : CSSProperty = this.startValue;
			var oldEnd : CSSProperty = this.endValue;
			var oldCurrent : CSSProperty = this.currentValue;
			var oldDelay : CSSProperty = this.delay;
			var oldStartTime : int = this.startTime;
			
			this.endValue = endValue;
			this.duration = duration;
			this.delay = delay;
			this.startTime = startTime;
			
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
				this.startTime -= timeOffset + (delay && delay.specifiedValue()) || 0;
			}
			else
			{
				//let the transition start from the current value without adjusting time
				this.startValue = oldCurrent;
				if (currentRatio == 0)
				{
					//add new delay minus the delay already spent
					var spentDelay : int = getTimer() - oldStartTime;
					var delayValue : int = (delay && delay.specifiedValue()) || 0;
					if (delayValue > spentDelay)
					{
						this.startTime -= spentDelay;
					}
					else
					{
						this.startTime -= delayValue;
					}
					this.startTime -=  spentDelay - delayValue;
				}
				else
				{
					//already moving, don't delay any further
					this.startTime -= (delay && delay.specifiedValue()) || 0;
				}
			}
		}
		
		public function setValueForTimeInContext(time : int, context : Object) : void
		{
			var durationValue : int = duration.valueOf() as int;
			var delayValue : int = (delay && delay.specifiedValue()) || 0;
			var currentTime : int = time - startTime - delayValue;
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
			currentValue.setSpecifiedValue(
				m_propertyTransition.setCurrentValueToRatio(currentRatio));
		}
	}
}