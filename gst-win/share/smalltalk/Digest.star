PK
     |[h@8��%  %    package.xmlUT	 ��XO��XOux �  �  <package>
  <name>Digest</name>
  <test>
    <prereq>Digest</prereq>
    <prereq>SUnit</prereq>
    <sunit>MD5Test SHA1Test</sunit>
    <filein>mdtests.st</filein>
  </test>
  <module>digest</module>

  <filein>digest.st</filein>
  <filein>md5.st</filein>
  <filein>sha1.st</filein>
</package>PK
     �Mh@F�5��
  �
    md5.stUT	 cqXO��XOux �  �  "======================================================================
|
|   MD5 class declarations
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2005, 2007, 2008 Free Software Foundation, Inc.
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



MessageDigest subclass: MD5 [
    
    <comment: nil>
    <category: 'Examples-Modules'>

    MD5 class >> new [
	<category: 'C call-outs'>
	^self basicNew initialize
    ]

    newState [
	<category: 'C call-outs'>
	<cCall: 'MD5AllocOOP' returning: #smalltalk args: #()>
	
    ]

    combine: input size: len into: context [
	<category: 'C call-outs'>
	<cCall: 'MD5Update' returning: #void args: #(#cObject #int #cObject)>
	
    ]

    finalize: state in: digest [
	<category: 'C call-outs'>
	<cCall: 'MD5Final' returning: #void args: #(#cObject #cObject)>
	
    ]

    initialize [
	<category: 'initialization'>
	self state: self newState
    ]

    nextPut: char [
	<category: 'checksumming'>
	self 
	    combine: (String with: char)
	    size: 1
	    into: self state
    ]

    nextPutAll: aStringOrStream [
	<category: 'checksumming'>
	| buffer n |
	(aStringOrStream isKindOf: String) 
	    ifTrue: 
		[self 
		    combine: aStringOrStream
		    size: aStringOrStream size
		    into: self state]
	    ifFalse: 
		[buffer := aStringOrStream species new: 1024.
		n := 0.
		aStringOrStream do: 
			[:each | 
			n := n + 1.
			buffer at: n put: each.
			n = 1024 
			    ifTrue: 
				[self 
				    combine: buffer
				    size: n
				    into: self state.
				n := 0]].
		self 
		    combine: buffer
		    size: n
		    into: self state]
    ]

    digest [
	<category: 'checksumming'>
	| answer |
	answer := ByteArray new: 16.
	self finalize: self state in: answer.
	^answer
    ]
]

PK
     �Mh@z��MY
  Y
  	  digest.stUT	 cqXO��XOux �  �  "======================================================================
|
|   MessageDigest abstract class declarations
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2005 Free Software Foundation, Inc.
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



Object subclass: MessageDigest [
    | state |
    
    <category: 'Examples-Modules'>
    <comment: nil>

    MessageDigest class >> new: initialString [
	<category: 'instance creation'>
	^(self new)
	    nextPutAll: initialString;
	    yourself
    ]

    MessageDigest class >> digestOf: aStringOrStream [
	<category: 'checksumming'>
	^(self new: aStringOrStream) digest
    ]

    MessageDigest class >> hexDigestOf: aStringOrStream [
	<category: 'checksumming'>
	^(self new: aStringOrStream) hexDigest
    ]

    copy [
	<category: 'checksumming'>
	^self deepCopy
    ]

    partialDigest [
	<category: 'checksumming'>
	| s digest |
	s := state copy.
	digest := self digest.
	state := s.
	^digest
    ]

    digest [
	<category: 'checksumming'>
	self subclassResponsibility
    ]

    partialHexDigest [
	<category: 'checksumming'>
	| s digest |
	s := state copy.
	digest := self hexDigest.
	state := s.
	^digest
    ]

    hexDigest [
	<category: 'checksumming'>
	| digest answer |
	digest := self digest.
	answer := String new: digest size * 2.
	digest keysAndValuesDo: 
		[:i :each | 
		answer at: i + i - 1 put: (Character digitValue: each // 16).
		answer at: i + i put: (Character digitValue: each \\ 16)].
	^answer asLowercase
    ]

    state [
	<category: 'private'>
	^state
    ]

    state: anObject [
	<category: 'private'>
	state := anObject
    ]
]

PK
     �Mh@I+�    
  mdtests.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Message digest tests declarations
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Paolo Bonzini
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



TestCase subclass: MessageDigestTest [
    
    <comment: nil>
    <category: 'Examples-Modules'>

    nullDigest [
	<category: 'test vectors'>
	^self hexToByteArray: self hexNullDigest
    ]

    hexNullDigest [
	<category: 'test vectors'>
	self subclassResponsibility
    ]

    abcDigest [
	<category: 'test vectors'>
	^self hexToByteArray: self hexAbcDigest
    ]

    hexAbcDigest [
	<category: 'test vectors'>
	self subclassResponsibility
    ]

    abcdefDigest [
	<category: 'test vectors'>
	^self hexToByteArray: self hexAbcdefDigest
    ]

    hexAbcdefDigest [
	<category: 'test vectors'>
	self subclassResponsibility
    ]

    size64 [
	<category: 'test vectors'>
	^(2 to: 37) inject: '' into: [:a :b | a , b printString]
    ]

    size64Digest [
	<category: 'test vectors'>
	^self hexToByteArray: self hexSize64Digest
    ]

    hexSize64Digest [
	<category: 'test vectors'>
	self subclassResponsibility
    ]

    size128 [
	<category: 'test vectors'>
	^(2 to: 69) inject: '' into: [:a :b | a , b printString]
    ]

    size128Digest [
	<category: 'test vectors'>
	^self hexToByteArray: self hexSize128Digest
    ]

    hexSize128Digest [
	<category: 'test vectors'>
	self subclassResponsibility
    ]

    hexToByteArray: hex [
	<category: 'test vectors'>
	| ba |
	ba := ByteArray new: hex size / 2.
	1 to: hex size
	    by: 2
	    do: 
		[:i | 
		ba at: i // 2 + 1
		    put: (hex at: i) asUppercase digitValue * 16 
			    + (hex at: i + 1) asUppercase digitValue].
	^ba
    ]

    allTestCases [
	<category: 'test vectors'>
	^
	{'' -> self nullDigest.
	'abc' -> self abcDigest.
	'abcdef' -> self abcdefDigest.
	self size64 -> self size64Digest.
	self size128 -> self size128Digest}
    ]

    allHexTestCases [
	<category: 'test vectors'>
	^
	{'' -> self hexNullDigest.
	'abc' -> self hexAbcDigest.
	'abcdef' -> self hexAbcdefDigest.
	self size64 -> self hexSize64Digest.
	self size128 -> self hexSize128Digest}
    ]

    testDigestOf [
	<category: 'testing'>
	self allTestCases 
	    do: [:each | self assert: (self digestClass digestOf: each key) = each value]
    ]

    testByteArray [
	<category: 'testing'>
	self allTestCases do: 
		[:each | 
		self 
		    assert: (self digestClass digestOf: each key asByteArray) = each value]
    ]

    testHexDigestOf [
	<category: 'testing'>
	self allHexTestCases 
	    do: [:each | self assert: (self digestClass hexDigestOf: each key) = each value]
    ]

    testNextPut [
	<category: 'testing'>
	self allTestCases do: 
		[:each | 
		| md5 |
		md5 := self digestClass new.
		each key do: [:ch | md5 nextPut: ch].
		self assert: md5 digest = each value]
    ]

    testNextPutAll [
	<category: 'testing'>
	self allTestCases do: 
		[:each | 
		| md5 |
		md5 := self digestClass new.
		md5 nextPutAll: each key readStream.
		self assert: md5 digest = each value]
    ]

    testPartial [
	<category: 'testing'>
	| md5 |
	md5 := self digestClass new.
	md5 nextPutAll: 'abc'.
	self assert: md5 partialDigest = self abcDigest.
	md5 nextPutAll: 'def'.
	self assert: md5 partialDigest = self abcdefDigest.
	self assert: md5 digest = self abcdefDigest
    ]

    testPartialHex [
	<category: 'testing'>
	| md5 |
	md5 := self digestClass new.
	md5 nextPutAll: 'abc'.
	self assert: md5 partialHexDigest = self hexAbcDigest.
	md5 nextPutAll: 'def'.
	self assert: md5 partialHexDigest = self hexAbcdefDigest.
	self assert: md5 hexDigest = self hexAbcdefDigest
    ]
]



MessageDigestTest subclass: MD5Test [
    
    <comment: nil>
    <category: 'Examples-Modules'>

    hexNullDigest [
	<category: 'test vectors'>
	^'d41d8cd98f00b204e9800998ecf8427e'
    ]

    hexAbcDigest [
	<category: 'test vectors'>
	^'900150983cd24fb0d6963f7d28e17f72'
    ]

    hexAbcdefDigest [
	<category: 'test vectors'>
	^'e80b5017098950fc58aad83c8c14978e'
    ]

    hexSize64Digest [
	<category: 'test vectors'>
	^'165b2b14eccde03de4742a2f9390e1a1'
    ]

    hexSize128Digest [
	<category: 'test vectors'>
	^'59bda09a8b3e1d186237ed0fed34d87a'
    ]

    digestClass [
	<category: 'test vectors'>
	^MD5
    ]
]



MessageDigestTest subclass: SHA1Test [
    
    <comment: nil>
    <category: 'Examples-Modules'>

    hexNullDigest [
	<category: 'test vectors'>
	^'da39a3ee5e6b4b0d3255bfef95601890afd80709'
    ]

    hexAbcDigest [
	<category: 'test vectors'>
	^'a9993e364706816aba3e25717850c26c9cd0d89d'
    ]

    hexAbcdefDigest [
	<category: 'test vectors'>
	^'1f8ac10f23c5b5bc1167bda84b833e5c057a77d2'
    ]

    hexSize64Digest [
	<category: 'test vectors'>
	^'6a90ea3e17064652ed5406d3e10eb9ac2ee9a21e'
    ]

    hexSize128Digest [
	<category: 'test vectors'>
	^'e02f6ccdd12ebf0958e18aea9fed8fbe818a223c'
    ]

    digestClass [
	<category: 'test vectors'>
	^SHA1
    ]
]

PK
     �Mh@�����
  �
    sha1.stUT	 cqXO��XOux �  �  "======================================================================
|
|   SHA1 class declarations
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



MessageDigest subclass: SHA1 [
    
    <comment: nil>
    <category: 'Examples-Modules'>

    SHA1 class >> new [
	<category: 'C call-outs'>
	^self basicNew initialize
    ]

    newState [
	<category: 'C call-outs'>
	<cCall: 'SHA1AllocOOP' returning: #smalltalk args: #()>
	
    ]

    combine: input size: len into: context [
	<category: 'C call-outs'>
	<cCall: 'SHA1Update' returning: #void args: #(#cObject #int #cObject)>
	
    ]

    finalize: state in: digest [
	<category: 'C call-outs'>
	<cCall: 'SHA1Final' returning: #void args: #(#cObject #cObject)>
	
    ]

    initialize [
	<category: 'initialization'>
	self state: self newState
    ]

    nextPut: char [
	<category: 'checksumming'>
	self 
	    combine: (String with: char)
	    size: 1
	    into: self state
    ]

    nextPutAll: aStringOrStream [
	<category: 'checksumming'>
	| buffer n |
	(aStringOrStream isKindOf: String) 
	    ifTrue: 
		[self 
		    combine: aStringOrStream
		    size: aStringOrStream size
		    into: self state]
	    ifFalse: 
		[buffer := aStringOrStream species new: 1024.
		n := 0.
		aStringOrStream do: 
			[:each | 
			n := n + 1.
			buffer at: n put: each.
			n = 1024 
			    ifTrue: 
				[self 
				    combine: buffer
				    size: n
				    into: self state.
				n := 0]].
		self 
		    combine: buffer
		    size: n
		    into: self state]
    ]

    digest [
	<category: 'checksumming'>
	| answer |
	answer := ByteArray new: 20.
	self finalize: self state in: answer.
	^answer
    ]
]

PK
     |[h@8��%  %            ��    package.xmlUT ��XOux �  �  PK
     �Mh@F�5��
  �
            ��j  md5.stUT cqXOux �  �  PK
     �Mh@z��MY
  Y
  	          ��t  digest.stUT cqXOux �  �  PK
     �Mh@I+�    
          ��  mdtests.stUT cqXOux �  �  PK
     �Mh@�����
  �
            ��\.  sha1.stUT cqXOux �  �  PK      �  a9    