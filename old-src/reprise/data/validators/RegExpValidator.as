/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.data.validators 
{
	import reprise.commands.AbstractCommand;	
	import reprise.data.IValidator;
	
	/**
	 * @author till
	 */
	public class RegExpValidator extends AbstractCommand implements IValidator 
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _value : *;
		protected var _regexp : RegExp;

		
		//----------------------               Public Methods               ----------------------//
		public function RegExpValidator(expression : String)
		{
			var parts : Array = expression.substr(1).split('/');
			var exp : String = parts[0];
			var options : String = parts[1] || '';
			_regexp = new RegExp(exp, options);
		}
		
		public override function execute(...args) : void
		{
			_didSucceed = _regexp.test(_value);
		}

		public function setValue(value : *) : void
		{
			_value = value;
		}
		
		public function value() : *
		{
			return _value;
		}
	}
}
