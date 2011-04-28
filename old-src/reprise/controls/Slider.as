/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.controls
{
	
	import reprise.ui.UIComponent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	
	public class Slider extends UIComponent
	{
		
		//----------------------             Public Properties              ----------------------//
		public static const DIRECTION_VERTICAL : String = 'vertical';
		public static const DIRECTION_HORIZONTAL : String = 'horizontal';
		

		//----------------------       Private / Protected Properties       ----------------------//
		protected var _thumb:SimpleButton;
		protected var _statusBar:UIComponent;
		protected var _track:UIComponent;
		
		protected var _minValue:Number = 0;
		protected var _maxValue:Number = 100;
		protected var _value:Number = 0;
		protected var _isContinuous:Boolean = true;
		
		protected var _dragStartThumbPosition:Number;
		protected var _dragStartMousePosition:Number;
		protected var _isDragging:Boolean;
		protected var _frameListenerActive:Boolean = false;
		
		protected var _allowsTickMarkValuesOnly:Boolean = false;
		protected var _numTickMarks:int = 2;
		protected var _animatesChange:Boolean = false;
		protected var _animationFriction:Number = .35;
		
		protected var _direction : String;
		
		
		//----------------------               Public Methods               ----------------------//
		public function Slider() {}
		
		
		public function setValue(value:Number):void
		{
			value = Math.min(value, _maxValue);
			value = Math.max(value, _minValue);
			_value = _allowsTickMarkValuesOnly ? closestTickMarkValueToValue(value) : value;
			if (!_isDragging)
			{
				applyValue();
			}
		}
		
		public function value():Number
		{
			return _value;
		}
		
		public function setMaxValue(maxValue:Number):void
		{
			_maxValue = maxValue;
			setValue(_value);
		}
		
		public function maxValue():Number
		{
			return _maxValue;
		}
		
		public function setMinValue(minValue:Number):void
		{
			_minValue = minValue;
			setValue(_value);
		}
		
		public function minValue():Number
		{
			return _minValue;
		}
		
		/** 
		* Sets whether the slider sends its events continuously to its listeners 
		* during mouse tracking.
		*/
		public function setContinuous(bFlag:Boolean):void
		{
			_isContinuous = bFlag;
		}
		
		public function isContinuous():Boolean
		{
			return _isContinuous;
		}
		
		public function setAllowsTickMarkValuesOnly(bFlag:Boolean):void
		{
			_allowsTickMarkValuesOnly = bFlag;
		}
		
		public function allowsTickMarkValuesOnly():Boolean
		{
			return _allowsTickMarkValuesOnly;
		}
		
		public function setNumberOfTickMarks(num:int):void
		{
			_numTickMarks = num;
		}
		
		public function numberOfTickMarks():int
		{
			return _numTickMarks;
		}
		
		public function tickMarkValueAtIndex(index:int):Number
		{
			return (_maxValue - _minValue) / (_numTickMarks - 1) * index;
		}
		
		public function closestTickMarkValueToValue(val:Number):Number
		{
			var diff:Number = (_maxValue - _minValue) / _numTickMarks;
			var index:int = Math.floor(val / diff);
			if (val % diff > diff / 2) index++;
			return index * diff;
		}
		
		public function setAnimatesChange(bFlag:Boolean):void
		{
			_animatesChange = bFlag;
		}
		
		public function setDirection(direction : String) : void
		{
			_direction = direction;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		override protected function initialize():void
		{
			super.initialize();
			addEventListener(Event.ADDED_TO_STAGE, self_addedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, self_removedFromStage);
			_direction = DIRECTION_HORIZONTAL;
		}

		override protected function createChildren():void
		{
			createTrack();
			createStatusBar();
			createThumb();
			addListeners();
		}
		
		override protected function beforeFirstDraw():void
		{
			applyValue();
		}
		
		protected function createTrack():void
		{
			_track = addComponent('track');
		}
		
		protected function createStatusBar():void
		{
			_statusBar = addComponent('status_bar');
		}
		
		protected function createThumb():void
		{
			_thumb = SimpleButton(addComponent('thumb', null, SimpleButton));
			_thumb.setStyle('position', 'absolute');
		}
		
		protected function addListeners():void
		{
			_thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumb_click);
			_track.addEventListener(MouseEvent.MOUSE_DOWN, track_mouseDown);
		}
		
		protected function applyValue():void
		{
			var thumbPosition : int;
			if(_direction == DIRECTION_HORIZONTAL)
			{
				thumbPosition = _thumb.left;
			}
			else
			{
				thumbPosition = _thumb.top;
			}
			var pos:Number = valueToPosition(_value, _minValue, _maxValue);
			if (_animatesChange && (!_isDragging || _allowsTickMarkValuesOnly))
			{
				var diff:Number = (pos - thumbPosition) * _animationFriction;
					
				if (Math.abs(diff) > 0.7)
				{
					pos = thumbPosition + diff;
					addFrameListener();
				}
				else 
				{
					removeFrameListener();
				}
			}
			if(_direction == DIRECTION_HORIZONTAL)
			{
				_thumb.left = _statusBar.width = pos;
			}
			else
			{
				_thumb.top = _statusBar.height = pos;
			}
		}
		
		protected function valueToPosition(value:Number, dataMin:Number, dataMax:Number):Number
		{
			var pos:Number;
			if(_direction == DIRECTION_HORIZONTAL)
			{
				pos = (width - _thumb.width) * ((value - dataMin) / (dataMax - dataMin));
				pos = Math.max(0, pos);
				pos = Math.min(width - _thumb.width, pos);
			}
			else
			{
				pos = (height - _thumb.height) * ((value - dataMin) / (dataMax - dataMin));
				pos = Math.max(0, pos);
				pos = Math.min(height - _thumb.height, pos);
				
			}
			return Math.round(pos);
		}
		
		protected function positionToValue(pos:Number):Number
		{
			if(_direction == DIRECTION_HORIZONTAL)
			{
				pos = Math.max(0, pos);
				pos = Math.min(width - _thumb.width, pos);
				return pos / (width - _thumb.width) * (_maxValue - _minValue) + _minValue;
			}
			else
			{
				pos = Math.max(0, pos);
				pos = Math.min(height - _thumb.height, pos);
				return pos / (height - _thumb.height) * (_maxValue - _minValue) + _minValue;
			}
		}
		
		protected function applyCurrentDragValue():void
		{
			if(_direction == DIRECTION_HORIZONTAL)
			{
				setValue(positionToValue(_dragStartThumbPosition +
					(_track.mouseX - _dragStartMousePosition)));
			}
			else
			{
				setValue(positionToValue(_dragStartThumbPosition +
					(_track.mouseY - _dragStartMousePosition)));
			}
			applyValue();
		}
		
		protected function addFrameListener():void
		{
			if (_frameListenerActive) return;

			addEventListener(Event.ENTER_FRAME, self_enterFrame);
			_frameListenerActive = true;
		}
		
		protected function removeFrameListener():void
		{
			if (!_frameListenerActive) return;
			var animationActive:Boolean;
			if(_direction == DIRECTION_HORIZONTAL)
			{
				animationActive = _thumb.left != valueToPosition(_value, _minValue,
				_maxValue);
			}
			else
			{
				animationActive = _thumb.top != valueToPosition(_value, _minValue,
				_maxValue);
			}
			if (animationActive || _isDragging) return;
			removeEventListener(Event.ENTER_FRAME, self_enterFrame);
			_frameListenerActive = false;
		}
		
		
		
		//*****************************************************************************************
		//*                                         Events                                        *
		//*****************************************************************************************
		protected function self_addedToStage(e:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
		
		protected function self_removedFromStage(e:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
		
		protected function thumb_click(e:MouseEvent):void
		{
			if(_direction == DIRECTION_HORIZONTAL)
			{
				_dragStartThumbPosition = _thumb.left;
				_dragStartMousePosition = _track.mouseX;
			}
			else
			{
				_dragStartThumbPosition = _thumb.top;
				_dragStartMousePosition = _track.mouseY;
			}
			_isDragging = true;
			addFrameListener();
		}
		
		protected function stage_mouseUp(e:MouseEvent):void
		{
			if (!_isDragging)
			{
				return;
			}
			_isDragging = false;
			removeFrameListener();
			applyCurrentDragValue();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function track_mouseDown(e:MouseEvent):void
		{
			if(_direction == DIRECTION_HORIZONTAL)
			{
				setValue(positionToValue(_track.mouseX - _thumb.width / 2));
			}
			else
			{
				setValue(positionToValue(_track.mouseY - _thumb.height / 2));
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function self_enterFrame(e:Event):void
		{
			// if we're not being dragged, there's animation to be done
			if (!_isDragging)
			{
				applyValue();
				return;
			}
			if (_isContinuous)
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
			applyCurrentDragValue();
		}
		
		protected function animatesChange():Boolean
		{
			return _animatesChange;
		}
	}
}