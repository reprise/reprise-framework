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

package reprise.ui
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import reprise.commands.IAsynchronousCommand;
	import reprise.controls.html.IInput;
	import reprise.data.IValidator;
	import reprise.data.validators.EmailValidator;
	import reprise.data.validators.RegExpValidator;
	import reprise.events.CommandEvent;
	
	
	public class AbstractInput extends UIComponent 
		implements IInput
	{
		/***************************************************************************
		*                             Public properties                            *
		***************************************************************************/
		/* @TODO: properties probably should be namespaced */
		public var m_priority : Number = 0;
		public var m_id : Number;
		
		
		/***************************************************************************
		*                           Protected properties                           *
		***************************************************************************/
		protected var m_autovalidates : Boolean = true;
		protected var m_validator : IValidator;
		protected var m_required : Boolean;
		protected var m_fieldname : String;
		protected var m_data:*;
		
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function AbstractInput() {}
		
		
		public function performValidation():void
		{
			if (!m_validator)
			{
				return;
			}
			if (m_validator is IAsynchronousCommand)
			{
				m_validator.addEventListener(Event.COMPLETE, validator_complete);
			}
			m_validator.setValue(value());
			m_validator.execute();
		}
		
		public function execute(...rest):void
		{
			performValidation();
		}
		
		public function setValidator(validator:IValidator):void
		{
			m_validator = validator;
		}
		
		public function validator():IValidator
		{
			return m_validator;
		}
		
		public function markAsInvalid():void
		{
			addCSSPseudoClass('error');
		}
		
		public function markAsValid():void
		{
			removePseudoClass('error');
		}
		
		public function setRequired(value : Boolean) : void
		{
			m_required = value;
		}
		
		/**
		 * @private
		 */
		public function setRequiredAttribute(value : String):void
		{
			m_required = (value == 'required' || value == 'true');
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
				default:
				{
					throw new Error('Input format not supported: ' + format);
				}
			}
		}
		
		public function required():Boolean
		{
			return m_required;
		}
		
		public function executesAsynchronously():Boolean
		{
			return m_validator ? m_validator is IAsynchronousCommand : false;
		}
		
		public function validator_complete(e:CommandEvent):void
		{
			dispatchEvent(new CommandEvent(Event.COMPLETE, e.success));
		}
		
		public function didSucceed():Boolean
		{
			var success:Boolean = false;
			if (!m_validator)
			{
				if (m_required)
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
				success = m_validator.didSucceed();
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
			m_data = theData;
		}
		
		public function data():*
		{
			return m_data;
		}
		
		public function setFieldName(aName:String):void
		{
			m_fieldname = aName;
		}
		
		public function fieldName():String
		{
			return m_fieldname;
		}
		
		public function setName(aName:String):void
		{
			setFieldName(aName);
		}
		
		public function get priority():Number
		{
			return m_priority;
		}
		
		public function set priority(value:Number):void
		{
			m_priority = value;
		}
		
		public function get id():Number
		{
			return m_id;
		}
		
		public function set id(value:Number):void
		{
			m_id = value;
		}
		
		public function cancel() : void
		{
			if (m_validator is IAsynchronousCommand)
			{
				(m_validator as IAsynchronousCommand).cancel();
			}
		}
		
		public function isCancelled() : Boolean
		{
			if (m_validator is IAsynchronousCommand)
			{
				return (m_validator as IAsynchronousCommand).isCancelled();
			}
			return false;
		}
		
		public function reset():void
		{
			if (m_validator is IAsynchronousCommand)
			{
				(m_validator as IAsynchronousCommand).reset();
			}
		}
		
		public function isExecuting():Boolean
		{
			if (m_validator is IAsynchronousCommand)
			{
				return (m_validator as IAsynchronousCommand).isExecuting();
			}
			return false;
		}
		
		/**
		 * sets the input focus to this Input and activates key control
		 */
		public override function setFocus(value : Boolean, method : String) : void
		{
			super.setFocus(value, method);
			if (value && m_canBecomeKeyView)
			{
				this.addEventListener(KeyboardEvent.KEY_DOWN, self_keyDown);
			}
			else
			{
				this.removeEventListener(KeyboardEvent.KEY_DOWN, self_keyDown);
			}
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
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