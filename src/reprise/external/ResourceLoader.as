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

package reprise.external
{
	import reprise.commands.CompositeCommand;
	import reprise.commands.IAsynchronousCommand;
	import reprise.commands.ICommand;
	import reprise.commands.IProgressCommand;
	import reprise.data.collection.IndexedArray;
	import reprise.events.CommandEvent;
	import reprise.events.ResourceEvent;

	public class ResourceLoader extends CompositeCommand
		implements IProgressCommand
	{
			
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var DEFAULT_MAX_PARALLEL_EXECUTION_COUNT : Number = 3;
		protected var m_resourcesToLoad:Number;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function ResourceLoader()
		{
			m_abortOnFailure = false;
			m_maxParallelExecutionCount = DEFAULT_MAX_PARALLEL_EXECUTION_COUNT;
		}
		
		public function addResource(cmd:IResource) : void
		{
//			if (m_isExecuting && cmd.url().indexOf("attach://") == 0)
//			{
//				cmd.execute();
//				m_finishedCommands.push(cmd);
//				return;
//			}
			addCommand(cmd);
		}
		
		public override function addCommand(cmd:ICommand):void
		{
			super.addCommand(cmd);
			calculateResourcesToLoad();
		}
		
		public override function removeCommand(cmd:ICommand):void
		{
			super.removeCommand(cmd);
			calculateResourcesToLoad();		
		}
		
		public function load():void
		{
			execute();
		}
		
		public override function execute(...args):void
		{
			if (m_isExecuting)
			{
				return;
			}
			super.execute();
			var i : Number = m_pendingCommands.length;
//			while(i--)
//			{
//				var resource : IResource = IResource(m_pendingCommands[i]);
//				if (resource.url().indexOf("attach://") == 0)
//				{
//					resource.execute();
//					m_finishedCommands.push(resource);
//					m_pendingCommands.splice(i, 1);
//				}
//			}
		}
		
		public function getProgress():Number
		{
			var total:Number = m_finishedCommands.length + 
				m_currentCommands.length + m_pendingCommands.length;
			var current:Number = m_finishedCommands.length;
			return Math.round(current / (total / 100) + 
				(getProgressOfCurrentResources() / total));
		}
		
		public function bytesLoaded() : Number
		{
			var bytesLoaded : Number = 0;
			var i : Number = m_finishedCommands.length;
			while(i--)
			{
				bytesLoaded += IResource(m_finishedCommands[i]).bytesLoaded();
			}
			i = m_currentCommands.length;
			while(i--)
			{
				bytesLoaded += IResource(m_currentCommands[i]).bytesLoaded();
			}
			return bytesLoaded;
		}
		
		public function getProgressOfCurrentResources() : Number
		{
			var progress : Number = 0;
			var i : Number = m_currentCommands.length;
			while(i--)
			{
				progress += IResource(m_currentCommands[i]).getProgress() / 
					m_currentCommands.length;
			}
			return progress;
		}
		
		public function currentResources() : IndexedArray
		{
			return m_currentCommands;
		}
		
		public function containsResourceWithURL(url:String) : Boolean
		{
			return resourceWithURL(url) != null;
		}
		
		public function resourceWithURL(url:String) : IResource
		{
			var resource:IResource;
			
			var i:Number = m_pendingCommands.length;
			while (i--)
			{
				resource = IResource(m_pendingCommands[i]);
				if (resource.url() == url)
				{
					return resource;
				}
			}
			i = m_finishedCommands.length;
			while (i--)
			{
				resource = IResource(m_finishedCommands[i]);
				if (resource.url() == url)
				{
					return resource;
				}
			}
			i = m_currentCommands.length;
			while (i--)
			{
				resource = IResource(m_currentCommands[i]);
				if (resource.url() == url)
				{
					return resource;
				}
			}
			return null;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function registerListenersForAsynchronousCommand(
			cmd:IAsynchronousCommand):void
		{
			super.registerListenersForAsynchronousCommand(cmd);
			cmd.addEventListener(ResourceEvent.PROGRESS, resourceProgress);
		}
		
		protected function calculateResourcesToLoad() : void
		{
			var num : Number = 0;
			var i : Number = m_pendingCommands.length;
			while (i--)
			{
				var cmd : IResource = m_pendingCommands[i];
				if (cmd.isCancelled())
				{
					continue;
				}
				num++;
			}
			m_resourcesToLoad = num;
		}
		
		protected override function unregisterListenersForAsynchronousCommand(
			cmd:IAsynchronousCommand):void
		{
			if (!cmd)
			{
				return;
			}
			super.unregisterListenersForAsynchronousCommand(cmd);
			cmd.removeEventListener(ResourceEvent.PROGRESS, resourceProgress);
		}
		
		protected function resourceProgress(e:CommandEvent):void
		{
			dispatchEvent(new ResourceEvent(ResourceEvent.PROGRESS));
		}
	}
}