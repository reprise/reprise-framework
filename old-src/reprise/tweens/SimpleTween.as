/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.tweens
{
	import reprise.commands.AbstractAsynchronousCommand;
	import reprise.events.TweenEvent;

	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class SimpleTween extends AbstractAsynchronousCommand
	{
		//----------------------             Public Properties              ----------------------//
		public static const DIRECTION_FORWARD : int = 1;
		public static const DIRECTION_BACKWARD : int = -1;
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static const g_frameEventDispatcher : Shape = new Shape();
		
		protected var _direction : int;
		protected var _startTime : int;
		protected var _currentTime:int;
		protected var _duration : int;
		protected var _delay : int;
		protected var _isPaused : Boolean = false;
	
		protected var _tweenedProperties : Array;
		protected var _preventFrameDropping : Boolean;
		protected var _frameDuration : int;
		protected var _lastFrameTime : int;
		protected var _timeAdjust : int;

		
		//----------------------               Public Methods               ----------------------//
		public function SimpleTween(
			duration:int = 1, delay : uint = 0, normalizeToFrameRate : uint = 0)
		{
			_duration = duration;
			if (_duration <= 0 || isNaN(_duration))
			{
				_duration = 1;
			}
			
			_delay = delay;
			if (normalizeToFrameRate != 0)
			{
				_preventFrameDropping = true;
				_frameDuration = 1000 / normalizeToFrameRate;
			}
			
			_currentTime = 0;
			_direction = DIRECTION_FORWARD;
			_tweenedProperties = [];
		}
		
		/**
		 * adds a property to tween, overloaded to accept both a 
		 * TweenedPropertyVO or the various parameters for creating one
		 */
		public function addTweenProperty (scope:Object, property:String, 
			startValue:Number, endValue:Number, tweenFunction:Function = null, 
			roundResults:Boolean = false, propertyIsMethod:Boolean = false, 
			extraParams:Array = null) : void
		{
			if (scope is TweenedPropertyVO)
			{
				_tweenedProperties.push(scope);
			}
			else {
				var propertyVO:TweenedPropertyVO = 
					new TweenedPropertyVO(scope, property, startValue, endValue, 
					tweenFunction, roundResults, propertyIsMethod, extraParams);
				_tweenedProperties.push(propertyVO);
			}
		}
		/**
		 * add multiple tween properties
		 */
		public function addMultipleProperties (
			scope:Object, properties:Array, startValues:Array, endValues:Array, 
			tweenFunction:Function = null, roundResults:Boolean = false, 
			extraParams:Array = null) : void
		{
			for (var i : int = 0; i < properties.length; i++)
			{
				var property:String = properties[i];
				var startValue:Number = startValues[i];
				var endValue:Number = endValues[i];
				var isMethod:Boolean = (scope[property] is Function);
				var propertyVO:TweenedPropertyVO = 
					new TweenedPropertyVO (scope, property, startValue, 
					endValue, tweenFunction, roundResults, isMethod, extraParams);
				_tweenedProperties.push(propertyVO);
			}
		}
		
		public function addTweenPropertyVO(vo : TweenedPropertyVO) : void
		{
			_tweenedProperties.push(vo);
		}
		
		
		/**
		 * removes the given tweenPropertyVO from the tween
		 */
		public function removeTweenProperty (
			tweenPropertyVO:TweenedPropertyVO) : void
		{
			for (var i : int = 0; i < _tweenedProperties.length; i++)
			{
				if (TweenedPropertyVO (_tweenedProperties[i]) == tweenPropertyVO)
				{
					_tweenedProperties.splice(i, 1);
					return;
				}
			}
		}
		
		/**
		 * changes the duration of the tween without interrupting it
		 * note that the time is rescaled accordingly, 
		 * so as not to interrupt smooth movements
		 */
		public function setDuration (duration:int) : void
		{
			_currentTime = _currentTime / _duration * duration;
			_duration = duration;
		}
		
		/**
		 * returns the tween's duration
		 */
		public function getDuration () : int
		{
			return _duration;
		}
		
		/**
		 * sets the tween's current time
		 */
		public function setTime (newTime:int) : void
		{
			_currentTime = newTime;
		}
		
		/**
		 * returns the tween's current time
		 */
		public function getTime() : int
		{
			return _currentTime;
		}
		
		/**
		 * reverses the tween.
		 * note that the time is fixed so that unfinished movements start to 
		 * reverse where they are at the time of reversal when using a symmetric 
		 * easing equation. 
		 */
		public function reverse() : void
		{
			_currentTime = _duration - _currentTime;
			_direction = (_direction == DIRECTION_FORWARD ?
				DIRECTION_BACKWARD : DIRECTION_FORWARD);
			
			for (var i : int = 0; i < _tweenedProperties.length; i++)
			{
				TweenedPropertyVO(_tweenedProperties[i]).reverse();
			}
		}
		
		/**
		 * returns the tween's direction
		 */
		public function getDirection () : int
		{
			return _direction;
		}
		
		/**
		 * sets the tween's direction
		 */
		public function setDirection(direction : int) : void
		{
			_direction = direction;
		}
		
		/**
		 * returns true if tweens is running
		 */
		public function isRunning() : Boolean
		{
			return _isExecuting;
		}
		
		public function setIsPaused(bFlag:Boolean):void
		{
			if (!_isExecuting && bFlag)
			{
				return;
			}
			if (bFlag)
			{
				g_frameEventDispatcher.removeEventListener(
					Event.ENTER_FRAME, executeTick);
				_isExecuting = false;
			}
			else
			{
				_startTime = getTimer() - _currentTime - _delay - _timeAdjust;
				g_frameEventDispatcher.addEventListener(
					Event.ENTER_FRAME, executeTick);
				_isExecuting = true;
			}
			_isPaused = bFlag;
		}
		
		public function isPaused():Boolean
		{
			return _isPaused;
		}

		/**
		 * starts the tween
		 */
		public function startTween(executeFirstTickImmediately:Boolean = false) : void
		{
			_isPaused = false;
			_isCancelled = false;
			if (!_isExecuting && _currentTime < _duration)
			{
				g_frameEventDispatcher.addEventListener(
					Event.ENTER_FRAME, executeTick);
				_isExecuting = true;
				_startTime = _lastFrameTime = getTimer() + _currentTime;
				_timeAdjust = 0;
				dispatchEvent(new TweenEvent(TweenEvent.START, true));
				if (executeFirstTickImmediately)
				{
					executeTick();
				}
			}
		}
		
		public override function execute(...rest) : void
		{
			if (_isExecuting)
			{
				return;
			}
			_isCancelled = false;
			startTween(true);
		}
		
		public override function cancel() : void
		{
			resetTween();
			super.cancel();
		}
		
		/**
		 * resets the tween's position and stops
		 */
		public function resetTween() : void
		{
			stopTween();
			_currentTime = 0;
		}
		
		/**
		 * stops the tween
		 */
		public function stopTween() : void
		{
			_isPaused = false;
			g_frameEventDispatcher.removeEventListener(
				Event.ENTER_FRAME, executeTick);
			_isExecuting = false;
		}
		
		public function finish() : void
		{
			if (!_isExecuting)
			{
				return;
			}
			stopTween();
			_currentTime = _duration;
			tweenProperties();
			dispatchEvent(new TweenEvent(Event.COMPLETE, true));		
		}
		
		public override function toString() : String
		{
			return "reprise.tweens.SimpleTween";
		}
		
		public override function didSucceed() : Boolean
		{
			return true;
		}
		
		public override function reset() : void
		{
			super.reset();
			resetTween();
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		/**
		 * executes all actions needed in a timerTick
		 */
		protected function executeTick(event : Event = null) : void
		{
			var time : int = getTimer();
			if (_preventFrameDropping)
			{
				if (time - _lastFrameTime > _frameDuration)
				{
					_timeAdjust += time - _lastFrameTime - _frameDuration;
				}
				_lastFrameTime = time;
			}
			_currentTime = time - _startTime - _timeAdjust - _delay;
			if (_currentTime < 0)
			{
				return;
			}
			if (_currentTime > _duration)
			{
				_currentTime = _duration;
			}
			tweenProperties();
			dispatchEvent(new TweenEvent(TweenEvent.TICK, true));
			if (_currentTime == _duration)
			{
				stopTween ();
				dispatchEvent(new TweenEvent(Event.COMPLETE, true));
			}
		}
		
		/**
		 * executes a tween-step
		 */
		protected function tweenProperties () : void
		{
			var propertyVO:TweenedPropertyVO;
			for (var i : int = 0; i < _tweenedProperties.length; i++)
			{
				propertyVO = TweenedPropertyVO(_tweenedProperties[i]);
				propertyVO.tweenProperty(_duration, _currentTime);
			}
		}
	}
}