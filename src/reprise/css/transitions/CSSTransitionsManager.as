/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.transitions
{
	import reprise.core.reprise;
	import reprise.css.CSSDeclaration;
	import reprise.css.CSSParsingResult;
	import reprise.css.CSSPropertiesChangeList;
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyCache;
	import reprise.events.TransitionEvent;

	import com.robertpenner.easing.Linear;

	import flash.events.EventDispatcher;
	
	use namespace reprise;
	
	public class CSSTransitionsManager
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static const DEFAULT_DURATION : Array = initDefaultDuration();
		protected static const DEFAULT_DELAY : Array = initDefaultDelay();
		protected static const DEFAULT_EASING : Array = [Linear.easeNone];
		protected static var g_transitionShortcuts : Object = {};
		
		protected var m_transitionProperties : Array;
		protected var m_transitionDurations : Array;
		protected var m_transitionDelays : Array;
		protected var m_transitionEasings : Array;
		protected var m_defaultValues : Array;
		
		protected var m_activeTransitions : Object;
		protected var m_adjustedStartTimes : Object;
		protected var m_target : EventDispatcher;
		protected var m_frameDuration : int;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSTransitionsManager(target : EventDispatcher)
		{
			m_target = target;
			m_adjustedStartTimes = {};
		}
		
		public function isActive() : Boolean
		{
			return m_activeTransitions != null;
		}
		
		public function hasTransitionForStyle(style : String) : Boolean
		{
			return m_transitionProperties && m_transitionProperties.indexOf(style) != -1;
		}
		
		public function hasActiveTransitionForStyle(style : String) : Boolean
		{
			return m_activeTransitions && m_activeTransitions[style] != null;
		}
		
		public function registerAdjustedStartTimeForProperty(
			startTime : int, property : String) : void
		{
			m_adjustedStartTimes[property] = startTime;
		}

		public function processTransitions(oldStyles : CSSDeclaration, newStyles : CSSDeclaration, 
			changeList : CSSPropertiesChangeList, frameRate : int, frameTime : int) : CSSDeclaration
		{
			var transitionPropName : String;
			var transitionDuration : CSSProperty;
			var transitionDelay : CSSProperty;
			var transitionEasing : Function;
			var transition : CSSPropertyTransition;
			
			if (newStyles.hasStyle('transitionFrameDropping') && 
				newStyles.getStyle('transitionFrameDropping').specifiedValue() == 'prevent')
			{
				m_frameDuration = 1000 / frameRate;
			}
			else
			{
				m_frameDuration = 10000;
			}
			if (newStyles && newStyles.hasStyle('RepriseTransitionProperty'))
			{
				m_transitionProperties = 
					newStyles.getStyle('RepriseTransitionProperty').specifiedValue();
				m_transitionDurations = newStyles.hasStyle('RepriseTransitionDuration') 
					? newStyles.getStyle('RepriseTransitionDuration').specifiedValue() 
					: DEFAULT_DURATION;
				m_transitionDelays = newStyles.hasStyle('RepriseTransitionDelay') 
					? newStyles.getStyle('RepriseTransitionDelay').specifiedValue() 
					: DEFAULT_DELAY;
				m_transitionEasings = 
					newStyles.hasStyle('RepriseTransitionTimingFunction') 
					? newStyles.getStyle('RepriseTransitionTimingFunction').specifiedValue() 
					: DEFAULT_EASING;
				m_defaultValues = newStyles.hasStyle('RepriseTransitionDefaultValue') && 
					newStyles.hasStyle('RepriseTransitionDefaultValue') 
					? newStyles.getStyle('RepriseTransitionDefaultValue').specifiedValue() 
					: [];
				
				//remove any transitions that aren't supposed to be active anymore
				if (m_activeTransitions)
				{
					for (transitionPropName in m_activeTransitions)
					{
						//TODO: check if the shortcut check can also use g_transitionShortcuts here
						if (m_transitionProperties.indexOf(transitionPropName) == -1)
						{
							transition = m_activeTransitions[transitionPropName];
							var shortcut : String = transition.shortcut;
							if (!shortcut || m_transitionProperties.indexOf(shortcut) == -1)
							{
								delete m_activeTransitions[transitionPropName];
								var cancelEvent : TransitionEvent = new TransitionEvent(
									TransitionEvent.TRANSITION_CANCEL);
								cancelEvent.propertyName = transitionPropName;
								cancelEvent.elapsedTime = frameTime - 
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
					var oldValue : CSSProperty = 
						CSSProperty(oldStyles && oldStyles.getStyle(transitionPropName));
					var targetValue : CSSProperty = newStyles.getStyle(transitionPropName);
					
					//apply default values
					if (defaultValue && (defaultValue.specifiedValue() != 'none' || 
						transitionPropName == 'display'))
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
					
					//ignore properties that don't have previous values or target values or where 
					//the values are identical
					if (!oldValue || !targetValue || targetValue.isAuto() || 
						oldValue == targetValue)
					{
						return;
					}
					transition = m_activeTransitions[transitionPropName];
					if (!transition)
					{
						transition = new CSSPropertyTransition(
							transitionPropName, shortcut);
						transition.duration = transitionDuration;
						transition.delay = transitionDelay;
						transition.easing = transitionEasing;
						transition.startTime = 
							m_adjustedStartTimes[transitionPropName] || frameTime;
						transition.startValue = oldValue;
						transition.endValue = targetValue;
						m_activeTransitions[transitionPropName] = transition;
					}
					else if (transition.currentValue.specifiedValue() == 
						targetValue.specifiedValue())
					{
						delete m_activeTransitions[transitionPropName];
					}
					else if (transition.endValue != targetValue)
					{
						transition.easing = transitionEasing;
						transition.updateValues(targetValue, transitionDuration, transitionDelay, 
							m_adjustedStartTimes[transitionPropName] || frameTime, 
							m_frameDuration, this);
					}
				}
				
				//add all new properties and update already active ones
				for (var i : int = 0; i < m_transitionProperties.length; i++)
				{
					transitionPropName = m_transitionProperties[i];
					transitionDuration = m_transitionDurations[i] || 
						transitionDuration || DEFAULT_DURATION[0];
					transitionDelay = m_transitionDelays[i] || transitionDelay || DEFAULT_DELAY[0];
					transitionEasing = m_transitionEasings[i] || 
						transitionEasing || DEFAULT_EASING[0];
					var defaultValue : * = null;
					if (m_defaultValues[i] && (m_defaultValues[i] != 'none' || 
						transitionPropName == 'display'))
					{
						defaultValue = CSSPropertyCache.propertyForKeyValue(transitionPropName,
							m_defaultValues[i], 'Transition Default Value', '[Transition Manager]');
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
				changeList.addChange(transitionPropName);
				transition = m_activeTransitions[transitionPropName];
				var previousRatio : Number = transition.currentRatio;
				transition.setValueForTimeInContext(frameTime, m_frameDuration, this);
				if (previousRatio == 0 && transition.currentRatio != 0)
				{
					var startEvent : TransitionEvent = 
						new TransitionEvent(TransitionEvent.TRANSITION_START);
					startEvent.propertyName = transitionPropName;
					m_target.dispatchEvent(startEvent);
				}
				styles.setPropertyForKey(transition.currentValue, transitionPropName);
				if (transition.hasCompleted)
				{
					delete m_activeTransitions[transitionPropName];
					var completeEvent : TransitionEvent = 
						new TransitionEvent(TransitionEvent.TRANSITION_COMPLETE);
					completeEvent.propertyName = transitionPropName;
					completeEvent.elapsedTime = frameTime - 
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
			
			m_adjustedStartTimes = {};
			
			return styles;
		}
		
		public static function registerTransitionShortcut(
			name : String, properties : Array) : void
		{
			g_transitionShortcuts[name] = properties;
		}
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected static function initDefaultDuration() : Array
		{
			var property : CSSProperty = new CSSProperty();
			property.setUnit('ms');
			property.setSpecifiedValue(250);
			return [property];
		}
		protected static function initDefaultDelay() : Array
		{
			var property : CSSProperty = new CSSProperty();
			property.setUnit('ms');
			property.setSpecifiedValue(0);
			return [property];
		}
	}
}