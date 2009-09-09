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

package reprise.controls
{
	import flash.events.MouseEvent;

	/**
	 * @author Marco
	 */
	public class LabelButton extends AbstractButton
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_labelDisplay : Label;
		protected var m_label : String = '';
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function LabelButton(label:String = null)
		{
			m_label = label || '';
		}
		
		/**
		 * sets the label to display
		 */
		public function setLabel(label:String) : void
		{
			m_label = label;
			if (!m_labelDisplay)
			{
				return;
			}
			m_labelDisplay.setLabel(label);
			invalidate();
		}
		
		public function getLabel() : String
		{
			var labelStr : String = m_labelDisplay.getLabel();
			return labelStr.substring(
				labelStr.indexOf(">") + 1, labelStr.lastIndexOf("<"));	
		}

		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function createChildren() : void
		{
			m_labelDisplay = Label(addComponent('label', null, Label));
			m_labelDisplay.label = m_label;
		}
		
		/**
		 * calculates the horizontal space taken by this elements' content
		 */
		protected override function calculateContentWidth() : int
		{
			if (m_currentStyles.display == 'inline')
			{
				return m_labelDisplay.width;
			}
			return super.calculateContentWidth();
		}
		
		protected override function applyStyles() : void
		{
			super.applyStyles();
			
			if (m_changedStyleProperties['selectable'])
			{
				m_labelDisplay.setStyle('selectable', String(m_currentStyles.selectable));
			}
			if (m_changedStyleProperties['cursor'])
			{
				m_labelDisplay.setStyle('cursor', m_currentStyles.cursor);
			}
			if (m_changedStyleProperties['textDecoration'])
			{
				m_labelDisplay.setStyle('textDecoration', m_currentStyles.textDecoration);
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