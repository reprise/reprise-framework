/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.controls.html 
{
	import reprise.ui.AbstractInput;
	
	/**
	 * @author till
	 */
	public class HiddenInput extends AbstractInput
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected var m_value : *;
		
		
		//----------------------               Public Methods               ----------------------//
		public override function value() : *
		{
			return m_value;
		}
		public override function setValue(value : *) : void
		{
			m_value = value;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initDefaultStyles() : void
		{
			super.initDefaultStyles();
			m_elementDefaultStyles.setStyle('display', 'none');
		}
	}
}
