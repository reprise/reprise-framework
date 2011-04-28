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
		
		protected var m_tooltipState:uint = TOOLTIP_INVISIBLE;
		
		protected var m_rootView:DocumentView;
		protected var m_tooltipContainer:Sprite;
		protected var m_tooltipDelay:Delegate;
		protected var m_tooltip:AbstractTooltip;
		protected var m_lastMousedElement:DisplayObject;
		protected var m_lastTooltipDataProvider:UIObject;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function TooltipManager(rootView:DocumentView, container : Sprite)
		{
			m_rootView = rootView;
			m_rootView.addEventListener(MouseEvent.MOUSE_OVER, rootView_mouseOver);
			m_rootView.addEventListener(MouseEvent.MOUSE_OUT, rootView_mouseOut);
			
			m_tooltipContainer = container;
			m_tooltipContainer.mouseEnabled = false;
			m_tooltipContainer.mouseChildren = false;
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
			
			var currentTooltipData:Object = m_tooltip ? m_tooltip.data() : null;
			var newTooltipData:Object = element ? element.tooltipData() : null;
			
			// nothing changed
			if (element == m_lastTooltipDataProvider && 
				currentTooltipData == newTooltipData)
			{
				if ((m_tooltipState == TOOLTIP_HIDE_ANIMATION || 
					m_tooltipState == TOOLTIP_INVISIBLE) && newTooltipData != null)
				{
					m_tooltip.show();
					m_tooltipState = TOOLTIP_SHOW_ANIMATION;
				}
				return;
			}
			
			if (m_lastTooltipDataProvider)
			{
				m_lastTooltipDataProvider.removeEventListener(DisplayEvent.TOOLTIPDATA_CHANGED,
					mousedElement_tooltipDataChanged);
			}
			
			if (element)
			{
				element.addEventListener(DisplayEvent.TOOLTIPDATA_CHANGED,
					mousedElement_tooltipDataChanged);
			}
			
			m_lastMousedElement = mousedElement;
			m_lastTooltipDataProvider = element;

			if (element == null && m_tooltip)
			{
				m_tooltip.setMousedElement(null);
				m_tooltip.setTooltipDataProvider(null);
				m_tooltip.setMousedComponent(null);
			}
			if (element == null || element.tooltipData() == null)
			{
				hideTooltip();
				return;
			}

			var tooltipData:Object = element.tooltipData();
			var tooltipRenderer:String = element.tooltipRenderer();
			
			if (m_tooltipDelay != null)
			{
				TimeCommandExecutor.instance().removeCommand(m_tooltipDelay);
				m_tooltipDelay = null;
			}
			
			if (element.tooltipDelay() > 0 && m_tooltipState == TOOLTIP_INVISIBLE)
			{
				m_tooltipDelay = new Delegate(this, showTooltipWithDataAndRendererForElement, 
					[tooltipData, tooltipRenderer, mousedElement, element]);
				TimeCommandExecutor.instance().delayCommand(m_tooltipDelay, element.tooltipDelay());
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
			
			if (m_tooltip == null || !m_tooltip.hasCSSClass(cssClassName))
			{
				removeTooltip();
				m_tooltip = tooltipDataProvider.document.uiRendererFactory().
					tooltipRendererById(renderer);
				m_tooltipContainer.addChild(m_tooltip);
				m_tooltip.setParent(tooltipDataProvider.document);
				m_tooltip.cssID = 'Tooltip';
				m_tooltip.mouseEnabled = m_tooltip.mouseChildren = false;
				m_tooltip.addEventListener(DisplayEvent.SHOW_COMPLETE, tooltip_showComplete);
				m_tooltip.addEventListener(DisplayEvent.HIDE_COMPLETE, tooltip_hideComplete);
				m_rootView.addEventListener(Event.ENTER_FRAME, rootView_enterFrame);
			}
			m_tooltip.setTooltipDataProvider(tooltipDataProvider);
			m_tooltip.setMousedElement(mousedElement);
			m_tooltip.setMousedComponent(findComponentForMousedElement(mousedElement));
			m_tooltip.addCSSClass(cssClassName);
			m_tooltip.setData(data);
			m_tooltip.forceRedraw();
			updateTooltipPosition();
			
			if (m_tooltipState != TOOLTIP_VISIBLE && m_tooltipState != TOOLTIP_SHOW_ANIMATION)
			{
				m_tooltip.show();
				m_tooltipState = TOOLTIP_SHOW_ANIMATION;
			}
		}
		
		protected function hideTooltip():void
		{
			if (m_tooltipState == TOOLTIP_INVISIBLE || m_tooltipState == TOOLTIP_HIDE_ANIMATION)
			{
				return;
			}
			if (m_tooltipDelay != null)
			{
				TimeCommandExecutor.instance().removeCommand(m_tooltipDelay);
				m_tooltipDelay = null;
			}
			m_tooltipState = TOOLTIP_HIDE_ANIMATION;
			m_tooltip.hide();
		}

		protected function updateTooltipPosition():void
		{
			if (!m_tooltip) return;
			m_tooltip.updatePosition();
		}
		
		protected function removeTooltip(tooltip:AbstractTooltip = null):void
		{
			if (!tooltip)
			{
				tooltip = m_tooltip;
			}
			if (!tooltip)
			{
				return;
			}
			tooltip.removeEventListener(DisplayEvent.HIDE_COMPLETE, tooltip_hideComplete);
			tooltip.removeEventListener(DisplayEvent.SHOW_COMPLETE, tooltip_showComplete);
			tooltip.remove();
			m_tooltipState = TOOLTIP_INVISIBLE;
			
			if (tooltip == m_tooltip)
			{
				m_rootView.removeEventListener(Event.ENTER_FRAME, rootView_enterFrame);
				m_tooltip = null;
			}
		}
		
		protected function tooltip_hideComplete(e:DisplayEvent):void
		{
			removeTooltip(AbstractTooltip(e.target));
		}
		
		protected function tooltip_showComplete(e:DisplayEvent):void
		{
			m_tooltipState = TOOLTIP_VISIBLE;
		}
		
		protected function rootView_enterFrame(e:Event):void
		{
			updateTooltipPosition();
		}
		
		protected function mousedElement_tooltipDataChanged(e:DisplayEvent):void
		{
			updateTooltipForElement(m_lastMousedElement);
		}
	}
}