PK    �Mh@��\��  �    find.jpgUT	 dqXO#�XOux �  �  ��y4�k��ٻ�D�rD�V��A�(ג�,s���2�Ҩ	ٙ�[Ӥ�-[��S��Ȓ�2�_f����T�sn�~��wy��9��yߗ����jg}��@  "h ���[P��������G돶��	�d md7 EB`H�(Ή�'-�U(�j�P��8\�,�p$BJQ�\H��Wxw���+�E"J����}����Ǌ�����oߣ��w����������a+k�#v.�]��=N��?p:0���@�����������7��o���%S�Q�<�zT]S[W���������?����G^�e��?LLNM�a/-ZY]?�orA ط��+R���ap�M.�¦	G(�I�;	��H��ED�"���UT����>1��.s{��ρ��/�o`߹F	Dpy0$`����l���Þ�3��c��!��-�Y�Y�;��J�o�D7�O��*U�o�����������|�M�c��<�n��+�D�C���5���<���>$�T]]���ޠn�=S��:�� ���n�m	�'�7��E�'Q�Z@�0���О�$�0���%q1d\���i�϶bIT/L�'��T����t�k�n�\r޻ܮ�`Óo�\����"��\y�0�8k��U�k���
)�{���,G���b.֧���H���К8�y~�dl	#G���Y�K�@�2��\ʼ���{�Qa�$�j����ݹE����Vg�Eǟ5Ѽ�^�~��X�Ƶ��Ĭr�`߹]��ER�A�ݝه�E͌^����M*��/���F�>���8"�z�N��c���r9�+q���{hz[$�yφ�>�/��''��V*M�t]�sk,I��n c�E	��)t��2�XVѶ1�����W����F�ݧ����
�xMZi5'g�2HWݳ��>��<��OR��cӦR�ҋOѠ�&���Ü�Y��|*x:�4��F}Q� �f�F��8b7UQz-Y�9���¼�f͔��t	;GB:�ݡ�w�������Ѭ�����-�	A�;v)�3�H��U�%FG\��t�-��)4�Ӽ�!�}Q�qRB��)�Ǒ]��,��4qiĮϗ'�����Ģ<����=����r��/���s�&<o3J��`��r�AW�8#J�e- �_;Q�ڃ�3Q���`�~��\���D�
㌘����lV�}�+ߡ�6�eo�=F��pZrW���(f�v�d�B4�sԸG�A��z4�KHe�4⓰�U\�Bs�f{J�Y�f������%O��4���W�߹�v�v���y����7�&�F�t�_Z��Ւ�p�����|�5
¡�F���@����?�א���T�;_��N!�V�7
�f[�g5�(z�E�	]�Yw���uw��H��=�gr�s��[ɳ^�g)�d{<��޴�p���E��W�P�U��Y+�ZT��Z�5��cUv9�����,&W�`�#'R�C7n��-���|*��.o��J��i劕��0���PK
     �Mh@��|�E�  E�    WebServer.stUT	 dqXO#�XOux �  �  "======================================================================
|
|   Generic web-server framework
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001 Travis Griggs and Ken Treis
| Written by Travis Griggs, Ken Treis and others.
| Port to GNU Smalltalk, enhancements and refactoring by Paolo Bonzini.
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



NetServer subclass: WebServer [
    | virtualHosts defaultVirtualHost log |
    
    <comment: 'A WebServer keeps a socket listening on a port, and dispatches incoming
requests to Servlet objects.  Thus, it is extremely expandable through
`servlets'' which subclass Servlet.  A separate Process is devoted to HTTP
serving.'>
    <category: 'Web-Framework'>

    Version := nil.

    WebServer class >> version [
	<category: 'accessing'>
	| number |
	Version isNil ifFalse: [^Version].
	number := Smalltalk version subStrings 
		    detect: [:each | (each at: 1) isDigit]
		    ifNone: 
			["???"

			'0.0'].
	^Version := 'GNU-WikiWorks/' , number
    ]

    log: action uri: location time: time [
	"self times nextPut: (Array with: action with: location with: time)"

	<category: 'logging'>
	Transcript
	    print: time;
	    space;
	    nextPutAll: action;
	    space;
	    print: location;
	    nl
    ]

    log [
	"self times"

	<category: 'logging'>
	log isNil ifTrue: [log := WriteStream on: Array new].
	^log
    ]

    depth [
	<category: 'accessing'>
	^-1
    ]

    addVirtualHost: aServlet [
	<category: 'accessing'>
	virtualHosts addComponent: aServlet
    ]

    defaultVirtualHost [
	<category: 'accessing'>
	^defaultVirtualHost
    ]

    defaultVirtualHost: anHost [
	<category: 'accessing'>
	virtualHosts rootServlet: (virtualHosts componentNamed: anHost).
	defaultVirtualHost := anHost
    ]

    handler [
	<category: 'accessing'>
	^virtualHosts rootServlet
    ]

    handler: aServlet [
	<category: 'accessing'>
	aServlet name: self defaultVirtualHost.
	virtualHosts
	    addComponent: aServlet;
	    rootServlet: aServlet
    ]

    respondTo: aRequest [
	<category: 'accessing'>
	| host handler |
	host := aRequest at: #HOST ifAbsent: [self defaultVirtualHost].
	(virtualHosts hasComponentNamed: host) 
	    ifFalse: [host := self defaultVirtualHost].
	(virtualHosts componentNamed: host) respondTo: aRequest
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	virtualHosts := CompositeServlet new.
	virtualHosts parent: self.
	self
	    defaultVirtualHost: Sockets.SocketAddress localHostName;
	    handler: CompositeServlet new
    ]

    uriOn: aStream [
	<category: 'private'>
	aStream nextPutAll: 'http:/'
    ]

    newSession [
	<category: 'private'>
	^WebSession new
    ]
]



NetSession subclass: WebSession [
    
    <comment: 'A WebSession is the NetSession object created by a WebServer.'>
    <category: 'Web-Framework'>

    next [
	<category: 'private'>
	^WebRequest for: self socket
    ]

    log: req time: time [
	<category: 'private'>
	self server 
	    log: req action
	    uri: req location
	    time: time
    ]
]



Object subclass: Servlet [
    | name parent |
    
    <category: 'Web-Framework'>
    <comment: 'A Servlet handles WebRequests that are given to it. WebRequests 
come from a WebServer, but often a Servlet will pass them on to
other Servlets.  Thus, sometimes there is a tree of Servlets.'>

    Servlet class >> named: aString [
	<category: 'instance creation'>
	^(self new)
	    name: aString;
	    yourself
    ]

    depth [
	<category: 'accessing'>
	^parent depth + 1
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aString [
	<category: 'accessing'>
	name := aString
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: anObject [
	<category: 'accessing'>
	parent := anObject
    ]

    uriOn: aStream [
	<category: 'accessing'>
	self printOn: aStream
    ]

    printOn: aStream [
	<category: 'accessing'>
	parent uriOn: aStream.
	self name isNil ifTrue: [^self].
	aStream nextPut: $/.
	aStream nextPutAll: self name
    ]
]



Servlet subclass: CompositeServlet [
    | components rootServlet errorServlet |
    
    <category: 'Web-Framework'>
    <comment: 'Handles a request by looking at the next name in the path.  If there is
no name, it uses the root handler. If there is no handler for the name,
uses the error handler.  Names are case sensitive.'>

    CompositeServlet class >> new [
	<category: 'instance creation'>
	^self onError: ErrorServlet new
    ]

    CompositeServlet class >> onError: aServlet [
	<category: 'instance creation'>
	^self onError: aServlet onRoot: ServletList new
    ]

    CompositeServlet class >> onError: aServlet onRoot: anotherServlet [
	<category: 'instance creation'>
	^super new onError: aServlet onRoot: anotherServlet
    ]

    errorServlet [
	<category: 'accessing'>
	^errorServlet
    ]

    errorServlet: aServlet [
	<category: 'accessing'>
	errorServlet := aServlet.
	aServlet parent: self
    ]

    rootServlet [
	<category: 'accessing'>
	^rootServlet
    ]

    rootServlet: aServlet [
	<category: 'accessing'>
	rootServlet := aServlet.
	aServlet parent: self
    ]

    addComponent: aServlet [
	<category: 'accessing'>
	components at: aServlet name put: aServlet.
	aServlet parent: self
    ]

    componentNamed: aString [
	<category: 'accessing'>
	^components at: aString ifAbsent: [errorServlet]
    ]

    components [
	<category: 'accessing'>
	^components copy
    ]

    hasComponentNamed: aString [
	<category: 'accessing'>
	^components includesKey: aString
    ]

    onError: aServlet onRoot: anotherServlet [
	<category: 'initialize release'>
	components := Dictionary new.
	self errorServlet: aServlet.
	self rootServlet: anotherServlet.
	anotherServlet parent: self
    ]

    respondTo: aRequest [
	<category: 'interaction'>
	| componentName |
	aRequest location size < self depth 
	    ifTrue: [^rootServlet respondTo: aRequest].
	componentName := aRequest location at: self depth.
	(self hasComponentNamed: componentName) 
	    ifFalse: [^errorServlet respondTo: aRequest].
	^(self componentNamed: componentName) respondTo: aRequest
    ]
]



Servlet subclass: ServletList [
    
    <category: 'Web-Framework'>
    <comment: 'A ServletList output a list of servlets that are children of its parent.
It is typically used as the root handler of a CompositeServlet.'>

    respondTo: aRequest [
	<category: 'interaction'>
	| stream |
	stream := aRequest stream.
	parent components isEmpty 
	    ifTrue: 
		[^(ErrorResponse unavailable)
		    respondTo: aRequest;
		    nl].
	aRequest pageFollows.
	stream
	    nextPutAll: '<HTML><TITLE>Top page</TITLE><BODY>';
	    nl.
	stream
	    nextPutAll: '<H2>Welcome to my server!!</H2>';
	    nl.
	stream
	    nextPutAll: 'This server contains the following sites:';
	    nl.
	stream
	    nextPutAll: '<UL>';
	    nl.
	parent components keys asSortedCollection do: 
		[:each | 
		stream
		    nextPutAll: '  <LI><A HREF="/';
		    nextPutAll: each;
		    nextPutAll: '">';
		    nextPutAll: each;
		    nextPutAll: '</A>';
		    nextPutAll: ', a ';
		    print: (parent componentNamed: each) class;
		    nl].
	stream
	    nextPutAll: '</UL>';
	    nl.
	stream
	    nextPutAll: '</BODY></HTML>';
	    nl;
	    nl
    ]
]



Servlet subclass: ErrorServlet [
    
    <category: 'Web-Framework'>
    <comment: 'An ErrorServlet gives a 404 (not found) or 503 (unavailable) error,
depending on whether its parent has children or not.  It is typically used
as the error handler of a CompositeServlet.'>

    respondTo: aRequest [
	<category: 'interaction'>
	| response |
	response := parent components isEmpty 
		    ifFalse: [ErrorResponse notFound]
		    ifTrue: [ErrorResponse unavailable].
	(#('HEAD' 'GET' 'POST') includes: aRequest action) 
	    ifFalse: [response := ErrorResponse acceptableMethods: #('HEAD' 'GET' 'POST')].
	response respondTo: aRequest
    ]
]



Stream subclass: WebResponse [
    | responseStream request |
    
    <category: 'Web-Framework'>
    <comment: 'WebResponse is an object that can emit an HTTP entity.  There can be
different subclasses of WebResponse for the various ways a page can be
rendered, such as errors, files from the file system, or Wiki pages.
Although you are not forced to use WebResponse to respond to requests
in your Servlet, doing so means that a good deal of code is already
there for you, including support for emitting headers, distinguishing
HEAD requests, HTTP/1.1 multi-request connections, and If-Modified-Since
queries.

All subclasses must implement sendBody.'>

    << anObject [
	<category: 'streaming'>
	responseStream display: anObject
    ]

    nl [
	<category: 'streaming'>
	responseStream nl
    ]

    nextPut: aCharacter [
	<category: 'streaming'>
	responseStream nextPut: aCharacter
    ]

    nextPutUrl: aString [
	<category: 'streaming'>
	responseStream nextPutAll: (URL encode: aString)
    ]

    nextPutAll: aString [
	<category: 'streaming'>
	responseStream nextPutAll: aString
    ]

    do: aBlock [
	<category: 'streaming'>
	self shouldNotImplement
    ]

    next [
	<category: 'streaming'>
	self shouldNotImplement
    ]

    atEnd [
	<category: 'streaming'>
	^true
    ]

    isErrorResponse [
	<category: 'testing'>
	^false
    ]

    modifiedTime [
	<category: 'response'>
	^DateTime now
    ]

    respondTo: aRequest [
	<category: 'response'>
	responseStream := aRequest stream.
	request := aRequest.
	self notModified 
	    ifTrue: [self sendNotModifiedResponse]
	    ifFalse: 
		[self sendHeader.
		aRequest isHead ifFalse: [self sendBody]].
	responseStream := request := nil
    ]

    notModified [
	<category: 'response'>
	| ifModSince modTime |
	ifModSince := request dateTimeAt: #'IF-MODIFIED-SINCE' ifAbsent: [nil].
	modTime := self modifiedTime.
	^ifModSince notNil and: [modTime <= ifModSince]
    ]

    request [
	<category: 'response'>
	^request
    ]

    responseStream [
	<category: 'response'>
	^responseStream
    ]

    sendBody [
	<category: 'response'>
	
    ]

    contentLength [
	<category: 'response'>
	^nil
    ]

    sendHeader [
	<category: 'response'>
	| stream |
	stream := responseStream.
	responseStream := CrLfStream on: stream.
	self sendResponseType.
	self sendServerHeaders.
	self sendStandardHeaders.
	self sendModifiedTime.
	self sendMimeType.
	self sendHeaderSeparator.

	"Send the body as binary"
	responseStream := stream
    ]

    sendHeaderSeparator [
	<category: 'response'>
	self nl
    ]

    sendNotModifiedResponse [
	<category: 'response'>
	^self
	    nextPutAll: 'HTTP/1.1 304 Not modified';
	    sendServerHeaders;
	    sendModifiedTime;
	    sendHeaderSeparator;
	    yourself
    ]

    sendMimeType [
	<category: 'response'>
	self
	    nextPutAll: 'Content-Type: text/html';
	    nl
    ]

    sendResponseType [
	<category: 'response'>
	self
	    nextPutAll: 'HTTP/1.1 200 Page follows';
	    nl
    ]

    sendServerHeaders [
	<category: 'response'>
	self
	    nextPutAll: 'Date: ';
	    sendTimestamp: DateTime now;
	    nl;
	    nextPutAll: 'Server: ';
	    nextPutAll: WebServer version;
	    nl
    ]

    sendStandardHeaders [
	<category: 'response'>
	| length |
	length := self contentLength.
	length isNil 
	    ifTrue: [request moreRequests: false]
	    ifFalse: 
		[self
		    << 'Content-Length: ';
		    << length;
		    nl].
	self
	    << 'Connection: ';
	    << (request at: #Connection);
	    nl
    ]

    sendModifiedTime [
	<category: 'response'>
	self
	    << 'Last-Modified: ';
	    sendTimestamp: self modifiedTime;
	    nl
    ]

    sendTimestamp: aTimestamp [
	<category: 'response'>
	| utc |
	utc := aTimestamp offset = Duration zero 
		    ifTrue: [aTimestamp]
		    ifFalse: [aTimestamp asUTC].
	self
	    nextPutAll: aTimestamp dayOfWeekAbbreviation;
	    nextPutAll: (aTimestamp day < 10 ifTrue: [', 0'] ifFalse: [', ']);
	    print: aTimestamp day;
	    space;
	    nextPutAll: aTimestamp monthAbbreviation;
	    space;
	    print: aTimestamp year;
	    space;
	    print: aTimestamp asTime;
	    nextPutAll: ' GMT'
    ]

    lineBreak [
	<category: 'html'>
	self
	    << '<BR>';
	    nl
    ]

    heading: aBlock [
	<category: 'html'>
	self heading: aBlock level: 1
    ]

    heading: aBlock level: anInteger [
	<category: 'html'>
	self << '<H' << anInteger << '>'.
	aBlock value.
	self
	    << '</H';
	    << anInteger;
	    << '>';
	    nl
    ]

    horizontalLine [
	<category: 'html'>
	self
	    << '<HR>';
	    nl
    ]

    image: fileNameBlock linkTo: urlBlock titled: titleBlock [
	<category: 'html'>
	self << '<A href="'.
	urlBlock value.
	self << '"><IMG src="'.
	fileNameBlock value.
	self << '" alt="'.
	titleBlock value.
	self << '" border=0></A>'
    ]

    image: fileNameBlock titled: titleBlock [
	<category: 'html'>
	self << '<IMG src="'.
	fileNameBlock value.
	self << '" alt="'.
	titleBlock value.
	self << '">'
    ]

    linkTo: urlBlock titled: titleBlock [
	<category: 'html'>
	self << '<A href="'.
	urlBlock value.
	self << '">'.
	titleBlock value.
	self << '</A>'
    ]

    listItem: aBlock [
	<category: 'html'>
	self << '<LI>'.
	aBlock value.
	self
	    << '</LI>';
	    nl
    ]

    monospace: aBlock [
	<category: 'html'>
	self << '<PRE>'.
	aBlock value.
	self
	    << '</PRE>';
	    nl
    ]

    para: aBlock [
	<category: 'html'>
	self << '<P>'.
	aBlock value.
	self
	    << '</P>';
	    nl
    ]

    bold: aBlock [
	<category: 'html'>
	self << '<B>'.
	aBlock value.
	self
	    << '</B>';
	    nl
    ]

    italic: aBlock [
	<category: 'html'>
	self << '<I>'.
	aBlock value.
	self
	    << '</I>';
	    nl
    ]

    tr: aBlock [
	<category: 'html'>
	self << '<TR>'.
	aBlock value.
	self
	    << '</TR>';
	    nl
    ]

    td: aBlock [
	<category: 'html'>
	self << '<TD>'.
	aBlock value.
	self
	    << '</TD>';
	    nl
    ]
]



Object subclass: WebRequest [
    | originator stream action clientData postData location uri |
    
    <category: 'Web-Framework'>
    <comment: 'WebRequests know how to parse HTTP requests, organizing the data
according to the requested header fields and to the form keys
(encoded in the URL for GET requests and in the request for POST
requests).'>

    EndOfLine := nil.
    EndOfRequest := nil.

    WebRequest class >> initialize [
	<category: 'initialization'>
	EndOfLine := String with: Character cr with: Character nl.
	EndOfRequest := EndOfLine , EndOfLine
    ]

    WebRequest class >> for: aClientConnection [
	<category: 'instance creation'>
	^self new initConnection: aClientConnection
    ]

    WebRequest class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    action [
	<category: 'accessing'>
	^action
    ]

    action: aString [
	<category: 'accessing'>
	action := aString
    ]

    at: aSymbol [
	<category: 'accessing'>
	^clientData at: aSymbol
    ]

    at: aSymbol ifAbsent: aBlock [
	<category: 'accessing'>
	^clientData at: aSymbol ifAbsent: aBlock
    ]

    at: aSymbol ifPresent: aBlock [
	<category: 'accessing'>
	^clientData at: aSymbol ifPresent: aBlock
    ]

    dateTimeAt: aSymbol [
	<category: 'accessing'>
	^self parseTimestamp: (clientData at: aSymbol)
    ]

    dateTimeAt: aSymbol ifAbsent: aBlock [
	<category: 'accessing'>
	^self parseTimestamp: (clientData at: aSymbol ifAbsent: [^aBlock value])
    ]

    dateTimeAt: aSymbol ifPresent: aBlock [
	<category: 'accessing'>
	^clientData at: aSymbol
	    ifPresent: [:value | aBlock value: (self parseTimestamp: value)]
    ]

    enumeratePostData: aBlock [
	<category: 'accessing'>
	postData keysAndValuesDo: aBlock
    ]

    getRequest [
	<category: 'accessing'>
	| saveStream version |
	saveStream := stream.
	stream := CrLfStream on: saveStream.
	self extractAction.
	self extractLocation.
	version := stream upTo: Character cr.
	stream next.	"Get nl"
	self extractClientData: version.
	(action sameAs: 'POST') 
	    ifTrue: 
		[self extractPostData: version
		    contentLength: (clientData at: #'CONTENT-LENGTH' ifAbsent: [nil])].

	"Get back to binary mode"
	stream := saveStream
    ]

    hasPostData [
	<category: 'accessing'>
	^postData notEmpty
    ]

    postDataAt: aSymbol ifPresent: aBlock [
	<category: 'accessing'>
	^postData at: aSymbol ifPresent: aBlock
    ]

    location [
	<category: 'accessing'>
	^location
    ]

    isHead [
	<category: 'accessing'>
	^action sameAs: 'HEAD'
    ]

    originator [
	<category: 'accessing'>
	^originator
    ]

    pageFollows [
	<category: 'accessing'>
	WebResponse new respondTo: self
    ]

    moreRequests [
	<category: 'accessing'>
	^(self at: #Connection) sameAs: 'keep-alive'
    ]

    moreRequests: aBoolean [
	<category: 'accessing'>
	self at: #Connection
	    put: (aBoolean ifTrue: ['Keep-Alive'] ifFalse: ['close'])
    ]

    postDataAt: aSymbol [
	<category: 'accessing'>
	^postData at: aSymbol
    ]

    postDataAt: aSymbol ifAbsent: aBlock [
	<category: 'accessing'>
	^postData at: aSymbol ifAbsent: aBlock
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: aStream [
	<category: 'accessing'>
	stream := aStream.
	originator := stream remoteAddress name
    ]

    uri [
	<category: 'accessing'>
	^uri
    ]

    initConnection: aClientConnection [
	<category: 'initialize-release'>
	| ec |
	self
	    stream: aClientConnection;
	    getRequest
    ]

    initialize [
	<category: 'initialize-release'>
	postData := IdentityDictionary new.
	clientData := IdentityDictionary new.
	location := OrderedCollection new
    ]

    release [
	<category: 'initialize-release'>
	stream flush.
	self moreRequests ifFalse: [stream close].
	^super release
    ]

    parseTimestamp: ts [
	<category: 'private'>
	| tok d m y time |
	tok := ts subStrings.
	(tok at: 1) last = $, 
	    ifFalse: 
		["asctime:  Sun Nov  6 08:49:37 1994"

		ts size = 5 ifFalse: [^nil].
		m := (ts at: 2) asSymbol.
		d := (ts at: 3) asInteger.
		y := (ts at: 5) asInteger.
		time := ts at: 4.
		^self 
		    makeTimestamp: d
		    month: m
		    year: y
		    time: time].
	(tok at: 1) size = 4 
	    ifTrue: 
		["RFC 822:  Sun, 06 Nov 1994 08:49:37 GMT"

		ts size = 6 ifFalse: [^nil].
		d := (ts at: 2) asInteger.
		m := (ts at: 3) asSymbol.
		y := (ts at: 4) asInteger.
		time := ts at: 5.
		^self 
		    makeTimestamp: d
		    month: m
		    year: y
		    time: time].
	"RFC 850 (obsolete):  Sunday, 06-Nov-94 08:49:37 GMT"
	ts size = 4 ifFalse: [^nil].
	d := ts at: 2.
	time := ts at: 3.
	d size = 9 ifFalse: [^nil].
	y := (d at: 8) base10DigitValue * 10 + (d at: 9) base10DigitValue + 1900.
	m := (d copyFrom: 4 to: 6) asSymbol.
	d := (d at: 1) base10DigitValue * 10 + (d at: 2) base10DigitValue.
	^self 
	    makeTimestamp: d
	    month: m
	    year: y
	    time: time
    ]

    makeTimestamp: d month: m year: y time: t [
	<category: 'private'>
	| month sec |
	t size = 8 ifFalse: [^nil].
	month := #(#Jan #Feb #Mar #Apr #May #Jun #Jul #Aug #Sep #Oct #Nov #Dec) 
		    indexOf: m
		    ifAbsent: [^nil].
	sec := ((t at: 1) base10DigitValue * 10 + (t at: 2) base10DigitValue) 
		    * 3600 
			+ (((t at: 4) base10DigitValue * 10 + (t at: 5) base10DigitValue) * 60) 
			+ ((t at: 7) base10DigitValue * 10 + (t at: 8) base10DigitValue).
	^(DateTime 
	    newDay: d
	    monthIndex: month
	    year: y) addSeconds: sec
    ]

    at: aSymbol put: aValue [
	<category: 'private'>
	^clientData at: aSymbol put: aValue
    ]

    endOfLine [
	<category: 'private'>
	^EndOfLine
    ]

    endOfRequest [
	<category: 'private'>
	^EndOfRequest
    ]

    extractAction [
	<category: 'private'>
	action := stream upTo: Character space
    ]

    extractClientData: clientVersion [
	<category: 'private'>
	"Default depends on version"

	| rs |
	self at: #Connection
	    put: (clientVersion = '1.0' ifTrue: ['close'] ifFalse: ['keep-alive']).
	rs := (stream upToAll: self endOfRequest) readStream.
	[rs atEnd] whileFalse: 
		[self at: (rs upTo: $:) trimSeparators asUppercase asSymbol
		    put: (rs upTo: Character cr) trimSeparators]
    ]

    extractLocation [
	<category: 'private'>
	uri := (stream upToAll: 'HTTP/') trimSeparators.
	location := uri subStrings: $?.
	location isEmpty ifTrue: [self error: 'Empty uri: ' , uri , '.'].
	location size = 2 ifTrue: [self extractQueryData: (location at: 2)].
	location := (location at: 1) subStrings: $/.
	location := location collect: [:each | URL decode: each].
	location := location reject: [:each | each isEmpty]
    ]

    extractPostData: clientVersion contentLength: contentLength [
	<category: 'private'>
	| s |
	clientVersion ~= '1.0' 
	    ifTrue: 
		[stream
		    nextPutAll: 'HTTP/1.1 100 Continue';
		    nl;
		    nl].
	(self at: #'CONTENT-TYPE' ifAbsent: [nil]) 
	    ~= 'application/x-www-form-urlencoded' ifTrue: [^self].

	"TODO: Parse the stream directly, rather than loading it all into
	 memory, because it could be large."
	s := contentLength notNil 
		    ifTrue: [stream next: contentLength asInteger]
		    ifFalse: [stream upTo: Character cr].
	^self extractQueryData: s
    ]

    extractQueryData: query [
	<category: 'private'>
	(query subStrings: $&) do: 
		[:each | 
		| pair |
		pair := each subStrings: $=.
		self postDataAt: (URL decode: pair first) asSymbol
		    put: (URL decode: (pair at: 2 ifAbsent: ['']))]
    ]

    postDataAt: aSymbol put: aValue [
	<category: 'private'>
	^postData at: aSymbol put: aValue
    ]
]



WebResponse subclass: ErrorResponse [
    | errorCode additionalHeaders |
    
    <category: 'Web-Framework'>
    <comment: 'An ErrorResponse generates responses with 3xx, 4xx or 5xx status codes,
together with their explaining HTML entities.'>

    ErrorNames := nil.
    ErrorDescriptions := nil.

    ErrorResponse class >> three [
	<category: 'initialize'>
	^#(#(300 'Multiple Choices' '<P>The requested resource corresponds to any one of a set of
representations. You can select a preferred representation.</P>') #(301 'Moved Permanently' '<P>The requested resource has been assigned a new permanent URL
and any future references to this resource should be done using
one of the returned URLs.</P>') #(302 'Moved Temporarily' '<P>The requested resource resides temporarily under a different
URI.  This is likely to be a response to a POST request which
has to retrieve a fixed entity, since many clients do not interpret
303 responses (See Other) correctly.</P>') #(303 'See Other' '<P>The response to the request can be found under a different
URL and should be retrieved using the supplied Location.</P>') #(304 'Not Modified' '') #(305 'Use Proxy' '<P>The requested resource must be accessed through the proxy given by
the Location field. </P>'))
    ]

    ErrorResponse class >> four [
	<category: 'initialize'>
	^#(#(400 'Bad Request' '<P>The request could not be understood by the server due to malformed
syntax.</P>') #(401 'Unauthorized' '<P>The request requires user authentication.</P>') #(402 'Payment Required' '<P>This code is reserved for future use.</P>') #(403 'Forbidden' '<P>The server understood the request, but is refusing to fulfill it.</P>') #(404 'Not Found' '<P>The requested URL was not found on this server.</P>') #(405 'Method Not Allowed' '<P>The specified method is not allowed for the resource identified by
the specified URL.</P>') #(406 'Not Acceptable' '<P>The resource identified by the request is only capable of generating
response entities which have content characteristics not acceptable
according to the accept headers sent in the request.</P>') #(407 'Proxy Authentication Required' '<P>To proceed, the client must first authenticate itself with the proxy.</P>') #(408 'Request Timeout' '<P>The client did not produce a request within the time that the server
was prepared to wait.</P>') #(409 'Conflict' '<P>The request could not be completed due to a conflict with the current
state of the resource. </P>') #(410 'Gone' '<P>The requested resource is no longer available at the server and no
forwarding address is known. This condition should be considered
permanent.</P>') #(411 'Length Required' '<P>The server refuses to accept the request without a defined
Content-Length header field.</P>') #(412 'Precondition Failed' '<P>The precondition given in one or more of the request-header fields
evaluated to false when it was tested on the server.</P>') #(413 'Request Entity Too Large' '<P>The server is refusing to process a request because the request
entity is larger than the server is willing or able to process.</P>') #(414 'Request-URI Too Long' '<P>The server is refusing to service the request because the requested
URL is longer than the server is willing to interpret. This condition
is most likely due to a client''s improper conversion of a POST request
with long query information to a GET request.</P>') #(415 'Unsupported Media Type' '<P>The server is refusing to service the request because the entity of
the request is in a format not supported by the requested resource
for the requested method.</P>'))
    ]

    ErrorResponse class >> five [
	<category: 'initialize'>
	^#(#(500 'Internal Server Error' '<P>The server encountered an unexpected condition which prevented it
from fulfilling the request.</P>') #(501 'Not Implemented' '<P>The server does not support the functionality required to fulfill the
request. The server does not recognize the request method and is not
capable of supporting it for any resource.</P>') #(502 'Bad Gateway' '<P>The server, while acting as a gateway or proxy, received an invalid
response from the upstream server it accessed in attempting to
fulfill the request.</P>') #(503 'Service Unavailable' '<P>The server is currently unable to handle the request due to a
temporary overloading or maintenance of the server. This is a temporary
condition.</P>') #(504 'Gateway Timeout' '<P>The server, while acting as a gateway or proxy, did not receive a
timely response from the upstream server it accessed in attempting to
complete the request.</P>') #(505 'HTTP Version Not Supported' '<P>The server does not support, or refuses to support, the HTTP protocol
version that was used in the request message.</P>'))
    ]

    ErrorResponse class >> initialize [
	<category: 'initialize'>
	ErrorNames := IdentityDictionary new.
	ErrorDescriptions := IdentityDictionary new.
	self initialize: self three.
	self initialize: self four.
	self initialize: self five
    ]

    ErrorResponse class >> initialize: arrayOfArrays [
	<category: 'initialize'>
	arrayOfArrays do: 
		[:array | 
		ErrorNames at: (array at: 1) put: (array at: 2).
		ErrorDescriptions at: (array at: 1) put: (array at: 3)]
    ]

    ErrorResponse class >> nameAt: error [
	<category: 'accessing'>
	^ErrorNames at: error
	    ifAbsent: 
		[(error < 300 or: [error > 599]) 
		    ifTrue: [self nameAt: 500]
		    ifFalse: [self nameAt: error // 100 * 100]]
    ]

    ErrorResponse class >> descriptionAt: error [
	<category: 'accessing'>
	^ErrorDescriptions at: error
	    ifAbsent: 
		[(error < 300 or: [error > 599]) 
		    ifTrue: [self descriptionAt: 500]
		    ifFalse: [self descriptionAt: error // 100 * 100]]
    ]

    ErrorResponse class >> errorCode: code [
	<category: 'instance creation'>
	^self new errorCode: code
    ]

    ErrorResponse class >> notModified [
	<category: 'instance creation'>
	^self errorCode: 304
    ]

    ErrorResponse class >> noContent [
	<category: 'instance creation'>
	^self errorCode: 204
    ]

    ErrorResponse class >> resetContent [
	<category: 'instance creation'>
	^self errorCode: 205
    ]

    ErrorResponse class >> unavailable [
	<category: 'instance creation'>
	^self errorCode: 503
    ]

    ErrorResponse class >> forbidden [
	<category: 'instance creation'>
	^self errorCode: 403
    ]

    ErrorResponse class >> notFound [
	<category: 'instance creation'>
	^self errorCode: 404
    ]

    ErrorResponse class >> gone [
	<category: 'instance creation'>
	^self errorCode: 410
    ]

    ErrorResponse class >> seeOtherURI: anotherURI [
	<category: 'instance creation'>
	^(self errorCode: 303)
	    addHeader: 'Location: ' , anotherURI;
	    yourself
    ]

    ErrorResponse class >> movedTemporarilyTo: anotherURI [
	<category: 'instance creation'>
	^(self errorCode: 302)
	    addHeader: 'Location: ' , anotherURI;
	    yourself
    ]

    ErrorResponse class >> movedPermanentlyTo: anotherURI [
	<category: 'instance creation'>
	^(self errorCode: 301)
	    addHeader: 'Location: ' , anotherURI;
	    yourself
    ]

    ErrorResponse class >> unauthorized: aString [
	<category: 'instance creation'>
	^(self errorCode: 401)
	    addHeader: 'WWW-Authenticate: ' , aString;
	    yourself
    ]

    ErrorResponse class >> acceptableMethods: anArray [
	<category: 'instance creation'>
	| header |
	header := String streamContents: 
			[:s | 
			s nextPutAll: 'Allow: '.
			anArray do: [:each | s nextPutAll: each] separatedBy: [s nextPutAll: ', ']].
	^(self errorCode: 405)
	    addHeader: header;
	    yourself
    ]

    isErrorResponse [
	<category: 'testing'>
	^true
    ]

    errorCode: code [
	<category: 'initialize'>
	errorCode := code.
	^self
    ]

    addHeader: aString [
	<category: 'initialize'>
	additionalHeaders isNil 
	    ifTrue: [additionalHeaders := OrderedCollection new].
	^additionalHeaders add: aString
    ]

    sendResponseType [
	<category: 'emit'>
	self
	    << 'HTTP/1.1 ';
	    << errorCode;
	    space;
	    << (self class nameAt: errorCode);
	    nl
    ]

    sendStandardHeaders [
	<category: 'emit'>
	super sendStandardHeaders.
	additionalHeaders isNil ifTrue: [^self].
	additionalHeaders do: 
		[:each | 
		self
		    << each;
		    nl]
    ]

    noMessageBody [
	<category: 'emit'>
	^#(204 205 304) includes: errorCode
    ]

    sendBody [
	<category: 'emit'>
	| description |
	self noMessageBody ifTrue: [^self].
	description := self class descriptionAt: errorCode.
	description isEmpty ifTrue: [^self].
	self
	    << '<HTML>';
	    nl;
	    << '<HEAD><TITLE>';
	    << errorCode;
	    space;
	    << (self class nameAt: errorCode);
	    << '</TITLE></HEAD>';
	    nl;
	    << '<BODY>';
	    nl;
	    heading: 
		    [self
			<< errorCode;
			space;
			<< (self class nameAt: errorCode)];
	    << description;
	    << 'originator: ';
	    << request originator displayString;
	    lineBreak;
	    << 'action: ';
	    << request action displayString;
	    lineBreak;
	    << 'location: '.
	request location do: [:each | self << $/ << each].
	request enumeratePostData: 
		[:key :val | 
		self
		    lineBreak;
		    << key;
		    << ' = ';
		    nl;
		    << val;
		    nl].
	self
	    lineBreak;
	    horizontalLine;
	    italic: [self << WebServer version];
	    << '</BODY></HTML>'
    ]
]



Object subclass: WebAuthorizer [
    | authorizer |
    
    <category: 'Web-Framework'>
    <comment: 'A WebAuthorizer checks for the correctness login/password couplets in an
HTTP request using the Basic authentication scheme.'>

    WebAuthorizer class >> fromString: aString [
	<category: 'private'>
	^self new authorizer: aString
    ]

    WebAuthorizer class >> loginID: aLoginID password: aPassword [
	<category: 'private'>
	^(self new)
	    loginID: aLoginID password: aPassword;
	    yourself
    ]

    authorize: aRequest [
	<category: 'accessing'>
	| trial |
	trial := aRequest at: #AUTHORIZATION ifAbsent: [nil].
	^trial = self authorizer
    ]

    authorizer [
	<category: 'accessing'>
	^authorizer
    ]

    authorizer: aString [
	<category: 'accessing'>
	authorizer := aString
    ]

    challengeFor: aServlet [
	<category: 'accessing'>
	^'Basic realm="%1"' % {aServlet name}
    ]

    authorize: aRequest in: aServlet ifAuthorized: aBlock [
	<category: 'accessing'>
	^(self authorize: aRequest) 
	    ifTrue: [aBlock value]
	    ifFalse: 
		[(ErrorResponse unauthorized: (self challengeFor: aServlet)) 
		    respondTo: aRequest.
		^nil]
    ]

    loginID: aName password: aPassword [
	"(self loginID: 'aName' password: 'aPassword') authorizer =
	 'Basic YU5hbWU6YVBhc3N3b3Jk'"

	<category: 'private'>
	| plain plainSize i chars stream |
	aName isNil | aPassword isNil ifTrue: [^nil].
	chars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.
	plain := (aName , ':' , aPassword) asByteArray.
	plainSize := plain size.
	plain size \\ 3 = 0 
	    ifFalse: [plain := plain , (ByteArray new: 3 - (plain size \\ 3))].
	i := 1.
	stream := WriteStream on: String new.
	stream nextPutAll: 'Basic '.
	[i < plain size] whileTrue: 
		[stream
		    nextPut: (chars at: (plain at: i) // 4 + 1);
		    nextPut: (chars at: (plain at: i) \\ 4 * 16 + ((plain at: i + 1) // 16) + 1);
		    nextPut: (chars 
				at: (plain at: i + 1) \\ 16 * 4 + ((plain at: i + 2) // 64) + 1);
		    nextPut: (chars at: (plain at: i + 2) \\ 64 + 1).
		i := i + 3].
	authorizer := stream contents.
	i := authorizer size.
	plain size - plainSize timesRepeat: 
		[authorizer at: i put: $=.
		i := i - 1]
    ]
]



Character extend [

    base10DigitValue [
	<category: 'converting'>
	^self isDigit ifTrue: [self asciiValue - 48] ifFalse: [0]
    ]

]



Eval [
    ErrorResponse initialize.
    WebRequest initialize
]

PK    �Mh@���4  �    edit.jpgUT	 dqXO#�XOux �  �  ��wT�W�L� `*��(ӈ
Eda�B �XF("��������,1*+B�Z�! AV@V@�b�з���9o��}�=������>�{��������� �  D �����P��c�SgН&������� D@Q��w *�9����S(.$,"*&�K`�JP�Ä��pA5VP�!�o�̅e�}E�B��2�E�Oֶ�v�ck���(&.����o����C#�#��&�,��ml�\���x�=牻���@ >,<"2�s�zRrJjZzVvN��y��䗔��?�xH~DyZG��5�����񢳫��e�������#�)����ٹ��E��oܵ�psk���z��ʅpA�p\d���1 �B��	˘;���ʪ�'�ʝ�,�mS7pa�>�O\^�pjg�������7�
|�<�V�Sj��c/�5��h�����N�t?��Q(����Ʀ���!����#QQ�?|t.fX`�ݤqzy)gv�W(r�'J�f����s��G�a��{�qa��/�8e��mB�$(������VF�sB+q��E"l��H�k��Ῠ�`�tG��}ݙ>��!��e_i���/��mJ�����D8ׁ\i}�mS��-��$>��l(mlk�W�4�W!{��nbY����#_7����q�|l\���"� ���~$pߙ��Q))����L�Z%���&:����V$�ɫ�A�h�Ck�c�����+z3Ry�[+˘�4-�Km���uB�V�y{4����I�׳����/[�M��T9�TT�qy{�^�3ڽ��ov:r�����r��pzVF�W�{m&�lα~N�&PX�&]iۚ��mȕ�+b�U�{��K�-��N���u2�>��d����	b�h����֥�U��y�����C}����^^�g����o9��
��F��5��`;lw��L��i�V )sd��؉j��>�R:|k1��T�%;�O���X�r�{cc$�?�o�3@"��^g�ct[�~X�s��L �6�E���va�\7Si�l�}��Ȫk.p���d]ߗm�ԷFT��X�:}�KWT���0���]��4aA�I��6-��6��+�j���Ic�����^��XUV�b��K1J�'���|T��!R�,b�E��p�95��Ѩ~�����oQ���P��4;�;+�P����e��t��vy<ѯ���Ь���f)�{@R���JZ:o?Hr�m6��й珛BKJm�?*�7_AL�����K�]:�h�����-w�kur�}q�k�W�km�����D���������Ὕ��p�3r���Y�eƧF���@RPX!���go�W/q_-��Y]9=�xN�Zw d�������8���C��8�eb�@3�/�`��"����1���a������
t16p�L3�%-mu�xj8��Td�R���MvI�k����b��cW*pӫ�S��r��`M�%���|���ӵZ����0tRr�{��O�s�QҷF��6}����r�<c���R5�����٣?��X�('�ho�-�(cy��p!�dg.�ܨ��>?b&D�w�ē������)&�Z9g۲���ܯp�{��Q�L`� :|��z��th���e�>�զ�LS��{1�iL�-O�i��3�̀��x�x �x��]��NJ�n�ٴ�U�ch��wm���q*x6~�AKhV����3?��^ϋ�eb%
E	��'����ȱT6=9��C�\��r�twb�ԡ��nd�H�V���}�e	�7�U�����4e��|�r$ c `W�(�S��Y���PK    �Mh@\��A      top.jpgUT	 dqXO#�XOux �  �  ��}4�{�{��"��YI����9����f����.�qWN��
�Ja6%yh�,���-�Is=l*Oa#k7���T�sn�?�{���y���|_߯�C����X4  H]��ت>���`���ѷ<7������� ��� �A8HU,U���X��@`�����3O��`�B`0(T�P� �_��C��/X�2���TJ���gI�"|��.$"^[���d����+ml�;9o��u
�َ����@ص��o����C���EF���ĞN`�9{�|bj����߯�rr�yn��ۥ�x|A��raMm]}C��'/[�D��:^�%Ҿ7o����'>L*>*��4� _�_��j.0
�j�q���s8�l�����fp����)-Cϔ�jm�ux٢��#��d�|�3ُ���/��`߸Ā.��<pfgW�$�b�����d�/��6�p�zt�T�l���L�;�Ȁ�f�L4�\�J��&��un�m{3ߣ-����I#��N	Z����aH�
�tӦ��U�f��W���f���fs���B�V�MTCJ���N��(&qxwk���B��څfT���\_�jP�D�ːt���J�����c\�1sm'�d�}W�H���~��K��6�=L���{KuѤs��ɡ��D�#XSr�$w���9��׎����i�_��8�$xU��G��݊�OOhw�����>�c���ܤ���C���b�{����	~��.-�g�s�EA�D�9�6����BO�f
7��#O�v}dNc�d���"-��wX�I�®�[F%�����ד�Ɛ�ձ�O�g1��.Sg��x�"VI��^!���Jnc�H���J+2�yY%lR�/�h�ht3$��Q<�����žGW��j��i�U]��ZJ�uO��-/�5�k�R�{c������{xL�lA{�8-��Mun)�rK���]� �߼1i��E�P�(g�� �5%��|�E�qLB|���&��d�Q$�ɐ���O>Wz���i��B�{t�������� �=�����{��v|/c�]��֦e����7Ӻ�p~��&\�WB��ڐZC\��q݂��e/�iF�r`ڦ�y8��o�U-7� �!�c���J��d:VB�|�UF�5��������L%���3���iiauwY	0�g6�p�����1�)A�*��X�Ƭ����<‰p��lz�`�q�a����:���K��j;(`L��8�M�U#���/-�'0?������0�b3����tS��a�EaS_f������/��2�1���I�3�w�7�C��b@E�6�P�è
o)��%�z#SdK̘�ވ��D��N��!�*�Ps������t������H��G$8Q	���gO.�oms�+=^F����"�ٲ��nP��;o�8?�C~m��."��>�f�2����2a� >��&�fkOl���V~�/���m�9����'��������=%kO���jY>Wo� ��+���̻W؃Ĩ�6G�����p���ϝ�K�Q�v�90�`��d�bW!b?��x�%�/3L�"RqM��z�7PK
     �Mh@�v�j�  �    test.stUT	 dqXO#�XOux �  �  Eval [
    PackageLoader fileInPackage: 'WebServer'
]



Namespace current: NetClients.WikiWorks [
    Smalltalk arguments do: [:each | FileStream fileIn: each]
]



Eval [
    ObjectMemory snapshot
]



Namespace current: NetClients.WikiWorks [
    WebServer publishMyFileSystem.
    "WebServer initializeWiki."
    "WebServer restartWikiNoImages."
    "WebServer restartWiki."

    Processor activeProcess suspend
]

PK
     �Mh@SYa�  �    WikiServer.stUT	 dqXO#�XOux �  �  "======================================================================
|
|   Wiki-style web server plug-in
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001 Travis Griggs and Ken Treis
| Written by Travis Griggs, Ken Treis and others.
| Port to GNU Smalltalk, enhancements and refactoring by Paolo Bonzini.
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



Object subclass: WikiPage [
    | author timestamp |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    WikiPage class >> newVersionOf: aWikiPage by: anAuthor [
	<category: 'instance creation'>
	^(self new)
	    previousVersion: aWikiPage;
	    author: anAuthor;
	    yourself
    ]

    WikiPage class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    allTitles [
	<category: 'accessing'>
	| oc |
	oc := OrderedCollection new.
	self allTitlesInto: oc.
	^oc
    ]

    allTitlesInto: aCollection [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    author [
	<category: 'accessing'>
	^author
    ]

    contents [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    references: aString [
	<category: 'accessing'>
	^(aString match: self contents) or: [aString match: self title]
    ]

    operationSynopsis [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    timestamp [
	<category: 'accessing'>
	^timestamp
    ]

    title [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    versionAt: aNumber [
	<category: 'accessing'>
	self versionsDo: [:each | each versionNumber = aNumber ifTrue: [^each]].
	^self subscriptBoundsError: aNumber
    ]

    versionNumber [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    versionsDo: aBlock [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    versionsReverseDo: aBlock [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    printOn: aStream [
	<category: 'displaying'>
	aStream
	    nextPut: $[;
	    nextPutAll: self title;
	    nextPut: $(;
	    print: self versionNumber;
	    nextPut: $);
	    nextPut: $];
	    nl;
	    nextPutAll: self contents;
	    nl.
	aStream
	    nextPut: ${;
	    nextPutAll: author;
	    space;
	    print: timestamp;
	    nextPut: $}
    ]

    changeTitle: aTitle by: anAuthor [
	<category: 'editing'>
	| newGuy |
	aTitle = self title ifTrue: [^self].
	newGuy := RenamedWikiPage newVersionOf: self by: anAuthor.
	newGuy title: aTitle.
	^newGuy
    ]

    newContents: aContents by: anAuthor [
	<category: 'editing'>
	| newGuy |
	aContents = self contents ifTrue: [^self].
	newGuy := EditedWikiPage newVersionOf: self by: anAuthor.
	newGuy contents: aContents.
	^newGuy
    ]

    author: anObject [
	<category: 'initialize'>
	author := anObject
    ]

    initialize [
	<category: 'initialize'>
	timestamp := DateTime now.
	author := ''
    ]

    saveToFile: aFileStream under: aWikiPM [
	<category: 'flat file'>
	aFileStream
	    nextPutAll: author;
	    nl.
	aFileStream
	    print: timestamp asSeconds;
	    nl.
	^self
    ]

    loadFromFile: rs under: aWikiPM [
	<category: 'flat file'>
	| timestamp author seconds |
	author := rs nextLine.
	seconds := rs nextLine asNumber.
	timestamp := (Date 
		    year: 1901
		    day: 1
		    hour: 0
		    minute: 0
		    second: 0) + (Duration seconds: seconds).
	self
	    author: author;
	    timestamp: timestamp
    ]

    timestamp: value [
	<category: 'flat file'>
	timestamp := value
    ]
]



WikiPage subclass: OriginalWikiPage [
    | title |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    allTitlesInto: aCollection [
	<category: 'accessing'>
	aCollection add: title
    ]

    contents [
	<category: 'accessing'>
	^'Describe ' , title , ' here...'
    ]

    operationSynopsis [
	<category: 'accessing'>
	^'Created'
    ]

    title [
	<category: 'accessing'>
	^title
    ]

    title: aString [
	<category: 'accessing'>
	title := aString
    ]

    versionNumber [
	<category: 'accessing'>
	^0
    ]

    versionsDo: aBlock [
	<category: 'accessing'>
	aBlock value: self
    ]

    versionsReverseDo: aBlock [
	<category: 'accessing'>
	aBlock value: self
    ]

    saveToFile: aFileStream under: aWikiPM [
	<category: 'flat file'>
	super saveToFile: aFileStream under: aWikiPM.
	aFileStream nextPutAll: title.
	^self
    ]

    loadFromFile: rs under: aWikiPM [
	<category: 'flat file'>
	super loadFromFile: rs under: aWikiPM.
	self title: rs upToEnd
    ]
]



WikiPage subclass: ChangedWikiPage [
    | previousVersion |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    allTitlesInto: aCollection [
	<category: 'accessing'>
	previousVersion allTitlesInto: aCollection
    ]

    contents [
	<category: 'accessing'>
	^previousVersion contents
    ]

    previousVersion [
	<category: 'accessing'>
	^previousVersion
    ]

    previousVersion: anObject [
	<category: 'accessing'>
	previousVersion := anObject
    ]

    title [
	<category: 'accessing'>
	^previousVersion title
    ]

    versionNumber [
	<category: 'accessing'>
	^previousVersion versionNumber + 1
    ]

    versionsDo: aBlock [
	<category: 'accessing'>
	aBlock value: self.
	previousVersion versionsDo: aBlock
    ]

    versionsReverseDo: aBlock [
	<category: 'accessing'>
	previousVersion versionsReverseDo: aBlock.
	aBlock value: self
    ]

    saveToFile: aFileStream under: aWikiPM [
	<category: 'flat file'>
	super saveToFile: aFileStream under: aWikiPM.
	aFileStream
	    print: (aWikiPM idForPage: self previousVersion);
	    nl.
	^self
    ]

    loadFromFile: rs under: aWikiPM [
	<category: 'flat file'>
	| id |
	super loadFromFile: rs under: aWikiPM.
	id := rs nextLine.
	self previousVersion: (aWikiPM loadPage: id)
    ]
]



ChangedWikiPage subclass: EditedWikiPage [
    | contents |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    contents [
	<category: 'accessing'>
	^contents
    ]

    contents: aString [
	"trim off trailing CRs"

	<category: 'accessing'>
	| index |
	index := aString size.
	[index > 1 and: [(aString at: index) = Character nl]] 
	    whileTrue: [index := index - 1].
	contents := aString copyFrom: 1 to: index
    ]

    operationSynopsis [
	<category: 'accessing'>
	^'Edited'
    ]

    saveToFile: aFileStream under: aWikiPM [
	<category: 'flat file'>
	super saveToFile: aFileStream under: aWikiPM.
	aFileStream nextPutAll: contents.
	^self
    ]

    loadFromFile: rs under: aWikiPM [
	<category: 'flat file'>
	super loadFromFile: rs under: aWikiPM.
	self contents: rs upToEnd
    ]
]



ChangedWikiPage subclass: RenamedWikiPage [
    | title |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    allTitlesInto: aCollection [
	<category: 'accessing'>
	aCollection add: title.
	^super allTitlesInto: aCollection
    ]

    operationSynopsis [
	<category: 'accessing'>
	^'Renamed'
    ]

    title [
	<category: 'accessing'>
	^title
    ]

    title: aString [
	<category: 'accessing'>
	title := aString
    ]

    saveToFile: aFileStream under: aWikiPM [
	<category: 'flat file'>
	super saveToFile: aFileStream under: aWikiPM.
	aFileStream nextPutAll: title.
	^self
    ]

    loadFromFile: rs under: aWikiPM [
	<category: 'flat file'>
	super loadFromFile: rs under: aWikiPM.
	self title: rs upToEnd
    ]
]



Object subclass: WikiSettings [
    | dictionary |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    WikiSettings class >> cookieString: aString [
	<category: 'instance creation'>
	^self new fromCookieString: aString
    ]

    WikiSettings class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    loadFromFile: aFileStream [
	<category: 'flat file'>
	| line |
	[(line := aFileStream nextLine) isEmpty] whileFalse: 
		[line := line substrings: $=.
		line size = 2 
		    ifTrue: [self at: (line at: 1) put: (line at: 2)]
		    ifFalse: [self at: (line at: 1) put: true]]
    ]

    saveToFile: ws [
	<category: 'flat file'>
	| line |
	self settingsDo: 
		[:key :value | 
		value == false 
		    ifFalse: 
			[line := key.
			value == true ifFalse: [line := line , '=' , 'value'].
			ws
			    nextPutAll: line;
			    nl]].
	ws nl
    ]

    initialize [
	<category: 'private'>
	dictionary := Dictionary new
    ]

    at: name put: value [
	<category: 'private'>
	^dictionary at: name put: value
    ]

    at: name default: default [
	<category: 'private'>
	^dictionary at: name ifAbsentPut: [default]
    ]

    backgroundColor [
	<category: 'settings'>
	^self at: 'bc' default: '#ffffff'
    ]

    backgroundColor: anObject [
	<category: 'settings'>
	self at: 'bc' put: anObject
    ]

    linkColor [
	<category: 'settings'>
	^self at: 'lc' default: '#0000ff'
    ]

    linkColor: anObject [
	<category: 'settings'>
	self at: 'lc' put: anObject
    ]

    tableBackgroundColor [
	<category: 'settings'>
	^self at: 'tbc' default: '#ffe0ff'
    ]

    tableBackgroundColor: anObject [
	<category: 'settings'>
	self at: 'tbc' put: anObject
    ]

    textColor [
	<category: 'settings'>
	^self at: 'tc' default: '#000000'
    ]

    textColor: anObject [
	<category: 'settings'>
	self at: 'tc' put: anObject
    ]

    visitedLinkColor [
	<category: 'settings'>
	^self at: 'vlc' default: '#551a8b'
    ]

    visitedLinkColor: anObject [
	<category: 'settings'>
	self at: 'vlc' put: anObject
    ]
]



Servlet subclass: Wiki [
    | settings pages rootPageTitle syntaxPageTitle fileServer persistanceManager |
    
    <comment: 'A Wiki is made up of four kinds of classes; Wiki, WikiPersistanceManager,
WikiPage, and WikiHTML.  A Wiki has a collection of WikiPages, which can be read or
edited over the web, and is able to select a WikiHTML to match the command to
be performed.  WikiHTML objects produce HTML for the page, which the WebServer
will send back to the web browser.  A WikiPersistanceManager knows how to save to
disk and then retrieve the pages that make up a Wiki; the reason why it is separated
from the Wiki class is that, this way, you can use any kind of persistance (binary,
flat file,...) with any kind of Wiki (password-protected, normal,
read-only,...).

There are many subclasses of WikiHTML, one for each way that a page can be
converted into HTML.  Each subclass represents a different command, such as editing,
changing the name of a page, or looking at old versions of a page.

There are also many subclasses of WikiPage.  Except for the original page, each
version points to the previous version of the page.  Since the original page is always
of the form "Describe XXX here", it is not very interesting.  Other versions of the page
can have a custom contents or can be renamed.'>
    <category: 'Web-Wiki'>

    Wiki class >> named: aString [
	<category: 'instance creation'>
	^self new name: aString
    ]

    Wiki class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	<category: 'initialize'>
	pages := Dictionary new.
	settings := WikiSettings new.
	self name: 'Wiki'.
	self rootPageTitle: 'Duh Tawp'.
	self syntaxPageTitle: 'Duh Rools'
    ]

    redirectToRootPage: aRequest [
	<category: 'interaction'>
	aRequest location addLast: self rootPageTitle , '.html'.
	"self sendPageFor: aRequest."
	^(ErrorResponse 
	    movedTemporarilyTo: self printString , '/' , aRequest location last) 
		respondTo: aRequest
    ]

    removeHTMLFrom: pageTitle [
	<category: 'interaction'>
	pageTitle size > 5 ifFalse: [^pageTitle].
	^(pageTitle copyFrom: pageTitle size - 4 to: pageTitle size = '.html') 
	    ifTrue: [pageTitle copyFrom: 1 to: pageTitle size - 5]
	    ifFalse: [pageTitle]
    ]

    sendPageFor: aRequest [
	<category: 'interaction'>
	| pageTitle |
	pageTitle := self removeHTMLFrom: aRequest location last.
	^(self hasPageTitled: pageTitle) 
	    ifTrue: [WikiPageHTML respondTo: aRequest in: self]
	    ifFalse: [WikiAbsentPageHTML respondTo: aRequest in: self]
    ]

    replyToGetRequest: aRequest [
	<category: 'interaction'>
	| rClass size |
	size := aRequest location size - self depth + 1.
	size < 2 
	    ifTrue: 
		[size = 0 ifTrue: [^self redirectToRootPage: aRequest].
		^(aRequest location last sameAs: 'RECENT CHANGES') 
		    ifTrue: [WikiChangesHTML respondTo: aRequest in: self]
		    ifFalse: [self sendPageFor: aRequest]].
	rClass := size = 2 
		    ifTrue: [self classForCommand: aRequest]
		    ifFalse: [WikiErrorHTML].
	^rClass respondTo: aRequest in: self
    ]

    classForCommand: aRequest [
	<category: 'interaction'>
	| cmd page |
	cmd := aRequest location at: self depth.
	page := aRequest location last.
	(cmd sameAs: 'CREATE') 
	    ifTrue: 
		[self createPageFor: aRequest.
		^WikiEditHTML].
	(self hasPageTitled: page) ifFalse: [^WikiAbsentPageHTML].
	(cmd sameAs: 'EDIT') ifTrue: [^WikiEditHTML].
	(cmd sameAs: 'HISTORY') ifTrue: [^WikiHistoryHTML].
	(cmd sameAs: 'RENAME') ifTrue: [^WikiRenameHTML].
	(cmd sameAs: 'REFS') ifTrue: [^WikiReferencesHTML].
	(cmd sameAs: 'VERSION') ifTrue: [^WikiVersionHTML].
	^WikiErrorHTML
    ]

    replyToPostEditRequest: aRequest [
	<category: 'interaction'>
	| newPage currentPage newContents |
	currentPage := self pageTitled: aRequest location last.
	newContents := aRequest postDataAt: #NEWCONTENTS.
	newPage := currentPage newContents: newContents by: aRequest originator.
	self addPage: newPage.
	self sendPageFor: aRequest
    ]

    replyToPostRenameRequest: aRequest [
	<category: 'interaction'>
	| currentPage newTitle newPage |
	currentPage := self pageTitled: aRequest location last.
	newTitle := aRequest postDataAt: #NEWTITLE.
	((self hasPageTitled: newTitle) 
	    and: [(self pageTitled: newTitle) ~= currentPage]) 
		ifTrue: [^WikiRenameConflictHTML respondTo: aRequest in: self].
	newPage := currentPage changeTitle: newTitle by: aRequest originator.
	self addPage: newPage.
	self sendPageFor: aRequest
    ]

    replyToPostRequest: aRequest [
	<category: 'interaction'>
	| cmd |
	cmd := aRequest postDataAt: #COMMAND.
	(cmd sameAs: 'EDIT') ifTrue: [^self replyToPostEditRequest: aRequest].
	(cmd sameAs: 'RENAME') ifTrue: [^self replyToPostRenameRequest: aRequest].
	(cmd sameAs: 'SEARCH') ifTrue: [^self replyToPostSearchRequest: aRequest].
	self replyToUnknownRequest: aRequest
    ]

    replyToPostSearchRequest: aRequest [
	<category: 'interaction'>
	^WikiReferencesHTML respondTo: aRequest in: self
    ]

    replyToUnknownRequest: aRequest [
	<category: 'interaction'>
	^WikiErrorHTML respondTo: aRequest in: self
    ]

    respondTo: aRequest [
	<category: 'interaction'>
	(aRequest action sameAs: 'HEAD') 
	    ifTrue: [^self replyToGetRequest: aRequest].
	(aRequest action sameAs: 'GET') 
	    ifTrue: [^self replyToGetRequest: aRequest].
	(aRequest action sameAs: 'POST') 
	    ifTrue: [^self replyToPostRequest: aRequest].
	^(ErrorResponse acceptableMethods: #('HEAD' 'GET' 'POST')) 
	    respondTo: aRequest
    ]

    syntaxPageTitle [
	<category: 'accessing'>
	^(self pageTitled: syntaxPageTitle) title
    ]

    syntaxPageTitle: aString [
	<category: 'accessing'>
	syntaxPageTitle notNil 
	    ifTrue: [pages removeKey: syntaxPageTitle asUppercase].
	syntaxPageTitle := aString.
	self addPage: self newSyntaxPage
    ]

    filesPath [
	<category: 'accessing'>
	^fileServer isNil ifTrue: [nil] ifFalse: [fileServer printString]
    ]

    filesPath: aString [
	<category: 'accessing'>
	| path |
	aString isNil ifTrue: [^self fileServer: nil].
	path := (aString at: 1) == $/ 
		    ifTrue: [WebServer current handler]
		    ifFalse: [self parent].
	(aString substrings: $/) 
	    do: [:each | each isEmpty ifFalse: [path := path componentNamed: each]].
	self fileServer: path
    ]

    fileServer [
	<category: 'accessing'>
	^fileServer
    ]

    fileServer: aString [
	<category: 'accessing'>
	fileServer := aString
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aString [
	<category: 'accessing'>
	name := aString
    ]

    persistanceManager: aWikiPersistanceManager [
	<category: 'accessing'>
	persistanceManager := aWikiPersistanceManager.
	aWikiPersistanceManager wiki: self
    ]

    rootPageTitle [
	<category: 'accessing'>
	^(self pageTitled: rootPageTitle) title
    ]

    rootPageTitle: aString [
	<category: 'accessing'>
	rootPageTitle notNil ifTrue: [pages removeKey: rootPageTitle asUppercase].
	rootPageTitle := aString.
	self addPage: (OriginalWikiPage new title: rootPageTitle)
    ]

    save [
	<category: 'accessing'>
	persistanceManager save
    ]

    settings [
	<category: 'accessing'>
	^settings
    ]

    startDate [
	<category: 'accessing'>
	^((self pageTitled: self rootPageTitle) versionAt: 0) timestamp
    ]

    loadFromFile: aFileStream [
	<category: 'flat file'>
	| path |
	settings loadFromFile: aFileStream.
	self name: aFileStream nextLine.
	self rootPageTitle: aFileStream nextLine.
	self syntaxPageTitle: aFileStream nextLine.
	path := aFileStream nextLine.
	path = '<none>' ifTrue: [path := nil].
	self filesPath: path.
	^self
    ]

    saveToFile: ws [
	<category: 'flat file'>
	settings saveToFile: ws.
	ws
	    nextPutAll: self name;
	    nl.
	ws
	    nextPutAll: self rootPageTitle;
	    nl.
	ws
	    nextPutAll: self syntaxPageTitle;
	    nl.
	self filesPath isNil 
	    ifTrue: 
		[ws
		    nextPutAll: '<none>';
		    nl]
	    ifFalse: 
		[ws
		    nextPutAll: self filesPath;
		    nl].
	^self
    ]

    addPage: aPage [
	<category: 'pages'>
	aPage allTitles do: [:each | pages at: each asUppercase put: aPage].
	persistanceManager isNil ifFalse: [persistanceManager addPage: aPage]
    ]

    currentPageTitleFor: aString [
	<category: 'pages'>
	^(aString sameAs: 'Changes') 
	    ifTrue: ['Recent Changes']
	    ifFalse: [(pages at: aString asUppercase) title]
    ]

    currentTitleOf: aString [
	<category: 'pages'>
	^(aString sameAs: 'RECENT CHANGES') 
	    ifTrue: [aString]
	    ifFalse: [(self pageTitled: aString) title]
    ]

    syntaxPage [
	<category: 'pages'>
	^self pageTitled: syntaxPageTitle
    ]

    hasPageTitled: aString [
	<category: 'pages'>
	^(pages includesKey: aString asUppercase) 
	    or: [aString sameAs: 'RECENT CHANGES']
    ]

    allPagesDo: aBlock [
	<category: 'pages'>
	pages do: aBlock
    ]

    pagesDo: aBlock [
	"when enumerating the pages dictionary, we want to filter to only those entries whose titles are current, this avoids double enumerating a page that might have two or more titles in it's history"

	<category: 'pages'>
	pages 
	    keysAndValuesDo: [:title :page | (page title sameAs: title) ifTrue: [aBlock value: page]]
    ]

    pageTitled: aString [
	<category: 'pages'>
	^pages at: aString asUppercase
    ]

    createPageFor: aRequest [
	<category: 'private'>
	(self hasPageTitled: aRequest location last) 
	    ifFalse: 
		[self addPage: ((OriginalWikiPage new)
			    author: aRequest originator;
			    title: aRequest location last;
			    yourself)]
    ]

    newSyntaxPage [
	<category: 'private'>
	^(OriginalWikiPage new title: syntaxPageTitle) 
	    newContents: self newSyntaxPageContents
	    by: ''
    ]

    newSyntaxPageContents [
	<category: 'private'>
	^'The Wiki''s a place where anybody can edit anything. To do so just follow the <I>Edit this page</I> link at the top or bottom of a page. The formatting rules are pretty simple:
. Links are created by placing square brackets around the link name (e.g. [[aPageName]). If you need to create a [[ character, use two of them (e.g. "[[[["). You don''t need to double up the ] character unless you actually want to use it as part of the link name.
. If you want to create a link to an "outside" source, just include the full internet protocol name (e.g. [[http://www.somesite.com] or [[mailto:someone@somewhere.com] or [[ftp://somesite.ftp]).
. If you want a link (either internal or outside) by another name, then place both the desired name and the actual link target as a pair separated by > character (e.g. [[The Top > Home Page] or [[me > mailto:myname@myplace.com]).
. Carriage returns create a new paragraph
. Use any HTML you want. The Wiki formatting rules will not be applied between a PRE tag.
. To create a horizontal line, start a line with ''----''.
. To create a bullet list item, start a line with a . character.
. To create a numbered list item, start a line with a # character.
. To create a heading, start a line with a * character.  More consecutive asterisks yield lower level headings.
. To create a table, start the line with two | (vertical bar) characters. For each cell in the row, separate again by two | characters. Successive lines that start with the two | characters are made into the same table.
. To publish your edits, press the save button. If you don''t want to publish, just press your browser''s Back button.
'
    ]
]



Wiki subclass: ProtectedWiki [
    | authorizer |
    
    <comment: nil>
    <category: 'Web-Wiki'>

    replyToRequest: aRequest [
	<category: 'authentication'>
	self authorizer 
	    authorize: aRequest
	    in: self
	    ifAuthorized: [super replyToRequest: aRequest]
    ]
]



ProtectedWiki subclass: ReadOnlyWiki [
    
    <comment: nil>
    <category: 'Web-Wiki'>

    replyToPostEditRequest: aRequest [
	<category: 'authentication'>
	self authorizer 
	    authorize: aRequest
	    in: self
	    ifAuthorized: [super replyToPostEditRequest: aRequest]
    ]

    replyToPostRenameRequest: aRequest [
	<category: 'authentication'>
	self authorizer 
	    authorize: aRequest
	    in: self
	    ifAuthorized: [super replyToPostRenameRequest: aRequest]
    ]
]



ProtectedWiki subclass: PasswordWiki [
    
    <comment: nil>
    <category: 'Web-Wiki'>

    authorizer [
	<category: 'authentication'>
	^authorizer
    ]

    authorizer: aWebAuthorizer [
	<category: 'authentication'>
	authorizer := aWebAuthorizer.
	self fileServer isNil 
	    ifFalse: [self fileServer uploadAuthorizer: aWebAuthorizer]
    ]

    loginID: aLoginID password: aPassword [
	<category: 'authentication'>
	self authorizer: (WebAuthorizer loginID: aLoginID password: aPassword)
    ]

    loadFromFile: aFileStream [
	<category: 'flat file'>
	super loadFromFile: aFileStream.
	self authorizer: (WebAuthorizer fromString: aFileStream nextLine).
	^self
    ]

    saveToFile: ws [
	<category: 'flat file'>
	super saveToFile: ws.
	ws
	    nextPutAll: self authorizer authorizer;
	    nl.
	^self
    ]
]



WebResponse subclass: WikiHTML [
    | wiki page |
    
    <comment: 'WikiHTML is an object that can convert a WikiPage to HTML.  There are
different subclasses of WikiHTML for the various ways a page can be rendered,
such as when it is edited or renamed.

All subclasses must implement sendBody.'>
    <category: 'Web-WikiRendering'>

    WikiHTML class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    WikiHTML class >> respondTo: aRequest in: aWiki [
	<category: 'instance creation'>
	^(self new)
	    wiki: aWiki;
	    respondTo: aRequest
    ]

    initialize [
	<category: 'initialize'>
	
    ]

    browserTitle [
	<category: 'accessing'>
	^self wikiName , ': ' , self pageTitle
    ]

    encodedPageTitle [
	<category: 'accessing'>
	^(URL encode: self page title) , '.html'
    ]

    settings [
	<category: 'accessing'>
	^wiki settings
    ]

    page [
	<category: 'accessing'>
	page isNil ifTrue: [page := wiki pageTitled: request location last].
	^page
    ]

    pageTitle [
	<category: 'accessing'>
	^self page title
    ]

    emitIcon: imageBlock linkTo: nameBlock titled: titleBlock [
	<category: 'accessing'>
	self wiki filesPath isNil 
	    ifFalse: 
		[^self
		    image: imageBlock
			linkTo: nameBlock
			titled: titleBlock;
		    nl].
	self td: [self linkTo: nameBlock titled: titleBlock]
    ]

    emitCommonIcons [
	<category: 'accessing'>
	self
	    emitIcon: [self << self wiki filesPath << '/help.jpg']
		linkTo: 
		    [self
			<< self wiki;
			<< $/;
			nextPutUrl: self wiki syntaxPageTitle]
		titled: [self << self wiki syntaxPageTitle];
	    emitIcon: [self << self wiki filesPath << '/recent.jpg']
		linkTo: [self << self wiki << '/RECENT+CHANGES']
		titled: [self << 'Recent changes'];
	    emitIcon: [self << self wiki filesPath << '/top.jpg']
		linkTo: [self << self wiki << $/]
		titled: [self << 'Back to Top']
    ]

    sendBody [
	"subclasses will usually want to do more here"

	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self emitFinish
    ]

    emitFinish [
	<category: 'accessing'>
	self
	    nl;
	    << '</FONT>';
	    nl;
	    << '</BODY></HTML>'
    ]

    emitSearch: aString [
	<category: 'accessing'>
	self horizontalLine.
	(self << '<FORM ACTION="' << wiki name)
	    << '" METHOD=POST>';
	    nl.
	self
	    << '<INPUT TYPE="HIDDEN" NAME="COMMAND" VALUE="SEARCH">';
	    nl.
	(self << '<INPUT TYPE= "TEXT" NAME="SEARCHPATTERN" VALUE="' << aString)
	    << '" SIZE=40>';
	    nl.
	self wiki filesPath isNil 
	    ifFalse: 
		[self << '<INPUT TYPE="image" ALIGN="absmiddle" BORDER="0" SRC="' 
		    << self wiki filesPath << '/find.jpg" ALT=']
	    ifTrue: [self << '<INPUT TYPE="submit" VALUE='].
	self
	    << '"Find..."></FORM>';
	    nl
    ]

    emitStart [
	<category: 'accessing'>
	(self << '<HTML><HEAD><TITLE>' << self browserTitle 
	    << '</TITLE></HEAD><BODY bgcolor=' << self settings backgroundColor 
	    << ' link=' << self settings linkColor 
	    << ' vlink=' << self settings visitedLinkColor)
	    << $>;
	    nl.
	(self << '<FONT color=' << self settings textColor)
	    << $>;
	    nl
    ]

    emitIcons [
	<category: 'accessing'>
	self
	    emitIconsStart;
	    emitCommonIcons;
	    emitIconsEnd
    ]

    emitIconsEnd [
	<category: 'accessing'>
	self wiki filesPath isNil 
	    ifFalse: 
		[self
		    << '<BR>';
		    nl]
	    ifTrue: 
		[self
		    nl;
		    << '</TR>';
		    nl;
		    << '</TABLE>';
		    nl]
    ]

    emitIconsStart [
	<category: 'accessing'>
	self wiki filesPath isNil 
	    ifFalse: 
		[^self image: [self << self wiki filesPath << '/head.jpg']
		    titled: [self << self wiki]].
	self << '<TABLE width=100% bgcolor=' << self settings tableBackgroundColor.
	self
	    << '><TR>';
	    nl
    ]

    emitUrlForCommand: commandName [
	<category: 'accessing'>
	self << self wiki << $/ << commandName << $/ << self encodedPageTitle
    ]

    emitUrlOfPage [
	<category: 'accessing'>
	self << self wiki << $/ << self encodedPageTitle
    ]

    linkToPage: aPage [
	<category: 'accessing'>
	self linkTo: 
		[self
		    << self wiki;
		    << $/;
		    nextPutUrl: aPage title]
	    titled: [self << aPage title]
    ]

    wiki [
	<category: 'accessing'>
	^wiki
    ]

    wiki: anObject [
	<category: 'accessing'>
	wiki := anObject
    ]

    wikiName [
	<category: 'accessing'>
	^wiki name
    ]
]



WikiHTML subclass: WikiPageHTML [
    | contentStream currentChar lastChar inBullets inNumbers heading inTable |
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    ParseTable := nil.

    WikiPageHTML class >> initialize [
	<category: 'initialize'>
	ParseTable := Array new: 256.
	ParseTable at: 1 + Character cr asciiValue put: #processCr.
	ParseTable at: 1 + Character nl asciiValue put: #processNl.
	ParseTable at: 1 + $[ asciiValue put: #processLeftBracket.
	ParseTable at: 1 + $. asciiValue put: #processDot.
	ParseTable at: 1 + $# asciiValue put: #processPound.
	ParseTable at: 1 + $- asciiValue put: #processDash.
	ParseTable at: 1 + $* asciiValue put: #processStar.
	ParseTable at: 1 + $| asciiValue put: #processPipe.
	ParseTable at: 1 + $< asciiValue put: #processLeftAngle
    ]

    isExternalAddress: linkAddress [
	"Faster than #match:"

	<category: 'private-HTML'>
	^#('http:' 'https:' 'mailto:' 'file:' 'ftp:' 'news:' 'gopher:' 'telnet:') 
	    anySatisfy: 
		[:each | 
		each size < linkAddress size and: 
			[(1 to: each size) 
			    allSatisfy: [:index | (each at: index) == (linkAddress at: index)]]]
    ]

    isImage: linkAddress [
	"Faster than #match:"

	<category: 'private-HTML'>
	^#('.gif' '.jpeg' '.jpg' '.jpe') anySatisfy: 
		[:each | 
		each size < linkAddress size and: 
			[(1 to: each size) allSatisfy: 
				[:index | 
				(each at: index) == (linkAddress at: linkAddress size - each size + index)]]]
    ]

    linkAddressIn: aString [
	<category: 'private-HTML'>
	| rs |
	rs := aString readStream.
	rs skipTo: $>.
	^(rs atEnd ifTrue: [aString] ifFalse: [rs upToEnd]) trimSeparators
    ]

    linkNameIn: aString [
	<category: 'private-HTML'>
	| rs |
	rs := aString readStream.
	^(rs upTo: $>) trimSeparators
    ]

    addCurrentChar [
	<category: 'parsing'>
	self responseStream nextPut: currentChar
    ]

    atLineStart [
	<category: 'parsing'>
	^lastChar == Character nl or: [lastChar == nil]
    ]

    closeBulletItem [
	<category: 'parsing'>
	self
	    << '</LI>';
	    nl.
	contentStream peek == $. 
	    ifFalse: 
		[inBullets := false.
		self
		    << '</UL>';
		    nl]
    ]

    closeHeading [
	<category: 'parsing'>
	(self << '</H' << heading)
	    << '>';
	    nl.
	heading := nil
    ]

    closeNumberItem [
	<category: 'parsing'>
	self
	    << '</LI>';
	    nl.
	contentStream peek == $# 
	    ifFalse: 
		[inNumbers := false.
		self
		    << '</OL>';
		    nl]
    ]

    closeTableRow [
	<category: 'parsing'>
	| pos |
	self
	    << '</TD></TR>';
	    nl.
	pos := contentStream position.
	(contentStream peekFor: $|) 
	    ifTrue: 
		[(contentStream peekFor: $|) 
		    ifTrue: 
			[inTable := false.
			self
			    << '</TABLE>';
			    nl]].
	contentStream position: pos
    ]

    processNextChar [
	<category: 'parsing'>
	| selector |
	lastChar := currentChar.
	currentChar := contentStream next.
	selector := ParseTable at: currentChar value + 1.
	^selector isNil 
	    ifTrue: [self addCurrentChar]
	    ifFalse: [self perform: selector]
    ]

    processDot [
	<category: 'parsing'>
	self atLineStart ifFalse: [^self addCurrentChar].
	inBullets 
	    ifFalse: 
		[self
		    << '<UL>';
		    nl.
		inBullets := true].
	self << ' <LI>'
    ]

    processStar [
	<category: 'parsing'>
	self atLineStart ifFalse: [^self addCurrentChar].
	heading := 2.
	[contentStream peekFor: $*] whileTrue: [heading := heading + 1].
	self << '<H' << heading << '>'
    ]

    processCr [
	<category: 'parsing'>
	contentStream peekFor: Character nl.
	currentChar := Character nl.
	self processNl
    ]

    processNl [
	<category: 'parsing'>
	inBullets ifTrue: [^self closeBulletItem].
	inNumbers ifTrue: [^self closeNumberItem].
	inTable ifTrue: [^self closeTableRow].
	heading isNil ifFalse: [^self closeHeading].
	self lineBreak
    ]

    processDash [
	<category: 'parsing'>
	self atLineStart ifFalse: [^self addCurrentChar].
	contentStream skipTo: Character nl.
	self horizontalLine.
	lastChar := Character nl
    ]

    processLeftAngle [
	<category: 'parsing'>
	| s |
	s := String new writeStream.
	self addCurrentChar.
	
	[currentChar := contentStream next.
	currentChar == $> or: [currentChar == $ ]] 
		whileFalse: [s nextPut: currentChar].
	self << (s := s contents) << currentChar.
	(s sameAs: 'PRE') ifFalse: [^self].
	
	[contentStream atEnd ifTrue: [^self].
	self << (contentStream upTo: $<) << $<.
	self << (s := contentStream upTo: $>) << $>.
	s sameAs: '/PRE'] 
		whileFalse
    ]

    processLeftBracket [
	<category: 'parsing'>
	| linkAddress linkName link |
	(contentStream peekFor: $[) ifTrue: [^self addCurrentChar].
	link := contentStream upTo: $].
	[contentStream peekFor: $]] 
	    whileTrue: [link := link , ']' , (contentStream upTo: $])].
	linkName := self linkNameIn: link.
	linkAddress := self linkAddressIn: link.
	(self isExternalAddress: linkAddress) 
	    ifTrue: 
		["external outside link"

		^self << '<A HREF="' << linkAddress << '">' << linkName << '</A>'].
	linkAddress = linkName 
	    ifTrue: [self emitLink: linkName]
	    ifFalse: [self emitLink: linkName to: linkAddress]
    ]

    processPipe [
	<category: 'parsing'>
	(contentStream peekFor: $|) 
	    ifTrue: 
		[self atLineStart 
		    ifTrue: 
			[inTable 
			    ifFalse: 
				[self
				    << '<TABLE BORDER=2 CELLPADDING=4 CELLSPACING=0 >';
				    nl.
				inTable := true].
			self << '<TR><TD>']
		    ifFalse: [self << '</TD><TD>']]
	    ifFalse: [self addCurrentChar]
    ]

    processPound [
	<category: 'parsing'>
	self atLineStart ifFalse: [^self addCurrentChar].
	inNumbers 
	    ifFalse: 
		[self
		    << '<OL>';
		    nl.
		inNumbers := true].
	self << ' <LI>'
    ]

    emitLink: linkAddress [
	<category: 'parsing'>
	| currentTitle |
	(self isImage: linkAddress) 
	    ifTrue: 
		["graphic image link"

		(self isExternalAddress: linkAddress) 
		    ifTrue: [^self << '<img src="' << linkAddress << '">']
		    ifFalse: 
			[^self << '<img src="' << '/' << self wiki filesPath << '/' << linkAddress 
			    << '">']].
	(wiki hasPageTitled: linkAddress) 
	    ifTrue: 
		["simple one piece existing link"

		currentTitle := self wiki currentTitleOf: linkAddress.
		self linkTo: 
			[self
			    << self wiki;
			    << $/;
			    nextPutUrl: currentTitle]
		    titled: [self << currentTitle]]
	    ifFalse: 
		["simple one piece non existant link"

		self << '<U>' << linkAddress << '</U>'.
		self linkTo: 
			[self
			    << self wiki;
			    << '/CREATE/';
			    nextPutUrl: linkAddress]
		    titled: [self << $?]]
    ]

    emitLink: linkName to: linkAddress [
	<category: 'parsing'>
	| currentTitle |
	(wiki hasPageTitled: linkAddress) 
	    ifTrue: 
		["two piece existing link"

		currentTitle := self wiki currentTitleOf: linkAddress.
		self linkTo: 
			[self
			    << self wiki;
			    << $/;
			    nextPutUrl: currentTitle]
		    titled: [self << linkName]]
	    ifFalse: 
		["two piece non existant link"

		self << '<U>' << linkName << '</U>'.
		self linkTo: 
			[self
			    << self wiki;
			    << '/CREATE/';
			    nextPutUrl: linkAddress]
		    titled: [self << $?]]
    ]

    sendBody [
	<category: 'HTML'>
	self emitStart.
	self emitIcons.
	self emitTitle.
	self emitContents.
	self emitSearch: ''.
	self emitFinish
    ]

    emitCommand: commandName text: textString [
	<category: 'HTML'>
	^self 
	    emitIcon: 
		[self << self wiki filesPath << $/ << commandName asLowercase << '.jpg']
	    linkTo: [self emitUrlForCommand: commandName]
	    titled: [self << textString]
    ]

    emitIcons [
	<category: 'HTML'>
	self emitIconsStart.
	self emitCommonIcons.
	self emitCommand: 'EDIT' text: 'Edit this page'.
	self emitCommand: 'RENAME' text: 'Rename this page'.
	self emitCommand: 'HISTORY' text: 'History of this page'.
	self emitIconsEnd
    ]

    emitContents [
	<category: 'HTML'>
	contentStream := self page contents readStream.
	[contentStream atEnd] whileFalse: [self processNextChar].
	lastChar == Character nl ifFalse: [self processNl].
	contentStream := nil
    ]

    emitTitle [
	<category: 'HTML'>
	self heading: 
		[self linkTo: [self emitUrlForCommand: 'REFS']
		    titled: [self << self page title]]
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	heading := nil.
	inBullets := inNumbers := inTable := false
    ]
]



WikiHTML subclass: WikiAbsentPageHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    browserTitle [
	<category: 'accessing'>
	^self wikiName , ': `' , self pageTitle , ''' not found'
    ]

    pageTitle [
	<category: 'accessing'>
	^request location last
    ]

    sendResponseType [
	<category: 'accessing'>
	self
	    << 'HTTP/1.1 404 Not Found';
	    nl
    ]

    sendBody [
	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self heading: 
		[self << self wikiName << ' contains no page titled: "' 
		    << request location last]
	    level: 2.
	self emitSearch: request location last.
	self emitFinish
    ]
]



WikiHTML subclass: WikiReferencesHTML [
    | referringPages |
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    actualSearchString [
	<category: 'private'>
	^self searchString isEmpty 
	    ifTrue: [self searchString]
	    ifFalse: ['*' , self searchString , '*']
    ]

    findMatches [
	<category: 'private'>
	| match |
	referringPages := SortedCollection sortBlock: [:a :b | a title < b title].
	match := self actualSearchString.
	Processor activeProcess lowerPriority.
	wiki 
	    pagesDo: [:each | (each references: match) ifTrue: [referringPages add: each]].
	Processor activeProcess raisePriority
    ]

    browserTitle [
	<category: 'accessing'>
	| ws |
	ws := String new writeStream.
	ws
	    nextPutAll: 'SEARCH ';
	    nextPutAll: self wikiName;
	    nextPutAll: ':"';
	    nextPutAll: self searchString;
	    nextPut: $".
	^ws contents
    ]

    sendBody [
	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self emitMatchList.
	self emitSearch: self searchString.
	self emitFinish
    ]

    emitMatchList [
	<category: 'accessing'>
	self findMatches.
	referringPages isEmpty ifTrue: [^self emitNoMatches].
	self heading: 
		[self 
		    << ('There %<is|are>2 %1 reference%<|s>2 to the phrase:' % 
				{referringPages size.
				referringPages size = 1})].
	self
	    << '<I>  ...';
	    << self searchString;
	    << '...</I>';
	    lineBreak.
	self
	    << '<UL>';
	    nl.
	referringPages do: [:each | self listItem: [self linkToPage: each]].
	self
	    << '</UL>';
	    nl
    ]

    emitNoMatches [
	<category: 'accessing'>
	self
	    << '<H1>No references to the phrase</H1>';
	    nl.
	self
	    << '<I>    ...';
	    << self searchString;
	    << '...</I>';
	    lineBreak
    ]

    searchString [
	<category: 'accessing'>
	^request postDataAt: #SEARCHPATTERN ifAbsent: [request location last]
    ]
]



WikiPageHTML subclass: WikiVersionHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    page [
	<category: 'accessing'>
	^super page versionAt: self versionNumber
    ]

    emitIcons [
	<category: 'accessing'>
	self emitIconsStart.
	self emitCommonIcons.
	self emitCommand: 'HISTORY' text: 'History of this page'.
	self emitPreviousVersion.
	self emitNextVersion.
	self emitIconsEnd
    ]

    emitNextVersion [
	<category: 'accessing'>
	self versionNumber < (wiki pageTitled: self page title) versionNumber 
	    ifFalse: [^self].
	self 
	    emitIcon: [self << self wiki filesPath << '/next.jpg']
	    linkTo: [self emitUrlForVersionNumber: self versionNumber + 1]
	    titled: [self << 'Previous']
    ]

    emitPreviousVersion [
	<category: 'accessing'>
	self versionNumber <= 0 ifTrue: [^self].
	self 
	    emitIcon: [self << self wiki filesPath << '/prev.jpg']
	    linkTo: [self emitUrlForVersionNumber: self versionNumber - 1]
	    titled: [self << 'Previous']
    ]

    emitTitle [
	<category: 'accessing'>
	self heading: 
		[self linkTo: [self emitUrlForCommand: 'REFS']
		    titled: [self << self page title].
		self << ' (Version ' << self versionNumber << ')']
    ]

    versionNumber [
	<category: 'accessing'>
	^((request postDataAt: #n) asNumber max: 0) min: super page versionNumber
    ]

    emitUrlForVersionNumber: aNumber [
	<category: 'html'>
	self << self wiki << '/VERSION/' << self encodedPageTitle << '?n=' 
	    << aNumber
    ]
]



WikiHTML subclass: WikiChangesHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    numberOfChanges [
	<category: 'accessing'>
	^20
    ]

    numberOfDays [
	<category: 'accessing'>
	^7
    ]

    pageTitle [
	<category: 'accessing'>
	^'Recent Changes'
    ]

    sendBody [
	<category: 'accessing'>
	| day genesis minDate changesShown |
	self emitStart.
	self emitIcons.
	self emitChanges.
	self emitSearch: ''.
	self emitFinish
    ]

    emitChangedPage: aPage [
	<category: 'accessing'>
	self listItem: 
		[self
		    linkToPage: aPage;
		    space.
		self << aPage timestamp asTime << ' (' << aPage author << ')']
    ]

    emitChanges [
	<category: 'accessing'>
	| day genesis minDate changesShown |
	self heading: [self << 'Recent Changes'].
	genesis := wiki startDate printNl.
	day := Date today.
	minDate := (day subtractDays: self numberOfDays) printNl.
	changesShown := 0.
	
	[day < genesis ifTrue: [^self].
	day >= minDate or: [changesShown < self numberOfChanges]] 
		whileTrue: 
		    [changesShown := changesShown + (self emitChangesFor: day).
		    day := day subtractDays: 1]
    ]

    emitChangesFor: aDate [
	<category: 'accessing'>
	| sc |
	sc := SortedCollection new 
		    sortBlock: [:a :b | a timestamp > b timestamp] wiki
		    pagesDo: [:each | each timestamp asDate = aDate ifTrue: [sc add: each]].
	sc isEmpty 
	    ifFalse: 
		[self heading: 
			[(self responseStream)
			    nextPutAll: aDate monthName;
			    space;
			    print: aDate day;
			    space;
			    print: aDate year]
		    level: 3.
		self
		    << '<UL>';
		    nl.
		sc do: [:each | self emitChangedPage: each].
		self
		    << '</UL>';
		    nl].
	^sc size
    ]
]



WikiHTML subclass: WikiErrorHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    browserTitle [
	<category: 'accessing'>
	^self pageTitle
    ]

    emitDescription [
	<category: 'accessing'>
	self
	    << 'The ';
	    << self wiki;
	    << ' wiki is not able to process this request. '.
	self 
	    << 'This can be due to a malformed URL, or (less likely) to an internal server error'.
	self
	    lineBreak;
	    lineBreak.
	self
	    << 'originator: ';
	    << request originator displayString;
	    lineBreak.
	self
	    << 'action: ';
	    << request action displayString;
	    lineBreak.
	self << 'location: '.
	request location do: [:each | self << $/ << each].
	self lineBreak.
	request enumeratePostData: 
		[:key :val | 
		self
		    lineBreak;
		    << key;
		    << ' = ';
		    nl;
		    << val;
		    nl].
	self
	    lineBreak;
	    horizontalLine;
	    italic: [self << WebServer version]
    ]

    pageTitle [
	<category: 'accessing'>
	^'Bad request'
    ]

    sendBody [
	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self emitDescription.
	self emitFinish
    ]
]



WikiHTML subclass: WikiRenameConflictHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    newTitle [
	<category: 'accessing'>
	^request postDataAt: #NEWTITLE
    ]

    emitDescription [
	<category: 'accessing'>
	self heading: 
		[self << 'This name ('.
		self linkTo: [self << self wiki << $/ << self newTitle]
		    titled: [self << self newTitle].
		self << ') is in use already. Sorry, cannot complete this rename.']
	    level: 2
    ]

    sendBody [
	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self emitDescription.
	self emitSearch: self newTitle.
	self emitFinish
    ]
]



WikiHTML subclass: WikiCommandHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    browserTitle [
	<category: 'accessing'>
	^super browserTitle , self titleSuffix
    ]

    titleSuffix [
	<category: 'accessing'>
	^self subclassResponsibility
    ]
]



WikiCommandHTML subclass: WikiEditHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    titleSuffix [
	<category: 'accessing'>
	^' (edit)'
    ]

    emitForm [
	<category: 'HTML'>
	self heading: 
		[self << 'Edit '.
		self linkTo: [self emitUrlForCommand: 'REFS']
		    titled: [self << self pageTitle]].
	self
	    << 'Don''t know how to edit a page? Visit ';
	    linkToPage: wiki syntaxPage;
	    << '.';
	    nl.
	self
	    << '<FORM ACTION="';
	    emitUrlOfPage;
	    << '" METHOD=POST>';
	    nl.
	self
	    << '<INPUT TYPE="HIDDEN" NAME="COMMAND" VALUE="EDIT">';
	    nl.
	self
	    << '<TEXTAREA NAME="NEWCONTENTS"  WRAP=VIRTUAL COLS=80 ROWS=20>';
	    nl.
	self
	    << self page contents;
	    nl.
	self
	    << '</TEXTAREA>';
	    lineBreak.
	self
	    << '<INPUT TYPE="submit" VALUE="Save">';
	    nl.
	self
	    << '</FORM>';
	    nl
    ]

    sendBody [
	<category: 'HTML'>
	self emitStart.
	self emitIcons.
	self emitForm.
	self emitFinish
    ]
]



WikiCommandHTML subclass: WikiHistoryHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    sendBody [
	<category: 'HTML'>
	self emitStart.
	self emitIcons.
	self emitTitle.
	self emitTable.
	self emitSearch: ''.
	self emitFinish
    ]

    emitTitle [
	<category: 'HTML'>
	self heading: 
		[self << 'History of '.
		self linkTo: [self emitUrlForCommand: 'REFS']
		    titled: [self << self page title]]
    ]

    emitTable [
	<category: 'HTML'>
	self
	    << '<TABLE WIDTH="95%" BORDER="1">';
	    nl.
	self
	    << '<TR>';
	    nl.
	self
	    td: [self << '<B>Version</B>'];
	    td: [self << '<B>Operation</B>'];
	    td: [self << '<B>Author</B>'];
	    td: [self << '<B>Creation Time</B>'].
	self
	    << '</TR>';
	    nl.
	self page versionsDo: [:each | self emitPageVersion: each].
	self
	    << '</TABLE>';
	    nl
    ]

    emitPageVersion: each [
	<category: 'HTML'>
	self
	    << '<TR>';
	    nl.
	self td: 
		[self linkTo: 
			[self
			    << self wiki;
			    << '/VERSION/';
			    nextPutUrl: each title;
			    << '?n=';
			    << each versionNumber]
		    titled: [self << each versionNumber]].
	self td: [self << each operationSynopsis].
	self td: [self << each author].
	self td: [self sendTimestamp: each timestamp].
	self
	    << '</TR>';
	    nl
    ]

    titleSuffix [
	<category: 'accessing'>
	^' (history)'
    ]
]



WikiCommandHTML subclass: WikiRenameHTML [
    
    <comment: nil>
    <category: 'Web-WikiRendering'>

    titleSuffix [
	<category: 'accessing'>
	^' (rename)'
    ]

    emitForm [
	<category: 'accessing'>
	self heading: 
		[self << 'Rename'.
		self linkTo: [self emitUrlForCommand: 'REFS']
		    titled: [self << self pageTitle]].
	self
	    << '<FORM ACTION="';
	    emitUrlOfPage;
	    << '" METHOD=POST>';
	    nl.
	self
	    << '<INPUT TYPE="HIDDEN" NAME="COMMAND" VALUE="RENAME">';
	    nl.
	self
	    << '<INPUT TYPE= "TEXT" NAME="NEWTITLE" SIZE=80 VALUE="';
	    << self pageTitle;
	    << '">';
	    lineBreak.
	self
	    << '<INPUT TYPE="submit" VALUE="Save">';
	    nl.
	self
	    << '</FORM>';
	    nl
    ]

    sendBody [
	<category: 'accessing'>
	self emitStart.
	self emitIcons.
	self emitForm.
	self emitFinish
    ]
]



Object subclass: WikiPersistanceManager [
    | wiki |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    wiki [
	<category: 'accessing'>
	^wiki
    ]

    wiki: aWiki [
	<category: 'accessing'>
	wiki := aWiki.
	self reset
    ]

    allPagesDo: aBlock [
	<category: 'accessing'>
	wiki allPagesDo: aBlock
    ]

    addPage: aPage [
	<category: 'persistance'>
	
    ]

    load [
	<category: 'persistance'>
	self subclassResponsibility
    ]

    save [
	<category: 'persistance'>
	self subclassResponsibility
    ]
]



WikiPersistanceManager subclass: FlatFileWiki [
    | directory fileCounter idMap |
    
    <category: 'Web-Wiki'>
    <comment: nil>

    FlatFileWiki class >> directory: aDirectory [
	<category: 'instance creation'>
	^self new directory: aDirectory
    ]

    reset [
	<category: 'initialize'>
	directory exists ifFalse: [Directory create: directory name].
	idMap := IdentityDictionary new.
	fileCounter := -1
    ]

    idForPage: aPage [
	<category: 'private-persistance'>
	^idMap at: aPage ifAbsentPut: [self savePage: aPage]
    ]

    indexIn: aFilename [
	<category: 'private-persistance'>
	| tail |
	tail := aFilename stripPath.
	^(tail copyFrom: 1 to: tail size - 4) asNumber
    ]

    nextFileCounter [
	<category: 'private-persistance'>
	^fileCounter := fileCounter + 1
    ]

    loadPage: id [
	<category: 'private-persistance'>
	^self loadPageInFile: (directory at: id , '.pag')
    ]

    loadPageInFile: aFilename [
	<category: 'private-persistance'>
	| index rs page |
	index := self indexIn: aFilename.
	^idMap at: index
	    ifAbsentPut: 
		[| type |
		Transcript show: '.'.
		rs := aFilename readStream.
		type := rs nextLine asSymbol.
		
		[page := (Smalltalk at: type) new.
		page loadFromFile: rs under: self] 
			ensure: [rs close].
		page]
    ]

    loadPages [
	<category: 'private-persistance'>
	| latestVersions pageMap |
	idMap := pageMap := IdentityDictionary new.
	directory filesMatching: '*.pag' do: [:fn | self loadPageInFile: fn].
	idMap := IdentityDictionary new.
	pageMap keysAndValuesDo: [:i :page | idMap at: page put: i].
	latestVersions := pageMap asSet.
	pageMap do: 
		[:page | 
		"Remove all versions older than `each' from latest"

		page 
		    versionsDo: [:each | each == page ifFalse: [latestVersions remove: each ifAbsent: []]]].
	latestVersions do: [:page | self wiki addPage: page]
    ]

    load [
	<category: 'private-persistance'>
	| rs fn |
	self reset.
	(fn := directory at: 'wiki.conf') exists 
	    ifFalse: [self error: 'wiki directory doesn''t exist'].
	rs := fn readStream.
	
	[| type |
	type := rs nextLine asSymbol.
	self wiki: (Smalltalk at: type) new.
	self wiki loadFromFile: rs] 
		ensure: [rs close].
	self loadPages.
	self wiki persistanceManager: self.
	^self wiki
    ]

    savePage: aPage [
	<category: 'private-persistance'>
	| id ws |
	id := self nextFileCounter.
	idMap at: aPage put: id.
	ws := (self directory at: id printString , '.pag') writeStream.
	
	[ws
	    nextPutAll: aPage class name;
	    nl.
	aPage saveToFile: ws under: self] 
		ensure: [ws close].
	^id
    ]

    savePages [
	<category: 'private-persistance'>
	self allPagesDo: [:aPage | self savePage: aPage]
    ]

    save [
	<category: 'private-persistance'>
	| ws |
	self reset.
	directory exists ifFalse: [Directory create: directory name].
	ws := (directory at: 'wiki.conf') writeStream.
	
	[ws
	    nextPutAll: wiki class name;
	    nl.
	wiki saveToFile: ws] 
		ensure: [ws close].
	self savePages
    ]

    directory [
	<category: 'accessing'>
	^directory
    ]

    directory: aFilename [
	<category: 'accessing'>
	directory := File name: aFilename
    ]

    addPage: aPage [
	<category: 'pages'>
	self idForPage: aPage.
	^self
    ]
]



WebServer class extend [

    wikiDirectories [
	<category: 'examples'>
	^#('GnuSmalltalkWiki')
    ]

    initializeImages [
	<category: 'examples'>
	(self at: 8080) handler addComponent:
	    (FileWebServer
		named: 'images'
		directory: (Directory kernel / '../WebServer.star') zip)
    ]

    initializeWiki [
	"Only run this method the first time."

	"WikiServer initializeNormalWiki"

	<category: 'examples'>
	self initializeImages.
	self wikiDirectories do: 
		[:eachName | 
		"Only run this method the first time."

		| wiki |
		wiki := Wiki new.
		wiki persistanceManager: (FlatFileWiki directory: eachName).
		wiki name: eachName.
		wiki rootPageTitle: 'Home Page'.
		wiki syntaxPageTitle: 'Wiki Syntax'.
		wiki filesPath: '/images'.
		wiki save.
		(self at: 8080) handler addComponent: wiki].
	(self at: 8080) start
    ]

    initializeWikiNoImages [
	"Only run this method the first time."

	"WikiServer initializeWikiNoImages"

	<category: 'examples'>
	self wikiDirectories do: 
		[:eachName | 
		"Only run this method the first time."

		| wiki |
		wiki := Wiki new.
		wiki persistanceManager: (FlatFileWiki directory: eachName).
		wiki name: eachName.
		wiki rootPageTitle: 'Home Page'.
		wiki syntaxPageTitle: 'Wiki Syntax'.
		wiki save.
		(self at: 8080) handler addComponent: wiki].
	(self at: 8080) start
    ]

    restartWiki [
	"WikiServer restartWiki"

	<category: 'examples'>
	self initializeImages.
	self wikiDirectories do: 
		[:eachName | 
		(self at: 8080) handler 
		    addComponent: (FlatFileWiki directory: eachName) load].
	(self at: 8080) start
    ]

    restartWikiNoImages [
	"WikiServer restartWikiNoImages"

	<category: 'examples'>
	self wikiDirectories do: 
		[:eachName | 
		(self at: 8080) handler 
		    addComponent: (((FlatFileWiki directory: eachName) load)
			    filesPath: nil;
			    yourself)].
	(self at: 8080) start
    ]

]



Eval [
    WikiPageHTML initialize
]

PK    �Mh@���   �     example1.sttUT	 dqXO#�XOux �  �  m��!�gx�.$��x����q��K�3Gs����q02@S�������iL��4P�n6{(1��Ͼ0/���`�1<�VH��Vj6� �-4[����O��i��s��VR�u����K��_l%�v����`E���$v�՘hkn^C�~PK
     4[h@����p  p    package.xmlUT	 #�XO#�XOux �  �  <package>
  <name>WebServer</name>
  <namespace>NetClients.WikiWorks</namespace>
  <prereq>NetClients</prereq>

  <filein>WebServer.st</filein>
  <filein>FileServer.st</filein>
  <filein>WikiServer.st</filein>
  <filein>STT.st</filein>
  <filein>Haiku.st</filein>
  <file>edit.jpg</file>
  <file>example1.stt</file>
  <file>example2.stt</file>
  <file>find.jpg</file>
  <file>head.jpg</file>
  <file>help.jpg</file>
  <file>history.jpg</file>
  <file>next.jpg</file>
  <file>prev.jpg</file>
  <file>recent.jpg</file>
  <file>rename.jpg</file>
  <file>test.st</file>
  <file>top.jpg</file>
  <file>ChangeLog</file>
</package>PK
     �Mh@j�k�|^  |^    FileServer.stUT	 dqXO#�XOux �  �  "======================================================================
|
|   File server plug-in
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000, 2001, 2008 Travis Griggs and Ken Treis
| Written by Travis Griggs, Ken Treis and others.
| Port to GNU Smalltalk, enhancements and refactory by Paolo Bonzini.
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



WebResponse subclass: FileSystemResponse [
    | file |
    
    <comment: '
A FileSystemResponse, being tied to a File object, knows about its
last modification time.'>
    <category: 'Web-File Server'>

    FileSystemResponse class >> file: aFile [
	<category: 'instance creation'>
	^self new file: aFile
    ]

    file: aFile [
	<category: 'initialize-release'>
	file := aFile
    ]

    modifiedTime [
	<category: 'response'>
	^file lastModifyTime
    ]
]



FileSystemResponse subclass: DirectoryResponse [
    
    <comment: '
A DirectoryResponse formats output of the contents of a Directory object.'>
    <category: 'Web-File Server'>

    chopName: aString [
	<category: 'response'>
	^aString size > self maxNameLength 
	    ifTrue: [(aString copyFrom: 1 to: self maxNameLength - 3) , '...']
	    ifFalse: [aString]
    ]

    maxNameLength [
	<category: 'response'>
	^30
    ]

    maxSizeLength [
	<category: 'response'>
	^6
    ]

    sendMetaHeaders [
	"While caching of file responses is generally desirable (even though
	 it can be incorrect if somebody does some uploading), caching
	 directory responses can be extremely confusing and could yield
	 incorrect uploads (where someone thinks he uploaded something and
	 actually didn't)"

	<category: 'response'>
	self
	    << '<meta http-equiv="Pragma" content="no-cache">';
	    nl.
	self
	    << '<meta http-equiv="Cache-control" content="no-cache">';
	    nl
    ]

    sendBody [
	<category: 'response'>
	self
	    << '<html><head><title>Directory Listing for ';
	    << request uri;
	    << '</title>';
	    nl;
	    sendMetaHeaders;
	    << '</head><body><h1>Directory Contents:</h1><pre>';
	    nl;
	    << 'Name';
	    next: self maxNameLength - 1 put: $ ;
	    << 'Modified on	       Size';
	    nl;
	    << '<hr>';
	    nl.
	(File name: file name) entryNames asSortedCollection 
	    do: [:each | self sendFileProperties: each].
	self << '</pre><hr><FORM ACTION="' << request uri.
	self
	    << '" METHOD="post" ENCTYPE="multipart/form-data">';
	    nl.
	self
	    << '<INPUT TYPE="file" NAME="contents">';
	    nl.
	self
	    << '<INPUT TYPE="submit" VALUE="Upload"></FORM>';
	    nl.
	self << '</body></html>'
    ]

    sendFileProperties: each [
	<category: 'response'>
	| isDirectory choppedName name subDirFile parent slash |
	each = '.' ifTrue: [^self].
	subDirFile := file / each.
	subDirFile isReadable ifFalse: [^self].
	isDirectory := subDirFile isDirectory.
	choppedName := isDirectory 
		    ifTrue: [self chopName: (each copyWith: $/)]
		    ifFalse: [self chopName: each].
	each = '..' 
	    ifTrue: 
		[slash := request uri findLast: [:each | each == $/].
		slash = 1 ifTrue: [^self].
		self << '<a href="' << (request uri copyFrom: 1 to: slash)]
	    ifFalse: [self << '<a href="' << request uri << $/ << each].
	self << '">' << choppedName << '</a>'.
	self next: self maxNameLength - choppedName size + 3 put: $ .
	self sendModifyTimeFor: subDirFile.
	isDirectory ifFalse: [self sendFileSizeFor: subDirFile].
	self nl
    ]

    sendModifyTimeFor: aFile [
	<category: 'response'>
	| date |
	date := aFile lastModifyTime at: 1.
	date day < 10 ifTrue: [self nextPut: $0].
	self << date << '	  '
    ]

    sendFileSizeFor: aFile [
	<category: 'response'>
	| size type printString |
	size := [aFile size] on: Error do: [:ex | ex return: nil].
	size isNil ifTrue: [^self].
	printString := String new: self maxSizeLength withAll: $ .
	type := #('Bytes' 'KB' 'MB' 'GB' 'TB') detect: 
			[:each | 
			| found |
			found := size < 10000.
			found ifFalse: [size := (size + 512) // 1024].
			found]
		    ifNone: 
			[^self
			    next: self maxSizeLength put: $*;
			    << ' huge!'].
	printString := printString , size rounded printString.
	printString := printString 
		    copyFrom: printString size + 1 - self maxSizeLength.
	self
	    << printString;
	    space;
	    << type
    ]
]



DirectoryResponse subclass: UploadResponse [
    
    <comment: '
An UploadResponse formats output of the contents of a Directory object,
and interprets multipart/form-data contents sent by a client that wants
to upload a file.'>
    <category: 'Web-File Server'>

    respondTo: aRequest [
	<category: 'response'>
	self doUpload: aRequest.
	super respondTo: aRequest
    ]

    doUpload: aRequest [
	"This is not a general multipart/form-data parser. The only things
	 it lacks is the ability to parse more than one field (with the
	 last boundary identified by two trailing dashes) and to build a
	 dictionary with the contents of each form field."

	<category: 'multipart'>
	| boundary str i remoteName uploadStream subHeaders |
	request := aRequest.
	boundary := self boundaryString.
	boundary isNil ifTrue: [^self].
	(request stream)
	    skipToAll: boundary;
	    nextLine.
	subHeaders := self getSubHeaders.
	subHeaders isEmpty ifTrue: [^self].
	str := subHeaders at: #'CONTENT-DISPOSITION' ifAbsent: [''].
	i := str indexOfSubCollection: 'filename="' ifAbsent: [0].
	i = 0 ifTrue: [^self].
	i := i + 10.
	(str at: i) == $" ifTrue: [^self].
	remoteName := str copyFrom: i to: (str indexOf: $" startingAt: i) - 1.
	remoteName := URL decode: remoteName.	"### not sure about this..."
	uploadStream := (self localFileFor: remoteName) writeStream.

	"Collect at least 128 bytes of content (of course, stop if we see a
	 boundary).	 We need this quantity because M$ Internet Explorer 4.0
	 for Mac appends 128 bytes of Mac file system info which we must
	 remove."
	boundary := boundary precompileSearch.
	str := self nextChunk.
	
	[i := boundary searchIn: str startingAt: 1.
	i notNil and: [str size < 128]] 
		whileTrue: [str := str , self nextChunk].
	((str at: 1) asciiValue = 0 and: 
		[(str at: 2) asciiValue = remoteName size 
		    and: [(str copyFrom: 3 to: remoteName size + 2) = remoteName]]) 
	    ifTrue: 
		[str := str copyFrom: 129 to: str size.
		i := i - 128].

	"Now do the real work"
	[i > 0] whileFalse: 
		[request stream isPeerAlive 
		    ifFalse: 
			[uploadStream close.
			(self localFileFor: remoteName) remove.
			^self].

		"While we don't encounter a chunk which could contain the
		 boundary, copy at maximum speed."
		
		[i := boundary possibleMatchSearchIn: str startingAt: 5.
		i > 0] 
			whileFalse: 
			    [uploadStream nextPutAll: str.
			    str := self nextChunk].

		"The boundary could be here. We have to look more carefully."
		i := boundary searchIn: str startingAt: i - 4.
		i > 0 
		    ifFalse: 
			["Not found, but it might finish in the next chunk..."

			uploadStream nextPutAll: (str copyFrom: 1 to: i - 5).
			str := (str copyFrom: i - 4 to: str size) , self nextChunk.
			i := boundary searchIn: str startingAt: 1]].

	"Save the last chunk in the file (the first if we didn't go through
	 the while loop."
	i > 5 ifTrue: [uploadStream nextPutAll: (str copyFrom: 1 to: i - 5)].

	"Clean things up..."
	uploadStream close
    ]

    nextChunk [
	<category: 'multipart'>
	
	request stream isPeerAlive ifFalse: [^''].
	^request stream nextAvailable: 1024
    ]

    localFileFor: remoteName [
	<category: 'multipart'>
	| idx fileName |
	idx := remoteName findLast: [:each | ':/\' includes: each].
	fileName := remoteName copyFrom: idx + 1.
	^file at: fileName
    ]

    getSubHeaders [
	<category: 'multipart'>
	| hdr subHeaders line colon |
	subHeaders := LookupTable new.
	
	[line := request stream nextLine.
	colon := line indexOf: $:.
	colon = 0] 
		whileFalse: 
		    [subHeaders at: (line copyFrom: 1 to: colon - 1) asUppercase asSymbol
			put: (line copyFrom: colon + 1) trimSeparators].
	^subHeaders
    ]

    boundaryString [
	"Decode multipart form data boundary information from a
	 header line that looks like the following line:
	 Content-Type: multipart/form-data; boundary=-----"

	<category: 'multipart'>
	| str |
	str := (request at: #'CONTENT-TYPE' ifAbsent: ['']) readStream.
	(str upTo: $;) = 'multipart/form-data' ifFalse: [^nil].
	str skipTo: $=.

	"Boundary lines *always* start with two dashes"
	^'--' , str upToEnd
    ]
]



FileSystemResponse subclass: FileResponse [
    | fileStream |
    
    <comment: '
A FileResponse outputs the contents of a whole file onto an HTTP
data stream.'>
    <category: 'Web-File Server'>

    FileResponse class >> file: aFile [
	<category: 'instance creation'>
	^
	[| fileStream |
	fileStream := aFile readStream.
	(super file: aFile)
	    fileStream: fileStream;
	    yourself] 
		on: Error
		do: [:ex | ex return: ErrorResponse forbidden]
    ]

    mimeType [
	<category: 'accessing'>
	^ContentHandler contentTypeFor: file name
    ]

    respondTo: aRequest [
	<category: 'response'>
	[super respondTo: aRequest] ensure: [fileStream close]
    ]

    sendBody [
	<category: 'response'>
	| size data read |
	size := fileStream size.
	[size > 0] whileTrue: 
		[data := fileStream next: (read := size min: 2000).
		size := size - read.
		self nextPutAll: data]
    ]

    contentLength [
	<category: 'response'>
	^fileStream size
    ]

    sendMimeType [
	<category: 'response'>
	self
	    << 'Content-Type: ';
	    << self mimeType;
	    nl
    ]

    sendStandardHeaders [
	<category: 'response'>
	super sendStandardHeaders.
	self
	    << 'Accept-Ranges: bytes';
	    nl
    ]

    fileStream: aStream [
	<category: 'initialize-release'>
	fileStream := aStream
    ]
]



FileResponse subclass: RangeResponse [
    | range |
    
    <comment: '
A RangeResponse outputs the contents of a single interval of a file
onto an HTTP data stream.'>
    <category: 'Web-File Server'>

    RangeResponse class >> file: aFile range: aRangeSpecification [
	<category: 'response'>
	| response |
	response := self file: aFile.
	^response isErrorResponse 
	    ifTrue: [response]
	    ifFalse: [response range: aRangeSpecification]
    ]

    range: aRangeSpecification [
	<category: 'initialize-release'>
	range := aRangeSpecification.
	range fileSize: fileStream size
    ]

    sendBody [
	<category: 'response'>
	self sendBody: range
    ]

    sendBody: range [
	<category: 'response'>
	| size data read |
	size := range last - range first + 1.
	fileStream position: range first.
	[size > 0] whileTrue: 
		[data := fileStream next: (read := size min: 2000).
		size := size - read.
		self nextPutAll: data]
    ]

    sendStandardHeaders [
	<category: 'response'>
	super sendStandardHeaders.
	range sendStandardHeadersOn: self
    ]

    contentLength [
	<category: 'response'>
	^range last - range first + 1
    ]
]



RangeResponse subclass: MultiRangeResponse [
    | mimeType boundary |
    
    <comment: '
A MultiRangeResponse outputs the contents of more than one interval of a
file onto an HTTP data stream, in multipart/byteranges format.'>
    <category: 'Web-File Server'>

    getBoundary [
	<category: 'caching'>
	^'------%1-!-GST-!-%2' % 
		{Time secondClock.
		Time millisecondClock}
    ]

    mimeType [
	"Cache the MIME type as computed by the FileResponse implementation"

	<category: 'caching'>
	mimeType isNil ifTrue: [mimeType := super mimeType].
	^mimeType
    ]

    sendBody [
	<category: 'response'>
	range do: 
		[:each | 
		self
		    << '--';
		    << boundary;
		    nl.
		self
		    << 'Content-type: ';
		    << self mimeType;
		    nl.
		each
		    sendStandardHeadersOn: self;
		    nl.
		self sendBody: each].
	self
	    << '--';
	    << boundary;
	    << '--';
	    nl
    ]

    sendMimeType [
	<category: 'response'>
	boundary := self getBoundary.
	self
	    << 'Content-type: multipart/byteranges; boundary=';
	    << boundary;
	    nl
    ]

    contentLength [
	<category: 'response'>
	^nil
    ]
]



Object subclass: RangeSpecification [
    
    <category: 'Web-File Server'>
    <comment: '
Subclasses of RangeSpecification contain information on the data requested
in a Range HTTP request header.'>

    RangeSpecification class >> on: aString [
	"Parse the `Range' header field, answer an instance of a subclass of
	 RangeSpecification. From RFC 2068 (HTTP 1.1) -- 1# means comma-separated
	 list with at least one element:
	 byte-ranges-specifier = bytes-unit '=' byte-range-set
	 byte-range-set  = 1#( byte-range-spec | suffix-byte-range-spec )
	 byte-range-spec = first-byte-pos '-' [last-byte-pos]
	 first-byte-pos  = 1*DIGIT
	 last-byte-pos   = 1*DIGIT
	 suffix-byte-range-spec = '-' suffix-length
	 suffix-length = 1*DIGIT'
	 "

	<category: 'parsing'>
	| stream partial current n first which ch |
	stream := ReadStream on: aString.
	partial := nil.
	which := #first.

	"Read the unit"
	(stream upToAll: 'bytes=') isEmpty ifFalse: [^nil].
	stream atEnd ifTrue: [^nil].
	
	[n := nil.
	
	[ch := stream atEnd 
		    ifTrue: [$,	"Fake an empty entry at end"]
		    ifFalse: [stream next].
	ch isDigit] 
		whileTrue: 
		    [n := n isNil ifTrue: [ch digitValue] ifFalse: [n * 10 + ch digitValue]].
	ch == $- 
	    ifTrue: 
		["Check for invalid range specifications"

		which == #last ifTrue: [^nil].
		which := #last.
		first := n].
	ch == $, 
	    ifTrue: 
		["Check for invalid range specifications"

		which == #first ifTrue: [^nil].
		first > n ifTrue: [^nil].
		n = -1 & (first = -1) ifTrue: [^nil].
		which := #first.
		current := SingleRangeSpecification new.
		current
		    first: first;
		    last: n.
		partial := partial isNil ifTrue: [current] ifFalse: [partial , current].
		stream atEnd ifTrue: [^partial]]] 
		repeat
    ]

    , anotherRange [
	<category: 'overridden'>
	self subclassResponsibility
    ]

    do: aBlock [
	<category: 'overridden'>
	self subclassResponsibility
    ]

    fileSize: size [
	<category: 'overridden'>
	self subclassResponsibility
    ]

    sendStandardHeadersOn: aStream [
	<category: 'overridden'>
	
    ]

    printOn: aStream [
	<category: 'printing'>
	self do: [:each | each sendStandardHeadersOn: aStream]
    ]
]



RangeSpecification subclass: SingleRangeSpecification [
    | first last size |
    
    <category: 'Web-File Server'>
    <comment: '
A SingleRangeSpecification contains information that will result in a
Content-Range HTTP header or multipart/byteranges subheader.'>

    first [
	<category: 'accessing'>
	^first
    ]

    last [
	<category: 'accessing'>
	^last
    ]

    first: anInteger [
	<category: 'accessing'>
	first := anInteger
    ]

    last: anInteger [
	<category: 'accessing'>
	last := anInteger
    ]

    , anotherRange [
	<category: 'overridden'>
	^(MultiRangeSpecification with: self)
	    , anotherRange;
	    yourself
    ]

    do: aBlock [
	<category: 'overridden'>
	aBlock value: self
    ]

    fileSize: fSize [
	<category: 'overridden'>
	size := fSize.

	"-500: first = nil, last = 500"
	first isNil 
	    ifTrue: 
		[first := last + size - 1.
		last := size - 1].

	"9500-: first = 9500, last = nil"
	last isNil ifTrue: [last := size - 1]
    ]

    sendStandardHeadersOn: aStream [
	<category: 'overridden'>
	aStream << 'Content-range: bytes ' << first << $- << last << $/ << size.
	aStream nl
    ]

    size [
	<category: 'overridden'>
	^1
    ]
]



RangeSpecification subclass: MultiRangeSpecification [
    | subranges |
    
    <category: 'Web-File Server'>
    <comment: '
A MultiRangeSpecification contains information on a complex Range request
header, that will result in a multipart/byteranges (MultiRangeResponse)
response.'>

    MultiRangeSpecification class >> with: aRange [
	<category: 'instance creation'>
	^(self new initialize)
	    , aRange;
	    yourself
    ]

    initialize [
	<category: 'initialize-release'>
	subranges := OrderedCollection new
    ]

    , anotherRange [
	<category: 'overridden'>
	anotherRange do: [:each | subranges add: each].
	^self
    ]

    do: aBlock [
	<category: 'overridden'>
	subranges do: aBlock
    ]

    fileSize: fSize [
	<category: 'overridden'>
	self do: [:each | each fileSize: fSize]
    ]

    sendStandardHeadersOn: aStream [
	<category: 'overridden'>
	
    ]

    size [
	<category: 'overridden'>
	^subranges size
    ]
]



Servlet subclass: FileWebServer [
    | initialDirectory uploadAuthorizer |
    
    <comment: '
A FileWebServer transforms incoming requests into appropriate FileResponses
and DirectoryResponses.'>
    <category: 'Web-File Server'>

    FileWebServer class >> named: aString [
	<category: 'instance creation'>
	^self new name: aString
    ]

    FileWebServer class >> named: aString directory: dirString [
	<category: 'instance creation'>
	^(self new)
	    name: aString;
	    directory: dirString;
	    yourself
    ]

    FileWebServer class >> new [
	<category: 'instance creation'>
	^(super new)
	    initialize;
	    yourself
    ]

    fileResponse: file request: aRequest [
	<category: 'interaction'>
	| range |
	range := aRequest at: #RANGE ifAbsent: [nil].
	range isNil ifTrue: [^FileResponse file: file].
	range := RangeSpecification on: range.
	range size = 1 ifTrue: [^RangeResponse file: file range: range].
	^MultiRangeResponse file: file range: range
    ]

    directoryResponse: aDirectory request: aRequest [
	<category: 'responding'>
	| listable |
	listable := aDirectory isReadable.
	(aRequest action sameAs: 'POST') 
	    ifTrue: 
		[^listable 
		    ifTrue: [self uploadResponse: aDirectory request: aRequest]
		    ifFalse: [ErrorResponse acceptableMethods: #('HEAD' 'GET')]].
	^(self indexResponse: aDirectory request: aRequest) ifNil: 
		[listable 
		    ifTrue: [DirectoryResponse file: aDirectory]
		    ifFalse: [ErrorResponse forbidden]]
    ]

    indexResponse: aDirectory request: aRequest [
	<category: 'interaction'>
	self indexFileNames do: 
		[:each | 
		| indexFile |
		indexFile := aDirectory / each.
		indexFile isReadable 
		    ifTrue: [^self fileResponse: indexFile request: aRequest]].
	^nil
    ]

    respondTo: aRequest [
	<category: 'interaction'>
	| response |
	response := (#('HEAD' 'GET' 'POST') includes: aRequest action asUppercase) 
		    ifTrue: [self responseFor: aRequest]
		    ifFalse: [ErrorResponse acceptableMethods: #('HEAD' 'GET' 'POST')].
	response isNil ifFalse: [response respondTo: aRequest]
    ]

    responseFor: aRequest [
	<category: 'interaction'>
	| file path |
	path := aRequest location.
	file := initialDirectory.
	path 
	    from: self depth
	    to: path size
	    do: 
		[:each | 
		(self isValidName: each) ifFalse: [^ErrorResponse notFound].
		file isDirectory ifFalse: [^ErrorResponse notFound].
		file := file directoryAt: each.
		file isReadable 
		    ifFalse: 
			[^file isDirectory 
			    ifTrue: [ErrorResponse notFound]
			    ifFalse: [ErrorResponse forbidden]]].
	file isDirectory ifTrue: [^self directoryResponse: file request: aRequest].
	^self fileResponse: file request: aRequest
    ]

    directory: aDirectory [
	<category: 'accessing'>
	initialDirectory := File name: aDirectory
    ]

    indexFileNames [
	<category: 'accessing'>
	^#('index.html' 'index.htm' 'default.html' 'default.htm')
    ]

    initialize [
	<category: 'initialize-release'>
	initialDirectory := Directory working.
	uploadAuthorizer := WebAuthorizer new.
	name := 'File'
    ]

    isValidName: aString [
	"Don't allow people to put strange characters or .. in a file directory.
	 If we allowed .., then someone could grab our password file."

	<category: 'testing'>
	^(aString indexOfSubCollection: '..') = 0 and: 
		[aString 
		    conform: [:each | each asInteger >= 32 and: [each asInteger < 127]]]
    ]

    uploadAuthorizer [
	<category: 'accessing'>
	^uploadAuthorizer
    ]

    uploadAuthorizer: aWebAuthorizer [
	<category: 'accessing'>
	uploadAuthorizer := aWebAuthorizer
    ]

    uploadLoginID: aLoginID password: aPassword [
	<category: 'accessing'>
	uploadAuthorizer := WebAuthorizer loginID: aLoginID password: aPassword
    ]

    uploadResponse: aDirectory request: aRequest [
	<category: 'responding'>
	^uploadAuthorizer 
	    authorize: aRequest
	    in: self
	    ifAuthorized: [UploadResponse file: aDirectory]
    ]
]



CharacterArray extend [

    precompileSearch [
	"Compile the receiver into some object that answers
	 #searchIn:startingAt: and #possibleMatchSearchIn:startingAt:"

	<category: 'Boyer-Moore search'>
	| encoding size |
	size := self size.
	encoding := size > 254 
		    ifTrue: [Array new: 513 withAll: size]
		    ifFalse: [ByteArray new: 513 withAll: size].

	"To find the last char of self, moving forwards"
	1 to: size do: [:i | encoding at: 2 + (self valueAt: i) put: size - i].

	"To find the first char of self, moving backwards"
	size to: 1
	    by: -1
	    do: [:i | encoding at: 258 + (self valueAt: i) put: i - 1].
	^Array with: self with: encoding
    ]

    boyerMooreSearch: string encoding: encoding startingAt: minPos [
	<category: 'Boyer-Moore search'>
	| idx searchSize size ofs |
	searchSize := encoding at: 1.
	idx := minPos + searchSize - 1.
	size := self size.
	[idx < size] whileTrue: 
		[ofs := encoding at: 2 + (self valueAt: idx).
		ofs = 0 
		    ifTrue: 
			["Look behind for the full searched string"

			ofs := searchSize.
			
			[(ofs := ofs - 1) == 0 ifTrue: [^idx - searchSize + 1].
			(string at: ofs) == (self at: idx - searchSize + ofs)] 
				whileTrue.

			"Sorry not found... yet"
			ofs := 1].
		idx := idx + ofs].
	^0
    ]

    boyerMoorePossibleMatchSearch: encoding startingAt: minPos [
	<category: 'Boyer-Moore search'>
	| idx searchSize ofs result |
	searchSize := encoding at: 1.
	idx := self size.
	result := 0.
	[idx > minPos] whileTrue: 
		[ofs := encoding at: 258 + (self valueAt: idx).
		ofs = 0 
		    ifTrue: 
			[result := idx.
			ofs := 1].
		idx := idx - ofs].
	^result
    ]

]



ArrayedCollection extend [

    searchIn: aString startingAt: minPos [
	"Same as `aString indexOfSubCollection: ... ifAbsent: [ 0 ]', where
	 the searched string is the string that was precompiled in the
	 receiver.	Optimized for minPos < self size - minPos (otherwise, you're
	 likely to win if you first use #possibleMatchSearchIn:startingAt:)"

	<category: 'Boyer-Moore search'>
	^aString 
	    boyerMooreSearch: (self at: 1)
	    encoding: (self at: 2)
	    startingAt: minPos
    ]

    possibleMatchSearchIn: aString startingAt: minPos [
	"Search for the first possible match starting from the minPos-th
	 item in the string that was precompiled in the receiver.  This
	 is not necessarily the first occurrence of the first character
	 (a later occurrence, or none at all, could be returned if the
	 algorithm discovers that the first cannot be part of a match).
	 Optimized for minPos > self size - minPos (otherwise, you're
	 likely to win if you use #searchIn:startingAt: directly)"

	<category: 'Boyer-Moore search'>
	^aString boyerMoorePossibleMatchSearch: (self at: 2) startingAt: minPos
    ]

]



WebServer class extend [

    publishMyHomeDir [
	"WebServer myHomeDirWiki"

	<category: 'examples'>
	| handler name dir |
	self terminateServer: 8080.
	name := '~' , (File stripPathFrom: Directory home).
	dir := Directory home , '/pub-www'.

	"Add a file server on a particular directory."
	handler := (self initializeServer: 8080) handler.
	handler addComponent: (FileWebServer named: name directory: dir)
    ]

]

PK    �Mh@m#63  �  
  rename.jpgUT	 dqXO#�XOux �  �  ��wP���!TT]�]�����@"�	nh��H]�X�%�j�`B�K�����xQ
�F6H��};��Ǜy;�{��9g�wΜϽҷ�)@��	 �  �q �(�Q�o��l�����3��6�ֿ����� �&@8�d� 0$�`{��g,�@2`������[6d%@�@����F7e�@���z��ɩx����jv��bӞ��?�yr���/\I߼E]Cs���^�}F��p�#V��pt:�<y����������!�a�Wc��0�32��sr�n�-.��S)�_U]C���oyB"SZ�Ri��]���/���߼��g���~V0'��Y�e�W���o\  �ǃ�W.������$|3@!�z�䔏yȟ�Q�mv}����7�9�)T�p��E]ߜg �����K���� ���l�6>���}�]b��QO']o�u=��fRQ�E#��Kl+��`���v�����iS~�������_>�h�E}��5�hM}�a/sܞ��5+��"��z��K�Ir����R��E49}0#6mg�+�`�DtI��A9,�є�;|J���lO��c�3����l',���)36�=zo�$_� l�Z��BB�=o_Ċ��U��3C��GX��%�Upn�H�r�M'��5\�o�"���!�o�Sn��+��0���L(?��=��}�\��j� �e�wQ|>��qah�V����k0jl����nm^��Y
.O/U�P.w �`B�P
��Nw�E���L��܄� }Gڴ6;�8�{G���A�\"�MI��x�B��]��_���\�֠��|�����>p�g�k�[�WI	�j8��]�_�r�}ć��=��IP�W���n�u5��&ΉRL?j�cn�w��S����q��gDܹ��#�.��]Yhh$$t�N�T�y5N�zJ� �O,�I7�*��/)�\�n/��sXP�ξ}�!2���a���f�	������7ё�E�L����;�R?ߓ���[��d%Z�ț�1/
�kI$��'���EF��(���m�|'�}s5`�:y��d䴂��]����D�kN*�����5j�.D�?=*��Jɞ�+H��SBV�*\�.,�@(c���P�B}��,�zÁ�HW��v�O�GU�(:��m���,���{:�I�r++َ��>�_��z(ɚNI������J�W}yD�d��n��e�����Z5ՄA�T7qP(�i��(�MIUb�����l�x�\0�D�oZu���į��E���:Xց8V'�z��~�f~�L!��	�x?g���l�т)����w�LZ�үo8�+���_V������TN�V64�x��1�L�w6�/X���r팬�S*��Q`��"0e��)B.�C�A�W�չ���CnA����泏>���R]� yye��!$� �0y�)���pv� ������^�a� �m�~�P���WXf+!�E�-2ĴP���z��/�l����1˛���|�W���Nk���1Lt�O���Y�9Z
CL;@E�q�Z�^v릻G�i^/���������}����zF��6��CHͺ�n9޺�����s��F:�مÁ��3�-#~�4����-��K[XdT���h[W��=�.m�U	r� 	L��e�s�8�kaJ�L�>�Mi�$W�F��+�âKߏ�?������0������Y�A��*zj�B��W�$��m�43���c�^��́�rR��s�,�ٰ�p9\�E��-���N��〤�v8��@n���W~L^��,"����^\�*Hb�$�ԋ��g���:��k�ۑ�"/��WT�U�����[-����H�@�ѳ'�/ز�z�1��>\��1� h�y�[��5��:O����V�h���!<�|=���d���gO���	��p�ߘ3H
�.����lJv&��r�Vt;)�/��k'|E߫	�F��ظ�,��:��_]v>��b��r�1L���E����S�NLw�z���8�n��>��Z�V���5
�oX6x C�	īґPK    �Mh@)	ſm  1    help.jpgUT	 dqXO#�XOux �  �  ��yP��ƿl���+�@�W��"�$H� �E�"E�&�e���]BYBX�-,	
D)���E%(ɇARrc�i�ǝ����s�g�3g��}S�7�����@  "<�`�V�[P�0~���ː�[�n��<d� 4`��PYL"�P�=���
�#DD��%$��6 
���p����> �Eȩ�A�����0��)S;u�� �9m�/.!�p谢������)����q��g��r�����Ew�o.��W��#�GRnD%$&%�������ݺM����U�kj�[Z���]}����GC���9195=3�Yx�nq��p��ͭm���/\ ���W.Y!��E�pA��_�p��Q9Q���q�؁S9��{��L܃~��%�Ѧ�������X��E�'�_\3�>D�y0Y ��iQ��ű'��d�}��b�SF�H�ְ�P �^���&(c@i�H4��)��a�_2�rFL��0лR9�������a�s��-F�f�%>X��L�aZ��ԧ-�!v���HI�ǜc�Vz�����i�A�P�]����&���]�N[Ėkz?�$�m�{��̷�u���k�������Tܓ��@Ҡ��RL,҅kE��Q��M5#��]k����q�=6�HH���t���i��s�+��dOgs��1�Z�3-���'x�MR�ފ\T
fh}�������)cC_�+B���\f�_;�{<�Z3ku����F�CDtk��͒�fpU��W(�g�K��5X�iuN�ܮۤ�@I�Ǳ��2�,��<��h@K�XR�uL{��o�����wZ�x���ռ,@�Ҫ���KWJ~C�Ԅq	 +��A�bB޳�RV(vt�	�+�G�R6���~�[�A��DI|��V;X�}��y�^��[Z�{#١��,s�h��w��kUS�{���g\O0%_�?��"�j�q5��p=OW�ͪ,�r;Y�����\�Y��7 4��)�m��${/^1Wb�_ ���)��}T�4L��O�vn��޶����������5ޘ$����XCU��S�	��RB'�fE�-y-�>��� ���z����p�rvO]�|'ur�G&������Zz+L0�m� +@T��~�>Ų�p��:ؔ(R\DC��0�EF�i�G3K<��k2��{�I$F;i��1{4��}:����X�}S]ĭdG�Z#'[���^��@���3k��U�z
I!U�����g��'��K�v��2�q���t'�K���O�8���V�J5��W��������oC"x�r&l6B"��ceRI�b�?£������.3���>�K�>( V~��
{��s�s�W F?t�6ky�d�M$�EI������� �=z8H H3ɕm����]K����k����~�@��	��/=|lm�5�3��T��h0�&��|�	����X*OM$����q#���dL�9�n68�?"���롯��y�^A�����(J�q�QZN�ɇV�fx>7]v7��;:�h�~���~9���|9u`��&�}�N��)�K.���t�\]�d�:�xst�xޮ�n�Z]^Y幥[��
FSZ��F�a2Ӂ\���}���>���n�<�Ti��갂���Xuǳ�u���D!�(fs�&ɵ���N�9�w������³�Y��o˿��!���\�ҀB�O�Dj�����p�sZ���7]&g=+��^�:%ok�8t<��m��E�f��є	�7�H��K���\'��򮘇~���򌝝�][�R��X��j�m��yF��5z�dƯ����m��w�Ϗ�{�f��1'0����Ý�]�],*�㮑3׵����,��>�����F�����f���;J&�p%�t�l�_�����|B�:��%��PK    �Mh@:R%�&	  �	  
  recent.jpgUT	 dqXO#�XOux �  �  ��{P�gƿ�p��"ʒR�RQ�@�B���`)
D@n���Ђ� Ԡ�#�(&PAC �m��[�IK@�R�4!Y�v���3���3�=s�9s~﫚P� �|<�= `kPM�k�����Z���7�OC�l���/K�@j��9�����0@�������o�����Z�:�k�&@��!����Z7{� ��zf{hl�Ei~��o�w�^����c��a���XJ�����㭖ۿ��r�=��w���AO�C�>�����C����?���~:��y��|aQ����W����J�q���H�Ÿ�v��n����>����?�d�)�?2:6>!�Ē;�yN:/[z�������O\0 ����W.��Gh~₩e|2 �f{4��4��7n����v���cms� ��Xʰ�����R�	�W��������X��}	�J�ՍR`�Z�5�Da��KtNo}v"[l-���%�8�K��C�����j�.Ok����ߴ�����X�ܺ����O��	��
�Ǟw�RfzuF�#�Kܨ�jeɠδ���U�8^Z+8vY�J�i����<�e����n[J��=0�_�Ew�a9���!���EI:
+�m�y�֒���^�<n9�:x���X2V����H:��]u�Ε6
*!����4�rQ��
/�(�Ei��*����u�}�D��o�������l8��uЈK�q���egv�h���43�a��/�6��Z��b�0�c\���K�3�����������7Uj�q�����Et��;���>E= V�2G���!^nj���{�ߞ�O=*�wV:�~��M��* ���L�C�9C* �c6��*�u�Q�y�S��#�a(�~@���O�%��ϙ9ls�b�DH��GY$D ���@�og�ʹ��x����ƃS"x��a?m�+B9�s9�<\a|2����
��
BR������3�R�m9J?[t��輏�QZAe�U]�xѬL}���h��+�=�v*;�+�ej��9�+�gfB)\��v�����>����*���CY�JA:��|�Ds�Z���w[��&��+���n]�!c]}��n�©.o���U4��C��E4,ŷ�}�ӌ�EZ�&s3�)`��
,E2$c_p�K�T�kG��&^
�_P��L_T�"z��:WJ)/��7��
���9c[����J�Y�M�8a�{rFI�qJzVv��
���ڛ��EL�j�Q��n>7s�2Z���cW�T@���
_Ȳ��������6(v�=���q+��,c7�bR��_�u���)~�q�Dru������M�,��/JGqn4k��Z�	��p{`'[ӱ�#�?�@���KM�-8�����3!���܊���+G��gd�T�),Ϋ�
$�Ί~��g����C�_C�T��%�����#��1>�bh�[.�ñ��\im�[Q���6Ӄ6d�}!����L�w]\�/�L �h:S�M��v>5����^��X�;����*t�{9�Zυ���ڞdr0G�����#�r(���"����ļ�9a�uR4-���5ǜ:!���`�I�^�-pZ���Kˉ��Oe���x�Tm�E���8�u5 �U�9�Q[U )��Su�{�A�A|{���-� 0��i�L��I�ӗ���S&_(`rwr/��M,2���������6c���7��P�M7�����p�<r8���d<�.2�4�t^xp����Ϙ���1�5�JJP n�P�PQ�M|��oՇ��G�+l�~���gu�n0|�yM�>��m�>�z�ےK	7�ӆd����Z��0��znc*��n�_d[koo�,R���z�F{�p�a��wVz���R9ҝ�O&�!����q!���b]�D�����u�Qw��3�W���\t���g���{���L���Jߞ:O�@L�;�n��F����"��j����G7&49��k"�W�)-�$�ի/"�Ť��`SC��Jp��I�z#J��j�ڝX��U5F���Y��/>�ؑ�^X~���ץ�d#{
��.Vs��MQ����pQ���{���A}\$�w����LntZ�����c��
Q0�	��z�+A��qH�`�MTJ�O a�)��$����6�P�LR���wz=y��o�4�6Y���=�]�Edx7C=ڤ�p� ��P��5�D�=a��S�B�	(3D�Bő[dI/uC׶z�A�/�F�N������?.{KP{3%8j�����5.���t�꟤���_Y����o�R��fI�wۃs��~������7�2�q���a��8�g$�J�oPK
     �Mh@^fr��  �    Haiku.stUT	 dqXO#�XOux �  �  ErrorResponse class extend [

    haikuErrorMessages: aBoolean [
	<category: 'haiku'>
	aBoolean ifFalse: [self initialize] ifTrue: [self initialize: self haiku]
    ]

    haiku [
	<category: 'haiku'>
	^#(#(404 'Not found' '<P><BLOCKQUOTE><I>Rather than a beep<BR>
Or a rude error message,<BR>
These words: "File not found."</I></BLOCKQUOTE></P>

<P>The requested URL was not found on this server.</P>') #(410 'Gone' '<P><BLOCKQUOTE><I>You step in the stream,<BR>
but the water has moved on.<BR>
This page is not here.</I></BLOCKQUOTE></P>

<P>The requested resource is no longer available at the server and no
forwarding address is known. This condition should be considered
permanent.</P>') #(414 'Request-URI Too Long' '<P><BLOCKQUOTE><I>Out of memory.<BR>
We wish to hold the whole sky,<BR>
But we never will.</I></BLOCKQUOTE></P>

<P>The server is refusing to service the request because the requested
URL is longer than the server is willing to interpret. This condition
is most likely due to a client''s improper conversion of a POST request
with long query information to a GET request.</P>') #(503 'Service unavailable' '<P><BLOCKQUOTE><I>Stay the patient course<BR>
Of little worth is your ire<BR>
The network is down.</I></BLOCKQUOTE></P>

<P>The server is currently unable to handle the request due to a
temporary overloading or maintenance of the server. This is a temporary
condition.</P>'))
    ]

]



Eval [
    ErrorResponse haikuErrorMessages: true
]

PK
     �Mh@(9��#&  #&    STT.stUT	 dqXO#�XOux �  �  "=====================================================================
|
|   Smalltalk templates
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Federico G. Stilman
| Porting by Markus Fritsche and Paolo Bonzini
| Integration with the web server framework by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
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



Object subclass: STTTemplate [
    | sttCode cache asStringSelector |
    
    <category: 'Web-STT'>
    <comment: 'This class implements template � la JSP, PHP, ASP (ugh!), and so on.
Smalltalk code is included between {% and %} tags.  The only caution
is not to include comments between a period or an open parentheses
of any kind, and the closing %}.

For example

    %{ "Comment" 1 to: 5 do: [ %} yes<br> %{ ] %}    is valid 
    %{ 1 to: 5 do: [ "Comment" %} yes<br> %{ ] %}    is not valid

This restriction might be removed in the future.

The template is evaluated by sending #evaluateOn: or #evaluateOn:stream:
and returns the output stream (available to the code as the variable `out'').
The first (or only) argument of these two methods is available to the
code as `self'').'>

    STTTemplate class >> test [
	<category: 'unit testing'>
	| sttTest |
	sttTest := '
        <html>
	<head><title>{%= self class %}</title></head>
	<body>
		<table>
			{% self to: 10 do: [ :each | %}
		        <tr>
				   <td>{%= each printString %}</td>
				   <td>{%= (each * 2) printString %}</td>
		        </tr>
		   	{% ] %}
		</table>
	</body>
	</html>'.
	^(STTTemplate on: sttTest) evaluateOn: 1
    ]

    STTTemplate class >> test2 [
	<category: 'unit testing'>
	| sttTest |
	sttTest := '
	<html>
	<head><title>{%= self class %}</title></head>

	{% 
		out nextPutAll: ''This is another test''; nl.

		1 to: 15 do: [:x |
                    out nextPutAll: ''<p>This paragraph was manually sent out '',
                                    (self * x) printString, ''</p>''; nl ].

		out nextPutAll: ''After all this ST code goes the final HTML closing tag''.
	%}

	</html>'.
	^(STTTemplate on: sttTest) evaluateOn: 3
    ]

    STTTemplate class >> on: aString [
	"Creates an instance of the receiver on aString"

	<category: 'instance creation'>
	^self on: aString asStringSelector: self defaultAsStringSelector
    ]

    STTTemplate class >> on: aString asStringSelector: aSymbol [
	"Creates an instance of the receiver on aString"

	<category: 'instance creation'>
	^self new initializeOn: aString asStringSelector: aSymbol
    ]

    STTTemplate class >> defaultAsStringSelector [
	<category: 'defaults'>
	^#displayString
    ]

    cache [
	"Returns the receiver's cached object"

	<category: 'caching'>
	^cache
    ]

    cache: anObject [
	"Save anObject in the receiver's cache"

	<category: 'caching'>
	cache := anObject
    ]

    initializeCache [
	"Initialize the receiver's cache"

	<category: 'caching'>
	cache := nil
    ]

    isCached [
	"Tell if the receiver is cached or not. In the future
	 this will consider the fact that a cached object may
	 become old after some time, and that means that the
	 object is NOT cached anymore."

	<category: 'caching'>
	^self cache notNil
    ]

    asSmalltalkCodeOn: anObject [
	"Returns the equivalent version of the receiver as a Smalltalk
	 CompiledMethod"

	<category: 'private'>
	| method stream |
	self isCached ifTrue: [^self cache].
	stream := String new writeStream.
	self writeSmalltalkCodeOn: stream.
	method := anObject class compile: stream.
	self cache: method.
	anObject class removeSelector: method selector.
	^method
    ]

    writeSmalltalkCodeOn: stream [
	"Write the equivalent version of the receiver as Smalltalk code
	 on the given stream"

	<category: 'private'>
	| sttOpenIndex sttCloseIndex lastIndex sttCodeIndex smalltalkExpression |
	stream
	    nextPutAll: 'STT_Cache';
	    print: self asOop;
	    nextPutAll: ': out [';
	    nl.
	lastIndex := 1.
	
	[(sttOpenIndex := self sttCode indexOfSubCollection: '{%'
		    startingAt: lastIndex) > 0] 
		whileTrue: 
		    [self 
			writeOutputCodeFor: (self sttCode copyFrom: lastIndex to: sttOpenIndex - 1)
			on: stream.
		    sttCloseIndex := self sttCode 
				indexOfSubCollection: '%}'
				startingAt: sttOpenIndex
				ifAbsent: [^self error: 'Missing closing tag'].
		    sttCodeIndex := sttOpenIndex + 2.
		    (sttCode at: sttOpenIndex + 2) = $= 
			ifTrue: 
			    [stream nextPutAll: 'out nextPutAll: ('.
			    sttCodeIndex := sttCodeIndex + 1].
		    smalltalkExpression := sttCode copyFrom: sttCodeIndex to: sttCloseIndex - 1.
		    smalltalkExpression := smalltalkExpression trimSeparators.
		    stream nextPutAll: smalltalkExpression.
		    (sttCode at: sttOpenIndex + 2) = $= 
			ifTrue: 
			    [stream nextPutAll: ') ' , self asStringSelector asString.
			    sttCodeIndex := sttCodeIndex + 1].
		    ('|[({.' includes: smalltalkExpression last) ifFalse: [stream nextPut: $.].
		    stream nl.
		    lastIndex := sttCloseIndex + 2].
	self 
	    writeOutputCodeFor: (self sttCode copyFrom: lastIndex to: sttCode size)
	    on: stream.
	stream nextPutAll: '^out ]'
    ]

    writeOutputCodeFor: aString on: aStream [
	"Writes on aStream the required Smalltalk code for outputing aString on 'out'"

	<category: 'private'>
	aStream
	    nextPutAll: 'out nextPutAll: ''';
	    nextPutAll: aString;
	    nextPutAll: '''.';
	    nl
    ]

    evaluateOn: anObject [
	"Evaluates the receiver to anObject"

	<category: 'evaluating'>
	^(self evaluateOn: anObject stream: String new writeStream) contents
    ]

    evaluateOn: anObject stream: out [
	"Evaluates the receiver to anObject"

	<category: 'evaluating'>
	^anObject perform: (self asSmalltalkCodeOn: anObject) with: out
    ]

    sttCode [
	"Returns the receiver's Smalltalk Template code"

	<category: 'accessing'>
	^sttCode
    ]

    asStringSelector [
	"Returns the selector used to show objects as Strings on the receiver"

	<category: 'accessing'>
	^asStringSelector
    ]

    asStringSelector: aSymbol [
	"Sets the selector used to show objects as Strings on the receiver"

	<category: 'accessing'>
	asStringSelector := aSymbol
    ]

    initializeOn: aString asStringSelector: aSymbol [
	<category: 'initializing'>
	sttCode := aString.
	asStringSelector := aSymbol.
	self initializeCache
    ]
]



WebResponse subclass: STTResponse [
    | stt |
    
    <comment: 'A WebResponse that uses STTTemplate to implement #sendBody.'>
    <category: 'Web-STT'>

    STTResponse class >> respondTo: aRequest with: aSTTTemplate [
	<category: 'responding'>
	(self new)
	    stt: aSTTTemplate;
	    respondTo: aRequest
    ]

    sendBody [
	<category: 'sending'>
	[self stt evaluateOn: self stream: responseStream] on: Error
	    do: 
		[:ex | 
		responseStream
		    << ex messageText;
		    nl;
		    << '<pre>'.
		Smalltalk backtraceOn: responseStream.
		responseStream
		    nl;
		    << '</pre>'.
		ex return]
    ]

    stt [
	<category: 'accessing'>
	^stt
    ]

    stt: aSTTTemplate [
	<category: 'accessing'>
	stt := aSTTTemplate
    ]
]



Servlet subclass: STTServlet [
    | stt |
    
    <comment: 'A Servlet that uses a STTResponse to implement #respondTo:.  Pass
a File, Stream, String or STTTemplate to its #stt: instance-side
method to complete the initialization of the servlet.'>
    <category: 'Web-STT'>

    respondTo: aRequest [
	<category: 'accessing'>
	STTResponse respondTo: aRequest with: self stt
    ]

    stt [
	<category: 'accessing'>
	^stt
    ]

    stt: aSTTTemplate [
	<category: 'accessing'>
	(aSTTTemplate isKindOf: File) 
	    ifTrue: 
		[self stt: aSTTTemplate readStream contents.
		^self].
	(aSTTTemplate isKindOf: Stream) 
	    ifTrue: 
		[self stt: aSTTTemplate contents.
		^self].
	(aSTTTemplate isKindOf: STTTemplate) 
	    ifFalse: 
		[self stt: (STTTemplate on: aSTTTemplate).
		^self].
	stt := aSTTTemplate
    ]
]



FileWebServer subclass: STTFileWebServer [
    | knownSTTs |
    
    <comment: 'A FileWebServer that uses STT to process .stt files.  Templates are
cached.'>
    <category: 'Web-STT'>

    initialize [
	<category: 'accessing'>
	super initialize.
	knownSTTs := LookupTable new
    ]

    fileResponse: file request: aRequest [
	<category: 'accessing'>
	| stt |
	('*.stt' match: file name) 
	    ifFalse: [^super fileResponse: file request: aRequest].
	stt := knownSTTs at: file name
		    ifAbsentPut: [STTTemplate on: file readStream contents].
	^STTResponse new stt: stt
    ]
]



WebServer class extend [

    publishMyFileSystem [
	"Watch out!! Security hole, they could steal /etc/passwd!!"

	"WebServer publishMyFileSystem"

	<category: 'testing'>
	| handler |
	self terminateServer: 8080.

	"Add a file server on a particular directory."
	handler := (self initializeServer: 8080) handler.
	handler addComponent: (STTFileWebServer named: 'disk' directory: '/')
    ]

]

PK    �Mh@f�>��  �    next.jpgUT	 dqXO#�XOux �  �  ��{4��ǿss��BFeJk�u2sI֤�!V��p�Pf��U�%Ke�0�R�1�a�Z�K�r��l(f�-���ߞ���w�o���9�y>�y��9����D�v�� �  $?�lp�W�[`�<����xk�?����k�p%�0�� 0��dm��|O��
�@a
�J�*�rw; A `(�B��+�> ��v�[S���h�별�B%�S�@��#1�<������[a����A�#�6�v���1.�X���i�חg����)��/��豗��M�z-���7s���n���%�?���pj�u��[�m�O������?084�|D<5����o�f�o�--����_�����r��\`(U���i[8�o��㘇b@�N���v9eV���D�湨-C+��t�������7���?�����m����b�rن��>�2�q%��|����[8���uÛ�B9���C��+��K���j�أC��b:X�7#�4�x��J�_�����ɚ:{�q�]���]�g�kg�'֮�?�Ҍq���Mh�G^��\Y��66��iIݯ�(�(q�����S����P���d.	��/zO�΅Դ~*z�I;�|��i'>6h�:�J��a�;��RP��b��J�+���4���(�[�JK���'��q�d�� ^Ě܅r��LDW�
���D��ƺ����g�y�aT�O�w�_h֘���N]$�mk���1	����w��C3r��@�� xu��z����Z3'B�Nn�bl�(5�t޸�I�$�,�:�u��e�s��q��G~���x������t���͆"���Q��ƈCg(%O�1}�-'�Vy6��g�9�v�:g��_
B��qOQ�v�=K"�m�,�f�0��)����ƈ*q��k�6�j:JOT�}|��1O�*;��=�l4�N�U���:C=*�va��L`ʃM9������x�I ��t�M��dB�a�	���v�;h�OѢR����S+ɤ��	�嫣 S�*�k����K,���Ѩ���
3�z>�oׄ�}�f��S�o��GWNK&_�I�bZ��� �G�S�2��G1Ϭ�ÝI-��f���a��(p_Ӥ�n�eu��>������<�rgjx���?e�<9�e?��[�E�C��3vf�+�%����܁�AG-z��8��&Ad9�c��&�L-���-�C=s�a�<�N�f���uNIw���50����b*@a��HV��u+�X�$��F�TZS��k�g�gwȀ��(�B�����^�'𼾴��������=��/3Mj����r}>�m��=�)��<�}�f�<�V_�Ynk�[���������셺������͞�|L���z.�98�^a�̭o"1�{��A��h{�X��z\pǨ|Hթ�Y,���M#�	�g܌d{�n�Oߡe��q������	n�����_] �k^��l>����q�|���-����l��s�车,�o���+7�%��I��4ߞ|�Ln�
�4��4a.u�7?\m�����G��U�\Pl�+i�[�,�!��h�1�P]}]n]���0�����="���+b�;2�O�(�������/zx���[�E�}���QHI��er줇��䮈�d߼�I~�<����M�T�1���2�P�����e�Lkt��AU���U$�<�c�X3�R�1�)-J�S;���nV�l����PK    �Mh@¦�`  �  	  ChangeLogUT	 dqXO#�XOux �  �  ��Qk�0���_q��AKڹMEĹ1��Y>����m�$�����V����t�ﻻ$b!���g=���`J�[*	0Z��$UU@:{���\d<�`[�C�Ă6�j0U�z�WT�d�c�<5��E��E~8�xs�1����!��X��T�r%�_r�	�V`i%�V�>��Q�Qc��K�&�M�Z*fZ��vג��=�{�[�[�^��}�Ç��.Ϩ_�v�P�@�^O؞#_�m�UX�� rn��6z�ɳ{2�Z�_���W^lƭ�u!�����$����R��J% �(�.��s�7�����F�!��FX�o���ȋvl�\��W���эhÉ"�U�3u�2N��+�~ PK    �Mh@eR��   U    example2.sttUT	 dqXO#�XOux �  �  e�?k�0���S��x	1��� [��V:��IXg����.ms�t��xz�3J�Z�ydg͵xA����QJ(n���*S�Z@����v���;�j��0&H�<�	l���n��j5�Oh�z�|)����&�"M�O\(�L~&�>ş�T��p�ׂ8���,g�lM������]��\$�w�c�Sh-�`��Xt�'�}��*�$P0��F7�$���7PK    �Mh@����  >    history.jpgUT	 dqXO#�XOux �  �  ��yT�W�!aU�Hٔ�F��(�Be52$E�%�TE@�AvH���J�( kd��EY" F������ $����9�3�w�y������}��I��9�  ho��v/���ۿ���ϛ�~��Z�j���d% -�� DdA`Y��P�{����$����KHJ�3�" 0X�@����< ��S?~F��+�"�{y�6��
�{8ZF��H���������8��glbjv򔹭����Y�9W7���7�^/]����x+�619��y���,�?Q�
���OKJ�����5/j�^����3�tt����?���g>�:;7��������������?�_�d��D 0D|�$�o�����;�"��8񃄼ͽ��fIM����o�H������}����X��E�؟\��A0h�����5 ��1��)�Ƅm��*�b�s&����Pҕ�e�ɳQ����N+|۴Ċx9q�jd��EKJxE�����;$B-�'��,|�����zZr���}�Nj�~�Dv�>F�����r�:5�L��55�/2�Gp�s�Zuٻc]K��QS�!��S��И$5�Z��-�J�8���^�u>g%�)N�R��)i�A���\��w����;�����\�F7�/O}���tl��Q��|�L���T�_�,2w.ή�����E��BXby����	�T��L?m֦����ļ��(���;�wXIq骑��a�����i�C�~�AH^7�J$��[�&=����v�(|B�����C�g�?7��e���ژN��X4]�̾���\ �7i��H�3�V���Զ_�Q̌�R��bp��-7t{�75�vK��
f*��oG����SfJ�ː
�'/*Z�Q{ר��Y�	9F�_��}c��0K��rX����<b:㶕�b$�P?�P��gx�����,�=��P>�e�s�~�H�W��+ߒ@���EGV�v&j�S�r�$mN���iwf��{墨=�8;z��vr�����<&�nj#8�3��9��p�w�)���Ne#W ��D=!P8��N}�[��4-�r�uS��\���M�7N���mJ�{E%t��-~Ml��ҫ���t&�R��hr(������b����L6�Y���V�x��1S�>�Y���3~��ע��|����U�Y8ɺOC��1�]Y&N^?A��[�����z�Z-�q��C��FL!	�_����&.������W� ��?W�U��k����|3����i#��GXm�L�>��4${�����F(��Ȃެ�z���qi(J~�pn�U8�w��2,/h̦�5�E���ɺ�N�XP���
q����2���6R8eS*j����\�->!z�٨Yz2;�Ův��
C$_�=�d�7�B::�_���ߤ�[�n-�P�q�.�dn�ʜ�R����*3f]���5C{�DD��Xu�c��*0[I'(�6aP��U���S����e`M?qM�Agu#��!��fˬOs����n���<2U��r�mֲ�U����\�M�э�Mł�X��n� ��h�TܢW�Z�>�8zq���q`o�C;���)]��C{����ʶ��'ϱ$�<�/=�t�4}��$��i�^H��7�b׫����/��Vj}���@���ȷf~����e�7]�M$bY��x{˚�:�w�������"3(��L��Rj�;���rF��E����x�U���By�W�UOhm,z������	߂D��-�o}3����Kw��P���#�S��O��."���:1�R��T�ӜB���o6�W�}*Qǻ�fT�튦��$����9�{�����P�h��O��ӪUǓ,]��,�u�7��F"/=��#�
��PK    �Mh@Aiw��  \    prev.jpgUT	 dqXO#�XOux �  �  ��{4��ǿsC$M$�rJCLL.�j�Y
!ɥ�2&a�fg'
�K���X#�e]�]�u)���J�25*�(a}���2X��gw������{�s��s��y���|V���6�:�80 ���:�_������#���o��!�������z@+ � ���a4l��[��������H����E�5C�f C �H
�D�u�� �ڲ��^N�3X~g��yrN���C���^C�.��Q)շihjaw[⭬��ٷ�����AWo���|������}A=u�ltL,�\\ꅋi��2s�~�g\-,���bW�������������.^w�������/�c��τ"���7So�gf�?�����g��u.�����+z��D"���\0x��D�0��b�)���<YA�!����}/p�ɨ!E�]�"��:�d�,��"��o.!�[�< ++�+2��M��B���y�����!#�lkҤ�;�ҁ�2=P��
�1O�:�X>��ٔp(�,��F4	o󮒰�������_�/U'>vzB�P� J�\I�&��p`{ ���:C��!"��x�o�5�������$6t�t\����B�����O���,|/��k�֊�D��=�.��
g�:Hj�8�A��8���/�Q�WaR�B3�o0��.��kh��|�j>�Y,��P��j�T�,q���F��v�Ҡ���s�Mfc\��9QsɋZ5��K@;���A��e��g>�˰}\���M(��(�$���N��|Y�y5���(�>RD6��S��t�t��\Fh5�Y�m��uJ����oU�=��R�8%@W�c/q����:>_9o�<Y,��Jx��埸�&�I*R��[��9N���;oroŞ�،c�b�[�g�����i��kM'SƋ��:�6�����~-���"��M�j91�7����zwO����Z	[vz��N5E.tz;}Rj��M�8;������"Y15���%ʽ:�GSۊ��I#6{ s�����(��a]�����C}׶�'�\SvrMo,�E+�x!d(�)Ua�22���ODp�5�ɻڐGW����Wn�L���$�j�d9@�i����_炡Dk:"�R��7l�E��D��f��,�5��|��X�pô9K �r��ÕK�S�����"��B��r���d�@j����z8>E�1	xM���q�bo񞉴��A�5�rZ�`��θ�,���S�T���R�2I�`R�DZ
ۥ�(��j�:����L� j���heɑiq�V\_�Wv���	nC�R��ÊBe�b2L�L���f��l~��n>�'���2S��-=T$q1�����0���y~A��sX�붢���L� p�� ��Z�������鶌HF�Ɓ!���y>��ǂ�Һ��tw�[P^|�L#CD�������a{�C-y��/Ӣ��'�՘�Iô�U@�9���>�CԘ��a����Y���������PF����Y{���*ϸ�r%;�TR��]d3廬���L�⪳�eS�#�\���K�Αc���#N|WU��)T��^��1�=}fF��}Ί���|�pi�����"���P����YTdK� $���)g�\�˸
��Y����w9���!(���~Q��gВSʃA���|��{xHul��ry�p�p{{ځ4��=�$��&(��;g^�GBJ|�n�1��:Fmmؔ@?Zы����ٽngN=�#Ӵ�)<wڢ��i:6�H���k��ϪT	��a�ԏ_c5cQ��e>�����/����������@�]��<����ϰu-��_i�~�,���7���-X��Ŵ��{'���U]hVԔ��oe���κ��uZCq�b�65��M)���&iL�_���$�
�
-�o��瞪yV����`��z#;/n%�-�q��>�R���zч+���[>yc%!��~PK    �Mh@D]]�#  %    head.jpgUT	 dqXO#�XOux �  �  �xwT��o�
G�"-* -��  p ��B�	D��#UA�PC��� �ADZ�N��4�Q�B���{�o����Κ53k��?{w��3k	�obhl;r;�>`�Y�>�����e��q����wG�����O�����	������8";*p�C��&Ŷ���V��u�(Ǳ�'8Orq�Z�aG�pp=�q���c����c��\�z󄠥����kO����k��dU�<����xI�����uM-m�[�F��M�X����;8���x���
	Ņ=������OHL�����y�2������XQY��������m{�������c��ԩ��34��կ����?���A���������%��u��1�c���u�h���p�ę���n���מ�<������KF�
�0�-,�F���?���{���쿀�7��)�#��q��0��-��6�����Ôe�#��P�2�ۛs�� 4v��q�ԔM�6-ԃ&�|<~���]@+�5��&�t��a	j���e�'���>@�@�>R��f�nS��$]t��ܞ��Q�B���B'���Q��ip0-~L�2]�̊������-v�CiKd,�;lZb�$qh4���+���8C3B�6��vc���O��-�|uB����B�v���:�>�ӭ�齺�y��m��jntբ�*��Kl��w���w��(q�9Y7t%c�V9�:˱�>id�[}N�(O-����P��������42���*�Q��!ڡ��b?_�� ��B\�H��G3�ؚ���o�,X2BU[�����f)�c7�NL��L����ݧ���v1�)%�u�0ű��{�v�^m�T��↚L����g!$�;������g>��Ѧq���7h�uS�xo:���߼�<���N2��5�&eo���,�xb��wV�j��]ߊ����(n^�(!1M�f�#�ҍP̓�tL��I�J��I\����k���]G�qP$�S��%OG�ɱ����O�O3��j#Q�����b�v�.�*m�{[�&|�����]KSOu�oჩ|(��A���,XBѭ�FY8��[횾?3�C�q�î̸<�9�fZdo�u,G�n���;�^���|��=��+=}%�j�Xs�kjv@br甌��75�0��;Ji���B������������r��7����;رD;](0҇>�]�g(��×�+��.T�7�"�G���p!�dE,�r
X�A�S}�	���MƇ�>g�y)^r9��>a�� !�� �}se�,���Uԏ�?���A�}�d���Wۿ�N��-��Bv��g��v׌շH>�6���8�-x�'����(J`��;~�4�?f���R����a5�.�% ��C�Z�qy�MT�=B�؋Wsѻp#��k���ޚ�ᯞ�3�kUDK�嬵vOدJ�2ڈ��Ѷ#�����a�Ғ�-jQ�����W���˂M����z+
�9LXZ���N���8���Sx�9Ln�K`�cI����HI�GQ#��|j#�/�9	��@s	�������S��H�)�1^�[!ʛ�k�ڦ�/��50�E�ԎBZ[7�^)�:���׻u�;�*|��W*�PP����~ȋ=���ߎ�A�v�cM)o���\xa���נ�>���ȢO��䲂�0�/s�	kZ�^�;���P<D��ɱ:ד*�m�ӣ�kV�d���3�.D�ZT��r�Ɂ���J�G5��F)	����ѱ��$�@�&}��ɼ�{G3��Q%�-�E����oݏ�
��D��&�N�7�ƅ�^��O���,�&tA$'���&D�B9td�:�:�qh���*���R�Nh�(�W�{r?�����IW8�:�5[��vt4$�tn��U�gZ|�2r&�{��2;٢�7��:z���'�����꺦�m��G2�-��DL�}Â���rU��(\x_�u���d��%	���#Tݿ]��g\-�������u���';�-�3f�2��_��M�<cX0OB\�)����M�ސ��	B���8}��r-�_�f2/R�i���oҫ�?�'}s��%4�w���}J&B��o��ܸ��*��f,5�G�ZN�~o.�y�d��Y}�*�P�✙���U���A�z��)"����|PU͔��en�zq�������b߆"<y���=�@7�&Sp���}�1;��> �<��ص X����o��Rs�U����V|�0��	����f>�)@�0���.{I'"��i��e�$7��@`���"m���{={�+@Zt��WbY��I[���أ��|l�~1� �3O:����O��:>�?���O���Q1㘩ĳs�O.�>���A���+4�R��~�S"6I����O�_�M�mHEE�����IԶg���ܪ¦#��B�����9|�=c�*�[_�2˴_���Wh�_)/�`+0{�ST�'W�È�d�Jل鍖������Ȫ��&�LR.�e��d����q�������I�����znlPG�R:o�^���cxTa���/6M(!�*]������RW��N�V��8=���e��qR]R"�K�'Ш��ǰ��;��#��_���r(3"�2`�8�Y�[.�7�%uf�0���sm�u�-�f�dR5��z� ��86�����0�65��%�b��WG�S�ߞ�?����]����p�M�o�����K�'�������2^�����Z���|�аP�Y�b�a������n�l��+;�6�nuK-�Z�g5���X�j�� y>���u2`ė�)*V�U�l�۷u���y�{��+c�K#pу������8���Ҙ��q�gxO����?.�SC���HA��$�	V��(JX"�a�M{�V�o�K��3Q#�E�9��3�_p8��Ư�L�+�/j��i�e�o*<����:��6S����Hi�'�gߦteA�� 0@��(=L��_�����;w&���@�/��>��V��P��l��dޗ���@h��ߪ�7���7��9X$��ռ��qӋ�6�+���%����})����0H��i�(2���_�~����k�z����#�����/θ�u��%�^���58�,����� )�F f��g�B:���fT�zv�86	s���lw�~��k)c��IG�\��Ӡ�m]XJ�6�� ���@�ݫA�Xh��o�0=�^[#l��z!{�~cy���F��La�脁�r?�@��V eHƀ2֪&��t�3�A��[n��]��)�v�/��O���-�z�3�:qqk�Y�n� �@�ݗ@�V�>C�C���/b��xu`��P��g6��k��䂋��&==X�Gu�t��L��]Mg�X�kSr$����`���>�2C�!�k�Y�^�6�.�>�d�2?���F^���95n�2��Iʟu��N���:e�4o�ɜB��]�$��b�`����%,���8�ɥ!�$��;�ח�*��R�@M������~����p���?@]����Ը�R�48�ru��Э��Y�zʂ���&tk��n8�7�����-o?uU��/kg�]|g��ٻP�N%(g�ֺ#x^.,��̭=�2;��soy$�*2O�����:�4�~�풂��{u/L����wgR��L�Z˾n�����̀���e�R�U��iZ�7�N�fZ�Tب���^��D��Q�<g����������W����[� ��s�@'�U���e�»%�V]���Xe�r:�s�z�:�~'3i���$���t�����z�(N�^��*��i���ɤ�z�t?��#��ID��ySE��3�l�<
Ȩ��0�u�RoD«FTu��ݧ�����ֈK��i�|���(nmO�YM������,$+\D�"tk<%���Zv�н����+՜��x*��#r��z6x+�K�J�2�ǂ-��`O��~=ې��J`|�����>�mY�(`�	�����@������x%�����>[a��41�q�������|W��(^�y�D�}ɨ����ֱ�n���D�o%~��ï�-�d��6�Ri2��*��tbs��!���1�J�Q惢mL��;����3��
ގ�	��O�֏���
��~g4�Tj�X�p����6iO�Nv�g�Nc�~�c[,�����E��wq��h$yƵy�u�K9gF�$��G>�o���G�%��c��L8 7�*�Q�����)=�췟�߄o@2��>��	@�U��	̚
�]��蝰�;r`����̺��D�[�R<�{��VP��V��sCRh*U���E�MI�,虚�w����Z�w��G������/ϟwh�]h��n6t�a0?E* �q��'
H���d���HB�O��: ��<~D�xT-�]R�ZL}Cd/%�,�K/I�ٺ����EH[<��/6�
*@I⏀�D"hD�w����򷙏Ps+�y��N��S+��zB)��sSo��k�?_����8���4���LH�<J�����Z'q��Ku���Z�g-��%��P��oRw�Iԇ�Z٦���;� ���!��
����r�d�g���^��v�oF|���~]�FP��L�d���e3�)������q�E՘ԇ�ɢ��).�����<����-���!q�Z�7��p�F��)�~]ih=�1q���N��Ů?���T���+s/W:�{�T��?JH��G�w=�$��x��f�5V�)ث�kU���,�#�7)?��`
K���l�`�N�
�����n�z7��]	4���G�D�����8����Y^}#"n�B$`��1^���yH'��z�E �Y�'{������(B�H�+E
�L�2|�l��:o�V�;����6E?�|���5������e�-�e䮷�GB��$�(i��w}�yt��-��lI>{���O\�3�T5��]} O���ӯ�9��=�CiV:! ܰ�oэ��� ���%[���~��e�ͅ�
���y���3p܍%������K�X�6�BnW>#~&���c�m��x�)�~z���NmXT:��k᭝_]�2w��p�����1o�{J�拗ԁ�V0�P ��F��鋼 فIe��c�"�xS��)����f��6fe�fL׮�3Vs��GB�$"�M�'�$p��������O/I	� ���&d�J���Z�a@�[0�n��P��y���зK���,2yR���m�,Fvk'-����w^��$E���R^w�Cy�<Ŋ��^`r�6vم��s|(��.�ؾ���l�tT�gc3υj�+�;=-��̂	o�N��}hwm�;��K�wFc4�=�wO�:ec_��+���_��'^�RPӪ/:9<h�rے8Xe`\>���V�fવ��,��re��䯾��~s�}�{�K_�X��j��}n��2e(1Cu������>_�P����:��Ϻ�T��(1�Q���[ -�����Qt��Q�2�'[W��֎ěZ�D��ٿ�Q�NI�A�-�Ϥ(�i�B�`v�#wd��}q�~S���8K1'����56B�� u�^�n���7Sϣ�� ۅ͓Ɯ֛_���$��,}��e�Ӄ��/�@��	�6�>ر澱j��	ճ��CMo����Y�7���a75�|[�Rk�Ĉ�_���_���z\e-j�UTd�e-��*Ү7/}4X���A����o����&�:ς�d�N��+N���T{�@n���ޑ������^s��i��@N¥Ի��cj��6�J��3�;g����^}/�$	�5	����lH5qnEq�rIَ~�\W/�|MV
�б�T���R�E�@:�ps�z���l����(5qF۠#B�Y��˒p�ȁ��R�5��mN�1��������'���z-��  r\c�Ij3d�槵���3�R J��+\_�
��YF���n��'m\,+�u��Po{$���\�̽h�q�1���$V���TF?���\&��?k���|nQ��=)����ȇ&DI<nQ�4�����Ğ�;��X�:䙔���7��|옔%��������BY���;4�{�P�ZNwǬ�?؏<�[�#���q�tm4�O2V��.+��;��%���~��!���.�̂�!O�(=3��Z�0�	:BG�޸�1\^[�m� ^��r楀��q�i0/��a�����T�I��a��%pj�����t�en��mA��C��]�#�B.�FOm�%��3�2�>�ٛ7�F��i��d�'%�GF����o��ͨ_�,�/�� z��V���e��G��ڟq'hUQ&+�s]̵¯C�ǻ?B���t;>P��:��Q'~�G�����kW2'ϖ�����c쭓+{:���Dg-M�$vX����c��C�,����A8��ː9����:��@Nzh�����}�D�ܜ��� ��& �ѳ��|��l��hi,�Z���R�e�&�_��m�#l�5NxT'���K��g�@=�p��G��ԣ�;�hS���2!������R*6���Rh/Ŋ��j�P��$� ��A+�w��̹\�#����]/M���g�(m�1[�vu<U۵�����͘����9U5 �b���%���١��3��W~|��q�1�U���Q+���J���>�X4}@�Q�Ӌ%�bT���Dg(d��\�&���ɇ�cD=!9s�d��[��lҺ��m�8Q�c�t�dڭA>yd�&�1"4�����DY��7mm��Ia2�Z*j�_N����:������|��~���72$�Z�n�(�iA%
> V_^�����b��ɧZs��
��=�=�Ѫ��C�T�r�-Ŧo��U�̰*+�V�4�iPyf[�ч�f�|y�psmn[l��M�����M�Ry`2AT1���1*7�����]��W$9�P�a>�(��L��5��I�q�>h3�-��n'�ױ���;��}=�2?�a�yP�We%w�T6ux[�cJ.�h�|�F}L�{��6s��t��(ح
�_�ꘚᣐ����cXq���.rwo�Y�&_��Z��3�E�����0�����j����լ�w���w��<_K(Qh�t�Q�u���2X/�|�K��%���a��#g[�>�mn��f4��!����(®�i��0�!���fw����ml骃�eʯgoYO�z�����/�}e��0�%%��:�� ^/�	�K�:��O��T���j�f\����:I���սM�?~��
~��D���=����J���	��<"g�SҾ����A�\o�D�dy?덝rm�Gv���ia{gī��S:�k�_��5HaU���'��I$J��v�
�f�(���s�Sُ#�+�����M���L���r��'l�|����3�)nH�6Z�,1�39�e�"��Ur��𪩇h�l�fVZc��+b�|�9/�B�Q�1�g/���[8��+�'_��hZ��&��/���R#�A�^>a�T�m�kbKu?.�/��KF\���O�ql9��AĢ��"����B����P2��}_�"�f��6��L+���t��HR�n���Ȇ���$Î=��F�.�r;f���i�'�0�#{�#w�K�EvJ`<�<�>���q1�~q��ߥ;9�sT߽�\�C{tN��r����?����{$���.Ӆ�3��l���z��5�2���u��'.�EG�O�P:���y�#�)Ă�B���3�����Ÿ������ȑrL��_CSkXG���F�w6�,��_T.� Z�96��b�����̀H"˂qq&z2'��$(��E�)0���+O9�q���.�\��HL|�ߕ�Nx���ЎwH����K����͆Ç�:]����SDk�Kb����v%޸��j6�QA�
Yo��K_�ղ��l֞�;�ׅ�n�8/���(���N�y~��6d#N����F;���r���J��x4�w��?[2|^�� �L.��SO�������$v�U�b#��QH�`N�R+���u���s�V�����9"��yZp��U���l�s�o��t|���.�:.��|yc��o[�W�K�����84��:�M�4jRj��+s<����mMdC��4��z��NԮ�N'~71ז2�s����6�f�R��|�NH�r<�5�1u����q���%X���¸ڭ)�d��#xX��tv�ǡw�_!� �aN�:�q���N�S��|����n��K��Z��GC�u�J��WgÔ�'?�z�>7?w���݊�|͉�{�݆W�&���$�'0���J�������yc��(�V9��{��,�LD���E���ݽƣ1=��J�6�e�n-���I�s3x{zqi$Q�X��.���=�u�>��V�O�y��߶��D�m��ws�r�&���AfҦ��ʂyB���7��{�)���@���)R��F�Z�hNKjaH�n4�m	�e��������/��Fa1��g��Ge��4|V���k���e�
�Ն�Ѳk7�����$�=3G�h�d�2��W���������8w]�W��OI�`/ڤ:��Ii�����572��M��4)���1O2�^��w������P 2-���/�Y :�[�C�'���ܴ���g�g]_ �z^��n7)w�A�d�Dg���-:F�b��8	@�d���!xzN[v(�`B����pҠ;
�M��7��0��<���+��7�-k��*F�B�o�brg�D<J�G1EC�9�n�H�Ģ'K���W�E�-���"��jc���dG3=���������4�	�T��!�#�i����TRu���0('����
��:�lV�p]�r��\S�38q�]�v���J$�ޅ΃˽����Nw���UȬڴ���$���8�>I���԰�� ��ZWc_��BӰZ�}Az�>=�{et�����y)v�Zn����i.3��eB�?�B%�g���ζ�ϗ�R˒�?z�Vfb�p�:��J3�YH�S��9�m��eq�9Q���:Sܚ�g�Q�<������PK    �Mh@��\��  �            ��    find.jpgUT dqXOux �  �  PK
     �Mh@��|�E�  E�            ��;  WebServer.stUT dqXOux �  �  PK    �Mh@���4  �            ��Ɗ  edit.jpgUT dqXOux �  �  PK    �Mh@\��A              ��<�  top.jpgUT dqXOux �  �  PK
     �Mh@�v�j�  �            ����  test.stUT dqXOux �  �  PK
     �Mh@SYa�  �            ����  WikiServer.stUT dqXOux �  �  PK    �Mh@���   �            ���f example1.sttUT dqXOux �  �  PK
     4[h@����p  p            ���g package.xmlUT #�XOux �  �  PK
     �Mh@j�k�|^  |^            ���j FileServer.stUT dqXOux �  �  PK    �Mh@m#63  �  
          ��O� rename.jpgUT dqXOux �  �  PK    �Mh@)	ſm  1            ���� help.jpgUT dqXOux �  �  PK    �Mh@:R%�&	  �	  
          ��u� recent.jpgUT dqXOux �  �  PK
     �Mh@^fr��  �            ���� Haiku.stUT dqXOux �  �  PK
     �Mh@(9��#&  #&            ���� STT.stUT dqXOux �  �  PK    �Mh@f�>��  �            ��D next.jpgUT dqXOux �  �  PK    �Mh@¦�`  �  	         ��U ChangeLogUT dqXOux �  �  PK    �Mh@eR��   U           ��� example2.sttUT dqXOux �  �  PK    �Mh@����  >            �� history.jpgUT dqXOux �  �  PK    �Mh@Aiw��  \            ���  prev.jpgUT dqXOux �  �  PK    �Mh@D]]�#  %            ���( head.jpgUT dqXOux �  �  PK      5  �L   