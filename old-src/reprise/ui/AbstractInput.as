/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.ui
{
	import reprise.commands.CompositeCommand;
	import reprise.commands.IAsynchronousCommand;
	import reprise.controls.html.IInput;
	import reprise.data.IValidator;
	import reprise.data.validators.EmailValidator;
	import reprise.data.validators.RegExpValidator;
	import reprise.events.CommandEvent;

	import flash.events.Event;
	import flash.events.KeyboardEvent;

	public class AbstractInput extends UIComponent 
		implements IInput
	{
		//----------------------             Public Properties              ----------------------//
		/* @TODO: properties probably should be namespaced */
		public var _priority : int = 0;
		public var _id : int;
		
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _autovalidates : Boolean = true;
		protected var _validator : IValidator;
		protected var _required : Boolean;
		protected var _fieldname : String;
		protected var _data : *;
		protected var _queueParent : CompositeCommand;

		
		//----------------------               Public Methods               ----------------------//
		public function AbstractInput() {}
		
		
		public function performValidation():void
		{
			if (!_validator)
			{
				return;
			}
			if (_validator is IAsynchronousCommand)
			{
				_validator.addEventListener(Event.COMPLETE, validator_complete);
			}
			_validator.setValue(value());
			_validator.execute();
		}
		
		public function execute(...rest):void
		{
			performValidation();
		}
		
		public function setValidator(validator:IValidator):void
		{
			_validator = validator;
		}
		
		public function validator():IValidator
		{
			return _validator;
		}
		
		public function markAsInvalid():void
		{
			addCSSPseudoClass('error');
		}
		
		public function markAsValid():void
		{
			removeCSSPseudoClass('error');
		}
		
		public function setRequired(value : Boolean) : void
		{
			_required = value;
		}
		
		/**
		 * @private
		 */
		public function setRequiredAttribute(value : String):void
		{
			_required = (value == 'required' || value == 'true');
		}
		
		public function setFormat(format : String) : void
		{
			if (format.charAt(0) == '/')
			{
				setValidator(new RegExpValidator(format));
				return;
			}
			//@TODO: implement some type of validators registry/ factory 
			switch (format)
			{
				case 'email':
				{
					setValidator(new EmailValidator());
					break;
				}
				case 'decimal':
				{
					setValidator(new RegExpValidator('/[0-9]+'));
					break;
				}
				default:
				{
					throw new Error('Input format not supported: ' + format);
				}
			}
		}
		
		public function required():Boolean
		{
			return _required;
		}
		
		public function executesAsynchronously():Boolean
		{
			return _validator ? _validator is IAsynchronousCommand : false;
		}
		
		public function validator_complete(e:CommandEvent):void
		{
			dispatchEvent(new CommandEvent(Event.COMPLETE, e.success));
		}
		
		public function didSucceed():Boolean
		{
			var success:Boolean = false;
			if (!_validator)
			{
				if (_required)
				{
					success = value() != null && value() != '';
				}
				else
				{
					success = true;
				}
			}
			else
			{
				success = _validator.didSucceed();
			}
			success ? markAsValid() : markAsInvalid();
			return success;
		}
		
		public function value():*
		{
			throw new Error('AbstractInput.value needs to be overwritten!');
			return null;
		}
		
		public function setValue(value:*):void
		{
			throw new Error('AbstractInput.setValue needs to be overwritten!');
		}
		
		public function setData(theData:*):void
		{
			_data = theData;
		}
		
		public function data():*
		{
			return _data;
		}
		
		public function setFieldName(aName:String):void
		{
			_fieldname = aName;
		}
		
		public function fieldName():String
		{
			return _fieldname;
		}
		
		public function setName(aName:String):void
		{
			setFieldName(aName);
		}
		
		public function get priority():int
		{
			return _priority;
		}
		
		public function set priority(value:int):void
		{
			_priority = value;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function set id(value:int):void
		{
			_id = value;
		}
		
		public function setQueueParent(queue : CompositeCommand) : void
		{
			_queueParent = queue;
		}
		
		public function cancel() : void
		{
			if (_validator is IAsynchronousCommand)
			{
				(_validator as IAsynchronousCommand).cancel();
			}
		}
		
		public function isCancelled() : Boolean
		{
			if (_validator is IAsynchronousCommand)
			{
				return (_validator as IAsynchronousCommand).isCancelled();
			}
			return false;
		}
		
		public function reset():void
		{
			if (_validator is IAsynchronousCommand)
			{
				(_validator as IAsynchronousCommand).reset();
			}
		}
		
		public function isExecuting():Boolean
		{
			if (_validator is IAsynchronousCommand)
			{
				return (_validator as IAsynchronousCommand).isExecuting();
			}
			return false;
		}
		
		/**
		 * sets the input focus to this Input and activates key control
		 */
		public override function setFocus(value : Boolean, method : String) : void
		{
			super.setFocus(value, method);
			if (value && _canBecomeKeyView)
			{
				this.addEventListener(KeyboardEvent.KEY_DOWN, self_keyDown);
			}
			else
			{
				this.removeEventListener(KeyboardEvent.KEY_DOWN, self_keyDown);
			}
		}
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected function self_keyDown(event : KeyboardEvent) : void
		{
			if (handleKeyEvent(event))
			{
				event.preventDefault();
				event.stopImmediatePropagation();
				event.stopPropagation();
			}
		}
		protected function handleKeyEvent(event : KeyboardEvent) : Boolean
		{
			return false;
		}
	}
}