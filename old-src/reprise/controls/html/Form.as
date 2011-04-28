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
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _fields:Array;
		protected var _customValidators:Array;
		protected var _submitButtons:Array;
		protected var _backButtons:Array;
		protected var _data : Object;
		protected var _validationCommand:CompositeCommand;
		protected var _validationDisabled:Boolean = false;
		
		
		//----------------------               Public Methods               ----------------------//
		public function Form() 
		{
			_fields = [];
			_submitButtons = [];
			_backButtons = [];
			_customValidators = [];
			addEventListener(DisplayEvent.ADDED_TO_DOCUMENT, self_displayObjectAdded);
			addEventListener(DisplayEvent.REMOVED_FROM_DOCUMENT, self_displayObjectRemoved);
		}
		
		public function data():Object
		{
			var i:int = 0;
			var data:Object = {};
			for (; i < _fields.length; i++)
			{
				var input:IInput = _fields[i] as IInput;
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
			_customValidators.push(validator);
		}
		
		public function failedValidators() : Array
		{
			var validators : Array = [];
			var i:int = 0;
			for (; i < _fields.length; i++)
			{
				var input:IInput = _fields[i] as IInput;
				if (input.didSucceed() || (!input.fieldName() && !input.required()))
				{
					continue;
				}
				validators.push(input);
			}
			for (i = 0; i < _customValidators.length; i++)
			{
				var validator:IValidator = IValidator(_customValidators[i]);
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
			return _fields.concat();
		}
		
		public function fieldWithName(name:String):IInput
		{
			var i:int = _fields.length;
			while (i--)
			{
				var field:IInput = IInput(_fields[i]);
				if (field.fieldName() == name)
				{
					return field;
				}
			}
			return null;
		}
		
		public function setValidationDisabled(bFlag:Boolean):void
		{
			_validationDisabled = bFlag;
		}
		
		public function markAsValid():void
		{
			for (var i:int = 0; i < _fields.length; i++)
			{
				var input:IInput = _fields[i];
				input.markAsValid();
			}
			removeCSSPseudoClass('error');
		}
		
		public function validate():void
		{
			if (_validationDisabled)
			{
				dispatchSubmitEvent();
				return;
			}
			
			_validationCommand = new CompositeCommand();
			_validationCommand.setAbortOnFailure(false);
			var i:int = 0;
			var count:int = 0;
			for (; i < _fields.length; i++)
			{
				var input:IInput = _fields[i] as IInput;
				if (!input.fieldName() && !input.required())
				{
					continue;
				}
				_validationCommand.addCommand(input);
				count++;
			}
			for (i = 0; i < _customValidators.length; i++)
			{
				var validator:IValidator = IValidator(_customValidators[i]);
				_validationCommand.addCommand(validator);
				count++;
			}
			if (!count)
			{
				dispatchSubmitEvent();
				return;
			}
			dispatchEvent(new FormEvent(FormEvent.WILL_VALIDATE));
			_validationCommand.addEventListener(Event.COMPLETE, validation_complete);
			_validationCommand.execute();

			if (!_validationCommand.isExecuting())
			{
				validation_complete(
					new CommandEvent(Event.COMPLETE, _validationCommand.didSucceed()));
			}
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initialize():void
		{
			super.initialize();
			if (stage) stage.addEventListener(KeyboardEvent.KEY_DOWN, self_keyDown);
		}
		
		protected function validation_complete(e:CommandEvent):void
		{
			if (!e.success)
			{
				addCSSPseudoClass('error');
				dispatchEvent(new FormEvent(FormEvent.VALIDATION_FAILURE));
				return;
			}
			removeCSSPseudoClass('error');
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
				_fields.push(e.target);
			}
			
			if (!(e.target is UIComponent))
			{
				return;
			}
			
			if (e.target is SubmitButton)
			{
				_submitButtons.push(e.target);
				(e.target as UIComponent).addEventListener(MouseEvent.CLICK, submitButton_click);
			}
			else if (e.target is BackButton)
			{
				_backButtons.push(e.target);
				(e.target as UIComponent).addEventListener(MouseEvent.CLICK, backButton_click);
			}
		}
		
		protected function self_displayObjectRemoved(e:Event):void
		{
			if (e.target is IInput)
			{
				_fields.splice(_fields.indexOf(e.target), 1);
			}
			var index:int;
			if ((index = _submitButtons.indexOf(e.target)) != -1)
			{
				(e.target as UIComponent).removeEventListener(MouseEvent.CLICK, submitButton_click);
				_submitButtons.splice(index, 1);
			}
			else if ((index = _backButtons.indexOf(e.target)) != -1)
			{
				(e.target as UIComponent).removeEventListener(MouseEvent.CLICK, backButton_click);
				_backButtons.splice(index, 1);
			}
		}
		
		protected function self_keyDown(e:KeyboardEvent):void
		{
			if (e.shiftKey && e.altKey && e.keyCode == 187)
			{
				_validationDisabled = !_validationDisabled;
				log('d Magic key! Validation is now ' + 
					(_validationDisabled ? 'OFF' : 'ON') + '.');
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