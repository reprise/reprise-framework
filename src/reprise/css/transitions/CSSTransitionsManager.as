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
	import reprise.events.TransitionEvent;	
	
	import flash.events.EventDispatcher;	
	
	import com.robertpenner.easing.Linear;
	
	import flash.utils.getTimer;
	
	import reprise.css.CSSDeclaration;
	import reprise.css.CSSParsingResult;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyCache;
	
	public class CSSTransitionsManager
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_transitionShortcuts : Object = {};
		
		protected var m_activeTransitions : Object;
		protected var m_target : EventDispatcher;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSTransitionsManager(target : EventDispatcher)
		{
			m_target = target;
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
							transition = m_activeTransitions[transitionPropName];
							var shortcut : String = transition.shortcut;
							if (!shortcut || transitionProperties.indexOf(shortcut) == -1)
							{
								delete m_activeTransitions[transitionPropName];
								var cancelEvent : TransitionEvent = new TransitionEvent(
									TransitionEvent.TRANSITION_CANCEL);
								cancelEvent.propertyName = transitionPropName;
								cancelEvent.elapsedTime = startTime - 
									transition.startTime - 
									transition.delay.specifiedValue();
								m_target.dispatchEvent(cancelEvent);
							}
						}
					}
				}
				else
				{
					m_activeTransitions = {};
				}
				
				function processProperty(transitionPropName : String, 
					shortcut : String = null, defaultValue : CSSProperty = null) : void
				{
					var oldValue : CSSProperty = (oldStyles && 
						oldStyles.getStyle(transitionPropName)) as CSSProperty;
					var targetValue : CSSProperty = 
						newStyles.getStyle(transitionPropName);
					
					//apply default values
					if (defaultValue && defaultValue.specifiedValue() != 'none')
					{
						//use default value if we have a target value but no old value
						if (targetValue && !oldValue)
						{
							oldValue = defaultValue;
						}
						//use default value if we have an old value but no target value
						else if (oldValue && !targetValue)
						{
							targetValue = defaultValue;
						}
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
						return;
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
						transition = new CSSPropertyTransition(
							transitionPropName, shortcut);
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
				
				//add all new properties and update already active ones
				for (var i : int = transitionProperties.length; i--;)
				{
					transitionPropName = transitionProperties[i];
					var defaultValue : *;
					if (defaultValues[i] && defaultValues[i] != 'none')
					{
						defaultValue = CSSPropertyCache.propertyForKeyValue(
							transitionPropName, defaultValues[i], null);
					}
					if (g_transitionShortcuts[transitionPropName])
					{
						var expansions : Array = 
							g_transitionShortcuts[transitionPropName];
						if (defaultValue)
						{
							var defaultValuesForExpansions : CSSParsingResult = 
								CSSParsingResult(defaultValue);
							var name : String;
							for each (name in expansions)
							{
								processProperty(name, transitionPropName, 
									defaultValuesForExpansions.propertyForKey(name));
							}
						}
						else
						{
							for each (name in expansions)
							{
								processProperty(name, transitionPropName);
							}
						}
					}
					else
					{
						processProperty(transitionPropName, 
							null, CSSProperty(defaultValue));
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
					var completeEvent : TransitionEvent = 
						new TransitionEvent(TransitionEvent.TRANSITION_COMPLETE);
					completeEvent.propertyName = transitionPropName;
					completeEvent.elapsedTime = startTime - 
						transition.startTime - 
						(transition.delay ? transition.delay.specifiedValue() : 0);
					m_target.dispatchEvent(completeEvent);
				}
				else
				{
					activeTransitionsCount++;
				}
			}
			
			if (!activeTransitionsCount)
			{
				m_activeTransitions = null;
				var allCompleteEvent : TransitionEvent = 
					new TransitionEvent(TransitionEvent.ALL_TRANSITIONS_COMPLETE);
				m_target.dispatchEvent(allCompleteEvent);
			}
			
			return styles;
		}
		
		public static function registerTransitionShortcut(
			name : String, properties : Array) : void
		{
			g_transitionShortcuts[name] = properties;
		}
	}
}