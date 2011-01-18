/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css.transitions
{
	public class TransitionVOFactory
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_propertyHandlerClasses : Object = {};
		
	
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function TransitionVOFactory()
		{
		}
		
		public static function registerProperty(
			name : String, transitionClass : Class) : void
		{
			g_propertyHandlerClasses[name] = transitionClass;
		}
		
		public static function transitionForPropertyName(
			name : String) : PropertyTransitionVO
		{
			var transitionClass : Class = 
				g_propertyHandlerClasses [name] || NumericTransitionVO;
			return PropertyTransitionVO(new transitionClass());
		}
	}
}