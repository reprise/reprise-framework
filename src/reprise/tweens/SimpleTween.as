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

package reprise.tweens
{
	import reprise.commands.AbstractAsynchronousCommand;
	import reprise.events.TweenEvent;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;	

	public class SimpleTween extends AbstractAsynchronousCommand
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const DIRECTION_FORWARD : int = 1;
		public static const DIRECTION_BACKWARD : int = -1;
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static const g_frameEventDispatcher : Shape = new Shape();
		
		protected var m_direction : int;
		protected var m_startTime : int;
		protected var m_currentTime:int;
		protected var m_duration : int;
		protected var m_delay : int;
		protected var m_isPaused : Boolean = false;
	
		protected var m_tweenedProperties : Array;
		protected var m_preventFrameDropping : Boolean;
		protected var m_frameDuration : int;
		protected var m_lastFrameTime : int;
		protected var m_timeAdjust : int;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function SimpleTween(
			duration:Number = 1, delay : uint = 0, normalizeToFrameRate : uint = 0)
		{
			m_duration = duration;
			if (m_duration <= 0 || isNaN(m_duration))
			{
				m_duration = 1;
			}
			
			m_delay = delay;
			if (normalizeToFrameRate != 0)
			{
				m_preventFrameDropping = true;
				m_frameDuration = 1000 / normalizeToFrameRate;
			}
			
			m_currentTime = 0;
			m_direction = DIRECTION_FORWARD;
			m_tweenedProperties = [];
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
				m_tweenedProperties.push(scope);
			}
			else {
				var propertyVO:TweenedPropertyVO = 
					new TweenedPropertyVO(scope, property, startValue, endValue, 
					tweenFunction, roundResults, propertyIsMethod, extraParams);
				m_tweenedProperties.push(propertyVO);
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
			for (var i : Number = 0; i < properties.length; i++)
			{
				var property:String = properties[i];
				var startValue:Number = startValues[i];
				var endValue:Number = endValues[i];
				var isMethod:Boolean = (scope[property] is Function);
				var propertyVO:TweenedPropertyVO = 
					new TweenedPropertyVO (scope, property, startValue, 
					endValue, tweenFunction, roundResults, isMethod, extraParams);
				m_tweenedProperties.push(propertyVO);
			}
		}
		
		/**
		 * removes the given tweenPropertyVO from the tween
		 */
		public function removeTweenProperty (
			tweenPropertyVO:TweenedPropertyVO) : void
		{
			for (var i : Number = 0; i < m_tweenedProperties.length; i++)
			{
				if (TweenedPropertyVO (m_tweenedProperties[i]) == tweenPropertyVO)
				{
					m_tweenedProperties.splice(i, 1);
					return;
				}
			}
		}
		
		/**
		 * changes the duration of the tween without interrupting it
		 * note that the time is rescaled accordingly, 
		 * so as not to interrupt smooth movements
		 */
		public function setDuration (duration:Number) : void
		{
			m_currentTime = m_currentTime / m_duration * duration;
			m_duration = duration;
		}
		
		/**
		 * returns the tween's duration
		 */
		public function getDuration () : Number
		{
			return m_duration;
		}
		
		/**
		 * sets the tween's current time
		 */
		public function setTime (newTime:Number) : void
		{
			m_currentTime = newTime;
		}
		
		/**
		 * returns the tween's current time
		 */
		public function getTime() : Number
		{
			return m_currentTime;
		}
		
		/**
		 * reverses the tween.
		 * note that the time is fixed so that unfinished movements start to 
		 * reverse where they are at the time of reversal when using a symmetric 
		 * easing equation. 
		 */
		public function reverse() : void
		{
			m_currentTime = m_duration - m_currentTime;
			m_direction = (m_direction == DIRECTION_FORWARD ? 
				DIRECTION_BACKWARD : DIRECTION_FORWARD);
			
			for (var i : Number = 0; i < m_tweenedProperties.length; i++)
			{
				TweenedPropertyVO(m_tweenedProperties[i]).reverse();
			}
		}
		
		/**
		 * returns the tween's direction
		 */
		public function getDirection () : int
		{
			return m_direction;
		}
		
		/**
		 * sets the tween's direction
		 */
		public function setDirection(direction : int) : void
		{
			m_direction = direction;
		}
		
		/**
		 * returns true if tweens is running
		 */
		public function isRunning() : Boolean
		{
			return m_isExecuting;
		}
		
		public function setIsPaused(bFlag:Boolean):void
		{
			if (m_isExecuting)
			{
				return;
			}
			if (bFlag)
			{
				g_frameEventDispatcher.removeEventListener(
					Event.ENTER_FRAME, executeTick);
				m_currentTime = m_duration - m_currentTime;
			}
			else
			{
				startTween();
			}
		}
		
		public function isPaused():Boolean
		{
			return m_isPaused;
		}

		/**
		 * starts the tween
		 */
		public function startTween(executeFirstTickImmediately:Boolean = false) : void
		{
			m_isPaused = false;
			m_isCancelled = false;
			if (!m_isExecuting && m_currentTime < m_duration)
			{
				g_frameEventDispatcher.addEventListener(
					Event.ENTER_FRAME, executeTick);
				m_isExecuting = true;
				m_startTime = m_lastFrameTime = getTimer() + m_currentTime;
				m_timeAdjust = 0;
				dispatchEvent(new TweenEvent(TweenEvent.START, true));
				if (executeFirstTickImmediately)
				{
					executeTick();
				}
			}
		}
		
		public override function execute(...rest) : void
		{
			if (m_isExecuting)
			{
				return;
			}
			m_isCancelled = false;
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
			m_currentTime = 0;
		}
		
		/**
		 * stops the tween
		 */
		public function stopTween() : void
		{
			m_isPaused = false;
			g_frameEventDispatcher.removeEventListener(
				Event.ENTER_FRAME, executeTick);
			m_isExecuting = false;
		}
		
		public function finish() : void
		{
			if (!m_isExecuting)
			{
				return;
			}
			stopTween();
			m_currentTime = m_duration;
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
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		/**
		 * executes all actions needed in a timerTick
		 */
		protected function executeTick(event : Event = null) : void
		{
			var time : int = getTimer();
			if (m_preventFrameDropping)
			{
				if (time - m_lastFrameTime > m_frameDuration)
				{
					m_timeAdjust += time - m_lastFrameTime - m_frameDuration;
				}
				m_lastFrameTime = time;
			}
			m_currentTime = time - m_startTime - m_timeAdjust - m_delay;
			if (m_currentTime < 0)
			{
				return;
			}
			if (m_currentTime > m_duration)
			{
				m_currentTime = m_duration;
			}
			tweenProperties();
			dispatchEvent(new TweenEvent(TweenEvent.TICK, true));
			if (m_currentTime == m_duration)
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
			for (var i : Number = 0; i < m_tweenedProperties.length; i++)
			{
				propertyVO = TweenedPropertyVO(m_tweenedProperties[i]);
				propertyVO.tweenProperty(m_duration, m_currentTime);
			}
		}
	}
}