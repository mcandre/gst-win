PK
     �Mh@E����  �    Core.stUT	 dqXO�XOux �  �  "=====================================================================
|
|   ROE core
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) Avi Bryant
|
| Permission is hereby granted, free of charge, to any person
| obtaining a copy of this software and associated documentation
| files (the `Software'), to deal in the Software without
| restriction, including without limitation the rights to use,
| copy, modify, merge, publish, distribute, sublicense, and/or sell
| copies of the Software, and to permit persons to whom the
| Software is furnished to do so, subject to the following
| conditions:
| 
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
| 
| THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
| OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
| NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
| HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
| WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
| FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
| OTHER DEALINGS IN THE SOFTWARE.
|
 ======================================================================"

Collection subclass: RAMappedCollection [
    | relation |
    
    <category: 'Roe-Mapping'>
    <comment: nil>

    RAMappedCollection class >> on: aRelation [
	^self new initializeWithRelation: aRelation
    ]

    do: aBlock [
	relation do: [:tuple | aBlock value: (self objectsForTuple: tuple)]
    ]

    initializeWithRelation: aRelation [
	relation := aRelation
    ]

    objectForTuple: anArray relation: aRelation attributes: attributeCollection [
	^aRelation objectForValues: (self valuesForTuple: anArray
		    attributes: attributeCollection)
    ]

    objectsForTuple: anArray [
	^relation attributesGroupedByOriginalRelation collect: 
		[:relationToAttributes | 
		self 
		    objectForTuple: anArray
		    relation: relationToAttributes key
		    attributes: relationToAttributes value]
    ]

    valueForAttribute: anAttribute fromTuple: anArray [
	^anArray at: (relation attributes indexOf: anAttribute)
    ]

    valuesForTuple: aTuple attributes: attributeCollection [
	^Dictionary from: (attributeCollection 
		    collect: [:attr | attr -> (aTuple valueForAttribute: attr)])
    ]
]



RAMappedCollection subclass: RASingleMappedCollection [
    
    <category: 'Roe-Mapping'>
    <comment: nil>

    do: aBlock [
	super do: [:ea | aBlock value: ea first]
    ]
]



Collection subclass: RARelation [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    isMutable [
        <category: 'testing'>
	^true
    ]
    
    * aRelation [
	<category: 'core operators'>
	^RACartesianProduct of: self with: aRelation
    ]

    , aRelation [
	<category: 'core operators'>
	^self union: aRelation
    ]

    - aRelation [
	<category: 'core operators'>
	^self difference: aRelation
    ]

    = other [
	"pretty hackish"

	<category: 'comparing'>
	^self printString = other printString
    ]

    >> aSymbol [
	<category: 'convenience'>
	^self attributeNamed: aSymbol
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitRelation: self
    ]

    asAlgebraicString [
	<category: 'converting'>
	^String 
	    streamContents: [:stream | (RAAlgebraicPrinter on: stream for: self) visit: self]
    ]

    asArray [
	<category: 'converting'>
	^((OrderedCollection new)
	    addAll: self;
	    yourself) asArray
    ]

    asMappedCollection [
	<category: 'converting'>
	^RAMappedCollection on: self
    ]

    asSingleMappedCollection [
	<category: 'converting'>
	^RASingleMappedCollection on: self
    ]

    attributeNamed: aString [
	<category: 'accessing'>
	^self attributeNamed: aString
	    ifAbsent: [self couldNotFindAttributeError: aString]
    ]

    attributeNamed: aString ifAbsent: errorBlock [
	<category: 'accessing'>
	| attribute |
	attribute := nil.
	self attributes do: 
		[:ea | 
		ea name asString = aString asString 
		    ifTrue: 
			[attribute ifNil: [attribute := ea]
			    ifNotNil: [:foo | RAAttribute ambiguousAttributeError: aString]]].
	^attribute ifNotNil: [:foo | attribute] ifNil: errorBlock
    ]

    attributes [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    attributesGroupedByOriginalRelation [
	<category: 'accessing'>
	^Array with: self -> self attributes
    ]

    clone [
	<category: 'core operators'>
	^RAClone of: self
    ]

    concreteRelation [
	<category: 'private'>
	self subclassResponsibility
    ]

    copyFrom: start to: stop [
	<category: 'core operators'>
	^self from: start to: stop
    ]

    couldNotFindAttributeError: aString [
	<category: 'private'>
	self error: 'Could not find attribute named ' , aString printString
    ]

    delete [
	<category: 'removing'>
	self concreteRelation deleteFor: self
    ]

    difference: aRelation [
	<category: 'core operators'>
	^RADifference of: self with: aRelation
    ]

    distinct [
	<category: 'core operators'>
	^RADistinct source: self
    ]

    do: aBlock [
	<category: 'enumerating'>
	self concreteRelation for: self do: aBlock
    ]

    from: start to: stop [
	<category: 'core operators'>
	^RARange 
	    of: self
	    from: start
	    to: stop
    ]

    groupBy: aString [
	<category: 'core operators'>
	^self groupByAll: (Array with: aString)
    ]

    groupByAll: attributeNames [
	<category: 'core operators'>
	^RAGrouping of: self by: attributeNames
    ]

    hash [
	<category: 'comparing'>
	^self printString hash
    ]

    indexBy: attributeName [
	<category: 'core operators'>
	^RAIndexWrapper on: self key: attributeName
    ]

    intersection: aRelation [
	<category: 'core operators'>
	^RAIntersection of: self with: aRelation
    ]

    keyBy: attributeName [
	<category: 'core operators'>
	^RAIndexWrapper on: self uniqueKey: attributeName
    ]

    orderBy: aString [
	<category: 'core operators'>
	^self orderByAll: (Array with: aString)
    ]

    orderBy: aString ascending: aBoolean [
	<category: 'core operators'>
	^self orderByAll: (Array with: aString) ascending: (Array with: aBoolean)
    ]

    orderByAll: attributeNames [
	<category: 'core operators'>
	| ascending |
	ascending := Array new: attributeNames size withAll: true.
	^self orderByAll: attributeNames ascending: ascending
    ]

    orderByAll: attributeNames ascending: booleanArray [
	<category: 'core operators'>
	^RAOrdering 
	    of: self
	    order: attributeNames
	    ascending: booleanArray
    ]

    project: aString [
	<category: 'core operators'>
	^self projectAll: (Array with: aString)
    ]

    projectAll: attributeNames [
	<category: 'core operators'>
	^RAProjection of: self into: attributeNames
    ]

    rename: oldName to: newName [
	<category: 'core operators'>
	^self renameAll: (Array with: oldName) to: (Array with: newName)
    ]

    renameAll: oldNameArray to: newNameArray [
	<category: 'core operators'>
	^RAAlias 
	    of: self
	    from: oldNameArray
	    to: newNameArray
    ]

    select: aBlock [
	<category: 'core operators'>
	^RASelection from: self where: aBlock
    ]

    species [
	<category: 'private'>
	^OrderedCollection
    ]

    union: aRelation [
	<category: 'core operators'>
	^RAUnion of: self with: aRelation
    ]

    update: aBlock [
	<category: 'updating'>
	self concreteRelation for: self update: aBlock
    ]

    where: attributeName equals: anObject [
	<category: 'convenience'>
	| attr |
	attr := self attributeNamed: attributeName.
	^self 
	    select: [:ea | (ea valueForAttribute: attr) = anObject]
    ]

    whereEqual: attributePair [
	<category: 'convenience'>
	^self select: 
		[:ea | 
		(ea valueForAttributeNamed: attributePair first) 
		    = (ea valueForAttributeNamed: attributePair last)]
    ]

    print: anObject on: aStream [
	<category: 'printing'>
	anObject printOn: aStream
    ]
]



RARelation subclass: RABinaryTransformation [
    | left right |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RABinaryTransformation class >> of: leftRelation with: rightRelation [
	^self new setLeftRelation: leftRelation rightRelation: rightRelation
    ]

    attributesGroupedByOriginalRelation [
	<category: 'accessing'>
	^left attributesGroupedByOriginalRelation 
	    , right attributesGroupedByOriginalRelation
    ]

    concreteRelation [
	<category: 'private'>
	^left concreteRelation
    ]

    isMutable [
	<category: 'testing'>
	^left isMutable and: [ right isMutable ]
    ]

    left [
	<category: 'accessing'>
	^left
    ]

    printOn: aStream [
	<category: 'printing'>
	(RAAlgebraicPrinter on: aStream) visit: self
    ]

    right [
	<category: 'accessing'>
	^right
    ]

    setLeftRelation: leftRelation rightRelation: rightRelation [
	<category: 'initialization'>
	left := leftRelation.
	right := rightRelation
    ]
]



RABinaryTransformation subclass: RACartesianProduct [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    isMutable [
        <category: 'testing'>
	^false
    ]
    
    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitCartesianProduct: self
    ]

    attributes [
	<category: 'accessing'>
	^left attributes , right attributes
    ]
]



RABinaryTransformation subclass: RADifference [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitDifference: self
    ]

    attributes [
	<category: 'accessing'>
	^left attributes
    ]
]



RABinaryTransformation subclass: RAIntersection [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitIntersection: self
    ]

    attributes [
	<category: 'accessing'>
	^left attributes
    ]
]



RABinaryTransformation subclass: RAUnion [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitUnion: self
    ]

    attributes [
	<category: 'accessing'>
	^left attributes
    ]
]



RARelation subclass: RAConcreteRelation [
    | name attributes |
    
    <category: 'Roe-Relations-Concrete'>
    <comment: nil>

    RAConcreteRelation class >> factory: aFactory name: aString [
	<category: 'instance creation'>
	^(self new)
	    factory: aFactory;
	    name: aString;
	    yourself
    ]

    addAllValues: anArray [
	<category: 'adding'>
	anArray do: [:row | self addValues: row]
    ]

    addValues: anArray [
	<category: 'adding'>
	self subclassResponsibility
    ]

    attributes [
	<category: 'accessing'>
	^attributes
    ]

    concreteRelation [
	<category: 'private'>
	^self
    ]

    for: aRelation do: aBlock [
	<category: 'private'>
	self subclassResponsibility
    ]

    for: aRelation update: aBlock [
	<category: 'updating'>
	self subclassResponsibility
    ]

    initializeWithName: aString [
	<category: 'initializing'>
	name := aString
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPut: $(;
	    nextPutAll: self name;
	    nextPut: $)
    ]
]



RARelation subclass: RAIndexedRelation [
    
    <category: 'Roe-Relations-Indexed'>
    <comment: nil>

    at: anObject [
	| relation |
	relation := self where: self keyName equals: anObject.
	self keyIsUnique 
	    ifFalse: [^relation]
	    ifTrue: [relation do: [:tuple | ^tuple]].
	self error: 'No value for key ' , anObject printString
    ]

    keyAttribute [
	^self attributeNamed: self keyName
    ]

    keyIsUnique [
	self subclassResponsibility
    ]

    keyName [
	self subclassResponsibility
    ]
]



RAIndexedRelation subclass: RAIndexWrapper [
    | source key unique |
    
    <category: 'Roe-Relations-Indexed'>
    <comment: nil>

    RAIndexWrapper class >> on: aRelation key: anAttribute [
	^self new 
	    setRelation: aRelation
	    key: anAttribute
	    unique: false
    ]

    RAIndexWrapper class >> on: aRelation uniqueKey: anAttribute [
	^self new 
	    setRelation: aRelation
	    key: anAttribute
	    unique: true
    ]

    acceptRoeVisitor: aVisitor [
	^aVisitor visitTransformation: self
    ]

    attributes [
	^source attributes
    ]

    concreteRelation [
	^source concreteRelation
    ]

    keyIsUnique [
	^unique
    ]

    keyName [
	^key
    ]

    isMutable [
	<category: 'testing'>
	^source isMutable
    ]

    printOn: aStream [
	source printOn: aStream
    ]

    setRelation: aRelation key: aString unique: aBoolean [
	source := aRelation.
	key := aString.
	unique := aBoolean
    ]

    source [
	^source
    ]
]



RARelation subclass: RATransformation [
    | source |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitTransformation: self
    ]

    attributes [
	<category: 'accessing'>
	^source attributes
    ]

    attributesGroupedByOriginalRelation [
	<category: 'accessing'>
	^source attributesGroupedByOriginalRelation
    ]

    concreteRelation [
	<category: 'private'>
	^source concreteRelation
    ]

    isMutable [
	<category: 'testing'>
	^source isMutable
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self asAlgebraicString
    ]

    source [
	<category: 'accessing'>
	^source
    ]
]



RATransformation subclass: RAAlias [
    | attributes |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RAAlias class >> of: aRelation from: attributeRefs to: nameArray [
	^self new 
	    setRelation: aRelation
	    attributes: attributeRefs
	    newNames: nameArray
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitAlias: self
    ]

    attributes [
	<category: 'accessing'>
	^attributes
    ]

    attributesGroupedByOriginalRelation [
	<category: 'accessing'>
	^source attributesGroupedByOriginalRelation collect: 
		[:assoc | 
		assoc key 
		    -> (assoc value collect: 
				[:attr | 
				attributes 
				    detect: [:ea | (ea respondsTo: #source) and: [ea source = attr]]
				    ifNone: [attr]])]
    ]

    setRelation: aRelation attributes: attributeRefs newNames: newNames [
	<category: 'initializing'>
	source := aRelation.
	attributes := source attributes copy.
	attributeRefs with: newNames
	    do: 
		[:ref :new | 
		| attr |
		attr := ref resolveAttributeIn: attributes.
		attributes replaceAll: attr
		    with: (RAAliasedAttribute attribute: attr name: new)]
    ]
]



RATransformation subclass: RAClone [
    | attributes |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RAClone class >> of: aRelation [
	^self basicNew setRelation: aRelation
    ]

    acceptRoeVisitor: aVisitor [
	^aVisitor visitClone: self
    ]

    attributes [
	^attributes
    ]

    setRelation: aRelation [
	source := aRelation.
	attributes := source attributes 
		    collect: [:ea | RAClonedAttribute attribute: ea]
    ]
]



RATransformation subclass: RADistinct [
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RADistinct class >> source: aRelation [
	^self basicNew setSource: aRelation
    ]

    isMutable [
        <category: 'testing'>
	^false
    ]
    
    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitDistinct: self
    ]

    setSource: aRelation [
	<category: 'visiting'>
	source := aRelation
    ]
]



RATransformation subclass: RAGrouping [
    | group |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RAGrouping class >> of: aSource by: attributeRefs [
	<category: 'instance creation'>
	^self basicNew setSource: aSource groupAttributes: attributeRefs
    ]

    isMutable [
        <category: 'testing'>
	^false
    ]
    
    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitGroup: self
    ]

    group [
	<category: 'accessing'>
	^group
    ]

    setSource: aRelation groupAttributes: attributeRefs [
	<category: 'initializing'>
	source := aRelation.
	group := attributeRefs 
		    collect: [:ea | ea resolveAttributeIn: source attributes]
    ]
]



RATransformation subclass: RAOrdering [
    | order ascending |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RAOrdering class >> of: aRelation order: attributeRefs ascending: booleanArray [
	<category: 'instance creation'>
	^self basicNew 
	    setSource: aRelation
	    orderAttributes: attributeRefs
	    ascending: booleanArray
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitOrder: self
    ]

    ascending [
	<category: 'accessing'>
	^ascending
    ]

    order [
	<category: 'accessing'>
	^order
    ]

    setSource: aRelation orderAttributes: attributeRefs ascending: booleanArray [
	<category: 'initialization'>
	source := aRelation.
	order := attributeRefs 
		    collect: [:ea | ea resolveAttributeIn: source attributes].
	ascending := booleanArray
    ]
]



RATransformation subclass: RAProjection [
    | attributes |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RAProjection class >> of: aRelation into: attributeRefs [
	^self new setRelation: aRelation attributes: attributeRefs
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitProjection: self
    ]

    attributes [
	<category: 'visiting'>
	^attributes
    ]

    attributesGroupedByOriginalRelation [
	<category: 'accessing'>
	^source attributesGroupedByOriginalRelation 
	    collect: [:assoc | assoc key -> (assoc value select: [:ea | attributes includes: ea])]
	    thenSelect: [:assoc | assoc value isEmpty not]
    ]

    setRelation: aRelation attributes: attributeRefs [
	<category: 'initializing'>
	source := aRelation.
	attributes := attributeRefs 
		    collect: [:ea | ea resolveAttributeIn: source attributes]
    ]
]



RATransformation subclass: RARange [
    | offset limit |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RARange class >> of: aSource from: min to: max [
	<category: 'instance creation'>
	^self basicNew setSource: aSource from: min to: max
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitInterval: self
    ]

    limit [
	<category: 'accessing-interval'>
	^limit
    ]

    offset [
	<category: 'accessing-interval'>
	^offset
    ]

    setSource: aRelation from: start to: stop [
	<category: 'initializing'>
	source := aRelation.
	offset := start - 1.
        limit := stop - start + 1
    ]

    start [
	<category: 'accessing-interval'>
	^offset + 1
    ]

    stop [
	<category: 'accessing-interval'>
	^offset + limit
    ]
]



RATransformation subclass: RASelection [
    | condition |
    
    <category: 'Roe-Relations-Core'>
    <comment: nil>

    RASelection class >> from: aRelation where: aBlock [
	^self new setRelation: aRelation condition: aBlock
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitSelection: self
    ]

    evaluateTuple: anArray [
	<category: 'evaluating'>
	^condition value: anArray
    ]

    setRelation: aRelation condition: aBlock [
	<category: 'initializing'>
	source := aRelation.
	condition := aBlock
    ]
]




DateTime extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitDateAndTime: self
    ]

]



Object extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitObject: self
    ]

]



Object subclass: RAAttribute [
    
    <category: 'Roe-Attributes'>
    <comment: nil>

    RAAttribute class >> errorCouldNotResolveAttribute [
	<category: 'private'>
	self error: 'could not resolve attribute'
    ]

    RAAttribute class >> ambiguousAttributeError: aString [
	<category: 'private'>
	self error: 'More than one attribute named ' , aString printString
    ]

    name [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    originalAttribute [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    originalRelation [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream nextPutAll: '(' , self name , ')'
    ]

    resolveAttributeIn: aCollection [
	<category: 'resolving'>
	self subclassResponsibility
    ]
]



RAAttribute subclass: RAAliasedAttribute [
    | source name |
    
    <category: 'Roe-Attributes'>
    <comment: nil>

    RAAliasedAttribute class >> attribute: anAttribute name: aString [
	<category: 'instance creation'>
	^self new setAttribute: anAttribute name: aString
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    originalAttribute [
	<category: 'accessing'>
	^source originalAttribute
    ]

    originalRelation [
	<category: 'accessing'>
	^source originalRelation
    ]

    resolveAttributeIn: aCollection [
	<category: 'resolving'>
	| attribute |
	aCollection do: 
		[:ea | 
		self = ea
		    ifTrue: 
			[attribute ifNil: [attribute := self]
			    ifNotNil: [:foo | RAAttribute ambiguousAttributeError: self name]]].
	attribute isNil ifFalse: [^attribute].
	RAAttribute errorCouldNotResolveAttribute
    ]

    setAttribute: anAttribute name: aString [
	<category: 'private'>
	source := anAttribute.
	name := aString asString
    ]

    source [
	<category: 'accessing'>
	^source
    ]
]



RAAttribute subclass: RAClonedAttribute [
    | source |
    
    <category: 'Roe-Attributes'>
    <comment: nil>

    RAClonedAttribute class >> attribute: anAttribute [
	^self new setAttribute: anAttribute
    ]

    name [
	^source name
    ]

    originalAttribute [
	^source originalAttribute
    ]

    originalRelation [
	^source originalRelation
    ]

    resolveAttributeIn: aCollection [
	<category: 'resolving'>
	| attribute |
	aCollection do: 
		[:ea | 
		self = ea
		    ifTrue: 
			[attribute ifNil: [attribute := self]
			    ifNotNil: [:foo | RAAttribute ambiguousAttributeError: self name]]].
	attribute isNil ifFalse: [^attribute].
	RAAttribute errorCouldNotResolveAttribute
    ]

    setAttribute: anAttribute [
	source := anAttribute
    ]
]



RAAttribute subclass: RASimpleAttribute [
    | relation name |
    
    <category: 'Roe-Attributes'>
    <comment: nil>

    RASimpleAttribute class >> named: aString relation: aRelation [
	<category: 'instance creation'>
	^self new setName: aString relation: aRelation
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    originalAttribute [
	<category: 'accessing'>
	^self
    ]

    originalRelation [
	<category: 'accessing'>
	^relation
    ]

    resolveAttributeIn: aCollection [
	<category: 'resolving'>
	| attribute |
	aCollection do: 
		[:ea | 
		self = ea
		    ifTrue: 
			[attribute ifNil: [attribute := self]
			    ifNotNil: [:foo | RAAttribute ambiguousAttributeError: self name]]].
	attribute isNil ifFalse: [^attribute].
	RAAttribute errorCouldNotResolveAttribute
    ]

    setName: aString relation: aRelation [
	<category: 'private'>
	name := aString asString.
	relation := aRelation
    ]
]



Object subclass: RAConditionNode [
    
    <category: 'Roe-Conditions'>
    <comment: nil>

    & other [
	<category: 'logical'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #&
    ]

    * other [
	<category: 'arithmetic'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #*
    ]

    + other [
	<category: 'arithmetic'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #+
    ]

    - other [
	<category: 'arithmetic'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #-
    ]

    / other [
	<category: 'arithmetic'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #/
    ]

    < other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #<
    ]

    <= other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #<=
    ]

    = other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #=
    ]

    > other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #>
    ]

    >= other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #>=
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	self subclassResponsibility
    ]

    asString [
	<category: 'converting'>
	^self
    ]

    like: aString [
	<category: 'comparing'>
	^self like: aString ignoreCase: false
    ]

    like: aString ignoreCase: aBoolean [
	<category: 'comparing'>
	^aBoolean 
	    ifFalse: 
		[RABinaryNode 
		    left: self
		    right: aString
		    operator: #like]
	    ifTrue: 
		[RABinaryNode 
		    left: self
		    right: aString
		    operator: #ilike]
    ]

    | other [
	<category: 'logical'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #|
    ]

    ~= other [
	<category: 'comparing'>
	^RABinaryNode 
	    left: self
	    right: other
	    operator: #~=
    ]
]



RAConditionNode subclass: RAAttributeNode [
    | attribute |
    
    <category: 'Roe-Conditions'>
    <comment: nil>

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitAttributeNode: self
    ]

    attribute [
	<category: 'private'>
	^attribute
    ]

    attribute: anAttribute [
	<category: 'private'>
	attribute := anAttribute
    ]

    name [
	<category: 'accessing'>
	^attribute name
    ]
]



RAConditionNode subclass: RABinaryNode [
    | left right operator |
    
    <category: 'Roe-Conditions'>
    <comment: nil>

    RABinaryNode class >> left: leftNode right: rightNode operator: aSymbol [
	^self new 
	    setLeft: leftNode
	    right: rightNode
	    operator: aSymbol
    ]

    acceptRoeVisitor: aVisitor [
	<category: 'visiting'>
	^aVisitor visitBinaryNode: self
    ]

    left [
	<category: 'accessing'>
	^left
    ]

    operator [
	<category: 'accessing'>
	^operator
    ]

    right [
	<category: 'accessing'>
	^right
    ]

    setLeft: aNode right: otherNode operator: aSymbol [
	<category: 'private'>
	left := aNode.
	right := otherNode.
	operator := aSymbol
    ]

    sqlOperator [
	<category: 'accessing'>
	right isNil 
	    ifTrue: 
		[operator = #= ifTrue: [^' IS '].
		operator = #~= ifTrue: [^' IS NOT ']].
	operator = #& ifTrue: [^' AND '].
	operator = #| ifTrue: [^' OR '].
	operator = #~= ifTrue: [^' != '].
	operator = #like ifTrue: [^' LIKE '].
	operator = #ilike ifTrue: [^' ILIKE '].
	^operator
    ]
]



Object subclass: RATuple [
    | relation |
    
    <category: 'Roe-Tuples'>
    <comment: nil>

    RATuple class >> relation: aRelation [
	^self basicNew initializeWithRelation: aRelation
    ]

    at: anObject [
	^self 
	    valueForAttribute: (anObject resolveAttributeIn: relation attributes)
    ]

    doesNotUnderstand: aMessage [
	| selector |
	selector := aMessage selector.
	(selector numArgs = 0 and: [self hasAttributeNamed: selector asString]) 
	    ifTrue: [^self valueForAttributeNamed: selector].
	((selector numArgs = 1 and: [self hasAttributeNamed: selector allButLast]) 
	    and: [self isMutable]) 
		ifTrue: 
		    [^self takeValue: aMessage argument forAttributeNamed: selector allButLast].
	^super doesNotUnderstand: aMessage
    ]

    hasAttributeNamed: aString [
	| s |
	s := aString asString.
	^relation attributes anySatisfy: [:ea | ea name = s]
    ]

    initializeWithRelation: aRelation [
	relation := aRelation
    ]

    isMutable [
	^false
    ]

    name [
	^self valueForAttributeNamed: #name ifAbsent: [super name]
    ]

    takeValue: anObject forAttribute: anAttribute [
	self isMutable 
	    ifTrue: [self subclassResponsibility]
	    ifFalse: [self shouldNotImplement]
    ]

    takeValue: anObject forAttributeNamed: aString [
	self takeValue: anObject forAttribute: (relation attributeNamed: aString)
    ]

    valueForAttribute: anAttribute [
	^self subclassResponsibility
    ]

    valueForAttributeNamed: aString [
	^self valueForAttribute: (relation attributeNamed: aString)
    ]

    valueForAttributeNamed: aString ifAbsent: errorBlock [
	^self valueForAttribute: (relation attributeNamed: aString
		    ifAbsent: [^errorBlock value])
    ]
]



RATuple subclass: RASelectTuple [
    
    <category: 'Roe-Tuples'>
    <comment: nil>

    valueForAttribute: anAttribute [
	^RAAttributeNode new attribute: anAttribute
    ]
]



RATuple subclass: RASimpleTuple [
    | values |
    
    <category: 'Roe-Tuples'>
    <comment: nil>

    RASimpleTuple class >> relation: aRelation values: anArray [
	^self basicNew initializeWithRelation: aRelation values: anArray
    ]

    initializeWithRelation: aRelation [
	<category: 'initializing'>
	self initializeWithRelation: aRelation
	    values: (Array new: aRelation attributes size)
    ]

    initializeWithRelation: aRelation values: anArray [
	<category: 'initializing'>
	super initializeWithRelation: aRelation.
	values := anArray
    ]

    valueForAttribute: anAttribute [
	<category: 'accessing'>
	^values at: (relation attributes indexOf: anAttribute)
    ]

    values [
	<category: 'accessing'>
	^values
    ]
]



RATuple subclass: RAUpdateTuple [
    | nodes |
    
    <category: 'Roe-Tuples'>
    <comment: nil>

    isMutable [
	^true
    ]

    nodes [
	^nodes ifNil: [nodes := Dictionary new]
    ]

    takeValue: anObject forAttribute: anAttribute [
	self nodes at: anAttribute put: anObject
    ]

    valueForAttribute: anAttribute [
	^RAAttributeNode new attribute: anAttribute
    ]
]



Object subclass: RAVisitor [
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    visit: anObject [
	<category: 'visiting'>
	^anObject acceptRoeVisitor: self
    ]

    visitAlias: aRelation [
	<category: 'visiting'>
	^self visitTransformation: aRelation
    ]

    visitBoolean: aBoolean [
	<category: 'visiting-objects'>
	^self visitObject: aBoolean
    ]

    visitCartesianProduct: aRelation [
	<category: 'visiting'>
	
    ]

    visitClone: aClone [
	<category: 'visiting'>
	
    ]

    visitDate: aDate [
	<category: 'visiting-objects'>
	^self visitObject: aDate
    ]

    visitDateAndTime: aDateAndTime [
	<category: 'visiting-objects'>
	^self visitObject: aDateAndTime
    ]

    visitDecimal: aDecimal [
	<category: 'visiting-objects'>
	^self visitNumber: aDecimal
    ]

    visitDifference: aRelation [
	<category: 'visiting'>
	
    ]

    visitDistinct: aRelation [
	<category: 'visiting'>
	
    ]

    visitFloat: aFloat [
	<category: 'visiting-objects'>
	^self visitNumber: aFloat
    ]

    visitGroup: aRelation [
	<category: 'visiting'>
	
    ]

    visitInteger: anInteger [
	<category: 'visiting-objects'>
	^self visitNumber: anInteger
    ]

    visitIntersection: aRelation [
	<category: 'visiting'>
	
    ]

    visitInterval: aRelation [
	<category: 'visiting'>
	
    ]

    visitNumber: aNumber [
	<category: 'visiting-objects'>
	^self visitObject: aNumber
    ]

    visitObject: anObject [
	<category: 'visiting-objects'>
	
    ]

    visitOrder: aRelation [
	<category: 'visiting'>
	
    ]

    visitProjection: aRelation [
	<category: 'visiting'>
	
    ]

    visitRelation: aRelation [
	<category: 'visiting'>
	
    ]

    visitSelection: aRelation [
	<category: 'visiting'>
	
    ]

    visitString: aString [
	<category: 'visiting-objects'>
	^self visitObject: aString
    ]

    visitTime: aTime [
	<category: 'visiting-objects'>
	^self visitObject: aTime
    ]

    visitTransformation: aRelation [
	<category: 'visiting'>
	^self visit: aRelation source
    ]

    visitUndefinedObject: anUndefinedObject [
	<category: 'visiting-objects'>
	^self visitObject: anUndefinedObject
    ]

    visitUnion: aRelation [
	<category: 'visiting'>
	
    ]
]



RAVisitor subclass: RAPrinter [
    | stream relation |
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    RAPrinter class >> on: aStream for: aConcreteRelation [
	^self new stream: aStream relation: aConcreteRelation
    ]

    RAPrinter class >> print: aRelation for: aConcreteRelation [
	^String streamContents: [:s |
	    (self on: s for: aConcreteRelation) visit: aRelation]
    ]

    printOperator: aNode [
	<category: 'printing'>
	stream nextPutAll: aNode operator
    ]

    stream: aStream relation: aConcreteRelation [
	<category: 'accessing'>
	stream := aStream.
	relation := aConcreteRelation
    ]

    tupleFor: aRelation [
	<category: 'accessing'>
	^RASelectTuple relation: aRelation
    ]

    visitAttributeNode: aNode [
	<category: 'visiting'>
	stream nextPutAll: aNode name
    ]

    visitBinaryNode: aNode [
	<category: 'visiting'>
	stream nextPut: $(.
	self visit: aNode left.
	self printOperator: aNode.
	self visit: aNode right.
	stream nextPut: $)
    ]

    visitConditionNodesFor: aRelation [
	<category: 'visiting'>
	self visit: (aRelation evaluateTuple: (self tupleFor: aRelation))
    ]

    visitObject: anObject [
	<category: 'visiting'>
	relation print: anObject on: stream
    ]

    visitRelation: aRelation [
	<category: 'visiting'>
	aRelation printOn: stream
    ]
]



RAPrinter subclass: RAAlgebraicPrinter [
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    visitAlias: aRelation [
	| sourceAttributes attributes |
	stream nextPutAll: 'R['.
	sourceAttributes := aRelation source attributes.
	attributes := aRelation attributes.
	sourceAttributes with: attributes
	    do: 
		[:old :new | 
		old = new 
		    ifFalse: 
			[stream
			    nextPutAll: old name;
			    nextPutAll: '->';
			    nextPutAll: new name;
			    nextPutAll: ',']].
	(stream contents endsWith: ',') ifTrue: [stream skip: -1].
	stream nextPutAll: ']'.
	self visitTransformation: aRelation
    ]

    visitCartesianProduct: aRelation [
	self visit: aRelation left.
	stream nextPutAll: ' X '.
	self visit: aRelation right
    ]

    visitDifference: aRelation [
	self visit: aRelation left.
	stream nextPutAll: ' \ '.
	self visit: aRelation right
    ]

    visitDistinct: aRelation [
	stream nextPut: ${.
	self visit: aRelation source.
	stream nextPut: $}
    ]

    visitGroup: aRelation [
	stream nextPutAll: 'G['.
	aRelation group do: [:each | stream nextPutAll: each name]
	    separatedBy: [stream nextPut: $,].
	stream nextPut: $].
	self visitTransformation: aRelation
    ]

    visitIntersection: aRelation [
	self visit: aRelation left.
	stream nextPutAll: ' n '.
	self visit: aRelation right
    ]

    visitInterval: aRelation [
	stream nextPutAll: 'I['.
	stream print: aRelation start.
	stream nextPut: $,.
	stream print: aRelation stop.
	stream nextPut: $].
	self visitTransformation: aRelation
    ]

    visitOrder: aRelation [
	stream nextPutAll: 'O['.
	(1 to: aRelation order size) do: 
		[:index | 
		stream nextPutAll: (aRelation order at: index) name.
		(aRelation ascending at: index) 
		    ifTrue: [stream nextPutAll: '->asc']
		    ifFalse: [stream nextPutAll: '->desc']]
	    separatedBy: [stream nextPut: $,].
	stream nextPut: $].
	self visitTransformation: aRelation
    ]

    visitProjection: aRelation [
	stream nextPutAll: 'P['.
	aRelation attributes do: [:each | stream nextPutAll: each name]
	    separatedBy: [stream nextPut: $,].
	stream nextPutAll: ']'.
	self visitTransformation: aRelation
    ]

    visitRelation: aRelation [
	stream nextPutAll: aRelation name
    ]

    visitSelection: aRelation [
	stream nextPutAll: 'S['.
	self visitConditionNodesFor: aRelation.
	stream nextPut: $].
	self visitTransformation: aRelation
    ]

    visitTransformation: aRelation [
	stream nextPut: $(.
	super visitTransformation: aRelation.
	stream nextPut: $)
    ]

    visitUnion: aRelation [
	self visit: aRelation left.
	stream nextPutAll: ' u '.
	self visit: aRelation right
    ]
]



UndefinedObject extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitUndefinedObject: self
    ]

]



Date extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitDate: self
    ]

]



Number extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitNumber: self
    ]

]



Boolean extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitBoolean: self
    ]

]



Integer extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitInteger: self
    ]

]



Time extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitTime: self
    ]

]



ScaledDecimal extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitDecimal: self
    ]

]



Float extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitFloat: self
    ]

]



String extend [

    acceptRoeVisitor: aVisitor [
	<category: '*Roe'>
	^aVisitor visitString: self
    ]

    resolveAttributeIn: aCollection [
	| attribute string |
	string := self asString asUppercase.
	aCollection do: 
		[:ea | 
		string = ea name asString asUppercase
		    ifTrue: 
			[attribute ifNil: [attribute := ea]
			    ifNotNil: [:foo | RAAttribute ambiguousAttributeError: self]]].
	attribute isNil ifFalse: [^attribute].
	RAAttribute errorCouldNotResolveAttribute
    ]

]



PK
     �[h@+d�4�  �    package.xmlUT	 �XO�XOux �  �  <package>
  <name>ROE</name>
  <namespace>ROE</namespace>
  <test>
    <namespace>ROE</namespace>
    <prereq>DBD-SQLite</prereq>
    <prereq>ROE</prereq>
    <prereq>SUnit</prereq>
    <sunit>ROE.RATestMapping ROE.RATestEvaluatorSemantics ROE.RATestSyntax 
	ROE.RATestSQLiteSemantics</sunit>
  
    <filein>Tests.st</filein>
    <filein>SQLiteTests.st</filein>
  </test>

  <filein>Extensions.st</filein>
  <filein>Core.st</filein>
  <filein>Array.st</filein>
  <filein>SQL.st</filein>
</package>PK
     �Mh@��/�s	  s	    SQLiteTests.stUT	 dqXO�XOux �  �  "=====================================================================
|
|   ROE - SQLite-based testing
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) Avi Bryant
|
| Permission is hereby granted, free of charge, to any person
| obtaining a copy of this software and associated documentation
| files (the `Software'), to deal in the Software without
| restriction, including without limitation the rights to use,
| copy, modify, merge, publish, distribute, sublicense, and/or sell
| copies of the Software, and to permit persons to whom the
| Software is furnished to do so, subject to the following
| conditions:
| 
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
| 
| THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
| OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
| NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
| HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
| WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
| FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
| OTHER DEALINGS IN THE SOFTWARE.
|
 ======================================================================"

RATestSemantics subclass: RATestSQLiteSemantics [
    | connection |
    
    <comment: nil>
    <category: 'Roe-Tests'>

    connection [
	<category: 'configuration'>
	^connection
    ]

    createRelation: aString attributes: anArray [
	<category: 'configuration'>
	^self connection >> aString
    ]

    setUp [
	<category: 'private'>
	connection := DBI.Connection connect: 'dbi:SQLite:dbname=test.dat'
	    user: nil password: nil.

	self connection
	    do: 'begin';
	    do: 'create table profs (facultyID integer, name text)';
	    do: 'create table students (studentNumber integer, name text)';
	    do: 'create table students2 (studentNumber integer, name text)';
	    do: 'create table courses (courseNumber integer, title text, prof integer)';
	    do: 'create table enrollment (student integer, course integer)'.
	    
	super setUp
    ]

    tearDown [
	<category: 'private'>
	self connection do: 'rollback'.
	self connection close.
	(File name: connection database) remove
    ]
]
PK
     �Mh@�%�  �    Extensions.stUT	 dqXO�XOux �  �  "=====================================================================
|
|   ROE extensions to the base classes
|
|
 ======================================================================"

"======================================================================
|
| This file is in the public domain.
|
 ======================================================================"

Collection extend [
    intersection: aCollection [
	| s |
	(self species == aCollection species
	     and: [ self size > aCollection size ])
		ifTrue: [ ^aCollection intersection: self ].

	s := aCollection asSet.
	^self select: [ :each | s includes: each ]
    ]
]
PK
     �Mh@��Q��R  �R    Tests.stUT	 dqXO�XOux �  �  "=====================================================================
|
|   ROE unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) Avi Bryant
|
| Permission is hereby granted, free of charge, to any person
| obtaining a copy of this software and associated documentation
| files (the `Software'), to deal in the Software without
| restriction, including without limitation the rights to use,
| copy, modify, merge, publish, distribute, sublicense, and/or sell
| copies of the Software, and to permit persons to whom the
| Software is furnished to do so, subject to the following
| conditions:
| 
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
| 
| THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
| OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
| NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
| HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
| WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
| FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
| OTHER DEALINGS IN THE SOFTWARE.
|
 ======================================================================"

RAArrayRelation subclass: RAMockRelation [
    | objectClass |
    
    <category: 'Roe-Tests'>
    <comment: nil>

    objectClass [
	^objectClass
    ]

    objectClass: aClass [
	objectClass := aClass
    ]

    objectForValues: aDictionary [
	| values |
	values := Dictionary new.
	aDictionary associationsDo: [:each | values at: each key name asSymbol put: each value].
	^self objectClass fromValues: values
    ]

    printOn: aStream [
	self attributes do: [:ea | aStream nextPutAll: ea name]
    ]
]


TestCase subclass: RATestMapping [
    | courses students |
    
    <comment: nil>
    <category: 'Roe-Tests'>

    setUp [
	<category: 'running'>
	courses := RAMockRelation name: 'courses' attributes: #(#id #title).
	students := RAMockRelation name: 'students' attributes: #(#name #courseID).
	courses addAllValues: #(#(1 'Discrete Math') #(2 'Databases')).
	students addAllValues: #(#('Avi' 2) #('Ken' 2)).
	courses objectClass: RAMockCourse.
	students objectClass: RAMockStudent
    ]

    studentsForCourseID: courseID [
	<category: 'private'>
	^students * (courses where: #id equals: courseID) 
	    whereEqual: #(#id #courseID)
    ]

    testObjectInstantiation [
	<category: 'testing'>
	| mappedStudents |
	mappedStudents := (self studentsForCourseID: 2) asMappedCollection.
	self assert: mappedStudents size = 2.
	self assert: mappedStudents anyOne first class = RAMockStudent.
	self assert: mappedStudents anyOne second class = RAMockCourse
    ]

    testSelfJoins [
	<category: 'testing'>
	| mapping tuple |
	mapping := (students * students * courses * students * courses) 
		    asMappedCollection.
	tuple := mapping anyOne.
	self assert: (tuple collect: [:ea | ea class name]) 
		    = #(#RAMockStudent #RAMockStudent #RAMockCourse #RAMockStudent #RAMockCourse)
    ]

    testSingleObjectInstantiation [
	<category: 'testing'>
	| mappedStudents |
	mappedStudents := students asSingleMappedCollection.
	self assert: mappedStudents size = 2.
	self assert: mappedStudents anyOne class = RAMockStudent
    ]
]



TestCase subclass: RATestSemantics [
    | students students2 courses profs enrollment |
    
    <comment: nil>
    <category: 'Roe-Tests'>

    addAllValues: anArray to: aRelation [
	<category: 'private'>
	aRelation addAllValues: anArray
    ]

    assertQueryOrdered: aRelation gives: anArray [
	<category: 'private'>
	self 
	    assert: (aRelation collect: [:ea | ea values asArray]) asArray = anArray
    ]

    assertQueryUnordered: aRelation gives: anArray [
	<category: 'private'>
	self assert: (aRelation collect: [:ea | ea values asArray]) asSet 
		    = anArray asSet
    ]

    assertTuple: aTuple is: anArray [
	<category: 'private'>
	self assert: aTuple values asArray = anArray
    ]

    createRelation: aString attributes: anArray [
	<category: 'private'>
	self subclassResponsibility
    ]

    selectCourseNumbersForProf: aString [
	<category: 'private'>
	^((profs * courses whereEqual: #(#facultyID #prof)) where: #name
	    equals: aString) project: #courseNumber
    ]

    selectCourseTitlesForStudent: aString [
	<category: 'private'>
	^((students select: [:ea | ea name = aString]) * enrollment * courses 
	    select: [:ea | ea student = ea studentNumber & (ea course = ea courseNumber)]) 
		project: #title
    ]

    setUp [
	<category: 'running'>
	profs := self createRelation: 'profs' attributes: #(#facultyID #name).
	self 
	    addAllValues: #(#(1 'Murphy') #(2 'Cavers') #(3 'Tsiknis') #(4 'Bob'))
	    to: profs.
	students := self createRelation: 'students'
		    attributes: #(#studentNumber #name).
	self addAllValues: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob'))
	    to: students.
	students2 := self createRelation: 'students2'
		    attributes: #(#studentNumber #name).
	self addAllValues: #(#(1 'Avi') #(2 'Julian') #(5 'Lukas') #(6 'Adrian'))
	    to: students2.
	courses := self createRelation: 'courses'
		    attributes: #('courseNumber' 'title' 'prof').
	self 
	    addAllValues: #(#(310 'Software Engineering' 1) #(220 'Discrete Math' 2) #(128 'Scheme' 2) #(304 'Databases' 3))
	    to: courses.
	enrollment := self createRelation: 'enrollment'
		    attributes: #('student' 'course').
	self 
	    addAllValues: #(#(1 310) #(1 220) #(2 220) #(2 128) #(3 220) #(3 304) #(3 310))
	    to: enrollment
    ]

    testAllStudents [
	<category: 'testing'>
	self assertQueryOrdered: students
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob'))
    ]

    testBothStudentAndProf [
	<category: 'testing'>
	| profName studentName |
	profName := profs attributeNamed: #name.
	studentName := students attributeNamed: #name.
	self 
	    assertQueryOrdered: ((profs * students 
		    select: [:ea | (ea at: profName) = (ea at: studentName)]) project: profName)
	    gives: #(#('Bob'))
    ]

    testBothStudentAndProfOldStyle [
	<category: 'testing'>
	self 
	    assertQueryOrdered: (((profs rename: #name to: #profName) 
		    * (students rename: #name to: #studName) 
			select: [:ea | ea profName = ea studName]) project: #profName)
	    gives: #(#('Bob'))
    ]

    testDistinct [
	<category: 'testing'>
	| student |
	student := enrollment attributeNamed: #student.
	self assertQueryOrdered: ((enrollment project: student) distinct 
		    orderBy: student)
	    gives: #(#(1) #(2) #(3)).
	self assertQueryOrdered: ((enrollment project: #course) distinct 
		    orderBy: #course)
	    gives: #(#(128) #(220) #(304) #(310))
    ]

    testFindClassmates [
	<category: 'testing'>
	| classmates |
	classmates := enrollment clone.
	self 
	    assertQueryUnordered: ((enrollment * classmates select: 
			[:ea | 
			(ea at: enrollment >> #course) = (ea at: classmates >> #course) 
			    & ((ea at: enrollment >> #student) ~= (ea at: classmates >> #student))]) 
		    projectAll: (Array with: enrollment >> #student with: classmates >> #student))
	    gives: #(#(1 3) #(1 2) #(2 3) #(3 1) #(2 1) #(3 2))
    ]

    testFindClassmatesOldStyle [
	<category: 'testing'>
	self 
	    assertQueryUnordered: ((enrollment 
		    * (enrollment renameAll: #(#student #course) to: #(#classmate #course2)) 
			select: [:ea | ea course = ea course2 & (ea student ~= ea classmate)]) 
			projectAll: #(#student #classmate))
	    gives: #(#(1 3) #(1 2) #(2 3) #(3 1) #(2 1) #(3 2))
    ]

    testFindProfCourses [
	<category: 'testing'>
	self assertQueryUnordered: (self selectCourseNumbersForProf: 'Cavers')
	    gives: #(#(220) #(128))
    ]

    testFindStudentCourses [
	<category: 'testing'>
	self assertQueryUnordered: (self selectCourseTitlesForStudent: 'Andrew')
	    gives: #(#('Discrete Math') #('Databases') #('Software Engineering'))
    ]

    testIntervalStudents [
	<category: 'testing'>
	| relation |
	relation := students orderBy: #studentNumber ascending: true.
	self assertQueryOrdered: (relation from: 1 to: 0) gives: #().
	self assertQueryOrdered: (relation from: 1 to: 1) gives: #(#(1 'Avi')).
	self assertQueryOrdered: (relation from: 1 to: 4)
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob')).
	self assertQueryOrdered: (relation from: 2 to: 3)
	    gives: #(#(2 'Julian') #(3 'Andrew')).
	self assertQueryOrdered: (relation copyFrom: 2 to: 3)
	    gives: #(#(2 'Julian') #(3 'Andrew'))
    ]

    testOrderStudents [
	<category: 'testing'>
	self 
	    assertQueryOrdered: (students orderBy: #studentNumber ascending: true)
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob')).
	self 
	    assertQueryOrdered: (students orderBy: #studentNumber ascending: false)
	    gives: #(#(4 'Bob') #(3 'Andrew') #(2 'Julian') #(1 'Avi'))
    ]

    testSelectOneStudent [
	<category: 'testing'>
	self assertQueryOrdered: (students select: [:ea | ea name = 'Julian'])
	    gives: #(#(2 'Julian'))
    ]

    testSize [
	<category: 'testing'>
	self assert: students size = 4
    ]

    testStudentExcept [
	<category: 'testing'>
	self assertQueryUnordered: students - students2
	    gives: #(#(3 'Andrew') #(4 'Bob')).
	self assertQueryUnordered: (students difference: students2)
	    gives: #(#(3 'Andrew') #(4 'Bob')).
	self assertQueryUnordered: students2 - students
	    gives: #(#(5 'Lukas') #(6 'Adrian')).
	self assertQueryUnordered: (students2 difference: students)
	    gives: #(#(5 'Lukas') #(6 'Adrian'))
    ]

    testStudentIndex [
	<category: 'testing'>
	| idx |
	idx := students indexBy: #studentNumber.
	self assertQueryUnordered: (idx at: 1) gives: #(#(1 'Avi')).
	idx := students keyBy: #studentNumber.
	self assertTuple: (idx at: 1) is: #(1 'Avi')
    ]

    testStudentIntersect [
	<category: 'testing'>
	self assertQueryUnordered: (students intersection: students2)
	    gives: #(#(1 'Avi') #(2 'Julian')).
	self assertQueryUnordered: (students2 intersection: students)
	    gives: #(#(1 'Avi') #(2 'Julian'))
    ]

    testStudentNames [
	<category: 'testing'>
	self assertQueryOrdered: (students project: #name)
	    gives: #(#('Avi') #('Julian') #('Andrew') #('Bob'))
    ]

    testStudentUnion [
	<category: 'testing'>
	self assertQueryUnordered: students , students2
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob') #(5 'Lukas') #(6 'Adrian')).
	self assertQueryUnordered: (students union: students2)
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob') #(5 'Lukas') #(6 'Adrian')).
	self assertQueryUnordered: students2 , students
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob') #(5 'Lukas') #(6 'Adrian')).
	self assertQueryUnordered: (students2 union: students)
	    gives: #(#(1 'Avi') #(2 'Julian') #(3 'Andrew') #(4 'Bob') #(5 'Lukas') #(6 'Adrian'))
    ]

    testUpdateAlias [
	<category: 'testing'>
	(students rename: #studentNumber to: #sn) update: [:ea | ea sn: 1].
	self assertQueryUnordered: students
	    gives: #(#(1 'Avi') #(1 'Julian') #(1 'Andrew') #(1 'Bob'))
    ]

    testUpdateAliasWithColumn [
	<category: 'testing'>
	(students renameAll: #(#name #studentNumber) to: #(#cn #sn)) 
	    update: [:ea | ea cn: ea sn asString].
	self assertQueryUnordered: students
	    gives: #(#(1 '1') #(2 '2') #(3 '3') #(4 '4'))
    ]

    testUpdateJoin [
	<category: 'testing'>
	| join |
	join := students * profs.
	self should: [join update: [:ea | ea studentNumber: 17]] raise: Error
    ]

    testUpdateSimpleSelect [
	<category: 'testing'>
	(students select: [:ea | ea name = 'Julian']) 
	    update: [:ea | ea name: 'Fitzell'].
	self assertQueryUnordered: students
	    gives: #(#(1 'Avi') #(2 'Fitzell') #(3 'Andrew') #(4 'Bob'))
    ]

    testUpdateTableWithColumn [
	<category: 'testing'>
	students update: [:ea | ea name: ea studentNumber asString].
	self assertQueryUnordered: students
	    gives: #(#(1 '1') #(2 '2') #(3 '3') #(4 '4'))
    ]

    testUpdateTableWithLiteral [
	<category: 'testing'>
	students update: [:ea | ea name: 'Foo'].
	self assertQueryUnordered: students
	    gives: #(#(1 'Foo') #(2 'Foo') #(3 'Foo') #(4 'Foo'))
    ]
]



RATestSemantics subclass: RATestEvaluatorSemantics [
    
    <comment: nil>
    <category: 'Roe-Tests'>

    createRelation: aString attributes: anArray [
	<category: 'private'>
	^RAArrayRelation name: aString attributes: anArray
    ]
]



TestCase subclass: RATestSyntax [
    | abc def abcdef ab fe abd geh abqe aLT2 bEQfoo abcSquared abcGBa abcGBab abcOBaa abcOBad abcOBaabd abcEabc abcUabc abcIabc abcD abcI |
    
    <comment: nil>
    <category: 'Roe-Tests'>

    assert: aRelation hasAttributes: attributeNames [
	<category: 'private'>
	self assert: (aRelation attributes collect: [:ea | ea name asSymbol]) asArray 
		    = attributeNames
    ]

    assertError: aBlock [
	<category: 'private'>
	self should: aBlock raise: Error
    ]

    setUp [
	<category: 'running'>
	abc := RAArrayRelation name: 'abc' attributes: #(#a #b #c).
	def := RAArrayRelation name: 'def' attributes: #(#d #e #f).
	abcdef := abc * def.
	ab := abc projectAll: #(#a #b).
	fe := def projectAll: #(#f #e).
	abd := abc rename: #c to: #d.
	geh := def renameAll: #(#d #f) to: #(#g #h).
	abqe := ab * (fe rename: #f to: #q).
	aLT2 := abc select: [:ea | ea a < 2].
	bEQfoo := abc select: [:ea | ea b = 'foo' & (ea a >= (ea c * 2))].
	abcSquared := abc * (abc renameAll: #(#a #b #c) to: #(#a1 #b1 #c1)).
	abcGBa := abc groupBy: #a.
	abcGBab := abc groupByAll: #(#a #b).
	abcOBaa := abc orderBy: #a.
	abcOBad := abc orderBy: #a ascending: false.
	abcOBaabd := abc orderByAll: #(#a #b)
		    ascending: (Array with: true with: false).
	abcEabc := abc difference: abc.	"abc - abc"
	abcUabc := abc union: abc.	"abc , abc"
	abcIabc := abc intersection: abc.
	abcD := abc distinct.
	abcI := abc from: 10 to: 15	"abc copyFrom: 10 to: 15"
    ]

    testAttributeNames [
	<category: 'testing'>
	self assert: abc hasAttributes: #(#a #b #c).
	self assert: def hasAttributes: #(#d #e #f).
	self assert: abcdef hasAttributes: #(#a #b #c #d #e #f).
	self assert: ab hasAttributes: #(#a #b).
	self assert: fe hasAttributes: #(#f #e).
	self assert: abd hasAttributes: #(#a #b #d).
	self assert: geh hasAttributes: #(#g #e #h).
	self assert: abqe hasAttributes: #(#a #b #q #e).
	self assert: aLT2 hasAttributes: #(#a #b #c).
	self assert: bEQfoo hasAttributes: #(#a #b #c).
	self assert: abcSquared hasAttributes: #(#a #b #c #a1 #b1 #c1).
	self assert: abcGBa hasAttributes: #(#a #b #c).
	self assert: abcGBab hasAttributes: #(#a #b #c).
	self assert: abcOBaa hasAttributes: #(#a #b #c).
	self assert: abcOBad hasAttributes: #(#a #b #c).
	self assert: abcOBaabd hasAttributes: #(#a #b #c).
	self assert: abcEabc hasAttributes: #(#a #b #c).
	self assert: abcUabc hasAttributes: #(#a #b #c).
	self assert: abcIabc hasAttributes: #(#a #b #c).
	self assert: abcD hasAttributes: #(#a #b #c).
	self assert: abcI hasAttributes: #(#a #b #c)
    ]

    testEquality [
	<category: 'testing'>
	self assert: (abc project: #a) = (abc project: #a).
	self deny: (abc project: #a) = (abc project: #b).
	self deny: (abc project: #a) = (ab project: #a).
	self assert: (abc rename: #a to: #x) = (abc rename: #a to: #x).
	self assert: (abc renameAll: #(#a) to: #(#x)) = (abc rename: #a to: #x).
	self assert: (abc renameAll: #(#a #b) to: #(#x #y)) 
		    = (abc renameAll: #(#b #a) to: #(#y #x)).
	self 
	    deny: (abc rename: #a to: #x) = (abc renameAll: #(#a #b) to: #(#x #y))
    ]

    testErrors [
	<category: 'testing'>
	abc project: #c.
	self assertError: [abc project: #d].
	self assertError: [ab project: #c].
	abc rename: #c to: #e.
	self assertError: [abc rename: #d to: #e].
	abc renameAll: #(#a #b) to: #(#e #f).
	self assertError: [abc renameAll: #(#a #b) to: #(#e)].
	abc where: #a equals: 3.
	self assertError: [abc where: #d equals: 3].
	abc * (abc rename: #a to: #a2) project: #a.
	self assertError: [abc * abc project: #a].
	abc * (abc rename: #a to: #a2) rename: #a to: #e.
	self assertError: [abc * abc rename: #a to: #e].
	abc * (abc rename: #a to: #a2) where: #a equals: 3.
	self assertError: [abc * abc where: #a equals: 3]
    ]

    testEscapingSql [
	<category: 'testing'>
	self assert: '\' asEscapedSql = '\\'.
	self assert: '''' asEscapedSql = ''''''.
	self assert: '\''' asEscapedSql = '\\'''''
    ]

    testOrigins [
	<category: 'testing'>
	self assert: (abc attributeNamed: #a) originalRelation = abc.
	self assert: (abcdef attributeNamed: #a) originalRelation = abc.
	self assert: (abd attributeNamed: #d) originalRelation = abc.
	self assert: (abc attributeNamed: #c) originalAttribute 
		    = (abc attributeNamed: #c).
	self assert: (abd attributeNamed: #d) originalAttribute 
		    = (abc attributeNamed: #c)
    ]

    testPrinting [
	"commented out cause I'm not sure we care"

	"self assert: abc prints: 'abc'.
	 self assert: def prints: 'def'.
	 self assert: abcdef prints: '(abc) * (def)'.
	 self assert: ab prints: '(abc) projectAll: #(#a #b)'.
	 self assert: fe prints: '(def) projectAll: #(#f #e)'.
	 self assert: abd prints: '(abc) renameAll: #(#c) to: #(#d)'.
	 self assert: geh prints: '(def) renameAll: #(#d #f) to: #(#g #h)'.
	 self assert: abqe prints: '((abc) projectAll: #(#a #b)) * ( X R[f->q](P[f,e](def))'.
	 self assert: aLT2 prints: 'S[(a<2)](abc)'.
	 self assert: bEQfoo prints: 'S[((b=''foo'')&(a>=(c*2)))](abc)'.
	 self assert: abcSquared prints: 'abc X R[a->a1,b->b1,c->c1](abc)'.
	 self assert: abcGBa prints: 'G[a](abc)'.
	 self assert: abcGBab prints: 'G[a,b](abc)'.
	 self assert: abcOBaa prints: 'O[a->asc](abc)'.
	 self assert: abcOBad prints: 'O[a->desc](abc)'.
	 self assert: abcOBaabd prints: 'O[a->asc,b->desc](abc)'.
	 self assert: abcEabc prints: 'abc \ abc'.
	 self assert: abcUabc prints: 'abc u abc'.
	 self assert: abcIabc prints: 'abc n abc'.
	 self assert: abcD prints: '{abc}'.
	 self assert: abcI prints: 'I[10,15](abc)'."

	<category: 'testing'>
	
    ]

    testPrintingAlgebraic [
	<category: 'testing'>
	self assert: abc asAlgebraicString = 'abc'.
	self assert: def asAlgebraicString = 'def'.
	self assert: abcdef asAlgebraicString = 'abc X def'.
	self assert: ab asAlgebraicString = 'P[a,b](abc)'.
	self assert: fe asAlgebraicString = 'P[f,e](def)'.
	self assert: abd asAlgebraicString = 'R[c->d](abc)'.
	self assert: geh asAlgebraicString = 'R[d->g,f->h](def)'.
	self assert: abqe asAlgebraicString = 'P[a,b](abc) X R[f->q](P[f,e](def))'.
	self assert: aLT2 asAlgebraicString = 'S[(a<2)](abc)'.
	self assert: bEQfoo asAlgebraicString = 'S[((b=''foo'')&(a>=(c*2)))](abc)'.
	self 
	    assert: abcSquared asAlgebraicString = 'abc X R[a->a1,b->b1,c->c1](abc)'.
	self assert: abcGBa asAlgebraicString = 'G[a](abc)'.
	self assert: abcGBab asAlgebraicString = 'G[a,b](abc)'.
	self assert: abcOBaa asAlgebraicString = 'O[a->asc](abc)'.
	self assert: abcOBad asAlgebraicString = 'O[a->desc](abc)'.
	self assert: abcOBaabd asAlgebraicString = 'O[a->asc,b->desc](abc)'.
	self assert: abcEabc asAlgebraicString = 'abc \ abc'.
	self assert: abcUabc asAlgebraicString = 'abc u abc'.
	self assert: abcIabc asAlgebraicString = 'abc n abc'.
	self assert: abcD asAlgebraicString = '{abc}'.
	self assert: abcI asAlgebraicString = 'I[10,15](abc)'
    ]

    testPrintingSql [
	<category: 'testing'>
	| notNullQuery nullQuery dateQuery trueQuery dummyRelation |
	dummyRelation := RASQLRelation basicNew.
	notNullQuery := abc select: [:ea | ea a ~= nil].
	self assert: (RASqlPrinter print: notNullQuery for: dummyRelation) 
		    = 'SELECT * FROM (SELECT "a" AS c1, "b" AS c2, "c" AS c3 FROM abc) AS t1 WHERE (c1 IS NOT NULL)'.
	nullQuery := abc select: [:ea | ea a = nil].
	self assert: (RASqlPrinter print: nullQuery for: dummyRelation) 
		    = 'SELECT * FROM (SELECT "a" AS c1, "b" AS c2, "c" AS c3 FROM abc) AS t1 WHERE (c1 IS NULL)'.
	dateQuery := abc 
		    select: [:ea | ea a = (Date 
				    newDay: 10
				    monthIndex: 11
				    year: 2006)].
	self assert: (RASqlPrinter print: dateQuery for: dummyRelation) 
		    = 'SELECT * FROM (SELECT "a" AS c1, "b" AS c2, "c" AS c3 FROM abc) AS t1 WHERE (c1=''10-Nov-2006'')'.
	trueQuery := abc select: [:ea | ea a = true].
	self assert: (RASqlPrinter print: trueQuery for: dummyRelation) 
		    = 'SELECT * FROM (SELECT "a" AS c1, "b" AS c2, "c" AS c3 FROM abc) AS t1 WHERE (c1=''true'')'
    ]
]


Object subclass: RAMockObject [
    
    <category: 'Roe-Tests'>
    <comment: nil>

    RAMockObject class >> fromValues: aDictionary [
	^self new initializeWithValues: aDictionary
    ]

    initializeWithValues: aDictionary [
	<category: 'initialize-release'>
	
    ]
]



RAMockObject subclass: RAMockCourse [
    | title |
    
    <category: 'Roe-Tests'>
    <comment: nil>

    initializeWithValues: aDictionary [
	<category: 'initialize-release'>
	title := aDictionary at: #title
    ]
]



RAMockObject subclass: RAMockStudent [
    | name |
    
    <category: 'Roe-Tests'>
    <comment: nil>

    initializeWithValues: aDictionary [
	<category: 'initialize-release'>
	name := aDictionary at: #name
    ]
]



Object extend [
    asString [
	^self printString
    ]
]

PK
     �Mh@N�1�  �    Array.stUT	 dqXO�XOux �  �  "=====================================================================
|
|   ROE bridge to standard collections
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) Avi Bryant
|
| Permission is hereby granted, free of charge, to any person
| obtaining a copy of this software and associated documentation
| files (the `Software'), to deal in the Software without
| restriction, including without limitation the rights to use,
| copy, modify, merge, publish, distribute, sublicense, and/or sell
| copies of the Software, and to permit persons to whom the
| Software is furnished to do so, subject to the following
| conditions:
| 
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
| 
| THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
| OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
| NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
| HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
| WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
| FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
| OTHER DEALINGS IN THE SOFTWARE.
|
 ======================================================================"

RAConcreteRelation subclass: RAArrayRelation [
    | tuples |
    
    <category: 'Roe-Relations-Concrete'>
    <comment: nil>

    RAArrayRelation class >> name: aString attributes: anArray [
	^self basicNew initializeWithName: aString attributes: anArray
    ]

    addValues: anArray [
	<category: 'adding'>
	tuples add: (anArray collect: [:ea | Array with: ea])
    ]

    for: aRelation do: aBlock [
	<category: 'private'>
	(RAEvaluator evaluate: aRelation) do: 
		[:array | 
		aBlock value: (RASimpleTuple relation: aRelation
			    values: (array collect: [:ea | ea first]))]
    ]

    for: aRelation update: aBlock [
	<category: 'updating'>
	(RAEvaluator evaluate: aRelation) 
	    do: [:ea | aBlock value: (RABoxedTuple relation: aRelation values: ea)]
    ]

    initializeWithName: aString [
	<category: 'initializing'>
	self initializeWithName: aString attributes: #()
    ]

    initializeWithName: aString attributes: anArray [
	<category: 'initializing'>
	super initializeWithName: aString.
	attributes := anArray 
		    collect: [:ea | RASimpleAttribute named: ea relation: self].
	tuples := OrderedCollection new
    ]

    tuples [
	<category: 'accessing'>
	^tuples
    ]

    update: aBlock [
	<category: 'updating'>
	tuples do: [:ea | aBlock value: (RABoxedTuple relation: self values: ea)]
    ]
]



RAVisitor subclass: RAEvaluator [
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    RAEvaluator class >> evaluate: aRelation [
	^self new visit: aRelation
    ]

    visitCartesianProduct: aRelation [
	| right left |
	right := self visit: aRelation right.
	left := self visit: aRelation left.
	^Array 
	    streamContents: [:s | left do: [:l | right do: [:r | s nextPut: l , r]]]
    ]

    visitClone: aClone [
	^self visitTransformation: aClone
    ]

    visitDifference: aRelation [
	| right |
	right := self visit: aRelation right.
	^Array streamContents: 
		[:stream | 
		(self visit: aRelation left) 
		    do: [:row | (right includes: row) ifFalse: [stream nextPut: row]]]
    ]

    visitDistinct: aRelation [
	^(self visit: aRelation source) asSet asArray
    ]

    visitIntersection: aRelation [
	^(self visit: aRelation left) intersection: (self visit: aRelation right)
    ]

    visitInterval: aRelation [
	^(self visitTransformation: aRelation) copyFrom: aRelation start
	    to: aRelation stop
    ]

    visitOrder: aRelation [
	| result ascending order pos block |
	result := self visitTransformation: aRelation.
	aRelation order size to: 1
	    by: -1
	    do: 
		[:index | 
		ascending := aRelation ascending at: index.
		order := aRelation order at: index.
		pos := aRelation attributes indexOf: order.
		block := 
			[:x :y | 
			ascending 
			    ifTrue: [(x at: pos) first < (y at: pos) first]
			    ifFalse: [(x at: pos) first > (y at: pos) first]].
		result := result sort: block].
	^result
    ]

    visitProjection: aRelation [
	| projectedAttributes sourceAttributes |
	projectedAttributes := aRelation attributes.
	sourceAttributes := aRelation source attributes.
	^(self visitTransformation: aRelation) collect: 
		[:tuple | 
		Array streamContents: 
			[:s | 
			tuple with: sourceAttributes
			    do: [:val :attr | (projectedAttributes includes: attr) ifTrue: [s nextPut: val]]]]
    ]

    visitRelation: aRelation [
	^aRelation tuples
    ]

    visitSelection: aRelation [
	| arrays tuples |
	arrays := self visitTransformation: aRelation.
	tuples := arrays 
		    collect: [:ea | RABoxedTuple relation: aRelation values: ea].
	tuples := tuples select: [:ea | aRelation evaluateTuple: ea].
	^tuples collect: [:ea | ea values]
    ]

    visitUnion: aRelation [
	^(self visit: aRelation left) , (self visit: aRelation right)
    ]
]



RASimpleTuple subclass: RABoxedTuple [
    
    <category: 'Roe-Tuples'>
    <comment: nil>

    isMutable [
	^relation isMutable
    ]

    takeValue: anObject forAttribute: anAttribute [
	(values at: (relation attributes indexOf: anAttribute)) at: 1 put: anObject
    ]

    valueForAttribute: anAttribute [
	^(super valueForAttribute: anAttribute) first
    ]
]



PK
     �Mh@��9�3  �3    SQL.stUT	 dqXO�XOux �  �  "=====================================================================
|
|   ROE SQL statement generator
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) Avi Bryant
|
| Permission is hereby granted, free of charge, to any person
| obtaining a copy of this software and associated documentation
| files (the `Software'), to deal in the Software without
| restriction, including without limitation the rights to use,
| copy, modify, merge, publish, distribute, sublicense, and/or sell
| copies of the Software, and to permit persons to whom the
| Software is furnished to do so, subject to the following
| conditions:
| 
| The above copyright notice and this permission notice shall be
| included in all copies or substantial portions of the Software.
| 
| THE SOFTWARE IS PROVIDED `AS IS', WITHOUT WARRANTY OF ANY KIND,
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
| OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
| NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
| HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
| WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
| FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
| OTHER DEALINGS IN THE SOFTWARE.
|
 ======================================================================"

RAConcreteRelation subclass: RASQLRelation [
    | connection |
    
    <category: 'Roe-Relations-Concrete'>
    <comment: nil>
    
    Log := false.

    RASQLRelation class >> log [
	^Log
    ]

    RASQLRelation class >> log: aBoolean [
	Log := aBoolean.
    ]

    RASQLRelation class >> name: aString [
	self shouldNotImplement
    ]

    RASQLRelation class >> name: aString connection: aConnection [
	^self basicNew initializeWithName: aString connection: aConnection
    ]

    addValues: anArray [
	<category: 'adding'>
	self exec: (self sqlInsert: (self attributes collect: [:ea | ea name])
		    values: anArray)
    ]

    attributes [
	<category: 'accessing'>
	attributes isNil ifTrue: [attributes := self discoverAttributes].
	^attributes
    ]

    basicExec: aString [
	<category: 'private'>
	self subclassResponsibility
    ]

    basicQuery: aString [
	<category: 'private'>
	self subclassResponsibility
    ]

    connection [
	<category: 'accessing'>
	^connection
    ]

    deleteFor: aRelation [
	<category: 'removing'>
	| conditionString |
	conditionString := RASingleTableSqlPrinter print: aRelation for: self.
	self exec: (self sqlDeleteWhere: conditionString)
    ]

    discoverAttributes [
	<category: 'private'>
	self subclassResponsibility
    ]

    exec: aString [
	<category: 'private'>
	^self logging: aString do: [self basicExec: aString]
    ]

    for: aRelation do: aBlock [
	<category: 'private'>
	(self query: (self sqlPrinterClass print: aRelation for: self)) 
	    do: [:ea | aBlock value: (RASimpleTuple relation: aRelation values: ea asArray)]
    ]

    for: aRelation update: aBlock [
	<category: 'updating'>
	| tuple conditionString |
	tuple := RAUpdateTuple relation: aRelation.
	aBlock value: tuple.
	conditionString := RASingleTableSqlPrinter print: aRelation for: self.
	self exec: (self sqlUpdate: tuple nodes where: conditionString)
    ]

    initializeWithName: aString connection: aConnection [
	<category: 'initializing'>
	super initializeWithName: aString.
	connection := aConnection
    ]

    log [
	<category: 'private'>
	^Log
    ]

    logging: aString do: aBlock [
	<category: 'private'>
	| time val |
	self log
	    ifTrue: [Transcript nextPutAll: aString].
	time := Time millisecondsToRun: [val := aBlock value].
	self log
	    ifTrue: [Transcript nextPutAll: ' [' , time printString , ']'; nl].
	^val
    ]

    query: aString [
	<category: 'private'>
	^self logging: aString do: [self basicQuery: aString]
    ]

    size [
	<category: 'core'>
	self subclassResponsibility
    ]

    sqlCount [
	<category: 'private'>
	^'SELECT COUNT(*) FROM ' , self name
    ]

    sqlDeleteWhere: conditionString [
	<category: 'private'>
	^String streamContents: 
		[:stream | 
		stream
		    nextPutAll: 'DELETE FROM ';
		    nextPutAll: self name;
		    nextPutAll: ' WHERE ';
		    nextPutAll: conditionString]
    ]

    sqlInsert: attributeNames values: anArray [
	<category: 'private'>
	^String streamContents: 
		[:stream | 
		stream
		    nextPutAll: 'INSERT INTO ';
		    nextPutAll: self name;
		    nextPutAll: ' ('.
		attributeNames do: 
			[:each | self printAttribute: each on: stream ]
		    separatedBy: [stream nextPutAll: ', '].
		stream nextPutAll: ') VALUES ('.
		anArray do: 
			[:each | self print: each on: stream ]
		    separatedBy: [stream nextPutAll: ', '].
		stream nextPutAll: ')']
    ]

    printAttribute: each on: aStream [
        <category: 'printing'>
	aStream
	    nextPut: $";
	    nextPutAll: each;
	    nextPut: $"
    ]

    print: anObject on: aStream [
        <category: 'printing'>
	anObject isNil ifTrue: [
	    aStream nextPutAll: 'NULL'. ^self ].
	aStream nextPut: $'.
	anObject isString
	    ifTrue: [ aStream nextPutAll: anObject asEscapedSql ]
	    ifFalse: [ aStream nextPutAll: anObject printString asEscapedSql ].
	aStream nextPut: $'
    ]

    sqlPrinterClass [
	<category: 'private'>
	^RASqlPrinter
    ]

    sqlUpdate: attributesToNodes where: conditionString [
	<category: 'private'>
	^String streamContents: 
		[:stream | 
		stream
		    nextPutAll: 'UPDATE ';
		    nextPutAll: name;
		    nextPutAll: ' SET '.
		attributesToNodes keysAndValuesDo: 
			[:attribute :node | 
			stream
			    nextPutAll: '"' , attribute originalAttribute name , '"';
			    nextPutAll: ' = (';
			    nextPutAll: (RASqlUpdatePrinter print: node for: self);
			    nextPutAll: '), '].
		stream skip: -2.
		stream nextPutAll: ' WHERE '.
		stream nextPutAll: conditionString]
    ]
]


RAPrinter subclass: RASingleTableSqlPrinter [
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    errorInvalidOperation [
	<category: 'visiting'>
	self error: 'Invalid operation on this relation'
    ]

    printOperator: aNode [
	<category: 'private'>
	stream nextPutAll: aNode sqlOperator
    ]

    visitAlias: aRelation [
	<category: 'visiting'>
	self visit: aRelation source
    ]

    visitAttributeNode: aNode [
	<category: 'visiting'>
	stream nextPutAll: '"' , aNode attribute originalAttribute name , '"'
    ]

    visitCartesianProduct: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitDifference: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitDistinct: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitGroup: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitIntersection: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitInterval: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]

    visitOrder: aRelation [
	<category: 'visiting'>
	self visit: aRelation source
    ]

    visitProjection: aRelation [
	<category: 'visiting'>
	self visit: aRelation source
    ]

    visitRelation: aRelation [
	<category: 'visiting'>
	stream nextPutAll: ' 1=1'
    ]

    visitSelection: aRelation [
	<category: 'visiting'>
	self visit: aRelation source.
	stream nextPutAll: ' AND ( '.
	self visitConditionNodesFor: aRelation.
	stream nextPutAll: ')'
    ]

    visitUnion: aRelation [
	<category: 'visiting'>
	self errorInvalidOperation
    ]
]



RAPrinter subclass: RASqlPrinter [
    | tableCounter columnCounter columnMap |
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    attributeNames: aCollection [
	<category: 'private'>
	^String streamContents: 
		[:s | 
		aCollection 
		    do: [:each | s nextPutAll: (self columnNameForAttribute: each)]
		    separatedBy: [s nextPutAll: ', ']]
    ]

    attributeNames: aCollection aliasedAs: aliasCollection [
	<category: 'private'>
	^String streamContents: 
		[:s | 
		(1 to: aCollection size)
		    do: 
			[:index || attr alias |
			attr := aCollection at: index.
			alias := aliasCollection at: index.
			s
			    nextPutAll: (self columnNameForAttribute: attr);
			    nextPutAll: ' AS ';
			    nextPutAll: (self columnNameForAttribute: alias) ]
		    separatedBy: [s nextPutAll: ', ']]
    ]

    columnNameForAttribute: anAttribute [
	<category: 'private'>
	columnMap ifNil: [columnMap := Dictionary new].
	^columnMap at: anAttribute ifAbsentPut: [self nextColumnName]
    ]

    nextColumnName [
	<category: 'accessing'>
	columnCounter := columnCounter ifNil: [1]
		    ifNotNil: [:foo | columnCounter + 1].
	^'c' , columnCounter printString
    ]

    nextTableName [
	<category: 'accessing'>
	tableCounter := tableCounter ifNil: [1] ifNotNil: [:foo | tableCounter + 1].
	^'t' , tableCounter printString
    ]

    printOperator: aNode [
	<category: 'private'>
	stream nextPutAll: aNode sqlOperator
    ]

    select: aString fromRelation: aRelation [
	<category: 'private'>
	stream
	    nextPutAll: 'SELECT ';
	    nextPutAll: aString;
	    nextPutAll: ' FROM '.
	self subselectRelation: aRelation
    ]

    selectAllFromRelation: aRelation [
	<category: 'private'>
	self select: '*' fromRelation: aRelation
    ]

    subselectRelation: aRelation [
	<category: 'private'>
	stream nextPut: $(.
	self visit: aRelation.
	stream
	    nextPutAll: ') AS ';
	    nextPutAll: self nextTableName
    ]

    visitAlias: aRelation [
	<category: 'visiting'>
	self select: (self attributeNames: aRelation source attributes
		    aliasedAs: aRelation attributes)
	    fromRelation: aRelation source
    ]

    visitAttributeNode: aNode [
	<category: 'visiting'>
	stream nextPutAll: (self columnNameForAttribute: aNode attribute)
    ]

    visitBoolean: aBoolean [
	<category: 'visiting-objects'>
	self visitObject: aBoolean
    ]

    visitCartesianProduct: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT * FROM '.
	self subselectRelation: aRelation left.
	stream nextPutAll: ', '.
	self subselectRelation: aRelation right
    ]

    visitClone: aRelation [
	<category: 'visiting'>
	self visitAlias: aRelation
    ]

    visitDate: aDate [
	<category: 'visiting-objects'>
	self visitObject: aDate
    ]

    visitDifference: aRelation [
	<category: 'visiting'>
	self visit: aRelation left.
	stream nextPutAll: ' EXCEPT '.
	self visit: aRelation right.
    ]

    visitDistinct: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT DISTINCT * FROM '.
	self subselectRelation: aRelation source
    ]

    visitGroup: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT * FROM '.
	self subselectRelation: aRelation source.
	stream nextPutAll: ' GROUP BY '.
	stream nextPutAll: (self attributeNames: aRelation group)
    ]

    visitIntersection: aRelation [
	<category: 'visiting'>
	self visit: aRelation left.
	stream nextPutAll: ' INTERSECT '.
	self visit: aRelation right.
    ]

    visitInterval: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT * FROM '.
	self subselectRelation: aRelation source.
	stream
	    nextPutAll: ' LIMIT ';
	    print: aRelation limit.
	stream
	    nextPutAll: ' OFFSET ';
	    print: aRelation offset
    ]

    visitOrder: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT * FROM '.
	self subselectRelation: aRelation source.
	stream nextPutAll: ' ORDER BY '.
	(1 to: aRelation order size) do: 
		[:index | 
		stream 
		    nextPutAll: (self columnNameForAttribute: (aRelation order at: index)).
		(aRelation ascending at: index) 
		    ifTrue: [stream nextPutAll: ' ASC']
		    ifFalse: [stream nextPutAll: ' DESC']]
	    separatedBy: [stream nextPutAll: ', ']
    ]

    visitProjection: aRelation [
	<category: 'visiting'>
	self select: (self attributeNames: aRelation attributes)
	    fromRelation: aRelation source
    ]

    visitRelation: aRelation [
	<category: 'visiting'>
	stream nextPutAll: 'SELECT '.
	aRelation attributes do: 
		[:attr | 
		stream
		    nextPutAll: '"';
		    nextPutAll: attr name;
		    nextPutAll: '" AS ';
		    nextPutAll: (self columnNameForAttribute: attr)]
	    separatedBy: [stream nextPutAll: ', '].
	stream nextPutAll: ' FROM ' , aRelation name
    ]

    visitSelection: aRelation [
	<category: 'visiting'>
	self selectAllFromRelation: aRelation source.
	stream nextPutAll: ' WHERE '.
	self visitConditionNodesFor: aRelation
    ]

    visitUndefinedObject: anUndefinedObject [
	<category: 'visiting-objects'>
	stream nextPutAll: 'NULL'
    ]

    visitUnion: aRelation [
	<category: 'visiting'>
	self visit: aRelation left.
	stream nextPutAll: ' UNION '.
	self visit: aRelation right.
    ]
]



RAPrinter subclass: RASqlUpdatePrinter [
    
    <category: 'Roe-Visitors'>
    <comment: nil>

    visitAttributeNode: aNode [
	<category: 'visiting'>
	stream nextPutAll: '"' , aNode attribute originalAttribute name , '"'
    ]
]


String extend [

    asEscapedSql [
       <category: '*Roe'>
       ^String streamContents: 
               [:stream | 
               self do: 
                       [:char | 
                       (#($' $\) includes: char) ifTrue: [stream nextPut: char].

                       stream nextPut: char]]
    ]

]
PK
     �Mh@E����  �            ��    Core.stUT dqXOux �  �  PK
     �[h@+d�4�  �            ��3�  package.xmlUT �XOux �  �  PK
     �Mh@��/�s	  s	            ��i�  SQLiteTests.stUT dqXOux �  �  PK
     �Mh@�%�  �            ��$�  Extensions.stUT dqXOux �  �  PK
     �Mh@��Q��R  �R            ���  Tests.stUT dqXOux �  �  PK
     �Mh@N�1�  �            ���  Array.stUT dqXOux �  �  PK
     �Mh@��9�3  �3            ��� SQL.stUT dqXOux �  �  PK      -  �<   