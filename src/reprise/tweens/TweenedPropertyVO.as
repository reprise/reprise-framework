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
	
	 
	/**
	 * @author Till Schneidereit
	 */
	public class TweenedPropertyVO
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public var scope:Object;
		public var property:String;
		public var startValue:Number;
		public var targetValue:Number;
		public var valueChange:Number;
		public var roundResults:Boolean;
		public var propertyIsMethod:Boolean;
		public var extraParams:Array;
		
		
		private var m_easingFunction : Function;
		
		
		public function TweenedPropertyVO(scope:Object, property:String, 
			startValue:Number, targetValue:Number, tweenFunction:Function = null, 
			roundResults:Boolean = false, propertyIsMethod:Boolean = false, 
			extraParams:Array = null) 
		{
			this.scope = scope;
			this.property = property;
			this.extraParams = extraParams || [];
			if (isNaN(startValue))
			{
				this.startValue = scope[property];
			}
			else
			{
				this.startValue = startValue;
			}
			this.targetValue = targetValue;
			this.roundResults = roundResults;
			valueChange = targetValue - startValue;
			if (tweenFunction != null)
			{
				m_easingFunction = tweenFunction;
			}
			setPropertyType(propertyIsMethod);
		}
		
		/**
		 * sets if the target property is a method and changes the way its' called appropriately
		 */
		public function setPropertyType (isMethod:Boolean) : void
		{
			if (isMethod)
			{
				propertyIsMethod = true;
			}
			else
			{
				propertyIsMethod = false;
			}
		}
		/*
			Method: tweenFunction
			default tweenFunction without any easing, can be replaced by any function with the same signature
		*/
		public function tweenFunction(
			time:Number, start:Number, change:Number, duration:Number) : Number
		{
			if (m_easingFunction != null)
			{
				return m_easingFunction(time, start, change, duration);
			}
			return change * time / duration + start;
		}
		
		/*
			Method: tweenProperty
			tweens the property
		*/
		public function tweenProperty(duration:Number, time:Number) : void
		{
			if (propertyIsMethod)
			{
				tweenPropertyAsMethod(duration, time);
				return;
			}
			tweenPropertyAsProperty(duration, time);
		}
		
		protected function tweenPropertyAsProperty(duration:Number, time:Number):void 
		{
			var args : Array = [time, startValue, valueChange, duration].concat(extraParams);
			var result : Number = tweenFunction.apply(null, args);
			scope[property] = roundResults ? Math.round(result) : result;
		}
		protected function tweenPropertyAsMethod (duration:Number, time:Number):void {
			var args : Array = [time, startValue, valueChange, duration].concat(extraParams);
			var result : Number = tweenFunction.apply(null, args);
			var methodArgs : Array = 
				[roundResults ? Math.round(result) : result].concat(extraParams);
			Function(scope[property]).apply(scope, methodArgs);
		}
		
		/*
			Method: reverse
			switch startValue and targetValue
		*/
		public function reverse ():void {
			var tmpValue:Number = startValue;
			startValue = targetValue;
			targetValue = tmpValue;
			valueChange = targetValue - startValue;
		}
	}
}