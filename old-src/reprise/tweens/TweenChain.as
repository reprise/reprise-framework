/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.tweens { 
	import reprise.events.TweenEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * @author Till Schneidereit
	 */
	public class TweenChain extends EventDispatcher
	{
		//----------------------             Public Properties              ----------------------//
		public static const EVENT_START : String = "start";
		public static const EVENT_TICK : String = "tick";
		public static const EVENT_FINISH_TWEEN : String = "finishTween";
		public static const EVENT_FINISH_CHAIN : String = "finishChain";
		
		public static const DIRECTION_FORWARD:int = 1;
		public static const DIRECTION_BACKWARD:int = -1;
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _tweens : Array;
		protected var _currentTween : SimpleTween;
		protected var _currentTweenIndex : int;
		protected var _isRunning : Boolean;
		protected var _direction:Number;
		
		//----------------------               Public Methods               ----------------------//
		public function TweenChain(...rest)
		{
	 		_tweens = [];
	 		for (var i : Number = 0; i < rest.length; i++)
	 		{
	 			_tweens.push(rest[i]);
	 		}
	 	}
		
		/**
		 * adds a tween to the end of the chain
		 */
		public function addTween (tween:SimpleTween):void {
			_tweens.push(tween);
		}
		
		/**
		 * starts the tweenChain
		 */
		public function startTweenChain ():void {
			if (!_currentTween) {
				_currentTweenIndex = 0;
				_currentTween = _tweens[0];
			}
			_isRunning = true;
			startTween();
		}
		
		/**
		 * resets the tweenChain
		 */
		public function resetTweenChain() : void
		{
			if (_currentTween)
			{
				_currentTween.resetTween();
				_currentTween.removeEventListener(
					Event.COMPLETE, tween_finish);
				_currentTween.removeEventListener(
					TweenEvent.TICK, tween_tick);
				_currentTween = null;
				_isRunning = false;
			}
		}
		
		/**
		 * Stops the tweenChain without resetting it
		 */
		public function stopTweenChain() : void
		{
			if (_currentTween)
			{
				_currentTween.stopTween();
				_isRunning = false;
			}
		}
		/**
		 * Reverses the tween chain.
		 * Note that the time is fixed so that unfinished movements start to 
		 * reverse where they are at the time of reversal when using a symmetric 
		 * easing equation. 
		 */
		public function reverse() : void
		{
			_direction = (_direction == DIRECTION_FORWARD ?
				DIRECTION_BACKWARD : DIRECTION_FORWARD);
			
			_tweens.reverse();
			for (var i : Number = 0; i < _tweens.length; i++)
			{
				SimpleTween(_tweens[i]).reverse();
			}
			_currentTweenIndex = _tweens.length - 1 - _currentTweenIndex;
		}
		
		/**
		 * returns the tween's direction
		 */
		public function getDirection () : Number
		{
			return _direction;
		}
		
		/**
		 * sets the tween's direction
		 */
		public function setDirection (newDirection:Number) : void
		{
			_direction = newDirection;
		}
		
		/**
		 * returns if the tweenChain is currently running
		 */
		public function isRunning () : Boolean
		{
			return _isRunning;
		}
		
		public override function toString() : String
		{
			return "reprise.tweens.TweenChain";
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		/**
		 * event handler, invoked on each tick of the current tween
		 */
		protected function tween_tick(event : TweenEvent) : void
		{
			dispatchEvent(new Event(EVENT_TICK));
		}
		/**
		 * callback invoked when a tween has finished
		 */
		protected function tween_finish(event:Event) : void
		{
			_currentTween.removeEventListener(
				Event.COMPLETE, tween_finish);
			_currentTween.removeEventListener(
				TweenEvent.TICK, tween_tick);
			_currentTween.resetTween();
			dispatchEvent(new Event(EVENT_FINISH_TWEEN));
			if (_currentTweenIndex < _tweens.length - 1)
			{
				_currentTweenIndex++;
				_currentTween = SimpleTween(_tweens[_currentTweenIndex]);
				startTween();
			}
			else
			{
				_currentTween = null;
				_isRunning = false;
				dispatchEvent(new Event(EVENT_FINISH_CHAIN));
			}
		}
		
		/**
		 * starts the current tween
		 */
		protected function startTween() : void
		{
			_currentTween.addEventListener(TweenEvent.TICK, tween_tick);
			_currentTween.addEventListener(Event.COMPLETE, tween_finish);
			_currentTween.startTween();
		}
	}
}