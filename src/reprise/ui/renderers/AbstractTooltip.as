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
	import reprise.core.ccInternal;
	import reprise.events.DisplayEvent;
	import reprise.ui.UIComponent;
	import reprise.ui.UIObject;
	
	import flash.geom.Point;
	
	use namespace ccInternal;
	
	public class AbstractTooltip extends UIComponent
	{
			
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "AbstractTooltip";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_target : UIObject;
		protected var m_dataSupplyTarget : Object;
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
			setPosition(m_target.stage.mouseX, m_target.stage.mouseY);
		}
		
		public override function setPosition(x : Number, y : Number) : void
		{
			var newPos : Point = new Point(x, y);
			newPos = stage.localToGlobal(newPos);
			newPos.y = Math.max(-m_marginTop, newPos.y + m_marginTop);
			newPos.y = Math.min(stage.stageHeight - outerHeight - m_marginTop, newPos.y);
			newPos.x = Math.max(-m_marginLeft, newPos.x + m_marginLeft);
			newPos.x = Math.min(stage.stageWidth - outerWidth - m_marginLeft, newPos.x);
			newPos = parent.globalToLocal(newPos);
			left = newPos.x;
			top = newPos.y;
		}
		
		public function setTarget(target : UIObject) : void
		{
			if (m_target != null)
			{
				removeEventListenersFromTargets();
			}
			
			m_target = target;
			addEventListenersToTargets();
		}
		
		public function target() : Object
		{
			return m_target;
		}
		
		public override function remove(...args) : void
		{
			removeEventListenersFromTargets();
			super.remove();
		}
		
		public function setDataSupplyTarget(target:Object) : void
		{
			m_dataSupplyTarget = target;
		}
		
		public function dataSupplyTarget() : Object
		{
			return m_dataSupplyTarget;
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
			m_elementDefaultStyles.setStyle('position', 'absolute');
			m_elementDefaultStyles.setStyle('top', '0');
			m_elementDefaultStyles.setStyle('left', '0');
		}
		
		protected override function refreshSelectorPath() : void
		{
			var oldPath:String = m_selectorPath;
			super.refreshSelectorPath();
			if (!m_target is UIComponent)
			{
				return;
			}
			m_selectorPath = UIComponent(m_target).selectorPath + 
				' ' + m_selectorPath.split(' ').pop();
			if (m_selectorPath != oldPath)
			{
				m_selectorPathChanged = true;
				return;
			}
			m_selectorPathChanged = false;
		}
		
		protected function target_remove(event : DisplayEvent) : void
		{
			dispatchEvent(new DisplayEvent(DisplayEvent.REMOVE));
		}
		
		protected function target_visibleChanged(e : DisplayEvent) : void
		{
			if (e.target.getVisibility())
				return;
			dispatchEvent(new DisplayEvent(DisplayEvent.REMOVE));
		}
		
		protected function target_tooltipDataChanged(e : DisplayEvent) : void
		{
			if (m_dataSupplyTarget.tooltipData() == null)
			{
				dispatchEvent(new DisplayEvent(DisplayEvent.REMOVE));
				return;
			}
			
			if (m_dataSupplyTarget.tooltipData() != m_tooltipData)
			{
				setData(m_dataSupplyTarget.tooltipData());
			}
		}
		
		protected function removeEventListenersFromTargets() : void
		{
			var parent : Object = m_target;
			while (true && parent != null)
			{
				parent.removeEventListener(this);
				if (parent == m_dataSupplyTarget)
				{
					break;
				}
				parent = parent['m_parentElement'];
			}
		}
		
		protected function addEventListenersToTargets() : void
		{
			var parent : Object = m_target;
			while (true && parent != null)
			{
				parent.addEventListener(DisplayEvent.REMOVE,
				 target_remove);
				parent.addEventListener(DisplayEvent.VISIBLE_CHANGED,
				 target_visibleChanged);
				if (parent == m_dataSupplyTarget)
				{
					break;
				}
				parent = parent['m_parentElement'];			
			}
			m_dataSupplyTarget.addEventListener(
				DisplayEvent.TOOLTIPDATA_CHANGED, target_tooltipDataChanged);
		}
	}
}