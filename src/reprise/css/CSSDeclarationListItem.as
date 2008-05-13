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

package reprise.css
{
	public class CSSDeclarationListItem
	{	
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		public var m_declarationSpecificity : Number;
		public var m_declarationIndex : Number;
		
		protected var m_selector : String;
		protected var m_selectorPattern : Array;
		public var m_declaration : CSSDeclaration;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSDeclarationListItem(selector : String, 
			declaration : CSSDeclaration, index : Number, file : String = null) 
		{
			m_selector = selector;
			var selectorStr : String = (("@" + selector.split(" ").join("@ @").
				split("#").join("|#").split(":").join("|:").split(".").
				join("|.")).split("||").join("|").split("|").join("@|@").
				split(">@").join("@>").split('>').join('|>') + "@").split("@@").join("@").
				split(' @|@').join(' @');
			if (selectorStr.substr(0, 3) == '@|@')
			{
				selectorStr = selectorStr.substr(2);
			}
			m_selectorPattern = selectorStr.split(' ');
			var i : int = m_selectorPattern.length;
			while (i--)
			{
				m_selectorPattern[i] = m_selectorPattern[i].split('|');
			}
			
			m_declarationSpecificity = specificityForSelector(selector);
			m_declarationIndex = index;
			m_declaration = CSSDeclaration(declaration);
		}
		
		public function declaration() : CSSDeclaration
		{
			return m_declaration;
		}
		
		public function matchesSubjectPath(subjectPath:String) : Boolean
		{
			var subjectIndex : Number = subjectPath.length;
			var minSubjectIndex : Number = subjectPath.lastIndexOf(" ") + 1;
			var patternOffset : int = 1;
			subjectPath += " ";
			
			var i : int = m_selectorPattern.length;
			while(i--)
			{
				//get pattern for the current element from the itemPath
//				var currentPattern : Array = patterns.pop().split("|");
				var currentPattern : Array = m_selectorPattern[i];
				var subjectPartBegin : Number;
				var patternPart : String = 
					currentPattern[currentPattern.length - patternOffset];
				patternOffset = 1;
				
				//match every element in subjectPath if the current patternPart is
				//a wildcard
				if (patternPart == "@*@" && currentPattern.length == 1)
				{
					subjectPartBegin = 
						subjectPath.lastIndexOf(" ", subjectIndex - 1);
				}
				else 
				{
					//check if the first element of the patternPart is in the 
					//subjectpath at a valid position.
					var patternInSubjectIndex : Number = 
						subjectPath.lastIndexOf(patternPart, subjectIndex);
					if (patternInSubjectIndex < minSubjectIndex)
					{
						return false;
					}
					subjectPartBegin = 
						subjectPath.lastIndexOf(" ", patternInSubjectIndex);
					var subjectPartEnd : Number = 
						subjectPath.indexOf(" ", patternInSubjectIndex);
					var currentSubjectPart : String = 
						subjectPath.substring(subjectPartBegin + 1, subjectPartEnd);
					
					//match all parts of the current pattern to the part of the 
					//subjectPath where the first patternPart occured only.
					var j : int = currentPattern.length - 1;
					while(j--)
					{
						patternPart = currentPattern[j];
						if (currentSubjectPart.indexOf(patternPart) == -1)
						{
							return false;
						}
					}
				}
				
				//check if the pattern mandates a direct parent child relationship
				//between the current and the next part and allow matches 
				//in the next part only if true.
				var nextPattern : Array = m_selectorPattern[i - 1];
				if (nextPattern && nextPattern[nextPattern.length - 1] == ">")
				{
					minSubjectIndex = 
						subjectPath.lastIndexOf(" ", subjectPartBegin - 1) + 1;
					patternOffset = 2;
				}
				else 
				{
					minSubjectIndex = 0;
				}
				subjectIndex = subjectPartBegin;
			}
			return true;
		}
		
//		public function matchesElement(element : ICSSStylable) : Boolean
//		{
//			var path : String = element.selectorPath;
//			var matches : Boolean = m_selectorRegexp.test(path);
//			if (matches)
//			{
//				trace(['match ', m_selectorRegexp, path, ''].join('\n'));
//				return true;
//			}
//			return false;
//		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function specificityForSelector(selector:String) : Number
		{
			var patterns : Array = selector.split(' ');
			var spec : Number = 0;
			var i : Number = patterns.length;
			
			while (i--)
			{
				spec += specificityForPattern(patterns[i]);
			}			
			return spec;
		}
		
		protected function specificityForPattern(pattern:String) : Number
		{
			var specificityFactorElement : Number = 1;
			var specificityFactorClass : Number = 10;
			var specificityFactorId : Number = 100;
	
			var spec : Number = 0;
			var patternParts : Array = pattern.split('.');
			
			//add specificity of classes multiplied by class count
			spec += (patternParts.length - 1) * specificityFactorClass;
			
			patternParts = patternParts[0].split('#');
			if (patternParts[0] != '')
			{
				spec += specificityFactorElement;
			}
			if (patternParts[1])
			{
				spec += specificityFactorId;
			}
			return spec;
		}
		
//		protected function createRegExp(path : String) : RegExp
//		{
//			var pathParts : Array = path.split(' ');
//			var i : uint = pathParts.length;
//			while(i--)
//			{
//				pathParts[i] = parsePathPart(pathParts[i]);
//			}
//			
//			//some cleanup
//			var pathExp : String = pathParts.join('.*').split('[\\w.:]*.*').join('.*');
//			return new RegExp('.*' + pathExp + '[ ]$');
//		}
//		
//		protected function parsePathPart(part : String) : String
//		{
//			//deal with direct descendand demands
//			if (part.indexOf('>') != -1)
//			{
//				var subParts : Array = part.split('>');
//				var i : uint = subParts.length;
//				while(i--)
//				{
//					subParts[i] = parsePathPart(subParts[i]);
//				}
//				return subParts.join('');
//			}
//			//deal with wildcard selector
//			if (part == '*')
//			{
//				//match everything as long as it's not a space
//				return '[^ ]+';
//			}
//			//remove wildcard if it's not the only character in the part
//			part = part.split('*').join('');
//			
//			//create expression for this part
//			var pathExp : String = ' ';
//			//split into tag, id and classes
//			var splitter : RegExp = /(\w+)*(#\w+)*([.:\w]*)/;
//			var result : Array = splitter.exec(part);
//			
//			var tag : String = result[1];
//			var id : String = result[2];
//			if (!tag && !id)
//			{
//				//match all tags and ids and beginning of classes
//				pathExp += '[\\w#.:]+';
//			}
//			else if (tag && !id)
//			{
//				//match specified tag and all ids and beginning of classes
//				pathExp += tag + '[#\\w.:]*';
//			}
//			else if (!tag && id)
//			{
//				//match all tags and specified id and beginning of classes
//				pathExp += '\\w+' + id + '[\\w.:]*';
//			}
//			else
//			{
//				//match specified tag and id and beginning of classes
//				pathExp += tag + id + '[\\w.:]*';
//			}
//			
//			//add test for classes
//			var classesStr : String = result[3];
//			if (!classesStr)
//			{
//				//don't add anything, we already match all classes
//				return pathExp;
//			}
//			
//			//split classes and sort ascending
//			var classes : Array = classesStr.split(':').join('.:').split('.').sort();
//			//discard empty first element
//			classes.shift();
//			for each (var className : String in classes)
//			{
//				if (className.charAt(0) != ':')
//				{
//					pathExp += '[.]';
//				}
//				pathExp += className + '(?=[.: ])[\\w.:]*';
//			}
//			
//			return pathExp;
//		}
	}
}