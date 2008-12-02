//
//  Form.as
//
//  Created by Marc Bauer on 2008-06-19.
//  Copyright (c) 2008 Fork Unstable Media GmbH. All rights reserved.
//

package reprise.controls.html
{

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import reprise.commands.CompositeCommand;
	import reprise.data.IValidator;
	import reprise.events.CommandEvent;
	import reprise.events.DisplayEvent;
	import reprise.events.FormEvent;
	import reprise.ui.UIComponent;
	
	
	public class Form extends UIComponent
	{
		
		/***************************************************************************
		*                           protected properties                           *
		***************************************************************************/
		protected var m_fields:Array;
		protected var m_customValidators:Array;
		protected var m_submitButtons:Array;
		protected var m_backButtons:Array;
		protected var m_data : Object;
		protected var m_validationCommand:CompositeCommand;
		protected var m_validationDisabled:Boolean = false;
		
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
		public function Form() 
		{
			m_fields = [];
			m_submitButtons = [];
			m_backButtons = [];
			m_customValidators = [];
			addEventListener(DisplayEvent.ADDED_TO_DOCUMENT, self_displayObjectAdded);
			addEventListener(DisplayEvent.REMOVED_FROM_DOCUMENT, self_displayObjectRemoved);
		}
		
		public function data():Object
		{
			var i:int = 0;
			var data:Object = {};
			for (; i < m_fields.length; i++)
			{
				var input:IInput = m_fields[i] as IInput;
				if (!input.fieldName() || data[input.fieldName()])
				{
					continue;
				}
				data[input.fieldName()] = input.value();
			}
			return data;
		}
		
		public function activate() : void
		{
			addCSSPseudoClass('active');
		}
		
		public function deactivate() : void
		{
			removeCSSPseudoClass('active');
		}
		
		public function addCustomValidator(validator:IValidator):void
		{
			m_customValidators.push(validator);
		}
		
		public function failedValidators() : Array
		{
			var validators : Array = [];
			var i:int = 0;
			for (; i < m_fields.length; i++)
			{
				var input:IInput = m_fields[i] as IInput;
				if (input.didSucceed() || (!input.fieldName() && !input.required()))
				{
					continue;
				}
				validators.push(input);
			}
			for (i = 0; i < m_customValidators.length; i++)
			{
				var validator:IValidator = IValidator(m_customValidators[i]);
				if (!validator.didSucceed())
				{
					validators.push(validator);
				}
			}
			
			return validators;
		}
		
		public function fields():Array
		{
			// don't let anyone modify our fields
			return m_fields.concat();
		}
		
		public function fieldWithName(name:String):IInput
		{
			var i:int = m_fields.length;
			while (i--)
			{
				var field:IInput = IInput(m_fields[i]);
				if (field.fieldName() == name)
				{
					return field;
				}
			}
			return null;
		}
		
		public function setValidationDisabled(bFlag:Boolean):void
		{
			m_validationDisabled = bFlag;
		}
		
		
		
		/***************************************************************************
		*                             protected methods                            *
		***************************************************************************/
		protected override function initialize():void
		{
			super.initialize();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, self_keyDown);
		}
		
		protected function validate():void
		{
			if (m_validationDisabled)
			{
				dispatchSubmitEvent();
				return;
			}
			
			m_validationCommand = new CompositeCommand();
			m_validationCommand.setAbortOnFailure(false);
			var i:int = 0;
			var count:int = 0;
			for (; i < m_fields.length; i++)
			{
				var input:IInput = m_fields[i] as IInput;
				if (!input.fieldName() && !input.required())
				{
					continue;
				}
				m_validationCommand.addCommand(input);
				count++;
			}
			for (i = 0; i < m_customValidators.length; i++)
			{
				var validator:IValidator = IValidator(m_customValidators[i]);
				m_validationCommand.addCommand(validator);
				count++;
			}
			if (!count)
			{
				dispatchSubmitEvent();
				return;
			}
			dispatchEvent(new FormEvent(FormEvent.WILL_VALIDATE));
			m_validationCommand.addEventListener(Event.COMPLETE, validation_complete);
			m_validationCommand.execute();

			if (!m_validationCommand.isExecuting())
			{
				m_validationCommand.didSucceed() 
					? dispatchSubmitEvent()
					: dispatchEvent(new FormEvent(FormEvent.VALIDATION_FAILURE));
			}
		}
		
		protected function validation_complete(e:CommandEvent):void
		{
			log('validation complete, success ' + e.success);
			if (!e.success)
			{
				dispatchEvent(new FormEvent(FormEvent.VALIDATION_FAILURE));
				return;
			}
			dispatchEvent(new FormEvent(FormEvent.SUBMIT));
		}
		
		protected function dispatchSubmitEvent():void
		{
			dispatchEvent(new FormEvent(FormEvent.SUBMIT));
		}
		
		protected function self_displayObjectAdded(e:Event) : void
		{
			if (e.target is IInput)
			{
				m_fields.push(e.target);
			}
			
			if (!(e.target is UIComponent))
			{
				return;
			}
			
			if (e.target is SubmitButton)
			{
				m_submitButtons.push(e.target);
				(e.target as UIComponent).addEventListener(MouseEvent.CLICK, submitButton_click);
			}
			else if (e.target is BackButton)
			{
				m_backButtons.push(e.target);
				(e.target as UIComponent).addEventListener(MouseEvent.CLICK, backButton_click);
			}
		}
		
		protected function self_displayObjectRemoved(e:Event):void
		{
			if (e.target is IInput)
			{
				m_fields.splice(m_fields.indexOf(e.target), 1);
			}
			var index:int;
			if ((index = m_submitButtons.indexOf(e.target)) != -1)
			{
				(e.target as UIComponent).removeEventListener(MouseEvent.CLICK, submitButton_click);
				m_submitButtons.splice(index, 1);
			}
			else if ((index = m_backButtons.indexOf(e.target)) != -1)
			{
				(e.target as UIComponent).removeEventListener(MouseEvent.CLICK, backButton_click);
				m_backButtons.splice(index, 1);
			}
		}
		
		protected function self_keyDown(e:KeyboardEvent):void
		{
			if (e.shiftKey && e.altKey && e.keyCode == 187)
			{
				m_validationDisabled = !m_validationDisabled;
				log('d Magic key! Validation is now ' + 
					(m_validationDisabled ? 'OFF' : 'ON') + '.');
			}
		}
		
		protected function submitButton_click(e:MouseEvent):void
		{
			validate();
		}
		
		protected function backButton_click(e:MouseEvent):void
		{
			dispatchEvent(new FormEvent(FormEvent.BACK));
		}
	}
}