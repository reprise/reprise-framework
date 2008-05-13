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

package reprise.commands
{
	import reprise.data.Range;
	import reprise.events.FrameEventBroadcaster;
	
	
	public class MovieClipController 
		extends AbstractAsynchronousCommand
		implements IFrameEventListener
	{
		
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const DIRECTION_FORWARDS : Number = 1;
		public static const DIRECTION_BACKWARDS : Number = 2;
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_target : MovieClip;
		protected var m_direction : Number = 1;
		protected var m_frameDelay : Number = 1;
		protected var m_frameDelayCount : Number = 0;
		protected var m_frameRange : Range;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function MovieClipController() {}
		
		
		public function execute() : void
		{
			super.execute();
			FrameEventBroadcaster.instance().addFrameListener(this);
		}
		
		public function setTarget(mc:MovieClip) : void
		{
			m_target = mc;
			if (m_frameRange == null)
			{
				m_frameRange = new Range(1, mc._totalframes);
			}
		}
		
		public function setDirection(dir:Number) : void
		{
			m_direction = dir;
		}
	
		public function currentFrame() : Number
		{
			return m_target._currentframe;
		}
		
		public function totalFrames() : Number
		{
			return m_target._totalframes;
		}
		
		public function gotoAndStop(frame:Number) : void
		{
			frame = normalizedFrame(frame);
			m_target.gotoAndStop(frame);
		}
		
		public function gotoAndPlay(frame:Number) : void
		{
			frame = normalizedFrame(frame);
			
			trace('normalizedFrame: ' + frame);
			
			m_target.gotoAndStop(frame);
			execute();
		}
		
		public function cancel() : void
		{
			FrameEventBroadcaster.instance().removeFrameListener(this);
			super.cancel();
		}
		
		public function setFrameDelay(delay:Number) : void
		{
			m_frameDelay = Math.max(0, delay);
		}
		
		public function setFrameRange(range:Range) : void
		{
			m_frameRange = range.clone();
			m_frameRange.location = Math.max(1, m_frameRange.location);
			m_frameRange.length = Math.min(totalFrames(), 
				m_frameRange.location + m_frameRange.length - 1);
			if (currentFrame() < m_frameRange.location)
			{
				this.gotoAndStop(m_frameRange.location);
			}
			else if (currentFrame() > m_frameRange.location + m_frameRange.length - 1)
			{
				this.gotoAndStop(m_frameRange.location + m_frameRange.length - 1);
			}
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function notifyComplete(success:Boolean) : void
		{
			FrameEventBroadcaster.instance().removeFrameListener(this);
			super.notifyComplete(success);
		}
		
		protected function normalizedFrame(frame:Number) : Number
		{
			frame = Math.max(frame, m_frameRange.location);
			frame = Math.min(frame, m_frameRange.location + m_frameRange.length - 1);
			return frame;
		}
		
		
		/***************************************************************************
		*						FrameEventListener interface					   *
		***************************************************************************/
		public function enterFrame() : void
		{
			if (++m_frameDelayCount < m_frameDelay)
			{
				return;
			}
			m_frameDelayCount = 0;
			
			if (m_direction == DIRECTION_FORWARDS)
			{
				if (currentFrame() < m_frameRange.location + m_frameRange.length - 1)
				{
					m_target.nextFrame();
					return;
				}
				notifyComplete(true);			
			}
			else
			{
				if (currentFrame() > m_frameRange.location)
				{
					m_target.prevFrame();
					return;				
				}
				notifyComplete(true);
			}
		}	
	}
}