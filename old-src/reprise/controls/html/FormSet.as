//
//  FormSet.as
//
//  Created by Marc Bauer on 2008-06-19.
//  Copyright (c) 2008 Fork Unstable Media GmbH. All rights reserved.
//

package reprise.controls.html
{
	import flash.events.Event;
	
	import reprise.events.DisplayEvent;
	import reprise.events.FormEvent;
	import reprise.ui.UIComponent;

	
	public class FormSet extends UIComponent
	{
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _forms:Array;
		protected var _activeFormIndex:int;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function FormSet() 
		{
		}
		
		public function data() : Array
		{
			var data : Array = [];
			for each (var form : Form in _forms)
			{
				var formData : Object = form.data();
				data.push(formData);
				if (form.cssID)
				{
					data[form.cssID] = formData;
				}
			}
			return data;
		}
		
		public function flattenedData():Object
		{
			var data:Object = {};
			for each (var form:Form in _forms)
			{
				var formData : Object = form.data();
				for (var key:String in formData)
				{
					data[key] = formData[key];
				}
			}
			return data;
		}
		
		public function activeFormIndex():int
		{
			return _activeFormIndex;
		}
		
		public function activeForm():Form
		{
			return Form(_forms[_activeFormIndex]);
		}
		
		public function numForms():int
		{
			return _forms.length;
		}
		
		public function setActiveFormIndex(index:int):void
		{
			applyFormIndex(index, false);
		}
		
		public function setValidationDisabled(bFlag:Boolean):void
		{
			for each (var form:Form in _forms)
			{
				form.setValidationDisabled(bFlag);
			}
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initialize() : void
		{
			super.initialize();
			_forms = [];
			_activeFormIndex = -1;
			addEventListener(DisplayEvent.ADDED_TO_DOCUMENT, self_displayObjectAdded);
			addEventListener(DisplayEvent.REMOVED_FROM_DOCUMENT, self_displayObjectRemoved);
		}
		
		protected override function validateBeforeChildren() : void
		{
			super.validateBeforeChildren();
			if (_firstDraw)
			{
				if (_activeFormIndex == -1)
				{
					if (_forms.length)
					{
						applyFormIndex(0, false);
					}
					return;
				}
			}
			applyFormIndex(_activeFormIndex, false);
		}

		protected function applyFormIndex(index:int, dispatchEvents : Boolean) : void
		{
			index = Math.max(Math.min(index, _forms.length - 1), 0);
			if (index == _activeFormIndex)
			{
				return;
			}

			var oldIndex:int = _activeFormIndex;
			var newIndex:int = index;
			
			var event:FormEvent;
			if (dispatchEvents && _activeFormIndex != -1)
			{
				event = new FormEvent(FormEvent.FORM_WILL_CHANGE, false, true);
				event.oldIndex = oldIndex;
				event.newIndex = newIndex;
				dispatchEvent(event);
				if (event.isDefaultPrevented())
				{
					return;
				}
			}

			if (_activeFormIndex != -1)
			{
				Form(_forms[_activeFormIndex]).deactivate();
			}
			Form(_forms[index]).activate();
			_activeFormIndex = index;
			invalidate();

			event = new FormEvent(FormEvent.FORM_CHANGE);
			event.oldIndex = oldIndex;
			event.newIndex = newIndex;
			if (dispatchEvents)
			{
				dispatchEvent(event);
			}
		}
		
		protected function addForm(form : Form) : void
		{
			_forms.push(form);
			form.addEventListener(FormEvent.SUBMIT, form_submit);
			form.addEventListener(FormEvent.BACK, form_back);
			
			if (_firstDraw)
			{
				if (_activeFormIndex == -1 || _activeFormIndex == _forms.length - 1)
				{
					applyFormIndex(_forms.length - 1, false);
				}
			}
		}
		
		protected function removeForm(form : Form) : void
		{
			var index:int = _forms.indexOf(form);
			form.removeEventListener(FormEvent.SUBMIT, form_submit);
			form.removeEventListener(FormEvent.BACK, form_back);
			_forms.splice(index, 1);
		}
		
		protected function self_displayObjectAdded(e:Event):void
		{
			if (e.target is Form)
			{
				addForm(Form(e.target));
			}
		}
		
		protected function self_displayObjectRemoved(e:Event):void
		{
			if (e.target is Form)
			{
				removeForm(Form(e.target));
			}
		}
		
		protected function form_submit(e:FormEvent):void
		{
			if (_activeFormIndex == _forms.length - 1)
			{
				dispatchEvent(new FormEvent(FormEvent.SUBMIT_SET));
			}
			else
			{
				applyFormIndex(_activeFormIndex + 1, true);
			}
		}
		
		protected function form_back(e:FormEvent):void
		{
			applyFormIndex(_activeFormIndex - 1, true);
		}
	}
}