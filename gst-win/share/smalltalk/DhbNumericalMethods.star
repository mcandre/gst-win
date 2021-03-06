PK
     �Mh@�f�Mg  g    Integration.stUT	 dqXOȉXOux �  �  "======================================================================
|
|   Numerical methods - Integration
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



DhbFunctionalIterator subclass: DhbTrapezeIntegrator [
    | from to sum step |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbTrapezeIntegrator class >> function: aBlock from: aNumber1 to: aNumber2 [
	"Create an new instance with given parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'creation'>
	^super new 
	    initialize: aBlock
	    from: aNumber1
	    to: aNumber2
    ]

    DhbTrapezeIntegrator class >> new [
	"Private - Block the constructor method for this class.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'creation'>
	^self error: 'Method new:from:to: must be used'
    ]

    DhbTrapezeIntegrator class >> defaultMaximumIterations [
	"Private - Answers the default maximum number of iterations for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^13
    ]

    from: aNumber1 to: aNumber2 [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'initialization'>
	from := aNumber1.
	to := aNumber2
    ]

    initialize: aBlock from: aNumber1 to: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'initialization'>
	functionBlock := aBlock.
	self from: aNumber1 to: aNumber2.
	^self
    ]

    computeInitialValues [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'operation'>
	step := to - from.
	sum := ((functionBlock value: from) + (functionBlock value: to)) * step 
		    / 2.
	result := sum
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'operation'>
	| oldResult |
	oldResult := result.
	result := self higherOrderSum.
	^self relativePrecision: (result - oldResult) abs
    ]

    higherOrderSum [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'transformation'>
	| x newSum |
	x := step / 2 + from.
	newSum := 0.
	[x < to] whileTrue: 
		[newSum := (functionBlock value: x) + newSum.
		x := x + step].
	sum := (step * newSum + sum) / 2.
	step := step / 2.
	^sum
    ]
]



DhbTrapezeIntegrator subclass: DhbRombergIntegrator [
    | order points interpolator |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbRombergIntegrator class >> defaultOrder [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'information'>
	^5
    ]

    initialize [
	"Private - initialize the parameters of the receiver with default values.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'initialization'>
	order := self class defaultOrder.
	^super initialize
    ]

    order: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'initialization'>
	anInteger < 2 
	    ifTrue: [self error: 'Order for Romberg integration must be larger than 1'].
	order := anInteger
    ]

    computeInitialValues [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'operation'>
	super computeInitialValues.
	points := OrderedCollection new: order.
	interpolator := DhbNevilleInterpolator points: points.
	points add: 1 @ sum
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'operation'>
	| interpolation |
	points addLast: (points last x * 0.25) @ self higherOrderSum.
	points size < order ifTrue: [^1].
	interpolation := interpolator valueAndError: 0.
	points removeFirst.
	result := interpolation at: 1.
	^self relativePrecision: (interpolation at: 2) abs
    ]
]



DhbTrapezeIntegrator subclass: DhbSimpsonIntegrator [
    
    <comment: nil>
    <category: 'DHB Numerical'>

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/4/99"

	<category: 'operation'>
	| oldResult oldSum |
	iterations < 2 
	    ifTrue: 
		[self higherOrderSum.
		^1].
	oldResult := result.
	oldSum := sum.
	result := (self higherOrderSum * 4 - oldSum) / 3.
	^self relativePrecision: (result - oldResult) abs
    ]
]

PK
     �Mh@��M�*{  *{    Optimization.stUT	 dqXOȉXOux �  �  "======================================================================
|
|   Numerical methods - Optimization / Operations Research
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: DhbProjectedOneVariableFunction [
    | index function argument |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbProjectedOneVariableFunction class >> function: aVectorFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'creation'>
	^super new initialize: aVectorFunction
    ]

    argumentWith: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^argument
	    at: index put: aNumber;
	    yourself
    ]

    index [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	index isNil ifTrue: [index := 1].
	^index
    ]

    value: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^function value: (self argumentWith: aNumber)
    ]

    initialize: aFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	function := aFunction.
	^self
    ]

    setArgument: anArrayOrVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	argument := anArrayOrVector copy
    ]

    setIndex: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	index := anInteger
    ]

    bumpIndex [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'transformation'>
	index isNil 
	    ifTrue: [index := 1]
	    ifFalse: 
		[index := index + 1.
		index > argument size ifTrue: [index := 1]]
    ]
]



DhbFunctionalIterator subclass: DhbFunctionOptimizer [
    | optimizingPointClass bestPoints |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbFunctionOptimizer class >> forOptimizer: aFunctionOptimizer [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'creation'>
	^self new initializeForOptimizer: aFunctionOptimizer
    ]

    DhbFunctionOptimizer class >> maximizingFunction: aFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'creation'>
	^(super new)
	    initializeAsMaximizer;
	    setFunction: aFunction
    ]

    DhbFunctionOptimizer class >> minimizingFunction: aFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'creation'>
	^(super new)
	    initializeAsMinimizer;
	    setFunction: aFunction
    ]

    DhbFunctionOptimizer class >> defaultPrecision [
	"Private - Answers the default precision for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^super defaultPrecision * 100
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'display'>
	super printOn: aStream.
	bestPoints do: 
		[:each | 
		aStream cr.
		each printOn: aStream]
    ]

    bestPoints [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^bestPoints
    ]

    functionBlock [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^functionBlock
    ]

    pointClass [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^optimizingPointClass
    ]

    initialize [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	bestPoints := SortedCollection sortBlock: [:a :b | a betterThan: b].
	^super initialize
    ]

    initializeAsMaximizer [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	optimizingPointClass := DhbMaximizingPoint.
	^self initialize
    ]

    initializeAsMinimizer [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	optimizingPointClass := DhbMinimizingPoint.
	^self
    ]

    initializeForOptimizer: aFunctionOptimizer [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	optimizingPointClass := aFunctionOptimizer pointClass.
	functionBlock := aFunctionOptimizer functionBlock.
	^self initialize
    ]

    initialValue: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'initialization'>
	result := aVector copy
    ]

    finalizeIterations [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	result := bestPoints first position
    ]

    addPointAt: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'transformation'>
	bestPoints 
	    add: (optimizingPointClass vector: aNumber function: functionBlock)
    ]
]



Object subclass: DhbMinimizingPoint [
    | value position |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbMinimizingPoint class >> new: aVector value: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'creation'>
	^(self new)
	    vector: aVector;
	    value: aNumber;
	    yourself
    ]

    DhbMinimizingPoint class >> vector: aVector function: aFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'creation'>
	^self new: aVector value: (aFunction value: aVector)
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 05-Jan-00"

	<category: 'display'>
	position printOn: aStream.
	aStream
	    nextPut: $:;
	    space.
	value printOn: aStream
    ]

    betterThan: anOptimizingPoint [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'information'>
	^value < anOptimizingPoint value
    ]

    position [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'information'>
	^position
    ]

    value [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'information'>
	^value
    ]

    value: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'initialization'>
	value := aNumber
    ]

    vector: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'initialization'>
	position := aVector
    ]
]



DhbFunctionOptimizer subclass: DhbOneVariableFunctionOptimizer [
    
    <comment: nil>
    <category: 'DHB Numerical'>

    GoldenSection := nil.

    DhbOneVariableFunctionOptimizer class >> defaultPrecision [
	"Private - Answers the default precision for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^DhbFloatingPointMachine new defaultNumericalPrecision * 10
    ]

    DhbOneVariableFunctionOptimizer class >> goldenSection [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	GoldenSection isNil ifTrue: [GoldenSection := (3 - 5 sqrt) / 2].
	^GoldenSection
    ]

    computePrecision [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^self 
	    precisionOf: ((bestPoints at: 2) position - (bestPoints at: 3) position) 
		    abs
	    relativeTo: (bestPoints at: 1) position abs
    ]

    hasBracketingPoints [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	| x1 |
	x1 := (bestPoints at: 1) position.
	^((bestPoints at: 2) position - x1) * ((bestPoints at: 3) position - x1) 
	    < 0
    ]

    indexOfOuterPoint [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	| inferior superior x |
	inferior := false.
	superior := false.
	x := bestPoints first position.
	2 to: 4
	    do: 
		[:n | 
		(bestPoints at: n) position < x 
		    ifTrue: 
			[inferior ifTrue: [^n].
			inferior := true]
		    ifFalse: 
			[superior ifTrue: [^n].
			superior := true]]
    ]

    nextXValue [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	| d3 d2 x1 |
	x1 := (bestPoints at: 1) position.
	d2 := (bestPoints at: 2) position - x1.
	d3 := (bestPoints at: 3) position - x1.
	^(d3 abs > d2 abs ifTrue: [d3] ifFalse: [d2]) * self class goldenSection 
	    + x1
    ]

    computeInitialValues [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	[bestPoints size > 3] whileTrue: [bestPoints removeLast].
	bestPoints size = 3 
	    ifTrue: [self hasBracketingPoints ifFalse: [bestPoints removeLast]].
	bestPoints size < 3 
	    ifTrue: [(DhbOptimizingBracketFinder forOptimizer: self) evaluate]
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	self addPointAt: self nextXValue.
	bestPoints removeAtIndex: self indexOfOuterPoint.
	^self computePrecision
    ]

    reset [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'transformation'>
	[bestPoints isEmpty] whileFalse: [bestPoints removeLast]
    ]
]



DhbFunctionOptimizer subclass: DhbMultiVariableGeneralOptimizer [
    
    <comment: nil>
    <category: 'DHB Numerical'>

    origin [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'initialization'>
	^result
    ]

    origin: anArrayOrVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'initialization'>
	result := anArrayOrVector
    ]

    range [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'initialization'>
	^self bestPoints
    ]

    range: anArrayOrVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'initialization'>
	bestPoints := anArrayOrVector
    ]

    computeInitialValues [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'operation'>
	self range notNil ifTrue: [self performGeneticOptimization].
	self performSimplexOptimization
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| optimizer |
	optimizer := DhbHillClimbingOptimizer forOptimizer: self.
	optimizer
	    desiredPrecision: desiredPrecision;
	    maximumIterations: maximumIterations;
	    initialValue: result.
	result := optimizer evaluate.
	^optimizer precision
    ]

    finalizeIterations [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	
    ]

    performGeneticOptimization [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'operation'>
	| optimizer manager |
	optimizer := DhbGeneticOptimizer forOptimizer: self.
	manager := DhbVectorChromosomeManager 
		    new: 100
		    mutation: 0.1
		    crossover: 0.1.
	manager
	    origin: self origin asVector;
	    range: self range asVector.
	optimizer chromosomeManager: manager.
	result := optimizer evaluate
    ]

    performSimplexOptimization [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/29/00"

	<category: 'operation'>
	| optimizer |
	optimizer := DhbSimplexOptimizer forOptimizer: self.
	optimizer
	    desiredPrecision: desiredPrecision sqrt;
	    maximumIterations: maximumIterations;
	    initialValue: result asVector.
	result := optimizer evaluate
    ]
]



Object subclass: DhbChromosomeManager [
    | population populationSize rateOfMutation rateOfCrossover |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbChromosomeManager class >> new: anInteger mutation: aNumber1 crossover: aNumber2 [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'creation'>
	^(self new)
	    populationSize: anInteger;
	    rateOfMutation: aNumber1;
	    rateOfCrossover: aNumber2;
	    yourself
    ]

    randomChromosome [
	<category: 'creation'>
	self subclassResponsibility
    ]

    isFullyPopulated [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'information'>
	^population size >= populationSize
    ]

    population [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'information'>
	^population
    ]

    populationSize: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	populationSize := anInteger
    ]

    rateOfCrossover: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	(aNumber between: 0 and: 1) 
	    ifFalse: [self error: 'Illegal rate of cross-over'].
	rateOfCrossover := aNumber
    ]

    rateOfMutation: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	(aNumber between: 0 and: 1) 
	    ifFalse: [self error: 'Illegal rate of mutation'].
	rateOfMutation := aNumber
    ]

    clone: aChromosome [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	^aChromosome copy
    ]

    crossover: aChromosome1 and: aChromosome2 [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	^self subclassResponsibility
    ]

    mutate: aChromosome [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	^self subclassResponsibility
    ]

    process: aChromosome1 and: aChromosome2 [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	| roll |
	roll := Number random.
	roll < rateOfCrossover 
	    ifTrue: [population addAll: (self crossover: aChromosome1 and: aChromosome2)]
	    ifFalse: 
		[roll < (rateOfCrossover + rateOfMutation) 
		    ifTrue: 
			[population
			    add: (self mutate: aChromosome1);
			    add: (self mutate: aChromosome2)]
		    ifFalse: 
			[population
			    add: (self clone: aChromosome1);
			    add: (self clone: aChromosome2)]]
    ]

    randomizePopulation [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	self reset.
	[self isFullyPopulated] 
	    whileFalse: [population add: self randomChromosome]
    ]

    reset [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'transformation'>
	population := OrderedCollection new: populationSize
    ]
]



DhbFunctionOptimizer subclass: DhbHillClimbingOptimizer [
    | unidimensionalFinder |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    computeInitialValues [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 05-Jan-00"

	<category: 'initialization'>
	unidimensionalFinder := DhbOneVariableFunctionOptimizer forOptimizer: self.
	unidimensionalFinder desiredPrecision: desiredPrecision.
	bestPoints := (1 to: result size) collect: 
			[:n | 
			(DhbVectorProjectedFunction function: functionBlock)
			    direction: ((DhbVector new: result size)
					atAllPut: 0;
					at: n put: 1;
					yourself);
			    yourself]
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| oldResult |
	precision := 1.0.
	bestPoints inject: result
	    into: [:prev :each | self minimizeDirection: each from: prev].
	self shiftDirections.
	self minimizeDirection: bestPoints last.
	oldResult := result.
	result := bestPoints last origin.
	precision := 0.0.
	result with: oldResult
	    do: 
		[:x0 :x1 | 
		precision := (self precisionOf: (x0 - x1) abs relativeTo: x0 abs) 
			    max: precision].
	^precision
    ]

    finalizeIterations [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	
    ]

    minimizeDirection: aVectorFunction [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	^unidimensionalFinder
	    reset;
	    setFunction: aVectorFunction;
	    addPointAt: 0;
	    addPointAt: precision;
	    addPointAt: precision negated;
	    evaluate
    ]

    minimizeDirection: aVectorFunction from: aVector [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	^aVectorFunction
	    origin: aVector;
	    argumentWith: (self minimizeDirection: aVectorFunction)
    ]

    shiftDirections [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	| position delta firstDirection |
	firstDirection := bestPoints first direction.
	bestPoints inject: nil
	    into: 
		[:prev :each | 
		position isNil 
		    ifTrue: [position := each origin]
		    ifFalse: [prev direction: each direction].
		each].
	position := bestPoints last origin - position.
	delta := position norm.
	delta > desiredPrecision 
	    ifTrue: [bestPoints last direction: (position scaleBy: 1 / delta)]
	    ifFalse: [bestPoints last direction: firstDirection]
    ]
]



DhbFunctionOptimizer subclass: DhbGeneticOptimizer [
    | chromosomeManager |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbGeneticOptimizer class >> defaultMaximumIterations [
	"Private - Answers the default maximum number of iterations for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^500
    ]

    DhbGeneticOptimizer class >> defaultPrecision [
	"Private - Answers the default precision for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^0
    ]

    computePrecision [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^1
    ]

    randomIndex: aNumberArray [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'information'>
	| x n |
	x := Number random.
	n := 1.
	aNumberArray do: 
		[:each | 
		x < each ifTrue: [^n].
		n := n + 1].
	^aNumberArray size	"Never reached unless an error occurs"
    ]

    randomScale [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'information'>
	| norm fBest fWorst answer |
	fBest := bestPoints first value.
	fWorst := bestPoints last value.
	norm := 1 / (fBest - fWorst).
	answer := bestPoints collect: [:each | (each value - fWorst) * norm].
	norm := 1 / (answer inject: 0 into: [:sum :each | each + sum]).
	fBest := 0.
	^answer collect: 
		[:each | 
		fBest := each * norm + fBest.
		fBest]
    ]

    chromosomeManager: aChromosomeManager [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	chromosomeManager := aChromosomeManager.
	^self
    ]

    collectPoints [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	| bestPoint |
	bestPoints isEmpty not ifTrue: [bestPoint := bestPoints removeFirst].
	bestPoints removeAll: bestPoints asArray.
	chromosomeManager population do: [:each | self addPointAt: each].
	bestPoint notNil ifTrue: [bestPoints add: bestPoint].
	result := bestPoints first position
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	| randomScale |
	randomScale := self randomScale.
	chromosomeManager reset.
	[chromosomeManager isFullyPopulated] 
	    whileFalse: [self processRandomParents: randomScale].
	self collectPoints.
	^self computePrecision
    ]

    initializeIterations [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	chromosomeManager randomizePopulation.
	self collectPoints
    ]

    processRandomParents: aNumberArray [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	chromosomeManager 
	    process: (bestPoints at: (self randomIndex: aNumberArray)) position
	    and: (bestPoints at: (self randomIndex: aNumberArray)) position
    ]
]



DhbMinimizingPoint subclass: DhbMaximizingPoint [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    betterThan: anOptimizingPoint [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 04-Jan-00"

	<category: 'information'>
	^value > anOptimizingPoint value
    ]
]



DhbFunctionOptimizer subclass: DhbSimplexOptimizer [
    | worstVector |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbSimplexOptimizer class >> defaultPrecision [
	"Private - Answers the default precision for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^DhbFloatingPointMachine new defaultNumericalPrecision * 1000
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'display'>
	super printOn: aStream.
	aStream cr.
	worstVector printOn: aStream
    ]

    computeInitialValues [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	bestPoints 
	    add: (optimizingPointClass vector: result function: functionBlock).
	self buildInitialSimplex.
	worstVector := bestPoints removeLast position
    ]

    buildInitialSimplex [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	| projectedFunction finder partialResult |
	projectedFunction := DhbProjectedOneVariableFunction 
		    function: functionBlock.
	finder := DhbOneVariableFunctionOptimizer forOptimizer: self.
	finder setFunction: projectedFunction.
	[bestPoints size < (result size + 1)] whileTrue: 
		[projectedFunction
		    setArgument: result;
		    bumpIndex.
		partialResult := finder
			    reset;
			    evaluate.
		bestPoints add: (optimizingPointClass 
			    vector: (projectedFunction argumentWith: partialResult)
			    function: functionBlock)]
    ]

    computePrecision [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/16/00"

	<category: 'operation'>
	| functionValues bestFunctionValue |
	functionValues := bestPoints collect: [:each | each value].
	bestFunctionValue := functionValues removeFirst.
	^functionValues inject: 0
	    into: 
		[:max :each | 
		(self precisionOf: (each - bestFunctionValue) abs
		    relativeTo: bestFunctionValue abs) max: max]
    ]

    contract [
	"Private - Contract the Simplex around the best Vector.
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/16/00"

	<category: 'operation'>
	| bestVector oldVectors |
	bestVector := bestPoints first position.
	oldVectors := OrderedCollection with: worstVector.
	[bestPoints size > 1] 
	    whileTrue: [oldVectors add: bestPoints removeLast position].
	oldVectors do: [:each | self contract: each around: bestVector].
	worstVector := bestPoints removeLast position.
	^self computePrecision
    ]

    contract: aVector around: bestVector [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/16/00"

	<category: 'operation'>
	bestPoints 
	    add: (optimizingPointClass vector: bestVector * 0.5 + (aVector * 0.5)
		    function: functionBlock)
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| centerOfGravity newPoint nextPoint |
	centerOfGravity := (bestPoints inject: ((worstVector copy)
			    atAllPut: 0;
			    yourself)
		    into: [:sum :each | each position + sum]) * (1 / bestPoints size).
	newPoint := optimizingPointClass vector: 2 * centerOfGravity - worstVector
		    function: functionBlock.
	(newPoint betterThan: bestPoints first) 
	    ifTrue: 
		[nextPoint := optimizingPointClass 
			    vector: newPoint position * 2 - centerOfGravity
			    function: functionBlock.
		(nextPoint betterThan: newPoint) ifTrue: [newPoint := nextPoint]]
	    ifFalse: 
		[newPoint := optimizingPointClass 
			    vector: centerOfGravity * 666667 + (worstVector * 333333)
			    function: functionBlock.
		(newPoint betterThan: bestPoints first) ifFalse: [^self contract]].
	worstVector := bestPoints removeLast position.
	bestPoints add: newPoint.
	result := bestPoints first position.
	^self computePrecision
    ]
]



DhbProjectedOneVariableFunction subclass: DhbVectorProjectedFunction [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'display'>
	self origin printOn: aStream.
	aStream nextPutAll: ' ('.
	self direction printOn: aStream.
	aStream nextPut: $)
    ]

    argumentWith: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^aNumber * self direction + self origin
    ]

    direction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^index
    ]

    origin [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'information'>
	^argument
    ]

    direction: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	index := aVector
    ]

    origin: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	argument := aVector
    ]
]



DhbOneVariableFunctionOptimizer subclass: DhbOptimizingBracketFinder [
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbOptimizingBracketFinder class >> initialPoints: aSortedCollection function: aFunction [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'creation'>
	^(super new)
	    setInitialPoints: aSortedCollection;
	    setFunction: aFunction
    ]

    initializeForOptimizer: aFunctionOptimizer [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	super initializeForOptimizer: aFunctionOptimizer.
	bestPoints := aFunctionOptimizer bestPoints.
	^self
    ]

    setInitialPoints: aSortedCollection [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'initialization'>
	bestPoints := aSortedCollection
    ]

    computeInitialValues [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	[bestPoints size < 2] whileTrue: [self addPointAt: Number random]
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	| x1 x2 |
	x1 := (bestPoints at: 1) position.
	x2 := (bestPoints at: 2) position.
	self addPointAt: x1 * 3 - (x2 * 2).
	precision := (x2 - x1) * ((bestPoints at: 3) position - x1).
	self hasConverged ifFalse: [bestPoints removeLast].
	^precision
    ]

    finalizeIterations [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/22/00"

	<category: 'operation'>
	result := bestPoints
    ]
]



DhbChromosomeManager subclass: DhbVectorChromosomeManager [
    | origin range |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    randomChromosome [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'creation'>
	^((1 to: origin size) collect: [:n | self randomComponent: n]) asVector
    ]

    randomComponent: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'information'>
	^(range at: anInteger) asFloatD random + (origin at: anInteger)
    ]

    origin: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	origin := aVector
    ]

    range: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'initialization'>
	range := aVector
    ]

    crossover: aChromosome1 and: aChromosome2 [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	| index new1 new2 |
	index := (aChromosome1 size - 1) random + 2.
	new1 := self clone: aChromosome1.
	new1 
	    replaceFrom: index
	    to: new1 size
	    with: aChromosome2
	    startingAt: index.
	new2 := self clone: aChromosome2.
	new2 
	    replaceFrom: index
	    to: new2 size
	    with: aChromosome1
	    startingAt: index.
	^Array with: new1 with: new2
    ]

    mutate: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 23-Feb-00"

	<category: 'operation'>
	| index |
	index := aVector size random + 1.
	^(aVector copy)
	    at: index put: (self randomComponent: index);
	    yourself
    ]
]

PK
     �Mh@T/�d�H  �H    Approximation.stUT	 dqXOȉXOux �  �  "======================================================================
|
|   Numerical methods - Interpolation and root finding
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



DhbFunctionalIterator subclass: DhbNewtonZeroFinder [
    | derivativeBlock |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbNewtonZeroFinder class >> function: aBlock1 derivative: aBlock2 [
	"Convenience method to create a instance with given function block.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'creation'>
	^(self new)
	    setFunction: aBlock1;
	    setDerivative: aBlock2;
	    yourself
    ]

    defaultDerivativeBlock [
	"Private - Answers a block computing the function's derivative by approximation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'information'>
	^
	[:x | 
	5000 
	    * ((functionBlock value: x + 0.0001) - (functionBlock value: x - 0.0001))]
    ]

    initialValue: aNumber [
	"Define the initial value for the iterations.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'initialization'>
	result := aNumber
    ]

    setDerivative: aBlock [
	"Defines the derivative of the function for which zeroes will be found.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'initialization'>
	| x |
	(aBlock respondsTo: #value:) 
	    ifFalse: [self error: 'Derivative block must implement the method value:'].
	x := result isNil ifTrue: [Number random] ifFalse: [result + Number random].
	((aBlock value: x) 
	    relativelyEqualsTo: (self defaultDerivativeBlock value: x)
	    upTo: 0.0001) ifFalse: [self error: 'Supplied derivative is not correct'].
	derivativeBlock := aBlock
    ]

    setFunction: aBlock [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 26/4/99"

	<category: 'initialization'>
	super setFunction: aBlock.
	derivativeBlock := nil
    ]

    computeInitialValues [
	"Private - If no derivative has been defined, take an ad-hoc definition.
	 If no initial value has been defined, take 0 as the starting point (for lack of anything better).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| n |
	result isNil ifTrue: [result := 0].
	derivativeBlock isNil 
	    ifTrue: [derivativeBlock := self defaultDerivativeBlock].
	n := 0.
	[(derivativeBlock value: result) equalsTo: 0] whileTrue: 
		[n := n + 1.
		n > maximumIterations 
		    ifTrue: [self error: 'Function''s derivative seems to be zero everywhere'].
		result := Number random + result]
    ]

    evaluateIteration [
	"Compute one step of Newton's zero finding method. Answers the estimated precision.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| delta |
	delta := (functionBlock value: result) / (derivativeBlock value: result).
	result := result - delta.
	^self relativePrecision: delta abs
    ]
]



Object subclass: DhbLagrangeInterpolator [
    | pointCollection |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLagrangeInterpolator class >> new [
	"Create a new instance of the receiver without points. Points must be added with add:
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^super new initialize
    ]

    DhbLagrangeInterpolator class >> points: aCollectionOfPoints [
	"Create a new instance of the receiver with given points.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initialize: aCollectionOfPoints
    ]

    defaultSamplePoints [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/5/99"

	<category: 'information'>
	^OrderedCollection new
    ]

    size [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 3/12/00"

	<category: 'information'>
	^pointCollection size
    ]

    value: aNumber [
	"Compute the value of the Lagrange interpolation polynomial on the receiver's points at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	| norm dx products answer size |
	norm := 1.
	size := pointCollection size.
	products := Array new: size.
	products atAllPut: 1.
	1 to: size
	    do: 
		[:n | 
		dx := aNumber - (self xPointAt: n).
		dx = 0 ifTrue: [^self yPointAt: n].
		norm := norm * dx.
		1 to: size
		    do: 
			[:m | 
			m = n 
			    ifFalse: 
				[products at: m
				    put: ((self xPointAt: m) - (self xPointAt: n)) * (products at: m)]]].
	answer := 0.
	1 to: size
	    do: 
		[:n | 
		answer := (self yPointAt: n) 
			    / ((products at: n) * (aNumber - (self xPointAt: n))) + answer].
	^norm * answer
    ]

    xPointAt: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'information'>
	^(pointCollection at: anInteger) x
    ]

    yPointAt: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'information'>
	^(pointCollection at: anInteger) y
    ]

    initialize [
	"Private - Create an empty point collection for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	^self initialize: self defaultSamplePoints
    ]

    initialize: aCollectionOfPoints [
	"Private - Defines the collection of points for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	pointCollection := aCollectionOfPoints.
	^self
    ]

    add: aPoint [
	"Add a point to the collection of points.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	^pointCollection add: aPoint
    ]
]



DhbFunctionalIterator subclass: DhbBisectionZeroFinder [
    | positiveX negativeX |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    setNegativeX: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'initialization'>
	(functionBlock value: aNumber) < 0 
	    ifFalse: 
		[self error: 'Function is not negative at x = ' , aNumber printString].
	negativeX := aNumber
    ]

    setPositiveX: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'initialization'>
	(functionBlock value: aNumber) > 0 
	    ifFalse: 
		[self error: 'Function is not positive at x = ' , aNumber printString].
	positiveX := aNumber
    ]

    computeInitialValues [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'operation'>
	positiveX isNil ifTrue: [self error: 'No positive value supplied'].
	negativeX isNil ifTrue: [self error: 'No negative value supplied']
    ]

    evaluateIteration [
	"Perform one step of bisection.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'operation'>
	result := (positiveX + negativeX) * 0.5.
	(functionBlock value: result) > 0 
	    ifTrue: [positiveX := result]
	    ifFalse: [negativeX := result].
	^self relativePrecision: (positiveX - negativeX) abs
    ]

    findNegativeXFrom: aNumber1 range: aNumber2 [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'operation'>
	| n |
	n := 0.
	
	[negativeX := Number random * aNumber2 + aNumber1.
	(functionBlock value: negativeX) < 0] 
		whileFalse: 
		    [n := n + 0.1.
		    n > maximumIterations 
			ifTrue: [self error: 'Unable to find a negative function value']]
    ]

    findPositiveXFrom: aNumber1 range: aNumber2 [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'operation'>
	| n |
	n := 0.
	
	[positiveX := Number random * aNumber2 + aNumber1.
	(functionBlock value: positiveX) > 0] 
		whileFalse: 
		    [n := n + 1.
		    n > maximumIterations 
			ifTrue: [self error: 'Unable to find a positive function value']]
    ]
]



DhbLagrangeInterpolator subclass: DhbNewtonInterpolator [
    | coefficients |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    computeCoefficients [
	"Private - Computes the coefficients for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	| size k1 kn |
	size := pointCollection size.
	coefficients := (1 to: size) collect: [:n | self yPointAt: n].
	1 to: size - 1
	    do: 
		[:n | 
		size to: n + 1
		    by: -1
		    do: 
			[:k | 
			k1 := k - 1.
			kn := k - n.
			coefficients at: k
			    put: ((coefficients at: k) - (coefficients at: k1)) 
				    / ((self xPointAt: k) - (self xPointAt: kn))]]
    ]

    value: aNumber [
	"Compute the value of the Lagrange interpolation polynomial on the receiver's points at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	| answer size |
	coefficients isNil ifTrue: [self computeCoefficients].
	size := coefficients size.
	answer := coefficients at: size.
	size - 1 to: 1
	    by: -1
	    do: [:n | answer := answer * (aNumber - (self xPointAt: n)) + (coefficients at: n)].
	^answer
    ]

    add: aPoint [
	"Add a point to the collection of points.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	self resetCoefficients.
	^super add: aPoint
    ]

    resetCoefficients [
	"Private - Reset the coefficients of the receiver to force a new computation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	coefficients := nil
    ]
]



DhbNewtonInterpolator subclass: DhbSplineInterpolator [
    | startPointDerivative endPointDerivative |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    defaultSamplePoints [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/5/99"

	<category: 'information'>
	^SortedCollection sortBlock: [:a :b | a x < b x]
    ]

    resetEndPointDerivatives [
	"Set the end point derivatives to undefined.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	self setEndPointDerivatives: (Array new: 2)
    ]

    setEndPointDerivatives: anArray [
	"Defines the end point derivatives.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	startPointDerivative := anArray at: 1.
	endPointDerivative := anArray at: 2.
	self resetCoefficients
    ]

    startPointDerivative: aNumber [
	"Defines the end point derivatives.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	startPointDerivative := aNumber.
	self resetCoefficients
    ]

    value: aNumber [
	"Computes the value of a cubic spline interpolation over the points of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	| n1 n2 n step a b |
	coefficients isNil ifTrue: [self computeSecondDerivatives].
	n2 := pointCollection size.
	n1 := 1.
	[n2 - n1 > 1] whileTrue: 
		[n := (n1 + n2) // 2.
		(self xPointAt: n) > aNumber ifTrue: [n2 := n] ifFalse: [n1 := n]].
	step := (self xPointAt: n2) - (self xPointAt: n1).
	a := ((self xPointAt: n2) - aNumber) / step.
	b := (aNumber - (self xPointAt: n1)) / step.
	^a * (self yPointAt: n1) + (b * (self yPointAt: n2)) 
	    + ((a * (a squared - 1) * (coefficients at: n1) 
		    + (b * (b squared - 1) * (coefficients at: n2))) * step squared 
		    / 6)
    ]

    endPointDerivative: aNumber [
	"Defines the end point derivatives.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'initialization'>
	endPointDerivative := aNumber.
	self resetCoefficients
    ]

    computeSecondDerivatives [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'transformation'>
	| size u w s dx inv2dx |
	size := pointCollection size.
	coefficients := Array new: size.
	u := Array new: size - 1.
	startPointDerivative isNil 
	    ifTrue: 
		[coefficients at: 1 put: 0.
		u at: 1 put: 0]
	    ifFalse: 
		[coefficients at: 1 put: -1 / 2.
		s := 1 / ((self xPointAt: 2) x - (self xPointAt: 1) x).
		u at: 1
		    put: 3 * s * (s * ((self yPointAt: size) - (self yPointAt: size - 1)) 
				    - startPointDerivative)].
	2 to: size - 1
	    do: 
		[:n | 
		dx := (self xPointAt: n) - (self xPointAt: n - 1).
		inv2dx := 1 / ((self xPointAt: n + 1) - (self xPointAt: n - 1)).
		s := dx * inv2dx.
		w := 1 / (s * (coefficients at: n - 1) + 2).
		coefficients at: n put: (s - 1) * w.
		u at: n
		    put: ((((self yPointAt: n + 1) - (self yPointAt: n)) 
			    / ((self xPointAt: n + 1) - (self xPointAt: n)) 
				- (((self yPointAt: n) - (self yPointAt: n - 1)) / dx)) * 6 
			    * inv2dx - ((u at: n - 1) * s)) 
			    * w].
	endPointDerivative isNil 
	    ifTrue: [coefficients at: size put: 0]
	    ifFalse: 
		[w := 1 / 2.
		s := 1 / ((self xPointAt: size) - (self xPointAt: size - 1)).
		u at: 1
		    put: 3 * s * (endPointDerivative 
				    - (s * (self yPointAt: size) - (self yPointAt: size - 1))).
		coefficients at: size
		    put: s - (w * (u at: size - 1) / ((coefficients at: size - 1) * w + 1))].
	size - 1 to: 1
	    by: -1
	    do: 
		[:n | 
		coefficients at: n
		    put: (coefficients at: n) * (coefficients at: n + 1) + (u at: n)]
    ]
]



DhbLagrangeInterpolator subclass: DhbNevilleInterpolator [
    | leftErrors rightErrors |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    computeDifference: aNumber at: anInteger1 order: anInteger2 [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 28/5/99"

	<category: 'information'>
	| leftDist rightDist ratio |
	leftDist := (self xPointAt: anInteger1) - aNumber.
	rightDist := (self xPointAt: anInteger1 + anInteger2) - aNumber.
	ratio := ((leftErrors at: anInteger1 + 1) - (rightErrors at: anInteger1)) 
		    / (leftDist - rightDist).
	leftErrors at: anInteger1 put: ratio * leftDist.
	rightErrors at: anInteger1 put: ratio * rightDist
    ]

    defaultSamplePoints [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/5/99"

	<category: 'information'>
	^SortedCollection sortBlock: [:a :b | a x < b x]
    ]

    initializeDifferences: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 28/5/99"

	<category: 'information'>
	| size nearestIndex dist minDist |
	size := pointCollection size.
	leftErrors size = size 
	    ifFalse: 
		[leftErrors := Array new: size.
		rightErrors := Array new: size].
	minDist := ((self xPointAt: 1) - aNumber) abs.
	nearestIndex := 1.
	leftErrors at: 1 put: (self yPointAt: 1).
	rightErrors at: 1 put: leftErrors first.
	2 to: size
	    do: 
		[:n | 
		dist := ((self xPointAt: n) - aNumber) abs.
		dist < minDist 
		    ifTrue: 
			[dist = 0 ifTrue: [^n negated].
			nearestIndex := n.
			minDist := dist].
		leftErrors at: n put: (self yPointAt: n).
		rightErrors at: n put: (leftErrors at: n)].
	^nearestIndex
    ]

    value: aNumber [
	"Compute the value of the Lagrange interpolation polynomial on the receiver's points at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	^(self valueAndError: aNumber) first
    ]

    valueAndError: aNumber [
	"Compute and return the interpolated value of the interpolation Lagranage polynomial
	 and its estimated error.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/4/99"

	<category: 'information'>
	| size nearestIndex answer error |
	nearestIndex := self initializeDifferences: aNumber.
	nearestIndex < 0 
	    ifTrue: [^Array with: (self yPointAt: nearestIndex negated) with: 0].
	answer := leftErrors at: nearestIndex.
	nearestIndex := nearestIndex - 1.
	size := pointCollection size.
	1 to: size - 1
	    do: 
		[:m | 
		1 to: size - m
		    do: 
			[:n | 
			self 
			    computeDifference: aNumber
			    at: n
			    order: m].
		size - m > (2 * nearestIndex) 
		    ifTrue: [error := leftErrors at: nearestIndex + 1]
		    ifFalse: 
			[error := rightErrors at: nearestIndex.
			nearestIndex := nearestIndex - 1].
		answer := answer + error].
	^Array with: answer with: error abs
    ]
]



DhbNevilleInterpolator subclass: DhbBulirschStoerInterpolator [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    computeDifference: aNumber at: anInteger1 order: anInteger2 [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 28/5/99"

	<category: 'information'>
	| diff ratio |
	ratio := ((self xPointAt: anInteger1) - aNumber) 
		    * (rightErrors at: anInteger1) 
			/ ((self xPointAt: anInteger1 + anInteger2) - aNumber).
	diff := ((leftErrors at: anInteger1 + 1) - (rightErrors at: anInteger1)) 
		    / (ratio - (leftErrors at: anInteger1 + 1)).
	rightErrors at: anInteger1 put: (leftErrors at: anInteger1 + 1) * diff.
	leftErrors at: anInteger1 put: ratio * diff
    ]
]

PK
     �Mh@Nuc^  ^    RNG.stUT	 dqXOȉXOux �  �  "======================================================================
|
|   Numerical methods - Random Number Generators
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: DhbMitchellMooreGenerator [
    | randoms lowIndex highIndex |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    UniqueInstance := nil.

    DhbMitchellMooreGenerator class >> constants: anArray lowIndex: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'creation'>
	^super new initialize: anArray lowIndex: anInteger
    ]

    DhbMitchellMooreGenerator class >> default [
	"Private-
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'creation'>
	| congruentialGenerator |
	congruentialGenerator := DhbCongruentialRandomNumberGenerator new.
	^self generateSeeds: congruentialGenerator
    ]

    DhbMitchellMooreGenerator class >> generateSeeds: congruentialGenerator [
	"Private-"

	<category: 'creation'>
	^self 
	    constants: ((1 to: 55) collect: [:n | congruentialGenerator floatValue])
	    lowIndex: 24
    ]

    DhbMitchellMooreGenerator class >> new [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'creation'>
	UniqueInstance isNil ifTrue: [UniqueInstance := self default].
	^UniqueInstance
    ]

    DhbMitchellMooreGenerator class >> reset: anInteger [
	"Reset the unique instance used for the default series"

	<category: 'creation'>
	UniqueInstance := self seed: anInteger
    ]

    DhbMitchellMooreGenerator class >> seed: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/18/00"

	<category: 'creation'>
	| congruentialGenerator |
	congruentialGenerator := DhbCongruentialRandomNumberGenerator 
		    seed: anInteger.
	^self generateSeeds: congruentialGenerator
    ]

    floatValue [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'information'>
	| x |
	x := (randoms at: lowIndex) + (randoms at: highIndex).
	x < 1.0 ifFalse: [x := x - 1.0].
	randoms at: highIndex put: x.
	highIndex := highIndex + 1.
	highIndex > randoms size ifTrue: [highIndex := 1].
	lowIndex := lowIndex + 1.
	lowIndex > randoms size ifTrue: [lowIndex := 1].
	^x
    ]

    integerValue: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'information'>
	^(self floatValue * anInteger) truncated
    ]

    initialize: anArray lowIndex: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/11/00"

	<category: 'initialization'>
	randoms := anArray.
	lowIndex := anInteger.
	highIndex := randoms size.
	^self
    ]
]



Object subclass: DhbCongruentialRandomNumberGenerator [
    | constant modulus multiplicator seed |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    UniqueInstance := nil.

    DhbCongruentialRandomNumberGenerator class >> constant: aNumber1 multiplicator: aNumber2 modulus: aNumber3 [
	"Create a new instance of the receiver with given constants.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new 
	    initialize: aNumber1
	    multiplicator: aNumber2
	    modulus: aNumber3
    ]

    DhbCongruentialRandomNumberGenerator class >> new [
	"Create a new instance of the receiver with D. Knuth's constants.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	UniqueInstance isNil 
	    ifTrue: 
		[UniqueInstance := super new initialize.
		UniqueInstance setSeed: 1].
	^UniqueInstance
    ]

    DhbCongruentialRandomNumberGenerator class >> seed: aNumber [
	"Create a new instance of the receiver with given seed
	 using D. Knuth's constants.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^(super new)
	    initialize;
	    setSeed: aNumber;
	    yourself
    ]

    floatValue [
	"Answer the next pseudo-random value between 0 and 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self value asFloatD / modulus
    ]

    integerValue: anInteger [
	"Answer a random integer between 0 and the anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self value \\ (anInteger * 1000) // 1000
    ]

    value [
	"Answer the next pseudo-random value.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	seed := (seed * multiplicator + constant) \\ modulus.
	^seed
    ]

    initialize [
	"Private - Initializes the constants of the receiver with D. Knuth's constants.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	self 
	    initialize: 2718281829.0
	    multiplicator: 3141592653.0
	    modulus: 4294967296.0
    ]

    initialize: aNumber1 multiplicator: aNumber2 modulus: aNumber3 [
	"Private - Initializes the constants needed by the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	constant := aNumber1.
	modulus := aNumber2.
	multiplicator := aNumber3.
	self setSeed: 1
    ]

    setSeed: aNumber [
	"Set the seed of the receiver to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	seed := aNumber
    ]
]

PK
     �[h@��yt  t    package.xmlUT	 ȉXOȉXOux �  �  <package>
  <name>DhbNumericalMethods</name>
  <namespace>Dhb</namespace>
  <test>
    <namespace>Dhb</namespace>
    <prereq>DhbNumericalMethods</prereq>
    <prereq>SUnit</prereq>
    <sunit>Dhb.DhbTestCase*</sunit>
    <filein>NumericsTests.st</filein>
  </test>

  <filein>Basic.st</filein>
  <filein>Statistics.st</filein>
  <filein>RNG.st</filein>
  <filein>Approximation.st</filein>
  <filein>Matrixes.st</filein>
  <filein>Functions.st</filein>
  <filein>Optimization.st</filein>
  <filein>Distributions.st</filein>
  <filein>Integration.st</filein>
  <filein>NumericsAdds.st</filein>
  <file>ChangeLog</file>
</package>PK
     �Mh@1X��a �a   Distributions.stUT	 dqXOȉXOux �  �  "======================================================================
|
|   Numerical methods - Probability densities
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: DhbProbabilityDensity [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbProbabilityDensity class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 Default returns nil (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'creation'>
	^nil
    ]

    DhbProbabilityDensity class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Unknown distribution'
    ]

    distributionFunction [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'creation'>
	^DhbProbabilityDistributionFunction density: self
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'display'>
	| params |
	aStream nextPutAll: self class distributionName.
	(params := self parameters) notNil 
	    ifTrue: 
		[| first |
		first := true.
		aStream nextPut: $(.
		params do: 
			[:each | 
			first ifTrue: [first := false] ifFalse: [aStream nextPut: $,].
			aStream space.
			each printOn: aStream].
		aStream nextPut: $)]
    ]

    acceptanceBetween: aNumber1 and: aNumber2 [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value larger than aNumber 1 and lower than or equal to aNumber2.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(self distributionValue: aNumber2) - (self distributionValue: aNumber1)
    ]

    approximatedValueAndGradient: aNumber [
	"Private - gradients an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 The gradient is computed by approximation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	| delta parameters dp gradient n |
	parameters := self parameters.
	n := parameters size.
	dp := self value: aNumber.
	delta := Array new: n.
	delta atAllPut: 0.
	gradient := DhbVector new: n.
	1 to: n
	    do: 
		[:k | 
		delta at: k put: (parameters at: k) * 0.0001.
		self changeParametersBy: delta.
		gradient at: k put: ((self value: aNumber) - dp) / (delta at: k).
		delta at: k put: (delta at: k) negated.
		k > 1 ifTrue: [delta at: k - 1 put: 0]].
	self changeParametersBy: delta.
	^Array with: dp with: gradient
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	self subclassResponsibility
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self subclassResponsibility
    ]

    inverseDistributionValue: aNumber [
	"Answer the number whose distribution value is aNumber.
	 NOTE: Subclass MUST NOT overwrite this method.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(aNumber between: 0 and: 1) 
	    ifTrue: [self privateInverseDistributionValue: aNumber]
	    ifFalse: [self error: 'Illegal argument for inverse distribution value']
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 Undefined. Must be implemented by subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^nil
    ]

    parameters [
	"Returns an Array containing the parameters of the distribution.
	 It is used to print out the distribution and for fitting.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^self subclassResponsibility
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose distribution is aNumber.
	 NOTE: Subclass may overwrite this method for faster computation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(DhbNewtonZeroFinder 
	    function: [:x | (self distributionValue: x) - aNumber]
	    derivative: self)
	    initialValue: self average / (1 - aNumber);
	    evaluate
    ]

    random [
	"Answer a random number distributed according to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self 
	    privateInverseDistributionValue: DhbMitchellMooreGenerator new floatValue
    ]

    skewness [
	"Answer the skewness of the receiver.
	 Undefined. Must be implemented by subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^nil
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 NOTE: At least one of the methods variance or standardDeviation must be implemented by the subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self variance sqrt
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	self subclassResponsibility
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	^self approximatedValueAndGradient: aNumber
    ]

    variance [
	"Answer the variance of the receiver.
	 NOTE: At least one of the methods variance or standardDeviation must be implemented by the subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self standardDeviation squared
    ]

    changeParametersBy: aVector [
	<category: 'transformation'>
	self subclassResponsibility
    ]
]



DhbProbabilityDensity subclass: DhbProbabilityDensityWithUnknownDistribution [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    acceptanceBetween: aNumber1 and: aNumber2 [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value larger than aNumber 1 and lower than or equal to aNumber2.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(DhbRombergIntegrator 
	    new: self
	    from: aNumber1
	    to: aNumber2) evaluate
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 This general purpose routine uses numerical integration.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(DhbRombergIntegrator 
	    new: self
	    from: self lowestValue
	    to: aNumber) evaluate
    ]

    lowestValue [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/18/00"

	<category: 'information'>
	^0
    ]
]



DhbProbabilityDensity subclass: DhbWeibullDistribution [
    | alpha beta norm |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbWeibullDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| average xMin xMax accMin accMax |
	aHistogram minimum < 0 ifTrue: [^nil].
	average := aHistogram average.
	xMin := (aHistogram minimum + average) / 2.
	accMin := (aHistogram countsUpTo: xMin) / aHistogram totalCount.
	xMax := (aHistogram maximum + average) / 2.
	accMax := (aHistogram countsUpTo: xMax) / aHistogram totalCount.
	^
	[self 
	    solve: xMin
	    acc: accMin
	    upper: xMax
	    acc: accMax] 
		on: Error
		do: [:signal | signal return: nil]
    ]

    DhbWeibullDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbWeibullDistribution class >> shape: aNumber1 scale: aNumber2 [
	"Create an instance of the receiver with given shape and scale parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 scale: aNumber2
    ]

    DhbWeibullDistribution class >> solve: lowX acc: lowAcc upper: highX acc: highAcc [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'creation'>
	| lowLnAcc highLnAcc deltaLnAcc lowLnX highLnX |
	lowLnAcc := (1 - lowAcc) ln negated ln.
	highLnAcc := (1 - highAcc) ln negated ln.
	deltaLnAcc := highLnAcc - lowLnAcc.
	lowLnX := lowX ln.
	highLnX := highX ln.
	^self shape: deltaLnAcc / (highLnX - lowLnX)
	    scale: ((highLnAcc * lowLnX - (lowLnAcc * highLnX)) / deltaLnAcc) exp
    ]

    DhbWeibullDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Weibull distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(1 / alpha) gamma * beta / alpha
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 Assumes that the value of the receiver is 0 for x < 0.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^aNumber > 0 
	    ifTrue: [1 - (aNumber / beta raisedTo: alpha) negated exp]
	    ifFalse: [0]
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: alpha with: beta
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(aNumber / beta raisedTo: alpha) negated exp 
	    * (aNumber raisedTo: alpha - 1) * norm
    ]

    variance [
	"Answer the variance of the receiver.
	 NOTE: At least one of the methods variance or standardDeviation must be implemented by the subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^beta squared / alpha 
	    * ((2 / alpha) gamma * 2 - ((1 / alpha) gamma squared / alpha))
    ]

    computeNorm [
	"Private - Compute the norm of the receiver because its parameters have changed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'initialization'>
	norm := alpha / (beta raisedTo: alpha)
    ]

    initialize: aNumber1 scale: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	(aNumber1 > 0 and: [aNumber2 > 0]) 
	    ifFalse: [self error: 'Illegal distribution parameters'].
	alpha := aNumber1.
	beta := aNumber2.
	self computeNorm.
	^self
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose acceptance is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	^((1 - aNumber) ln negated raisedTo: 1 / alpha) * beta
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	alpha := alpha + (aVector at: 1).
	beta := beta + (aVector at: 2).
	self computeNorm
    ]
]



DhbProbabilityDensity subclass: DhbExponentialDistribution [
    | beta |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbExponentialDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| mu |
	aHistogram minimum < 0 ifTrue: [^nil].
	mu := aHistogram average.
	^mu > 0 ifTrue: [self scale: aHistogram average] ifFalse: [nil]
    ]

    DhbExponentialDistribution class >> new [
	"Create a new instance of the receiver with scale parameter 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: 1
    ]

    DhbExponentialDistribution class >> scale: aNumber [
	"Create a new instance of the receiver with given scale parameter.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber
    ]

    DhbExponentialDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Exponential distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^beta
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^[1 - (aNumber / beta negated) exp] on: Error
	    do: [:signal | signal return: 0]
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^6
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: beta
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose acceptance is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(1 - aNumber) ln negated * beta
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^DhbMitchellMooreGenerator new floatValue ln * beta negated
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^2
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^beta
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^[(aNumber / beta) negated exp / beta] on: Error
	    do: [:signal | signal return: 0]
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'information'>
	| dp |
	dp := self value: aNumber.
	^Array with: dp with: (DhbVector with: (aNumber / beta - 1) * dp / beta)
    ]

    initialize: aNumber [
	"Private - Set the scale parameter of the receiver to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	aNumber > 0 ifFalse: [self error: 'Illegal distribution parameters'].
	beta := aNumber.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'transformation'>
	beta := beta + (aVector at: 1)
    ]
]



DhbProbabilityDensity subclass: DhbBetaDistribution [
    | alpha1 alpha2 gamma1 gamma2 logNorm incompleteBetaFunction |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbBetaDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'creation'>
	| average variance a b |
	(aHistogram minimum < 0 or: [aHistogram maximum > 1]) ifTrue: [^nil].
	average := aHistogram average.
	variance := aHistogram variance.
	a := ((1 - average) / variance - 1) * average.
	a > 0 ifFalse: [^nil].
	b := (1 / average - 1) * a.
	b > 0 ifFalse: [^nil].
	^self shape: a shape: b
    ]

    DhbBetaDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbBetaDistribution class >> shape: aNumber1 shape: aNumber2 [
	"Create an instance of the receiver with given shape parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 shape: aNumber2
    ]

    DhbBetaDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Beta distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^alpha1 / (alpha1 + alpha2)
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	incompleteBetaFunction isNil 
	    ifTrue: 
		[incompleteBetaFunction := DhbIncompleteBetaFunction shape: alpha1
			    shape: alpha2].
	^incompleteBetaFunction value: aNumber
    ]

    firstGammaDistribution [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	gamma1 isNil 
	    ifTrue: [gamma1 := DhbGammaDistribution shape: alpha1 scale: 1].
	^gamma1
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^3 * (alpha1 + alpha2 + 1) 
	    * (((alpha1 + alpha2) squared * 2 
		    + ((alpha1 + alpha2 - 6) * alpha1 * alpha2)) 
			/ ((alpha1 + alpha2 + 2) * (alpha1 + alpha2 + 3) * alpha1 * alpha2)) 
		- 3
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: alpha1 with: alpha2
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| r |
	r := self firstGammaDistribution random.
	^r / (self secondGammaDistribution random + r)
    ]

    secondGammaDistribution [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	gamma2 isNil 
	    ifTrue: [gamma2 := DhbGammaDistribution shape: alpha2 scale: 1].
	^gamma2
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^(alpha1 + alpha2 + 1) sqrt * 2 * (alpha2 - alpha1) 
	    / ((alpha1 * alpha2) sqrt * (alpha1 + alpha2 + 2))
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(aNumber > 0 and: [aNumber < 1]) 
	    ifTrue: 
		[(aNumber ln * (alpha1 - 1) + ((1 - aNumber) ln * (alpha2 - 1)) + logNorm) 
		    exp]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^alpha1 * alpha2 / ((alpha1 + alpha2) squared * (alpha1 + alpha2 + 1))
    ]

    computeNorm [
	"Private - Compute the norm of the receiver because its parameters have changed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	logNorm := (alpha1 + alpha2) logGamma - alpha1 logGamma - alpha2 logGamma
    ]

    initialize: aNumber1 shape: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	(aNumber1 > 0 and: [aNumber2 > 0]) 
	    ifFalse: [self error: 'Illegal distribution parameters'].
	alpha1 := aNumber1.
	alpha2 := aNumber2.
	self computeNorm.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	alpha1 := alpha1 + (aVector at: 1).
	alpha2 := alpha2 + (aVector at: 2).
	self computeNorm.
	gamma1 := nil.
	gamma2 := nil.
	incompleteBetaFunction := nil
    ]
]



DhbProbabilityDensity subclass: DhbUniformDistribution [
    | lowLimit highLimit |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbUniformDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'public'>
	^'Uniform distribution'
    ]

    DhbUniformDistribution class >> from: aNumber1 to: aNumber2 [
	"Create a new instance of the receiver with given limits.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'public'>
	^super new initialize: aNumber1 to: aNumber2
    ]

    DhbUniformDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 Default returns nil (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'public'>
	| b c |
	b := aHistogram standardDeviation * 1.73205080756888.	"12 sqrt / 2"
	b = 0 ifTrue: [^nil].
	c := aHistogram average.
	^self from: c - b to: c + b
    ]

    DhbUniformDistribution class >> new [
	"Create a new instance of the receiver with limits 0 and 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'public'>
	^self from: 0 to: 1
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(highLimit + lowLimit) / 2
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	aNumber < lowLimit ifTrue: [^0].
	^aNumber < highLimit 
	    ifTrue: [(aNumber - lowLimit) / (highLimit - lowLimit)]
	    ifFalse: [1]
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^-12 / 10
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: lowLimit with: highLimit
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose acceptance is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(highLimit - lowLimit) * aNumber + lowLimit
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^0
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(highLimit - lowLimit) / 3.46410161513774	"12 sqrt"
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(aNumber between: lowLimit and: highLimit) 
	    ifTrue: [1 / (highLimit - lowLimit)]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(highLimit - lowLimit) squared / 12
    ]

    initialize: aNumber1 to: aNumber2 [
	"Private - Defines the limits of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	aNumber1 < aNumber2 
	    ifFalse: [self error: 'Illegal distribution parameters'].
	lowLimit := aNumber1.
	highLimit := aNumber2.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	lowLimit := lowLimit + (aVector at: 1).
	highLimit := highLimit + (aVector at: 2)
    ]
]



DhbProbabilityDensity subclass: DhbFisherTippettDistribution [
    | alpha beta |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbFisherTippettDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| beta |
	beta := aHistogram standardDeviation.
	beta = 0 ifTrue: [^nil].
	beta := beta * (6 sqrt / FloatD pi).
	^self shape: aHistogram average - (0.5772156649 * beta) scale: beta
    ]

    DhbFisherTippettDistribution class >> new [
	"Create a standard version of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self shape: 0 scale: 1
    ]

    DhbFisherTippettDistribution class >> shape: aNumber1 scale: aNumber2 [
	"Create an instance of the receiver with given shape and scale parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 scale: aNumber2
    ]

    DhbFisherTippettDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Fisher-Tippett distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^0.5772566490000001 * beta + alpha
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	alpha := alpha + (aVector at: 1).
	beta := beta + (aVector at: 2)
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 14/4/99"

	<category: 'information'>
	| arg |
	arg := (aNumber - alpha) / beta.
	arg := arg < DhbFloatingPointMachine new largestExponentArgument negated 
		    ifTrue: [^0]
		    ifFalse: [arg negated exp].
	^arg > DhbFloatingPointMachine new largestExponentArgument 
	    ifTrue: [1]
	    ifFalse: [arg negated exp]
    ]

    integralFrom: aNumber1 to: aNumber2 [
	"Private - Compute the integral of the receiver from aNumber1 to aNumber2.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 14/4/99"

	<category: 'information'>
	^(DhbRombergIntegrator 
	    new: self
	    from: aNumber1
	    to: aNumber2) evaluate
    ]

    integralUpTo: aNumber [
	"Private - Compute the integral of the receiver from -infinity to aNumber.
	 aNumber must be below 0 (no checking!!).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 14/4/99"

	<category: 'information'>
	^(DhbRombergIntegrator 
	    new: [:x | x = 0 ifTrue: [0] ifFalse: [(self value: 1 / x) / x squared]]
	    from: 1 / aNumber
	    to: 0) evaluate
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^2.4
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: alpha with: beta
    ]

    random [
	"Answer a random number distributed according to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/4/99"

	<category: 'information'>
	| t |
	
	[t := DhbMitchellMooreGenerator new floatValue ln negated.
	t > 0] 
		whileFalse: [].
	^t ln negated * beta + alpha
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^1.3
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^FloatD pi * beta / 6 sqrt
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	| arg |
	arg := (aNumber - alpha) / beta.
	arg := arg > DhbFloatingPointMachine new largestExponentArgument 
		    ifTrue: [^0]
		    ifFalse: [arg negated exp + arg].
	^arg > DhbFloatingPointMachine new largestExponentArgument 
	    ifTrue: [0]
	    ifFalse: [arg negated exp / beta]
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	| dp dy y |
	dp := self value: aNumber.
	y := (aNumber - alpha) / beta.
	dy := y negated exp - 1.
	^Array with: dp
	    with: (DhbVector with: dy * dp / beta negated
		    with: dp * (y * dy + 1) / beta negated)
    ]

    initialize: aNumber1 scale: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'initialization'>
	aNumber2 > 0 ifFalse: [self error: 'Illegal distribution parameters'].
	alpha := aNumber1.
	beta := aNumber2.
	^self
    ]
]



DhbProbabilityDensityWithUnknownDistribution subclass: DhbLogNormalDistribution [
    | normalDistribution |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLogNormalDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| average variance sigma2 |
	aHistogram minimum < 0 ifTrue: [^nil].
	average := aHistogram average.
	average > 0 ifFalse: [^nil].
	variance := aHistogram variance.
	sigma2 := (variance / average squared + 1) ln.
	sigma2 > 0 ifFalse: [^nil].
	^self new: average ln - (sigma2 * 5) sigma: sigma2 sqrt
    ]

    DhbLogNormalDistribution class >> new [
	"Create a new instance of the receiver with mu=0 and sigma=1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self new: 0 sigma: 1
    ]

    DhbLogNormalDistribution class >> new: aNumber1 sigma: aNumber2 [
	"Create a new instance of the receiver with given mu and sigma.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 sigma: aNumber2
    ]

    DhbLogNormalDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Log normal distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(normalDistribution variance * 0.5 + normalDistribution average) exp
    ]

    fourthCentralMoment [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 24/6/99"

	<category: 'information'>
	| y x |
	y := normalDistribution average exp.
	x := normalDistribution variance exp.
	^y squared squared * x squared 
	    * (((x squared * x - 4) * x squared + 6) * x - 3)
    ]

    kurtosis [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| x |
	x := normalDistribution variance exp.
	^((x + 2) * x + 3) * x squared - 6
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^normalDistribution parameters
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^normalDistribution random exp
    ]

    skewness [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| x |
	x := normalDistribution variance exp.
	^(x - 1) sqrt * (x + 2)
    ]

    thirdCentralMoment [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 24/6/99"

	<category: 'information'>
	| y x |
	y := normalDistribution average exp.
	x := normalDistribution variance exp.
	^y squared * y * (x raisedTo: 3 / 2) * ((x squared negated + 3) * x - 2)
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^aNumber > 0 
	    ifTrue: [(normalDistribution value: aNumber ln) / aNumber]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(normalDistribution average * 2 + normalDistribution variance) exp 
	    * (normalDistribution variance exp - 1)
    ]

    initialize: aNumber1 sigma: aNumber2 [
	"Private - Defines the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	normalDistribution := DhbNormalDistribution new: aNumber1 sigma: aNumber2.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	normalDistribution changeParametersBy: aVector
    ]
]



DhbProbabilityDensity subclass: DhbCauchyDistribution [
    | mu beta |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbCauchyDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	^self shape: aHistogram average
	    scale: 4 * aHistogram variance 
		    / (FloatD pi * (aHistogram maximum squared + aHistogram minimum squared)) 
			    sqrt
    ]

    DhbCauchyDistribution class >> new [
	"Create an instance of the receiver with center 0 and scale 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self shape: 0 scale: 1
    ]

    DhbCauchyDistribution class >> shape: aNumber1 scale: aNumber2 [
	"Create an instance of the receiver with given center and scale parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 scale: aNumber2
    ]

    DhbCauchyDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Cauchy distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^mu
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 Assumes that the value of the receiver is 0 for x < 0.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^((aNumber - mu) / beta) arcTan / FloatD pi + (1 / 2)
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: mu with: beta
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose acceptance is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^((aNumber - (1 / 2)) * FloatD pi) tan * beta + mu
    ]

    standardDeviation [
	"The standard deviation of the receiver is not defined.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^nil
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^beta / (FloatD pi * (beta squared + (aNumber - mu) squared))
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	| dp denominator |
	dp := self value: aNumber.
	denominator := 1 / ((aNumber - mu) squared + beta squared).
	^Array with: dp
	    with: (DhbVector with: 2 * dp * (aNumber - mu) * denominator
		    with: dp * (1 / beta - (2 * beta * denominator)))
    ]

    variance [
	"The variance of the receiver is not defined.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^nil
    ]

    initialize: aNumber1 scale: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	mu := aNumber1.
	beta := aNumber2.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	mu := mu + (aVector at: 1).
	beta := beta + (aVector at: 2)
    ]
]



Object subclass: DhbProbabilityDistributionFunction [
    | probabilityDensity |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbProbabilityDistributionFunction class >> density: aProbabilityDensity [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'creation'>
	^self new initialize: aProbabilityDensity
    ]

    value: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^probabilityDensity distributionValue: aNumber
    ]

    initialize: aProbabilityDensity [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'initialization'>
	probabilityDensity := aProbabilityDensity.
	^self
    ]
]



DhbProbabilityDensity subclass: DhbGammaDistribution [
    | alpha beta norm randomCoefficients incompleteGammaFunction |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbGammaDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| alpha beta |
	aHistogram minimum < 0 ifTrue: [^nil].
	alpha := aHistogram average.
	beta := aHistogram variance / alpha.
	^[self shape: alpha / beta scale: beta] on: Error
	    do: [:signal | signal return: nil]
    ]

    DhbGammaDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbGammaDistribution class >> shape: aNumber1 scale: aNumber2 [
	"Create an instance of the receiver with given shape and scale parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 scale: aNumber2
    ]

    DhbGammaDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Gamma distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^alpha * beta
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self incompleteGammaFunction value: aNumber / beta
    ]

    incompleteGammaFunction [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	incompleteGammaFunction isNil 
	    ifTrue: [incompleteGammaFunction := DhbIncompleteGammaFunction shape: alpha].
	^incompleteGammaFunction
    ]

    initializeRandomCoefficientsForLargeAlpha [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	| a b q d |
	a := 1 / (2 * alpha - 1) sqrt.
	b := alpha - 4 ln.
	q := 1 / a + alpha.
	d := 4.5 ln + 1.
	^Array 
	    with: a
	    with: b
	    with: q
	    with: d
    ]

    initializeRandomCoefficientsForSmallAlpha [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	| e |
	e := 1 exp.
	^(e + alpha) / e
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^6 / alpha
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: alpha with: beta
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(alpha > 1 
	    ifTrue: [self randomForLargeAlpha]
	    ifFalse: [self randomForSmallAlpha]) * beta
    ]

    randomCoefficientsForLargeAlpha [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	randomCoefficients isNil 
	    ifTrue: [randomCoefficients := self initializeRandomCoefficientsForLargeAlpha].
	^randomCoefficients
    ]

    randomCoefficientsForSmallAlpha [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	randomCoefficients isNil 
	    ifTrue: [randomCoefficients := self initializeRandomCoefficientsForSmallAlpha].
	^randomCoefficients
    ]

    randomForLargeAlpha [
	"Private - Generate a random number distributed according to the receiver
	 when alpha > 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	[true] whileTrue: 
		[| u1 u2 c v y z w |
		u1 := DhbMitchellMooreGenerator new floatValue.
		u2 := DhbMitchellMooreGenerator new floatValue.
		c := self randomCoefficientsForLargeAlpha.
		v := (u1 / (1 - u1)) ln * (c at: 1).
		y := v exp * alpha.
		z := u1 squared * u2.
		w := (c at: 3) * v + (c at: 2) - y.
		(c at: 4) + w >= (4.5 * z) ifTrue: [^y].
		z ln <= w ifTrue: [^y]]
    ]

    randomForSmallAlpha [
	"Private - Generate a random number distributed according to the receiver
	 when alpha < 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	[true] whileTrue: 
		[| p |
		p := DhbMitchellMooreGenerator new floatValue 
			    * self randomCoefficientsForSmallAlpha.
		p > 1 
		    ifTrue: 
			[| y |
			y := ((self randomCoefficientsForSmallAlpha - p) / alpha) ln negated.
			DhbMitchellMooreGenerator new floatValue <= (y raisedTo: alpha - 1) 
			    ifTrue: [^y]]
		    ifFalse: 
			[| y |
			y := p raisedTo: 1 / alpha.
			DhbMitchellMooreGenerator new floatValue <= y negated exp ifTrue: [^y]]]
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^2 / alpha sqrt
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^aNumber > 0 
	    ifTrue: [(aNumber ln * (alpha - 1) - (aNumber / beta) - norm) exp]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^beta squared * alpha
    ]

    computeNorm [
	"Private - Compute the norm of the receiver because its parameters have changed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	norm := beta ln * alpha + alpha logGamma
    ]

    initialize: aNumber1 scale: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	(aNumber1 > 0 and: [aNumber2 > 0]) 
	    ifFalse: [self error: 'Illegal distribution parameters'].
	alpha := aNumber1.
	beta := aNumber2.
	self computeNorm.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	alpha := alpha + (aVector at: 1).
	beta := beta + (aVector at: 2).
	self computeNorm.
	incompleteGammaFunction := nil.
	randomCoefficients := nil
    ]
]



DhbProbabilityDensity subclass: DhbTriangularDistribution [
    | lowLimit highLimit peak |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbTriangularDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 Default returns nil (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'creation'>
	| b c |
	b := aHistogram standardDeviation * 1.73205080756888.	"12 sqrt / 2"
	b = 0 ifTrue: [^nil].
	c := aHistogram average.
	^self 
	    new: c
	    from: c - b
	    to: c + b
    ]

    DhbTriangularDistribution class >> new [
	"Create an instance of the receiver with peak at 1/2 and limits 0 and 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'creation'>
	^self 
	    new: 1 / 2
	    from: 0
	    to: 1
    ]

    DhbTriangularDistribution class >> new: aNumber1 from: aNumber2 to: aNumber3 [
	"Create an instance of the receiver with peak at aNumber1 and limits aNumber2 and aNumber3.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new 
	    initialize: aNumber1
	    from: aNumber2
	    to: aNumber3
    ]

    DhbTriangularDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Triangular distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(lowLimit + peak + highLimit) / 3
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| norm |
	^(aNumber between: lowLimit and: highLimit) 
	    ifTrue: 
		[aNumber < peak 
		    ifTrue: 
			[norm := (highLimit - lowLimit) * (peak - lowLimit).
			(aNumber - lowLimit) squared / norm]
		    ifFalse: 
			[aNumber > peak 
			    ifTrue: 
				[norm := (highLimit - lowLimit) * (highLimit - peak).
				1 - ((highLimit - aNumber) squared / norm)]
			    ifFalse: [(peak - lowLimit) / (highLimit - lowLimit)]]]
	    ifFalse: [0]
    ]

    inverseAcceptanceAfterPeak: aNumber [
	"Private - Compute inverse acceptance function in the region after the peak.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^highLimit 
	    - ((1 - aNumber) * (highLimit - lowLimit) * (highLimit - peak)) sqrt
    ]

    inverseAcceptanceBeforePeak: aNumber [
	"Private - Compute inverse acceptance function in the region before the peak.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^(aNumber * (highLimit - lowLimit) * (peak - lowLimit)) sqrt + lowLimit
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^-6 / 10
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array 
	    with: lowLimit
	    with: highLimit
	    with: peak
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose acceptance is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(peak - lowLimit) / (highLimit - lowLimit) > aNumber 
	    ifTrue: [self inverseAcceptanceBeforePeak: aNumber]
	    ifFalse: [self inverseAcceptanceAfterPeak: aNumber]
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^((lowLimit squared * lowLimit + (peak squared * peak) 
	    + (highLimit squared * highLimit)) / 135 
	    - ((lowLimit squared * peak + (lowLimit squared * highLimit) 
		    + (peak squared * lowLimit) + (peak squared * highLimit) 
		    + (highLimit squared * lowLimit) + (highLimit squared * peak)) 
		    / 90) 
		+ (2 * lowLimit * peak * highLimit / 45)) 
		/ (self standardDeviation raisedToInteger: 3)
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| norm |
	^(aNumber between: lowLimit and: highLimit) 
	    ifTrue: 
		[aNumber < peak 
		    ifTrue: 
			[norm := (highLimit - lowLimit) * (peak - lowLimit).
			2 * (aNumber - lowLimit) / norm]
		    ifFalse: 
			[aNumber > peak 
			    ifTrue: 
				[norm := (highLimit - lowLimit) * (highLimit - peak).
				2 * (highLimit - aNumber) / norm]
			    ifFalse: [2 / (highLimit - lowLimit)]]]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(lowLimit squared + peak squared + highLimit squared - (lowLimit * peak) 
	    - (lowLimit * highLimit) - (peak * highLimit)) 
	    / 18
    ]

    initialize: aNumber1 from: aNumber2 to: aNumber3 [
	"Private - Defines the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	(aNumber2 < aNumber3 and: [aNumber1 between: aNumber2 and: aNumber3]) 
	    ifFalse: [self error: 'Illegal distribution parameters'].
	peak := aNumber1.
	lowLimit := aNumber2.
	highLimit := aNumber3.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	lowLimit := lowLimit + (aVector at: 1).
	highLimit := highLimit + (aVector at: 2).
	peak := peak + (aVector at: 3)
    ]
]



DhbProbabilityDensity subclass: DhbLaplaceDistribution [
    | mu beta |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLaplaceDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	^self shape: aHistogram average scale: (aHistogram variance / 2) sqrt
    ]

    DhbLaplaceDistribution class >> new [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'creation'>
	^self shape: 0 scale: 1
    ]

    DhbLaplaceDistribution class >> shape: aNumber1 scale: aNumber2 [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'creation'>
	^super new initialize: aNumber1 scale: aNumber2
    ]

    DhbLaplaceDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Laplace distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^mu
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^3
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: mu with: beta
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| r |
	r := DhbMitchellMooreGenerator new floatValue ln * beta negated.
	^DhbMitchellMooreGenerator new floatValue > 0.5 
	    ifTrue: [mu + r]
	    ifFalse: [mu - r]
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^0
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^beta * 2 sqrt
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^((aNumber - mu) / beta) abs negated exp / (2 * beta)
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	| dp |
	dp := self value: aNumber.
	^Array with: dp
	    with: (DhbVector with: (aNumber - mu) sign * dp / beta
		    with: ((aNumber - mu) abs / beta - 1) * dp / beta)
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	^aNumber > mu 
	    ifTrue: [1 - (((aNumber - mu) / beta) negated exp / 2)]
	    ifFalse: [((aNumber - mu) / beta) exp / 2]
    ]

    initialize: aNumber1 scale: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	mu := aNumber1.
	beta := aNumber2.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'transformation'>
	mu := mu + (aVector at: 1).
	beta := beta + (aVector at: 2)
    ]
]



DhbProbabilityDensity subclass: DhbFisherSnedecorDistribution [
    | dof1 dof2 norm chiSquareDistribution1 chiSquareDistribution2 incompleteBetaFunction |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbFisherSnedecorDistribution class >> degreeOfFreedom: anInteger1 degreeOfFreedom: anInteger2 [
	"Create a new instance of the receiver with given degrees of freedom.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'creation'>
	^super new initialize: anInteger1 and: anInteger2
    ]

    DhbFisherSnedecorDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'creation'>
	| n1 n2 a |
	aHistogram minimum < 0 ifTrue: [^nil].
	n2 := (2 / (1 - (1 / aHistogram average))) rounded.
	n2 > 0 ifFalse: [^nil].
	a := (n2 - 2) * (n2 - 4) * aHistogram variance / (n2 squared * 2).
	n1 := (7 * (n2 - 2) / (1 - a)) rounded.
	^n1 > 0 
	    ifTrue: [self degreeOfFreedom: n1 degreeOfFreedom: n2]
	    ifFalse: [nil]
    ]

    DhbFisherSnedecorDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbFisherSnedecorDistribution class >> test: aStatisticalMoment1 with: aStatisticalMoment2 [
	"Perform a consistency Fisher test (or F-test) on the variances of two statistical moments ( or histograms).
	 Answer the probability of passing the test.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'creation'>
	^(self class degreeOfFreedom: aStatisticalMoment1 count
	    degreeOfFreedom: aStatisticalMoment2 count) 
		distributionValue: aStatisticalMoment1 variance 
			/ aStatisticalMoment2 variance
    ]

    DhbFisherSnedecorDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Fisher-Snedecor distribution'
    ]

    average [
	"Answer the average of the receiver.
	 Undefined if dof2 is smaller than 3.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^dof2 > 2 ifTrue: [dof2 / (dof2 - 2)] ifFalse: [nil]
    ]

    confidenceLevel: aNumber [
	"Answer the probability in percent of finding a value
	 distributed according to the receiver outside of the
	 interval [ 1/aNumber, aNumber].
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	aNumber < 0 
	    ifTrue: [self error: 'Confidence level argument must be positive'].
	^(1 - (self acceptanceBetween: aNumber reciprocal and: aNumber)) * 100
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	^1 - (self incompleteBetaFunction value: dof2 / (aNumber * dof1 + dof2))
    ]

    incompleteBetaFunction [
	"Private - Answers the incomplete beta function used to compute
	 the symmetric acceptance integral of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	incompleteBetaFunction isNil 
	    ifTrue: 
		[incompleteBetaFunction := DhbIncompleteBetaFunction shape: dof2 / 2
			    shape: dof1 / 2].
	^incompleteBetaFunction
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: dof1 with: dof2
    ]

    random [
	"Answer a random number distributed according to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	chiSquareDistribution1 isNil 
	    ifTrue: 
		[chiSquareDistribution1 := DhbChiSquareDistribution degreeOfFreedom: dof1.
		chiSquareDistribution2 := DhbChiSquareDistribution degreeOfFreedom: dof2].
	^chiSquareDistribution1 random * dof2 
	    / (chiSquareDistribution2 random * dof1)
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^aNumber > 0 
	    ifTrue: 
		[(norm + (aNumber ln * (dof1 / 2 - 1)) 
		    - ((aNumber * dof1 + dof2) ln * ((dof1 + dof2) / 2))) exp]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 Undefined if dof2 is smaller than 5.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^dof2 > 4 
	    ifTrue: 
		[dof2 squared * 2 * (dof1 + dof2 - 2) 
		    / ((dof2 - 2) squared * dof1 * (dof2 - 4))]
	    ifFalse: [nil]
    ]

    computeNorm [
	"Private - Compute the norm of the receiver because its parameters have changed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	norm := dof1 ln * (dof1 / 2) + (dof2 ln * (dof2 / 2)) 
		    - (dof1 / 2 logBeta: dof2 / 2)
    ]

    initialize: anInteger1 and: anInteger2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	dof1 := anInteger1.
	dof2 := anInteger2.
	self computeNorm.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	dof1 := dof1 + (aVector at: 1) max: 1.
	dof2 := dof2 + (aVector at: 2) max: 1.
	self computeNorm.
	chiSquareDistribution1 := nil.
	chiSquareDistribution2 := nil.
	incompleteBetaFunction := nil
    ]
]



DhbGammaDistribution subclass: DhbChiSquareDistribution [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbChiSquareDistribution class >> degreeOfFreedom: anInteger [
	"Create a new instance of the receiver with given degree of freedom.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^anInteger > 40 
	    ifTrue: [DhbAsymptoticChiSquareDistribution degreeOfFreedom: anInteger]
	    ifFalse: [super shape: anInteger / 2 scale: 2]
    ]

    DhbChiSquareDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| dof |
	aHistogram minimum < 0 ifTrue: [^nil].
	dof := aHistogram average rounded.
	^dof > 0 
	    ifTrue: [self degreeOfFreedom: aHistogram average rounded]
	    ifFalse: [nil]
    ]

    DhbChiSquareDistribution class >> shape: aNumber1 scale: aNumber2 [
	"Create an instance of the receiver with given shape and scale parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbChiSquareDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Chi square distribution'
    ]

    confidenceLevel: aNumber [
	"Answer the probability in percent of finding a chi square value
	 distributed according to the receiver larger than aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	^(1 - (self distributionValue: aNumber)) * 100
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: alpha * 2
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 13/4/99"

	<category: 'transformation'>
	super changeParametersBy: (Array with: aVector first / 2 with: 0)
    ]
]



DhbProbabilityDensity subclass: DhbAsymptoticChiSquareDistribution [
    | degreeOfFreedom reducedDOF normalDistribution |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbAsymptoticChiSquareDistribution class >> degreeOfFreedom: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'creation'>
	^super new initialize: anInteger
    ]

    DhbAsymptoticChiSquareDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbAsymptoticChiSquareDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'information'>
	^'Chi square distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^degreeOfFreedom
    ]

    confidenceLevel: aNumber [
	"Answer the probability in percent of finding a chi square value
	 distributed according to the receiver larger than aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	^(1 - (self distributionValue: aNumber)) * 100
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'information'>
	| x |
	^aNumber > 0 
	    ifTrue: 
		[x := (aNumber * 2) sqrt.
		DhbErfApproximation new value: x - reducedDOF]
	    ifFalse: [0]
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'information'>
	^12 / degreeOfFreedom
    ]

    parameters [
	"Returns an Array containing the parameters of the distribution.
	 It is used to print out the distribution and for fitting.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: degreeOfFreedom
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(DhbNormalDistribution random + reducedDOF) squared / 2
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'information'>
	^(2 / degreeOfFreedom) sqrt * 2
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'information'>
	| x |
	^aNumber > 0 
	    ifTrue: 
		[x := (aNumber * 2) sqrt.
		(DhbErfApproximation new normal: x - reducedDOF) / x]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^degreeOfFreedom * 2
    ]

    initialize: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'initialization'>
	degreeOfFreedom := anInteger.
	reducedDOF := (degreeOfFreedom * 2 - 1) sqrt.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	normalDistribution changeParametersBy: aVector
    ]
]



DhbProbabilityDensity subclass: DhbHistogrammedDistribution [
    | histogram |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbHistogrammedDistribution class >> histogram: aHistogram [
	"Create a new instance of the receiver corresponding to a histogram.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'creation'>
	^super new initialize: aHistogram
    ]

    DhbHistogrammedDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbHistogrammedDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Experimental distribution'
    ]

    acceptanceBetween: aNumber1 and: aNumber2 [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value larger than aNumber 1 and lower than or equal to aNumber2.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(histogram countsBetween: (aNumber1 max: histogram minimum)
	    and: (aNumber2 min: histogram maximum)) / histogram totalCount
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^histogram average
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^aNumber < histogram minimum 
	    ifTrue: [0]
	    ifFalse: 
		[aNumber < histogram maximum 
		    ifTrue: [(histogram countsUpTo: aNumber) / histogram totalCount]
		    ifFalse: [1]]
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 Undefined. Must be implemented by subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^histogram kurtosis
    ]

    privateInverseDistributionValue: aNumber [
	"Private - Answer the number whose distribution is aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^histogram inverseDistributionValue: aNumber
    ]

    skewness [
	"Answer the skewness of the receiver.
	 Undefined. Must be implemented by subclass.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^histogram skewness
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^histogram standardDeviation
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	^(aNumber >= histogram minimum and: [aNumber < histogram maximum]) 
	    ifTrue: 
		[(histogram countAt: aNumber) / (histogram totalCount * histogram binWidth)]
	    ifFalse: [0]
    ]

    variance [
	"Answer the variance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^histogram variance
    ]

    initialize: aHistogram [
	"Private - Defines the histogram of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'initialization'>
	aHistogram count = 0 
	    ifTrue: 
		[self error: 'Cannot define probability density on an empty histogram'].
	histogram := aHistogram.
	^self
    ]
]



DhbProbabilityDensity subclass: DhbNormalDistribution [
    | mu sigma nextRandom |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    NextRandom := nil.

    DhbNormalDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	^self new: aHistogram average sigma: aHistogram standardDeviation
    ]

    DhbNormalDistribution class >> new [
	"Create a new instance of the receiver with mu=0 and sigma=1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self new: 0 sigma: 1
    ]

    DhbNormalDistribution class >> new: aNumber1 sigma: aNumber2 [
	"Create a new instance of the receiver with given mu and sigma.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 sigma: aNumber2
    ]

    DhbNormalDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Normal distribution'
    ]

    DhbNormalDistribution class >> random [
	"Answer a random number distributed according to a (0,1) normal distribution.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	| v1 v2 w y |
	NextRandom isNil 
	    ifTrue: 
		[
		[v1 := Number random * 2 - 1.
		v2 := Number random * 2 - 1.
		w := v1 squared + v2 squared.
		w > 1] 
			whileTrue: [].
		y := (w ln * 2 negated / w) sqrt.
		v1 := y * v1.
		NextRandom := y * v2]
	    ifFalse: 
		[v1 := NextRandom.
		NextRandom := nil].
	^v1
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^mu
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^DhbErfApproximation new value: (aNumber - mu) / sigma
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^0
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: mu with: sigma
    ]

    random [
	"Answer a random number distributed accroding to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^self class random * sigma + mu
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^0
    ]

    standardDeviation [
	"Answer the standard deviation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^sigma
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(DhbErfApproximation new normal: (aNumber - mu) / sigma) / sigma
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'information'>
	| dp y |
	y := (aNumber - mu) / sigma.
	dp := (DhbErfApproximation new normal: y) / sigma.
	^Array with: dp
	    with: (DhbVector with: dp * y / sigma with: dp * (y squared - 1) / sigma)
    ]

    initialize: aNumber1 sigma: aNumber2 [
	"Private - Defines the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	mu := aNumber1.
	sigma := aNumber2.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'transformation'>
	mu := mu + (aVector at: 1).
	sigma := sigma + (aVector at: 2)
    ]
]



DhbProbabilityDensity subclass: DhbStudentDistribution [
    | degreeOfFreedom norm chiSquareDistribution incompleteBetaFunction |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbStudentDistribution class >> asymptoticLimit [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/4/99"

	<category: 'creation'>
	^30
    ]

    DhbStudentDistribution class >> degreeOfFreedom: anInteger [
	"Create a new instance of the receiver with anInteger degrees of freedom.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'creation'>
	^anInteger > self asymptoticLimit 
	    ifTrue: [DhbNormalDistribution new]
	    ifFalse: 
		[anInteger = 1 
		    ifTrue: [DhbCauchyDistribution shape: 0 scale: 1]
		    ifFalse: [super new initialize: anInteger]]
    ]

    DhbStudentDistribution class >> fromHistogram: aHistogram [
	"Create an instance of the receiver with parameters estimated from the
	 given histogram using best guesses. This method can be used to
	 find the initial values for a fit.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/3/99"

	<category: 'creation'>
	| dof var |
	var := aHistogram variance.
	var = 0 ifTrue: [^nil].
	dof := (2 / (1 - (1 / aHistogram variance))) rounded max: 1.
	^dof > self asymptoticLimit 
	    ifTrue: [nil]
	    ifFalse: [self degreeOfFreedom: dof]
    ]

    DhbStudentDistribution class >> new [
	"Prevent using this message to create instances
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    DhbStudentDistribution class >> test: aStatisticalMoment1 with: aStatisticalMoment2 [
	"Preform a consistency Student test (or t-test) on the averages of  two statistical moments ( or histograms).
	 Answers the probability of failing the test.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'creation'>
	| t |
	t := (aStatisticalMoment1 average - aStatisticalMoment2 average) abs.
	^1 
	    - ((self class 
		    degreeOfFreedom: aStatisticalMoment1 count + aStatisticalMoment2 count - 2) 
			acceptanceBetween: t negated
			and: t)
    ]

    DhbStudentDistribution class >> distributionName [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^'Student distribution'
    ]

    average [
	"Answer the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^0
    ]

    chiSquareDistribution [
	"Private - Answer the chi square distribution used to generate
	 random numbers for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	chiSquareDistribution isNil 
	    ifTrue: 
		[chiSquareDistribution := DhbChiSquareDistribution 
			    degreeOfFreedom: degreeOfFreedom - 1].
	^chiSquareDistribution
    ]

    confidenceLevel: aNumber [
	"Answer the probability in percent of finding a value
	 distributed according to the receiver with an absolute value
	 larger than aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	^(1 - (self symmetricAcceptance: aNumber abs)) * 100
    ]

    distributionValue: aNumber [
	"Answers the probability of observing a random variable distributed according to
	 the receiver with a value lower than or equal to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	aNumber = 0 ifTrue: [^1 / 2].
	^(aNumber > 0 
	    ifTrue: [2 - (self symmetricAcceptance: aNumber abs)]
	    ifFalse: [self symmetricAcceptance: aNumber abs]) / 2
    ]

    incompleteBetaFunction [
	"Private - Answers the incomplete beta function used to compute
	 the symmetric acceptance integral of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	incompleteBetaFunction isNil 
	    ifTrue: 
		[incompleteBetaFunction := DhbIncompleteBetaFunction 
			    shape: degreeOfFreedom / 2
			    shape: 0.5].
	^incompleteBetaFunction
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 Undefined if the degree of freedom is less than 5.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^degreeOfFreedom > 4 ifTrue: [6 / (degreeOfFreedom - 4)] ifFalse: [nil]
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^Array with: degreeOfFreedom
    ]

    random [
	"Answer a random number distributed according to the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	^DhbNormalDistribution random 
	    * ((degreeOfFreedom - 1) / self chiSquareDistribution random) sqrt
    ]

    skewness [
	"Answer the skewness of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^0
    ]

    symmetricAcceptance: aNumber [
	"Private - Compute the acceptance of the receiver between -aNumber and aNumber
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/3/99"

	<category: 'information'>
	^self incompleteBetaFunction 
	    value: degreeOfFreedom / (aNumber squared + degreeOfFreedom)
    ]

    value: aNumber [
	"Answers the probability that a random variable distributed according to the receiver
	 gives a value between aNumber and aNumber + espilon (infinitesimal interval).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^(norm 
	    - ((aNumber squared / degreeOfFreedom + 1) ln * ((degreeOfFreedom + 1) / 2))) 
		exp
    ]

    variance [
	"Answer the variance of the receiver.
	 Undefined if the degree of freedom is less than 3.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^degreeOfFreedom > 2 
	    ifTrue: [degreeOfFreedom / (degreeOfFreedom - 2)]
	    ifFalse: [nil]
    ]

    computeNorm [
	"Private - Compute the norm of the receiver because its parameters have changed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	norm := ((degreeOfFreedom / 2 logBeta: 1 / 2) + (degreeOfFreedom ln / 2)) 
		    negated
    ]

    initialize: anInteger [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	anInteger > 0 ifFalse: [self error: 'Degree of freedom must be positive'].
	degreeOfFreedom := anInteger.
	self computeNorm.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	degreeOfFreedom := degreeOfFreedom + (aVector at: 1).
	self computeNorm
    ]
]

PK
     �Mh@1�]�&  &    NumericsAdds.stUT	 dqXOȉXOux �  �  "======================================================================
|
|   Numerical methods - Class extensions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Integer extend [

    gamma [
	"Compute the Gamma function for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'numerics'>
	self > 0 
	    ifFalse: 
		[^self 
		    error: 'Attempt to compute the Gamma function of a non-positive integer'].
	^(self - 1) factorial
    ]

    random [
	"Answer a random integer between 0 and the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'numerics'>
	^Dhb.DhbMitchellMooreGenerator new integerValue: self
    ]

]



Number class extend [

    random [
	"Answers a random number between 0 and 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'numerics'>
	^Dhb.DhbMitchellMooreGenerator new floatValue
    ]

]



Number extend [

    addPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'numerics'>
	^aPolynomial addNumber: self
    ]

    asLimitedPrecisionReal [
	"Convert the receiver to an instance of
	 some subclass of LimitedPrecisionReal.
	 This method defines what the default is."

	<category: 'numerics'>
	^self asFloat
    ]

    beta: aNumber [
	"Computes the beta function of the receiver and aNumber
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'numerics'>
	^(self logBeta: aNumber) exp
    ]

    dividingPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'numerics'>
	^aPolynomial timesNumber: 1 / self
    ]

    equalsTo: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'numerics'>
	^self relativelyEqualsTo: aNumber
	    upTo: Dhb.DhbFloatingPointMachine new defaultNumericalPrecision
    ]

    errorFunction [
	"Answer the error function for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'numerics'>
	^Dhb.DhbErfApproximation new value: self
    ]

    gamma [
	"Compute the Gamma function for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'numerics'>
	^self > 1 
	    ifTrue: [^Dhb.DhbLanczosFormula new gamma: self]
	    ifFalse: 
		[self < 0 
		    ifTrue: [Float pi / ((Float pi * self) sin * (1 - self) gamma)]
		    ifFalse: [(Dhb.DhbLanczosFormula new gamma: self + 1) / self]]
    ]

    logBeta: aNumber [
	"Computes the logarithm of the beta function of the receiver and aNumber
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'numerics'>
	^self logGamma + aNumber logGamma - (self + aNumber) logGamma
    ]

    logGamma [
	"Computes the log of the Gamma function (for positive numbers only)
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'numerics'>
	^self > 1 
	    ifTrue: [Dhb.DhbLanczosFormula new logGamma: self]
	    ifFalse: 
		[self > 0 
		    ifTrue: [(Dhb.DhbLanczosFormula new logGamma: self + 1) - self ln]
		    ifFalse: [^self error: 'Argument for the log gamma function must be positive']]
    ]

    productWithMatrix: aMatrix [
	"Answer a new matrix, product of aMatrix with the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'numerics'>
	^aMatrix class rows: (aMatrix rowsCollect: [:each | each * self])
    ]

    productWithVector: aVector [
	"Answers a new vector product of the receiver with aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'numerics'>
	^aVector collect: [:each | each * self]
    ]

    random [
	"Answers a random number distributed between 0 and the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'numerics'>
	^self class random * self
    ]

    relativelyEqualsTo: aNumber upTo: aSmallNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'numerics'>
	| norm |
	norm := self abs max: aNumber abs.
	^norm <= Dhb.DhbFloatingPointMachine new defaultNumericalPrecision 
	    or: [(self - aNumber) abs < (aSmallNumber * norm)]
    ]

    subtractToPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'numerics'>
	^aPolynomial addNumber: self negated
    ]

    timesPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'numerics'>
	^aPolynomial timesNumber: self
    ]

]



Point extend [

    extentFromBottomLeft: aPoint [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^Rectangle origin: self 
		    - (0 @ (aPoint isInteger ifTrue: [aPoint] ifFalse: [aPoint y]))
	    extent: aPoint
    ]

    extentFromBottomRight: aPoint [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^Rectangle origin: self - aPoint extent: aPoint
    ]

    extentFromCenter: aPoint [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^Rectangle origin: self - (aPoint // 2) extent: aPoint
    ]

    extentFromTopLeft: aPoint [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^Rectangle origin: self extent: aPoint
    ]

    extentFromTopRight: aPoint [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^Rectangle origin: self 
		    - ((aPoint isInteger ifTrue: [aPoint] ifFalse: [aPoint x]) @ 0)
	    extent: aPoint
    ]

]



Rectangle extend [

    positiveRectangle [
	"(c) Copyrights Didier BESSET, 1998, all rights reserved
	 Initial code: 21/4/98"

	<category: 'numerics'>
	^(origin min: corner) corner: (origin max: corner)
    ]

]



Collection extend [

    asVector [
	<category: 'numerics'>
	^(Dhb.DhbVector new: self size) 
	    replaceFrom: 1
	    to: self size
	    with: self
	    startingAt: 1
    ]

]



DhbPolynomial extend [

    generality [
	<category: 'numerics'>
	^nil
    ]

]



DhbVector extend [

    generality [
	<category: 'numerics'>
	^nil
    ]

]

PK
     �Mh@��x  �x    Basic.stUT	 dqXOȉXOux �  �  "======================================================================
|
|   Numerical methods - Basic objects and concepts
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: DhbIterativeProcess [
    | precision desiredPrecision maximumIterations result iterations |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbIterativeProcess class >> new [
	"Create an instance of the class.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'creation'>
	^super new initialize
    ]

    DhbIterativeProcess class >> defaultMaximumIterations [
	"Private - Answers the default maximum number of iterations for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^50
    ]

    DhbIterativeProcess class >> defaultPrecision [
	"Private - Answers the default precision for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^DhbFloatingPointMachine new defaultNumericalPrecision
    ]

    hasConverged [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 20/4/99"

	<category: 'information'>
	^precision <= desiredPrecision
    ]

    iterations [
	"Answers the number of iterations performed.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^iterations
    ]

    limitedSmallValue: aNumber [
	"Private - prevent aNumber from being smaller in absolute value than a small number.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	^aNumber abs < DhbFloatingPointMachine new smallNumber 
	    ifTrue: [DhbFloatingPointMachine new smallNumber]
	    ifFalse: [aNumber]
    ]

    precision [
	"Answer the attained precision for the result.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'information'>
	^precision
    ]

    precisionOf: aNumber1 relativeTo: aNumber2 [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/5/99"

	<category: 'information'>
	^aNumber2 > DhbFloatingPointMachine new defaultNumericalPrecision 
	    ifTrue: [aNumber1 / aNumber2]
	    ifFalse: [aNumber1]
    ]

    result [
	"Answer the result of the iterations (if any)
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^result
    ]

    desiredPrecision: aNumber [
	"Defines the desired precision for the result.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'initialization'>
	aNumber > 0 
	    ifFalse: [^self error: 'Illegal precision: ' , aNumber printString].
	desiredPrecision := aNumber
    ]

    initialize [
	"Private - initialize the parameters of the receiver with default values.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'initialization'>
	desiredPrecision := self class defaultPrecision.
	maximumIterations := self class defaultMaximumIterations.
	^self
    ]

    maximumIterations: anInteger [
	"Defines the maximum number of iterations.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'initialization'>
	(anInteger isInteger and: [anInteger > 1]) 
	    ifFalse: 
		[^self 
		    error: 'Invalid maximum number of iteration: ' , anInteger printString].
	maximumIterations := anInteger
    ]

    evaluate [
	"Perform the iteration until either the desired precision is attained or the number of iterations exceeds the maximum.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	iterations := 0.
	self initializeIterations.
	
	[iterations := iterations + 1.
	precision := self evaluateIteration.
	self hasConverged or: [iterations >= maximumIterations]] 
		whileFalse: [].
	self finalizeIterations.
	^self result
    ]

    evaluateIteration [
	"Dummy method (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	^self subclassResponsibility
    ]

    finalizeIterations [
	"Perform cleanup operation if needed (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	
    ]

    initializeIterations [
	"Initialize the iterations (must be implemented by subclass when needed).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	
    ]
]



DhbIterativeProcess subclass: DhbFunctionalIterator [
    | functionBlock relativePrecision |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbFunctionalIterator class >> function: aBlock [
	"Convenience method to create a instance with given function block.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'creation'>
	^(self new)
	    setFunction: aBlock;
	    yourself
    ]

    relativePrecision: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/4/99"

	<category: 'information'>
	^self precisionOf: aNumber relativeTo: result abs
    ]

    setFunction: aBlock [
	"Defines the function for which zeroes will be found.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 7/1/99"

	<category: 'initialization'>
	(aBlock respondsTo: #value:) 
	    ifFalse: [self error: 'Function block must implement the method value:'].
	functionBlock := aBlock
    ]

    computeInitialValues [
	<category: 'operation'>
	self subclassResponsibility
    ]

    initializeIterations [
	"If no initial value has been defined, take 0 as the starting point (for lack of anything better).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	functionBlock isNil ifTrue: [self error: 'No function supplied'].
	self computeInitialValues
    ]
]



Object subclass: DhbPolynomial [
    | coefficients |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbPolynomial class >> coefficients: anArray [
	"Creates a new instance with given coefficients
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'creation'>
	^self new initialize: anArray reverse
    ]

    = aNumberOrPolynomial [
	<category: 'comparing'>
	aNumberOrPolynomial isNil ifTrue: [^false].
	aNumberOrPolynomial isNumber 
	    ifTrue: 
		[^coefficients size = 1 and: [coefficients first = aNumberOrPolynomial]].
	aNumberOrPolynomial class = self class ifFalse: [^false].
	^self coefficients = aNumberOrPolynomial coefficients
    ]

    hash [
	<category: 'comparing'>
	^coefficients hash
    ]

    deflatedAt: aNumber [
	"Answers a new polynomial quotient of the receiver with polynomial (X-aNumber)
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 20/4/99"

	<category: 'creation'>
	| remainder next newCoefficients |
	remainder := 0.
	newCoefficients := coefficients collect: 
			[:each | 
			next := remainder.
			remainder := remainder * aNumber + each.
			next].
	^self class 
	    coefficients: (newCoefficients copyFrom: 2 to: newCoefficients size) 
		    reverse
    ]

    derivative [
	"Answer a new polynomial, derivative of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'creation'>
	| n |
	n := coefficients size.
	^self class 
	    coefficients: ((coefficients collect: 
			[:each | 
			n := n - 1.
			each * n]) 
		    reverse copyFrom: 2 to: coefficients size)
    ]

    integral [
	"Answer a new polynomial, integral of the receiver with value 0 at x=0.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'creation'>
	^self integral: 0
    ]

    integral: aValue [
	"Answer a new polynomial, integral of the receiver with given value at x=0.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'creation'>
	| n |
	n := coefficients size + 1.
	^self class 
	    coefficients: ((coefficients collect: 
			[:each | 
			n := n - 1.
			each / n]) 
		    copyWith: aValue) reverse
    ]

    printOn: aStream [
	"Append to aStream a written representation of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'display'>
	| n firstNonZeroCoefficientPrinted |
	n := 0.
	firstNonZeroCoefficientPrinted := false.
	coefficients reverseDo: 
		[:each | 
		each = 0 
		    ifFalse: 
			[firstNonZeroCoefficientPrinted 
			    ifTrue: 
				[aStream space.
				each < 0 ifFalse: [aStream nextPut: $+].
				aStream space]
			    ifFalse: [firstNonZeroCoefficientPrinted := true].
			(each = 1 and: [n > 0]) ifFalse: [each printOn: aStream].
			n > 0 
			    ifTrue: 
				[aStream nextPutAll: ' X'.
				n > 1 
				    ifTrue: 
					[aStream nextPut: $^.
					n printOn: aStream]]].
		n := n + 1]
    ]

    addNumber: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'double dispatching'>
	| newCoefficients |
	newCoefficients := coefficients reverse.
	newCoefficients at: 1 put: newCoefficients first + aNumber.
	^self class coefficients: newCoefficients
    ]

    addPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'double dispatching'>
	^self class coefficients: ((0 to: (self degree max: aPolynomial degree)) 
		    collect: [:n | (aPolynomial at: n) + (self at: n)])
    ]

    differenceFromNumber: aFloatD [
	<category: 'double dispatching'>
	^self subtractFrom: aFloatD
    ]

    dividingPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'double dispatching'>
	^(self dividingPolynomialWithRemainder: aPolynomial) first
    ]

    dividingPolynomialWithRemainder: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'double dispatching'>
	| remainderCoefficients quotientCoefficients n m norm quotientDegree |
	n := self degree.
	m := aPolynomial degree.
	quotientDegree := m - n.
	quotientDegree < 0 
	    ifTrue: [^Array with: (self class new: #(0)) with: aPolynomial].
	quotientCoefficients := Array new: quotientDegree + 1.
	remainderCoefficients := (0 to: m) collect: [:k | aPolynomial at: k].
	norm := 1 / coefficients first.
	quotientDegree to: 0
	    by: -1
	    do: 
		[:k | 
		| x |
		x := (remainderCoefficients at: n + k + 1) * norm.
		quotientCoefficients at: quotientDegree + 1 - k put: x.
		n + k - 1 to: k
		    by: -1
		    do: 
			[:j | 
			remainderCoefficients at: j + 1
			    put: (remainderCoefficients at: j + 1) - (x * (self at: j - k))]].
	^Array with: (self class coefficients: quotientCoefficients reverse)
	    with: (self class coefficients: (remainderCoefficients copyFrom: 1 to: n))
    ]

    productFromNumber: aFloatD [
	<category: 'double dispatching'>
	^self * aFloatD
    ]

    subtractFrom: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'double dispatching'>
	| newCoefficients |
	newCoefficients := (coefficients collect: [:c | c negated]) reverse.
	newCoefficients at: 1 put: newCoefficients first + aNumber.
	^self class coefficients: newCoefficients
    ]

    subtractToPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'double dispatching'>
	^self class coefficients: ((0 to: (self degree max: aPolynomial degree)) 
		    collect: [:n | (aPolynomial at: n) - (self at: n)])
    ]

    sumFromNumber: aFloatD [
	<category: 'double dispatching'>
	^self + aFloatD
    ]

    timesNumber: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'double dispatching'>
	^self class 
	    coefficients: (coefficients collect: [:each | each * aNumber]) reverse
    ]

    timesPolynomial: aPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'double dispatching'>
	| productCoefficients degree |
	degree := aPolynomial degree + self degree.
	productCoefficients := (degree to: 0 by: -1) collect: 
			[:n | 
			| sum |
			sum := 0.
			0 to: degree - n
			    do: [:k | sum := (self at: k) * (aPolynomial at: degree - n - k) + sum].
			sum].
	^self class coefficients: productCoefficients
    ]

    at: anInteger [
	"Answers the coefficient of order anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'information'>
	^anInteger < coefficients size 
	    ifTrue: [coefficients at: coefficients size - anInteger]
	    ifFalse: [0]
    ]

    coefficients [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/5/99"

	<category: 'information'>
	^coefficients reverse
    ]

    degree [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'information'>
	^coefficients size - 1
    ]

    roots [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 20/4/99"

	<category: 'information'>
	^self roots: DhbFloatingPointMachine new defaultNumericalPrecision
    ]

    roots: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 20/4/99"

	<category: 'information'>
	| pol roots x rootFinder |
	rootFinder := DhbNewtonZeroFinder new.
	rootFinder desiredPrecision: aNumber.
	pol := self class 
		    coefficients: (coefficients reverse collect: [:each | each asFloatD]).
	roots := OrderedCollection new: self degree.
	
	[rootFinder
	    setFunction: pol;
	    setDerivative: pol derivative.
	x := rootFinder evaluate.
	rootFinder hasConverged] 
		whileTrue: 
		    [roots add: x.
		    pol := pol deflatedAt: x.
		    pol degree > 0 ifFalse: [^roots]].
	^roots
    ]

    value: aNumber [
	"Answer the value of the polynomial for the specified variable value.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'information'>
	^coefficients inject: 0 into: [:sum :each | sum * aNumber + each]
    ]

    initialize: anArray [
	"Private - Initialize the coefficients of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'initialization'>
	coefficients := anArray.
	^self
    ]

    generality [
	<category: 'numerics'>
	^nil
    ]

    * aNumberOrPolynomial [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'operation'>
	^aNumberOrPolynomial timesPolynomial: self
    ]

    + aNumberOrPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'operation'>
	^aNumberOrPolynomial addPolynomial: self
    ]

    - aNumberOrPolynomial [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 19/4/99"

	<category: 'operation'>
	^aNumberOrPolynomial subtractToPolynomial: self
    ]

    / aNumberOrPolynomial [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/4/99"

	<category: 'operation'>
	^aNumberOrPolynomial dividingPolynomial: self
    ]
]



Object subclass: DhbDecimalFloatingNumber [
    | mantissa exponent |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    Digits := nil.

    DhbDecimalFloatingNumber class >> new: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'creation'>
	^self new normalize: aNumber
    ]

    DhbDecimalFloatingNumber class >> defaultDigits [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'information'>
	^15
    ]

    DhbDecimalFloatingNumber class >> digits [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'information'>
	Digits isNil ifTrue: [Digits := self defaultDigits].
	^Digits
    ]

    DhbDecimalFloatingNumber class >> defaultDigits: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'transformation'>
	Digits := anInteger
    ]

    DhbDecimalFloatingNumber class >> resetDigits [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'transformation'>
	Digits := nil
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'display'>
	mantissa printOn: aStream.
	aStream nextPutAll: 'xE'.
	exponent negated printOn: aStream
    ]

    value [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'information'>
	^mantissa / (10 raisedToInteger: exponent)
    ]

    * aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'operation'>
	^self class new: self value * aNumber value
    ]

    + aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'operation'>
	^self class new: self value + aNumber value
    ]

    - aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'operation'>
	^self class new: self value - aNumber value
    ]

    / aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'operation'>
	^self class new: self value / aNumber value
    ]

    sqrt [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'operation'>
	^self class new: self value sqrt
    ]

    normalize: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/6/99"

	<category: 'transformation'>
	exponent := (self class digits - (aNumber log: 10)) floor.
	mantissa := (aNumber * (10 raisedToInteger: exponent)) rounded.
	^self
    ]
]



DhbPolynomial subclass: DhbEstimatedPolynomial [
    | errorMatrix |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    error: aNumber [
	"Compute the error on the value of the receiver for argument aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'information'>
	| errorVector term nextTerm |
	nextTerm := 1.
	errorVector := (coefficients collect: 
			[:each | 
			term := nextTerm.
			nextTerm := aNumber * nextTerm.
			term]) 
		    asVector.
	^(errorVector * errorMatrix * errorVector) sqrt
    ]

    errorMatrix [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/5/99"

	<category: 'information'>
	^errorMatrix
    ]

    valueAndError: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 20/5/99"

	<category: 'information'>
	^Array with: (self value: aNumber) with: (self error: aNumber)
    ]

    errorMatrix: aMatrix [
	"Defines the error matrix of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'initialization'>
	errorMatrix := aMatrix
    ]
]



Object subclass: DhbFloatingPointMachine [
    | defaultNumericalPrecision radix machinePrecision negativeMachinePrecision smallestNumber largestNumber smallNumber largestExponentArgument |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    UniqueInstance := nil.

    DhbFloatingPointMachine class >> new [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'creation'>
	UniqueInstance = nil ifTrue: [UniqueInstance := super new].
	^UniqueInstance
    ]

    DhbFloatingPointMachine class >> reset [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'creation'>
	UniqueInstance := nil
    ]

    showParameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/6/99"

	<category: 'display'>
	Transcript
	    cr;
	    cr;
	    nextPutAll: 'Floating-point machine parameters';
	    cr;
	    nextPutAll: '---------------------------------';
	    cr;
	    nextPutAll: 'Radix: '.
	self radix printOn: Transcript.
	Transcript
	    cr;
	    nextPutAll: 'Machine precision: '.
	self machinePrecision printOn: Transcript.
	Transcript
	    cr;
	    nextPutAll: 'Negative machine precision: '.
	self negativeMachinePrecision printOn: Transcript.
	Transcript
	    cr;
	    nextPutAll: 'Smallest number: '.
	self smallestNumber printOn: Transcript.
	Transcript
	    cr;
	    nextPutAll: 'Largest number: '.
	self largestNumber printOn: Transcript
    ]

    computeLargestNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/6/99"

	<category: 'information'>
	| one floatingRadix fullMantissaNumber |
	one := 1.0.
	floatingRadix := self radix asFloatD.
	fullMantissaNumber := one 
		    - (floatingRadix * self negativeMachinePrecision).
	largestNumber := fullMantissaNumber.
	
	[
	[fullMantissaNumber := fullMantissaNumber * floatingRadix.
	fullMantissaNumber isFinite ifFalse: [Error signal].
	largestNumber := fullMantissaNumber.
	true] 
		whileTrue: []] 
		on: Error
		do: [:signal | signal return: nil]
    ]

    computeMachinePrecision [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'information'>
	| one zero inverseRadix tmp |
	one := 1.0.
	zero := 0.0.
	inverseRadix := one / self radix asFloatD.
	machinePrecision := one.
	
	[tmp := one + machinePrecision.
	tmp - one = zero] 
		whileFalse: [machinePrecision := machinePrecision * inverseRadix]
    ]

    computeNegativeMachinePrecision [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'information'>
	| one zero floatingRadix inverseRadix tmp |
	one := 1.0.
	zero := 0.0.
	floatingRadix := self radix asFloatD.
	inverseRadix := one / floatingRadix.
	negativeMachinePrecision := one.
	
	[tmp := one - negativeMachinePrecision.
	tmp - one = zero] whileFalse: 
		    [negativeMachinePrecision := negativeMachinePrecision * inverseRadix]
    ]

    computeRadix [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'information'>
	| one zero a b tmp1 tmp2 |
	one := 1.0.
	zero := 0.0.
	a := one.
	
	[a := a + a.
	tmp1 := a + one.
	tmp2 := tmp1 - a.
	tmp2 - one = zero] 
		whileTrue: [].
	b := one.
	
	[b := b + b.
	tmp1 := a + b.
	radix := (tmp1 - a) truncated.
	radix = 0] 
		whileTrue: []
    ]

    computeSmallestNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/6/99"

	<category: 'information'>
	| one floatingRadix inverseRadix fullMantissaNumber |
	one := 1 asFloatD.
	floatingRadix := self radix asFloatD.
	inverseRadix := one / floatingRadix.
	fullMantissaNumber := one 
		    - (floatingRadix * self negativeMachinePrecision).
	smallestNumber := fullMantissaNumber.
	
	[
	[fullMantissaNumber := fullMantissaNumber * inverseRadix.
	fullMantissaNumber = 0.0 ifTrue: [Error signal].
	fullMantissaNumber isFinite ifFalse: [Error signal].
	smallestNumber := fullMantissaNumber.
	true] 
		whileTrue: []] 
		on: Error
		do: [:signal | signal return: nil]
    ]

    defaultNumericalPrecision [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'information'>
	defaultNumericalPrecision isNil 
	    ifTrue: [defaultNumericalPrecision := self machinePrecision sqrt].
	^defaultNumericalPrecision
    ]

    largestExponentArgument [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/18/00"

	<category: 'information'>
	largestExponentArgument isNil 
	    ifTrue: [largestExponentArgument := self largestNumber ln].
	^largestExponentArgument
    ]

    largestNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/5/99"

	<category: 'information'>
	largestNumber isNil ifTrue: [self computeLargestNumber].
	^largestNumber
    ]

    machinePrecision [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'information'>
	machinePrecision isNil ifTrue: [self computeMachinePrecision].
	^machinePrecision
    ]

    negativeMachinePrecision [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 22/4/99"

	<category: 'information'>
	negativeMachinePrecision isNil 
	    ifTrue: [self computeNegativeMachinePrecision].
	^negativeMachinePrecision
    ]

    radix [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/4/99"

	<category: 'information'>
	radix isNil ifTrue: [self computeRadix].
	^radix
    ]

    smallestNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/5/99"

	<category: 'information'>
	smallestNumber isNil ifTrue: [self computeSmallestNumber].
	^smallestNumber
    ]

    smallNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/5/99"

	<category: 'information'>
	smallNumber isNil ifTrue: [smallNumber := self smallestNumber sqrt].
	^smallNumber
    ]
]



Array subclass: DhbVector [
    
    <shape: #pointer>
    <category: 'DHB Numerical'>
    <comment: nil>

    normalized [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30-Dec-99"

	<category: 'creation'>
	^1 / self norm * self
    ]

    asVector [
	"Answer self since the receiver is a vector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^self
    ]

    dimension [
	"Answer the dimension of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^self size
    ]

    norm [
	"Answer the norm of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^(self * self) sqrt
    ]

    scalarProduct: aVector [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/5/99"

	<category: 'information'>
	| product n |
	n := 0.
	product := self collect: 
			[:each | 
			n := n + 1.
			(aVector at: n) * each].
	n := product size.
	[n > 1] whileTrue: 
		[| i j |
		i := 1.
		j := n.
		[i < j] whileTrue: 
			[product at: i put: (product at: i) + (product at: j).
			j := j - 1.
			i := i + 1].
		n := i min: j].
	^product at: 1
    ]

    generality [
	<category: 'numerics'>
	^nil
    ]

    * aNumberOrMatrixOrVector [
	"Answers the product of the receiver with the argument.
	 The argument can be a number, matrix or vector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aNumberOrMatrixOrVector productWithVector: self
    ]

    + aVector [
	"Answers the sum of the receiver with aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	| answer n |
	answer := self class new: self size.
	n := 0.
	self with: aVector
	    do: 
		[:a :b | 
		n := n + 1.
		answer at: n put: a + b].
	^answer
    ]

    - aVector [
	"Answers the difference of the receiver with aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	| answer n |
	answer := self class new: self size.
	n := 0.
	self with: aVector
	    do: 
		[:a :b | 
		n := n + 1.
		answer at: n put: a - b].
	^answer
    ]

    productFromNumber: aFloatD [
	<category: 'operation'>
	^self * aFloatD
    ]

    productWithMatrix: aMatrix [
	"Answers the product of aMatrix with the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix rowsCollect: [:each | each * self]
    ]

    productWithVector: aVector [
	"Answers the scalar product of aVector with the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	| n |
	n := 0.
	^self inject: 0
	    into: 
		[:sum :each | 
		n := n + 1.
		(aVector at: n) * each + sum]
    ]

    tensorProduct: aVector [
	"Answers the tensor product of the receiver with aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	self dimension = aVector dimension 
	    ifFalse: [^self error: 'Vector dimensions mismatch to build tensor product'].
	^DhbSymmetricMatrix 
	    rows: (self collect: [:a | aVector collect: [:b | a * b]])
    ]

    accumulate: aVectorOrAnArray [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'transformation'>
	1 to: self size
	    do: [:n | self at: n put: (self at: n) + (aVectorOrAnArray at: n)]
    ]

    accumulateNegated: aVectorOrAnArray [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'transformation'>
	1 to: self size
	    do: [:n | self at: n put: (self at: n) - (aVectorOrAnArray at: n)]
    ]

    negate [
	"Inverse the sign of all components of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	1 to: self size do: [:n | self at: n put: (self at: n) negated]
    ]

    scaleBy: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'transformation'>
	1 to: self size do: [:n | self at: n put: (self at: n) * aNumber]
    ]
]

PK
     �Mh@x�[�I  �I    Functions.stUT	 dqXOȉXOux �  �  "======================================================================
|
|   Numerical methods - Special functions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: DhbSeriesTermServer [
    | x lastTerm |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    setArgument: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'initialization'>
	x := aNumber asFloatD
    ]
]



DhbIterativeProcess subclass: DhbInfiniteSeries [
    | termServer |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbInfiniteSeries class >> server: aTermServer [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'creation'>
	^self new initialize: aTermServer
    ]

    initialize: aTermServer [
	"Private - Assigns the object responsible to compute each term.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'initialization'>
	termServer := aTermServer.
	^self
    ]

    evaluateIteration [
	"Perform one iteration.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'operation'>
	| delta |
	delta := termServer termAt: iterations.
	result := result + delta.
	^self precisionOf: delta abs relativeTo: result abs
    ]

    initializeIterations [
	"Initialize the series.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'operation'>
	result := termServer initialTerm
    ]
]



Object subclass: DhbIncompleteGammaFunction [
    | alpha alphaLogGamma series fraction |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbIncompleteGammaFunction class >> shape: aNumber [
	"Defines a new instance of the receiver with paramater aNumber
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'creation'>
	^super new initialize: aNumber
    ]

    evaluateFraction: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	fraction isNil 
	    ifTrue: 
		[fraction := DhbIncompleteGammaFractionTermServer new.
		fraction setParameter: alpha].
	fraction setArgument: aNumber.
	^(DhbContinuedFraction server: fraction)
	    desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	    evaluate
    ]

    evaluateSeries: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	series isNil 
	    ifTrue: 
		[series := DhbIncompleteGammaSeriesTermServer new.
		series setParameter: alpha].
	series setArgument: aNumber.
	^(DhbInfiniteSeries server: series)
	    desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	    evaluate
    ]

    value: aNumber [
	"Compute the value of the receiver for argument aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	| x norm |
	aNumber = 0 ifTrue: [^0].
	x := aNumber asFloatD.
	norm := [(x ln * alpha - x - alphaLogGamma) exp] on: Error
		    do: [:signal | signal return: nil].
	norm isNil ifTrue: [^1].
	^x - 1 < alpha 
	    ifTrue: [(self evaluateSeries: x) * norm]
	    ifFalse: [1 - (norm / (self evaluateFraction: x))]
    ]

    initialize: aNumber [
	"Private - Defines the parameter alpha of the receiver
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'initialization'>
	alpha := aNumber asFloatD.
	alphaLogGamma := alpha logGamma.
	^self
    ]
]



DhbSeriesTermServer subclass: DhbIncompleteGammaFractionTermServer [
    | alpha |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    initialTerm [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	lastTerm := x - alpha + 1.
	^lastTerm
    ]

    termsAt: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	lastTerm := lastTerm + 2.
	^Array with: (alpha - anInteger) * anInteger with: lastTerm
    ]

    setParameter: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'initialization'>
	alpha := aNumber asFloatD
    ]
]



Object subclass: PointSeries [
    | points |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    PointSeries class >> new [
	"Create a new instance and initialize it"

	<category: 'creation'>
	^super new initialize
    ]

    primitiveAdd: aPoint [
	"Private - Add a point to the receiver"

	<category: 'privateMethods'>
	points add: aPoint
    ]

    primitiveRemove: aPoint [
	"Private - Removes a point from the receiver"

	<category: 'privateMethods'>
	points remove: aPoint
    ]

    sortBlock [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/5/99"

	<category: 'privateMethods'>
	^[:a :b | a x < b x]
    ]

    add: anObject [
	"Add a point to the receiver"

	<category: 'public methods'>
	self primitiveAdd: anObject.
	self changed: self changedSymbol.
	^anObject
    ]

    at: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'public methods'>
	^points at: anInteger
    ]

    changedSymbol [
	"Answers the symbol of the event sent when the points of the receiver change"

	<category: 'public methods'>
	^#pointsChanged
    ]

    collectPoints: aBlock [
	<category: 'public methods'>
	^points collect: aBlock
    ]

    do: aBlock [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'public methods'>
	self pointsDo: aBlock
    ]

    firstPoint [
	"Answers the first point stored in the receiver"

	<category: 'public methods'>
	^self at: 1
    ]

    initialize [
	"Create the point collection"

	<category: 'public methods'>
	points := SortedCollection sortBlock: self sortBlock.
	^self
    ]

    isEmpty [
	"
	 (c) Copyrights Didier BESSET, 1998, all rights reserved.
	 Initial code: 28/9/98"

	<category: 'public methods'>
	^points isEmpty
    ]

    notEmpty [
	<category: 'public methods'>
	^points notEmpty
    ]

    pointCollection [
	"Answer the collection of points.
	 (c) Copyrights Didier BESSET, 1998, all rights reserved.
	 Initial code: 28/9/98"

	<category: 'public methods'>
	^self collectPoints: [:each | each]
    ]

    pointsDo: aBlock [
	<category: 'public methods'>
	points do: aBlock
    ]

    remove: anObject [
	"Add a point to the receiver"

	<category: 'public methods'>
	self primitiveRemove: anObject.
	self changed: self changedSymbol.
	^anObject
    ]

    size [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'public methods'>
	^points size
    ]

    sort [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 27/5/99"

	<category: 'public methods'>
	points := (points asSortedCollection: self sortBlock) asOrderedCollection
    ]
]



Object subclass: DhbLanczosFormula [
    | coefficients sqrt2Pi |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    UniqueInstance := nil.

    DhbLanczosFormula class >> new [
	"Answer a unique instance. Create it if it does not exist.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/1/99"

	<category: 'creation'>
	UniqueInstance isNil 
	    ifTrue: 
		[UniqueInstance := super new.
		UniqueInstance initialize].
	^UniqueInstance
    ]

    gamma: aNumber [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'information'>
	^(self leadingFactor: aNumber) exp * (self series: aNumber) * sqrt2Pi 
	    / aNumber
    ]

    leadingFactor: aNumber [
	"Private - Answers the log of the leading factor in Lanczos' formula.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'information'>
	| temp |
	temp := aNumber + 5.5.
	^temp ln * (aNumber + 0.5) - temp
    ]

    logGamma: aNumber [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'information'>
	^(self leadingFactor: aNumber) 
	    + ((self series: aNumber) * sqrt2Pi / aNumber) ln
    ]

    series: aNumber [
	"Private - Answer the value of the series of Lanczos' formula.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'information'>
	| term |
	term := aNumber.
	^coefficients inject: 1.00000000019001
	    into: 
		[:sum :each | 
		term := term + 1.
		each / term + sum]
    ]

    initialize [
	"Private - Initialize the coefficients of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/3/99"

	<category: 'initialization'>
	sqrt2Pi := (FloatD pi * 2) sqrt.
	coefficients := #(76.1800917294714 -86.50532032941671 24.0140982408309 -1.23173957245015 0.00120865097387 -0.00000539523938).
	^self
    ]
]



DhbSeriesTermServer subclass: DhbIncompleteBetaFractionTermServer [
    | alpha1 alpha2 |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    initialTerm [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	^1
    ]

    termsAt: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	| n n2 |
	n := anInteger // 2.
	n2 := 2 * n.
	^Array with: (n2 < anInteger 
		    ifTrue: 
			[x negated * (alpha1 + n) * (alpha1 + alpha2 + n) 
			    / ((alpha1 + n2) * (alpha1 + 1 + n2))]
		    ifFalse: [x * n * (alpha2 - n) / ((alpha1 + n2) * (alpha1 - 1 + n2))])
	    with: 1
    ]

    setParameter: aNumber1 second: aNumber2 [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'initialization'>
	alpha1 := aNumber1.
	alpha2 := aNumber2
    ]
]



DhbSeriesTermServer subclass: DhbIncompleteGammaSeriesTermServer [
    | alpha sum |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    initialTerm [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	lastTerm := 1 / alpha.
	sum := alpha.
	^lastTerm
    ]

    termAt: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'information'>
	sum := sum + 1.
	lastTerm := lastTerm * x / sum.
	^lastTerm
    ]

    setParameter: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'initialization'>
	alpha := aNumber asFloatD
    ]
]



Object subclass: DhbIncompleteBetaFunction [
    | alpha1 alpha2 fraction inverseFraction logNorm |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbIncompleteBetaFunction class >> shape: aNumber1 shape: aNumber2 [
	"Create an instance of the receiver with given shape parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 shape: aNumber2
    ]

    evaluateFraction: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	fraction isNil 
	    ifTrue: 
		[fraction := DhbIncompleteBetaFractionTermServer new.
		fraction setParameter: alpha1 second: alpha2].
	fraction setArgument: aNumber.
	^(DhbContinuedFraction server: fraction)
	    desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	    evaluate
    ]

    evaluateInverseFraction: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	inverseFraction isNil 
	    ifTrue: 
		[inverseFraction := DhbIncompleteBetaFractionTermServer new.
		inverseFraction setParameter: alpha2 second: alpha1].
	inverseFraction setArgument: 1 - aNumber.
	^(DhbContinuedFraction server: inverseFraction)
	    desiredPrecision: DhbFloatingPointMachine new defaultNumericalPrecision;
	    evaluate
    ]

    value: aNumber [
	"Compute the value of the receiver for argument aNumber.
	 Note: aNumber must be between 0 and 1 (otherwise an exception will occur)
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'information'>
	| norm |
	aNumber = 0 ifTrue: [^0].
	aNumber = 1 ifTrue: [^1].
	norm := (aNumber ln * alpha1 + ((1 - aNumber) ln * alpha2) + logNorm) exp.
	^(alpha1 + alpha2 + 2) * aNumber < (alpha1 + 1) 
	    ifTrue: [norm / ((self evaluateFraction: aNumber) * alpha1)]
	    ifFalse: [1 - (norm / ((self evaluateInverseFraction: aNumber) * alpha2))]
    ]

    initialize: aNumber1 shape: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'initialization'>
	alpha1 := aNumber1.
	alpha2 := aNumber2.
	logNorm := (alpha1 + alpha2) logGamma - alpha1 logGamma - alpha2 logGamma.
	^self
    ]
]



DhbInfiniteSeries subclass: DhbContinuedFraction [
    | numerator denominator |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    evaluateIteration [
	"Perform one iteration.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'operation'>
	| terms delta |
	terms := termServer termsAt: iterations.
	denominator := 1 
		    / (self limitedSmallValue: (terms at: 1) * denominator + (terms at: 2)).
	numerator := self 
		    limitedSmallValue: (terms at: 1) / numerator + (terms at: 2).
	delta := numerator * denominator.
	result := result * delta.
	^(delta - 1) abs
    ]

    initializeIterations [
	"Initialize the series.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/3/99"

	<category: 'operation'>
	numerator := self limitedSmallValue: termServer initialTerm.
	denominator := 0.
	result := numerator
    ]
]



DhbIterativeProcess subclass: DhbIncompleteBetaFunctionFraction [
    | x q1 q2 q3 numerator denominator alpha1 alpha2 |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbIncompleteBetaFunctionFraction class >> shape: aNumber1 shape: aNumber2 [
	"Create an instance of the receiver with given shape parameters.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize: aNumber1 shape: aNumber2
    ]

    initialize: aNumber1 shape: aNumber2 [
	"Private - Initialize the parameters of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'initialization'>
	alpha1 := aNumber1.
	alpha2 := aNumber2.
	q1 := alpha1 + alpha2.
	q2 := alpha1 + 1.
	q3 := alpha1 - 1.
	^self
    ]

    setArgument: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'initialization'>
	x := aNumber
    ]

    evaluateIteration [
	"Compute and add the next term of the fraction.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'operation'>
	| m m2 temp |
	m := iterations + 1.
	m2 := m * 2.
	temp := m * (alpha2 - m) * x / ((q3 + m2) * (alpha1 + m2)).
	denominator := self limitedSmallValue: denominator * temp + 1.
	numerator := self limitedSmallValue: temp / numerator + 1.
	denominator := 1 / denominator.
	result := result * numerator * denominator.
	temp := (alpha1 + m) negated * (q1 + m) * x / ((q2 + m2) * (alpha1 + m2)).
	denominator := self limitedSmallValue: denominator * temp + 1.
	numerator := self limitedSmallValue: temp / numerator + 1.
	denominator := 1 / denominator.
	temp := numerator * denominator.
	result := result * temp.
	^(temp - 1) abs
    ]

    initializeIterations [
	"Initialize the iterations (subclasses must write their own method and call this one last).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/3/99"

	<category: 'operation'>
	numerator := 1.
	denominator := 1 / (self limitedSmallValue: 1 - (q1 * x / q2)).
	result := denominator
    ]
]



Object subclass: DhbErfApproximation [
    | constant series norm |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    UniqueInstance := nil.

    DhbErfApproximation class >> new [
	"Answer a unique instance. Create it if it does not exist.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/1/99"

	<category: 'creation'>
	UniqueInstance isNil 
	    ifTrue: 
		[UniqueInstance := super new.
		UniqueInstance initialize].
	^UniqueInstance
    ]

    normal: aNumber [
	"Computes the value of the Normal distribution for aNumber
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/1/99"

	<category: 'information'>
	^[(aNumber squared * -0.5) exp * norm] on: Error
	    do: [:signal | signal return: 0]
    ]

    value: aNumber [
	"Answer erf( aNumber) using an approximation from Abramovitz and Stegun, Handbook of Mathematical Functions.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/1/99"

	<category: 'information'>
	| t |
	aNumber = 0 ifTrue: [^0.5].
	aNumber > 0 ifTrue: [^1 - (self value: aNumber negated)].
	aNumber < -20 ifTrue: [^0].
	t := 1 / (1 - (constant * aNumber)).
	^(series value: t) * t * (self normal: aNumber)
    ]

    initialize [
	"Private - Initialize constants needed to evaluate the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/1/99"

	<category: 'initialization'>
	constant := 0.2316419.
	norm := 1 / (FloatD pi * 2) sqrt.
	series := DhbPolynomial 
		    coefficients: #(0.31938153 -0.356563782 1.781477937 -1.821255978 1.330274429)
    ]
]

PK    �Mh@�-Q�   �  	  ChangeLogUT	 dqXOȉXOux �  �  �P�N�@<w��7D�$ ����*�@A�p�nd��h��lDUN=��glWEYde�7 �h��ƚ=��Svߙ�[�-��]B��;��jؐ���~��=���6z��X�v>�-.gZ,��ف5�&��
�,��}p��Cˏ�*�W�ٓ	Թ��3&�@w59�~�ݞ��ï�KX����Y?��-$̇�NeIK2��Ecȍ��Yq���g���V<��PT�RF���KZE����]C�\� PK
     �Mh@�����  �    Matrixes.stUT	 dqXOȉXOux �  �  "======================================================================
|
|   Numerical methods - Matrixes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: DhbMatrix [
    | rows lupDecomposition |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbMatrix class >> join: anArrayOfMatrices [
	"Inverse of the split operation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/5/99"

	<category: 'creation'>
	| rows n row rowSize n1 n2 |
	rows := OrderedCollection new.
	n1 := (anArrayOfMatrices at: 1) numberOfColumns.
	n2 := n1 + 1.
	rowSize := n1 + (anArrayOfMatrices at: 2) numberOfColumns.
	n := 0.
	(anArrayOfMatrices at: 1) rowsDo: 
		[:each | 
		n := n + 1.
		row := DhbVector new: rowSize.
		row
		    replaceFrom: 1
			to: n1
			with: each
			startingAt: 1;
		    replaceFrom: n2
			to: rowSize
			with: ((anArrayOfMatrices at: 2) rowAt: n)
			startingAt: 1.
		rows add: row].
	n := 0.
	(anArrayOfMatrices at: 3) rowsDo: 
		[:each | 
		n := n + 1.
		row := DhbVector new: rowSize.
		row
		    replaceFrom: 1
			to: n1
			with: each
			startingAt: 1;
		    replaceFrom: n2
			to: rowSize
			with: ((anArrayOfMatrices at: 4) rowAt: n)
			startingAt: 1.
		rows add: row].
	^self rows: rows
    ]

    DhbMatrix class >> new: anInteger [
	"Create an empty square matrix of dimension anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initialize: anInteger
    ]

    DhbMatrix class >> rows: anArrayOrVector [
	"Create a new matrix with given components.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initializeRows: anArrayOrVector
    ]

    DhbMatrix class >> lupCRLCriticalDimension [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'information'>
	^40
    ]

    = aNumberOrMatrix [
	<category: 'comparing'>
	aNumberOrMatrix isNil ifTrue: [^false].
	aNumberOrMatrix isNumber 
	    ifTrue: 
		[^(self numberOfRows = 1 and: [self numberOfColumns = 1]) 
		    and: [(self rowAt: 1 columnAt: 1) = aNumberOrMatrix]].
	aNumberOrMatrix class = self class ifFalse: [^false].
	^self rows = aNumberOrMatrix rows
    ]

    hash [
	<category: 'comparing'>
	^rows hash
    ]

    printOn: aStream [
	"Append to the argument aStream, a sequence of characters that describes the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'display'>
	| first |
	first := true.
	rows do: 
		[:each | 
		first ifTrue: [first := false] ifFalse: [aStream cr].
		each printOn: aStream]
    ]

    addWithMatrix: aMatrix class: aMatrixClass [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	| n |
	n := 0.
	^aMatrixClass 
	    rows: (self rowsCollect: 
			[:each | 
			n := n + 1.
			each + (aMatrix rowAt: n)])
    ]

    addWithRegularMatrix: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^aMatrix addWithMatrix: self class: aMatrix class
    ]

    addWithSymmetricMatrix: aMatrix [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/28/99"

	<category: 'double dispatching'>
	^aMatrix addWithMatrix: self class: self class
    ]

    productFromNumber: aFloatD [
	<category: 'double dispatching'>
	^self * aFloatD
    ]

    productWithMatrix: aMatrix [
	"Answers the product of aMatrix with the receiver (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self productWithMatrixFinal: aMatrix
    ]

    productWithMatrixFinal: aMatrix [
	"Answers the product of aMatrix with the receiver (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self class rows: (aMatrix 
		    rowsCollect: [:row | self columnsCollect: [:col | row * col]])
    ]

    productWithSymmetricMatrix: aSymmetricMatrix [
	"Answers the product of the receiver with aSymmetricMatrix (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self class rows: (self 
		    rowsCollect: [:row | aSymmetricMatrix columnsCollect: [:col | row * col]])
    ]

    productWithTransposeMatrix: aMatrix [
	"Answers the product of the receiver with the transpose of aMatrix(in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self class 
	    rows: (self rowsCollect: [:row | aMatrix rowsCollect: [:col | row * col]])
    ]

    productWithVector: aVector [
	"Answers the product of the receiver with aVector
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self columnsCollect: [:each | each * aVector]
    ]

    subtractWithMatrix: aMatrix class: aMatrixClass [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	| n |
	n := 0.
	^aMatrixClass 
	    rows: (self rowsCollect: 
			[:each | 
			n := n + 1.
			each - (aMatrix rowAt: n)])
    ]

    subtractWithRegularMatrix: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^aMatrix subtractWithMatrix: self class: aMatrix class
    ]

    subtractWithSymmetricMatrix: aMatrix [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/28/99"

	<category: 'double dispatching'>
	^aMatrix subtractWithMatrix: self class: self class
    ]

    transposeProductWithMatrix: aMatrix [
	"Answers the product of the transpose of the receiver with aMatrix (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'double dispatching'>
	^self class rows: (self 
		    columnsCollect: [:row | aMatrix columnsCollect: [:col | row * col]])
    ]

    columnAt: anInteger [
	"Answers the anInteger-th column of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^rows collect: [:each | each at: anInteger]
    ]

    determinant [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'information'>
	^self lupDecomposition determinant
    ]

    isSquare [
	"Answers true if the number of rows is equal to the number of columns.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^rows size = rows last size
    ]

    isSymmetric [
	"Answers false because the receiver is not a symmetric matrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^false
    ]

    largestPowerOf2SmallerThan: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved
	 Initial code: 21/3/99"

	<category: 'information'>
	| m m2 |
	m := 2.
	
	[m2 := m * 2.
	m2 < anInteger] whileTrue: [m := m2].
	^m
    ]

    lupDecomposition [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'information'>
	lupDecomposition isNil 
	    ifTrue: [lupDecomposition := DhbLUPDecomposition equations: rows].
	^lupDecomposition
    ]

    numberOfColumns [
	"Answer the number of rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^rows last size
    ]

    numberOfRows [
	"Answer the number of rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^rows size
    ]

    rowAt: anInteger [
	"Answers the anInteger-th row of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^rows at: anInteger
    ]

    rowAt: aRowIndex columnAt: aColumnIndex [
	"Answers the aRowIndex-th, aColumnIndex-th entry in the receiver.
	 (c) Copyrights Joseph WHITESELL, 2001, all rights reserved.
	 Initial code: 08/17/2001"

	<category: 'information'>
	^(rows at: aRowIndex) at: aColumnIndex
    ]

    rowAt: aRowIndex columnAt: aColumnIndex put: aValue [
	<category: 'information'>
	^(rows at: aRowIndex) at: aColumnIndex put: aValue
    ]

    rows [
	<category: 'information'>
	^rows
    ]

    transpose [
	"Answer a new matrix, transpose of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^self class rows: (self columnsCollect: [:each | each])
    ]

    initialize: anInteger [
	"Build empty components for a square matrix.
	 No check is made: components are assumed to be orgainized in rows.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	rows := (1 to: anInteger) asVector 
		    collect: [:each | DhbVector new: anInteger]
    ]

    initializeRows: anArrayOrVector [
	"Defines the components of the recevier.
	 No check is made: components are assumed to be orgainized in rows.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	rows := anArrayOrVector asVector collect: [:each | each asVector]
    ]

    columnsCollect: aBlock [
	"Perform the collect: operation on the rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'iterators'>
	| n |
	n := 0.
	^rows last collect: 
		[:each | 
		n := n + 1.
		aBlock value: (self columnAt: n)]
    ]

    columnsDo: aBlock [
	"Perform the collect: operation on the rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'iterators'>
	| n |
	n := 0.
	^rows last do: 
		[:each | 
		n := n + 1.
		aBlock value: (self columnAt: n)]
    ]

    rowsCollect: aBlock [
	"Perform the collect: operation on the rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'iterators'>
	^rows collect: aBlock
    ]

    rowsDo: aBlock [
	"Perform the collect: operation on the rows of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'iterators'>
	^rows do: aBlock
    ]

    * aNumberOrMatrixOrVector [
	"Answers the product of the receiver with the argument.
	 The argument can be a number, matrix or vector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aNumberOrMatrixOrVector productWithMatrix: self
    ]

    + aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix addWithRegularMatrix: self
    ]

    - aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix subtractWithRegularMatrix: self
    ]

    inverse [
	"Answer the inverse of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^self isSquare 
	    ifTrue: [self lupInverse]
	    ifFalse: [self squared inverse * self transpose]
    ]

    inversePureCRL [
	"Answer the inverse of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 5/5/99"

	<category: 'operation'>
	^self squared inversePureCRL * self transpose
    ]

    lupInverse [
	<category: 'operation'>
	^self class rows: self lupDecomposition inverseMatrixComponents
    ]

    squared [
	"Answers the product of the transpose of the receiver with the receiver (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^DhbSymmetricMatrix rows: (self 
		    columnsCollect: [:col | self columnsCollect: [:colT | col * colT]])
    ]

    strassenProductWithMatrix: aMatrix [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/5/99"

	<category: 'operation'>
	| matrixSplit selfSplit p1 p2 p3 p4 p5 p6 p7 |
	(self numberOfRows > 2 and: [self numberOfColumns > 2]) 
	    ifFalse: 
		[^self class rows: (aMatrix 
			    rowsCollect: [:row | self columnsCollect: [:col | row * col]])].
	selfSplit := self split.
	matrixSplit := aMatrix split.
	p1 := (selfSplit at: 2) - (selfSplit at: 4) 
		    strassenProductWithMatrix: (matrixSplit at: 1).
	p2 := (selfSplit at: 4) 
		    strassenProductWithMatrix: (matrixSplit at: 1) + (matrixSplit at: 2).
	p3 := (selfSplit at: 1) 
		    strassenProductWithMatrix: (matrixSplit at: 3) + (matrixSplit at: 4).
	p4 := (selfSplit at: 3) - (selfSplit at: 1) 
		    strassenProductWithMatrix: (matrixSplit at: 4).
	p5 := (selfSplit at: 1) + (selfSplit at: 4) 
		    strassenProductWithMatrix: (matrixSplit at: 1) + (matrixSplit at: 4).
	p6 := (selfSplit at: 3) + (selfSplit at: 4) 
		    strassenProductWithMatrix: (matrixSplit at: 2) - (matrixSplit at: 4).
	p7 := (selfSplit at: 1) + (selfSplit at: 2) 
		    strassenProductWithMatrix: (matrixSplit at: 1) - (matrixSplit at: 3).
	^self class join: (Array 
		    with: p5 + p4 + p6 - p2
		    with: p1 + p2
		    with: p3 + p4
		    with: p5 + p1 - p3 - p7)
    ]

    accumulate: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	| n |
	n := 0.
	self rowsCollect: 
		[:each | 
		n := n + 1.
		each accumulate: (aMatrix rowAt: n)]
    ]

    accumulateNegated: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	| n |
	n := 0.
	self rowsCollect: 
		[:each | 
		n := n + 1.
		each accumulateNegated: (aMatrix rowAt: n)]
    ]

    asSymmetricMatrix [
	"Convert the receiver to a symmetric matrix (no check is made).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	^DhbSymmetricMatrix rows: rows
    ]

    negate [
	"Inverse the sign of all components of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	rows do: [:each | each negate]
    ]

    scaleBy: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/11/00"

	<category: 'transformation'>
	rows do: [:each | each scaleBy: aNumber]
    ]

    split [
	"Private - Answers an array of 4 matrices split from the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/5/99"

	<category: 'transformation'>
	| n m n1 m1 |
	n := self numberOfRows.
	m := self numberOfColumns.
	n1 := self largestPowerOf2SmallerThan: n.
	m1 := self largestPowerOf2SmallerThan: m.
	^Array 
	    with: (self class 
		    rows: ((1 to: n1) asVector collect: [:k | (rows at: k) copyFrom: 1 to: m1]))
	    with: (self class rows: ((1 to: n1) asVector 
			    collect: [:k | (rows at: k) copyFrom: m1 + 1 to: m]))
	    with: (self class rows: ((n1 + 1 to: n) asVector 
			    collect: [:k | (rows at: k) copyFrom: 1 to: m1]))
	    with: (self class rows: ((n1 + 1 to: n) asVector 
			    collect: [:k | (rows at: k) copyFrom: m1 + 1 to: m]))
    ]
]



Object subclass: DhbLUPDecomposition [
    | rows permutation parity |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLUPDecomposition class >> direct: anArrayOfArrays [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'creation'>
	^self new initialize: anArrayOfArrays
    ]

    DhbLUPDecomposition class >> equations: anArrayOfArrays [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'creation'>
	^self new initialize: (anArrayOfArrays collect: [:each | each copy])
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'display'>
	| first delimitingString n k |
	n := rows size.
	first := true.
	rows do: 
		[:row | 
		first ifTrue: [first := false] ifFalse: [aStream cr].
		delimitingString := '('.
		row do: 
			[:each | 
			aStream nextPutAll: delimitingString.
			each printOn: aStream.
			delimitingString := ' '].
		aStream nextPut: $)]
    ]

    determinant [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'information'>
	| n |
	permutation isNil ifTrue: [self protectedDecomposition].
	permutation = 0 ifTrue: [^0].	"Singular matrix has 0 determinant"
	n := 0.
	^rows inject: parity
	    into: 
		[:det :each | 
		n := n + 1.
		(each at: n) * det]
    ]

    inverseMatrixComponents [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'information'>
	| n inverseRows column |
	permutation isNil ifTrue: [self protectedDecomposition].
	permutation = 0 ifTrue: [^nil].	"Singular matrix has no inverse"
	n := rows size.
	inverseRows := (1 to: n) asVector collect: [:j | DhbVector new: n].
	1 to: n
	    do: 
		[:j | 
		column := self solve: ((Array new: rows size)
				    atAllPut: 0;
				    at: j put: 1;
				    yourself).
		1 to: n do: [:i | (inverseRows at: i) at: j put: (column at: i)]].
	^inverseRows
    ]

    largestPivotFrom: anInteger [
	"Private - Answers the largest pivot element in column anInteger, from position anInteger upward.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	| valueOfMaximum indexOfMaximum value |
	valueOfMaximum := ((rows at: anInteger) at: anInteger) abs.
	indexOfMaximum := anInteger.
	anInteger + 1 to: rows size
	    do: 
		[:n | 
		value := ((rows at: n) at: anInteger) abs.
		value > valueOfMaximum 
		    ifTrue: 
			[valueOfMaximum := value.
			indexOfMaximum := n]].
	^indexOfMaximum
    ]

    initialize: anArrayOfArrays [
	"Private - A copy of the original array is made.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'initialization'>
	rows := anArrayOfArrays.
	parity := 1.
	^self
    ]

    backwardSubstitution: anArray [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	| n sum answer |
	n := rows size.
	answer := DhbVector new: n.
	n to: 1
	    by: -1
	    do: 
		[:i | 
		sum := anArray at: i.
		i + 1 to: n do: [:j | sum := sum - (((rows at: i) at: j) * (answer at: j))].
		answer at: i put: sum / ((rows at: i) at: i)].
	^answer
    ]

    decompose [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	| n |
	n := rows size.
	permutation := (1 to: n) asArray.
	1 to: n - 1
	    do: 
		[:k | 
		self
		    swapRow: k withRow: (self largestPivotFrom: k);
		    pivotAt: k]
    ]

    forwardSubstitution: anArray [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	| n sum answer |
	answer := permutation collect: [:each | anArray at: each].
	n := rows size.
	2 to: n
	    do: 
		[:i | 
		sum := answer at: i.
		1 to: i - 1 do: [:j | sum := sum - (((rows at: i) at: j) * (answer at: j))].
		answer at: i put: sum].
	^answer
    ]

    pivotAt: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	| inversePivot size k |
	inversePivot := 1 / ((rows at: anInteger) at: anInteger).
	size := rows size.
	k := anInteger + 1.
	k to: size
	    do: 
		[:i | 
		(rows at: i) at: anInteger put: ((rows at: i) at: anInteger) * inversePivot.
		k to: size
		    do: 
			[:j | 
			(rows at: i) at: j
			    put: ((rows at: i) at: j) 
				    - (((rows at: i) at: anInteger) * ((rows at: anInteger) at: j))]]
    ]

    protectedDecomposition [
	"Private - If decomposition fails, set permutation to 0.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	[self decompose] on: Error
	    do: 
		[:signal | 
		permutation := 0.
		signal return: nil]
    ]

    solve: anArrayOrVector [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 30/3/99"

	<category: 'transformation'>
	permutation isNil ifTrue: [self protectedDecomposition].
	^permutation = 0 
	    ifTrue: [nil]
	    ifFalse: 
		[self backwardSubstitution: (self forwardSubstitution: anArrayOrVector)]
    ]

    swapRow: anInteger1 withRow: anInteger2 [
	"Private - Swap the rows indexed by the given integers.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	anInteger1 = anInteger2 
	    ifFalse: 
		[| swappedRow |
		swappedRow := rows at: anInteger1.
		rows at: anInteger1 put: (rows at: anInteger2).
		rows at: anInteger2 put: swappedRow.
		swappedRow := permutation at: anInteger1.
		permutation at: anInteger1 put: (permutation at: anInteger2).
		permutation at: anInteger2 put: swappedRow.
		parity := parity negated]
    ]
]



DhbIterativeProcess subclass: DhbJacobiTransformation [
    | lowerRows transform |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbJacobiTransformation class >> matrix: aSymmetricMatrix [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'creation'>
	^super new initialize: aSymmetricMatrix
    ]

    DhbJacobiTransformation class >> new [
	"Prevent using this message to create instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    printOn: aStream [
	"Append to the argument aStream, a sequence of characters that describes the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'display'>
	| first |
	first := true.
	lowerRows do: 
		[:each | 
		first ifTrue: [first := false] ifFalse: [aStream cr].
		each printOn: aStream]
    ]

    largestOffDiagonalIndices [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'information'>
	| n m abs |
	n := 2.
	m := 1.
	precision := ((lowerRows at: n) at: m) abs.
	1 to: lowerRows size
	    do: 
		[:i | 
		1 to: i - 1
		    do: 
			[:j | 
			abs := ((lowerRows at: i) at: j) abs.
			abs > precision 
			    ifTrue: 
				[n := i.
				m := j.
				precision := abs]]].
	^Array with: m with: n
    ]

    transform [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'information'>
	^DhbMatrix rows: transform
    ]

    initialize: aSymmetricMatrix [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'initialization'>
	| n m |
	n := aSymmetricMatrix numberOfRows.
	lowerRows := Array new: n.
	transform := Array new: n.
	1 to: n
	    do: 
		[:k | 
		lowerRows at: k put: ((aSymmetricMatrix rowAt: k) copyFrom: 1 to: k).
		transform at: k
		    put: ((Array new: n)
			    atAllPut: 0;
			    at: k put: 1;
			    yourself)].
	^self
    ]

    evaluateIteration [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'operation'>
	| indices |
	indices := self largestOffDiagonalIndices.
	self transformAt: (indices at: 1) and: (indices at: 2).
	^precision
    ]

    finalizeIterations [
	"Transfer the eigenValues into a vector and set this as the result.
	 eigen values and transform matrix are sorted using a bubble sort.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'operation'>
	| n |
	n := 0.
	result := lowerRows collect: 
			[:each | 
			n := n + 1.
			each at: n].
	self sortEigenValues
    ]

    exchangeAt: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'transformation'>
	| temp n |
	n := anInteger + 1.
	temp := result at: n.
	result at: n put: (result at: anInteger).
	result at: anInteger put: temp.
	transform do: 
		[:each | 
		temp := each at: n.
		each at: n put: (each at: anInteger).
		each at: anInteger put: temp]
    ]

    sortEigenValues [
	"Private - Use a bubble sort.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'transformation'>
	| n bound m |
	n := lowerRows size.
	bound := n.
	[bound = 0] whileFalse: 
		[m := 0.
		1 to: bound - 1
		    do: 
			[:j | 
			(result at: j) abs > (result at: j + 1) abs 
			    ifFalse: 
				[self exchangeAt: j.
				m := j]].
		bound := m]
    ]

    transformAt: anInteger1 and: anInteger2 [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 1/6/99"

	<category: 'transformation'>
	| d t s c tau apq app aqq arp arq |
	apq := (lowerRows at: anInteger2) at: anInteger1.
	apq = 0 ifTrue: [^nil].
	app := (lowerRows at: anInteger1) at: anInteger1.
	aqq := (lowerRows at: anInteger2) at: anInteger2.
	d := aqq - app.
	arp := d * 0.5 / apq.
	t := arp > 0 
		    ifTrue: [1 / ((arp squared + 1) sqrt + arp)]
		    ifFalse: [1 / (arp - (arp squared + 1) sqrt)].
	c := 1 / (t squared + 1) sqrt.
	s := t * c.
	tau := s / (1 + c).
	1 to: anInteger1 - 1
	    do: 
		[:r | 
		arp := (lowerRows at: anInteger1) at: r.
		arq := (lowerRows at: anInteger2) at: r.
		(lowerRows at: anInteger1) at: r put: arp - (s * (tau * arp + arq)).
		(lowerRows at: anInteger2) at: r put: arq + (s * (arp - (tau * arq)))].
	anInteger1 + 1 to: anInteger2 - 1
	    do: 
		[:r | 
		arp := (lowerRows at: r) at: anInteger1.
		arq := (lowerRows at: anInteger2) at: r.
		(lowerRows at: r) at: anInteger1 put: arp - (s * (tau * arp + arq)).
		(lowerRows at: anInteger2) at: r put: arq + (s * (arp - (tau * arq)))].
	anInteger2 + 1 to: lowerRows size
	    do: 
		[:r | 
		arp := (lowerRows at: r) at: anInteger1.
		arq := (lowerRows at: r) at: anInteger2.
		(lowerRows at: r) at: anInteger1 put: arp - (s * (tau * arp + arq)).
		(lowerRows at: r) at: anInteger2 put: arq + (s * (arp - (tau * arq)))].
	1 to: lowerRows size
	    do: 
		[:r | 
		arp := (transform at: r) at: anInteger1.
		arq := (transform at: r) at: anInteger2.
		(transform at: r) at: anInteger1 put: arp - (s * (tau * arp + arq)).
		(transform at: r) at: anInteger2 put: arq + (s * (arp - (tau * arq)))].
	(lowerRows at: anInteger1) at: anInteger1 put: app - (t * apq).
	(lowerRows at: anInteger2) at: anInteger2 put: aqq + (t * apq).
	(lowerRows at: anInteger2) at: anInteger1 put: 0
    ]
]



DhbIterativeProcess subclass: DhbLargestEigenValueFinder [
    | matrix eigenvector transposeEigenvector |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbLargestEigenValueFinder class >> matrix: aMatrix [
	"Create a new instance of the receiver for a given matrix and default precision.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^(self new)
	    initialize: aMatrix;
	    yourself
    ]

    DhbLargestEigenValueFinder class >> matrix: aMatrix precision: aNumber [
	"Create a new instance of the receiver for a given matrix and desired precision.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^(self new)
	    initialize: aMatrix;
	    desiredPrecision: aNumber;
	    yourself
    ]

    DhbLargestEigenValueFinder class >> defaultMaximumIterations [
	"Private - Answers the default maximum number of iterations for newly created instances.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'information'>
	^100
    ]

    nextLargestEigenValueFinder [
	"Return an eigen value finder for the same eigen values of the receiver except the one found.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	| norm |
	norm := 1 / (eigenvector * transposeEigenvector).
	^self class 
	    matrix: matrix * ((DhbSymmetricMatrix identity: eigenvector size) 
			    - (eigenvector * norm tensorProduct: transposeEigenvector))
	    precision: desiredPrecision
    ]

    eigenvalue [
	"Answer the eigen value found by the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^result
    ]

    eigenvector [
	"Answer the normalized eigen vector found by the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^eigenvector * (1 / eigenvector norm)
    ]

    initialize: aMatrix [
	"Defines the matrix for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	matrix := aMatrix
    ]

    evaluateIteration [
	"Iterate the product of the matrix of the eigen vector and the transpose.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| oldEigenvalue |
	oldEigenvalue := result.
	transposeEigenvector := transposeEigenvector * matrix.
	transposeEigenvector := transposeEigenvector 
		    * (1 / (transposeEigenvector at: 1)).
	eigenvector := matrix * eigenvector.
	result := eigenvector at: 1.
	eigenvector := eigenvector * (1 / result).
	^oldEigenvalue isNil 
	    ifTrue: [2 * desiredPrecision]
	    ifFalse: [(result - oldEigenvalue) abs]
    ]

    initializeIterations [
	"Initialize the iterations (subclasses must write their own method and call this one last).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	eigenvector := DhbVector new: matrix numberOfRows.
	eigenvector atAllPut: 1.0.
	transposeEigenvector := DhbVector new: eigenvector size.
	transposeEigenvector atAllPut: 1.0
    ]
]



Object subclass: DhbLinearEquationSystem [
    | rows solutions |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLinearEquationSystem class >> equations: anArrayOfArrays constant: anArray [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initialize: anArrayOfArrays constants: (Array with: anArray)
    ]

    DhbLinearEquationSystem class >> equations: anArrayOfArrays constants: anArrayOfConstantArrays [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initialize: anArrayOfArrays constants: anArrayOfConstantArrays
    ]

    printOn: aStream [
	"Append to the argument aStream, a sequence of characters that describes the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'display'>
	| first delimitingString n k |
	n := rows size.
	first := true.
	rows do: 
		[:row | 
		first ifTrue: [first := false] ifFalse: [aStream cr].
		delimitingString := '('.
		k := 0.
		row do: 
			[:each | 
			aStream nextPutAll: delimitingString.
			each printOn: aStream.
			k := k + 1.
			delimitingString := k < n ifTrue: [' '] ifFalse: [' : ']].
		aStream nextPut: $)]
    ]

    largestPivotFrom: anInteger [
	"Private - Answers the largest pivot element in column anInteger, from position anInteger upward.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	| valueOfMaximum indexOfMaximum |
	valueOfMaximum := (rows at: anInteger) at: anInteger.
	indexOfMaximum := anInteger.
	anInteger + 2 to: rows size
	    do: 
		[:n | 
		((rows at: n) at: anInteger) > valueOfMaximum 
		    ifTrue: 
			[valueOfMaximum := (rows at: n) at: anInteger.
			indexOfMaximum := n]].
	^indexOfMaximum
    ]

    solution [
	"Answers the solution corresponding to the first constant array.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	^self solutionAt: 1
    ]

    solutionAt: anInteger [
	"Answer the solution corresponding to the anInteger-th constant array.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	"solutions isNil
	 ifTrue: [ [self solve] when: Error do: [ :signal |solutions := 0. signal return: nil.] ].
	 solutions = 0
	 ifTrue: [ ^nil].
	 ( solutions at: anInteger) isNil
	 ifTrue: [ self backSubstitutionAt: anInteger].
	 ^solutions at: anInteger"

	<category: 'information'>
	solutions isNil 
	    ifTrue: 
		[[self solve] on: Error
		    do: 
			[:signal | 
			solutions := 0.
			signal return: nil]].
	solutions = 0 ifTrue: [^nil].
	(solutions at: anInteger) isNil 
	    ifTrue: [self backSubstitutionAt: anInteger].
	^solutions at: anInteger
    ]

    initialize: anArrayOfArrays constants: anArrayOfConstantArrays [
	"Private - Initialize the receiver with system's matrix in anArrayOfArrays and several constants.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	| n |
	n := 0.
	rows := anArrayOfArrays collect: 
			[:each | 
			n := n + 1.
			each , (anArrayOfConstantArrays collect: [:c | c at: n])].
	^self
    ]

    backSubstitutionAt: anInteger [
	"Private - Perform the back-substitution step corresponding to the anInteger-th constant array.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	| size answer accumulator |
	size := rows size.
	answer := Array new: size.
	size to: 1
	    by: -1
	    do: 
		[:n | 
		accumulator := (rows at: n) at: anInteger + size.
		n + 1 to: size
		    do: [:m | accumulator := accumulator - ((answer at: m) * ((rows at: n) at: m))].
		answer at: n put: accumulator / ((rows at: n) at: n)].
	solutions at: anInteger put: answer
    ]

    pivotAt: anInteger [
	"Private - Performs pivot operation with pivot element at anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	| inversePivot rowPivotValue row pivotRow |
	pivotRow := rows at: anInteger.
	inversePivot := 1 / (pivotRow at: anInteger).
	anInteger + 1 to: rows size
	    do: 
		[:n | 
		row := rows at: n.
		rowPivotValue := (row at: anInteger) * inversePivot.
		anInteger to: row size
		    do: [:m | row at: m put: (row at: m) - ((pivotRow at: m) * rowPivotValue)]]
    ]

    pivotStepAt: anInteger [
	"Private - Performs an optimum pivot operation at anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	self
	    swapRow: anInteger withRow: (self largestPivotFrom: anInteger);
	    pivotAt: anInteger
    ]

    solve [
	"Private - Perform LU decomposition of the system.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	1 to: rows size do: [:n | self pivotStepAt: n].
	solutions := Array new: (rows at: 1) size - rows size
    ]

    swapRow: anInteger1 withRow: anInteger2 [
	"Private - Swap the rows indexed by the given integers.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	| swappedRow |
	anInteger1 = anInteger2 
	    ifFalse: 
		[swappedRow := rows at: anInteger1.
		rows at: anInteger1 put: (rows at: anInteger2).
		rows at: anInteger2 put: swappedRow]
    ]
]



DhbMatrix subclass: DhbSymmetricMatrix [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbSymmetricMatrix class >> identity: anInteger [
	"Create an identity matrix of dimension anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	^self new initializeIdentity: anInteger
    ]

    DhbSymmetricMatrix class >> join: anArrayOfMatrices [
	"Inverse of the split operation.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'creation'>
	| rows n |
	rows := OrderedCollection new.
	n := 0.
	(anArrayOfMatrices at: 1) rowsDo: 
		[:each | 
		n := n + 1.
		rows add: each , ((anArrayOfMatrices at: 3) columnAt: n)].
	n := 0.
	(anArrayOfMatrices at: 2) rowsDo: 
		[:each | 
		n := n + 1.
		rows add: ((anArrayOfMatrices at: 3) rowAt: n) , each].
	^self rows: rows
    ]

    DhbSymmetricMatrix class >> lupCRLCriticalDimension [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'information'>
	^36
    ]

    isSquare [
	"Answers true because a symmetric matrix is square.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^true
    ]

    isSymmetric [
	"Answers true because the receiver is a symmetric matrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'information'>
	^true
    ]

    clear [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/11/00"

	<category: 'initialization'>
	rows do: [:each | each atAllPut: 0]
    ]

    initializeIdentity: anInteger [
	"Build components for an identity matrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'initialization'>
	rows := (1 to: anInteger) asVector collect: 
			[:n | 
			(DhbVector new: anInteger)
			    atAllPut: 0;
			    at: n put: 1;
			    yourself]
    ]

    + aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix addWithSymmetricMatrix: self
    ]

    - aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix subtractWithSymmetricMatrix: self
    ]

    addWithSymmetricMatrix: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix addWithMatrix: self class: self class
    ]

    crlInverse [
	<category: 'operation'>
	| matrices b1 cb1ct cb1 |
	matrices := self split.
	b1 := (matrices at: 1) inverse.
	cb1 := (matrices at: 3) * b1.
	cb1ct := (cb1 productWithTransposeMatrix: (matrices at: 3)) 
		    asSymmetricMatrix.
	matrices at: 3 put: (matrices at: 2) * cb1.
	matrices at: 2 put: ((matrices at: 2) accumulateNegated: cb1ct) inverse.
	matrices at: 1
	    put: (b1 accumulate: (cb1 transposeProductWithMatrix: (matrices at: 3))).
	(matrices at: 3) negate.
	^self class join: matrices
    ]

    inverse [
	"Answer the inverse of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^(rows size < self class lupCRLCriticalDimension 
	    or: [lupDecomposition notNil]) 
		ifTrue: [self lupInverse]
		ifFalse: [self crlInverse]
    ]

    inverse1By1 [
	"Private - Answer the inverse of the receiver when it is a 1x1 matrix (no check is made).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'operation'>
	^self class 
	    rows: (DhbVector with: (DhbVector with: 1 / ((rows at: 1) at: 1)))
    ]

    inverse2By2 [
	"Private - Answer the inverse of the receiver when it is a 2x2 matrix (no check is made).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/5/99"

	<category: 'operation'>
	| line1 line2 |
	line1 := DhbVector with: ((rows at: 2) at: 2)
		    with: ((rows at: 1) at: 2) negated.
	line2 := DhbVector with: ((rows at: 1) at: 2) negated
		    with: ((rows at: 1) at: 1).
	^self class rows: (DhbVector with: line1 with: line2) 
		    * (1 / (((rows at: 1) at: 1) * ((rows at: 2) at: 2) 
				    - ((rows at: 1) at: 2) squared))
    ]

    inversePureCRL [
	"Answer the inverse of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	| matrices b1 cb1 cb1ct |
	rows size = 1 ifTrue: [^self inverse1By1].
	rows size = 2 ifTrue: [^self inverse2By2].
	matrices := self split.
	b1 := (matrices at: 1) inversePureCRL.
	cb1 := (matrices at: 3) * b1.
	cb1ct := (cb1 productWithTransposeMatrix: (matrices at: 3)) 
		    asSymmetricMatrix.
	matrices at: 2
	    put: ((matrices at: 2) accumulateNegated: cb1ct) inversePureCRL.
	matrices at: 3 put: (matrices at: 2) * cb1.
	matrices at: 1
	    put: (b1 accumulate: (cb1 transposeProductWithMatrix: (matrices at: 3))).
	(matrices at: 3) negate.
	^self class join: matrices
    ]

    inversePureLUP [
	"Answer the inverse of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	lupDecomposition := nil.
	^self class rows: lupDecomposition inverseMatrixComponents
    ]

    productWithMatrix: aMatrix [
	"Answers the product of aMatrix with the receiver (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix productWithSymmetricMatrix: self
    ]

    productWithSymmetricMatrix: aSymmetricMatrix [
	"Answers the product of aMatrix with the receiver (in this order).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aSymmetricMatrix productWithMatrixFinal: self
    ]

    subtractWithSymmetricMatrix: aMatrix [
	"Answers the sum of the receiver with aMatrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'operation'>
	^aMatrix subtractWithMatrix: self class: self class
    ]

    split [
	"Private -
	 Answers an array of 3 matrices split from the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/2/99"

	<category: 'transformation'>
	| n |
	n := self largestPowerOf2SmallerThan: rows size.
	^Array 
	    with: (self class 
		    rows: ((1 to: n) asVector collect: [:k | (rows at: k) copyFrom: 1 to: n]))
	    with: (self class rows: ((n + 1 to: rows size) asVector 
			    collect: [:k | (rows at: k) copyFrom: n + 1 to: rows size]))
	    with: (self class superclass rows: ((n + 1 to: rows size) asVector 
			    collect: [:k | (rows at: k) copyFrom: 1 to: n]))
    ]
]

PK
     �Mh@�e7z z   Statistics.stUT	 dqXOȉXOux �  �  "======================================================================
|
|   Numerical methods - Statistics
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: DhbStatisticalMoments [
    | moments |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbStatisticalMoments class >> new [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'creation'>
	^self new: 4
    ]

    DhbStatisticalMoments class >> new: anInteger [
	"anInteger is the degree of the highest central moments
	 accumulated within the created instance.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'creation'>
	^super new initialize: anInteger + 1
    ]

    asWeightedPoint: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'creation'>
	^DhbWeightedPoint point: aNumber @ self average error: self errorOnAverage
    ]

    average [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'information'>
	self count = 0 ifTrue: [^nil].
	^moments at: 2
    ]

    centralMoment: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/6/99"

	<category: 'information'>
	^moments at: anInteger + 1
    ]

    count [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/6/99"

	<category: 'information'>
	^moments at: 1
    ]

    errorOnAverage [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 02-Jan-00"

	<category: 'information'>
	^(self variance / self count) sqrt
    ]

    kurtosis [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'information'>
	| n n1 n23 |
	n := self count.
	n < 4 ifTrue: [^nil].
	n23 := (n - 2) * (n - 3).
	n1 := n - 1.
	^((moments at: 5) * n squared * (n + 1) / (self variance squared * n1) 
	    - (n1 squared * 3)) / n23
    ]

    skewness [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'information'>
	| n v |
	n := self count.
	n < 3 ifTrue: [^nil].
	v := self variance.
	^(moments at: 4) * n squared / ((n - 1) * (n - 2) * (v sqrt * v))
    ]

    standardDeviation [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'information'>
	^self variance sqrt
    ]

    unnormalizedVariance [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'information'>
	^(self centralMoment: 2) * self count
    ]

    variance [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'information'>
	| n |
	n := self count.
	n < 2 ifTrue: [^nil].
	^self unnormalizedVariance / (n - 1)
    ]

    initialize: anInteger [
	"Private - ( anInteger - 1) is the degree of the highest accumulated central moment.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'initialization'>
	moments := Array new: anInteger.
	self reset.
	^self
    ]

    fConfidenceLevel: aStatisticalMomentsOrHistogram [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'testing'>
	| fValue |
	fValue := self variance / aStatisticalMomentsOrHistogram variance.
	^fValue < 1 
	    ifTrue: 
		[(DhbFisherSnedecorDistribution 
		    degreeOfFreedom: aStatisticalMomentsOrHistogram count
		    degreeOfFreedom: self count) confidenceLevel: fValue reciprocal]
	    ifFalse: 
		[(DhbFisherSnedecorDistribution degreeOfFreedom: self count
		    degreeOfFreedom: aStatisticalMomentsOrHistogram count) 
			confidenceLevel: fValue]
    ]

    tConfidenceLevel: aStatisticalMomentsOrHistogram [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'testing'>
	| sbar dof |
	dof := self count + aStatisticalMomentsOrHistogram count - 2.
	sbar := ((self unnormalizedVariance 
		    + aStatisticalMomentsOrHistogram unnormalizedVariance) / dof) 
		    sqrt.
	^(DhbStudentDistribution degreeOfFreedom: dof) 
	    confidenceLevel: (self average - aStatisticalMomentsOrHistogram average) 
		    / ((1 / self count + (1 / aStatisticalMomentsOrHistogram count)) sqrt 
			    * sbar)
    ]

    accumulate: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'transformation'>
	| correction n n1 oldSums pascal nTerm cTerm term |
	n := moments at: 1.
	n1 := n + 1.
	correction := ((moments at: 2) - aNumber) / n1.
	oldSums := moments copyFrom: 1 to: moments size.
	moments
	    at: 1 put: n1;
	    at: 2 put: (moments at: 2) - correction.
	pascal := Array new: moments size.
	pascal atAllPut: 0.
	pascal
	    at: 1 put: 1;
	    at: 2 put: 1.
	nTerm := -1.
	cTerm := correction.
	n1 := n / n1.
	n := n negated.
	3 to: moments size
	    do: 
		[:k | 
		cTerm := cTerm * correction.
		nTerm := n * nTerm.
		term := cTerm * (1 + nTerm).
		k to: 3
		    by: -1
		    do: 
			[:l | 
			pascal at: l put: (pascal at: l - 1) + (pascal at: l).
			term := (pascal at: l) * (oldSums at: l) + term.
			oldSums at: l put: (oldSums at: l) * correction].
		pascal at: 2 put: (pascal at: 1) + (pascal at: 2).
		moments at: k put: term * n1]
    ]

    reset [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 10/5/99"

	<category: 'transformation'>
	moments atAllPut: 0
    ]
]



Object subclass: DhbMahalanobisCenter [
    | center inverseCovariance accumulator |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbMahalanobisCenter class >> new: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'creation'>
	^self new initialize: anInteger
    ]

    DhbMahalanobisCenter class >> onVector: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'creation'>
	^self new center: aVector
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	accumulator count printOn: aStream.
	aStream nextPutAll: ': '.
	center printOn: aStream
    ]

    count [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^accumulator count
    ]

    distanceTo: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	| delta |
	delta := aVector - center.
	^delta * inverseCovariance * delta
    ]

    center: aVector [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	accumulator := DhbCovarianceAccumulator new: aVector size.
	center := aVector.
	inverseCovariance := DhbSymmetricMatrix identity: aVector size.
	^self
    ]

    initialize: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	accumulator := DhbCovarianceAccumulator new: anInteger.
	^self
    ]

    accumulate: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	accumulator accumulate: aVector
    ]

    computeParameters [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	center := accumulator average copy.
	inverseCovariance := accumulator covarianceMatrix inverse
    ]

    reset [
	"Leave center and inverse covariant matrix untouched
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	accumulator reset
    ]
]



Object subclass: DhbVectorAccumulator [
    | count average |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbVectorAccumulator class >> new: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'creation'>
	^self new initialize: anInteger
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	super printOn: aStream.
	aStream space.
	count printOn: aStream.
	aStream space.
	average printOn: aStream
    ]

    average [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^average
    ]

    count [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^count
    ]

    initialize: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	average := DhbVector new: anInteger.
	self reset.
	^self
    ]

    accumulate: aVectorOrArray [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	| delta |
	count := count + 1.
	delta := average - aVectorOrArray asVector scaleBy: 1 / count.
	average accumulateNegated: delta.
	^delta
    ]

    reset [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	count := 0.
	average atAllPut: 0
    ]
]



DhbIterativeProcess subclass: DhbClusterFinder [
    | dataServer dataSetSize minimumRelativeClusterSize |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbClusterFinder class >> new: anInteger server: aClusterDataServer type: aClusterClass [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'creation'>
	^super new 
	    initialize: anInteger
	    server: aClusterDataServer
	    type: aClusterClass
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	aStream nextPutAll: 'Iterations: '.
	iterations printOn: aStream.
	result do: 
		[:each | 
		aStream cr.
		each printOn: aStream]
    ]

    clusters: aCollectionOfClusters [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/18/00"

	<category: 'information'>
	result := aCollectionOfClusters
    ]

    indexOfNearestCluster: aVector [
	"Private - Answers the index of the cluster nearest to aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'information'>
	| distance index |
	index := 1.
	distance := (result at: 1) distanceTo: aVector.
	2 to: result size
	    do: 
		[:n | 
		| x |
		x := (result at: n) distanceTo: aVector.
		x < distance 
		    ifTrue: 
			[distance := x.
			index := n]].
	^index
    ]

    initialize: anInteger server: aClusterDataServer type: aClusterClass [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'information'>
	self dataServer: aClusterDataServer.
	self clusters: ((1 to: anInteger) collect: [:n | aClusterClass new]).
	minimumRelativeClusterSize := 0.
	^self
    ]

    minimumClusterSize [
	<category: 'information'>
	^(minimumRelativeClusterSize * dataSetSize) rounded
    ]

    dataServer: aClusterDataServer [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/18/00"

	<category: 'initialization'>
	dataServer := aClusterDataServer
    ]

    minimumRelativeClusterSize: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	minimumRelativeClusterSize := aNumber max: 0
    ]

    evaluateIteration [
	"Perform an accumulation of the data from the server.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	dataServer reset.
	dataSetSize := 0.
	[dataServer atEnd] whileFalse: 
		[self accumulate: dataServer next.
		dataSetSize := dataSetSize + 1].
	^self collectChangesAndResetClusters
    ]

    finalizeIterations [
	"Close the data server.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	dataServer close
    ]

    initializeIterations [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	dataServer open.
	result 
	    do: [:each | each isUndefined ifTrue: [each centerOn: dataServer next]]
    ]

    accumulate: aVector [
	"Private - Accumulate aVector into the nearest cluster.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'transformation'>
	(result at: (self indexOfNearestCluster: aVector)) accumulate: aVector
    ]

    collectChangesAndResetClusters [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	| hasEmptyClusters changes |
	changes := 0.
	hasEmptyClusters := false.
	result do: 
		[:each | 
		changes := each changes + changes.
		(each isInsignificantIn: self) 
		    ifTrue: 
			[each centerOn: nil.
			hasEmptyClusters := true]
		    ifFalse: [each reset]].
	hasEmptyClusters 
	    ifTrue: [result := result reject: [:each | each isUndefined]].
	^changes / 2
    ]
]



DhbStatisticalMoments subclass: DhbFastStatisticalMoments [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    average [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'information'>
	self count = 0 ifTrue: [^nil].
	^(moments at: 2) / self count
    ]

    kurtosis [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'information'>
	| var x1 x2 x3 x4 kFact kConst n m4 xSquared |
	n := self count.
	n < 4 ifTrue: [^nil].
	var := self variance.
	var = 0 ifTrue: [^nil].
	x1 := (moments at: 2) / n.
	x2 := (moments at: 3) / n.
	x3 := (moments at: 4) / n.
	x4 := (moments at: 5) / n.
	xSquared := x1 squared.
	m4 := x4 - (4 * x1 * x3) + (6 * x2 * xSquared) - (xSquared squared * 3).
	kFact := n * (n + 1) / (n - 1) / (n - 2) / (n - 3).
	kConst := 3 * (n - 1) * (n - 1) / (n - 2) / (n - 3).
	^kFact * (m4 * n / var squared) - kConst
    ]

    skewness [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'information'>
	| x1 x2 x3 n stdev |
	n := self count.
	n < 3 ifTrue: [^nil].
	stdev := self standardDeviation.
	stdev = 0 ifTrue: [^nil].
	x1 := (moments at: 2) / n.
	x2 := (moments at: 3) / n.
	x3 := (moments at: 4) / n.
	^(x3 - (3 * x1 * x2) + (2 * x1 * x1 * x1)) * n * n 
	    / (stdev squared * stdev * (n - 1) * (n - 2))
    ]

    unnormalizedVariance [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'information'>
	^(moments at: 3) - ((moments at: 2) squared * self count)
    ]

    variance [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'information'>
	| n |
	n := self count.
	n < 2 ifTrue: [^nil].
	^((moments at: 3) - ((moments at: 2) squared / n)) / (n - 1)
    ]

    accumulate: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'transformation'>
	| var |
	var := 1.
	1 to: moments size
	    do: 
		[:n | 
		moments at: n put: (moments at: n) + var.
		var := var * aNumber]
    ]
]



DhbIterativeProcess subclass: DhbLeastSquareFit [
    | dataHolder errorMatrix chiSquare equations constants degreeOfFreedom |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    DhbLeastSquareFit class >> histogram: aHistogram distributionClass: aProbabilityDensityFunctionClass [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'creation'>
	^self points: aHistogram
	    function: (DhbScaledProbabilityDensityFunction histogram: aHistogram
		    distributionClass: aProbabilityDensityFunctionClass)
    ]

    DhbLeastSquareFit class >> points: aDataHolder function: aParametricFunction [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'creation'>
	^aParametricFunction isNil 
	    ifTrue: [nil]
	    ifFalse: [super new initialize: aDataHolder data: aParametricFunction]
    ]

    chiSquare [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	chiSquare isNil ifTrue: [self computeChiSquare].
	^chiSquare
    ]

    computeChiSquare [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	chiSquare := 0.
	degreeOfFreedom := self numberOfFreeParameters negated.
	dataHolder pointsAndErrorsDo: 
		[:each | 
		chiSquare := (each chi2Contribution: result) + chiSquare.
		degreeOfFreedom := degreeOfFreedom + 1]
    ]

    confidenceLevel [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/6/00"

	<category: 'information'>
	^(DhbChiSquareDistribution degreeOfFreedom: self degreeOfFreedom) 
	    confidenceLevel: self chiSquare
    ]

    degreeOfFreedom [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	degreeOfFreedom isNil ifTrue: [self computeChiSquare].
	^degreeOfFreedom
    ]

    errorMatrix [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 14/4/99"

	<category: 'information'>
	^DhbSymmetricMatrix rows: errorMatrix inverseMatrixComponents
    ]

    fitType [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^'Least square fit'
    ]

    numberOfFreeParameters [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^self numberOfParameters
    ]

    numberOfParameters [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	^result parameters size
    ]

    value: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/8/00"

	<category: 'information'>
	^result value: aNumber
    ]

    valueAndError: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/8/00"

	<category: 'information'>
	| valueGradient |
	valueGradient := result valueAndGradient: aNumber.
	^Array with: valueGradient first
	    with: (valueGradient last * (self errorMatrix * valueGradient last)) sqrt
    ]

    initialize: aDataHolder data: aParametricFunction [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'initialization'>
	dataHolder := aDataHolder.
	result := aParametricFunction.
	^self
    ]

    accumulate: aWeightedPoint [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'operation'>
	| f g |
	f := result valueAndGradient: aWeightedPoint xValue.
	g := f last.
	f := f first.
	constants 
	    accumulate: g * ((aWeightedPoint yValue - f) * aWeightedPoint weight).
	1 to: g size
	    do: [:k | (equations at: k) accumulate: g * ((g at: k) * aWeightedPoint weight)]
    ]

    accumulateEquationSystem [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'operation'>
	dataHolder pointsAndErrorsDo: [:each | self accumulate: each]
    ]

    computeChanges [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'operation'>
	errorMatrix := DhbLUPDecomposition direct: equations.
	^errorMatrix solve: constants
    ]

    computeEquationSystem [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'operation'>
	constants atAllPut: 0.
	equations do: [:each | each atAllPut: 0].
	self accumulateEquationSystem
    ]

    evaluateIteration [
	"Dummy method (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| changes maxChange |
	self computeEquationSystem.
	changes := self computeChanges.
	result changeParametersBy: changes.
	maxChange := 0.
	result parameters with: changes
	    do: [:r :d | maxChange := (d / r) abs max: maxChange].
	^maxChange
    ]

    finalizeIterations [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	equations := nil.
	constants := nil.
	degreeOfFreedom := nil.
	chiSquare := nil
    ]

    initializeIterations [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 6/1/99"

	<category: 'operation'>
	| n |
	n := self numberOfParameters.
	constants := (DhbVector new: n)
		    atAllPut: 0;
		    yourself.
	equations := (1 to: n) collect: 
			[:k | 
			(DhbVector new: n)
			    atAllPut: 0;
			    yourself]
    ]
]



Object subclass: DhbHistogram [
    | minimum binWidth overflow underflow moments contents freeExtent cacheSize desiredNumberOfBins |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbHistogram class >> new [
	"Create a standard new instance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'creation'>
	^super new initialize
    ]

    DhbHistogram class >> defaultCacheSize [
	"Private - Answer the default cache size.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'information'>
	^100
    ]

    DhbHistogram class >> defaultNumberOfBins [
	"Private - Defines the default number of bins for instances of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^50
    ]

    DhbHistogram class >> integerScales [
	"Private - Scales for strict integers"

	<category: 'information'>
	^#(2 4 5 8 10)
    ]

    DhbHistogram class >> scales [
	"Private - Scales for any number"

	<category: 'information'>
	^#(1.25 2 2.5 4 5 7.5 8 10)
    ]

    DhbHistogram class >> semiIntegerScales [
	"Private - Scales for large integers"

	<category: 'information'>
	^#(2 2.5 4 5 7.5 8 10)
    ]

    average [
	"Answer the average of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments average
    ]

    binIndex: aNumber [
	"Answers the index of the bin corresponding to aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	^((aNumber - minimum) / binWidth) floor + 1
    ]

    binWidth [
	"Answer the bin width for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	self isCached ifTrue: [self flushCache].
	^binWidth
    ]

    chi2Against: aScaledDistribution [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/30/00"

	<category: 'information'>
	| chi2 |
	chi2 := 0.
	self pointsAndErrorsDo: 
		[:each | 
		chi2 := (each chi2Contribution: aScaledDistribution) + chi2].
	^chi2
    ]

    chi2ConfidenceLevelAgainst: aScaledDistribution [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/30/00"

	<category: 'information'>
	^(DhbChiSquareDistribution 
	    degreeOfFreedom: contents size - aScaledDistribution parameters size) 
		confidenceLevel: (self chi2Against: aScaledDistribution)
    ]

    collectIntegralPoints: aBlock [
	"Collects the points needed to display the receiver as an integral.
	 Needed to use polymorphic behavior when plotting the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	| answer bin lastContents integral norm x |
	self isCached ifTrue: [self flushCache].
	answer := OrderedCollection new: contents size * 2 + 1.
	bin := self minimum.
	answer add: (aBlock value: bin @ 0).
	integral := self underflow.
	norm := self totalCount.
	contents do: 
		[:each | 
		integral := integral + each.
		x := integral / norm.
		answer add: (aBlock value: bin @ x).
		bin := bin + binWidth.
		answer add: (aBlock value: bin @ x)].
	answer add: (aBlock value: bin @ 0).
	^answer asArray
    ]

    collectPoints: aBlock [
	"Collects the points needed to display the receiver.
	 Needed to use polymorphic behavior when plotting the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	| answer bin lastContents |
	self isCached ifTrue: [self flushCache].
	answer := OrderedCollection new: contents size * 2 + 1.
	bin := self minimum.
	answer add: (aBlock value: bin @ 0).
	contents do: 
		[:each | 
		answer add: (aBlock value: bin @ each).
		bin := bin + binWidth.
		answer add: (aBlock value: bin @ each)].
	answer add: (aBlock value: bin @ 0).
	^answer asArray
    ]

    count [
	"Answer the count of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments count
    ]

    countAt: aNumber [
	"Answer the count in the bin corresponding to aNumber or 0 if outside the limits.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	| n |
	n := self binIndex: aNumber.
	^(n between: 1 and: contents size) ifTrue: [contents at: n] ifFalse: [0]
    ]

    countsBetween: aNumber1 and: aNumber2 [
	"Computes the events located between aNumber1 and aNumber2.
	 NOTE: This method assumes the two numbers are within the limits
	 of the receiver and that the receiver is not cached.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	| n1 n2 answer |
	n1 := self binIndex: aNumber1.
	n2 := self binIndex: aNumber2.
	answer := (contents at: n1) * (binWidth * n1 + minimum - aNumber1) 
		    / binWidth.
	n2 > contents size 
	    ifTrue: [n2 := contents size + 1]
	    ifFalse: 
		[answer := answer 
			    + ((contents at: n2) * (aNumber2 - (binWidth * (n2 - 1) + self maximum)) 
				    / binWidth)].
	n1 + 1 to: n2 - 1 do: [:n | answer := answer + (contents at: n)].
	^answer
    ]

    countsUpTo: aNumber [
	"Computes the events located up to aNumber.
	 NOTE: This method assumes aNumber is within the limits
	 of the receiver and that the receiver is not cached.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	| n answer |
	n := self binIndex: aNumber.
	n > contents size ifTrue: [^self count].
	answer := (contents at: n) 
		    * (aNumber - (binWidth * (n - 1) + self minimum)) / binWidth.
	1 to: n - 1 do: [:m | answer := answer + (contents at: m)].
	^answer + underflow
    ]

    errorOnAverage [
	"Answer the error on the average of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments errorOnAverage
    ]

    inverseDistributionValue: aNumber [
	"Private - Compute the value which corresponds to a integrated count of aNumber.
	 NOTE: aNumber is assumed to be between 0 and 1.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'information'>
	| count x integral |
	count := self count * aNumber.
	x := self minimum.
	integral := 0.
	contents do: 
		[:each | 
		| delta |
		delta := count - integral.
		each > delta ifTrue: [^self binWidth * delta / each + x].
		integral := integral + each.
		x := self binWidth + x].
	^self maximum
    ]

    isCached [
	"Private - Answer true if the content of the receiver is cached.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^binWidth isNil
    ]

    isEmpty [
	"Always false.
	 Needed to use polymorphic behavior when plotting the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	^false
    ]

    kurtosis [
	"Answer the kurtosis of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments kurtosis
    ]

    lowBinLimitAt: anInteger [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 4/3/99"

	<category: 'information'>
	^(anInteger - 1) * binWidth + minimum
    ]

    maximum [
	"Answer the minimum for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	self isCached ifTrue: [self flushCache].
	^contents size * binWidth + minimum
    ]

    maximumCount [
	"Answer the maximum count of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/2/99"

	<category: 'information'>
	self isCached ifTrue: [self flushCache].
	^contents inject: (contents isEmpty ifTrue: [1] ifFalse: [contents at: 1])
	    into: [:max :each | max max: each]
    ]

    minimum [
	"Answer the minimum for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	self isCached ifTrue: [self flushCache].
	^minimum
    ]

    overflow [
	"Answer the overflow of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^overflow
    ]

    roundToScale: aNumber [
	"Private - Adjust aNumber of the lowest upper scale"

	<category: 'information'>
	| orderOfMagnitude norm scales rValue |
	orderOfMagnitude := (aNumber log: 10) floor.
	scales := self class scales.
	aNumber isInteger 
	    ifTrue: 
		[orderOfMagnitude < 1 ifTrue: [orderOfMagnitude := 1].
		orderOfMagnitude = 1 ifTrue: [scales := self class integerScales].
		orderOfMagnitude = 2 ifTrue: [scales := self class semiIntegerScales]].
	norm := 10 raisedToInteger: orderOfMagnitude.
	rValue := aNumber / norm.
	^(scales detect: [:each | rValue <= each]) * norm
    ]

    skewness [
	"Answer the skewness of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments skewness
    ]

    standardDeviation [
	"Answer the standardDeviation of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments standardDeviation
    ]

    totalCount [
	"Answer the count of the recevier, inclusing underflow and overflow
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments count + underflow + overflow
    ]

    underflow [
	"Answer the underflow of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^underflow
    ]

    unnormalizedVariance [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'information'>
	^moments unnormalizedVariance
    ]

    variance [
	"Answer the variance of the recevier
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'information'>
	^moments variance
    ]

    freeExtent: aBoolean [
	"Defines the range of the receiver to be freely adjustable.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	(underflow = 0 and: [overflow = 0]) 
	    ifFalse: [self error: 'Histogram extent cannot be redefined'].
	freeExtent := aBoolean
    ]

    initialize [
	"Private - initializes the receiver with standard settings.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'initialization'>
	freeExtent := false.
	cacheSize := self class defaultCacheSize.
	desiredNumberOfBins := self class defaultNumberOfBins.
	contents := OrderedCollection new: cacheSize.
	moments := DhbFixedStatisticalMoments new.
	overflow := 0.
	underflow := 0.
	^self
    ]

    setDesiredNumberOfBins: anInteger [
	"Defines the desired number of bins. It may be adjusted to a few units later on.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	anInteger > 0 
	    ifFalse: [self error: 'Desired number of bins must be positive'].
	desiredNumberOfBins := anInteger
    ]

    setRangeFrom: aNumber1 to: aNumber2 bins: anInteger [
	"Defines the range of the receiver by specifying the minimum, maximum and number of bins.
	 Values are adjusted to correspond to a reasonable value for the bin width and the limits.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	self isCached 
	    ifFalse: [self error: 'Histogram limits cannot be redefined'].
	minimum := aNumber1.
	self
	    setDesiredNumberOfBins: anInteger;
	    adjustDimensionUpTo: aNumber2
    ]

    setWidth: aNumber1 from: aNumber2 bins: anInteger [
	"Defines the range of the receiver by specifying the minimum, bin width and number of bins.
	 Values are adjusted to correspond to a reasonable value for the bin width and the limits.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'initialization'>
	self isCached 
	    ifFalse: [self error: 'Histogram limits cannot be redefined'].
	minimum := aNumber2.
	self
	    setDesiredNumberOfBins: anInteger;
	    adjustDimensionUpTo: aNumber1 * anInteger + aNumber2
    ]

    pointsAndErrorsDo: aBlock [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'iterators'>
	| x |
	x := self minimum - (self binWidth / 2).
	contents do: 
		[:each | 
		x := x + self binWidth.
		aBlock value: (DhbWeightedPoint point: x count: each)]
    ]

    fConfidenceLevel: aStatisticalMomentsOrHistogram [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'testing'>
	^moments fConfidenceLevel: aStatisticalMomentsOrHistogram
    ]

    tConfidenceLevel: aStatisticalMomentsOrHistogram [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 1/22/00"

	<category: 'testing'>
	^moments tConfidenceLevel: aStatisticalMomentsOrHistogram
    ]

    accumulate: aNumber [
	"Accumulate aNumber into the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	| bin |
	self isCached ifTrue: [^self accumulateInCache: aNumber].
	bin := self binIndex: aNumber.
	(bin between: 1 and: contents size) 
	    ifTrue: 
		[contents at: bin put: (contents at: bin) + 1.
		moments accumulate: aNumber]
	    ifFalse: [self processOverflows: bin for: aNumber]
    ]

    accumulateInCache: aNumber [
	"Private - Accumulate aNumber inside a cache
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	contents add: aNumber.
	contents size > cacheSize ifTrue: [self flushCache]
    ]

    adjustDimensionUpTo: aNumber [
	"Private - Compute an adequate bin width and adjust the minimum and number of bins accordingly.
	 aNumber is the maximum value to accumulate. The minimum value has already been assigned.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 16/2/99"

	<category: 'transformation'>
	| maximum |
	binWidth := self roundToScale: (aNumber - minimum) / desiredNumberOfBins.
	minimum := (minimum / binWidth) floor * binWidth.
	maximum := (aNumber / binWidth) ceiling * binWidth.
	contents := Array new: ((maximum - minimum) / binWidth) ceiling.
	contents atAllPut: 0
    ]

    countOverflows: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	anInteger > 0 
	    ifTrue: [overflow := overflow + 1]
	    ifFalse: [underflow := underflow + 1]
    ]

    flushCache [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	| maximum values |
	minimum isNil 
	    ifTrue: [minimum := contents isEmpty ifTrue: [0] ifFalse: [contents first]].
	maximum := minimum.
	contents do: 
		[:each | 
		each < minimum 
		    ifTrue: [minimum := each]
		    ifFalse: [each > maximum ifTrue: [maximum := each]]].
	maximum = minimum ifTrue: [maximum := minimum + desiredNumberOfBins].
	values := contents.
	self adjustDimensionUpTo: maximum.
	values do: [:each | self accumulate: each]
    ]

    growContents: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	anInteger > 0 
	    ifTrue: [self growPositiveContents: anInteger]
	    ifFalse: [self growNegativeContents: anInteger]
    ]

    growNegativeContents: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	| n newSize newContents |
	n := 1 - anInteger.
	newSize := contents size + n.
	newContents := Array new: newSize.
	newContents at: 1 put: 1.
	2 to: n do: [:i | newContents at: i put: 0].
	newContents 
	    replaceFrom: n + 1
	    to: newSize
	    with: contents
	    startingAt: 1.
	contents := newContents.
	minimum := (anInteger - 1) * binWidth + minimum
    ]

    growPositiveContents: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	| n newContents |
	n := contents size.
	newContents := Array new: anInteger.
	newContents 
	    replaceFrom: 1
	    to: n
	    with: contents
	    startingAt: 1.
	n + 1 to: anInteger - 1 do: [:i | newContents at: i put: 0].
	newContents at: anInteger put: 1.
	contents := newContents
    ]

    processOverflows: anInteger for: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/2/99"

	<category: 'transformation'>
	freeExtent 
	    ifTrue: 
		[self growContents: anInteger.
		moments accumulate: aNumber]
	    ifFalse: [self countOverflows: anInteger]
    ]
]



Object subclass: DhbCluster [
    | accumulator previousSampleSize |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbCluster class >> new [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'creation'>
	^super new initialize
    ]

    changes [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^(self sampleSize - previousSampleSize) abs
    ]

    distanceTo: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^self subclassResponsibility
    ]

    isInsignificantIn: aClusterFinder [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/17/00"

	<category: 'information'>
	^self sampleSize <= aClusterFinder minimumClusterSize
    ]

    isUndefined [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^self subclassResponsibility
    ]

    sampleSize [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^accumulator count
    ]

    centerOn: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	self subclassResponsibility
    ]

    initialize [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	previousSampleSize := 0.
	^self
    ]

    accumulate: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	accumulator accumulate: aVector
    ]

    collectAccumulatorResults [
	<category: 'transformation'>
	self subclassResponsibility
    ]

    reset [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	previousSampleSize := self sampleSize.
	self collectAccumulatorResults.
	accumulator reset
    ]
]



Object subclass: DhbAbstractDataServer [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    atEnd [
	"Answers true if there is no more data element.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'information'>
	self subclassResponsibility
    ]

    close [
	"Close the data stream (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	
    ]

    next [
	"Answers the next element on the stream.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	self subclassResponsibility
    ]

    open [
	"Open the data stream (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	self subclassResponsibility
    ]

    reset [
	"Reset the position of the data stream to the beginning.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	self subclassResponsibility
    ]
]



Object subclass: DhbPolynomialLeastSquareFit [
    | pointCollection degreePlusOne |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbPolynomialLeastSquareFit class >> new: anInteger [
	"Create a new instance of the receiver with given degree.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'creation'>
	^super new initialize: anInteger
    ]

    DhbPolynomialLeastSquareFit class >> new: anInteger on: aCollectionOfPoints [
	"Create a new instance of the receiver with given degree and points.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'creation'>
	^super new initialize: anInteger on: aCollectionOfPoints
    ]

    evaluate [
	"Perform the least square fit and answers the fitted polynomial.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'information'>
	| system errorMatrix |
	system := self computeEquations.
	errorMatrix := (system at: 1) inverse.
	^(DhbEstimatedPolynomial coefficients: errorMatrix * (system at: 2))
	    errorMatrix: errorMatrix;
	    yourself
    ]

    initialize: anInteger [
	"Private - Create an empty point collection for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'initialization'>
	^self initialize: anInteger on: OrderedCollection new
    ]

    initialize: anInteger on: aCollectionOfPoints [
	"Private - Defines the collection of points for the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'initialization'>
	pointCollection := aCollectionOfPoints.
	degreePlusOne := anInteger + 1.
	^self
    ]

    accumulate: aWeightedPoint into: aVectorOfVectors and: aVector [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'transformation'>
	| t p powers |
	p := 1.0.
	powers := aVector collect: 
			[:each | 
			t := p.
			p := p * aWeightedPoint xValue.
			t].
	aVector 
	    accumulate: powers * (aWeightedPoint yValue * aWeightedPoint weight).
	1 to: aVector size
	    do: 
		[:k | 
		(aVectorOfVectors at: k) 
		    accumulate: powers * ((powers at: k) * aWeightedPoint weight)]
    ]

    add: aWeightedPoint [
	"Add a point to the collection of points.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'transformation'>
	^pointCollection add: aWeightedPoint
    ]

    computeEquations [
	"Private - Answer a pair Matrix/Vector defining the system of equations
	 to solve the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'transformation'>
	| rows vector |
	vector := (DhbVector new: degreePlusOne)
		    atAllPut: 0;
		    yourself.
	rows := (1 to: degreePlusOne) collect: 
			[:k | 
			(DhbVector new: degreePlusOne)
			    atAllPut: 0;
			    yourself].
	pointCollection do: 
		[:each | 
		self 
		    accumulate: each
		    into: rows
		    and: vector].
	^Array with: (DhbSymmetricMatrix rows: rows) with: vector
    ]
]



Object subclass: DhbLinearRegression [
    | sum1 sumX sumY sumXX sumYY sumXY slope intercept correlationCoefficient |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbLinearRegression class >> new [
	"Create a new instance of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'creation'>
	^(super new)
	    reset;
	    yourself
    ]

    asEstimatedPolynomial [
	"Answer the resulting linear dependence found by the receiver in the form of a polynomial
	 with embedded error matrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'information'>
	^(DhbEstimatedPolynomial coefficients: self coefficients)
	    errorMatrix: self errorMatrix;
	    yourself
    ]

    asPolynomial [
	"Answer the resulting linear dependence found by the receiver in the form of a polynomial.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	^DhbPolynomial coefficients: self coefficients
    ]

    coefficients [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'information'>
	^Array with: self intercept with: self slope
    ]

    correlationCoefficient [
	"Answers the correlation coefficient of the receiver
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	correlationCoefficient isNil ifTrue: [self computeResults].
	^correlationCoefficient
    ]

    errorMatrix [
	"Answer the resulting linear dependence found by the receiver in the form of a polynomial
	 with embedded error matrix.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 18/3/99"

	<category: 'information'>
	| c1 cx cxx |
	c1 := 1.0 / (sumXX * sum1 - sumX squared).
	cx := sumX negated * c1.
	cxx := sumXX * c1.
	c1 := sum1 * c1.
	^DhbSymmetricMatrix rows: (Array with: (Array with: cxx with: cx)
		    with: (Array with: cx with: c1))
    ]

    errorOnIntercept [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/5/99"

	<category: 'information'>
	^(sumXX / (sumXX * sum1 - sumX squared)) sqrt
    ]

    errorOnSlope [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 21/5/99"

	<category: 'information'>
	^(sum1 / (sumXX * sum1 - sumX squared)) sqrt
    ]

    intercept [
	"Answers the intercept of the receiver
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	intercept isNil ifTrue: [self computeResults].
	^intercept
    ]

    slope [
	"Answers the slope of the receiver
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	slope isNil ifTrue: [self computeResults].
	^slope
    ]

    value: aNumber [
	"Answer the value interpolated at aNumber by the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'information'>
	^aNumber * self slope + self intercept
    ]

    add: aPoint [
	"Accumulate aPoint into of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	self add: aPoint weight: 1
    ]

    add: aPoint weight: aNumber [
	"Accumulate aPoint into of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	sum1 := sum1 + aNumber.
	sumX := sumX + (aPoint x * aNumber).
	sumY := sumY + (aPoint y * aNumber).
	sumXX := sumXX + (aPoint x squared * aNumber).
	sumYY := sumYY + (aPoint y squared * aNumber).
	sumXY := sumXY + (aPoint x * aPoint y * aNumber).
	self resetResults
    ]

    computeResults [
	"Private - Compute the results of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	| xNorm xyNorm |
	xNorm := sumXX * sum1 - (sumX * sumX).
	xyNorm := sumXY * sum1 - (sumX * sumY).
	slope := xyNorm / xNorm.
	intercept := (sumXX * sumY - (sumXY * sumX)) / xNorm.
	correlationCoefficient := xyNorm 
		    / (xNorm * (sumYY * sum1 - (sumY * sumY))) sqrt
    ]

    remove: aPoint [
	"Remove aPoint which was accumulated into of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	sum1 := sum1 - 1.
	sumX := sumX - aPoint x.
	sumY := sumY - aPoint y.
	sumXX := sumXX - aPoint x squared.
	sumYY := sumYY - aPoint y squared.
	sumXY := sumXY - (aPoint x * aPoint y).
	self resetResults
    ]

    reset [
	"Set all accumulators of the receiver to zero and reset its results.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	sum1 := 0.
	sumX := 0.
	sumY := 0.
	sumXX := 0.
	sumYY := 0.
	sumXY := 0.
	self resetResults
    ]

    resetResults [
	"Private - Reset the results of the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/2/99"

	<category: 'transformation'>
	slope := nil.
	intercept := nil.
	correlationCoefficient := nil
    ]
]



DhbVectorAccumulator subclass: DhbCovarianceAccumulator [
    | covariance |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    covarianceMatrix [
	"Answer a matrix containing the covariance of the accumulated data.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'information'>
	| rows n |
	n := 0.
	rows := covariance collect: 
			[:row | 
			n := n + 1.
			row 
			    , ((n + 1 to: covariance size) collect: [:m | (covariance at: m) at: n])].
	^DhbSymmetricMatrix rows: rows
    ]

    initialize: anInteger [
	"Private - Initialize the receiver to accumulate vectors of dimension anInteger.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'initialization'>
	covariance := ((1 to: anInteger) collect: [:n | DhbVector new: n]) 
		    asVector.
	^super initialize: anInteger
    ]

    accumulate: anArray [
	"Accumulate anArray into the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'transformation'>
	| delta count1 r |
	count1 := count.
	delta := super accumulate: anArray.
	r := count1 / count.
	1 to: delta size
	    do: 
		[:n | 
		1 to: n
		    do: 
			[:m | 
			(covariance at: n) at: m
			    put: count1 * (delta at: n) * (delta at: m) 
				    + (r * ((covariance at: n) at: m))]]
    ]

    reset [
	"Set all accumulators to zero.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 8/3/99"

	<category: 'transformation'>
	super reset.
	covariance do: [:each | each atAllPut: 0]
    ]
]



DhbCluster subclass: DhbCovarianceCluster [
    | center |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    distanceTo: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	^accumulator distanceTo: aVector
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	accumulator printOn: aStream
    ]

    isUndefined [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^accumulator isNil
    ]

    centerOn: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	accumulator := aVector isNil 
		    ifTrue: [nil]
		    ifFalse: [DhbMahalanobisCenter onVector: aVector]
    ]

    collectAccumulatorResults [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	accumulator computeParameters
    ]
]



DhbStatisticalMoments subclass: DhbFixedStatisticalMoments [
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbFixedStatisticalMoments class >> new [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'creation'>
	^super new: 4
    ]

    DhbFixedStatisticalMoments class >> new: anInteger [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'creation'>
	^self error: 'Illegal creation message for this class'
    ]

    accumulate: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 17/6/99"

	<category: 'transformation'>
	| correction n n1 c2 c3 |
	n := moments at: 1.
	n1 := n + 1.
	correction := ((moments at: 2) - aNumber) / n1.
	c2 := correction squared.
	c3 := c2 * correction.
	moments
	    at: 5
		put: ((moments at: 5) + ((moments at: 4) * correction * 4) 
			+ ((moments at: 3) * c2 * 6) + (c2 squared * (n squared * n + 1))) 
			* n / n1;
	    at: 4
		put: ((moments at: 4) + ((moments at: 3) * correction * 3) 
			+ (c3 * (1 - n squared))) * n 
			/ n1;
	    at: 3 put: ((moments at: 3) + (c2 * (1 + n))) * n / n1;
	    at: 2 put: (moments at: 2) - correction;
	    at: 1 put: n1
    ]
]



DhbCluster subclass: DhbEuclideanCluster [
    | center |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'display'>
	accumulator count printOn: aStream.
	aStream nextPutAll: ': '.
	center printOn: aStream
    ]

    distanceTo: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'information'>
	^(aVector - center) norm
    ]

    centerOn: aVector [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	center := aVector.
	accumulator := DhbVectorAccumulator new: aVector size
    ]

    isUndefined [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	^center isNil
    ]

    collectAccumulatorResults [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'transformation'>
	center := accumulator average copy
    ]
]



DhbLeastSquareFit subclass: DhbMaximumLikekihoodHistogramFit [
    | count countVariance |
    
    <comment: nil>
    <category: 'DHB Numerical'>

    fitType [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^'Maximum likelihood fit'
    ]

    normalization [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/12/00"

	<category: 'information'>
	^count
    ]

    normalizationError [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/12/00"

	<category: 'information'>
	^countVariance sqrt
    ]

    numberOfFreeParameters [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^super numberOfParameters
    ]

    numberOfParameters [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'information'>
	^super numberOfParameters - 1
    ]

    valueAndError: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/8/00"

	<category: 'information'>
	| valueGradient gradient gVar |
	valueGradient := result valueAndGradient: aNumber.
	gradient := valueGradient last copyFrom: 1 to: valueGradient last size - 1.
	gVar := gradient * (self errorMatrix * gradient) / count.
	^Array with: valueGradient first
	    with: ((valueGradient first / count) squared * countVariance + gVar) sqrt
    ]

    accumulate: aWeightedPoint [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'operation'>
	| f g temp inverseProbability |
	f := result valueAndGradient: aWeightedPoint xValue.
	g := f last copyFrom: 1 to: f last size - 1.
	f := f first.
	f = 0 ifTrue: [^nil].
	inverseProbability := 1 / f.
	temp := aWeightedPoint yValue * inverseProbability.
	constants accumulate: g * temp.
	temp := temp * inverseProbability.
	1 to: g size
	    do: [:k | (equations at: k) accumulate: g * ((g at: k) * temp)]
    ]

    computeChanges [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'operation'>
	^super computeChanges copyWith: 0
    ]

    computeNormalization [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'operation'>
	| numerator denominator temp |
	numerator := 0.
	denominator := 0.
	dataHolder pointsAndErrorsDo: 
		[:each | 
		temp := result value: each xValue.
		temp = 0 
		    ifFalse: 
			[numerator := numerator + (each yValue squared / temp).
			denominator := denominator + temp]].
	count := (numerator / denominator) sqrt.
	countVariance := numerator / (4 * count)
    ]

    finalizeIterations [
	"Compute the normalization factor.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	self computeNormalization.
	result setCount: count.
	super finalizeIterations
    ]

    initializeIterations [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'operation'>
	result setCount: 1.
	count := dataHolder totalCount.
	super initializeIterations
    ]
]



Object subclass: DhbScaledProbabilityDensityFunction [
    | probabilityDensityFunction count binWidth |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbScaledProbabilityDensityFunction class >> histogram: aHistogram against: aProbabilityDensityFunction [
	"Create a new instance of the receiver with given probability density function and histogram.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	^self new 
	    initialize: aProbabilityDensityFunction
	    binWidth: aHistogram binWidth
	    count: aHistogram totalCount
    ]

    DhbScaledProbabilityDensityFunction class >> histogram: aHistogram distributionClass: aProbabilityDensityFunctionClass [
	"Create a new instance of the receiver with given probability density function and histogram.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'creation'>
	| dp |
	^(dp := aProbabilityDensityFunctionClass fromHistogram: aHistogram) isNil 
	    ifTrue: [nil]
	    ifFalse: [self histogram: aHistogram against: dp]
    ]

    printOn: aStream [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'display'>
	super printOn: aStream.
	aStream
	    nextPut: $[;
	    nextPutAll: probabilityDensityFunction class distributionName;
	    nextPut: $]
    ]

    distributionFunction [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 15/4/99"

	<category: 'information'>
	^probabilityDensityFunction distributionFunction
    ]

    parameters [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'information'>
	^probabilityDensityFunction parameters copyWith: count
    ]

    value: aNumber [
	"
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'information'>
	^(probabilityDensityFunction value: aNumber) * binWidth * count
    ]

    valueAndGradient: aNumber [
	"Answers an Array containing the value of the receiver at aNumber
	 and the gradient of the receiver's respective to the receiver's
	 parameters evaluated at aNumber.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'information'>
	| g temp |
	g := probabilityDensityFunction valueAndGradient: aNumber.
	temp := binWidth * count.
	^Array with: g first * temp
	    with: ((g last collect: [:each | each * temp]) copyWith: g first * binWidth)
    ]

    initialize: aProbabilityDensityFunction binWidth: aNumber count: anInteger [
	"Private -
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 3/3/99"

	<category: 'initialization'>
	probabilityDensityFunction := aProbabilityDensityFunction.
	binWidth := aNumber.
	count := anInteger.
	^self
    ]

    changeParametersBy: aVector [
	"Modify the parameters of the receiver by aVector.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 11/3/99"

	<category: 'transformation'>
	count := count + aVector last.
	probabilityDensityFunction changeParametersBy: aVector
    ]

    setCount: aNumber [
	"(c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 12/3/99"

	<category: 'transformation'>
	count := aNumber
    ]
]



Object subclass: DhbWeightedPoint [
    | xValue yValue weight error |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    DhbWeightedPoint class >> point: aPoint [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'creation'>
	^self new initialize: aPoint weight: 1
    ]

    DhbWeightedPoint class >> point: aNumber count: anInteger [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'creation'>
	^self point: aNumber @ anInteger
	    weight: (anInteger > 0 ifTrue: [1 / anInteger] ifFalse: [1])
    ]

    DhbWeightedPoint class >> point: aPoint error: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'creation'>
	^self new initialize: aPoint error: aNumber
    ]

    DhbWeightedPoint class >> point: aPoint weight: aNumber [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'creation'>
	^self new initialize: aPoint weight: aNumber
    ]

    error [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'accessing'>
	error isNil ifTrue: [error := 1 / weight sqrt].
	^error
    ]

    point [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'accessing'>
	^xValue @ yValue
    ]

    weight [
	<category: 'accessing'>
	^weight
    ]

    xValue [
	<category: 'accessing'>
	^xValue
    ]

    yValue [
	<category: 'accessing'>
	^yValue
    ]

    chi2ComparisonContribution: aWeightedPoint [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'information'>
	^(aWeightedPoint yValue - yValue) squared 
	    / (1 / aWeightedPoint weight + (1 / weight))
    ]

    chi2Contribution: aFunction [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'information'>
	^(yValue - (aFunction value: xValue)) squared * weight
    ]

    initialize: aPoint error: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'initialization'>
	error := aNumber.
	^self initialize: aPoint weight: 1 / aNumber squared
    ]

    initialize: aPoint weight: aNumber [
	"Private -
	 (c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/5/00"

	<category: 'initialization'>
	xValue := aPoint x.
	yValue := aPoint y.
	weight := aNumber.
	^self
    ]
]



DhbAbstractDataServer subclass: DhbMemoryBasedDataServer [
    | data position |
    
    <category: 'DHB Numerical'>
    <comment: nil>

    atEnd [
	"Answers true if there is no more data element.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'information'>
	^data size < position
    ]

    dimension [
	"Answers the dimension of the vectors catered by the receiver.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'information'>
	^data first size
    ]

    data: anOrderedCollection [
	"(c) Copyrights Didier BESSET, 2000, all rights reserved.
	 Initial code: 2/16/00"

	<category: 'initialization'>
	data := anOrderedCollection.
	self reset
    ]

    next [
	"Answers the next element on the stream.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	| answer |
	answer := data at: position.
	position := position + 1.
	^answer
    ]

    open [
	"Open the data stream (must be implemented by subclass).
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	self reset
    ]

    reset [
	"Reset the position of the data stream to the beginning.
	 (c) Copyrights Didier BESSET, 1999, all rights reserved.
	 Initial code: 9/3/99"

	<category: 'operation'>
	position := 1
    ]
]

PK
     �Mh@�Q�F��  ��    NumericsTests.stUT	 dqXOȉXOux �  �  "======================================================================
|
|   Numerical methods - Test Suite
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2002, 2007, 2010 Didier Besset.
| Written by Didier Besset.
|
| This file is part of the Smalltalk Numerical Methods library.
|
| The Smalltalk Numerical Methods library is free software; you can
| redistribute it and/or modify it under the terms of the GNU Lesser General
| Public License as published by the Free Software Foundation; either version
| 2.1, or (at your option) any later version.
| 
| The Smalltalk Numerical Methods library is distributed in the hope that it
| will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
| of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the Smalltalk Numerical Methods library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



TestCase subclass: DhbTestCase [
    
    <comment: nil>
    <category: 'DHB Numerical SUnits'>

    defaultLogPolicyClass [
	<category: 'logging'>
	^TestVerboseLog
    ]
]



DhbTestCase subclass: DhbTestGamma [
    
    <comment: nil>
    <category: 'DHB Numerical SUnits'>

    DhbTestGamma class >> epsilon [
	<category: 'utility'>
	^0.00005
    ]

    gammaDiff: aNumber expected: result [
	<category: 'helpers'>
	| a |
	a := DhbLanczosFormula new gamma: aNumber.
	^(a - result) abs
    ]

    testGamma [
	<category: 'tests'>
	| diff |
	diff := self gammaDiff: 4 expected: 6.
	self assert: diff < self class epsilon.
	diff := self gammaDiff: 1 / 3 expected: 2.6789.
	self assert: diff < self class epsilon.
	diff := self gammaDiff: 4 / 5 expected: 1.1642.
	self assert: diff < self class epsilon
    ]
]



DhbTestCase subclass: DhbTestIterators [
    
    <comment: nil>
    <category: 'DHB Numerical SUnits'>

    integratorTest: anIntegratorClass [
	<category: 'integration'>
	| a |
	a := anIntegratorClass 
		    function: [:x | x sin]
		    from: 0
		    to: 0.
	self assert: (a evaluate equalsTo: 0).
	a := anIntegratorClass 
		    function: [:x | x sin]
		    from: 0
		    to: FloatD pi.
	self assert: a evaluate - 2 < 0.00001.
	a := anIntegratorClass 
		    function: [:x | x sin]
		    from: FloatD pi negated
		    to: 0.
	self assert: (a evaluate + 2) abs < 0.00001.
	a := anIntegratorClass 
		    function: [:x | x sin]
		    from: FloatD pi negated
		    to: FloatD pi.
	self assert: (a evaluate equalsTo: 0)
    ]

    integratorTestInversedBounds: anIntegratorClass [
	<category: 'integration'>
	"Integrator cannot deal with nversed bounds"

	| a |
	a := anIntegratorClass 
		    function: [:x | x sin]
		    from: FloatD pi
		    to: 0.
	self deny: (a evaluate equalsTo: -2)
    ]

    testRomberg [
	<category: 'integration'>
	self integratorTest: DhbRombergIntegrator
    ]

    testRombergInversedBounds [
	"Integrator cannot deal with nversed bounds"

	<category: 'integration'>
	self integratorTestInversedBounds: DhbRombergIntegrator
    ]

    testSimpson [
	<category: 'integration'>
	self integratorTest: DhbSimpsonIntegrator
    ]

    testSimpsonInversedBounds [
	"Integrator cannot deal with nversed bounds"

	<category: 'integration'>
	self integratorTestInversedBounds: DhbSimpsonIntegrator
    ]

    testTrapeze [
	<category: 'integration'>
	self integratorTest: DhbTrapezeIntegrator
    ]

    testTrapezeInversedBounds [
	"Integrator cannot deal with nversed bounds"

	<category: 'integration'>
	self integratorTestInversedBounds: DhbTrapezeIntegrator
    ]

    testRootFind [
	<category: 'polynomial'>
	| a roots |
	a := DhbPolynomial coefficients: #(0 1 1).
	roots := a roots asSortedCollection.
	self
	    assert: roots size = 2;
	    assert: (roots first equalsTo: -1);
	    assert: (roots last equalsTo: 0)
    ]

    testRootFindComplex [
	"Does not support complex roots"

	<category: 'polynomial'>
	| a roots |
	a := DhbPolynomial coefficients: #(1 0 1).
	roots := a roots.
	self assert: roots size = 0
    ]

    testBisectionZeroFinder [
	<category: 'zero finders'>
	| finder |
	finder := DhbBisectionZeroFinder function: [:x | x + 1].
	finder
	    setNegativeX: -70;
	    setPositiveX: 10.
	finder evaluate.
	self
	    assert: finder hasConverged;
	    assert: (finder result equalsTo: -1)
    ]

    testBisectionZeroFinderNoZero [
	<category: 'zero finders'>
	| finder |
	finder := DhbBisectionZeroFinder function: [:x | x * x + 1].
	self should: [finder findNegativeXFrom: -30 range: 20] raise: Error
    ]

    testBisectionZeroFinderSquared [
	<category: 'zero finders'>
	| finder |
	finder := DhbBisectionZeroFinder function: [:x | x * x - 1].
	finder
	    setNegativeX: -0.9000000000000001;
	    setPositiveX: 10.
	finder evaluate.
	self
	    assert: finder hasConverged;
	    assert: (finder result equalsTo: 1)
    ]

    testNewtonZeroFinder [
	<category: 'zero finders'>
	| finder |
	finder := DhbNewtonZeroFinder function: [:x | x + 1] derivative: [:x | 1].
	finder evaluate.
	self
	    assert: finder hasConverged;
	    assert: (finder result equalsTo: -1)
    ]

    testNewtonZeroFinderSquared [
	<category: 'zero finders'>
	| finder |
	finder := DhbNewtonZeroFinder function: [:x | x * x - 1]
		    derivative: [:x | 2 * x].
	finder evaluate.
	self
	    assert: finder hasConverged;
	    assert: (finder result abs equalsTo: 1)
    ]
]



DhbTestCase subclass: DhbNumericalMethodsTestCase [
    
    <comment: nil>
    <category: 'DHB Numerical SUnits'>

    testClusterCovariance [
	<category: 'data mining'>
	| dataServer clusters finder |
	dataServer := DhbMemoryBasedDataServer new.
	dataServer data: (self generatedPoints: 1000).
	finder := DhbClusterFinder 
		    new: 5
		    server: dataServer
		    type: DhbCovarianceCluster.
	finder minimumRelativeClusterSize: 0.1.
	clusters := finder evaluate.
	self should: [clusters size = 3]
    ]

    testClusterEuclidean [
	<category: 'data mining'>
	| dataServer clusters finder |
	dataServer := DhbMemoryBasedDataServer new.
	dataServer data: (self generatedPoints: 1000).
	finder := DhbClusterFinder 
		    new: 5
		    server: dataServer
		    type: DhbEuclideanCluster.
	finder minimumRelativeClusterSize: 0.15.
	clusters := finder evaluate.
	self should: [clusters size = 3]
    ]

    testCovarianceAccumulation [
	"Code example 12.2"

	<category: 'data mining'>
	| accumulator average covarianceMatrix |
	accumulator := DhbCovarianceAccumulator new: 3.
	#(#(1 2 3) #(2 3 4) #(1 3 2) #(4 3 1) #(1 3 1) #(1 4 2) #(3 1 2) #(3 4 2)) 
	    do: [:x | accumulator accumulate: x asVector].
	average := accumulator average.
	self should: [(average at: 1) equalsTo: 2.0].
	self should: [(average at: 2) equalsTo: 2.875].
	self should: [(average at: 3) equalsTo: 2.125].
	covarianceMatrix := accumulator covarianceMatrix.
	self should: [((covarianceMatrix rowAt: 1) at: 1) equalsTo: 1.25].
	self should: [((covarianceMatrix rowAt: 1) at: 2) equalsTo: -0.125].
	self should: [((covarianceMatrix rowAt: 2) at: 1) equalsTo: -0.125].
	self should: [((covarianceMatrix rowAt: 1) at: 3) equalsTo: -0.25].
	self should: [((covarianceMatrix rowAt: 3) at: 1) equalsTo: -0.25].
	self should: [((covarianceMatrix rowAt: 2) at: 2) equalsTo: 0.859375].
	self should: [((covarianceMatrix rowAt: 2) at: 3) equalsTo: -0.109375].
	self should: [((covarianceMatrix rowAt: 3) at: 2) equalsTo: -0.109375].
	self should: [((covarianceMatrix rowAt: 3) at: 3) equalsTo: 0.859375]
    ]

    testMahalanobisCenter [
	"Code example 12.5"

	<category: 'data mining'>
	| center distance |
	center := DhbMahalanobisCenter new: 3.
	#(#(1 2 3) #(2 3 4) #(1 3 2) #(4 3 1) #(1 3 1) #(1 4 2) #(3 1 2) #(3 4 2)) 
	    do: [:x | center accumulate: x asVector].
	center computeParameters.
	distance := center distanceTo: #(1 2 3) asVector.
	self should: [distance equalsTo: 2.26602282704126]
    ]

    testFTest [
	<category: 'estimation'>
	| accC accMM confidenceLevel |
	accC := DhbStatisticalMoments new.
	#(5.560000000000001 5.89 4.660000000000001 5.690000000000001 5.34 4.79 4.8 7.860000000000001 3.64 5.700000000000001) 
	    do: [:x | accC accumulate: x].
	accMM := DhbStatisticalMoments new.
	#(7.480000000000001 6.75 3.77 5.71 7.25 4.730000000000001 6.230000000000001 5.600000000000001 5.940000000000001 4.58) 
	    do: [:x | accMM accumulate: x].
	confidenceLevel := accC fConfidenceLevel: accMM.
	self should: [(accC average - 5.393) abs < 0.000000001].
	self should: [(accC standardDeviation - 1.0990809292) abs < 0.000000001].
	self should: [(accMM average - 5.804000000000001) abs < 0.000000001].
	self should: [(accMM standardDeviation - 1.19415428) abs < 0.000000001].
	self should: [(confidenceLevel - 79.8147614536) abs < 0.000000001]
    ]

    testInterpolationNewton [
	<category: 'estimation'>
	| interpolator |
	interpolator := DhbNewtonInterpolator new.
	1 to: 45
	    by: 2
	    do: [:x | interpolator add: x @ x degreesToRadians sin].
	self should: 
		[((interpolator value: 8) - 8 degreesToRadians sin) abs < 0.00000000000001]
    ]

    testLeastSquare [
	"Code example 10.9"

	"Note: the seemingly large error on the fit results is due to the binning of the histogram."

	<category: 'estimation'>
	| count shape scale genDistr hist fit fittedDistr parameters |
	count := 10000.
	shape := 0.
	scale := 1.
	hist := DhbHistogram new.
	hist freeExtent: true.
	genDistr := DhbFisherTippettDistribution shape: shape scale: scale.
	count timesRepeat: [hist accumulate: genDistr random].
	fit := DhbLeastSquareFit histogram: hist
		    distributionClass: DhbFisherTippettDistribution.
	fittedDistr := fit evaluate.
	parameters := fittedDistr parameters.
	self should: [((parameters at: 1) - shape) abs < 0.1].
	self should: [((parameters at: 2) - scale) abs < 0.1].
	self should: [((parameters at: 3) - count) abs < 100]
    ]

    testLeastSquarePolynomial [
	"Code example 10.5"

	<category: 'estimation'>
	| fit estimation |
	fit := DhbPolynomialLeastSquareFit new: 3.
	fit
	    add: (DhbWeightedPoint point: 1 @ 2.0);
	    add: (DhbWeightedPoint point: 2 @ 21.0);
	    add: (DhbWeightedPoint point: 3 @ 72.0);
	    add: (DhbWeightedPoint point: 4 @ 173.0);
	    add: (DhbWeightedPoint point: 5 @ 342.0);
	    add: (DhbWeightedPoint point: 6 @ 597.0);
	    add: (DhbWeightedPoint point: 7 @ 956.0);
	    add: (DhbWeightedPoint point: 8 @ 1437.0);
	    add: (DhbWeightedPoint point: 9 @ 2058.0);
	    add: (DhbWeightedPoint point: 10 @ 2837.0).
	estimation := fit evaluate.
	self should: [((estimation value: 4.5) - 247.875) abs < 0.000000001].
	self should: [((estimation error: 4.5) - 0.5215298) abs < 0.00001].
	self should: 
		[((estimation value: 7.150000000000001) - 1019.932625) abs 
		    < (estimation error: 7.150000000000001)]
    ]

    testLinearRegression [
	"Code example 10.5"

	<category: 'estimation'>
	| linReg estimation |
	linReg := DhbLinearRegression new.
	linReg
	    add: 1 @ 0.72;
	    add: 2 @ 3.25;
	    add: 3 @ 5.75;
	    add: 4 @ 8.210000000000001;
	    add: 5 @ 10.71;
	    add: 6 @ 13.38;
	    add: 7 @ 15.82;
	    add: 8 @ 18.39;
	    add: 9 @ 20.72;
	    add: 10 @ 23.38.
	self should: [(linReg slope - 2.514727272727) abs < 0.000000000001].
	self should: [(linReg intercept + 1.798) abs < 0.000000000001].
	self should: 
		[(linReg correlationCoefficient - 0.999966922113) abs < 0.000000000001].
	estimation := linReg asEstimatedPolynomial.
	self 
	    should: [((estimation value: 4.5) - 9.518272727272701) abs < 0.000000000001].
	self should: 
		[((estimation value: 7.150000000000001) - 16.1823) abs < 0.000000000001]
    ]

    testMaximumLikelihood [
	"Code example 10.11"

	"Note: the seemingly large error on the fit results is due to the binning of the histogram."

	<category: 'estimation'>
	| count shape scale genDistr hist fit fittedDistr parameters |
	count := 10000.
	shape := 0.
	scale := 1.
	hist := DhbHistogram new.
	hist freeExtent: true.
	genDistr := DhbFisherTippettDistribution shape: shape scale: scale.
	count timesRepeat: [hist accumulate: genDistr random].
	fit := DhbMaximumLikekihoodHistogramFit histogram: hist
		    distributionClass: DhbFisherTippettDistribution.
	fittedDistr := fit evaluate.
	parameters := fittedDistr parameters.
	self should: [((parameters at: 1) - shape) abs < 0.1].
	self should: [((parameters at: 2) - scale) abs < 0.1].
	self should: [((parameters at: 3) - count) abs < 100]
    ]

    testTTest [
	<category: 'estimation'>
	| accC accMM confidenceLevel |
	accC := DhbStatisticalMoments new.
	#(5.560000000000001 5.89 4.660000000000001 5.690000000000001 5.34 4.79 4.8 7.860000000000001 3.64 5.700000000000001) 
	    do: [:x | accC accumulate: x].
	accMM := DhbStatisticalMoments new.
	#(7.480000000000001 6.75 3.77 5.71 7.25 4.730000000000001 6.230000000000001 5.600000000000001 5.940000000000001 4.58) 
	    do: [:x | accMM accumulate: x].
	confidenceLevel := accC tConfidenceLevel: accMM.
	self should: [(accC average - 5.393) abs < 0.000000001].
	self should: [(accC standardDeviation - 1.0990809292) abs < 0.000000001].
	self should: [(accMM average - 5.804000000000001) abs < 0.000000001].
	self should: [(accMM standardDeviation - 1.19415428) abs < 0.000000001].
	self should: [(confidenceLevel - 56.63207399890001) abs < 0.000000001]
    ]

    testBeta [
	"Code example 2.14"

	<category: 'function evaluation'>
	| value |
	value := 2.5 gamma * 5.5 gamma / 8 gamma.
	self should: [((2.5 beta: 5.5) - value) abs < 0.00000000000001]
    ]

    testBetaLog [
	"Code example 2.15"

	<category: 'function evaluation'>
	| value |
	value := 2.5 logGamma + 5.5 logGamma - 8 logGamma.
	self should: [((2.5 logBeta: 5.5) - value) abs < 0.0000000000001]
    ]

    testErrorFunctionCentile [
	"Code example 2.5"

	<category: 'function evaluation'>
	| weight average stDev centile |
	weight := 2.85.
	average := 3.39.
	stDev := 0.44.
	centile := ((weight - average) / stDev) errorFunction * 100.
	self should: [(centile - 10.986012) abs < 0.000001]
    ]

    testGamma [
	"Code example 2.10"

	<category: 'function evaluation'>
	| value |
	value := FloatD pi sqrt * 3 / 4.
	self should: [(2.5 gamma - value) abs < 0.00000000000001]
    ]

    testGammaLog [
	"Code example 2.11"

	<category: 'function evaluation'>
	| value |
	value := 2.5 gamma ln.
	self should: [(2.5 logGamma - value) abs < 0.0000000000001]
    ]

    testGammaLow [
	<category: 'function evaluation'>
	| value |
	value := FloatD pi sqrt / 2.
	self should: [((3 / 2) gamma - value) abs < 0.00000000000001]
    ]

    testGammaNegative [
	<category: 'function evaluation'>
	| value |
	value := FloatD pi / (1.5 gamma * (FloatD pi / -2) sin).
	self should: [((-1 / 2) gamma - value) abs < 0.00000000000001]
    ]

    testInterpolationBulirschStoer [
	<category: 'function evaluation'>
	| interpolator |
	interpolator := DhbBulirschStoerInterpolator new.
	1 to: 45
	    by: 2
	    do: [:x | interpolator add: x @ x degreesToRadians sin].
	self should: 
		[((interpolator value: 8) - 8 degreesToRadians sin) abs < 0.00000000000001]
    ]

    testInterpolationLagrange [
	"Code example 3.2"

	<category: 'function evaluation'>
	| interpolator |
	interpolator := DhbLagrangeInterpolator new.
	1 to: 45
	    by: 2
	    do: [:x | interpolator add: x @ x degreesToRadians sin].
	self should: 
		[((interpolator value: 8) - 8 degreesToRadians sin) abs < 0.00000000000001]
    ]

    testInterpolationLagrangeLinear [
	"Code example 3.1"

	<category: 'function evaluation'>
	| interpolator |
	interpolator := DhbLagrangeInterpolator 
		    points: (Array with: 1 @ 2 with: 3 @ 1).
	self should: [((interpolator value: 2.2) - 1.4) abs < 0.00000000000001]
    ]

    testInterpolationNeville [
	<category: 'function evaluation'>
	| interpolator |
	interpolator := DhbNevilleInterpolator new.
	1 to: 45
	    by: 2
	    do: [:x | interpolator add: x @ x degreesToRadians sin].
	self should: 
		[((interpolator value: 8) - 8 degreesToRadians sin) abs < 0.00000000000001]
    ]

    testInterpolationNevilleLinear [
	"Code example 3.1"

	<category: 'function evaluation'>
	| interpolator |
	interpolator := DhbNevilleInterpolator 
		    points: (Array with: 1 @ 2 with: 3 @ 1).
	self should: [((interpolator value: 2.2) - 1.4) abs < 0.00000000000001]
    ]

    testInterpolationNewtonLinear [
	"Code example 3.1"

	<category: 'function evaluation'>
	| interpolator |
	interpolator := DhbNewtonInterpolator 
		    points: (Array with: 1 @ 2 with: 3 @ 1).
	self should: [((interpolator value: 2.2) - 1.4) abs < 0.00000000000001]
    ]

    testInterpolationSpline [
	<category: 'function evaluation'>
	| interpolator |
	interpolator := DhbSplineInterpolator new.
	1 to: 45
	    by: 2
	    do: [:x | interpolator add: x @ x degreesToRadians sin].
	self 
	    should: [((interpolator value: 8) - 8 degreesToRadians sin) abs < 0.0000001]
    ]

    testInterpolationSplineLinear [
	"Code example 3.1"

	<category: 'function evaluation'>
	| interpolator |
	interpolator := DhbSplineInterpolator 
		    points: (Array with: 1 @ 2 with: 3 @ 1).
	self should: [((interpolator value: 2.2) - 1.4) abs < 0.00000000000001]
    ]

    testPolynomialAddition [
	<category: 'function evaluation'>
	| polynomial |
	polynomial := (DhbPolynomial coefficients: #(2 -3 1)) 
		    + (DhbPolynomial coefficients: #(-3 7 2 1)).
	self should: [(polynomial at: 0) = -1].
	self should: [(polynomial at: 1) = 4].
	self should: [(polynomial at: 2) = 3].
	self should: [(polynomial at: 3) = 1].
	self should: [(polynomial at: 4) = 0]
    ]

    testPolynomialDerivative [
	"Code example 2.3"

	<category: 'function evaluation'>
	| polynomial |
	polynomial := (DhbPolynomial coefficients: #(-3 7 2 1)) derivative.
	self should: [(polynomial at: 0) = 7].
	self should: [(polynomial at: 1) = 4].
	self should: [(polynomial at: 2) = 3].
	self should: [(polynomial at: 3) = 0].
	self should: [(polynomial at: 4) = 0]
    ]

    testPolynomialDivision [
	<category: 'function evaluation'>
	| pol1 pol2 polynomial |
	pol1 := DhbPolynomial coefficients: #(2 -3 1).
	pol2 := DhbPolynomial coefficients: #(-6 23 -20 3 -1 1).
	polynomial := pol2 / pol1.
	self should: [(polynomial at: 0) = -3].
	self should: [(polynomial at: 1) = 7].
	self should: [(polynomial at: 2) = 2].
	self should: [(polynomial at: 3) = 1].
	self should: [(polynomial at: 4) = 0].
	self should: [(polynomial at: 5) = 0].
	self should: [(polynomial at: 6) = 0]
    ]

    testPolynomialEvaluation [
	"Code example 2.2"

	<category: 'function evaluation'>
	| polynomial |
	polynomial := DhbPolynomial coefficients: #(2 -3 1).
	self should: [0 = (polynomial value: 1)]
    ]

    testPolynomialIntegral [
	"Code example 2.3"

	<category: 'function evaluation'>
	| polynomial |
	polynomial := (DhbPolynomial coefficients: #(-3 7 2 1)) integral.
	self should: [(polynomial at: 0) = 0].
	self should: [(polynomial at: 1) = -3].
	self should: [(polynomial at: 2) = (7 / 2)].
	self should: [(polynomial at: 3) = (2 / 3)].
	self should: [(polynomial at: 4) = (1 / 4)].
	self should: [(polynomial at: 5) = 0]
    ]

    testPolynomialIntegralWithConstant [
	"Code example 2.3"

	<category: 'function evaluation'>
	| polynomial |
	polynomial := (DhbPolynomial coefficients: #(-3 7 2 1)) integral: 5.
	self should: [(polynomial at: 0) = 5].
	self should: [(polynomial at: 1) = -3].
	self should: [(polynomial at: 2) = (7 / 2)].
	self should: [(polynomial at: 3) = (2 / 3)].
	self should: [(polynomial at: 4) = (1 / 4)].
	self should: [(polynomial at: 5) = 0]
    ]

    testPolynomialMultiplication [
	"Code example 2.3"

	<category: 'function evaluation'>
	| pol1 pol2 polynomial |
	pol1 := DhbPolynomial coefficients: #(2 -3 1).
	pol2 := DhbPolynomial coefficients: #(-3 7 2 1).
	polynomial := pol1 * pol2.
	self should: [(polynomial at: 0) = -6].
	self should: [(polynomial at: 1) = 23].
	self should: [(polynomial at: 2) = -20].
	self should: [(polynomial at: 3) = 3].
	self should: [(polynomial at: 4) = -1].
	self should: [(polynomial at: 5) = 1].
	self should: [(polynomial at: 6) = 0]
    ]

    testPolynomialNumberAddition [
	<category: 'function evaluation'>
	| polynomial |
	polynomial := 2 + (DhbPolynomial coefficients: #(2 -3 1)).
	self should: [(polynomial at: 0) = 4].
	self should: [(polynomial at: 1) = -3].
	self should: [(polynomial at: 2) = 1].
	self should: [(polynomial at: 3) = 0]
    ]

    testPolynomialNumberAdditionInverse [
	<category: 'function evaluation'>
	| polynomial |
	polynomial := (DhbPolynomial coefficients: #(2 -3 1)) + 2.
	self should: [(polynomial at: 0) = 4].
	self should: [(polynomial at: 1) = -3].
	self should: [(polynomial at: 2) = 1].
	self should: [(polynomial at: 3) = 0]
    ]

    testPolynomialNumberDivision [
	<category: 'function evaluation'>
	| polynomial |
	polynomial := (DhbPolynomial coefficients: #(2 -3 1)) / 2.
	self should: [(polynomial at: 0) = 1].
	self should: [(polynomial at: 1) = (-3 / 2)].
	self should: [(polynomial at: 2) = (1 / 2)].
	self should: [(polynomial at: 3) = 0]
    ]

    testPolynomialNumberMultiplication [
	<category: 'function evaluation'>
	| polynomial |
	polynomial := 2 * (DhbPolynomial coefficients: #(2 -3 1)).
	self should: [(polynomial at: 0) = 4].
	self should: [(polynomial at: 1) = -6].
	self should: [(polynomial at: 2) = 2].
	self should: [(polynomial at: 3) = 0]
    ]

    testPolynomialNumberMultiplicationInverse [
	<category: 'function evaluation'>
	| polynomial |
	polynomial := (DhbPolynomial coefficients: #(2 -3 1)) * 2.
	self should: [(polynomial at: 0) = 4].
	self should: [(polynomial at: 1) = -6].
	self should: [(polynomial at: 2) = 2].
	self should: [(polynomial at: 3) = 0]
    ]

    testPolynomialNumberSubtraction [
	<category: 'function evaluation'>
	| polynomial |
	polynomial := 2 - (DhbPolynomial coefficients: #(2 -3 1)).
	self should: [(polynomial at: 0) = 0].
	self should: [(polynomial at: 1) = 3].
	self should: [(polynomial at: 2) = -1].
	self should: [(polynomial at: 3) = 0]
    ]

    testPolynomialNumberSubtractionInverse [
	<category: 'function evaluation'>
	| polynomial |
	polynomial := (DhbPolynomial coefficients: #(2 -3 1)) - 2.
	self should: [(polynomial at: 0) = 0].
	self should: [(polynomial at: 1) = -3].
	self should: [(polynomial at: 2) = 1].
	self should: [(polynomial at: 3) = 0]
    ]

    testPolynomialSubtraction [
	<category: 'function evaluation'>
	| polynomial |
	polynomial := (DhbPolynomial coefficients: #(2 -3 1)) 
		    - (DhbPolynomial coefficients: #(-3 7 2 1)).
	self should: [(polynomial at: 0) = 5].
	self should: [(polynomial at: 1) = -10].
	self should: [(polynomial at: 2) = -1].
	self should: [(polynomial at: 3) = -1].
	self should: [(polynomial at: 4) = 0]
    ]

    testBissection [
	"Code Example 5.1"

	<category: 'iterative algorithms'>
	| zeroFinder result |
	zeroFinder := DhbBisectionZeroFinder 
		    function: [:x | x errorFunction - 0.9000000000000001].
	zeroFinder
	    setPositiveX: 10.0;
	    setNegativeX: 0.0.
	result := zeroFinder evaluate.
	self should: [zeroFinder hasConverged].
	self should: [(result - 1.28155193291605) abs < 0.00000000000001]
    ]

    testIncompleteBetaFunction [
	<category: 'iterative algorithms'>
	| function |
	function := DhbIncompleteBetaFunction shape: 2 shape: 5.
	self should: 
		[((function value: 0.8000000000000001) - 0.9984000000000001) abs < 0.00001]
    ]

    testIncompleteGammaFunction [
	<category: 'iterative algorithms'>
	| function |
	function := DhbIncompleteGammaFunction shape: 2.
	self should: [((function value: 2) - 0.59399414981) abs < 0.00000000001]
    ]

    testIntegrationRomberg [
	<category: 'iterative algorithms'>
	| integrator ln2 ln3 |
	integrator := DhbRombergIntegrator 
		    function: [:x | 1.0 / x]
		    from: 1
		    to: 2.
	ln2 := integrator evaluate.
	integrator from: 1 to: 3.
	ln3 := integrator evaluate.
	self should: [(2.0 ln - ln2) abs < (2 * integrator precision)].
	self should: [(3.0 ln - ln3) abs < (2 * integrator precision)]
    ]

    testIntegrationSimpson [
	<category: 'iterative algorithms'>
	| integrator ln2 ln3 |
	integrator := DhbSimpsonIntegrator 
		    function: [:x | 1.0 / x]
		    from: 1
		    to: 2.
	ln2 := integrator evaluate.
	integrator from: 1 to: 3.
	ln3 := integrator evaluate.
	self should: [(2.0 ln - ln2) abs < integrator precision].
	self should: [(3.0 ln - ln3) abs < integrator precision]
    ]

    testIntegrationTrapeze [
	"Code Example 6.1"

	<category: 'iterative algorithms'>
	| integrator ln2 ln3 |
	integrator := DhbTrapezeIntegrator 
		    function: [:x | 1.0 / x]
		    from: 1
		    to: 2.
	ln2 := integrator evaluate.
	integrator from: 1 to: 3.
	ln3 := integrator evaluate.
	self should: [(2.0 ln - ln2) abs < integrator precision].
	self should: [(3.0 ln - ln3) abs < integrator precision]
    ]

    testNewtonZeroFinder [
	"Code Example 5.3"

	<category: 'iterative algorithms'>
	| zeroFinder result |
	zeroFinder := DhbNewtonZeroFinder 
		    function: [:x | x errorFunction - 0.9000000000000001].
	zeroFinder initialValue: 1.0.
	result := zeroFinder evaluate.
	self should: [zeroFinder hasConverged].
	self should: [(result - 1.28155193867885) abs < zeroFinder precision]
    ]

    testPolynomialRoots [
	"Code Example 5.5"

	<category: 'iterative algorithms'>
	| polynomial roots |
	polynomial := DhbPolynomial coefficients: #(-10 -13 -2 1).
	roots := polynomial roots asSortedCollection asArray.
	self should: [roots size = 3].
	self should: 
		[((roots at: 1) + 2) abs 
		    < DhbFloatingPointMachine new defaultNumericalPrecision].
	self should: 
		[((roots at: 2) + 1) abs 
		    < DhbFloatingPointMachine new defaultNumericalPrecision].
	self should: 
		[((roots at: 3) - 5) abs 
		    < DhbFloatingPointMachine new defaultNumericalPrecision]
    ]

    testDeterminant [
	<category: 'linear algebra'>
	| m |
	m := DhbMatrix rows: #(#(3 2 4) #(2 -5 -1) #(1 -2 2)).
	self should: [m determinant = -42]
    ]

    testEigenvalues [
	"Code Example 8.15"

	<category: 'linear algebra'>
	| m charPol roots eigenvalues finder |
	m := DhbMatrix rows: #(#(3 -2 0) #(-2 7 1) #(0 1 5)).
	charPol := DhbPolynomial coefficients: #(82 -66 15 -1).
	roots := charPol roots asSortedCollection asArray reverse.
	finder := DhbJacobiTransformation matrix: m.
	finder desiredPrecision: 0.000000001.
	eigenvalues := finder evaluate.
	self should: [eigenvalues size = 3].
	self should: [((roots at: 1) - (eigenvalues at: 1)) abs < 0.000000001].
	self should: [((roots at: 2) - (eigenvalues at: 2)) abs < 0.000000001].
	self should: [((roots at: 3) - (eigenvalues at: 3)) abs < 0.000000001]
    ]

    testEigenvaluesLargest [
	"Code Example 8.13"

	<category: 'linear algebra'>
	| m charPol roots eigenvalue finder |
	m := DhbMatrix rows: #(#(3 -2 0) #(-2 7 1) #(0 1 5)).
	charPol := DhbPolynomial coefficients: #(82 -66 15 -1).
	roots := charPol roots asSortedCollection asArray reverse.
	finder := DhbLargestEigenValueFinder matrix: m.
	finder desiredPrecision: 0.00000001.
	eigenvalue := finder evaluate.
	self should: [((roots at: 1) - eigenvalue) abs < 0.00000001].
	finder := finder nextLargestEigenValueFinder.
	eigenvalue := finder evaluate.
	self should: [((roots at: 2) - eigenvalue) abs < 0.00000001]
    ]

    testLUPDecomposition [
	"Code Example 8.10"

	<category: 'linear algebra'>
	| s sol1 sol2 |
	s := DhbLUPDecomposition equations: #(#(3 2 4) #(2 -5 -1) #(1 -2 2)).
	sol1 := s solve: #(16 6 10).
	sol2 := s solve: #(7 10 9).
	self should: [sol1 size = 3].
	self should: [(sol1 at: 1) = 2].
	self should: [(sol1 at: 2) = -1].
	self should: [(sol1 at: 3) = 3].
	self should: [sol2 size = 3].
	self should: [(sol2 at: 1) = 1].
	self should: [(sol2 at: 2) = -2].
	self should: [(sol2 at: 3) = 2]
    ]

    testLinearEquations [
	"Code Example 8.6"

	<category: 'linear algebra'>
	| s sol1 sol2 |
	s := DhbLinearEquationSystem equations: #(#(3 2 4) #(2 -5 -1) #(1 -2 2))
		    constants: #(#(16 6 10) #(7 10 9)).
	sol1 := s solutionAt: 1.
	sol2 := s solutionAt: 2.
	self should: [sol1 size = 3].
	self should: [(sol1 at: 1) = 2].
	self should: [(sol1 at: 2) = -1].
	self should: [(sol1 at: 3) = 3].
	self should: [sol2 size = 3].
	self should: [(sol2 at: 1) = 1].
	self should: [(sol2 at: 2) = -2].
	self should: [(sol2 at: 3) = 2]
    ]

    testLinearEquationsSingle [
	<category: 'linear algebra'>
	| s sol |
	s := DhbLinearEquationSystem equations: #(#(1 2 0) #(3 5 4) #(5 6 3))
		    constant: #(0.1 12.5 10.3).
	sol := s solution.
	self should: [sol size = 3].
	self should: [(sol at: 1) equalsTo: 0.5].
	self should: [(sol at: 2) equalsTo: -0.2].
	self should: [(sol at: 3) equalsTo: 3.0]
    ]

    testLinearEquationsSingular [
	<category: 'linear algebra'>
	| s sol |
	s := DhbLinearEquationSystem equations: #(#(1 2 0) #(10 12 6) #(5 6 3))
		    constant: #(0.1 12.5 10.3).
	sol := s solution.
	self should: [sol isNil]
    ]

    testMatrixInversionSmall [
	<category: 'linear algebra'>
	| m c |
	m := DhbMatrix rows: #(#(3 2 4) #(2 -5 -1) #(1 -2 2)).
	c := m inverse * m.
	self should: [c numberOfRows = 3].
	self should: [c numberOfColumns = 3].
	self should: [((c rowAt: 1) at: 1) = 1].
	self should: [((c rowAt: 1) at: 2) = 0].
	self should: [((c rowAt: 1) at: 3) = 0].
	self should: [((c rowAt: 2) at: 1) = 0].
	self should: [((c rowAt: 2) at: 2) = 1].
	self should: [((c rowAt: 2) at: 3) = 0].
	self should: [((c rowAt: 3) at: 1) = 0].
	self should: [((c rowAt: 3) at: 2) = 0].
	self should: [((c rowAt: 3) at: 3) = 1]
    ]

    testMatrixOperation [
	"Code Example 8.1"

	<category: 'linear algebra'>
	| a b c |
	a := DhbMatrix rows: #(#(1 0 1) #(-1 -2 3)).
	b := DhbMatrix rows: #(#(1 2 3) #(-2 1 7) #(5 6 7)).
	c := a * b.
	self should: [c numberOfRows = 2].
	self should: [c numberOfColumns = 3].
	self should: [((c rowAt: 1) at: 1) = 6].
	self should: [((c rowAt: 1) at: 2) = 8].
	self should: [((c rowAt: 1) at: 3) = 10].
	self should: [((c rowAt: 2) at: 1) = 18].
	self should: [((c rowAt: 2) at: 2) = 14].
	self should: [((c rowAt: 2) at: 3) = 4]
    ]

    testVectorMatrixOperation [
	"Code Example 8.1"

	<category: 'linear algebra'>
	| a u v |
	a := DhbMatrix rows: #(#(1 0 1) #(-1 -2 3)).
	u := #(1 2 3) asVector.
	v := a * u.
	self should: [v size = 2].
	self should: [(v at: 1) = 4].
	self should: [(v at: 2) = 4]
    ]

    testVectorOperation [
	"Code Example 8.1"

	<category: 'linear algebra'>
	| u v w |
	u := #(1 2 3) asVector.
	v := #(3 4 5) asVector.
	w := 4 * u + (3 * v).
	self should: [w size = 3].
	self should: [(w at: 1) = 13].
	self should: [(w at: 2) = 20].
	self should: [(w at: 3) = 27]
    ]

    testVectorOperationInverse [
	<category: 'linear algebra'>
	| u v w |
	u := #(1 2 3) asVector.
	v := #(3 4 5) asVector.
	w := v * 4 - (3 * u).
	self should: [w size = 3].
	self should: [(w at: 1) = 9].
	self should: [(w at: 2) = 10].
	self should: [(w at: 3) = 11]
    ]

    testVectorProduct [
	"Code Example 8.1"

	<category: 'linear algebra'>
	| u v |
	u := #(1 2 3) asVector.
	v := #(3 4 5) asVector.
	self should: [u * v = 26]
    ]

    testVectorTransposeMatrixOperation [
	"Code Example 8.1"

	<category: 'linear algebra'>
	| c v w |
	c := DhbMatrix rows: #(#(6 8 10) #(18 14 4)).
	v := #(4 4) asVector.
	w := c transpose * v.
	self should: [w size = 3].
	self should: [(w at: 1) = 96].
	self should: [(w at: 2) = 88].
	self should: [(w at: 3) = 56]
    ]

    testOptimize [
	"General optimizer to test genetic algorithm"

	<category: 'optimization'>
	| fBlock finder result |
	fBlock := 
		[:x | 
		| r |
		r := x * x.
		r = 0 ifTrue: [1] ifFalse: [r sqrt sin / r]].
	finder := DhbMultiVariableGeneralOptimizer maximizingFunction: fBlock.
	finder desiredPrecision: 0.000001.
	finder
	    origin: #(0.5 1.0 0.5) asVector;
	    range: #(2 2 2) asVector.
	result := finder evaluate.
	self should: [finder precision < 0.000001].
	self should: [(result at: 1) abs < 0.000001].
	self should: [(result at: 2) abs < 0.000001].
	self should: [(result at: 3) abs < 0.000001]
    ]

    testOptimizeOneDimension [
	"Code example 11.1"

	<category: 'optimization'>
	| distr finder maximum |
	distr := DhbGammaDistribution shape: 2 scale: 5.
	finder := DhbOneVariableFunctionOptimizer maximizingFunction: distr.
	finder desiredPrecision: 0.000001.
	maximum := finder evaluate.
	self should: [(maximum - 5) abs < 0.000001].
	self should: [finder precision < 0.000001]
    ]

    testOptimizePowell [
	"Code example 11.3"

	<category: 'optimization'>
	| fBlock hillClimber educatedGuess result |
	fBlock := [:x | (x * x) negated exp].
	educatedGuess := #(0.5 1.0 0.5) asVector.
	hillClimber := DhbHillClimbingOptimizer maximizingFunction: fBlock.
	hillClimber initialValue: educatedGuess.
	hillClimber desiredPrecision: 0.000001.
	result := hillClimber evaluate.
	self should: [hillClimber precision < 0.000001].
	self should: [(result at: 1) abs < 0.000001].
	self should: [(result at: 2) abs < 0.000001].
	self should: [(result at: 3) abs < 0.000001]
    ]

    testOptimizeSimplex [
	"Code example 11.5"

	<category: 'optimization'>
	| fBlock simplex educatedGuess result |
	fBlock := [:x | (x * x) negated exp].
	educatedGuess := #(0.5 1.0 0.5) asVector.
	simplex := DhbSimplexOptimizer maximizingFunction: fBlock.
	simplex initialValue: educatedGuess.
	simplex desiredPrecision: 0.000001.
	result := simplex evaluate.
	self should: [simplex precision < 0.000001].
	self should: [(result at: 1) abs < 0.000001].
	self should: [(result at: 2) abs < 0.000001].
	self should: [(result at: 3) abs < 0.000001]
    ]

    accumulateAround: aVector size: aNumber into: aCollection [
	"Private - Generate a random point around the given center and insert it into the collection.
	 aNumber is the sigma for the distance to the center"

	<category: 'privateMethods'>
	| r phi psi localVector |
	r := (DhbNormalDistribution new: 0 sigma: aNumber) random.
	phi := FloatD pi random.
	psi := FloatD pi random.
	localVector := DhbVector new: 3.
	localVector
	    at: 1 put: phi sin * psi sin * r;
	    at: 2 put: phi cos * psi sin * r;
	    at: 3 put: psi cos * r.
	aCollection add: localVector + aVector
    ]

    generatedPoints: anInteger [
	"Private - Generate random points into aCollection. 3 clusters are used"

	<category: 'privateMethods'>
	| centers results |
	centers := Array new: 3.
	centers
	    at: 1 put: #(200 200 200) asVector;
	    at: 2 put: #(-200 200 200) asVector;
	    at: 3 put: #(200 200 -200) asVector.
	results := OrderedCollection new.
	anInteger timesRepeat: 
		[self 
		    accumulateAround: (centers at: 3 random + 1)
		    size: 1
		    into: results].
	^results
    ]

    setUp [
	"Reset the seed of the random numbers (to get consistent results)"

	<category: 'privateMethods'>
	DhbMitchellMooreGenerator reset: 0
    ]

    testGammaDistribution [
	<category: 'statistics'>
	| dist |
	dist := DhbGammaDistribution shape: 3.4 scale: 1.7.
	self should: [(dist average - (3.4 * 1.7)) abs < 0.000000001].
	self 
	    should: [(dist standardDeviation - (3.4 sqrt * 1.7)) abs < 0.000000001].
	self should: [((dist value: 4.5) - 0.1446067652) abs < 0.000000001].
	self 
	    should: [((dist distributionValue: 4.5) - 0.3982869736) abs < 0.000000001]
    ]

    testHistogram [
	<category: 'statistics'>
	| histogram |
	histogram := DhbHistogram new.
	histogram 
	    setRangeFrom: 0.0
	    to: 48.0
	    bins: 8.
	#(36 13 27 16 33 24 4 20 15 23 37 23 31 15 47 22 6 15 41 22 14 14 31 42 3 42 22 8 37 41) 
	    do: [:x | histogram accumulate: x].
	histogram
	    accumulate: -1;
	    accumulate: 55;
	    accumulate: 56.
	self should: [histogram count = 30].
	self should: [histogram underflow = 1].
	self should: [histogram overflow = 2].
	self should: [(histogram countAt: 1) = 3].
	self should: [(histogram countAt: 8.5) = 4].
	self should: [(histogram countAt: 16) = 8].
	self should: [(histogram countAt: 23.5) = 4].
	self should: [(histogram countAt: 31) = 6].
	self should: [(histogram countAt: 38.5) = 4].
	self should: [(histogram countAt: 46) = 1].
	self should: [(histogram average - 24.1333333333) abs < 0.000000001].
	self 
	    should: [(histogram standardDeviation - 12.461619237603) abs < 0.000000001].
	self should: [(histogram skewness - 0.116659884676) abs < 0.000000001].
	self should: [(histogram kurtosis + 1.004665562311) abs < 0.000000001]
    ]

    testNormalDistribution [
	<category: 'statistics'>
	| dist |
	dist := DhbNormalDistribution new: 3.4 sigma: 1.7.
	self should: [(dist average - 3.4) abs < 0.000000001].
	self should: [(dist standardDeviation - 1.7) abs < 0.000000001].
	self should: [((dist value: 4.5) - 0.1903464693) abs < 0.000000001].
	self should: 
		[((dist distributionValue: 4.5) - 0.7412031298000001) abs < 0.000000001]
    ]

    testStatisticalMoments [
	"comment"

	<category: 'statistics'>
	| accumulator |
	accumulator := DhbStatisticalMoments new.
	#(36 13 27 16 33 24 4 20 15 23 37 23 31 15 47 22 6 15 41 22 14 14 31 42 3 42 22 8 37 41) 
	    do: [:x | accumulator accumulate: x].
	self should: [(accumulator average - 24.1333333333) abs < 0.000000001].
	self 
	    should: [(accumulator standardDeviation - 12.461619237603) abs < 0.000000001].
	self should: [(accumulator skewness - 0.116659884676) abs < 0.000000001].
	self should: [(accumulator kurtosis + 1.004665562311) abs < 0.000000001]
    ]

    testStatisticalMomentsFast [
	<category: 'statistics'>
	| accumulator |
	accumulator := DhbFastStatisticalMoments new.
	#(36 13 27 16 33 24 4 20 15 23 37 23 31 15 47 22 6 15 41 22 14 14 31 42 3 42 22 8 37 41) 
	    do: [:x | accumulator accumulate: x].
	self should: [(accumulator average - 24.1333333333) abs < 0.000000001].
	self 
	    should: [(accumulator standardDeviation - 12.461619237603) abs < 0.000000001].
	self should: [(accumulator skewness - 0.116659884676) abs < 0.000000001].
	self should: [(accumulator kurtosis + 1.004665562311) abs < 0.000000001]
    ]

    testStatisticalMomentsFixed [
	<category: 'statistics'>
	| accumulator |
	accumulator := DhbFixedStatisticalMoments new.
	#(36 13 27 16 33 24 4 20 15 23 37 23 31 15 47 22 6 15 41 22 14 14 31 42 3 42 22 8 37 41) 
	    do: [:x | accumulator accumulate: x].
	self should: [(accumulator average - 24.1333333333) abs < 0.000000001].
	self 
	    should: [(accumulator standardDeviation - 12.461619237603) abs < 0.000000001].
	self should: [(accumulator skewness - 0.116659884676) abs < 0.000000001].
	self should: [(accumulator kurtosis + 1.004665562311) abs < 0.000000001]
    ]
]



DhbTestCase subclass: DhbTestNumericPrecision [
    
    <comment: nil>
    <category: 'DHB Numerical SUnits'>

    testDecimalAdd [
	<category: 'decimal floating number'>
	| a b |
	a := DhbDecimalFloatingNumber new: 1.
	b := DhbDecimalFloatingNumber new: 2.
	self assert: (a + b) value = 3.
	a := DhbDecimalFloatingNumber new: 1.56.
	b := DhbDecimalFloatingNumber new: 2.2.
	self assert: (a + b) value = 3.76
    ]

    testDecimalMultiple [
	<category: 'decimal floating number'>
	| a b result |
	a := DhbDecimalFloatingNumber new: 2.
	b := DhbDecimalFloatingNumber new: 2.
	self assert: (a * b) value = 4.
	a := DhbDecimalFloatingNumber new: 1.5.
	b := DhbDecimalFloatingNumber new: 2.5.
	result := (a * b) value asFloat - (1.5 * 2.5).
	self assert: result abs < 0.00001
    ]

    testComputeLargestNumber [
	<category: 'floating point machine'>
	| machine |
	machine := DhbFloatingPointMachine new.
	machine computeLargestNumber.
	self assert: machine largestNumber > 1.0000001e25
    ]

    testComputeSmallestNumber [
	<category: 'floating point machine'>
	| machine |
	machine := DhbFloatingPointMachine new.
	machine computeSmallestNumber.
	self assert: machine smallestNumber < 1.0e-25
    ]

    testMachinePrecision [
	<category: 'floating point machine'>
	| machine |
	machine := DhbFloatingPointMachine new.
	machine computeMachinePrecision.
	self assert: machine machinePrecision < 0.0000099999998e
    ]
]



DhbTestCase subclass: DhbTestFunctions [
    
    <comment: nil>
    <category: 'DHB Numerical SUnits'>

    testAdd [
	<category: 'polynomial'>
	| a b c |
	a := DhbPolynomial coefficients: #(2 1 1).
	c := a + 3.
	self assert: c coefficients = #(5 1 1).
	b := DhbPolynomial coefficients: #(1 5).
	c := a + b.
	self assert: c coefficients = #(3 6 1)
    ]

    testDerivative [
	<category: 'polynomial'>
	| a answer |
	a := DhbPolynomial coefficients: #(5 2 3).
	answer := DhbPolynomial coefficients: #(2 6).
	self assert: a derivative = answer
    ]

    testDivide [
	<category: 'polynomial'>
	| a b c answer |
	a := DhbPolynomial coefficients: #(9 6 3).
	c := a / 3.
	self assert: c coefficients = #(3 2 1).
	answer := DhbPolynomial coefficients: #(3 3).
	b := DhbPolynomial coefficients: #(1 1).
	a := answer * b.
	c := a / b.
	self assert: c = answer
    ]

    testEqual [
	<category: 'polynomial'>
	| a b |
	a := DhbPolynomial coefficients: #(5 2 3).
	b := DhbPolynomial coefficients: #(5 2 3).
	self assert: a = b
    ]

    testIntegral [
	<category: 'polynomial'>
	| a b |
	a := DhbPolynomial coefficients: #(0 2 3).
	b := a derivative.
	self assert: b integral = a
    ]

    testMultiply [
	<category: 'polynomial'>
	| a b c |
	a := DhbPolynomial coefficients: #(3 2 1).
	c := a * 3.
	self assert: c coefficients = #(9 6 3).
	b := DhbPolynomial coefficients: #(1 1).
	c := a * b.
	self assert: c coefficients = #(3 5 3 1)
    ]

    testValue [
	<category: 'polynomial'>
	| square |
	square := DhbPolynomial coefficients: #(2 1 1).
	self
	    assert: (square value: 1) = 4;
	    assert: (square value: 3) = (2 + (1 * 3) + (1 * 3 * 3)).
	square := DhbPolynomial coefficients: #(2).
	self
	    assert: (square value: 1) = 2;
	    assert: (square value: 0) = 2
    ]
]



DhbTestCase subclass: DhbTestBeta [
    
    <comment: nil>
    <category: 'DHB Numerical SUnits'>

    testBeta [
	<category: 'tests'>
	self assert: (2 beta: 4) isNumber
    ]
]

PK
     �Mh@�f�Mg  g            ��    Integration.stUT dqXOux �  �  PK
     �Mh@��M�*{  *{            ���  Optimization.stUT dqXOux �  �  PK
     �Mh@T/�d�H  �H            ��"�  Approximation.stUT dqXOux �  �  PK
     �Mh@Nuc^  ^            ����  RNG.stUT dqXOux �  �  PK
     �[h@��yt  t            ����  package.xmlUT ȉXOux �  �  PK
     �Mh@1X��a �a           ��M�  Distributions.stUT dqXOux �  �  PK
     �Mh@1�]�&  &            ��BZ NumericsAdds.stUT dqXOux �  �  PK
     �Mh@��x  �x            ���x Basic.stUT dqXOux �  �  PK
     �Mh@x�[�I  �I            ���� Functions.stUT dqXOux �  �  PK    �Mh@�-Q�   �  	         ���; ChangeLogUT dqXOux �  �  PK
     �Mh@�����  �            ���< Matrixes.stUT dqXOux �  �  PK
     �Mh@�e7z z           ��� Statistics.stUT dqXOux �  �  PK
     �Mh@�Q�F��  ��            ���� NumericsTests.stUT dqXOux �  �  PK      0  �   