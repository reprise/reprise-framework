/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.css
{
	import reprise.controls.csspropertyparsers.ScrollbarProperties;
	import reprise.core.reprise;
	import reprise.css.propertyparsers.Background;
	import reprise.css.propertyparsers.Border;
	import reprise.css.propertyparsers.DefaultParser;
	import reprise.css.propertyparsers.DisplayPosition;
	import reprise.css.propertyparsers.Filters;
	import reprise.css.propertyparsers.Font;
	import reprise.css.propertyparsers.Margin;
	import reprise.css.propertyparsers.Padding;
	import reprise.css.propertyparsers.Transition;
	import reprise.css.transitions.CSSTransitionsManager;
	import reprise.css.transitions.TransitionVOFactory;
	import reprise.data.AdvancedColor;

	import flash.text.StyleSheet;
	
	use namespace reprise;

	public class CSSDeclaration
	{
		//----------------------             Public Properties              ----------------------//
		reprise static const TEXT_STYLESHEET : StyleSheet = new StyleSheet();
		public static const INHERITABLE_PROPERTIES : Object = {};
		
		//----------------------       Private / Protected Properties       ----------------------//
		protected static const TEXT_PROPERTIES : Object = 
		{
			'textAlign' : true,
			'blockIndent' : true,
			'fontWeight' : true,
			'bullet' : true,
			'color' : true,
			'fontFamily' : true,
			'textIndent' : true,
			'fontStyle' : true,
			'kerning' : true,
			'leading' : true,
			'marginLeft' : true,
			'letterSpacing' : true,
			'marginRight' : true,
			'fontSize' : true,
			'tabStops' : true,
			'target' : true,
			'textDecoration' : true,
			'url' : true
		};
		protected static const g_textStyleNames : Object = {};
		
		protected static const g_propertyToParserTable : Object	= {};
		protected static const g_defaultPropertiesRegistered : Boolean = 
			registerDefaultProperties();
		
		protected var _properties : Object;
		protected var _hasDefaultValues : Boolean;
		
		// this property only exist to reduce the display of errors, 
		// if there are missing parsers
		protected static var _thrownErrors : Object	= {};
		
		
		//----------------------               Public Methods               ----------------------//
		public function CSSDeclaration()
		{
			_properties = {};
		}
		
		public static function CSSDeclarationFromObject(obj:Object) : CSSDeclaration
		{
			var decl : CSSDeclaration = new CSSDeclaration();		
			for (var key:String in obj)
			{
				decl.setStyle(key, obj[key]);
			}
			return decl;
		}
		
		public static function registerPropertyCollection(
			collection : Object /*CSSPropertyParser*/) : void
		{
			var properties : Object = collection.KNOWN_PROPERTIES;
			
			registerPropertyCollectionObject(properties, collection);
		}
		
		private static function registerPropertyCollectionObject(
			properties : Object, collection : Object) : void
		{
			var shortcuts : Object = collection.TRANSITION_SHORTCUTS || {};
			for (var prop : String in properties)
			{
				var definition : Object = properties[prop];
				g_propertyToParserTable[prop] = definition['parser'];
				if (definition['inheritable'])
				{
					INHERITABLE_PROPERTIES[prop] = true;
				}
				if (definition['transition'])
				{
					TransitionVOFactory.registerProperty(
						prop, definition['transition']);
				}
				if (shortcuts[prop])
				{
					CSSTransitionsManager.registerTransitionShortcut(
						prop, shortcuts[prop]);
				}
			}
		}

		reprise static function parserForProperty(key : String) : Function
		{
			// get the name of the associated class
			var parser : Function = g_propertyToParserTable[key];
			if (parser == null)
			{
				parser = DefaultParser.parseAnything;
				if (!_thrownErrors[key])
				{
					log('n No parser registered for css property "' + key + 
						'". Parsing property via DefaultParser (probably as string).');
					_thrownErrors[key] = true;
				}
			}		
			return parser;
		}
		
		// Alias for setPropertyForKey
		public function setStyle(key : String, value : String = null, weak : Boolean = false) : void
		{
			if (!value)
			{
				_properties[key] && delete _properties[key];
				return;
			}
			setValueForKeyDefinedInFile(value, key, '', weak);
		}
		// Alias for getPropertyForKey
		public function getStyle(key : String) : CSSProperty
		{
			return _properties[key];
		}
		public function hasStyle(key : String) : Boolean
		{
			return _properties[key] != null;
		}
		
		public function setPropertyForKey(prop : CSSProperty, key : String) : void
		{
			_properties[key] = prop;
		}
		
		public function properties() : Object
		{
			return _properties;
		}
		
		public function getValueForKey(key : String) : CSSProperty
		{
			return _properties[key];
		}
	
		// the cssdeclaration defined by argument will by default overwrite our properties
		public function mergeCSSDeclaration(otherDeclaration: CSSDeclaration, 
			inheritableStylesOnly:Boolean = false, weakly : Boolean = false) : void
		{
			var props : Object = otherDeclaration._properties;
			var otherProp : CSSProperty;
			var ourProp : CSSProperty;
			
			for (var key : String in props)
			{
				ourProp = _properties[key];
				
				// well, inheritable styles only is the deal
				if (inheritableStylesOnly && !INHERITABLE_PROPERTIES[key] && 
					!(ourProp && ourProp.inheritsValue()))
				{
					continue;
				}
				
				otherProp = props[key];
				
				// well, inheritable styles only is the deal
				if (weakly && ourProp && !ourProp.isAuto() && !otherProp.important())
				{
					continue;
				}
				
							
				// now we have two properties. so here goes the real merging
				if (ourProp && ourProp.important() && (!otherProp.important() || weakly))
				{
					continue;
				}
				
				_properties[key] = otherProp;
			}
		}
		
		public function inheritCSSDeclaration(parentDeclaration:CSSDeclaration) : void
		{
			mergeCSSDeclaration(parentDeclaration, true);
		}
		
		public function compare(otherDeclaration:CSSDeclaration) : CSSPropertiesChangeList
		{
			var ownProperties:Object = _properties;
			var changes : CSSPropertiesChangeList = new CSSPropertiesChangeList();
			var key : String;
			if (!otherDeclaration)
			{
				for (key in ownProperties)
				{
					changes.addChange(key);
				}
				return changes;
			}
			var otherProperties:Object = otherDeclaration._properties;
			var comparedProperties : Object = {};
			for (key in ownProperties)
			{
				if (ownProperties[key] != otherProperties[key])
				{
					changes.addChange(key);
				}
				comparedProperties[key] = true;
			}
			//we have to compare in both direction as for .. in doesn't allow us 
			//to know if the other object has more properties
			for (key in otherProperties)
			{
				if (comparedProperties[key])
				{
					continue;
				}
				if (ownProperties[key] != otherProperties[key])
				{
					changes.addChange(key);
				}
			}
			return changes;
		}
		
		public function clone() : CSSDeclaration
		{
			var decl : CSSDeclaration = new CSSDeclaration();
			
			for (var key:String in _properties)
			{
				decl._properties[key] = _properties[key];
			}
				
			return decl;
		}
		
		public function toComputedStyles() : ComputedStyles
		{
			var obj : ComputedStyles = new ComputedStyles();
			for (var key:String in _properties)
			{
				obj[key] = CSSProperty(_properties[key]).valueOf();
			}
			
			return obj;
		}
		
		public function toTextFormatObject() : Object
		{
			var tfObject : Object = {};
			for (var key:String in _properties)
			{
				if (TEXT_PROPERTIES[key])
				{
					tfObject[key] = CSSProperty(_properties[key]).valueOf();
				}
			}
			tfObject.color &&= AdvancedColor(tfObject.color).toString().substr(0, 7);
			return tfObject;
		}
		
		reprise function textStyleName(applyToRootNode : Boolean) : String
		{
			//build hash key
			var hash : String = '';
			for (var key:String in _properties)
			{
				if (TEXT_PROPERTIES[key])
				{
					hash += key + "_" + CSSProperty(_properties[key]).valueOf() + ",";
				}
			}
			hash += applyToRootNode;
			
			//check for existing class in stylesheet
			if (!g_textStyleNames[hash])
			{
				//prime cache for this declaration
				var styleName : String = 'style_' + TEXT_STYLESHEET.styleNames.length;
				var stylesObject : Object = toTextFormatObject();
				if (applyToRootNode)
				{
					delete stylesObject.marginLeft;
					delete stylesObject.marginRight;
				}
				TEXT_STYLESHEET.setStyle('.' + styleName, stylesObject);
				g_textStyleNames[hash] = styleName;
			}
			
			return g_textStyleNames[hash];
		}
		
		public function toString() : String
		{
			var str:String = "CSSDeclaration\n{\n";
			var props : Array = [];
			for (var key:String in _properties)
			{
				var property : CSSProperty = CSSProperty(_properties[key]);
				props.push("\t" + key + " : " + property.specifiedValue() + 
					(property.unit() || '') + "; //" + (property.cssFile() || '[no file]'));
			}
			props = props.sort();
			return str + props.join('\n') + '\n}';	
			return str + '}';
		}
		
		
		
		//----------------------         Private / Protected Methods        ----------------------//
		// internal handling of getting and setting properties
		reprise function setValueForKeyDefinedInFile(
			val:String, key:String, file:String = '', weak : Boolean = false) : void
		{
			var result : Object = CSSPropertyCache.propertyForKeyValue(key, val, file, weak);
			
			if (result is CSSProperty)
			{
				_properties[key] = result;
				return;
			}
			if (result is CSSParsingResult)
			{
				var props : Object = result.properties();
				for (key in props)
				{
					_properties[key] = props[key];
				}
				return;
			}
			var msg : String = 'c Parser for key "' + key + '" returned ';
			msg += result == null ? 'null. Perhaps you didn\'t define the ' +
				'parser method as static? Or you probably gave the parser method ' +
				'a wrong name. Or you even forgot to implement it. Double-check ' +
				'and retry!' : 'value of wrong type.';
			msg += 'Parsing property via DefaultParser (probably as String).';
			
			result = DefaultParser.parseAnything(val, file);
			_properties[key] = result;
			
			log(msg);
		}
		
		protected static function registerDefaultProperties() : Boolean
		{
			registerPropertyCollection(Background);
			registerPropertyCollection(Border);
			registerPropertyCollection(DisplayPosition);
			registerPropertyCollection(Font);
			registerPropertyCollection(Margin);
			registerPropertyCollection(Padding);
			registerPropertyCollection(ScrollbarProperties);
			registerPropertyCollection(Filters);
			registerPropertyCollection(Transition);
			return true;
		}
	}
}