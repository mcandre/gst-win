PK
     M[h@�cW�E  E    package.xmlUT	 R�XOR�XOux �  �  <package>
  <name>Iconv</name>
  <namespace>I18N</namespace>
  <test>
    <namespace>I18N</namespace>
    <prereq>Iconv</prereq>
    <prereq>SUnit</prereq>
    <sunit>I18N.IconvTest</sunit>
    <filein>iconvtests.st</filein>
  </test>
  <module>iconv</module>

  <filein>Sets.st</filein>
  <filein>UTF7.st</filein>
</package>PK
     �Mh@R}����  ��    Sets.stUT	 dqXOR�XOux �  �  "======================================================================
|
|   Base encodings including Unicode (ISO10646)
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2005, 2006, 2007, 2008 Free Software Foundation, Inc.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Eval [
    I18N addSubspace: #Encoders
]



Error subclass: InvalidSequenceError [
    
    <category: 'i18n-Character sets'>
    <comment: 'I am raised if an invalid sequence is found while converting a
string from a charset to another'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'invalid input sequence'
    ]
]



Error subclass: IncompleteSequenceError [
    
    <category: 'i18n-Character sets'>
    <comment: 'I am raised if an invalid sequence is found while converting a
string from a charset to another.  In particular, I am raised
if the input stream ends abruptly in the middle of a multi-byte
sequence.'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'incomplete input sequence'
    ]
]



SystemExceptions.SystemExceptions.InvalidArgument subclass: InvalidCharsetError [
    
    <category: 'i18n-Character sets'>
    <comment: 'I am raised if the user tries to encode from or to an unknown
encoding'>

    description [
	"Answer a textual description of the exception."

	<category: 'accessing'>
	^'unknown encoding specified'
    ]
]



CharacterArray subclass: EncodedString [
    | string encoding |
    
    <category: 'i18n-Character sets'>
    <comment: 'An EncodedString, like a String, is a sequence of bytes representing
a specific encoding of a UnicodeString.  Unlike a String, however,
the encoding name is known, rather than detected, irrelevant or
assumed to be the system default.'>

    EncodedString class >> fromString: aString [
	<category: 'instance creation'>
	| str |
	str := aString asString.
	str encoding = str class defaultEncoding ifTrue: [ ^str ].
	^self fromString: str encoding: str encoding
    ]

    EncodedString class >> fromString: aString encoding: encoding [
	<category: 'instance creation'>
	| str |
	str := aString isString 
		    ifTrue: [aString]
		    ifFalse: [aString asString: encoding].
	str encoding = encoding ifTrue: [ ^str ].
	^(self basicNew)
	    setString: aString;
	    encoding: encoding
    ]

    EncodedString class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    EncodedString class >> new: size [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    EncodedString class >> isUnicode [
	"Answer false; the receiver stores bytes (i.e. an encoded
	 form), not characters."

	<category: 'accessing'>
	^false
    ]

    asString [
	<category: 'accessing'>
	^string
    ]

    asUnicodeString [
	<category: 'accessing'>
	^string asUnicodeString: encoding
    ]

    at: anIndex [
	<category: 'accessing'>
	^string at: anIndex
    ]

    at: anIndex put: anObject [
	<category: 'accessing'>
	^string at: anIndex put: anObject
    ]

    do: aBlock [
	<category: 'accessing'>
	string do: aBlock
    ]

    encoding [
	<category: 'accessing'>
	encoding = 'UTF-32' ifTrue: [^string utf32Encoding ].
	encoding = 'UTF-16' ifTrue: [^string utf16Encoding ].
	^encoding
    ]

    hash [
	<category: 'accessing'>
	^string hash bitXor: encoding hash
    ]

    species [
	<category: 'accessing'>
	^EncodedStringFactory encoding: self encoding
    ]

    size [
	<category: 'accessing'>
	^string size
    ]

    utf16Encoding [
	<category: 'accessing'>
	^string utf16Encoding
    ]

    utf32Encoding [
	<category: 'accessing'>
	^string utf32Encoding
    ]

    valueAt: anIndex [
	<category: 'accessing'>
	^string valueAt: anIndex
    ]

    valueAt: anIndex put: anObject [
	<category: 'accessing'>
	^string valueAt: anIndex put: anObject
    ]

    displayOn: aStream [
	"Print a representation of the receiver on aStream. Unlike
	 #printOn:, this method does not display the encoding and
	 enclosing quotes."

	<category: 'printing'>
	string displayOn: aStream
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	aStream
	    nextPutAll: encoding;
	    nextPut: $[.
	(string asUnicodeString: encoding) asString printOn: aStream.
	aStream nextPut: $]
    ]

    copy [
	<category: 'copying'>
	^self class fromString: string copy encoding: self encoding
    ]

    copyEmpty [
	<category: 'copying'>
	^self class fromString: (string copyEmpty: string size)
	    encoding: self encoding
    ]

    copyEmpty: size [
	<category: 'copying'>
	^self class fromString: (string copyEmpty: size) encoding: self encoding
    ]

    setString: aString [
	<category: 'initializing'>
	string := aString
    ]

    encoding: aString [
	<category: 'initializing'>
	encoding := aString
    ]
]



Object subclass: EncodedStringFactory [
    | encoding |
    
    <category: 'i18n-Character sets'>
    <comment: 'An EncodedStringFactory is used (in place of class objects) so that
Encoders can return EncodedString objects with the correct encoding.'>

    EncodedStringFactory class >> encoding: aString [
	"Answer a new EncodedStringFactory, creating strings with the
	 given encoding."

	<category: 'instance creation'>
	^self new encoding: aString
    ]

    fromString: aString [
	"Answer an EncodedString based on aString and in the encoding
	 represented by the receiver."

	<category: 'instance creation'>
	^EncodedString fromString: aString encoding: self encoding
    ]

    new [
	"Answer a new, empty EncodedString using the encoding
	 represented by the receiver."

	<category: 'instance creation'>
	^EncodedString fromString: String new encoding: self encoding
    ]

    new: size [
	"Answer a new EncodedString of the given size, using the encoding
	 represented by the receiver."

	<category: 'instance creation'>
	^EncodedString fromString: (String new: size) encoding: self encoding
    ]

    isUnicode [
	"Answer false; the receiver stores bytes (i.e. an encoded
	 form), not characters."

	<category: 'accessing'>
	^false
    ]

    encoding [
	"Answer the encoding used for the created Strings."

	<category: 'instance creation'>
	^encoding
    ]

    encoding: aString [
	"Set the encoding used for the created Strings."

	<category: 'instance creation'>
	encoding := aString
    ]
]



Stream subclass: Encoder [
    | origin from to factory |
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is the superclass of streams that take an origin
and encode it to another character set.  The subclasses are
are for internal use unless you are writing support for your own
encodings.'>

    Encoder class >> on: aStringOrStream from: fromEncoding to: toEncoding [
	"Answer a new encoder that translates from fromEncoding
	 to toEncoding.  The encodings are guaranteed to be
	 those for which the encoder was registered."

	<category: 'instance creation'>
	^self basicNew 
	    initializeFrom: fromEncoding
	    to: toEncoding
	    origin: aStringOrStream
    ]

    atEnd [
	"Return whether the receiver can produce another character in
	 the receiver; by default, this is true if there is another
	 character in the origin."

	<category: 'stream operations'>
	^self atEndOfInput
    ]

    next [
	"Return the next character in the receiver; by default,
	 this is the next character in the origin."

	<category: 'stream operations'>
	^self nextInput
    ]

    atEndOfInput [
	"Return whether there is another character in the origin.  This
	 method is for private use by encoders, calling it outside won't
	 corrupt the internal state of the encoder but the result
	 probably won't be meaningful (depending on the innards of the
	 encoder)."

	<category: 'stream operations'>
	^origin atEnd
    ]

    peekInput [
	"Return the next character in the origin without advancing it."

	<category: 'stream operations'>
	^origin peek
    ]

    nextInput [
	"Return the next character in the origin.  This method is for
	 private use by encoders, calling it outside may corrupt the
	 internal state of the encoder."

	<category: 'stream operations'>
	^origin next
    ]

    nextInputAvailable: n into: aCollection startingAt: pos [
	"Place up to N characters from the origin in aCollection.  This method is for
	 private use by encoders, calling it outside may corrupt the
	 internal state of the encoder."

	<category: 'stream operations'>
	^origin nextAvailable: n into: aCollection startingAt: pos
    ]

    species [
	"We answer a string of Characters encoded in our destination
	 encoding."

	<category: 'stream operations'>
	factory isNil 
	    ifTrue: 
		[factory := to = String defaultEncoding 
			    ifTrue: [String]
			    ifFalse: [EncodedStringFactory encoding: to]].
	^factory
    ]

    initializeFrom: fromEncoding to: toEncoding origin: aStringOrStream [
	<category: 'private - initialization'>
	from := fromEncoding.
	to := toEncoding.
	origin := (aStringOrStream isKindOf: Stream) 
		    ifFalse: [aStringOrStream readStream]
		    ifTrue: [aStringOrStream].
	self flush
    ]
]



Stream subclass: EncodedStream [
    
    <import: Encoders>
    <category: 'i18n-Character sets'>
    <comment: 'This class is a factory for subclasses of Encoder.  Encoders
act as parts of a pipe, hence this class provides methods that
construct an appropriate pipe.'>

    EncodersRegistry := nil.

    EncodedStream class >> initialize [
	"Initialize the registry of the encoders to include the standard
	 encoders contained in the library."

	<category: 'initializing'>
	EncodersRegistry := #().
    ]

    EncodedStream class >> registerEncoderFor: arrayOfAliases toUTF32: toUTF32Class fromUTF32: fromUTF32Class [
	"Register the two classes that will respectively convert from the
	 charsets in arrayOfAliases to UTF-32 and vice versa.
	 
	 The former class is a stream that accepts characters and returns
	 (via #next) integers representing UTF-32 character codes, while
	 the latter accepts UTF-32 character codes and converts them to
	 characters.  For an example see respectively FromUTF7 and ToUTF7
	 (I admit it is not a trivial example)."

	<category: 'initializing'>
	EncodersRegistry := EncodersRegistry copyWith: 
			{arrayOfAliases.
			toUTF32Class.
			fromUTF32Class}
    ]

    EncodedStream class >> bigEndianPivot [
	"When only one of the sides is implemented in Smalltalk
	 and the other is obtained via iconv, we use UTF-32 to
	 marshal data from Smalltalk to iconv; answer whether we
	 should encode UTF-32 characters as big-endian."

	<category: 'private - triangulating'>
	^Memory bigEndian
    ]

    EncodedStream class >> pivotEncoding [
	"When only one of the sides is implemented in Smalltalk
	 and the other is obtained via iconv, we need a common
	 pivot encoding to marshal data from Smalltalk to iconv.
	 Answer the iconv name of this encoding."

	<category: 'private - triangulating'>
	^self bigEndianPivot ifTrue: ['UTF-32BE'] ifFalse: ['UTF-32LE']
    ]

    EncodedStream class >> split: input to: encoding [
	"Answer a pipe with the given input stream (which produces
	 UTF-32 character codes as integers) and whose output is
	 a series of Characters in the required pivot encoding"

	<category: 'private - triangulating'>
	^(encoding = 'UCS-4BE' or: [encoding = 'UTF-32BE']) 
	    ifTrue: 
		[SplitUTF32BE 
		    on: input
		    from: 'UTF-32'
		    to: encoding]
	    ifFalse: 
		[SplitUTF32LE 
		    on: input
		    from: 'UTF-32'
		    to: encoding]
    ]

    EncodedStream class >> compose: input from: encoding [
	"Answer a pipe with the given input stream (which produces
	 Characters in the required pivot encoding) and whose output
	 is a series of integer UTF-32 character codes."

	<category: 'private - triangulating'>
	^(encoding = 'UCS-4BE' or: [encoding = 'UTF-32BE']) 
	    ifTrue: 
		[ComposeUTF32BE 
		    on: input
		    from: encoding
		    to: 'UTF-32']
	    ifFalse: 
		[ComposeUTF32LE 
		    on: input
		    from: encoding
		    to: 'UTF-32']
    ]

    EncodedStream class >> encoding: anUnicodeString [
	"Answer a pipe of encoders that converts anUnicodeString to default
	 encoding for strings (the current locale's default charset if none
	 is specified)."

	<category: 'instance creation'>
	^self encoding: anUnicodeString as: String defaultEncoding
    ]

    EncodedStream class >> encoding: aStringOrStream as: toEncoding [
	"Answer a pipe of encoders that converts anUnicodeString (which contains
	 to the supplied encoding (which can be an ASCII String or Symbol)."

	<category: 'instance creation'>
	"Adopt an uniform naming"

	| pivot to encoderTo pipe |
	to := toEncoding asString.
	(to = 'UTF-32' or: [to = 'UCS-4']) ifTrue: [to := 'UTF-32BE'].
	(to = 'UTF-16' or: [to = 'UCS-2']) ifTrue: [to := 'UTF-16BE'].

	"If converting to the pivot encoding, we're done."
	pivot := ((to startsWith: 'UCS-4') or: [to startsWith: 'UTF-32']) 
		    ifTrue: [to]
		    ifFalse: [self pivotEncoding].
	encoderTo := Iconv.
	EncodersRegistry 
	    do: [:each | ((each at: 1) includes: to) ifTrue: [encoderTo := each at: 3]].
	pipe := aStringOrStream.

	"Split UTF-32 character codes into bytes if needed by iconv."
	encoderTo == Iconv ifTrue: [pipe := self split: pipe to: pivot].

	"If not converting to the pivot encoding, we need one more step."
	to = pivot 
	    ifFalse: 
		[pipe := encoderTo 
			    on: pipe
			    from: pivot
			    to: toEncoding].
	^pipe
    ]

    EncodedStream class >> unicodeOn: aStringOrStream [
	"Answer a pipe of encoders that converts aStringOrStream (which can
	 be a string or another stream) from its encoding (or the current
	 locale's default charset, if the encoding cannot be determined)
	 to integers representing Unicode character codes."

	<category: 'instance creation'>
	^self unicodeOn: aStringOrStream encoding: aStringOrStream encoding
    ]

    EncodedStream class >> unicodeOn: aStringOrStream encoding: fromEncoding [
	"Answer a pipe of encoders that converts aStringOrStream
	 (which can be a string or another stream) from the supplied
	 encoding (which can be an ASCII String or Symbol) to
	 integers representing Unicode character codes."

	<category: 'instance creation'>
	"Adopt an uniform naming"

	| from pivot encoderFrom pipe |
	from := fromEncoding asString.
	(from = 'UTF-32' or: [from = 'UCS-4']) 
	    ifTrue: [from := aStringOrStream utf32Encoding].
	(from = 'UTF-16' or: [from = 'UCS-2']) 
	    ifTrue: [from := aStringOrStream utf16Encoding].
	pivot := 'UTF-32'.
	((from startsWith: 'UCS-4') or: [from startsWith: 'UTF-32']) 
	    ifTrue: [pivot := from].
	pivot = 'UTF-32' ifTrue: [pivot := self pivotEncoding].
	encoderFrom := Iconv.
	EncodersRegistry 
	    do: [:each | ((each at: 1) includes: from) ifTrue: [encoderFrom := each at: 2]].
	pipe := aStringOrStream.

	"If not converting from the pivot encoding, we need one more step."
	from = pivot 
	    ifFalse: 
		[pipe := encoderFrom 
			    on: pipe
			    from: fromEncoding
			    to: pivot].

	"Compose iconv-produced bytes into UTF-32 character codes if needed."
	encoderFrom == Iconv ifTrue: [pipe := self compose: pipe from: pivot].

	"Skip the BOM, if present."
	pipe peekFor: $<16rFEFF>.
	^pipe
    ]

    EncodedStream class >> on: aStringOrStream from: fromEncoding [
	"Answer a pipe of encoders that converts aStringOrStream
	 (which can be a string or another stream) from the given
	 encoding to the default locale's default charset."

	<category: 'instance creation'>
	^self 
	    on: aStringOrStream
	    from: fromEncoding
	    to: String defaultEncoding
    ]

    EncodedStream class >> on: aStringOrStream to: toEncoding [
	"Answer a pipe of encoders that converts aStringOrStream
	 (which can be a string or another stream) from the default
	 locale's default charset to the given encoding."

	<category: 'instance creation'>
	^self 
	    on: aStringOrStream
	    from: aStringOrStream encoding
	    to: toEncoding
    ]

    EncodedStream class >> on: aStringOrStream from: fromEncoding to: toEncoding [
	"Answer a pipe of encoders that converts aStringOrStream
	 (which can be a string or another stream) between the
	 two supplied encodings (which can be ASCII Strings or
	 Symbols)"

	<category: 'instance creation'>
	"Adopt an uniform naming"

	| from pivot to encoderFrom encoderTo pipe |
	from := fromEncoding asString.
	to := toEncoding asString.
	(from = 'UTF-32' or: [from = 'UCS-4']) 
	    ifTrue: [from := aStringOrStream utf32Encoding].
	(from = 'UTF-16' or: [from = 'UCS-2']) 
	    ifTrue: [from := aStringOrStream utf16Encoding].
	(to = 'UTF-32' or: [to = 'UCS-4']) ifTrue: [to := 'UTF-32BE'].
	(to = 'UTF-16' or: [to = 'UCS-2']) ifTrue: [to := 'UTF-16BE'].
	pivot := 'UTF-32'.
	((from startsWith: 'UCS-4') or: [from startsWith: 'UTF-32']) 
	    ifTrue: [pivot := from].
	((to startsWith: 'UCS-4') or: [to startsWith: 'UTF-32']) 
	    ifTrue: [pivot := to].
	pivot = 'UTF-32' ifTrue: [pivot := self pivotEncoding].
	encoderFrom := encoderTo := Iconv.
	EncodersRegistry do: 
		[:each | 
		((each at: 1) includes: to) ifTrue: [encoderTo := each at: 3].
		((each at: 1) includes: from) ifTrue: [encoderFrom := each at: 2]].

	"Let iconv do the triangulation if possible"
	(encoderFrom == Iconv and: [encoderTo == Iconv]) 
	    ifTrue: 
		[^Iconv 
		    on: aStringOrStream
		    from: fromEncoding
		    to: toEncoding].

	"Else answer a `pipe' that takes care of triangulating.
	 There is an additional complication: Smalltalk encoders
	 read or provide a stream of character codes (respectively
	 if the source is UTF-32, or the target is UTF-32), while iconv
	 expects raw bytes.  So we add an intermediate layer if
	 a mixed Smalltalk+iconv conversion is done: it converts
	 character codes --> bytes (SplitUTF32xx, used if iconv will
	 convert from UTF-32) or bytes --> character code (ComposeUTF32xx,
	 used if iconv will convert to UTF-32).
	 
	 There are five different cases (remember that at least one converter
	 is not iconv, so `both use iconv' and `from = pivot = to' are banned):
	 from = pivot    --> Compose + encoderTo
	 pivot = to      --> encoderFrom + Split
	 to uses iconv   --> encoderFrom + Split + iconv (from ~= pivot)
	 from uses iconv --> iconv + Compose + encoderTo (to ~= pivot)
	 none uses iconv --> encoderFrom + encoderTo (implies neither = pivot)"
	pipe := aStringOrStream.
	from = pivot 
	    ifFalse: 
		["Convert to our intermediate representation and split to
		 bytes if needed."

		pipe := encoderFrom 
			    on: pipe
			    from: fromEncoding
			    to: pivot.
		encoderTo == Iconv 
		    ifTrue: 
			[pipe := self split: pipe to: pivot.

			"Check if we already reached the destination format."
			to = pivot ifTrue: [^pipe]]].

	"Compose iconv-produced bytes into UTF-32 character codes if needed."
	encoderFrom == Iconv ifTrue: [pipe := self compose: pipe from: pivot].
	^encoderTo 
	    on: pipe
	    from: pivot
	    to: toEncoding
    ]
]



Namespace current: I18N.Encoders [

Encoder subclass: FromUTF32 [
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is a superclass for classes that convert from UTF-32
characters (encoded as 32-bit Integers) to bytes in another
encoding (encoded as Characters).'>
]

]



Namespace current: I18N.Encoders [

Encoder subclass: ToUTF32 [
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is a superclass for classes that convert from bytes
(encoded as Characters) to UTF-32 characters (encoded as 32-bit
Integers to simplify the code and to avoid endianness conversions).'>

    species [
	"We answer a UnicodeString of Unicode characters encoded as UTF-32."

	<category: 'stream operation'>
	^UnicodeString
    ]
]

]



Namespace current: I18N.Encoders [

ToUTF32 subclass: ComposeUTF32LE [
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is used internally to provide UTF-32 characters encoded as
32-bit integers for a descendent of FromUTF32, when the starting
encoding is little-endian.'>

    next [
	"Answer a 32-bit integer obtained by reading four 8-bit character
	 codes in little-endian order and putting them together"

	<category: 'stream operation'>
	^(self nextInput asInteger + (self nextInput asInteger bitShift: 8) 
	    + (self nextInput asInteger bitShift: 16) 
		+ (self nextInput asInteger bitShift: 24)) asCharacter
    ]
]

]



Namespace current: I18N.Encoders [

ToUTF32 subclass: ComposeUTF32BE [
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is used internally to provide UTF-32 characters encoded as
32-bit integers for a descendent of FromUTF32, when the starting
encoding is big-endian.'>

    next [
	"Answer a 32-bit integer obtained by reading four 8-bit character
	 codes in big-endian order and putting them together"

	"This code attempts to create as few large integers as possible"

	<category: 'stream operation'>
	^((((((self nextInput asInteger bitShift: 8) 
	    bitOr: self nextInput asInteger) bitShift: 8) 
	    bitOr: self nextInput asInteger) bitShift: 8) 
	    bitOr: self nextInput asInteger) asCharacter
    ]
]

]



Namespace current: I18N.Encoders [

FromUTF32 subclass: SplitUTF32LE [
    | wch |
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is used internally to split into four 8-bit characters
the 32-bit UTF-32 integers coming from a descendent of ToUTF32, when
the destination encoding is little-endian.'>

    atEnd [
	"Answer whether the receiver can produce more characters"

	<category: 'stream operation'>
	^wch == 1 and: [self atEndOfInput]
    ]

    next [
	"Answer an 8-bit Character obtained by converting each 32-bit
	 Integer found in the origin to the four bytes that make it up,
	 and ordering them from the least significant to the most
	 significant."

	<category: 'stream operation'>
	| answer |
	wch == 1 
	    ifTrue: 
		["Answer the LSB.  This code will create as few LargeIntegers
		 as possible by setting the mark bit only after the LSB has
		 been extracted."

		wch := answer := self nextInput codePoint.
		wch := (wch bitShift: -8) + 16777216.
		^Character value: (answer bitAnd: 255)].

	"Answer any other byte"
	answer := wch bitAnd: 255.
	wch := wch bitShift: -8.
	^Character value: answer
    ]

    flush [
	"Flush any remaining bytes in the last 32-bit character read from
	 the input"

	<category: 'stream operation'>
	wch := 1
    ]
]

]



Namespace current: I18N.Encoders [

FromUTF32 subclass: SplitUTF32BE [
    | count wch |
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is used internally to split into four 8-bit characters
the 32-bit UTF-32 integers coming from a descendent of ToUTF32, when
the destination encoding is big-endian.'>

    atEnd [
	"Answer whether the receiver can produce more characters"

	<category: 'stream operation'>
	^count == 0 and: [self atEndOfInput]
    ]

    next [
	"Answer an 8-bit Character obtained by converting each 32-bit
	 Integer found in the origin to the four bytes that make it up,
	 and ordering them from the most significant to the least
	 significant."

	<category: 'stream operation'>
	| answer |
	count == 0 
	    ifTrue: 
		["Answer the MSB.  This code will create as few LargeIntegers
		 as possible by discarding the bits we answer and operating
		 on SmallIntegers once only bits 0..23 remain."

		wch := answer := self nextInput codePoint.
		wch := wch bitAnd: 16777215.
		count := 3.
		^Character value: (answer bitShift: -24)].

	"Answer any other byte.  We keep things so that the byte we answer
	 is always in bits 16..23 when we arrive here."
	answer := wch bitShift: -16.
	wch := wch bitAnd: 65535.
	wch := wch bitShift: 8.
	count := count - 1.
	^Character value: answer
    ]

    flush [
	"Flush any remaining bytes in the last 32-bit character read from
	 the input"

	<category: 'stream operation'>
	count := 0
    ]
]

]



Namespace current: I18N.Encoders [

Encoder subclass: Iconv [
    | iconvHandle readBuffer readPos readEnd recodedBuffer recodedPos recodedEnd |
    
    <category: 'i18n-Character sets'>
    <comment: 'This class is used to delegate the actual character set conversion
to the C library''s iconv function.  Most conversions use iconv as
the only step in the conversions, sometimes the structure is 
ToUTF32+SplitUTF32xx+Iconv or Iconv+ComposeUTF32xx+FromUTF32, rarely
Iconv is skipped altogether and only Smalltalk converters are used.'>

    Iconv class >> initialize [
	<category: 'private - living across snapshots'>
	ObjectMemory addDependent: self
    ]

    Iconv class >> update: aspect [
	<category: 'private - living across snapshots'>
	aspect == #aboutToSnapshot
	    ifTrue: [self allInstancesDo: [:each | each release]]
    ]

    iconvOpen: to from: from [
	<category: 'C call-outs'>
	<cCall: 'iconv_open' returning: #cObject args: #(#string #string)>
	
    ]

    iconvClose: handle [
	<category: 'C call-outs'>
	<cCall: 'iconv_close' returning: #void args: #(#cObject)>
	
    ]

    iconvOn: handle from: readBuffer at: readPos size: readCount to: writeBuffer size: writeCount state: bytesLeft [
	<category: 'C call-outs'>
	<cCall: 'iconvWrapper' returning: #boolean
	args: #(#cObject #smalltalk #int #int #smalltalk #int #smalltalk)>
	
    ]

    atEnd [
	"Answer whether the receiver can produce more characters"

	<category: 'stream operation'>
	^self atEndOfBuffer and: [self convertMore]
    ]

    next [
	"Answer the next character that the receiver can produce."

	<category: 'stream operation'>
	| answer |
	(self atEndOfBuffer and: [self convertMore])
	    ifTrue: [^self pastEnd].
	answer := recodedBuffer at: recodedPos.
	recodedPos := recodedPos + 1.
	^answer
    ]

    nextAvailable: anInteger putAllOn: aStream [
	"Copy up to anInteger bytes from the next buffer's worth of data
	 from the receiver to aStream."

	<category: 'stream operation'>
	| n |
	(self atEndOfBuffer and: [self convertMore])
	    ifTrue: [^self pastEnd].
	n := anInteger min: recodedEnd - recodedPos + 1.
	aStream
	    next: n
	    putAll: recodedBuffer
	    startingAt: recodedPos.
	recodedPos := recodedPos + n.
	^n
    ]

    nextAvailable: anInteger into: aCollection startingAt: pos [
	"Store up to anInteger bytes from the next buffer's worth of data
	 from the receiver onto aCollection."

	<category: 'stream operation'>
	| n |
	(self atEndOfBuffer and: [self convertMore])
	    ifTrue: [^self pastEnd].
	n := anInteger min: recodedEnd - recodedPos + 1.
	aCollection
	    replaceFrom: pos to: pos + n - 1
	    with: recodedBuffer
	    startingAt: recodedPos.
	recodedPos := recodedPos + n.
	^n
    ]

    release [
	<category: 'private - living across snapshots'>
	self
	    removeToBeFinalized;
	    finalize
    ]

    finalize [
	<category: 'private - living across snapshots'>
	iconvHandle isNil ifTrue: [^self].
	self iconvClose: iconvHandle.
	iconvHandle := nil
    ]

    iconvOpen [
	<category: 'private - living across snapshots'>
	iconvHandle isNil ifFalse: [self release].
	iconvHandle := self iconvOpen: to from: from.
	iconvHandle address = 4294967295 
	    ifTrue: [^InvalidCharsetError signal: 
			{from.
			to}].
	self addToBeFinalized.
    ]

    atEndOfBuffer [
	"Answer whether we ate all the characters that iconv had
	 converted to the destination encoding."

	<category: 'private - conversion'>
	^recodedPos > recodedEnd
    ]

    refill [
	"Make it so that iconv will always have a decent number of
	 characters to convert, by keeping the number of used
	 bytes in the read buffer above bufferSize-refillThreshold"

	<category: 'private - conversion'>
	| data |
	readPos > self refillThreshold 
	    ifTrue: 
		[readBuffer 
		    replaceFrom: 1
		    to: readEnd - readPos + 1
		    with: readBuffer
		    startingAt: readPos.
		readEnd := readEnd - readPos + 1.
		readPos := 1].

	readEnd := readEnd + (self
	    nextInputAvailable: self bufferSize - readEnd
	    into: readBuffer
	    startingAt: readEnd + 1).
    ]

    initializeFrom: fromEncoding to: toEncoding origin: aStringOrStream [
	<category: 'private - conversion'>
	super 
	    initializeFrom: fromEncoding
	    to: toEncoding
	    origin: aStringOrStream.
	readPos := 1.
	readEnd := 0.
	recodedPos := 1.
	recodedEnd := 0
    ]

    bufferSize [
	"Answer the size of the buffers we pass to iconv"

	<category: 'private - conversion'>
	^1024
    ]

    refillThreshold [
	"Answer the threshold for readPos (the first unused
	 byte in the input buffer), above which we read
	 more characters from the input."

	<category: 'private - conversion'>
	^1000
    ]

    initBuffers [
	"Initialize the input and output buffer for icode"

	<category: 'private - conversion'>
	readBuffer := String new: self bufferSize.
	recodedBuffer := String new: self bufferSize
    ]

    convertMore [
	<category: 'private - conversion'>
	| oldReadPos bytesLeft fine |
	recodedBuffer isNil ifTrue: [self initBuffers].
	readBuffer isNil ifTrue: [^true].
	iconvHandle isNil ifTrue: [self iconvOpen].
	self refill.
	bytesLeft := Array new: 2.
	fine := self 
		    iconvOn: iconvHandle
		    from: readBuffer
		    at: readPos
		    size: readEnd - readPos + 1
		    to: recodedBuffer
		    size: self bufferSize
		    state: bytesLeft.
	oldReadPos := readPos.
	readPos := readEnd + 1 - (bytesLeft at: 1).
	recodedEnd := self bufferSize - (bytesLeft at: 2).
	recodedPos := 1.
	fine ifFalse: [InvalidSequenceError signal. ^true].
	readPos > readEnd ifFalse: [
	    readPos = oldReadPos ifTrue: [ IncompleteSequenceError signal ].
	    ^readPos = oldReadPos ].
	self atEndOfInput ifFalse: [^false].

	"At end of input, check whether the last character was complete."
	readBuffer := nil.
	^recodedEnd = 0
    ]
]

]

"Now add some extensions to the system classes"



Namespace current: I18N [
    (String classPool includesKey: #DefaultEncoding) 
	ifFalse: [String addClassVarName: #DefaultEncoding]
]



String class extend [

    defaultDefaultEncoding [
	"Answer the encoding that is used in case the user specifies none."

	<category: 'converting'>
	^'UTF-8'
    ]

    defaultEncoding [
	"Answer the default encoding that is used for transcoding."

	<category: 'converting'>
	DefaultEncoding isNil ifTrue: [^self defaultDefaultEncoding].
	^DefaultEncoding
    ]

    defaultEncoding: aString [
	"Answer the default locale's default charset"

	<category: 'converting'>
	DefaultEncoding := aString
    ]

]



CharacterArray extend [

    asString: aString [
	"Return a String with the contents of the receiver, converted
	 into the aString locale character set."

	<category: 'multibyte encodings'>
	^(I18N.EncodedStream 
	    on: self
	    from: self encoding
	    to: aString) contents
    ]

    asUnicodeString [
	"Return an UnicodeString with the contents of the receiver, interpreted
	 as the default locale character set."

	<category: 'multibyte encodings'>
	^(I18N.EncodedStream unicodeOn: self) contents
    ]

    numberOfCharacters [
	"Answer the number of Unicode characters in the receiver, interpreting it
	 as the default locale character set."

	<category: 'multibyte encodings'>
	^self asUnicodeString numberOfCharacters
    ]

]



String extend [

    numberOfCharacters: aString [
	"Answer the number of Unicode characters in the receiver, interpreting it
	 in the character encoding aString."

	<category: 'multibyte encodings'>
	^(self asUnicodeString: aString) numberOfCharacters
    ]

    asUnicodeString: aString [
	"Return an UnicodeString with the contents of the receiver, interpreted
	 as the default locale character set."

	<category: 'multibyte encodings'>
	^(I18N.EncodedStream unicodeOn: self encoding: aString) contents
    ]

    encoding [
	"Answer the encoding of the receiver, assuming it is in the
	 default locale's default charset"

	<category: 'converting'>
	| encoding |
	(self size >= 4 and: 
		[(self valueAt: 1) = 0 and: 
			[(self valueAt: 2) = 0 
			    and: [(self valueAt: 3) = 254 and: [(self valueAt: 4) = 255]]]]) 
	    ifTrue: [^'UTF-32BE'].
	(self size >= 4 and: 
		[(self valueAt: 4) = 0 and: 
			[(self valueAt: 3) = 0 
			    and: [(self valueAt: 2) = 254 and: [(self valueAt: 1) = 255]]]]) 
	    ifTrue: [^'UTF-32LE'].
	(self size >= 2 
	    and: [(self valueAt: 1) = 254 and: [(self valueAt: 2) = 255]]) 
		ifTrue: [^'UTF-16BE'].
	(self size >= 2 
	    and: [(self valueAt: 2) = 254 and: [(self valueAt: 1) = 255]]) 
		ifTrue: [^'UTF-16LE'].
	(self size >= 3 and: 
		[(self valueAt: 1) = 239 
		    and: [(self valueAt: 2) = 187 and: [(self valueAt: 3) = 191]]]) 
	    ifTrue: [^'UTF-8'].
	encoding := self class defaultEncoding.
	encoding asString = 'UTF-16' ifTrue: [^self utf16Encoding].
	encoding asString = 'UTF-32' ifTrue: [^self utf32Encoding].
	^encoding
    ]

    utf32Encoding [
	"Assuming the receiver is encoded as UTF-16 with a proper
	 endianness marker, answer the correct encoding of the receiver."

	<category: 'converting'>
	(self size >= 4 and: 
		[(self valueAt: 4) = 0 and: 
			[(self valueAt: 3) = 0 
			    and: [(self valueAt: 2) = 254 and: [(self valueAt: 1) = 255]]]]) 
	    ifTrue: [^'UTF-32LE'].
	^'UTF-32BE'
    ]

    utf16Encoding [
	"Assuming the receiver is encoded as UTF-16 with a proper
	 endianness marker, answer the correct encoding of the receiver."

	<category: 'converting'>
	(self size >= 2 
	    and: [(self valueAt: 2) = 254 and: [(self valueAt: 1) = 255]]) 
		ifTrue: [^'UTF-16LE'].
	^'UTF-16BE'
    ]

]



UnicodeCharacter extend [

    asString [
	"Return a String with the contents of the receiver, converted
	 into the default locale character set."

	<category: 'converting'>
	^(I18N.EncodedStream encoding: (UnicodeString with: self)) contents
    ]

    asString: encoding [
	"Return a String with the contents of the receiver, converted
	 into the requested encoding."

	<category: 'converting'>
	^(I18N.EncodedStream encoding: (UnicodeString with: self) as: encoding) 
	    contents
    ]

    asUnicodeString [
	"Return a UnicodeString with the contents of the receiver, converted
	 from the default locale character set.  Raise an exception if the
	 receiver is not a valid 1-byte character in the given character set."

	<category: 'converting'>
	^UnicodeString with: self
    ]

    asUnicodeString: encoding [
	<category: 'converting'>
	self shouldNotImplement
    ]

]



Character extend [

    asString: encoding [
	"Return a String with the contents of the receiver, interpreted
	 into the requested encoding."

	<category: 'converting'>
	^I18N.EncodedString fromString: (String with: self) encoding: encoding
    ]

    asString [
	"Return a String with the contents of the receiver, converted
	 into the default locale character set."

	<category: 'converting'>
	^String with: self
    ]

    asUnicodeString [
	"Return a UnicodeString with the contents of the receiver, converted
	 from the default locale character set.  Raise an exception if the
	 receiver is not a valid 1-byte character in the given character set."

	<category: 'converting'>
	^(String with: self) asUnicodeString
    ]

    asUnicodeString: encoding [
	"Return a UnicodeString with the contents of the receiver, converted
	 from the given character set.  Raise an exception if the receiver
	 is not a valid 1-byte character in the given character set."

	<category: 'converting'>
	^(String with: self) asUnicodeString: encoding
    ]

]



UnicodeCharacter extend [

    displayOn: aStream [
	"Print a representation of the receiver on aStream. Unlike
	 #printOn:, this method does not display a leading dollar."

	<category: 'printing'>
	aStream isUnicode 
	    ifTrue: [aStream nextPut: self]
	    ifFalse: [aStream nextPutAll: self asString]
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	aStream nextPut: $$.
	self displayOn: aStream
    ]

]



ByteArray extend [

    asString: aString [
	"Return a String with the contents of the receiver, interpreted
	 as the locale character set given by aString."

	<category: 'converting'>
	^self asString asUnicodeString
    ]

    asUnicodeString [
	"Return an UnicodeString with the contents of the receiver, interpreted
	 as the default locale character set."

	<category: 'converting'>
	^self asString asUnicodeString
    ]

    asUnicodeString: aString [
	"Return an UnicodeString with the contents of the receiver, interpreted
	 as the default locale character set."

	<category: 'converting'>
	^self asString asUnicodeString: aString
    ]

]



UnicodeString extend [

    asString [
	"Return a String with the contents of the receiver, converted
	 into the default locale character set."

	<category: 'converting'>
	^(I18N.EncodedStream encoding: self) contents
    ]

    asString: aString [
	"Return a String with the contents of the receiver, converted
	 into the aString locale character set."

	<category: 'converting'>
	^(I18N.EncodedStream encoding: self as: aString) contents
    ]

    displayOn: aStream [
	"Print a representation of the receiver on aStream. Unlike
	 #displayOn:, this method does not include quotes."

	<category: 'converting'>
	aStream isUnicode 
	    ifTrue: [aStream nextPutAll: self]
	    ifFalse: [self asString displayOn: aStream]
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'converting'>
	aStream isUnicode 
	    ifTrue: 
		[aStream nextPut: $'.
		aStream nextPutAll: (self copyReplaceAll: '''' with: '''''').
		aStream nextPut: $']
	    ifFalse: [self asString printOn: aStream]
    ]

]



PositionableStream extend [

    encoding [
	"Answer the encoding of the underlying collection"

	<category: 'converting'>
	^collection encoding
    ]

    utf16Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-16"

	<category: 'converting'>
	^collection utf16Encoding
    ]

    utf32Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-32"

	<category: 'converting'>
	^collection utf32Encoding
    ]

]



Stream extend [

    utf16Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-16"

	<category: 'converting'>
	^'UTF-16BE'
    ]

    utf32Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-32"

	<category: 'converting'>
	^'UTF-32BE'
    ]

]



FileDescriptor extend [

    encoding [
	"Answer the encoding that is used when storing Unicode characters."

	<category: 'converting'>
	^self species defaultEncoding
    ]

    utf16Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-16.
	 Return big-endian UTF-16 since that's the default."

	<category: 'converting'>
	^'UTF-16BE'
    ]

    utf32Encoding [
	"Answer the encoding of the underlying collection, assuming it's UTF-32.
	 Return big-endian UTF-32 since that's the default."

	<category: 'converting'>
	^'UTF-32BE'
    ]

]



Namespace current: I18N [
    Encoders.Iconv initialize.
    EncodedStream initialize
]

PK
     �Mh@iͬW{,  {,    UTF7.stUT	 dqXOR�XOux �  �  "======================================================================
|
|   Base encodings including Unicode (ISO10646)
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2002, 2005, 2006, 2007, 2008 Free Software Foundation, Inc.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Namespace current: I18N.Encoders [

FromUTF32 subclass: ToUTF7 [
    | left value lookahead |
    
    <category: 'i18n-Encodings'>
    <comment: 'This class implements a converter that transliterates UTF-7
encoded characters to UTF-32 values (encoded as 32-bit Integers).'>

    Base64Characters := nil.
    DirectCharacters := nil.
    ToBase64 := nil.

    ToUTF7 class >> initialize [
	"Initialize the tables used by the UTF-32-to-UTF-7 converter"

	<category: 'initialization'>
	Base64Characters := #[0 0 0 0 0 168 255 3 254 255 255 7 254 255 255 7].

	"Table of direct characters"
	DirectCharacters := #[0 38 0 0 129 243 255 135 254 255 255 7 254 255 255 7].
	ToBase64 := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    ]

    isBase64: anInteger [
	<category: 'private'>
	| d |
	^anInteger < 128 and: 
		[d := Base64Characters at: anInteger // 8 + 1.
		((d bitShift: 0 - (anInteger \\ 8)) bitAnd: 1) == 1]
    ]

    isDirect: anInteger [
	<category: 'private'>
	| d |
	^anInteger < 128 and: 
		[d := DirectCharacters at: anInteger // 8 + 1.
		((d bitShift: 0 - (anInteger \\ 8)) bitAnd: 1) == 1]
    ]

    toBase64Char: anInteger [
	<category: 'private'>
	^ToBase64 at: anInteger + 1
    ]

    atEnd [
	"Answer whether the receiver can produce more characters"

	<category: 'conversion'>
	^left == 0 and: [self atEndOfInput]
    ]

    flush [
	"Flush any remaining bytes in the last 32-bit character read from
	 the input"

	<category: 'conversion'>
	left := 0
    ]

    next [
	"Answer the next character that the receiver can produce."

	<category: 'conversion'>
	| ch next |
	left = 0 
	    ifTrue: 
		["Base64 encoding inactive"

		ch := self nextInput codePoint.
		(self isDirect: ch) ifTrue: [^ch asCharacter].
		ch = 43 
		    ifTrue: 
			[left := -256.
			lookahead := $-.
			^$+].
		ch < 65536 
		    ifTrue: 
			[left := 16.
			value := ch.
			^$+].
		"ch >= 1114112 ifTrue: [InvalidSequenceError signal]."

		"Convert to a surrogate pair.  First character is always $2.
                 Compare with the other surrogate pair case below."
		left := ##(26 bitOr: -256).
		lookahead := 50. "(self toBase64: 16r36) asInteger"
		value := ((ch bitAnd: 16r1FFFC00) bitShift: 6)
                            + (ch bitAnd: 16r3FF)
			    + ##(16rDC00 - 16r400000).
		^$+].
	left < 0 
	    ifTrue: 
		["if at end of input output -.  otherwise:
		 left = -256..-1 ---> output the lookahead character and go to
                 (left bitAnd: 255).
		 left = -512 ---> if there's no lookahead, output $-.  if there
                 is lookahead and $- needed, output $- and go to -256; if there
                 is lookahead but no $- needed, output lookahead and go to 0"

		lookahead isNil 
		    ifTrue: 
			[left := 0.
			self atEndOfInput ifTrue: [^$-]]
		    ifFalse: 
			[ch := lookahead.
			^(left = -512 and: [self isBase64: ch]) 
			    ifTrue: 
				[left := -256.
				$-]
			    ifFalse: 
				[lookahead := nil.
				left := left bitAnd: 255.
				ch asCharacter]]].
	left < 6 
	    ifTrue: 
		["Pump another character into the Base64 encoder"

		(self atEndOfInput or: [self isDirect: (ch := self nextInput codePoint)]) 
		    ifTrue: 
			[lookahead := ch.
			left = 0 ifTrue: [left := -256. ^$-].
			"Terminate the stream by left-aligning the last byte"
			value := value bitShift: 6 - left.
			left := 6]
		    ifFalse: 
			[ch < 65536 
			    ifTrue: 
				[left := left + 16.
				value := (value bitShift: 16) + ch]
			    ifFalse: 
				["ch >= 1114112 ifTrue: [InvalidSequenceError signal]."

                                "Inline the computation of the next base64
                                 character to avoid creating LargeIntegers.
                                 16r36 is the high 6 bits of 16rD800.  Bits
                                 that do not fit in `next' are placed in
                                 `value' below (with 16r18000000 bitAnd: ...)."
                                next := ((value bitShift: 6) + 16r36) bitShift: 0 - left.
                                "Here 16rD8000000 would be necessary, but we
                                 know left > 0 so the first two bits will never
                                 be used.  This avoids LargeInteger math."
                                value := (16r18000000 bitAnd: (16r3C00000 bitShift: left))
				         + ((ch bitAnd: 16r1FFC00) bitShift: 6)
                                         + (ch bitAnd: 16r3FF)
					 + ##(16rDC00 - 16r400000).

				left := left + 26.
                                ^self toBase64Char: next]]].

	"Take 6 bits out of the Base-64 encoded stream"
	left := left - 6.
	next := value bitShift: 0 - left.
	value := value bitXor: (next bitShift: left).

	"Exit base64 if at end of input or next char is direct."
	left = 0 ifTrue: [left := -512].
	^self toBase64Char: next
    ]
]

]



Namespace current: I18N.Encoders [

ToUTF32 subclass: FromUTF7 [
    | shift wch lookahead |
    
    <category: 'i18n-Encodings'>
    <comment: nil>

    DirectCharacters := nil.
    FromBase64 := nil.

    FromUTF7 class >> initialize [
	"Initialize the tables used by the UTF-7-to-UTF-32 converter"

	<category: 'initialization'>
	FromBase64 := #[62 99 99 99 63 52 53 54 55 56 57 58 59 60 61 99 99 99 99 99 99 99 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 99 99 99 99 99 99 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51].
	DirectCharacters := #[0 38 0 0 255 247 255 255 255 255 255 239 255 255 255 63 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
    ]

    isDirect: anInteger [
	<category: 'private'>
	| d |
	^anInteger < 128 and: 
		[d := DirectCharacters at: anInteger // 8 + 1.
		((d bitShift: 0 - (anInteger \\ 8)) bitAnd: 1) == 1]
    ]

    fromBase64Char: aCharacter [
	<category: 'private'>
	^FromBase64 at: aCharacter - 42
    ]

    atEnd [
	"Answer whether the receiver can produce another UTF-32 32-bit
	 encoded integer"

	<category: 'converting'>
	^lookahead isNil
    ]

    next [
	"Answer the next character that the receiver can produce."

	<category: 'converting'>
	| ch |
	lookahead isNil 
	    ifTrue: 
		[SystemExceptions.EndOfStream signal: self.
		^nil].
	ch := lookahead.
	self getNext.
	^ch
    ]

    flush [
	"Flush any remaining state left in the encoder by the last character
	 (this is because UTF-7 encodes 6 bits at a time, so it takes three
	 characters before it can provide a single 16-bit character and
	 up to six characters before it can provide a full UTF-32 character)."

	<category: 'converting'>
	shift := -6.
	wch := 0.
	self getNext
    ]

    getNext [
	<category: 'private - converting'>
	
	[self atEndOfInput 
	    ifTrue: 
		[(shift = -6 or: [shift = 10]) 
		    ifFalse: 
			[shift := -6.
			wch := 0.
			InvalidSequenceError signal].
		lookahead := nil.
		^self].
	(lookahead := self readNext) isNil] 
		whileTrue
    ]

    readNext [
	"The decoder will always decode a character ahead, because when we
	 are to read only a minus, we might already be at the end of the
	 stream! Here is a simple example: +AFs- which decodes to [
	 We read + and switch to base-64 --> shift = 10
	 We read A and put it into the accumulator --> shift = 4
	 We read F and put it into the accumulator --> shift = -2 *next is last*
	 We read s and put it into the accumulator --> shift = 8
	 
	 We then decode the [ and return it.  Now we are not
	 #atEndOfInput yet, but there are no more characters to
	 give away!  Since we are not sure that the source supports
	 #peek, our only other option would be to implement peeking
	 for it and check for $- now.  This would have an overhead
	 proportional to the number of input characters (to check
	 whether we have already peeked the next characters), while
	 our choice's overhead is proportional to the number of output
	 characters, which is always less in UTF-7."

	<category: 'private - converting'>
	| ch value wc1 |
	ch := self nextInput value.
	shift = -6 
	    ifTrue: 
		[(self isDirect: ch) ifTrue: [^Character codePoint: ch].
		ch == 43 
		    ifFalse: 
			["plus"

			InvalidSequenceError signal].
		ch := self nextInput value.
		ch == 45 
		    ifTrue: 
			["minus"

			^$+].

		"Else switch into base64 mode"
		shift := 10].
	((ch between: 43 and: 122) and: [(value := self fromBase64Char: ch) < 99]) 
	    ifFalse: 
		["Terminate base64 encoding.
		 If accumulated data is nonzero, the input is invalid.
		 Also, partial UTF-16 characters are invalid."

		(shift <= 4 or: [wch > 0]) 
		    ifTrue: 
			[shift := -6.
			wch := 0.
			InvalidSequenceError signal].
		shift := -6.

		"Discard a -"
		ch = 45 
		    ifTrue: 
			["minus"

			^nil].
		(self isDirect: ch) ifFalse: [InvalidSequenceError signal].
		^Character codePoint: ch].
	shift > 0 
	    ifTrue: 
		["Concatenate the base64 integer value to the accumulator"

		wch := wch + (value bitShift: shift).
		shift := shift - 6.
		^nil].
	wc1 := wch + (value bitShift: shift).
	wch := (value bitShift: shift + 16) bitAnd: 16rFC00.
	shift := shift + 10.
	wc1 < 16rD800 ifTrue: [^Character codePoint: wc1].
	wc1 < 16rDC00 
	    ifTrue: 
		["After a High Surrogate, leave bits 20..10 of the Unicode
                  character being encoded in bits 26..16 of wch; the offset
                  wc1 - D7C0 = wc1 - D800 + (16r10000 bitShift: -10).  Then
                  wait for the Low Surrogate."

		wch := wch + ((wc1 - 16rD7C0) bitShift: 16).
		^nil].
	wc1 <= 16rDFFF ifTrue: [^InvalidSequenceError signal].
	wc1 <= 16rFFFF ifTrue: [^Character codePoint: wc1].

	"We have read the UTF-16 element after an High Surrogate.  Verify that
	 it is is indeed a Low Surrogate, and return the resulting character."
	((wc1 bitAnd: 16rFFFF) between: 16rDC00 and: 16rDFFF)
	    ifFalse: [^InvalidSequenceError signal].
	wc1 := ((wc1 bitAnd: 16r7FF0000) bitShift: -6) + (wc1 bitAnd: 16r3FF).
	^Character codePoint: wc1
    ]
]

]

Namespace current: I18N [
    Encoders.ToUTF7 initialize.
    Encoders.FromUTF7 initialize.
    EncodedStream
	registerEncoderFor: #('UTF7' 'UTF-7')
	toUTF32: Encoders.FromUTF7
	fromUTF32: Encoders.ToUTF7
]
PK
     �Mh@���i$  i$    iconvtests.stUT	 dqXOR�XOux �  �  "======================================================================
|
|   Iconv module unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini and Stephen Compall
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



TestCase subclass: IconvTest [
    
    <comment: nil>
    <category: 'Examples-Useful'>

    testStringNumberOfCharacters [
	<category: 'test'>
	self assert: ($<16r0438> asString: 'UTF-8') numberOfCharacters = 1.
	self assert: ($<16rFFFE> asString: 'UTF-8') numberOfCharacters = 1.
	self 
	    assert: ((UnicodeString new: 10) atAllPut: $<16r0438>) asString 
		    numberOfCharacters = 10
    ]

    testUnicodeStringNumberOfCharacters [
	<category: 'test'>
	self assert: $<16r0438> asUnicodeString numberOfCharacters = 1.
	self assert: $<16rFFFE> asUnicodeString numberOfCharacters = 1.
	self 
	    assert: ((UnicodeString new: 10) atAllPut: $<16r0438>) numberOfCharacters 
		    = 10
    ]

    testUnicodeCharAsStringColon [
	<category: 'test'>
	self assert: ($<16r0438> asString: 'UTF-8') = #[208 184] asString.
	self assert: ($<16rFFFE> asString: 'UTF-8') = #[239 191 190] asString.
	self assert: ($<16r0438> asString: 'KOI8-R') first value = 201.
	self assert: ($<16r0438> asString: 'KOI8-R') first class = Character.
	self deny: ($<16r0438> asString: 'KOI8-R') first = $<16r00C9>
    ]

    testEncodedStringSize [
	<category: 'test'>
	| str |
	str := EncodedString fromString: (String with: (Character value: 233))
		    encoding: 'KOI8-R'.
	self assert: str size = 1.
	str := EncodedString fromString: #[216 0 220 0] asString
		    encoding: 'UTF-16BE'.
	self assert: str size = 4
    ]

    testEncodedStringNumberOfCharacters [
	<category: 'test'>
	| str |
	str := EncodedString fromString: (String with: (Character value: 233))
		    encoding: 'KOI8-R'.
	self assert: str numberOfCharacters = 1.
	str := EncodedString fromString: #[216 0 220 0] asString
		    encoding: 'UTF-16BE'.
	self assert: str numberOfCharacters = 1.

	"Test that the BOM is skipped for both big- and little-endian UTF-16."
	str := EncodedString fromString: (String new: 2) encoding: 'UTF-16'.
	str valueAt: 1 put: 254; valueAt: 2 put: 255.
	self assert: str numberOfCharacters = 0.
	str valueAt: 1 put: 255; valueAt: 2 put: 254.
	self assert: str numberOfCharacters = 0
    ]

    testEncodedStringAsUnicodeString [
	<category: 'test'>
	| str |
	str := EncodedString fromString: (String with: (Character value: 233))
		    encoding: 'KOI8-R'.
	self assert: str asUnicodeString first = $<16r0418>
    ]

    testCharAsStringColon [
	<category: 'test'>
	| ch |
	ch := Character value: 233.
	self assert: (ch asString: 'KOI8-R') encoding = 'KOI8-R'.
	self deny: (ch asString: 'KOI8-R') = (ch asString: 'ISO-8859-1')
    ]

    testCharAsUnicodeStringColon [
	<category: 'test'>
	| ch |
	ch := Character value: 233.
	self assert: (ch asUnicodeString: 'KOI8-R') first = $<16r0418>
    ]

    testStringAsUnicodeStringColon [
	<category: 'test'>
	| str |
	str := (Character value: 233) asString.
	self assert: (str asUnicodeString: 'KOI8-R') first = $<16r0418>.
	self assert: (str asUnicodeString: 'ISO-8859-1') first = $<16r00E9>.
	str := #[239 191 190] asString.
	self assert: (str asUnicodeString: 'UTF-8') first = $<16rFFFE>.
	str := #[208 184] asString.
	self assert: (str asUnicodeString: 'UTF-8') first = $<16r0438>.
	self assert: ('' asUnicodeString: 'UTF-8') isEmpty
    ]

    testByteArrayAsUnicodeStringColon [
	<category: 'test'>
	| str |
	str := #[233].
	self assert: (str asUnicodeString: 'KOI8-R') first = $<16r0418>.
	self assert: (str asUnicodeString: 'ISO-8859-1') first = $<16r00E9>.
	str := #[239 191 190].
	self assert: (str asUnicodeString: 'UTF-8') first = $<16rFFFE>.
	str := #[208 184].
	self assert: (str asUnicodeString: 'UTF-8') first = $<16r0438>.
	self assert: (#[] asUnicodeString: 'UTF-8') isEmpty
    ]

    testFromUTF7 [
	<category: 'test'>
	| str |
	self assert: ('+-' asUnicodeString: 'UTF-7') first = $+.
	self assert: ('+BBg-' asUnicodeString: 'UTF-7') first = $<16r0418>.
	self assert: ('+BBgEOA-' asUnicodeString: 'UTF-7') second = $<16r0438>.
	self assert: ('+BBgEOAQZ-' asUnicodeString: 'UTF-7') third = $<16r0419>.
	self assert: ('+2//f/w-' asUnicodeString: 'UTF-7') size = 1.
	self assert: ('+2//f/w-' asUnicodeString: 'UTF-7') first = $<16r10FFFF>.
	self assert: ('+BDjb/9//-' asUnicodeString: 'UTF-7') size = 2.
	self assert: ('+BDjb/9//-' asUnicodeString: 'UTF-7') last = $<16r10FFFF>.
	self assert: ('+BDgEGNv/3/8-' asUnicodeString: 'UTF-7') size = 3.
	self 
	    assert: ('+BDgEGNv/3/8-' asUnicodeString: 'UTF-7') last = $<16r10FFFF>.

	"Test exiting Base64 mode with a non-Base64 character."
	str := 'A+ImIDkQ.' asUnicodeString: 'UTF-7'.
	self assert: str size = 4.
	self assert: str first = $A.
	self assert: str second = $<16r2262>.
	self assert: str third = $<16r0391>.
	self assert: str last = $..

	"Test handling of optional direct characters."
	self shouldnt: ['#' asUnicodeString: 'UTF-7'] raise: InvalidSequenceError.
	self should: ['\' asUnicodeString: 'UTF-7'] raise: InvalidSequenceError.
	self should: ['~' asUnicodeString: 'UTF-7'] raise: InvalidSequenceError.
	self should: ['+BBgA' asUnicodeString: 'UTF-7'] raise: InvalidSequenceError.
	self should: ['+BBg\' asUnicodeString: 'UTF-7'] raise: InvalidSequenceError
    ]

    testToUTF7 [
	<category: 'test'>
	| str |
	self assert: ((UnicodeString with: $+) asString: 'UTF-7') asString = '+-'.
	str := UnicodeString with: $<16r0418>.
	self assert: (str asString: 'UTF-7') encoding = 'UTF-7'.
	self assert: (str asString: 'UTF-7') asString = '+BBg-'.
	self assert: ((str copyWith: $.) asString: 'UTF-7') asString = '+BBg.'.
	self assert: ((str copyWith: $-) asString: 'UTF-7') asString = '+BBg--'.
	self assert: ((str copyWith: $A) asString: 'UTF-7') asString = '+BBg-A'.
	str := str copyWith: $<16r0438>.
	self assert: (str asString: 'UTF-7') asString = '+BBgEOA-'.
	str := str copyWith: $<16r0419>.
	self assert: (str asString: 'UTF-7') asString = '+BBgEOAQZ-'.
	str := UnicodeString with: $<16r10FFFE>.
	self assert: (str asString: 'UTF-7') asString = '+2//f/g-'.
	str := (UnicodeString with: $<16r0438>), str.
	self assert: (str asString: 'UTF-7') asString = '+BDjb/9/+-'.
	str := (UnicodeString with: $<16r0438>), str.
	self assert: (str asString: 'UTF-7') asString = '+BDgEONv/3/4-'.

	"Test that, if there are no bits left to emit, we exit base64 immediately."
	str := UnicodeString with: $<12376> with: $<12435> with: $\ with: $u.
	self assert: (str asString: 'UTF-7') asString = '+MFgwkwBc-u'
    ]

    testRoundTrip [
	<category: 'test'>
	| s |
	s := String new: 1 withAll: $x.
	self assert: (s asUnicodeString asString: 'UTF-8') = s.
	s := String new: 1024 withAll: $x.
	self assert: (s asUnicodeString asString: 'UTF-8') = s.
	s := String new: 1025 withAll: $x.
	self assert: (s asUnicodeString asString: 'UTF-8') = s.
	s := UnicodeString new: 1 withAll: $x.
	self assert: (s asString: 'UTF-8') asUnicodeString = s.
	s := UnicodeString new: 1024 withAll: $x.
	self assert: (s asString: 'UTF-8') asUnicodeString = s.
	s := UnicodeString new: 1025 withAll: $x.
	self assert: (s asString: 'UTF-8') asUnicodeString = s.
	s := UnicodeString new: 1025 withAll: $<16r4000>.
	self assert: (s asString: 'UTF-8') asUnicodeString = s.
	s := UnicodeString new: 1025 withAll: $<16r4000>.
	self assert: (s asString: 'UTF-8') asUnicodeString = s
    ]

    testExceptions [
	<category: 'test'>
	| b |
	self should: [ #[228] asUnicodeString ] raise: IncompleteSequenceError.
	self should: [ #[128] asUnicodeString ] raise: InvalidSequenceError.
	self should: [ #[228 128] asUnicodeString ] raise: IncompleteSequenceError.

	"On some OSes we return IncompleteSequenceError for the following."
	"self should: [ #[228 228] asUnicodeString ] raise: InvalidSequenceError."

	b := ByteArray new: 1026.
	b atAll: (1 to: 1026 by: 3) put: 228.
	b atAll: (2 to: 1026 by: 3) put: 128.
	b atAll: (3 to: 1026 by: 3) put: 128.
	self shouldnt: [ b asUnicodeString ] raise: IncompleteSequenceError.

	b := b copyFrom: 1 to: 1025.
	self should: [ b asUnicodeString ] raise: IncompleteSequenceError.

	b at: 1025 put: 228.
	"On some OSes we return IncompleteSequenceError for the following."
	"self should: [ b asUnicodeString ] raise: InvalidSequenceError."

	b := b copyFrom: 1 to: 1024.
	self should: [ b asUnicodeString ] raise: IncompleteSequenceError.
    ]
]

PK
     M[h@�cW�E  E            ��    package.xmlUT R�XOux �  �  PK
     �Mh@R}����  ��            ���  Sets.stUT dqXOux �  �  PK
     �Mh@iͬW{,  {,            ����  UTF7.stUT dqXOux �  �  PK
     �Mh@���i$  i$            ��D�  iconvtests.stUT dqXOux �  �  PK      >  ��    