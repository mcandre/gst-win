PK
     �Mh@�C��tL  tL    2D.stUT	 dqXO��XOux �  �  "======================================================================
|
|   GNUPlot bindings, GPPlot and related classes 
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation; either version 2, or (at your option)
| any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but
| WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
| or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
| for more details.
| 
| You should have received a copy of the GNU General Public License
| along with GNU Smalltalk; see the file COPYING.  If not, write to the
| Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
| 02110-1301, USA.  
|
 ======================================================================"

GPAbstractPlot subclass: GPPlot [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a single ''plot'' command.'>

    | xAxis x2Axis yAxis y2Axis barWidth barGap |

    GPPlot class >> defaultStyleClass [
        ^GPPlotStyle 
    ]

    axes [
	<category: 'printing'>
	"Note we don't use the accessors!"
	^{ xAxis ifNotNil: [ :axis | axis withName: 'x' ].
	   x2Axis ifNotNil: [ :axis | axis withName: 'x2' ].
	   yAxis ifNotNil: [ :axis | axis withName: 'y' ].
	   y2Axis  ifNotNil: [ :axis | axis withName: 'y2' ] }
    ]

    xAxis [
	<category: 'accessing'>
	^xAxis ifNil: [ xAxis := GPAxis new name: 'x'; yourself ]
    ]

    xAxis: aGPAxis [
	<category: 'accessing'>
	xAxis := aGPAxis
    ]

    x2Axis [
	<category: 'accessing'>
	^x2Axis ifNil: [ x2Axis := GPAxis new name: 'x2'; yourself ]
    ]

    x2Axis: aGPAxis [
	<category: 'accessing'>
	x2Axis := aGPAxis
    ]

    yAxis [
	<category: 'accessing'>
	^yAxis ifNil: [ yAxis := GPAxis new name: 'y'; yourself ]
    ]

    yAxis: aGPAxis [
	<category: 'accessing'>
	yAxis := aGPAxis
    ]

    y2Axis [
	<category: 'accessing'>
	^y2Axis ifNil: [ y2Axis := GPAxis new name: 'y2'; yourself ]
    ]

    y2Axis: aGPAxis [
	<category: 'accessing'>
	y2Axis := aGPAxis
    ]

    barGap [
	<category: 'accessing'>
	^barGap
    ]

    barGap: anInteger [
	<category: 'accessing'>
	barGap := anInteger
    ]

    barWidth [
	<category: 'accessing'>
	barWidth isNil ifTrue: [ barWidth := 1 ].
	^barWidth
    ]

    barWidth: aNumber [
	<category: 'accessing'>
	barWidth := aNumber
    ]

    newGroup: anInteger of: maxGroup [
	<category: 'private'>
	| gap |
	gap := (self barGap ifNil: [ #(##(1/2) 1) at: maxGroup ifAbsent: [2] ])
	  - (1 - self barWidth).
	^(super newGroup: anInteger of: maxGroup)
	    barOffset: (2 * anInteger - 1 - maxGroup) / 2 / (maxGroup + gap);
	    barWidth: self barWidth / (maxGroup + gap);
	    yourself
    ]

    function: exprBlock [
	<category: 'building'>
	| expr |
	expr := exprBlock value: (GPVariableExpression on: $x).
        ^self add: (GPFunctionSeries on: expr)
    ]

    lrSteps: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'steps';
			yourself)
    ]

    lrSteps: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self lrSteps: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    ulSteps: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'fsteps';
			yourself)
    ]

    ulSteps: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self ulSteps: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    centerSteps: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'histeps';
			yourself)
    ]

    centerSteps: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self centerSteps: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    dots: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'dots';
			yourself)
    ]

    dots: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self dots: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    points: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'points';
			yourself)
    ]

    points: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self points: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    labels: aDataSourceOrArray [
	<category: 'building'>
	"For now, center is passed from here.  Later, GPTextSeries will have
	 its own params class."
	^self add: ((GPTextSeries on: aDataSourceOrArray)
			graphType: 'labels center';
			yourself)
    ]

    labels: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self labels: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    bubbles: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPBubbleSeries on: aDataSourceOrArray)
			graphType: 'points';
			yourself)
    ]

    bubbles: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self bubbles: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    impulses: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'impulses';
			yourself)
    ]

    impulses: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self impulses: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    vectors: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPVectorSeries on: aDataSourceOrArray)
			graphType: 'vectors';
			yourself)
    ]

    vectors: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self vectors: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    bars: aDataSourceOrArray [
	<category: 'building'>
	^self add: (GPBarSeries on: aDataSourceOrArray)
    ]

    bars: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self bars: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    boxes: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPBoxSeries on: aDataSourceOrArray)
			graphType: 'boxes';
			yourself)
    ]

    boxes: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self boxes: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    xyErrorBoxes: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYErrorSeries on: aDataSourceOrArray)
			graphType: 'boxxyerrorbars';
			yourself)
    ]

    xyErrorBoxes: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self xyErrorBoxes: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    errorBoxes: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPErrorBoxSeries on: aDataSourceOrArray)
			graphType: 'boxerrorbars';
			yourself)
    ]

    errorBoxes: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self errorBoxes: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    candleSticks: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPFinancialDataSeries on: aDataSourceOrArray)
			graphType: 'candlesticks';
			yourself)
    ]

    candleSticks: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self candleSticks: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    financeBars: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPFinancialDataSeries on: aDataSourceOrArray)
			graphType: 'financebars';
			yourself)
    ]

    financeBars: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self financeBars: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    lines: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYSeries on: aDataSourceOrArray)
			graphType: 'lines';
			yourself)
    ]

    lines: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self lines: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    xyErrorBars: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXYErrorSeries on: aDataSourceOrArray)
			graphType: 'xyerrorbars';
			yourself)
    ]

    xyErrorBars: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self xyErrorBars: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    xErrorBars: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPXErrorSeries on: aDataSourceOrArray)
			graphType: 'xerrorbars';
			yourself)
    ]

    xErrorBars: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self xErrorBars: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    errorBars: aDataSourceOrArray [
	<category: 'building'>
	^self add: ((GPErrorSeries on: aDataSourceOrArray)
			graphType: 'errorbars';
			yourself)
    ]

    errorBars: aDataSourceOrArray with: aBlock [
	<category: 'building'>
	| series |
	series := self errorBars: aDataSourceOrArray.
	aBlock value: series.
	^series
    ]

    displaySeriesOn: aStream [
	<category: 'printing'>
        aStream nextPutAll: 'plot '.
        super displaySeriesOn: aStream
    ]
]

GPStyle subclass: GPPlotStyle [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define parameters for a ''plot'' command.'>

]

GPGroupSeries subclass: GPBarSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for an histogram.'>

    defaultColumns [
	^{ GPColumnRef column: 1 }
    ]

    data [
	^self columns first
    ]

    data: expr [
	self columns: { expr asGPExpression }
    ]

    displayOn: aStream group: aGroup [
        self dataSource displayOn: aStream.
        aStream nextPutAll: ' using '.
        self displayColumnsOn: aStream group: aGroup.
        self displayStyleOn: aStream group: aGroup.
	aGroup stackData: self data.
        self displayTicLabelsOn: aStream group: aGroup.
    ]

    displayColumnsOn: aStream group: aGroup [
	aStream nextPutAll: '($0'.
	aGroup barOffset < 0 ifFalse: [ aStream nextPut: $+ ].
	aStream print: aGroup barOffset asFloat.
	aStream nextPutAll: '):'.
	aGroup dataOffset isNil
	    ifTrue: [
		aStream display: self data.
		aStream nextPutAll: ':('.
		aStream display: aGroup barWidth asFloat.
		aStream nextPut: $) ]
	    ifFalse: [
		aStream display: aGroup dataOffset + (self data / 2).
		aStream nextPutAll: ':('.
		aStream display: (aGroup barWidth / 2) asFloat.
		aStream nextPutAll: '):'.
		aStream display: self data / 2 ].
    ]

    displayStyleOn: aStream group: aGroup [
	aGroup dataOffset isNil
	    ifTrue: [ aStream nextPutAll: ' with boxes' ]
	    ifFalse: [ aStream nextPutAll: ' with boxxyerrorbars' ].
	super displayStyleOn: aStream group: aGroup
    ]

    displayTicLabelsOn: aStream group: aGroup [
	ticColumns isNil ifFalse: [
	    aStream nextPutAll: ', '.
	    self dataSource displayOn: aStream.
	    aStream nextPutAll: ' using 0:'.
	    aStream display: aGroup dataOffset.
	    aStream nextPutAll: ':""'.
	    super displayTicLabelsOn: aStream group: aGroup.
	    aStream nextPutAll: ' notitle with labels'.
	]
    ]

    printDataOn: aStream [
	super printDataOn: aStream.
	ticColumns isNil ifFalse: [ super printDataOn: aStream ].
    ]
]

GPDataSeries subclass: GPXYSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values.'>

    defaultColumns [
	| c0 c1 c2 |
	c0 := GPColumnRef column: 0.
	c1 := GPColumnRef column: 1.
	(self ticColumns notNil and: [ self ticColumns includes: 2 ])
	    ifTrue: [ ^{ c0. c1 } ].

	c2 := GPColumnRef column: 2.
	^{ c2 ifValid: [ c1 ] ifNotValid: [ c0 ].
	   c2 ifValid: [ c2 ] ifNotValid: [ c1 ] }
    ]

    data: expr [
	self columns: { expr asGPExpression }
    ]

    x: xExpr y: yExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression  }
    ]
]

GPXYSeries subclass: GPBubbleSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y,size) values,
i.e. a bubble plot.'>

    GPBubbleSeries class >> defaultStyle [
	^defaultStyle ifNil: [ super defaultStyle pointType: 6; yourself ]
    ]

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3 }
    ]

    x: xExpr y: yExpr size: sizeExpr [
	self columns: { xExpr asGPExpression. yExpr asGPExpression.
			sizeExpr asGPExpression }
    ]

    displayOn: aStream [
	super displayOn: aStream.
	aStream nextPutAll: ' ps variable'
    ]
]

GPXYSeries subclass: GPTextSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y,text) values.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3 }
    ]

    x: xExpr y: yExpr text: textExpr [
	self columns: { xExpr asGPExpression. yExpr asGPExpression.
			textExpr asGPExpression }
    ]
]

GPXYSeries subclass: GPBoxSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values
optionally specifying a box width.'>

    x: xExpr y: yExpr width: widthExpr [
	self columns: { xExpr asGPExpression. yExpr asGPExpression.
			widthExpr asGPExpression }
    ]
]

GPDataSeries subclass: GPErrorSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values
with a (vertical) error bar.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3 }
    ]

    x: xExpr y: yExpr error: errExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			errExpr asGPExpression }
    ]

    x: xExpr min: minExpr max: maxExpr [
	| y err min max |
	min := minExpr asGPExpression.
        max := maxExpr asGPExpression.
	y := (min + max) / 2.
	err := (max - min) / 2.
	self columns: { xExpr asGPExpression.  y. err }
    ]

    x: xExpr y: yExpr min: minExpr max: maxExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			minExpr asGPExpression.
			maxExpr asGPExpression }
    ]
]

GPErrorSeries subclass: GPErrorBoxSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values
with an adjustable width and a (vertical) error bar.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3 }
    ]

    x: xExpr y: yExpr error: errExpr width: widthExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			errExpr asGPExpression.
			widthExpr asGPExpression }
    ]

    x: xExpr min: minExpr max: maxExpr width: widthExpr [
	| y err min max |
	min := minExpr asGPExpression.
        max := maxExpr asGPExpression.
	y := (min + max) / 2.
	err := (max - min) / 2.
	self columns: { xExpr asGPExpression.  y. err.
			widthExpr asGPExpression }
    ]

    x: xExpr y: yExpr min: minExpr max: maxExpr width: widthExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			minExpr asGPExpression.
			maxExpr asGPExpression.
			widthExpr asGPExpression }
    ]
]

GPDataSeries subclass: GPXErrorSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values
with an horizontal error bar.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3 }
    ]

    x: xExpr error: errExpr y: yExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			errExpr asGPExpression }
    ]

    min: minExpr max: maxExpr y: yExpr [
	| x err min max |
	min := minExpr asGPExpression.
        max := maxExpr asGPExpression.
	x := (min + max) / 2.
	err := (max - min) / 2.
	self columns: { x. yExpr asGPExpression. err }
    ]

    x: xExpr min: minExpr max: maxExpr y: yExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			minExpr asGPExpression.
			maxExpr asGPExpression }
    ]
]

GPDataSeries subclass: GPXYErrorSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for (x,y) values
with 2D error bars.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3. GPColumnRef column: 4 }
    ]

    x: xExpr error: xErrExpr y: yExpr error: yErrExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			xErrExpr asGPExpression.
			yErrExpr asGPExpression }
    ]

    xMin: xMinExpr max: xMaxExpr yMin: yMinExpr max: yMaxExpr [
	| x y xErr yErr xMin yMin xMax yMax |
	xMin := xMinExpr asGPExpression.
        xMax := xMaxExpr asGPExpression.
	x := (xMin + xMax) / 2.
	xErr := (xMax - xMin) / 2.
	yMin := yMinExpr asGPExpression.
        yMax := yMaxExpr asGPExpression.
	y := (yMin + yMax) / 2.
	yErr := (yMax - yMin) / 2.
	self columns: { x. y. xErr. yErr }
    ]

    x: xExpr min: xMinExpr max: xMaxExpr y: yExpr min: yMinExpr max: yMaxExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			xMinExpr asGPExpression.
			xMaxExpr asGPExpression.
			yMinExpr asGPExpression.
			yMaxExpr asGPExpression }
    ]
]

GPDataSeries subclass: GPVectorSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for vector fields.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3. GPColumnRef column: 4 }
    ]

    x: xExpr dx: dxExpr y: yExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			dxExpr asGPExpression.
			0 asGPExpression }
    ]

    x: xExpr y: yExpr dx: dxExpr dy: dyExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			dxExpr asGPExpression.
			dyExpr asGPExpression }
    ]

    x: xExpr dx: dxExpr y: yExpr dy: dyExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			dxExpr asGPExpression.
			dyExpr asGPExpression }
    ]

    x1: x1Expr x2: x2Expr y: yExpr [
	| x1 |
	x1 := x1Expr asGPExpression.
	self columns: { x1.  yExpr asGPExpression.
			x2Expr asGPExpression - x1.
			0 asGPExpression }
    ]

    x: xExpr y: yExpr dy: dyExpr [
	self columns: { xExpr asGPExpression.
			yExpr asGPExpression.
			0 asGPExpression.
			dyExpr asGPExpression }
    ]

    x: xExpr y1: y1Expr y2: y2Expr [
	| y1 |
	y1 := y1Expr asGPExpression.
	self columns: { xExpr asGPExpression.  y1.
			0 asGPExpression.
			y2Expr asGPExpression - y1 }
    ]

    x1: x1Expr x2: x2Expr y1: y1Expr y2: y2Expr [
	| x1 y1 |
	x1 := x1Expr asGPExpression.
	y1 := y1Expr asGPExpression.
	self columns: { x1.  y1.
			x2Expr asGPExpression - x1.
			y2Expr asGPExpression - y1 }
    ]
]

GPDataSeries subclass: GPFinancialDataSeries [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a data series for
low/high/open/close values.'>

    defaultColumns [
	^{ GPColumnRef column: 1. GPColumnRef column: 2.
	   GPColumnRef column: 3. GPColumnRef column: 4.
	   GPColumnRef column: 5 }
    ]

    x: xExpr open: openExpr low: lowExpr high: highExpr close: closeExpr [
	self columns: { xExpr asGPExpression.
			openExpr asGPExpression.
			lowExpr asGPExpression.
			highExpr asGPExpression.
			closeExpr asGPExpression }
    ]

]

PK
     �Mh@���a0  0    Expressions.stUT	 dqXO��XOux �  �  "======================================================================
|
|   GNUPlot bindings, expression trees
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation; either version 2, or (at your option)
| any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but
| WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
| or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
| for more details.
| 
| You should have received a copy of the GNU General Public License
| along with GNU Smalltalk; see the file COPYING.  If not, write to the
| Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
| 02110-1301, USA.  
|
 ======================================================================"

GPObject subclass: GPExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define plotted functions.'>

    precedence [
	self subclassResponsibility
    ]

    printOn: aStream [
	<category: 'printing'>
	self class printOn: aStream.
	aStream nextPut: $(.
	self displayAsOperandOn: aStream.
	aStream nextPut: $)
    ]
 
    displayPrologOn: aStream into: defs [
    ]
 
    displayAsOperandOn: aStream [
	<category: 'printing'>
    ]

    displayOn: aStream [
	<category: 'printing'>
	aStream nextPut: $(.
	self displayAsOperandOn: aStream.
	aStream nextPut: $).
    ]

    printOperand: aGPExpression on: aStream [
	<category: 'printing'>
	aGPExpression precedence < self precedence
	     ifTrue: [ aStream nextPut: $( ].
	aGPExpression displayAsOperandOn: aStream.
	aGPExpression precedence < self precedence
	     ifTrue: [ aStream nextPut: $) ]
    ]

    Object >> asGPExpression [
	<category: 'conversion'>
	^GNUPlot.GPLiteralExpression on: self
    ]

    asGPExpression [
	<category: 'conversion'>
	^self
    ]

    coerce: aNumber [
	<category: 'mixed computation'>
	^aNumber asGPExpression
    ]

    generality [
	<category: 'mixed computation'>
	^1000
    ]

    + expr [
	<category: 'mixed computation'>
	^GPBinaryExpression new
	    op: #+ prec: -4 lhs: self rhs: expr asGPExpression;
	    yourself
    ]

    - expr [
	<category: 'mixed computation'>
	^GPBinaryExpression new
	    op: #- prec: -4 lhs: self rhs: expr asGPExpression;
	    yourself
    ]

    * expr [
	<category: 'mixed computation'>
	^GPBinaryExpression new
	    op: #* prec: -3 lhs: self rhs: expr asGPExpression;
	    yourself
    ]

    / expr [
	<category: 'mixed computation'>
	^GPBinaryExpression new
	    op: #/ prec: -3 lhs: self rhs: expr asGPExpression;
	    yourself
    ]

    raisedTo: expr [
	<category: 'mixed computation'>
	^GPBinaryExpression new
	    op: '**' prec: -1 lhs: self rhs: expr asGPExpression;
	    yourself
    ]

    raisedToInteger: expr [
	<category: 'mixed computation'>
	^self raisedTo: expr
    ]

    bitInvert [
	<category: 'mixed computation'>
	^GPUnaryOpExpression new
	    op: '~' expr: self
    ]

    negated [
	<category: 'mixed computation'>
	^GPUnaryOpExpression new
	    op: #- expr: self
    ]

    squared [
	<category: 'mixed computation'>
	^self raisedTo: 2
    ]

    abs [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'abs' expr: self
    ]

    sign [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'sgn' expr: self
    ]

    round [
	<category: 'mixed computation'>
	^(self + 0.5) truncated
    ]

    truncated [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'int' expr: self
    ]

    ceiling [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'ceil' expr: self
    ]

    floor [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'floor' expr: self
    ]

    ln [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'log' expr: self
    ]

    log [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'log10' expr: self
    ]

    exp [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'exp' expr: self
    ]

    arcTanh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'atanh' expr: self
    ]

    arcCosh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'acosh' expr: self
    ]

    arcSinh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'asinh' expr: self
    ]

    tanh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'tanh' expr: self
    ]

    cosh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'cosh' expr: self
    ]

    sinh [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'sinh' expr: self
    ]

    arcTan [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'atan' expr: self
    ]

    arcCos [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'acos' expr: self
    ]

    arcSin [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'asin' expr: self
    ]

    tan [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'tan' expr: self
    ]

    cos [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'cos' expr: self
    ]

    sin [
	<category: 'mixed computation'>
	^GPFunctionExpression new
	    op: 'sin' expr: self
    ]
]

GPExpression subclass: GPUnaryExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    | op expr |
    displayAsOperandOn: aStream [
	aStream nextPutAll: op.
	self printOperand: expr on: aStream.
    ]
 
    displayPrologOn: aStream into: defs [
	expr displayPrologOn: aStream into: defs
    ]

    op: operandSymbol expr: exprExpr [
	op := operandSymbol.
	expr := exprExpr
    ]
]

GPUnaryExpression subclass: GPUnaryOpExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    precedence [
	^-2
    ]
]

GPUnaryExpression subclass: GPFunctionExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    precedence [
	^1
    ]
]

GPFunctionExpression subclass: GPFitExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions
and represent functions fitted to a data source.'>

    | source function expr params |
    GPFunctionExpression class >>
	name: aString source: aSource function: aBlock variable: expr [
	^self new
	    op: aString expr: expr;
	    source: aSource asGPDataSource function: aBlock;
	    yourself
    ]

    source: aSource function: aBlock [
	"Use variables from A on as parameters"
	params := (1 to: aBlock argumentCount) collect: [ :i |
	    GPVariableExpression on: (Character digitValue: i + 9) ].

	function := aBlock valueWithArguments: params.
	source := aSource
    ]

    displayPrologOn: aStream into: defs [
	(defs includes: self) ifTrue: [ ^self ].
	defs add: self.
	super displayPrologOn: aStream into: defs.

	"f(x)=a*x+b"
	self displayAsOperandOn: aStream.
	aStream
	     nextPut: $=;
	     display: function;
	     nl;
	     nextPutAll: 'fit '.
	
	"fit f(x) 'filename' using 1:2 via A,B"
	self displayAsOperandOn: aStream.
	aStream
	    space;
	    display: source;
	    nextPutAll: ' using 1:2 via '.

	params
	    do: [ :each | each displayAsOperandOn: aStream ]
	    separatedBy: [ aStream nextPut: $, ].

	aStream nl.
	source printDataOn: aStream.
	aStream nl.
    ]
]

GPExpression subclass: GPBinaryExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    | op prec lhs rhs |
    precedence [
	^prec
    ]

    displayAsOperandOn: aStream [
	self printOperand: lhs on: aStream.
	aStream nextPutAll: op.
	self printOperand: rhs on: aStream.
    ]
 
    displayPrologOn: aStream into: defs [
	lhs displayPrologOn: aStream into: defs.
	rhs displayPrologOn: aStream into: defs
    ]

    op: operandSymbol prec: precedence lhs: lhsExpr rhs: rhsExpr [
	op := operandSymbol.
	prec := precedence.
	lhs := lhsExpr.
	rhs := rhsExpr
    ]
]

GPExpression subclass: GPCondExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    | cond trueBranch falseBranch |

    GPCondExpression class >> condition: condExpr ifTrue: trueExpr ifFalse: falseExpr [
	^self new
	    condition: condExpr ifTrue: trueExpr ifFalse: falseExpr;
	    yourself
    ]

    precedence [
	^-10
    ]

    displayAsOperandOn: aStream [
	self printOperand: cond on: aStream.
	aStream nextPut: $?.
	self printOperand: trueBranch on: aStream.
	aStream nextPut: $:.
	self printOperand: falseBranch on: aStream.
    ]
 
    displayPrologOn: aStream into: defs [
	cond displayPrologOn: aStream into: defs.
	trueBranch displayPrologOn: aStream into: defs.
	falseBranch displayPrologOn: aStream into: defs
    ]

    condition: condExpr ifTrue: trueExpr ifFalse: falseExpr [
	cond := condExpr.
	trueBranch := trueExpr value.
	falseBranch := falseExpr value
    ]
]

GPExpression subclass: GPPrimaryExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions.'>

    precedence [
	^0
    ]
]

GPPrimaryExpression subclass: GPColumnRef [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions
and refer to columns of external data sets.'>

    | column |
    GPColumnRef class >> column: anInteger [
	<category: 'instance creation'>
	^self new column: anInteger
    ]

    column [
	<category: 'accessing'>
	^column
    ]

    column: aString [
	<category: 'private - initialization'>
	column := aString
    ]

    displayAsOperandOn: aStream [
	<category: 'printing'>
	aStream nextPut: $$.
	column printOn: aStream
    ]

    displayOn: aStream [
	<category: 'printing'>
	column printOn: aStream
    ]

    valid [
	<category: 'building'>
	^GPColumnRefValidExpression column: self column
    ]

    ifValid: validBlock ifNotValid: invalidBlock [
	<category: 'building'>
	^GPCondExpression
	    condition: self valid
	    ifTrue: validBlock
	    ifFalse: invalidBlock
    ]
]

GPPrimaryExpression subclass: GPColumnRefValidExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions
and refer to columns of external data sets.'>

    | column |
    GPColumnRefValidExpression class >> column: anInteger [
	<category: 'instance creation'>
	^self new column: anInteger
    ]

    column [
	<category: 'accessing'>
	^column
    ]

    column: aString [
	<category: 'private - initialization'>
	column := aString
    ]

    displayAsOperandOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'valid('.
	column printOn: aStream.
	aStream nextPut: $).
    ]

    displayOn: aStream [
	<category: 'printing'>
	column printOn: aStream
    ]
]

GPPrimaryExpression subclass: GPLiteralExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions
and usually refer to numeric values.'>

    | object |
    GPLiteralExpression class >> on: anObject [
	<category: 'instance creation'>
	^self new object: anObject
    ]

    object [
	<category: 'accessing'>
	^object
    ]

    object: aString [
	<category: 'private - initialization'>
	object := aString
    ]

    displayAsOperandOn: aStream [
	<category: 'printing'>
	object displayOn: aStream
    ]
]

UndefinedObject extend [
    asGPExpression [
	^GNUPlot.GPLiteralExpression on: '(1/0)'
    ]
]

GPLiteralExpression subclass: GPVariableExpression [
    <category: 'GNUPlot'>
    <comment: 'My instances are used in the syntax tree of plotted functions
and refer to independent variables.'>

    fit: source to: aBlock name: aString [
	^GPFitExpression
	    name: aString
	    source: source asGPDataSource
	    function: aBlock
	    variable: self
    ]
]

PK
     �Mh@�l�#H'  H'    Terminals.stUT	 dqXO��XOux �  �  "======================================================================
|
|   GNUPlot bindings, concrete terminal
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation; either version 2, or (at your option)
| any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but
| WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
| or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
| for more details.
| 
| You should have received a copy of the GNU General Public License
| along with GNU Smalltalk; see the file COPYING.  If not, write to the
| Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
| 02110-1301, USA.  
|
 ======================================================================"


"The GPPngTerminal class is Copyright (c) 2007 Igor Stasenko
 and licensed under the X11 license.

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the `Software'), to deal in the Software without
    restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following
    conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE."

GPFileTerminal subclass: GPPngTerminal [
    <category: 'GNUPlot'>
    <comment: 'My instances describe an abstract GNU Plot terminal
that saves plots to a PNG file.'>

    | transparent interlace trueColor crop rounded font size enhanced |
    
    enhanced [
	<category: 'accessing'>
	^enhanced
    ]

    enhanced: aBoolean [
	<category: 'accessing'>
	enhanced := aBoolean
    ]

    font [
	<category: 'accessing'>
	^font
    ]

    font: aSymbolOrString [
	<category: 'accessing'>
	"font could be a one of: tiny | small | medium | large | giant
	 (symbols), or '<face> {pointsize}' "
	font := aSymbolOrString
    ]

    initialize [
	"Set default values"

	<category: 'initialize-release'>
	super initialize.
	transparent := false.
	interlace := false.
	trueColor := true.
	crop := false.
	rounded := true.
	font := #medium.
	size := 640 @ 480.
	enhanced := false.
    ]

    interlace [
	<category: 'accessing'>
	^interlace
    ]

    interlace: aBoolean [
	<category: 'accessing'>
	interlace := aBoolean
    ]

    printOptionsOn: str [
	<category: 'printing'>
	transparent ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'transparent '.
	interlace ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'interlace '.
	crop ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'crop '.
	trueColor ifFalse: [str nextPutAll: 'no'].
	str
	    nextPutAll: 'truecolor ';
	    nextPutAll: (rounded ifTrue: ['rounded '] ifFalse: ['butt ']);
	    nextPut: Character space;
	    nextPutAll: 'size ';
	    display: size x;
	    nextPut: $, ;
	    display: size y;
	    space.

	enhanced ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'enhanced '.

	font isNil ifFalse: [
	    font isSymbol
		ifTrue: [ str nextPutAll: font ]
		ifFalse: [ str nextPutAll: 'font '; print: font ].
	    str space ]
    ]

    crop [
	<category: 'accessing'>
	^crop
    ]

    crop: aBoolean [
	<category: 'accessing'>
	crop := aBoolean
    ]

    rounded [
	<category: 'accessing'>
	^rounded
    ]

    rounded: aBoolean [
	<category: 'accessing'>
	rounded := aBoolean
    ]

    size [
	<category: 'accessing'>
	^size
    ]

    size: aPoint [
	<category: 'accessing'>
	size := aPoint
    ]

    name [
	<category: 'printing'>
	^'png'
    ]

    transparent [
	<category: 'accessing'>
	^transparent
    ]

    transparent: aBoolean [
	<category: 'accessing'>
	transparent := aBoolean
    ]

    trueColor [
	<category: 'accessing'>
	^trueColor
    ]

    trueColor: aBoolean [
	<category: 'accessing'>
	trueColor := aBoolean
    ]
]


GPFileTerminal subclass: GPGifTerminal [
    <category: 'GNUPlot'>
    <comment: 'My instances describe an abstract GNU Plot terminal
that saves plots to a PNG file.'>

    | crop transparent animate font size enhanced |
    
    handlesMultiplot [
	^self animate
    ]

    enhanced [
	<category: 'accessing'>
	^enhanced
    ]

    enhanced: aBoolean [
	<category: 'accessing'>
	enhanced := aBoolean
    ]

    font [
	<category: 'accessing'>
	^font
    ]

    font: aSymbolOrString [
	<category: 'accessing'>
	"font could be a one of: tiny | small | medium | large | giant
	 (symbols), or '<face> {pointsize}' "
	font := aSymbolOrString
    ]

    crop [
	<category: 'accessing'>
	^crop
    ]

    crop: aBoolean [
	<category: 'accessing'>
	crop := aBoolean
    ]

    initialize [
	"Set default values"

	<category: 'initialize-release'>
	super initialize.
	transparent := false.
	animate := false.
	crop := false.
	size := 640 @ 480.
	enhanced := false.
    ]

    printOptionsOn: str [
	<category: 'printing'>
	transparent ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'transparent '.
	crop ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'crop '.
	animate ifFalse: [str nextPutAll: 'no'].
	str
	    nextPutAll: 'animate size ';
	    display: size x;
	    nextPut: $, ;
	    display: size y;
	    space.

	enhanced ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'enhanced '.

	font isNil ifFalse: [ str nextPutAll: 'font '; print: font; space ]
    ]

    size [
	<category: 'accessing'>
	^size
    ]

    size: aPoint [
	<category: 'accessing'>
	size := aPoint
    ]

    name [
	<category: 'printing'>
	^'gif'
    ]

    transparent [
	<category: 'accessing'>
	^transparent
    ]

    transparent: aBoolean [
	<category: 'accessing'>
	transparent := aBoolean
    ]

    animate [
	<category: 'accessing'>
	^animate
    ]

    animate: aBoolean [
	<category: 'accessing'>
	animate := aBoolean
    ]
]



GPFileTerminal subclass: GPPostscriptTerminal [
    <category: 'GNUPlot'>
    <comment: 'My instances describe an abstract GNU Plot terminal
that saves plots to a EPS file.'>

    | color rounded font enhanced size |
    
    enhanced [
	<category: 'accessing'>
	^enhanced
    ]

    enhanced: aBoolean [
	<category: 'accessing'>
	enhanced := aBoolean
    ]

    font [
	<category: 'accessing'>
	^font
    ]

    font: aSymbolOrString [
	<category: 'accessing'>
	font := aSymbolOrString
    ]

    initialize [
	"Set default values"

	<category: 'initialize-release'>
	super initialize.
	color := false.
	rounded := true.
	size := 5 @ 3.5.
	enhanced := false.
    ]

    printOptionsOn: str [
	<category: 'printing'>
	enhanced ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'enhanced '.
	str
	    nextPutAll: (color ifTrue: ['color '] ifFalse: ['monochrome ']);
	    nextPutAll: (rounded ifTrue: ['rounded'] ifFalse: ['butt']);
	    nextPutAll: ' size ';
	    display: size x;
	    nextPut: $, ;
	    display: size y;
	    space.

	font isNil ifFalse: [ str nextPutAll: 'font '; print: font; space ]
    ]

    rounded [
	<category: 'accessing'>
	^rounded
    ]

    rounded: aBoolean [
	<category: 'accessing'>
	rounded := aBoolean
    ]

    size [
	<category: 'accessing'>
	^size
    ]

    size: aPoint [
	<category: 'accessing'>
	size := aPoint
    ]

    color [
	<category: 'accessing'>
	^color
    ]

    color: aBoolean [
	<category: 'accessing'>
	color := aBoolean
    ]
]


GPPostscriptTerminal subclass: GPEpsTerminal [
    name [
	<category: 'printing'>
	^'postscript eps'
    ]

]

GPPostscriptTerminal subclass: GPPsTerminal [
    name [
	<category: 'printing'>
	^'pdf'
    ]

]

GPFileTerminal subclass: GPSvgTerminal [
    <category: 'GNUPlot'>
    <comment: 'My instances describe an abstract GNU Plot terminal
that saves plots to a EPS file.'>

    | resizable rounded font enhanced size |
    
    enhanced [
	<category: 'accessing'>
	^enhanced
    ]

    enhanced: aBoolean [
	<category: 'accessing'>
	enhanced := aBoolean
    ]

    font [
	<category: 'accessing'>
	^font
    ]

    font: aSymbolOrString [
	<category: 'accessing'>
	font := aSymbolOrString
    ]

    initialize [
	"Set default values"

	<category: 'initialize-release'>
	super initialize.
	resizable := false.
	rounded := true.
	size := 640 @ 480.
	enhanced := false.
    ]

    printOptionsOn: str [
	<category: 'printing'>
	enhanced ifFalse: [str nextPutAll: 'no'].
	str nextPutAll: 'enhanced '.
	str
	    nextPutAll: (resizable ifTrue: ['dynamic '] ifFalse: ['fixed ']);
	    nextPutAll: (rounded ifTrue: ['rounded'] ifFalse: ['butt']);
	    nextPutAll: ' size ';
	    display: size x;
	    nextPut: $, ;
	    display: size y;
	    space.

	font isNil ifFalse: [ str nextPutAll: 'font '; print: font; space ]
    ]

    rounded [
	<category: 'accessing'>
	^rounded
    ]

    rounded: aBoolean [
	<category: 'accessing'>
	rounded := aBoolean
    ]

    size [
	<category: 'accessing'>
	^size
    ]

    size: aPoint [
	<category: 'accessing'>
	size := aPoint
    ]

    name [
	<category: 'printing'>
	^'svg'
    ]

    resizable [
	<category: 'accessing'>
	^resizable
    ]

    resizable: aBoolean [
	<category: 'accessing'>
	resizable := aBoolean
    ]
]
PK
     �Mh@݉��S  S  	  Series.stUT	 dqXO��XOux �  �  "======================================================================
|
|   GNUPlot bindings style classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation; either version 2, or (at your option)
| any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but
| WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
| or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
| for more details.
| 
| You should have received a copy of the GNU General Public License
| along with GNU Smalltalk; see the file COPYING.  If not, write to the
| Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
| 02110-1301, USA.  
|
 ======================================================================"

"The GPSeriesStyle class is Copyright (c) 2007 Igor Stasenko
 and licensed under the X11 license.

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the `Software'), to deal in the Software without
    restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following
    conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE."

GPRectangleStyle subclass: GPSeriesStyle [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to customize the appearance of a plotted
function or data set.'>

    | x2 y2 title |
    
    initialize [
	<category: 'initialization'>
	super initialize.
	x2 := y2 := false
    ]

    y2 [
	<category: 'axes'>
	^y2
    ]

    y2: aBoolean [
	<category: 'axes'>
	y2 := aBoolean
    ]

    x2 [
	<category: 'axes'>
	^x2
    ]

    x2: aBoolean [
	<category: 'axes'>
	x2 := aBoolean
    ]

    fillStyle [
        <category: 'styles'>
        ^params at: #fillstyle ifAbsent: [ #empty ]
    ]

    notitle [
	"The line title and sample can be omitted from the key by using the keyword notitle"

	<category: 'title'>
	title := 'notitle'
    ]

    pointSize: aParam [
	"You may also scale the line width and point size for a plot by using <line width> and <point size>,
	 which are specified relative to the default values for each terminal. The pointsize may also be altered
	 globally � see set pointsize (p. 111) for details. But note that both <point size> as set here and
	 as set by set pointsize multiply the default point size � their effects are not cumulative. That is, set
	 pointsize 2; plot x w p ps 3 will use points three times default size, not six.
	 
	 It is also possible to specify pointsize variable either as part of a line style or for an individual plot.
	 In this case one extra column of input is required, i.e. 3 columns for a 2D plot and 4 columns for a 3D
	 splot. The size of each individual point is determined by multiplying the global pointsize by the value
	 read from the data file."

	<category: 'styles'>
	params at: #pointsize put: aParam
    ]

    pointType: aNumber [
	"If you wish to choose the line or point type for a single plot, <line type> and <point type> may be
	 specified. These are positive integer constants (or expressions) that specify the line type and point type
	 to be used for the plot."

	<category: 'styles'>
	params at: #pointtype put: aNumber
    ]

    axes [
	| axes |
	axes := 'axes x1y1' copy.
	self x2 ifTrue: [ axes at: 7 put: $2 ].
	self y2 ifTrue: [ axes at: 9 put: $2 ].
	^axes
    ]

    titleFor: aSeries [
	title notNil ifTrue: [ ^title ].
	^aSeries defaultTitle
	    ifNil: [ 'notitle' ]
	    ifNotNil: [ :defaultTitle | 'title ', defaultTitle printString ]
    ]

    displayOn: aStream [
	self displayOn: aStream for: nil
    ]

    displayOn: aStream for: aSeries [
	"#axes #title #with comes first, then rest"

	<category: 'converting'>
	(self x2 or: [ self y2 ])
	    ifTrue: [ aStream space; nextPutAll: self axes ].
	(title notNil or: [ aSeries notNil ])
	    ifTrue: [ aStream space; nextPutAll: (self titleFor: aSeries) ].
	super displayOn: aStream
    ]

    title: aTitle [
	"A line title for each function and data set appears in the key, accompanied by a sample of the line and/or
	 symbol used to represent it.
	 
	 If key autotitles is set (which is the default) and neither title nor notitle are specified the line title is
	 the function name or the file name as it appears on the plot command. If it is a file name, any datafile
	 modifiers specified will be included in the default title.
	 "

	<category: 'title'>
	"Using printString, i.e. single quotes, to prevent backslash conversion"
	title := 'title ', aTitle printString
    ]
]

Object subclass: GPSeriesGroup [
    <category: 'GNUPlot'>
    <comment: 'I am used internally to track the series that have already
been plotted in a group.'>

    | id barWidth barOffset dataOffset |
    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [ self id = anObject id ]
    ]

    hash [
	<category: 'basic'>
	^id hash
    ]

    id [
	<category: 'accessing'>
	id isNil ifTrue: [ id := 0 ].
	^id
    ]

    id: anInteger [
	<category: 'accessing'>
	id := anInteger
    ]

    barWidth [
	<category: 'accessing'>
	barWidth isNil ifTrue: [ barWidth := 0.5 ].
	^barWidth
    ]

    barWidth: aNumber [
	<category: 'accessing'>
	barWidth := aNumber
    ]

    barOffset [
	<category: 'accessing'>
	barOffset isNil ifTrue: [ barOffset := 0 ].
	^barOffset
    ]

    barOffset: aNumber [
	<category: 'accessing'>
	barOffset := aNumber
    ]

    dataOffset [
	<category: 'accessing'>
	^dataOffset
    ]

    stackData: aColumn [
	<category: 'accessing'>
	dataOffset := dataOffset isNil
	    ifTrue: [ aColumn ]
	    ifFalse: [ dataOffset + aColumn ]
    ]
]

GPContainer subclass: GPSeries [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define a plotted function or data set.'>

    GPSeries class >> defaultStyleClass [
	^GPSeriesStyle
    ]

    addTo: aGPPlot [
	<category: 'private - double dispatch'>
	aGPPlot addSeries: self
    ]

    defaultTitle [
	<category: 'dwim'>
	self subclassResponsibility
    ]

    group [
	<category: 'accessing'>
	^0
    ]

    group: anInteger [
	<category: 'accessing'>
	"Do nothing.  Grouping would not affect the way most data
	 series are drawn."
    ]

    printDataOn: aStream [
	<category: 'printing'>
    ]

    displayOn: aStream [
	<category: 'printing'>
	| group |
	group := GPSeriesGroup new id: self group; yourself.
	self displayOn: aStream group: group.
    ]

    displayOn: aStream group: aGroup [
	<category: 'printing'>
	self displayStyleOn: aStream group: aGroup
    ]

    displayStyleOn: aStream group: aGroup [
	| theParameters |
	theParameters := style ifNil: [ self class defaultStyle ].
	theParameters displayOn: aStream for: self
    ]

    displayPrologOn: aStream into: defs [
	super displayOn: aStream.
    ]

    xCoordinateSystem [
	<category: 'printing'>
	^self style x2 ifTrue: [ 'second' ] ifFalse: [ '' ]
    ]

    yCoordinateSystem [
	<category: 'printing'>
	self style y2 == self style x2 ifTrue: [ ^'' ].
	^self style y2 ifTrue: [ 'second' ] ifFalse: [ 'first']
    ]
]


GPSeries subclass: GPFunctionSeries [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define a plotted function.'>

    | expression range |
    GPFunctionSeries class >> on: expr [
	<category: 'instance creation'>
	^self new expression: expr
    ]

    defaultTitle [
	^String streamContents: [ :str | expression displayAsOperandOn: str ]
    ]

    expression [
	<category: 'accessing'>
	^expression
    ]

    expression: expr [
	<category: 'private - initialization'>
	expression := expr asGPExpression
    ]

    from: a to: b [
	<category: 'accessing'>
	range := { a. b }
    ]

    from [
        <category: 'accessing'>
	^range ifNotNil: [ :r | r first ]
    ]

    to [
        <category: 'accessing'>
	^range ifNotNil: [ :r | r second ]
    ]

    displayOn: aStream group: aGroup [
        <category: 'printing'>
	range isNil ifFalse: [
	    aStream
		nextPut: $[;
		display: range first;
		nextPut: $:;
		display: range second;
		nextPut: $];
		space ].
	expression displayOn: aStream.
	super displayOn: aStream group: aGroup
    ]

    displayPrologOn: aStream into: defs [
	super displayPrologOn: aStream into: defs.
	expression displayPrologOn: aStream into: defs
    ]
]


GPSeriesStyle subclass: GPDataSeriesStyle [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to customize the processing of
a data set before plotting, or its appearance.'>

    smooth: aSymbol [
	"aSymbol is any of #unique, #frequency, #csplines, #bezier, #sbezier"
	
	<category: 'styles'>
	params at: #smooth put: aSymbol asString
    ]
]

GPSeries subclass: GPDataSeries [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define a plotted data set.'>

    | columns dataSource graphType ticColumns |
    GPDataSeries class >> defaultStyleClass [
	^GPDataSeriesStyle
    ]

    GPDataSeries class >> on: aDataSource [
	<category: 'instance creation'>
	^self new dataSource: aDataSource asGPDataSource
    ]

    columns [
	<category: 'accessing'>
	columns ifNil: [ ^self defaultColumns ].
	^columns
    ]

    columns: anArray [
	<category: 'private - initialization'>
	columns := anArray
    ]

    dataSource [
	<category: 'accessing'>
	^dataSource
    ]

    dataSource: aDataSource [
	<category: 'private - initialization'>
	dataSource := aDataSource
    ]

    defaultColumns [
	self subclassResponsibility
    ]

    defaultTitle [
	^dataSource defaultTitle
    ]

    graphType: aString [
	<category: 'private - initialization'>
	graphType := aString
    ]

    displayOn: aStream group: aGroup [
	self dataSource displayOn: aStream.
	aStream nextPutAll: ' using '.
	self displayColumnsOn: aStream group: aGroup.
	self displayTicLabelsOn: aStream group: aGroup.
	super displayOn: aStream group: aGroup.
    ]

    displayStyleOn: aStream group: aGroup [
	graphType isNil ifFalse: [
	    aStream nextPutAll: ' with '; nextPutAll: graphType; space ].
        super displayStyleOn: aStream group: aGroup
    ]

    displayColumnsOn: aStream group: aGroup [
	self columns
	    do: [ :each | each displayOn: aStream ]
	    separatedBy: [ aStream nextPut: $: ].
    ]

    displayTicLabelsOn: aStream group: aGroup [
	"Add xticlabels etc. fake columns."
	ticColumns isNil ifFalse: [
	    ticColumns keysAndValuesDo: [ :k :v |
		aStream
		    nextPut: $:;
		    nextPutAll: k;
		    nextPut: $(;
		    display: v;
		    nextPut: $) ] ].
    ]

    printDataOn: aStream [
	dataSource printDataOn: aStream.
    ]

    displayPrologOn: aStream into: defs [
	super displayPrologOn: aStream into: defs.
	columns isNil ifTrue: [ ^self ].
	columns do: [ :each | each displayPrologOn: aStream into: defs ]
    ]

    ticColumns [
	^ticColumns ifNil: [ ticColumns := LookupTable new ]
    ]

    xTicColumn [
	^self ticColumns at: 'xtic' ifAbsent: [ nil ]
    ]

    xTicColumn: column [
	^column isNil
	    ifTrue: [ self ticColumns removeKey: 'xtic' ifAbsent: [ nil ] ]
	    ifFalse: [ self ticColumns at: 'xtic' put: column ]
    ]

    x2TicColumn [
	^self ticColumns at: 'x2tic' ifAbsent: [ nil ]
    ]

    x2TicColumn: column [
	^column isNil
	    ifTrue: [ self ticColumns removeKey: 'x2tic' ifAbsent: [ nil ] ]
	    ifFalse: [ self ticColumns at: 'x2tic' put: column ]
    ]

    yTicColumn [
	^self ticColumns at: 'ytic' ifAbsent: [ nil ]
    ]

    yTicColumn: column [
	^column isNil
	    ifTrue: [ self ticColumns removeKey: 'ytic' ifAbsent: [ nil ] ]
	    ifFalse: [ self ticColumns at: 'ytic' put: column ]
    ]

    y2TicColumn [
	^self ticColumns at: 'y2tic' ifAbsent: [ nil ]
    ]

    y2TicColumn: column [
	^column isNil
	    ifTrue: [ self ticColumns removeKey: 'y2tic' ifAbsent: [ nil ] ]
	    ifFalse: [ self ticColumns at: 'y2tic' put: column ]
    ]

    "zTicColumn [
	^self ticColumns at: 'ztic' ifAbsent: [ nil ]
    ]

    zTicColumn: column [
	^column isNil
	    ifTrue: [ self ticColumns removeKey: 'ztic' ifAbsent: [ nil ] ]
	    ifFalse: [ self ticColumns at: 'ztic' put: column ]
    ]"
]

GPDataSeries subclass: GPGroupSeries [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define plotted data sets when
more series can be grouped together (e.g. in stacked bars).'>

    | group |
    group [
	<category: 'accessing'>
	group isNil ifTrue: [ group := 0 ].
	^group
    ]

    group: anInteger [
	<category: 'accessing'>
	group := anInteger.
    ]
]


GPObject subclass: GPAxis [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to customize the appearance of a plotted
axis.'>

    | name range logScale mirrorTics outwardTics ticRange ticSpacing ticFormat
      ticSubdivision majorGrid minorGrid tics style label labelStyle |

    name: aString [
	<category: 'private - initialization'>
	name := aString
    ]

    withName: aString [
	<category: 'private - initialization'>
	^name = aString
	    ifTrue: [ self ]
	    ifFalse: [ self copy name: aString ]
    ]

    from: a to: b [
	<category: 'accessing'>
	range := { a. b }
    ]

    from [
        <category: 'accessing'>
	^range ifNotNil: [ :r | r first ]
    ]

    from: a [
	<category: 'accessing'>
	range := { a. self to }
    ]

    to [
        <category: 'accessing'>
	^range ifNotNil: [ :r | r second ]
    ]

    to: b [
	<category: 'accessing'>
	range := { self from. b }
    ]

    ticAt: value put: string [
        <category: 'accessing'>
	tics isNil ifTrue: [ tics := OrderedCollection new ].
	tics add: value asGPExpression->string
    ]

    ticFrom: a to: b [
        <category: 'accessing'>
        ticRange := { a. b }
    ]

    ticFrom [
        <category: 'accessing'>
        ^ticRange ifNotNil: [ :r | r first ]
    ]

    ticTo [
        <category: 'accessing'>
        ^ticRange ifNotNil: [ :r | r second ]
    ]

    ticSpacing [
        <category: 'accessing'>
        ^ticSpacing
    ]

    ticSpacing: aNumber [
        <category: 'accessing'>
        ticSpacing := aNumber
    ]

    label [
        <category: 'accessing'>
        ^label
    ]

    label: aString [
        <category: 'accessing'>
        label := aString
    ]

    labelStyle [
        <category: 'accessing'>
        ^labelStyle
    ]

    labelStyle: aString [
        <category: 'accessing'>
        labelStyle := aString
    ]

    ticFormat [
        <category: 'accessing'>
        ^ticFormat
    ]

    ticFormat: aBoolean [
        <category: 'accessing'>
        ticFormat := aBoolean
    ]

    ticSubdivision [
        <category: 'accessing'>
        ^ticSubdivision
    ]

    ticSubdivision: aNumber [
        <category: 'accessing'>
        ticSubdivision := aNumber
    ]

    majorGrid [
        <category: 'accessing'>
        ^majorGrid
    ]

    majorGrid: aLineStyle [
        <category: 'accessing'>
        aLineStyle == true ifTrue: [ majorGrid := GPLineStyle new. ^self ].
        aLineStyle == false ifTrue: [ majorGrid := nil. ^self ].
        majorGrid := aLineStyle
    ]

    minorGrid [
        <category: 'accessing'>
        ^minorGrid
    ]

    minorGrid: aLineStyle [
        <category: 'accessing'>
        aLineStyle == true ifTrue: [ minorGrid := GPLineStyle new. ^self ].
        aLineStyle == false ifTrue: [ minorGrid := nil. ^self ].
        minorGrid := aLineStyle
    ]

    style [
        <category: 'accessing'>
        ^style
    ]

    style: aLineStyle [
        <category: 'accessing'>
        aLineStyle == true ifTrue: [ style := GPLineStyle new. ^self ].
        aLineStyle == false ifTrue: [ style := nil. ^self ].
        style := aLineStyle
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	logScale := false.
	mirrorTics := true.
	outwardTics := false.
    ]

    logScale [
        <category: 'accessing'>
        ^logScale
    ]

    logScale: aBoolean [
        <category: 'accessing'>
        logScale := aBoolean
    ]

    mirrorTics [
        <category: 'accessing'>
        ^mirrorTics
    ]

    mirrorTics: aBoolean [
        <category: 'accessing'>
        mirrorTics := aBoolean
    ]

    outwardTics [
        <category: 'accessing'>
        ^outwardTics
    ]

    outwardTics: aBoolean [
        <category: 'accessing'>
        outwardTics := aBoolean
    ]

    displayGridOn: aStream [
        <category: 'printing'>
	| majGrid |
        aStream
            nextPutAll: 'set grid '.
	minorGrid isNil ifFalse: [ aStream nextPut: $m ].
	aStream
            nextPutAll: name;
            nextPutAll: 'tics'.

	majGrid := (majorGrid isNil and: [ minorGrid notNil ])
	    ifTrue: [ minorGrid ]
	    ifFalse: [ majorGrid ].

	majGrid notNil
	    ifTrue: [
		majGrid isDefault
		    ifTrue: [ aStream nextPutAll: ' ls 0' ]
		    ifFalse: [ aStream display: majGrid ] ].

	minorGrid isNil ifTrue: [ ^self ].
	aStream nextPut: $,.
	minorGrid isDefault
	    ifTrue: [ aStream nextPutAll: ' ls 0' ]
	    ifFalse: [ aStream display: minorGrid ].
    ]

    displayRangeOn: aStream [
        <category: 'printing'>
        aStream
            nextPutAll: 'set ';
            nextPutAll: name;
            nextPutAll: 'range [';
            display: (range first ifNil: [ '*' ]);
            nextPut: $:;
            display: (range second ifNil: [ '*' ]);
            nextPut: $];
            nl
    ]

    displayTicsOn: aStream [
        <category: 'printing'>
	| spacing |
        aStream
            nextPutAll: 'set ';
            nextPutAll: name;
            nextPutAll: 'tics'.

	self mirrorTics ifFalse: [ aStream nextPutAll: ' nomirror' ].
	self outwardTics ifTrue: [ aStream nextPutAll: ' out' ].
	self displayTicRangeOn: aStream.
        aStream nl
    ]

    displayTicRangeOn: aStream [
        <category: 'printing'>
	| spacing |
	ticRange isNil
	    ifTrue: [
		(ticSpacing isNil and: [ ticSpacing > 0 ])
		    ifFalse: [ aStream space; display: ticSpacing ] ]
	    ifFalse: [
	        spacing := ticSpacing.
		spacing = 0 ifTrue: [ spacing := self ticTo - self ticFrom ].
		spacing isNil ifTrue: [ spacing := (self ticTo - self ticFrom) / 4.0 ].
		aStream
		     space; display: self ticFrom;
		     nextPut: $,; display: spacing;
		     nextPut: $,; display: self ticTo ].
    ]

    displayUserTicsOn: aStream [
        <category: 'printing'>
        aStream
            nextPutAll: 'set ';
            nextPutAll: name;
            nextPutAll: 'tics add ('.
	tics
	    do: [ :each |
	        aStream
		    print: each value displayString; 
		    space;
		    display: each key ]
	    separatedBy: [ aStream nextPut: $, ].
	aStream nextPut: $); nl
    ]

    displayLabelOn: aStream [
        <category: 'printing'>
        aStream
            nextPutAll: 'set ';
            nextPutAll: name;
            nextPutAll: 'label ';
	    print: label displayString.

	self labelStyle isNil ifFalse: [
	    aStream display: self labelStyle ].
	aStream nl
    ]

    displayOn: aStream [
        <category: 'printing'>
	| spacing |
        range isNil ifFalse: [
            self displayRangeOn: aStream ].
	(ticRange notNil or: [ ticSpacing notNil
		or: [ self mirrorTics not or: [ self outwardTics ]]])
	    ifTrue: [ self displayTicsOn: aStream ].
	tics notNil
	    ifTrue: [ self displayUserTicsOn: aStream ].
	(minorGrid notNil or: [ majorGrid notNil ])
	    ifTrue: [ self displayGridOn: aStream ].
	label notNil
	    ifTrue: [ self displayLabelOn: aStream ].

	self ticFormat isNil ifFalse: [
            aStream
                nextPutAll: 'set format ';
                nextPutAll: name;
                space;
                print: self ticFormat;
                nl ].

	self logScale ifTrue: [
            aStream
                nextPutAll: 'set logscale ';
                nextPutAll: name;
                nl ].

	self style isNil ifFalse: [
            aStream
                nextPutAll: 'set ';
                nextPutAll: name;
                nextPutAll: 'zeroaxis';
                display: self style;
                nl ].

	self ticSubdivision isNil ifFalse: [
            aStream
                nextPutAll: 'set m';
                nextPutAll: name;
                nextPutAll: 'tics ';
                display: self ticSubdivision;
                nl ].
    ]
]
PK
     �[h@�Q�6  6    package.xmlUT	 ��XO��XOux �  �  <package>
  <name>GNUPlot</name>
  <namespace>GNUPlot</namespace>

  <filein>Base.st</filein>
  <filein>Objects.st</filein>
  <filein>Series.st</filein>
  <filein>Terminals.st</filein>
  <filein>Expressions.st</filein>
  <filein>2D.st</filein>
  <filein>Examples.st</filein>
  <file>ChangeLog</file>
</package>PK
     �Mh@�jo^8  ^8    Base.stUT	 dqXO��XOux �  �  "======================================================================
|
|   GNUPlot bindings base classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation; either version 2, or (at your option)
| any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but
| WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
| or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
| for more details.
| 
| You should have received a copy of the GNU General Public License
| along with GNU Smalltalk; see the file COPYING.  If not, write to the
| Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
| 02110-1301, USA.  
|
 ======================================================================"

Object subclass: GPObject [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define aspects of a plot.'>

    GPObject class >> new [
	<category: 'instance creation'>
        ^super new initialize
    ]

    asString [
	<category: 'printing'>
	^self displayString
    ]

    initialize [
	<category: 'private - initialization'>
    ]

    displayOn: aStream [
	<category: 'printing'>
    ]

    printOn: aStream [
	<category: 'printing'>
	self class printOn: aStream.
	aStream nextPut: $(.
	self displayOn: aStream.
	aStream nextPut: $)
    ]
]

GPObject subclass: GNUPlot [
    | plots terminal cols |
    
    <category: 'GNUPlot'>
    <comment: 'I am the main class to interact with GNU plot.
	See GNUPlotExamples for usage examples'>

    CommandPath := nil.

    GNUPlot class >> commandPath [
	<category: 'executing'>
	^CommandPath ifNil: [ self defaultCommandPath ]
    ]

    GNUPlot class >> commandPath: aString [
	<category: 'executing'>
	CommandPath := aString
    ]

    GNUPlot class >> defaultCommandPath [
	<category: 'executing'>
	^(Smalltalk hostSystem indexOfSubCollection: '-mingw' ifAbsent: [ 0 ]) > 0
	    ifTrue: [ 'pgnuplot.exe -' ]
	    ifFalse: [ 'gnuplot' ]
    ]

    GNUPlot class >> newPipe: dir [
	<category: 'executing'>
	^FileStream popen: self commandPath dir: dir
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	plots := OrderedCollection new
    ]

    output: aFileName [
	<category: 'accessing'>
	self terminal isInteractive ifTrue: [ self terminal: GPPngTerminal new ].
	self terminal output: aFileName
    ]

    execute [
	^self terminal display: self
    ]

    cols [
	^cols
    ]

    cols: anInteger [
	cols := anInteger
    ]

    add: aPlot [
	<category: 'accessing'>
	^plots add: aPlot
    ]
	
    plot [
	"Adding a plot command and returning GPPlot instance ready for accepting parameters"

	<category: 'accessing'>
	plots size > 1 ifTrue: [ self error: 'cannot use #plot in multiplot' ].
	plots size = 1 ifTrue: [ ^plots first ].
	^self add: GPPlot new
    ]

    multiplotLayout [
	| theCols theRows |
	<category: 'converting'>
	theCols := cols isNil ifTrue: [plots size sqrt ceiling] ifFalse: [cols].
	^theCols @ (plots size / theCols) ceiling
    ]

    displayOn: aStream [
	| layout row col thisRowCols |
	<category: 'converting'>
	plots size = 0 ifTrue: [ ^self ].

        aStream nextPutAll: 'reset'; nl.
	(plots size = 1 or: [ self terminal handlesMultiplot ]) ifTrue: [
	    plots do: [ :each | each displayOn: aStream ].
	    ^self ].

	layout := self multiplotLayout.
	aStream
	    nextPutAll: 'set size %1, %2' % {
		layout x asFloat / (layout x max: layout y).
		layout y asFloat / (layout x max: layout y) };
	    nl.

	row := col := 0.
	thisRowCols := layout x.
	aStream nextPutAll: 'set multiplot'; nl.
	plots keysAndValuesDo: 
	    [:i :each | 
            aStream
		nextPutAll: 'reset'; nl;
		nextPutAll: 'set size %1, %2' % { 1.0/layout x. 1.0/layout y } ; nl;
		nextPutAll: 'set origin %1, %2' % {
			(col + ((layout x - thisRowCols) / 2.0)) / layout x.
			(layout y - 1.0 - row) / layout y }; nl;
		display: each;
		nl.

	    col := col + 1.
	    col = layout x ifTrue: [
		col := 0.
		row := row + 1.
		thisRowCols := (i + layout x min: plots size) - i]].
	aStream nextPutAll: 'unset multiplot'; nl
    ]

    terminal [
	<category: 'accessing'>
	^terminal ifNil: [ terminal := GPInteractiveTerminal new ].
    ]

    terminal: aGPTerminal [
	<category: 'accessing'>
	terminal := aGPTerminal
    ]
]


GPObject subclass: GPStyle [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to customize the appearance of a plot
element.'>

    | params |

    initialize [
	<category: 'initialize-release'>
	super initialize.
	params := Dictionary new
    ]

    isDefault [
	^params isEmpty
    ]

    displayOn: aStream [
	<category: 'printing'>
	params keysAndValuesDo: 
		[:key :val | 
		aStream
		    space; nextPutAll: key;
		    space.
		val isSymbol
		    ifTrue: [aStream nextPutAll: val]
		    ifFalse: [aStream print: val]]
    ]
]


GPObject subclass: GPDataSource [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define the source of a plotted data set.'>

    at: anObject [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    defaultTitle [
	self subclassResponsibility
    ]

    printDataOn: aStream [
	<category: 'printing'>
	"Do nothing by default"
    ]

    asGPDataSource [
	^self
    ]
]

GPDataSource subclass: GPFileDataSource [
    <category: 'GNUPlot'>
    <comment: 'My instances allow to use a file as the source of a plot.'>

    | fileName index |
    GPFileDataSource class >> on: aString [
	<category: 'instance creation'>
	^self new fileName: aString
    ]

    at: anInteger [
	<category: 'accessing'>
	index isNil ifFalse: [ self error: 'data set already chosen' ].
	^self copy index: anInteger - 1; yourself
    ]

    defaultTitle [
	^fileName
    ]

    index: anInteger [
	<category: 'private'>
	index := anInteger
    ]

    fileName [
	<category: 'accessing'>
	^fileName
    ]

    fileName: aString [
	<category: 'private - initialization'>
	fileName := aString
    ]

    displayOn: aStream [
	fileName printOn: aStream
	index isNil
	    ifFalse: [ aStream nextPutAll: ' index '; display: index ]
    ]
]

File extend [
    asGPDataSource [
	^GNUPlot.GPDataSource on: self name
    ]
]

GPDataSource subclass: GPSmalltalkDataSource [
    <category: 'GNUPlot'>
    <comment: 'My instances allow to use an object, typically a collection,
as the source of a plot.'>

    | data |
    GPSmalltalkDataSource class >> on: aCollection [
	<category: 'instance creation'>
	^self new
	    add: aCollection; yourself
    ]

    initialize [
	<category: 'private - initialization'>
	super initialize.
	data := OrderedCollection new
    ]

    at: anInteger [
	<category: 'accessing'>
	^self class on: (data at: anInteger)
    ]

    add: aCollection [
	<category: 'private - initialization'>
	data add: aCollection
    ]

    defaultTitle [
	^nil
    ]

    displayOn: aStream [
	'''-''' displayOn: aStream
    ]

    printData: anObject on: aStream level: n [
        anObject isNumber ifTrue: [anObject printOn: aStream. ^self].

        anObject isString ifTrue: [
	    aStream nextPut: $".
	    aStream display: (anObject copyReplaceAll: '"' with: '\"').
	    aStream nextPut: $".
	    ^self ].

	anObject
	    do: [:each |
		self printData: each on: aStream level: n + 1.
		n = 3 ifTrue: [ aStream space ] ifFalse: [ aStream nl ] ]
    ]

    printDataOn: aStream [
	self printData: data on: aStream level: 1.
        aStream nextPut: $e; nl.
    ]

    Object >> asGPDataSource [
	^GNUPlot.GPSmalltalkDataSource on: self
    ]
]


GPObject subclass: GPElement [
    <category: 'GNUPlot'>
    <comment: 'My instances are used to define an element of a drawing,
whose appearance can also be customized.'>

    | style |

    GPElement class [
	| defaultStyle |
	defaultStyleClass [
	    self subclassResponsibility
	]

	defaultStyle [
            ^defaultStyle ifNil: [ defaultStyle := self defaultStyleClass new ]
	]
    ]

    style [
        <category: 'accessing'>
        ^style ifNil: [ style := self class defaultStyle copy ].
    ]

    style: anObject [
        <category: 'accessing'>
        style := anObject.
    ]

    addTo: aGPPlot [
	<category: 'private - double dispatch'>
	self subclassResponsibility
    ]
]


GPElement subclass: GPContainer [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define objects that establish a
coordinate system.'>

    | objects |
    initialize [
	<category: 'private - initialization'>
	super initialize.
	objects := OrderedCollection new.
    ]

    addObject: anElement [
        <category: 'private - double dispatch'>
        ^objects add: anElement
    ]

    addSeries: aSeries [
        <category: 'private - double dispatch'>
        self shouldNotImplement
    ]

    add: aGPObject [
        <category: 'building'>
        ^aGPObject addTo: self
    ]

    xCoordinateSystem [
	<category: 'printing'>
	self subclassResponsibility
    ]

    yCoordinateSystem [
	<category: 'printing'>
	^''
    ]

    displayOn: aStream [
        <category: 'printing'>
        objects do: [:each |
	    each
		displayOn: aStream
		pointDisplay: [ :str :p |
		    str
			nextPutAll: self xCoordinateSystem;
			space;
			print: p x;
			nextPut: $,;
			nextPutAll: self yCoordinateSystem;
			space;
			print: p y ].
	    aStream nl]
    ]
]


GPContainer subclass: GPAbstractPlot [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a single ''plot'' command.'>

    | series |

    axes [
        <category: 'printing'>
	self subclassResponsibility
    ]

    initialize [
	<category: 'private - initialization'>
	super initialize.
	series := OrderedCollection new
    ]

    addSeries: aSeries [
        <category: 'private - double dispatch'>
        ^series add: aSeries
    ]

    function: exprBlock [
        <category: 'building'>
        self subclassResponsibility
    ]

    function: exprBlock with: aBlock [
        <category: 'building'>
        | series |
        series := self function: exprBlock.
        aBlock value: series.
        ^series
    ]

    displayPrologOn: aStream [
	<category: 'display'>
	| defs |
        style isNil ifFalse: [ style displayOn: aStream ].
        self axes do: [ :d | d isNil ifFalse: [ aStream display: d; nl ] ].

	defs := Set new.
        series do: [:d | d displayPrologOn: aStream into: defs ].
    ]

    groupedSeries [
	"Assign groups to series that do not have one, and return a
	 Dictionary of OrderedCollections, holding the series according
	 to their #group."
	<category: 'private'>

	| groupedSeries maxGroup |
	maxGroup := series inject: 0 into: [ :old :each |
	    each group = 0 ifTrue: [ each group: old + 1 ].
	    each group ].

	groupedSeries := LookupTable new.
	series do: [:d |
	    (groupedSeries
		at: (self newGroup: d group of: maxGroup)
		ifAbsentPut: [ OrderedCollection new ])
		    add: d ].

	^groupedSeries
    ]

    newGroup: anInteger of: maxGroup [
	<category: 'private - factory'>
	^GPSeriesGroup new
	    id: anInteger;
	    yourself
    ]

    displaySeriesOn: aStream [
        <category: 'printing'>
	| groupedSeries first |
	groupedSeries := self groupedSeries.
	first := true.
	groupedSeries
	    keysAndValuesDo: [:group :list |
	        list do: [:d |
		    first ifFalse: [aStream nextPutAll: ', '].
		    first := false.
		    d displayOn: aStream group: group]].

        aStream nl.
	groupedSeries do: [:list |
	    list do: [:d | d printDataOn: aStream]]
    ]

    displayOn: aStream [
        <category: 'printing'>
        self displayPrologOn: aStream.
	super displayOn: aStream.
        self displaySeriesOn: aStream.
    ]

    xCoordinateSystem [
	<category: 'printing'>
	^'screen'
    ]
]


GPObject subclass: GPTerminal [
    
    <category: 'GNUPlot'>
    <comment: 'My instances describe an abstract GNU Plot terminal
(corresponding to the ''set terminal'' command).'>

    displayOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: 'set terminal ';
	    nextPutAll: self name;
	    nextPut: Character space.
	self printOptionsOn: aStream.
	aStream nl.
    ]

    printOptionsOn: aStream [
	<category: 'printing'>
    ]

    name [
	"Return a string identifying terminal type"

	<category: 'printing'>
	self subclassResponsibility
    ]

    display: aGNUPlot [
	<category: 'executing'>
	self subclassResponsibility
    ]

    display: aGNUPlot on: aStream [
	<category: 'executing'>
	^aStream
	    display: self; nl;
	    display: aGNUPlot;
	    yourself
    ]

    handlesMultiplot [
	<category: 'testing'>
	^false
    ]

    isInteractive [
	<category: 'testing'>
	self subclassResponsibility
    ]
]


GPTerminal subclass: GPInteractiveTerminal [
    
    <category: 'GNUPlot'>
    <comment: 'My instances describe an abstract GNU Plot terminal
that plots data on the display.'>

    display: aGNUPlot [
	<category: 'executing'>
	| pipe |
	pipe := GNUPlot newPipe: FileStream write.
	self display: aGNUPlot on: pipe.
	pipe close
    ]

    displayOn: aStream [
	<category: 'printing'>
	| options |
	options := String streamContents: [ :s | self printOptionsOn: s ].
	options isEmpty ifTrue: [ ^self ].
	aStream nextPutAll: 'set macros'; nl.
	super displayOn: aStream
    ]

    name [
	"Return a string identifying terminal type"

	<category: 'printing'>
	^'@GNUTERM'
    ]

    isInteractive [
	<category: 'testing'>
	^true
    ]
]


GPTerminal subclass: GPFileTerminal [
    
    <category: 'GNUPlot'>
    <comment: 'My instances describe an abstract GNU Plot terminal
that saves plots to a file.'>

    | output |

    output [
	<category: 'accessing'>
	^output
    ]

    output: aFileName [
	<category: 'accessing'>
	output := aFileName
    ]

    displayOn: aStream [
	<category: 'printing'>
	super displayOn: aStream.
	aStream
	    nextPutAll: 'set output ';
	    print: (self output ifNil: [ '-' ])
    ]

    display: aGNUPlot [
	<category: 'executing'>
	| pipe |
	pipe := GNUPlot newPipe: FileStream readWrite.
	self display: aGNUPlot on: pipe.
	^pipe shutdown; contents
    ]

    isInteractive [
	<category: 'testing'>
	^false
    ]
]
PK
     �Mh@AÕ  �    Examples.stUT	 dqXO��XOux �  �  "======================================================================
|
|   GNUPlot bindings, examples
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation; either version 2, or (at your option)
| any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but
| WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
| or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
| for more details.
| 
| You should have received a copy of the GNU General Public License
| along with GNU Smalltalk; see the file COPYING.  If not, write to the
| Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
| 02110-1301, USA.  
|
 ======================================================================"

GPObject subclass: GNUPlotExamples [
    
    <category: 'GNUPlot-Tests and examples'>
    <comment: 'See class side for methods with examples'>

    GNUPlotExamples class >> newPngTerminal [
	^GPPngTerminal new
	    size: 300 @ 300;
	    "colors: (GPTerminalColors new borders: Color darkGray); FIXME"
	    yourself
    ]

    GNUPlotExamples class >> example1 [
	| p |
	p := GNUPlot new.
	p plot
	    lines: #(1 2 3 4 5)
	    with: [:series | series style title: 'Title' ].
	^p asString
    ]

    GNUPlotExamples class >> example2 [
	^self example2On: nil
    ]

    GNUPlotExamples class >> example2On: file [
	| p |
	p := GNUPlot new.
	file isNil ifFalse: [
	    p terminal: self newPngTerminal.
	    p output: file ].

	p plot
	    lines: #(1 5 2 8 3)
	    with: [:series | series style title: 'Title' ].
	Transcript display: p; nl.
	p execute
    ]

    GNUPlotExamples class >> fullPlot [
	^self fullPlotOn: nil
    ]

    GNUPlotExamples class >> fullPlotOn: file [
	| p |
	p := GNUPlot new.
	file isNil ifFalse: [
	    p terminal: self newPngTerminal.
	    p output: file ].

	p plot
	    "first plot"
	    lines: #(1 5 2 8 3)
	    with: [:series | series style title: 'Zig-zag' ];

	    "second plot"
	    function: [ :x | x sin ];

	    "third plot, notice no title appears"
	    boxes: #(6 3 1 5 4);

	    bubbles: #((1.5 7 6)).

	Transcript display: p; nl.
	p execute
    ]

    GNUPlotExamples class >> twoPlots [
	^self twoPlotsOn: nil
    ]

    GNUPlotExamples class >> twoPlotsOn: file [
	| p |
	p := GNUPlot new.
	file isNil ifFalse: [
	    p terminal: self newPngTerminal.
	    p output: file ].

	p plot
	    lines: #(1 5 2 8 3)
	    with: [:series | series style title: 'Zig-zag' ];

	    "second plot"
	    function: [ :x | x sin ].

	Transcript display: p; nl.
	p execute
    ]

    GNUPlotExamples class >> logPlot [
	^self logPlotOn: nil
    ]

    GNUPlotExamples class >> logPlotOn: file [
	| p fit data |
	p := GNUPlot new.
	file isNil ifFalse: [
	    p terminal: self newPngTerminal.
	    p output: file ].

	p plot
	    function: [ :x | x raisedTo: 2 ];
	    function: [ :x | x raisedTo: 3 ];
	    function: [ :x | x exp ].

	p plot xAxis from: 1 to: 10; logScale: true.
	p plot yAxis from: 1 to: 1000; logScale: true.

	Transcript display: p; nl.
	p execute
    ]

    GNUPlotExamples class >> fit [
	^self fitOn: nil
    ]

    GNUPlotExamples class >> fitOn: file [
	| p fit data |
	p := GNUPlot new.
	file isNil ifFalse: [
	    p terminal: self newPngTerminal.
	    p output: file ].

	data := #((0.1 0.2) (1 2) (2 1) (3 3) (4 2) (4.9 3.8)).

	p plot
	    points: data with: [ :series |
		series x: '$1' y: '$2' ];
	    function: [ :x |
		x fit: data to: [ :a :b | a * x + b ] name: 'f' ].

	Transcript display: p; nl.
	p execute
    ]

    GNUPlotExamples class >> multiplot [
	^self multiplotOn: nil
    ]

    GNUPlotExamples class >> multiplotOn: file [
	| p plot |
	p := GNUPlot new.
	file isNil ifFalse: [
	    p terminal: self newPngTerminal.
	    p output: file ].

	(plot := GPPlot new)
	    lines: #(1 5 2 8 3)
	    with: [:series | series style title: 'Title' ].
	p add: plot; add: plot; add: plot.
	Transcript display: p; nl.
	p execute
    ]

    GNUPlotExamples class >> bars [
	^self barsOn: nil
    ]

    GNUPlotExamples class >> barsOn: file [
	| p plot data |
	p := GNUPlot new.
	file isNil ifFalse: [
	    p terminal: self newPngTerminal.
	    p output: file ].

	data := #((1 2 'a') (2 3 'b') (3 4 'c') (4 5 'd') (5 6 'e')).

	(plot := GPPlot new)
	    bars: data
	    with: [:series |
		series style fillStyle: #solid.
		series data: (GPColumnRef column: 1) ];

	    bars: data
	    with: [:series |
		series style fillStyle: #solid.
		series data: (GPColumnRef column: 2); xTicColumn: 3 ].

	plot xAxis ticSpacing: 0.
	plot xAxis from: -0.5 to: 4.5.
	plot yAxis from: 0.
	p add: plot.

	data := #((1 1 'a') (2 1 'b') (3 1 'c') (4 1 'd') (5 1 'e')).

	(plot := GPPlot new)
	    bars: data
	    with: [:series |
		series style fillStyle: #solid.
		series group: 1.
		series data: (GPColumnRef column: 1) ];

	    bars: data
	    with: [:series |
		series style fillStyle: #solid.
		series group: 1.
		series data: (GPColumnRef column: 2); xTicColumn: 3 ].

	plot xAxis ticSpacing: 0.
	plot xAxis from: -0.5 to: 4.5.
	plot yAxis from: 0.

	p add: plot.
	Transcript display: p; nl.
	p execute
    ]
]
PK
     �Mh@�%��.  �.  
  Objects.stUT	 dqXO��XOux �  �  "======================================================================
|
|   GNUPlot bindings, graphical objects
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify
| it under the terms of the GNU General Public License as published by
| the Free Software Foundation; either version 2, or (at your option)
| any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but
| WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
| or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
| for more details.
| 
| You should have received a copy of the GNU General Public License
| along with GNU Smalltalk; see the file COPYING.  If not, write to the
| Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
| 02110-1301, USA.  
|
 ======================================================================"

GPElement subclass: GPGraphicalObject [
    <category: 'GNUPlot'>
    <comment: 'My instance represent a pictorial element that can be added
to a graph.'>

    displayOn: aStream [
	<category: 'printing'>
	self
            displayOn: aStream
            pointDisplay: [ :str :p |
                str
                    print: p x;
                    nextPut: $,;
                    print: p y ]
    ]

    displayOn: aStream pointDisplay: aBlock [
	<category: 'printing'>
    ]

    addTo: aGPPlot [
        <category: 'private - double dispatch'>
        aGPPlot addObject: self
    ]
]


GPStyle subclass: GPLabelStyle [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to customize the appearance of a label
on a graph.'>

    | font rotate offset |

    font [
	<category: 'accessing'>
	^font
    ]

    font: aString [
	<category: 'accessing'>
	font := aString
    ]

    rotate [
	<category: 'accessing'>
	^rotate
    ]

    rotate: aNumber [
	<category: 'accessing'>
	rotate := aNumber
    ]

    offset [
	<category: 'accessing'>
	^offset
    ]

    offset: aPoint [
	<category: 'accessing'>
	offset := aPoint
    ]

    displayOn: aStream [
	<category: 'printing'>
	self font isNil ifFalse: [
	    aStream nextPutAll: ' font '; print: self font ].
	self rotate isNil ifFalse: [
	    aStream nextPutAll: ' rotate by '; print: self rotate ].
	self offset isNil ifFalse: [
	    aStream
		nextPutAll: ' offset ';
		print: self offset x;
		nextPut: $,
		print: self offset y ].
    ]
]

GPGraphicalObject subclass: GPLabel [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a label on a graph.'>

    | position align text |
    GPLabel class >> position: aPoint text: aString [
	<category: 'instance creation'>
	^self new
	    position: aPoint;
	    text: aString
    ]

    GPLabel class >> defaultStyleClass [
	<category: 'style'>
        ^GPLabelStyle
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	align := #left
    ]

    align [
	<category: 'accessing'>
	^align
    ]

    align: aSymbol [
	<category: 'accessing'>
	align := aSymbol
    ]

    position [
	<category: 'accessing'>
	^position
    ]

    position: aString [
	<category: 'accessing'>
	position := aString
    ]

    text [
	<category: 'accessing'>
	^text
    ]

    text: aString [
	<category: 'accessing'>
	text := aString
    ]

    displayOn: aStream pointDisplay: aBlock [
	<category: 'printing'>
	aStream
	    nextPutAll: 'set label ';
	    print: self text displayString;
	    nextPutAll: ' front at '.

	aBlock value: aStream value: self position.
	align isNil ifFalse: [ aStream space; nextPutAll: self align ].
	self style isNil ifFalse: [ self style displayOn: aStream ]
    ]
]


GPGraphicalObject subclass: GPBoundingBox [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define a rectangle drawn on a graph.'>

    | bbox |
    GPBoundingBox class >> origin: origin corner: corner [
	<category: 'instance creation'>
	^self new
	    boundingBox: (Rectangle origin: origin corner: corner)
    ]

    GPBoundingBox class >> origin: origin extent: extent [
	<category: 'instance creation'>
	^self new
	    boundingBox: (Rectangle origin: origin extent: extent)
    ]

    GPBoundingBox class >> left: l top: t right: r bottom: b [
	<category: 'instance creation'>
	^self new
	    boundingBox: (Rectangle left: l top: t right: r bottom: b)
    ]

    GPBoundingBox class >> boundingBox: aRectangle [
	<category: 'instance creation'>
	^self new
	    boundingBox: aRectangle
    ]

    boundingBox [
	<category: 'accessing'>
	^bbox
    ]

    boundingBox: aRectangle [
	<category: 'accessing'>
	bbox := aRectangle
    ]

    left [
	<category: 'accessing'>
	^bbox left
    ]

    top [
	<category: 'accessing'>
	^bbox top
    ]

    right [
	<category: 'accessing'>
	^bbox right
    ]

    bottom [
	<category: 'accessing'>
	^bbox bottom
    ]

    origin [
	<category: 'accessing'>
	^bbox origin
    ]

    corner [
	<category: 'accessing'>
	^bbox corner
    ]

    width [
	<category: 'accessing'>
	^bbox width
    ]

    height [
	<category: 'accessing'>
	^bbox height
    ]
]


GPStyle subclass: GPLineStyle [
    lineColor [
	^params at: #linecolor ifAbsent: [ nil ]
    ]

    lineColor: aColorSpec [
	"aColorSpec has one of the following forms:
	 rgbcolor 'colorname'
	 rgbcolor '#RRGGBB'
	 rgbcolor variable
	 palette frac <val> # <val> runs from 0 to 1
	 palette cb <value> # <val> lies within cbrange
	 palette z
	 
	 'rgb variable' requires an additional column in the using specifier, and is only available in 3D plotting
	 mode (splot). The extra column is interpreted as a 24-bit packed RGB triple. These are most easily
	 specified in a data file as hexidecimal values (see above).
	 
	 Example:
	 rgb(r,g,b) = 65536 * int(r) + 256 * int(g) + int(b)
	 splot 'data' using 1:2:3:(rgb($1,$2,$3)) with points lc rgb variable
	 
	 The color palette is a linear gradient of colors that smoothly maps a single numerical value onto a
	 particular color. Two such mappings are always in effect. palette frac maps a fractional value between
	 0 and 1 onto the full range of the color palette. palette cb maps the range of the color axis onto the
	 same palette. See set cbrange. See also set colorbox. You can use either of these
	 to select a constant color from the current palette.
	 'palette z' maps the z value of each plot segment or plot element into the cbrange mapping of the
	 palette. This allows smoothly-varying color along a 3d line or surface. This option applies only to 3D
	 plots (splot).
	 "

	<category: 'styles'>
	"FIXME"
	params at: #linecolor
	    put: aColorSpec "(aColorSpec isColor 
		    ifTrue: ['rgbcolor ''' , aColorSpec asHTMLColor , '''']
		    ifFalse: [aColorSpec])"
    ]

    lineType [
	^params at: #linetype ifAbsent: [ nil ]
    ]

    lineType: aNumber [
	"If you wish to choose the line or point type for a single plot, <line type> and <point type> may be
	 specified. These are positive integer constants (or expressions) that specify the line type and point type
	 to be used for the plot."

	<category: 'styles'>
	params at: #linetype put: aNumber
    ]

    lineWidth [
	^params at: #linewidth ifAbsent: [ nil ]
    ]

    lineWidth: aParam [
	"You may also scale the line width and point size for a plot by using <line width> and <point size>,
	 which are specified relative to the default values for each terminal. The pointsize may also be altered
	 globally; see set pointsize for details. But note that both <point size> as set here and
	 as set by set pointsize multiply the default point size; their effects are not cumulative. That is, set
	 pointsize 2; plot x w p ps 3 will use points three times default size, not six."

	<category: 'styles'>
	params at: #linewidth put: aParam
    ]
]


GPBoundingBox subclass: GPLine [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define an arrow drawn on a graph.'>

    GPLine class >> defaultStyleClass [
	<category: 'style'>
        ^GPLineStyle
    ]

    displayOn: aStream pointDisplay: aBlock [
	<category: 'printing'>
	aStream nextPutAll: 'set arrow from '.
	aBlock value: aStream value: self origin.
	aStream nextPutAll: ' to '.
	aBlock value: aStream value: self corner.
	aStream nextPutAll: ' front nohead'.

	self style isNil ifFalse: [ self style displayOn: aStream ]
    ]
]


GPLineStyle subclass: GPRectangleStyle [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define the appearance of a rectangle
drawn on a graph.'>

    fillStyle [
        <category: 'styles'>
        ^params at: #fillstyle ifAbsent: [ #solid ]
    ]

    fillStyle: aString [
        <category: 'styles'>
        params at: #fillstyle put: aString
    ]
]

GPBoundingBox subclass: GPRectangle [
    GPRectangle class >> defaultStyleClass [
	<category: 'style'>
        ^GPRectangleStyle
    ]

    displayOn: aStream pointDisplay: aBlock [
	<category: 'printing'>
	aStream nextPutAll: 'set object rect from '.
	aBlock value: aStream value: self origin.
	aStream nextPutAll: ' to '.
	aBlock value: aStream value: self corner.
	aStream nextPutAll: ' front'.

	self style isNil ifFalse: [ self style displayOn: aStream ]
    ]
]


GPLineStyle subclass: GPArrowStyle [
    | head tail filled size thickness |

    initialize [
	<category: 'initialization'>
	super initialize.
	head := true.
	tail := false.
	filled := true.

	"This looks more or less like gnuplot's default arrow."
	size := (0.015 * 15 degreesToRadians cos)
		@ (0.015 * 15 degreesToRadians sin).
	thickness := 0.
    ]

    thickness [
	<category: 'accessing'>
	^thickness
    ]

    thickness: aNumber [
	<category: 'accessing'>
	"<1 gives an acute angle (concave head), =1 a right angle."
	thickness := aNumber
    ]

    size [
	<category: 'accessing'>
	^size
    ]

    size: aPoint [
	"The x size is parallel to the line, the y size
	 is perpendicular."
	<category: 'accessing'>
	size := aPoint
    ]

    head [
	<category: 'accessing'>
	^head
    ]

    head: aSymbol [
	<category: 'accessing'>
	head := aSymbol
    ]

    tail [
	<category: 'accessing'>
	^tail
    ]

    tail: aSymbol [
	<category: 'accessing'>
	tail := aSymbol
    ]

    filled [
	<category: 'accessing'>
	^filled
    ]

    filled: aSymbol [
	<category: 'accessing'>
	filled := aSymbol
    ]

    displayOn: aStream [
	<category: 'printing'>
	| heads angle backAngle length |
	heads := (#((' nohead' ' backhead') (' head') (' heads'))
		    at: (head ifTrue: [ 2 ] ifFalse: [ 1 ]))
		        at: (tail ifTrue: [ 2 ] ifFalse: [ 1 ]).

	aStream nextPutAll: heads.

	angle := size y arcTan: size x.
	length := size x / angle cos.
	angle := angle radiansToDegrees rounded.
	aStream
	   nextPutAll: ' size screen ';
	   print: length;
	   nextPut: $,;
	   print: angle.

	backAngle := thickness = 0
	    ifTrue: [ angle ]
	    ifFalse: [ (size y arcTan: size x * (1 - thickness))
				radiansToDegrees rounded ].

	backAngle > angle
	    ifTrue: [
		aStream
		    nextPut: $,;
		    print: backAngle;
		    nextPutAll: (filled ifTrue: [ ' filled' ] ifFalse: [ ' empty' ]) ]
	    ifFalse: [
		aStream nextPutAll: ' nofilled' ].

	super displayOn: aStream
    ]
]

GPBoundingBox subclass: GPArrow [
    <category: 'GNUPlot'>
    <comment: 'My instance is used to define an arrow drawn on a graph.'>

    GPArrow class >> defaultStyleClass [
	<category: 'style'>
        ^GPArrowStyle
    ]

    displayOn: aStream pointDisplay: aBlock [
	<category: 'printing'>
	aStream nextPutAll: 'set arrow from '.
	aBlock value: aStream value: self origin.
	aStream nextPutAll: ' to '.
	aBlock value: aStream value: self corner.
	aStream nextPutAll: ' front'.

	self style isNil ifFalse: [ self style displayOn: aStream ]
    ]
]

PK    �Mh@�F�
l  #  	  ChangeLogUT	 dqXO��XOux �  �  �V�n�8}��b�<(l�v{1�`�&1�#n��8��67)�Tb���EYr6g߄9�3g�p2���`����pn�?�(����׵��֭�z��wPbv�kn=�[*�=��૒�JW���a�4�A���z���������8GOC�pcˣ,�)���7����,�Yk�}��/�#X� �V: eؽ*ۏy��\��etvv�az���������~��C�aS�i����K�dr���mA6ʬ=(�_ĥz�6`W�v�ە'(���-�N�Id��� տ����cA&p"�y&n� �<�f@5����潓C g`e��C�+��v7f��>�p|��+I!���2����i�	�QW$�� X!t��{9!����U����"�ښ���.�E��4r��E�i	Ŧۆ���J n� ӣ��[�1�2��d�h8�K�0�_wéD��<X�)��1AHQ�ےs�-햎�����A�|2Ȭ�
����W�=�\����N�X���~*k:��ɚ��я�rK��Q�ο��2L[���h����)0���.�n���p�5�3V���Kb�[C@$S]t�����d����s�U.t�k�q�sࡍ��{7G���0��%&w�������f"6�Ivd2D*R��#�րʐk�G2�C�=�m%��1d��
� XQ*�G]�yQw2G��-bZp-22�΂ɠJ��'M6Q��ds���4b�ܐ�"�����J�NB����٩�Y�$���o��6�LR'�l>�!WL��$l9t�f�%W(�����|��r}Շ���}��&=ڡ���L�z��!H[F��@m���|W��N�ذ�9�]{�U+sc`���[�Ӳ�|�&��\��ڮ�b��lA���l���aXuO�`�H��6�\�ȵlX�����U��K_$Q�w��EVit����ϸ��l��k��.�%v��ခ�'�独�H�Z�w�/"�}"AUvD;h���Kĝ�H~{xP2�QÞR? ����t���R�q�SQ۲Z�>x�)��;c:����s���.t80�����-+*n�iY�$%��@j�t�uׯc�|��]�?��0>����c�6�F���1�j��^?��\��PK
     �Mh@�C��tL  tL            ��    2D.stUT dqXOux �  �  PK
     �Mh@���a0  0            ���L  Expressions.stUT dqXOux �  �  PK
     �Mh@�l�#H'  H'            ��}  Terminals.stUT dqXOux �  �  PK
     �Mh@݉��S  S  	          ����  Series.stUT dqXOux �  �  PK
     �[h@�Q�6  6            ����  package.xmlUT ��XOux �  �  PK
     �Mh@�jo^8  ^8            ��Y�  Base.stUT dqXOux �  �  PK
     �Mh@AÕ  �            ���1 Examples.stUT dqXOux �  �  PK
     �Mh@�%��.  �.  
          ���G Objects.stUT dqXOux �  �  PK    �Mh@�F�
l  #  	         ���v ChangeLogUT dqXOux �  �  PK    	 	 �  O{   