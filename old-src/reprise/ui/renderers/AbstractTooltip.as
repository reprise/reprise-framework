/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.ui.renderers
{
	import reprise.events.DisplayEvent;
	import reprise.controls.Label;
	import reprise.core.reprise;
	import reprise.css.propertyparsers.DisplayPosition;
	import reprise.ui.UIComponent;

	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	use namespace reprise;
	
	public class AbstractTooltip extends UIComponent
	{
			
		//----------------------             Public Properties              ----------------------//
		public static var className : String = "AbstractTooltip";
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _mousedElement : DisplayObject;
		protected var _mousedComponent : UIComponent;
		protected var _tooltipDataProvider : Object;
		protected var _label : Label;
			
		
		//----------------------               Public Methods               ----------------------//
		public function AbstractTooltip()
		{
		}
	
		
		public function setData(data : Object) : void
		{
			_tooltipData = data;
			_label.setLabel(String(data));
		}
		
		public function data() : Object
		{
			return _tooltipData;
		}
		
		public function updatePosition() : void
		{
			var pos : Point;
			switch (style.position)
			{
				case DisplayPosition.POSITION_ABSOLUTE:
				{
					if (!_mousedComponent)
					{
						return;
					}
					pos = positionRelativeToElement(_mousedComponent);
					break;
				}
				case DisplayPosition.POSITION_FIXED:
				{
					pos = positionRelativeToElement(stage);
					break;
				}
				case DisplayPosition.POSITION_STATIC:
				{
					// there seems to be a problem with sprites which are freshly inserted into the
					// view hierarchy. most probably it takes a sec before their stage attribute is 
					// set, so we take care of this here. one frame later everything will be fine 
					// again.
					if (!(_mousedElement && _mousedElement.stage))
					{
						return;
					}
					pos = positionRelativeToMouse();
					break;
				}
			}
			setPosition(pos.x, pos.y);
		}

		public function setPosition(xValue:Number, yValue:Number) : void
		{
			var newPos : Point = new Point(xValue, yValue);
			newPos = stage.localToGlobal(newPos);
			newPos.y = Math.max(-_currentStyles.marginTop, newPos.y + _currentStyles.marginTop);
			newPos.y = Math.min(stage.stageHeight - outerHeight - _currentStyles.marginTop, newPos.y);
			newPos.x = Math.max(-_currentStyles.marginLeft, newPos.x + _currentStyles.marginLeft);
			newPos.x = Math.min(stage.stageWidth - outerWidth - _currentStyles.marginLeft, newPos.x);
			newPos = parent.globalToLocal(newPos);
			x = newPos.x;
			y = newPos.y;
		}
		
		public function setMousedElement(mousedElement : DisplayObject) : void
		{
			_mousedElement = mousedElement;
		}
		
		public function mousedElement() : DisplayObject
		{
			return _mousedElement;
		}
		
		public function setMousedComponent(mousedComponent:UIComponent):void
		{
			_mousedComponent && _mousedComponent.removeEventListener(
				DisplayEvent.VALIDATION_COMPLETE, mousedEvent_validationComplete);
			_mousedComponent = mousedComponent;
			_mousedComponent && _mousedComponent.addEventListener(
				DisplayEvent.VALIDATION_COMPLETE, mousedEvent_validationComplete);
			validateElement(true, true);
			updatePosition();
		}

		public function mousedComponent():UIComponent
		{
			return _mousedComponent;
		}
		
		public function setTooltipDataProvider(target:Object) : void
		{
			_tooltipDataProvider = target;
		}
		
		public function tooltipDataProvider() : Object
		{
			return _tooltipDataProvider;
		}

		override public function remove(...args : *) : void
		{
			_mousedComponent && _mousedComponent.removeEventListener(
				DisplayEvent.VALIDATION_COMPLETE, mousedEvent_validationComplete);
			super.remove(args);
		}

		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function createChildren() : void
		{
			_label = Label(addChild(new Label()));
			_label.cssClasses = 'tooltipLabel';
		}
		
		protected override function initDefaultStyles() : void
		{
			super.initDefaultStyles();
			_elementDefaultStyles.setStyle('position', 'static');
			_elementDefaultStyles.setStyle('top', '18');
			_elementDefaultStyles.setStyle('left', '0');
		}
		
		protected override function refreshSelectorPath() : void
		{
			var oldPath:String = _selectorPath || '';
			super.refreshSelectorPath();
			if (_mousedComponent is UIComponent)
			{
				_selectorPath = UIComponent(_mousedComponent).selectorPath +
					' ' + _selectorPath.split(' ').pop();
			}
			else
			{
				var basePathParts : Array = oldPath.split(' ');
				basePathParts.pop();
				basePathParts.push(_selectorPath.split(' ').pop());
				_selectorPath = basePathParts.join(' ');
			}
			if (_selectorPath != oldPath)
			{
				_selectorPathChanged = true;
				return;
			}
			_selectorPathChanged = false;
		}

		protected override function resolveContainingBlock() : void
		{
			_containingBlock = _rootElement;
		}
		
		protected override function resolvePositioningProperties() : void
		{
			_positionInFlow = 0;
		}
		
		protected function positionRelativeToElement(element:DisplayObject) : Point
		{
			var pos : Point = new Point();
			if (style.right && !style.left)
			{
				pos.x = element.width - style.right - width;
			}
			else
			{
				pos.x = style.left;
			}
			
			if (style.bottom && !style.top)
			{
				pos.y = element.height - style.bottom - height;
			}
			else
			{
				pos.y = style.top;
			}
			return element.localToGlobal(pos);
		}
		
		protected function positionRelativeToMouse() : Point
		{
			var pos : Point = new Point();
			pos.x = _mousedElement.stage.mouseX + style.left;
			pos.y = _mousedElement.stage.mouseY + style.top;
			return pos;
		}
		
		protected override function validateAfterChildren() : void
		{
			super.validateAfterChildren();
			applyOutOfFlowChildPositions();
		}
		
		protected function mousedEvent_validationComplete(event : DisplayEvent) : void
		{
			_mousedComponent.document.addEventListener(
				DisplayEvent.DOCUMENT_VALIDATION_COMPLETE, document_validationComplete);
		}
		
		protected function document_validationComplete(event : DisplayEvent) : void
		{
			_mousedComponent.document.removeEventListener(
				DisplayEvent.DOCUMENT_VALIDATION_COMPLETE, document_validationComplete);
			validateElement(true, true);
			updatePosition();
		}
	}
}