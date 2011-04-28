/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.commands
{
	import reprise.data.Range;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class MovieClipController 
		extends AbstractAsynchronousCommand
	{
		
		//----------------------             Public Properties              ----------------------//
		public static const DIRECTION_FORWARDS : int = 1;
		public static const DIRECTION_BACKWARDS : int = 2;

		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _target : MovieClip;
		protected var _direction : int = 1;
		protected var _frameDelay : int = 1;
		protected var _frameDelayCount : int = 0;
		protected var _frameRange : Range;
		protected var _resetOnExecute : Boolean = false;
		
		
		//----------------------               Public Methods               ----------------------//
		public function MovieClipController(target:MovieClip) 
		{
			setTarget(target);
		}
		
		
		public override function execute(...args) : void
		{
			super.execute();
			if (_resetOnExecute)
			{
				if (_direction == DIRECTION_FORWARDS)
				{
					gotoAndStop(_frameRange.location);
				}
				else
				{
					gotoAndStop(_frameRange.location + _frameRange.length - 1);
				}
			}
			else
			{
				applyFrameRange();
			}
			_target.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function setTarget(mc:MovieClip) : void
		{
			_target = mc;
			if (_frameRange == null)
			{
				_frameRange = new Range(1, mc.totalFrames);
			}
		}
		
		public function setDirection(dir:int) : void
		{
			_direction = dir;
		}
	
		public function currentFrame() : int
		{
			return _target.currentFrame;
		}
		
		public function totalFrames() : int
		{
			return _target.totalFrames;
		}
		
		public function gotoAndStop(frame:int) : void
		{
			frame = normalizedFrame(frame);
			_target.gotoAndStop(frame);
		}
		
		public function gotoAndPlay(frame:int) : void
		{
			frame = normalizedFrame(frame);
			_target.gotoAndStop(frame);
			execute();
		}
		
		public override function cancel() : void
		{
			_target.removeEventListener(Event.ENTER_FRAME, enterFrame);
			super.cancel();
		}
		
		public function setFrameDelay(delay:int) : void
		{
			_frameDelay = Math.max(0, delay);
		}
		
		public function setFrameRange(range:Range) : void
		{
			_frameRange = range.clone();
			_frameRange.location = Math.max(1, _frameRange.location);
			_frameRange.length = Math.min(totalFrames(),
				_frameRange.location + _frameRange.length - 1) - _frameRange.location + 1;
			if (isExecuting())
			{
				applyFrameRange();
			}
		}
		
		public function frameRange() : Range
		{
			return _frameRange.clone();
		}
		
		public function setResetsOnExecute(bFlag:Boolean):void
		{
			_resetOnExecute = bFlag;
		}
		
		public function resetsOnExecute():Boolean
		{
			return _resetOnExecute;
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function notifyComplete(success:Boolean) : void
		{
			_target.removeEventListener(Event.ENTER_FRAME, enterFrame);
			super.notifyComplete(success);
		}
		
		protected function normalizedFrame(frame:int) : int
		{
			frame = Math.max(frame, _frameRange.location);
			frame = Math.min(frame, _frameRange.location + _frameRange.length - 1);
			return frame;
		}
		
		protected function applyFrameRange():void
		{
			if (currentFrame() < _frameRange.location)
			{
				this.gotoAndStop(_frameRange.location);
			}
			else if (currentFrame() > _frameRange.location + _frameRange.length - 1)
			{
				this.gotoAndStop(_frameRange.location + _frameRange.length - 1);
			}
		}
		
		
		/***************************************************************************
		*						FrameEventListener interface					   *
		***************************************************************************/
		public function enterFrame(e:Event) : void
		{
			if (++_frameDelayCount < _frameDelay)
			{
				return;
			}
			_frameDelayCount = 0;
			if (_direction == DIRECTION_FORWARDS)
			{
				if (currentFrame() < _frameRange.location + _frameRange.length - 1)
				{
					_target.nextFrame();
					return;
				}
				notifyComplete(true);			
			}
			else
			{
				if (currentFrame() > _frameRange.location)
				{
					_target.prevFrame();
					return;				
				}
				notifyComplete(true);
			}
		}	
	}
}