PK
     �Mh@dÚG  G    Connection.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   Generic database interface - Connection class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Mike Anderson
| Copyright 2007, 2008 Free Software Foundation, Inc.
|
| Written by Mike Anderson
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



Object subclass: Connection [
    
    <category: 'DBI-Framework'>
    <comment: 'I represent a connection to a database.'>

    | tables |

    Drivers := LookupTable new.

    Connection class >> updateDriverList [
	"Private - Look for new subclasses of Connection."
	<category: 'initialization'>
	Drivers := LookupTable new.
	Connection allSubclassesDo: [ :each |
	    each driverName isNil ifFalse: [
		Drivers at: each driverName put: each ] ]
    ]

    Connection class >> driverName [
	"Override this method, returning the name of the driver, in every
	 concrete subclass of Connection.  Abstract classes should return
	 nil instead."
	^nil
    ]

    Connection class >> fieldConverterClass [
	"Override this method, returning a subclass of FieldConverter, in every
	 concrete subclass of Connection that needs it."
	^FieldConverter
    ]

    Connection class >> paramConnect: params user: aUserName password: aPassword [
	"Connect to the database server using the parameters in params (a
	Dictionary) and the given username and password (abstract)."

	<category: 'connecting'>
	self subclassResponsibility
    ]

    Connection class >> connect: aDSN user: aUserName password: aPassword [
	"Connect to the database server identified by aDSN using the given
	 username and password.  The DSN is in the format
	 dbi:DriverName:dbname=database_name;host=hostname;port=port
	 Where dbi is constant, DriverName is the name of the driver, and
	 everything else is parameters in the form name1=value1;name2=value2;...
	 
	 Individual drivers may parse the parameters differently, though
	 the existing ones all support parameters dbname, host and port."

	<category: 'connecting'>
	| info driverClass driver |
	info := ConnectionInfo fromDSN: aDSN.
	info scheme asLowercase = 'dbi' 
	    ifFalse: [self error: 'Connection string is not for DBI!'].
	driver := info driver.
	driverClass := Drivers at: driver
		    ifAbsent: [self updateDriverList.
			Drivers at: driver
			    ifAbsent: [self error: 'Unknown driver: ' , driver]].
	^driverClass 
	    paramConnect: info params
	    user: aUserName
	    password: aPassword
    ]

    >> aString [
	"Returns a Table object corresponding to the given table."

	<category: 'accessing'>
	^self tableAt: aString
    ]

    primTableAt: aString ifAbsent: aBlock [
	"Returns a Table object corresponding to the given table.  Should be
	 overridden by subclasses."

	<category: 'querying'>
	self subclassResponsibility
    ]

    tableAt: aString [
	"Returns a Table object corresponding to the given table."

	<category: 'accessing'>
	^self tableAt: aString ifAbsent: [self error: 'Unknown table: ', aString]
    ]

    tableAt: aString ifAbsent: aBlock [
	"Returns a Table object corresponding to the given table."

	<category: 'accessing'>
	tables isNil ifTrue: [ tables := LookupTable new ].
	^tables at: aString ifAbsentPut: [self primTableAt: aString ifAbsent: aBlock]
    ]

    do: aSQLQuery [
	"Executes a SQL statement (usually one that doesn't return a result set).
	 Return value is a ResultSet, to which you can send #rowsAffected
	 (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]

    prepare: aSQLQuery [
	"Creates a statement object, that can be executed (with parameters, if
	 applicable) repeatedly (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]

    select: aSQLQuery [
	"Prepares and executes a SQL statement. Returns the result set or
	 throws an exception on failure (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]

    close [
	"Close the connection now; should happen on GC too (abstract)."

	<category: 'connecting'>
	self subclassResponsibility
    ]

    fieldConverter [
	"Returns a FieldConverter that can be used to insert Smalltalk
	 objects into queries."

	<category: 'accessing'>
	^self class fieldConverterClass uniqueInstance
    ]

    database [
	"Returns the database name for this connection.  This corresponds
	 to the catalog in SQL standard parlance (abstract)."

	<category: 'accessing'>
	self subclassResponsibility
    ]
]



Eval [
    Connection initialize
]

PK
     �Mh@� ;W  W    Statement.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   Generic database interface - Statement class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Mike Anderson
| Copyright 2007, 2008, 2011 Free Software Foundation, Inc.
|
| Written by Mike Anderson
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



Object subclass: Statement [
    | connection |
    
    <category: 'DBI-Framework'>
    <comment: 'I represent a prepared statement.'>

    Statement class >> on: aConnection [
        "Return a new statement for this connection."

        <category: 'instance creation'>
        ^self new
            connection: aConnection;
            yourself
    ]

    Statement class >> getCommand: queryString [
        | readStream writeStream aCharacter |
        writeStream := WriteStream on: String new.
        readStream := ReadStream on: queryString.
        readStream skipSeparators.
        [readStream atEnd
	    or: [aCharacter := readStream next. aCharacter isSeparator]]
                whileFalse: [writeStream nextPut: aCharacter asUppercase].
        ^writeStream contents
    ]

    connection [
        "Return the connection for which the statement was prepared."

        <category: 'private'>
        ^connection
    ]

    connection: aConnection [
        "Associate the statement to the given Connection."

        <category: 'private'>
        connection := aConnection
    ]

    execute [
	"Execute with no parameters (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]

    executeWith: aParameter [
	"Execute with one parameters."

	<category: 'querying'>
	^self executeWithAll: {aParameter}
    ]

    executeWith: aParam1 with: aParam2 [
	"Execute with two parameters."

	<category: 'querying'>
	^self executeWithAll: 
		{aParam1.
		aParam2}
    ]

    executeWith: aParam1 with: aParam2 with: aParam3 [
	"Execute with three parameters."

	<category: 'querying'>
	^self executeWithAll: 
		{aParam1.
		aParam2.
		aParam3}
    ]

    executeWithAll: aParams [
	"Execute taking parameters from the Collection aParams (abstract)."

	<category: 'querying'>
	self subclassResponsibility
    ]
]

PK
     �Mh@#�~      ConnectionInfo.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   Generic database interface - ConnectionInfo class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Mike Anderson
| Copyright 2007, 2008 Free Software Foundation, Inc.
|
| Written by Mike Anderson
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



Object subclass: ConnectionInfo [
    | scheme driver paramString params |
    
    <category: 'DBI-Framework'>
    <comment: 'A utility class to contain connection info.'>

    ConnectionInfo class >> fromDSN: aDSN [
	"Parse a DSN in the format
         dbi:DriverName:dbname=database_name;host=hostname;port=port where
         dbi is constant, DriverName is the name of the driver, and everything
         else is parameters in the form name1=value1;name2=value2;..."

	<category: 'instance creation'>
	| sm n |
	n := self new.
	sm := ReadStream on: aDSN.
	n scheme: (sm upTo: $:).
	n driver: (sm upTo: $:).
	n paramString: sm upToEnd.
	^n
    ]

    parseParams [
	<category: 'private'>
	params := LookupTable new.
	(paramString subStrings: $;) do: 
		[:p | 
		| kv |
		kv := p subStrings: $=.
		params at: (kv at: 1) put: (kv size > 1 ifTrue: [kv at: 2] ifFalse: [nil])].

	self setUpParamSynonyms
    ]

    setUpParamSynonyms [
	"Private - set up synonyms like dbname/db/database."
	| database host |

	database := params at: 'database' ifAbsent: [nil].
	database := database ifNil: [ params at: 'db' ifAbsent: [nil] ].
	database := database ifNil: [ params at: 'dbname' ifAbsent: [nil] ].
	database isNil ifFalse: [
	    params at: 'database' put: database.
	    params at: 'db' put: database.
	    params at: 'dbname' put: database ].

	host := params at: 'host' ifAbsent: [nil].
	host := host ifNil: [ params at: 'hostname' ifAbsent: [nil] ].
	host isNil ifFalse: [
	    params at: 'host' put: host.
	    params at: 'hostname' put: host ]
    ]

    scheme: aString [
	"Set the scheme; the only supported one is 'dbi'."
	<category: 'accessing'>
	scheme := aString
    ]

    scheme [
	"Answer the scheme; the only supported one is 'dbi'."
	<category: 'accessing'>
	^scheme
    ]

    driver: aString [
	"Set the driver; this is not the driver class."
	<category: 'accessing'>
	driver := aString
    ]

    driver [
	"Answer the driver; this is not the driver class."
	<category: 'accessing'>
	^driver
    ]

    paramString: aString [
	"Set the parameter list."
	<category: 'accessing'>
	paramString := aString.
	params := nil
    ]

    params [
	"Return the parsed parameters in a Dictionary."
	<category: 'accessing'>
	params isNil ifTrue: [self parseParams].
	^params
    ]
]

PK
     �Zh@��w  w    package.xmlUT	 ��XO��XOux �  �  <package>
  <name>DBI</name>
  <namespace>DBI</namespace>
  <prereq>ROE</prereq>

  <filein>ConnectionInfo.st</filein>
  <filein>Connection.st</filein>
  <filein>Statement.st</filein>
  <filein>ResultSet.st</filein>
  <filein>Row.st</filein>
  <filein>ColumnInfo.st</filein>
  <filein>Table.st</filein>
  <filein>FieldConverter.st</filein>
  <file>ChangeLog</file>
</package>PK
     �Mh@�C9QG  G    FieldConverter.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   Generic database interface - FieldConverter class
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


Object subclass: FieldConverter [
    
    <category: 'DBI'>
    <comment: nil>

    FieldConverter class [
	| uniqueInstance |
	uniqueInstance [
	    <category: 'instance creation'>
	    uniqueInstance isNil
		ifTrue: [ uniqueInstance := self basicNew initialize ].
	    ^uniqueInstance
	]

	new [
	    <category: 'instance creation'>
	    self error: 'use uniqueInstance instead'
	]
    ]

    | converterSelectors |

    writeBoolean: aBoolean on: aStream [
        <category: 'converting-smalltalk'>
	aStream nextPut: $'.
        aBoolean printOn: aStream.
	aStream nextPut: $'.
    ]

    writeQuotedDate: aDate on: aStream [
        <category: 'converting-smalltalk'>
	aStream nextPut: $'.
        self writeDate: aDate on: aStream.
	aStream nextPut: $'.
    ]

    writeQuotedTime: aDate on: aStream [
        <category: 'converting-smalltalk'>
	aStream nextPut: $'.
        self writeTime: aDate on: aStream.
	aStream nextPut: $'.
    ]

    writeDate: aDate on: aStream [
        <category: 'converting-smalltalk'>
        aDate printOn: aStream.
    ]

    writeFloat: aFloat on: aStream [
        <category: 'converting-smalltalk'>
        | readStream character |
	aStream nextPut: $'.
        readStream := ReadStream on: aFloat asFloat printString.

        [character := readStream next.
        character isNil] whileFalse:
                    [(character = $d
                        or: [ character = $e
                        or: [ character = $q ]])
                            ifTrue:
                                [character := readStream next.
                                character isNil ifTrue: [^self].
                                aStream nextPut: $e.
                                character = $- ifFalse: [aStream nextPut: $+]].
                    aStream nextPut: character].
	aStream nextPut: $'.
    ]

    writeDateTime: aDateTime on: aStream [
        <category: 'converting-smalltalk'>
	aStream nextPut: $'.
        self writeDate: aDateTime asDate on: aStream.
        aStream nextPut: $ .
        self writeTime: aDateTime asTime on: aStream.
	aStream nextPut: $'.
    ]

    writeInteger: anInteger on: aStream [
        <category: 'converting-smalltalk'>
	aStream nextPut: $'.
        anInteger printOn: aStream.
	aStream nextPut: $'.
    ]

    writeTime: aTime on: aStream [
        <category: 'converting-smalltalk'>
        aTime printOn: aStream.
    ]

    printString: aValue [
        <category: 'actions'>
        | writeStream |
        writeStream := WriteStream on: String new.
        self print: aValue on: writeStream.
        ^writeStream contents
    ]

    print: aValue on: aStream [
        <category: 'actions'>
        | aSelector |
	aValue isNil ifTrue: [ aStream nextPutAll: 'NULL'. ^self ].
        aSelector := converterSelectors at: aValue class
                    ifAbsent: [ #defaultConvert:on: ].
        self
            perform: aSelector
            with: aValue
            with: aStream.
    ]

    defaultConvert: aValue on: aStream [
        | writeStream readStream ch |
	aStream nextPut: $'.
	aValue isString
	    ifTrue: [ readStream := aValue readStream ]
	    ifFalse: [
		writeStream := WriteStream on: String new.
		aValue displayOn: writeStream.
		readStream := writeStream readStream ].

	[ readStream atEnd ] whileFalse: [
	    ch := readStream next.
	    ch = $' ifTrue: [ aStream nextPut: $' ].
	    ch = $\ ifTrue: [ aStream nextPut: $\ ].
	    aStream nextPut: ch
	].
	aStream nextPut: $'.
    ]

    buildConversionMap [
        <category: 'private-initialize'>
        converterSelectors := IdentityDictionary new.
        converterSelectors
            at: Boolean put: #writeBoolean:on:;
            at: FloatD put: #writeFloat:on:;
            at: FloatE put: #writeFloat:on:;
            at: FloatQ put: #writeFloat:on:;
            at: Fraction put: #writeFloat:on:;
            at: Integer put: #writeInteger:on:;
            at: Date put: #writeQuotedDate:on:;
            at: DateTime put: #writeDateTime:on:;
            at: Time put: #writeQuotedTime:on:
    ]

    initialize [
        <category: 'private-initialize'>
	self buildConversionMap
    ]
]
PK
     �Mh@��ع!  !    Table.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   Generic database interface - Table class (bridge with ROE)
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



ROE.RASQLRelation subclass: Table [
    
    <category: 'DBI'>
    <comment: nil>

    | columns |

    basicExec: aString [
	<category: 'private'>
	^connection do: aString
    ]

    basicQuery: aString [
	<category: 'private'>
	^(connection select: aString) contents
    ]

    columnsArray [
	"Answer a Dictionary of column name -> ColumnInfo pairs (abstract)."
	self subclassResponsibility
    ]

    columns [
        <category: 'accessing'>
        columns isNil
            ifTrue:
                [| n array |
		array := self columnsArray.
                columns := LookupTable new: array size.
                array do: [:col | columns at: col name put: col]].
        ^columns
    ]

    columnNames [
	"Answer an array of column names in order (abstract)."

	<category: 'accessing'>
	^self columnsArray collect: [:each | self name]
    ]

    columnAt: aIndex [
        "Answer the aIndex'th column name."

        <category: 'accessing'>
        ^(self columnsArray at: aIndex) name
    ]

    database [
	"Returns the database name for this table.  This corresponds
	 to the catalog in SQL standard parlance."

	<category: 'accessing'>
	^self connection database
    ]

    discoverAttributes [
	<category: 'private'>
	^self columnsArray
	    collect: [:each | RASimpleAttribute named: each name relation: self]
    ]

    size [
	<category: 'core'>
	^(self query: self sqlCount) first atIndex: 1
    ]

    print: anObject on: aStream [
        <category: 'printing'>
        self connection fieldConverter print: anObject on: aStream
    ]
]
PK
     �Mh@	l|*1
  1
    ColumnInfo.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   Generic database interface - ColumnInfo class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Mike Anderson
| Copyright 2007, 2008 Free Software Foundation, Inc.
|
| Written by Mike Anderson
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



Object subclass: ColumnInfo [
    
    <category: 'DBI-Framework'>
    <comment: nil>

    name [
	"Return the name of the column (abstract)."
	<category: 'accessing'>
	self subclassResponsibility
    ]

    index [
	"Return the 1-based index of the column in the result set (abstract)."
	<category: 'accessing'>
	self subclassResponsibility
    ]

    isNullable [
	"Return whether the column can be NULL (always returns true in
	 ColumnInfo)."
	<category: 'accessing'>
	^true
    ]

    type [
	"Return a string containing the type of the column (abstract)."
	<category: 'accessing'>
	self subclassResponsibility
    ]

    size [
	"Return the size of the column (abstract)."
	<category: 'accessing'>
	^nil
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."
	<category: 'printing'>
	aStream
	    print: self class;
	    nextPut: $(;
	    display: self;
	    nextPut: $)
    ]

    displayOn: aStream [
	"Print a representation of the receiver on aStream."
	<category: 'printing'>
	aStream
	    nextPutAll: self name;
	    space;
	    nextPutAll: self type.
	((self type includes: $( ) not and: [ self size notNil ])
	    ifTrue: [ aStream nextPut: $(; print: self size; nextPut: $) ].
	self isNullable ifFalse: [ aStream nextPutAll: ' not null' ].
    ]
]

PK
     �Mh@7kŧ  �    ResultSet.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   Generic database interface - ResultSet class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Mike Anderson
| Copyright 2007, 2008, 2009 Free Software Foundation, Inc.
|
| Written by Mike Anderson
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



Stream subclass: ResultSet [
    | statement |
    
    <category: 'DBI-Framework'>
    <comment: 'I represent a result set, ie. the set of rows returned from a SELECT statement.
I may also be returned for DML statements (INSERT, UPDATE, DELETE), in which
case I only hold the number of rows affected.'>

    fetch [
	"Return the next row, or nil if at the end of the result set."
	<category: 'cursor access'>
	self atEnd ifTrue: [ ^nil ].
	^self next
    ]

    next [
	"Return the next row, or raise an error if at the end of the stream
	 (abstract)."
	<category: 'cursor access'>
	self subclassResponsibility
    ]

    atEnd [
	"Return whether all the rows in the result set have been consumed.
	 (abstract)."
	<category: 'cursor access'>
	self subclassResponsibility
    ]

    rows [
	"Answer the contents of the execution result as array of Rows."

	<category: 'accessing'>
	| pos |
	pos := self position.
	^[ self position: 0. self contents ]
	    ensure: [ self position: pos ]
    ]

    columns [
	"Answer a Dictionary of column name -> ColumnInfo pairs (abstract)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    columnNames [
	"Answer an array of column names in order (abstract)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    columnAt: aIndex [
	"Answer the aIndex'th column name."

	<category: 'accessing'>
	^self columnNames at: aIndex
    ]

    isSelect [
	"Returns true if the statement was a SELECT or similar operation
	 (e.g. SHOW, DESCRIBE, EXPLAIN), false otherwise."

	<category: 'accessing'>
	^false
    ]

    isDML [
	"Returns true if the statement was not a SELECT or similar operation
	 (e.g. SHOW, DESCRIBE, EXPLAIN)."

	<category: 'accessing'>
	^false
    ]

    position [
	"Returns the current row index (0-based) in the result set (abstract)."
	<category: 'stream protocol'>
	self subclassResponsibility
    ]

    position: anInteger [
	"Sets the current row index (0-based) in the result set (abstract)."
	<category: 'stream protocol'>
	self subclassResponsibility
    ]

    size [
	"Returns the number of rows in the result set."
	<category: 'stream protocol'>
	^self rowCount
    ]

    rowCount [
	"Returns the number of rows in the result set;
	 error for DML statements."

	<category: 'accessing'>
	self error: 'Not a SELECT statement.'
    ]

    rowsAffected [
	"For DML statments, returns the number of rows affected;
	 error for SELECT statements."

	<category: 'accessing'>
	self error: 'Not a DML statement.'
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."
	<category: 'printing'>
	self isSelect ifFalse: [ ^super printOn: aStream ].
	self rows do: 
		[:row | 
		row printOn: aStream.
		aStream nl]
    ]

    statement [
	"Return the Statement, if any, that generated the result set."

	<category: 'accessing'>
	^statement
    ]

    statement: aStatement [
	<category: 'private'>
	statement := aStatement
    ]
]

PK    �Mh@�oSʸ  j  	  ChangeLogUT	 cqXO��XOux �  �  �Tak�0�\����6��6t��v	����v��l�H:#�M�_?�Y�1[�������{gY����4;�aU��4��Cxm��M��Ė.�J�fʶ^$��'x��I��S��pU�c�B��IM~�Z�)��$)�<K�"����76���@��G���F��k��h5���L`x�k�V����E%-�c��(�0W~$�S[��Ap�[Y7zB�Gʾ�A��ˑH�:�i��S��?��� �)��S�����;�!����4�K�dcHx���T<0�ᖠ��ʍAM��	n���a�g��Β�6�v��8nʡ�"͏5x��D�X��G'�PeŢ�[��T�e_û�ݕ��݇��8��C�H1��n�,Yuz�d8���ޡ���Ƶm���� 9L(�}��0�_�����A�h��<C���Z�*C�3��w�g~��'PK
     �Mh@�����  �    Row.stUT	 cqXO��XOux �  �  "=====================================================================
|
|   Generic database interface - Row class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Mike Anderson
| Copyright 2007, 2008 Free Software Foundation, Inc.
|
| Written by Mike Anderson
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



Object subclass: Row [
    | resultSet |
    
    <category: 'DBI-Framework'>
    <comment: 'I represent a row in a result set.'>

    resultSet [
	"Return the result set that includes the receiver."

	<category: 'accessing'>
	^resultSet
    ]

    resultSet: aResultSet [
	<category: 'private'>
	resultSet := aResultSet
    ]

    at: aColumnName [
	"Return the value of the named column (abstract)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    asArray [
	"Return the values of the columns."

	<category: 'accessing'>
	^1 to: self columns size collect: [:index | self atIndex: index]
    ]

    asDictionary [
	"Return the names and values of the columns as a dictionary."

	| d |
	<category: 'accessing'>
	d := LookupTable new.
	self keysAndValuesDo: [ :key :value | d at: key put: value ].
	^d
    ]

    atIndex: aColumnIndex [
	"Return the value of the column at the given 1-based index (abstract)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    columnCount [
	"Return the number of columns in the row."

	<category: 'accessing'>
	^resultSet columnCount
    ]

    columns [
	"Return a Dictionary of ColumnInfo objects for the columns in the row,
	 where the keys are the column names."

	<category: 'accessing'>
	^resultSet columns
    ]

    columnNames [
	"Return an array of column names for the columns in the row."

	<category: 'accessing'>
	^resultSet columnNames
    ]

    columnAt: aIndex [
	"Return a ColumnInfo object for the aIndex-th column in the row."

	<category: 'accessing'>
	^resultSet columnAt: aIndex
    ]

    keysAndValuesDo: aBlock [
	"Pass to aBlock each column name and the corresponding value."

	<category: 'accessing'>
	self columns keysAndValuesDo: 
	    [:name :col | aBlock value: name value: (self atIndex: col index)]
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	self keysAndValuesDo: [ :col :val |
	    aStream << col << ' -> ' << val printString << '   ' ]
    ]
]

PK
     �Mh@dÚG  G            ��    Connection.stUT cqXOux �  �  PK
     �Mh@� ;W  W            ���  Statement.stUT cqXOux �  �  PK
     �Mh@#�~              ��+"  ConnectionInfo.stUT cqXOux �  �  PK
     �Zh@��w  w            ���0  package.xmlUT ��XOux �  �  PK
     �Mh@�C9QG  G            ��N2  FieldConverter.stUT cqXOux �  �  PK
     �Mh@��ع!  !            ���G  Table.stUT cqXOux �  �  PK
     �Mh@	l|*1
  1
            ��CS  ColumnInfo.stUT cqXOux �  �  PK
     �Mh@7kŧ  �            ���]  ResultSet.stUT cqXOux �  �  PK    �Mh@�oSʸ  j  	         ���n  ChangeLogUT cqXOux �  �  PK
     �Mh@�����  �            ���p  Row.stUT cqXOux �  �  PK    
 
 2  �}    