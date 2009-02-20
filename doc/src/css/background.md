title: CSS Background property
toc-title: Background


## background

### Description
A shorthand property for setting all background properties in one declaration. __Background attachment is not supported!__

### Values
* `background-color`
* `background-image`
* `background-repeat`
* `background-position`

### Examples
	background: #FF0000
	background: url(stars.gif) no-repeat top
	background: #00FF00 url(stars.gif) no-repeat top right

***

## background-image

### Description
Sets an image as the background. This can either be a bitmap or a SWF file.

### Examples
	background-image: url(url/to/my/image.png);

***

## background-color

### Description
Declares the background color.

### Values
Valid color names, RGB values, RGBA values, hexidecimal notation.

### Examples
	background-color: #fff; /* 100% white */
	background-color: #ffffff7f; /* 50% white */
	background-color: rgb(255, 255, 255); /* 100% white */
	background-color: rgba(255, 255, 255, .5); /* 50% white */

***

## background-repeat

### Description
The background-repeat property sets if/how a background image will be repeated.

### Values
`repeat`
: Default. The background image will be repeated vertically and horizontally.

`repeat-x`
: The background image will be repeated vertically.

`repeat-y`  
: The background image will be repeated horizontally.

`no-repeat`  
: The background image will be displayed only once.

### Examples
	background-repeat: repeat-x;
	background-repeat: no-repeat;


***

## background-position

### Description
The background-position property sets the starting position of a background image.

### Values
* top
* left
* center
* right
* bottom
* x%
* y%
* x px
* y px

### Examples
	background-position: 0% 100%
	background-position: bottom right
	background-position: 5px 10px


***

## background-renderer

***

## background-blend-mode

***

## background-gradient

***

## background-gradient-colors

***

## background-gradient-type

***

## background-gradient-ratios

***

## background-gradient-rotation

***

## background-scale-9

***

## background-scale-9-type

***

## background-scale9-rect

### Description
Scales a background image according to a user defined scaling rect. With Scale 9 you can resize images without distorting them. The defined rect is applied to the current background image and uses the size of the element in which the background image is drawn.

![Scale9grid](images/scale9grid.gif)

### Values
* `background-scale9-rect-top`
* `background-scale9-rect-right`
* `background-scale9-rect-bottom`
* `background-scale9-rect-left`

### Examples
![Scale9example](images/scale9example.gif)

	background-scale9-rect: 9px 8px 17px 24px; /* top right bottom left */

***

## background-scale9-rect-top

***

## background-scale9-rect-right

***

## background-scale9-rect-bottom

***

## background-scale9-rect-left

***

## background-image-type
<table>
	<tr>
		<th>Name:</th>
		<th>background-image-type</th>
	</tr>
	<tr>
		<td>Value:</td>
		<td><code>bitmap | animation</code></td>
	</tr>
	<tr>
		<td>Initial:</td>
		<td><code>bitmap</code></td>
	</tr>
	<tr>
		<td>Applies to:</td>
		<td>All elements</td>
	</tr>
	<tr>
		<td>Inherited:</td>
		<td>No</td>
	</tr>
	<tr>
		<td>Percentages:</td>
		<td>N/A</td>
	</tr>
</table>

### Description
The `background-image-type` property defines if the background image is treated as a static bitmap image or as an active swf movie that may contain animations or run code.


***

## background-image-preload

Name
: background-image-preload

Value
: preload | true | false

Initial
: false

Applies to
: N/A

Inherited
: No

Percentages
: N/A

### Description
Specifies if the CSS implementation should preload the `background-image` specified in the same declaration as this property.

Using this property, you can force images to be preloaded as part of the CSS loading process, making sure that the image is displayed immediately when first used in the view structure.

Note that this property only works in conjunction with the `background-image` property, not with background images specified in the `background` shortcut.

***

## background-image-aliasing
<table>
	<tr>
		<th>Name:</th>
		<th>background-image-aliasing</th>
	</tr>
	<tr>
		<td>Value:</td>
		<td><code>alias | anti-alias</code></td>
	</tr>
	<tr>
		<td>Initial:</td>
		<td><code>anti-alias</code></td>
	</tr>
	<tr>
		<td>Applies to:</td>
		<td>All Elements</td>
	</tr>
	<tr>
		<td>Inherited:</td>
		<td>No</td>
	</tr>
	<tr>
		<td>Percentages:</td>
		<td>N/A</td>
	</tr>
</table>

### Description
Specifies if an image used as the background image should be aliased or not. If this property is not set, the DefaultBackgroundRenderer uses `anti-alias`.

Only applies to background images for elements that don't have `background-image-type` set to `animation`.

### Examples

	background-image: url(foo.gif);
	background-image-alias: alias;