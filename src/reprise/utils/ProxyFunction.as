/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.utils { 
	/**
	 * This is a Delegate class which is similar to mx.utils.Delegate.
	 * The advantage is compatibility to mtasc and the ability to add parameters
	 * to the delegate function.
	 */
	public class ProxyFunction {
	
		/**
		 * Constructor. Private to prevent instantiation from outside
		 */
		public function ProxyFunction() {}
	
		/**
		 * Creates a functions wrapper for the original function so that it runs
		 * in the provided context
		 *
		 * @param	scope		context in which to run the function
		 * @param	method		function to run
		 *
		 * @return	Function	delegate function
		 * @usage
		 * 			<code>
		 * 			button.onRelease = onReleaseButton [, arg0, arg1, ... argn];
		 * 			</code>
		 */
		public static function create(scope:Object, method:Function, ... args) : Function
		{
			var params:Array = args;
	
			var proxyFunc:Function = function () : Object
			{
				var result:Object = method.apply(scope, arguments.concat(params));
				return result;
			};
	
			return proxyFunc;
		}
	}
}