PK
     �Mh@>5�e6  e6    SocketAddress.stUT	 eqXO׊XOux �  �  "======================================================================
|
|   Smalltalk sockets - SocketAddress class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008, 2009 Free Software Foundation, Inc.
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



Object subclass: SocketAddress [
    | name |
    
    <category: 'Sockets-Protocols'>
    <comment: '
This class is the abstract class for machine addresses over a network.
It also fulfills the function of the C style functions gethostname(),
gethostbyname(), and gethostbyaddr(), resolves machine names into their
corresponding numeric addresses (via DNS, /etc/hosts, or other mechanisms)
and vice versa.'>

    SocketAddress class [
	| anyLocalAddress loopbackHost unknownAddress defaultStreamSocketImplClass defaultDatagramSocketImplClass defaultRawSocketImplClass |
	
    ]

    Cache := nil.
    LocalHostName := nil.

    SocketAddress class >> defaultStreamSocketImplClass [
	"Answer the class that, by default, is used to map between the
	 Socket's protocol and a low-level C interface."

	<category: 'accessing'>
	^defaultStreamSocketImplClass ifNil: [ SocketImpl ]
    ]

    SocketAddress class >> defaultStreamSocketImplClass: aClass [
	"Set which class will be used by default to map between the
	 receiver's protocol and a low-level C interface."

	<category: 'accessing'>
	defaultStreamSocketImplClass := aClass
    ]

    SocketAddress class >> defaultRawSocketImplClass [
	"Answer the class that, by default, is used to map between the
	 Socket's protocol and a low-level C interface."

	<category: 'accessing'>
	^defaultRawSocketImplClass ifNil: [ RawSocketImpl ]
    ]

    SocketAddress class >> defaultRawSocketImplClass: aClass [
	"Set which class will be used by default to map between the
	 receiver's protocol and a low-level C interface."

	<category: 'accessing'>
	defaultRawSocketImplClass := aClass
    ]

    SocketAddress class >> defaultDatagramSocketImplClass [
	"Answer the class that, by default, is used to map between the
	 Socket's protocol and a low-level C interface."

	<category: 'accessing'>
	^defaultDatagramSocketImplClass ifNil: [ DatagramSocketImpl ]
    ]

    SocketAddress class >> defaultDatagramSocketImplClass: aClass [
	"Set which class will be used by default to map between the
	 receiver's protocol and a low-level C interface."

	<category: 'accessing'>
	defaultDatagramSocketImplClass := aClass
    ]

    SocketAddress class >> newSocket: socketClass [
        "Answer a new instance of socketClass, using the protocol
         family of the receiver."

        <category: 'private-creating sockets'>
        ^socketClass
            new: (socketClass defaultImplementationClassFor: self)
            addressClass: self
    ]

    SocketAddress class >> newRawSocket [
	"Create a new raw socket, providing access to low-level network protocols
	 and interfaces for the protocol family represented by the receiver
	 (for example, the C protocol family PF_INET for the IPAddress class)
	 Ordinary user programs usually have no need to use this method."

	<category: 'creating sockets'>
	^DatagramSocket new: self defaultRawSocketImplClass addressClass: self
    ]

    SocketAddress class >> initLocalAddresses [
	"Private - Initialize the anyLocalAddress class-instance variable
	 for the entire hierarchy."
	<category: 'initialization'>
	| all |
	"Initialize to the loopback host."
	self withAllSubclassesDo: [ :each | each anyLocalAddress: each loopbackHost].

	"Override with resolved addresses."
	all := self allByName: self localHostName.
	all isNil
	    ifFalse: [all do: [ :each | each class anyLocalAddress: each ]]
    ]

    SocketAddress class >> flush [
	"Flush the cached IP addresses."

	<category: 'initialization'>
	LocalHostName := nil.
	Cache := Dictionary new.
	self withAllSubclassesDo: [:each | each anyLocalAddress: nil ].
    ]

    SocketAddress class >> createUnknownAddress [
	"Answer an object representing an unkown address in the address
	 family for the receiver"

	<category: 'initialization'>
	^Socket defaultAddressClass unknownAddress
    ]

    SocketAddress class >> createLoopbackHost [
	"Answer an object representing the loopback host in the address
	 family for the receiver."

	<category: 'initialization'>
	^Socket defaultAddressClass loopbackHost
    ]

    SocketAddress class >> update: aspect [
	"Flush all the caches for IPAddress subclasses"

	<category: 'initialization'>
	aspect == #returnFromSnapshot ifTrue: [self flush].
    ]

    SocketAddress class >> anyLocalAddress [
	"Answer an IPAddress representing a local address."

	<category: 'accessing'>
	"The local address can be computed with a single lookup for all
	 the classes."
	anyLocalAddress isNil ifTrue: [ SocketAddress initLocalAddresses ].
	^anyLocalAddress
    ]

    SocketAddress class >> anyLocalAddress: anObject [
	"Private - Store an object representing a local address in the address
	 family for the receiver"

	<category: 'initialization'>
	anyLocalAddress := anObject
    ]

    SocketAddress class >> at: host cache: aBlock [
	"Private - Answer the list of addresses associated to the
	 given host in the cache.  If the host is not cached yet,
	 evaluate aBlock and cache and answer the result."

	<category: 'accessing'>
	self == SocketAddress ifFalse: [ ^aBlock value ].

	^Cache at: host ifAbsent: [
	    | result |
	    result := aBlock value.
	    result isNil
		ifTrue: [ nil ]
		ifFalse: [ Cache at: host put: result ] ]
    ]

    SocketAddress class >> aiFlags [
	<category: 'private'>
	^self == SocketAddress ifTrue: [ self aiAddrconfig ] ifFalse: [ 0 ]
    ]

    SocketAddress class >> isDigitAddress: aString [
	"Answer whether the receiver can interpret aString as a valid
	 address without going through a resolver."

	<category: 'accessing'>
	^false
    ]

    SocketAddress class >> localHostName [
	"Answer the name of the local machine."

	<category: 'accessing'>
	LocalHostName isNil ifTrue: [ LocalHostName := self primLocalName ].
	^LocalHostName
    ]

    SocketAddress class >> loopbackHost [
	"Answer an instance of the receiver representing the local machine
	 (127.0.0.1 in the IPv4 family)."

	<category: 'accessing'>
	loopbackHost isNil ifTrue: [ loopbackHost := self createLoopbackHost ].
	loopbackHost name: self localHostName.
	^loopbackHost
    ]

    SocketAddress class >> unknownAddress [
	"Answer an instance of the receiver representing an unknown machine
	 (0.0.0.0 in the IPv4 family)."

	<category: 'accessing'>
	unknownAddress isNil ifTrue: [ unknownAddress := self createUnknownAddress ].
	^unknownAddress
    ]

    SocketAddress class >> allByName: aString [
	"Answer all the IP addresses that refer to the the given host.  If
	 a digit address is passed in aString, the result is an array
	 containing the single passed address.  If the host could not be
	 resolved to an IP address, answer nil."

	<category: 'host name lookup'>
	| host addresses |
	host := aString asLowercase.
	self withAllSubclassesDo: 
		[:c | 
		(c isDigitAddress: host) 
		    ifTrue: [^self at: host cache: [Array with: (c fromString: host)]]].
	addresses := self at: host
	    cache: [ | hints result array |
		hints := CAddrInfoStruct gcNew.
		hints aiFamily value: self protocolFamily.
		hints aiFlags value: (self aiFlags bitOr: self aiCanonname).
		[(result := hints getaddrinfo: host) isNil
                    ifTrue: [nil]
                    ifFalse: [
		        array := self extractAddressesAfterLookup: result.
                        array isEmpty ifTrue: [nil] ifFalse: [array]]]
                    ensure: [result free]].

	^addresses
    ]

    SocketAddress class >> byName: aString [
	"Answer a single IP address that refer to the the given host.  If
	 a digit address is passed in aString, the result is the same as
	 using #fromString:.  If the host could not be resolved to an IP
	 address, answer nil."

	<category: 'host name lookup'>
	| all |
	aString isEmpty ifTrue: [^self loopbackHost].
	all := self allByName: aString.
	all isNil ifTrue: [^nil].
        self == SocketAddress ifFalse: [^all anyOne].
	^all detect: [:each | each isKindOf: Socket defaultAddressClass]
            ifNone: [all anyOne]
    ]

    SocketAddress class >> extractAddressesAfterLookup: aiHead [
	"Private - Given a CByte object, extract the arrays returned by
	 gethostbyname and answer them."

	<category: 'private'>
	| result addrBytes addr ai name |
	result := OrderedCollection new.
	name := aiHead aiCanonname value.
	ai := aiHead.
	[ ai isNil ] whileFalse: [
	    addrBytes := ByteArray fromCData: ai aiAddr value size: ai aiAddrlen value.
	    addr := self
		extractFromSockAddr: addrBytes
		port: NullValueHolder uniqueInstance.
	    addr isNil ifFalse: [
		addr name: name.
		(result includes: addr) ifFalse: [ result add: addr ] ].
	    ai := ai aiNext value ].
	^result
    ]

    SocketAddress class >> extractFromSockAddr: aByteArray port: portAdaptor [
	"Private - Answer a new SocketAddress from a ByteArray containing a
	 C sockaddr structure.  The portAdaptor's value is changed
	 to contain the port that the structure refers to."

	<category: 'abstract'>
	| addressFamily |
	"BSD systems place a length byte at offset 1, so look-up offset 2
	 first.  If it is 0, we're on a little-endian system without
	 the sa_len field, so use offset 1 as a second possibility."
	addressFamily := aByteArray at: 2.
	addressFamily = 0 ifTrue: [ addressFamily := aByteArray at: 1 ].

	self allSubclassesDo: [ :each |
	    each addressFamily = addressFamily ifTrue: [
		^each fromSockAddr: aByteArray port: portAdaptor ] ].

	^nil
    ]

    SocketAddress class >> fromSockAddr: aByteArray port: portAdaptor [
	"Private - Answer a new IPAddress from a ByteArray containing a
	 C sockaddr structure.  The portAdaptor's value is changed
	 to contain the port that the structure refers to.  Raise an error
	 if the address family is unknown."

	<category: 'abstract'>
	^(self extractFromSockAddr: aByteArray port: portAdaptor)
	    ifNil: [ self error: 'unknown address family' ]
    ]

    = aSocketAddress [
	"Answer whether the receiver and aSocketAddress represent
	 the same machine.  The host name is not checked because
	 an IPAddress created before a DNS is activated is named
	 after its numbers-and-dots notation, while the same IPAddress,
	 created when a DNS is active, is named after its resolved name."

	<category: 'accessing'>
	^self class == aSocketAddress class 
	    and: [self asByteArray = aSocketAddress asByteArray]
    ]

    isMulticast [
	"Answer whether an address is reserved for multicast connections."

	<category: 'testing'>
	^false
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'accessing'>
	^self asByteArray hash
    ]

    name [
	"Answer the host name (or the digit notation if the DNS could not
	 resolve the address).  If the DNS answers a different IP address
	 for the same name, the second response is not cached and the digit
	 notation is also returned (somebody's likely playing strange jokes
	 with your DNS)."

	<category: 'accessing'>
	| addresses bytes |
	name isNil ifFalse: [^name].
	bytes := self asByteArray.
	name := self class 
		    primName: bytes
		    len: bytes size
		    type: self class addressFamily.

	"No DNS active..."
	name isNil ifTrue: [^name := self printString].
	addresses := self class at: name cache: [Array with: self].
	addresses do: 
		[:each | 
		each getName isNil ifTrue: [each name: name].
		(each = self and: [each getName ~= name]) 
		    ifTrue: 
			["Seems like someone's joking with the DNS server
			 and changed this host's IP address even though the
			 name stays the same. Don't cache the name and don't
			 even give away an alphanumeric name"

			^name := self printString]].
	^name
    ]

    asByteArray [
	"Convert the receiver to a ByteArray passed to the operating system's
	 socket functions)"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    getName [
	"Private - Answer the name (which could be nil if the name has not
	 been cached yet)."

	<category: 'private'>
	^name
    ]

    name: newName [
	"Private - Cache the name of the host which the receiver represents."

	<category: 'private'>
	name := newName
    ]
]



CStruct subclass: CAddrInfoStruct [
    <declaration: #(
		#(#aiFlags #int)
		#(#aiFamily #int)
		#(#aiSocktype #int)
		#(#aiProtocol #int)
		#(#aiAddrlen #int)
		#(#aiCanonname #string)
		#(#aiAddr #(#ptr #{CObject}))
		#(#aiNext #(#ptr #{CAddrInfoStruct}))) >

    getaddrinfo: name [
	<category: 'C function wrappers'>
	^self getaddrinfo: name service: nil
    ]

    getaddrinfo: name service: service [
	<category: 'C function wrappers'>
	| res |
	res := self class address: 0.
	(CAddrInfoStruct getaddrinfo: name service: service
	    hints: self result: res) = -1 ifTrue: [ ^nil ].
	res address = 0 ifTrue: [ ^nil ].
	^res
    ]
]

PK
     �Mh@�k�K!  K!  	  cfuncs.stUT	 eqXO׊XOux �  �  SocketAddress class extend [

    addressFamily [
	<category: 'C constants'>
	<cCall: 'TCPafUnspec' returning: #long args: #()>
	
    ]

    protocolFamily [
	<category: 'C constants'>
	<cCall: 'TCPpfUnspec' returning: #long args: #()>
	
    ]

    aiAddrconfig [
	<category: 'C constants'>
	<cCall: 'TCPaiAddrconfig' returning: #long args: #()>
	
    ]

    aiCanonname [
	<category: 'C constants'>
	<cCall: 'TCPaiCanonname' returning: #long args: #()>
	
    ]

]

IPAddress class extend [

    addressFamily [
	<category: 'C constants'>
	<cCall: 'TCPafInet' returning: #long args: #()>
	
    ]

    protocolFamily [
	<category: 'C constants'>
	<cCall: 'TCPpfInet' returning: #long args: #()>
	
    ]

]

IP6Address class extend [

    addressFamily [
	<category: 'C constants'>
	<cCall: 'TCPafInet6' returning: #long args: #()>
	
    ]

    protocolFamily [
	<category: 'C constants'>
	<cCall: 'TCPpfInet6' returning: #long args: #()>
	
    ]

    aiAll [
	<category: 'C constants'>
	<cCall: 'TCPaiAll' returning: #long args: #()>
	
    ]

    aiV4mapped [
	<category: 'C constants'>
	<cCall: 'TCPaiV4mapped' returning: #long args: #()>
	
    ]

]

UnixAddress class extend [

    addressFamily [
	<category: 'C constants'>
	<cCall: 'TCPafUnix' returning: #long args: #()>
	
    ]

    protocolFamily [
	<category: 'C constants'>
	<cCall: 'TCPpfUnix' returning: #long args: #()>
	
    ]

]



AbstractSocketImpl class extend [

    solSocket [
	<category: 'C constants'>
	<cCall: 'TCPsolSocket' returning: #long args: #()>
	
    ]

    soLinger [
	<category: 'C constants'>
	<cCall: 'TCPsoLinger' returning: #long args: #()>
	
    ]

    soReuseAddr [
	<category: 'C constants'>
	<cCall: 'TCPsoReuseAddr' returning: #long args: #()>
	
    ]

    sockDgram [
	<category: 'C constants'>
	<cCall: 'TCPsockDgram' returning: #long args: #()>
	
    ]

    sockStream [
	<category: 'C constants'>
	<cCall: 'TCPsockStream' returning: #long args: #()>
	
    ]

    sockRDM [
	<category: 'C constants'>
	<cCall: 'TCPsockRDM' returning: #long args: #()>
	
    ]

    sockRaw [
	<category: 'C constants'>
	<cCall: 'TCPsockRaw' returning: #long args: #()>
	
    ]

]


UDPSocketImpl class extend [

    ipprotoIp [
	<category: 'C constants'>
	<cCall: 'TCPipprotoIp' returning: #long args: #()>
	
    ]

    protocol [
	<category: 'C constants'>
	<cCall: 'TCPipprotoUdp' returning: #long args: #()>
	
    ]

]



TCPSocketImpl class extend [

    protocol [
	<category: 'C constants'>
	<cCall: 'TCPipprotoTcp' returning: #long args: #()>
	
    ]

    ipprotoTcp [
	<category: 'C constants'>
	<cCall: 'TCPipprotoTcp' returning: #long args: #()>
	
    ]

    tcpNodelay [
	<category: 'C constants'>
	<cCall: 'TCPtcpNodelay' returning: #long args: #()>
	
    ]

]



ICMP6SocketImpl class extend [

    protocol [
	<category: 'C constants'>
	<cCall: 'TCPipprotoIcmpv6' returning: #long args: #()>
	
    ]

]



ICMPSocketImpl class extend [

    protocol [
	<category: 'C constants'>
	<cCall: 'TCPipprotoIcmp' returning: #long args: #()>
	
    ]

]



OOBSocketImpl extend [

    msgOOB [
	<category: 'C constants'>
	<cCall: 'TCPmsgOOB' returning: #long args: #()>
	
    ]

]



DatagramSocketImpl extend [

    msgPeek [
	<category: 'C constants'>
	<cCall: 'TCPmsgPeek' returning: #long args: #()>
	
    ]

    ipMulticastTtl [
	<category: 'C constants'>
	<cCall: 'TCPipMulticastTtl' returning: #long args: #()>
	
    ]

    ipMulticastIf [
	<category: 'C constants'>
	<cCall: 'TCPipMulticastIf' returning: #long args: #()>
	
    ]

    ipAddMembership [
	<category: 'C constants'>
	<cCall: 'TCPipAddMembership' returning: #long args: #()>
	
    ]

    ipDropMembership [
	<category: 'C constants'>
	<cCall: 'TCPipDropMembership' returning: #long args: #()>
	
    ]

]



CAddrInfoStruct extend [
    free [
	<category: 'C call-outs'>
	<cCall: 'TCPfreeaddrinfo' returning: #void
	args: #(#self)>
	
    ]

    CAddrInfoStruct class >> getaddrinfo: name service: servname hints: hints result: res [
	<category: 'C call-outs'>
	<cCall: 'TCPgetaddrinfo' returning: #int
	args: #(#string #string #cObject #cObjectPtr)>
	
    ]

    aiAddr [
	<category: 'C call-outs'>
	<cCall: 'TCPgetAiAddr' returning: #(#ptr #{CObject})
	args: #(#self)>
	
    ]

    aiCanonname [
	<category: 'C call-outs'>
	<cCall: 'TCPgetAiCanonname' returning: #{CString}
	args: #(#self)>
	
    ]
]

SocketAddress class extend [

    primName: address len: len type: addressFamily [
	<category: 'C call-outs'>
	<cCall: 'TCPgetHostByAddr' returning: #stringOut
	args: #(#cObject #int #int)>
	
    ]

    primLocalName [
	<category: 'C call-outs'>
	<cCall: 'TCPgetLocalName' returning: #stringOut
	args: #()>
	
    ]

]



AbstractSocketImpl extend [

    accept: socket peer: peer addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPaccept' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    bind: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPbind' returning: #int
	args: #(#int #cObject #int )>
	
    ]

    connect: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPconnect' returning: #int
	args: #(#int #cObject #int )>
	
    ]

    listen: socket log: len [
	<category: 'C call-outs'>
	<cCall: 'TCPlisten' returning: #int
	args: #(#int #int )>
	
    ]

    getPeerName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetpeername' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    getSockName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockname' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    receive: socket buffer: buf size: len flags: flags from: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPrecvfrom' returning: #int
	args: #(#int #cObject #int #int #cObject #cObject )>
	
    ]

    send: socket buffer: buf size: len flags: flags to: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPsendto' returning: #int
	args: #(#int #cObject #int #int #cObject #int )>
	
    ]

    soError: socket [
	<category: 'C constants'>
	<cCall: 'TCPgetSoError' returning: #int args: #(#int)>
	
    ]

    option: socket level: level at: name put: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPsetsockopt' returning: #int
	args: #(#int #int #int #cObject #int )>
	
    ]

    option: socket level: level at: name get: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockopt' returning: #int
	args: #(#int #int #int #cObject #cObject )>
	
    ]

    create: family type: type protocol: protocol [
	<category: 'C call-outs'>
	<cCall: 'TCPsocket' returning: #int
	args: #(#int #int #int )>
	
    ]

]



AbstractSocketImpl class extend [

    accept: socket peer: peer addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPaccept' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    bind: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPbind' returning: #int
	args: #(#int #cObject #int )>
	
    ]

    connect: socket to: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPconnect' returning: #int
	args: #(#int #cObject #int )>
	
    ]

    listen: socket log: len [
	<category: 'C call-outs'>
	<cCall: 'TCPlisten' returning: #int
	args: #(#int #int )>
	
    ]

    getPeerName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetpeername' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    getSockName: socket addr: addr addrLen: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockname' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    receive: socket buffer: buf size: len flags: flags from: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPrecvfrom' returning: #int
	args: #(#int #cObject #int #int #cObject #cObject )>
	
    ]

    send: socket buffer: buf size: len flags: flags to: addr size: addrLen [
	<category: 'C call-outs'>
	<cCall: 'TCPsendto' returning: #int
	args: #(#int #cObject #int #int #cObject #int )>
	
    ]

    option: socket level: level at: name put: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPsetsockopt' returning: #int
	args: #(#int #int #int #cObject #int )>
	
    ]

    option: socket level: level at: name get: value size: len [
	<category: 'C call-outs'>
	<cCall: 'TCPgetsockopt' returning: #int
	args: #(#int #int #int #cObject #cObject )>
	
    ]

    create: family type: type protocol: protocol [
	<category: 'C call-outs'>
	<cCall: 'TCPsocket' returning: #int
	args: #(#int #int #int )>
	
    ]

]

PK
     �Mh@ F�?˖  ˖  
  Sockets.stUT	 eqXO׊XOux �  �  "======================================================================
|
|   Smalltalk sockets - Stream hierarchy
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2005, 2006, 2008, 2009 Free Software Foundation, Inc.
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



Stream subclass: AbstractSocket [
    | impl |
    
    <category: 'Sockets-Streams'>
    <comment: '
This class models a client site socket.  A socket is a TCP/IP endpoint
for network communications conceptually similar to a file handle.

This class only takes care of buffering and blocking if requested.
It uses an underlying socket implementation object which is
a subclass of AbstractSocketImpl.  This is necessary to hide
some methods in FileDescriptor that are not relevant to sockets,
as well as to implement buffering independently of the implementation
nuances required by the different address families.  The address
family class (a subclass of SocketAddress) acts as a factory for socket
implementation objects.'>

    CheckPeriod := nil.
    Timeout := nil.
    DefaultAddressClass := nil.

    Ports := nil.

    AbstractSocket class >> defaultPortAt: protocol [
	"Answer the port that is used (by default) for the given service (high
	 level protocol)"

	<category: 'well known ports'>
	^Ports at: protocol
    ]

    AbstractSocket class >> defaultPortAt: protocol ifAbsent: port [
	"Answer the port that is used (by default) for the given service (high
	 level protocol), or the specified port if none is registered."

	<category: 'well known ports'>
	^Ports at: protocol ifAbsent: port
    ]

    AbstractSocket class >> defaultPortAt: protocol put: port [
	"Associate the given port to the service specified by `protocol'."

	<category: 'well known ports'>
	^Ports at: protocol put: port
    ]

    AbstractSocket class >> initialize [
	self
	    timeout: 30000;
	    checkPeriod: 100;
	    defaultAddressClass: IPAddress.
	Ports := (Dictionary new)
		    at: 'ftp' put: 21;
		    at: 'telnet' put: 23;
		    at: 'smtp' put: 25;
		    at: 'dns' put: 42;
		    at: 'whois' put: 43;
		    at: 'finger' put: 79;
		    at: 'http' put: 80;
		    at: 'pop3' put: 110;
		    at: 'nntp' put: 119;
		    yourself
    ]

    AbstractSocket class >> portEcho [
	"Answer the port on which the ECHO service listens"

	<category: 'well known ports'>
	^7
    ]

    AbstractSocket class >> portDiscard [
	"Answer the port on which the DISCARD service listens"

	<category: 'well known ports'>
	^9
    ]

    AbstractSocket class >> portSystat [
	"Answer the port on which the SYSTAT service listens"

	<category: 'well known ports'>
	^11
    ]

    AbstractSocket class >> portDayTime [
	"Answer the port on which the TOD service listens"

	<category: 'well known ports'>
	^13
    ]

    AbstractSocket class >> portNetStat [
	"Answer the port on which the NETSTAT service listens"

	<category: 'well known ports'>
	^15
    ]

    AbstractSocket class >> portFTP [
	"Answer the port on which the FTP daemon listens"

	<category: 'well known ports'>
	^21
    ]

    AbstractSocket class >> portSSH [
	"Answer the port on which the SSH daemon listens"

	<category: 'well known ports'>
	^22
    ]

    AbstractSocket class >> portTelnet [
	"Answer the port on which the TELNET daemon listens"

	<category: 'well known ports'>
	^23
    ]

    AbstractSocket class >> portSMTP [
	"Answer the port on which the SMTP daemon listens"

	<category: 'well known ports'>
	^25
    ]

    AbstractSocket class >> portTimeServer [
	"Answer the port on which the time server listens"

	<category: 'well known ports'>
	^37
    ]

    AbstractSocket class >> portDNS [
	"Answer the port on which the DNS listens"

	<category: 'well known ports'>
	^53
    ]

    AbstractSocket class >> portWhois [
	"Answer the port on which the WHOIS daemon listens"

	<category: 'well known ports'>
	^43
    ]

    AbstractSocket class >> portGopher [
	"Answer the port on which the Gopher daemon listens"

	<category: 'well known ports'>
	^70
    ]

    AbstractSocket class >> portFinger [
	"Answer the port on which the finger daemon listens"

	<category: 'well known ports'>
	^79
    ]

    AbstractSocket class >> portHTTP [
	"Answer the port on which the http daemon listens"

	<category: 'well known ports'>
	^80
    ]

    AbstractSocket class >> portPOP3 [
	"Answer the port on which the pop3 daemon listens"

	<category: 'well known ports'>
	^110
    ]

    AbstractSocket class >> portNNTP [
	"Answer the port on which the nntp daemon listens"

	<category: 'well known ports'>
	^119
    ]

    AbstractSocket class >> portExecServer [
	"Answer the port on which the exec server listens"

	<category: 'well known ports'>
	^512
    ]

    AbstractSocket class >> portLoginServer [
	"Answer the port on which the rlogin daemon listens"

	<category: 'well known ports'>
	^513
    ]

    AbstractSocket class >> portCmdServer [
	"Answer the port on which the rsh daemon listens"

	<category: 'well known ports'>
	^514
    ]

    AbstractSocket class >> portReserved [
	"Answer the last port reserved to privileged processes"

	<category: 'well known ports'>
	^1023
    ]

    AbstractSocket class >> checkPeriod [
	"Answer the period that is to elapse between socket polls if data
	 data is not ready and the connection is still open (in milliseconds)"

	<category: 'timed-out operations'>
	^CheckPeriod
    ]

    AbstractSocket class >> checkPeriod: anInteger [
	"Set the period that is to elapse between socket polls if data
	 data is not ready and the connection is still open (in milliseconds)"

	<category: 'timed-out operations'>
	CheckPeriod := anInteger truncated
    ]

    AbstractSocket class >> timeout [
	"Answer the period that is to elapse between the request for (yet
	 unavailable) data and the moment when the connection is considered dead
	 (in milliseconds)"

	<category: 'timed-out operations'>
	^Timeout
    ]

    AbstractSocket class >> timeout: anInteger [
	"Set the period that is to elapse between the request for (yet
	 unavailable) data and the moment when the connection is considered
	 dead (in milliseconds)"

	<category: 'timed-out operations'>
	Timeout := anInteger truncated
    ]

    AbstractSocket class >> defaultImplementationClassFor: aSocketAddressClass [
	"Answer the default implementation class.  Depending on the
	 subclass, this might be the default stream socket implementation
	 class of the given address class, or rather its default datagram
	 socket implementation class."

	<category: 'defaults'>
	self subclassResponsibility
    ]

    AbstractSocket class >> defaultAddressClass [
	"Answer the default address family to be used.  In the library,
	 the address family is represented by a subclass of SocketAddress
	 which is by default IPAddress."

	<category: 'defaults'>
	^DefaultAddressClass
    ]

    AbstractSocket class >> defaultAddressClass: class [
	"Set the default address family to be used.  In the library,
	 the address family is represented by a subclass of SocketAddress
	 which is by default IPAddress."

	<category: 'defaults'>
	DefaultAddressClass := class
    ]

    AbstractSocket class >> resolveAddress: ipAddressOrString [
	| addr |

	ipAddressOrString isString 
	    ifTrue: [
		addr := SocketAddress byName: ipAddressOrString.
		addr isNil 
		    ifTrue: 
			[self error: 'cannot resolve host name ' , ipAddressOrString printString]]
	    ifFalse: [addr := ipAddressOrString].

	^ addr
    ]

    AbstractSocket class >> new: implementation [
	"Answer a new instance of the receiver, using as the underlying
	 layer the object passed as the `implementation' parameter; the
	 object is probably going to be some kind of AbstractSocketImpl."

	<category: 'instance creation'>
	^super new initialize: implementation
    ]

    AbstractSocket class >> new: implClass addressClass: addressClass [
	"Answer a new instance of the receiver, using as the underlying
	 layer a new instance of `implementationClass' and using the
	 protocol family of `addressClass'."

	<category: 'instance creation'>
	^self new: (implClass newFor: addressClass)
    ]

    AbstractSocket class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    soLinger [
	"Answer the number of seconds that the socket is allowed to wait
	 if it promises reliable delivery but has unacknowledged/untransmitted
	 packets when it is closed, or nil if those packets are left to their
	 destiny or discarded."

	<category: 'socket options'>
	^self implementation soLinger
    ]

    soLinger: linger [
	"Set the number of seconds that the socket is allowed to wait
	 if it promises reliable delivery but has unacknowledged/untransmitted
	 packets when it is closed."

	<category: 'socket options'>
	^self implementation soLinger: linger
    ]

    soLingerOff [
	"Specify that, even if the socket promises reliable delivery, any
	 packets that are unacknowledged/untransmitted when it is closed
	 are to be left to their destiny or discarded."

	<category: 'socket options'>
	^self implementation soLinger: nil
    ]

    species [
	<category: 'socket options'>
	^String
    ]

    address [
	"Answer an IP address that is of common interest (this can be either
	 the local or the remote address, according to the definition in the
	 subclass)."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    ensureWriteable [
	"Suspend the current process until more data can be written on the
	 socket."

	self implementation ensureWriteable
    ]

    ensureReadable [
	"Suspend the current process until more data is available on the
	 socket."

	self implementation ensureReadable
    ]

    isPeerAlive [
	"Answer whether the connection with the peer remote machine is still
	 valid."

	<category: 'accessing'>
	^self implementation isOpen
    ]
	
    available [
	"Answer whether there is data available on the socket.  Same as
	 #canRead, present for backwards compatibility."

	<category: 'accessing'>
	^self canRead
    ]

    canRead [
	"Answer whether there is data available on the socket."

	<category: 'accessing'>
	^self implementation canRead
    ]

    canWrite [
	"Answer whether there is free space in the socket's write buffer."

	<category: 'accessing'>
	^self implementation canWrite
    ]

    close [
	"Close the socket represented by the receiver."

	<category: 'accessing'>
	self flush.
	self implementation close
    ]

    flush [
	"Flush any buffers used by the receiver."

	<category: 'accessing'>
	
    ]

    isOpen [
	"Answer whether the connection between the receiver and the remote
	 endpoint is still alive."

	<category: 'accessing'>
	self implementation isNil ifTrue: [^false].
	^self implementation isOpen
    ]

    localAddress [
	"Answer the local IP address of the socket."

	<category: 'accessing'>
	self implementation isNil ifTrue: [self error: 'socket not connected'].
	^self implementation localAddress
    ]

    localPort [
	"Answer the local IP port of the socket."

	<category: 'accessing'>
	self implementation isNil ifTrue: [self error: 'socket not connected'].
	^self implementation localPort
    ]

    port [
	"Answer an IP port that is of common interest (this can be the port for
	 either the local or remote endpoint, according to the definitions in the
	 subclass"

	<category: 'accessing'>
	self subclassResponsibility
    ]

    remoteAddress [
	"Answer the IP address of the socket's remote endpoint."

	<category: 'accessing'>
	self implementation isNil ifTrue: [self error: 'socket not connected'].
	^self implementation remoteAddress
    ]

    remotePort [
	"Answer the IP port of the socket's remote endpoint."

	<category: 'accessing'>
	self implementation isNil ifTrue: [self error: 'socket not connected'].
	^self implementation remotePort
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream
	    print: self class;
	    nextPut: $[;
	    print: self address;
	    nextPut: $:;
	    print: self port;
	    nextPutAll: ']'
    ]

    implementation [
	<category: 'private'>
	^impl
    ]

    initialize: implementation [
	<category: 'private'>
	impl := implementation
    ]

    waitUntil: aBlock then: resultBlock onTimeoutDo: timeoutBlock [
	<category: 'private'>
	Timeout // CheckPeriod timesRepeat: 
		[aBlock value ifTrue: [^resultBlock value].
		(Delay forMilliseconds: CheckPeriod) wait].
	^timeoutBlock value
    ]

    atEnd [
	"By default, answer whether the connection is still open."

	<category: 'stream protocol'>
	^self isOpen
    ]

    next [
	"Read another character from the socket, failing if the connection is
	 dead."

	<category: 'stream protocol'>
	^self implementation next
    ]

    next: n putAll: aCollection startingAt: pos [
	"Write `char' to the socket, failing if the connection is dead.  The
	 SIGPIPE signal is automatically caught and ignored by the system."

	<category: 'stream protocol'>
	^self implementation next: n putAll: aCollection startingAt: pos
    ]

    nextPut: char [
	"Write `char' to the socket, failing if the connection is dead.  The
	 SIGPIPE signal is automatically caught and ignored by the system."

	<category: 'stream protocol'>
	^self implementation nextPut: char
    ]

    isExternalStream [
	"Answer whether the receiver streams on a file or socket."

	<category: 'testing'>
	^true
    ]
]



AbstractSocket subclass: DatagramSocket [
    
    <category: 'Sockets-Streams'>
    <comment: '
This class models a connectionless datagram socket that sends
individual packets of data across the network.  In the TCP/IP world,
this means UDP.  Datagram packets do not have guaranteed delivery,
or any guarantee about the order the data will be received on the
remote host.

This class uses an underlying socket implementation object which is
a subclass of DatagramSocketImpl.  This is less necessary for
datagram sockets than for stream sockets (except for hiding some
methods in FileDescriptor that are not relevant to sockets),
but it is done for cleanliness and symmetry.'>

    DefaultBufferSize := nil.

    DatagramSocket class >> defaultImplementationClassFor: aSocketAddressClass [
	"Answer the default implementation class.  Depending on the
	 subclass, this might be the default stream socket implementation
	 class of the given address class, or rather its default datagram
	 socket implementation class."

	<category: 'accessing'>
	^aSocketAddressClass defaultDatagramSocketImplClass
    ]

    DatagramSocket class >> defaultBufferSize [
	"Answer the default maximum size for input datagrams."

	<category: 'accessing'>
	^DefaultBufferSize
    ]

    DatagramSocket class >> defaultBufferSize: size [
	"Set the default maximum size for input datagrams."

	<category: 'accessing'>
	DefaultBufferSize := size
    ]

    DatagramSocket class >> initialize [
	"Initialize the class to use an input datagram size of 128."

	<category: 'initialization'>
	DatagramSocket defaultBufferSize: 128
    ]

    DatagramSocket class >> new [
	"Answer a new datagram socket (by default an UDP socket), without
	 a specified local address and port."

	<category: 'instance creation'>
	^self local: nil port: 0
    ]

    DatagramSocket class >> port: localPort [
	"Create a new socket and bind it to the local host on the given port."

	<category: 'instance creation'>
	^self 
	    remote: nil
	    port: 0
	    local: nil
	    port: localPort
    ]

    DatagramSocket class >> local: ipAddressOrString port: remotePort [
	"Create a new socket and bind it to the given host (passed as a
	 String to be resolved or as an IPAddress), on the given port."

	<category: 'instance creation'>
	^self 
	    remote: nil
	    port: 0
	    local: ipAddressOrString
	    port: remotePort
    ]

    DatagramSocket class >> remote: ipAddressOrString port: remotePort local: ipAddress port: localPort [
	"Create a new socket and bind it to the given host (passed as a
	 String to be resolved or as a SocketAddress), and to the given remotePort.
	 The default destination for the datagrams will be ipAddressOrString
	 (if not nil), on the remotePort port."

	<category: 'instance creation'>
	| localAddr remoteAddr addressClass |
	remoteAddr := self resolveAddress: ipAddressOrString.
	localAddr := self resolveAddress: ipAddress.
	addressClass := remoteAddr isNil 
		    ifTrue: [self defaultAddressClass]
		    ifFalse: [remoteAddr class].
	addressClass := localAddr isNil
		    ifTrue: [addressClass]
		    ifFalse: [localAddr class].
	localAddr isNil ifTrue: [localAddr := addressClass anyLocalAddress].
	^(addressClass newSocket: self)
	    remote: remoteAddr
	    port: remotePort
	    local: localAddr
	    port: localPort
    ]

    address [
	"Answer the local address."

	<category: 'accessing'>
	^self localAddress
    ]

    bufferSize [
	"Answer the size of the buffer in which datagrams are stored."

	<category: 'accessing'>
	^self implementation bufferSize
    ]

    bufferSize: size [
	"Set the size of the buffer in which datagrams are stored."

	<category: 'accessing'>
	self implementation bufferSize: size
    ]

    datagramClass [
	"Answer the class used by the socket to return datagrams."

	<category: 'accessing'>
	^self implementation class datagramClass
    ]

    next [
	"Read a datagram on the socket and answer it."

	<category: 'accessing'>
	^self 
	    waitUntil: [self implementation canRead]
	    then: [self implementation next]
	    onTimeoutDo: [nil]
    ]

    nextPut: aDatagram [
	"Send the given datagram on the socket."

	<category: 'accessing'>
	self 
	    waitUntil: [self implementation canWrite]
	    then: 
		[self implementation nextPut: aDatagram.
		aDatagram]
	    onTimeoutDo: [nil]
    ]

    port [
	"Answer the local port."

	<category: 'accessing'>
	^self localPort
    ]

    peek [
	"Peek for a datagram on the socket and answer it."

	<category: 'accessing'>
	^self 
	    waitUntil: [self implementation canRead]
	    then: [self implementation peek]
	    onTimeoutDo: [nil]
    ]

    peek: datagram [
	"Peek for a datagram on the socket, store it in `datagram', and
	 answer the datagram itself."

	<category: 'accessing'>
	^self 
	    waitUntil: [self implementation canRead]
	    then: 
		[self implementation peek: datagram.
		true]
	    onTimeoutDo: [false]
    ]

    receive: datagram [
	"Read a datagram from the socket, store it in `datagram', and
	 answer the datagram itself."

	<category: 'accessing'>
	^self 
	    waitUntil: [self implementation canRead]
	    then: 
		[self implementation receive: datagram.
		true]
	    onTimeoutDo: [false]
    ]

    nextFrom: ipAddress port: port [
	"Answer the next datagram from the given address and port."

	<category: 'direct operations'>
	self 
	    waitUntil: [self implementation canRead]
	    then: [self implementation nextFrom: ipAddress port: port]
	    onTimeoutDo: [nil]
    ]

    remote: remoteAddress port: remotePort local: ipAddress port: localPort [
	"Private - Set the local endpoint of the socket and the default
	 address to which datagrams are sent."

	<category: 'private'>
	(self implementation)
	    soReuseAddr: 1;
	    bufferSize: self class defaultBufferSize;
	    connectTo: remoteAddress port: remotePort;
	    bindTo: ipAddress port: localPort
    ]
]



DatagramSocket subclass: MulticastSocket [
    
    <category: 'Sockets-Streams'>
    <comment: '
This class models a multicast socket that sends packets to a multicast
group.  All members of the group listening on that address and port will
receive all the messages sent to the group.

In the TCP/IP world, these sockets are UDP-based and a multicast group
consists of a multicast address (a class D internet address, i.e. one
whose most significant bits are 1110), and a well known port number.'>

    interface [
	"Answer the local device supporting the multicast socket.  This
	 is usually set to any local address."

	<category: 'instance creation'>
	^self implementation ipMulticastIf
    ]

    interface: ipAddress [
	"Set the local device supporting the multicast socket.  This
	 is usually set to any local address."

	<category: 'instance creation'>
	self implementation ipMulticastIf: ipAddress
    ]

    join: ipAddress [
	"Join the multicast socket at the given IP address"

	<category: 'instance creation'>
	self implementation join: ipAddress
    ]

    leave: ipAddress [
	"Leave the multicast socket at the given IP address"

	<category: 'instance creation'>
	self implementation leave: ipAddress
    ]

    nextPut: packet timeToLive: timeToLive [
	"Send the datagram with a specific TTL (time-to-live)"

	<category: 'instance creation'>
	| oldTTL |
	oldTTL := self implementation timeToLive.
	self implementation timeToLive: timeToLive.
	self nextPut: packet.
	self implementation timeToLive: oldTTL
    ]

    timeToLive [
	"Answer the socket's datagrams' default time-to-live"

	<category: 'instance creation'>
	^self implementation timeToLive
    ]

    timeToLive: newTTL [
	"Set the default time-to-live for the socket's datagrams"

	<category: 'instance creation'>
	self implementation timeToLive: newTTL
    ]
]



AbstractSocket subclass: ServerSocket [
    
    <category: 'Sockets-Streams'>
    <comment: '
This class models server side sockets.  The basic model is that the
server socket is created and bound to some well known port.  It then
listens for and accepts connections.  At that point the client and
server sockets are ready to communicate with one another utilizing
whatever application layer protocol they desire.

As with the other AbstractSocket subclasses, most instance methods of
this class simply redirect their calls to an implementation class.'>

    ServerSocket class >> defaultImplementationClassFor: aSocketAddressClass [
	"Answer the default implementation class."

	<category: 'accessing'>
	^aSocketAddressClass defaultStreamSocketImplClass
    ]

    ServerSocket class >> defaultQueueSize [
	"Answer the default length of the queue for pending connections.  When
	 the queue fills, new clients attempting to connect fail until the server
	 has sent #accept to accept a connection from the queue."

	<category: 'instance creation'>
	^5
    ]

    ServerSocket class >> queueSize: backlog [
	"Answer a new ServerSocket serving on any local address and port, with a
	 pending connections queue of the given length."

	<category: 'instance creation'>
	^self 
	    port: 0
	    queueSize: backlog
	    bindTo: nil
    ]

    ServerSocket class >> queueSize: backlog bindTo: ipAddress [
	"Answer a new ServerSocket serving on the given local address,
	 and on any port, with a pending connections queue of the given length."

	<category: 'instance creation'>
	^self 
	    port: 0
	    queueSize: backlog
	    bindTo: ipAddress
    ]

    ServerSocket class >> port: anInteger [
	"Answer a new ServerSocket serving on any local address, on the given
	 port, with a pending connections queue of the default length."

	<category: 'instance creation'>
	^self 
	    port: anInteger
	    queueSize: self defaultQueueSize
	    bindTo: nil
    ]

    ServerSocket class >> port: anInteger queueSize: backlog [
	"Answer a new ServerSocket serving on any local address, on the given
	 port, with a pending connections queue of the given length."

	<category: 'instance creation'>
	^self 
	    port: anInteger
	    queueSize: backlog
	    bindTo: nil
    ]

    ServerSocket class >> port: anInteger bindTo: ipAddress [
	"Answer a new ServerSocket serving on the given address and port,
	 with a pending connections queue of the default length."

	<category: 'instance creation'>
	^self 
	    port: anInteger
	    queueSize: self defaultQueueSize
	    bindTo: ipAddress
    ]

    ServerSocket class >> port: anInteger queueSize: backlog bindTo: ipAddress [
	"Answer a new ServerSocket serving on the given address and port,
	 and with a pending connections queue of the given length."

	<category: 'instance creation'>
	| localAddr addressClass |
	addressClass := ipAddress isNil 
		    ifTrue: [self defaultAddressClass]
		    ifFalse: [ipAddress class].
	localAddr := ipAddress isNil 
		    ifTrue: [addressClass unknownAddress]
		    ifFalse: [ipAddress].
	^(addressClass newSocket: self)
	    port: anInteger
	    queueSize: backlog
	    bindTo: localAddr
    ]

    address [
	"Answer the local address"

	<category: 'accessing'>
	^self localAddress
    ]

    port [
	"Answer the local port (the port that the passive socket is listening on)."

	<category: 'accessing'>
	^self localPort
    ]

    waitForConnection [
	"Wait for a connection to be available, and suspend the currently
	 executing process in the meanwhile."

	<category: 'accessing'>
	self implementation ensureReadable
    ]

    accept [
	"Accept a new connection and create a new instance of Socket if there is
	 one, else answer nil."

	<category: 'accessing'>
	^self accept: Socket
    ]

    accept: socketClass [
	"Accept a new connection and create a new instance of socketClass if
	 there is one, else answer nil.  This is usually needed only to create
	 DatagramSockets."

	<category: 'accessing'>
	self canRead ifFalse: [^nil].	"Make it non-blocking"
	^self primAccept: socketClass
    ]

    primAccept: socketClass [
	"Accept a new connection and create a new instance of Socket if there is
	 one, else fail."

	<category: 'accessing'>
	| implClass newImpl |
	implClass := self implementation activeSocketImplClass.
	newImpl := self implementation accept: implClass.
	^socketClass new: newImpl
    ]

    port: anInteger queueSize: backlog bindTo: localAddr [
	"Initialize the ServerSocket so that it serves on the given
	 address and port, and has a pending connections queue of
	 the given length."

	<category: 'initializing'>
	(self implementation)
	    soReuseAddr: 1;
	    bindTo: localAddr port: anInteger;
	    listen: backlog
    ]
]



AbstractSocket subclass: StreamSocket [
    | peerDead readBuffer outOfBand |
    
    <category: 'Sockets-Streams'>
    <comment: '
This class adds a read buffer to the basic model of AbstractSocket.'>

    ReadBufferSize := nil.

    StreamSocket class >> initialize [
	"Initialize the receiver's defaults"

	<category: 'initialize'>
	self readBufferSize: 1024.
    ]

    StreamSocket class >> readBufferSize [
	"Answer the size of the read buffer for newly-created sockets"

	<category: 'accessing'>
	^ReadBufferSize
    ]

    StreamSocket class >> readBufferSize: anInteger [
	"Set the size of the read buffer for newly-created sockets"

	<category: 'accessing'>
	ReadBufferSize := anInteger
    ]

    StreamSocket class >> defaultImplementationClassFor: aSocketAddressClass [
	"Answer the default implementation class.  Depending on the
	 subclass, this might be the default stream socket implementation
	 class of the given address class, or rather its default datagram
	 socket implementation class."

	<category: 'accessing'>
	^aSocketAddressClass defaultStreamSocketImplClass
    ]

    StreamSocket class >> remote: ipAddressOrString port: remotePort [
	"Create a new socket and connect to the given host (passed as a
	 String to be resolved or as a SocketAddress), and to the given port."

	<category: 'instance creation'>
	^self 
	    remote: ipAddressOrString
	    port: remotePort
	    local: nil
	    port: 0
    ]

    StreamSocket class >> remote: ipAddressOrString port: remotePort local: ipAddress port: localPort [
	"Create a new socket and connect to the given host (passed as a
	 String to be resolved or as a SocketAddress), and to the given remotePort.
	 Then bind it to the local address passed in ipAddress, on the localPort
	 port; if the former is nil, any local address will do, and if the latter
	 is 0, any local port will do."

	<category: 'instance creation'>
	| localAddr remoteAddr addressClass |
	remoteAddr := self resolveAddress: ipAddressOrString.
	remoteAddr isNil 
	    ifTrue: 
		[self error: 'cannot resolve host name ' , ipAddressOrString printString].
	addressClass := remoteAddr isNil 
		    ifTrue: [self defaultAddressClass]
		    ifFalse: [remoteAddr class].
	addressClass := ipAddress isNil 
		    ifTrue: [addressClass]
		    ifFalse: [ipAddress class].
	^(addressClass newSocket: self)
	    remote: remoteAddr
	    port: remotePort
	    local: localAddr
	    port: localPort
    ]

    address [
	"Answer the address of the remote endpoint"

	<category: 'accessing'>
	^self remoteAddress
    ]

    port [
	"Answer the port of the remote endpoint"

	<category: 'accessing'>
	^self remotePort
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream"

	<category: 'printing'>
	aStream
	    print: self class;
	    nextPutAll: '[local ';
	    print: self localAddress;
	    nextPut: $:;
	    print: self localPort;
	    nextPutAll: ', remote ';
	    print: self remoteAddress;
	    nextPut: $:;
	    print: self remotePort;
	    nextPut: $]
    ]

    remote: remoteAddr port: remotePort local: localAddr port: localPort [
	<category: 'private'>
	localAddr isNil 
	    ifFalse: [self implementation bindTo: localAddr port: localPort].
	self implementation connectTo: remoteAddr port: remotePort
    ]

    species [
	<category: 'private'>
	^String
    ]

    atEnd [
	"Answer whether more data is available on the socket"

	<category: 'stream protocol'>
	^self peek isNil
    ]

    ensureReadable [
	"Suspend the current process until more data is available in the
	 socket's read buffer or from the operating system."

	self canRead ifFalse: [ super ensureReadable ]
    ]

    canRead [
	"Answer whether more data is available in the socket's read buffer
	 or from the operating system."

	<category: 'stream protocol'>
	^(self hasReadBuffer and: [self readBuffer notEmpty]) 
	    or: [super canRead]
    ]

    availableBytes [
	"Answer how many bytes are available in the socket's read buffer
	 or from the operating system."

	<category: 'stream protocol'>
	self canRead ifFalse: [ ^0 ].
	^self readBuffer availableBytes
    ]

    bufferContents [
	"Answer the current contents of the read buffer"

	<category: 'stream protocol'>
	readBuffer isNil ifTrue: [^self pastEnd].
	^self readBuffer bufferContents
    ]

    close [
	"Flush and close the socket."

	<category: 'stream protocol'>
	super close.
	self deleteBuffers
    ]

    fill [
	"Fill the read buffer with data read from the socket"

	<category: 'stream protocol'>
	self readBuffer notNil ifTrue: [self readBuffer fill]
    ]

    isPeerAlive [
	"Answer whether the connection with the peer remote machine is still
	 valid."

	<category: 'stream protocol'>
	^self readBuffer notNil and: [ super isPeerAlive ]
    ]

    next [
	"Read a byte from the socket.  This might yield control to other
	 Smalltalk Processes."

	<category: 'stream protocol'>
	readBuffer isNil ifTrue: [^self pastEnd].
	^self readBuffer next
    ]
	
    nextAvailable: anInteger putAllOn: aStream [
        "Copy up to anInteger objects from the receiver to
	 aStream, stopping if no more data is available."

        <category: 'accessing-reading'>
	| available read |
	readBuffer isNil ifTrue: [ ^self pastEnd ].
	self ensureReadable.

	read := 0.
	[ read < anInteger
		and: [ (available := self availableBytes) > 0 ] ] whileTrue: [
	    read := read + (self readBuffer
		nextAvailable: (available min: anInteger - read)
		putAllOn: aStream) ].

	^read
    ]

    nextAvailable: anInteger into: aCollection startingAt: pos [
        "Place up to anInteger objects from the receiver into
	 aCollection, starting from position pos and stopping if
         no more data is available."

        <category: 'accessing-reading'>
	| available read |
	readBuffer isNil ifTrue: [ ^self pastEnd ].
	self ensureReadable.

	read := 0.
	[ read < anInteger
		and: [ (available := self availableBytes) > 0 ] ] whileTrue: [
	    read := read + (self readBuffer
		nextAvailable: (available min: anInteger - read)
		into: aCollection
		startingAt: pos + read) ].

	^read
    ]

    peek [
	"Read a byte from the socket, without advancing the buffer; answer
	 nil if no more data is available.  This might yield control to other
	 Smalltalk Processes."

	<category: 'stream protocol'>
	self readBuffer isNil ifTrue: [^nil].
	self readBuffer atEnd ifTrue: [^nil].
	^self readBuffer peek
    ]

    peekFor: anObject [
	"Read a byte from the socket, advancing the buffer only if it matches
	 anObject; answer whether they did match or not.  This might yield
	 control to other Smalltalk Processes."

	<category: 'stream protocol'>
	self readBuffer isNil ifTrue: [^false].
	self readBuffer atEnd ifTrue: [^false].
	^self readBuffer peekFor: anObject
    ]

    readBufferSize: size [
	"Create a new read buffer of the given size (which is only
	 possible before the first read or if the current buffer is
	 empty)."

	<category: 'stream protocol'>
	readBuffer isNil ifTrue: [^self].
	(self hasReadBuffer and: [readBuffer notEmpty]) 
	    ifTrue: [self error: 'read buffer must be empty before changing its size'].
	readBuffer := self newReadBuffer: size
    ]

    deleteBuffers [
	<category: 'private - buffering'>
	readBuffer := nil
    ]

    noBufferFlag [
	"Value that means `lazily initialize the buffer'."

	<category: 'private - buffering'>
	^0
    ]

    hasReadBuffer [
	<category: 'private - buffering'>
	^readBuffer ~~ self noBufferFlag
    ]

    initialize: implementation [
	<category: 'private - buffering'>
	super initialize: implementation.
	readBuffer := self noBufferFlag
    ]

    newReadBuffer: size [
	<category: 'private - buffering'>
	^(ReadBuffer on: (String new: size)) fillBlock: 
		[:data :size || n | 
		self implementation ensureReadable.
		n := self implementation isOpen 
		    ifTrue: [self implementation nextAvailable: size into: data startingAt: 1]
                    ifFalse: [0].
		n = 0 ifTrue: [self deleteBuffers].
		n]
    ]

    readBuffer [
	<category: 'private - buffering'>
	readBuffer == self noBufferFlag 
	    ifTrue: [readBuffer := self newReadBuffer: ReadBufferSize].
	^readBuffer
    ]

    outOfBand [
	"Return a datagram socket to be used for receiving out-of-band data
	 on the receiver."

	<category: 'out-of-band data'>
	| outOfBandImpl |
	outOfBand isNil 
	    ifTrue: 
		[outOfBandImpl := self implementation outOfBandImplClass new.
		outOfBandImpl initialize: self implementation fd.
		outOfBand := DatagramSocket new: outOfBandImpl].
	^outOfBand
    ]
]



StreamSocket subclass: Socket [
    | writeBuffer |
    
    <category: 'Sockets-Streams'>
    <comment: '
This class adds read and write buffers to the basic model of AbstractSocket.'>

    WriteBufferSize := nil.

    Socket class >> initialize [
	"Initialize the receiver's defaults"

	<category: 'well known ports'>
	self writeBufferSize: 256.
    ]

    Socket class >> writeBufferSize [
	"Answer the size of the write buffer for newly-created sockets"

	<category: 'accessing'>
	^WriteBufferSize
    ]

    Socket class >> writeBufferSize: anInteger [
	"Set the size of the write buffer for newly-created sockets"

	<category: 'accessing'>
	WriteBufferSize := anInteger
    ]

    flush [
	"Flush the write buffer to the operating system"

	<category: 'stream protocol'>
	self isPeerAlive ifTrue: [
	    self implementation valueWithoutBuffering: [
		self writeBuffer flush]]
    ]

    nextPut: char [
	"Write a character to the socket; this acts as a bit-bucket when
	 the socket is closed.  This might yield control to other
	 Smalltalk Processes."

	<category: 'stream protocol'>
	self writeBuffer isNil ifTrue: [^self].
	self writeBuffer nextPut: char
    ]

    next: n putAll: aCollection startingAt: pos [
	"Write aString to the socket; this acts as a bit-bucket when
	 the socket is closed.  This might yield control to other
	 Smalltalk Processes."

	<category: 'stream protocol'>
	self writeBuffer isNil ifTrue: [^self].
	self writeBuffer next: n putAll: aCollection startingAt: pos
    ]

    writeBufferSize: size [
	"Create a new write buffer of the given size, flushing the
	 old one is needed.  This might yield control to other
	 Smalltalk Processes."

	<category: 'stream protocol'>
	writeBuffer isNil ifTrue: [^self].
	self hasWriteBuffer ifTrue: [writeBuffer flush].
	writeBuffer := self newWriteBuffer: size
    ]

    deleteBuffers [
	<category: 'private - buffering'>
	super deleteBuffers.
	writeBuffer := nil
    ]

    hasWriteBuffer [
	<category: 'private - buffering'>
	^writeBuffer ~~ self noBufferFlag
    ]

    initialize: implementation [
	<category: 'private - buffering'>
	super initialize: implementation.
	writeBuffer := self noBufferFlag
    ]

    ensureWriteable [
	"Answer whether more data is available in the socket's read buffer
	 or from the operating system."

	<category: 'stream protocol'>
	self canWrite ifFalse: [super ensureWriteable]
    ]

    canWrite [
	"Answer whether more data is available in the socket's read buffer
	 or from the operating system."

	<category: 'stream protocol'>
	^(self hasWriteBuffer and: [self readBuffer isFull not]) 
	    or: [super canWrite]
    ]

    newWriteBuffer: size [
	<category: 'private - buffering'>
	^(WriteBuffer on: (String new: size)) flushBlock: 
		[:data :size | 
		| alive |
		self implementation ensureWriteable.
		alive := self implementation isOpen 
			    and: [(self implementation next: size putAll: data startingAt: 1) > -1].
		alive ifFalse: [self deleteBuffers]]
    ]

    writeBuffer [
	<category: 'private - buffering'>
	writeBuffer == self noBufferFlag 
	    ifTrue: [writeBuffer := self newWriteBuffer: WriteBufferSize].
	^writeBuffer
    ]
]



Eval [
    AbstractSocket initialize.
    StreamSocket initialize.
    Socket initialize.
]

PK
     \h@�pz��  �    package.xmlUT	 ׊XO׊XOux �  �  <package>
  <name>Sockets</name>
  <namespace>Sockets</namespace>
  <test>
    <namespace>Sockets</namespace>
    <prereq>Sockets</prereq>
    <prereq>SUnit</prereq>
    <sunit>Sockets.SocketTest</sunit>
    <filein>UnitTest.st</filein>
  </test>
  <prereq>ObjectDumper</prereq>
  <callout>TCPaccept</callout>

  <filein>Buffers.st</filein>
  <filein>Datagram.st</filein>
  <filein>SocketAddress.st</filein>
  <filein>AbstractSocketImpl.st</filein>
  <filein>IPSocketImpl.st</filein>
  <filein>IP6SocketImpl.st</filein>
  <filein>UnixSocketImpl.st</filein>
  <filein>Sockets.st</filein>
  <filein>Tests.st</filein>
  <filein>cfuncs.st</filein>
  <filein>init.st</filein>
  <file>ChangeLog</file>
</package>PK
     �Mh@�Ji�  �  
  Buffers.stUT	 eqXO׊XOux �  �  "======================================================================
|
|   ReadBuffer and WriteBuffer classes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2003, 2007, 2008, 2009 Free Software Foundation, Inc.
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



WriteStream subclass: WriteBuffer [
    | flushBlock |
    
    <category: 'Examples-Useful tools'>
    <comment: '
I''m a WriteStream that, instead of growing the collection,
evaluates an user defined block and starts over with the same
collection.'>

    flush [
	"Evaluate the flushing block and reset the stream"

	<category: 'buffer handling'>
	flushBlock notNil ifTrue: [flushBlock value: collection value: ptr - 1].
	ptr := 1
    ]

    close [
	<category: 'buffer handling'>
        super close.
        flushBlock := nil
    ]

    flushBlock: block [
	"Set which block will be used to flush the buffer.
	 The block will be evaluated with a collection and
	 an Integer n as parameters, and will have to write
	 the first n elements of the collection."

	<category: 'buffer handling'>
	flushBlock := block
    ]

    growCollection [
	<category: 'private'>
	self flush
    ]

    growCollectionTo: n [
	<category: 'private'>
	self shouldNotImplement
    ]

    isFull [
	<category: 'testing'>
	^self position = self collection size
    ]

    next: n putAll: aCollection startingAt: pos [
        "Put n characters or bytes of aCollection, starting at the pos-th,
         in the collection buffer."

        <category: 'accessing-writing'>

	| end written amount |
	ptr = collection size ifTrue: [self growCollection].
	written := 0.
	
	[end := collection size min: ptr + (n - written - 1).
	end >= ptr 
	    ifTrue: 
		[collection 
		    replaceFrom: ptr
		    to: end
		    with: aCollection
		    startingAt: pos + written.
		written := written + (end - ptr + 1).
		ptr := end + 1].
	written < n] 
		whileTrue: [self growCollection].
    ]

]



ReadStream subclass: ReadBuffer [
    | fillBlock |
    
    <category: 'Examples-Useful tools'>
    <comment: '
I''m a ReadStream that, when the end of the stream is reached,
evaluates an user defined block to try to get some more data.'>

    ReadBuffer class >> on: aCollection [
	"Answer a Stream that uses aCollection as a buffer.  You
	 should ensure that the fillBlock is set before the first
	 operation, because the buffer will report that the data
	 has ended until you set the fillBlock."

	<category: 'instance creation'>
	^(super on: aCollection)
	    setToEnd;
	    yourself	"Force a buffer load soon"
    ]

    close [
	<category: 'buffer handling'>
        super close.
        fillBlock := nil
    ]

    atEnd [
	"Answer whether the data stream has ended."

	<category: 'buffer handling'>
	self basicAtEnd ifFalse: [^false].
	fillBlock isNil ifTrue: [^true].
	endPtr := fillBlock value: collection value: collection size.
	ptr := 1.
	^self basicAtEnd
    ]

    pastEnd [
	"Try to fill the buffer if the data stream has ended."

	<category: 'buffer handling'>
	self atEnd ifTrue: [^super pastEnd].
	"Else, the buffer has been filled."
	^self next
    ]

    bufferContents [
	"Answer the data that is in the buffer, and empty it."

	<category: 'buffer handling'>
	| contents |
	self basicAtEnd ifTrue: [^self species new: 0].
	contents := self collection copyFrom: ptr to: endPtr.
	endPtr := ptr - 1.	"Empty the buffer"
	^contents
    ]

    availableBytes [
        "Answer how many bytes are available in the buffer."

	<category: 'buffer handling'>
	self isEmpty ifTrue: [ self fill ].
	^endPtr + 1 - ptr
    ]

    nextAvailable: anInteger putAllOn: aStream [
	"Copy the next anInteger objects from the receiver to aStream.
	 Return the number of items stored."

	<category: 'accessing-reading'>
	self isEmpty ifTrue: [ self fill ].
	^super nextAvailable: anInteger putAllOn: aStream
    ]

    nextAvailable: anInteger into: aCollection startingAt: pos [
	"Place the next anInteger objects from the receiver into aCollection,
	 starting at position pos.  Return the number of items stored."

	<category: 'accessing-reading'>
	self isEmpty ifTrue: [ self fill ].
	^super nextAvailable: anInteger into: aCollection startingAt: pos
    ]

    fill [
	"Fill the buffer with more data if it is empty, and answer
	 true if the fill block was able to read more data."

	<category: 'buffer handling'>
	^self atEnd not
    ]

    fillBlock: block [
	"Set the block that fills the buffer. It receives a collection
	 and the number of bytes to fill in it, and must return the number
	 of bytes actually read"

	<category: 'buffer handling'>
	fillBlock := block
    ]

    isEmpty [
	"Answer whether the next input operation will force a buffer fill"

	<category: 'buffer handling'>
	^self basicAtEnd
    ]

    isFull [
	"Answer whether the buffer has been just filled"

	<category: 'buffer handling'>
	^self notEmpty and: [self position = 0]
    ]

    notEmpty [
	"Check whether the next input operation will force a buffer fill
	 and answer true if it will not."

	<category: 'buffer handling'>
	^self basicAtEnd not
    ]

    upToEnd [
	"Returns a collection of the same type that the stream accesses, up to
	 but not including the object anObject.  Returns the entire rest of the
	 stream's contents if anObject is not present."

	<category: 'accessing-reading'>
	| ws |
	ws := String new writeStream.
	[self nextAvailablePutAllOn: ws.
	self atEnd] whileFalse.
	^ws contents
    ]

    upTo: anObject [
	"Returns a collection of the same type that the stream accesses, up to
	 but not including the object anObject.  Returns the entire rest of the
	 stream's contents if anObject is not present."

	<category: 'accessing-reading'>
	| result r ws |
	self atEnd ifTrue: [^collection copyEmpty: 0].
	r := collection indexOf: anObject startingAt: ptr ifAbsent: [0].
	r = 0 ifFalse: [result := self next: r - ptr. self next. ^result].

	ws := String new writeStream.
	[self nextAvailablePutAllOn: ws.
	self atEnd ifTrue: [^ws contents].
	r := collection indexOf: anObject startingAt: ptr ifAbsent: [0].
	r = 0] whileTrue.

	self next: r - 1 putAllOn: ws; next.
	^ws contents
    ]
]

PK
     �Mh@���4S  4S    AbstractSocketImpl.stUT	 eqXO׊XOux �  �  "======================================================================
|
|   Abstract socket implementations
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008, 2009 Free Software Foundation, Inc.
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



FileDescriptor subclass: AbstractSocketImpl [
    | localAddress localPort remoteAddress remotePort |
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for socket implementations.
The implementation class serves an intermediary to routines that
perform the actual socket operations.  It hides the buffering and
blocking behavior of the Socket classes.

A default implementation is provided by each address family, but
this can be changed by class methods on SocketAddress sublcasses.'>

    AbstractSocketImpl class >> addressClass [
	"Answer the class responsible for handling addresses for
	 the receiver"

	<category: 'abstract'>
	self subclassResponsibility
    ]

    AbstractSocketImpl class >> protocol [
	"Answer the protocol parameter for `create'"

	<category: 'abstract'>
	^0
    ]

    AbstractSocketImpl class >> socketType [
	"Answer the socket type parameter for `create'."

	<category: 'abstract'>
	self subclassResponsibility
    ]

    AbstractSocketImpl class >> newFor: addressClass [
	"Create a socket for the receiver."

	<category: 'socket creation'>
	| descriptor |
	descriptor := self 
		    create: addressClass protocolFamily
		    type: self socketType
		    protocol: self protocol.
	descriptor < 0 ifTrue: [ File checkError ].
	^self on: descriptor
    ]

    accept: implementationClass [
	"Accept a connection on the receiver, and create a new instance
	 of implementationClass that will deal with the newly created
	 active server socket."

	<category: 'socket operations'>
	| peer addrLen newFD fd |
	peer := ByteArray new: 128.
	addrLen := CInt gcValue: 128.
	(fd := self fd) isNil ifTrue: [ ^SystemExceptions.EndOfStream signal ].
	newFD := self 
		    accept: fd
		    peer: peer
		    addrLen: addrLen.
        newFD < 0 ifTrue: [ self checkSoError ].
	^(implementationClass on: newFD)
	    hasBeenBound;
	    hasBeenConnectedTo: peer;
	    yourself
    ]

    bindTo: ipAddress port: port [
	"Bind the receiver to the given IP address and port. `Binding' means
	 attaching the local endpoint of the socket."

	<category: 'socket operations'>
	| addr fd |
	addr := ipAddress port: port.
	
	(fd := self fd) isNil ifTrue: [ ^self ].
	[(self 
	    bind: fd
	    to: addr
	    addrLen: addr size) < 0 ifTrue: [File checkError] ]
		ifCurtailed: [self close].
	self isOpen ifTrue: [self hasBeenBound]
    ]

    fileOp: ioFuncIndex [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	^aBlock value
    ]

    fileOp: ioFuncIndex with: arg1 [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex with: arg1 ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	^aBlock value
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	^aBlock value
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3 [
	"Private - Used to limit the number of primitives used by FileStreams"

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	self checkError.
	^nil
    ]

    fileOp: ioFuncIndex with: arg1 with: arg2 with: arg3 ifFail: aBlock [
	"Private - Used to limit the number of primitives used by FileStreams."

	<category: 'socket operations'>
	<primitive: VMpr_FileDescriptor_socketOp>
	^aBlock value
    ]

    getSockName [
	"Retrieve a ByteArray containing a sockaddr_in struct for the
	 local endpoint of the socket."

	<category: 'socket operations'>
	| sock addrLen fd |
	sock := ByteArray new: 128.
	addrLen := CInt gcValue: 128.
	(fd := self fd) isNil
	    ifTrue: [ ^nil ].
	(self getSockName: self fd addr: sock addrLen: addrLen) = -1
	    ifTrue: [ ^nil ].
	^sock
    ]

    listen: backlog [
	"Make the receiver a passive server socket with a pending connections
	 queue of the given size."

	<category: 'socket operations'>
	| fd |
	(fd := self fd) isNil ifTrue: [ ^self ].
	self listen: fd log: backlog
    ]

    connectTo: ipAddress port: port [
	"Connect the receiver to the given IP address and port. `Connecting'
	 means attaching the remote endpoint of the socket."

	<category: 'accessing'>
	self hasBeenConnectedTo: ipAddress port: port
    ]

    localAddress [
	"Answer the address of the local endpoint of the socket (even if IP
	 is not being used, this identifies the machine that is bound to the
	 socket)."

	<category: 'accessing'>
	^localAddress
    ]

    localPort [
	"Answer the port of the local endpoint of the socket (even if IP
	 is not being used, this identifies the service or process that
	 is bound to the socket)."

	<category: 'accessing'>
	^localPort
    ]

    remoteAddress [
	"Answer the address of the remote endpoint of the socket (even if IP
	 is not being used, this identifies the machine to which the socket
	 is connected)."

	<category: 'accessing'>
	^remoteAddress
    ]

    remotePort [
	"Answer the port of the remote endpoint of the socket (even if IP
	 is not being used, this identifies the service or process to which
	 the socket is connected)."

	<category: 'accessing'>
	^remotePort
    ]

    valueWithoutBuffering: aBlock [
	"Evaluate aBlock, ensuring that any data that it writes to the socket
	 is sent immediately to the network."

	<category: 'socket options'>
	aBlock value
    ]

    optionAt: opt level: level size: size [
	"Answer in a ByteArray of the given size the value of a socket option.
	 The option identifier is in `opt' and the level is in `level'.  A
	 layer over this method is provided for the most common socket options,
	 so this will be rarely used."

	<category: 'socket options'>
	| result len fd |
	result := ByteArray new: size.
	len := CInt gcValue: size.
	(fd := self fd) isNil ifTrue: [ ^nil ].
	self 
	    option: fd
	    level: level
	    at: opt
	    get: result
	    size: len.
	^result
    ]

    optionAt: opt level: level put: anObject [
	"Modify the value of a socket option.  The option identifier is in
	 `opt' and the level is in `level'.  anObject can be a boolean,
	 integer, socket address or ByteArray. A layer over this method is
	 provided for the most common socket options, so this will be rarely
	 used."

	<category: 'socket options'>
	| ba fd |
	ba := self makeByteArray: anObject.
	(fd := self fd) isNil ifTrue: [ ^self ].
	self 
	    option: fd
	    level: level
	    at: opt
	    put: ba
	    size: ba size
    ]

    soLinger [
	"Answer the number of seconds by which a `close' operation can block
	 to ensure that all the packets have reliably reached the destination,
	 or nil if those packets are left to their destiny."

	<category: 'socket options'>
	| data |
	data := self 
		    optionAt: self class soLinger
		    level: self class solSocket
		    size: CInt sizeof * 2.
	(data intAt: 1) = 0 ifTrue: [^nil].
	^data intAt: CInt sizeof + 1
    ]

    soLinger: linger [
	"Set the number of seconds by which a `close' operation can block
	 to ensure that all the packets have reliably reached the destination.
	 If linger is nil, those packets are left to their destiny."

	<category: 'socket options'>
	| data |
	data := ByteArray new: CInt sizeof * 2.
	linger isNil 
	    ifFalse: 
		[data at: 1 put: 1.
		data intAt: CInt sizeof + 1 put: linger].
	self 
	    optionAt: self class soLinger
	    level: self class solSocket
	    put: data
    ]

    soReuseAddr [
	"Answer whether another socket can be bound the same local address as this
	 one.  If you enable this option, you can actually have two sockets with the
	 same Internet port number; but the system won't allow you to use the two
	 identically-named sockets in a way that would confuse the Internet.  The
	 reason for this option is that some higher-level Internet protocols,
	 including FTP, require you to keep reusing the same socket number."

	<category: 'socket options'>
	^((self 
	    optionAt: self class soReuseAddr
	    level: self class solSocket
	    size: CInt sizeof) intAt: 1) 
	    > 0
    ]

    soReuseAddr: aBoolean [
	"Set whether another socket can be bound the same local address as this one."

	<category: 'socket options'>
	self 
	    optionAt: self class soReuseAddr
	    level: self class solSocket
	    put: aBoolean
    ]

    makeByteArray: anObject [
	"Private - Convert anObject to a ByteArray to be used to store socket
	 options.  This can be a ByteArray, a socket address valid for this
	 class, an Integer or a Boolean."

	<category: 'private'>
	anObject == true ifTrue: [
	    ^#[1 0 0 0]].
	anObject == false ifTrue: [
	    ^#[0 0 0 0]].
	anObject isInteger ifTrue: [
	    ^(ByteArray new: CInt sizeof)
		at: 1 put: (anObject bitAnd: 255);
		at: 2 put: (anObject // 256 bitAnd: 255);
		at: 3 put: (anObject // 65536 bitAnd: 255);
		at: 4 put: (anObject // 16777216 bitAnd: 255);
		yourself].

	^anObject asByteArray
    ]

    hasBeenConnectedTo: ipAddress port: port [
	"Store the remote address and port that the receiver is connected to."

	<category: 'private'>
	remoteAddress := ipAddress.
	remotePort := port
    ]

    hasBeenConnectedTo: sockAddr [
	"Store the remote address and port that the receiver is connected to."

	<category: 'private'>
	| port |
	port := ValueHolder new.
	self 
	    hasBeenConnectedTo: (SocketAddress fromSockAddr: sockAddr port: port)
	    port: port value
    ]

    hasBeenBoundTo: ipAddress port: port [
	"Store the local address and port that the receiver is bound to."

	<category: 'private'>
	localAddress := ipAddress.
	localPort := port
    ]

    hasBeenBoundTo: sockAddr [
	"Store the local address and port that the receiver has been bound to."

	<category: 'private'>
	| port |
	port := ValueHolder new.
	self hasBeenBoundTo: (SocketAddress fromSockAddr: sockAddr port: port)
	    port: port value
    ]

    hasBeenBound [
	"Retrieve the local address and port that the receiver has been bound to."

	<category: 'private'>
	self hasBeenBoundTo: self getSockName
    ]

    checkSoError [
        "Retrieve SO_ERROR and, if non-zero, raise an exception for its value."

	<category: 'private'>
        self isOpen ifFalse: [^SystemExceptions.FileError signal: 'file closed'].
        File checkError: self soError
    ]

    ensureReadable [
	"If the file is open, wait until data can be read from it.  The wait
	 allows other Processes to run."

	<category: 'asynchronous operations'>
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 14
	    with: 0
	    with: Semaphore new
	    ifFail: [[self checkSoError] ensure: [^self close]].
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 13
	    with: 0
	    ifFail: [[self checkSoError] ensure: [self close]]
    ]

    ensureWriteable [
	"If the file is open, wait until we can write to it.  The wait
	 allows other Processes to run."

	"FileDescriptor's ensureWriteable is actually dummy,
	 because not all devices support sending SIGIO's when
	 they become writeable -- notably, tty's under Linux :-("

	<category: 'asynchronous operations'>
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 14
	    with: 1
	    with: Semaphore new
	    ifFail: [[self checkSoError] ensure: [^self close]].
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 13
	    with: 1
	    ifFail: [[self checkSoError] ensure: [self close]]
    ]

    waitForException [
	"If the file is open, wait until an exceptional condition (such
	 as presence of out of band data) has occurred on it.  The wait
	 allows other Processes to run."

	<category: 'asynchronous operations'>
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 14
	    with: 2
	    with: Semaphore new
	    ifFail: [[self checkSoError] ensure: [^self close]].
	self isOpen ifFalse: [^self].
	self 
	    fileOp: 13
	    with: 2
	    ifFail: [[self checkSoError] ensure: [self close]]
    ]

    soError [
	<category: 'private'>
	^self soError: self fd
    ]
]



AbstractSocketImpl subclass: SocketImpl [
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for stream socket
implementations.'>

    SocketImpl class >> socketType [
	"Answer the socket type parameter for `create'."

	<category: 'parameters'>
	^self sockStream
    ]

    activeSocketImplClass [
	"Return an implementation class to be used for the active socket
	 created when a connection is accepted by a listening socket.
	 The default is simply the same class as the receiver."
	^self class
    ]

    outOfBandImplClass [
	"Return an implementation class to be used for out-of-band data
	 on the receiver."

	<category: 'abstract'>
	^OOBSocketImpl
    ]

    connectTo: ipAddress port: port [
	"Try to connect the socket represented by the receiver to the given remote
	 machine."

	<category: 'socket operations'>
	| addr fd peer |
	addr := ipAddress port: port.
	
	[(fd := self fd) isNil ifTrue: [ ^self ].
	(self 
	    connect: fd
	    to: addr
	    addrLen: addr size) < 0 ifTrue: [self checkSoError] ]
		ifCurtailed: [self close].

	"connect does not block, so wait for"
	self ensureWriteable.
	self isOpen ifTrue: [
	    peer := self getPeerName ifNil: [ addr ].
	    self hasBeenConnectedTo: peer]
    ]

    getPeerName [
	"Retrieve a ByteArray containing a sockaddr_in struct for the
	 remote endpoint of the socket."

	<category: 'socket operations'>
	| peer addrLen fd |
	peer := ByteArray new: 128.
	addrLen := CInt gcValue: 128.
	(fd := self fd) isNil
	    ifTrue: [ ^nil ].
	(self getPeerName: self fd addr: peer addrLen: addrLen) = -1
	    ifTrue: [ ^nil ].
	^peer
    ]

]



AbstractSocketImpl subclass: DatagramSocketImpl [
    | bufSize |
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for datagram socket
implementations.'>

    DatagramSocketImpl class >> socketType [
	"Answer the socket type parameter for `create'."

	<category: 'parameters'>
	^self sockDgram
    ]

    DatagramSocketImpl class >> datagramClass [
	"Answer the datagram class returned by default by instances of
	 this class."

	<category: 'parameters'>
	^Datagram
    ]

    bufferSize [
	"Answer the size of the buffer in which datagrams are stored."

	<category: 'accessing'>
	^bufSize
    ]

    bufferSize: size [
	"Set the size of the buffer in which datagrams are stored."

	<category: 'accessing'>
	bufSize := size
    ]

    peek [
	"Peek for a datagram on the receiver, answer a new object
	 of the receiver's datagram class."

	<category: 'socket operations'>
	^self receive: self msgPeek datagram: self class datagramClass new
    ]

    peek: aDatagram [
	"Peek for a datagram on the receiver, answer aDatagram modified
	 to contain information on the newly received datagram."

	<category: 'socket operations'>
	^self receive: self msgPeek datagram: aDatagram
    ]

    next [
	"Retrieve a datagram from the receiver, answer a new object
	 of the receiver's datagram class."

	<category: 'socket operations'>
	^self receive: 0 datagram: self class datagramClass new
    ]

    receive: aDatagram [
	"Retrieve a datagram from the receiver, answer aDatagram modified
	 to contain information on the newly received datagram."

	<category: 'socket operations'>
	^self receive: 0 datagram: aDatagram
    ]

    nextPut: aDatagram [
	"Send aDatagram on the socket"

	<category: 'socket operations'>
	self 
	    send: aDatagram
	    to: (aDatagram address isNil 
		    ifTrue: [remoteAddress]
		    ifFalse: [aDatagram address])
	    port: (aDatagram port isNil ifTrue: [remotePort] ifFalse: [aDatagram port]).
    ]

    receive: flags datagram: aDatagram [
	"Receive a new datagram into `datagram', with the given flags, and
	 answer `datagram' itself; this is an abstract method.
	 The flags can be zero to receive the datagram, or `self msgPeek'
	 to only peek for it without removing it from the queue."

	<category: 'socket operations'>
	| address port data from addrLen fd read |
	data := ByteArray new: self bufferSize.
	from := ByteArray new: 128.
	addrLen := CInt gcValue: 128.
	(fd := self fd) isNil ifTrue: [ ^SystemExceptions.EndOfStream signal ].
	read := self 
	    receive: fd
	    buffer: data
	    size: data size
	    flags: (self flags bitOr: flags)
	    from: from
	    size: addrLen.
	read < 0 ifTrue: [ self checkSoError ].
	port := ValueHolder new.
	^aDatagram
	    data: data;
	    dataSize: read;
	    address: (SocketAddress fromSockAddr: from port: port);
	    port: port value;
	    yourself
    ]

    send: aDatagram to: theReceiver port: port [
	"Send aDatagram on the socket to the given receiver and port"

	<category: 'socket operations'>
	| size receiver fd sent |
	theReceiver isNil 
	    ifTrue: [receiver := nil. size := 0]
	    ifFalse: 
		[receiver := theReceiver port: port.
		size := receiver size].
	(fd := self fd) isNil ifTrue: [ ^SystemExceptions.EndOfStream signal ].
	sent := self 
	    send: fd
	    buffer: aDatagram data
	    size: aDatagram size
	    flags: self flags
	    to: receiver
	    size: size.
	sent < 0 ifTrue: [ self checkSoError ].
    ]

    flags [
	<category: 'private'>
	^0
    ]
]



DatagramSocketImpl subclass: MulticastSocketImpl [
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for datagram socket
implementations that support multicast.'>

    ipMulticastIf [
	"Answer the local device for a multicast socket (in the form of
	 an address)"

	<category: 'multicasting'>
	self subclassResponsibility
    ]

    ipMulticastIf: interface [
	"Set the local device for a multicast socket (in the form of
	 an address, usually anyLocalAddress)"

	<category: 'multicasting'>
	self subclassResponsibility
    ]

    join: ipAddress [
	"Join the multicast socket at the given address"

	<category: 'multicasting'>
	self subclassResponsibility
    ]

    leave: ipAddress [
	"Leave the multicast socket at the given address"

	<category: 'multicasting'>
	self subclassResponsibility
    ]

    timeToLive [
	"Answer the time to live of the datagrams sent through the receiver
	 to a multicast socket."

	<category: 'multicasting'>
	self subclassResponsibility
    ]

    timeToLive: ttl [
	"Set the time to live of the datagrams sent through the receiver
	 to a multicast socket."

	<category: 'multicasting'>
	self subclassResponsibility
    ]
]



DatagramSocketImpl subclass: RawSocketImpl [
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for raw socket
implementations.  Raw socket packets are modeled as datagrams.'>

    RawSocketImpl class >> socketType [
	"Answer the socket type parameter for `create'."

	<category: 'parameters'>
	^self sockRaw
    ]
]




DatagramSocketImpl subclass: OOBSocketImpl [
    
    <category: 'Sockets-Protocols'>
    <comment: '
This abstract class serves as the parent class for socket
implementations that send out-of-band data over a stream socket.'>

    canRead [
	"Answer whether out-of-band data is available on the socket"

	<category: 'implementation'>
	^self exceptionalCondition
    ]

    ensureReadable [
	"Stop the process until an error occurs or out-of-band data
	 becomes available on the socket"

	<category: 'implementation'>
	^self waitForException
    ]

    flags [
	<category: 'private'>
	^self msgOOB
    ]
]
PK
     �Mh@i�M�R  R    Datagram.stUT	 eqXO׊XOux �  �  "======================================================================
|
|   Smalltalk sockets - Datagram class
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008 Free Software Foundation, Inc.
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



Object subclass: Datagram [
    | data address port dataSize |
    
    <category: 'Sockets-Protocols'>
    <comment: '
This class models a packet of data that is to be sent across the network
using a connectionless protocol such as UDP.  It contains the data
to be send, as well as the destination address and port.  Note that
datagram packets can arrive in any order and are not guaranteed to be
delivered at all.

This class can also be used for receiving data from the network.'>

    Datagram class >> data: aByteArray [
	"Answer a new datagram with the specified data."

	<category: 'instance creation'>
	^(self new)
	    data: aByteArray;
	    yourself
    ]

    Datagram class >> data: aByteArray address: ipAddress port: port [
	"Answer a new datagram with the specified target socket, and
	 aByteArray as its data."

	<category: 'instance creation'>
	^(self new)
	    data: aByteArray;
	    address: ipAddress;
	    port: port;
	    yourself
    ]

    Datagram class >> object: object objectDumper: od address: ipAddress port: port [
	"Serialize the object onto a ByteArray, and create a Datagram with
	 the object as its contents, and the specified receiver.  Serialization
	 takes place through ObjectDumper passed as `od', and the stream
	 attached to the ObjectDumper is resetted every time.  Using this
	 method is indicated if different objects that you're sending are
	 likely to contain references to the same objects."

	<category: 'instance creation'>
	od stream reset.
	od dump: object.
	^self 
	    data: od stream contents
	    address: ipAddress
	    port: port
    ]

    Datagram class >> object: object address: ipAddress port: port [
	"Serialize the object onto a ByteArray, and create a Datagram
	 with the object as its contents, and the specified receiver.
	 Note that each invocation of this method creates a separate
	 ObjectDumper; if different objects that you're sending are likely
	 to contain references to the same objects, you should use
	 #object:objectDumper:address:port:."

	<category: 'instance creation'>
	| stream |
	stream := (String new: 100) writeStream.
	ObjectDumper dump: object to: stream.
	^self 
	    data: stream contents
	    address: ipAddress
	    port: port
    ]

    address [
	"Answer the address of the target socket"

	<category: 'accessing'>
	^address
    ]

    address: ipAddress [
	"Set the address of the target socket"

	<category: 'accessing'>
	address := ipAddress
    ]

    data [
	"Answer the data attached to the datagram"

	<category: 'accessing'>
	^data
    ]

    data: aByteArray [
	"Set the data attached to the datagram"

	<category: 'accessing'>
	data := aByteArray.
	dataSize := nil.
    ]

    dataSize [
	"Answer the size of the message."

	<category: 'accessing'>

	^dataSize
    ]

    dataSize: aSize [
	"I am called to update the size..."

	<category: 'accessing'>

	dataSize := aSize		
    ]

    size [
	"I determine the size of the datagram. It is either an explicitly
         specified dataSize, or the size of the whole collection."

        <category: 'accessing'>
        ^dataSize isNil
	    ifTrue: [data size]
	    ifFalse: [dataSize].
    ]


    get [
	"Parse the data attached to the datagram through a newly created
	 ObjectDumper, and answer the resulting object.  This method is
	 complementary to #object:address:port:."

	<category: 'accessing'>
	^ObjectDumper loadFrom: self data readStream
    ]

    getThrough: objectDumper [
	"Parse the data attached to the datagram through the given
	 ObjectDumper without touching the stream to which it is
	 attached, and answer the resulting object.  The state of
	 the ObjectDumper, though, is updated.  This method is
	 complementary to #object:objectDumper:address:port:."

	<category: 'accessing'>
	| result saveStream |
	saveStream := objectDumper stream.
	[objectDumper stream: self data readStream.
	result := objectDumper load]
	    ensure: [objectDumper stream: saveStream].
	^result
    ]

    port [
	"Answer the IP port of the target socket"

	<category: 'accessing'>
	^port
    ]

    port: thePort [
	"Set the IP port of the target socket"

	<category: 'accessing'>
	port := thePort
    ]
]

PK
     �Mh@~�$�V6  V6    IPSocketImpl.stUT	 eqXO׊XOux �  �  "======================================================================
|
|   Smalltalk IPv4 sockets
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008 Free Software Foundation, Inc.
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



SocketAddress subclass: IPAddress [
    | address |
    
    <comment: '
This class models an IPv4 address.  It also acts as a factory for IPv4
stream (TCP), datagram (UDP) and raw sockets.'>
    <category: 'Sockets-Protocols'>

    IPAddress class >> initialize [
	"Set up the default implementation classes for the receiver"

	<category: 'initialization'>
	self defaultRawSocketImplClass: ICMPSocketImpl.
	self defaultDatagramSocketImplClass: UDPSocketImpl.
	self defaultStreamSocketImplClass: TCPSocketImpl
    ]

    IPAddress class >> createLoopbackHost [
	"Answer an object representing the loopback host in the address
	 family for the receiver.  This is 127.0.0.1 for IPv4."

	<category: 'initialization'>
	^IPAddress fromBytes: #[127 0 0 1]
    ]

    IPAddress class >> createUnknownAddress [
	"Answer an object representing an unkown address in the address
	 family for the receiver"

	<category: 'initialization'>
	^(IPAddress fromBytes: #[0 0 0 0])
	    name: '0.0.0.0';
	    yourself
    ]

    IPAddress class >> addressSize [
	"Answer the size of an IPv4 address."

	<category: 'constants'>
	^4
    ]

    IPAddress class >> version [
	"Answer the version of IP that the receiver implements."

	<category: 'constants'>
	^4
    ]

    IPAddress class >> fromBytes: aByteArray [
	"Answer a new IPAddress from a ByteArray containing the bytes
	 in the same order as the digit form: 131.175.6.2 would be
	 represented as #[131 175 6 2]."

	<category: 'instance creation'>
	^self basicNew 
	    address: ((aByteArray copyFrom: 1 to: 4) makeReadOnly: true)
    ]

    IPAddress class >> fromSockAddr: aByteArray port: portAdaptor [
	"Private - Answer a new IPAddress from a ByteArray containing a
	 C sockaddr_in structure.  The portAdaptor's value is changed
	 to contain the port that the structure refers to."

	<category: 'instance creation'>
	portAdaptor value: (aByteArray at: 3) * 256 + (aByteArray at: 4).
	^self fromBytes: (aByteArray copyFrom: 5 to: 8)
    ]

    IPAddress class >> fromString: aString [
	"Answer a new IPAddress from a String containing the requested
	 address in digit form.  Hexadecimal forms are not allowed.
	 
	 An Internet host address is a number containing four bytes of data.
	 These are divided into two parts, a network number and a local
	 network address number within that network. The network number
	 consists of the first one, two or three bytes; the rest of the
	 bytes are the local address.
	 
	 Network numbers are registered with the Network Information Center
	 (NIC), and are divided into three classes--A, B, and C. The local
	 network address numbers of individual machines are registered with
	 the administrator of the particular network.
	 
	 Class A networks have single-byte numbers in the range 0 to 127. There
	 are only a small number of Class A networks, but they can each support
	 a very large number of hosts (several millions). Medium-sized Class B
	 networks have two-byte network numbers, with the first byte in the range
	 128 to 191; they support several thousands of host, but are almost
	 exhausted. Class C networks are the smallest and the most commonly
	 available; they have three-byte network numbers, with the first byte
	 in the range 192-223. Class D (multicast, 224.0.0.0 to 239.255.255.255)
	 and E (research, 240.0.0.0 to 255.255.255.255) also have three-byte
	 network numbers.
	 
	 Thus, the first 1, 2, or 3 bytes of an Internet address specifies a
	 network. The remaining bytes of the Internet address specify the address
	 within that network.  The Class A network 0 is reserved for broadcast to
	 all networks. In addition, the host number 0 within each network is
	 reserved for broadcast to all hosts in that network.  The Class A network
	 127 is reserved for loopback; you can always use the Internet address
	 `127.0.0.1' to refer to the host machine (this is answered by the
	 #loopbackHost class method).
	 
	 Since a single machine can be a member of multiple networks, it can have
	 multiple Internet host addresses. However, there is never supposed to be
	 more than one machine with the same host address.
	 
	 There are four forms of the standard numbers-and-dots notation for
	 Internet addresses: a.b.c.d specifies all four bytes of the address
	 individually; a.b.c interprets as a 2-byte quantity, which is useful for
	 specifying host addresses in a Class B network with network address number
	 a.b; a.b intrprets the last part of the address as a 3-byte quantity,
	 which is useful for specifying host addresses in a Class A network with
	 network address number a.
	 
	 If only one part is given, this corresponds directly to the host address
	 number."

	<category: 'instance creation'>
	| substrings |
	substrings := aString substrings: $..
	substrings := substrings collect: [:each | each asInteger].
	^self fromArray: substrings
    ]

    IPAddress class >> fromArray: parts [
	"Answer a new IPAddress from an array of numbers; the numbers
	 are to be thought as the dot-separated numbers in the standard
	 numbers-and-dots notation for IPv4 addresses."

	<category: 'instance creation'>
	| result last |
	result := ByteArray new: 4.

	"e.g. 2 parts (a.b): byte 1 are taken from a and b; byte
	 4 and 3 are bits 0-7 and 8-15 of c respectively; byte 2 is
	 whatever remains (bits 16-23 is the string is well-formed).
	 Handling (result at: parts size) specially simplifies
	 error checking."
	1 to: parts size - 1 do: [:i | result at: i put: (parts at: i) asInteger].
	last := (parts at: parts size) asInteger.
	result size to: parts size + 1
	    by: -1
	    do: 
		[:i | 
		result at: i put: last \\ 256.
		last := last // 256].
	result at: parts size put: last.
	^self fromBytes: result
    ]

    IPAddress class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    IPAddress class >> with: b1 with: b2 with: b3 with: b4 [
	"Answer a new IPAddress whose bytes (from most-significant
	 to least-significant) are in the parameters."

	<category: 'instance creation'>
	^self basicNew 
	    address: ((ByteArray 
		    with: b1
		    with: b2
		    with: b3
		    with: b4) makeReadOnly: true)
    ]

    IPAddress class >> isDigitAddress: aString [
	"Answer whether aString is a valid address in a.b.c.d form."

	<category: 'private'>
	| dots |
	dots := 0.
	(aString substrings: $.) do: 
		[:part | 
		dots := dots + 1.
		(part allSatisfy: [:each | each isDigit]) ifFalse: [^false].
		part asInteger > 255 ifTrue: [^false]].
	^dots = 4
    ]

    asByteArray [
	"Answer a read-only ByteArray of size four containing the
	 receiver's bytes in network order (big-endian)"

	<category: 'accessing'>
	^address
    ]

    addressClass [
	"Answer the `address class' of the receiver (see
	 IPAddress class>>#fromString:)"

	<category: 'accessing'>
	| net |
	net := address at: 1.
	net < 128 ifTrue: [^$A].
	net < 192 ifTrue: [^$B].
	net < 224 ifTrue: [^$C].
	^net < 240 ifTrue: [$D] ifFalse: [$E]
    ]

    host [
	"Answer an host number for the receiver; this is given by
	 the last three bytes for class A addresses, by the last
	 two bytes for class B addresses, else by the last byte."

	<category: 'accessing'>
	| net |
	net := address at: 1.
	net < 128 
	    ifTrue: 
		[^(address at: 4) + ((address at: 3) * 256) + ((address at: 2) * 65536)].
	net < 192 ifTrue: [^(address at: 4) + ((address at: 3) * 256)].
	^address at: 4
    ]

    network [
	"Answer a network number for the receiver; this is given by the
	 first three bytes for class C/D/E addresses, by the first two
	 bytes for class B addresses, else by the first byte."

	<category: 'accessing'>
	| net |
	net := address at: 1.
	net < 128 ifTrue: [^net].
	net < 192 ifTrue: [^net * 256 + (address at: 2)].
	^net * 65536 + ((address at: 2) * 256) + (address at: 2)
    ]

    subnet [
	"Answer an host number for the receiver; this is 0 for class A
	 addresses, while it is given by the last byte of the network
	 number for class B/C/D/E addresses."

	<category: 'accessing'>
	| net |
	net := address at: 1.
	net < 128 ifTrue: [^address at: 2].
	net < 192 ifTrue: [^address at: 3].
	^0
    ]

    isMulticast [
	"Answer whether the receiver reprensents an address reserved for
	 multicast datagram connections"

	<category: 'accessing'>
	^(address at: 1) between: 224 and: 239
	"^self addressClass == $D"
    ]

    printOn: aStream [
	"Print the receiver in dot notation."

	<category: 'printing'>
	address do: [:each | each printOn: aStream]
	    separatedBy: [aStream nextPut: $.]
    ]

    address: aByteArray [
	"Private - Set the ByteArray corresponding to the four parts of
	 the IP address in dot notation"

	<category: 'private'>
	address := aByteArray
    ]

    port: port [
	"Return a ByteArray containing a struct sockaddr for the given port
	 on the IP address represented by the receiver. Family = AF_INET."

	<category: 'private'>
	port < 0 | (port > 65535) ifTrue: [self error: 'port out of range'].
	^(ByteArray new: 16)
	    "Write sin_addr"
	    replaceFrom: 5
		to: 8
		with: address
		startingAt: 1;

	    "Write sin_len and sin_family = AF_INET"
	    at: 1 put: 16;
	    at: 2 put: self class addressFamily;

	    "Write sin_port in network order (big endian)"
	    at: 3 put: port // 256;
	    at: 4 put: (port bitAnd: 255);
	    yourself

    ]
]



SocketImpl subclass: TCPSocketImpl [
    
    <comment: '
Unless the application installs its own implementation, this is the
default socket implementation that will be used for IPv4 stream
sockets.  It uses C call-outs to implement standard BSD style sockets
of family AF_INET and type SOCK_STREAM.'>
    <category: 'Sockets-Protocols'>

    valueWithoutBuffering: aBlock [
        "Evaluate aBlock, ensuring that any data that it writes to the socket
         is sent immediately to the network."

        <category: 'socket options'>
        ^[self optionAt: self class tcpNodelay
	    level: self class ipprotoTcp
	    put: 1.
	aBlock value] ensure:
            [self optionAt: self class tcpNodelay
		level: self class ipprotoTcp
		put: 0]
    ]
]



MulticastSocketImpl subclass: UDPSocketImpl [
    
    <comment: '
Unless the application installs its own implementation, this is the
default socket implementation that will be used for IPv4 datagram
sockets.  It uses C call-outs to implement standard BSD style sockets
of family AF_INET and type SOCK_DGRAM.'>
    <category: 'Sockets-Protocols'>

    ipMulticastIf [
	"Answer the local device for a multicast socket (in the form of
	 an address)"

	<category: 'multicasting'>
	^self addressClass fromByteArray: (self 
		    optionAt: self ipMulticastIf
		    level: self class ipprotoIp
		    size: CInt sizeof)
    ]

    ipMulticastIf: interface [
	"Set the local device for a multicast socket (in the form of
	 an address, usually anyLocalAddress)"

	<category: 'multicasting'>
	self 
	    optionAt: self ipMulticastIf
	    level: self class ipprotoIp
	    put: interface
    ]

    join: ipAddress [
	"Join the multicast socket at the given address"

	<category: 'multicasting'>
	self primJoinLeave: ipAddress option: self ipAddMembership
    ]

    leave: ipAddress [
	"Leave the multicast socket at the given address"

	<category: 'multicasting'>
	self primJoinLeave: ipAddress option: self ipDropMembership
    ]

    primJoinLeave: ipAddress option: opt [
	"Private - Used to join or leave a multicast service."

	<category: 'multicasting'>
	| data |
	data := ByteArray new: IPAddress addressSize * 2.
	data
	    replaceFrom: 1
		to: IPAddress addressSize
		with: ipAddress asByteArray
		startingAt: 1;
	    replaceFrom: IPAddress addressSize + 1
		to: data size
		with: IPAddress anyLocalAddress asByteArray
		startingAt: 1.
	self 
	    optionAt: opt
	    level: self class ipprotoIp
	    put: data
    ]

    timeToLive [
	"Answer the time to live of the datagrams sent through the receiver
	 to a multicast socket."

	<category: 'multicasting'>
	^(self 
	    optionAt: self ipMulticastTtl
	    level: self class ipprotoIp
	    size: CInt sizeof) intAt: 1
    ]

    timeToLive: ttl [
	"Set the time to live of the datagrams sent through the receiver
	 to a multicast socket."

	<category: 'multicasting'>
	self 
	    optionAt: self ipMulticastTtl
	    level: self class ipprotoIp
	    put: ttl
    ]
]



RawSocketImpl subclass: ICMPSocketImpl [
    
    <comment: '
Unless the application installs its own implementation, this is the
default socket implementation that will be used for IPv4 raw
sockets.  It uses C call-outs to implement standard BSD style sockets
of family AF_INET, type SOCK_RAW, protocol IPPROTO_ICMP.'>
    <category: 'Sockets-Protocols'>

]

PK
     �Mh@9��t  t    IP6SocketImpl.stUT	 eqXO׊XOux �  �  "======================================================================
|
|   Smalltalk IPv6 addresses
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008 Free Software Foundation, Inc.
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



SocketAddress subclass: IP6Address [
    | address |
    
    <comment: '
This class models an IPv6 address.  It also acts as a factory for IPv6
stream (TCP), datagram (UDP) and raw sockets.'>
    <category: 'Sockets-Protocols'>

    IP6Address class >> initialize [
	"Set up the default implementation classes for the receiver"

	<category: 'initialization'>
	self defaultRawSocketImplClass: ICMP6SocketImpl.
	self defaultDatagramSocketImplClass: UDPSocketImpl.
	self defaultStreamSocketImplClass: TCPSocketImpl
    ]

    IP6Address class >> createLoopbackHost [
	"Answer an object representing the loopback host in the address
	 family for the receiver.  This is ::1 for IPv4."

	<category: 'initialization'>
	^(IP6Address fromBytes: #[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1])
	    name: '::1';
	    yourself
    ]

    IP6Address class >> createUnknownAddress [
	"Answer an object representing an unkown address in the address
	 family for the receiver"

	<category: 'initialization'>
	^(IP6Address fromBytes: #[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0])
	    name: '::0';
	    yourself
    ]

    IP6Address class >> aiFlags [
	<category: 'private'>
	^self aiV4mapped + self aiAll
    ]

    IP6Address class >> addressSize [
	"Answer the size of an IPv4 address."

	<category: 'constants'>
	^16
    ]

    IP6Address class >> version [
	"Answer the version of IP that the receiver implements."

	<category: 'constants'>
	^6
    ]

    IP6Address class >> fromBytes: aByteArray [
	"Answer a new IP6Address from a ByteArray containing the bytes
	 in the same order as the digit form: 131.175.6.2 would be
	 represented as #[131 175 6 2]."

	<category: 'instance creation'>
	^self basicNew 
	    address: ((aByteArray copyFrom: 1 to: 16) makeReadOnly: true)
    ]

    IP6Address class >> fromSockAddr: aByteArray port: portAdaptor [
	"Private - Answer a new IP6Address from a ByteArray containing a
	 C sockaddr_in structure.  The portAdaptor's value is changed
	 to contain the port that the structure refers to."

	<category: 'instance creation'>
	portAdaptor value: (aByteArray at: 3) * 256 + (aByteArray at: 4).
	^self fromBytes: (aByteArray copyFrom: 9 to: 24)
    ]

    IP6Address class >> invalidAddress [
	<category: 'private'>
	self error: 'invalid IPv6 address'
    ]

    IP6Address class >> readWordFrom: stream [
	<category: 'private'>
	| n |
	(stream atEnd or: [ stream peekFor: $: ])
	    ifTrue: [ self invalidAddress ].

	n := Integer readFrom: stream radix: 16.
	(n < 0 or: [ n > 65535 ]) ifTrue: [ self invalidAddress ].
	(stream atEnd or: [ stream peekFor: $: ]) ifTrue: [ ^n ].
	self invalidAddress
    ]

    IP6Address class >> fromString: aString [
	"Answer a new IP6Address from a String containing the requested
	 address in digit form."

	<category: 'instance creation'>
	| s n break count expected ipv4 i |
	n := WordArray new: 8.
	count := (aString occurrencesOf: $:) + 1.
	(aString includes: $.)
	    ifTrue: [
		ipv4 := IPAddress fromString: (aString copyAfterLast: $:).
		ipv4 := ipv4 asByteArray.
		n at: 7 put: ipv4 first * 256 + ipv4 second.
		n at: 8 put: ipv4 third * 256 + ipv4 fourth.
		count := count - 1.
		expected := 6 ]
	    ifFalse: [
		expected := 8 ].

	expected < count ifTrue: [ self invalidAddress ].

	i := 1.
	s := aString readStream.
	break := false.
	[ i > expected ] whileFalse: [
	    s atEnd ifTrue: [ self invalidAddress ].
	    (break not and: [ s peekFor: $: ])
		ifTrue: [
		    break := true.
		    i := i + expected - count + 1 ]
		ifFalse: [
		    n at: i put: (self readWordFrom: s).
		    i := i + 1 ] ].
	^self fromArray: n
    ]

    IP6Address class >> fromArray: parts [
	"Answer a new IP6Address from an array of numbers; the numbers
	 are to be thought as the colon-separated numbers in the standard
	 numbers-and-colons notation for IPv4 addresses."

	<category: 'instance creation'>
	| address |
	address := ByteArray new: 16.
	parts keysAndValuesDo: [ :i :each |
	    address at: i * 2 - 1 put: (each bitShift: -8).
	    address at: i * 2 put: (each bitAnd: 255) ].

	^self fromBytes: address
    ]

    IP6Address class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    IP6Address class >> isDigitAddress: aString [
	"Answer whether aString is a valid address in colon-separated form."

	<category: 'private'>
	^false
    ]

    asByteArray [
	"Answer a read-only ByteArray of size four containing the
	 receiver's bytes in network order (big-endian)"

	<category: 'accessing'>
	^address
    ]

    isMulticast [
	"Answer whether the receiver reprensents an address reserved for
	 multicast datagram connections"

	<category: 'accessing'>
	^address first = 255
    ]

    printOn: aStream [
	"Print the receiver in dot notation."

	<category: 'printing'>
	| n words format |
	n := 1.
	1 to: 16 do: [ :i |
	    (n = i and: [ (address at: n) = 0 ]) ifTrue: [ n := i + 1 ] ].

	n = 13 ifTrue: [
	    aStream nextPutAll: '::%1.%2.%3.%4' % (address copyFrom: 13).
	    ^self ].
	(n = 11 and: [ (address at: 11) = 255 and: [ (address at: 12) = 255 ]]) ifTrue: [ 
	    aStream nextPutAll: '::ffff:%1.%2.%3.%4' % (address copyFrom: 13).
	    ^self ].

	words := (1 to: 15 by: 2) collect: [ :i |
	    (((address at: i) * 256 + (address at: i + 1)) printString: 16)
		asLowercase ].

	format := n >= 15 ifTrue: [ '::%8' ] ifFalse: [ '%1:%2:%3:%4:%5:%6:%7:%8' ].
	aStream nextPutAll: format % words
    ]

    address: aByteArray [
	"Private - Set the ByteArray corresponding to the four parts of
	 the IP address in dot notation"

	<category: 'private'>
	address := aByteArray
    ]

    port: port [
	"Return a ByteArray containing a struct sockaddr for the given port
	 on the IP address represented by the receiver. Family = AF_INET6."

	<category: 'private'>
	port < 0 | (port > 65535) ifTrue: [self error: 'port out of range'].
	^(ByteArray new: 28)
	    "Write sin_addr"
	    replaceFrom: 9
		to: 24
		with: address
		startingAt: 1;

            "Write sin_len and sin_family = AF_INET6"
            at: 1 put: 28;
            at: 2 put: self class addressFamily;

	    "Write sin_port in network order (big endian)"
	    at: 3 put: port // 256;
	    at: 4 put: (port bitAnd: 255);
	    yourself

    ]
]



RawSocketImpl subclass: ICMP6SocketImpl [
    
    <comment: '
Unless the application installs its own implementation, this is the
default socket implementation that will be used for IPv6 raw
sockets.  It uses C call-outs to implement standard BSD style sockets
of family AF_INET, type SOCK_RAW, protocol IPPROTO_ICMPV6.'>
    <category: 'Sockets-Protocols'>

]


CStruct subclass: CSockAddrIn6Struct [
    <declaration: #(
		#(#sin6Family #short)
		#(#sin6Port #(#array #byte 2))
		#(#sin6Flowinfo #int)
		#(#sin6Addr #(#array #byte 16))
		#(#sin6ScopeId #int)) >
]

PK    �Mh@<]��  qg  	  ChangeLogUT	 eqXO׊XOux �  �  �<kS�Ȳ��_1�-06���
τ�$�B؜[u�r����"kT	��������a"��ڳ�H3===���{���G����%;���Q��'�ǇYRd6������N&*�x����A�W�4�|�nE0��F�`�PA��̘�y.�D�OB$�W�$`<	�HeG�l���D�ux��!�$T��E��l��B�/���E�o��M�L�n᣽�7>-�S�)�Z�'���,+�<�	�S����I����b!5��i\�����v�RiM ��o�����D�eB�UǙ X&�"Kp�_
Ŧp��\(�������AK�$�Y����#���"6��Y�p�\�Mǧf<A��aG�T2U��b�"7h)�H������P���g��'����]fb	Xg@���;�%�i��%�(�
�B��Sd�t	��9m6͢E�Gp<���Q�o�_4������"��KܪD��4h��#��	�p%�� ~9L�{���a��G���X��F�"�B {O�$�����;1Ye���U�"Ζ�b�����r>Sv���{��v�M�wMy{A�݌�X��$�C�"Q8�[dro��>$Y"Pĥ��r �d�Y��{�=~��J�$̀9 ��+RP,y�p
��G��t�iv���;���X!�#�4z��B����z�(45�ɣ�BбS�(�Ǹr�)T�ζl"&8g��D#�4��vu�x��v5)f,R�� V���]R2�<R�<���H&p��'��wv�����?vnN]�`��9
�*R��4�ޓ���J���x,Qj��J��o&x/�LvY�h`�W�����)V����"J4d�]�P���j��<�41�V<��fչM�5���W���a��*�2�6@��i�����e����Ph	֣�p�/H�����5��D�(2�
���-��ς-]Tw������j?/I-��D)�[%"b$@�J�#b�= �OQ>'@��H=�{L��m���rI�U�"�����(�.��E��=��歡�z��� �U��ʹu+��N�Q��0n��X��4Ѩv�p�i��n �e��9[�jH`�ػ5@4�i&����G`�#ؐX�<k�p�{�2���@��(-r�NG�g9��	iF5p�u��+��,үr�Ax��f:�������c�Ȧˍn�L���[����ێ�(�EP�脠��&3��~�^M�׳14��%�r���	0!*���s�(����" %��
y�/�gMuԅg����R�2��[ƈ(�|»����~v}s��30�Ȭ
�B<b�5%e
��0+��t�{)�S:Σ��EX�/�@½�C��G��v��H:a����G�_s�뉰�Cp�L�������7�;�� �;<��ݘǥ�7�B�Z�@[�g����8��h��K�-'ߠ�-��q���r��v��c؀���BѴ��j��R��T �>,�8
8��@��-t�]	z���`Q,
F��zr��� �����*仐H�[�`���u�@&	�5���0�9:XC~ �P�b|5���������p��7�ן��v!T�]��~JdN�]�$��`�"�Kp�'�D���|�����w����1C �_|���>?�A��xU6'���
횣���s,`����	�<�1����ݹ��ZR��?3��+��Qv"|Y�����,���>	�H�0^"���\G����S�S̵��~��c�✀3����.s�(bt�.ϝ� 5�9J>~�!w5�+S���V�ҏ�Т�3�^���kV��(�W�(-��3B,i�b�Y0#�TR$L����y�sgeU�:�٫ʴ��n��ӿ4�S�<��+����q=��H��>�8_<���#�ZAý�w�Uk�`����l}�r�y`: ���6w��,k���M�F�`����'t�ݳl�HhV9.���L8bK����cxϓ@�G�E�g�O��f o��Bf�.�����[Ә�)J����[�,��C�&R_�|�!eO1s��������7���J�@�@X�����kд��'�P�f����X%H?/��tic0j�Ъ���61�g½�A�(�}ʸ��0F;*��[��ubX�ѭc1L���jM_����aW�����JSd�)ǈ������㄃�!AG
źEA�Ə���N6�k}�������S�k͈#O��k�Up��!k&Qsqm�w0c��m�
0I����k�?E:Z�2�
Җ^�By����R� ���bRD^i\ULh*�$F�
E05*3/aY�]��F�iW����w	����4��IZ���8&�@9~�����0�$Y6�h�&�%��8[ӊ�7'�RɎ��}j7�O͏
��>����/�j���k�Gi!�d�)�����_��ò��ƥ,*��T�����6#���s6U��8���������������k����f"�7 ����0=�9r���R��	Q/�Φ|���ґ�?/fBM�℈��GQ�-�5�W�ݮNZG�F�a�:AOzp��i�b}?S����<L�����/e�%[A��ns2�U�����a�A8/���
�<�,�uD����4�9dO��'�		`$�}�����9���&�K7�SP7%�0/w
:��,�tJ��"���A�aYޛ��r7ZS��0h�ӧڴP	�B S�m!٪F�U3�SϾ��}����qb��Oo�a�Ñh�ة�ΝK_@ٗ-˜Xyb8�R�U���>��X�'+*�Z6N��y-�[^8��=$��m b��r�L��^ڧ����i�*}������x6c��8�";����V����<�eU�ĭCa�����f�!���Bn�G�K%/���k32F5�`q�tve뱂W����eǭb���j�����O��"��"tW�	�7��g��2��d��ŶQgae����^ )��$��|�S��$�vf-�bq�R�|��Y��i�yb�9�(6=`�I��dA����p�d{��~� �"��uk���Is`3�E�\e�i����%�=kP`F�m�1��֢j3v�lg��#��c�'�-��s�3#]*_Uu�W|]e�<K�D�P��ܡap���-RtT�d*4�3���ɒ�s������Z/ J_/p��0�;y�\�����d`�������:j����pp�A�G
�ԍ���jz��ԔR6�䉺,�Y������כ�hSLt�����������>���σќkr�Q�r��,,��x���:�S�*7�`� :%m[�e�e�Sc_����얤^����P�)��Av,�3�O�4��@,�S?�	������v�C
*:�T�өR0�D�3��"5\�m�uJ�[���N�I�Mݽ�AuG:�3��{TQ�݉�3��w{�G`��w�	D��h������%�K9��vL0�΁�d��Wx�܁�����lm���.Yo���VF���0����ç*,��j� D�t`���S$�2�M���j��}�K�W@�7zf�����y�f����.��f���$�b�ܱ��kX�"���/�5�-5mJ��s��Y�'��7�z��j��6�D�vjzA��Ta^��?��"�P[hRo�U[���_7����u[̊%��A�nэt� <����\m=b�F�ʝ�+P�Ο����e�sw�F�&��\��CҮ
��q��ZIc��틩��P���ݸX�y��������x�S�GB�f3�����b�CB��C8�06�!z����Z:	u�)�PQ�x�L1�ڡ��ǃ�&+�%ߵ��w����6�5m�y�P�G��1/����0�N���|RHE/�1�1/5��S��"�^R���Kvz��&R��F��&n�q)�6د��?��DI�wf�[?	Jl�v���o�ٶ.��;%�]��'���fũ��2��C��o�+�v����=�\1bG%SUڔ~��Z+��D3���Dw+N��=��������&�ǝ�BV��΁Q���@z����`�̈2� 4�Gi��Lu>�,�vеsˠg�uTk�Yk��]]�Is�N�_S�j��gʫR��q@Վ�Νvw��N �����(!���8�B�=PA�`�Vwu/�y�l|�3ZU^��%:�sp��x��z	3;�߫��.!1ˍ�T:��(��S�.�{O�\T�ٵ���6с�l�{�E]-x��]��ɉ��ȅ��
@7�a+������1��L�S�u\l��5T�p���nC0ثB���c���K��������YǢ�o��h�I��4`;wR�a�Cvֵo��������X3���ܰ=�Z\ƞ�)��x�u�U	V�V��H3��A6QN�r1�1��t�jWy&y��G��>���Kcb��o~����e��߳]SA���JYw"��T�V Pܭu��/8|!#~4����ċB�(_�g�m�6�@j� (�L��Wt+FW�L7��hIF!���%)FL�������vq�e|{�����줹`j��/�s
�T�)v�R"��� �Ef�Sm�aW7m�b{m����u�I^�5�RN\�Z�sN7�a/�TAY��G�O�|Y���[g���Fv��gX"[V�Aҽjj�\Q��<�`xH���Z�֨%�X�������U�������q&���iͫ�]s�|�a�,D6쩪Py�[��>g�o���7�8�{ .Q�7�V5��r���+	x���5*}����suP;+T�rWex��Z��*׮����L�T��x��;æ�Vv����]�P3 ���s,ă�ekϯ���A�`��m���B�Xi@��3�I�޺��h�x���/]���qp�vN�x�ࡾ���_U_����t7�r76᾵�3��>o곚R���0HaR��5�Kx�a���;:���K*�箟��@���r�:Wt�٬��&`��.�/ۦ��m�t�.V��;�fiQۊ�vK�h8��K�ٵޮu�a��eb)�QT�k�c�����nɗ�0'	��w�P.�B�g0��I1ӭ+���~d�8���j���\&?����8]05Ù�3�Qo~�8����AՍ? �j��$�d� C��!���ޟ����7SPi�F��R�s�z��l�E �`�@��q�
��ʻ��+$5��Z	Tg63j=�$��@�XwW�x�͵aM��uK��:l�zE���I����)�9u `���n/�����;o��c�R��B$g�>)ޟ�{J���X�_`�Ԓf�:�¡�o�������Azc�䤠�L/�G}�s���rB���U��h��ǩö�Z	�$0��������7<c�̗��<t$%I���D`#�&����]��]5��Y�,�]��99ǣFp��RD4!ǃwow~�J���x�τ.Q�A.e�E��cߪ/�φE@�I��X�+��h����GY���Y�6z�Wy��}Z=
�V��U�%Li��CL��5�I��?=����g��n�~����ê�F�A8o���w�۝��ǯ��^��Ϋs���H6y��	HU��1���e3%PoT�l��,bT��B�����T�:�^D�?A�\�(��x�0M�2���e+T���]�H���KH��i�e�ژ���H���Y��y��Kc[Z�o![Z�Թ��m+�K�$c�Ǖ�|��\��Tf�h�W��?Z�C��F��'�h��Բ%�Bߓ6�;��a��c!�ֆ�)��Xm|��_��{��wk�����1�]3��_��#p
̇���%�vg����Wμ��	���N�!K�W�N���OE�$���g�fS�*���K,�%���g��N1�r��S�g��������ҽ�zM_4Vo|c��wo�B�����Qs���X[�y����m�;�jЌ$�Q��+r�ո^أ��)i�I�(��M�Gu�eN��6����N�~�â���6c�V��S�ܟ`�]Pʱ���A4� x��\���-@�MW���,�^j72�.e#��k�e��,���'�:�iF}�'Z�=Y��+�߶eDj�^Lu�^��Y=̯ͷO)�~<��+��s�Z���o�vm��q�!N��W{p�zI����Һ�T"��u�VKpj2*f��Χ��r� ��J�I�H��qOP���2wH�g�H�n_���~�d�&�`��K���a |���B���$�܀��L_�^C��1��ﳻ�ʒ-'vzJ��J+���������p��^'=�e]�LU��\2�s�P�[�+ެ���,���F�걚�VG���>�ݢ�@������K��H�X�`��r>'oq�
t��
�G���i
�{��`��N������J�?�f:u�Tl�LH={��?���-𔻤�*�d�6P����>��Ȟ�c�X,�Y#Q��(�hK��W)HR�i��dٽ,N��+���zC流Ɏ<A+��$�@�����88����n��8?�]Xbm��H}s���|j�����5��Ea0$���Yt��,��	�e���T�� ��ǓIB�촠��t->���U��r���vO΢�}"� ��]�sA,��-��,���%���Q�+2����$�d�vl��w��������OA��5t�B�<|�.��5��Z|��?��r;[��~����+����LAc:gh�fP/�]1k�Mv��!�/����9�B�$>�mbϥ[���K�BL��S��s���h�Қx���&utpiO�u/������s�FM&���b��e\�����.��޼-)�dVG� ��/i�:�
��
|Mk������MMDl�t�`�爔��*A�6篬 X��Y��/�����Qԥ*਀��lWY �L�!LA΅�E��7&b`DV�q8C'�A1���t�NNi,���z]/;����Q�{y��knላ������dW_{���Q�W�=��h�=����.xRLT]*���n�����iKHA�-��T`�v��O��/�E�	�"��F@Ca�E�PK
     �Mh@�!��D  D    UnixSocketImpl.stUT	 eqXO׊XOux �  �  "======================================================================
|
|   Smalltalk AF_UNIX sockets
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
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



SocketAddress subclass: UnixAddress [
    
    <comment: '
This class represents an address for a machine using the AF_UNIX
address family.  Since this address family is only used for local
sockets, the class is a singleton; the filesystem path to the socket
is represented using the port argument to socket functions, as either
a String or a File object.
'>
    <category: 'Sockets-Protocols'>

    UnixAddress class [
	| uniqueInstance |

	initialize [
	    "Set up the default implementation classes for the receiver"

	    <category: 'initialization'>
	    self defaultDatagramSocketImplClass: UnixDatagramSocketImpl.
	    self defaultStreamSocketImplClass: UnixSocketImpl
	]

	uniqueInstance [
	    <category: 'instance creation'>
	    uniqueInstance isNil ifTrue: [ uniqueInstance := self new ].
	    ^uniqueInstance
        ]

	createLoopbackHost [
	    "Answer an object representing the loopback host in the address
	     family for the receiver.  This is 127.0.0.1 for IPv4."

	    <category: 'initialization'>
	    ^self uniqueInstance
        ]

	createUnknownAddress [
	    "Answer an object representing an unkown address in the address
	     family for the receiver"

	    <category: 'initialization'>
	    ^self uniqueInstance
        ]

	fromSockAddr: aByteArray port: portAdaptor [
	    "Private - Answer the unique UnixAddress instance, filling
	     in the portAdaptor's value from a ByteArray containing a
	     C sockaddr_in structure."

	    <category: 'instance creation'>
	    | s size |
	    size := aByteArray
		indexOf: 0 startingAt: 4 ifAbsent: [ aByteArray size + 1 ].
	    s := String new: size - 3.
	    s replaceFrom: 1 to: s size with: aByteArray startingAt: 3.
	    portAdaptor value: s.
	    ^self uniqueInstance
	]

	extractAddressesAfterLookup: result [
	    "Not implemented, DNS should not answer AF_UNIX addresses!"

	    self shouldNotImplement
        ]
    ]

    = aSocketAddress [
	"Answer whether the receiver and aSocketAddress represent
	 the same socket on the same machine."

	<category: 'accessing'>
	^self == aSocketAddress
    ]

    isMulticast [
	"Answer whether an address is reserved for multicast connections."

	<category: 'testing'>
	^false
    ]

    hash [
	"Answer an hash value for the receiver"

	<category: 'accessing'>
	^self class hash
    ]

    printOn: aStream [
	"Print the receiver in dot notation."

	<category: 'printing'>
	aStream nextPutAll: '[AF_UNIX address family]'
    ]

    port: port [
	"Return a ByteArray containing a struct sockaddr for the given port
	 on the IP address represented by the receiver. Family = AF_UNIX."

	<category: 'private'>
	| portString |
	portString := port asString.
	portString isEmpty
	    ifTrue: [self error: 'invalid socket path'].
	portString size > 108
	    ifTrue: [self error: 'socket path too long'].
	^(ByteArray new: 110)
            "Write sin_len and sin_family = AF_UNIX"
            at: 1 put: portString size + 3;
            at: 2 put: self class addressFamily;
	    replaceFrom: 3 to: portString size + 2 with: portString startingAt: 1;
	    yourself
    ]
]


SocketImpl subclass: UnixSocketImpl [
    
    <comment: '
This class represents a stream socket using the AF_UNIX address family.
It unlinks the filesystem path when the socket is closed.
'>
    
    <category: 'Sockets-Protocols'>

    activeSocketImplClass [
	"Return an implementation class to be used for the active socket
	 created when a connection is accepted by a listening socket.
	 Return SocketImpl, because the active socket should not delete
	 the socket file when it is closed."
	^SocketImpl
    ]

    close [
	<category: 'socket operations'>

	| port |
	port := localPort.
	[ super close ] ensure: [
	    port isNil ifFalse: [ port asFile remove ] ]
    ]
]

DatagramSocketImpl subclass: UnixDatagramSocketImpl [
    
    <comment: '
This class represents a datagram socket using the AF_UNIX address family.
It unlinks the filesystem path when the socket is closed.
'>
    
    <category: 'Sockets-Protocols'>

    close [
	<category: 'socket operations'>

	| port |
	port := localPort.
	[ super close ] ensure: [
	    port isNil ifFalse: [ port asFile remove ] ]
    ]
]
PK
     �Mh@w�)�  �    init.stUT	 eqXO׊XOux �  �  "======================================================================
|
|   Smalltalk sockets classes (initialization script).
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008 Free Software Foundation, Inc.
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



Eval [
    Socket initialize.
    DatagramSocket initialize.
    ServerSocket initialize.
    IPAddress initialize.
    IP6Address initialize.
    UnixAddress initialize.
    ObjectMemory addDependent: SocketAddress.
    SocketAddress update: #returnFromSnapshot.

    "Backwards compatibility."
    Sockets addSubspace: #TCP.
    Smalltalk at: #TCP put: Sockets.TCP.
]

PK
     �Mh@���A�#  �#    Tests.stUT	 eqXO׊XOux �  �  Stream subclass: DummyStream [
    <category: 'Sockets-Tests'>

    | n |
    DummyStream class >> new [ ^super new initialize ]
    initialize [ n := 0 ]
    nextPut: anObject [ n := n + 1 ]
    next: anInteger putAll: aCollection startingAt: pos [ n := n + anInteger ]
    size [ ^n ]
]

Socket class extend [

    microTest [
	"Extremely small test (try to receive SMTP header)"

	<category: 'tests'>
	| s |
	s := Socket remote: IPAddress anyLocalAddress port: 25.
	(s upTo: Character cr) printNl.
	s close
    ]

    testPort2For: anAddressClass [
	<category: 'tests'>
	anAddressClass == UnixAddress ifTrue: [ ^'/tmp/gst.test2' ].
	^54322
    ]
	
    testPortFor: anAddressClass [
	<category: 'tests'>
	anAddressClass == UnixAddress ifTrue: [ ^'/tmp/gst.test' ].
	^54321
    ]
	
    tweakedLoopbackTest [
	"Send data from one socket to another on the local machine, trying to avoid
	 buffering overhead.  Tests most of the socket primitives.  Comparison of
	 the results of loopbackTest and tweakedLoopbackTest should give a measure
	 of the overhead of buffering when sending/receiving large quantities of
	 data."

	<category: 'tests'>
	^self loopbackTest: #(5000 4000)
    ]

    loopbackTest [
	"Send data from one socket to another on the local machine. Tests most of
	 the socket primitives."

	<category: 'tests'>
	^self loopbackTest: nil
    ]

    loopbackTest: bufferSizes [
	"Send data from one socket to another on the local machine. Tests most of
	 the socket primitives.  The parameter is the size of the input and
	 output buffer sizes."

	<category: 'tests'>
	^self loopbackTest: bufferSizes addressClass: Socket defaultAddressClass
    ]

    loopbackTestOn: addressClass [
	"Send data from one socket to another on the local machine. Tests most of
	 the socket primitives.  The parameter is the address class (family)
	 to use."

	<category: 'tests'>
	^self loopbackTest: nil addressClass: addressClass
    ]

    loopbackTest: bufferSizes addressClass: addressClass [
	"Send data from one socket to another on the local machine. Tests most of
	 the socket primitives.  The parameters are the size of the input and
	 output buffer sizes, and the address class (family) to use."

	<category: 'tests'>
	| queue server client bytesToSend sendBuf bytesSent bytesReceived
	  t extraBytes timeout process recvBuf |
	Transcript
	    cr;
	    show: 'starting loopback test';
	    cr.
	queue := ServerSocket 
		    port: (self testPortFor: addressClass)
		    queueSize: 5
		    bindTo: addressClass loopbackHost.
	client := Socket remote: queue localAddress port: (self testPortFor: addressClass).
	bufferSizes isNil 
	    ifFalse: 
		[client
		    readBufferSize: (bufferSizes at: 1);
		    writeBufferSize: (bufferSizes at: 2)].
	timeout := false.
	process := 
		[(Delay forMilliseconds: Socket timeout) wait.
		timeout := true] fork.
	
	[timeout ifTrue: [self error: 'could not establish connection'].
	(server := queue accept: StreamSocket) isNil] 
		whileTrue: [Processor yield].
	process terminate.
	Transcript
	    show: 'connection established';
	    cr.
	bytesToSend := 5000000.
	sendBuf := String new: 4000 withAll: $x.
	recvBuf := DummyStream new.
	bytesSent := bytesReceived := 0.
	t := Time millisecondsToRun: 
			[
			[server nextPutAll: sendBuf.
			bytesSent := bytesSent + sendBuf size.
			[client canRead] whileTrue: 
				[client nextAvailablePutAllOn: recvBuf.
				bytesReceived := recvBuf size].
			bytesSent >= bytesToSend and: [bytesReceived = bytesSent]] 
				whileFalse].
	Transcript
	    show: 'closing connection';
	    cr.
	extraBytes := client bufferContents size.
	server close.
	extraBytes > 0 
	    ifTrue: 
		[Transcript
		    show: ' *** received ' , extraBytes size printString , ' extra bytes ***';
		    cr].
	client close.
	queue close.
	Transcript
	    show: 'loopback test done; ' , (t / 1000.0) printString , ' seconds';
	    cr;
	    show: (bytesToSend asFloat / t roundTo: 0.01) printString;
	    showCr: ' kBytes/sec'
    ]

    producerConsumerTest [
	"Send data from one datagram socket to another on the local machine. Tests most of the
	 socket primitives and works with different processes."

	<category: 'tests'>
	^self producerConsumerTestOn: Socket defaultAddressClass
    ]

    producerConsumerTestOn: addressClass [
	"Send data from one socket to another on the local machine. Tests most of the
	 socket primitives and works with different processes."

	<category: 'tests'>
	| bytesToSend bytesSent bytesReceived t server client queue sema producer consumer queueReady |
	Transcript
	    cr;
	    show: 'starting loopback test';
	    cr.
	sema := Semaphore new.
	queueReady := Semaphore new.
	bytesToSend := 5000000.
	bytesSent := bytesReceived := 0.
	t := Time millisecondsToRun: 
			[producer := 
				[| timeout process sendBuf |
				queue := ServerSocket 
					    port: (self testPortFor: addressClass)
					    queueSize: 5
					    bindTo: addressClass loopbackHost.
				queueReady signal.
				timeout := false.
				process := 
					[(Delay forMilliseconds: Socket timeout) wait.
					timeout := true] fork.
				
				[timeout ifTrue: [self error: 'could not establish connection'].
				(server := queue accept ": StreamSocket") isNil] 
					whileTrue: [Processor yield].
				process terminate.
				Transcript
				    show: 'connection established';
				    cr.
				sendBuf := String new: 4000 withAll: $x.
				
				[server nextPutAll: sendBuf.
				bytesSent := bytesSent + sendBuf size.
				bytesSent >= bytesToSend] 
					whileFalse: [Processor yield].
				sema signal] 
					fork.
			consumer := 
				[| recvBuf |
				recvBuf := DummyStream new.
				queueReady wait.
				client := Socket remote: queue localAddress port: (self testPortFor: addressClass).
				
				[[client canRead] whileTrue: 
					[client nextAvailablePutAllOn: recvBuf.
					bytesReceived := recvBuf size].
				bytesSent >= bytesToSend and: [bytesReceived = bytesSent]] 
					whileFalse: [Processor yield].
				sema signal] 
					fork.
			sema wait.
			sema wait].
	Transcript
	    show: 'closing connection';
	    cr.
	server close.
	client close.
	queue close.
	Transcript
	    show: 'loopback test done; ' , (t / 1000.0) printString , ' seconds';
	    cr;
	    show: (bytesToSend asFloat / t roundTo: 0.01) printString;
	    showCr: ' kBytes/sec'
    ]

    datagramLoopbackTest [
	"Send data from one datagram socket to another on the local machine. Tests most of the
	 socket primitives and works with different processes."

	<category: 'tests'>
	^self datagramLoopbackTestOn: Socket defaultAddressClass
    ]

    datagramLoopbackTestOn: addressClass [
	"Send data from one datagram socket to another on the local machine. Tests most of the
	 socket primitives and works with different processes."

	<category: 'tests'>
	| bytesToSend bytesSent bytesReceived t |
	Transcript
	    cr;
	    show: 'starting datagram loopback test';
	    cr.
	bytesToSend := 5000000.
	bytesSent := bytesReceived := 0.
	t := Time millisecondsToRun: 
			[| server client datagram |
			client := DatagramSocket
				    local: addressClass loopbackHost
				    port: (self testPort2For: addressClass).
			server := DatagramSocket 
				    remote: addressClass loopbackHost
				    port: (self testPort2For: addressClass)
				    local: nil
				    port: (self testPortFor: addressClass).
			datagram := Datagram data: (String new: 128 withAll: $x) asByteArray.
			
			[server
			    nextPut: datagram;
			    flush.
			bytesSent := bytesSent + datagram data size.
			[client canRead] 
			    whileTrue: [bytesReceived := bytesReceived + client next data size].
			bytesReceived < bytesToSend] 
				whileTrue.
			Transcript
			    show: 'closing connection';
			    cr.
			server close.
			client close].
	Transcript
	    show: 'udp loopback test done; ' , (t / 1000.0) printString , ' seconds';
	    cr;
	    show: '% packets lost ' 
			, (100 - (bytesReceived / bytesSent * 100)) asFloat printString;
	    cr;
	    show: (bytesToSend asFloat / t roundTo: 0.01) printString;
	    showCr: ' kBytes/sec'
    ]

    sendTest [
	"Send data to the 'discard' socket of localhost."

	<category: 'tests'>
	^self sendTest: '127.0.0.1'
    ]

    sendTest: host [
	"Send data to the 'discard' socket of the given host. Tests the speed of
	 one-way data transfers across the network to the given host. Note that
	 many hosts do not run a discard server."

	"Socket sendTest: 'localhost'"

	<category: 'tests'>
	| sock bytesToSend sendBuf bytesSent t |
	Transcript
	    cr;
	    show: 'starting send test';
	    cr.
	sock := Socket remote: host port: Socket portDiscard.
	Transcript
	    show: 'connection established';
	    cr.
	bytesToSend := 5000000.
	sendBuf := String new: 4000 withAll: $x.
	bytesSent := 0.
	t := Time millisecondsToRun: 
			[[bytesSent < bytesToSend] whileTrue: 
				[sock
				    nextPutAll: sendBuf;
				    flush.
				bytesSent := bytesSent + sendBuf size]].
	Transcript
	    show: 'closing connection';
	    cr.
	sock close.
	Transcript
	    show: 'send test done; time = ' , (t / 1000.0) printString, ' seconds';
	    cr;
	    show: (bytesToSend asFloat / t) printString;
	    showCr: ' kBytes/sec'
    ]

]

PK
     �Mh@"|�
  �
    UnitTest.stUT	 eqXO׊XOux �  �  "======================================================================
|
|   SUnit Test Cases for the Socket Code
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2011 Free Software Foundation, Inc.
| Written by Holger Hans Peter Freyther.
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

TestCase subclass: SocketTest [
    testDoNotCrashOnSendto [
        "
         The objective of this test is to check if the c code is
         crashing with 'invalid' input.
        "
        | socket addrLen datagram |
        socket := DatagramSocket new.

	"Passing the wrong bits to the call out will abort."
	addrLen := CInt gcValue: 0.
        socket implementation
            accept: -1 peer: nil addrLen: addrLen;
            bind: -1 to: nil addrLen: 0;
            connect: -1 to: nil addrLen: 0;
            getPeerName: -1 addr: nil addrLen: addrLen;
            getSockName: -1 addr: nil addrLen: addrLen;
            receive: -1 buffer: nil size: 0 flags: 0 from: nil size: addrLen.

	"Pass a datagram with no destination."
	datagram := Datagram new.
	socket nextPut: datagram.
    ]

    testDoNotCrashWithWrongTypes [
        "The objective is to see if wrong types for a cCallout will
         make the VM crash or not. It should also check if these calls
         raise the appropriate exception."
        | socket impl |

        socket := DatagramSocket new.
        impl := socket implementation.

        self should: [impl accept: -1 peer: nil addrLen: 0] raise: SystemExceptions.PrimitiveFailed.
        self should: [impl getPeerName: -1 addr: nil addrLen: 0] raise: SystemExceptions.PrimitiveFailed.
        self should: [impl getSockName: -1 addr: nil addrLen: 0] raise: SystemExceptions.PrimitiveFailed.
        self should: [impl receive: -1 buffer: nil size: 0 flags: 0 from: nil size: 0] raise: SystemExceptions.PrimitiveFailed.
    ]
]
PK
     �Mh@>5�e6  e6            ��    SocketAddress.stUT eqXOux �  �  PK
     �Mh@�k�K!  K!  	          ���6  cfuncs.stUT eqXOux �  �  PK
     �Mh@ F�?˖  ˖  
          ��=X  Sockets.stUT eqXOux �  �  PK
     \h@�pz��  �            ��L�  package.xmlUT ׊XOux �  �  PK
     �Mh@�Ji�  �  
          ��S�  Buffers.stUT eqXOux �  �  PK
     �Mh@���4S  4S            ��8 AbstractSocketImpl.stUT eqXOux �  �  PK
     �Mh@i�M�R  R            ���a Datagram.stUT eqXOux �  �  PK
     �Mh@~�$�V6  V6            ��Rw IPSocketImpl.stUT eqXOux �  �  PK
     �Mh@9��t  t            ��� IP6SocketImpl.stUT eqXOux �  �  PK    �Mh@<]��  qg  	         ���� ChangeLogUT eqXOux �  �  PK
     �Mh@�!��D  D            ���� UnixSocketImpl.stUT eqXOux �  �  PK
     �Mh@w�)�  �            ��T� init.stUT eqXOux �  �  PK
     �Mh@���A�#  �#            ��( Tests.stUT eqXOux �  �  PK
     �Mh@"|�
  �
            ��)* UnitTest.stUT eqXOux �  �  PK        /5   