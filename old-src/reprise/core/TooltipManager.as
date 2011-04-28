/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.core
{
	import reprise.commands.TimeCommandExecutor;
	import reprise.events.DisplayEvent;
	import reprise.ui.DocumentView;
	import reprise.ui.UIComponent;
	import reprise.ui.UIObject;
	import reprise.ui.renderers.AbstractTooltip;
	import reprise.utils.Delegate;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class TooltipManager
	{
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static const TOOLTIP_SHOW_ANIMATION:uint = 1;
		protected static const TOOLTIP_VISIBLE:uint = 2;
		protected static const TOOLTIP_HIDE_ANIMATION:uint = 3;
		protected static const TOOLTIP_INVISIBLE:uint = 4;
		
		protected var _tooltipState:uint = TOOLTIP_INVISIBLE;
		
		protected var _rootView:DocumentView;
		protected var _tooltipContainer:Sprite;
		protected var _tooltipDelay:Delegate;
		protected var _tooltip:AbstractTooltip;
		protected var _lastMousedElement:DisplayObject;
		protected var _lastTooltipDataProvider:UIObject;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function TooltipManager(rootView:DocumentView, container : Sprite)
		{
			_rootView = rootView;
			_rootView.addEventListener(MouseEvent.MOUSE_OVER, rootView_mouseOver);
			_rootView.addEventListener(MouseEvent.MOUSE_OUT, rootView_mouseOut);
			
			_tooltipContainer = container;
			_tooltipContainer.mouseEnabled = false;
			_tooltipContainer.mouseChildren = false;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function rootView_mouseOver(e:MouseEvent):void
		{
			updateTooltipForElement(DisplayObject(e.target));
		}
		
		protected function rootView_mouseOut(e:MouseEvent):void
		{
			hideTooltip();
		}
		
		protected function updateTooltipForElement(mousedElement:DisplayObject):void
		{
			var element:UIObject = findTooltipDataProviderForElement(mousedElement);
			
			var currentTooltipData:Object = _tooltip ? _tooltip.data() : null;
			var newTooltipData:Object = element ? element.tooltipData() : null;
			
			// nothing changed
			if (element == _lastTooltipDataProvider &&
				currentTooltipData == newTooltipData)
			{
				if ((_tooltipState == TOOLTIP_HIDE_ANIMATION ||
					_tooltipState == TOOLTIP_INVISIBLE) && newTooltipData != null)
				{
					_tooltip.show();
					_tooltipState = TOOLTIP_SHOW_ANIMATION;
				}
				return;
			}
			
			if (_lastTooltipDataProvider)
			{
				_lastTooltipDataProvider.removeEventListener(DisplayEvent.TOOLTIPDATA_CHANGED,
					mousedElement_tooltipDataChanged);
			}
			
			if (element)
			{
				element.addEventListener(DisplayEvent.TOOLTIPDATA_CHANGED,
					mousedElement_tooltipDataChanged);
			}
			
			_lastMousedElement = mousedElement;
			_lastTooltipDataProvider = element;

			if (element == null && _tooltip)
			{
				_tooltip.setMousedElement(null);
				_tooltip.setTooltipDataProvider(null);
				_tooltip.setMousedComponent(null);
			}
			if (element == null || element.tooltipData() == null)
			{
				hideTooltip();
				return;
			}

			var tooltipData:Object = element.tooltipData();
			var tooltipRenderer:String = element.tooltipRenderer();
			
			if (_tooltipDelay != null)
			{
				TimeCommandExecutor.instance().removeCommand(_tooltipDelay);
				_tooltipDelay = null;
			}
			
			if (element.tooltipDelay() > 0 && _tooltipState == TOOLTIP_INVISIBLE)
			{
				_tooltipDelay = new Delegate(this, showTooltipWithDataAndRendererForElement,
					[tooltipData, tooltipRenderer, mousedElement, element]);
				TimeCommandExecutor.instance().delayCommand(_tooltipDelay, element.tooltipDelay());
			}
			else
			{
				showTooltipWithDataAndRendererForElement(tooltipData, tooltipRenderer, 
					mousedElement, element);
			}
		}
		
		protected function findTooltipDataProviderForElement(element:DisplayObject):UIObject
		{
			while (element != null)
			{
				if (element is UIObject && UIObject(element).tooltipData() != null)
				{
					return UIObject(element);
				}
				element = element.parent;
			}
			return null;
		}
		
		protected function findComponentForMousedElement(element:DisplayObject):UIComponent
		{
			while (element != null)
			{
				if (element is UIComponent)
				{
					return UIComponent(element);
				}
				element = element.parent;
			}
			return null;
		}
		
		protected function showTooltipWithDataAndRendererForElement(data:Object, renderer:String, 
			mousedElement:DisplayObject, tooltipDataProvider:UIObject, delegate:Delegate=null):void
		{
			var cssClassName:String = renderer == null ? 'default' : renderer;
			
			if (_tooltip == null || !_tooltip.hasCSSClass(cssClassName))
			{
				removeTooltip();
				_tooltip = tooltipDataProvider.document.uiRendererFactory().
					tooltipRendererById(renderer);
				_tooltipContainer.addChild(_tooltip);
				_tooltip.setParent(tooltipDataProvider.document);
				_tooltip.cssID = 'Tooltip';
				_tooltip.mouseEnabled = _tooltip.mouseChildren = false;
				_tooltip.addEventListener(DisplayEvent.SHOW_COMPLETE, tooltip_showComplete);
				_tooltip.addEventListener(DisplayEvent.HIDE_COMPLETE, tooltip_hideComplete);
				_rootView.addEventListener(Event.ENTER_FRAME, rootView_enterFrame);
			}
			_tooltip.setTooltipDataProvider(tooltipDataProvider);
			_tooltip.setMousedElement(mousedElement);
			_tooltip.setMousedComponent(findComponentForMousedElement(mousedElement));
			_tooltip.addCSSClass(cssClassName);
			_tooltip.setData(data);
			_tooltip.forceRedraw();
			updateTooltipPosition();
			
			if (_tooltipState != TOOLTIP_VISIBLE && _tooltipState != TOOLTIP_SHOW_ANIMATION)
			{
				_tooltip.show();
				_tooltipState = TOOLTIP_SHOW_ANIMATION;
			}
		}
		
		protected function hideTooltip():void
		{
			if (_tooltipState == TOOLTIP_INVISIBLE || _tooltipState == TOOLTIP_HIDE_ANIMATION)
			{
				return;
			}
			if (_tooltipDelay != null)
			{
				TimeCommandExecutor.instance().removeCommand(_tooltipDelay);
				_tooltipDelay = null;
			}
			_tooltipState = TOOLTIP_HIDE_ANIMATION;
			_tooltip.hide();
		}

		protected function updateTooltipPosition():void
		{
			if (!_tooltip) return;
			_tooltip.updatePosition();
		}
		
		protected function removeTooltip(tooltip:AbstractTooltip = null):void
		{
			if (!tooltip)
			{
				tooltip = _tooltip;
			}
			if (!tooltip)
			{
				return;
			}
			tooltip.removeEventListener(DisplayEvent.HIDE_COMPLETE, tooltip_hideComplete);
			tooltip.removeEventListener(DisplayEvent.SHOW_COMPLETE, tooltip_showComplete);
			tooltip.remove();
			_tooltipState = TOOLTIP_INVISIBLE;
			
			if (tooltip == _tooltip)
			{
				_rootView.removeEventListener(Event.ENTER_FRAME, rootView_enterFrame);
				_tooltip = null;
			}
		}
		
		protected function tooltip_hideComplete(e:DisplayEvent):void
		{
			removeTooltip(AbstractTooltip(e.target));
		}
		
		protected function tooltip_showComplete(e:DisplayEvent):void
		{
			_tooltipState = TOOLTIP_VISIBLE;
		}
		
		protected function rootView_enterFrame(e:Event):void
		{
			updateTooltipPosition();
		}
		
		protected function mousedElement_tooltipDataChanged(e:DisplayEvent):void
		{
			updateTooltipForElement(_lastMousedElement);
		}
	}
}