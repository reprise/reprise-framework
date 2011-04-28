/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.ui.renderers { 
	import reprise.commands.FrameCommandExecutor;
	import reprise.utils.Delegate;
	
	
	public class DefaultTooltipRenderer extends AbstractTooltip
	{
			
		//----------------------             Public Properties              ----------------------//
		public static var className : String = "DefaultTooltipRenderer";
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var fadeIn : Delegate;
		protected var fadeOut : Delegate;
		protected var isFadingIn : Boolean;
		protected var isFadingOut : Boolean;
		protected var isVisible : Boolean;
			
		
		//----------------------               Public Methods               ----------------------//
		public function DefaultTooltipRenderer()
		{
		}
	
		
		public override function show(...args) : void
		{
			if (isFadingIn || (isVisible && !isFadingOut))
				return;
			setVisibility(true);
			isFadingOut = false;
			isFadingIn = true;
			FrameCommandExecutor.instance().removeCommand(fadeOut);
			FrameCommandExecutor.instance().addCommand(fadeIn);
		}
		
		public override function hide(...args) : void
		{
			if (isFadingOut || (!isVisible && !isFadingIn))
				return;
			isFadingIn = false;
			isFadingOut = true;
			FrameCommandExecutor.instance().removeCommand(fadeIn);
			FrameCommandExecutor.instance().addCommand(fadeOut);
		}
	
	
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initialize() : void
		{
			super.initialize();
			fadeIn = new Delegate(this, doShow);
			fadeOut = new Delegate(this, doHide);
			isFadingIn = false;
			isFadingOut = false;
			isVisible = false;
			alpha = 0;
		}
		
		protected function doShow(...rest) : void
		{
			opacity += .4;
			if (opacity >= 1)
			{
				FrameCommandExecutor.instance().removeCommand(fadeIn);
				isFadingIn = false;
				isVisible = true;
				show_complete();
			}
		}
		
		protected function doHide(...rest) : void
		{
			opacity -= .4;
			if (opacity <= 0)
			{
				FrameCommandExecutor.instance().removeCommand(fadeOut);
				isFadingOut = false;
				isVisible = false;
				hide_complete();
			}
		}	
	}
}