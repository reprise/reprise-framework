title: CSS Positioning Properties
toc-title: Positioning

For more information, see the specification at
<http://webkit.org/specs/CSSVisualEffects/CSSTransitions.html>

## position
Places an element in a static, relative, absolute or fixed position

Name
: position

Value
: `static | relative | absolute | fixed`

Initial
: `static`

Applies to
: All Elements

Inherited
: No

Percentages
: N/A

Spec
: http://www.w3.org/TR/REC-CSS2/colors.html#q2

Deviations
: Some differences in stacking remain for elements that are positioned absolutely or fixed. The details of how browsers render those are hard to implement in the Flash Player. Notably, we'd need to split the borders from the rest of the element in some cases to be able to display them in front of all other elements, parent-child relationships nonwithstanding.

***

## float

Lets object flow inside a horizontal line box. Depending on the value, objects are left or right 
aligned.

Name
: float

Value
: `none | left | right`

Initial
: `none`

Applies to
: All Elements

Inherited
: No

Percentages
: N/A

Spec
: http://www.w3.org/TR/css3-box/#float

Deviations
: Support for floats is _very_ basic: We only float boxes and don't flow text around them and floats are always cleared, meaning that their line boxes are immediately closed if the next non-absolutely positioned element isn't floated. Also, we don't guarantee that the details of how floats are positioned are behaving as specified by the W3C.

All in all, floats should only be used for simple cases like horizontal navigation strips. For those cases, they work fine, though and changes in layout aren't to be expected in later versions.

***

## top

The behavior of `top` depends on how the element is specified:

* For elements with `position: static`, `top` is ignored.
* For elements with `position: relative`, `top` acts as an offset from the elements' original in-flow position. This change in position is purely presentional, it doesn't affect the flow of other elements.
* For elements with `position: absolute`, `top` acts as an offset from the top edge of the containing block.
* For elements with `position: fixed`, `top` acts as an offset from the top edge of the initial block, i.e. the document.


Name
: top

Value
: `<length> | <percentage> | auto`

Initial
: `auto`

Applies to
: All Elements

Inherited
: No

Percentages
: height of containing block

Spec
: TODO

Deviations
: None known

***

## right

The behavior of `right` depends on how the element is specified:

* For elements with `position: static`, `right` is ignored.
* For elements with `position: relative`, `right` acts as an offset from the elements' original in-flow position. This change in position is purely presentional, it doesn't affect the flow of other elements.
* For elements with `position: absolute`, `right` acts as an offset from the right edge of the containing block.
* For elements with `position: fixed`, `right` acts as an offset from the right edge of the initial block, i.e. the document.

TODO: explain the interactions between `left, right, margin-left, margin-right and position`


Name
: right

Value
: `<length> | <percentage> | auto`

Initial
: `auto`

Applies to
: All Elements

Inherited
: No

Percentages
: width of containing block

Spec
: TODO

Deviations
: None known

***

## bottom

The behavior of `bottom` depends on how the element is specified:

* For elements with `position: static`, `bottom` is ignored.
* For elements with `position: relative`, `bottom` acts as an offset from the elements' original in-flow position. This change in position is purely presentional, it doesn't affect the flow of other elements.
* For elements with `position: absolute`, `bottom` acts as an offset from the bottom edge of the containing block.
* For elements with `position: fixed`, `bottom` acts as an offset from the bottom edge of the initial block, i.e. the document.

TODO: explain the interactions between `left, right, margin-left, margin-right and position`


Name
: bottom

Value
: `<length> | <percentage> | auto`

Initial
: `auto`

Applies to
: All Elements

Inherited
: No

Percentages
: height of containing block

Spec
: TODO

Deviations
: None known

***

## left

The behavior of `left` depends on how the element is specified:

* For elements with `position: static`, `left` is ignored.
* For elements with `position: relative`, `left` acts as an offset from the elements' original in-flow position. This change in position is purely presentional, it doesn't affect the flow of other elements.
* For elements with `position: absolute`, `left` acts as an offset from the left edge of the containing block.
* For elements with `position: fixed`, `left` acts as an offset from the left edge of the initial block, i.e. the document.

TODO: explain the interactions between `left, right, margin-left, margin-right and position`


Name
: left

Value
: `<length> | <percentage> | auto`

Initial
: `auto`

Applies to
: All Elements

Inherited
: No

Percentages
: width of containing block

Spec
: TODO

Deviations
: None known

***

## overflow
Name
: overflow

Value
: `visible | hidden | scroll | auto`

Initial
: `visible`

Applies to
: All Elements

Inherited
: No

Percentages
: N/A

Spec
: http://www.w3.org/TR/css3-box/#overflow1

Deviations
: Overflow affects all descendant elements, even those with a containing block that's farther up in the display hierarchy. This isn't likely to change in the future as we can only follow the spec here by changing how we deal with descendant elements on a very fundamental level.

These properties specify whether content is clipped when it overflows the element's content area. It affects the clipping of all of the element's content except any descendant elements (and their respective content and descendants) whose containing block is the viewport or an ancestor of the element. ‘Overflow-x’ determines clipping at the left and right edges, ‘overflow-y’ at the top and bottom edges.

`overflow` is a shorthand. If it has one keyword, it sets both `overflow-x` and `overflow-y` to that keyword; if it has two, it sets `overflow-x` to the first and `overflow-y` to the second. Keywords have the following meanings:

visible
: This value indicates that content is not clipped, i.e., it may be rendered outside the content box.

hidden
: This value indicates that the content is clipped and that no scrolling mechanism should be provided to view the content outside the clipping region.

scroll
: This value indicates that the content is clipped and that if the user agent uses a scrolling mechanism that is visible on the screen (such as a scroll bar or a panner), that mechanism should be displayed for a box whether or not any of its content is clipped. This avoids any problem with scrollbars appearing and disappearing in a dynamic environment. When this value is specified and the target medium is ‘print’, overflowing content may be printed.

auto
: The behavior of the ‘auto’ value is UA-dependent, but should cause a scrolling mechanism to be provided for overflowing boxes.

***

## vertical-align

### Description
Sets the vertical alignment of an element. Of the values listed below, only top, middle, baseline, 
and bottom are supported right now.

### Values
* baseline
* sub
* super
* top (default)
* text-top
* middle
* bottom
* text-bottom
* length
* percent (%)

***

## z-index

### Description
Sets the stack order of an element. All elements that have a positive z-index are displayed in front 
of all elements without a z-index, while all elements with a negative one are displayed behind all 
elements without a z-index.

### Values
* auto (default)
* number

***

## clip

### Description
Not yet supported!
Sets the shape of an element. The element is clipped into this shape, and displayed

### Values
* shape
* auto