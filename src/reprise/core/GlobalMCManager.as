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

package reprise.core
{ 
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	public class GlobalMCManager
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static const g_highLevelContainerDepth:Number = 10000;
		protected static const g_lowLevelContainerName:String = 'LOW_LEVEL_CONTAINER';
		protected static const g_highLevelContainerName:String = 'HIGH_LEVEL_CONTAINER';
		
		protected static var g_instance : GlobalMCManager;
		
		protected var m_stage : DisplayObjectContainer;
		protected var m_lowLevelContainer : Sprite;
		protected var m_highLevelContainer : Sprite;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function instance(
			stage : DisplayObjectContainer = null) : GlobalMCManager
		{
			if (!g_instance)
			{
				g_instance = new GlobalMCManager(stage);
			}
			return g_instance;
		}
		
		public function stage() : DisplayObjectContainer
		{
			return m_stage;
		}
		
		public function addHighLevelMc(name : String = null) : Sprite
		{
			var clip : Sprite = new Sprite();
			if (name)
			{
				clip.name = name;
			}
			m_highLevelContainer.addChild(clip);
			return clip;
		}
		
		public function addLowLevelMc(name : String = null) : Sprite
		{
			var clip : Sprite = new Sprite();
			if (name)
			{
				clip.name = name;
			}
			m_lowLevelContainer.addChild(clip);
			return clip;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function GlobalMCManager(stage : DisplayObjectContainer)
		{
			m_stage = stage;
			createLowLevelContainer(stage);
			createHighLevelContainer(stage);
		}
		
		protected function createLowLevelContainer(stage : DisplayObjectContainer) : void
		{
			//TODO: check if the changes in the AS2 version that happened in 622:15.3.08
			//are relevant to the as3 version
			m_lowLevelContainer = new Sprite();
			m_lowLevelContainer.name = 'low_level_container';
			stage.addChildAt(m_lowLevelContainer, 0);
		}
		
		protected function createHighLevelContainer(stage : DisplayObjectContainer) : void
		{
			//TODO: check if the changes in the AS2 version that happened in 622:15.3.08
			//are relevant to the as3 version
			m_highLevelContainer = new Sprite();
			m_highLevelContainer.mouseEnabled = false;
			m_highLevelContainer.name = 'high_level_container';
			stage.addChild(m_highLevelContainer);
		}
	}
}