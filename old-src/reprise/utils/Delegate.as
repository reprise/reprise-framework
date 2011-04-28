/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.utils
{
	import reprise.commands.AbstractCommand;	 

	public class Delegate extends AbstractCommand
	{//----------------------       Private / Protected Properties       ----------------------//
		protected var _scope : Object;
		protected var _method : Function;
		protected var _args : Array;
		
		
		//----------------------               Public Methods               ----------------------//
		public function Delegate(scope:Object, method:Function, args:Array = null)
		{
			_scope = scope;
			_method = method;
			_args = args;
		}
	
		public static function create(scope:Object, method:Function, ...rest) : Delegate
		{
			return new Delegate(scope, method, rest);
		}
		
		/**
		 * executes the delegate
		 */
		public override function execute(...rest) : void
		{
			var args:Array = rest.concat(_args).concat(this);
			_method.apply(_scope, args);
			_didSucceed = true;
		}

		public function scope() : Object
		{
			return _scope;
		}
		public function setScope(scope : Object) : void
		{
			_scope = scope;
		}
		
		public function arguments():Array
		{
			return _args;
		}
		
		public function setArguments(args:Array):void
		{
			_args = args;
		}
	}
}