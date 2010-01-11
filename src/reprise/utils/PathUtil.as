/*
* Copyright (c) 2006-2010 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package reprise.utils
{ 
	import reprise.data.Range;
	
	
	public class PathUtil
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function pathComponents(path:String) : Array
		{
			var components : Array = path.split('/');
			
			if (!components.length)
			{
				return components;
			}
			
			if (components[0].length == 0)
			{
				components[0] = '/';
			}
			
			var i : int = components.length;
			while (i-- > 1)
			{
				if (components[i].length == 0)
				{
					components.splice(i, 1);
				}
			}
			
			return components;
		}
		
		public static function stringByStandardizingPath(path:String) : String
		{
			// doing this twice removes three slashes
			path = path.split('//').join('/').split('//').join('/').split('/./').join('/');
			
			var searchRange : Range = new Range(0, path.length);
			var foundIndex : int = StringUtil.indexOfStringInRange(path, '../', searchRange);
	
			while (foundIndex - searchRange.location == 0)
			{
				searchRange.location += 3;
				searchRange.length = path.length - searchRange.location;				
				foundIndex = StringUtil.indexOfStringInRange(path, '../', searchRange);
			}
			
			foundIndex = StringUtil.indexOfStringInRange(path, '/../', searchRange);		
			while (foundIndex != -1)
			{
				var lastSlashIndex : int = StringUtil.indexOfStringInRange(
					path, '/', new Range(0, foundIndex), StringUtil.BACKWARDS_SEARCH);			
				if (lastSlashIndex == -1)
				{
					path = StringUtil.stringByDeletingCharactersInRange(path, new Range(0, 3));
				}
				else
				{
					path = StringUtil.stringByDeletingCharactersInRange(
						path, new Range(lastSlashIndex, foundIndex - lastSlashIndex + 3));
				}
				searchRange.length = path.length - searchRange.location;
				foundIndex = StringUtil.indexOfStringInRange(path, '/../', searchRange);
			}
			return path;
		}
		
		public static function stringByAppendingPathComponent(input:String, component:String) : String
		{
			if (component.indexOf('/') == 0)
			{
				component = component.substr(0, component.length - 1);
			}
			if (input.lastIndexOf('/') != input.length - 1)
			{
				input += '/';
			}
			return input + component;
		}
		
		public static function pathWithComponents(components:Array) : String
		{
			var path:String = components[0];
			for (var i : int = 1; i < components.length; i++)
			{
				path = stringByAppendingPathComponent(path, components[i]);
			}
			return path;
		}
		
		public static function isAbsolutePath(path:String) : Boolean
		{
			return path.charAt(0) == '/';
		}
		
		public static function pathExtension(path:String) : String
		{
			if (path == null)
			{
				return '';
			}
			var dotIndex:int = path.lastIndexOf('.');
	
			if (dotIndex == -1)
			{
				return '';
			}
			
			var sepIndex:int = path.lastIndexOf('/');
			if (sepIndex != -1 && dotIndex < sepIndex)
			{
				return '';
			}
			
			return path.substring(dotIndex + 1);
		}
		
		public static function lastPathComponent(path:String) : String
		{
			var sepIndex:int = path.lastIndexOf('/');
			var component : String;
			
			if (sepIndex == -1)
			{
				component = '';
			}
			else
			{
				if (sepIndex == path.length - 1)
				{
					if (sepIndex == 0)
					{
						component = '';
					}
					else
					{
						component = lastPathComponent(path.substring(0, sepIndex));
					}
				}
				else
				{
					component = path.substring(sepIndex + 1);
				}
			}
			return component;
		}
		
		public static function stringByDeletingLastPathComponent(path:String) : String
		{		
			var index:int = path.lastIndexOf(lastPathComponent(path));
			if (index == -1)
			{
				return path;
			}
			if (index == 0)
			{
				return '';
			}
			
			if (index > 1)
			{
				return path.substring(0, index - 1);
			}
			else
			{
				return '/';
			}
		}
	
		/**
		* Converts a relative path into an absolute path by resolving the relative path 
		* <code>resolvee</code> to a given absolute path <code>base</code>.
		* 
		* If <code>base</code> is <code>null</code> or <code>resolvee</code> is already an absolute 
		* path, the method returns the value of <code>resolvee</code> unaltered.
		* 
		* @param resolvee A relative path to be converted into an absolute path
		* @param base An absolute path to be used as the root for the relative path
		* 
		* @return The resolved absolute path
		*/
		public static function stringByResolvingRelativePathToPath(resolvee:String, 
			base:String = null) : String
		{
			resolvee = stringByStandardizingPath(resolvee);
			if (!base)
			{
				return resolvee;
			}
			base = stringByStandardizingPath(base);
			
			if (isAbsolutePath(resolvee))
			{
				return resolvee;
			}
	
			var resolveeComponents : Array = pathComponents(resolvee);
			var baseComponents : Array = pathComponents(base);
			var lastComponent : String = '';
	
			if (pathExtension(resolvee) != '')
			{
				lastComponent = String(resolveeComponents.pop());
			}
	
			for (var i : int = 0; i < resolveeComponents.length; i++)
			{
				var currentDirPart:String = resolveeComponents[i];
				if (currentDirPart == '..')
				{
					baseComponents.pop();
				}
				else
				{
					baseComponents.push(currentDirPart);
				}
			}
			baseComponents.push(lastComponent);		
			
			return stringByStandardizingPath(pathWithComponents(baseComponents));
		}
		
		/**
		 * Takes two absolute paths and returns a relative path that would resolve 
		 * to the second absolute path if related to the first absolute path.
		 * 
		 * @param basePath The path to make the filename relative to
		 * @param filename The path to make relative to the basePath
		 * 
		 * @return A relative path to filename 
		 */
		public static function relativePathToFilename(
			basePath : String, filename : String) : String
		{
			filename = stringByStandardizingPath(filename);
			var commonRoot : Array = 
				commonRootPathComponents(stringByStandardizingPath(basePath), filename);
			
			if (commonRoot == null)
			{
				return filename;
			}
			
			var uniquePart1 : Array = 
				pathComponents(basePath).slice(commonRoot.length - 1);
			var uniquePart2 : Array = 
				pathComponents(filename).slice(commonRoot.length - 1);
			
			var numberOfStepsUp : int = uniquePart1.length;
			if (uniquePart1[uniquePart1.length - 1] == '')
			{
				numberOfStepsUp--;
			}
			if (numberOfStepsUp < 1)
			{
				return uniquePart2.join('/');
			}
			
			var stepsUpArray : Array = uniquePart2.concat();
			for (var i : int = 0; i < numberOfStepsUp; i++)
			{
				var steppingUpPast : String = uniquePart1[i];
				if (steppingUpPast == '..')
				{
					if (stepsUpArray[0] == '..')
					{
						stepsUpArray.shift();
					}
					else
					{
						return null;
					}
				}
				else
				{
					stepsUpArray.unshift('..');
				}
			}
			
			return stringByStandardizingPath(pathWithComponents(stepsUpArray));
		}	
		
		public static function commonRootPathComponents(file1:String, file2:String) : Array
		{
			var filename1Array : Array = pathComponents(file1);
			var filename2Array : Array = pathComponents(file2);
			var minLength : int = int(Math.min(filename1Array.length, filename2Array.length));
			var resultArray : Array = [];
			
			for (var i : int = 0; i < minLength; i++)
			{
				if (filename1Array[i] == filename2Array[i])
				{
					resultArray.push(filename1Array[i]);
				}
				else
				{
					break;
				}
			}
			
			if (!resultArray.length)
			{
				return null;
			}
			
			return resultArray;
		}	
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function PathUtil() {}	
	}
}