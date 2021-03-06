PK
     �Mh@�)���  �    SqueakParser.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Squeak input parser
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
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



STFileInParser subclass: SqueakFileInParser [
    
    <comment: nil>
    <category: 'Refactory-Parser'>

    evaluate: node [
	"Convert some Squeak messages to GNU Smalltalk file-out syntax.
	 This avoids that the STParsingDriver need to know about other
	 dialects."

	<category: 'accessing'>
	| stmt |
	node statements size == 1 ifFalse: [^super evaluate: node].
	stmt := node statements first.
        stmt isReturn ifTrue: [ stmt := stmt value ].
	stmt isMessage ifFalse: [^super evaluate: node].
	stmt selector == #addCategory: ifTrue: [^false].
	stmt selector == #commentStamp:prior: 
	    ifTrue: 
		[stmt arguments: {RBLiteralNode new literalToken: scanner nextRawChunk}.
		stmt selector: #comment:].
	stmt selector == #methodsFor:stamp: 
	    ifTrue: 
		[stmt arguments first value = 'as yet unclassified' 
		    ifTrue: [stmt arguments first token value: nil].
		stmt arguments: {stmt arguments first}.
		stmt selector: #methodsFor:].
	^super evaluate: node
    ]

    scannerClass [
	"We need a special scanner to convert the double-bangs in strings
	 to single bangs.  Unlike in GNU Smalltalk, all bangs must be
	 `escaped' in Squeak."

	<category: 'private-parsing'>
	^SqueakFileInScanner
    ]
]



STFileScanner subclass: SqueakFileInScanner [
    
    <comment: nil>
    <category: 'Refactory-Parser'>

    on: aStream [
	<category: 'accessing'>
	super on: aStream.
	classificationTable := classificationTable copy.
	classificationTable at: $! value put: #binary
    ]

    scanLiteralString [
	"In theory, this should also be applied to method comments, but the
	 representation of comments in RBParseNode makes it more complicated;
	 not a big deal."

	<category: 'accessing'>
	| val |
	val := super scanLiteralString.
	val value: (val value copyReplaceAll: '!!' with: '!').
	val 
	    value: (val value copyReplacing: 13 asCharacter withObject: 10 asCharacter).
	^val
    ]

    scanLiteralCharacter [
	"Also treat ! specially here."

	<category: 'accessing'>
	| val |
	val := super scanLiteralCharacter.
	val value = $! ifTrue: [self step].
	^val
    ]

    scanBinary: aClass [
	"Treat ! specially, it is a binary operator in Squeak (if properly
	 escaped)."

        <category: 'private-scanning'>
        | val |
	currentCharacter == $! ifTrue: [
	    self step == $! 
	        ifFalse: [^RBSpecialCharacterToken value: $! start: tokenStart]].

        buffer nextPut: currentCharacter.
        self step.
        (characterType == #binary and: [currentCharacter ~~ $-])
            ifTrue:
		[currentCharacter == $!
		    ifTrue:
			[self step == $!
			    ifTrue: [
				buffer nextPut: $!.
				self step]
			    ifFalse: [
				stream skip: -1.
				currentCharacter := $!.
				characterType := #binary]]
		    ifFalse:
	                [buffer nextPut: currentCharacter.
	                self step]].
	[characterType == #binary]
		whileTrue: [
		buffer nextPut: currentCharacter.
		self step].

        val := buffer contents.
        val := val asSymbol.
        ^aClass value: val start: tokenStart
    ]

    nextRawChunk [
	"Return a raw chunk, converting all double exclamation marks to single.
	 This is used for parsing Squeak class comments."

	<category: 'accessing'>
	buffer reset.
	[currentCharacter == $! and: [self step ~~ $!]] whileFalse: 
		[buffer nextPut: currentCharacter.
		self step].
	self stripSeparators.
	^RBLiteralToken value: buffer contents start: tokenStart
    ]
]

PK
     �Mh@Ӊ��        NewSyntaxExporter.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Class fileout support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
| Written by Daniele Sciascia.
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


FileOutExporter subclass: NewSyntaxExporter [
    <comment: 'This class is responsible for filing out 
               a given class on a given stream'>
    
    printFormattedSet: aSet [
        aSet isNil ifTrue: [ ^self ].
        aSet do: [ :element | outStream nextPutAll: element ]
            separatedBy: [ outStream space ]
    ]
    
    fileOutDeclaration: aBlock [
        (completeFileOut and: [ outClass environment ~= self defaultNamespace ])
	    ifFalse: [ ^self fileOutClassBody: aBlock ].
        
        outStream nextPutAll: 'Namespace current: ';
                  store: outClass environment;
                  nextPutAll: ' ['; nl; nl.
                  
	self fileOutClassBody: aBlock.
        outStream nextPut: $]; nl; nl.
    ]
      
    fileOutSelectors: selectors classSelectors: classSelectors [
        self fileOutDeclaration: [
            classSelectors do: [ :each | self fileOutSource: each class: true ].
            selectors do: [ :each | self fileOutSource: each class: false ].
        ]
    ]
    
    fileOutSource: selector class: isClass [
        | class |
        
        outStream nl; nextPutAll: '    '.
        class := isClass 
                    ifTrue: [ outStream nextPutAll: outClass name; nextPutAll: ' class >> '.
                              outClass asMetaclass ]
                    ifFalse: [ outClass ].
        outStream
	    nextPutAll: (class >> selector) methodRecompilationSourceString;
	    nl.
    ]

    fileOutCategory: category class: isClass [
        | methods theClass |

	theClass := isClass
	    ifTrue: [ outClass asMetaclass ]
	    ifFalse: [ outClass ].
        
        methods := theClass selectors select: 
                    [ :selector | (theClass compiledMethodAt: selector) 
                                    methodCategory = category ].
        
        methods asSortedCollection
	    do: [ :selector | self fileOutSource: selector class: isClass ]
    ]
    
    fileOutClassExtension: aBlock [
        outStream nextPutAll: (outClass asClass name).
        
        (outClass isMetaclass)
            ifTrue:  [ outStream nextPutAll: ' class extend ['; nl ]
            ifFalse: [ outStream nextPutAll: ' extend ['; nl ].
            
        aBlock value.
        
        outStream nl; nextPut: $]; nl; nl.
    ]

    fileOutClassDeclaration: aBlock [
        | aSet superclassName inheritedShape |
        
        outClass isMetaclass ifTrue: [ ^outClass ].
        
        superclassName := outClass superclass isNil
            ifTrue: [ 'nil' ]
            ifFalse: [ outClass superclass nameIn: outClass environment ].
        
        outStream
            nextPutAll: superclassName; space;
	        nextPutAll: 'subclass: ';
            nextPutAll: outClass name; space;
            nextPut: $[; nl; space: 4. 
        
        "instance variables"
        (outClass instVarNames isEmpty) ifFalse: [
            outStream nextPut: $|; space.
            self printFormattedSet: outClass instVarNames.
            outStream space; nextPut: $|; nl; space: 4
        ].
            
	"shape"
	inheritedShape := outClass superclass isNil
				ifTrue: [ nil ]
				ifFalse: [ outClass superclass shape ].
	outClass shape ~~
	    (outClass inheritShape ifTrue: [ inheritedShape ] ifFalse: [ nil ])
	    	ifTrue: [ outStream nl; space: 4;
	    	  		  nextPutAll: '<shape: ';
			          store: outClass shape;
			          nextPut: $> ].
				          
	"sharedPools"
        (aSet := outClass sharedPools) do: [ :element | 
            outStream nl; space: 4; nextPutAll: '<import: '.
            outStream nextPutAll: element.
            outStream nextPutAll: '>' ].

	    "category and comment"  	
	outStream nl.
	outClass classPragmas do: [ :selector |
            outStream space: 4;
		  nextPut: $<;
		  nextPutAll: selector;
		  nextPutAll: ': '.
	    (outClass perform: selector) storeLiteralOn: outStream.
	    outStream  nextPut: $>; nl ].
	    
        "class instance varriables"            
        outClass asMetaclass instVarNames isEmpty
            ifFalse: [ outStream nl; space: 4; nextPutAll: outClass name;
                       nextPutAll: ' class ['; nl; tab.
                       outStream nextPut: $|; space.
                       self printFormattedSet: outClass asMetaclass instVarNames.
                       outStream space; nextPut: $|; nl; tab.
                       outStream nl; space: 4; nextPut: $]; nl ].
         
        "class variables"
        ((aSet := outClass classVarNames) isEmpty)
            ifFalse: [
                outStream nl.
                aSet do: [ :var | outStream space: 4; nextPutAll: var; nextPutAll: ' := nil.'; nl ] ].

        aBlock value.
                       
        outStream nextPut: $]; nl; nl.
    ]

    fileOutMethods [            
        outClass asMetaclass collectCategories do:
            [ :category | self fileOutCategory: category class: true ].
                
        outClass asMetaclass selectors isEmpty ifFalse: [ outStream nl ].
        
        outClass collectCategories do: 
            [ :category | self fileOutCategory: category class: false ]
    ]
    
    fileOutInitialize [
        (outClass includesSelector: #initialize)
            ifTrue: [ outStream nl; 
                        nextPutAll: 'Eval [ ';
                        print: outClass; 
                        nextPutAll: ' initialize ]'; nl. ]
    ]
]

NewSyntaxExporter subclass: FormattingExporter [
    
    <comment: 'This class in addition to FileOutExporter, uses an RBFormatter
               to pretty print the body of every method.'>
               
    fileOutInitialize [ ]

    fileOutSource: selector class: isClass [
        | class source |
        outStream nl; nextPutAll: '    '.
        class := isClass 
                    ifTrue: [
			outStream
			    nextPutAll: outClass name;
			    nextPutAll: ' class >> '.
                        outClass asMetaclass ]
                    ifFalse: [ outClass ].
                    
	source := (class compiledMethodAt: selector) methodFormattedSourceString.
        outStream nextPutAll: source; nl.
    ]
]
PK
     �Mh@c��.h  h    PoolResolutionTests.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   PoolResolution tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) 2008 Free Software Foundation, Inc.
| Written by Stephen Compall.
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

Tests addSubspace: #MyLibrary; addSubspace: #MyProject.
MyProject addSubspace: #MyLibWrapper.

"actually for later, to demonstrate the need for the `direct
superclass only' namespace-walk-stop rule"

MyLibrary at: #PkgVersion put: 'MyLibrary 1.0'.
MyProject at: #PkgVersion put: 'MyProject 0.3141'.

Namespace current: STInST.Tests.MyLibrary [

Eval [
    MyLibrary at: #StandardOverrides put:
        (Dictionary from: {#Scape -> 42});
	at: #ValueAdaptor put: 9994
]

Object subclass: Foo [
    Exception := 42.
    Scape := 21.

    exception [^Exception]
    scape [^Scape]
]

Foo subclass: Bar [
    <import: StandardOverrides>
    scape [^Scape]
    valueAdaptor [^ValueAdaptor]
]

Bar subclass: Blah [
    scape [^Scape]
]

] "end namespace MyLibrary"

Namespace current: STInST.Tests.MyProject.MyLibWrapper [

Eval [
    "note this changes my superspace"
    MyProject at: #Exception put: #Exception.
    Namespace current import:
	(Dictionary from: {#Blah -> 6667. #Scoobs -> 785}).
]

MyLibrary.Foo subclass: Baz [
    scape [^Scape]
    exception [^Exception]
    valueAdaptor [^ValueAdaptor]
    blah [^Blah]
]

] "end namespace MyProject.MyLibWrapper"

Namespace current: STInST.Tests.MyLibrary [

"you ask, Who would do this? to which I say..."
MyProject.MyLibWrapper.Baz subclass: BackForMore [
    pkgVersion [^PkgVersion]
    blah [^Blah]
    scoobs [^Scoobs]
]

] "end namespace MyLibrary"


Namespace current: STInST.Tests [

TestCase subclass: TestDefaultPoolResolution [
    | foo bar baz blah backformore |

    assertVariable: symbol of: pools is: value description: str [
	| binding |
	binding := pools lookupBindingOf: symbol.
	self assert: binding notNil.
	self assert: value = binding value description: str.
    ]

    setUp [
	foo := DefaultPoolResolution of: MyLibrary.Foo.
	bar := DefaultPoolResolution of: MyLibrary.Bar.
	blah := DefaultPoolResolution of: MyLibrary.Blah.
	baz := DefaultPoolResolution of: MyProject.MyLibWrapper.Baz.
	backformore := DefaultPoolResolution of: MyLibrary.BackForMore.
    ]

    testClassPoolFirst [
	self assertVariable: #Exception of: foo is: 42
	     description: 'prefer class pool to namespace'
    ]

    testSharedPoolBeforeSuperClassPool [
	self assertVariable: #Scape of: bar is: 42
	     description: 'prefer here-shared pool to super-class pool'
    ]
    
    testInheritedPools [
	self assertVariable: #Scape of: blah is: 42
	     description: 'super-shared pool picked up'.
	self assertVariable: #Scape of: baz is: 21
	     description: 'super-class pool picked up'.
    ]

    testShortNamespaceWalk [
	self assertVariable: #Exception of: baz is: #Exception
	     description: 'namespace walked briefly before moving to superclass'.
	self assertVariable: #ValueAdaptor of: baz is: 9994
	     description: 'namespace walk stops at super-common space'.
	self assertVariable: #PkgVersion of: backformore is: 'MyLibrary 1.0'
	     description: 'namespace walk stops only at direct-super-common space'.
    ]

    testNamespacePools [
	self assertVariable: #Blah of: baz is: 6667
	     description: 'this-class ns pool var found'.
	self assertVariable: #Blah of: backformore is: MyLibrary.Blah
	     description: 'here-namespace searched first'.
	self assertVariable: #Scoobs of: backformore is: 785
	     description: 'superclass ns pools inherited'.
    ]
]

TestCase subclass: TestClassicPoolResolution [
    | foo bar baz blah backformore |

    assertVariable: symbol of: pools is: value description: str [
	| binding |
	binding := pools lookupBindingOf: symbol.
	self assert: binding notNil.
	self assert: value = binding value description: str.
    ]

    setUp [
	foo := ClassicPoolResolution of: MyLibrary.Foo.
	bar := ClassicPoolResolution of: MyLibrary.Bar.
	blah := ClassicPoolResolution of: MyLibrary.Blah.
	baz := ClassicPoolResolution of: MyProject.MyLibWrapper.Baz.
	backformore := ClassicPoolResolution of: MyLibrary.BackForMore.
    ]

    testNamespaceFirst [
	self assertVariable: #Exception of: foo is: Exception
	     description: 'prefer namespace to class pool'
    ]

    testClassPoolFirst [
	self assertVariable: #Scape of: bar is: 21
	     description: 'prefer class pool to shared pool'
    ]

    testInheritedPools [
	self assertVariable: #Scape of: blah is: 21
	     description: 'super-shared pool picked up'.
	self assertVariable: #Scape of: baz is: 21
	     description: 'super-class pool picked up'.
    ]

    testLongNamespaceWalk [
	self assertVariable: #Exception of: baz is: #Exception
	     description: 'namespace walked before moving to superclass'.
	self assertVariable: #ValueAdaptor of: baz is: ValueAdaptor
	     description: 'and again'.
	self assertVariable: #ValueAdaptor of: bar is: 9994
	     description: 'top class''s namespace goes first'.
	self assertVariable: #PkgVersion of: backformore is: 'MyLibrary 1.0'
	     description: 'not surprising, really'.
    ]
    
    testNamespacePools [
	self assertVariable: #Blah of: baz is: MyLibrary.Blah
	     description: 'ns pool vars not searched'.
	self assertVariable: #Blah of: backformore is: MyLibrary.Blah
	     description: 'mostly vacuous'.
	self assert: (backformore lookupBindingOf: #Scoobs) isNil
	    description: 'ns pools really not searched'.
    ]
]

]
PK
     �Mh@��	�~*  ~*    STFileParser.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Smalltalk in Smalltalk file-in driver
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2003,2006,2007,2008,2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


RBParser subclass: STFileParser [
    | driver |
    
    <comment: nil>
    <category: 'Refactory-Parser'>

    STFileParser class >> parseSmalltalk: aString with: aDriver [
	<category: 'accessing'>
	^self 
	    parseSmalltalk: aString
	    with: aDriver
	    onError: nil
    ]

    STFileParser class >> parseSmalltalk: aString with: aDriver onError: aBlock [
	<category: 'accessing'>
	| parser |
	parser := self new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString type: #on:errorBlock:.
	parser driver: aDriver.
	^parser parseSmalltalk
    ]

    STFileParser class >> parseSmalltalkStream: aStream with: aDriver [
	<category: 'accessing'>
	^self 
	    parseSmalltalkStream: aStream
	    with: aDriver
	    onError: nil
    ]

    STFileParser class >> parseSmalltalkStream: aStream with: aDriver onError: aBlock [
	<category: 'accessing'>
	| parser |
	parser := self new.
	parser errorBlock: aBlock.
	parser initializeParserWithStream: aStream type: #on:errorBlock:.
	parser driver: aDriver.
	^parser parseSmalltalk
    ]

    driver [
	<category: 'accessing'>
	^driver
    ]

    driver: aSTParsingDriver [
	<category: 'accessing'>
	driver := aSTParsingDriver.
	driver parser: self
    ]

    parseSmalltalk [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    compile: node [
	<category: 'overridable - parsing file-ins'>
	^driver compile: node
    ]

    endMethodList [
	<category: 'overridable - parsing file-ins'>
	driver endMethodList
    ]

    resolveClass: node [
	<category: 'overridable - parsing file-ins'>
	self evaluate: node.
	^self result
    ]

    evaluate: node [
	"This should be overridden because its result affects the parsing
	 process: true means 'start parsing methods', false means 'keep
	 evaluating'."

	<category: 'overridable - parsing file-ins'>
	^node notNil and: [node statements size > 0 and: [driver evaluate: node]]
    ]

    parseStatements [
	<category: 'utility'>
	(currentToken isSpecial and: [currentToken value == $!]) 
	    ifTrue: [^RBSequenceNode statements: #()].
	^self parseStatements: false
    ]

    parseDoit [
	<category: 'utility'>
	| node start stop comments |
	comments := scanner getComments.
	start := comments isNil 
		    ifTrue: [currentToken start - 1]
		    ifFalse: [comments first first - 1].
	tags := nil.
	node := self parseStatements.
        node addReturn.
	node comments isNil 
	    ifTrue: [node comments: comments]
	    ifFalse: [comments isNil ifFalse: [node comments: node comments , comments]].

	"One -1 accounts for base-1 vs. base-0 (as above), the
	 other drops the bang because we have a one-token lookahead."
	stop := currentToken start - 2.
	^self 
	    addSourceFrom: start
	    to: stop
	    to: node
    ]

    addSourceFrom: start to: stop to: node [
	<category: 'utility'>
	| method source |
	node isMethod 
	    ifTrue: [method := node]
	    ifFalse: 
		[method := RBMethodNode selectorParts: #() arguments: #().
		node parent: method].
	source := MappedSourceCode on: scanner from: start to: stop.
	method source: source.
	^node
    ]
]



Object subclass: STParsingDriver [
    | parser |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    parseSmalltalk: aString with: aParserClass [
	<category: 'starting the parsing'>
	^aParserClass parseSmalltalk: aString with: self
    ]

    parseSmalltalk: aString with: aParserClass onError: aBlock [
	<category: 'starting the parsing'>
	^aParserClass 
	    parseSmalltalk: aString
	    with: self
	    onError: aBlock
    ]

    parseSmalltalkStream: aStream with: aParserClass [
	<category: 'starting the parsing'>
	^aParserClass parseSmalltalkStream: aStream with: self
    ]

    parseSmalltalkStream: aStream with: aParserClass onError: aBlock [
	<category: 'starting the parsing'>
	^aParserClass 
	    parseSmalltalkStream: aStream
	    with: self
	    onError: aBlock
    ]

    parseSmalltalkFileIn: aFilename with: aParserClass [
	<category: 'starting the parsing'>
	^self 
	    parseSmalltalkFileIn: aFilename
	    with: aParserClass
	    onError: nil
    ]

    parseSmalltalkFileIn: aFilename with: aParserClass onError: aBlock [
	<category: 'starting the parsing'>
	| parser file |
	file := FileStream open: aFilename mode: FileStream read.
	
	[self 
	    parseSmalltalkStream: file
	    with: aParserClass
	    onError: aBlock] 
		ensure: [file close]
    ]

    errorBlock [
	<category: 'accessing'>
	^parser errorBlock
    ]

    parserWarning: aString [
	<category: 'accessing'>
	parser parserWarning: aString
    ]

    parserError: aString [
	<category: 'accessing'>
	parser parserError: aString
    ]

    parser [
	<category: 'accessing'>
	^parser
    ]

    parser: aSTFileParser [
	<category: 'accessing'>
	parser := aSTFileParser
    ]

    result [
	"return self by default"

	<category: 'overridable - parsing file-ins'>
	^self
    ]

    compile: node [
	"do nothing by default"

	<category: 'overridable - parsing file-ins'>
	^nil
    ]

    endMethodList [
	"do nothing by default"

	<category: 'overridable - parsing file-ins'>
	
    ]

    evaluate: node [
	"This should be overridden because its result affects the parsing
	 process: true means 'start parsing methods', false means 'keep
	 evaluating'. By default, always answer false."

	<category: 'overridable - parsing file-ins'>
	^false
    ]

    currentNamespace [
	<category: 'overridable - parsing file-ins'>
	^Namespace current
    ]
]



STFileParser subclass: STFileInParser [
    
    <comment: nil>
    <category: 'Refactory-Parser'>

    parseSmalltalk [
	<category: 'private-parsing'>
	[self parseDoits] whileTrue: [self parseMethodDefinitionList].
        self atEnd ifFalse: [self parserError: 'doit expected'].
	^driver result
    ]

    scannerClass [
	<category: 'private-parsing'>
	^STFileScanner
    ]

    parseDoits [
	"Parses the stuff to be executed until a
	 ! <class expression> methodsFor: <category string> !"

	<category: 'private-parsing'>
	| node |
	
	[self atEnd ifTrue: [^false].
	node := self parseDoit.
	scanner stripSeparators.
	self evaluate: node] 
		whileFalse: 
		    [(currentToken isSpecial and: [currentToken value == $!]) 
			ifTrue: [self step]].
	^true
    ]

    parseMethodFromFile [
	<category: 'private-parsing'>
	| node source start stop |
	start := currentToken start - 1.
	tags := nil.
	node := self parseMethod.
	node comments: (node comments select: [:each | each last >= start]).

	"One -1 accounts for base-1 vs. base-0 (as above), the
	 other drops the bang because we have a one-token lookahead."
	stop := currentToken start - 2.
	node := self 
		    addSourceFrom: start
		    to: stop
		    to: node.
	scanner stripSeparators.
	self step.	"gobble method terminating bang"
	^node
    ]

    parseMethodDefinitionList [
	"Called after first !, expecting a set of bang terminated
	 method definitions, followed by a bang"

	<category: 'private-parsing'>
	| method |

	self step.	"gobble doit terminating bang"
	[scanner atEnd or: [currentToken isSpecial and: [currentToken value == $!]]] 
	    whileFalse: [
		method := self compile: self parseMethodFromFile.
		method isNil ifFalse: [method noteOldSyntax]].
	scanner stripSeparators.
	self step.
	self endMethodList
    ]
]



RBScanner subclass: STFileScanner [
    
    <comment: nil>
    <category: 'Refactory-Parser'>

    next [
	<category: 'accessing'>
	| token |
	buffer reset.
	tokenStart := stream position.
	characterType == #eof ifTrue: [^RBToken start: tokenStart + 1].	"The EOF token should occur after the end of input"
	token := self scanToken.
	(token isSpecial and: [token value == $!]) ifFalse: [self stripSeparators].
	^token
    ]
]



PositionableStream extend [

    name [
	"Answer a string that represents what the receiver is streaming on"

	<category: 'compiling'>
	^'(%1 %2)' % 
		{self species article.
		self species name}
    ]


    segmentFrom: startPos to: endPos [
	"Answer an object that, when sent #asString, will yield the result
	 of sending `copyFrom: startPos to: endPos' to the receiver"

	<category: 'compiling'>
	^self copyFrom: startPos to: endPos
    ]

]


Stream extend [

    segmentFrom: startPos to: endPos [
	"Answer an object that, when sent #asString, will yield the result
	 of sending `copyFrom: startPos to: endPos' to the receiver"

	<category: 'compiling'>
	^nil
    ]

]

FileStream extend [

    segmentFrom: startPos to: endPos [
	"Answer an object that, when sent #asString, will yield the result
	 of sending `copyFrom: startPos to: endPos' to the receiver"

	<category: 'compiling'>
	self isPipe ifTrue: [^nil].
	^FileSegment 
	    on: self file
	    startingAt: startPos
	    for: endPos - startPos + 1
    ]

]

MappedCollection subclass: MappedSourceCode [
    <comment: 'This class is a hack.  It allows the positions in the tokens
and in the comments to be file-based, while at the same time only the source
code of the method is kept in memory.'>
    <category: 'Refactory-Parser'>

    | sourceCode |

    MappedSourceCode class >> on: aScanner from: start to: stop [
	<category: 'instance creation'>
	| collection coll sourceCode |
	collection := aScanner stream copyFrom: start to: stop.
	coll := self collection: collection map: (1 - start to: stop).
	sourceCode := (aScanner stream segmentFrom: start to: stop)
			ifNil: [collection].
	coll sourceCode: sourceCode.
	^coll
    ]

    asString [
	<category: 'conversion'>
	^self domain asString
    ]

    asSourceCode [
	<category: 'conversion'>
	^sourceCode
    ]

    sourceCode: anObject [
	<category: 'private - initialization'>
	sourceCode := anObject
    ]
]

Object extend [
    asSourceCode [
	<category: 'private-compilation'>
	^self
    ]
]

PK
     �Mh@�A���  �    Exporter.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Class fileout support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
| Written by Daniele Sciascia.
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


Object subclass: FileOutExporter [
    | outClass outStream completeFileOut defaultNamespace |
    
    <comment: 'This class is responsible for filing out 
               a given class on a given stream'>
    
    DefaultExporter := nil.

    FileOutExporter class >> defaultExporter [
        ^DefaultExporter ifNil: [ NewSyntaxExporter ]
    ]

    FileOutExporter class >> defaultExporter: aClass [
        DefaultExporter := aClass
    ]

    FileOutExporter class >> on: aClass to: aStream [    
        ^super new initializeWith: aClass and: aStream.
    ]

    FileOutExporter class >> fileOut: aClass to: aStream [    
        (self on: aClass to: aStream) fileOut
    ]

    FileOutExporter class >> fileOut: aClass toFile: aString [    
        | aStream |
        aStream := FileStream open: aString mode: FileStream write.
        [ (self on: aClass to: aStream) fileOut ]
            ensure: [ aStream close ]
    ]
    
    FileOutExporter class >> fileOutCategory: aString of: aClass to: aStream [
	| methods exporter |
        methods := aClass selectors select: [ :selector |
            (aClass compiledMethodAt: selector) methodCategory = aString ].
        exporter := self on: aClass asClass to: aStream.
        exporter completeFileOut: false.
	aClass isClass
	    ifTrue: [ exporter fileOutSelectors: methods classSelectors: #() ]
	    ifFalse: [ exporter fileOutSelectors: #() classSelectors: methods ]
    ]
    
    FileOutExporter class >> fileOutSelector: aSymbol of: aClass to: aStream [
	| exporter |
        exporter := self on: aClass asClass to: aStream.
        exporter completeFileOut: false.
	aClass isClass
	    ifTrue: [ exporter fileOutSelectors: {aSymbol} classSelectors: #() ]
	    ifFalse: [ exporter fileOutSelectors: #() classSelectors: {aSymbol} ]
    ]
    
    initializeWith: aClass and: aStream [
        outClass := aClass.
        outStream := aStream.
	completeFileOut := true.
    ]

    completeFileOut [
        ^completeFileOut
    ]

    completeFileOut: aBoolean [
        completeFileOut := aBoolean.
    ]

    defaultNamespace [
	defaultNamespace isNil 
	    ifTrue: [ defaultNamespace := Namespace current ].
        ^defaultNamespace
    ]

    defaultNamespace: aNamespace [
        defaultNamespace := aNamespace.
    ]

    fileOut [                   
        self fileOutDeclaration: [ self fileOutMethods ].
        completeFileOut
	        ifFalse: [ self fileOutInitialize ]
    ]
      
    fileOutSelectors: selectors classSelectors: classSelectors [
	self subclassResponsibility
    ]

    fileOutDeclaration: aBlock [
	self subclassResponsibility
    ]
    
    fileOutClassBody: aBlock [
	completeFileOut
	    ifTrue: [ self fileOutClassDeclaration: aBlock ]
	    ifFalse: [ self fileOutClassExtension: aBlock ].
    ]
    
    fileOutClassExtension: aBlock [
	self subclassResponsibility
    ]

    fileOutClassDeclaration: aBlock [
	self subclassResponsibility
    ]

    fileOutMethods [            
	self subclassResponsibility
    ]
    
    fileOutInitialize [
        (outClass includesSelector: #initialize)
            ifTrue: [ outStream nl; 
                        nextPutAll: 'Eval [ ';
                        print: outClass; 
                        nextPutAll: ' initialize ]'; nl. ]
    ]
]

PK
     �Mh@ /8 #   #    RewriteTests.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   ParseTreeRewriter tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) 2007 Free Software Foundation, Inc.
| Written by Stephen Compall.
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



Namespace current: STInST.Tests [

TestCase subclass: TestStandardRewrites [
    
    <comment: 'I test the ParseTreeRewriter with string rewrites provided directly
by PTR''s methods.

This is a series of unit tests written with SUnit to check the
functionality of STInST.ParseTreeRewriter and its
helper classes.  It was written based on the original functionality,
so that one could perform a radical rewrite and ensure that its
behavior stayed the same, at least as much as I care it to stay so.'>
    <category: 'Refactory-Tests'>

    testExpressions [
	"Basic testing of proper descent"

	<category: 'testing'>
	self 
	    rewrite: '(self foo: (one isNil ifTrue: [self uhOh. two]
					 ifFalse: [one]))
		       isNil ifTrue: [three isNil ifFalse: [three]
						  ifTrue: [four]]
			     ifFalse: [self foo: (one isNil ifTrue: [self uhOh. two] ifFalse: [one])]'
	    from: '``@receiver isNil ifTrue: [|`@otherVars| ``@.other]
				  ifFalse: [``@receiver]'
	    to: '``@receiver ifNil: [|`@otherVars| ``@.other]'
	    shouldBe: '(self foo: (one ifNil: [self uhOh. two]))
			ifNil: [three isNil ifFalse: [three]
					    ifTrue: [four]]'.
	"descent and simple replacement behavior with cascades"
	self 
	    rewrite: '| temp |
		   temp := self one at: two put: three.
		   (self qqq at: temp put: dict)
		       at: four put: (five at: half put: quarter);
		       at: (six at: q put: r) put: 7;
		       w: (1 at: 2 put: 3).
		   ^42'
	    from: '`@receiver at: ``@key put: `@value'
	    to: '`@receiver set: ``@key to: `@value'
	    shouldBe: '| temp |
		    temp := self one set: two to: three.
		    (self qqq at: temp put: dict)
			set: four to: (five at: half put: quarter);
			set: (six set: q to: r) to: 7;
			w: (1 set: 2 to: 3).
		    ^42'
	"``@receiver it was, until I found that a cascade corner
	 described below causes the w: send below to have the wrong
	 receiver.  After all, it just doesn't make sense to descend
	 to the receiver for some cascade messages but not others!"
    ]

    testCascadeCornerCases [
	"Issue non-messages-are-found: If replacement isn't a cascade or
	 message, it drops.  Oddly, PTR didn't count this as a 'not
	 found'; it doesn't descend into arguments of the original node in
	 this case, and, as a result, it won't descend to the receiver.  This
	 behavior was changed, the original implementation needed this
	 shouldBe: content:
	 
	 obj.
	 (stream display: z) display: (stream display: x);
	 display: y; nextPut: $q"

	<category: 'testing'>
	self 
	    rewrite: 'stream display: obj.
		   (stream display: z) display: (stream display: x);
		       display: y; nextPut: $q'
	    from: '``@receiver display: ``@object'
	    to: '``@object'
	    shouldBe: 'obj.
		    z display: x;
			display: y; nextPut: $q'.

	"Cascades within cascades are flattened."
	self 
	    rewrite: 'stream nextPut: $r; display: (what display: qqq); tab'
	    from: '``@recv display: ``@obj'
	    to: '``@recv display: ``@obj; nl'
	    shouldBe: 'stream nextPut: $r;
			display: (what display: qqq; nl);
			nl; tab'.

	"Issue rsic-doesnt-copy: lookForMoreMatchesInContext: doesn't copy
	 its values.  As a result, replacement in successful replacements
	 later rejected by acceptCascadeNode: (after
	 lookForMoreMatchesInContext: is already sent, after all) depends
	 on where in the subtree a match happened.  This is why selective
	 recursion into successful matches before giving outer contexts
	 the opportunity to reject them isn't so great.  It can be 'fixed'
	 by #copy-ing each value in the context before descending into it.
	 I would prefer removing that 'feature' altogether, and my own
	 'trampoline' rewriter does just this.
	 
	 This replacement test depends on the non-message rejection oddity
	 described above, though fixing that won't entirely fix this
	 issue.  If that issue is not, this test will need this shouldBe:
	 qqq display: (qqq display: sss);
	 display: [[sss]]'"
	self 
	    rewrite: 'qqq display: (qqq display: sss);
		       display: [qqq display: sss]'
	    from: '``@recv display: ``@obj'
	    to: '[``@obj]'
	    shouldBe: 'qqq display: [sss];
			display: [[sss]]'.
	
	[| rsicCopiesPRewriter sourceExp |
	rsicCopiesPRewriter := (self rewriterClass new)
		    replace: '``@recv display: ``@obj' with: '[``@obj]';
		    replace: '`@recv value' with: '`@recv';
		    yourself.
	sourceExp := RBParser 
		    parseExpression: 'qqq display: (qqq display: sss value value);
	      display: [qqq display: sss value value]'.
	self deny: (self 
		    rewriting: sourceExp
		    with: rsicCopiesPRewriter
		    yields: 'qqq display: (qqq display: sss value value);
			      display: [[sss value]]')
	    description: 'neither non-messages-are-found nor rsic-doesnt-copy fixed'.
	self deny: (self 
		    rewriting: sourceExp
		    with: rsicCopiesPRewriter
		    yields: 'qqq display: [sss value];
			    display: [[sss]]')
	    description: 'non-messages-are-found fixed, but not rsic-doesnt-copy'.
	self assert: (self 
		    rewriting: sourceExp
		    with: rsicCopiesPRewriter
		    yields: 'qqq display: [sss value];
			    display: [[sss value]]')
	    description: 'both non-messages-are-found and rsic-doesnt-copy fixed'] 
		value.

	"Unmatched messages in a cascade get their arguments rewritten,
	 but not the receiver, provided that some other message in the
	 cascade was rewritten.  This can lead to unreal trees if that
	 message had a recurseInto receiver."
	self 
	    assert: ((RBCascadeNode 
		    messages: (RBParser parseExpression: '(1 b) b. (1 a) c') statements) 
			match: (self rewriterClass 
				replace: '``@recv a'
				with: '``@recv b'
				in: (RBParser parseExpression: '(1 a) a; c'))
			inContext: RBSmallDictionary new)
	    description: 'Don''t rewrite cascade receivers unless no submessages matched'
    ]

    testMultiRewrite [
	<category: 'testing'>
	| rewriter origTree match1 match2 |
	match1 := RBParser parseExpression: 'x value'.
	match2 := RBParser parseExpression: 'x'.
	origTree := RBParser parseExpression: 'x value value'.
	#(#('`' '') #('' '`')) do: 
		[:prefixes | 
		| prefix1 prefix2 rewriter |
		prefix1 := prefixes at: 1.
		prefix2 := prefixes at: 2.
		rewriter := ParseTreeRewriter new.
		rewriter
		    replace: prefix1 , '`@x value' with: prefix1 , '`@x';
		    replace: prefix2 , '`@x value' with: prefix2 , '`@x'.
		rewriter executeTree: origTree copy.
		self assert: (
			{match1.
			match2} 
				contains: [:matchTree | matchTree match: rewriter tree inContext: RBSmallDictionary new])
		    description: 'Rewrite one or the other']
    ]

    rewriterClass [
	<category: 'rewriting'>
	^ParseTreeRewriter
    ]

    rewriting: codeTree with: rewriter yields: newCodeString [
	"Answer whether rewriting codeTree (untouched) with rewriter
	 yields newCodeString."

	<category: 'rewriting'>
	^(RBParser parseExpression: newCodeString) match: (rewriter
		    executeTree: codeTree copy;
		    tree)
	    inContext: RBSmallDictionary new
    ]

    rewrite: codeString from: pattern to: replacement shouldBe: newCodeString [
	"Assert that replacing pattern with replacement in codeString
	 yields newCodeString."

	<category: 'rewriting'>
	^self assert: ((RBParser parseRewriteExpression: newCodeString) 
		    match: (self rewriterClass 
			    replace: pattern
			    with: replacement
			    in: (RBParser parseExpression: codeString))
		    inContext: Dictionary new)
	    description: ((WriteStream on: (String new: 50))
		    display: codeString;
		    nl;
		    nextPutAll: '    ==| (';
		    print: pattern;
		    nextPutAll: ' => ';
		    print: replacement;
		    nextPut: $);
		    nl;
		    nextPutAll: '    ==> ';
		    display: newCodeString;
		    contents)
    ]
]

]

PK
     �Mh@C�s"�  �    SqueakExporter.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Squeak format class fileout support
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


OldSyntaxExporter subclass: SqueakSyntaxExporter [
    <comment: 'This class is responsible for filing out 
               a given class on a given stream in Squeak format'>

    
    fileOutDeclaration: aBlock [
        (completeFileOut and: [ outClass environment ~= self defaultNamespace ])
	    ifTrue: [ Warning signal: 'Squeak format does not support namespaces' ].

	self fileOutClassBody: aBlock.
    ]

    fileOutChunk: aString [
        outStream
            nl;
            nextPutAll: (aString copyReplaceAll: '!' with: '!!');
            nextPut: $!
    ]

    fileOutComment [
	outStream
            nextPut: $!;
            print: outClass;
            nextPutAll: ' commentStamp: ''<historical>'' prior: 0!'.

	self fileOutChunk: (outClass comment ifNil: [ '' ]).
	outStream nl; nl.
    ] 

    fileOutClassDeclaration: aBlock [
	outStream
	    nextPutAll: 'SystemOrganization addCategory: #';
	    print: outClass category;
	    nextPut: $!;
	    nl.

	super fileOutClassDeclaration: aBlock
    ]
]
PK
     �[h@�A�.�  �    package.xmlUT	 I�XOI�XOux �  �  <package>
  <name>Parser</name>
  <namespace>STInST</namespace>
  <test>
    <namespace>STInST.Tests</namespace>
    <prereq>Parser</prereq>
    <prereq>SUnit</prereq>
    <sunit>STInST.Tests.TestStandardRewrites</sunit>
    <sunit>STInST.Tests.TestDefaultPoolResolution</sunit>
    <sunit>STInST.Tests.TestClassicPoolResolution</sunit>
  
    <filein>RewriteTests.st</filein>
    <filein>PoolResolutionTests.st</filein>
  </test>

  <filein>RBToken.st</filein>
  <filein>RBParseNodes.st</filein>
  <filein>RBParser.st</filein>
  <filein>ParseTreeSearcher.st</filein>
  <filein>RBFormatter.st</filein>
  <filein>OrderedSet.st</filein>
  <filein>STFileParser.st</filein>
  <filein>STCompLit.st</filein>
  <filein>STSymTable.st</filein>
  <filein>STCompiler.st</filein>
  <filein>STDecompiler.st</filein>
  <filein>STLoaderObjs.st</filein>
  <filein>STLoader.st</filein>
  <filein>SqueakParser.st</filein>
  <filein>SIFParser.st</filein>
  <filein>GSTParser.st</filein>
  <filein>STEvaluationDriver.st</filein>
  <filein>Exporter.st</filein>
  <filein>NewSyntaxExporter.st</filein>
  <filein>OldSyntaxExporter.st</filein>
  <filein>SqueakExporter.st</filein>
  <filein>Extensions.st</filein>
  <file>ChangeLog</file>
</package>PK
     �Mh@ٝ�[�  �    STCompLit.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Smalltalk in Smalltalk compiler constant definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Eval [
    Smalltalk at: #VMByteCodeNames
	put: ((Dictionary new: 75)
		at: #Send put: 28;
		at: #SendSuper put: 29;
		at: #SendImmediate put: 30;
		at: #SendImmediateSuper put: 31;
		at: #PushTemporaryVariable put: 32;
		at: #PushOuterVariable put: 33;
		at: #PushLitVariable put: 34;
		at: #PushReceiverVariable put: 35;
		at: #StoreTemporaryVariable put: 36;
		at: #StoreOuterVariable put: 37;
		at: #StoreLitVariable put: 38;
		at: #StoreReceiverVariable put: 39;
		at: #JumpBack put: 40;
		at: #Jump put: 41;
		at: #PopJumpTrue put: 42;
		at: #PopJumpFalse put: 43;
		at: #PushInteger put: 44;
		at: #PushSpecial put: 45;
		at: #PushLitConstant put: 46;
		at: #PopStoreIntoArray put: 47;
		at: #PopStackTop put: 48;
		at: #MakeDirtyBlock put: 49;
		at: #ReturnMethodStackTop put: 50;
		at: #ReturnContextStackTop put: 51;
		at: #DupStackTop put: 52;
		at: #LineNumber put: 54;
		at: #ExtByte put: 55;
		at: #PushSelf put: 56;
		yourself).
    Smalltalk at: #VMOtherConstants
	put: ((Dictionary new: 16)
		at: #NilIndex put: 0;
		at: #TrueIndex put: 1;
		at: #FalseIndex put: 2;
		at: #LastImmediateSend put: 24;
		at: #NewColonSpecial put: 32;
		at: #ThisContextSpecial put: 33;
		yourself).
    selectorsMap := IdentityDictionary new: 512.
    CompiledCode specialSelectors keysAndValuesDo: 
	    [:index :selector | 
	    selector isNil ifFalse: [selectorsMap at: selector put: index - 1]].
    VMOtherConstants at: #VMSpecialSelectors put: selectorsMap.
    VMOtherConstants at: #VMSpecialIdentifiers
	put: ((LookupTable new: 8)
		at: 'super' put: [:c | c compileError: 'invalid occurrence of super'];
		at: 'self' put: [:c | c compileByte: VMByteCodeNames.PushSelf];
		at: 'nil'
		    put: 
			[:c | 
			c compileByte: VMByteCodeNames.PushSpecial arg: VMOtherConstants.NilIndex];
		at: 'true'
		    put: 
			[:c | 
			c compileByte: VMByteCodeNames.PushSpecial arg: VMOtherConstants.TrueIndex];
		at: 'false'
		    put: 
			[:c | 
			c compileByte: VMByteCodeNames.PushSpecial arg: VMOtherConstants.FalseIndex];
		at: 'thisContext'
		    put: 
			[:c | 
			c
			    pushLiteralVariable: #{ContextPart};
			    compileByte: VMByteCodeNames.SendImmediate
				arg: VMOtherConstants.ThisContextSpecial];
		yourself).
    VMOtherConstants at: #VMSpecialMethods
	put: ((IdentityDictionary new: 32)
		at: #whileTrue put: #compileWhileLoop:;
		at: #whileFalse put: #compileWhileLoop:;
		at: #whileTrue: put: #compileWhileLoop:;
		at: #whileFalse: put: #compileWhileLoop:;
		at: #repeat put: #compileRepeat:;
		at: #timesRepeat: put: #compileTimesRepeat:;
		at: #to:do: put: #compileLoop:;
		at: #to:by:do: put: #compileLoop:;
		at: #ifTrue: put: #compileBoolean:;
		at: #ifTrue:ifFalse: put: #compileBoolean:;
		at: #ifFalse: put: #compileBoolean:;
		at: #ifFalse:ifTrue: put: #compileBoolean:;
		at: #and: put: #compileBoolean:;
		at: #or: put: #compileBoolean:;
		yourself)
]

PK
     �Mh@�!^�  �    OldSyntaxExporter.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Class fileout support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
| Written by Daniele Sciascia.
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


FileOutExporter subclass: OldSyntaxExporter [
    <comment: 'This class is responsible for filing out 
               a given class on a given stream'>
    
    printFormattedSet: aSet [
        outStream nextPut: $'.
        aSet isNil ifTrue: [ ^self ].
        aSet do: [ :element | outStream nextPutAll: element ]
            separatedBy: [ outStream space ].
        outStream nextPut: $'.
    ]
    
    fileOutDeclaration: aBlock [
        (completeFileOut and: [ outClass environment ~= self defaultNamespace ])
	    ifFalse: [ ^self fileOutClassBody: aBlock ].
        
        outStream nextPutAll: 'Namespace current: ';
                  store: outClass environment;
		  nextPut: $!; nl; nl.
                  
	self fileOutClassBody: aBlock.
        outStream nextPutAll: 'Namespace current: Smalltalk!'; nl; nl.
    ]
    
    fileOutClassExtension: aBlock [
        aBlock value.
        outStream nl.
    ]

    fileOutComment [
	outStream
            print: outClass;
            nextPutAll: ' comment: ';
            nl;
            print: outClass comment;
            nextPut: $!;
            nl; nl.
    ] 

    fileOutSelectors: selectors classSelectors: classSelectors [
        self fileOutDeclaration: [
            self fileOutSource: classSelectors class: outClass asMetaclass.
            self fileOutSource: selectors class: outClass.
        ]
    ]

    fileOutClassDeclaration: aBlock [
        | superclassName |
    
        superclassName := outClass superclass isNil
            ifTrue: [ 'nil' ]
            ifFalse: [ outClass superclass nameIn: outClass environment ].
    
        outStream
            nextPutAll: superclassName; space;
            nextPutAll: outClass kindOfSubclass; space;
            store: outClass name asSymbol.
    
        outStream nl; tab; nextPutAll: 'instanceVariableNames: '.
        self printFormattedSet: outClass instVarNames.

        outStream nl; tab; nextPutAll: 'classVariableNames: '.
        self printFormattedSet: outClass classVarNames.

        outStream nl; tab; nextPutAll: 'poolDictionaries: '.
        self printFormattedSet: outClass sharedPools.

        outStream nl; tab; nextPutAll: 'category: ';
            print: outClass category;
            nextPut: $!;
            nl; nl.

	self fileOutComment.

        outClass asMetaclass instVarNames isEmpty ifFalse: [
            outStream print: outClass asMetaclass; nextPutAll: ' instanceVariableNames: '.
            self printFormattedSet: outClass asMetaclass instVarNames.
	    outStream nextPut: $!; nl; nl].
	aBlock value.
        outStream nl.
    ]

    fileOutMethods [            
        outClass asMetaclass collectCategories do:
            [ :category | self fileOutCategory: category class: true ].
        
        outClass collectCategories do: 
            [ :category | self fileOutCategory: category class: false ]
    ]

    fileOutCategory: category class: aBoolean [
        | methods class |

        class := aBoolean ifTrue: [ outClass asMetaclass ] ifFalse: [ outClass ].
        methods := class selectors select: [ :selector |
            (class compiledMethodAt: selector) methodCategory = category ].

	self fileOutSource: methods class: class.
    ]

    fileOutSource: selectors class: aClass [
	| categories catSB methodSB |
	catSB := [ :a :b | (a key ifNil: ['~~']) < (b key ifNil: ['~~']) ].
	methodSB := [ :a :b | a selector < b selector ].

	categories := Dictionary new.
	selectors do: [ :each || method |
	    method := aClass >> each.
	    (categories
		at: method methodCategory
		ifAbsentPut: [SortedCollection sortBlock: methodSB]) add: method].

	(categories associations asSortedCollection: catSB) do: [ :each |
	    self fileOutCategory: each key methods: each value class: aClass ]
    ]

    fileOutCategory: aString methods: methods class: aClass [
        methods isEmpty ifTrue: [ ^self ].
        outStream
	     nextPut: $!; print: aClass;
             nextPutAll: ' methodsFor: ';
             print: aString;
             nextPut: $!.

        methods do: [ :method |
	    outStream nl.
	    self fileOutChunk: (self oldSyntaxSourceCodeFor: method) ].

        outStream nextPutAll: ' !'; nl; nl
    ]

    fileOutChunk: aString [
        outStream
            nl;
            nextPutAll: aString;
            nextPut: $!
    ]

    oldSyntaxSourceCodeFor: aMethod [
	| source cat |
	aMethod isOldSyntax ifTrue: [ ^aMethod methodSourceString ].
	source := aMethod methodSourceString.
	source := source copyReplacingRegex: '\s*\[\s*(.*[\S\n])' with: '
	%1'.
	source := source copyReplacingRegex: '\s*]\s*$' with: '
'.
	cat := aMethod methodCategory printString escapeRegex.
        ^source
	    copyReplacingAllRegex: ('(?m:^)\s*<category: ', cat, '>\s*
')
	    with: ''.
    ]

    fileOutInitialize [
        (outClass includesSelector: #initialize)
            ifTrue: [ outStream nl; 
                        print: outClass; 
                        nextPutAll: ' initialize!'; nl. ]
    ]
]

PK
     �Mh@,�B2:A  :A    STSymTable.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Smalltalk in Smalltalk compiler symbol table
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1995,1999,2000,2001,2002,2006,2007,2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Collection extend [
    literalHash [
        <category: 'compiler'>
        ^self identityHash
    ]

    literalEquals: anObject [
        <category: 'compiler'>
        ^self == anObject
    ]
]

VariableBinding extend [
    literalHash [
        <category: 'compiler'>
        ^self identityHash
    ]

    literalEquals: anObject [
        <category: 'compiler'>
        ^self == anObject
    ]
]

ArrayedCollection extend [
    literalHash [
        <category: 'compiler'>
        ^self size bitXor: self class hash
    ]

    literalEquals: anObject [
        <category: 'compiler'>
        self == anObject ifTrue: [^true].
        self size = anObject size ifFalse: [^false].
        self class = anObject class ifFalse: [^false].
        1 to: self size do: [ :i |
            ((self at: i) literalEquals: (anObject at: i))
                ifFalse: [^false] ].
        ^true
    ]
]

Float extend [
    literalHash [
        <category: 'compiler'>
        ^self primHash
    ]

    literalEquals: anObject [
        <category: 'compiler'>
        self size = anObject size ifFalse: [^false].
        self class = anObject class ifFalse: [^false].
        1 to: self size do: [ :i |
            ((self at: i) literalEquals: (anObject at: i))
                ifFalse: [^false] ].
        ^true
    ]
]

Object extend [
    literalHash [
        <category: 'compiler'>
        ^self hash
    ]

    literalEquals: anObject [
        <category: 'compiler'>
        ^self = anObject
    ]
]


LookupTable subclass: LiteralDictionary [
    
    <shape: #pointer>
    <category: 'Collections-Keyed'>
    <comment: 'I am similar to LookupTable, except that I use the 
comparison message #literalEquals: to determine equivalence of objects.'>

    keysClass [
	"Answer the class answered by #keys"

	<category: 'private methods'>
	^IdentitySet
    ]

    hashFor: anObject [
	"Return an hash value for the item, anObject"

	<category: 'private methods'>
	^anObject literalHash
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private methods'>
	| index size element |
	"Sorry for the lack of readability, but I want speed... :-)"
	index := (anObject literalHash scramble 
		    bitAnd: (size := self primSize) - 1) + 1.
	
	[((element := self primAt: index) isNil or: [element literalEquals: anObject])
	    ifTrue: [^index].
	index == size ifTrue: [index := 1] ifFalse: [index := index + 1]] 
		repeat
    ]
]


Object subclass: STLiteralsTable [
    | map array |
    
    <category: 'System-Compiler'>
    <comment: nil>

    STLiteralsTable class >> new: aSize [
	<category: 'instance creation'>
	^self new initialize: aSize
    ]

    addLiteral: anObject [
	"Answers the index of the given literal.  If the literal is already
	 present in the literals, returns the index of that one."

	<category: 'accessing'>
	^map at: anObject
	    ifAbsentPut: 
		["Grow the array when full"

		| newArray |
		array size = map size 
		    ifTrue: 
			[(newArray := Array new: map size * 2) 
			    replaceFrom: 1
			    to: map size
			    with: array
			    startingAt: 1.
			array become: newArray].
		array at: map size + 1 put: anObject.
		map size]
    ]

    literals [
	<category: 'accessing'>
	^array
    ]

    trim [
	<category: 'accessing'>
	array become: (array copyFrom: 1 to: map size)
    ]

    initialize: aSize [
	<category: 'private'>
	map := LiteralDictionary new: aSize.
	array := Array new: aSize
    ]
]



Object subclass: STVariable [
    | id scope canStore |
    
    <category: 'System-Compiler'>
    <comment: nil>

    STVariable class >> id: id scope: scope canStore: canStore [
	<category: 'instance creation'>
	^self new 
	    id: id
	    scope: scope
	    canStore: canStore
    ]

    canStore [
	<category: 'accessing'>
	^canStore
    ]

    id [
	<category: 'accessing'>
	^id
    ]

    id: anObject scope: scopeIndex canStore: aBoolean [
	<category: 'accessing'>
	id := anObject.
	scope := scopeIndex.
	canStore := aBoolean
    ]

    scope [
	<category: 'accessing'>
	^scope
    ]
]



Object subclass: STSymbolTable [
    | variables tempCount litTable pools instVars environment scopes scopeVariables |
    
    <category: 'System-Compiler'>
    <comment: nil>

    UseUndeclared := nil.

    STSymbolTable class >> initialize [
	<category: 'accessing'>
	UseUndeclared := 0
    ]

    STSymbolTable class >> insideFilein [
	<category: 'accessing'>
	^UseUndeclared > 0
    ]

    STSymbolTable class >> nowInsideFileIn [
	<category: 'accessing'>
	UseUndeclared := UseUndeclared + 1
    ]

    STSymbolTable class >> nowOutsideFileIn [
	<category: 'accessing'>
	UseUndeclared := UseUndeclared - 1
    ]

    STSymbolTable class >> new [
	<category: 'instance creation'>
	^super new init
    ]

    addPool: poolDictionary [
	<category: 'declaring'>
	pools addPoolLast: poolDictionary
    ]

    declareEnvironment: aBehavior [
	<category: 'declaring'>
	| i canAlwaysStore inSandbox |
	environment := aBehavior.
	inSandbox := thisContext isUntrusted.
	i := -1.
	canAlwaysStore := aBehavior isUntrusted.
	aBehavior withAllSuperclasses reverseDo: 
		[:class | 
		canAlwaysStore := canAlwaysStore and: [class isUntrusted].
		class instVarNames do: 
			[:iv | 
			instVars at: iv asSymbol
			    put: (STVariable 
				    id: (i := i + 1)
				    scope: 0
				    canStore: (canAlwaysStore or: [inSandbox not]))]].
	self declareGlobals
    ]

    declareGlobals [
	<category: 'declaring'>
	pools := environment poolResolution of: environment.
    ]

    declareTemporary: tempName canStore: canStore for: stCompiler [
	<category: 'declaring'>
	| symbol |
	symbol := tempName asSymbol.
	(variables includesKey: symbol) 
	    ifTrue: 
		[(variables at: symbol) scope < scopes size 
		    ifTrue: 
			[stCompiler compileWarning: 'variable ''%1'' shadows another' % {tempName}]
		    ifFalse: [^stCompiler compileError: 'duplicate variable name ' , tempName]].
	variables at: symbol
	    put: (STVariable 
		    id: tempCount
		    scope: scopes size
		    canStore: canStore).
	tempCount := tempCount + 1.
	^tempCount - 1
    ]

    scopeEnter [
	<category: 'declaring'>
	scopes add: tempCount.
	tempCount := 0.
	scopeVariables add: variables.
	variables := variables copy
    ]

    scopeLeave [
	"Answer whether we are in a `clean' scope (no return from method, no
	 references to variable in an outer scope)."

	<category: 'declaring'>
	tempCount := scopes removeLast.
	variables := scopeVariables removeLast
    ]

    undeclareTemporary: tempName [
	<category: 'declaring'>
	variables removeKey: tempName asSymbol ifAbsent: []
    ]

    addLiteral: aLiteral [
	"Answers the index of the given literal.  If the literal is already
	 present in the litTable, returns the index of that one."

	<category: 'declaring'>
	^litTable addLiteral: aLiteral
    ]

    canStore: aName [
	<category: 'accessing'>
	| var |
	var := variables at: aName asSymbol ifAbsent: [nil].
	var isNil ifFalse: [^var canStore].
	var := instVars at: aName asSymbol ifAbsent: [nil].
	var isNil ifFalse: [^var canStore].
	^true
    ]

    environment [
	<category: 'accessing'>
	^environment
    ]

    numTemps [
	<category: 'accessing'>
	^tempCount
    ]

    isTemporary: aName [
	<category: 'accessing'>
	^variables includesKey: aName asSymbol
    ]

    isReceiver: aName [
	<category: 'accessing'>
	^instVars includesKey: aName asSymbol
    ]

    outerScopes: aName [
	<category: 'accessing'>
	| value |
	value := variables at: aName asSymbol.
	^scopes size - value scope
    ]

    invalidScopeResolution: stCompiler [
	<category: 'accessing'>
	^stCompiler compileError: 'invalid scope resolution'
    ]

    bindingOf: namesArray for: stCompiler [
	<category: 'accessing'>
	| assoc |
	assoc := self lookupPoolsFor: (namesArray at: 1) asSymbol.
	assoc isNil ifTrue: [^nil].

	"Ok, proceed with the remaining names (if any)."
	namesArray 
	    from: 2
	    to: namesArray size
	    keysAndValuesDo: 
		[:i :each | 
		assoc := assoc value scopeDictionary associationAt: each asSymbol
			    ifAbsent: 
				[| symbol |
				i < namesArray size ifTrue: [self invalidScopeResolution: stCompiler].

				"Last item, add to Undeclared"
				^self lookupUndeclared: each asSymbol]].
	^assoc
    ]

    lookupPoolsFor: symbol [
	<category: 'accessing'>
	^pools lookupBindingOf: symbol
    ]

    lookupBindingOf: symbol [
	<category: 'accessing'>
	| assoc |
	assoc := self lookupPoolsFor: symbol.
	assoc isNil ifTrue: [^self lookupUndeclared: symbol].
	^assoc
    ]

    lookupName: aName for: stCompiler [
	"Answers a value for the name"

	<category: 'accessing'>
	| symbol value assoc index |
	index := aName indexOf: $..
	symbol := index = 0 
		    ifTrue: [aName asSymbol]
		    ifFalse: [(aName copyFrom: 1 to: index - 1) asSymbol].
	index = 0 
	    ifTrue: 
		[value := variables at: symbol ifAbsent: [nil].
		value isNil ifFalse: [^value id].
		value := instVars at: symbol ifAbsent: [nil].
		value isNil ifFalse: [^value id]].
	assoc := index = 0 
		    ifTrue: [self lookupBindingOf: symbol]
		    ifFalse: [self bindingOf: (aName substrings: $.) for: stCompiler].
	assoc isNil ifFalse: [^self addLiteral: assoc].
	^assoc
    ]

    finish [
	<category: 'accessing'>
	litTable trim
    ]

    literals [
	<category: 'accessing'>
	^litTable literals
    ]

    init [
	<category: 'private'>
	variables := Dictionary new: 5.
	litTable := STLiteralsTable new: 13.
	instVars := Dictionary new: 7.
	scopeVariables := OrderedCollection new: 5.
	scopes := OrderedCollection new: 5.
	tempCount := 0
    ]

    lookupUndeclared: symbol [
	"Answer an Association for variable symbol that will be bound
	 later, if undeclared variables are allowed and the symbol is a
	 syntactic candidate; otherwise answer nil."

	<category: 'private'>
	self class insideFilein ifFalse: [^nil].
	(symbol at: 1) isUppercase ifFalse: [^nil].
	^Undeclared associationAt: symbol ifAbsent:
	    [Undeclared add: (VariableBinding key: symbol value: nil
					      environment: Undeclared)]
    ]
]



Object subclass: PoolResolution [
    <comment: 'I resolve names into shared pool bindings on behalf of
an STSymbolTable.  I can be configured separately for each class, for
use compiling methods for that class.'>

    Current := nil.
    
    PoolResolution class >> current [
	"Answer the resolution class used by the default
	 implementation of #poolResolution on classes."
	^Current
    ]
    
    PoolResolution class >> current: aPoolResolutionClass [
	"Set the value answered by #current."
	^Current := aPoolResolutionClass
    ]

    PoolResolution class >> of: aBehavior [
	"Build a resolution for aBehavior using #declareEnvironment:
	 and #canonicalizeBehavior:."
	<category: 'instance creation'>
	| instance |
	instance := self new.
	instance declareEnvironment:
	    (instance canonicalizeBehavior: aBehavior).
	^instance
    ]

    addClassLast: aClass [
	"As with #addPoolLast:, but for a class instead.  Also as with
	 #addPoolLast:, it often makes sense to replace this
	 implementation with your own."
	<category: 'overriding'>
	| addedPool |
	addedPool := self addPoolLast: aClass classPool.
	aClass sharedPoolDictionaries do: [:sp | self addPoolLast: sp].
	aClass allSuperclassesDo: [:class |
	    self addPoolLast: class classPool.
	    class sharedPoolDictionaries do: [:sp | self addPoolLast: sp]].
	^addedPool
    ]

    addPoolLast: poolDictionary [
	"If it is sensible, add poolDictionary to the end of my pool
	 search order, setting aside whatever standards I usually use
	 to determine the search order.	 Answer whether the pool can
	 now be considered to be included in my search order.

	 My implementation does nothing; you must override it if you
	 want it."
	<category: 'overriding'>
	^false
    ]

    declareEnvironment: aBehavior [
	"Import aBehavior as the direct class that will contain the
	 method I am helping to compile.  I expect to be sent before
	 anything else in my API."
	<category: 'initializing'>
	^self subclassResponsibility
    ]

    canonicalizeBehavior: aBehavior [
	"Map aBehavior to something sensible for #declareEnvironment:.
	 By default, unmeta and then search the inheritance for a real
	 class.  If no real class is found, answer nil."
	<category: 'overriding'>
	| behavior |
	behavior := aBehavior.
	behavior isMetaclass ifTrue: [behavior := behavior instanceClass].
	[behavior isClass] whileFalse:
	    [behavior := behavior superclass.
	     behavior isNil ifTrue: [^nil]].
	^behavior
    ]

    lookupBindingOf: symbol [
	"Answer an Association for the symbol, to be #value-d to
	 resolve the variable at evaluation time, or nil if none can
	 be found."
	<category: 'accessing'>
	^self subclassResponsibility
    ]
]



PoolResolution subclass: ClassicPoolResolution [
    | pools |
    <comment: 'I provide shared pool variable resolution as it was
before the PoolResolution hierarchy was added, and TwistedPools became
default.'>

    addPoolLast: poolDictionary [
	"Add poolDictionary and all superspaces to the end of the
	 search order.	Always succeed."
	<category: 'accessing'>
	pools addAll: poolDictionary withAllSuperspaces.
	^true
    ]

    lookupBindingOf: symbol [
	"Search all pools in order (see super comment)."
	<category: 'accessing'>
	pools do: [:pool |
	    (pool scopeDictionary associationAt: symbol ifAbsent: [nil])
		ifNotNil: [:assoc | ^assoc]].
	^nil
    ]

    declareEnvironment: aBehavior [
	<category: 'initializing'>
	| behavior |
	pools := OrderedSet identityNew: 7.
	aBehavior ifNil: [^nil].
	behavior := aBehavior.
	"add all namespaces, class pools, and shared pools"
	behavior withAllSuperclassesDo: [:class |
	    self addPoolLast: class environment.
	    class classPool isEmpty ifFalse: [pools add: class classPool]].
	behavior withAllSuperclassesDo: [:class |
	    class sharedPoolDictionaries do: [:sp | self addPoolLast: sp]].
    ]
]



PoolResolution subclass: DefaultPoolResolution [
    | pools |
    <comment: 'I provide a "namespace is application" oriented method
of shared pool searching, intended to be more intuitive for those who
expect things to be found in their own namespace first.	 This is more
fully explained by my implementation, or at GNU Smalltalk wiki page
PoolResolution.'>

    addPoolLast: poolDictionary [
	"Add poolDictionary and all superspaces to the end of the
	 search order.	Always succeed."
	<category: 'accessing'>
	pools addAll: poolDictionary withAllSuperspaces.
	^true
    ]

    lookupBindingOf: symbol [
	"Search all pools in order (see super comment)."
	<category: 'accessing'>
	pools do: [:pool |
	    (pool hereAssociationAt: symbol ifAbsent: [nil])
		ifNotNil: [:assoc | ^assoc]].
	^nil
    ]

    declareEnvironment: aBehavior [
	<category: 'initializing'>
	pools := OrderedSet identityNew: 7.
	aBehavior ifNil: [^nil].
	aBehavior allSharedPoolDictionariesDo: [ :each |
	    each isEmpty ifFalse: [ pools add: each ] ]
    ]
]



Behavior extend [
    poolResolution [
	"Answer a PoolResolution class to be used for resolving pool
	 variables while compiling methods on this class."
	<category: 'compiling methods'>
	^STInST.PoolResolution current
    ]
]
    
    
Metaclass extend [
    poolResolution [
	"Use my instance's poolResolution."
	<category: 'compiling methods'>
	^self instanceClass poolResolution
    ]
]



Eval [
    STSymbolTable initialize.
    PoolResolution current: DefaultPoolResolution.
]

PK
     �Mh@,�o      STEvaluationDriver.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Smalltalk in Smalltalk compiler - STParsingDriver that evaluates code
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2006,2007,2008, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: STParserScanner [
    | parser scanner unusedTokens |
    
    <category: 'System-Compiler'>
    <comment: 'I provide RBScanner''s important protocols for use in another Parser
by extracting tokens from a scanner owned by a particular parser.  In
other words, by giving me to another parser, you can subcontract
parsing from one parser to the other.

My main purpose is to account for lookahead tokens, so they are not
hidden from other objects trying to work with a RBParser''s scanner.

    parser
	The parser I come from.
    scanner
	Said parser''s real scanner.
    unusedTokens
	See #unusedTokens:.'>

    STParserScanner class >> overscanFrom: aParser scanning: aScanner [
	"Answer a new instances that treats aParser's implicit scanner
	 token sequence as my own."

	<category: 'instance creation'>
	^(self new)
	    parser: aParser scanner: aScanner;
	    yourself
    ]

    atEnd [
	<category: 'accessing'>
	^unusedTokens isEmpty 
	    ifTrue: [scanner atEnd]
	    ifFalse: [unusedTokens first isMemberOf: RBToken]
    ]

    next [
	<category: 'accessing'>
	^unusedTokens isEmpty 
	    ifTrue: [scanner next]
	    ifFalse: [unusedTokens removeFirst]
    ]

    getComments [
	<category: 'accessing'>
	^scanner getComments
    ]

    stream [
	<category: 'accessing'>
	^scanner stream
    ]

    stripSeparators [
	"I don't know why RBParser sends this, but here it is."

	<category: 'accessing'>
	^scanner stripSeparators
    ]

    unusedTokens: tokens [
	"Make `tokens' a list that should be reread by any parser that
	 takes control of the effective token stream."

	<category: 'accessing'>
	unusedTokens addAllFirst: tokens
    ]

    unusedTokens [
	"Information used by a parser to (re)set its internal state."

	<category: 'private'>
	^unusedTokens
    ]

    parser: aParser scanner: aScanner [
	<category: 'private'>
	parser := aParser.
	scanner := aScanner.
	unusedTokens := OrderedCollection new: 2
    ]
]


STParsingDriver subclass: STEvaluationDriver [
    | curCategory curClass curCompilerClass evalFor lastResult method |
    
    <comment: 'I am an STParsingDriver that compiles code that you file in.'>
    <category: 'System-Compiler'>

    STEvaluationDriver class >> methodsFor: aString parsingWith: parser compiler: compilerClass class: aClass [
	"Search the current context stack for another evaluation driver,
	 copy its error block and scanner to a new instance of `parser',
	 and compile the method definition list following the #methodsFor:
	 invocation implied by this message that was just read by that
	 other evaluation driver/parser.  Answer the new instance of
	 myself.
	 
	 If the outer driver's parser is the same, just reuse that
	 driver/parser combo instead."

	<category: 'accessing'>
	| ctx driver |
	ctx := thisContext.
	[ctx selector == #evaluate:] whileFalse: 
		[ctx := ctx parentContext.
		ctx isNil 
		    ifTrue: 
			[^aClass basicMethodsFor: aString ifTrue: compilerClass ~~ STFakeCompiler]].

	"Optimization where #evaluatorClass is left alone: If the outer
	 parser has the same class as the parser I will create, change the
	 outer driver to #compile: for my arguments."
	(parser isNil or: [ctx receiver parser isMemberOf: parser]) 
	    ifTrue: 
		[^(ctx receiver)
		    methodsFor: aString
			compiler: compilerClass
			class: aClass;
		    yourself].
	driver := self new.
	driver 
	    methodsFor: aString
	    compiler: compilerClass
	    class: aClass.
	ctx receiver parser releaseScannerTo: 
		[:scanner | 
		| parseProc |
		(parseProc := parser new)
		    errorBlock: ctx receiver errorBlock;
		    scanner: scanner;
		    driver: driver;
		    parseMethodDefinitionList.
		scanner unusedTokens: parseProc unusedTokens].
	^driver
    ]

    evalFor: anObject [
	<category: 'accessing'>
	evalFor := anObject
    ]

    result [
	<category: 'accessing'>
	^lastResult
    ]

    methodsFor: aString compiler: compilerClass class: aClass [
	<category: 'accessing'>
	curCategory := aString.
	curClass := aClass.
	curCompilerClass := compilerClass
    ]

    compile: node [
	<category: 'overrides'>
	method := curCompilerClass 
		    compile: node
		    for: curClass
		    classified: curCategory
		    parser: self.
	^method
    ]

    endMethodList [
	<category: 'overrides'>
	curClass := nil
    ]

    evaluate: node [
	<category: 'overrides'>
	| method |
	method := evalFor class compilerClass 
		    compile: node
		    asMethodOf: evalFor class
		    classified: nil
		    parser: self
		    environment: Namespace current.
	[lastResult := evalFor perform: method] valueWithUnwind.
	^curClass notNil
    ]

    record: string [
	"Transcript nextPutAll: string; nl"

	<category: 'overrides'>
	
    ]
]



RBParser extend [

    unusedTokens [
	"Answer the tokens I have read from the scanner but not
	 processed."

	<category: 'accessing'>
	^
	{currentToken.
	nextToken} copyWithout: nil
    ]

    releaseScannerTo: aBlock [
	"Invoke aBlock with my effective scanner, during which that
	 scanner can be owned by a different parser.  After aBlock exits,
	 I assume that I own the scanner's token stream again.  Answer
	 aBlock's result.
	 
	 If you read tokens from the scanner, but don't use them, you must
	 push them back on with #unusedTokens:."

	<category: 'accessing'>
	| delegateScanner |
	delegateScanner := STParserScanner overscanFrom: self scanning: scanner.
	delegateScanner unusedTokens: self unusedTokens.
	^[aBlock value: delegateScanner] ensure: 
		[| unused |
		unused := delegateScanner unusedTokens.
		currentToken := unused at: 1 ifAbsent: [nil].
		nextToken := unused at: 2 ifAbsent: [nil].
		unused size > 2 
		    ifTrue: 
			[SystemExceptions.InvalidValue signalOn: unused
			    reason: 'too many enqueued tokens']]
    ]

]


Behavior extend [

    compilerClass [
	"Return the class that will be used to compile the parse
	 nodes into bytecodes."

	<category: 'compiling'>
	^STInST.STCompiler
    ]

]
PK
     �Mh@�C�L��  ��    STDecompiler.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Smalltalk bytecode decompiler
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2006 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



RBValueToken subclass: STDecompiledValueToken [
    
    <comment: nil>
    <category: 'System-Compiler'>

    length [
	"Always answer 1 (the size of a bytecode)."

	<category: 'overrides'>
	^1
    ]
]



Object subclass: STDecompilationContext [
    | mclass outer method numTemps numArgs tmpNames current jumps instVarNames instVarNamesSet cfg basicBlocks |
    
    <category: 'System-Compiler'>
    <comment: 'This class holds the information about the current decompilation,
including the CFG and the synthetic variable names.

Most of this information is interesting to the decompilers for
the blocks, which is why the sub-contexts hold a pointer to
the outer context.'>

    STDecompilationContext class >> on: aCompiledCodeObject class: aClass outer: outerContext [
	<category: 'instance creation'>
	^self new 
	    initialize: aCompiledCodeObject
	    class: aClass
	    outer: outerContext
    ]

    initialize: aCompiledCodeObject class: aClass outer: outerContext [
	"Initialize the receiver's instance variables with information
	 about decompiling the block or method aCompiledCodeObject, found in
	 the aClass class.  If we are to decompile a block, the context
	 for the outer method is found in outerContext."

	<category: 'initialization'>
	mclass := aClass.
	outer := outerContext.
	method := aCompiledCodeObject.
	numTemps := outer isNil ifTrue: [0] ifFalse: [outer numTemps].
	numArgs := outer isNil ifTrue: [0] ifFalse: [outer numArgs].
	instVarNames := aClass allInstVarNames.
	instVarNamesSet := instVarNames asSet.
	tmpNames := IdentityDictionary new.
	jumps := IdentityDictionary new.
	0 to: self methodNumArgs - 1
	    do: [:index | tmpNames at: index put: self newArgName].
	aCompiledCodeObject dispatchTo: self with: nil.
	self buildCFG
    ]

    buildCFG [
	"Build the control-flow graph of the object to be decompiled."

	<category: 'initialization'>
	| basicBlockBoundaries n |
	basicBlockBoundaries := jumps keys collect: [:each | each + 2].
	basicBlockBoundaries addAll: (jumps values collect: [:each | each value]).
	basicBlockBoundaries add: method size + 2.

	"Build a map from bytecode numbers to basic block ids"
	basicBlocks := OrderedCollection new.
	cfg := OrderedCollection new.
	n := 1.
	basicBlockBoundaries asSortedCollection inject: 1
	    into: 
		[:old :boundary | 
		boundary > old 
		    ifTrue: 
			[boundary - old timesRepeat: [basicBlocks add: n].
			cfg addLast: (STControlFlowGraphNode id: n).
			n := n + 1].
		boundary].

	"Now use it to build the CFG"
	jumps keysAndValuesDo: 
		[:key :each | 
		(self cfgNodeAt: key) 
		    addSuccessor: each key -> (self cfgNodeAt: each value)].

	"Add arcs for falling off the basic block."
	cfg 
	    from: 1
	    to: cfg size - 1
	    do: 
		[:each | 
		each succ isNil 
		    ifTrue: [each addSuccessor: #jump -> (cfg at: each id + 1)].
		(each succ at: 1) key = #jumpTrue 
		    ifTrue: [each addSuccessor: #jumpFalse -> (cfg at: each id + 1)].
		(each succ at: 1) key = #jumpFalse 
		    ifTrue: [each addSuccessor: #jumpTrue -> (cfg at: each id + 1)]].

	"Sort in depth-first order"
	(cfg at: 1) computeDfnums: 1
    ]

    outer [
	"Answer the outer decompilation context"

	<category: 'accessing'>
	^outer
    ]

    mclass [
	"Answer the class in which the method we are decompiling lives"

	<category: 'accessing'>
	^mclass
    ]

    method [
	"Answer the method we are decompiling"

	<category: 'accessing'>
	^method
    ]

    cfg [
	"Answer an Array with all the nodes in the method's control-flow
	 graph."

	<category: 'accessing'>
	^cfg
    ]

    cfgNodeAt: bytecode [
	"Answer the node of the control-flow graph that contains information
	 for the basic block of which the given bytecode index is part"

	<category: 'accessing'>
	^cfg at: (basicBlocks at: bytecode)
    ]

    outerTemporaryAt: anIndex scopes: scopes [
	"Answer the name of the anIndex-th temporary in the scopes-th outer
	 scope"

	<category: 'accessing'>
	^scopes > 0 
	    ifTrue: [self outer outerTemporaryAt: anIndex scopes: scopes - 1]
	    ifFalse: [self temporaryAt: anIndex]
    ]

    instVarNameAt: anIndex [
	"Answer the name of the anIndex-th instance variable of the class
	 in which the decompiled method lives."

	<category: 'accessing'>
	^instVarNames at: anIndex + 1
    ]

    temporaryAt: anIndex [
	"Answer the name of the anIndex-th temporary of the decompiled method."

	<category: 'accessing'>
	^tmpNames at: anIndex
    ]

    temporaryNames [
	"Answer the name of all the temporaries of the decompiled method."

	<category: 'accessing'>
	^tmpNames values
    ]

    methodNumArgs [
	"Answer the number of arguments that the decompiled method receives."

	<category: 'accessing'>
	^method numArgs
    ]

    numArgs [
	"Answer the number of argXXX variables that have been defined so far."

	<category: 'accessing'>
	^numArgs
    ]

    numTemps [
	"Answer the number of tXXX variables that have been defined so far."

	<category: 'accessing'>
	^numTemps
    ]

    newArgName [
	"Answer a new argXXX variable"

	<category: 'accessing'>
	| candidate |
	
	[candidate := 'arg' , (numArgs := numArgs + 1) printString.
	instVarNamesSet includes: candidate] 
		whileTrue.
	^candidate
    ]

    newTemporaryName [
	"Answer a new tXXX variable"

	<category: 'accessing'>
	| candidate |
	
	[candidate := 't' , (numTemps := numTemps + 1) printString.
	instVarNamesSet includes: candidate] 
		whileTrue.
	^candidate
    ]

    invalidOpcode: unused [
	"Signal an error"

	<category: 'analyzing'>
	self error: 'invalid opcode'
    ]

    pushInstVar: anIndex with: unused [
	<category: 'analyzing'>
	
    ]

    storeInstVar: anIndex with: unused [
	<category: 'analyzing'>
	
    ]

    makeDirtyBlock: unused [
	<category: 'analyzing'>
	
    ]

    pushTemporary: anIndex outer: scopes with: unused [
	"Create the name of the given temporary"

	<category: 'analyzing'>
	scopes > 0 
	    ifTrue: [self pushTemporary: anIndex with: unused]
	    ifFalse: 
		[outer 
		    pushTemporary: anIndex
		    outer: scopes - 1
		    with: unused]
    ]

    storeTemporary: anIndex outer: scopes with: unused [
	"Create the name of the given temporary"

	<category: 'analyzing'>
	scopes > 0 
	    ifTrue: [self storeTemporary: anIndex with: unused]
	    ifFalse: 
		[outer 
		    storeTemporary: anIndex
		    outer: scopes - 1
		    with: unused]
    ]

    pushTemporary: anIndex with: unused [
	"Create the name of the given temporary"

	<category: 'analyzing'>
	tmpNames at: anIndex ifAbsentPut: [self newTemporaryName]
    ]

    storeTemporary: anIndex with: unused [
	"Create the name of the given temporary"

	<category: 'analyzing'>
	tmpNames at: anIndex ifAbsentPut: [self newTemporaryName]
    ]

    popIntoArray: anIndex with: unused [
	<category: 'analyzing'>
	
    ]

    pushLiteral: anObject with: unused [
	<category: 'analyzing'>
	
    ]

    pushGlobal: anObject with: unused [
	<category: 'analyzing'>
	
    ]

    storeGlobal: anObject with: unused [
	<category: 'analyzing'>
	
    ]

    pushSelf: unused [
	<category: 'analyzing'>
	
    ]

    popStackTop: unused [
	<category: 'analyzing'>
	
    ]

    dupStackTop: unused [
	<category: 'analyzing'>
	
    ]

    exitInterpreter: unused [
	<category: 'analyzing'>
	
    ]

    returnFromContext: unused [
	"Returns are treated as jumps to past the final bytecode"

	<category: 'analyzing'>
	self jumpTo: method size + 1 with: unused
    ]

    returnFromMethod: unused [
	"Returns are treated as jumps to past the final bytecode"

	<category: 'analyzing'>
	self jumpTo: method size + 1 with: unused
    ]

    popJumpIfFalseTo: destination with: unused [
	"Record the jump"

	<category: 'analyzing'>
	jumps at: current put: #jumpFalse -> destination
    ]

    popJumpIfTrueTo: destination with: unused [
	"Record the jump"

	<category: 'analyzing'>
	jumps at: current put: #jumpTrue -> destination
    ]

    jumpTo: destination with: unused [
	"Record the jump"

	<category: 'analyzing'>
	jumps at: current put: #jump -> destination
    ]

    lineNo: n with: unused [
	<category: 'analyzing'>
	
    ]

    superSend: aSymbol numArgs: anInteger with: unused [
	<category: 'analyzing'>
	
    ]

    send: aSymbol numArgs: anInteger with: unused [
	<category: 'analyzing'>
	
    ]

    bytecodeIndex: byte with: unused [
	<category: 'analyzing'>
	current := byte
    ]
]



Magnitude subclass: STControlFlowGraphNode [
    | id dfnum pred succ fallThrough statements stack |
    
    <category: 'System-Compiler'>
    <comment: 'This class is a node in the CFG of a method.  It knows how
to simplify itself to a single node that uses Smalltalk''s
control-structures-as-messages.'>

    STControlFlowGraphNode class >> id: id [
	"Create a new instance of the receiver"

	<category: 'instance creation'>
	^self new id: id
    ]

    printOn: aStream [
	"Print a textual representation of the receiver on aStream"

	<category: 'printing'>
	aStream
	    print: self id;
	    nextPutAll: ' df=';
	    print: self dfnum.
	self succ isNil 
	    ifFalse: 
		[aStream 
		    print: (self succ collect: [:each | each key -> each value id]) asArray].
	statements isNil 
	    ifFalse: 
		[statements do: 
			[:each | 
			aStream
			    nl;
			    space: 4;
			    print: each]].
	aStream nl
    ]

    printTreeOn: aStream [
	"Print a textual representation of the receiver and all of its
	 successors on aStream"

	<category: 'printing'>
	(self withAllSuccessors asSortedCollection: [:a :b | a id < b id]) do: 
		[:node | 
		aStream
		    print: node;
		    nl]
    ]

    addPredecessor: node [
	"Private - Add `node' to the set of predecessors of the receiver."

	<category: 'private'>
	pred := pred isNil ifTrue: [{node}] ifFalse: [pred copyWith: node]
    ]

    removeSuccessor: node [
	"Private - Remove `node' from the set of successors of the receiver."

	<category: 'private'>
	succ isNil 
	    ifFalse: 
		[succ := succ reject: [:each | each value = node].
		succ isEmpty ifTrue: [succ := nil]]
    ]

    removePredecessor: node [
	"Private - Remove `node' from the set of predecessors of the receiver."

	<category: 'private'>
	pred isNil 
	    ifFalse: 
		[pred := pred copyWithout: node.
		pred isEmpty ifTrue: [pred := nil]]
    ]

    addAllSuccessorsTo: aSet [
	"Private - Add all the direct and indirect successors of the receiver
	 to aSet."

	<category: 'private'>
	succ isNil ifTrue: [^aSet].
	succ do: 
		[:each | 
		(aSet includes: each value) 
		    ifFalse: 
			[aSet add: each value.
			each value addAllSuccessorsTo: aSet]].
	^aSet
    ]

    computeDfnums: n [
	"Private - Number the receiver and all of its direct and
	 indirect successors in depth-first order, starting from n."

	<category: 'private'>
	| num |
	self dfnum isNil ifFalse: [^n].
	self dfnum: n.
	num := n + 1.
	self succ isNil 
	    ifFalse: [succ do: [:each | num := each value computeDfnums: num]].
	^num
    ]

    < anObject [
	"Sort in depth-first order"

	<category: 'comparison'>
	^self dfnum < anObject dfnum
    ]

    = anObject [
	"Sort in depth-first order"

	<category: 'comparison'>
	^self class == anObject class and: [self dfnum = anObject dfnum]
    ]

    hash [
	"Sort in depth-first order"

	<category: 'comparison'>
	^self dfnum
    ]

    allSuccessors [
	"Answer the set of all direct and indirect successors of
	 the receiver"

	<category: 'accessing'>
	^self addAllSuccessorsTo: Set new
    ]

    withAllSuccessors [
	"Answer the set of all the nodes in the receiver's CFG, that
	 is the node and all of its direct and indirect successors."

	<category: 'accessing'>
	^(self addAllSuccessorsTo: Set new)
	    add: self;
	    yourself
    ]

    dfnum [
	"Answer the progressive number of the receiver in a depth-first
	 visit of the graph."

	<category: 'accessing'>
	^dfnum
    ]

    dfnum: n [
	"Set the progressive number of the receiver in a depth-first
	 visit of the graph."

	<category: 'accessing'>
	dfnum := n
    ]

    id [
	"Answer a numeric identifier for the receiver.  Consecutive indexes
	 represent basic blocks that are adjacent in memory."

	<category: 'accessing'>
	^id
    ]

    id: n [
	"Set the numeric identifier for the receiver.  Consecutive indexes
	 represent basic blocks that are adjacent in memory."

	<category: 'accessing'>
	id := n
    ]

    pred [
	"Answer the set of predecessors of the receiver."

	<category: 'accessing'>
	^pred
    ]

    succ [
	"Answer the set of successors of the receiver."

	<category: 'accessing'>
	^succ
    ]

    succ: newSucc [
	"Set the set of successors of the receiver to be newSucc.
	 newSucc should hold associations that represent the kind
	 of jump (#jump, #jumpTrue, #jumpFalse) in the key, and
	 the destination basic block in the value."

	<category: 'accessing'>
	succ isNil 
	    ifFalse: 
		[succ do: [:each | each value removePredecessor: self].
		succ := nil].
	succ := newSucc.
	succ isNil ifTrue: [^self].
	succ do: [:assoc | assoc value addPredecessor: self]
    ]

    statements [
	"Answer the set of statements executed by the receiver"

	<category: 'accessing'>
	^ statements ifNil: [ #() ]
    ]

    statements: aCollection [
	"Set the set of statements executed by the receiver"

	<category: 'accessing'>
	statements := aCollection
    ]

    stack [
	"Answer the state of the stack after the receiver completes
	 its execution"

	<category: 'accessing'>
	stack isNil ifTrue: [stack := OrderedCollection new].
	^stack
    ]

    stack: aCollection [
	"Set the state of the stack after the receiver completes
	 its execution"

	<category: 'accessing'>
	stack := aCollection
    ]

    fallThroughIfFalse [
	"Answer whether the receiver ends with a `jump if true'
	 bytecode"

	<category: 'accessing'>
	^fallThrough = #jumpFalse
    ]

    fallThroughIfTrue [
	"Answer whether the receiver ends with a `jump if false'
	 bytecode"

	<category: 'accessing'>
	^fallThrough = #jumpTrue
    ]

    addSuccessor: kindBlockAssociation [
	"Add the successor represented by kindBlockAssociation,
	 which should be an association that represents the kind
	 of jump (#jump, #jumpTrue, #jumpFalse) in the key, and
	 the destination basic block in the value."

	<category: 'accessing'>
	kindBlockAssociation value id = (self id + 1) 
	    ifTrue: [fallThrough := kindBlockAssociation key].
	succ := succ isNil 
		    ifTrue: [{kindBlockAssociation}]
		    ifFalse: [succ copyWith: kindBlockAssociation].
	kindBlockAssociation value addPredecessor: self
    ]

    blkNode: statements arguments: args [
	"Private - Answer an RBBlockNode with the given statements
	 and arguments."

	<category: 'simplification'>
	^(RBBlockNode new)
	    body: (self seqNode: statements);
	    arguments: args
    ]

    blkNode: statements [
	"Private - Answer an RBBlockNode with the given statements."

	<category: 'simplification'>
	^(RBBlockNode new)
	    body: (self seqNode: statements);
	    arguments: #()
    ]

    msgNode: arguments receiver: receiver selector: aSymbol [
	"Private - Answer an RBMessageNode with the given arguments,
	 receiver and selector."

	<category: 'simplification'>
	| selParts |
	selParts := aSymbol keywords 
		    collect: [:each | RBValueToken new value: each].
	^(RBMessageNode new)
	    arguments: arguments;
	    receiver: receiver;
	    selectorParts: selParts
    ]

    seqNode: statements [
	"Private - Answer an RBSequenceNode with the given statements."

	<category: 'simplification'>
	^(RBSequenceNode new)
	    temporaries: #();
	    statements: statements;
	    periods: #()
    ]

    disconnect [
	"Disconnect the receiver from the graph (removing
	 all arcs that point to it or depart from it)."

	<category: 'simplification'>
	pred isNil 
	    ifFalse: 
		[pred do: [:each | each removeSuccessor: self].
		pred := nil].
	self succ: nil
    ]

    disconnectSuccessorsAndMerge: newSucc [
	"Disconnect the receiver's successors from the graph (removing
	 all arcs that point to them or depart from them),
	 then try to merge the receiver with its predecessor
	 (if there is only one after the disconnection) and
	 possibly with the new successors, newSucc (if there
	 is only one and it has no other predecessors than the
	 receiver)."

	<category: 'simplification'>
	succ do: [:each | each value disconnect].
	self merge: newSucc
    ]

    merge: succSet [
	"Try to merge the receiver with its predecessor
	 (if there is only one after the disconnection) and
	 possibly with the new successors, succSet (if there
	 is only one and it has no other predecessors than the
	 receiver)."

	<category: 'simplification'>
	| newSelf newSucc theSucc |
	newSucc := succSet.
	newSelf := self.
	self succ: newSucc.
	newSelf pred size = 1 
	    ifTrue: 
		[newSelf := pred at: 1.
		newSelf statements addAllLast: self statements.
		self disconnect.
		newSelf succ: newSucc].
	
	[newSucc size = 1 ifFalse: [^self].
	theSucc := (newSucc at: 1) value.
	theSucc pred size = 1 ifFalse: [^self].
	newSelf statements addAllLast: theSucc statements.
	newSucc := theSucc succ.
	theSucc disconnect] 
		repeat
    ]

    simplify [
	"Recognize simple control structures in the receiver and
	 reduce them to a single basic block that sends the appropriate
	 Smalltalk messages."

	<category: 'simplification'>
	self
	    simplifyRepeat;
	    simplifyIf;
	    simplifyLoop
    ]

    simplifyIf: cond then: arm2 else: arm1 ifTrueIfFalse: ifTrueIfFalse [
	"Simplify a two-way conditional.  cond used to be the
	 last statement of the receiver, arm1 and arm2 are the
	 receiver's successor basic blocks."

	<category: 'simplification'>
	"'resolving if/then/else' displayNl."

	| block1 block2 |
	block2 := self blkNode: arm2 statements.
	block1 := self blkNode: arm1 statements.
	self statements addLast: (self 
		    msgNode: 
			{block1.
			block2}
		    receiver: cond
		    selector: (ifTrueIfFalse 
			    ifTrue: [#ifTrue:ifFalse:]
			    ifFalse: [#ifFalse:ifTrue:]))
    ]

    simplifyIf: cond then: arm ifTrue: ifTrue [
	"Simplify a one-way conditional.  cond used to be the
	 last statement of the receiver, arm is one of the
	 receiver's successor basic blocks."

	<category: 'simplification'>
	"'resolving if/then' displayNl."

	| seq block |
	block := self blkNode: arm statements.
	self statements addLast: (self 
		    msgNode: {block}
		    receiver: cond
		    selector: (ifTrue ifTrue: [#ifTrue:] ifFalse: [#ifFalse:]))
    ]

    simplifyIf [
	"Recognize conditional control structures where the
	 receiver is the header, and simplify them."

	<category: 'simplification'>
	| cond arm1 arm2 |
	succ size < 2 ifTrue: [^false].
	arm1 := (self succ at: 1) value.
	arm2 := (self succ at: 2) value.
	((arm1 succ at: 1) value = (arm2 succ at: 1) value 
	    and: [(arm1 succ at: 1) value ~= self and: [(arm2 succ at: 1) value ~= self]]) 
		ifTrue: 
		    [self
			simplifyIf: self statements removeLast
			    then: arm1
			    else: arm2
			    ifTrueIfFalse: self fallThroughIfFalse;
			disconnectSuccessorsAndMerge: arm1 succ.
		    ^true].
	((arm2 succ at: 1) value = arm1 and: [(arm2 succ at: 1) value ~= self]) 
	    ifTrue: 
		[self
		    simplifyIf: self statements removeLast
			then: arm2
			ifTrue: self fallThroughIfTrue;
		    disconnectSuccessorsAndMerge: arm1 succ.
		^true].
	^false
    ]

    simplifyWhile: body whileTrue: whileTrue [
	"Simplify a #whileTrue: or #whileFalse: control structure
	 where the receiver will be the receiver block, and body
	 the argument block."

	<category: 'simplification'>
	"'resolving while' displayNl."

	| cond block |
	cond := self blkNode: self statements.
	block := self blkNode: body statements.
	self 
	    statements: (OrderedCollection with: (self 
			    msgNode: {block}
			    receiver: cond
			    selector: (whileTrue ifTrue: [#whileTrue:] ifFalse: [#whileFalse:])))
    ]

    simplifyTimesRepeat: body newSucc: newSucc [
	"Simplify a #timesRepeat: control structure."

	<category: 'simplification'>
	"'resolving timesRepeat' displayNl."

	| to block |
	(newSucc statements)
	    removeFirst;
	    removeFirst.
	(self statements)
	    removeLast;
	    removeLast.
	(body statements)
	    removeLast;
	    removeLast.
	((self pred at: 2) statements)
	    removeLast;
	    removeLast.
	to := self statements removeLast.
	block := self blkNode: body statements.
	self statements addLast: (self 
		    msgNode: {block}
		    receiver: to
		    selector: #timesRepeat:)
    ]

    simplifyToByDo: body newSucc: newSucc [
	"Simplify a #to:do: or #to:by:do: control structure."

	<category: 'simplification'>
	| variable from to by block |
	(self statements at: self statements size - 2) isAssignment 
	    ifFalse: [^self simplifyTimesRepeat: body newSucc: newSucc].

	"'resolving to/by/do' displayNl."
	(newSucc statements)
	    removeFirst;
	    removeFirst.
	self statements removeLast.
	to := self statements removeLast.
	from := self statements last value.
	variable := self statements removeLast variable.
	by := body statements removeLast value arguments at: 1.
	(body statements)
	    removeLast;
	    removeLast;
	    removeLast.
	((self pred at: 2) statements)
	    removeLast;
	    removeLast;
	    removeLast;
	    removeLast.
	block := self blkNode: body statements arguments: {variable}.
	self statements addLast: (self 
		    msgNode: (by = 1 
			    ifTrue: 
				[
				{to.
				block}]
			    ifFalse: 
				[
				{to.
				by.
				block}])
		    receiver: from
		    selector: (by = 1 ifFalse: [#to:by:do:] ifTrue: [#to:do:]))
    ]

    simplifyLoop [
	"Recognize looping control structures where the
	 receiver is the dominator, and simplify them."

	<category: 'simplification'>
	| middle bottom |
	succ size < 2 ifTrue: [^false].
	pred isNil ifTrue: [^false].
	bottom := succ detect: [:each | pred includes: each value] ifNone: [^false].
	middle := succ detect: [:each | each ~= bottom].
	middle value statements size = 0 
	    ifFalse: 
		[self simplifyToByDo: bottom value newSucc: middle value.
		self disconnectSuccessorsAndMerge: {middle}]
	    ifTrue: 
		[self simplifyWhile: bottom value whileTrue: self fallThroughIfFalse.
		self disconnectSuccessorsAndMerge: middle value succ].
	^true
    ]

    simplifyRepeat [
	"Recognize and simplify infinite loops (#repeat)."

	<category: 'simplification'>
	| block |
	self succ isNil ifTrue: [^false].
	(self succ at: 1) value = self ifFalse: [^false].

	"'resolving repeat' displayNl."
	block := self blkNode: self statements.
	self statements: 
		{self 
		    msgNode: #()
		    receiver: block
		    selector: #repeat}.
	self merge: nil.
	^true
    ]
]



Object subclass: STDecompiler [
    | context stack statements isBlock current bbList bb |
    
    <category: 'System-Compiler'>
    <comment: 'This class converts bytecodes back to parse trees.'>

    STDecompiler class >> decompile: aSelector in: aClass [
	"Answer the source code for the selector aSelector of the
	 given class"

	<category: 'instance creation'>
	| node |
	node := self parseTreeForMethod: aClass >> aSelector in: aClass.
	^RBFormatter new format: node
    ]

    STDecompiler class >> parseTreeForMethod: aMethod in: aClass [
	"Answer the parse tree for the method aMethod of the
	 given class"

	<category: 'instance creation'>
	^self new decompileMethod: (STDecompilationContext 
		    on: aMethod
		    class: aClass
		    outer: nil)
    ]

    STDecompiler class >> parseTreeForBlock: aBlock from: aDecompilerObject [
	"Answer the parse tree for the block aBlock, considering
	 the information already dug by aDecompilerObject"

	<category: 'instance creation'>
	^self new decompileBlock: (STDecompilationContext 
		    on: aBlock
		    class: aDecompilerObject context mclass
		    outer: aDecompilerObject context)
    ]

    STDecompiler class >> testRepeat [
	"A meaningless method to test #repeat simplification"

	<category: 'test'>
	| c |
	c := 'c'.
	
	[c * 2.
	true ifTrue: [c * c].
	2 * c] repeat
    ]

    STDecompiler class >> testIfTrue [
	"A meaningless method to test #ifTrue: simplification"

	<category: 'test'>
	| a b c |
	a := 'a'.
	b := 'b'.
	c := 'c'.
	a = b ifTrue: [c * c]
    ]

    STDecompiler class >> testWhile [
	"A meaningless method to test #whileTrue: simplification"

	<category: 'test'>
	| a b c |
	a := 'a'.
	b := 'b'.
	c := 'c'.
	
	[b = 1.
	1 = b] whileFalse: 
		    [c * 1.
		    1 * c].
	
	[b = 2.
	2 = b] whileTrue: 
		    [c * 2.
		    2 * c]
    ]

    STDecompiler class >> testToByDo [
	"A meaningless method to test #to:by:do: simplification"

	<category: 'test'>
	| a b c |
	a := 'a'.
	b := 'b'.
	c := 'c'.
	a to: b
	    by: 3
	    do: 
		[:i | 
		a = b.
		c = i]
    ]

    STDecompiler class >> test [
	"Do some tests"

	<category: 'test'>
	(self decompile: #testToByDo in: STDecompiler class) displayNl.
	'' displayNl.
	(self decompile: #testWhile in: STDecompiler class) displayNl.
	'' displayNl.
	(self decompile: #testIfTrue in: STDecompiler class) displayNl.
	'' displayNl.
	(self decompile: #testRepeat in: STDecompiler class) displayNl.
	'' displayNl.
	(self decompile: #path in: VariableBinding) displayNl.
	'' displayNl.
	(self decompile: #bindWith: in: CharacterArray) displayNl.
	'' displayNl.
	(self decompile: #detect: in: Iterable) displayNl.
	'' displayNl.
	(self decompile: #key:value:environment: in: HomedAssociation class) 
	    displayNl.
	'' displayNl.
	(self decompile: #storeOn: in: VariableBinding) displayNl.
	'' displayNl.
	(self decompile: #contents in: MappedCollection) displayNl.
	'' displayNl.
	(self decompile: #collect: in: MappedCollection) displayNl.
	'' displayNl.
	(self decompile: #repeat in: BlockClosure) displayNl.
	'' displayNl.
	(self decompile: #binaryRepresentationObject in: Object) displayNl.
	'' displayNl.
	(self decompile: #whileTrue: in: BlockClosure) displayNl.
	'' displayNl.
	(self decompile: #become: in: Object) displayNl.
	'' displayNl.
	(self decompile: #timesRepeat: in: Integer) displayNl
    ]

    context [
	<category: 'auxiliary'>
	^context
    ]

    source [
	"Answer a dummy source code object to be used to insert
	 primitive names in the decompiled code."

	<category: 'auxiliary'>
	^context method primitive > 0 
	    ifTrue: 
		['<primitive: %1>' % {VMPrimitives keyAtValue: context method primitive}]
	    ifFalse: ['']
    ]

    tags: source [
	<category: 'auxiliary'>
	^source isEmpty ifTrue: [#()] ifFalse: [{1 to: source size}]
    ]

    argumentNames [
	<category: 'auxiliary'>
	^(0 to: context methodNumArgs - 1) 
	    collect: [:each | context temporaryAt: each]
    ]

    arguments [
	<category: 'auxiliary'>
	^self argumentNames collect: [:each | self varNode: each]
    ]

    selectorParts: aSymbol [
	<category: 'auxiliary'>
	^aSymbol keywords 
	    collect: [:each | RBValueToken value: each start: current]
    ]

    temporaries [
	<category: 'auxiliary'>
	^self temporaryNames collect: [:each | self varNode: each]
    ]

    temporaryNames [
	<category: 'auxiliary'>
	^(context temporaryNames asOrderedCollection)
	    removeAll: self argumentNames;
	    yourself
    ]

    litNode: anObject [
	<category: 'auxiliary'>
	| tok |
	anObject class == BlockClosure 
	    ifTrue: [^self class parseTreeForBlock: anObject block from: self].
	tok := anObject class == Association 
		    ifFalse: [RBLiteralToken value: anObject start: current]
		    ifTrue: [RBBindingToken value: anObject path start: current].
	^RBLiteralNode new literalToken: tok
    ]

    varNode: name [
	<category: 'auxiliary'>
	^RBVariableNode new 
	    identifierToken: (STDecompiledValueToken value: name start: current)
    ]

    assignment: name [
	<category: 'auxiliary'>
	^(RBAssignmentNode new)
	    value: stack removeLast;
	    variable: (self varNode: name)
    ]

    decompileBlock: stDecompilationContext [
	<category: 'decompilation'>
	isBlock := true.
	^(RBBlockNode new)
	    body: (self decompileBody: stDecompilationContext);
	    arguments: self arguments;
	    yourself
    ]

    decompileMethod: stDecompilationContext [
	<category: 'decompilation'>
	| parseNode |
	isBlock := false.
	^(parseNode := RBMethodNode new)
	    body: (self decompileBody: stDecompilationContext);
	    selectorParts: (self selectorParts: context method selector);
	    source: self source;
	    tags: (self tags: parseNode source);
	    arguments: self arguments;
	    yourself
    ]

    decompileBody: stDecompilationContext [
	<category: 'decompilation'>
	| seq |
	context := stDecompilationContext.
	stack := OrderedCollection new.
	bbList := SortedCollection new.
	context method dispatchTo: self with: nil.
	self bytecodeIndex: context method size + 1 with: nil.
	self simplify.
	seq := (RBSequenceNode new)
		    temporaries: self temporaries;
		    statements: (context cfg at: 1) statements;
		    periods: #().
	^seq
    ]

    doCascade: send [
	<category: 'decompilation'>
	(stack notEmpty and: [stack last isCascade]) 
	    ifFalse: 
		[stack 
		    addLast: (RBCascadeNode new messages: (OrderedCollection with: send))]
	    ifTrue: 
		[send parent: stack last.
		stack last messages addLast: send]
    ]

    endStatement [
	<category: 'decompilation'>
	statements addLast: stack removeLast
    ]

    invalidOpcode: unused [
	<category: 'analyzing'>
	self error: 'invalid opcode'
    ]

    makeDirtyBlock: unused [
	<category: 'analyzing'>
	
    ]

    pushInstVar: anIndex with: unused [
	<category: 'analyzing'>
	stack addLast: (self varNode: (context instVarNameAt: anIndex))
    ]

    storeInstVar: anIndex with: unused [
	<category: 'analyzing'>
	stack addLast: (self assignment: (context instVarNameAt: anIndex))
    ]

    pushTemporary: anIndex outer: scopes with: unused [
	<category: 'analyzing'>
	stack 
	    addLast: (self varNode: (context outerTemporaryAt: anIndex scopes: scopes))
    ]

    storeTemporary: anIndex outer: scopes with: unused [
	<category: 'analyzing'>
	stack addLast: (self 
		    assignment: (context outerTemporaryAt: anIndex scopes: scopes))
    ]

    pushTemporary: anIndex with: unused [
	<category: 'analyzing'>
	stack addLast: (self varNode: (context temporaryAt: anIndex))
    ]

    storeTemporary: anIndex with: unused [
	<category: 'analyzing'>
	stack addLast: (self assignment: (context temporaryAt: anIndex))
    ]

    popIntoArray: anIndex with: unused [
	<category: 'analyzing'>
	| value |
	value := stack removeLast.
	anIndex = 0 
	    ifTrue: 
		[stack removeLast.
		stack 
		    addLast: (RBArrayConstructorNode new body: ((RBSequenceNode new)
				    temporaries: #();
				    statements: OrderedCollection new;
				    periods: #()))].
	stack last body addNode: value
    ]

    pushLiteral: anObject with: unused [
	<category: 'analyzing'>
	stack addLast: (self litNode: anObject)
    ]

    pushGlobal: anObject with: unused [
	<category: 'analyzing'>
	stack addLast: (self varNode: anObject path)
    ]

    storeGlobal: anObject with: unused [
	<category: 'analyzing'>
	stack addLast: (self assignment: anObject path)
    ]

    pushSelf: unused [
	<category: 'analyzing'>
	stack addLast: (self varNode: 'self')
    ]

    isCascadeLast [
	<category: 'analyzing'>
	^stack size >= 2 and: [(stack at: stack size - 1) isCascade]
    ]

    isCascade [
	<category: 'analyzing'>
	(stack size >= 3 and: [(stack at: stack size - 2) isCascade]) 
	    ifTrue: [^true].
	^stack size >= 2 and: 
		[stack last isMessage 
		    and: [(stack at: stack size - 1) == stack last receiver]]
    ]

    popStackTop: unused [
	<category: 'analyzing'>
	| send receiver |
	self isCascade ifFalse: [^self endStatement].

	"There are two possible cases:
	 
	 the receiver		-->	an RBCascadeNode
	 the new message send		the receiver
	 
	 the RBCascadeNode		augmented RBCascadeNode
	 the receiver		-->	the receiver
	 the new message send"
	send := stack removeLast.
	receiver := stack removeLast.
	self doCascade: send.
	stack addLast: receiver
    ]

    dupStackTop: unused [
	<category: 'analyzing'>
	stack addLast: (stack at: stack size)
    ]

    exitInterpreter: unused [
	<category: 'analyzing'>
	
    ]

    returnFromContext: unused [
	<category: 'analyzing'>
	isBlock 
	    ifTrue: [self endStatement]
	    ifFalse: [self returnFromMethod: unused]
    ]

    returnFromMethod: unused [
	<category: 'analyzing'>
	| retVal |
	retVal := stack removeLast.
	stack size timesRepeat: [statements addAllLast: stack removeFirst].
	statements addLast: (RBReturnNode value: retVal)
    ]

    popJumpIfFalseTo: destination with: unused [
	<category: 'analyzing'>
	
    ]

    popJumpIfTrueTo: destination with: unused [
	<category: 'analyzing'>
	
    ]

    jumpTo: destination with: unused [
	<category: 'analyzing'>
	
    ]

    lineNo: n with: unused [
	<category: 'analyzing'>
	
    ]

    superSend: aSymbol numArgs: anInteger with: unused [
	"Pop the class at which we start the search."

	<category: 'analyzing'>
	stack removeLast.
	stack at: stack size - anInteger put: (self varNode: 'super').
	^self 
	    send: aSymbol
	    numArgs: anInteger
	    with: unused
    ]

    send: aSymbol numArgs: anInteger with: unused [
	<category: 'analyzing'>
	"Not a very efficient check, but a rare one indeed (who
	 sends #thisContext?)"

	| args collection msg |
	(aSymbol == #thisContext 
	    and: [stack last = self varNode: ContextPart binding path]) 
		ifTrue: 
		    [stack
			removeLast;
			addLast: (self varNode: 'thisContext').
		    ^self].
	args := Array new: anInteger.
	anInteger to: 1
	    by: -1
	    do: [:each | args at: each put: stack removeLast].
	stack addLast: ((RBMessageNode new)
		    arguments: args;
		    receiver: stack removeLast;
		    selectorParts: (self selectorParts: aSymbol)).

	"If the receiver was over an RBCascadeNode, merge the send
	 with the cascade."
	self isCascadeLast ifTrue: [self doCascade: stack removeLast]
    ]

    bytecodeIndex: byte with: unused [
	<category: 'analyzing'>
	| newBB |
	current := byte.
	newBB := context cfgNodeAt: byte.
	newBB == bb 
	    ifFalse: 
		[self newBasicBlock: newBB.
		statements := OrderedCollection new.
		bb := newBB]
    ]

    newBasicBlock: newBB [
	<category: 'analyzing'>
	bb isNil ifTrue: [^self].
	bb dfnum isNil ifTrue: [^self].
	statements addAllLast: stack.
	bb statements: statements.
	bbList add: bb.
	bb succ do: 
		[:each | 
		each value stack: stack copy.
		each key = #jump ifFalse: [each value stack removeLast]].
	stack := newBB stack
    ]

    simplify [
	<category: 'analyzing'>
	| oldSize goOn |
	bbList := bbList asArray.
	
	[bbList := bbList select: 
			[:each | 
			each succ size >= 2 
			    or: [each succ notNil and: [(each succ at: 1) value id <= each id]]].
	bbList isEmpty] 
		whileFalse: [bbList do: [:each | each simplify]]
    ]
]

PK
     �Mh@�b��Z�  Z�    ParseTreeSearcher.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Refactoring Browser - Parse tree searching and rewriting
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1998-2000 The Refactory, Inc.
|
| This file is distributed together with GNU Smalltalk.
|
 ======================================================================"



Object subclass: RBReadBeforeWrittenTester [
    | read checkNewTemps scopeStack searcher |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBReadBeforeWrittenTester class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    RBReadBeforeWrittenTester class >> isVariable: aString readBeforeWrittenIn: aBRProgramNode [
	<category: 'accessing'>
	^(self isVariable: aString writtenBeforeReadIn: aBRProgramNode) not
    ]

    RBReadBeforeWrittenTester class >> isVariable: aString writtenBeforeReadIn: aBRProgramNode [
	<category: 'accessing'>
	^(self readBeforeWritten: (Array with: aString) in: aBRProgramNode) 
	    isEmpty
    ]

    RBReadBeforeWrittenTester class >> readBeforeWritten: varNames in: aParseTree [
	<category: 'accessing'>
	^(self new)
	    checkNewTemps: false;
	    initializeVars: varNames;
	    executeTree: aParseTree;
	    read
    ]

    RBReadBeforeWrittenTester class >> variablesReadBeforeWrittenIn: aParseTree [
	<category: 'accessing'>
	^(self new)
	    executeTree: aParseTree;
	    read
    ]

    checkNewTemps: aBoolean [
	<category: 'initialize-release'>
	checkNewTemps := aBoolean
    ]

    createSearchTrees [
	<category: 'initialize-release'>
	searcher := ParseTreeSearcher new.

	"Case 1 - Set the values, depending on whether we matched an assignment"
	searcher
	    matches: '`var := `@object'
		do: 
		    [:aNode :ans | 
		    searcher executeTree: aNode value.
		    self variableWritten: aNode.
		    ans];
	    matches: '`var'
		do: 
		    [:aNode :ans | 
		    self variableRead: aNode.
		    ans].

	"Handle the special while* and ifTrue:ifFalse: blocks separately"
	searcher
	    matchesAnyOf: #('[| `@temps | ``@.Statements] whileTrue: ``@block' '[| `@temps | ``@.Statements] whileTrue' '[| `@temps | ``@.Statements] whileFalse: ``@block' '[| `@temps | ``@.Statements] whileFalse')
		do: [:aNode :ans | ans];
	    matchesAnyOf: #('`@condition ifTrue: [| `@tTemps | `@.trueBlock] ifFalse: [| `@fTemps| `@.falseBlock]' '`@condition ifFalse: [| `@fTemps | `@.falseBlock] ifTrue: [| `@tTemps | `@.trueBlock]')
		do: 
		    [:aNode :ans | 
		    searcher executeTree: aNode receiver.
		    self processIfTrueIfFalse: aNode.
		    ans].

	"Case 2 - Recursive call yourself on the body of the block node just matched"
	searcher matches: '[:`@args | | `@temps | `@.Statements]'
	    do: 
		[:aNode :ans | 
		self processBlock: aNode.
		ans].
	searcher matches: '| `@temps | `@.Stmts'
	    do: 
		[:aNode :ans | 
		self processStatementNode: aNode.
		ans]
    ]

    initialize [
	<category: 'initialize-release'>
	scopeStack := OrderedCollection with: Dictionary new.
	read := Set new.
	checkNewTemps := true.
	self createSearchTrees
    ]

    initializeVars: varNames [
	<category: 'initialize-release'>
	varNames do: [:each | self currentScope at: each put: nil]
    ]

    executeTree: aParseTree [
	<category: 'accessing'>
	^searcher executeTree: aParseTree
    ]

    read [
	<category: 'accessing'>
	self currentScope 
	    keysAndValuesDo: [:key :value | value == true ifTrue: [read add: key]].
	^read
    ]

    copyDictionary: aDictionary [
	"We could send aDictionary the copy message, but that doesn't copy the associations."

	<category: 'private'>
	| newDictionary |
	newDictionary := Dictionary new: aDictionary size.
	aDictionary 
	    keysAndValuesDo: [:key :value | newDictionary at: key put: value].
	^newDictionary
    ]

    createScope [
	<category: 'private'>
	scopeStack add: (self copyDictionary: scopeStack last)
    ]

    currentScope [
	<category: 'private'>
	^scopeStack last
    ]

    processBlock: aNode [
	<category: 'private'>
	| newScope |
	self createScope.
	self executeTree: aNode body.
	newScope := self removeScope.
	newScope keysAndValuesDo: 
		[:key :value | 
		(value == true and: [(self currentScope at: key) isNil]) 
		    ifTrue: [self currentScope at: key put: value]]
    ]

    processIfTrueIfFalse: aNode [
	<category: 'private'>
	| trueScope falseScope |
	self createScope.
	self executeTree: aNode arguments first body.
	trueScope := self removeScope.
	self createScope.
	self executeTree: aNode arguments last body.
	falseScope := self removeScope.
	self currentScope keysAndValuesDo: 
		[:key :value | 
		value isNil 
		    ifTrue: 
			[(trueScope at: key) == (falseScope at: key) 
			    ifTrue: [self currentScope at: key put: (trueScope at: key)]
			    ifFalse: 
				[((trueScope at: key) == true or: [(falseScope at: key) == true]) 
				    ifTrue: [self currentScope at: key put: true]]]]
    ]

    processStatementNode: aNode [
	<category: 'private'>
	| temps |
	(checkNewTemps not or: [aNode temporaries isEmpty]) 
	    ifTrue: 
		[aNode statements do: [:each | self executeTree: each].
		^self].
	self createScope.
	temps := aNode temporaries collect: [:each | each name].
	self initializeVars: temps.
	aNode statements do: [:each | self executeTree: each].
	self removeScope keysAndValuesDo: 
		[:key :value | 
		(temps includes: key) 
		    ifTrue: [value == true ifTrue: [read add: key]]
		    ifFalse: 
			[(self currentScope at: key) isNil 
			    ifTrue: [self currentScope at: key put: value]]]
    ]

    removeScope [
	<category: 'private'>
	^scopeStack removeLast
    ]

    variableRead: aNode [
	<category: 'private'>
	(self currentScope includesKey: aNode name) 
	    ifTrue: 
		[(self currentScope at: aNode name) isNil 
		    ifTrue: [self currentScope at: aNode name put: true]]
    ]

    variableWritten: aNode [
	<category: 'private'>
	(self currentScope includesKey: aNode variable name) 
	    ifTrue: 
		[(self currentScope at: aNode variable name) isNil 
		    ifTrue: [self currentScope at: aNode variable name put: false]]
    ]
]



Object subclass: RBParseTreeRule [
    | searchTree owner |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBParseTreeRule class >> methodSearch: aString [
	<category: 'instance creation'>
	^(self new)
	    methodSearchString: aString;
	    yourself
    ]

    RBParseTreeRule class >> new [
	<category: 'instance creation'>
	^(super new)
	    initialize;
	    yourself
    ]

    RBParseTreeRule class >> search: aString [
	<category: 'instance creation'>
	^(self new)
	    searchString: aString;
	    yourself
    ]

    initialize [
	<category: 'initialize-release'>
	
    ]

    methodSearchString: aString [
	<category: 'initialize-release'>
	searchTree := RBParser parseRewriteMethod: aString
    ]

    owner: aParseTreeSearcher [
	<category: 'initialize-release'>
	owner := aParseTreeSearcher
    ]

    searchString: aString [
	<category: 'initialize-release'>
	searchTree := RBParser parseRewriteExpression: aString
    ]

    canMatch: aProgramNode [
	<category: 'matching'>
	^true
    ]

    foundMatchFor: aProgramNode [
	<category: 'matching'>
	^aProgramNode
    ]

    performOn: aProgramNode [
	<category: 'matching'>
	self context empty.
	^((searchTree match: aProgramNode inContext: self context) 
	    and: [self canMatch: aProgramNode]) 
		ifTrue: 
		    [owner recusivelySearchInContext.
		    self foundMatchFor: aProgramNode]
		ifFalse: [nil]
    ]

    context [
	<category: 'private'>
	^owner context
    ]
]



LookupTable subclass: RBSmallDictionary [
    
    <shape: #pointer>
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBSmallDictionary class >> new [
	<category: 'instance creation'>
	^self new: 2
    ]

    RBSmallDictionary class >> new: anInteger [
	<category: 'instance creation'>
	^(self primNew: anInteger) initialize: anInteger
    ]

    capacity [
	<category: 'private'>
	^super primSize
    ]

    whileGrowingAt: key put: value [
	<category: 'private'>
	tally := tally + 1.
	self primAt: self size put: key.
	self valueAt: self size put: value
    ]

    incrementTally [
	<category: 'private'>
	tally := tally + 1.
	^(tally > self primSize)
	    ifTrue: [self grow];
	    yourself
    ]

    findIndex: anObject [
	"Tries to see if anObject exists as an indexed variable. As soon as nil
	 or anObject is found, the index of that slot is answered"

	<category: 'private'>
	| element |
	1 to: self size
	    do: 
		[:i | 
		element := self primAt: i.
		(element isNil or: [element = anObject]) ifTrue: [^i]].
	tally = self primSize ifTrue: [self grow].
	^self size + 1
    ]
]



RBProgramNodeVisitor subclass: ParseTreeSearcher [
    | searches answer argumentSearches context |
    
    <comment: 'ParseTreeSearcher walks over a normal source code parse tree using the visitor pattern, and then matches these nodes against the meta-nodes using the match:inContext: methods defined for the meta-nodes.

Instance Variables:
    answer    <Object>    the "answer" that is propagated between matches
    argumentSearches    <Collection of: (Association key: RBProgramNode value: BlockClosure)>    argument searches (search for the RBProgramNode and perform the BlockClosure when its found)
    context    <RBSmallDictionary>    a dictionary that contains what each meta-node matches against. This could be a normal Dictionary that is created for each search, but is created once and reused (efficiency).
    searches    <Collection of: (Association key: RBProgramNode value: BlockClosure)>    non-argument searches (search for the RBProgramNode and perform the BlockClosure when its found)'>
    <category: 'Refactory-Parser'>

    ParseTreeSearcher class >> treeMatching: aString in: aParseTree [
	<category: 'accessing'>
	(self new)
	    matches: aString do: [:aNode :answer | ^aNode];
	    executeTree: aParseTree.
	^nil
    ]

    ParseTreeSearcher class >> treeMatchingStatements: aString in: aParseTree [
	<category: 'accessing'>
	| notifier tree lastIsReturn |
	notifier := self new.
	tree := RBParser parseExpression: aString.
	lastIsReturn := tree lastIsReturn.
	notifier matches: (lastIsReturn 
		    ifTrue: ['| `@temps | `@.S1. ' , tree formattedCode]
		    ifFalse: ['| `@temps | `@.S1. ' , tree formattedCode , '. `@.S2'])
	    do: [:aNode :answer | ^tree].
	notifier executeTree: aParseTree.
	^nil
    ]

    ParseTreeSearcher class >> getterMethod: aVarName [
	<category: 'instance creation'>
	^(self new)
	    matchesMethod: '`method ^' , aVarName do: [:aNode :ans | aNode selector];
	    yourself
    ]

    ParseTreeSearcher class >> justSendsSuper [
	<category: 'instance creation'>
	^(self new)
	    matchesAnyMethodOf: #('`@method: `@Args ^super `@method: `@Args' '`@method: `@Args super `@method: `@Args')
		do: [:aNode :ans | true];
	    yourself
    ]

    ParseTreeSearcher class >> returnSetterMethod: aVarName [
	<category: 'instance creation'>
	^(self new)
	    matchesMethod: '`method: `Arg ^' , aVarName , ' := `Arg'
		do: [:aNode :ans | aNode selector];
	    yourself
    ]

    ParseTreeSearcher class >> setterMethod: aVarName [
	<category: 'instance creation'>
	^(self new)
	    matchesAnyMethodOf: (Array with: '`method: `Arg ' , aVarName , ' := `Arg'
			with: '`method: `Arg ^' , aVarName , ' := `Arg')
		do: [:aNode :ans | aNode selector];
	    yourself
    ]

    ParseTreeSearcher class >> buildSelectorString: aSelector [
	<category: 'private'>
	| stream keywords |
	aSelector numArgs = 0 ifTrue: [^aSelector].
	stream := WriteStream on: String new.
	keywords := aSelector keywords.
	1 to: keywords size
	    do: 
		[:i | 
		stream
		    nextPutAll: (keywords at: i);
		    nextPutAll: ' ``@arg';
		    nextPutAll: i printString;
		    nextPut: $ ].
	^stream contents
    ]

    ParseTreeSearcher class >> buildSelectorTree: aSelector [
	<category: 'private'>
	^RBParser parseRewriteExpression: '``@receiver ' 
		    , (self buildSelectorString: aSelector)
	    onError: [:err :pos | ^nil]
    ]

    ParseTreeSearcher class >> buildTree: aString method: aBoolean [
	<category: 'private'>
	^aBoolean 
	    ifTrue: [RBParser parseRewriteMethod: aString]
	    ifFalse: [RBParser parseRewriteExpression: aString]
    ]

    addArgumentRule: aParseTreeRule [
	<category: 'accessing'>
	argumentSearches add: aParseTreeRule.
	aParseTreeRule owner: self
    ]

    addArgumentRules: ruleCollection [
	<category: 'accessing'>
	ruleCollection do: [:each | self addArgumentRule: each]
    ]

    addRule: aParseTreeRule [
	<category: 'accessing'>
	searches add: aParseTreeRule.
	aParseTreeRule owner: self
    ]

    addRules: ruleCollection [
	<category: 'accessing'>
	ruleCollection do: [:each | self addRule: each]
    ]

    answer [
	<category: 'accessing'>
	^answer
    ]

    context [
	<category: 'accessing'>
	^context
    ]

    executeMethod: aParseTree initialAnswer: anObject [
	<category: 'accessing'>
	answer := anObject.
	searches detect: [:each | (each performOn: aParseTree) notNil] ifNone: [].
	^answer
    ]

    executeTree: aParseTree [
	"Save our current context, in case someone is performing another search inside a match."

	<category: 'accessing'>
	| oldContext |
	oldContext := context.
	context := RBSmallDictionary new.
	self visitNode: aParseTree.
	context := oldContext.
	^answer
    ]

    executeTree: aParseTree initialAnswer: aValue [
	<category: 'accessing'>
	answer := aValue.
	^self executeTree: aParseTree
    ]

    answer: anObject [
	<category: 'initialize-release'>
	answer := anObject
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	context := RBSmallDictionary new.
	searches := OrderedCollection new.
	argumentSearches := OrderedCollection new: 0.
	answer := nil
    ]

    matches: aString do: aBlock [
	<category: 'searching'>
	self addRule: (RBSearchRule searchFor: aString thenDo: aBlock)
    ]

    matchesAnyArgumentOf: stringCollection do: aBlock [
	<category: 'searching'>
	stringCollection do: [:each | self matchesArgument: each do: aBlock]
    ]

    matchesAnyMethodOf: aStringCollection do: aBlock [
	<category: 'searching'>
	aStringCollection do: [:each | self matchesMethod: each do: aBlock]
    ]

    matchesAnyOf: aStringCollection do: aBlock [
	<category: 'searching'>
	aStringCollection do: [:each | self matches: each do: aBlock]
    ]

    matchesAnyTreeOf: treeCollection do: aBlock [
	<category: 'searching'>
	treeCollection do: [:each | self matchesTree: each do: aBlock]
    ]

    matchesArgument: aString do: aBlock [
	<category: 'searching'>
	self addArgumentRule: (RBSearchRule searchFor: aString thenDo: aBlock)
    ]

    matchesArgumentTree: aRBProgramNode do: aBlock [
	<category: 'searching'>
	self 
	    addArgumentRule: (RBSearchRule searchForTree: aRBProgramNode thenDo: aBlock)
    ]

    matchesMethod: aString do: aBlock [
	<category: 'searching'>
	self addRule: (RBSearchRule searchForMethod: aString thenDo: aBlock)
    ]

    matchesTree: aRBProgramNode do: aBlock [
	<category: 'searching'>
	self addRule: (RBSearchRule searchForTree: aRBProgramNode thenDo: aBlock)
    ]

    foundMatch [
	<category: 'private'>
	
    ]

    lookForMoreMatchesInContext: oldContext [
	<category: 'private'>
	oldContext keysAndValuesDo: 
		[:key :value | 
		(key isString not and: [key recurseInto]) 
		    ifTrue: [value do: [:each | self visitNode: each]]]
    ]

    performSearches: aSearchCollection on: aNode [
	<category: 'private'>
	| value |
	1 to: aSearchCollection size
	    do: 
		[:i | 
		value := (aSearchCollection at: i) performOn: aNode.
		value notNil 
		    ifTrue: 
			[self foundMatch.
			^value]].
	^nil
    ]

    recusivelySearchInContext [
	"We need to save the matched context since the other searches might overwrite it."

	<category: 'private'>
	| oldContext |
	oldContext := context.
	context := RBSmallDictionary new.
	self lookForMoreMatchesInContext: oldContext.
	context := oldContext
    ]

    visitArgument: aNode [
	<category: 'visiting'>
	| value |
	value := self performSearches: argumentSearches on: aNode.
	^value isNil 
	    ifTrue: 
		[aNode acceptVisitor: self.
		aNode]
	    ifFalse: [value]
    ]

    visitNode: aNode [
	<category: 'visiting'>
	| value |
	value := self performSearches: searches on: aNode.
	^value isNil 
	    ifTrue: 
		[aNode acceptVisitor: self.
		aNode]
	    ifFalse: [value]
    ]

    addArgumentSearch: aSearchCondition [
	<category: 'obsolete'>
	self addArgumentRule: (self buildParseTreeRuleFor: aSearchCondition)
    ]

    addArgumentSearches: aSearchCondition [
	<category: 'obsolete'>
	aSearchCondition key 
	    do: [:each | self addArgumentSearch: each -> aSearchCondition value]
    ]

    addMethodSearch: aSearchCondition [
	<category: 'obsolete'>
	self addRule: (self buildMethodParseTreeRuleFor: aSearchCondition)
    ]

    addMethodSearches: aSearchCondition [
	<category: 'obsolete'>
	aSearchCondition key 
	    do: [:each | self addMethodSearch: each -> aSearchCondition value]
    ]

    addSearch: aSearchCondition [
	<category: 'obsolete'>
	self addRule: (self buildParseTreeRuleFor: aSearchCondition)
    ]

    addSearches: aSearchCondition [
	<category: 'obsolete'>
	aSearchCondition key 
	    do: [:each | self addSearch: each -> aSearchCondition value]
    ]

    buildMethodParseTreeRuleFor: aSearchCondition [
	<category: 'obsolete'>
	^(aSearchCondition key isKindOf: RBProgramNode) 
	    ifTrue: 
		[RBSearchRule searchForTree: aSearchCondition key
		    thenDo: aSearchCondition value]
	    ifFalse: 
		[RBSearchRule searchForMethod: aSearchCondition key
		    thenDo: aSearchCondition value]
    ]

    buildParseTreeRuleFor: aSearchCondition [
	<category: 'obsolete'>
	^(aSearchCondition key isKindOf: RBProgramNode) 
	    ifTrue: 
		[RBSearchRule searchForTree: aSearchCondition key
		    thenDo: aSearchCondition value]
	    ifFalse: 
		[RBSearchRule searchFor: aSearchCondition key thenDo: aSearchCondition value]
    ]
]



RBParseTreeRule subclass: RBSearchRule [
    | answerBlock |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBSearchRule class >> searchFor: aString thenDo: aBlock [
	<category: 'instance creation'>
	^self new searchFor: aString thenDo: aBlock
    ]

    RBSearchRule class >> searchForMethod: aString thenDo: aBlock [
	<category: 'instance creation'>
	^self new searchForMethod: aString thenDo: aBlock
    ]

    RBSearchRule class >> searchForTree: aRBProgramNode thenDo: aBlock [
	<category: 'instance creation'>
	^self new searchForTree: aRBProgramNode thenDo: aBlock
    ]

    searchFor: aString thenDo: aBlock [
	<category: 'initialize-release'>
	self searchString: aString.
	answerBlock := aBlock
    ]

    searchForMethod: aString thenDo: aBlock [
	<category: 'initialize-release'>
	self methodSearchString: aString.
	answerBlock := aBlock
    ]

    searchForTree: aRBProgramNode thenDo: aBlock [
	<category: 'initialize-release'>
	searchTree := aRBProgramNode.
	answerBlock := aBlock
    ]

    canMatch: aProgramNode [
	<category: 'testing'>
	owner answer: (answerBlock value: aProgramNode value: owner answer).
	^true
    ]
]



RBParseTreeRule subclass: RBReplaceRule [
    | verificationBlock |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    initialize [
	<category: 'initialize-release'>
	super initialize.
	verificationBlock := [:aNode | true]
    ]

    canMatch: aProgramNode [
	<category: 'matching'>
	^verificationBlock value: aProgramNode
    ]

    foundMatchFor: aProgramNode [
	<category: 'matching'>
	self subclassResponsibility
    ]
]



ParseTreeSearcher subclass: ParseTreeRewriter [
    | tree |
    
    <comment: 'ParseTreeRewriter walks over and transforms its RBProgramNode (tree). If the tree is modified, then answer is set to true, and the modified tree can be retrieved by the #tree method.

Instance Variables:
    tree    <RBProgramNode>    the parse tree we''re transforming'>
    <category: 'Refactory-Parser'>

    ParseTreeRewriter class >> replace: code with: newCode in: aParseTree [
	<category: 'accessing'>
	^(self 
	    replace: code
	    with: newCode
	    method: false)
	    executeTree: aParseTree;
	    tree
    ]

    ParseTreeRewriter class >> replace: code with: newCode in: aParseTree onInterval: anInterval [
	<category: 'accessing'>
	| rewriteRule |
	rewriteRule := self new.
	^rewriteRule
	    replace: code
		with: newCode
		when: [:aNode | aNode intersectsInterval: anInterval];
	    executeTree: aParseTree;
	    tree
    ]

    ParseTreeRewriter class >> replaceStatements: code with: newCode in: aParseTree onInterval: anInterval [
	<category: 'accessing'>
	| tree searchStmt replaceStmt |
	tree := self buildTree: code method: false.
	tree lastIsReturn 
	    ifTrue: 
		[searchStmt := '| `@temps | `@.Statements. ' , code.
		replaceStmt := '| `@temps | `@.Statements. ^' , newCode]
	    ifFalse: 
		[searchStmt := '| `@temps | `@.Statements1. ' , code , '.  `@.Statements2'.
		replaceStmt := '| `@temps | `@.Statements1. ' , newCode 
			    , '.  `@.Statements2'].
	^self 
	    replace: searchStmt
	    with: replaceStmt
	    in: aParseTree
	    onInterval: anInterval
    ]

    ParseTreeRewriter class >> classVariable: aVarName getter: getMethod setter: setMethod [
	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	rewriteRule
	    replace: aVarName , ' := ``@object'
		with: 'self class ' , setMethod , ' ``@object';
	    replace: aVarName with: 'self class ' , getMethod.
	^rewriteRule
    ]

    ParseTreeRewriter class >> removeTemporaryNamed: aName [
	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	rewriteRule replace: '| `@temps1 ' , aName , ' `@temps2 | ``@.Statements'
	    with: '| `@temps1  `@temps2 | ``@.Statements'.
	^rewriteRule
    ]

    ParseTreeRewriter class >> rename: varName to: newVarName [
	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	rewriteRule
	    replace: varName with: newVarName;
	    replaceArgument: varName with: newVarName.
	^rewriteRule
    ]

    ParseTreeRewriter class >> rename: varName to: newVarName handler: aBlock [
	"Rename varName to newVarName, evaluating aBlock if there is a
	 temporary variable with the same name as newVarName. This
	 does not change temporary variables with varName."

	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	rewriteRule
	    replace: varName with: newVarName;
	    replaceArgument: newVarName
		withValueFrom: 
		    [:aNode | 
		    aBlock value.
		    aNode].
	^rewriteRule
    ]

    ParseTreeRewriter class >> replace: code with: newCode method: aBoolean [
	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	aBoolean 
	    ifTrue: [rewriteRule replaceMethod: code with: newCode]
	    ifFalse: [rewriteRule replace: code with: newCode].
	^rewriteRule
    ]

    ParseTreeRewriter class >> replaceLiteral: literal with: newLiteral [
	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	rewriteRule 
	    replace: '`#literal'
	    withValueFrom: [:aNode | aNode]
	    when: 
		[:aNode | 
		self 
		    replaceLiteral: literal
		    with: newLiteral
		    inToken: aNode token].
	^rewriteRule
    ]

    ParseTreeRewriter class >> variable: aVarName getter: getMethod setter: setMethod [
	<category: 'instance creation'>
	| rewriteRule |
	rewriteRule := self new.
	rewriteRule
	    replace: aVarName , ' := ``@object'
		with: 'self ' , setMethod , ' ``@object';
	    replace: aVarName with: 'self ' , getMethod.
	^rewriteRule
    ]

    ParseTreeRewriter class >> replaceLiteral: literal with: newLiteral inToken: literalToken [
	<category: 'private'>
	| value |
	value := literalToken realValue.
	value == literal 
	    ifTrue: 
		[literalToken 
		    value: newLiteral
		    start: nil
		    stop: nil.
		^true].
	^value class == Array and: 
		[literalToken value inject: false
		    into: 
			[:bool :each | 
			bool | (self 
				    replaceLiteral: literal
				    with: newLiteral
				    inToken: each)]]
    ]

    executeTree: aParseTree [
	<category: 'accessing'>
	| oldContext |
	oldContext := context.
	context := RBSmallDictionary new.
	answer := false.
	tree := self visitNode: aParseTree.
	context := oldContext.
	^answer
    ]

    tree [
	<category: 'accessing'>
	^tree
    ]

    replace: searchString with: replaceString [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule searchFor: searchString
		    replaceWith: replaceString)
    ]

    replace: searchString with: replaceString when: aBlock [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule 
		    searchFor: searchString
		    replaceWith: replaceString
		    when: aBlock)
    ]

    replace: searchString withValueFrom: replaceBlock [
	<category: 'replacing'>
	self addRule: (RBBlockReplaceRule searchFor: searchString
		    replaceWith: replaceBlock)
    ]

    replace: searchString withValueFrom: replaceBlock when: conditionBlock [
	<category: 'replacing'>
	self addRule: (RBBlockReplaceRule 
		    searchFor: searchString
		    replaceWith: replaceBlock
		    when: conditionBlock)
    ]

    replaceArgument: searchString with: replaceString [
	<category: 'replacing'>
	self addArgumentRule: (RBStringReplaceRule searchFor: searchString
		    replaceWith: replaceString)
    ]

    replaceArgument: searchString with: replaceString when: aBlock [
	<category: 'replacing'>
	self addArgumentRule: (RBStringReplaceRule 
		    searchFor: searchString
		    replaceWith: replaceString
		    when: aBlock)
    ]

    replaceArgument: searchString withValueFrom: replaceBlock [
	<category: 'replacing'>
	self addArgumentRule: (RBBlockReplaceRule searchFor: searchString
		    replaceWith: replaceBlock)
    ]

    replaceArgument: searchString withValueFrom: replaceBlock when: conditionBlock [
	<category: 'replacing'>
	self addArgumentRule: (RBBlockReplaceRule 
		    searchFor: searchString
		    replaceWith: replaceBlock
		    when: conditionBlock)
    ]

    replaceMethod: searchString with: replaceString [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule searchForMethod: searchString
		    replaceWith: replaceString)
    ]

    replaceMethod: searchString with: replaceString when: aBlock [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule 
		    searchForMethod: searchString
		    replaceWith: replaceString
		    when: aBlock)
    ]

    replaceMethod: searchString withValueFrom: replaceBlock [
	<category: 'replacing'>
	self addRule: (RBBlockReplaceRule searchForMethod: searchString
		    replaceWith: replaceBlock)
    ]

    replaceMethod: searchString withValueFrom: replaceBlock when: conditionBlock [
	<category: 'replacing'>
	self addRule: (RBBlockReplaceRule 
		    searchForMethod: searchString
		    replaceWith: replaceBlock
		    when: conditionBlock)
    ]

    replaceTree: searchTree withTree: replaceTree [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule searchForTree: searchTree
		    replaceWith: replaceTree)
    ]

    replaceTree: searchTree withTree: replaceTree when: aBlock [
	<category: 'replacing'>
	self addRule: (RBStringReplaceRule 
		    searchForTree: searchTree
		    replaceWith: replaceTree
		    when: aBlock)
    ]

    foundMatch [
	<category: 'private'>
	answer := true
    ]

    lookForMoreMatchesInContext: oldContext [
	<category: 'private'>
	oldContext keysAndValuesDo: 
		[:key :value | 
		| newValue |
		(key isString not and: [key recurseInto]) 
		    ifTrue: 
			["Of course, the following statement does nothing without the `deepCopy'
			 which fixes the bug."

			newValue := oldContext at: key put: value deepCopy.	"<<<"
			self visitNodes: newValue
			    onMatch: [:newValue | oldContext at: key put: newValue]]]
    ]

    visitNode: aNode [
	<category: 'visiting'>
	^self 
	    visitNode: aNode
	    searches: searches
	    onMatch: [:newNode | ]
    ]

    visitNode: aNode onMatch: aBlock [
	<category: 'visiting'>
	^self 
	    visitNode: aNode
	    searches: searches
	    onMatch: aBlock
    ]

    visitNodes: aNodeList [
	<category: 'visiting'>
	^self visitNodes: aNodeList onMatch: [:newNodes | ]
    ]

    visitNodes: aNodeList onMatch: aBlock [
	<category: 'visiting'>
	^self 
	    visitNodes: aNodeList
	    searches: searches
	    onMatch: aBlock
    ]

    visitArgument: aNode [
	<category: 'visiting'>
	^self 
	    visitNode: aNode
	    searches: argumentSearches
	    onMatch: [:newNode | ]
    ]

    visitArguments: aNodeList [
	<category: 'visiting'>
	^self visitArguments: aNodeList onMatch: [:newNodes | ]
    ]

    visitArguments: aNodeList onMatch: aBlock [
	<category: 'visiting'>
	^self 
	    visitNodes: aNodeList
	    searches: argumentSearches
	    onMatch: aBlock
    ]

    visitNode: aNode searches: theseSearches onMatch: aBlock [
	"Visit aNode, sending visitNode:'s answer to aBlock if
	 performSearches:on: finds a match."

	<category: 'visiting'>
	| newNode |
	newNode := self performSearches: theseSearches on: aNode.
	^newNode isNil 
	    ifTrue: 
		[aNode acceptVisitor: self.
		aNode]
	    ifFalse: 
		[aBlock value: newNode.
		newNode]
    ]

    visitNodes: aNodeList searches: theseSearches onMatch: aBlock [
	"Answer aNodeList but with each element replaced by the result of
	 visitNode:onMatch: with said element (and a block of my own).  If
	 any matches occur, I'll call aBlock afterwards with the
	 replacement of aNodeList before answering it."

	<category: 'visiting'>
	| replacementList rlHasMatch |
	rlHasMatch := false.
	replacementList := aNodeList collect: 
			[:eltNode | 
			self 
			    visitNode: eltNode
			    searches: theseSearches
			    onMatch: [:newElt | rlHasMatch := true]].
	^rlHasMatch 
	    ifTrue: 
		[aBlock value: replacementList.
		replacementList]
	    ifFalse: [aNodeList]
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anAssignmentNode variable
	    onMatch: [:newField | anAssignmentNode variable: newField].
	self visitNode: anAssignmentNode value
	    onMatch: [:newField | anAssignmentNode value: newField]
    ]

    acceptArrayConstructorNode: anArrayNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anArrayNode body
	    onMatch: [:newField | anArrayNode body: newField]
    ]

    acceptBlockNode: aBlockNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aBlockNode arguments
	    onMatch: [:newField | aBlockNode arguments: newField].
	self visitNode: aBlockNode body
	    onMatch: [:newField | aBlockNode body: newField]
    ]

    searchCascadeNodeMessage: aMessageNode messagesTo: newMessages [
	"Helper for acceptCascadeNode: -- descend to aMessageNode, but no
	 further.  Add the resulting message or cascade of messages from
	 the tree rule's foundMatchFor: to newMessages and answer said
	 result if a match is found.  Add aMessageNode to newMessages and
	 answer nil otherwise."

	<category: 'visitor-double dispatching'>
	| answer newNode |
	answer := self performSearches: searches on: aMessageNode.
	newNode := answer ifNil: [aMessageNode].
	newNode isCascade 
	    ifTrue: [newMessages addAll: newNode messages]
	    ifFalse: 
		[newMessages add: (newNode isMessage 
			    ifTrue: [newNode]
			    ifFalse: 
				[Warning 
				    signal: 'Cannot replace message node inside of cascaded node with non-message node'.
				answer := nil.	"<<<"
				aMessageNode])].
	^answer
    ]

    acceptCascadeNode: aCascadeNode [
	<category: 'visitor-double dispatching'>
	| newMessages notFound |
	newMessages := OrderedCollection new: aCascadeNode messages size.
	notFound := OrderedCollection new: aCascadeNode messages size.
	aCascadeNode messages do: 
		[:each | 
		(self searchCascadeNodeMessage: each messagesTo: newMessages) isNil 
		    ifTrue: [notFound add: each]].

	"Rewrite the receiver once and distribute it among the messages if
	 no replacements were made."
	notFound size == aCascadeNode messages size 
	    ifTrue: 
		[self visitNode: aCascadeNode messages first receiver
		    onMatch: [:receiver | newMessages do: [:each | each receiver: receiver]]].
	notFound do: 
		[:each | 
		self visitNodes: each arguments
		    onMatch: [:newArgs | each arguments: newArgs]].
	aCascadeNode messages: newMessages
    ]

    acceptMessageNode: aMessageNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aMessageNode receiver
	    onMatch: [:newField | aMessageNode receiver: newField].
	self visitNodes: aMessageNode arguments
	    onMatch: [:newField | aMessageNode arguments: newField]
    ]

    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aMethodNode arguments
	    onMatch: [:newField | aMethodNode arguments: newField].
	self visitNode: aMethodNode body
	    onMatch: [:newField | aMethodNode body: newField]
    ]

    acceptOptimizedNode: anOptimizedNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anOptimizedNode body
	    onMatch: [:newField | anOptimizedNode body: newField]
    ]

    acceptReturnNode: aReturnNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aReturnNode value
	    onMatch: [:newField | aReturnNode value: newField]
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aSequenceNode temporaries
	    onMatch: [:newField | aSequenceNode temporaries: newField].
	self visitNodes: aSequenceNode statements
	    onMatch: [:newField | aSequenceNode statements: newField]
    ]
]



RBReplaceRule subclass: RBStringReplaceRule [
    | replaceTree |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBStringReplaceRule class >> searchFor: searchString replaceWith: replaceString [
	<category: 'instance creation'>
	^self new searchFor: searchString replaceWith: replaceString
    ]

    RBStringReplaceRule class >> searchFor: searchString replaceWith: replaceString when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchFor: searchString
	    replaceWith: replaceString
	    when: aBlock
    ]

    RBStringReplaceRule class >> searchForMethod: searchString replaceWith: replaceString [
	<category: 'instance creation'>
	^self new searchForMethod: searchString replaceWith: replaceString
    ]

    RBStringReplaceRule class >> searchForMethod: searchString replaceWith: replaceString when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchForMethod: searchString
	    replaceWith: replaceString
	    when: aBlock
    ]

    RBStringReplaceRule class >> searchForTree: searchString replaceWith: replaceString [
	<category: 'instance creation'>
	^self new searchForTree: searchString replaceWith: replaceString
    ]

    RBStringReplaceRule class >> searchForTree: searchString replaceWith: replaceString when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchForTree: searchString
	    replaceWith: replaceString
	    when: aBlock
    ]

    methodReplaceString: replaceString [
	<category: 'initialize-release'>
	replaceTree := RBParser parseRewriteMethod: replaceString
    ]

    replaceString: replaceString [
	<category: 'initialize-release'>
	replaceTree := RBParser parseRewriteExpression: replaceString.
	searchTree isSequence = replaceTree isSequence 
	    ifFalse: 
		[searchTree isSequence 
		    ifTrue: [replaceTree := RBSequenceNode statements: (Array with: replaceTree)]
		    ifFalse: [searchTree := RBSequenceNode statements: (Array with: searchTree)]]
    ]

    searchFor: searchString replaceWith: replaceString [
	<category: 'initialize-release'>
	self searchString: searchString.
	self replaceString: replaceString
    ]

    searchFor: searchString replaceWith: replaceString when: aBlock [
	<category: 'initialize-release'>
	self searchFor: searchString replaceWith: replaceString.
	verificationBlock := aBlock
    ]

    searchForMethod: searchString replaceWith: replaceString [
	<category: 'initialize-release'>
	self methodSearchString: searchString.
	self methodReplaceString: replaceString
    ]

    searchForMethod: searchString replaceWith: replaceString when: aBlock [
	<category: 'initialize-release'>
	self searchForMethod: searchString replaceWith: replaceString.
	verificationBlock := aBlock
    ]

    searchForTree: aRBProgramNode replaceWith: replaceNode [
	<category: 'initialize-release'>
	searchTree := aRBProgramNode.
	replaceTree := replaceNode
    ]

    searchForTree: aRBProgramNode replaceWith: replaceString when: aBlock [
	<category: 'initialize-release'>
	self searchForTree: aRBProgramNode replaceWith: replaceString.
	verificationBlock := aBlock
    ]

    foundMatchFor: aProgramNode [
	<category: 'matching'>
	| newTree |
	newTree := replaceTree copyInContext: self context.
	newTree copyCommentsFrom: aProgramNode.
	^newTree
    ]
]



RBReplaceRule subclass: RBBlockReplaceRule [
    | replaceBlock |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBBlockReplaceRule class >> searchFor: searchString replaceWith: replaceBlock [
	<category: 'instance creation'>
	^self new searchFor: searchString replaceWith: replaceBlock
    ]

    RBBlockReplaceRule class >> searchFor: searchString replaceWith: replaceBlock when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchFor: searchString
	    replaceWith: replaceBlock
	    when: aBlock
    ]

    RBBlockReplaceRule class >> searchForMethod: searchString replaceWith: replaceBlock [
	<category: 'instance creation'>
	^self new searchForMethod: searchString replaceWith: replaceBlock
    ]

    RBBlockReplaceRule class >> searchForMethod: searchString replaceWith: replaceBlock when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchForMethod: searchString
	    replaceWith: replaceBlock
	    when: aBlock
    ]

    RBBlockReplaceRule class >> searchForTree: searchString replaceWith: replaceBlock [
	<category: 'instance creation'>
	^self new searchForTree: searchString replaceWith: replaceBlock
    ]

    RBBlockReplaceRule class >> searchForTree: searchString replaceWith: replaceBlock when: aBlock [
	<category: 'instance creation'>
	^self new 
	    searchFor: searchString
	    replaceWith: replaceBlock
	    when: aBlock
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	replaceBlock := [:aNode | aNode]
    ]

    searchFor: searchString replaceWith: aBlock [
	<category: 'initialize-release'>
	self searchString: searchString.
	replaceBlock := aBlock
    ]

    searchFor: searchString replaceWith: replBlock when: verifyBlock [
	<category: 'initialize-release'>
	self searchFor: searchString replaceWith: replBlock.
	verificationBlock := verifyBlock
    ]

    searchForMethod: searchString replaceWith: aBlock [
	<category: 'initialize-release'>
	self methodSearchString: searchString.
	replaceBlock := aBlock
    ]

    searchForMethod: searchString replaceWith: replBlock when: verifyBlock [
	<category: 'initialize-release'>
	self searchForMethod: searchString replaceWith: replBlock.
	verificationBlock := verifyBlock
    ]

    searchForTree: aRBProgramNode replaceWith: aBlock [
	<category: 'initialize-release'>
	searchTree := aRBProgramNode.
	replaceBlock := aBlock
    ]

    searchForTree: aRBProgramNode replaceWith: replBlock when: verifyBlock [
	<category: 'initialize-release'>
	self searchForTree: aRBProgramNode replaceWith: replBlock.
	verificationBlock := verifyBlock
    ]

    foundMatchFor: aProgramNode [
	<category: 'matching'>
	^replaceBlock value: aProgramNode
    ]
]

PK
     �Mh@ǿATI(  I(    OrderedSet.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   OrderedSet Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) 2007 Free Software Foundation, Inc.
| Written by Stephen Compall.
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



OrderedCollection subclass: OrderedSet [
    | unorderedSet |
    
    <shape: #pointer>
    <category: 'Collections-Sequenceable'>
    <comment: 'My instances represent sets of unique objects that may be accessed by
an arbitrary index.  Besides allowing addition, removal, and insertion
of objects at indexed locations in my instances, I impose the
invariant that a particular element cannot appear more than once.

This invariant leads to varying behavior, as in some cases it makes
sense to behave as an OrderedCollection, whereas in others it makes
more sense to behave as a Set.  For example, #collect: may answer an
OrderedSet with fewer elements than the receiver, #at:put: will signal
an error if its put: argument is already present as a different
element, and #with:with: may potentially answer an OrderedSet with
only one element.

I use a Set, called "unordered set", to decide whether an element is
already present.'>

    OrderedSet class >> identityNew: anInteger [
	"Answer an OrderedSet of size anInteger which uses #== to compare its
	 elements."

	<category: 'instance creation'>
	^self on: (IdentitySet new: anInteger)
    ]

    OrderedSet class >> new: anInteger [
	"Answer an OrderedSet of size anInteger."

	<category: 'instance creation'>
	^self on: (Set new: anInteger)
    ]

    OrderedSet class >> on: anEmptySet [
	"Answer an OrderedSet that uses anEmptySet as an unordered set to
	 maintain my set-property."

	<category: 'instance creation'>
	anEmptySet isEmpty ifFalse: [self error: 'expected empty collection'].
	^(super new: anEmptySet basicSize)
	    unorderedSet: anEmptySet;
	    yourself
    ]

    at: anIndex put: anObject [
	"Store anObject at the anIndex-th item of the receiver, answer
	 anObject.  Signal an error if anObject is already present as
	 another element of the receiver."

	<category: 'accessing'>
	| oldElement |
	oldElement := self at: anIndex.
	"Though it is somewhat inefficient to remove then possibly readd
	 the old element, the case is rare enough that the precision of
	 unorderedSet-based comparison is worth it."
	unorderedSet remove: oldElement.
	(unorderedSet includes: anObject) 
	    ifTrue: 
		[unorderedSet add: oldElement.
		^self error: 'anObject is already present'].
	unorderedSet add: anObject.
	^super at: anIndex put: anObject
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	unorderedSet := unorderedSet copy
    ]

    copyEmpty: newSize [
	"Answer an empty copy of the receiver."

	<category: 'copying'>
	^self species on: (unorderedSet copyEmpty: newSize)
    ]

    includes: anObject [
	"Answer whether anObject is one of my elements, according to my
	 'unordered set'."

	<category: 'searching for elements'>
	^unorderedSet includes: anObject
    ]

    occurrencesOf: anObject [
	"Answer how many of anObject I contain.  As I am a set, this is
	 always 0 or 1."

	<category: 'searching for elements'>
	^(self includes: anObject) ifTrue: [1] ifFalse: [0]
    ]

    indexOf: anElement startingAt: anIndex ifAbsent: exceptionBlock [
	"Answer the first index > anIndex which contains anElement.
	 Invoke exceptionBlock and answer its result if no item is found."

	<category: 'searching for elements'>
	^((self includes: anElement) 
	    or: [(anIndex between: 1 and: self size + 1) not]) 
		ifTrue: 
		    ["if anIndex isn't valid, super method will catch it.  Also,
		     super method may not find the element, which is fine"

		    super 
			indexOf: anElement
			startingAt: anIndex
			ifAbsent: exceptionBlock]
		ifFalse: [exceptionBlock value]
    ]

    add: anObject [
	"Add anObject in the receiver if it is not already present, and
	 answer it."

	<category: 'adding'>
	(unorderedSet includes: anObject) 
	    ifFalse: 
		[super add: anObject.
		unorderedSet add: anObject].
	^anObject
    ]

    add: newObject afterIndex: i [
	"Add newObject in the receiver just after the i-th, unless it is
	 already present, and answer it.  Fail if i < 0 or i > self size"

	<category: 'adding'>
	(unorderedSet includes: newObject) 
	    ifFalse: 
		[super add: newObject afterIndex: i.
		unorderedSet add: newObject].
	^newObject
    ]

    addAll: aCollection [
	"Add every item of aCollection to the receiver that is not already
	 present, and answer it."

	<category: 'adding'>
	^self addAllLast: aCollection
    ]

    addAll: newCollection afterIndex: i [
	"Add every item of newCollection to the receiver just after
	 the i-th, answer it. Fail if i < 0 or i > self size"

	<category: 'adding'>
	| index |
	(i between: 0 and: self size) 
	    ifFalse: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: i].
	index := i + firstIndex.
	self makeRoomLastFor: newCollection size.
	lastIndex to: index
	    by: -1
	    do: [:i | self basicAt: i + newCollection size put: (self basicAt: i)].
	lastIndex := lastIndex + newCollection size.
	newCollection do: 
		[:each | 
		(unorderedSet includes: each) 
		    ifFalse: 
			[unorderedSet add: each.
			self basicAt: index put: each.
			index := 1 + index]].
	self closeGapFrom: index - firstIndex + 1 to: i + newCollection size.
	^newCollection
    ]

    addAllFirst: aCollection [
	"Add every item of newCollection to the receiver right at the start
	 of the receiver. Answer aCollection"

	<category: 'adding'>
	| index |
	self makeRoomFirstFor: aCollection size.
	firstIndex := index := firstIndex - aCollection size.
	aCollection do: 
		[:elt | 
		(unorderedSet includes: elt) 
		    ifFalse: 
			[self basicAt: index put: elt.
			unorderedSet add: elt.
			index := index + 1]].
	self closeGapFrom: index - firstIndex + 1 to: aCollection size.
	^aCollection
    ]

    addAllLast: aCollection [
	"Add every item of newCollection to the receiver right at the end
	 of the receiver. Answer aCollection"

	<category: 'adding'>
	"might be too big, but probably not too much"

	| index newElements newElementCount |
	self makeRoomLastFor: aCollection size.
	aCollection do: 
		[:element | 
		(unorderedSet includes: element) 
		    ifFalse: 
			[lastIndex := lastIndex + 1.
			self basicAt: lastIndex put: element.
			unorderedSet add: element]].
	^aCollection
    ]

    addFirst: newObject [
	"Add newObject to the receiver right at the start of the receiver,
	 unless it is already present as an element.  Answer newObject"

	<category: 'adding'>
	(unorderedSet includes: newObject) 
	    ifFalse: 
		[unorderedSet add: newObject.
		super addFirst: newObject].
	^newObject
    ]

    addLast: newObject [
	"Add newObject to the receiver right at the end of the receiver,
	 unless it is already present as an element.  Answer newObject"

	<category: 'adding'>
	(unorderedSet includes: newObject) 
	    ifFalse: 
		[unorderedSet add: newObject.
		super addLast: newObject].
	^newObject
    ]

    removeFirst [
	"Remove an object from the start of the receiver. Fail if the receiver
	 is empty"

	<category: 'removing'>
	^unorderedSet remove: super removeFirst
    ]

    removeLast [
	"Remove an object from the end of the receiver. Fail if the receiver
	 is empty."

	<category: 'removing'>
	^unorderedSet remove: super removeLast
    ]

    removeAtIndex: anIndex [
	"Remove the object at index anIndex from the receiver. Fail if the
	 index is out of bounds."

	<category: 'removing'>
	^unorderedSet remove: (super removeAtIndex: anIndex)
    ]

    closeGapFrom: gapStart to: gapEnd [
	"Remove all elements between gapStart and gapEnd, inclusive,
	 without modifying the unordered set.  I simply ignore this
	 message if gapStart or gapEnd is bad."

	<category: 'private methods'>
	"these vars are almost always exactly the current basic gap"

	| realStart realEnd |
	realStart := firstIndex + gapStart - 1.
	realEnd := firstIndex + gapEnd - 1.

	"trivial cases"
	(gapStart <= gapEnd and: 
		[(realStart between: firstIndex and: lastIndex) 
		    and: [realEnd between: firstIndex and: lastIndex]]) 
	    ifFalse: [^self].
	realEnd = lastIndex 
	    ifTrue: 
		[lastIndex := realStart - 1.
		^self].
	realStart = firstIndex 
	    ifTrue: 
		[firstIndex := realEnd + 1.
		^self].

	"shift from before?"
	gapStart - 1 < (lastIndex - realEnd) 
	    ifTrue: 
		[
		[self basicAt: realEnd put: (self basicAt: (realStart := realStart - 1)).
		realEnd := realEnd - 1.
		realStart = firstIndex] 
			whileFalse.
		firstIndex := realEnd + 1]
	    ifFalse: 
		["shift from after"

		
		[self basicAt: realStart put: (self basicAt: (realEnd := realEnd + 1)).
		realStart := realStart + 1.
		realEnd = lastIndex] 
			whileFalse.
		lastIndex := realStart - 1].
	"help the gc"
	realStart to: realEnd do: [:i | self basicAt: i put: nil]
    ]

    growBy: delta shiftBy: shiftCount [
	"This may be private to OrderedCollection, but its inlining of
	 new-instance filling breaks me."

	<category: 'private methods'>
	| uSet |
	uSet := unorderedSet.
	super growBy: delta shiftBy: shiftCount.
	"effectively copy after #become: invocation"
	unorderedSet := uSet
    ]

    unorderedSet: aSet [
	<category: 'private methods'>
	unorderedSet := aSet
    ]
]

PK
     �Mh@EA��`5  `5    GSTParser.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   GNU Smalltalk syntax parser
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
| Written by Daniele Sciascia.
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

STInST.STFileInParser subclass: GSTFileInParser [
    | taggee class currentDeclaration |

    parseStatements [
        | returnPosition statements node |
	"Skip temporaries."
        (currentToken isBinary and: [currentToken value == #|]) 
	    ifTrue: [ self step. self parseArgs. self step ].
        (currentToken isBinary and: [currentToken value == #||]) 
	    ifTrue: [ self step ].

        (currentToken isSpecial and: [currentToken value == $!]) 
	    ifTrue: [ ^RBSequenceNode statements: #() ].

        node := (currentToken isSpecial and: [currentToken value == $^]) 
            ifTrue: [returnPosition := currentToken start.  
                     self step.
                     RBReturnNode return: returnPosition value: self parseAssignment]
            ifFalse: [self parseAssignment].

        self addCommentsTo: node.
        ^RBSequenceNode statements: { node }
    ]

    parseDoits [
        "Parses the stuff to be executed until a closed bracket."

        <category: 'private-parsing'>
        | node |

        [self atEnd ifTrue: [^false].
        (currentToken isSpecial and: [currentToken value == $]])
	    ifTrue: [^false].

        node := self parseDoit.
        scanner stripSeparators.
        self evaluate: node]
                whileFalse:
                    [(currentToken isSpecial and: [currentToken value == $!])
                        ifTrue: [self step]].
        ^true
    ]

    parseDoit [
	| node |
	(taggee notNil and: [currentToken value = #<]) ifTrue:
	    [self parseClassTag. ^nil].
	node := super parseDoit.
        (currentToken isSpecial and: [ self skipToken: $[ ])
            ifTrue: [self parseDeclaration: node statements first. ^nil].

        currentToken isSpecial ifTrue: [ self skipToken: $. ].
	^node
    ]

    parseDeclaration: node [
        | decl |
	currentDeclaration := node parent.
        decl := node.
        decl isReturn ifTrue: [ decl := decl value ].
        decl isMessage ifTrue: [
            (decl selectorParts first value = 'subclass:')
                ifTrue: [self parseClass: decl. ^self].
            
            (decl selectorParts first value = 'extend')
                ifTrue: [self parseClassExtension: decl. ^self].
                
            ((decl receiver name = 'Namespace') 
                and: [decl selectorParts first value = 'current:' ])
                    ifTrue: [self parseNamespace: decl. ^self]].
        
        decl isVariable 
            ifTrue: [(decl name = 'Eval') 
                        ifTrue: [self parseEval. ^self]].
        
        self parserError: 'expected Eval, Namespace or class definition'
    ]
    
    parseEval [
        | stmts |
        stmts := self parseStatements: false.
        self skipExpectedToken: $].
        self evaluate: stmts.
    ]
    
    parseNamespace: node [   
        | namespace fullNamespace newNamespace |
        namespace := RBVariableNode
	    named: self driver currentNamespace name asString.
        fullNamespace := RBVariableNode
	    named: (self driver currentNamespace nameIn: Smalltalk).

	newNamespace := node arguments first name asSymbol.
	(self driver currentNamespace includesKey: newNamespace)
	    ifFalse: [
	        self evaluateMessageOn: namespace
	             selector: #addSubspace:
	             argument: node arguments first name asSymbol ].
           
        self evaluateStatement: node.       
	taggee := RBVariableNode named:
	    (self driver currentNamespace nameIn: Smalltalk).
        self parseDoits.
        self skipExpectedToken: $].

        "restore previous namespace"
	taggee := fullNamespace.
        node parent: nil.
        node arguments: { fullNamespace }.
        self evaluateStatement: node
    ]

    parseClassExtension: node [
        class := node receiver.
        self parseClassBody: true.
        class := nil
    ]
    
    parseClass: node [ 
        self evaluateMessageOn: (node receiver)
             selector: #subclass:environment:
             arguments: {node arguments first name asSymbol.
                         self driver currentNamespace}.
             
        class := node arguments first.
        self parseClassBody: false.
        class := nil.
    ]
    
    parseClassBody: extend [
	| addInstVars oldTaggee |
	oldTaggee := taggee.
	taggee := class.
	addInstVars := extend.
        [ self skipToken: $] ] whileFalse: [
	    addInstVars := self
		parseClassBodyElement: addInstVars
		withinExtend: extend ].
	taggee := oldTaggee.
    ]
    
    parseClassBodyElement: addInstVars withinExtend: extend [
        | node classNode |

	"drop comments"
        scanner getComments.
        
        "look for class tag"
        (currentToken value = #< and: [self nextToken isKeyword])
            ifTrue: [self parseClassTag. ^addInstVars].
        
        "look for class variable"
        (currentToken isIdentifier and: [self nextToken isAssignment])
            ifTrue: [self parseClassVariable. ^addInstVars].
            
        "class side"
        ((currentToken isIdentifier 
            and: [self nextToken isIdentifier])
            and: [self nextToken value = 'class'])
                ifTrue: [classNode := RBVariableNode identifierToken: currentToken.
                         self step.
    
                         (classNode = class)
                            ifTrue: ["look for class method"
                                     (self nextToken value = #>>)
                                        ifTrue: [self step. self step.
                                                 self parseMethodSourceOn: (self makeClassOf: classNode). 
                                                 ^addInstVars ].
                                            
                                     "look for metaclass"
                                     (self nextToken value = $[)
                                        ifTrue: [self parseMetaclass: extend.
                                                 ^addInstVars ].
                                        
                                     self parserError: 'invalid class body element'].
                          
                         "look for overriding class method"
                         self step.
                         (currentToken value = #>>)
                            ifTrue: ["TODO: check that classNode is a superclass of the current class"
                                     self step.
                                     self parseMethodSourceOn: (self makeClassOf: classNode).
                                     ^addInstVars]. 
                          
                          self parserError: 'invalid class body element' ].
                        
        "look for overriding method"
        (currentToken isIdentifier and: [self nextToken value = #>>])
            ifTrue: ["check that classNode is a superclass of the current class!!!"    
                     classNode := RBVariableNode identifierToken: currentToken.
                     self step. self step.
                     self parseMethodSourceOn: classNode.
                     ^addInstVars].
               
        node := self parseMessagePattern.
        
        "look for method"
        (self skipToken: $[)
            ifTrue: [self parseMethodSource: node. ^addInstVars].
        
        "look for instance variables"
        (node selectorParts first value = #|)
            ifTrue: [self parseInstanceVariables: node add: addInstVars. ^true].
            
        self parserError: 'invalid class body element'
    ]
    
    parseClassTag [
        | selector argument stmt |
        
        self skipExpectedToken: #<.
        
        (currentToken isKeyword)
            ifTrue: [selector := currentToken value asSymbol. self step]
            ifFalse: [self parserError: 'expected keyword'].
        
        argument := self parsePrimitiveObject.
        self skipExpectedToken: #>.
        
        stmt := RBMessageNode
    	             receiver: taggee
    	             selector: selector
    	             arguments: { argument }.
        self evaluateStatement: stmt.
    ]
    
    parseClassVariable [ 
        | node stmt name |
        
        node := self parseAssignment.
        node isAssignment
            ifFalse: [self parserError: 'expected assignment'].
        
        (self skipToken: $.) ifFalse: [
	    (currentToken value = $]) ifFalse: [
		self parserError: 'expected . or ]']].

        name := RBLiteralNode value: (node variable name asSymbol).
        node := self makeSequenceNode: node value.
        node := RBBlockNode body: node.
        
        stmt := RBMessageNode 
                receiver: class
                selector: #addClassVarName:value:
                arguments: { name . node }.

        self evaluateStatement: stmt.
    ]
    
    parseMetaclass: extend [
        | tmpClass |     
        
        self step. self step.
        tmpClass := class.
        class := self makeClassOf: class.
        self parseClassBody: extend.
        class := tmpClass
    ]
    
    parseMethodSource: patternNode [
        self parseMethodSource: patternNode on: class
    ]
    
    parseMethodSourceOn: classNode [
        | patternNode |
	"Drop comments before the message pattern"
        patternNode := self parseMessagePattern.
        self skipExpectedToken: $[.
        self parseMethodSource: patternNode on: classNode.
    ]
    
    parseMethodSource: patternNode on: classNode [
        | methodNode start stop |
        
        start := patternNode selectorParts first start - 1.
        methodNode := self parseMethodInto: patternNode.
        stop := currentToken start - 1.
        self skipExpectedToken: $].
        methodNode := self addSourceFrom: start to: stop to: methodNode.
        
        self evaluateMessageOn: classNode
             selector: #methodsFor:
             argument: nil.
        
        self compile: methodNode.
	self endMethodList.
    ]
    
    parseInstanceVariables: node add: addThem [
        | vars |
            
	vars := addThem
	    ifTrue: [
	        (self resolveClass: class) instVarNames
		    fold: [ :a :b | a, ' ', b ] ]
	    ifFalse: [ '' ].

        vars := vars, ' ', (node arguments at: 1) name.
        [currentToken isIdentifier]
            whileTrue: [vars := vars , ' ' , currentToken value.
        
                        self step ].       

        self skipExpectedToken: #|.
        self evaluateMessageOn: class 
             selector: #instanceVariableNames:
             argument: vars.
    ]
    
    evaluateMessageOn: rec selector: sel arguments: argSymbols [
        | stmt |
          
        stmt := RBMessageNode
            receiver: rec
            selector: sel
            arguments: (argSymbols collect: [:each | RBLiteralNode value: each]).
	    	    
        self evaluateStatement: stmt.
    ]
    
    evaluateMessageOn: rec selector: sel argument: argSymbol [
        self evaluateMessageOn: rec selector: sel arguments: { argSymbol }
    ]
    
    evaluateStatement: node [
	^self evaluate: (self makeSequenceNode: node)
    ]
    
    evaluate: seq [
	| emptySeq |
	(currentDeclaration notNil and: [ currentDeclaration comments notEmpty ])
	    ifTrue: [
		seq parent isNil
		    ifTrue: [
			seq comments: currentDeclaration comments.
			seq parent: currentDeclaration parent ]
		    ifFalse: [
			emptySeq := self makeSequenceNode.
			emptySeq comments: currentDeclaration comments.
			emptySeq parent: currentDeclaration parent.
			super evaluate: emptySeq ] ].
	currentDeclaration := nil.
        ^super evaluate: seq
    ]

    makeSequenceNode [
        | seq |
	seq := RBSequenceNode
            leftBar: nil
            temporaries: #()
            rightBar: nil.
        seq periods: #().
        seq statements: #().
	^seq
    ]
    
    makeSequenceNode: stmt [
        ^self makeSequenceNode statements: { stmt }.
    ]
    
    makeClassOf: node [
        ^RBMessageNode
    	    receiver: node
    	    selector: #class
    	    arguments: #()
    ]

    skipToken: tokenValue [
        (currentToken value = tokenValue)
            ifTrue: [self step. ^true]
            ifFalse: [^false]
    ]
    
    skipExpectedToken: tokenValue [
        (self skipToken: tokenValue)
            ifFalse: [self parserError: ('expected ' , tokenValue asSymbol)]
    ]
]
PK
     �Mh@>�h<  <    Extensions.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Class extensions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
| Written by Daniele Sciascia.
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


Behavior extend [
    parseNodeAt: selector [
	"Available only when the Parser package is loaded--Answer an
	 RBMethodNode that compiles to my method named by selector."
        ^(self compiledMethodAt: selector) methodParseNode
    ]

    formattedSourceStringAt: aSelector ifAbsent: aBlock [
	"Answer the method source code as a formatted string. Requires
	 package Parser."

	<category: 'source code'>
	| method |
	method := self lookupSelector: aSelector.
	method isNil ifTrue: [^aBlock value copy].
	^method methodFormattedSourceString
    ]
]


CompiledMethod extend [
    methodFormattedSourceString [
        "Answer the method source code as a string, formatted using
	 the RBFormatter.  Requires package Parser."

        <category: 'compiling'>
	^STInST.RBFormatter new
		      initialIndent: 1;
                      format: self methodParseNode.
    ]

    methodParseNode [
        "Answer the parse tree for the receiver, or nil if there is an
         error.  Requires package Parser."

        <category: 'compiling'>
	^self parserClass
            parseMethod: self methodSourceString
            category: self methodCategory
	    onError: [ :message :position | ^nil ]
    ]

    parserClass [
	"Answer a parser class, similar to Behavior>>parserClass, that
	 can parse my source code.  Requires package Parser."
        <category: 'compiling'>
	^self isOldSyntax
	    ifTrue: [ STInST.RBParser ]
	    ifFalse: [ STInST.RBBracketedMethodParser ]
    ]
]


Class extend [
    fileOutHeaderOn: aFileStream [
        | now |
        aFileStream 
            nextPutAll: '"Filed out from ';
            nextPutAll: Smalltalk version;
            nextPutAll: ' on '.
            
        now := Date dateAndTimeNow.
        
        aFileStream
            print: now asDate;
            space;
            print: now asTime;
            nextPutAll: '"';
            nl; nl
    ]
    
    fileOutDeclarationOn: aFileStream [
	"File out class definition to aFileStream.  Requires package Parser."
	<category: 'filing'>
	self fileOutHeaderOn: aFileStream.
        (STInST.FileOutExporter defaultExporter on: self to: aFileStream)
            fileOutDeclaration: [ ]
    ]

    fileOutOn: aFileStream [
	"File out complete class description:  class definition, class and
	 instance methods.  Requires package Parser."
	<category: 'filing'>
	self fileOutHeaderOn: aFileStream.
        STInST.FileOutExporter defaultExporter
	    fileOut: self to: aFileStream
    ]
]

ClassDescription extend [
    fileOutSelector: aSymbol toStream: aFileStream [
        "File out all the methods belonging to the method category,
	 category, to aFileStream.  Requires package Parser."
	
	self fileOutHeaderOn: aFileStream.
        STInST.FileOutExporter defaultExporter
	    fileOutSelector: aSymbol of: self to: aFileStream
    ]

    fileOutCategory: category toStream: aFileStream [
        "File out all the methods belonging to the method category,
	 category, to aFileStream.  Requires package Parser."
	
	self fileOutHeaderOn: aFileStream.
        STInST.FileOutExporter defaultExporter
	    fileOutCategory: category of: self to: aFileStream
    ]
]
PK
     �Mh@l2�:  �:    RBFormatter.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Refactoring Browser - Smalltalk code pretty-printer
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1998-2000 The Refactory, Inc.
|
| This file is distributed together with GNU Smalltalk.
|
 ======================================================================"



RBProgramNodeVisitor subclass: RBFormatter [
    | codeStream lineStart firstLineLength tabs initialIndent |
    
    <comment: nil>
    <category: 'Refactory-Parser'>

    firstLineLength [
	<category: 'accessing'>
	^firstLineLength isNil 
	    ifTrue: [codeStream position]
	    ifFalse: [firstLineLength]
    ]

    formatAll: anArray [
	<category: 'accessing'>
	self formatStatements: anArray.
	^codeStream contents
    ]

    format: aNode [
	<category: 'accessing'>
	self visitNode: aNode.
	^codeStream contents
    ]

    initialIndent [
	<category: 'accessing'>
	initialIndent isNil ifTrue: [initialIndent := 0].
	^initialIndent
    ]

    initialIndent: anInteger [
	<category: 'accessing'>
	initialIndent := anInteger
    ]

    isMultiLine [
	<category: 'accessing'>
	^firstLineLength notNil
    ]

    lastLineLength [
	<category: 'accessing'>
	^codeStream position - (lineStart max: 0)
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	lineStart := self lineLength negated.
	codeStream := WriteStream on: (String new: 60).
	firstLineLength := nil
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	codeStream := WriteStream on: (String new: 60).
	tabs := 0.
	lineStart := 0
    ]

    indent [
	<category: 'private'>
	firstLineLength isNil ifTrue: [firstLineLength := codeStream position].
	codeStream nl.
	tabs // 2 timesRepeat: [codeStream tab].
	tabs odd ifTrue: [codeStream next: 4 put: Character space].
	lineStart := codeStream position
    ]

    indent: anInteger while: aBlock [
	<category: 'private'>
	tabs := tabs + anInteger.
	aBlock value.
	tabs := tabs - anInteger
    ]

    indentWhile: aBlock [
	<category: 'private'>
	self indent: 1 while: aBlock
    ]

    lineLength [
	<category: 'private'>
	^codeStream position - lineStart
    ]

    lineStart: aPosition [
	<category: 'private'>
	lineStart := aPosition
    ]

    maximumArgumentsPerLine [
	<category: 'private'>
	^2
    ]

    maxLineSize [
	<category: 'private'>
	^75
    ]

    needsParenthesisFor: aNode [
	<category: 'private'>
	| parent grandparent |
	aNode isValue ifFalse: [^false].
	parent := aNode parent.
	parent isNil ifTrue: [^false].
	(aNode isMessage and: [parent isMessage and: [parent receiver == aNode]]) 
	    ifTrue: 
		[grandparent := parent parent.
		(grandparent notNil and: [grandparent isCascade]) ifTrue: [^true]].
	aNode precedence < parent precedence ifTrue: [^false].
	aNode isAssignment & parent isAssignment ifTrue: [^false].
	aNode isAssignment | aNode isCascade ifTrue: [^true].
	aNode precedence == 0 ifTrue: [^false].
	aNode isMessage ifFalse: [^true].
	aNode precedence = parent precedence ifFalse: [^true].
	aNode isUnary ifTrue: [^false].
	aNode isKeyword ifTrue: [^true].
	parent receiver == aNode ifFalse: [^true].
	^self precedenceOf: parent selector greaterThan: aNode selector
    ]

    precedenceOf: parentSelector greaterThan: childSelector [
	"Put parenthesis around things that are preceived to have 'lower' precedence. For example, 'a + b * c'
	 -> '(a + b) * c' but 'a * b + c' -> 'a * b + c'"

	<category: 'private'>
	| childIndex parentIndex operators |
	operators := #(#($| $& $?) #($= $~ $< $>) #($- $+) #($* $/ $% $\) #($@)).
	childIndex := 0.
	parentIndex := 0.
	1 to: operators size
	    do: 
		[:i | 
		((operators at: i) includes: parentSelector first) 
		    ifTrue: [parentIndex := i].
		((operators at: i) includes: childSelector first) 
		    ifTrue: [childIndex := i]].
	^childIndex < parentIndex
    ]

    selectorsToLeaveOnLine [
	<category: 'private'>
	^#(#to:do: #to:by: #to:by:do:)
    ]

    selectorsToStartOnNewLine [
	<category: 'private'>
	^#(#ifTrue:ifFalse: #ifFalse:ifTrue: #ifTrue: #ifFalse:)
    ]

    formatLiteral: token [
	<category: 'private-formatting'>
	| isArray aValue |
	aValue := token value.
	token isCompileTimeBound 
	    ifTrue: 
		[codeStream
		    nextPutAll: '#{';
		    nextPutAll: aValue;
		    nextPut: $}.
		^self].
	aValue class == Array 
	    ifTrue: 
		[codeStream nextPutAll: '#('.
		aValue do: [:each | self formatLiteral: each]
		    separatedBy: [codeStream nextPut: $ ].
		codeStream nextPut: $).
		^self].
	aValue class == ByteArray 
	    ifTrue: 
		[codeStream nextPutAll: '#['.
		aValue do: [:each | codeStream store: each]
		    separatedBy: [codeStream nextPut: $ ].
		codeStream nextPut: $].
		^self].
	aValue isSymbol 
	    ifTrue: 
		[self formatSymbol: aValue.
		^self].
	aValue class == Character 
	    ifTrue: 
		[codeStream
		    nextPut: $$;
		    nextPut: aValue.
		^self].
	aValue storeLiteralOn: codeStream
    ]

    formatMessage: aMessageNode cascade: cascadeBoolean [
	<category: 'private-formatting'>
	| selectorParts arguments multiLine formattedArgs indentFirst firstArgLength length |
	selectorParts := aMessageNode selectorParts.
	arguments := aMessageNode arguments.
	formattedArgs := OrderedCollection new.
	multiLine := aMessageNode selector numArgs > self maximumArgumentsPerLine.
	length := aMessageNode selector size + arguments size + 1.
	firstArgLength := 0.
	self indentWhile: 
		[1 to: arguments size
		    do: 
			[:i | 
			| formatter string |
			formatter := (self copy)
				    lineStart: (selectorParts at: i) length negated;
				    yourself.
			string := formatter format: (arguments at: i).
			formattedArgs add: string.
			i == 1 ifTrue: [firstArgLength := formatter firstLineLength].
			length := length + string size.
			multiLine := multiLine or: [formatter isMultiLine]]].
	multiLine := multiLine or: [length + self lineLength > self maxLineSize].
	indentFirst := cascadeBoolean not and: 
			[multiLine and: 
				[(self startMessageSendOnNewLine: aMessageNode) or: 
					[self lineLength + selectorParts first length + 2 + firstArgLength 
					    > self maxLineSize]]].
	indentFirst ifTrue: [self indent].
	self 
	    formatMessageSelector: selectorParts
	    withArguments: formattedArgs
	    multiline: multiLine
    ]

    formatMessageSelector: selectorParts withArguments: formattedArgs multiline: multiLine [
	<category: 'private-formatting'>
	formattedArgs isEmpty 
	    ifTrue: [codeStream nextPutAll: selectorParts first value]
	    ifFalse: 
		[1 to: formattedArgs size
		    do: 
			[:i | 
			i ~~ 1 & multiLine not ifTrue: [codeStream nextPut: $ ].
			codeStream
			    nextPutAll: (selectorParts at: i) value;
			    nextPut: $ ;
			    nextPutAll: (formattedArgs at: i).
			(multiLine and: [i < formattedArgs size]) ifTrue: [self indent]]]
    ]

    formatComment: aString [
	<category: 'private-formatting'>
	| stream |
	stream := ReadStream 
		    on: aString
		    from: (aString findFirst: [:each | each = $"]) + 1
		    to: (aString findLast: [:each | each = $"]) - 1.
	stream atEnd ifTrue: [^self].
	codeStream nextPut: $".
	stream linesDo: 
		[:each | 
		codeStream nextPutAll: each trimSeparators.
		stream atEnd 
		    ifFalse: 
			[self indent.
			codeStream space]].
	codeStream nextPut: $"
    ]

    formatMethodCommentFor: aNode indentBefore: aBoolean [
	<category: 'private-formatting'>
	| source |
	source := aNode source.
	source isNil ifTrue: [^self].
	aNode comments do: 
		[:each | 
		aBoolean ifTrue: [self indent].
		self formatComment: (aNode source copyFrom: each first to: each last).
		codeStream nl.
		aBoolean ifFalse: [self indent]]
    ]

    formatMethodPatternFor: aMethodNode [
	<category: 'private-formatting'>
	| selectorParts arguments |
	selectorParts := aMethodNode selectorParts.
	arguments := aMethodNode arguments.
	arguments isEmpty 
	    ifTrue: 
		[codeStream
		    nextPutAll: selectorParts first value;
		    nextPut: $ ]
	    ifFalse: 
		[selectorParts with: arguments
		    do: 
			[:selector :arg | 
			codeStream
			    nextPutAll: selector value;
			    nextPut: $ .
			self visitArgument: arg.
			codeStream nextPut: $ ]]
    ]

    formatStatementCommentFor: aNode [
	<category: 'private-formatting'>
	| source |
	source := aNode source.
	source isNil ifTrue: [^self].
	aNode comments do: 
		[:each | 
		| crs |
		crs := self newLinesFor: source startingAt: each first.
		(crs - 1 max: 0) timesRepeat: [codeStream nl].
		crs == 0 ifTrue: [codeStream tab] ifFalse: [self indent].
		self formatComment: (source copyFrom: each first to: each last)]
    ]

    formatStatementsFor: aSequenceNode [
	<category: 'private-formatting'>
	self formatStatements: aSequenceNode statements
    ]

    formatStatements: statements [
	<category: 'private-formatting'>
	statements isEmpty ifTrue: [^self].
	1 to: statements size - 1
	    do: 
		[:i | 
		self visitNode: (statements at: i).
		codeStream nextPut: $..
		self formatStatementCommentFor: (statements at: i).
		self indent].
	self visitNode: statements last.
	self formatStatementCommentFor: statements last
    ]

    formatSymbol: aSymbol [
	"Format the symbol, if its not a selector then we must put quotes around it. The and: case below,
	 handles the VisualWorks problem of not accepting two bars as a symbol."

	<category: 'private-formatting'>
	codeStream nextPut: $#.
	((RBScanner isSelector: aSymbol) and: [aSymbol ~~ #'||']) 
	    ifTrue: [codeStream nextPutAll: aSymbol]
	    ifFalse: [aSymbol asString printOn: codeStream]
    ]

    formatTagFor: aMethodNode [
	<category: 'private-formatting'>
	| primitiveSources |
	primitiveSources := aMethodNode primitiveSources.
	primitiveSources do: 
		[:each | 
		codeStream nextPutAll: each.
		self indent]
    ]

    formatTemporariesFor: aSequenceNode [
	<category: 'private-formatting'>
	| temps |
	temps := aSequenceNode temporaries.
	temps isEmpty ifTrue: [^self].
	codeStream nextPutAll: '| '.
	temps do: 
		[:each | 
		self visitArgument: each.
		codeStream nextPut: $ ].
	codeStream nextPut: $|.
	self indent
    ]

    newLinesFor: aString startingAt: anIndex [
	<category: 'private-formatting'>
	| count cr lf index char |
	cr := Character value: 13.
	lf := Character value: 10.
	count := 0.
	index := anIndex - 1.
	[index > 0 and: 
		[char := aString at: index.
		char isSeparator]] 
	    whileTrue: 
		[char == lf 
		    ifTrue: 
			[count := count + 1.
			(aString at: (index - 1 max: 1)) == cr ifTrue: [index := index - 1]].
		char == cr ifTrue: [count := count + 1].
		index := index - 1].
	^count
    ]

    startMessageSendOnNewLine: aMessageNode [
	<category: 'testing'>
	(self selectorsToStartOnNewLine includes: aMessageNode selector) 
	    ifTrue: [^true].
	(self selectorsToLeaveOnLine includes: aMessageNode selector) 
	    ifTrue: [^false].
	^aMessageNode selector numArgs > self maximumArgumentsPerLine
    ]

    visitNode: aNode [
	<category: 'visiting'>
	| parenthesis |
	parenthesis := self needsParenthesisFor: aNode.
	parenthesis ifTrue: [codeStream nextPut: $(].
	aNode acceptVisitor: self.
	parenthesis ifTrue: [codeStream nextPut: $)]
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>
	self indent: 2
	    while: 
		[self visitNode: anAssignmentNode variable.
		codeStream nextPutAll: ' := '.
		self visitNode: anAssignmentNode value]
    ]

    acceptArrayConstructorNode: anArrayNode [
	<category: 'visitor-double dispatching'>
	| seqNode multiline formattedBody formatter |
	seqNode := anArrayNode body.
	formatter := (self copy)
		    lineStart: 0;
		    yourself.
	formattedBody := formatter format: seqNode.
	multiline := self lineLength + formattedBody size > self maxLineSize 
		    or: [formatter isMultiLine].
	multiline ifTrue: [self indent].
	codeStream
	    nextPut: ${;
	    nextPutAll: formattedBody;
	    nextPut: $}
    ]

    acceptBlockNode: aBlockNode [
	<category: 'visitor-double dispatching'>
	| seqNode multiline formattedBody formatter |
	seqNode := aBlockNode body.
	formatter := (self copy)
		    lineStart: 0;
		    yourself.
	formattedBody := formatter format: seqNode.
	multiline := self lineLength + formattedBody size > self maxLineSize 
		    or: [formatter isMultiLine].
	multiline ifTrue: [self indent].
	codeStream nextPut: $[.
	aBlockNode arguments do: 
		[:each | 
		codeStream nextPut: $:.
		self visitNode: each.
		codeStream nextPut: $ ].
	aBlockNode arguments isEmpty 
	    ifFalse: 
		[codeStream nextPutAll: '| '.
		multiline ifTrue: [self indent]].
	codeStream
	    nextPutAll: formattedBody;
	    nextPut: $]
    ]

    acceptCascadeNode: aCascadeNode [
	<category: 'visitor-double dispatching'>
	| messages |
	messages := aCascadeNode messages.
	self visitNode: messages first receiver.
	self indentWhile: 
		[messages do: 
			[:each | 
			self
			    indent;
			    indentWhile: [self formatMessage: each cascade: true]]
		    separatedBy: [codeStream nextPut: $;]]
    ]

    acceptLiteralNode: aLiteralNode [
	<category: 'visitor-double dispatching'>
	^self formatLiteral: aLiteralNode token
    ]

    acceptMessageNode: aMessageNode [
	<category: 'visitor-double dispatching'>
	| newFormatter code |
	newFormatter := self copy.
	code := newFormatter format: aMessageNode receiver.
	codeStream nextPutAll: code.
	codeStream nextPut: $ .
	newFormatter isMultiLine 
	    ifTrue: [lineStart := codeStream position - newFormatter lastLineLength].
	self indent: (newFormatter isMultiLine ifTrue: [2] ifFalse: [1])
	    while: [self formatMessage: aMessageNode cascade: false]
    ]

    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>
	self formatMethodPatternFor: aMethodNode.
	codeStream nextPut: $[.
	self indent: self initialIndent
	    while: 
		[self indentWhile: 
			[self formatMethodCommentFor: aMethodNode indentBefore: true.
			aMethodNode category isNil 
			    ifFalse: 
				[self indent.
				codeStream
				    nextPutAll: '<category: ';
				    print: aMethodNode category;
				    nextPut: $>].
			self indent.
			self visitNode: aMethodNode body].
		self indent.
		codeStream nextPut: $]]
    ]

    acceptOptimizedNode: anOptimizedNode [
	<category: 'visitor-double dispatching'>
	codeStream nextPutAll: '##('.
	self visitNode: anOptimizedNode body.
	codeStream nextPut: $)
    ]

    acceptReturnNode: aReturnNode [
	<category: 'visitor-double dispatching'>
	codeStream nextPut: $^.
	self visitNode: aReturnNode value
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>
	| parent |
	aSequenceNode statements isEmpty 
	    ifFalse: 
		[self formatMethodCommentFor: aSequenceNode indentBefore: false.
		self formatTemporariesFor: aSequenceNode].
	parent := aSequenceNode parent.
	(parent notNil and: [parent isMethod]) ifTrue: [self formatTagFor: parent].
	self formatStatementsFor: aSequenceNode
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>
	codeStream nextPutAll: aVariableNode name
    ]
]

PK    �Mh@4�v5#  w�  	  ChangeLogUT	 eqXOJ�XOux �  �  �=kw�6���_�ƻ;c���G���$v�ֳI���Ü9[��$���e���}  ��C)�=�3�D�����px��9�ǕJ��Ź�2�T��>|3[�(��u_x�w-�8gi�(���	��f��4����{���v�^��I�:���{:H��]�Q��l=��O���N^v\�����̴�h�w�H�\�y��A�u/�B��"�� �Z�\���~o�|�>*��L]%#�b�i6�٬X�$�#��B���3���d�ŵ��ϋL��9�!~�ӗo��A������2��P�<W�e.�$�c%3q/OGa:�T�
��$N�;a���7E��2���"�3I�X�D,T>OC@�{ �G�_��6�W��QK���ڠ�߳�r@�<:����Z��k�͔+�s��Z��@Ju�&:�9�5h���� ϏN��a��C$Q|(� �$���ȻЈG�E���J���9\#<�
y�F��|.s\��R�-J� ,b�j�$���4̈́z��%l���D���A����<�v=��;�̓�����K�)�C)����'@��L���1�P=�jܑ����~�QNo�O?"��N+��6	����EF� ��,>�24����w��,-fsB�A��A2-|*�Ow����e��H/@S�E��w�Y�e~�Խ�r�]�T�d�^LH�Trei����va��!�Y�i�o�]�c O��]�;�� ��΋˛���E�i�k�	s��4z 
����\�-d�_;�3b.fY��?��LƷ��QX6pK3Q�4���c_^t|đ�����q��Z�����a;���+���ʦq�D�����T����P���C�rNB5����"3������I��Z���� >�:e�����4K����~"2h]��Ge�?Tp�ހ]1��|����t��g�_/�i�[��%�-���ㅌ�\�w"������]w���Z7J�1\������;�w�
�jY����Õ� K������ �A����44��;���r>1,O~��,;�v�]�۠ox;��D(ą���*��b��IA	�	V`s	�g�%C�����P1�~�i|�aa_EqJ=NW`#�"Z�p���V�IG#Ors拙�_�&G�
"�@L�T溶zǫ���wYto���V��6dF���1v���Uǭn�n�;���8ҟ�����K-{����Y��w*�[:]���eiV�iH�v���er�r�E�y.�`�J( ��N �Z�*�R�����uv��?�m��N<�D�@=��q��p{����ۉvJ��9�z�Wq8^'�|x�@�@�1���6vڥ `�f�r�6�o+���%Z����E	�q���rɦ��]��Wӱ��@ �ӚCi��f�@˂��E�1 �p>�3(X���U����l���	�g���p�l,��${�{���'���c=�����r�w�5�&�T�<�m�/�9h��:��"u:� �]�oǲ�W@�����̈́['�W$:v%�~���o�G�?�������N�>�����ҏ�<�4Yq U�<�q��%`�]��&so�a���*k�7�.X}9�����D�-��_�e�����<`;z���(0�	8O9��T�}�9e��8�/"�"���;�1�'5k��,P���L�O���+�֡�zj�Ȫ���\.�B��8<�yQ�s��A~�<�c��mV��j��}��(OG��@C+� �C��	������3V���|�/�p� �=���V6`��͈�Q����"�1��{8[V�_�!��LX��C'j�F��y���5���@��l�)�[���Q�FRrN�G�����_Q�������~�&�.p,8p�"�(��O���1�q4]�2�@&	��{��DO���g)�I1��V�c�
߱CPB��h.1�J`���&Ia�p�W�]��q�$7&����6+*��x���i��Y �o���Z�/b�r;Л�s-�r��$f�۳�;����P�؜�I4H,-�[Ki�	 ���"L��9H9x���� M�u�K���Z�AD\S��Ů�%*~:fA��k�O����Tn�^�V�e� ���%8�Į���e����J�wl"�i�����^�8pw��]Pq"s��{%}���n��_H��$t�C
�S� �w�mK~����#����C���Y�N��F�@OM�G|V�Ȝ %p�����qHz4c�ѭ���B&yh�Z�c��A�W�E��Ƞ��BpW}2���m��k�l �jԈF�h��FLc���@(�/>D@�����m��T_װ_�i���͂u�����N;�*t{aG>���E��͙�e�A�,�^0ƌ�b0� n+�ln�f*��{(���Ǝ������5I�LEa')"�CĔ�1�\R����"(��d��M���.�T�)�x��TH�qhV�G"���� ���M�HP�&h�G�3$>z���ٹ�klR��p�A4P��I�J��4���� �rsv�ĝ�-��c#=��48Nʹ6�Ϙ�KBjSK7�#�?�Bz�|<	0��8�Lg�O�ۻ���F���b]���; �4�3/�Hg[�z��l`^�[�	c�e��*���vX�O��Nt@���3�]�~m,^�DZ�M=����t�4�@�=���� P�&b��xܝ�k�F�)��.�F.���I�|���a��q�A����[y�t����aSb✸-�'�V���%�b|)��[/��OlE���Α~�9j��J�[lc7G������2�h����TD�u0�R͘1�wڔφ��ISG~�����Z,�N{T�1Y�hFN1gM/�G�+�=�a4���G�F�cV��p��t�V�j̄sT�i�.��,�ܕ��U� ��Z�~��d��������ތg]�ߵUB|I T����e6�@<e`���lED��b�ǉ�kv9�� bE��n]e_E���l �_-��c2ꔡ̥ѲV���x��@�*5u�E&J�s�
� �S�-|���*�`���XR��]��b'��N|���w��-�0���[Hro���w�`�2��y���<M�OX!<��/t%Q�
�5rI��\�F���(����h�( �X	Rv-�P�*%�-����F����X�(I݂��\ل� � 	(�i�t`�����Ig��@7��I���� ��n,��|�&.E�h�����le������؟`.^���z4!����]�O�y��L���I�^�up
��T&��\Az�����n<V�0�Ͻ\f�*]4��p71V�D�](�b��l�<E�꼌0�;Um�@�$�̉��IC���ԑuH�/{Q��u {��e22%4X}���qп�!�XӔ7
wqV<�Q#��l1sa-��C�aс��i��S����!XX��G&vg�sq�8_l��}�e��c^/4��O5��� ;3SSS�<�.�h��<��<�������6�on���)X���A�?|,�\�Ƈ��/�<��V�Ǽ�!��||cC�Y���u�\�&!YO�|ݶi�c��*�ԫón�g���Ѣ0YHƔWaȁ����Su7^[�ld�%X[����jq��I'�Z��I&�4�g��-����Ȕ�O�"q��FP����>bb�ޗ��Kd�*�����a#A�]��b���p�@uؐA�t|KvF�[*�u��{U L�7WY����D�vW��P�S�v�[$�+�)�������M�b?���@X�'�P.z��X�g�6�T"�4m��1��'	2��nIL�"9����_~ER������:�V�;�JbXS�ߜ1���k"L�qPO��=c{�7��ĳk�S6|S9܉�Zľ5>L��C������	)'!R�8������םJl��ݖ6��,�yq~C���E2��s#.�>1'����(Th��0�c(Ù~��h\����N	�'�=��+~`�&����������;oD2�&[T�:b �$��kg���z.-��e�e�|�x02��jf*�d��-�@�'S_���3���ᆀ�p��bh;OS�a�ʴ��|��B��SE����7O��f���D7БF�� �$?�)8og��V��1�ȬM���R����'��	;����_^L�����x[�c���;fQᲑM�O������C�j��g`W��ٜ�K	���Y���]`��fۣ���*J�"�шX�i�*��-�2RA���lUh����y��V������]E?��Y�`��3a���57��`R0o6�K�4a�*��Bn!�򳞟[Ⰻ��k������l=)��������W��6�����D��j��EG��!J��"G�
�\�%�a�a3��,�k��m�8��\_���u�ⵡ�y!,��,Ƶ���e��Z�����Z=��6h�sF�.�JQU�6���l��QJ�dKDV�w5*�U' �$;,��GfJl�e�Hu~0�7��&�����O��n�r�j�H�t�ܦmm��]�C��d�c2%�D�'��|6W��Y��:Z&����M.y9���fFxkׅ���������r�~��ףF��E�.��Z�@^���3J��Z�ܫAu�H�^A>�J�i��MA��%h�Pqwq��V���;���`&�H�Vfn�r�L��P��9��8���
�k��P��V-�	8A��ʩZ^�ݖ�=$�+E��4�B5_�,yJ�;�g�~�2�I��X��@poM6vۀ����?�h�c�������f���
4����ܾZ��-�3�� GG�.D0�����5���g-��@�b7��f����`n �_�U1��.� b���O���3G5k�*����m�&��ʘgu�x������)2�bU Zu(ĿC`ag#h�z1���t����8O��,mH�m�ܤ�LH���a3i�e��8"�|�?��ؖ5��by%�=XB��Q�|�y01@�dݛ/��(������F�e6fH���vm�]��i�����
�̄|+��F$�Z�:�Y(���i��1 D�Ҋ��L�4��k֧eA�H4����>�]�(��\���0�?�V�Wu�j�8��}+/Ͳt%�c��7��o�	:5?n��V�G�ɔ8�H�Oe��!�;t�ח�sti��X����|�&��V1A�4;�Bk��Ψ �����HI��r݃�`ǔY-�P�5�uGJM�b�=㄄^��,�h��{O�bG�3�2��'b���Sq��pȞ�vȗ8���d��~kG1A��{�p($������s dR�z �Z���S�ޠ#"��j�#o�L�qT���S�c���&,2�e�T+P~X[q�Z�RQ��*���y���-���������?/8��Gk���[@e7&�JZ�54X.c��g�{��XYRyIV�̧@�]�-1Q�&�B��/s�6@���a�ʮ�w���Ю`>��[ ��q.u ����ؠ�E��j(K�1��8�	x�Х�y�
ѝ�6��V��/>{&>����O�T(g�^i#�\S1��#��Z�1���<���-��pbCj�˫)�L�i�B��?c����C4ϨD0FJ�mh*�j�-�>썖2���/�5a�Y�f��V#���ն�M��8���)�w���?���-�	Ԫ3�Ҵ�)3d�VK�!`�Y��5�Ǹ<Uu��/�BL������l�S/'f�����sL���JG�/F����{�Ͱ�����rO�`#QŊ�@��bs�)�Gb,]�X���m�v��w��*tƸ
(}�̔�S�!��{��̫-Rkl��85�_&ԫ�_^���3.��������iE�W�� ���"�X�KK.Ӱ�vz�ے�&�>0�z��*�%�_3��/-| �R���_�vPĸ����85&�J�=P�`��`���b&@f�S�؈�^LH�8�uo5��b�!+�o?��0϶�W�z��C�@~�L�i�<>�Y�Ѐ=���kp`oQ|_��hk��Gi��٦���3�l���E�<sEi'5�yJ���@�%�b_�,ֵ;]놵Yy�}�XEL,���0�|�J9_vY�K���ԯ�盳+S�G� mWު�&���M���v�9 ��5C��U<!��=�T���4��ku�-��ᚏ����/�$|<xټ�6	��Ƽqn�2
���i|گX[��
B[ӱ^LҘgkқh�s���&�b�N��@�B���~��9�s���Y����wۄh}�lݘ�#s�i��*%
����"ا�e����U<�:�{E�^��[��ҩ�9��ksݮ0j� 70���g�j.�K�cϏ�V�QֱQ�c�
#�@�Y:���gĢ%P��K�������n�E0��ɶ�����s�
��k���S�9��b����ƖK�8�M;���
��U!�7� ��7�O�������œ��&�f�{/�p�w�;خ�CC���*_�|Qb���~i	q���y�ny4�k�"�F7��78	���Ԙ��&��f�k5Wz����_��n,�|YM��h.v����Ş7�lo7�b�x��6&h}��똨@�C�ɤG���1�썱�̸`�B��/L��4�3�����Ú]������s��\�������`J�tC|�Z�e��?���@�[�cH3+a���475�T����&�H��<�AQ�������ms_�ϥ��V\e���7�ᛀ�~`��N��c[0���>يi�Q.8š�¦q��MAg!2�*u���w��������wU��"�����qpl�{44أ�XTJ�r LO3���۽cU���#�4�Z���z�����i����GIV<�ID!h*�W������E*	�u>�*W�&��t'e��3X��(��B3��]������ꆩ�%
��1W��� 1,h�p�0�DV��� �Nb�|wRL1���( �
чbo�y3? <p�"�H���6�E�6�E"�:]V>�3S���U� .�b6��gxgև��ƥo��!0.M������L[+3�-V%��<;h�`�E�g�sU+��ۻ�|q�I9�i�n�v���qG<m��!�v|4�bX�/���ƷWK��L u��r��A[��U8<�%؆����;qY�/޲{�5d���`��	@�ny����W�]Sx��6,τ��^�sa���:KC: �|�%�Y,�N?�b0���in�.��_��5�p_�Q�"�5�!���D�$2�zY�$���
�f2���<4�C:;p8z�ݸ��cUZ\f��#�[�J_�]��W^�����ޯmu�o"����T�j�߽��Ԧ���j�
n��|t���������S�����~҉�WJ%>�sQR��Q�\��5Sk/�Yx�@u�Ħ��,>D_�5�.NT��U��ػ�����Kl� Cf�rS��y,���I��<{��-�[����+�6����mr�?~o�3{��VG�w8�����4��y4��XZO�����U�%����c88_��9��������2�������{���k���nQ��jLʄ�c1`4�'��3��W����~fnR�ԫEe�9��@{��M�wߕ�J�?3�J���7v�1'،fwu88&�a{�]�2 j�����
Ls��Úf�p��jE�S��,��5g˖4v�2[���
M}�6z�Sf8,��I��'���7���:h�GOp��
���c�Q�ȋ7h�:Q�,I׷e��Ifr���^����?�8lpz���A5��6N �4�m7��Z)��1�2T�|i��j�P�Q5�1S�4�#I�qאjk�ɧA�Eǰ���pm��i�g����O)��v�;��O��I :��9OL"��C�$wu;��_^`fʛ��_���O�c���i18�g�d���=;/�4;�9���i@���V���I֠hߖ��I1������!�����f��^l[�e�����6M��q�.���c2�-U�۽ܨ����9��mb��mSM�H��j�Oc�j~�͐�n��hѥT1�t��/�M���I˯�u��&)�/���	΃�ff���f�yߎ_rˀ ,��^t�R1q\��ǲ֌�qK�U_4������1��6*������hh:ii�c��,��	���w��}�n0�MU��8!� �%9�5
3�{�3ʪ�'��|G�P����^>�J�b�)m�ț�܅�2"7��67�
,�l���0��� �����f)�����44�;�Ym����ِ���^㏷�%n	:F�6��8�W�;
?�V�~�����+��1�lۆ >�	���&!�΢��<{͕WX�,M�yDO-�7����Cw������܎1u?*�ݑ`��iZ?����?��N�����x�Ix_%dǷ�&o�(W�b`�7����fĤ�;f)�3�pn~���T�OV^���@��T�<d'[��Fs5���=槏5F�m���fIBvi����^V��'��Ϻ2d��MaG����c��~���0[����r���r�D3����D�#�][Fk�L�9%���⋣l���^�~_f��☠M�8�ܘ~�k~�'���r̋��EЦ�|�;���C�c�$xQ�f�h�n������!�};Ņ
��zjtPΩlB�� �r@5-*��	��� g sW��Z�.�\�	��x��{n��а{����Ֆݸ����&���,�����-�7�*{Y��_�⛳�Q���A�ۆie�}�״�;��;o<\�44��<�!&p��	5>������޸t���9�{E�/<�%m@��.�K�b#��v%mg�ϕ���o�S'O���*����9�)�+q�����I��h�]YB��]4��7�� d8=lǍ�=� :� ��#Us����|U5l�W�PK
     �Mh@����Sp  Sp    STCompiler.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Smalltalk in Smalltalk compiler
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2003,2006,2007,2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



RBProgramNodeVisitor subclass: STFakeCompiler [
    
    <import: VMOtherConstants>
    <import: VMByteCodeNames>
    <comment: 'I am the Smalltalk equivalent of a wimp. I never do nothing: they tell me
to compile something, and I just return nil...

Actually, I am used when conditionally compiled code has to be skipped.'>
    <category: 'System-Compiler'>

    STFakeCompiler class >> evaluate: aSequenceNode parser: aParser [
	<category: 'evaluation'>
	^nil
    ]

    STFakeCompiler class >> compile: methodDefNode for: aBehavior classified: aString parser: aParser [
	<category: 'compilation'>
	^nil
    ]
]



STFakeCompiler subclass: STCompiler [
    | node destClass symTable parser bytecodes depth maxDepth isInsideBlock |
    
    <comment: 'Unlike my brother STFakeCompiler, I am a real worker. Give me some nodes, and
I will output a full-fledged CompiledMethod!!

Compilation takes place as a visit of a tree of RBParseNodes, through the
Visitor pattern embodied by the superclass RBParseNodeVisitor.  For
example, when we send the ''true printOn: stdout'' message, the structure
of the tree is:

    RBMessageNode, which contains:
	the receiver, a RBLiteralNode
	the message, a RBMessageNode, which contains
	     the selector
	     the arguments, a Collection which contains a RBVariableNode

#acceptMessageNode: checks if the receiver is super. If so, it tells the message
to compile itself as a send to super. In this case however it tells both the
receiver and the message to compile themselves.
#acceptLiteralNode: will output a ''push true'' bytecode.
#acceptMessageNode:, in turn, asks the parameters to compile themselves, asks
the STSymTable object to add the #printOn: literal, then compiles a ''send
message'' bytecode.
The RBVariableNode which refers to stdout, when it is asked to compile itself,
tells the STCompiler object to add a literal (since it refers to a global
variable) and then compiles either a ''push global variable'' or a ''push
indexed'' bytecode. The resulting stream is

	push true
	push literal corresponding to (#stdout -> stdout)
	send message with 0 args, selector = #printOn:'>
    <category: 'System-Compiler'>

    OneNode := nil.
    TrueNode := nil.
    FalseNode := nil.
    NilNode := nil.
    SuperVariable := nil.
    SelfVariable := nil.
    ThisContextVariable := nil.

    STCompiler class >> initialize [
	<category: 'initialize'>
	OneNode := RBLiteralNode value: 1.
	TrueNode := RBLiteralNode value: true.
	FalseNode := RBLiteralNode value: false.
	NilNode := RBLiteralNode value: nil.
	SelfVariable := RBVariableNode named: 'self'.
	SuperVariable := RBVariableNode named: 'super'.
	ThisContextVariable := RBVariableNode named: 'thisContext'
    ]

    STCompiler class >> evaluate: aSequenceNode parser: aParser [
	<category: 'evaluation'>
	| cm methodNode |
	aSequenceNode addReturn.
	methodNode := (RBMethodNode new)
		    arguments: #();
		    body: aSequenceNode;
		    selector: #Doit;
		    source: nil;
		    yourself.
	cm := self 
		    compile: methodNode
		    asMethodOf: UndefinedObject
		    classified: nil
		    parser: aParser
		    environment: Namespace current.
	^nil perform: cm
    ]

    STCompiler class >> canCompile: code [
	"Answer whether I know how to compile the given code directly, on
	 behalf of a Behavior."

	<category: 'compilation'>
	^(code isKindOf: RBProgramNode) and: [code isMethod]
    ]

    STCompiler class >> compile: methodNode for: aBehavior classified: aString parser: aParser [
	<category: 'compilation'>
	^aBehavior addSelector: methodNode selector
	    withMethod: (self 
		    compile: methodNode
		    asMethodOf: aBehavior
		    classified: aString
		    parser: aParser)
    ]

    STCompiler class >> compile: methodNode asMethodOf: aBehavior classified: aString parser: aParser [
	<category: 'compilation'>
	^self 
	    compile: methodNode
	    asMethodOf: aBehavior
	    classified: aString
	    parser: aParser
	    environment: nil
    ]

    STCompiler class >> compile: methodNode asMethodOf: aBehavior classified: aString parser: aParser environment: aNamespace [
	<category: 'compilation'>
	| compiler method |
	compiler := self new.
	compiler class: aBehavior parser: aParser.
	aNamespace isNil ifFalse: [compiler addPool: aNamespace].
	method := compiler visitNode: methodNode.
	aString isNil ifFalse: [ method methodCategory: aString ].
	^method
    ]

    class: aBehavior parser: aParser [
	<category: 'private'>
	destClass := aBehavior.
	symTable := STSymbolTable new.
	parser := aParser.
	bytecodes := WriteStream on: (ByteArray new: 240).
	isInsideBlock := 0.
	symTable declareEnvironment: aBehavior
    ]

    addLiteral: literal [
	<category: 'accessing'>
	^(symTable addLiteral: literal)
    ]

    addPool: aNamespace [
	<category: 'accessing'>
	^symTable addPool: aNamespace
    ]

    bytecodesFor: aBlockNode [
	<category: 'accessing'>
	^self bytecodesFor: aBlockNode atEndDo: []
    ]

    bytecodesFor: aBlockNode atEndDo: aBlock [
	<category: 'accessing'>
	| saveBytecodes result |
	saveBytecodes := bytecodes.
	bytecodes := WriteStream on: (ByteArray new: 240).
	self declareArgumentsAndTemporaries: aBlockNode.
	self compileStatements: aBlockNode body.
	self undeclareArgumentsAndTemporaries: aBlockNode.
	aBlock value.
	result := bytecodes contents.
	bytecodes := saveBytecodes.
	^result
    ]

    checkStore: aVariableName [
	<category: 'accessing'>
	(symTable canStore: aVariableName) 
	    ifFalse: [self compileError: 'cannot store in argument ' , aVariableName]
    ]

    compileError: aString [
	<category: 'accessing'>
	parser parserError: aString
    ]

    compileBackJump: displacement [
	<category: 'accessing'>
	| jumpLen |
	jumpLen := displacement + 2.
	jumpLen := displacement + (self sizeOfJump: jumpLen).
	jumpLen := displacement + (self sizeOfJump: jumpLen).
	self compileByte: JumpBack arg: jumpLen
    ]

    compileJump: displacement if: jmpCondition [
	<category: 'accessing'>
	displacement < 0 
	    ifTrue: 
		["Should not happen"

		^self error: 'Cannot compile backwards conditional jumps'].
	self depthDecr: 1.
	jmpCondition 
	    ifFalse: [self compileByte: PopJumpFalse arg: displacement]
	    ifTrue: [self compileByte: PopJumpTrue arg: displacement]
    ]

    compileWarning: aString [
	<category: 'accessing'>
	parser parserWarning: aString
    ]

    declareTemporaries: node [
	<category: 'accessing'>
	node temporaries do: 
		[:aTemp | 
		symTable 
		    declareTemporary: aTemp name
		    canStore: true
		    for: self]
    ]

    declareArgumentsAndTemporaries: node [
	<category: 'accessing'>
	node arguments do: 
		[:anArg | 
		symTable 
		    declareTemporary: anArg name
		    canStore: false
		    for: self].
	self declareTemporaries: node body
    ]

    maxDepth [
	<category: 'accessing'>
	^maxDepth
    ]

    depthDecr: n [
	<category: 'accessing'>
	depth := depth - n
    ]

    depthIncr [
	<category: 'accessing'>
	depth = maxDepth 
	    ifTrue: 
		[depth := depth + 1.
		maxDepth := maxDepth + 1]
	    ifFalse: [depth := depth + 1]
    ]

    depthSet: n [
	"n can be an integer, or a previously returned value (in which case the
	 exact status at the moment of the previous call is remembered)"

	<category: 'accessing'>
	| oldDepth |
	oldDepth := n -> maxDepth.
	n isInteger 
	    ifTrue: [depth := maxDepth := n]
	    ifFalse: 
		[depth := n key.
		maxDepth := n value].
	^oldDepth
    ]

    literals [
	<category: 'accessing'>
	^symTable literals
    ]

    lookupName: variable [
	<category: 'accessing'>
	| definition |
	definition := symTable lookupName: variable for: self.
	definition isNil 
	    ifTrue: 
		["Might want to declare this puppy as a local and go on
		 notwithstanding the error"

		self 
		    compileError: 'Undefined variable ' , variable printString , ' referenced.'].
	^definition
    ]

    compileByte: aByte [
	<category: 'accessing'>
	self compileByte: aByte arg: 0
    ]

    compileByte: aByte arg: arg [
	<category: 'accessing'>
	| n |
	n := 0.
	[(arg bitShift: n) > 255] whileTrue: [n := n - 8].
	n to: -8
	    by: 8
	    do: 
		[:shift | 
		bytecodes
		    nextPut: ExtByte;
		    nextPut: ((arg bitShift: shift) bitAnd: 255)].
	bytecodes
	    nextPut: aByte;
	    nextPut: (arg bitAnd: 255)
    ]

    compileByte: aByte arg: arg1 arg: arg2 [
	<category: 'accessing'>
	self compileByte: aByte arg: (arg1 bitShift: 8) + arg2
    ]

    nextPutAll: aByteArray [
	<category: 'accessing'>
	bytecodes nextPutAll: aByteArray
    ]

    isInsideBlock [
	<category: 'accessing'>
	^isInsideBlock > 0
    ]

    pushLiteral: value [
	<category: 'accessing'>
	| definition |
	(value isInteger and: [value >= 0 and: [value <= 1073741823]]) 
	    ifTrue: 
		[self compileByte: PushInteger arg: value.
		^self].
        value isNil
            ifTrue:
                [self compileByte: PushSpecial arg: NilIndex.
                ^self].
        value == true
            ifTrue:
                [self compileByte: PushSpecial arg: TrueIndex.
                ^self].
        value == false
            ifTrue:
                [self compileByte: PushSpecial arg: FalseIndex.
                ^self].
	definition := self addLiteral: value.
	self compileByte: PushLitConstant arg: definition
    ]

    pushLiteralVariable: value [
	<category: 'accessing'>
	| definition |
	definition := self addLiteral: value.
	self compileByte: PushLitVariable arg: definition
    ]

    sizeOfJump: distance [
	<category: 'accessing'>
	distance < 256 ifTrue: [^2].
	distance < 65536 ifTrue: [^4].
	distance < 16777216 ifTrue: [^6].
	^8
    ]

    displacementsToJumpAround: jumpAroundOfs and: initialCondLen [
	<category: 'accessing'>
	| jumpAroundLen oldJumpAroundLen finalJumpOfs finalJumpLen |
	jumpAroundLen := oldJumpAroundLen := 0.
	
	[finalJumpOfs := initialCondLen + oldJumpAroundLen + jumpAroundOfs.
	finalJumpLen := self sizeOfJump: finalJumpOfs.
	jumpAroundLen := self sizeOfJump: jumpAroundOfs + finalJumpLen.
	oldJumpAroundLen = jumpAroundLen] 
		whileFalse: [oldJumpAroundLen := jumpAroundLen].
	^finalJumpLen + finalJumpOfs -> (jumpAroundOfs + finalJumpLen)
    ]

    insideNewScopeDo: aBlock [
	<category: 'accessing'>
	| result |
	isInsideBlock := isInsideBlock + 1.
	symTable scopeEnter.
	result := aBlock value.
	symTable scopeLeave.
	isInsideBlock := isInsideBlock - 1.
	^result
    ]

    bindingOf: anOrderedCollection [
	<category: 'accessing'>
	| binding |
	binding := symTable bindingOf: anOrderedCollection for: self.
	binding isNil 
	    ifTrue: 
		[self 
		    compileError: 'Undefined variable binding' 
			    , anOrderedCollection asArray printString , 'referenced.'].
	^binding
    ]

    undeclareTemporaries: aNode [
	<category: 'accessing'>
	aNode temporaries do: [:each | symTable undeclareTemporary: each name]
    ]

    undeclareArgumentsAndTemporaries: aNode [
	<category: 'accessing'>
	self undeclareTemporaries: aNode body.
	aNode arguments do: [:each | symTable undeclareTemporary: each name]
    ]

    acceptSequenceNode: node [
	<category: 'visiting RBSequenceNodes'>
	| statements method |
	node addSelfReturn.
	depth := maxDepth := 0.
	self declareTemporaries: node.
	self compileStatements: node.
	self undeclareTemporaries: node.
	symTable finish.
	method := CompiledMethod 
		    literals: symTable literals
		    numArgs: 0
		    numTemps: symTable numTemps
		    attributes: #()
		    bytecodes: bytecodes contents
		    depth: maxDepth + symTable numTemps.
	(method descriptor)
	    setSourceCode: node source asSourceCode;
	    methodClass: UndefinedObject;
	    selector: #executeStatements.
	^method
    ]

    acceptMethodNode: node [
	<category: 'visiting RBMethodNodes'>
	| statements method attributes |
	node body addSelfReturn.
	depth := maxDepth := 0.
	self declareArgumentsAndTemporaries: node.
	self compileStatements: node body.
	self undeclareArgumentsAndTemporaries: node.
	symTable finish.
	attributes := self compileMethodAttributes: node primitiveSources.
	method := CompiledMethod 
		    literals: symTable literals
		    numArgs: node arguments size
		    numTemps: node body temporaries size
		    attributes: attributes
		    bytecodes: bytecodes contents
		    depth: maxDepth + node body temporaries size + node arguments size.
	(method descriptor)
	    setSourceCode: node source asSourceCode;
	    methodClass: symTable environment;
	    selector: node selector.
	method attributesDo: 
		[:ann | 
		| handler error |
		handler := symTable environment pragmaHandlerFor: ann selector.
		handler notNil 
		    ifTrue: 
			[error := handler value: method value: ann.
			error notNil ifTrue: [self compileError: error]]].
	^method
    ]

    acceptArrayConstructorNode: aNode [
	"STArrayNode is the parse node class for {...} style array constructors.
	 It is compiled like a normal inlined block, but with the statements
	 preceded by (Array new: <size of the array>) and with each statement
	 followed with a <pop into instance variable of new stack top>
	 instead of a simple pop."

	<category: 'visiting RBArrayConstructorNodes'>
	self
	    depthIncr;
	    pushLiteralVariable: (Smalltalk associationAt: #Array);
	    depthIncr;
	    compileByte: PushInteger arg: aNode body statements size;
	    depthDecr: 1;
	    compileByte: SendImmediate arg: NewColonSpecial.
	aNode body statements keysAndValuesDo: 
		[:index :each | 
		each acceptVisitor: self.
		self
		    depthDecr: 1;
		    compileByte: PopStoreIntoArray arg: index - 1]
    ]

    acceptBlockNode: aNode [
	"STBlockNode has a variable that contains a string for each parameter,
	 and one that contains a list of statements. Here is how STBlockNodes
	 are compiled:
	 
	 push BlockClosure or CompiledBlock literal
	 make dirty block                    <--- only if pushed CompiledBlock
	 
	 Statements are put in a separate CompiledBlock object that is referenced
	 by the BlockClosure that the sequence above pushes or creates.
	 
	 compileStatements: creates the bytecodes.  It is this method that is
	 called by STCompiler>>bytecodesFor: and STCompiler>>bytecodesFor:append:"

	<category: 'visiting RBBlockNodes'>
	| bc depth block clean |
	depth := self depthSet: aNode arguments size + aNode body temporaries size.
	aNode body statements isEmpty 
	    ifTrue: [aNode body addNode: (RBLiteralNode value: nil)].
	bc := self insideNewScopeDo: 
			[self bytecodesFor: aNode
			    atEndDo: 
				[aNode body lastIsReturn ifFalse: [self compileByte: ReturnContextStackTop]]].
	block := CompiledBlock 
		    numArgs: aNode arguments size
		    numTemps: aNode body temporaries size
		    bytecodes: bc
		    depth: self maxDepth
		    literals: self literals.
	self depthSet: depth.
	clean := block flags.
	clean == 0 
	    ifTrue: 
		[self 
		    pushLiteral: (BlockClosure block: block receiver: symTable environment).
		^aNode].
	self pushLiteral: block.
	self compileByte: MakeDirtyBlock
    ]

    compileStatements: aNode [
	<category: 'visiting RBBlockNodes'>
	aNode statements keysAndValuesDo: 
		[:index :each | 
		index = 1 
		    ifFalse: 
			[self
			    depthDecr: 1;
			    compileByte: PopStackTop].
		each acceptVisitor: self].
	aNode statements isEmpty 
	    ifTrue: 
		[self
		    depthIncr;
		    compileByte: PushSpecial arg: NilIndex]
    ]

    acceptCascadeNode: aNode [
	"RBCascadeNode holds a collection with one item per message."

	<category: 'visiting RBCascadeNodes'>
	| messages first |
	messages := aNode messages.
	first := messages at: 1.
	first receiver = SuperVariable 
	    ifTrue: 
		[aNode messages do: [:each | self compileSendToSuper: each]
		    separatedBy: 
			[self
			    depthDecr: 1;
			    compileByte: PopStackTop].
		^aNode].
	first receiver acceptVisitor: self.
	self
	    depthIncr;
	    compileByte: DupStackTop.
	self compileMessage: first.
	messages 
	    from: 2
	    to: messages size - 1
	    do: 
		[:each | 
		self
		    compileByte: PopStackTop;
		    compileByte: DupStackTop.
		self compileMessage: each].
	self
	    depthDecr: 1;
	    compileByte: PopStackTop.
	self compileMessage: messages last
    ]

    acceptOptimizedNode: aNode [
	<category: 'visiting RBOptimizedNodes'>
	self depthIncr.
	self pushLiteral: (self class evaluate: aNode body parser: parser)
    ]

    acceptLiteralNode: aNode [
	"STLiteralNode has one instance variable, the token for the literal
	 it represents."

	<category: 'visiting RBLiteralNodes'>
	self depthIncr.
	aNode compiler: self.
	self pushLiteral: aNode value
    ]

    acceptAssignmentNode: aNode [
	"First compile the assigned, then the assignment to the assignee..."

	<category: 'visiting RBAssignmentNodes'>
	aNode value acceptVisitor: self.
	(VMSpecialIdentifiers includesKey: aNode variable name) 
	    ifTrue: [self compileError: 'cannot assign to ' , aNode variable name].
	self compileAssignmentFor: aNode variable
    ]

    acceptMessageNode: aNode [
	"RBMessageNode contains a message send. Its instance variable are
	 a receiver, selector, and arguments."

	<category: 'compiling'>
	| specialSelector |
	aNode receiver = SuperVariable 
	    ifTrue: 
		[self compileSendToSuper: aNode.
		^true].
	specialSelector := VMSpecialMethods at: aNode selector ifAbsent: [nil].
	specialSelector isNil 
	    ifFalse: [(self perform: specialSelector with: aNode) ifTrue: [^false]].
	aNode receiver acceptVisitor: self.
	self compileMessage: aNode
    ]

    compileMessage: aNode [
	"RBMessageNode contains a message send. Its instance variable are
	 a receiver, selector, and arguments.  The receiver has already
	 been compiled."

	<category: 'compiling'>
	| args litIndex |
	aNode arguments do: [:each | each acceptVisitor: self].
	VMSpecialSelectors at: aNode selector
	    ifPresent: 
		[:idx | 
		idx <= LastImmediateSend 
		    ifTrue: [self compileByte: idx arg: 0]
		    ifFalse: [self compileByte: SendImmediate arg: idx].
		^aNode].
	args := aNode arguments size.
	litIndex := self addLiteral: aNode selector.
	self 
	    compileByte: Send
	    arg: litIndex
	    arg: args
    ]

    compileRepeat: aNode [
	"Answer whether the loop can be optimized (that is,
	 whether the only parameter is a STBlockNode)"

	<category: 'compiling'>
	| whileBytecodes |
	aNode receiver isBlock ifFalse: [^false].
	(aNode receiver arguments isEmpty 
	    and: [aNode receiver body temporaries isEmpty]) ifFalse: [^false].
	whileBytecodes := self bytecodesFor: aNode receiver
			    atEndDo: 
				[self
				    compileByte: PopStackTop;
				    depthDecr: 1].
	self nextPutAll: whileBytecodes.
	self compileBackJump: whileBytecodes size.

	"The optimizer might like to see the return value of #repeat."
	self
	    depthIncr;
	    compileByte: PushSpecial arg: NilIndex.
	^true
    ]

    compileWhileLoop: aNode [
	"Answer whether the while loop can be optimized (that is,
	 whether the only parameter is a STBlockNode)"

	<category: 'compiling'>
	| whileBytecodes argBytecodes jumpOffsets |
	aNode receiver isBlock ifFalse: [^false].
	(aNode receiver arguments isEmpty 
	    and: [aNode receiver body temporaries isEmpty]) ifFalse: [^false].
	argBytecodes := #().
	aNode arguments do: 
		[:onlyArgument | 
		onlyArgument isBlock ifFalse: [^false].
		(onlyArgument arguments isEmpty 
		    and: [onlyArgument body temporaries isEmpty]) ifFalse: [^false].
		argBytecodes := self bytecodesFor: onlyArgument
			    atEndDo: 
				[self
				    compileByte: PopStackTop;
				    depthDecr: 1]].
	whileBytecodes := self bytecodesFor: aNode receiver.
	self nextPutAll: whileBytecodes.
	jumpOffsets := self displacementsToJumpAround: argBytecodes size
		    and: whileBytecodes size + 2.	"for jump around jump"

	"The if: clause means: if selector is whileFalse:, compile
	 a 'pop/jump if true'; else compile a 'pop/jump if false'"
	self compileJump: (self sizeOfJump: jumpOffsets value)
	    if: (aNode selector == #whileTrue or: [aNode selector == #whileTrue:]).
	self compileByte: Jump arg: jumpOffsets value.
	argBytecodes isNil ifFalse: [self nextPutAll: argBytecodes].
	self compileByte: JumpBack arg: jumpOffsets key.

	"Somebody might want to use the return value of #whileTrue:
	 and #whileFalse:"
	self
	    depthIncr;
	    compileByte: PushSpecial arg: NilIndex.
	^true
    ]

    compileSendToSuper: aNode [
	<category: 'compiling'>
	| litIndex args |
	self
	    depthIncr;
	    compileByte: PushSelf.
	aNode arguments do: [:each | each acceptVisitor: self].
	self pushLiteral: destClass superclass.
	VMSpecialSelectors at: aNode selector
	    ifPresent: 
		[:idx | 
		self compileByte: SendImmediateSuper arg: idx.
		^aNode].
	litIndex := self addLiteral: aNode selector.
	args := aNode arguments size.
	self 
	    compileByte: SendSuper
	    arg: litIndex
	    arg: args.
	self depthDecr: aNode arguments size
    ]

    compileTimesRepeat: aNode [
	<category: 'compiling'>
	"aNode receiver acceptVisitor: self."

	| block |
	block := aNode arguments first.
	(block arguments isEmpty and: [block body temporaries isEmpty]) 
	    ifFalse: [^false].
	^false
    ]

    compileLoop: aNode [
	<category: 'compiling'>
	"aNode receiver acceptVisitor: self."

	| stop step block |
	aNode arguments do: 
		[:each | 
		stop := step.	"to:"
		step := block.	"by:"
		block := each	"do:"].
	block isBlock ifFalse: [^false].
	(block arguments size = 1 and: [block body temporaries isEmpty]) 
	    ifFalse: [^false].
	stop isNil 
	    ifTrue: 
		[stop := step.
		step := OneNode	"#to:do:"]
	    ifFalse: [step isImmediate ifFalse: [^false]].
	^false
    ]

    compileBoolean: aNode [
	<category: 'compiling'>
	| bc1 ret1 bc2 selector |
	aNode arguments do: 
		[:each | 
		each isBlock ifFalse: [^false].
		(each arguments isEmpty and: [each body temporaries isEmpty]) 
		    ifFalse: [^false].
		bc1 isNil 
		    ifTrue: 
			[bc1 := self bytecodesFor: each.
			ret1 := each body lastIsReturn]
		    ifFalse: [bc2 := self bytecodesFor: each]].
	aNode receiver acceptVisitor: self.
	selector := aNode selector.
	bc2 isNil 
	    ifTrue: 
		["Transform everything into #ifTrue:ifFalse: or #ifFalse:ifTrue:"

		selector == #ifTrue: 
		    ifTrue: 
			[selector := #ifTrue:ifFalse:.
			bc2 := NilIndex	"Push nil"].
		selector == #ifFalse: 
		    ifTrue: 
			[selector := #ifFalse:ifTrue:.
			bc2 := NilIndex	"Push nil"].
		selector == #and: 
		    ifTrue: 
			[selector := #ifTrue:ifFalse:.
			bc2 := FalseIndex	"Push false"].
		selector == #or: 
		    ifTrue: 
			[selector := #ifFalse:ifTrue:.
			bc2 := TrueIndex	"Push true"].
		bc2 := 
			{PushSpecial.
			bc2}.
		^self 
		    compileBoolean: aNode
		    longBranch: bc1
		    returns: ret1
		    shortBranch: bc2
		    longIfTrue: selector == #ifTrue:ifFalse:].
	selector == #ifTrue:ifFalse: 
	    ifTrue: 
		[^self 
		    compileIfTrue: bc1
		    returns: ret1
		    ifFalse: bc2].
	selector == #ifFalse:ifTrue: 
	    ifTrue: 
		[^self 
		    compileIfFalse: bc1
		    returns: ret1
		    ifTrue: bc2].
	^self error: 'bad boolean message selector'
    ]

    compileBoolean: aNode longBranch: bc1 returns: ret1 shortBranch: bc2 longIfTrue: longIfTrue [
	<category: 'compiling'>
	self compileJump: bc1 size + (ret1 ifTrue: [0] ifFalse: [2])
	    if: longIfTrue not.
	self nextPutAll: bc1.
	ret1 ifFalse: [self compileByte: Jump arg: bc2 size].
	self nextPutAll: bc2.
	^true
    ]

    compileIfTrue: bcTrue returns: bcTrueReturns ifFalse: bcFalse [
	<category: 'compiling'>
	| trueSize |
	trueSize := bcTrueReturns 
		    ifTrue: [bcTrue size]
		    ifFalse: [bcTrue size + (self sizeOfJump: bcFalse size)].
	self compileJump: trueSize if: false.
	self nextPutAll: bcTrue.
	bcTrueReturns ifFalse: [self compileByte: Jump arg: bcFalse size].
	self nextPutAll: bcFalse.
	^true
    ]

    compileIfFalse: bcFalse returns: bcFalseReturns ifTrue: bcTrue [
	<category: 'compiling'>
	| falseSize |
	falseSize := bcFalseReturns 
		    ifTrue: [bcFalse size]
		    ifFalse: [bcFalse size + (self sizeOfJump: bcTrue size)].
	self compileJump: falseSize if: true.
	self nextPutAll: bcFalse.
	bcFalseReturns ifFalse: [self compileByte: Jump arg: bcTrue size].
	self nextPutAll: bcTrue.
	^true
    ]

    acceptReturnNode: aNode [
	<category: 'compiling'>
	aNode value acceptVisitor: self.
	self isInsideBlock 
	    ifTrue: [self compileByte: ReturnMethodStackTop]
	    ifFalse: [self compileByte: ReturnContextStackTop]
    ]

    compileAssignmentFor: aNode [
	"RBVariableNode has one instance variable, the name of the variable
	 that it represents."

	<category: 'visiting RBVariableNodes'>
	| definition |
	self checkStore: aNode name.
	definition := self lookupName: aNode name.
	(symTable isTemporary: aNode name) 
	    ifTrue: 
		[^self compileStoreTemporary: definition
		    scopes: (symTable outerScopes: aNode name)].
	(symTable isReceiver: aNode name) 
	    ifTrue: [^self compileByte: StoreReceiverVariable arg: definition].
	self compileByte: StoreLitVariable arg: definition.
	self compileByte: PopStackTop.
	self compileByte: PushLitVariable arg: definition
    ]

    acceptVariableNode: aNode [
	<category: 'visiting RBVariableNodes'>
	| locationType definition |
	self depthIncr.
	VMSpecialIdentifiers at: aNode name
	    ifPresent: 
		[:block | 
		block value: self.
		^aNode].
	definition := self lookupName: aNode name.
	(symTable isTemporary: aNode name) 
	    ifTrue: 
		[^self compilePushTemporary: definition
		    scopes: (symTable outerScopes: aNode name)].
	(symTable isReceiver: aNode name) 
	    ifTrue: 
		[self compileByte: PushReceiverVariable arg: definition.
		^aNode].
	self compileByte: PushLitVariable arg: definition
    ]

    compilePushTemporary: number scopes: outerScopes [
	<category: 'visiting RBVariableNodes'>
	outerScopes = 0 
	    ifFalse: 
		[self 
		    compileByte: PushOuterVariable
		    arg: number
		    arg: outerScopes.
		^self].
	self compileByte: PushTemporaryVariable arg: number
    ]

    compileStoreTemporary: number scopes: outerScopes [
	<category: 'visiting RBVariableNodes'>
	outerScopes = 0 
	    ifFalse: 
		[self 
		    compileByte: StoreOuterVariable
		    arg: number
		    arg: outerScopes.
		^self].
	self compileByte: StoreTemporaryVariable arg: number
    ]

    compileMethodAttributes: attributes [
	<category: 'compiling method attributes'>
	^attributes asArray 
	    collect: [:each | self compileAttribute: (RBScanner on: each readStream)]
    ]

    scanTokenFrom: scanner [
	<category: 'compiling method attributes'>
	scanner atEnd 
	    ifTrue: [^self compileError: 'method attributes must end with ''>'''].
	^scanner next
    ]

    compileAttribute: scanner [
	<category: 'compiling method attributes'>
	| currentToken selectorBuilder selector arguments argParser node |
	currentToken := self scanTokenFrom: scanner.
	(currentToken isBinary and: [currentToken value == #<]) 
	    ifFalse: [^self compileError: 'method attributes must begin with ''<'''].
	selectorBuilder := WriteStream on: String new.
	arguments := WriteStream on: Array new.
	currentToken := self scanTokenFrom: scanner.
	[currentToken isBinary and: [currentToken value == #>]] whileFalse: 
		[currentToken isKeyword 
		    ifFalse: [^self compileError: 'keyword expected in method attribute'].
		selectorBuilder nextPutAll: currentToken value.
		argParser := RBParser new.
		argParser errorBlock: parser errorBlock.
		argParser scanner: scanner.
		node := argParser parseBinaryMessageNoGreater.
		node := RBSequenceNode statements: {node}.
		arguments nextPut: (self class evaluate: node parser: argParser).
		currentToken := argParser currentToken].
	selector := selectorBuilder contents asSymbol.
	^Message selector: selector arguments: arguments contents
    ]
]



Eval [
    STCompiler initialize
]

PK
     �Mh@�!}�      SIFParser.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   SIF input parser
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
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


STFileInParser subclass: #SIFFileInParser
    instanceVariableNames: 'lastClass'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Refactory-Parser'!

!SIFFileInParser methodsFor: 'parsing'!

parseMethodDefinitionList
    "Methods are defined one by one in SIF."
    | method |
    method := self compile: self parseMethodFromFile.
    method isNil ifFalse: [ method noteOldSyntax ].
    self endMethodList
! !

!SIFFileInParser methodsFor: 'evaluating'!

evaluate: node
    "Convert some SIF messages to GNU Smalltalk file-out syntax.
     This avoids that the STParsingDriver need to know about other
     dialects."
    | stmt |
    node statements size == 0 ifTrue: [ ^false ].
    node statements size == 1 ifFalse: [ ^self error: 'invalid SIF' ].

    stmt := node statements first.
    stmt isReturn ifTrue: [ stmt := stmt value ].
    stmt isMessage ifFalse: [ ^super evaluate: node ].
    stmt selector == #interchangeVersion: ifTrue: [ ^false ].

    stmt selector == #named:superclass:indexedInstanceVariables:instanceVariableNames:classVariableNames:sharedPools:classInstanceVariableNames: ifTrue: [
	lastClass := self evaluateClass: stmt.
	^false ].

    stmt selector == #key:value: ifTrue: [
	lastClass isNil
	    ifFalse: [ self evaluateAnnotation: stmt to: lastClass ].
	^false ].

    stmt selector == #classMethod ifTrue: [
	lastClass := nil.
	self evaluateClassMethod: stmt.
	^true ].

    stmt selector == #method ifTrue: [
	lastClass := nil.
	self evaluateMethod: stmt.
	^true ].

    (stmt selector == #initializerFor:) ifTrue: [
	lastClass := nil.
	self evaluateInitializer: stmt.
	^false ].

    (stmt selector == #initializer) ifTrue: [
	lastClass := nil.
	self evaluateGlobalInitializer: stmt.
	^false ].

    (stmt selector == #variable: or: [ stmt selector == #constant: ]) ifTrue: [
	lastClass := nil.
	self evaluatePoolDefinition: stmt.
	^false ].

    stmt selector == #named: ifTrue: [
	lastClass := nil.
	self evaluatePool: stmt.
	^false ].

    self error: 'invalid SIF'
!

evaluateStatement: stmt
    driver evaluate: (RBSequenceNode new
			temporaries: #();
			statements: { stmt })
!

evaluateClass: stmt
    "Convert `Class named: ...' syntax to GNU Smalltalk file-out syntax."
    | name superclass shape ivn cvn sp civn newStmt newClass |
    name := stmt arguments at: 1.
    superclass := stmt arguments at: 2.
    shape := stmt arguments at: 3.
    ivn := stmt arguments at: 4.
    cvn := stmt arguments at: 5.
    sp := stmt arguments at: 6.
    civn := stmt arguments at: 7.

    shape value = #none
	ifTrue: [ shape := RBLiteralNode value: nil ].
    shape value = #object
	ifTrue: [ shape := RBLiteralNode value: #pointer ].

    newStmt := RBMessageNode
		receiver: (RBVariableNode named: superclass value)
		selector: #variable:subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
		arguments: {
			shape. RBLiteralNode value: name value asSymbol.
			ivn. cvn. sp. RBLiteralNode value: nil }.
    self evaluateStatement: newStmt.

    newClass := RBVariableNode named: name value.
    newStmt := RBMessageNode
	    receiver: (self makeClassOf: newClass)
	    selector: #instanceVariableNames:
	    arguments: { civn }.
    self evaluateStatement: newStmt.

    ^newClass!

makeClassOf: node
    ^RBMessageNode
	receiver: node
	selector: #class
	arguments: #()!

evaluateAnnotation: stmt to: object
    "Convert `Annotation key: ...' syntax to GNU Smalltalk file-out syntax."
    | key value selector newStmt |
    key := stmt arguments at: 1.
    value := stmt arguments at: 2.
    key value = 'package' ifTrue: [ selector := #category: ].
    key value = 'category' ifTrue: [ selector := #category: ].
    key value = 'comment' ifTrue: [ selector := #comment: ].
    selector isNil ifFalse: [
        newStmt := RBMessageNode
	    receiver: object
	    selector: selector
	    arguments: { value }.
        self evaluateStatement: newStmt ]!

evaluateClassMethod: stmt
    "Convert `Foo classMethod' syntax to GNU Smalltalk file-out syntax."
    stmt receiver: (self makeClassOf: stmt receiver).
    self evaluateMethod: stmt!

evaluateMethod: stmt
    "Convert `Foo method' syntax to GNU Smalltalk file-out syntax."
    | newStmt |
    newStmt := RBMessageNode
	receiver: stmt receiver
	selector: #methodsFor:
	arguments: { RBLiteralNode value: nil }.
    self evaluateStatement: newStmt!

evaluateInitializer: stmt
    "Convert `Foo initializerFor: Bar' syntax to GNU Smalltalk file-out syntax."
    self
	evaluateInitializerFor: stmt arguments first value
	in: stmt receiver!

evaluateGlobalInitializer: stmt
    "Convert `Foo initializer' syntax to GNU Smalltalk file-out syntax."
    | node |
    stmt receiver name = 'Global' ifTrue: [
	node := self parseDoit.
        scanner stripSeparators.
        self step.
	^super evaluate: node ].

    self
	evaluateInitializerFor: stmt receiver name
	in: (RBVariableNode named: 'Smalltalk')!

evaluateInitializerFor: key in: receiver
    | position node arg newStmt |
    position := currentToken start.
    node := RBOptimizedNode
                left: position
                body: self parseDoit
                right: currentToken start.

    scanner stripSeparators.
    self step.
    newStmt := RBMessageNode
	    receiver: receiver
	    selector: #at:put:
	    arguments: { RBLiteralNode value: key asSymbol. node }.
    self evaluateStatement: newStmt!
    
evaluatePoolDefinition: stmt
    "Convert `Foo variable:/constant: ...' syntax to GNU Smalltalk file-out
     syntax."
    | receiver key newStmt |
    receiver := stmt receiver.
    receiver name = 'Global' ifTrue: [ receiver := RBVariableNode named: 'Smalltalk' ].
    key := RBLiteralNode value: stmt arguments first value asSymbol.

    newStmt := RBMessageNode
	    receiver: receiver
	    selector: #at:put:
	    arguments: { key. RBLiteralNode value: nil }.

    self evaluateStatement: newStmt!

evaluatePool: stmt
    "Convert `Pool named: ...' syntax to GNU Smalltalk file-out syntax."
    | key newStmt |
    key := RBLiteralNode value: stmt arguments first value asSymbol .
    newStmt := RBMessageNode
	    receiver: (RBVariableNode named: 'Smalltalk')
	    selector: #addSubspace:
	    arguments: { key }.

    self evaluateStatement: newStmt!
! !

!SIFFileInParser methodsFor: 'private-parsing'!

scannerClass
    "We need a special scanner to convert the double-bangs in strings
     to single bangs.  Unlike in GNU Smalltalk, all bangs must be
     `escaped' in Squeak."
    ^SqueakFileInScanner! !

PK
     �Mh@x�Q06�  6�    RBParser.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Refactoring Browser - Smalltalk parser and scanner
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1998-2000 The Refactory, Inc.
|
| This file is distributed together with GNU Smalltalk.
|
 ======================================================================"



Object subclass: RBParser [
    | scanner currentToken nextToken errorBlock tags source methodCategory |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBParser class >> parseExpression: aString [
	<category: 'accessing'>
	^self parseExpression: aString onError: nil
    ]

    RBParser class >> parseExpression: aString onError: aBlock [
	<category: 'accessing'>
	| node parser |
	parser := self new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString type: #on:errorBlock:.
	node := parser parseExpression.
	^(node statements size == 1 and: [node temporaries isEmpty]) 
	    ifTrue: [node statements first]
	    ifFalse: [node]
    ]

    RBParser class >> parseMethod: aString [
	<category: 'accessing'>
	^self 
	    parseMethod: aString
	    category: nil
	    onError: nil
    ]

    RBParser class >> parseMethod: aString category: aCategory [
	<category: 'accessing'>
	^self 
	    parseMethod: aString
	    category: aCategory
	    onError: nil
    ]

    RBParser class >> parseMethod: aString onError: aBlock [
	<category: 'accessing'>
	^self 
	    parseMethod: aString
	    category: nil
	    onError: aBlock
    ]

    RBParser class >> parseMethod: aString category: aCategory onError: aBlock [
	<category: 'accessing'>
	| parser |
	parser := self new.
	parser methodCategory: aCategory.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString type: #on:errorBlock:.
	^parser parseMethod: aString
    ]

    RBParser class >> parseRewriteExpression: aString [
	<category: 'accessing'>
	^self parseRewriteExpression: aString onError: nil
    ]

    RBParser class >> parseRewriteExpression: aString onError: aBlock [
	<category: 'accessing'>
	| node parser |
	parser := self new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString type: #rewriteOn:errorBlock:.
	node := parser parseExpression.
	^(node statements size == 1 and: [node temporaries isEmpty]) 
	    ifTrue: [node statements first]
	    ifFalse: [node]
    ]

    RBParser class >> parseRewriteMethod: aString [
	<category: 'accessing'>
	^self parseRewriteMethod: aString onError: nil
    ]

    RBParser class >> parseRewriteMethod: aString onError: aBlock [
	<category: 'accessing'>
	| parser |
	parser := self new.
	parser errorBlock: aBlock.
	parser initializeParserWith: aString type: #rewriteOn:errorBlock:.
	^parser parseMethod: aString
    ]

    RBParser class >> parseMethodPattern: aString [
	<category: 'parsing'>
	| parser |
	parser := self new.
	parser errorBlock: [:error :position | ^nil].
	parser initializeParserWith: aString type: #on:errorBlock:.
	^parser parseMessagePattern selector
    ]

    methodCategory [
	<category: 'accessing'>
	^methodCategory
    ]

    methodCategory: aCategory [
	<category: 'accessing'>
	methodCategory := aCategory
    ]

    errorBlock: aBlock [
	<category: 'accessing'>
	errorBlock := aBlock.
	scanner notNil ifTrue: [scanner errorBlock: aBlock]
    ]

    initializeParserWith: aString type: aSymbol [
	<category: 'accessing'>
	source := aString.
	self scanner: (self scannerClass 
		    perform: aSymbol
		    with: (ReadStream on: aString)
		    with: self errorBlock)
    ]

    initializeParserWithStream: aStream type: aSymbol [
	<category: 'accessing'>
	source := nil.
	self scanner: (self scannerClass 
		    perform: aSymbol
		    with: aStream
		    with: self errorBlock)
    ]

    parseExpression [
	<category: 'accessing'>
	| node |
	node := self parseStatements: false.
	self atEnd ifFalse: [self parserError: 'Unknown input at end'].
	^node
    ]

    parseMethod: aString [
	<category: 'accessing'>
	| node |
	node := self parseMethod.
	self atEnd ifFalse: [self parserError: 'Unknown input at end'].
	node source: aString.
	^node
    ]

    scannerClass [
	<category: 'accessing'>
	^RBScanner
    ]

    errorBlock [
	<category: 'error handling'>
	^errorBlock isNil ifTrue: [[:message :position | ]] ifFalse: [errorBlock]
    ]

    errorFile [
	<category: 'error handling'>
	^scanner stream name
    ]

    errorLine [
	<category: 'error handling'>
	^(scanner stream copyFrom: 1 to: self errorPosition) readStream lines 
	    contents size
    ]

    errorPosition [
	<category: 'error handling'>
	^currentToken start
    ]

    parserWarning: aString [
	"Raise a Warning"

	<category: 'error handling'>
	Warning signal: aString
    ]

    parserError: aString [
	"Evaluate the block. If it returns raise an error"

	<category: 'error handling'>
	self errorBlock value: aString value: self errorPosition.
	self 
	    error: '%1:%2: %3' % 
			{self errorFile.
			self errorLine.
			aString}
    ]

    scanner: aScanner [
	<category: 'initialize-release'>
	scanner := aScanner.
	tags := nil.
	self step
    ]

    addCommentsTo: aNode [
	<category: 'private'>
	aNode comments: scanner getComments
    ]

    currentToken [
	<category: 'private'>
	^currentToken
    ]

    nextToken [
	<category: 'private'>
	^nextToken isNil ifTrue: [nextToken := scanner next] ifFalse: [nextToken]
    ]

    step [
	<category: 'private'>
	nextToken notNil 
	    ifTrue: 
		[currentToken := nextToken.
		nextToken := nil.
		^currentToken].
	currentToken := scanner next
    ]

    parseArgs [
	<category: 'private-parsing'>
	| args |
	args := OrderedCollection new.
	[currentToken isIdentifier] whileTrue: [args add: self parseVariableNode].
	^args
    ]

    parseArrayConstructor [
	<category: 'private-parsing'>
	| position node |
	position := currentToken start.
	self step.
	node := RBArrayConstructorNode new.
	node left: position.
	node body: (self parseStatements: false).
	(currentToken isSpecial and: [currentToken value == $}]) 
	    ifFalse: [self parserError: '''}'' expected'].
	node right: currentToken start.
	self step.
	^node
    ]

    parseAssignment [
	"Need one token lookahead to see if we have a ':='. This method could
	 make it possible to assign the literals true, false and nil."

	<category: 'private-parsing'>
	| node position |
	(currentToken isIdentifier and: [self nextToken isAssignment]) 
	    ifFalse: [^self parseCascadeMessage].
	node := self parseVariableNode.
	position := currentToken start.
	self step.
	^RBAssignmentNode 
	    variable: node
	    value: self parseAssignment
	    position: position
    ]

    parseBinaryMessage [
	<category: 'private-parsing'>
	| node |
	node := self parseUnaryMessage.
	[currentToken isBinary] 
	    whileTrue: [node := self parseBinaryMessageWith: node].
	^node
    ]

    parseBinaryMessageNoGreater [
	<category: 'private-parsing'>
	| node |
	node := self parseUnaryMessage.
	[currentToken isBinary and: [currentToken value ~~ #>]] 
	    whileTrue: [node := self parseBinaryMessageWith: node].
	^node
    ]

    parseBinaryMessageWith: aNode [
	<category: 'private-parsing'>
	| binaryToken |
	binaryToken := currentToken.
	self step.
	^RBMessageNode 
	    receiver: aNode
	    selectorParts: (Array with: binaryToken)
	    arguments: (Array with: self parseUnaryMessage)
    ]

    parseBinaryPattern [
	<category: 'private-parsing'>
	| binaryToken |
	currentToken isBinary 
	    ifFalse: [self parserError: 'Message pattern expected'].
	binaryToken := currentToken.
	self step.
	^RBMethodNode selectorParts: (Array with: binaryToken)
	    arguments: (Array with: self parseVariableNode)
    ]

    parseBlock [
	<category: 'private-parsing'>
	| position node |
	position := currentToken start.
	self step.
	node := self parseBlockArgsInto: RBBlockNode new.
	node left: position.
	node body: (self parseStatements: false).
	(currentToken isSpecial and: [currentToken value == $]]) 
	    ifFalse: [self parserError: ''']'' expected'].
	node right: currentToken start.
	self step.
	^node
    ]

    parseBlockArgsInto: node [
	<category: 'private-parsing'>
	| verticalBar args colons |
	args := OrderedCollection new: 2.
	colons := OrderedCollection new: 2.
	verticalBar := false.
	[currentToken isSpecial and: [currentToken value == $:]] whileTrue: 
		[colons add: currentToken start.
		self step.	":"
		verticalBar := true.
		args add: self parseVariableNode].
	verticalBar 
	    ifTrue: 
		[currentToken isBinary 
		    ifTrue: 
			[node bar: currentToken start.
			currentToken value == #| 
			    ifTrue: [self step]
			    ifFalse: 
				[currentToken value == #'||' 
				    ifTrue: 
					["Hack the current token to be the start
					 of temps bar"

					currentToken
					    value: #|;
					    start: currentToken start + 1]
				    ifFalse: [self parserError: '''|'' expected']]]
		    ifFalse: 
			[(currentToken isSpecial and: [currentToken value == $]]) 
			    ifFalse: [self parserError: '''|'' expected']]].
	node
	    arguments: args;
	    colons: colons.
	^node
    ]

    parseCascadeMessage [
	<category: 'private-parsing'>
	| node receiver messages semicolons |
	node := self parseKeywordMessage.
	(currentToken isSpecial 
	    and: [currentToken value == $; and: [node isMessage]]) ifFalse: [^node].
	receiver := node receiver.
	messages := OrderedCollection new: 3.
	semicolons := OrderedCollection new: 3.
	messages add: node.
	[currentToken isSpecial and: [currentToken value == $;]] whileTrue: 
		[semicolons add: currentToken start.
		self step.
		messages add: (currentToken isIdentifier 
			    ifTrue: [self parseUnaryMessageWith: receiver]
			    ifFalse: 
				[currentToken isKeyword 
				    ifTrue: [self parseKeywordMessageWith: receiver]
				    ifFalse: 
					[| temp |
					currentToken isBinary ifFalse: [self parserError: 'Message expected'].
					temp := self parseBinaryMessageWith: receiver.
					temp == receiver ifTrue: [self parserError: 'Message expected'].
					temp]])].
	^RBCascadeNode messages: messages semicolons: semicolons
    ]

    parseKeywordMessage [
	<category: 'private-parsing'>
	^self parseKeywordMessageWith: self parseBinaryMessage
    ]

    parseKeywordMessageWith: node [
	<category: 'private-parsing'>
	| args isKeyword keywords |
	args := OrderedCollection new: 3.
	keywords := OrderedCollection new: 3.
	isKeyword := false.
	[currentToken isKeyword] whileTrue: 
		[keywords add: currentToken.
		self step.
		args add: self parseBinaryMessage.
		isKeyword := true].
	^isKeyword 
	    ifTrue: 
		[RBMessageNode 
		    receiver: node
		    selectorParts: keywords
		    arguments: args]
	    ifFalse: [node]
    ]

    parseKeywordPattern [
	<category: 'private-parsing'>
	| keywords args |
	keywords := OrderedCollection new: 2.
	args := OrderedCollection new: 2.
	[currentToken isKeyword] whileTrue: 
		[keywords add: currentToken.
		self step.
		args add: self parseVariableNode].
	^RBMethodNode selectorParts: keywords arguments: args
    ]

    parseMessagePattern [
	<category: 'private-parsing'>
	^currentToken isIdentifier 
	    ifTrue: [self parseUnaryPattern]
	    ifFalse: 
		[currentToken isKeyword 
		    ifTrue: [self parseKeywordPattern]
		    ifFalse: [self parseBinaryPattern]]
    ]

    parseMethod [
	<category: 'private-parsing'>
	| methodNode |
	methodNode := self parseMessagePattern.
	^self parseMethodInto: methodNode
    ]

    parseMethodInto: methodNode [
	<category: 'private-parsing'>
	tags := nil.
	self parseResourceTag.
	self addCommentsTo: methodNode.
	methodNode body: (self parseStatements: true).
	methodNode tags: tags.
	methodNode category: methodCategory.
	^methodNode
    ]

    parseOptimizedExpression [
	<category: 'private-parsing'>
	| position node |
	position := currentToken start.
	self step.
	node := RBOptimizedNode 
		    left: position
		    body: (self parseStatements: false)
		    right: currentToken start.
	(currentToken isSpecial and: [currentToken value == $)]) 
	    ifFalse: [self parserError: ''')'' expected'].
	self step.
	^node
    ]

    parseParenthesizedExpression [
	<category: 'private-parsing'>
	| leftParen node |
	leftParen := currentToken start.
	self step.
	node := self parseAssignment.
	^(currentToken isSpecial and: [currentToken value == $)]) 
	    ifTrue: 
		[node addParenthesis: (leftParen to: currentToken start).
		self step.
		node]
	    ifFalse: [self parserError: ''')'' expected']
    ]

    parsePatternBlock [
	<category: 'private-parsing'>
	| position node |
	position := currentToken start.
	self step.
	node := self parseBlockArgsInto: RBPatternBlockNode new.
	node left: position.
	node body: (self parseStatements: false).
	(currentToken isSpecial and: [currentToken value == $}]) 
	    ifFalse: [self parserError: '''}'' expected'].
	node right: currentToken start.
	self step.
	^node
    ]

    parsePrimitiveIdentifier [
	<category: 'private-parsing'>
	| value token |
	token := currentToken.
	value := currentToken value.
	self step.
	value = 'true' 
	    ifTrue: 
		[^RBLiteralNode literalToken: (RBLiteralToken 
			    value: true
			    start: token start
			    stop: token start + 3)].
	value = 'false' 
	    ifTrue: 
		[^RBLiteralNode literalToken: (RBLiteralToken 
			    value: false
			    start: token start
			    stop: token start + 4)].
	value = 'nil' 
	    ifTrue: 
		[^RBLiteralNode literalToken: (RBLiteralToken 
			    value: nil
			    start: token start
			    stop: token start + 2)].
	^RBVariableNode identifierToken: token
    ]

    parseNegatedNumber [
	<category: 'private-parsing'>
	| token |
	self step.
	token := currentToken.
	(token value respondsTo: #negated) ifFalse: [
	    ^self parserError: 'Number expected' ].
	token value negative ifTrue: [
	    ^self parserError: 'Positive number expected' ].
	token value: token value negated.
	self step.
	^RBLiteralNode literalToken: token
    ]

    parsePrimitiveLiteral [
	<category: 'private-parsing'>
	| token |
	token := currentToken.
	self step.
	^RBLiteralNode literalToken: token
    ]

    parsePrimitiveObject [
	<category: 'private-parsing'>
	currentToken isIdentifier ifTrue: [^self parsePrimitiveIdentifier].
	currentToken isLiteral ifTrue: [^self parsePrimitiveLiteral].
	(currentToken isBinary and: [ currentToken value == #- ])
	    ifTrue: [^self parseNegatedNumber].
	currentToken isSpecial 
	    ifTrue: 
		[currentToken value == $[ ifTrue: [^self parseBlock].
		currentToken value == ${ ifTrue: [^self parseArrayConstructor].
		currentToken value == $( ifTrue: [^self parseParenthesizedExpression]].
	currentToken isPatternBlock ifTrue: [^self parsePatternBlock].
	currentToken isOptimized ifTrue: [^self parseOptimizedExpression].
	self parserError: 'Variable expected'
    ]

    parseResourceTag [
	<category: 'private-parsing'>
	| start |
	[currentToken isBinary and: [currentToken value == #<]] whileTrue: 
		[start := currentToken start.
		self step.
		[scanner atEnd or: [currentToken isBinary and: [currentToken value == #>]]] 
		    whileFalse: [self step].
		(currentToken isBinary and: [currentToken value == #>]) 
		    ifFalse: [self parserError: '''>'' expected'].
		tags isNil 
		    ifTrue: [tags := OrderedCollection with: (start to: currentToken stop)]
		    ifFalse: [tags add: (start to: currentToken stop)].
		self step]
    ]

    parseStatementList: tagBoolean into: sequenceNode [
	<category: 'private-parsing'>
	| statements return periods returnPosition node |
	return := false.
	statements := OrderedCollection new.
	periods := OrderedCollection new.
	self addCommentsTo: sequenceNode.
	tagBoolean ifTrue: [self parseResourceTag].
	
	[self atEnd 
	    or: [currentToken isSpecial and: ['!])}' includes: currentToken value]]] 
		whileFalse: 
		    [return ifTrue: [self parserError: 'End of statement list encountered'].
		    (currentToken isSpecial and: [currentToken value == $^]) 
			ifTrue: 
			    [returnPosition := currentToken start.
			    self step.
			    node := RBReturnNode return: returnPosition value: self parseAssignment.
			    self addCommentsTo: node.
			    statements add: node.
			    return := true]
			ifFalse: 
			    [node := self parseAssignment.
			    self addCommentsTo: node.
			    statements add: node].
		    (currentToken isSpecial and: [currentToken value == $.]) 
			ifTrue: 
			    [periods add: currentToken start.
			    self step]
			ifFalse: [return := true]].
	sequenceNode
	    statements: statements;
	    periods: periods.
	^sequenceNode
    ]

    parseStatements: tagBoolean [
	<category: 'private-parsing'>
	| args leftBar rightBar |
	args := #().
	leftBar := rightBar := nil.
	currentToken isBinary 
	    ifTrue: 
		[currentToken value == #| 
		    ifTrue: 
			[leftBar := currentToken start.
			self step.
			args := self parseArgs.
			(currentToken isBinary and: [currentToken value = #|]) 
			    ifFalse: [self parserError: '''|'' expected'].
			rightBar := currentToken start.
			self step]
		    ifFalse: 
			[currentToken value == #'||' 
			    ifTrue: 
				[rightBar := (leftBar := currentToken start) + 1.
				self step]]].
	^self parseStatementList: tagBoolean
	    into: (RBSequenceNode 
		    leftBar: leftBar
		    temporaries: args
		    rightBar: rightBar)
    ]

    parseUnaryMessage [
	<category: 'private-parsing'>
	| node |
	node := self parsePrimitiveObject.
	[currentToken isIdentifier] 
	    whileTrue: [node := self parseUnaryMessageWith: node].
	^node
    ]

    parseUnaryMessageWith: aNode [
	<category: 'private-parsing'>
	| selector |
	selector := currentToken.
	self step.
	^RBMessageNode 
	    receiver: aNode
	    selectorParts: (Array with: selector)
	    arguments: #()
    ]

    parseUnaryPattern [
	<category: 'private-parsing'>
	| selector |
	selector := currentToken.
	self step.
	^RBMethodNode selectorParts: (Array with: selector) arguments: #()
    ]

    parseVariableNode [
	<category: 'private-parsing'>
	| node |
	currentToken isIdentifier 
	    ifFalse: [self parserError: 'Variable name expected'].
	node := RBVariableNode identifierToken: currentToken.
	self step.
	^node
    ]

    atEnd [
	<category: 'testing'>
	^currentToken class == RBToken
    ]
]



Stream subclass: RBScanner [
    | stream buffer tokenStart currentCharacter characterType classificationTable saveComments comments extendedLanguage errorBlock |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    ClassificationTable := nil.
    PatternVariableCharacter := nil.

    RBScanner class >> classificationTable [
	<category: 'accessing'>
	ClassificationTable isNil ifTrue: [self initialize].
	^ClassificationTable
    ]

    RBScanner class >> patternVariableCharacter [
	<category: 'accessing'>
	^PatternVariableCharacter
    ]

    RBScanner class >> initialize [
	<category: 'class initialization'>
	PatternVariableCharacter := $`.
	ClassificationTable := Array new: 255.
	self 
	    initializeChars: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'
	    to: #alphabetic.
	self initializeChars: '01234567890' to: #digit.
	self initializeChars: '%&*+,-/<=>?@\~|' to: #binary.
	self initializeChars: '{}().:;[]^!' to: #special.
	#(9 10 12 13 26 32) do: [:i | ClassificationTable at: i put: #separator]
    ]

    RBScanner class >> initializeChars: characters to: aSymbol [
	<category: 'class initialization'>
	characters do: [:c | ClassificationTable at: c asInteger put: aSymbol]
    ]

    RBScanner class >> on: aStream [
	<category: 'instance creation'>
	| str |
	str := self basicNew on: aStream.
	str step.
	str stripSeparators.
	^str
    ]

    RBScanner class >> on: aStream errorBlock: aBlock [
	<category: 'instance creation'>
	| str |
	str := self basicNew on: aStream.
	str
	    errorBlock: aBlock;
	    step;
	    stripSeparators.
	^str
    ]

    RBScanner class >> rewriteOn: aStream [
	<category: 'instance creation'>
	| str |
	str := self basicNew on: aStream.
	str
	    extendedLanguage: true;
	    ignoreComments.
	str step.
	str stripSeparators.
	^str
    ]

    RBScanner class >> rewriteOn: aStream errorBlock: aBlock [
	<category: 'instance creation'>
	| str |
	str := self basicNew on: aStream.
	str
	    extendedLanguage: true;
	    ignoreComments;
	    errorBlock: aBlock;
	    step;
	    stripSeparators.
	^str
    ]

    RBScanner class >> isSelector: aSymbol [
	<category: 'testing'>
	| scanner token |
	scanner := self basicNew.
	scanner on: (ReadStream on: aSymbol asString).
	scanner step.
	token := scanner scanAnySymbol.
	token isLiteral ifFalse: [^false].
	token value isEmpty ifTrue: [^false].
	^scanner atEnd
    ]

    RBScanner class >> isVariable: aString [
	<category: 'testing'>
	| scanner token |
	aString isString ifFalse: [^false].
	aString isEmpty ifTrue: [^false].
	(ClassificationTable at: aString first asInteger) == #alphabetic 
	    ifFalse: [^false].
	scanner := self basicNew.
	scanner on: (ReadStream on: aString asString).
	scanner errorBlock: [:s :p | ^false].
	scanner step.
	token := scanner scanIdentifierOrKeyword.
	token isKeyword ifTrue: [^false].
	^scanner atEnd
    ]

    classificationTable: anObject [
	<category: 'accessing'>
	classificationTable := anObject
    ]

    contents [
	<category: 'accessing'>
	| contentsStream |
	contentsStream := WriteStream on: (Array new: 50).
	self do: [:each | contentsStream nextPut: each].
	^contentsStream contents
    ]

    errorBlock: aBlock [
	<category: 'accessing'>
	errorBlock := aBlock
    ]

    extendedLanguage [
	<category: 'accessing'>
	^extendedLanguage
    ]

    extendedLanguage: aBoolean [
	<category: 'accessing'>
	extendedLanguage := aBoolean
    ]

    flush [
	<category: 'accessing'>
	
    ]

    getComments [
	<category: 'accessing'>
	| oldComments |
	comments isEmpty ifTrue: [^nil].
	oldComments := comments.
	comments := OrderedCollection new: 1.
	^oldComments
    ]

    ignoreComments [
	<category: 'accessing'>
	saveComments := false
    ]

    next [
	<category: 'accessing'>
	| token |
	buffer reset.
	tokenStart := stream position.
	characterType == #eof ifTrue: [^RBToken start: tokenStart + 1].	"The EOF token should occur after the end of input"
	token := self scanToken.
	self stripSeparators.
	^token
    ]

    nextPut: anObject [
	"Provide an error notification that the receiver does not
	 implement this message."

	<category: 'accessing'>
	self shouldNotImplement
    ]

    saveComments [
	<category: 'accessing'>
	saveComments := true
    ]

    scanToken [
	"fast-n-ugly. Don't write stuff like this. Has been found to cause cancer in laboratory rats. Basically a
	 case statement. Didn't use Dictionary because lookup is pretty slow."

	<category: 'accessing'>
	characterType == #alphabetic ifTrue: [^self scanIdentifierOrKeyword].
	characterType == #digit ifTrue: [^self scanNumber].
	characterType == #binary ifTrue: [^self scanBinary: RBBinarySelectorToken].
	characterType == #special ifTrue: [^self scanSpecialCharacter].
	currentCharacter == $' ifTrue: [^self scanLiteralString].
	currentCharacter == $# ifTrue: [^self scanLiteral].
	currentCharacter == $$ ifTrue: [^self scanLiteralCharacter].
	(extendedLanguage and: [currentCharacter == PatternVariableCharacter]) 
	    ifTrue: [^self scanPatternVariable].
	^self scannerError: 'Unknown character'
    ]

    position [
	<category: 'accessing'>
	^stream position
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    errorBlock [
	<category: 'error handling'>
	^errorBlock isNil ifTrue: [[:message :position | ]] ifFalse: [errorBlock]
    ]

    errorPosition [
	<category: 'error handling'>
	^stream position
    ]

    scannerError: aString [
	"Evaluate the block. If it returns raise an error"

	<category: 'error handling'>
	self errorBlock value: aString value: self errorPosition.
	self error: aString
    ]

    on: aStream [
	<category: 'initialize-release'>
	buffer := WriteStream on: (String new: 60).
	stream := aStream.
	classificationTable := self class classificationTable.
	saveComments := true.
	extendedLanguage := false.
	comments := OrderedCollection new
    ]

    classify: aCharacter [
	<category: 'private'>
	| index |
	aCharacter isNil ifTrue: [^nil].
	index := aCharacter asInteger.
	index == 0 ifTrue: [^#separator].
	index > 255 ifTrue: [^nil].
	^classificationTable at: index
    ]

    previousStepPosition [
	<category: 'private'>
	^characterType == #eof 
	    ifTrue: [stream position]
	    ifFalse: [stream position - 1]
    ]

    step [
	<category: 'private'>
	stream atEnd 
	    ifTrue: 
		[characterType := #eof.
		^currentCharacter := nil].
	currentCharacter := stream next.
	characterType := self classify: currentCharacter.
	^currentCharacter
    ]

    isDigit: aChar base: base [
	<category: 'private-scanning numbers'>
	aChar isNil ifTrue: [^false].
	base <= 10 
	    ifTrue: 
		[aChar isDigit ifFalse: [^false].
		^aChar value - $0 value < base].
	^aChar isUppercase 
	    ifTrue: [aChar value - $A value < (base - 10)]
	    ifFalse: [aChar isDigit]
    ]

    scanDigits: ch base: base [
	<category: 'private-scanning numbers'>
	| c num |
	c := ch.
	num := 0.
	
	[[c == $_] whileTrue: 
		[self step.
		c := currentCharacter].
	c notNil and: [self isDigit: c base: base]] 
		whileTrue: 
		    [num := num * base + c digitValue.
		    self step.
		    c := currentCharacter].
	^num
    ]

    scanExtendedLiterals [
	<category: 'private-scanning numbers'>
	| token |
	self step.
	currentCharacter == $( 
	    ifTrue: 
		[self step.
		^RBOptimizedToken start: tokenStart].
	self scannerError: 'Expecting parentheses'
    ]

    scanFraction: ch num: num base: base return: aBlock [
	<category: 'private-scanning numbers'>
	| c scale result |
	c := ch.
	scale := 0.
	result := num.
	
	[[c == $_] whileTrue: 
		[self step.
		c := currentCharacter].
	c notNil and: [self isDigit: c base: base]] 
		whileTrue: 
		    [result := result * base + c digitValue.
		    self step.
		    c := currentCharacter.
		    scale := scale - 1].
	aBlock value: result value: scale
    ]

    scanNumberValue [
	<category: 'private-scanning numbers'>
	| isNegative base exponent scale ch num |
	isNegative := false.
	exponent := nil.

	"could be radix or base-10 mantissa"
	num := self scanDigits: currentCharacter base: 10.
	currentCharacter == $r 
	    ifTrue: 
		[base := num truncated.
		self step	"skip over 'r'".
		currentCharacter == $- 
		    ifTrue: 
			[isNegative := true.
			self step	"skip '-'"].
		(self isDigit: currentCharacter base: base) 
		    ifTrue: [num := self scanDigits: currentCharacter base: base]
		    ifFalse: [self error: 'malformed number']]
	    ifFalse: [base := 10].

	"Here we've either
	 a) parsed base, an 'r' and are sitting on the following character
	 b) parsed the integer part of the mantissa, and are sitting on the char
	 following it, or
	 c) parsed nothing and are sitting on a - sign."
	currentCharacter == $. 
	    ifTrue: 
		[(self isDigit: stream peek base: base)
		    ifTrue: 
			[self step.
			self 
			    scanFraction: currentCharacter
			    num: num
			    base: base
			    return: 
				[:n :s | 
				num := n.
				exponent := s]]].
	isNegative ifTrue: [num := num negated].
	currentCharacter == $s 
	    ifTrue: 
		[self step.
		currentCharacter isNil ifTrue: [currentCharacter := Character space].
		exponent isNil ifTrue: [exponent := 0].
		currentCharacter isDigit 
		    ifTrue: [scale := self scanDigits: currentCharacter base: 10]
		    ifFalse: 
			["Might sit on the beginning of an identifier such as 123stu,
			 or on a ScaledDecimal literal lacking the scale such as 123s"
			(currentCharacter == $_ or: [currentCharacter isLetter]) 
			    ifTrue: 
				[stream skip: -1.
				currentCharacter := $s]
			    ifFalse: [scale := exponent negated]].
		^num asScaledDecimal: exponent radix: base scale: scale].
	currentCharacter == $e 
	    ifTrue: [num := num asFloatE]
	    ifFalse: 
		[currentCharacter == $d 
		    ifTrue: [num := num asFloatD]
		    ifFalse: 
			[currentCharacter == $q 
			    ifTrue: [num := num asFloatQ]
			    ifFalse: 
				[^exponent isNil 
				    ifTrue: [num]
				    ifFalse: [num asFloat * (base raisedToInteger: exponent)]]]].
	ch := currentCharacter.
	self step.
	currentCharacter isNil ifTrue: [currentCharacter := Character space].
	(currentCharacter == $_ or: [currentCharacter isLetter]) 
	    ifTrue: 
		[stream skip: -1.
		currentCharacter := ch].
	exponent isNil ifTrue: [exponent := 0].
	currentCharacter == $- 
	    ifTrue: 
		[self step.
		exponent := exponent - (self scanDigits: currentCharacter base: 10)]
	    ifFalse: 
		[currentCharacter isDigit 
		    ifTrue: [exponent := exponent + (self scanDigits: currentCharacter base: 10)]].
	^num * (base raisedToInteger: exponent)
    ]

    scanAnySymbol [
	<category: 'private-scanning'>
	characterType == #alphabetic ifTrue: [^self scanSymbol].
	characterType == #binary ifTrue: [^self scanBinary: RBLiteralToken].
	^RBToken new
    ]

    scanBinary: aClass [
	"This doesn't parse according to the ANSI draft. It only parses 1 or 2 letter binary tokens."

	<category: 'private-scanning'>
	| val |
	buffer nextPut: currentCharacter.
	self step.
	(characterType == #binary and: [currentCharacter ~~ $-]) 
	    ifTrue: 
		[buffer nextPut: currentCharacter.
		self step].
	val := buffer contents.
	val := val asSymbol.
	^aClass value: val start: tokenStart
    ]

    scanByteArray [
	<category: 'private-scanning'>
	| byteStream number |
	byteStream := WriteStream on: (ByteArray new: 100).
	self step.
	
	[self stripSeparators.
	characterType == #digit] whileTrue: 
		    [number := self scanNumber value.
		    (number isInteger and: [number between: 0 and: 255]) 
			ifFalse: [self scannerError: 'Expecting 8-bit integer'].
		    byteStream nextPut: number].
	currentCharacter == $] ifFalse: [self scannerError: ''']'' expected'].
	self step.	"]"
	^RBLiteralToken 
	    value: byteStream contents
	    start: tokenStart
	    stop: self previousStepPosition
    ]

    scanIdentifierOrKeyword [
	<category: 'private-scanning'>
	| tokenType token |
	currentCharacter == $_ ifTrue: [^self scanAssignment].
	self scanName.
	token := self scanNamespaceName.
	token isNil 
	    ifTrue: 
		[tokenType := (currentCharacter == $: and: [stream peek ~~ $=]) 
			    ifTrue: 
				[buffer nextPut: currentCharacter.
				self step.	":"
				RBKeywordToken]
			    ifFalse: [RBIdentifierToken].
		token := tokenType value: buffer contents start: tokenStart].
	^token
    ]

    scanNamespaceName [
	<category: 'private-scanning'>
	| token |
	currentCharacter == $. 
	    ifTrue: 
		[(stream atEnd or: [(self classify: stream peek) ~~ #alphabetic]) 
		    ifTrue: [^nil]]
	    ifFalse: 
		[(currentCharacter == $: and: [stream peek == $:]) ifFalse: [^nil].
		self step].
	buffer nextPut: $..
	self step.
	self scanName.
	token := self scanNamespaceName.
	token isNil 
	    ifTrue: [token := RBIdentifierToken value: buffer contents start: tokenStart].
	^token
    ]

    scanLiteral [
	<category: 'private-scanning'>
	self step.
	self stripSeparators.
	characterType == #alphabetic ifTrue: [^self scanSymbol].
	characterType == #binary 
	    ifTrue: [^(self scanBinary: RBLiteralToken) stop: self previousStepPosition].
	currentCharacter == $' ifTrue: [^self scanStringSymbol].
	currentCharacter == $( ifTrue: [^self scanLiteralArray].
	currentCharacter == $[ ifTrue: [^self scanByteArray].
	currentCharacter == ${ ifTrue: [^self scanQualifier].
	currentCharacter == $# ifTrue: [^self scanExtendedLiterals].
	self scannerError: 'Expecting a literal type'
    ]

    scanLiteralArray [
	<category: 'private-scanning'>
	| arrayStream start |
	arrayStream := WriteStream on: (Array new: 10).
	self step.
	start := tokenStart.
	
	[self stripSeparators.
	tokenStart := stream position.
	currentCharacter == $)] 
		whileFalse: 
		    [arrayStream nextPut: self scanLiteralArrayParts.
		    buffer reset].
	self step.
	^RBLiteralToken 
	    value: arrayStream contents
	    start: start
	    stop: self previousStepPosition
    ]

    scanLiteralArrayParts [
	<category: 'private-scanning'>
	currentCharacter == $# ifTrue: [^self scanLiteral].
	characterType == #alphabetic 
	    ifTrue: 
		[| token value |
		token := self scanSymbol.
		value := token value.
		value == #nil ifTrue: [token value: nil].
		value == #true ifTrue: [token value: true].
		value == #false ifTrue: [token value: false].
		^token].
	(characterType == #digit 
	    or: [currentCharacter == $- and: [(self classify: stream peek) == #digit]]) 
		ifTrue: [^self scanNumber].
	characterType == #binary 
	    ifTrue: [^(self scanBinary: RBLiteralToken) stop: self previousStepPosition].
	currentCharacter == $' ifTrue: [^self scanLiteralString].
	currentCharacter == $$ ifTrue: [^self scanLiteralCharacter].
	currentCharacter == $( ifTrue: [^self scanLiteralArray].
	currentCharacter == $[ ifTrue: [^self scanByteArray].
	^self scannerError: 'Unknown character in literal array'
    ]

    scanLiteralCharacter [
	<category: 'private-scanning'>
	| token value char tokenStop |
	self step.	"$"
	tokenStop := stream position.
	char := currentCharacter.
	self step.	"char"
	char = $< 
	    ifTrue: 
		[self stripSeparators.
		characterType == #digit 
		    ifTrue: 
			[value := self scanNumberValue.
			(value isInteger and: [value between: 0 and: 1114111]) 
			    ifFalse: [^self scannerError: 'Integer between 0 and 16r10FFFF expected'].
			char := Character codePoint: value.
			self stripSeparators.
			tokenStop := stream position.
			currentCharacter = $> 
			    ifTrue: [self step]
			    ifFalse: [^self scannerError: '''>'' expected']]].
	^RBLiteralToken 
	    value: char
	    start: tokenStart
	    stop: tokenStop
    ]

    scanLiteralString [
	<category: 'private-scanning'>
	self step.
	
	[currentCharacter isNil 
	    ifTrue: [self scannerError: 'Unmatched '' in string literal.'].
	currentCharacter == $' and: [self step ~~ $']] 
		whileFalse: 
		    [buffer nextPut: currentCharacter.
		    self step].
	^RBLiteralToken 
	    value: buffer contents
	    start: tokenStart
	    stop: self previousStepPosition
    ]

    scanPatternVariable [
	<category: 'private-scanning'>
	buffer nextPut: currentCharacter.
	self step.
	currentCharacter == ${ 
	    ifTrue: 
		[self step.
		^RBPatternBlockToken value: '`{' start: tokenStart].
	[characterType == #alphabetic] whileFalse: 
		[characterType == #eof 
		    ifTrue: [self scannerError: 'Pattern variable expected'].
		buffer nextPut: currentCharacter.
		self step].
	^self scanIdentifierOrKeyword
    ]

    scanName [
	<category: 'private-scanning'>
	[characterType == #alphabetic or: [characterType == #digit]] whileTrue: 
		[buffer nextPut: currentCharacter.
		self step]
    ]

    scanNumber [
	<category: 'private-scanning'>
	^RBLiteralToken 
	    value: self scanNumberValue
	    start: tokenStart
	    stop: self previousStepPosition
    ]

    scanQualifier [
	<category: 'private-scanning'>
	| nameStream |
	self step.	"{"
	nameStream := WriteStream on: (String new: 10).
	[currentCharacter == $}] whileFalse: 
		[nameStream nextPut: currentCharacter.
		self step].
	self step.	"}"
	^RBBindingToken 
	    value: nameStream contents
	    start: tokenStart
	    stop: self previousStepPosition
    ]

    scanAssignment [
	<category: 'private-scanning'>
	self step.
	^RBAssignmentToken start: tokenStart
    ]

    scanSpecialCharacter [
	<category: 'private-scanning'>
	| character |
	currentCharacter == $: 
	    ifTrue: 
		[self step.
		^currentCharacter == $= 
		    ifTrue: [self scanAssignment]
		    ifFalse: [RBSpecialCharacterToken value: $: start: tokenStart]].
	character := currentCharacter.
	self step.
	^RBSpecialCharacterToken value: character start: tokenStart
    ]

    scanStringSymbol [
	<category: 'private-scanning'>
	| literalToken |
	literalToken := self scanLiteralString.
	literalToken value: literalToken value asSymbol.
	^literalToken
    ]

    scanSymbol [
	<category: 'private-scanning'>
	| lastPosition hasColon value startPosition |
	hasColon := false.
	startPosition := lastPosition := stream position.
	[characterType == #alphabetic] whileTrue: 
		[self scanName.
		currentCharacter == $: 
		    ifTrue: 
			[buffer nextPut: $:.
			hasColon := true.
			lastPosition := stream position.
			self step]].
	value := buffer contents.
	(hasColon and: [value last ~~ $:]) 
	    ifTrue: 
		[stream position: lastPosition.
		self step.
		value := value copyFrom: 1 to: lastPosition - startPosition + 1].
	^RBLiteralToken 
	    value: value asSymbol
	    start: tokenStart
	    stop: self previousStepPosition
    ]

    stripComment [
	<category: 'private-scanning'>
	| start stop |
	start := stream position.
	[self step == $"] whileFalse: 
		[characterType == #eof 
		    ifTrue: [self scannerError: 'Unmatched " in comment.']].
	stop := stream position.
	self step.
	saveComments ifFalse: [^self].
	comments add: (start to: stop)
    ]

    stripSeparators [
	<category: 'private-scanning'>
	
	[[characterType == #separator] whileTrue: [self step].
	currentCharacter == $"] 
		whileTrue: [self stripComment]
    ]

    atEnd [
	<category: 'testing'>
	^characterType == #eof
    ]

    isReadable [
	<category: 'testing'>
	^true
    ]

    isWritable [
	<category: 'testing'>
	^false
    ]
]



RBParser subclass: RBBracketedMethodParser [

    <category: 'Refactory-Parser'>
    <comment: 'A subclass of RBParser that discards a pair of brackets around
methods.'>

    skipToken: tokenValue [
        currentToken isValue ifFalse: [^false].
        (currentToken value = tokenValue)
            ifTrue: [self step. ^true]
            ifFalse: [^false]
    ]

    skipExpectedToken: tokenValue [
        (self skipToken: tokenValue)
            ifFalse: [self parserError: ('expected ' , tokenValue asSymbol)]
    ]

    parseMethodInto: methodNode [
        <category: 'private-parsing'>
        self skipExpectedToken: $[.
       super parseMethodInto: methodNode.
        self skipExpectedToken: $].
        ^methodNode
    ]
]


Eval [
    RBScanner initialize
]
PK
     �Mh@�kFp�+  �+    STLoader.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Smalltalk proxy class loader
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2002, 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

STParsingDriver subclass: #STInterpreter
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: 'System-Compiler'
!

STInterpreter class
       instanceVariableNames: 'evaluationMethods'
!

STInterpreter comment:
'This class does simple interpretation of the chunks that make up a
file-in.'!

STInterpreter subclass: #STClassLoader
       instanceVariableNames: 'loadedClasses proxies proxyNilClass currentClass
			       currentCategory currentNamespace defaultNamespace'
       classVariableNames: ''
       poolDictionaries: 'STClassLoaderObjects'
       category: 'System-Compiler'
!

STClassLoader comment:
'This class creates non-executable proxies for the classes it loads in.
It does not work if classes are created dynamically, but otherwise it
does it job well.'!

!STInterpreter class methodsFor: 'accessing'!

evaluationMethods
    ^evaluationMethods!

toEvaluate: interpretedSelector perform: selector
    evaluationMethods isNil
	ifTrue: [ evaluationMethods := IdentityDictionary new ].

    evaluationMethods at: interpretedSelector put: selector! !

!STInterpreter methodsFor: 'overrides'!

evaluationMethodFor: selector
    | method class |
    class := self class.
    [
        class evaluationMethods isNil ifFalse: [
            method := class evaluationMethods at: selector ifAbsent: [ nil ].
	    method isNil ifFalse: [ ^method ].
	].
	class == STInterpreter ifTrue: [ ^nil ].
	class := class superclass
    ] repeat
!

evaluateStatement: node
    | method |
    method := self evaluationMethodFor: node selector.
    (method isNil)
        ifTrue: [ ^self unknown: node ]
        ifFalse: [ ^self
	                perform: method
	                with: node receiver
	                with: node selector
	                with: node arguments ]
!

evaluate: node
    ^node statements 
	inject: false
	into: [ :old :each |
	    "We *do not* want short-circuit evaluation here!!"
	    | node |
	    node := each.
	    each isReturn
		ifTrue: [ node := each value ].

	    node isMessage
		ifTrue: [ old | (self evaluateStatement: node) ]
		ifFalse: [ self unknown: node ].
        ]
!

unknown: node
    ^false
! !

!STClassLoader class methodsFor: 'accessing'!

initialize
    self
	toEvaluate: #subclass:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #subclass:environment:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variable:subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableWordSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableByteSubclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #subclass:declaration:classVariableNames:poolDictionaries:category:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #subclass:instanceVariableNames:classVariableNames:poolDictionaries:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variable:subclass:instanceVariableNames:classVariableNames:poolDictionaries:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableSubclass:instanceVariableNames:classVariableNames:poolDictionaries:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableWordSubclass:instanceVariableNames:classVariableNames:poolDictionaries:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #variableByteSubclass:instanceVariableNames:classVariableNames:poolDictionaries:
	perform: #doSubclass:selector:arguments:;

	toEvaluate: #methodsFor:
	perform: #doMethodsFor:selector:arguments:;

	toEvaluate: #addSubspace:
	perform: #doAddNamespace:selector:arguments:;

	toEvaluate: #current:
	perform: #doSetNamespace:selector:arguments:;

	toEvaluate: #import:
	perform: #doImport:selector:arguments:;

	toEvaluate: #category:
	perform: #doSend:selector:arguments:;

	toEvaluate: #comment:
	perform: #doSend:selector:arguments:;

	toEvaluate: #shape:
	perform: #doSend:selector:arguments:;

	toEvaluate: #addClassVarName:
	perform: #doSend:selector:arguments:;
	
	toEvaluate: #addClassVarName:value:
	perform: #doAddClassVarName:selector:arguments:;

	toEvaluate: #instanceVariableNames:
	perform: #doSend:selector:arguments:
! !

!STClassLoader class methodsFor: 'instance creation'!

new
    ^self basicNew initialize
! !

!STClassLoader methodsFor: 'accessing'!

currentNamespace
    ^currentNamespace!

currentNamespace: ns
    currentNamespace := self proxyForNamespace: ns!

proxyNilClass
    proxyNilClass isNil ifTrue: [ proxyNilClass := ProxyNilClass on: nil for: self ].
    ^proxyNilClass!
    
proxyForNamespace: anObject
    anObject isNamespace ifFalse: [ ^anObject ].
    ^proxies at: anObject ifAbsentPut: [
	ProxyNamespace on: anObject for: self ]!

proxyForClass: anObject
    anObject isClass ifFalse: [ ^anObject ].
    ^proxies at: anObject ifAbsentPut: [
	ProxyClass on: anObject for: self ]! !

!STClassLoader methodsFor: 'initializing'!

defaultNamespace
    ^defaultNamespace
!

initialNamespace
    ^Namespace current
!

initialize
    loadedClasses := OrderedSet new.
    proxies := IdentityDictionary new.
    defaultNamespace := self proxyForNamespace: self initialNamespace.
    currentNamespace := defaultNamespace.
! !

!STClassLoader methodsFor: 'overrides'!

loadedClasses
    ^loadedClasses
!

fullyDefinedLoadedClasses
    ^loadedClasses select: [ :each | each isFullyDefined ]
!

result
    "This is what #parseSmalltalk answers"
    ^self loadedClasses
!

endMethodList
    currentClass := nil
!

defineMethod: node 
    node category: currentCategory.
    ^currentClass methodDictionary
        at: (node selector asSymbol)
        put: (LoadedMethod node: node)
!

compile: node
    ^self defineMethod: node
! !

!STClassLoader methodsFor: 'evaluating statements'!

defineSubclass: receiver selector: selector arguments: argumentNodes
    | class arguments newClass |
    
    class := self resolveClass: receiver.
    arguments := argumentNodes collect: [ :each | each value ].
    newClass := class perform: selector withArguments: arguments asArray.
    loadedClasses add: newClass.
    proxies at: newClass put: newClass.
    ^newClass
!

doSubclass: receiver selector: selector arguments: argumentNodes
   
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^false ].
    
    self defineSubclass: receiver selector: selector arguments: argumentNodes.
    ^false
!

doSend: receiver selector: selector arguments: argumentNodes
    | isClass class |
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^false ].

    isClass := receiver isMessage and: [ receiver selector = #class ].
    class := isClass
	ifTrue: [ (self resolveClass: receiver receiver) asMetaclass ]
	ifFalse: [ self resolveClass: receiver ].

    class perform: selector with: argumentNodes first value.
    ^false
!

doAddClassVarName: receiver selector: selector arguments: argumentNodes
    | class classVarName value |
    class := self resolveClass: receiver.
    classVarName := argumentNodes first value asString.
    value := argumentNodes last.
    class addClassVarName: classVarName value: value.
    ^false
!

doImport: receiver selector: selector arguments: argumentNodes
    | class namespace |
    receiver isMessage ifTrue: [ ^false ].
    class := self resolveClass: receiver.
    namespace := self resolveNamespace: argumentNodes first.
    class import: namespace.
    ^false
!

doSetNamespace: receiver selector: selector arguments: argumentNodes
    | ns |
    receiver isVariable ifFalse: [ ^false ].
    receiver name = 'Namespace' ifFalse: [ ^false ].

    ns := self resolveNamespace: argumentNodes first.
    self currentNamespace: ns.
    ^false
!

doAddNamespace: receiver selector: selector arguments: argumentNodes
    | root |
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^false ].

    root := self resolveNamespace: receiver.
    root addSubspace: argumentNodes first value.
    ^false
!

doMethodsFor: receiver selector: selector arguments: argumentNodes
    | class |
    (argumentNodes allSatisfy: [ :each | each isLiteral ])
	ifFalse: [ ^false ].

    currentClass := self resolveClass: receiver.
    currentCategory := argumentNodes first value.
    ^true
!

resolveClass: node
    | object |
    (node isMessage and: [ node selector = #class or: [ node selector = #classSide ]])
	ifTrue: [ ^(self resolveClass: node receiver) asMetaclass ].
    node isLiteral ifTrue: [
        "Dictionary cannot have nil as a key, use the entire RBLiteralNode."
        ^self proxyNilClass ].
        
    object := self
	resolveName: node
	isNamespace: [ :index :size | index < size ].
    ^self proxyForClass: object
!

resolveNamespace: node
    | object |
    object := self
	resolveName: node
	isNamespace: [ :index :size | true ].

    ^self proxyForNamespace: object
!

resolveName: node isNamespace: aBlock
    | current selectors |
    current := node.
    selectors := OrderedCollection new.
    [ current isMessage ] whileTrue: [
	selectors addFirst: current selector.
	current := current receiver
    ].
    selectors addAllFirst: (current name substrings: $.).

    current := self currentNamespace.
    selectors keysAndValuesDo: [ :index :each || name |
	name := each asSymbol.
	current := current
	       at: name
	       ifAbsentPut: [
	           (aBlock value: index value: selectors size)
		       ifTrue: [ current addSubspace: name ]
		       ifFalse: [ UndefinedClass name: name in: current for: self ]]].
    ^current! !

STClassLoader initialize!
PK
     �Mh@h�{D�, �,   RBParseNodes.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Refactoring Browser - Parse nodes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1998-2000 The Refactory, Inc.
|
| This file is distributed together with GNU Smalltalk.
|
 ======================================================================"



Object subclass: RBProgramNodeVisitor [
    
    <category: 'Refactory-Parser'>
    <comment: 'RBProgramNodeVisitor is an abstract visitor for the RBProgramNodes.

'>

    RBProgramNodeVisitor class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	<category: 'initialize-release'>
	
    ]

    visitArgument: each [
	"Here to allow subclasses to detect arguments or temporaries."

	<category: 'visiting'>
	^self visitNode: each
    ]

    visitArguments: aNodeCollection [
	<category: 'visiting'>
	^aNodeCollection do: [:each | self visitArgument: each]
    ]

    visitNode: aNode [
	<category: 'visiting'>
	^aNode acceptVisitor: self
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anAssignmentNode variable.
	self visitNode: anAssignmentNode value
    ]

    acceptArrayConstructorNode: anArrayNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anArrayNode body
    ]

    acceptBlockNode: aBlockNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aBlockNode arguments.
	self visitNode: aBlockNode body
    ]

    acceptCascadeNode: aCascadeNode [
	<category: 'visitor-double dispatching'>
	aCascadeNode messages do: [:each | self visitNode: each]
    ]

    acceptLiteralNode: aLiteralNode [
	<category: 'visitor-double dispatching'>
	
    ]

    acceptMessageNode: aMessageNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aMessageNode receiver.
	aMessageNode arguments do: [:each | self visitNode: each]
    ]

    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aMethodNode arguments.
	self visitNode: aMethodNode body
    ]

    acceptOptimizedNode: anOptimizedNode [
	<category: 'visitor-double dispatching'>
	self visitNode: anOptimizedNode body
    ]

    acceptReturnNode: aReturnNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aReturnNode value
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aSequenceNode temporaries.
	aSequenceNode statements do: [:each | self visitNode: each]
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>
	
    ]
]



Object subclass: RBProgramNode [
    | parent comments |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBProgramNode is an abstract class that represents an abstract syntax tree node in a Smalltalk program.

Subclasses must implement the following messages:
    accessing
	start
	stop
    visitor
	acceptVisitor:

The #start and #stop methods are used to find the source that corresponds to this node. "source copyFrom: self start to: self stop" should return the source for this node.

The #acceptVisitor: method is used by RBProgramNodeVisitors (the visitor pattern). This will also require updating all the RBProgramNodeVisitors so that they know of the new node.

Subclasses might also want to redefine match:inContext: and copyInContext: to do parse tree searching and replacing.

Subclasses that contain other nodes should override equalTo:withMapping: to compare nodes while ignoring renaming temporary variables, and children that returns a collection of our children nodes.

Instance Variables:
    comments    <Collection of: Interval>    the intervals in the source that have comments for this node
    parent    <RBProgramNode>    the node we''re contained in

'>

    allArgumentVariables [
	<category: 'accessing'>
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
	    into: 
		[:vars :each | 
		vars
		    addAll: each allArgumentVariables;
		    yourself]
    ]

    allDefinedVariables [
	<category: 'accessing'>
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
	    into: 
		[:vars :each | 
		vars
		    addAll: each allDefinedVariables;
		    yourself]
    ]

    allTemporaryVariables [
	<category: 'accessing'>
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
	    into: 
		[:vars :each | 
		vars
		    addAll: each allTemporaryVariables;
		    yourself]
    ]

    asReturn [
	"Change the current node to a return node."

	<category: 'accessing'>
	parent isNil 
	    ifTrue: [self error: 'Cannot change to a return without a parent node.'].
	parent isSequence 
	    ifFalse: [self error: 'Parent node must be a sequence node.'].
	(parent isLast: self) ifFalse: [self error: 'Return node must be last.'].
	^parent addReturn
    ]

    blockVariables [
	<category: 'accessing'>
	^parent isNil ifTrue: [#()] ifFalse: [parent blockVariables]
    ]

    children [
	<category: 'accessing'>
	^#()
    ]

    comments [
	<category: 'accessing'>
	^comments isNil ifTrue: [#()] ifFalse: [comments]
    ]

    comments: aCollection [
	<category: 'accessing'>
	comments := aCollection
    ]

    formattedCode [
	<category: 'accessing'>
	^self formatterClass new format: self
    ]

    formatterClass [
	<category: 'accessing'>
	^RBFormatter
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: anObject [
	<category: 'accessing'>
	parent := anObject
    ]

    precedence [
	<category: 'accessing'>
	^6
    ]

    source [
	<category: 'accessing'>
	^parent notNil ifTrue: [parent source] ifFalse: [nil]
    ]

    sourceInterval [
	<category: 'accessing'>
	^self start to: self stop
    ]

    start [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    stop [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    temporaryVariables [
	<category: 'accessing'>
	^parent isNil ifTrue: [#()] ifFalse: [parent temporaryVariables]
    ]

    equalTo: aNode exceptForVariables: variableNameCollection [
	<category: 'comparing'>
	| dictionary |
	dictionary := Dictionary new.
	(self equalTo: aNode withMapping: dictionary) ifFalse: [^false].
	dictionary keysAndValuesDo: 
		[:key :value | 
		(key = value or: [variableNameCollection includes: key]) ifFalse: [^false]].
	^true
    ]

    equalTo: aNode withMapping: aDictionary [
	<category: 'comparing'>
	^self = aNode
    ]

    copyCommentsFrom: aNode [
	"Add all comments from aNode to us. If we already have the comment, then don't add it."

	<category: 'copying'>
	| newComments |
	newComments := OrderedCollection new.
	aNode nodesDo: [:each | newComments addAll: each comments].
	self nodesDo: 
		[:each | 
		each comments do: [:comment | newComments remove: comment ifAbsent: []]].
	newComments isEmpty ifTrue: [^self].
	newComments := newComments asSortedCollection: [:a :b | a first < b first].
	self comments: newComments
    ]

    nodesDo: aBlock [
	<category: 'iterating'>
	aBlock value: self.
	self children do: [:each | each nodesDo: aBlock]
    ]

    deepCopy [
	"Hacked to fit collection protocols.  We use #deepCopy to obtain a list
	 of copied nodes.  We do already copy for our instance variables
	 through #postCopy, so we redirect #deepCopy to be a normal #copy."

	<category: 'enumeration'>
	^self copy
    ]

    collect: aBlock [
	"Hacked to fit collection protocols"

	<category: 'enumeration'>
	^aBlock value: self
    ]

    do: aBlock [
	"Hacked to fit collection protocols"

	<category: 'enumeration'>
	aBlock value: self
    ]

    size [
	"Hacked to fit collection protocols"

	<category: 'enumeration'>
	^1
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^self copy
    ]

    copyList: matchNodes inContext: aDictionary [
	<category: 'matching'>
	| newNodes |
	newNodes := OrderedCollection new.
	matchNodes do: 
		[:each | 
		| object |
		object := each copyInContext: aDictionary.
		newNodes addAll: object].
	^newNodes
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	^self = aNode
    ]

    matchList: matchNodes against: programNodes inContext: aDictionary [
	<category: 'matching'>
	^self 
	    matchList: matchNodes
	    index: 1
	    against: programNodes
	    index: 1
	    inContext: aDictionary
    ]

    matchList: matchNodes index: matchIndex against: programNodes index: programIndex inContext: aDictionary [
	<category: 'matching'>
	| node currentIndex currentDictionary nodes |
	matchNodes size < matchIndex ifTrue: [^programNodes size < programIndex].
	node := matchNodes at: matchIndex.
	node isList 
	    ifTrue: 
		[currentIndex := programIndex - 1.
		
		[currentDictionary := aDictionary copy.
		programNodes size < currentIndex or: 
			[nodes := programNodes copyFrom: programIndex to: currentIndex.
			(currentDictionary at: node ifAbsentPut: [nodes]) = nodes and: 
				[(self 
				    matchList: matchNodes
				    index: matchIndex + 1
				    against: programNodes
				    index: currentIndex + 1
				    inContext: currentDictionary) 
					ifTrue: 
					    [currentDictionary 
						keysAndValuesDo: [:key :value | aDictionary at: key put: value].
					    ^true].
				false]]] 
			whileFalse: [currentIndex := currentIndex + 1].
		^false].
	programNodes size < programIndex ifTrue: [^false].
	(node match: (programNodes at: programIndex) inContext: aDictionary) 
	    ifFalse: [^false].
	^self 
	    matchList: matchNodes
	    index: matchIndex + 1
	    against: programNodes
	    index: programIndex + 1
	    inContext: aDictionary
    ]

    cascadeListCharacter [
	<category: 'pattern variable-accessing'>
	^$;
    ]

    listCharacter [
	<category: 'pattern variable-accessing'>
	^$@
    ]

    literalCharacter [
	<category: 'pattern variable-accessing'>
	^$#
    ]

    recurseIntoCharacter [
	<category: 'pattern variable-accessing'>
	^$`
    ]

    statementCharacter [
	<category: 'pattern variable-accessing'>
	^$.
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: self class name;
	    nextPut: $(;
	    nextPutAll: self formattedCode;
	    nextPut: $)
    ]

    bestNodeFor: anInterval [
	<category: 'querying'>
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	selectedChildren := self children 
		    select: [:each | each intersectsInterval: anInterval].
	^selectedChildren size == 1 
	    ifTrue: [selectedChildren first bestNodeFor: anInterval]
	    ifFalse: [self]
    ]

    selfMessages [
	<category: 'querying'>
	| searcher |
	searcher := ParseTreeSearcher new.
	searcher matches: 'self `@msg: ``@args'
	    do: 
		[:aNode :answer | 
		answer
		    add: aNode selector;
		    yourself].
	^searcher executeTree: self initialAnswer: Set new
    ]

    statementNode [
	"Return your topmost node that is contained by a sequence node."

	<category: 'querying'>
	(parent isNil or: [parent isSequence]) ifTrue: [^self].
	^parent statementNode
    ]

    superMessages [
	<category: 'querying'>
	| searcher |
	searcher := ParseTreeSearcher new.
	searcher matches: 'super `@msg: ``@args'
	    do: 
		[:aNode :answer | 
		answer
		    add: aNode selector;
		    yourself].
	^searcher executeTree: self initialAnswer: Set new
    ]

    whichNodeIsContainedBy: anInterval [
	<category: 'querying'>
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	selectedChildren := self children 
		    select: [:each | each intersectsInterval: anInterval].
	^selectedChildren size == 1 
	    ifTrue: [selectedChildren first whichNodeIsContainedBy: anInterval]
	    ifFalse: [nil]
    ]

    whoDefines: aName [
	<category: 'querying'>
	^(self defines: aName) 
	    ifTrue: [self]
	    ifFalse: [parent notNil ifTrue: [parent whoDefines: aName] ifFalse: [nil]]
    ]

    removeDeadCode [
	<category: 'replacing'>
	self children do: [:each | each removeDeadCode]
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	self error: 'I don''t store other nodes'
    ]

    replaceWith: aNode [
	<category: 'replacing'>
	parent isNil ifTrue: [self error: 'This node doesn''t have a parent'].
	parent replaceNode: self withNode: aNode
    ]

    assigns: aVariableName [
	<category: 'testing'>
	^(self children detect: [:each | each assigns: aVariableName] ifNone: [nil]) 
	    notNil
    ]

    containedBy: anInterval [
	<category: 'testing'>
	^anInterval first <= self start and: [anInterval last >= self stop]
    ]

    containsReturn [
	<category: 'testing'>
	^(self children detect: [:each | each containsReturn] ifNone: [nil]) 
	    notNil
    ]

    defines: aName [
	<category: 'testing'>
	^false
    ]

    directlyUses: aNode [
	<category: 'testing'>
	^true
    ]

    evaluatedFirst: aNode [
	<category: 'testing'>
	self children do: 
		[:each | 
		each == aNode ifTrue: [^true].
		each isImmediate ifFalse: [^false]].
	^false
    ]

    intersectsInterval: anInterval [
	<category: 'testing'>
	^(anInterval first between: self start and: self stop) 
	    or: [self start between: anInterval first and: anInterval last]
    ]

    isAssignment [
	<category: 'testing'>
	^false
    ]

    isBlock [
	<category: 'testing'>
	^false
    ]

    isCascade [
	<category: 'testing'>
	^false
    ]

    isCompileTimeBound [
	<category: 'testing'>
	^false
    ]

    isDirectlyUsed [
	"This node is directly used as an argument, receiver, or part of an assignment."

	<category: 'testing'>
	^parent isNil ifTrue: [false] ifFalse: [parent directlyUses: self]
    ]

    isEvaluatedFirst [
	"Return true if we are the first thing evaluated in this statement."

	<category: 'testing'>
	^parent isNil or: [parent isSequence or: [parent evaluatedFirst: self]]
    ]

    isImmediate [
	<category: 'testing'>
	^false
    ]

    isLast: aNode [
	<category: 'testing'>
	| children |
	children := self children.
	^children isEmpty not and: [children last == aNode]
    ]

    isLiteral [
	<category: 'testing'>
	^false
    ]

    isMessage [
	<category: 'testing'>
	^false
    ]

    isMethod [
	<category: 'testing'>
	^false
    ]

    isReturn [
	<category: 'testing'>
	^false
    ]

    isSequence [
	<category: 'testing'>
	^false
    ]

    isUsed [
	"Answer true if this node could be used as part of another expression. For example, you could use the
	 result of this node as a receiver of a message, an argument, the right part of an assignment, or the
	 return value of a block. This differs from isDirectlyUsed in that it is conservative since it also includes
	 return values of blocks."

	<category: 'testing'>
	^parent isNil ifTrue: [false] ifFalse: [parent uses: self]
    ]

    isValue [
	<category: 'testing'>
	^false
    ]

    isVariable [
	<category: 'testing'>
	^false
    ]

    lastIsReturn [
	<category: 'testing'>
	^self isReturn
    ]

    references: aVariableName [
	<category: 'testing'>
	^(self children detect: [:each | each references: aVariableName]
	    ifNone: [nil]) notNil
    ]

    uses: aNode [
	<category: 'testing'>
	^true
    ]

    isList [
	<category: 'testing-matching'>
	^false
    ]

    recurseInto [
	<category: 'testing-matching'>
	^false
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	self subclassResponsibility
    ]
]



RBProgramNode subclass: RBSequenceNode [
    | leftBar rightBar statements periods temporaries |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBSequenceNode is an AST node that represents a sequence of statements. Both RBBlockNodes and RBMethodNodes contain these.

Instance Variables:
    leftBar    <Integer | nil>    the position of the left | in the temporaries definition
    periods    <SequenceableCollection of: Integer>    the positions of all the periods that separate the statements
    rightBar    <Integer | nil>    the position of the right | in the temporaries definition
    statements    <SequenceableCollection of: RBStatementNode>    the statement nodes
    temporaries    <SequenceableCollection of: RBVariableNode>    the temporaries defined

'>

    RBSequenceNode class >> leftBar: leftInteger temporaries: variableNodes rightBar: rightInteger [
	<category: 'instance creation'>
	^self new 
	    leftBar: leftInteger
	    temporaries: variableNodes
	    rightBar: rightInteger
    ]

    RBSequenceNode class >> statements: statementNodes [
	<category: 'instance creation'>
	^self temporaries: #() statements: statementNodes
    ]

    RBSequenceNode class >> temporaries: variableNodes statements: statementNodes [
	<category: 'instance creation'>
	^(self new)
	    temporaries: variableNodes;
	    statements: statementNodes;
	    yourself
    ]

    addReturn [
	<category: 'accessing'>
	| node |
	statements isEmpty ifTrue: [^nil].
	statements last isReturn ifTrue: [^statements last].
	node := RBReturnNode value: statements last.
	statements at: statements size put: node.
	node parent: self.
	^node
    ]

    allDefinedVariables [
	<category: 'accessing'>
	^(self temporaryNames asOrderedCollection)
	    addAll: super allDefinedVariables;
	    yourself
    ]

    allTemporaryVariables [
	<category: 'accessing'>
	^(self temporaryNames asOrderedCollection)
	    addAll: super allTemporaryVariables;
	    yourself
    ]

    children [
	<category: 'accessing'>
	^(OrderedCollection new)
	    addAll: self temporaries;
	    addAll: self statements;
	    yourself
    ]

    leftBar [
	<category: 'accessing'>
	^leftBar
    ]

    periods: anObject [
	<category: 'accessing'>
	periods := anObject
    ]

    removeTemporaryNamed: aName [
	<category: 'accessing'>
	temporaries := temporaries reject: [:each | each name = aName]
    ]

    rightBar [
	<category: 'accessing'>
	^rightBar
    ]

    start [
	<category: 'accessing'>
	^leftBar isNil 
	    ifTrue: [statements isEmpty ifTrue: [1] ifFalse: [statements first start]]
	    ifFalse: [leftBar]
    ]

    statements [
	<category: 'accessing'>
	^statements
    ]

    statements: stmtCollection [
	<category: 'accessing'>
	statements := stmtCollection.
	statements do: [:each | each parent: self]
    ]

    stop [
	<category: 'accessing'>
	^(periods isEmpty ifTrue: [0] ifFalse: [periods last]) 
	    max: (statements isEmpty ifTrue: [0] ifFalse: [statements last stop])
    ]

    temporaries [
	<category: 'accessing'>
	^temporaries
    ]

    temporaries: tempCollection [
	<category: 'accessing'>
	temporaries := tempCollection.
	temporaries do: [:each | each parent: self]
    ]

    temporaryNames [
	<category: 'accessing'>
	^temporaries collect: [:each | each name]
    ]

    temporaryVariables [
	<category: 'accessing'>
	^(super temporaryVariables asOrderedCollection)
	    addAll: self temporaryNames;
	    yourself
    ]

    = anObject [
	"Can't send = to the temporaries and statements collection since they might change from arrays to OCs"

	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	self temporaries size = anObject temporaries size ifFalse: [^false].
	1 to: self temporaries size
	    do: 
		[:i | 
		(self temporaries at: i) = (anObject temporaries at: i) ifFalse: [^false]].
	self statements size = anObject statements size ifFalse: [^false].
	1 to: self statements size
	    do: [:i | (self statements at: i) = (anObject statements at: i) ifFalse: [^false]].
	^true
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	self statements size == anObject statements size ifFalse: [^false].
	1 to: self statements size
	    do: 
		[:i | 
		((self statements at: i) equalTo: (anObject statements at: i)
		    withMapping: aDictionary) ifFalse: [^false]].
	aDictionary values asSet size = aDictionary size ifFalse: [^false].	"Not a one-to-one mapping"
	self temporaries 
	    do: [:each | aDictionary removeKey: each name ifAbsent: []].
	^true
    ]

    hash [
	<category: 'comparing'>
	^self temporaries hash bitXor: (self statements isEmpty 
		    ifTrue: [0]
		    ifFalse: [self statements first hash])
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	temporaries := temporaries collect: [:each | each copy].
	statements := statements collect: [:each | each copy]
    ]

    leftBar: leftInteger temporaries: variableNodes rightBar: rightInteger [
	<category: 'initialize-release'>
	leftBar := leftInteger.
	self temporaries: variableNodes.
	rightBar := rightInteger
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    temporaries: (self copyList: temporaries inContext: aDictionary);
	    statements: (self copyList: statements inContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	self class == aNode class ifFalse: [^false].
	^(self 
	    matchList: temporaries
	    against: aNode temporaries
	    inContext: aDictionary) and: 
		    [self 
			matchList: statements
			against: aNode statements
			inContext: aDictionary]
    ]

    removeDeadCode [
	<category: 'replacing'>
	(self isUsed ifTrue: [statements size - 1] ifFalse: [statements size]) 
	    to: 1
	    by: -1
	    do: [:i | (statements at: i) isImmediate ifTrue: [statements removeAtIndex: i]].
	super removeDeadCode
    ]

    removeNode: aNode [
	<category: 'replacing'>
	self replaceNode: aNode withNodes: #()
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	self statements: (statements 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]]).
	self temporaries: (temporaries 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
    ]

    replaceNode: aNode withNodes: aCollection [
	<category: 'replacing'>
	| index newStatements |
	index := self indexOfNode: aNode.
	newStatements := OrderedCollection new: statements size + aCollection size.
	1 to: index - 1 do: [:i | newStatements add: (statements at: i)].
	newStatements addAll: aCollection.
	index + 1 to: statements size
	    do: [:i | newStatements add: (statements at: i)].
	aCollection do: [:each | each parent: self].
	statements := newStatements
    ]

    indexOfNode: aNode [
	"Try to find the node by first looking for ==, and then for ="

	<category: 'private'>
	^(1 to: statements size) detect: [:each | each == aNode]
	    ifNone: [statements indexOf: aNode]
    ]

    defines: aName [
	<category: 'testing'>
	^(temporaries detect: [:each | each name = aName] ifNone: [nil]) notNil
    ]

    directlyUses: aNode [
	<category: 'testing'>
	^false
    ]

    isLast: aNode [
	<category: 'testing'>
	| last |
	statements isEmpty ifTrue: [^false].
	last := statements last.
	^last == aNode or: 
		[last isMessage and: 
			[(#(#ifTrue:ifFalse: #ifFalse:ifTrue:) includes: last selector) and: 
				[last arguments inject: false
				    into: [:bool :each | bool or: [each isLast: aNode]]]]]
    ]

    isSequence [
	<category: 'testing'>
	^true
    ]

    lastIsReturn [
	<category: 'testing'>
	^statements isEmpty not and: [statements last lastIsReturn]
    ]

    references: aVariableName [
	<category: 'testing'>
	^(statements detect: [:each | each references: aVariableName] ifNone: [nil]) 
	    notNil
    ]

    uses: aNode [
	<category: 'testing'>
	statements isEmpty ifTrue: [^false].
	aNode == statements last ifFalse: [^false].
	^self isUsed
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptSequenceNode: self
    ]

    addNode: aNode [
	<category: 'adding nodes'>
	aNode parent: self.
	(statements isEmpty not and: [statements last isReturn]) 
	    ifTrue: [self error: 'Cannot add statement after return node'].
	statements := (statements asOrderedCollection)
		    add: aNode;
		    yourself
    ]

    addNode: aNode before: anotherNode [
	<category: 'adding nodes'>
	| index |
	index := self indexOfNode: anotherNode.
	index = 0 ifTrue: [^self addNode: aNode].
	statements := (statements asOrderedCollection)
		    add: aNode beforeIndex: index;
		    yourself.
	aNode parent: self
    ]

    addNodeFirst: aNode [
	<category: 'adding nodes'>
	aNode parent: self.
	statements := (statements asOrderedCollection)
		    addFirst: aNode;
		    yourself
    ]

    addNodes: aCollection [
	<category: 'adding nodes'>
	aCollection do: [:each | each parent: self].
	(statements isEmpty not and: [statements last isReturn]) 
	    ifTrue: [self error: 'Cannot add statement after return node'].
	statements := (statements asOrderedCollection)
		    addAll: aCollection;
		    yourself
    ]

    addNodes: aCollection before: anotherNode [
	<category: 'adding nodes'>
	aCollection do: [:each | self addNode: each before: anotherNode]
    ]

    addNodesFirst: aCollection [
	<category: 'adding nodes'>
	aCollection do: [:each | each parent: self].
	statements := (statements asOrderedCollection)
		    addAllFirst: aCollection;
		    yourself
    ]

    addSelfReturn [
	<category: 'adding nodes'>
	| node |
	self lastIsReturn ifTrue: [^self].
	node := RBReturnNode value: (RBVariableNode named: 'self').
	self addNode: node
    ]

    addTemporariesNamed: aCollection [
	<category: 'adding nodes'>
	aCollection do: [:each | self addTemporaryNamed: each]
    ]

    addTemporaryNamed: aString [
	<category: 'adding nodes'>
	| variableNode |
	variableNode := RBVariableNode named: aString.
	variableNode parent: self.
	temporaries := temporaries copyWith: variableNode
    ]

    bestNodeFor: anInterval [
	<category: 'querying'>
	| node |
	node := super bestNodeFor: anInterval.
	node == self 
	    ifTrue: 
		[(temporaries isEmpty and: [statements size == 1]) 
		    ifTrue: [^statements first]].
	^node
    ]

    whichNodeIsContainedBy: anInterval [
	<category: 'querying'>
	| node |
	node := super whichNodeIsContainedBy: anInterval.
	node == self 
	    ifTrue: 
		[(temporaries isEmpty and: [statements size == 1]) 
		    ifTrue: [^statements first]].
	^node
    ]
]





RBProgramNode subclass: RBStatementNode [
    
    <category: 'Refactory-Parser'>
    <comment: 'RBStatementNode is an abstract class that represents AST nodes that can go in sequence nodes.

'>
]



RBProgramNode subclass: RBMethodNode [
    | selector selectorParts body source arguments tags category |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBMethodNode is the AST that represents a Smalltalk method.

Instance Variables:
    arguments    <SequenceableCollection of: RBVariableNode>    the arguments to the method
    body    <RBSequenceNode>    the body/statements of the method
    selector    <Symbol | nil>    the method name (cached)
    selectorParts    <SequenceableCollection of: RBValueToken>    the tokens for the selector keywords
    source    <String>    the source we compiled
    tag    <Interval | nil>    the source location of any resource/primitive tags

'>

    RBMethodNode class >> selector: aSymbol arguments: variableNodes body: aSequenceNode [
	<category: 'instance creation'>
	^(self new)
	    arguments: variableNodes;
	    selector: aSymbol;
	    body: aSequenceNode;
	    yourself
    ]

    RBMethodNode class >> selector: aSymbol body: aSequenceNode [
	<category: 'instance creation'>
	^self 
	    selector: aSymbol
	    arguments: #()
	    body: aSequenceNode
    ]

    RBMethodNode class >> selectorParts: tokenCollection arguments: variableNodes [
	<category: 'instance creation'>
	^((tokenCollection detect: [:each | each isPatternVariable] ifNone: [nil]) 
	    notNil ifTrue: [RBPatternMethodNode] ifFalse: [RBMethodNode]) 
	    new selectorParts: tokenCollection arguments: variableNodes
    ]

    addNode: aNode [
	<category: 'accessing'>
	^body addNode: aNode
    ]

    addReturn [
	<category: 'accessing'>
	body addReturn
    ]

    addSelfReturn [
	<category: 'accessing'>
	^body addSelfReturn
    ]

    allArgumentVariables [
	<category: 'accessing'>
	^(self argumentNames asOrderedCollection)
	    addAll: super allArgumentVariables;
	    yourself
    ]

    allDefinedVariables [
	<category: 'accessing'>
	^(self argumentNames asOrderedCollection)
	    addAll: super allDefinedVariables;
	    yourself
    ]

    argumentNames [
	<category: 'accessing'>
	^self arguments collect: [:each | each name]
    ]

    arguments [
	<category: 'accessing'>
	^arguments
    ]

    arguments: variableNodes [
	<category: 'accessing'>
	arguments := variableNodes.
	arguments do: [:each | each parent: self]
    ]

    body [
	<category: 'accessing'>
	^body
    ]

    body: stmtsNode [
	<category: 'accessing'>
	body := stmtsNode.
	body parent: self
    ]

    children [
	<category: 'accessing'>
	^self arguments copyWith: self body
    ]

    primitiveSources [
	<category: 'accessing'>
	self tags isEmpty ifTrue: [^#()].
	^self tags collect: [:each | source copyFrom: each first to: each last]
    ]

    isBinary [
	<category: 'accessing'>
	^(self isUnary or: [self isKeyword]) not
    ]

    isKeyword [
	<category: 'accessing'>
	^selectorParts first value last == $:
    ]

    isUnary [
	<category: 'accessing'>
	^self arguments isEmpty
    ]

    selector [
	<category: 'accessing'>
	^selector isNil 
	    ifTrue: [selector := self buildSelector]
	    ifFalse: [selector]
    ]

    selector: aSelector [
	<category: 'accessing'>
	| keywords numArgs |
	keywords := aSelector keywords.
	numArgs := aSelector numArgs.
	numArgs == arguments size 
	    ifFalse: 
		[self 
		    error: 'Attempting to assign selector with wrong number of arguments.'].
	selectorParts := numArgs == 0 
		    ifTrue: [Array with: (RBIdentifierToken value: keywords first start: nil)]
		    ifFalse: 
			[keywords first last == $: 
			    ifTrue: [keywords collect: [:each | RBKeywordToken value: each start: nil]]
			    ifFalse: [Array with: (RBBinarySelectorToken value: aSelector start: nil)]].
	selector := aSelector
    ]

    source [
	<category: 'accessing'>
	^source
    ]

    source: anObject [
	<category: 'accessing'>
	source := anObject
    ]

    start [
	<category: 'accessing'>
	(selectorParts notNil and: [selectorParts first start notNil]) 
	    ifTrue: [^selectorParts first start].
	body start isNil ifFalse: [^body start].
	^1
    ]

    stop [
	<category: 'accessing'>
	^self start + source size - 1
    ]

    tags [
	<category: 'accessing'>
	^tags isNil ifTrue: [#()] ifFalse: [tags]
    ]

    tags: aCollectionOfIntervals [
	<category: 'accessing'>
	tags := aCollectionOfIntervals
    ]

    category [
	<category: 'accessing'>
	^category
    ]

    category: aCategory [
	<category: 'accessing'>
	category := aCategory
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	(self selector = anObject selector and: [self body = anObject body]) 
	    ifFalse: [^false].
	1 to: self arguments size
	    do: [:i | (self arguments at: i) = (anObject arguments at: i) ifFalse: [^false]].
	^true
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	(self selector = anObject selector 
	    and: [self body equalTo: anObject body withMapping: aDictionary]) 
		ifFalse: [^false].
	1 to: self arguments size
	    do: 
		[:i | 
		((self arguments at: i) equalTo: (anObject arguments at: i)
		    withMapping: aDictionary) ifFalse: [^false].
		aDictionary removeKey: (self arguments at: i) name].
	^self primitiveSources = anObject primitiveSources
    ]

    hash [
	<category: 'comparing'>
	^(self selector hash bitXor: self body hash) bitXor: self arguments hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	body := body copy.
	arguments := arguments collect: [:each | each copy]
    ]

    selectorParts: tokenCollection arguments: variableNodes [
	<category: 'initialize-release'>
	selectorParts := tokenCollection.
	self arguments: variableNodes
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    selectorParts: (selectorParts collect: [:each | each removePositions]);
	    arguments: (arguments collect: [:each | each copyInContext: aDictionary]);
	    body: (body copyInContext: aDictionary);
	    source: (aDictionary at: '-source-');
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	self class == aNode class ifFalse: [^false].
	aDictionary at: '-source-' put: aNode source.
	self selector == aNode selector ifFalse: [^false].
	^(self 
	    matchList: arguments
	    against: aNode arguments
	    inContext: aDictionary) 
		and: [body match: aNode body inContext: aDictionary]
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self formattedCode
    ]

    buildSelector [
	<category: 'private'>
	| selectorStream |
	selectorStream := WriteStream on: (String new: 50).
	selectorParts do: [:each | selectorStream nextPutAll: each value].
	^selectorStream contents asSymbol
    ]

    selectorParts [
	<category: 'private'>
	^selectorParts
    ]

    selectorParts: tokenCollection [
	<category: 'private'>
	selectorParts := tokenCollection
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	aNode == body ifTrue: [self body: anotherNode].
	self arguments: (arguments 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
    ]

    defines: aName [
	<category: 'testing'>
	^(arguments detect: [:each | each name = aName] ifNone: [nil]) notNil
    ]

    isLast: aNode [
	<category: 'testing'>
	^body isLast: aNode
    ]

    isMethod [
	<category: 'testing'>
	^true
    ]

    isPrimitive [
	<category: 'testing'>
	^tags notNil and: 
		[tags isEmpty not and: 
			[(self primitiveSources detect: [:each | '*primitive*' match: each]
			    ifNone: [nil]) notNil]]
    ]

    lastIsReturn [
	<category: 'testing'>
	^body lastIsReturn
    ]

    references: aVariableName [
	<category: 'testing'>
	^body references: aVariableName
    ]

    uses: aNode [
	<category: 'testing'>
	^body == aNode and: [aNode lastIsReturn]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptMethodNode: self
    ]
]



RBStatementNode subclass: RBValueNode [
    | parentheses |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBValueNode is an abstract class that represents a node that returns some value.

Instance Variables:
    parentheses    <SequenceableCollection of: Inteval>    the positions of the parethesis around this node. We need a collection of intervals for stupid code such as "((3 + 4))" that has multiple parethesis around the same expression.

'>

    addParenthesis: anInterval [
	<category: 'accessing'>
	parentheses isNil ifTrue: [parentheses := OrderedCollection new: 1].
	parentheses add: anInterval
    ]

    parentheses [
	<category: 'accessing'>
	^parentheses isNil ifTrue: [#()] ifFalse: [parentheses]
    ]

    start [
	<category: 'accessing'>
	^parentheses isNil 
	    ifTrue: [self startWithoutParentheses]
	    ifFalse: [parentheses last first]
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    stop [
	<category: 'accessing'>
	^parentheses isNil 
	    ifTrue: [self stopWithoutParentheses]
	    ifFalse: [parentheses last last]
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    containedBy: anInterval [
	<category: 'testing'>
	^anInterval first <= self startWithoutParentheses 
	    and: [anInterval last >= self stopWithoutParentheses]
    ]

    hasParentheses [
	<category: 'testing'>
	^self parentheses isEmpty not
    ]

    isValue [
	<category: 'testing'>
	^true
    ]
]



RBStatementNode subclass: RBReturnNode [
    | return value |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBReturnNode is an AST node that represents a return expression.

Instance Variables:
    return    <Integer>    the position of the ^ character
    value    <RBValueNode>    the value that is being returned

'>

    RBReturnNode class >> return: returnInteger value: aValueNode [
	<category: 'instance creation'>
	^self new return: returnInteger value: aValueNode
    ]

    RBReturnNode class >> value: aNode [
	<category: 'instance creation'>
	^self return: nil value: aNode
    ]

    children [
	<category: 'accessing'>
	^Array with: value
    ]

    start [
	<category: 'accessing'>
	^return
    ]

    stop [
	<category: 'accessing'>
	^value stop
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: valueNode [
	<category: 'accessing'>
	value := valueNode.
	value parent: self
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	^self value = anObject value
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	^self value equalTo: anObject value withMapping: aDictionary
    ]

    hash [
	<category: 'comparing'>
	^self value hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	value := value copy
    ]

    return: returnInteger value: aValueNode [
	<category: 'initialize-release'>
	return := returnInteger.
	self value: aValueNode
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    value: (value copyInContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	^value match: aNode value inContext: aDictionary
    ]

    containsReturn [
	<category: 'testing'>
	^true
    ]

    isReturn [
	<category: 'testing'>
	^true
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptReturnNode: self
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	value == aNode ifTrue: [self value: anotherNode]
    ]
]



RBMethodNode subclass: RBPatternMethodNode [
    | isList |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBPatternMethodNode is a RBMethodNode that will match other method nodes without their selectors being equal. 

Instance Variables:
    isList    <Boolean>    are we matching each keyword or matching all keywords together (e.g., `keyword1: would match a one argument method whereas `@keywords: would match 0 or more arguments)

'>

    selectorParts: tokenCollection arguments: variableNodes [
	<category: 'initialize-release'>
	super selectorParts: tokenCollection arguments: variableNodes.
	isList := (tokenCollection first value at: 2) == self listCharacter
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	| selectors |
	selectors := self isSelectorList 
		    ifTrue: [(aDictionary at: selectorParts first value) keywords]
		    ifFalse: [selectorParts collect: [:each | aDictionary at: each value]].
	^(RBMethodNode new)
	    selectorParts: (selectors collect: 
			    [:each | 
			    (each last == $: ifTrue: [RBKeywordToken] ifFalse: [RBIdentifierToken]) 
				value: each
				start: nil]);
	    arguments: (self copyList: arguments inContext: aDictionary);
	    body: (body copyInContext: aDictionary);
	    source: (aDictionary at: '-source-');
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self matchingClass ifFalse: [^false].
	aDictionary at: '-source-' put: aNode source.
	self isSelectorList 
	    ifTrue: 
		[^(aDictionary at: selectorParts first value ifAbsentPut: [aNode selector]) 
		    = aNode selector and: 
			    [(aDictionary at: arguments first ifAbsentPut: [aNode arguments]) 
				= aNode arguments and: [body match: aNode body inContext: aDictionary]]].
	^(self matchArgumentsAgainst: aNode inContext: aDictionary) 
	    and: [body match: aNode body inContext: aDictionary]
    ]

    matchArgumentsAgainst: aNode inContext: aDictionary [
	<category: 'matching'>
	self arguments size == aNode arguments size ifFalse: [^false].
	(self matchSelectorAgainst: aNode inContext: aDictionary) 
	    ifFalse: [^false].
	1 to: arguments size
	    do: 
		[:i | 
		((arguments at: i) match: (aNode arguments at: i) inContext: aDictionary) 
		    ifFalse: [^false]].
	^true
    ]

    matchSelectorAgainst: aNode inContext: aDictionary [
	<category: 'matching'>
	| keyword |
	1 to: selectorParts size
	    do: 
		[:i | 
		keyword := selectorParts at: i.
		(aDictionary at: keyword value
		    ifAbsentPut: 
			[keyword isPatternVariable 
			    ifTrue: [(aNode selectorParts at: i) value]
			    ifFalse: [keyword value]]) 
			= (aNode selectorParts at: i) value ifFalse: [^false]].
	^true
    ]

    matchingClass [
	<category: 'private'>
	^RBMethodNode
    ]

    isSelectorList [
	<category: 'testing'>
	^isList
    ]
]



RBValueNode subclass: RBStatementListNode [
    | left right body |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBStatementListNode is an AST node that represents a block "[...]" or an array constructor "{...}".

Instance Variables:
    body    <RBSequenceNode>    the code inside the block
    left    <Integer>    position of [/{
    right    <Integer>    position of ]/}

'>

    RBStatementListNode class >> body: aSequenceNode [
	<category: 'instance creation'>
	^(self new)
	    body: aSequenceNode;
	    yourself
    ]

    RBStatementListNode class >> left: leftInteger body: aSequenceNode right: rightInteger [
	<category: 'instance creation'>
	^(self new)
	    left: leftInteger
		body: aSequenceNode
		right: rightInteger;
	    yourself
    ]

    body [
	<category: 'accessing'>
	^body
    ]

    body: stmtsNode [
	<category: 'accessing'>
	body := stmtsNode.
	body parent: self
    ]

    children [
	<category: 'accessing'>
	^Array with: body
    ]

    left [
	<category: 'accessing'>
	^left
    ]

    left: anObject [
	<category: 'accessing'>
	left := anObject
    ]

    precedence [
	<category: 'accessing'>
	^0
    ]

    right [
	<category: 'accessing'>
	^right
    ]

    right: anObject [
	<category: 'accessing'>
	right := anObject
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^left
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^right
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	^self body = anObject body
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	self arguments size = anObject arguments size ifFalse: [^false].
	^self body equalTo: anObject body withMapping: aDictionary
    ]

    hash [
	<category: 'comparing'>
	^self body hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	body := body copy
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^self class body: (body copyInContext: aDictionary)
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	^body match: aNode body inContext: aDictionary
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	body == aNode ifTrue: [self body: anotherNode]
    ]

    directlyUses: aNode [
	<category: 'testing'>
	^false
    ]

    isLast: aNode [
	<category: 'testing'>
	^body isLast: aNode
    ]

    references: aVariableName [
	<category: 'testing'>
	^body references: aVariableName
    ]

    left: leftInteger body: aSequenceNode right: rightInteger [
	<category: 'initialize-release'>
	left := leftInteger.
	self body: aSequenceNode.
	right := rightInteger
    ]
]



RBStatementListNode subclass: RBOptimizedNode [
    
    <category: 'Browser-Parser'>
    <comment: '
RBOptimizedNode is an AST node that represents ##(...) expressions. These expressions are evaluated at compile time and directly inserted into the method.
'>

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptOptimizedNode: self
    ]

    isImmediate [
	<category: 'testing'>
	^true
    ]
]



RBValueNode subclass: RBMessageNode [
    | receiver selector selectorParts arguments |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBMessageNode is an AST node that represents a message send.

Instance Variables:
    arguments    <SequenceableCollection of: RBValueNode>    our argument nodes
    receiver    <RBValueNode>    the receiver''s node
    selector    <Symbol | nil>    the selector we''re sending (cached)
    selectorParts    <SequenceableCollection of: RBValueToken>    the tokens for each keyword

'>

    RBMessageNode class >> receiver: aValueNode selector: aSymbol [
	<category: 'instance creation'>
	^self 
	    receiver: aValueNode
	    selector: aSymbol
	    arguments: #()
    ]

    RBMessageNode class >> receiver: aValueNode selector: aSymbol arguments: valueNodes [
	<category: 'instance creation'>
	^(self new)
	    receiver: aValueNode;
	    arguments: valueNodes;
	    selector: aSymbol;
	    yourself
    ]

    RBMessageNode class >> receiver: aValueNode selectorParts: keywordTokens arguments: valueNodes [
	<category: 'instance creation'>
	^((keywordTokens detect: [:each | each isPatternVariable] ifNone: [nil]) 
	    notNil ifTrue: [RBPatternMessageNode] ifFalse: [RBMessageNode]) 
	    new 
		receiver: aValueNode
		selectorParts: keywordTokens
		arguments: valueNodes
    ]

    arguments [
	<category: 'accessing'>
	^arguments isNil ifTrue: [#()] ifFalse: [arguments]
    ]

    arguments: argCollection [
	<category: 'accessing'>
	arguments := argCollection.
	arguments do: [:each | each parent: self]
    ]

    children [
	<category: 'accessing'>
	^(OrderedCollection with: self receiver)
	    addAll: self arguments;
	    yourself
    ]

    precedence [
	<category: 'accessing'>
	^self isUnary 
	    ifTrue: [1]
	    ifFalse: [self isKeyword ifTrue: [3] ifFalse: [2]]
    ]

    receiver [
	<category: 'accessing'>
	^receiver
    ]

    receiver: aValueNode [
	<category: 'accessing'>
	receiver := aValueNode.
	receiver parent: self
    ]

    selector [
	<category: 'accessing'>
	^selector isNil 
	    ifTrue: [selector := self buildSelector]
	    ifFalse: [selector]
    ]

    selector: aSelector [
	<category: 'accessing'>
	| keywords numArgs |
	keywords := aSelector keywords.
	numArgs := aSelector numArgs.
	numArgs == arguments size 
	    ifFalse: 
		[self 
		    error: 'Attempting to assign selector with wrong number of arguments.'].
	selectorParts := numArgs == 0 
		    ifTrue: [Array with: (RBIdentifierToken value: keywords first start: nil)]
		    ifFalse: 
			[keywords first last == $: 
			    ifTrue: [keywords collect: [:each | RBKeywordToken value: each start: nil]]
			    ifFalse: [Array with: (RBBinarySelectorToken value: aSelector start: nil)]].
	selector := aSelector
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^receiver start
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^arguments isEmpty 
	    ifTrue: [selectorParts first stop]
	    ifFalse: [arguments last stop]
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	(self receiver = anObject receiver 
	    and: [self selector = anObject selector]) ifFalse: [^false].
	1 to: self arguments size
	    do: [:i | (self arguments at: i) = (anObject arguments at: i) ifFalse: [^false]].
	^true
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	((self receiver equalTo: anObject receiver withMapping: aDictionary) 
	    and: [self selector = anObject selector]) ifFalse: [^false].
	1 to: self arguments size
	    do: 
		[:i | 
		((self arguments at: i) equalTo: (anObject arguments at: i)
		    withMapping: aDictionary) ifFalse: [^false]].
	^true
    ]

    hash [
	<category: 'comparing'>
	^(self receiver hash bitXor: self selector hash) 
	    bitXor: (self arguments isEmpty 
		    ifTrue: [0]
		    ifFalse: [self arguments first hash])
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	receiver := receiver copy.
	arguments := arguments collect: [:each | each copy]
    ]

    receiver: aValueNode selectorParts: keywordTokens arguments: valueNodes [
	<category: 'initialize-release'>
	self receiver: aValueNode.
	selectorParts := keywordTokens.
	self arguments: valueNodes
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    receiver: (receiver copyInContext: aDictionary);
	    selectorParts: (selectorParts collect: [:each | each removePositions]);
	    arguments: (arguments collect: [:each | each copyInContext: aDictionary]);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	self selector == aNode selector ifFalse: [^false].
	(receiver match: aNode receiver inContext: aDictionary) ifFalse: [^false].
	1 to: arguments size
	    do: 
		[:i | 
		((arguments at: i) match: (aNode arguments at: i) inContext: aDictionary) 
		    ifFalse: [^false]].
	^true
    ]

    buildSelector [
	<category: 'private'>
	| selectorStream |
	selectorStream := WriteStream on: (String new: 50).
	selectorParts do: [:each | selectorStream nextPutAll: each value].
	^selectorStream contents asSymbol
    ]

    selectorParts [
	<category: 'private'>
	^selectorParts
    ]

    selectorParts: tokenCollection [
	<category: 'private'>
	selectorParts := tokenCollection
    ]

    isBinary [
	<category: 'testing'>
	^(self isUnary or: [self isKeyword]) not
    ]

    isKeyword [
	<category: 'testing'>
	^selectorParts first value last == $:
    ]

    isMessage [
	<category: 'testing'>
	^true
    ]

    isUnary [
	<category: 'testing'>
	^arguments isEmpty
    ]

    lastIsReturn [
	<category: 'testing'>
	^(#(#ifTrue:ifFalse: #ifFalse:ifTrue:) includes: self selector) and: 
		[arguments first isBlock and: 
			[arguments first body lastIsReturn 
			    and: [arguments last isBlock and: [arguments last body lastIsReturn]]]]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptMessageNode: self
    ]

    replaceNode: aNode withNode: anotherNode [
	"If we're inside a cascade node and are changing the receiver, change all the receivers"

	<category: 'replacing'>
	receiver == aNode 
	    ifTrue: 
		[self receiver: anotherNode.
		(parent notNil and: [parent isCascade]) 
		    ifTrue: [parent messages do: [:each | each receiver: anotherNode]]].
	self arguments: (arguments 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
    ]

    bestNodeFor: anInterval [
	<category: 'querying'>
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	selectorParts do: 
		[:each | 
		((anInterval first between: each start and: each stop) 
		    or: [each start between: anInterval first and: anInterval last]) 
			ifTrue: [^self]].
	self children do: 
		[:each | 
		| node |
		node := each bestNodeFor: anInterval.
		node notNil ifTrue: [^node]]
    ]
]



RBValueNode subclass: RBCascadeNode [
    | messages semicolons |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBCascadeNode is an AST node for cascaded messages (e.g., "self print1 ; print2").

Instance Variables:
    messages    <SequenceableCollection of: RBMessageNode>    the messages 
    semicolons    <SequenceableCollection of: Integer>    positions of the ; between messages

'>

    RBCascadeNode class >> messages: messageNodes [
	<category: 'instance creation'>
	^self new messages: messageNodes
    ]

    RBCascadeNode class >> messages: messageNodes semicolons: integerCollection [
	<category: 'instance creation'>
	^self new messages: messageNodes semicolons: integerCollection
    ]

    children [
	<category: 'accessing'>
	^self messages
    ]

    messages [
	<category: 'accessing'>
	^messages
    ]

    messages: messageNodeCollection [
	<category: 'accessing'>
	messages := messageNodeCollection.
	messages do: [:each | each parent: self]
    ]

    precedence [
	<category: 'accessing'>
	^4
    ]

    semicolons: anObject [
	<category: 'accessing'>
	semicolons := anObject
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^messages first start
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^messages last stop
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	self messages size = anObject messages size ifFalse: [^false].
	1 to: self messages size
	    do: [:i | (self messages at: i) = (anObject messages at: i) ifFalse: [^false]].
	^true
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	self messages size == anObject messages size ifFalse: [^false].
	1 to: self messages size
	    do: 
		[:i | 
		((self messages at: i) equalTo: (anObject messages at: i)
		    withMapping: aDictionary) ifFalse: [^false]].
	^true
    ]

    hash [
	<category: 'comparing'>
	^self messages hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	messages := messages collect: [:each | each copy]
    ]

    messages: messageNodes semicolons: integerCollection [
	<category: 'initialize-release'>
	self messages: messageNodes.
	semicolons := integerCollection
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    messages: (self copyList: messages inContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	^self 
	    matchList: messages
	    against: aNode messages
	    inContext: aDictionary
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	self messages: (messages 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
    ]

    directlyUses: aNode [
	<category: 'testing'>
	^messages last = aNode and: [self isDirectlyUsed]
    ]

    isCascade [
	<category: 'testing'>
	^true
    ]

    uses: aNode [
	<category: 'testing'>
	^messages last = aNode and: [self isUsed]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptCascadeNode: self
    ]

    bestNodeFor: anInterval [
	<category: 'querying'>
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	messages 
	    reverseDo: [:each | (each containedBy: anInterval) ifTrue: [^each]].
	selectedChildren := (messages 
		    collect: [:each | each bestNodeFor: anInterval]) 
			reject: [:each | each isNil].
	^selectedChildren detect: [:each | true] ifNone: [nil]
    ]

    whichNodeIsContainedBy: anInterval [
	<category: 'querying'>
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	messages 
	    reverseDo: [:each | (each containedBy: anInterval) ifTrue: [^each]].
	selectedChildren := (messages 
		    collect: [:each | each whichNodeIsContainedBy: anInterval]) 
			reject: [:each | each isNil].
	^selectedChildren detect: [:each | true] ifNone: [nil]
    ]
]



RBValueNode subclass: RBAssignmentNode [
    | variable assignment value |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBAssignmentNode is an AST node for assignment statements

Instance Variables:
    assignment    <Integer>    position of the :=
    value    <RBValueNode>    the value that we''re assigning
    variable    <RBVariableNode>    the variable being assigned

'>

    RBAssignmentNode class >> variable: aVariableNode value: aValueNode [
	<category: 'instance creation'>
	^self 
	    variable: aVariableNode
	    value: aValueNode
	    position: nil
    ]

    RBAssignmentNode class >> variable: aVariableNode value: aValueNode position: anInteger [
	<category: 'instance creation'>
	^self new 
	    variable: aVariableNode
	    value: aValueNode
	    position: anInteger
    ]

    assignment [
	<category: 'accessing'>
	^assignment
    ]

    children [
	<category: 'accessing'>
	^Array with: value with: variable
    ]

    precedence [
	<category: 'accessing'>
	^5
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^variable start
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^value stop
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aValueNode [
	<category: 'accessing'>
	value := aValueNode.
	value parent: self
    ]

    variable [
	<category: 'accessing'>
	^variable
    ]

    variable: varNode [
	<category: 'accessing'>
	variable := varNode.
	variable parent: self
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	^self variable = anObject variable and: [self value = anObject value]
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	^(self variable equalTo: anObject variable withMapping: aDictionary) 
	    and: [self value equalTo: anObject value withMapping: aDictionary]
    ]

    hash [
	<category: 'comparing'>
	^self variable hash bitXor: self value hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	variable := variable postCopy.
	value := value postCopy
    ]

    variable: aVariableNode value: aValueNode position: anInteger [
	<category: 'initialize-release'>
	self variable: aVariableNode.
	self value: aValueNode.
	assignment := anInteger
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(self class new)
	    variable: (variable copyInContext: aDictionary);
	    value: (value copyInContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	^(variable match: aNode variable inContext: aDictionary) 
	    and: [value match: aNode value inContext: aDictionary]
    ]

    assigns: aVariableName [
	<category: 'testing'>
	^variable name = aVariableName or: [value assigns: aVariableName]
    ]

    directlyUses: aNode [
	<category: 'testing'>
	^aNode = value ifTrue: [true] ifFalse: [self isDirectlyUsed]
    ]

    isAssignment [
	<category: 'testing'>
	^true
    ]

    uses: aNode [
	<category: 'testing'>
	^aNode = value ifTrue: [true] ifFalse: [self isUsed]
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	value == aNode ifTrue: [self value: anotherNode].
	variable == aNode ifTrue: [self variable: anotherNode]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptAssignmentNode: self
    ]

    bestNodeFor: anInterval [
	<category: 'querying'>
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	assignment isNil ifTrue: [^super bestNodeFor: anInterval].
	((anInterval first between: assignment and: assignment + 1) 
	    or: [assignment between: anInterval first and: anInterval last]) 
		ifTrue: [^self].
	self children do: 
		[:each | 
		| node |
		node := each bestNodeFor: anInterval.
		node notNil ifTrue: [^node]]
    ]
]



RBValueNode subclass: RBVariableNode [
    | token |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBVariableNode is an AST node that represent a variable (global, inst var, temp, etc.).

Instance Variables:
    token    <RBValueToken>    the token that contains our name and position

'>

    RBVariableNode class >> identifierToken: anIdentifierToken [
	<category: 'instance creation'>
	^(anIdentifierToken isPatternVariable 
	    ifTrue: [RBPatternVariableNode]
	    ifFalse: [RBVariableNode]) new 
	    identifierToken: anIdentifierToken
    ]

    RBVariableNode class >> named: aString [
	<category: 'instance creation'>
	^self identifierToken: (RBIdentifierToken value: aString start: 0)
    ]

    name [
	<category: 'accessing'>
	^token value
    ]

    precedence [
	<category: 'accessing'>
	^0
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^token start
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^token stop
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	^self name = anObject name
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	^(aDictionary at: self name ifAbsentPut: [anObject name]) = anObject name
    ]

    hash [
	<category: 'comparing'>
	^self name hash
    ]

    identifierToken: anIdentifierToken [
	<category: 'initialize-release'>
	token := anIdentifierToken
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^self class identifierToken: token removePositions
    ]

    isImmediate [
	<category: 'testing'>
	^true
    ]

    isVariable [
	<category: 'testing'>
	^true
    ]

    references: aVariableName [
	<category: 'testing'>
	^self name = aVariableName
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptVariableNode: self
    ]
]



RBValueNode subclass: RBLiteralNode [
    | token |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBLiteralNode is an AST node that represents literals (e.g., #foo, #(1 2 3), true, etc.).

Instance Variables:
    token    <RBLiteralToken>    the token that contains the literal value as well as its source positions

'>

    RBLiteralNode class >> literalToken: aLiteralToken [
	<category: 'instance creation'>
	^self new literalToken: aLiteralToken
    ]

    RBLiteralNode class >> value: aValue [
	<category: 'instance creation'>
	^self literalToken: (RBLiteralToken value: aValue)
    ]

    compiler: compiler [
	<category: 'compile-time binding'>
	token compiler: compiler
    ]

    isCompileTimeBound [
	<category: 'compile-time binding'>
	^token isCompileTimeBound
    ]

    precedence [
	<category: 'accessing'>
	^0
    ]

    startWithoutParentheses [
	<category: 'accessing'>
	^token start
    ]

    stopWithoutParentheses [
	<category: 'accessing'>
	^token stop
    ]

    token [
	<category: 'accessing'>
	^token
    ]

    value [
	<category: 'accessing'>
	^token realValue
    ]

    = anObject [
	<category: 'comparing'>
	self == anObject ifTrue: [^true].
	self class == anObject class ifFalse: [^false].
	self value class == anObject value class ifFalse: [^false].
	^self value = anObject value
    ]

    hash [
	<category: 'comparing'>
	^self value hash
    ]

    literalToken: aLiteralToken [
	<category: 'initialize-release'>
	token := aLiteralToken
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^self class literalToken: token removePositions
    ]

    isImmediate [
	<category: 'testing'>
	^true
    ]

    isLiteral [
	<category: 'testing'>
	^true
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptLiteralNode: self
    ]
]



RBStatementListNode subclass: RBArrayConstructorNode [
    
    <category: 'Refactory-Parser'>
    <comment: 'RBArrayConstructorNode is an AST node that represents an array constructor node "{...}".'>

    directlyUses: aNode [
	<category: 'testing'>
	^body statements includes: aNode
    ]

    uses: aNode [
	<category: 'testing'>
	^body statements includes: aNode
    ]

    removeDeadCode [
	<category: 'visitor'>
	self body children do: [:each | each removeDeadCode]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptArrayConstructorNode: self
    ]
]



RBStatementListNode subclass: RBBlockNode [
    | colons arguments bar |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBBlockNode is an AST node that represents a block "[...]".

Instance Variables:
    arguments    <SequenceableCollection of: RBVariableNode>    the arguments for the block
    bar    <Integer | nil>    position of the | after the arguments
    body    <RBSequenceNode>    the code inside the block
    colons    <SequenceableCollection of: Integer>    positions of each : before each argument
    left    <Integer>    position of [
    right    <Integer>    position of ]

'>

    RBBlockNode class >> body: sequenceNode [
	<category: 'instance creation'>
	^(super body: sequenceNode)
	    arguments: #();
	    yourself
    ]

    RBBlockNode class >> arguments: argNodes body: sequenceNode [
	<category: 'instance creation'>
	^(self body: sequenceNode)
	    arguments: argNodes;
	    yourself
    ]

    allArgumentVariables [
	<category: 'accessing'>
	^(self argumentNames asOrderedCollection)
	    addAll: super allArgumentVariables;
	    yourself
    ]

    allDefinedVariables [
	<category: 'accessing'>
	^(self argumentNames asOrderedCollection)
	    addAll: super allDefinedVariables;
	    yourself
    ]

    argumentNames [
	<category: 'accessing'>
	^self arguments collect: [:each | each name]
    ]

    arguments [
	<category: 'accessing'>
	^arguments
    ]

    arguments: argCollection [
	<category: 'accessing'>
	arguments := argCollection.
	arguments do: [:each | each parent: self]
    ]

    bar [
	<category: 'accessing'>
	^bar
    ]

    bar: anObject [
	<category: 'accessing'>
	bar := anObject
    ]

    blockVariables [
	<category: 'accessing'>
	| vars |
	vars := super blockVariables asOrderedCollection.
	vars addAll: self argumentNames.
	^vars
    ]

    children [
	<category: 'accessing'>
	^self arguments copyWith: self body
    ]

    colons [
	<category: 'accessing'>
	^colons
    ]

    colons: anObject [
	<category: 'accessing'>
	colons := anObject
    ]

    = anObject [
	<category: 'comparing'>
	super = anObject ifFalse: [^false].
	self arguments size = anObject arguments size ifFalse: [^false].
	1 to: self arguments size
	    do: [:i | (self arguments at: i) = (anObject arguments at: i) ifFalse: [^false]].
	^true
    ]

    equalTo: anObject withMapping: aDictionary [
	<category: 'comparing'>
	self class = anObject class ifFalse: [^false].
	self arguments size = anObject arguments size ifFalse: [^false].
	1 to: self arguments size
	    do: 
		[:i | 
		((self arguments at: i) equalTo: (anObject arguments at: i)
		    withMapping: aDictionary) ifFalse: [^false]].
	(self body equalTo: anObject body withMapping: aDictionary) 
	    ifFalse: [^false].
	self arguments do: [:each | aDictionary removeKey: each name].
	^true
    ]

    hash [
	<category: 'comparing'>
	^self arguments hash bitXor: super hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	arguments := arguments collect: [:each | each copy]
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^(super copyInContext: aDictionary)
	    arguments: (self copyList: arguments inContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self class ifFalse: [^false].
	^(super match: aNode inContext: aDictionary) and: 
		[self 
		    matchList: arguments
		    against: aNode arguments
		    inContext: aDictionary]
    ]

    replaceNode: aNode withNode: anotherNode [
	<category: 'replacing'>
	super replaceNode: aNode withNode: anotherNode.
	self arguments: (arguments 
		    collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
    ]

    defines: aName [
	<category: 'testing'>
	^(arguments detect: [:each | each name = aName] ifNone: [nil]) notNil
    ]

    isBlock [
	<category: 'testing'>
	^true
    ]

    isImmediate [
	<category: 'testing'>
	^true
    ]

    uses: aNode [
	<category: 'testing'>
	aNode = body ifFalse: [^false].
	^parent isMessage 
	    ifTrue: 
		[(#(#ifTrue:ifFalse: #ifTrue: #ifFalse: #ifFalse:ifTrue:) 
		    includes: parent selector) not 
		    or: [parent isUsed]]
	    ifFalse: [self isUsed]
    ]

    acceptVisitor: aProgramNodeVisitor [
	<category: 'visitor'>
	^aProgramNodeVisitor acceptBlockNode: self
    ]
]



RBBlockNode subclass: RBPatternBlockNode [
    | valueBlock |
    
    <category: 'Refactory-ParseTree Matching'>
    <comment: nil>

    addArgumentWithNameBasedOn: aString [
	<category: 'matching'>
	| name index vars |
	name := aString.
	vars := self allDefinedVariables.
	index := 0.
	[vars includes: name] whileTrue: 
		[index := index + 1.
		name := name , index printString].
	arguments := arguments copyWith: (RBVariableNode named: name)
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^self replacingBlock value: aDictionary
    ]

    createBlock [
	<category: 'matching'>
	| source |
	source := self formattedCode.
	^Behavior evaluate: source
    ]

    createMatchingBlock [
	<category: 'matching'>
	self arguments size > 2 
	    ifTrue: 
		[self 
		    error: 'Search blocks can only contain arguments for the node and matching dictionary'].
	self arguments size == 0 
	    ifTrue: [self error: 'Search blocks must contain one argument for the node'].
	self arguments size = 1 
	    ifTrue: [self addArgumentWithNameBasedOn: 'aDictionary'].
	^self createBlock
    ]

    createReplacingBlock [
	<category: 'matching'>
	self arguments size > 1 
	    ifTrue: 
		[self 
		    error: 'Replace blocks can only contain an argument for the matching dictionary'].
	self arguments size = 0 
	    ifTrue: [self addArgumentWithNameBasedOn: 'aDictionary'].
	^self createBlock
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	^self matchingBlock value: aNode value: aDictionary
    ]

    matchingBlock [
	<category: 'matching'>
	^valueBlock isNil 
	    ifTrue: [valueBlock := self createMatchingBlock]
	    ifFalse: [valueBlock]
    ]

    replacingBlock [
	<category: 'matching'>
	^valueBlock isNil 
	    ifTrue: [valueBlock := self createReplacingBlock]
	    ifFalse: [valueBlock]
    ]

    sentMessages [
	<category: 'accessing'>
	^OrderedCollection new
    ]
]



RBMessageNode subclass: RBPatternMessageNode [
    | isList isCascadeList |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBPatternMessageNode is a RBMessageNode that will match other message nodes without their selectors being equal. 

Instance Variables:
    isList    <Boolean>    are we matching each keyword or matching all keywords together (e.g., `keyword1: would match a one argument method whereas `@keywords: would match 0 or more arguments)'>

    receiver: aValueNode selectorParts: keywordTokens arguments: valueNodes [
	<category: 'initialize-release'>
	| message |
	super 
	    receiver: aValueNode
	    selectorParts: keywordTokens
	    arguments: valueNodes.
	isCascadeList := isList := false.
	message := keywordTokens first value.
	2 to: message size
	    do: 
		[:i | 
		| character |
		character := message at: i.
		character == self listCharacter 
		    ifTrue: [isList := true]
		    ifFalse: 
			[character == self cascadeListCharacter 
			    ifTrue: [isCascadeList := true]
			    ifFalse: [^self]]]
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	| selectors |
	self isList ifTrue: [^aDictionary at: self].
	selectors := self isSelectorList 
		    ifTrue: [(aDictionary at: selectorParts first value) keywords]
		    ifFalse: [selectorParts collect: [:each | aDictionary at: each value]].
	^(RBMessageNode new)
	    receiver: (receiver copyInContext: aDictionary);
	    selectorParts: (selectors collect: 
			    [:each | 
			    (each last == $: ifTrue: [RBKeywordToken] ifFalse: [RBIdentifierToken]) 
				value: each
				start: nil]);
	    arguments: (self copyList: arguments inContext: aDictionary);
	    yourself
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	aNode class == self matchingClass ifFalse: [^false].
	(receiver match: aNode receiver inContext: aDictionary) ifFalse: [^false].
	self isSelectorList 
	    ifTrue: 
		[^(aDictionary at: selectorParts first value ifAbsentPut: [aNode selector]) 
		    == aNode selector and: 
			    [(aDictionary at: arguments first ifAbsentPut: [aNode arguments]) 
				= aNode arguments]].
	^self matchArgumentsAgainst: aNode inContext: aDictionary
    ]

    matchArgumentsAgainst: aNode inContext: aDictionary [
	<category: 'matching'>
	self arguments size == aNode arguments size ifFalse: [^false].
	(self matchSelectorAgainst: aNode inContext: aDictionary) 
	    ifFalse: [^false].
	1 to: arguments size
	    do: 
		[:i | 
		((arguments at: i) match: (aNode arguments at: i) inContext: aDictionary) 
		    ifFalse: [^false]].
	^true
    ]

    matchSelectorAgainst: aNode inContext: aDictionary [
	<category: 'matching'>
	| keyword |
	1 to: selectorParts size
	    do: 
		[:i | 
		keyword := selectorParts at: i.
		(aDictionary at: keyword value
		    ifAbsentPut: 
			[keyword isPatternVariable 
			    ifTrue: [(aNode selectorParts at: i) value]
			    ifFalse: [keyword value]]) 
			= (aNode selectorParts at: i) value ifFalse: [^false]].
	^true
    ]

    matchingClass [
	<category: 'private'>
	^RBMessageNode
    ]

    isList [
	<category: 'testing-matching'>
	^isCascadeList and: [parent notNil and: [parent isCascade]]
    ]

    isSelectorList [
	<category: 'testing-matching'>
	^isList
    ]
]



RBVariableNode subclass: RBPatternVariableNode [
    | recurseInto isList isLiteral isStatement isAnything |
    
    <category: 'Refactory-Parser'>
    <comment: 'RBPatternVariableNode is an AST node that is used to match several other types of nodes (literals, variables, value nodes, statement nodes, and sequences of statement nodes).

The different types of matches are determined by the name of the node. If the name contains a # character, then it will match a literal. If it contains, a . then it matches statements. If it contains no extra characters, then it matches only variables. These options are mutually exclusive.

The @ character can be combined with the name to match lists of items. If combined with the . character, then it will match a list of statement nodes (0 or more). If used without the . or # character, then it matches anything except for list of statements. Combining the @ with the # is not supported.

Adding another ` in the name will cause the search/replace to look for more matches inside the node that this node matched. This option should not be used for top level expressions since that would cause infinite recursion (e.g., searching only for "``@anything").

Instance Variables:
    isList    <Boolean>    can we match a list of items (@)
    isLiteral    <Boolean>    only match a literal node (#)
    isStatement    <Boolean>    only match statements (.)
    recurseInto    <Boolean>    search for more matches in the node we match (`)

'>

    identifierToken: anIdentifierToken [
	<category: 'initialize-release'>
	super identifierToken: anIdentifierToken.
	self initializePatternVariables
    ]

    initializePatternVariables [
	<category: 'initialize-release'>
	| name |
	name := self name.
	isAnything := isList := isLiteral := isStatement := recurseInto := false.
	2 to: name size
	    do: 
		[:i | 
		| character |
		character := name at: i.
		character == self listCharacter 
		    ifTrue: [isAnything := isList := true]
		    ifFalse: 
			[character == self literalCharacter 
			    ifTrue: [isLiteral := true]
			    ifFalse: 
				[character == self statementCharacter 
				    ifTrue: [isStatement := true]
				    ifFalse: 
					[character == self recurseIntoCharacter 
					    ifTrue: [recurseInto := true]
					    ifFalse: [^self]]]]]
    ]

    parent: aRBProgramNode [
	"Fix the case where '``@node' should match a single node, not a sequence node."

	<category: 'accessing'>
	super parent: aRBProgramNode.
	parent isSequence 
	    ifTrue: 
		[(self isStatement or: [parent temporaries includes: self]) 
		    ifFalse: [isList := false]]
    ]

    copyInContext: aDictionary [
	<category: 'matching'>
	^aDictionary at: self
    ]

    match: aNode inContext: aDictionary [
	<category: 'matching'>
	self isAnything 
	    ifTrue: [^(aDictionary at: self ifAbsentPut: [aNode]) = aNode].
	self isLiteral ifTrue: [^self matchLiteral: aNode inContext: aDictionary].
	self isStatement 
	    ifTrue: [^self matchStatement: aNode inContext: aDictionary].
	aNode class == self matchingClass ifFalse: [^false].
	^(aDictionary at: self ifAbsentPut: [aNode]) = aNode
    ]

    matchLiteral: aNode inContext: aDictionary [
	<category: 'matching'>
	^aNode class == RBLiteralNode 
	    and: [(aDictionary at: self ifAbsentPut: [aNode]) = aNode]
    ]

    matchStatement: aNode inContext: aDictionary [
	<category: 'matching'>
	(aNode parent notNil and: [aNode parent isSequence]) ifFalse: [^false].
	^(aDictionary at: self ifAbsentPut: [aNode]) = aNode
    ]

    matchingClass [
	<category: 'private'>
	^RBVariableNode
    ]

    isAnything [
	<category: 'testing-matching'>
	^isAnything
    ]

    isList [
	<category: 'testing-matching'>
	^isList
    ]

    isLiteral [
	<category: 'testing-matching'>
	^isLiteral
    ]

    isStatement [
	<category: 'testing-matching'>
	^isStatement
    ]

    recurseInto [
	<category: 'testing-matching'>
	^recurseInto
    ]
]

PK
     �Mh@���C�  �  
  RBToken.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Refactoring Browser - Token classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1998-2000 The Refactory, Inc.
|
| This file is distributed together with GNU Smalltalk.
|
 ======================================================================"



Object subclass: RBToken [
    | sourcePointer |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBToken class >> start: anInterval [
	<category: 'instance creation'>
	^self new start: anInterval
    ]

    compiler: aCompiler [
	"do nothing by default"

	<category: 'accessing'>
	
    ]

    length [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    removePositions [
	<category: 'accessing'>
	sourcePointer := nil
    ]

    start [
	<category: 'accessing'>
	^sourcePointer
    ]

    stop [
	<category: 'accessing'>
	^self start + self length - 1
    ]

    start: anInteger [
	<category: 'initialize-release'>
	sourcePointer := anInteger
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $ ;
	    nextPutAll: self class name
    ]

    isAssignment [
	<category: 'testing'>
	^false
    ]

    isBinary [
	<category: 'testing'>
	^false
    ]

    isCompileTimeBound [
	<category: 'testing'>
	^false
    ]

    isIdentifier [
	<category: 'testing'>
	^false
    ]

    isKeyword [
	<category: 'testing'>
	^false
    ]

    isLiteral [
	<category: 'testing'>
	^false
    ]

    isOptimized [
	<category: 'testing'>
	^false
    ]

    isPatternVariable [
	<category: 'testing'>
	^false
    ]

    isPatternBlock [
	<category: 'testing'>
	^false
    ]

    isSpecial [
	<category: 'testing'>
	^false
    ]

    isValue [
	<category: 'accessing'>
	^false
    ]
]



RBToken subclass: RBValueToken [
    | value |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBValueToken class >> value: aString start: anInteger [
	<category: 'instance creation'>
	^self new value: aString start: anInteger
    ]

    isValue [
	<category: 'accessing'>
	^true
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: anObject [
	<category: 'accessing'>
	value := anObject
    ]

    value: aString start: anInteger [
	<category: 'initialize-release'>
	value := aString.
	sourcePointer := anInteger
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream nextPut: $(.
	value printOn: aStream.
	aStream nextPutAll: ')'
    ]

    length [
	<category: 'private'>
	^value size
    ]
]



RBToken subclass: RBAssignmentToken [
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    length [
	<category: 'private'>
	^2
    ]

    isAssignment [
	<category: 'testing'>
	^true
    ]
]



RBValueToken subclass: RBLiteralToken [
    | stopPosition |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    RBLiteralToken class >> value: anObject [
	<category: 'instance creation'>
	| literal |
	literal := anObject class == Array 
		    ifTrue: [anObject collect: [:each | self value: each]]
		    ifFalse: [anObject].
	^self 
	    value: literal
	    start: nil
	    stop: nil
    ]

    RBLiteralToken class >> value: aString start: anInteger stop: stopInteger [
	<category: 'instance creation'>
	^self new 
	    value: aString
	    start: anInteger
	    stop: stopInteger
    ]

    compiler: aCompiler [
	<category: 'accessing'>
	value class == Array 
	    ifTrue: [value do: [:each | each compiler: aCompiler]]
    ]

    realValue [
	<category: 'accessing'>
	^value class == Array 
	    ifTrue: [value collect: [:each | each realValue]]
	    ifFalse: [value]
    ]

    stop: anObject [
	<category: 'accessing'>
	stopPosition := anObject
    ]

    value: aString start: anInteger stop: stopInteger [
	<category: 'initialize-release'>
	value := aString.
	sourcePointer := anInteger.
	stopPosition := stopInteger
    ]

    length [
	<category: 'private'>
	^stopPosition - self start + 1
    ]

    isLiteral [
	<category: 'testing'>
	^true
    ]
]



RBLiteralToken subclass: RBBindingToken [
    | compiler association |
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    compiler: aCompiler [
	<category: 'accessing'>
	compiler := aCompiler
    ]

    isCompileTimeBound [
	<category: 'accessing'>
	^true
    ]

    realValue [
	<category: 'accessing'>
	association notNil ifTrue: [^association].
	compiler isNil ifTrue: [^self value].
	^association := compiler bindingOf: (self value substrings: $.)
    ]
]



RBValueToken subclass: RBBinarySelectorToken [
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    isBinary [
	<category: 'testing'>
	^true
    ]
]



RBValueToken subclass: RBSpecialCharacterToken [
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    length [
	<category: 'private'>
	^1
    ]

    isSpecial [
	<category: 'testing'>
	^true
    ]
]



RBValueToken subclass: RBIdentifierToken [
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    isIdentifier [
	<category: 'testing'>
	^true
    ]

    isPatternVariable [
	<category: 'testing'>
	^value first == RBScanner patternVariableCharacter
    ]
]



RBValueToken subclass: RBKeywordToken [
    
    <category: 'Refactory-Parser'>
    <comment: nil>

    isKeyword [
	<category: 'testing'>
	^true
    ]

    isPatternVariable [
	<category: 'testing'>
	^value first == RBScanner patternVariableCharacter
    ]
]



RBToken subclass: RBOptimizedToken [
    
    <category: 'Refactory-Scanner'>
    <comment: nil>

    isOptimized [
	<category: 'testing'>
	^true
    ]

    length [
	<category: 'testing'>
	^3
    ]
]



RBValueToken subclass: RBPatternBlockToken [
    
    <category: 'Refactory-Scanner'>
    <comment: nil>

    isPatternBlock [
	<category: 'testing'>
	^true
    ]
]

PK
     �Mh@%��      STLoaderObjs.stUT	 eqXOJ�XOux �  �  "======================================================================
|
|   Smalltalk proxy class loader -- auxiliary classes
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2007, 2008, 2009
| Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
| 
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
| 
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

STInST addSubspace: #STClassLoaderObjects!
Namespace current: STClassLoaderObjects!

Warning subclass: #UndefinedClassWarning
        instanceVariableNames: 'undefinedClass'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

!UndefinedClassWarning class methodsFor: 'exception handling'!

signal: anObject
    ^self new
        undefinedClass: anObject;
        signal
! !

!UndefinedClassWarning methodsFor: 'exception handling'!

description
    ^'undefined class'
!

messageText
    ^'undefined class %1' % {self undefinedClass name asString}
!

undefinedClass
    ^undefinedClass
!

undefinedClass: anObject
    undefinedClass := anObject
! !


Object subclass: #PseudoBehavior
        instanceVariableNames: 'subclasses methods loader'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

PseudoBehavior comment:
'This class represent a proxy for a class that is found by an
STClassLoader in the source code it parses.'!

Collection subclass: #OverlayDictionary
           instanceVariableNames: 'primary secondary additionalSize'
           classVariableNames: ''
           poolDictionaries: ''
           category: 'System-Compiler'!

OverlayDictionary comment:
'This class can access multiple Dictionaries and return keys from
any of them'!

!OverlayDictionary class methodsFor: 'instance creation'!

on: backupDictionary
    backupDictionary isNil ifTrue: [ ^LookupTable new ].
    ^self new primary: LookupTable new; secondary: backupDictionary
! !

!OverlayDictionary methodsFor: 'accessing'!

do: aBlock
    primary do: aBlock.
    secondary keysAndValuesDo: [ :k :v |
        (primary includes: k) ifFalse: [ aBlock value: v ] ]!

keysDo: aBlock
    primary keysDo: aBlock.
    secondary keysAndValuesDo: [ :k :v |
        (primary includes: k) ifFalse: [ aBlock value: k ] ]!

keysAndValuesDo: aBlock
    primary keysAndValuesDo: aBlock.
    secondary keysAndValuesDo: [ :k :v |
        (primary includes: k) ifFalse: [ aBlock value: k value: v ] ]!

keys
    ^primary keys addAll: secondary keys; yourself!

values
    ^self asOrderedCollection!

size
    ^primary size + additionalSize!

at: key
    ^primary at: key ifAbsent: [ secondary at: key ]!

at: key put: value
    primary at: key ifAbsent: [
        (secondary includesKey: key)
	    ifTrue: [ additionalSize := additionalSize - 1 ] ].
    ^primary at: key put: value!

at: key ifAbsent: aBlock
    ^primary at: key ifAbsent: [ secondary at: key ifAbsent: aBlock ]!

at: key ifAbsentPut: aBlock
    ^primary at: key ifAbsent: [
        (secondary includesKey: key)
	    ifTrue: [ secondary at: key ]
	    ifFalse: [ primary at: key put: aBlock value ] ]! !



!OverlayDictionary methodsFor: 'initializing'!

primary: aDictionary
    primary := aDictionary!

secondary: aDictionary
    secondary := aDictionary.
    additionalSize := secondary size.
! !


PseudoBehavior subclass: #UndefinedClass
        instanceVariableNames: 'name class environment'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

UndefinedClass comment:
'This class represent a proxy for a class that is found by an
STClassLoader while parsing source code, but is not
the system.  It is possible to handle subclasses and extension methods
of such classes.'!

PseudoBehavior subclass: #UndefinedMetaclass
        instanceVariableNames: 'instanceClass'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

UndefinedMetaclass comment:
'This class represent a proxy for the metaclass of a class that is found
by an STClassLoader while parsing source code, but is not the system.'!

PseudoBehavior subclass: #ProxyClass
        instanceVariableNames: 'proxy otherSide'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

ProxyClass comment:
'This class represent a proxy for a preexisting class that is found by an
STClassLoader as a superclass while parsing source code.  Proxying
preexisting classes is necessary to correctly augment their subclasses
with the new classes, and to handle extension methods.'!

ProxyClass subclass: #ProxyNilClass
        instanceVariableNames: ''
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

ProxyClass comment:
'This class represent a proxy for the nil fake superclass.'!

PseudoBehavior subclass: #LoadedBehavior
        instanceVariableNames: 'instVars superclass comment '
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

LoadedBehavior comment:
'This class represent a proxy for a class object that is defined
by an STClassLoader.'!

LoadedBehavior subclass: #LoadedClass
        instanceVariableNames: 'name category sharedPools classVars class
				environment shape declaration '
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

LoadedClass comment:
'This class represent a proxy for a class whose source code is parsed
by an STClassLoader.'!

LoadedBehavior subclass: #LoadedMetaclass
        instanceVariableNames: 'instanceClass '
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

LoadedMetaclass comment:
'This class represent a proxy for a metaclass whose source code is parsed
by an STClassLoader.'!

Object subclass: #LoadedMethod
        instanceVariableNames: 'node category isOldSyntax'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

LoadedMethod comment:
'This class represent a proxy for a method, containing the source code
that was parsed by an STClassLoader.'!

BindingDictionary variableSubclass: #PseudoNamespace
        instanceVariableNames: 'loader subspaces'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

PseudoNamespace comment:
'This class represent a proxy for a namespace that an STClassLoader finds
along the way.'!

PseudoNamespace variableSubclass: #LoadedNamespace
        instanceVariableNames: 'name'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

PseudoNamespace comment:
'This class represent a proxy for a namespace that is created by the
source code that an STClassLoader is parsing.'!

PseudoNamespace variableSubclass: #ProxyNamespace
        instanceVariableNames: 'proxy'
        classVariableNames: ''
        poolDictionaries: ''
        category: 'System-Compiler'!

ProxyNamespace comment:
'This class represent a proxy for a preexisting namespace that is
referenced by the source code that an STClassLoader is parsing.'!

!PseudoBehavior class methodsFor: 'creating'!

for: aSTClassLoader
    ^self new initialize: aSTClassLoader
! !

!PseudoBehavior methodsFor: 'creating classes'!

variableByteSubclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: c
	shape: #byte
        environment: loader currentNamespace
	loader: loader!
 
variableWordSubclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: c
	shape: #word
        environment: loader currentNamespace
	loader: loader!
 
variable: shape subclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: c
	shape: shape
        environment: loader currentNamespace
	loader: loader!
 
variableSubclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: c
	shape: #pointer
        environment: loader currentNamespace
	loader: loader!
 
subclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: c
	shape: nil
        environment: loader currentNamespace
	loader: loader!

subclass: s declaration: cstructDecl classVariableNames: cvn
	poolDictionaries: pd category: c

    ^(self
	subclass: s
	instanceVariableNames: ''
	classVariableNames: cvn
	poolDictionaries: pd
	category: c) declaration: cstructDecl; yourself!

variableByteSubclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: ''
	shape: #byte
        environment: loader currentNamespace
	loader: loader!
 
variableWordSubclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: ''
	shape: #word
        environment: loader currentNamespace
	loader: loader!
 
variable: shape subclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: ''
	shape: shape
        environment: loader currentNamespace
	loader: loader!
 
variableSubclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: ''
	shape: #pointer
        environment: loader currentNamespace
	loader: loader!
 
subclass: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ivn
	classVariableNames: cvn
	poolDictionaries: pd
	category: ''
	shape: nil
        environment: loader currentNamespace
	loader: loader!

subclass: s

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''
	shape: nil
        environment: loader currentNamespace
	loader: loader!

subclass: s environment: env

    ^LoadedClass
	superclass: self
	name: s
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''
	shape: nil
        environment: env
	loader: loader!

!PseudoBehavior methodsFor: 'method dictionary services'!

selectors
    "Answer a Set of the receiver's selectors"
    ^self methodDictionary keys
!

allSelectors
    "Answer a Set of all the selectors understood by the receiver"
    | aSet |
    aSet := self selectors.
    self allSuperclassesDo:
        [ :superclass | aSet addAll: superclass selectors ].
    ^aSet
!

compiledMethodAt: selector
    "Return the compiled method associated with selector, from the local
    method dictionary.  Error if not found."
    ^self methodDictionary at: selector
!

includesSelector: selector
    "Return whether there is a compiled method associated with
    selector, from the local method dictionary."
    ^self methodDictionary includesKey: selector
!

parseNodeAt: selector
    "Answer the parse tree (if available) for the given selector"
    ^(self >> selector) methodParseNode
!

sourceCodeAt: selector
    "Answer source code (if available) for the given selector"
    | source |
    source := (self >> selector) methodSourceCode.
    source isNil ifTrue: [ '" *** SOURCE CODE NOT AVAILABLE *** "' copy ].
    ^source asString
!

>> selector
    "Return the compiled method associated with selector, from the local
    method dictionary.  Error if not found."
    ^self methodDictionary at: selector
! !


!PseudoBehavior methodsFor: 'navigating hierarchy'!

subclasses
    subclasses isNil
        ifTrue: [ subclasses := OrderedCollection new ].
    ^subclasses
!

addSubclass: aClass
    "Add aClass asone of the receiver's subclasses."
    self subclasses remove: aClass ifAbsent: [].
    self subclasses add: aClass
!

removeSubclass: aClass
    "Remove aClass from the list of the receiver's subclasses"
    self subclasses remove: aClass ifAbsent: [].
!

allSubclassesDo: aBlock
    "Invokes aBlock for all subclasses, both direct and indirect."
    self subclasses do: [ :class |
        aBlock value: class.
        class allSubclassesDo: aBlock
    ].
!

allSuperclassesDo: aBlock
    "Invokes aBlock for all superclasses, both direct and indirect."
    | class superclass |
    class := self.
    [ superclass := class superclass.
      class := superclass.
      superclass notNil ] whileTrue:
        [ aBlock value: superclass ]
!

withAllSubclassesDo: aBlock
    "Invokes aBlock for the receiver and all subclasses, both direct
     and indirect."
    aBlock value: self.
    self allSubclassesDo: aBlock.
!

withAllSuperclassesDo: aBlock
    "Invokes aBlock for the receiver and all superclasses, both direct
     and indirect."
    | class |
    class := self.
    [ aBlock value: class.
      class := class superclass.
      class notNil ] whileTrue
!

selectSubclasses: aBlock
    "Return a Set of subclasses of the receiver satisfying aBlock."
    | aSet |
    aSet := Set new.
    self allSubclassesDo: [ :subclass | (aBlock value: subclass)
                                            ifTrue: [ aSet add: subclass ] ].
    ^aSet
!

selectSuperclasses: aBlock
    "Return a Set of superclasses of the receiver satisfying aBlock."
    | aSet |
    aSet := Set new.
    self allSuperclassesDo: [ :superclass | (aBlock value: superclass)
                                            ifTrue: [ aSet add: superclass ] ].
    ^aSet
!

subclassesDo: aBlock
    "Invokes aBlock for all direct subclasses."
    self subclasses do: aBlock
! !

!PseudoBehavior methodsFor: 'accessing'!

loader
    ^loader
!

allInstVarNames
    "Answer the names of the variables in the receiver's inst pool dictionary
     and in each of the superinstes' inst pool dictionaries"

    ^self superclass allInstVarNames, self instVarNames
!

allClassVarNames
    "Answer the names of the variables in the receiver's class pool dictionary
     and in each of the superclasses' class pool dictionaries"

    ^self asClass allClassVarNames
!

allSharedPools
    "Return the names of the shared pools defined by the class and any of
     its superclasses"

    ^self asClass allSharedPools
!

nameIn: aNamespace
    "Answer the class name when the class is referenced from aNamespace"
    | proxy reference |
    proxy := loader proxyForNamespace: aNamespace.
    reference := proxy at: self name asSymbol ifAbsent: [ nil ].
    self = reference ifTrue: [ ^self name asString ].
    ^(self environment nameIn: aNamespace), '.', self printString
! !


!PseudoBehavior methodsFor: 'testing'!

isDefined
    ^true
!

isFullyDefined
    self isDefined ifFalse: [ ^false ].
    ^self superclass isNil or: [ self superclass isFullyDefined ]
! !


!PseudoBehavior methodsFor: 'abstract'!

classPragmas
    self subclassResponsibility
!

asClass
    self subclassResponsibility
!

asMetaclass
    self subclassResponsibility
!

category
    ^nil
!

comment
    self subclassResponsibility
!

kindOfSubclass
    "Return a string indicating the type of class the receiver is"

    self shape isNil ifFalse: [^'subclass:'].
    self shape == #pointer ifTrue: [^'variableSubclass:'].
    self shape == #byte ifTrue: [^'variableByteSubclass:'].
    self shape == (CLongSize == 4 ifTrue: [ #uint32 ] ifFalse: [ #uint64 ])
	ifTrue: [^'variableWordSubclass:'].
    ^'variable: ' , self shape storeString , 'subclass:'
!

inheritShape
    ^false
!

shape
    ^nil
!

environment
    self subclassResponsibility
!

kindOfSubclass
    "Return a string indicating the type of class the receiver is"
    self shape isNil ifTrue: [ ^'subclass:' ].
    self shape == #pointer ifTrue: [ ^'variableSubclass:' ].
    ^'variable: ', self shape storeString, 'subclass:'
!

inheritShape
    ^false
!

sharedPools
    self subclassResponsibility
!

superclass
    self subclassResponsibility
!

methodDictionary
    methods isNil ifTrue: [ methods := LookupTable new ].
    ^methods
! 

methodDictionary: aDictionary
    methods := aDictionary
!

collectCategories
    | categories |
    self methodDictionary isNil ifTrue: [ ^#() ].

    categories := Set new.
    self methodDictionary do:
	[ :method | categories add: (method methodCategory) ].

    ^categories asSortedCollection 
! !

!PseudoBehavior methodsFor: 'printing'!

printOn: aStream
    aStream
	nextPutAll: self name!
! !

!PseudoBehavior methodsFor: 'storing'!

storeOn: aStream
    aStream
	nextPutAll: self name!
! !

!PseudoBehavior methodsFor: 'initializing'!

initialize: aSTClassLoader
    loader := aSTClassLoader
! !

!ProxyClass class methodsFor: 'creating classes'!

on: aClass for: aSTClassLoader
    ^(self for: aSTClassLoader) setProxy: aClass
! !

!ProxyClass methodsFor: 'testing'!

isDefined
     ^true
!

isFullyDefined
     ^true
! !

!ProxyClass methodsFor: 'delegation'!

= anObject
    ^proxy == anObject 
	or: [ anObject class == self class
		 and: [ proxy == anObject proxy ] ]
!

hash
    ^proxy hash
!

proxy
   ^proxy
!

classPragmas
    ^proxy classPragmas
!

printOn: aStream
    proxy printOn: aStream
!

asClass
    proxy isClass ifTrue: [ ^self ].
    otherSide isNil
	ifTrue: [ otherSide := ProxyClass on: proxy instanceClass for: self loader ].
    ^otherSide
!

asMetaclass
    proxy isMetaclass ifTrue: [ ^self ].
    otherSide isNil
	ifTrue: [ otherSide := ProxyClass on: proxy class for: self loader ].
    ^otherSide
!

isClass
    ^proxy isClass
!

isMetaclass
    ^proxy isMetaclass
!

category
    ^proxy category
!

comment
    ^proxy comment
!

environment
    ^proxy environment
!

inheritShape
    ^proxy inheritShape
!

shape
    ^proxy shape
!

superclass
    ^proxy superclass
!

doesNotUnderstand: aMessage
    ^proxy perform: aMessage
! !


!ProxyClass methodsFor: 'initializing'!

setProxy: aClass
    proxy := aClass.
    self methodDictionary: (OverlayDictionary on: proxy methodDictionary)
! !

!ProxyNilClass methodsFor: 'accessing'!

classPragmas
    ^#(#comment #category)
!

nameIn: aNamespace
    ^'nil'
! !

!UndefinedClass class methodsFor: 'creating'!

name: aSymbol in: aNamespace for: aLoader
    ^(self for: aLoader)
	environment: aNamespace;
	name: aSymbol
! !

!UndefinedClass methodsFor: 'testing'!

isDefined
    ^false
! !

!UndefinedClass methodsFor: 'accessing'!

asMetaclass
    ^class!

asClass
    ^self!

classPragmas
    ^#(#comment #category)
!

name
    ^name
!

name: aSymbol
    name := aSymbol
!

initialize: aSTLoader
    super initialize: aSTLoader.
    class := UndefinedMetaclass for: self
!

environment
    ^environment
!

environment: aNamespace
    environment := aNamespace.
!

superclass
    UndefinedClassWarning signal: self.
    ^nil
! !

!UndefinedClass methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: self name!
! !

!UndefinedMetaclass class methodsFor: 'creating'!

for: aClass
    ^(super for: aClass loader)
	initializeFor: aClass! !

!UndefinedMetaclass methodsFor: 'printing'!

printOn: aStream
    aStream
	nextPutAll: self asClass name;
	nextPutAll: ' class'!
! !

!UndefinedMetaclass methodsFor: 'initializing'!

initializeFor: aClass
    super initialize: aClass loader.
    instanceClass := aClass! !

!UndefinedMetaclass methodsFor: 'accessing'!

isClass
    ^false
!

isMetaclass
    ^true
!

asClass
    ^instanceClass
!

asMetaclass
    ^self
! !

!UndefinedMetaclass methodsFor: 'delegation'!

name
    ^self asClass name
!

category
    "Answer the class category"
    ^self asClass category
!

comment
    "Answer the class comment"
    ^self asClass comment
!

comment: aString
    "Answer the class comment"
    ^self asClass comment: aString
!

environment
    "Answer the namespace in which the receiver is implemented"
    ^self asClass environment
!

classVarNames
    "Answer the names of the variables in the class pool dictionary"

    ^self asClass classVarNames
!

sharedPools
    "Return the names of the shared pools defined by the class"

    ^self asClass sharedPools
! !

!UndefinedMetaclass methodsFor: 'testing'!

isDefined
    ^false
! !

!UndefinedMetaclass methodsFor: 'delegation'!

name
    ^self asClass name
! !



!LoadedMetaclass class methodsFor: 'creating'!

for: aClass
    ^(super for: aClass loader)
	initializeFor: aClass! !

!LoadedBehavior methodsFor: 'accessing'!

instVarNames
    "Answer the names of the variables in the inst pool dictionary"

    ^instVars
!

instanceVariableNames: ivn
    instVars := ivn subStrings.
!

superclass
    ^superclass
! !

!LoadedMetaclass methodsFor: 'printing'!

printOn: aStream
    aStream
	nextPutAll: self asClass name;
	nextPutAll: ' class'!
! !

!LoadedMetaclass methodsFor: 'accessing'!

isClass
    ^false
!

isMetaclass
    ^true
!

asClass
    ^instanceClass
!

asMetaclass
    ^self
! !

!LoadedMetaclass methodsFor: 'delegation'!

name
    ^self asClass name
!

category
    "Answer the class category"
    ^self asClass category
!

comment
    "Answer the class comment"
    ^self asClass comment
!

comment: aString
    "Answer the class comment"
    ^self asClass comment: aString
!

environment
    "Answer the namespace in which the receiver is implemented"
    ^self asClass environment
!

classVarNames
    "Answer the names of the variables in the class pool dictionary"

    ^self asClass classVarNames
!

sharedPools
    "Return the names of the shared pools defined by the class"

    ^self asClass sharedPools
! !



!LoadedMetaclass class methodsFor: 'creating'!

for: aClass
    ^(super for: aClass loader)
	initializeFor: aClass! !

!LoadedMetaclass methodsFor: 'initializing'!

initializeFor: aClass
    super initialize: aClass loader.
    instanceClass := aClass.
    instVars := Array new.
    superclass := aClass superclass class.
    superclass addSubclass: self
!

!LoadedClass class methodsFor: 'creating classes'!

superclass: sup name: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c shape: sh environment: env loader: loader
    ^(self for: loader)
	superclass: sup name: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c shape: sh environment: env
! !

!LoadedClass methodsFor: 'accessing'!

isClass
    ^true
!

isMetaclass
    ^false
!

asClass
    ^self
!

asMetaclass
    ^class
!

name
    "Answer the class name"
    ^name
!

category
    "Answer the class category"
    ^category
!

category: aString
    "Set the class category"
    category := aString
!

classPragmas
    ^superclass classPragmas
!

declaration
    "Answer the class declaration for CStruct subclasses"
    ^declaration
!

declaration: aString
    "Set the class declaration (for CStruct subclasses)"
    declaration := aString
!

shape
    "Answer the class shape"
    ^shape
!

shape: aSymbol
    "Set the class shape"
    shape := aSymbol
!

comment
    "Answer the class comment"
    ^comment
!

comment: aString
    "Set the class comment"
    comment := aString
!

environment
    "Answer the namespace in which the receiver is implemented"
    ^environment
!

classVarNames
    "Answer the names of the variables in the class pool dictionary"

    ^classVars
!

sharedPools
    "Return the names of the shared pools defined by the class"

    ^sharedPools
!

addClassVarName: aString
    "Return the names of the shared pools defined by the class"

    sharedPools := sharedPools copyWith: aString
!

addClassVarName: aString value: aBlock
    "Return the names of the shared pools defined by the class"

    sharedPools := sharedPools copyWith: aString
!

import: aNamespace
    "Return the names of the shared pools defined by the class"

    sharedPools := sharedPools copyWith: (aNamespace nameIn: self environment)
! !


!LoadedClass methodsFor: 'initializing'!

superclass: sup name: s instanceVariableNames: ivn classVariableNames: cvn
	poolDictionaries: pd category: c shape: sh environment: env
    superclass := sup.
    name := s.
    category := c.
    shape := sh.
    environment := env.
    class := LoadedMetaclass for: self.
    instVars := ivn subStrings.
    classVars := cvn subStrings.
    sharedPools := pd subStrings.
    superclass addSubclass: self.
    environment at: name put: self.
! !

!LoadedMethod class methodsFor: 'instance creation'!

node: aRBMethodNode
    ^self new
	    node: aRBMethodNode
!

!LoadedMethod methodsFor: 'accessing'!

node
    ^node
!

node: aRBMethodNode
    node := aRBMethodNode.
    category := node category.
    category isNil ifTrue: [ self extractMethodCategory ]
!

extractMethodCategory
    node primitiveSources do: [:each |
	self extractMethodCategory: (RBScanner on: each readStream).
	category isNil ifFalse: [ ^self ] ]
!

extractMethodCategory: scanner
    | currentToken argument |
    currentToken := scanner next.
    (currentToken isBinary and: [currentToken value == #<]) ifFalse: [^self].
    currentToken := scanner next.
    currentToken isKeyword ifFalse: [^self].
    currentToken value = 'category:' ifFalse: [^self].
    currentToken := scanner next.
    currentToken isLiteral ifFalse: [^self].
    argument := currentToken value.
    currentToken := scanner next.
    (currentToken isBinary and: [currentToken value == #>]) ifFalse: [^self].
    category := argument.
!

methodFormattedSourceString
    "Answer the method source code as a string, formatted using
     the RBFormatter."

    <category: 'compiling'>
    ^STInST.RBFormatter new
                  initialIndent: 1;
                  format: self methodParseNode
!

methodParseNode
    ^self node
!

methodCategory
    ^category
!

methodSourceCode
    ^node source asSourceCode
!

selector
    ^node selector asSymbol
!

methodSourceString
    ^node source asString
!

isOldSyntax
    ^isOldSyntax ifNil: [false]
!

noteOldSyntax
    isOldSyntax := true.
! !

!LoadedMethod methodsFor: 'empty stubs'!

discardTranslation
    "Do nothing"
! !

!PseudoNamespace methodsFor: 'abstract'!

name
    self subclassResponsibility! !

!PseudoNamespace methodsFor: 'printing'!

nameIn: aNamespace
    "Answer Smalltalk code compiling to the receiver when the current
     namespace is aNamespace"

    | reference proxy |
    proxy := loader proxyForNamespace: aNamespace.
    reference := proxy at: self name asSymbol ifAbsent: [ nil ].
    self = reference ifTrue: [ ^self name asString ].
    ^(self superspace nameIn: aNamespace ), '.', self name
!

printOn: aStream
    aStream nextPutAll: (self nameIn: Namespace current)
! !

!PseudoNamespace methodsFor: 'storing'!

storeOn: aStream
    aStream nextPutAll: (self nameIn: Namespace current)
! !

!PseudoNamespace methodsFor: 'initializing'!

copyEmpty: newSize
    ^(super copyEmpty: newSize)
	setLoader: loader;
	setSubspaces: subspaces;
	yourself
!

setLoader: aSTClassLoader
    loader := aSTClassLoader
!

setSubspaces: aSet
    subspaces := aSet
! !

!PseudoNamespace methodsFor: 'accessing'!

superspace
    ^self environment
!

setSuperspace: superspace
    self environment: superspace.
    self environment subspaces add: self
!

subspaces
    subspaces isNil ifTrue: [ subspaces := IdentitySet new ].
    ^subspaces
!

addSubspace: aSymbol
    ^LoadedNamespace name: aSymbol in: self for: loader
! !

!LoadedNamespace class methodsFor: 'instance creation'!

name: aSymbol in: aDictionary for: aSTClassLoader
    ^aDictionary at: aSymbol put: (self new
	name: aSymbol;
	setLoader: aSTClassLoader;
	environment: aDictionary;
	yourself)
! !

!LoadedNamespace methodsFor: 'initializing'!
copyEmpty: newSize
    ^(super copyEmpty: newSize)
        name: name;
    	yourself
! !
 
!LoadedNamespace methodsFor: 'accessing'!

at: key ifAbsent: aBlock
    "Return the value associated to the variable named as specified
    by `key'. If the key is not found search will be brought on in
    superspaces, finally evaluating aBlock if the variable cannot be
    found in any of the superspaces."
    | index space |
    space := self.
    [
	space at: key ifPresent: [ :value | ^value ].
	space := space superspace.
	space isNil 
    ] whileFalse.
    ^aBlock value
!

name
    ^name
!

name: aSymbol
    name := aSymbol
! !

!LoadedNamespace methodsFor: 'printing'!

printOn: aStream
    aStream
	nextPutAll: 'LoadedNamespace[';
	nextPutAll: self name;
	nextPut: $]! !


!ProxyNamespace class methodsFor: 'accessing'!

on: aDictionary for: aSTClassLoader
    | instance superspace subspaceProxy |
    instance := self new
	setLoader: aSTClassLoader;
	setProxy: aDictionary;
	yourself.

    "Link the instance to itself."
    instance
	at: aDictionary name asSymbol put: instance.

    "Create proxies for the superspaces and for links to the
     subspaces"
    aDictionary superspace isNil ifFalse: [
	superspace := aDictionary superspace.
	instance
	    setSuperspace: (aSTClassLoader proxyForNamespace: superspace).

	subspaceProxy := instance.
	[ superspace isNil ] whileFalse: [
	    superspace := aSTClassLoader proxyForNamespace: superspace.
	    superspace
		at: subspaceProxy name asSymbol put: subspaceProxy.
	    instance
		at: superspace name asSymbol put: superspace.
	    subspaceProxy := superspace.
	    superspace := superspace superspace
	].
    ].

    ^instance
! !

!ProxyNamespace methodsFor: 'initializing'!

copyEmpty: newSize
    ^(super copyEmpty: newSize)
	setProxy: proxy;
	yourself
!

setProxy: aDictionary
    proxy := aDictionary!
! !

!ProxyNamespace methodsFor: 'accessing'!

= anObject
    ^anObject == self proxy or: [
	anObject class == self class and: [
	    self proxy == anObject proxy ]]
!

hash
    ^proxy hash
!

proxy
    ^proxy
!

at: aKey
    ^super at: aKey ifAbsent: [
	proxy at: aKey ]!

at: aKey ifAbsent: aBlock
    ^super at: aKey ifAbsent: [
	proxy at: aKey ifAbsent: aBlock ]!

at: aKey ifAbsentPut: aBlock
    ^super at: aKey ifAbsent: [
	proxy at: aKey ifAbsent: [
	    self at: aKey put: aBlock value ]]!

at: aKey ifPresent: aBlock
    | result |
    result := super at: aKey ifAbsent: [
	proxy at: aKey ifAbsent: [ ^nil ] ].
    ^aBlock value: result!

name
    "Answer the receiver's name"
    ^proxy name
!

printOn: aStream
    "Print a representation of the receiver on aStream"
    aStream nextPutAll: self classNameString , '[', proxy name, '] (' ; nl.
    self myKeysAndValuesDo:
    	[ :key :value | aStream tab;
		   print: key;
		   nextPutAll: '->';
		   print: value;
		   nl ].
    aStream nextPut: $)
!

do: aBlock
    super do: aBlock.
    proxy do: aBlock!

keysAndValuesDo: aBlock
    super keysAndValuesDo: aBlock.
    proxy keysAndValuesDo: aBlock!

myKeysAndValuesDo: aBlock
    super keysAndValuesDo: aBlock!

associationsDo: aBlock
    super associationsDo: aBlock.
    proxy associationsDo: aBlock!

keysDo: aBlock
    super keysDo: aBlock.
    proxy keysDo: aBlock!

includesKey: aKey
    ^(super includesKey: aKey) or: [
	proxy includesKey: aKey ]! !

Namespace current: STInST!
PK
     �Mh@�)���  �            ��    SqueakParser.stUT eqXOux �  �  PK
     �Mh@Ӊ��                ��3  NewSyntaxExporter.stUT eqXOux �  �  PK
     �Mh@c��.h  h            ���/  PoolResolutionTests.stUT eqXOux �  �  PK
     �Mh@��	�~*  ~*            ��9I  STFileParser.stUT eqXOux �  �  PK
     �Mh@�A���  �            �� t  Exporter.stUT eqXOux �  �  PK
     �Mh@ /8 #   #            ���  RewriteTests.stUT eqXOux �  �  PK
     �Mh@C�s"�  �            ��`�  SqueakExporter.stUT eqXOux �  �  PK
     �[h@�A�.�  �            ����  package.xmlUT I�XOux �  �  PK
     �Mh@ٝ�[�  �            ����  STCompLit.stUT eqXOux �  �  PK
     �Mh@�!^�  �            ����  OldSyntaxExporter.stUT eqXOux �  �  PK
     �Mh@,�B2:A  :A            ����  STSymTable.stUT eqXOux �  �  PK
     �Mh@,�o              ��9" STEvaluationDriver.stUT eqXOux �  �  PK
     �Mh@�C�L��  ��            ���> STDecompiler.stUT eqXOux �  �  PK
     �Mh@�b��Z�  Z�            ��R� ParseTreeSearcher.stUT eqXOux �  �  PK
     �Mh@ǿATI(  I(            ���d OrderedSet.stUT eqXOux �  �  PK
     �Mh@EA��`5  `5            ���� GSTParser.stUT eqXOux �  �  PK
     �Mh@>�h<  <            ��0� Extensions.stUT eqXOux �  �  PK
     �Mh@l2�:  �:            ���� RBFormatter.stUT eqXOux �  �  PK    �Mh@4�v5#  w�  	         ��� ChangeLogUT eqXOux �  �  PK
     �Mh@����Sp  Sp            ��D3 STCompiler.stUT eqXOux �  �  PK
     �Mh@�!}�              ��ޣ SIFParser.stUT eqXOux �  �  PK
     �Mh@x�Q06�  6�            ��%� RBParser.stUT eqXOux �  �  PK
     �Mh@�kFp�+  �+            ���V STLoader.stUT eqXOux �  �  PK
     �Mh@h�{D�, �,           ��z� RBParseNodes.stUT eqXOux �  �  PK
     �Mh@���C�  �  
          ���� RBToken.stUT eqXOux �  �  PK
     �Mh@%��              ���� STLoaderObjs.stUT eqXOux �  �  PK      �  5F   