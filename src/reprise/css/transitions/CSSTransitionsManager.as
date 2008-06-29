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
	import com.robertpenner.easing.Linear;
	
	import flash.utils.getTimer;
	
	import reprise.css.CSSDeclaration;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyCache;
	
	public class CSSTransitionsManager
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_activeTransitions : Object;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSTransitionsManager()
		{
		}
		
		public function isActive() : Boolean
		{
			return m_activeTransitions != null;
		}
		
		public function processTransitions(
			oldStyles : CSSDeclaration, newStyles : CSSDeclaration) : CSSDeclaration
		{
			var transitionPropName : String;
			var transition : CSSPropertyTransition;
			var startTime : int = getTimer();
			if (newStyles && newStyles.getStyle('RepriseTransitionProperty'))
			{
				var transitionProperties : Array = 
					newStyles.getStyle('RepriseTransitionProperty').specifiedValue();
				var transitionDurations : Array = 
					newStyles.getStyle('RepriseTransitionDuration').specifiedValue();
				var transitionDelays : Array = 
					newStyles.getStyle('RepriseTransitionDelay').specifiedValue();
				var transitionEasings : Array = newStyles.getStyle(
					'RepriseTransitionTimingFunction').specifiedValue();
				var defaultValues : Array = newStyles.getStyle(
					'RepriseTransitionDefaultValue').specifiedValue();
				
				//remove any transitions that aren't supposed to be active anymore
				if (m_activeTransitions)
				{
					for (transitionPropName in m_activeTransitions)
					{
						if (transitionProperties.indexOf(transitionPropName) == -1)
						{
							delete m_activeTransitions[transitionPropName];
						}
					}
				}
				else
				{
					m_activeTransitions = {};
				}
				
				//add all new properties and update already active ones
				for (var i : int = transitionProperties.length; i--;)
				{
					transitionPropName = transitionProperties[i];
					var oldValue : CSSProperty = (oldStyles && 
						oldStyles.getStyle(transitionPropName)) as CSSProperty;
					var targetValue : CSSProperty = 
						newStyles.getStyle(transitionPropName);
					
					//check for default value if we have a target value but no old value
					if (targetValue && !oldValue && 
						defaultValues[i] && defaultValues[i] != 'none')
					{
						oldValue = CSSProperty(CSSPropertyCache.propertyForKeyValue(
							transitionPropName, defaultValues[i], null));
					}
					
					//exception for intrinsic dimensions
//					if (!targetValue && (transitionPropName == 'intrinsicHeight' || 
//						transitionPropName == 'intrinsicWidth'))
//					{
//						//TODO: cache these properties
//						trace("exception for " + transitionPropName);
//						if (!m_firstDraw)
//						{
//							oldValue = new CSSProperty();
//							oldValue.setSpecifiedValue(0);
//						}
//						targetValue = new CSSProperty();
//						targetValue.setSpecifiedValue(999);
//					}
					
					//ignore properties that don't have previous values or target values
					//TODO: check if we can implement default values for new elements
					if (!oldValue || !targetValue || 
						oldValue.specifiedValue() == targetValue.specifiedValue())
					{
						continue;
					}
					if (transitionEasings[i])
					{ 
						var easing : Function = transitionEasings[i];
					}
					else
					{
						easing = Linear.easeNone;
					}
					transition = m_activeTransitions[transitionPropName];
					if (!transition)
					{
						transition = new CSSPropertyTransition(transitionPropName);
						transition.duration = transitionDurations[i];
						transition.delay = transitionDelays[i];
						transition.easing = easing;
						transition.startTime = startTime;
						transition.startValue = oldValue;
						transition.endValue = targetValue;
						m_activeTransitions[transitionPropName] = transition;
					}
					else if (transition.endValue != targetValue)
					{
						transition.easing = easing;
						transition.updateValues(targetValue, transitionDurations[i], 
							transitionDelays[i], startTime, this);
					}
				}
			}
			
			if (!m_activeTransitions)
			{
				return newStyles;
			}
			
			var styles : CSSDeclaration = newStyles.clone();
			var activeTransitionsCount : int = 0;
			for (transitionPropName in m_activeTransitions)
			{
				transition = m_activeTransitions[transitionPropName];
				transition.setValueForTimeInContext(startTime, this);
				styles.setPropertyForKey(transition.currentValue, transitionPropName);
				if (transition.hasCompleted)
				{
					delete m_activeTransitions[transitionPropName];
				}
				else
				{
					activeTransitionsCount++;
				}
			}
			
			if (!activeTransitionsCount)
			{
				m_activeTransitions = null;
			}
			
			return styles;
		}
	}
}