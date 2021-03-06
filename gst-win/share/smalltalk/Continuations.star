PK
     �Mh@3��,�  �    ShiftResetTest.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Delimited continuations tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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






"Mindbending fun."

Object subclass: Monad [
    Monad class >> do: aBlock [
	^[
	    | monad |
	    monad := self new.
	    monad lift: (aBlock cull: monad) ] reset
    ]

    bind: anObject [
	^[ :k | self bind: anObject with: k ] shift
    ]

    bind: anObject with: k [
	self subclassResponsibility
    ]

    lift: anObject [
	self subclassResponsibility
    ]
]

Monad subclass: AbstractAmbMonad [
    Fail := Object new.
    AbstractAmbMonad class >> fail [ ^Fail ]

    oneOf: anArray [ ^self bind: anArray ]
    valueOfOneOf: aBlockArray [ ^(self oneOf: aBlockArray) value ]
]

AbstractAmbMonad subclass: AmbMonad [
    bind: anObject with: k [ ^anObject gather: k ]
    lift: anObject [ ^anObject == Fail ifTrue: [ #() ] ifFalse: [ {anObject} ] ]
]

AbstractAmbMonad subclass: AnyMonad [
    bind: anObject with: k [ ^anObject anySatisfy: k ]
    lift: anObject [ ^anObject ~~ Fail ]
]

AbstractAmbMonad subclass: CountMonad [
    bind: anObject with: k [ ^(anObject collect: k) fold: [ :a :b | a + b ] ]
    lift: anObject [ ^anObject == Fail ifTrue: [ 0 ] ifFalse: [ 1 ] ]
]

Array extend [
    queensCheck [
        | x y size |
        1 to: self size
            do:
                [:i |
                x := self at: i.
                1 to: i - 1
                    do:
                        [:j |
                        y := self at: j.
                        x = y ifTrue: [ ^false ].
                        (x - y) abs = (i - j) abs ifTrue: [ ^false ]].
        ].
	^true
    ]
]

TestCase subclass: ShiftResetTest [
    testSimple [
	self should: [1 + [:k | 3] shift] raise: Error.
	self assert: (1 + [3] reset) = 4.
	self assert: (1 + [2 * [:k | k value: 3 ] shift] reset) = 7.
	self assert: (1 + [2 * [:k | k value: (k value: 3) ] shift] reset) = 13
    ]

    testNumbers [
	| block |
	block := [ :amb | 
	    | a b c d |
	    d := amb oneOf: #(0 64 128 192).
	    c := amb oneOf: #(0 16 32 48).
	    b := amb oneOf: #(0 4 8 12).
	    a := amb oneOf: #(0 1 2 3).
	    a + b + c + d ].
	self assert: (AmbMonad do: block) size = (CountMonad do: block)
    ]

    testAny [
	| result |
	result := 3 to: 5 collect: [ :size |
	    AnyMonad do: [ :amb || board |
	        board := 1 to: size collect: [:a | amb oneOf: (1 to: size)].
	        board queensCheck
		    ifTrue: [ board ]
		    ifFalse: [ AmbMonad fail ]] ].
	self deny: result first.
	self assert: result second.
	self assert: result third
    ]

    testCount [
	| result |
	result := 3 to: 5 collect: [ :size |
	    CountMonad do: [ :amb || board |
	        board := 1 to: size collect: [:a | amb oneOf: (1 to: size)].
	        board queensCheck
		    ifTrue: [ board ]
		    ifFalse: [ AmbMonad fail ]] ].
	self assert: result first = 0.
	self assert: result second = 2.
	self assert: result third = 10
    ]

]
PK
     �Zh@���`  `    package.xmlUT	 ��XO��XOux �  �  <package>
  <name>Continuations</name>
  <test>
    <prereq>Continuations</prereq>
    <prereq>SUnit</prereq>
    <sunit>ContinuationTest AmbTest ShiftResetTest</sunit>
  
    <filein>Test.st</filein>
    <filein>AmbTest.st</filein>
    <filein>ShiftResetTest.st</filein>
  </test>

  <filein>Amb.st</filein>
  <filein>ShiftReset.st</filein>
</package>PK
     �Mh@$�r�  �  
  AmbTest.stUT	 cqXO��XOux �  �  TestCase subclass: AmbTest [
    | amb |
    
    <comment: nil>
    <category: 'Seaside-Seaside-Continuations'>

    setUp [
	<category: 'as yet unclassified'>
	amb := Amb new
    ]

    testAllValuesAboveFive [
	<category: 'as yet unclassified'>
	| x results |
	results := amb allValues: 
			[x := amb oneOf: (1 to: 10).
			amb assert: x > 5.
			x].
	self assert: results = #(6 7 8 9 10)
    ]

    testMaybe [
	<category: 'as yet unclassified'>
	| x y z |
	x := amb maybe.
	y := amb maybe.
	z := amb maybe not.
	amb deny: x = y.
	amb deny: x = z.
	self assert: x.
	self deny: y.
	self deny: z
    ]

    testPickANumber [
	<category: 'as yet unclassified'>
	self assert: self pickANumber = 1
    ]

    testPickANumberAboveFive [
	<category: 'as yet unclassified'>
	| x |
	x := self pickANumber.
	amb assert: x > 5.
	self assert: x = 6
    ]

    testFactoring [
	<category: 'as yet unclassified'>
	self assert: (self factors: 7) = #(7).
	self assert: (self factors: 8) = #(2 2 2).
	self assert: (self factors: 84) = #(2 2 3 7)
    ]

    testSetIntersection [
	<category: 'as yet unclassified'>
	| x |
	x := amb allValues: 
			[| x y |
			x := amb oneOf: #(#one #two #three #four).
			y := amb oneOf: #(#two #four #six #eight).
			amb assert: x = y.
			x].
	self assert: x size = 2.
	self assert: (x includes: #two).
	self assert: (x includes: #four).
	x := amb allOf: #(#one #two #three #four)
		    satisfying: [:x | x = (amb oneOf: #(#two #four #six #eight))].
	self assert: x size = 2.
	self assert: (x includes: #two).
	self assert: (x includes: #four).
	x := amb allOf: #(#one #two #three #four)
		    satisfying: [:x | amb oneOf: #(#two #four #six #eight) satisfies: [:y | x = y]].
	self assert: x size = 2.
	self assert: (x includes: #two).
	self assert: (x includes: #four)
    ]

    testSicpLogicProblem [
	"Baker, Cooper, Fletcher, Miller, and Smith live on different floors of an apartment house that contains only five floors. Baker does not live on the top floor. Cooper does not live on the bottom floor. Fletcher does not live on either the top or the bottom floor. Miller lives on a higher floor than does Cooper. Smith does not live on a floor adjacent to Fletcher's. Fletcher does not live on a floor adjacent to Cooper's. Where does everyone live?"

	"This implementation is too slow - uncomment to actually run it."

	<category: 'as yet unclassified'>
	| baker cooper fletcher miller smith |
	baker := amb oneOf: (1 to: 5).
	cooper := amb oneOf: (1 to: 5).
	fletcher := amb oneOf: (1 to: 5).
	miller := amb oneOf: (1 to: 5).
	smith := amb oneOf: (1 to: 5).
	amb 
	    assert: ((Set new)
		    add: baker;
		    add: cooper;
		    add: fletcher;
		    add: miller;
		    add: smith;
		    size) = 5.
	amb deny: baker = 5.
	amb deny: cooper = 1.
	amb deny: fletcher = 5.
	amb deny: fletcher = 1.
	amb assert: miller > cooper.
	amb deny: (smith - fletcher) abs = 1.
	amb deny: (fletcher - cooper) abs = 1.
	self assert: baker = 3.
	self assert: cooper = 2.
	self assert: fletcher = 4.
	self assert: miller = 5.
	self assert: smith = 1
    ]

    testSicpLogicProblemFaster [
	"Baker, Cooper, Fletcher, Miller, and Smith live on different floors
	 of an apartment house that contains only five floors. Baker does
	 not live on the top floor. Cooper does not live on the bottom
	 floor. Fletcher does not live on either the top or the bottom
	 floor. Miller lives on a higher floor than does Cooper. Smith does
	 not live on a floor adjacent to Fletcher's. Fletcher does not live
	 on a floor adjacent to Cooper's. Where does everyone live?"

	<category: 'as yet unclassified'>
	| baker cooper fletcher miller smith |
	fletcher := amb oneOf: (1 to: 5).
	amb deny: fletcher = 5.
	amb deny: fletcher = 1.
	smith := amb oneOf: (1 to: 5).
	amb deny: (smith - fletcher) abs = 1.
	cooper := amb oneOf: (1 to: 5).
	amb deny: cooper = 1.
	amb deny: (fletcher - cooper) abs = 1.
	miller := amb oneOf: (1 to: 5).
	amb assert: miller > cooper.
	baker := amb oneOf: (1 to: 5).
	amb deny: baker = 5.
	amb 
	    assert: ((Set new)
		    add: baker;
		    add: cooper;
		    add: fletcher;
		    add: miller;
		    add: smith;
		    size) = 5.
	self assert: baker = 3.
	self assert: cooper = 2.
	self assert: fletcher = 4.
	self assert: miller = 5.
	self assert: smith = 1
    ]

    testSolveAnEquation [
	<category: 'as yet unclassified'>
	| x y |
	x := amb oneOf: (1 to: 10).
	y := amb oneOf: (1 to: 10).
	amb assert: y * x = 42.
	self assert: x = 6.
	self assert: y = 7
    ]

    testAlways [
	<category: 'as yet unclassified'>
	self 
	    assert: (amb always: 
			[| x |
			x := amb maybe.
			amb assert: x | x not]).
	self deny: (amb always: 
			[| x |
			x := amb maybe.
			amb assert: x])
    ]

    testCountValues [
	<category: 'as yet unclassified'>
	self assert: (amb countValues: [self queens: 3]) = 0.
	self assert: (amb countValues: [self queens: 4]) = 2
    ]

    testHasValue [
	<category: 'as yet unclassified'>
	self deny: (amb hasValue: [self queens: 3]).
	self assert: (amb hasValue: [self queens: 4])
    ]

    testNoneOfSatisfies [
	<category: 'as yet unclassified'>
	self deny: (self primeNoneOf: 8).
	self assert: (self primeNoneOf: 7)
    ]

    testAllOfSatisfy [
	<category: 'as yet unclassified'>
	self deny: (self primeAllOf: 8).
	self assert: (self primeAllOf: 7).
	self assert: (amb allOf: (2 to: 4)
		    satisfy: [:x | amb allOf: (5 to: 7) satisfy: [:y | x < y]])
    ]

    testOneOfSatisfies [
	<category: 'as yet unclassified'>
	self deny: (self primeOneOf: 8).
	self assert: (self primeOneOf: 7).
	self assert: (amb oneOf: (4 to: 6)
		    satisfies: [:x | amb oneOf: (2 to: 4) satisfies: [:y | x = y]])
    ]

    testDoubleNegation [
	"This fails -- it is clear if you consider that..."

	<category: 'as yet unclassified'>
	self deny: (amb noneOf: (5 to: 7)
		    satisfies: [:x | amb noneOf: (2 to: 4) satisfies: [:y | x < y]]).

	"... this passes, and is equivalent to the above."
	self assert: (amb oneOf: (5 to: 7)
		    satisfies: [:x | amb noneOf: (2 to: 4) satisfies: [:y | x < y]]).

	"But what we meant was actually this."
	self assert: (amb noneOf: (5 to: 7)
		    satisfies: [:x | amb oneOf: (2 to: 4) satisfies: [:y | x < y]])
    ]

    testQueens [
	<category: 'as yet unclassified'>
	| results |
	results := amb allValues: [self queens: 5].
	self assert: results size = 10.
	self assert: (results includes: #(1 3 5 2 4)).
	self assert: (results includes: #(5 3 1 4 2)).
	self deny: (results includes: #(1 2 3 4 5)).
	self assert: (results allSatisfy: [:x | x asSet size = 5])
    ]

    pickANumber [
	<category: 'problems'>
	^self pickANumberGreaterThan: 0
    ]

    pickANumberGreaterThan: aNumber [
	<category: 'problems'>
	^amb valueOf: [aNumber + 1] or: [self pickANumberGreaterThan: aNumber + 1]
    ]

    factors: n [
	<category: 'problems'>
	| lastDivisor check |
	n <= 2 ifTrue: [^{n}].
	lastDivisor := ValueHolder with: 1.
	^amb allValues: 
		[| divisor factor |
		divisor := amb oneOf: (2 to: n).
		amb assert: n \\ divisor == 0.
		amb assert: divisor \\ lastDivisor value == 0.
		factor := divisor / lastDivisor value.
		lastDivisor value: divisor.
		factor]
    ]

    primeOneOf: n [
	<category: 'problems'>
	| limit |
	limit := n sqrt ceiling.
	^(amb oneOf: (2 to: limit) satisfies: [:x | n \\ x = 0]) not
    ]

    primeNoneOf: n [
	<category: 'problems'>
	| limit |
	limit := n sqrt ceiling.
	^amb noneOf: (2 to: limit) satisfies: [:x | n \\ x = 0]
    ]

    primeAllOf: n [
	<category: 'problems'>
	| limit |
	limit := n sqrt ceiling.
	^amb allOf: (2 to: limit) satisfy: [:x | n \\ x > 0]
    ]

    queens: size [
	<category: 'problems'>
	| board x y results |
	board := (1 to: size) collect: [:a | amb oneOf: (1 to: size)].
	1 to: size
	    do: 
		[:i | 
		x := board at: i.
		1 to: i - 1
		    do: 
			[:j | 
			y := board at: j.
			amb assert: x ~= y.
			amb assert: (x - y) abs ~= (i - j) abs]].
	^board copy
    ]
]
PK
     �Mh@2�r�C
  C
    ShiftReset.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Delimited continuations Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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
    "MetaContinuation := Kernel.ProcessVariable key: Object new."
    MetaContinuation := ValueHolder new.

    BlockClosure class >> continueWith: anObject [
	"Pass anObject to the metacontinuation."
	| mc |
	mc := MetaContinuation value.
	mc isNil ifTrue: [ self error: 'you forgot the top-level reset...' ].
	mc value: anObject
    ]

    BlockClosure class >> continueAt: cc [
	"Set the metacontinuation to one that restores the old value and
	 restarts cc."
	| mc |
	mc := MetaContinuation value.
	MetaContinuation value: [ :v |
	    MetaContinuation value: mc.
	    cc value: v ].
    ]

    reset [
	^Continuation escapeDo: [ :cc |
	    BlockClosure
	        "Make the metacontinuation pass the result to the invoker
	         of reset, until it is invoked."
		continueAt: cc;

		"Pass the result to the metacontinuation.  The
		 metacontinuation restores the outer metacontinuation, and
		 binds the result by continuing on cc."
		continueWith: self value ]
    ]

    shift [
	^Continuation escapeDo: [ :cc |
	    | escape |
	    "In order to escape, we obviously have to pass v to the
	     continuation cc.  However, because this discards the
	     rest of the `shifted' block, we protect it with reset."
	    escape := [ :v | [cc value: v] reset ].
	
	    BlockClosure continueWith: (self cull: escape) ]
    ]
]
PK
     �Mh@A��q�  �    Amb.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Lisp continuations for Smalltalk: the Amb evaluator
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2004-2009 Avi Bryant.
|
| Permission is hereby granted, free of charge, to any person obtaining a
| copy of this software and associated documentation files (the `Software'),
| to deal in the Software without restriction, including without limitation
| the rights to use, copy, modify, merge, publish, distribute, sublicense,
| and/or sell copies of the Software, and to permit persons to whom the
| Software is furnished to do so, subject to the following conditions:
| 
| The above copyright notice and this permission notice shall be included
| in all copies or substantial portions of the Software.
| 
| THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS
| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
| FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
| THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
| OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
| ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
| OTHER DEALINGS IN THE SOFTWARE.
 ======================================================================"



Object subclass: Amb [
    | failureContinuation direction |
    
    <category: 'Seaside-Seaside-Continuations'>
    <comment: nil>

    Amb class >> new [
	<category: 'new'>
	^super new initialize
    ]

    Amb class >> allValues: aBlock [
	<category: 'new'>
	| amb |
	amb := self new.
	^amb allValues: [aBlock value: amb]
    ]

    withAllValues: aBlock do: serviceBlock [
	<category: 'superpositions'>
	| kPrev count |
	kPrev := failureContinuation.
	(Continuation currentDo: 
		[:kRetry | 
		failureContinuation := [:v | kRetry value: false].
		serviceBlock value: aBlock value.
		kRetry value: true]) 
	    ifTrue: [self fail].
	failureContinuation := kPrev
    ]

    always: aBlock [
	<category: 'superpositions'>
	direction := direction not.
	^[(self hasValue: aBlock) not] ensure: [direction := direction not]
    ]

    countValues: aBlock [
	<category: 'superpositions'>
	| count |
	count := ValueHolder with: 0.
	self withAllValues: aBlock do: [:x | count value: count value + 1].
	^count value
    ]

    allValues: aBlock [
	<category: 'superpositions'>
	| results |
	results := OrderedCollection new.
	self withAllValues: aBlock do: [:x | results add: x].
	^results asArray
    ]

    assert: aBoolean [
	<category: 'superpositions'>
	aBoolean == direction ifFalse: [self fail]
    ]

    deny: aBoolean [
	<category: 'superpositions'>
	self assert: aBoolean not
    ]

    fail [
	<category: 'superpositions'>
	^failureContinuation value: nil
    ]

    hasValue: aBlock [
	<category: 'superpositions'>
	| kPrev ok |
	kPrev := failureContinuation.
	ok := Continuation currentDo: 
			[:kRetry | 
			failureContinuation := [:v | kRetry value: false].
			aBlock value.
			kRetry value: true].
	failureContinuation := kPrev.
	^ok
    ]

    initialize [
	<category: 'superpositions'>
	failureContinuation := [:v | self error: 'Amb tree exhausted'].
	direction := true
    ]

    maybe [
	<category: 'superpositions'>
	^self oneOf: 
		{true.
		false}
    ]

    noneOf: aCollection satisfies: aBlock [
	<category: 'superpositions'>
	^(self oneOf: aCollection satisfies: aBlock) not
    ]

    allOf: aCollection satisfying: aBlock [
	<category: 'superpositions'>
	^self allValues: 
		[| x |
		x := self oneOf: aCollection.
		self assert: (aBlock value: x).
		x]
    ]

    allOf: aCollection satisfy: aBlock [
	<category: 'superpositions'>
	^(self hasValue: 
		[| x |
		x := self oneOf: aCollection.
		self deny: (aBlock value: x)]) 
	    not
    ]

    oneOf: aCollection satisfies: aBlock [
	<category: 'superpositions'>
	^self hasValue: 
		[| x |
		x := self oneOf: aCollection.
		self assert: (aBlock value: x)]
    ]

    oneOf: aCollection [
	<category: 'superpositions'>
	^self valueOfOneOf: aCollection through: [:ea | ea]
    ]

    valueOf: blockOne or: blockTwo [
	<category: 'superpositions'>
	^self valueOfOneOf: 
		{blockOne.
		blockTwo}
    ]

    valueOf: blockOne or: blockTwo or: blockThree [
	<category: 'superpositions'>
	^self valueOfOneOf: 
		{blockOne.
		blockTwo.
		blockThree}
    ]

    valueOfOneOf: blockCollection [
	<category: 'superpositions'>
	^self valueOfOneOf: blockCollection through: [:ea | ea value]
    ]

    valueOfOneOf: blockCollection through: aBlock [
	<category: 'superpositions'>
	| kPrev |
	kPrev := failureContinuation.
	^Continuation currentDo: 
		[:kEntry | 
		blockCollection do: 
			[:ea | 
			Continuation currentDo: 
				[:kNext | 
				failureContinuation := 
					[:v | 
					failureContinuation := kPrev.
					kNext value: v] fixTemps.
				kEntry value: (aBlock value: ea)]].
		kPrev value: nil]
    ]
]
PK
     �Mh@U�y  y    Test.stUT	 cqXO��XOux �  �  


TestCase subclass: ContinuationTest [
    | tmp tmp2 |
    
    <comment: nil>
    <category: 'Seaside-Seaside-Continuations'>

    callcc: aBlock [
	<category: 'as yet unclassified'>
	^Continuation currentDo: aBlock
    ]

    testBlockEscape [
	<category: 'as yet unclassified'>
	| x |
	tmp := 0.
	x := 
		[tmp := tmp + 1.
		tmp2 value].
	self callcc: 
		[:cc | 
		tmp2 := cc.
		x value].
	tmp2 := [].
	x value.
	self assert: tmp = 2
    ]

    testBlockTemps [
	<category: 'as yet unclassified'>
	| y |
	#(1 2 3) do: 
		[:i | 
		| x |
		x := i.
		tmp 
		    ifNil: [tmp2 := self callcc: 
					[:cc | 
					tmp := cc.
					[:q | ]]].
		tmp2 value: x.
		x := 17].
	y := self callcc: 
			[:cc | 
			tmp value: cc.
			42].
	self assert: y = 1
    ]

    testBlockVars [
	<category: 'as yet unclassified'>
	| continuation |
	tmp := 0.
	tmp := (self callcc: 
			[:cc | 
			continuation := cc.
			0]) + tmp.
	tmp2 isNil 
	    ifFalse: [tmp2 value]
	    ifTrue: 
		[#(1 2 3) 
		    do: [:i | self callcc: 
				[:cc | 
				tmp2 := cc.
				continuation value: i]]].
	self assert: tmp = 6
    ]

    testMethodTemps [
	<category: 'as yet unclassified'>
	| i continuation |
	i := 0.
	i := i + (self callcc: 
				[:cc | 
				continuation := cc.
				1]).
	self assert: i ~= 3.
	i = 2 ifFalse: [continuation value: 2]
    ]

    testSimpleCallCC [
	<category: 'as yet unclassified'>
	| x continuation |
	x := self callcc: 
			[:cc | 
			continuation := cc.
			false].
	x ifFalse: [continuation value: true].
	self assert: x
    ]

    testSimplestCallCC [
	<category: 'as yet unclassified'>
	| x |
	x := self callcc: [:cc | cc value: true].
	self assert: x
    ]
]
PK
     �Mh@3��,�  �            ��    ShiftResetTest.stUT cqXOux �  �  PK
     �Zh@���`  `            ��5  package.xmlUT ��XOux �  �  PK
     �Mh@$�r�  �  
          ���  AmbTest.stUT cqXOux �  �  PK
     �Mh@2�r�C
  C
            ��1  ShiftReset.stUT cqXOux �  �  PK
     �Mh@A��q�  �            ���;  Amb.stUT cqXOux �  �  PK
     �Mh@U�y  y            ��nO  Test.stUT cqXOux �  �  PK      �  (V    