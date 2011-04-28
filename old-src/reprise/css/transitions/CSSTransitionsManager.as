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
	{//----------------------       Private / Protected Properties       ----------------------//
		protected static const DEFAULT_DURATION : Array = initDefaultDuration();
		protected static const DEFAULT_DELAY : Array = initDefaultDelay();
		protected static const DEFAULT_EASING : Array = [Linear.easeNone];
		protected static var g_transitionShortcuts : Object = {};
		
		protected var _transitionProperties : Array;
		protected var _transitionDurations : Array;
		protected var _transitionDelays : Array;
		protected var _transitionEasings : Array;
		protected var _defaultValues : Array;
		
		protected var _activeTransitions : Object;
		protected var _adjustedStartTimes : Object;
		protected var _target : EventDispatcher;
		protected var _frameDuration : int;

		
		//----------------------               Public Methods               ----------------------//
		public function CSSTransitionsManager(target : EventDispatcher)
		{
			_target = target;
			_adjustedStartTimes = {};
		}
		
		public function isActive() : Boolean
		{
			return _activeTransitions != null;
		}
		
		public function hasTransitionForStyle(style : String) : Boolean
		{
			return _transitionProperties && _transitionProperties.indexOf(style) != -1;
		}
		
		public function hasActiveTransitionForStyle(style : String) : Boolean
		{
			return _activeTransitions && _activeTransitions[style] != null;
		}
		
		public function registerAdjustedStartTimeForProperty(
			startTime : int, property : String) : void
		{
			_adjustedStartTimes[property] = startTime;
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
				_frameDuration = 1000 / frameRate;
			}
			else
			{
				_frameDuration = 10000;
			}
			if (newStyles && newStyles.hasStyle('RepriseTransitionProperty'))
			{
				_transitionProperties =
					newStyles.getStyle('RepriseTransitionProperty').specifiedValue();
				_transitionDurations = newStyles.hasStyle('RepriseTransitionDuration')
					? newStyles.getStyle('RepriseTransitionDuration').specifiedValue() 
					: DEFAULT_DURATION;
				_transitionDelays = newStyles.hasStyle('RepriseTransitionDelay')
					? newStyles.getStyle('RepriseTransitionDelay').specifiedValue() 
					: DEFAULT_DELAY;
				_transitionEasings =
					newStyles.hasStyle('RepriseTransitionTimingFunction') 
					? newStyles.getStyle('RepriseTransitionTimingFunction').specifiedValue() 
					: DEFAULT_EASING;
				_defaultValues = newStyles.hasStyle('RepriseTransitionDefaultValue') &&
					newStyles.hasStyle('RepriseTransitionDefaultValue') 
					? newStyles.getStyle('RepriseTransitionDefaultValue').specifiedValue() 
					: [];
				
				//remove any transitions that aren't supposed to be active anymore
				if (_activeTransitions)
				{
					for (transitionPropName in _activeTransitions)
					{
						//TODO: check if the shortcut check can also use g_transitionShortcuts here
						if (_transitionProperties.indexOf(transitionPropName) == -1)
						{
							transition = _activeTransitions[transitionPropName];
							var shortcut : String = transition.shortcut;
							if (!shortcut || _transitionProperties.indexOf(shortcut) == -1)
							{
								delete _activeTransitions[transitionPropName];
								var cancelEvent : TransitionEvent = new TransitionEvent(
									TransitionEvent.TRANSITION_CANCEL);
								cancelEvent.propertyName = transitionPropName;
								cancelEvent.elapsedTime = frameTime - 
									transition.startTime - 
									transition.delay.specifiedValue();
								_target.dispatchEvent(cancelEvent);
							}
						}
					}
				}
				else
				{
					_activeTransitions = {};
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
					transition = _activeTransitions[transitionPropName];
					if (!transition)
					{
						transition = new CSSPropertyTransition(
							transitionPropName, shortcut);
						transition.duration = transitionDuration;
						transition.delay = transitionDelay;
						transition.easing = transitionEasing;
						transition.startTime = 
							_adjustedStartTimes[transitionPropName] || frameTime;
						transition.startValue = oldValue;
						transition.endValue = targetValue;
						_activeTransitions[transitionPropName] = transition;
					}
					else if (transition.currentValue.specifiedValue() == 
						targetValue.specifiedValue())
					{
						delete _activeTransitions[transitionPropName];
					}
					else if (transition.endValue != targetValue)
					{
						transition.easing = transitionEasing;
						transition.updateValues(targetValue, transitionDuration, transitionDelay, 
							_adjustedStartTimes[transitionPropName] || frameTime,
							_frameDuration, this);
					}
				}
				
				//add all new properties and update already active ones
				for (var i : int = 0; i < _transitionProperties.length; i++)
				{
					transitionPropName = _transitionProperties[i];
					transitionDuration = _transitionDurations[i] ||
						transitionDuration || DEFAULT_DURATION[0];
					transitionDelay = _transitionDelays[i] || transitionDelay || DEFAULT_DELAY[0];
					transitionEasing = _transitionEasings[i] ||
						transitionEasing || DEFAULT_EASING[0];
					var defaultValue : * = null;
					if (_defaultValues[i] && (_defaultValues[i] != 'none' ||
						transitionPropName == 'display'))
					{
						defaultValue = CSSPropertyCache.propertyForKeyValue(
							transitionPropName, _defaultValues[i], null);
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
			
			if (!_activeTransitions)
			{
				return newStyles;
			}
			
			var styles : CSSDeclaration = newStyles.clone();
			var activeTransitionsCount : int = 0;
			for (transitionPropName in _activeTransitions)
			{
				changeList.addChange(transitionPropName);
				transition = _activeTransitions[transitionPropName];
				var previousRatio : Number = transition.currentRatio;
				transition.setValueForTimeInContext(frameTime, _frameDuration, this);
				if (previousRatio == 0 && transition.currentRatio != 0)
				{
					var startEvent : TransitionEvent = 
						new TransitionEvent(TransitionEvent.TRANSITION_START);
					startEvent.propertyName = transitionPropName;
					_target.dispatchEvent(startEvent);
				}
				styles.setPropertyForKey(transition.currentValue, transitionPropName);
				if (transition.hasCompleted)
				{
					delete _activeTransitions[transitionPropName];
					var completeEvent : TransitionEvent = 
						new TransitionEvent(TransitionEvent.TRANSITION_COMPLETE);
					completeEvent.propertyName = transitionPropName;
					completeEvent.elapsedTime = frameTime - 
						transition.startTime - 
						(transition.delay ? transition.delay.specifiedValue() : 0);
					_target.dispatchEvent(completeEvent);
				}
				else
				{
					activeTransitionsCount++;
				}
			}
			
			if (!activeTransitionsCount)
			{
				_activeTransitions = null;
				var allCompleteEvent : TransitionEvent = 
					new TransitionEvent(TransitionEvent.ALL_TRANSITIONS_COMPLETE);
				_target.dispatchEvent(allCompleteEvent);
			}
			
			_adjustedStartTimes = {};
			
			return styles;
		}
		
		public static function registerTransitionShortcut(
			name : String, properties : Array) : void
		{
			g_transitionShortcuts[name] = properties;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
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