/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.events
{
	import flash.events.Event;
	
	public class FormEvent extends Event
	{
		//----------------------             Public Properties              ----------------------//
		public static const SUBMIT : String = 'formSubmit';
		public static const SUBMIT_SET : String = 'formSubmitSet';
		public static const BACK : String = 'formBack';
		public static const FORM_WILL_CHANGE : String = 'formWillChange';
		public static const FORM_CHANGE : String = 'formChange';
		public static const WILL_VALIDATE : String = 'formWillValidate';
		public static const VALIDATION_FAILURE : String = 'formError';
		
		public var oldIndex : int;
		public var newIndex : int;
				
		public function FormEvent(
			type : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}