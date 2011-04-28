/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.utils
{
	import flash.events.Event;	
	import flash.events.EventDispatcher;
	
	import reprise.commands.AbstractAsynchronousCommand;	

	public class AsynchronousDelegate extends AbstractAsynchronousCommand
	{
		//----------------------         Private / Protected Methods        ----------------------//
		protected var _executionDelegate : Delegate;
		protected var _waitsForEvent : Boolean = false;
		protected var _commandCompleteEventName : String;
		protected var _successEvaluationFunction : Function;
	
	
		//----------------------               Public Methods               ----------------------//
		public function AsynchronousDelegate(scope:Object, method:Function, 
			args:Array, commandCompleteEventName:String = null)
		{
			_executionDelegate = new Delegate(scope, method, args);
			if (commandCompleteEventName != null)
			{
				_waitsForEvent = true;
				_commandCompleteEventName = commandCompleteEventName;
			}
			_successEvaluationFunction = function(e:Event):Boolean{return true;};
		}
		
		public static function create(
			scope:Object, method:Function, ...args) : AsynchronousDelegate
		{
			return new AsynchronousDelegate(scope, method, args);
		}
		
		override public function execute(...args) : void
		{
			super.execute();
			if (_waitsForEvent)
			{
				EventDispatcher(_executionDelegate.scope()).addEventListener(
					_commandCompleteEventName, execution_complete);
			}
			_executionDelegate.execute();
			if (!_waitsForEvent)
			{
				notifyComplete(true);
			}
		}
		
		public function waitsForEvent() : Boolean
		{
			return _waitsForEvent;
		}
		public function setWaitsForEvent(val:Boolean) : void
		{
			_waitsForEvent = val;
		}
		
		public function commandCompleteEventName() : String
		{
			return _commandCompleteEventName;
		}
		public function setCommandCompleteEventName(val:String) : void
		{
			_commandCompleteEventName = val;
		}
		
		public function successEvaluationFunction():Function
		{
			return _successEvaluationFunction;
		}
		public function setSuccessEvaluationFunction(f:Function):void
		{
			_successEvaluationFunction = f;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function execution_complete(event : Event) : void
		{
			EventDispatcher(_executionDelegate.scope()).removeEventListener(
				_commandCompleteEventName, execution_complete);
			notifyComplete(_successEvaluationFunction(event));
		}
	}
}