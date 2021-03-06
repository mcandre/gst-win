PK
     �Mh@�/�a  a    Core.stUT	 eqXOՊXOux �  �  "======================================================================
|
|   Swazoo 2.1 core
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: SwazooResource [
    | enabled uriPattern parent |
    
    <category: 'Swazoo-Core'>
    <comment: 'Resource is an abstract class for all so called web resources. Such resource has its url address and can serve with responding to web requests. Every resource need to #answerTo: aHTTPRequest with aHTTPResponse. Site is a subclass of a Resource. You can subclass it with your own implementation. There is also a CompositeResource, which can hold many subresources. Site is also aCopmpositeResource and therefore you can add your own resources to your site.'>

    SwazooResource class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    SwazooResource class >> uriPattern: aString [
	<category: 'instance creation'>
	^self new uriPattern: aString
    ]

    answerTo: aRequest [
	"override in your Resource and return a HTTPResponse"

	<category: 'serving'>
	^nil
    ]

    authenticationRealm [
	"rfc2617 3.2.1: A string to be displayed to users so they know which username and
	 password to use. This string should contain at least the name of
	 the host performing the authentication and might additionally
	 indicate the collection of users who might have access. An example
	 might be 'registered_users@gotham.news.com'"

	<category: 'authentication'>
	^'Swazoo server'
    ]

    authenticationScheme [
	"#Basic or #Digest, see rfc2617. Digest is recomended because password
	 goes encrypted to server"

	<category: 'authentication'>
	^#Digest
    ]

    canAnswer [
	<category: 'testing'>
	^self isEnabled and: [self isValidlyConfigured]
    ]

    currentUrl [
	<category: 'accessing'>
	| stream |
	stream := WriteStream on: String new.
	self printUrlOn: stream.
	^stream contents
    ]

    disable [
	<category: 'start/stop'>
	enabled := false
    ]

    enable [
	<category: 'start/stop'>
	enabled := true
    ]

    helpResolve: aResolution [
	<category: 'accessing'>
	^aResolution resolveLeafResource: self
    ]

    initUriPattern [
	<category: 'private-initialize'>
	self uriPattern: ''
    ]

    initialize [
	<category: 'private-initialize'>
	self enable.
	self initUriPattern
    ]

    isEnabled [
	<category: 'testing'>
	^enabled
    ]

    isValidlyConfigured [
	<category: 'testing'>
	^self uriPattern ~= ''
    ]

    match: anIdentifier [
	<category: 'private'>
	^self uriPattern = anIdentifier
    ]

    onResourceCreated [
	"Received after the resource has been added to its parent resource. Opportunity to perform initialization that depends on knowledge of the resource tree structure"

	<category: 'private-initialize'>
	
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    parent: aResource [
	<category: 'private'>
	parent := aResource
    ]

    printUrlOn: aWriteStream [
	<category: 'accessing'>
	self parent printUrlOn: aWriteStream.
	aWriteStream nextPutAll: self uriPattern
    ]

    root [
	<category: 'accessing'>
	^self parent isNil ifTrue: [self] ifFalse: [self parent root]
    ]

    start [
	<category: 'start/stop'>
	
    ]

    stop [
	<category: 'start/stop'>
	
    ]

    unauthorizedResponse [
	"Resource should call this method and return its result immediately, if request is not authorized
	 to access that resource and a HTTP authorization is needed"

	"^HTTPAuthenticationChallenge newForResource: self"

	<category: 'authentication'>
	
    ]

    unauthorizedResponsePage [
	"Resource should override this method with it's own html message"

	<category: 'authentication'>
	^'<HTML>
  <HEAD>
    <TITLE>Authentication error</TITLE>
  </HEAD>
  <BODY>
    <H1>401 Authentication error</H1>
    <P>Bad username or password</P>
  </BODY>
</HTML>'
    ]

    uriPattern [
	<category: 'accessing'>
	^uriPattern
    ]

    uriPattern: anIdentifier [
	<category: 'accessing'>
	anIdentifier notNil ifTrue: [uriPattern := anIdentifier]
    ]
]



SwazooResource subclass: CompositeResource [
    | children |
    
    <category: 'Swazoo-Core'>
    <comment: nil>

    addResource: aResource [
	<category: 'adding/removing'>
	self children add: aResource.
	aResource parent: self.
	aResource onResourceCreated.
	^aResource
    ]

    addResources: anOrderedCollection [
	<category: 'adding/removing'>
	anOrderedCollection do: [:each | self addResource: each].
	^anOrderedCollection
    ]

    children [
	<category: 'accessing'>
	children isNil ifTrue: [self initChildren].
	^children
    ]

    currentUrl [
	<category: 'accessing'>
	| string |
	string := super currentUrl.
	^string last = $/ ifTrue: [string] ifFalse: [string , '/']
    ]

    hasNoResources [
	<category: 'testing'>
	^self children isEmpty
    ]

    helpResolve: aResolution [
	<category: 'accessing'>
	^aResolution resolveCompositeResource: self
    ]

    includesResource: aResource [
	<category: 'testing'>
	^self children includes: aResource
    ]

    initChildren [
	<category: 'initialize-release'>
	children := OrderedCollection new
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	self initChildren
    ]

    isRootPath [
	<category: 'testing'>
	^self uriPattern = '/'
    ]

    match: anIdentifier [
	<category: 'private'>
	^self uriPattern match: anIdentifier
    ]

    printUrlOn: aWriteStream [
	<category: 'accessing'>
	super printUrlOn: aWriteStream.
	self isRootPath ifFalse: [aWriteStream nextPut: $/]
    ]

    removeResource: aResource [
	<category: 'adding/removing'>
	self children remove: aResource ifAbsent: [nil]
    ]
]



CompositeResource subclass: SwazooSite [
    | name serving |
    
    <category: 'Swazoo-Core'>
    <comment: 'Site : Swazoo can serve many sites at once (virtual sites). Class Site is therefore a main class to start configuring your server. It holds an IP, port and hostname of your site.'>

    SwazooSite class >> named: aString [
	"return a website with that name"

	<category: 'accessing'>
	^SwazooServer singleton siteNamed: aString
    ]

    SwazooSite class >> newNamed: aString [
	<category: 'instance creation'>
	| site |
	site := self new name: aString.
	SwazooServer singleton addSite: site.
	site initialize.
	^site
    ]

    addAlias: anAlias [
	<category: 'accessing'>
	self uriPattern add: anAlias
    ]

    aliases [
	<category: 'accessing'>
	^self uriPattern
    ]

    compile: tag [
	<category: 'config-from-file'>
	^SwazooCompiler evaluate: tag
    ]

    helpResolve: aResolution [
	<category: 'private'>
	^aResolution resolveSite: self
    ]

    host [
	"hostname of this site. Example: www.ibm.com.
	 hostname must be unique on that server.
	 Don't mix with ip, which also can be something like www.ibm.com.
	 There can be many sites with different hostnames on the same ip !!"

	<category: 'accessing'>
	^self uriIdentifier host
    ]

    host: aString [
	<category: 'private'>
	self uriIdentifier host: aString
    ]

    host: aHostString ip: anIPString port: aNumber [
	"see comments in methods host and ip !!"

	"hostname must be unique!!"

	<category: 'accessing'>
	| site |
	site := SwazooServer singleton siteHostnamed: aHostString.
	(site notNil and: [site ~= self]) 
	    ifTrue: [^SwazooSiteError error: 'Site with that hostname already exist!'].
	self uriIdentifier 
	    setIp: anIPString
	    port: aNumber
	    host: aHostString
    ]

    host: aHostString port: aNumber [
	"run on all ip interfaces on specified port"

	"hostname must be unique!!"

	<category: 'accessing'>
	self 
	    host: aHostString
	    ip: '*'
	    port: aNumber
    ]

    initUriPattern [
	<category: 'initialize-release'>
	self uriPattern: OrderedCollection new.
    ]

    initialize [
	<category: 'initialize-release'>
	super initialize.
	self stop.	"in case you initialize working site"
	self initUriPattern
    ]

    ip [
	"IP address of this site. Swazoo can have virtual sites, that is, more than one
	 site can share the same ip and port!!
	 IP can be a number or full DNS name. For example: server.ibm.com or 234.12.45.66"

	<category: 'accessing'>
	^self uriIdentifier ip
    ]

    ip: aString [
	<category: 'private'>
	self uriIdentifier ip: aString
    ]

    isRootPath [
	<category: 'testing'>
	^false
    ]

    isServing [
	"is this site on-line?"

	<category: 'testing'>
	^serving notNil and: [serving]
    ]

    match: aRequest [
	<category: 'private'>
	self uriPattern detect: [:each | each requestMatch: aRequest]
	    ifNone: [^false].
	^true
    ]

    name [
	"a short name of that site. Example: for host www.ibm.com, name it ibm"

	<category: 'accessing'>
	name isNil ifTrue: [^''].
	^name
    ]

    name: aString [
	"a short name of that site. Example: for host www.ibm.com, name it ibm"

	"name must be unique"

	<category: 'accessing'>
	(SwazooServer singleton siteNamed: aString) notNil 
	    ifTrue: [^SwazooSiteError error: 'Site with that name already exist!'].
	name := aString
    ]

    nextTagFrom: aStream [
	<category: 'config-from-file'>
	aStream upTo: $<.
	^aStream atEnd ifTrue: [nil] ifFalse: [aStream upTo: $>]
    ]

    onAllInterfaces [
	"site is running on all machine's IP interfaces"

	<category: 'testing'>
	^self ip = '*' or: [self ip = '0.0.0.0']
    ]

    onAnyHost [
	"site don't care about host name during url resolution"

	<category: 'testing'>
	^self host = '*'
    ]

    port [
	<category: 'accessing'>
	^self uriIdentifier port
    ]

    port: aNumber [
	<category: 'private'>
	self uriIdentifier port: aNumber
    ]

    printUrlOn: aWriteStream [
	<category: 'private'>
	self uriIdentifier printUrlOn: aWriteStream
    ]

    readCompositeFrom: aStream storingInto: aComposite [
	<category: 'config-from-file'>
	| tag |
	
	[tag := self nextTagFrom: aStream.
	tag = '/CompositeResource'] 
		whileFalse: 
		    [| thingy |
		    thingy := self compile: tag.
		    aComposite addResource: thingy.
		    (thingy isKindOf: CompositeResource) 
			ifTrue: [self readCompositeFrom: aStream storingInto: thingy]]
    ]

    readFrom: aStream [
	"read configuration from an XML file, see sites.cnf"

	<category: 'config-from-file'>
	| tag |
	tag := self nextTagFrom: aStream.
	tag isNil ifTrue: [^nil].
	tag = 'Site' 
	    ifFalse: [^SwazooSiteError error: 'invalid site specification!'].
	
	[tag := self nextTagFrom: aStream.
	tag = '/Site'] whileFalse: 
		    [| thingy |
		    thingy := self compile: tag.
		    (thingy isKindOf: SiteIdentifier) 
			ifTrue: [self addAlias: thingy]
			ifFalse: 
			    [self addResource: thingy.
			    (thingy isKindOf: CompositeResource) 
				ifTrue: [self readCompositeFrom: aStream storingInto: thingy]]]
    ]

    serving: aBoolean [
	<category: 'private'>
	serving := aBoolean
    ]

    sslPort: aNumber [
	<category: 'accessing'>
	self uriPattern size < 2 
	    ifTrue: [self uriPattern add: SSLSiteIdentifier new].
	(self uriPattern at: 2) 
	    setIp: self ip
	    port: aNumber
	    host: self host
    ]

    start [
	<category: 'start/stop'>
	| swazoo |
	swazoo := SwazooServer singleton.
	
	[self aliases do: 
		[:each | 
		| httpServer |
		httpServer := swazoo serverFor: each.	"it will also create and start it if needed"
		httpServer addSite: self]] 
		ifCurtailed: [self stop].
	self serving: true
    ]

    stop [
	<category: 'start/stop'>
	| swazoo |
	swazoo := SwazooServer singleton.
	self aliases do: 
		[:each | 
		| httpServer |
		httpServer := swazoo serverFor: each.
		(swazoo servers includes: httpServer) 
		    ifTrue: 
			[httpServer removeSite: self.
			httpServer hasNoSites 
			    ifTrue: 
				[swazoo removeServer: httpServer.
				httpServer stop]]].
	self serving: false
    ]

    uriIdentifier [
	<category: 'private'>
	self uriPattern isEmpty ifTrue: [self uriPattern add: SiteIdentifier new].
	^self uriPattern first
    ]

    uriPattern [
	<category: 'private'>
	uriPattern isNil ifTrue: [self initUriPattern].
	^uriPattern
    ]

    watchdogAction [
	"override in your subclass"

	<category: 'private'>
	
    ]
]



Object subclass: SwazooServer [
    | sites servers watchdog |
    
    <category: 'Swazoo-Core'>
    <comment: 'SwazooServer is where all begins in Swazoo!
SwazooServer singleton : return one and only one server which holds the Sites. Also used to start and stop all sites ato once, to add new sited etc. When running, a collection of HTTPServers is also stored in SwazooServer singleton.

SwazooServer demoStart  will create and run a demo site on http://localhost:8888 which 
                              returns a web page with ''Hello World!'''>

    Singleton := nil.

    SwazooServer class >> configureFrom: aFilenameString [
	<category: 'config-from-file'>
	| sites stream |
	self singleton removeAllSites.
	stream := aFilenameString asFilename readStream.
	[sites := self readSitesFrom: stream] ensure: [stream close].
	sites do: 
		[:each | 
		self singleton addSite: each.
		each start]
    ]

    SwazooServer class >> demoStart [
	"on http://localhost:8888/ will return simple 'Hello World'"

	<category: 'start/stop'>
	| site |
	site := self singleton siteNamed: 'swazoodemo'.
	site isNil ifTrue: [site := self singleton prepareDemoSite].
	site start
    ]

    SwazooServer class >> demoStop [
	<category: 'start/stop'>
	self stopSite: 'swazoodemo'
    ]

    SwazooServer class >> exampleConfigurationFile [
	"example sites.cnf, which will serve static files from current directory and respond with
	 'Hello Worlrd' from url http://localhost:8888/foo/Howdy"

	"<Site>
	 <SiteIdentifier ip: '127.0.0.1' port: 8888 host: 'localhost' >
	 <CompositeResource uriPattern: '/'>
	 <CompositeResource uriPattern: 'foo'>
	 <HelloWorldResource uriPattern: 'Howdy'>
	 </CompositeResource>
	 </CompositeResource>
	 <FileResource uriPattern: '/' filePath: '.'>
	 </Site>"

	<category: 'config-from-file'>
	
    ]

    SwazooServer class >> initSingleton [
	<category: 'private'>
	Singleton := super new
    ]

    SwazooServer class >> initialize [
	"self initialize"

	<category: 'initialize'>
	SpEnvironment addImageStartupTask: [self singleton restartServers]
	    for: self singleton
    ]

    SwazooServer class >> new [
	<category: 'private'>
	^self shouldNotImplement
    ]

    SwazooServer class >> readSitesFrom: aStream [
	<category: 'private'>
	| sites instance |
	sites := OrderedCollection new.
	
	[instance := SwazooSite new readFrom: aStream.
	instance notNil] 
		whileTrue: [sites add: instance].
	^sites
    ]

    SwazooServer class >> restart [
	<category: 'start/stop'>
	self
	    stop;
	    start
    ]

    SwazooServer class >> singleton [
	<category: 'accessing'>
	Singleton isNil ifTrue: [self initSingleton].
	^Singleton
    ]

    SwazooServer class >> siteHostnamed: aString [
	<category: 'accessing'>
	^self singleton siteHostnamed: aString
    ]

    SwazooServer class >> siteNamed: aString [
	<category: 'accessing'>
	^self singleton siteNamed: aString
    ]

    SwazooServer class >> start [
	"start all sites"

	<category: 'start/stop'>
	self singleton start
    ]

    SwazooServer class >> startOn: aPortNumber [
	"start a site on that port, on all ip interfaces and accepting all hosts.
	 It also created a site if there is any site on that port yet"

	<category: 'start/stop'>
	^self singleton startOn: aPortNumber
    ]

    SwazooServer class >> startSite: aString [
	"start site with that name"

	<category: 'start/stop'>
	self singleton startSite: aString
    ]

    SwazooServer class >> stop [
	"stop all sites"

	<category: 'start/stop'>
	self singleton stop
    ]

    SwazooServer class >> stopOn: aPortNumber [
	"stop a site on that port, if any runingon all ip interfaces and accepting all hosts."

	<category: 'start/stop'>
	^self singleton stopOn: aPortNumber
    ]

    SwazooServer class >> stopSite: aString [
	"stop site with that name"

	<category: 'start/stop'>
	self singleton stopSite: aString
    ]

    SwazooServer class >> swazooVersion [
	<category: 'accessing'>
	^'Swazoo 2.2 Smalltalk Web Server'
    ]

    addServer: aHTTPServer [
	<category: 'private-servers'>
	^self servers add: aHTTPServer
    ]

    addSite: aSite [
	<category: 'adding/removing'>
	(self siteNamed: aSite name) notNil 
	    ifTrue: [^SwazooSiteError error: 'Site with that name already exist!'].
	(self siteHostnamed: aSite host) notNil 
	    ifTrue: [^SwazooSiteError error: 'Site host name must be unique!'].
	(self 
	    hasSiteHostnamed: aSite host
	    ip: aSite ip
	    port: aSite port) 
		ifTrue: 
		    [^SwazooSiteError 
			error: 'Site with that host:ip:port combination already exist!'].
	(self allowedHostIPPortFor: aSite) 
	    ifFalse: 
		[^SwazooSiteError 
		    error: 'Site with such host:ip:port combination not allowed!'].
	self sites add: aSite
    ]

    allSites [
	<category: 'accessing'>
	^self sites copy
    ]

    allowedHostIPPortFor: aSite [
	"is host:ip:port combination of aSite allowed regarding to existing sites?"

	"rules:
	 1. host name must be unique, except if it is * (anyHost)
	 2. only one site per port can run on any host and all IP interfaces (ip = * or 0.0.0.0)
	 3. if there is a site runing on all IPs, then no one can run on specific ip, per port
	 4. 3 vice versa
	 5. there is no site with the same host ip port combination
	 "

	<category: 'private'>
	(self siteHostnamed: aSite host) notNil ifTrue: [^false].
	(aSite onAllInterfaces and: [self hasSiteOnPort: aSite port]) 
	    ifTrue: [^false].
	(aSite onAllInterfaces not 
	    and: [self hasSiteOnAllInterfacesOnPort: aSite port]) ifTrue: [^false].
	(self 
	    hasSiteHostnamed: aSite host
	    ip: aSite ip
	    port: aSite port) ifTrue: [^false].
	^true
    ]

    hasSiteHostnamed: aHostname ip: ipString port: aNumber [
	<category: 'private'>
	^self sites contains: 
		[:each | 
		each host = aHostname and: [each ip = ipString and: [each port = aNumber]]]
    ]

    hasSiteOnAllInterfacesOnPort: aNumber [
	"only one site per port is allowed when listening to all interfaces"

	<category: 'private'>
	^self sites 
	    contains: [:each | each onAllInterfaces and: [each port = aNumber]]
    ]

    hasSiteOnPort: aNumber [
	<category: 'private'>
	^self sites contains: [:each | each port = aNumber]
    ]

    initServers [
	<category: 'initialize-release'>
	servers := Set new
    ]

    initSites [
	<category: 'initialize-release'>
	sites := OrderedCollection new
    ]

    initialize [
	<category: 'initialize-release'>
	self initSites.
	self initServers
    ]

    isServing [
	"any site running currently?"

	<category: 'testing'>
	^self servers notEmpty
    ]

    isWatchdogRunning [
	<category: 'private-watchdog'>
	^self watchdog notNil	"and: [self watchdog is not].  ?!!?"
    ]

    newServerFor: aSiteIdentifier [
	<category: 'private-servers'>
	^aSiteIdentifier newServer
    ]

    prepareDemoSite [
	"on http://localhost:8888 to return 'Hello Word'"

	<category: 'private'>
	| site |
	site := SwazooSite newNamed: 'swazoodemo'.	"which is now also added to SwazoServer"
	site 
	    host: '*'
	    ip: '*'
	    port: 8888.
	site addResource: (HelloWorldResource uriPattern: '/').
	^site
    ]

    prepareDemoSiteOnPort: aNumber [
	"this site will run on all IP interfaces on that port, returning 'Hello World'"

	<category: 'private'>
	| name site |
	name := 'port' , aNumber printString.
	site := SwazooSite newNamed: name.	"which is now also added to SwazoServer"
	site 
	    host: '*'
	    ip: '*'
	    port: aNumber.
	site addResource: (HelloWorldResource uriPattern: '/').
	^site
    ]

    removeAllSites [
	<category: 'private'>
	self sites copy do: [:each | self removeSite: each]
    ]

    removeServer: aHTTPServer [
	<category: 'private-servers'>
	^self servers remove: aHTTPServer
    ]

    removeSite: aSite [
	<category: 'adding/removing'>
	aSite stop.
	self sites remove: aSite
    ]

    restart [
	<category: 'start/stop'>
	self
	    stop;
	    start
    ]

    restartServers [
	"do that after image restart, because TCP sockets are probably not valid anymore"

	<category: 'private-servers'>
	self servers do: [:each | each restart]
    ]

    serverFor: aSiteIdentifier [
	<category: 'private-servers'>
	| httpServer |
	aSiteIdentifier isEmpty ifTrue: [^nil].	"in case of new one  initializing"
	^self servers 
	    detect: [:each | each ip = aSiteIdentifier ip & (each port = aSiteIdentifier port)]
	    ifNone: 
		[httpServer := self newServerFor: aSiteIdentifier.
		self addServer: httpServer.
		httpServer start.
		^httpServer]
    ]

    servers [
	<category: 'private'>
	servers isNil ifTrue: [self initServers].
	^servers
    ]

    siteAnyHostAllInterfacesOnPort: aNumber [
	"for host: * ip: * sites"

	<category: 'private'>
	^self sites detect: 
		[:each | 
		each onAnyHost and: [each onAllInterfaces and: [each port = aNumber]]]
	    ifNone: [nil]
    ]

    siteHostnamed: aString [
	"find a site with that host name"

	<category: 'accessing'>
	| string |
	aString = '*' ifTrue: [^nil].	"what else should we return?"
	string := aString isNil ifTrue: [''] ifFalse: [aString asLowercase].
	^self sites 
	    detect: [:each | each host notNil and: [each host asLowercase = string]]
	    ifNone: [nil]
    ]

    siteNamed: aString [
	"find a site with that short name"

	<category: 'accessing'>
	| string |
	string := aString isNil ifTrue: [''] ifFalse: [aString asLowercase].
	^self sites detect: [:each | each name asLowercase = string] ifNone: [nil]
    ]

    sites [
	<category: 'private'>
	sites isNil ifTrue: [self initSites].
	^sites
    ]

    start [
	<category: 'start/stop'>
	self sites do: [:site | site start].
	self startWatchdog
    ]

    startOn: aPortNumber [
	"start a site on that port, on all ip interfaces and accepting all hosts.
	 It also created a site if there is any site on that port yet"

	"opening http://localhost:portNumber will return a simple 'Hello world'"

	<category: 'start/stop'>
	| site |
	site := self siteAnyHostAllInterfacesOnPort: aPortNumber.
	site isNil ifTrue: [site := self prepareDemoSiteOnPort: aPortNumber].
	site start.
	^site
    ]

    startSite: aString [
	"start site with that name"

	<category: 'start/stop'>
	| site |
	site := self siteNamed: aString.
	^site notNil 
	    ifTrue: 
		[site start.
		self isWatchdogRunning ifFalse: [self startWatchdog].
		site]
	    ifFalse: [nil]
    ]

    startWatchdog [
	"SwazooServer singleton startWatchdog"

	<category: 'private-watchdog'>
	self isWatchdogRunning ifTrue: [self stopWatchdog].
	self 
	    watchdog: (
		[[true] whileTrue: 
			[(self respondsTo: #watchdogSites) ifTrue: [self watchdogSites].
			(self respondsTo: #watchdogOther) ifTrue: [self watchdogOther].	"if any"
			(Delay forSeconds: self watchdogPeriod) wait]] 
			forkAt: Processor lowIOPriority)
    ]

    stop [
	<category: 'start/stop'>
	self sites do: [:site | site stop].
	self servers do: [:server | server stop].
	self initServers.
	self stopWatchdog
    ]

    stopOn: aPortNumber [
	"stop a site on that port, if any running on all ip interfaces and accepting all hosts"

	<category: 'start/stop'>
	| site |
	site := self siteAnyHostAllInterfacesOnPort: aPortNumber.
	^site notNil 
	    ifTrue: 
		[site stop.
		site]
	    ifFalse: [nil]
    ]

    stopSite: aString [
	"stop site with that name"

	<category: 'start/stop'>
	| site |
	site := self siteNamed: aString.
	^site notNil 
	    ifTrue: 
		[site stop.
		site]
	    ifFalse: [nil]
    ]

    stopWatchdog [
	<category: 'private-watchdog'>
	self watchdog notNil 
	    ifTrue: 
		[self watchdog terminate.
		self watchdog: nil]
    ]

    watchdog [
	<category: 'private-watchdog'>
	^watchdog
    ]

    watchdog: aProcess [
	<category: 'private-watchdog'>
	watchdog := aProcess
    ]

    watchdogPeriod [
	<category: 'private-watchdog'>
	^10	"seconds"
    ]

    watchdogSites [
	<category: 'private-watchdog'>
	self sites do: [:each | each isServing ifTrue: [each watchdogAction]]
    ]
]



Eval [
    SwazooServer initialize
]
PK
     �Mh@�˪A�  �    HTTP.stUT	 eqXOՊXOux �  �  "======================================================================
|
|   Swazoo 2.1 HTTP handling
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: HTTPConnection [
    | stream loop server task |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    HTTPConnection class >> socket: aSocket [
	<category: 'instance creation'>
	^self new stream: aSocket stream
    ]

    close [
	<category: 'serving'>
	self stream notNil 
	    ifTrue: 
		[self stream close.
		stream := nil].
	self server notNil ifTrue: [self server removeConnection: self].
	self loop notNil 
	    ifTrue: 
		[self loop terminate.
		self loop: nil]
    ]

    getAndDispatchMessages [
	"^self
	 The HTTPRequest is read from my socket stream.  I then pass this request to my server
	 to get a response."

	<category: 'serving'>
	self stream anyDataReady 
	    ifTrue: 
		["wait for data and if anything read, proceed"

		self task: (SwazooTask newOn: self).
		self readRequestFor: self task.
		self produceResponseFor: self task.
		self task request wantsConnectionClose ifTrue: [self close].
		self task request isHttp10 ifTrue: [self close]	"well, we won't complicate here"]
	    ifFalse: 
		[self keepAliveTimeout ifTrue: [^self close].
		(Delay forMilliseconds: 100) wait.	"to finish sending, if any"
		self close]
    ]

    interact [
	"longer description is below method"

	<category: 'serving'>
	| interactionBlock |
	interactionBlock := 
		[
		[[[true] whileTrue: 
			[self getAndDispatchMessages.
			Processor yield]] 
			    ifCurtailed: 
			        [self close]]
		    on: Error
		    do: [:ex |
			(Delay forMilliseconds: 50) wait.	"to finish sending, if any"
			self close]].
	self server isMultiThreading 
	    ifTrue: 
		[self loop: (interactionBlock forkAt: Processor userBackgroundPriority)]
	    ifFalse: [interactionBlock value].
	^self

	"I represent a specifc connection with an HTTP client (a browser, probably) over which will come an HTTP request.  Here, I fork the handling of the request so that the current thread (which is most likely the HTTP server main loop) can carry on with the next request.  This means that more than one request may being handled in the image at a time, and that means that the application developer must worry about thread safety - e.g the problem of a given business object being updated by more than one HTTP request thread.
	 For a GemStone implementation of Swazoo, one may want only one request is handled at a time, multi-threadedness being handled by having multiple gems.  This is a nice option because the application developer does not have to worry about thread safety in this case - GemStone handles the hard stuff.
	 *And* the thing called a loop that was in this method was no such thing.  In all circumstances, >>getAndDispatchMessages handles exactly one requst and then closes the socket!! (very non-HTTP1.1).  Anyway, for now I'm just going to make that explicit.  This needs to be re-visited to support HTTP 1.1."
    ]

    isOpen [
	"not yet closed"

	<category: 'testing'>
	^self stream notNil
    ]

    keepAliveTimeout [
	<category: 'testing'>
	| seconds |
	self task isNil ifTrue: [^false].
	self task request isKeepAlive ifFalse: [^false].
	seconds := self task request keepAlive notNil 
		    ifTrue: [self task request keepAlive asInteger - 10	"to be sure"]
		    ifFalse: [20].	"probably enough?"
	^SpTimestamp now asSeconds - self task request timestamp asSeconds 
	    >= seconds
    ]

    loop [
	<category: 'private'>
	^loop
    ]

    loop: aProcess [
	<category: 'private'>
	loop := aProcess
    ]

    nextPutError: aResponse [
	<category: 'serving-responses'>
	aResponse informConnectionClose.
	self responsePrinterClass writeResponse: aResponse to: self stream.
    ]

    nextPutResponse: aMessage toRequest: aRequest [
	<category: 'serving-responses'>
	aRequest isHead 
	    ifTrue: [self responsePrinterClass writeHeadersFor: aMessage to: self stream]
	    ifFalse: [self responsePrinterClass writeResponse: aMessage to: self stream].
    ]

    produceResponseFor: aSwazooTask [
	"Given the request in aTask I try to make a response.  If there are any unhandled
	 exceptions, respond with an internal server error."

	<category: 'serving'>
	aSwazooTask request isNil ifTrue: [^nil].
	"SpExceptionContext for:
	 ["
	aSwazooTask response: (self server answerTo: aSwazooTask request).
	aSwazooTask request ensureFullRead.	"in case if defered parsing not done in HTTPost"
	aSwazooTask request wantsConnectionClose 
	    ifTrue: [aSwazooTask response informConnectionClose]
	    ifFalse: 
		[aSwazooTask request isKeepAlive 
		    ifTrue: [aSwazooTask response informConnectionKeepAlive]].
	aSwazooTask response isStreamed 
	    ifFalse: 
		["streamed ones did that by themselves"

		self nextPutResponse: aSwazooTask response toRequest: aSwazooTask request]
	    ifTrue: [aSwazooTask response waitClose].	"to be sure all is sent"
	aSwazooTask request isGet 
	    ifFalse: 
		[self close	"to avoid strange 200 bad requests
		 after two consecutive POSTs, but it is really a hack and original reason
		 must be found!!"
		"onAnyExceptionDo:
		 [:ex |
		 self halt.
		 self nextPutError: HTTPResponse internalServerError.
		 ex defaultAction."	"usually raise an UHE window"	"
		 self close]"]
    ]

    readRequestFor: aSwazooTask [
	"I read the next request from my socket and add it to aSwazooTask.  If I have any
	 problems and need to force a bad request (400) response, I add this response to aSwazooTask."

	<category: 'serving'>
	| request |
	SpExceptionContext 
	    for: 
		[request := self requestReaderClass readFrom: self stream.
		request uri port: self server port.
		(request httpVersion last = 1 
		    and: [(request headers includesFieldOfClass: HTTPHostField) not]) 
			ifTrue: [aSwazooTask response: HTTPResponse badRequest].
		[request peer: self stream socket remoteAddress] on: Error do: [:ex | ].
		request
		    ip: self stream socket localAddress hostAddressString;
		    setTimestamp.
		aSwazooTask request: request]
	    on: SpError , HTTPException
	    do: 
		[:ex | 
		aSwazooTask response: HTTPResponse badRequest.
		self nextPutError: aSwazooTask response.
		self close]
    ]

    requestReaderClass [
	<category: 'private'>
	^server requestReaderClass
    ]

    responsePrinterClass [
	<category: 'private'>
	^server responsePrinterClass
    ]

    server [
	<category: 'private'>
	^server
    ]

    server: aServer [
	<category: 'private'>
	server := aServer
    ]

    socket [
	<category: 'private'>
	^self stream socket
    ]

    stream [
	<category: 'private'>
	^stream
    ]

    stream: aSwazooStream [
	<category: 'private'>
	stream := aSwazooStream
    ]

    task [
	"request/response pair, current or last one (until next request)"

	<category: 'private'>
	^task
    ]

    task: aSwazooTask [
	"request/response pair, current or last one (until next request)"

	<category: 'private'>
	task := aSwazooTask
    ]
]



Object subclass: AbstractHTTPServer [
    | connections sites socket loop isMultiThreading |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    AbstractHTTPServer class >> initialize [
	<category: 'intialize-release'>
	SpEnvironment addImageShutdownTask: [self shutDown] for: self
    ]

    AbstractHTTPServer class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    AbstractHTTPServer class >> shutDown [
	"HTTPServer shutDown"

	<category: 'intialize-release'>
	self allInstances do: [:each | each stop].
	SpEnvironment removeShutdownActionFor: self
    ]

    acceptConnection [
	"^self
	 I accept the next inbound TCP/IP connection.  The operating system libraries queue these up for me, so I can just handle one at a time.  I create an HTTPConnection instance to actually handle the interaction with the client - if I am in single threaded mode, the connection will completely handle the request before returning control to me, but in multi-threaded mode the connection forks the work into a sepparate thread in this image and control is immediately returned to me (the application programmer must worry about thread safety in this case."

	<category: 'private'>
	| clientConnection |
	clientConnection := SpExceptionContext 
		    for: [HTTPConnection socket: self socket accept]
		    on: SpError
		    do: 
			[:ex | 
			Transcript
			    show: 'Socket accept error: ' , ex errorString;
			    cr.
			^self].
	self addConnection: clientConnection.
	clientConnection interact.
	^self
    ]

    addConnection: aConnection [
	<category: 'private'>
	self connections add: aConnection.
	aConnection server: self
    ]

    addSite: aSite [
	<category: 'sites'>
	(self sites includesResource: aSite) 
	    ifFalse: [^self sites addResource: aSite]
    ]

    answerTo: aRequest [
	<category: 'serving'>
	| response |
	response := URIResolution resolveRequest: aRequest startingAt: self sites.
	^response isNil ifTrue: [HTTPResponse notFound] ifFalse: [response]
    ]

    connections [
	<category: 'private'>
	connections isNil ifTrue: [self initConnections].
	^connections
    ]

    createSocket [
	<category: 'abstract-start/stop'>
	self subclassResponsibility.
    ]

    hasNoSites [
	<category: 'sites'>
	^self sites hasNoResources
    ]

    initConnections [
	<category: 'private-initialize'>
	connections := OrderedCollection new
    ]

    initSites [
	<category: 'private-initialize'>
	sites := ServerRootComposite new
    ]

    initialize [
	<category: 'private-initialize'>
	self initConnections.
	self initSites
    ]

    isMultiThreading [
	"^a Boolean
	 I return true if each inbound HTTP connection will be handled in its own thread.  See the senders of this message to see where that is important.  Note that the default mode is mult-threaded because this is how Swazoo has worked so far.  This is tricky for the application programmer, though, as they must ensure that they work in a thread safe way (e.g. avoid the many threads updating the same object).  For those deploying to GemStone, you wil find things much easier if you do *not* run multithreaded, but rather run many gems each with a single-threaded Swazoo instance (and your app logic) in each.  Also in GemStone, run the main loop in the foreground, c.f. >>mainLoopInForeground"

	<category: 'multithreading'>
	isMultiThreading isNil ifTrue: [self setMultiThreading].
	^isMultiThreading
    ]

    isServing [
	<category: 'testing'>
	^self loop notNil
    ]

    loop [
	<category: 'private'>
	^loop
    ]

    loop: aProcess [
	<category: 'private'>
	loop := aProcess
    ]

    removeConnection: aConnection [
	<category: 'private'>
	self connections remove: aConnection ifAbsent: [nil]
    ]

    removeSite: aSite [
	<category: 'sites'>
	^self sites removeResource: aSite
    ]

    requestReaderClass [
	<category: 'factories'>
	self subclassResponsibility
    ]

    responsePrinterClass [
	<category: 'factories'>
	self subclassResponsibility
    ]

    restart [
	"usefull after image startup, when socket is probably not valid anymore"

	<category: 'start/stop'>
	self stop.
	self start
    ]

    setMultiThreading [
	"^self
	 I record that this HTTP server is to operate in a multi-threaded mode.  c.f. isMultiThreading"

	<category: 'multithreading'>
	isMultiThreading := true.
	^self
    ]

    setSingleThreading [
	"^self
	 I record that this HTTP server is to operate in a single-threaded mode.  c.f. isMultiThreading"

	<category: 'multithreading'>
	isMultiThreading := false.
	^self
    ]

    sites [
	<category: 'private'>
	sites isNil ifTrue: [self initSites].
	^sites
    ]

    socket [
	<category: 'private'>
	^socket
    ]

    socket: aSocket [
	<category: 'private'>
	socket := aSocket
    ]

    start [
	<category: 'start/stop'>
	self loop isNil 
	    ifTrue: 
		[self socket: self createSocket.
		self loop: ([[self acceptConnection] repeat] 
			    forkAt: Processor userBackgroundPriority)]
    ]

    stop [
	<category: 'start/stop'>
	self loop isNil 
	    ifFalse: 
		[self connections copy do: [:each | each close].
		self loop terminate.
		self loop: nil.
		self socket close.
		self socket: nil]
    ]
]



AbstractHTTPServer subclass: HTTPServer [
    
    | ip port |

    <category: 'Swazoo-HTTP'>
    <comment: nil>

    createSocket [
	<category: 'private-initialize'>
	^(self socketClass serverOnIP: self ipCorrected port: self port)
		listenFor: 50;
		yourself
    ]

    ip [
	<category: 'private-initialize'>
	^ip
    ]

    ip: anIPString [
	<category: 'private-initialize'>
	ip := anIPString
    ]

    ipCorrected [
	"in case of '*' always return '0.0.0.0'"

	<category: 'private-initialize'>
	^self ip = '*' ifTrue: ['0.0.0.0'] ifFalse: [self ip]
    ]

    port [
	<category: 'private-initialize'>
	^port
    ]

    port: aNumber [
	<category: 'private-initialize'>
	port := aNumber
    ]

    requestReaderClass [
	<category: 'factories'>
	^HTTPReader
    ]

    responsePrinterClass [
	<category: 'factories'>
	^HTTPPrinter
    ]

    socketClass [
	"^a Class
	 I use SwazooSocket to wrap the actual socket.  SwazooSocket does some of the byte translation work for me."

	<category: 'private'>
	^SwazooSocket
    ]
]



Object subclass: HTTPString [
    
    <category: 'Swazoo-HTTP'>
    <comment: 'This class contains some utility methods that were previously implemented as extentions to system classes.  This is really a stop-gap until, perhaps, the SwazooStream yeilds HTTPStrings.

'>

    HTTPString class >> decodedHTTPFrom: aCharacterArray [
	"Code taken from the swazoo specific extention to the CharacterArray class"

	<category: 'decoding'>
	| targetStream sourceStream |
	targetStream := WriteStream on: aCharacterArray class new.
	sourceStream := ReadStream on: aCharacterArray.
	[sourceStream atEnd] whileFalse: 
		[| char |
		char := sourceStream next.
		char = $% 
		    ifTrue: 
			[targetStream nextPut: (Character 
				    value: (SpEnvironment integerFromString: '16r' , (sourceStream next: 2)))]
		    ifFalse: 
			[char == $+ 
			    ifTrue: [targetStream nextPut: Character space]
			    ifFalse: [targetStream nextPut: char]]].
	^targetStream contents
    ]

    HTTPString class >> encodedHTTPFrom: aCharacterArray [
	"Code taken from the swazoo specific extention to the CharacterArray class"

	<category: 'decoding'>
	| targetStream |
	targetStream := WriteStream on: aCharacterArray class new.
	aCharacterArray do: 
		[:char | 
		(self isHTTPReservedCharacter: char) 
		    ifTrue: 
			[targetStream nextPut: $%.
			targetStream nextPutAll: (char asInteger 
				    printPaddedWith: $0
				    to: 2
				    base: 16)
			"char asInteger
			 printOn: targetStream
			 paddedWith: $0
			 to: 2
			 base: 16"]
		    ifFalse: [targetStream nextPut: char]].
	^targetStream contents
    ]

    HTTPString class >> isHTTPReservedCharacter: aCharacter [
	"Code taken from the swazoo specific extention to the Character class"

	<category: 'decoding'>
	^(aCharacter isAlphaNumeric or: ['-_.!~*''()' includes: aCharacter]) not
    ]

    HTTPString class >> newRandomString: anInteger [
	<category: 'instance creation'>
	| numbersThroughAlphas targetStream char random |
	numbersThroughAlphas := (48 to: 122) 
		    collect: [:each | Character value: each].
	targetStream := WriteStream on: (String new: anInteger).
	random := Random new.
	[targetStream contents size < anInteger] whileTrue: 
		[char := numbersThroughAlphas 
			    at: (random next * (numbersThroughAlphas size - 1)) rounded + 1.
		char isAlphaNumeric ifTrue: [targetStream nextPut: char]].
	^targetStream contents
    ]

    HTTPString class >> stringFromBytes: aByteArray [
	"^a String
	 In GemStone ['Hello, World' asByteArray asString] returns the string 'aByteArray' !!
	 This is the boring long way of getting a string from a ByteArray - but it does work
	 in GemStone."

	"HTTPString stringFromBytes: ('Hello, World' asByteArray)"

	<category: 'decoding'>
	| targetStream |
	targetStream := WriteStream on: String new.
	aByteArray do: [:aByte | targetStream nextPut: (Character value: aByte)].
	^targetStream contents
    ]

    HTTPString class >> subCollectionsFrom: aCollection delimitedBy: anObject [
	"^an OrderedCollection
	 I return the ordered collection of sub-collections from aCollection, delimited
	 by anObject."

	"HTTPString subCollectionsFrom: 'aaa/bbb/' delimitedBy: $/"

	<category: 'tokens'>
	| subCollections sourceStream |
	subCollections := OrderedCollection new.
	sourceStream := ReadStream on: aCollection.
	[sourceStream atEnd] 
	    whileFalse: [subCollections add: (sourceStream upTo: anObject)].
	(aCollection isEmpty 
	    or: [(sourceStream
		    skip: -1;
		    next) == anObject]) 
		ifTrue: [subCollections add: aCollection class new].
	^subCollections
    ]

    HTTPString class >> trimBlanksFrom: aString [
	"^a String
	 I return a copy of aString with all leading and trailing blanks removed."

	<category: 'decoding'>
	| first last |
	first := 1.
	last := aString size.
	[last > 0 and: [(aString at: last) isSeparator]] 
	    whileTrue: [last := last - 1].
	^last == 0 
	    ifTrue: [String new]
	    ifFalse: 
		[[first < last and: [(aString at: first) isSeparator]] 
		    whileTrue: [first := first + 1].
		aString copyFrom: first to: last]
    ]
]



CompositeResource subclass: ServerRootComposite [
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    helpResolve: aResolution [
	<category: 'accessing'>
	^aResolution resolveServerRoot: self
    ]
]



Object subclass: AbstractSwazooSocket [
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    accept [
	<category: 'server accessing'>
	self subclassResponsibility
    ]

    close [
	<category: 'accessing'>
	self subclassRespnsibility
    ]

    isActive [
	<category: 'testing'>
	self subclassResponsibility
    ]

    listenFor: anInteger [
	<category: 'server accessing'>
	self subclassResponsibility
    ]

    localAddress [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    read: anInteger [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    readInto: aByteArray startingAt: start for: length [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    remoteAddress [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    stream [
	<category: 'private'>
	self subclassResponsibility
    ]

    write: aByteArray [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    writeFrom: aByteArray startingAt: start for: length [
	<category: 'accessing'>
	self subclassResponsibility
    ]
]



AbstractSwazooSocket subclass: SwazooSocket [
    | accessor |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    SwazooSocket class >> accessor: aSocketAccessor [
	<category: 'private'>
	^self new accessor: aSocketAccessor
    ]

    SwazooSocket class >> connectTo: aHostString port: anInteger [
	<category: 'instance creation'>
	| newSocket |
	newSocket := SpSocket newTCPSocket.
	newSocket connectTo: (SpIPAddress hostName: aHostString port: anInteger).
	^self accessor: newSocket
    ]

    SwazooSocket class >> connectedPair [
	<category: 'instance creation'>
	^SpSocket newSocketPair collect: [:each | self accessor: each]
    ]

    SwazooSocket class >> serverOnIP: anIPString port: anInteger [
	<category: 'instance creation'>
	| newSocket |
	newSocket := SpSocket newTCPSocket.
	newSocket
	    setAddressReuse: true;
	    bindSocketAddress: (SpIPAddress hostName: anIPString port: anInteger).
	^self accessor: newSocket
    ]

    accept [
	<category: 'server accessing'>
	^self class accessor: self accessor acceptRetryingIfTransientErrors
    ]

    accessor [
	<category: 'private'>
	^accessor
    ]

    accessor: aSocketAccessor [
	<category: 'private'>
	accessor := aSocketAccessor
    ]

    close [
	<category: 'accessing'>
	self accessor close
    ]

    isActive [
	<category: 'testing'>
	^self accessor isActive
    ]

    listenFor: anInteger [
	<category: 'server accessing'>
	self accessor listenBackloggingUpTo: anInteger
    ]

    localAddress [
	<category: 'accessing'>
	^self accessor getSocketName
    ]

    read: anInteger [
	<category: 'accessing'>
	^self accessor read: anInteger
    ]

    readInto: aByteArray startingAt: start for: length [
	<category: 'accessing'>
	^self accessor 
	    readInto: aByteArray
	    startingAt: start
	    for: length
    ]

    remoteAddress [
	<category: 'accessing'>
	^self accessor getPeerName
    ]

    stream [
	<category: 'private'>
	^SwazooStream socket: self
    ]

    write: aByteArray [
	<category: 'accessing'>
	^self accessor write: aByteArray
    ]

    writeFrom: aByteArray startingAt: start for: length [
	<category: 'accessing'>
	^self accessor 
	    writeFrom: aByteArray
	    startingAt: start
	    for: length
    ]
]



Object subclass: SwazooStream [
    | socket readBuffer readPtr readEnd writeBuffer writePtr writeEnd chunked |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    SwazooStream class >> preambleSize [
        <category: 'defaults'>
	^6
    ]

    SwazooStream class >> defaultBufferSize [
        <category: 'defaults'>
        ^8000
    ]

    SwazooStream class >> connectedPair [
	<category: 'instance creation'>
	^SwazooSocket connectedPair collect: [:each | self socket: each]
    ]

    SwazooStream class >> on: aString [
	"use only for testing!!"

	<category: 'instance creation'>
	^self new setInputString: aString
    ]

    SwazooStream class >> socket: aSwazooSocket [
	<category: 'instance creation'>
	^self new setSocket: aSwazooSocket
    ]

    copyBufferTo: anIndex [
	"from current position to desired index"

	<category: 'mime boundary'>
	| start |
	start := readPtr.
	readPtr := anIndex.
	^readBuffer copyFrom: start to: anIndex - 1
    ]

    indexOfBoundary: aBoundaryBytes [
	"index of boundary start, beeing full boundary or part at the end of buffer. 0 if not found"

	<category: 'mime boundary'>
	| inx innerInx firstInx |
	inx := readPtr.
	[inx <= readEnd] whileTrue: 
		[innerInx := 1.
		firstInx := inx.
		[(aBoundaryBytes at: innerInx) = (readBuffer at: inx)] whileTrue: 
			[innerInx = aBoundaryBytes size ifTrue: [^firstInx].	"full boundary found"
			inx = readEnd ifTrue: [^firstInx].	"partial boundary at the edge of buffer found"
			inx := inx + 1.
			innerInx := innerInx + 1].
		inx := inx + 1].
	^0
    ]

    signsOfBoundary: aBoundaryBytes [
	"detect as fast as possible if any if not all MIME part boundary is present in buffer contents"

	"return number of bundary bytes detected, 0 = no boundary"

	<category: 'mime boundary'>
	| first index |
	first := aBoundaryBytes first.
	"fast test"
	((readPtr + 1 to: readEnd) 
	    contains: [:inx | (readBuffer at: inx) = first]) ifFalse: [^0].
	"full or partial boundary on the edge of buffer test"
	index := self indexOfBoundary: aBoundaryBytes.	"index of full, or partial boundary at the edge"
	index = 0 ifTrue: [^0].	"no boundary found"
	readEnd - index >= aBoundaryBytes size ifTrue: [^aBoundaryBytes size].	"full boundary detected"
	^readEnd - index + 1	"partial boundary at the end of buffer"
    ]

    startsWith: aPartialBoundaryBytes [
	"is remaining part of MIME part boundary at the start of buffer?"

	<category: 'mime boundary'>
	1 to: aPartialBoundaryBytes size
	    do: 
		[:inx | 
		(readBuffer at: readPtr + inx) = (aPartialBoundaryBytes at: inx) 
		    ifFalse: [^false]].
	^true
    ]

    anyDataReady [
	"wait for data and return true if any data ready. On VW somethimes happen that data
	 receipt is signaled but no data is actually received"

	<category: 'accessing-reading'>
	self fillBuffer.
	^readPtr <= readEnd
    ]

    atEnd [
	"TCP socket data never ends!!"

	<category: 'accessing-reading'>
	^false
    ]

    close [
	"close TCP socket and relase buffers"

	<category: 'initialize-release'>
	self socket close.
	self nilWriteBuffer.
	self nilReadBuffer	"to GC buffers"
    ]

    closeChunk [
        "a zero sized chunk determine and end of chunked data and also response"

	<category: 'chunked encoding'>
        | written |
        "first crlf ends 0 length line, second crlf ends whole response"
        written := self socket
                    writeFrom: #(48 13 10 13 10) asByteArray
                    startingAt: 1
                    for: 5.
        written = 5 ifFalse: [self error: 'socket write error']
    ]

    closeResponse [
	"for chunked response: close it by sending null chunk"

	"do a bit cleanup after response is sent"

	<category: 'initialize-release'>
	self flush.
	self isChunked ifTrue: [self closeChunk; resetChunked].
    ]

    cr [
	<category: 'accessing-writing'>
	self nextPutByte: 13
    ]

    crlf [
	<category: 'accessing-writing'>
	self
	    cr;
	    lf
    ]

    writeDataSize [
	<category: 'private'>

	^writeEnd - writePtr + 1
    ]

    fillBuffer [
	<category: 'private'>
	readPtr > readEnd ifFalse: [^self].
	self socket isNil ifTrue: [^self].	"if SwazooStream is used for tests only"
	readPtr := 1.
        readEnd := self socket
                    readInto: readBuffer
                    startingAt: 1
                    for: readBuffer size.       "nr. of actuall bytes read"
        readEnd = 0
            ifTrue:
                [SwazooStreamNoDataError
                    raiseSignal: 'No data available.  Socket probably closed']
    ]

    fillPreamble [
	<category: 'chunked encoding'>

	| size length start |
	size := self writeDataSize.
	"preamble has no room for bigger chunk..."
        size > 65535 ifTrue: [self error: 'chunk too long!'].
        length := size printStringRadix: 16.

        SpEnvironment isSqueak ifTrue: [length := length copyFrom: 4].     "trim 16r"
	writeBuffer
	    replaceFrom: 1 to: length size
	    with: length
	    startingAt: 1.
	writeBuffer
	    replaceFrom: length size + 1 to: 6
	    with: #[32 32 32 32 13 10]
	    startingAt: length size + 1.
	writePtr := 1
    ]

    flush [
	"actually write to the tcp socket and clear write buffer"

	<category: 'initialize-release'>
	| written |
	self socket isNil ifTrue: [^nil].	"for simulations and tests"

	self isChunked ifTrue: [self fillPreamble].
	[writeEnd < writePtr] whileFalse:
	    [written := self socket
                            writeFrom: writeBuffer
                            startingAt: writePtr
                            for: writeEnd - writePtr + 1.
            writePtr := writePtr + written].
	writePtr := self class preambleSize + 1.
	writeEnd := self class preambleSize.
    ]

    isChunked [
	"sending in chunks (transfer encoding: chunked)"

	<category: 'chunking'>
	^chunked notNil and: [chunked]
    ]

    isFull [
	"sending in chunks (transfer encoding: chunked)"

	<category: 'chunking'>
	^writeEnd >= writeBuffer size
    ]

    lf [
	<category: 'accessing-writing'>
	self nextPutByte: 10
    ]

    next [
	<category: 'accessing-reading'>
	self fillBuffer.
	^readBuffer at: (readPtr := readPtr + 1) - 1
    ]

    next: anInteger [
	<category: 'accessing-reading'>
	| array at n |
	array := String new: anInteger.
	at := 1.
	[ at <= anInteger ] whileTrue: [
	    self fillBuffer.
	    n := readEnd - readPtr + 1 min: anInteger - at + 1.
	    array replaceFrom: at to: at + n - 1 with: readBuffer startingAt: readPtr.
	    readPtr := readPtr + n.
	    at := at + n].
	^array
    ]

    nextByte [
	<category: 'private-stream'>
	self fillBuffer.
	^readBuffer byteAt: (readPtr := readPtr + 1) - 1
    ]

    nextBytes: anInteger [
	<category: 'private-stream'>
	| array at n |
	array := ByteArray new: anInteger.
	at := 1.
	[ at <= anInteger ] whileTrue: [
	    self fillBuffer.
	    n := readEnd - readPtr + 1 min: anInteger - at + 1.
	    array replaceFrom: at to: at + n - 1 with: readBuffer startingAt: readPtr.
	    readPtr := readPtr + n.
	    at := at + n].
	^array
    ]

    nextLine [
	<category: 'accessing-reading'>
	| stream |
	stream := WriteStream on: (String new: 50).
	self writeNextLineTo: stream.
	^stream contents
    ]

    nextPut: aCharacterOrInteger [
	<category: 'accessing-writing'>
	self isFull ifTrue: [self flush].
	writeBuffer at: (writeEnd := writeEnd + 1) put: aCharacterOrInteger asCharacter. "###"
	^aCharacterOrInteger
    ]

    nextPutAllBufferOn: aStream [
	<category: 'accessing-reading'>
	| n |
	n := readEnd - readPtr + 1.
	aStream next: readEnd - readPtr + 1 putAll: readBuffer startingAt: readPtr.
	readPtr := readEnd + 1.
	^n
    ]

    nextPutAll: aByteStringOrArray [
	<category: 'accessing-writing'>
	| at n |
	at := 1.
	[ at <= aByteStringOrArray size ] whileTrue: [
	    self isFull ifTrue: [self flush].
	    n := writeBuffer size - writeEnd min: aByteStringOrArray size - at + 1.
	    writeBuffer replaceFrom: writeEnd + 1 to: writeEnd + n with: aByteStringOrArray startingAt: at.
	    writeEnd := writeEnd + n.
	    at := at + n].
	^aByteStringOrArray
    ]

    nextPutByte: aByte [
	<category: 'private-stream'>
	self isFull ifTrue: [self flush].
	^writeBuffer byteAt: (writeEnd := writeEnd + 1) put: aByte
    ]

    nextPutBytes: aByteArray [
	<category: 'private-stream'>
	^self nextPutAll: aByteArray
    ]

    nextPutLine: aByteStringOrArray [
	<category: 'accessing-writing'>
	self nextPutAll: aByteStringOrArray.
	self crlf
    ]

    nextUnfoldedLine [
	<category: 'accessing-reading'>
	| stream ch |
	stream := WriteStream on: (String new: 50).
	self writeNextLineTo: stream.
	stream contents isEmpty 
	    ifFalse: 
		[
		[ch := self peek.
		ch notNil and: [ch == Character space or: [ch == Character tab]]] 
			whileTrue: [self writeNextLineTo: stream]].
	^stream contents
    ]

    nilReadBuffer [
	"to release memory"

	<category: 'initialize-release'>
	readBuffer := nil
    ]

    nilWriteBuffer [
	"to release memory"

	<category: 'initialize-release'>
	writeBuffer := nil
    ]

    peek [
	<category: 'accessing-reading'>
	| byte |
	self anyDataReady ifFalse: [^nil].
	^readBuffer at: readPtr
    ]

    peekByte [
	<category: 'private-stream'>
	self anyDataReady ifFalse: [^nil].
	^readBuffer byteAt: readPtr
    ]

    print: anObject [
	<category: 'private'>
	anObject printOn: self
    ]

    readBuffer [
	<category: 'accessing'>
	^readBuffer
    ]

    enlargeReadBuffer: anInteger [
	<category: 'buffer size'>
	anInteger < readBuffer size ifTrue: [ ^self ].
	readBuffer := (readBuffer class new: anInteger)
	    replaceFrom: 1
	        to: readBuffer size
	        with: readBuffer
	        startingAt: 1;
	    yourself
    ]

    readBuffer: aByteArray ready: dataLength [
	<category: 'private'>
	readBuffer := aByteArray.
	readPtr := 1.
	readEnd := dataLength.
    ]

    writeBuffer: aByteArray [
	<category: 'private'>
	writeBuffer := aByteArray.
	writePtr := self class preambleSize + 1.
	writeEnd := self class preambleSize.
    ]

    resetChunked [
	"sending in chunks (transfer encoding: chunked)"

	<category: 'chunking'>
	chunked := false
    ]

    setChunked [
	"sending in chunks (transfer encoding: chunked)"

	<category: 'chunking'>
	chunked := true
    ]

    setInputString: aCollection [
	<category: 'private'>
	self readBuffer: aCollection asString ready: aCollection size.
	self writeBuffer: (String new: self class defaultBufferSize).
    ]

    setSocket: aSwazooSocket [
	<category: 'private'>
	self socket: aSwazooSocket.
	self readBuffer: (String new: self class defaultBufferSize) ready: 0.
	self writeBuffer: (String new: self class defaultBufferSize).
    ]

    skip: anInteger [
	<category: 'accessing-reading'>
	| n skipped |
	n := anInteger.
	[
	    skipped := n min: (readEnd - readPtr + 1).
	    readPtr := readPtr + skipped.
	    n := n - skipped.
	    n > 0
	] whileTrue: [self fillBuffer]
    ]

    socket [
	<category: 'private'>
	^socket
    ]

    socket: aSocket [
	<category: 'private'>
	socket := aSocket
    ]

    space [
	<category: 'accessing-writing'>
	self nextPutByte: 32
    ]

    upTo: aCharacterOrByte [
	<category: 'accessing-reading'>
	| targetChar result r ws |
	targetChar := aCharacterOrByte asCharacter. "###"
	r := readBuffer indexOf: targetChar startingAt: readPtr ifAbsent: [0].
	r = 0 ifFalse: [result := self next: r - readPtr. self next. ^result].

	ws := String new writeStream.
	[self nextPutAllBufferOn: ws.
	self fillBuffer.
	r := readBuffer indexOf: targetChar startingAt: readPtr ifAbsent: [0].
	r = 0] whileTrue.

	ws next: r putAll: readBuffer startingAt: 1.
	readPtr := r + 1.
	^ws contents
    ]

    writeBufferContents [
	<category: 'accessing-writing'>
	^writeBuffer copyFrom: writePtr to: writeEnd
    ]

    writeNextLineTo: aStream [
	<category: 'accessing-reading'>
	| r |
	[r := readBuffer indexOf: Character cr startingAt: readPtr ifAbsent: [0].
	r = 0] whileTrue: [
	    self nextPutAllBufferOn: aStream.
	    self fillBuffer].

	aStream next: r - readPtr putAll: readBuffer startingAt: readPtr.
	readPtr := r + 1.
	self peekByte = 10	"skip remaining linefeed"
	    ifTrue: [readPtr := readPtr + 1]
	    ifFalse: [SwazooHTTPParseError raiseSignal: 'CR without LF']
    ]
]



Object subclass: SwazooURI [
    | protocol hostname port identifier queries |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    SwazooURI class >> fromString: aString [
	<category: 'instance creation'>
	^self new fromString: aString
    ]

    SwazooURI class >> value: aString [
	<category: 'instance creation'>
	^self new value: aString
    ]

    asString [
	<category: 'printing'>
	| targetStream |
	targetStream := WriteStream on: String new.
	self printOn: targetStream.
	^targetStream contents
    ]

    defaultPort [
	<category: 'private'>
	^80
    ]

    fromStream: sourceStream [
	<category: 'initialize-release'>
	self readProtocolFrom: sourceStream.
	self readHostFrom: sourceStream.
	self readPortFrom: sourceStream.
	self readIdentifierFrom: sourceStream.
	self readQueryFrom: sourceStream.
	^self
    ]

    fromString: aString [
	<category: 'initialize-release'>
	| sourceStream |
	sourceStream := ReadStream on: aString.
	self fromStream: sourceStream.
	^self
    ]

    host [
	<category: 'accessing'>
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: self hostname.
	self port = self defaultPort 
	    ifFalse: 
		[ws nextPut: $:.
		self port printOn: ws].
	^ws contents
    ]

    host: aString [
	<category: 'accessing'>
	| rs |
	rs := ReadStream on: aString.
	self hostname: (rs upTo: $:).
	rs atEnd ifFalse: [self port: rs upToEnd asNumber]
    ]

    hostname [
	<category: 'accessing'>
	^hostname
    ]

    hostname: aHostname [
	<category: 'accessing'>
	hostname := aHostname
    ]

    identifier [
	<category: 'accessing'>
	^identifier
    ]

    identifier: anObject [
	<category: 'accessing'>
	identifier := anObject
    ]

    identifierPath [
	<category: 'accessing'>
	| parts |
	parts := (HTTPString subCollectionsFrom: self identifier delimitedBy: $/) 
		    collect: [:each | HTTPString decodedHTTPFrom: each].
	self identifier first = $/ ifTrue: [parts addFirst: '/'].
	^parts reject: [:each | each isEmpty]
    ]

    includesQuery: aString [
	<category: 'accessing-queries'>
	| result |
	result := self queries detect: [:aQuery | aQuery key = aString]
		    ifNone: [nil].
	^result notNil
    ]

    isDirectory [
	<category: 'testing'>
	^self identifier last = $/
    ]

    port [
	"^an Integer
	 The port number defaults to 80 for HTTP."

	<category: 'accessing'>
	^port isNil ifTrue: [80] ifFalse: [port]
    ]

    port: anInteger [
	<category: 'accessing'>
	port := anInteger
    ]

    printOn: targetStream [
	<category: 'printing'>
	(self hostname notNil and: [self protocol notNil]) 
	    ifTrue: 
		[targetStream
		    nextPutAll: self protocol;
		    nextPutAll: '://'].
	self hostname notNil ifTrue: [targetStream nextPutAll: self hostname].
	(self hostname notNil and: [self port notNil and: [self port ~= 80]]) 
	    ifTrue: 
		[targetStream
		    nextPut: $:;
		    nextPutAll: self port printString].
	self identifier notNil ifTrue: [targetStream nextPutAll: self identifier].
	self printQueriesOn: targetStream.
	^self
    ]

    printQueriesOn: targetStream [
	<category: 'printing'>
	| firstQuery |
	self queries isEmpty 
	    ifFalse: 
		[firstQuery := self queries at: 1.
		targetStream
		    nextPut: $?;
		    nextPutAll: firstQuery key;
		    nextPut: $=;
		    nextPutAll: (HTTPString encodedHTTPFrom: firstQuery value).
		2 to: self queries size
		    do: 
			[:queryIndex | 
			| aQuery |
			aQuery := self queries at: queryIndex.
			targetStream
			    nextPut: $&;
			    nextPutAll: aQuery key;
			    nextPut: $=;
			    nextPutAll: (HTTPString encodedHTTPFrom: aQuery value)]].
	^self
    ]

    protocol [
	<category: 'accessing'>
	protocol isNil ifTrue: [self protocol: 'http'].
	^protocol
    ]

    protocol: aString [
	<category: 'accessing'>
	protocol := aString
    ]

    queries [
	"^an OrderedCollection
	 This is an ordered colleciton of associations.  It can't be a dictionary, because it is legal to have many entries with the same key value."

	<category: 'accessing-queries'>
	queries isNil ifTrue: [queries := OrderedCollection new].
	^queries
    ]

    queries: anOrderedCollection [
	"^self
	 The queries must be an OrderedCollection of Associations c.f. >>queries"

	<category: 'accessing-queries'>
	queries := anOrderedCollection.
	^self
    ]

    queriesNamed: aString [
	<category: 'accessing-queries'>
	^self queries select: [:aQuery | aQuery key = aString]
    ]

    queryAt: aString [
	<category: 'accessing-queries'>
	^self queryAt: aString ifAbsent: [nil]
    ]

    queryAt: aString ifAbsent: aBlock [
	"^aString
	 I return the value of the first query I find with the key aString.  If there are none I execute aBlock."

	<category: 'accessing-queries'>
	| result |
	result := self queries detect: [:aQuery | aQuery key = aString]
		    ifNone: [aBlock].
	^result value
    ]

    readHostFrom: aStream [
	"^self
	 I read the host name from the URI presumed to be in aStream.  The stream should be positioned right at the start, or just after the '//' of the protocol.  The host name is terminated by one of $:, $/, $? or the end of the stream depending on wether there is a port, path, query or nothing following the host.  If the host name is of zero length, I record a nil host name.  The stream is left positioned at the terminating character."

	<category: 'private'>
	| hostnameStream |
	hostnameStream := WriteStream on: String new.
	
	[| nextCharacter |
	nextCharacter := aStream peek.
	#($: $/ $? nil) includes: nextCharacter] 
		whileFalse: [hostnameStream nextPut: aStream next].
	hostnameStream contents isEmpty 
	    ifFalse: [hostname := hostnameStream contents].
	^self
    ]

    readIdentifierFrom: sourceStream [
	<category: 'private'>
	self identifier: (sourceStream upTo: $?).
	^self
    ]

    readPortFrom: aStream [
	"^self
	 I read the port nnumber from the URI presumed to be in aStream.  If a port number has been specified, the stream should be positioned right at before a $: charcter.  So, if the next chacter is a :, we have a port number.  I read up to one of $/, $? or the end of the stream depending on wether there is a path, query or nothing following the host.  The stream is left positioned at the terminating character."

	<category: 'private'>
	| targetStream |
	targetStream := WriteStream on: String new.
	aStream peek == $: 
	    ifTrue: 
		[| terminators |
		terminators := Array 
			    with: $/
			    with: $?
			    with: nil.
		aStream next.
		
		[| nextCharacter |
		nextCharacter := aStream peek.
		terminators includes: nextCharacter] 
			whileFalse: 
			    [| nextDigit |
			    nextDigit := aStream next.
			    nextDigit isDigit ifTrue: [targetStream nextPut: nextDigit]].
		targetStream contents isEmpty 
		    ifFalse: [port := targetStream contents asNumber]].
	^self
    ]

    readProtocolFrom: aStream [
	"^self
	 I read the protocol from the URI presumed to be in aStream.  The protocol preceeds '://' in the URI.  I leave the stream position either right after the '//' if there is a protocol, otherwise I reset the position to the start of the stream."

	<category: 'private'>
	| candidateProtocol |
	candidateProtocol := aStream upTo: $:.
	(aStream size - aStream position >= 2 
	    and: [aStream next == $/ and: [aStream next == $/]]) 
		ifTrue: [self protocol: candidateProtocol]
		ifFalse: [aStream reset].
	^self
    ]

    readQueryFrom: sourceStream [
	<category: 'private'>
	[sourceStream atEnd] whileFalse: 
		[| nameValue name value |
		nameValue := sourceStream upTo: $&.
		name := nameValue copyUpTo: $=.
		value := (nameValue readStream)
			    upTo: $=;
			    upToEnd.	"if any"
		self queries add: name -> (HTTPString decodedHTTPFrom: value)].
	^self
    ]

    value [
	"1 halt: 'Use >>asString or >>printOn: instead'."

	<category: 'accessing'>
	^self asString
    ]
]



Object subclass: URIIdentifier [
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    = anIdentifier [
	<category: 'comparing'>
	^self match: anIdentifier
    ]

    hash [
	<category: 'comparing'>
	^1
    ]

    match: anotherIdentifier [
	<category: 'testing'>
	^(self typeMatch: anotherIdentifier) 
	    and: [self valueMatch: anotherIdentifier]
    ]

    requestMatch: aRequest [
	<category: 'testing'>
	^self valueMatch: aRequest
    ]

    typeMatch: anotherIdentifier [
	<category: 'private'>
	^self class == anotherIdentifier class
    ]

    valueMatch: aRequestOrIdentifier [
	<category: 'private'>
	^self subclassResponsibility
    ]
]



URIIdentifier subclass: SiteIdentifier [
    | ip port host |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    SiteIdentifier class >> defaultPort [
	<category: 'accessing'>
	^80
    ]

    SiteIdentifier class >> host: hostName ip: anIP port: aPort [
	<category: 'instance creation'>
	^self new 
	    setIp: anIP
	    port: aPort
	    host: hostName
    ]

    SiteIdentifier class >> ip: anIP port: aPort host: hostName [
	<category: 'obsolete'>
	^self new 
	    setIp: anIP
	    port: aPort
	    host: hostName
    ]

    currentUrl [
	<category: 'accessing'>
	| stream |
	stream := WriteStream on: String new.
	self printUrlOn: stream.
	^stream contents
    ]

    host [
	<category: 'accessing'>
	host isNil ifTrue: [host := '*'].
	^host
    ]

    host: aString [
	<category: 'private'>
	host := aString
    ]

    hostMatch: aSiteIdentifier [
	<category: 'private-comparing'>
	self host asLowercase = aSiteIdentifier host asLowercase ifTrue: [^true].
	(self host = '*' or: [aSiteIdentifier host = '*']) ifTrue: [^true].	"is this always good?"
	^false
    ]

    ip [
	<category: 'accessing'>
	ip isNil ifTrue: [ip := '*'].
	^ip
    ]

    ip: aString [
	<category: 'private'>
	ip := aString
    ]

    ipMatch: aSiteIdentifier [
	"ip can be in numbers or named!!"

	<category: 'private-comparing'>
	| myIP otherIP |
	self ip = aSiteIdentifier ip ifTrue: [^true].
	(self ip = '*' or: [self ip = '0.0.0.0']) ifTrue: [^true].
	(aSiteIdentifier ip = '*' or: [aSiteIdentifier ip = '0.0.0.0']) 
	    ifTrue: [^true].
	"is this always good?"
	myIP := SpIPAddress hostName: self ip port: self port.
	otherIP := SpIPAddress hostName: aSiteIdentifier ip
		    port: aSiteIdentifier port.
	^myIP hostAddress = otherIP hostAddress
    ]

    isEmpty [
	"host ip port empty or nil"

	<category: 'testing'>
	(host isNil or: [host isEmpty]) ifTrue: [^true].
	(ip isNil or: [ip isEmpty]) ifTrue: [^true].
	port isNil ifTrue: [^true].
	^false
    ]

    newServer [
	<category: 'initialize-release'>
	^(HTTPServer new)
	    ip: self ip;
	    port: self port
    ]

    port [
	<category: 'accessing'>
	port isNil ifTrue: [port := self class defaultPort].
	^port
    ]

    port: aNumber [
	<category: 'private'>
	port := aNumber
    ]

    portMatch: aSiteIdentifier [
	"ih host can be anything then same goes for the port of request too"

	<category: 'private-comparing'>
	self port = aSiteIdentifier port ifTrue: [^true].
	(self host = '*' or: [aSiteIdentifier host = '*']) ifTrue: [^true].
	^false
    ]

    printHostPortStringOn: stream [
	<category: 'private'>
	stream nextPutAll: (self host notNil ifTrue: [self host] ifFalse: ['']).
	self port = 80 
	    ifFalse: 
		[stream
		    nextPut: $:;
		    nextPutAll: self port printString]
    ]

    printString [
	<category: 'private'>
	^'a Swazoo.SiteIndentifier
	host: ' 
	    , (self host isNil ifTrue: [''] ifFalse: [self host]) , '
	ip: ' 
	    , (self ip isNil ifTrue: [''] ifFalse: [self ip]) , '
	port: ' 
	    , self port printString
    ]

    printUrlOn: aWriteStream [
	<category: 'private'>
	aWriteStream nextPutAll: 'http://'.
	self printHostPortStringOn: aWriteStream
    ]

    setIp: anIP port: aPort host: hostName [
	<category: 'initialize-release'>
	self ip: anIP.
	self port: aPort.
	self host: hostName
    ]

    valueMatch: aRequestOrIdentifier [
	<category: 'private-comparing'>
	^(self portMatch: aRequestOrIdentifier) 
	    and: [(self ipMatch: aRequestOrIdentifier)
	    and: [self hostMatch: aRequestOrIdentifier]]
    ]
]



Object subclass: URIResolution [
    | position request |
    
    <category: 'Swazoo-HTTP'>
    <comment: nil>

    URIResolution class >> resolveRequest: aRequest startingAt: aResource [
	<category: 'instance creation'>
	^(self new initializeRequest: aRequest) visitResource: aResource
    ]

    advance [
	<category: 'private'>
	self position: self position + 1
    ]

    atEnd [
	<category: 'accessing'>
	^self position = self request uri identifierPath size
    ]

    currentIdentifier [
	<category: 'private'>
	^self currentPath last
    ]

    currentPath [
	<category: 'private'>
	^self request uri identifierPath copyFrom: 1 to: self position
    ]

    fullPath [
	<category: 'accessing'>
	^self request uri identifierPath
    ]

    getAnswerFrom: aResource [
	<category: 'private'>
	^aResource answerTo: self request
    ]

    initializeRequest: aRequest [
	<category: 'private-initialize'>
	self request: aRequest.
	self request resolution: self.
	self position: 1
    ]

    position [
	<category: 'accessing'>
	^position
    ]

    position: anInteger [
	<category: 'private'>
	position := anInteger
    ]

    request [
	<category: 'accessing'>
	^request
    ]

    request: aRequest [
	<category: 'private'>
	request := aRequest
    ]

    resolveCompositeResource: aResource [
	<category: 'resolving'>
	(aResource canAnswer and: [aResource match: self currentIdentifier]) 
	    ifFalse: [^nil].
	^self visitChildrenOf: aResource advancing: true
    ]

    resolveLeafResource: aResource [
	<category: 'resolving'>
	(aResource canAnswer and: [aResource match: self currentIdentifier])
	    ifFalse: [^nil].
	^self getAnswerFrom: aResource
    ]

    resolveServerRoot: aServerRoot [
	<category: 'resolving'>
	^self resolveTransparentComposite: aServerRoot
    ]

    resolveSite: aSite [
	<category: 'resolving'>
	(aSite canAnswer and: [aSite match: self request]) ifFalse: [^nil].
	^self visitChildrenOf: aSite advancing: false
    ]

    resolveTransparentComposite: aCompositeResource [
	<category: 'resolving'>
	^self visitChildrenOf: aCompositeResource advancing: false
    ]

    resourcePath [
	<category: 'accessing'>
	^self request uri identifierPath copyFrom: 1 to: self position
    ]

    retreat [
	<category: 'private'>
	self position: self position - 1.
	^nil
    ]

    siteMatch: aSite [
	<category: 'backwards compatibility'>
	^aSite match: self request
    ]

    tailPath [
	<category: 'accessing'>
	| fullPath |
	fullPath := self fullPath.
	^fullPath copyFrom: self position + 1 to: fullPath size
    ]

    tailStream [
	<category: 'private'>
	^ReadStream on: self tailPath
    ]

    visitChildrenOf: aResource advancing: aBoolean [
	<category: 'resolving'>
	| response |
	self atEnd & aBoolean ifTrue: [^self getAnswerFrom: aResource].
	aBoolean ifTrue: [self advance].
	aResource children do: 
		[:each | 
		response := self visitResource: each.
		response isNil ifFalse: [^response]].
	^aBoolean ifTrue: [self retreat] ifFalse: [nil]
    ]

    visitResource: aResource [
	<category: 'resolving'>
	^aResource helpResolve: self
    ]
]



Eval [
    HTTPServer initialize
]
PK    �Mh@�OtD�  �    PORTINGUT	 eqXOՊXOux �  �  �S�n�@��/�%ˑ�6N{�_�VmQ�Չ�����tw	q�{gǎT���2;�����b��py4��x̕�K��<RC>'��b����X���\U(�~������RFq�k�[8Sۄ��7(�«� d� �s�����AZ�፫��5��Q6ΣQ>���i��8�6ɑM�B:����
p����5�1�|6�jưo�[��/�����8?���?�L�rCN�P��U*.[(|�b�,UY�>dp��2M�������d	;S��ڇx9~��)�T�u�^wl���N���f��Q�{Y~����%�Ҧ�t��<��u�ٛ䦯q9�W�Z�^���?�Z�/a�ծ=o���Z���ۨ)R��SЫ,[ձr�uSI6UR�BzO�+�����֔��r9dg��	���X�>L
�؏Noyg�-y$Rc؜tޚ�͎"��8�$��T��E�� ��(�Z��m�R� �΢��MnGW��U�}P�����H���>���N��Xi�	��w���5
��f�����v�W��8\1������Scp�a0�@L�L4p�a��b���Ft~���c�u��v����	v��\�x��_qQ�ˎO����n1����,�tT~,q��4[�]E]_PK
     �Mh@/���  �  
  Headers.stUT	 eqXOՊXOux �  �  "======================================================================
|
|   Swazoo 2.1 HTTP request/response header components
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: HTTPHeaders [
    | fields |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    addField: aField [
	"HTTPSpec1.1 Sec4.2
	 Multiple message-header fields with the same field-name MAY be present in a message if and only if the entire field-value for that header field is defined as a comma-separated list [i.e., #(values)]. It MUST be possible to combine the multiple header fields into one 'field-name: field-value' pair, without changing the semantics of the message, by appending each subsequent field-value to the first, each separated by a comma. The order in which header fields with the same field-name are received is therefore significant to the interpretation of the combined field value, and thus a proxy MUST NOT change the order of these field values when a message is forwarded.
	 Note that we have to use the field name here as we may be adding a field for which there is no class, i.e. it's a GenericHeaderField."

	<category: 'services'>
	(self includesFieldNamed: aField name) 
	    ifTrue: [(self fieldNamed: aField name) combineWith: aField]
	    ifFalse: [self fields at: aField name asUppercase put: aField].
	^self
    ]

    fieldNamed: aString [
	"^aString
	 If I contain a field named aString, I return it.  Otherwise an exception is thrown.
	 This is a bad way of getting a field.  Use >> fieldOfClass: instead."

	<category: 'services'>
	| targetString |
	targetString := aString asUppercase.
	^self fields detect: [:aField | aField name asUppercase = targetString]
    ]

    fieldNamed: aString ifNone: aBlock [
	"^aString
	 If I contain a field named aString, I return it.  Otherwise I evaluate aBlock."

	<category: 'services'>
	^self fields at: aString asUppercase ifAbsent: aBlock
    ]

    fieldNamed: aFieldName ifPresent: presentBlock ifAbsent: absentBlock [
	"^an Object
	 I look for a field named aFieldName among my fields.  If I find it, I return the result of evaluating presentBlock with the found field as an argument, otherwise I return the result of evaluate the absentBlock"

	<category: 'services'>
	| foundField |
	foundField := self fieldNamed: aFieldName ifNone: [nil].
	^foundField isNil 
	    ifTrue: [absentBlock value]
	    ifFalse: [presentBlock value: foundField]
    ]

    fieldOfClass: aClass [
	"^aString
	 If I contain a field of class aClass, I return it.   Otherwise an exception is thrown."

	<category: 'services'>
	^self fields detect: [:aField | aField class == aClass] ifNone: [^nil]
    ]

    fieldOfClass: aClass ifNone: aBlock [
	"^aString
	 If I contain a field of class aClass, I return it.   Otherwise I evaluate aBlock."

	<category: 'services'>
	^self fields detect: [:aField | aField class == aClass] ifNone: aBlock
    ]

    fieldOfClass: fieldClass ifPresent: presentBlock ifAbsent: absentBlock [
	"^an Object
	 I look for a field of class fieldClass among my fields.  If I find it, I return the result of evaluating presentBlock with the found field as an argument, otherwise I return the result of evaluate the absentBlock"

	<category: 'services'>
	| foundField |
	foundField := self fieldOfClass: fieldClass ifNone: [nil].
	^foundField isNil 
	    ifTrue: [absentBlock value]
	    ifFalse: [presentBlock value: foundField]
    ]

    fields [
	<category: 'private'>
	fields isNil ifTrue: [fields := Dictionary new].
	^fields
    ]

    getOrMakeFieldOfClass: aClass [
	"^a HeaderField
	 If I contain a field of class aClass, I return it.   Otherwise I create a new instance if the field class and add it to my collection of headers."

	<category: 'services'>
	^self fieldOfClass: aClass
	    ifNone: 
		[| newField |
		newField := aClass new.
		self addField: newField.
		newField]
    ]

    includesFieldNamed: aString [
	"^a Boolean
	 I return true if one of my fields has the name aString."

	<category: 'testing'>
	| targetField |
	targetField := self fieldNamed: aString ifNone: [nil].
	^targetField notNil
    ]

    includesFieldOfClass: aClass [
	"^a Boolean
	 I return true if one of my fields is of class aClass."

	<category: 'testing'>
	^self 
	    fieldOfClass: aClass
	    ifPresent: [:aField | true]
	    ifAbsent: [false]
    ]

    printOn: aStream [
	<category: 'private'>
	aStream
	    nextPutAll: 'a HTTPHeaders';
	    cr.
	self fields values do: 
		[:each | 
		aStream
		    nextPutAll: '   ' , each printString;
		    cr]
    ]
]



Object subclass: HeaderField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HeaderField class [
	| httpFieldNameToClassDictionary |
	
    ]

    HeaderField class >> classForFieldName: aString [
	"^a Class
	 If I can find a specific header field with a name matching aString I return that.  Otherwise I return the GenericHeaderField class."

	<category: 'private'>
	^self httpFieldNameToClassDictionary at: aString
	    ifAbsent: [GenericHeaderField]
    ]

    HeaderField class >> fromLine: aString [
        "for testing only"
 	<category: 'instance creation'>
 	| sourceStream fieldName fieldValue |
 	sourceStream := ReadStream on: aString.
 	fieldName := sourceStream upTo: $:.
 	fieldValue := sourceStream upToEnd.
 	^self name: fieldName value: fieldValue
    ]

    HeaderField class >> name: fieldName value: fieldValue [
	<category: 'instance creation'>
	| upName trimValue fieldClass |
	upName := (HTTPString trimBlanksFrom: fieldName) asUppercase.
	fieldClass := self classForFieldName: upName.
	trimValue := HTTPString trimBlanksFrom: fieldValue.
	^fieldClass newForFieldName: upName withValueFrom: trimValue
    ]

    HeaderField class >> httpFieldNameToClassDictionary [
	"^a Class
	 I return the dictionarry of my subclasses keyed on the name of the field they represent.
	 Note that we only need *Request* headers listed in here because they are the only thing we will be parsing for."

	"After a change here, remeber to do 'HeaderField resetHttpFieldNameToClassDictionary'"

	<category: 'private'>
	httpFieldNameToClassDictionary isNil 
	    ifTrue: 
		[| headerClasses |
		headerClasses := OrderedCollection new.
		headerClasses
		    add: ContentDispositionField;
		    add: HTTPContentLengthField;
		    add: ContentTypeField;
		    add: HTTPAcceptField;
		    add: HTTPAuthorizationField;
		    add: HTTPConnectionField;
		    add: HTTPHostField;
		    add: HTTPIfMatchField;
		    add: HTTPIfModifiedSinceField;
		    add: HTTPIfNoneMatchField;
		    add: HTTPIfRangeField;
		    add: HTTPIfUnmodifiedSinceField;
		    add: HTTPRefererField;
		    add: HTTPUserAgentField.
		httpFieldNameToClassDictionary := Dictionary new.
		headerClasses do: 
			[:aClass | 
			httpFieldNameToClassDictionary at: aClass fieldName asUppercase put: aClass]].
	^httpFieldNameToClassDictionary
    ]

    HeaderField class >> newForFieldName: fieldNameString withValueFrom: fieldValueString [
	<category: 'private'>
	^self subclassResponsibility
    ]

    HeaderField class >> resetHttpFieldNameToClassDictionary [
	<category: 'private'>
	httpFieldNameToClassDictionary := nil.
	^self
    ]

    combineWith: aHeaderField [
	<category: 'services'>
	SwazooHeaderFieldParseError raiseSignal: 'Not supported'
    ]

    fieldName [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    isConditional [
	<category: 'testing'>
	^false
    ]

    isContentDisposition [
	<category: 'testing'>
	^false
    ]

    isContentType [
	<category: 'testing'>
	^false
    ]

    name [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: self name;
	    nextPutAll: ': '.
	self valuesAsStringOn: aStream.
	^self
    ]

    values [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    valuesAsString [
	<category: 'printing'>
	| targetStream |
	targetStream := WriteStream on: String new.
	self valuesAsStringOn: targetStream.
	^targetStream contents
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	^self subclassResponsibility
    ]
]



HeaderField subclass: GenericHeaderField [
    | name value |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    GenericHeaderField class >> newForFieldName: fieldNameString withValueFrom: fieldValueString [
	<category: 'instance creation'>
	^self new forFieldName: fieldNameString andValue: fieldValueString
    ]

    combineWith: aHeaderField [
	"^self
	 I simply take my values and concatenate the values of aHeaderField."

	<category: 'services'>
	value := self value , ', ' , aHeaderField value.
	^self
    ]

    fieldName [
	<category: 'accessing'>
	1 halt: 'use >>name instead'.
	^self name
    ]

    forFieldName: fieldNameString andValue: fieldValueString [
	<category: 'initialize-release'>
	name := fieldNameString.
	value := fieldValueString.
	^self
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    values [
	<category: 'accessing'>
	^(HTTPString subCollectionsFrom: self value delimitedBy: $,) 
	    collect: [:each | HTTPString trimBlanksFrom: each]
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: value.
	^self
    ]
]



HeaderField subclass: SpecificHeaderField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    SpecificHeaderField class >> fieldName [
	<category: 'accessing'>
	^self subclassResponsibility
    ]

    SpecificHeaderField class >> newForFieldName: fieldNameString withValueFrom: fieldValueString [
	<category: 'private'>
	^self newWithValueFrom: fieldValueString
    ]

    SpecificHeaderField class >> newWithValueFrom: fieldValueString [
	<category: 'private'>
	^self new valueFrom: fieldValueString
    ]

    name [
	<category: 'accessing'>
	^self class fieldName
    ]

    parameterAt: aString ifAbsent: aBlock [
	<category: 'accessing'>
	1 halt: 'use the transfer encodings of the field, not this'.
	^self parameters at: aString ifAbsent: aBlock
    ]

    parseValueFrom: aString [
	<category: 'private'>
	^self subclassResponsibility
    ]

    readParametersFrom: sourceStream [
	"^a Dictionary
	 c.f. RFC 2616 3.6 Transfer Codings"

	<category: 'private'>
	| parameters |
	parameters := Dictionary new.
	[sourceStream atEnd] whileFalse: 
		[| attribute value |
		attribute := HTTPString trimBlanksFrom: (sourceStream upTo: $=).
		value := HTTPString trimBlanksFrom: (sourceStream upTo: $;).
		parameters at: attribute put: value].
	^parameters
    ]

    valueFrom: fieldValueString [
	<category: 'initialize-release'>
	self parseValueFrom: fieldValueString.
	^self
    ]

    values [
	<category: 'accessing'>
	^Array with: self value
    ]
]



SpecificHeaderField subclass: ContentDispositionField [
    | type parameters |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    ContentDispositionField class >> fieldName [
	<category: 'accessing'>
	^'Content-Disposition'
    ]

    isContentDisposition [
	<category: 'testing'>
	^true
    ]

    parameterAt: aString [
	<category: 'services'>
	^parameters at: aString ifAbsent: [nil]
    ]

    parseValueFrom: aString [
	<category: 'private'>
	| sourceStream |
	sourceStream := aString readStream.
	type := HTTPString trimBlanksFrom: (sourceStream upTo: $;).
	parameters := self readParametersFrom: sourceStream.
	^self
    ]
]



SpecificHeaderField subclass: ContentTypeField [
    | mediaType transferCodings |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    ContentTypeField class >> fieldName [
	<category: 'accessing'>
	^'Content-Type'
    ]

    defaultMediaType [
	"^a String
	 See RFC 2616 '7.2.1 Type'.  If no media type is specified, application/octet-stream is the default."

	<category: 'accessing'>
	^'application/octet-stream'
    ]

    isContentType [
	<category: 'testing'>
	^true
    ]

    mediaType [
	<category: 'accessing'>
	^mediaType isNil ifTrue: [self defaultMediaType] ifFalse: [mediaType]
    ]

    mediaType: aString [
	<category: 'accessing'>
	mediaType := aString.
	^self
    ]

    parseValueFrom: aString [
	<category: 'private'>
	| sourceStream |
	sourceStream := aString readStream.
	mediaType := HTTPString trimBlanksFrom: (sourceStream upTo: $;).
	transferCodings := self readParametersFrom: sourceStream.
	^self
    ]

    transferCodings [
	<category: 'accessing'>
	transferCodings isNil ifTrue: [transferCodings := String new].
	^transferCodings
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self mediaType.
	self transferCodings isEmpty 
	    ifFalse: 
		[self transferCodings keysAndValuesDo: 
			[:name :value | 
			aStream
			    nextPutAll: ' ';
			    nextPutAll: name;
			    nextPut: $=;
			    nextPutAll: value]].
	^self
    ]
]



SpecificHeaderField subclass: HTTPAcceptField [
    | mediaTypes |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPAcceptField class >> fieldName [
	<category: 'accessing'>
	^'Accept'
    ]

    combineWith: aHeaderField [
	"^self
	 I simply take my values and concatenate the values of aHeaderField."

	<category: 'services'>
	self mediaTypes addAll: aHeaderField mediaTypes.
	^self
    ]

    mediaTypes [
	<category: 'accessing'>
	mediaTypes isNil ifTrue: [mediaTypes := OrderedCollection new].
	^mediaTypes
    ]

    parseValueFrom: aString [
	<category: 'private'>
	mediaTypes := HTTPString subCollectionsFrom: aString delimitedBy: $,.
	^self
    ]

    valuesAsStringOn: targetStream [
	<category: 'printing'>
	self mediaTypes isEmpty 
	    ifFalse: 
		[targetStream nextPutAll: self mediaTypes first.
		2 to: self mediaTypes size
		    do: 
			[:methodIndex | 
			targetStream
			    nextPut: $,;
			    nextPutAll: (self mediaTypes at: methodIndex)]].
	^self
    ]
]



SpecificHeaderField subclass: HTTPAllowField [
    | methods |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPAllowField class >> fieldName [
	<category: 'accessing'>
	^'Allow'
    ]

    methods [
	<category: 'accessing'>
	methods isNil ifTrue: [methods := OrderedCollection new].
	^methods
    ]

    valuesAsStringOn: targetStream [
	<category: 'printing'>
	self methods isEmpty 
	    ifFalse: 
		[targetStream nextPutAll: self methods first.
		2 to: self methods size
		    do: 
			[:methodIndex | 
			targetStream
			    nextPut: $,;
			    nextPutAll: (self methods at: methodIndex)]].
	^self
    ]
]



SpecificHeaderField subclass: HTTPAuthorizationField [
    | credentials |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPAuthorizationField class >> fieldName [
	<category: 'accessing'>
	^'Authorization'
    ]

    HTTPAuthorizationField class >> newForFieldName: fieldNameString withValueFrom: fieldValueString [
	"^an HTTPAuthorizationField
	 I return an instance of one of my concrete subclasses.  To get to this point, the field name *must* be 'AUTHORIZATION'."

	<category: 'private'>
	| sourceStream schemeName |
	sourceStream := ReadStream on: fieldValueString.
	schemeName := sourceStream upTo: Character space.
	^schemeName = 'Basic' 
	    ifTrue: [HTTPAuthorizationBasicField newWithValueFrom: sourceStream upToEnd]
	    ifFalse: [HTTPAuthorizationDigestField newWithValueFrom: sourceStream upToEnd]
    ]

    credentials [
	<category: 'accessing'>
	^credentials
    ]

    parseValueFrom: aString [
	<category: 'private'>
	credentials := HTTPString trimBlanksFrom: aString.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self credentials.
	^self
    ]
]



HTTPAuthorizationField subclass: HTTPAuthorizationBasicField [
    | userid password |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    password [
	"^a String
	 I return the password string (as defined in RFC 2617 pp.2) part of the user-pass value in my credentials."

	<category: 'services'>
	password isNil ifTrue: [self resolveUserPass].
	^password
    ]

    resolveUserPass [
	"^self
	 I look at my credentials string and pull out the userid and password.  Note that having to check for atEnd before the upToEnd is for GemStone which crashes if upToEnd is used when already atEnd."

	"(Base64EncodingReadStream on: 'YnJ1Y2U6c3F1aWRzdXBwbGllZHBhc3N3b3Jk' ) upToEnd asString"

	<category: 'private'>
	| userPassString sourceStream |
	userPassString := userPassString := Base64MimeConverter 
			    mimeDecode: self credentials
			    as: String.
	sourceStream := ReadStream on: userPassString.
	userid := sourceStream upTo: $:.
	password := sourceStream atEnd 
		    ifTrue: [String new]
		    ifFalse: [sourceStream upToEnd].
	^self
    ]

    userid [
	"^a String
	 I return the userid string (as defined in RFC 2617 pp.2) part of the user-pass value in my credentials."

	<category: 'services'>
	userid isNil ifTrue: [self resolveUserPass].
	^userid
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'Basic '.
	super valuesAsStringOn: aStream.
	^self
    ]
]



HTTPAuthorizationField subclass: HTTPAuthorizationDigestField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: 'Digest '.
	super valuesAsStringOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPCacheControlField [
    | directives private maxAge noStore noCache mustRevalidate |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPCacheControlField class >> fieldName [
	<category: 'accessing'>
	^'Cache-Control'
    ]

    directives [
	"for easy setting directives in one string"

	<category: 'accessing'>
	^directives
    ]

    directives: aString [
	"for easy setting directives in one string"

	"example: 'no-store, no-cache, must-revalidate'"

	<category: 'accessing'>
	directives := aString
    ]

    maxAge [
	"^an Integer or nil
	 I return my max age which is either an integer number of seconds for which the entity can be considdered fresh, or nil, in which case other headers such as Expires can be used by a cache to determine the expiration time of the entity."

	<category: 'accessing'>
	^maxAge
    ]

    maxAge: anIntegerOrNil [
	"^self
	 I record the number of seconds for which the resource is 'fresh' and after which will expire and become 'stale' for caching purposes.  Setting this to nil means the max age is unspecified, and this is the default.  This directive takes presidence over any Expires header when a cache or client is handling an HTTP message."

	<category: 'services'>
	maxAge := anIntegerOrNil.
	^self
    ]

    private [
	"^a Boolean or nil
	 There are three possible values for private.  Explicity true (the entity can only be cached in private caches), explicity false (this is a public entity and can be held in a shared/public cache perhaps even when stale) or nil (the default which means that the entity may be held in a public shared cache, but only until it goes stale)."

	<category: 'accessing'>
	^private
    ]

    setNotPublicOrPrivate [
	"^self
	 I am being told that the entity in my message is not explicity public or private.  This is the default and means that public caches may retain copies of the resource, but should not be as relaxed about the rules as with an explicitly public resource. c.f >>setPublic & >>setPrivate."

	<category: 'services'>
	private := nil.
	^self
    ]

    setPrivate [
	"^self
	 I am being told that the entity in my message is a private one that can only be cached on private caches, i.e. caches that can be drawn upon a single clients.  An example of a private cache is the one *inside* your web browser.   This is probably what you want if the entity contains personal information."

	<category: 'services'>
	private := true.
	^self
    ]

    setPublic [
	"^self
	 I am being told that the entity in my message is a public one that can be cached on public caches, i.e. caches that can be drawn upon by many clients.  This is probably not what you want if the entity contains personal information!!  c.f. >>setPrivate  Note that expicitly setting cache-control public actually loosens some other rules and means resources can be used by cached beyond their normal life."

	<category: 'services'>
	private := false.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPut: Character space.
	self directives notNil ifTrue: [aStream nextPutAll: self directives].
	self private notNil 
	    ifTrue: 
		[self writePublicOrPrivateTo: aStream.
		self maxAge notNil ifTrue: [aStream nextPutAll: ', ']].
	self maxAge notNil ifTrue: [self writeMaxAgeTo: aStream].
	^self
    ]

    writeMaxAgeTo: aStream [
	"^self
	 I write the maxAge directive to aStream"

	<category: 'printing'>
	aStream nextPutAll: 'max-age='.
	self maxAge printOn: aStream.
	^self
    ]

    writePublicOrPrivateTo: aStream [
	"^self
	 I write the either the public or the private directive to aStream"

	<category: 'printing'>
	self private 
	    ifTrue: [aStream nextPutAll: 'private']
	    ifFalse: [aStream nextPutAll: 'public'].
	^self
    ]
]



SpecificHeaderField subclass: HTTPConnectionField [
    | connectionToken |
    
    <category: 'Swazoo-Headers'>
    <comment: 'c.f. RFC 2616 14.10

   The Connection header has the following grammar:

       Connection = "Connection" ":" 1#(connection-token)
       connection-token  = token

'>

    HTTPConnectionField class >> fieldName [
	<category: 'accessing'>
	^'Connection'
    ]

    connectionToken [
	"^a String
	 Common values are 'close' and 'keep-alive'."

	<category: 'accessing'>
	^connectionToken
    ]

    connectionToken: aString [
	"^self"

	<category: 'accessing'>
	connectionToken := aString.
	^self
    ]

    connectionTokenIsClose [
	<category: 'testing'>
	^self connectionToken = 'close'
    ]

    parseValueFrom: aString [
	<category: 'private'>
	connectionToken := HTTPString trimBlanksFrom: aString.
	^self
    ]

    setToClose [
	<category: 'services'>
	self connectionToken: 'close'.
	^self
    ]

    setToKeepAlive [
	<category: 'services'>
	self connectionToken: 'keep-alive'.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: connectionToken.
	^self
    ]
]



SpecificHeaderField subclass: HTTPContentLengthField [
    | contentLength |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPContentLengthField class >> fieldName [
	<category: 'accessing'>
	^'Content-Length'
    ]

    contentLength [
	<category: 'accessing'>
	^contentLength
    ]

    contentLength: anInteger [
	<category: 'accessing'>
	contentLength := anInteger
    ]

    parseValueFrom: aString [
	<category: 'private'>
	contentLength := aString asNumber.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self contentLength printOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPCookieField [
    | values |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPCookieField class >> fieldName [
	<category: 'accessing'>
	^'Cookie'
    ]
]



SpecificHeaderField subclass: HTTPDateField [
    | date |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPDateField class >> fieldName [
	<category: 'accessing'>
	^'Date'
    ]

    date [
	<category: 'accessing'>
	^date
    ]

    date: aDate [
	"^self
	 Note that this is an HTTP Date, and so is really a timestamp :-/"

	<category: 'accessing'>
	date := aDate.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self date asRFC1123StringOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPETagField [
    | entityTag |
    
    <category: 'Swazoo-Headers'>
    <comment: 'RFC 2626 14.19 ETag

   The ETag response-header field provides the current value of the
   entity tag for the requested variant. The headers used with entity
   tags are described in sections 14.24, 14.26 and 14.44. The entity tag
   MAY be used for comparison with other entities from the same resource
   (see section 13.3.3).

      ETag = "ETag" ":" entity-tag

   Examples:

      ETag: "xyzzy"
      ETag: W/"xyzzy"
      ETag: ""

'>

    HTTPETagField class >> fieldName [
	<category: 'accessing'>
	^'ETag'
    ]

    entityTag [
	<category: 'accessing'>
	^entityTag
    ]

    entityTag: aString [
	<category: 'accessing'>
	entityTag := aString.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $";
	    nextPutAll: self entityTag;
	    nextPut: $".
	^self
    ]
]



SpecificHeaderField subclass: HTTPExpiresField [
    | timestamp |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPExpiresField class >> fieldName [
	<category: 'accessing'>
	^'Expires'
    ]

    timestamp [
	<category: 'accessing'>
	^timestamp
    ]

    timestamp: aTimestamp [
	<category: 'accessing'>
	timestamp := aTimestamp
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self timestamp asRFC1123StringOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPHostField [
    | hostName portNumber |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPHostField class >> fieldName [
	<category: 'accessing'>
	^'Host'
    ]

    hostName [
	<category: 'accessing'>
	^hostName
    ]

    parseValueFrom: aString [
	<category: 'private'>
	| sourceStream portNumberString |
	sourceStream := ReadStream on: aString.
	hostName := sourceStream upTo: $:.
	portNumberString := sourceStream atEnd 
		    ifTrue: [String new]
		    ifFalse: [sourceStream upToEnd].
	portNumberString notEmpty 
	    ifTrue: [portNumber := portNumberString asNumber].
	^self
    ]

    portNumber [
	<category: 'accessing'>
	^portNumber isNil ifTrue: [80] ifFalse: [portNumber]
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self hostName.
	portNumber notNil 
	    ifTrue: 
		[aStream nextPut: $:.
		self portNumber printOn: aStream].
	^self
    ]
]



SpecificHeaderField subclass: HTTPIfModifiedSinceField [
    | date |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPIfModifiedSinceField class >> fieldName [
	<category: 'accessing'>
	^'If-Modified-Since'
    ]

    date [
	<category: 'accessing'>
	^date
    ]

    isCacheHitFor: anEntity [
	"^a Boolean
	 I return true if an anEntity is a cache hit given the conditional I represent.  So in my case, I'm looking to see that the entity has not changed since my date.
	 anEntity *must* respond to >>lastModified"

	<category: 'testing'>
	^anEntity lastModified <= self date
    ]

    isConditional [
	<category: 'testing'>
	^true
    ]

    parseValueFrom: aString [
	<category: 'private'>
	date := SpTimestamp fromRFC1123String: aString.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self date notNil ifTrue: [self date asRFC1123StringOn: aStream].
	^self
    ]
]



SpecificHeaderField subclass: HTTPIfRangeField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPIfRangeField class >> fieldName [
	<category: 'accessing'>
	^'If-Range'
    ]
]



SpecificHeaderField subclass: HTTPIfUnmodifiedSinceField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPIfUnmodifiedSinceField class >> fieldName [
	<category: 'accessing'>
	^'If-Unmodified-Since'
    ]

    isCacheHitFor: anEntity [
	"^a Boolean
	 I return true if an anEntity is a cache hit given the conditional I represent.
	 anEntity *must* respond to >>entutyTag"

	<category: 'testing'>
	1 halt.
	^self
    ]

    isConditional [
	<category: 'testing'>
	^true
    ]
]



SpecificHeaderField subclass: HTTPLastModifiedField [
    | timestamp |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPLastModifiedField class >> fieldName [
	<category: 'accessing'>
	^'Last-Modified'
    ]

    timestamp [
	<category: 'accessing'>
	^timestamp
    ]

    timestamp: aTimestamp [
	<category: 'accessing'>
	timestamp := aTimestamp
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self timestamp asRFC1123StringOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPLocationField [
    | uri |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPLocationField class >> fieldName [
	<category: 'accessing'>
	^'Location'
    ]

    uri [
	<category: 'accessing'>
	^uri
    ]

    uri: aSwazooURI [
	<category: 'accessing'>
	uri := aSwazooURI.
	^self
    ]

    uriString: aString [
	<category: 'accessing'>
	uri := SwazooURI fromString: aString.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self uri printOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPMatchField [
    | entityTags |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    addEntityTag: aString [
	<category: 'services'>
	self entityTags add: aString.
	^self
    ]

    combineWith: aHeaderField [
	"^self
	 I add the entity tags of aHeaderField to my own collection of entity tags."

	<category: 'services'>
	self entityTags addAll: aHeaderField entityTags.
	^self
    ]

    entityTags [
	<category: 'accessing'>
	^self matchesAnyCurrentEntity 
	    ifTrue: [nil]
	    ifFalse: 
		[entityTags isNil ifTrue: [entityTags := OrderedCollection new].
		entityTags]
    ]

    isConditional [
	<category: 'testing'>
	^true
    ]

    matchesAnyCurrentEntity [
	<category: 'testing'>
	^entityTags = '*'
    ]

    parseValueFrom: aString [
	<category: 'private'>
	aString = '*' 
	    ifTrue: [entityTags := aString]
	    ifFalse: 
		[| sourceStream |
		entityTags := OrderedCollection new.
		sourceStream := ReadStream on: aString.
		[sourceStream atEnd] whileFalse: 
			[| entityTag |
			sourceStream upTo: $".
			entityTag := sourceStream upTo: $".
			entityTags add: entityTag.
			sourceStream upTo: $,]].
	^self
    ]

    valuesAsStringOn: targetStream [
	<category: 'printing'>
	self write: self entityTags first asQuotedStringTo: targetStream.
	2 to: self entityTags size
	    do: 
		[:tagIndex | 
		targetStream nextPut: $,.
		self write: (self entityTags at: tagIndex) asQuotedStringTo: targetStream].
	^self
    ]

    write: aString asQuotedStringTo: targetStream [
	"^self
	 See RFC 2616 2.2"

	<category: 'printing'>
	targetStream nextPut: $".
	aString do: 
		[:character | 
		character == $" 
		    ifTrue: [targetStream nextPutAll: '\"']
		    ifFalse: [targetStream nextPut: character]].
	targetStream nextPut: $".
	^self
    ]
]



HTTPMatchField subclass: HTTPIfMatchField [
    
    <category: 'Swazoo-Headers'>
    <comment: 'From RFC 2616

14.24 If-Match

   The If-Match request-header field is used with a method to make it
   conditional. A client that has one or more entities previously
   obtained from the resource can verify that one of those entities is
   current by including a list of their associated entity tags in the
   If-Match header field. Entity tags are defined in section 3.11. The
   purpose of this feature is to allow efficient updates of cached
   information with a minimum amount of transaction overhead. It is also
   used, on updating requests, to prevent inadvertent modification of
   the wrong version of a resource. As a special case, the value "*"
   matches any current entity of the resource.

       If-Match = "If-Match" ":" ( "*" | 1#entity-tag )

   If any of the entity tags match the entity tag of the entity that
   would have been returned in the response to a similar GET request
   (without the If-Match header) on that resource, or if "*" is given

   and any current entity exists for that resource, then the server MAY
   perform the requested method as if the If-Match header field did not
   exist.

   A server MUST use the strong comparison function (see section 13.3.3)
   to compare the entity tags in If-Match.

   If none of the entity tags match, or if "*" is given and no current
   entity exists, the server MUST NOT perform the requested method, and
   MUST return a 412 (Precondition Failed) response. This behavior is
   most useful when the client wants to prevent an updating method, such
   as PUT, from modifying a resource that has changed since the client
   last retrieved it.

   If the request would, without the If-Match header field, result in
   anything other than a 2xx or 412 status, then the If-Match header
   MUST be ignored.

   The meaning of "If-Match: *" is that the method SHOULD be performed
   if the representation selected by the origin server (or by a cache,
   possibly using the Vary mechanism, see section 14.44) exists, and
   MUST NOT be performed if the representation does not exist.

   A request intended to update a resource (e.g., a PUT) MAY include an
   If-Match header field to signal that the request method MUST NOT be
   applied if the entity corresponding to the If-Match value (a single
   entity tag) is no longer a representation of that resource. This
   allows the user to indicate that they do not wish the request to be
   successful if the resource has been changed without their knowledge.
   Examples:

       If-Match: "xyzzy"
       If-Match: "xyzzy", "r2d2xxxx", "c3piozzzz"
       If-Match: *

   The result of a request having both an If-Match header field and
   either an If-None-Match or an If-Modified-Since header fields is
   undefined by this specification.

'>

    HTTPIfMatchField class >> fieldName [
	<category: 'accessing'>
	^'If-Match'
    ]

    isCacheHitFor: anEntity [
	"^a Boolean
	 I return true if an anEntity is a cache hit given the conditional I represent.
	 anEntity *must* respond to >>entutyTag"

	<category: 'testing'>
	1 halt.
	^self
    ]
]



HTTPMatchField subclass: HTTPIfNoneMatchField [
    
    <category: 'Swazoo-Headers'>
    <comment: 'This is a confitional header field.  The HTTP client is asking for a resource on the basis of this condition.  So, we need to have first found the resource, and then we can considder the condition, as follows ...

From RFC 2616:

14.26 If-None-Match

   The If-None-Match request-header field is used with a method to make
   it conditional. A client that has one or more entities previously
   obtained from the resource can verify that none of those entities is
   current by including a list of their associated entity tags in the
   If-None-Match header field. The purpose of this feature is to allow
   efficient updates of cached information with a minimum amount of
   transaction overhead. It is also used to prevent a method (e.g. PUT)
   from inadvertently modifying an existing resource when the client
   believes that the resource does not exist.

   As a special case, the value "*" matches any current entity of the
   resource.

       If-None-Match = "If-None-Match" ":" ( "*" | 1#entity-tag )

   If any of the entity tags match the entity tag of the entity that
   would have been returned in the response to a similar GET request
   (without the If-None-Match header) on that resource, or if "*" is
   given and any current entity exists for that resource, then the
   server MUST NOT perform the requested method, unless required to do
   so because the resource''s modification date fails to match that
   supplied in an If-Modified-Since header field in the request.
   Instead, if the request method was GET or HEAD, the server SHOULD
   respond with a 304 (Not Modified) response, including the cache-
   related header fields (particularly ETag) of one of the entities that
   matched. For all other request methods, the server MUST respond with
   a status of 412 (Precondition Failed).

   See section 13.3.3 for rules on how to determine if two entities tags
   match. The weak comparison function can only be used with GET or HEAD
   requests.

   If none of the entity tags match, then the server MAY perform the
   requested method as if the If-None-Match header field did not exist,
   but MUST also ignore any If-Modified-Since header field(s) in the
   request. That is, if no entity tags match, then the server MUST NOT
   return a 304 (Not Modified) response.

   If the request would, without the If-None-Match header field, result
   in anything other than a 2xx or 304 status, then the If-None-Match
   header MUST be ignored. (See section 13.3.4 for a discussion of
   server behavior when both If-Modified-Since and If-None-Match appear
   in the same request.)

   The meaning of "If-None-Match: *" is that the method MUST NOT be
   performed if the representation selected by the origin server (or by
   a cache, possibly using the Vary mechanism, see section 14.44)
   exists, and SHOULD be performed if the representation does not exist.
   This feature is intended to be useful in preventing races between PUT
   operations.

   Examples:

       If-None-Match: "xyzzy"
       If-None-Match: W/"xyzzy"
       If-None-Match: "xyzzy", "r2d2xxxx", "c3piozzzz"
       If-None-Match: W/"xyzzy", W/"r2d2xxxx", W/"c3piozzzz"
       If-None-Match: *

   The result of a request having both an If-None-Match header field and
   either an If-Match or an If-Unmodified-Since header fields is
   undefined by this specification.'>

    HTTPIfNoneMatchField class >> fieldName [
	<category: 'accessing'>
	^'If-None-Match'
    ]

    isCacheHitFor: anEntity [
	"^a Boolean
	 I return true if an anEntity is a cache hit given the conditional I represent.  So in my case, I'm looking to see that the entity has a tag which is in my collection of entityTags.
	 anEntity *must* respond to >>entityTag"

	<category: 'testing'>
	^self entityTags includes: anEntity entityTag
    ]
]



SpecificHeaderField subclass: HTTPRefererField [
    | uri |
    
    <category: 'Swazoo-Headers'>
    <comment: 'RFC 2616: 14.36 Referer

   The Referer[sic] request-header field allows the client to specify,
   for the server''s benefit, the address (URI) of the resource from
   which the Request-URI was obtained (the "referrer", although the
   header field is misspelled.) The Referer request-header allows a
   server to generate lists of back-links to resources for interest,
   logging, optimized caching, etc. It also allows obsolete or mistyped
   links to be traced for maintenance. The Referer field MUST NOT be
   sent if the Request-URI was obtained from a source that does not have
   its own URI, such as input from the user keyboard.

       Referer        = "Referer" ":" ( absoluteURI | relativeURI )

   Example:

       Referer: http://www.w3.org/hypertext/DataSources/Overview.html

   If the field value is a relative URI, it SHOULD be interpreted
   relative to the Request-URI. The URI MUST NOT include a fragment. See
   section 15.1.3 for security considerations.

'>

    HTTPRefererField class >> fieldName [
	<category: 'accessing'>
	^'Referer'
    ]

    parseValueFrom: aString [
	<category: 'private'>
	uri := SwazooURI fromString: aString.
	^self
    ]

    uri [
	<category: 'accessing'>
	^uri
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	self uri printOn: aStream.
	^self
    ]
]



SpecificHeaderField subclass: HTTPServerField [
    | productTokens |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPServerField class >> fieldName [
	<category: 'accessing'>
	^'Server'
    ]

    productTokens [
	<category: 'accessing'>
	^productTokens
    ]

    productTokens: aString [
	<category: 'accessing'>
	productTokens := aString.
	^self
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self productTokens.
	^self
    ]
]



SpecificHeaderField subclass: HTTPSetCookieField [
    | cookies |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPSetCookieField class >> fieldName [
	<category: 'accessing'>
	^'Set-Cookie'
    ]

    addCookie: aCookieString [
	<category: 'services'>
	^self cookies add: aCookieString
    ]

    combineWith: aSetCookieField [
	"^self
	 I add the cookies of aSetCookieField to my own collection of cookies."

	<category: 'services'>
	self cookies addAll: aSetCookieField cookies.
	^self
    ]

    cookies [
	<category: 'accessing'>
	cookies isNil ifTrue: [cookies := OrderedCollection new].
	^cookies
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: (self cookies at: 1).
	2 to: self cookies size
	    do: 
		[:cookieIndex | 
		aStream
		    nextPutAll: ', ';
		    nextPutAll: (self cookies at: cookieIndex)].
	^self
    ]
]



SpecificHeaderField subclass: HTTPUserAgentField [
    | productTokens |
    
    <category: 'Swazoo-Headers'>
    <comment: 'RFC 2616: 14.43 User-Agent

   The User-Agent request-header field contains information about the
   user agent originating the request. This is for statistical purposes,
   the tracing of protocol violations, and automated recognition of user
   agents for the sake of tailoring responses to avoid particular user
   agent limitations. User agents SHOULD include this field with
   requests. The field can contain multiple product tokens (section 3.8)
   and comments identifying the agent and any subproducts which form a
   significant part of the user agent. By convention, the product tokens
   are listed in order of their significance for identifying the
   application.

       User-Agent     = "User-Agent" ":" 1*( product | comment )

   Example:

       User-Agent: CERN-LineMode/2.15 libwww/2.17b3'>

    HTTPUserAgentField class >> fieldName [
	<category: 'accessing'>
	^'User-Agent'
    ]

    parseValueFrom: aString [
	"^self
	 I could try and parse out the product name and version numbers, but there is no need to worry about this at the moment, so I just record the string."

	<category: 'private'>
	productTokens := HTTPString trimBlanksFrom: aString.
	^self
    ]

    productTokens [
	<category: 'accessing'>
	^productTokens
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: productTokens.
	^self
    ]
]



SpecificHeaderField subclass: HTTPWWWAuthenticateField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    HTTPWWWAuthenticateField class >> fieldName [
	<category: 'accessing'>
	^'WWW-Authenticate'
    ]

    isBasic [
	"^a Boolean
	 I return true if I represent a header for basic authentication. c.f. RFC 2617 sec 2."

	<category: 'testing'>
	^false
    ]

    isDigest [
	"^a Boolean
	 I return true if I represent a header for digest authentication. c.f. RFC 2617 sec 3."

	<category: 'testing'>
	^false
    ]
]



HTTPWWWAuthenticateField subclass: HTTPWWWAuthenticateBasicField [
    | realm |
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    isBasic [
	"^a Boolean
	 I return true if I represent a header for basic authentication. c.f. RFC 2617 sec 2."

	<category: 'testing'>
	^true
    ]

    realm [
	"^a String
	 I return the realm for which I represent an autentication challenge.  This string will be presented to the browser user in the login dialog."

	<category: 'accessing'>
	^realm
    ]

    realm: anObject [
	<category: 'accessing'>
	realm := anObject
    ]

    valuesAsStringOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: 'Basic realm="';
	    nextPutAll: self realm;
	    nextPut: $".
	^self
    ]
]



HTTPWWWAuthenticateField subclass: HTTPWWWAuthenticateDigestField [
    
    <category: 'Swazoo-Headers'>
    <comment: nil>

    isDigest [
	"^a Boolean
	 I return true if I represent a header for digest authentication. c.f. RFC 2617 sec 3."

	<category: 'testing'>
	^true
    ]
]



PK
     \h@.�>D      package.xmlUT	 ՊXOՊXOux �  �  <package>
  <name>Swazoo</name>
  <namespace>Swazoo</namespace>
  <test>
    <namespace>Swazoo</namespace>
    <prereq>SUnit</prereq>
    <prereq>Swazoo</prereq>
    <sunit>
      Swazoo.CompositeResourceTest
      Swazoo.FileResourceTest
      Swazoo.HTTPPostTest
      Swazoo.HTTPRequestTest
      Swazoo.HTTPResponseTest
      Swazoo.HTTPServerTest
      Swazoo.HeaderFieldTest
      Swazoo.HelloWorldResourceTest
      Swazoo.HomeResourceTest
      Swazoo.RedirectionResourceTest
      Swazoo.ResourceTest
      Swazoo.SiteIdentifierTest
      Swazoo.SiteTest
      Swazoo.SwazooBaseExtensionsTest
      Swazoo.SwazooBoundaryTest
      Swazoo.SwazooCacheControlTest
      Swazoo.SwazooCompilerTest
      Swazoo.SwazooConfigurationTest
      Swazoo.SwazooServerTest
      Swazoo.SwazooSocketTest
      Swazoo.SwazooStreamTest
      Swazoo.SwazooURITest
      Swazoo.URIParsingTest
      Swazoo.URIResolutionTest
    </sunit>
    <filein>Tests.st</filein>
  </test>
  <prereq>Sport</prereq>

  <filein>Exceptions.st</filein>
  <filein>Headers.st</filein>
  <filein>Messages.st</filein>
  <filein>Core.st</filein>
  <filein>Resources.st</filein>
  <filein>HTTP.st</filein>
  <filein>Protocol.st</filein>
  <filein>SCGI.st</filein>
  <filein>Extensions.st</filein>
  <file>PORTING</file>
  <start>
    %1 isNil ifTrue: [ ^Swazoo.SwazooServer start ].
    %1 ~ '^[0-9]+$' ifTrue: [ ^Swazoo.SwazooServer startOn: %1 asNumber ].
    (File name: %1) exists ifTrue: [ ^Swazoo.SwazooServer configureFrom: %1 ].
    %1 = 'swazoodemo' ifTrue: [ ^Swazoo.SwazooServer demoStart ].
    Swazoo.SwazooServer startSite: %1
  </start>
  <stop>
    %1 isNil ifTrue: [ ^Swazoo.SwazooServer stop ].
    %1 ~ '^[0-9]+$' ifTrue: [ ^Swazoo.SwazooServer stopOn: %1 asNumber ].
    Swazoo.SwazooServer stopSite: %1
  </stop>
</package>PK
     �Mh@A~�(  (    Resources.stUT	 eqXOՊXOux �  �  "======================================================================
|
|   Swazoo 2.1 HTTP response serving
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: SwazooCacheControl [
    | request cacheTarget etag lastModified |
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    addNotModifedHeaders: aResponse [
	"RFC2616 10.3.5
	 If the conditional GET used a strong cache validator (see section 13.3.3), the response SHOULD NOT include other entity-headers. ... this prevents inconsistencies between cached entity-bodies and updated headers."

	<category: 'operations'>
	self isRequestStrongValidator 
	    ifTrue: [aResponse headers addField: (HTTPETagField new entityTag: self etag)]
	    ifFalse: [self basicAddResponseHeaders: aResponse].
	^aResponse
    ]

    addResponseHeaders: aResponse [
	"Add response headers to the response.
	 We MUST differentiate between 200/302 responses"

	<category: 'operations'>
	^aResponse isNotModified 
	    ifTrue: [self addNotModifedHeaders: aResponse]
	    ifFalse: [self basicAddResponseHeaders: aResponse]
    ]

    basicAddResponseHeaders: aResponse [
	"RFC 2616 13.3.4
	 HTTP/1.1 origin servers:
	 - SHOULD send an entity tag validator unless it is not feasible to generate one.
	 - SHOULD send a Last-Modified value"

	<category: 'operations'>
	aResponse headers addField: (HTTPETagField new entityTag: self etag).
	aResponse headers 
	    addField: (HTTPLastModifiedField new timestamp: self lastModified).
	^aResponse
    ]

    cacheTarget [
	<category: 'accessing'>
	^cacheTarget
    ]

    etag [
	<category: 'accessing'>
	etag isNil ifTrue: [etag := self generateETag].
	^etag
    ]

    etag: aString [
	<category: 'accessing'>
	etag := aString
    ]

    generateETag [
	<category: 'operations'>
	^self cacheTarget etag
    ]

    generateLastModified [
	<category: 'operations'>
	^self cacheTarget lastModified
    ]

    isIfModifiedSince [
	"Answers true if either
	 - the request does not included the header
	 -or there is not a match"

	<category: 'testing'>
	| ifModifiedSince |
	ifModifiedSince := request headers fieldOfClass: HTTPIfModifiedSinceField
		    ifNone: [nil].
	^ifModifiedSince isNil or: [self lastModified > ifModifiedSince date]
    ]

    isIfNoneMatch [
	"Answers true if either
	 - the request does not included the header
	 -or there is not a match"

	<category: 'testing'>
	| field |
	field := request headers fieldOfClass: HTTPIfNoneMatchField ifNone: [nil].
	^field isNil or: [(field entityTags includes: self etag) not]
    ]

    isNotModified [
	"Compare the cacheTarget with the request headers and answer if the client's version is not modified.
	 Takes into account http version, and uses best practices defined by HTTP spec"

	<category: 'testing'>
	^self isIfNoneMatch not or: [self isIfModifiedSince not]
    ]

    isRequestStrongValidator [
	<category: 'testing'>
	| field |
	field := request headers fieldOfClass: HTTPIfNoneMatchField ifNone: [nil].
	^field notNil and: [field entityTags isEmpty not]
    ]

    lastModified [
	<category: 'testing'>
	lastModified isNil ifTrue: [lastModified := self generateLastModified].
	^lastModified
    ]

    lastModified: aRFC1123TimeStampString [
	<category: 'testing'>
	lastModified := aRFC1123TimeStampString
    ]

    request: aHTTPGet cacheTarget: anObject [
	<category: 'accessing'>
	request := aHTTPGet.
	cacheTarget := anObject
    ]
]



Object subclass: SwazooCompiler [
    | accessor |
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    SwazooCompiler class >> evaluate: aString [
	<category: 'evaluation'>
	^SpEnvironment 
	    evaluate: aString
	    receiver: SwazooCompiler
	    in: self class environment
    ]

    SwazooCompiler class >> evaluate: aString receiver: anObject [
	<category: 'evaluation'>
	^SpEnvironment 
	    evaluate: aString
	    receiver: anObject
	    in: self class environment
    ]
]



SwazooResource subclass: FileMappingResource [
    | directoryIndex filePath |
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    FileMappingResource class >> uriPattern: aString filePath: aFilePath [
	<category: 'instance creation'>
	^(self uriPattern: aString) filePath: aFilePath
    ]

    FileMappingResource class >> uriPattern: aString filePath: aFilePath directoryIndex: anotherString [
	<category: 'instance creation'>
	^(self uriPattern: aString)
	    filePath: aFilePath;
	    directoryIndex: anotherString
    ]

    answerTo: aRequest [
	<category: 'serving'>
	(self checkExistence: aRequest) ifFalse: [^nil].
	(self checkURI: aRequest) 
	    ifFalse: 
		[| response |
		response := HTTPResponse movedPermanently.
		response headers 
		    addField: (HTTPLocationField new uriString: aRequest uri identifier , '/').
		^response].
	^self file: (self fileFor: aRequest) answerTo: aRequest
    ]

    checkExistence: aRequest [
	<category: 'private'>
	(self rootFileFor: aRequest) exists ifFalse: [^false].
	^(self fileFor: aRequest) exists
    ]

    checkURI: aRequest [
	<category: 'private'>
	| needsFinalSlash |
	needsFinalSlash := (self rootFileFor: aRequest) isDirectory 
		    and: [aRequest uri isDirectory not].
	^needsFinalSlash not
    ]

    directoryIndex [
	<category: 'accessing'>
	^directoryIndex
    ]

    directoryIndex: aString [
	<category: 'accessing'>
	directoryIndex := aString
    ]

    file: aFilename answerTo: aRequest [
	<category: 'private'>
	^self subclassResponsibility
    ]

    fileDirectory [
	<category: 'private'>
	^SpFilename named: self filePath
    ]

    fileFor: aRequest [
	<category: 'private'>
	| fn |
	fn := self rootFileFor: aRequest.
	fn isDirectory ifTrue: [fn := fn construct: self directoryIndex].
	^fn
    ]

    filePath [
	<category: 'accessing'>
	^filePath
    ]

    filePath: aString [
	<category: 'accessing'>
	filePath := aString
    ]

    initialize [
	<category: 'private-initialize'>
	super initialize.
	self directoryIndex: 'index.html'
    ]

    rootFileFor: aRequest [
	<category: 'private'>
	^aRequest tailPath inject: self fileDirectory
	    into: 
		[:subPath :each | 
		(#('.' '..') includes: (HTTPString trimBlanksFrom: each)) 
		    ifTrue: [subPath]
		    ifFalse: [subPath construct: each]]
    ]
]



FileMappingResource subclass: FileResource [
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    ContentTypes := nil.

    FileResource class >> initialize [
	"self initialize"

	<category: 'class initialization'>
	ContentTypes := (Dictionary new)
		    add: '.txt' -> 'text/plain';
		    add: '.html' -> 'text/html';
		    add: '.htm' -> 'text/html';
		    add: '.css' -> 'text/css';
		    add: '.png' -> 'image/png';
		    add: '.gif' -> 'image/gif';
		    add: '.jpg' -> 'image/jpeg';
		    add: '.m3u' -> 'audio/mpegurl';
		    add: '.ico' -> 'image/x-icon';
		    add: '.pdf' -> 'application/pdf';
		    yourself
    ]

    contentTypeFor: aString [
	<category: 'private'>
	^ContentTypes at: aString ifAbsent: ['application/octet-stream']
    ]

    file: aFilename answerTo: aRequest [
	<category: 'private'>
	| cacheControl response |
	cacheControl := SwazooCacheControl new request: aRequest
		    cacheTarget: aFilename.
	response := cacheControl isNotModified 
		    ifTrue: [HTTPResponse notModified]
		    ifFalse: 
			[FileResponse ok entity: ((MimeObject new)
				    value: aFilename;
				    contentType: (self contentTypeFor: aFilename extension))].
	cacheControl addResponseHeaders: response.
	^response
    ]
]



FileResource subclass: HomeResource [
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    answerTo: aRequest [
	<category: 'accessing'>
	aRequest tailPath isEmpty ifTrue: [^nil].
	(self validateHomePath: aRequest tailPath first) ifFalse: [^nil].
	^super answerTo: aRequest
    ]

    rootFileFor: aRequest [
	<category: 'private'>
	| homeKey file |
	homeKey := aRequest tailPath first copyFrom: 2
		    to: aRequest tailPath first size.
	file := (self fileDirectory construct: homeKey) construct: 'html'.
	(aRequest tailPath copyFrom: 2 to: aRequest tailPath size) 
	    do: [:each | each = '..' ifFalse: [file := file construct: each]].
	^file
    ]

    validateHomePath: aString [
	<category: 'private'>
	^aString first = $~
    ]
]



SwazooResource subclass: HelloWorldResource [
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    answerTo: aRequest [
	<category: 'serving'>
	| response |
	response := HTTPResponse ok.
	response
	    contentType: 'text/html';
	    entity: '<html><head><title>Hello World</title></head><body>Hello World!</body></html>'.
	^response
    ]
]



SwazooResource subclass: RedirectionResource [
    | targetUri |
    
    <category: 'Swazoo-Resources'>
    <comment: nil>

    RedirectionResource class >> uriPattern: aString targetUri: bString [
	<category: 'instance creation'>
	^(self uriPattern: aString) targetUri: bString
    ]

    answerTo: aRequest [
	<category: 'serving'>
	| answer |
	answer := HTTPResponse movedPermanently.
	answer headers addField: (HTTPLocationField new uriString: self targetUri).
	^answer
    ]

    targetUri [
	<category: 'private-initialize'>
	^targetUri
    ]

    targetUri: aString [
	<category: 'private-initialize'>
	targetUri := aString
    ]
]



Eval [
    FileResource initialize
]
PK
     �Mh@�x]�6�  6�    Messages.stUT	 eqXOՊXOux �  �  "======================================================================
|
|   Swazoo 2.1 HTTP request/response framework
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: HTTPMessage [
    | task headers |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    addInitialHeaders [
	"^self
	 This is a no-op.  My subclasses may wish to add some initial headers."

	<category: 'initialize-release'>
	^self
    ]

    headers [
	<category: 'accessing'>
	headers isNil ifTrue: [self initHeaders].
	^headers
    ]

    initHeaders [
	<category: 'initialize-release'>
	headers := HTTPHeaders new.
	self addInitialHeaders
    ]

    task [
	"on which task (request/response pair) this message belongs"

	"to get a connection on which this task belongs, use task connection"

	<category: 'accessing'>
	^task
    ]

    task: aSwazooTask [
	<category: 'accessing'>
	task := aSwazooTask
    ]
]



HTTPMessage subclass: HTTPRequest [
    | requestLine peer timestamp ip environmentData resolution encrypted authenticated host |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    HTTPRequest class >> allMethodNames [
	"...of all request methods we support there"

	<category: 'accessing'>
	self subclasses collect: [:each | each methodName]
    ]

    HTTPRequest class >> methodName [
	"HTTP method used for a request"

	<category: 'accessing'>
	^self subclassResponsibility
    ]

    HTTPRequest class >> classFor: aString [
	"to support an additional http method, simply subclass a HTTPRequest!!"

	<category: 'instance creation'>
	aString = 'GET' ifTrue: [^HTTPGet	"most used anyway"].
	aString = 'POST' ifTrue: [^HTTPPost	"second most used"].

	^self subclasses detect: [:each | each methodName = aString]
	    ifNone: [^HTTPException notImplemented].
    ]

    HTTPRequest class >> readFrom: aSwazooStream [
	"For testing only (I'm guessing / hoping!!)."

	<category: 'tests support'>
	^HTTPReader readFrom: aSwazooStream
    ]

    HTTPRequest class >> request: aUriString [
	"For testing only (I'm guessing / hoping!!).  The idea to to create a request for a resource with the URI 'someHost/aUriString'."

	<category: 'tests support'>
	^self 
	    request: aUriString
	    from: 'someHost'
	    at: 'someIP'
    ]

    HTTPRequest class >> request: aUriString from: aHostString at: anIPString [
	"For testing only (I'm guessing / hoping!!).
	 A request is manufactured that has a request line method of >>methodName and a request line URI with an identifier of aUriString.  A Host header is added to the headers and the ip address is set to anIP string.
	 This may result in a corrupt or invalid request, but that's the natutre of testing, I guess."

	<category: 'tests support'>
	^self new 
	    request: aUriString
	    from: aHostString
	    at: anIPString
    ]

    authenticated [
	<category: 'private'>
	^authenticated
    ]

    conditionalHeaderFields [
	"^an OrderedCollection
	 I return my collection of conditional header fields.  A conditional GET requires that each of these is checked against the current state of the target resource."

	<category: 'services'>
	^self headers fields select: [:aField | aField isConditional]
    ]

    connection [
	<category: 'accessing-headers'>
	^(self headers fieldOfClass: HTTPConnectionField ifNone: [^nil]) 
	    connectionToken
    ]

    contentLength [
	<category: 'accessing-headers'>
	^(self headers fieldOfClass: HTTPContentLengthField) contentLength
    ]

    cookie [
	<category: 'accessing-headers'>
	| field |
	field := self headers fields at: 'COOKIE' ifAbsent: [^nil].
	^field value

	"field := self headers fieldOfClass: HTTPCookieField ifNone: [nil].
	 ^field isNil ifTrue: [nil] ifFalse: [field valuesAsString]"
    ]

    encrypted [
	<category: 'private'>
	^encrypted
    ]

    ensureFullRead [
	"that is, that everything is read from a socket stream. Importanf for HTTPost
	 and defered parsing of postData"

	<category: 'private'>
	
    ]

    environmentAt: aKey [
	<category: 'accessing'>
	^self environmentAt: aKey ifAbsent: [nil]
    ]

    environmentAt: aKey ifAbsent: aBlock [
	<category: 'accessing'>
	^self environmentData at: aKey ifAbsent: aBlock
    ]

    environmentAt: aKey put: aValue [
	<category: 'accessing'>
	self environmentData at: aKey put: aValue
    ]

    environmentData [
	<category: 'private'>
	environmentData isNil ifTrue: [self initEnvironmentData].
	^environmentData
    ]

    requestLine: aRequestLine [
	"^self
	 I parse my headers from aStream and update my URI and HTTP version information from aRequest line.  I need to parse the headers first because, for some reason, the URI insists on knowing the host, and this is taken from the Host: header field."

	<category: 'initialize-release'>
	requestLine := aRequestLine.
    ]

    hasCookie [
	"check if  Cookie:  was in request header"

	"it is GenericHeaderField!!"

	<category: 'testing'>
	^self headers fields includesKey: 'COOKIE'

	"^self headers includesFieldOfClass: HTTPCookieField"
    ]

    headerAt: aKey ifAbsent: aBlock [
	<category: 'accessing-headers'>
	^self headers fieldNamed: aKey ifNone: aBlock
    ]

    host [
	<category: 'accessing-headers'>
        host isNil ifTrue: [host := self computeHost].
        ^host
    ]

    computeHost [
	<category: 'private'>
	| value |
        value := self headers
	    fieldOfClass: HTTPHostField
	    ifPresent: [:field | field hostName]
	    ifAbsent: [self requestLine requestURI hostname].

        ^value notNil ifTrue: [value] ifFalse: ['']
    ]

    httpVersion [
	<category: 'accessing'>
	^self requestLine httpVersion
    ]

    includesQuery: aString [
	<category: 'accessing-queries'>
	^self uri includesQuery: aString
    ]

    initEnvironmentData [
	<category: 'initialize-release'>
	environmentData := Dictionary new
    ]

    initRequestLine [
	<category: 'initialize-release'>
	requestLine := HTTPRequestLine new
    ]

    ip [
	<category: 'accessing'>
	^ip
    ]

    ip: anObject [
	<category: 'private'>
	ip := anObject
    ]

    isAuthenticated [
	<category: 'testing'>
	^self authenticated isNil not
    ]

    isClose [
	<category: 'testing'>
	| connectionField |
	connectionField := self headers fieldOfClass: HTTPConnectionField
		    ifNone: [nil].
	^connectionField notNil and: [connectionField connectionTokenIsClose]
    ]

    isDelete [
	<category: 'testing'>
	^false
    ]

    isEncrypted [
	<category: 'testing'>
	^self encrypted isNil not
    ]

    isFromLinux [
	<category: 'testing'>
	^self userAgent notNil and: ['*Linux*' match: self userAgent]
    ]

    isFromMSIE [
	<category: 'testing'>
	^self userAgent notNil and: ['*MSIE*' match: self userAgent]
    ]

    isFromNetscape [
	"NS>7.0 or Mozilla or Firefox"

	<category: 'testing'>
	^self userAgent notNil and: ['*Gecko*' match: self userAgent]
    ]

    isFromWindows [
	<category: 'testing'>
	^self userAgent notNil and: ['*Windows*' match: self userAgent]
    ]

    isGet [
	<category: 'testing'>
	^false
    ]

    isHead [
	<category: 'testing'>
	^false
    ]

    isHttp10 [
	"Version of requests's HTTP protocol is 1.0"

	<category: 'testing'>
	^self requestLine isHttp10
    ]

    isHttp11 [
	"Version of requests's HTTP protocol is 1.0"

	<category: 'testing'>
	^self requestLine isHttp11
    ]

    isKeepAlive [
	<category: 'testing'>
	| header |
	header := self connection.
	header isNil ifTrue: [^false].
	^'*Keep-Alive*' match: header
    ]

    isOptions [
	<category: 'testing'>
	^false
    ]

    isPost [
	<category: 'testing'>
	^false
    ]

    isPut [
	<category: 'testing'>
	^false
    ]

    isTrace [
	<category: 'testing'>
	^false
    ]

    keepAlive [
	"how many seconds a connection must be kept alive"

	<category: 'accessing-headers'>
	^(self headers fieldNamed: 'KeepAlive' ifNone: [^nil]) value
    ]

    methodName [
	"HTTP method used for a request"

	<category: 'accessing'>
	^self class methodName
    ]

    peer [
	<category: 'accessing'>
	^peer
    ]

    peer: anObject [
	<category: 'private'>
	peer := anObject
    ]

    port [
	"^an Integer
	 I return the port number to which the request was directed."

	<category: 'accessing-headers'>
	| host |
	host := self headers fieldOfClass: HTTPHostField.
	^(host notNil and: [(self httpVersion at: 2) = 1]) 
	    ifTrue: [host portNumber]
	    ifFalse: [self requestLine requestURI port]
    ]

    printOn: aStream [
	<category: 'private'>
	aStream nextPutAll: 'a HTTPRequest ' , self methodName.
	self isHttp10 ifTrue: [aStream nextPutAll: ' HTTP/1.0'].
	self peer notNil 
	    ifTrue: 
		[aStream
		    cr;
		    tab;
		    nextPutAll: ' from: ';
		    nextPutAll: self peer hostAddressString].
	aStream
	    cr;
	    tab;
	    nextPutAll: ' at: '.
	aStream nextPutAll: self timestamp printString.
	aStream
	    cr;
	    tab;
	    nextPutAll: ' host: ';
	    nextPutAll: (self headerAt: 'Host' ifAbsent: ['']) hostName.
	aStream
	    cr;
	    tab;
	    nextPutAll: ' url: '.
	self uri printOn: aStream.
	self userAgent notNil 
	    ifTrue: 
		[aStream
		    cr;
		    tab;
		    nextPutAll: ' browser: ';
		    nextPutAll: self userAgent].
	self connection notNil 
	    ifTrue: 
		[aStream
		    cr;
		    tab;
		    nextPutAll: ' connection: ';
		    nextPutAll: self connection].
	self keepAlive notNil 
	    ifTrue: 
		[aStream
		    cr;
		    tab;
		    nextPutAll: ' keep-alive: ';
		    nextPutAll: self keepAlive].
	^self
    ]

    queries [
	<category: 'private'>
	^self uri queries
    ]

    queryAt: aKey [
	<category: 'accessing-queries'>
	^self uri queryAt: aKey
    ]

    queryAt: aKey ifAbsent: aBlock [
	<category: 'accessing-queries'>
	^self uri queryAt: aKey ifAbsent: aBlock
    ]

    queryData [
	<category: 'accessing-queries'>
	^self uri queryData
    ]

    readFrom: aSwazooStream [
	<category: 'parsing'>
    ]

    referer [
	<category: 'accessing-headers'>
	| field |
	field := self headers fieldOfClass: HTTPRefererField ifNone: [nil].
	^field isNil ifTrue: [nil] ifFalse: [field uri asString]
    ]

    request: aUriString from: aHostString at: anIPString [
	"For testing only (I'm guessing / hoping!!).
	 A request is manufactured that has a request line method of >>methodName and a request line URI with an identifier of aUriString.  A Host header is added to the headers and the ip address is set to anIP string.  I also set the HTTP version to #(1 1).
	 This may result in a corrupt or invalid request, but that's the natutre of testing, I guess."

	<category: 'private'>
	requestLine := (HTTPRequestLine new)
		    method: self class methodName;
		    requestURI: ((SwazooURI new)
				identifier: aUriString;
				yourself);
		    httpVersion: #(1 1);
		    yourself.
	self headers addField: (HTTPHostField newWithValueFrom: aHostString).
	self ip: anIPString.
	^self
    ]

    requestLine [
	"^an HTTPRequestLine"

	<category: 'accessing'>
	requestLine isNil ifTrue: [self initRequestLine].
	^requestLine
    ]

    resolution [
	<category: 'accessing'>
	^resolution
    ]

    resolution: anObject [
	<category: 'accessing'>
	resolution := anObject
    ]

    resourcePath [
	<category: 'accessing'>
	^self resolution resourcePath
    ]

    respondUsing: responseBlock [
	"^an HTTPResponse
	 By default, I let aBlock handle creating the response by passing myself as the agrument to the block.  My subclasses may override this method and directly respond.  This is most likely for Unsupported requests and for things like OPTIONS requsts.  c.f. HTTPServer>>answerTo:"

	<category: 'services'>
	^responseBlock value: self
    ]

    session [
	<category: 'accessing'>
	^self environmentAt: #session
    ]

    session: aSession [
	<category: 'accessing'>
	self environmentAt: #session put: aSession
    ]

    setAuthenticated [
	<category: 'private'>
	authenticated := true
    ]

    setEncrypted [
	<category: 'private'>
	encrypted := true
    ]

    setTimestamp [
	<category: 'initialize-release'>
	timestamp := SpTimestamp now
    ]

    streamedResponse [
	"prepares (if not already) and return a streamed response"

	"necessary because we need an output stream to stream into"

	<category: 'accessing-response'>
	self task response isNil 
	    ifTrue: 
		[self task response: (HTTPStreamedResponse on: self task
			    stream: self task connection stream)].
	self task response class == HTTPStreamedResponse 
	    ifFalse: [self error: 'not streamed response?'].	"this can happen if resp. is from before"
	^self task response
    ]

    tailPath [
	<category: 'accessing'>
	^self resolution tailPath
    ]

    timestamp [
	<category: 'accessing'>
	^timestamp
    ]

    uri [
	<category: 'accessing'>
	^self requestLine requestURI
    ]

    uriString [
	<category: 'accessing'>
	^self uri identifier
    ]

    urlString [
	<category: 'accessing'>
	^self uri value
    ]

    userAgent [
	<category: 'accessing-headers'>
	| userAgentField |
	userAgentField := self headers fieldOfClass: HTTPUserAgentField
		    ifNone: [nil].
	^userAgentField isNil ifTrue: [nil] ifFalse: [userAgentField productTokens]
    ]

    wantsConnectionClose [
	<category: 'testing'>
	self isClose ifTrue: [^true].
	^self isHttp10 and: [self isKeepAlive not]
    ]
]



HTTPRequest subclass: HTTPDelete [
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPDelete 

rfc26216 section 9.7

The DELETE method requests that the origin server delete the resource
   identified by the Request-URI. This method MAY be overridden by human
   intervention (or other means) on the origin server. The client cannot
   be guaranteed that the operation has been carried out, even if the
   status code returned from the origin server indicates that the action
   has been completed successfully. However, the server SHOULD NOT
   indicate success unless, at the time the response is given, it
   intends to delete the resource or move it to an inaccessible
   location.
 ...
'>

    HTTPDelete class >> methodName [
	"HTTP method used for a request"

	<category: 'accessing'>
	^'DELETE'
    ]

    isDelete [
	<category: 'testing'>
	^true
    ]
]



HTTPRequest subclass: HTTPGet [
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPGet 

rfc26216 section 9.3

   The GET method means retrieve whatever information (in the form of an
   entity) is identified by the Request-URI. If the Request-URI refers
   to a data-producing process, it is the produced data which shall be
   returned as the entity in the response and not the source text of the
   process, unless that text happens to be the output of the process.
'>

    HTTPGet class >> methodName [
	<category: 'accessing'>
	^'GET'
    ]

    isGet [
	<category: 'testing'>
	^true
    ]
]



HTTPRequest subclass: HTTPHead [
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPHead

rfc26216 section 9.4

   The HEAD method is identical to GET except that the server MUST NOT
   return a message-body in the response. The metainformation contained
   in the HTTP headers in response to a HEAD request SHOULD be identical
   to the information sent in response to a GET request. This method can
   be used for obtaining metainformation about the entity implied by the
   request without transferring the entity-body itself. This method is
   often used for testing hypertext links for validity, accessibility,
   and recent modification.

'>

    HTTPHead class >> methodName [
	<category: 'accessing'>
	^'HEAD'
    ]

    isHead [
	<category: 'testing'>
	^true
    ]
]



HTTPRequest subclass: HTTPOptions [
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPOptions

rfc26216 section 9.2

   The OPTIONS method represents a request for information about the
   communication options available on the request/response chain
   identified by the Request-URI. This method allows the client to
   determine the options and/or requirements associated with a resource,
   or the capabilities of a server, without implying a resource action
   or initiating a resource retrieval.

'>

    HTTPOptions class >> methodName [
	<category: 'accessing'>
	^'OPTIONS'
    ]

    isOptions [
	<category: 'testing'>
	^true
    ]

    respondUsing: responseBlock [
	"^an HTTPResponse
	 I represent a request for the options supported by this server.  I respond with a 200 (OK) and a list of my supported methods in an Allow: header.  I ignore the responseBlock."

	<category: 'services'>
	| response allowField |
	response := HTTPResponse ok.
	allowField := HTTPAllowField new.
	allowField methods addAll: self class allMethodNames.
	response headers addField: allowField.
	^response
    ]
]



HTTPRequest subclass: HTTPPost [
    | postData entityBody readPosition |
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPPost 

rfc26216 section 9.5

   The POST method is used to request that the origin server accept the
   entity enclosed in the request as a new subordinate of the resource
   identified by the Request-URI in the Request-Line.

Instance Variables:
	entityBody	<>	
	postData	<HTTPPostDataArray>	

'>

    HTTPPost class >> methodName [
	<category: 'accessing'>
	^'POST'
    ]

    applicationOctetStreamFrom: aStream [
	"^self
	 rfc 2046 says:
	 The recommended action for an implementation that receives an 'application/octet-stream' entity is to simply offer to put the data in a file, with any Content-Transfer-Encoding undone, or perhaps to use it as input to a user-specified process.
	 This method used to do a crlf -> cr conversion on the octet-stream, but was not clear why."

	<category: 'private'>
	self entityBody: (HTTPString 
		    stringFromBytes: (aStream nextBytes: self contentLength)).
	^self
    ]

    blockStreamingFrom: aSwazooStream to: outStream until: boundary [
	"detected"

	"copy by 8k blocks for optimal performance until a boundary of MIME part is detected"

	"Finish appropriatelly streaming at the end (skip crlf etc.)"

	<category: 'private-parsing support'>
	| start nrOfBoundary contents inPrevious remainingBoundary boundaryIndex |
	start := self readPosition.
	[true] whileTrue: 
		[nrOfBoundary := 0.
		[nrOfBoundary = 0] whileTrue: 
			[nrOfBoundary := aSwazooStream signsOfBoundary: boundary.
			nrOfBoundary = 0 
			    ifTrue: 
				["no boundary in current buffer content"
				self incReadPosition:
					(aSwazooStream nextPutAllBufferOn: outStream).
				self checkToEnlargeBufferIn: aSwazooStream from: start.	"for effective streaming"
				aSwazooStream fillBuffer]].
		"copy and stream out content up to potential boundary"
		boundaryIndex := aSwazooStream indexOfBoundary: boundary.
		inPrevious := aSwazooStream copyBufferTo: boundaryIndex.
		outStream 
		    nextPutAll: (inPrevious copyFrom: 1 to: (inPrevious size - 2 max: 0)).	"without potential crlf"
		self incReadPosition: inPrevious size.	"potential crlf included!!"
		nrOfBoundary = boundary size 
		    ifTrue: 
			["full boundary detected, lets finish here"

			aSwazooStream skip: boundary size.	"skip boundary"
			self incReadPosition: boundary size.
			^true].	"streaming complete"
		self incReadPosition: nrOfBoundary.
		aSwazooStream fillBuffer.	"let's get next buffer"
		remainingBoundary := boundary copyFrom: nrOfBoundary + 1 to: boundary size.
		(aSwazooStream startsWith: remainingBoundary) 
		    ifTrue: 
			["bound. ends in next buff?"

			aSwazooStream skip: remainingBoundary size + 2.	"skip remaining bound. and crlf"
			self incReadPosition: remainingBoundary size + 2.
			^true].	"streaming complete"
		outStream
		    nextPutAll: (inPrevious copyFrom: inPrevious size - 2 to: inPrevious size);
		    nextPutAll: (boundary copyFrom: 1 to: nrOfBoundary)	"potential crlf"	"boundary part in prev.buff."]	"continue from the start"
    ]

    checkToEnlargeBufferIn: aSwazooStream from: startPosition [
	"enlarge buffer to 1MB (if not already) if more than 100KB already read"

	<category: 'private-parsing support'>
	aSwazooStream readBuffer size > 100000 ifTrue: [^nil].
	self readPosition - startPosition > 100000 
	    ifTrue: [aSwazooStream enlargeReadBuffer: 1000000]
    ]

    containsHeaderNecessaryFields [
	"content type and (content length or chunked transfer encoding)"

	<category: 'private-parsing support'>
	(self headers includesFieldOfClass: ContentTypeField) ifFalse: [^false].
	(self headers includesFieldOfClass: HTTPContentLengthField) 
	    ifTrue: [^true].
	^(self headers fieldNamed: 'Transfer-encoding' ifNone: [^false]) value 
	    = 'chunked'
    ]

    emptyData [
	<category: 'accessing'>
	self ensureFullRead.
	^self postData select: [:each | each value isEmpty]
    ]

    ensureFullRead [
	"that is, everything is read from a socket stream. Important because of defered parsing
	 of postData"

	<category: 'parsing'>
	self postData isParsed 
	    ifFalse: 
		[self parsePostDataFrom: self postData stream.
		self postData setParsed]
    ]

    entityBody [
	<category: 'accessing'>
	^entityBody
    ]

    entityBody: aString [
	<category: 'private'>
	entityBody := aString
    ]

    readFrom: aSwazooStream [
	<category: 'parsing'>
	self initPostDataFor: aSwazooStream
	"self parsePostDataFrom: aSwazooStream."	"defered until first access of postData!!"
    ]

    incReadPosition [
	<category: 'private'>
	self readPosition: self readPosition + 1
    ]

    incReadPosition: anInteger [
	<category: 'private'>
	self readPosition: self readPosition + anInteger
    ]

    initPostDataFor: aSwazooStream [
	<category: 'initialize-release'>
	postData := HTTPPostDataArray newOn: aSwazooStream
    ]

    isPost [
	<category: 'testing'>
	^true
    ]

    isPostDataEmpty [
	<category: 'testing'>
	self ensureFullRead.
	^self postData isEmpty
    ]

    isPostDataStreamedAt: aKey [
	<category: 'testing'>
	^(self postData at: aKey ifAbsent: [^false]) isStreamed
    ]

    multipartDataFrom: aSwazooStream [
	"read all mime parts and put them in postData"

	"read directly from stream, without intermediate buffers"

	<category: 'private-parsing'>
	| contentTypeField boundary part |
	contentTypeField := self headers fieldOfClass: ContentTypeField
		    ifNone: [^aSwazooStream nextBytes: self contentLength].	"just skip"
	boundary := contentTypeField transferCodings at: 'boundary'
		    ifAbsent: [^aSwazooStream nextBytes: self contentLength].	"just skip"
	self skipMimePreambleAndBoundary: boundary from: aSwazooStream.
	part := #something.
	[part notNil] whileTrue: 
		[part := self partFromStream: aSwazooStream boundary: boundary.
		part notNil ifTrue: [self postDataAt: part key put: part value]].
	self skipMimeEpilogueFrom: aSwazooStream.	"all to the end  as defined by contentLegth"
	aSwazooStream nilReadBuffer.
    ]

    parsePostDataFrom: aSwazooStream [
	<category: 'parsing'>
	| mediaType |
	self containsHeaderNecessaryFields 
	    ifFalse: 
		[^SwazooHTTPPostError 
		    raiseSignal: 'Content-Type and Content-Length or chunked needed'].
	mediaType := (self headers fieldOfClass: ContentTypeField) mediaType.
	mediaType = 'application/x-www-form-urlencoded' 
	    ifTrue: [^self urlencodedDataFrom: aSwazooStream].
	mediaType = 'multipart/form-data' 
	    ifTrue: [^self multipartDataFrom: aSwazooStream].
	^self applicationOctetStreamFrom: aSwazooStream
    ]

    partFromStream: aSwazooStream boundary: aBoundaryBytes [
	"one mime part from a stream. Nil if no more multipart data"

	"Squeak specific"

	<category: 'private-parsing'>
	| bytes name filename datum contentType |
	bytes := aSwazooStream nextBytes: 2.
	self incReadPosition: 2.
	bytes = '--' asByteArray ifTrue: [^nil].	"end of multipart data"
	name := nil.
	datum := nil.
	contentType := nil.	"just to avoid compilation warning"
	[true] whileTrue: 
		["read all lines and at the end a body of that part"

		| line |
		line := 
			[(aSwazooStream upTo: Character cr asInteger) asString	"Squeak specific"] 
				on: Error
				do: [:ex | ''].	"usually nothing to read anymore), why happen this anyway?"
		self readPosition: self readPosition + line size + 1.	"cr"
		line := bytes asString , line.
		bytes := ''.
		aSwazooStream peekByte = Character lf asInteger 
		    ifTrue: 
			["this is a name line"

			| field |
			aSwazooStream nextByte.
			self incReadPosition.	"skip linefeed"
			line isEmpty 
			    ifTrue: 
				["empty line indicates start of entity"

				name isNil ifTrue: [^nil].	"name must be read in previous circle"
				datum contentType: contentType.	"completes datum's contentType read in a prev step"
				^name -> (self 
					    readEntityFrom: aSwazooStream
					    datum: datum
					    boundary: aBoundaryBytes)].
			field := HeaderField fromLine: line.
			field isContentDisposition 
			    ifTrue: 
				[name := (field parameterAt: 'name') copyWithout: $".
				datum := (self isPostDataStreamedAt: name) 
					    ifTrue: [self postData at: name	"streamed datum must exist before"]
					    ifFalse: [HTTPPostDatum new].
				contentType notNil ifTrue: [datum contentType: contentType].	"if read in prev.circle"
				filename := field parameterAt: 'filename'.	"only for file uploads"
				filename notNil ifTrue: [datum filename: (filename copyWithout: $")]].
			field isContentType ifTrue: [contentType := field mediaType]]]
    ]

    postData [
	<category: 'private'>
	^postData
    ]

    postDataAt: aKey [
	<category: 'accessing'>
	^self postDataAt: aKey ifAbsent: [nil]
    ]

    postDataAt: aKey beforeStreamingDo: aBlockClosure [
	"announce that you want to receive post data directly to a binary stream, which will be set
	 by aBlockClosure. That block must receive and argument, which is a HTTPostDatum and
	 here it can set a writeStream"

	"Fails if post data is already read"

	<category: 'accessing'>
	self postData isParsed 
	    ifTrue: 
		[^self error: 'HTTPost already parsed, streaming not possible anymore!'].
	^self postDataAt: aKey put: (HTTPPostDatum new writeBlock: aBlockClosure)
    ]

    postDataAt: aKey do: aBlock [
	<category: 'accessing'>
	| val |
	self ensureFullRead.	"defered parsing of postData"
	val := self postData at: aKey ifAbsent: [nil].
	val isNil ifFalse: [aBlock value: val]
    ]

    postDataAt: aKey ifAbsent: aBlock [
	<category: 'accessing'>
	self ensureFullRead.	"defered parsing of postData"
	^self postData at: aKey ifAbsent: aBlock
    ]

    postDataAt: aKey put: aPostDatum [
	"for testing purposes"

	<category: 'accessing'>
	self postData at: aKey put: aPostDatum
    ]

    postDataAt: aKey putString: aString [
	"for testing purposes"

	<category: 'accessing'>
	self postDataAt: aKey put: (HTTPPostDatum new value: aString)
    ]

    postDataAt: aKey streamTo: aWriteStream [
	"announce that you want to receive post data directly to aWriteStream,
	 which must be binary. Fails if post data is already read"

	<category: 'accessing'>
	self postData isParsed 
	    ifTrue: 
		[^self error: 'HTTPost already parsed, streaming not possible anymore!'].
	^self postDataAt: aKey put: (HTTPPostDatum new writeStream: aWriteStream)
    ]

    postDataKeys [
	<category: 'accessing'>
	self ensureFullRead.	"defered parsing of postData"
	^self postData keys
    ]

    postDataStringAt: aKey [
	<category: 'accessing'>
	^(self postDataAt: aKey ifAbsent: [^nil]) value
    ]

    postKeysAndValuesDo: aTwoArgBlock [
	<category: 'accessing'>
	self ensureFullRead.	"defered parsing of postData"
	self postData 
	    keysAndValuesDo: [:key :each | aTwoArgBlock value: key value: each value]
    ]

    readEntityFrom: aSwazooStream datum: aDatum boundary: aBoundaryBytes [
	"read one entity from a stream and put into datum. Stream it if streamed. Also call a block
	 (if any) just before start of streaming, with a datum as parameter. This block can then set
	 a write stream in datum (for instance open a output file and stream on it)"

	<category: 'private-parsing'>
	| outStream |
	aDatum writeBlock notNil ifTrue: [aDatum writeBlock value: aDatum].	"this should set writeStream if not already!!"
	outStream := (aDatum isStreamed and: [aDatum writeStream notNil]) 
		    ifTrue: [aDatum writeStream]
		    ifFalse: [WriteStream on: ByteArray new].
	self 
	    blockStreamingFrom: aSwazooStream
	    to: outStream
	    until: '--' , aBoundaryBytes.	"efficient streaming"
	aDatum isStreamed not 
	    ifTrue: 
		["otherwise entity is already streamed to the output"

		aDatum value: outStream contents asString].
	^aDatum
    ]

    readPosition [
	"position in a read stream. just temporary"

	<category: 'private'>
	readPosition isNil ifTrue: [^1].
	^readPosition
    ]

    readPosition: aNumber [
	<category: 'private'>
	readPosition := aNumber
    ]

    skipMimeEpilogueFrom: aSwazooStream [
	"skip a mime epilogue until end of post data defined by contentLength"

	"example:
	 --boundary--
	 This is the epilogue.  It is also to be ignored
	 "

	<category: 'private-parsing support'>
	[self readPosition < self contentLength] whileTrue: 
		[aSwazooStream next.	"just skip"
		self incReadPosition]
    ]

    skipMimePreambleAndBoundary: aBoundaryBytes from: aSwazooStream [
	"skip a mime preamble until first boundary starts then skip that boundary too"

	"example:
	 Content-type: multipart/mixed; boundary=''boundary''
	 
	 This is the preamble.  It is to be ignored, though it is
	 a handy place to include an explanatory note to non-MIME compliant readers.
	 --boundary
	 ..."

	<category: 'private-parsing support'>
	| dummy |
	dummy := WriteStream on: ByteArray new.
	self 
	    blockStreamingFrom: aSwazooStream
	    to: dummy
	    until: '--' , aBoundaryBytes
    ]

    urlencodedDataFrom: aStream [
	<category: 'private-parsing'>
	| entity tokens |
	(self headers includesFieldOfClass: HTTPContentLengthField) 
	    ifFalse: [^self].
	entity := aStream nextBytes: self contentLength.
	tokens := HTTPString 
		    subCollectionsFrom: (HTTPString stringFromBytes: entity)
		    delimitedBy: $&.
	(tokens 
	    collect: [:each | HTTPString subCollectionsFrom: each delimitedBy: $=]) 
		do: 
		    [:keyVal | 
		    | datum key |
		    datum := HTTPPostDatum new.
		    datum 
			value: (HTTPString decodedHTTPFrom: (keyVal last 
					collect: [:char | char = $+ ifTrue: [Character space] ifFalse: [char]])).
		    key := HTTPString decodedHTTPFrom: (keyVal first 
					collect: [:char | char = $+ ifTrue: [Character space] ifFalse: [char]]).
		    self postDataAt: key put: datum]
    ]
]



HTTPRequest subclass: HTTPPut [
    | putData |
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPPut 

rfc26216 section 9.6

   The PUT method requests that the enclosed entity be stored under the
   supplied Request-URI. If the Request-URI refers to an already
   existing resource, the enclosed entity SHOULD be considered as a
   modified version of the one residing on the origin server. If the
   Request-URI does not point to an existing resource, and that URI is
   capable of being defined as a new resource by the requesting user
   agent, the origin server can create the resource with that URI. If a
   new resource is created, the origin server MUST inform the user agent
   via the 201 (Created) response. If an existing resource is modified,
   either the 200 (OK) or 204 (No Content) response codes SHOULD be sent
   to indicate successful completion of the request. If the resource
   could not be created or modified with the Request-URI, an appropriate
   error response SHOULD be given that reflects the nature of the
   problem. The recipient of the entity MUST NOT ignore any Content-*
   (e.g. Content-Range) headers that it does not understand or implement
   and MUST return a 501 (Not Implemented) response in such cases.

Instance Variables:
	putData	<>	

'>

    HTTPPut class >> methodName [
	<category: 'accessing'>
	^'PUT'
    ]

    isPut [
	<category: 'testing'>
	^true
    ]

    octetDataFrom: aStream [
	<category: 'reading'>
	self headers fieldOfClass: HTTPContentLengthField
	    ifNone: [^SwazooHTTPPutError raiseSignal: 'Missing Content-Length'].
	self putData: (aStream nextBytes: self contentLength)
    ]

    putData [
	<category: 'accessing'>
	^putData
    ]

    putData: aString [
	<category: 'private'>
	putData := aString
    ]

    readFrom: aStream [
	<category: 'reading'>
	| contentTypeField |
	contentTypeField := self headers fieldOfClass: ContentTypeField
		    ifNone: [SwazooHTTPPutError raiseSignal: 'Missing Content-Type'].
	contentTypeField mediaType = 'application/octet-stream' 
	    ifTrue: [self octetDataFrom: aStream]
	    ifFalse: [self urlencodedDataFrom: aStream].
	^self
    ]
]



HTTPRequest subclass: HTTPTrace [
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPTrace 

rfc26216 section 9.8

   The TRACE method is used to invoke a remote, application-layer loop-
   back of the request message. The final recipient of the request
   SHOULD reflect the message received back to the client as the
   entity-body of a 200 (OK) response
'>

    HTTPTrace class >> methodName [
	<category: 'accessing'>
	^'TRACE'
    ]

    isTrace [
	<category: 'testing'>
	^true
    ]
]



HTTPMessage subclass: HTTPResponse [
    | code entity |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    StatusCodes := nil.

    HTTPResponse class >> badRequest [
	<category: 'response types'>
	^super new code: 400
    ]

    HTTPResponse class >> forbidden [
	<category: 'response types'>
	^(super new)
	    code: 403;
	    entity: '<HTML>
<HEAD><TITLE>Forbidden</TITLE></HEAD>
<BODY>
<H1>403 Forbidden</H1>
<P>Access to the requested resource is forbidden.</P>
</BODY></HTML>'
    ]

    HTTPResponse class >> found [
	<category: 'response types'>
	^super new code: 302
    ]

    HTTPResponse class >> initialize [
	"self initialize"

	<category: 'class initialization'>
	StatusCodes := (Dictionary new)
		    add: 100 -> 'Continue';
		    add: 101 -> 'Switching Protocols';
		    add: 200 -> 'OK';
		    add: 201 -> 'Created';
		    add: 202 -> 'Accepted';
		    add: 203 -> 'Non-Authoritative Information';
		    add: 204 -> 'No Content';
		    add: 205 -> 'Reset Content';
		    add: 206 -> 'Partial Content';
		    add: 300 -> 'Multiple Choices';
		    add: 301 -> 'Moved Permanently';
		    add: 302 -> 'Found';
		    add: 303 -> 'See Other';
		    add: 304 -> 'Not Modified';
		    add: 305 -> 'Use Proxy';
		    add: 307 -> 'Temporary Redirect';
		    add: 400 -> 'Bad Request';
		    add: 401 -> 'Unauthorized';
		    add: 402 -> 'Payment Required';
		    add: 403 -> 'Forbidden';
		    add: 404 -> 'Not Found';
		    add: 405 -> 'Method Not Allowed';
		    add: 406 -> 'Not Acceptable';
		    add: 407 -> 'Proxy Authentication Required';
		    add: 408 -> 'Request Time-out';
		    add: 409 -> 'Conflict';
		    add: 410 -> 'Gone';
		    add: 411 -> 'Length Required';
		    add: 412 -> 'Precondition Failed';
		    add: 413 -> 'Request Entity Too Large';
		    add: 414 -> 'Request-URI Too Large';
		    add: 415 -> 'Unsupported Media Type';
		    add: 416 -> 'Requested range not satisfiable';
		    add: 417 -> 'Expectation Failed';
		    add: 500 -> 'Internal Server Error';
		    add: 501 -> 'Not Implemented';
		    add: 502 -> 'Bad Gateway';
		    add: 503 -> 'Service Unavailable';
		    add: 504 -> 'Gateway Time-out';
		    add: 505 -> 'HTTP Version not supported';
		    yourself.
	self postInitialize
    ]

    HTTPResponse class >> internalServerError [
	<category: 'response types'>
	^(super new)
	    code: 500;
	    entity: '<HTML>
<HEAD><TITLE>Not Found</TITLE></HEAD>
<BODY>
<H1>500 Internal Server Error</H1>
<P>The server experienced an error while processing this request.  If this problem persists, please contact the webmaster.</P>
</BODY></HTML>'
    ]

    HTTPResponse class >> methodNotAllowed [
	"c.f. RFC 2616  10.4.6
	 The method specified in the Request-Line is not allowed for the
	 resource identified by the Request-URI. The response MUST include an
	 Allow header containing a list of valid methods for the requested
	 resource."

	<category: 'response types'>
	^super new code: 405
    ]

    HTTPResponse class >> movedPermanently [
	<category: 'response types'>
	^super new code: 301
    ]

    HTTPResponse class >> notFound [
	<category: 'response types'>
	^(super new)
	    code: 404;
	    entity: '<HTML>
<HEAD><TITLE>Not Found</TITLE></HEAD>
<BODY>
<H1>404 Not Found</H1>
<P>The requested resource was not found on this server.</P>
</BODY></HTML>'
    ]

    HTTPResponse class >> notImplemented [
	<category: 'response types'>
	^super new code: 501
    ]

    HTTPResponse class >> notModified [
	<category: 'response types'>
	^super new code: 304
    ]

    HTTPResponse class >> ok [
	<category: 'response types'>
	^super new code: 200
    ]

    HTTPResponse class >> postInitialize [
	"extend it with your own codes"

	<category: 'class initialization'>
	
    ]

    HTTPResponse class >> redirectLink [
	"^an HTTPResponse
	 Note that 302 is really the 'found' response.  This code should really be 303 (>>seeOther).  However, because many clients take 302 & 303 to be the same and because older clients don't understand 303, 302 is commonly used in this case.  See RFC 2616 10.3.4."

	<category: 'response types'>
	^super new code: 302
    ]

    HTTPResponse class >> seeOther [
	"^an HTTPResponse
	 The response to the request can be found under a different URI and SHOULD be retrieved using a GET method on that resource. This method exists primarily to allow the output of a POST-activated script to redirect the user agent to a selected resource.
	 See RFC 2616 10.3.4."

	<category: 'response types'>
	^super new code: 303
    ]

    HTTPResponse class >> statusTextForCode: aNumber [
	<category: 'accessing'>
	^StatusCodes at: aNumber ifAbsent: [
	    "if some new status codes was added later"
	    self class initialize.
	    StatusCodes at: aNumber ifAbsent: ['']]
    ]

    HTTPResponse class >> unauthorized [
	<category: 'response types'>
	^super new code: 401
    ]

    addDateHeader [
	"^self
	 Note that the server must have it's clock set to GMT"

	<category: 'initialize-release'>
	self headers addField: (HTTPDateField new date: SpTimestamp now).
	^self
    ]

    addDefaultBody [
	<category: 'initialize-release'>
	self 
	    entity: '<HTML>
<HEAD><TITLE>' 
		    , (StatusCodes at: self code ifAbsent: [self code printString]) 
			, '</TITLE></HEAD>
  <BODY>
   <H2>' , self code printString 
		    , ' ' , (StatusCodes at: self code ifAbsent: [self code printString]) 
		    , '</H2>
   <P>The server experienced an error while processing this request. <BR>
   If this problem persists, please contact the webmaster.</P>
  <P>Swazoo Smalltalk Web Server</P>
  </BODY>
</HTML>'
    ]

    addHeaderName: aNameString value: aValueString [
	<category: 'accessing-headers'>
	^self headers addField: (GenericHeaderField newForFieldName: aNameString
		    withValueFrom: aValueString)
    ]

    addInitialHeaders [
	<category: 'initialize-release'>
	self addServerHeader.
	self addDateHeader
    ]

    addServerHeader [
	<category: 'initialize-release'>
	^self headers 
	    addField: (HTTPServerField new productTokens: SwazooServer swazooVersion)
    ]

    cacheControl: aString [
	"example: 'no-store, no-cache, must-revalidate'"

	<category: 'accessing-headers'>
	self headers addField: (HTTPCacheControlField new directives: aString)
    ]

    code [
	<category: 'accessing'>
	^code
    ]

    code: anInteger [
	<category: 'initialize-release'>
	code := anInteger.
	(#(200) includes: code) ifFalse: [self addDefaultBody]
    ]

    codeText [
	<category: 'accessing'>
	^self class statusTextForCode: self code
    ]

    contentLength [
	^self headers
	    fieldNamed: 'Content-length'
	    ifNone: [
		| field |
		field := HTTPContentLengthField new contentLength: self contentSize.
		self headers addField: field.
		field ]
    ]

    contentSize [
	<category: 'accessing'>
	^self entity notNil ifTrue: [self entity size] ifFalse: [0]
    ]

    contentType [
	"^a String
	 Return the media type from my Content-Type header field."

	<category: 'accessing-headers'>
	^self headers 
	    fieldOfClass: ContentTypeField
	    ifPresent: [:field | field mediaType]
	    ifAbsent: ['application/octet-stream']
    ]

    contentType: aString [
	<category: 'accessing-headers'>
	self headers addField: (ContentTypeField new mediaType: aString).
	^self
    ]

    cookie: aString [
	<category: 'accessing-headers'>
	| newField |
	newField := HTTPSetCookieField new.
	newField addCookie: aString.
	self headers addField: newField.
	^self
    ]

    entity [
	<category: 'accessing'>
	^entity
    ]

    entity: anEntity [
	<category: 'accessing'>
	entity := anEntity asByteArray	"if not already"
    ]

    printEntityOn: aStream [
	<category: 'sending'>
	self entity isNil ifFalse: [aStream nextPutBytes: self entity]
    ]

    expires: aSpTimestamp [
	"from SPort"

	<category: 'accessing-headers'>
	self headers addField: (HTTPExpiresField new timestamp: aSpTimestamp).
	^self
    ]

    informConnectionClose [
	<category: 'private'>
	self headers 
	    fieldOfClass: HTTPConnectionField
	    ifPresent: [:field | field setToClose]
	    ifAbsent: [self headers addField: HTTPConnectionField new setToClose].
	^self
    ]

    informConnectionKeepAlive [
	<category: 'private'>
	self headers 
	    fieldOfClass: HTTPConnectionField
	    ifPresent: [:field | field setToKeepAlive]
	    ifAbsent: [self headers addField: HTTPConnectionField new setToKeepAlive].
	^self
    ]

    isBadRequest [
	<category: 'testing'>
	^self code = 400
    ]

    isFound [
	<category: 'testing'>
	^self code = 302
    ]

    isHttp10 [
	"we are responding by old HTTP/1.0 protocol"

	<category: 'testing'>
	^self task request isHttp10
    ]

    isHttp11 [
	"we are responding by HTTP/1.1 protocol"

	<category: 'testing'>
	^self task request isHttp11
    ]

    isInternalServerError [
	<category: 'testing'>
	^self code = 500
    ]

    isMovedPermanently [
	<category: 'testing'>
	^self code = 301
    ]

    isNotFound [
	<category: 'testing'>
	^self code = 404
    ]

    isNotImplemented [
	<category: 'testing'>
	^self code = 501
    ]

    isNotModified [
	<category: 'testing'>
	^self code = 304
    ]

    isOk [
	<category: 'testing'>
	^self code = 200
    ]

    isRedirectLink [
	<category: 'testing'>
	^self code = 302
    ]

    isSeeOther [
	<category: 'testing'>
	^self code = 303
    ]

    isStreamed [
	<category: 'testing'>
	^false
    ]

    isUnauthorized [
	<category: 'testing'>
	^self code = 401
    ]

    lastModified: aSpTimestamp [
	"from SPort"

	<category: 'accessing-headers'>
	self headers addField: (HTTPLastModifiedField new timestamp: aSpTimestamp).
	^self
    ]

    location: aString [
	<category: 'accessing-headers'>
	self headers addField: (HTTPLocationField new uriString: aString).
	^self
    ]
]


HTTPResponse subclass: FileResponse [
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    contentType [
	<category: 'accessing-headers'>
	^self entity contentType
    ]

    entity: aMimeObject [
	<category: 'accessing'>
	entity := aMimeObject.
	self contentType: self entity contentType.
    ]

    contentSize [
	<category: 'private-printing'>
	^self entity notNil ifTrue: [self entity value fileSize] ifFalse: [0]
    ]

    printEntityOn: aStream [
	<category: 'private-printing'>
	| rs |
	self entity isNil 
	    ifFalse: 
		[rs := self entity value readStream.
		rs lineEndTransparent.
		SpExceptionContext 
		    for: 
			[[[rs atEnd] whileFalse: [aStream nextPutAll: (rs nextAvailable: 2000)]] 
			    ensure: [rs close]]
		    on: SpError
		    do: [:ex | ex return]]
    ]
]



HTTPResponse subclass: HTTPStreamedResponse [
    | stream count length state semaphore |
    
    <category: 'Swazoo-Messages'>
    <comment: 'HTTPStreamedResponse 

HTTP/1.1 	no length   	chunked
HTTP/1.1	length		streamed directly, with contentLength
HTTP/1.0	no length   	simulated streaming: into entity first, then sent as normal response (not yet impl.)
HTTP/1.0  	length 		streamed directly, with content length

Instance Variables:
	stream		<SwazooStream> where to stream a response
	count		<Integer> 		how many bytes already streamed
	length		<Integer>		announced length of response, optional
	state		<Symbol>		#header #streaming #closed			
	semaphore	<Semaphore>	to signal end of response

'>

    HTTPStreamedResponse class >> on: aSwazooTask stream: aSwazooStream [
	<category: 'instance creation'>
	^(super ok)
	    task: aSwazooTask;
	    stream: aSwazooStream;
	    initialize
    ]

    close [
	"mandatory!! It signals that streaming is finished and response can end"

	<category: 'initialize-release'>
	self testForUnderflow.	"if streamed but not chunked: all data sent?"
	self stream closeResponse.
	self setClosed.
	self stream: nil.	"to avoid unintential writing"
	self semaphore signal	"to signal close to all waiting processes"
    ]

    contentSize [
	<category: 'accessing'>
	self length notNil ifTrue: [^self length].
	self entity notNil ifTrue: [self entity size].
	^nil
    ]

    count [
	"how many bytes already streamed"

	<category: 'accessing'>
	count isNil ifTrue: [self count: 0].
	^count
    ]

    count: aNumber [
	<category: 'private'>
	count := aNumber
    ]

    flush [
	"force sending to a TCP socket"

	<category: 'accessing-stream'>
	self stream flush
    ]

    initSemaphore [
	<category: 'initialize-release'>
	semaphore := Semaphore new
    ]

    initialize [
	<category: 'initialize-release'>
	self setHeader
    ]

    isClosed [
	"is response closed?. No streaming or anything else possible anymore"

	<category: 'private-state'>
	^state = #closed
    ]

    isHeader [
	"is response in header state?. this is initial one"

	<category: 'private-state'>
	^state = #header
    ]

    isStreamed [
	<category: 'testing'>
	^true
    ]

    isStreaming [
	"is response in streaming state? All nextPut to stream is sent in chunked format to browser"

	<category: 'private-state'>
	^state = #streaming
    ]

    length [
	"how many bytes response is expected to have.
	 This is optional, if set before streaming begin, then we stream without chunking (and
	 therefore we can stream on HTTP 1.0 !!)"

	<category: 'accessing'>
	^length
    ]

    length: aNumber [
	<category: 'accessing'>
	length := aNumber
    ]

    nextPut: aCharacterOrByte [
	<category: 'accessing-stream'>
	self isHeader ifTrue: [self sendHeaderAndStartStreaming].
	self count: self count + 1.
	self testForOverflow.
	^self stream nextPut: aCharacterOrByte
    ]

    nextPutAll: aByteStringOrArray [
	<category: 'accessing-stream'>
	self isHeader ifTrue: [self sendHeaderAndStartStreaming].
	self count: self count + aByteStringOrArray size.
	self testForOverflow.
	^self stream nextPutAll: aByteStringOrArray
    ]

    semaphore [
	"semahore to signal end of streaming = all data sent"

	<category: 'private'>
	semaphore isNil ifTrue: [self initSemaphore].
	^semaphore
    ]

    sendHeaderAndStartStreaming [
	<category: 'private'>
	self shouldSimulateStreaming 
	    ifTrue: [self error: 'simulated streaming not yet implemented!'].
	self writeHeaderTo: self stream.
	self stream flush.	"to push sending of header immediately"
	self shouldBeChunked ifTrue: [self stream setChunked].
	self setStreaming
    ]

    setClosed [
	"response is closed. No streaming or anything else possible anymore"

	<category: 'private-state'>
	state := #closed
    ]

    setHeader [
	"response in header state. this is initial one"

	<category: 'private-state'>
	state := #header
    ]

    setStreaming [
	"response in streaming state. All nextPut to stream is sent in chunked format to browser"

	<category: 'private-state'>
	state := #streaming
    ]

    shouldBeChunked [
	<category: 'testing'>
	^self isHttp11 and: [self length isNil]
    ]

    shouldSimulateStreaming [
	"stream to entity first then send all at once (because only now we
	 know the length of response)"

	<category: 'testing'>
	^self isHttp10 and: [self length isNil]
    ]

    stream [
	<category: 'private'>
	^stream
    ]

    stream: aSwazooStream [
	<category: 'private'>
	stream := aSwazooStream
    ]

    testForOverflow [
	"if streaming but not chunking, then count must never be larger than announced length"

	<category: 'private'>
	(self length notNil and: [self count > self length]) 
	    ifTrue: [self error: 'streaming overflow']
    ]

    testForUnderflow [
	"if streaming but not chunking, then count must be exactly the announced
	 length at the end"

	<category: 'private'>
	(self length notNil and: [self count ~= self length]) 
	    ifTrue: [self error: 'not enough data streamed ']
    ]

    waitClose [
	"wait until all data is sent-streamed out and response is closed"

	<category: 'waiting'>
	^self semaphore wait
    ]
]



Object subclass: HTTPPostDataArray [
    | underlyingCollection stream parsed |
    
    <category: 'Swazoo-Messages'>
    <comment: 'Introduced the HTTPPostDataArray to hold post data in an HTTPRequest in place of a Dictionary.  This is because it is legal for there to be more than one entry with the same name (key) and using a Dictionary  looses data (!).

Instance Variables:
	underlyingCollection	<>	

'>

    HTTPPostDataArray class >> newOn: aSwazooStream [
	<category: 'instance creation'>
	^(super new)
	    initialize;
	    stream: aSwazooStream
    ]

    allAt: aKey [
	<category: 'accessing'>
	| candidates |
	candidates := self underlyingCollection 
		    select: [:anAssociation | anAssociation key = aKey].
	^candidates collect: [:anAssociation | anAssociation value]
    ]

    allNamesForValue: aString [
	<category: 'accessing'>
	| candidates |
	candidates := self underlyingCollection 
		    select: [:anAssociation | anAssociation value value = aString].
	^candidates collect: [:anAssociation | anAssociation key]
    ]

    associations [
	<category: 'accessing'>
	^self underlyingCollection
    ]

    at: aKey [
	<category: 'accessing'>
	^(self allAt: aKey) last
    ]

    at: aKey ifAbsent: aBlock [
	<category: 'accessing'>
	| candidates |
	candidates := self underlyingCollection 
		    select: [:anAssociation | anAssociation key = aKey].
	^candidates isEmpty ifTrue: [aBlock value] ifFalse: [candidates last value]
    ]

    at: key put: anObject [
	<category: 'accessing'>
	self underlyingCollection add: (Association key: key value: anObject).
	^anObject
    ]

    clearParsed [
	<category: 'accessing'>
	parsed := false
    ]

    includesKey: aKey [
	<category: 'accessing'>
	| candidates |
	candidates := self underlyingCollection 
		    select: [:anAssociation | anAssociation key = aKey].
	^candidates notEmpty
    ]

    includesValue: aString [
	<category: 'accessing'>
	| candidates |
	candidates := self underlyingCollection 
		    select: [:anAssociation | anAssociation value value = aString].
	^candidates notEmpty
    ]

    initialize [
	<category: 'initialize-release'>
	self clearParsed
    ]

    isEmpty [
	<category: 'testing'>
	^self underlyingCollection isEmpty
    ]

    isParsed [
	"postdata is already read and parsed from a request"

	<category: 'testing'>
	^parsed
    ]

    keys [
	"^a Set
	 I mimick the behavior of a Dictionay which I replace.  I return a set of the keys in my underlying collection of associations."

	<category: 'accessing'>
	^(self underlyingCollection collect: [:anAssociation | anAssociation key]) 
	    asSet
    ]

    keysAndValuesDo: aTwoArgumentBlock [
	<category: 'enumerating'>
	self underlyingCollection 
	    do: [:anAssociation | aTwoArgumentBlock value: anAssociation key value: anAssociation value]
    ]

    nameForValue: aString [
	<category: 'accessing'>
	^(self allNamesForValue: aString) last
    ]

    printOn: aStream [
	<category: 'private'>
	aStream nextPutAll: 'a Swazoo.HttpPostDataArray 
	'.
	self underlyingCollection do: 
		[:each | 
		aStream 
		    nextPutAll: each key printString , '->' , each value value printString 
			    , '
	']
    ]

    select: aBlock [
	"^an Object
	 I run the select on the values of the associations in my underlying collection.  This mimicks the behavior when a Dictionary was used in my place."

	<category: 'enumerating'>
	^self underlyingCollection 
	    select: [:anAssociation | aBlock value: anAssociation value]
    ]

    setParsed [
	<category: 'accessing'>
	parsed := true
    ]

    stream [
	<category: 'private'>
	^stream
    ]

    stream: aSwazooStream [
	"needed for defered postData parsing"

	<category: 'private'>
	stream := aSwazooStream
    ]

    underlyingCollection [
	<category: 'private'>
	underlyingCollection isNil 
	    ifTrue: [underlyingCollection := OrderedCollection new].
	^underlyingCollection
    ]
]



Object subclass: HTTPRequestLine [
    | method requestURI httpVersion |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    httpVersion [
	<category: 'accessing'>
	^httpVersion
    ]

    httpVersion: anArray [
	<category: 'private'>
	httpVersion := anArray.
	^self
    ]

    isHttp10 [
	<category: 'testing'>
	^self httpVersion last = 0
    ]

    isHttp11 [
	<category: 'testing'>
	^self httpVersion last = 1
    ]

    method [
	<category: 'accessing'>
	^method
    ]

    method: aString [
	<category: 'private'>
	method := aString.
	^self
    ]

    requestURI [
	<category: 'accessing'>
	^requestURI
    ]

    requestURI: aString [
	<category: 'private'>
	requestURI := aString.
	^self
    ]
]



Object subclass: MimeObject [
    | contentType value |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    contentType [
	<category: 'accessing'>
	^contentType isNil ifTrue: [self defaultContentType] ifFalse: [contentType]
    ]

    contentType: anObject [
	<category: 'accessing'>
	contentType := anObject
    ]

    defaultContentType [
	<category: 'private-accessing'>
	^'application/octet-stream'
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    value: anObject [
	<category: 'accessing'>
	value := anObject
    ]
]



MimeObject subclass: HTTPPostDatum [
    | filename writeStream writeBlock |
    
    <category: 'Swazoo-Messages'>
    <comment: nil>

    defaultContentType [
	<category: 'private-accessing'>
	^'text/plain'
    ]

    filename [
	<category: 'accessing'>
	^filename
    ]

    filename: aString [
	<category: 'accessing'>
	filename := aString
    ]

    filenameWithoutPath [
	"M$ Internet Explorer includes full path in filename of uploaded file!!"

	<category: 'accessing'>
	self filename isNil ifTrue: [^nil].
	^(self filename includes: $\) 
	    ifTrue: 
		[self filename copyFrom: (self filename lastIndexOf: $\) + 1
		    to: self filename size]
	    ifFalse: [self filename]
    ]

    isStreamed [
	"this postDatum is streamed - it has an output stream to receive data into or a block
	 which will set it"

	<category: 'testing'>
	^self writeStream notNil or: [self writeBlock notNil]
    ]

    writeBlock [
	<category: 'accessing'>
	^writeBlock
    ]

    writeBlock: aBlockClosure [
	"this block will be called just before start of streaming to writeStream. It can be used to
	 open the writeStream, because on that time we already know the filename of uploaded file.
	 As a parameter this postDatum is sent"

	<category: 'accessing'>
	writeBlock := aBlockClosure
    ]

    writeStream [
	<category: 'accessing'>
	^writeStream
    ]

    writeStream: aWriteStream [
	"a binary stream where to put directly a post data"

	<category: 'accessing'>
	writeStream := aWriteStream
    ]
]



Object subclass: SwazooTask [
    | connection request response |
    
    <category: 'Swazoo-Messages'>
    <comment: 'A SwazooTask is simply a request-response pair.  This class just makes the task (ha!) of dealing with requests and responses a bit easier.'>

    SwazooTask class >> newOn: aHTTPConnection [
	<category: 'instance creation'>
	^super new connection: aHTTPConnection
    ]

    connection [
	<category: 'accessing'>
	^connection
    ]

    connection: aHTTPConnection [
	<category: 'accessing'>
	connection := aHTTPConnection
    ]

    request [
	<category: 'accessing'>
	^request
    ]

    request: aHTTPRequest [
	<category: 'accessing'>
	request := aHTTPRequest.
	aHTTPRequest task: self
    ]

    response [
	<category: 'accessing'>
	^response
    ]

    response: aHTTPResponse [
	<category: 'accessing'>
	response := aHTTPResponse.
	aHTTPResponse notNil ifTrue: [aHTTPResponse task: self]
    ]
]



Eval [
    HTTPResponse initialize
]
PK
     �Mh@��t�^!  ^!    Exceptions.stUT	 eqXOՊXOux �  �  "======================================================================
|
|   Swazoo 2.1 exceptions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Error subclass: HTTPException [
    | response |
    
    <category: 'Swazoo-Exceptions'>
    <comment: 'HTTPException immediatelly returns attached HTTP response to client. That way it is easier to respond with different status codes (like 201 Created). Not only error ones! You can respond somewhere deeply in code of your resource with raising that exception and adding a prepared HTTPResponse. 
This exception is non-resumable!

Example of ways to raise http response (200 Ok):

	HTTPException raiseResponse: (HTTPResponse new code: 200).
	HTTPException raiseResponseCode: 200.
	HTTPException ok.

Instance Variables:
	response	<HTTPResponse>	a response to be sent to client

'>

    HTTPException class >> accepted [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 202)
    ]

    HTTPException class >> badGateway [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 502)
    ]

    HTTPException class >> badRequest [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 400)
    ]

    HTTPException class >> conflict [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 409)
    ]

    HTTPException class >> continue [
	<category: 'responses-informational'>
	^self raiseResponse: (HTTPResponse new code: 100)
    ]

    HTTPException class >> created [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 201)
    ]

    HTTPException class >> expectationFailed [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 416)
    ]

    HTTPException class >> forbidden [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 403)
    ]

    HTTPException class >> found [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 302)
    ]

    HTTPException class >> gatewayTimeout [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 504)
    ]

    HTTPException class >> gone [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 410)
    ]

    HTTPException class >> httpVersionNotSupported [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 505)
    ]

    HTTPException class >> internalServerError [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 500)
    ]

    HTTPException class >> lengthRequired [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 411)
    ]

    HTTPException class >> methodNotAllowed [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 405)
    ]

    HTTPException class >> movedPermanently [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 301)
    ]

    HTTPException class >> multipleChoices [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 300)
    ]

    HTTPException class >> noContent [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 204)
    ]

    HTTPException class >> nonAuthorativeInformation [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 203)
    ]

    HTTPException class >> notAcceptable [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 406)
    ]

    HTTPException class >> notFound [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 404)
    ]

    HTTPException class >> notImplemented [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 501)
    ]

    HTTPException class >> notModified [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 304)
    ]

    HTTPException class >> ok [
	<category: 'responses-succesfull'>
	^self raiseResponse: HTTPResponse ok
    ]

    HTTPException class >> partialContent [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 206)
    ]

    HTTPException class >> paymentRequired [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 402)
    ]

    HTTPException class >> preconditionFailed [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 412)
    ]

    HTTPException class >> proxyAuthenticationRequired [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 407)
    ]

    HTTPException class >> raiseResponseCode: aNumber [
	"Raise an exception to immediatelly return http response with that code"

	<category: 'signalling'>
	^self raiseResponse: (HTTPResponse new code: aNumber)
    ]

    HTTPException class >> requestEntityTooLarge [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 413)
    ]

    HTTPException class >> requestTimeout [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 408)
    ]

    HTTPException class >> requestURITooLong [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 414)
    ]

    HTTPException class >> requestedRangeNotSatisfiable [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 416)
    ]

    HTTPException class >> resetContent [
	<category: 'responses-succesfull'>
	^self raiseResponse: (HTTPResponse new code: 205)
    ]

    HTTPException class >> seeOther [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 303)
    ]

    HTTPException class >> serviceUnavailable [
	<category: 'responses-server error'>
	^self raiseResponse: (HTTPResponse new code: 503)
    ]

    HTTPException class >> switchingProtocols [
	<category: 'responses-informational'>
	^self raiseResponse: (HTTPResponse new code: 101)
    ]

    HTTPException class >> temporaryRedirect [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 307)
    ]

    HTTPException class >> unathorized [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 401)
    ]

    HTTPException class >> unsupportedMediaType [
	<category: 'responses-client error'>
	^self raiseResponse: (HTTPResponse new code: 415)
    ]

    HTTPException class >> useProxy [
	<category: 'responses-redirection'>
	^self raiseResponse: (HTTPResponse new code: 305)
    ]

    response [
	<category: 'accessing'>
	^response
    ]

    response: aHTTPResponse [
	<category: 'accessing'>
	response := aHTTPResponse
    ]
]



SpError subclass: SwazooHTTPParseError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SpError subclass: SwazooHTTPRequestError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SwazooHTTPRequestError subclass: SwazooHTTPPostError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SwazooHTTPRequestError subclass: SwazooHTTPPutError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SpError subclass: SwazooHeaderFieldParseError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SpError subclass: SwazooSiteError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



SpError subclass: SwazooStreamNoDataError [
    
    <comment: nil>
    <category: 'Swazoo-Exceptions'>
]



PK
     �Mh@:P�a6!  6!    Protocol.stUT	 eqXOՊXOux �  �  "======================================================================
|
|   Swazoo 2.1 HTTP request/response reading
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: SwazooRequestReader [
    | request stream requestLine |

    <category: 'Swazoo-Messages'>

    SwazooRequestReader class >> readFrom: aSwazooStream [
	<category: 'parsing'>
	| reader |
	reader := self new.
	reader initializeStream: aSwazooStream.
	reader readRequest.
	^reader request
    ]

    initializeStream: aSwazooStream [
	<category: 'initialize'>
	stream := aSwazooStream.
	requestLine := HTTPRequestLine new.
    ]

    readBody [
	<category: 'parsing'>
	self request readFrom: stream
    ]

    readHeaders [
	<category: 'abstract-parsing'>
        self subclassResponsibility
    ]

    readRequest [
	<category: 'parsing'>
	self readRequestLine.
	request := (HTTPRequest classFor: self method) new.
        request requestLine: requestLine.
	self readHeaders.
	self request setTimestamp.
	self readBody
    ]

    readRequestLine [
	<category: 'abstract-parsing'>
        self subclassResponsibility
    ]

    request [
	<category: 'accessing'>
        ^request
    ]

    stream [
	<category: 'accessing'>
        ^stream
    ]

    requestURI [
	<category: 'accessing-request line'>
        ^requestLine requestURI
    ]

    requestURI: aString [
	<category: 'accessing-request line'>
        requestLine requestURI: aString
    ]

    httpVersion [
	<category: 'accessing-request line'>
        ^requestLine httpVersion
    ]

    httpVersion: aString [
	<category: 'accessing-request line'>
        requestLine httpVersion: aString
    ]

    method [
	<category: 'accessing-request line'>
        ^requestLine method
    ]

    method: aString [
	<category: 'accessing-request line'>
        requestLine method: aString
    ]
]



SwazooRequestReader subclass: HTTPReader [

    <category: 'Swazoo-Messages'>

    readHeaderFieldFrom: aString [
	<category: 'parsing'>
        | sourceStream fieldName fieldValue |
        sourceStream := ReadStream on: aString.
        fieldName := sourceStream upTo: $:.
        fieldValue := sourceStream upToEnd.
        ^HeaderField name: fieldName value: fieldValue
    ]

    readHeaders [
	<category: 'parsing'>
        | nextLine field header |

        [nextLine := stream nextUnfoldedLine.
        nextLine isEmpty] whileFalse: [
	    request headers addField: (self readHeaderFieldFrom: nextLine)].
        ^self
    ]

    readRequestLine [
	<category: 'parsing'>
        self skipLeadingBlankLines.
        self method: (stream upTo: Character space asInteger) asString.
        self parseURI.
        self parseHTTPVersion.
    ]

    parseHTTPVersion [
        <category: 'parsing'>
        | major minor |
        self skipSpaces.
        stream upTo: $/ asInteger.
        major := (stream upTo: $. asInteger) asString asNumber.
        minor := (stream upTo: Character cr asInteger) asString asNumber.
        self httpVersion: (Array with: major with: minor).
        stream next.
    ]

    parseURI [
        <category: 'parsing'>
        self skipSpaces.
        self requestURI:
	    (SwazooURI
                fromString: (stream upTo: Character space asInteger) asString).
        ^self
    ]

    skipLeadingBlankLines [
        "^self
         RFC 2616:
         In the interest of robustness, servers SHOULD ignore any empty
         line(s) received where a Request-Line is expected. In other words, if
         the server is reading the protocol stream at the beginning of a
         message and receives a CRLF first, it should ignore the CRLF."

        <category: 'parsing'>
        [stream peek == Character cr asInteger] whileTrue:
                [((stream next: 2) at: 2) == Character lf asInteger
                    ifFalse: [SwazooHTTPParseError raiseSignal: 'CR without LF']].
        ^self
    ]

    skipSpaces [
        <category: 'parsing'>
        [stream peek = Character space] whileTrue: [stream next].
        ^self
    ]
]



Object subclass: SwazooResponsePrinter [
    | stream response |

    <category: 'Swazoo-Messages'>

    SwazooResponsePrinter class >> writeHeadersFor: aResponse to: aSwazooStream [
	<category: 'private-sending'>
	aSwazooStream isNil ifTrue: [ ^self ].
	^self new
	    response: aResponse;
	    stream: aSwazooStream;
	    writeHeader;
	    closeResponse
    ]

    SwazooResponsePrinter class >> writeResponse: aResponse to: aSwazooStream [
	<category: 'private-sending'>
	aSwazooStream isNil ifTrue: [ ^self ].
	^self new
	    response: aResponse;
	    stream: aSwazooStream;
	    writeResponseTo: nil;
	    closeResponse
    ]

    SwazooResponsePrinter class >> writeResponse: aResponse for: aRequest to: aSwazooStream [
	<category: 'private-sending'>
	aSwazooStream isNil ifTrue: [ ^self ].
	^self new
	    response: aResponse;
	    stream: aSwazooStream;
	    writeResponseTo: aRequest;
	    closeResponse
    ]

    response [
	<category: 'accessing'>
	^response
    ]

    response: aResponse [
	<category: 'accessing'>
	response := aResponse
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: aSwazooStream [
	<category: 'accessing'>
	stream := aSwazooStream
    ]

    closeResponse [
	<category: 'private-sending'>
	stream closeResponse
    ]

    endHeader [
	<category: 'abstract-sending'>
	self subclassResponsibility
    ]

    printChunkedTransferEncoding [
	<category: 'abstract-sending'>
	self subclassResponsibility
    ]

    printContentLength [
	"it is also added to headers. It is added so late because to be printed last,
	 just before body starts"

	<category: 'sending'>
	self printHeader: response contentLength
    ]

    printHeader: aField [
	<category: 'abstract-sending'>
	self subclassResponsibility
    ]

    printHeaders [
	"^self
	 Write the headers (key-value pairs) to aStream.  The key
	 must be a String."

	<category: 'sending'>
	response headers fields do: 
		[:aField | self printHeader: aField]
    ]

    printStatus [
	<category: 'abstract-sending'>
	self subclassResponsibility
    ]

    writeHeader [
	<category: 'sending'>
	self printStatus.
	self printHeaders.
	(response isStreamed and: [response shouldBeChunked]) 
	    ifTrue: [self printChunkedTransferEncoding]
	    ifFalse: [self printContentLength].
	self endHeader
    ]

    writeResponseTo: aRequest [
	<category: 'sending'>
	stream isNil ifTrue: [^self].
	self writeHeader.
	(aRequest isNil or: [aRequest isHead not]) 
	    ifTrue: [response printEntityOn: self stream].
	stream closeResponse
    ]
]


SwazooResponsePrinter subclass: HTTPPrinter [

    <category: 'Swazoo-Messages'>

    crlf [
	<category: 'private-sending'>
	stream
	    nextPut: Character cr;
	    nextPut: Character lf
    ]

    endHeader [
	<category: 'private-sending'>
	self crlf
    ]

    printChunkedTransferEncoding [
	<category: 'private-sending'>
	stream nextPutAll: 'Transfer-Encoding: chunked'.
	self crlf
    ]

    printHeader: aField [
	<category: 'private-sending'>
        stream
            nextPutAll: aField name;
            nextPutAll: ': '.
        aField valuesAsStringOn: stream.
	self crlf
    ]

    printStatus [
	<category: 'private-sending'>
	| version |
	version := (response task isNil 
		    or: [response task request isNil or: [response task request isHttp11]]) 
			ifTrue: ['HTTP/1.1 ']
			ifFalse: ['HTTP/1.0 '].
	stream
	    nextPutAll: version;
	    print: response code;
	    space;
	    nextPutAll: response codeText.
	self crlf
    ]
]
PK
     �Mh@��3C�  �    Extensions.stUT	 eqXOՊXOux �  �  "======================================================================
|
|   Swazoo 2.1 extensions for GNU Smalltalk
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Stream extend [
    lineEndTransparent [
	"Do nothing.  GNU Smalltalk streams do not muck with line endings."
	<category: 'useless portability hacks'>
    ]
]



SpFilename extend [

    etag [
	"^a String
	 The etag of a file entity is taken to be the date last modified as a String.
	 We use the SpTimestamp in"

	<category: '*Swazoo-accessing'>
	^self lastModified asRFC1123String
    ]

    lastModified [
	"| info |
	 info := self dates at: #modified.
	 ^SpTimestamp fromDate: info first andTime: info last"

	<category: '*Swazoo-accessing'>
	^self modifiedTimestamp
    ]

]



SpFileStream extend [
    lineEndTransparent [
       "Do nothing.  GNU Smalltalk streams do not muck with line endings."
       <category: 'useless portability hacks'>
    ]

    nextAvailable: anInteger [
        ^self underlyingStream nextAvailable: anInteger
    ]
]


PK
     �Mh@;�3%�  �    SCGI.stUT	 eqXOՊXOux �  �  "======================================================================
|
|   Swazoo SCGI add-on
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Nicolas Petton
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


AbstractHTTPServer subclass: SCGIServer [
    | port |

    <comment: nil>
    <category: 'Swazoo-SCGI'>

    createSocket [
	<category: 'start/stop'>
	^(self socketClass serverOnIP: self ip port: self port)
	    listenFor: 50;
	    yourself
    ]

    ip [
	<category: 'private-initialize'>
	^'0.0.0.0'
    ]

    port [
	<category: 'private-initialize'>
	^port
    ]

    port: anInteger [
	<category: 'private-initialize'>
	port := anInteger
    ]

    requestReaderClass [
	<category: 'serving'>
	^SCGIReader
    ]

    responsePrinterClass [
	<category: 'serving'>
	^SCGIPrinter
    ]

    socketClass [
	<category: 'serving'>
	^SwazooSocket
    ]
]

URIIdentifier subclass: SCGIIdentifier [
    | port |

    <comment: nil>
    <category: 'Swazoo-SCGI'>

    SCGIIdentifier class >> port: aPort [
	<category: 'instance creation'>
	^self new setPort: aPort
    ]

    SCGIIdentifier class >> host: aString ip: anotherString port: aPort [
	<category: 'instance creation'>
	^self port: aPort
    ]

    currentUrl [
	<category: 'accessing'>
	| stream |
	stream := WriteStream on: String new.
	self printUrlOn: stream.
	^stream contents
    ]

    port [
	<category: 'accessing'>
	^port
    ]

    port: aNumber [
	<category: 'private'>
	port := aNumber
    ]

    ip [
	^'0.0.0.0'
    ]

    isEmpty [
	<category: 'testing'>
	^port isNil
    ]

    newServer [
	<category: 'initialize-release'>
	^SCGIServer new port: self port
    ]

    setPort: aPort [
	<category: 'initialize-release'>
	self port: aPort
    ]

    printString [
	<category: 'private'>
	^'a Swazoo.SCGIIndentifier'
    ]

    printUrlOn: aWriteStream [
	<category: 'private'>
	aWriteStream nextPutAll: '*:' , self port printString
    ]

    portMatch: aSCGIIdentifier [
	<category: 'private-comparing'>
	^self port = aSCGIIdentifier port
    ]

    valueMatch: aRequestOrIdentifier [
	<category: 'private-comparing'>
	^self portMatch: aRequestOrIdentifier
    ]
]

HTTPPrinter subclass: SCGIPrinter [

    <comment: nil>
    <category: 'Swazoo-SCGI'>

    printStatus [
	<category: 'private-sending'>
	stream
	    nextPutAll: 'Status: ';
	    print: response code;
	    space;
	    nextPutAll: response codeText.
	self crlf
    ]
]

SwazooRequestReader subclass: SCGIReader [
    | fields |

    <comment: nil>
    <category: 'Swazoo-SCGI'>

    readNetString [
	<category: '*Swazoo-SCGI'>
	"This method implements the NetString protocol as
	defined by: http://cr.yp.to/proto/netstrings.txt"

	| size c answer |
	size := 0.
	[(c := stream next) >= $0 and: [c <= $9]] whileTrue: [
	    size := (size * 10) + (c value - 48)].

	c = $: ifFalse: [ ^self error: 'invalid net string'].
	answer := stream next: size.
	stream next = $, ifFalse: [ ^self error: 'invalid net string'].
	^answer
    ]

    readHeaders [
	<category: 'parsing'>
	| uriHeader methodHeader |
	self readHeadersFrom: self readNetString.
	uriHeader := fields
	    detect: [:each | each name asUppercase = 'REQUEST-URI']
	    ifNone: [nil].
	self requestURI: (SwazooURI fromString: (uriHeader
	    ifNil: ['']
	    ifNotNil: [uriHeader value])).
	methodHeader := fields
	    detect: [:each | each name asUppercase = 'REQUEST-METHOD']
	    ifNone: [nil].
	self method: (methodHeader
	    ifNil: ['GET']
	    ifNotNil: [methodHeader value]).
    ]

    readHeadersFrom: aString [
	"This is the request parsing code based on Simple CGI standard:
	 http://python.ca/scgi/protocol.txt"
	<category: 'parsing'>

	| zero start end key valueEnd value |
	zero := Character value: 0.
	start := 1.
	fields := OrderedCollection new.

	[end := aString indexOf: zero startingAt: start.
	key := aString copyFrom: start to: end - 1.
	valueEnd := aString indexOf: zero startingAt: end + 1.
	value := aString copyFrom: end + 1 to: valueEnd - 1.
	fields add: (HeaderField
	    name: (self convertFieldName: key)
	    value: value).
	valueEnd = aString size]
	    whileFalse: [start := valueEnd + 1]
    ]

    readRequest [
	<category: 'parsing'>
	self readHeaders.
	request := (HTTPRequest classFor: self method) new.
	self httpVersion: #(0 0).
	fields do: [:each |
	    request headers
		fieldOfClass: each class
		ifNone: [request headers addField: each]].
	request requestLine: requestLine.
	self request setTimestamp.
	self readBody.
    ]

    convertFieldName: aString [
	<category: 'private'>
	^(aString
	    copyReplacingAllRegex: '^HTTP_' with: '')
	    copyReplacingAllRegex: '_' with: '-'
    ]
]

SwazooSite extend [
    scgiPort: aNumber [
	<category: '*Swazoo-SCGI'>
	| identifier |
        identifier := self uriPattern
            detect: [ :each | each isKindOf: SCGIIdentifier ]
            ifNone: [ self uriPattern add: SCGIIdentifier new ].
        identifier port: aNumber
    ]
]
PK
     �Mh@s��/ �/   Tests.stUT	 eqXOՊXOux �  �  "======================================================================
|
|   Swazoo 2.1 testcases
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2000-2009 the Swazoo team.
|
| This file is part of Swazoo.
|
| Swazoo is free software; you can redistribute it and/or modify it
| under the terms of the GNU Lesser General Public License as published
| by the Free Software Foundation; either version 2.1, or (at your option)
| any later version.
| 
| Swazoo is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
| FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
| License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: SwazooBenchmarks [
    | server content |
    
    <category: 'Swazoo-Tests'>
    <comment: 'SwazooBenchmarks stores several benchmarks and performance routines

'>

    Singleton := nil.

    SwazooBenchmarks class >> singleton [
	<category: 'accessing'>
	Singleton isNil ifTrue: [Singleton := self new].
	^Singleton
    ]

    content [
	"test content to be writen to the socket"

	<category: 'accessing'>
	content isNil ifTrue: [self initContent].
	^content
    ]

    content: aByteArray [
	<category: 'accessing'>
	content := aByteArray
    ]

    contentSize [
	<category: 'initialize-release'>
	^4
    ]

    initContent [
	<category: 'initialize-release'>
	| response ws |
	response := HTTPResponse ok.
	response entity: (ByteArray new: self contentSize withAll: 85).
	ws := SwazooStream on: String new.
	HTTPPrinter writeResponse: response to: ws.
	content := ws writeBufferContents
    ]

    server [
	"TCP server loop"

	<category: 'accessing'>
	^server
    ]

    server: aProcess [
	"TCP server loop"

	<category: 'accessing'>
	server := aProcess
    ]

    serverLoop [
	<category: 'socket performance'>
	| socket clientSocket |
	socket := SpSocket newTCPSocket.
	socket
	    setAddressReuse: true;
	    bindSocketAddress: (SpIPAddress hostName: 'localhost' port: 9999).
	
	[socket listenBackloggingUpTo: 50.
	[true] whileTrue: 
		[clientSocket := socket accept.
		
		[[true] whileTrue: 
			[clientSocket underlyingSocket waitForData.
			clientSocket read: 60.	"HTTP request"
			clientSocket write: self content]] 
			on: Error
			do: [:ex | ]]] 
		ensure: 
		    [clientSocket notNil ifTrue: [clientSocket close].
		    socket close]
    ]

    startSocketServer [
	"SwazooBenchmarks singleton startSocketServer"

	"SwazooBenchmarks singleton stopSocketServer"

	"testing raw socket performance.
	 it will start a server on localhost:9999 to receive a request
	 and respond with 10K response as drirectly as possible."

	<category: 'socket performance'>
	self stopSocketServer.
	self server: [self serverLoop] fork
    ]

    stopSocketServer [
	"SwazooBenchmarks singleton stopSocketServer"

	<category: 'socket performance'>
	self server notNil 
	    ifTrue: 
		[self server terminate.
		self server: nil].
	self content: nil.
	(Delay forMilliseconds: 1000) wait
    ]
]



Object subclass: TestPseudoSocket [
    | byteStreamToServer byteStreamFromServer clientWaitSemaphore serverWaitSemaphore ipAddress |
    
    <category: 'Swazoo-Tests'>
    <comment: 'TestPseudoSocket is a drop in replacement for a SwazooSocket that can be used during testing to feed bytes into a running SwazooHTTPServer and grab the responses without having to start a real socket pair.

So, to the HTTP server it must look like a server socket.  To the tester it must look like a write stream (to send bytes to the HTTP server) and a read stream (to read the HTTP responses).'>

    TestPseudoSocket class >> newTCPSocket [
	"^a TestPseudoSocket
	 I simply return a new instance of myself."

	<category: 'instance creation'>
	^self new
    ]

    TestPseudoSocket class >> serverOnIP: host port: port [
	"^self
	 I'm only pretending to be a socket class, so I ignore the host and port."

	<category: 'instance creation'>
	^self new
    ]

    acceptRetryingIfTransientErrors [
	"^another TestSocketThing
	 The sender expects me to block until a request comes in 'over the socket'.  What I really do is wait for someone to ask me to 'send in' a Byte array and then I return myself.  Note that I will only handle one request at a time!!"

	<category: 'socket stuff'>
	self serverWaitSemaphore wait.
	^self
    ]

    bindSocketAddress: anOSkIPAddress [
	"^self
	 This is a no-op for me."

	<category: 'socket stuff'>
	ipAddress := anOSkIPAddress.
	^self
    ]

    byteStreamFromServer [
	<category: 'accessing'>
	^byteStreamFromServer
    ]

    byteStreamFromServer: aByteStream [
	<category: 'accessing'>
	byteStreamFromServer := aByteStream.
	^self
    ]

    byteStreamToServer [
	<category: 'accessing'>
	^byteStreamToServer
    ]

    byteStreamToServer: aByteStream [
	<category: 'accessing'>
	byteStreamToServer := aByteStream.
	^self
    ]

    clientWaitSemaphore [
	"^a Semaphore
	 I return the semaphore I use to control 'client' activity."

	<category: 'accessing'>
	clientWaitSemaphore isNil ifTrue: [clientWaitSemaphore := Semaphore new].
	^clientWaitSemaphore
    ]

    close [
	"^self
	 The server has finished with us at this point, so we signal the semaphore to give the client end chance to grab the response."

	<category: 'socket stuff'>
	self clientWaitSemaphore signal.
	^self
    ]

    flush [
	<category: 'socket stuff'>
	^self
    ]

    getPeerName [
	<category: 'socket stuff'>
	^ipAddress
    ]

    getSocketName [
	<category: 'socket stuff'>
	^ipAddress
    ]

    isActive [
	"^self
	 I am pretending to be a socket, and the sender wants to know if I am active.  Of course I am!!."

	<category: 'socket stuff'>
	^true
    ]

    listenBackloggingUpTo: anInteger [
	"^self
	 This is a no-op for me."

	<category: 'socket stuff'>
	^self
    ]

    listenFor: anInteger [
	"^self
	 This is a no-op for now."

	<category: 'socket stuff'>
	^self
    ]

    next [
	<category: 'stream-toServer'>
	^self byteStreamToServer next
    ]

    nextPut: aCharacter [
	<category: 'stream-fromServer'>
	self byteStreamFromServer nextPut: aCharacter asInteger
    ]

    nextPutAll: aCollection [
	"^self
	 At present it seems that aCollection will always be a string of chacters."

	<category: 'stream-fromServer'>
	^self byteStreamFromServer nextPutAll: aCollection asByteArray
    ]

    nextPutBytes: aByteArray [
	<category: 'stream-fromServer'>
	self byteStreamFromServer nextPutAll: aByteArray
    ]

    peek [
	"^a Character
	 It seems that the HTTP server is expecting Characters not Bytes - this will have to change."

	<category: 'stream-toServer'>
	^byteStreamToServer isNil 
	    ifTrue: [nil]
	    ifFalse: [Character value: self byteStreamToServer peek]
    ]

    print: anObject [
	<category: 'stream-fromServer'>
	self nextPutAll: anObject printString asByteArray.
	^self
    ]

    read: integerNumberOfBytes [
	"^a ByteArray
	 I read the next numberOfBytes from my underlying stream."

	<category: 'stream-toServer'>
	^byteStreamToServer isNil 
	    ifTrue: [ByteArray new]
	    ifFalse: [self byteStreamToServer nextAvailable: integerNumberOfBytes]
    ]

    serverWaitSemaphore [
	"^a Semaphore
	 I return the semaphore I use to control 'server' activity."

	<category: 'accessing'>
	serverWaitSemaphore isNil ifTrue: [serverWaitSemaphore := Semaphore new].
	^serverWaitSemaphore
    ]

    setAddressReuse: aBoolean [
	"^self
	 This is a no-op for me."

	<category: 'socket stuff'>
	^self
    ]

    socket [
	"^self
	 I am being asked this as if I am a socket stream.  I return myself because I'm pretending to be both the socket and the socket stream."

	<category: 'stream-toServer'>
	^self
    ]

    space [
	<category: 'stream-fromServer'>
	self nextPut: Character space.
	^self
    ]

    stream [
	"^self
	 I have to pretend to be a socket stream too."

	<category: 'socket stuff'>
	^self
    ]

    upTo: aCharacter [
	"a ByteString
	 For some reason, we have to look for a character in a ByteStream - this is a Swazoo thing."

	<category: 'stream-toServer'>
	^self byteStreamToServer upTo: aCharacter asInteger
    ]

    write: aByteArray [
	"^an Integer
	 I write the contents of the sourceByteArray to my underlying Socket.
	 I return the number of bytes written."

	<category: 'stream-fromServer'>
	self byteStreamFromServer nextPutAll: aByteArray.
	^aByteArray size
    ]

    writeBytesToServer: aByteArray [
	"^self
	 This is where we make the bytes available over the pseudo socket.  Unlike a socket this is a one off thing (at least in this implementation of the pseudo socket).  Once the bytes are written, control passes to the server and stays there until the server sends a close to what it thinks is the client socket, but is really me."

	<category: 'actions-client'>
	| results |
	self byteStreamToServer: (ReadStream on: aByteArray).
	self byteStreamFromServer: (WriteStream on: (ByteArray new: 1000)).
	self serverWaitSemaphore signal.
	self clientWaitSemaphore wait.
	results := self byteStreamFromServer contents.
	self byteStreamToServer: nil.
	self byteStreamFromServer: nil.
	^results
    ]
]



TestCase subclass: CompositeResourceTest [
    | composite |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    sampleInSite [
	<category: 'testing'>
	| site |
	site := SwazooSite new.
	site 
	    host: 'swazoo.org'
	    ip: '127.0.0.1'
	    port: 8200.
	site addResource: composite
    ]

    setUp [
	<category: 'running'>
	composite := CompositeResource uriPattern: '/'
    ]

    testAddResource [
	<category: 'testing'>
	| child |
	composite 
	    addResource: (child := HelloWorldResource uriPattern: 'hello.html').
	self assert: composite children size = 1.
	self assert: composite children first == child.
	self assert: child parent == composite
    ]

    testAddResources [
	<category: 'testing'>
	| child1 child2 |
	child1 := HelloWorldResource uriPattern: 'hello1.html'.
	child2 := HelloWorldResource uriPattern: 'hello2.html'.
	composite addResources: (Array with: child1 with: child2).
	self assert: composite children size = 2.
	composite children do: 
		[:each | 
		self assert: (composite children includes: each).
		self assert: each parent == composite]
    ]

    testCurrentUrl [
	<category: 'testing'>
	| child leaf |
	self sampleInSite.
	self assert: composite currentUrl = 'http://swazoo.org:8200/'.
	composite addResource: (child := CompositeResource uriPattern: 'foo').
	self assert: child currentUrl = 'http://swazoo.org:8200/foo/'.
	child addResource: (leaf := HelloWorldResource uriPattern: 'hi.html').
	self assert: leaf currentUrl = 'http://swazoo.org:8200/foo/hi.html'
    ]

    testEmptyURIPatternInvalid [
	<category: 'testing'>
	composite uriPattern: ''.
	self deny: composite isValidlyConfigured
    ]

    testNilURIPatternDoesNothing [
	<category: 'testing'>
	| pattern |
	pattern := composite uriPattern.
	composite uriPattern: nil.
	self assert: composite uriPattern = pattern
    ]

    testValidlyConfigured [
	<category: 'testing'>
	self assert: composite isValidlyConfigured
    ]
]



TestCase subclass: FileResourceTest [
    | resource |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    setUp [
	<category: 'running'>
	| directory firstFile ws |
	directory := SpFilename named: 'fResTest'.
	directory exists ifFalse: [directory makeDirectory].
	firstFile := (SpFilename named: 'fResTest') construct: 'abc.html'.
	ws := firstFile writeStream.
	[ws nextPutAll: 'hello'] ensure: [ws close].
	resource := FileResource uriPattern: 'foo' filePath: 'fResTest'
    ]

    tearDown [
	<category: 'running'>
	((SpFilename named: 'fResTest') construct: 'abc.html') delete.
	(SpFilename named: 'fResTest') delete
    ]

    testContentType [
	<category: 'testing'>
	self assert: (resource contentTypeFor: '.txt') = 'text/plain'.
	self assert: (resource contentTypeFor: '.html') = 'text/html'
    ]

    testDirectoryIndex [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo/'.
	resource directoryIndex: 'abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'foo'
    ]

    testETag [
	"Filename etags do not have the leading and trailing double quotes.  Header fields add the quotes as necessary"

	<category: 'testing'>
	| request response etag |
	request := HTTPGet request: 'foo/abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self 
	    assert: (etag := (response headers fieldOfClass: HTTPETagField) entityTag) 
		    notNil.
	request := HTTPGet request: 'foo/abc.html'.
	request headers addField: (HTTPIfNoneMatchField new addEntityTag: etag).
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 304.
	self 
	    assert: (response headers fieldOfClass: HTTPETagField) entityTag = etag.
	request := HTTPGet request: 'foo/abc.html'.
	request headers addField: (HTTPIfNoneMatchField new valueFrom: '"wrong"').
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self 
	    assert: (response headers fieldOfClass: HTTPETagField) entityTag = etag
    ]

    testExistantFile [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo/abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'foo'
    ]

    testNonexistantFile [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo/notThere.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil
    ]

    testRedirection [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo'.
	resource directoryIndex: 'abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 301.
	self assert: (response headers fieldNamed: 'Location') uri asString 
		    = 'http://foo/'.
	self assert: (response headers fieldNamed: 'Location') uri host = 'foo'
    ]

    testRelativeFile [
	"it doesn't work anyway!!
	 | request response |
	 request := HTTPGet request: 'foo/../', resource fileDirectory tail, '/abc.html'.
	 response := URIResolution resolveRequest: request startingAt: resource.
	 self assert: response isNil"

	<category: 'testing'>
	
    ]

    testSafeConstruct [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo/../abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	request := HTTPGet request: 'foo/.. /./abc.html'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200
    ]
]



TestCase subclass: HTTPPostTest [
    | request |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    crlf [
	<category: 'requests'>
	^String with: Character cr with: Character lf
    ]

    fileContents [
	"HTTPRequestTest new fileContents"

	<category: 'requests'>
	| stream |
	stream := SwazooStream on: String new.
	stream
	    nextPutLine: 'BEGIN:VCALENDAR';
	    nextPutLine: 'PRODID:-//Squeak-iCalendar//-';
	    nextPutLine: 'VERSION:2.0';
	    nextPutLine: 'X-WR-CALNAME:test';
	    nextPutLine: 'METHOD:PUBLISH';
	    nextPutLine: 'BEGIN:VEVENT';
	    nextPutLine: 'UID:an event with a start date and not date and time';
	    nextPutLine: 'CATEGORIES:category1,category2';
	    nextPutLine: 'CREATED:20050501T110231Z';
	    nextPutLine: 'SEQUENCE:0';
	    nextPutLine: 'SUMMARY:aTitle';
	    nextPutLine: 'PRIORITY:5';
	    nextPutLine: 'DTSTART;VALUE=DATE:20050425';
	    nextPutLine: 'END:VEVENT';
	    nextPutLine: 'END:VCALENDAR'.
	^stream writeBufferContents asString
    ]

    postDashes [
	<category: 'requests'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
	    nextPutLine: 'Content-Length: 149';
	    crlf;
	    nextPutLine: '--boundary';
	    nextPutLine: 'Content-Disposition: form-data; name="id5273"';
	    crlf;
	    nextPutLine: '----';
	    nextPutLine: '--boundary';
	    nextPutLine: 'Content-Disposition: form-data; name="field2"';
	    crlf;
	    nextPutLine: '- --';
	    nextPutLine: '--boundary--'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    postEmpty [
	"post entity with empty value"

	<category: 'requests'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
	    nextPutLine: 'Content-Length: 75';
	    crlf;
	    nextPutLine: '--boundary';
	    nextPutLine: 'Content-Disposition: form-data; name="id5273"';
	    crlf;
	    nextPutLine: '';
	    nextPutLine: '--boundary--'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    postFile [
	<category: 'requests'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Connection: Keep-Alive';
	    nextPutLine: 'User-Agent: Mozilla/4.72 [en] (X11; I; Linux 2.3.51 i686)';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Referer: http://www.bar.com/takeMeThere.html';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= -----------------20752836116568320241700153999';
	    nextPutLine: 'Content-Length: ' 
			, (527 + self fileContents size) printString;
	    crlf;
	    nextPutLine: '-------------------20752836116568320241700153999';
	    nextPutLine: 'Content-Disposition: form-data; name="id5273"';
	    crlf;
	    nextPutLine: 'main';
	    nextPutLine: '-------------------20752836116568320241700153999';
	    nextPutLine: 'Content-Disposition: form-data; name="field2"';
	    crlf;
	    crlf;
	    nextPutLine: '-------------------20752836116568320241700153999';
	    nextPutLine: 'Content-Disposition: form-data; name="field7"; filename="event.ical"';
	    nextPutLine: 'Content-Type: application/octet-stream';
	    crlf;
	    nextPutAll: self fileContents;
	    crlf;
	    nextPutLine: '-------------------20752836116568320241700153999';
	    nextPutLine: 'Content-Disposition: form-data; name="attach"';
	    crlf;
	    nextPutLine: 'Attach';
	    nextPutLine: '-------------------20752836116568320241700153999--'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    postPreambleEpilogue [
	<category: 'requests'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
	    nextPutLine: 'Content-Length: 146';
	    crlf;
	    nextPutLine: 'This is a multi-part message in MIME format';
	    nextPutLine: '--boundary';
	    nextPutLine: 'Content-Disposition: form-data; name="id5273"';
	    crlf;
	    nextPutLine: 'main';
	    nextPutLine: '--boundary--';
	    nextPutLine: 'This is the epilogue'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    postSimple [
	<category: 'requests'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= boundary';
	    nextPutLine: 'Content-Length: 79';
	    crlf;
	    nextPutLine: '--boundary';
	    nextPutLine: 'Content-Disposition: form-data; name="id5273"';
	    crlf;
	    nextPutLine: 'main';
	    nextPutLine: '--boundary--'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    postUrlEncoded [
	<category: 'requests'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST  /document/aab.html HTTP/1.1';
	    nextPutLine: 'Host: biart.eranova.si';
	    nextPutLine: 'Content-Type: application/x-www-form-urlencoded';
	    nextPutLine: 'Content-Length: 36';
	    crlf;
	    nextPutAll: 'home=Cosby+one&favorite+flavor=flies'.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    testBlockCopy [
	"streaming with 8k blocks for performance"

	"this is just a basic test with content shorter that one block"

	<category: 'testing-mime parsing'>
	| boundary message in out |
	boundary := '--boundary--'.
	message := 'just something'.
	in := SwazooStream on: message , self crlf , boundary.
	out := WriteStream on: String new.
	HTTPPost new 
	    blockStreamingFrom: in
	    to: out
	    until: boundary.
	self assert: out contents = message
    ]

    testPost10Simple [
	"just one entity"

	<category: 'testing-posts'>
	| post |
	post := self postSimple.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = 'main'
    ]

    testPost2Empty [
	"post entity with empty value"

	<category: 'testing-posts'>
	| post |
	post := self postEmpty.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = ''
    ]

    testPost3Dashes [
	"some ---- inside post data"

	<category: 'testing-posts'>
	| post |
	post := self postDashes.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = '----'.
	self assert: (post postDataStringAt: 'field2') = '- --'
    ]

    testPost40File [
	<category: 'testing-file posts'>
	| post |
	post := self postFile.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = 'main'.
	self assert: (post postDataStringAt: 'field2') = ''.
	self assert: (post postDataAt: 'field7') filename = 'event.ical'.
	self 
	    assert: ((post postDataStringAt: 'field7') readStream upTo: Character cr) 
		    = 'BEGIN:VCALENDAR'.
	self assert: (post postDataStringAt: 'field7') = self fileContents.
	self assert: (post postDataStringAt: 'attach') = 'Attach'
    ]

    testPost41FileStreamed [
	<category: 'testing-file posts'>
	| post stream |
	post := self postFile.
	stream := WriteStream on: ByteArray new.
	post postDataAt: 'field7' streamTo: stream.
	self assert: (post isPostDataStreamedAt: 'field7').
	self deny: post postData isParsed.	"post data read from socket defered"
	self assert: (post postDataStringAt: 'id5273') = 'main'.
	self assert: post postData isParsed.	"first access to post data trigger full read and parse"
	self assert: (post postDataAt: 'field7') filename = 'event.ical'.
	self assert: (stream contents asString readStream upTo: Character cr) 
		    = 'BEGIN:VCALENDAR'.
	self assert: stream contents asString = self fileContents.
	self assert: (post postDataStringAt: 'attach') = 'Attach'
    ]

    testPost42FileContentType [
	<category: 'testing-file posts'>
	| post |
	post := self postFile.	"set the data to the post"
	self assert: post isPostDataEmpty not.	"read the content of the stream"
	self assert: (post postDataAt: 'field7') contentType 
		    = 'application/octet-stream'
    ]

    testPost5UrlEncoded [
	"just one entity"

	<category: 'testing-posts'>
	| post |
	post := self postUrlEncoded.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'home') = 'Cosby one'.
	self assert: (post postDataStringAt: 'favorite flavor') = 'flies'
    ]

    testPostPreambleEpilogue [
	"mime preamble before first part and epilogue at the end. See #postPreambleEpilogue"

	<category: 'testing-posts'>
	| post |
	post := self postPreambleEpilogue.
	self assert: post isPostDataEmpty not.
	self assert: (post postDataStringAt: 'id5273') = 'main'
    ]

    testPostRawEntity [
	<category: 'testing-posts'>
	| requestStream post |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST /foobar HTTP/1.0';
	    nextPutLine: 'Host: foo.com';
	    nextPutLine: 'Content-Type: text/plain';
	    nextPutLine: 'Content-Length: 12';
	    crlf;
	    nextPutLine: 'Hello, World'.
	post := HTTPRequest 
		    readFrom: (SwazooStream on: requestStream writeBufferContents).
	self assert: post isPostDataEmpty.
	self assert: post entityBody = 'Hello, World'
    ]

    testPostUrlEncodedData [
	<category: 'testing-posts'>
	| requestStream post |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST / HTTP/1.1';
	    nextPutLine: 'Host: foo.com';
	    nextPutLine: 'Content-Type: application/x-www-form-urlencoded';
	    nextPutLine: 'Content-Length: 31';
	    crlf;
	    nextPutLine: 'address=+fs&product=&quantity=1'.
	post := HTTPRequest 
		    readFrom: (SwazooStream on: requestStream writeBufferContents).
	self assert: (post postDataAt: 'address') value = ' fs'.
	self assert: (post postDataAt: 'product') value = ''.
	self assert: (post postDataAt: 'quantity') value = '1'
    ]
]



TestCase subclass: HTTPRequestTest [
    | request |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    basicGet [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET / HTTP/1.1';
	    nextPutLine: 'Host: foo.com';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    basicGetHTTP10 [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET / HTTP/1.0';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    basicGetHTTP10Keepalive [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET / HTTP/1.0';
	    nextPutLine: 'Connection: Keep-Alive';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    basicHead [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'HEAD / HTTP/1.1';
	    nextPutLine: 'Host: foo.com';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    crlfOn: aStream [
	<category: 'private'>
	aStream
	    nextPut: Character cr;
	    nextPut: Character lf
    ]

    fullGet [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET /aaa/bbb/ccc.html?foo=bar&baz=quux HTTP/1.1';
	    nextPutLine: 'Connection: Keep-Alive';
	    nextPutLine: 'User-Agent: Mozilla/4.72 [en] (X11; I; Linux 2.3.51 i686)';
	    nextPutLine: 'Host: foo.com:8888';
	    nextPutLine: 'Referer: http://www.bar.com/takeMeThere.html';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    getMultiValueHeader [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET /aaa/bbb/ccc.html?foo=bar&baz=quux HTTP/1.1';
	    nextPutLine: 'Content-Type: multipart/form-data; boundary= --boundary';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    portedGet [
	<category: 'requests-gets'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET / HTTP/1.1';
	    nextPutLine: 'Host: foo.com:8888';
	    crlf.
	^HTTPRequest 
	    readFrom: (SwazooStream on: requestStream writeBufferContents)
    ]

    test10ConnectionClose [
	<category: 'testing-other'>
	request := self basicGetHTTP10.
	self assert: request wantsConnectionClose
    ]

    test10KeepAliveConnectionClose [
	<category: 'testing-other'>
	request := self basicGetHTTP10Keepalive.
	self deny: request wantsConnectionClose
    ]

    testBasicGet [
	<category: 'testing-gets'>
	request := self basicGet.
	self assert: request isGet.
	self assert: request isHttp11.
	self deny: request isHead.
	self deny: request isPost.
	self deny: request isPut
    ]

    testBasicGetHTTP10 [
	<category: 'testing-gets'>
	request := self basicGetHTTP10.
	self assert: request isGet.
	self assert: request isHttp10.
	self deny: request isHead.
	self deny: request isPost.
	self deny: request isPut
    ]

    testBasicGetHost [
	<category: 'testing-gets'>
	request := self basicGet.
	self assert: request host = 'foo.com'
    ]

    testBasicGetPort [
	<category: 'testing-gets'>
	request := self basicGet.
	self assert: request port = 80
    ]

    testBasicHead [
	<category: 'testing-gets'>
	request := self basicHead.
	self assert: request isHead.
	self deny: request isGet.
	self deny: request isPost.
	self deny: request isPut
    ]

    testConnection [
	<category: 'testing-other'>
	request := self fullGet.
	self assert: request connection = 'Keep-Alive'
    ]

    testGetMultiValueHeader [
	<category: 'testing-gets'>
	| header |
	request := self getMultiValueHeader.
	header := request headerAt: 'Content-Type' ifAbsent: [nil].
	self assert: header mediaType = 'multipart/form-data'.
	self assert: (header transferCodings at: 'boundary') = '--boundary'.
	self 
	    assert: header valuesAsString = 'multipart/form-data boundary=--boundary'

	"'Content-Type: multipart/form-data; boundary= --boundary';"
    ]

    testHeaderAtIfPresent [
	<category: 'testing-other'>
	request := self basicGet.
	self assert: (request headers 
		    fieldOfClass: HTTPIfRangeField
		    ifPresent: [:header | header == (request headers fieldOfClass: HTTPIfRangeField)]
		    ifAbsent: [true]).
	self assert: (request headers 
		    fieldOfClass: HTTPHostField
		    ifPresent: [:header | header == (request headers fieldOfClass: HTTPHostField)]
		    ifAbsent: [false])
    ]

    testMissingContentType [
	<category: 'testing-other'>
	| requestStream result |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'POST /foobar HTTP/1.0';
	    nextPutLine: 'Host: foo.com';
	    nextPutLine: 'Content-Length: 12';
	    crlf;
	    nextPutLine: 'Hello, World'.
	"nextPutLine: 'Content-Type: text/plain'. <-- this is missing!! - and should be for this test"
	result := SpExceptionContext 
		    for: 
			[(HTTPRequest 
			    readFrom: (SwazooStream on: requestStream writeBufferContents)) 
				ensureFullRead	"because of defered post data parsing"]
		    on: SpError
		    do: [:ex | ex].
	self assert: result class == SwazooHTTPPostError.
	^self
    ]

    testNo11ConnectionClose [
	<category: 'testing-other'>
	request := self basicGet.
	self deny: request wantsConnectionClose
    ]

    testNoEqualsQueries [
	"The last assert here used to check that 'request queryAt: 'WSDL'' is nil, but a test for an empty string is more consistent with query argument formats."

	<category: 'testing-other'>
	| requestStream |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET /test/typed.asmx?WSDL HTTP/1.1';
	    nextPutLine: 'Host: foo.com:8888';
	    crlf.
	request := HTTPRequest 
		    readFrom: (SwazooStream on: requestStream writeBufferContents).
	self assert: (request includesQuery: 'WSDL').
	self assert: (request queryAt: 'WSDL') isEmpty
    ]

    testPortedGetPort [
	<category: 'testing-gets'>
	request := self portedGet.
	self assert: request port = 8888
    ]

    testReferer [
	<category: 'testing-other'>
	request := self fullGet.
	self 
	    assert: request referer asString = 'http://www.bar.com/takeMeThere.html'
    ]

    testRequestWithCRButNoLF [
	"| requestStream result |
	 requestStream := SwazooStream on: String new.
	 requestStream
	 nextPutAll: 'GET / HTTP/1.1';
	 cr.
	 result := SpExceptionContext
	 for: [HTTPRequest readFrom: (SwazooStream on: requestStream writeBufferContents)]
	 on: SpError
	 do: [:ex | ex].
	 self assert: result class == SwazooHTTPParseError.
	 ^self"

	<category: 'testing-other'>
	
    ]

    testUserAgent [
	<category: 'testing-other'>
	request := self fullGet.
	self 
	    assert: request userAgent = 'Mozilla/4.72 [en] (X11; I; Linux 2.3.51 i686)'
    ]
]



TestCase subclass: HTTPResponseTest [
    | response |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    crlf [
	<category: 'private'>
	^String with: Character cr with: Character lf
    ]

    testInternalServerError [
	<category: 'testing'>
	| ws rs |
	response := HTTPResponse internalServerError.
	ws := SwazooStream on: String new.
	HTTPPrinter new response: response; stream: ws; printStatus.
	rs := SwazooStream on: ws writeBufferContents.
	self assert: rs nextLine = 'HTTP/1.1 500 Internal Server Error'
    ]

    testOK [
	<category: 'testing'>
	| ws rs |
	response := HTTPResponse ok.
	ws := SwazooStream on: String new.
	HTTPPrinter new response: response; stream: ws; printStatus.
	rs := SwazooStream on: ws writeBufferContents.
	self assert: rs nextLine = 'HTTP/1.1 200 OK'
    ]

    testResponseTypes [
	<category: 'testing'>
	self assert: HTTPResponse badRequest isBadRequest.
	self assert: HTTPResponse found isFound.
	self assert: HTTPResponse internalServerError isInternalServerError.
	self assert: HTTPResponse movedPermanently isMovedPermanently.
	self assert: HTTPResponse notFound isNotFound.
	self assert: HTTPResponse notImplemented isNotImplemented.
	self assert: HTTPResponse notModified isNotModified.
	self assert: HTTPResponse ok isOk.
	self assert: HTTPResponse redirectLink isRedirectLink.
	self assert: HTTPResponse seeOther isSeeOther
    ]
]



TestCase subclass: HTTPServerTest [
    | server stream |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    setUp [
	<category: 'running'>
	| socket |
	(Delay forMilliseconds: 100) wait.
	server := HTTPServer new.
	
	[server
	    ip: 'localhost';
	    port: 8123.
	server start] fork.
	(Delay forMilliseconds: 100) wait.
	"stream := (SocketAccessor newTCPclientToHost: 'localhost' port: 8123)
	 readAppendStream"
	socket := SpSocket connectToServerOnHost: 'localhost' port: 8123.
	stream := SwazooStream socket: socket
    ]

    tearDown [
	<category: 'running'>
	server stop.
	stream close.
	stream := nil.
	Delay forMilliseconds: 500
    ]

    testServing [
	<category: 'tests'>
	self assert: server isServing
    ]

    testStopServing [
	<category: 'tests'>
	server stop.
	self deny: server isServing
    ]
]



TestCase subclass: HeaderFieldTest [
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    testCombine [
	"Entity tags must be quoted strings - RFC 2616 3.11"

	<category: 'testing'>
	| header1 header2 header3 |
	header1 := HeaderField fromLine: 'If-Match: "a"'.
	header2 := HeaderField fromLine: 'If-Match: "b","c"'.
	header3 := HeaderField fromLine: 'If-Match: "d"'.
	header1 combineWith: header2.
	self assert: header1 valuesAsString = '"a","b","c"'.
	header1 combineWith: header3.
	self assert: header1 valuesAsString = '"a","b","c","d"'
    ]

    testContentTypeMultiple [
	"HTTP/1.1 header field values can be folded onto multiple lines if the
	 continuation line begins with a space or horizontal tab. All linear
	 white space, including folding, has the same semantics as SP. A
	 recipient MAY replace any linear white space with a single SP before
	 interpreting the field value or forwarding the message downstream.
	 
	 LWS            = [CRLF] 1*( SP | HT )"

	<category: 'testing'>
	| requestStream request field |
	requestStream := SwazooStream on: String new.
	requestStream
	    nextPutLine: 'GET / HTTP/1.1';
	    nextPutLine: 'Host: 127.0.0.1';
	    nextPutLine: 'Content-Type: text/html; ';
	    nextPutLine: ' charset=iso-8859-1';
	    crlf.
	request := HTTPRequest 
		    readFrom: (SwazooStream on: requestStream writeBufferContents).
	field := request headers fieldNamed: 'content-type'.
	self assert: field name = 'Content-Type'.
	self assert: field mediaType = 'text/html'.
	self assert: (field transferCodings at: 'charset') = 'iso-8859-1'
    ]

    testValues [
	"Entity tags are held internally as simple strings.  Any necessary leading and trailing double quotes are added by the header fields as needed.  Note that it is OK to have a comma in an entity tag - see the second of the group of 3 tags below."

	<category: 'testing'>
	| header |
	header := HeaderField fromLine: 'If-Match: "xyzzy" '.
	self assert: header name = 'If-Match'.
	self assert: header entityTags first = 'xyzzy'.
	header := HeaderField 
		    fromLine: 'If-Match: "xyzzy", "r2d2,xxxx", "c3piozzzz" '.
	self assert: header name = 'If-Match'.
	self assert: header entityTags first = 'xyzzy'.
	self assert: (header entityTags at: 2) = 'r2d2,xxxx'.
	self assert: header entityTags last = 'c3piozzzz'
    ]
]



TestCase subclass: HelloWorldResourceTest [
    | hello |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    setUp [
	<category: 'running'>
	hello := HelloWorldResource uriPattern: 'hello.html'
    ]

    testResponse [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'hello.html'.
	response := URIResolution resolveRequest: request startingAt: hello.
	self assert: response code = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'hello.html'
    ]
]



TestCase subclass: HomeResourceTest [
    | resource |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    setUp [
	<category: 'running'>
	resource := HomeResource uriPattern: '/' filePath: 'home'
    ]

    testRootFileFor [
	<category: 'running'>
	| request |
	request := HTTPGet request: '/~someUser'.
	URIResolution new initializeRequest: request.
	self assert: (resource rootFileFor: request) asString 
		    = (((SpFilename named: 'home') construct: 'someUser') construct: 'html') 
			    asString
    ]

    testValidateHomePath [
	<category: 'running'>
	self assert: (resource validateHomePath: '~somebody').
	self assert: (resource validateHomePath: '~somebodyElse').
	self deny: (resource validateHomePath: 'someplace').
	self deny: (resource validateHomePath: 'some~body')
    ]
]



TestCase subclass: RedirectionResourceTest [
    | resource |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    setUp [
	<category: 'running'>
	resource := RedirectionResource uriPattern: 'foo'
		    targetUri: 'http://abc.def.com'
    ]

    testGetResource [
	<category: 'testing'>
	| request response |
	request := HTTPGet request: 'foo'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 301.
	self assert: (response headers fieldNamed: 'Location') uri asString 
		    = 'http://abc.def.com'.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'foo'
    ]
]



TestCase subclass: ResourceTest [
    | resource |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    basicGet: uri [
	<category: 'private'>
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'GET ' , uri , ' HTTP/1.1'.
	self crlfOn: ws.
	ws nextPutAll: 'Host: swazoo.org'.
	self crlfOn: ws.
	self crlfOn: ws.
	^HTTPRequest readFrom: (ReadStream on: ws contents)
    ]

    basicGetUri: uriString [
	<category: 'private'>
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'GET ' , uriString , ' HTTP/1.1'.
	self crlfOn: ws.
	ws nextPutAll: 'Host: swazoo.org'.
	self crlfOn: ws.
	self crlfOn: ws.
	^HTTPRequest readFrom: (ReadStream on: ws contents)
    ]

    basicGetUri: uriString host: hostname port: port [
	<category: 'private'>
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'GET ' , uriString , ' HTTP/1.1'.
	self crlfOn: ws.
	ws nextPutAll: 'Host: ' , hostname.
	port notNil 
	    ifTrue: 
		[ws
		    nextPut: $:;
		    print: port].
	self crlfOn: ws.
	self crlfOn: ws.
	^HTTPRequest readFrom: (ReadStream on: ws contents)
    ]

    crlfOn: aStream [
	<category: 'private'>
	aStream
	    nextPut: Character cr;
	    nextPut: Character lf
    ]

    setUp [
	<category: 'running'>
	resource := SwazooResource uriPattern: 'foo'
    ]

    testEmptyURIPatternInvalid [
	<category: 'testing'>
	resource uriPattern: ''.
	self deny: resource isValidlyConfigured
    ]

    testEnabledByDefault [
	<category: 'testing'>
	self assert: resource isEnabled
    ]

    testNilURIPatternDoesNothing [
	<category: 'testing'>
	| pattern |
	pattern := resource uriPattern.
	resource uriPattern: nil.
	self assert: resource uriPattern = pattern
    ]

    testValidlyConfigured [
	<category: 'testing'>
	self assert: resource isValidlyConfigured
    ]

    testLeafMatch [
	<category: 'testing'>
	self assert: (resource match: 'foo')
    ]

    testLeafMismatch [
	<category: 'testing'>
	self deny: (resource match: 'Foo')
    ]

]



TestCase subclass: SiteIdentifierTest [
    | identifier |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    setUp [
	<category: 'running'>
	identifier := SiteIdentifier 
		    host: 'localhost'
		    ip: '127.0.0.1'
		    port: 80
    ]

    testCaseInsensitiveMatch [
	<category: 'testing'>
	| another |
	another := SiteIdentifier 
		    host: 'lOCaLhOST'
		    ip: '127.0.0.1'
		    port: 80.
	self assert: (identifier match: another)
    ]

    testCurrentUrl [
	<category: 'testing'>
	self assert: identifier currentUrl = 'http://localhost'.
	identifier := SiteIdentifier 
		    host: 'localhost'
		    ip: '127.0.0.1'
		    port: 81.
	self assert: identifier currentUrl = 'http://localhost:81'
    ]

    testHostMismatch [
	<category: 'testing'>
	| another |
	another := SiteIdentifier 
		    host: 'thisIsMyMachine'
		    ip: '127.0.0.1'
		    port: 80.
	self deny: (identifier match: another)
    ]

    testIPMismatch [
	<category: 'testing'>
	| another |
	another := SiteIdentifier 
		    host: 'localhost'
		    ip: '127.0.0.2'
		    port: 80.
	self deny: (identifier match: another)
    ]

    testMatch [
	<category: 'testing'>
	| another |
	another := SiteIdentifier 
		    host: 'localhost'
		    ip: '127.0.0.1'
		    port: 80.
	self assert: (identifier match: another)
    ]

    testPortMismatch [
	<category: 'testing'>
	| another |
	another := SiteIdentifier 
		    host: 'localhost'
		    ip: '127.0.0.1'
		    port: 81.
	self deny: (identifier match: another)
    ]
]



TestCase subclass: SiteTest [
    | site |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    addSecondAlias [
	<category: 'running'>
	site addAlias: (SiteIdentifier 
		    host: 'swazoo2.org'
		    ip: '127.0.0.2'
		    port: 8202)
    ]

    setUp [
	<category: 'running'>
	super setUp.
	site := SwazooSite new.
	site addAlias: (SiteIdentifier 
		    host: 'swazoo.org'
		    ip: '127.0.0.1'
		    port: 8200)
    ]

    testCurrentUrl [
	<category: 'testing'>
	site currentUrl = 'http://swazoo.org:8200'.
	self addSecondAlias.
	site currentUrl = 'http://swazoo.org:8200'
    ]

    testCurrentUrl80 [
	<category: 'testing'>
	| aSite |
	aSite := SwazooSite new.
	aSite addAlias: (SiteIdentifier 
		    host: 'swazoo.org'
		    ip: '127.0.0.1'
		    port: 80).
	aSite currentUrl = 'http://swazoo.org'.
	aSite currentUrl = 'http://swazoo.org'
    ]

    testRequestMatch [
	<category: 'testing'>
	| request site visitor |
	request := HTTPGet 
		    request: 'foo'
		    from: 'myhosthost:1234'
		    at: '1.2.3.4'.
	visitor := URIResolution new initializeRequest: request.
	site := SwazooSite new 
		    host: 'myhosthost'
		    ip: '1.2.3.4'
		    port: 1234.
	self assert: (site match: request)
    ]

    testRequestMismatch [
	<category: 'testing'>
	| request site |
	request := HTTPGet 
		    request: 'foo'
		    from: 'localhost:1234'
		    at: '1.2.3.4'.
	site := SwazooSite new 
		    host: 'remotehost'
		    ip: '1.2.3.4'
		    port: 1234.
	self deny: (site match: request)
    ]

]



TestCase subclass: SwazooBaseExtensionsTest [
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    testCharacterArrayTrimBlanks [
	<category: 'testing'>
	self 
	    assert: (HTTPString trimBlanksFrom: '   a b c d e f g') = 'a b c d e f g'.
	self assert: (HTTPString trimBlanksFrom: 'no blanks') = 'no blanks'.
	self assert: (HTTPString trimBlanksFrom: ' leading') = 'leading'.
	self assert: (HTTPString trimBlanksFrom: 'trailing ') = 'trailing'.
	self assert: (HTTPString trimBlanksFrom: '') = ''.
	self 
	    assert: (HTTPString 
		    trimBlanksFrom: (String with: Character cr with: Character lf)) isEmpty
    ]

    testFilenameEtag [
	"The filename etag is a simple string and does not contain double quotes.  Header fields apply double quotes as necessary when writing themselves."

	<category: 'testing'>
	| fn etag1 etag2 |
	fn := SpFilename named: 'etagTest'.
	
	[(fn writeStream)
	    nextPut: $-;
	    close.	"create file"
	etag1 := fn etag.
	(Delay forSeconds: 1) wait.
	(fn appendStream)
	    nextPut: $-;
	    close.	"modify file"
	etag2 := fn etag.
	self assert: (etag1 isKindOf: String).
	self assert: (etag2 isKindOf: String).
	self deny: etag1 = etag2] 
		ensure: [fn delete]
    ]

    testStringNewRandom [
	<category: 'testing'>
	| sizes strings |
	sizes := #(5 20 6127 2 100).
	strings := sizes collect: [:each | HTTPString newRandomString: each].
	strings with: sizes do: [:string :size | self assert: string size = size]
    ]
]



TestCase subclass: SwazooBoundaryTest [
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    testBoundaryFull [
	<category: 'testing-mime boundary'>
	| boundary stream |
	boundary := '--boundary--'.
	stream := SwazooStream on: 'just--boundary--something'.	"full boundary"
	self assert: (stream signsOfBoundary: boundary) = boundary size
    ]

    testBoundaryMixed [
	<category: 'testing-mime boundary'>
	| boundary stream |
	boundary := '--boundary--'.
	stream := SwazooStream on: 'yes,--just--boundary--something'.	"partial, later full boundary"
	self assert: (stream signsOfBoundary: boundary) = boundary size
    ]

    testBoundaryOnEdge [
	"part of boundary at the end of this stream, remaining probably in the next"

	<category: 'testing-mime boundary'>
	| boundary stream |
	boundary := '--boundary--'.
	stream := SwazooStream on: 'just something-'.	"just first char of boundary"
	self assert: (stream signsOfBoundary: boundary) = 1.
	stream := SwazooStream on: 'just something--'.	"two chars"
	self assert: (stream signsOfBoundary: boundary) = 2.
	stream := SwazooStream on: 'just something--bound'.	"half"
	self assert: (stream signsOfBoundary: boundary) = 7.
	stream := SwazooStream on: 'just something--boundary--'.	"full boundary at the edge"
	self assert: (stream signsOfBoundary: boundary) = boundary size
    ]

    testBoundaryOnEdgeMixed [
	"signs of boundary in the middle part at the end of this buffer, remaining probably in the next"

	<category: 'testing-mime boundary'>
	| boundary stream |
	boundary := '--boundary--'.
	stream := SwazooStream on: 'just-something-'.	"sign in the middle, one char at the end"
	self assert: (stream signsOfBoundary: boundary) = 1.
	stream := SwazooStream on: 'just-something--'.	"two chars"
	self assert: (stream signsOfBoundary: boundary) = 2.
	stream := SwazooStream on: 'just-so--mething--bound'.	"even more mixed case"
	self assert: (stream signsOfBoundary: boundary) = 7
    ]

    testBoundarySimple [
	<category: 'testing-mime boundary'>
	| boundary stream |
	boundary := '--boundary--'.
	stream := SwazooStream on: 'just something'.	"no boundary"
	self assert: (stream signsOfBoundary: boundary) = 0.
	stream := SwazooStream on: 'just-something'.	"sign of boundary"
	self assert: (stream signsOfBoundary: boundary) = 0.
	stream := SwazooStream on: 'just--something'.	"more sign of boundary"
	self assert: (stream signsOfBoundary: boundary) = 0.
	stream := SwazooStream on: 'just--boundary--something'.	"full boundary"
	self assert: (stream signsOfBoundary: boundary) = boundary size
    ]

    testIndexOfBoundary [
	"index of start of boundary in buffer, both full or partial at the edge/end of buffer"

	<category: 'testing-mime boundary'>
	| boundary stream |
	boundary := '--boundary--'.
	stream := SwazooStream on: 'just something'.	"no boundary"
	self assert: (stream indexOfBoundary: boundary) = 0.
	stream := SwazooStream on: 'just--boundary--something-'.	"full boundary"
	self assert: (stream indexOfBoundary: boundary) = 5.
	stream := SwazooStream on: 'just something--boun'.	"partial boundary at the edge"
	self assert: (stream indexOfBoundary: boundary) = 15.
	stream := SwazooStream on: 'just something-'.	"partial boundary, one char only"
	self assert: (stream indexOfBoundary: boundary) = 15.
	stream := SwazooStream on: 'just-som--ething--boun'.	"mixed case with partial at the edge"
	self assert: (stream indexOfBoundary: boundary) = 17
    ]
]



TestCase subclass: SwazooCacheControlTest [
    | resource cacheTarget request cacheControl |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    setUp [
	<category: 'running'>
	| directory firstFile ws |
	directory := SpFilename named: 'fResTest'.
	directory exists ifFalse: [directory makeDirectory].
	firstFile := directory construct: 'abc.html'.
	ws := firstFile writeStream.
	[ws nextPutAll: 'hello'] ensure: [ws close].
	resource := FileResource uriPattern: 'foo' filePath: 'fResTest'.
	request := HTTPGet request: 'foo/abc.html'.
	URIResolution resolveRequest: request startingAt: resource.
	cacheControl := SwazooCacheControl new request: request
		    cacheTarget: (cacheTarget := resource fileFor: request)
    ]

    tearDown [
	<category: 'running'>
	((SpFilename named: 'fResTest') construct: 'abc.html') delete.
	(SpFilename named: 'fResTest') delete
    ]

    testIfModifiedSinceModified [
	<category: 'testing'>
	| response timestampInThePast |
	request := HTTPGet request: 'foo/abc.html'.
	timestampInThePast := SpTimestamp fromDate: (Date today subtractDays: 1)
		    andTime: Time now.
	request headers addField: (HTTPIfModifiedSinceField new 
		    valueFrom: timestampInThePast asRFC1123String).
	cacheControl := SwazooCacheControl new request: request
		    cacheTarget: cacheTarget.
	self assert: cacheControl isNotModified not.
	self assert: cacheControl isIfModifiedSince.
	response := HTTPResponse ok.
	cacheControl addResponseHeaders: response.
	self 
	    assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
		    = cacheTarget lastModified
    ]

    testIfModifiedSinceNot [
	<category: 'testing'>
	| response |
	request headers addField: (HTTPIfModifiedSinceField new 
		    valueFrom: cacheTarget lastModified asRFC1123String).
	self assert: cacheControl isNotModified.
	self assert: cacheControl isIfModifiedSince not.
	response := HTTPResponse notModified.
	cacheControl addResponseHeaders: response.
	self 
	    assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
		    = cacheTarget lastModified
    ]

    testIfNoneMatchHeaderMatch [
	"same etag"

	<category: 'testing'>
	| response |
	request headers 
	    addField: (HTTPIfNoneMatchField new addEntityTag: cacheTarget etag).
	self assert: cacheControl isNotModified.
	self deny: cacheControl isIfNoneMatch.

	"do NOT include last-modified"
	response := HTTPResponse notModified.
	cacheControl addResponseHeaders: response.
	self 
	    assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self 
	    assert: (response headers fieldNamed: 'Last-Modified' ifNone: [nil]) isNil
    ]

    testIfNoneMatchHeaderNone [
	"same etag"

	<category: 'testing'>
	| response |
	request := HTTPGet request: 'foo/abc.html'.
	request headers addField: (HTTPIfNoneMatchField new valueFrom: 'blah').
	cacheControl := SwazooCacheControl new request: request
		    cacheTarget: cacheTarget.
	self assert: cacheControl isNotModified not.
	self assert: cacheControl isIfNoneMatch.
	response := HTTPResponse ok.
	cacheControl addResponseHeaders: response.
	self 
	    assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
		    = cacheTarget lastModified
    ]

    testNoHeaders [
	<category: 'testing'>
	| response |
	self assert: cacheControl isNotModified not.
	self assert: cacheControl isIfNoneMatch.
	self assert: cacheControl isIfModifiedSince.

	"add both"
	response := HTTPResponse ok.
	cacheControl addResponseHeaders: response.
	self 
	    assert: (response headers fieldNamed: 'ETag') entityTag = cacheTarget etag.
	self assert: (response headers fieldNamed: 'Last-Modified') timestamp 
		    = cacheTarget lastModified
    ]
]



TestCase subclass: SwazooCompilerTest [
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    testEvaluate [
	<category: 'running'>
	self assert: (SwazooCompiler evaluate: '1 + 2 * 3') = 9
    ]

    testEvaluateReceiver [
	<category: 'running'>
	self assert: (SwazooCompiler evaluate: 'self + 2 * 3' receiver: 1) = 9
    ]
]



TestCase subclass: SwazooConfigurationTest [
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    testCompositeResourceSite [
	<category: 'testing'>
	| rs site composite howdy duh hithere |
	rs := ReadStream 
		    on: '<Site>
 <CompositeResource uriPattern: ''/''>
  <HelloWorldResource uriPattern: ''howdy''>
  <CompositeResource uriPattern: ''duh''>
   <HelloWorldResource uriPattern: ''hithere''>
  </CompositeResource>
 </CompositeResource>
</Site>'.
	site := SwazooSite new readFrom: rs.
	self assert: site children size = 1.
	composite := site children first.
	self assert: composite class == CompositeResource.
	self assert: composite uriPattern = '/'.
	self assert: composite children size = 2.
	self assert: composite parent == site.
	howdy := composite children first.
	self assert: howdy class == HelloWorldResource.
	self assert: howdy uriPattern = 'howdy'.
	self assert: howdy parent == composite.
	duh := composite children last.
	self assert: duh children size = 1.
	self assert: duh class == CompositeResource.
	self assert: duh uriPattern = 'duh'.
	self assert: duh parent == composite.
	hithere := duh children first.
	self assert: hithere class == HelloWorldResource.
	self assert: hithere uriPattern = 'hithere'.
	self assert: hithere parent == duh
    ]

    testEmptySite [
	<category: 'testing'>
	| rs site alias |
	rs := ReadStream 
		    on: '<Site>
 <SiteIdentifier ip: ''192.168.1.66'' port: 80 host: ''swazoo.org''>
</Site>'.
	site := SwazooSite new readFrom: rs.
	self assert: site aliases size = 1.
	self assert: site currentUrl = 'http://swazoo.org/'.
	alias := site aliases first.
	self assert: alias host = 'swazoo.org'.
	self assert: alias ip = '192.168.1.66'.
	self assert: alias port = 80
    ]

    testFileResourceSite [
	<category: 'testing'>
	| rs site resource |
	rs := ReadStream 
		    on: '<Site>
<SiteIdentifier ip: ''192.168.1.66'' port: 80 host: ''swazoo.org''>
 <FileResource uriPattern: ''/'' filePath: ''files''>
</Site>'.
	site := SwazooSite new readFrom: rs.
	self assert: site children size = 1.
	resource := site children first.
	self assert: resource class == FileResource.
	self assert: resource uriPattern = '/'.
	self assert: resource filePath = 'files'.
	self assert: resource parent == site.
	self assert: resource currentUrl = 'http://swazoo.org/'
    ]

    testMultipleResourcesSite [
	<category: 'testing'>
	| rs site resource1 resource2 |
	rs := ReadStream 
		    on: '<Site>
 <HelloWorldResource uriPattern: ''/''>
 <HelloWorldResource uriPattern: ''/''>
</Site>'.
	site := SwazooSite new readFrom: rs.
	self assert: site children size = 2.
	resource1 := site children first.
	self assert: resource1 class == HelloWorldResource.
	self assert: resource1 uriPattern = '/'.
	resource2 := site children last.
	self assert: resource2 class == HelloWorldResource.
	self assert: resource2 uriPattern = '/'
    ]

    testMultipleSites [
	<category: 'testing'>
	| rs sites site alias1 alias2 |
	rs := ReadStream 
		    on: '<Site>
 <SiteIdentifier ip: ''192.168.1.66'' port: 80 host: ''swazoo.org''>
 <SiteIdentifier ip: ''192.168.1.66'' port: 81 host: ''swazoo.org''>
</Site>
<Site>
</Site>'.
	sites := SwazooServer readSitesFrom: rs.
	self assert: sites size = 2.
	site := sites first.
	self assert: site aliases size = 2.
	alias1 := site aliases first.
	self assert: alias1 host = 'swazoo.org'.
	self assert: alias1 ip = '192.168.1.66'.
	self assert: alias1 port = 80.
	alias2 := site aliases last.
	self assert: alias2 host = 'swazoo.org'.
	self assert: alias2 ip = '192.168.1.66'.
	self assert: alias2 port = 81
    ]

    testSingleResourceSite [
	<category: 'testing'>
	| rs site resource |
	rs := ReadStream 
		    on: '<Site>
<SiteIdentifier ip: ''192.168.1.66'' port: 80 host: ''swazoo.org''>
 <HelloWorldResource uriPattern: ''/''>
</Site>'.
	site := SwazooSite new readFrom: rs.
	self assert: site children size = 1.
	resource := site children first.
	self assert: resource class == HelloWorldResource.
	self assert: resource uriPattern = '/'.
	self assert: resource parent == site.
	self assert: resource currentUrl = 'http://swazoo.org/'
    ]

    testSiteTag [
	<category: 'testing'>
	| rs config tag |
	rs := ReadStream on: '  <Site>  

</Site>   '.
	config := SwazooSite new.
	tag := config nextTagFrom: rs.
	self assert: tag = 'Site'.
	tag := config nextTagFrom: rs.
	self assert: tag = '/Site'.
	self assert: (config nextTagFrom: rs) isNil
    ]
]



TestCase subclass: SwazooServerTest [
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    removeTestSiteIfAny [
	<category: 'support'>
	| site |
	site := SwazooServer siteNamed: self testSiteName.
	site notNil ifTrue: [SwazooServer singleton removeSite: site]
    ]

    testAccessingSite [
	<category: 'testing'>
	| site |
	self removeTestSiteIfAny.
	site := (SwazooSite new)
		    name: self testSiteName;
		    host: 'test.org'
			ip: 'localhost'
			port: 8543.
	
	[SwazooServer singleton addSite: site.
	self assert: (SwazooServer siteNamed: self testSiteName) notNil.
	site := SwazooServer siteNamed: self testSiteName.
	self assert: site name = self testSiteName.
	self assert: (SwazooServer siteHostnamed: 'test.org') notNil.
	site := SwazooServer siteHostnamed: 'test.org'.
	self assert: site host = 'test.org'] 
		ensure: [SwazooServer singleton removeSite: site]
    ]

    testAddingAllInterfacesSite [
	"site to listen on all IP interfaces but on specified port"

	<category: 'testing-adding sites'>
	| site server |
	self removeTestSiteIfAny.
	server := SwazooServer singleton.
	self assert: (server siteNamed: self testSiteName) isNil.
	site := (SwazooSite new)
		    name: self testSiteName;
		    host: '*'
			ip: '*'
			port: 7261.
	
	[server addSite: site.
	self assert: (server siteNamed: self testSiteName) notNil] 
		ensure: [server removeSite: site]
    ]

    testAddingSite [
	<category: 'testing-adding sites'>
	| site server nrSites |
	self removeTestSiteIfAny.
	server := SwazooServer singleton.
	nrSites := server sites size.
	self assert: (server siteNamed: self testSiteName) isNil.
	self assert: (server siteHostnamed: self testSiteName) isNil.
	site := (SwazooSite new)
		    name: self testSiteName;
		    host: 'test.org'
			ip: 'localhost'
			port: 5798.
	server addSite: site.
	self assert: (server siteNamed: self testSiteName) notNil.
	self assert: (server siteHostnamed: 'test.org') notNil.
	server removeSite: site.
	self assert: server sites size = nrSites
    ]

    testAllInterfacesTwoPortSites [
	"two sites can run on all IP interfaces and different port"

	<category: 'testing-adding sites'>
	| server site1 site2 |
	server := SwazooServer singleton.
	site1 := (SwazooSite new)
		    name: 'allInterfaces1';
		    host: '*'
			ip: '*'
			port: 7261.
	site2 := (SwazooSite new)
		    name: 'allInterfaces2';
		    host: '*'
			ip: '*'
			port: 7262.
	
	[server addSite: site1.
	self shouldnt: [server addSite: site2] raise: Error] 
		ensure: 
		    [server
			removeSite: site1;
			removeSite: site2]
    ]

    testAllStarsThenExactOnOtherPort [
	<category: 'testing-adding sites'>
	| server site1 site2 |
	server := SwazooServer singleton.
	site1 := (SwazooSite new)
		    name: 'allstar232';
		    host: '*'
			ip: '*'
			port: 7261.
	site2 := (SwazooSite new)
		    name: 'exactdfdf';
		    host: 'localhost'
			ip: 'localhost'
			port: 7262.
	
	[server addSite: site1.
	self shouldnt: 
		[server
		    addSite: site2;
		    removeSite: site2]
	    raise: Error] 
		ensure: [server removeSite: site1]
    ]

    testDuplicateAllInterfacesSite [
	"two sites cannot run on all IP interfaces and same port"

	<category: 'testing-adding sites'>
	| server site1 site2 |
	server := SwazooServer singleton.
	site1 := (SwazooSite new)
		    name: 'allInterfaces1';
		    host: '*'
			ip: '*'
			port: 7261.
	site2 := (SwazooSite new)
		    name: 'allInterfaces2';
		    host: '*'
			ip: '*'
			port: 7261.
	
	[server addSite: site1.
	self should: [server addSite: site2] raise: Error] 
		ensure: [server removeSite: site1]
    ]

    testDuplicateNames [
	<category: 'testing-adding sites'>
	| site server |
	self removeTestSiteIfAny.
	server := SwazooServer singleton.
	site := (SwazooSite new)
		    name: self testSiteName;
		    host: 'test.org'
			ip: 'localhost'
			port: 6376.
	
	[server addSite: site.
	self should: [site name: self testSiteName] raise: Error.
	self shouldnt: [site host: 'test.org'] raise: Error.
	self should: 
		[(SwazooSite new)
		    name: self testSiteName;
		    host: 'test.org'
			ip: 'localhost'
			port: 6376]
	    raise: Error] 
		ensure: [server removeSite: site]
    ]

    testSiteName [
	<category: 'support'>
	^'aaabbcc987'
    ]

    testStartingOnAPort [
	"and all ip interfaces, any host"

	<category: 'testing'>
	| site server nrServers |
	server := SwazooServer singleton.
	nrServers := server servers size.
	
	[site := server startOn: 4924.
	self assert: site isServing.
	self assert: server servers size = (nrServers + 1).
	server stopOn: 4924.
	self assert: site isServing not.
	self assert: server servers size = nrServers] 
		ensure: 
		    [site stop.
		    server removeSite: site]
    ]

    testStartingOnTwoPorts [
	"and all ip interfaces, any host"

	<category: 'testing'>
	| server nrServers site1 site2 |
	server := SwazooServer singleton.
	nrServers := server servers size.
	
	[site1 := server startOn: 4924.
	site2 := server startOn: 4925.
	self assert: site1 isServing.
	self assert: site2 isServing.
	self assert: server servers size = (nrServers + 2).
	server stopOn: 4924.
	server stopOn: 4925.
	self assert: site1 isServing not.
	self assert: site2 isServing not.
	self assert: server servers size = nrServers] 
		ensure: 
		    [site1 stop.
		    site2 stop.
		    server
			removeSite: site1;
			removeSite: site2]
    ]

    testStartingSite [
	<category: 'testing'>
	| site server nrServers |
	self removeTestSiteIfAny.
	server := SwazooServer singleton.
	nrServers := server servers size.
	site := (SwazooSite new)
		    name: self testSiteName;
		    host: 'test.org'
			ip: 'localhost'
			port: 8765.
	
	[server addSite: site.
	self assert: site isServing not.
	SwazooServer startSite: self testSiteName.
	self assert: server servers size = (nrServers + 1).
	self assert: site isServing.
	SwazooServer stopSite: self testSiteName.
	self assert: site isServing not.
	self assert: server servers size = nrServers] 
		ensure: 
		    [site stop.
		    server removeSite: site]
    ]
]



TestCase subclass: SwazooSocketTest [
    | input output |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    setUp [
	<category: 'running'>
	| pair |
	pair := SwazooSocket connectedPair.
	input := pair first.
	output := pair last
    ]

    tearDown [
	<category: 'running'>
	input close.
	output close
    ]

    testConnectedPair [
	<category: 'testing'>
	(Array with: input with: output) 
	    do: [:each | self assert: (each isKindOf: SwazooSocket)]
    ]

    testNetworkConnection [
	<category: 'testing'>
	| server sem |
	input close.
	output close.
	sem := Semaphore new.
	
	[server := SwazooSocket serverOnIP: '127.0.0.1' port: 65423.
	server listenFor: 50.
	
	[input := server accept.
	sem signal] fork.
	output := SwazooSocket connectTo: 'localhost' port: 65423.
	sem wait.
	self testReadWrite] 
		ensure: [server close]
    ]

    testPartialRead [
	<category: 'testing'>
	| bytes |
	bytes := ByteArray withAll: #(5 4 3).
	self assert: (input write: bytes) = 3.
	self assert: (output read: 5) = bytes
    ]

    testReadTimeout [
	"on Squeak doesn't come back, and also we don't need it for now !!"

	"input write: (ByteArray withAll: #(1 2 3)).
	 self assert: (output read: 3 timeout: 40) = (ByteArray withAll: #(1 2 3)).
	 self assert: (output read: 3 timeout: 40) = ByteArray new"

	<category: 'testing'>
	
    ]

    testReadWrite [
	<category: 'testing'>
	| bytes |
	bytes := ByteArray withAll: #(1 2 3 4 5).
	self assert: (input write: bytes) = 5.
	self assert: (output read: 5) = bytes.
	bytes := ByteArray with: 4.
	self assert: (input write: bytes) = 1.
	self assert: (output read: 1) = bytes
    ]
]



TestCase subclass: SwazooStreamTest [
    | input output |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    crlfOn: aSwazooStream [
	<category: 'running'>
	aSwazooStream
	    nextPut: Character cr;
	    nextPut: Character lf
    ]

    setUp [
	<category: 'running'>
	| pair |
	pair := SwazooStream connectedPair.
	input := pair first.
	output := pair last
    ]

    tearDown [
	<category: 'running'>
	input close.
	output close
    ]

    testConnectedPair [
	<category: 'testing'>
	(Array with: input with: output) 
	    do: [:each | self assert: (each isKindOf: SwazooStream)]
    ]

    testErrorOnInputClose [
	<category: 'testing'>
	self should: 
		[input close.
		output next]
	    raise: Error
    ]

    testLinesWithDoubleCRLF [
	<category: 'testing-lines'>
	| ws rs comparisonString |
	comparisonString := 'abcd'.
	ws := SwazooStream on: String new.
	ws nextPutAll: comparisonString.
	self crlfOn: ws.
	self crlfOn: ws.
	rs := SwazooStream on: ws writeBufferContents.
	self assert: rs nextLine = comparisonString.
	self assert: rs nextLine = ''
    ]

    testNextPut [
	<category: 'testing'>
	#($A $M $Y $b $r $z) do: 
		[:each | 
		self assert: (input nextPut: each) = each.
		input flush.
		self assert: output next = each]
    ]

    testNextPutAll [
	<category: 'testing'>
	#('123' 'abc' 'swazoo') do: 
		[:each | 
		self assert: (input nextPutAll: each) = each.
		input flush.
		self assert: (output next: each size) = each]
    ]

    testNextPutByte [
	<category: 'testing'>
	| bytes |
	bytes := ByteArray 
		    with: 6
		    with: 5
		    with: 0
		    with: 2.
	bytes do: 
		[:each | 
		self assert: (input nextPutByte: each) = each.
		input flush.
		self assert: output nextByte = each]
    ]

    testNextPutBytes [
	<category: 'testing'>
	| bytes1 bytes2 bytes3 |
	bytes1 := ByteArray withAll: #(1 2 3 4).
	bytes2 := ByteArray withAll: #(5 4 3 2 1).
	bytes3 := ByteArray withAll: #(1 1 2 3 5).
	(Array 
	    with: bytes1
	    with: bytes2
	    with: bytes3) do: 
		    [:each | 
		    self assert: (input nextPutBytes: each) = each.
		    input flush.
		    self assert: (output nextBytes: each size) = each]
    ]

    testPeek [
	<category: 'testing'>
	#($K $J $D $j $m $z) do: 
		[:each | 
		input nextPut: each.
		input flush.
		self assert: output peek = each.
		output next]
    ]

    testPeekByte [
	<category: 'testing'>
	| bytes |
	bytes := ByteArray withAll: #(5 2 8 4 11 231).
	bytes do: 
		[:each | 
		input nextPutByte: each.
		input flush.
		self assert: output peekByte = each.
		output nextByte]
    ]

    testSingleLineWithCR [
	<category: 'testing-lines'>
	| ws rs comparisonString errored |
	comparisonString := 'abcd' , (String with: Character cr) , 'efg'.
	ws := SwazooStream on: String new.
	ws nextPutAll: comparisonString.
	ws nextPut: Character cr.
	rs := SwazooStream on: ws writeBufferContents.
	errored := false.
	SpExceptionContext 
	    for: [rs nextLine]
	    on: SpError
	    do: [:ex | errored := true].
	self assert: errored
    ]

    testSingleLineWithCRLF [
	<category: 'testing-lines'>
	| ws rs comparisonString |
	comparisonString := 'abcd'.
	ws := SwazooStream on: String new.
	ws nextPutAll: comparisonString.
	self crlfOn: ws.
	rs := SwazooStream on: ws writeBufferContents.
	self assert: rs nextLine = comparisonString
    ]
]



TestCase subclass: SwazooURITest [
    | fooURI encodedURI barURI queryURI |
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    setUp [
	<category: 'running'>
	fooURI := SwazooURI fromString: 'www.foo.com/index.html'.
	encodedURI := SwazooURI fromString: 'www.foo.com/index%3F.html'.
	queryURI := SwazooURI fromString: 'www.foo.com/index.html?foo=1&bar=hi%26'.
	barURI := SwazooURI fromString: 'www.bar.com:8080/files/'
    ]

    testHostname [
	<category: 'running'>
	self assert: fooURI hostname = 'www.foo.com'.
	self assert: encodedURI hostname = 'www.foo.com'.
	self assert: queryURI hostname = 'www.foo.com'.
	self assert: barURI hostname = 'www.bar.com'
    ]

    testIdentifier [
	<category: 'running'>
	self assert: fooURI identifier = '/index.html'.
	self assert: encodedURI identifier = '/index%3F.html'.
	self assert: queryURI identifier = '/index.html'.
	self assert: barURI identifier = '/files/'
    ]

    testIdentifierPath [
	<category: 'running'>
	self assert: fooURI identifierPath 
		    = (OrderedCollection with: '/' with: 'index.html').
	self assert: encodedURI identifierPath 
		    = (OrderedCollection with: '/' with: 'index?.html').
	self assert: queryURI identifierPath 
		    = (OrderedCollection with: '/' with: 'index.html').
	self 
	    assert: barURI identifierPath = (OrderedCollection with: '/' with: 'files')
    ]

    testIsDirectory [
	<category: 'running'>
	self deny: fooURI isDirectory.
	self deny: encodedURI isDirectory.
	self deny: queryURI isDirectory.
	self assert: barURI isDirectory
    ]

    testPort [
	<category: 'running'>
	self assert: fooURI port = 80.
	self assert: encodedURI port = 80.
	self assert: queryURI port = 80.
	self assert: barURI port = 8080
    ]

    testQueries [
	<category: 'running'>
	self deny: (queryURI includesQuery: 'hi').
	self assert: (queryURI includesQuery: 'foo').
	self assert: (queryURI includesQuery: 'bar').
	self assert: (queryURI queryAt: 'foo') = '1'.
	self assert: (queryURI queryAt: 'bar') = 'hi&'
    ]

    testValue [
	<category: 'running'>
	self assert: fooURI value = 'http://www.foo.com/index.html'.
	self assert: encodedURI value = 'http://www.foo.com/index%3F.html'.
	self assert: queryURI value = 'http://www.foo.com/index.html?foo=1&bar=hi%26'.
	self assert: barURI value = 'http://www.bar.com:8080/files/'
    ]
]



TestCase subclass: URIParsingTest [
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    test05SimpleFullURI [
	<category: 'testing'>
	| uri |
	uri := SwazooURI fromString: 'http://abc.com:8080/smith/home.html'.
	self assert: uri protocol = 'http'.
	self assert: uri hostname = 'abc.com'.
	self assert: uri port = 8080.
	self assert: uri identifier = '/smith/home.html'.
	self assert: uri asString = 'http://abc.com:8080/smith/home.html'
    ]

    test10SimpleFullURIWithQuery [
	<category: 'testing'>
	| uri |
	uri := SwazooURI fromString: 'http://abc.com:8080/smith/home.html?a=1&b=2'.
	self assert: uri protocol = 'http'.
	self assert: uri hostname = 'abc.com'.
	self assert: uri port = 8080.
	self assert: uri identifier = '/smith/home.html'.
	self assert: uri asString = 'http://abc.com:8080/smith/home.html?a=1&b=2'
    ]

    test15SimpleFullURIWithPort80 [
	<category: 'testing'>
	| uri |
	uri := SwazooURI fromString: 'http://abc.com:80/smith/home.html?a=1&b=2'.
	self assert: uri protocol = 'http'.
	self assert: uri hostname = 'abc.com'.
	self assert: uri port = 80.
	self assert: uri identifier = '/smith/home.html'.
	self assert: uri asString = 'http://abc.com/smith/home.html?a=1&b=2'
    ]

    test20SimpleFullURIWithNoPort [
	<category: 'testing'>
	| uri |
	uri := SwazooURI fromString: 'http://abc.com/smith/home.html?a=1&b=2'.
	self assert: uri protocol = 'http'.
	self assert: uri hostname = 'abc.com'.
	self assert: uri port = 80.
	self assert: uri identifier = '/smith/home.html'.
	self assert: uri asString = 'http://abc.com/smith/home.html?a=1&b=2'
    ]
]



TestCase subclass: URIResolutionTest [
    
    <comment: nil>
    <category: 'Swazoo-Tests'>

    testCompositeAnswer [
	<category: 'testing'>
	| resource request response |
	resource := CompositeResource uriPattern: 'base'.
	resource addResource: (HelloWorldResource uriPattern: 'hi').
	request := HTTPGet request: 'base/hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self assert: request resourcePath size = 2.
	self assert: request resourcePath first = 'base'.
	self assert: request resourcePath last = 'hi'
    ]

    testCompositeItselfCannotAnswer [
	<category: 'testing'>
	| resource request response |
	resource := CompositeResource uriPattern: 'base'.
	request := HTTPGet request: 'base'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil
    ]

    testCompositeNoAnswer [
	<category: 'testing'>
	| resource request response |
	resource := CompositeResource uriPattern: 'base'.
	resource addResource: (HelloWorldResource uriPattern: 'hi').
	request := HTTPGet request: 'tail/hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil
    ]

    testLeafAnswer [
	<category: 'testing'>
	| resource request response |
	resource := HelloWorldResource uriPattern: 'hi'.
	request := HTTPGet request: 'hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = 'hi'
    ]

    testNoAnswerWhenDisabled [
	<category: 'testing'>
	| resource request response |
	resource := HelloWorldResource uriPattern: 'hi'.
	resource disable.
	request := HTTPGet request: 'hi'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil
    ]

    testResourcePath [
	<category: 'testing'>
	| request resolution |
	request := HTTPGet 
		    request: 'foo/bar/baz/quux'
		    from: 'localhost:1234'
		    at: '1.2.3.4'.
	resolution := URIResolution new initializeRequest: request.
	self assert: resolution resourcePath = #('foo') asOrderedCollection.
	resolution advance.
	self assert: resolution resourcePath = #('foo' 'bar') asOrderedCollection.
	resolution advance.
	self 
	    assert: resolution resourcePath = #('foo' 'bar' 'baz') asOrderedCollection.
	resolution advance.
	self assert: resolution resourcePath 
		    = #('foo' 'bar' 'baz' 'quux') asOrderedCollection
    ]

    testSiteAnswer [
	<category: 'testing'>
	| resource request response |
	resource := SwazooSite new 
		    port: 80.
	resource addResource: (HelloWorldResource uriPattern: '/').
	request := HTTPGet 
		    request: '/'
		    from: 'foo.com'
		    at: '1.2.3.4'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
	self assert: request resourcePath size = 1.
	self assert: request resourcePath first = '/'
    ]

    testSiteMatch [
	<category: 'testing'>
	| request site response |
	request := HTTPGet 
		    request: '/'
		    from: 'myhosthost:1234'
		    at: '1.2.3.4'.
	site := SwazooSite new 
		    host: 'myhosthost'
		    ip: '1.2.3.4'
		    port: 1234.
	site addResource: (HelloWorldResource uriPattern: '/').
	response := URIResolution resolveRequest: request startingAt: site.
	self assert: response code = 200.
    ]

    testSiteMismatch [
	<category: 'testing'>
	| request site response |
	request := HTTPGet 
		    request: '/'
		    from: 'localhost:1234'
		    at: '1.2.3.4'.
	site := SwazooSite new 
		    host: 'remotehost'
		    ip: '1.2.3.4'
		    port: 1234.
	site addResource: (HelloWorldResource uriPattern: '/').
	response := URIResolution resolveRequest: request startingAt: site.
	self assert: response isNil.
    ]

    testStringMatch [
	<category: 'testing'>
	| request response resource |
	request := HTTPGet request: 'foo'.
	resource := HelloWorldResource uriPattern: 'foo'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response code = 200.
    ]

    testStringMismatch [
	<category: 'testing'>
	| request response resource |
	request := HTTPGet request: 'foo'.
	resource := HelloWorldResource uriPattern: 'Foo'.
	response := URIResolution resolveRequest: request startingAt: resource.
	self assert: response isNil.
    ]

    testTailPath [
	<category: 'testing'>
	| request resolution |
	request := HTTPGet 
		    request: 'foo/bar/baz/quux'
		    from: 'localhost:1234'
		    at: '1.2.3.4'.
	resolution := URIResolution new initializeRequest: request.
	self 
	    assert: resolution tailPath = #('bar' 'baz' 'quux') asOrderedCollection.
	resolution advance.
	self assert: resolution tailPath = #('baz' 'quux') asOrderedCollection.
	resolution advance.
	self assert: resolution tailPath = #('quux') asOrderedCollection.
	resolution advance.
	self assert: resolution tailPath isEmpty
    ]
]



PK
     �Mh@�/�a  a            ��    Core.stUT eqXOux �  �  PK
     �Mh@�˪A�  �            ��Za  HTTP.stUT eqXOux �  �  PK    �Mh@�OtD�  �           ���  PORTINGUT eqXOux �  �  PK
     �Mh@/���  �  
          ��~# Headers.stUT eqXOux �  �  PK
     \h@.�>D              ���� package.xmlUT ՊXOux �  �  PK
     �Mh@A~�(  (            ��� Resources.stUT eqXOux �  �  PK
     �Mh@�x]�6�  6�            ��Y  Messages.stUT eqXOux �  �  PK
     �Mh@��t�^!  ^!            ���� Exceptions.stUT eqXOux �  �  PK
     �Mh@:P�a6!  6!            ��y Protocol.stUT eqXOux �  �  PK
     �Mh@��3C�  �            ���" Extensions.stUT eqXOux �  �  PK
     �Mh@;�3%�  �            ��!+ SCGI.stUT eqXOux �  �  PK
     �Mh@s��/ �/           ��CB Tests.stUT eqXOux �  �  PK      �  �r   