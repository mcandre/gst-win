PK
     �Mh@;,�#8  #8    CairoPattern.stUT	 cqXO��XOux �  �  "======================================================================
|
|   CairoPattern wrapper class for libcairo
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones and Michael Bridgen.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


BlockClosure extend [
    maskOn: context [
	"Private - Used by Cairo to do double-dispatch on #mask:"

	<category: 'cairo double dispatch'>
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo mask: context pattern: pattern
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    on: context withSourceDo: paintBlock [
	"Private - Used by Cairo to do double-dispatch on #withSource:do:"

	<category: 'cairo double dispatch'>
	| pattern source |
	source := Cairo.Cairo getSource: context.
	Cairo.Cairo patternReference: source.
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	    paintBlock value
	] ensure: [
	    source isNil ifFalse: [
		Cairo.Cairo
		    setSource: context source: source;
		    patternDestroy: source ].
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    setSourceOn: context [
	"Private - Used by Cairo to do double-dispatch on #source:"

	<category: 'cairo double dispatch'>
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]
]

Object subclass: CairoPattern [
    | cachedPattern canonical |

    Patterns := nil.
    CairoPattern class >> initialize [
	"Initialize the dictionary of patterns that have a C
	 representation."

	<category: 'initialize'>
	Patterns := WeakKeyDictionary new.
	ObjectMemory addDependent: self.
    ]

    CairoPattern class >> update: aspect [
	"Clear the dictionary of patterns that have a C
	 representation."

	<category: 'private-persistence'>
	aspect == #returnFromSnapshot ifTrue: [
	    Patterns do: [ :each | each release ].
	    Patterns := WeakKeyDictionary new].
    ]

    cachedPattern [
	"Return the C representation of the pattern."

	<category: 'private-persistence'>
	cachedPattern isNil ifFalse: [ ^cachedPattern ].
	Patterns at: self put: self.
	self addToBeFinalized.
	canonical := self.
	^cachedPattern := self createCachedPattern
    ]

    pattern [
	"Return the C representation of the pattern, looking it up
	 in the Patterns class variable and associating it to the
	 receiver if none is found."

	<category: 'private-persistence'>
	canonical isNil
	    ifTrue: [ canonical := Patterns at: self ifAbsentPut: [ self ] ].

	^canonical cachedPattern
    ]

    createCachedPattern [
	"Private - Create the CObject representing the pattern."

	<category: 'C interface'>
	self subclassResponsibility.
    ]


    postCopy [
	"We reference the same canonical object, but the pattern lives
	 in the canonical object, not in this one."

	<category: 'private-persistence'>
	cachedPattern := nil.
    ]

    finalize [
	<category: 'private-persistence'>
	cachedPattern ifNotNil: [ :p |
	    cachedPattern := nil.
	    Cairo patternDestroy: p ].
    ]
	
    release [
	<category: 'private-persistence'>
	super release.
	canonical isNil ifTrue: [
	    canonical := Patterns at: self ifAbsent: [nil].
	    canonical isNil ifTrue: [ ^self ]].
	canonical == self
	    ifFalse: [ canonical release ]
	    ifTrue: [
		Patterns removeKey: self ifAbsent: [].
		self finalize.
		self removeToBeFinalized ].

	canonical := nil.
    ]

    maskOn: context [
	"Private - Used by Cairo to do double-dispatch on #mask:"

	<category: 'cairo double dispatch'>
	Cairo.Cairo mask: context pattern: self pattern
    ]

    setSourceOn: context [
	"Private - Used by Cairo to do double-dispatch on #source:"

	<category: 'cairo double dispatch'>
	Cairo setSource: context source: self pattern
    ]

    on: context withSourceDo: paintBlock [
	"Private - Used by Cairo to do double-dispatch on #withSource:do:"

	<category: 'cairo double dispatch'>
	| pattern source |
	source := Cairo getSource: context.
	Cairo patternReference: source.
	[
	    self setSourceOn: context.
	    paintBlock value
	] ensure: [
	    source isNil ifFalse: [
		Cairo
		    setSource: context source: source;
		    patternDestroy: source ].
	].
    ]
].

CairoPattern subclass: CairoPatternDecorator [
    | wrappedPattern |
    CairoPatternDecorator class >> on: aPattern [
	<category: 'instance creation'>
	^self new wrappedPattern: aPattern; yourself
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    self wrappedPattern = anObject wrappedPattern ]
    ]

    hash [
	<category: 'basic'>
	^self class hash bitXor: self wrappedPattern hash
    ]

    wrappedPattern [
	<category: 'accessing'>
	^wrappedPattern
    ]

    wrappedPattern: aPattern [
	<category: 'private-accessing'>
	wrappedPattern := aPattern
    ]
]

CairoPatternDecorator subclass: ReflectedPattern [
    createCachedPattern [
	<category: 'C interface'>
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendReflect.
	^result
    ]
]

CairoPatternDecorator subclass: RepeatedPattern [
    createCachedPattern [
	<category: 'C interface'>
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendRepeat.
	^result
    ]
]

CairoPatternDecorator subclass: PaddedPattern [
    createCachedPattern [
	<category: 'C interface'>
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendPad.
	^result
    ]
]

CairoPattern subclass: SurfacePattern [
    | surface |

    SurfacePattern class >> on: aSurface [
	<category: 'instance creation'>
	^self new surface: aSurface; yourself
    ]

    surface [
	<category: 'accessing'>
	^ surface
    ]

    surface: aCairoSurface [
	<category: 'private-accessing'>
	surface := aCairoSurface
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    self surface = anObject surface ]
    ]

    hash [
	<category: 'basic'>
	^self class hash bitXor: self surface hash
    ]

    createCachedPattern [
	<category: 'C interface'>
	^ Cairo patternCreateForSurface: surface cairoSurface
    ]
].

CairoPattern subclass: GradientPattern [
    | colorStops |

    GradientPattern class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    colorStops [
	<category: 'accessing'>
	^colorStops
    ]

    initialize [
	<category: 'initialize'>
	colorStops := OrderedCollection new.
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    self colorStops = anObject colorStops ]
    ]

    hash [
	<category: 'basic'>
	^self class hash bitXor: self colorStops hash
    ]

    addStopAt: aNumber color: aColor [
	<category: 'accessing'>
	colorStops add: aNumber -> aColor.
    ]

    addStopAt: aNumber red: r green: g blue: b alpha: a [
	<category: 'accessing'>
	colorStops add: aNumber -> (Color r: r g: g blue: b a: a).
    ]

    initializeCachedPattern: p [
	<category: 'private'>
	| c |
	colorStops do: [ :stop |
	    c := stop value.
	    Cairo patternAddColorStopRgba: p
		  offset: stop key asCNumber
		  red: c red asCNumber
		  green: c green asCNumber
		  blue: c blue asCNumber
		  alpha: c alpha asCNumber ].
    ]
].

GradientPattern subclass: LinearGradient [
    | point0 point1 |

    LinearGradient class >> from: point0 to: point1 [
	<category: 'instance creation'>
	^ self new
	    from: point0 to: point1;
	    yourself
    ]

    from [
	<category: 'accessing'>
	^point0
    ]

    to [
	<category: 'accessing'>
	^point1
    ]

    from: aPoint0 to: aPoint1 [
	<category: 'private-accessing'>
	point0 := aPoint0.
	point1 := aPoint1.
    ]

    = anObject [
	<category: 'basic'>
	^super = anObject and: [
	    point0 = anObject from and: [
	    point1 = anObject to ]]
    ]

    hash [
	<category: 'basic'>
	^(super hash bitXor: point0 hash) bitXor: point1 hash
    ]

    createCachedPattern [
	<category: 'C interface'>
	| p c |
	p := Cairo patternCreateLinear: point0 x asCNumber
		   y0: point0 y asCNumber
		   x1: point1 x asCNumber
		   y1: point1 y asCNumber.
	self initializeCachedPattern: p.
	^ p
    ]
].

GradientPattern subclass: RadialGradient [
    | point0 r0 point1 r1 |

    RadialGradient class >> from: point0 radius: r0 to: point1 radius: r1 [
	<category: 'instance creation'>
	^ self new
	    from: point0 radius: r0 to: point1 radius: r1;
	    yourself
    ]

    from [
	<category: 'accessing'>
	^point0
    ]

    fromRadius [
	<category: 'accessing'>
	^r0
    ]

    to [
	<category: 'accessing'>
	^point1
    ]

    toRadius [
	<category: 'accessing'>
	^r1
    ]

    from: aPoint0 radius: aR0 to: aPoint1 radius: aR1 [
	<category: 'private-accessing'>
	point0 := aPoint0.
	r0 := aR0.
	point1 := aPoint1.
	r1 := aR1.
    ]

    = anObject [
	<category: 'basic'>
	^super = anObject and: [
	    point0 = anObject from and: [
	    r0 = anObject fromRadius and: [
	    point1 = anObject to and: [
	    r1 = anObject toRadius ]]]]
    ]

    hash [
	<category: 'basic'>
	^(((super hash bitXor: point0 hash) bitXor: point1 hash)
	     bitXor: r0 hash) bitXor: r1 hash
    ]

    createCachedPattern [
	<category: 'C interface'>
	| p c |
	p := Cairo patternCreateRadial: point0 x asCNumber
		   cy0: point0 y asCNumber
		   radius0: r0 asCNumber
		   cx1: point1 x asCNumber
		   cy1: point1 y asCNumber
		   radius1: r1 asCNumber.
	self initializeCachedPattern: p.
	^ p
    ]
].

CairoPattern subclass: Color [
    | red green blue alpha |

    Color >> new [
	<category: 'instance creation'>
	^self new r: 0 g: 0 b: 0 a: 1.
    ]

    Color class >> r: r g: g b: b [
	<category: 'instance creation'>
	^ self basicNew r: r g: g b: b a: 1.0.
    ]

    Color class >> r: r g: g b: b a: a [
	<category: 'instance creation'>
	^ self basicNew r: r g: g b: b a: a.
    ]

    Color class >> black [
	<category: 'instance creation'>
	^ self r: 0 g: 0 b: 0
    ]

    Color class >> white [
	<category: 'instance creation'>
	^ self r: 1 g: 1 b: 1
    ]

    Color class >> red [
	<category: 'instance creation'>
	^ self r: 1 g: 0 b: 0
    ]

    Color class >> green [
	<category: 'instance creation'>
	^ self r: 0 g: 1 b: 0
    ]

    Color class >> blue [
	<category: 'instance creation'>
	^ self r: 0 g: 0 b: 1
    ]

    Color class >> cyan [
	<category: 'instance creation'>
	^ self r: 0 g: 1 b: 1
    ]

    Color class >> magenta [
	<category: 'instance creation'>
	^ self r: 1 g: 0 b: 1
    ]

    Color class >> yellow [
	<category: 'instance creation'>
	^ self r: 1 g: 1 b: 0
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    red = anObject red and: [
	    green = anObject green and: [
	    blue = anObject blue and: [
	    alpha = anObject alpha]]]]
    ]

    hash [
	<category: 'basic'>
	^(red * 255) truncated +
	 ((green * 255) truncated * 256) +
	 ((blue * 255) truncated * 65536) +
	 ((alpha * 63) truncated * 16777216)
    ]
	 
    red [
	<category: 'accesing'>
	^red
    ]

    green [
	<category: 'accesing'>
	^green
    ]

    blue [
	<category: 'accesing'>
	^blue
    ]

    alpha [
	<category: 'accesing'>
	^alpha
    ]

    r: r g: g b: b a: a [
	<category: 'private-accesing'>
	red := r.
	green := g.
	blue := b.
	alpha := a.
    ]

    withRed: aNumber [
	<category: 'instance creation'>
	^ Color r: aNumber g: green b: blue a: alpha
    ]

    withGreen: aNumber [
	<category: 'instance creation'>
	^ Color r: red g: aNumber b: blue a: alpha
    ]

    withBlue: aNumber [
	<category: 'instance creation'>
	^ Color r: red g: green b: aNumber a: alpha
    ]

    withAlpha: aNumber [
	<category: 'instance creation'>
	^ Color r: red g: green b: blue a: aNumber
    ]

    mix: aColor ratio: aScale [
	<category: 'mixing'>
	^Color r: ((red * aScale) + (aColor red * (1 - aScale)))
		g: ((green * aScale) + (aColor green * (1 - aScale)))
		b: ((blue * aScale) + (aColor blue * (1 - aScale)))
		a: ((alpha * aScale) + (aColor alpha * (1 - aScale)))
    ]

    * aScale [
	<category: 'mixing'>
	aScale isNumber ifTrue: [
	    ^ Color r: ((red * aScale) min: 1)
		    g: ((green * aScale) min: 1)
		    b: ((blue * aScale) min: 1)
		    a: alpha ].
	^ Color r: red * aScale red
		g: green * aScale green
		b: blue * aScale blue
		a: alpha * aScale alpha
    ]

    createCachedPattern [
	<category: 'C interface'>

	^ Cairo patternCreateRgba: red asCNumber
		green: green asCNumber
		blue: blue asCNumber
		alpha: alpha asCNumber.
    ]

    printOn: st [
	<category: 'printing'>

	st << 'Color r: ' << red << ' g: ' << green << ' b: ' << blue << ' a: ' << alpha.
    ]

    storeOn: st [
	<category: 'printing'>

	st << $(.
	self printOn: st.
	st << $)
    ]

    setSourceOn: context [
	"Private - Used by Cairo to do double-dispatch on #source:"

	<category: 'cairo double dispatch'>
	Cairo
	    setSourceRgba: context
	    red: red asCNumber
	    green: green asCNumber
	    blue: blue asCNumber
	    alpha: alpha asCNumber.
    ]
].

Eval [
    CairoPattern initialize
]
PK
     �Zh@��R�      package.xmlUT	 ��XO��XOux �  �  <package>
  <name>Cairo</name>
  <namespace>Cairo</namespace>
  <library>libcairo</library>

  <filein>CairoFuncs.st</filein>
  <filein>CairoContext.st</filein>
  <filein>CairoTransform.st</filein>
  <filein>CairoSurface.st</filein>
  <filein>CairoPattern.st</filein>
</package>PK
     �Mh@�7�u2O  2O    CairoFuncs.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Cairo function declarations
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Originally by Mike Anderson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: Cairo [
    
    <category: 'Cairo-C interface'>
    <comment: 'This class provides the C functions used in
calling Cairo functions.  The user should actually use higher-level
classes such as CairoSurface, CairoPattern and (using #withContextDo:)
CairoContext.'>

    Cairo class >> arc: cr xc: xc yc: yc radius: radius angle1: angle1 angle2: angle2 [
        <cCall: 'cairo_arc' returning: #void args: #(#cObject #double #double #double #double #double )>
    ]

    Cairo class >> arcNegative: cr xc: xc yc: yc radius: radius angle1: angle1 angle2: angle2 [
        <cCall: 'cairo_arc_negative' returning: #void args: #(#cObject #double #double #double #double #double )>
    ]

    Cairo class >> clip: cr [
        <cCall: 'cairo_clip' returning: #void args: #(#cObject )>
    ]

    Cairo class >> clipPreserve: cr [
        <cCall: 'cairo_clip_preserve' returning: #void args: #(#cObject )>
    ]

    Cairo class >> closePath: cr [
        <cCall: 'cairo_close_path' returning: #void args: #(#cObject )>
    ]

    Cairo class >> create: target [
        <cCall: 'cairo_create' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> curveTo: cr x1: x1 y1: y1 x2: x2 y2: y2 x3: x3 y3: y3 [
        <cCall: 'cairo_curve_to' returning: #void args: #(#cObject #double #double #double #double #double #double )>
    ]

    Cairo class >> destroy: cr [
        <cCall: 'cairo_destroy' returning: #void args: #(#cObject )>
    ]

    Cairo class >> fill: cr [
        <cCall: 'cairo_fill' returning: #void args: #(#cObject )>
    ]

    Cairo class >> fillPreserve: cr [
        <cCall: 'cairo_fill_preserve' returning: #void args: #(#cObject )>
    ]

    Cairo class >> identityMatrix: cr [
        <cCall: 'cairo_identity_matrix' returning: #void args: #(#cObject )>
    ]

    Cairo class >> imageSurfaceCreate: format width: width height: height [
        <cCall: 'cairo_image_surface_create' returning: #cObject args: #(#int #int #int)>
    ]

    Cairo class >> imageSurfaceCreateForData: data format: format width: width height: height stride: stride [
        <cCall: 'cairo_image_surface_create_for_data' returning: #cObject args: #(#cObject #int #int #int #int )>
    ]

    Cairo class >> imageSurfaceCreateFromPng: filename [
        <cCall: 'cairo_image_surface_create_from_png' returning: #cObject args: #(#string )>
    ]

    Cairo class >> imageSurfaceGetData: surface [
        <cCall: 'cairo_image_surface_get_data' returning: #{CByte} args: #(#cObject)>
    ]

    Cairo class >> imageSurfaceGetHeight: filename [
        <cCall: 'cairo_image_surface_get_height' returning: #int args: #(#cObject )>
    ]

    Cairo class >> imageSurfaceGetWidth: filename [
        <cCall: 'cairo_image_surface_get_width' returning: #int args: #(#cObject )>
    ]

    Cairo class >> pdfSurfaceCreate: file width: width height: height [
        <cCall: 'cairo_pdf_surface_create' returning: #cObject args: #(#string #double #double)>
    ]

    Cairo class >> pdfSurfaceSetSize: file width: width height: height [
        <cCall: 'cairo_pdf_surface_set_size' returning: #int args: #(#cObject #double #double)>
    ]

    Cairo class >> svgSurfaceCreate: file width: width height: height [
        <cCall: 'cairo_svg_surface_create' returning: #cObject args: #(#string #double #double)>
    ]

    Cairo class >> showPage: file width: width height: height [
        <cCall: 'cairo_show_page' returning: #void args: #(#cObject)>
    ]

    Cairo class >> lineTo: cr x: x y: y [
        <cCall: 'cairo_line_to' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> mask: cr pattern: pattern [
        <cCall: 'cairo_mask' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> maskSurface: cr surface: surface surfaceX: surfaceX surfaceY: surfaceY [
        <cCall: 'cairo_mask_surface' returning: #void args: #(#cObject #cObject #double #double )>
    ]

    Cairo class >> matrixInit: matrix xx: xx yx: yx xy: xy yy: yy x0: x0 y0: y0 [
        <cCall: 'cairo_matrix_init' returning: #void args: #(#cObject #double #double #double #double #double #double )>
    ]

    Cairo class >> matrixInitIdentity: matrix [
        <cCall: 'cairo_matrix_init_identity' returning: #void args: #(#cObject )>
    ]

    Cairo class >> matrixInvert: matrix [
        <cCall: 'cairo_matrix_invert' returning: #int args: #(#cObject )>
    ]

    Cairo class >> matrixMultiply: result a: a b: b [
        <cCall: 'cairo_matrix_multiply' returning: #void args: #(#cObject #cObject #cObject )>
    ]

    Cairo class >> matrixRotate: matrix radians: radians [
        <cCall: 'cairo_matrix_rotate' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> matrixScale: matrix sx: sx sy: sy [
        <cCall: 'cairo_matrix_scale' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> matrixTransformDistance: matrix dx: dx dy: dy [
        <cCall: 'cairo_matrix_transform_distance' returning: #void args: #(#cObject #cObject #cObject )>
    ]

    Cairo class >> matrixTransformPoint: matrix x: x y: y [
        <cCall: 'cairo_matrix_transform_point' returning: #void args: #(#cObject #cObject #cObject )>
    ]

    Cairo class >> matrixTranslate: matrix tx: tx ty: ty [
        <cCall: 'cairo_matrix_translate' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> moveTo: cr x: x y: y [
        <cCall: 'cairo_move_to' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> newPath: cr [
        <cCall: 'cairo_new_path' returning: #void args: #(#cObject )>
    ]

    Cairo class >> newSubPath: cr [
        <cCall: 'cairo_new_sub_path' returning: #void args: #(#cObject )>
    ]

    Cairo class >> paint: cr [
        <cCall: 'cairo_paint' returning: #void args: #(#cObject )>
    ]

    Cairo class >> paintWithAlpha: cr alpha: alpha [
        <cCall: 'cairo_paint_with_alpha' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> patternAddColorStopRgba: pattern offset: offset red: red green: green blue: blue alpha: alpha [
        <cCall: 'cairo_pattern_add_color_stop_rgba' returning: #void args: #(#cObject #double #double #double #double #double )>
    ]

    Cairo class >> patternCreateForSurface: surface [
        <cCall: 'cairo_pattern_create_for_surface' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> patternCreateLinear: x0 y0: y0 x1: x1 y1: y1 [
        <cCall: 'cairo_pattern_create_linear' returning: #cObject args: #(#double #double #double #double )>
    ]

    Cairo class >> patternCreateRadial: cx0 cy0: cy0 radius0: radius0 cx1: cx1 cy1: cy1 radius1: radius1 [
        <cCall: 'cairo_pattern_create_radial' returning: #cObject args: #(#double #double #double #double #double #double )>
    ]

    Cairo class >> patternCreateRgb: red green: green blue: blue [
        <cCall: 'cairo_pattern_create_rgb' returning: #cObject args: #(#double #double #double )>
    ]

    Cairo class >> patternCreateRgba: red green: green blue: blue alpha: alpha [
        <cCall: 'cairo_pattern_create_rgba' returning: #cObject args: #(#double #double #double #double )>
    ]

    Cairo class >> patternReference: pattern [
        <cCall: 'cairo_pattern_reference' returning: #void args: #(#cObject )>
    ]

    Cairo class >> patternDestroy: pattern [
        <cCall: 'cairo_pattern_destroy' returning: #void args: #(#cObject )>
    ]

    Cairo class >> patternGetExtend: pattern [
        <cCall: 'cairo_pattern_get_extend' returning: #int args: #(#cObject )>
    ]

    Cairo class >> patternSetExtend: pattern extend: extend [
        <cCall: 'cairo_pattern_set_extend' returning: #void args: #(#cObject #int)>
    ]

    Cairo class >> popGroup: cr [
        <cCall: 'cairo_pop_group' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> pushGroup: cr [
        <cCall: 'cairo_push_group' returning: #void args: #(#cObject )>
    ]

    Cairo class >> rectangle: cr x: x y: y width: width height: height [
        <cCall: 'cairo_rectangle' returning: #void args: #(#cObject #double #double #double #double )>
    ]

    Cairo class >> reference: cr [
        <cCall: 'cairo_reference' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> relCurveTo: cr dx1: dx1 dy1: dy1 dx2: dx2 dy2: dy2 dx3: dx3 dy3: dy3 [
        <cCall: 'cairo_rel_curve_to' returning: #void args: #(#cObject #double #double #double #double #double #double )>
    ]

    Cairo class >> relLineTo: cr dx: dx dy: dy [
        <cCall: 'cairo_rel_line_to' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> relMoveTo: cr dx: dx dy: dy [
        <cCall: 'cairo_rel_move_to' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> resetClip: cr [
        <cCall: 'cairo_reset_clip' returning: #void args: #(#cObject )>
    ]

    Cairo class >> restore: cr [
        <cCall: 'cairo_restore' returning: #void args: #(#cObject )>
    ]

    Cairo class >> rotate: cr angle: angle [
        <cCall: 'cairo_rotate' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> save: cr [
        <cCall: 'cairo_save' returning: #void args: #(#cObject )>
    ]

    Cairo class >> scale: cr sx: sx sy: sy [
        <cCall: 'cairo_scale' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> scaledFontCreate: fontFace fontMatrix: fontMatrix ctm: ctm options: options [
        <cCall: 'cairo_scaled_font_create' returning: #cObject args: #(#cObject #cObject #cObject #cObject )>
    ]

    Cairo class >> scaledFontDestroy: scaledFont [
        <cCall: 'cairo_scaled_font_destroy' returning: #void args: #(#cObject )>
    ]

    Cairo class >> scaledFontExtents: scaledFont extents: extents [
        <cCall: 'cairo_scaled_font_extents' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> scaledFontGetCtm: scaledFont ctm: ctm [
        <cCall: 'cairo_scaled_font_get_ctm' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> scaledFontGetFontFace: scaledFont [
        <cCall: 'cairo_scaled_font_get_font_face' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> scaledFontGetFontMatrix: scaledFont fontMatrix: fontMatrix [
        <cCall: 'cairo_scaled_font_get_font_matrix' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> scaledFontGetFontOptions: scaledFont options: options [
        <cCall: 'cairo_scaled_font_get_font_options' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> scaledFontGetType: scaledFont [
        <cCall: 'cairo_scaled_font_get_type' returning: #int args: #(#cObject )>
    ]

    Cairo class >> scaledFontGlyphExtents: scaledFont glyphs: glyphs numGlyphs: numGlyphs extents: extents [
        <cCall: 'cairo_scaled_font_glyph_extents' returning: #void args: #(#cObject #cObject #int #cObject )>
    ]

    Cairo class >> scaledFontReference: scaledFont [
        <cCall: 'cairo_scaled_font_reference' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> scaledFontStatus: scaledFont [
        <cCall: 'cairo_scaled_font_status' returning: #int args: #(#cObject )>
    ]

    Cairo class >> scaledFontTextExtents: scaledFont utf8: utf8 extents: extents [
        <cCall: 'cairo_scaled_font_text_extents' returning: #void args: #(#cObject #string #cObject )>
    ]

    Cairo class >> selectFontFace: cr family: family slant: slant weight: weight [
        <cCall: 'cairo_select_font_face' returning: #void args: #(#cObject #string #int #int )>
    ]

    Cairo class >> getSource: cr [
        <cCall: 'cairo_get_source' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> getMiterLimit: cr [
        <cCall: 'cairo_get_miter_limit' returning: #double args: #(#cObject )>
    ]

    Cairo class >> getFillRule: cr [
        <cCall: 'cairo_get_fill_rule' returning: #int args: #(#cObject )>
    ]

    Cairo class >> getLineCap: cr [
        <cCall: 'cairo_get_line_cap' returning: #int args: #(#cObject )>
    ]

    Cairo class >> getLineJoin: cr [
        <cCall: 'cairo_get_line_join' returning: #int args: #(#cObject )>
    ]

    Cairo class >> getLineWidth: cr [
        <cCall: 'cairo_get_line_width' returning: #double args: #(#cObject )>
    ]

    Cairo class >> getOperator: cr [
        <cCall: 'cairo_get_operator' returning: #int args: #(#cObject )>
    ]

    Cairo class >> setSource: cr source: source [
        <cCall: 'cairo_set_source' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> setSourceRgb: cr red: red green: green blue: blue [
        <cCall: 'cairo_set_source_rgb' returning: #void args: #(#cObject #double #double #double )>
    ]

    Cairo class >> setSourceRgba: cr red: red green: green blue: blue alpha: alpha [
        <cCall: 'cairo_set_source_rgba' returning: #void args: #(#cObject #double #double #double #double )>
    ]

    Cairo class >> setFontSize: cr size: size [
        <cCall: 'cairo_set_font_size' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> setMiterLimit: cr miterLimit: size [
        <cCall: 'cairo_set_miter_limit' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> setFillRule: cr fillRule: fillRule [
        <cCall: 'cairo_set_fill_rule' returning: #void args: #(#cObject #int )>
    ]

    Cairo class >> setLineCap: cr lineCap: lineCap [
        <cCall: 'cairo_set_line_cap' returning: #void args: #(#cObject #int )>
    ]

    Cairo class >> setLineJoin: cr lineJoin: lineJoin [
        <cCall: 'cairo_set_line_join' returning: #void args: #(#cObject #int )>
    ]

    Cairo class >> setLineWidth: cr width: width [
        <cCall: 'cairo_set_line_width' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> setOperator: cr operator: lineJoin [
        <cCall: 'cairo_set_operator' returning: #void args: #(#cObject #int )>
    ]

    Cairo class >> showText: cr utf8: utf8 [
        <cCall: 'cairo_show_text' returning: #void args: #(#cObject #string )>
    ]

    Cairo class >> stroke: cr [
        <cCall: 'cairo_stroke' returning: #void args: #(#cObject )>
    ]

    Cairo class >> strokePreserve: cr [
        <cCall: 'cairo_stroke_preserve' returning: #void args: #(#cObject )>
    ]

    Cairo class >> surfaceWriteToPng: surface filename: filename [
        <cCall: 'cairo_surface_write_to_png' returning: #void args: #(#cObject #string )>
    ]

    Cairo class >> surfaceDestroy: surface [
        <cCall: 'cairo_surface_destroy' returning: #void args: #(#cObject )>
    ]

    Cairo class >> surfaceFinish: surface [
        <cCall: 'cairo_surface_finish' returning: #void args: #(#cObject )>
    ]

    Cairo class >> surfaceFlush: surface [
        <cCall: 'cairo_surface_flush' returning: #void args: #(#cObject )>
    ]

    Cairo class >> textExtents: cr utf8: utf8 extents: extents [
        <cCall: 'cairo_text_extents' returning: #void args: #(#cObject #string #cObject )>
    ]

    Cairo class >> textPath: cr utf8: utf8 [
        <cCall: 'cairo_text_path' returning: #void args: #(#cObject #string )>
    ]

    Cairo class >> transform: cr matrix: matrix [
        <cCall: 'cairo_transform' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> translate: cr tx: tx ty: ty [
        <cCall: 'cairo_translate' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> xlibSurfaceSetDrawable: surface drawable: drawable width: width height: height [
        <cCall: 'cairo_xlib_surface_set_drawable' returning: #void args: #(#cObject #uLong #int #int )>
    ]

    Cairo class >> xlibSurfaceSetSize: surface width: width height: height [
        <cCall: 'cairo_xlib_surface_set_size' returning: #void args: #(#cObject #int #int )>
    ]

    Cairo class >> defaultSelector: aFuncName args: aArgs [
        <category: 'loading'>
        | sel |
        sel := super defaultSelector: aFuncName args: aArgs.
        (sel startsWith: 'cairo') 
            ifTrue: [sel := (sel at: 6) asLowercase asString , (sel copyFrom: 7)].
        ^sel
    ]

    Cairo class >> fillRuleEvenOdd [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> fillRuleWinding [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> lineJoinBevel [
        <category: 'loading'>
        ^2
    ]

    Cairo class >> lineJoinRound [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> lineJoinMiter [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> lineCapSquare [
        <category: 'loading'>
        ^2
    ]

    Cairo class >> lineCapRound [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> lineCapButt [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> fontSlantOblique [
        <category: 'loading'>
        ^2
    ]

    Cairo class >> fontSlantItalic [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> fontSlantNormal [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> fontWeightBold [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> fontWeightNormal [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> extendPad [
        <category: 'loading'>
        ^3
    ]

    Cairo class >> extendReflect [
        <category: 'loading'>
        ^2
    ]

    Cairo class >> extendRepeat [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> extendNone [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> formatArgb32 [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> operatorClear [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> operatorSource [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> operatorOver [
        <category: 'loading'>
        ^2
    ]

    Cairo class >> operatorIn [
        <category: 'loading'>
        ^3
    ]

    Cairo class >> operatorOut [
        <category: 'loading'>
        ^4
    ]

    Cairo class >> operatorAtop [
        <category: 'loading'>
        ^5
    ]

    Cairo class >> operatorDest [
        <category: 'loading'>
        ^6
    ]

    Cairo class >> operatorDestOver [
        <category: 'loading'>
        ^7
    ]

    Cairo class >> operatorDestIn [
        <category: 'loading'>
        ^8
    ]

    Cairo class >> operatorDestOut [
        <category: 'loading'>
        ^9
    ]

    Cairo class >> operatorDestAtop [
        <category: 'loading'>
        ^10
    ]

    Cairo class >> operatorXor [
        <category: 'loading'>
        ^11
    ]

    Cairo class >> operatorAdd [
        <category: 'loading'>
        ^12
    ]

    Cairo class >> operatorSaturate [
        <category: 'loading'>
        ^13
    ]

]

CStruct subclass: CairoTextExtents [
    <declaration: #(
        (#xBearing #double)
        (#yBearing #double)
        (#width #double)
        (#height #double)
        (#xAdvance #double)
        (#yAdvance #double)) >

    <category: 'Cairo-C interface'>
]
PK
     �Mh@��{�&"  &"    CairoSurface.stUT	 cqXO��XOux �  �  "======================================================================
|
|   CairoSurface wrapper class for libcairo
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones and Michael Bridgen.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


CairoContextProvider subclass: CairoSurface [
    | surface |

    cairoSurface [
	"Return the CObject for the Cairo surface."

	<category: 'C interface'>
	surface isNil ifTrue: [ self rebuildSurface ].
	^surface
    ]

    update: aspect [
	<category: 'private-persistence'>
	aspect == #returnFromSnapshot ifFalse: [
	    (SurfacePattern on: self) release ].
	self rebuildSurface.
	aspect == #returnFromSnapshot ifTrue: [
	    self changed: #returnFromSnapshot ].
    ]

    buildSurface [
	"Abstract method to actually create a Cairo surface.
	 Returns the CObject."

	<category: 'C interface'>
	self subclassResponsibility.
    ]

    extent [
	"Return the size of the surface"

	self subclassResponsibility
    ]

    rebuildSurface [
	<category: 'private-persistence'>
	surface := nil.
	surface := self buildSurface.
	self addToBeFinalized.
    ]

    finalize [
	<category: 'private-finalization'>
	self free
    ]

    free [
	<category: 'private-finalization'>
	surface ifNil: [ ^self ].
	Cairo surfaceDestroy: surface.
	surface := nil.
    ]

    release [
	<category: 'private-finalization'>
	self finalize.
	self removeToBeFinalized.
	super release
    ]

    withContextDo: aBlock [
	"Execute aBlock passing a valid Cairo context for the
	 surface.  The context is invalidated after aBlock returns."

	<category: 'accessing'>
	| context |
	[ aBlock value: (context := CairoContext on: self) ] ensure: [ 
	    context isNil ifFalse: [ context release ] ]
    ]
]

CairoSurface subclass: CairoOffscreenSurface [
    | extent |

    CairoOffscreenSurface class >> extent: aPoint [
	"Create a new surface with the given size.  Right now it is
	 only possible to create 32-bit color surfaces.

	 The surface is blanked when the Smalltalk image is restarted."
	<category: 'instance creation'>
	^self new extent: aPoint
    ]

    extent [
	"Return the size of the surface"

	<category: 'accessing'>
	^extent
    ]

    extent: aPoint [ extent := aPoint ]
]

CairoOffscreenSurface subclass: CairoImageSurface [
    buildSurface [
	<category: 'C interface'>
	^Cairo imageSurfaceCreate: Cairo formatArgb32 width: extent x height: extent y
    ]

    data [
	<category: 'C interface'>
	^Cairo imageSurfaceGetData: self cairoSurface
    ]
]

CairoOffscreenSurface subclass: CairoFileSurface [
    | filename |

    CairoFileSurface class >> on: aFile with: aSurface [
	"Create a new surface that will save to aFile and whose
	 size and initial content is the same as aSurface's.
         For a subclass of CairoLoadableFileSurface, the
	 content is reset to the content of aFile when
	 the Smalltalk image is restarted.  Otherwise, it
         will be reset to transparent on image restart."

	<category: 'instance creation'>
	^(self extent: aSurface extent)
	    buildSurface;
	    paint: aSurface;
	    filename: aFile asString;
	    yourself
    ]

    CairoFileSurface class >> on: aFile extent: aPoint [
	"Create a new surface that will save to aFile, whose
	 size is aPoint.  The initial content is transparent
         except for subclasses of CairoLoadableFileSurface,
         where it is loaded from aFile.  For loadable surfaces
	 the content is also reset to the content of aFile when
	 the Smalltalk image is restarted, otherwise it will be
         transparent too."

	<category: 'instance creation'>
	^(self extent: aPoint)
	    filename: aFile asString;
	    buildSurface;
	    yourself
    ]

    paint: aSurface [
	"Private - Paint the contents of aSurface on this surface."

	<category: 'private'>
	super withContextDo: [ :context || pattern |
	    context source: (SurfacePattern on: aSurface); paint ]
    ]

    filename [
	"Answer the file from which the bits of the surface are loaded."

	<category: 'accessing'>
	^filename
    ]

    filename: aString [
	"Answer the file to which the bits of the surface are saved."

	<category: 'accessing'>
	filename := aString.
    ]

    saveTo: aContext [
	"Save the contents of the surface to the file specified by
	 #filename."

	<category: 'private-file'>
	self subclassResponbsibility
    ]

    withContextDo: aBlock [
	"Execute aBlock passing a valid Cairo context for the
	 surface.  After aBlock returns, the context is invalidated
	 and the content of the surface is saved to the file."

	<category: 'accessing'>
	super withContextDo: [ :ctx |
	    [ aBlock value: ctx ] ensure: [ self saveTo: ctx ] ]
    ]
]

CairoFileSurface subclass: CairoMultiPageSurface [
    saveTo: aContext [
	"Save the contents of the surface to the PNG file specified by
	 #filename."

	<category: 'private-file'>
	Cairo showPage: aContext
    ]
]

CairoFileSurface subclass: CairoPdfSurface [
    buildSurface [
	<category: 'C interface'>
	^Cairo pdfSurfaceCreate: self filename width: extent x height: extent y
    ]

    withContextDo: aBlock [
	"Execute aBlock passing a valid Cairo context for the
	 surface.  The extent can be modified just before calling
	 this.  After aBlock returns, the context is invalidated
	 and the content of the surface is saved to the file."

	<category: 'accessing'>
	^Cairo pdfSurfaceSetSize: self cairoSurface width: extent x height: extent y
    ]
].

CairoFileSurface subclass: CairoSvgSurface [
    buildSurface [
	<category: 'C interface'>
	^Cairo svgSurfaceCreate: self filename width: extent x height: extent y
    ]
].

CairoFileSurface subclass: CairoLoadableFileSurface [
    CairoFileSurface class >> on: aFile [
	"Create a new surface that will save to aFile, whose
	 size is aPoint and whose initial content is obtained
	 by loading aFile.  aFile is reloaded on every Smalltalk
	 image load."

	^self new filename: aFile asString
    ]

    buildBlankSurface [
	<category: 'C interface'>
	self subclassResponsibility
    ]

    buildSurface [
	"Try to read the surface from the file if it exists.  Otherwise,
	 create a blank surface whose size must have been given with
	 the superclass constructor method, #extent:."

	<category: 'file'>
	^(filename notNil and: [ filename asFile exists ])
	    ifTrue: [ self buildSurfaceFromFile ]
	    ifFalse: [ self buildBlankSurface ]
    ]

    buildSurfaceFromFile [
	"Load the contents of the surface to the file specified by
	 #filename."

	<category: 'file'>
	self subclassResponbsibility
    ]

    extent [
	"Return the size of the surface.  Requires the file to exist
	 if the size was not supplied at surface creation time."

	extent isNil ifTrue: [
	    self extent: ((Cairo imageSurfaceGetWidth: self cairoSurface) @
			  (Cairo imageSurfaceGetHeight: self cairoSurface)) ].
	^super extent
    ]
]

CairoLoadableFileSurface subclass: CairoPngSurface [
    buildBlankSurface [
	<category: 'C interface'>
	^Cairo imageSurfaceCreate: Cairo formatArgb32 width: extent x height: extent y
    ]

    buildSurfaceFromFile [
	"Try to read the surface from the file if it exists.  Otherwise,
	 create a blank surface whose size must have been given with
	 the superclass constructor method, #extent:."

	<category: 'file'>
	^Cairo imageSurfaceCreateFromPng: filename
    ]

    data [
	<category: 'C interface'>
	^Cairo imageSurfaceGetData: self cairoSurface
    ]

    save [
	"Save the contents of the surface to the PNG file specified by
	 #filename."

	<category: 'file'>
	Cairo surfaceWriteToPng: self cairoSurface filename: filename
    ]

    saveTo: aContext [
	"Save the contents of the surface to the PNG file specified by
	 #filename."

	<category: 'private-file'>
	self save
    ]
].

PK
     �Mh@�"`W`o  `o    CairoContext.stUT	 cqXO��XOux �  �  "======================================================================
|
|   CairoContext wrapper class for libcairo
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008, 2009 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones and Michael Bridgen.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: CairoContextProvider [
    <comment: 'I provide the means to obtain a CairoContext.'>

    withContextDo: aBlock [
	<category: 'drawing'>
	self subclassResponsibility
    ]
]

CairoContextProvider subclass: CairoContext [
    | surface context depth |

    <comment: 'I provide the means to draw on a CairoSurface.'>

    CairoContext class >> context: aCObject [
	"Creates a new context pointing to the given C cairo_t pointer."

	<category: 'instance creation'>
	^ self new initializeContext: aCObject
    ]

    CairoContext class >> on: aCairoSurface [
	"Creates a new context with all graphics state parameters set
	 to default values and with target as a target surface."

	<category: 'instance creation'>
	^ self new initialize: aCairoSurface
    ]

    initializeContext: aCObject [
	<category: 'private'>
	context := aCObject.
	depth := 0.
	self addToBeFinalized
    ]

    initialize: aCairoSurface [
	<category: 'private'>
	surface := aCairoSurface.
	depth := 0.
	surface addDependent: self.
	self rebuildContext.
    ]

    rebuildContext [
	<category: 'private-persistence'>
	surface isNil ifFalse: [
	    context := Cairo create: surface cairoSurface.
	    self addToBeFinalized].
    ]

    update: aspect [
	<category: 'private-persistence'>
	aspect == #returnFromSnapshot ifTrue: [
	    ^self rebuildContext].
    ]

    finalize [
	<category: 'private-persistence'>
	context ifNil: [ ^self ].
	Cairo destroy: context.
	context := nil.
	surface removeDependent: self.
	surface := nil.
    ]

    release [
	<category: 'private-persistence'>
	self finalize.
	self removeToBeFinalized.
	super release.
    ]

    restore [
	<category: 'drawing'>
	"Restore the context to a state saved by a preceding call to #save,
	 and removes that state from the stack of saved states."
	Cairo restore: context.
    ]

    save [
	"Make a copy of the current state and saves it on an internal
	 stack of saved states."

	<category: 'drawing'>
	Cairo save: context.
    ]

    withContextDo: aBlock [
	"Execute aBlock without modifying the current state.  Provided
	 for polymorphism with CairoSurface."

	<category: 'drawing-handy API'>
	Cairo save: context.
	^[aBlock value: self] ensure: [ Cairo restore: context ].
    ]
	
    saveWhile: aBlock [
	"Execute aBlock without modifying the current state."
	<category: 'drawing-handy API'>
	Cairo save: context.
	^ aBlock ensure: [ Cairo restore: context ].
    ]

    withSource: aPatternOrBlock do: paintBlock [
	<category: 'drawing-handy API'>
	"Execute paintBlock while the current source is set to aPatternOrBlock.
	 If aPatternOrBlock is a BlockClosure, the result of performing the
	 drawing commands in aPatternOrBlock is used as a pattern."
	aPatternOrBlock on: context withSourceDo: paintBlock
    ]

    source: aPatternOrBlock [
	"Set the source pattern to a CairoPattern or, if aPatternOrBlock is a
	 BlockClosure, to the result of performing the drawing commands in
	 aPatternOrBlock."

	<category: 'accessing'>
	aPatternOrBlock setSourceOn: context
    ]

    sourceRed: r green: g blue: b [
	"Set the source pattern to an opaque color."
	<category: 'accessing'>
	Cairo setSourceRgb: context red: r asCNumber green: g asCNumber blue: b asCNumber.
    ]

    sourceRed: r green: g blue: b alpha: a [
	"Set the source pattern to an opaque or translucent color."
	<category: 'accessing'>
	Cairo setSourceRgba: context red: r asCNumber green: g asCNumber blue: b asCNumber alpha: a asCNumber.
    ]

    closePath [
	"Add a line segment to the path from the current point to the
	 beginning of the current sub-path, and closes this sub-path.
	 Leaves the current point will be at the joined endpoint of
	 the sub-path.  When a closed sub-path is stroked, there are no
	 caps on the ends of the sub-path. Instead, there is a line join
	 connecting the final and initial segments of the sub-path. "
	<category: 'paths'>
	Cairo closePath: context.
    ]

    withClosedPath: aBlock do: opsBlock [
	"Using a path consisting of the path commands in aBlock, plus
	 a final #closePath, do the operations in opsBlock.  All of
	 them implicitly preserve the path, which is cleared after
	 opsBlock is evaluated."
	<category: 'paths-handy API'>
	self withPath: [ aBlock value. self closePath ] do: opsBlock
    ]

    addClosedSubPath: aBlock [
	<category: 'paths-handy API'>
	"Adds a new closed sub-path to the current path, described by
	 the path commands in aBlock.  The sub-path starts with no
	 current point set, which is useful when it starts with an arc."
	self newSubPath.
	aBlock value.
	self closePath
    ]

    addSubPath: aBlock [
	<category: 'paths-handy API'>
	"Adds a new sub-path to the current path, described by the path
	 commands in aBlock.  The sub-path starts with no current point
	 set, which is useful when it starts with an arc."
	self newSubPath.
	aBlock value
    ]

    withPath: aBlock do: opsBlock [
	"Using a path consisting of the path commands in aBlock, do
	 the operations in opsBlock.  All of them implicitly preserve
	 the path, which is cleared after opsBlock is evaluated."
	<category: 'paths-handy API'>

	"Cannot yet save a path and go back to it later."
	depth >= 1 ifTrue: [ self notYetImplemented ].
	depth := depth + 1.
	[aBlock value. opsBlock value] ensure: [
	    depth := depth - 1. self newPath]
    ]

    newSubPath [
	"Begin a new sub-path. Note that the existing path is not affected.
	 After this call there will be no current point."
	<category: 'paths'>
	Cairo newSubPath: context.
    ]

    newPath [
	"Clears the current path. After this call there will be no path and
	 no current point."

	<category: 'paths'>
	Cairo newPath: context.
    ]

    moveTo: aPoint [
	"Begin a new sub-path. After this call the current point will
	 be aPoint."

	<category: 'paths'>
	Cairo moveTo: context x: aPoint x asCNumber y: aPoint y asCNumber.
    ]

    relMoveTo: aPoint [
	"Begin a new sub-path. After this call the current point will be
	 offset by aPoint."

	<category: 'paths'>
	Cairo relMoveTo: context dx: aPoint x asCNumber dy: aPoint y asCNumber.
    ]

    lineTo: aPoint [
	"Adds a line to the path from the current point to position aPoint
	in user-space coordinates."

	<category: 'paths'>
	Cairo lineTo: context x: aPoint x asCNumber y: aPoint y asCNumber.
    ]

    relLineTo: aPoint [
	"Adds a line to the path from the current point to the point offset
	by aPoint in user-space coordinates."

	<category: 'paths'>
	Cairo relLineTo: context dx: aPoint x asCNumber dy: aPoint y asCNumber.
    ]

    curveTo: aPoint3 via: aPoint1 via: aPoint2 [
	"Adds a cubic Bezier spline to the path from the current point to
	 aPoint3 in user-space coordinates, using aPoint1 and aPoint2 as the
	 control points. After this call the current point will be aPoint3. 

	 If there is no current point before the call, the first control
	 point will be used as the starting point."
	<category: 'paths'>
	Cairo curveTo: context
	      x1: aPoint1 x asCNumber y1: aPoint1 y asCNumber
	      x2: aPoint2 x asCNumber y2: aPoint2 y asCNumber
	      x3: aPoint3 x asCNumber y3: aPoint3 y asCNumber.
    ]

    curveVia: aPoint1 via: aPoint2 to: aPoint3 [
	"Adds a cubic Bezier spline to the path from the current point to
	 aPoint3 in user-space coordinates, using aPoint1 and aPoint2 as the
	 control points. After this call the current point will be aPoint3. 

	 If there is no current point before the call, the first control
	 point will be used as the starting point."
	<category: 'paths'>
	Cairo curveTo: context
	      x1: aPoint1 x asCNumber y1: aPoint1 y asCNumber
	      x2: aPoint2 x asCNumber y2: aPoint2 y asCNumber
	      x3: aPoint3 x asCNumber y3: aPoint3 y asCNumber.
    ]

    arc: aPoint radius: r from: angle1 to: angle2 [
	"Adds a circular arc of the given radius to the current path. The
	arc is centered at aPoint, begins at angle1 and proceeds in
	the direction of increasing angles to end at angle2. If angle2
	is less than angle1 it will be progressively increased by 2*PI
	until it is greater than angle1.

	If there is a current point, an initial line segment will be
	added to the path to connect the current point to the beginning
	of the arc."
	<category: 'paths'>
	Cairo arc: context
	      xc: aPoint x asCNumber yc: aPoint y asCNumber
	      radius: r asCNumber
	      angle1: angle1 asCNumber angle2: angle2 asCNumber.
    ]

    arcNegative: aPoint radius: r from: angle1 to: angle2 [
	"Adds a circular arc of the given radius to the current path. The
	arc is centered at aPoint, begins at angle1 and proceeds in
	the direction of decreasing angles to end at angle2. If angle2
	is greater than angle1 it will be progressively decreased by 2*PI
	until it is less than angle1.

	If there is a current point, an initial line segment will be
	added to the path to connect the current point to the beginning
	of the arc."
	<category: 'paths'>
	Cairo arcNegative: context
	      xc: aPoint x asCNumber yc: aPoint y asCNumber
	      radius: r asCNumber
	      angle1: angle1 asCNumber angle2: angle2 asCNumber.
    ]

    rectangle: aRect [
	"Adds a closed sub-path rectangle with the given bounding box to the
	 current path."

	<category: 'paths'>
	Cairo rectangle: context
	      x: aRect left asCNumber y: aRect top asCNumber
	      width: aRect width asCNumber height: aRect height asCNumber.
    ]

    groupWhile: aBlock [
	"Set the source pattern to the result of drawing with the commands
	 in aBlock."

	<category: 'drawing-handy API'>
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    aBlock ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    clipPreserve [
	"Establish a new clip region by intersecting the current clip
	 region with the current path as it would be filled by #fill
	 and according to the current fill rule.  Preserves the path."
	<category: 'drawing'>
	Cairo clipPreserve: context
    ]

    clip [
	"Establish a new clip region by intersecting the current clip
	 region with the current path as it would be filled by #fill
	 and according to the current fill rule.  The current clip region
	 affects all drawing operations by effectively masking out any
	 changes to the surface that are outside the current clip region."
	<category: 'drawing'>
	depth > 0
	    ifTrue: [Cairo clipPreserve: context]
	    ifFalse: [Cairo clip: context]
    ]

    clip: aBlock [
	"Establish a new clip region by intersecting the current clip
	 region with the path obtained by drawing the path commands
	 in aBlock."
	<category: 'drawing-handy API'>
	self withPath: aBlock do: [ self clip ]
    ]

    resetClip [
	"Reset the current clip region to its original, unrestricted state."
	<category: 'drawing'>
        Cairo resetClip: context.
    ]

    mask: aPatternOrBlock [
	"Paints the current source using the alpha channel of aPatternOrBlock
	 as a mask.  Opaque areas of the pattern are painted with the source,
	 transparent areas are not painted."
	<category: 'drawing'>
        aPatternOrBlock maskOn: context
    ]

    paint [
	"Paint the current source everywhere within the current clip region."

	<category: 'drawing'>
        Cairo paint: context.
    ]

    paintWith: aPatternOrBlock [
	"Paint the source given by aPatternOrBlock everywhere within the current
	 clip region."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self paint ]
    ]

    paintWithAlpha: a [
	"Paint the current source everywhere within the current clip region,
	 using a mask of constant alpha value."
	<category: 'drawing'>
        Cairo paintWithAlpha: context alpha: a asCNumber.
    ]

    paint: aPatternOrBlock withAlpha: a [
	"Paint the source given by aPatternOrBlock everywhere within the current
	 clip region, using a mask of constant alpha value."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self paintWithAlpha: a ]
    ]

    fillPreserve [
	"Fill the current path according to the current fill rule.  Each
	 sub-path is implicitly closed before being filled.  Leaves the
	 current path untouched."
	<category: 'drawing'>
	Cairo fillPreserve: context
    ]

    fill [
	"Fill the current path according to the current fill rule.  Each
	 sub-path is implicitly closed before being filled."
	<category: 'drawing'>
	depth > 0
	    ifTrue: [Cairo fillPreserve: context]
	    ifFalse: [Cairo fill: context]
    ]

    fill: aBlock [
	"Fill the path obtained by drawing the path commands in aBlock,
	 according to the current fill rule.  Each sub-path is implicitly
	 closed before being filled."
	<category: 'drawing-handy API'>
	self withPath: aBlock do: [ self fill ]
    ]

    fill: pathBlock with: aPatternOrBlock [
	"Fill the path obtained by drawing the path commands in aBlock,
	 according to the current fill rule, using as the source the pattern
	 in aPatternOrBlock or the result of the drawing commands in it
	 (if it is a block).  Each sub-path is implicitly closed before
	 being filled."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self fill: pathBlock ]
    ]

    fillWith: aPatternOrBlock [
	"Fill the current path according to the current fill rule, using
	 as the source the pattern in aPatternOrBlock or the result of
	 the drawing commands in it (if it is a block).  Each sub-path
	 is implicitly closed before being filled."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self fill ]
    ]

    strokePreserve [
	"Stroke the current path according to the current line width,
	 line join, line cap, and dash settings, without clearing the
	 current path afterwards."
	<category: 'drawing'>
	Cairo strokePreserve: context
    ]

    stroke [
	"Stroke the current path according to the current line width,
	 line join, line cap, and dash settings."
	<category: 'drawing'>
	depth > 0
	    ifTrue: [Cairo strokePreserve: context]
	    ifFalse: [Cairo stroke: context]
    ]

    stroke: aBlock [
	"Stroke the path defined by the path commands in aBlock,
	 according to the current line width, line join, line cap,
	 and dash settings."
	<category: 'drawing-handy API'>
	self withPath: aBlock do: [ self stroke ]
    ]

    stroke: pathBlock with: aPatternOrBlock [
	"Stroke the path defined by the path commands in aBlock,
	 according to the current line width, line join, line cap,
	 and dash settings.  aPatternOrBlock (or, if it is a block,
	 the result of the drawing commands in it) is used as the
	 source."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self stroke: pathBlock ]
    ]

    strokeWith: aPatternOrBlock [
	"Stroke the current path according to the current line width,
	 line join, line cap, and dash settings.  aPatternOrBlock (or,
	 if it is a block, the result of the drawing commands in it)
	 is used as the source."
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self stroke ]
    ]

    identityMatrix [
	"Reset the current transformation matrix (CTM) by setting it
	 equal to the identity matrix. That is, the user-space and
	 device-space axes will be aligned and one user-space unit will
	 transform to one device-space unit."
	<category: 'transform'>
        Cairo identityMatrix: context.
    ]

    translateBy: aPoint [
	"Modifies the current transformation matrix (CTM) by translating
	 the user-space origin by (tx, ty)."
	<category: 'transform'>
	Cairo translate: context tx: aPoint x asCNumber ty: aPoint y asCNumber.
    ]

    scaleBy: aPoint [
	"Modifies the current transformation matrix (CTM) by scaling
	 the X and Y user-space axes by aPoint."
	<category: 'transform'>
	| p |
	p := aPoint asPoint.
        Cairo scale: context sx: p x asCNumber sy: p y asCNumber.
    ]

    rotateBy: rads [
	"Modifies the current transformation matrix (CTM) by rotating
	 the X and Y user-space axes by rads radians."
	<category: 'transform'>
        Cairo rotate: context angle: rads asCNumber.
    ]

    nullTransform [
	"Does nothing to the current transformation matrix (CTM)."
	<category: 'transform-handy API'>
    ]

    transformByMatrix: aTransform [
	"Private - Used for double dispatch."
	<category: 'transform'>
        Cairo transform: context matrix: aTransform matrix.
    ]

    transformBy: aTransform [
	"Modifies the current transformation matrix (CTM) by applying
	 the given Transform object."
	<category: 'transform'>
        aTransform accept: self
    ]

    CairoContext class >> lookupOperatorValue: anInteger [
	<category: 'private-accessing'>
	anInteger == Cairo operatorClear ifTrue: [ ^#clear ].
	anInteger == Cairo operatorSource ifTrue: [ ^#source ].
	anInteger == Cairo operatorOver ifTrue: [ ^#over ].
	anInteger == Cairo operatorIn ifTrue: [ ^#in ].
	anInteger == Cairo operatorOut ifTrue: [ ^#out ].
	anInteger == Cairo operatorAtop ifTrue: [ ^#atop ].
	anInteger == Cairo operatorDest ifTrue: [ ^#dest ].
	anInteger == Cairo operatorDestOver ifTrue: [ ^#destOver ].
	anInteger == Cairo operatorDestIn ifTrue: [ ^#destIn ].
	anInteger == Cairo operatorDestOut ifTrue: [ ^#destOut ].
	anInteger == Cairo operatorDestAtop ifTrue: [ ^#destAtop ].
	anInteger == Cairo operatorXor ifTrue: [ ^#xor ].
	anInteger == Cairo operatorAdd ifTrue: [ ^#add ].
	anInteger == Cairo operatorSaturate ifTrue: [ ^#saturate ].
	self error: 'Unsupported operator value ', anInteger
    ]

    CairoContext class >> lookupLineCapValue: anInteger [
	<category: 'private-accessing'>
	anInteger == Cairo lineCapSquare ifTrue: [ ^#square ].
	anInteger == Cairo lineCapRound ifTrue: [ ^#round ].
	anInteger == Cairo lineCapButt ifTrue: [ ^#butt ].
	self error: 'Unsupported line cap value ', anInteger
    ]

    CairoContext class >> lookupLineJoinValue: anInteger [
	<category: 'private-accessing'>
	anInteger == Cairo lineJoinBevel ifTrue: [ ^#bevel ].
	anInteger == Cairo lineJoinRound ifTrue: [ ^#round ].
	anInteger == Cairo lineJoinMiter ifTrue: [ ^#miter ].
	self error: 'Unsupported line join value ', anInteger
    ]

    CairoContext class >> lookupFillRuleValue: anInteger [
	<category: 'private-accessing'>
	anInteger == Cairo fillRuleEvenOdd ifTrue: [ ^#evenOdd ].
	anInteger == Cairo fillRuleWinding ifTrue: [ ^#winding ].
	self error: 'Unsupported fill rule value ', anInteger
    ]

    CairoContext class >> lookupSlantValue: anInteger [
	<category: 'private-accessing'>
	anInteger == Cairo fontSlantNormal ifTrue: [ ^#normal ].
	anInteger == Cairo fontSlantItalic ifTrue: [ ^#italic ].
	anInteger == Cairo fontSlantOblique ifTrue: [ ^#oblique ].
	self error: 'Unsupported slant value ', anInteger
    ]

    CairoContext class >> lookupOperator: anInteger [
	<category: 'private-accessing'>
	anInteger == #clear ifTrue: [ ^Cairo operatorClear ].
	anInteger == #source ifTrue: [ ^Cairo operatorSource ].
	anInteger == #over ifTrue: [ ^Cairo operatorOver ].
	anInteger == #in ifTrue: [ ^Cairo operatorIn ].
	anInteger == #out ifTrue: [ ^Cairo operatorOut ].
	anInteger == #atop ifTrue: [ ^Cairo operatorAtop ].
	anInteger == #dest ifTrue: [ ^Cairo operatorDest ].
	anInteger == #destOver ifTrue: [ ^Cairo operatorDestOver ].
	anInteger == #destIn ifTrue: [ ^Cairo operatorDestIn ].
	anInteger == #destOut ifTrue: [ ^Cairo operatorDestOut ].
	anInteger == #destAtop ifTrue: [ ^Cairo operatorDestAtop ].
	anInteger == #xor ifTrue: [ ^Cairo operatorXor ].
	anInteger == #add ifTrue: [ ^Cairo operatorAdd ].
	anInteger == #saturate ifTrue: [ ^Cairo operatorSaturate ].
	self error: 'Unsupported operator value ', anInteger
    ]

    CairoContext class >> lookupLineCap: aSymbol [
	<category: 'private-accessing'>
	aSymbol == #square ifTrue: [ ^Cairo lineCapSquare ].
	aSymbol == #round ifTrue: [ ^Cairo lineCapRound ].
	aSymbol == #butt ifTrue: [ ^Cairo lineCapButt ].
	self error: 'Unsupported line cap symbol ', aSymbol
    ]

    CairoContext class >> lookupLineJoin: aSymbol [
	<category: 'private-accessing'>
	aSymbol == #bevel ifTrue: [ ^Cairo lineJoinBevel ].
	aSymbol == #round ifTrue: [ ^Cairo lineJoinRound ].
	aSymbol == #miter ifTrue: [ ^Cairo lineJoinMiter ].
	self error: 'Unsupported line join symbol ', aSymbol
    ]

    CairoContext class >> lookupFillRule: aSymbol [
	<category: 'private-accessing'>
	aSymbol == #evenOdd ifTrue: [ ^Cairo fillRuleEvenOdd ].
	aSymbol == #winding ifTrue: [ ^Cairo fillRuleWinding ].
	self error: 'Unsupported fill rule symbol ', aSymbol
    ]

    CairoContext class >> lookupSlant: aSymbol [
	<category: 'private-accessing'>
	aSymbol == #normal ifTrue: [ ^Cairo fontSlantNormal ].
	aSymbol == #italic ifTrue: [ ^Cairo fontSlantItalic ].
	aSymbol == #oblique ifTrue: [ ^Cairo fontSlantOblique ].
	self error: 'Unsupported slant symbol ', aSymbol
    ]

    CairoContext class >> lookupWeight: aSymbol [
	<category: 'private-accessing'>
	aSymbol == #normal ifTrue: [ ^Cairo fontWeightNormal ].
	aSymbol == #bold ifTrue: [ ^Cairo fontWeightBold ].
	self error: 'Unsupported weight symbol ', aSymbol
    ]

    selectFontFamily: aString slant: slantSymbol weight: weightSymbol [
	"Selects a family and style of font from a simplified description
	 as a family name, slant and weight. Cairo provides no operation
	 to list available family names on the system (the full Cairo API
	 for text is not yet supported), but the standard CSS2 generic
	 family names (serif, sans-serif, cursive, fantasy, monospace),
	 are likely to work as expected."
	<category: 'text'>
	Cairo selectFontFace: context
	      family: aString
	      slant: (self class lookupSlant: slantSymbol)
	      weight: (self class lookupWeight: weightSymbol).
    ]

    lineWidth [
	"Answer the current line width within the cairo context. The line
	 width value specifies the diameter of a pen that is circular in
	 user space."
	<category: 'accessing'>
	^Cairo getLineWidth: context.
    ]

    lineCap [
	"Answer the current line cap style within the cairo context."
	<category: 'accessing'>
	^self class lookupLineCapValue: (Cairo getLineCap: context).
    ]

    fillRule [
	"Answer the current fill rule style within the cairo context.
	 The fill rule is used to determine which regions are inside or
	 outside a complex (potentially self-intersecting) path."
	<category: 'accessing'>
	^self class lookupFillRuleValue: (Cairo getFillRule: context).
    ]

    lineJoin [
	"Answer how cairo will render the junction of two lines when stroking."
	<category: 'accessing'>
	^self class lookupLineJoinValue: (Cairo getLineJoin: context).
    ]

    operator [
	"Set how cairo will composite the destination, source and mask."
	<category: 'accessing'>
	^self class lookupOperatorValue: (Cairo getOperator: context).
    ]

    miterLimit [
	"Answer the miter limit of the cairo context, i.e. the ratio between
	 miter length and line width above which a #miter line join is
	 automatically converted to a bevel.  The limit angle, below which
	 the miter is converted by a bevel, is 2 * arcsin (1 / miterLimit)."
	<category: 'accessing'>
	^Cairo getMiterLimit: context.
    ]

    lineWidth: w [
	"Set the current line width within the cairo context. The line
	 width value specifies the diameter of a pen that is circular in
	 user space."
	<category: 'accessing'>
	Cairo setLineWidth: context width: w asCNumber.
    ]

    lineCap: aSymbol [
	"Set the current line cap style within the cairo context.  aSymbol
	 can be one of #square, #round, #butt."
	<category: 'accessing'>
	Cairo setLineCap: context lineCap: (self class lookupLineCap: aSymbol).
    ]

    fillRule: aSymbol [
	"Set the current fill rule style within the cairo context.  The
	 fill rule can be #winding or #evenOdd, and is used to determine
	 which regions are inside or outside a complex (potentially
	 self-intersecting) path."
	<category: 'accessing'>
	Cairo setFillRule: context fillRule: (self class lookupFillRule: aSymbol).
    ]

    lineJoin: aSymbol [
	"Set how cairo will render the junction of two lines when stroking.
	 aSymbol can be one of #miter, #round, #bevel."
	<category: 'accessing'>
	Cairo setLineJoin: context lineJoin: (self class lookupLineJoin: aSymbol).
    ]

    operator: aSymbol [
	"Set how cairo will composite the destination, source and mask."
	<category: 'accessing'>
	Cairo setOperator: context operator: (self class lookupOperator: aSymbol).
    ]

    miterLimit: aNumber [
	"Answer the miter limit of the cairo context, i.e. the ratio between
	 miter length and line width above which a #miter line join is
	 automatically converted to a bevel.  The miter limit can be computed
	 from a limit angle using the formula 1 / sin (angle / 2)."
	<category: 'accessing'>
	Cairo setMiterLimit: context miterLimit: aNumber asCNumber.
    ]

    fontSize: aNumber [
	"Sets the current font matrix to a scale by a factor
	of size, replacing any font matrix previously set. This results
	in an em-square of size by size user space units."
	<category: 'accessing'>
	Cairo setFontSize: context size: aNumber.
    ]

    showText: aString [
	"Generates and fills the shape from a string of UTF-8 characters,
	 rendered according to the current font face, size and slanting. "
	<category: 'drawing'>
	Cairo showText: context utf8: aString.
    ]

    textPath: aString [
	"Generates a set of closed paths from a string of UTF-8 characters,
	 rendered according to the current font face, size and slanting. "
	<category: 'paths'>
	Cairo textPath: context utf8: aString.
    ]

    textExtents: aString [
	"Gets the extents for a string of text. The extents describe a
	 user-space rectangle that encloses the inked portion of the text.
	 Whitespace characters do not directly contribute to the size of
	 the rectangle, except indirectly by changing the position
	 of subsequent non-whitespace characters.  Trailing whitespace,
	 in particular, affects the advance and not the extent."
	<category: 'text'>
	| ext |
	ext := CairoTextExtents gcNew.
	Cairo textExtents: context utf8: aString extents: ext.
	^TextExtents from: ext
    ]
].

Object subclass: TextExtents [

    <comment: 'I store the extents of a single glyph or a string of
glyphs in user-space coordinates.'>

    | bearing extent advance |

    bearing [
	"Return a Point giving the distance from the origin to the leftmost
	 part of the glyphs as drawn.  Coordinates are positive if the glyphs
	 lie entirely to the right of (resp. below) the origin."
	<category: 'accessing'>
	^bearing
    ]

    extent [
	"Return the width and height of the glyphs as drawn."
	<category: 'accessing'>
	^extent
    ]

    advance [
	"Return the distance to advance after drawing the glyphs.  The Y
	 component will typically be zero except for vertical text layout
	 as found in East-Asian languages."
	<category: 'accessing'>
	^advance
   ]

    TextExtents class >> from: aCairoTextExtents [
	<category: 'private-instance creation'>
	^ self new initializeFrom: aCairoTextExtents
    ]

    initializeFrom: aCairoTextExtents [
	<category: 'private'>
	bearing := aCairoTextExtents xBearing value @ aCairoTextExtents yBearing value.
	extent := aCairoTextExtents width value @ aCairoTextExtents height value.
	advance := aCairoTextExtents xAdvance value @ aCairoTextExtents yAdvance value.
    ]
].
PK
     �Mh@`�[N�G  �G    CairoTransform.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Compositional transformation classes using CairoMatrix
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones and Michael Bridgen.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

CStruct subclass: CairoMatrix [
    <declaration: #(
      (#xx #double)
      (#yx #double)
      (#xy #double)
      (#yy #double)
      (#x0 #double)
      (#y0 #double))>

    <category: 'Cairo-C interface'>

    initIdentity [
	<category: 'initialize'>
        Cairo matrixInitIdentity: self.
    ]

    withPoint: aPoint do: block [
	<category: 'using'>
	^block
	    value: self 
	    value: (CDouble gcValue: aPoint x)
	    value: (CDouble gcValue: aPoint y)
    ]

    copy [
	<category: 'copying'>
        | shiny |
        shiny := CairoMatrix gcNew.
        Cairo matrixInit: shiny 
	      xx: self xx value
	      yx: self yx value
	      xy: self xy value
	      yy: self yy value
	      x0: self x0 value
	      y0: self y0 value.
        ^ shiny
    ]
]


Object subclass: TransformVisitor [
    rotateBy: rads [
	"Visitor method for rotation by aPoint."

	<category: 'visiting'>
	self subclassResponsibility
    ]

    scaleBy: aPoint [
	"Visitor method for scaling by aPoint."

	<category: 'visiting'>
	self subclassResponsibility
    ]

    transformByMatrix: aMatrixTransform [
	"Visitor method for transforms by an arbitrary matrix."

	<category: 'visiting'>
	self subclassResponsibility
    ]

    translateBy: aPoint [
	"Visitor method for translations by aPoint."

	<category: 'visiting'>
	self subclassResponsibility
    ]

]

Object subclass: Transform [
    | matrix |

    <category: 'Cairo-Transformation matrices'>
    <comment: 'A note on transforms: to be compositional, the most
straight-forward thing is to always use a transformation matrix.  However,
a lot of the time, we''ll be doing just one kind of transformation;
e.g., a scale, or a translation.  Further, we may only ever modify a
transformation in one way, like translating a translation.  For this
reason, we specialise for each of the translations and provide a generic
matrix implementation for composing heterogeneous transformations.'>

    Transform class >> new [
	"Return an instance of the receiver representing the identity
	 transform."

	<category: 'instance creation'>
	^ super new initialize
    ]

    Transform class >> identity [
        "Return the identity transform, that leaves its visitor
        unchanged."

	<category: 'instance creation'>
        ^ IdentityTransform instance
    ]

    Transform class >> sequence: transforms [
        "Return a compound transform, that transforms its visitor by
        each of the Transforms in transforms in first-to-last order."

	<category: 'instance creation'>
	transforms isEmpty ifTrue: [ ^self identity ].
        ^ transforms fold: [:acc :xform | xform after: acc]
    ]

    initialize [
	"Overridden by subclasses so that the resulting object represents
	 the identity transform."
	<category: 'initializing'>
    ]

    before: aTransform [
        "Return a new Transform that transforms transform by self
         first, then by aTransform."

	<category: 'composing'>
        ^ aTransform after: self.
    ]

    accept: aVisitor [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
        self subclassResponsibility
    ]

    after: transform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
        self subclassResponsibility
    ]

    about: aPoint [
	"Return the transformation described by the receiver, performed
	 about aPoint rather than about 0@0."

	<category: 'composing'>
        ^ ((Translation by: aPoint)
              before: self) before: (Translation by: aPoint * -1)
    ]

    translateBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with a translation by aPoint."

	<category: 'composing'>
        ^ self asMatrixTransform translateBy: aPoint.
    ]

    scaleBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with scaling by aPoint."

	<category: 'composing'>
        ^ self asMatrixTransform scaleBy: aPoint.
    ]

    rotateBy: rads [
	"Return the transformation described by the receiver, composed
	 with rotation by rads radians."

	<category: 'composing'>
        ^ self asMatrixTransform rotateBy: rads.
    ]

    nullTransform [
	"Return the transformation described by the receiver, composed
	 with the identity transform."

	<category: 'composing'>
	^ self
    ]

    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
        self subclassResponsibility
    ]

    transformDistance: aPoint [
	"Answer the result of passing the vector aPoint through the receiver."

	<category: 'applying'>
        self subclassResponsibility
    ]

    asMatrixTransform [
	"Answer the receiver converted to a generic matrix-based
	 transformation."

	<category: 'converting'>
	self subclassResponsibility
    ]

    transformBounds: rect [
        "Transform the given bounds. Note this is distinct from
         transforming a rectangle, since bounds must be aligned with
         the axes."

	<category: 'applying'>
        | corners |
        corners := {self transformPoint: rect topLeft.
		    self transformPoint: rect topRight.
		    self transformPoint: rect bottomLeft.
		    self transformPoint: rect bottomRight}.
        ^ (corners fold: [ :left :right | left min: right ]) corner:
            (corners fold: [ :left :right | left max: right ])
    ]

    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
        ^ self subclassResponsibility
    ]

    scale [
	"Return the scale factor applied by the receiver."

	<category: 'accessing'>
	^ (1@1)
     ]
    
    rotation [
	"Return the rotation applied by the receiver, in radians."

	<category: 'accessing'>
	^ 0
    ]

    translation [
	"Return the translation applied by the receiver."

	<category: 'accessing'>
	^ (0@0)
    ]
		      
    translateTo: aPoint [
	"Return a version of the receiver that translates 0@0 to aPoint."

	<category: 'composing'>
	^ self translateBy: (aPoint - self translation).
    ]
    
    scaleTo: sxsy [
	"Return a version of the receiver that scales the distance 1@1 to
	 sxsy."

	<category: 'composing'>
	^ self scaleBy: sxsy asPoint / self scale
    ]

    rotateTo: rads [
	"Return a version of the receiver that rotates by rads."

	<category: 'composing'>
	^ self rotateBy: (rads - self rotation)
    ]
]

Transform subclass: MatrixTransform [
    | matrix |

    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent transforms using a matrix, in the most generic way.'>
    asMatrixTransform [
	"Return the receiver, since it is already a MatrixTransform."

	<category: 'converting'>
	^self
    ]

    matrix [
	<category: 'private-accessing'>
	^ matrix
    ]

    postCopy [
	<category: 'private-copying'>
        matrix := matrix copy.
    ]

    copyOp: aBlock [
	<category: 'private-composing'>
	| newMatrix |
	newMatrix := self copy.
	aBlock value: newMatrix matrix.
	^newMatrix
    ]

    initialize [
	"Initialize the receiver so that it represents the identity transform."

	<category: 'initialize'>
        matrix := CairoMatrix gcNew initIdentity.
    ]

    accept: aVisitor [
        "Sends #transformByMatrix:."

	<category: 'double dispatch'>
	^aVisitor transformByMatrix: self
    ]

    after: aTransform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
	^ aTransform asMatrixTransform
	    copyOp: [:n | Cairo matrixMultiply: n a: n b: self matrix]
    ]

    rotateBy: rads [
	"Return the transformation described by the receiver, composed
	 with rotation by rads radians."

	<category: 'composing'>
	^ self copyOp: [:n | Cairo matrixRotate: n radians: rads]
    ]

    scaleBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with scaling by aPoint."

	<category: 'composing'>
	| p |
	p := aPoint asPoint.
	^ self copyOp: [:n | Cairo matrixScale: n sx: p x sy: p y]
    ]

    translateBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with a translation by aPoint."

	<category: 'composing'>
	^ self copyOp: [:n | Cairo matrixTranslate: n tx: aPoint x ty: aPoint y]
    ]

    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
        ^self matrix withPoint: aPoint do:
            [ :mtx :x :y |
                Cairo matrixTransformPoint: mtx x: x y: y.
                x value @ y value
            ]
    ]

    transformDistance: aPoint [
	"Answer the result of passing the vector aPoint through the receiver."

	<category: 'applying'>
        ^self matrix withPoint: aPoint do:
            [ :mtx :x :y |
                Cairo matrixTransformDistance: mtx dx: x dy: y.
                x value @ y value
            ]
    ]

    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
	^ self copyOp: [:n | Cairo matrixInvert: n]
    ]

    scale [
	"Return the scale factor applied by the receiver."

	<category: 'accessing'>
	| pt1 pt2 |
	pt1 := self transformDistance: (1@0).
	pt2 := self transformDistance: (0@1).
	^ (pt1 dist: (0@0)) @ (pt2 dist: (0@0))
    ]

    rotation [
	"Return the rotation applied by the receiver, in radians."

	<category: 'accessing'>
	| pt1 pt2 |
	pt1 := self transformDistance: (1@0).
	pt2 := self transformDistance: (0@1).
	^ pt2 arcTan: pt1
    ]

    translation [
	"Return the translation applied by the receiver."

	<category: 'accessing'>
	^ self transformPoint: (0@0)
    ]
]

Transform subclass: AnalyticTransform [
    | matrix |

    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent transforms using its decomposition into scaling,
rotation and translation.  I am an abstract class.'>
    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
        ^self asMatrixTransform transformPoint: aPoint
    ]

    transformDistance: aPoint [
	"Answer the result of passing the vector aPoint through the receiver."

	<category: 'applying'>
        ^(self transformPoint: aPoint) - self translation
    ]

    asMatrixTransform [
	"Return the transformation described by the receiver, converted
	 to a transformation matrix."

	<category: 'converting'>
        matrix isNil ifTrue: [matrix := self after: MatrixTransform new].
	^matrix
    ]

]

AnalyticTransform subclass: IdentityTransform [

    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent the identity transform.'>
    IdentityTransform class [
        | instance |

        instance [
	    instance ifNil: [ instance := self new ].
	    ^instance
        ]
    ]

    accept: aVisitor [
        "Sends #nullTransform."

	<category: 'double dispatch'>
	^aVisitor nullTransform
    ]

    before: aTransform [
        "Return a new Transform that transforms transform by self
         first, then by aTransform."

	<category: 'composing'>
	^ aTransform
    ]

    after: aTransform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
	^ aTransform
    ]

    translateBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with a translation by aPoint."

	<category: 'composing'>
	^ Translation by: aPoint
    ]

    scaleBy: aPoint [
	"Return the transformation described by the receiver, composed
	 with scaling by aPoint."

	<category: 'composing'>
	^ Scale by: aPoint
    ]

    rotateBy: rads [
	"Return the transformation described by the receiver, composed
	 with rotation by rads radians."

	<category: 'composing'>
	^ Rotation by: rads
    ]

    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
	^ aPoint
    ]

    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
	^ self
    ]
]

AnalyticTransform subclass: Translation [
    | dxdy |

    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent translations analytically.'>
    Translation class >> by: aPoint [
	"Return an instance of the receiver representing translation by aPoint."
	<category: 'instance creation'>
        ^self basicNew
	    translation: aPoint;
	    yourself
    ]

    translation: aPoint [
	<category: 'private'>
        dxdy := aPoint.
    ]

    translateBy: point [
	"Return the transformation described by the receiver, composed
	 with a translation by aPoint."

	<category: 'composing'>
        ^ Translation by: (dxdy + point).
    ]

    initialize [
	"Initialize the receiver so that it represents the identity transform."

	<category: 'initializing'>
	dxdy := 0@0.
    ]

    accept: aVisitor [
        "Sends #translateBy:."

	<category: 'double dispatch'>
	aVisitor translateBy: dxdy.
    ]

    after: aTransform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
	^ aTransform translateBy: dxdy.
    ]

    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
        ^ aPoint + dxdy
    ]
    
    transformDistance: aPoint [
	"Answer the result of passing the vector aPoint through the receiver."

	<category: 'applying'>
        ^ aPoint
    ]

    transformBounds: rect [
        "Transform the given bounds. This is not distinct from
         transforming a rectangle in the case of translation."

	<category: 'applying'>
        ^ rect translateBy: dxdy
    ]

    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
        ^ Translation by: dxdy * -1
    ]

    translation [
	"Return the translation applied by the receiver."

	<category: 'accessing'>
	^ dxdy
    ]
]

AnalyticTransform subclass: Scale [
    | sxsy |
    
    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent scaling analytically.'>
    Scale class >> by: aPoint [
	"Return an instance of the receiver representing scaling by aPoint."
	<category: 'instance creation'>
        ^self basicNew
	    factors: aPoint asPoint;
	    yourself
    ]

    factors: aPoint [
	<category: 'private'>
        sxsy := aPoint.
    ]

    scaleBy: factors [
	"Return the transformation described by the receiver, composed
	 with scaling by aPoint."

	<category: 'composing'>
        ^ Scale by: (sxsy * factors)
    ]

    initialize [
	"Initialize the receiver so that it represents the identity transform."

	<category: 'initializing'>
	sxsy := 1@1.
    ]

    accept: aVisitor [
        "Sends #scaleBy:."

	<category: 'double dispatch'>
	aVisitor scaleBy: sxsy.
    ]

    after: aTransform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
	^ aTransform scaleBy: sxsy.
    ]

    transformPoint: aPoint [
	"Answer the result of passing the point aPoint through the receiver."

	<category: 'applying'>
        ^ aPoint * sxsy
    ]
    
    transformDistance: aPoint [
	"Answer the result of passing the vector aPoint through the receiver."

	<category: 'applying'>
        ^ aPoint * sxsy
    ]
    
    transformBounds: rect [
        "Transform the given bounds. This is not distinct from
         transforming a rectangle in the case of scaling."

        ^ rect scaleBy: sxsy
    ]
    
    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
        ^ Scale by: (1/sxsy x) @ (1/sxsy y)
    ]

    scale [
	"Return the scale factor applied by the receiver."

	<category: 'accessing'>
	^ sxsy
    ]
]

AnalyticTransform subclass: Rotation [
    | radians |

    <category: 'Cairo-Transformation matrices'>
    <comment: 'I represent rotations analytically.'>
    Rotation class >> by: rads [
	"Return an instance of the receiver representing rotation by rads
	 radians."
	<category: 'instance creation'>
        ^self basicNew
	    radians: rads;
	    yourself
    ]

    radians: aDouble [
	<category: 'private'>
        radians := aDouble.
    ]

    rotateBy: rads [
	"Return the transformation described by the receiver, composed
	 with rotation by rads radians."

	<category: 'composing'>
        ^ Rotation by: radians + rads.
    ]

    initialize [
	"Initialize the receiver so that it represents the identity transform."

	<category: 'initializing'>
	radians := 0.
    ]

    accept: aVisitor [
        "Sends #rotateBy:."

	<category: 'double dispatch'>
	aVisitor rotateBy: radians.
    ]

    after: aTransform [
        "Return a new Transform that transforms transform by
         aTransform first, then by self."

	<category: 'composing'>
	^ aTransform rotateBy: radians.
    ]

    inverse [
	"Return the inverse transform of the receiver."

	<category: 'composing'>
        ^ Rotation by: -1 * radians
    ]

    rotation [
	"Return the rotation applied by the receiver, in radians."

	<category: 'accessing'>
	^ radians
    ]
]
PK
     �Mh@;,�#8  #8            ��    CairoPattern.stUT cqXOux �  �  PK
     �Zh@��R�              ��l8  package.xmlUT ��XOux �  �  PK
     �Mh@�7�u2O  2O            ���9  CairoFuncs.stUT cqXOux �  �  PK
     �Mh@��{�&"  &"            ��@�  CairoSurface.stUT cqXOux �  �  PK
     �Mh@�"`W`o  `o            ����  CairoContext.stUT cqXOux �  �  PK
     �Mh@`�[N�G  �G            ��X CairoTransform.stUT cqXOux �  �  PK      �  qc   