PK
     �Mh@A�Z4  4    HTTP.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   HTTP protocol support
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, and in the public domain
| Copyright (c) 2002, 2005 Free Software Foundation, Inc.
| Adapted by Paolo Bonzini.
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



Namespace current: NetClients.HTTP [

NetClient subclass: HTTPClient [
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-HTTP'>

    HTTPClient class >> defaultPortNumber [
	<category: 'constants'>
	^80
    ]

    HTTPClient class >> defaultSSLPortNumber [
	<category: 'constants'>
	^443
    ]

    HTTPClient class >> exampleURL: url host: host port: port [
	"self exampleURL: 'http://www.gnu.org' host: 'www.gnu.org' port: 80."

	"self exampleURL: 'http://www.gnu.org' host: 'localhost' port: 8080."

	<category: 'examples'>
	| body headers client |
	client := HTTPClient connectToHost: host port: port.
	
	[headers := client 
		    get: url
		    requestHeaders: #()
		    into: (body := WriteStream on: String new)] 
		ensure: [client close].
	^headers -> body contents
    ]

    get: urlString requestHeaders: requestHeaders into: aStream [
	<category: 'accessing'>
	^self clientPI 
	    get: urlString
	    requestHeaders: requestHeaders
	    into: aStream
    ]

    getBinary: urlString [
	<category: 'accessing'>
	| stream |
	stream := WriteStream on: (String new: 1024).
	self 
	    get: urlString
	    requestHeaders: Array new
	    into: stream.
	^stream contents
    ]

    getText: urlString [
	<category: 'accessing'>
	^self clientPI decode: (self getBinary: urlString)
    ]

    head: urlString requestHeaders: requestHeaders [
	<category: 'accessing'>
	^self clientPI head: urlString requestHeaders: requestHeaders
    ]

    head: urlString requestHeaders: requestHeaders into: aStream [
	"This method is deprecated in favor of #head:requestHeaders:, because the
	 last parameter is effectively unused."

	<category: 'accessing'>
	^self clientPI head: urlString requestHeaders: requestHeaders
    ]

    post: urlString type: type data: data binary: binary requestHeaders: requestHeaders into: aStream [
	<category: 'accessing'>
	^self clientPI 
	    post: urlString
	    type: type
	    data: data
	    binary: binary
	    requestHeaders: requestHeaders
	    into: aStream
    ]

    protocolInterpreter [
	<category: 'private'>
	^HTTPProtocolInterpreter
    ]
]

]



Namespace current: NetClients.HTTP [

NetProtocolInterpreter subclass: HTTPProtocolInterpreter [
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-HTTP'>

    HTTPProtocolInterpreter class >> defaultResponseClass [
	<category: 'private-attributes'>
	^HTTPResponse
    ]

    get: urlString requestHeaders: requestHeaders into: aStream [
	<category: 'accessing'>
	self connectIfClosed.
	self
	    nextPutAll: 'GET ' , urlString , ' HTTP/1.1';
	    cr.
	self putRequestHeaders: requestHeaders.
	^self readResponseInto: aStream
    ]

    readResponseStream: aResponseStream into: aStream length: aContentLength [
	<category: 'accessing'>
	| remaining |
	remaining := aContentLength.
	[remaining = 0] whileFalse: 
		[| data |
		data := aResponseStream next: (4096 min: remaining).
		remaining := remaining - data size.
		self reporter readByte: data size.
		aStream nextPutAll: data]
    ]

    readChunkedResponseStream: aResponseStream into: aStream [
	<category: 'accessing'>
	"Happily, aResponseStream should be buffered."

	| cr lf chunkSize chunkExt i remaining s |
	cr := Character cr.
	lf := Character lf.
	
	[aResponseStream atEnd ifTrue: [^self].
        (aResponseStream peek asUppercase isDigit: 16) 
	    ifFalse: 
		[self 
		    error: 'Expecting chunk-size, but found ' 
			    , aResponseStream peek printString , '.'].
	chunkSize := Integer readFrom: aResponseStream radix: 16.

	"Technically, a chunk-extension should start with $;, but we'll
	 ignore everything to the CRLF for simplicity (we don't understand
	 any chunk extensions, so we have to ignore them)."
	[aResponseStream next = cr and: [aResponseStream next = lf]] whileFalse.
	chunkSize = 0] 
		whileFalse: 
		    ["Possibly we should just read it all?"

		    self 
			readResponseStream: aResponseStream
			into: aStream
			length: chunkSize.
		    (aResponseStream next = cr and: [aResponseStream next = lf]) 
			ifFalse: 
			    [self error: 'Expected CRLF but found: ' , s printString
			    "We could try to recover by reading to the next CRLF, I suppose..."].
		    chunkSize = 0].
	aResponseStream peekFor: cr.
	aResponseStream peekFor: lf
	"There shouldn't be a trailer as we didn't say it was acceptable in the request."
    ]

    readResponseInto: aStream [
	<category: 'accessing'>
	| response totalByte readStream |
	response := self getResponse.
	self checkResponse: response.
	totalByte := response fieldAt: 'Content-Length' ifAbsent: [nil].
	totalByte notNil 
	    ifTrue: 
		["#asInteger strips 'Content-Length' from the front of the string."

		totalByte := totalByte value trimSeparators asInteger.
		self reporter totalByte: totalByte].
	self reporter startTransfer.
	readStream := self connectionStream stream.
	response preReadBytes isEmpty 
	    ifFalse: 
		[self reporter readByte: response preReadBytes size.
		readStream := response preReadBytes readStream , readStream].
	totalByte notNil 
	    ifTrue: 
		[self 
		    readResponseStream: readStream
		    into: aStream
		    length: totalByte]
	    ifFalse: 
		[| te s |
		self readChunkedResponseStream: readStream into: aStream.
		"Remove 'chunked' from transfer-encoding header"
		te := response fieldAt: 'transfer-encoding' ifAbsent: [nil].
		te notNil 
		    ifTrue: 
			[s := te value.
			(s 
			    indexOf: 'chunked'
			    matchCase: false
			    startingAt: 1) ifNotNil: 
				    [:i | 
				    te value: (s copyFrom: 1 to: i first - 1) , (s copyFrom: i last + 1)]]].
	self reporter endTransfer.
	response keepAlive ifFalse: [self close].
	^response
    ]

    head: urlString requestHeaders: requestHeaders [
	<category: 'accessing'>
	| response |
	self connectIfClosed.
	self reporter startTransfer.
	self
	    nextPutAll: 'HEAD ' , urlString , ' HTTP/1.1';
	    cr.
	self putRequestHeaders: requestHeaders.
	response := self getResponse.
	self checkResponse: response.
	self reporter endTransfer.
	response keepAlive ifFalse: [self close].
	^response
    ]

    putRequestHeaders: requestHeaders [
	<category: 'accessing'>
	| host |
	host := false.
	requestHeaders do: 
		[:header | 
		('Host:*' match: header) ifTrue: [host := true].
		self
		    nextPutAll: header;
		    cr].

	"The Host header is necessary to support virtual hosts"
	host 
	    ifFalse: 
		[self
		    nextPutAll: 'Host: ' , self client hostName;
		    cr].
	self cr
    ]

    post: urlString type: type data: data binary: binary requestHeaders: requestHeaders into: aStream [
	<category: 'accessing'>
	| readStream response totalByte |
	self connectIfClosed.
	self
	    nextPutAll: 'POST ' , urlString , ' HTTP/1.1';
	    cr.
	self
	    nextPutAll: 'Content-Type: ' , type;
	    cr.
	self
	    nextPutAll: 'Content-Length: ' , data size printString;
	    cr.
	self putRequestHeaders: requestHeaders.
	binary 
	    ifTrue: [(self connectionStream stream) nextPutAll: data; flush]
	    ifFalse: [self nextPutAll: data].
	^self readResponseInto: aStream
    ]

    checkResponse: response ifError: errorBlock [
	<category: 'private'>
	| status |
	status := response status.

	"Successful"
	status = 200 
	    ifTrue: 
		["OK"

		^self].
	status = 201 
	    ifTrue: 
		["Created"

		^self].
	status = 202 
	    ifTrue: 
		["Accepted"

		^self].
	status = 203 
	    ifTrue: 
		["Provisional Information"

		^self].
	status = 204 
	    ifTrue: 
		["No Response"

		^self].
	status = 205 
	    ifTrue: 
		["Deleted"

		^self].
	status = 206 
	    ifTrue: 
		["Modified"

		^self].

	"Redirection"
	(status = 301 or: 
		["Moved Permanently"

		status = 302	"Moved Temporarily"]) 
	    ifTrue: 
		[^self redirectionNotify: response ifInvalid: errorBlock].
	status = 303 
	    ifTrue: 
		["Method"

		^self].
	status = 304 
	    ifTrue: 
		["Not Modified"

		^self].

	"Client Error"
	status = 400 
	    ifTrue: 
		["Bad Request"

		^errorBlock value].
	status = 401 
	    ifTrue: 
		["Unauthorized"

		^errorBlock value].
	status = 402 
	    ifTrue: 
		["Payment Required"

		^errorBlock value].
	status = 403 
	    ifTrue: 
		["Forbidden"

		^errorBlock value].
	status = 404 
	    ifTrue: 
		["Not Found"

		^errorBlock value].
	status = 405 
	    ifTrue: 
		["Method Not Allowed"

		^errorBlock value].
	status = 406 
	    ifTrue: 
		["None Acceptable"

		^errorBlock value].
	status = 407 
	    ifTrue: 
		["Proxy Authent. Required"

		^errorBlock value].
	status = 408 
	    ifTrue: 
		["Request Timeout"

		^errorBlock value].

	"Server Errors"
	status = 500 
	    ifTrue: 
		["Internal Server Error"

		^errorBlock value].
	status = 501 
	    ifTrue: 
		["Not Implemented"

		^errorBlock value].
	status = 502 
	    ifTrue: 
		["Bad Gateway"

		^errorBlock value].
	status = 503 
	    ifTrue: 
		["Service Unavailable"

		^errorBlock value].
	status = 504 
	    ifTrue: 
		["Gateway Timeout"

		^errorBlock value].

	"Unknown status"
	^errorBlock value
    ]

    redirectionNotify: aResponse ifInvalid: errorBlock [
	<category: 'private'>
        | ex |
	ex := HTTPRedirection new.
	ex response: aResponse.
        ex location isNil
            ifTrue: [ ^errorBlock value ]
            ifFalse: [
                ex tag: ex location. "backwards compatibility"
	        ex signal ].
    ]
]

]



Namespace current: NetClients.HTTP [

NetResponse subclass: HTTPResponse [
    | version messageHeader preReadBytes |
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-HTTP'>

    fieldAt: key [
	<category: 'accessing'>
	^messageHeader fieldAt: key
    ]

    fieldAt: key ifAbsent: absentBlock [
	<category: 'accessing'>
	^messageHeader fieldAt: key ifAbsent: absentBlock
    ]

    keepAlive [
	<category: 'accessing'>
	| connection |
	(self fieldAt: 'content-length' ifAbsent: [nil]) isNil ifTrue: [^false].
	connection := self fieldAt: 'connection' ifAbsent: [nil].
	connection := connection isNil ifTrue: [''] ifFalse: [connection value].

	"For HTTP/1.0, the default is close and there is a de facto
	 standard way to specify keep-alive connections"
	version < 'HTTP/1.1' 
	    ifTrue: [^'*keep-alive*' match: connection ignoreCase: true].

	"For HTTP/1.1, the default is keep-alive"
	^('*close*' match: connection ignoreCase: true) not
    ]

    messageHeader [
	<category: 'accessing'>
	^messageHeader
    ]

    preReadBytes [
	<category: 'accessing'>
	^preReadBytes isNil ifTrue: [#[]] ifFalse: [preReadBytes]
    ]

    parseResponse: aClient [
	<category: 'parsing'>
	| messageHeaderParser |
	messageHeader := MIME.MimeEntity new.
	version := aClient nextAvailable: 8.
	('HTTP/1.#' match: version) 
	    ifFalse: 
		["may be HTTP/0.9"

		preReadBytes := version.
		status := 200.
		statusMessage := 'OK'.
		version := 'HTTP/0.9'.
		^self].
	self parseStatusLine: aClient.
	messageHeaderParser := MIME.MimeEntity parser on: aClient connectionStream.
	messageHeader parseFieldsFrom: messageHeaderParser.
	messageHeaderParser assertNoLookahead.
	preReadBytes := #().
    ]

    printOn: aStream [
	<category: 'printing'>
	self printStatusOn: aStream.
	aStream cr.
	messageHeader printOn: aStream
    ]

    printStatusOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'HTTP/1.0 '.
	super printStatusOn: aStream
    ]

    parseStatusLine: aClient [
	<category: 'private'>
	| stream |
	stream := aClient nextLine readStream.
	stream skipSeparators.
	status := Integer readFrom: stream.
	stream skipSeparators.
	statusMessage := stream upToEnd
    ]
]

]



Namespace current: NetClients.HTTP [

ProtocolNotification subclass: HTTPRedirection [
    
    <category: 'NetClients-HTTP'>
    <comment: nil>

    | location |

    location [
        location isNil ifFalse: [^location].
        response isNil ifTrue: [^nil].
	location := response fieldAt: 'Location' ifAbsent: [nil].
        location isNil ifFalse: [location := location value].
	^location
    ]
]

]

PK
     �Mh@Y�~�H H   IMAP.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   IMAP protocol support
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2000 Leslie A. Tyrrell
| Copyright (c) 2009 Free Software Foundation
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



Namespace current: NetClients.IMAP [

Object subclass: IMAPCommand [
    | client sequenceID name arguments status responses completionResponse promise |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    ResponseRegistry := nil.

    IMAPCommand class >> initialize [
	"IMAPCommand initialize"

	<category: 'class initialization'>
	(ResponseRegistry := Dictionary new)
	    at: 'FETCH' put: #('FETCH' 'OK' 'NO' 'BAD');
	    at: 'SEARCH' put: #('SEARCH' 'OK' 'NO' 'BAD');
	    at: 'SELECT' put: #('FLAGS' 'EXISTS' 'RECENT' 'OK' 'NO' 'BAD');
	    at: 'EXAMINE' put: #('FLAGS' 'EXISTS' 'RECENT' 'OK' 'NO' 'BAD');
	    at: 'LIST' put: #('LIST' 'OK' 'NO' 'BAD');
	    at: 'LSUB' put: #('LSUB' 'OK' 'NO' 'BAD');
	    at: 'STATUS' put: #('STATUS');
	    at: 'EXPUNGE' put: #('EXPUNGE' 'OK' 'NO' 'BAD');
	    at: 'STORE' put: #('FETCH' 'OK' 'NO' 'BAD');
	    at: 'UID' put: #('FETCH' 'SEARCH' 'OK' 'NO' 'BAD');
	    at: 'CAPABILITY' put: #('CAPABILITY' 'OK' 'BAD');
	    at: 'STORE' put: #('FETCH');
	    at: 'LOGOUT' put: #('BYE' 'OK' 'BAD');
	    at: 'CLOSE' put: #('OK' 'NO' 'BAD');
	    at: 'CHECK' put: #('OK' 'NO');
	    at: 'APPEND' put: #('OK' 'NO' 'BAD');
	    at: 'SUBSCRIBE' put: #('OK' 'NO' 'BAD');
	    at: 'RENAME' put: #('OK' 'NO' 'BAD');
	    at: 'DELETE' put: #('OK' 'NO' 'BAD');
	    at: 'CREATE' put: #('OK' 'NO' 'BAD');
	    at: 'LOGIN' put: #('OK' 'NO' 'BAD');
	    at: 'AUTHENTICATE' put: #('OK' 'NO' 'BAD');
	    at: 'NOOP' put: #('OK' 'BAD')
    ]

    IMAPCommand class >> definedResponsesAt: aName [
	<category: 'defined responses'>
	^self responseRegistry at: aName asUppercase
	    ifAbsentPut: [IdentityDictionary new]
    ]

    IMAPCommand class >> responseRegistry [
	<category: 'defined responses'>
	^ResponseRegistry
    ]

    IMAPCommand class >> forClient: anIMAPPI name: aString arguments: arguments [
	"The intention here is to let users specify the complete string of command arguments. Because this string may contain atom-specials like $(, etc., this line may be sent as quoted string, which would be wrong. So we fool the printing logic to view this string as an atom. It is a hack, but seems like a convenient one"

	<category: 'instance creation'>
	| args |
	args := arguments isCharacters 
		    ifTrue: [#atom -> arguments]
		    ifFalse: [arguments].
	^self new 
	    forClient: anIMAPPI
	    name: aString
	    arguments: args
    ]

    IMAPCommand class >> login: aNameString password: aPassString [
	<category: 'instance creation'>
	^self name: 'login'
	    arguments: (Array with: #string -> aNameString with: #string -> aPassString)
    ]

    IMAPCommand class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    IMAPCommand class >> parse: scanner [
	"Read and parse next command from a stream. This is mainly useful for testing previously stored
	 exchange logs"

	<category: 'instance creation'>
	^self new parse: scanner
    ]

    IMAPCommand class >> readFrom: aStream [
	"Read and parse next command from a stream. This is mainly useful for testing previously stored exchange logs"

	<category: 'instance creation'>
	^self parse: (IMAPScanner on: aStream)
    ]

    arguments [
	<category: 'accessing'>
	^arguments
    ]

    arguments: anObject [
	<category: 'accessing'>
	arguments := anObject
    ]

    client [
	<category: 'accessing'>
	^client
    ]

    client: anObject [
	<category: 'accessing'>
	client := anObject
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: anObject [
	<category: 'accessing'>
	name := anObject
    ]

    sequenceID [
	<category: 'accessing'>
	^sequenceID
    ]

    sequenceID: anObject [
	<category: 'accessing'>
	sequenceID := anObject
    ]

    completionResponse [
	<category: 'completion response'>
	^completionResponse
    ]

    completionResponse: anObject [
	<category: 'completion response'>
	completionResponse := anObject.
	self beDone
    ]

    execute [
	"Prepend the given command and send it to the server."

	<category: 'execute'>
	self sendOn: client connectionStream.
	self client connectionStream nl.
	self beSent
    ]

    wait [
	<category: 'execute'>
	^promise value
    ]

    definedResponses [
	<category: 'handle responses'>
	^self class definedResponsesAt: self name asUppercase
    ]

    handle: aResponse [
	<category: 'handle responses'>
	(aResponse hasTag: self sequenceID) 
	    ifTrue: 
		[self completionResponse: aResponse.
		^true].
	(self isDefinedResponse: aResponse) 
	    ifTrue: 
		[self responses add: aResponse.
		^true].
	^self notifyClientIfNeeded: aResponse
    ]

    isDefinedResponse: aResponse [
	<category: 'handle responses'>
	^self definedResponses includes: aResponse cmdName
    ]

    needsClientNotification: aResponse [
	<category: 'handle responses'>
	^false
	"^client isInterestedIn: aResponse"
    ]

    notifyClientIfNeeded: aResponse [
	<category: 'handle responses'>
	^(self needsClientNotification: aResponse) 
	    ifTrue: [client handle: aResponse]
	    ifFalse: [false]
    ]

    registerResponse: aResponse [
	<category: 'handle responses'>
	aResponse isCompletionResponse 
	    ifTrue: [self completionResponse: aResponse]
	    ifFalse: [self responses add: aResponse]
    ]

    responses [
	<category: 'handle responses'>
	^responses notNil 
	    ifTrue: [responses]
	    ifFalse: [responses := OrderedCollection new]
    ]

    forClient: anIMAPPI name: aString arguments: args [
	<category: 'initialization'>
	self client: anIMAPPI.
	self name: aString.
	self arguments: (self canonicalizeArguments: args)
    ]

    initialize [
	<category: 'initialization'>
	promise := Promise new.
	responses := OrderedCollection new: 1
    ]

    completedSuccessfully [
	<category: 'obsolete'>
	^self successful
    ]

    parse: scanner [
	"Read and parse next command from a stream. This is mainly useful for testing previously stored
	 exchange logs"

	<category: 'parsing'>
	| tokens |
	tokens := scanner deepTokenizeAsAssociation.
	self
	    sequenceID: tokens first value;
	    name: (tokens at: 2) value;
	    arguments: (tokens copyFrom: 3 to: tokens size)
    ]

    printCompletionResponseOn: aStream indent: level [
	<category: 'printing'>
	self completionResponse notNil 
	    ifTrue: [self completionResponse printOn: aStream indent: level]
    ]

    printOn: aStream [
	<category: 'printing'>
	self scanner printTokenList: self asTokenList on: aStream
    ]

    printResponseOn: aStream indent: level [
	<category: 'printing'>
	(self responces isNil or: [self responces isEmpty]) ifTrue: [^String new].
	self responses do: 
		[:eachResponse | 
		aStream nl.
		eachResponse printOn: aStream indent: level]
    ]

    scanner [
	<category: 'printing'>
	^IMAPScanner
    ]

    sendOn: aClient [
	"aClient is a IMAPProtocolInterpreter"

	<category: 'printing'>
	self client sendTokenList: self asTokenList
    ]

    asTokenList [
	<category: 'private'>
	| list |
	list := OrderedCollection with: #atom -> self sequenceID
		    with: #atom -> name.
	self arguments notNil ifTrue: [list addAll: self arguments].
	^list
    ]

    canonicalizeArguments: arguments [
	"Arguments can one of: integer, string or array of thereof, potentially nested. Scalars are
	 converted into array with this scalar as a sole element"

	<category: 'private'>
	arguments isNil ifTrue: [^Array new].
	^(arguments isCharacters or: [arguments isSequenceable not]) 
	    ifTrue: [^Array with: arguments]
	    ifFalse: [arguments]
    ]

    promise [
	<category: 'private'>
	^promise
    ]

    commandResponse [
	<category: 'responses'>
	| coll |
	^(coll := self commandResponses) isEmpty 
	    ifTrue: [nil]
	    ifFalse: [coll first]
    ]

    commandResponses [
	<category: 'responses'>
	^self responses select: [:resp | resp cmdName match: self name]
    ]

    commandResponseValue [
	<category: 'responses'>
	| resp |
	^(resp := self commandResponse) isNil ifTrue: [nil] ifFalse: [resp value]
    ]

    statusResponses [
	<category: 'responses'>
	^self responses select: [:eachResponse | eachResponse isStatusResponse]
    ]

    beDone [
	<category: 'status'>
	self status: #done.
	self client commandIsDone: self.
	self value: self completionResponse
    ]

    beSent [
	<category: 'status'>
	self status: #sent.
	self client commandIsInProgress: self
    ]

    status [
	<category: 'status'>
	^status
    ]

    status: anObject [
	<category: 'status'>
	status := anObject
    ]

    value [
	<category: 'status'>
	^promise value
    ]

    value: anObject [
	<category: 'status'>
	promise value: status
    ]

    failed [
	<category: 'testing'>
	^self successful not
    ]

    isDone [
	<category: 'testing'>
	^self status = #done
    ]

    isSent [
	<category: 'testing'>
	^self status = #sent
    ]

    successful [
	<category: 'testing'>
	^self isDone and: [self completionResponse isOK]
    ]
]

]



Namespace current: NetClients.IMAP [

Object subclass: IMAPFetchedItem [
    | name |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPFetchedItem class >> canBe: aName [
	<category: 'instance creation'>
	^false
    ]

    IMAPFetchedItem class >> defaultFetchedItemClass [
	<category: 'instance creation'>
	^IMAPFetchedItem
    ]

    IMAPFetchedItem class >> named: aName [
	<category: 'instance creation'>
	^(self properSubclassForItemNamed: aName) new name: aName
    ]

    IMAPFetchedItem class >> properSubclassForItemNamed: aName [
	<category: 'instance creation'>
	^IMAPFetchedItem allSubclasses detect: [:each | each canBe: aName]
	    ifNone: [self defaultFetchedItemClass]
    ]

    extractContentFrom: tokenStream [
	<category: 'building'>
	self subclassResponsibility
    ]

    name [
	<category: 'name'>
	^name
    ]

    name: aName [
	<category: 'name'>
	name := aName
    ]
]

]



Namespace current: NetClients.IMAP [

NetProtocolInterpreter subclass: IMAPProtocolInterpreter [
    | responseStream commandSequencer mutex readResponseSemaphore continuationPromise commandsInProgress queuedCommands |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    commandPrefix: aString [
	<category: 'accessing'>
	commandSequencer prefix: aString
    ]

    responseStream [
	<category: 'accessing'>
	^responseStream
    ]

    connect [
	<category: 'connection'>
	super connect.
	self resetCommandSequence.
	responseStream := self connectionStream.
	commandSequencer reset.
	self getResponse
    ]

    defaultCommandPrefix [
	<category: 'constants and defaults'>
	^'imapv4_'
    ]

    defaultResponseClass [
	<category: 'constants and defaults'>
	^IMAPResponse
    ]

    lineEndConvention [
	<category: 'constants and defaults'>
	^LineEndCRLF
    ]

    commandIsDone: command [
	<category: 'events'>
	mutex critical: 
		[commandsInProgress remove: command ifAbsent: [^self].
		readResponseSemaphore wait]
    ]

    commandIsInProgress: command [
	<category: 'events'>
	mutex critical: 
		[commandsInProgress addFirst: command.
		readResponseSemaphore signal]
    ]

    commandIsQueued: command [
	<category: 'events'>
	
    ]

    connectionIsReady [
	<category: 'events'>
	
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	mutex := Semaphore forMutualExclusion.
	readResponseSemaphore := Semaphore new.
	queuedCommands := SharedQueue new.
	commandsInProgress := OrderedCollection new: 4.
	commandSequencer := IMAPCommandSequencer 
		    newPrefix: self defaultCommandPrefix.
	self commandReaderLoop fork.
	self responseReaderLoop fork
    ]

    commandReaderLoop [
	<category: 'private'>
	| command |
	^
	[
	[command := queuedCommands next.
	self class log: ['----------------------------------'] level: #IMAPClient.
	self class log: ['C: ' , command printString] level: #IMAPClient.
	command execute] 
		repeat]
    ]

    commandsInProgress [
	<category: 'private'>
	^commandsInProgress
    ]

    nextCommandSequenceNumber [
	<category: 'private'>
	^commandSequencer next
    ]

    queuedCommands [
	<category: 'private'>
	^queuedCommands
    ]

    resetCommandSequence [
	<category: 'private'>
	commandSequencer reset
    ]

    responseReaderLoop [
	<category: 'private'>
	^
	[
	[readResponseSemaphore
	    wait;
	    signal.
	self handleNextResponse] 
		whileTrue]
    ]

    responseStream: stream [
	"This is ONLY for debugging purposes"

	<category: 'private'>
	responseStream := stream
    ]

    executeCommand: aCommand [
	<category: 'public'>
	aCommand sequenceID isNil 
	    ifTrue: [aCommand sequenceID: self nextCommandSequenceNumber].
	queuedCommands nextPut: aCommand.
	self commandIsQueued: aCommand
    ]

    getResponse [
	<category: 'responses'>
	| resp |
	resp := self defaultResponseClass readFrom: self responseStream.
	self class log: ['  S: ' , resp printLog] level: #IMAPServer.
	^resp
    ]

    handle: aResponse [
	<category: 'responses'>
	^self client handle: aResponse
    ]

    handleContinuationResponse: aResponse [
	<category: 'responses'>
	| promise |
	promise := continuationPromise.
	continuationPromise := nil.
	readResponseSemaphore wait.
	promise value: aResponse
    ]

    handleNextResponse [
	<category: 'responses'>
	| resp |
	resp := self getResponse.
	resp isNil ifTrue: [^false].
	(self waitingForContinuation and: [resp isContinuationResponse]) 
	    ifTrue: 
		[self handleContinuationResponse: resp.
		^true].
	commandsInProgress detect: [:command | command handle: resp]
	    ifNone: [self handle: resp].
	^true
    ]

    waitForContinuation [
	<category: 'responses'>
	| promise |
	continuationPromise isNil ifTrue: [continuationPromise := Promise new].
	promise := continuationPromise.
	readResponseSemaphore signal.
	^promise value
    ]

    waitingForContinuation [
	<category: 'responses'>
	^continuationPromise notNil
    ]

    argumentAsAssociation: argument [
	<category: 'sending tokens'>
	(argument isKindOf: Association) ifTrue: [^argument].
	argument isNil ifTrue: [^'NIL'].
	argument isCharacters ifTrue: [^#string -> argument].
	(argument isKindOf: Number) ifTrue: [^#number -> argument].
	argument isSequenceable ifTrue: [^#parenthesizedList -> argument].
	^argument
    ]

    sendLiteralString: string [
	<category: 'sending tokens'>
	IMAPScanner printLiteralStringLength: string on: self connectionStream.
	self waitForContinuation.
	IMAPScanner printLiteralStringContents: string on: self connectionStream
    ]

    sendToken: token tokenType: tokenType [
	<category: 'sending tokens'>
	tokenType = #literalString 
	    ifTrue: [self sendLiteralString: token]
	    ifFalse: 
		[IMAPScanner 
		    printToken: token
		    tokenType: tokenType
		    on: self connectionStream]
    ]

    sendTokenList: listOfTokens [
	<category: 'sending tokens'>
	| assoc |
	listOfTokens do: 
		[:arg | 
		assoc := self argumentAsAssociation: arg.
		self sendToken: assoc value tokenType: assoc key]
	    separatedBy: [self connectionStream space]
    ]
]

]



Namespace current: NetClients.IMAP [

NetClient subclass: IMAPClient [
    | state |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    IMAPClient class >> defaultPortNumber [
	<category: 'constants'>
	^143
    ]

    protocolInterpreter [
	<category: 'accessing'>
	^IMAPProtocolInterpreter
    ]

    state [
	<category: 'accessing'>
	^state
    ]

    state: aState [
	<category: 'accessing'>
	state := aState.
	state client: self
    ]

    connected [
	"Establish a connection to the host <aString>."

	<category: 'connection'>
	self state: IMAPNonAuthenticatedState new
    ]

    append: message to: aMailboxName [
	<category: 'commands'>
	^self state 
	    append: message
	    to: aMailboxName
	    flags: nil
	    date: nil
    ]

    append: message to: aMailboxName flags: flags date: dateString [
	<category: 'commands'>
	^self state 
	    append: message
	    to: aMailboxName
	    flags: flags
	    date: dateString
    ]

    capability [
	<category: 'commands'>
	^self state capability
    ]

    check [
	<category: 'commands'>
	^self state check
    ]

    close [
	<category: 'commands'>
	^self state close
    ]

    create: aMailBoxName [
	<category: 'commands'>
	^self state create: aMailBoxName
    ]

    delete: aMailBoxName [
	<category: 'commands'>
	^self state delete: aMailBoxName
    ]

    examine: aMailBoxName [
	<category: 'commands'>
	^self state examine: aMailBoxName
    ]

    expunge [
	<category: 'commands'>
	^self state expunge
    ]

    fetch: aCriteria [
	<category: 'commands'>
	^self state fetch: aCriteria
    ]

    fetch: messageNumbers retrieve: criteria [
	<category: 'commands'>
	^self state fetch: messageNumbers retrieve: criteria
    ]

    fetchRFC822Messages: messageNumbers [
	<category: 'commands'>
	| result dict |
	result := self state fetch: messageNumbers retrieve: 'rfc822'.
	dict := Dictionary new: 4.
	^result successful 
	    ifTrue: 
		[result commandResponses 
		    do: [:resp | dict at: resp value put: (resp parameters at: 'RFC822')].
		dict]
	    ifFalse: [nil]
    ]

    list: refName mailbox: name [
	<category: 'commands'>
	^self state list: refName mailbox: name
    ]

    login [
	<category: 'commands'>
	^self state login
    ]

    logout [
	<category: 'commands'>
	^self state logout
    ]

    lsub: refName mailbox: name [
	<category: 'commands'>
	^self state lsub: refName mailbox: name
    ]

    noop [
	<category: 'commands'>
	^self state noop
    ]

    rename: oldMailBox newName: newMailBox [
	<category: 'commands'>
	^self state rename: oldMailBox newName: newMailBox
    ]

    search: aCriteria [
	<category: 'commands'>
	^self state search: aCriteria
    ]

    select: aMailBoxName [
	<category: 'commands'>
	^self state select: aMailBoxName
    ]

    status: aMailBoxNameWithArguments [
	<category: 'commands'>
	^self state status: aMailBoxNameWithArguments
    ]

    store: args [
	<category: 'commands'>
	^self state store: args
    ]

    subscribe: aMailBoxName [
	<category: 'commands'>
	^self state subscribe: aMailBoxName
    ]

    uid: aString [
	<category: 'commands'>
	^self state uid: aString
    ]

    unsubscribe: aMailBoxName [
	<category: 'commands'>
	^self state unsubscribe: aMailBoxName
    ]

    commandClassFor: cmdName [
	<category: 'create&execute command'>
	^self class commandClassFor: cmdName
    ]

    createCommand: aString [
	<category: 'create&execute command'>
	^self createCommand: aString arguments: nil
    ]

    createCommand: aString arguments: anArray [
	<category: 'create&execute command'>
	^IMAPCommand 
	    forClient: clientPI
	    name: aString
	    arguments: anArray
    ]

    execute: cmd arguments: args changeStateTo: aStateBlock [
	<category: 'create&execute command'>
	^self execute: [self createCommand: cmd arguments: args]
	    changeStateTo: aStateBlock
    ]

    execute: aBlock changeStateTo: aStateBlock [
	<category: 'create&execute command'>
	| command |
	command := aBlock value.
	self executeCommand: command.
	command wait.
	command completedSuccessfully ifTrue: [self state: aStateBlock value].
	^command
    ]

    executeAndWait: aString [
	<category: 'create&execute command'>
	^self executeAndWait: aString arguments: nil
    ]

    executeAndWait: aString arguments: anArray [
	<category: 'create&execute command'>
	| command |
	command := self createCommand: aString arguments: anArray.
	self executeCommand: command.
	command wait.
	^command
    ]

    executeCommand: aCommand [
	<category: 'create&execute command'>
	^self clientPI executeCommand: aCommand
    ]

    canonicalizeMailboxName: aMailboxName [
	"#todo. Mailbox names are encoded in UTF-7 format. Add encoding logic here when available"

	<category: 'private'>
	^aMailboxName
    ]

    messageSetAsString: messageNumbers [
	<category: 'private'>
	| stream |
	stream := (String new: 64) writeStream.
	messageNumbers do: [:messageNumber | stream nextPutAll: messageNumber]
	    separatedBy: [stream nextPut: $,].
	^stream contents
    ]

    handle: aResponse [
	"^aResponse"

	<category: 'responses'>
	^true
    ]
]

]



Namespace current: NetClients.IMAP [

Object subclass: IMAPCommandSequencer [
    | prefix value |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPCommandSequencer class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    IMAPCommandSequencer class >> newPrefix: prefix [
	<category: 'instance creation'>
	^(self new)
	    prefix: prefix;
	    yourself
    ]

    next [
	<category: 'accessing'>
	self increment.
	^self prefix , self value printString
    ]

    prefix [
	<category: 'accessing'>
	^prefix
    ]

    prefix: aValue [
	<category: 'accessing'>
	prefix := aValue
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aValue [
	<category: 'accessing'>
	value := aValue
    ]

    initialize [
	<category: 'initialization'>
	value := 0
    ]

    reset [
	<category: 'initialization'>
	self value: 0
    ]

    increment [
	<category: 'private'>
	self value: self value + 1
    ]
]

]



Namespace current: NetClients.IMAP [

Object subclass: IMAPFetchedItemSectionSpecification [
    | specName parameters span rawContent |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPFetchedItemSectionSpecification class >> readFrom: tokenStream [
	<category: 'instance creation'>
	| specName |
	specName := tokenStream next.
	specName isNil ifTrue: [specName := 'Empty'].
	^((self properSubclassFor: specName) new)
	    specName: specName;
	    readFrom: tokenStream
    ]

    IMAPFetchedItemSectionSpecification class >> canBe: aName [
	<category: 'matching'>
	^#('TEXT' 'MIME') includes: aName asUppercase
    ]

    IMAPFetchedItemSectionSpecification class >> defaultClass [
	<category: 'matching'>
	^IMAPFetchedItemSectionSpecification
    ]

    IMAPFetchedItemSectionSpecification class >> properSubclassFor: aName [
	<category: 'matching'>
	^IMAPFetchedItemSectionSpecification withAllSubclasses 
	    detect: [:each | each canBe: aName]
	    ifNone: [self defaultClass]
    ]

    specName [
	<category: 'accessing'>
	^specName
    ]

    specName: aName [
	<category: 'accessing'>
	specName := aName
    ]

    extractContentFrom: tokenStream [
	"
	 Check for a partial fetch- this would include a range specification given in angle brackets.
	 Otherwise, there should only be a single token containing the requested content.
	 "

	<category: 'content'>
	| peekStream |
	peekStream := tokenStream peek readStream.
	peekStream peek = $< 
	    ifTrue: [self extractSpannedContentSpanFrom: tokenStream]
	    ifFalse: [rawContent := tokenStream next]
    ]

    extractSpannedContentSpanFrom: tokenStream [
	"we've lost some information- we need the bytecount, but it is gone.  Must revisit this!!"

	<category: 'content'>
	| startPoint |
	startPoint := ((tokenStream next readStream)
		    next;
		    upTo: $>) asNumber.
	rawContent := tokenStream next.

	"we're going to try to simply use the length of the raw content as the span length- however, this is not actually correct, though it is close."
	span := startPoint @ rawContent size
    ]

    rawContent [
	<category: 'content'>
	^rawContent
    ]

    readFrom: tokenStream [
	"
	 The section spec will be either numeric (if the message is MIME this is oK) or one of the following:
	 'HEADER'
	 'HEADER.FIELDS'
	 'HEADER.FIELDS.NOT'
	 'MIME'
	 'TEXT'
	 
	 Some examples would be:
	 
	 1
	 1.HEADER
	 
	 HEADER
	 HEADER.FIELDS
	 
	 3.2.3.5.HEADER.FIELDS (to fetch header fields for part 3.2.3.5)
	 "

	"the numeric part could be pulled out at this point as the position spec, followed by the section spec, then followed by optional? parameters."

	"positionSpec := ?"

	<category: 'instance creation'>
	parameters := tokenStream next
    ]

    pvtFullSpan [
	<category: 'span'>
	^0 to: self rawContent size
    ]

    span [
	"Items are not always requested in their entirety.  The span tells us which part of the desired content was retrieved."

	<category: 'span'>
	^span notNil ifTrue: [span] ifFalse: [self pvtFullSpan]
    ]

    span: anInterval [
	"Items are not always requested in their entirety.  The span tells us which part of the desired content was retrieved."

	<category: 'span'>
	span := anInterval
    ]
]

]



Namespace current: NetClients.IMAP [

Object subclass: IMAPResponse [
    | source cmdName value |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPResponse class >> defaultResponseClass [
	<category: 'parsing, general'>
	^IMAPResponse
    ]

    IMAPResponse class >> parse: scanner [
	<category: 'parsing, general'>
	| theToken theResponse |
	theToken := scanner nextToken.
	theToken isNil ifTrue: [^nil].

	"
	 IMAP Server responses are classified as either tagged or untagged.
	 Untagged responses begin with either the asterisk or plus sign, while tagged responses begin with the command id.
	 "
	theResponse := (#($* '+') includes: theToken) 
		    ifTrue: [self parseUntagged: scanner withStar: theToken == $*]
		    ifFalse: [self parseTagged: scanner withTag: theToken].
	scanner upTo: Character nl.
	^theResponse
	    source: scanner sourceTrail;
	    yourself
    ]

    IMAPResponse class >> parserForUntaggedResponse: responseName [
	<category: 'parsing, general'>
	| properSubclass |
	properSubclass := IMAPResponse allSubclasses 
		    detect: [:each | each canParse: responseName]
		    ifNone: [self defaultResponseClass].
	^properSubclass new
    ]

    IMAPResponse class >> parserTypeForTaggedStatus: status [
	<category: 'parsing, general'>
	^IMAPResponseTagged
    ]

    IMAPResponse class >> parseTagged: scanner withTag: tag [
	<category: 'parsing, general'>
	| status |
	status := scanner nextToken.
	^(self parserTypeForTaggedStatus: status) 
	    parse: scanner
	    tag: tag
	    status: status
    ]

    IMAPResponse class >> parseContinuationResponse: scanner [
	<category: 'parsing, general'>
	^IMAPContinuationResponse new
    ]

    IMAPResponse class >> parseUntagged: scanner withStar: isStar [
	<category: 'parsing, general'>
	"An untagged responses might be a continuation responses.
	 These begin with the plus sign rather than the asterisk."

	| token token2 |
	isStar ifFalse: [^self parseContinuationResponse: scanner].
	token := scanner nextToken.

	"At this point, we know the response is untagged, but IMAP's untagged responses are not well designed.
	 Some responses provide numeric data first, response or condition name second, while others do it the other way around.
	 What we are doing here is determining what order these things are in, and then doing the parsing accordingly."
	^token first isLetter 
	    ifTrue: [(self parserForUntaggedResponse: token) parse: scanner with: token]
	    ifFalse: 
		[token2 := scanner nextToken.
		(self parserForUntaggedResponse: token2) 
		    parse: scanner
		    forCommandOrConditionNamed: token2
		    withValue: token]
    ]

    IMAPResponse class >> readFrom: stream [
	<category: 'parsing, general'>
	^self parse: (self scannerOn: stream)
    ]

    IMAPResponse class >> scannerOn: stream [
	<category: 'parsing, general'>
	^IMAPScanner on: stream
    ]

    IMAPResponse class >> canParse: responseName [
	<category: 'testing'>
	^false
    ]

    cmdName [
	<category: 'accessing'>
	^cmdName
    ]

    cmdName: aString [
	<category: 'accessing'>
	cmdName := aString
    ]

    source [
	<category: 'accessing'>
	^source
    ]

    source: aString [
	<category: 'accessing'>
	source := aString
    ]

    tag [
	<category: 'accessing'>
	^nil
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: aValue [
	<category: 'accessing'>
	value := aValue
    ]

    parse: scanner [
	<category: 'parsing, general'>
	self value: scanner deepTokenize
    ]

    parse: scanner forCommandOrConditionNamed: commandOrConditionName withValue: codeValue [
	<category: 'parsing, general'>
	self cmdName: commandOrConditionName.
	self value: codeValue.
	self parse: scanner
    ]

    parse: scanner with: commandConditionOrStatusName [
	<category: 'parsing, general'>
	self cmdName: commandConditionOrStatusName.
	self parse: scanner
    ]

    scanFrom: scanner [
	<category: 'parsing, general'>
	self value: scanner deepTokenize
    ]

    scanFrom: scanner forCommandOrConditionNamed: commandOrConditionName withValue: codeValue [
	<category: 'parsing, general'>
	self cmdName: commandOrConditionName.
	self value: codeValue.
	self scanFrom: scanner
    ]

    scanFrom: scanner with: commandConditionOrStatusName [
	<category: 'parsing, general'>
	self cmdName: commandConditionOrStatusName.
	self scanFrom: scanner
    ]

    printLog [
	<category: 'printing'>
	^self source
    ]

    printOn: stream [
	<category: 'printing'>
	source notNil ifTrue: [stream nextPutAll: source]
    ]

    hasTag: aString [
	<category: 'testing'>
	^false
    ]

    isContinuationResponse [
	<category: 'testing'>
	^false
    ]

    isStatusResponse [
	<category: 'testing'>
	^false
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPResponse subclass: IMAPContinuationResponse [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    isContinuationResponse [
	<category: 'testing'>
	^true
    ]
]

]



Namespace current: NetClients.IMAP [

Object subclass: IMAPState [
    | client |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPState class >> forClient: client [
	<category: 'instance creation'>
	^self new client: client
    ]

    client [
	<category: 'accessing'>
	^client
    ]

    capability [
	<category: 'any state valid commands'>
	^client executeAndWait: 'capability'
    ]

    logout [
	<category: 'any state valid commands'>
	| command |
	(command := client executeAndWait: 'logout') completedSuccessfully 
	    ifTrue: [client state: IMAPState new].
	^command
    ]

    noop [
	<category: 'any state valid commands'>
	^client executeAndWait: 'noop'
    ]

    append [
	<category: 'commands'>
	self signalError
    ]

    check: aClient [
	<category: 'commands'>
	self signalError
    ]

    close: aClient [
	<category: 'commands'>
	self signalError
    ]

    copy [
	<category: 'commands'>
	self signalError
    ]

    create: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    delete: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    examine: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    expunge: aClient [
	<category: 'commands'>
	self signalError
    ]

    fetch: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    list: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    login: pi [
	<category: 'commands'>
	self signalError
    ]

    lsub: aClient arguments: aLIst [
	<category: 'commands'>
	self signalError
    ]

    rename: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    search: aClient arguments: aLIst [
	<category: 'commands'>
	self signalError
    ]

    select: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    status [
	<category: 'commands'>
	self signalError
    ]

    store: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    subscribe: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    uid: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    unsubscribe: aClient arguments: aList [
	<category: 'commands'>
	self signalError
    ]

    signalError [
	<category: 'errors'>
	^WrongStateError signal
    ]

    client: aValue [
	<category: 'initialize-release'>
	client := aValue
    ]

    capability: aClient [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'capability') completedSuccessfully 
	    ifTrue: [command]
	    ifFalse: [false]
    ]

    logout: aClient [
	<category: 'obsolete'>
	| command |
	(command := aClient executeAndWait: 'logout') completedSuccessfully 
	    ifTrue: [aClient state: IMAPState new].
	^command
    ]

    noop: client [
	<category: 'obsolete'>
	| command |
	^(command := client executeAndWait: 'noop') completedSuccessfully 
	    ifTrue: [command]
	    ifFalse: [false]
    ]

    isAuthenticated [
	<category: 'testing'>
	^false
    ]

    isSelected [
	<category: 'testing'>
	^false
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPResponse subclass: IMAPDataResponse [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPDataResponse class >> canParse: responseName [
	<category: 'testing'>
	^false
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPState subclass: IMAPAuthenticatedState [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    append: message to: aMailboxName flags: flags date: dateString [
	<category: 'commands'>
	| args |
	args := OrderedCollection 
		    with: (client canonicalizeMailboxName: aMailboxName).
	flags notNil ifTrue: [args add: flags].
	dateString notNil ifTrue: [args add: #atom -> dateString].
	args add: #literalString -> message.
	^client executeAndWait: 'append' arguments: args
    ]

    create: aMailboxName [
	<category: 'commands'>
	^client 
	    execute: 'create'
	    arguments: aMailboxName
	    changeStateTo: [IMAPSelectedState new]
    ]

    delete: aMailboxName [
	<category: 'commands'>
	^client executeAndWait: 'delete' arguments: aMailboxName
    ]

    examine: aMailBoxName [
	<category: 'commands'>
	^client 
	    execute: 'examine'
	    arguments: aMailBoxName
	    changeStateTo: [IMAPSelectedState new]
    ]

    list: refName mailbox: name [
	<category: 'commands'>
	^client executeAndWait: 'list' arguments: (Array with: refName with: name)
    ]

    lsub: refName mailbox: name [
	<category: 'commands'>
	^client executeAndWait: 'lsub' arguments: (Array with: refName with: name)
    ]

    rename: oldMailBox newName: newMailBox [
	<category: 'commands'>
	^client executeAndWait: 'rename'
	    arguments: (Array with: oldMailBox with: newMailBox)
    ]

    select: aMailBoxName [
	<category: 'commands'>
	^client 
	    execute: 'select'
	    arguments: aMailBoxName
	    changeStateTo: [IMAPSelectedState new]
    ]

    status: aMailBoxNameWithArguments [
	<category: 'commands'>
	^client executeAndWait: 'status' arguments: aMailBoxNameWithArguments

	"arguments: (Array with: aMailBoxNameWithArguments)"
    ]

    subscribe: aMailBoxName [
	<category: 'commands'>
	^client executeAndWait: 'subscribe' arguments: (Array with: aMailBoxName)
    ]

    unsubscribe: aMailBoxName [
	<category: 'commands'>
	^client executeAndWait: 'unsubscribe' arguments: (Array with: aMailBoxName)
    ]

    create: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'create' arguments: aList) 
	    completedSuccessfully 
		ifTrue: 
		    [aClient state: IMAPSelectedState new.
		    command]
		ifFalse: [false]
    ]

    delete: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'delete' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    examine: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'examine' arguments: aList) 
	    completedSuccessfully 
		ifTrue: 
		    [aClient state: IMAPSelectedState new.
		    command]
		ifFalse: [nil]
    ]

    list: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'list' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    lsub: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'lsub' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    rename: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'rename' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    select: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'select' arguments: aList) 
	    completedSuccessfully 
		ifTrue: 
		    [aClient state: IMAPSelectedState new.
		    command]
		ifFalse: [nil]
    ]

    subscribe: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'subscribe' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    unsubscribe: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'unsubscribe' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    isAuthenticated [
	<category: 'testing'>
	^true
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPResponse subclass: IMAPStatusResponse [
    | text status |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPStatusResponse class >> canParse: commandOrConditionName [
	<category: 'testing'>
	^#('OK' 'NO' 'BAD' 'BYE') includes: commandOrConditionName
    ]

    status [
	<category: 'accessing'>
	^status
    ]

    status: aStatus [
	<category: 'accessing'>
	status := aStatus
    ]

    text [
	<category: 'accessing'>
	^text
    ]

    parse: scanner [
	<category: 'parsing, general'>
	| val key |
	scanner skipWhiteSpace.
	(scanner peekFor: $[) 
	    ifTrue: 
		[self value: OrderedCollection new.
		scanner flagBracketSpecial: true.
		key := scanner nextToken asUppercase.
		(#('UIDVALIDITY' 'UNSEEN') includes: key) 
		    ifTrue: [val := scanner nextToken asNumber].
		'PERMANENTFLAGS' = key ifTrue: [val := scanner deepNextToken].
		'NEWNAME' = key 
		    ifTrue: 
			[| old new |
			old := scanner nextToken.
			new := scanner nextToken.
			val := Array with: old with: new].
		[scanner nextToken ~~ $] and: [scanner tokenType ~= #doIt]] whileTrue.
		scanner flagBracketSpecial: false].
	text := scanner scanText.
	(#('ALERT' 'PARSE' 'TRYCREATE' 'READ-ONLY' 'READ-WRITE') includes: key) 
	    ifTrue: [val := text].
	self value: key -> val
    ]

    parse: scanner with: commandConditionOrStatusName [
	<category: 'parsing, general'>
	self cmdName: commandConditionOrStatusName.
	self status: commandConditionOrStatusName.
	self parse: scanner
    ]

    isBad [
	<category: 'testing, imap'>
	^self status = 'BAD'
    ]

    isNotAccepted [
	<category: 'testing, imap'>
	^self status = 'NO'
    ]

    isOK [
	<category: 'testing, imap'>
	^self status = 'OK'
    ]

    isStatusResponse [
	<category: 'testing, response type'>
	^true
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPResponse subclass: IMAPCommandCompletionResponse [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPBodySectionFetchedItem [
    | sectionSpec |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPBodySectionFetchedItem class >> canBe: aName [
	"
	 Can the reciever represent items fetched using the given name?  This is not as straightforward as it ought to be.
	 IMAPv4 uses 'BODY' fetches in two very different ways, so we will have to be careful about that.
	 For now, we are not making the distinction, so we will have to revisit this in the future.
	 Also, note that we don't include 'RFC822.SIZE'.  Such a fetch does not return anything complex- it's actually just a simple metadata fetch.
	 "

	"^#(
	 'BODY'
	 'BODY.PEEK'
	 'RFC822'
	 'RFC822.HEADER'
	 'RFC822.TEXT'
	 ) includes: aName."

	<category: 'matching'>
	^false
    ]

    sectionSpec [
	<category: 'accessing'>
	^sectionSpec
    ]

    extractContentFrom: tokenStream [
	"
	 For the body parts extraction case, tokens will be something like:
	 $[
	 'HEADER.FIELDS'
	 #('FIELD1' 'FIELD2')
	 $]
	 '...content as described above...'
	 
	 Whereas for the body (structure) case, the tokens will be something like:
	 #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')
	 
	 What a screwed up spec.
	 "

	"devel thought: It might would be good if the reciever could tell what had been requested, and what had been recieved."

	<category: 'building'>
	| specTokens |
	specTokens := tokenStream
		    upTo: $[;
		    upTo: $].
	(self sectionSpecificationFrom: specTokens) 
	    extractContentFrom: tokenStream
    ]

    sectionSpecificationFrom: tokens [
	<category: 'building'>
	^sectionSpec := IMAPFetchedItemSectionSpecification 
		    readFrom: tokens readStream
    ]

    headerFieldNamed: aName ifAbsent: aBlock [
	"hmm... need a more compex example here."

	<category: 'header fields'>
	self halt
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPState subclass: IMAPNonAuthenticatedState [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    authenticate [
	<category: 'commands'>
	
    ]

    login [
	<category: 'commands'>
	^client 
	    execute: 'login'
	    arguments: (Array with: client user username with: client user password)
	    changeStateTo: [IMAPAuthenticatedState new]
    ]

    login: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	command := aClient executeAndWait: 'login' arguments: aList.
	command completedSuccessfully 
	    ifTrue: [aClient state: IMAPAuthenticatedState new].
	^command
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPMessageEnvelopeFetchedItem [
    | envelope |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPMessageEnvelopeFetchedItem class >> canBe: aName [
	"
	 Can the reciever represent items fetched using the given name?
	 Note that we include 'RFC822.SIZE' .
	 This is just a simple metadata fetch, unlike such things as 'RFC822' or 'RFC822.HEADER' .
	 "

	<category: 'matching'>
	^'ENVELOPE' = aName
    ]

    bccLine [
	<category: 'accessing'>
	^self envelope at: 8
    ]

    ccLine [
	<category: 'accessing'>
	^self envelope at: 7
    ]

    dateLine [
	<category: 'accessing'>
	^self envelope at: 1
    ]

    fromAuthor [
	<category: 'accessing'>
	^(self fromLine at: 1) at: 1
    ]

    fromLine [
	<category: 'accessing'>
	^self envelope at: 3
    ]

    inReplyToLine [
	<category: 'accessing'>
	^self envelope at: 9
    ]

    replyToAuthor [
	<category: 'accessing'>
	^(self replyToLine at: 1) at: 1
    ]

    replyToLine [
	<category: 'accessing'>
	^self envelope at: 5
    ]

    senderAuthor [
	<category: 'accessing'>
	^(self senderLine at: 1) at: 1
    ]

    senderLine [
	<category: 'accessing'>
	^self envelope at: 4
    ]

    subjectLine [
	<category: 'accessing'>
	^self envelope at: 2
    ]

    toLine [
	<category: 'accessing'>
	^self envelope at: 6
    ]

    uniqueMessageIDLine [
	<category: 'accessing'>
	^self envelope at: 10
    ]

    extractContentFrom: tokenStream [
	"the envelope is an array of message metadata- we'll come back to this for interpretation later."

	<category: 'building'>
	self envelope: tokenStream next
    ]

    envelope [
	<category: 'envelope'>
	^envelope
    ]

    envelope: anArray [
	"We have yet to interpret the contents of the given array... we shall need to get to that later."

	<category: 'envelope'>
	envelope := anArray
    ]

    printDevelOn: aStream indent: level [
	<category: 'printing'>
	aStream
	    crtab: level;
	    nextPutAll: 'Date: ';
	    nextPutAll: self dateLine;
	    crtab: level;
	    nextPutAll: 'Subject: ';
	    nextPutAll: self subjectLine;
	    crtab: level;
	    nextPutAll: 'From: ';
	    print: self fromAuthor;
	    crtab: level;
	    nextPutAll: 'Sender: ';
	    print: self senderAuthor;
	    crtab: level;
	    nextPutAll: 'ReplyTo: ';
	    print: self replyToAuthor;
	    crtab: level;
	    nextPutAll: 'To: ';
	    print: self toLine;
	    crtab: level;
	    nextPutAll: 'In Reply To: ';
	    print: self inReplyToLine;
	    crtab: level;
	    nextPutAll: 'Message ID: ';
	    nextPutAll: self uniqueMessageIDLine;
	    crtab: level;
	    nextPutAll: 'Bcc: ';
	    print: self bccLine;
	    crtab: level;
	    nextPutAll: 'Cc: ';
	    print: self ccLine;
	    yourself
    ]

    printOn: aStream [
	<category: 'printing'>
	self printDevelOn: aStream indent: 0
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPBodyRFC822FetchedItem [
    | value |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPBodyRFC822FetchedItem class >> canBe: aName [
	"
	 Note that we don't include 'RFC822.SIZE'.
	 Such a fetch does not return anything complex- it's actually just a simple metadata fetch.
	 "

	<category: 'matching'>
	^#('RFC822' 'RFC822.HEADER' 'RFC822.TEXT') includes: aName
    ]

    extractContentFrom: tokenStream [
	"
	 Cases:
	 RFC822
	 RFC822.Header
	 RFC822.Text
	 "

	<category: 'building'>
	value := tokenStream next
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPMessageMetadataFetchedItem [
    | value |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPMessageMetadataFetchedItem class >> canBe: aName [
	"
	 Can the reciever represent items fetched using the given name?
	 Note that we include 'RFC822.SIZE' .
	 This is just a simple metadata fetch, unlike such things as 'RFC822' or 'RFC822.HEADER' .
	 "

	<category: 'matching'>
	^#('FLAGS' 'INTERNALDATE' 'RFC822.SIZE' 'UID') includes: aName
    ]

    extractContentFrom: tokenStream [
	<category: 'building'>
	self value: tokenStream next
    ]

    value [
	<category: 'value'>
	^value
    ]

    value: anObject [
	<category: 'value'>
	value := anObject
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItemSectionSpecification subclass: IMAPFetchedItemHeaderSectionSpecification [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPFetchedItemHeaderSectionSpecification class >> canBe: aName [
	<category: 'matching'>
	^'HEADER*' match: aName ignoreCase: true
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPBodyStructureFetchedItem [
    | structure |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPBodyStructureFetchedItem class >> canBe: aName [
	<category: 'matching'>
	^'BODYSTRUCTURE' = aName
    ]

    structure [
	<category: 'accessing'>
	^structure
    ]

    structure: aStructure [
	<category: 'accessing'>
	structure := aStructure
    ]

    extractContentFrom: tokenStream [
	"
	 The structure will be something like:
	 #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')
	 "

	<category: 'building'>
	self structure: tokenStream next
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPFetchedItem subclass: IMAPBodyFetchedItem [
    | parts |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPBodyFetchedItem class >> canBe: aName [
	"
	 Can the reciever represent items fetched using the given name?  This is not as straightforward as it ought to be.
	 IMAPv4 uses 'BODY' fetches in two very different ways, so we will have to be careful about that.
	 For now, we are not making the distinction, so we will have to revisit this in the future.
	 "

	<category: 'matching'>
	^#('BODY' 'BODY.PEEK') includes: aName
    ]

    extractBodySectionContentFrom: tokenStream [
	<category: 'building'>
	self parts 
	    add: (IMAPBodySectionFetchedItem new extractContentFrom: tokenStream)
    ]

    extractContentFrom: tokenStream [
	"
	 For the body parts extraction case, tokens will be something like:
	 $[
	 'HEADER.FIELDS'
	 #('FIELD1' 'FIELD2')
	 $]
	 '...content as described above...'
	 
	 Whereas for the body (structure) case, the tokens will be something like:
	 #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')
	 
	 What a screwed up spec.
	 "

	"devel thought: It might would be good if the reciever could tell what had been requested, and what had been recieved."

	"First off, are we talking about a body section fetch, or a short-form body structure fetch? Bastards!!"

	<category: 'building'>
	tokenStream peek = $[ 
	    ifTrue: [self extractBodySectionContentFrom: tokenStream]
	    ifFalse: [self extractShortFormBodyStructureFrom: tokenStream]
    ]

    extractShortFormBodyStructureFrom: tokenStream [
	"
	 Whereas for the body (structure) case, the tokens will be something like:
	 #('TEXT' 'PLAIN' #('CHARSET' 'us-ascii') nil nil '8BIT' '763' '8')
	 "

	<category: 'building'>
	self parts 
	    add: (IMAPBodyStructureFetchedItem new extractContentFrom: tokenStream)
    ]

    parts [
	<category: 'parts'>
	^parts notNil ifTrue: [parts] ifFalse: [parts := OrderedCollection new]
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPDataResponse subclass: IMAPDataResponseFetch [
    | fetchedItems metaResponses |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPDataResponseFetch class >> canParse: responseName [
	<category: 'testing'>
	^'FETCH' = responseName

	"^false"
    ]

    bodyFetch [
	<category: 'fetchable items'>
	^self fetchedItemNamed: 'body' ifAbsent: [nil]
    ]

    bodyText [
	<category: 'fetchable items'>
	^(self fetchedItemNamed: 'body') parts first sectionSpec rawContent
    ]

    envelope [
	<category: 'fetchable items'>
	^self fetchedItemNamed: 'envelope' ifAbsent: [nil]
    ]

    extractFetchedItemsFrom: tokenStream [
	<category: 'fetchable items'>
	
	[tokenStream atEnd not 
	    and: [self fetchableItemNames includes: tokenStream peek]] 
		whileTrue: 
		    [(self newFetchedItemNamed: tokenStream next) 
			extractContentFrom: tokenStream]
    ]

    fetchableItemNames [
	<category: 'fetchable items'>
	^#('ALL' 'BODY' 'BODY.PEEK' 'BODYSTRUCTURE' 'ENVELOPE' 'FAST' 'FULL' 'FLAGS' 'INTERNALDATE' 'RFC822' 'RFC822.HEADER' 'RFC822.SIZE' 'RFC822.TEXT' 'UID')	"actually, there are two forms represented by this name- see the spec."
    ]

    fetchedHeaderNamed: aHeaderName ifAbsent: aBlock [
	<category: 'fetchable items'>
	^self headerFetch fieldNamed: aHeaderName ifAbsent: [aBlock value]
    ]

    fetchedItemNamed: aName [
	<category: 'fetchable items'>
	^self fetchedItemNamed: aName ifAbsent: [nil]
    ]

    fetchedItemNamed: aName ifAbsent: aBlock [
	<category: 'fetchable items'>
	| seekName |
	seekName := aName asLowercase.
	^self fetchedItems at: seekName ifAbsent: [aBlock value]
    ]

    fetchedItems [
	<category: 'fetchable items'>
	^fetchedItems notNil 
	    ifTrue: [fetchedItems]
	    ifFalse: [fetchedItems := Dictionary new]
    ]

    hasUID [
	<category: 'fetchable items'>
	^self fetchedItems includesKey: 'uid'
    ]

    hasUniqueMessageID [
	<category: 'fetchable items'>
	^self hasFetchedItemHaving: 'message-ID'
    ]

    itemHolding: anItemName [
	<category: 'fetchable items'>
	^self fetchedItems traverse: [:eachItem | eachItem]
	    seeking: [:eachItem | eachItem holds: anItemName]
    ]

    newFetchedItemNamed: aName [
	<category: 'fetchable items'>
	^self fetchedItems at: aName asLowercase
	    put: (IMAPFetchedItem named: aName)
    ]

    rawUniqueMessageID [
	"If available, answer the unique message ID as provided within the message's headers."

	<category: 'fetchable items'>
	^self bodyFetch headerFieldNamed: 'message-ID' ifAbsent: [nil]
    ]

    uid [
	"The UID is an item that may or not have been fetched by the reciever."

	<category: 'fetchable items'>
	| uidRaw |
	uidRaw := self fetchedItemNamed: 'UID' ifAbsent: [nil].
	^uidRaw notNil ifTrue: [uidRaw value asNumber] ifFalse: [nil]
    ]

    messageNumber [
	<category: 'message number'>
	^self sequenceNumber
    ]

    messageNumber: aNumber [
	<category: 'message number'>
	self sequenceNumber: aNumber
    ]

    messageSequenceNumber [
	<category: 'message number'>
	^self sequenceNumber
    ]

    sequenceNumber [
	<category: 'message number'>
	^self fetchedItemNamed: 'sequence_number'
    ]

    sequenceNumber: aNumber [
	<category: 'message number'>
	^self fetchedItems at: 'sequence_number' put: aNumber
    ]

    metaResponses [
	<category: 'meta responses'>
	^metaResponses
    ]

    metaResponses: statusResponses [
	<category: 'meta responses'>
	metaResponses := statusResponses
    ]

    parse: scanner [
	<category: 'parsing, general'>
	| tokens |
	scanner flagBracketSpecial: true.
	tokens := scanner deepNextToken.
	scanner flagBracketSpecial: false.
	self extractFetchedItemsFrom: tokens readStream
    ]

    value: aNumber [
	<category: 'parsing, general'>
	self sequenceNumber: (value := aNumber)
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPStatusResponse subclass: IMAPResponseMailboxStatus [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPResponseMailboxStatus class >> canParse: conditionName [
	"should be more- I need to check this."

	<category: 'testing'>
	^#('UNSEEN' 'EXISTS') includes: conditionName
    ]

    parse: scanner [
	<category: 'parsing, general'>
	self halt.
	super parse: scanner
    ]

    parse: scanner forCommandOrConditionNamed: commandOrConditionName withValue: codeValue [
	<category: 'parsing, general'>
	self cmdName: commandOrConditionName.
	self value: codeValue
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPStatusResponse subclass: IMAPResponseTagged [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPResponseTagged class >> parse: scanner tag: tag status: status [
	<category: 'parsing, general'>
	^self new 
	    parse: scanner
	    tag: tag
	    status: status
    ]

    IMAPResponseTagged class >> scanFrom: scanner tag: tag status: status [
	<category: 'parsing, general'>
	^self new 
	    scanFrom: scanner
	    tag: tag
	    status: status
    ]

    IMAPResponseTagged class >> canParse: cmdName [
	<category: 'testing'>
	^false
    ]

    tag [
	<category: 'accessing'>
	^self cmdName
    ]

    text [
	<category: 'accessing'>
	^text
    ]

    parse: scanner tag: tag status: statusString [
	<category: 'parsing, general'>
	self cmdName: tag.
	self status: statusString.
	^self parse: scanner
    ]

    hasTag: tagString [
	<category: 'testing'>
	^self tag match: tagString
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPDataResponse subclass: IMAPDataResponseSearch [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPDataResponseSearch class >> canParse: responseName [
	<category: 'testing'>
	^'SEARCH' = responseName
    ]

    basicIDSequences [
	<category: 'id sequences'>
	| intervals currentStart currentStop currentInterval |
	intervals := OrderedCollection new.
	currentInterval := -1 -> -1.
	self numericIDs do: 
		[:eachNumericID | 
		eachNumericID = (currentInterval value + 1) 
		    ifTrue: [currentInterval value: eachNumericID]
		    ifFalse: 
			[currentStop := currentStart := eachNumericID.
			intervals add: (currentInterval := currentStart -> currentStop)]].
	^intervals collect: 
		[:eachInterval | 
		eachInterval key = eachInterval value 
		    ifTrue: [eachInterval key printString]
		    ifFalse: [eachInterval key printString , ':' , eachInterval value printString]]
    ]

    idSequences [
	"
	 This would be a good place to further condense the basic id sequences.
	 Currently we offer a series of ranges, but these ranges could be combined, eg:
	 #('1:123' '231:321'  etc...)
	 could become:
	 #('1:123, 231:321' etc...)
	 This would reduce the number of fetch requests that would be needed to retrieve the messages identified by the search response.
	 "

	<category: 'id sequences'>
	^self basicIDSequences
    ]

    numericIDs [
	<category: 'id sequences'>
	^self rawIDs collect: [:eachRawID | eachRawID asNumber]
    ]

    rawIDs [
	<category: 'id sequences'>
	^self value
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPAuthenticatedState subclass: IMAPSelectedState [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    check [
	<category: 'commands'>
	^client executeAndWait: 'check'
    ]

    close [
	<category: 'commands'>
	^client 
	    execute: 'close'
	    arguments: nil
	    changeStateTo: [IMAPAuthenticatedState new]
    ]

    copy [
	<category: 'commands'>
	
    ]

    expunge [
	<category: 'commands'>
	^client executeAndWait: 'expunge'
    ]

    fetch: aCriteria [
	<category: 'commands'>
	^client executeAndWait: 'fetch' arguments: aCriteria
    ]

    fetch: messageNumbers retrieve: criteria [
	<category: 'commands'>
	| msgString args |
	msgString := client messageSetAsString: messageNumbers.
	args := OrderedCollection with: msgString.
	criteria notNil 
	    ifTrue: 
		[criteria isCharacters 
		    ifTrue: [args add: criteria]
		    ifFalse: [args addAll: criteria]].
	^client executeAndWait: 'fetch' arguments: args
    ]

    search: aCriteria [
	<category: 'commands'>
	^client executeAndWait: 'search' arguments: aCriteria
    ]

    store: args [
	<category: 'commands'>
	^client executeAndWait: 'store' arguments: args
    ]

    uid: aString [
	<category: 'commands'>
	^client executeAndWait: 'uid' arguments: aString
    ]

    check: aClient [
	<category: 'obsolete'>
	^client executeAndWait: 'check'
    ]

    close: aClient [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'close') completedSuccessfully 
	    ifTrue: 
		[aClient state: IMAPAuthenticatedState new.
		command]
	    ifFalse: [nil]
    ]

    expunge: aClient [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'expunge') completedSuccessfully 
	    ifTrue: [command]
	    ifFalse: [nil]
    ]

    fetch: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'fetch' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    search: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'search' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    store: aClient arguments: aList [
	<category: 'obsolete'>
	| command |
	^(command := aClient executeAndWait: 'store' arguments: aList) 
	    completedSuccessfully ifTrue: [command] ifFalse: [nil]
    ]

    isSelected [
	<category: 'testing'>
	^true
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPDataResponse subclass: IMAPDataResponseList [
    | mbAttributes mbDelimiter mbName |
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPDataResponseList class >> canParse: cmdName [
	<category: 'testing'>
	^'LIST' = cmdName
    ]

    mbAttributes [
	<category: 'accessing'>
	^mbAttributes
    ]

    mbDelimeter [
	<category: 'accessing'>
	^mbDelimiter
    ]

    mbName [
	<category: 'accessing'>
	^mbName
    ]

    parse: scanner [
	"Parse message attributes"

	"(\NOSELECT)  '/'  ~/Mail/foo"

	<category: 'parsing, general'>
	| tokens |
	tokens := scanner deepTokenize.
	mbAttributes := tokens at: 1.
	mbDelimiter := tokens at: 2.
	mbName := tokens at: 3
    ]
]

]



Namespace current: NetClients.IMAP [

MIME.MailScanner subclass: IMAPScanner [
    | flagBracketSpecial |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    TextMask := nil.
    QuotedTextMask := nil.
    QuotedPairChar := nil.
    AtomMask := nil.

    IMAPScanner class >> atomSpecials [
	"These characters cannot occur inside an atom"

	<category: 'character classification'>
	^'( ){%*"\'
    ]

    IMAPScanner class >> specials [
	<category: 'character classification'>
	^self atomSpecials
    ]

    IMAPScanner class >> initClassificationTable [
	<category: 'class initialization'>
	super initClassificationTable.
	self initClassificationTableWith: TextMask when: [:c | c ~~ Character cr].
	self initClassificationTableWith: AtomMask
	    when: [:c | c > Character space and: [(self atomSpecials includes: c) not]].
	self initClassificationTableWith: QuotedTextMask
	    when: [:c | c ~~ $" and: [c ~~ $\ and: [c ~~ Character cr]]]
    ]

    IMAPScanner class >> initialize [
	"IMAPScanner initialize"

	<category: 'class initialization'>
	self
	    initializeConstants;
	    initClassificationTable
    ]

    IMAPScanner class >> initializeConstants [
	<category: 'class initialization'>
	AtomMask := 256.
	QuotedTextMask := 4096.
	TextMask := 8192
    ]

    IMAPScanner class >> defaultTokenType [
	<category: 'printing'>
	^#string
    ]

    IMAPScanner class >> printAtom: atom on: stream [
	<category: 'printing'>
	atom isNil 
	    ifTrue: [stream nextPutAll: 'NIL']
	    ifFalse: [stream nextPutAll: atom	"asUppercase"]
    ]

    IMAPScanner class >> printIMAPString: value on: stream [
	"Print string as either atom or quoted text"

	<category: 'printing'>
	value isNil ifTrue: [self printNilOn: stream].
	(self shouldBeQuoted: value) 
	    ifTrue: [self printQuotedText: value on: stream]
	    ifFalse: [self printAtom: value on: stream]
    ]

    IMAPScanner class >> printLiteralString: aString on: stream [
	"Note that this method is good for printing but not for sending.
	 IMAP requires sender to send string length, then wait for continuation response"

	<category: 'printing'>
	self printLiteralStringLength: aString on: stream.
	self printLiteralStringContents: aString on: stream
    ]

    IMAPScanner class >> printLiteralStringContents: aString on: stream [
	<category: 'printing'>
	stream nextPutAll: aString
    ]

    IMAPScanner class >> printLiteralStringLength: aString on: stream [
	<category: 'printing'>
	stream nextPut: ${.
	aString size printOn: stream.
	stream
	    nextPut: $};
	    nl
    ]

    IMAPScanner class >> printNilOn: stream [
	<category: 'printing'>
	stream nextPutAll: 'NIL'
    ]

    IMAPScanner class >> printParenthesizedList: arrayOfAssociations on: stream [
	"In order to accurately print parenthesized list, we need to know
	 token types of every element. This is applied recursively"

	<category: 'printing'>
	stream nextPut: $(.
	self printTokenList: arrayOfAssociations on: stream.
	stream nextPut: $)
    ]

    IMAPScanner class >> printToken: value tokenType: aSymbol on: stream [
	<category: 'printing'>
	aSymbol = #string ifTrue: [^self printIMAPString: value on: stream].
	aSymbol = #literalString 
	    ifTrue: [^self printLiteralString: value on: stream].
	aSymbol = #atom ifTrue: [^self printAtom: value on: stream].
	aSymbol = #quotedText ifTrue: [^self printQuotedText: value on: stream].
	aSymbol = #nil ifTrue: [^self printNilOn: stream].
	aSymbol = #parenthesizedList 
	    ifTrue: [^self printParenthesizedList: value on: stream].	"Invalid token type"
	aSymbol = #special ifTrue: [^stream nextPut: value].
	self halt
    ]

    IMAPScanner class >> stringAsAssociation: string [
	<category: 'printing'>
	(self shouldBeQuoted: string) ifFalse: [^#atom -> string].
	(string first == $\ and: 
		[string size > 1 
		    and: [self shouldBeQuoted: (string copyFrom: 2 to: string size) not]]) 
	    ifTrue: [^#atom -> string].
	^#quotedText -> string
    ]

    IMAPScanner class >> tokenAsAssociation: token [
	<category: 'printing'>
	(token isKindOf: Association) ifTrue: [^token].
	token isNil ifTrue: [^'NIL'].
	token isCharacters ifTrue: [^self stringAsAssociation: token].
	(token isKindOf: Number) ifTrue: [^#number -> token].
	token isSequenceable ifTrue: [^#parenthesizedList -> token].
	^token
    ]

    IMAPScanner class >> isAtomChar: char [
	<category: 'testing'>
	^((self classificationTable at: char asInteger + 1) bitAnd: AtomMask) ~= 0
    ]

    IMAPScanner class >> shouldBeQuoted: string [
	<category: 'testing'>
	^(string detect: [:char | (self isAtomChar: char) not] ifNone: [nil]) 
	    notNil
    ]

    flagBracketSpecial [
	<category: 'accessing'>
	flagBracketSpecial isNil ifTrue: [flagBracketSpecial := false].
	^flagBracketSpecial
    ]

    flagBracketSpecial: aBoolean [
	<category: 'accessing'>
	flagBracketSpecial := aBoolean
    ]

    doSpecialScanProcessing [
	"Hacks that require special handling of IMAP tokens go here.
	 The most frustrating one for us was handling of message/mailbox flags that have format \<atom> as
	 in \Seen. The problem is that $\ is not an atom-char, so these flags are tokenized as #($\ 'Seen').
	 We make heuristical decision here if current token is $\ immediately followed by a letter. We will
	 then read next token and merge $\ and next token answering a string. This is ONLY applied inside a
	 parenthesized list"

	<category: 'multi-character scans'>
	(token == $\ 
	    and: [(self classificationMaskFor: self peek) anyMask: AlphabeticMask]) 
		ifTrue: 
		    [self nextToken.
		    token := '\' , token.
		    tokenType := #string]
    ]

    scanAtom [
	"atom = 1*<any CHAR except atom-specials (which includes atomSpecials, space and CTLs)>"

	<category: 'multi-character scans'>
	token := self scanWhile: 
			[(self isBracketSpecial: hereChar) not 
			    and: [self matchCharacterType: AtomMask]].
	(token match: 'NIL') 
	    ifTrue: 
		["RFC2060 defines NIL as a special atom type, atoms are not case-sensitive"

		token := nil.
		tokenType := #nil]
	    ifFalse: [tokenType := #atom].
	^token
    ]

    scanLiteralText [
	"<{> nnn <}> <CRLF> <nnn bytes>"

	<category: 'multi-character scans'>
	| nbytes string |
	nbytes := self scanLiteralTextLength.
	string := self nextBytesAsString: nbytes.
	token := string 
		    copyReplaceAll: (String with: Character cr with: Character nl)
		    with: (String with: Character nl).
	tokenType := #literalString.
	^token
    ]

    scanLiteralTextLength [
	"<{> nnn <}> <CRLF>"

	"We are positioned at the first brace character"

	<category: 'multi-character scans'>
	token := self 
		    scanToken: [self matchCharacterType: DigitMask]
		    delimitedBy: '{}'
		    notify: 'Malformed literal length'.
	self upTo: Character nl.
	^Integer readFrom: token readStream
    ]

    scanParenthesizedList [
	<category: 'multi-character scans'>
	| stream |
	stream := (Array new: 4) writeStream.
	self mustMatch: $( notify: 'Parenthesized list should begin with ('.
	self deepTokenizeUntil: [token == $)]
	    do: 
		[self doSpecialScanProcessing.
		stream nextPut: token].
	token ~~ $) ifTrue: [self notify: 'Non-terminated parenthesized list'].
	token := stream contents.
	tokenType := #parenthesizedList.
	^token
    ]

    scanParenthesizedListAsAssociation [
	<category: 'multi-character scans'>
	| stream |
	stream := (Array new: 4) writeStream.
	self mustMatch: $( notify: 'Parenthesized list should begin with ('.
	self deepTokenizeAsAssociationUntil: [token == $)]
	    do: 
		[:assoc | 
		self doSpecialScanProcessing.
		stream nextPut: tokenType -> token].
	token ~~ $) ifTrue: [self notify: 'Non-terminated parenthesized list'].
	token := stream contents.
	tokenType := #parenthesizedList.
	^tokenType -> token
    ]

    scanQuotedChar [
	"Scan possible quoted character. If the current char is $\, read in next character and make it a quoted
	 string character"

	<category: 'multi-character scans'>
	^hereChar == $\ 
	    ifTrue: 
		[self step.
		classificationMask := QuotedTextMask.
		true]
	    ifFalse: [false]
    ]

    scanQuotedText [
	"quoted-string = <"

	"> *(quoted_char / quoted-pair) <"

	">
	 quoted_char    =  <any CHAR except <"

	"> and <\>"

	"We are positioned at the first double quote character"

	<category: 'multi-character scans'>
	token := self 
		    scanToken: 
			[self
			    scanQuotedChar;
			    matchCharacterType: QuotedTextMask]
		    delimitedBy: '""'
		    notify: 'Unmatched quoted text'.
	tokenType := #quotedText.
	^token
    ]

    scanText [
	"RFC822: text = <Any CHAR, including bare CR & bare LF, but not including CRLF. This is a 'catchall' category and cannot be tokenized. Text is used only to read values of unstructured fields"

	<category: 'multi-character scans'>
	^self
	    skipWhiteSpace;
	    scanWhile: [(self matchCharacterType: CRLFMask) not]
    ]

    printLiteralString: aString on: stream [
	<category: 'printing'>
	self class printLiteralStringLength: aString on: stream.
	self class printLiteralStringContents: aString on: stream
    ]

    isBracketSpecial: char [
	<category: 'private'>
	^self flagBracketSpecial and: ['[]' includes: char]
    ]

    nextBytesAsString: nbytes [
	<category: 'private'>
	| str |
	^source isExternalStream 
	    ifTrue: 
		[
		[self binary.
		str := (source next: nbytes) asString.
		self sourceTrailNextPutAll: str.
		str] 
			ensure: [self text]]
	    ifFalse: [super next: nbytes]
    ]

    nextIMAPToken [
	<category: 'private'>
	| char |
	self skipWhiteSpace.
	char := self peek.
	char isNil 
	    ifTrue: 
		["end of input"

		tokenType := #doIt.
		^token := nil].
	char == $" ifTrue: [^self scanQuotedText].
	char == ${ ifTrue: [^self scanLiteralText].
	(char < Character space 
	    or: [(self specials includes: char) or: [self isBracketSpecial: char]]) 
		ifTrue: 
		    ["Special character. Make it token value and set token type"

		    tokenType := #special.
		    token := self next.
		    ^token].
	(self matchCharacterType: AtomMask) ifTrue: [^self scanAtom].
	tokenType := #doIt.
	token := char.
	^token
    ]

    deepNextToken [
	<category: 'tokenization'>
	^self nextToken == $( 
	    ifTrue: 
		[self
		    stepBack;
		    scanParenthesizedList]
	    ifFalse: [token]
    ]

    deepNextTokenAsAssociation [
	<category: 'tokenization'>
	^self nextToken == $( 
	    ifTrue: 
		[self
		    stepBack;
		    scanParenthesizedListAsAssociation]
	    ifFalse: [tokenType -> token]
    ]

    deepTokenize [
	<category: 'tokenization'>
	| stream |
	stream := (Array new: 4) writeStream.
	
	[self deepNextToken.
	tokenType = #doIt or: [token == Character cr or: [token == Character nl]]] 
		whileFalse: [stream nextPut: token].
	token == Character cr ifTrue: [self stepBack].
	token == Character nl ifTrue: [self stepBack].
	^stream contents
    ]

    deepTokenizeAsAssociation [
	<category: 'tokenization'>
	| stream assoc |
	stream := (Array new: 4) writeStream.
	
	[assoc := self deepNextTokenAsAssociation.
	assoc key = #doIt] 
		whileFalse: [stream nextPut: assoc].
	^stream contents
    ]

    deepTokenizeAsAssociationUntil: aBlock do: actionBlock [
	<category: 'tokenization'>
	| assoc |
	
	[self skipWhiteSpace.
	assoc := self deepNextTokenAsAssociation.
	assoc key = #doIt or: aBlock] 
		whileFalse: [actionBlock value: assoc]
    ]

    deepTokenizeUntil: aBlock do: actionBlock [
	<category: 'tokenization'>
	
	[self
	    skipWhiteSpace;
	    deepNextToken.
	tokenType == #doIt or: aBlock] 
		whileFalse: [actionBlock value]
    ]

    nextToken [
	<category: 'tokenization'>
	^self nextIMAPToken
    ]

    specials [
	<category: 'tokenization'>
	^self class atomSpecials
    ]
]

]



Namespace current: NetClients.IMAP [

IMAPDataResponseList subclass: IMAPDataResponseLSub [
    
    <category: 'NetClients-IMAP'>
    <comment: nil>

    IMAPDataResponseLSub class >> canParse: cmdName [
	<category: 'testing'>
	^'LSUB' = cmdName
    ]
]

]



Namespace current: NetClients.IMAP [
    IMAPCommand initialize.
    IMAPScanner initialize
]

PK
     �[h@�s�Z  Z    package.xmlUT	 ǉXOǉXOux �  �  <package>
  <name>NetClients</name>
  <namespace>NetClients</namespace>
  <test>
    <namespace>NetClients</namespace>
    <prereq>NetClients</prereq>
    <prereq>SUnit</prereq>
    <filein>IMAPTests.st</filein>
  </test>
  <prereq>Sockets</prereq>

  <filein>MIME.st</filein>
  <filein>Base.st</filein>
  <filein>ContentHandler.st</filein>
  <filein>IMAP.st</filein>
  <filein>POP.st</filein>
  <filein>SMTP.st</filein>
  <filein>NNTP.st</filein>
  <filein>FTP.st</filein>
  <filein>HTTP.st</filein>
  <filein>URIResolver.st</filein>
  <filein>NetServer.st</filein>
  <file>ChangeLog</file>
</package>PK
     �Mh@#�x��<  �<    FTP.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   FTP protocol support
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, and in the public domain
| Copyright (c) 2002, 2008 Free Software Foundation, Inc.
| Adapted by Paolo Bonzini.
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



Namespace current: NetClients.FTP [

Object subclass: FTPServerEntity [
    | permissions id owner group sizeInBytes modifiedDate filename isDirectory |
    
    <category: 'NetClients-FTP'>
    <comment: nil>

    filename [
	<category: 'accessing'>
	^filename
    ]

    filename: aValue [
	<category: 'accessing'>
	filename := aValue
    ]

    group [
	<category: 'accessing'>
	^group
    ]

    group: aValue [
	<category: 'accessing'>
	group := aValue
    ]

    id [
	<category: 'accessing'>
	^id
    ]

    id: aValue [
	<category: 'accessing'>
	id := aValue asNumber
    ]

    isDirectory [
	<category: 'accessing'>
	^isDirectory
    ]

    isDirectory: aValue [
	<category: 'accessing'>
	isDirectory := aValue
    ]

    modifiedDate [
	<category: 'accessing'>
	^modifiedDate
    ]

    modifiedDate: aValue [
	<category: 'accessing'>
	modifiedDate := aValue
    ]

    owner [
	<category: 'accessing'>
	^owner
    ]

    owner: aValue [
	<category: 'accessing'>
	owner := aValue
    ]

    permissions [
	<category: 'accessing'>
	^permissions
    ]

    permissions: aValue [
	<category: 'accessing'>
	permissions := aValue
    ]

    sizeInBytes [
	<category: 'accessing'>
	^sizeInBytes
    ]

    sizeInBytes: aValue [
	<category: 'accessing'>
	sizeInBytes := aValue asNumber
    ]

    displayString [
	<category: 'displaying'>
	| stream |
	stream := Stream on: (String new: 100).
	self isDirectory 
	    ifTrue: [stream nextPutAll: ' <D> ']
	    ifFalse: [stream space: 5].
	stream
	    nextPutAll: self filename;
	    space: 30 - self filename size.
	stream nextPutAll: self sizeInBytes printString.
	^stream contents
    ]

    from: stream [
	<category: 'initialize-release'>
	self permissions: (stream upTo: Character space).
	stream skipSeparators.
	self id: (stream upTo: Character space).
	stream skipSeparators.
	self owner: (stream upTo: Character space).
	stream skipSeparators.
	self group: (stream upTo: Character space).
	stream skipSeparators.
	self sizeInBytes: (stream upTo: Character space).
	stream skipSeparators.
	self modifiedDate: (self getDateFromNext: 3 on: stream).
	stream skipSeparators.
	self filename: (stream upTo: Character space).
	self isDirectory: self sizeInBytes = 0
    ]

    getDateFromNext: aNumber on: stream [
	<category: 'private'>
	| iStream |
	iStream := WriteStream on: (String new: 100).
	aNumber timesRepeat: 
		[iStream nextPutAll: (stream upTo: Character space).
		iStream nextPut: Character space.
		stream skipSeparators].
	^DateTime readFrom: iStream contents readStream
    ]
]

]



Namespace current: NetClients.FTP [

NetClient subclass: FTPClient [
    | loggedInUser |
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-FTP'>

    FTPClient class >> defaultPortNumber [
	<category: 'constants'>
	^21
    ]

    FTPClient class >> exampleHost: host [
	"self exampleHost: 'localhost'."

	<category: 'examples'>
	^self exampleHost: host port: 21
    ]

    FTPClient class >> exampleHost: host port: port [
	"self exampleHost: 'localhost' port: 2121."

	<category: 'examples'>
	| user password stream client |
	user := 'utente'.
	password := 'bonzini'.
	stream := WriteStream on: (String new: 256).
	client := FTPClient connectToHost: host port: port.
	
	[client
	    username: user password: password;
	    login;
	    getList: '/' into: stream] 
		ensure: [client close].
	^stream contents
    ]

    FTPClient class >> exampleHost: host fileName: fileName [
	"self exampleHost: 'localhost'."

	<category: 'examples'>
	^self 
	    exampleHost: host
	    port: 21
	    fileName: fileName
    ]

    FTPClient class >> exampleHost: host port: port fileName: fileName [
	"self exampleHost: 'arrow' fileName: '/pub/smallwalker/README'."

	<category: 'examples'>
	| user password stream client |
	user := 'utente'.
	password := 'bonzini'.
	stream := WriteStream on: (String new: 256).
	client := FTPClient connectToHost: host port: port.
	
	[client
	    username: user password: password;
	    login;
	    getFile: fileName
		type: #ascii
		into: stream] 
		ensure: [client close].
	^stream contents
    ]

    protocolInterpreter [
	<category: 'private'>
	^FTPProtocolInterpreter
    ]

    login [
	<category: 'ftp'>
	self connectIfClosed.
	loggedInUser = self user ifTrue: [^self].
	self clientPI ftpUser: self user username.
	self clientPI ftpPassword: self user password.
	loggedInUser := self user
    ]

    logout [
	<category: 'ftp'>
	loggedInUser := nil.
	(self clientPI)
	    ftpQuit;
	    close
    ]

    getFile: fileName type: type into: aStream [
	<category: 'ftp'>
	| fname directory tail |
	self login.
	fname := File path: fileName.
	directory := fname path asString.
	tail := fname stripPath asString.
	tail isEmpty 
	    ifTrue: 
		[^self clientPI 
		    getDataWithType: type
		    into: aStream
		    do: [self clientPI ftpRetrieve: fileName]]
	    ifFalse: 
		[self clientPI ftpCwd: directory.
		^self clientPI 
		    getDataWithType: type
		    into: aStream
		    do: [self clientPI ftpRetrieve: tail]]
    ]

    getList: pathName into: aStream [
	<category: 'ftp'>
	| fname directory tail |
	self login.
	fname := File path: pathName.
	directory := fname path asString.
	tail := fname stripPath asString.
	self clientPI ftpCwd: directory.
	^self clientPI 
	    getDataWithType: #ascii
	    into: aStream
	    do: 
		[tail isEmpty 
		    ifTrue: [self clientPI ftpList]
		    ifFalse: [self clientPI ftpList: tail].
		0]
    ]
]

]



Namespace current: NetClients.FTP [

NetProtocolInterpreter subclass: FTPProtocolInterpreter [
    
    <import: Sockets>
    <comment: nil>
    <category: 'NetClients-FTP'>

    openDataConnectionDo: controlBlock [
	<category: 'data connection'>
	"Create a socket.  Set up a queue for a single connection."

	| portSocket dataStream |
	portSocket := ServerSocket 
		    reuseAddr: true
		    port: 0
		    queueSize: 1
		    bindTo: nil.
	
	[self ftpPort: portSocket port host: portSocket address asByteArray.

	"issue control command."
	controlBlock value.
	[(dataStream := portSocket accept) isNil] whileTrue: [Processor yield]] 
		ensure: [portSocket close].
	^dataStream
    ]

    openPassiveDataConnectionDo: controlBlock [
	<category: 'data connection'>
	"Enter Passive Mode"

	| array dataSocket dataStream |
	array := self ftpPassive.
	dataStream := Socket remote: (IPAddress fromBytes: (array at: 1))
		    port: (array at: 2).

	"issue control command."
	controlBlock value.
	^dataStream
    ]

    connect [
	<category: 'ftp protocol'>
	super connect.
	self checkResponse
    ]

    getDataWithType: type into: aStream do: controlBlock [
	<category: 'ftp protocol'>
	| dataStream totalByte coll |
	(#(#ascii #binary) includes: type) 
	    ifFalse: [^self error: 'type must be #ascii or #binary'].
	type == #ascii ifTrue: [self ftpTypeAscii] ifFalse: [self ftpTypeBinary].

	"dataStream := self openDataConnectionDo: [totalByte := controlBlock value]."
	dataStream := self 
		    openPassiveDataConnectionDo: [totalByte := controlBlock value].
	totalByte > 0 ifTrue: [self reporter totalByte: totalByte].
	self reporter startTransfer.
	
	[[dataStream atEnd] whileFalse: 
		[| byte |
		byte := dataStream nextAvailable: 1024.
		self reporter readByte: byte size.
		type == #ascii 
		    ifTrue: [aStream nextPutAll: (self decode: byte)]
		    ifFalse: [aStream nextPutAll: byte]]] 
		ensure: [dataStream close].
	self reporter endTransfer
    ]

    ftpAbort [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'ABOR';
	    cr.
	self checkResponse
    ]

    ftpCdup [
	"Change to Parent Directory"

	<category: 'ftp protocol'>
	self
	    nextPutAll: 'CDUP';
	    cr.
	self checkResponse
    ]

    ftpCwd: directory [
	"Change Working Directory"

	<category: 'ftp protocol'>
	self
	    nextPutAll: 'CWD ' , directory;
	    cr.
	self checkResponse
    ]

    ftpList [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'LIST';
	    cr.
	self checkResponse
    ]

    ftpList: pathName [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'LIST ' , pathName;
	    cr.
	self checkResponse
    ]

    ftpPassive [
	<category: 'ftp protocol'>
	| response stream hostAddress port |
	self
	    nextPutAll: 'PASV';
	    cr.
	response := self getResponse.
	self checkResponse: response.
	response status = 227 
	    ifFalse: [^self unexpectedResponse: response].

	"227 Entering Passive Mode (h1,h2,h3,h4,p1,p2)"
	stream := response statusMessage readStream.
	hostAddress := ByteArray new: 4.
	stream upTo: $(.
	hostAddress at: 1 put: (Integer readFrom: stream).
	stream skip: 1.
	hostAddress at: 2 put: (Integer readFrom: stream).
	stream skip: 1.
	hostAddress at: 3 put: (Integer readFrom: stream).
	stream skip: 1.
	hostAddress at: 4 put: (Integer readFrom: stream).
	stream skip: 1.
	port := Integer readFrom: stream.
	stream skip: 1.
	port := (port bitShift: 8) + (Integer readFrom: stream).
	^Array with: hostAddress with: port
    ]

    ftpPassword: password [
	<category: 'ftp protocol'>
	| response |
	self
	    nextPutAll: 'PASS ' , password;
	    cr.
	response := self getResponse.
	self checkResponse: response
	    ifError: [self loginIncorrectError: response statusMessage]
    ]

    ftpPort: portInteger host: hostAddressBytes [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'PORT ';
	    nextPutAll: (hostAddressBytes at: 1) printString;
	    nextPut: $,;
	    nextPutAll: (hostAddressBytes at: 2) printString;
	    nextPut: $,;
	    nextPutAll: (hostAddressBytes at: 3) printString;
	    nextPut: $,;
	    nextPutAll: (hostAddressBytes at: 4) printString;
	    nextPut: $,;
	    nextPutAll: ((portInteger bitShift: -8) bitAnd: 255) printString;
	    nextPut: $,;
	    nextPutAll: (portInteger bitAnd: 255) printString;
	    cr.
	self checkResponse
    ]

    ftpQuit [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'QUIT';
	    cr.
	self checkResponse
    ]

    ftpRetrieve: fileName [
	<category: 'ftp protocol'>
	| response stream |
	self
	    nextPutAll: 'RETR ' , fileName;
	    cr.
	response := self getResponse.
	self checkResponse: response.

	"150 Opening data connection for file (398 bytes)."
	stream := response statusMessage readStream.
	stream skipTo: $(.
	stream atEnd ifTrue: [^nil].
	^Integer readFrom: stream
    ]

    ftpStore: fileName [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'STOR ' , fileName;
	    cr.
	self checkResponse
    ]

    ftpType: type [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'TYPE ' , type;
	    cr.
	self checkResponse
    ]

    ftpTypeAscii [
	<category: 'ftp protocol'>
	^self ftpType: 'A'
    ]

    ftpTypeBinary [
	<category: 'ftp protocol'>
	^self ftpType: 'I'
    ]

    ftpUser: user [
	<category: 'ftp protocol'>
	self
	    nextPutAll: 'USER ' , user;
	    cr.
	self checkResponse
    ]

    checkResponse: response ifError: errorBlock [
	<category: 'private'>
	| status |
	status := response status.

	"Positive Preliminary reply"
	status = 110 
	    ifTrue: 
		["Restart marker reply"

		^self].
	status = 120 
	    ifTrue: 
		["Service ready in nnn minutes"

		^self].
	status = 125 
	    ifTrue: 
		["Data connection already open"

		^self].
	status = 150 
	    ifTrue: 
		["File status okay"

		^self].

	"Positive Completion reply"
	status = 200 
	    ifTrue: 
		["OK"

		^self].
	status = 202 
	    ifTrue: 
		["Command not implemented"

		^self].
	status = 211 
	    ifTrue: 
		["System status"

		^self].
	status = 212 
	    ifTrue: 
		["Directory status"

		^self].
	status = 213 
	    ifTrue: 
		["File status"

		^self].
	status = 214 
	    ifTrue: 
		["Help message"

		^self].
	status = 215 
	    ifTrue: 
		["NAME system type"

		^self].
	status = 220 
	    ifTrue: 
		["Service ready for new user"

		^self].
	status = 221 
	    ifTrue: 
		["Service closing control connection"

		^self].
	status = 225 
	    ifTrue: 
		["Data connection open"

		^self].
	status = 226 
	    ifTrue: 
		["Closing data connection"

		^self].
	status = 227 
	    ifTrue: 
		["Entering Passive Mode"

		^self].
	status = 230 
	    ifTrue: 
		["User logged in"

		^self].
	status = 250 
	    ifTrue: 
		["Requested file action okay"

		^self].
	status = 257 
	    ifTrue: 
		["'PATHNAME' created"

		^self].

	"Positive Intermediate reply"
	status = 331 
	    ifTrue: 
		["User name okay"

		^self].
	status = 332 
	    ifTrue: 
		["Need account for login"

		^self].
	status = 350 
	    ifTrue: 
		["Requested file action pending"

		^self].

	"Transient Negative Completion reply"
	status = 421 
	    ifTrue: 
		["Service not available"

		^errorBlock value].
	status = 425 
	    ifTrue: 
		["Can't open data connection"

		^errorBlock value].
	status = 426 
	    ifTrue: 
		["Connection closed"

		^errorBlock value].
	status = 450 
	    ifTrue: 
		["Requested file action not taken"

		^errorBlock value].
	status = 451 
	    ifTrue: 
		["Requested action aborted"

		^errorBlock value].
	status = 452 
	    ifTrue: 
		["Requested action not taken"

		^errorBlock value].

	"Permanent Negative Completion reply"
	status = 500 
	    ifTrue: 
		["Syntax error"

		^errorBlock value].
	status = 501 
	    ifTrue: 
		["Syntax error"

		^errorBlock value].
	status = 502 
	    ifTrue: 
		["Command not implemented"

		^errorBlock value].
	status = 503 
	    ifTrue: 
		["Bad sequence of commands"

		^errorBlock value].
	status = 504 
	    ifTrue: 
		["Command not implemented"

		^errorBlock value].
	status = 530 
	    ifTrue: 
		["Not logged in"

		^self loginIncorrectError: response statusMessage].
	status = 532 
	    ifTrue: 
		["Need account for storing files"

		^errorBlock value].
	status = 550 
	    ifTrue: 
		["Requested action not taken"

		^self fileNotFoundError: response statusMessage].
	status = 551 
	    ifTrue: 
		["Requested action aborted"

		^errorBlock value].
	status = 552 
	    ifTrue: 
		["Requested file action aborted"

		^errorBlock value].
	status = 553 
	    ifTrue: 
		["Requested action not taken"

		^errorBlock value].

	"Unknown status"
	^errorBlock value
    ]

    fileNotFoundError: errorString [
	<category: 'private'>
	^FTPFileNotFoundError signal: errorString
    ]
]

]



Namespace current: NetClients.FTP [

NetClientError subclass: FTPFileNotFoundError [
    
    <comment: nil>
    <category: 'NetClients-FTP'>
]

]

PK
     �Mh@���(}  }    Base.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   Abstract NetClient framework
|
|
 ======================================================================"

"======================================================================
|
| NetUser and NetEnvironment are Copyright 2000 Cincom, Inc.
| NetResponse, PluggableReporter and *Error are (c) 1995 Kazuki Yasumatsu
| and in the public domain.
|
| The rest is copyright 2002, 2007, 2008, 2009 Free Software Foundation, Inc.
| and written by Paolo Bonzini.
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
    NetClients at: #LineEndCR put: #cr.
    NetClients at: #LineEndLF put: #nl.
    NetClients at: #LineEndCRLF put: #crnl.
    NetClients at: #LineEndTransparent put: #yourself
]



Object subclass: NetUser [
    | username password |
    
    <category: 'NetClients-Framework'>
    <comment: 'Instances of this class hold the username and password used to login to a mail server.

Instance Variables:
	username	<String>		username string
	password	<String>		password string'>

    NetUser class >> username: aUsername password: aPassword [
	"NetUser username: 'foo' password: 'foo'"

	<category: 'instance creation'>
	| user |
	user := self new.
	^user
	    username: aUsername;
	    password: aPassword yourself
    ]

    password [
	<category: 'accessing'>
	^password
    ]

    password: aString [
	<category: 'accessing'>
	password := aString
    ]

    username [
	<category: 'accessing'>
	^username
    ]

    username: aString [
	<category: 'accessing'>
	username := aString
    ]
]



Object subclass: NetEnvironment [
    | debugStream debugCategories debugClasses trace logFileName |
    
    <category: 'NetClients-Framework'>
    <comment: nil>

    NetEnvironment class [
	| uniqueInstance |
	
    ]

    NetEnvironment class >> default [
	<category: 'accessing'>
	^uniqueInstance isNil 
	    ifTrue: [uniqueInstance := self new]
	    ifFalse: [uniqueInstance]
    ]

    debugCategories [
	<category: 'accessing'>
	debugCategories isNil 
	    ifTrue: 
		[debugCategories := Set new.
		debugCategories add: #general].
	^debugCategories
    ]

    debugClasses [
	<category: 'accessing'>
	^debugClasses isNil 
	    ifTrue: [debugClasses := Set new]
	    ifFalse: [debugClasses]
    ]

    debugStream [
	<category: 'accessing'>
	^debugStream
    ]

    debugStream: aStream [
	<category: 'accessing'>
	debugStream := aStream
    ]

    logFileName [
	<category: 'accessing'>
	logFileName isNil ifTrue: [logFileName := 'NetClientLog.txt'].
	^logFileName
    ]

    logFileName: aString [
	<category: 'accessing'>
	logFileName := aString
    ]

    trace [
	<category: 'accessing'>
	trace isNil ifTrue: [trace := false].
	^trace
    ]

    trace: aBoolean [
	<category: 'accessing'>
	trace := aBoolean
    ]

    debug: aBlock level: aLevel [
	<category: 'debugging'>
	(self trace and: [self debugCategories includes: aLevel]) 
	    ifTrue: [aBlock value]
    ]

    log: aStringOrBlock [
	<category: 'debugging'>
	self log: aStringOrBlock level: #general
    ]

    log: aStringOrBlock level: aLevel [
	<category: 'debugging'>
	| stream i briefMsg aMsg |
	self debug: 
		[(stream := self debugStream) == nil ifTrue: [^self].
		(aStringOrBlock isKindOf: BlockClosure) 
		    ifTrue: [aMsg := aStringOrBlock value]
		    ifFalse: [aMsg := aStringOrBlock].
		i := aMsg size.
		[i > 0 and: [(aMsg at: i) isSeparator]] whileTrue: [i := i - 1].
		briefMsg := aMsg copyFrom: 1 to: i.
		stream
		    cr;
		    nextPutAll: briefMsg;
		    flush]
	    level: aLevel
    ]

    printTrace: aString [
	<category: 'debugging'>
	| stream |
	(stream := self debugStream) == nil ifTrue: [^self].
	stream
	    cr;
	    cr;
	    nextPutAll: ' **** ' asString.
	Date today printOn: stream.
	stream nextPutAll: ' '.
	Time now printOn: stream.
	stream
	    nextPutAll: ' ' , aString , ' ****';
	    flush
    ]

    traceOff [
	<category: 'debugging'>
	self printTrace: 'Stop Trace'.
	self trace: false
    ]

    traceOn [
	<category: 'debugging'>
	self trace: true.
	self printTrace: 'Start Trace'
    ]

    addDebugCategory: symbol [
	<category: 'private'>
	self debugCategories add: symbol
    ]

    removeDebugCategory: symbol [
	<category: 'private'>
	self debugCategories remove: symbol
    ]

    reset [
	<category: 'private'>
	self resetDebugClasses.
	self resetDebugCategories
    ]

    resetDebugCategories [
	<category: 'private'>
	debugCategories := nil
    ]

    resetDebugClasses [
	<category: 'private'>
	debugClasses := nil
    ]

    addToDebug: aClass [
	<category: 'registration'>
	self debugClasses add: aClass
    ]
]



Object subclass: NetClient [
    | hostName portNumber user reporter clientPI connectionStream isSSL |
    
    <import: Sockets>
    <category: 'NetClients-Framework'>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>

    NetClient class >> defaultPortNumber [
	<category: 'constants'>
	self subclassResponsibility
    ]

    NetClient class >> defaultSSLPortNumber [
	<category: 'constants'>
	self subclassResponsibility
    ]

    NetClient class >> connectToHost: aHostname [
	<category: 'instance creation'>
	^self new hostName: aHostname; connect
    ]

    NetClient class >> connectToHost: aHostname port: aPort [
	<category: 'instance creation'>
	^self new hostName: aHostname; portNumber: aPort; connect
    ]

    NetClient class >> loginToHost: aHostName asUser: userString withPassword: passwdString [
	<category: 'instance creation'>
	^self 
	    loginToHost: aHostName
	    port: nil
	    asUser: userString
	    withPassword: passwdString
    ]

    NetClient class >> loginToHost: aHostName port: aNumber asUser: userString withPassword: passwdString [
	<category: 'instance creation'>
	^self new 
	    loginToHost: aHostName
	    port: aNumber
	    asUser: userString
	    withPassword: passwdString
    ]

    NetClient class >> loginUser: userString withPassword: passwdString [
	<category: 'instance creation'>
	^self loginUser: userString withPassword: passwdString
    ]

    user [
	<category: 'accessing'>
	^user
    ]

    user: aNetUser [
	<category: 'accessing'>
	user := aNetUser
    ]

    username [
	<category: 'accessing'>
	^user username
    ]

    password [
	<category: 'accessing'>
	^self user password
    ]

    username: usernameString password: passwdString [
	<category: 'accessing'>
	user := NetUser username: usernameString password: passwdString
    ]

    clientPI [
	<category: 'accessing'>
	clientPI isNil ifTrue: [
            self clientPI: (self protocolInterpreter client: self)].
	^clientPI
    ]

    clientPI: aProtocolInterpreter [
	<category: 'accessing'>
	clientPI := aProtocolInterpreter
    ]

    hostName [
	<category: 'accessing'>
	^hostName
    ]

    hostName: aString [
	<category: 'accessing'>
	hostName := aString
    ]

    isSSL [
	<category: 'accessing'>
	isSSL isNil ifTrue: [isSSL := false].
	^isSSL
    ]

    isSSL: aBoolean [
	<category: 'accessing'>
	isSSL := aBoolean
    ]

    defaultPortNumber [
	<category: 'accessing'>
	^self isSSL
            ifFalse: [self class defaultPortNumber]
	    ifTrue: [self class defaultSSLPortNumber]
    ]

    portNumber [
	<category: 'accessing'>
	portNumber isNil ifTrue: [^self defaultPortNumber].
	portNumber = 0 ifTrue: [^self defaultPortNumber].
	^portNumber
    ]

    portNumber: aNumber [
	<category: 'accessing'>
	portNumber := aNumber
    ]

    reporter [
	<category: 'accessing'>
	reporter isNil ifTrue: [reporter := Reporter new].
	^reporter
    ]

    reporter: aReporter [
	<category: 'accessing'>
	reporter := aReporter
    ]

    protocolInterpreter [
	<category: 'abstract'>
	self subclassResponsibility
    ]

    binary [
	<category: 'connection'>
	connectionStream class == CrLfStream 
	    ifTrue: [connectionStream := connectionStream stream]
    ]

    isBinary [
	<category: 'connection'>
	^connectionStream class ~~ CrLfStream
    ]

    text [
	<category: 'connection'>
	self binary.
	self clientPI lineEndConvention = LineEndCRLF 
	    ifTrue: [connectionStream := CrLfStream on: connectionStream]
    ]

    close [
	<category: 'connection'>
	^self logout
    ]

    closeConnection [
	<category: 'connection'>
	self closed 
	    ifFalse: 
		[connectionStream close.
		connectionStream := nil].
	self liveAcrossSnapshot ifTrue: [ObjectMemory removeDependent: self]
    ]

    closed [
	<category: 'connection'>
	^connectionStream == nil
    ]

    connect [
	<category: 'connection'>
	| connection messageText |
	[connection := self createSocket]
		    on: Error
		    do: 
			[:ex | 
			ex.
			messageText := ex messageText.
			ex return: nil].
	connection isNil ifTrue: [^self clientPI connectionFailedError: messageText].
	self connectionStream: connection.
	self clientPI connected.
    ]

    connectIfClosed [
	<category: 'connection'>
	self closed ifTrue: [self connect]
    ]

    createSSLWrapper [
	<category: 'connection'>
	| connection messageText |
        (self hostName anySatisfy: [ :ch |
            '''"\${}()*?' includes: ch ])
                 ifTrue: [ self error: 'invalid host name' ].
        (self portNumber isInteger not and: [self anySatisfy: [ :ch |
            '''"\${}()*?' includes: ch ]])
                 ifTrue: [ self error: 'invalid port name' ].
        Directory libexec isNil
            ifTrue: [ self error: 'cannot find gnutls-wrapper' ].
	^FileDescriptor
            popen: '%1 %2 %3' % { Directory libexec / 'gnutls-wrapper'.
                self hostName. self portNumber }
            dir: 'r+'
    ]

    createSocket [
	<category: 'connection'>
	| connection messageText |
        self isSSL ifTrue: [ ^self createSSLWrapper ].
	^Socket remote: self hostName port: self portNumber
    ]

    connectionStream [
	<category: 'connection'>
	^connectionStream
    ]

    connectionStream: aSocket [
	<category: 'connection'>
	connectionStream := aSocket.
	self text.
	self liveAcrossSnapshot ifTrue: [ObjectMemory addDependent: self]
    ]

    liveAcrossSnapshot [
	<category: 'private-attributes'>
	^false
    ]

    login [
	<category: 'connection'>
	
    ]

    logout [
	<category: 'connection'>
	
    ]

    loginToHost: aHostName asUser: userString withPassword: passwdString [
	<category: 'connection'>
	^self 
	    loginToHost: aHostName
	    port: nil
	    asUser: userString
	    withPassword: passwdString
    ]

    loginToHost: aHostName port: aNumber asUser: userString withPassword: passwdString [
	<category: 'connection'>
	| resp |
	hostName := aHostName.
	portNumber := aNumber.
	self username: userString password: passwdString.
	self connect.
	(resp := self login) completedSuccessfully ifFalse: [^nil]
    ]

    reconnect [
	<category: 'connection'>
	self closeConnection.
	self connect
    ]
]



Object subclass: NetProtocolInterpreter [
    | client |
    
    <import: TCP>
    <category: 'NetClients-Framework'>
    <comment: nil>

    NetProtocolInterpreter class >> base64Encode: aString [
	| i j outSize c1 c2 c3 out b64string chars |
	chars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.
	outSize := aString size // 3 * 4.
	(aString size \\ 3) = 0 ifFalse: [ outSize := outSize + 4 ].
	b64string := String new: outSize.

	i := 1.
	1 to: outSize by: 4 do: [ :j |
	    c1 := aString valueAt: i ifAbsent: [0].
	    c2 := aString valueAt: i+1 ifAbsent: [0].
	    c3 := aString valueAt: i+2 ifAbsent: [0].

            out := c1 bitShift: -2.
            b64string at: j put: (chars at: out + 1).

            out := ((c1 bitAnd: 3) bitShift: 4) bitOr: (c2 bitShift: -4).
            b64string at: j+1 put: (chars at: out + 1).

            out := ((c2 bitAnd: 15) bitShift: 2) bitOr: (c3 bitShift: -6).
            b64string at: j+2 put: (chars at: out + 1).

            out := c3 bitAnd: 63.
            b64string at: j+3 put: (chars at: out + 1).

            i := i + 3.
        ].

	b64string
	    replaceFrom: outSize - (i - aString size) + 2
	    to: outSize withObject: $=.

       ^b64string
    ]

    NetProtocolInterpreter class >> log: aString level: aLevel [
	<category: 'debugging'>
	NetEnvironment default log: aString level: aLevel
    ]

    NetProtocolInterpreter class >> registerToDebug [
	<category: 'debugging'>
	NetEnvironment default addToDebug: self
    ]

    NetProtocolInterpreter class >> client: aNetClient [
	<category: 'instance creation'>
	^self new client: aNetClient
    ]

    NetProtocolInterpreter class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    NetProtocolInterpreter class >> defaultResponseClass [
	<category: 'private-attributes'>
	^NetResponse
    ]

    NetProtocolInterpreter class >> base64Encode: aString [
	| chars i j n t1 t2 t3 ch aStringSize b64Size b64String |
	chars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.

	aStringSize := aString size.
	b64Size := aStringSize // 3 * 4.
	(aStringSize \\ 3 ~= 0) ifTrue: [b64Size := b64Size + 4].
	b64String := String new: b64Size withAll: $=.

	i := j := 1.
	[i <= aStringSize] whileTrue: [
	    t1 := (aString at: i ifAbsent: [Character nul]) asInteger.
	    t2 := (aString at: i + 1 ifAbsent: [Character nul]) asInteger.
	    t3 := (aString at: i + 2 ifAbsent: [Character nul]) asInteger.
	    n := 3 min: aStringSize - i + 1.

	    ch := t1 bitShift: -2.
	    b64String at: j put: (chars at: ch + 1).

	    ch := ((t1 bitAnd: 3) bitShift: 4) bitOr: (t2 bitShift: -4).
	    b64String at: j + 1 put: (chars at: ch + 1).

	    n >= 2 ifTrue: [
		ch := ((t2 bitAnd: 15) bitShift: 2) bitOr: (t2 bitShift: -6).
		b64String at: j + 2 put: (chars at: ch + 1).
	    ].

	    n >= 3 ifTrue: [
		ch := t3 bitAnd: 63.
		b64String at: j + 3 put: (chars at: ch + 1).
	    ].

	    i := i + 3.
	    j := j + 4.
	].

	^b64String
    ]

    client [
	<category: 'accessing'>
	^client
    ]

    reporter [
	<category: 'accessing'>
	^self client reporter
    ]

    receiveMessageUntilPeriod [
	"Receive and answer a message until period line."

	<category: 'accessing'>
	| write |
	write := WriteStream on: (String new: 4 * 1024).
	self receiveMessageUntilPeriodInto: write.
	^write contents
    ]

    receiveMessageUntilPeriodInto: aStream [
	"Receive a message until period line into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	MIME.MimeEntity new parseSimpleBodyFrom: self onto: aStream
    ]

    sendMessageWithPeriod: aStream [
	"Send aStream as a message with period."

	<category: 'accessing'>
	self connectIfClosed.
	(PrependDotStream to: self)
	    nextPutAll: aStream;
	    flush
    ]

    skipMessageUntilPeriod [
	"Skip a message until period line."

	<category: 'accessing'>
	self connectIfClosed.
	MIME.MimeEntity new skipSimpleBodyFrom: self
    ]

    binary [
	<category: 'connection'>
	client binary
    ]

    isBinary [
	<category: 'connection'>
	^client isBinary
    ]

    text [
	<category: 'connection'>
	client text
    ]

    close [
	<category: 'connection'>
        client closeConnection
    ]

    closed [
	<category: 'connection'>
	^client closed
    ]

    connectionStream [
	<category: 'connection'>
	^client connectionStream
    ]

    connectionStream: aSocket [
	<category: 'connection'>
	client connectionStream: aSocket
    ]

    connected [
	<category: 'callbacks'>
    ]

    connect [
	<category: 'connection'>
	client connect
    ]

    connectIfClosed [
	<category: 'connection'>
	client connectIfClosed
    ]

    reconnect [
	<category: 'connection'>
	client reconnect
    ]

    decode: aString [
	<category: 'encoding'>
	^aString
    ]

    encode: aString [
	<category: 'encoding'>
	^aString
    ]

    client: aNetClient [
	<category: 'initialize-release'>
	client := aNetClient
    ]

    initialize [
	<category: 'initialize-release'>
	
    ]

    release [
	<category: 'initialize-release'>
	self close
    ]

    checkResponse [
	<category: 'private'>
	self checkResponse: self getResponse
    ]

    checkResponse: response [
	<category: 'private'>
	self checkResponse: response
	    ifError: [self errorResponse: response]
    ]

    checkResponse: reponse ifError: errorBlock [
	<category: 'private'>
	
    ]

    connectionClosedError: messageText [
	<category: 'private'>
	^(ConnectionClosedError new)
	    tag: messageText;
	    signal: 'Connection closed: ' , messageText
    ]

    connectionFailedError: messageText [
	<category: 'private'>
	^(ConnectionFailedError new)
	    tag: messageText;
	    signal: 'Connection failed: ' , messageText
    ]

    getResponse [
	<category: 'private'>
	^self class defaultResponseClass fromClient: self
    ]

    loginIncorrectError: messageText [
	<category: 'private'>
	^(LoginIncorrectError new)
	    tag: messageText;
	    signal: 'Login incorrect: ' , messageText
    ]

    errorResponse: aResponse [
	<category: 'private'>
	^(ProtocolError new)
	    response: aResponse;
	    signal
    ]

    unexpectedResponse: aResponse [
	<category: 'private'>
	^(UnexpectedResponseError new)
	    response: aResponse;
	    signal
    ]

    lineEndConvention [
	<category: 'private-attributes'>
	^LineEndCRLF
    ]

    atEnd [
	<category: 'stream accessing'>
	^self connectionStream atEnd
    ]

    contents [
	<category: 'stream accessing'>
	^self decode: self connectionStream contents
    ]

    cr [
	<category: 'stream accessing'>
	| conv |
	conv := self lineEndConvention.
	(conv = LineEndCR or: [conv = LineEndTransparent]) 
	    ifTrue: [^self connectionStream nextPut: Character cr].
	conv = LineEndLF ifTrue: [^self connectionStream nextPut: Character nl].
	conv = LineEndCRLF 
	    ifTrue: 
		[^self connectionStream
		    nextPut: Character cr;
		    nextPut: Character nl].
	self error: 'Undefined line-end convention'
    ]

    flush [
	<category: 'stream accessing'>
	self connectionStream flush
    ]

    next [
	<category: 'stream accessing'>
	^self connectionStream next
    ]

    next: anInteger [
	<category: 'stream accessing'>
	^self decode: (self connectionStream next: anInteger)
    ]

    nextAvailable: anInteger [
	<category: 'stream accessing'>
	^self decode: (self connectionStream nextAvailable: anInteger)
    ]

    nextLine [
	<category: 'stream accessing'>
	| write byte |
	write := WriteStream on: (String new: 128).
	[self connectionStream atEnd] whileFalse: 
		[byte := self connectionStream next.
		byte == Character cr 
		    ifTrue: 
			[self connectionStream peekFor: Character nl.
			^self decode: write contents].
		byte == Character nl ifTrue: [^self decode: write contents].
		write nextPut: byte].
	^self decode: write contents
    ]

    nextPut: aCharacter [
	<category: 'stream accessing'>
	self connectionStream nextPutAll: (self encode: (String with: aCharacter))
    ]

    nextPutAll: aString [
	<category: 'stream accessing'>
	aString isEmpty ifTrue: [^self].
	self connectionStream nextPutAll: (self encode: aString)
    ]

    nl [
	<category: 'stream accessing'>
	| conv |
	conv := self lineEndConvention.
	conv = LineEndCR ifTrue: [^self connectionStream nextPut: Character cr].
	(conv = LineEndLF or: [conv = LineEndTransparent]) 
	    ifTrue: [^self connectionStream nextPut: Character nl].
	conv = LineEndCRLF 
	    ifTrue: 
		[^self connectionStream
		    nextPut: Character cr;
		    nextPut: Character nl].
	self error: 'Undefined line-end convention'
    ]

    species [
	<category: 'stream accessing'>
	^self connectionStream species
    ]

    upTo: aCharacter [
	<category: 'stream accessing'>
	| byte |
	aCharacter = Character cr ifTrue: [^self nextLine].
	byte := self encode: (String with: aCharacter).
	byte size = 1 
	    ifTrue: [^self decode: (self connectionStream upTo: byte)]
	    ifFalse: [^self decode: (self connectionStream upToAll: byte)]
    ]

    update: aSymbol [
	"Dependents of ObjectMemory are sent update:
	 #returnFromSnapshot when a snapshot is started."

	<category: 'updating'>
	self liveAcrossSnapshot 
	    ifTrue: 
		[aSymbol == #returnFromSnapshot ifTrue: [self close]
		"(aSymbol == #aboutToSnapshot or: [aSymbol == #aboutToQuit])
		 ifTrue: [self close]."].
	super update: aSymbol
    ]
]



Object subclass: NetResponse [
    | status statusMessage |
    
    <category: 'NetClients-Framework'>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>

    NetResponse class >> fromClient: aClient [
	<category: 'instance creation'>
	| response |
	response := self new.
	response parseResponse: aClient.
	^response
    ]

    status [
	<category: 'accessing'>
	^status
    ]

    status: anInteger [
	<category: 'accessing'>
	status := anInteger
    ]

    statusArray [
	<category: 'accessing'>
	| n array |
	status == nil ifTrue: [n := 0] ifFalse: [n := status].
	array := Array new: 3.
	array at: 1 put: n // 100.
	n := n - (n // 100 * 100).
	array at: 2 put: n // 10.
	n := n - (n // 10 * 10).
	array at: 3 put: n.
	^array
    ]

    statusMessage [
	<category: 'accessing'>
	^statusMessage
    ]

    statusMessage: aString [
	<category: 'accessing'>
	statusMessage := aString
    ]

    parseResponse: aClient [
	<category: 'parsing'>
	self parseStatusLine: aClient
    ]

    printOn: aStream [
	<category: 'printing'>
	self printStatusOn: aStream
    ]

    printStatusOn: aStream [
	<category: 'printing'>
	status notNil 
	    ifTrue: 
		[aStream
		    print: status;
		    space].
	statusMessage notNil ifTrue: [aStream nextPutAll: statusMessage]
    ]

    parseStatusLine: aClient [
	<category: 'private'>
	| stream |
	statusMessage := nil.
	
	[stream := aClient nextLine readStream.
	status := Integer readFrom: stream.
	stream next = $-] 
		whileTrue: 
		    [statusMessage == nil 
			ifTrue: [statusMessage := stream upToEnd]
			ifFalse: 
			    [statusMessage := statusMessage , (String with: Character cr) 
					, stream upToEnd]].
	stream skipSeparators.
	statusMessage == nil 
	    ifTrue: [statusMessage := stream upToEnd]
	    ifFalse: 
		[statusMessage := statusMessage , (String with: Character cr) 
			    , stream upToEnd]
    ]
]



Object subclass: Reporter [
    | totalByte readByte startTime currentTime |
    
    <category: 'NetClients-URIResolver'>
    <comment: nil>

    readByte [
	<category: 'accessing'>
	^readByte
    ]

    readByte: anInteger [
	<category: 'accessing'>
	readByte := readByte + anInteger.
	currentTime := Time millisecondClockValue.
    ]

    endTransfer [
	<category: 'api'>
	^self
    ]

    startTransfer [
	<category: 'api'>
	readByte := 0.
	startTime := currentTime := Time millisecondClockValue.
	^self
    ]

    statusString: aString [
	<category: 'api'>
	^self
    ]

    totalByte [
	<category: 'api'>
	^totalByte
    ]

    totalByte: aNumber [
	<category: 'api'>
	totalByte := aNumber
    ]

    transferSpeed [
	<category: 'api'>
	currentTime = startTime ifTrue: [^nil].
        ^readByte / ((currentTime - startTime) / 1000)
    ]
]



Reporter subclass: PluggableReporter [
    | statusBlock |
    
    <category: 'NetClients-Framework'>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>

    PluggableReporter class >> statusBlock: aBlock [
	<category: 'instance creation'>
	^self new statusBlock: aBlock
    ]

    endTransfer [
	<category: 'accessing'>
	self statusString: 'Transferring: Done.'
    ]

    readByte: anInteger [
	<category: 'accessing'>
        super readByte: anInteger.
	self statusString: self progressStatusString
    ]

    startTransfer [
	<category: 'accessing'>
        super startTransfer.
	self statusString: 'Transferring: Start.'
    ]

    statusString: statusString [
	<category: 'accessing'>
	statusBlock isNil ifTrue: [^self].
	statusBlock value: statusString
    ]

    progressStatusString [
	<category: 'private'>
	| stream speed |
	stream := WriteStream on: (String new: 128).
	stream print: readByte.
	totalByte == nil 
	    ifFalse: 
		[stream
		    nextPut: $/;
		    print: totalByte].
	stream nextPutAll: ' bytes'.
        speed := self transferSpeed.
	speed == nil
	    ifFalse: 
		[stream nextPutAll: ' ('.
		stream display: (self transferSpeed / 1024 asScaledDecimal: 2).
		stream nextPutAll: ' Kbytes/sec)'].
	^stream contents
    ]

    statusBlock: aBlock [
	<category: 'private'>
	statusBlock := aBlock
    ]
]



Stream subclass: RemoveDotStream [
    | stream ch atStart |
    
    <category: 'NetClients-Framework'>
    <comment: nil>

    RemoveDotStream class >> on: aStream [
	<category: 'instance creation'>
	^self new initialize: aStream
    ]

    atEnd [
	<category: 'input'>
	ch isNil ifFalse: [^false].
	stream isNil ifTrue: [^true].
	stream atEnd 
	    ifTrue: 
		[stream := nil.
		^true].
	ch := stream next.
	(atStart and: [ch == $.]) 
	    ifFalse: 
		[atStart := ch == Character cr or: [ch == Character nl].
		^false].
	atStart := false.

	"Found dot at start of line, discard it"
	stream atEnd 
	    ifTrue: 
		[stream := ch := nil.
		^true].
	ch := stream next.

	"Found lonely dot, we are at end of stream"
	(ch == Character cr or: [ch == Character nl]) 
	    ifTrue: 
		[ch == Character cr ifTrue: [stream next].
		stream := ch := nil.
		^true].
	^false
    ]

    next [
	<category: 'input'>
	| answer |
	self atEnd ifTrue: [self error: 'end of stream reached'].
	answer := ch.
	ch := nil.
	^answer
    ]

    peek [
	<category: 'input'>
	self atEnd ifTrue: [^nil].
	^ch
    ]

    peekFor: aCharacter [
	<category: 'input'>
	self atEnd ifTrue: [^false].
	ch == aCharacter 
	    ifTrue: 
		[self next.
		^true].
	^false
    ]

    initialize: aStream [
	<category: 'private'>
	stream := aStream.
	atStart := true.
	self atEnd
    ]

    species [
	<category: 'private'>
	^stream species
    ]
]



Stream subclass: PrependDotStream [
    | stream atStart |
    
    <category: 'NetClients-Framework'>
    <comment: 'A PrependDotStream removes a dot to each line starting with a dot, and
ends when its input has a lonely dot.'>

    PrependDotStream class >> to: aStream [
	<category: 'instance creation'>
	^self new initialize: aStream
    ]

    flush [
	<category: 'output'>
	atStart ifFalse: [self nl].
	stream
	    nextPut: $.;
	    nl
    ]

    nextPut: aChar [
	<category: 'output'>
	(atStart and: [aChar == $.]) ifTrue: [stream nextPut: aChar].
	stream nextPut: aChar.
	atStart := aChar == Character nl
    ]

    initialize: aStream [
	<category: 'private'>
	stream := aStream.
	atStart := true
    ]

    species [
	<category: 'private'>
	^stream species
    ]
]



Stream subclass: CrLfStream [
    | stream readStatus eatLf |
    
    <category: 'NetClients-Framework'>
    <comment: 'A CrLfStream acts as a pipe which transforms incoming data into LF-separated
lines, and outgoing data into CRLF-separated lines.'>

    Lf := nil.
    Cr := nil.

    CrLfStream class >> on: aStream [
	<category: 'instance creation'>
	Cr := Character cr.
	Lf := Character nl.
	^self new on: aStream
    ]

    on: aStream [
	<category: 'initializing'>
	stream := aStream.
	eatLf := false.
	readStatus := #none
    ]

    atEnd [
	<category: 'stream'>
	^stream atEnd and: [readStatus == #none]
    ]

    close [
	<category: 'stream'>
	stream close
    ]

    flush [
	<category: 'stream'>
	stream flush
    ]

    next [
	<category: 'stream'>
	| result |
	readStatus == #none 
	    ifFalse: 
		[readStatus == Cr ifTrue: [stream peekFor: Lf].
		readStatus := #none.
		^Lf].
	result := stream next.
	^(result == Cr or: [result == Lf]) 
	    ifTrue: 
		[readStatus := result.
		Cr]
	    ifFalse: [result]
    ]

    nextLine [
	<category: 'stream'>
	| line |
	line := self upTo: Cr.
	self next.	"Eat line feed"
	^line
    ]

    nextPut: aCharacter [
	<category: 'stream'>
	eatLf 
	    ifTrue: 
		[eatLf := false.
		aCharacter == Lf ifTrue: [^self]]
	    ifFalse: 
		[aCharacter == Lf 
		    ifTrue: 
			[stream
			    nextPut: Cr;
			    nextPut: Lf;
			    flush.
			^self]].
	stream nextPut: aCharacter.
	aCharacter == Cr 
	    ifTrue: 
		[stream
		    nextPut: Lf;
		    flush.
		eatLf := true]
    ]

    peek [
	<category: 'stream'>
	| result |
	readStatus == #none 
	    ifFalse: 
		[readStatus == Cr ifTrue: [stream peekFor: Lf].
		readStatus := Lf.	"peek for LF just once"
		^Lf].
	result := stream peek.
	^result == Lf ifTrue: [Cr] ifFalse: [result]
    ]

    peekFor: aCharacter [
	<category: 'stream'>
	| result success |
	readStatus == #none 
	    ifFalse: 
		[readStatus == Cr ifTrue: [stream peekFor: Lf].
		success := aCharacter == Lf.
		readStatus := success ifTrue: [#none] ifFalse: [Lf].	"peek for LF just once"
		^success].
	result := stream peek.
	(result == Cr or: [result == Lf]) 
	    ifTrue: 
		[success := aCharacter == Cr.
		success ifTrue: [readStatus := stream next].
		^success].
	success := aCharacter == result.
	success ifTrue: [stream next].
	^success
    ]

    species [
	<category: 'stream'>
	^stream species
    ]

    stream [
	<category: 'stream'>
	^stream
    ]
]



Error subclass: NetClientError [
    
    <category: 'NetClients-Framework'>
    <comment: nil>
]



NetClientError subclass: ConnectionFailedError [
    
    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
        <category: 'exception handling'>

        ^'The connection attempt failed.'
    ]
]



NetClientError subclass: ConnectionClosedError [
    
    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
        <category: 'exception handling'>

        ^'The server closed the connection.'
    ]
]



Notification subclass: ProtocolNotification [
    
    | response |

    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
	<category: 'exception handling'>
	^'Protocol Notification'
    ]

    response [
	<category: 'exception handling'>
	^response
    ]

    response: aResponse [
	<category: 'exception handling'>
	response := aResponse.
        self messageText: '%1: %2' % {self description. response statusMessage}
    ]

    isResumable [
	<category: 'exception handling'>
	^true
    ]
]



NetClientError subclass: ProtocolError [
    
    | response |

    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
	<category: 'exception handling'>
	^'Protocol Error'
    ]

    response [
	<category: 'exception handling'>
	^response
    ]

    response: aResponse [
	<category: 'exception handling'>
	response := aResponse.
        self messageText: '%1: %2' % {self description. response statusMessage}
    ]

    isResumable [
	<category: 'exception handling'>
	^true
    ]
]



NetClientError subclass: UnexpectedResponseError [
    
    | response |

    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
	<category: 'exception handling'>
	^'Unexpected Response'
    ]

    isResumable [
	<category: 'exception handling'>
	^false
    ]
]



NetClientError subclass: LoginIncorrectError [
    
    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
        <category: 'exception handling'>

        ^'The server rejected your login attempt.'
    ]
]


NetClientError subclass: WrongStateError [
    <category: 'NetClients-Framework'>
    <comment: nil>

    description [
        <category: 'exception handling'>

        ^'This command cannot be executed in the client''s current state.'
    ]
]

PK
     �Mh@��2A�D  �D    NNTP.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   NNTP protocol support
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, and in the public domain
| Copyright (c) 2002 Free Software Foundation, Inc.
| Adapted by Paolo Bonzini.
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



Namespace current: NetClients.NNTP [

NetClient subclass: NNTPClient [
    | currentGroup |
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-NNTP'>

    NNTPClient class >> defaultPortNumber [
	<category: 'constants'>
	^119
    ]

    NNTPClient class >> exampleHelpOn: host [
	"self exampleHelpOn: 'localhost'."

	<category: 'examples'>
	| client answer |
	client := NNTPClient connectToHost: host.
	
	[answer := client help.
	client logout] ensure: [client close].
	^answer
    ]

    NNTPClient class >> exampleOn: host group: groupString [
	"self exampleOn: 'newshost' group: 'comp.lang.smalltalk'."

	<category: 'examples'>
	| subjects client |
	client := NNTPClient connectToHost: host.
	
	[| range |
	range := client activeArticlesInGroup: groupString.
	subjects := Array new: range size.
	client 
	    subjectsOf: groupString
	    from: range first
	    to: range last
	    do: [:n :subject | subjects add: subject].
	client logout] 
		ensure: [client close].
	subjects inspect
    ]

    activeArticlesInGroup: groupString [
	"Answer an active article range in group."

	<category: 'accessing'>
	| response read from to |
	self connectIfClosed.
	response := self clientPI nntpGroup: groupString.
	currentGroup := groupString.
	response status = 211 ifFalse: [^0 to: 0].
	"A response is as follows:"
	"211 n f l s (n = estimated number of articles in group,
	 f = first article number in the group,
	 l = last article number in the group,
	 s = name of the group.)"
	read := response statusMessage readStream.
	read skipSeparators.
	Integer readFrom: read.
	read skipSeparators.
	from := Integer readFrom: read.
	read skipSeparators.
	to := Integer readFrom: read.
	^from to: to
    ]

    activeNewsgroupsDo: aBlock [
	"Answer a list of active newsgroups."

	<category: 'accessing'>
	| line |
	self reconnect.
	self clientPI nntpList.
	[self atEnd or: 
		[line := self nextLine.
		line = '.']] 
	    whileFalse: [aBlock value: line]
    ]

    activeNewsgroups [
	"Answer a list of active newsgroups."

	<category: 'accessing'>
	| stream |
	stream := WriteStream on: Array new.
	self activeNewsgroupsDo: [:each | stream nextPut: each].
	^stream contents
    ]

    articleAt: idOrNumberString into: aStream [
	"Read an article at idOrNumberString into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpArticle: idOrNumberString.
	self receiveMessageUntilPeriodInto: aStream
    ]

    articleAtNumber: anInteger group: groupString into: aStream [
	"Read an article at anInteger of a newsgroup named groupString into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	self articleAt: anInteger printString into: aStream
    ]

    articleMessageAt: idOrNumberString [
	"Answer a message of an article at idOrNumberString."

	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpArticle: idOrNumberString.
	^MIME.MimeEntity readFrom: self
    ]

    articleMessageAtNumber: anInteger group: groupString [
	"Answer a message of an article at anInteger of a newsgroup named groupString."

	<category: 'accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	^self articleMessageAt: anInteger printString
    ]

    bodyAt: idOrNumberString into: aStream [
	"Read a body of an article at idOrNumberString into aStream."

	<category: 'accessing'>
	| response |
	self connectIfClosed.
	self clientPI nntpBody: idOrNumberString.
	self receiveMessageUntilPeriodInto: aStream
    ]

    bodyAtNumber: anInteger group: groupString into: aStream [
	"Read a body of an article at anInteger of a newsgroup named groupString into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	^self bodyAt: anInteger printString into: aStream
    ]

    connected [
	<category: 'accessing'>
	currentGroup := nil.
    ]

    group: groupString [
	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpGroup: groupString.
	currentGroup := groupString
    ]

    headAt: idOrNumberString into: aStream [
	"Read a header of an article at idOrNumberString into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpHead: idOrNumberString.
	self receiveMessageUntilPeriodInto: aStream
    ]

    headAtNumber: anInteger group: groupString into: aStream [
	"Read a header of an article at anInteger of a newsgroup named groupString into aStream."

	<category: 'accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	^self headAt: anInteger printString into: aStream
    ]

    help [
	"Answer a help text."

	<category: 'accessing'>
	| write |
	write := WriteStream on: (String new: 1024).
	self connectIfClosed.
	self clientPI nntpHelp.
	self receiveMessageUntilPeriodInto: write.
	^write contents
    ]

    postArticleMessage: aMessage [
	"Post a news article message."

	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpPost: [aMessage printMessageOnClient: self]
    ]

    postArticleStream: aStream [
	"Post a news article in aStream."

	<category: 'accessing'>
	self connectIfClosed.
	self clientPI nntpPost: [self sendMessageWithPeriod: aStream]
    ]

    logout [
	<category: 'accessing'>
	self closed ifTrue: [^self].
	self clientPI nntpQuit.
	self close
    ]

    protocolInterpreter [
	<category: 'private'>
	^NNTPProtocolInterpreter
    ]

    headersAt: keyString group: groupString from: from to: to do: aBlock [
	"Answer a list of article number and value of header field in a range (from to)."

	<category: 'extended accessing'>
	| line |
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	self clientPI 
	    nntpXhdr: keyString
	    from: from
	    to: to.
	[self atEnd or: 
		[line := self nextLine.
		line = '.']] whileFalse: 
		[| read number string |
		read := line readStream.
		read skipSeparators.
		number := Integer readFrom: read.
		read skipSeparators.
		string := read upToEnd.
		aBlock value: number value: string]
    ]

    headersAt: keyString group: groupString from: from to: to into: aStream [
	"Answer a list of article number and value of header field in a range (from to)."

	<category: 'extended accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	self clientPI 
	    nntpXhdr: keyString
	    from: from
	    to: to.
	self receiveMessageUntilPeriodInto: aStream
    ]

    messageIdsOf: groupString from: from to: to do: aBlock [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'MESSAGE-ID'
	    group: groupString
	    from: from
	    to: to
	    do: aBlock
    ]

    messageIdsOf: groupString from: from to: to into: aStream [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'MESSAGE-ID'
	    group: groupString
	    from: from
	    to: to
	    into: aStream
    ]

    overviewsOf: groupString from: from to: to do: aBlock [
	"Answer a list of article number and overview of header field in a range (from to)."

	<category: 'extended accessing'>
	| line |
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	self clientPI nntpXoverFrom: from to: to.
	[self atEnd or: 
		[line := self nextLine.
		line = '.']] whileFalse: 
		[| read number string |
		read := line readStream.
		read skipSeparators.
		number := Integer readFrom: read.
		read skipSeparators.
		string := read upToEnd.
		aBlock value: number value: string]
    ]

    overviewsOf: groupString from: from to: to into: aStream [
	"Answer a list of article number and overview of header field in a range (from to)."

	<category: 'extended accessing'>
	self connectIfClosed.
	groupString = currentGroup ifFalse: [self group: groupString].
	self clientPI nntpXoverFrom: from to: to.
	self receiveMessageUntilPeriodInto: aStream
    ]

    subjectsOf: groupString from: from to: to do: aBlock [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'SUBJECT'
	    group: groupString
	    from: from
	    to: to
	    do: aBlock
    ]

    subjectsOf: groupString from: from to: to into: aStream [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'SUBJECT'
	    group: groupString
	    from: from
	    to: to
	    into: aStream
    ]

    xrefsOf: groupString from: from to: to do: aBlock [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'XREF'
	    group: groupString
	    from: from
	    to: to
	    do: aBlock
    ]

    xrefsOf: groupString from: from to: to into: aStream [
	<category: 'extended accessing'>
	^self 
	    headersAt: 'XREF'
	    group: groupString
	    from: from
	    to: to
	    into: aStream
    ]

    liveAcrossSnapshot [
	<category: 'private-attributes'>
	^true
    ]
]

]



Namespace current: NetClients.NNTP [

NetProtocolInterpreter subclass: NNTPProtocolInterpreter [
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-NNTP'>

    connect [
	<category: 'connection'>
	super connect.

	"Skip first general response."
	self checkResponse: self getResponse.

	"Set mode to reader for INN."
	self
	    nextPutAll: 'MODE READER';
	    cr.
	"Ignore error"
	self checkResponse: self getResponse ifError: []
    ]

    nntpArticle: idOrNumberString [
	<category: 'nntp protocol'>
	| response |
	self
	    nextPutAll: 'ARTICLE ' , idOrNumberString;
	    cr.
	response := self getResponse.
	response status = 220 
	    ifFalse: 
		["article retrieved - head and body follows"

		^self checkResponse: response]
    ]

    nntpBody: idOrNumberString [
	<category: 'nntp protocol'>
	| response |
	self
	    nextPutAll: 'BODY ' , idOrNumberString;
	    cr.
	response := self getResponse.
	response status = 222 
	    ifFalse: 
		["article retrieved - body follows"

		^self checkResponse: response]
    ]

    nntpGroup: groupString [
	<category: 'nntp protocol'>
	| response |
	self
	    nextPutAll: 'GROUP ' , groupString;
	    cr.
	response := self getResponse.
	self checkResponse: response.
	^response
    ]

    nntpHead: idOrNumberString [
	<category: 'nntp protocol'>
	| response |
	self
	    nextPutAll: 'HEAD ' , idOrNumberString;
	    cr.
	response := self getResponse.
	response status = 221 
	    ifFalse: 
		["article retrieved - head follows"

		^self checkResponse: response]
    ]

    nntpHelp [
	<category: 'nntp protocol'>
	self
	    nextPutAll: 'HELP';
	    cr.
	self checkResponseForFollowingText: self getResponse
    ]

    nntpList [
	<category: 'nntp protocol'>
	self
	    nextPutAll: 'LIST';
	    cr.
	self checkResponseForFollowingText: self getResponse
    ]

    nntpPost: aBlock [
	<category: 'nntp protocol'>
	self
	    nextPutAll: 'POST';
	    cr.
	self checkResponse: self getResponse.
	aBlock value.
	self checkResponse: self getResponse
    ]

    nntpQuit [
	<category: 'nntp protocol'>
	self
	    nextPutAll: 'QUIT';
	    cr.
	self checkResponse: self getResponse
    ]

    nntpXhdr: keyString from: from to: to [
	"Answer a list of article number and value of header field in a range (from to)."

	<category: 'nntp protocol'>
	self
	    nextPutAll: 'XHDR ' , keyString , ' ' , from printString , '-' 
			, to printString;
	    cr.
	self checkResponseForFollowingText: self getResponse
    ]

    nntpXoverFrom: from to: to [
	"Answer a list of article number and overview of header field in a range (from to)."

	<category: 'nntp protocol'>
	self
	    nextPutAll: 'XOVER ' , from printString , '-' , to printString;
	    cr.
	self checkResponseForFollowingText: self getResponse
    ]

    checkResponse: response [
	<category: 'private'>
	| textFollows |
	textFollows := self checkResponse: response
		    ifError: [self errorResponse: response. ^self].
	textFollows ifFalse: [^self].
	self skipMessageUntilPeriod.
	self unexpectedResponse: response
    ]

    checkResponse: response ifError: errorBlock [
	"Answer text follows or not."

	<category: 'private'>
	| status |
	status := response status.

	"Timeout after 7200 seconds, closing connection"
	status = 503 ifTrue: [^self connectionClosedError: response statusMessage].

	"Informative message"
	status = 100 
	    ifTrue: 
		["help text follows"

		^true].
	(status between: 190 and: 199) 
	    ifTrue: 
		["debug output"

		^false].

	"Command ok"
	status = 200 
	    ifTrue: 
		["server ready - posting allowed"

		^false].
	status = 201 
	    ifTrue: 
		["server ready - no posting allowed"

		^false].
	status = 202 
	    ifTrue: 
		["slave status noted"

		^false].
	status = 205 
	    ifTrue: 
		["closing connection - goodbye!"

		^false].
	status = 211 
	    ifTrue: 
		["n f l s group selected"

		^false].
	"### n f l s (n = estimated number of articles in group,
	 f = first article number in the group,
	 l = last article number in the group,
	 s = name of the group.)"
	status = 215 
	    ifTrue: 
		["list of newsgroups follows"

		^true].

	"### n <a> (n = article number, <a> = message-id)"
	status = 220 
	    ifTrue: 
		["article retrieved - head and body follows"

		^true].
	status = 221 
	    ifTrue: 
		["article retrieved - head follows"

		^true].
	status = 222 
	    ifTrue: 
		["article retrieved - body follows"

		^true].
	status = 223 
	    ifTrue: 
		["article retrieved - request text separately"

		^true].
	status = 224 
	    ifTrue: 
		["data follows"

		^true].
	status = 230 
	    ifTrue: 
		["list of new articles by message-id follows"

		^true].
	status = 231 
	    ifTrue: 
		["list of new newsgroups follows"

		^true].
	status = 235 
	    ifTrue: 
		["article transferred ok"

		^false].
	status = 240 
	    ifTrue: 
		["article posted ok"

		^false].

	"Command ok so far, send the rest of it"
	status = 335 
	    ifTrue: 
		["send article to be transferred"

		^false].
	status = 340 
	    ifTrue: 
		["send article to be posted"

		^false].

	"Command was correct, but couldn't be performed for some reason"
	status = 400 
	    ifTrue: 
		["service discontinued"

		^errorBlock value].
	status = 411 
	    ifTrue: 
		["no such news group"

		^errorBlock value].
	status = 412 
	    ifTrue: 
		["no newsgroup has been selected"

		^errorBlock value].
	status = 420 
	    ifTrue: 
		["no current article has been selected"

		^errorBlock value].
	status = 421 
	    ifTrue: 
		["no next article in this group"

		^errorBlock value].
	status = 422 
	    ifTrue: 
		["no previous article in this group"

		^errorBlock value].
	status = 423 
	    ifTrue: 
		["no such article number in this group"

		^errorBlock value].
	status = 430 
	    ifTrue: 
		["no such article found"

		^errorBlock value].
	status = 435 
	    ifTrue: 
		["article not wanted - do not send it"

		^errorBlock value].
	status = 436 
	    ifTrue: 
		["transfer failed - try again later"

		^errorBlock value].
	status = 437 
	    ifTrue: 
		["article rejected - do not try again."

		^errorBlock value].
	status = 440 
	    ifTrue: 
		["posting not allowed"

		^errorBlock value].
	status = 441 
	    ifTrue: 
		["posting failed"

		^errorBlock value].

	"Command unimplemented, or incorrect, or a serious program error occurred"
	status = 500 
	    ifTrue: 
		["command not recognized"

		^errorBlock value].
	status = 501 
	    ifTrue: 
		["command syntax error"

		^errorBlock value].
	status = 502 
	    ifTrue: 
		["access restriction or permission denied"

		^errorBlock value].
	status = 503 
	    ifTrue: 
		["program fault - command not performed"

		^errorBlock value].

	"Unknown status"
	^errorBlock value
    ]

    checkResponseForFollowingText: response [
	<category: 'private'>
	| textFollows |
	textFollows := self checkResponse: response
		    ifError: [self errorResponse: response. ^self].
	textFollows ifFalse: [self unexpectedResponse: response. ^self]
    ]

    defaultPortNumber [
	<category: 'private-attributes'>
	^119
    ]

    nextPutAll: aString [
	<category: 'stream accessing'>
	| retryCount |
	aString isEmpty ifTrue: [^self].
	retryCount := 0.
	[self connectionStream nextPutAll: (self encode: aString)] on: Error
	    do: 
		[:ex | 
		(retryCount := retryCount + 1) > 1 
		    ifTrue: [ex return]
		    ifFalse: 
			[self reconnect.
			ex restart]]
    ]
]

]

PK
     �Mh@d���      NetServer.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   Generic server framework
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2005, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini
|
| This file is part of the GNU Smalltalk class library.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published by
| the Free Software Foundation; either version 2.1, or (at your option) 
| any later version.
|
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
|
| You should have received a copy of the GNU Lesser General Public License 
| along with GNU Smalltalk; see the file COPYING.LIB.  If not, write to 
| the Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA
| 02110-1301, USA.
|
 ======================================================================"



Object subclass: NetThread [
    | process socket priority |
    
    <import: Sockets>
    <category: 'Sockets-Serving framework'>
    <comment: 'A NetThread runs a process attached to a specified socket.'>

    NetThread class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    defaultPriority [
	<category: 'initialize-release'>
	^Processor userSchedulingPriority
    ]

    initialize [
	<category: 'initialize-release'>
	priority := self defaultPriority
    ]

    release [
	<category: 'initialize-release'>
	socket close.
	socket := nil.
	super release
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    print: self class;
	    nextPut: $:.
	self isRunning ifFalse: [^aStream nextPutAll: 'idle'].
	aStream print: self socket port
    ]

    createSocket [
	<category: 'private'>
	self subclassResponsibility
    ]

    startNewProcess [
	<category: 'private'>
	process := ([self run] newProcess)
		    priority: priority;
		    name: self class name , ' Process';
		    yourself.
	process resume
    ]

    isPeerAlive [
	<category: 'private'>
	^socket notNil and: [socket isPeerAlive]
    ]

    socket [
	<category: 'private'>
	^socket
    ]

    run [
	<category: 'running'>
	self subclassResponsibility
    ]

    isRunning [
	<category: 'serving'>
	^process notNil
    ]

    start [
	<category: 'serving'>
	self isRunning ifTrue: [^self].
	socket := self createSocket.
	self startNewProcess
    ]
]



NetThread subclass: NetServer [
    | port |
    
    <category: 'Sockets-Serving framework'>
    <comment: 'A NetServer keeps a socket listening on a port, and dispatches incoming
requests to NetSession objects.'>

    Servers := nil.

    NetServer class >> at: port [
	<category: 'accessing'>
	| server |
	Servers isNil ifTrue: [Servers := Dictionary new].
	^Servers at: port
	    ifAbsentPut: 
		[(self new)
		    port: port;
		    yourself]
    ]

    NetServer class >> initializeServer: port [
	<category: 'accessing'>
	| server |
	server := self at: port.
	server isRunning ifFalse: [server startOn: port].
	^server
    ]

    NetServer class >> terminateServer: port [
	<category: 'accessing'>
	Servers isNil ifTrue: [^self].
	(Servers includesKey: port) 
	    ifTrue: 
		[(Servers at: port) release.
		Servers removeKey: port]
    ]

    newSession [
	<category: 'abstract'>
	self subclassResponsibility
    ]

    respondTo: aRequest [
	<category: 'abstract'>
	self subclassResponsibility
    ]

    port [
	<category: 'accessing'>
	^port
    ]

    port: anObject [
	<category: 'accessing'>
	self stop.
	port := anObject
    ]

    priority [
	<category: 'accessing'>
	^priority
    ]

    priority: anInteger [
	<category: 'accessing'>
	priority := anInteger.
	self isRunning ifTrue: [process priority: priority]
    ]

    startOn: aPortNumber [
	<category: 'accessing'>
	self port: aPortNumber.
	self start
    ]

    createSocket [
	<category: 'private'>
	^ServerSocket port: port
    ]

    defaultPriority [
	<category: 'private'>
	^Processor lowIOPriority
    ]

    run [
	<category: 'private'>
	Processor activeProcess name: 'listen'.
	
	[socket waitForConnection.
	(self newSession)
	    server: self;
	    start] 
		repeat
    ]

    release [
	<category: 'initialize-release'>
	self stop.
	super release
    ]

    stop [
	<category: 'serving'>
	self isRunning 
	    ifTrue: 
		[process terminate.
		process := nil.
		socket close.
		socket := nil]
    ]
]



NetThread subclass: NetSession [
    | server |
    
    <category: 'Sockets-Serving framework'>
    <comment: 'NetSessions divide a session in separate requests and provide 
exception handling for those.'>

    log: request time: milliseconds [
	<category: 'abstract'>
	
    ]

    next [
	<category: 'abstract'>
	self subclassResponsibility
    ]

    server [
	<category: 'accessing'>
	^server
    ]

    server: aServer [
	<category: 'accessing'>
	server := aServer
    ]

    createSocket [
	<category: 'private'>
	^server socket accept
    ]

    run [
	<category: 'private'>
	| req time |
	Processor activeProcess name: 'connection'.
	
	[
	[req := self next.
	time := Time millisecondsToRun: 
			[self server respondTo: req.
			req release]] 
		on: Error
		do: 
		    [:ex | 
		    "Ignore errors due to bad communication lines."

		    self isPeerAlive ifFalse: [ex return].
		    ex pass].
	self log: req time: time.
	self isPeerAlive] 
		whileTrue
    ]
]

PK
     �Mh@�xI  xI    IMAPTests.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   IMAP protocol unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2000 Leslie A. Tyrrell
| Copyright (c) 2009 Free Software Foundation
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



Namespace current: NetClients.IMAP [

TestCase subclass: IMAPProtocolInterpreterTest [
    | pi |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    setUp [
	<category: 'running'>
	pi := IMAPProtocolInterpreter new.
	pi client: IMAPClient new
    ]

    testScript1 [
	<category: 'Testing'>
	self 
	    executeCompleteTestScript: 'C: abcd CAPABILITY
S: * CAPABILITY IMAP4rev1 AUTH=KERBEROS_V4
S: abcd OK CAPABILITY completed
' 
		    readStream
    ]

    testScript2 [
	<category: 'Testing'>
	| stream |
	stream := 'C: A003 APPEND saved-messages (\Seen) {309}
S: + Ready for additional command text
C: Date: Mon, 7 Feb 1994 21:52:25 -0800 (PST)
C: From: Fred Foobar <foobar@Blurdybloop.COM>
C: Subject: afternoon meeting
C: To: mooch@owatagu.siam.edu
C: Message-Id: <B27397-0100000@Blurdybloop.COM>
C: MIME-Version: 1.0
C: Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
C: 
C: Hello Joe, do you think we can meet at 3:30 tomorrow?
C: 1234567
S: A003 OK APPEND completed' 
		    readStream.
	self executeCompleteTestScript: stream
    ]

    executeCompleteTestScript: aStream [
	"Execute script respresenting complete execution of one or more commands.
	 At the end of the script all commands must have been completed, so there will be
	 no queued or outstanding commands and all returned commands will be in 'done' state"

	<category: 'utility'>
	| cmds |
	cmds := self executeTestScript: aStream.
	cmds last value.	"Wait for the last command"
	self assert: pi queuedCommands size = 0.
	self assert: pi commandsInProgress size = 0.
	cmds do: [:cmd | self assert: cmd isDone].
	^cmds
    ]

    executeTestScript: aStream [
	"Execute script is the form:
	 C: abcd CAPABILITY
	 S: * CAPABILITY IMAP4rev1 AUTH=KERBEROS_V4
	 S: abcd OK CAPABILITY completed
	 Lines starting with 'C: ' are client commands, lines starting with 'S: ' are server responses"

	<category: 'utility'>
	| cmd cmdStream respStream line |
	cmdStream := (String new: 64) writeStream.
	respStream := (String new: 64) writeStream.
	[aStream atEnd] whileFalse: 
		[cmd := aStream peek asUppercase.
		line := aStream
			    next: 3;
			    upTo: Character nl.
		cmd == $C 
		    ifTrue: 
			[cmdStream
			    nextPutAll: line;
			    nl]
		    ifFalse: 
			[respStream
			    nextPutAll: line;
			    nl]].
	pi responseStream: respStream contents readStream.
	^self sendCommandsFrom: cmdStream contents readStream
    ]

    sendCommandFrom: stream [
	<category: 'utility'>
	| cmd |
	cmd := IMAPCommand readFrom: stream.
	cmd client: pi.
	pi executeCommand: cmd.
	^cmd
    ]

    sendCommandsFrom: aStream [
	"Assumption currently is, every command occupies one line. This is because
	 IMAPComand>>readFrom reads until end of stream. So we will read command's line
	 from the stream and feed it to the command as a separate stream.
	 Answers ordered collection of commands sent"

	<category: 'utility'>
	| cmds |
	cmds := OrderedCollection new.
	pi connectionStream: (String new: 256) writeStream.
	[aStream atEnd] 
	    whileFalse: [cmds addLast: (self sendCommandFrom: aStream)].
	^cmds
    ]
]

]



Namespace current: NetClients.IMAP [

TestCase subclass: IMAPResponseTest [
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    testFetch [
	<category: 'Testing'>
	| scanner resp str |
	str := '* 12 "FETCH" (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
	scanner := IMAPScanner on: str readStream.
	resp := IMAPResponse parse: scanner.
	self assert: (resp isKindOf: IMAPDataResponseFetch).
	self assert: resp cmdName = 'FETCH'.
	self assert: resp messageNumber = '12'.
	self assert: (resp bodyFetch parts isKindOf: SequenceableCollection).
	self assert: (resp bodyFetch parts 
		    allSatisfy: [:each | each sectionSpec specName = 'HEADER'])
    ]

    testResponseHandling [
	<category: 'Testing'>
	| command str |
	command := (IMAPCommand new)
		    sequenceID: 'a_1';
		    name: 'FETCH';
		    yourself.
	command client: IMAPProtocolInterpreter new.
	[command value] fork.
	self 
	    assert: (command handle: (IMAPResponse 
			    readFrom: '* FLAGS (\Seen \Answered \Deleted)' readStream)) 
		    not.
	self 
	    assert: (command handle: (IMAPResponse readFrom: 'a_2 OK bla' readStream)) 
		    not.
	self assert: command isDone not.
	str := '* 12 "FETCH" (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
	self assert: (command handle: (IMAPResponse readFrom: str readStream)).
	self assert: (command 
		    handle: (IMAPResponse readFrom: 'a_1 OK FETCH completed' readStream)).
	self assert: command isDone.
	self assert: command completionResponse status = 'OK'.
	self assert: command promise hasValue
    ]

    testTaggedMessages [
	<category: 'Testing'>
	| scanner resp |
	scanner := IMAPScanner on: 'oasis_1 OK LOGIN completed' readStream.
	resp := IMAPResponse parse: scanner.
	self assert: (resp isKindOf: IMAPResponseTagged).
	self assert: resp tag = 'oasis_1'.
	self assert: resp status = 'OK'.
	self assert: resp text = 'LOGIN completed'
    ]

    testUnTaggedMessages [
	<category: 'Testing'>
	| scanner resp |
	scanner := IMAPScanner on: '* FLAGS (\Seen \Answered \Deleted)' readStream.
	resp := IMAPResponse parse: scanner.
	self assert: resp cmdName = 'FLAGS'.
	self assert: resp value first = #('\Seen' '\Answered' '\Deleted')
    ]
]

]



Namespace current: NetClients.IMAP [

TestCase subclass: IMAPTest [
    | client |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    login [
	"establish a socket connection to the IMAP server and log me in"

	<category: 'Running'>
	client := IMAPClient 
		    loginToHost: 'SKIPPER'
		    asUser: 'itktest'
		    withPassword: 'Cincom*062000'.
	self assert: (client isKindOf: IMAPClient)
    ]

    logout [
	<category: 'Running'>
	client logout
    ]

    testAppend [
	<category: 'Testing'>
	| message |
	self login.
	message := 'Date: Mon, 7 Feb 1994 21:52:25 -0800 (PST)
From: Fred Foobar <foobar@Blurdybloop.COM>
Subject: afternoon meeting
To: mooch@owatagu.siam.edu
Message-Id: <B27397-0100000@Blurdybloop.COM>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

Hello Joe, do you think we can meet at 3:30 tomorrow?'.
	client append: message to: 'inbox'.
	self logout
    ]

    testCreateRenameDelete [
	<category: 'Testing'>
	| comm box box1 |
	box := 'mybox'.
	box1 := 'myBoxRenamed'.
	self login.
	
	[comm := client create: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client rename: box newName: box1.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully] 
		ensure: 
		    [client delete: box1.
		    self logout]
    ]

    testExamine [
	<category: 'Testing'>
	| box comm |
	self login.
	box := 'inbox'.
	comm := client examine: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	self logout
    ]

    testList [
	<category: 'Testing'>
	"box := nil.
	 box isNil ifTrue:[ ^nil]."

	| box comm |
	self login.
	
	[box := 'news/mail/box' asString.
	comm := client create: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client list: 'news/' mailbox: 'mail/*'.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	self assert: comm responses first mbName asUppercase = box asUppercase] 
		ensure: [comm := client delete: box].
	self logout
    ]

    testNoopCapability [
	<category: 'Testing'>
	| comm |
	self login.
	comm := client noop.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client capability.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	self logout
    ]

    testSelectCheck [
	<category: 'Testing'>
	"box := nil.
	 box isNil ifTrue:[ ^nil]."

	| box comm |
	self login.
	
	[box := 'news/mail/box' asString.
	comm := client create: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client select: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client check.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully] 
		ensure: [comm := client delete: box]
    ]

    testSelectClose [
	<category: 'Testing'>
	"box := nil.
	 box isNil ifTrue:[ ^nil]."

	| box comm |
	self login.
	
	[box := 'news/mail/box' asString.
	comm := client create: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client select: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client close.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully] 
		ensure: [comm := client delete: box]
    ]

    testSelectExpunge [
	"Test case doesn't return untagged response: EXPUNGE as expected"

	<category: 'Testing'>
	"box := nil.
	 box isNil ifTrue:[ ^nil]."

	| box comm |
	self login.
	box := 'inbox' asString.
	comm := client select: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client expunge.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully
    ]

    testSelectFetch [
	<category: 'Testing'>
	| box comm |
	self login.
	box := 'inbox' asString.
	client select: box.
	comm := client fetch: '2:3 (flags internaldate uid RFC822)'.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.



	"comm := client fetch: '2,4 (flags internaldate uid BODY.PEEK[header])'."
	"client fetch: '1:4 (uid Body.Peek[Header.Fields (Subject Date From Message-Id)])'."
	"client fetch: '1:2 (flags internaldate uid RFC822)'."
	"client fetch: '1 (Body.Peek[header])'."
	"comm := client fetch: '3 (BodyStructure)'."


	"client fetch: '2 full'."
	self logout
    ]

    testSelectSearch [
	<category: 'Testing'>
	"box := nil.
	 box isNil ifTrue: [ ^box]."

	| box |
	self login.
	box := 'inbox' asString.
	client select: box.
	client search: 'undeleted unanswered from "Kogan, Tamara"'.
	self logout
    ]

    testSelectStore [
	"| box |
	 
	 self login.
	 box := 'inbox' asString.
	 self assert: ((client select: box) == true).
	 (client store: '1:1 +FLAGS (\Deleted)') inspect.
	 (client store: '1:1 -FLAGS (\Deleted)') inspect.
	 
	 self logout."

	<category: 'Testing'>
	
    ]

    testSelectUID [
	"No expected response    | box |
	 
	 self login.
	 box := 'inbox' asString.
	 self assert: ((client select: box) == true).
	 (client uid: 'fetch 1:1 FLAGS') inspect.
	 self logout."

	<category: 'Testing'>
	
    ]

    testSubscribeUnsubLSUB [
	<category: 'Testing'>
	| box comm |
	box := nil.
	box isNil ifTrue: [^nil].
	self login.
	
	[box := 'news/mail/box' asString.
	comm := client create: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client subscribe: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	comm := client lsub: 'news/' mailbox: 'mail/*'.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully.
	self assert: comm responses first mbName asUppercase = box asUppercase.
	comm := client unsubscribe: box.
	self assert: (comm isKindOf: IMAPCommand).
	self assert: comm completedSuccessfully] 
		ensure: [comm := client delete: box].
	self logout
    ]
]

]



Namespace current: NetClients.IMAP [

TestCase subclass: IMAPScannerTest [
    | parser |
    
    <comment: nil>
    <category: 'NetClients-IMAP'>

    setUp [
	<category: 'running'>
	parser := IMAPScanner new
    ]

    stream6 [
	<category: 'running'>
	| str |
	str := (String new: 512) writeStream.
	str
	    nextPutAll: '* 12 FETCH (FLAGS (\Seen) INTERNALDATE "17-Jul-1996 02:44:25 -0700"
 RFC822.SIZE 4286 ENVELOPE ("Wed, 17 Jul 1996 02:23:25 -0700 (PDT)"
 "IMAP4rev1 WG mtg summary and minutes"
 (("Terry Gray" NIL "gray" "cac.washington.edu"))
 (("Terry Gray" NIL "gray" "cac.washington.edu"))
 (("Terry Gray" NIL "gray" "cac.washington.edu"))
 ((NIL NIL "imap" "cac.washington.edu"))
 ((NIL NIL "minutes" "CNRI.Reston.VA.US")
 ("John Klensin" NIL "KLENSIN" "INFOODS.MIT.EDU")) NIL NIL
 "<B27397-0100000@cac.washington.edu>")
  BODY ("TEXT" "PLAIN" ("CHARSET" "US-ASCII") NIL NIL "7BIT" 3028 92))
';
	    nl.
	^str
    ]

    testDeepTokenize [
	<category: 'testing'>
	| tokens |
	tokens := parser
		    on: '* FLAGS (\Seen \Answered \Flagged \Deleted XDraft)' readStream;
		    deepTokenize.
	self assert: tokens 
		    = #($* 'FLAGS' #('\Seen' '\Answered' '\Flagged' '\Deleted' 'XDraft')).
	self assert: parser atEnd
    ]

    testDeepTokenize1 [
	<category: 'testing'>
	| tokens |
	tokens := parser
		    on: '(BODYSTRUCTURE (("TEXT" "PLAIN" ("charset" "iso-8859-1") NIL nil "QUOTED-PRINTABLE" 7 2 NIL NIL NIL)("APPLICATION" "OCTET-STREAM" ("name" "StoreErrorDialog.st") NiL NIL "BASE64" 4176 NIL NIL NIL) "mixed" ("boundary" "=_STAMPed_MAIL_=") NIL NIL))' 
				readStream;
		    deepTokenize.
	self assert: tokens 
		    = #(#('BODYSTRUCTURE' #(#('TEXT' 'PLAIN' #('charset' 'iso-8859-1') nil nil 'QUOTED-PRINTABLE' '7' '2' nil nil nil) #('APPLICATION' 'OCTET-STREAM' #('name' 'StoreErrorDialog.st') nil nil 'BASE64' '4176' nil nil nil) 'mixed' #('boundary' '=_STAMPed_MAIL_=') nil nil))).
	self assert: parser atEnd.
	tokens := parser
		    on: '(BODYSTRUCTURE (("TEXT" "PLAIN" ("charset" "iso-8859-1") NIL NIL "QUOTED-PRINTABLE" 7 2 NIL NIL NIL)("APPLICATION" "OCTET-STREAM" ("name" "StoreErrorDialog.st") NIL NIL "BASE64" 4176 NIL NIL NIL) "mixed" ("boundary" "=_STAMPed_MAIL_=") NIL NIL))' 
				readStream;
		    deepTokenizeAsAssociation
    ]

    testDeepTokenizeAsAssoc [
	<category: 'testing'>
	| tokens str |
	str := '* 12 "FETCH" ((a b nil) BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
	tokens := parser
		    on: str readStream;
		    deepTokenizeAsAssociation.
	self assert: tokens first = (#special -> $*).
	self assert: (tokens at: 2) = (#atom -> '12').
	self assert: (tokens at: 3) = (#quotedText -> 'FETCH').
	self assert: (tokens at: 4) 
		    = (#parenthesizedList -> (Array 
				    with: #parenthesizedList -> (Array 
						    with: #atom -> 'a'
						    with: #atom -> 'b'
						    with: #nil -> nil)
				    with: #atom -> 'BODY[HEADER]'
				    with: #literalString 
					    -> 'Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

')).
	self assert: parser atEnd
    ]

    testLiteralStrings [
	<category: 'testing'>
	| tokens str |
	str := '* 12 FETCH (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.	"Extra char for every cr -- will be different in external streams"
	tokens := parser
		    on: str readStream;
		    deepTokenize.
	self assert: tokens 
		    = #($* '12' 'FETCH' #('BODY[HEADER]' 'Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

')).
	self assert: parser atEnd
    ]

    testSourceTrail [
	<category: 'testing'>
	| str trail |
	str := '* 12 "FETCH" (BODY[HEADER] {341}
Date: Wed, 17 Jul 1996 02:23:25 -0700 (PDT)
From: Terry Gray <gray@cac.washington.edu>
Subject: IMAP4rev1 WG mtg summary and minutes
To: imap@cac.washington.edu
cc: minutes@CNRI.Reston.VA.US, John Klensin <KLENSIN@INFOODS.MIT.EDU>
Message-Id: <B27397-0100000@cac.washington.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII

)'.
	parser
	    on: str readStream;
	    sourceTrailOn;
	    deepTokenizeAsAssociation.
	trail := parser sourceTrail.
	self assert: trail = str.
	self assert: parser sourceTrail isNil.
	self assert: parser atEnd
    ]

    testTaggedResponses [
	<category: 'testing'>
	| tokens |
	tokens := parser
		    on: 'oasis_3 OK FETCH completed.' readStream;
		    tokenize.
	self assert: tokens = #('oasis_3' 'OK' 'FETCH' 'completed.').
	self assert: parser atEnd
    ]
]

]
PK
     �Mh@3��.G#  G#    POP.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   POP3 protocol support
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, and in the public domain
| Copyright (c) 2002 Free Software Foundation, Inc.
| Adapted by Paolo Bonzini.
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



Namespace current: NetClients.POP [

NetResponse subclass: POPResponse [
    
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-POP3'>

    printStatusOn: aStream [
	<category: 'printing'>
	status notNil 
	    ifTrue: 
		[status = 1 
		    ifTrue: [aStream nextPutAll: '+OK ']
		    ifFalse: [aStream nextPutAll: '-ERR ']].
	statusMessage notNil ifTrue: [aStream nextPutAll: statusMessage]
    ]

    parseStatusLine: aClient [
	"Returned string is: '+OK ok message' or '-ERR error message'"

	<category: 'private'>
	| stream |
	stream := aClient nextLine readStream.
	"status = 1 (OK), status = 0 (ERR)"
	stream next = $+ ifTrue: [status := 1] ifFalse: [status := 0].
	stream skipTo: Character space.
	stream skipSeparators.
	statusMessage := stream upToEnd
    ]
]

]



Namespace current: NetClients.POP [

NetClient subclass: POPClient [
    | loggedInUser |
    
    <import: MIME>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-POP3'>

    POPClient class >> defaultPortNumber [
	<category: 'constants'>
	^110
    ]

    POPClient class >> example2Host: host username: username password: password [
	<category: 'examples'>
	
	[self 
	    exampleHost: host
	    username: username
	    password: password] 
		on: LoginIncorrectError
		do: 
		    [:ex | 
		    'Login incorrect' printNl.
		    ex return]
    ]

    POPClient class >> exampleHost: host username: username password: password [
	<category: 'examples'>
	| client |
	client := POPClient connectToHost: host.
	
	[client username: username password: password.
	client login.
	Transcript showCr: 'New messages: ' , client newMessagesCount printString.
	Transcript showCr: 'bytes ' , client newMessagesSize printString.
	Transcript showCr: 'ids ' , client newMessagesIds printString.
	Transcript showCr: 'sizes ' , client newMessages printString.
	client getNewMailMessages: [:m | m inspect] delete: false] 
		ensure: [client close]
    ]

    login [
	<category: 'accessing'>
	loggedInUser = self user ifTrue: [^self].
	loggedInUser isNil ifFalse: [self logout].
	self connect.
	self clientPI popUser: self username.
	self clientPI popPassword: self password.
	loggedInUser := self user
    ]

    logout [
	<category: 'accessing'>
	self clientPI popQuit
    ]

    newMessagesCount [
	<category: 'accessing'>
	^self clientPI popStatus key
    ]

    newMessagesSize [
	<category: 'accessing'>
	^self clientPI popStatus value
    ]

    newMessagesIds [
	<category: 'accessing'>
	^self clientPI popList keys asSortedCollection asArray
    ]

    newMessages [
	<category: 'accessing'>
	^self clientPI popList
    ]

    sizeAt: id [
	<category: 'accessing'>
	^self clientPI popList: id
    ]

    headersAt: id [
	<category: 'accessing'>
	^self clientPI popTop: id lines: 1
    ]

    at: id [
	<category: 'accessing'>
	^self clientPI popRetrieve: id
    ]

    getNewMailHeaders: messageBlock delete: delete [
	<category: 'accessing'>
	| count entity |
	self login.
	count := self clientPI popStatus key.
	count = 0 
	    ifFalse: 
		[1 to: count
		    do: 
			[:i | 
			entity := self clientPI popTop: i lines: 1.
			messageBlock value: entity].
		delete ifTrue: [1 to: count do: [:i | self clientPI popDelete: i]]]
    ]

    getNewMailMessages: messageBlock delete: delete [
	<category: 'accessing'>
	| count entity |
	self login.
	count := self clientPI popStatus key.
	count = 0 
	    ifFalse: 
		[1 to: count
		    do: 
			[:i | 
			entity := self clientPI popRetrieve: i.
			messageBlock value: entity].
		delete ifTrue: [1 to: count do: [:i | self clientPI popDelete: i]]]
    ]

    getNewMailStreams: streamBlock delete: delete [
	<category: 'accessing'>
	| count |
	self connectIfClosed.
	self clientPI popUser: self username.
	self clientPI popPassword: self password.
	count := self clientPI popStatus.
	count = 0 
	    ifFalse: 
		[1 to: count do: [:i | self clientPI popRetrieve: i into: streamBlock value].
		delete ifTrue: [1 to: count do: [:i | self clientPI popDelete: i]]]
    ]

    protocolInterpreter [
	<category: 'private'>
	^POPProtocolInterpreter
    ]
]

]



Namespace current: NetClients.POP [

NetProtocolInterpreter subclass: POPProtocolInterpreter [
    
    <import: MIME>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-POP3'>

    POPProtocolInterpreter class >> defaultResponseClass [
	<category: 'private-attributes'>
	^POPResponse
    ]

    connect [
	<category: 'pop protocol'>
	super connect.
	self checkResponse
    ]

    popDelete: anInteger [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'DELE ' , anInteger printString;
	    cr.
	self checkResponse
    ]

    popList [
	<category: 'pop protocol'>
	| stream dictionary assoc |
	self
	    nextPutAll: 'LIST';
	    cr.
	self checkResponse.
	dictionary := LookupTable new.
	stream := ReadWriteStream on: (String new: 100).
	self receiveMessageUntilPeriodInto: stream.
	stream reset.
	
	[assoc := self parseSizeDataFrom: stream nextLine readStream.
	assoc key > 0] 
		whileTrue: [dictionary add: assoc].
	^dictionary
    ]

    popList: anInteger [
	<category: 'pop protocol'>
	| stream response |
	self
	    nextPutAll: 'LIST ' , anInteger printString;
	    cr.
	response := self getResponse.
	self checkResponse: response.
	response statusMessage == nil ifTrue: [^0].
	stream := response statusMessage readStream.
	^(self parseSizeDataFrom: stream) value
    ]

    popPassword: password [
	<category: 'pop protocol'>
	| response |
	self
	    nextPutAll: 'PASS ' , password;
	    cr.
	response := self getResponse.
	self checkResponse: response
	    ifError: [self loginIncorrectError: response statusMessage]
    ]

    popQuit [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'QUIT';
	    cr.
	self checkResponse
    ]

    popRetrieve: anInteger [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'RETR ' , anInteger printString;
	    cr.
	self checkResponse.
	^MIME.MimeEntity readFromClient: self connectionStream
    ]

    popRetrieve: anInteger into: aStream [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'RETR ' , anInteger printString;
	    cr.
	self checkResponse.
	self receiveMessageUntilPeriodInto: aStream
    ]

    popStatus [
	"Check status and return a number of messages."

	<category: 'pop protocol'>
	| response stream |
	self
	    nextPutAll: 'STAT';
	    cr.
	response := self getResponse.
	self checkResponse: response.
	response statusMessage == nil ifTrue: [^0 -> 0].
	stream := response statusMessage readStream.
	^self parseSizeDataFrom: stream
    ]

    popTop: anInteger lines: linesInteger [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'TOP ' , anInteger printString;
	    nextPutAll: ' ' , linesInteger printString;
	    cr.
	self checkResponse.
	^MIME.MimeEntity readFromClient: self connectionStream
    ]

    popTop: anInteger lines: linesInteger into: aStream [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'TOP ' , anInteger printString;
	    nextPutAll: ' ' , linesInteger printString;
	    cr.
	self checkResponse.
	self receiveMessageUntilPeriodInto: aStream
    ]

    popUser: user [
	<category: 'pop protocol'>
	self
	    nextPutAll: 'USER ' , user;
	    cr.
	self checkResponse
    ]

    checkResponse: response ifError: errorBlock [
	<category: 'private'>
	| status |
	status := response status.
	status = 1 
	    ifTrue: 
		["OK"

		^self].
	^errorBlock value
    ]

    parseSizeDataFrom: stream [
	<category: 'private'>
	| count size |
	stream skipSeparators.
	count := Integer readFrom: stream.
	stream skipSeparators.
	size := Integer readFrom: stream.
	^count -> size
    ]
]

]

PK
     �Mh@���f�&  �&    ContentHandler.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   Abstract ContentHandler class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
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



Object subclass: ContentHandler [
    | stream |
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    ContentHandler class [
	| validTypes |
	
    ]

    FileExtensionMap := nil.
    FileTypeMap := nil.

    ContentHandler class >> contentTypeFor: aFileName ifAbsent: aBlock [
	"Guess a MIME content type for the given file name and answer it.
	 If no interesting value could be found, evaluate aBlock"

	<category: 'checking files'>
	| posi |
	posi := aFileName findLast: [:each | each = $.].
	posi = 0 ifTrue: [^aBlock value].
	^FileExtensionMap at: (aFileName copyFrom: posi + 1 to: aFileName size)
	    ifAbsent: aBlock
    ]

    ContentHandler class >> contentTypeFor: aFileName [
	"Guess a MIME content type for the given file name and answer it"

	<category: 'checking files'>
	^self contentTypeFor: aFileName ifAbsent: ['application/octet-stream']
    ]

    ContentHandler class >> guessContentTypeFor: aPositionableStream ifAbsent: aBlock [
	"Guess a MIME content type for the given file name and answer it.
	 If no interesting value could be found, evaluate aBlock"

	<category: 'checking files'>
	| str ba text |
	str := aPositionableStream nextAvailable: 12.
	ba := str asByteArray.
	FileTypeMap do: 
		[:each | 
		| ok |
		ok := true.
		(each at: 1) doWithIndex: 
			[:ch :index | 
			(ch isSymbol or: [index >= str size]) 
			    ifFalse: 
				[ch isInteger 
				    ifTrue: [ok := ok and: [(ba at: index) = ch]]
				    ifFalse: [ok := ok and: [(str at: index) = ch]]]].
		ok ifTrue: [^each at: 2]].
	str := str , (aPositionableStream nextAvailable: 200).
	text := str allSatisfy: [:each | each value <= 127].
	^text ifTrue: ['text/plain'] ifFalse: aBlock
    ]

    ContentHandler class >> guessContentTypeFor: aPositionableStream [
	"Guess a MIME content type for the given file contents and answer it."

	<category: 'checking files'>
	^self guessContentTypeFor: aPositionableStream
	    ifAbsent: ['application/octet-stream']
    ]

    ContentHandler class >> classFor: mimeType [
	"Answer a subclass of the receiver (or the receiver itself if none
	 could be found) that can handle the mimeType content type (a String)."

	<category: 'checking files'>
	self 
	    withAllSubclassesDo: [:each | (each validTypes includes: mimeType) ifTrue: [^each]].
	^self
    ]

    ContentHandler class >> defaultFileExtensionMap [
	"Answer a default extension->mime type map"

	<category: 'accessing'>
	^#(#('aif' 'audio/x-aiff') #('ai' 'application/postscript') #('aifc' 'audio/aiff') #('aiff' 'audio/x-aiff') #('au' 'audio/basic') #('avi' 'video/x-msvideo') #('bmp' 'image/bmp') #('cdf' 'application/x-cdf') #('cer' 'application/x-x509-ca-cert') #('crt' 'application/x-x509-ca-cert') #('css' 'text/css') #('dcr' 'application/x-director') #('der' 'application/x-x509-ca-cert') #('dir' 'application/x-director') #('dll' 'application/x-msdownload') #('doc' 'application/msword') #('dot' 'application/msword') #('dxr' 'application/x-director') #('eml' 'message/rfc822') #('eps' 'application/postscript') #('exe' 'application/x-msdownload') #('fif' 'application/fractals') #('gif' 'image/gif') #('gz' 'application/x-gzip') #('hqx' 'application/mac-binhex40') #('htm' 'text/html') #('html' 'text/html') #('htt' 'text/webviewhtml') #('ins' 'application/x-internet-signup') #('isp' 'application/x-internet-signup') #('ivf' 'video/x-ivf') #('jfif' 'image/pjpeg') #('jpe' 'image/jpeg') #('jpeg' 'image/jpeg') #('jpg' 'image/jpeg') #('latex' 'application/x-latex') #('m1v' 'video/mpeg') #('man' 'application/x-troff-man') #('mht' 'message/rfc822') #('mhtml' 'message/rfc882') #('mid' 'audio/mid') #('mov' 'movie/quicktime') #('mov' 'video/quicktime') #('mp2' 'video/mpeg') #('mpa' 'video/mpeg') #('mpe' 'movie/mpeg') #('mpeg' 'movie/mpeg') #('mpg' 'video/mpeg') #('nws' 'message/rfc822') #('p7c' 'application/pkcs7-mime') #('png' 'image/png') #('pdf' 'application/pdf') #('pot' 'application/vnd.ms-powerpoint') #('ppa' 'application/vnd.ms-powerpoint') #('pps' 'application/vnd.ms-powerpoint') #('ppt' 'application/vnd.ms-powerpoint') #('ps' 'application/postscript') #('pwz' 'application/vnd.ms-powerpoint') #('qt' 'video/quicktime') #('rmi' 'audio/mid') #('rtf' 'application/msword') #('sgm' 'text/sgml') #('sgml' 'text/sgml') #('sit' 'application/x-stuffit') #('snd' 'audio/basic') #('spl' 'application/futuresplash') #('st' 'text/plain') #('swf' 'application/x-shockwave-flash') #('svg' 'image/svg+xml') #('tar' 'application/x-tar') #('tgz' 'application/x-compressed') #('tif' 'image/tiff') #('tiff' 'image/tiff') #('txt' 'text/plain') #('wav' 'audio/wav') #('wiz' 'application/msword') #('xbm' 'image/x-xbitmap') #('xml' 'text/xml') #('xls' 'application/vnd.ms-excel') #('z' 'application/x-compress') #('zip' 'application/x-zip-compressed'))	"Of course!"
    ]

    ContentHandler class >> defaultFileTypeMap [
	"Answer a default file contents->mime type map. Each element is
	 an array; the first element of the array is matched against the
	 data passed to #guessContentTypeFor:. A character or integer is
	 matched against a single byte, while if a Symbol is found, the
	 corresponding byte in the data stream is not compared against
	 anything"

	<category: 'accessing'>
	^#(#('MZ' 'application/x-msdownload') #(#($P $K 3 4) 'application/x-zip-compressed') #('%PDF' 'application/pdf') #('%!PS' 'application/postscript') #('.snd' 'audio/basic') #('dns.' 'audio/basic') #('MThd' 'audio/mid') #(#($R $I $F $F #- #- #- #- $R $M $I $D) 'audio/mid') #(#($R $I $F $F #- #- #- #- $W $A $V $E) 'audio/x-wav') #('<!DOCTYPE H' 'text/html') #('<!--' 'text/html') #('<html' 'text/html') #('<HTML' 'text/html') #('<?x' 'text/xml') #('<!' 'text/sgml') #('GIF8' 'image/gif') #('#def' 'image/x-bitmap') #('! XPM2' 'image/x-pixmap') #('/* XPM' 'image/x-pixmap') #(#($I $I 42 0) 'image/tiff') #(#($M $M 0 42) 'image/tiff') #(#(137 $P $N $G 13 10 26 10) 'image/png') #('BM' 'image/bmp') #(#[255 216 255 224] 'image/jpeg') #(#[255 216 255 232] 'image/jpg'))
    ]

    ContentHandler class >> contentType: type hasExtension: ext [
	"Associate the given MIME content type to the `ext' extension (without
	 leading dots)."

	<category: 'accessing'>
	^FileExtensionMap at: ext put: type
    ]

    ContentHandler class >> contentType: type hasMagicData: data [
	"Associate the given MIME content type to the magic data in `data'. Data
	 is an ArrayedCollection (usually an Array, ByteArray, or String) whose
	 contents are matched against the data passed to #guessContentTypeFor:. A
	 character or integer is matched against a single byte, while if a Symbol
	 is found, the corresponding byte in the data stream is not compared against
	 anything.  Of course a Symbol can only occur if data is an Array."

	<category: 'accessing'>
	^FileTypeMap add: (Array with: data with: type)
    ]

    ContentHandler class >> initialize [
	"Initialize the default file extension and magic data maps"

	<category: 'accessing'>
	FileExtensionMap := Dictionary new.
	FileTypeMap := self defaultFileTypeMap asOrderedCollection.
	self defaultFileExtensionMap 
	    do: [:each | FileExtensionMap at: (each at: 1) put: (each at: 2)].
	ContentHandler 
	    registerContentTypes: #('application/octet-stream' 'application/x-unknown' 'text/english' 'text/plain')
    ]

    ContentHandler class >> validTypes [
	"Answer some MIME types that instances the receiver can interpret"

	<category: 'accessing'>
	^validTypes isNil ifTrue: [#()] ifFalse: [validTypes]
    ]

    ContentHandler class >> registerContentType: contentType [
	"Register the receiver to be used to parse entities of the given MIME type.
	 contentTypes must be a String."

	<category: 'accessing'>
	validTypes isNil ifTrue: [validTypes := OrderedCollection new].
	validTypes add: contentType
    ]

    ContentHandler class >> registerContentTypes: contentTypes [
	"Register the receiver to be used to parse entities of the given MIME
	 types.  contentTypes must be a collection of Strings."

	<category: 'accessing'>
	validTypes isNil ifTrue: [validTypes := OrderedCollection new].
	validTypes addAll: contentTypes
    ]

    ContentHandler class >> on: stream [
	"Answer an instance of the receiver to be used to interpret data in the
	 given stream"

	<category: 'instance creation'>
	^self new initialize: stream
    ]

    contents [
	"By default, answer the whole contents of the stream without interpreting
	 anything; subclasses however might want to return a more interesting
	 object, failing if the data is somehow incorrect."

	<category: 'retrieving contents'>
	^stream contents
    ]

    initialize: aStream [
	<category: 'private'>
	stream := aStream
    ]
]



Eval [
    ContentHandler initialize
]

PK    �Mh@R�*PM  �@  	  ChangeLogUT	 dqXOǉXOux �  �  �[{s�6��[��zv�f,V����$u�&�v���ݙ�مHHD� hE�����9 >Dٔӻ���H���<� :O&���k*�$���+�8!?�ݧ7ˬ��Z�O	|1B�6��9SQ<%WR1���Nɂa:"��R������ae��SM��h8<����N�.z���}�͔��$��,(Df��s��U�H4|��w��\1=%�T�̾{�bno��bo�冰,��h�#���f)��"[��X˄gK�2�05�T"!)�cd�XVg���"�@���T��c�ι�������~��i)�:n�I��7D�c��B5srKr���������֥��f��)��Ylt��݌�s��o�	�"��1rG�sP�����JI����3�%�XrS�q���E���bg�����>���0��,�?sv��#๽ak	&Yh&��>+��T�}��{`�7*'�I��/��*���d��jjz�x���΀����^Wn5��K�|�Q��Z,(�=��ۯ�����R,��>�L�kf��b[�VO��7k�?��Z�!�D�Э�s!
��B�<�jK�Q��k�_~�BA��T�^��1��/ ���J���Č�������q��uT�Q"Q
7������Ɗ��/��U(�����.v���ֆ%����57t��f�*�����L#��խ�ق�|�k��E_~K�"`,w\����i�;M���]��"GlA�@A����3Gy�>���8���0�����#s��d�i��]�-�����)ח����}�z>B� !ǂ�d��,�R�>!v�I����\עX.�m��&B��A�V���t��p��8h͘j͔�$/�\Qt�N���a ������L�d�L̝�y��dV���1�k���&j����lvI��W�D<��w�
 L`Gf�z���a�4��6Ŝ���p�H��Z�u�=$�<)�5@�8�e�����,���j��5��I%�w�R��)���]�QbhD��J��+�b��}kH|�"f�b���Y.HE)��-�7�
��B`�Rlws����mTi�٭�oґ�Q�^��'�\@�u�Ӭ.5����?tb �M���|r��E_�"(;��4SQ`6�K���Х�K�_�&}�æ
|�;�d�e�T� 0��ڃ�'}<3(���Ac�����C�s��R���U!eƔ�	eS����GsPr�S���{��y�A0��V�ejȖQ�(�پˡ`��� J�XGQP���#�!�&E��3�S������O��WI㔯�_)�$&`�g�$�잼�3b�]���|�_F/���IS�8�=~��U��~]�G3�9�d��ϼ(�����8����T��C������I23�#HF�L�R�N��{D�����#�]�8�;Z���Ik�c��i���C���e�hMWm��bRTP���٤ܸ�!�W�,�^c�d�fbX��f4 r\�y��-T�ĳ�`��Όm�GM (.��VT(0H@�\�Y�@��ls���lF�j뱚c��ޫGVƵ�9F����6��B�Wq3 *����`K�6\΁e�AQI�3c���e��P��4���8E�u�}=�f*[��@���Y̳�^�|Z'��Ҷ���9 ;,�*b���ͥ�j�``�=8q�6��t����G����Ń#6��نUzT��7q��О�a��v-�9������l��.�\�zl+r7�������+��>p�;�6
��E�E�Kp/���Yhl�7�����{��b��|4��ځFx4�ன�æ��2|'��2�c�!�z
l��8Tg�U�(���G���4 y]~��w9�N ,���w@)��)�;S8��Fg�C�(�-�+<T{�a���ך�ϋ7[�J�2*V%�:,=�lyD��Pl�p}͘z+0x�;�����w���n;B�	P�d>.FW � s'��M<������}Itɲ�Im�n[��5���QJ����5����f�� %��ƶ���m,���`����`2��P�9H&��Է�`IH)P7P�#�� qGEQ��>O�QL�@�@k���s̰�'�(f9/��
Pil?�q�D3]I�1�\"l���-�	�=��u�7{7�.�a�芞� ���TaS����y޻�jx�$:m��J�_O98l��<]CH���v��=���|�;W�-j�s(Q�K)�ZR������:H$����$˖:�9�2`��=�|˂�NѦ�5�;�A�<I�2_�~omG/vE�Y|@/�P���l_�>r��Ǣaj��Ѥ'�khk=�b&�쩮&�ykߍMv��.54"\58 F����To���-A��Vq����F����~I��&w�2]�bߘԅ�|(��
��$�Xe-k����/�x�S��Q�E��KV#���v_ŷ� ��]P�l�&4��O��z7pc"�M��m(7R���uY���Mr��(���g����dw���w�V'��qr"3f�#�[PWj���؃�~�lQ�S��Ҳ�aH�㓳��l�fj	��I���uW�+*�S�D-.D���1;]z�,�Z���!P���U�α�#�r°���>��ʓ�ّ�t�j ��>k�F�k��on@w��v6�ʀ�3EU�n�	R�c�V��F�)�(��j�jTp>U�5Z$<l���P���2!�=;�O=��{X����Y�*�);qX�ޕO-r�����HHH�`�*f�����K �+;�]�y��a�k��\w!f����X�<`��%�[>����ꁎ6R%6���c��ܾ��v�P����x���puw���K�a*���.],<A}	j�"��`�*8��	[�x��}��B�AŊ�����b?�@�0/C�TW�b����¦v��sCn��v�� wl�I��)����@
2ٖW�WP�.�a��؁%?��������ڝ����M&d�����F5�'+��
�%VV�;_�w�4�����8�B����F[̍;�� ������� ��g�aYӰ�Ħ�5!�#}�]ދ�:��(엢��V֧]�Cܔ�7��O�\��t�Sw�t\��'^�nSȾn�$|�o�Æ���q+�s���磳��m~�� �9�oP*����n�	�6^Dy߮L,��n_XP	v�f�Y�>+�z$m?2j�
h����"p�~
����~�L�yHI�m�쾿�}4�,:�~|���z����{�K����R IZ��R^߂eJ�kv�+/�Tp�7��+�j%ޒ5���d��3n���xbm^�Cr�.���ն<���Q10�b|sg"k<������瘋m���e;��l���^��|G)bM�ڐz��d��|�aT�Bȇ�zÎ���(�ݒ��{/�I��m�����Xߓ�6��RkroS��%�g��D�|�#nZ��g�(�p#<�0�rrxx.� 	w�Mmw#E�|7�k>2��5{����U�%v_��)tUߐ�
8B ����Q� δ���(��e�;ifU�ǝ9�g8���������#�;^ 4r��,zd]�^�(Oi��ǣ�{�=�n����v̘�!�v����`��yކ,���Y�
��)�mc�9���Q��}�{��)��+�"���K+*���qSv�.B0E�j�*�/���B3�ٳ�����
���!1>nzH���)-p��K��k� .Y����x{�U����:��}�Ol���$o?�>�~��s��s��fud^�%�P!�⟓D�qm�U�����|����hհa�'�{�5�۾Qx��c������ǵ�vOh��6L\���ѯŊ�P�Tct����tCǇO����S+H^�z�4!�[9J���_0\(�	��&��~�
}�xe��3VO
����N�������u3$��wXB�hX��#�pF�=� X��ϣ3Okҿ�l9!�oC"�k�/������m�c@�S��a�M��44�4�%����EWt�$�K���T�����x�a�c����οM���B4��~�HF��O�X ��/گ��)���}�7�P]�J��C�ȗ�$�3��#ပ@�C�1�p�B�������=l?� �f��*��k�a%��֔�wTb+`Z�VymO�A"��+�q���/�����u�Ԛ�oQ�d<�����=
�-�(y�M+����h�|�b�իn!���;5�v��-T��B9i�mn�ċ�?��PmM���o���������XݚiKw�'�������I�}UÛ��:s�s?g�	�l��F�-P�,^ـ��(5kq\]����.��]����]G�(�֑������x�A��}�J2(_�dT{׌�~$�K	��PK
     �Mh@�k�^K(  K(    SMTP.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   SMTP protocol support
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, and in the public domain
| Copyright (c) 2002, 2009 Free Software Foundation, Inc.
| Adapted by Paolo Bonzini.
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



Namespace current: NetClients.SMTP [

NetClient subclass: SMTPClient [
    
    <import: MIME>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-SMTP'>

    SMTPClient class >> defaultPortNumber [
	<category: 'constants'>
	^25
    ]

    SMTPClient class >> example2Host: host [
	"self example2Host: 'localhost'."

	<category: 'examples'>
	| user message client |
	user := '%1@%2' % 
			{Smalltalk getenv: 'USER'.
			IPAddress localHostName}.
	message := MIME.MimeEntity 
		    readFrom: ('From: ' , user , '
To: ' , user , '
To: foo' , user , '
Bcc: ' 
			    , user 
				, '
Subject: Test mail from Smalltalk (SMTPClient)

This is a test mail from Smalltalk (SMTPClient).
') 
				readStream.
	client := SMTPClient connectToHost: host.
	
	[[client sendMessage: message] on: SMTPNoSuchRecipientError
	    do: 
		[:ex | 
		ex
		    inspect;
		    return]] 
		ensure: [client close]
    ]

    SMTPClient class >> exampleHost: host [
	"self exampleHost: 'localhost'."

	<category: 'examples'>
	| user message client |
	user := '%1@%2' % 
			{Smalltalk getenv: 'USER'.
			IPAddress localHostName}.
	message := MIME.MimeEntity 
		    readFrom: ('From: ' , user , '
To: ' , user , '
Bcc: ' , user 
			    , '
Subject: Test mail from Smalltalk (SMTPClient)

This is a test mail from Smalltalk (SMTPClient).
') 
				readStream.
	client := SMTPClient connectToHost: host.
	[client sendMessage: message] ensure: [client close]
    ]

    logout [
	<category: 'accessing'>
	self clientPI smtpQuit
    ]

    sendMailStream: aStream sender: sender recipients: recipients [
	<category: 'accessing'>
	self connectIfClosed.
	self clientPI smtpHello: self getHostname.
	(self clientPI isESMTP and: [self username isNil]) ifFalse: [
            self clientPI esmtpAuthLogin: self username.
            self password isNil ifFalse: [
		self clientPI esmtpPassword: self password ]].
	self clientPI smtpMail: sender.
	recipients do: [:addr | self clientPI smtpRecipient: addr].
	self clientPI smtpData: [self clientPI sendMessageWithPeriod: aStream]
    ]

    sendMessage: aMessage [
	<category: 'accessing'>
	| sender recipients |
	aMessage inspect.
	(aMessage sender isNil or: [(sender := aMessage sender addresses) isEmpty]) 
	    ifTrue: [^self error: 'No sender'].
	sender size > 1 ifTrue: [^self error: 'Invalid sender'].
	sender := sender first.
	recipients := aMessage recipients.
	^self 
	    sendMessage: aMessage
	    sender: sender
	    recipients: recipients
    ]

    sendMessage: aMessage sender: sender recipients: recipients [
	<category: 'accessing'>
	self connectIfClosed.
	self clientPI smtpHello: self getHostname.
	(self clientPI isESMTP and: [self username isNil]) ifFalse: [
            self clientPI esmtpAuthLogin: self username.
            self password isNil ifFalse: [
		self clientPI esmtpPassword: self password ]].
	self clientPI smtpMail: sender.
	recipients do: [:addr | self clientPI smtpRecipient: addr].
	self clientPI smtpData: [aMessage printMessageOnClient: self clientPI]
    ]

    getHostname [
	<category: 'private'>
	^IPAddress localHostName
    ]

    protocolInterpreter [
	<category: 'private'>
	^SMTPProtocolInterpreter
    ]
]

]



Namespace current: NetClients.SMTP [

NetProtocolInterpreter subclass: SMTPProtocolInterpreter [
    
    <import: MIME>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.
'>
    <category: 'NetClients-SMTP'>

    | esmtp |

    checkResponse: response ifError: errorBlock [
	<category: 'private'>
	| status |
	status := response status.

	"Positive Completion reply"
	status = 211 
	    ifTrue: 
		["System status, or system help reply"

		^self].
	status = 214 
	    ifTrue: 
		["Help message"

		^self].
	status = 220 
	    ifTrue: 
		["Service ready"

		^self].
	status = 221 
	    ifTrue: 
		["Service closing channel"

		^self].
        status = 235
            ifTrue:
                ["Authentication successful"

                ^self].
	status = 250 
	    ifTrue: 
		["Requested mail action okay"

		^self].
	status = 251 
	    ifTrue: 
		["User not local; will forward"

		^self].

	"Positive Intermediate reply"
        status = 334
            ifTrue:
                ["Authentication password"

                ^self].
	status = 354 
	    ifTrue: 
		["Start mail input"

		^self].

	"Transient Negative Completion reply"
	status = 421 
	    ifTrue: 
		["Service not available"

		^errorBlock value].
	status = 450 
	    ifTrue: 
		["Requested mail action not taken"

		^errorBlock value].
	status = 451 
	    ifTrue: 
		["Requested action aborted"

		^errorBlock value].
	status = 452 
	    ifTrue: 
		["Requested action not taken"

		^errorBlock value].

	"Permanent Negative Completion reply"
	status = 500 
	    ifTrue: 
		["Syntax error"

		^errorBlock value].
	status = 501 
	    ifTrue: 
		["Syntax error in parameters"

		^errorBlock value].
	status = 502 
	    ifTrue: 
		["Command not implemented"

		^errorBlock value].
	status = 503 
	    ifTrue: 
		["Bad sequence of commands"

		^errorBlock value].
	status = 504 
	    ifTrue: 
		["Command parameter not implemented"

		^errorBlock value].
	status = 550 
	    ifTrue: 
		["Requested action not taken"

		^errorBlock value].
	status = 551 
	    ifTrue: 
		["User not local; please try"

		^errorBlock value].
	status = 552 
	    ifTrue: 
		["Requested mail action aborted"

		^errorBlock value].
	status = 553 
	    ifTrue: 
		["Requested action not taken"

		^errorBlock value].
	status = 554 
	    ifTrue: 
		["Transaction failed"

		^errorBlock value].

	"Unknown status"
	^errorBlock value
    ]

    noSuchRecipientNotify: errorString [
	<category: 'private'>
	^SMTPNoSuchRecipientError signal: errorString
    ]

    connect [
	<category: 'smtp protocol'>
	| response |
	super connect.
	response := self getResponse.
	esmtp := response statusMessage ~ 'ESMTP'.
	self checkResponse: response
    ]

    isESMTP [
	<category: 'accssing'>
	^esmtp
    ]

    esmtpAuthLogin: user [
        <category: 'esmtp protocol'>
        self
            nextPutAll: 'AUTH LOGIN ', (self class base64Encode: user);
            nl.
        self checkResponse.
    ]

    esmtpPassword: password [
        <category: 'esmtp protocol'>
        self
            nextPutAll: (self class base64Encode: password);
            nl.
        self checkResponse
    ]

    smtpData: streamBlock [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'DATA';
	    nl.
	self checkResponse.
	streamBlock value.
	self checkResponse
    ]

    smtpExpand: aString [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'EXPN ' , aString;
	    nl.
	self checkResponse
    ]

    smtpHello: domain [
	<category: 'smtp protocol'>
	self
	    nextPutAll: ('%<EHLO|HELO>1 %2' % {esmtp. domain});
	    nl.
	self checkResponse
    ]

    smtpHelp [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'HELP';
	    nl.
	self checkResponse
    ]

    smtpHelp: aString [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'HELP ' , aString;
	    nl.
	self checkResponse
    ]

    smtpMail: reversePath [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'MAIL FROM: <' , reversePath displayString , '>';
	    nl.
	self checkResponse
    ]

    smtpNoop [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'NOOP';
	    nl.
	self checkResponse
    ]

    smtpQuit [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'QUIT';
	    nl.
	self checkResponse
    ]

    smtpRecipient: forwardPath [
	<category: 'smtp protocol'>
	| response |
	self
	    nextPutAll: 'RCPT TO: <' , forwardPath displayString , '>';
	    nl.
	response := self getResponse.
	self checkResponse: response
	    ifError: 
		[| status |
		status := response status.
		(status = 550 or: 
			["Requested action not taken"

			status = 551]) 
		    ifTrue: 
			["User not local; please try"

			self noSuchRecipientNotify: forwardPath]
		    ifFalse: [self errorResponse: response]]
    ]

    smtpReset [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'RSET';
	    nl.
	self checkResponse
    ]

    smtpSend: reversePath [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'SEND FROM: <' , reversePath displayString , '>';
	    nl.
	self checkResponse
    ]

    smtpSendAndMail: reversePath [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'SAML FROM: <' , reversePath displayString , '>';
	    nl.
	self checkResponse
    ]

    smtpSendOrMail: reversePath [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'SOML FROM: <' , reversePath displayString , '>';
	    nl.
	self checkResponse
    ]

    smtpTurn [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'TURN';
	    nl.
	self checkResponse
    ]

    smtpVerify: aString [
	<category: 'smtp protocol'>
	self
	    nextPutAll: 'VRFY ' , aString;
	    nl.
	self checkResponse
    ]
]

]



Namespace current: NetClients.SMTP [

NetClientError subclass: SMTPNoSuchRecipientError [
    
    <comment: nil>
    <category: 'NetClients-SMTP'>
]

]

PK
     �Mh@��g�^�  ^�    URIResolver.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   URL resolving and on-disk storage support
|
|
 ======================================================================"

"======================================================================
|
| Based on code copyright (c) Kazuki Yasumatsu, and in the public domain
| Copyright (c) 2002, 2008 Free Software Foundation, Inc.
| Adapted by Paolo Bonzini.
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



Object subclass: URIResolver [
    | url reporter noCache client entity |
    
    <import: Sockets>
    <import: MIME>
    <category: 'NetClients-URIResolver'>
    <comment: '
Copyright (c) Kazuki Yasumatsu, 1995. All rights reserved.

'>

    URIResolver class >> openOn: aURI ifFail: aBlock [
	"Check if aURI can be fetched from the Internet or from the local system,
	 and if so return a WebEntity with its contents.  If this is not possible,
	 instead, evaluate the zero-argument block aBlock and answer the result
	 of the evaluation."

	<category: 'api'>
	| url body entity |
	url := aURI.
	(url respondsTo: #key) ifTrue: [url := url key , ':/' , url value].
	url isString ifTrue: [url := URL fromString: url].
	
	[entity := (self on: url)
		    noCache: true;
		    contentsNoSignal] 
		on: ProtocolError do: [:sig | sig return: aBlock value]
		on: Error do: [:sig | sig return: aBlock value].
	^entity
    ]

    URIResolver class >> openStreamOn: aURI ifFail: aBlock [
	"Check if aURI can be fetched from the Internet or from the local system,
	 and if so return a Stream with its contents.  If this is not possible,
	 instead, evaluate the zero-argument block aBlock and answer the result
	 of the evaluation."

	<category: 'api'>
	| entity |
	entity := self openOn: aURI ifFail: [^aBlock value].
	^entity stream
    ]

    defaultHeaders [
	"The default headers for HTTP like requests"
	| requestHeaders |
	requestHeaders := OrderedCollection new.
	requestHeaders add: 'User-Agent: GNU-Smalltalk/' , Smalltalk version.
	requestHeaders add: 'Accept: text/html, image/gif, */*; q=0.2'.
	requestHeaders add: 'Host: ' , url host.
	noCache ifTrue: [requestHeaders add: 'Pragma: no-cache'].

	^ requestHeaders
    ]

    connectClient [
	<category: 'private'>
	| host |
	host := url host isNil 
		    ifTrue: [SocketAddress localHostName]
		    ifFalse: [url host].
	self connectClientToHost: host port: url port
    ]

    connectClientToHost: host port: port [
	<category: 'private'>
        client closed ifFalse: [client close].
	client hostName: host; portNumber: port; connect
    ]

    connect [
	<category: 'private'>
	client reporter: self reporter.
	url username isNil 
	    ifFalse: [client username: url username password: url password].
	client reporter statusString: 'Connecting'.
	[client connect] on: ConnectionFailedError
	    do: [:ex | ^self errorContents: ex tag]
    ]

    noCache [
	<category: 'accessing'>
	noCache isNil ifTrue: [noCache := false].
	^noCache
    ]

    noCache: aBoolean [
	<category: 'accessing'>
	noCache := aBoolean
    ]

    reporter [
	<category: 'accessing'>
	^reporter
    ]

    reporter: aReporter [
	<category: 'accessing'>
	reporter := aReporter.
	client isNil ifFalse: [client reporter: self reporter]
    ]

    entity [
	<category: 'accessing'>
	^entity
    ]

    contentsNoSignal [
	<category: 'accessing'>
	| scheme contents |
	(entity notNil and: [noCache not]) ifTrue: [^entity].
	url hasPostData 
	    ifTrue: 
		[contents := (MimeEntity new)
			    addField: ContentTypeField urlEncoded;
			    body: url postData;
			    yourself.
		^self postContentsNoSignal: contents].
	scheme := url scheme.
	scheme = 'http' ifTrue: [client := HTTP.HTTPClient new. ^entity := self getHttpContents].
	scheme = 'https' ifTrue: [client := HTTP.HTTPClient new. client isSSL: true. ^entity := self getHttpContents].
	scheme = 'ftp' ifTrue: [client := FTP.FTPClient new. ^entity := self getFtpContents].
	scheme = 'news' ifTrue: [client := NNTP.NNTPClient new. ^entity := self getNewsContents].
	scheme = 'nntp' ifTrue: [client := NNTP.NNTPClient new. ^entity := self getNntpContents].
	url isFileScheme ifTrue: [^entity := self getFileContents].
	^self errorContents: 'Unsupported protocol'
    ]

    contents [
	<category: 'accessing'>
	| messageText |
	[^self contentsNoSignal] on: Error
	    do: 
		[:ex | 
		messageText := ex messageText.
		ex return].
	^self errorContents: messageText
    ]

    getHeadNoSignal [
	<category: 'accessing'>
	| scheme |
	url hasPostData ifTrue: [^self errorContents: 'Unsupported post'].
	scheme := url scheme.
	scheme = 'http' ifTrue: [client := HTTP.HTTPClient new. ^self getHttpHead].
	scheme = 'https' ifTrue: [client := HTTP.HTTPClient new. client isSSL: true. ^self getHttpHead].
	^self errorContents: 'Unsupported protocol'
    ]

    getHead [
	<category: 'accessing'>
	| messageText |
	[^self getHeadNoSignal] on: Error
	    do: 
		[:ex | 
		messageText := ex messageText.
		ex return].
	^self errorContents: messageText
    ]

    postContents: contents [
	<category: 'accessing'>
	| messageText |
	[^self postContentNoSignal: contents] on: Error
	    do: 
		[:ex | 
		messageText := ex messageText.
		ex return].
	^self errorContents: messageText

	"^self postContentsNoSignal: contents"
    ]

    postContentsNoSignal: contents [
	<category: 'accessing'>
	| scheme |
	scheme := url scheme.
	scheme = 'http' ifTrue: [client := HTTP.HTTPClient new. ^self postHttpContents: contents].
	scheme = 'https' ifTrue: [client := HTTP.HTTPClient new. client isSSL: true. ^self postHttpContents: contents].
	^self errorContents: 'Unsupported protocol'
    ]

    getDirectoryContentsOf: aDirectory [
	<category: 'file accessing'>
	| maxSize stream title contents |
	maxSize := 32.
	stream := ReadWriteStream on: (String new: 512).
	title := 'Directory listing of ' , aDirectory fullName.
	stream 
	    nextPutAll: 'Content-type: text/html

<html>
<head>
<title>' , title 
		    , '</title>
</head>
<body>
<h2>' , title 
		    , '</h2>
'.
	stream
	    nextPutAll: '<pre>';
	    nl.
	stream 
	    nextPutAll: '<a href="file:' , aDirectory path , '" class="upfolder">'.
	stream
	    nextPutAll: 'Up to higher level directory</a>';
	    nl;
	    nl.
	aDirectory entryNames asSortedCollection do: 
		[:name | 
		| file isDirectory fileSize |
		file := aDirectory at: name.
		
		[isDirectory := file isDirectory.
		fileSize := file size] on: Error
			do: 
			    [:ex | 
			    isDirectory := false.
			    fileSize := 0.
			    ex return].
		stream
		    tab;
		    nextPutAll: '<a href="file:' , file fullName , '" class="'.
		isDirectory 
		    ifTrue: [stream nextPutAll: 'folder']
		    ifFalse: [stream nextPutAll: 'document'].
		stream nextPutAll: '">'.
		stream
		    nextPutAll: name;
		    nextPutAll: '</a>'.
		name size <= maxSize 
		    ifFalse: 
			[stream
			    nl;
			    tab;
			    next: maxSize put: $ ]
		    ifTrue: [stream next: maxSize - name size put: $ ].
		fileSize := fileSize printString.
		fileSize size < 8 ifTrue: [stream next: 8 - fileSize size put: $ ].
		stream
		    nextPutAll: fileSize;
		    nextPutAll: ' bytes'.
		stream nl].
	stream
	    nextPutAll: '</pre>';
	    nl.
	stream nextPutAll: '</body>
</html>'.
	stream reset.
	^(WebEntity readFrom: stream)
	    url: url;
	    canCache: false;
	    yourself
    ]

    getFileContents [
	<category: 'file accessing'>
	| file result |
	file := File name: (url path ifNil: '/').
	file exists ifFalse: [^self errorContents: 'No such file'].
	file isReadable ifFalse: [^self errorContents: 'Cannot read'].
	file isDirectory ifTrue: [^self getDirectoryContentsOf: file].
	^(WebEntity new)
	    url: url;
	    canCache: false;
	    localFileName: url path;
	    guessMimeType;
	    yourself
    ]

    getFtpContents [
	<category: 'ftp accessing'>
	| contents path tmpFile type stream |
	contents := self getProxyContentsHost: 'ftpProxyHost' port: 'ftpProxyPort'.
	contents notNil ifTrue: [^contents].
	self connectClient.
	
	[| user mail |
	user := NetUser new.
	url username isNil 
	    ifTrue: [user username: 'anonymous']
	    ifFalse: [user username: url username].
	url password isNil 
	    ifTrue: 
		["Anonymous FTP, send e-mail address as password"

		mail := UserProfileSettings default settingAt: #mailAddress.
		(mail isNil or: ['*@*.*' match: mail]) ifTrue: [mail := 'gst@'].
		user password: mail]
	    ifFalse: [user password: url password].
	client
	    user: user;
	    login] 
		on: NetClientError
		do: 
		    [:ex | 
		    client close.
		    ^self errorContents: ex tag].
	client reporter 
	    statusString: 'Connect: Host contacted. Waiting for reply...'.
	(url path isNil or: [url path isEmpty]) 
	    ifTrue: [path := '/']
	    ifFalse: [path := url path].
	stream := self tmpFile.
	tmpFile := stream file.
	^
	[
	[client 
	    getFile: path
	    type: #binary
	    into: stream] 
		ensure: [stream close].
	(WebEntity new)
	    url: url;
	    canCache: false;
	    localFileName: tmpFile name;
	    guessMimeType;
	    yourself] 
		on: NetClientError
		do: [:ex | ^self errorContents: ex messageText]
		on: FTP.FTPFileNotFoundError
		do: 
		    [:ex | 
		    tmpFile exists ifTrue: [tmpFile remove].
		    stream := ReadWriteStream on: (String new: 512).
		    ^
		    [(path at: path size) = '/' ifFalse: [path := path copyWith: $/].
		    client getList: path into: stream.
		    stream reset.
		    self getFtpDirectoryContentsFrom: stream] 
			    on: FTP.FTPFileNotFoundError
			    do: [:ex | ^self errorContents: ex messageText]]
    ]

    getFtpDirectoryContentsFrom: aStream [
	<category: 'ftp accessing'>
	| baseURL maxSize stream title contents sp read mode ftype fileSize name newURL index |
	baseURL := url copy.
	baseURL path isNil 
	    ifTrue: [baseURL path: '/junk']
	    ifFalse: [baseURL path: (File append: 'junk' to: baseURL path)].
	maxSize := 32.
	stream := ReadWriteStream on: (String new: 512).
	title := 'Directory listing of ' , url printString.
	stream 
	    nextPutAll: 'Content-type: text/html

<html>
<head>
<title>' , title 
		    , '</title>
</head>
<body>
<h2>' , title 
		    , '</h2>
'.

	"-rwxr-xr-x  1 user    group         512 Aug  8 05:57 file"
	"drwxr-xr-x  1 user    group         512 Aug  8 05:57 directory"
	"lrwxrwxrwx  1 user    group         512 Aug  8 05:57 symlink"
	"brwxr-xr-x  1 user    group         0, 1 Aug  8 05:57 block-device"
	"crwxr-xr-x  1 user    group         1, 2 Aug  8 05:57 character-device"
	"p---------  1 user    group         0 Aug  8 05:57 pipe"
	stream
	    nextPutAll: '<pre>';
	    nl.
	baseURL path isNil 
	    ifFalse: 
		[stream
		    nextPutAll: '<a href="';
		    print: (baseURL construct: (URL fromString: '..'));
		    nextPutAll: '" class="upfolder">'].
	stream
	    nextPutAll: 'Up to higher level directory</a>';
	    nl;
	    nl.
	[aStream atEnd] whileFalse: 
		[sp := Character space.
		read := (aStream upTo: Character nl) readStream.
		mode := read upTo: sp.
		mode isEmpty ifTrue: [ftype := nil] ifFalse: [ftype := mode first].
		read skipSeparators.
		read upTo: sp.	"nlink"
		read skipSeparators.
		read upTo: sp.	"user"
		read skipSeparators.
		read upTo: sp.	"group"
		read skipSeparators.
		(ftype = $b or: [ftype = $c]) 
		    ifTrue: 
			[fileSize := '0'.
			read upTo: sp.	"major"
			read skipSeparators.
			read upTo: sp	"minor"]
		    ifFalse: [fileSize := read upTo: sp].
		read skipSeparators.
		read upTo: sp.	"month"
		read skipSeparators.
		read upTo: sp.	"day"
		read skipSeparators.
		read upTo: sp.	"time"
		read skipSeparators.
		name := read upToEnd trimSeparators.
		(ftype isNil or: [name isEmpty or: [name = '.' or: [name = '..']]]) 
		    ifFalse: 
			[ftype = $l 
			    ifTrue: 
				["symbolic link"

				index := name indexOfSubCollection: ' -> ' startingAt: 1.
				index > 0 
				    ifTrue: 
					[newURL := baseURL 
						    construct: (URL fromString: (name copyFrom: index + 4 to: name size)).
					name := name copyFrom: 1 to: index - 1]
				    ifFalse: [newURL := baseURL construct: (URL fromString: name)]]
			    ifFalse: 
				[(ftype = $- or: [ftype = $d]) 
				    ifTrue: [newURL := baseURL construct: (URL fromString: name)]
				    ifFalse: [newURL := nil]].
			stream tab.
			newURL isNil 
			    ifTrue: [stream nextPutAll: '<span class="']
			    ifFalse: [stream nextPutAll: '<a href="' , newURL printString , '" class="'].
			ftype = $d 
			    ifTrue: [stream nextPutAll: 'folder']
			    ifFalse: 
				[ftype = $l 
				    ifTrue: [stream nextPutAll: 'symlink']
				    ifFalse: [stream nextPutAll: 'document']].
			stream nextPutAll: '">'.
			name size <= maxSize 
			    ifTrue: 
				[stream nextPutAll: name.
				newURL isNil ifFalse: [stream nextPutAll: '</a>'].
				maxSize - name size timesRepeat: [stream space]]
			    ifFalse: 
				[stream nextPutAll: name.
				newURL isNil ifFalse: [stream nextPutAll: '</a>'].
				stream
				    nl;
				    tab.
				maxSize timesRepeat: [stream space]].
			fileSize size < 8 ifTrue: [8 - fileSize size timesRepeat: [stream space]].
			stream
			    nextPutAll: fileSize;
			    nextPutAll: ' bytes'.
			stream nl]].
	stream
	    nextPutAll: '</pre>';
	    nl.
	stream nextPutAll: '</body>
</html>'.
	stream reset.
	^(WebEntity readFrom: stream)
	    url: url;
	    canCache: false;
	    yourself
    ]

    getHttpContents [
	<category: 'http accessing'>
	| contents urlString |
	contents := self getProxyContentsHost: 'httpProxyHost'
		    port: 'httpProxyPort'.
	contents notNil ifTrue: [^contents].
	self connectClient.
	^self requestHttpContents: url requestString
    ]

    doHTTPRequest: requestBlock onSuccess: successBlock [
	<category: 'private'>
	| requestHeaders tmpFile stream protocolError response string |
	requestHeaders := self defaultHeaders.
	client reporter statusString: 'Connecting'.
	protocolError := false.
	client reporter 
	    statusString: 'Connect: Host contacted. Waiting for reply...'.
	stream := self tmpFile.
	tmpFile := stream file.
	
	[
	[
	[response := requestBlock value: requestHeaders value: stream]
		ensure: [client close]] 
		on: ProtocolError
		do: 
		    [:ex | 
		    protocolError := true.
		    ex pass]
		on: NetClientError
		do: [:ex | ^self errorContents: ex messageText]
		on: HTTP.HTTPRedirection
		do: 
		    [:ex | 
		    | location |
		    location := ex location.
		    client reporter statusString: 'Redirecting'.
		    stream close.
		    stream := nil.
		    tmpFile exists ifTrue: [tmpFile remove].
		    ^(self class on: (url construct: (URL fromString: location)))
			noCache: self noCache;
			reporter: self reporter;
			contents]] 
		ensure: [stream isNil ifFalse: [stream close]].
	^protocolError 
	    ifTrue: 
		[string := tmpFile contents.
		tmpFile remove.
		(WebEntity new)
		    body: string;
		    url: url;
		    canCache: false;
		    guessMimeType;
		    yourself]
	    ifFalse: 
		[|ent |
		    ent := (WebEntity new)
			    url: url;
			    localFileName: tmpFile name;
			    canCache: noCache not;
			    guessMimeType;
			    yourself.
		    successBlock value: ent.
		    ent]
    ]

    requestHttpContents: urlString [
	<category: 'http accessing'>
	^ self doHTTPRequest: [:requestHeaders :stream |
		    client  get: urlString requestHeaders: requestHeaders into: stream]
	       onSuccess: [:ent | ]
    ]

    getHttpHead [
	<category: 'http accessing'>
	| contents |
	contents := self getProxyHeadHost: 'httpProxyHost' port: 'httpProxyPort'.
	contents notNil ifTrue: [^contents].
	self connectClient.
	^self requestHttpHead: url requestString
    ]

    requestHttpHead: urlString [
	<category: 'http accessing'>
	| requestHeaders tmpFile stream protocolError response string |
	requestHeaders := self defaultHeaders.
	client reporter statusString: 'Connecting'.
	client reporter 
	    statusString: 'Connect: Host contacted. Waiting for reply...'.
	stream := self tmpFile.
	tmpFile := stream file.
	protocolError := false.
	
	[
	[
	[response := client 
		    head: urlString
		    requestHeaders: requestHeaders
		    into: stream] 
		ensure: [client close]] 
		on: ProtocolError
		do: 
		    [:ex | 
		    protocolError := true.
		    ex pass]
		on: NetClientError
		do: [:ex | ^self errorContents: ex messageText]
		on: HTTP.HTTPRedirection
		do: 
		    [:ex | 
		    | location |
		    location := ex location.
		    client reporter statusString: 'Redirecting'.
		    stream close.
		    stream := nil.
		    tmpFile exists ifTrue: [tmpFile remove].
		    ^(self class on: (url construct: (URL fromString: location)))
			noCache: self noCache;
			reporter: self reporter;
			getHead]] 
		ensure: [stream isNil ifFalse: [stream close]].
	^protocolError 
	    ifTrue: 
		[string := tmpFile contents.
		tmpFile remove.
		(WebEntity new)
		    body: string;
		    url: url;
		    canCache: false;
		    guessMimeTypeFromResponse: response;
		    yourself]
	    ifFalse: 
		[(WebEntity new)
		    url: url;
		    canCache: false;
		    localFileName: tmpFile name;
		    guessMimeTypeFromResponse: response;
		    yourself]
    ]

    postHttpContents: contents [
	<category: 'http accessing'>
	| replyContents |
	replyContents := self 
		    postProxyContents: contents
		    host: 'httpProxyHost'
		    port: 'httpProxyPort'.
	replyContents notNil ifTrue: [^replyContents].
	self connectClient.
	^self postHttpContents: contents urlString: url requestString
    ]

    postHttpContents: contents urlString: urlString [
	<category: 'http accessing'>
	^ self doHTTPRequest: [:requestHeaders :stream |
		    client post: urlString
		    type: contents type
		    data: contents asStringOrByteArray
		    binary: contents isBinary
		    requestHeaders: requestHeaders
		    into: stream] 
		onSuccess: [:ent | ent canCache: false ]
    ]

    emptyMessage [
	<category: 'mailto accessing'>
	| message address fields subject references |
	message := MimeEntity new.
	address := self defaultMailAddress.
	message parseFieldFrom: ('From: ' , address) readStream.
	url query isNil 
	    ifFalse: 
		[fields := url decodedFields.
		subject := fields at: 'subject' ifAbsent: [nil].
		subject isNil 
		    ifFalse: 
			[message parseFieldFrom: ('Subject: ' , subject displayString) readStream].
		references := fields at: 'references' ifAbsent: [nil].
		references isNil 
		    ifFalse: 
			[message 
			    parseFieldFrom: ('References: ' , references displayString) readStream]].
	^message
    ]

    emptyMailMessage [
	<category: 'mailto accessing'>
	| message to |
	message := self emptyMessage.
	to := url path.
	to isNil ifFalse: [message parseFieldFrom: ('To: ' , to) readStream].
	message 
	    parseFieldFrom: ('X-Mailer: GNU-Smalltalk/' , Smalltalk version) readStream.
	^message
    ]

    getNewsArticleContents: articleId [
	<category: 'news accessing'>
	| tmpFile stream contents |
	stream := self tmpFile.
	tmpFile := stream file.
	
	[
	[client articleAt: '<' , articleId , '>' into: stream.
	client quit] 
		ensure: 
		    [stream close.
		    client close]] 
		on: NetClientError
		do: 
		    [:ex | 
		    tmpFile exists ifTrue: [tmpFile remove].
		    ^self errorContents: ex messageText].
	^(WebEntity readFrom: tmpFile contents type: 'message/news')
	    url: url;
	    canCache: false;
	    localFileName: tmpFile name;
	    yourself
    ]

    getNewsArticleContents: articleNo group: group [
	<category: 'news accessing'>
	| tmpFile stream contents |
	stream := self tmpFile.
	tmpFile := stream file.
	
	[
	[client 
	    articleAtNumber: articleNo
	    group: group
	    into: stream.
	client quit] 
		ensure: 
		    [stream close.
		    client close]] 
		on: NetClientError
		do: 
		    [:ex | 
		    tmpFile exists ifTrue: [tmpFile remove].
		    ^self errorContents: ex messageText].
	^(WebEntity readFrom: tmpFile contents type: 'message/news')
	    url: url;
	    canCache: false;
	    localFileName: tmpFile name;
	    yourself
    ]

    getNewsArticleList: from to: to group: group [
	<category: 'news accessing'>
	| subjects index |
	subjects := Array new: to - from + 1.
	index := 0.
	client 
	    subjectsOf: group
	    from: from
	    to: to
	    do: [:n :subject | subjects at: (index := index + 1) put: (Array with: n with: subject)].
	index = 0 ifTrue: [^Array new].
	index < subjects size ifTrue: [subjects := subjects copyFrom: 1 to: index].
	^subjects
    ]

    getNewsArticleListContents: group [
	<category: 'news accessing'>
	| maxRange range from to prevRanges subjects stream pto pfrom |
	maxRange := 100.
	range := client activeArticlesInGroup: group.
	from := range first.
	to := range last.
	prevRanges := OrderedCollection new.
	to - from + 1 > maxRange 
	    ifTrue: 
		[pfrom := from.
		from := to - maxRange + 1.
		pto := from - 1.
		[pto - pfrom + 1 > maxRange] whileTrue: 
			[prevRanges addFirst: (pto - maxRange + 1 to: pto).
			pto := pto - maxRange].
		prevRanges addFirst: (pfrom to: pto)].
	subjects := self 
		    getNewsArticleList: from
		    to: to
		    group: group.
	client
	    quit;
	    close.
	stream := ReadWriteStream on: (String new: 80 * subjects size).
	stream
	    nextPutAll: 'Content-type: text/html';
	    nl;
	    nl;
	    nextPutAll: '<html>';
	    nl;
	    nextPutAll: '<title>Newsgroup: ' , group , '</title>';
	    nl;
	    nextPutAll: '<h1>Newsgroup: ' , group , '</h1>';
	    nl.
	prevRanges isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<hr>';
		    nl;
		    nextPutAll: '<b>Previous articles</b>';
		    nl;
		    nextPutAll: '<ul>';
		    nl.
		prevRanges do: 
			[:r | 
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '/';
			    print: r first;
			    nextPut: $-;
			    print: r last;
			    nextPutAll: '">';
			    print: r first;
			    nextPut: $-;
			    print: r last;
			    nextPutAll: '</a></li>';
			    nl].
		stream
		    nextPutAll: '</ul>';
		    nl;
		    nextPutAll: '<hr>';
		    nl].
	subjects isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<ul>';
		    nl.
		subjects do: 
			[:array | 
			| n subject |
			n := array at: 1.
			subject := array at: 2.
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '/' , n printString , '">';
			    nl;
			    nextPutAll: subject , '</a></li>';
			    nl].
		stream
		    nextPutAll: '</ul>';
		    nl].
	stream
	    nextPutAll: '</html>';
	    nl.
	stream reset.
	^(WebEntity readFrom: stream) url: url
    ]

    getNewsArticleListContents: from to: to group: group [
	<category: 'news accessing'>
	| subjects stream |
	subjects := self 
		    getNewsArticleList: from
		    to: to
		    group: group.
	client
	    quit;
	    close.
	stream := ReadWriteStream on: (String new: 80 * subjects size).
	stream
	    nextPutAll: 'Content-type: text/html';
	    nl;
	    nl;
	    nextPutAll: '<html>';
	    nl;
	    nextPutAll: '<title>Newsgroup: ' , group , ' (' , from printString , '-' 
			, to printString , ')</title>';
	    nl;
	    nextPutAll: '<h1>Newsgroup: ' , group , ' (' , from printString , '-' 
			, to printString , ')</h1>';
	    nl.
	subjects isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<ul>';
		    nl.
		subjects do: 
			[:array | 
			| n subject |
			n := array at: 1.
			subject := array at: 2.
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '/' , n printString , '">';
			    nl;
			    nextPutAll: subject , '</a></li>';
			    nl].
		stream
		    nextPutAll: '</ul>';
		    nl].
	stream
	    nextPutAll: '</html>';
	    nl.
	stream reset.
	^(WebEntity readFrom: stream) url: url
    ]

    getNewsContents [
	<category: 'news accessing'>
	| host string |
	(url hasFragment or: [url hasQuery]) ifTrue: [^self invalidURL].
	host := url host.
	host isNil 
	    ifTrue: 
		[host := UserProfileSettings default settingAt: 'nntpHost' ifAbsent: [nil]].
	host isNil ifTrue: [^self invalidURL].
	string := url path.
	string isNil ifTrue: [^self invalidURL].
	self connectClient.
	
	[
	[(string indexOf: $@) > 0 
	    ifTrue: 
		["may be article"

		^self getNewsArticleContents: string]
	    ifFalse: 
		["may be newsgroup"

		^self getThreadedNewsArticleListContents: string]] 
		ensure: [client close]] 
		on: NetClientError
		do: [:ex | ^self errorContents: ex messageText]
    ]

    getNntpContents [
	<category: 'news accessing'>
	| host string read group from to |
	(url hasFragment or: [url hasPostData]) ifTrue: [^self invalidURL].
	host := url host.
	host isNil 
	    ifTrue: 
		[host := UserProfileSettings default settingAt: 'nntpHost' ifAbsent: [nil]].
	host isNil ifTrue: [^self invalidURL].
	string := url path.
	string isNil ifTrue: [^self invalidURL].
	read := string readStream.
	read atEnd ifTrue: [^self invalidURL].
	read peek = $/ ifTrue: [read next].
	group := read upTo: $/.
	url hasQuery 
	    ifTrue: 
		[read := url query readStream.
		read atEnd ifTrue: [^self invalidURL].
		from := Integer readFrom: read.
		from = 0 ifTrue: [^self invalidURL].
		read next = $- ifFalse: [^self invalidURL].
		to := Integer readFrom: read.
		to = 0 ifTrue: [^self invalidURL]]
	    ifFalse: 
		[read atEnd ifTrue: [^self invalidURL].
		from := Integer readFrom: read.
		from = 0 ifTrue: [^self invalidURL].
		to := nil].
	self connectClient.
	^
	[
	[to isNil 
	    ifTrue: [self getNewsArticleContents: from group: group]
	    ifFalse: 
		[self 
		    getThreadedNewsArticleListContents: from
		    to: to
		    group: group]] 
		ensure: [client close]] 
		on: NetClientError
		do: [:ex | ^self errorContents: ex messageText]
    ]

    getThreadedNewsArticleList: from to: to group: group [
	<category: 'news accessing'>
	| subjects threads |
	subjects := self 
		    getNewsArticleList: from
		    to: to
		    group: group.
	threads := Dictionary new.
	subjects do: 
		[:array | 
		| read stream head tname col |
		read := (array at: 2) readStream.
		stream := WriteStream on: (String new: read size).
		
		[read skipSeparators.
		head := read nextAvailable: 3.
		'Re:' sameAs: head] 
			whileTrue: [].
		stream
		    nextPutAll: head;
		    nextPutAll: read.
		tname := stream contents.
		col := threads at: tname ifAbsent: [nil].
		col notNil 
		    ifTrue: [col add: array]
		    ifFalse: 
			[col := SortedCollection sortBlock: 
					[:x :y | 
					| xn yn xsize ysize |
					xn := x at: 1.
					yn := y at: 1.
					xsize := (x at: 2) size.
					ysize := (y at: 2) size.
					xsize = ysize ifTrue: [xn <= yn] ifFalse: [xsize <= ysize]].
			col add: array.
			threads at: tname put: col]].
	^threads
    ]

    getThreadedNewsArticleListContents: group [
	<category: 'news accessing'>
	| maxRange range from to prevRanges threads stream pto pfrom |
	maxRange := 100.
	range := client activeArticlesInGroup: group.
	from := range first.
	to := range last.
	prevRanges := OrderedCollection new.
	to - from + 1 > maxRange 
	    ifTrue: 
		[pfrom := from.
		from := to - maxRange + 1.
		pto := from - 1.
		[pto - pfrom + 1 > maxRange] whileTrue: 
			[prevRanges addFirst: (pto - maxRange + 1 to: pto).
			pto := pto - maxRange].
		prevRanges addFirst: (pfrom to: pto)].
	threads := self 
		    getThreadedNewsArticleList: from
		    to: to
		    group: group.
	client
	    quit;
	    close.
	stream := ReadWriteStream on: (String new: 80 * threads size).
	stream
	    nextPutAll: 'Content-type: text/html';
	    nl;
	    nl;
	    nextPutAll: '<html>';
	    nl;
	    nextPutAll: '<title>Newsgroup: ' , group , '</title>';
	    nl;
	    nextPutAll: '<h1>Newsgroup: ' , group , '</h1>';
	    nl.
	prevRanges isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<hr>';
		    nl;
		    nextPutAll: '<b>Previous articles</b>';
		    nl;
		    nextPutAll: '<ul>';
		    nl.
		prevRanges do: 
			[:r | 
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '?' , r first printString , '-' 
					, r last printString , '">';
			    nl;
			    nextPutAll: r first printString , '-' , r last printString , '</a></li>';
			    nl].
		stream
		    nextPutAll: '</ul>';
		    nl;
		    nextPutAll: '<hr>';
		    nl].
	threads isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<ul>';
		    nl.
		threads keys asSortedCollection do: 
			[:key | 
			| col first |
			col := threads at: key.
			first := col removeFirst.
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '/' , (first at: 1) printString 
					, '">';
			    nl;
			    nextPutAll: (first at: 2) , '</a></li>';
			    nl.
			col isEmpty 
			    ifFalse: 
				[stream
				    nextPutAll: '<ul>';
				    nl.
				col do: 
					[:array | 
					| n subject |
					n := array at: 1.
					subject := array at: 2.
					stream
					    nextPutAll: '<li><a href="nntp:/' , group , '/' , n printString , '">';
					    nl;
					    nextPutAll: subject , '</a></li>';
					    nl].
				stream
				    nextPutAll: '</ul>';
				    nl]].
		stream
		    nextPutAll: '</ul>';
		    nl].
	stream
	    nextPutAll: '</html>';
	    nl.
	stream reset.
	^(WebEntity readFrom: stream) url: url
    ]

    getThreadedNewsArticleListContents: from to: to group: group [
	<category: 'news accessing'>
	| threads stream |
	threads := self 
		    getThreadedNewsArticleList: from
		    to: to
		    group: group.
	client
	    quit;
	    close.
	stream := ReadWriteStream on: (String new: 80 * threads size).
	stream
	    nextPutAll: 'Content-type: text/html';
	    nl;
	    nl;
	    nextPutAll: '<html>';
	    nl;
	    nextPutAll: '<title>Newsgroup: ' , group , ' (' , from printString , '-' 
			, to printString , ')</title>';
	    nl;
	    nextPutAll: '<h1>Newsgroup: ' , group , ' (' , from printString , '-' 
			, to printString , ')</h1>';
	    nl.
	threads isEmpty 
	    ifFalse: 
		[stream
		    nextPutAll: '<ul>';
		    nl.
		threads keys asSortedCollection do: 
			[:key | 
			| col first |
			col := threads at: key.
			first := col removeFirst.
			stream
			    nextPutAll: '<li><a href="nntp:/' , group , '/' , (first at: 1) printString 
					, '">';
			    nl;
			    nextPutAll: (first at: 2) , '</a></li>';
			    nl.
			col isEmpty 
			    ifFalse: 
				[stream
				    nextPutAll: '<ul>';
				    nl.
				col do: 
					[:array | 
					| n subject |
					n := array at: 1.
					subject := array at: 2.
					stream
					    nextPutAll: '<li><a href="nntp:/' , group , '/' , n printString , '">';
					    nl;
					    nextPutAll: subject , '</a></li>';
					    nl].
				stream
				    nextPutAll: '</ul>';
				    nl]].
		stream
		    nextPutAll: '</ul>';
		    nl].
	stream
	    nextPutAll: '</html>';
	    nl.
	stream reset.
	^(WebEntity readFrom: stream) url: url
    ]

    emptyNewsMessage [
	<category: 'postto accessing'>
	| message group org |
	message := self emptyMessage.
	group := url path.
	group isNil 
	    ifFalse: [message parseFieldFrom: ('Newsgroups: ' , group) readStream].
	org := UserProfileSettings default settingAt: 'organization'
		    ifAbsent: [nil].
	org isNil 
	    ifFalse: [message parseFieldFrom: ('Organization: ' , org) readStream].
	message 
	    parseFieldFrom: ('X-Newsreader: GNU-Smalltalk/' , Smalltalk version) 
		    readStream.
	^message
    ]

    defaultMailAddress [
	<category: 'private'>
	^UserProfileSettings default settingAt: #mailAddress
    ]

    errorContents: errorString [
	<category: 'private'>
	| contents |
	contents := WebEntity 
		    readFrom: ('Content-type: text/html

<html>
<body>
<h1>Error</h1>
<p><b>Reason:</b> ' 
			    , errorString , '</p>
</body>
</html>') 
			    readStream.
	contents url: url.
	contents canCache: false.
	^contents
    ]

    getBufferSize [
	<category: 'private'>
	| kbytes |
	kbytes := (UserProfileSettings default settingAt: #bufferSize) asNumber.
	^kbytes * 1024
    ]

    getNoProxyHostNames [
	<category: 'private'>
	| col read stream noProxy ch |
	col := OrderedCollection new.
	noProxy := UserProfileSettings default settingAt: #proxyList.
	noProxy = 'none' ifTrue: [^col].
	read := noProxy readStream.
	stream := WriteStream on: (String new: 64).
	[read atEnd] whileFalse: 
		[read skipSeparators.
		stream reset.
		[read atEnd or: 
			[ch := read next.
			ch isSeparator or: [ch = $,]]] 
		    whileFalse: [stream nextPut: ch].
		stream isEmpty ifFalse: [col addLast: stream contents]].
	stream isEmpty ifFalse: [col addLast: stream contents].
	^col
    ]

    getProxyContentsHost: hostKey port: portKey [
	<category: 'private'>
	| host port |
	(host := url host) isNil 
	    ifTrue: [^self errorContents: 'No host name is specified'].
	(self isNoProxyHost: host) ifTrue: [^nil].
	host := UserProfileSettings default settingAt: hostKey.
	(host isString and: [host notEmpty]) ifFalse: [^nil].
	port := UserProfileSettings default settingAt: portKey.
	port isInteger ifFalse: [^nil].
        client := HTTP.HTTPClient new.
	self connectClientToHost: host port: port.
	^self requestHttpContents: url fullRequestString
    ]

    getProxyHeadHost: hostKey port: portKey [
	<category: 'private'>
	| host port |
	(host := url host) isNil 
	    ifTrue: [^self errorContents: 'No host name is specified'].
	(self isNoProxyHost: host) ifTrue: [^nil].
	host := UserProfileSettings default settingAt: hostKey.
	(host isString and: [host notEmpty]) ifFalse: [^nil].
	port := UserProfileSettings default settingAt: portKey.
	port isInteger ifFalse: [^nil].
        client := HTTP.HTTPClient new.
	self connectClientToHost: host port: port.
	^self requestHttpHead: url fullRequestString
    ]

    invalidURL [
	<category: 'private'>
	^self errorContents: 'Invalid URL'
    ]

    isNoProxyHost: host [
	<category: 'private'>
	self getNoProxyHostNames 
	    do: [:noproxy | ('*' , noproxy , '*' match: host) ifTrue: [^true]].
	^false
    ]

    on: anURL [
	<category: 'private'>
	url := anURL
    ]

    postProxyContents: contents host: hostKey port: portKey [
	<category: 'private'>
	| host port |
	(host := url host) isNil 
	    ifTrue: [^self errorContents: 'No host name is specified'].
	(self isNoProxyHost: host) ifTrue: [^nil].
	host := UserProfileSettings default settingAt: hostKey.
	(host isString and: [host notEmpty]) ifFalse: [^nil].
	port := UserProfileSettings default settingAt: portKey.
	port isInteger ifFalse: [^nil].
        client := HTTP.HTTPClient new.
	self connectClientToHost: host port: port.
	^self postHttpContents: contents urlString: url fullRequestString
    ]

    tmpFile [
	<category: 'private'>
	| dir |
	dir := UserProfileSettings default settingAt: 'tmpDir'.
	dir = '' ifTrue: [dir := '/tmp/'] ifFalse: [dir := dir , '/'].
	^FileStream openTemporaryFile: dir
    ]
]



MIME.MimeEntity subclass: WebEntity [
    | url canCache localFileName |
    
    <comment: nil>
    <category: 'NetSupport-WWW-Objects'>

    body [
	<category: 'accessing'>
	| stream type file |
	body isNil ifFalse: [^super body].

	"Read it from the file"
	type := (self fieldAt: 'content-type') type.
	file := File name: localFileName.
	stream := self class parser on: file readStream.
	('message/*' match: type) 
	    ifTrue: 
		[self fields removeKey: 'content-type'.
		self readFrom: stream].
	self parseBodyFrom: stream.
	^body
    ]

    stream [
	<category: 'accessing'>
	| body |
	body := self body.
	self canDelete ifTrue: [(File name: self localFileName) remove].
	^body readStream
    ]

    canCache [
	<category: 'accessing'>
	canCache notNil ifTrue: [^canCache].
	^url notNil and: [url canCache]
    ]

    canCache: aBoolean [
	<category: 'accessing'>
	canCache := aBoolean
    ]

    canDelete [
	<category: 'accessing'>
	(url notNil and: [url isFileScheme]) ifTrue: [^false].
	^self isFileContents
    ]

    isFileContents [
	<category: 'accessing'>
	^localFileName notNil
    ]

    localFileName [
	<category: 'accessing'>
	^localFileName
    ]

    localFileName: aString [
	<category: 'accessing'>
	localFileName := aString
    ]

    url [
	<category: 'accessing'>
	^url
    ]

    url: anURL [
	<category: 'accessing'>
	url := anURL
    ]

    urlName [
	<category: 'accessing'>
	^url isNil ifTrue: ['<no URL>'] ifFalse: [url printString]
    ]

    guessMimeTypeFromResponse: aResponse [
	<category: 'mime types'>
	self addField: (self contentTypeFromResponse: aResponse)
    ]

    guessMimeType [
	<category: 'mime types'>
	| mimeType |
	mimeType := self guessedContentType.
	self addField: (ContentTypeField fromLine: 'content-type: ' , mimeType)
    ]

    contentTypeFromResponse: aResponse [
	<category: 'mime types'>
	| mimeType |
	aResponse isNil 
	    ifFalse: 
		[mimeType := aResponse fieldAt: 'content-type' ifAbsent: [nil].
		mimeType isNil ifFalse: [^mimeType]].
	mimeType := self guessedContentType.
	^ContentTypeField fromLine: 'content-type: ' , mimeType
    ]

    contentTypeFromURL [
	<category: 'mime types'>
	| path index |
	path := url path.
	(path isNil or: [path isEmpty]) ifTrue: [^nil].
	^ContentHandler contentTypeFor: url path ifAbsent: [nil]
    ]

    contentTypeFromContents [
	<category: 'mime types'>
	| file stream |
	file := File name: localFileName.
	file exists 
	    ifTrue: 
		[stream := file readStream.
		^[ContentHandler guessContentTypeFor: stream] ensure: [stream close]]
    ]

    guessedContentType [
	<category: 'mime types'>
	| mimeType |
	url isNil 
	    ifFalse: 
		[mimeType := self contentTypeFromURL.
		mimeType isNil ifFalse: [^mimeType]].
	localFileName isNil 
	    ifFalse: 
		["check for well-known magic types"

		^self contentTypeFromContents].
	^'application/octet-stream'
    ]
]



Object subclass: UserProfileSettings [
    | settings |
    
    <category: 'NetClients-URIResolver'>
    <comment: nil>

    UserProfileSettings class [
	| default |
	
    ]

    UserProfileSettings class >> default [
	<category: 'accessing'>
	^default isNil ifTrue: [default := self new] ifFalse: [default]
    ]

    UserProfileSettings class >> default: aSettingsObject [
	<category: 'accessing'>
	default := aSettingsObject
    ]

    UserProfileSettings class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    UserProfileSettings class >> postLoad: aParcel [
	<category: 'parcel load/unload'>
	self initialize
    ]

    settings [
	<category: 'accessing'>
	^settings
    ]

    settings: aValue [
	<category: 'accessing'>
	settings := aValue
    ]

    settingAt: aSymbol [
	<category: 'api'>
	^self settings at: aSymbol ifAbsent: ['']
    ]

    settingFor: aSymbol put: aValue [
	<category: 'api'>
	^self settings at: aSymbol put: aValue
    ]

    initialize [
	<category: 'initialize-release'>
	self settings: IdentityDictionary new.
	self settings at: #tmpDir put: (Smalltalk getenv: 'TEMP').
	self settings at: #mailer put: 'SMTPClient'.
	self settings at: #bufferSize put: '16'.
	self settings at: #proxyList put: 'none'.
	self settings at: #mailAddress put: nil.
	self settings at: #mailServer put: nil.
	self settings at: #signature put: nil.
	self settings at: #hostKey put: ''.
	self settings at: #portKey put: '80'
    ]
]



Eval [
    UserProfileSettings initialize
]

PK
     �Mh@���㖋 ��   MIME.stUT	 dqXOǉXOux �  �  "======================================================================
|
|   MIME support
|
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2000 Cincom, Inc.
| Copyright (c) 2009 Free Software Foundation
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



Namespace current: NetClients.MIME [

Object subclass: MessageElement [
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    MessageElement class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    MessageElement class >> fromLine: aString [
	"For compatibility with Swazoo"

	<category: 'parsing'>
	self subclassResponsibility
    ]

    MessageElement class >> readFrom: aStream [
	"Each message element has responsibility to read itself from input stream. Reading usually involves parsing, so implementations of this method create an instance of lexical scanner and invoke a parser (see explanation for parse: method)"

	<category: 'parsing'>
	self subclassResponsibility
    ]

    MessageElement class >> readFromClient: aStream [
	"This just parses a RFC821 message (with dots before each line)"

	<category: 'parsing'>
	^self readFrom: (RemoveDotStream on: aStream)
    ]

    MessageElement class >> scannerOn: aStream [
	<category: 'parsing'>
	^((aStream respondsTo: #isRFC822Scanner) 
	    and: [aStream respondsTo: #isRFC822Scanner]) 
		ifTrue: [aStream]
		ifFalse: [self scannerType on: aStream]
    ]

    MessageElement class >> scannerType [
	<category: 'parsing'>
	self subclassResponsibility
    ]

    canonicalValue [
	"Canonical value of an item represents its external representation as required by relevant protocols. Usually an element has to be converted to a cannonical representation before it can be sent over the network. This is a requirement of RFC822 and MIME. Canonical representation removes all whitespace between adjacent tokens"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    value [
	"Answers current value of the item. For structured elements (i.e. structured header fields) this value may be different for the source value read from source stream. For unstructured elements source and value are the same"

	<category: 'accessing'>
	^self source
    ]

    value: aValue [
	<category: 'accessing'>
	self source: aValue
    ]

    parse: scanner [
	"Each message element has responsibility to parse itself. The argument is an appropriate scanner. Scanners for RFC822, Mime and HTTP messages are stream wrappers, so they can be used to read and tokenize input stream"

	<category: 'parsing'>
	self subclassResponsibility
    ]

    readFrom: aStream [
	"Each message element has responsibility to read itself from input stream. Reading usually involves parsing, so implementations of this method typically create an instance of lexical scanner and invoke a parser (see explanation for parse: method)"

	<category: 'parsing'>
	self subclassResponsibility
    ]

    readFromClient: aStream [
	"This just parses a RFC821 message (with dots before each line)"

	<category: 'parsing'>
	^self readFrom: (RemoveDotStream on: aStream)
    ]

    scannerOn: aStream [
	"Each element should know what the underlying syntax is. For example, structured fields would mostly use MIME syntax and tokenize input streams into MIME 'tokens' while <address-spec> which is part of many standards, has to be tokenized using RFC822 syntax (using RFC822 'atoms')"

	<category: 'parsing'>
	^self class scannerOn: aStream
    ]

    printOn: aStream [
	<category: 'printing'>
	self subclassResponsibility
    ]

    storeOn: aStream [
	<category: 'printing'>
	self printOn: aStream
    ]

    initialize [
	<category: 'private-initialize'>
	
    ]

    valueFrom: aString [
	"Swazoo compatibility"

	<category: 'private-initialize'>
	^self readFrom: aString readStream
    ]
]

]



Namespace current: NetClients.MIME [

Object subclass: SimpleScanner [
    | source hereChar token tokenType saveComments currentComment classificationMask sourceTrailStream lookahead |
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    SimpleScanner class [
	| classificationTable |
	
    ]

    Lf := nil.
    AlphabeticMask := nil.
    EndOfLineMask := nil.
    CRLF := nil.
    NilMask := nil.
    CRLFMask := nil.
    WhiteSpaceMask := nil.
    Cr := nil.
    DigitMask := nil.

    SimpleScanner class >> classificationTable [
	<category: 'accessing'>
	^classificationTable isNil 
	    ifTrue: [self superclass classificationTable]
	    ifFalse: [classificationTable]
    ]

    SimpleScanner class >> classificationTable: aValue [
	<category: 'accessing'>
	classificationTable := aValue
    ]

    SimpleScanner class >> cr [
	<category: 'accessing'>
	^Cr
    ]

    SimpleScanner class >> crlf [
	<category: 'accessing'>
	^CRLF
    ]

    SimpleScanner class >> lf [
	<category: 'accessing'>
	^Lf
    ]

    SimpleScanner class >> whiteSpace [
	<category: 'character classification'>
	^String with: Character space with: Character tab
    ]

    SimpleScanner class >> initClassificationTable [
	<category: 'class initialization'>
	classificationTable := WordArray new: 256.
	self initClassificationTableWith: AlphabeticMask
	    when: [:c | ($a <= c and: [c <= $z]) or: [$A <= c and: [c <= $Z]]].
	self initClassificationTableWith: DigitMask
	    when: [:c | c >= $0 and: [c <= $9]].
	self initClassificationTableWith: WhiteSpaceMask
	    when: 
		[:c | 
		"space"

		"tab"

		#(32 9) includes: c asInteger].
	self initClassificationTableWith: CRLFMask
	    when: [:c | c == Character cr or: [c == Character nl]].
	"self initClassificationTableWith: EndOfLineMask
	    when: [:c | c == Character cr]"
    ]

    SimpleScanner class >> initClassificationTableWith: mask when: aBlock [
	"Set the mask in all entries of the classificationTable for which
	 aBlock answers true."

	<category: 'class initialization'>
	0 to: classificationTable size - 1
	    do: 
		[:i | 
		(aBlock value: (Character value: i)) 
		    ifTrue: 
			[classificationTable at: i + 1
			    put: ((classificationTable at: i + 1) bitOr: mask)]]
    ]

    SimpleScanner class >> initialize [
	"SimpleScanner initialize"

	<category: 'class initialization'>
	self
	    initializeConstants;
	    initClassificationTable
    ]

    SimpleScanner class >> initializeConstants [
	<category: 'class initialization'>
	AlphabeticMask := 1.
	DigitMask := 2.
	WhiteSpaceMask := 4.
	CRLFMask := 8.
	EndOfLineMask := 16.
	NilMask := 0.
	Cr := Character cr.
	Lf := Character nl.
	CRLF := Array with: Character cr with: Character nl
    ]

    SimpleScanner class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    SimpleScanner class >> on: stream [
	<category: 'instance creation'>
	^self new on: stream
    ]

    SimpleScanner class >> defaultTokenType [
	<category: 'printing'>
	self subclassResponsibility
    ]

    SimpleScanner class >> printToken: assocOrValue on: stream [
	<category: 'printing'>
	| tokenType token |
	(assocOrValue isKindOf: Association) 
	    ifTrue: 
		[tokenType := assocOrValue key.
		token := assocOrValue value]
	    ifFalse: 
		[tokenType := self defaultTokenType.
		token := assocOrValue].
	self 
	    printToken: token
	    tokenType: tokenType
	    on: stream
    ]

    SimpleScanner class >> printToken: value tokenType: aSymbol on: stream [
	<category: 'printing'>
	self subclassResponsibility
    ]

    classificationMask [
	<category: 'accessing'>
	^classificationMask
    ]

    currentComment [
	<category: 'accessing'>
	^currentComment
    ]

    hereChar [
	<category: 'accessing'>
	^hereChar
    ]

    hereChar: char [
	<category: 'accessing'>
	hereChar := char.
	classificationMask := self classificationMaskFor: hereChar.
	lookahead := nil.
	^hereChar
    ]

    saveComments [
	<category: 'accessing'>
	^saveComments
    ]

    saveComments: aValue [
	<category: 'accessing'>
	saveComments := aValue
    ]

    token [
	<category: 'accessing'>
	^token
    ]

    tokenType [
	<category: 'accessing'>
	^tokenType
    ]

    expected: aString [
	"Notify that there is a problem at current token."

	<category: 'error handling'>
	^self notify: 'expected `%1''' % {aString}
    ]

    notify: string [
	"Subclasses may wish to override this"

	<category: 'error handling'>
	self error: string
    ]

    offEnd: aString [
	"Parser overrides this"

	<category: 'error handling'>
	^self notify: aString
    ]

    classificationMaskFor: charOrNil [
	<category: 'expression types'>
	^charOrNil isNil 
	    ifTrue: [NilMask]
	    ifFalse: [^self class classificationTable at: charOrNil asInteger + 1]
    ]

    matchCharacterType: mask [
	<category: 'expression types'>
	^self classificationMask anyMask: mask
    ]

    mustMatch: char [
	<category: 'expression types'>
	^self mustMatch: char notify: [self expected: (String with: char)]
    ]

    mustMatch: char notify: message [
	<category: 'expression types'>
	self skipWhiteSpace.
	self next == char ifFalse: [self notify: message]
    ]

    scanTokenMask: tokenMask [
	"Scan token based on character mask. Answers token's value. Stream is positioned before the character that terminated scan"

	<category: 'expression types'>
	^self scanWhile: [self matchCharacterType: tokenMask]
    ]

    scanUntil: aNiladicBlock [
	"Scan token using a block until match is found. At the end of scan the stream is positioned after the
	 matching character. Answers token value"

	<category: 'expression types'>
	| stream |
	stream := (String new: 40) writeStream.
	
	[self atEnd 
	    ifTrue: 
		[self hereChar: nil.
		^stream contents].
	self step.
	aNiladicBlock value] 
		whileFalse: [stream nextPut: hereChar].
	^stream contents
    ]

    scanWhile: aNiladicBlock [
	"Scan token using a block. At the end of scan the stream is positioned at the first character that does not match. hereChar is nil. Answers token value"

	<category: 'expression types'>
	| str |
	str := self scanUntil: [aNiladicBlock value not].
	hereChar notNil ifTrue: [self stepBack].
	^str
    ]

    step [
	<category: 'expression types'>
	^self next
    ]

    stepBack [
	<category: 'expression types'>
	lookahead isNil ifFalse: [self error: 'cannot step back twice'].
	self sourceTrailSkip: -1.
	lookahead := hereChar.
	hereChar := nil
    ]

    initialize [
	<category: 'initialize-release'>
	saveComments := true.
	self hereChar: nil
    ]

    on: inputStream [
	"Bind the input stream"

	<category: 'initialize-release'>
	self hereChar: nil.
	source := inputStream
    ]

    scan: inputStream [
	"Bind the input stream, fill the character buffers and first token buffer"

	<category: 'initialize-release'>
	self on: inputStream.
	^self nextToken
    ]

    skipWhiteSpace [
	"It is inefficient because intermediate stream is created. Perhaps refactoring scanWhile: can help"

	<category: 'multi-character scans'>
	self scanWhile: [self matchCharacterType: WhiteSpaceMask]
    ]

    printToken: assoc on: stream [
	<category: 'printing'>
	self class printToken: assoc on: stream
    ]

    printToken: value tokenType: aSymbol on: stream [
	<category: 'printing'>
	self class 
	    printToken: value
	    tokenType: aSymbol
	    on: stream
    ]

    resetToken [
	<category: 'private'>
	token := tokenType := nil
    ]

    sourceTrail [
	<category: 'source trail'>
	| res |
	sourceTrailStream notNil ifTrue: [res := sourceTrailStream contents].
	sourceTrailStream := nil.
	^res
    ]

    sourceTrailNextPut: char [
	<category: 'source trail'>
	(sourceTrailStream notNil and: [char notNil]) 
	    ifTrue: [sourceTrailStream nextPut: char]
    ]

    sourceTrailNextPutAll: string [
	<category: 'source trail'>
	(sourceTrailStream notNil and: [string notNil]) 
	    ifTrue: [sourceTrailStream nextPutAll: string]
    ]

    sourceTrailOff [
	<category: 'source trail'>
	sourceTrailStream := nil
    ]

    sourceTrailOn [
	<category: 'source trail'>
	sourceTrailStream := (String new: 64) writeStream
    ]

    sourceTrailSkip: integer [
	<category: 'source trail'>
	sourceTrailStream notNil ifTrue: [sourceTrailStream skip: integer]
    ]

    atEnd [
	<category: 'stream interface -- reading'>
	^lookahead isNil and: [source atEnd]
    ]

    contents [
	<category: 'stream interface -- reading'>
	| contents |
	contents := source contents lookahead notNil 
		    ifTrue: 
			[contents := (contents species with: lookahead) , contents.
			lookahead := nil].
	^contents
    ]

    next [
	<category: 'stream interface -- reading'>
	self hereChar: self peek.
	self sourceTrailNextPut: hereChar.
	lookahead := nil.
	^hereChar
    ]

    next: anInteger [
	"Answer the next anInteger elements of the receiver."

	<category: 'stream interface -- reading'>
	| newCollection res |
	newCollection := self species new: anInteger.
	res := self 
		    next: anInteger
		    into: newCollection
		    startingAt: 1.
	self sourceTrailNextPutAll: res.
	^res
    ]

    next: anInteger into: aSequenceableCollection startingAt: startIndex [
	"Store the next anInteger elements of the receiver into aSequenceableCollection
	 starting at startIndex in aSequenceableCollection. Answer aSequenceableCollection."

	<category: 'stream interface -- reading'>
	| index stopIndex |
	index := startIndex.
	stopIndex := index + anInteger.
	(lookahead notNil and: [anInteger > 0]) 
	    ifTrue: 
		[aSequenceableCollection at: index put: lookahead.
		index := index + 1.
		lookahead := nil].
	anInteger > 0 ifTrue: [self hereChar: nil].
	[index < stopIndex] whileTrue: 
		[aSequenceableCollection at: index put: source next.
		index := index + 1].
	^aSequenceableCollection
    ]

    nextLine [
	<category: 'stream interface -- reading'>
	| line |
	line := self scanUntil: [self matchCharacterType: CRLFMask].
	self scanWhile: [self matchCharacterType: CRLFMask].
	^line
    ]

    peek [
	"Answer what would be returned with a self next, without
	 changing position.  If the receiver is at the end, answer nil."

	<category: 'stream interface -- reading'>
	lookahead notNil ifTrue: [^lookahead].
	self atEnd ifTrue: [^nil].
	hereChar := nil.
	lookahead := source next.
	^lookahead
    ]

    peekFor: anObject [
	"Answer false and do not move the position if self next ~= anObject or if the
	 receiver is at the end. Answer true and increment position if self next = anObject."

	"This sets lookahead"

	<category: 'stream interface -- reading'>
	self peek isNil ifTrue: [^false].

	"peek for matching element"
	anObject = lookahead 
	    ifTrue: 
		[self next.
		^true].
	^false
    ]

    position [
	<category: 'stream interface -- reading'>
	^source position - (lookahead isNil ifTrue: [0] ifFalse: [1])
    ]

    position: anInt [
	<category: 'stream interface -- reading'>
	lookahead := nil.
	^source position: anInt
    ]

    skip: integer [
	<category: 'stream interface -- reading'>
	self sourceTrailSkip: integer.
	lookahead isNil 
	    ifFalse: 
		[lookahead := nil.
		source skip: integer - 1]
	    ifTrue: [source skip: integer]
    ]

    species [
	<category: 'stream interface -- reading'>
	^source species
    ]

    upTo: anObject [
	"Answer a subcollection from position to the occurrence (if any, exclusive) of anObject.
	 The stream is left positioned after anObject.
	 If anObject is not found answer everything."

	<category: 'stream interface -- reading'>
	| str |
	lookahead = anObject 
	    ifTrue: 
		[self sourceTrailNextPut: lookahead.
		lookahead := nil.
		^''].
	str := source upTo: anObject.
	lookahead isNil 
	    ifFalse: 
		[str := lookahead asString , str.
		lookahead := nil].
	self
	    sourceTrailNextPutAll: str;
	    sourceTrailNextPut: anObject.
	^str
    ]

    upToAll: pattern [
	<category: 'stream interface -- reading'>
	| str |
	lookahead isNil 
	    ifFalse: 
		[source skip: -1.
		lookahead := nil].
	str := source upToAll: pattern.
	self
	    sourceTrailNextPutAll: str;
	    sourceTrailNextPutAll: pattern.
	^str
    ]

    upToEnd [
	<category: 'stream interface -- reading'>
	| str |
	str := source upToEnd.
	lookahead isNil 
	    ifFalse: 
		[str := lookahead asString , str.
		lookahead := nil].
	self sourceTrailNextPutAll: str.
	^str
    ]

    testScanTokens [
	<category: 'sunit test helpers'>
	| s st |
	s := WriteStream on: (Array new: 16).
	st := WriteStream on: (Array new: 16).
	[tokenType = #doIt] whileFalse: 
		[s nextPut: token.
		st nextPut: tokenType.
		self nextToken].
	^Array with: s contents with: st contents
    ]

    testScanTokens: textOrString [
	"Answer with an Array which has been tokenized"

	<category: 'sunit test helpers'>
	self scan: (ReadStream on: textOrString asString).
	^self testScanTokens
    ]

    nextToken [
	<category: 'tokenization'>
	self subclassResponsibility
    ]

    nextTokenAsAssociation [
	"Read next token and and answer tokenType->token"

	<category: 'tokenization'>
	self nextToken.
	^tokenType -> token
    ]

    scanToken: aNiladicBlock delimitedBy: anArray notify: errorMessageString [
	"Scan next lexical token based on the criteria defined by NiladicBlock. The block is evaluated for every character read from input stream until it yields false. Stream is positioned before character that terminated scan"

	"Example: self scanToken: [ self scanQuotedChar; matchCharacterType: DomainTextMask ]
	 delimitedBy: '[]' notify: 'Malformed domain text'."

	<category: 'tokenization'>
	| string |
	self mustMatch: anArray first.
	string := self scanWhile: aNiladicBlock.
	self mustMatch: anArray last notify: errorMessageString.
	^string
    ]

    scanTokens: textOrString [
	"Answer with an Array which has been tokenized"

	<category: 'tokenization'>
	^self
	    on: (ReadStream on: textOrString asString);
	    tokenize
    ]

    tokenize [
	<category: 'tokenization'>
	| s |
	s := WriteStream on: (Array new: 16).
	
	[self nextToken.
	tokenType = #doIt] whileFalse: [s nextPut: token].
	^s contents
    ]

    tokenizeList: aBlock separatedBy: comparisonBlock [
	"list = token *( separator token)"

	<category: 'tokenization'>
	| stream block |
	stream := (Array new: 4) writeStream.
	block := [stream nextPut: aBlock value].
	block value.	"Evaluate for the first element"
	self tokenizeWhile: [comparisonBlock value] do: block.
	^stream contents
    ]

    tokenizeUntil: aBlock do: actionBlock [
	<category: 'tokenization'>
	
	[self skipWhiteSpace.
	self position.
	self nextToken.
	tokenType == #doIt or: aBlock] 
		whileFalse: [actionBlock value]
    ]

    tokenizeWhile: aBlock [
	<category: 'tokenization'>
	| s |
	s := WriteStream on: (Array new: 16).
	self tokenizeWhile: [aBlock value] do: [s nextPut: token].
	^s contents
    ]

    tokenizeWhile: aBlock do: actionBlock [
	<category: 'tokenization'>
	| pos |
	
	[self skipWhiteSpace.
	pos := self position.
	self nextToken.
	tokenType ~= #doIt & aBlock value	"#######"] 
		whileTrue: [actionBlock value].
	self position: pos	"Reset position to the beginning of the token that did not match"
    ]
]

]



Namespace current: NetClients.MIME [

MessageElement subclass: MimeEntity [
    | parent fields body |
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    MimeEntity class >> contentLengthFieldName [
	<category: 'constants'>
	^'content-length'
    ]

    MimeEntity class >> contentTypeFieldName [
	<category: 'constants'>
	^'content-type'
    ]

    MimeEntity class >> syntaxOfMultiPartMimeBodies [
	"From RFC 2046: Media Types                  November 1996
	 
	 The Content-Type field for multipart entities requires one parameter,
	 'boundary'. The boundary delimiter line is then defined as a line
	 consisting entirely of two hyphen characters ($-, decimal value 45)
	 followed by the boundary parameter value from the Content-Type header
	 field, optional linear whitespace, and a terminating CRLF.
	 
	 WARNING TO IMPLEMENTORS:  The grammar for parameters on the Content-
	 type field is such that it is often necessary to enclose the boundary
	 parameter values in quotes on the Content-type line.  This is not
	 always necessary, but never hurts. Implementors should be sure to
	 study the grammar carefully in order to avoid producing invalid
	 Content-type fields.  Thus, a typical 'multipart' Content-Type header
	 field might look like this:
	 
	 Content-Type: multipart/mixed; boundary=gc0p4Jq0M2Yt08j34c0p
	 
	 But the following is not valid:
	 
	 Content-Type: multipart/mixed; boundary=gc0pJq0M:08jU534c0p
	 
	 (because of the colon) and must instead be represented as
	 
	 Content-Type: multipart/mixed; boundary="

	"gc0pJq0M:08jU534c0p"

	"
	 
	 This Content-Type value indicates that the content consists of one or
	 more parts, each with a structure that is syntactically identical to
	 an RFC 822 message, except that the header area is allowed to be
	 completely empty, and that the parts are each preceded by the line
	 
	 --gc0pJq0M:08jU534c0p
	 
	 The boundary delimiter MUST occur at the beginning of a line, i.e.,
	 following a CRLF, and the initial CRLF is considered to be attached
	 to the boundary delimiter line rather than part of the preceding
	 part.  The boundary may be followed by zero or more characters of
	 linear whitespace. It is then terminated by either another CRLF and
	 the header fields for the next part, or by two CRLFs, in which case
	 there are no header fields for the next part.  If no Content-Type
	 field is present it is assumed to be 'message/rfc822' in a
	 'multipart/digest' and 'text/plain' otherwise.
	 
	 NOTE:  The CRLF preceding the boundary delimiter line is conceptually
	 attached to the boundary so that it is possible to have a part that
	 does not end with a CRLF (line  break).  Body parts that must be
	 considered to end with line breaks, therefore, must have two CRLFs
	 preceding the boundary delimiter line, the first of which is part of
	 the preceding body part, and the second of which is part of the
	 encapsulation boundary."

	<category: 'documentation'>
	
    ]

    MimeEntity class >> headerTypeFor: headerName [
	<category: 'parsing'>
	^HeaderField	"For now"
    ]

    MimeEntity class >> parser [
	<category: 'parsing'>
	^self scannerType new
    ]

    MimeEntity class >> parseFieldsFrom: stream [
	<category: 'parsing'>
	^self new parseFieldsFrom: (self parser on: stream)
    ]

    MimeEntity class >> readFrom: stream [
	<category: 'parsing'>
	^self new readFrom: (self parser on: stream)
    ]

    MimeEntity class >> readFrom: stream defaultType: type [
	<category: 'parsing'>
	^(self new)
	    fieldAt: 'content-type'
		put: (ContentTypeField fromLine: 'content-type: ' , type);
	    readFrom: (self parser on: stream);
	    yourself
    ]

    MimeEntity class >> readFrom: stream type: type [
	<category: 'parsing'>
	('message/*' match: type) ifTrue: [^self readFrom: stream].
	^(self new)
	    fieldAt: 'content-type'
		put: (ContentTypeField fromLine: 'content-type: ' , type);
	    parseBodyFrom: (self parser on: stream);
	    yourself
    ]

    MimeEntity class >> scannerType [
	<category: 'parsing'>
	^MimeScanner
    ]

    bcc [
	<category: 'accessing'>
	^self fieldAt: 'bcc'
    ]

    body [
	<category: 'accessing'>
	^body
    ]

    body: aValue [
	<category: 'accessing'>
	body := aValue
    ]

    boundary [
	<category: 'accessing'>
	^self contentTypeField boundary
    ]

    cc [
	<category: 'accessing'>
	^self fieldAt: 'cc'
    ]

    charset [
	<category: 'accessing'>
	^self contentTypeField charset
    ]

    contents [
	<category: 'accessing'>
	| handler |
	handler := ContentHandler classFor: self contentType.
	^(handler on: self body readStream) contents
    ]

    contentId [
	<category: 'accessing'>
	^(self fieldAt: 'content-id' ifAbsent: [^nil]) id
    ]

    contentType [
	<category: 'accessing'>
	^self contentTypeField contentType
    ]

    contentTypeField [
	<category: 'accessing'>
	^self fieldAt: 'content-type' ifAbsent: [self defaultContentTypeField]
    ]

    fields [
	<category: 'accessing'>
	^fields
    ]

    fields: aValue [
	<category: 'accessing'>
	fields := aValue
    ]

    from [
	<category: 'accessing'>
	^self fieldAt: 'from'
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: aMimeEntity [
	<category: 'accessing'>
	parent := aMimeEntity
    ]

    recipients [
	<category: 'accessing'>
	| recipients |
	recipients := #().
	self to isNil ifFalse: [recipients := recipients , self to addresses].
	self cc isNil ifFalse: [recipients := recipients , self cc addresses].
	self bcc isNil ifFalse: [recipients := recipients , self bcc addresses].
	^recipients
    ]

    replyTo [
	<category: 'accessing'>
	^self fieldAt: 'reply-to'
    ]

    sender [
	<category: 'accessing'>
	^self fieldAt: 'sender' ifAbsent: [self fieldAt: 'from']
    ]

    subject [
	<category: 'accessing'>
	^self fieldAt: 'subject'
    ]

    subtype [
	<category: 'accessing'>
	^self contentTypeField subtype
    ]

    to [
	<category: 'accessing'>
	^self fieldAt: 'to'
    ]

    type [
	<category: 'accessing'>
	^self contentTypeField type
    ]

    addField: field [
	"This method will check if the field exists already; if yes, if it can be merged into the existing field and, if yes, merge it. Otherwise, add as a new field"

	"Implement field merge"

	<category: 'accessing fields and body parts'>
	^self fieldAt: field name put: field
    ]

    bodyPartAt: index [
	<category: 'accessing fields and body parts'>
	^self body at: index
    ]

    bodyPartNamed: id [
	<category: 'accessing fields and body parts'>
	^self isMultipart 
	    ifTrue: [self body detect: [:part | part contentId = id]]
	    ifFalse: [nil]
    ]

    fieldAt: aString [
	<category: 'accessing fields and body parts'>
	^self fieldAt: aString asLowercase ifAbsent: [nil]
    ]

    fieldAt: aString ifAbsent: aNiladicBlock [
	<category: 'accessing fields and body parts'>
	^self fields at: aString asLowercase ifAbsent: aNiladicBlock
    ]

    fieldAt: aString ifAbsentPut: aNiladicBlock [
	<category: 'accessing fields and body parts'>
	^self fields at: aString asLowercase ifAbsentPut: aNiladicBlock
    ]

    fieldAt: aString put: aHeaderField [
	<category: 'accessing fields and body parts'>
	^self fields at: aString asLowercase put: aHeaderField
    ]

    asByteArray [
	<category: 'converting'>
	
    ]

    asStream [
	<category: 'converting'>
	
    ]

    asString [
	<category: 'converting'>
	
    ]

    asStringOrByteArray [
	<category: 'converting'>
	
    ]

    defaultContentType [
	<category: 'defaults'>
	^self defaultContentTypeField contentType
    ]

    defaultContentTypeField [
	<category: 'defaults'>
	^ContentTypeField default
    ]

    initialize [
	<category: 'initialization'>
	fields := Dictionary new: 4
    ]

    defaultContentTypeForNestedEntities [
	<category: 'parsing'>
	^(self type = 'multipart' and: [self subtype = 'digest']) 
	    ifTrue: ['content-type: message/rfc822']
	    ifFalse: ['text/plain; charset=US-ASCII']
    ]

    fieldFactory [
	"Answers object that can map field name to field type (class). It may and will be subclassed"

	<category: 'parsing'>
	^HeaderField
    ]

    parseBodyFrom: rfc822Stream [
	<category: 'parsing'>
	self isMultipart 
	    ifTrue: [self parseMultipartBodyFrom: rfc822Stream]
	    ifFalse: [self parseSimpleBodyFrom: rfc822Stream]
    ]

    parseFieldFrom: stream [
	<category: 'parsing'>
	| field |
	field := self fieldFactory readFrom: stream.
	self addField: field
    ]

    parseFieldsFrom: rfc822Stream [
	<category: 'parsing'>
	[rfc822Stream atEndOfLine] 
		whileFalse: [self parseFieldFrom: rfc822Stream].
        rfc822Stream next; skipEndOfLine
    ]

    parseMultipartBodyFrom: rfc822Stream [
	"Parse multi-part body. See more in 'documentation' category on the class side"

	<category: 'parsing'>
	| boundary parts partArray |
	(boundary := self boundary) notNil 
	    ifTrue: 
		[parts := (Array new: 2) writeStream.	"Skip to the first boundary, ignore text in between"
		partArray := rfc822Stream scanToBoundary: boundary].
	
	[partArray isNil 
	    ifTrue: [^self error: 'Missing boundary in multi-part body'].
	partArray := rfc822Stream scanToBoundary: boundary.
	partArray notNil ifTrue: [parts nextPut: partArray first].
	partArray notNil and: [partArray last ~~ #last]] 
		whileTrue.
	self 
	    body: (parts contents collect: 
			[:part | 
			MimeEntity readFrom: part readStream
			    defaultType: self defaultContentTypeForNestedEntities])
    ]

    parseSimpleBodyFrom: rfc822Stream [
	<category: 'parsing'>
	| stream |
	stream := (String new: 256) writeStream.
	self parseSimpleBodyFrom: rfc822Stream onto: stream.
	self body: stream contents
    ]

    parseSimpleBodyFrom: rfc822Stream onto: stream [
	<category: 'parsing'>
	| inStream |
	inStream := RemoveDotStream on: rfc822Stream.
	[inStream atEnd] whileFalse: 
		[stream
		    nextPutAll: inStream nextLine;
		    nl]
    ]

    readFrom: rfc822Stream [
	<category: 'parsing'>
	self parseFieldsFrom: rfc822Stream.
	self parseBodyFrom: rfc822Stream
    ]

    skipSimpleBodyFrom: rfc822Stream onto: stream [
	<category: 'parsing'>
	| inStream |
	inStream := RemoveDotStream on: rfc822Stream.
	[inStream atEnd] whileFalse: [inStream nextLine]
    ]

    printBodyOn: aStream [
	<category: 'printing'>
	self body isNil ifTrue: [^self].
	self body class == Array 
	    ifFalse: 
		[aStream nextPutAll: self body.
		^self].
	aStream nextPutAll: 'This is a MIME message.

'.
	self body do: 
		[:each | 
		aStream
		    nextPutAll: '--';
		    nextPutAll: self boundary.
		each printOn: aStream].
	aStream
	    nextPutAll: '--';
	    nextPutAll: self boundary;
	    nextPutAll: '--'
    ]

    printBodyOnClient: aClient [
	<category: 'printing'>
	| out |
	out := PrependDotStream to: aClient.
	self printBodyOn: out.
	out flush
    ]

    printHeaderOn: aStream [
	<category: 'printing'>
	self fields do: 
		[:each | 
		aStream
		    print: each;
		    nl]
    ]

    printHeaderOnClient: aClient [
	<category: 'printing'>
	| out |
	out := PrependDotStream to: aClient.
	self printHeaderOn: out.
	out flush
    ]

    printMessageOn: aStream [
	<category: 'printing'>
	self printHeaderOn: aStream.
	aStream nl.
	self printBodyOn: aStream
    ]

    printMessageOnClient: aClient [
	<category: 'printing'>
	| out |
	out := PrependDotStream to: aClient.
	self printMessageOn: out.
	out flush
    ]

    printOn: aStream [
	<category: 'printing'>
	self printMessageOn: aStream
    ]

    hasBoundary [
	<category: 'testing'>
	^(self fieldAt: 'boundary') notNil
    ]

    isMultipart [
	<category: 'testing'>
	^self contentTypeField isMultipart
    ]
]

]



Namespace current: NetClients.MIME [

MessageElement subclass: NetworkEntityDescriptor [
    | alias comment |
    
    <category: 'NetClients-MIME'>
    <comment: 'I am an abstract superclass for RFC822 mailbox and group descriptors. Each of these can have an associated alias (name) and comment 

Instance Variables:
    alias    <?type?>  comment
    comment    <?type?>  comment
'>

    NetworkEntityDescriptor class >> scannerType [
	<category: 'parsing'>
	^NetworkAddressParser
    ]

    alias [
	<category: 'accessing'>
	^alias
    ]

    alias: aValue [
	<category: 'accessing'>
	alias := aValue
    ]

    comment [
	<category: 'accessing'>
	^comment
    ]

    comment: aValue [
	<category: 'accessing'>
	comment := aValue
    ]

    scannerType [
	<category: 'parsing'>
	^self class scannerType
    ]

    printAliasOn: stream [
	<category: 'priniting'>
	alias notNil ifTrue: [stream nextPutAll: alias]
    ]

    printCanonicalValueOn: stream [
	<category: 'priniting'>
	self subclassResponsibility
    ]

    printCommentOn: stream [
	<category: 'priniting'>
	comment notNil 
	    ifTrue: 
		[stream nextPut: $(.
		comment do: 
			[:char | 
			(RFC822Scanner isCommentChar: char) ifFalse: [stream nextPut: $\].
			stream nextPut: char].
		stream nextPut: $)]
    ]

    printOn: stream [
	<category: 'priniting'>
	self printCanonicalValueOn: stream.
	comment notNil ifTrue: [self printCommentOn: stream]
    ]
]

]



Namespace current: NetClients.MIME [

MessageElement subclass: HeaderField [
    | name source |
    
    <category: 'NetClients-MIME'>
    <comment: 'This is base class for all header fields. Each header field has a name and a value. Each field also has the following responsibility:
    Represent its value; being able to answer and receive a value.
    Read its value from a (positionable) stream (parsing). Field''s value is terminated by new line (subject to line folding). There is no requirement now that field''s value terminates ate the end of the stream.
    Write its contents on a stream (composition)

When reading itself from a stream, the field will store its source. When this field is written on a stream and there is source already available, this source will be written instead of parsed field''s value. The reasoning is that all standards strongly discourage making any alterations to the fields if a message is being forwarded, resent, proxied, etc. Parsing and subsequent composition can change many aspects of a field such as, replace multiple spaces with a single space, removing nonessential white spece altogether, changing the order of the values, etc. So if a source is available, it is trusted more than the parsed value for writing on a stream. This necessitates resetting source to nil when any of the field''s aspects is modified. All setters should send change notification so that it is done transparently

This class can be used to parse/compose all nonstructured fields. For unstructured fields field''s value and source are the same, so #value answers source. Specific subclasses add more specific processing for field''s value, so they override methods #value, #value:.

Message parsing: Each field is responsible for knowing its underlying grammar. This included both lexical and grammar rules. Therefore, each subclass implements methods #scannerType and #parserOn: <stream>. These answer scanner class and new instance of parser for a given source stream. Method parse: parses and sets field''s value.

A conventional way of creating new instance of a stream from source field is 
    HeaderField readFrom: stream

This reads field''s name, find an appropriate field class for this name, creates an instance of this field and lets it read/parse field''s value.

Instance Variables:
    name    <String>  comment
    source    <String>  comment
'>

    HeaderField class >> name: aname [
	"Answer new instance of field corresponding to field's name. For now, treat all fields as unstructured"

	<category: 'instance creation'>
	^((self fieldClassForName: aname) new)
	    name: aname;
	    yourself
    ]

    HeaderField class >> defaultFieldClass [
	<category: 'parsing'>
	^HeaderField
    ]

    HeaderField class >> fieldClassForName: fieldName [
	"For now we scan all subclasses. Later I plan to use registry which is somewhat more flexible, especially if different protocols can have different formats for the same field"

	<category: 'parsing'>
	| fname |
	fname := fieldName asLowercase.
	^HeaderField allSubclasses detect: 
		[:each | 
		(each fieldNames detect: [:candidate | candidate asLowercase = fname]
		    ifNone: [nil]) notNil]
	    ifNone: [self defaultFieldClass]
    ]

    HeaderField class >> fieldNames [
	<category: 'parsing'>
	^#()
    ]

    HeaderField class >> fromLine: aString [
	"For compatibility with Swazoo"

	<category: 'parsing'>
	| rfc822Stream |
	rfc822Stream := self scannerOn: aString readStream.
	^(self name: (self readFieldNameFrom: rfc822Stream))
	    readFrom: rfc822Stream;
	    yourself
    ]

    HeaderField class >> readFieldNameFrom: rfc822Stream [
	<category: 'parsing'>
	| fname |
	fname := rfc822Stream scanFieldName.
	rfc822Stream mustMatch: $: notify: 'Invalid Field (Missing colon)'.
	rfc822Stream skipWhiteSpace.
	^fname asLowercase
    ]

    HeaderField class >> readFrom: rfc822Stream [
	"Reads and parses message header contents from the message stream; answers an instance of message header. rfc822Stream is RFC822MessageParser; it extends stream interface by providing message scanning/parsing services. At this point the stream is positioned right after semicolon that delimits header name"

	<category: 'parsing'>
	^(self name: (self readFieldNameFrom: rfc822Stream)) 
	    readFrom: rfc822Stream
    ]

    HeaderField class >> scannerType [
	<category: 'parsing'>
	^MimeScanner
    ]

    canonicalFieldName [
	<category: 'accessing'>
	| s |
	s := name copy.
	s isEmpty ifTrue: [^s].
	s at: 1 put: s first asUppercase.	"Capitalize first letter"
	^s
    ]

    canonicalValue [
	"Override as necessary"

	<category: 'accessing'>
	^self value
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aString [
	<category: 'accessing'>
	^name := aString
    ]

    source [
	<category: 'accessing'>
	^source
    ]

    source: anObject [
	<category: 'accessing'>
	source := anObject
    ]

    value [
	<category: 'accessing'>
	^self source
    ]

    value: aValue [
	<category: 'accessing'>
	self source: aValue
    ]

    parse: rfc822Stream [
	"Generic parser for unstructured fields. Copy everything up to CRLF. Scanner handles end of line rules and answers cr when end of line is seen. Scanner also folds linear white space answering space character in place of <CRLF space+>"

	<category: 'parsing'>
	self value: rfc822Stream nextLine
    ]

    readFrom: aStream [
	<category: 'parsing'>
	self source: aStream scanText.
	^self parse: (self scannerOn: self source readStream)
    ]

    printOn: aStream [
	<category: 'printing'>
	self printOn: aStream indent: 0
    ]

    printOn: aStream indent: level [
	<category: 'printing'>
	aStream
	    tab: level;
	    nextPutAll: self canonicalFieldName;
	    nextPut: $:;
	    space.
	self printValueOn: aStream
    ]

    printStructureOn: aStream [
	"Unstructured fields just print their value on a stream"

	<category: 'printing'>
	self printValueOn: aStream
    ]

    printValueOn: aStream [
	<category: 'printing'>
	| val |
	(val := self value) notNil ifTrue: [val displayOn: aStream]
    ]

    valueFrom: aString [
	"Swazoo compatibility"

	<category: 'private-initialize'>
	^self readFrom: aString readStream
    ]
]

]



Namespace current: NetClients.MIME [

SimpleScanner subclass: MimeEncodedWordCoDec [
    
    <category: 'NetClients-MIME'>
    <comment: 'I am responsible for scanning tokens for the presence of MIME ''encoded words''. MIME uses encoded word to allow non-ascii characters to be used in message headers. Encoded words can occur inside MIME extension fields (ones starting with X-) as well as in field bodies. An encoded word may occur everywhere in the body in place of text'', ''word'', ''comment'' or ''phrase'' token. Encoded word specifies charset, encoding mechanism and encoded text itself'>

    MimeEncodedWordCoDec class >> decode: word [
	<category: 'parsing'>
	^self decode: word using: (self encodingParametersOf: word)
    ]

    MimeEncodedWordCoDec class >> decode: word using: arr [
	<category: 'parsing'>
	^arr notNil 
	    ifTrue: 
		[self 
		    decodeEncodedWord: (arr at: 3)
		    charset: arr first
		    encoding: (arr at: 2)]
	    ifFalse: [word]
    ]

    MimeEncodedWordCoDec class >> decodeComment: commentString [
	<category: 'parsing'>
	^self new decodeComment: commentString
    ]

    MimeEncodedWordCoDec class >> decodePhrase: words [
	"decode phrase word by word; concatenate decoded words and answer concatenated string"

	<category: 'parsing'>
	| output |
	output := (String new: words size) writeStream.
	self decodePhrase: words printOn: output.
	^output contents
    ]

    MimeEncodedWordCoDec class >> decodePhrase: words printOn: stream [
	<category: 'parsing'>
	| params lastParams lastWord |
	lastWord := nil.
	words do: 
		[:word | 
		lastParams := params.
		params := self encodingParametersOf: word.
		(lastWord notNil and: [params isNil or: [lastParams isNil]]) 
		    ifTrue: [stream space].
		stream nextPutAll: (lastWord := self decode: word using: params)]
    ]

    MimeEncodedWordCoDec class >> decodeText: text [
	<category: 'parsing'>
	^self new decodeText: text
    ]

    MimeEncodedWordCoDec class >> encodingParametersOf: word [
	<category: 'parsing'>
	| mark1 mark2 |
	^(word first == $= and: 
		[word last == $= and: 
			[(word at: 2) == $? and: 
				[(word at: word size - 1) == $? and: 
					[(mark1 := word 
						    nextIndexOf: $?
						    from: 3
						    to: word size - 2) > 0 
					    and: 
						[(mark2 := word 
							    nextIndexOf: $?
							    from: mark1 + 1
							    to: word size - 2) > (mark1 + 1)]]]]]) 
	    ifTrue: 
		[Array 
		    with: (word copyFrom: 3 to: mark1 - 1) asLowercase
		    with: (word copyFrom: mark1 + 1 to: mark2 - 1) asLowercase
		    with: (word copyFrom: mark2 + 1 to: word size - 2)]
	    ifFalse: [nil]
    ]

    MimeEncodedWordCoDec class >> decodeEncodedWord: contents charset: charset encoding: encodingString [
	<category: 'text processing'>
	| encoding |
	encoding := encodingString asLowercase.
	(#('b' 'base64') includes: encoding) 
	    ifTrue: 
		[^MimeScanner 
		    decodeBase64From: 1
		    to: contents size
		    in: contents].
	(#('q' 'quoted-printable') includes: encoding) 
	    ifTrue: 
		[^self 
		    decodeQuotedPrintableFrom: 1
		    to: contents size
		    in: contents].
	(#('uue' 'uuencode' 'x-uue' 'x-uuencode') includes: encoding) 
	    ifTrue: 
		[^self 
		    decodeUUEncodedFrom: 1
		    to: contents size
		    in: contents].
	^nil	"Failed to decode"
    ]

    MimeEncodedWordCoDec class >> decodeQuotedPrintableFrom: startIndex to: endIndex in: aString [
	"Decode aString from startIndex to endIndex in quoted-printable."

	<category: 'text processing'>
	| input output char n1 n2 |
	input := ReadStream 
		    on: aString
		    from: startIndex
		    to: endIndex.
	output := (String new: endIndex - startIndex) writeStream.
	[input atEnd] whileFalse: 
		[char := input next.
		$= == char 
		    ifTrue: 
			[('0123456789ABCDEF' includes: (n1 := input next)) 
			    ifTrue: 
				[n2 := input next.
				output nextPut: ((n1 digitValue bitShift: 4) + n2 digitValue) asCharacter]]
		    ifFalse: [output nextPut: char]].
	^output contents
    ]

    MimeEncodedWordCoDec class >> decodeUUEncodedFrom: startIndex to: farEndIndex in: aString [
	"decode aString from startIndex to farEndIndex as uuencode-encoded"

	<category: 'text processing'>
	| endIndex i nl space output data |
	endIndex := farEndIndex - 2.
	
	[endIndex <= startIndex or: 
		[(aString at: endIndex + 1) = $e 
		    and: [(aString at: endIndex + 2) = $n and: [(aString at: endIndex + 3) = $d]]]] 
		whileFalse: [endIndex := endIndex - 1].
	i := (aString 
		    findString: 'begin'
		    startingAt: startIndex
		    ignoreCase: true
		    useWildcards: false) first.
	i = 0 ifTrue: [i := startIndex].
	nl := Character nl.
	space := Character space asInteger.
	output := (data := String new: (endIndex - startIndex) * 3 // 4) 
		    writeStream.
	
	[[i < endIndex and: [(aString at: i) ~= nl]] whileTrue: [i := i + 1].
	i < endIndex] 
		whileTrue: 
		    [| count |
		    count := (aString at: (i := i + 1)) asInteger - space bitAnd: 63.
		    i := i + 1.
		    count = 0 
			ifTrue: [i := endIndex]
			ifFalse: 
			    [[count > 0] whileTrue: 
				    [| m n o p |
				    m := (aString at: i) asInteger - space bitAnd: 63.
				    n := (aString at: i + 1) asInteger - space bitAnd: 63.
				    o := (aString at: i + 2) asInteger - space bitAnd: 63.
				    p := (aString at: i + 3) asInteger - space bitAnd: 63.
				    count >= 1 
					ifTrue: 
					    [output nextPut: (Character value: (m bitShift: 2) + (n bitShift: -4)).
					    count >= 2 
						ifTrue: 
						    [output 
							nextPut: (Character value: ((n bitShift: 4) + (o bitShift: -2) bitAnd: 255)).
						    count >= 3 
							ifTrue: [output nextPut: (Character value: ((o bitShift: 6) + p bitAnd: 255))]]].
				    i := i + 4.
				    count := count - 3]]].
	^data copyFrom: 1 to: output position
    ]

    decode: word [
	<category: 'parsing'>
	^self class decode: word
    ]

    decodeComment: text [
	<category: 'parsing'>
	"First, quick check if we possibly have an encoded word"

	| output word params spaces lastParams lastWord |
	(text indexOfSubCollection: '=?' startingAt: 1) = 0 ifTrue: [^text].	"We suspect there might be an encoded word inside, do the legwork"
	self on: text readStream.
	output := (String new: text size) writeStream.
	spaces := String new.
	params := lastWord := nil.
	
	[lastParams := params.
	self atEnd] whileFalse: 
		    [word := self scanWhile: [(self matchCharacterType: WhiteSpaceMask) not].
		    params := self class encodingParametersOf: word.
		    (lastWord notNil and: [params isNil or: [lastParams isNil]]) 
			ifTrue: [output nextPutAll: spaces].
		    output nextPutAll: (lastWord := self class decode: word using: params).
		    spaces := self scanWhile: [self matchCharacterType: WhiteSpaceMask]].
	^output contents
    ]

    decodePhrase: words [
	<category: 'parsing'>
	^self class decodePhrase: words
    ]

    decodeText: text [
	"Decoding of text is similar to decoding of comment, but RFC2047 requires that an encoded word that appears in in *text token MUST be separated from any adjacent encoded word or text by a linear-white-space"

	<category: 'parsing'>
	"First, quick check if we possibly have an encoded word"

	| output word |
	(text indexOfSubCollection: '=?' startingAt: 1) = 0 ifTrue: [^text].	"We suspect there might be an encoded word inside, do the legwork"
	self on: text readStream.
	output := (String new: text size) writeStream.
	[self atEnd] whileFalse: 
		[word := self scanWhile: [(self matchCharacterType: WhiteSpaceMask) not].
		output
		    nextPutAll: (self decode: word);
		    nextPutAll: (self scanWhile: [self matchCharacterType: WhiteSpaceMask])].
	^output contents
    ]

    encodingParametersOf: word [
	<category: 'parsing'>
	^self class encodingParametersOf: word
    ]
]

]



Namespace current: NetClients.MIME [

SimpleScanner subclass: MailScanner [
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    MailScanner class >> printQuotedText: str on: stream [
	"Print word as either atom or quoted text"

	<category: 'printing'>
	(self shouldBeQuoted: str) 
	    ifTrue: 
		[stream
		    nextPut: $";
		    nextPutAll: str;
		    nextPut: $"]
	    ifFalse: [stream nextPutAll: str]
    ]

    MailScanner class >> printTokenList: list on: stream [
	<category: 'printing'>
	self 
	    printTokenList: list
	    on: stream
	    separatedBy: [stream space]
    ]

    MailScanner class >> printTokenList: list on: stream separatedBy: aBlock [
	<category: 'printing'>
	list do: [:assoc | self printToken: assoc on: stream] separatedBy: aBlock
    ]

    printAtom: atom on: stream [
	<category: 'printing'>
	self class printAtom: atom on: stream
    ]

    printQuotedText: qtext on: stream [
	<category: 'printing'>
	self class printQuotedText: qtext on: stream
    ]

    printText: qtext on: stream [
	<category: 'printing'>
	self class printText: qtext on: stream
    ]
]

]



Namespace current: NetClients.MIME [

NetworkEntityDescriptor subclass: NetworkAddressDescriptor [
    | domain localPart route |
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    NetworkAddressDescriptor class >> readFrom: aString [
	<category: 'instance creation'>
	^self parser parse: aString
    ]

    NetworkAddressDescriptor class >> scannerType [
	<category: 'parsing'>
	^NetworkAddressParser
    ]

    NetworkAddressDescriptor class >> addressesFrom: stream [
	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp' readStream."

	"self addressesFrom: 'Kazuki Yasumatsu <kyasu@crl.fujixerox.co.jp>' readStream."

	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp (Kazuki Yasumatsu)' readStream."

	"self addressesFrom: ' kyasu1, kyasu2, Kazuki Yasumatsu <kyasu3>, kyasu4 (Kazuki Yasumatsu)' readStream."

	"self addressesFrom: ' foo bar, kyasu1, ,  Kazuki Yasumatsu <kyasu2> <kyasu3> (<foo> (foo bar), bar)' readStream."

	<category: 'utility'>
	^self scannerType addressesFrom: stream
    ]

    NetworkAddressDescriptor class >> addressFrom: aString [
	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp'."

	"self addressesFrom: 'Kazuki Yasumatsu <kyasu@crl.fujixerox.co.jp>'."

	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp (Kazuki Yasumatsu)'."

	"self addressesFrom: ' kyasu1, kyasu2, Kazuki Yasumatsu <kyasu3>, kyasu4 (Kazuki Yasumatsu)'."

	"self addressesFrom: ' foo bar, kyasu1, ,  Kazuki Yasumatsu <kyasu2> <kyasu3> (<foo> (foo bar), bar)'."

	<category: 'utility'>
	^self scannerType addressFrom: aString
    ]

    addressSpecString [
	<category: 'accessing'>
	^self printStringSelector: #printAddressSpecOn:
    ]

    aliasString [
	<category: 'accessing'>
	^self printStringSelector: #printAliasOn:
    ]

    commentString [
	<category: 'accessing'>
	^self printStringSelector: #printCommentOn:
    ]

    domain [
	<category: 'accessing'>
	^domain
    ]

    domain: aValue [
	<category: 'accessing'>
	domain := aValue
    ]

    domainString [
	<category: 'accessing'>
	^self printStringSelector: #printDomainOn:
    ]

    localPart [
	<category: 'accessing'>
	^localPart
    ]

    localPart: aValue [
	<category: 'accessing'>
	localPart := aValue
    ]

    localPartString [
	<category: 'accessing'>
	^self printStringSelector: #printLocalPartOn:
    ]

    route [
	<category: 'accessing'>
	^route
    ]

    route: aValue [
	<category: 'accessing'>
	route := aValue
    ]

    routeString [
	<category: 'accessing'>
	^self printStringSelector: #printRouteOn:
    ]

    initialize [
	<category: 'initialization'>
	localPart := Array new
    ]

    printAddressSpecOn: stream [
	<category: 'printing'>
	self hasAddressSpec 
	    ifTrue: 
		[self printLocalPartOn: stream.
		stream nextPut: $@.
		self printDomainOn: stream]
    ]

    printCanonicalValueOn: stream [
	<category: 'printing'>
	alias notNil 
	    ifTrue: [self printRouteAddressOn: stream]
	    ifFalse: [self printAddressSpecOn: stream]
    ]

    printDomainOn: stream [
	<category: 'printing'>
	self scannerType printDomain: domain on: stream
    ]

    printLocalPartOn: stream [
	<category: 'printing'>
	localPart do: [:token | self scannerType printWord: token on: stream]
	    separatedBy: [stream nextPut: $.]
    ]

    printRouteAddressOn: stream [
	<category: 'printing'>
	self printAliasOn: stream.
	(route notNil or: [self hasAddressSpec]) 
	    ifTrue: 
		[stream nextPut: $<.
		self
		    printRouteOn: stream;
		    printAddressSpecOn: stream.
		stream nextPut: $>]
    ]

    printRouteOn: stream [
	<category: 'printing'>
	(route notNil and: [route notEmpty]) 
	    ifTrue: 
		[route do: 
			[:domainx | 
			stream
			    space;
			    nextPut: $@.
			self scannerType printDomain: domainx on: stream.
			stream nextPut: $:].
		stream space]
    ]

    printStringSelector: sel [
	<category: 'private'>
	| stream |
	stream := (String new: 40) writeStream.
	self perform: sel with: stream.
	^stream contents
    ]

    hasAddressSpec [
	<category: 'testing'>
	^localPart notNil 
	    and: [localPart isEmpty not and: [domain notNil and: [domain isEmpty not]]]
    ]
]

]



Namespace current: NetClients.MIME [

HeaderField subclass: StructuredHeaderField [
    | parameters |
    
    <category: 'NetClients-MIME'>
    <comment: 'I am used as a base for all structured fields as defined by RFC822, MIME and HTTP. Structured fields consist of words rather than text. Therefore, structured fields can be tokenized using lexical scanner.
I am designed to be compatible with Swazoo. Swazoo uses this class to store parameters, so I provide both storage and compatible methods to parse parameters. Parameters are modifiers for the primary value for a field. Syntax of parameters is as follows:
    parameters = *( <;> <key> <=> <value>)

In the future we may reconsiders if providing parameter storage here is a good idea because it seems that only a few field types can have parameters

Instance Variables:
    parameters    <Dictionary>  Contains parsed parameter values as associations
'>

    canonicalValue [
	"Canonical value removes all white space and comments from the source"

	<category: 'accessing'>
	^self tokenizedValueFrom: (self scannerOn: self source readStream)
    ]

    parameterAt: aString [
	<category: 'accessing'>
	^self parameterAt: aString ifAbsent: [nil]
    ]

    parameterAt: aString ifAbsent: aBlock [
	<category: 'accessing'>
	^parameters at: aString ifAbsent: aBlock
    ]

    parameterAt: aString ifAbsentPut: aBlock [
	<category: 'accessing'>
	^self parameters at: aString ifAbsentPut: aBlock
    ]

    parameterAt: aString put: aBlock [
	<category: 'accessing'>
	^self parameters at: aString put: aBlock
    ]

    parameters [
	<category: 'accessing'>
	^parameters
    ]

    parameters: aCollection [
	<category: 'accessing'>
	parameters := aCollection
    ]

    parametersDo: aMonadicBlock [
	"aBlock is a one-argument block which will be evaluated for each parameter. Argument is an
	 association (parameter name, parameter value)"

	<category: 'accessing'>
	^self parameters 
	    keysAndValuesDo: [:nm :val | aMonadicBlock value: nm -> val]
    ]

    printParameter: assoc on: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $;;
	    nextPutAll: assoc key;
	    nextPut: $=;
	    nextPutAll: assoc value
    ]

    printParametersOn: aStream [
	<category: 'printing'>
	self parametersDo: [:assoc | self printParameter: assoc on: aStream]
    ]

    printStructureOn: aStream [
	"Default implementation is the same as inherited. Subclasses can override it"

	<category: 'printing'>
	super printValueOn: aStream
    ]

    printValueOn: aStream [
	"The reasoning here is that if an instance was created by parsing input stream, it should be reconstructed verbatim rather than restored by us. We may alter the original in some ways and sometimes it may be undesirable"

	<category: 'printing'>
	self value notNil 
	    ifTrue: [super printValueOn: aStream]
	    ifFalse: [self printStructureOn: aStream]
    ]

    initialize [
	<category: 'private-initialize'>
	super initialize.
	parameters := Dictionary new
    ]

    readParametersFrom: rs [
	<category: 'private-utility'>
	| paramName paramValue |
	
	[rs
	    skipWhiteSpace;
	    atEnd] whileFalse: 
		    [rs mustMatch: $; notify: 'Invalid parameter'.
		    paramName := rs nextToken.
		    rs mustMatch: $= notify: 'Invalid parameter'.
		    paramValue := rs nextToken.
		    parameters at: paramName put: paramValue]
    ]

    tokenize: rfc822Stream [
	"Scan field value token by token. Answer an array of tokens"

	<category: 'private-utility'>
	| result token |
	result := (Array new: 2) writeStream.
	
	[rfc822Stream atEnd or: 
		[rfc822Stream peek == Character nl 
		    or: [(token := rfc822Stream nextToken) isNil]]] 
		whileFalse: [result nextPut: token].
	^result contents
    ]

    tokenizedValueFrom: rfc822Stream [
	"Scan field value token by token. Answer a string that is a concatenation of all elements in the array. One can view this as a canonicalized field value because this operation eliminates all white space and comments"

	<category: 'private-utility'>
	| result tokens |
	result := (String new: 20) writeStream.
	tokens := self tokenize: rfc822Stream.
	tokens do: 
		[:token | 
		token isString 
		    ifTrue: [result nextPutAll: token]
		    ifFalse: [result nextPut: token]].
	^result contents
    ]
]

]



Namespace current: NetClients.MIME [

NetworkEntityDescriptor subclass: MailGroupDescriptor [
    | addresses |
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    addresses [
	<category: 'accessing'>
	^addresses
    ]

    addresses: anArray [
	<category: 'accessing'>
	addresses := anArray
    ]

    alias [
	<category: 'accessing'>
	^alias
    ]

    alias: aString [
	<category: 'accessing'>
	alias := aString
    ]

    initialize [
	<category: 'initialization'>
	addresses := Array new
    ]

    printCanonicalValueOn: stream [
	<category: 'printing'>
	self printAliasOn: stream.
	stream nextPut: $:.
	self addresses do: [:address | address printOn: stream]
	    separatedBy: [stream nextPut: $,].
	stream nextPut: $;
    ]
]

]



Namespace current: NetClients.MIME [

MailScanner subclass: RFC822Scanner [
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    HeaderNameMask := nil.
    QuotedPairChar := nil.
    QuotedPairMask := nil.
    AtomMask := nil.
    QuotedTextMask := nil.
    CommentMask := nil.
    SimpleTimeZones := nil.
    DomainTextMask := nil.
    TextMask := nil.
    HeaderNameDelimiterChar := nil.
    TokenMask := nil.

    RFC822Scanner class >> specials [
	"Note that definition of this set varies from standard to standard, so this method needs to be overridden for specialized parsers"

	<category: 'character classification'>
	^'()<>@,;:\".[]'
    ]

    RFC822Scanner class >> tspecials [
	"tspecials in MIME and HTTP. It is derived from RCC822 specials with addition of </>, <?>, <=> and removal of <.>"

	<category: 'character classification'>
	^'()<>@,;:\"/[]?='
    ]

    RFC822Scanner class >> initClassificationTable [
	<category: 'class initialization'>
	super initClassificationTable.
	self initClassificationTableWith: HeaderNameMask
	    when: [:c | c > Character space and: [c ~~ $:]].
	self initClassificationTableWith: TextMask
	    when: [:c | c ~~ Character cr and: [c ~~ Character nl]].
	self initClassificationTableWith: AtomMask
	    when: [:c | c > Character space and: [(self specials includes: c) not]].
	self initClassificationTableWith: TokenMask
	    when: [:c | c > Character space and: [(self tspecials includes: c) not]].
	self initClassificationTableWith: QuotedTextMask
	    when: 
		[:c | 
		c ~~ $" and: [c ~~ $\ and: [c ~~ Character cr and: [c ~~ Character nl]]]].
	self initClassificationTableWith: DomainTextMask
	    when: 
		[:c | 
		('[]\' includes: c) not and: [c ~~ Character cr and: [c ~~ Character nl]]].
	self initClassificationTableWith: CommentMask
	    when: 
		[:c | 
		c ~~ $( and: 
			[c ~~ $) and: [c ~~ $\ and: [c ~~ Character cr and: [c ~~ Character nl]]]]]
    ]

    RFC822Scanner class >> initialize [
	"RFC822Scanner initialize"

	<category: 'class initialization'>
	self
	    initializeConstants;
	    initClassificationTable
    ]

    RFC822Scanner class >> initializeConstants [
	<category: 'class initialization'>
	AtomMask := 256.
	CommentMask := 512.
	DomainTextMask := 1024.
	HeaderNameMask := 2048.
	QuotedTextMask := 4096.
	TextMask := 8192.
	TokenMask := 16384.
	QuotedPairMask := (QuotedTextMask bitOr: CommentMask) 
		    bitOr: DomainTextMask.
	QuotedPairChar := $\.
	HeaderNameDelimiterChar := $:
    ]

    RFC822Scanner class >> dateAndTimeFrom: aString [
	"RFC822Scanner dateAndTimeFrom: '6 Dec 88 10:16:08 +0900 (Tuesday)'."

	"RFC822Scanner dateAndTimeFrom: '12 Dec 88 10:16:08 +0900 (Tuesday)'."

	"RFC822Scanner dateAndTimeFrom: 'Fri, 31 Mar 89 09:13:20 +0900'."

	"RFC822Scanner dateAndTimeFrom: 'Tue, 18 Apr 89 23:29:47 +0900'."

	"RFC822Scanner dateAndTimeFrom: 'Tue, 23 May 89 13:52:12 JST'."

	"RFC822Scanner dateAndTimeFrom: 'Thu, 1 Dec 88 17:13:27 jst'."

	"RFC822Scanner dateAndTimeFrom: 'Sat, 15 Jul 95 14:36:22 0900'."

	"RFC822Scanner dateAndTimeFrom: '2-Nov-86 10:43:42 PST'."

	"RFC822Scanner dateAndTimeFrom: 'Friday, 21-Jul-95 04:04:55 GMT'."

	"RFC822Scanner dateAndTimeFrom: 'Jul 10 11:06:40 1995'."

	"RFC822Scanner dateAndTimeFrom: 'Jul 10 11:06:40 JST 1995'."

	"RFC822Scanner dateAndTimeFrom: 'Mon Jul 10 11:06:40 1995'."

	"RFC822Scanner dateAndTimeFrom: 'Mon Jul 10 11:06:40 JST 1995'."

	"RFC822Scanner dateAndTimeFrom: '(6 December 1988 10:16:08 am )'."

	"RFC822Scanner dateAndTimeFrom: '(12 December 1988 10:16:08 am )'."

	"RFC822Scanner dateAndTimeFrom: ''."

	<category: 'from Network Clients'>
	| rfcString |
	aString size <= 10 
	    ifTrue: 
		["may be illegal format"

		^DateTime utcDateAndTimeNow].
	rfcString := self normalizeDateAndTimeString: aString.
	^self readRFC822DateAndTimeFrom: rfcString readStream
    ]

    RFC822Scanner class >> defaultTimeZoneDifference [
	<category: 'from Network Clients'>
	^DateTime now offset seconds
    ]

    RFC822Scanner class >> initializeTimeZones [
	"RFC822Scanner initializeTimeZones."

	"Install TimeZone constants."

	<category: 'from Network Clients'>
	SimpleTimeZones := Dictionary new.

	"Universal Time"
	SimpleTimeZones at: 'UT' put: 0.
	SimpleTimeZones at: 'GMT' put: 0.

	"For North America."
	SimpleTimeZones at: 'EST' put: -5.
	SimpleTimeZones at: 'EDT' put: -4.
	SimpleTimeZones at: 'CST' put: -6.
	SimpleTimeZones at: 'CDT' put: -5.
	SimpleTimeZones at: 'MST' put: -7.
	SimpleTimeZones at: 'MDT' put: -6.
	SimpleTimeZones at: 'PST' put: -8.
	SimpleTimeZones at: 'PDT' put: -7.

	"For Europe."
	SimpleTimeZones at: 'BST' put: 0.
	SimpleTimeZones at: 'WET' put: 0.
	SimpleTimeZones at: 'MET' put: 1.
	SimpleTimeZones at: 'EET' put: 2.

	"For Japan."
	SimpleTimeZones at: 'JST' put: 9
    ]

    RFC822Scanner class >> normalizeDateAndTimeString: aString [
	"RFC822 formats"

	"RFC822Scanner normalizeDateAndTimeString: '6 Dec 88 10:16:08 +0900 (Tuesday)'."

	"RFC822Scanner normalizeDateAndTimeString: 'Tue, 18 Apr 89 23:29:47 +0900'."

	"RFC822Scanner normalizeDateAndTimeString: 'Tue, 18 Apr 89 23:29:47 0900'."

	"RFC822Scanner normalizeDateAndTimeString: 'Tue, 23 May 89 13:52:12 JST'."

	"RFC822Scanner normalizeDateAndTimeString: '2-Nov-86 10:43:42 PST'."

	"Other formats"

	"RFC822Scanner normalizeDateAndTimeString: 'Jul 10 11:06:40 1995'."

	"RFC822Scanner normalizeDateAndTimeString: 'Jul 10 11:06:40 JST 1995'."

	"RFC822Scanner normalizeDateAndTimeString: 'Mon Jul 10 11:06:40 1995'."

	"RFC822Scanner normalizeDateAndTimeString: 'Mon Jul 10 11:06:40 JST 1995'."

	<category: 'from Network Clients'>
	| head tail read str1 str2 write |
	aString size < 6 ifTrue: [^aString].
	head := aString copyFrom: 1 to: aString size - 5.
	(head indexOf: $,) > 0 ifTrue: [^aString].
	tail := aString copyFrom: aString size - 4 to: aString size.
	read := tail readStream.
	(read next = Character space and: 
		[read next isDigit 
		    and: [read next isDigit and: [read next isDigit and: [read next isDigit]]]]) 
	    ifFalse: [^aString].
	read := head readStream.
	str1 := read upTo: Character space.
	str2 := read upTo: Character space.
	(str1 isEmpty or: [str2 isEmpty]) ifTrue: [^aString].
	str2 first isDigit 
	    ifFalse: 
		[str1 := str2.
		str2 := read upTo: Character space.
		(str2 isEmpty or: [str2 first isDigit not]) ifTrue: [^aString]].
	read atEnd ifTrue: [^aString].
	write := WriteStream on: (String new: 32).
	write
	    nextPutAll: str2;
	    nextPutAll: str1;
	    nextPutAll: (tail copyFrom: 4 to: 5);
	    space;
	    nextPutAll: read.
	^write contents
    ]

    RFC822Scanner class >> readDateFrom: aStream [
	"date    =  1*2DIGIT month 2DIGIT
	 month    =  'Jan'  /  'Feb' /  'Mar'  /  'Apr'
	 /  'May'  /  'Jun' /  'Jul'  /  'Aug'
	 /  'Sep'  /  'Oct' /  'Nov'  /  'Dec'"

	"RFC822Scanner readDateFrom: '01 Jan 95' readStream."

	"RFC822Scanner readDateFrom: '1 Jan 95' readStream."

	"RFC822Scanner readDateFrom: '23 Jan 95' readStream."

	"RFC822Scanner readDateFrom: '23-Jan-95' readStream."

	"RFC822Scanner readDateFrom: 'Jan 23 95' readStream."

	"RFC822Scanner readDateFrom: 'Jan 23 1995' readStream."

	<category: 'from Network Clients'>
	^Date readFrom: aStream
    ]

    RFC822Scanner class >> readRFC822DateAndTimeFrom: aStream [
	"date-time    =  [ day ',' ] date time
	 day            =  'Mon'  / 'Tue' /  'Wed'  / 'Thu'
	 /  'Fri'  / 'Sat' /  'Sun'"

	"RFC822Scanner readRFC822DateAndTimeFrom: '6 Dec 88 10:16:08 +0900 (Tuesday)' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: '12 Dec 88 10:16:08 +0900 (Tuesday)' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: 'Fri, 31 Mar 89 09:13:20 +0900' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: 'Tue, 18 Apr 89 23:29:47 +0900' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: 'Tue, 23 May 89 13:52:12 JST' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: 'Thu, 1 Dec 88 17:13:27 jst' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: '2-Nov-86 10:43:42 PST' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: '(6 December 1988 10:16:08 am )' readStream."

	"RFC822Scanner readRFC822DateAndTimeFrom: '(12 December 1988 10:16:08 am )' readStream."

	<category: 'from Network Clients'>
	| char date time |
	[aStream atEnd or: 
		[char := aStream peek.
		char isDigit]] 
	    whileFalse: [aStream next].
	aStream atEnd ifTrue: [^DateTime utcDateAndTimeNow].
	date := self readDateFrom: aStream.
	aStream skipSeparators.
	time := self readTimeFrom: aStream.
	^Array with: date with: time
    ]

    RFC822Scanner class >> readTimeFrom: aStream [
	"time    =  hour zone
	 hour    =  2DIGIT ':' 2DIGIT [':' 2DIGIT]
	 zone    =  'UT'  / 'GMT'
	 /  'EST' / 'EDT'
	 /  'CST' / 'CDT'
	 /  'MST' / 'MDT'
	 /  'PST' / 'PDT'
	 /  1ALPHA
	 / ( ('+' / '-') 4DIGIT )"

	"RFC822Scanner readTimeFrom: '12:16:08 GMT' readStream."

	"RFC822Scanner readTimeFrom: '12:16:08 XXX' readStream."

	"RFC822Scanner readTimeFrom: '07:16:08 EST' readStream."

	"RFC822Scanner readTimeFrom: '07:16:08 -0500' readStream."

	"RFC822Scanner readTimeFrom: '21:16:08 JST' readStream."

	"RFC822Scanner readTimeFrom: '21:16:08 jst' readStream."

	"RFC822Scanner readTimeFrom: '21:16:08 +0900' readStream."

	"RFC822Scanner readTimeFrom: '21:16:08 0900' readStream."

	"RFC822Scanner readTimeFrom: '12:16:08 pm' readStream."

	"Smalltalk time"

	"RFC822Scanner readTimeFrom: '12:16' readStream."

	"No timezone"

	"RFC822Scanner readTimeFrom: '12:16:08' readStream."

	"No timezone"

	<category: 'from Network Clients'>
	| hour minute second write char timezone |
	hour := Integer readFrom: aStream.
	minute := 0.
	second := 0.
	(aStream peekFor: $:) 
	    ifTrue: 
		[minute := Integer readFrom: aStream.
		(aStream peekFor: $:) ifTrue: [second := Integer readFrom: aStream]].
	aStream skipSeparators.
	write := WriteStream on: (String new: 8).
	[aStream atEnd or: 
		[char := aStream next.
		char isSeparator]] 
	    whileFalse: [write nextPut: char].
	timezone := write contents asUppercase.
	(SimpleTimeZones at: timezone ifAbsent: [nil]) notNil 
	    ifTrue: [hour := hour - (SimpleTimeZones at: timezone)]
	    ifFalse: 
		[('+####' match: timezone) 
		    ifTrue: 
			[hour := hour - (timezone copyFrom: 2 to: 3) asNumber.
			minute := minute - (timezone copyFrom: 4 to: 5) asNumber]
		    ifFalse: 
			[('-####' match: timezone) 
			    ifTrue: 
				[hour := hour + (timezone copyFrom: 2 to: 3) asNumber.
				minute := minute + (timezone copyFrom: 4 to: 5) asNumber]
			    ifFalse: 
				['AM' = timezone 
				    ifTrue: 
					["Smalltalk time"

					hour = 12 ifTrue: [hour := 0]]
				    ifFalse: 
					['PM' = timezone 
					    ifTrue: 
						["Smalltalk time"

						hour = 12 ifTrue: [hour := 0].
						hour := hour + 12]
					    ifFalse: 
						["Using default time zone"

						hour := hour - (self defaultTimeZoneDifference // 3600)]]]]].
	^Time fromSeconds: 60 * (60 * hour + minute) + second
    ]

    RFC822Scanner class >> defaultTokenType [
	<category: 'printing'>
	^#word
    ]

    RFC822Scanner class >> nextPutComment: comment on: stream [
	<category: 'printing'>
	comment notNil 
	    ifTrue: 
		[stream nextPut: $(.
		comment do: 
			[:char | 
			(self isCommentChar: char) ifFalse: [stream nextPut: $\].
			stream nextPut: char].
		stream nextPut: $)]
    ]

    RFC822Scanner class >> printDomain: domainx on: stream [
	"Domainx is an array of domain segments"

	<category: 'printing'>
	domainx notNil 
	    ifTrue: 
		[domainx do: [:word | self printWord: word on: stream]
		    separatedBy: [stream nextPut: $.]]
    ]

    RFC822Scanner class >> printPhrase: phrase on: stream [
	<category: 'printing'>
	phrase do: [:word | stream nextPutAll: word] separatedBy: [stream space]
    ]

    RFC822Scanner class >> printWord: str on: stream [
	"Print word as either atom or quoted text"

	<category: 'printing'>
	(self shouldBeQuoted: str) 
	    ifTrue: 
		[stream
		    nextPut: $";
		    nextPutAll: str;
		    nextPut: $"]
	    ifFalse: [stream nextPutAll: str]
    ]

    RFC822Scanner class >> isAtomChar: char [
	<category: 'testing'>
	^((self classificationTable at: char asInteger + 1) bitAnd: AtomMask) ~= 0
    ]

    RFC822Scanner class >> isCommentChar: char [
	<category: 'testing'>
	^((self classificationTable at: char asInteger + 1) bitAnd: CommentMask) 
	    ~= 0
    ]

    RFC822Scanner class >> shouldBeQuoted: string [
	<category: 'testing'>
	^(string detect: [:char | (self isAtomChar: char) not] ifNone: [nil]) 
	    notNil
    ]

    phraseAsString: phrase [
	<category: 'converting'>
	| stream |
	stream := (String new: 40) writeStream.
	self class printPhrase: phrase on: stream.
	^stream contents
    ]

    scanAtom [
	"atom  =  1*<any CHAR except specials, SPACE and CTLs>"

	<category: 'multi-character scans'>
	token := self scanTokenMask: AtomMask.
	tokenType := #atom.
	^token
    ]

    scanComment [
	"collect comment"

	<category: 'multi-character scans'>
	| output |
	output := saveComments 
		    ifTrue: [(String new: 40) writeStream]
		    ifFalse: [nil].
	self scanCommentOn: output.
	output notNil 
	    ifTrue: 
		[currentComment isNil 
		    ifTrue: [currentComment := OrderedCollection with: output contents]
		    ifFalse: [currentComment add: output contents]].
	^token
    ]

    scanDomainText [
	"dtext = <any CHAR excluding <[>, <]>, <\> & CR, & including linear-white-space> ; => may be folded"

	<category: 'multi-character scans'>
	token := self 
		    scanToken: 
			[self
			    scanQuotedChar;
			    matchCharacterType: DomainTextMask]
		    delimitedBy: '[]'
		    notify: 'Malformed domain literal'.
	tokenType := #domainText.
	^token
    ]

    atEndOfLine [
	<category: 'multi-character scans'>
        self peek.
	^(self classificationMaskFor: lookahead) anyMask: CRLFMask
    ]

    skipEndOfLine [
	<category: 'multi-character scans'>
	hereChar == Character nl 
	    ifFalse: 
		[(source peekFor: Character nl) 
		    ifFalse: [^false]
		    ifTrue: [self sourceTrailNextPut: Character nl]].
        ^true
    ]

    scanEndOfLine [
	"Note: this will work only for RFC822 but not for HTTP. Needs more design work"

	<category: 'multi-character scans'>
        "Called after #step, so no need to peek to set the CRLFMask."
	(self matchCharacterType: CRLFMask) ifFalse: [^false].
	self skipEndOfLine ifFalse: [^self].
	self shouldFoldLine 
	    ifTrue: 
		[self hereChar: Character space.
		^self].

	"Otherwise we have an end-of-line condition -- set appropriate masks"
	classificationMask := (classificationMask bitClear: WhiteSpaceMask) 
		    bitOr: EndOfLineMask
    ]

    scanFieldName [
	"RFC822, p.9: field-name = 1*<any CHAR excluding CTLs, SPACE and ':'>"

	<category: 'multi-character scans'>
	^self scanTokenMask: HeaderNameMask
    ]

    scanPhrase [
	"RFC822: phrase = 1*word ; Sequence of words. At the end of scan the scanner has read the first token after phrase"

	<category: 'multi-character scans'>
	^self tokenizeWhile: [#(#quotedText #atom) includes: tokenType]
    ]

    scanQuotedChar [
	"Scan possible quoted character. If the current char is $\, read in next character and make it a quoted
	 string character"

	<category: 'multi-character scans'>
	^hereChar == QuotedPairChar 
	    ifTrue: 
		[self step.
		classificationMask := QuotedPairMask.
		true]
	    ifFalse: [false]
    ]

    scanQuotedText [
	"quoted-string = <"

	"> *(qtext/quoted-pair) <"

	">; Regular qtext or quoted chars.
	 qtext    =  <any CHAR excepting <"

	">, <\> & CR, and including linear-white-space>  ; => may be folded"

	"We are positioned at the first double quote character"

	<category: 'multi-character scans'>
	token := self 
		    scanToken: 
			[self
			    scanQuotedChar;
			    matchCharacterType: QuotedTextMask]
		    delimitedBy: '""'
		    notify: 'Unmatched quoted text'.
	tokenType := #quotedText.
	^token
    ]

    scanText [
	"RFC822: text = <Any CHAR, including bare CR & bare LF, but not including CRLF. This is a 'catchall' category and cannot be tokenized. Text is used only to read values of unstructured fields"

	<category: 'multi-character scans'>
	(self matchCharacterType: EndOfLineMask) ifTrue: [^String new].
	^self scanUntil: [self matchCharacterType: CRLFMask]
    ]

    scanWord [
	<category: 'multi-character scans'>
	self nextToken.
	(#(#quotedText #atom) includes: tokenType) 
	    ifFalse: [self error: 'Expecting word'].
	^token
    ]

    skipWhiteSpace [
	"It is inefficient because intermediate stream is created. Perhaps refactoring scanWhile: can help"

	<category: 'multi-character scans'>
	self scanWhile: 
		[hereChar == $( 
		    ifTrue: 
			[self
			    stepBack;
			    scanComment.
			true]
		    ifFalse: [self matchCharacterType: WhiteSpaceMask]]
    ]

    nextRFC822Token [
	<category: 'private'>
	| char |
	self skipWhiteSpace.
	char := self peek.
	char isNil 
	    ifTrue: 
		["end of input"

		tokenType := #doIt.
		^token := nil].
	char == $( 
	    ifTrue: 
		[^self
		    scanComment;
		    nextToken].
	char == $" ifTrue: [^self scanQuotedText].
	(self specials includes: char) 
	    ifTrue: 
		[tokenType := #special.	"Special character. Make it token value and set token type"
		^token := self next].
	(self matchCharacterType: AtomMask) ifTrue: [^self scanAtom].
	tokenType := #doIt.
	token := char.
	^token
    ]

    scanCommentOn: streamOrNil [
	"scan comment copying on specified stream"

	<category: 'private'>
	self step ~~ $( ifTrue: [self error: 'Unmatched comment'].	"Should never be the case"
	token := self scanUntil: 
			[((self
			    scanQuotedChar;
			    matchCharacterType: CommentMask) 
				ifTrue: 
				    [streamOrNil notNil ifTrue: [streamOrNil nextPut: hereChar].
				    true]
				ifFalse: 
				    [hereChar == $( 
					ifTrue: 
					    [streamOrNil notNil ifTrue: [streamOrNil space].
					    self
						stepBack;
						scanCommentOn: streamOrNil.
					    streamOrNil notNil ifTrue: [streamOrNil space].
					    true]
					ifFalse: [false]]) 
				not].
	hereChar ~~ $) ifTrue: [self error: 'Unmatched comment'].
	^token
    ]

    assertNoLookahead [
	"Fail if the parser has lookahead."

	<category: 'test'>

        lookahead isNil ifFalse: [ self error: 'unexpected parsing state' ]
    ]

    shouldFoldLine [
	"Answers true if next line is to be folded in, that is, if CRLF is followed by at least one white space"

	<category: 'private'>
	| char |
	self atEnd ifTrue: [^false].
	char := source peek.
	^((self classificationMaskFor: char) anyMask: WhiteSpaceMask) 
	    ifFalse: 
		[self resetToken; peek.
		false]
	    ifTrue: 
		[self sourceTrailNextPut: source next.
		true]
    ]

    step [
	<category: 'private'>
	super step.
	self scanEndOfLine.
	^hereChar
    ]

    isRFC822Scanner [
	<category: 'testing'>
	^true
    ]

    nextToken [
	<category: 'tokenization'>
	^self nextRFC822Token
    ]

    specials [
	"This method is provided to encapsulate lexical differences between RFC822 on one side, and MIME, HTTP on the other side. MIME definiton of 'tspecials' is the same as the RFC 822 definition of ''specials' with the addition of the three characters </>, <?>, and <=>, and the removal of <.>. To present uniform tokenization interface, this method is overridden in Mime scanner"

	<category: 'tokenization'>
	^self class specials
    ]
]

]



Namespace current: NetClients.MIME [

StructuredHeaderField subclass: ScalarField [
    | value |
    
    <category: 'NetClients-MIME'>
    <comment: 'I represent RFC822 structured header field that contains a single value. When parsing the field we would just sequentially read and concatenate all tokens. This will remove all ''noise'' such as white space and comments

Instance Variables:
    item    <String>  Parsed value of the item
'>

    ScalarField class >> fieldNames [
	<category: 'parsing'>
	^#('message-id' 'content-id' 'content-transfer-encoding' 'transfer-encoding' 'content-encoding')
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: anObject [
	<category: 'accessing'>
	value := anObject
    ]

    parse: rfc822Stream [
	<category: 'parsing'>
	self value: (self tokenizedValueFrom: rfc822Stream)
    ]
]

]



Namespace current: NetClients.MIME [

RFC822Scanner subclass: MimeScanner [
    
    <category: 'NetClients-MIME'>
    <comment: nil>

    MimeScanner class >> decodeBase64From: startIndex to: endIndex in: aString [
	"Decode aString from startIndex to endIndex in base64."

	<category: 'text processing'>
	| codeChars decoder index nl endChars end padding data sz i outSize |
	codeChars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.
	decoder := (0 to: 255) 
		    collect: [:n | (codeChars indexOf: (n + 1) asCharacter) - 1].
	decoder replaceAll: -1 with: 0.
	index := startIndex.
	nl := Character nl.
	"There is padding at the end of a base64 message if the content is not a multiple of
	 3 bytes in length.  The padding is either two ='s to pad-out a trailing byte, 1 = to
	 pad out a trailing pair of bytes, or no padding.  Here we count the padding.  After
	 processing the message we cut-back by the amount of padding."
	end := endIndex min: (sz := aString size).
	endChars := codeChars , (String with: $=).
	
	[(endChars includes: (aString at: end)) 
	    and: [end = endIndex or: [(aString at: end + 1) = nl]]] 
		whileFalse: [end := end - 1].
	padding := 0.
	[(aString at: end - padding) == $=] whileTrue: 
		[padding := padding + 1].
	outSize := (end - startIndex + 1) * 3 // 4 - padding.
	data := String new: outSize.
	i := 1.
	[index <= end] whileTrue: 
		[| triple |
		triple := ((decoder at: (aString at: index) asInteger) bitShift: 18) 
			    + ((decoder at: (aString at: index + 1) asInteger) bitShift: 12) 
				+ ((decoder at: (aString at: index + 2) asInteger) bitShift: 6) 
				+ (decoder at: (aString at: index + 3) asInteger).
		padding := outSize - i.
		data at: i put: (Character value: (triple digitAt: 3)).
		padding > 0 ifTrue: [
			data at: i + 1 put: (Character value: (triple digitAt: 2))].
		padding > 1 ifTrue: [
			data at: i + 2 put: (Character value: (triple digitAt: 1))].

		i := i + 3.
		index := index + 4.
		[(index > sz or: [(aString at: index) = nl]) and: [index <= end]] 
		    whileTrue: [index := index + 1]].
	^data
    ]

    MimeScanner class >> decodeQuotedPrintableFrom: startIndex to: endIndex in: aString [
	"Decode aString from startIndex to endIndex in quoted-printable."

	<category: 'text processing'>
	| input output char n1 n2 |
	input := ReadStream 
		    on: aString
		    from: startIndex
		    to: endIndex.
	output := (String new: endIndex - startIndex) writeStream.
	[input atEnd] whileFalse: 
		[char := input next.
		$= == char 
		    ifTrue: 
			[('0123456789ABCDEF' includes: (n1 := input next)) 
			    ifTrue: 
				[n2 := input next.
				output nextPut: ((n1 digitValue bitShift: 4) + n2 digitValue) asCharacter]]
		    ifFalse: [output nextPut: char]].
	^output contents
    ]

    MimeScanner class >> decodeUUEncodedFrom: startIndex to: farEndIndex in: aString [
	"decode aString from startIndex to farEndIndex as uuencode-encoded"

	<category: 'text processing'>
	| endIndex i nl space output data |
	endIndex := farEndIndex - 2.
	
	[endIndex <= startIndex or: 
		[(aString at: endIndex + 1) = $e 
		    and: [(aString at: endIndex + 2) = $n and: [(aString at: endIndex + 3) = $d]]]] 
		whileFalse: [endIndex := endIndex - 1].
	i := (aString 
		    findString: 'begin'
		    startingAt: startIndex
		    ignoreCase: true
		    useWildcards: false) first.
	i = 0 ifTrue: [i := startIndex].
	nl := Character nl.
	space := Character space asInteger.
	output := (data := String new: (endIndex - startIndex) * 3 // 4) 
		    writeStream.
	
	[[i < endIndex and: [(aString at: i) ~= nl]] whileTrue: [i := i + 1].
	i < endIndex] 
		whileTrue: 
		    [| count |
		    count := (aString at: (i := i + 1)) asInteger - space bitAnd: 63.
		    i := i + 1.
		    count = 0 
			ifTrue: [i := endIndex]
			ifFalse: 
			    [[count > 0] whileTrue: 
				    [| m n o p |
				    m := (aString at: i) asInteger - space bitAnd: 63.
				    n := (aString at: i + 1) asInteger - space bitAnd: 63.
				    o := (aString at: i + 2) asInteger - space bitAnd: 63.
				    p := (aString at: i + 3) asInteger - space bitAnd: 63.
				    count >= 1 
					ifTrue: 
					    [output nextPut: (Character value: (m bitShift: 2) + (n bitShift: -4)).
					    count >= 2 
						ifTrue: 
						    [output 
							nextPut: (Character value: ((n bitShift: 4) + (o bitShift: -2) bitAnd: 255)).
						    count >= 3 
							ifTrue: [output nextPut: (Character value: ((o bitShift: 6) + p bitAnd: 255))]]].
				    i := i + 4.
				    count := count - 3]]].
	^data copyFrom: 1 to: output position
    ]

    scanText [
	"Parse text as defined in RFC822 grammar, then apply the rules of RFC2047 for encoded words in Text fields. An encoded word inside text field may appear immediately following a white space character"

	<category: 'multi-character scans'>
	| text |
	text := super scanText.
	^MimeEncodedWordCoDec decodeText: text
    ]

    scanToBoundary: boundary [
	"Scan for specified boundary (RFC2046, p5.1). Answer two-element array. First element is the scanned text from current position up to the beginning of the boundary. Second element is either #next or #last. #next means the boundary found is not the last one. #last means the boundary is the closing boundary for the multi-part body (that is, it looks like '--<boundary>--)"

	<category: 'multi-character scans'>
	| pattern string kind |
	pattern := (String with: Character nl) , '--' , boundary.
	string := self upToAll: pattern.
	kind := ((self peekFor: $-) and: [self peekFor: $-]) 
		    ifTrue: [#last]
		    ifFalse: [#next].
	self upTo: Character nl.
	^Array with: string with: kind
    ]

    scanToken [
	"MIME and HTTP: token  =  1*<any CHAR except tspecials, SPACE and CTLs>. That is, 'token' is analogous to RFC822 'atom' except set of Mime's set of tspecials characters includes three more characters as compared to set of 'specials' in RFC822"

	<category: 'multi-character scans'>
	token := self scanTokenMask: TokenMask.
	tokenType := #token.
	^token
    ]

    printPhrase: phrase on: stream [
	<category: 'printing'>
	MimeEncodedWordCoDec decodePhrase: phrase printOn: stream
    ]

    decodeCommentString: commentString [
	<category: 'private'>
	^MimeEncodedWordCoDec decodeComment: commentString
    ]

    nextMimeToken [
	<category: 'private'>
	| char |
	self skipWhiteSpace.
	char := self peek.
	char isNil 
	    ifTrue: 
		["end of input"

		tokenType := #doIt.
		^token := nil].
	char == $( 
	    ifTrue: 
		[^self
		    scanComment;
		    nextToken].
	char == $" ifTrue: [^self scanQuotedText].
	(self specials includes: char) 
	    ifTrue: 
		[tokenType := #special.	"Special character. Make it token value and set token type"
		^token := self next].
	(self matchCharacterType: TokenMask) ifTrue: [^self scanToken].
	tokenType := #doIt.
	token := char.
	^token
    ]

    scanCommentOn: streamOrNil [
	"scan comment copying on specified stream. Look for MIME 'encoded words' (RFC2047) and decoded them if identified"

	<category: 'private'>
	token := super scanCommentOn: streamOrNil.
	^self decodeCommentString: token
    ]

    nextToken [
	<category: 'tokenization'>
	^self nextMimeToken
    ]

    specials [
	"This method is provided to encapsulate lexical differences between RFC822 on one side, and MIME, HTTP on the other side. MIME definiton of 'tspecials' is the same as the RFC 822 definition of ''specials' with the addition of the three characters </>, <?>, and <=>, and the removal of <.>. To present uniform tokenization interface, this method is overridden in Mime scanner"

	<category: 'tokenization'>
	^self class tspecials
    ]
]

]



Namespace current: NetClients.MIME [

RFC822Scanner subclass: NetworkAddressParser [
    | descriptor |
    
    <category: 'NetClients-MIME'>
    <comment: 'This class parses mailbox and group addresses as well as address-spec as defined by RFC822 and MIME. Parsed results are placed in an instance of NetworkAddressDescriptor or MailGroupDescriptor. See utility methods.
RFC822 spec is word-based, so address is first tokenized, then parsed. MIME (RFC2045-2049) adds further interpretation to the address syntax. Once address is parsed, some parts of the address (namely ''phrase'' and ''comment'') can be further scanned for the presence of ''encoded words''. 
Note that MIME ''words'' are not the same as RFC822 ''words'', so the same expression may be tokenized differently in RFC822 and MIME. MIME states that mailbox and group addresses MUST be tokenized using RFC822 spec, then processed according to MIME rules. Therefore, we use #nextRFC822Token, not #nextToken like everybody else


Instance Variables:
    descriptor    <NetworkAddressDescriptor | MailGroupDescriptor>  comment
'>

    NetworkAddressParser class >> parse: string [
	<category: 'instance creation'>
	^self new parse: string
    ]

    NetworkAddressParser class >> addressesFrom: stream [
	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp' readStream."

	"self addressesFrom: 'Kazuki Yasumatsu <kyasu@crl.fujixerox.co.jp>' readStream."

	"self addressesFrom: 'kyasu@crl.fujixerox.co.jp (Kazuki Yasumatsu)' readStream."

	"self addressesFrom: ' kyasu1, kyasu2, Kazuki Yasumatsu <kyasu3>, kyasu4 (Kazuki Yasumatsu)' readStream."

	"self addressesFrom: ' foo bar, kyasu1, ,  Kazuki Yasumatsu <kyasu2> <kyasu3> (<foo> (foo bar), bar)' readStream."

	<category: 'utility'>
	^(self on: stream) parseAddressesSeparatedBy: $,
    ]

    NetworkAddressParser class >> addressFrom: stream [
	"self addressFrom: 'kyasu@crl.fujixerox.co.jp'."

	"self addressFrom: 'Kazuki Yasumatsu <kyasu@crl.fujixerox.co.jp>'."

	"self addressFrom: 'kyasu@crl.fujixerox.co.jp (Kazuki Yasumatsu)'."

	<category: 'utility'>
	^(self on: stream) parseAddress
    ]

    descriptor [
	<category: 'accessing'>
	^descriptor
    ]

    descriptor: aValue [
	<category: 'accessing'>
	descriptor := aValue
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	descriptor := self newAddressDescriptor
    ]

    completeScanOfAddressSpecWith: partial [
	"addr-spec   =  local-part <@> domain        ; global address
	 local-part = word *(<.> word) ; uninterpreted, case-preserved
	 First local-part token was already scanned; we are now scanning *(<.> word) group and domain part.
	 Partial is an array of tokens already read"

	<category: 'private'>
	| stream pos |
	stream := partial readWriteStream.
	stream setToEnd.
	self descriptor localPart: (self scanLocalAddressPartTo: stream).
	pos := self position.
	self nextRFC822Token == $@ 
	    ifTrue: [self descriptor domain: self scanDomain]
	    ifFalse: [self position: pos]
    ]

    newAddressDescriptor [
	<category: 'private'>
	^NetworkAddressDescriptor new
    ]

    parseGroupSpecWith: phrase [
	"group = phrase <:> [#mailbox] <;>"

	<category: 'private'>
	| group mailboxes phrasex comment stream |
	mailboxes := self tokenizeList: [self parseAddress]
		    separatedBy: [token == $,].
	self nextRFC822Token == $; 
	    ifFalse: [^self notify: 'Group descriptor should be terminated by <:>'].
	group := MailGroupDescriptor new.

	"If phrase is non-empty, an alias was specified"
	phrasex := phrase isEmpty 
		    ifTrue: [nil]
		    ifFalse: [self phraseAsString: phrase].
	comment := currentComment isNil 
		    ifTrue: [nil]
		    ifFalse: 
			[stream := (String new: 40) writeStream.
			currentComment do: [:part | stream nextPutAll: part]
			    separatedBy: [stream space].
			stream contents].
	group
	    alias: phrasex;
	    addresses: mailboxes;
	    comment: comment.
	^group
    ]

    parseMailboxSpecWith: phrasex [
	"address     =  mailbox                      ; one addressee
	 /  group                        ; named list
	 group       =  phrase <:> [#mailbox] <;>
	 mailbox     =  addr-spec                    ; simple address
	 /  phrase route-addr            ; name & addr-spec
	 route-addr  =  <<> [route] addr-spec <>>
	 route       =  1#(<@> domain) <:>           ; path-relative"

	<category: 'private'>
	| phrase tok local stream comment |
	phrase := phrasex.
	tok := self nextRFC822Token.
	self descriptor: self newAddressDescriptor.

	"Variations of mailbox spec"
	tok = $< 
	    ifTrue: 
		["Phil Campbell<philc@acme.com>"

		self
		    stepBack;
		    scanRouteAndAddress]
	    ifFalse: 
		[('.@' includes: tok) 
		    ifTrue: 
			["These ones should have a non-empty local part to the left of delimiter"

			phrase isEmpty ifTrue: [self error: 'Invalid network address'].
			local := Array with: phrase last.
			phrase := phrase copyFrom: 1 to: phrase size - 1.	"Extract the part we already scanned"
			tok = $. 
			    ifTrue: 
				["phil.campbell.wise@acme.com>"

				self
				    stepBack;
				    completeScanOfAddressSpecWith: local].
			tok = $@ 
			    ifTrue: 
				["philc@acme.com>"

				self descriptor localPart: local.
				self descriptor domain: self scanDomain]]
		    ifFalse: [self stepBack]].
	"If phrase is non-empty, an alias was specified"
	phrase := phrase isEmpty 
		    ifTrue: [phrase := nil]
		    ifFalse: [self phraseAsString: phrase].
	self descriptor alias: phrase.
	comment := currentComment isNil 
		    ifTrue: [nil]
		    ifFalse: 
			[stream := (String new: 40) writeStream.
			currentComment do: [:part | stream nextPutAll: part]
			    separatedBy: [stream space].
			stream contents].
	self descriptor comment: comment.
	^self descriptor
    ]

    scanLocalAddressPartTo: stream [
	"local-part = word *(<.> word) ; uninterpreted, case-preserved
	 Part of local part may have been scanned already, it's in localPart of the descriptor"

	<category: 'private'>
	self tokenizeWhile: [token == $.] do: [stream nextPut: self scanWord].
	^stream contents
    ]

    tryScanSubdomain [
	<category: 'private'>
	self nextRFC822Token.
	tokenType = #atom ifTrue: [^true].
	token = $[ 
	    ifTrue: 
		[self
		    stepBack;
		    scanDomainText.
		^true].
	^false
    ]

    addressesFrom: stream [
	<category: 'public'>
	^(self on: stream) parseAddressesSeparatedBy: $,
    ]

    parse: aString [
	<category: 'public'>
	^self
	    on: aString readStream;
	    parseAddress
    ]

    parseAddress [
	"address     =  mailbox                      ; one addressee
	 /  group                        ; named list
	 group       =  phrase <:> [#mailbox] <;>
	 mailbox     =  addr-spec                    ; simple address
	 /  phrase route-addr            ; name & addr-spec
	 route-addr  =  <<> [route] addr-spec <>>
	 route       =  1#(<@> domain) <:>           ; path-relative"

	<category: 'public'>
	| phrase |
	phrase := self scanPhrase.
	^self nextRFC822Token = $: 
	    ifTrue: [self parseGroupSpecWith: phrase]
	    ifFalse: 
		[self
		    stepBack;
		    parseMailboxSpecWith: phrase]
    ]

    parseAddressesSeparatedBy: separatorChar [
	<category: 'public'>
	| addresses |
	addresses := self tokenizeList: [self parseAddress]
		    separatedBy: [token == separatorChar].
	^addresses
    ]

    scanDomain [
	"domain = sub-domain *(<.> sub-domain)"

	"Answers an array of domain seqments, from least significant to most significant"

	<category: 'public'>
	^self tokenizeList: 
		[self nextRFC822Token.
		tokenType = #atom 
		    ifTrue: [token]
		    ifFalse: 
			[token = $[ 
			    ifTrue: 
				[self
				    stepBack;
				    scanDomainText]
			    ifFalse: [^self notify: 'Invalid domain specification']]]
	    separatedBy: [token == $.]
    ]

    scanLocalAddress [
	"local-part = word *(<.> word) ; uninterpreted, case-preserved"

	<category: 'public'>
	^self tokenizeList: 
		[self nextRFC822Token.
		(#(#quotedText #atom) includes: tokenType) 
		    ifFalse: [^self notify: 'Local part can only include words'].
		token]
	    separatedBy: [token == $.]
    ]

    scanRoute [
	"route = 1#(<@> domain) <:> ; path-relative"

	<category: 'public'>
	| stream |
	stream := (Array new: 2) writeStream.
	[self nextRFC822Token == $@] whileTrue: 
		[stream nextPut: self scanDomain.
		self nextToken = $: ifFalse: [self error: 'Invalid route spec']].
	stream size = 0 ifTrue: [self error: 'Invalid route spec'].
	^stream contents
    ]

    scanRouteAndAddress [
	"route-addr  =  <<> [route] addr-spec <>>"

	<category: 'public'>
	self mustMatch: $< notify: 'Invalid route address spec'.
	self nextRFC822Token == $@ 
	    ifTrue: 
		[self stepBack.
		self descriptor route: self scanRoute].
	self completeScanOfAddressSpecWith: (Array with: token).
	self mustMatch: $> notify: 'Invalid route address spec'
    ]
]

]



Namespace current: NetClients.MIME [

StructuredHeaderField subclass: ContentTypeField [
    | type subtype |
    
    <category: 'NetClients-MIME'>
    <comment: 'This class represents MIME and HTTP Content-type header field. Format and semantics of this field are defined in the following documents:
    RFC2045: MIME, Part One: Format of Internet Message Bodies (ftp.uu.net/inet/rfc/rfc2045.Z)
    RFC2046: MIME, Part Two: Media Types (ftp.uu.net/inet/rfc/rfc2046.Z)
    RFC2068: Hyptertext Transfer Protocol -- HTTP/1.1 (ftp.uu.net/inet/rfc/rfc2068.Z)
As well as some other supplementary documents such as RFC2110 (ftp.uu.net/inet/rfc/rfc2110.Z)

The purpose of this field is to describe the data containing in the message body fully enough that the receiving side can pick an appropriate mechanism to handle the data in an appropriate manner. The value of this field is called a media type.

The value of media type consists of media type and subtype identifiers as well as auxiliary information required for certain media types. Auxiliary information is parsed and stored as field parameters. Utility methods are provided to simplify access to the most common parameters such as charset.

Currently defined top level media types are as follows:

    text, image, audio, video, multipart

Default is
    text/plain; charset=us-ascii

Instance Variables:
    type    <String>  Top level media type
    subtype    <String>  Media subtype
'>

    ContentTypeField class >> default [
	<category: 'defaults'>
	^self fromLine: 'content-type: text/plain; charset=us-ascii'
    ]

    ContentTypeField class >> defaultCharset [
	<category: 'defaults'>
	^'us-ascii'
    ]

    ContentTypeField class >> defaultContentType [
	<category: 'defaults'>
	^'text/plain'
    ]

    ContentTypeField class >> urlEncoded [
	<category: 'defaults'>
	^self 
	    fromLine: 'content-type: application/x-www-form-urlencoded; charset=us-ascii'
    ]

    ContentTypeField class >> fieldNames [
	<category: 'parsing'>
	^#('content-type')
    ]

    boundary [
	<category: 'accessing'>
	^self parameterAt: 'boundary'
    ]

    boundary: aString [
	<category: 'accessing'>
	^self parameterAt: 'boundary' put: aString
    ]

    charset [
	<category: 'accessing'>
	^(self parameterAt: 'charset' ifAbsent: [^self class defaultCharset]) 
	    asLowercase
    ]

    contentType [
	<category: 'accessing'>
	^type , '/' , subtype
    ]

    subtype [
	<category: 'accessing'>
	^subtype
    ]

    subtype: aString [
	<category: 'accessing'>
	subtype := aString
    ]

    type [
	<category: 'accessing'>
	^type
    ]

    type: aString [
	<category: 'accessing'>
	type := aString
    ]

    multipartType [
	<category: 'constants'>
	^'multipart'
    ]

    parse: rfc822Stream [
	"RFC2045: content := <Content-Type> <:> type </> subtype *(<;> parameter)"

	<category: 'parsing'>
	type := rfc822Stream nextToken asLowercase.
	rfc822Stream mustMatch: $/
	    notify: 'Content type must be specified as type/subtype'.
	subtype := rfc822Stream nextToken asLowercase.
	self readParametersFrom: rfc822Stream
    ]

    printStructureOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self contentType.
	self printParametersOn: aStream
    ]

    isMultipart [
	<category: 'testing'>
	^type = 'multipart'
    ]
]

]



Namespace current: NetClients.MIME [

ScalarField subclass: VersionField [
    | majorVersion minorVersion |
    
    <category: 'NetClients-MIME'>
    <comment: 'I represent version fields such as MIME or HTTP version field. My value has a form <major version><.><minor version>. Value of this field is its version strung; methods are provided to read (or construct version from) its constituent parts


Instance Variables:
    majorVersion    <String>    comment
    minorVersion    <String>  comment
'>

    VersionField class >> fieldNames [
	<category: 'parsing'>
	^#('mime-version' 'http-version')
    ]

    majorVersion [
	<category: 'accessing'>
	^majorVersion
    ]

    majorVersion: number [
	<category: 'accessing'>
	majorVersion := number
    ]

    minorVersion [
	<category: 'accessing'>
	^minorVersion
    ]

    minorVersion: number [
	<category: 'accessing'>
	minorVersion := number
    ]

    value [
	<category: 'accessing'>
	^self version
    ]

    value: string [
	<category: 'accessing'>
	self version: string
    ]

    version [
	<category: 'accessing'>
	^majorVersion , '.' , minorVersion
    ]

    version: string [
	<category: 'accessing'>
	| arr |
	arr := string subStrings: $..
	arr size < 2 
	    ifTrue: 
		[self 
		    notify: 'Version should be specified as <major version>.<minor version>'].
	self majorVersion: arr first.
	self minorVersion: arr last
    ]
]

]



Namespace current: NetClients.MIME [

ScalarField subclass: SingleMailboxField [
    
    <category: 'NetClients-MIME'>
    <comment: 'This class is used to represent RFC822 fields whose value is a single mailbox or network address. Value of this field is its mailbox descriptor. Examples of single mailbox field are ''Sender:'' and ''Resent-Sender''. Note that the absolute majority of address fields may contain multiple addresses and, therefore, are instantiated as MailBoxListFields.'>

    SingleMailboxField class >> fieldNames [
	<category: 'parsing'>
	^#('sender' 'resent-sender')
    ]

    address [
	<category: 'accessing'>
	^self value
    ]

    address: address [
	<category: 'accessing'>
	self value: address
    ]

    addresses [
	<category: 'accessing'>
	^{self address}
    ]

    addresses: aCollection [
	<category: 'accessing'>
	aCollection size = 1 
	    ifFalse: [self error: 'can only contain a single address'].
	aCollection do: [:theOnlyAddress | self value: theOnlyAddress]
    ]

    parse: rfc822Stream [
	"HeaderField fromLine: 'Sender :        Phil Campbell (The great) <philc@yahoo.com>'"

	<category: 'parsing'>
	self value: (NetworkAddressDescriptor addressFrom: rfc822Stream)
    ]
]

]



Namespace current: NetClients.MIME [

ScalarField subclass: MailboxListField [
    
    <category: 'NetClients-MIME'>
    <comment: 'I am used to represent most of RFC822 address fields. My value is a sequenceable collection of mailbox or mail group descriptors. Examples of this field are ''From'', ''To'', ''Cc'', ''Bcc'', etc'>

    MailboxListField class >> fieldNames [
	<category: 'parsing'>
	^#('from' 'to' 'reply-to' 'cc' 'bcc' 'resent-reply-to' 'resent-from' 'resent-to' 'resent-cc' 'resent-bcc')
    ]

    addAddress: address [
	<category: 'accessing'>
	^self addAddresses: (Array with: address)
    ]

    addAddresses: aCollection [
	<category: 'accessing'>
	self value addAll: aCollection
    ]

    address [
	<category: 'accessing'>
	self value first
    ]

    address: address [
	<category: 'accessing'>
	self value isEmpty ifTrue: [self value: (OrderedCollection new: 1)].
	self value at: 1 put: address
    ]

    addresses [
	<category: 'accessing'>
	^self value
    ]

    addresses: aCollection [
	<category: 'accessing'>
	self value: aCollection
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	value := OrderedCollection new
    ]

    parse: rfc822Stream [
	"HeaderField fromLine: 'To       :  George Jones <Group@Some-Reg.An-Org>,
	 Al.Neuman@MAD.Publisher'"

	<category: 'parsing'>
	self value: (NetworkAddressDescriptor addressesFrom: rfc822Stream)
    ]

    printValueOn: aStream [
	<category: 'printing'>
	| val |
	(val := self value) notNil 
	    ifTrue: 
		[val do: [:each | each printOn: aStream]
		    separatedBy: 
			[aStream
			    nextPutAll: ', ';
			    nl;
			    tab]]
    ]
]

]



Namespace current: NetClients.MIME [
    SimpleScanner initialize.
    RFC822Scanner initialize
]

PK
     �Mh@A�Z4  4            ��    HTTP.stUT dqXOux �  �  PK
     �Mh@Y�~�H H           ��T4  IMAP.stUT dqXOux �  �  PK
     �[h@�s�Z  Z            ���L package.xmlUT ǉXOux �  �  PK
     �Mh@#�x��<  �<            ��|O FTP.stUT dqXOux �  �  PK
     �Mh@���(}  }            ���� Base.stUT dqXOux �  �  PK
     �Mh@��2A�D  �D            �� 
 NNTP.stUT dqXOux �  �  PK
     �Mh@d���              ���N NetServer.stUT dqXOux �  �  PK
     �Mh@�xI  xI            ��1e IMAPTests.stUT dqXOux �  �  PK
     �Mh@3��.G#  G#            ��� POP.stUT dqXOux �  �  PK
     �Mh@���f�&  �&            ��v� ContentHandler.stUT dqXOux �  �  PK    �Mh@R�*PM  �@  	         ���� ChangeLogUT dqXOux �  �  PK
     �Mh@�k�^K(  K(            ��* SMTP.stUT dqXOux �  �  PK
     �Mh@��g�^�  ^�            ���3 URIResolver.stUT dqXOux �  �  PK
     �Mh@���㖋 ��           ��\� MIME.stUT dqXOux �  �  PK      U  3Z   