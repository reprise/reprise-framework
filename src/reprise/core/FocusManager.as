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

package reprise.core
{
	import reprise.utils.DisplayListUtil;
	import reprise.ui.DocumentView;
	import reprise.ui.UIObject;

	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	use namespace reprise;

	public class FocusManager
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const FOCUS_METHOD_KEYBOARD : String = 'keyboard';
		public static const FOCUS_METHOD_MOUSE : String = 'mouse';
		
		
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_document : DocumentView;
		protected var m_focus : UIObject;
		protected var m_inFocusHandling : Boolean;
		protected var m_lastTabPress : int;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function FocusManager(document : DocumentView)
		{
			m_document = document;
			document.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, self_keyFocusChange);
			document.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, self_mouseFocusChange);
			document.addEventListener(FocusEvent.FOCUS_IN, self_focusIn);
		}
		
		reprise function setFocusedElement(element : UIObject, method : String) : Boolean
		{
			if (m_focus && m_focus == element)
			{
				return false;
			}
			if (m_focus)
			{
				m_focus.setFocus(false, method);
			}
			m_focus = element;
			if (element && element.document == m_document)
			{
				m_document.stage.focus = element;
				element.setFocus(true, method);
				return true;
			}
			return false;
		}
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected function self_keyFocusChange(e:FocusEvent):void
		{
			if (m_inFocusHandling)
			{
				return;
			}
			m_inFocusHandling = true;
			if (e.keyCode == Keyboard.TAB && !e.isDefaultPrevented())
			{
				if (getTimer() - m_lastTabPress < 15)
				{
					e.preventDefault();
					m_inFocusHandling = false;
					return;
				}
				m_lastTabPress = getTimer();
				var focusView:UIObject;
				if (e.shiftKey)
				{
					focusView = m_focus != null 
						? m_focus.previousValidKeyView() 
						: m_document.previousValidKeyView();
				}
				else
				{
					focusView = m_focus != null 
						? m_focus.nextValidKeyView() 
						: m_document.nextValidKeyView();
				}
				if (setFocusedElement(focusView, FOCUS_METHOD_KEYBOARD))
				{
		            e.preventDefault();
				}
	        }
			m_inFocusHandling = false;
		}
		protected function self_mouseFocusChange(event : FocusEvent) : void
		{
			if (m_inFocusHandling)
			{
				return;
			}
			m_inFocusHandling = true;
			var element : DisplayObject = DisplayObject(event.relatedObject);
			while (element && !(element is UIObject))
			{
				element = element.parent;
			}
			if (setFocusedElement(element as UIObject, FOCUS_METHOD_MOUSE))
			{
				event.preventDefault();
			}
			m_inFocusHandling = false;
		}
		
		protected function self_focusIn(event : FocusEvent) : void
		{
			if (m_inFocusHandling)
			{
				return;
			}
			m_inFocusHandling = true;
			var focusedElement : UIObject = DisplayListUtil.locateElementContainingDisplayObject(
				DisplayObject(event.target), true);
			if (m_focus != focusedElement)
			{
				if (setFocusedElement(focusedElement, FOCUS_METHOD_MOUSE))
				{
					event.preventDefault();
				}
			}
			m_inFocusHandling = false;
		}
	}
}
