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
		protected var m_forms:Array;
		protected var m_activeFormIndex:int;
		
		
		
		//----------------------               Public Methods               ----------------------//
		public function FormSet() 
		{
		}
		
		public function data() : Array
		{
			var data : Array = [];
			for each (var form : Form in m_forms)
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
			for each (var form:Form in m_forms)
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
			return m_activeFormIndex;
		}
		
		public function activeForm():Form
		{
			return Form(m_forms[m_activeFormIndex]);
		}
		
		public function numForms():int
		{
			return m_forms.length;
		}
		
		public function setActiveFormIndex(index:int):void
		{
			applyFormIndex(index, false);
		}
		
		public function setValidationDisabled(bFlag:Boolean):void
		{
			for each (var form:Form in m_forms)
			{
				form.setValidationDisabled(bFlag);
			}
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		protected override function initialize() : void
		{
			super.initialize();
			m_forms = [];
			m_activeFormIndex = -1;
			addEventListener(DisplayEvent.ADDED_TO_DOCUMENT, self_displayObjectAdded);
			addEventListener(DisplayEvent.REMOVED_FROM_DOCUMENT, self_displayObjectRemoved);
		}
		
		protected override function validateBeforeChildren() : void
		{
			super.validateBeforeChildren();
			if (m_firstDraw)
			{
				if (m_activeFormIndex == -1)
				{
					if (m_forms.length)
					{
						applyFormIndex(0, false);
					}
					return;
				}
			}
			applyFormIndex(m_activeFormIndex, false);
		}

		protected function applyFormIndex(index:int, dispatchEvents : Boolean) : void
		{
			index = Math.max(Math.min(index, m_forms.length - 1), 0);
			if (index == m_activeFormIndex)
			{
				return;
			}

			var oldIndex:int = m_activeFormIndex;
			var newIndex:int = index;
			
			var event:FormEvent;
			if (dispatchEvents && m_activeFormIndex != -1)
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

			if (m_activeFormIndex != -1)
			{
				Form(m_forms[m_activeFormIndex]).deactivate();
			}
			Form(m_forms[index]).activate();
			m_activeFormIndex = index;
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
			m_forms.push(form);
			form.addEventListener(FormEvent.SUBMIT, form_submit);
			form.addEventListener(FormEvent.BACK, form_back);
			
			if (m_firstDraw)
			{
				if (m_activeFormIndex == -1 || m_activeFormIndex == m_forms.length - 1)
				{
					applyFormIndex(m_forms.length - 1, false);
				}
			}
		}
		
		protected function removeForm(form : Form) : void
		{
			var index:int = m_forms.indexOf(form);
			form.removeEventListener(FormEvent.SUBMIT, form_submit);
			form.removeEventListener(FormEvent.BACK, form_back);
			m_forms.splice(index, 1);
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
			if (m_activeFormIndex == m_forms.length - 1)
			{
				dispatchEvent(new FormEvent(FormEvent.SUBMIT_SET));
			}
			else
			{
				applyFormIndex(m_activeFormIndex + 1, true);
			}
		}
		
		protected function form_back(e:FormEvent):void
		{
			applyFormIndex(m_activeFormIndex - 1, true);
		}
	}
}