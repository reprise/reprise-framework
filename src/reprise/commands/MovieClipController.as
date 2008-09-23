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
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class MovieClipController 
		extends AbstractAsynchronousCommand
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
		protected var m_resetOnExecute : Boolean = false;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function MovieClipController(target:MovieClip) 
		{
			setTarget(target);
		}
		
		
		public override function execute(...args) : void
		{
			super.execute();
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
			m_target.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function setTarget(mc:MovieClip) : void
		{
			m_target = mc;
			if (m_frameRange == null)
			{
				m_frameRange = new Range(1, mc.totalFrames);
			}
		}
		
		public function setDirection(dir:Number) : void
		{
			m_direction = dir;
		}
	
		public function currentFrame() : Number
		{
			return m_target.currentFrame;
		}
		
		public function totalFrames() : Number
		{
			return m_target.totalFrames;
		}
		
		public function gotoAndStop(frame:Number) : void
		{
			frame = normalizedFrame(frame);
			m_target.gotoAndStop(frame);
		}
		
		public function gotoAndPlay(frame:Number) : void
		{
			frame = normalizedFrame(frame);
			m_target.gotoAndStop(frame);
			execute();
		}
		
		public override function cancel() : void
		{
			m_target.removeEventListener(Event.ENTER_FRAME, enterFrame);
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
				m_frameRange.location + m_frameRange.length - 1) - m_frameRange.location + 1;
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
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function notifyComplete(success:Boolean) : void
		{
			m_target.removeEventListener(Event.ENTER_FRAME, enterFrame);
			super.notifyComplete(success);
		}
		
		protected function normalizedFrame(frame:Number) : Number
		{
			frame = Math.max(frame, m_frameRange.location);
			frame = Math.min(frame, m_frameRange.location + m_frameRange.length - 1);
			return frame;
		}
		
		protected function applyFrameRange():void
		{
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
		*						FrameEventListener interface					   *
		***************************************************************************/
		public function enterFrame(e:Event) : void
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