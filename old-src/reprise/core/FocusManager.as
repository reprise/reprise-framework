/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.core
{
	import reprise.ui.DocumentView;
	import reprise.ui.UIObject;
	import reprise.utils.DisplayListUtil;

	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	use namespace reprise;

	public class FocusManager
	{
		//----------------------             Public Properties              ----------------------//
		public static const FOCUS_METHOD_KEYBOARD : String = 'keyboard';
		public static const FOCUS_METHOD_MOUSE : String = 'mouse';
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _document : DocumentView;
		protected var _focus : UIObject;
		protected var _inFocusHandling : Boolean;
		protected var _lastTabPress : int;
		
		
		//----------------------               Public Methods               ----------------------//
		public function FocusManager(document : DocumentView)
		{
			_document = document;
			document.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, document_keyFocusChange);
			document.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, document_mouseFocusChange);
			document.addEventListener(FocusEvent.FOCUS_IN, document_focusIn);
			document.addEventListener(MouseEvent.MOUSE_DOWN, document_mouseDown);
		}
		
		/**
		 * Because of the entirely borked focus management of the Flash Player, we need to make 
		 * sure that we really, really get the focus under all conditions. As it turns out, in 
		 * certain cases, the player doesn't even dispatch a FOCUS_IN event for TextFields when 
		 * they are clicked.
		 * This method catches these cases.
		 */
		protected function document_mouseDown(event : MouseEvent) : void
		{
			var element : UIObject = DisplayListUtil.locateElementContainingDisplayObject(
				DisplayObject(event.target), true);
			if (element == _focus)
			{
				return;
			}
			setFocusedElement(element, FOCUS_METHOD_MOUSE);
		}

		reprise function setFocusedElement(element : UIObject, method : String) : Boolean
		{
			if (_focus && _focus == element)
			{
				return false;
			}
			if (_focus)
			{
				_focus.setFocus(false, method);
			}
			_focus = element;
			if (element && element.document == _document)
			{
				element.setFocus(true, method);
				return true;
			}
			//else
//			_document.stage.focus = null;
			_focus = null;
			return false;
		}
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function document_keyFocusChange(e:FocusEvent):void
		{
			if (_inFocusHandling)
			{
				return;
			}
			_inFocusHandling = true;
			if (e.keyCode == Keyboard.TAB && !e.isDefaultPrevented())
			{
				if (getTimer() - _lastTabPress < 15)
				{
					e.preventDefault();
					_inFocusHandling = false;
					return;
				}
				_lastTabPress = getTimer();
				var focusView:UIObject;
				if (e.shiftKey)
				{
					focusView = _focus != null
						? _focus.previousValidKeyView()
						: _document.previousValidKeyView();
				}
				else
				{
					focusView = _focus != null
						? _focus.nextValidKeyView()
						: _document.nextValidKeyView();
				}
				if (setFocusedElement(focusView, FOCUS_METHOD_KEYBOARD))
				{
		            e.preventDefault();
				}
	        }
			_inFocusHandling = false;
		}
		protected function document_mouseFocusChange(event : FocusEvent) : void
		{
			if (_inFocusHandling)
			{
				return;
			}
			_inFocusHandling = true;
			var element : DisplayObject = DisplayObject(event.relatedObject);
			var focusedElement : UIObject = DisplayListUtil.locateElementContainingDisplayObject(
				element, true);
			if (setFocusedElement(focusedElement, FOCUS_METHOD_MOUSE))
			{
				event.preventDefault();
			}
			_inFocusHandling = false;
		}
		
		protected function document_focusIn(event : FocusEvent) : void
		{
			if (_inFocusHandling)
			{
				return;
			}
			_inFocusHandling = true;
			var focusedElement : UIObject = DisplayListUtil.locateElementContainingDisplayObject(
				DisplayObject(event.target), true);
			if (_focus != focusedElement)
			{
				if (setFocusedElement(focusedElement, FOCUS_METHOD_MOUSE))
				{
					event.preventDefault();
				}
			}
			_inFocusHandling = false;
		}
	}
}
