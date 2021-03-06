PK
     �Mh@Zr��@N  @N  
  Publish.stUT	 eqXO[�XOux �  �  "======================================================================
|
|   Documentation generator abstract classes.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2007,2008,2009
| Free Software Foundation, Inc.
| Written by Steve Byrne and Paolo Bonzini.
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
| GNU Smalltalk; see the file COPYING.	If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"


String extend [
    caseSensitiveCompareTo: aCharacterArray [
	<category: 'private-ClassPublisher extensions'>
        | c1 c2 |
        1 to: (self size min: aCharacterArray size)
            do:
                [:i |
                c1 := (self at: i) value.
                c2 := (aCharacterArray at: i) value.
                c1 = c2 ifFalse: [^c1 - c2]].
        ^self size - aCharacterArray size
    ]
]


Object subclass: ClassPublisher [
    | class destination referenceNamespace |
    
    <category: 'Examples-File out'>
    <comment: nil>

    ClassPublisher class >> basicPublish: aClass on: aFileStream [
	"Publish aClass, in the format supported by the receiver, on aFileStream"

	<category: 'publishing'>
	self new fileOut: aClass on: aFileStream
    ]

    ClassPublisher class >> publish: aClass on: aFileStream [
	"Publish aClass, in the format supported by the receiver, on aFileStream"

	<category: 'publishing'>
	self new fileOut: aClass on: aFileStream
    ]

    ClassPublisher class >> publish: aClass onFile: fileNameString [
	"Publish aClass, in the format supported by the receiver, on a file named
	 fileNameString"

	<category: 'publishing'>
	| file |
	file := FileStream open: fileNameString mode: 'w'.
	[self publish: aClass on: file] ensure: [file close]
    ]

    fileOut: aClass on: aFileStream [
	"File out the given class on aFileStream."

	<category: 'publishing'>
	referenceNamespace := self namespaceFor: aClass.
	class := aClass asClass.
	destination := aFileStream.
	self emitHeader: Date dateAndTimeNow.
	class := class asMetaclass.
	self fileOutMethods.
	class := class asClass.
	self fileOutMethods.
	self emitFooter
    ]

    fileOutMethods [
	"File out the methods in the current method dictionary."

	<category: 'publishing'>
	| categories now |
	categories := Set new.
	self methodDictionary isNil ifTrue: [^self].
	self methodDictionary 
	    do: [:method | categories add: method methodCategory].
	categories asSortedCollection 
	    do: [:category | self emitCategory: category]
    ]

    emitCategory: category [
	"Emit valid output for the given category."

	<category: 'to be subclassed'>
	self subclassResponsibility
    ]

    emitFooter [
	"Emit a valid footer."

	<category: 'to be subclassed'>
	self subclassResponsibility
    ]

    emitHeader: timestamp [
	"Emit a valid header. timestamp contains `Date dateAndTimeNow'."

	<category: 'to be subclassed'>
	self subclassResponsibility
    ]

    escaped [
	"Answer a set of characters that must be passed through #printEscaped: -
	 for example, <, & and > in HTML"

	<category: 'to be subclassed'>
	^''
    ]

    namespaceFor: aClass [
	"aClass is being published. Answer the namespace to be used when producing
	 names."

	<category: 'to be subclassed'>
	^aClass environment
    ]

    printEscaped: ch [
	"Called by #nextPutText: when a character that must be escaped is
	 encountered. The actual behavior depends on the class - for instance,
	 Postscripts put a \ before it"

	<category: 'to be subclassed'>
	self nextPut: ch
    ]

    currentClass [
	"Answer the class which we are working on"

	<category: 'accessing/delegating'>
	^class
    ]

    classCategory [
	"Answer the category of the class which we are working on"

	<category: 'accessing/delegating'>
	| class |
	class := self currentClass asClass.
	^class category isNil ifTrue: [''] ifFalse: [class category]
    ]

    classComment [
	"Answer the comment of the class which we are working on"

	<category: 'accessing/delegating'>
	| class |
	class := self currentClass asClass.
	^class comment isNil ifTrue: [''] ifFalse: [class comment]
    ]

    className [
	"Answer the name of the class which we are working on"

	<category: 'accessing/delegating'>
	^self currentClass asClass nameIn: referenceNamespace
    ]

    superclassName [
	"Answer the name of the class which we are working on"

	<category: 'accessing/delegating'>
	| superclass |
	superclass := self currentClass asClass superclass.
	superclass isNil ifTrue: [^'none'].
	^superclass nameIn: referenceNamespace
    ]

    nextPut: aCharacter [
	"Append aCharacter on the file-out"

	<category: 'accessing/delegating'>
	destination nextPut: aCharacter
    ]

    nextPutAll: aString [
	"Append aString on the file-out, literally"

	<category: 'accessing/delegating'>
	destination nextPutAll: aString
    ]

    nextPutAllText: aString [
	"Append aCharacter on the file-out, replacing tabs in aString with
	 appropriate number of spaces, and escaping characters appropriately"

	<category: 'accessing/delegating'>
	| hpos prev |
	hpos := 1.
	aString do: 
		[:ch | 
		ch == Character tab 
		    ifTrue: 
			[
			[self nextPut: Character space.
			hpos := hpos + 1.
			hpos \\ 8 = 1] 
				whileFalse: [].
                        prev := Character space]
		    ifFalse: 
			[self nextPutAllChar: ch after: prev.
			hpos := hpos + 1.
                        prev := ch]]
    ]

    nextPutAllChar: ch after: prev [
       (self escaped includes: ch) 
			    ifTrue: [self printEscaped: ch]
			    ifFalse: [self nextPut: ch].
    ]

    nl [
	"Append a new line on the file-out"

	<category: 'accessing/delegating'>
	destination nl
    ]

    space [
	"Append a space on the file-out"

	<category: 'accessing/delegating'>
	destination space
    ]

    print: anObject [
	"Print anObject on the file-out, replacing tabs in aString with
	 appropriate number of spaces, and escaping characters appropriately"

	<category: 'accessing/delegating'>
	self nextPutAllText: anObject printString
    ]

    store: anObject [
	"Store Smalltalk code evaluating to anObject on the file-out, replacing
	 tabs in aString with appropriate number of spaces, and escaping characters
	 appropriately"

	<category: 'accessing/delegating'>
	self nextPutAllText: anObject storeString
    ]

    skip: skip [
	"Move by skip bytes in the file-out"

	<category: 'accessing/delegating'>
	destination skip: skip
    ]

    position [
	"Answer the current position in the file-out"

	<category: 'accessing/delegating'>
	^destination position
    ]

    position: position [
	"Move the pointer in the file-out to the given position"

	<category: 'accessing/delegating'>
	destination position: position
    ]

    methodDictionary [
	"Answer the method dictionary for the class we're working on"

	<category: 'accessing/delegating'>
	^self currentClass methodDictionary
    ]

    selectorAndBody: methodString [
	"Answer a two-element Array containing the selector and the
	 body of the method, as they appear in methodString"

	<category: 'useful parsing'>
	| sel body ch split start pos |
	start := self skipWhite: 1 on: methodString.
	ch := methodString at: start.
	split := ch isAlphaNumeric 
		    ifTrue: [self parseUnaryOrKeyword: methodString from: start]
		    ifFalse: 
			[pos := self skipToWhite: start on: methodString.
			pos := self skipWhite: pos on: methodString.
			pos := self skipIdentifier: pos on: methodString.
			self skipPastNewline: pos on: methodString].
	sel := methodString copyFrom: start to: split - 1.
	body := split > methodString size 
		    ifFalse: [methodString copyFrom: split to: methodString size]
		    ifTrue: [''].
	^Array with: sel trimSeparators with: body
    ]

    skipToWhite: start on: string [
	"Answer the position of the first non-white character in string, starting
	 the scan at position start"

	<category: 'useful parsing'>
	| pos |
	pos := start.
	
	[pos > string size ifTrue: [^pos].
	(string at: pos) isSeparator] 
		whileFalse: [pos := pos + 1].
	^pos
    ]

    skipWhiteExceptNewlines: stream [
	"Skip up to next non-separator or newline.  Answer whether stream
	 is not at end afterwards."

	<category: 'useful parsing'>
	
	[| char |
	stream atEnd ifTrue: [^false].
	char := stream next.
	char isSeparator 
	    and: [(##(
		{Character nl.
		Character cr} asString) includes: char) not]] 
		whileTrue.
	stream skip: -1.
	^true
    ]

    skipWhite: start on: string [
	"Answer the position of the first white character in string, starting
	 the scan at position start"

	<category: 'useful parsing'>
	| pos |
	pos := start.
	
	[pos > string size ifTrue: [^pos].
	(string at: pos) isSeparator] 
		whileTrue: [pos := pos + 1].
	^pos
    ]

    skipWhite: stream [
	"Skip everything up to the first white character in stream. Answer
	 true if a non-white character was found before the end of the stream"

	<category: 'useful parsing'>
	
	[stream atEnd ifTrue: [^false].
	stream next isSeparator] whileTrue: [].
	stream skip: -1.
	^true
    ]

    skipIdentifier: start on: string [
	"Answer the position of the first non-alphanumeric character in string,
	 starting the scan at position start"

	<category: 'useful parsing'>
	| pos |
	pos := start.
	
	[pos > string size ifTrue: [^pos].
	(string at: pos) isAlphaNumeric] 
		whileTrue: [pos := pos + 1].
	^pos
    ]

    skipPastNewline: start on: string [
	"Answer the position of the first white character (not including new-line
	 characters) in string, starting the scan at position start"

	<category: 'useful parsing'>
	| pos ch |
	pos := start.
	
	[ch := string at: pos.
	ch isSeparator and: [ch ~~ Character nl]] 
		whileTrue: [pos := pos + 1].
	ch == Character nl ifTrue: [pos := pos + 1].
	^pos
    ]

    parseUnaryOrKeyword: string from: start [
	"Parse a message selector from string."

	<category: 'useful parsing'>
	| pos ch tempPos |
	pos := self skipIdentifier: start on: string.
	pos > string size ifTrue: [^string size + 1].
	ch := string at: pos.
	ch == $: 
	    ifFalse: 
		["Got a unary selector"

		pos := self skipPastNewline: pos on: string.
		^pos].
	pos := start.
	
	[tempPos := self skipWhite: pos on: string.
	tempPos > string size ifTrue: [^string size + 1].
	ch := string at: tempPos.
	"make sure we have a valid keyword identifier to start"
	ch isLetter ifFalse: [^self skipPastNewline: pos on: string].
	tempPos := self skipIdentifier: tempPos on: string.
	tempPos > string size ifTrue: [^string size + 1].
	ch := string at: tempPos.
	ch == $: ifFalse: [^self skipPastNewline: pos on: string].

	"parsed a keyword, expect an identifier next"
	tempPos := self skipWhite: tempPos + 1 on: string.
	tempPos > string size ifTrue: [^string size + 1].
	ch := string at: tempPos.
	ch isLetter ifFalse: [^self skipPastNewline: pos on: string].
	pos := self skipIdentifier: tempPos on: string.
	pos > string size ifTrue: [^string size + 1].
	true] 
		whileTrue
    ]

    reformatComment: source [
	"I extract a comment from source, which is a stream pointing right after
	 a double quote character."

	<category: 'useful parsing'>
	| comment input |
	input := source upTo: $".
	comment := WriteStream on: (String new: input size).
	input := ReadStream on: input.
	[input atEnd] whileFalse: 
		[comment nextPutAll: (input upTo: Character nl).
		comment nl.
		self skipWhiteExceptNewlines: input].
	^comment contents
    ]

    extractComment: source [
	"I seek a starting comment in source, which is a method's source code.
	 If I cannot find it, I try to guess one, else I answer the comment."

	<category: 'useful parsing'>
	| isCommented comment |
	comment := ReadStream on: source.
	self skipWhite: comment.
	isCommented := comment peekFor: $".

	"Check for new syntax."
	isCommented 
	    ifFalse: 
		[comment peekFor: $[.
		self skipWhite: comment.
		isCommented := comment peekFor: $"].

	"Maybe they put temporaries *before* the method comment..."
	isCommented 
	    ifFalse: 
		[(comment peekFor: $|) 
		    ifTrue: 
			[comment skipTo: $|.
			isCommented := comment atEnd not and: 
					[self skipWhite: comment.
					comment peekFor: $"]]].
	^isCommented 
	    ifTrue: [self reformatComment: comment]
	    ifFalse: [self guessComment: comment contents]
    ]

    guessComment: source [
	"I look at source, which has no starting comment, and try to guess a comment"

	<category: 'useful parsing'>
	| n m start |
	(source indexOfSubCollection: 'shouldNotImplement') > 0 
	    ifTrue: [^'This method should not be called for instances of this class.'].
	(source indexOfSubCollection: 'notYetImplemented') > 0 
	    ifTrue: [^'This method''s functionality has not been implemented yet.'].
	(source indexOfSubCollection: 'subclassResponsibility') > 0 
	    ifTrue: 
		[^'This method''s functionality should be implemented by subclasses of ' 
		    , self currentClass asClass printString].
	n := 1.
	
	[n := self skipWhite: n on: source.
	(n > source size or: [']"' includes: (source at: n)]) 
	    ifTrue: [^'Answer the receiver.'].
	m := self skipToWhite: n on: source.
	start := source copyFrom: n to: m - 1.
	n := self skipWhite: m on: source.
	(start notEmpty and: 
		[(start at: 1) = $^ 
		    and: [n > source size or: [']"' includes: (source at: n)]]]) 
	    ifTrue: 
		[start = '^self' ifTrue: [^'Answer the receiver.'].
		^'Answer `' , (start copyFrom: 2 to: start size) , '''.'].
	n <= source size 
	    ifTrue: 
		[(source at: n) = $< 
		    ifTrue: [n := source indexOf: $> startingAt: n]
		    ifFalse: [(']"' includes: (source at: n)) ifFalse: [^'Not commented.']].
		n := n + 1]] 
		repeat
    ]
]



"----------------------------------------------------------------------"



ClassPublisher subclass: DocPublisher [
    | categories |
    
    <category: 'Examples-File out'>
    <comment: nil>

    DocPublisher class >> printHierarchyOf: classes on: aFileStream [
	"Typeset on aFileStream a full hierarchy tree, starting from the classes
	 in the given Collection"

	<category: 'printing trees'>
	self makeDescendentsDictionary: (self makeFullTree: classes)
	    thenPrintOn: aFileStream
    ]

    DocPublisher class >> printHierarchyOf: dict hierarchy: desc startAt: root on: aFileStream indent: indent [
	"Recursive worker method for #printHierarchyOf:on:
	 dict is the classes Dictionary as obtained by makeFullTree:,
	 desc is the classes Dictionary as passed by makeDescendentsDictionary:thenPrintOn:"

	<category: 'printing trees'>
	| subclasses |
	subclasses := desc at: root.
	subclasses := self sortClasses: subclasses.
	subclasses do: 
		[:each | 
		self 
		    printTreeClass: each
		    shouldLink: (dict at: each)
		    on: aFileStream
		    indent: indent.
		self 
		    printHierarchyOf: dict
		    hierarchy: desc
		    startAt: each
		    on: aFileStream
		    indent: (indent copyWith: $ )]
    ]

    DocPublisher class >> printTreeClass: class shouldLink: aBoolean on: aFileStream indent: indent [
	"Abstract - do nothing by default"

	<category: 'printing trees'>
	
    ]

    DocPublisher class >> sortClasses: collection [
	<category: 'printing trees'>
	^collection asSortedCollection: 
		[:a :b | 
		(a nameIn: Namespace current) <= (b nameIn: Namespace current)]
    ]

    DocPublisher class >> makeFullTree: classes [
	"From the classes collection, create a Dictionary in which we ensure
	 that every key's superclass is also a key.  For example, if
	 classes contained Object and Array, the dictionary would also have
	 Collection, SequenceableCollection and ArrayedCollection as keys.
	 For every key, its value is true if classes includes it, else it is
	 false."

	<category: 'printing trees'>
	| dict newClasses checkClasses |
	dict := LookupTable new: classes size.
	classes do: [:each | dict at: each put: true].
	checkClasses := dict keys.
	
	[newClasses := Set new.
	checkClasses do: 
		[:each | 
		each superclass isNil 
		    ifFalse: 
			[(dict includesKey: each superclass) 
			    ifFalse: [newClasses add: each superclass]]].
	newClasses isEmpty] 
		whileFalse: 
		    [newClasses do: [:each | dict at: each put: false].
		    checkClasses := newClasses].
	^dict
    ]

    DocPublisher class >> makeDescendentsDictionary: dict thenPrintOn: aFileStream [
	"From the dict Dictionary, created by #makeFullTree:, create
	 another with the same keys.  Each key is associated to a set of
	 classes which are all the immediate subclasses which are also
	 keys of dict.  Then this dictionary is passed to the recursive
	 method #printHierarchyOf:hierarchy:startAt:on:"

	<category: 'printing trees'>
	| descendents |
	descendents := dict collect: [:each | Set new].
	descendents at: #none put: Set new.
	dict keysDo: 
		[:each | 
		each superclass isNil 
		    ifTrue: [(descendents at: #none) add: each]
		    ifFalse: [(descendents at: each superclass) add: each]].
	self 
	    printHierarchyOf: dict
	    hierarchy: descendents
	    startAt: #none
	    on: aFileStream
	    indent: ''
    ]

    emitMethod: source [
	<category: 'abstract'>
	
    ]

    emitMethodSelector: source [
	<category: 'abstract'>
	
    ]

    emitSelectorAndMethod: association [
	<category: 'abstract'>
	self emitMethodSelector: association key.
	self emitMethod: association value
    ]

    emitIndexFooter [
	<category: 'abstract'>
	
    ]

    emitLink: category kind: kind [
	<category: 'abstract'>
	
    ]

    emitAfterNode [
	<category: 'abstract'>
	
    ]

    emitNode: index category: category [
	<category: 'abstract'>
	
    ]

    namespaceFor: aClass [
	"aClass is being published. Answer the namespace to be used when producing
	 names; by default, this is the current namespace for documentation
	 publishers."

	<category: 'abstract'>
	^Namespace current
    ]

    categoriesSize [
	<category: 'accessing'>
	^categories size
    ]

    categoryAt: n [
	<category: 'accessing'>
	^(categories at: n) key
    ]

    categoryAt: n ifBadIndex: aString [
	<category: 'accessing'>
	n < 1 ifTrue: [^aString].
	n > categories size ifTrue: [^aString].
	^(categories at: n) key
    ]

    emitCategory: category [
	"I emit a link to the anchor where the category will be, and store
	 enough information so that they'll be able to generate the actual
	 output."

	<category: 'subclassed'>
	| categoryMethods methods kind private |
	private := category indexOfSubCollection: 'private' startingAt: 1.
	private = 0 ifFalse: [^self].
	kind := self currentClass isMetaclass 
		    ifTrue: [' (class)']
		    ifFalse: [' (instance)'].
	methods := self methodDictionary 
		    select: [:each | each methodCategory = category].
	categoryMethods := OrderedCollection new.
	methods associationsDo: 
		[:assoc | 
		assoc value methodSourceString isNil 
		    ifFalse: [categoryMethods add: assoc key -> assoc value methodSourceString]].
	categoryMethods := categoryMethods asSortedCollection: [ :a :b |
	    (a key caseSensitiveCompareTo: b key) <= 0 ].
	categories add: (category , kind) -> categoryMethods.
	self emitLink: category kind: kind
    ]

    emitFooter [
	"In addition to the footer, I emit the actual documentation based on data
	 collected by #emitCategory:."

	<category: 'subclassed'>
	self emitIndexFooter.
	categories doWithIndex: 
		[:each :index | 
		self emitNode: index category: each key.
		each value do: [:assoc | self emitSelectorAndMethod: assoc].
		self emitAfterNode]
    ]
]
PK
     �[h@��@�   �     package.xmlUT	 [�XO[�XOux �  �  <package>
  <name>ClassPublisher</name>
  <namespace>STInST</namespace>
  <prereq>Parser</prereq>

  <filein>Publish.st</filein>
  <filein>PSFileOut.st</filein>
  <filein>HTML.st</filein>
  <filein>Texinfo.st</filein>
  <file>ChangeLog</file>
</package>PK
     �Mh@~q�i�  �    PSFileOut.stUT	 eqXO[�XOux �  �  "======================================================================
|
|   File out PostScript method definitions.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
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
| GNU Smalltalk; see the file COPYING.	If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"


ClassPublisher subclass: PSFileOutPublisher [
    
    <category: 'Examples-File out'>
    <comment: nil>

    emitCategory: category [
	"I write Postscript for legal Smalltalk load syntax definitions of all of my methods
	 are in the 'category' category"

	<category: 'subclassed'>
	self
	    nextPutAll: 'italic setfont';
	    nl;
	    nextPutAll: '(!';
	    print: self class;
	    nextPutAll: ' methodsFor: ';
	    store: category;
	    nextPutAll: '!)';
	    nextPutAll: ' show ';
	    nl.
	self methodDictionary 
	    do: [:method | method methodCategory = category ifTrue: [self emitMethod: method]].
	self nextPutAll: '(!) show newline
newline newline
'
    ]

    emitMethod: method [
	"I emit valid PostScript for method's source code."

	<category: 'subclassed'>
	| data |
	method methodSourceString isNil ifTrue: [^self].
	data := self selectorAndBody: method methodSourceString.
	self
	    nextPutAll: 'newline newline';
	    nl;
	    nextPutAll: 'bold setfont';
	    nl;
	    emitLines: (data at: 1);
	    nextPutAll: 'normal setfont';
	    nl;
	    emitLines: (data at: 2);
	    nextPutAll: '(! ) show ';
	    nl
    ]

    escaped [
	"Answer a set of characters that must be passed through #printEscaped: -
	 i.e. ( and )"

	<category: 'subclassed'>
	^'()'
    ]

    printEscaped: ch [
	"Put a \ before ( and ) characters."

	<category: 'subclassed'>
	self
	    nextPut: $\;
	    nextPut: ch
    ]

    emitLines: string [
	"Print string, a line at a time"

	<category: 'subclassed'>
	string linesDo: 
		[:line | 
		self
		    nextPut: $(;
		    nextPutAllText: line;
		    nextPutAll: ') show newline';
		    nl]
    ]

    emitFooter [
	"I emit a valid Postscript footer."

	<category: 'subclassed'>
	self
	    nextPutAll: 'finish';
	    nl
    ]

    emitHeader: now [
	"I emit a valid Postscript header for the file-out."

	<category: 'subclassed'>
	| stream |
	stream := WriteStream on: (String new: 200).
	self currentClass fileOutDeclarationOn: stream.
	self
	    nextPutAll: self header;
	    nextPutAll: 'normal setfont';
	    nl;
	    nextPutAll: '(''Filed out from ';
	    nextPutAll: Smalltalk version;
	    nextPutAll: ' on ';
	    print: (now at: 1);
	    nextPutAll: '	';
	    print: (now at: 2);
	    nextPutAll: ' ''!)';
	    nextPutAll: ' show newline newline';
	    nl;
	    nl;
	    emitLines: stream contents;
	    nextPutAll: '() show newline newline';
	    nl;
	    nl
    ]

    header [
	<category: 'PostScript'>
	^'%!

%%%
%%% User settable parameters
%%%

/fontSize 10 def
/leading 2 def
/indent 10 def


%%%
%%% End of user settable parameters
%%%

clippath pathbbox
  /uy exch def
  /ux exch def
  /ly exch def
  /lx exch def


/lineHeight fontSize leading add def

/ystart uy lineHeight sub def
/ypos ystart def

/linecounter 0 def
/maxline
    uy ly sub		    % height
    lineHeight		    % line_height height
    div floor		    % max_whole_lines_per_page
def

/Helvetica findfont fontSize scalefont /normal exch def
/Helvetica-Bold findfont fontSize scalefont /bold exch def
/Helvetica-Oblique findfont fontSize scalefont /italic exch def

/newline { % - => -
    /ypos ypos lineHeight sub def
    /linecounter linecounter 1 add def
    linecounter maxline 1 sub ge
    {
	showpage
	/ypos ystart def
	/linecounter 0 def
    } if
    indent ypos moveto
} def

/finish { % - => -
    linecounter 0 gt
    { showpage }
    if
} def

indent ypos moveto

'
    ]
]
PK
     �Mh@��gb)  b)  
  Texinfo.stUT	 eqXO[�XOux �  �  "======================================================================
|
|   File out a TexInfo reference.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
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
| GNU Smalltalk; see the file COPYING.	If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"


DocPublisher subclass: TexinfoDocPublisher [
    
    <category: 'Examples-File out'>
    <comment: nil>

    TexinfoDocPublisher class [
	| current |
	
    ]

    TexinfoDocPublisher class >> nextClass [
	<category: 'multiple classes'>
	| result |
	^(result := current peek) isNil 
	    ifTrue: ['']
	    ifFalse: [result nameIn: Namespace current]
    ]

    TexinfoDocPublisher class >> prevClass [
	<category: 'multiple classes'>
	| result |
	current position = 2 ifTrue: [^'Tree'].
	current skip: -2.
	result := current next.
	current atEnd ifFalse: [current next].
	^result nameIn: Namespace current
    ]

    TexinfoDocPublisher class >> publishAll: classArray onFile: aFileName [
	<category: 'multiple classes'>
	| stream |
	stream := FileStream open: aFileName mode: FileStream write.
	[self publishAll: classArray on: stream] ensure: [stream close]
    ]

    TexinfoDocPublisher class >> publishAll: classArray on: aFileStream [
	<category: 'multiple classes'>
	| sorted |
	sorted := self sortClasses: classArray.
	current := ReadStream on: sorted.
	aFileStream nextPutAll: self header.
	sorted do: 
		[:each | 
		aFileStream
		    nextPutAll: '* ';
		    nextPutAll: (each nameIn: Namespace current);
		    nextPutAll: '::';
		    nl].
	aFileStream nextPutAll: self beforeTree.
	self printHierarchyOf: sorted on: aFileStream.
	aFileStream nextPutAll: self afterTree.
	sorted do: 
		[:each | 
		current atEnd ifFalse: [current next].
		'writing documentation for ' display.
		(each nameIn: Namespace current) displayNl.
		self basicPublish: each on: aFileStream].
	aFileStream nextPutAll: self footer
    ]

    TexinfoDocPublisher class >> publishAll: classArray [
	self publishAll: classArray on: stdout
    ]

    TexinfoDocPublisher class >> publishAll: classArray toLocation: aFileName [
	self publishAll: classArray onFile: aFileName
    ]

    TexinfoDocPublisher class >> publish: aClass on: aFileStream [
	"Publish aClass, in the format supported by the receiver, on aFileStream"

	<category: 'multiple classes'>
	self publishAll: (Array with: aClass) on: aFileStream
    ]

    TexinfoDocPublisher class >> header [
	<category: 'texinfo source'>
	^'@c Define the class index, method index, and selector cross-reference
@ifclear CLASS-INDICES
@set CLASS-INDICES
@defindex cl
@defcodeindex me
@defcodeindex sl 
@end ifclear

@c These are used for both TeX and HTML
@set BEFORE1
@set  AFTER1
@set BEFORE2
@set  AFTER2

@ifinfo
@c Use asis so that leading and trailing spaces are meaningful.
@c Remember we''re inside a @menu command, hence the blanks are
@c kept in the output.
@set BEFORE1 @asis{* }
@set  AFTER1 @asis{::}
@set BEFORE2 @asis{  (}
@set  AFTER2 @asis{)}
@end ifinfo

@macro class {a,b}
@value{BEFORE1}\a\\a\@b{\b\}@value{AFTER1}
@end macro
@macro superclass {a,b}
\a\\a\@value{BEFORE2}@i{\b\}@value{AFTER2}
@end macro

@ifnotinfo
@macro begindetailmenu
@display
@end macro
@macro enddetailmenu
@end display
@end macro
@end ifnotinfo

@ifinfo
@macro begindetailmenu
@detailmenu
@end macro
@macro enddetailmenu
@end detailmenu
@end macro
@end ifinfo

@iftex
@macro beginmenu
@end macro
@macro endmenu
@end macro
@end iftex

@ifnottex
@macro beginmenu
@menu
@end macro
@macro endmenu
@end menu
@end macro
@end ifnottex

@beginmenu
@ifnottex
Alphabetic list:
'
    ]

    TexinfoDocPublisher class >> beforeTree [
	<category: 'texinfo source'>
	^'@end ifnottex

@ifinfo
Class tree:
@end ifinfo
@iftex
@section Tree
@end iftex
@ifnotinfo

Classes documented in this manual are @b{boldfaced}.

@end ifnotinfo
@begindetailmenu
'
    ]

    TexinfoDocPublisher class >> afterTree [
	<category: 'texinfo source'>
	^'@enddetailmenu
@endmenu
@unmacro class
@unmacro superclass
@unmacro endmenu
@unmacro beginmenu
@unmacro enddetailmenu
@unmacro begindetailmenu
'
    ]

    TexinfoDocPublisher class >> footer [
	<category: 'texinfo source'>
	^''
    ]

    TexinfoDocPublisher class >> printTreeClass: class shouldLink: aBoolean on: aFileStream indent: indent [
	"The @t{} is needed because otherwise makeinfo discards the leading spaces
	 in indent -- i.e. the whole string, since indent is only made of spaces."

	<category: 'creating the class tree'>
	aBoolean
	    ifTrue: [aFileStream nextPutAll: '@class{@t{'];
	    ifFalse: [aFileStream nextPutAll: '@superclass{@t{'].
	aFileStream
	    nextPutAll: indent;
	    nextPutAll: '}, ';
	    nextPutAll: (class nameIn: Namespace current);
	    nextPut: $};
	    nl
    ]

    TexinfoDocPublisher class >> publishNamespaces: aCollection [
	<category: 'creating GST''s manual'>
	| subclasses |
	subclasses := Set new.
	aCollection do: 
		[:ns | 
		ns 
		    allClassesDo: [:each | (each inheritsFrom: CStruct) ifFalse: [subclasses add: each]]].
	^self publishAll: subclasses onFile: 'classes.texi'
    ]

    emitMethodSelector: aSymbol [
	"I emit a Texinfo indexing command for the selector in aSymbol."

	<category: 'emitting comments'>
	self
	    nextPutAll: '@meindex ';
	    nextPutAllText: aSymbol;
	    nl
    ]

    emitCrossReferences: comment [
	"Emit the cross-references to other selectors that are included
	 in the method comment."

	<category: 'emitting comments'>
	| i j ch |
	i := 1.
	
	[(i := comment 
		    indexOf: $#
		    startingAt: i
		    ifAbsent: [nil]) isNil] 
		whileFalse: 
		    [j := i.
		    
		    [j := j + 1.
		    j > comment size or: [#(${ $} $[ $] $, $' $. $( $) $ $; $<10>) includes: (comment at: j)]]
			    whileFalse.
		    i + 1 < j 
			ifTrue: 
			    [self
				nextPutAll: '@slindex ';
				nextPutAllText: (comment copyFrom: i + 1 to: j - 1);
				nl].
		    i := j]
    ]

    emitSelectorAndMethod: association [
	"I emit valid Texinfo markup for a comment contained in source - which is
	 a method's source code."

	<category: 'subclassed'>
	| selAndBody comment |
	selAndBody := self selectorAndBody: association value.
	comment := self extractComment: (selAndBody at: 2).

	"Uncomment to avoid documenting private methods"
	"(comment size > 7 and: [ (comment copyFrom: 1 to: 7) = 'Private' ])
	 ifTrue: [ ^self ]."
	self
	    emitMethodSelector: association key;
	    emitCrossReferences: comment;
	    nextPutAll: '@item ';
	    nextPutAllText: ((selAndBody at: 1) copyWithout: Character nl);
	    nl;
	    nextPutAllText: comment;
	    nl;
	    nl
    ]

    emitLink: category kind: kind [
	<category: 'subclassed'>
	self
	    nextPutAll: '* ';
	    nextPutAllText: (self nodeName: category , kind);
	    nextPutAll: ':: ';
	    nextPutAllText: kind;
	    nl
    ]

    emitIndexFooter [
	<category: 'subclassed'>
	self
	    nextPutAll: '@end menu';
	    nl;
	    nl
    ]

    emitAfterNode [
	<category: 'subclassed'>
	self
	    nextPutAll: '@end table';
	    nl;
	    nl
    ]

    prevCategory: index [
	<category: 'subclassed'>
	index = 1 ifTrue: [^self className].
	^self nodeName: (self categoryAt: index - 1)
    ]

    nextCategory: index [
	<category: 'subclassed'>
	index = self categoriesSize ifTrue: [^''].
	^self nodeName: (self categoryAt: index + 1)
    ]

    className: category [
	<category: 'subclassed'>
	| size className |
	size := category size.
	className := self className.
	^(category copyFrom: size - 6 to: size) = '(class)' 
	    ifTrue: [className , ' class']
	    ifFalse: [className]
    ]

    nodeName: category [
	<category: 'subclassed'>
	| last className |
	last := category findLast: [:each | each == Character space].
	className := self className: category.
	^className , '-' , (category copyFrom: 1 to: last - 1)
    ]

    sectionName: category [
	<category: 'subclassed'>
	| last className |
	last := category findLast: [:each | each == Character space].
	className := self className: category.
	^className , ': ' , (category copyFrom: 1 to: last - 1)
    ]

    emitNode: index category: category [
	<category: 'subclassed'>
	self
	    nl;
	    nl;
	    nextPutAll: '@node ';
	    nextPutAll: (self nodeName: category);
	    nl;
	    nextPutAll: '@subsection ';
	    nextPutAllText: (self sectionName: category);
	    nl;
	    nl;
	    nextPutAll: '@table @b';
	    nl
    ]

    emitHeader: now [
	"I emit a valid TexInfo header for the file-out."

	<category: 'subclassed'>
	categories := OrderedCollection new.
	self nextPutAll: '@node %1
@section %1
@clindex %1

' % {self className}.
	self
	    nextPutAll: '@table @b';
	    nl;
	    nextPutAll: '@item Defined in namespace ';
	    nextPutAllText: self currentClass environment storeString;
	    nl;
	    nextPutAll: '@itemx Superclass: ';
	    nextPutAllText: self superclassName;
	    nl;
	    nextPutAll: '@itemx Category: ';
	    nextPutAllText: self classCategory;
	    nl;
	    nextPutAllText: self classComment;
	    nl;
	    nextPutAll: '@end table';
	    nl;
	    nl;
	    nextPutAll: '@menu';
	    nl
    ]

    escaped [
	"Answer a set of characters that must be passed through #printEscaped: -
	 i.e. @, {, }."

	<category: 'subclassed'>
	^'@{}'
    ]

    printEscaped: ch [
	"Print ch with a @ in front of it."

	<category: 'subclassed'>
	self nextPut: $@.
	self nextPut: ch
    ]

    nextPutAllChar: ch after: prev [
        "Treat # and : specially so that we can insert hyphenation signs
	 and avoid overfull hboxes long ABC>>#def signatures are encountered."

	<category: 'subclassed'>
        (prev isNil or: [ prev isSeparator ]) ifFalse: [
	    ch = $# ifTrue: [^self nextPutAll: '@-#'].
	    ch = $: ifTrue: [^self nextPutAll: ':@-']].
	^super nextPutAllChar: ch after: prev
    ]
]

PK    �Mh@u�+ V    	  ChangeLogUT	 eqXO[�XOux �  �  �SKo�0>w�H�!%쮠�UUmii�TĪ-'��u&���g��"�;��BT�j����g����ɸ�L��+��
6����7 ���j��T���F{/�W��j�Z;;�+ta���
(��B"8l��#`�R5M��r���#���*�|�C�4B�q͋��֞t*�T�gU>p�k㛰=p�|mt�5�����F��@��P|��+/��Cςs�4$�z�H#( �{���N��B��9M�}"��}�8��7Ѵ�U:�ߖ��\"�i��I�X�y=o�2��C���-(8�Hۇ�@	-_��)���{��?x
~�=Z�~�Qi�DDѯ�:qq��r[�o�0"�
��3�ħďVrʵ,}�Hf9���S�&�XR�~Wm�n�̛(�5��ە�$��;+�2z2�W ǵ���%\3�A+�bNW�:C�%���,`ֶE�Q,�ο�N���kƾC'���Z�JzXν����V;G��dpB�>���)�B�;Kel�9��(�K�����(NG�H�aIY6K�Hq ����4i�W'̕NQ���8OHtW�W�.i�Y��&�U�ƌ����\o�^�W$W蕓kdʠ�PK
     �Mh@x��  �    HTML.stUT	 eqXO[�XOux �  �  "======================================================================
|
|   File out a HTML reference.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
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
| GNU Smalltalk; see the file COPYING.	If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"


DocPublisher subclass: HTMLDocPublisher [
    
    <category: 'Examples-File out'>
    <comment: nil>

    HTMLDocPublisher class >> publishNamespaces: aCollection [
	<category: 'multiple classes'>
	| subclasses |
	subclasses := Set new.
	aCollection do: 
		[:ns | 
		ns 
		    allClassesDo: [:each | (each inheritsFrom: CStruct) ifFalse: [subclasses add: each]]].
	self publishAll: subclasses withIndexOnFile: 'classes.html'
    ]

    HTMLDocPublisher class >> publishAll: classArray withIndexOn: aFileStream [
	<category: 'multiple classes'>
	| sorted |
	sorted := self sortClasses: classArray.
	aFileStream 
	    nextPutAll: '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"> <!--
Automatically yours from GNU Smalltalk''s HTMLDocPublisher! -->

<HTML>
<HEAD>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
    <META NAME="GENERATOR" CONTENT="GNU Smalltalk HTMLDocPublisher">
    <TITLE>Smalltalk class reference</TITLE>
</HEAD>
<BODY>
<H1>Smalltalk class reference</H1><HR><P>
<PRE>
'.
	self printHierarchyOf: sorted on: aFileStream.
	aFileStream nextPutAll: '
    
Alphabetic list of classes:'; nl.
	sorted do: 
		[:each | 
		| fileName |
		fileName := each nameIn: Namespace current.
		('writing documentation into ' , fileName , '.html') displayNl.
		self publish: each onFile: fileName , '.html'.
		aFileStream
		    nextPutAll: '<A HREF="%1.html">%1</A>' % {fileName};
		    nl].
	aFileStream nextPutAll: '</PRE></BODY></HTML>'
    ]

    HTMLDocPublisher class >> publishAll: classArray withIndexOnFile: aFileName [
	<category: 'multiple classes'>
	| stream |
	stream := FileStream open: aFileName mode: FileStream write.
	[self publishAll: classArray withIndexOn: stream] ensure: [stream close]
    ]

    HTMLDocPublisher class >> publishAll: classArray toLocation: dirName [
	| currentDir |
	currentDir := Directory working.
	dirName = '.'
            ifFalse: [
		(File isAccessible: dirName) ifFalse: [ Directory create: dirName ].
		Directory working: dirName ].
	self publishAll: classArray withIndexOnFile: 'classes.html'.
	dirName = '.' ifFalse: [ Directory working: currentDir ]
    ]

    HTMLDocPublisher class >> publishAll: classArray [
	self publishAll: classArray toLocation: '.'
    ]

    HTMLDocPublisher class >> printTreeClass: class shouldLink: aBoolean on: aFileStream indent: indent [
	<category: 'writing the class tree'>
	| fileName |
	aFileStream
	    nextPutAll: indent;
	    nextPutAll: indent.
	fileName := class nameIn: Namespace current.
	aBoolean 
	    ifTrue: [aFileStream nextPutAll: '<A HREF="' , fileName , '.html">']
	    ifFalse: [aFileStream nextPut: $(].
	aFileStream nextPutAll: (class nameIn: Namespace current).
	aBoolean 
	    ifTrue: [aFileStream nextPutAll: '</A>']
	    ifFalse: [aFileStream nextPut: $)].
	aFileStream nl
    ]

    emitMethod: source [
	"I emit valid HTML for a comment contained in source - which is a method's
	 source code."

	<category: 'emitting comments'>
	| selAndBody comment |
	selAndBody := self selectorAndBody: source.
	comment := self extractComment: (selAndBody at: 2).
	self
	    nextPutAll: '<B>';
	    nextPutAllText: (selAndBody at: 1);
	    nextPutAll: '</B><BLOCKQUOTE>';
	    nextPutAllText: comment;
	    nextPutAll: '</BLOCKQUOTE><P>';
	    nl;
	    nl
    ]

    emitLink: category kind: kind [
	<category: 'subclassed'>
	self
	    nextPutAll: '<A HREF="#';
	    print: categories size;
	    nextPutAll: '">';
	    nextPutAllText: category;
	    nextPutAll: '</A>';
	    nextPutAll: kind;
	    nextPutAll: '<BR>';
	    nl
    ]

    emitFooter [
	<category: 'subclassed'>
	super emitFooter.
	self nextPutAll: '</BODY></HTML>'
    ]

    emitAfterNode [
	<category: 'subclassed'>
	self
	    nextPutAll: '<A HREF="#top">top</A><BR>';
	    nl
    ]

    emitNode: index category: category [
	<category: 'subclassed'>
	self
	    nl;
	    nl;
	    nextPutAll: '<HR><P><H3><A NAME="';
	    print: index;
	    nextPutAll: '">';
	    nextPutAllText: category;
	    nextPutAll: '</A></H3></P>';
	    nl
    ]

    emitHeader: now [
	"I emit a valid HTML header for the file-out."

	<category: 'subclassed'>
	categories := OrderedCollection new.
	self 
	    nextPutAll: '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"> <!--
Automatically yours from GNU Smalltalk''s HTMLDocPublisher!
Filed out from %1 on %2	 %3 -->

<HTML>
<HEAD>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
    <META NAME="GENERATOR" CONTENT="GNU Smalltalk HTMLDocPublisher">
    <TITLE>%4</TITLE>
</HEAD>
<BODY>
' 
		    % 
			{Smalltalk version.
			now at: 1.
			now at: 2.
			self className}.
	self
	    nextPutAll: '<DL><DT><B>Category: ';
	    nextPutAllText: self classCategory;
	    nl;
	    nextPutAll: '<BR>Superclass: ';
	    nextPutAllText: self superclassName;
	    nextPutAll: '</B><DD>';
	    nl;
	    nextPutAllText: self classComment;
	    nl;
	    nextPutAll: '</DL><P><A NAME="top"><H2>Method category index</H2></A>';
	    nl
    ]

    escaped [
	"Answer a set of characters that must be passed through #printEscaped: -
	 i.e. <, >, & and double quote"

	<category: 'subclassed'>
	^'<>&"'
    ]

    printEscaped: ch [
	"Print ch as a SGML entity."

	<category: 'subclassed'>
	ch = $< ifTrue: [^self nextPutAll: '&lt;'].
	ch = $> ifTrue: [^self nextPutAll: '&gt;'].
	ch = $& ifTrue: [^self nextPutAll: '&amp;'].
	ch = $" ifTrue: [^self nextPutAll: '&quot;'].
	self nextPut: ch
    ]
]
PK
     �Mh@Zr��@N  @N  
          ��    Publish.stUT eqXOux �  �  PK
     �[h@��@�   �             ���N  package.xmlUT [�XOux �  �  PK
     �Mh@~q�i�  �            ���O  PSFileOut.stUT eqXOux �  �  PK
     �Mh@��gb)  b)  
          ���a  Texinfo.stUT eqXOux �  �  PK    �Mh@u�+ V    	         ����  ChangeLogUT eqXOux �  �  PK
     �Mh@x��  �            ��.�  HTML.stUT eqXOux �  �  PK      �  ,�    