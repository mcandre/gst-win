PK
     �Mh@M�D��K �K   magritte-model.stUT	 dqXOÉXOux �  �  String extend [

    matches: aString [
	<category: '*magritte-model-testing'>
	aString isEmpty ifTrue: [^true].
	^(aString includesAnyOf: '*#') 
	    ifTrue: [aString match: self]
	    ifFalse: [self includesSubstring: aString caseSensitive: false]
    ]

]



Error subclass: MAError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I represent a generic Magritte error.'>

    displayString [
	<category: 'printing'>
	^self printString
    ]
]



MAError subclass: MAPropertyError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: nil>
]



MAError subclass: MAReadError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that gets raised when there is problem reading serialized data.'>
]



MAError subclass: MAValidationError [
    | resumable |
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am a generic validation error. I reference the description that caused the validation error.'>

    MAValidationError class >> description: aDescription signal: aString [
	<category: 'instance-creation'>
	^(self new)
	    setDescription: aDescription;
	    signal: aString;
	    yourself
    ]

    beResumable [
	<category: 'accessing'>
	resumable := true
    ]

    isResumable [
	<category: 'testing'>
	^resumable
    ]

    printOn: aStream [
	<category: 'printing'>
	(self tag isDescription and: [self tag label notNil]) 
	    ifTrue: 
		[aStream
		    nextPutAll: self tag label;
		    nextPutAll: ': '].
	aStream nextPutAll: self messageText
    ]

    setDescription: aDescription [
	<category: 'initialization'>
	self tag: aDescription.
	resumable := false
    ]
]



MAValidationError subclass: MAConditionError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever a user-defined condition is failing.'>
]



MAValidationError subclass: MAConflictError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever there is an edit conflict.'>
]



MAValidationError subclass: MAKindError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever a description is applied to the wrong type of data.'>
]



MAValidationError subclass: MAMultipleErrors [
    | collection |
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever there are multiple validation rules failing.'>

    MAMultipleErrors class >> description: aDescription errors: aCollection signal: aString [
	<category: 'instance-creation'>
	^(self new)
	    setDescription: aDescription;
	    setCollection: aCollection;
	    signal: aString;
	    yourself
    ]

    collection [
	<category: 'accessing'>
	^collection
    ]

    printOn: aStream [
	<category: 'printing'>
	self collection do: [:each | aStream print: each]
	    separatedBy: [aStream nextPut: Character nl]
    ]

    setCollection: aCollection [
	<category: 'initialization'>
	collection := aCollection
    ]
]



MAValidationError subclass: MARangeError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever a described value is out of bounds.'>
]



MAValidationError subclass: MARequiredError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that is raised whenever a required value is not supplied.'>
]



MAError subclass: MAWriteError [
    
    <category: 'Magritte-Model-Exception'>
    <comment: 'I am an error that gets raised when there is problem writing serialized data.'>
]



nil subclass: MAProxyObject [
    | realSubject |
    
    <comment: 'I represent an abstract proxy object, to be refined by my subclasses.'>
    <category: 'Magritte-Model-Utility'>

    MAProxyObject class >> on: anObject [
	<category: 'instance creation'>
	^self basicNew realSubject: anObject
    ]

    copy [
	"It doesn't make sense to copy proxies in most cases, the real-subject needs to be looked up and will probably return a new instance on every call anyway."

	<category: 'copying'>
	^self
    ]

    doesNotUnderstand: aMessage [
	<category: 'private'>
	^self realSubject perform: aMessage selector
	    withArguments: aMessage arguments
    ]

    isMorph [
	"Answer ==false==, since I am no morph. Squeak is calling this method after image-startup and might lock if I do not answer to this message."

	<category: 'private'>
	^false
    ]

    isNil [
	"This method is required to properly return ==true== if the ==realSubject== is ==nil==."

	<category: 'testing'>
	^self realSubject isNil
    ]

    printOn: aStream [
	"Print the receiver on ==aStream== but within square-brackets to show that it is a proxied instance."

	<category: 'printing'>
	aStream
	    nextPut: $[;
	    print: self realSubject;
	    nextPut: $]
    ]

    printString [
	<category: 'printing'>
	^String streamContents: [:stream | self printOn: stream]
    ]

    realSubject [
	<category: 'accessing'>
	^realSubject
    ]

    realSubject: anObject [
	<category: 'accessing'>
	realSubject := anObject
    ]
]



MAProxyObject subclass: MADynamicObject [
    
    <comment: 'A dynamic object can be used for almost any property within Magritte that is not static but calculated dynamically. This is a shortcut to avoid having to build context sensitive descriptions manually over and over again, however there are a few drawbacks: 

- Some messages sent to this proxy, for example ==#class== and ==#value==, might not get resolved properly.
- Raising an unhandled exception will not always open a debugger on your proxy, because tools are unable to properly work with the invalid object and might even crash your image.'>
    <category: 'Magritte-Model-Utility'>

    realSubject [
	<category: 'accessing'>
	^super realSubject on: SystemExceptions.UnhandledException do: [:err | nil]
    ]
]



ArrayedCollection extend [

    copyWithAll: aCollection [
	<category: '*magritte-model'>
	^(self species new: self size + aCollection size)
	    replaceFrom: 1
		to: self size
		with: self
		startingAt: 1;
	    replaceFrom: self size + 1
		to: self size + aCollection size
		with: aCollection
		startingAt: 1;
	    yourself
    ]

]



Class extend [

    descriptionContainer [
	"Return the default description container."

	<category: '*magritte-model-configuration'>
	^(Magritte.MAPriorityContainer new)
	    label: self label;
	    yourself
    ]

    label [
	"Answer a human-readable name of the receiving class. This implementation tries to be smart and return a nice label, unfortunately for a lot of classes this doesn't work well so subclasses might want to override this method and return soemthing more meaningfull to end-users."

	<category: '*magritte-model-accessing'>
	| start input |
	start := self name findFirst: [:each | each isLowercase].
	input := (self name copyFrom: (1 max: start - 1) to: self name size) 
		    readStream.
	^String streamContents: 
		[:stream | 
		[input atEnd] whileFalse: 
			[stream nextPut: input next.
			(input atEnd or: [input peek isLowercase]) 
			    ifFalse: [stream nextPut: Character space]]]
    ]

]



Collection extend [

    asMultilineString [
	<category: '*magritte-model'>
	^String streamContents: 
		[:stream | 
		self do: [:each | stream nextPutAll: each]
		    separatedBy: [stream nextPut: Character nl]]
    ]

    copyWithAll: aCollection [
	<category: '*magritte-model'>
	^(self copy)
	    addAll: aCollection;
	    yourself
    ]

    copyWithoutFirst: anObject [
	<category: '*magritte-model'>
	| done |
	done := false.
	^self 
	    reject: [:each | (each = anObject and: [done not]) and: [done := true]]
    ]

]



BlockClosure extend [

    asDynamicObject [
	"Answer an object that will automatically evaluate the receiver when it receives a message. It will eventually pass the message to the resulting object. Use with caution, for details see *MADynamicObject*."

	<category: '*magritte-model'>
	^Magritte.MADynamicObject on: self
    ]

]



SequenceableCollection extend [

    asAccessor [
	<category: '*magritte-model'>
	^Magritte.MAChainAccessor accessors: self
    ]

    moveDown: anObject [
	<category: '*magritte-model'>
	| first second |
	first := self identityIndexOf: anObject ifAbsent: [^0].
	second := first < self size ifTrue: [first + 1] ifFalse: [^first].
	self swap: first with: second.
	^second
    ]

    moveUp: anObject [
	<category: '*magritte-model'>
	| first second |
	first := self identityIndexOf: anObject ifAbsent: [^0].
	second := first > 1 ifTrue: [first - 1] ifFalse: [^first].
	self swap: first with: second.
	^second
    ]

    reduce: aBlock [
       <category: '*magritte-model'>
       | result |
       self isEmpty ifTrue: [^nil].
       result := self first.
       2 to: self size
           do: [:index | result := aBlock value: result value: (self at: index)].
       ^result
    ]

]



Symbol extend [

    asAccessor [
	<category: '*magritte-model-converting'>
	^Magritte.MASelectorAccessor selector: self
    ]

    isDescriptionDefinition [
	"Answer wheter the receiver is a method selector following the naming conventions of a description definition."

	<category: '*magritte-model-testing'>
	^self isDescriptionSelector and: [self isUnary]
    ]

    isDescriptionExtension: aSelector [
	"Answer wheter the receiver is a method selector following the naming conventions of a description extension to aSelector."

	<category: '*magritte-model-testing'>
	^self isDescriptionSelector 
	    and: [self numArgs = 1 and: [self startsWith: aSelector]]
    ]

    isDescriptionSelector [
	"Answer wheter the receiver is a method selector following the naming conventions of a  description selector."

	<category: '*magritte-model-testing'>
	^self ~= #description and: [self startsWith: #description]
    ]

]



Object subclass: MAAdaptiveModel [
    | description values |
    
    <category: 'Magritte-Model-Models'>
    <comment: 'I am an adaptive model referencing a dynamic description of myself and a dictionary mapping those descriptions to actual values.'>

    MAAdaptiveModel class >> description: aDescription [
	<category: 'instance creation'>
	^(self new)
	    description: aDescription;
	    yourself
    ]

    MAAdaptiveModel class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    defaultDescription [
	<category: 'accessing-configuration'>
	^MAContainer new
    ]

    defaultDictionary [
	<category: 'accessing-configuration'>
	^Dictionary new
    ]

    description [
	"Answer the description of the receiver."

	<category: 'accessing'>
	^description
    ]

    description: aDescription [
	<category: 'accessing'>
	description := aDescription
    ]

    initialize [
	<category: 'initialization'>
	self description: self defaultDescription.
	self values: self defaultDictionary
    ]

    readUsing: aDescription [
	"Answer the actual value of ==aDescription== within the receiver, ==nil== if not present."

	<category: 'model'>
	^self values at: aDescription ifAbsent: [nil]
    ]

    values [
	"Answer a dictionary mapping description to actual values."

	<category: 'accessing'>
	^values
    ]

    values: aDictionary [
	<category: 'accessing'>
	values := aDictionary
    ]

    write: anObject using: aDescription [
	"Set ==anObject== to be that actual value of the receiver for ==aDescription==."

	<category: 'model'>
	self values at: aDescription put: anObject
    ]
]



Object subclass: MADescriptionBuilder [
    | cache |
    
    <category: 'Magritte-Model-Utility'>
    <comment: nil>

    Default := nil.

    MADescriptionBuilder class >> default [
	<category: 'accessing'>
	^Default
    ]

    MADescriptionBuilder class >> default: aBuilder [
	<category: 'accessing'>
	Default := aBuilder
    ]

    MADescriptionBuilder class >> for: anObject [
	<category: 'building'>
	^self default for: anObject
    ]

    MADescriptionBuilder class >> initialize [
	<category: 'initialization'>
	self default: MANamedBuilder new
    ]

    MADescriptionBuilder class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    build: anObject [
	<category: 'private'>
	self subclassResponsibility
    ]

    finalize [
	<category: 'initialization'>
	super finalize.
	self flush
    ]

    flush [
	<category: 'actions'>
	cache := IdentityDictionary new
    ]

    for: anObject [
	<category: 'accessing'>
	^cache at: anObject ifAbsentPut: [self build: anObject]
    ]

    initialize [
	<category: 'initialization'>
	self flush
    ]
]



MADescriptionBuilder subclass: MANamedBuilder [
    
    <category: 'Magritte-Model-Utility'>
    <comment: 'I dynamically build container descriptions from class-side methods using a simple naming convention for the selector names:

# The method ==#defaultContainer== is called to retrieve the container instance.
# All the unary methods starting with the selector ==#description== are called and should return a valid description to be added to the container.
# All the keyword messages with one argument having a prefix of a method selected in step 2 will be called with the original description to further refine its definition.'>

    build: anObject [
	<category: 'private'>
	| selectors container description |
	selectors := anObject class allSelectors 
		    select: [:each | each isDescriptionSelector].
	container := self 
		    build: anObject
		    for: self containerSelector
		    in: selectors.
	^(selectors select: [:each | each isDescriptionDefinition]) 
	    inject: (cache at: anObject put: container)
	    into: 
		[:result :each | 
		self containerSelector = each 
		    ifFalse: 
			[description := self 
				    build: anObject
				    for: each
				    in: selectors.
			description isDescription ifTrue: [result add: description]].
		result]
    ]

    build: anObject for: aSelector in: aCollection [
	<category: 'private'>
	^(aCollection select: [:each | each isDescriptionExtension: aSelector]) 
	    inject: (anObject perform: aSelector)
	    into: [:result :each | anObject perform: each with: result]
    ]

    containerSelector [
	<category: 'configuration'>
	^#descriptionContainer
    ]
]



Object subclass: MAFileModel [
    | filename mimetype filesize |
    
    <category: 'Magritte-Model-Models'>
    <comment: 'I represent a file with filename, mimetype and contents within the Magritte framework.

There are different file-models that you can use with Magritte. The idea is that you set the ==#kind:== of an MAFileDescription to one of the subclasses of ==*MAFileModel*==.'>

    MimeTypes := nil.

    MAFileModel class >> defaultMimeType [
	<category: 'accessing-defaults'>
	^'application/octet-stream'
    ]

    MAFileModel class >> defaultMimeTypes [
	<category: 'accessing-defaults'>
	^#('ai' 'application/postscript' 'aif' 'audio/x-aiff' 'aifc' 'audio/x-aiff' 'aiff' 'audio/x-aiff' 'asc' 'text/plain' 'au' 'audio/basic' 'avi' 'video/x-msvideo' 'bcpio' 'application/x-bcpio' 'bin' 'application/octet-stream' 'c' 'text/plain' 'cc' 'text/plain' 'ccad' 'application/clariscad' 'cdf' 'application/x-netcdf' 'class' 'application/octet-stream' 'cpio' 'application/x-cpio' 'cpt' 'application/mac-compactpro' 'csh' 'application/x-csh' 'css' 'text/css' 'dcr' 'application/x-director' 'dir' 'application/x-director' 'dms' 'application/octet-stream' 'doc' 'application/msword' 'drw' 'application/drafting' 'dvi' 'application/x-dvi' 'dwg' 'application/acad' 'dxf' 'application/dxf' 'dxr' 'application/x-director' 'eps' 'application/postscript' 'etx' 'text/x-setext' 'exe' 'application/octet-stream' 'ez' 'application/andrew-inset' 'f' 'text/plain' 'f90' 'text/plain' 'fli' 'video/x-fli' 'gif' 'image/gif' 'gtar' 'application/x-gtar' 'gz' 'application/x-gzip' 'h' 'text/plain' 'hdf' 'application/x-hdf' 'hh' 'text/plain' 'hqx' 'application/mac-binhex40' 'htm' 'text/html' 'html' 'text/html' 'ice' 'x-conference/x-cooltalk' 'ief' 'image/ief' 'iges' 'model/iges' 'igs' 'model/iges' 'ips' 'application/x-ipscript' 'ipx' 'application/x-ipix' 'jpe' 'image/jpeg' 'jpeg' 'image/jpeg' 'jpg' 'image/jpeg' 'js' 'application/x-javascript' 'kar' 'audio/midi' 'latex' 'application/x-latex' 'lha' 'application/octet-stream' 'lsp' 'application/x-lisp' 'lzh' 'application/octet-stream' 'm' 'text/plain' 'man' 'application/x-troff-man' 'me' 'application/x-troff-me' 'mesh' 'model/mesh' 'mid' 'audio/midi' 'midi' 'audio/midi' 'mif' 'application/vnd.mif' 'mime' 'www/mime' 'mov' 'video/quicktime' 'movie' 'video/x-sgi-movie' 'mp2' 'audio/mpeg' 'mp3' 'audio/mpeg' 'mpe' 'video/mpeg' 'mpeg' 'video/mpeg' 'mpg' 'video/mpeg' 'mpga' 'audio/mpeg' 'ms' 'application/x-troff-ms' 'msh' 'model/mesh' 'nc' 'application/x-netcdf' 'oda' 'application/oda' 'pbm' 'image/x-portable-bitmap' 'pdb' 'chemical/x-pdb' 'pdf' 'application/pdf' 'pgm' 'image/x-portable-graymap' 'pgn' 'application/x-chess-pgn' 'png' 'image/png' 'pnm' 'image/x-portable-anymap' 'pot' 'application/mspowerpoint' 'ppm' 'image/x-portable-pixmap' 'pps' 'application/mspowerpoint' 'ppt' 'application/mspowerpoint' 'ppz' 'application/mspowerpoint' 'pre' 'application/x-freelance' 'prt' 'application/pro_eng' 'ps' 'application/postscript' 'qt' 'video/quicktime' 'ra' 'audio/x-realaudio' 'ram' 'audio/x-pn-realaudio' 'ras' 'image/cmu-raster' 'rgb' 'image/x-rgb' 'rm' 'audio/x-pn-realaudio' 'roff' 'application/x-troff' 'rpm' 'audio/x-pn-realaudio-plugin' 'rtf' 'text/rtf' 'rtx' 'text/richtext' 'scm' 'application/x-lotusscreencam' 'set' 'application/set' 'sgm' 'text/sgml' 'sgml' 'text/sgml' 'sh' 'application/x-sh' 'shar' 'application/x-shar' 'silo' 'model/mesh' 'sit' 'application/x-stuffit' 'skd' 'application/x-koan' 'skm' 'application/x-koan' 'skp' 'application/x-koan' 'skt' 'application/x-koan' 'smi' 'application/smil' 'smil' 'application/smil' 'snd' 'audio/basic' 'sol' 'application/solids' 'spl' 'application/x-futuresplash' 'src' 'application/x-wais-source' 'step' 'application/STEP' 'stl' 'application/SLA' 'stp' 'application/STEP' 'sv4cpio' 'application/x-sv4cpio' 'sv4crc' 'application/x-sv4crc' 'swf' 'application/x-shockwave-flash' 't' 'application/x-troff' 'tar' 'application/x-tar' 'tcl' 'application/x-tcl' 'tex' 'application/x-tex' 'texi' 'application/x-texinfo' 'texinfo' 'application/x-texinfo' 'tif' 'image/tiff' 'tiff' 'image/tiff' 'tr' 'application/x-troff' 'tsi' 'audio/TSP-audio' 'tsp' 'application/dsptype' 'tsv' 'text/tab-separated-values' 'txt' 'text/plain' 'unv' 'application/i-deas' 'ustar' 'application/x-ustar' 'vcd' 'application/x-cdlink' 'vda' 'application/vda' 'viv' 'video/vnd.vivo' 'vivo' 'video/vnd.vivo' 'vrml' 'model/vrml' 'wav' 'audio/x-wav' 'wrl' 'model/vrml' 'xbm' 'image/x-xbitmap' 'xlc' 'application/vnd.ms-excel' 'xll' 'application/vnd.ms-excel' 'xlm' 'application/vnd.ms-excel' 'xls' 'application/vnd.ms-excel' 'xlw' 'application/vnd.ms-excel' 'xml' 'text/xml' 'xpm' 'image/x-xpixmap' 'xwd' 'image/x-xwindowdump' 'xyz' 'chemical/x-pdb' 'zip' 'application/zip')
    ]

    MAFileModel class >> initialize [
	<category: 'initialization'>
	MimeTypes := Dictionary new.
	1 to: self defaultMimeTypes size
	    by: 2
	    do: 
		[:index | 
		MimeTypes at: (self defaultMimeTypes at: index)
		    put: (self defaultMimeTypes at: index + 1)]
    ]

    MAFileModel class >> mimetypeFor: aString [
	<category: 'accessing'>
	^self mimetypes at: aString ifAbsent: [self defaultMimeType]
    ]

    MAFileModel class >> mimetypes [
	<category: 'accessing'>
	^MimeTypes
    ]

    MAFileModel class >> new [
	<category: 'instance-creation'>
	^self basicNew initialize
    ]

    = anObject [
	<category: 'comparing'>
	^self species = anObject species and: 
		[self filename = anObject filename and: [self mimetype = anObject mimetype]]
    ]

    contents [
	"Answer the contents of the file. This method is supposed to be overridden by concrete subclasses."

	<category: 'accessing'>
	self subclassResponsibility
    ]

    contents: aByteArray [
	"Set the contents of the receiver. This method is supposed to be overridden by concrete subclasses."

	<category: 'accessing'>
	filesize := aByteArray size
    ]

    extension [
	"Answer the file-extension."

	<category: 'accessing-dynamic'>
	^self filename copyAfterLast: $.
    ]

    filename [
	"Answer the filename of the receiver."

	<category: 'accessing'>
	^filename
    ]

    filename: aString [
	<category: 'accessing'>
	filename := aString
    ]

    filesize [
	"Answer the size of the file."

	<category: 'accessing-dynamic'>
	^filesize
    ]

    finalize [
	"Cleanup after a file is removed, subclasses might require to specialize this method."

	<category: 'initialization'>
	self initialize
    ]

    hash [
	<category: 'comparing'>
	^self filename hash bitXor: self mimetype hash
    ]

    initialize [
	<category: 'initialization'>
	filesize := 0.
	filename := 'unknown'.
	mimetype := self class defaultMimeType
    ]

    isApplication [
	"Return ==true== if the mimetype of the receiver is application-data. This message will match types like: application/postscript, application/zip, application/pdf, etc."

	<category: 'testing-types'>
	^self maintype = 'application'
    ]

    isAudio [
	"Return ==true== if the mimetype of the receiver is audio-data. This message will match types like: audio/basic, audio/tone, audio/mpeg, etc."

	<category: 'testing-types'>
	^self maintype = 'audio'
    ]

    isEmpty [
	<category: 'testing'>
	^self filesize = 0
    ]

    isImage [
	"Return ==true== if the mimetype of the receiver is image-data. This message will match types like: image/jpeg, image/gif, image/png, image/tiff, etc."

	<category: 'testing-types'>
	^self maintype = 'image'
    ]

    isText [
	"Return ==true== if the mimetype of the receiver is text-data. This message will match types like: text/plain, text/html, text/sgml, text/css, text/xml, text/richtext, etc."

	<category: 'testing-types'>
	^self maintype = 'text'
    ]

    isVideo [
	"Return ==true== if the mimetype of the receiver is video-data. This message will match types like: video/mpeg, video/quicktime, etc."

	<category: 'testing-types'>
	^self maintype = 'video'
    ]

    maintype [
	"Answer the first part of the mime-type."

	<category: 'accessing-dynamic'>
	^self mimetype copyUpTo: $/
    ]

    mimetype [
	"Answer the mimetype of the receiver."

	<category: 'accessing'>
	^mimetype
    ]

    mimetype: aString [
	<category: 'accessing'>
	mimetype := aString
    ]

    subtype [
	"Answer the second part of the mime-type."

	<category: 'accessing-dynamic'>
	^self mimetype copyAfter: $/
    ]
]



MAFileModel subclass: MAExternalFileModel [
    | location |
    
    <category: 'Magritte-Model-Models'>
    <comment: 'I manage the file-data I represent on the file-system. From the programmer this looks the same as if the file would be in memory (==*MAMemoryFileModel*==), as it is transparently loaded and written out as necessary.

- The ==#baseDirectory== is the place where Magritte puts its file-database. Keep this value to nil to make it default to a subdirectory next to the Squeak image.
- The ==#baseUrl== is a nice optimization to allow Apache (or any other Web Server) to directly serve the files. ==#baseUrl== is an absolute URL-prefix that is used to generate the path to the file. If you have specified one the file data does not go trough the image anymore, but instead is directly served trough the properly configured Web Server.

The files are currently stored using the following scheme:

=/files/9d/bsy8kyp45g0q7blphknk48zujap2wd/earthmap1k.jpg
=1     2   3                              4

#Is the #baseDirectory as specified in the settings.
#Are 256 directories named ''00'' to ''ff'' to avoid having thousands of files in the same directory. Unfortunately this leads to problems with the Squeak file primitives and some filesystems don''t handle that well. This part is generated at random.
#This is a secure id, similar to the Seaside session key. It is generated at random and provides a security system that even works trough Apache (you have to disable directory listings of course): if you don''t know the file-name you cannot access the file.
#This is the original file-name. Subclasses might want to store other cached versions of the same file there, for example resized images, etc.'>

    MAExternalFileModel class [
	| baseDirectory baseUrl |
	
    ]

    MAExternalFileModel class >> baseDirectory [
	<category: 'accessing'>
	^baseDirectory ifNil: [Directory working / 'files']
    ]

    MAExternalFileModel class >> baseDirectory: aStringOrDirectory [
	"Defines the base-directory where the files are stored. If this value is set to nil, it default to a subdirectory of of the current image-location."

	<category: 'accessing'>
	baseDirectory := aStringOrDirectory isString 
		    ifTrue: [aStringOrDirectory asFile]
		    ifFalse: [aStringOrDirectory]
    ]

    MAExternalFileModel class >> baseUrl [
	<category: 'accessing'>
	^baseUrl
    ]

    MAExternalFileModel class >> baseUrl: aString [
	"Defines the base-URL where the files are served from, when using an external web server. This setting is left to nil by default, causing the files to be served trough the image."

	<category: 'accessing'>
	baseUrl := aString isNil 
		    ifFalse: 
			[aString last = $/ ifFalse: [aString] ifTrue: [aString copyUpToLast: $/]]
    ]

    MAExternalFileModel class >> initialize [
	<category: 'initialization'>
	baseDirectory := baseUrl := nil
    ]

    baseDirectory [
	<category: 'configuration'>
	^self class baseDirectory
    ]

    baseUrl [
	<category: 'configuration'>
	^self class baseUrl
    ]

    contents [
	<category: 'accessing'>
	| stream |
	^(self directory exists and: [self directory includes: self filename]) 
	    ifFalse: [ByteArray new]
	    ifTrue: 
		[stream := self readStream.
		[stream contents asByteArray] ensure: [stream close]]
    ]

    contents: aByteArray [
	<category: 'accessing'>
	| stream |
	stream := self writeStream.
	[stream nextPutAll: aByteArray asByteArray] ensure: [stream close].
	super contents: aByteArray
    ]

    directory [
	<category: 'accessing-dynamic'>
	^self location inject: self baseDirectory
	    into: [:result :each | result / each]
    ]

    finalize [
	<category: 'initialization'>
	| directory |
	directory := self directory.
	directory exists ifTrue: [directory all remove].
	"[(directory := directory parent) entries isEmpty] 
	    whileTrue: [directory all remove]."
	super finalize.
	location := nil
    ]

    location [
	<category: 'accessing-dynamic'>
	^location 
	    ifNil: [location := self uniqueLocation: self locationDefinition]
    ]

    locationDefinition [
	<category: 'configuration'>
	^#(#(2 '63450af8d9c2e17b') #(30 'iaojv41bw67e0tud5m9rgplqfy8x3cs2kznh'))
    ]

    postCopy [
	<category: 'copying'>
	| previous |
	super postCopy.
	previous := self contents.
	location := nil.
	self contents: previous
    ]

    readStream [
	<category: 'accessing-dynamic'>
	^(self directory / self filename) readStream
    ]

    uniqueLocation: aLocationDefinition [
	"Finds an unique path to be used and create the necessary sub directories."

	<category: 'private'>
	| valid result directory definition |
	valid := false.
	result := Array new: aLocationDefinition size.
	[valid] whileFalse: 
		[directory := self baseDirectory createDirectories.
		result keysAndValuesDo: 
			[:index :value | 
			definition := aLocationDefinition at: index.
			result at: index
			    put: ((String new: definition first) 
				    collect: [:each | definition second atRandom]).
			directory := directory / (result at: index).
			directory exists 
			    ifFalse: 
				[directory createDirectories.
				valid := true]]].
	^result
    ]

    writeStream [
	<category: 'accessing-dynamic'>
	^(self directory / self filename) writeStream
    ]
]



MAFileModel subclass: MAMemoryFileModel [
    | contents |
    
    <category: 'Magritte-Model-Models'>
    <comment: 'I represent a file using a ByteArray in the object memory. I am not practicable for big files: use me for development and testing only.'>

    contents [
	<category: 'accessing'>
	^contents ifNil: [contents := ByteArray new]
    ]

    contents: aByteArray [
	<category: 'accessing'>
	super contents: aByteArray.
	contents := aByteArray asByteArray
    ]

    finalize [
	<category: 'initialization'>
	super finalize.
	contents := nil
    ]
]



Object subclass: MAObject [
    | properties |
    
    <category: 'Magritte-Model-Core'>
    <comment: 'I provide functionality available to all Magritte objects. I implement a dictionary of properties, so that extensions can easily store additional data.'>

    MAObject class >> initialize [
	<category: 'initialization'>
	MACompatibility openWorkspace: self license titled: 'Magritte License'
    ]

    MAObject class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    MAObject class >> license [
	"Return a string with the license of the package. This string shall not be removed or altered in any case."

	<category: 'accessing'>
	^'The MIT License

Copyright (c) 2003-' , Date today year asString 
	    , ' Lukas Renggli, renggli at gmail.com

Copyright (c) 2003-' 
		, Date today year asString 
		, ' Software Composition Group, University of Bern, Switzerland

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
    ]

    MAObject class >> new [
	"Create a new instance of the receiving class and checks if it is concrete."

	<category: 'instance-creation'>
	self isAbstract ifTrue: [self error: self name , ' is abstract.'].
	^self basicNew initialize
    ]

    MAObject class >> withAllConcreteClasses [
	<category: 'reflection'>
	^Array streamContents: 
		[:stream | 
		self withAllConcreteClassesDo: [:each | stream nextPut: each]]
    ]

    MAObject class >> withAllConcreteClassesDo: aBlock [
	<category: 'reflection'>
	self 
	    withAllSubclassesDo: [:each | each isAbstract ifFalse: [aBlock value: each]]
    ]

    = anObject [
	"Answer whether the receiver and the argument represent the same object. This default implementation checks if the species of the compared objects are the same, so that superclasses might call super before performing their own check. Also redefine the message ==#hash== when redefining this message."

	<category: 'comparing'>
	^self species = anObject species
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	
    ]

    errorPropertyNotFound: aSelector [
	<category: 'private'>
	MAPropertyError signal: 'Property ' , aSelector , ' not found.'
    ]

    hasProperty: aKey [
	"Test if the property ==aKey== is defined within the receiver."

	<category: 'testing'>
	^self properties includesKey: aKey
    ]

    hash [
	"Answer a SmallInteger whose value is related to the receiver's identity. Also redefine the message ==#= == when redefining this message."

	<category: 'comparing'>
	^self species hash
    ]

    initialize [
	<category: 'initialization'>
	
    ]

    postCopy [
	"This method is called whenever a shallow copy of the receiver is made. Redefine this method in subclasses to copy other fields as necessary. Never forget to call super, else class invariants might be violated."

	<category: 'copying'>
	super postCopy.
	properties := properties copy
    ]

    properties [
	"Answer the property dictionary of the receiver."

	<category: 'accessing'>
	^properties ifNil: [properties := Dictionary new]
    ]

    propertyAt: aKey [
	"Answer the value of the property ==aKey==, raises an error if the property doesn't exist."

	<category: 'accessing'>
	^self propertyAt: aKey ifAbsent: [self errorPropertyNotFound: aKey]
    ]

    propertyAt: aKey ifAbsent: aBlock [
	"Answer the value of the property ==aKey==, or the result of ==aBlock== if the property doesn't exist."

	<category: 'accessing'>
	^self properties at: aKey ifAbsent: aBlock
    ]

    propertyAt: aKey ifAbsentPut: aBlock [
	"Answer the value of the property ==aKey==, or if the property doesn't exist adds and answers the result of evaluating ==aBlock==."

	<category: 'accessing'>
	^self properties at: aKey ifAbsentPut: aBlock
    ]

    propertyAt: aKey ifPresent: aBlock [
	"Lookup the property ==aKey==, if it is present, answer the value of evaluating ==aBlock== block with the value. Otherwise, answer ==nil==."

	<category: 'accessing'>
	^self properties at: aKey ifPresent: aBlock
    ]

    propertyAt: aKey put: aValue [
	"Adds or replaces the property ==aKey== with ==aValue==."

	<category: 'accessing'>
	^self properties at: aKey put: aValue
    ]
]



MAObject subclass: MAAccessor [
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am the abstract superclass to all accessor strategies. Accessors are used to implement different ways of accessing (reading and writing) data from instances using a common protocol: data can be uniformly read and written using ==#readFrom:== respectively ==#write:to:==.'>

    asAccessor [
	<category: 'converting'>
	^self
    ]

    canRead: aModel [
	"Test if ==aModel== can be read."

	<category: 'testing'>
	^false
    ]

    canWrite: aModel [
	"Test if ==aModel== can be written."

	<category: 'testing'>
	^false
    ]

    printOn: aStream [
	<category: 'printing'>
	self storeOn: aStream
    ]

    read: aModel [
	"Read from ==aModel== using the access-strategy of the receiver."

	<category: 'model'>
	^nil
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    store: self class;
	    nextPutAll: ' new'
    ]

    write: anObject to: aModel [
	"Write ==anObject== to ==aModel== using the access-strategy of the receiver."

	<category: 'model'>
	
    ]
]



MAAccessor subclass: MADelegatorAccessor [
    | next |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'My access strategy is to delegate to the next accessor. I am not that useful all by myself, but subclasses might override certain methods to intercept access.'>

    MADelegatorAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MADelegatorAccessor class >> on: anAccessor [
	<category: 'instance-creation'>
	^self new next: anAccessor
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self next = anObject next]
    ]

    canRead: aModel [
	<category: 'testing'>
	^self next canRead: aModel
    ]

    canWrite: aModel [
	<category: 'testing'>
	^self next canWrite: aModel
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self next hash
    ]

    next [
	<category: 'accessing'>
	^next
    ]

    next: anAccessor [
	<category: 'accessing'>
	next := anAccessor asAccessor
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	next := next copy
    ]

    read: aModel [
	<category: 'model'>
	^self next read: aModel
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' on: ';
	    store: self next;
	    nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	self next write: anObject to: aModel
    ]
]



MADelegatorAccessor subclass: MAChainAccessor [
    | accessor |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am an access strategy used to chain two access strategies. To read and write a value the ==accessor== is performed on the given model and the result is passed into the ==next== accessor.'>

    MAChainAccessor class >> accessor: anAccessor next: aNextAccessor [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use #on:accessor: instead.'.
	^self on: anAccessor accessor: aNextAccessor
    ]

    MAChainAccessor class >> accessors: aSequenceableCollection [
	<category: 'instance-creation'>
	aSequenceableCollection isEmpty 
	    ifTrue: 
		[self error: 'Unable to create accessor sequence from empty collection.'].
	aSequenceableCollection size = 1 
	    ifTrue: [^aSequenceableCollection first asAccessor].
	^self on: aSequenceableCollection first asAccessor
	    accessor: (self accessors: aSequenceableCollection allButFirst)
    ]

    MAChainAccessor class >> on: anAccessor accessor: anotherAccessor [
	<category: 'instance-creation'>
	^(self on: anAccessor) accessor: anotherAccessor
    ]

    MAChainAccessor class >> selectors: aSequenceableCollection [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use #accessors: instead.'.
	^self accessors: aSequenceableCollection
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self accessor = anObject accessor]
    ]

    accessor [
	<category: 'accessing'>
	^accessor
    ]

    accessor: anAccessor [
	<category: 'accessing'>
	accessor := anAccessor
    ]

    canRead: aModel [
	<category: 'testing'>
	^(super canRead: aModel) 
	    and: [self accessor canRead: (self next read: aModel)]
    ]

    canWrite: aModel [
	<category: 'testing'>
	^(super canRead: aModel) 
	    and: [self accessor canWrite: (self next read: aModel)]
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self accessor hash
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	accessor := accessor copy
    ]

    read: aModel [
	<category: 'model'>
	^self accessor read: (super read: aModel)
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' on: ';
	    store: self next;
	    nextPutAll: ' accessor: ';
	    store: self accessor;
	    nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	self accessor write: anObject to: (super read: aModel)
    ]
]



MAAccessor subclass: MADictionaryAccessor [
    | key |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am an access strategy to be used on dictionaries. I use my ==key== to read from and write to indexed collections.'>

    MADictionaryAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MADictionaryAccessor class >> key: aSymbol [
	<category: 'instance-creation'>
	^(self new)
	    key: aSymbol;
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self key = anObject key]
    ]

    canRead: aModel [
	<category: 'testing'>
	^true
    ]

    canWrite: aModel [
	<category: 'testing'>
	^true
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self key hash
    ]

    key [
	<category: 'accessing'>
	^key
    ]

    key: aKey [
	<category: 'accessing'>
	key := aKey
    ]

    read: aModel [
	<category: 'model'>
	^aModel at: self key ifAbsent: [nil]
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' key: ';
	    store: self key;
	    nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	aModel at: self key put: anObject
    ]
]



MAAccessor subclass: MAIdentityAccessor [
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am a read-only access strategy and I answer the model itself when being read.'>

    MAIdentityAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    canRead: aModel [
	<category: 'testing'>
	^true
    ]

    read: aModel [
	<category: 'model'>
	^aModel
    ]

    write: anObject to: aModel [
	<category: 'model'>
	MAWriteError signal: 'Not supposed to write to ' , aModel asString , '.'
    ]
]



MAAccessor subclass: MANullAccessor [
    | uuid |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am a null access strategy and I should be neither read nor written. I am still comparable to other strategies by holding onto a unique-identifier.'>

    MANullAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MANullAccessor class >> new [
	<category: 'instance-creation'>
	^self uuid: MACompatibility uuid
    ]

    MANullAccessor class >> uuid: anUUID [
	<category: 'instance-creation'>
	^(self basicNew)
	    uuid: anUUID;
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self uuid = anObject uuid]
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self uuid hash
    ]

    read: aModel [
	<category: 'model'>
	MAReadError signal: 'This message is not appropriate for this object'
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' uuid: ';
	    store: self uuid;
	    nextPut: $)
    ]

    uuid [
	<category: 'accessing'>
	^uuid
    ]

    uuid: anObject [
	<category: 'accessing'>
	uuid := anObject
    ]

    write: anObject to: aModel [
	<category: 'model'>
	MAWriteError signal: 'This message is not appropriate for this object'
    ]
]



MAAccessor subclass: MAPluggableAccessor [
    | readBlock writeBlock |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am an access strategy defined by two block-closures. The read-block expects the model as its first argument and is used to retrieve a value. The write-block expects the model as its first and the value as its second argument and is used to write a value to the model.'>

    MAPluggableAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAPluggableAccessor class >> read: aReadBlock write: aWriteBlock [
	<category: 'instance creation'>
	^(self new)
	    readBlock: aReadBlock;
	    writeBlock: aWriteBlock;
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: 
		[self readBlock = anObject readBlock 
		    and: [self writeBlock = anObject writeBlock]]
    ]

    canRead: aModel [
	<category: 'testing'>
	^self readBlock notNil
    ]

    canWrite: aModel [
	<category: 'testing'>
	^self writeBlock notNil
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: (self readBlock hash bitXor: self writeBlock hash)
    ]

    read: aModel [
	<category: 'model'>
	^self readBlock value: aModel
    ]

    readBlock [
	<category: 'accessing'>
	^readBlock
    ]

    readBlock: aBlock [
	<category: 'accessing'>
	readBlock := aBlock
    ]

    storeBlock: aBlock on: aStream [
	<category: 'printing'>
	aStream nextPutAll: aBlock decompile asString allButFirst allButLast
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' read: '.
	self storeBlock: self readBlock on: aStream.
	aStream nextPutAll: ' write: '.
	self storeBlock: self writeBlock on: aStream.
	aStream nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	self writeBlock value: aModel value: anObject
    ]

    writeBlock [
	<category: 'accessing'>
	^writeBlock
    ]

    writeBlock: aBlock [
	<category: 'accessing'>
	writeBlock := aBlock
    ]
]



MAAccessor subclass: MASelectorAccessor [
    | readSelector writeSelector |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am the most common access strategy defined by a read- and a write-selector. I am mostly used together with standard getters and setters as usually defined by the accessing protocol. If there is only a read-selector specified, the write selector will be deduced automatically by adding a colon to the read-selector.'>

    MASelectorAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MASelectorAccessor class >> read: aSelector [
	<category: 'instance creation'>
	^self read: aSelector write: nil
    ]

    MASelectorAccessor class >> read: aReadSelector write: aWriteSelector [
	<category: 'instance creation'>
	^(self new)
	    readSelector: aReadSelector;
	    writeSelector: aWriteSelector;
	    yourself
    ]

    MASelectorAccessor class >> selector: aSelector [
	<category: 'instance creation'>
	^(self new)
	    selector: aSelector;
	    yourself
    ]

    MASelectorAccessor class >> write: aSelector [
	<category: 'instance creation'>
	^self read: nil write: aSelector
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: 
		[self readSelector = anObject readSelector 
		    and: [self writeSelector = anObject writeSelector]]
    ]

    canRead: aModel [
	<category: 'testing'>
	^self readSelector notNil and: [aModel respondsTo: self readSelector]
    ]

    canWrite: aModel [
	<category: 'testing'>
	^self writeSelector notNil and: [aModel respondsTo: self writeSelector]
    ]

    hash [
	<category: 'comparing'>
	^super hash 
	    bitXor: (self readSelector hash bitXor: self writeSelector hash)
    ]

    read: aModel [
	<category: 'model'>
	^aModel perform: self readSelector
    ]

    readSelector [
	<category: 'accessing'>
	^readSelector
    ]

    readSelector: aSelector [
	<category: 'accessing'>
	readSelector := aSelector
    ]

    selector [
	<category: 'accessing-dynamic'>
	^self readSelector
    ]

    selector: aSelector [
	<category: 'accessing-dynamic'>
	self readSelector: aSelector asSymbol.
	self writeSelector: (aSelector asString copyWith: $:) asSymbol
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' read: ';
	    store: self readSelector;
	    nextPutAll: ' write: ';
	    store: self writeSelector;
	    nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	aModel perform: self writeSelector with: anObject
    ]

    writeSelector [
	<category: 'accessing'>
	^writeSelector
    ]

    writeSelector: aSelector [
	<category: 'accessing'>
	writeSelector := aSelector
    ]
]



MASelectorAccessor subclass: MAAutoSelectorAccessor [
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am very similar to my super-class *MASelectorAccessor*, however I do create instance variables and accessor methods automatically if necessary. I am especially useful for prototyping. I never change existing accessor methods.'>

    categoryName [
	<category: 'accessing'>
	^#'accessing-generated'
    ]

    createReadAccessor: aClass [
	<category: 'private'>
	(aClass selectors includes: self readSelector) ifTrue: [^self].
	aClass 
	    compile: (String streamContents: 
			[:stream | 
			stream
			    nextPutAll: self readSelector, ' [';
			    cr.
			stream
			    tab;
			    nextPutAll: '^ ';
			    nextPutAll: self readSelector, ' ]'])
	    classified: self categoryName
    ]

    createVariable: aClass [
	<category: 'private'>
	(aClass allInstVarNames includes: self readSelector) ifTrue: [^self].
	aClass addInstVarName: self readSelector
    ]

    createWriteAccessor: aClass [
	<category: 'private'>
	(aClass selectors includes: self writeSelector) ifTrue: [^self].
	aClass 
	    compile: (String streamContents: 
			[:stream | 
			stream
			    nextPutAll: self writeSelector;
			    space;
			    nextPutAll: 'anObject [';
			    cr.
			stream
			    tab;
			    nextPutAll: self readSelector;
			    nextPutAll: ' := anObject ]'])
	    classified: self categoryName
    ]

    read: aModel [
	<category: 'model'>
	(self canRead: aModel) 
	    ifFalse: 
		[self createVariable: aModel class.
		self createReadAccessor: aModel class].
	^super read: aModel
    ]

    write: anObject to: aModel [
	<category: 'model'>
	(self canWrite: aModel) 
	    ifFalse: 
		[self createVariable: aModel class.
		self createWriteAccessor: aModel class].
	super write: anObject to: aModel
    ]
]



MAAccessor subclass: MAVariableAccessor [
    | name |
    
    <category: 'Magritte-Model-Accessor'>
    <comment: 'I am an access strategy that directly reads from and writes to instance variables. I strongly violate encapsulation and most of the time I should be replaced by an instance of *MASelectorAccessor*.'>

    MAVariableAccessor class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAVariableAccessor class >> name: aString [
	<category: 'instance creation'>
	^(self new)
	    name: aString asSymbol;
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self name = anObject name]
    ]

    canRead: aModel [
	<category: 'testing'>
	^aModel class allInstVarNames includes: self name
    ]

    canWrite: aModel [
	<category: 'testing'>
	^self canRead: aModel
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self name hash
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: aString [
	<category: 'accessing'>
	name := aString
    ]

    read: aModel [
	<category: 'model'>
	^aModel instVarNamed: self name
    ]

    storeOn: aStream [
	<category: 'printing'>
	aStream
	    nextPut: $(;
	    store: self class;
	    nextPutAll: ' name: ';
	    store: self name;
	    nextPut: $)
    ]

    write: anObject to: aModel [
	<category: 'model'>
	aModel instVarNamed: self name put: anObject
    ]
]



ValueHolder subclass: MADescriptionHolder [
    
    <category: 'Magritte-Examples'>
    <comment: nil>

    MADescriptionHolder class >> descriptionClasses [
	<category: 'accessing'>
	^(OrderedCollection new)
	    add: MAStringDescription;
	    add: MAMemoDescription;
	    add: MASymbolDescription;
	    add: MAPasswordDescription;
	    add: MABooleanDescription;
	    add: MASingleOptionDescription;
	    add: MAMultipleOptionDescription;
	    add: MAToOneRelationDescription;
	    add: MAToManyRelationDescription;
	    add: MANumberDescription;
	    add: MADurationDescription;
	    add: MADateDescription;
	    add: MATimeDescription;
	    add: MATimeStampDescription;
	    add: MATokenDescription;
	    add: MAFileDescription;
	    add: MAClassDescription;
	    add: MATableDescription;
	    yourself
    ]

    MADescriptionHolder class >> descriptionValue [
	<category: 'meta'>
	^(MASingleOptionDescription new)
	    options: self descriptionClasses;
	    reference: MAClassDescription new;
	    groupBy: #grouping;
	    selectorAccessor: 'contents';
	    label: 'Type';
	    priority: 20;
	    yourself
    ]

    MADescriptionHolder class >> groupChoice [
	<category: 'groups'>
	^(Set new)
	    add: MABooleanDescription;
	    add: MASingleOptionDescription;
	    add: MAMultipleOptionDescription;
	    add: MAToOneRelationDescription;
	    add: MAToManyRelationDescription;
	    yourself
    ]

    MADescriptionHolder class >> groupMagnitude [
	<category: 'groups'>
	^(Set new)
	    add: MANumberDescription;
	    add: MADurationDescription;
	    add: MADateDescription;
	    add: MATimeDescription;
	    add: MATimeStampDescription;
	    yourself
    ]

    MADescriptionHolder class >> groupMisc [
	<category: 'groups'>
	^(Set new)
	    add: MAFileDescription;
	    add: MAClassDescription;
	    add: MATableDescription;
	    yourself
    ]

    MADescriptionHolder class >> groupOf: aClass [
	<category: 'api'>
	(self groupText includes: aClass) ifTrue: [^'Text'].
	(self groupChoice includes: aClass) ifTrue: [^'Choice'].
	(self groupMagnitude includes: aClass) ifTrue: [^'Magnitude'].
	(self groupPick includes: aClass) ifTrue: [^'Pick'].
	(self groupMisc includes: aClass) ifTrue: [^'Miscellaneous'].
	^'Other'
    ]

    MADescriptionHolder class >> groupPick [
	<category: 'groups'>
	^(Set new)
	    add: MATokenDescription;
	    yourself
    ]

    MADescriptionHolder class >> groupText [
	<category: 'groups'>
	^(Set new)
	    add: MAStringDescription;
	    add: MAMemoDescription;
	    add: MASymbolDescription;
	    add: MAPasswordDescription;
	    yourself
    ]

    initialize [
	<category: 'initialize-release'>
	self contents: self class descriptionClasses first
    ]
]


MAObject subclass: MADescription [
    | accessor |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am the root of the description hierarchy in Magritte and I provide most of the basic properties available to all descriptions. If you would like to annotate your model with a description have a look at the different subclasses of myself.

!Example
If your model has an instance variable called ==title== that should be used to store the title of the object, you could add the following description to your class:

=Document class>>descriptionTitle
=	^ MAStringDescription new
=		autoAccessor: #title;
=		label: ''Title'';
=		priority: 20;
=		beRequired;
=		yourself.

The selector ==#title== is the name of the accessor method used by Magritte to retrieve the value from the model. In the above case Magritte creates the accessor method and the instance variable automatically, if necessary. The label is used to give the field a name and will be printed next to the input box if a visual GUI is created from this description.

The write-accessor is automatically deduced by adding a colon to the read-selector, in this example ==#title:==. You can specify your own accessor strategy using one of the subclasses of ==*MAAccessor*==. If you have multiple description within the same object, the ==#priority:# field is used to order them. Assign a low priority to have descriptions traversed first.'>

    MADescription class >> accessor: anAccessor [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self new accessor: anAccessor
    ]

    MADescription class >> accessor: anAccessor label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: anAccessor
	    label: aString
	    priority: self defaultPriority
    ]

    MADescription class >> accessor: anAccessor label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: anAccessor
	    label: aString
	    priority: aNumber
	    default: self defaultDefault
    ]

    MADescription class >> accessor: anAccessor label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^(self new)
	    accessor: anAccessor;
	    label: aString;
	    priority: aNumber;
	    default: anObject;
	    yourself
    ]

    MADescription class >> auto: aSelector [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAAutoSelectorAccessor selector: aSelector)
    ]

    MADescription class >> auto: aSelector label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAAutoSelectorAccessor selector: aSelector) label: aString
    ]

    MADescription class >> auto: aSelector label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAAutoSelectorAccessor selector: aSelector)
	    label: aString
	    priority: aNumber
    ]

    MADescription class >> auto: aSelector label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAAutoSelectorAccessor selector: aSelector)
	    label: aString
	    priority: aNumber
	    default: anObject
    ]

    MADescription class >> grouping [
	<category: '*magritte-seaside-examples'>
	^MADescriptionHolder groupOf: self
    ]

    MADescription class >> defaultAccessor [
	<category: 'accessing-defaults'>
	^MANullAccessor new
    ]

    MADescription class >> defaultComment [
	<category: 'accessing-defaults'>
	^nil
    ]

    MADescription class >> defaultConditions [
	<category: 'accessing-defaults'>
	^Array new
    ]

    MADescription class >> defaultDefault [
	<category: 'accessing-defaults'>
	^nil
    ]

    MADescription class >> defaultGroup [
	<category: 'accessing-defaults'>
	^nil
    ]

    MADescription class >> defaultLabel [
	<category: 'accessing-defaults'>
	^String new
    ]

    MADescription class >> defaultPersistent [
	<category: 'accessing-defaults'>
	^true
    ]

    MADescription class >> defaultPriority [
	<category: 'accessing-defaults'>
	^0
    ]

    MADescription class >> defaultReadonly [
	<category: 'accessing-defaults'>
	^false
    ]

    MADescription class >> defaultRequired [
	<category: 'accessing-defaults'>
	^false
    ]

    MADescription class >> defaultStringReader [
	<category: 'accessing-defaults'>
	^MAStringReader
    ]

    MADescription class >> defaultStringWriter [
	<category: 'accessing-defaults'>
	^MAStringWriter
    ]

    MADescription class >> defaultUndefined [
	<category: 'accessing-defaults'>
	^String new
    ]

    MADescription class >> defaultValidator [
	<category: 'accessing-defaults'>
	^MAValidatorVisitor
    ]

    MADescription class >> defaultVisible [
	<category: 'accessing-defaults'>
	^true
    ]

    MADescription class >> descriptionComment [
	<category: 'accessing-description'>
	^(MAMemoDescription new)
	    accessor: #comment;
	    label: 'Comment';
	    priority: 110;
	    default: self defaultComment;
	    yourself
    ]

    MADescription class >> descriptionDefault [
	<category: 'accessing-description'>
	^self isAbstract 
	    ifFalse: 
		[(self new)
		    accessor: #default;
		    label: 'Default';
		    priority: 130;
		    default: self defaultDefault;
		    yourself]
    ]

    MADescription class >> descriptionGroup [
	<category: 'accessing-description'>
	^(MAStringDescription new)
	    accessor: #group;
	    default: self defaultGroup;
	    label: 'Group';
	    priority: 105;
	    yourself
    ]

    MADescription class >> descriptionLabel [
	<category: 'accessing-description'>
	^(MAStringDescription new)
	    accessor: #label;
	    label: 'Label';
	    priority: 100;
	    default: self defaultLabel;
	    yourself
    ]

    MADescription class >> descriptionName [
	<category: 'accessing-description'>
	^(MAStringDescription new)
	    accessor: #name;
	    label: 'Kind';
	    priority: 0;
	    beReadonly;
	    yourself
    ]

    MADescription class >> descriptionPriority [
	<category: 'accessing-description'>
	^(MANumberDescription new)
	    accessor: #priority;
	    label: 'Priority';
	    priority: 130;
	    default: self defaultPriority;
	    beRequired;
	    yourself
    ]

    MADescription class >> descriptionReadonly [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #readonly;
	    label: 'Readonly';
	    priority: 200;
	    default: self defaultReadonly;
	    yourself
    ]

    MADescription class >> descriptionRequired [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #required;
	    label: 'Required';
	    priority: 220;
	    default: self defaultRequired;
	    yourself
    ]

    MADescription class >> descriptionStringReader [
	<category: 'accessing-description'>
	^(MASingleOptionDescription new)
	    accessor: #stringReader;
	    label: 'String Reader';
	    priority: 300;
	    default: self defaultStringReader;
	    options: [self defaultStringReader withAllSubclasses] asDynamicObject;
	    reference: MAClassDescription new;
	    yourself
    ]

    MADescription class >> descriptionStringWriter [
	<category: 'accessing-description'>
	^(MASingleOptionDescription new)
	    accessor: #stringWriter;
	    label: 'String Writer';
	    priority: 310;
	    default: self defaultStringWriter;
	    options: [self defaultStringWriter withAllSubclasses] asDynamicObject;
	    reference: MAClassDescription new;
	    yourself
    ]

    MADescription class >> descriptionUndefined [
	<category: 'accessing-description'>
	^(MAStringDescription new)
	    accessor: #undefined;
	    label: 'Undefined String';
	    priority: 140;
	    default: self defaultUndefined;
	    yourself
    ]

    MADescription class >> descriptionValidator [
	<category: 'accessing-description'>
	^(MASingleOptionDescription new)
	    accessor: #validator;
	    label: 'Validator';
	    priority: 250;
	    default: self defaultValidator;
	    options: [self defaultValidator withAllSubclasses] asDynamicObject;
	    reference: MAClassDescription new;
	    yourself
    ]

    MADescription class >> descriptionVisible [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #visible;
	    label: 'Visible';
	    priority: 210;
	    default: self defaultVisible;
	    yourself
    ]

    MADescription class >> null [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MANullAccessor uuid: MACompatibility uuid)
    ]

    MADescription class >> null: anUuid [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MANullAccessor uuid: anUuid)
    ]

    MADescription class >> null: anUuid label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MANullAccessor uuid: anUuid) label: aString
    ]

    MADescription class >> null: anUuid label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MANullAccessor uuid: anUuid)
	    label: aString
	    priority: aNumber
    ]

    MADescription class >> null: anUuid label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MANullAccessor uuid: anUuid)
	    label: aString
	    priority: aNumber
	    default: anObject
    ]

    MADescription class >> read: aReadBlock write: aWriteBlock [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAPluggableAccessor read: aReadBlock write: aWriteBlock)
    ]

    MADescription class >> read: aReadBlock write: aWriteBlock label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAPluggableAccessor read: aReadBlock write: aWriteBlock)
	    label: aString
    ]

    MADescription class >> read: aReadBlock write: aWriteBlock label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAPluggableAccessor read: aReadBlock write: aWriteBlock)
	    label: aString
	    priority: aNumber
    ]

    MADescription class >> read: aReadBlock write: aWriteBlock label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAPluggableAccessor read: aReadBlock write: aWriteBlock)
	    label: aString
	    priority: aNumber
	    default: anObject
    ]

    MADescription class >> selector: aSelector [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MASelectorAccessor selector: aSelector)
    ]

    MADescription class >> selector: aSelector label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MASelectorAccessor selector: aSelector) label: aString
    ]

    MADescription class >> selector: aSelector label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MASelectorAccessor selector: aSelector)
	    label: aString
	    priority: aNumber
    ]

    MADescription class >> selector: aSelector label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MASelectorAccessor selector: aSelector)
	    label: aString
	    priority: aNumber
	    default: anObject
    ]

    MADescription class >> selectors: anArray [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAChainAccessor selectors: anArray)
    ]

    MADescription class >> selectors: anArray label: aString [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self accessor: (MAChainAccessor selectors: anArray) label: aString
    ]

    MADescription class >> selectors: anArray label: aString priority: aNumber [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAChainAccessor selectors: anArray)
	    label: aString
	    priority: aNumber
    ]

    MADescription class >> selectors: anArray label: aString priority: aNumber default: anObject [
	<category: 'deprecated'>
	self deprecated: 'Obsolete, use instance side configuration methods.'.
	^self 
	    accessor: (MAChainAccessor selectors: anArray)
	    label: aString
	    priority: aNumber
	    default: anObject
    ]

    , aDescription [
	"Concatenate the receiver and ==aDescription== to one composed description. Answer a description container containing both descriptions."

	<category: 'operators'>
	^(self asContainer copy)
	    addAll: aDescription asContainer;
	    yourself
    ]

    <= anObject [
	"Answer whether the receiver should precede ==anObject== in a priority container."

	<category: 'operators'>
	^self priority <= anObject priority
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self accessor = anObject accessor]
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitDescription: self
    ]

    accessor [
	"Answer the access-strategy of the model-value described by the receiver."

	<category: 'accessing'>
	^accessor ifNil: [accessor := self class defaultAccessor]
    ]

    accessor: anObject [
	<category: 'accessing'>
	accessor := anObject asAccessor
    ]

    addCondition: aCondition [
	<category: 'validation'>
	self addCondition: aCondition labelled: aCondition asString
    ]

    addCondition: aCondition labelled: aString [
	"Add ==aCondition== as an additional validation condition to the receiver and give it the label ==aString==. The first argument is either a block-context, a composite of the subclasses of ==*MACondition*==, or any other object that responds to ==#value:== with ==true== or ==false==."

	<category: 'validation'>
	self conditions: (self conditions 
		    copyWith: (Association key: aCondition value: aString))
    ]

    asContainer [
	"Answer a description container of the receiver."

	<category: 'converting'>
	self subclassResponsibility
    ]

    autoAccessor: aSelector [
	"Uses ==aSelector== to read from the model. Creates read and write accessors and instance-variables if necessary. This is very conveniant for prototyping and can later be changed to a ==*selectorAccessor:*== using a simple rewrite rule."

	<category: 'accessors'>
	self accessor: (MAAutoSelectorAccessor selector: aSelector)
    ]

    beHidden [
	<category: 'actions'>
	self visible: false
    ]

    beOptional [
	<category: 'actions'>
	self required: false
    ]

    beReadonly [
	<category: 'actions'>
	self readonly: true
    ]

    beRequired [
	<category: 'actions'>
	self required: true
    ]

    beVisible [
	<category: 'actions'>
	self visible: true
    ]

    beWriteable [
	<category: 'actions'>
	self readonly: false
    ]

    chainAccessor: anArray [
	"Uses ==anArray== of selectors to read from the model."

	<category: 'accessors'>
	self accessor: (MAChainAccessor accessors: anArray)
    ]

    comment [
	"Answer a comment or help-text giving a hint what this description is used for. GUIs that are built from this description might display it as a tool-tip."

	<category: 'accessing-properties'>
	^self propertyAt: #comment ifAbsent: [self class defaultComment]
    ]

    comment: aString [
	<category: 'accessing-properties'>
	self propertyAt: #comment put: aString
    ]

    conditions [
	"Answer a collection of additional conditions that need to be fulfilled so that the described model is valid. Internally the collection associates conditions, that are either blocks or subclasses of *MACondition*, with an error string."

	<category: 'accessing-properties'>
	^self propertyAt: #conditions ifAbsent: [self class defaultConditions]
    ]

    conditions: anArray [
	<category: 'accessing-properties'>
	self propertyAt: #conditions put: anArray
    ]

    conflictErrorMessage [
	<category: 'accessing-messages'>
	^self propertyAt: #conflictErrorMessage
	    ifAbsent: ['Input is conflicting with concurrent modification']
    ]

    conflictErrorMessage: aString [
	<category: 'accessing-messages'>
	^self propertyAt: #conflictErrorMessage put: aString
    ]

    default [
	<category: 'accessing'>
	^nil
    ]

    default: anObject [
	<category: 'accessing'>
	
    ]

    fromString: aString [
	"Answer an object being parsed from ==aString==."

	<category: 'strings'>
	^self fromString: aString reader: self stringReader
    ]

    fromString: aString reader: aParser [
	"Answer an object being parsed from ==aString== using ==aParser==."

	<category: 'strings'>
	^aParser read: aString readStream description: self
    ]

    fromStringCollection: aCollection [
	"Answer a collection of objects being parsed from ==aCollection== of strings."

	<category: 'strings'>
	^self fromStringCollection: aCollection reader: self stringReader
    ]

    fromStringCollection: aCollection reader: aParser [
	"Answer a collection of objects being parsed from ==aCollection== of strings using ==aParser==."

	<category: 'strings'>
	^aCollection collect: [:each | self fromString: each reader: aParser]
    ]

    group [
	"Answer the group of the receiving description. The group is a string used to categorize and group descriptions. Certain display interpreters with be able to use this information to improve the useability."

	<category: 'accessing-properties'>
	^self propertyAt: #group ifAbsent: [self class defaultGroup]
    ]

    group: aString [
	"Answer the group of the receiving description. The group is a string used to categorize and group descriptions. Certain display interpreters with be able to use this information to improve the useability."

	<category: 'accessing-properties'>
	^self propertyAt: #group put: aString
    ]

    hasChildren [
	"Answer ==true== if the receiver has any child-descriptions. A description container usually has children."

	<category: 'testing'>
	^false
    ]

    hasComment [
	"Answer ==true== if the the receiver has got a non empty comment."

	<category: 'testing'>
	^self comment isEmptyOrNil not
    ]

    hasLabel [
	"Answer ==true== if the the receiver has got a non empty label."

	<category: 'testing'>
	^self label isEmptyOrNil not
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self accessor hash
    ]

    isContainer [
	"Answer ==true== if the receiver is a description container."

	<category: 'testing'>
	^false
    ]

    isDescription [
	"Answer ==true== if the receiver is a description."

	<category: 'testing'>
	^true
    ]

    isGrouped [
	<category: 'testing'>
	^false
    ]

    isReadonly [
	<category: 'testing'>
	^self readonly
    ]

    isRequired [
	<category: 'testing'>
	^self required
    ]

    isSatisfiedBy: anObject [
	"Answer ==true== if ==anObject== is a valid instance of the receiver's description."

	<category: 'validation'>
	[self validate: anObject] on: MAValidationError do: [:err | ^false].
	^true
    ]

    isSortable [
	"Answer ==true== if the described object can be trivially sorted, e.g. it answers to #<=."

	<category: 'testing'>
	^false
    ]

    isVisible [
	<category: 'testing'>
	^self visible
    ]

    kind [
	"Answer the base-class (type) the receiver is describing. The default implementation answers the most generic class: Object, the root of the Smalltalk class hierarchy. Subclasses might refine this choice."

	<category: 'accessing-configuration'>
	^Object
    ]

    kindErrorMessage [
	<category: 'accessing-messages'>
	^self propertyAt: #kindErrorMessage ifAbsent: ['Invalid input given']
    ]

    kindErrorMessage: aString [
	<category: 'accessing-messages'>
	^self propertyAt: #kindErrorMessage put: aString
    ]

    label [
	"Answer the label of the receiving description. The label is mostly used as an identifier that is printed next to the input field when building a GUI from the receiver."

	<category: 'accessing-properties'>
	^self propertyAt: #label ifAbsent: [self class defaultLabel]
    ]

    label: aString [
	<category: 'accessing-properties'>
	self propertyAt: #label put: aString
    ]

    multipleErrorsMessage [
	<category: 'accessing-messages'>
	^self propertyAt: #multipleErrorsMessage ifAbsent: ['Multiple errors']
    ]

    multipleErrorsMessage: aString [
	<category: 'accessing-messages'>
	^self propertyAt: #multipleErrorsMessage put: aString
    ]

    name [
	"Answer the name of the description, a human-readable string describing the type."

	<category: 'accessing-configuration'>
	^self class label
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	accessor := accessor copy
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPutAll: ' label: ';
	    print: self label.
	aStream
	    nextPutAll: ' comment: ';
	    print: self comment
    ]

    priority [
	"Answer a number that is the priority of the receiving description. Priorities are used to give descriptions an explicit order by sorting them according to this number."

	<category: 'accessing-properties'>
	^self propertyAt: #priority ifAbsent: [self class defaultPriority]
    ]

    priority: aNumber [
	<category: 'accessing-properties'>
	self propertyAt: #priority put: aNumber
    ]

    propertyAccessor: aSelector [
	"Uses ==aSelector== to read from the property dictionary of the model."

	<category: 'accessors'>
	self accessor: ((MAChainAccessor on: #properties) 
		    accessor: (MADictionaryAccessor key: aSelector))
    ]

    readonly [
	"Answer ==true== if the model described by the receiver is read-only."

	<category: 'accessing-properties'>
	^self propertyAt: #readonly ifAbsent: [self class defaultReadonly]
    ]

    readonly: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #readonly put: aBoolean
    ]

    required [
	"Answer ==true== if the model described by the receiver is required, this is it cannot be ==nil==."

	<category: 'accessing-properties'>
	^self propertyAt: #required ifAbsent: [self class defaultRequired]
    ]

    required: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #required put: aBoolean
    ]

    requiredErrorMessage [
	<category: 'accessing-messages'>
	^self propertyAt: #requiredErrorMessage
	    ifAbsent: ['Input is required but no input given']
    ]

    requiredErrorMessage: aString [
	<category: 'accessing-messages'>
	^self propertyAt: #requiredErrorMessage put: aString
    ]

    selectorAccessor: aSelector [
	"Uses ==aSelector== to read from the model."

	<category: 'accessors'>
	self accessor: (MASelectorAccessor selector: aSelector)
    ]

    stringReader [
	"Answer a Visitor that can be used to parse the model described by the receiver from a string."

	<category: 'accessing-strings'>
	^self propertyAt: #stringReader ifAbsent: [self class defaultStringReader]
    ]

    stringReader: aClass [
	<category: 'accessing-strings'>
	self propertyAt: #stringReader put: aClass
    ]

    stringWriter [
	"Answer a Visitor that can be used to convert the model described by the receiver to a string."

	<category: 'accessing-strings'>
	^self propertyAt: #stringWriter ifAbsent: [self class defaultStringWriter]
    ]

    stringWriter: aClass [
	<category: 'accessing-strings'>
	self propertyAt: #stringWriter put: aClass
    ]

    toString: anObject [
	"Answer a string being formatted from ==anObject==."

	<category: 'strings'>
	^self toString: anObject writer: self stringWriter
    ]

    toString: anObject writer: aFormatter [
	"Answer a string being formatted from ==anObject== using ==aFormatter==."

	<category: 'strings'>
	^aFormatter write: anObject description: self
    ]

    toStringCollection: aCollection [
	"Answer a collection of strings being formatted from ==aCollection==."

	<category: 'strings'>
	^self toStringCollection: aCollection writer: self stringWriter
    ]

    toStringCollection: aCollection writer: aFormatter [
	"Answer a collection of strings being formatted from ==aCollection== using ==aFormatter==."

	<category: 'strings'>
	^aCollection collect: [:each | self toString: each writer: aFormatter]
    ]

    undefined [
	"Answer a string that is printed whenever the model described by the receiver is ==nil==."

	<category: 'accessing-strings'>
	^(self propertyAt: #undefined ifAbsent: [self class defaultUndefined]) 
	    ifNil: [self class defaultUndefined]
    ]

    undefined: aString [
	<category: 'accessing-strings'>
	self propertyAt: #undefined put: aString
    ]

    validate: anObject [
	"Validate ==anObject== in the context of the describing-receiver, raises an error in case of a problem. If ==anObject== is ==nil== and not required, most tests will be skipped. Do not override this message, instead have a look at ==#validateSpecific:== what is usually a better place to define the behaviour your description requires."

	<category: 'validation'>
	self validator on: anObject description: self
    ]

    validateConditions: anObject [
	"Validate ==anObject== to satisfy all its custom conditions."

	<category: 'validation-private'>
	self conditions do: 
		[:each | 
		(each key value: anObject) 
		    ifFalse: [MAConditionError description: self signal: each value]]
    ]

    validateKind: anObject [
	"Validate ==anObject== to be of the right kind."

	<category: 'validation-private'>
	(anObject isKindOf: self kind) 
	    ifFalse: [MAKindError description: self signal: self kindErrorMessage]
    ]

    validateRequired: anObject [
	"Validate ==anObject== not to be ==nil== if it is required."

	<category: 'validation-private'>
	(self isRequired and: [anObject isNil]) 
	    ifTrue: [MARequiredError description: self signal: self requiredErrorMessage]
    ]

    validateSpecific: anObject [
	"Validate ==anObject== to satisfy its descriptions specific validation rules. Subclasses mostly want to override this method."

	<category: 'validation-private'>
	
    ]

    validator [
	"Answer a Visitor that can be used to validate the model described by the receiver."

	<category: 'accessing-properties'>
	^self propertyAt: #validator ifAbsent: [self class defaultValidator]
    ]

    validator: aClass [
	<category: 'accessing-properties'>
	self propertyAt: #validator put: aClass
    ]

    visible [
	"Answer ==true== if the model described by the receiver is visible, as an opposite to hidden."

	<category: 'accessing-properties'>
	^self propertyAt: #visible ifAbsent: [self class defaultVisible]
    ]

    visible: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #visible put: aBoolean
    ]
]



MADescription subclass: MAContainer [
    | children |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a container holding a collection of descriptions, all instances of subclasses of *MAElementDescription*. I keep my children within an ==OrderedCollection==, but I don''t sort them according to their priority.

I fully support the collection protocol: descriptions can be added and removed. Moreover I implement most enumeration methods, so that users are able to iterate (==do:==), filter (==select:==, ==reject:==), transform (==collect:==), extract (==detect:==, ==detect:ifNone:==), and test (==allSatisfy:==, ==anySatisfy:==, ==noneSatisfy:==) my elements.'>

    MAContainer class >> defaultAccessor [
	<category: 'accessing-defaults'>
	^MAIdentityAccessor new
    ]

    MAContainer class >> defaultCollection [
	<category: 'accessing-defaults'>
	^OrderedCollection new
    ]

    MAContainer class >> descriptionChildren [
	<category: 'accessing-description'>
	^(MAToManyRelationDescription new)
	    accessor: (MASelectorAccessor read: #children write: #setChildren:);
	    classes: [MAElementDescription withAllConcreteClasses] asDynamicObject;
	    default: self defaultCollection;
	    label: 'Elements';
	    priority: 400;
	    beOrdered;
	    yourself
    ]

    MAContainer class >> descriptionDefault [
	<category: 'accessing-description'>
	^nil
    ]

    MAContainer class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAContainer class >> with: aDescription [
	<category: 'instance creation'>
	^(self new)
	    add: aDescription;
	    yourself
    ]

    MAContainer class >> withAll: aCollection [
	<category: 'instance creation'>
	^(self new)
	    addAll: aCollection;
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self children = anObject children]
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitContainer: self
    ]

    add: aDescription [
	<category: 'adding'>
	self children add: aDescription
    ]

    addAll: aCollection [
	<category: 'adding'>
	self children addAll: aCollection
    ]

    allSatisfy: aBlock [
	<category: 'enumerating'>
	^self children allSatisfy: aBlock
    ]

    anySatisfy: aBlock [
	<category: 'enumerating'>
	^self children anySatisfy: aBlock
    ]

    asContainer [
	<category: 'converting'>
	^self
    ]

    at: anIndex [
	<category: 'accessing'>
	^self children at: anIndex
    ]

    at: anIndex ifAbsent: aBlock [
	<category: 'accessing'>
	^self children at: anIndex ifAbsent: aBlock
    ]

    children [
	<category: 'accessing'>
	^children
    ]

    collect: aBlock [
	<category: 'enumerating'>
	^(self copy)
	    setChildren: (self children collect: aBlock);
	    yourself
    ]

    copyEmpty [
	<category: 'copying'>
	^(self copy)
	    setChildren: self class defaultCollection;
	    yourself
    ]

    copyFrom: aStartIndex to: anEndIndex [
	<category: 'copying'>
	^(self copy)
	    setChildren: (self children copyFrom: aStartIndex to: anEndIndex);
	    yourself
    ]

    copyWithout: anObject [
	<category: 'copying'>
	^self reject: [:each | each = anObject]
    ]

    copyWithoutAll: aCollection [
	<category: 'copying'>
	^self reject: [:each | aCollection includes: each]
    ]

    detect: aBlock [
	<category: 'enumerating'>
	^self children detect: aBlock
    ]

    detect: aBlock ifNone: anExceptionBlock [
	<category: 'enumerating'>
	^self children detect: aBlock ifNone: anExceptionBlock
    ]

    do: aBlock [
	<category: 'enumerating'>
	self children do: aBlock
    ]

    do: aBlock separatedBy: aSeparatorBlock [
	<category: 'enumerating'>
	self children do: aBlock separatedBy: aSeparatorBlock
    ]

    errorNotFound: aDescription [
	<category: 'private'>
	self error: aDescription class label , ' not found.'
    ]

    hasChildren [
	<category: 'testing'>
	^self notEmpty
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self children hash
    ]

    includes: aDescription [
	<category: 'testing'>
	^self children includes: aDescription
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	self setChildren: self class defaultCollection
    ]

    inject: anObject into: aBlock [
	<category: 'enumerating'>
	^self children inject: anObject into: aBlock
    ]

    intersection: aCollection [
	<category: 'enumerating'>
	^(self copy)
	    setChildren: (self children intersection: aCollection);
	    yourself
    ]

    isContainer [
	<category: 'testing'>
	^true
    ]

    isEmpty [
	<category: 'testing'>
	^self children isEmpty
    ]

    keysAndValuesDo: aBlock [
	<category: 'enumerating'>
	self children keysAndValuesDo: aBlock
    ]

    moveDown: aDescription [
	<category: 'moving'>
	self children moveDown: aDescription
    ]

    moveUp: aDescription [
	<category: 'moving'>
	self children moveUp: aDescription
    ]

    noneSatisfy: aBlock [
	<category: 'enumerating'>
	^self children noneSatisfy: aBlock
    ]

    notEmpty [
	<category: 'testing'>
	^self children notEmpty
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	self setChildren: self children copy
    ]

    reject: aBlock [
	<category: 'enumerating'>
	^(self copy)
	    setChildren: (self children reject: aBlock);
	    yourself
    ]

    remove: aDescription [
	<category: 'removing'>
	self children remove: aDescription
	    ifAbsent: [self errorNotFound: aDescription]
    ]

    removeAll [
	<category: 'removing'>
	self setChildren: self class defaultCollection
    ]

    select: aBlock [
	<category: 'enumerating'>
	^(self copy)
	    setChildren: (self children select: aBlock);
	    yourself
    ]

    setChildren: aCollection [
	<category: 'initialization'>
	children := aCollection
    ]

    size [
	<category: 'accessing'>
	^self children size
    ]

    union: aContainer [
	<category: 'enumerating'>
	^(self copy)
	    addAll: (aContainer reject: [:each | self includes: each]);
	    yourself
    ]

    with: aCollection do: aBlock [
	<category: 'enumerating'>
	self children with: aCollection do: aBlock
    ]
]



MAContainer subclass: MAPriorityContainer [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a container holding a collection of descriptions and I keep them sorted according to their priority.'>

    MAPriorityContainer class >> defaultCollection [
	<category: 'accessing-defaults'>
	^SortedCollection new
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitPriorityContainer: self
    ]

    moveDown: aDescription [
	<category: 'moving'>
	self shouldNotImplement
    ]

    moveUp: aDescription [
	<category: 'moving'>
	self shouldNotImplement
    ]

    resort [
	<category: 'actions'>
	self setChildren: self children copy
    ]

    setChildren: aCollection [
	<category: 'initialization'>
	super setChildren: aCollection asSortedCollection
    ]
]



MADescription subclass: MAElementDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am an abstract description for all basic description types.'>

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitElementDescription: self
    ]

    asContainer [
	<category: 'converting'>
	^MAContainer with: self
    ]

    default [
	<category: 'accessing'>
	^self propertyAt: #default ifAbsent: [self class defaultDefault]
    ]

    default: anObject [
	<category: 'accessing'>
	self propertyAt: #default put: anObject
    ]
]



MAElementDescription subclass: MABooleanDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of the Boolean values ==true== and ==false==. My visual representation could be a check-box.'>

    MABooleanDescription class >> defaultFalseString [
	<category: 'accessing-defaults'>
	^self defaultFalseStrings first
    ]

    MABooleanDescription class >> defaultFalseStrings [
	<category: 'accessing-defaults'>
	^#('false' 'f' 'no' 'n' '0' 'off')
    ]

    MABooleanDescription class >> defaultTrueString [
	<category: 'accessing-defaults'>
	^self defaultTrueStrings first
    ]

    MABooleanDescription class >> defaultTrueStrings [
	<category: 'accessing-defaults'>
	^#('true' 't' 'yes' 'y' '1' 'on')
    ]

    MABooleanDescription class >> descriptionFalseString [
	<category: 'accessing-descriptions'>
	^(MAStringDescription new)
	    accessor: #falseString;
	    default: self defaultFalseString;
	    label: 'False String';
	    priority: 410;
	    yourself
    ]

    MABooleanDescription class >> descriptionRequired [
	<category: 'accessing-descriptions'>
	^nil
    ]

    MABooleanDescription class >> descriptionTrueString [
	<category: 'accessing-descriptions'>
	^(MAStringDescription new)
	    accessor: #trueString;
	    default: self defaultTrueString;
	    label: 'True String';
	    priority: 400;
	    yourself
    ]

    MABooleanDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MABooleanDescription class >> label [
	<category: 'accessing'>
	^'Boolean'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitBooleanDescription: self
    ]

    allOptions [
	<category: 'accessing-selection'>
	^self options
    ]

    allOptionsWith: anObject [
	<category: 'accessing-selection'>
	^self options
    ]

    falseString [
	<category: 'accessing-properties'>
	^self propertyAt: #falseString ifAbsent: [self class defaultFalseString]
    ]

    falseString: aString [
	<category: 'accessing-properties'>
	^self propertyAt: #falseString put: aString
    ]

    falseStrings [
	<category: 'accessing-readonly'>
	^self class defaultFalseStrings
    ]

    isExtensible [
	<category: 'accessing-selection'>
	^false
    ]

    kind [
	<category: 'accessing'>
	^Boolean
    ]

    labelForOption: anObject [
	<category: 'private'>
	anObject == true ifTrue: [^self trueString].
	anObject == false ifTrue: [^self falseString].
	^self undefined
    ]

    options [
	<category: 'accessing-selection'>
	^Array with: false with: true
    ]

    reference [
	<category: 'accessing-selection'>
	^self
    ]

    trueString [
	<category: 'accessing-properties'>
	^self propertyAt: #trueString ifAbsent: [self class defaultTrueString]
    ]

    trueString: aString [
	<category: 'accessing-properties'>
	^self propertyAt: #trueString put: aString
    ]

    trueStrings [
	<category: 'accessing-readonly'>
	^self class defaultTrueStrings
    ]
]



MAElementDescription subclass: MAClassDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of Smalltalk classes, possible values can be any of ==Smalltalk allClasses==.'>

    MAClassDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAClassDescription class >> label [
	<category: 'accessing'>
	^'Class'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitClassDescription: self
    ]

    kind [
	<category: 'accessing'>
	^Class
    ]
]



MAElementDescription subclass: MAFileDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of files, their contents, filename and mime-type. Possible values include instances of *MAFileModel*. My visual representation could be a file-upload dialog.'>

    MAFileDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAFileDescription class >> label [
	<category: 'accessing'>
	^'File'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitFileDescription: self
    ]

    kind [
	<category: 'accessing'>
	^self propertyAt: #modelClass ifAbsent: [MAMemoryFileModel]
    ]

    kind: aClass [
	"Set the file model class to be used."

	<category: 'accessing'>
	self propertyAt: #modelClass put: aClass
    ]
]



MAElementDescription subclass: MAMagnitudeDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am an abstract description for subclasses of ==Magnitude==. The range of accepted values can be limited using the accessors ==min:== and ==max:==.'>

    MAMagnitudeDescription class >> defaultMax [
	<category: 'accessing-defaults'>
	^nil
    ]

    MAMagnitudeDescription class >> defaultMin [
	<category: 'accessing-defaults'>
	^nil
    ]

    MAMagnitudeDescription class >> descriptionMax [
	<category: 'accessing-description'>
	^(self new)
	    accessor: #max;
	    label: 'Maximum';
	    priority: 410;
	    yourself
    ]

    MAMagnitudeDescription class >> descriptionMin [
	<category: 'accessing-description'>
	^(self new)
	    accessor: #min;
	    label: 'Min';
	    priority: 400;
	    yourself
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitMagnitudeDescription: self
    ]

    isSortable [
	<category: 'testing'>
	^true
    ]

    isWithinRange: anObject [
	<category: 'testing'>
	^(self min isNil or: [self min <= anObject]) 
	    and: [self max isNil or: [self max >= anObject]]
    ]

    max [
	<category: 'accessing'>
	^self propertyAt: #max ifAbsent: [self class defaultMax]
    ]

    max: aMagnitudeOrNil [
	"Set the maximum for accepted values, or ==nil== if open."

	<category: 'accessing'>
	^self propertyAt: #max put: aMagnitudeOrNil
    ]

    min [
	<category: 'accessing'>
	^self propertyAt: #min ifAbsent: [self class defaultMin]
    ]

    min: aMagnitudeOrNil [
	"Set the minimum for accepted values, or ==nil== if open."

	<category: 'accessing'>
	^self propertyAt: #min put: aMagnitudeOrNil
    ]

    min: aMinimumObject max: aMaximumObject [
	"Set the minimum and maximum of accepted values, or ==nil== if open."

	<category: 'conveniance'>
	self
	    min: aMinimumObject;
	    max: aMaximumObject
    ]

    rangeErrorMessage [
	<category: 'accessing-messages'>
	| min max |
	^self propertyAt: #rangeErrorMessage
	    ifAbsent: 
		[min := self toString: self min.
		max := self toString: self max.
		(self min notNil and: [self max notNil]) 
		    ifTrue: [^'Input must be between ' , min , ' and ' , max].
		(self min notNil and: [self max isNil]) 
		    ifTrue: [^'Input must be above or equeal to ' , min].
		(self min isNil and: [self max notNil]) 
		    ifTrue: [^'Input must be below or equal to ' , max]]
    ]

    rangeErrorMessage: aString [
	<category: 'accessing-messages'>
	^self propertyAt: #rangeErrorMessage put: aString
    ]

    validateSpecific: anObject [
	<category: 'validation-private'>
	super validateSpecific: anObject.
	(self isWithinRange: anObject) 
	    ifFalse: [MARangeError description: self signal: self rangeErrorMessage]
    ]
]



MAMagnitudeDescription subclass: MADateDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of dates, possible values are instances of ==Date==. My visual representation could be a date-picker.'>

    MADateDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MADateDescription class >> label [
	<category: 'accessing'>
	^'Date'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitDateDescription: self
    ]

    kind [
	<category: 'accessing'>
	^Date
    ]
]



MAMagnitudeDescription subclass: MADurationDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of durations, possible values are instances of ==Duration==.'>

    MADurationDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MADurationDescription class >> label [
	<category: 'accessing'>
	^'Duration'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitDurationDescription: self
    ]

    kind [
	<category: 'accessing'>
	^Duration
    ]
]



MAMagnitudeDescription subclass: MANumberDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of numbers, possible values are instances of ==Number== and all its subclasses, including ==Integer== and ==Float==. My visual representation could be a number input-box or even a slider-control.'>

    MANumberDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MANumberDescription class >> label [
	<category: 'accessing'>
	^'Number'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitNumberDescription: self
    ]

    beInteger [
	<category: 'conveniance'>
	self addCondition: [:value | value isInteger]
	    labelled: 'No integer was entered'
    ]

    kind [
	<category: 'accessing'>
	^Number
    ]
]



MAMagnitudeDescription subclass: MATimeDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of times, possible values are instances of ==Time==. My visual representation could be a time-picker.'>

    MATimeDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MATimeDescription class >> label [
	<category: 'accessing'>
	^'Time'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitTimeDescription: self
    ]

    kind [
	<category: 'accessing'>
	^Time
    ]
]



MAMagnitudeDescription subclass: MATimeStampDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of timestamps, possible values are instances of ==DateTime==. My visual representation could be a date- and time-picker.'>

    MATimeStampDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MATimeStampDescription class >> label [
	<category: 'accessing'>
	^'Timestamp'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitTimeStampDescription: self
    ]

    kind [
	<category: 'accessing'>
	^DateTime
    ]
]



MAElementDescription subclass: MAReferenceDescription [
    | reference |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am an abstract superclass for descriptions holding onto another description.
'>

    MAReferenceDescription class >> defaultReference [
	<category: 'accessing-defaults'>
	^MAStringDescription new
    ]

    MAReferenceDescription class >> descriptionReference [
	<category: 'accessing-description'>
	^(MAToOneRelationDescription new)
	    accessor: #reference;
	    classes: [MADescription withAllConcreteClasses] asDynamicObject;
	    label: 'Description';
	    priority: 400;
	    beRequired;
	    yourself
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitReferenceDescription: self
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	reference := reference copy
    ]

    reference [
	<category: 'accessing'>
	^reference ifNil: [reference := self class defaultReference]
    ]

    reference: aDescription [
	<category: 'accessing'>
	reference := aDescription
    ]
]



MAReferenceDescription subclass: MAOptionDescription [
    | options |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am an abstract description of different options the user can choose from. My instance variable ==options== references the options I am representing. The options can be sorted or unsorted.'>

    MAOptionDescription class >> defaultOptions [
	<category: 'accessing-defaults'>
	^OrderedCollection new
    ]

    MAOptionDescription class >> defaultSorted [
	<category: 'accessing-defaults'>
	^false
    ]

    MAOptionDescription class >> descriptionDefault [
	<category: 'accessing-description'>
	^nil
    ]

    MAOptionDescription class >> descriptionOptions [
	<category: 'accessing-description'>
	^(MAMemoDescription new)
	    accessor: #optionsTextual;
	    label: 'Options';
	    priority: 410;
	    default: self defaultOptions;
	    yourself
    ]

    MAOptionDescription class >> descriptionSorted [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #sorted;
	    label: 'Sorted';
	    priority: 240;
	    default: self defaultSorted;
	    yourself
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitOptionDescription: self
    ]

    allOptions [
	<category: 'accessing-dynamic'>
	^self prepareOptions: self options copy
    ]

    allOptionsWith: anObject [
	<category: 'accessing-dynamic'>
	^self prepareOptions: ((self shouldNotInclude: anObject) 
		    ifFalse: [self options copyWith: anObject]
		    ifTrue: [self options copy])
    ]

    beSorted [
	<category: 'actions'>
	self sorted: true
    ]

    beUnsorted [
	<category: 'actions'>
	self sorted: false
    ]

    isSorted [
	<category: 'testing'>
	^self sorted
    ]

    labelForOption: anObject [
	<category: 'private'>
	self propertyAt: #labels
	    ifPresent: [:labels | labels at: anObject ifPresent: [:value | ^value]].
	^self reference toString: anObject
    ]

    options [
	<category: 'accessing'>
	^options ifNil: [options := self class defaultOptions]
    ]

    options: anArray [
	<category: 'accessing'>
	options := anArray
    ]

    optionsAndLabels: aCollection [
	"Set the options to be the keys of aCollection and the labels to be the values of aCollection."

	<category: 'accessing'>
	self options: (aCollection collect: [:assoc | assoc key]).
	self propertyAt: #labels
	    put: (aCollection inject: IdentityDictionary new
		    into: 
			[:result :assoc | 
			result
			    add: assoc;
			    yourself])
    ]

    optionsTextual [
	<category: 'accessing-textual'>
	^(self reference toStringCollection: self options) asMultilineString
    ]

    optionsTextual: aString [
	<category: 'accessing-textual'>
	| lines |
	lines := (aString ifNil: [String new]) lines.
	^self options: (self reference fromStringCollection: lines)
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	options := options copy
    ]

    prepareOptions: aCollection [
	<category: 'private'>
	^self isSorted 
	    ifFalse: [aCollection asArray]
	    ifTrue: 
		[(aCollection asArray)
		    sort: self sortBlock;
		    yourself]
    ]

    shouldNotInclude: anObject [
	<category: 'accessing-dynamic'>
	^anObject isNil or: [self options includes: anObject]
    ]

    sortBlock [
	<category: 'private'>
	^
	[:a :b | 
	(self reference toString: a) 
	    <= (self reference toString: b)]
    ]

    sorted [
	<category: 'accessing-properties'>
	^self propertyAt: #sorted ifAbsent: [self class defaultSorted]
    ]

    sorted: aBoolean [
	<category: 'accessing-properties'>
	^self propertyAt: #sorted put: aBoolean
    ]

    undefined: aString [
	<category: 'accessing-properties'>
	super undefined: aString.
	self reference isNil ifFalse: [self reference undefined: aString]
    ]
]



MAOptionDescription subclass: MAMultipleOptionDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of multiple options, possible options are stored within the ==options== field, possible values are instances of ==Collection==. My visual representation could be a multi-select list or a group of check-boxes.'>

    MAMultipleOptionDescription class >> defaultDistinct [
	<category: 'accessing-defaults'>
	^false
    ]

    MAMultipleOptionDescription class >> defaultOrdered [
	<category: 'accessing-defaults'>
	^false
    ]

    MAMultipleOptionDescription class >> descriptionDistinct [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #distinct;
	    label: 'Distinct';
	    priority: 250;
	    default: self defaultDistinct;
	    yourself
    ]

    MAMultipleOptionDescription class >> descriptionOrdered [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #ordered;
	    label: 'Ordered';
	    priority: 260;
	    default: self defaultOrdered;
	    yourself
    ]

    MAMultipleOptionDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAMultipleOptionDescription class >> label [
	<category: 'accessing'>
	^'Multiple-Option'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitMultipleOptionDescription: self
    ]

    beDistinct [
	<category: 'actions'>
	self distinct: true
    ]

    beIndefinite [
	<category: 'actions'>
	self distinct: false
    ]

    beOrdered [
	<category: 'actions'>
	self ordered: true
    ]

    beUnordered [
	<category: 'actions'>
	self ordered: false
    ]

    distinct [
	<category: 'accessing-properties'>
	^self propertyAt: #distinct ifAbsent: [self class defaultDistinct]
    ]

    distinct: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #distinct put: aBoolean
    ]

    isDistinct [
	<category: 'testing'>
	^self distinct
    ]

    isOrdered [
	<category: 'testing'>
	^self ordered
    ]

    kind [
	<category: 'accessing'>
	^Collection
    ]

    ordered [
	<category: 'accessing-properties'>
	^self propertyAt: #ordered ifAbsent: [self class defaultOrdered]
    ]

    ordered: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #ordered put: aBoolean
    ]

    validateKind: anObject [
	<category: 'validating'>
	super validateKind: anObject.
	(anObject allSatisfy: [:each | self options includes: each]) 
	    ifFalse: [MAKindError description: self signal: self kindErrorMessage]
    ]

    validateRequired: anObject [
	<category: 'validating'>
	super validateRequired: anObject.
	(self isRequired and: [anObject isCollection and: [anObject isEmpty]]) 
	    ifTrue: [MARequiredError description: self signal: self requiredErrorMessage]
    ]
]



MAOptionDescription subclass: MASingleOptionDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of a single option, possible values are stored within the ==options== field, but I might also be extensible so that the user can add its own option. My visual representation could be a drop-down list or a group of option-buttons.'>

    MASingleOptionDescription class >> defaultExtensible [
	<category: 'accessing-defaults'>
	^false
    ]

    MASingleOptionDescription class >> descriptionExtensible [
	<category: 'accessing-descriptions'>
	^(MABooleanDescription new)
	    accessor: #extensible;
	    label: 'Extensible';
	    priority: 250;
	    default: self defaultExtensible;
	    yourself
    ]

    MASingleOptionDescription class >> descriptionGroupBy [
	<category: 'accessing-descriptions'>
	^(MASymbolDescription new)
	    selectorAccessor: #groupBy;
	    label: 'Grouped by';
	    priority: 260;
	    default: nil;
	    yourself
    ]

    MASingleOptionDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MASingleOptionDescription class >> label [
	<category: 'accessing'>
	^'Single-Option'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitSingleOptionDescription: self
    ]

    beExtensible [
	<category: 'actions'>
	self extensible: true
    ]

    beLimited [
	<category: 'actions'>
	self extensible: false
    ]

    extensible [
	<category: 'accessing-properties'>
	^self propertyAt: #extensible ifAbsent: [self class defaultExtensible]
    ]

    extensible: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #extensible put: aBoolean
    ]

    groupBy [
	"Answer the selector to be sent to the options objects for determining their group"

	<category: 'accessing-properties'>
	^self propertyAt: #groupBy ifAbsent: [nil]
    ]

    groupBy: aSymbol [
	"aSymbol is the selector to be sent to the options objects for getting their group"

	<category: 'accessing-properties'>
	^self propertyAt: #groupBy put: aSymbol
    ]

    isExtensible [
	<category: 'testing'>
	^self extensible
    ]

    isGrouped [
	<category: 'testing'>
	^self groupBy notNil
    ]

    prepareOptions: aCollection [
	<category: 'private'>
	^self isRequired 
	    ifTrue: [super prepareOptions: aCollection]
	    ifFalse: [(super prepareOptions: aCollection) copyWithFirst: nil]
    ]

    shouldNotInclude: anObject [
	<category: 'accessing-dynamic'>
	^self isExtensible not or: [super shouldNotInclude: anObject]
    ]

    validateKind: anObject [
	<category: 'validating'>
	super validateKind: anObject.
	(self isExtensible or: [self options includes: anObject]) 
	    ifFalse: [MAKindError description: self signal: self kindErrorMessage]
    ]
]



MAReferenceDescription subclass: MARelationDescription [
    | classes |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am an abstract description for descriptions representing a relation. My instance variable ==classes== references a collection of possible classes that I can relate to. If required the reference description will be automatically built from this list of classes.'>

    MARelationDescription class >> defaultClasses [
	<category: 'accessing-defaults'>
	^Set new
    ]

    MARelationDescription class >> defaultReference [
	<category: 'accessing-defaults'>
	^nil
    ]

    MARelationDescription class >> descriptionClasses [
	<category: 'accessing-description'>
	^(MAMultipleOptionDescription new)
	    accessor: #classes;
	    label: 'Classes';
	    priority: 400;
	    options: [Smalltalk allClasses] asDynamicObject;
	    reference: MAClassDescription new;
	    yourself
    ]

    MARelationDescription class >> descriptionReference [
	<category: 'accessing-description'>
	^(super descriptionReference)
	    classes: [MAContainer withAllConcreteClasses] asDynamicObject;
	    beOptional;
	    yourself
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitRelationDescription: self
    ]

    allClasses [
	<category: 'accessing-dynamic'>
	^(Array withAll: self classes)
	    sort: [:a :b | a label <= b label];
	    yourself
    ]

    classes [
	<category: 'accessing'>
	^classes ifNil: [classes := self class defaultClasses]
    ]

    classes: aCollection [
	<category: 'accessing'>
	classes := aCollection
    ]

    commonClass [
	"Answer a common superclass of the classes of the receiver. The algorithm is implemented to be as efficient as possible. The inner loop will be only executed the first few iterations."

	<category: 'accessing-dynamic'>
	| current |
	self classes isEmpty ifTrue: [^self class descriptionContainer].
	current := self classes anyOne.
	self classes do: 
		[:each | 
		[each includesBehavior: current] 
		    whileFalse: [current := current superclass]].
	^current
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	classes := classes copy
    ]

    reference [
	"The reference within a ==*MARelationDescription*== is calculated automatically from all the classes of the receiver, if set to ==nil==. By setting the reference to a ==*MAContainer*== instance it is possible to customize the reference description."

	<category: 'accessing-dynamic'>
	^super reference ifNil: [self commonClass description]
    ]
]



MARelationDescription subclass: MAToManyRelationDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of an one-to-many relationship, possible values are instances of ==Collection==.'>

    MAToManyRelationDescription class >> defaultDefinitive [
	<category: 'accessing-defaults'>
	^false
    ]

    MAToManyRelationDescription class >> defaultOrdered [
	<category: 'accessing-defaults'>
	^false
    ]

    MAToManyRelationDescription class >> defaultSorted [
	<category: 'accessing-defaults'>
	^false
    ]

    MAToManyRelationDescription class >> descriptionDefinitive [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #definitive;
	    label: 'Definitive';
	    priority: 265;
	    default: self defaultDefinitive;
	    yourself
    ]

    MAToManyRelationDescription class >> descriptionOrdered [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #ordered;
	    label: 'Ordered';
	    priority: 260;
	    default: self defaultOrdered;
	    yourself
    ]

    MAToManyRelationDescription class >> descriptionSorted [
	<category: 'accessing-description'>
	^(MABooleanDescription new)
	    accessor: #sorted;
	    label: 'Sorted';
	    priority: 240;
	    default: self defaultSorted;
	    yourself
    ]

    MAToManyRelationDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAToManyRelationDescription class >> label [
	<category: 'accessing'>
	^'1:m Relation'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitToManyRelationDescription: self
    ]

    beDefinitive [
	<category: 'actions'>
	self definitive: true
    ]

    beModifiable [
	<category: 'actions'>
	self definitive: false
    ]

    beOrdered [
	<category: 'actions'>
	self ordered: true
    ]

    beSorted [
	<category: 'actions'>
	self sorted: true
    ]

    beUnordered [
	<category: 'actions'>
	self ordered: false
    ]

    beUnsorted [
	<category: 'actions'>
	self sorted: false
    ]

    definitive [
	<category: 'accessing-properties'>
	^self propertyAt: #definitive ifAbsent: [self class defaultDefinitive]
    ]

    definitive: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #definitive put: aBoolean
    ]

    isDefinitive [
	<category: 'testing'>
	^self definitive
    ]

    isOrdered [
	<category: 'testing'>
	^self ordered
    ]

    isSorted [
	<category: 'testing'>
	^self sorted
    ]

    kind [
	<category: 'accessing'>
	^Collection
    ]

    ordered [
	<category: 'accessing-properties'>
	^self propertyAt: #ordered ifAbsent: [self class defaultOrdered]
    ]

    ordered: aBoolean [
	<category: 'accessing-properties'>
	self propertyAt: #ordered put: aBoolean
    ]

    sorted [
	<category: 'accessing-properties'>
	^self propertyAt: #sorted ifAbsent: [self class defaultSorted]
    ]

    sorted: aBoolean [
	<category: 'accessing-properties'>
	^self propertyAt: #sorted put: aBoolean
    ]

    validateKind: anObject [
	<category: 'validating'>
	super validateKind: anObject.
	anObject do: 
		[:object | 
		(self classes 
		    anySatisfy: [:class | object species includesBehavior: class]) 
			ifFalse: [MAKindError description: self signal: self kindErrorMessage]]
    ]

    validateRequired: anObject [
	<category: 'validating'>
	super validateRequired: anObject.
	(self isRequired and: [anObject isCollection and: [anObject isEmpty]]) 
	    ifTrue: [MARequiredError description: self signal: self requiredErrorMessage]
    ]
]



MAToManyRelationDescription subclass: MAToManyScalarRelationDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'Like MAToManyRelationDescription but for scalar values.'>

    MAToManyScalarRelationDescription class >> label [
	<category: 'accessing'>
	^'1:m scalar Relation'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitToManyScalarRelationDescription: self
    ]
]



MARelationDescription subclass: MAToOneRelationDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of an one-to-one relationship.'>

    MAToOneRelationDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAToOneRelationDescription class >> label [
	<category: 'accessing'>
	^'1:1 Relation'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitToOneRelationDescription: self
    ]

    validateKind: anObject [
	<category: 'validating'>
	super validateKind: anObject.
	(self classes anySatisfy: [:class | anObject species = class]) 
	    ifFalse: [MAKindError description: self signal: self kindErrorMessage]
    ]
]



MAReferenceDescription subclass: MATableDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of tables, their cells and labels. I hold a reference to the description of my cells, that are all described using the same description. Possible values include instances of *MATableModel*.'>

    MATableDescription class >> defaultColumnLabels [
	<category: 'accessing-defaults'>
	^OrderedCollection 
	    with: 'a'
	    with: 'b'
	    with: 'c'
    ]

    MATableDescription class >> defaultRowLabels [
	<category: 'accessing-defaults'>
	^OrderedCollection 
	    with: '1'
	    with: '2'
	    with: '3'
    ]

    MATableDescription class >> descriptionColumnLabels [
	<category: 'accessing-description'>
	^(MAMemoDescription new)
	    accessor: #columnLabelsTextual;
	    label: 'Column Labels';
	    priority: 250;
	    yourself
    ]

    MATableDescription class >> descriptionDefault [
	<category: 'accessing-description'>
	^nil
    ]

    MATableDescription class >> descriptionRequired [
	<category: 'accessing-description'>
	^nil
    ]

    MATableDescription class >> descriptionRowLabels [
	<category: 'accessing-description'>
	^(MAMemoDescription new)
	    accessor: #rowLabelsTextual;
	    label: 'Row Labels';
	    priority: 250;
	    yourself
    ]

    MATableDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MATableDescription class >> label [
	<category: 'accessing'>
	^'Table'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitTableDescription: self
    ]

    columnCount [
	<category: 'accessing'>
	^self columnLabels size
    ]

    columnLabels [
	<category: 'accessing-properties'>
	^self propertyAt: #columnLabels ifAbsent: [self class defaultColumnLabels]
    ]

    columnLabels: aCollection [
	<category: 'accessing-properties'>
	self propertyAt: #columnLabels put: aCollection
    ]

    columnLabelsTextual [
	<category: 'accessing-textual'>
	^(MAStringDescription new toStringCollection: self columnLabels) 
	    asMultilineString
    ]

    columnLabelsTextual: aString [
	<category: 'accessing-textual'>
	self 
	    columnLabels: (MAStringDescription new fromStringCollection: aString lines)
    ]

    kind [
	<category: 'accessing'>
	^MATableModel
    ]

    rowCount [
	<category: 'accessing'>
	^self rowLabels size
    ]

    rowLabels [
	<category: 'accessing-properties'>
	^self propertyAt: #rowLabels ifAbsent: [self class defaultRowLabels]
    ]

    rowLabels: aCollection [
	<category: 'accessing-properties'>
	self propertyAt: #rowLabels put: aCollection
    ]

    rowLabelsTextual [
	<category: 'accessing-textual'>
	^(MAStringDescription new toStringCollection: self rowLabels) 
	    asMultilineString
    ]

    rowLabelsTextual: aString [
	<category: 'accessing-textual'>
	self 
	    rowLabels: (MAStringDescription new fromStringCollection: aString lines)
    ]

    validateSpecific: anObject [
	<category: 'validation-private'>
	super validateSpecific: anObject.
	(anObject rowCount ~= self rowCount 
	    or: [anObject columnCount ~= self columnCount]) 
		ifTrue: [MAKindError description: self signal: self kindErrorMessage]
    ]
]



MAReferenceDescription subclass: MATokenDescription [
    | tokens |
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of tokens all described by the referenced description, possible values are instances of ==SequenceableCollection==.'>

    MATokenDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MATokenDescription class >> label [
	<category: 'accessing'>
	^'Token'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitTokenDescription: self
    ]

    kind [
	<category: 'accessing-dynamic'>
	^Array
    ]

    tokens [
	<category: 'accessing'>
	^tokens ifNil: [tokens := #()]
    ]

    tokens: anArray [
	<category: 'accessing'>
	tokens := anArray
    ]
]



MAElementDescription subclass: MAStringDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of strings, possible values are instances of ==String==. My visual representation could be a single line text-field. Use ==*MAMemoDescription*== for multi-line strings.'>

    MAStringDescription class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    MAStringDescription class >> label [
	<category: 'accessing'>
	^'String'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitStringDescription: self
    ]

    isSortable [
	<category: 'testing'>
	^true
    ]

    kind [
	<category: 'accessing'>
	^String
    ]
]



MAStringDescription subclass: MAMemoDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of multiline strings, possible values are instances of ==String==. My visual representation could be a text-area field.'>

    MAMemoDescription class >> defaultLineCount [
	<category: 'accessing-defaults'>
	^3
    ]

    MAMemoDescription class >> descriptionLineCount [
	<category: 'accessing-description'>
	^(MANumberDescription new)
	    accessor: #lineCount;
	    label: 'Number of Lines';
	    priority: 400;
	    default: self defaultLineCount;
	    beInteger;
	    min: 1;
	    yourself
    ]

    MAMemoDescription class >> label [
	<category: 'accessing'>
	^'Memo'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitMemoDescription: self
    ]

    lineCount [
	<category: 'accessing-properties'>
	^self propertyAt: #lineCount ifAbsent: [self class defaultLineCount]
    ]

    lineCount: anInteger [
	<category: 'accessing-properties'>
	^self propertyAt: #lineCount put: anInteger
    ]
]



MAStringDescription subclass: MAPasswordDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of a password string, possible values are instances of ==String==. My visual representation could be a password field, where there are stars printed instead of the characters the user enters.'>

    MAPasswordDescription class >> label [
	<category: 'accessing'>
	^'Password'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitPasswordDescription: self
    ]

    isObfuscated: anObject [
	<category: 'testing'>
	^anObject notNil and: 
		[anObject isString 
		    and: [anObject isEmpty not and: [anObject allSatisfy: [:each | each = $*]]]]
    ]

    isSortable [
	<category: 'testing'>
	^false
    ]

    obfuscated: anObject [
	<category: 'operators'>
	^String new: (self toString: anObject) size withAll: $*
    ]
]



MAStringDescription subclass: MASymbolDescription [
    
    <category: 'Magritte-Model-Description'>
    <comment: 'I am a description of symbols, possible values are instances of ==Symbol==.'>

    MASymbolDescription class >> label [
	<category: 'accessing'>
	^'Symbol'
    ]

    acceptMagritte: aVisitor [
	<category: 'visiting'>
	aVisitor visitSymbolDescription: self
    ]

    kind [
	<category: 'accessing'>
	^Symbol
    ]
]



MAObject subclass: MAMemento [
    | model description |
    
    <category: 'Magritte-Model-Memento'>
    <comment: 'I am an abstract memento. I reference a model I am working on and the description currently used to describe this model.'>

    MAMemento class >> model: aModel [
	<category: 'instance creation'>
	^self model: aModel description: aModel description
    ]

    MAMemento class >> model: aModel description: aDescription [
	<category: 'instance creation'>
	^(self new)
	    setModel: aModel;
	    setDescription: aDescription;
	    reset;
	    yourself
    ]

    commit [
	"Commit the receiver into the model."

	<category: 'actions'>
	
    ]

    description [
	<category: 'accessing'>
	^description
    ]

    isDifferent: firstDictionary to: secondDictionary [
	<category: 'private'>
	| firstValue secondValue |
	self description do: 
		[:each | 
		(each isVisible and: [each isReadonly not]) 
		    ifTrue: 
			[firstValue := firstDictionary at: each ifAbsent: [nil].
			secondValue := secondDictionary at: each ifAbsent: [nil].
			firstValue = secondValue ifFalse: [^true]]].
	^false
    ]

    model [
	<category: 'accessing'>
	^model
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPutAll: ' model: ';
	    print: self model
    ]

    pull [
	"Utitlity method to pull the model into a dictionary mapping descriptions to values. nil values are replaced with the default ones of the model."

	<category: 'private'>
	| result |
	result := self pullRaw.
	result keysAndValuesDo: 
		[:key :value | 
		value isNil ifTrue: [result at: key put: key default yourself]].
	^result
    ]

    pullRaw [
	<category: 'private'>
	| result |
	result := Dictionary new.
	self description 
	    do: [:each | result at: each put: (self model readUsing: each)].
	^result
    ]

    push: aDictionary [
	"Utitlity method to push a dictionary mapping descriptions to values into the model."

	<category: 'private'>
	aDictionary keysAndValuesDo: 
		[:key :value | 
		(key isVisible and: [key isReadonly not]) 
		    ifTrue: [self model write: value using: key]]
    ]

    reset [
	"Reset the memento from the model."

	<category: 'actions'>
	
    ]

    setDescription: aDescription [
	<category: 'initialization'>
	description := aDescription
    ]

    setModel: aModel [
	<category: 'initialization'>
	model := aModel
    ]

    validate [
	"Check if the data in the receiver would be valid if committed. In case of problems an exception is raised."

	<category: 'actions'>
	self description validate: self
    ]
]



MAMemento subclass: MACachedMemento [
    | cache |
    
    <category: 'Magritte-Model-Memento'>
    <comment: 'I cache values being read and written without touching the model. When committing changes, the modifications will be propagated to the model all at once.'>

    MACachedMemento class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    cache [
	<category: 'accessing'>
	^cache
    ]

    commit [
	<category: 'actions'>
	super commit.
	self push: self cache.
	self reset
    ]

    hasChanged [
	"Answer ==true==, if the cached data is different to the data in the model."

	<category: 'testing'>
	^self isDifferent: self cache to: self pullRaw
    ]

    readUsing: aDescription [
	<category: 'private'>
	^self cache at: aDescription
    ]

    reset [
	<category: 'actions'>
	super reset.
	self setCache: self pull
    ]

    setCache: aDictionary [
	<category: 'initialization'>
	cache := aDictionary
    ]

    write: anObject using: aDescription [
	<category: 'private'>
	self cache at: aDescription put: anObject
    ]
]



MACachedMemento subclass: MACheckedMemento [
    | original |
    
    <category: 'Magritte-Model-Memento'>
    <comment: 'I cache values as my superclass and also remember the original values of the model at the time the cache is built. With this information I am able to detect edit conflicts and can prevent accidental loss of data by merging the changes.'>

    hasConflict [
	"Answer ==true==, if there is an edit conflict."

	<category: 'testing'>
	^self hasChanged and: [self isDifferent: self original to: self pullRaw]
    ]

    original [
	<category: 'accessing'>
	^original
    ]

    reset [
	<category: 'actions'>
	super reset.
	self setOriginal: self pullRaw
    ]

    setOriginal: aDictionary [
	<category: 'initialization'>
	original := aDictionary
    ]

    validate [
	<category: 'actions'>
	self hasConflict ifFalse: [^super validate].
	self reset.
	MAConflictError description: self description
	    signal: self description conflictErrorMessage
    ]
]



MAMemento subclass: MAStraitMemento [
    
    <category: 'Magritte-Model-Memento'>
    <comment: 'I am a memento that forwards read- and write-access directly to the model. I can mostly be replaced with the model itself.'>

    MAStraitMemento class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    readUsing: aDescription [
	<category: 'private'>
	^(self model readUsing: aDescription) ifNil: [aDescription default]
    ]

    write: anObject using: aDescription [
	<category: 'private'>
	self model write: anObject using: aDescription
    ]
]



Object subclass: MASortBlock [
    | accessor selector |
    
    <category: 'Magritte-Model-Utility'>
    <comment: nil>

    MASortBlock class >> accessor: anAccessor selector: aSelector [
	<category: 'instance-creation'>
	^self basicNew initializeAccessor: anAccessor selector: aSelector
    ]

    MASortBlock class >> selector: aSelector [
	<category: 'instance-creation'>
	^self accessor: MAIdentityAccessor new selector: aSelector
    ]

    fixTemps [
	<category: 'actions'>
	
    ]

    initializeAccessor: anAccessor selector: aSelector [
	<category: 'initialize-release'>
	accessor := anAccessor asAccessor.
	selector := aSelector
    ]

    value: aFirstObject value: aSecondObject [
	<category: 'evaluating'>
	^(accessor read: aFirstObject) perform: selector
	    with: (accessor read: aSecondObject)
    ]
]



Object subclass: MATableModel [
    | rowCount columnCount contents |
    
    <category: 'Magritte-Model-Models'>
    <comment: 'I am a model class representing a table within the Magritte framework. Internally I store my cells within a flat array, however users may access data giving ''''row'''' and ''''column'''' coordinates with ==#at:at:== and ==#at:at:put:==. I can support reshaping myself, but of course this might lead to loss of data-cells.'>

    MATableModel class >> rows: aRowCount columns: aColumnCount [
	<category: 'instance-creation'>
	^self 
	    rows: aRowCount
	    columns: aColumnCount
	    contents: (Array new: aRowCount * aColumnCount)
    ]

    MATableModel class >> rows: aRowCount columns: aColumnCount contents: anArray [
	<category: 'instance-creation'>
	^(self new)
	    setRowCount: aRowCount;
	    setColumnCount: aColumnCount;
	    setContents: anArray;
	    yourself
    ]

    = aTable [
	<category: 'comparing'>
	^self species = aTable species and: 
		[self rowCount = aTable rowCount and: 
			[self columnCount = aTable columnCount 
			    and: [self contents = aTable contents]]]
    ]

    at: aRowIndex at: aColumnIndex [
	"Answer the contents of ==aRowIndex== and ==aColumnIndex==. Raises an error if the coordinates are out of bounds."

	<category: 'accessing'>
	self checkAt: aRowIndex at: aColumnIndex.
	^self uncheckedAt: aRowIndex at: aColumnIndex
    ]

    at: aRowIndex at: aColumnIndex put: aValue [
	"Set the contents of ==aRowIndex== and ==aColumnIndex==> to ==aValue==. Raises an error if the coordinates are out of bounds."

	<category: 'accessing'>
	self checkAt: aRowIndex at: aColumnIndex.
	^self 
	    uncheckedAt: aRowIndex
	    at: aColumnIndex
	    put: aValue
    ]

    checkAt: aRowIndex at: aColumnIndex [
	<category: 'private'>
	(aRowIndex between: 1 and: self rowCount) 
	    ifFalse: [self error: 'Row subscript out of range.'].
	(aColumnIndex between: 1 and: self columnCount) 
	    ifFalse: [self error: 'Column subscript out of range.']
    ]

    collect: aBlock [
	<category: 'enumeration'>
	| copy |
	copy := self copyEmpty.
	self do: 
		[:row :col :val | 
		copy 
		    at: row
		    at: col
		    put: (aBlock 
			    value: row
			    value: col
			    value: val)].
	^copy
    ]

    columnCount [
	"Answer the column count of the table."

	<category: 'accessing'>
	^columnCount
    ]

    contents [
	<category: 'accessing'>
	^contents
    ]

    copyEmpty [
	<category: 'copying'>
	^self class rows: self rowCount columns: self columnCount
    ]

    copyRows: aRowCount columns: aColumnCount [
	<category: 'copying'>
	| table |
	table := self class rows: aRowCount columns: aColumnCount.
	1 to: (self rowCount min: aRowCount)
	    do: 
		[:row | 
		1 to: (self columnCount min: aColumnCount)
		    do: 
			[:col | 
			table 
			    uncheckedAt: row
			    at: col
			    put: (self uncheckedAt: row at: col)]].
	^table
    ]

    do: aBlock [
	<category: 'enumeration'>
	1 to: self rowCount
	    do: 
		[:row | 
		1 to: self columnCount
		    do: 
			[:col | 
			aBlock 
			    value: row
			    value: col
			    value: (self uncheckedAt: row at: col)]]
    ]

    hash [
	<category: 'comparing'>
	^self contents hash
    ]

    indexAt: aRowIndex at: aColumnIndex [
	<category: 'private'>
	^(aRowIndex - 1) * self columnCount + aColumnIndex
    ]

    pointAt: anIndex [
	<category: 'private'>
	^Point x: (anIndex - 1) // self columnCount + 1
	    y: (anIndex - 1) \\ self columnCount + 1
    ]

    postCopy [
	<category: 'copying'>
	super postCopy.
	self setContents: self contents copy
    ]

    reshapeRows: aRowCount columns: aColumnCount [
	"Change the size of the receiving table to ==aRowCount== times ==aColumnCount==, throwing away elements that are cut off and initializing empty cells with ==nil==."

	<category: 'operations'>
	self 
	    setContents: (self copyRows: aRowCount columns: aColumnCount) contents.
	self
	    setRowCount: aRowCount;
	    setColumnCount: aColumnCount
    ]

    rowCount [
	"Answer the row count of the table."

	<category: 'accessing'>
	^rowCount
    ]

    setColumnCount: anInteger [
	<category: 'initialization'>
	columnCount := anInteger
    ]

    setContents: anArray [
	<category: 'initialization'>
	contents := anArray
    ]

    setRowCount: anInteger [
	<category: 'initialization'>
	rowCount := anInteger
    ]

    uncheckedAt: aRowIndex at: aColumnIndex [
	<category: 'accessing'>
	^self contents at: (self indexAt: aRowIndex at: aColumnIndex)
    ]

    uncheckedAt: aRowIndex at: aColumnIndex put: aValue [
	<category: 'accessing'>
	^self contents at: (self indexAt: aRowIndex at: aColumnIndex) put: aValue
    ]
]



Object subclass: MAVisitor [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: 'I am a visitor responsible to visit Magritte descriptions. I am an abstract class providing a default implementation for concrete visitors. The protocol I am implementing reflects the hierarchy of *MADescription* with its subclasses so that visiting a specific class automatically calls less specific implementations in case the specific implementation has been left out. The code was automatically created using code on my class-side.'>

    MAVisitor class >> buildVisitorHierarchyForClass: aClass selector: aBlock classified: aSelector [
	"self buildVisitorHierarchyForClass: MADescription selector: [ :class | 'visit' , (class name allButFirst: 2) , ':' ] classified: #'visiting-description'"

	<category: 'private'>
	aClass withAllSubclassesDo: 
		[:class | 
		(class category startsWith: 'Magritte') 
		    ifTrue: 
			[self 
			    compile: (String streamContents: 
					[:stream | 
					stream
					    nextPutAll: (aBlock value: class);
					    nextPutAll: ' anObject';
					    cr.
					class = aClass 
					    ifFalse: 
						[stream
						    tab;
						    nextPutAll: 'self ';
						    nextPutAll: (aBlock value: class superclass);
						    nextPutAll: ' anObject.']])
			    classified: aSelector.
			class 
			    compile: (String streamContents: 
					[:stream | 
					stream
					    nextPutAll: 'acceptMagritte: aVisitor';
					    cr.
					stream
					    tab;
					    nextPutAll: 'aVisitor ';
					    nextPutAll: (aBlock value: class);
					    nextPutAll: ' self.'])
			    classified: #visiting]]
    ]

    visit: anObject [
	"Visit ==anObject== with the receiving visitor."

	<category: 'visiting'>
	anObject acceptMagritte: self
    ]

    visitAll: aCollection [
	"Visit all elements of ==aCollection== with the receiving visitor."

	<category: 'visiting'>
	aCollection do: [:each | self visit: each]
    ]

    visitBooleanDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitClassDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitContainer: anObject [
	<category: 'visiting-description'>
	self visitDescription: anObject
    ]

    visitDateDescription: anObject [
	<category: 'visiting-description'>
	self visitMagnitudeDescription: anObject
    ]

    visitDescription: anObject [
	<category: 'visiting-description'>
	
    ]

    visitDurationDescription: anObject [
	<category: 'visiting-description'>
	self visitMagnitudeDescription: anObject
    ]

    visitElementDescription: anObject [
	<category: 'visiting-description'>
	self visitDescription: anObject
    ]

    visitFileDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitMagnitudeDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitMemoDescription: anObject [
	<category: 'visiting-description'>
	self visitStringDescription: anObject
    ]

    visitMultipleOptionDescription: anObject [
	<category: 'visiting-description'>
	self visitOptionDescription: anObject
    ]

    visitNumberDescription: anObject [
	<category: 'visiting-description'>
	self visitMagnitudeDescription: anObject
    ]

    visitOptionDescription: anObject [
	<category: 'visiting-description'>
	self visitReferenceDescription: anObject
    ]

    visitPasswordDescription: anObject [
	<category: 'visiting-description'>
	self visitStringDescription: anObject
    ]

    visitPriorityContainer: anObject [
	<category: 'visiting-description'>
	self visitContainer: anObject
    ]

    visitReferenceDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitRelationDescription: anObject [
	<category: 'visiting-description'>
	self visitReferenceDescription: anObject
    ]

    visitReportContainer: anObject [
	<category: 'visiting-description'>
	self visitContainer: anObject
    ]

    visitSingleOptionDescription: anObject [
	<category: 'visiting-description'>
	self visitOptionDescription: anObject
    ]

    visitStringDescription: anObject [
	<category: 'visiting-description'>
	self visitElementDescription: anObject
    ]

    visitSymbolDescription: anObject [
	<category: 'visiting-description'>
	self visitStringDescription: anObject
    ]

    visitTableDescription: anObject [
	<category: 'visiting-description'>
	self visitReferenceDescription: anObject
    ]

    visitTableReference: anObject [
	<category: 'visiting-description'>
	^self visitReferenceDescription: anObject
    ]

    visitTimeDescription: anObject [
	<category: 'visiting-description'>
	self visitMagnitudeDescription: anObject
    ]

    visitTimeStampDescription: anObject [
	<category: 'visiting-description'>
	self visitMagnitudeDescription: anObject
    ]

    visitToManyRelationDescription: anObject [
	<category: 'visiting-description'>
	self visitRelationDescription: anObject
    ]

    visitToManyScalarRelationDescription: anObject [
	<category: 'visiting-description'>
	self visitToManyRelationDescription: anObject
    ]

    visitToOneRelationDescription: anObject [
	<category: 'visiting-description'>
	self visitRelationDescription: anObject
    ]

    visitTokenDescription: anObject [
	<category: 'visiting-description'>
	self visitReferenceDescription: anObject
    ]
]



MAVisitor subclass: MAGraphVisitor [
    | seen object |
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    initialize [
	<category: 'initialization'>
	super initialize.
	seen := IdentitySet new
    ]

    object [
	<category: 'accessing'>
	^object
    ]

    use: anObject during: aBlock [
	<category: 'private'>
	| previous |
	(seen includes: anObject) ifTrue: [^self].
	anObject isNil ifFalse: [seen add: anObject].
	previous := object.
	object := anObject.
	aBlock ensure: [object := previous]
    ]
]



MAGraphVisitor subclass: MAValidatorVisitor [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    MAValidatorVisitor class >> on: anObject description: aDescription [
	<category: 'instance-creation'>
	^self new on: anObject description: aDescription
    ]

    on: anObject description: aDescription [
	<category: 'initialization'>
	self use: anObject during: [self visit: aDescription]
    ]

    validate: anObject using: aDescription [
	<category: 'private'>
	aDescription validateRequired: anObject.
	anObject ifNil: [^self].
	aDescription
	    validateKind: anObject;
	    validateSpecific: anObject;
	    validateConditions: anObject
    ]

    visit: aDescription [
	<category: 'visiting'>
	(aDescription isVisible and: [aDescription isReadonly not]) 
	    ifTrue: [super visit: aDescription]
    ]

    visitContainer: aDescription [
	<category: 'visiting-descriptions'>
	super visitContainer: aDescription.
	self object ifNil: [^self].
	aDescription 
	    do: [:each | self use: (object readUsing: each) during: [self visit: each]]
    ]

    visitDescription: aDescription [
	"Validate the current object using aDescription within an exception handler to avoid running further tests that might cause error-cascades."

	<category: 'visiting-descriptions'>
	[self validate: self object using: aDescription] on: MAValidationError
	    do: 
		[:err |
		err isResumable ifFalse: [err beResumable].
		err pass]
    ]

    visitTableDescription: aDescription [
	<category: 'visiting-descriptions'>
	super visitTableDescription: aDescription.
	self object ifNil: [^self].
	self object contents 
	    do: [:each | self use: each during: [self visit: aDescription reference]]
    ]
]



MAVisitor subclass: MAStreamingVisitor [
    | stream object |
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    contents [
	<category: 'streaming'>
	^self stream contents
    ]

    object [
	<category: 'accessing'>
	^object
    ]

    object: anObject [
	<category: 'accessing'>
	object := anObject
    ]

    object: anObject during: aBlock [
	<category: 'private'>
	| previous |
	previous := self object.
	self object: anObject.
	aBlock ensure: [self object: previous]
    ]

    stream [
	<category: 'accessing'>
	^stream
    ]

    stream: aStream [
	<category: 'accessing'>
	stream := aStream
    ]
]



MAStreamingVisitor subclass: MAReader [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    MAReader class >> read: aStream description: aDescription [
	<category: 'instance creation'>
	^self new read: aStream description: aDescription
    ]

    error: aString [
	<category: 'private'>
	MAReadError signal: aString
    ]

    read: aStream description: aDescription [
	<category: 'visiting'>
	self
	    stream: aStream;
	    visit: aDescription.
	^self object
    ]
]



MAReader subclass: MAStringReader [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    read: aStream description: aDescription [
	<category: 'visiting'>
	^aStream atEnd ifFalse: [super read: aStream description: aDescription]
    ]

    visitBooleanDescription: aDescription [
	<category: 'visiting-description'>
	(aDescription trueString = self contents 
	    or: [aDescription trueStrings includes: self contents]) 
		ifTrue: [^self object: true].
	(aDescription falseString = self contents 
	    or: [aDescription falseStrings includes: self contents]) 
		ifTrue: [^self object: false].
	MAReadError signal
    ]

    visitClassDescription: aDescription [
	<category: 'visiting-description'>
	self shouldNotImplement
    ]

    visitContainer: anObject [
	<category: 'visiting-description'>
	self shouldNotImplement
    ]

    visitDurationDescription: aDescription [
	<category: 'visiting-description'>
	| contents |
	contents := self contents.
	contents isEmpty ifTrue: [MAReadError signal].
	(contents occurrencesOf: $-) > 1 ifTrue: [MAReadError signal].
	(contents indexOf: $-) > 1 ifTrue: [MAReadError signal].
	(contents occurrencesOf: $.) > 1 ifTrue: [MAReadError signal].
	(contents allSatisfy: [:each | '-0123456789.:' includes: each]) 
	    ifFalse: [MAReadError signal].
	super visitDurationDescription: aDescription
    ]

    visitElementDescription: aDescription [
	"This implementation can be very dangerous and might lead to a potential security hole (this is tested), since the default implementation of #readFrom: in Object evaluates the expression to find its value. Most subclasses like Number, Date, Time, ... override this implementation, but some others (like Boolean) do not."

	<category: 'visiting-description'>
	self object: ([aDescription kind readFrom: self stream] on: Error
		    do: [:err | MAReadError signal: err messageText])
    ]

    visitFileDescription: aDescription [
	<category: 'visiting-description'>
	self shouldNotImplement
    ]

    visitMultipleOptionDescription: aDescription [
	<category: 'visiting-description'>
	self 
	    object: (Array streamContents: 
			[:output | 
			[self stream atEnd] whileFalse: 
				[output 
				    nextPut: (aDescription reference fromString: (self stream upTo: $,)).
				self stream peek = Character space ifTrue: [self stream next]]])
    ]

    visitNumberDescription: aDescription [
	<category: 'visiting-description'>
	| contents |
	contents := self contents.
	contents isEmpty ifTrue: [MAReadError signal].
	(contents occurrencesOf: $-) > 1 ifTrue: [MAReadError signal].
	(contents indexOf: $-) > 1 ifTrue: [MAReadError signal].
	(contents occurrencesOf: $.) > 1 ifTrue: [MAReadError signal].
	(contents allSatisfy: [:each | '+-0123456789.eE' includes: each]) 
	    ifFalse: [MAReadError signal].
	super visitNumberDescription: aDescription
    ]

    visitRelationDescription: aDescription [
	<category: 'visiting-description'>
	self shouldNotImplement
    ]

    visitSingleOptionDescription: aDescription [
	<category: 'visiting-description'>
	self visit: aDescription reference
    ]

    visitStringDescription: aDescription [
	<category: 'visiting-description'>
	self object: self contents
    ]

    visitSymbolDescription: aDescription [
	<category: 'visiting-description'>
	self object: self contents asSymbol
    ]

    visitTableDescription: aDescription [
	<category: 'visiting-description'>
	self shouldNotImplement
    ]

    visitTimeDescription: aDescription [
	<category: 'visiting-description'>
	| string |
	string := self contents.
	(string notEmpty 
	    and: [string allSatisfy: [:each | '0123456789: apm' includes: each]]) 
		ifFalse: [MAReadError signal].
	self object: (aDescription kind readFrom: string readStream)
    ]

    visitTokenDescription: aDescription [
	<category: 'visiting-description'>
	self 
	    object: (aDescription kind streamContents: 
			[:output | 
			[self stream atEnd] whileFalse: 
				[output 
				    nextPut: (aDescription reference fromString: (self stream upTo: $ ))]])
    ]
]



MAStreamingVisitor subclass: MAWriter [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    MAWriter class >> write: anObject [
	<category: 'instance creation'>
	^self new write: anObject
    ]

    MAWriter class >> write: anObject description: aDescription [
	<category: 'instance creation'>
	^self new write: anObject description: aDescription
    ]

    MAWriter class >> write: anObject description: aDescription to: aStream [
	<category: 'instance creation'>
	^self new 
	    write: anObject
	    description: aDescription
	    to: aStream
    ]

    defaultWriteStream [
	<category: 'private'>
	self subclassResponsibility
    ]

    error: aString [
	<category: 'private'>
	MAWriteError signal: aString
    ]

    write: anObject [
	<category: 'visiting'>
	^self write: anObject description: anObject description
    ]

    write: anObject description: aDescription [
	<category: 'visiting'>
	^self 
	    write: anObject
	    description: aDescription
	    to: self defaultWriteStream
    ]

    write: anObject description: aDescription to: aStream [
	<category: 'visiting'>
	self
	    object: anObject;
	    stream: aStream;
	    visit: aDescription.
	^self contents
    ]
]



MAWriter subclass: MAStringWriter [
    
    <category: 'Magritte-Model-Visitor'>
    <comment: nil>

    defaultWriteStream [
	<category: 'private'>
	^String new writeStream
    ]

    visitBooleanDescription: aDescription [
	<category: 'visiting-description'>
	self stream nextPutAll: (self object 
		    ifTrue: [aDescription trueString]
		    ifFalse: [aDescription falseString])
    ]

    visitClassDescription: aDescription [
	<category: 'visiting-description'>
	self stream nextPutAll: self object label
    ]

    visitContainer: aDescription [
	<category: 'visiting-description'>
	aDescription do: 
		[:each | 
		each isVisible 
		    ifTrue: 
			[each stringWriter 
			    write: (self object readUsing: each)
			    description: each
			    to: stream.
			^self]]
    ]

    visitElementDescription: aDescription [
	<category: 'visiting-description'>
	self stream nextPutAll: self object asString
    ]

    visitFileDescription: aDescription [
	<category: 'visiting-description'>
	self stream nextPutAll: self object filename
    ]

    visitMultipleOptionDescription: aDescription [
	<category: 'visiting-description'>
	self object 
	    do: [:each | self object: each during: [self visit: aDescription reference]]
	    separatedBy: [self stream nextPutAll: ', ']
    ]

    visitSingleOptionDescription: aDescription [
	<category: 'visiting-description'>
	self visit: aDescription reference
    ]

    visitTimeDescription: aDescription [
	<category: 'visiting-description'>
	self object 
	    print24: true
	    showSeconds: true
	    on: self stream
    ]

    visitTimeStampDescription: aDescription [
	<category: 'visiting-description'>
	(self stream)
	    print: self object asDate;
	    space.
	self stream print: self object asTime
    ]

    visitToManyRelationDescription: aDescription [
	<category: 'visiting-description'>
	self object 
	    do: [:each | self object: each during: [self visit: each description]]
	    separatedBy: [self stream nextPutAll: ', ']
    ]

    visitToOneRelationDescription: aDescription [
	<category: 'visiting-description'>
	self visit: self object description
    ]

    visitTokenDescription: aDescription [
	<category: 'visiting-description'>
	self object 
	    do: [:each | self object: each during: [self visit: aDescription reference]]
	    separatedBy: [self stream nextPutAll: ' ']
    ]

    write: anObject description: aDescription to: aStream [
	<category: 'visiting'>
	anObject isNil ifTrue: [^aDescription undefined].
	^super 
	    write: anObject
	    description: aDescription
	    to: aStream
    ]
]



Object class extend [

    description [
	<category: '*magritte-model-accessing'>
	^Magritte.MADescriptionBuilder for: self
    ]

]



Object extend [

    description [
	"Return the description of the reciever. Subclasses might override this message to return instance-based descriptions."

	<category: '*magritte-model-accessing'>
	^self class description
    ]

    isDescription [
	<category: '*magritte-model-testing'>
	^false
    ]

    mementoClass [
	"Return a class to be used to remember or cache the receiver, namely a memento object."

	<category: '*magritte-model-accessing'>
	^Magritte.MACheckedMemento
    ]

    readUsing: aDescription [
	"Dispatch the read-access to the receiver using the accessor of aDescription."

	<category: '*magritte-model-model'>
	^aDescription accessor read: self
    ]

    write: anObject using: aDescription [
	"Dispatch the write-access to the receiver of anObject using the accessor of aDescription."

	<category: '*magritte-model-model'>
	aDescription accessor write: anObject to: self
    ]

]



UndefinedObject extend [

    asAccessor [
	<category: '*magritte-model-converting'>
	^Magritte.MANullAccessor new
    ]

    label [
	<category: '*magritte-model-accessing'>
	^'n/a'
    ]

]



Integer extend [

    asFileSize [
	<category: '*magritte-model-converting'>
	#('B' 'KB' 'MB' 'GB' 'TB' 'PB' 'EB' 'ZB' 'YB') inject: self
	    into: 
		[:value :each | 
		value < 1024 
		    ifFalse: [value // 1024]
		    ifTrue: [^value asString , ' ' , each]]
    ]

]



Eval [
    MADescriptionBuilder initialize.
    MAExternalFileModel initialize.
    MAFileModel initialize.
    MAObject initialize
]

PK    �Mh@W�Nle  �    PORTINGUT	 dqXOÉXOux �  �  �UMo�F��W�H�#�����NQ5͡h�9"�^K+,�����d6�=I��|3o���ZE��P˕Pߩ�N}4��on�䥕�(>9ik"=���v��X�Tb%
Jo�h����V��KmBD<��LT������z��HuB�v��{���Rǭ)���2�9Ѡ=�Mh^+��k_7��TZ��S�Bv^N����HBǥP�ȵ71JvCi )~�ŕ�/SR	w(�H���.N��
�%�7�L K�-^9�����өy��~���ڜ����pjkM�b��zYz�S�W����N�ј����~,z0�v?��I�94�;�W/?�0�҃���}�͘h�N��������kv�oN\ ���➣��'��[r��e�Ƈ�0��7ʅˆ�Y)
J�kj%6Z]
зW��g��P*r�b��{��l͓)���j�|����..���yf9Q��XN&P�8�mȸ+���`*Y�u�WZ�ָ�i)`���A�J$��*:�`�G�N�qS^��M�N�~�.��x��Z���K�~��X�zv$ִ�!�xP��D�8A�l �����᣽V�،����f�s��0�G����8a��~~>*D��:�u*GVS"��t1di�?��X��!{�8�j)+W�!>���b�I����H]�R�����th�9�}&o�7��q�q�;��@t�[�Tl H��D�����s�B��S��:�S��Y���0�2&���Q��Ꟊ�w��n�2!��������8�?SRϤ���`=�0��|��iKW�$Ӧ?��fsF ���ی4�;��f�]���lֻ
�܋����r�����(Z�^�4���vo���_PK
     �[h@x�>=  =    package.xmlUT	 ÉXOÉXOux �  �  <package>
  <name>Magritte</name>
  <namespace>Magritte</namespace>
  <test>
    <namespace>Magritte</namespace>
    <prereq>Magritte</prereq>
    <prereq>SUnit</prereq>
    <sunit>Magritte.MAAdaptiveModelTest*
	Magritte.MADescriptionBuilderTest*
	Magritte.MADynamicObjectTest*
	Magritte.MAExtensionsTest*
	Magritte.MAFileModelTest*
	Magritte.MAObjectTest*
	Magritte.MATableModelTest*</sunit>
    <filein>magritte-tests.st</filein>
  </test>

  <filein>magritte-gst.st</filein>
  <filein>magritte-model.st</filein>
  <file>PORTING</file>
  <file>ChangeLog</file>
</package>PK
     �Mh@�I��'  �'    magritte-gst.stUT	 dqXOÉXOux �  �  "======================================================================
|
|   Magritte compatibility methods for GNU Smalltalk
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



Object subclass: MACompatibility [
    
    <category: 'Magritte-Model-Core'>
    <comment: 'I am providing all the platform compatibility code on my class side, so that porting to different Smalltalk dialects can concentrate in a single place.'>

    ShowLicense := false.

    MACompatibility class >> allSubInstancesOf: aClass do: aBlock [
	"Evaluate the aBlock for all instances of aClass and all its subclasses."

	<category: 'environment'>
	aClass allSubinstancesDo: aBlock
    ]

    MACompatibility class >> classNamed: aString [
	"Return the class named aString, nil if the class can't be found."

	<category: 'environment'>
	^(aString subStrings: $.) inject: Smalltalk into: [ :old :each |
	    old at: each asSymbol ifAbsent: [ ^nil ] ]
    ]

    MACompatibility class >> openWorkspace: aContentsString titled: aTitleString [
	"Open a new wokspace with the contents aContentsString and the title aTitleString."

	ShowLicense ifFalse: [ ^self ].
	('%1

%2
' % { aTitleString asUppercase. aContentsString }) displayOn: stderr
    ]

    MACompatibility class >> referenceStream: aReadWriteStream [
	"Return a stream instance to operate on aReadWriteStream being able to serialize and deserialize objects by sending #nextPut: and #next. Squeak: The implementation of ReferenceStream doesn't work well together with the default WriteStream implementaiton, therefor we have to change it on the fly."

	<category: 'environment'>
	^ObjectDumper on: aReadWriteStream
    ]

    MACompatibility class >> uuid [
	"Answer a random object that is extremly likely to be unique over space and time."

	<category: 'environment'>
	^UUID new
    ]
]



ByteArray subclass: UUID [
    
    <shape: #byte>
    <category: 'Seaside-Core-Utilities'>
    <comment: 'I am a UUID.  Sending #new generates a UUIDv1.'>

    Node := nil.
    SequenceValue := nil.
    LastTime := nil.
    Generator := nil.
    GeneratorMutex := nil.

    UUID class >> timeValue [
	"Returns the time value for a UUIDv1, in 100 nanoseconds units
	 since 1-1-1601."
	^((Time utcSecondClock + (109572 * 86400)) * 1000
	    + Time millisecondClock) * 10000
    ]

    UUID class >> randomNodeValue [
	"Return the node value for a UUIDv1."
	| n |
	"TODO: use some kind of digest to produce cryptographically strong
	 random numbers."
	n := Generator between: 0 and: 16rFFFF.
	n := (n bitShift: 16) bitOr: (Generator between: 0 and: 16rFFFF).
	n := (n bitShift: 16) bitOr: (Generator between: 0 and: 16rFFFF).
	^n bitOr: 1
    ]

    UUID class >> update: aSymbol [
	"Update the sequence value of a UUIDv1 when an image is restarted."

	aSymbol == #returnFromSnapshot ifTrue: [
	    "You cannot be sure that the node ID is the same."
	    GeneratorMutex critical: [
		Generator := Random new.
		LastTime := self timeValue.
		Node := self randomNodeValue.
		SequenceValue := (SequenceValue + 1) bitAnd: 16383 ]].
    ]

    UUID class >> defaultSize [
	"Return the size of a UUIDv1."

	<category: 'private'>
	^16
    ]

    UUID class >> initialize [
	"Initialize the class."

	<category: 'initialization'>
	ObjectMemory addDependent: self.
	Generator := Random new.
	LastTime := self timeValue.
	Node := self randomNodeValue.
	SequenceValue := Generator between: 0 and: 16383.
	GeneratorMutex := Semaphore forMutualExclusion.
    ]

    UUID class >> new [
	"Return a new UUIDv1."

	<category: 'instance-creation'>
	^(self new: self defaultSize) initialize
    ]

    initialize [
	"Fill in the fields of a new UUIDv1."

	<category: 'private'>
	| t |
	GeneratorMutex critical: [
	    t := self class timeValue bitAnd: 16rFFFFFFFFFFFFFFF.
	    t <= LastTime
		ifTrue: [ SequenceValue := (SequenceValue + 1) bitAnd: 16383 ].

	    LastTime := t.
	    self at: 1 put: ((t bitShift: -24) bitAnd: 255).
	    self at: 2 put: ((t bitShift: -16) bitAnd: 255).
	    self at: 3 put: ((t bitShift: -8) bitAnd: 255).
	    self at: 4 put: (t bitAnd: 255).
	    self at: 5 put: ((t bitShift: -40) bitAnd: 255).
	    self at: 6 put: ((t bitShift: -32) bitAnd: 255).
	    self at: 7 put: (t bitShift: -56) + 16r10.
	    self at: 8 put: ((t bitShift: -48) bitAnd: 255).
	    self at: 9 put: (SequenceValue bitShift: -8) + 16r80.
	    self at: 10 put: (SequenceValue bitAnd: 255).
	    self at: 13 put: ((Node bitShift: -40) bitAnd: 255).
	    self at: 14 put: ((Node bitShift: -32) bitAnd: 255).
	    self at: 15 put: ((Node bitShift: -24) bitAnd: 255).
	    self at: 16 put: ((Node bitShift: -16) bitAnd: 255).
	    self at: 11 put: ((Node bitShift: -8) bitAnd: 255).
	    self at: 12 put: (Node bitAnd: 255)]
    ]

    printOn: aStream from: a to: b [
	<category: 'private'>
	self from: a to: b do: [:each |
	    aStream nextPut: (Character digitValue: (each bitShift: -4)).
	    aStream nextPut: (Character digitValue: (each bitAnd: 15)) ]
    ]

    printOn: aStream [
	"Print the bytes in the receiver in UUID format."
	<category: 'printing'>
	self printOn: aStream from: 1 to: 4.
	aStream nextPut: $-.
	self printOn: aStream from: 5 to: 6.
	aStream nextPut: $-.
	self printOn: aStream from: 7 to: 8.
	aStream nextPut: $-.
	self printOn: aStream from: 9 to: 10.
	aStream nextPut: $-.
	self printOn: aStream from: 11 to: 16.
    ]
]



Symbol extend [
    isUnary [
	"Return true if the symbol represents a Unary selector."
	<category: 'testing'>

	^self numArgs = 0
    ]
]

FileDescriptor extend [
    binary [
	"Do nothing, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
    ]
]

Object extend [
    asString [
	"Return the #displayString, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
        ^self displayString
    ]

    isCollection [
	"Return false, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
        ^false
    ]

    isEmptyOrNil [ 
	"Return false, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
        ^false
    ]

    isVariableBinding [
	"Return false, needed by Magritte-Seaside."

	<category: 'squeak compatibility'>
        ^false
    ]

]

Association extend [
    isVariableBinding [
	"Return false, needed by Magritte-Seaside."

	<category: 'squeak compatibility'>
        ^true
    ]
]

Collection extend [
    intersection: b [
	"Return the set of elements common to the receiver and B."

	<category: 'squeak compatibility'>
        ^self asSet & b
    ]

    hasEqualElements: b [
	"Compare the elements in the receiver and B.  Can be improved,
	 looking at Squeak's implementation."

	<category: 'squeak compatibility'>
        ^self asArray = b asArray
    ]

    isCollection [
	"Return true, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
        ^true
    ]

    isEmptyOrNil [
	"Return true if the collection is empty, needed for Squeak
	 compatibility."

	<category: 'squeak compatibility'>
        ^self isEmpty
    ]
]

SequenceableCollection extend [
    sort: aBlock [
	"Sort the items of the receiver according to the sort block,
	 aBlock."

	<category: 'squeak compatibility'>
	self
	    replaceFrom: 1
	    to: self size
	    with: (self asSortedCollection: aBlock)
	    startingAt: 1
    ]
]

SortedCollection extend [
    sort: aBlock [
	"Sort the items of the receiver according to the sort block,
	 aBlock, and change the sort block to aBlock."

	<category: 'squeak compatibility'>
	sortBlock := aBlock.
	self sortFrom: firstIndex to: lastIndex.
        sorted := true.
        lastOrdered := lastIndex
    ]
]

UndefinedObject extend [
    isEmptyOrNil [
	"Return true, needed for Squeak compatibility."

	<category: 'squeak compatibility'>
	^true
    ]
]

String extend [
    includesSubstring: aString caseSensitive: aBoolean [
	"Needed for Squeak compatibility."

	<category: 'squeak compatibility'>
	aBoolean ifTrue: [ ^(self indexOfSubCollection: aString) > 0 ].
	^(self asLowercase indexOfSubCollection: aString asLowercase) > 0
    ]
]

ValueHolder extend [
    contents [
	"Needed for Squeak compatibility."
	^self value
    ]
    contents: anObject [
	"Needed for Squeak compatibility."
	self value: anObject
    ]
]

Time extend [
    print24: boolean24 showSeconds: booleanSec on: aStream [
        "Print a representation of the receiver on aStream according
	 to the given flags.  Needed for Squeak compatibility."

        <category: 'arithmetic'>
	| h |
	h := boolean24 ifTrue: [ self hour24 ] ifFalse: [ self hour12 ].
        h printOn: aStream.
        aStream nextPut: $:.
        self minutes < 10 ifTrue: [aStream nextPut: $0].
        self minutes printOn: aStream.
	booleanSec ifFalse: [ ^self ].
        aStream nextPut: $:.
        self seconds < 10 ifTrue: [aStream nextPut: $0].
        self seconds printOn: aStream
    ]
]

Object subclass: MAVisitor [
    MAVisitor class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]
    initialize [
	<category: 'initialization'>
    ]
]



Eval [
    UUID initialize.
]
PK    �Mh@��C��     	  ChangeLogUT	 dqXOÉXOux �  �  ���j1E��+�-$ĩ.*"��@���	��$�h��SJ����p�ή�^w�n�',x��R ���w�i2R�A����Γ�G�ᓢ�If�)S��$S���h�W�Tg훶�e�LD�Kh�t�3��m���'�����y�l�4�a1��Vnh�c~ �R��� 	m$��Y׸��u	ɃCm�F}PK
     �Mh@iY �~ ~   magritte-tests.stUT	 dqXOÉXOux �  �  Object subclass: MAAccessorMock [
    
    <category: 'Magritte-Tests-Accessor'>
    <comment: nil>
]



Object subclass: MAMockAddress [
    | place street plz |
    
    <category: 'Magritte-Tests-Mocks'>
    <comment: nil>

    MAMockAddress class >> descriptionPlace [
	<category: 'descriptions'>
	^(MAStringDescription new)
	    autoAccessor: 'place';
	    label: 'Place';
	    yourself
    ]

    MAMockAddress class >> descriptionPlz [
	<category: 'descriptions'>
	^(MANumberDescription new)
	    autoAccessor: 'plz';
	    label: 'PLZ';
	    yourself
    ]

    MAMockAddress class >> descriptionStreet [
	<category: 'descriptions'>
	^(MAStringDescription new)
	    autoAccessor: 'street';
	    label: 'Street';
	    yourself
    ]

    = anObject [
	<category: 'comparing'>
	^self species = anObject species and: 
		[self street = anObject street 
		    and: [self plz = anObject plz and: [self place = anObject place]]]
    ]

    hash [
	<category: 'comparing'>
	^self street hash
    ]

    place [
	<category: 'accessing-generated'>
	^place
    ]

    place: anObject [
	<category: 'accessing-generated'>
	place := anObject
    ]

    plz [
	<category: 'accessing-generated'>
	^plz
    ]

    plz: anObject [
	<category: 'accessing-generated'>
	plz := anObject
    ]

    street [
	<category: 'accessing-generated'>
	^street
    ]

    street: anObject [
	<category: 'accessing-generated'>
	street := anObject
    ]
]



TestCase subclass: MAAdaptiveModelTest [
    | scaffolder |
    
    <comment: nil>
    <category: 'Magritte-Tests-Models'>

    descriptions [
	<category: 'accessing'>
	^self scaffolder description children
    ]

    scaffolder [
	<category: 'accessing'>
	^scaffolder
    ]

    setUp [
	<category: 'running'>
	scaffolder := MAAdaptiveModel new.
	(scaffolder description)
	    add: MAStringDescription new;
	    add: MANumberDescription new.
	scaffolder write: 'foo' using: self descriptions first.
	scaffolder write: 123 using: self descriptions second
    ]

    testRead [
	<category: 'testing'>
	self assert: (self scaffolder readUsing: self descriptions first) = 'foo'.
	self assert: (self scaffolder readUsing: self descriptions second) = 123
    ]

    testWrite [
	<category: 'testing'>
	self scaffolder write: 'bar' using: self descriptions first.
	self scaffolder write: 321 using: self descriptions second.
	self assert: (self scaffolder readUsing: self descriptions first) = 'bar'.
	self assert: (self scaffolder readUsing: self descriptions second) = 321
    ]
]



TestCase subclass: MADescriptionBuilderTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Utility'>

    MADescriptionBuilderTest class >> descriptionContainer [
	<category: 'mock-descriptions'>
	^super descriptionContainer label: 'mock'
    ]

    MADescriptionBuilderTest class >> descriptionContainer: aDescription [
	<category: 'mock-descriptions'>
	^aDescription
	    propertyAt: #bar put: nil;
	    yourself
    ]

    MADescriptionBuilderTest class >> descriptionContainerFoo: aDescription [
	<category: 'mock-descriptions'>
	^aDescription
	    propertyAt: #foo put: nil;
	    yourself
    ]

    MADescriptionBuilderTest class >> descriptionDescription [
	<category: 'mock-descriptions'>
	^MAToOneRelationDescription new label: 'foo'
    ]

    MADescriptionBuilderTest class >> descriptionDescription: aDescription [
	<category: 'mock-descriptions'>
	^aDescription
	    propertyAt: #foo put: nil;
	    yourself
    ]

    MADescriptionBuilderTest class >> descriptionDescriptionBar: aDescription [
	<category: 'mock-descriptions'>
	^aDescription
	    propertyAt: #bar put: nil;
	    yourself
    ]

    MADescriptionBuilderTest class >> descriptionDescriptionRec: aDescription [
	<category: 'mock-descriptions'>
	^aDescription reference: self description
    ]

    testContainer [
	<category: 'testing'>
	self assert: self description label = 'mock'.
	self assert: (self description hasProperty: #foo).
	self assert: (self description hasProperty: #bar)
    ]

    testDescription [
	<category: 'testing'>
	self assert: self description size = 1.
	self assert: self description children first label = 'foo'.
	self assert: (self description children first hasProperty: #foo).
	self assert: (self description children first hasProperty: #bar)
    ]

    testRecursive [
	<category: 'testing'>
	self assert: self description children first reference = self description
    ]
]



TestCase subclass: MADynamicObjectTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Utility'>

    testCalculated [
	<category: 'testing'>
	| object dummy |
	object := MADynamicObject on: [Time millisecondClockValue].
	dummy := object yourself.
	(Delay forMilliseconds: 2) wait.
	self assert: dummy < object yourself
    ]

    testCollection [
	<category: 'testing'>
	| object |
	object := MADynamicObject on: [OrderedCollection with: 1 with: 2].
	self assert: object size = 2.
	self assert: object first = 1.
	self assert: object second = 2.
	object add: 3.
	self assert: object size = 2.
	self assert: object first = 1.
	self assert: object second = 2
    ]

    testConstant [
	<category: 'testing'>
	| object |
	object := MADynamicObject on: [self].
	self assert: object = self.
	object := MADynamicObject on: [123].
	self assert: object = 123
    ]

    testCopy [
	<category: 'testing'>
	| object first second |
	object := (MADynamicObject on: [Time millisecondClockValue]) copy.
	first := object yourself.
	(Delay forMilliseconds: 2) wait.
	second := object yourself.
	self assert: first < second
    ]

    testCounter [
	<category: 'testing'>
	| object counter |
	counter := nil.
	object := MADynamicObject 
		    on: [counter := counter isNil ifTrue: [1] ifFalse: [counter := counter + 1]].
	self assert: object = 1.
	self assert: object yourself = 2.
	self assert: object yourself yourself = 3
    ]

    testDynamic [
	<category: 'testing'>
	| object collection |
	collection := nil.
	object := MADynamicObject on: 
			[collection isNil 
			    ifTrue: [collection := OrderedCollection with: 1 with: 2]
			    ifFalse: [collection]].
	self assert: object size = 2.
	self assert: object first = 1.
	self assert: object second = 2.
	object add: 3.
	self assert: object size = 3.
	self assert: object first = 1.
	self assert: object second = 2.
	self assert: object third = 3
    ]

    testException [
	<category: 'testing'>
	| object |
	object := MADynamicObject on: [1 / 0].
	self should: [object asString] raise: ZeroDivide.
	object := MADynamicObject on: [Halt signal].
	self assert: object asString = 'nil'
    ]

    "testNilOrNotNil [
	<category: 'testing'>
	| object |
	object := MADynamicObject on: [1].
	self deny: object isNil.
	self assert: object notNil.
	object := MADynamicObject on: [nil].
	self assert: object isNil.
	self deny: object notNil
    ]"
]



TestCase subclass: MAExtensionsTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Utility'>

    testCopyWithAll [
	<category: 'testing-collection'>
	| col res |
	col := #(#a #b).
	res := col copyWithAll: #(#c #d).
	self assert: res = #(#a #b #c #d).
	self deny: col == res.
	col := Set with: #a with: #b.
	res := col copyWithAll: #(#c #d).
	self assert: res size = 4.
	self assert: (res includes: #a).
	self assert: (res includes: #b).
	self assert: (res includes: #c).
	self assert: (res includes: #d).
	self deny: col == res.
	col := OrderedCollection with: #a with: #b.
	res := col copyWithAll: #(#c #d).
	self 
	    assert: res = (OrderedCollection 
			    with: #a
			    with: #b
			    with: #c
			    with: #d).
	self deny: col == res
    ]

    testCopyWithoutFirst [
	<category: 'testing-collection'>
	| col res |
	col := #(#a #b #a #c).
	res := col copyWithoutFirst: #a.
	self assert: res = #(#b #a #c).
	self deny: col == res.
	col := Set 
		    with: #a
		    with: #b
		    with: #c.
	res := col copyWithoutFirst: #a.
	self assert: res size = 2.
	self assert: (res includes: #b).
	self assert: (res includes: #c).
	self deny: col == res
    ]

    testFileSize [
	<category: 'testing-integer'>
	self assert: 1000 asFileSize = '1000 B'.
	self assert: 1024 asFileSize = '1 KB'.
	self assert: (1000 * 1000) asFileSize = '976 KB'.
	self assert: (1024 * 1024) asFileSize = '1 MB'.
	self assert: (1000 * 1000 * 1000) asFileSize = '953 MB'.
	self assert: (1024 * 1024 * 1024) asFileSize = '1 GB'.
	self assert: (1000 * 1000 * 1000 * 1000) asFileSize = '931 GB'.
	self assert: (1024 * 1024 * 1024 * 1024) asFileSize = '1 TB'

	"etc"
    ]

    testMatches [
	<category: 'testing-string'>
	self assert: ('' matches: '').
	self assert: ('zort' matches: '').
	self assert: ('zort' matches: 'o').
	self assert: ('zort' matches: 'O').
	self assert: ('zort' matches: '*').
	self assert: ('mobaz' matches: '*baz').
	self deny: ('mobazo' matches: '*baz').
	self assert: ('mobazo' matches: '*baz*').
	self deny: ('mozo' matches: '*baz*').
	self assert: ('foozo' matches: 'foo*').
	self deny: ('bozo' matches: 'foo*').
	self assert: ('foo23baz' matches: 'foo*baz').
	self assert: ('foobaz' matches: 'foo*baz').
	self deny: ('foo23bazo' matches: 'foo*baz').
	self assert: ('Foo' matches: 'foo').
	self deny: ('foobazort' matches: 'foo*baz*zort').
	self assert: ('foobazzort' matches: 'foo*baz*zort').
	self assert: ('afoo3zortthenfoo3zort' matches: '*foo#zort').
	self assert: ('afoodezortorfoo3zort' matches: '*foo*zort')
    ]

    testMoveDown [
	<category: 'testing-collection'>
	| col |
	col := Array 
		    with: 1
		    with: 2
		    with: 3.
	self assert: (col moveDown: 1) = 2.
	self assert: col = #(2 1 3).
	self assert: (col moveDown: 1) = 3.
	self assert: col = #(2 3 1).
	self assert: (col moveDown: 1) = 3.
	self assert: col = #(2 3 1).
	self assert: (col moveDown: 0) = 0.
	self assert: col = #(2 3 1)
    ]

    testMoveUp [
	<category: 'testing-collection'>
	| col |
	col := Array 
		    with: 1
		    with: 2
		    with: 3.
	self assert: (col moveUp: 3) = 2.
	self assert: col = #(1 3 2).
	self assert: (col moveUp: 3) = 1.
	self assert: col = #(3 1 2).
	self assert: (col moveUp: 3) = 1.
	self assert: col = #(3 1 2).
	self assert: (col moveUp: 0) = 0.
	self assert: col = #(3 1 2)
    ]

    testReduce [
	<category: 'testing-collection'>
	self assert: (#() reduce: [:a :b | a]) isNil.
	self assert: ((1 to: 9) reduce: [:a :b | a]) = 1.
	self assert: ((1 to: 9) reduce: [:a :b | b]) = 9.
	self assert: ((1 to: 9) reduce: [:a :b | a + b]) = 45.
	self assert: ((1 to: 9) reduce: [:a :b | a * b]) = 362880.
	self assert: (#('a' 'b' 'c') reduce: [:a :b | a , ' ' , b]) = 'a b c'.
	self assert: (#('a' 'b' 'c') reduce: [:a :b | b , ' ' , a]) = 'c b a'
    ]

    testValidationError [
	<category: 'testing-errors'>
	| result |
	result := [MARequiredError signal: 'some message'] on: MARequiredError
		    do: [:err | err displayString].
	self assert: result = 'some message'.
	result := 
		[MARequiredError description: ((MAStringDescription new)
			    label: 'label';
			    yourself)
		    signal: 'some message'] 
			on: MARequiredError
			do: [:err | err displayString].
	self assert: result = 'label: some message'
    ]
]



TestCase subclass: MAFileModelTest [
    | model |
    
    <comment: nil>
    <category: 'Magritte-Tests-Models'>

    MAFileModelTest class >> isAbstract [
	<category: 'testing'>
	^self name = #MAFileModelTest
    ]

    actualClass [
	<category: 'private'>
	^self subclassResponsibility
    ]

    setUp [
	<category: 'running'>
	super setUp.
	model := self actualClass new
    ]

    tearDown [
	<category: 'running'>
	model finalize
    ]

    testComparing [
	<category: 'testing'>
	| other |
	other := self actualClass new.
	other
	    filename: 'something.dat';
	    contents: (ByteArray 
			with: 1
			with: 2
			with: 3).
	self assert: model = model.
	self deny: model = other.
	self deny: other = model.
	other finalize	"should be in tearDown;  for now, at least let's discard when we pass"
    ]

    testContents [
	<category: 'testing'>
	self assert: model contents isEmpty.
	model contents: (ByteArray 
		    with: 1
		    with: 2
		    with: 3).
	self 
	    assert: model contents = (ByteArray 
			    with: 1
			    with: 2
			    with: 3).
	self assert: model filesize = 3
    ]

    testFilename [
	<category: 'testing'>
	self assert: model filename = 'unknown'.
	self assert: model extension isEmpty.
	model filename: 'test.txt'.
	self assert: model filename = 'test.txt'.
	self assert: model extension = 'txt'
    ]

    testIsEmpty [
	<category: 'testing'>
	self assert: model isEmpty.
	model filename: 'foo.txt'.
	self assert: model isEmpty.
	model mimetype: 'text/plain'.
	self assert: model isEmpty.
	model contents: 'hello'.
	self deny: model isEmpty
    ]

    testMimetype [
	<category: 'testing'>
	self assert: model mimetype = 'application/octet-stream'.
	self assert: model maintype = 'application'.
	self assert: model subtype = 'octet-stream'.
	model mimetype: 'text/html'.
	self assert: model mimetype = 'text/html'.
	self assert: model maintype = 'text'.
	self assert: model subtype = 'html'
    ]

    testMimetypeApplication [
	<category: 'testing'>
	model mimetype: 'application/pdf'.
	self assert: model isApplication.
	self deny: model isAudio.
	self deny: model isImage.
	self deny: model isText.
	self deny: model isVideo
    ]

    testMimetypeAudio [
	<category: 'testing'>
	model mimetype: 'audio/mpeg'.
	self deny: model isApplication.
	self assert: model isAudio.
	self deny: model isImage.
	self deny: model isText.
	self deny: model isVideo
    ]

    testMimetypeDefault [
	<category: 'testing'>
	self assert: model isApplication.
	self deny: model isAudio.
	self deny: model isImage.
	self deny: model isText.
	self deny: model isVideo
    ]

    testMimetypeImage [
	<category: 'testing'>
	model mimetype: 'image/png'.
	self deny: model isApplication.
	self deny: model isAudio.
	self assert: model isImage.
	self deny: model isText.
	self deny: model isVideo
    ]

    testMimetypeText [
	<category: 'testing'>
	model mimetype: 'text/xml'.
	self deny: model isApplication.
	self deny: model isAudio.
	self deny: model isImage.
	self assert: model isText.
	self deny: model isVideo
    ]

    testMimetypeVideo [
	<category: 'testing'>
	model mimetype: 'video/mpeg'.
	self deny: model isApplication.
	self deny: model isAudio.
	self deny: model isImage.
	self deny: model isText.
	self assert: model isVideo
    ]
]



MAFileModelTest subclass: MAExternalFileModelTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Models'>

    actualClass [
	<category: 'private'>
	^MAExternalFileModel
    ]
]



MAFileModelTest subclass: MAMemoryFileModelTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Models'>

    actualClass [
	<category: 'private'>
	^MAMemoryFileModel
    ]
]



TestCase subclass: MAObjectTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Core'>

    MAObjectTest class >> buildTestClassFor: aClass [
	"self buildTestClassFor: MAObject"

	<category: 'building'>
	| thisName thisClass thisCategory parentClass |
	thisName := (aClass name , 'Test') asSymbol.
	(thisName beginsWith: 'MA') ifFalse: [^self].
	thisClass := MACompatibility classNamed: thisName.
	thisCategory := 'Magritte-Tests-' , (aClass category copyAfterLast: $-).
	parentClass := self = thisClass 
		    ifTrue: [self superclass]
		    ifFalse: 
			[MACompatibility classNamed: (aClass superclass name , 'Test') asSymbol].
	thisClass := parentClass 
		    subclass: thisName
		    instanceVariableNames: (thisClass isNil 
			    ifFalse: [thisClass instanceVariablesString]
			    ifTrue: [String new])
		    classVariableNames: ''
		    poolDictionaries: ''
		    category: thisCategory.
	thisClass compile: 'actualClass
	^ ' , aClass name classified: #private.
	thisClass class compile: 'isAbstract
	^ ' , aClass isAbstract asString
	    classified: #testing.
	aClass subclassesDo: [:each | self buildTestClassFor: each]
    ]

    MAObjectTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    MAObjectTest class >> shouldInheritSelectors [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAObject
    ]

    instance [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    testCopy [
	<category: 'testing-copying'>
	self assert: self instance = self instance copy.
	self deny: self instance == self instance copy
    ]

    testCopyProperties [
	<category: 'testing-copying'>
	self deny: self instance properties == self instance copy properties
    ]

    testEqual [
	<category: 'testing-comparing'>
	self assert: self instance = self instance.
	self assert: self instance = self instance copy.
	self assert: self instance copy = self instance.
	self deny: self instance = 123.
	self deny: self instance = String new
    ]

    testHash [
	<category: 'testing-comparing'>
	self assert: self instance hash isInteger.
	self assert: self instance hash = self instance hash.
	self assert: self instance hash = self instance copy hash
    ]

    testIsDescription [
	<category: 'testing-testing'>
	self deny: self instance isDescription
    ]

    testProperties [
	<category: 'testing-properties'>
	self assert: self instance properties notNil.
	self instance instVarNamed: 'properties' put: nil.
	self instance propertyAt: #foo put: #bar.
	self instance instVarNamed: 'properties' put: nil.
	self instance propertyAt: #foo ifAbsent: [nil].
	self instance instVarNamed: 'properties' put: nil.
	self instance propertyAt: #foo ifAbsentPut: [#bar].
	self instance instVarNamed: 'properties' put: nil.
	self instance hasProperty: #foo.
	self instance instVarNamed: 'properties' put: nil
    ]

    testPropertiesAt [
	<category: 'testing-properties'>
	self assert: (self instance propertyAt: #foo put: 'bar') = 'bar'.
	self assert: (self instance propertyAt: #foo) = 'bar'.
	self should: [self instance propertyAt: #bar] raise: MAPropertyError
    ]

    testPropertiesAtIfAbsent [
	<category: 'testing-properties'>
	self assert: (self instance propertyAt: #foo put: 'bar') = 'bar'.
	self assert: (self instance propertyAt: #foo ifAbsent: ['baz']) = 'bar'.
	self assert: (self instance propertyAt: #bar ifAbsent: ['baz']) = 'baz'
    ]

    testPropertiesAtIfAbsentPut [
	<category: 'testing-properties'>
	self assert: (self instance propertyAt: #foo put: 'bar') = 'bar'.
	self assert: (self instance propertyAt: #foo ifAbsentPut: ['baz']) = 'bar'.
	self assert: (self instance propertyAt: #foo) = 'bar'.
	self assert: (self instance propertyAt: #bar ifAbsentPut: ['baz']) = 'baz'.
	self assert: (self instance propertyAt: #bar) = 'baz'
    ]

    testPropertiesAtIfPresent [
	<category: 'testing-properties'>
	self 
	    assert: (self instance propertyAt: #foo
		    ifPresent: [:value | self assert: false]) isNil.
	self instance propertyAt: #foo put: 1.
	self 
	    assert: (self instance propertyAt: #foo
		    ifPresent: 
			[:value | 
			self assert: value = 1.
			2]) = 2
    ]

    testPropertiesAtPut [
	<category: 'testing-properties'>
	self instance propertyAt: #foo put: 'bar'.
	self assert: (self instance propertyAt: #foo) = 'bar'.
	self instance propertyAt: #foo put: 'baz'.
	self assert: (self instance propertyAt: #foo) = 'baz'
    ]

    testPropertiesHas [
	<category: 'testing-properties'>
	self deny: (self instance hasProperty: #foo).
	self instance propertyAt: #foo put: 'bar'.
	self assert: (self instance hasProperty: #foo).
	self deny: (self instance hasProperty: #bar)
    ]

    testSanity [
	"If this test case fails, there is something wrong with the setup of the test-case."

	<category: 'testing'>
	self assert: self actualClass isAbstract not
	    description: 'Unable to test abstract class.'.
	self assert: self instance class = self actualClass
	    description: 'Invalid test instance.'
    ]
]



MAObjectTest subclass: MAAccessorTest [
    | accessor value |
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAAccessorTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    accessor [
	<category: 'accessing'>
	^accessor
    ]

    accessorInstance [
	<category: 'private'>
	self subclassResponsibility
    ]

    actualClass [
	<category: 'private'>
	^MAAccessor
    ]

    instance [
	<category: 'accessing'>
	^accessor
    ]

    setUp [
	<category: 'running'>
	super setUp.
	accessor := self accessorInstance
    ]

    testAsAccessor [
	<category: 'testing-identity'>
	self assert: self instance asAccessor = self instance.
	self assert: self instance asAccessor == self instance
    ]

    testCanRead [
	<category: 'testing-testing'>
	self subclassResponsibility
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self subclassResponsibility
    ]

    testRead [
	<category: 'testing'>
	self subclassResponsibility
    ]

    testStore [
	<category: 'testing-identity'>
	self 
	    assert: (Behavior
		    evaluate: self accessor storeString) = self accessor
    ]

    testWrite [
	<category: 'testing'>
	self subclassResponsibility
    ]

    value [
	<category: 'accessing-model'>
	^value
    ]

    value: anObject [
	<category: 'accessing-model'>
	value := anObject
    ]
]



MAAccessorTest subclass: MADelegatorAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MADelegatorAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass on: (MASelectorAccessor selector: #value)
    ]

    actualClass [
	<category: 'private'>
	^MADelegatorAccessor
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self).
	self accessor next readSelector: #zork.
	self deny: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self accessor canWrite: self).
	self accessor next writeSelector: #zork:.
	self deny: (self accessor canWrite: self)
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '123'.
	self assert: (self accessor read: self) = '123'
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]
]



MADelegatorAccessorTest subclass: MAChainAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAChainAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass accessors: #(#holder #contents #value)
    ]

    actualClass [
	<category: 'private'>
	^MAChainAccessor
    ]

    holder [
	<category: 'private'>
	^(ValueHolder new)
	    contents: self;
	    yourself
    ]

    testAccessor [
	<category: 'testing'>
	self accessor accessor: self.
	self assert: self accessor accessor = self
    ]

    testAsAccessor [
	<category: 'testing'>
	super testAsAccessor.
	accessor := #(#value) asAccessor.
	self assert: (accessor isKindOf: MASelectorAccessor).
	self assert: accessor selector = #value.
	accessor := #(#value #contents) asAccessor.
	self assert: (accessor isKindOf: MAChainAccessor).
	self assert: (accessor next isKindOf: MASelectorAccessor).
	self assert: accessor next selector = #value.
	self assert: (accessor accessor isKindOf: MASelectorAccessor).
	self assert: accessor accessor selector = #contents
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self).
	self accessor accessor accessor readSelector: #zork.
	self deny: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self accessor canWrite: self).
	self accessor accessor accessor writeSelector: #zork.
	self deny: (self accessor canWrite: self)
    ]

    testKind [
	<category: 'testing'>
	self assert: self accessor class = MAChainAccessor.
	self assert: self accessor next class = MASelectorAccessor.
	self assert: self accessor accessor class = MAChainAccessor.
	self assert: self accessor accessor next class = MASelectorAccessor.
	self assert: self accessor accessor accessor class = MASelectorAccessor
    ]

    testNext [
	<category: 'testing'>
	| next |
	next := #foo asAccessor.
	self accessor next: next.
	self assert: self accessor next = next
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '12'.
	self assert: (self accessor read: self) = '12'
    ]

    testSelector [
	<category: 'testing'>
	self assert: self accessor next selector = #holder.
	self assert: self accessor accessor next selector = #contents.
	self assert: self accessor accessor accessor selector = #value
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]
]



MAAccessorTest subclass: MADictionaryAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MADictionaryAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass key: #value
    ]

    actualClass [
	<category: 'private'>
	^MADictionaryAccessor
    ]

    at: aKey ifAbsent: aBlock [
	<category: 'accessing'>
	^aKey = #value ifTrue: [value] ifFalse: [aBlock value]
    ]

    at: aKey put: aValue [
	<category: 'accessing'>
	self assert: aKey = #value.
	^value := aValue
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self).
	self accessor key: #zork.
	self assert: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self accessor canWrite: self)
    ]

    testKey [
	<category: 'testing'>
	self accessor key: #other.
	self assert: self accessor key = #other
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '12'.
	self assert: (self accessor read: self) = '12'
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]
]



MAAccessorTest subclass: MAIdentityAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAIdentityAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass new
    ]

    actualClass [
	<category: 'private'>
	^MAIdentityAccessor
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self deny: (self accessor canWrite: self)
    ]

    testRead [
	<category: 'testing'>
	self assert: (self accessor read: 123) = 123
    ]

    testWrite [
	<category: 'testing'>
	self should: [self accessor write: 123 to: self] raise: MAWriteError.
	self assert: self value isNil
    ]
]



MAAccessorTest subclass: MANullAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MANullAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass new
    ]

    actualClass [
	<category: 'private'>
	^MANullAccessor
    ]

    testAsAccessor [
	<category: 'testing-identity'>
	super testAsAccessor.
	self assert: (nil asAccessor isKindOf: self actualClass)
    ]

    testCanRead [
	<category: 'testing-testing'>
	self deny: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self deny: (self accessor canWrite: nil)
    ]

    testRead [
	<category: 'testing'>
	self should: [self accessor read: self] raise: MAReadError
    ]

    testWrite [
	<category: 'testing'>
	self should: [self accessor write: 123 to: self] raise: MAWriteError.
	self assert: self value isNil
    ]
]



MAAccessorTest subclass: MAPluggableAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAPluggableAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass read: [:model | model value]
	    write: [:model :object | model value: object]
    ]

    actualClass [
	<category: 'private'>
	^MAPluggableAccessor
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self instance canRead: self).
	self instance readBlock: nil.
	self deny: (self instance canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self instance canWrite: nil).
	self assert: (self instance canWrite: 123).
	self assert: (self instance canWrite: self).
	self instance writeBlock: nil.
	self deny: (self instance canWrite: nil).
	self deny: (self instance canWrite: 123).
	self deny: (self instance canWrite: self)
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '12'.
	self assert: (self accessor read: self) = '12'
    ]

    testReadBlock [
	<category: 'testing'>
	self accessor readBlock: 
		[:model | 
		self assert: model = self.
		123].
	self assert: (self accessor read: self) = 123
    ]

    testStore [
	"The class BlockContext is not serializeable, ignore this test."

	<category: 'testing-identity'>
	
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]

    testWriteBlock [
	<category: 'testing'>
	self accessor writeBlock: 
		[:model :object | 
		self assert: model = self.
		self assert: object = 123].
	self accessor write: 123 to: self
    ]
]



MAAccessorTest subclass: MASelectorAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MASelectorAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass selector: #value
    ]

    actualClass [
	<category: 'private'>
	^MASelectorAccessor
    ]

    testAsAccessor [
	<category: 'testing-identity'>
	super testAsAccessor.
	self assert: #value asAccessor = self instance.
	self deny: #value asAccessor == self instance
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self).
	self accessor readSelector: #zork.
	self deny: (self accessor canRead: self).
	self accessor readSelector: nil.
	self deny: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self accessor canWrite: self).
	self accessor writeSelector: #zork:.
	self deny: (self accessor canWrite: self).
	self accessor writeSelector: nil.
	self deny: (self accessor canWrite: self)
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '12'.
	self assert: (self accessor read: self) = '12'
    ]

    testReadSelector [
	<category: 'testing'>
	self accessor readSelector: #contents.
	self assert: self accessor selector = #contents.
	self assert: self accessor readSelector = #contents.
	self assert: self accessor writeSelector = #value:
    ]

    testSelector [
	<category: 'testing'>
	self accessor selector: #contents.
	self assert: self accessor selector = #contents.
	self assert: self accessor readSelector = #contents.
	self assert: self accessor writeSelector = #contents:
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]

    testWriteSelector [
	<category: 'testing'>
	self accessor writeSelector: #contents:.
	self assert: self accessor selector = #value.
	self assert: self accessor readSelector = #value.
	self assert: self accessor writeSelector = #contents:
    ]
]



MASelectorAccessorTest subclass: MAAutoSelectorAccessorTest [
    | mock foo |
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAAutoSelectorAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAAutoSelectorAccessor
    ]

    foo: anObject [
	<category: 'accessing-generated'>
	foo := anObject
    ]

    mock [
	<category: 'accessing'>
	^mock
    ]

    mockInstance [
	<category: 'private'>
	^MAAccessorMock new
    ]

    runCase [
	<category: 'running'>
	mock := self mockInstance.
	super runCase
    ]

    tearDown [
	<category: 'running'>
	super tearDown.

	"remove methods and category"
	(self mock class selectors
	    select: [ :each | (self mock class >> each) methodCategory = self accessor categoryName ])
		do: [:each | self mock class removeSelector: each].

	"remove instance variables"
	self mock class instVarNames 
	    do: [:each | self mock class removeInstVarName: each]
    ]

    testAsAccessor [
	"noop"

	<category: 'testing-identity'>
	
    ]

    testReadFirst [
	<category: 'testing'>
	self accessor selector: #foo.
	self assert: (self accessor read: self mock) isNil.
	self accessor write: 123 to: self mock.
	self assert: (self accessor read: self mock) = 123
    ]

    testWriteFirst [
	<category: 'testing'>
	self accessor selector: #foo.
	self accessor write: 123 to: self mock.
	self assert: (self accessor read: self mock) = 123
    ]
]



MAAccessorTest subclass: MAVariableAccessorTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Accessor'>

    MAVariableAccessorTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    accessorInstance [
	<category: 'private'>
	^self actualClass name: 'value'
    ]

    actualClass [
	<category: 'private'>
	^MAVariableAccessor
    ]

    testCanRead [
	<category: 'testing-testing'>
	self assert: (self accessor canRead: self).
	self accessor name: 'zork'.
	self deny: (self accessor canRead: self)
    ]

    testCanWrite [
	<category: 'testing-testing'>
	self assert: (self accessor canWrite: self).
	self accessor name: 'zork'.
	self deny: (self accessor canWrite: self)
    ]

    testName [
	<category: 'testing'>
	self accessor name: 'other'.
	self assert: self accessor name = 'other'
    ]

    testRead [
	<category: 'testing'>
	self value: 123.
	self assert: (self accessor read: self) = 123.
	self value: '12'.
	self assert: (self accessor read: self) = '12'
    ]

    testWrite [
	<category: 'testing'>
	self accessor write: 123 to: self.
	self assert: self value = 123.
	self accessor write: '123' to: self.
	self assert: self value = '123'
    ]
]



MAObjectTest subclass: MADescriptionTest [
    | description |
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MADescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    MADescriptionTest class >> shouldInheritSelectors [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MADescription
    ]

    description [
	<category: 'accessing'>
	^description
    ]

    descriptionInstance [
	<category: 'private'>
	^(self actualClass new)
	    accessor: MANullAccessor new;
	    yourself
    ]

    instance [
	<category: 'accessing'>
	^description
    ]

    setUp [
	<category: 'running'>
	super setUp.
	description := self descriptionInstance.
	self assert: description accessor notNil
    ]

    testAccessor [
	<category: 'testing-accessing'>
	self description accessor: (MASelectorAccessor selector: #foo).
	self assert: self description accessor selector = #foo
    ]

    testAsContainer [
	<category: 'testing-converting'>
	self subclassResponsibility
    ]

    testComment [
	<category: 'testing-accessing'>
	self description comment: 'bar'.
	self assert: self description comment = 'bar'
    ]

    testCopyAccessor [
	<category: 'testing-copying'>
	self assert: self description copy accessor = self description accessor.
	self deny: self description copy accessor == self description accessor
    ]

    testDictionaryKey [
	<category: 'testing-identity'>
	| dictionary |
	dictionary := Dictionary new.
	dictionary at: self instance put: 1.
	self assert: (dictionary at: self instance) = 1.
	dictionary at: self instance put: 2.
	self assert: (dictionary at: self instance) = 2
    ]

    testGroup [
	<category: 'testing-accessing'>
	self assert: self description group isNil.
	self description group: 'foo'.
	self assert: self description group = 'foo'
    ]

    testHasChildren [
	<category: 'testing-testing'>
	self deny: self description hasChildren
    ]

    testHasComment [
	<category: 'testing-testing'>
	self description comment: nil.
	self deny: self description hasComment.
	self description comment: ''.
	self deny: self description hasComment.
	self description comment: 'comment'.
	self assert: self description hasComment
    ]

    testHasLabel [
	<category: 'testing-testing'>
	self description label: nil.
	self deny: self description hasLabel.
	self description label: ''.
	self deny: self description hasLabel.
	self description label: 'label'.
	self assert: self description hasLabel
    ]

    testIsContainer [
	<category: 'testing-testing'>
	self deny: self description isContainer
    ]

    testIsDescription [
	<category: 'testing-testing'>
	self assert: self description isDescription
    ]

    testLabel [
	<category: 'testing-accessing'>
	self description label: 'foo'.
	self assert: self description label = 'foo'
    ]

    testPriority [
	<category: 'testing-accessing'>
	self description priority: 123.
	self assert: self description priority = 123
    ]

    testReadonly [
	<category: 'testing-actions'>
	self description beReadonly.
	self assert: self description readonly.
	self assert: self description isReadonly.
	self description beWriteable.
	self deny: self description readonly.
	self deny: self description isReadonly
    ]

    testRequired [
	<category: 'testing-actions'>
	self description beRequired.
	self assert: self description required.
	self assert: self description isRequired.
	self description beOptional.
	self deny: self description required.
	self deny: self description isRequired
    ]

    testSetElement [
	<category: 'testing-identity'>
	| set |
	set := Set new.
	set add: self instance.
	self assert: set size = 1.
	self assert: (set includes: self instance).
	set add: self instance.
	self assert: set size = 1.
	self assert: (set includes: self instance)
    ]

    testVisible [
	<category: 'testing-actions'>
	self description beHidden.
	self deny: self description visible.
	self deny: self description isVisible.
	self description beVisible.
	self assert: self description visible.
	self assert: self description isVisible
    ]
]



MADescriptionTest subclass: MAContainerTest [
    | child1 child2 child3 |
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAContainerTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAContainer
    ]

    child1 [
	<category: 'accessing'>
	^child1 ifNil: 
		[child1 := (MAStringDescription new)
			    accessor: #child1;
			    label: 'child1';
			    priority: 1;
			    yourself]
    ]

    child2 [
	<category: 'accessing'>
	^child2 ifNil: 
		[child2 := (MAStringDescription new)
			    accessor: #child2;
			    label: 'child2';
			    priority: 2;
			    yourself]
    ]

    child3 [
	<category: 'accessing'>
	^child3 ifNil: 
		[child3 := (MAStringDescription new)
			    accessor: #child3;
			    label: 'child3';
			    priority: 3;
			    yourself]
    ]

    exampleInstance [
	<category: 'private'>
	^(MACachedMemento new)
	    setDescription: self description;
	    setCache: ((Dictionary new)
			at: self child1 put: nil;
			at: self child2 put: nil;
			at: self child3 put: nil;
			yourself);
	    yourself
    ]

    testAdd [
	<category: 'testing-adding'>
	self description add: self child1.
	self assert: self description size = 1.
	self assert: (self description includes: self child1).
	self description add: self child2.
	self assert: self description size = 2.
	self assert: (self description includes: self child1).
	self assert: (self description includes: self child2)
    ]

    testAddAll [
	<category: 'testing-adding'>
	self description addAll: (Array with: self child1 with: self child2).
	self assert: self description size = 2.
	self assert: (self description includes: self child1).
	self assert: (self description includes: self child2)
    ]

    testAsContainer [
	<category: 'testing-converting'>
	self assert: self description asContainer = self description.
	self assert: self description asContainer == self description
    ]

    testChildren [
	<category: 'testing-accessing'>
	self assert: self description children isCollection.
	self assert: self description children isEmpty
    ]

    testCollect [
	<category: 'testing-enumerating'>
	| collected |
	(self description)
	    add: self child1;
	    add: self child2.
	collected := self description collect: [:each | each].
	self assert: self description = collected.
	self deny: self description == collected.
	collected := self description collect: [:each | each copy].
	self assert: self description = collected.
	self deny: self description == collected.
	collected := self description collect: 
			[:each | 
			(each copy)
			    accessor: (MASelectorAccessor selector: #foo);
			    yourself].
	self deny: self description = collected.
	self deny: self description == collected
    ]

    testConcatenate [
	<category: 'testing-operators'>
	| concatenate |
	concatenate := self child1 , self child2.
	self assert: concatenate size = 2.
	self assert: concatenate children first = self child1.
	self assert: concatenate children second = self child2.
	concatenate := self child1 , self child2 , self child3.
	self assert: concatenate size = 3.
	self assert: concatenate children first = self child1.
	self assert: concatenate children second = self child2.
	self assert: concatenate children third = self child3
    ]

    testCopy [
	<category: 'testing-copying'>
	(self description)
	    add: self child1;
	    add: self child2.
	super testCopy.
	self deny: self description copy children == self description children.
	self assert: self description copy children first 
		    = self description children first.
	self assert: self description copy children second 
		    = self description children second
    ]

    testCopyEmpty [
	<category: 'testing-copying'>
	(self description)
	    add: self child1;
	    add: self child2.
	self assert: self description copyEmpty isEmpty
    ]

    testCopyFromTo [
	<category: 'testing-copying'>
	| copied |
	(self description)
	    add: self child1;
	    add: self child2;
	    add: self child3.
	copied := self description copyFrom: 2 to: 3.
	self assert: copied ~= self description.
	self assert: copied size = 2.
	self assert: copied children first = self child2.
	self assert: copied children second = self child3
    ]

    testDetect [
	<category: 'testing-enumerating'>
	self description add: self child1.
	self assert: (self description detect: [:each | self child1 = each]) 
		    = self child1.
	self should: [self description detect: [:each | self child2 = each]]
	    raise: Error
    ]

    testDetectIfNone [
	<category: 'testing-enumerating'>
	self description add: self child1.
	self 
	    assert: (self description detect: [:each | self child1 = each] ifNone: [123]) 
		    = self child1.
	self 
	    assert: (self description detect: [:each | self child2 = each] ifNone: [123]) 
		    = 123
    ]

    testDo [
	<category: 'testing-enumerating'>
	| collection |
	collection := self description class defaultCollection.
	(self description)
	    add: self child1;
	    add: self child2.
	self description do: [:each | collection add: each].
	self assert: (self description children hasEqualElements: collection)
    ]

    testDoSepratedBy [
	<category: 'testing-enumerating'>
	| collection |
	collection := OrderedCollection new.
	(self description)
	    add: self child1;
	    add: self child2.
	self description do: [:each | collection add: each]
	    separatedBy: [collection add: nil].
	self assert: collection size = 3.
	self assert: collection first = self child1.
	self assert: collection second isNil.
	self assert: collection third = self child2
    ]

    testEmpty [
	<category: 'testing-testing'>
	self assert: self description isEmpty.
	self description add: self child1.
	self deny: self description isEmpty
    ]

    testHasChildren [
	<category: 'testing-testing'>
	super testHasChildren.
	self description add: self child1.
	self assert: self description hasChildren
    ]

    testIncludes [
	<category: 'testing-testing'>
	self deny: (self description includes: self child1).
	self description add: self child1.
	self assert: (self description includes: self child1)
    ]

    testInjectInto [
	<category: 'testing-enumerating'>
	(self description)
	    add: self child1;
	    add: self child2.
	self 
	    assert: (self description inject: 'start'
		    into: [:result :each | result , ' ' , each label]) = 'start child1 child2'
    ]

    testIntersection [
	<category: 'testing-operators'>
	| a b union |
	a := self child1 , self child2.
	b := self child2 , self child3.
	union := a intersection: b.
	self assert: union size = 1.
	self deny: (union includes: self child1).
	self assert: (union includes: self child2).
	self deny: (union includes: self child3)
    ]

    testIsContainer [
	<category: 'testing-testing'>
	self assert: self description isContainer
    ]

    testKeysAndValuesDo [
	<category: 'testing-enumerating'>
	(self description)
	    add: self child1;
	    add: self child2.
	self description keysAndValuesDo: 
		[:index :each | 
		index = 1 
		    ifTrue: [self assert: self child1 = each]
		    ifFalse: 
			[index = 2 
			    ifTrue: [self assert: self child2 = each]
			    ifFalse: [self assert: false]]]
    ]

    testMoveDown [
	<category: 'testing-moving'>
	(self description)
	    add: self child1;
	    add: self child2.
	self assert: self description children first = self child1.
	self assert: self description children second = self child2.
	self description moveDown: self child1.
	self assert: self description children first = self child2.
	self assert: self description children second = self child1.
	self description moveDown: self child1.
	self assert: self description children first = self child2.
	self assert: self description children second = self child1
    ]

    testMoveUp [
	<category: 'testing-moving'>
	(self description)
	    add: self child1;
	    add: self child2.
	self assert: self description children first = self child1.
	self assert: self description children second = self child2.
	self description moveUp: self child2.
	self assert: self description children first = self child2.
	self assert: self description children second = self child1.
	self description moveUp: self child2.
	self assert: self description children first = self child2.
	self assert: self description children second = self child1
    ]

    testNoFailingValidation [
	<category: 'testing-validating'>
	| example |
	(self description)
	    add: self child1;
	    add: self child2.
	example := self exampleInstance.
	self shouldnt: [example validate] raise: MAValidationError
    ]

    testNotEmpty [
	<category: 'testing-testing'>
	self deny: self description notEmpty.
	self description add: self child1.
	self assert: self description notEmpty
    ]

    testOneFailingValidation [
	<category: 'testing-validating'>
	| example |
	(self description)
	    add: self child1;
	    add: ((self child2)
			addCondition: [:v | self fail];
			beRequired;
			yourself).
	example := self exampleInstance.
	self should: [example validate] raise: MAValidationError.
	[example validate] on: MAValidationError
	    do: 
		[:err | 
		self assert: err class = MARequiredError.
		self assert: err tag = self child2.
		self assert: err isResumable.
		err resume]
    ]

    testReject [
	<category: 'testing-enumerating'>
	| rejected |
	(self description)
	    add: self child1;
	    add: self child2.
	rejected := self description reject: [:each | false].
	self assert: self description = rejected.
	rejected := self description reject: [:each | true].
	self assert: rejected isEmpty
    ]

    testRemove [
	<category: 'testing-removing'>
	(self description)
	    add: self child1;
	    add: self child2.
	self description remove: self child1.
	self assert: self description size = 1.
	self deny: (self description includes: self child1).
	self assert: (self description includes: self child2).
	self description remove: self child2.
	self assert: self description isEmpty
    ]

    testRemoveAll [
	<category: 'testing-removing'>
	(self description)
	    add: self child1;
	    add: self child2.
	self description removeAll.
	self assert: self description isEmpty
    ]

    testSelect [
	<category: 'testing-enumerating'>
	| selected |
	(self description)
	    add: self child1;
	    add: self child2.
	selected := self description select: [:each | true].
	self assert: self description = selected.
	selected := self description select: [:each | false].
	self assert: selected isEmpty
    ]

    testSize [
	<category: 'testing-accessing'>
	self assert: self description size = 0.
	self description add: self child1.
	self assert: self description size = 1.
	self description add: self child2.
	self assert: self description size = 2.
	self description add: self child3.
	self assert: self description size = 3
    ]

    testTwoFailingValidation [
	<category: 'testing-validating'>
	| example step |
	(self description)
	    add: ((self child1)
			addCondition: [:v | self fail];
			beRequired;
			yourself);
	    add: ((self child2)
			addCondition: [:v | self fail];
			beRequired;
			yourself).
	example := self exampleInstance.
	step := 1.
	self should: [example validate] raise: MAValidationError.
	[example validate] on: MAValidationError
	    do: 
		[:err | 
		self assert: err class = MARequiredError.
		self assert: err isResumable.
		step = 1 ifTrue: [self assert: err tag = self child1].
		step = 2 ifTrue: [self assert: err tag = self child2].
		step = 3 ifTrue: [self fail].
		step := step + 1.
		err resume]
    ]

    testUnion [
	<category: 'testing-operators'>
	| a b union |
	a := self child1 , self child2.
	b := self child2 , self child3.
	union := a union: b.
	self assert: union size = 3.
	self assert: (union includes: self child1).
	self assert: (union includes: self child2).
	self assert: (union includes: self child3)
    ]

    testWithDo [
	<category: 'testing-enumerating'>
	(self description)
	    add: self child1;
	    add: self child2.
	self description with: self description children
	    do: [:first :second | self assert: first = second]
    ]
]



MAContainerTest subclass: MAPriorityContainerTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAPriorityContainerTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAPriorityContainer
    ]

    testMoveDown [
	<category: 'testing-moving'>
	self should: [super testMoveDown] raise: Error
    ]

    testMoveUp [
	<category: 'testing-moving'>
	self should: [super testMoveUp] raise: Error
    ]
]



MADescriptionTest subclass: MAElementDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAElementDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAElementDescription
    ]

    emptyInstance [
	<category: 'private'>
	^String new
    ]

    includedInstance [
	<category: 'private'>
	self subclassResponsibility
    ]

    includedInstanceString [
	<category: 'private'>
	^MAStringWriter write: self includedInstance
	    description: self descriptionInstance
    ]

    invalidInstance [
	<category: 'private'>
	^Object new
    ]

    invalidInstanceString [
	<category: 'private'>
	^self invalidInstance asString
    ]

    nullInstance [
	<category: 'private'>
	^nil
    ]

    shouldSkipStringTests [
	<category: 'private'>
	^false
    ]

    testAddCondition [
	<category: 'testing-validation'>
	self description addCondition: [:value | value isNil].
	self assert: self description conditions size = 1.
	self assert: self description conditions first value isString
    ]

    testAddConditionLabelled [
	<category: 'testing-validation'>
	self description addCondition: [:value | value isNil]
	    labelled: 'ist net nil'.
	self assert: self description conditions size = 1.
	self assert: self description conditions first value = 'ist net nil'
    ]

    testAsContainer [
	<category: 'testing-converting'>
	self assert: self description asContainer size = 1.
	self assert: (self description asContainer includes: self description)
    ]

    testConcatenation [
	<category: 'testing-operators'>
	| child1 child2 concatenate |
	child1 := self description copy.
	child2 := self description copy.
	concatenate := child1 , child2.
	self assert: concatenate size = 2.
	self assert: concatenate children first = child1.
	self assert: concatenate children second = child2.
	concatenate := child1 , concatenate.
	self assert: concatenate size = 3.
	self assert: concatenate children first = child1.
	self assert: concatenate children second = child1.
	self assert: concatenate children third = child2
    ]

    testCopy [
	<category: 'testing-copying'>
	super testCopy.
	self assert: self description copy default = self description default
    ]

    testDefault [
	<category: 'testing-accessing'>
	self description default: self includedInstance.
	self assert: self description default = self includedInstance
    ]

    testFromString [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self assert: (self description fromString: self includedInstanceString) 
		    = self includedInstance.
	self 
	    assert: (self description fromString: self includedInstanceString
		    reader: self description stringReader) = self includedInstance.
	self 
	    assert: (self description fromString: self includedInstanceString
		    reader: self description stringReader new) = self includedInstance
    ]

    testFromStringCollection [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self 
	    assert: (self description 
		    fromStringCollection: (Array with: self includedInstanceString
			    with: self includedInstanceString)) 
			= (Array with: self includedInstance with: self includedInstance).
	self 
	    assert: (self description 
		    fromStringCollection: (Array with: self includedInstanceString
			    with: self includedInstanceString)
		    reader: self description stringReader) 
			= (Array with: self includedInstance with: self includedInstance)
    ]

    testFromStringEvaluated [
	"This ensures that the parsing algorithm doesn't compile the input, what would cause a  security hole in the framework."

	<category: 'testing-strings'>
	| error |
	error := nil.
	self shouldSkipStringTests ifTrue: [^self].
	[self description fromString: '1 / 0. nil'] on: Exception
	    do: [:err | error := err].
	self deny: (error isKindOf: ZeroDivide)
    ]

    testFromStringInvalid [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self should: [self description fromString: self invalidInstanceString]
	    raise: MAReadError
    ]

    testFromStringNull [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self assert: (self description fromString: self emptyInstance) isNil.
	self 
	    assert: (self description fromString: self emptyInstance
		    reader: self description stringReader) isNil.
	self 
	    assert: (self description fromString: self emptyInstance
		    reader: self description stringReader new) isNil
    ]

    testKind [
	<category: 'testing-accessing'>
	self assert: (self includedInstance isKindOf: self description kind)
    ]

    testKindErrorMessage [
	<category: 'testing-validation'>
	self assert: self description kindErrorMessage notEmpty.
	self description kindErrorMessage: 'zork'.
	self assert: self description kindErrorMessage = 'zork'.
	[self description validateKind: self invalidInstance] on: MAKindError
	    do: [:err | self assert: self description kindErrorMessage = err messageText]
    ]

    testRequiredErrorMessage [
	<category: 'testing-validation'>
	self assert: self description requiredErrorMessage notEmpty.
	self description requiredErrorMessage: 'zork'.
	self assert: self description requiredErrorMessage = 'zork'.
	
	[(self description)
	    beRequired;
	    validateRequired: self nullInstance] 
		on: MARequiredError
		do: [:err | self assert: self description requiredErrorMessage = err messageText]
    ]

    testSatisfied [
	<category: 'testing-testing'>
	self assert: (self description isSatisfiedBy: self includedInstance).
	self assert: (self description isSatisfiedBy: self nullInstance).
	self deny: (self description isSatisfiedBy: self invalidInstance)
    ]

    testStringReader [
	<category: 'testing-accessing'>
	| object |
	self description stringReader: (object := MAStringReader new).
	self assert: self description stringReader = object
    ]

    testStringWriter [
	<category: 'testing-accessing'>
	| object |
	self description stringWriter: (object := MAStringWriter new).
	self assert: self description stringWriter = object
    ]

    testToString [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self assert: (self description toString: self includedInstance) 
		    = self includedInstanceString.
	self 
	    assert: (self description toString: self includedInstance
		    writer: self description stringWriter) = self includedInstanceString.
	self 
	    assert: (self description toString: self includedInstance
		    writer: self description stringWriter new) = self includedInstanceString
    ]

    testToStringCollection [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self 
	    assert: (self description 
		    toStringCollection: (Array with: self includedInstance
			    with: self includedInstance)) 
			= (Array with: self includedInstanceString with: self includedInstanceString).
	self 
	    assert: (self description 
		    toStringCollection: (Array with: self includedInstance
			    with: self includedInstance)
		    writer: self description stringWriter) 
			= (Array with: self includedInstanceString with: self includedInstanceString)
    ]

    testToStringFromString [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self 
	    assert: (self description 
		    fromString: (self description toString: self includedInstance)) 
			= self includedInstance.
	self 
	    assert: (self description 
		    fromString: (self description toString: self includedInstance
			    writer: self description stringWriter)
		    reader: self description stringReader) = self includedInstance.
	self 
	    assert: (self description 
		    fromString: (self description toString: self includedInstance
			    writer: self description stringWriter new)
		    reader: self description stringReader new) = self includedInstance
    ]

    testToStringNull [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self assert: (self description toString: self nullInstance) 
		    = self description undefined.
	self 
	    assert: (self description toString: self nullInstance
		    writer: self description stringWriter) = self description undefined.
	self 
	    assert: (self description toString: self nullInstance
		    writer: self description stringWriter new) = self description undefined
    ]

    testToStringUndefined [
	<category: 'testing-strings'>
	self shouldSkipStringTests ifTrue: [^self].
	self description undefined: 'n/a'.
	self assert: (self description toString: self nullInstance) = 'n/a'.
	self 
	    assert: (self description toString: self nullInstance
		    writer: self description stringWriter) = 'n/a'.
	self 
	    assert: (self description toString: self nullInstance
		    writer: self description stringWriter new) = 'n/a'
    ]

    testUndefined [
	<category: 'testing-accessing'>
	self description undefined: 'nop'.
	self assert: self description undefined = 'nop'
    ]

    testValidate [
	<category: 'testing-validation'>
	self description beRequired.
	self shouldnt: [self description validate: self includedInstance]
	    raise: MAValidationError.
	self should: [self description validate: self invalidInstance]
	    raise: MAKindError.
	self should: [self description validate: self nullInstance]
	    raise: MARequiredError
    ]

    testValidateConditions [
	"This test might fail for MADateDescriptionTest, since there is a bug in Squeak."

	<category: 'testing-validation'>
	| object |
	object := self includedInstance.
	self description addCondition: [:value | object == value]
	    labelled: 'included instance test'.
	self shouldnt: [self description validate: object] raise: MAConditionError.
	self should: [self description validate: object copy]
	    raise: MAConditionError
    ]

    testValidateKind [
	<category: 'testing-validation'>
	self should: [self description validateKind: self invalidInstance]
	    raise: MAKindError.
	self shouldnt: [self description validateKind: self includedInstance]
	    raise: MAKindError
    ]

    testValidateRequired [
	<category: 'testing-validation'>
	self description beOptional.
	self shouldnt: [self description validateRequired: self nullInstance]
	    raise: MARequiredError.
	self shouldnt: [self description validateRequired: self includedInstance]
	    raise: MARequiredError.
	self description beRequired.
	self should: [self description validateRequired: self nullInstance]
	    raise: MARequiredError.
	self shouldnt: [self description validateRequired: self includedInstance]
	    raise: MARequiredError
    ]

    testValidateSpecific [
	<category: 'testing-validation'>
	self shouldnt: [self description validate: self includedInstance]
	    raise: MARequiredError
    ]
]



MAElementDescriptionTest subclass: MABooleanDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MABooleanDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MABooleanDescription
    ]

    includedInstance [
	<category: 'private'>
	^true
    ]

    testValidateConditions [
	<category: 'testing-validation'>
	
    ]
]



MAElementDescriptionTest subclass: MAClassDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAClassDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAClassDescription
    ]

    includedInstance [
	<category: 'private'>
	^String
    ]

    shouldSkipStringTests [
	<category: 'private'>
	^true
    ]
]



MAElementDescriptionTest subclass: MAFileDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAFileDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAFileDescription
    ]

    includedInstance [
	<category: 'private'>
	^(MAMemoryFileModel new)
	    contents: 'Lukas Renggli';
	    filename: 'author.txt';
	    yourself
    ]

    shouldSkipStringTests [
	<category: 'private'>
	^true
    ]
]



MAElementDescriptionTest subclass: MAMagnitudeDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAMagnitudeDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAMagnitudeDescription
    ]

    excludedInstance [
	<category: 'private'>
	self subclassResponsibility
    ]

    maxInstance [
	<category: 'private'>
	self subclassResponsibility
    ]

    minInstance [
	<category: 'private'>
	self subclassResponsibility
    ]

    testInfToInf [
	<category: 'testing'>
	self assert: self description min isNil.
	self assert: self description max isNil.
	self assert: (self description isSatisfiedBy: self minInstance).
	self assert: (self description isSatisfiedBy: self includedInstance).
	self assert: (self description isSatisfiedBy: self maxInstance)
    ]

    testInfToVal [
	<category: 'testing'>
	self description max: self includedInstance.
	self assert: self description min isNil.
	self assert: self description max = self includedInstance.
	self assert: (self description isSatisfiedBy: self minInstance).
	self assert: (self description isSatisfiedBy: self includedInstance).
	self deny: (self description isSatisfiedBy: self maxInstance)
    ]

    testMax [
	<category: 'testing-accessing'>
	self description max: self maxInstance.
	self assert: self description max = self maxInstance
    ]

    testMin [
	<category: 'testing-accessing'>
	self description min: self minInstance.
	self assert: self description min = self minInstance
    ]

    testMinMax [
	<category: 'testing-accessing'>
	self description min: self minInstance max: self maxInstance.
	self assert: self description min = self minInstance.
	self assert: self description max = self maxInstance
    ]

    testRangeErrorMessage [
	<category: 'testing-validation'>
	(self description)
	    min: self minInstance;
	    max: self maxInstance.
	self assert: self description rangeErrorMessage notEmpty.
	self description rangeErrorMessage: 'zork'.
	self assert: self description rangeErrorMessage = 'zork'.
	[self description validate: self excludedInstance] on: MARangeError
	    do: [:err | self assert: self description rangeErrorMessage = err messageText]
    ]

    testRangeErrorMessageGenerated [
	<category: 'testing-validation'>
	self description min: nil max: nil.
	self assert: self description rangeErrorMessage isNil.
	self description min: nil max: self maxInstance.
	self assert: self description rangeErrorMessage notEmpty.
	self description min: self minInstance max: nil.
	self assert: self description rangeErrorMessage notEmpty.
	self description min: self minInstance max: self maxInstance.
	self assert: self description rangeErrorMessage notEmpty
    ]

    testValToInf [
	<category: 'testing'>
	self description min: self includedInstance.
	self assert: self description min = self includedInstance.
	self assert: self description max isNil.
	self deny: (self description isSatisfiedBy: self minInstance).
	self assert: (self description isSatisfiedBy: self includedInstance).
	self assert: (self description isSatisfiedBy: self maxInstance)
    ]

    testValToVal [
	<category: 'testing'>
	self description min: self includedInstance.
	self description max: self includedInstance.
	self assert: self description min = self includedInstance.
	self assert: self description max = self includedInstance.
	self deny: (self description isSatisfiedBy: self minInstance).
	self assert: (self description isSatisfiedBy: self includedInstance).
	self deny: (self description isSatisfiedBy: self maxInstance)
    ]

    testValidateSpecific [
	<category: 'testing-validation'>
	super testValidateSpecific.
	(self description)
	    min: self minInstance;
	    max: self maxInstance.
	self shouldnt: [self description validate: self includedInstance]
	    raise: MARangeError.
	self should: [self description validate: self excludedInstance]
	    raise: MARangeError
    ]
]



MAMagnitudeDescriptionTest subclass: MADateDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MADateDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MADateDescription
    ]

    excludedInstance [
	<category: 'private'>
	^Date 
	    newDay: 1
	    month: (Date nameOfMonth: 6)
	    year: 1980
    ]

    includedInstance [
	<category: 'private'>
	^Date 
	    newDay: 11
	    month: (Date nameOfMonth: 6)
	    year: 1980
    ]

    maxInstance [
	<category: 'private'>
	^Date 
	    newDay: 12
	    month: (Date nameOfMonth: 6)
	    year: 1980
    ]

    minInstance [
	<category: 'private'>
	^Date 
	    newDay: 10
	    month: (Date nameOfMonth: 6)
	    year: 1980
    ]
]



MAMagnitudeDescriptionTest subclass: MADurationDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MADurationDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MADurationDescription
    ]

    excludedInstance [
	<category: 'private'>
	^Duration 
	    days: 0
	    hours: 0
	    minutes: 0
	    seconds: 2
    ]

    includedInstance [
	<category: 'private'>
	^Duration 
	    days: 1
	    hours: 2
	    minutes: 3
	    seconds: 4
    ]

    maxInstance [
	<category: 'private'>
	^Duration 
	    days: 2
	    hours: 2
	    minutes: 3
	    seconds: 4
    ]

    minInstance [
	<category: 'private'>
	^Duration 
	    days: 0
	    hours: 2
	    minutes: 3
	    seconds: 4
    ]
]



MAMagnitudeDescriptionTest subclass: MANumberDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MANumberDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MANumberDescription
    ]

    excludedInstance [
	<category: 'private'>
	^0.618
    ]

    includedInstance [
	<category: 'private'>
	^2.7182
    ]

    maxInstance [
	<category: 'private'>
	^3.1415
    ]

    minInstance [
	<category: 'private'>
	^1.618
    ]

    testFromString [
	"We do some special tests here because #visitNumberDescription: in
	 MAStringReader works around problems with Number>>readFrom."

	<category: 'private'>
	self shouldSkipStringTests ifTrue: [^self].
	super testFromString.
	self 
	    should: [self description fromString: 'xyz']
	    raise: MAReadError
	    description: 'Non-numeric string should raise an error'.
	self 
	    should: [self description fromString: '12-234']
	    raise: MAReadError
	    description: 'Non-numeric string should raise an error'.
	self 
	    should: [self description fromString: '1.4.2007']
	    raise: MAReadError
	    description: 'Non-numeric string should raise an error'.
	self assert: (self description fromString: '') isNil
	    description: 'Empty string should be parsed to nil'.
	self assert: (self description fromString: '-20') = -20
	    description: 'Negative numbers should be accepted'
    ]

    testValidateConditions [
	<category: 'tests'>
	
    ]
]



MAMagnitudeDescriptionTest subclass: MATimeDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MATimeDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MATimeDescription
    ]

    excludedInstance [
	<category: 'private'>
	^Time 
	    hour: 9
	    minute: 33
	    second: 12
    ]

    includedInstance [
	<category: 'private'>
	^Time 
	    hour: 11
	    minute: 33
	    second: 12
    ]

    maxInstance [
	<category: 'private'>
	^Time 
	    hour: 12
	    minute: 33
	    second: 12
    ]

    minInstance [
	<category: 'private'>
	^Time 
	    hour: 10
	    minute: 33
	    second: 12
    ]
]



MAMagnitudeDescriptionTest subclass: MATimeStampDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MATimeStampDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MATimeStampDescription
    ]

    excludedInstance [
	<category: 'private'>
	^DateTime 
	    year: 1980
	    month: 1
	    day: 11
	    hour: 11
	    minute: 38
	    second: 12
    ]

    includedInstance [
	<category: 'private'>
	^DateTime 
	    year: 1980
	    month: 6
	    day: 11
	    hour: 11
	    minute: 38
	    second: 12
    ]

    maxInstance [
	<category: 'private'>
	^DateTime 
	    year: 1980
	    month: 6
	    day: 12
	    hour: 11
	    minute: 38
	    second: 12
    ]

    minInstance [
	<category: 'private'>
	^DateTime 
	    year: 1980
	    month: 6
	    day: 10
	    hour: 11
	    minute: 38
	    second: 12
    ]
]



MAElementDescriptionTest subclass: MAReferenceDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAReferenceDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAReferenceDescription
    ]

    referenceInstance [
	<category: 'private'>
	^MAStringDescription new
    ]

    setUp [
	<category: 'running'>
	super setUp.
	self description reference: self referenceInstance.
	self assert: self description reference accessor notNil
    ]

    testCopyReference [
	<category: 'testing-copying'>
	self assert: self description copy reference = self description reference.
	self deny: self description copy reference == self description reference
    ]
]



MAReferenceDescriptionTest subclass: MAOptionDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAOptionDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAOptionDescription
    ]

    optionInstances [
	<category: 'private'>
	^Array 
	    with: 'foo'
	    with: 'bar'
	    with: 'zork'
    ]

    setUp [
	<category: 'running'>
	super setUp.
	self description options: self optionInstances
    ]

    testAllOptions [
	<category: 'testing-accessing'>
	(self description)
	    beRequired;
	    beSorted;
	    options: #(#c #b #a).
	self assert: self description allOptions = #(#a #b #c).
	(self description)
	    beRequired;
	    beUnsorted;
	    options: #(#c #b #a).
	self assert: self description allOptions = #(#c #b #a)
    ]

    testAllOptionsWithExisting [
	<category: 'testing-accessing'>
	(self description)
	    beRequired;
	    options: #(#a #b #c).
	self assert: (self description allOptionsWith: #a) = #(#a #b #c)
    ]

    testAllOptionsWithNil [
	<category: 'testing-accessing'>
	(self description)
	    beRequired;
	    options: #(#a #b #c).
	self assert: (self description allOptionsWith: nil) = #(#a #b #c)
    ]

    testCopyOptions [
	<category: 'testing-copying'>
	self deny: self description copy options == self description options.
	self assert: self description copy options = self description options
    ]

    testFromStringInvalid [
	"There is no invalid string input."

	<category: 'testing-strings'>
	
    ]

    testOptions [
	<category: 'testing-accessing'>
	self description options: #(#a #b #c).
	self assert: self description options = #(#a #b #c)
    ]

    testOptionsAndLabels [
	<category: 'testing-strings'>
	self description reference: MANumberDescription new.
	self assert: (self description labelForOption: 1) = '1'.
	self description 
	    optionsAndLabels: (Array with: 1 -> 'one' with: 2 -> 'two').
	self assert: (self description labelForOption: 1) = 'one'.
	self assert: (self description labelForOption: 2) = 'two'.
	self assert: (self description labelForOption: 3) = '3'
    ]

    testReferencePrinting [
	<category: 'testing'>
	self description reference: MAStringDescription new.
	self assert: (self description labelForOption: 1) = '1'.
	self assert: (self description labelForOption: 1 @ 2) = '1@2'.
	self assert: (self description labelForOption: 1 -> 2) = '1->2'
    ]

    testSorted [
	<category: 'testing-properties'>
	self description beSorted.
	self assert: self description isSorted.
	self assert: self description sorted.
	self description beUnsorted.
	self deny: self description isSorted.
	self deny: self description sorted
    ]
]



MAOptionDescriptionTest subclass: MAMultipleOptionDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAMultipleOptionDescriptionTest class >> defaultUnique [
	<category: 'accessing-default'>
	^false
    ]

    MAMultipleOptionDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAMultipleOptionDescription
    ]

    includedInstance [
	<category: 'private'>
	^self optionInstances copyFrom: 1 to: 2
    ]

    testOrdered [
	<category: 'testing-properties'>
	self description beOrdered.
	self assert: self description isOrdered.
	self assert: self description ordered.
	self description beUnordered.
	self deny: self description isOrdered.
	self deny: self description ordered
    ]

    testSorted [
	<category: 'testing-properties'>
	self description beDistinct.
	self assert: self description isDistinct.
	self assert: self description distinct.
	self description beIndefinite.
	self deny: self description isDistinct.
	self deny: self description distinct
    ]
]



MAOptionDescriptionTest subclass: MASingleOptionDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MASingleOptionDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MASingleOptionDescription
    ]

    includedInstance [
	<category: 'private'>
	^self optionInstances first
    ]

    testAllOptionsOptional [
	<category: 'testing-accessing'>
	(self description)
	    beOptional;
	    beSorted;
	    options: #(#c #b #a).
	self assert: self description allOptions = #(nil #a #b #c).
	(self description)
	    beOptional;
	    beUnsorted;
	    options: #(#c #b #a).
	self assert: self description allOptions = #(nil #c #b #a)
    ]

    testAllOptionsWithExtensible [
	<category: 'testing-accessing'>
	(self description)
	    beRequired;
	    beUnsorted;
	    beLimited;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(#c #d #a).
	(self description)
	    beRequired;
	    beUnsorted;
	    beExtensible;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(#c #d #a #b).
	(self description)
	    beRequired;
	    beSorted;
	    beLimited;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(#a #c #d).
	(self description)
	    beRequired;
	    beSorted;
	    beExtensible;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(#a #b #c #d)
    ]

    testAllOptionsWithOptional [
	<category: 'testing-accessing'>
	(self description)
	    beOptional;
	    beSorted;
	    beExtensible;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(nil #a #b #c #d).
	(self description)
	    beOptional;
	    beSorted;
	    beLimited;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(nil #a #c #d).
	(self description)
	    beOptional;
	    beUnsorted;
	    beExtensible;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(nil #c #d #a #b).
	(self description)
	    beOptional;
	    beUnsorted;
	    beLimited;
	    options: #(#c #d #a).
	self assert: (self description allOptionsWith: #b) = #(nil #c #d #a)
    ]

    testExtensible [
	<category: 'testing-properties'>
	self description beExtensible.
	self assert: self description isExtensible.
	self assert: self description extensible.
	self description beLimited.
	self deny: self description isExtensible.
	self deny: self description extensible
    ]

    testGroupBy [
	<category: 'testing-properties'>
	self deny: self description isGrouped.
	self description groupBy: #grouping.
	self assert: self description isGrouped
    ]

    testGroupOf [
	<category: 'testing-properties'>
	self assert: MADateDescription grouping = 'Magnitude'
    ]
]



MAReferenceDescriptionTest subclass: MARelationDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MARelationDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MARelationDescription
    ]

    addressInstance1 [
	<category: 'private'>
	^(MAMockAddress new)
	    street: 'Tillierstrasse 17';
	    plz: 3005;
	    place: 'Bern';
	    yourself
    ]

    addressInstance2 [
	<category: 'private'>
	^(MAMockAddress new)
	    street: 'In der Au';
	    plz: 8765;
	    place: 'Engi';
	    yourself
    ]

    setUp [
	<category: 'running'>
	super setUp.
	(self description)
	    reference: MAMockAddress description;
	    classes: (Array with: MAMockAddress)
    ]

    shouldSkipStringTests [
	<category: 'private'>
	^true
    ]

    testCopyClasses [
	<category: 'testing-copying'>
	self assert: self description copy classes = self description classes.
	self deny: self description copy classes == self description classes
    ]
]



MARelationDescriptionTest subclass: MAToManyRelationDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAToManyRelationDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAToManyRelationDescription
    ]

    includedInstance [
	<category: 'private'>
	^Array with: self addressInstance1 with: self addressInstance2
    ]

    testDefinitive [
	<category: 'testing-properties'>
	self description beDefinitive.
	self assert: self description isDefinitive.
	self assert: self description definitive.
	self description beModifiable.
	self deny: self description isDefinitive.
	self deny: self description definitive
    ]

    testOrdered [
	<category: 'testing-properties'>
	self description beOrdered.
	self assert: self description isOrdered.
	self assert: self description ordered.
	self description beUnordered.
	self deny: self description isOrdered.
	self deny: self description ordered
    ]

    testSorted [
	<category: 'testing-properties'>
	self description beSorted.
	self assert: self description isSorted.
	self assert: self description sorted.
	self description beUnsorted.
	self deny: self description isSorted.
	self deny: self description sorted
    ]
]



MAToManyRelationDescriptionTest subclass: MAToManyScalarRelationDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    actualClass [
	<category: 'private'>
	^MAToManyScalarRelationDescription
    ]

    includedInstance [
	<category: 'private'>
	^Array with: '1' with: '2'
    ]

    setUp [
	<category: 'running'>
	super setUp.
	(self description)
	    reference: ((MAStringDescription new)
			accessor: MANullAccessor new;
			yourself);
	    classes: (Array with: String)
    ]
]



MARelationDescriptionTest subclass: MAToOneRelationDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAToOneRelationDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAToOneRelationDescription
    ]

    includedInstance [
	<category: 'private'>
	^self addressInstance1
    ]
]



MAReferenceDescriptionTest subclass: MATableDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MATableDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MATableDescription
    ]

    includedInstance [
	<category: 'private'>
	^MATableModel 
	    rows: 3
	    columns: 3
	    contents: #('1' '2' '3' '2' '4' '6' '3' '6' '9')
    ]

    shouldSkipStringTests [
	<category: 'private'>
	^true
    ]
]



MAReferenceDescriptionTest subclass: MATokenDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MATokenDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MATokenDescription
    ]

    includedInstance [
	<category: 'private'>
	^#('foo' 'bar')
    ]

    testFromStringInvalid [
	"There is no invalid string input."

	<category: 'testing-strings'>
	
    ]
]



MAElementDescriptionTest subclass: MAStringDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAStringDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAStringDescription
    ]

    includedInstance [
	<category: 'private'>
	^'Lukas Renggli'
    ]

    testFromStringInvalid [
	"There is no invalid string input."

	<category: 'testing-strings'>
	
    ]
]



MAStringDescriptionTest subclass: MAMemoDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    actualClass [
	<category: 'private'>
	^MAMemoDescription
    ]

    testLineCount [
	<category: 'testing-properties'>
	self description lineCount: 123.
	self assert: self description lineCount = 123
    ]
]



MAStringDescriptionTest subclass: MAPasswordDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MAPasswordDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAPasswordDescription
    ]

    testIsObfuscated [
	<category: 'testing'>
	self deny: (self description isObfuscated: '').
	self deny: (self description isObfuscated: nil).
	self deny: (self description isObfuscated: 123).
	self deny: (self description isObfuscated: '**1').
	self assert: (self description isObfuscated: '******')
    ]

    testObfuscated [
	<category: 'testing'>
	self assert: (self description obfuscated: nil) = ''.
	self assert: (self description obfuscated: 'zork') = '****'.
	self assert: (self description obfuscated: 'foobar') = '******'
    ]
]



MAStringDescriptionTest subclass: MASymbolDescriptionTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Description'>

    MASymbolDescriptionTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MASymbolDescription
    ]

    includedInstance [
	<category: 'private'>
	^#magritte
    ]

    testValidateConditions [
	<category: 'testing-validation'>
	
    ]
]



MAObjectTest subclass: MAMementoTest [
    | description memento value |
    
    <comment: nil>
    <category: 'Magritte-Tests-Memento'>

    MAMementoTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    actualClass [
	<category: 'private'>
	^MAMemento
    ]

    defaultInstance [
	<category: 'private'>
	^'Lukas Renggli'
    ]

    description [
	<category: 'accessing'>
	^description
    ]

    descriptionInstance [
	<category: 'private'>
	^MAContainer with: ((MAStringDescription new)
		    default: self defaultInstance;
		    accessor: #value;
		    yourself)
    ]

    descriptionValue [
	<category: 'accessing'>
	^self description children first
    ]

    includedInstance [
	<category: 'private'>
	^'Rene Magritte'
    ]

    instance [
	<category: 'accessing'>
	^memento
    ]

    invalidInstance [
	<category: 'private'>
	^31415
    ]

    memento [
	<category: 'accessing'>
	^memento
    ]

    mementoInstance [
	<category: 'private'>
	^self actualClass model: self modelInstance
    ]

    modelInstance [
	<category: 'private'>
	^self
    ]

    nullInstance [
	<category: 'private'>
	^nil
    ]

    otherInstance [
	<category: 'private'>
	^'Ursula Freitag'
    ]

    read [
	<category: 'accessing-memento'>
	^self memento readUsing: self descriptionValue
    ]

    setUp [
	<category: 'running'>
	super setUp.
	description := self descriptionInstance.
	memento := self mementoInstance
    ]

    testCommit [
	<category: 'testing-actions'>
	self subclassResponsibility
    ]

    testDescription [
	<category: 'testing-accessing'>
	self assert: self memento description = self description.
	self assert: self memento description = self descriptionInstance
    ]

    testModel [
	<category: 'testing-accessing'>
	self assert: self memento model = self modelInstance
    ]

    testRead [
	<category: 'testing-basic'>
	self subclassResponsibility
    ]

    testReset [
	<category: 'testing-actions'>
	self subclassResponsibility
    ]

    testValidateIncluded [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self shouldnt: [self memento validate] raise: MAValidationError
    ]

    testValidateInvalid [
	<category: 'testing-actions'>
	self write: self invalidInstance.
	self should: [self memento validate] raise: MAValidationError
    ]

    testValidateRequired [
	<category: 'testing-actions'>
	self descriptionValue beRequired.
	self write: self nullInstance.
	self should: [self memento validate] raise: MAValidationError
    ]

    testWrite [
	<category: 'testing-basic'>
	self subclassResponsibility
    ]

    value [
	<category: 'accessing-model'>
	^value
    ]

    value: anObject [
	<category: 'accessing-model'>
	value := anObject
    ]

    write: anObject [
	<category: 'accessing-memento'>
	self memento write: anObject using: self descriptionValue
    ]
]



MAMementoTest subclass: MACachedMementoTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Memento'>

    MACachedMementoTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MACachedMemento
    ]

    testCache [
	<category: 'testing-accessing'>
	self assert: self memento cache size = self description size
    ]

    testCommit [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self assert: self read = self includedInstance.
	self assert: self value = self nullInstance.
	self assert: self memento hasChanged.
	self memento commit.
	self assert: self read = self includedInstance.
	self assert: self value = self includedInstance.
	self deny: self memento hasChanged
    ]

    testRead [
	<category: 'testing-basic'>
	self assert: self read = self defaultInstance.
	self value: self includedInstance.
	self assert: self read = self defaultInstance
    ]

    testReset [
	<category: 'testing-actions'>
	self value: self defaultInstance.
	self write: self includedInstance.
	self assert: self memento hasChanged.
	self memento reset.
	self assert: self read = self defaultInstance.
	self assert: self value = self defaultInstance.
	self deny: self memento hasChanged
    ]

    testWrite [
	<category: 'testing-basic'>
	self write: self includedInstance.
	self assert: self read = self includedInstance.
	self assert: self value = self nullInstance.
	self write: self defaultInstance.
	self assert: self read = self defaultInstance.
	self assert: self value = self nullInstance
    ]
]



MACachedMementoTest subclass: MACheckedMementoTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Memento'>

    MACheckedMementoTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MACheckedMemento
    ]

    testConflictCommit [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self assert: self read = self includedInstance.
	self assert: self memento hasChanged.
	self deny: self memento hasConflict.
	self value: self otherInstance.
	self assert: self read = self includedInstance.
	self assert: self memento hasChanged.
	self assert: self memento hasConflict.
	self memento commit.
	self assert: self read = self includedInstance.
	self assert: self value = self includedInstance.
	self deny: self memento hasChanged.
	self deny: self memento hasConflict
    ]

    testConflictReset [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self assert: self read = self includedInstance.
	self assert: self memento hasChanged.
	self deny: self memento hasConflict.
	self value: self otherInstance.
	self assert: self read = self includedInstance.
	self assert: self memento hasChanged.
	self assert: self memento hasConflict.
	self memento reset.
	self assert: self read = self otherInstance.
	self assert: self value = self otherInstance.
	self deny: self memento hasChanged.
	self deny: self memento hasConflict
    ]

    testOriginal [
	<category: 'testing-accessing'>
	self assert: self memento original size = self description size
    ]

    testValidateConflictCommit [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self shouldnt: [self memento validate] raise: MAValidationError.
	self value: self otherInstance.
	self should: [self memento validate] raise: MAValidationError.
	self memento commit.
	self shouldnt: [self memento validate] raise: MAValidationError
    ]

    testValidateConflictReset [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self shouldnt: [self memento validate] raise: MAValidationError.
	self value: self otherInstance.
	self should: [self memento validate] raise: MAValidationError.
	self memento reset.
	self shouldnt: [self memento validate] raise: MAValidationError
    ]
]



MAMementoTest subclass: MAStraitMementoTest [
    
    <comment: nil>
    <category: 'Magritte-Tests-Memento'>

    MAStraitMementoTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    actualClass [
	<category: 'private'>
	^MAStraitMemento
    ]

    testCommit [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self assert: self value = self includedInstance.
	self assert: self read = self includedInstance.
	self memento commit.
	self assert: self value = self includedInstance.
	self assert: self read = self includedInstance
    ]

    testRead [
	<category: 'testing-basic'>
	self assert: self read = self defaultInstance.
	self value: self includedInstance.
	self assert: self read = self includedInstance.
	self value: self defaultInstance.
	self assert: self read = self defaultInstance
    ]

    testReset [
	<category: 'testing-actions'>
	self write: self includedInstance.
	self memento reset.
	self assert: self read = self includedInstance
    ]

    testValidateRequired [
	<category: 'testing-actions'>
	
    ]

    testWrite [
	<category: 'testing-basic'>
	self write: self includedInstance.
	self assert: self value = self includedInstance.
	self write: self defaultInstance.
	self assert: self value = self defaultInstance.
	self write: self nullInstance.
	self assert: self value = self nullInstance
    ]
]



TestCase subclass: MATableModelTest [
    | table |
    
    <comment: nil>
    <category: 'Magritte-Tests-Models'>

    setUp [
	<category: 'running'>
	table := (MATableModel rows: 3 columns: 4) 
		    collect: [:row :col :value | row raisedTo: col]
    ]

    testAtAt [
	<category: 'testing-accessing'>
	self assert: (table at: 1 at: 1) = 1.
	self assert: (table at: 2 at: 3) = 8.
	self assert: (table at: 3 at: 2) = 9.
	self assert: (table at: 3 at: 4) = 81
    ]

    testAtAtAbsent [
	<category: 'testing-accessing'>
	self should: [table at: 0 at: 1] raise: Error.
	self should: [table at: 1 at: 0] raise: Error.
	self should: [table at: 4 at: 4] raise: Error.
	self should: [table at: 3 at: 5] raise: Error
    ]

    testAtAtPut [
	<category: 'testing-accessing'>
	self assert: (table 
		    at: 1
		    at: 1
		    put: -1) = -1.
	self assert: (table 
		    at: 2
		    at: 3
		    put: -8) = -8.
	self assert: (table 
		    at: 3
		    at: 2
		    put: -9) = -9.
	self assert: (table 
		    at: 3
		    at: 4
		    put: -81) = -81.
	self assert: (table at: 1 at: 1) = -1.
	self assert: (table at: 2 at: 3) = -8.
	self assert: (table at: 3 at: 2) = -9.
	self assert: (table at: 3 at: 4) = -81
    ]

    testAtAtPutAbsent [
	<category: 'testing-accessing'>
	self should: 
		[table 
		    at: 0
		    at: 1
		    put: 0]
	    raise: Error.
	self should: 
		[table 
		    at: 1
		    at: 0
		    put: 0]
	    raise: Error.
	self should: 
		[table 
		    at: 4
		    at: 4
		    put: 0]
	    raise: Error.
	self should: 
		[table 
		    at: 3
		    at: 5
		    put: 0]
	    raise: Error
    ]

    testCollect [
	<category: 'testing-enumerating'>
	table := table collect: [:row :col :val | row + col + val].
	table 
	    do: [:row :col :val | self assert: (row raisedTo: col) = (val - row - col)]
    ]

    testContents [
	<category: 'testing-accessing'>
	self assert: table contents = #(1 1 1 1 2 4 8 16 3 9 27 81)
    ]

    testCopy [
	<category: 'testing-copying'>
	self assert: table copy rowCount = table rowCount.
	self assert: table copy columnCount = table columnCount.
	self assert: table copy contents = table contents.
	self deny: table copy contents == table contents
    ]

    testCopyEmpty [
	<category: 'testing-copying'>
	self assert: table copyEmpty rowCount = table rowCount.
	self assert: table copyEmpty columnCount = table columnCount.
	self assert: (table copyEmpty contents allSatisfy: [:each | each isNil])
    ]

    testCopyRowsColumns [
	<category: 'testing-copying'>
	self assert: (table copyRows: 1 columns: 2) rowCount = 1.
	self assert: (table copyRows: 1 columns: 2) columnCount = 2.
	self assert: (table copyRows: 1 columns: 2) contents = #(1 1).
	self assert: (table copyRows: 4 columns: 3) rowCount = 4.
	self assert: (table copyRows: 4 columns: 3) columnCount = 3.
	self assert: (table copyRows: 4 columns: 3) contents 
		    = #(1 1 1 2 4 8 3 9 27 nil nil nil)
    ]

    testCoumnCount [
	<category: 'testing-accessing'>
	self assert: table columnCount = 4
    ]

    testDo [
	<category: 'testing-enumerating'>
	table do: [:row :col :val | self assert: (row raisedTo: col) = val]
    ]

    testEqual [
	<category: 'testing-comparing'>
	self assert: table = table.
	self assert: table = table copy.
	self assert: table copy = table.
	self assert: table copy = table copy.
	self deny: table = (table copy 
			    at: 1
			    at: 2
			    put: 3).
	self deny: table = (table copyRows: 3 columns: 3).
	self deny: table = (table copyRows: 4 columns: 4)
    ]

    testHash [
	<category: 'testing-comparing'>
	self assert: table hash = table hash.
	self assert: table hash = table copy hash.
	self assert: table copy hash = table hash.
	self assert: table copy hash = table copy hash
    ]

    testRowCount [
	<category: 'testing-accessing'>
	self assert: table rowCount = 3
    ]

    testSetup [
	<category: 'testing'>
	self assert: table rowCount = 3.
	self assert: table columnCount = 4.
	self assert: table contents = #(1 1 1 1 2 4 8 16 3 9 27 81)
    ]
]

PK
     �Mh@M�D��K �K           ��    magritte-model.stUT dqXOux �  �  PK    �Mh@W�Nle  �           ��L PORTINGUT dqXOux �  �  PK
     �[h@x�>=  =            ���O package.xmlUT ÉXOux �  �  PK
     �Mh@�I��'  �'            ��@R magritte-gst.stUT dqXOux �  �  PK    �Mh@��C��     	         ��Bz ChangeLogUT dqXOux �  �  PK
     �Mh@iY �~ ~           ��A{ magritte-tests.stUT dqXOux �  �  PK      �  ��   