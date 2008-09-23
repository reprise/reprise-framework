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
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import reprise.events.MouseEventConstants;
	import reprise.ui.AbstractInput;
	import reprise.ui.DocumentView;
	import reprise.ui.UIComponent; 

	public class AbstractButton extends AbstractInput
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_isToggleButton : Boolean = false;
		protected var m_currentState : String;
	
		protected var m_selected : Boolean = false;
		protected var m_enabled : Boolean = true;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		/**
		 * setter for the isToggleButton property
		 */
		public function set isToggleButton(value:Boolean) : void
		{
			m_isToggleButton = value;
		}
		
		/**
		 * getter for the isToggleButton property
		 */
		public function get isToggleButton() : Boolean
		{
			return m_isToggleButton;
		}
		
		/**
		 * sets the buttons' current state
		 * 
		 * @param state can be one of STATE_ACTIVE and STATE_INACTIVE
		 */
		public function set selected(value:Boolean) : void
		{
			if (value == m_selected)
			{
				return;
			}
			if (value)
			{
				activate();
			}
			else
			{
				deactivate();
			}
		}
		/**
		 * returns the buttons' current state
		 * 
		 * @return state can be one of STATE_ACTIVE and STATE_INACTIVE
		 */
		public function get selected() : Boolean
		{
			return m_selected;
		}
		
		
		/**
		 * disables the button and sets the appropriate format
		 */
		public function set enabled(value:Boolean) : void
		{
			//TODO: add proper handling of enabled property
			if (value == m_enabled)
			{
				return;
			}
			m_enabled = value;
			if (!value)
			{
				addPseudoClass("disabled");
				removePseudoClass("hover");
				removePseudoClass("down");
			}
			else
			{
				removePseudoClass("disabled");
			}
//			m_buttonDisplay.enabled = value;
			invalidate();
		}
		
		public function get enabled() : Boolean
		{
			return m_enabled;
		}
		
		public override function value():*
		{
			return selected;
		}
		
		public override function setValue(value:*):void
		{
			selected = Boolean(value);
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function AbstractButton()
		{
		}
		
		protected override function initialize() : void
		{
			super.initialize();
			
			m_canBecomeKeyView = true;
			
			initializeButtonHandlers();
		}
		protected function initializeButtonHandlers() : void
		{
			addEventListener(MouseEvent.MOUSE_OVER, buttonDisplay_over);
			addEventListener(MouseEvent.MOUSE_OUT, buttonDisplay_out);
			addEventListener(MouseEvent.MOUSE_DOWN, buttonDisplay_down);
			addEventListener(MouseEvent.CLICK, buttonDisplay_click);
		}
		
		protected function activate() : void
		{
			addPseudoClass("checked");
			m_selected = true;
		}
		
		protected function deactivate() : void
		{
			removePseudoClass("checked");
			m_selected = false;
		}
		
		protected override function handleKeyEvent(event : KeyboardEvent) : Boolean
		{
			switch(event.keyCode)
			{
				case Keyboard.SPACE:
				{
					dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					return true;
				}
				default:
				{
					return false;
				}
			}
		}
		
		protected function buttonDisplay_over(event : MouseEvent) : void
		{
			log('button: ' + this);
			if (m_enabled)
			{
				addPseudoClass("hover");
			}
		}
		protected function buttonDisplay_out(event : MouseEvent) : void
		{
			removePseudoClass("hover");
		}
		protected function buttonDisplay_down(event : MouseEvent) : void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, buttonDisplay_up);
			if (m_enabled)
			{
				addPseudoClass("active");
			}
		}
		protected function buttonDisplay_up(event : MouseEvent) : void
		{
			removePseudoClass("active");
			if (!(event.target == this || contains(DisplayObject(event.target))))
			{
		        dispatchEvent(new MouseEvent(MouseEventConstants.MOUSE_UP_OUTSIDE));
		    }
		}
		protected function buttonDisplay_click(event : MouseEvent) : void
		{
			if (m_enabled)
			{
				removeErrorMark();
			}
			if (m_canBecomeKeyView)
			{
				m_rootElement.setFocusedElement(this, DocumentView.FOCUS_METHOD_MOUSE);
			}
			
			if(isToggleButton)
			{
				if(selected)
				{
					selected = false;
				}
				else
				{
					selected = true;	
				}
			}
		}
	}
}