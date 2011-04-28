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
		protected var m_scope : Object;
		protected var m_method : Function;
		protected var m_args : Array;
		
		
		//----------------------               Public Methods               ----------------------//
		public function Delegate(scope:Object, method:Function, args:Array = null)
		{
			m_scope = scope;
			m_method = method;
			m_args = args;
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
			var args:Array = rest.concat(m_args).concat(this);
			m_method.apply(m_scope, args);
			m_didSucceed = true;
		}

		public function scope() : Object
		{
			return m_scope;
		}
		public function setScope(scope : Object) : void
		{
			m_scope = scope;
		}
		
		public function arguments():Array
		{
			return m_args;
		}
		
		public function setArguments(args:Array):void
		{
			m_args = args;
		}
	}
}