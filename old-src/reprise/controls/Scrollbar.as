/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.controls 
{
	import reprise.events.DisplayEvent;
	import reprise.events.MouseEventConstants;
	import reprise.ui.UIComponent;
	import reprise.utils.ProxyFunction;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	public class Scrollbar extends UIComponent
	{
		//----------------------             Public Properties              ----------------------//
		public static const ORIENTATION_VERTICAL : String = 'vertical';
		public static const ORIENTATION_HORIZONTAL : String = 'horizontal';
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static const SCROLL_DIR_UP : int = -1;
		protected static const SCROLL_DIR_DOWN : int = 1;
		
		
		protected var _scrollUpBtn : SimpleButton;
		protected var _scrollDownBtn : SimpleButton;
		protected var _scrollThumb : SimpleButton;
		protected var _scrollTrack : SimpleButton;
		
		protected var _scrollDirection : int;
		protected var _scrollIntervalID : int;
		
		protected var _target : TextField;
		protected var _textScrollOrientation : String;
		
		protected var _minPos : Number;
		protected var _maxPos : Number;
		
		protected var _thumbMinPos : Number;
		protected var _thumbMaxPos : Number;
		
		protected var _scrollPosition : Number;
	
		protected var _mouseWheelListener : Object;
		
		protected var _mouseWheelHitAreaX : Number;
		protected var _mouseWheelHitAreaY : Number;
		protected var _mouseWheelHitAreaWidth : Number;
		protected var _mouseWheelHitAreaHeight : Number;
		protected var _overflowScrollMode : Boolean = true;

		
		//----------------------               Public Methods               ----------------------//
		public function Scrollbar()
		{
		}
		
		public function setOverflowScrollMode(standaloneMode : Boolean) : void
		{
			_overflowScrollMode = standaloneMode;
		}
		
		public function overflowScrollMode() : Boolean
		{
			return _overflowScrollMode;
		}

		
		public function delayValidation() : void
		{
			setTimeout(forceRedraw, 1);
		}
		
		/**
		 * sets a TextField instance as the Scrollbar's _target
		 */
		public function setScrollTarget(target:TextField, orientation:String) : void
		{
			_target = target;
			_textScrollOrientation = orientation;
			if (_target)
			{
				if (orientation == ORIENTATION_VERTICAL)
				{
					pageScrollSize = _target.bottomScrollV - _target.scrollV;
				}
				else
				{
					pageScrollSize = _target.width - 4;
				}
				addEventListener(Event.ENTER_FRAME, checkTargetScrollPos);
				checkTargetScrollPos();
			}
			else
			{
				removeEventListener(Event.ENTER_FRAME, checkTargetScrollPos);
			}
		}
		
		/**
		 * sets the Scrollbar's scrollV properties
		 */
		public function setScrollProperties(
			pageSize:Number, minPos:Number, maxPos:Number) : void
		{
			pageScrollSize = pageSize;
			if (maxPos < minPos)
			{
				maxPos = minPos;
			}
			_minPos = minPos;
			_maxPos = maxPos;
			invalidate();
		}
		
		/**
		 * setter for the scrollPosition property
		 */
		public function set scrollPosition(position:Number) : void
		{
			if (_target)
			{
				_target.scrollV = position;
			}
			updateScrollPosition(position);
		}
		/**
		 * getter for the scrollPosition property
		 */
		public function get scrollPosition() : Number
		{
			return _scrollPosition;
		}
		
		public function get minScrollPosition() : Number
		{
			return _minPos;
		}
		public function get maxScrollPosition() : Number
		{
			return _maxPos;
		}

		/**
		 * sets whether the scrollBar should automatically 
		 * hide itself if there's no need to scrollV
		 */
		public function set autoHide(hide:Boolean) : void
		{
			_currentStyles.autoHide = hide;
			_instanceStyles.setStyle('autoHide', hide.toString());
		}
		/**
		 * returns the current state of the autoHide property
		 */
		public function get autoHide() : Boolean
		{
			return _currentStyles.autoHide;
		}
		
		public function set pageScrollSize(value:Number) : void
		{
			_currentStyles.pageScrollSize = value;
			_instanceStyles.setStyle('pageScrollSize', value.toString());
		}
		public function get pageScrollSize() : Number
		{
			return _currentStyles.pageScrollSize;
		}
		public function set lineScrollSize(value:Number) : void
		{
			_currentStyles.lineScrollSize = value;
			_instanceStyles.setStyle('lineScrollSize', value.toString());
		}
		public function get lineScrollSize() : Number
		{
			return _currentStyles.lineScrollSize;
		}
		
		/**
		 * getter for the scaleScrollThumb property
		 */
		public function get scaleScrollThumb() : Boolean
		{
			return Boolean(_currentStyles.scaleScrollThumb);
		}
		/**
		 * getter for the scaleScrollThumb property
		 */
		public function set scaleScrollThumb(scaleScrollThumb:Boolean) : void
		{
			_instanceStyles.setStyle('scaleScrollThumb', scaleScrollThumb.toString());
		}

		/**
		 * getter for the _scrollUpBtn
		 */		
		public function get scrollUpBtn() : SimpleButton
		{
			return _scrollUpBtn;
		}
		
		/**
		 * getter for the _scrollDownBtn
		 */
		public function get scrollDownBtn() : SimpleButton
		{
			return _scrollDownBtn;
		}
		
		/**
		 * sets the area in which the scrollbar should react on mouseWheel events
		 * 
		 * Coordinates are relative to the Scrollbars' parent
		 */
		public function setMouseWheelArea(
			x:Number, y:Number, width:Number, height:Number) : void
		{
			_mouseWheelHitAreaX = x;
			_mouseWheelHitAreaY = y;
			_mouseWheelHitAreaWidth = width;
			_mouseWheelHitAreaHeight = height;
		}
		
		/**
		 * clean up
		 */
		public override function remove(...args) : void
		{
			clearInterval(_scrollIntervalID);
			super.remove();
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initialize() : void
		{
			super.initialize();
			
			_scrollPosition = 0;
			_minPos = 0;
			_maxPos = 0;
			
			
			//init mouseWheel support
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel_turn);
		}
		protected override function initDefaultStyles() : void
		{
			_elementDefaultStyles.setStyle('lineScrollSize', '1');
			_elementDefaultStyles.setStyle('pageScrollSize', '5');
			_elementDefaultStyles.setStyle('width', '16px');
			_elementDefaultStyles.setStyle('height', '50px');
			_elementDefaultStyles.setStyle('boxSizing', 'border-box');
		}
		
		protected override function createChildren() : void
		{
			_scrollUpBtn = SimpleButton(addChild(new SimpleButton()));
			_scrollUpBtn.cssClasses = "scrollUpBtn";
			_scrollTrack = SimpleButton(addChild(new SimpleButton()));
			_scrollTrack.cssClasses = "scrollTrack";
			_scrollDownBtn = SimpleButton(addChild(new SimpleButton()));
			_scrollDownBtn.cssClasses = "scrollDownBtn";
			_scrollThumb = SimpleButton(addChild(new SimpleButton()));
			_scrollThumb.cssClasses = "scrollThumb";
			
			//init button delegates
			_scrollUpBtn.addEventListener(MouseEvent.MOUSE_DOWN,  scrollUp_press);
			_scrollUpBtn.addEventListener(MouseEvent.MOUSE_UP, scrollBtn_up);
			_scrollUpBtn.addEventListener(
				MouseEventConstants.MOUSE_UP_OUTSIDE, scrollBtn_up);
			
			_scrollDownBtn.addEventListener(MouseEvent.MOUSE_DOWN, scrollDown_press);
			_scrollDownBtn.addEventListener(MouseEvent.MOUSE_UP, scrollBtn_up);
			_scrollDownBtn.addEventListener(
				MouseEventConstants.MOUSE_UP_OUTSIDE, scrollBtn_up);
			
			_scrollThumb.addEventListener(MouseEvent.MOUSE_DOWN, scrollThumb_press);
			_scrollThumb.addEventListener(MouseEvent.MOUSE_UP, scrollThumb_up);
			_scrollThumb.addEventListener(
				MouseEventConstants.MOUSE_UP_OUTSIDE, scrollThumb_up);
			
			_scrollTrack.addEventListener(MouseEvent.MOUSE_DOWN, scrollTrack_press);
			_scrollTrack.addEventListener(MouseEvent.MOUSE_UP, scrollBtn_up);
			_scrollTrack.addEventListener(
				MouseEventConstants.MOUSE_UP_OUTSIDE, scrollBtn_up);
		}

		override protected function hookIntoDisplayList() : void
		{
			if (!_overflowScrollMode)
			{
				super.hookIntoDisplayList();
			}
		}

		override protected function applyStyles() : void
		{
			super.applyStyles();
			
			switch (_currentStyles.buttonPositioning)
			{
				case 'top':
				{
					_children[0] = _scrollUpBtn;
					_children[1] = _scrollDownBtn;
					_children[2] = _scrollTrack;
					break;
				}
				case 'bottom':
				{
					_children[0] = _scrollTrack;
					_children[1] = _scrollUpBtn;
					_children[2] = _scrollDownBtn;
					break;
				}
				case 'separated':
				default:
				{
					_children[0] = _scrollUpBtn;
					_children[1] = _scrollTrack;
					_children[2] = _scrollDownBtn;
					
				}
			}
		}

		protected override function validateAfterChildren() : void
		{
			top = top;
			left = left;
			if (_currentStyles.autoHide && _maxPos == _minPos)
			{
				setVisibility(false);
				//TODO: check if we can disable positioning entirely here
				super.validateAfterChildren();
				return;
			}
			
			var specHeight:Number = 
				_currentStyles.height - _currentStyles.marginTop - _currentStyles.marginBottom;
			var trackHeight:Number = 
				specHeight - _scrollUpBtn.outerHeight - _scrollDownBtn.outerHeight;
			_scrollTrack.setStyle('height', trackHeight + 'px');
			_scrollTrack.forceRedraw();
				
			super.validateAfterChildren();
			
			if (_maxPos == _minPos)
			{
				if (_scrollThumb.enabled)
				{
					_scrollThumb.enabled = false;
					_scrollUpBtn.enabled = false;
					_scrollDownBtn.enabled = false;
					_scrollTrack.enabled = false;
				}
			}
			else
			{
				if (!_scrollThumb.enabled)
				{
					_scrollThumb.enabled = true;
					_scrollUpBtn.enabled = true;
					_scrollDownBtn.enabled = true;
					_scrollTrack.enabled = true;
				}
			
				var scrollTrackBox:Rectangle = _scrollTrack.clientRect();
				_thumbMinPos = scrollTrackBox.top;
				if (_currentStyles.scaleScrollThumb)
				{
					_scrollThumb.setStyle('boxSizing', 'border-box');
					_scrollThumb.height = Math.ceil(
						_scrollTrack.outerHeight * pageScrollSize /
						(pageScrollSize + _maxPos - _minPos));
					_scrollThumb.forceRedraw();
				}
				_thumbMaxPos = scrollTrackBox.bottom - _scrollThumb.outerHeight;
			}
			updateScrollPosition(_scrollPosition);
		}
		
		
		
		protected function scrollUp_press(event : MouseEvent) : void
		{
			startScrollUp(lineScrollSize);
		}
		
		protected function scrollDown_press(event : MouseEvent) : void
		{
			startScrollDown(lineScrollSize);
		}
		
		protected function scrollThumb_press(event : MouseEvent) : void
		{
			_scrollIntervalID = setInterval(thumbScrub, 50, event.localY);
		}
		protected function scrollThumb_up(event : MouseEvent) : void
		{
			clearInterval(_scrollIntervalID);
		}
		
		protected function scrollTrack_press(event : MouseEvent) : void
		{
			if (mouseY >= _scrollThumb.top)
			{
				startScrollDown(pageScrollSize);
			}
			else
			{
				startScrollUp(pageScrollSize);
			}
		}
		
		protected function scrollBtn_up(event : MouseEvent) : void
		{
			stopScroll();
		}
		
		/**
		 * periodically checks if the _target's scrollV property has
		 * changed and updates the scrollbar's visuals accordingly
		 */
		protected function checkTargetScrollPos(...rest) : void
		{
			if (_textScrollOrientation == ORIENTATION_VERTICAL)
			{
				if (_target.maxScrollV != _maxPos ||
					_target.scrollV != _scrollPosition)
				{
					setScrollProperties(_target.bottomScrollV - _target.scrollV,
						1, _target.maxScrollV);
					_scrollPosition = _target.scrollV;
				}
			}
			else
			{
				if (_target.maxScrollH != _maxPos ||
					_target.scrollH != _scrollPosition)
				{
					_scrollPosition = _target.scrollH;
					setScrollProperties(_target.width - 4, 0,
						_target.maxScrollH);
				}
			}
		}
		
		
		protected function startScrollUp(scrollSize:Number) : void
		{
			startScroll(scrollSize, SCROLL_DIR_UP);
		}
		protected function startScrollDown(scrollSize:Number) : void
		{
			startScroll(scrollSize, SCROLL_DIR_DOWN);
		}
		
		protected function startScroll(scrollSize:Number, direction:int) : void
		{
			_scrollDirection = direction;
			scrollV(scrollSize);
			clearInterval(_scrollIntervalID);
			_scrollIntervalID = setInterval(
				ProxyFunction.create(this, callScroll), 200, scrollSize);
		}
		protected function stopScroll() : void
		{
			clearInterval(_scrollIntervalID);
		}
		protected function scrollV(scrollSize:Number) : void
		{
			if (scrollSize == pageScrollSize)
			{
				if (_scrollDirection == SCROLL_DIR_DOWN &&
					mouseY < _scrollThumb.bottom)
				{
					return;
				}
				else if (_scrollDirection == SCROLL_DIR_UP &&
					mouseY >= _scrollThumb.top)
				{
					return;
				}
			}
			
			updateScrollPosition(
				_scrollPosition + _scrollDirection * scrollSize, true);
			dispatchEvent(new DisplayEvent(Event.CHANGE));
		}
		
		/**
		 * updates the scrollPosition in accordance with the thumbs current position
		 */
		protected function thumbScrub(offset:Number) : void
		{
			var pos:Number = mouseY - offset;
			if (pos < _thumbMinPos)
			{
				pos = _thumbMinPos;
			}
			else if (pos > _thumbMaxPos)
			{
				pos = _thumbMaxPos;
			}
			
			var oldPosition : Number = _scrollPosition;
			updateScrollPosition(Math.round((pos - _thumbMinPos) *
				_maxPos /(_thumbMaxPos - _thumbMinPos)), true);
			if (_scrollPosition != oldPosition)
			{
				dispatchEvent(new DisplayEvent(Event.CHANGE));
			}
		}
		
		protected function callScroll(scrollSize:Number) : void
		{
			scrollV(scrollSize);
			clearInterval(_scrollIntervalID);
			_scrollIntervalID =
				setInterval(ProxyFunction.create(this, scrollV), 50, scrollSize);
		}
		
		/**
		 * updates graphics to reflect the new scrollPosition
		 */
		protected function updateScrollPosition(
			position:Number, updateTextFieldTarget:Boolean = false) : void
		{
			if (position < _minPos)
			{
				position = _minPos;
			}
			else if (position > _maxPos)
			{
				position = _maxPos;
			}
			_scrollPosition = position;
			if (_maxPos <= _minPos)
			{
				_scrollThumb.top = _thumbMinPos;
			}
			else
			{
				_scrollThumb.top = _thumbMinPos +
					Math.round((_thumbMaxPos - _thumbMinPos) *
					(position - _minPos) /(_maxPos - _minPos));
			}
			if (updateTextFieldTarget && _target)
			{
				if (_textScrollOrientation == ORIENTATION_VERTICAL)
				{
					_target.scrollV = _scrollPosition;
				}
				else
				{
					_target.scrollH = _scrollPosition;
				}
			}
		}
		
		/**
		 * event handler, invoked on turn of the mouseWheel
		 * 
		 * updates the scrollPosition
		 */
		protected override function mouseWheel_turn(event : MouseEvent) : void
		{
			var xMouse:Number = parent.mouseX;
			var yMouse:Number = parent.mouseY;
			
			if ((_target &&(xMouse >= x && xMouse <= x + outerWidth) &&
				(yMouse >= y && yMouse <= y + outerHeight)) ||
				((xMouse >= _mouseWheelHitAreaX &&
				xMouse <= _mouseWheelHitAreaX + _mouseWheelHitAreaWidth) &&
				(yMouse >= _mouseWheelHitAreaY &&
				yMouse <= _mouseWheelHitAreaY + _mouseWheelHitAreaHeight)))
			{
				var position:Number = 
					scrollPosition - lineScrollSize * event.delta;
				updateScrollPosition(position, true);
				dispatchEvent(new DisplayEvent(Event.CHANGE));
			}
		}
	}
}