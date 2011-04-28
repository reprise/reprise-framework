/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.transitions
{
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import reprise.commands.AbstractAsynchronousCommand;
	import reprise.data.Range;

	public class CSSMovieClipController 
		extends AbstractAsynchronousCommand
	{
		
		//----------------------             Public Properties              ----------------------//
		public static const DIRECTION_FORWARDS : int = 1;
		public static const DIRECTION_BACKWARDS : int = -1;
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _target : MovieClip;
		protected var _direction : int = 1;
		protected var _frameDelay : int = 1;
		protected var _frameDelayCount : int = 0;
		protected var _frameRange : Range;
		protected var _resetOnExecute : Boolean = false;
		protected var _operation : String;
		protected var _operationParameters : Array;
		protected var _loops : int;
		protected var _playedLoops : int;

		
		//----------------------               Public Methods               ----------------------//
		public function CSSMovieClipController(target:MovieClip) 
		{
			setTarget(target);
		}
		
		
		public override function execute(...args) : void
		{
			super.execute();
			_target.addEventListener(Event.ENTER_FRAME, target_enterFrame, false, 0, true);
			
			if (_operation)
			{
				applyOperation();
				return;
			}
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
		}

		public function setTarget(mc:MovieClip) : void
		{
			_target = mc;
			if (_frameRange == null)
			{
				_frameRange = new Range(1, mc.totalFrames);
			}
		}
		
		public function setOperation(operation : String, parameters : Array) : void
		{
			_operation = operation;
			_operationParameters = parameters;
		}
		
		public function setDirection(direction : int) : void
		{
			_direction = direction;
		}

		public function currentFrame() : int
		{
			return _target.currentFrame;
		}
		
		public function totalFrames() : int
		{
			return _target.totalFrames;
		}
		
		public function gotoAndStop(frame : int) : void
		{
			frame = normalizedFrame(frame);
			_target.gotoAndStop(frame);
		}
		
		public function gotoAndPlay(frame : int) : void
		{
			frame = normalizedFrame(frame);
			_target.gotoAndStop(frame);
			execute();
		}
		
		public override function cancel() : void
		{
			_target.removeEventListener(Event.ENTER_FRAME, target_enterFrame);
			super.cancel();
		}
		
		public function setFrameDelay(delay : int) : void
		{
			_frameDelay = Math.max(0, delay);
		}
		
		public function setFrameRange(range:Range) : void
		{
			_frameRange = range.clone();
			_frameRange.location = Math.max(1, _frameRange.location);
			_frameRange.length = Math.min(totalFrames(),
				_frameRange.location + _frameRange.length - 1) - _frameRange.location + 1;
			_direction = _frameRange.length < 0 ? DIRECTION_BACKWARDS : DIRECTION_FORWARDS;
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
		
		/**
		 * Starts playback.
		 * <p>
		 * Due to the lack of overloading, it's not possible to define two play methods that take 
		 * different parameters. Because of that, the first parameter is overloaded and takes on 
		 * different meaning depending on the second parameters' value:
		 * <p>
		 * If no parameter is provided, playback starts at the current position.
		 * <p>
		 * If the second parameter is left at its default value, the first parameter is treated 
		 * as the target frame, otherwise, it's treated as the start frame of the sequence.
		 * <p>
		 * Both parameters can be numeric frame positions or frame labels.
		 * 
		 * @param frame	The frame to play to, if the only parameter, 
		 * 				the frame to start from otherwise
		 * @param end	The frame to play to play to
		 */
		public function play(frame : * = NaN, end : * = NaN) : void
		{
			
		}
		
		/**
		 * Stops playback and moves the playhead to the given frame, if one is provided.
		 * 
		 * @param frame	The frame to move the playhead to. 
		 * 				Can be a numeric frame position or a frame label
		 */
		public function stop(frame : * = NaN) : void
		{
			
		}
		
		/**
		 * Starts looping playback by going from the start frame in the direction of needed to 
		 * reach the end frame and jumping back to the start frame once the end frame has been 
		 * reached.
		 * 
		 * @param start			The frame to start the loop from
		 * @param end			The frame to loop to
		 * @param repeatCount	[optional] The amount of repititions to play the loop. 
		 * 						0 means endlessly
		 */
		public function loop(start : int, end : int, repeatCount : int = 0) : void
		{
		}

		/**
		 * Starts looping playback by going from the start frame in the direction of needed to 
		 * reach the end frame and reversing direction once the end frame has been reached.
		 * 
		 * @param start			The frame to start the marquee from
		 * @param end			The frame to marquee to
		 * @param repeatCount	[optional] The amount of repititions to play the marquee. 
		 * 						0 means endlessly
		 */
		public function marquee(start : int, end : int, repeatCount : int = 0) : void
		{
			
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function notifyComplete(success:Boolean) : void
		{
			_target.removeEventListener(Event.ENTER_FRAME, target_enterFrame);
			super.notifyComplete(success);
		}
		
		protected function normalizedFrame(frame : int) : int
		{
			frame = Math.max(frame, _frameRange.location);
			frame = Math.min(frame, _frameRange.location + _frameRange.length - 1);
			return frame;
		}
		
		protected function applyFrameRange():void
		{
			_target.gotoAndStop(_frameRange.location);
		}
		
		protected function applyOperation() : void
		{
			var labels : Array = _target.currentLabels;
			var start : int;
			var end : int;
			switch (_operation)
			{
				case 'play':
				case 'loop':
				case 'marquee':
					{
					_loops = 1;
					_playedLoops = 0;
					if (!_operationParameters || _operationParameters.length == 0)
					{
						start = currentFrame();
						end = totalFrames();
					}
					else if (_operationParameters.length == 1)
					{
						end = absolutizeFrame(_operationParameters[0], labels);
						start = currentFrame() + 1 * (end > currentFrame() ? 1 : -1);
					}
					else
					{
						start = absolutizeFrame(_operationParameters[0], labels);
						end = absolutizeFrame(_operationParameters[1], labels);
						if (_operationParameters.length > 2 &&
							(_operation == 'loop' || _operation == 'marquee'))
						{
							_loops = _operationParameters[2];
							if (_loops == 0)
							{
								_loops = int.MAX_VALUE / 2;
							}
						}
						if (_operation == 'marquee')
						{
							_loops *= 2;
						}
					}
					if (start == 0)
					{
						start++;
					}
					setFrameRange(new Range(start, end - start));
					break;
				}
				case 'stop':
				{
					_target.gotoAndStop(_operationParameters && _operationParameters[0] ||
						_target.currentFrame);
					break;
				}
				default:
				{
					throw new Error(
						'CSSMovieClipController operation not supported: ' + _operation);
					}
			}
		}
		
		protected function absolutizeFrame(frame : *, labels : Array) : int
		{
			if (frame is int)
			{
				return frame;
			}
			if ('+-'.indexOf(frame.charAt(0)) != -1)
			{
				return currentFrame() + parseInt(frame);
			}
			for each (var label : FrameLabel in labels)
			{
				if (label.name == frame)
				{
					return label.frame;
				}
			}
			return 1;
		}

		
		/***************************************************************************
		*						FrameEventListener interface					   *
		***************************************************************************/
		protected function target_enterFrame(e:Event) : void
		{
			if (++_frameDelayCount < _frameDelay)
			{
				return;
			}
			_frameDelayCount = 0;
			if (_operation == 'stop')
			{
				notifyComplete(true);
				return;
			}
			if (currentFrame() != _frameRange.location + _frameRange.length)
			{
				_target.gotoAndStop(currentFrame() + 1 * _direction);
				if (!(currentFrame() == _frameRange.location + _frameRange.length &&
					_frameDelay == 1) || _playedLoops < _loops - 1)
				{
					return;
				}
			}
			if (++_playedLoops < _loops)
			{
				if (_operation == 'loop')
				{
					_target.gotoAndStop(_frameRange.location);
				}
				else if (_operation == 'marquee')
				{
					_frameRange.location = currentFrame();
					_frameRange.length *= -1;
					_direction *= -1;
					_target.gotoAndStop(currentFrame() + 1 * _direction);
				}
				return;
			}
			notifyComplete(true);
		}	
	}
}