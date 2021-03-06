PK
     �Mh@����N  N    Connection.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   MySQL DBI driver - Connection class and related classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Markus Fritsche,
| refactored/rewritten by Paolo Bonzini
|
| Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
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



ReadStream subclass: MySQLReadStream [
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    readNullTerminatedString [
	<category: 'accessing'>
	^self upTo: self null asCharacter
    ]

    null [
	<category: 'constants'>
	^0
    ]
]



WriteStream subclass: MySQLWriteStream [
    | outputPacket |
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    MySQLWriteStream class >> on: aCollection startingAt: aPosition outputPacket: op [
	<category: 'instance creation'>
	| ws |
	ws := (self on: aCollection) setWritePosition: aPosition.
	ws outputPacket: op.
	^ws
    ]

    MySQLWriteStream class >> xon: aCollection outputPacket: op [
	<category: 'instance creation'>
	| ws |
	ws := (super on: aCollection) initialize.
	ws outputPacket: op.
	^ws
    ]

    cmdConnect [
	<category: 'mysql-constants'>
	^11
    ]

    cmdCreateDatabase [
	<category: 'mysql-constants'>
	^5
    ]

    cmdDebug [
	<category: 'mysql-constants'>
	^13
    ]

    cmdDropDatabase [
	<category: 'mysql-constants'>
	^6
    ]

    cmdFieldList [
	<category: 'mysql-constants'>
	^4
    ]

    cmdInitializeDatabase [
	<category: 'mysql-constants'>
	^2
    ]

    cmdKillProcess [
	<category: 'mysql-constants'>
	^12
    ]

    cmdProcessInfo [
	<category: 'mysql-constants'>
	^10
    ]

    cmdQuery [
	<category: 'mysql-constants'>
	^3
    ]

    cmdQuit [
	<category: 'mysql-constants'>
	^1
    ]

    cmdRefresh [
	<category: 'mysql-constants'>
	^7
    ]

    cmdShutdown [
	<category: 'mysql-constants'>
	^8
    ]

    cmdSleep [
	<category: 'mysql-constants'>
	^0
    ]

    cmdStatistics [
	<category: 'mysql-constants'>
	^9
    ]

    flush [
	<category: 'accessing'>
	outputPacket flush
    ]

    nextPutAllNullTerminated: aCollection2 [
	<category: 'accessing'>
	self nextPutAll: aCollection2.
	self nextPut: self null asCharacter
    ]

    nextPutCommand: aCommand [
	<category: 'accessing'>
	self
	    nextPut: (Character value: (self perform: aCommand));
	    nextPut: self null asCharacter
    ]

    nextPutCommand: aCommand message: aString [
	<category: 'accessing'>
	self
	    nextPut: (Character value: (self perform: aCommand));
	    nextPutAllNullTerminated: aString
    ]

    outputPacket [
	<category: 'accessing'>
	^outputPacket
    ]

    outputPacket: p [
	<category: 'accessing'>
	outputPacket := p
    ]

    setWritePosition: aPosition [
	"aPosition timesRepeat: [ self nextPut: 0 asCharacter]"

	<category: 'accessing'>
	ptr := aPosition + 1
    ]

    initialize [
	<category: 'initialize'>
	
    ]

    null [
	<category: 'constants'>
	^0
    ]
]



Object subclass: MySQLPacket [
    | packetNumber size buffer stream |
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    MySQLPacket class >> defaultBufferSize [
	<category: 'constants'>
	^8192
    ]

    MySQLPacket class >> headerSize [
	<category: 'constants'>
	^4
    ]

    MySQLPacket class >> packetNumberOffset [
	<category: 'constants'>
	^4
    ]

    MySQLPacket class >> packetNumberSize [
	<category: 'constants'>
	^1
    ]

    MySQLPacket class >> izeOffset [
	<category: 'constants'>
	^1
    ]

    MySQLPacket class >> sizeSize [
	<category: 'constants'>
	^3
    ]

    MySQLPacket class >> on: aStream [
	<category: 'instance creation'>
	^(self new)
	    stream: aStream;
	    initialize
    ]

    packetNumber [
	<category: 'accessing'>
	^packetNumber
    ]

    packetNumber: anInteger [
	<category: 'accessing'>
	packetNumber := anInteger
    ]

    size [
	<category: 'accessing'>
	^size
    ]

    size: anObject [
	<category: 'accessing'>
	size := anObject
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: anObject [
	<category: 'accessing'>
	stream := anObject
    ]
]



MySQLPacket subclass: MySQLInputPacket [
    | readStream |
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    initialize [
	<category: 'initialize-release'>
	self stream atEnd 
	    ifTrue: 
		[size := packetNumber := 0.
		buffer := #[].
		^self].
	size := self readSize.
	packetNumber := self readPacketNumber.
	buffer := self readBuffer.
	readStream := MySQLReadStream on: buffer
    ]

    isStatus: anInteger onError: aSymbol [
	<category: 'reading'>
	^(self readStatusOnError: aSymbol) = anInteger
    ]

    checkForStatus: anInteger onError: aSymbol [
	<category: 'reading'>
	(self readStatusOnError: aSymbol) = anInteger 
	    ifFalse: [self handleError: aSymbol]
    ]

    checkStatusOnError: aSymbol [
	<category: 'reading'>
	self checkForStatus: 0 onError: aSymbol
    ]

    handleError: aSymbol [
	<category: 'reading'>
	| ba int1 int2 |
	ba := (readStream next: 2) asByteArray.
	int1 := ba basicAt: 1.
	int2 := ba basicAt: 2.
	int2 := int2 bitShift: 8.
	MySQLConnection throwException: aSymbol
	    message: (int1 + int2) printString , ' ' 
		    , readStream readNullTerminatedString
	"MySQLConnection throwException: aSymbol
	 message: (readStream next: 2) asByteArray asInteger printString , ' '
	 , readStream readNullTerminatedString"
    ]

    readBuffer [
	<category: 'reading'>
	^self stream next: self size
    ]

    readPacketNumber [
	<category: 'reading'>
	| ba o int1 |
	o := self stream next: self class packetNumberSize.
	ba := o asByteArray.
	int1 := ba basicAt: 1.
	^int1

	"^(self stream next: self class packetNumberSize) asByteArray asInteger"
    ]

    readSize [
	<category: 'reading'>
	| ba o int1 int2 int3 |
	o := self stream next: self class sizeSize.
	"o := String streamContents: [:aStream | 1 to: self class sizeSize
	 do: [:i | aStream nextPut: self stream next]]."
	ba := o asByteArray.
	int1 := ba basicAt: 1.
	int2 := ba basicAt: 2.
	int2 := int2 bitShift: 8.
	int3 := ba basicAt: 3.
	int3 := int3 bitShift: 16.
	^int1 + int2 + int3
	"^(self stream next: self class sizeSize) asByteArray asInteger"
    ]

    readStatusOnError: aSymbol [
	<category: 'reading'>
	| status |
	status := readStream next asInteger.
	status = 255 ifFalse: [^status].
	self handleError: aSymbol
    ]

    readStream [
	<category: 'accessing'>
	^readStream
    ]
]



MySQLPacket subclass: MySQLOutputPacket [
    | writeStream |
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    writeStream [
	<category: 'accessing'>
	^writeStream
    ]

    flush [
	<category: 'actions'>
	| aString ba s bytesSend |
	aString := self writeStream contents.
	self size: aString size - self class headerSize.
	ba := MySQLConnection integerAsByteArray: self size
		    length: self class sizeSize.
	s := MySQLConnection byteArrayAsByteString: ba.
	aString 
	    replaceFrom: 1
	    to: self class sizeSize
	    with: s
	    startingAt: 1.
	aString at: self class sizeSize + 1
	    put: (Character value: self packetNumber).
	(self stream)
	    nextPutAll: aString;
	    flush
    ]

    initialize [
	<category: 'initialize-release'>
	packetNumber := 0.
	buffer := String new: self class defaultBufferSize.
	writeStream := MySQLWriteStream 
		    on: buffer
		    startingAt: self class headerSize
		    outputPacket: self

	"This is a bit of a hack...I should utilize events instead"
    ]
]



Connection subclass: MySQLConnection [
    | socket serverInfo database responsePacket |
    
    <comment: nil>
    <category: 'Mysql-Driver'>

    MySQLConnection class >> throwException: aSymbol [
	<category: 'errors'>
	self throwException: aSymbol message: ''
    ]

    MySQLConnection class >> throwException: aSymbol message: aString [
	<category: 'errors'>
	self 
	    error: (self errorTable at: aSymbol ifAbsent: ['Unknown']) , ': ' , aString
    ]

    MySQLConnection class >> errorTable [
	<category: 'errors'>
	ErrorTable isNil 
	    ifTrue: 
		[ErrorTable := IdentityDictionary new.
		1 to: self errorTableMap size
		    by: 2
		    do: 
			[:i | 
			ErrorTable at: (self errorTableMap at: i)
			    put: (self errorTableMap at: i + 1)]].
	^ErrorTable
    ]

    MySQLConnection class >> errorTableMap [
	<category: 'errors'>
	^#(#protocol 'Invalid Protocol' #authentication 'Access denied' #setDatabase 'Could not set the database' #invalidQuery 'Invalid query')
    ]

    MySQLConnection class >> driverName [
	<category: 'instance creation'>
	^'MySQL'
    ]

    MySQLConnection class >> paramConnect: aParams user: aUserName password: aPassword [
	<category: 'instance creation'>
	| database connection host port |
	database := aParams at: 'dbname' ifAbsent: [nil].

	(aParams includesKey: 'mysql_socket')
	    ifTrue: [
		host := Sockets.UnixAddress uniqueInstance.
		port := aParams at: 'mysql_socket' ]
	    ifFalse: [
		host := aParams at: 'host' ifAbsent: ['127.0.0.1'].
		port := (aParams at: 'port' ifAbsent: [3306]) asInteger ].

	connection := self new.
	connection connectTo: host port: port.
	connection login: aUserName password: aPassword.
	database isNil ifFalse: [connection database: database].
	^connection
    ]

    MySQLConnection class >> byteArrayAsInteger: ba [
	<category: 'misc'>
	^self 
	    byteArrayAsInteger: ba
	    from: 1
	    for: ba size
    ]

    MySQLConnection class >> byteArrayAsInteger: ba from: anOffset for: aLength [
	<category: 'misc'>
	| shiftAmount anInteger |
	shiftAmount := 0.
	anInteger := 0.
	anOffset to: aLength
	    do: 
		[:index | 
		anInteger := anInteger bitOr: ((ba at: index) bitShift: shiftAmount).
		shiftAmount := shiftAmount + 8].
	^anInteger
    ]

    MySQLConnection class >> integerAsByteArray: int length: aLength [
	<category: 'misc'>
	| aByteArray shiftAmount mask |
	aByteArray := ByteArray new: aLength.
	shiftAmount := 0.
	mask := 255.
	1 to: aLength
	    do: 
		[:index | 
		aByteArray at: index put: (mask bitAnd: (int bitShift: shiftAmount)).
		shiftAmount := shiftAmount - 8].
	^aByteArray
    ]

    MySQLConnection class >> byteArrayAsByteString: ba [
	<category: 'misc'>
	| size s |
	size := ba size.
	s := String new: size.
	1 to: size
	    do: [:index | s at: index put: (Character value: (ba at: index))].
	^s
    ]

    beginTransaction [
	<category: 'querying'>
	^self do: 'START TRANSACTION'
    ]

    commitTransaction [
	<category: 'querying'>
	^self do: 'COMMIT'
    ]

    rollbackTransaction [
	<category: 'querying'>
	^self do: 'ROLLBACK'
    ]

    database [
	<category: 'querying'>
	^database
    ]

    do: aSQLQuery [
	<category: 'querying'>
	^(self prepare: aSQLQuery) execute
    ]

    select: aSQLQuery [
	<category: 'querying'>
	^(self prepare: aSQLQuery) execute
    ]

    prepare: aQuery [
	<category: 'querying'>
	^(MySQLStatement on: self) prepare: aQuery
    ]

    finalize [
	<category: 'closing'>
	self close
    ]

    close [
	<category: 'closing'>
	self
	    removeToBeFinalized;
	    closeRequest;
	    closeSocket
    ]

    closeRequest [
	<category: 'closing'>
	(self requestPacket writeStream)
	    nextPutCommand: #cmdQuit;
	    flush
    ]

    closeSocket [
	<category: 'closing'>
	socket isNil ifFalse: [socket close].
	socket := nil
    ]

    connectTo: host port: port [
	<category: 'initialize-release'>
	| messageText |
	socket := Sockets.Socket remote: host port: port.
	self addToBeFinalized.
	socket isNil ifTrue: [^self error: messageText].
	serverInfo := MySQLServerInfo new.
	serverInfo readFrom: self responsePacket
    ]

    database: aString [
	<category: 'initialize-release'>
	(self requestPacket writeStream)
	    nextPutCommand: #cmdInitializeDatabase message: aString;
	    flush.
	self responsePacket checkStatusOnError: #setDatabase.
	database := aString
    ]

    oldProtocolHashes: password [
	<category: 'initialize-release'>
	password isEmpty ifTrue: [^''].
	^{self hash2: password seed: serverInfo hashSeed}
    ]

    newProtocolHashes: password [
	<category: 'initialize-release'>
	password isEmpty ifTrue: [^String new: 1].
	^
	{self hashSHA1: password seed: serverInfo hashSeed.
	self hash2: password seed: serverInfo hashSeed}
    ]

    login: user password: password [
	<category: 'initialize-release'>
	| replyStream hashes userSent longPassword |
	replyStream := self replyPacket writeStream.
	serverInfo hashSeed size = 8 
	    ifTrue: 
		[hashes := self oldProtocolHashes: password.
		replyStream
		    nextPutAll: (self class integerAsByteArray: 1 length: 2) asByteString;
		    nextPutAll: (self class integerAsByteArray: 65536 length: 3) asByteString;
		    nextPutAllNullTerminated: user;
		    nextPutAllNullTerminated: hashes first;
		    flush]
	    ifFalse: 
		[hashes := self newProtocolHashes: password.
		replyStream
		    nextPutAll: (self class integerAsByteArray: 41477 length: 4) asByteString;
		    nextPutAll: (self class integerAsByteArray: 65536 length: 4) asByteString;
		    nextPut: 8 asCharacter;
		    next: 23 put: 0 asCharacter;
		    nextPutAllNullTerminated: user;
		    nextPut: hashes first size asCharacter;
		    nextPutAll: hashes first;
		    flush.
		(self responsePacket isStatus: 254 onError: #authenticate) 
		    ifTrue: 
			[replyStream := self replyPacket writeStream.
			replyStream
			    nextPutAll: hashes second;
			    flush]]
    ]

    hash: aString seed: aSeed for: hashMethod [
	<category: 'hashing'>
	^self class 
	    perform: hashMethod
	    with: aString
	    with: aSeed
    ]

    replyPacket [
	<category: 'accessing'>
	^(MySQLOutputPacket on: socket) 
	    packetNumber: responsePacket packetNumber + 1
    ]

    requestPacket [
	<category: 'accessing'>
	^MySQLOutputPacket on: socket
    ]

    responsePacket [
	<category: 'accessing'>
	^responsePacket := MySQLInputPacket on: socket
    ]

    hashSHA1: aString seed: aSeed [
	"This algorithm is for MySQL 4.1+."

	<category: 'hashing'>
	"Compute hash1 = SHA1(password), then hash2 = SHA1(hash1). The server
	 already knows this, as that is what is held in its password table
	 (preceded with a *)."

	| hashedString hashedStringSeeded result |
	hashedString := SHA1 digestOf: aString.
	hashedStringSeeded := SHA1 digestOf: hashedString.

	"Append hash2 to the salt sent by the server and hash that."
	hashedStringSeeded := SHA1 digestOf: aSeed , hashedStringSeeded.

	"Finally, XOR the result with SHA1(password).  The server takes this,
	 computes SHA1(salt.`SHA1 stored in DB`), uses the latter result to
	 undo the XOR, computes again SHA1, and compares that with the SHA1
	 stored in the DB."
	result := String new: 20.
	1 to: 20
	    do: 
		[:i | 
		result at: i
		    put: (Character 
			    value: ((hashedString at: i) bitXor: (hashedStringSeeded at: i)))].
	^result
    ]

    hash2: aString seed: longSeed [
	"This algorithm is for MySQL 3.22+."

	<category: 'hashing'>
	"Reserve a final byte for NULL termination"

	| hashedString maxValue result num1 num2 num3 aSeed |
	aSeed := longSeed copyFrom: 1 to: 8.
	hashedString := String new: aSeed size.
	result := self randomInit2: aString seed: aSeed.
	maxValue := 1073741823.
	num1 := result at: 1.
	num2 := result at: 2.
	1 to: hashedString size
	    do: 
		[:index | 
		num1 := (num1 * 3 + num2) \\ maxValue.
		num2 := (num1 + num2 + 33) \\ maxValue.
		num3 := (num1 / maxValue * 31) truncated + 64.
		hashedString at: index put: num3 asCharacter].
	num1 := (num1 * 3 + num2) \\ maxValue.
	num2 := (num1 + num2 + 33) \\ maxValue.
	num3 := (num1 / maxValue * 31) truncated.
	hashedString keysAndValuesDo: 
		[:index :character | 
		hashedString at: index put: (character asInteger bitXor: num3) asCharacter].
	^hashedString
    ]

    hash: aString [
	"Hash algorithm taken from mysql in order to send password to the server"

	<category: 'hashing'>
	| num1 num2 num3 |
	num1 := 1345345333.
	num2 := 305419889.
	num3 := 7.
	aString do: 
		[:character | 
		(character = Character space or: [character = Character tab]) 
		    ifFalse: 
			[| charValue |
			charValue := character asInteger.
			num1 := num1 
				    bitXor: ((num1 bitAnd: 63) + num3) * charValue + (num1 bitShift: 8).
			num2 := num2 + ((num2 bitShift: 8) bitXor: num1).
			num3 := num3 + charValue]].
	^Array with: (num1 bitAnd: 2147483647) with: (num2 bitAnd: 2147483647)
    ]

    randomInit2: aString seed: aSeed [
	<category: 'hashing'>
	| result array1 array2 |
	result := Array new: 2.
	array1 := self hash: aString.
	array2 := self hash: aSeed.
	result at: 1 put: ((array1 at: 1) bitXor: (array2 at: 1)) \\ 1073741823.
	result at: 2 put: ((array1 at: 2) bitXor: (array2 at: 2)) \\ 1073741823.
	^result
    ]

    primTableAt: aString ifAbsent: aBlock [
	| table |
	[
	    table := (MySQLTable name: aString connection: self)
		columnsArray;
		yourself ]
	    on: Error
	    do: [ :ex | ex return ].

	table isNil ifTrue: [ ^aBlock value ].
	^table
    ]
]



Object subclass: MySQLServerInfo [
    | protocol serverThread serverVersion charset status hashSeed options |
    
    <category: 'Mysql-Driver'>
    <comment: nil>

    charset [
	<category: 'accessing'>
	^charset
    ]

    status [
	<category: 'accessing'>
	^status
    ]

    hashSeed [
	<category: 'accessing'>
	^hashSeed
    ]

    options [
	<category: 'accessing'>
	^options
    ]

    protocol [
	<category: 'accessing'>
	^protocol
    ]

    serverThread [
	<category: 'accessing'>
	^serverThread
    ]

    readFrom: aResponsePacket [
	<category: 'reading'>
	self
	    readProtocolFrom: aResponsePacket;
	    readServerVersionFrom: aResponsePacket;
	    readServerThreadFrom: aResponsePacket;
	    readHashSeedFrom: aResponsePacket;
	    readOptionsFrom: aResponsePacket.
	aResponsePacket readStream atEnd 
	    ifFalse: 
		[self
		    readCharsetFrom: aResponsePacket;
		    readStatusFrom: aResponsePacket;
		    readMoreSeedFrom: aResponsePacket]
    ]

    readStatusFrom: aResponsePacket [
	<category: 'reading'>
	status := (aResponsePacket readStream next: 2) asByteArray asInteger.
	aResponsePacket readStream next: 13
    ]

    readCharsetFrom: aResponsePacket [
	<category: 'reading'>
	charset := aResponsePacket readStream next value
    ]

    readHashSeedFrom: aResponsePacket [
	<category: 'reading'>
	hashSeed := aResponsePacket readStream readNullTerminatedString
    ]

    readMoreSeedFrom: aResponsePacket [
	<category: 'reading'>
	hashSeed := hashSeed , aResponsePacket readStream readNullTerminatedString
    ]

    readOptionsFrom: aResponsePacket [
	<category: 'reading'>
	options := (aResponsePacket readStream next: 2) asByteArray asInteger
    ]

    readProtocolFrom: aResponsePacket [
	<category: 'reading'>
	protocol := aResponsePacket readStatusOnError: #protocol.
	protocol = 10 ifFalse: [MySQLConnection error: #protocol]
    ]

    readServerThreadFrom: aResponsePacket [
	<category: 'reading'>
	serverThread := (aResponsePacket readStream next: 4) asByteArray asInteger
    ]

    readServerVersionFrom: aResponsePacket [
	<category: 'reading'>
	serverVersion := aResponsePacket readStream readNullTerminatedString
    ]
]

PK
     �Mh@Ah�o�
  �
    Statement.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   MySQL DBI driver - Statement class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Markus Fritsche,
| refactored/rewritten by Paolo Bonzini
|
| Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
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


Statement subclass: MySQLStatement [
    | statement isSelect |

    <category: 'DBI-Framework'>
    <comment: 'I represent a prepared statement.'>

    SelectQueries := #('EXPLAIN' 'SELECT' 'SHOW' 'DESCRIBE') asSet.

    getCommand [
        | readStream writeStream aCharacter |
        writeStream := WriteStream on: String new.
        readStream := ReadStream on: statement.
        readStream skipSeparators.
        [readStream atEnd
	    or: [aCharacter := readStream next. aCharacter isSeparator]]
                whileFalse: [writeStream nextPut: aCharacter asUppercase].
        ^writeStream contents
    ]

    prepare: aSQLString [
	"Prepare the statement in aSQLString."

	<category: 'private'>
	statement := aSQLString.
	isSelect := SelectQueries includes: self getCommand.
    ]

    statement [
	"Return the SQL template."
	^statement
    ]

    execute [
	"Execute with no parameters"

	<category: 'abstract'>
        | queryInfo |
        connection requestPacket writeStream
            nextPutCommand: #cmdQuery message: statement;
            flush.

	^MySQLResultSet on: self
    ]

    isSelect [
	"Return whether the query is a SELECT-type query."
	^isSelect
    ]

    executeWithAll: aParams [
	"Execute taking parameters from the Collection aParams."

	<category: 'not implemented'>
	self notYetImplemented
    ]
]

PK
     �Zh@5� �u  u    package.xmlUT	 ��XO��XOux �  �  <package>
  <name>DBD-MySQL</name>
  <namespace>DBI.MySQL</namespace>
  <test>
    <namespace>DBI.MySQL</namespace>
    <prereq>DBD-MySQL</prereq>
    <prereq>SUnit</prereq>
    <sunit>DBI.MySQL.DBIMySQLTestSuite</sunit>
    <filein>MySQLTests.st</filein>
  </test>
  <prereq>DBI</prereq>
  <prereq>Digest</prereq>
  <prereq>Sockets</prereq>

  <filein>Column.st</filein>
  <filein>Connection.st</filein>
  <filein>Extensions.st</filein>
  <filein>ResultSet.st</filein>
  <filein>Row.st</filein>
  <filein>Statement.st</filein>
  <filein>Table.st</filein>
  <filein>TableColumnInfo.st</filein>
  <file>ChangeLog</file>
</package>PK
     �Mh@6`�$�M  �M    MySQLTests.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   MySQL DBI driver unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Paolo Bonzini
|
| Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
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



TestCase subclass: DBIMySQLBaseTestCase [
    | connection testSupport testProgress |
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    setUp [
	<category: 'initialize-release'>
	super setUp.
	testSupport := DBIMySQLTestSupport mysqlTestSupport.
	connection := testSupport connect.
	testProgress := TestProgress new: testSupport class numRowsToInsert.
	testProgress
    ]

    tearDown [
	<category: 'initialize-release'>
	connection close
    ]
]



DBIMySQLBaseTestCase subclass: DBIMySQLCreateTableTestCase [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    createTable [
	<category: 'tests'>
	| result |
	Transcript show: 'Creating table: ' , testSupport class tableName , '...'.
	result := connection do: testSupport createTable.
	Transcript
	    show: ' Done';
	    nl.
	self should: [result isSelect not and: [result rowsAffected = 0]]
    ]
]



DBIMySQLBaseTestCase subclass: DBIMySQLDropTableTestCase [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    dropTableIfExists [
	<category: 'tests'>
	| result |
	Transcript show: 'Dropping table: ' , testSupport class tableName , '...'.
	result := connection 
		    do: 'drop table if exists ' , testSupport class tableName.
	Transcript
	    show: ' Done';
	    nl.
	self should: [result isSelect not and: [result rowsAffected = 0]]
    ]

    dropTable [
	<category: 'tests'>
	| result |
	Transcript show: 'Dropping table: ' , testSupport class tableName , '...'.
	result := connection do: 'drop table ' , testSupport class tableName.
	Transcript
	    show: ' Done';
	    nl.
	self should: [result isSelect not and: [result rowsAffected = 0]]
    ]
]



DBIMySQLBaseTestCase subclass: DBIMySQLDeleteTestCase [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    deleteRows [
	<category: 'tests'>
	| result |
	Transcript 
	    show: 'Deleting ' , testSupport class numRowsToInsert printString 
		    , ' rows...'.
	result := connection do: 'delete from ' , testSupport class tableName.
	Transcript
	    show: ' Done';
	    nl.
	"Value is either 0 or numRowsToInsert, depending on the version"
	self should: [result isSelect not]
    ]
]



DBIMySQLBaseTestCase subclass: DBIMySQLInsertTestCase [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    insertRow [
	<category: 'tests'>
	| result |
	result := connection do: testSupport insertIntoTable.
	testProgress nextStep.
	^result
    ]

    insertRows [
	<category: 'tests'>
	| ok result |
	Transcript 
	    show: 'Inserting ' , testSupport class numRowsToInsert printString 
		    , ' rows'.
	ok := true.
	testSupport class numRowsToInsert timesRepeat: 
		[result := self insertRow.
		ok := ok and: [result isSelect not	"and: [result rowsAffected = 1]"]].
	self should: [ok]
    ]
]



DBIMySQLBaseTestCase subclass: DBIMySQLSelectTestCase [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    checkResult: resultSet [
	<category: 'tests'>
	| count numColumns row |
	count := 0.
	numColumns := resultSet columns size.
	[resultSet atEnd] whileFalse: 
		[row := resultSet next.
		1 to: numColumns do: [:columnNum | (row atIndex: columnNum) printString].
		count := count + 1.
		testProgress nextStep].
	^count
    ]

    selectRows [
	<category: 'tests'>
	| result |
	Transcript 
	    show: 'Selecting ' , testSupport class numRowsToInsert printString 
		    , ' rows'.
	result := connection 
		    select: 'select * from ' , testSupport class tableName.
	self should: 
		[result isSelect 
		    and: [(self checkResult: result) = testSupport class numRowsToInsert]]
    ]
]



Object subclass: RangedRandom [
    | random highValue lowValue range numRandomBits |
    
    <category: 'Mysql-Driver-Tests'>
    <comment: nil>

    RangedRandom class >> randomBits [
	<category: 'constants'>
	^16
    ]

    RangedRandom class >> randomFactor [
	<category: 'constants'>
	^1000000
    ]

    RangedRandom class >> randomMask [
	<category: 'constants'>
	^65535
    ]

    RangedRandom class >> between: anInteger and: anInteger2 [
	<category: 'instance creation'>
	^self new between: anInteger and: anInteger2
    ]

    between: anInteger and: anInteger2 [
	<category: 'initialize'>
	random := Random new.
	highValue := anInteger max: anInteger2.
	lowValue := anInteger min: anInteger2.
	range := highValue - lowValue.
	range > 0 ifTrue: [range := range + 1].
	numRandomBits := self randomBitsNeededFor: range
    ]

    next [
	<category: 'accessing'>
	| aRandom |
	aRandom := self nextRandom \\ range.
	aRandom = 0 ifTrue: [(self rangeIncludes: 0) ifFalse: [^self next]].
	^lowValue + aRandom
    ]

    maskFor: numBits [
	<category: 'private'>
	^(self class randomMask bitShift: numBits - self class randomBits) 
	    bitAnd: self class randomMask
    ]

    nextRandom [
	<category: 'private'>
	| nextRandom numBits numBitsToUse |
	nextRandom := 0.
	numBits := numRandomBits.
	[numBits = 0] whileFalse: 
		[numBitsToUse := numBits min: self class randomBits.
		nextRandom := (nextRandom bitShift: numBitsToUse) 
			    bitOr: ((random next * self class randomFactor) asInteger 
				    bitAnd: (self maskFor: numBitsToUse)).
		numBits := numBits - numBitsToUse].
	^nextRandom
    ]

    randomBitsNeededFor: anInteger [
	<category: 'private'>
	| numBits |
	numBits := (anInteger log: 2) ceiling.
	(1 bitShift: numBits) < anInteger ifTrue: [numBits := numBits + 1].
	^numBits
    ]

    rangeIncludes: aValue [
	<category: 'private'>
	^highValue >= aValue and: [lowValue <= aValue]
    ]
]



Object subclass: TestProgress [
    | resolution totalSteps numSteps stepsPerLevel currentStep displayCharacter |
    
    <category: 'Mysql-Driver-Tests'>
    <comment: nil>

    TestProgress class >> new: aNumSteps [
	<category: 'instance creation'>
	^self new initialize: aNumSteps
    ]

    TestProgress class >> defaultDisplayCharacter [
	<category: 'defaults'>
	^$.
    ]

    TestProgress class >> defaultResolution [
	<category: 'defaults'>
	^20
    ]

    initialize: aNumSteps [
	<category: 'initialize-release'>
	numSteps := aNumSteps.
	totalSteps := 0.
	resolution := self class defaultResolution.
	stepsPerLevel := numSteps // resolution.
	currentStep := 0.
	displayCharacter := self class defaultDisplayCharacter
    ]

    checkSteps [
	<category: 'private'>
	currentStep >= stepsPerLevel 
	    ifTrue: 
		[currentStep := 0.
		Transcript
		    nextPut: displayCharacter;
		    flush].
	totalSteps = numSteps 
	    ifTrue: 
		[Transcript
		    show: ' Done';
		    nl]
    ]

    currentStep [
	<category: 'accessing'>
	^currentStep
    ]

    displayCharacter [
	<category: 'accessing'>
	^displayCharacter
    ]

    displayCharacter: anObject [
	<category: 'accessing'>
	displayCharacter := anObject
    ]

    nextStep [
	<category: 'accessing'>
	currentStep := currentStep + 1.
	totalSteps := totalSteps + 1.
	self checkSteps
    ]

    numSteps [
	<category: 'accessing'>
	^numSteps
    ]

    resolution [
	<category: 'accessing'>
	^resolution
    ]

    stepsPerLevel [
	<category: 'accessing'>
	^stepsPerLevel
    ]

    totalSteps [
	<category: 'accessing'>
	^totalSteps
    ]
]



TestSuite subclass: DBIMySQLTestSuite [
    
    <comment: nil>
    <category: 'Mysql-Driver-Tests'>

    DBIMySQLTestSuite class >> suite [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	"super initialize."

	<category: 'initialize-release'>
	self name: 'DBIMySQL-Test'.
	self addTest: (DBIMySQLDropTableTestCase selector: #dropTableIfExists).
	self addTest: (DBIMySQLCreateTableTestCase selector: #createTable).
	self addTest: (DBIMySQLInsertTestCase selector: #insertRows).
	self addTest: (DBIMySQLSelectTestCase selector: #selectRows).
	self addTest: (DBIMySQLDeleteTestCase selector: #deleteRows).
	self addTest: (DBIMySQLDropTableTestCase selector: #dropTable).
	Transcript nl
    ]
]



Object subclass: DBIMySQLTestSupport [
    | randomGenerators mysqlTypes mysqlValues enumSetValues |
    
    <category: 'Mysql-Driver-Tests'>
    <comment: nil>

    Instance := nil.

    DBIMySQLTestSupport class >> mysqlTestSupport [
	<category: 'singleton'>
	Instance isNil ifTrue: [Instance := self new initialize].
	^Instance
    ]

    DBIMySQLTestSupport class >> resetMysqlTestSupport [
	<category: 'singleton'>
	Instance := nil
    ]

    DBIMySQLTestSupport class >> numRowsToInsert [
	<category: 'constants'>
	^40
    ]

    DBIMySQLTestSupport class >> tableName [
	<category: 'constants'>
	^'DBIMySQLTestTable'
    ]

    createDelimitedStringFor: aCollection delimiter: aDelimiter using: aBlock [
	<category: 'private'>
	| collection writeStream |
	collection := aCollection asOrderedCollection.
	collection size = 0 ifTrue: [^''].
	writeStream := WriteStream on: String new.
	writeStream nextPutAll: (aBlock value: collection first).
	2 to: collection size
	    do: 
		[:index | 
		writeStream
		    nextPutAll: aDelimiter;
		    nextPutAll: (aBlock value: (collection at: index))].
	^writeStream contents
    ]

    enumSetValues [
	<category: 'private'>
	^enumSetValues
    ]

    enumValues [
	<category: 'private'>
	^self 
	    createDelimitedStringFor: self enumSetValues
	    delimiter: ', '
	    using: [:enumValue | '''' , enumValue , '''']
    ]

    fieldNameFor: aType [
	<category: 'private'>
	^'test_' , aType
    ]

    getFieldDefinitionFor: aType [
	<category: 'private'>
	| writeStream |
	writeStream := WriteStream on: String new.
	self writeFieldDefinitionFor: aType on: writeStream.
	^writeStream contents
    ]

    nextRandomFor: aType [
	<category: 'private'>
	^(randomGenerators at: aType) next
    ]

    writeFieldDefinitionFor: aType on: aWriteStream [
	<category: 'private'>
	aWriteStream
	    nextPutAll: (self fieldNameFor: aType);
	    nextPut: $ ;
	    nextPutAll: (mysqlTypes at: aType)
    ]

    connect [
	<category: 'accessing'>
	| user password db isUser |
	user := TestSuitesScripter variableAt: 'mysqluser' ifAbsent: [nil].
	isUser := user notNil.
	isUser ifFalse: [user := 'root'].
	password := TestSuitesScripter variableAt: 'mysqlpassword'
		    ifAbsent: [isUser ifTrue: [nil] ifFalse: ['root']].
	db := TestSuitesScripter variableAt: 'mysqldb' ifAbsent: ['test'].
	^DBI.Connection 
	    connect: 'dbi:MySQL:dbname=' , db
	    user: user
	    password: password
    ]

    createTable [
	<category: 'accessing'>
	^self createTableNamed: self class tableName
    ]

    createTableNamed: aName [
	<category: 'accessing'>
	| writeStream |
	writeStream := WriteStream on: String new.
	writeStream
	    nextPutAll: 'CREATE TABLE ';
	    nextPutAll: aName;
	    nextPut: $(;
	    nl.
	writeStream nextPutAll: (self 
		    createDelimitedStringFor: mysqlTypes keys
		    delimiter: ', '
		    using: [:field | self getFieldDefinitionFor: field]).
	^writeStream
	    nextPut: $);
	    contents
    ]

    insertIntoTable [
	<category: 'accessing'>
	^self insertIntoTableNamed: self class tableName
    ]

    insertIntoTableNamed: aName [
	<category: 'accessing'>
	| writeStream |
	writeStream := WriteStream on: String new.
	writeStream
	    nextPutAll: 'INSERT INTO ';
	    nextPutAll: aName;
	    nextPutAll: ' (';
	    nl.
	writeStream nextPutAll: (self 
		    createDelimitedStringFor: mysqlTypes keys
		    delimiter: ', '
		    using: [:field | self fieldNameFor: field]).
	writeStream
	    nextPutAll: ') VALUES (';
	    nl.
	writeStream
	    nextPutAll: (self 
			createDelimitedStringFor: mysqlTypes keys
			delimiter: ', '
			using: 
			    [:type | 
			    | valueSelector |
			    valueSelector := mysqlValues at: type ifAbsent: #null.
			    DBI.FieldConverter uniqueInstance
				printString: ((self perform: valueSelector) value: type value: self)]);
	    nextPut: $).
	^writeStream contents
    ]

    charValue [
	<category: 'private-values'>
	^[:type :support | 'Z']
    ]

    dateTimeValue [
	<category: 'private-values'>
	^
	[:type :support | 
	DateTime 
	    fromDays: (support dateValue value: #date value: support) days
	    seconds: (support timeValue value: #time value: support) seconds
	    offset: Duration zero]
    ]

    dateValue [
	<category: 'private-values'>
	^[:type :support | Date fromDays: (support nextRandomFor: type)]
    ]

    doubleValue [
	<category: 'private-values'>
	^[:type :support | 1.7976931348623d308]
    ]

    enumValue [
	<category: 'private-values'>
	^[:type :support | support enumSetValues at: (support nextRandomFor: type)]
    ]

    floatValue [
	<category: 'private-values'>
	^[:type :support | 3.4028235e38]
    ]

    intValue [
	<category: 'private-values'>
	^[:type :support | support nextRandomFor: type]
    ]

    null [
	<category: 'private-values'>
	^[:type :support | 'NULL']
    ]

    stringValue [
	<category: 'private-values'>
	^[:type :support | 'This is a String with UPPER and lower CaSeS']
    ]

    timestampValue [
	<category: 'private-values'>
	^[:type :support | DateTime now]
    ]

    timeValue [
	<category: 'private-values'>
	^[:type :support | Time fromSeconds: (support nextRandomFor: type)]
    ]

    initializeEnumSetValues [
	<category: 'private-initialize'>
	enumSetValues add: 'Apples'.
	enumSetValues add: 'Bananas'.
	enumSetValues add: 'Grapes'.
	enumSetValues add: 'Oranges'.
	enumSetValues add: 'Peaches'
    ]

    initializeMysqlTypes [
	<category: 'private-initialize'>
	mysqlTypes
	    at: #tinyInt put: 'TINYINT';
	    at: #tinyIntUnsigned put: 'TINYINT UNSIGNED';
	    at: #tinyIntZerofill put: 'TINYINT ZEROFILL';
	    at: #tinyIntUnsignedZerofill put: 'TINYINT UNSIGNED ZEROFILL';
	    at: #smallInt put: 'SMALLINT';
	    at: #smallIntUnsigned put: 'SMALLINT UNSIGNED';
	    at: #smallIntZerofill put: 'SMALLINT ZEROFILL';
	    at: #smallIntUnsignedZerofill put: 'SMALLINT UNSIGNED ZEROFILL';
	    at: #mediumInt put: 'MEDIUMINT';
	    at: #mediumIntUnsigned put: 'MEDIUMINT UNSIGNED';
	    at: #mediumIntZerofill put: 'MEDIUMINT ZEROFILL';
	    at: #mediumIntUnsignedZerofill put: 'MEDIUMINT UNSIGNED ZEROFILL';
	    at: #int put: 'INT';
	    at: #intUnsigned put: 'INT UNSIGNED';
	    at: #intZerofill put: 'INT ZEROFILL';
	    at: #intUnsignedZerofill put: 'INT UNSIGNED ZEROFILL';
	    at: #bigInt put: 'BIGINT';
	    at: #bigIntUnsigned put: 'BIGINT UNSIGNED';
	    at: #bigIntZerofill put: 'BIGINT ZEROFILL';
	    at: #bigIntUnsignedZerofill put: 'BIGINT UNSIGNED ZEROFILL';
	    at: #float put: 'FLOAT(4)';
	    at: #double put: 'FLOAT(8)';
	    at: #decimal put: 'DECIMAL(10, 5)';
	    at: #date put: 'DATE';
	    at: #time put: 'TIME';
	    at: #dateTime put: 'DATETIME';
	    at: #timestamp put: 'TIMESTAMP';
	    at: #char put: 'CHAR';
	    at: #varChar put: 'VARCHAR(70)';
	    at: #tinyBlob put: 'TINYBLOB';
	    at: #blob put: 'BLOB';
	    at: #mediumBlob put: 'MEDIUMBLOB';
	    at: #longBlob put: 'LONGBLOB';
	    at: #tinyText put: 'TINYTEXT';
	    at: #text put: 'TEXT';
	    at: #mediumText put: 'MEDIUMTEXT';
	    at: #enum put: 'ENUM(' , self enumValues , ')';
	    at: #set put: 'SET(' , self enumValues , ')'
    ]

    initializeMysqlValues [
	<category: 'private-initialize'>
	mysqlValues
	    at: #tinyInt put: #intValue;
	    at: #tinyIntUnsigned put: #intValue;
	    at: #tinyIntZerofill put: #intValue;
	    at: #tinyIntUnsignedZerofill put: #intValue;
	    at: #smallInt put: #intValue;
	    at: #smallIntUnsigned put: #intValue;
	    at: #smallIntZerofill put: #intValue;
	    at: #smallIntUnsignedZerofill put: #intValue;
	    at: #mediumInt put: #intValue;
	    at: #mediumIntUnsigned put: #intValue;
	    at: #mediumIntZerofill put: #intValue;
	    at: #mediumIntUnsignedZerofill put: #intValue;
	    at: #int put: #intValue;
	    at: #intUnsigned put: #intValue;
	    at: #intZerofill put: #intValue;
	    at: #intUnsignedZerofill put: #intValue;
	    at: #bigInt put: #intValue;
	    at: #bigIntUnsigned put: #intValue;
	    at: #bigIntZerofill put: #intValue;
	    at: #bigIntUnsignedZerofill put: #intValue;
	    at: #float put: #floatValue;
	    at: #double put: #doubleValue;
	    at: #decimal put: #doubleValue;
	    at: #date put: #dateValue;
	    at: #time put: #timeValue;
	    at: #timestamp put: #timestampValue;
	    at: #dateTime put: #dateTimeValue;
	    at: #char put: #charValue;
	    at: #varChar put: #stringValue;
	    at: #tinyBlob put: #stringValue;
	    at: #blob put: #stringValue;
	    at: #mediumBlob put: #stringValue;
	    at: #longBlob put: #stringValue;
	    at: #tinyText put: #stringValue;
	    at: #text put: #stringValue;
	    at: #mediumText put: #stringValue;
	    at: #enum put: #enumValue;
	    at: #set put: #enumValue
    ]

    initializeRandomGenerators [
	<category: 'private-initialize'>
	randomGenerators
	    at: #tinyInt put: (RangedRandom between: -128 and: 127);
	    at: #tinyIntUnsigned put: (RangedRandom between: 0 and: 255);
	    at: #tinyIntZerofill put: (randomGenerators at: #tinyInt);
	    at: #tinyIntUnsignedZerofill put: (randomGenerators at: #tinyIntUnsigned);
	    at: #smallInt put: (RangedRandom between: -32768 and: 32767);
	    at: #smallIntUnsigned put: (RangedRandom between: 0 and: 65535);
	    at: #smallIntZerofill put: (randomGenerators at: #smallInt);
	    at: #smallIntUnsignedZerofill put: (randomGenerators at: #smallIntUnsigned);
	    at: #mediumInt put: (RangedRandom between: -8388608 and: 8388607);
	    at: #mediumIntUnsigned put: (RangedRandom between: 0 and: 16777215);
	    at: #mediumIntZerofill put: (randomGenerators at: #mediumInt);
	    at: #mediumIntUnsignedZerofill
		put: (randomGenerators at: #mediumIntUnsigned);
	    at: #int put: (RangedRandom between: -2147483648 and: 2147483647);
	    at: #intUnsigned put: (RangedRandom between: 0 and: 4294967295);
	    at: #intZerofill put: (randomGenerators at: #int);
	    at: #intUnsignedZerofill put: (randomGenerators at: #intUnsigned);
	    at: #bigInt
		put: (RangedRandom between: -9223372036854775808 and: 9223372036854775807);
	    at: #bigIntUnsigned
		put: (RangedRandom between: 0 and: 18446744073709551615);
	    at: #bigIntZerofill put: (randomGenerators at: #bigInt);
	    at: #bigIntUnsignedZerofill put: (randomGenerators at: #bigIntUnsigned);
	    at: #date put: (RangedRandom between: -329083 and: 2958098);
	    at: #time put: (RangedRandom between: 0 and: 86399);
	    at: #enum put: (RangedRandom between: 1 and: 5);
	    at: #set put: (randomGenerators at: #enum)
    ]

    initialize [
	<category: 'initialize-release'>
	randomGenerators := IdentityDictionary new.
	mysqlValues := IdentityDictionary new.
	enumSetValues := OrderedCollection new.
	mysqlTypes := IdentityDictionary new.
	self
	    initializeEnumSetValues;
	    initializeRandomGenerators;
	    initializeMysqlValues;
	    initializeMysqlTypes
    ]
]

PK
     �Mh@�����  �    Table.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   MySQL DBI driver - Table class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini
|
| Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
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
 ======================================================================
"



Table subclass: MySQLTable [
    
    <category: 'DBD-MySQL'>
    <comment: nil>

    | columnsArray |

    columnsArray [
	"Answer an array of column name -> ColumnInfo pairs."
	| query resultSet i |
	columnsArray isNil ifTrue: [
	    query := 'show columns from `%2`.`%1`' % {
		    self name. self connection database }.
	    resultSet := self connection select: query.
	    i := 0.
	    columnsArray := resultSet rows collect: [ :row |
		MySQLTableColumnInfo from: row index: (i := i + 1) ] ].
	^columnsArray
    ]

    printAttribute: each on: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $`;
	    nextPutAll: each;
	    nextPut: $`
    ]
]
PK
     �Mh@3�Y�
  
    ResultSet.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   MySQL DBI driver - ResultSet class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Markus Fritsche,
| refactored/rewritten by Paolo Bonzini
|
| Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
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


ResultSet subclass: MySQLResultSet [
    | index rows rowCount columns columnsDict |
    
    <comment: nil>
    <category: 'DBI-Drivers'>

    MySQLResultSet class >> on: aStatement [
	<category: 'private'>
	^(self basicNew)
	    statement: aStatement;
	    readFrom: aStatement connection;
	    yourself
    ]

    readFrom: aConnection [
	<category: 'private'>
	rowCount := self isSelect
		ifTrue: [ self readSelectFrom: aConnection ]
		ifFalse: [ self readUpdateFrom: aConnection ]
    ]

    readUpdateFrom: aConnection [
	<category: 'private'>
	| responsePacket |
        responsePacket := aConnection responsePacket.
        responsePacket checkStatusOnError: #invalidQuery.
        ^(responsePacket readStream next: 2) asByteArray asInteger
    ]

    readSelectFrom: aConnection [
	<category: 'private'>
	| row responsePacket column |
        responsePacket := aConnection responsePacket.
        columns := Array
                new: (responsePacket readStatusOnError: #invalidQuery).

        1 to: columns size do: [:index |
            columns at: index put: (column := MySQLColumnInfo new).
	    column readFrom: aConnection responsePacket readStream index: index].

        responsePacket := aConnection responsePacket.
        responsePacket checkForStatus: 254 onError: #invalidQuery.

	rows := OrderedCollection new.
	[
	    row := MySQLRow on: self readFrom: aConnection responsePacket readStream.
	    row isEmpty
	] whileFalse: [ rows addLast: row ].

	index := 0.
	^rows size
    ]

    position [
	<category: 'cursor access'>
	^index
    ]

    position: anInteger [
	<category: 'cursor access'>
        (anInteger between: 0 and: self size)
            ifTrue: [ index := anInteger ]
            ifFalse: [ SystemExceptions.IndexOutOfRange signalOn: self withIndex: anInteger ].
	^index
    ]

    next [
	<category: 'cursor access'>
	self atEnd ifTrue: [self error: 'No more rows'].
	index := index + 1.
	^rows at: index
    ]

    atEnd [
	<category: 'cursor access'>
	^index >= self rowCount
    ]

    valueAtRow: aRowNum column: aColNum [
	<category: 'private'>
	^(rows at: aRowNum) atIndex: aColNum
    ]

    isSelect [
	<category: 'accessing'>
	^self statement isSelect
    ]

    isDML [
	<category: 'accessing'>
	^self statement isSelect not
    ]

    rowCount [
	<category: 'accessing'>
	self isSelect ifFalse: [super rowCount].
	^rowCount
    ]

    rowsAffected [
	<category: 'accessing'>
	self isDML ifFalse: [super rowsAffected].
	^rowCount
    ]

    columnsArray [
	<category: 'accessing'>
	^columns
    ]

    columns [
	<category: 'accessing'>
	| columnsDict |
	columnsDict isNil 
	    ifTrue: 
		[columnsDict := LookupTable new: columns size.
		columns do: [:col | columnsDict at: col name put: col]].
	^columnsDict
    ]

    columnNames [
	"Answer the names of the columns in this result set."

	<category: 'accessing'>
	^columns collect: [:col | col name]
    ]

    columnCount [
	"Answer the number of columns in the result set."

	<category: 'accessing'>
	^columns size
    ]

    rows [
	"This is slightly more efficient than the default method."

	<category: 'accessing'>
	^rows
    ]

    release [
	"Clear the result set."

	<category: 'MySQL specific'>
	columns := rows := nil
    ]
]
PK
     �Mh@);�`  `    Extensions.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   MySQL DBI driver - Base class extensions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Markus Fritsche,
| refactored/rewritten by Paolo Bonzini
|
| Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
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




ByteArray extend [

    asInteger [
	<category: 'accessing'>
	| shiftAmount anInteger |
	shiftAmount := 0.
	anInteger := 0.
	1 to: self size
	    do: 
		[:index | 
		anInteger := anInteger bitOr: ((self at: index) bitShift: shiftAmount).
		shiftAmount := shiftAmount + 8].
	^anInteger
    ]

    asByteString [
	<category: 'accessing'>
	| stream |
	stream := WriteStream on: String new.
	1 to: self size
	    do: [:x | stream nextPut: (Character value: (self basicAt: x))].
	^stream contents
    ]

]

PK
     �Mh@3�p�X6  X6  	  Column.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   MySQL DBI driver - ColumnInfo class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Markus Fritsche,
| refactored/rewritten by Paolo Bonzini
|
| Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
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



ColumnInfo subclass: MySQLColumnInfo [
    | table name size type flags decimalPlaces charset index |
    
    <comment: nil>
    <category: 'Mysql-Driver'>

    Types := nil.
    ConverterSelectors := nil.
    TypeNames := nil.

    MySQLColumnInfo class >> buildTypeNameMap [
	<category: 'private-initialize'>
	TypeNames := Dictionary new.
	TypeNames
	    at: MySQLColumnInfo bitType put: 'bit';
	    at: MySQLColumnInfo tinyType put: 'tinyint';
	    at: MySQLColumnInfo shortType put: 'smallint';
	    at: MySQLColumnInfo int24Type put: 'mediumint';
	    at: MySQLColumnInfo longType put: 'int';
	    at: MySQLColumnInfo longlongType put: 'bigint';
	    at: MySQLColumnInfo floatType put: 'float(4)';
	    at: MySQLColumnInfo doubleType put: 'float(8)';
	    at: MySQLColumnInfo oldDecimalType put: 'decimal';
	    at: MySQLColumnInfo decimalType put: 'decimal';
	    at: MySQLColumnInfo newDateType put: 'date';
	    at: MySQLColumnInfo dateType put: 'date';
	    at: MySQLColumnInfo datetimeType put: 'datetime';
	    at: MySQLColumnInfo timeType put: 'time';
	    at: MySQLColumnInfo timestampType put: 'timestamp';
	    at: MySQLColumnInfo enumType put: 'enum';
	    at: MySQLColumnInfo setType put: 'set';
	    at: MySQLColumnInfo tinyBlobType put: 'tinyblob';
	    at: MySQLColumnInfo mediumBlobType put: 'mediumblob';
	    at: MySQLColumnInfo longBlobType put: 'longblob';
	    at: MySQLColumnInfo blobType put: 'blob';
	    at: MySQLColumnInfo varCharType put: 'varchar';
	    at: MySQLColumnInfo varStringType put: 'varchar';
	    at: MySQLColumnInfo stringType put: 'string'
    ]

    MySQLColumnInfo class >> buildTypeMap [
	<category: 'private-initialize'>
	Types := Dictionary new.
	Types
	    at: MySQLColumnInfo bitType put: #toBoolean:;
	    at: MySQLColumnInfo tinyType put: #toInteger:;
	    at: MySQLColumnInfo shortType put: #toInteger:;
	    at: MySQLColumnInfo longType put: #toInteger:;
	    at: MySQLColumnInfo int24Type put: #toInteger:;
	    at: MySQLColumnInfo longlongType put: #toInteger:;
	    at: MySQLColumnInfo floatType put: #toFloat:;
	    at: MySQLColumnInfo doubleType put: #toDouble:;
	    at: MySQLColumnInfo oldDecimalType put: #toDouble:;
	    at: MySQLColumnInfo decimalType put: #toDouble:;
	    at: MySQLColumnInfo newDateType put: #toDate:;
	    at: MySQLColumnInfo dateType put: #toDate:;
	    at: MySQLColumnInfo datetimeType put: #toDateTime:;
	    at: MySQLColumnInfo timeType put: #toTime:;
	    at: MySQLColumnInfo timestampType put: #toTimestamp:;
	    at: MySQLColumnInfo enumType put: #toString:;
	    at: MySQLColumnInfo setType put: #toSet:;
	    at: MySQLColumnInfo tinyBlobType put: #toByteArray:;
	    at: MySQLColumnInfo mediumBlobType put: #toByteArray:;
	    at: MySQLColumnInfo longBlobType put: #toByteArray:;
	    at: MySQLColumnInfo blobType put: #toByteArray:;
	    at: MySQLColumnInfo varCharType put: #toString:;
	    at: MySQLColumnInfo varStringType put: #toString:;
	    at: MySQLColumnInfo stringType put: #toString:
    ]

    MySQLColumnInfo class >> initialize [
	<category: 'initialize-release'>
	self
	    buildTypeMap;
	    buildTypeNameMap
    ]

    MySQLColumnInfo class >> bitType [
	<category: 'constants-types'>
	^16
    ]

    MySQLColumnInfo class >> blobType [
	<category: 'constants-types'>
	^252
    ]

    MySQLColumnInfo class >> datetimeType [
	<category: 'constants-types'>
	^12
    ]

    MySQLColumnInfo class >> newDateType [
	<category: 'constants-types'>
	^14
    ]

    MySQLColumnInfo class >> dateType [
	<category: 'constants-types'>
	^10
    ]

    MySQLColumnInfo class >> oldDecimalType [
	<category: 'constants-types'>
	^0
    ]

    MySQLColumnInfo class >> decimalType [
	<category: 'constants-types'>
	^246
    ]

    MySQLColumnInfo class >> doubleType [
	<category: 'constants-types'>
	^5
    ]

    MySQLColumnInfo class >> enumType [
	<category: 'constants-types'>
	^247
    ]

    MySQLColumnInfo class >> floatType [
	<category: 'constants-types'>
	^4
    ]

    MySQLColumnInfo class >> int24Type [
	<category: 'constants-types'>
	^9
    ]

    MySQLColumnInfo class >> longBlobType [
	<category: 'constants-types'>
	^251
    ]

    MySQLColumnInfo class >> longlongType [
	<category: 'constants-types'>
	^8
    ]

    MySQLColumnInfo class >> longType [
	<category: 'constants-types'>
	^3
    ]

    MySQLColumnInfo class >> mediumBlobType [
	<category: 'constants-types'>
	^250
    ]

    MySQLColumnInfo class >> nullType [
	<category: 'constants-types'>
	^6
    ]

    MySQLColumnInfo class >> setType [
	<category: 'constants-types'>
	^248
    ]

    MySQLColumnInfo class >> shortType [
	<category: 'constants-types'>
	^2
    ]

    MySQLColumnInfo class >> stringType [
	<category: 'constants-types'>
	^254
    ]

    MySQLColumnInfo class >> timestampType [
	<category: 'constants-types'>
	^7
    ]

    MySQLColumnInfo class >> timeType [
	<category: 'constants-types'>
	^11
    ]

    MySQLColumnInfo class >> tinyBlobType [
	<category: 'constants-types'>
	^249
    ]

    MySQLColumnInfo class >> tinyType [
	<category: 'constants-types'>
	^1
    ]

    MySQLColumnInfo class >> varCharType [
	<category: 'constants-types'>
	^15
    ]

    MySQLColumnInfo class >> varStringType [
	<category: 'constants-types'>
	^253
    ]

    MySQLColumnInfo class >> yearType [
	<category: 'constants-types'>
	^13
    ]

    MySQLColumnInfo class >> autoIncrementFlag [
	<category: 'constants-flags'>
	^512
    ]

    MySQLColumnInfo class >> binaryFlag [
	<category: 'constants-flags'>
	^128
    ]

    MySQLColumnInfo class >> blobFlag [
	<category: 'constants-flags'>
	^16
    ]

    MySQLColumnInfo class >> enumFlag [
	<category: 'constants-flags'>
	^256
    ]

    MySQLColumnInfo class >> multipleKeyFlag [
	<category: 'constants-flags'>
	^8
    ]

    MySQLColumnInfo class >> notNullFlag [
	<category: 'constants-flags'>
	^1
    ]

    MySQLColumnInfo class >> primaryKeyFlag [
	<category: 'constants-flags'>
	^2
    ]

    MySQLColumnInfo class >> timestampFlag [
	<category: 'constants-flags'>
	^1024
    ]

    MySQLColumnInfo class >> uniqueKeyFlag [
	<category: 'constants-flags'>
	^4
    ]

    MySQLColumnInfo class >> unsignedFlag [
	<category: 'constants-flags'>
	^32
    ]

    MySQLColumnInfo class >> zerofillFlag [
	<category: 'constants-flags'>
	^64
    ]

    MySQLColumnInfo class >> readFrom: aReadStream [
	<category: 'instance creation'>
	^self new readFrom: aReadStream
    ]

    hasFlag: aFlag [
	<category: 'testing'>
	^(self flags bitAnd: aFlag) > 0
    ]

    isAutoIncrement [
	<category: 'testing'>
	^self hasFlag: self class autoIncrementFlag
    ]

    isBinary [
	<category: 'testing'>
	^self hasFlag: self class binaryFlag
    ]

    isBlob [
	<category: 'testing'>
	^self hasFlag: self class blobFlag
    ]

    isEnumeration [
	<category: 'testing'>
	^self hasFlag: self class enumFlag
    ]

    isMultipleKey [
	<category: 'testing'>
	^self hasFlag: self class multipleKeyFlag
    ]

    isNullable [
	<category: 'testing'>
	^self isNotNull not
    ]

    isNotNull [
	<category: 'testing'>
	^self hasFlag: self class notNullFlag
    ]

    isPrimaryKey [
	<category: 'testing'>
	^self hasFlag: self class primaryKeyFlag
    ]

    isTimestamp [
	<category: 'testing'>
	^self hasFlag: self class timestampFlag
    ]

    isUniqueKey [
	<category: 'testing'>
	^self hasFlag: self class uniqueKeyFlag
    ]

    isZerofill [
	<category: 'testing'>
	^self hasFlag: self class zerofillFlag
    ]

    decimalPlaces [
	<category: 'accessing'>
	^decimalPlaces
    ]

    flags [
	<category: 'accessing'>
	^flags
    ]

    index [
	<category: 'accessing'>
	^index
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    size [
	<category: 'accessing'>
	^size
    ]

    table [
	<category: 'accessing'>
	^table
    ]

    type [
	<category: 'accessing'>
	^TypeNames at: type
    ]

    convert: aValue [
	<category: 'actions'>
	^self perform: (Types at: type) with: aValue
    ]

    toBoolean: aString [
	<category: 'converting'>
	aString isNil ifTrue: [^nil].
	^aString first value = 1
    ]

    toByteArray: aString [
	<category: 'converting'>
	^self isBinary 
	    ifTrue: [aString isNil ifTrue: [nil] ifFalse: [aString asByteArray]]
	    ifFalse: [aString]
    ]

    toDate: aString [
	<category: 'converting'>
	| aStream day month year |
	aStream := aString readStream.
	year := Integer readFrom: aStream.
	aStream next.
	month := Integer readFrom: aStream.
	aStream next.
	day := Integer readFrom: aStream.
	^Date 
	    newDay: day
	    monthIndex: month
	    year: year
    ]

    toDateTime: aString [
	<category: 'converting'>
	^self toTimestamp: aString
    ]

    toDouble: aString [
	<category: 'converting'>
	| aStream writeStream character |
	aStream := ReadStream on: aString.
	writeStream := WriteStream on: String new.
	
	[character := aStream next.
	character isNil] whileFalse: 
		    [character = $e 
			ifTrue: 
			    [writeStream nextPut: $d.
			    character := aStream next.
			    character = $+ ifTrue: [character := aStream next]].
		    writeStream nextPut: character].
	^FloatD readFrom: (ReadStream on: writeStream contents)
    ]

    toFloat: aString [
	<category: 'converting'>
	| writeStream character aStream |
	aStream := ReadStream on: aString.
	writeStream := WriteStream on: String new.
	
	[character := aStream next.
	character isNil] 
		whileFalse: [character = $+ ifFalse: [writeStream nextPut: character]].
	^FloatE readFrom: (ReadStream on: writeStream contents)
    ]

    toInteger: aString [
	<category: 'converting'>
	^Integer readFrom: (ReadStream on: aString)
    ]

    toString: aString [
	<category: 'converting'>
	^aString
    ]

    toTime: aString [
	<category: 'converting'>
	| aStream hour minute second |
	aStream := aString readStream.
	hour := Integer readFrom: aStream.
	aStream next.
	minute := Integer readFrom: aStream.
	aStream next.
	second := Integer readFrom: aStream.
	^Time fromSeconds: 60 * (60 * hour + minute) + second
    ]

    toTimestamp: aString [
	<category: 'converting'>
	| aStream year separators month day hour minute second |
	aStream := aString readStream.
	year := (aStream next: 4) asInteger.
	separators := aStream peekFor: $-.
	month := (aStream next: 2) asInteger.
	separators ifTrue: [aStream next].
	day := (aStream next: 2) asInteger.
	separators ifTrue: [aStream next].
	hour := (aStream next: 2) asInteger.
	separators ifTrue: [aStream next].
	minute := (aStream next: 2) asInteger.
	separators ifTrue: [aStream next].
	second := (aStream next: 2) asInteger.
	^DateTime 
	    fromDays: (Date 
		    newDay: day
		    monthIndex: month
		    year: year) days
	    seconds: 3600 * hour + (60 * minute) + second
	    offset: Duration zero
    ]

    charset [
	<category: 'reading'>
	^charset
    ]

    readDecimalPlaces: aReadStream [
	<category: 'reading'>
	decimalPlaces := aReadStream next asInteger
    ]

    readFlags: aReadStream [
	<category: 'reading'>
	flags := (aReadStream next: 2) asByteArray asInteger
    ]

    readFrom: aReadStream index: i [
	<category: 'reading'>
	"can be catalogue, db, table, org table, field (and org field follows)
	 or table, field, length, type, flags+decimal"

	| length fields |
	index := i.
	fields := (1 to: 5) 
		    collect: [:i | aReadStream next: aReadStream next asInteger].
	aReadStream atEnd 
	    ifFalse: 
		[table := fields at: 3.
		name := fields at: 5.
		"org field"
		aReadStream next: aReadStream next asInteger.
		length := aReadStream next asInteger - 10.
		self
		    readCharset: aReadStream;
		    readSize: aReadStream;
		    readType: aReadStream;
		    readFlags: aReadStream;
		    readDecimalPlaces: aReadStream.
		aReadStream next: length.
		^self].

	"MySQL 3.x format."
	table := fields at: 1.
	name := fields at: 2.
	size := (fields at: 3) asByteArray asInteger.
	type := (fields at: 4) first asInteger.
	self readFlags: (fields at: 5) readStream.
	decimalPlaces := (fields at: 5) last asInteger
    ]

    readCharset: aReadStream [
	<category: 'reading'>
	charset := (aReadStream next: 2) asByteArray asInteger
    ]

    readName: aReadStream [
	<category: 'reading'>
	name := aReadStream next: aReadStream next asInteger
    ]

    readSize: aReadStream [
	<category: 'reading'>
	size := (aReadStream next: 4) asByteArray asInteger
    ]

    readTable: aReadStream [
	<category: 'reading'>
	table := aReadStream next: aReadStream next asInteger
    ]

    readType: aReadStream [
	<category: 'reading'>
	type := aReadStream next asInteger
    ]
]



Eval [
    MySQLColumnInfo initialize
]

PK    �Mh@���L�  �  	  ChangeLogUT	 cqXO��XOux �  �  ��QO�0ǟɧ8io�9a�,Bh�S�J[7(H�MnsI-_�;C�O?X*x*Lyq��w�s�W�\�y��O �4Y�r�3 g����օ�|{�$G���;�b��l	W��=���Уol��p��� ��,I
�NS�%�O,1%�p-�\�R�2�=y�j��f1���
g Ӎv-B��V���@�Kkm�W!ȋI�Ⓩ2�w��0��I ���}��=I����zeq@~#0޴A�i~�f��{���zo�T"ެ�`I��E���_�^��@����V�N"����;S��ss����=*�����E�v������:�oP�C�����.~얗߯�c����ףA�擷̝5c�;��h���^�х9��$���Cv�c�2T��-�Ή�B
E�PK
     �Mh@��O
Y	  Y	    TableColumnInfo.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   MySQL DBI driver - TableColumnInfo class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
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
 ======================================================================
"



ColumnInfo subclass: MySQLTableColumnInfo [
    
    <category: 'DBD-MySQL'>
    <comment: nil>
    | name type size nullable index |

    MySQLTableColumnInfo class >> from: aRow index: anInteger [
	^self new initializeFrom: aRow index: anInteger
    ]

    initializeFrom: aRow index: anInteger [
	| rawType |
	name := aRow atIndex: 1.
	rawType := aRow atIndex: 2.
	nullable := (aRow atIndex: 3) = 'YES'.
	index := anInteger.

	type := rawType copyUpTo: $(.
	(type = 'enum' or: [ type = 'set' or: [ rawType includes: $, ]])
	    ifTrue: [ type := rawType ]
	    ifFalse: [ size := (rawType copyAfter: $( ) asInteger ].
    ]

    name [
	"Return the name of the column."
	<category: 'accessing'>
	^name
    ]

    index [
	"Return the 1-based index of the column in the result set."
	<category: 'accessing'>
	^index
    ]

    isNullable [
	"Return whether the column can be NULL."
	<category: 'accessing'>
	^nullable
    ]

    type [
	"Return a string containing the type of the column."
	<category: 'accessing'>
	^type
    ]

    size [
	"Return the size of the column."
	<category: 'accessing'>
	^size
    ]
]
PK
     �Mh@s3UG  G    Row.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   MySQL DBI driver - Row class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Josh Miller
| Written by Josh Miller, ported by Markus Fritsche,
| refactored/rewritten by Paolo Bonzini
|
| Copyright 2003, 2007, 2008 Free Software Foundation, Inc.
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



Row subclass: MySQLRow [
    | isEmpty |
    
    <shape: #pointer>
    <comment: nil>
    <category: 'Mysql-Driver'>

    MySQLRow class >> on: aResultSet readFrom: aConnection [
	<category: 'instance creation'>
	^(self new: aResultSet columnCount)
	    resultSet: aResultSet;
	    readFrom: aConnection
    ]

    checkForEndOrNull: aReadStream [
	"This is a bit unclean...the value 254 has been overloaded in the protocol.  When it is the only
	 value in the stream, it indicates there are no more rows.  It also indicates that the following
	 8 bytes contain the size of the field value.  The problem is that there is another condition that
	 produces a single value on the stream...a row with one column whose value is NULL."

	<category: 'reading'>
	| endOrNull |
	aReadStream size = 1 
	    ifTrue: 
		[endOrNull := aReadStream next asInteger.
		isEmpty := endOrNull = 254.
		^true].
	(aReadStream size < 9 and: [aReadStream peekFor: (Character value: 254)]) 
	    ifTrue: 
		[aReadStream next: aReadStream size - 1.
		isEmpty := true.
		^true].
	isEmpty := false.
	^false
    ]

    readFrom: aReadStream [
	<category: 'reading'>
	(self checkForEndOrNull: aReadStream) ifTrue: [^self].
	1 to: self columnCount
	    do: 
		[:index | 
		| aSize column |
		aSize := self readSizeFrom: aReadStream.
		aSize = -1 
		    ifFalse: 
			[column := resultSet columnsArray at: index.
			self at: index put: (column convert: (aReadStream next: aSize))]]
    ]

    readSizeFrom: aReadStream [
	<category: 'reading'>
	| aSize |
	aSize := aReadStream next asInteger.
	aSize < 251 ifTrue: [^aSize].
	aSize = 251 ifTrue: [^-1].
	aSize = 252 ifTrue: [^(aReadStream next: 2) asByteArray asInteger].
	aSize = 253 ifTrue: [^(aReadStream next: 3) asByteArray asInteger].
	aSize = 254 ifTrue: [^(aReadStream next: 8) asByteArray asInteger]
    ]

    at: aColumnName [
	<category: 'accessing'>
	^self basicAt: (resultSet columns at: aColumnName) index
    ]

    atIndex: anIndex [
	<category: 'accessing'>
	^self basicAt: anIndex
    ]

    columnCount [
	<category: 'accessing'>
	^self size
    ]

    columns [
	<category: 'accessing'>
	^resultSet columns
    ]

    columnNames [
	<category: 'accessing'>
	^resultSet columnNames
    ]

    isEmpty [
	<category: 'testing'>
	^isEmpty
    ]
]

PK
     �Mh@����N  N            ��    Connection.stUT cqXOux �  �  PK
     �Mh@Ah�o�
  �
            ��eN  Statement.stUT cqXOux �  �  PK
     �Zh@5� �u  u            ��LY  package.xmlUT ��XOux �  �  PK
     �Mh@6`�$�M  �M            ��\  MySQLTests.stUT cqXOux �  �  PK
     �Mh@�����  �            ��3�  Table.stUT cqXOux �  �  PK
     �Mh@3�Y�
  
            ��8�  ResultSet.stUT cqXOux �  �  PK
     �Mh@);�`  `            ����  Extensions.stUT cqXOux �  �  PK
     �Mh@3�p�X6  X6  	          ��/�  Column.stUT cqXOux �  �  PK    �Mh@���L�  �  	         ��� ChangeLogUT cqXOux �  �  PK
     �Mh@��O
Y	  Y	            ��� TableColumnInfo.stUT cqXOux �  �  PK
     �Mh@s3UG  G            ��A Row.stUT cqXOux �  �  PK      ~  �   