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

package reprise.data.validators 
{
	import reprise.commands.AbstractCommand;
	import reprise.controls.html.IInput;
	import reprise.data.IValidator;
	
	public class DuplicateFieldValidator extends AbstractCommand implements IValidator 
	{
		/***************************************************************************
		*                           Protected properties                           *
		***************************************************************************/
		protected var m_value : *;
		protected var m_field : IInput;
		protected var m_regexp : RegExp;

		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function DuplicateFieldValidator(field:IInput)
		{
			m_field = field;
		}
		
		public override function execute(...args) : void
		{
			m_didSucceed = m_field.value() == m_value;
			if (!m_didSucceed)
			{
				m_field.markAsInvalid();
			}
		}

		public function setValue(value : *) : void
		{
			m_value = value;
		}
		
		public function value() : *
		{
			return m_value;
		}
	}
}