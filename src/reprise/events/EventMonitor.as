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

package reprise.events
{ 
	import reprise.commands.TimeCommandExecutor;
	import reprise.core.GlobalMCManager;
	import reprise.css.propertyparsers.DisplayPosition;
	import reprise.data.collection.IndexedArray;
	import reprise.ui.UIComponent;
	import reprise.ui.UIObject;
	import reprise.ui.renderers.AbstractTooltip;
	import reprise.utils.Delegate;
	import reprise.utils.ProxyFunction;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.fscommand;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.getTimer;
	
	public class EventMonitor extends EventDispatcher
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected static var g_doubleClickTimeout:Number = 500;
		protected static var g_holderIdentifier:String = 'UIComponent';
		protected static var g_tooltipDisplayName:String = 'GLOBAL_TOOLTIP_DISPLAY';
		
		protected static var g_instance : EventMonitor;
		
		
		protected var m_stage : Stage;
		protected var m_dragClip : Sprite;
		protected var m_handCursorFaker : Sprite;
		
		protected var m_tooltip:AbstractTooltip;
		protected var m_tooltipDisplay:MovieClip;
		protected	var m_tooltipDelay:Delegate;
		
		protected var m_isMouseDown:Boolean;
		protected var m_lastMouseDownEvent:MouseEvent;
		protected	var m_lastMouseDownTime:Number;
		protected var m_lastMouseMoveEvent:MouseEvent;
		protected var m_clickCount:Number;
		protected var m_focus:UIObject;
		
		protected var m_recorders:IndexedArray; 
			
		protected var m_mouseIsOutsideSWF:Boolean = false;
		protected var m_mouseIsOutsideTimeout:Delegate;
	
	
	
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function instance(stage : Stage = null) : EventMonitor
		{
			if (!g_instance)
			{
				g_instance = new EventMonitor(stage);
			}
			return g_instance;
		}
	
		public function trackKeyEvents():void
		{
			Keyboard.addListener(this);
		}	
		public function stopTrackKeyEvents():void
		{
			Keyboard.removeListener(this);
		}
		
		public function focus():UIObject
		{
			return m_focus;
		}
		
		public function setFocus(newFocus:UIObject):void
		{
			if (newFocus == m_focus)
			{
				return;
			}
			
			if (!newFocus.canBecomeKeyView())
			{
				newFocus = null;
			}
	
			var oldFocus:UIObject = m_focus;
			m_focus = newFocus;		
			if (oldFocus != null)
			{
				var focusOutEvent:FocusEvent = 
					buildFocusEvent(FocusEvent.FOCUS_OUT, oldFocus, newFocus);
				oldFocus.dispatchEvent(focusOutEvent);
				dispatchEvent(focusOutEvent);
				recordFocusEvent(focusOutEvent);
			}
					
			if (newFocus != null)
			{
				var focusInEvent:FocusEvent = 
					buildFocusEvent(FocusEvent.FOCUS_IN, newFocus, oldFocus);
				newFocus.dispatchEvent(focusInEvent);
				dispatchEvent(focusInEvent);
				recordFocusEvent(focusInEvent);
			}
		}
		
//		public function addRecorder(recorder:IEventRecorder) : void
//		{
//			if (!m_recorders)
//			{
//				m_recorders = new IndexedArray();
//			}
//			m_recorders.push(recorder);
//		}
//		
//		public function removeRecorder(recorder:IEventRecorder) : void
//		{
//			m_recorders.remove(recorder);
//		}
		
		// IFrameEventListener
		public function enterFrame() : void
		{
			validateAfterMouseMove();
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function EventMonitor(stage : Stage)
		{
			//TODO: add some singleton technique here
			m_stage = stage;
			m_dragClip = GlobalMCManager.instance().addHighLevelMc();
			m_handCursorFaker = GlobalMCManager.instance().addLowLevelMc();
	
			// Away with FlashPlayer focusmanagement
			_global.focusRect = false;
			MovieClip.prototype.focusEnabled = false;
			MovieClip.prototype.tabEnabled = false;
			MovieClip.prototype.focusRect = false;
			
			//detect and re-route MovieClip::startDrag and MovieClip::stopDrag
			MovieClip.prototype.$_startDrag = MovieClip.prototype.startDrag;
			MovieClip.prototype.startDrag = emulateStartDrag;
			MovieClip.prototype.$_stopDrag = MovieClip.prototype.stopDrag;
			MovieClip.prototype.stopDrag = emulateStopDrag;
			
			Stage.addListener(this);
			m_handCursorFaker.onRelease = function() {};
			m_handCursorFaker.onRollOut = ProxyFunction.create(this, handCursorFaker_rollOut);
			m_handCursorFaker.onRollOver = ProxyFunction.create(this, handCursorFaker_rollOver);
			onResize();
			
			m_focus = null;
			m_isMouseDown = false;
			m_lastMouseDownEvent = null;
			m_lastMouseDownTime = null;
			m_lastMouseMoveEvent = null;
			m_tooltipDisplay = null;
			m_tooltip = null;
			m_tooltipDelay = null;
			
			FrameEventBroadcaster.instance().addFrameListener(this);
		}
		
		
		/**
		* Mouse listener
		**/	
		protected function onMouseDown():void
		{
			killMouseLeftSWFTimeout();
			m_isMouseDown = true;
			var display:MovieClip = findDropTarget(String(m_dragClip.dropTarget));
			var holder:UIObject = m_mouseIsOutsideSWF ? null : UIObject(display[g_holderIdentifier]);
			
			if (holder != null)
			{
				// send mousedown event to holder
				var pressEvent:MouseEvent = buildMouseEvent(MouseEvent.PRESS, null, holder);
				var mouseDownEvent:MouseEvent = buildMouseEvent(MouseEvent.MOUSE_DOWN, display, holder);
				bubbleMouseButtonEventManually(pressEvent, holder);
				recordMouseEvent(pressEvent);
				holder.dispatchEvent(mouseDownEvent);
				dispatchEvent(mouseDownEvent);
				recordMouseEvent(mouseDownEvent);
				
				// be prepared for doubleclicks
				var timeDif:Number = getTimer() - m_lastMouseDownTime;
				if (m_lastMouseDownEvent.target == holder &&
					timeDif <= g_doubleClickTimeout)
				{
					m_clickCount++;
				}
				else
				{
					m_clickCount = 1;
				}
				m_lastMouseDownTime = getTimer();
				m_lastMouseDownEvent = mouseDownEvent.clone();
			}
			else
			{
				m_lastMouseDownEvent = null;
				m_clickCount = 0;
			}
			// handle focus
			setFocus(holder);
		}
		
		protected function onMouseUp():void
		{
			killMouseLeftSWFTimeout();
			m_isMouseDown = false;
			var display:MovieClip = findDropTarget(String(m_dragClip.dropTarget));
			var holder:UIObject = m_mouseIsOutsideSWF ? null : UIObject(display[g_holderIdentifier]);
	
			// mouseup			
			var mouseUpEvent:MouseEvent = 
				buildMouseEvent(MouseEvent.MOUSE_UP, display, holder);		
			if (holder)
			{
				holder.dispatchEvent(mouseUpEvent);
				dispatchEvent(mouseUpEvent);
				recordMouseEvent(mouseUpEvent);
				
				// click or doubleclick
				if (m_lastMouseDownEvent != null && holder != null && 
					m_lastMouseDownEvent.target == holder)
				{
					var timeDif:Number = getTimer() - m_lastMouseDownTime;
					var eventType:String;
					var mouseEvent:MouseEvent;
					m_lastMouseDownTime = getTimer();
								
					if (timeDif <= g_doubleClickTimeout && m_clickCount == 2)
					{
						eventType = MouseEvent.DOUBLE_CLICK;
						m_clickCount = 0;
					}
					else
					{
						eventType = MouseEvent.CLICK;
					}
							
					mouseEvent = buildMouseEvent(eventType, display, holder);
					holder.dispatchEvent(mouseEvent);
					dispatchEvent(mouseEvent);
					recordMouseEvent(mouseEvent);
					return;
				}
			}
			else
			{
				dispatchEvent(mouseUpEvent);			
			}
			
			// release outside
			if (m_lastMouseDownEvent != null)
			{
				var releaseOutsideEvent:MouseEvent = 
					buildMouseEvent(MouseEvent.RELEASE_OUTSIDE, 
					null, UIObject(m_lastMouseDownEvent.target));	
				bubbleMouseButtonEventManually(releaseOutsideEvent, 
					UIObject(m_lastMouseDownEvent.target));
				recordMouseEvent(releaseOutsideEvent);
				
				var mouseUpOutsideEvent:MouseEvent = 
					buildMouseEvent(MouseEvent.MOUSE_UP_OUTSIDE, 
					display, UIObject(m_lastMouseDownEvent.target));
				UIObject(m_lastMouseDownEvent.target).
					dispatchEvent(mouseUpOutsideEvent);
				dispatchEvent(mouseUpOutsideEvent);
				recordMouseEvent(mouseUpOutsideEvent);
			}
		}
		
		protected function onMouseMove() : void
		{
			killMouseLeftSWFTimeout();
			validateAfterMouseMove();
		}
		
		protected function validateAfterMouseMove():void
		{
			m_dragClip.$_stopDrag();
			m_dragClip.$_startDrag(false);
					
			var display:MovieClip = findDropTarget(String(m_dragClip.dropTarget));
			var holder:UIObject = m_mouseIsOutsideSWF ? null : UIObject(display[g_holderIdentifier]);
			var mouseMoveEvent:MouseEvent;
			
			// mouse move
			if (holder != null)
			{
				mouseMoveEvent = buildMouseEvent(MouseEvent.MOUSE_MOVE, display, holder);
				holder.dispatchEvent(mouseMoveEvent);
				dispatchEvent(mouseMoveEvent);
				m_handCursorFaker.useHandCursor = holder.useHandCursor || 
					UIComponent(holder).style.cursor == DisplayPosition.CURSOR_POINTER;
			}
			else
			{
				m_handCursorFaker.useHandCursor = false;
				hideTooltip();
			}
	
			// object under the mouse is still the same, we're done
			if ((holder == m_lastMouseMoveEvent.target && m_lastMouseMoveEvent != null))
			{
				updateTooltipPosition();
				return;
			}
			
			if (m_lastMouseMoveEvent != null && m_lastMouseMoveEvent.target != holder)
			{
				// we have a new object under our cursor
				// rollover and rollout go first	
				var rollOutEvent:MouseEvent = buildMouseEvent(MouseEvent.ROLL_OUT, null, 
					UIObject(m_lastMouseMoveEvent.target));
				var mouseOutEvent:MouseEvent = buildMouseEvent(MouseEvent.MOUSE_OUT, null, 
					UIObject(m_lastMouseMoveEvent.target));			
				bubbleMouseButtonEventManually(rollOutEvent, UIObject(m_lastMouseMoveEvent.target), holder);
				UIObject(m_lastMouseMoveEvent.target).dispatchEvent(mouseOutEvent);
				dispatchEvent(mouseOutEvent);
				recordMouseEvent(rollOutEvent);
				recordMouseEvent(mouseOutEvent);
			}
			
			if (holder != null)
			{
				var rollOverEvent:MouseEvent = buildMouseEvent(MouseEvent.ROLL_OVER, display, holder);
				var mouseOverEvent:MouseEvent = buildMouseEvent(MouseEvent.MOUSE_OVER, display, holder);
				// bubble mouseover event
				// rollover and rollout go first
				bubbleMouseButtonEventManually(rollOverEvent, holder, UIObject(m_lastMouseMoveEvent.target));
				holder.dispatchEvent(mouseOverEvent);
				dispatchEvent(mouseOverEvent);
				recordMouseEvent(rollOverEvent);
				recordMouseEvent(mouseOverEvent);
				showTooltipForElement(holder);
				
				m_lastMouseMoveEvent = mouseMoveEvent.clone();
			}
			else
			{
				m_lastMouseMoveEvent = null;
			}
		}		
		
		protected function onMouseWheel(delta:Number):void
		{
			killMouseLeftSWFTimeout();
			var display:MovieClip = findDropTarget(String(m_dragClip.dropTarget));
			var holder:UIObject = UIObject(display[g_holderIdentifier]);
	
			holder.dispatchEvent(buildMouseEvent(MouseEvent.MOUSE_WHEEL, display, holder, delta));
			dispatchEvent(buildMouseEvent(MouseEvent.MOUSE_WHEEL, display, holder, delta));
		}	
		
		/**
		* Keyboard listener
		**/
		protected function onKeyUp():void
		{
			var keyUpEvent:KeyboardEvent = buildKeyboardEvent(KeyboardEvent.KEY_UP, m_focus, null, null);
			m_focus.dispatchEvent(keyUpEvent);
			dispatchEvent(keyUpEvent);
			recordKeyboardEvent(keyUpEvent);
		}
		
		protected function onKeyDown():void
		{
			if (Keyboard.getCode() == Keyboard.TAB)
			{
				if (Keyboard.isDown(Keyboard.SHIFT))
				{
					setFocus(previousKeyView());
				}
				else
				{
					setFocus(nextKeyView());
				}
				return;
			}
	
			var keyDownEvent:KeyboardEvent = buildKeyboardEvent(KeyboardEvent.KEY_DOWN, m_focus, 
				Keyboard.getCode(), Keyboard.getAscii());
			m_focus.dispatchEvent(keyDownEvent);
			dispatchEvent(keyDownEvent);
			recordKeyboardEvent(keyDownEvent);
		}
		
		/**
		* Focus listener
		**/
		protected function onSetFocus(oldFocus:Object, newFocus:Object):void
		{
			
		}
		
		
		/**
		* Stage listener
		**/	
		protected function onResize():void
		{		
			m_handCursorFaker.x = m_handCursorFaker.y = 0;
			m_handCursorFaker.graphics.clear();
			m_handCursorFaker.graphics.beginFill(0x000000, 0);
			m_handCursorFaker.graphics.lineTo(stage.stageWidth, 0);
			m_handCursorFaker.graphics.lineTo(stage.stageWidth, stage.stageHeight);
			m_handCursorFaker.graphics.lineTo(0, stage.stageHeight);
			m_handCursorFaker.graphics.lineTo(0, 0);
			m_handCursorFaker.graphics.endFill();
		}
		
		
		
		/**
		* placeholder functions for integrating recorders in the future
		**/
		protected function recordMouseEvent(mouseEvent:MouseEvent):void
		{
			var i : Number = m_recorders.length;
			if (i > 0)
			{
				mouseEvent = mouseEvent.clone();
				while (i--)
				{
//					IEventRecorder(m_recorders[i]).recordMouseEvent(mouseEvent);
				}
			}
		}
		
		protected function recordKeyboardEvent(keyboardEvent:KeyboardEvent):void
		{
			var i : Number = m_recorders.length;
			if (i > 0)
			{
				keyboardEvent = keyboardEvent.clone();
				while (i--)
				{
//					IEventRecorder(m_recorders[i]).recordKeyboardEvent(keyboardEvent);
				}
			}
		}
		
		protected function recordFocusEvent(focusEvent:FocusEvent):void
		{
			var i : Number = m_recorders.length;
			if (i > 0)
			{
				focusEvent = focusEvent.clone();
				while (i--)
				{
					IEventRecorder(m_recorders[i]).recordFocusEvent(focusEvent);
				}
			}
		}
		
		
		
		protected function handCursorFaker_rollOver() : void
		{
			m_mouseIsOutsideSWF = false;
			killMouseLeftSWFTimeout();
		}
		
		protected function handCursorFaker_rollOut() : void
		{
			killMouseLeftSWFTimeout();
			m_mouseIsOutsideTimeout = new Delegate(this, timeout_mouseLeftSWF);
			TimeCommandExecutor.instance().delayCommand(m_mouseIsOutsideTimeout, 500);
		}
		
		protected function killMouseLeftSWFTimeout() : void
		{
			if (m_mouseIsOutsideTimeout == null)
			{
				return;
			}
			TimeCommandExecutor.instance().removeCommand(m_mouseIsOutsideTimeout);
			m_mouseIsOutsideTimeout = null;
		}
		
		protected function timeout_mouseLeftSWF() : void
		{
			m_mouseIsOutsideSWF = true;
			validateAfterMouseMove();		
		}
		
		
		
		/**
		* Tooltip management
		**/
		protected function createTooltipDisplay():void
		{
			if (m_tooltipDisplay != null)
			{
				return;
			}
			m_tooltipDisplay = GlobalMCManager.instance().addHighLevelMc(g_tooltipDisplayName);
		}
		
		protected function showTooltipForElement(elem:UIObject):void
		{
			var rootElem:UIObject = elem;
			elem = findElementWithTooltip(elem);
			var tooltipData:Object = elem.tooltipData();
			var tooltipRenderer:String = elem.tooltipRenderer();
	
			if (tooltipData == null)
			{
				hideTooltip();
				return;
			}
	
			if (m_tooltipDelay != null)
			{
				TimeCommandExecutor.instance().removeCommand(m_tooltipDelay);
				m_tooltipDelay = null;			
			}
			
			if (elem.tooltipDelay() > 0)
			{
				m_tooltipDelay = new Delegate(this, showTooltipWithDataAndRendererForElement, 
					[tooltipData, tooltipRenderer, rootElem, elem]);
				TimeCommandExecutor.instance().delayCommand(m_tooltipDelay, elem.tooltipDelay());
			}
			else
			{
				showTooltipWithDataAndRendererForElement(tooltipData, tooltipRenderer, rootElem, elem);
			}
		}
		
		protected function showTooltipWithDataAndRendererForElement(
			data:Object, renderer:String, 
			target:UIObject, dataSupplyTarget:UIObject):void
		{
			createTooltipDisplay();
			var cssClassName:String = renderer == null ? 'default' : renderer;
			
			if (m_tooltip == null || cssClassName != m_tooltip.cssClasses)
			{
				removeTooltip();
				m_tooltip = target.document.
					uiRendererFactory().tooltipRendererById(renderer);
				m_tooltip.addEventListener(DisplayEvent.HIDE_COMPLETE, 
				 removeTooltip);
				m_tooltip.addEventListener(DisplayEvent.REMOVE, 
				 hideTooltip);
				m_tooltipDisplay.g_holderIdentifier = m_tooltip;
				m_tooltip.setParent(target.document);
				m_tooltip.setDisplay(m_tooltipDisplay, 0);
				m_tooltip.cssId = 'Tooltip';
			}
	
			m_tooltip.setDataSupplyTarget(dataSupplyTarget);
			m_tooltip.setTarget(target);
			m_tooltip.cssClasses = cssClassName;
			m_tooltip.setData(data);
			m_tooltip.forceRedraw();
			m_tooltip.show();
			updateTooltipPosition();		
		}
		
		protected function updateTooltipPosition():void
		{
			m_tooltip.updatePosition();
		}
		
		protected function hideTooltip():void
		{
			if (m_tooltipDelay != null)
			{
				TimeCommandExecutor.instance().removeCommand(m_tooltipDelay);
				m_tooltipDelay = null;
			}		
			m_tooltip.hide();
		}
	
	
		protected function findElementWithTooltip(parentElement:UIObject):UIObject
		{
			while (parentElement != null)
			{
				if (parentElement.tooltipData() != null)
				{
					return parentElement;
				}
				parentElement = parentElement['m_parentElement'];
			}
			return null;
		}
		
		protected function removeTooltip(e:DisplayEvent):void
		{
			var tooltip:UIObject;
			if (m_tooltip != null)
			{
				tooltip = m_tooltip;
			}
			if (e.target != null)
			{
				tooltip = UIObject(e.target);
			}
			
			if (tooltip == null)
			{
				return;
			}
	
			tooltip.remove();
			
			if (tooltip == m_tooltip)
			{
				m_tooltip = null;
			}
		}	
		
		
		
	
		protected function nextKeyView():UIObject
		{
			var base:UIObject = m_focus != null ? m_focus:m_focus.document;
			return base.nextValidKeyView();
		}
		
		protected function previousKeyView():UIObject
		{
			var base:UIObject = m_focus != null ? m_focus:m_focus.document;
			return base.previousValidKeyView();
		}
		
		protected function bubbleMouseButtonEventManually(
			event:MouseEvent, dispatchable:UIObject, endObject:UIObject):void
		{
			var endTarget : String = endObject['m_display']._target;
			var currentTarget : String = dispatchable['m_display']._target;
	
			event.bubbles = false;		
			while (dispatchable && dispatchable != endObject && 
				endTarget.indexOf(currentTarget) != 0)
			{
				event.target = dispatchable;
				//TODO: won't work!
				event.currentTarget = dispatchable;
				dispatchable.dispatchEvent(event);
				dispatchable = UIObject(dispatchable.getDispatcherParent());
				// we're picky and root views don't receive our events
				currentTarget = dispatchable['m_display']._target;
				if (dispatchable == dispatchable['m_rootElement'])
				{
					return;
				}
			}
		}
		
		protected function findDropTarget(target:String):MovieClip
		{
			if (target.indexOf(g_tooltipDisplayName) != -1)
			{
				if (m_tooltip.target()['m_display'].hitTest(_root.mouseX, _root.mouseY) &&
					m_tooltip.target() != null && m_tooltip.target().getVisibility())
					return m_tooltip.target()['m_display'];
				return null;
			}
			
			var display:MovieClip = eval(target);
			if (display[g_holderIdentifier] is UIObject)
			{
				return display;
			}
			var i:Number;
			var parts:Array = target.split('/');
			parts.pop();
			while (parts.length)
			{
				display = eval(parts.join('/'));
				if (display[g_holderIdentifier] is UIObject)
				{
					return display;
				}
				parts.pop();
			}
			return null;
		}
		
		protected function buildMouseEvent(type:String, target:MovieClip, 
			assignedComponent:UIObject, delta:Number):MouseEvent
		{
			var event:MouseEvent = new MouseEvent(type, true);
			event.target = assignedComponent;
			event.buttonDown = m_isMouseDown;
			event.localX = target.mouseX;
			event.localY = target.mouseY;
			event.stageX = _root.mouseX;
			event.stageY = _root.mouseY;
			event.delta = delta == null ? 0:delta;
			event.ctrlKey = Key.isDown(Keyboard.CONTROL);
			event.altKey = Key.isDown(Keyboard.ALT);
			event.shiftKey = Key.isDown(Keyboard.SHIFT);
			event.timestamp = (new Date()).getTime();
			return event;
		}
		
		protected function buildKeyboardEvent(type:String, assignedComponent:UIObject, 
			keyCode:Number, asciiCode:Number):KeyboardEvent
		{
			var event:KeyboardEvent = new KeyboardEvent(type, true);
			event.target = assignedComponent;
			event.ctrlKey = Key.isDown(Keyboard.CONTROL);
			event.altKey = Key.isDown(Keyboard.ALT);
			event.shiftKey = Key.isDown(Keyboard.SHIFT);
			event.keyCode = keyCode;
			event.charCode = asciiCode;
			event.timestamp = (new Date()).getTime();		
			return event;
		}
		
		protected function buildFocusEvent(type:String, assignedComponent:UIObject, 
			oldFocus:UIObject):FocusEvent
		{
			var event:FocusEvent = new FocusEvent(type, true);
			event.target = assignedComponent;
			event.relatedObject = oldFocus;
			event.shiftKey = Key.isDown(Keyboard.SHIFT);
			event.keyCode = null;
			event.timestamp = (new Date()).getTime();
			return event;
		}
		
		
		protected function emulateStartDrag(lockCenter:Boolean, 
			left:Number, top:Number, right:Number, bottom:Number) : void
		{
			var clip:MovieClip = MovieClip(this);
			if (lockCenter)
			{
				clip.x = clip.parent.mouseX;
				clip.y = clip.parent.mouseY;
			}
			var mouseOffsetX:Number = clip.mouseX;
			var mouseOffsetY:Number = clip.mouseY;
			clip.onMouseMove = function()
			{
				var x:Number = clip.parent.mouseX - mouseOffsetX;
				var y:Number = clip.parent.mouseY - mouseOffsetY;
				clip.x = left > x ? left : right < x ? right : x;
				clip.y = top > y ? top : bottom < y ? bottom : y;
			};
		}
		protected function emulateStopDrag() : void
		{
			var clip:MovieClip = MovieClip(this);
			delete clip.onMouseMove;
		}
	}
}