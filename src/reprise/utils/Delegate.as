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

package reprise.utils
{ 
	import reprise.commands.ICommand;	
	
	import flash.events.EventDispatcher;
	
	public class Delegate extends EventDispatcher implements ICommand
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_scope : Object;
		protected var m_method : Function;
		protected var m_args : Array;
		protected var m_priority : Number;
		protected var m_id : Number;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
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
		public function execute(...rest) : void
		{
			var args:Array = rest.concat(m_args).concat(this);
			m_method.apply(m_scope, args);
		}
		
		public function scope() : Object
		{
			return m_scope;
		}
		public function setScope(scope : Object) : void
		{
			m_scope = scope;
		}
		public function setPriority(value : Number) : void
		{
			m_priority = value;
		}
		public function priority() : Number
		{
			return m_priority;
		}
		public function setId(value : Number) : void
		{
			m_id = value;
		}
		public function id() : Number
		{
			return m_id;
		}
	}
}