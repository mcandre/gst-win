PK
     �Mh@%^R>  >    zlibtests.stUT	 fqXO:�XOux �  �  "======================================================================
|
|   ZLib module unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
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



TestCase subclass: ZlibStreamTest [
    | oldBufSize |
    
    <comment: nil>
    <category: 'Examples-Useful'>

    ZlibStreamTest class >> fooVector [
	"Return a long and repetitive string."

	<category: 'testing'>
	| original size answer |
	original := 'The quick brown fox jumps over the lazy dog
'.
	size := original size.
	answer := String new: size * 81.
	1 to: 81
	    do: 
		[:idx | 
		answer 
		    replaceFrom: (idx - 1) * size + 1
		    to: idx * size
		    with: original].
	^answer
    ]

    setUp [
	<category: 'testing'>
	oldBufSize := ZlibStream bufferSize.
	ZlibStream bufferSize: 512
    ]

    tearDown [
	<category: 'testing'>
	ZlibStream bufferSize: oldBufSize
    ]

    assertFooVector: string [
	"SUnit-Assert that string = `self fooVector'."

	<category: 'testing'>
	self assert: string = self fooVector
    ]

    fooVector [
	"Refactored to class."

	<category: 'testing'>
	^self class fooVector
    ]

    doDeflate [
	"Deflate the long string and return the result."

	<category: 'testing'>
	^(DeflateStream on: self fooVector readStream) contents
    ]

    testError [
	"Test whether catching errors works."

	<category: 'testing'>
	self should: [(InflateStream on: #[12 34 56] readStream) contents]
	    raise: ZlibError
    ]

    testSyncFlush [
	"Test flushing the WriteStream version of DeflateStream."

	<category: 'testing'>
	| dest stream contents |
	stream := String new writeStream.
	dest := DeflateStream compressingTo: stream.
	dest
	    nextPutAll: self fooVector;
	    syncFlush.
	contents := stream contents.
	self assert: (contents asByteArray last: 4) = #[0 0 255 255].
	self 
	    assert: (InflateStream on: contents readStream) contents = self fooVector
    ]

    testWrite [
	"Test the WriteStream version of DeflateStream."

	<category: 'testing'>
	| dest |
	dest := DeflateStream compressingTo: String new writeStream.
	dest nextPutAll: self fooVector.
	self assert: dest contents asByteArray = self doDeflate asByteArray
    ]

    testRaw [
	"Test connecting a DeflateStream back-to-back with an InflateStream."

	<category: 'testing'>
	| deflate |
	deflate := RawDeflateStream on: self fooVector readStream.
	self assertFooVector: (RawInflateStream on: deflate) contents
    ]

    testGZip [
	"Test connecting a DeflateStream back-to-back with an InflateStream."

	<category: 'testing'>
	| deflate |
	deflate := GZipDeflateStream on: self fooVector readStream.
	self assertFooVector: (GZipInflateStream on: deflate) contents
    ]

    testDirect [
	"Test connecting a DeflateStream back-to-back with an InflateStream."

	<category: 'testing'>
	| deflate |
	deflate := DeflateStream on: self fooVector readStream.
	self assertFooVector: (InflateStream on: deflate) contents
    ]

    testInflate [
	"Basic compression/decompression test."

	<category: 'testing'>
	self 
	    assertFooVector: (InflateStream on: self doDeflate readStream) contents
    ]

    testNextAvailable [
	"Test accessing data with nextAvailable (needed to file-in compressed data)."

	<category: 'testing'>
	| stream data |
	stream := InflateStream on: self doDeflate readStream.
	data := String new.
	[stream atEnd] whileFalse: [data := data , (stream nextAvailable: 1024) ].
	self assertFooVector: data
    ]

    testNextAvailablePutAllOn [
	"Test accessing data with nextAvailablePutAllOn."

	<category: 'testing'>
	| stream data |
	stream := InflateStream on: self doDeflate readStream.
	data := String new writeStream.
	[stream atEnd] whileFalse: [stream nextAvailablePutAllOn: data].
	self assertFooVector: data contents
    ]

    testRandomAccess [
	"Test random access to deflated data."

	<category: 'testing'>
	| original stream data ok |
	original := self fooVector.
	stream := InflateStream on: self doDeflate readStream.
	stream contents.
	stream position: 0.
	self assert: (original copyFrom: 1 to: 512) = (stream next: 512).
	stream position: 512.
	self assert: (original copyFrom: 513 to: 1024) = (stream next: 512).
	stream position: 1536.
	self assert: (original copyFrom: 1537 to: 2048) = (stream next: 512).
	stream position: 1.
	self assert: (original copyFrom: 2 to: 512) = (stream next: 511).
	stream position: 514.
	self assert: (original copyFrom: 515 to: 1024) = (stream next: 510)
    ]
]

PK
     Q\h@E\�Mw  w    package.xmlUT	 :�XO:�XOux �  �  <package>
  <name>ZLib</name>
  <namespace>ZLib</namespace>
  <test>
    <namespace>ZLib</namespace>
    <prereq>SUnit</prereq>
    <prereq>ZLib</prereq>
    <sunit>ZlibStreamTest</sunit>
    <filein>zlibtests.st</filein>
  </test>
  <module>zlib</module>

  <filein>ZLibStream.st</filein>
  <filein>ZLibReadStream.st</filein>
  <filein>ZLibWriteStream.st</filein>
</package>PK
     �Mh@n�P�Q)  Q)    ZLibReadStream.stUT	 fqXO:�XOux �  �  "======================================================================
|
|   ZLib module declarations
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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



ZlibStream subclass: ZlibReadStream [
    | delta ptr endPtr |
    
    <comment: 'This abstract class implements the basic buffering that is
used for communication with zlib.'>
    <category: 'Examples-Useful'>

    atEnd [
	"Answer whether the stream has got to an end"

	<category: 'streaming'>
	ptr >= endPtr ifFalse: [^false].
	^zlibObject isNil or: 
		[self fillBuffer.
		zlibObject isNil]
    ]

    next [
	"Return the next object (character or byte) in the receiver."

	<category: 'streaming'>
	self atEnd ifTrue: [^self pastEnd].
	ptr := ptr + 1.
	^outBytes at: ptr
    ]

    peekFor: anObject [
	"Returns true and gobbles the next element from the stream of it is
	 equal to anObject, returns false and doesn't gobble the next element
	 if the next element is not equal to anObject."

	<category: 'streaming'>
	| result |
	self atEnd ifTrue: [^self pastEnd].
	result := (outBytes at: ptr + 1) = anObject.
	result ifTrue: [ptr := ptr + 1].
	^result
    ]

    nextAvailable: anInteger putAllOn: aStream [
        "Copy up to anInteger objects from the receiver to
         aStream, stopping if no more data is available."

        <category: 'accessing-reading'>
        | n |
	self atEnd ifTrue: [^0].
        n := anInteger min: endPtr - ptr.
        aStream
            next: n
            putAll: outBytes
            startingAt: ptr + 1.
        ptr := ptr + n.
        ^n
    ]

    nextAvailable: anInteger into: aCollection startingAt: pos [
        "Place up to anInteger objects from the receiver into
         aCollection, starting from position pos and stopping if
         no more data is available."

        <category: 'accessing-reading'>
        | n |
	self atEnd ifTrue: [^0].
        n := anInteger min: endPtr - ptr.
        aCollection
            replaceFrom: pos
            to: pos + n - 1
            with: outBytes
            startingAt: ptr + 1.
        ptr := ptr + n.
        ^n
    ]

    peek [
	"Returns the next element of the stream without moving the pointer.
	 Returns nil when at end of stream."

	<category: 'streaming'>
	self atEnd ifTrue: [^nil].
	^outBytes at: ptr + 1
    ]

    position [
	"Answer the current value of the stream pointer.  Note that only inflating
	 streams support random access to the stream data."

	<category: 'streaming'>
	^delta + ptr
    ]

    resetBuffer [
	<category: 'private'>
	ptr := 0.
	delta := 0.
	endPtr := 0
    ]

    initialize: aStream [
	<category: 'private'>
	super initialize: aStream.
	outBytes := self species new: self class bufferSize.
	self resetBuffer
    ]

    fillBuffer [
	"Fill the output buffer, supplying data to zlib until it can actually
	 produce something."

	<category: 'private'>
	| flush |
	delta := delta + endPtr.
	ptr := 0.
	
	"TODO: reuse the inBytes collection."
	[(inBytes isNil and: [self stream atEnd not]) 
	    ifTrue: [inBytes := self stream nextAvailable: 1024].
	flush := inBytes isNil ifTrue: [4] ifFalse: [0].
	endPtr := self processInput: flush size: inBytes size.
	endPtr = 0] 
		whileTrue.

	"End of data, or zlib error encountered."
	endPtr = -1 ifTrue: [self checkError]
    ]
]



ZlibReadStream subclass: RawDeflateStream [
    
    <comment: 'Instances of this class produce "raw" (PKZIP)
deflated data.'>
    <category: 'Examples-Useful'>

    RawDeflateStream class >> compressingTo: aStream [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream."

	<category: 'instance creation'>
	^RawDeflateWriteStream on: aStream
    ]

    RawDeflateStream class >> compressingTo: aStream level: level [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream with the given compression level."

	<category: 'instance creation'>
	^RawDeflateWriteStream on: aStream level: level
    ]

    RawDeflateStream class >> on: aStream [
	"Answer a stream that compresses the data in aStream with the default
	 compression level."

	<category: 'instance creation'>
	^(super on: aStream) initializeZlibObject: self defaultCompressionLevel
    ]

    RawDeflateStream class >> on: aStream level: compressionLevel [
	"Answer a stream that compresses the data in aStream with the given
	 compression level."

	<category: 'instance creation'>
	^(super on: aStream) initializeZlibObject: compressionLevel
    ]

    initializeZlibObject: level windowSize: winSize [
	<category: 'private zlib interface'>
	<cCall: 'gst_deflateInit' returning: #void args: #(#self #int #int)>
	
    ]

    initializeZlibObject: level [
	<category: 'private zlib interface'>
	self initializeZlibObject: level windowSize: -15
    ]

    destroyZlibObject [
	<category: 'private zlib interface'>
	<cCall: 'gst_deflateEnd' returning: #void args: #(#self)>
	
    ]

    processInput: atEnd size: bytes [
	<category: 'private zlib interface'>
	<cCall: 'gst_deflate' returning: #int args: #(#self #int #int)>
	
    ]
]



RawDeflateStream subclass: DeflateStream [
    
    <comment: 'Instances of this class produce "standard"
(zlib, RFC1950) deflated data.'>
    <category: 'Examples-Useful'>

    DeflateStream class >> compressingTo: aStream [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream."

	<category: 'instance creation'>
	^DeflateWriteStream on: aStream
    ]

    DeflateStream class >> compressingTo: aStream level: level [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream with the given compression level."

	<category: 'instance creation'>
	^DeflateWriteStream on: aStream level: level
    ]

    initializeZlibObject: level [
	<category: 'private zlib interface'>
	self initializeZlibObject: level windowSize: 15
    ]
]



RawDeflateStream subclass: GZipDeflateStream [
    
    <comment: 'Instances of this class produce GZip (RFC1952)
deflated data.'>
    <category: 'Examples-Useful'>

    GZipDeflateStream class >> compressingTo: aStream [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream."

	<category: 'instance creation'>
	^GZipDeflateWriteStream on: aStream
    ]

    GZipDeflateStream class >> compressingTo: aStream level: level [
	"Answer a stream that receives data via #nextPut: and compresses it onto
	 aStream with the given compression level."

	<category: 'instance creation'>
	^GZipDeflateWriteStream on: aStream level: level
    ]

    initializeZlibObject: level [
	<category: 'private zlib interface'>
	self initializeZlibObject: level windowSize: 31
    ]
]



ZlibReadStream subclass: RawInflateStream [
    
    <comment: 'Instances of this class reinflate "raw" (PKZIP)
deflated data.'>
    <category: 'Examples-Useful'>

    position: anInteger [
	"Set the current position in the stream to anInteger.  Notice that this
	 class can only provide the illusion of random access, by appropriately
	 rewinding the input stream or skipping compressed data."

	<category: 'positioning'>
	delta > anInteger ifTrue: [self reset].
	[delta + endPtr < anInteger] whileTrue: [self fillBuffer].
	ptr := anInteger - delta
    ]

    reset [
	"Reset the stream to the beginning of the compressed data."

	<category: 'positioning'>
	self stream reset.
	self
	    destroyZlibObject;
	    initializeZlibObject.
	self resetBuffer
    ]

    copyFrom: start to: end [
	"Answer the data on which the receiver is streaming, from
	 the start-th item to the end-th.  Note that this method is 0-based,
	 unlike the one in Collection, because a Stream's #position method
	 returns 0-based values.  Notice that this class can only provide
	 the illusion of random access, by appropriately rewinding the input
	 stream or skipping compressed data."

	<category: 'positioning'>
	| pos |
	pos := self position.
	^
	[self
	    position: start;
	    next: end - start] 
		ensure: [self position: pos]
    ]

    isPositionable [
	"Answer true if the stream supports moving backwards with #skip:."

	<category: 'positioning'>
	^true
    ]

    skip: anInteger [
	"Move the current position by anInteger places, either forwards or
	 backwards."

	<category: 'positioning'>
	self position: self position + anInteger
    ]

    initialize: aStream [
	<category: 'private zlib interface'>
	self initializeZlibObject.
	super initialize: aStream
    ]

    initializeZlibObject: windowSize [
	<category: 'private zlib interface'>
	<cCall: 'gst_inflateInit' returning: #void args: #(#self #int)>
	
    ]

    initializeZlibObject [
	<category: 'private zlib interface'>
	self initializeZlibObject: -15
    ]

    destroyZlibObject [
	<category: 'private zlib interface'>
	<cCall: 'gst_inflateEnd' returning: #void args: #(#self)>
	
    ]

    processInput: atEnd size: bytes [
	<category: 'private zlib interface'>
	<cCall: 'gst_inflate' returning: #int args: #(#self #int #int)>
	
    ]
]



RawInflateStream subclass: InflateStream [
    
    <comment: 'Instances of this class reinflate "standard"
(zlib, RFC1950) deflated data.'>
    <category: 'Examples-Useful'>

    initializeZlibObject [
	<category: 'private zlib interface'>
	self initializeZlibObject: 15
    ]
]



RawInflateStream subclass: GZipInflateStream [
    
    <comment: 'Instances of this class reinflate GZip (RFC1952)
deflated data.'>
    <category: 'Examples-Useful'>

    initializeZlibObject [
	<category: 'private zlib interface'>
	self initializeZlibObject: 31
    ]
]

PK
     �Mh@���{6  6    ZLibStream.stUT	 fqXO:�XOux �  �  "======================================================================
|
|   ZLib module declarations
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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



Error subclass: ZlibError [
    | stream |
    
    <category: 'Examples-Useful'>
    <comment: 'This exception is raised whenever there is an error
in a compressed stream.'>

    stream [
	"Answer the ZlibStream that caused the error."

	<category: 'accessing'>
	^stream
    ]

    stream: anObject [
	"Set the ZlibStream that caused the error."

	<category: 'accessing'>
	stream := anObject
    ]
]



Stream subclass: ZlibStream [
    | inBytes outBytes zlibObject stream |
    
    <category: 'Examples-Useful'>
    <comment: 'This abstract class implements the basic interface to
the zlib module.  Its layout matches what is expected by the C code.'>

    BufferSize := nil.
    DefaultCompressionLevel := nil.

    ZlibStream class >> bufferSize [
	"Answer the size of the output buffers that are passed to zlib.  Each
	 zlib stream uses a buffer of this size."

	<category: 'accessing'>
	BufferSize isNil ifTrue: [BufferSize := 16384].
	^BufferSize
    ]

    ZlibStream class >> bufferSize: anInteger [
	"Set the size of the output buffers that are passed to zlib.  Each
	 zlib stream uses a buffer of this size."

	<category: 'accessing'>
	BufferSize := anInteger
    ]

    ZlibStream class >> defaultCompressionLevel [
	"Return the default compression level used by deflating streams."

	<category: 'accessing'>
	DefaultCompressionLevel isNil ifTrue: [DefaultCompressionLevel := 6].
	^DefaultCompressionLevel
    ]

    ZlibStream class >> defaultCompressionLevel: anInteger [
	"Set the default compression level used by deflating streams.  It
	 should be a number between 1 and 9."

	<category: 'accessing'>
	DefaultCompressionLevel := anInteger
    ]

    ZlibStream class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    ZlibStream class >> on: aStream [
	"Answer an instance of the receiver that decorates aStream."

	<category: 'instance creation'>
	^self basicNew initialize: aStream
    ]

    stream [
	"Answer the wrapped stream."

	<category: 'streaming'>
	^stream
    ]

    isExternalStream [
	"Answer whether the receiver streams on a file or socket."

	<category: 'streaming'>
	^stream isExternalStream
    ]

    name [
	"Return the name of the underlying stream."

	<category: 'streaming'>
	^stream name
    ]

    species [
	"Return the type of the collections returned by #upTo: etc."

	<category: 'streaming'>
	^stream species
    ]

    initialize: aStream [
	<category: 'private'>
	stream := aStream.
	self addToBeFinalized
    ]

    finalize [
	<category: 'private'>
	self destroyZlibObject
    ]

    checkError [
	<category: 'private zlib interface'>
	| error |
	error := self getError.
	self
	    finalize;
	    removeToBeFinalized.
	error isNil 
	    ifFalse: 
		[(ZlibError new)
		    messageText: error;
		    stream: self;
		    signal]
    ]

    getError [
	<category: 'private zlib interface'>
	<cCall: 'gst_zlibError' returning: #string args: #(#self)>
	
    ]

    destroyZlibObject [
	<category: 'private zlib interface'>
	self subclassResponsibility
    ]

    processInput: atEnd size: bytes [
	<category: 'private zlib interface'>
	self subclassResponsibility
    ]
]

PK
     �Mh@A�K��  �    ZLibWriteStream.stUT	 fqXO:�XOux �  �  "======================================================================
|
|   ZLib module declarations
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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



Eval [
    DLD addModule: 'zlib'
]



ZlibStream subclass: ZlibWriteStream [
    | delta ptr |
    
    <comment: 'This abstract class implements the basic buffering
that is used for communication with zlib in a WriteStream decorator.'>
    <category: 'Examples-Useful'>

    flushBuffer [
	"Flush the deflated output to the destination stream."

	<category: 'streaming'>
	self flushBuffer: 0
    ]

    flush [
	"Flush the deflated output to the destination stream, and flush the
	 destination stream."

	<category: 'streaming'>
	self flushBuffer: 0.
	self stream flush
    ]

    partialFlush [
	"Flush the deflated output to the destination stream using Z_PARTIAL_FLUSH,
	 and flush the destination stream."

	<category: 'streaming'>
	self flushBuffer: 1.
	self stream flush
    ]

    syncFlush [
	"Flush the deflated output to the destination stream using Z_SYNC_FLUSH,
	 and flush the destination stream.  Note that this includes the four
	 bytes 0/0/255/255 at the end of the flush."

	<category: 'streaming'>
	self flushBuffer: 2.
	self stream flush
    ]

    flushDictionary [
	"Flush the deflated output to the destination stream using Z_FULL_FLUSH,
	 and flush the destination stream."

	<category: 'streaming'>
	self flushBuffer: 3.
	self stream flush
    ]

    finish [
	"Finish the deflated output to the destination stream using Z_FINISH.
	 The destination stream is not flushed."

	<category: 'streaming'>
	self flushBuffer: 4.
	self stream flush
    ]

    close [
	"Finish the deflated output to the destination stream using Z_FINISH.
	 The destination stream is closed, which implies flushing."

	<category: 'streaming'>
	self finish.
	self stream close
    ]

    readStream [
	"Finish the deflated output to the destination stream using Z_FINISH and
	 return a ReadStream on the deflated data (requires the destination
	 stream to support #readStream)."

	<category: 'streaming'>
	| result |
	self finish.
	result := self stream readStream.
	self stream close.
	^result
    ]

    contents [
	"Finish the deflated output to the destination stream using Z_FINISH and
	 return the deflated data (requires the destination stream to support
	 #contents)."

	<category: 'streaming'>
	| result |
	self finish.
	result := self stream contents.
	self stream close.
	^result
    ]

    nextPut: aByte [
	"Append a character or byte (depending on whether the destination
	 stream works on a ByteArray or String) to the deflation buffer."

	<category: 'streaming'>
	ptr = inBytes size ifTrue: [self flushBuffer].
	inBytes at: ptr put: aByte.
	ptr := ptr + 1
    ]

    next: n putAll: aCollection startingAt: pos [
	"Put n characters or bytes of aCollection, starting at the pos-th,
	 in the deflation buffer."

	<category: 'streaming'>
	| written amount |
	ptr = inBytes size ifTrue: [self flushBuffer].
	written := 0.
	
	[amount := inBytes size - ptr + 1 min: n - written.
	self 
	    next: amount
	    bufferAll: aCollection
	    startingAt: pos + written.
	written := written + amount.
	written < n] 
		whileTrue: [self flushBuffer]
    ]

    position [
	"Answer the number of compressed bytes written."

	<category: 'streaming'>
	self flushBuffer.
	^delta
    ]

    next: n bufferAll: aCollection startingAt: pos [
	"Private - Assuming that the buffer has space for n characters, store
	 n characters of aCollection in the buffer, starting from the pos-th."

	<category: 'private'>
	n = 0 ifTrue: [^self].
	inBytes 
	    replaceFrom: ptr
	    to: ptr + n - 1
	    with: aCollection
	    startingAt: pos.
	ptr := ptr + n
    ]

    initialize: aWriteStream [
	<category: 'private'>
	super initialize: aWriteStream.
	inBytes := self species new: self class bufferSize.
	outBytes := self species new: self class bufferSize.
	ptr := 1.
	delta := 0
    ]

    flushBuffer: flag [
	"Fill the output buffer, supplying data to zlib until it exhausts
	 the input buffer, and putting the output into the destination stream."

	<category: 'private'>
	"The module uses the convention of nil-ing out inBytes when its data
	 is completely consumed; this is useless for this class, so undo it."

	| endPtr buffer |
	
	[buffer := inBytes.
	endPtr := self processInput: flag size: ptr - 1.
	inBytes := buffer.
	ptr := 1.
	endPtr = -1 ifTrue: [self checkError].
	endPtr > 0] 
		whileTrue: 
		    [delta := delta + endPtr.
		    self stream 
			next: endPtr
			putAll: outBytes
			startingAt: 1]
    ]
]



ZlibWriteStream subclass: RawDeflateWriteStream [
    
    <comment: 'Instances of this class produce "raw" (PKZIP)
deflated data.'>
    <category: 'Examples-Useful'>

    DefaultCompressionLevel := nil.

    RawDeflateWriteStream class >> on: aWriteStream [
	"Answer a stream that compresses the data in aStream with the default
	 compression level."

	<category: 'instance creation'>
	^(self basicNew)
	    initializeZlibObject: self defaultCompressionLevel;
	    initialize: aWriteStream
    ]

    RawDeflateWriteStream class >> on: aWriteStream level: compressionLevel [
	"Answer a stream that compresses the data in aStream with the given
	 compression level."

	<category: 'instance creation'>
	^(self basicNew)
	    initializeZlibObject: compressionLevel;
	    initialize: aWriteStream
    ]

    initializeZlibObject: level windowSize: winSize [
	<category: 'private zlib interface'>
	<cCall: 'gst_deflateInit' returning: #void args: #(#self #int #int)>
	
    ]

    initializeZlibObject: level [
	<category: 'private zlib interface'>
	self initializeZlibObject: level windowSize: -15
    ]

    destroyZlibObject [
	<category: 'private zlib interface'>
	<cCall: 'gst_deflateEnd' returning: #void args: #(#self)>
	
    ]

    processInput: atEnd size: bytes [
	<category: 'private zlib interface'>
	<cCall: 'gst_deflate' returning: #int args: #(#self #int #int)>
	
    ]
]



RawDeflateWriteStream subclass: DeflateWriteStream [
    
    <comment: 'Instances of this class produce "standard"
(zlib, RFC1950) deflated data.'>
    <category: 'Examples-Useful'>

    initializeZlibObject: level [
	<category: 'private zlib interface'>
	self initializeZlibObject: level windowSize: 15
    ]
]



RawDeflateWriteStream subclass: GZipDeflateWriteStream [
    
    <comment: 'Instances of this class produce GZip (RFC1952)
deflated data.'>
    <category: 'Examples-Useful'>

    initializeZlibObject: level [
	<category: 'private zlib interface'>
	self initializeZlibObject: level windowSize: 31
    ]
]

PK
     �Mh@%^R>  >            ��    zlibtests.stUT fqXOux �  �  PK
     Q\h@E\�Mw  w            ���  package.xmlUT :�XOux �  �  PK
     �Mh@n�P�Q)  Q)            ��@  ZLibReadStream.stUT fqXOux �  �  PK
     �Mh@���{6  6            ���@  ZLibStream.stUT fqXOux �  �  PK
     �Mh@A�K��  �            ��YR  ZLibWriteStream.stUT fqXOux �  �  PK      �  �p    