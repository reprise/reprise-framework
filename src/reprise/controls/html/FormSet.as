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
		
		/***************************************************************************
		*                           protected properties                           *
		***************************************************************************/
		protected var m_forms:Array;
		protected var m_activeFormIndex:int;
		
		
		
		/***************************************************************************
		*                              Public methods                              *
		***************************************************************************/
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
			index = Math.max(Math.min(index, m_forms.length - 1), 0);
			
			if (index == m_activeFormIndex)
			{
				return;
			}
			if (m_activeFormIndex != -1)
			{
				Form(m_forms[m_activeFormIndex]).deactivate();
			}
			var oldIndex:int = m_activeFormIndex;
			var newIndex:int = index;
			Form(m_forms[index]).activate();
			var event:FormEvent;
			if (m_activeFormIndex != -1)
			{
				event = new FormEvent(FormEvent.FORM_WILL_CHANGE);
				event.oldIndex = oldIndex;
				event.newIndex = newIndex;
				dispatchEvent(event);
			}
			m_activeFormIndex = index;
			event = new FormEvent(FormEvent.FORM_CHANGE);
			event.oldIndex = oldIndex;
			event.newIndex = newIndex;
			invalidate();
			dispatchEvent(event);
		}
		
		public function setValidationDisabled(bFlag:Boolean):void
		{
			for each (var form:Form in m_forms)
			{
				form.setValidationDisabled(bFlag);
			}
		}
		
		
		
		/***************************************************************************
		*                             protected methods                            *
		***************************************************************************/
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
						setActiveFormIndex(0);
					}
					return;
				}
			}
			setActiveFormIndex(m_activeFormIndex);
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
					setActiveFormIndex(m_forms.length - 1);
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
				setActiveFormIndex(m_activeFormIndex + 1);
			}
		}
		
		protected function form_back(e:FormEvent):void
		{
			setActiveFormIndex(m_activeFormIndex - 1);
		}
	}
}