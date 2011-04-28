/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.external
{
	import reprise.commands.CompositeCommand;
	import reprise.commands.IAsynchronousCommand;
	import reprise.commands.ICommand;
	import reprise.commands.IProgressCommand;
	import reprise.events.CommandEvent;
	import reprise.events.ResourceEvent;

	public class ResourceLoader extends CompositeCommand
		implements IProgressCommand
	{
		
		//----------------------       Private / Protected Properties       ----------------------//
		/**
		* The default number of how many resources are loaded concurrently
		*/
		public static var DEFAULT_MAX_PARALLEL_EXECUTION_COUNT : int = 3;
		
		/**
		* The number of contained resources to load
		*/
		protected var m_numResourcesToLoad:int;
		/**
		* The number of resources already loaded
		*/
		protected var m_numResourcesLoaded:int;
		/**
		* The number of bytes already loaded
		*/
		protected var m_numBytesLoaded:int;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function ResourceLoader()
		{
			m_abortOnFailure = false;
			m_maxParallelExecutionCount = DEFAULT_MAX_PARALLEL_EXECUTION_COUNT;
		}
		
		/**
		* Adds a resource to the queue. If the resource uses the <code>attach://</code> protocol
		* it is executed immediately if the <code>ResourceLoader</code> is already running.
		* 
		* @param cmd The resource to add to the queue
		*/
		public function addResource(cmd:IResource) : void
		{
			if (m_isExecuting && cmd.url().indexOf("attach://") == 0)
			{
				cmd.execute();
				m_numCommandsExecuted++;
				m_numResourcesLoaded++;
				//Some attached resources finish loading immediately, while others take a frame
				if (!IResource(cmd).didFinishLoading())
				{
					m_isExecutingAsynchronously = true;
					cmd.id = m_nextResourceId++;
					cmd.setQueueParent(this);
					m_currentCommands.push(cmd);
					registerListenersForAsynchronousCommand(IAsynchronousCommand(cmd));
					return;
				}
				else
				{
					m_numBytesLoaded += cmd.bytesTotal();
				}
				return;
			}
			addCommand(cmd);
		}
		
		/**
		* @inheritDoc
		*/
		override public function addCommand(cmd:ICommand):void
		{
			super.addCommand(cmd);
			if (cmd is IResource)
			{
				m_numResourcesToLoad++;
			}
		}
		
		/**
		* @inheritDoc
		*/
		override public function removeCommand(cmd:ICommand):void
		{
			// we only decrement the resourcesToLoad count, if the command wasn't executed
			// yet. If if was, our statistics should not be distorted
			if (cmd is IResource && m_pendingCommands.contains(cmd))
			{
				m_numResourcesToLoad--;
			}
			super.removeCommand(cmd);
		}
		
		/**
		* Starts the execution of the <code>ResourceLoader</code>. All resources using the 
		* <code>attach://</code> protocol are executed beforehand. Afterwards the super-
		* implementation is called. If the <code>ResourceLoader</code> is already running, this
		* method does nothing.
		 *
		 * Note that eagerly loading resources using the <code>attach://</code> protocol might lead to temporarily
		 * exceeding the <code>maxParallelExecutionCount</code>. This is a deliberate consequence of loading attached
		 * assets as early as possible.
		*/
		override public function execute(...args):void
		{
			if (m_isExecuting)
			{
				return;
			}
			var i : int = m_pendingCommands.length;
			while (i--)
			{
				var cmd : ICommand = ICommand(m_pendingCommands[i]);
				if (cmd is IResource && IResource(cmd).url().indexOf("attach://") == 0)
				{
					cmd.execute();
					m_numCommandsExecuted++;
					m_numResourcesToLoad--;
					m_pendingCommands.splice(i, 1);
					//Some attached resources finish loading immediately, while others take a frame
					if (IResource(cmd).didFinishLoading())
					{
						m_numResourcesLoaded++;
						continue;
					}
					registerListenersForAsynchronousCommand(IAsynchronousCommand(cmd));
					m_currentCommands.push(cmd);
				}
			}
			super.execute();
		}
		
		/**
		* Returns the total progress of all resources as a percentage value.
		* 
		* @return A percentage value containing the total progress of all contained resources
		*/
		public function progress():Number
		{
			var total:Number = m_numResourcesLoaded + m_numResourcesToLoad;
			var resourceCount : int = total;
			for (var i : int = m_currentCommands.length; i--;)
			{
				if (m_currentCommands[i] is IResource)
				{
					total += IResource(m_currentCommands[i]).progress() / 100;
					resourceCount++;
				}
			}
			return total / resourceCount * 100;
		}
		
		/**
		* Returns the number of bytes loaded of all contained resources.
		* 
		* @return The number of bytes loaded
		*/
		public function bytesLoaded() : int
		{
			var bytesLoaded : int = 0;
			var i : int = m_currentCommands.length;
			while(i--)
			{
				var cmd:ICommand = m_currentCommands[i];
				if (cmd is IResource)
				{
					bytesLoaded += IResource(cmd).bytesLoaded();
				}
			}
			return bytesLoaded + m_numBytesLoaded;
		}
		
		/**
		* @inheritDoc
		*/
		override public function reset():void
		{
			super.reset();
			m_numResourcesLoaded = 0;
			m_numBytesLoaded = 0;
			m_numResourcesToLoad = 0;
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		/**
		* Returns the progress of the resources currently being executed as a percentage value.
		*/
		protected function progressOfCurrentResources() : Number
		{
			var progress : Number = 0;
			var i : int = m_currentCommands.length;
			while(i--)
			{
				var cmd:ICommand = m_currentCommands[i];
				if (cmd is IResource)
				{
					progress += IResource(cmd).progress() / m_currentCommands.length;
				}
			}
			return progress;
		}
		
		/**
		* Registers listeners for <code>ResourceEvent.PROGRESS</code> calls super implementation
		* beforehand.
		* 
		* @param cmd The command to which the listeners should be attached to
		*/		
		override protected function registerListenersForAsynchronousCommand(
			cmd:IAsynchronousCommand):void
		{
			if (cmd is IResource)
			{
				m_numResourcesToLoad--;
			}
			super.registerListenersForAsynchronousCommand(cmd);
			cmd.addEventListener(ResourceEvent.PROGRESS, resource_progress);
		}
		
		/**
		* Unregisters listeners for <code>ResourceEvent.PROGRESS</code> calls super implementation
		* beforehand.
		* 
		* @param cmd The command from which the listeners should be removed
		*/
		override protected function unregisterListenersForAsynchronousCommand(
			cmd:IAsynchronousCommand):void
		{
			super.unregisterListenersForAsynchronousCommand(cmd);
			cmd.removeEventListener(ResourceEvent.PROGRESS, resource_progress);
		}
		
		
		
		//*****************************************************************************************
		//*                                         Events                                        *
		//*****************************************************************************************
		/**
		* Called when a resource finished execution. Updates the number of loaded bytes and calls
		* the super implementation afterwards.
		* 
		* @param The <code>CommandEvent</code>
		*/
		override protected function command_complete(e:CommandEvent):void
		{
			if (e.target is IResource)
			{
				m_numBytesLoaded += IResource(e.target).bytesLoaded();
				m_numResourcesLoaded++;
				dispatchEvent(new ResourceEvent(ResourceEvent.PROGRESS));
			}
			super.command_complete(e);
		}
		
		/**
		* Called by a <code>ResourceEvent.PROGRESS</code>.
		* 
		* @param The <code>ResourceEvent</code>
		*/
		protected function resource_progress(e:CommandEvent):void
		{
			dispatchEvent(new ResourceEvent(ResourceEvent.PROGRESS));
		}
	}
}