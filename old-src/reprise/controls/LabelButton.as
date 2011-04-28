/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.controls
{
	import flash.events.MouseEvent;

	/**
	 * @author Marco
	 */
	public class LabelButton extends AbstractButton
	{
		//----------------------             Public Properties              ----------------------//
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _labelDisplay : Label;
		protected var _label : String = '';
		
		
		//----------------------               Public Methods               ----------------------//
		public function LabelButton(label:String = null)
		{
			_label = label || '';
		}
		
		/**
		 * sets the label to display
		 */
		public function setLabel(label:String) : void
		{
			_label = label;
			if (!_labelDisplay)
			{
				return;
			}
			_labelDisplay.setLabel(label);
			invalidate();
		}
		
		public function getLabel() : String
		{
			var labelStr : String = _labelDisplay.getLabel();
			return labelStr.substring(
				labelStr.indexOf(">") + 1, labelStr.lastIndexOf("<"));	
		}

		//----------------------         Private / Protected Methods        ----------------------//
		protected override function createChildren() : void
		{
			_labelDisplay = Label(addComponent('label', null, Label));
			_labelDisplay.label = _label;
		}
		
		/**
		 * calculates the horizontal space taken by this elements' content
		 */
		protected override function calculateContentWidth() : int
		{
			if (_currentStyles.display == 'inline')
			{
				return _labelDisplay.width;
			}
			return super.calculateContentWidth();
		}
		
		protected override function applyStyles() : void
		{
			super.applyStyles();
			
			if (_changedStyleProperties['cursor'])
			{
				_labelDisplay.setStyle('cursor', _currentStyles.cursor);
			}
			if (_changedStyleProperties['textDecoration'])
			{
				_labelDisplay.setStyle('textDecoration', _currentStyles.textDecoration);
			}
		}
		
		protected override function buttonDisplay_click(event : MouseEvent) : void
		{
			if (event.target != this)
			{
				event.stopImmediatePropagation();
				dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, mouseX, mouseY));
				return;
			}
			
			super.buttonDisplay_click(event);
		}
	}
}