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

package reprise.tweens { 
	import reprise.events.TweenEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * @author Till Schneidereit
	 */
	public class TweenChain extends EventDispatcher
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var EVENT_START : String = "start";
		public static var EVENT_TICK : String = "tick";
		public static var EVENT_FINISH_TWEEN : String = "finishTween";
	public static var EVENT_FINISH_CHAIN : String = "finishChain";
		
		public static var DIRECTION_FORWARD:Number = 1;
		public static var DIRECTION_BACKWARD:Number = -1;
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_tweens : Array;
		protected var m_currentTween : SimpleTween;
		protected var m_currentTweenIndex : Number;
		protected var m_isRunning : Boolean;
		protected var m_direction:Number;
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function TweenChain(...rest)
		{
	 		m_tweens = [];
	 		for (var i : Number = 0; i < rest.length; i++)
	 		{
	 			m_tweens.push(rest[i]);
	 		}
	 	}
		
		/**
		 * adds a tween to the end of the chain
		 */
		public function addTween (tween:SimpleTween):void {
			m_tweens.push(tween);
		}
		
		/**
		 * starts the tweenChain
		 */
		public function startTweenChain ():void {
			if (!m_currentTween) {
				m_currentTweenIndex = 0;
				m_currentTween = m_tweens[0];
			}
			m_isRunning = true;
			startTween();
		}
		
		/**
		 * resets the tweenChain
		 */
		public function resetTweenChain() : void
		{
			if (m_currentTween)
			{
				m_currentTween.resetTween();
				m_currentTween.removeEventListener(
					Event.COMPLETE, tween_finish);
				m_currentTween.removeEventListener(
					TweenEvent.TICK, tween_tick);
				m_currentTween = null;
				m_isRunning = false;
			}
		}
		
		/**
		 * Stops the tweenChain without resetting it
		 */
		public function stopTweenChain() : void
		{
			if (m_currentTween)
			{
				m_currentTween.stopTween();
				m_isRunning = false;
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
			m_direction = (m_direction == DIRECTION_FORWARD ? 
				DIRECTION_BACKWARD : DIRECTION_FORWARD);
			
			m_tweens.reverse();
			for (var i : Number = 0; i < m_tweens.length; i++)
			{
				SimpleTween(m_tweens[i]).reverse();
			}
			m_currentTweenIndex = m_tweens.length - 1 - m_currentTweenIndex;
		}
		
		/**
		 * returns the tween's direction
		 */
		public function getDirection () : Number
		{
			return m_direction;
		}
		
		/**
		 * sets the tween's direction
		 */
		public function setDirection (newDirection:Number) : void
		{
			m_direction = newDirection;
		}
		
		/**
		 * returns if the tweenChain is currently running
		 */
		public function isRunning () : Boolean
		{
			return m_isRunning;
		}
		
		public override function toString() : String
		{
			return "reprise.tweens.TweenChain";
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		/**
		 * event handler, invoked on each tick of the current tween
		 */
		protected function tween_tick() : void
		{
			dispatchEvent(new Event(EVENT_TICK));
		}
		/**
		 * callback invoked when a tween has finished
		 */
		protected function tween_finish(event:Event) : void
		{
			m_currentTween.removeEventListener(
				Event.COMPLETE, tween_finish);
			m_currentTween.removeEventListener(
				TweenEvent.TICK, tween_tick);
			m_currentTween.resetTween();
			dispatchEvent(new Event(EVENT_FINISH_TWEEN));
			if (m_currentTweenIndex < m_tweens.length - 1)
			{
				m_currentTweenIndex++;
				m_currentTween = SimpleTween(m_tweens[m_currentTweenIndex]);
				startTween();
			}
			else
			{
				m_currentTween = null;
				m_isRunning = false;
				dispatchEvent(new Event(EVENT_FINISH_CHAIN));
			}
		}
		
		/**
		 * starts the current tween
		 */
		protected function startTween() : void
		{
			m_currentTween.addEventListener(TweenEvent.TICK, tween_tick);
			m_currentTween.addEventListener(Event.COMPLETE, tween_finish);
			m_currentTween.startTween();
		}
	}
}