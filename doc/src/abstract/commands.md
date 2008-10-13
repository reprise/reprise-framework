title: Using the built-in commands of the Reprise Framework
toc-title: Using commands
toc-sort-order: 3

# Commands in the Reprise Framework

## Overview

A command is a single encapsulated task represented as an object. This way commands can be queued, recorded or made undone. Most notably is the use of commands as an elegant way to deal with the inherent asynchronous nature of the Actionscript language.

## The command interface

In it's simplest form commands need to implement a single method named `execute()`, but since commands play an important role in the Reprise framework, any custom command needs to supply a little more information about itself. We'll get to that back later when we look at how to queue commands.

## Asynchronous vs. non-asynchronous commands

There are two different kinds of commands, asynchronous and non-asynchronous commands. In general asynchronous commands are wrapped around either timers (Timer class, setInterval) or around built-in events, like `Event.ENTER_FRAME`, `Event.COMPLETE` (for loading or media playback) and events generated through user interaction, whereas non-asynchronous commands return immediately after execution. In either case should a consumer be able to learn about the success of a command execution by calling `didSucceed()` on the command, as defined in the `ICommand` interface. This is also important for queues which abort execution if any of the contained commands fails.

Due to not returning immediately, asynchronous have a slightly more complicated interface. They require a mechanism to notify a consumer when their task is completed. Fortunately if you inherit from AbstractAsynchronousCommand (which you should), most of the work is already done for you.

## A simple command

_Fig. 1 The command class_

	package
	{
		
		import reprise.commands.AbstractCommand;
		
		
		class TraceCommand extends AbstractCommand
		{
			
			protected var m_message:String;
			
			
			public function TraceCommand(message:String)
			{
				m_message = message;
			}
			
			public override function execute(...rest):void
			{
				trace(m_message);
			}
		}
	}

_Fig 1.1 Using the class_

	var traceCmd:TraceCommand = new TraceCommand('Hello World');
	traceCmd.execute(); // outputs "Hello World"

## A simple asynchronous command

_Fig. 2 The command class_

	package
	{
		
		import reprise.commands.AbstractAsynchronousCommand;
		import flash.utils.Timer;
		import flash.events.TimerEvent;
		
		
		class AsynchronousTraceCommand extends AbstractAsynchronousCommand
		{
			
			protected var m_message:String;
			protected var m_timer:Timer;
			
			
			public function AsynchronousTraceCommand(message:String, delay:int)
			{
				m_message = message;
				m_timer = new Timer(delay, 1);
				m_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_complete);
			}
			
			public override function execute(...rest):void
			{
				super.execute();
				m_timer.start();
			}
			
			public override function cancel():void
			{
				m_timer.stop();
			}
			
			protected function timer_complete(e:TimerEvent):void
			{
				trace(m_message);
				notifyComplete(true);
			}
		}
	}

_Fig. 2.1 Using the class_

	var traceCmd:AsynchronousTraceCommand = new AsynchronousTraceCommand('Hello World', 1500);
	traceCmd.execute(); // outputs "Hello World" after 1.5 seconds

## Queuing

As mentioned before an important strength of commands is their ability to be queued. Reprise accomplishes this task with the help of composite commands. Once fired, a `CompositeCommand` executes all its contained commands. If it contains solely non-asynchronous commands it will return immediately, if it contains any asynchronous commands it will notify consumers on completion via an event. 

Composite commands let you also specify how many commands you want to have run concurrently, if any. In order to maintain a queue sorted by priority, every command added to a `CompositeCommand` needs to implement the `ICommand` interface and thus implement the getter/setters `priority` and `id`. The `id` value is automatically assigned to a command after it was added to a `CompositeCommand`. It represents its index in the queue and is used to distinguish which command to execute, if two or more commands have an equal priority. In this case the command which was first pushed into the `CompositeCommand` will be executed.