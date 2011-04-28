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
		protected var m_target : MovieClip;
		protected var m_direction : int = 1;
		protected var m_frameDelay : int = 1;
		protected var m_frameDelayCount : int = 0;
		protected var m_frameRange : Range;
		protected var m_resetOnExecute : Boolean = false;
		protected var m_operation : String;
		protected var m_operationParameters : Array;
		protected var m_loops : int;
		protected var m_playedLoops : int;

		
		//----------------------               Public Methods               ----------------------//
		public function CSSMovieClipController(target:MovieClip) 
		{
			setTarget(target);
		}
		
		
		public override function execute(...args) : void
		{
			super.execute();
			m_target.addEventListener(Event.ENTER_FRAME, target_enterFrame, false, 0, true);
			
			if (m_operation)
			{
				applyOperation();
				return;
			}
			if (m_resetOnExecute)
			{
				if (m_direction == DIRECTION_FORWARDS)
				{
					gotoAndStop(m_frameRange.location);
				}
				else
				{
					gotoAndStop(m_frameRange.location + m_frameRange.length - 1);
				}
			}
			else
			{
				applyFrameRange();
			}
		}

		public function setTarget(mc:MovieClip) : void
		{
			m_target = mc;
			if (m_frameRange == null)
			{
				m_frameRange = new Range(1, mc.totalFrames);
			}
		}
		
		public function setOperation(operation : String, parameters : Array) : void
		{
			m_operation = operation;
			m_operationParameters = parameters;
		}
		
		public function setDirection(direction : int) : void
		{
			m_direction = direction;
		}

		public function currentFrame() : int
		{
			return m_target.currentFrame;
		}
		
		public function totalFrames() : int
		{
			return m_target.totalFrames;
		}
		
		public function gotoAndStop(frame : int) : void
		{
			frame = normalizedFrame(frame);
			m_target.gotoAndStop(frame);
		}
		
		public function gotoAndPlay(frame : int) : void
		{
			frame = normalizedFrame(frame);
			m_target.gotoAndStop(frame);
			execute();
		}
		
		public override function cancel() : void
		{
			m_target.removeEventListener(Event.ENTER_FRAME, target_enterFrame);
			super.cancel();
		}
		
		public function setFrameDelay(delay : int) : void
		{
			m_frameDelay = Math.max(0, delay);
		}
		
		public function setFrameRange(range:Range) : void
		{
			m_frameRange = range.clone();
			m_frameRange.location = Math.max(1, m_frameRange.location);
			m_frameRange.length = Math.min(totalFrames(), 
				m_frameRange.location + m_frameRange.length - 1) - m_frameRange.location + 1;
			m_direction = m_frameRange.length < 0 ? DIRECTION_BACKWARDS : DIRECTION_FORWARDS;
			if (isExecuting())
			{
				applyFrameRange();
			}
		}
		
		public function frameRange() : Range
		{
			return m_frameRange.clone();
		}
		
		public function setResetsOnExecute(bFlag:Boolean):void
		{
			m_resetOnExecute = bFlag;
		}
		
		public function resetsOnExecute():Boolean
		{
			return m_resetOnExecute;
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
			m_target.removeEventListener(Event.ENTER_FRAME, target_enterFrame);
			super.notifyComplete(success);
		}
		
		protected function normalizedFrame(frame : int) : int
		{
			frame = Math.max(frame, m_frameRange.location);
			frame = Math.min(frame, m_frameRange.location + m_frameRange.length - 1);
			return frame;
		}
		
		protected function applyFrameRange():void
		{
			m_target.gotoAndStop(m_frameRange.location);
		}
		
		protected function applyOperation() : void
		{
			var labels : Array = m_target.currentLabels;
			var start : int;
			var end : int;
			switch (m_operation)
			{
				case 'play':
				case 'loop':
				case 'marquee':
					{
					m_loops = 1;
					m_playedLoops = 0;
					if (!m_operationParameters || m_operationParameters.length == 0)
					{
						start = currentFrame();
						end = totalFrames();
					}
					else if (m_operationParameters.length == 1)
					{
						end = absolutizeFrame(m_operationParameters[0], labels);
						start = currentFrame() + 1 * (end > currentFrame() ? 1 : -1);
					}
					else
					{
						start = absolutizeFrame(m_operationParameters[0], labels);
						end = absolutizeFrame(m_operationParameters[1], labels);
						if (m_operationParameters.length > 2 && 
							(m_operation == 'loop' || m_operation == 'marquee'))
						{
							m_loops = m_operationParameters[2];
							if (m_loops == 0)
							{
								m_loops = int.MAX_VALUE / 2;
							}
						}
						if (m_operation == 'marquee')
						{
							m_loops *= 2;
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
					m_target.gotoAndStop(m_operationParameters && m_operationParameters[0] || 
						m_target.currentFrame);
					break;
				}
				default:
				{
					throw new Error(
						'CSSMovieClipController operation not supported: ' + m_operation);
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
			if (++m_frameDelayCount < m_frameDelay)
			{
				return;
			}
			m_frameDelayCount = 0;
			if (m_operation == 'stop')
			{
				notifyComplete(true);
				return;
			}
			if (currentFrame() != m_frameRange.location + m_frameRange.length)
			{
				m_target.gotoAndStop(currentFrame() + 1 * m_direction);
				if (!(currentFrame() == m_frameRange.location + m_frameRange.length && 
					m_frameDelay == 1) || m_playedLoops < m_loops - 1)
				{
					return;
				}
			}
			if (++m_playedLoops < m_loops)
			{
				if (m_operation == 'loop')
				{
					m_target.gotoAndStop(m_frameRange.location);
				}
				else if (m_operation == 'marquee')
				{
					m_frameRange.location = currentFrame();
					m_frameRange.length *= -1;
					m_direction *= -1;
					m_target.gotoAndStop(currentFrame() + 1 * m_direction);
				}
				return;
			}
			notifyComplete(true);
		}	
	}
}