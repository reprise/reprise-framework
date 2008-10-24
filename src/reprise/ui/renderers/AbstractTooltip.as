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

package reprise.ui.renderers
{
	import reprise.controls.Label;
	import reprise.core.reprise;
	import reprise.css.propertyparsers.DisplayPosition;
	import reprise.ui.UIComponent;
	import reprise.ui.UIObject;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;	 
	
	use namespace reprise;
	
	public class AbstractTooltip extends UIComponent
	{
			
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "AbstractTooltip";
		
		
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_mousedElement : DisplayObject;
		protected var m_mousedComponent : UIComponent;
		protected var m_tooltipDataProvider : Object;
		protected var m_label : Label;
			
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/	
		public function AbstractTooltip()
		{
		}
	
		
		public function setData(data : Object) : void
		{
			m_tooltipData = data;
			m_label.setLabel(String(data));
		}
		
		public function data() : Object
		{
			return m_tooltipData;
		}
		
		public function updatePosition() : void
		{
			var pos:Point = new Point();
			switch (style.position)
			{
				case DisplayPosition.POSITION_ABSOLUTE:
				{
					pos = positionRelativeToElement(m_mousedComponent);
					break;
				}
				case DisplayPosition.POSITION_FIXED:
				{
					pos = positionRelativeToElement(stage);
					break;
				}
				case DisplayPosition.POSITION_STATIC:
				{
					pos.x = m_mousedElement.stage.mouseX + style.left;
					pos.y = m_mousedElement.stage.mouseY + style.top;
					break;
				}
			}
			setPosition(pos.x, pos.y);
		}
		
		public function setPosition(xValue:Number, yValue:Number) : void
		{
			var newPos : Point = new Point(xValue, yValue);
			newPos = stage.localToGlobal(newPos);
			newPos.y = Math.max(-m_currentStyles.marginTop, newPos.y + m_currentStyles.marginTop);
			newPos.y = Math.min(stage.stageHeight - outerHeight - m_currentStyles.marginTop, newPos.y);
			newPos.x = Math.max(-m_currentStyles.marginLeft, newPos.x + m_currentStyles.marginLeft);
			newPos.x = Math.min(stage.stageWidth - outerWidth - m_currentStyles.marginLeft, newPos.x);
			newPos = parent.globalToLocal(newPos);
			x = newPos.x;
			y = newPos.y;
		}
		
		public function setMousedElement(mousedElement : DisplayObject) : void
		{
			m_mousedElement = mousedElement;
		}
		
		public function mousedElement() : DisplayObject
		{
			return m_mousedElement;
		}
		
		public function setMousedComponent(mousedComponent:UIComponent):void
		{
			m_mousedComponent = mousedComponent;
			refreshSelectorPath();
		}
		
		public function mousedComponent():UIComponent
		{
			return m_mousedComponent;
		}
		
		public function setTooltipDataProvider(target:Object) : void
		{
			m_tooltipDataProvider = target;
		}
		
		public function tooltipDataProvider() : Object
		{
			return m_tooltipDataProvider;
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function createChildren() : void
		{
			m_label = Label(addChild(new Label()));
			m_label.cssClasses = 'tooltipLabel';
		}
		
		protected override function initDefaultStyles() : void
		{
			super.initDefaultStyles();
			m_elementDefaultStyles.setStyle('position', 'static');
			m_elementDefaultStyles.setStyle('top', '18');
			m_elementDefaultStyles.setStyle('left', '0');
		}
		
		protected override function refreshSelectorPath() : void
		{
			var oldPath:String = m_selectorPath;
			super.refreshSelectorPath();
			if (!m_mousedElement is UIComponent)
			{
				return;
			}
			m_selectorPath = UIComponent(m_mousedComponent).selectorPath + 
				' ' + m_selectorPath.split(' ').pop();
			if (m_selectorPath != oldPath)
			{
				m_selectorPathChanged = true;
				return;
			}
			m_selectorPathChanged = false;
		}
		
		protected override function resolveContainingBlock() : void
		{
			m_containingBlock = m_rootElement;
		}
		
		protected override function resolvePositioningProperties() : void
		{
			m_positionInFlow = 0;
		}
		
		protected function positionRelativeToElement(element:DisplayObject):Point
		{
			var p:Point = new Point();
			
			if (style.right && !style.left)
			{
				p.x = element.width - style.right - width;
			}
			else
			{
				p.x = style.left;
			}
			
			if (style.bottom && !style.top)
			{
				p.y = element.height - style.bottom - height;
			}
			else
			{
				p.y = style.top;
			}
			return element.localToGlobal(p);
		}
	}
}