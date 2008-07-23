title: CSS Transitions Properties
toc-title: Transitions

For more information, see the specification at
<http://webkit.org/specs/CSSVisualEffects/CSSTransitions.html>

## -reprise-transition-property

### Description
Specifies the properties to apply transitions to

### Values
* List of CSS property names

### Notes
* Right now, it's not possible to use shortcut names for properties specified here. For example, 
  you have to explicitly specify the transitions for all four borders if you want to apply a 
  transition to changing the border-width of an element.

### Example
The following declaration applies transitions to the width and the height of an element matching 
the selector:

	.myElement
	{
		-reprise-transition-property: width, height;
	}

***

## -reprise-transition-duration

### Description
Sets the duration for transitions

### Values
* List of time values with the units 's' for seconds and 'ms' for milliseconds

### Example
The following declaration sets the transitions for the width and the height to durations of 500ms 
and 2500ms, respectively:

	.myElement
	{
		-reprise-transition-property: width, height;
		-reprise-transition-duration: 500ms, 2.5s;
	}

***

## -reprise-transition-delay

### Description
Sets the delay before starting transitions

### Values
* List of time values with the units 's' for seconds and 'ms' for milliseconds

### Example
The following declaration sets the transitions for the width and the height to durations of 500ms 
and 2500ms with a delay of 1000ms and 300ms, respectively:

	.myElement
	{
		-reprise-transition-property: width, height;
		-reprise-transition-duration: 500ms, 2.5s;
		-reprise-transition-delay: 1000ms, 300ms;
	}

***

## -reprise-transition-timing-function

### Description
Sets the easing functions to be used for transitions

### Values
* List of easing function names, which can be either 'linear' or 'easeIn', 'easeOut' or 'easeInOut' 
  followed by one of the following: 
  linear, Quad, Quint, Quart, Cubic, Back, Bounce, Circ and Sine

### Default
* linear

### Example
The following declaration sets the transitions for the width and the height to durations of 500ms 
and 2500ms with quad easing and a bounce effect, respectively:

	.myElement
	{
		-reprise-transition-property: width, height;
		-reprise-transition-duration: 500ms, 2.5s;
		-reprise-transition-timing-function: easeInQuad, easeOutBounce;
	}

***

## -reprise-transition-default-value

### Description
Sets the default value to be used if no previous value can be found for a transitioned property. 
This can be used to make an element transition into its first visual state after being created.

### Values
* List of mixed property values, depending on the properties for which default values are to be 
defined.

### Example
The following declaration causes an element matching the selector path to be rolled down to its 
final height from initially having a height of 0 after being created:

	.myElement
	{
		-reprise-transition-property: height;
		-reprise-transition-duration: 500ms;
		-reprise-transition-timing-function: easeOutQuad;
		-reprise-transition-default-value: 0px;
	}

***

## -reprise-transition

### Description
Shortcut definition for all of the above properties.

### Values
* List of a combination of values for all properties described above.

### Notes
* If only one duration is given in one list entry, it is interpreted as the duration 
* If two durations are given in one list entry, the first is interpreted as the duration, second as 
  the delay
* As default values can be of any type and are thus difficult to separate from the other values 
  in a list entry, they have to be enclosed in a function definition 'default()'

### Example
The following declaration causes an element matching the selector path to be rolled down to its 
final height from initially having a height of 0 after being created:

	.myElement
	{
		-reprise-transition: height 500ms easeInOutQuad default(0px);
	}