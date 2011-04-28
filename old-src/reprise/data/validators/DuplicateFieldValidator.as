/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.data.validators 
{
	import reprise.commands.AbstractCommand;
	import reprise.controls.html.IInput;
	import reprise.data.IValidator;
	
	public class DuplicateFieldValidator extends AbstractCommand implements IValidator 
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _value : *;
		protected var _field : IInput;
		protected var _regexp : RegExp;

		
		//----------------------               Public Methods               ----------------------//
		public function DuplicateFieldValidator(field:IInput)
		{
			_field = field;
		}
		
		public override function execute(...args) : void
		{
			_didSucceed = _field.didSucceed() && _field.value() == _value;
			if (!_didSucceed)
			{
				_field.markAsInvalid();
			}
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