PK
     \h@G�/�M  M    package.xmlUT	 ԊXOԊXOux �  �  <package>
  <name>SUnit</name>
  <test>
    <prereq>SUnit</prereq>
    <sunit>SUnitTest</sunit>
    <sunit>TestSuitesScriptTest</sunit>
  
    <filein>SUnitTests.st</filein>
    <filein>SUnitScriptTests.st</filein>
  </test>

  <filein>SUnitPreload.st</filein>
  <filein>SUnit.st</filein>
  <filein>SUnitScript.st</filein>
</package>PK
     �Mh@�f=��  �    SUnitScript.stUT	 eqXOԊXOux �  �  "======================================================================
|
|   SUnit testing framework scripting system
|
|   This file is in the public domain.
|
 ======================================================================"



Object subclass: TestSuitesScripter [
    | script stream variables |
    
    <category: 'SUnit'>
    <comment: nil>

    Current := nil.

    TestSuitesScripter class >> run: script quiet: quiet verbose: verbose [
	<category: 'Init / Release'>
	| result |
	result := self withScript: script
		    do: 
			[:scripter | 
			| suite |
			suite := scripter value.

			"Set log policy to write to stdout."
			quiet ifTrue: [suite logPolicy: TestLogPolicy null].
			verbose ifTrue: [suite logPolicy: (TestVerboseLog on: stdout)].
			(quiet or: [verbose]) 
			    ifFalse: [suite logPolicy: (TestCondensedLog on: stdout)].
			suite run].

	"Print result depending on verboseness."
	quiet 
	    ifFalse: 
		[result runCount < result passedCount ifTrue: [stdout nl].
		result printNl.
		result errorCount > 0 
		    ifTrue: 
			[stdout
			    nextPutAll: 'Errors:';
			    nl.
			(result errors 
			    asSortedCollection: [:a :b | a printString <= b printString]) do: 
				    [:each | 
				    stdout
					nextPutAll: '    ';
					print: each;
					nl]].
		result failureCount > 0 
		    ifTrue: 
			[stdout
			    nextPutAll: 'Failures:';
			    nl.
			(result failures 
			    asSortedCollection: [:a :b | a printString <= b printString]) do: 
				    [:each | 
				    stdout
					nextPutAll: '    ';
					print: each;
					nl]]].
	^result
    ]

    TestSuitesScripter class >> current [
	<category: 'Init / Release'>
	^Current
    ]

    TestSuitesScripter class >> variableAt: aString ifAbsent: aBlock [
	<category: 'Init / Release'>
	self current isNil ifTrue: [^aBlock value].
	^self current variableAt: aString ifAbsent: aBlock
    ]

    TestSuitesScripter class >> run: aString [
	<category: 'Init / Release'>
	^self withScript: aString do: [:scripter | scripter value run]
    ]

    TestSuitesScripter class >> withScript: aString do: aBlock [
	<category: 'Init / Release'>
	| previous |
	previous := Current.
	^[aBlock value: (Current := self script: aString)] 
	    sunitEnsure: [Current := previous]
    ]

    TestSuitesScripter class >> script: aString [
	<category: 'Init / Release'>
	^self new setScript: aString
    ]

    printOn: aStream [
	<category: 'Printing'>
	super printOn: aStream.
	script isNil ifTrue: [^self].
	aStream
	    nextPut: $<;
	    nextPutAll: script;
	    nextPut: $>
    ]

    singleSuiteScript: aString [
	<category: 'Private'>
	| useHierarchy realName testCase |
	aString last = $* 
	    ifTrue: 
		[realName := aString copyFrom: 1 to: aString size - 1.
		useHierarchy := true]
	    ifFalse: 
		[realName := aString.
		useHierarchy := false].
	realName isEmpty ifTrue: [^nil].
	testCase := SUnitNameResolver classNamed: realName.
	testCase isNil ifTrue: [^nil].
	^useHierarchy 
	    ifTrue: [self hierarchyOfTestSuitesFrom: testCase]
	    ifFalse: [testCase suite]
    ]

    variableAt: aString put: valueString [
	<category: 'Private'>
	^variables at: aString put: valueString
    ]

    variableAt: aString ifAbsent: aBlock [
	<category: 'Private'>
	^variables at: aString ifAbsent: aBlock
    ]

    parseVariable: name [
	<category: 'Private'>
	| value ch |
	name isEmpty ifTrue: [self error: 'empty variable name'].
	(stream peekFor: $') 
	    ifFalse: 
		[value := stream peek isSeparator 
			    ifTrue: ['']
			    ifFalse: [(self getNextWord: '') ifNil: ['']].
		^self variableAt: name put: value].
	value := WriteStream on: String new.
	
	[stream atEnd ifTrue: [self error: 'unterminated string'].
	(ch := stream next) ~= $' or: [stream peekFor: $']] 
		whileTrue: [value nextPut: ch].
	^self variableAt: name put: value contents
    ]

    getNextToken [
	<category: 'Private'>
	| word |
	
	[self skipWhitespace.
	word := self getNextWord: '='.
	stream peekFor: $=] 
		whileTrue: [self parseVariable: word].
	^word
    ]

    skipWhitespace [
	<category: 'Private'>
	
	[self skipComments.
	stream atEnd ifTrue: [^nil].
	stream peek isSeparator] 
		whileTrue: [stream next]
    ]

    getNextWord: extraDelimiters [
	<category: 'Private'>
	| word ch |
	stream atEnd ifTrue: [^nil].
	word := WriteStream on: String new.
	
	[ch := stream peek.
	ch isSeparator ifTrue: [^word contents].
	(extraDelimiters includes: ch) ifTrue: [^word contents].
	word nextPut: stream next.
	stream atEnd ifTrue: [^word contents]] 
		repeat
    ]

    hierarchyOfTestSuitesFrom: aTestCase [
	<category: 'Private'>
	| subSuite |
	subSuite := TestSuite new.
	aTestCase isAbstract ifFalse: [subSuite addTest: aTestCase suite].
	aTestCase allSubclasses 
	    do: [:each | each isAbstract ifFalse: [subSuite addTest: each suite]].
	^subSuite
    ]

    setScript: aString [
	<category: 'Private'>
	variables := Dictionary new.
	script := aString
    ]

    skipComments [
	<category: 'Private'>
	[stream peekFor: $"] whileTrue: [stream skipTo: $"]
    ]

    value [
	<category: 'Scripting'>
	| suite subSuite token |
	suite := TestSuite new.
	stream := ReadStream on: script.
	[stream atEnd] whileFalse: 
		[token := self getNextToken.
		token notNil 
		    ifTrue: 
			[subSuite := self singleSuiteScript: token.
			subSuite notNil ifTrue: [suite addTest: subSuite]]].
	^suite
    ]
]

PK
     �Mh@�9�+%\  %\    SUnit.stUT	 eqXOԊXOux �  �  Object subclass: TestSuite [
    | tests resources name |
    
    <category: 'SUnit'>
    <comment: '
This is a Composite of Tests, either TestCases or other TestSuites. The common protocol is #run: aTestResult and the dependencies protocol'>

    TestSuite class >> named: aString [
	<category: 'Creation'>
	^(self new)
	    name: aString;
	    yourself
    ]

    run [
	<category: 'Running'>
	| result |
	result := TestResult new.
	self resources 
	    do: [:res | res isAvailable ifFalse: [^res signalInitializationError]].
	[self run: result] sunitEnsure: [self resources do: [:each | each reset]].
	^result
    ]

    run: aResult [
	<category: 'Running'>
	self tests do: 
		[:each | 
		self sunitChanged: each.
		each run: aResult]
    ]

    addTest: aTest [
	<category: 'Accessing'>
	self tests add: aTest
    ]

    addTests: aCollection [
	<category: 'Accessing'>
	aCollection do: [:eachTest | self addTest: eachTest]
    ]

    defaultResources [
	<category: 'Accessing'>
	^self tests inject: Set new
	    into: 
		[:coll :testCase | 
		coll
		    addAll: testCase resources;
		    yourself]
    ]

    isLogging [
	<category: 'Accessing'>
	^true
    ]

    logPolicy: aLogPolicy [
	<category: 'Accessing'>
	self tests 
	    do: [:each | each isLogging ifTrue: [each logPolicy: aLogPolicy]]
    ]

    name [
	<category: 'Accessing'>
	^name
    ]

    name: aString [
	<category: 'Accessing'>
	name := aString
    ]

    resources [
	<category: 'Accessing'>
	resources isNil ifTrue: [resources := self defaultResources].
	^resources
    ]

    resources: anObject [
	<category: 'Accessing'>
	resources := anObject
    ]

    tests [
	<category: 'Accessing'>
	tests isNil ifTrue: [tests := OrderedCollection new].
	^tests
    ]

    addDependentToHierachy: anObject [
	<category: 'Dependencies'>
	self sunitAddDependent: anObject.
	self tests do: [:each | each addDependentToHierachy: anObject]
    ]

    removeDependentFromHierachy: anObject [
	<category: 'Dependencies'>
	self sunitRemoveDependent: anObject.
	self tests do: [:each | each removeDependentFromHierachy: anObject]
    ]
]



Object subclass: TestResource [
    | name description |
    
    <category: 'SUnit'>
    <comment: nil>

    TestResource class [
	| current |
	
    ]

    TestResource class >> new [
	<category: 'Creation'>
	^super new initialize
    ]

    TestResource class >> reset [
	<category: 'Creation'>
	current notNil ifTrue: [[current tearDown] ensure: [current := nil]]
    ]

    TestResource class >> signalInitializationError [
	<category: 'Creation'>
	^TestResult 
	    signalErrorWith: 'Resource ' , self name , ' could not be initialized'
    ]

    TestResource class >> isAbstract [
	"Override to true if a TestResource subclass is Abstract and should not have
	 TestCase instances built from it"

	<category: 'Testing'>
	^self name = #TestResource
    ]

    TestResource class >> isAvailable [
	<category: 'Testing'>
	^self current notNil and: [self current isAvailable]
    ]

    TestResource class >> isUnavailable [
	<category: 'Testing'>
	^self isAvailable not
    ]

    TestResource class >> current [
	<category: 'Accessing'>
	current isNil ifTrue: [current := self new].
	^current
    ]

    TestResource class >> current: aTestResource [
	<category: 'Accessing'>
	current := aTestResource
    ]

    TestResource class >> resources [
	<category: 'Accessing'>
	^#()
    ]

    description [
	<category: 'Accessing'>
	description isNil ifTrue: [^''].
	^description
    ]

    description: aString [
	<category: 'Accessing'>
	description := aString
    ]

    name [
	<category: 'Accessing'>
	name isNil ifTrue: [^self printString].
	^name
    ]

    name: aString [
	<category: 'Accessing'>
	name := aString
    ]

    resources [
	<category: 'Accessing'>
	^self class resources
    ]

    setUp [
	"Does nothing. Subclasses should override this
	 to initialize their resource"

	<category: 'Running'>
	
    ]

    signalInitializationError [
	<category: 'Running'>
	^self class signalInitializationError
    ]

    tearDown [
	"Does nothing. Subclasses should override this
	 to tear down their resource"

	<category: 'Running'>
	
    ]

    isAvailable [
	"override to provide information on the
	 readiness of the resource"

	<category: 'Testing'>
	^true
    ]

    isUnavailable [
	"override to provide information on the
	 readiness of the resource"

	<category: 'Testing'>
	^self isAvailable not
    ]

    printOn: aStream [
	<category: 'Printing'>
	aStream nextPutAll: self class printString
    ]

    initialize [
	<category: 'Init / Release'>
	self setUp
    ]
]



Object subclass: TestResult [
    | failures errors passed |
    
    <category: 'SUnit'>
    <comment: '
This is a Collecting Parameter for the running of a bunch of tests. TestResult is an interesting object to subclass or substitute. #runCase: is the external protocol you need to reproduce. Kent has seen TestResults that recorded coverage information and that sent email when they were done.'>

    TestResult class >> error [
	<category: 'Exceptions'>
	^SUnitNameResolver errorObject
    ]

    TestResult class >> failure [
	<category: 'Exceptions'>
	^TestFailure
    ]

    TestResult class >> resumableFailure [
	<category: 'Exceptions'>
	^ResumableTestFailure
    ]

    TestResult class >> signalErrorWith: aString [
	<category: 'Exceptions'>
	self error sunitSignalWith: aString
    ]

    TestResult class >> signalFailureWith: aString [
	<category: 'Exceptions'>
	self failure sunitSignalWith: aString
    ]

    TestResult class >> new [
	<category: 'Init / Release'>
	^super new initialize
    ]

    correctCount [
	"depreciated - use #passedCount"

	<category: 'Accessing'>
	^self passedCount
    ]

    defects [
	<category: 'Accessing'>
	^(OrderedCollection new)
	    addAll: self errors;
	    addAll: self failures;
	    yourself
    ]

    errorCount [
	<category: 'Accessing'>
	^self errors size
    ]

    errors [
	<category: 'Accessing'>
	^self unexpectedErrors
    ]

    expectedDefectCount [
	<category: 'Accessing'>
	^self expectedDefects size
    ]

    expectedDefects [
	<category: 'Accessing'>
	^errors , failures asOrderedCollection
	    select: [:each | each shouldPass not]
    ]

    expectedPassCount [
	<category: 'Accessing'>
	^self expectedPasses size
    ]

    expectedPasses [
	<category: 'Accessing'>
	^passed select: [:each | each shouldPass]
    ]

    unexpectedErrorCount [
	<category: 'Accessing'>
	^self unexpectedErrors size
    ]

    unexpectedErrors [
	<category: 'Accessing'>
	^errors select: [:each | each shouldPass]
    ]

    unexpectedFailureCount [
	<category: 'Accessing'>
	^self unexpectedFailures size
    ]

    unexpectedFailures [
	<category: 'Accessing'>
	^failures select: [:each | each shouldPass]
    ]

    unexpectedPassCount [
	<category: 'Accessing'>
	^self unexpectedPasses size
    ]

    unexpectedPasses [
	<category: 'Accessing'>
	^passed select: [:each | each shouldPass not]
    ]

    failureCount [
	<category: 'Accessing'>
	^self failures size
    ]

    failures [
	<category: 'Accessing'>
	^failures
    ]

    passed [
	<category: 'Accessing'>
	^self expectedPasses, self expectedDefects
    ]

    passedCount [
	<category: 'Accessing'>
	^self passed size
    ]

    runCount [
	<category: 'Accessing'>
	^passed size + failures size + errors size
    ]

    tests [
	<category: 'Accessing'>
	^(OrderedCollection new: self runCount)
	    addAll: passed;
	    addAll: errors;
	    addAll: failures;
	    yourself
    ]

    hasErrors [
	<category: 'Testing'>
	^self errors size > 0
    ]

    hasFailures [
	<category: 'Testing'>
	^self failures size > 0
    ]

    hasPassed [
	<category: 'Testing'>
	^self hasErrors not and: [self hasFailures not]
    ]

    isError: aTestCase [
	<category: 'Testing'>
	^self errors includes: aTestCase
    ]

    isFailure: aTestCase [
	<category: 'Testing'>
	^self failures includes: aTestCase
    ]

    isPassed: aTestCase [
	<category: 'Testing'>
	^self passed includes: aTestCase
    ]

    initialize [
	<category: 'Init / Release'>
	errors := Set new.
	failures := Set new.
	passed := OrderedCollection new.
    ]

    runCase: aTestCase [
	<category: 'Running'>
	| testCasePassed |
	aTestCase logPolicy startTestCase: aTestCase.
	testCasePassed := 
		[
		[aTestCase runCase.
		true] sunitOn: self class failure
			do: 
			    [:signal | 
			    failures add: aTestCase.
			    signal sunitExitWith: false]] 
			sunitOn: self class error
			do: 
			    [:signal | 
			    (errors includes: aTestCase) ifFalse: [aTestCase logError: signal].
			    errors add: aTestCase.
			    signal sunitExitWith: false].
	aTestCase logPolicy flush.
	testCasePassed ifTrue: [passed add: aTestCase]
    ]

    printOn: aStream [
	<category: 'Printing'>
	aStream
	    nextPutAll: self runCount printString;
	    nextPutAll: ' run'.
        self expectedPassCount > 0 ifTrue: [
            aStream
                nextPutAll: ', ';
	        nextPutAll: self expectedPassCount printString;
	        nextPutAll: ' passes' ].
        self expectedDefectCount > 0 ifTrue: [
            aStream
                nextPutAll: ', ';
	        nextPutAll: self expectedDefectCount printString;
	        nextPutAll: ' expected failures' ].
        self unexpectedFailureCount > 0 ifTrue: [
            aStream
                nextPutAll: ', ';
	        nextPutAll: self unexpectedFailureCount printString;
	        nextPutAll: ' failures' ].
        self unexpectedErrorCount > 0 ifTrue: [
            aStream
                nextPutAll: ', ';
	        nextPutAll: self unexpectedErrorCount printString;
	        nextPutAll: ' errors' ].
        self unexpectedPassCount > 0 ifTrue: [
            aStream
                nextPutAll: ', ';
	        nextPutAll: self unexpectedPassCount printString;
	        nextPutAll: ' unexpected passes' ]
    ]
]



Object subclass: TestLogPolicy [
    | logDevice testCase |
    
    <category: 'SUnit'>
    <comment: '
A TestLogPolicy is a Strategy to log failures and successes within an
SUnit test suite.  Besides providing a null logging policy, this class
provides some common accessors and intention-revealing methdods.

Instance Variables:
    logDevice	<Stream>	the device on which the test results are logged
    testCase	<Object>	the test case that''s being run

'>

    TestLogPolicy class >> null [
	<category: 'Instance Creation'>
	^TestLogPolicy on: (WriteStream on: String new)
    ]

    TestLogPolicy class >> on: aStream [
	<category: 'Instance Creation'>
	^self new initialize: aStream
    ]

    initialize: aStream [
	<category: 'Initializing'>
	logDevice := aStream
    ]

    logDevice [
	<category: 'Accessing'>
	^logDevice
    ]

    testCase [
	<category: 'Accessing'>
	^testCase
    ]

    flush [
	<category: 'logging'>
	logDevice flush
    ]

    logError: exception [
	<category: 'logging'>
	
    ]

    logFailure: failure [
	<category: 'logging'>
	
    ]

    logSuccess [
	<category: 'logging'>
	
    ]

    nextPut: aCharacter [
	<category: 'logging'>
	logDevice nextPut: aCharacter
    ]

    nextPutAll: aString [
	<category: 'logging'>
	logDevice nextPutAll: aString
    ]

    print: anObject [
	<category: 'logging'>
	anObject printOn: logDevice
    ]

    showCr: aString [
	<category: 'logging'>
	logDevice
	    nextPutAll: aString;
	    nl
    ]

    space [
	<category: 'logging'>
	logDevice nextPut: $ 
    ]

    startTestCase: aTestCase [
	<category: 'logging'>
	testCase := aTestCase
    ]
]



TestLogPolicy subclass: TestVerboseLog [
    | hadSuccesses |
    
    <category: 'SUnit'>
    <comment: '
TestVerboseLog logs tests in this format

TestCaseName>>#testMethod1 .
TestCaseName>>#testMethod2 ..
TestCaseName>>#testMethod3 ....
FAILURE: failure description 1
...
ERROR
FAILURE: failure description 2
TestCaseName>>#testMethod4 .................

where each dot is a successful assertion.'>

    flush [
	<category: 'logging'>
	hadSuccesses ifTrue: [self showCr: ''].
	hadSuccesses := false.
	super flush
    ]

    logError: exception [
	<category: 'logging'>
	exception messageText displayNl.
	Smalltalk backtrace.
	self flush.
	self showCr: 'ERROR'
    ]

    logFailure: failure [
	<category: 'logging'>
	self flush.
	(failure isNil)
	    ifTrue: [self showCr: 'FAILURE: Assertion failed'];
	    ifFalse: [self showCr: 'FAILURE: ' , failure]
    ]

    logSuccess [
	<category: 'logging'>
	hadSuccesses := true.
	self nextPut: $.
    ]

    startTestCase: aTestCase [
	<category: 'logging'>
	super startTestCase: aTestCase.
	hadSuccesses := true.
	self
	    print: aTestCase;
	    space
    ]
]



TestVerboseLog subclass: TestCondensedLog [
    | realLogDevice hadProblems |
    
    <category: 'SUnit'>
    <comment: '
TestCondensedLog logs tests in the same format as TestVerboseLog,
but omits tests that pass.
'>

    flush [
	<category: 'logging'>
	super flush.
	hadProblems 
	    ifTrue: 
		[realLogDevice
		    nextPutAll: self logDevice contents;
		    flush].
	self logDevice reset
    ]

    initialize: aStream [
	<category: 'logging'>
	realLogDevice := aStream.
	super initialize: (WriteStream on: String new)
    ]

    logError: exception [
	<category: 'logging'>
	hadProblems := true.
	super logError: exception
    ]

    logFailure: failure [
	<category: 'logging'>
	hadProblems := true.
	super logFailure: failure
    ]

    startTestCase: aTestCase [
	<category: 'logging'>
	hadProblems := false.
	super startTestCase: aTestCase
    ]
]



TestLogPolicy subclass: TestFailureLog [
    
    <category: 'SUnit'>
    <comment: '
TestFailureLog implements logging exactly like SUnit 3.1.
'>

    logFailure: failure [
	<category: 'logging'>
	failure isNil 
	    ifFalse: 
		[self
		    print: self testCase;
		    nextPutAll: ': ';
		    showCr: failure]
    ]
]



Object subclass: TestCase [
    | testSelector logPolicy |
    
    <category: 'SUnit'>
    <comment: '
A TestCase is a Command representing the future running of a test case. Create one with the class method #selector: aSymbol, passing the name of the method to be run when the test case runs.

When you discover a new fixture, subclass TestCase, declare instance variables for the objects in the fixture, override #setUp to initialize the variables, and possibly override# tearDown to deallocate any external resources allocated in #setUp.

When you are writing a test case method, send #assert: aBoolean when you want to check for an expected value. For example, you might say "self assert: socket isOpen" to test whether or not a socket is open at a point in a test.'>

    TestCase class >> debug: aSymbol [
	<category: 'Instance Creation'>
	^(self selector: aSymbol) debug
    ]

    TestCase class >> run: aSymbol [
	<category: 'Instance Creation'>
	^(self selector: aSymbol) run
    ]

    TestCase class >> selector: aSymbol [
	<category: 'Instance Creation'>
	^self new setTestSelector: aSymbol
    ]

    TestCase class >> suite [
	<category: 'Instance Creation'>
	^self buildSuite
    ]

    TestCase class >> buildSuite [
	<category: 'Building Suites'>
	| suite |
	^self isAbstract 
	    ifTrue: 
		[suite := self suiteClass named: self name asString.
		self allSubclasses 
		    do: [:each | each isAbstract ifFalse: [suite addTest: each buildSuiteFromSelectors]].
		suite]
	    ifFalse: [self buildSuiteFromSelectors]
    ]

    TestCase class >> buildSuiteFromAllSelectors [
	<category: 'Building Suites'>
	^self buildSuiteFromMethods: self allTestSelectors
    ]

    TestCase class >> buildSuiteFromLocalSelectors [
	<category: 'Building Suites'>
	^self buildSuiteFromMethods: self testSelectors
    ]

    TestCase class >> buildSuiteFromMethods: testMethods [
	<category: 'Building Suites'>
	^testMethods inject: (self suiteClass named: self name asString)
	    into: 
		[:suite :selector | 
		suite
		    addTest: (self selector: selector);
		    yourself]
    ]

    TestCase class >> buildSuiteFromSelectors [
	<category: 'Building Suites'>
	^self shouldInheritSelectors 
	    ifTrue: [self buildSuiteFromAllSelectors]
	    ifFalse: [self buildSuiteFromLocalSelectors]
    ]

    TestCase class >> suiteClass [
	<category: 'Building Suites'>
	^TestSuite
    ]

    TestCase class >> allTestSelectors [
	<category: 'Accessing'>
	^self sunitAllSelectors select: [:each | 'test*' sunitMatch: each]
    ]

    TestCase class >> resources [
	<category: 'Accessing'>
	^#()
    ]

    TestCase class >> sunitVersion [
	<category: 'Accessing'>
	^'3.1'
    ]

    TestCase class >> testSelectors [
	<category: 'Accessing'>
	^self sunitSelectors select: [:each | 'test*' sunitMatch: each]
    ]

    TestCase class >> isAbstract [
	"Override to true if a TestCase subclass is Abstract and should not have
	 TestCase instances built from it"

	<category: 'Testing'>
	^self name = #TestCase
    ]

    TestCase class >> shouldInheritSelectors [
	"I should inherit from an Abstract superclass but not from a concrete one by default, unless I have no testSelectors in which case I must be expecting to inherit them from my superclass.  If a test case with selectors wants to inherit selectors from a concrete superclass, override this to true in that subclass."

	<category: 'Testing'>
	^self superclass isAbstract or: 
		[self testSelectors isEmpty

		"$QA Ignore:Sends system method(superclass)$"]
    ]

    assert: aBoolean [
	<category: 'Accessing'>
	aBoolean 
	    ifTrue: [self logSuccess]
	    ifFalse: 
		[self logFailure: nil.
		TestResult failure sunitSignalWith: 'Assertion failed']
    ]

    assert: aBoolean description: aString [
	<category: 'Accessing'>
	aBoolean 
	    ifTrue: [self logSuccess]
	    ifFalse: 
		[self logFailure: aString.
		TestResult failure sunitSignalWith: aString]
    ]

    assert: aBoolean description: aString resumable: resumableBoolean [
	<category: 'Accessing'>
	| exception |
	aBoolean 
	    ifTrue: [self logSuccess]
	    ifFalse: 
		[self logFailure: aString.
		exception := resumableBoolean 
			    ifTrue: [TestResult resumableFailure]
			    ifFalse: [TestResult failure].
		exception sunitSignalWith: aString]
    ]

    deny: aBoolean [
	<category: 'Accessing'>
	self assert: aBoolean not
    ]

    deny: aBoolean description: aString [
	<category: 'Accessing'>
	self assert: aBoolean not description: aString
    ]

    deny: aBoolean description: aString resumable: resumableBoolean [
	<category: 'Accessing'>
	self 
	    assert: aBoolean not
	    description: aString
	    resumable: resumableBoolean
    ]

    logError: aSignal [
	<category: 'Accessing'>
	self logPolicy logError: aSignal
    ]

    logFailure: anObject [
	<category: 'Accessing'>
	self logPolicy logFailure: anObject
    ]

    logPolicy [
	<category: 'Accessing'>
	logPolicy isNil ifTrue: [logPolicy := self defaultLogPolicy].
	^logPolicy
    ]

    logPolicy: aLogPolicy [
	<category: 'Accessing'>
	logPolicy := aLogPolicy
    ]

    logSuccess [
	<category: 'Accessing'>
	self logPolicy logSuccess
    ]

    defaultLogPolicy [
	<category: 'Accessing'>
	^self isLogging 
	    ifTrue: [self defaultLogPolicyClass on: self failureLog]
	    ifFalse: [TestLogPolicy null]
    ]

    defaultLogPolicyClass [
	<category: 'Accessing'>
	^TestCondensedLog
    ]

    resources [
	<category: 'Accessing'>
	| allResources resourceQueue |
	allResources := Set new.
	resourceQueue := OrderedCollection new.
	resourceQueue addAll: self class resources.
	[resourceQueue isEmpty] whileFalse: 
		[| next |
		next := resourceQueue removeFirst.
		allResources add: next.
		resourceQueue addAll: next resources].
	^allResources
    ]

    selector [
	<category: 'Accessing'>
	^testSelector
    ]

    should: aBlock [
	<category: 'Accessing'>
	self assert: aBlock value
    ]

    should: aBlock description: aString [
	<category: 'Accessing'>
	self assert: aBlock value description: aString
    ]

    should: aBlock raise: anExceptionalEvent [
	<category: 'Accessing'>
	^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent)
    ]

    should: aBlock raise: anExceptionalEvent description: aString [
	<category: 'Accessing'>
	^self assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent)
	    description: aString
    ]

    shouldnt: aBlock [
	<category: 'Accessing'>
	self deny: aBlock value
    ]

    shouldnt: aBlock description: aString [
	<category: 'Accessing'>
	self deny: aBlock value description: aString
    ]

    shouldnt: aBlock raise: anExceptionalEvent [
	<category: 'Accessing'>
	^self 
	    assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent) not
    ]

    shouldnt: aBlock raise: anExceptionalEvent description: aString [
	<category: 'Accessing'>
	^self 
	    assert: (self executeShould: aBlock inScopeOf: anExceptionalEvent) not
	    description: aString
    ]

    signalFailure: aString [
	<category: 'Accessing'>
	TestResult failure sunitSignalWith: aString
    ]

    debug [
	<category: 'Running'>
	self resources 
	    do: [:res | res isAvailable ifFalse: [^res signalInitializationError]].
	[(self class selector: testSelector)
		logPolicy: TestLogPolicy null;
		runCase] 
	    sunitEnsure: [self resources do: [:each | each reset]]
    ]

    debugAsFailure [
	<category: 'Running'>
	| semaphore |
	semaphore := Semaphore new.
	self resources 
	    do: [:res | res isAvailable ifFalse: [^res signalInitializationError]].
	
	[semaphore wait.
	self resources do: [:each | each reset]] fork.
	(self class selector: testSelector) runCaseAsFailure: semaphore
    ]

    failureLog [
	<category: 'Running'>
	^SUnitNameResolver defaultLogDevice
    ]

    isLogging [
	"By default, we're not logging failures. If you override this in
	 a subclass, make sure that you override #failureLog"

	<category: 'Running'>
	^true
    ]

    openDebuggerOnFailingTestMethod [
	"SUnit has halted one step in front of the failing test method. Step over the 'self halt' and
	 send into 'self perform: testSelector' to see the failure from the beginning"

	<category: 'Running'>
	self
	    halt;
	    performTest
    ]

    run [
	<category: 'Running'>
	| result |
	result := TestResult new.
	self run: result.
	^result
    ]

    run: aResult [
	<category: 'Running'>
	aResult runCase: self
    ]

    runCase [
	<category: 'Running'>
	
	[self setUp.
	self performTest] sunitEnsure: [self tearDown]
    ]

    runCaseAsFailure: aSemaphore [
	<category: 'Running'>
	
	[self setUp.
	self openDebuggerOnFailingTestMethod] sunitEnsure: 
		    [self tearDown.
		    aSemaphore signal]
    ]

    setUp [
	<category: 'Running'>
	
    ]

    tearDown [
	<category: 'Running'>
	
    ]

    expectedFailures [
	<category: 'Testing'>
	^Array new
    ]

    shouldPass [
	"Unless the selector is in the list we get from #expectedFailures, we expect it to pass"

	<category: 'Testing'>
	^(self expectedFailures includes: testSelector) not
    ]

    executeShould: aBlock inScopeOf: anExceptionalEvent [
	<category: 'Private'>
	^
	[aBlock value.
	false] sunitOn: anExceptionalEvent
		do: [:ex | ex sunitExitWith: true]
    ]

    performTest [
	<category: 'Private'>
	self perform: testSelector sunitAsSymbol
    ]

    setTestSelector: aSymbol [
	<category: 'Private'>
	testSelector := aSymbol
    ]

    addDependentToHierachy: anObject [
	"an empty method. for Composite compability with TestSuite"

	<category: 'Dependencies'>
	
    ]

    removeDependentFromHierachy: anObject [
	"an empty method. for Composite compability with TestSuite"

	<category: 'Dependencies'>
	
    ]

    printOn: aStream [
	<category: 'Printing'>
	aStream
	    nextPutAll: self class printString;
	    nextPutAll: '>>#';
	    nextPutAll: testSelector
    ]
]

PK
     �Mh@� ��.  �.    SUnitTests.stUT	 eqXOԊXOux �  �  TestCase subclass: ResumableTestFailureTestCase [
    
    <comment: nil>
    <category: 'SUnit-SUnitTests'>

    errorTest [
	<category: 'Not categorized'>
	1 zork
    ]

    failureLog [
	<category: 'Not categorized'>
	^SUnitNameResolver defaultLogDevice
    ]

    failureTest [
	<category: 'Not categorized'>
	self
	    assert: false
		description: 'You should see me'
		resumable: true;
	    assert: false
		description: 'You should see me too'
		resumable: true;
	    assert: false
		description: 'You should see me last'
		resumable: false;
	    assert: false
		description: 'You should not see me'
		resumable: true
    ]

    isLogging [
	<category: 'Not categorized'>
	^false
    ]

    okTest [
	<category: 'Not categorized'>
	self assert: true
    ]

    regularTestFailureTest [
	<category: 'Not categorized'>
	self assert: false description: 'You should see me'
    ]

    resumableTestFailureTest [
	<category: 'Not categorized'>
	self
	    assert: false
		description: 'You should see me'
		resumable: true;
	    assert: false
		description: 'You should see me too'
		resumable: true;
	    assert: false
		description: 'You should see me last'
		resumable: false;
	    assert: false
		description: 'You should not see me'
		resumable: true
    ]

    testResumable [
	<category: 'Not categorized'>
	| result suite |
	suite := TestSuite new.
	suite addTest: (self class selector: #errorTest).
	suite addTest: (self class selector: #regularTestFailureTest).
	suite addTest: (self class selector: #resumableTestFailureTest).
	suite addTest: (self class selector: #okTest).
	result := suite run.
	self
	    assert: result failures size = 2;
	    assert: result errors size = 1
    ]
]



TestCase subclass: SUnitTest [
    
    <comment: '
This is both an example of writing tests and a self test for the SUnit. The tests 
run the SUnitClientTests and make sure that things blow up correctly. Your
tests will usually be far more complicated in terms of your own objects- more
assertions, more complicated setup. Kent says: "Never forget, however, that
if the tests are hard to write, something is probably wrong with the design".'>
    <category: 'SUnit-SUnitTests'>

    SUnitTest class >> shouldInheritSelectors [
	"answer true to inherit selectors from superclasses"

	<category: 'Testing'>
	^false
    ]

    testAssert [
	<category: 'Testing'>
	self assert: true.
	self deny: false
    ]

    testDefects [
	<category: 'Testing'>
	| result suite error failure |
	suite := TestSuite new.
	suite addTest: (error := SUnitClientTest selector: #error).
	suite addTest: (failure := SUnitClientTest selector: #fail).
	result := suite run.
	self assert: (result defects includes: error).
	self assert: (result defects includes: failure).
	self 
	    assertForTestResult: result
	    runCount: 2
	    passed: 0
	    failed: 1
	    errors: 1
    ]

    testDialectLocalizedException [
	<category: 'Testing'>
	self should: [TestResult signalFailureWith: 'Foo']
	    raise: TestResult failure.
	self should: [TestResult signalErrorWith: 'Foo'] raise: TestResult error
    ]

    testDoubleError [
	<category: 'Testing'>
	| case result |
	case := SUnitClientTest selector: #doubleError.
	result := case run.
	self 
	    assertForTestResult: result
	    runCount: 1
	    passed: 0
	    failed: 0
	    errors: 1
    ]

    testError [
	<category: 'Testing'>
	| case result |
	case := SUnitClientTest selector: #error.
	result := case run.
	self 
	    assertForTestResult: result
	    runCount: 1
	    passed: 0
	    failed: 0
	    errors: 1.
	case := SUnitClientTest selector: #errorShouldntRaise.
	result := case run.
	self 
	    assertForTestResult: result
	    runCount: 1
	    passed: 0
	    failed: 0
	    errors: 1
    ]

    testException [
	<category: 'Testing'>
	self should: [self error: 'foo'] raise: TestResult error
    ]

    testFail [
	<category: 'Testing'>
	| case result |
	case := SUnitClientTest selector: #fail.
	result := case run.
	self 
	    assertForTestResult: result
	    runCount: 1
	    passed: 0
	    failed: 1
	    errors: 0
    ]

    testIsNotRerunOnDebug [
	<category: 'Testing'>
	| case |
	case := SUnitClientTest selector: #testRanOnlyOnce.
	case run.
	case debug
    ]

    testRan [
	<category: 'Testing'>
	| case |
	case := SUnitClientTest selector: #setRun.
	self assert: case hasSetup ~= true.
	case run.
	self assert: case hasSetup == true.
	self assert: case hasRun == true
    ]

    testResult [
	<category: 'Testing'>
	| case result |
	case := SUnitClientTest selector: #noop.
	result := case run.
	self 
	    assertForTestResult: result
	    runCount: 1
	    passed: 1
	    failed: 0
	    errors: 0
    ]

    testResumable [
	<category: 'Testing'>
	| result suite |
	(suite := TestSuite new) addTest: (SUnitClientTest selector: #errorTest).
	suite addTest: (SUnitClientTest selector: #regularTestFailureTest).
	suite addTest: (SUnitClientTest selector: #resumableTestFailureTest).
	suite addTest: (SUnitClientTest selector: #okTest).
	result := suite run.
	self
	    assert: result failures size = 2;
	    assert: result errors size = 1
    ]

    testRunning [
	<category: 'Testing'>
	(SUnitDelay forSeconds: 1) wait
    ]

    testShould [
	<category: 'Testing'>
	self should: [true].
	self shouldnt: [false]
    ]

    testSuite [
	<category: 'Testing'>
	| suite result |
	suite := TestSuite new.
	suite addTest: (SUnitClientTest selector: #noop).
	suite addTest: (SUnitClientTest selector: #fail).
	suite addTest: (SUnitClientTest selector: #error).
	result := suite run.
	self 
	    assertForTestResult: result
	    runCount: 3
	    passed: 1
	    failed: 1
	    errors: 1
    ]

    testExpectedFailures [
        <category: 'Testing'>
        | result suite expected failed error |
	suite := TestSuite new.
	suite addTest: (expected := SUnitClientTest selector: #generateExpectedFailure).
	suite addTest: (failed := SUnitClientTest selector: #generateUnexpectedSuccess).
	result := suite run.
	self assert: (result expectedDefects includes: expected).
	self assert: (result unexpectedPasses includes: failed).

	self
	    assertForTestResult: result
	    runCount: 2
	    passed: 1
	    failed: 1
	    errors: 0
    ]

    assertForTestResult: aResult runCount: aRunCount passed: aPassedCount failed: aFailureCount errors: anErrorCount [
	<category: 'Private'>
	self
	    assert: aResult runCount = aRunCount;
	    assert: aResult passedCount = aPassedCount;
	    assert: aResult failureCount = aFailureCount;
	    assert: aResult errorCount = anErrorCount
    ]

    isLogging [
	<category: 'Logging'>
	^true
    ]
]



TestResource subclass: SimpleTestResource [
    | runningState hasRun hasSetup hasRanOnce |
    
    <comment: nil>
    <category: 'SUnitTests'>

    hasRun [
	<category: 'testing'>
	^hasRun
    ]

    hasSetup [
	<category: 'testing'>
	^hasSetup
    ]

    isAvailable [
	<category: 'testing'>
	^self runningState == self startedStateSymbol
    ]

    runningState [
	<category: 'accessing'>
	^runningState
    ]

    runningState: aSymbol [
	<category: 'accessing'>
	runningState := aSymbol
    ]

    setRun [
	<category: 'running'>
	hasRun := true
    ]

    setUp [
	<category: 'running'>
	self runningState: self startedStateSymbol.
	hasSetup := true
    ]

    startedStateSymbol [
	<category: 'running'>
	^#started
    ]

    stoppedStateSymbol [
	<category: 'running'>
	^#stopped
    ]

    tearDown [
	<category: 'running'>
	self runningState: self stoppedStateSymbol
    ]
]



TestCase subclass: SUnitClientTest [
    | hasRun hasSetup |
    
    <comment: '
This is an internal class used by the self test for the SUnit. These are
very simple tests but they are pretty strange, since you want to make
sure things blow up. They are separate from SUnitTest both because
you don''t want to log these failures, and because they don''t test
SUnit concepts but rather simulate the real test suites that SUnit
will run.'>
    <category: 'SUnitTests'>

    doubleError [
	<category: 'Private'>
	[3 zork] sunitEnsure: [10 zork]
    ]

    error [
	<category: 'Private'>
	3 zork
    ]

    errorShouldntRaise [
	<category: 'Private'>
	self shouldnt: [self someMessageThatIsntUnderstood]
	    raise: SUnitNameResolver notificationObject
    ]

    errorTest [
	<category: 'Private'>
	1 zork.
	^self
    ]

    fail [
	<category: 'Private'>
	self assert: false
    ]

    isLogging [
	<category: 'Private'>
	^false
    ]

    noop [
	<category: 'Private'>
	
    ]

    okTest [
	<category: 'Private'>
	self assert: true.
	^self
    ]

    regularTestFailureTest [
	<category: 'Private'>
	self assert: false description: 'You should see me'.
	^self
    ]

    resumableTestFailureTest [
	<category: 'Private'>
	self
	    assert: false
		description: 'You should see me'
		resumable: true;
	    assert: false
		description: 'You should see me too'
		resumable: true;
	    assert: false
		description: 'You should see me last'
		resumable: false;
	    assert: false
		description: 'You should not see me'
		resumable: true.
	^self
    ]

    setRun [
	<category: 'Private'>
	hasRun := true
    ]

    testRanOnlyOnce [
	<category: 'Private'>
	self assert: hasRun ~= true.
	hasRun := true
    ]

    hasRun [
	<category: 'Accessing'>
	^hasRun
    ]

    hasSetup [
	<category: 'Accessing'>
	^hasSetup
    ]

    setUp [
	<category: 'Running'>
	hasSetup := true
    ]

    expectedFailures [
	<category: 'Private'>
        ^#(#generateExpectedFailure #generateUnexpectedSuccess)
    ]

    generateExpectedFailure [
	<category: 'Private'>
        self assert: false
    ]

    generateUnexpectedSuccess [
	<category: 'Private'>
        self assert: true
    ]
]



TestCase subclass: ExampleSetTest [
    | full empty |
    
    <comment: nil>
    <category: 'SUnitTests'>

    testAdd [
	<category: 'Testing'>
	empty add: 5.
	self assert: (empty includes: 5)
    ]

    testGrow [
	<category: 'Testing'>
	empty addAll: (1 to: 100).
	self assert: empty size = 100
    ]

    testIllegal [
	<category: 'Testing'>
	self should: [empty at: 5] raise: TestResult error.
	self should: [empty at: 5 put: #abc] raise: TestResult error
    ]

    testIncludes [
	<category: 'Testing'>
	self assert: (full includes: 5).
	self assert: (full includes: #abc)
    ]

    testOccurrences [
	<category: 'Testing'>
	self assert: (empty occurrencesOf: 0) = 0.
	self assert: (full occurrencesOf: 5) = 1.
	full add: 5.
	self assert: (full occurrencesOf: 5) = 1
    ]

    testRemove [
	<category: 'Testing'>
	full remove: 5.
	self assert: (full includes: #abc).
	self deny: (full includes: 5)
    ]

    setUp [
	<category: 'Running'>
	empty := Set new.
	full := Set with: 5 with: #abc
    ]
]



TestCase subclass: SimpleTestResourceTestCase [
    | resource |
    
    <comment: nil>
    <category: 'SUnitTests'>

    SimpleTestResourceTestCase class >> resources [
	<category: 'Not categorized'>
	^(Set new)
	    add: SimpleTestResource;
	    yourself
    ]

    dummy [
	<category: 'Not categorized'>
	self assert: true
    ]

    error [
	<category: 'Not categorized'>
	'foo' odd
    ]

    fail [
	<category: 'Not categorized'>
	self assert: false
    ]

    setRun [
	<category: 'Not categorized'>
	resource setRun
    ]

    setUp [
	<category: 'Not categorized'>
	resource := SimpleTestResource current
    ]

    testRan [
	<category: 'Not categorized'>
	| case |
	case := self class selector: #setRun.
	case run.
	self assert: resource hasSetup.
	self assert: resource hasRun
    ]

    testResourceInitRelease [
	<category: 'Not categorized'>
	| result suite error failure |
	suite := TestSuite new.
	suite addTest: (error := self class selector: #error).
	suite addTest: (failure := self class selector: #fail).
	suite addTest: (self class selector: #dummy).
	result := suite run.
	self assert: resource hasSetup
    ]

    testResourcesCollection [
	<category: 'Not categorized'>
	| collection |
	collection := self resources.
	self assert: collection size = 1
    ]
]

PK
     �Mh@j�#
  
    SUnitPreload.stUT	 eqXOԊXOux �  �  Exception subclass: TestFailure [
    
    <category: 'SUnitPreload'>
    <comment: nil>
]



Delay subclass: SUnitDelay [
    
    <category: 'SUnitPreload'>
    <comment: nil>
]



TestFailure subclass: ResumableTestFailure [
    
    <category: 'SUnitPreload'>
    <comment: nil>

    sunitExitWith: aValue [
	<category: 'Camp Smalltalk'>
	^self resume: aValue
    ]
]



Object subclass: SUnitNameResolver [
    
    <category: 'SUnitPreload'>
    <comment: nil>

    SUnitNameResolver class >> classNamed: aSymbol [
	<category: 'Camp Smalltalk'>
	^(aSymbol substrings: $.) inject: Smalltalk
	    into: [:space :key | space at: key asSymbol ifAbsent: [^nil]]
    ]

    SUnitNameResolver class >> defaultLogDevice [
	<category: 'Camp Smalltalk'>
	^Transcript
    ]

    SUnitNameResolver class >> errorObject [
	<category: 'Camp Smalltalk'>
	^Error
    ]

    SUnitNameResolver class >> mnuExceptionObject [
	<category: 'Camp Smalltalk'>
	^MessageNotUnderstood
    ]

    SUnitNameResolver class >> notificationObject [
	<category: 'Camp Smalltalk'>
	^Notification
    ]
]



Object extend [

    sunitAddDependent: anObject [
	<category: 'Camp Smalltalk'>
	self addDependent: anObject
    ]

    sunitChanged: aspect [
	<category: 'Camp Smalltalk'>
	self changed: aspect
    ]

    sunitRemoveDependent: anObject [
	<category: 'Camp Smalltalk'>
	self removeDependent: anObject
    ]

]



BlockClosure extend [

    sunitEnsure: aBlock [
	<category: 'Camp Smalltalk'>
	^self ensure: aBlock
    ]

    sunitOn: aSignal do: anExceptionBlock [
	<category: 'Camp Smalltalk'>
	^self on: aSignal do: anExceptionBlock
    ]

]



Behavior extend [

    sunitAllSelectors [
	<category: 'Camp Smalltalk'>
	^self allSelectors asSortedCollection asOrderedCollection
    ]

    sunitSelectors [
	<category: 'Camp Smalltalk'>
	^self selectors asSortedCollection asOrderedCollection
    ]

]



String extend [

    sunitAsSymbol [
	<category: 'Camp Smalltalk'>
	^self asSymbol
    ]

    sunitMatch: aString [
	<category: 'Camp Smalltalk'>
	^self match: aString
    ]

    sunitSubStrings [
	<category: 'Camp Smalltalk'>
	^self substrings
    ]

]



Exception class extend [

    sunitSignalWith: aString [
	<category: 'Camp Smalltalk'>
	^self signal: aString
    ]

]



Exception extend [

    sunitExitWith: aValue [
	<category: 'Camp Smalltalk'>
	^self return: aValue
    ]

]



String extend [

    sunitAsClass [
	<category: 'Camp Smalltalk'>
	^SUnitNameResolver classNamed: self
    ]

]



Class extend [

    sunitName [
	<category: 'Camp Smalltalk'>
	^self name
    ]

]

PK
     �Mh@����  �    SUnitScriptTests.stUT	 eqXOԊXOux �  �  "======================================================================
|
|   SUnit testing framework scripting system
|
|   This file is in the public domain.
|
 ======================================================================"



SUnitTest subclass: TestSuitesHierarchyScriptTest [
    
    <comment: nil>
    <category: 'SUnitTests'>

    testRanOnlyOnce [
	<category: 'Testing'>
	self assert: true
    ]
]



TestSuitesHierarchyScriptTest subclass: TestSuitesCompoundScriptTest [
    
    <comment: nil>
    <category: 'SUnitTests'>

    testRanOnlyOnce [
	<category: 'Testing'>
	self assert: true
    ]
]



TestCase subclass: TestSuitesScriptTest [
    
    <comment: nil>
    <category: 'SUnitTests'>

    suiteFor: aScript [
	<category: 'Testing'>
	^(TestSuitesScripter script: aScript) value
    ]

    compile: aScript [
	<category: 'Testing'>
	^(TestSuitesScripter script: aScript)
	    value;
	    yourself
    ]

    testCompoundScript [
	<category: 'Testing'>
	| allTestCaseClasses superCase subCase |
	allTestCaseClasses := (self 
		    suiteFor: 'TestSuitesHierarchyScriptTest TestSuitesCompoundScriptTest') 
			tests.
	self assert: allTestCaseClasses size = 2.
	superCase := (allTestCaseClasses at: 1) tests first.
	self assert: superCase class sunitName sunitAsSymbol 
		    = #TestSuitesHierarchyScriptTest.
	subCase := (allTestCaseClasses at: 2) tests first.
	self assert: subCase class sunitName sunitAsSymbol 
		    = #TestSuitesCompoundScriptTest
    ]

    testEmbeddedNameCommentScript [
	<category: 'Testing'>
	| suite |
	suite := self 
		    suiteFor: ' "This comment contains the name of a SUnitTest Case"  TestSuitesScriptTest'.
	self assert: suite tests size = 1
    ]

    testEmptyCommentScript [
	<category: 'Testing'>
	| suite |
	suite := self suiteFor: ' " " TestSuitesScriptTest'.
	self assert: suite tests size = 1
    ]

    testEmptyHierarchyScript [
	<category: 'Testing'>
	| suite |
	suite := self suiteFor: '*'.
	self assert: suite tests isEmpty
    ]

    testEmptyScript [
	<category: 'Testing'>
	| suite |
	suite := self suiteFor: ''.
	self assert: suite tests isEmpty
    ]

    testHierarchyScript [
	<category: 'Testing'>
	| allTestCaseClasses superCase subCase suite |
	suite := self suiteFor: 'TestSuitesHierarchyScriptTest*'.
	allTestCaseClasses := suite tests.
	self assert: allTestCaseClasses size = 1.
	superCase := (allTestCaseClasses first tests at: 1) tests first.
	self assert: superCase class sunitName sunitAsSymbol 
		    = #TestSuitesHierarchyScriptTest.
	subCase := (allTestCaseClasses first tests at: 2) tests first.
	self assert: subCase class sunitName sunitAsSymbol 
		    = #TestSuitesCompoundScriptTest
    ]

    testOpenCommentScript [
	<category: 'Testing'>
	| suite |
	suite := self suiteFor: ' "SUnitTest'.
	self assert: suite tests isEmpty
    ]

    testSimpleScript [
	<category: 'Testing'>
	| allTestCaseClasses case suite |
	suite := self suiteFor: 'TestSuitesHierarchyScriptTest'.
	allTestCaseClasses := suite tests.
	self assert: allTestCaseClasses size = 1.
	case := (allTestCaseClasses at: 1) tests at: 1.
	self 
	    assert: case class sunitName sunitAsSymbol = #TestSuitesHierarchyScriptTest
    ]

    testSingleWordCommentScript [
	<category: 'Testing'>
	| suite |
	suite := self suiteFor: ' "SUnitTest" TestSuitesScriptTest'.
	self assert: suite tests size = 1
    ]

    testTwoCommentsScript [
	<category: 'Testing'>
	| suite |
	suite := self 
		    suiteFor: ' " SUnitTest "  " SUnitTest " TestSuitesScriptTest'.
	self assert: suite tests size = 1.
	suite := self suiteFor: ' " SUnitTest "" SUnitTest " TestSuitesScriptTest'.
	self assert: suite tests size = 1
    ]

    testStringVariableScript [
	<category: 'Testing'>
	| scripter |
	scripter := self 
		    compile: 'var1=''value'' var2=''''''quoted "not SUnitTest and not a comment"
'''''' TestSuitesScriptTest'.
	self assert: (scripter variableAt: 'var1' ifAbsent: [42]) = 'value'.
	self assert: (scripter variableAt: 'var2' ifAbsent: [42]) 
		    = '''quoted "not SUnitTest and not a comment"
'''.
	self assert: (scripter variableAt: 'var3' ifAbsent: [42]) = 42.
	self assert: scripter value tests size = 1
    ]

    testVariableScript [
	<category: 'Testing'>
	| scripter |
	scripter := self compile: ' var1=value TestSuitesScriptTest'.
	self assert: (scripter variableAt: 'var1' ifAbsent: [42]) = 'value'.
	self assert: (scripter variableAt: 'var2' ifAbsent: [42]) = 42.
	self assert: scripter value tests size = 1
    ]

    testEmptyVariableScript [
	<category: 'Testing'>
	| scripter |
	scripter := self compile: ' var1= TestSuitesScriptTest'.
	self assert: (scripter variableAt: 'var1' ifAbsent: [42]) = ''.
	self assert: (scripter variableAt: 'var2' ifAbsent: [42]) = 42.
	self assert: scripter value tests size = 1
    ]
]

PK
     \h@G�/�M  M            ��    package.xmlUT ԊXOux �  �  PK
     �Mh@�f=��  �            ���  SUnitScript.stUT eqXOux �  �  PK
     �Mh@�9�+%\  %\            ���  SUnit.stUT eqXOux �  �  PK
     �Mh@� ��.  �.            ��,s  SUnitTests.stUT eqXOux �  �  PK
     �Mh@j�#
  
            ���  SUnitPreload.stUT eqXOux �  �  PK
     �Mh@����  �            ��~�  SUnitScriptTests.stUT eqXOux �  �  PK      �  ��    