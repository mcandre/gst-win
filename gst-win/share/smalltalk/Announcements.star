PK
     �Zh@�9:��   �     package.xmlUT	 �XO�XOux �  �  <package>
  <name>Announcements</name>
  <test>
    <prereq>Announcements</prereq>
    <prereq>SUnit</prereq>
    <sunit>AnnouncementsTest</sunit>
    <filein>AnnouncementsTests.st</filein>
  </test>
  <filein>Announcements.st</filein>
</package>PK
     �Mh@�S���  ��    AnnouncementsTests.stUT	 cqXO�XOux �  �  TestCase subclass: AnnouncementTest [
    
    <comment: nil>
    <category: 'Announcements-Tests'>

    testAsAnnouncement [
	<category: 'tests'>
	| a |
	a := Announcement new.
	self assert: a = a asAnnouncement.
	self assert: Announcement asAnnouncement class = Announcement
    ]

    testDo [
	<category: 'tests'>
	| count |
	count := 0.
	Announcement do: 
		[:aClass | 
		self assert: aClass == Announcement.
		count := count + 1].
	self assert: count = 1
    ]

    testIncludes [
	<category: 'tests'>
	self assert: (Announcement includes: Announcement).
	self assert: (Announcement includes: Object) not.
	self assert: (Announcement includes: TestAnnouncement1) not
    ]
]



TestCase subclass: AnnouncerTest [
    | announcer |
    
    <comment: nil>
    <category: 'Announcements-Tests'>

    testAnnounce [
	"Subclasses of AXAnnouncement should be able to be announced, other classes shouldn't.
	 Announcement objects (instances of AXAnnouncement or any of it's subclasses') should be able to be announced, others shouldn't
	 #announce: should return the created announcement.
	 #announce: should deliver an announcement to all the subscriptions that are subscribed for the class of the announcement or it's superclasses, that are subclasses of AXAnnouncement."

	<category: 'tests'>
	| runs result |
	announcer := Announcer new.
	Announcement , TestAnnouncement1 , TestAnnouncement2 do: 
		[:each | 
		result := announcer announce: each.
		self assert: result class == each.
		result := announcer announce: each new.
		self assert: result class == each].
	
	{Object.
	nil.
	Array} do: 
		    [:each | 
		    self should: [announcer announce: each] raise: Error.
		    self should: [announcer announce: each basicNew] raise: Error].
	runs := 0.
	announcer when: Announcement
	    do: 
		[:anAnnouncement | 
		self assert: (anAnnouncement isKindOf: Announcement).
		runs := runs + 1].
	announcer when: TestAnnouncement1
	    do: 
		[:anAnnouncement | 
		self assert: anAnnouncement class == TestAnnouncement1.
		anAnnouncement x: 42.
		runs := runs + 1].
	self assert: announcer subscriptionRegistry allSubscriptions size = 2.
	result := announcer announce: TestAnnouncement1.
	self assert: result class == TestAnnouncement1.
	self assert: result x = 42.
	self assert: runs = 2.
	runs := 0.
	result := announcer announce: Announcement.
	self assert: result class == Announcement.
	self assert: runs = 1
    ]

    testInitialize [
	<category: 'tests'>
	announcer := Announcer new.
	self assert: announcer subscriptionRegistry isNil not
    ]

    testMayAnnounce [
	<category: 'tests'>
	announcer := Announcer new.
	Announcement , TestAnnouncement1 , TestAnnouncement2 
	    do: [:each | self assert: (announcer mayAnnounce: each)].
	
	{Object.
	nil.
	Array} 
		do: [:each | self assert: (announcer mayAnnounce: each) not]
    ]

    testMultipleSubscriptions [
	<category: 'tests'>
	| newSubscriptions |
	announcer := Announcer new.
	newSubscriptions := announcer when: TestAnnouncement1 , TestAnnouncement2
		    do: [].
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 2.
	self assert: announcer subscriptionRegistry allSubscriptions size = 2.
	self 
	    assert: (announcer subscriptionRegistry allSubscriptions 
		    collect: [:each | each announcementClass]) asSet 
		    = 
			{TestAnnouncement1.
			TestAnnouncement2} asSet.
	announcer := Announcer new.
	newSubscriptions := announcer 
		    when: Announcement , TestAnnouncement1 , TestAnnouncement2
		    do: []
		    for: [].
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 3.
	self assert: announcer subscriptionRegistry allSubscriptions size = 3.
	announcer := Announcer new.
	newSubscriptions := announcer 
		    when: Announcement , Announcement
		    send: #yourself
		    to: [].
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 2.
	self assert: announcer subscriptionRegistry allSubscriptions size = 2.
	announcer := Announcer new.
	newSubscriptions := announcer 
		    when: 
			{Announcement.
			Announcement}
		    send: #yourself
		    to: [].
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 2.
	self assert: announcer subscriptionRegistry allSubscriptions size = 2.
	announcer := Announcer new.
	newSubscriptions := announcer 
		    when: {Announcement}
		    send: #yourself
		    to: [].
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	self assert: announcer subscriptionRegistry allSubscriptions size = 1
    ]

    testOnDo [
	<category: 'tests'>
	| results subscriptions newSubscriptions |
	announcer := Announcer new.
	results := OrderedCollection new.
	newSubscriptions := announcer on: Announcement do: [results add: 0].
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: results size = 1.
	self assert: results first = 0.
	newSubscriptions := announcer on: Announcement
		    do: 
			[:anAnnouncement | 
			self assert: anAnnouncement class == Announcement.
			results add: 1].
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: results asSet = #(0 1) asSet.
	self assert: results size = 3.
	self assert: (results count: [:each | each = 0]) = 2.
	self assert: (results count: [:each | each = 1]) = 1.
	newSubscriptions := announcer on: Announcement
		    do: 
			[:anAnnouncement :anAnnouncer | 
			self assert: anAnnouncement class == Announcement.
			self assert: anAnnouncer == announcer.
			results add: 2].
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: results asSet = #(0 1 2) asSet.
	self assert: results size = 6.
	self assert: (results count: [:each | each = 0]) = 3.
	self assert: (results count: [:each | each = 1]) = 2.
	self assert: (results count: [:each | each = 2]) = 1.
	subscriptions := announcer subscriptionRegistry allSubscriptions.
	self assert: subscriptions size = 3.
	self assert: (subscriptions 
		    allSatisfy: [:each | each action == each subscriber]).
	self assert: (subscriptions collect: [:each | each action numArgs]) asSet 
		    = #(0 1 2) asSet
    ]

    testOnSendTo [
	<category: 'tests'>
	| result blocks newSubscriptions |
	announcer := Announcer new.
	result := OrderedCollection new.
	blocks := 
		{[result add: 0].
		[:first | result add: first].
		
		[:first :second | 
		result
		    add: first;
		    add: second].
		
		[:first :second :third | 
		result
		    add: first;
		    add: second]}.
	newSubscriptions := announcer 
		    on: Announcement
		    send: #value
		    to: blocks first.
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: result asArray = #(0).
	newSubscriptions := announcer 
		    on: Announcement
		    send: #value:
		    to: blocks second.
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: result size = 3.
	self assert: (result select: [:each | each = 0]) size = 2.
	self 
	    assert: (result select: [:each | each class == Announcement]) size = 1.
	newSubscriptions := announcer 
		    on: Announcement
		    send: #value:value:
		    to: blocks third.
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: result size = 7.
	self assert: (result select: [:each | each = 0]) size = 3.
	self 
	    assert: (result select: [:each | each class == Announcement]) size = 3.
	self assert: (result includes: announcer).
	self should: 
		[announcer 
		    on: Announcement
		    send: #value:value:value:
		    to: blocks fourth]
	    raise: Error
    ]

    testSubscription [
	<category: 'oldtests'>
	| runs |
	runs := 0.
	announcer := Announcer new.
	announcer when: TestAnnouncement1
	    do: 
		[:ann | 
		ann x: 1.
		runs := runs + 1].
	self assert: (announcer announce: TestAnnouncement1) x = 1.
	self assert: runs = 1.
	announcer when: TestAnnouncement1
	    do: 
		[:ann | 
		ann x: 2.
		runs := runs + 1].
	self assert: (#(1 2) includes: (announcer announce: TestAnnouncement1) x).
	self assert: runs = 3.
	self assert: (announcer announce: Announcement) class = Announcement.
	self assert: runs = 3
    ]

    testSubscription1 [
	<category: 'oldtests'>
	| x |
	x := 0.
	announcer := Announcer new.
	announcer when: Announcement do: [:ann | x := x + 1].
	self assert: (announcer announce: TestAnnouncement1 new) class 
		    = TestAnnouncement1.
	self assert: (announcer announce: TestAnnouncement2 new) class 
		    = TestAnnouncement2.
	self assert: x = 2
    ]

    testSubscription2 [
	<category: 'oldtests'>
	| x |
	x := 0.
	announcer := Announcer new.
	announcer when: 
		{TestAnnouncement1.
		Announcement}
	    do: [:ann | x := x + 1].
	self assert: (announcer announce: TestAnnouncement1 new) class 
		    = TestAnnouncement1.
	self assert: x = 2.
	self assert: (announcer announce: TestAnnouncement2 new) class 
		    = TestAnnouncement2.
	self assert: x = 3.
	self assert: (announcer announce: Announcement new) class = Announcement.
	self assert: x = 4
    ]

    testSubscriptionCollection [
	<category: 'oldtests'>
	| x |
	x := 0.
	announcer := Announcer new.
	announcer when: 
		{TestAnnouncement1.
		TestAnnouncement2}
	    do: 
		[:ann | 
		ann x: 1.
		x := x + 1].
	self assert: (announcer announce: TestAnnouncement1 new) x = 1.
	self assert: (announcer announce: TestAnnouncement2 new) x = 1.
	self assert: x = 2
    ]

    testSubscriptionWhenSendTo [
	<category: 'oldtests'>
	| subscriber |
	announcer := Announcer new.
	subscriber := TestSubscriber new.
	announcer 
	    when: TestAnnouncement1 , Announcement
	    send: #run
	    to: subscriber.
	announcer announce: TestAnnouncement1.
	self assert: subscriber runs = 2.
	announcer announce: TestAnnouncement2.
	self assert: subscriber runs = 3.
	announcer 
	    when: TestAnnouncement2
	    send: #storeAnnouncement:
	    to: subscriber.
	announcer announce: TestAnnouncement2.
	self assert: subscriber runs = 5.
	self 
	    assert: ((subscriber announcements collect: [:each | each class]) 
		    asSortedCollection: [:a :b | a name < b name]) 
			= (
			    {UndefinedObject.
			    UndefinedObject.
			    UndefinedObject.
			    UndefinedObject.
			    TestAnnouncement2} 
				    asSortedCollection: [:a :b | a name < b name]).
	announcer 
	    when: TestAnnouncement1
	    send: #storeAnnouncement:andAnnouncer:
	    to: subscriber.
	announcer announce: TestAnnouncement1.
	self assert: subscriber runs = 8.
	self 
	    assert: (((subscriber announcements copyFrom: 6 to: 8) 
		    collect: [:each | each class]) asSortedCollection: [:a :b | a name < b name]) 
		    = (
			{UndefinedObject.
			UndefinedObject.
			TestAnnouncement1} 
				asSortedCollection: [:a :b | a name < b name]).
	self 
	    assert: (subscriber announcers select: [:each | each isNil not]) asArray 
		    = {announcer}.
	announcer announce: TestAnnouncement2.
	self assert: subscriber runs = 10.
	self 
	    assert: (subscriber announcers copyFrom: 9 to: 10) asArray = 
			{nil.
			nil}.
	self 
	    assert: (((subscriber announcements copyFrom: 9 to: 10) 
		    collect: [:each | each class]) asSortedCollection: [:a :b | a name < b name]) 
		    = (
			{UndefinedObject.
			TestAnnouncement2} asSortedCollection: [:a :b | a name < b name])
    ]

    testSubscriptionRegistry [
	<category: 'tests'>
	announcer := Announcer new.
	self assert: announcer subscriptionRegistry class == SubscriptionRegistry
    ]

    testUnsubscribe [
	<category: 'oldtests'>
	| subscriber |
	announcer := Announcer new.
	self should: [announcer unsubscribe: Object new] raise: Error.
	self should: [announcer unsubscribe: Object new from: Announcement]
	    raise: Error.
	subscriber := Object new.
	announcer 
	    when: Announcement , TestAnnouncement1
	    do: []
	    for: subscriber.
	self 
	    assert: (announcer subscriptionRegistry subscriptionsOf: subscriber) size 
		    = 2.
	announcer unsubscribe: subscriber.
	self assert: (announcer subscriptionRegistry subscriptionsOf: subscriber) 
		    isEmpty.
	announcer 
	    when: Announcement , TestAnnouncement2
	    do: []
	    for: subscriber.
	self 
	    assert: (announcer subscriptionRegistry subscriptionsOf: subscriber) size 
		    = 2.
	announcer unsubscribe: subscriber from: Announcement.
	self 
	    assert: (announcer subscriptionRegistry subscriptionsOf: subscriber) size 
		    = 1.
	self 
	    assert: (announcer subscriptionRegistry subscriptionsOf: subscriber
		    for: Announcement) isEmpty.
	self 
	    assert: (announcer subscriptionRegistry subscriptionsOf: subscriber
		    for: TestAnnouncement2) size 
		    = 1
    ]

    testWhenDo [
	<category: 'tests'>
	| results subscriptions newSubscriptions |
	announcer := Announcer new.
	results := OrderedCollection new.
	newSubscriptions := announcer when: Announcement do: [results add: 0].
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: results size = 1.
	self assert: results first = 0.
	newSubscriptions := announcer when: Announcement
		    do: 
			[:anAnnouncement | 
			self assert: anAnnouncement class == Announcement.
			results add: 1].
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: results asSet = #(0 1) asSet.
	self assert: results size = 3.
	self assert: (results count: [:each | each = 0]) = 2.
	self assert: (results count: [:each | each = 1]) = 1.
	newSubscriptions := announcer when: Announcement
		    do: 
			[:anAnnouncement :anAnnouncer | 
			self assert: anAnnouncement class == Announcement.
			self assert: anAnnouncer == announcer.
			results add: 2].
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: results asSet = #(0 1 2) asSet.
	self assert: results size = 6.
	self assert: (results count: [:each | each = 0]) = 3.
	self assert: (results count: [:each | each = 1]) = 2.
	self assert: (results count: [:each | each = 2]) = 1.
	subscriptions := announcer subscriptionRegistry allSubscriptions.
	self assert: subscriptions size = 3.
	self assert: (subscriptions 
		    allSatisfy: [:each | each action == each subscriber]).
	self assert: (subscriptions collect: [:each | each action numArgs]) asSet 
		    = #(0 1 2) asSet
    ]

    testWhenDoFor [
	<category: 'tests'>
	| results subscriptions subscriber1 subscriber2 newSubscriptions |
	announcer := Announcer new.
	results := OrderedCollection new.
	subscriber1 := Object new.
	subscriber2 := Object new.
	newSubscriptions := announcer 
		    when: Announcement
		    do: [results add: 0]
		    for: subscriber1.
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: results size = 1.
	self assert: results first = 0.
	newSubscriptions := announcer 
		    when: Announcement
		    do: 
			[:anAnnouncement | 
			self assert: anAnnouncement class == Announcement.
			results add: 1]
		    for: subscriber2.
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: results asSet = #(0 1) asSet.
	self assert: results size = 3.
	self assert: (results count: [:each | each = 0]) = 2.
	self assert: (results count: [:each | each = 1]) = 1.
	newSubscriptions := announcer 
		    when: Announcement
		    do: 
			[:anAnnouncement :anAnnouncer | 
			self assert: anAnnouncement class == Announcement.
			self assert: anAnnouncer == announcer.
			results add: 2]
		    for: subscriber1.
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: results asSet = #(0 1 2) asSet.
	self assert: results size = 6.
	self assert: (results count: [:each | each = 0]) = 3.
	self assert: (results count: [:each | each = 1]) = 2.
	self assert: (results count: [:each | each = 2]) = 1.
	subscriptions := announcer subscriptionRegistry allSubscriptions.
	self assert: subscriptions size = 3.
	self 
	    assert: (subscriptions select: [:each | each subscriber == subscriber1]) 
		    size = 2.
	self 
	    assert: ((subscriptions select: [:each | each subscriber == subscriber1])
		    allSatisfy: [:each | #(0 2) includes: each action numArgs]).
	self 
	    assert: (subscriptions select: [:each | each subscriber == subscriber2]) 
		    size = 1.
	self 
	    assert: ((subscriptions select: [:each | each subscriber == subscriber2])
		    allSatisfy: [:each | #(1) includes: each action numArgs]).
	self assert: (subscriptions allSatisfy: [:each | #(0 1 2) includes: each action numArgs]).
    ]

    testWhenSendTo [
	<category: 'tests'>
	| result blocks newSubscriptions |
	announcer := Announcer new.
	result := OrderedCollection new.
	blocks := 
		{[result add: 0].
		[:first | result add: first].
		
		[:first :second | 
		result
		    add: first;
		    add: second].
		
		[:first :second :third | 
		result
		    add: first;
		    add: second]}.
	newSubscriptions := announcer 
		    when: Announcement
		    send: #value
		    to: blocks first.
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: result asArray = #(0).
	newSubscriptions := announcer 
		    when: Announcement
		    send: #value:
		    to: blocks second.
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: result size = 3.
	self assert: (result select: [:each | each = 0]) size = 2.
	self 
	    assert: (result select: [:each | each class == Announcement]) size = 1.
	newSubscriptions := announcer 
		    when: Announcement
		    send: #value:value:
		    to: blocks third.
	self assert: newSubscriptions class == SubscriptionCollection.
	self assert: newSubscriptions size = 1.
	announcer announce: Announcement.
	self assert: result size = 7.
	self assert: (result select: [:each | each = 0]) size = 3.
	self 
	    assert: (result select: [:each | each class == Announcement]) size = 3.
	self assert: (result includes: announcer).
	self should: 
		[announcer 
		    when: Announcement
		    send: #value:value:value:
		    to: blocks fourth]
	    raise: Error
    ]
]



TestCase subclass: SubscriptionCollectionTest [
    | announcer |
    
    <comment: nil>
    <category: 'Announcements-Tests'>

    setUp [
	<category: 'running'>
	announcer := Announcer new
    ]

    testAll [
	<category: 'tests'>
	| calls calls2 misses intercepted intercepted2 |
	calls := 0.
	calls2 := 0.
	misses := 0.
	intercepted := false.
	intercepted2 := false.
	announcer when: Announcement do: [calls := calls + 1].
	announcer when: TestAnnouncement1 do: [calls2 := calls2 + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	self assert: calls2 = 0.
	announcer announce: TestAnnouncement1.
	self assert: calls = 2.
	self assert: calls2 = 1.
	announcer subscriptionRegistry allSubscriptions suspendWhile: 
		[(announcer subscriptionRegistry subscriptionsFor: TestAnnouncement1) 
		    interceptWith: [intercepted := true]
		    while: 
			[(announcer subscriptionRegistry subscriptionsFor: Announcement) 
			    interceptWith: [intercepted2 := true]
			    while: 
				[announcer announce: Announcement.
				self assert: intercepted not.
				self assert: intercepted2.
				intercepted2 := false.
				self assert: calls = 2.
				self assert: calls2 = 1.
				announcer announce: TestAnnouncement1.
				self assert: intercepted.
				self assert: intercepted2.
				intercepted := false.
				intercepted2 := false.
				self assert: calls = 2.
				self assert: calls2 = 1.
				announcer subscriptionRegistry allSubscriptions 
				    interceptWith: [:announcement :anAnnouncer :subscription | subscription deliver: announcement from: anAnnouncer]
				    while: 
					[announcer announce: TestAnnouncement1.
					self assert: intercepted.
					self assert: intercepted2.
					self assert: calls = 3.
					self assert: calls2 = 2.
					intercepted := false.
					intercepted2 := false.
					announcer announce: Announcement.
					self assert: intercepted not.
					self assert: intercepted2.
					self assert: calls = 4.
					self assert: calls2 = 2.
					intercepted2 := false.
					announcer announce: TestAnnouncement2.
					self assert: intercepted not.
					self assert: intercepted2.
					self assert: calls = 5.
					self assert: calls2 = 2.
					intercepted2 := false].
				announcer announce: TestAnnouncement1.
				self assert: intercepted.
				self assert: intercepted2.
				intercepted := false.
				intercepted2 := false.
				self assert: calls = 5.
				self assert: calls2 = 2.
				announcer announce: TestAnnouncement2.
				self assert: intercepted not.
				self assert: intercepted2.
				intercepted2 := false.
				self assert: calls = 5.
				self assert: calls2 = 2].
			(announcer subscriptionRegistry subscriptionsFor: Announcement) 
			    suspendWhile: 
				[announcer announce: TestAnnouncement1.
				self assert: intercepted.
				self assert: intercepted2 not.
				intercepted := false.
				self assert: calls = 5.
				self assert: calls2 = 2.
				self assert: misses = 0]
			    ifAnyMissed: [misses := misses + 1].
			self assert: misses = 1].
		self assert: misses = 1]
	    ifAnyMissed: [misses := misses + 1].
	self assert: misses = 2
    ]

    testIterceptWithWhile [
	<category: 'tests'>
	| calls intercepted |
	calls := 0.
	intercepted := false.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions 
	    interceptWith: [intercepted := true]
	    while: [announcer announce: Announcement].
	self assert: calls = 1.
	self assert: intercepted = true.
	announcer announce: Announcement.
	self assert: calls = 2.
	intercepted := false.
	announcer subscriptionRegistry allSubscriptions 
	    interceptWith: [intercepted := true]
	    while: [calls := calls + 1].
	self assert: calls = 3.
	self assert: intercepted = false
    ]

    testIterceptWithWhile2 [
	<category: 'tests'>
	| calls intercepted intercepted2 |
	calls := 0.
	intercepted := false.
	intercepted2 := false.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions 
	    interceptWith: [intercepted := true]
	    while: 
		[announcer subscriptionRegistry allSubscriptions 
		    interceptWith: [intercepted2 := true]
		    while: 
			[announcer announce: Announcement.
			self assert: intercepted.
			self assert: intercepted2.
			intercepted := false.
			intercepted2 := false]].
	self assert: calls = 1.
	announcer announce: Announcement.
	self assert: calls = 2.
	self assert: intercepted not.
	self assert: intercepted2 not
    ]

    testIterceptWithWhile3 [
	<category: 'tests'>
	| calls intercepted |
	calls := 0.
	intercepted := false.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions interceptWith: 
		[:announcement | 
		self assert: announcement class = Announcement.
		intercepted := true]
	    while: 
		[announcer announce: Announcement.
		self assert: intercepted.
		intercepted := false].
	self assert: calls = 1.
	announcer announce: Announcement.
	self assert: calls = 2.
	self assert: intercepted not
    ]

    testIterceptWithWhile4 [
	<category: 'tests'>
	| calls intercepted |
	calls := 0.
	intercepted := false.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions interceptWith: 
		[:announcement :anAnnouncer | 
		self assert: announcement class = Announcement.
		self assert: anAnnouncer = announcer.
		intercepted := true]
	    while: 
		[announcer announce: Announcement.
		self assert: intercepted.
		intercepted := false].
	self assert: calls = 1.
	announcer announce: Announcement.
	self assert: calls = 2.
	self assert: intercepted not
    ]

    testIterceptWithWhile5 [
	<category: 'tests'>
	| calls intercepted |
	calls := 0.
	intercepted := false.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions interceptWith: 
		[:announcement :anAnnouncer :subscription | 
		self assert: announcement class = Announcement.
		self assert: anAnnouncer = announcer.
		self assert: announcer subscriptionRegistry allSubscriptions first 
			    = subscription.
		intercepted := true]
	    while: 
		[announcer announce: Announcement.
		self assert: intercepted.
		intercepted := false].
	self assert: calls = 1.
	announcer announce: Announcement.
	self assert: calls = 2.
	self assert: intercepted not
    ]

    testIterceptWithWhile6 [
	<category: 'tests'>
	| calls intercepted |
	calls := 0.
	intercepted := false.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	self should: 
		[announcer subscriptionRegistry allSubscriptions 
		    interceptWith: [:announcement :anAnnouncer :subscription :badParameter | intercepted := true]
		    while: 
			[announcer announce: Announcement.
			self assert: intercepted.
			intercepted := false]]
	    raise: Error.
	self assert: calls = 1.
	announcer announce: Announcement.
	self assert: calls = 2.
	self assert: intercepted not
    ]

    testIterceptWithWhileDeliverFrom [
	<category: 'tests'>
	| calls intercepted |
	calls := 0.
	intercepted := false.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions interceptWith: 
		[:announcement :anAnnouncer :subscription | 
		subscription deliver: announcement from: anAnnouncer.
		intercepted := true]
	    while: 
		[announcer announce: Announcement.
		self assert: intercepted.
		intercepted := false].
	self assert: calls = 2.
	announcer announce: Announcement.
	self assert: calls = 3.
	self assert: intercepted not
    ]

    testIterceptWithWhileDeliverFrom1 [
	<category: 'tests'>
	| calls |
	calls := 0.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions 
	    interceptWith: [:announcement :anAnnouncer :subscription | subscription deliver: announcement from: anAnnouncer]
	    while: [announcer announce: Announcement].
	self assert: calls = 2.
	announcer announce: Announcement.
	self assert: calls = 3
    ]

    testIterceptWithWhileDeliverFrom2 [
	<category: 'tests'>
	| calls |
	calls := 0.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions 
	    interceptWith: [:announcement :anAnnouncer :subscription | subscription deliver: announcement from: anAnnouncer]
	    while: 
		[announcer subscriptionRegistry allSubscriptions 
		    interceptWith: [:announcement :anAnnouncer :subscription | subscription deliver: announcement from: anAnnouncer]
		    while: [announcer announce: Announcement]].
	self assert: calls = 3.
	announcer announce: Announcement.
	self assert: calls = 4
    ]

    testSuspendWhile [
	<category: 'tests'>
	| calls |
	calls := 0.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions 
	    suspendWhile: [announcer announce: Announcement].
	self assert: calls = 1.
	announcer announce: Announcement.
	self assert: calls = 2
    ]

    testSuspendWhile2 [
	<category: 'tests'>
	| calls |
	calls := 0.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions suspendWhile: 
		[announcer subscriptionRegistry allSubscriptions 
		    suspendWhile: [announcer announce: Announcement].
		announcer announce: Announcement].
	self assert: calls = 1.
	announcer announce: Announcement.
	self assert: calls = 2
    ]

    testSuspendWhileIfAnyMissed [
	<category: 'tests'>
	| calls anyMissed |
	calls := 0.
	anyMissed := false.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions 
	    suspendWhile: [announcer announce: Announcement]
	    ifAnyMissed: [anyMissed := true].
	self assert: calls = 1.
	self assert: anyMissed = true.
	announcer announce: Announcement.
	self assert: calls = 2.
	anyMissed := false.
	announcer subscriptionRegistry allSubscriptions 
	    suspendWhile: [calls := calls + 1]
	    ifAnyMissed: [anyMissed := true].
	self assert: calls = 3.
	self assert: anyMissed = false
    ]

    testSuspendWhileIfAnyMissed2 [
	<category: 'tests'>
	| calls misses |
	calls := 0.
	misses := 0.
	announcer when: Announcement do: [calls := calls + 1].
	announcer announce: Announcement.
	self assert: calls = 1.
	announcer subscriptionRegistry allSubscriptions suspendWhile: 
		[announcer subscriptionRegistry allSubscriptions 
		    suspendWhile: [announcer announce: Announcement]
		    ifAnyMissed: [misses := misses + 1]]
	    ifAnyMissed: [misses := misses + 1].
	self assert: calls = 1.
	self assert: misses = 2.
	announcer announce: Announcement.
	self assert: calls = 2.
	announcer subscriptionRegistry allSubscriptions suspendWhile: 
		[announcer subscriptionRegistry allSubscriptions 
		    suspendWhile: [calls := calls + 1]
		    ifAnyMissed: [misses := misses + 1].
		announcer announce: Announcement]
	    ifAnyMissed: [misses := misses + 1].
	self assert: calls = 3.
	self assert: misses = 3.
	announcer subscriptionRegistry allSubscriptions suspendWhile: 
		[announcer subscriptionRegistry allSubscriptions 
		    suspendWhile: [announcer announce: Announcement]
		    ifAnyMissed: [misses := misses + 1].
		announcer announce: Announcement]
	    ifAnyMissed: [misses := misses + 1].
	self assert: misses = 5
    ]
]



TestCase subclass: SubscriptionRegistryTest [
    | registry |
    
    <comment: nil>
    <category: 'Announcements-Tests'>

    setUp [
	<category: 'running'>
	registry := SubscriptionRegistry new
    ]

    testAllSubscriptions [
	<category: 'tests'>
	| subscriptions |
	subscriptions := 
		{(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement1;
		    subscriber: Object new;
		    action: [:a :b | true].
		(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement2;
		    subscriber: Object new;
		    action: [:a :b | true].
		(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement2;
		    subscriber: Object new;
		    action: [:a :b | true]}.
	registry register: subscriptions first.
	registry register: subscriptions second.
	registry register: subscriptions third.
	self assert: registry allSubscriptions asSet = subscriptions asSet
    ]

    testRegisterBasic [
	<category: 'tests'>
	| subscription announcer announcementClass subscriber action |
	subscription := StrongSubscription new.
	announcer := Object new.
	announcementClass := Announcement.
	subscriber := Object new.
	action := [true].
	subscription := StrongSubscription 
		    newWithAction: action
		    announcer: announcer
		    announcementClass: announcementClass
		    subscriber: subscriber.
	registry register: subscription.
	self assert: (registry subscriptionsFor: announcementClass) asArray 
		    = {subscription}.
	self 
	    assert: (registry subscriptionsOf: subscriber) asArray = {subscription}
    ]

    testRegisterCollections [
	<category: 'tests'>
	| subscriptions |
	subscriptions := 
		{(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement1;
		    subscriber: Object new;
		    action: [:a :b | true].
		(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement2;
		    subscriber: Object new;
		    action: [:a :b | true]}.
	registry register: subscriptions first.
	registry register: subscriptions second.
	self assert: (registry subscriptionsFor: TestAnnouncement1) asArray 
		    = {subscriptions first}.
	self assert: (registry subscriptionsFor: TestAnnouncement2) asArray 
		    = {subscriptions second}.
	self assert: (registry subscriptionsFor: Announcement) asSet = Set new
    ]

    testRegisterCollections2 [
	<category: 'tests'>
	| subscription |
	subscription := (StrongSubscription new)
		    announcer: Object new;
		    announcementClass: Announcement;
		    subscriber: Object new;
		    action: [:a :b | true].
	registry register: subscription.
	self 
	    assert: (registry subscriptionsFor: TestAnnouncement1) asSet = #() asSet
    ]

    testRemoveSubscriptions [
	<category: 'tests'>
	| subscriptions subscriber |
	subscriber := TestSubscriber new.
	subscriptions := 
		{(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement1;
		    subscriber: subscriber;
		    action: [:a :b | true].
		(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement1;
		    subscriber: subscriber;
		    action: [:a :b | true].
		(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement2;
		    subscriber: subscriber;
		    action: [:a :b | true].
		(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement2;
		    subscriber: subscriber;
		    action: [:a :b | true]}.
	subscriptions do: [:each | registry register: each].
	self assert: (registry subscriptionsOf: subscriber) size = 4.
	self 
	    assert: (registry subscriptionsOf: subscriber for: TestAnnouncement1) size 
		    = 2.
	self 
	    assert: (registry subscriptionsOf: subscriber for: TestAnnouncement2) size 
		    = 2.
	self 
	    assert: (registry subscriptionsOf: subscriber for: Announcement) size = 0.
	self assert: ((registry subscriptionsOf: subscriber) 
		    includes: subscriptions first).
	self assert: ((registry subscriptionsOf: subscriber) 
		    includes: subscriptions second).
	self assert: ((registry subscriptionsOf: subscriber) 
		    includes: subscriptions third).
	self assert: ((registry subscriptionsOf: subscriber) 
		    includes: subscriptions fourth).
	registry removeSubscriptions: {subscriptions first}.
	self assert: (registry subscriptionsOf: subscriber) size = 3.
	self 
	    assert: (registry subscriptionsOf: subscriber for: TestAnnouncement1) size 
		    = 1.
	self 
	    assert: (registry subscriptionsOf: subscriber for: TestAnnouncement2) size 
		    = 2.
	self assert: ((registry subscriptionsOf: subscriber) 
		    includes: subscriptions second).
	self assert: ((registry subscriptionsOf: subscriber) 
		    includes: subscriptions third).
	self assert: ((registry subscriptionsOf: subscriber) 
		    includes: subscriptions fourth).
	registry removeSubscriptions: {subscriptions third}.
	self assert: (registry subscriptionsOf: subscriber) size = 2.
	self 
	    assert: (registry subscriptionsOf: subscriber for: TestAnnouncement1) size 
		    = 1.
	self 
	    assert: (registry subscriptionsOf: subscriber for: TestAnnouncement2) size 
		    = 1.
	self assert: ((registry subscriptionsOf: subscriber) 
		    includes: subscriptions second).
	self assert: ((registry subscriptionsOf: subscriber) 
		    includes: subscriptions fourth).
	registry removeSubscriptions: {subscriptions fourth}.
	self assert: (registry subscriptionsOf: subscriber) size = 1.
	self 
	    assert: (registry subscriptionsOf: subscriber for: TestAnnouncement1) size 
		    = 1.
	self assert: ((registry subscriptionsOf: subscriber) 
		    includes: subscriptions second).
	registry removeSubscriptions: {subscriptions second}.
	"Implementation specific parts!!!!!!!!"
	self 
	    assert: (registry instVarNamed: #subscriptionsByAnnouncementClasses) size 
		    = 0

	"Doesn't work :(
	 subscriber := subscriber hash.
	 Smalltalk garbageCollect.
	 self assert: (TestSubscriber allInstances noneSatisfy: [:each | each hash = subscriber])."
    ]

    testSubscriptionsOfFor [
	<category: 'tests'>
	| subscriptions subscriber |
	subscriber := Object new.
	subscriptions := 
		{(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement1;
		    subscriber: subscriber;
		    action: [:a :b | true].
		(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement2;
		    subscriber: subscriber;
		    action: [:a :b | true].
		(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: TestAnnouncement2;
		    subscriber: Object new;
		    action: [:a :b | true].
		(StrongSubscription new)
		    announcer: Object new;
		    announcementClass: Announcement;
		    subscriber: subscriber;
		    action: [:a :b | true]}.
	registry register: subscriptions first.
	registry register: subscriptions second.
	registry register: subscriptions third.
	self 
	    assert: (registry subscriptionsOf: subscriber for: TestAnnouncement1) 
		    asArray = {subscriptions first}.
	self 
	    assert: (registry subscriptionsOf: subscriber for: TestAnnouncement2) 
		    asArray = {subscriptions second}.
	self 
	    assert: (registry subscriptionsOf: subscriber for: Announcement) asArray 
		    = {}.
	self 
	    assert: (registry subscriptionsOf: subscriber
		    for: 
			{TestAnnouncement1.
			TestAnnouncement2}) asSet 
		    = 
			{subscriptions first.
			subscriptions second} asSet.
	self 
	    assert: (registry subscriptionsOf: Object new for: TestAnnouncement1) 
		    asArray = {}.
	self 
	    assert: (registry subscriptionsOf: Object new
		    for: 
			{TestAnnouncement1.
			TestAnnouncement2}) asArray 
		    = {}.
	registry register: subscriptions fourth.
	self 
	    assert: (registry subscriptionsOf: subscriber for: TestAnnouncement1) 
		    asArray = {subscriptions first}
    ]
]



TestCase subclass: SubscriptionTest [
    
    <comment: nil>
    <category: 'Announcements-Tests'>

    testActionValue [
	<category: 'tests'>
	| anAnn anAnnouncer subscription |
	subscription := StrongSubscription new.
	subscription action: [true].
	self assert: (subscription value: Announcement new) = true.
	subscription := StrongSubscription new.
	subscription action: [:ann | ann].
	anAnn := Announcement new.
	self assert: (subscription value: anAnn) = anAnn.
	subscription := StrongSubscription new.
	subscription action: 
		[:ann :announcer | 
		
		{ann.
		announcer}].
	anAnnouncer := Object new.
	subscription announcer: anAnnouncer.
	self assert: (subscription value: anAnn) = 
			{anAnn.
			anAnnouncer}.
	subscription action: 
		[:a :b :c | 
		
		{a.
		b.
		c}].
	self should: [subscription value: anAnn] raise: Error
    ]

    testAnnouncementClass [
	<category: 'tests'>
	| subscription |
	subscription := Subscription new.
	subscription announcementClass: Announcement.
	self assert: subscription announcementClass = Announcement
    ]

    testBlockForWithSelector [
	"Obsolete"

	<category: 'tests'>
	| object result announcer |
	announcer := Announcer new.
	object := 'The best test.'.
	result := announcer subscriptionRegistry subscriptionClass 
		    blockFor: object
		    withSelector: #size.
	self assert: (result respondsTo: #value).
	self assert: result numArgs = 0.
	self assert: result value = object size.
	result := announcer subscriptionRegistry subscriptionClass 
		    blockFor: object
		    withSelector: #indexOfSubCollection:.
	self assert: (result value: 'est') = (object indexOfSubCollection: 'est').
	self assert: (result respondsTo: #value:).
	self assert: result numArgs = 1.
	result := announcer subscriptionRegistry subscriptionClass 
		    blockFor: object
		    withSelector: #indexOfSubCollection:startingAt:.
	self assert: (result respondsTo: #value:value:).
	self assert: result numArgs = 2.
	self assert: (result value: 'est' value: 8) 
		    = (object indexOfSubCollection: 'est' startingAt: 8)
    ]
]






Announcement subclass: TestAnnouncement1 [
    | x |
    
    <category: 'Announcements-Tests'>
    <comment: nil>

    x [
	<category: 'accessing'>
	^x
    ]

    x: anInteger [
	<category: 'accessing'>
	x := anInteger
    ]
]



Announcement subclass: TestAnnouncement2 [
    | x |
    
    <category: 'Announcements-Tests'>
    <comment: nil>

    x [
	<category: 'accessing'>
	^x
    ]

    x: anInteger [
	<category: 'accessing'>
	x := anInteger
    ]
]



Object subclass: PerformanceTest [
    
    <category: 'Announcements-Tests'>
    <comment: 'I am a performance test for the AXAnnouncements package.
I compare the package to TriggerEvents like Vassili Bykov did on his blog. http://www.cincomsmalltalk.com/userblogs/vbykov/blogView?showComments=true&entry=3311592662

Results on a P4@3.2 (took about 10 minutes):

<N> TriggerEvent AXAnnouncements Ratio   
0   517          738             0.701   
1   855          1059            0.807   
3   3170         1428            2.22    
10  7984         2925            2.73    
30  22004        6717            3.276   
100 71300        19030           3.747 

The table becomes fancy if you copy it to a place where the characters'' width is fixed.

To perform the test yourself, print it:
AXPerformanceTest run

I also spam the Transcript with my messages. 
Beware, performing the test takes minutes.

You might play with the numbers in #testValues. They represent the number of subscriptions.'>

    PerformanceTest class >> run [
	<category: 'running'>
	| triggerEventResults axAnnouncementsResults result |
	triggerEventResults := self testTriggerEvent.
	axAnnouncementsResults := self testAXAnnouncements.
	result := WriteStream on: ''.
	result
	    nextPutAll: ('<N>' 
			padded: #right
			to: 4
			with: $ );
	    nextPutAll: ('TriggerEvent' 
			padded: #right
			to: 13
			with: $ );
	    nextPutAll: ('AXAnnouncements' 
			padded: #right
			to: 16
			with: $ );
	    nextPutAll: ('Ratio' 
			padded: #right
			to: 8
			with: $ );
	    cr.
	self testValues do: 
		[:each | 
		result
		    nextPutAll: (each asString 
				padded: #right
				to: 4
				with: $ );
		    nextPutAll: ((triggerEventResults at: each) asString 
				padded: #right
				to: 13
				with: $ );
		    nextPutAll: ((axAnnouncementsResults at: each) asString 
				padded: #right
				to: 16
				with: $ );
		    nextPutAll: (((1000 * (triggerEventResults at: each) 
				/ (axAnnouncementsResults at: each)) asFloat 
				rounded / 1000) 
				asFloat asString 
				padded: #right
				to: 8
				with: $ );
		    cr].
	Transcript show: result contents.
	^result contents
    ]

    PerformanceTest class >> testAXAnnouncements [
	| results |
	results := Dictionary new.
	self testValues do: 
		[:each | 
		| foo partialResults |
		partialResults := OrderedCollection new.
		4 timesRepeat: 
			[Smalltalk garbageCollect.
			foo := Announcer new.
			"foo subscriptionRegistry subscriptionClass: AXWeakSubscription."
			1 to: each
			    do: 
				[:i | 
				foo 
				    when: Announcement
				    send: #yourself
				    to: i].
			partialResults 
			    add: [100000 timesRepeat: [foo announce: Announcement]] timeToRun.
			Transcript
			    show: thisContext methodSelector asString , ' subscription #' 
					, each asString , ' partialResult #' 
					, partialResults size asString , ': ' 
					, partialResults last asString , ' msecs';
			    cr].
		results at: each put: (partialResults copyFrom: 2 to: 4) sum // 3.
		Transcript
		    show: thisContext methodSelector asString , ' subscription #' 
				, each asString , ' result: ' 
				, (results at: each) asString , ' msecs';
		    cr].
	^results
    ]

    PerformanceTest class >> testTriggerEvent [
	| results |
	results := Dictionary new.
	self testValues do: 
		[:each | 
		| foo partialResults |
		partialResults := OrderedCollection new.
		4 timesRepeat: 
			[Smalltalk garbageCollect.
			foo := Object new.
			1 to: each
			    do: 
				[:i | 
				foo 
				    when: #foo
				    send: #yourself
				    to: i].
			partialResults 
			    add: [100000 timesRepeat: [foo triggerEvent: #foo]] timeToRun.
			Transcript
			    show: thisContext methodSelector asString , ' subscription #' 
					, each asString , ' partialResult #' 
					, partialResults size asString , ': ' 
					, partialResults last asString , ' msecs';
			    cr].
		results at: each put: (partialResults copyFrom: 2 to: 4) sum // 3.
		Transcript
		    show: thisContext methodSelector asString , ' subscription #' 
				, each asString , ' result: ' 
				, (results at: each) asString , ' msecs';
		    cr].
	^results
    ]

    PerformanceTest class >> testValues [
	<category: 'keys and value tests'>
	^#(0 1 3 10 30 100)
    ]
]



Object subclass: TestSubscriber [
    | announcements announcers runs |
    
    <category: 'Announcements-Tests'>
    <comment: nil>

    TestSubscriber class >> new [
        <category: 'instance creation'>
        ^self basicNew initialize
    ]

    announcements [
	<category: 'accessing'>
	^announcements
    ]

    announcers [
	<category: 'accessing'>
	^announcers
    ]

    initialize [
	<category: 'initialization'>
	runs := 0.
	announcements := OrderedCollection new.
	announcers := OrderedCollection new
    ]

    run [
	<category: 'running'>
	runs := runs + 1.
	announcements add: nil.
	announcers add: nil
    ]

    runs [
	<category: 'accessing'>
	^runs
    ]

    storeAnnouncement: anAnnouncement [
	runs := runs + 1.
	announcements add: anAnnouncement.
	announcers add: nil
    ]

    storeAnnouncement: anAnnouncement andAnnouncer: anAnnouncer [
	runs := runs + 1.
	announcements add: anAnnouncement.
	announcers add: anAnnouncer
    ]
]
PK
     �Mh@A��JjE  jE    Announcements.stUT	 cqXO�XOux �  �  Object subclass: Announcement [
    
    <category: 'Announcements'>
    <comment: nil>

    Announcement class >> , anAnnouncementClass [
	<category: 'adding'>
	^AnnouncementClassCollection with: self with: anAnnouncementClass
    ]

    Announcement class >> asAnnouncement [
	<category: 'converting'>
	^self new
    ]

    Announcement class >> do: aBlock [
	"Act as a collection."

	<category: 'enumerating'>
	aBlock value: self
    ]

    Announcement class >> includes: aClass [
	"Act as a collection."

	<category: 'testing'>
	^self = aClass
    ]

    asAnnouncement [
	<category: 'converting'>
	^self
    ]
]



Object subclass: Announcer [
    | registry announcementBaseClass |
    
    <category: 'Announcements'>
    <comment: nil>

    Announcer class >> new [
        <category: 'instance creation'>
        ^self basicNew initialize
    ]

    announce: anObject [
	"Deliver anObject to the registered subscribers. anObject should respond to #asAnnouncement and return with an instance of announcementBaseClass. The return value is the announcement which can be modified by the subscribers."

	<category: 'announcements'>
	| announcement actualClass |
	announcement := anObject asAnnouncement.
	actualClass := announcement class.
	registry subscriptionsFor: actualClass announce: announcement.
	[actualClass == announcementBaseClass] whileFalse: 
		[actualClass := actualClass superclass.
		registry subscriptionsFor: actualClass announce: announcement].
	^announcement
    ]

    announcementBaseClass [
	"This is the base class of the classhierarchy which can be used as announcements in this announcer."

	<category: 'accessing'>
	^announcementBaseClass
    ]

    announcementBaseClass: aClass [
	"Set the base class of the classhierarchy which can be used as announcements in this announcer. Changing it while having registered subscriptions is very dangerous."

	<category: 'accessing'>
	(aClass ~= announcementBaseClass and: [registry isEmpty not]) 
	    ifTrue: 
		[Warning 
		    signal: 'Changing the base class of the announcement hierarchy may hang the image!'].
	announcementBaseClass := aClass
    ]

    initialize [
	<category: 'initialization'>
	registry := SubscriptionRegistry new.
	announcementBaseClass := Announcement
    ]

    mayAnnounce: anAnnouncementClass [
	"Decide if this announcer may announce an instance of anAnnanAnnouncementClass."

	<category: 'announcements'>
	^anAnnouncementClass == announcementBaseClass 
	    or: [anAnnouncementClass inheritsFrom: announcementBaseClass]
    ]

    on: anAnnouncementClassOrCollection do: aBlock [
	"For compatibiliy with Announcements package."

	<category: 'subscriptions'>
	^self when: anAnnouncementClassOrCollection do: aBlock
    ]

    on: anAnnouncementClassOrCollection send: aSelector to: anObject [
	"For compatibiliy with Announcements package."

	<category: 'subscriptions'>
	^self 
	    when: anAnnouncementClassOrCollection
	    send: aSelector
	    to: anObject
    ]

    subscriptionRegistry [
	<category: 'accessing'>
	^registry
    ]

    unsubscribe: anObject [
	<category: 'subscriptions'>
	| subscriptions |
	subscriptions := registry subscriptionsOf: anObject.
	subscriptions isEmpty 
	    ifTrue: [self error: 'No subscriptions for ' , anObject asString].
	registry removeSubscriptions: subscriptions
    ]

    unsubscribe: anObject from: anAnnouncementClassOrCollection [
	<category: 'subscriptions'>
	| subscriptions |
	subscriptions := registry subscriptionsOf: anObject
		    for: anAnnouncementClassOrCollection.
	subscriptions isEmpty 
	    ifTrue: 
		[self error: (anObject asString , ' has no subscriptions on ') 
			    , anAnnouncementClassOrCollection asString].
	registry removeSubscriptions: subscriptions
    ]

    when: anAnnouncementClassOrCollection do: aBlock [
	<category: 'subscriptions'>
	^self 
	    when: anAnnouncementClassOrCollection
	    do: aBlock
	    for: aBlock
    ]

    when: anAnnouncementClassOrCollection do: aBlock for: anObject [
	<category: 'subscriptions'>
	| subscriptions |
	subscriptions := SubscriptionCollection new.
	anAnnouncementClassOrCollection do: 
		[:each | 
		| subscription |
		(self mayAnnounce: each) 
		    ifFalse: [self error: self asString , ' may not announce ' , each asString].
		subscription := registry subscriptionClass 
			    newWithAction: aBlock
			    announcer: self
			    announcementClass: each
			    subscriber: anObject.
		subscriptions add: subscription.
		registry register: subscription].
	^subscriptions
    ]

    when: anAnnouncementClassOrCollection send: aSelector to: anObject [
	<category: 'subscriptions'>
	| subscriptions |
	subscriptions := SubscriptionCollection new.
	anAnnouncementClassOrCollection do: 
		[:each | 
		| subscription |
		(self mayAnnounce: each) 
		    ifFalse: [self error: self asString , ' may not announce ' , each asString].
		subscription := registry subscriptionClass 
			    newWithSelector: aSelector
			    announcer: self
			    announcementClass: each
			    subscriber: anObject.
		subscriptions add: subscription.
		registry register: subscription].
	^subscriptions
    ]
]



Object subclass: Subscription [
    | announcer announcementClass subscriber interceptors selector |
    
    <category: 'Announcements'>
    <comment: nil>

    action [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    action: aValuable [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    addInterceptor: aBlock [
	<category: 'interceptors'>
	aBlock numArgs > 3 
	    ifTrue: 
		[self error: 'The interceptor block should have 0, 1, 2 or 3 arguments!'].
	interceptors ifNil: [interceptors := OrderedCollection new].
	interceptors add: aBlock
    ]

    announcementClass [
	<category: 'accessing'>
	^announcementClass
    ]

    announcementClass: aClass [
	<category: 'accessing'>
	announcementClass := aClass
    ]

    announcer [
	<category: 'accessing'>
	^announcer
    ]

    announcer: anAnnouncer [
	<category: 'accessing'>
	announcer := anAnnouncer
    ]

    deliver: anAnnouncement from: anAnnouncer [
	<category: 'delivery'>
	self subclassResponsibility
    ]

    removeInterceptor [
	<category: 'interceptors'>
	interceptors removeLast.
	interceptors isEmpty ifTrue: [interceptors := nil]
    ]

    selector [
	<category: 'accessing'>
	^selector
    ]

    selector: aSelector [
	<category: 'accessing'>
	selector := aSelector
    ]

    subscriber [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    subscriber: anObject [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    value: anAnnouncement [
	<category: 'delivery'>
	self subclassResponsibility
    ]
]



Subscription subclass: StrongSubscription [
    | action |
    
    <category: 'Announcements'>
    <comment: nil>

    StrongSubscription class >> blockFor: anObject withSelector: aSelector [
	<category: 'private'>
	| args |
	args := aSelector numArgs.
	args = 0 ifTrue: [^[anObject perform: aSelector]].
	args = 1 
	    ifTrue: 
		[^[:anAnnouncement | anObject perform: aSelector with: anAnnouncement]].
	args = 2 
	    ifTrue: 
		[^
		[:anAnnouncement :anAnnouncer | 
		anObject 
		    perform: aSelector
		    with: anAnnouncement
		    with: anAnnouncer]].
	self error: 'Couldn''t create block'
    ]

    StrongSubscription class >> newWithAction: aBlock announcer: anAnnouncer announcementClass: anAnnouncementClass subscriber: anObject [
	<category: 'instance creation'>
	^(self new)
	    action: aBlock;
	    announcer: anAnnouncer;
	    announcementClass: anAnnouncementClass;
	    subscriber: anObject;
	    yourself
    ]

    StrongSubscription class >> newWithSelector: aSelector announcer: anAnnouncer announcementClass: anAnnouncementClass subscriber: anObject [
	<category: 'instance creation'>
	| block |
	block := self blockFor: anObject withSelector: aSelector.
	^(self new)
	    action: block;
	    announcer: anAnnouncer;
	    announcementClass: anAnnouncementClass;
	    subscriber: anObject;
	    selector: aSelector;
	    yourself
    ]

    action [
	<category: 'accessing'>
	^action
    ]

    action: aValuable [
	<category: 'accessing'>
	action := aValuable
    ]

    deliver: anAnnouncement from: anAnnouncer [
	<category: 'delivery'>
	^action cull: anAnnouncement cull: anAnnouncer
    ]

    subscriber [
	<category: 'accessing'>
	^subscriber
    ]

    subscriber: anObject [
	<category: 'accessing'>
	subscriber := anObject
    ]

    value: anAnnouncement [
	<category: 'delivery'>
	interceptors ifNil: [^action cull: anAnnouncement cull: announcer].
	interceptors do: 
		[:each | 
		each 
		    cull: anAnnouncement
		    cull: announcer
		    cull: self]
    ]
]



StrongSubscription subclass: WeakSubscription [
    
    <category: 'Announcements'>
    <comment: nil>

    WeakSubscription class >> blockFor: anObject withSelector: aSelector [
	<category: 'private'>
	| args |
	args := aSelector numArgs.
	args = 0 
	    ifTrue: [^[(anObject at: 1) ifNotNil: [:o | o perform: aSelector]]].
	args = 1 
	    ifTrue: 
		[^
		[:anAnnouncement | 
		(anObject at: 1) 
		    ifNotNil: [:o | o perform: aSelector with: anAnnouncement]]].
	args = 2 
	    ifTrue: 
		[^
		[:anAnnouncement :anAnnouncer | 
		(anObject at: 1) ifNotNil: 
			[:o | 
			o 
			    perform: aSelector
			    with: anAnnouncement
			    with: anAnnouncer]]].
	self error: 'Couldn''t create block'
    ]

    WeakSubscription class >> newWithAction: aBlock announcer: anAnnouncer announcementClass: anAnnouncementClass subscriber: anObject [
	<category: 'instance creation'>
	| subscription |
	subscription := aBlock == anObject 
		    ifTrue: 
			[WeakBlockSubscription 
			    newForAnnouncer: anAnnouncer
			    announcementClass: anAnnouncementClass
			    subscriber: anObject]
		    ifFalse: 
			[super 
			    newWithAction: aBlock
			    announcer: anAnnouncer
			    announcementClass: anAnnouncementClass
			    subscriber: anObject].
	anObject 
	    toFinalizeSend: #removeSubscription:
	    to: anAnnouncer subscriptionRegistry
	    with: subscription.
	^subscription
    ]

    WeakSubscription class >> newWithSelector: aSelector announcer: anAnnouncer announcementClass: anAnnouncementClass subscriber: anObject [
	<category: 'instance creation'>
	| subscription block |
	block := self blockFor: (WeakArray with: anObject) withSelector: aSelector.
	subscription := (self new)
		    action: block;
		    announcer: anAnnouncer;
		    announcementClass: anAnnouncementClass;
		    subscriber: anObject;
		    selector: aSelector;
		    yourself.
	anObject 
	    toFinalizeSend: #removeSubscription:
	    to: anAnnouncer subscriptionRegistry
	    with: subscription.
	^subscription
    ]

    subscriber [
	<category: 'accessing'>
	^subscriber at: 1
    ]

    subscriber: anObject [
	<category: 'accessing'>
	subscriber := WeakArray with: anObject
    ]
]



Subscription subclass: WeakBlockSubscription [
    
    <category: 'Announcements'>
    <comment: nil>

    WeakBlockSubscription class >> newForAnnouncer: anAnnouncer announcementClass: anAnnouncementClass subscriber: anObject [
	<category: 'instance creation'>
	^(self new)
	    announcer: anAnnouncer;
	    announcementClass: anAnnouncementClass;
	    subscriber: anObject;
	    yourself
    ]

    action [
	<category: 'accessing'>
	^subscriber at: 1
    ]

    action: aValuable [
	<category: 'accessing'>
	^self shouldNotImplement
    ]

    deliver: anAnnouncement from: anAnnouncer [
	<category: 'delivery'>
	^(subscriber at: 1) 
	    ifNotNil: [:action | action cull: anAnnouncement cull: anAnnouncer]
    ]

    subscriber [
	<category: 'accessing'>
	^subscriber at: 1
    ]

    subscriber: anObject [
	<category: 'accessing'>
	subscriber := WeakArray with: anObject
    ]

    value: anAnnouncement [
	<category: 'delivery'>
	interceptors ifNil: 
		[^(subscriber at: 1) 
		    ifNotNil: [:action | action cull: anAnnouncement cull: announcer]].
	interceptors do: 
		[:each | 
		each 
		    cull: anAnnouncement
		    cull: announcer
		    cull: self]
    ]
]



Object subclass: SubscriptionRegistry [
    | subscriptionsByAnnouncementClasses subscriptionClass |
    
    <category: 'Announcements'>
    <comment: nil>

    SubscriptionRegistry class >> new [
        <category: 'instance creation'>
        ^self basicNew initialize
    ]

    allSubscriptions [
	<category: 'accessing'>
	| result |
	result := SubscriptionCollection new.
	subscriptionsByAnnouncementClasses do: [:each | result addAll: each].
	^result
    ]

    allSubscriptionsDo: aBlock [
	<category: 'accessing'>
	subscriptionsByAnnouncementClasses do: [:each | each do: aBlock]
    ]

    initialize [
	<category: 'initialization'>
	subscriptionsByAnnouncementClasses := IdentityDictionary new.
	subscriptionClass := StrongSubscription
    ]

    isEmpty [
	<category: 'testing'>
	^subscriptionsByAnnouncementClasses isEmpty
    ]

    register: aSubscription [
	<category: 'subscribing'>
	(subscriptionsByAnnouncementClasses at: aSubscription announcementClass
	    ifAbsentPut: [SubscriptionCollection new]) add: aSubscription
    ]

    removeSubscription: aSubscription [
	"Removes a subscription from the registry."

	<category: 'subscribing'>
	| subscriptionCollection |
	subscriptionCollection := subscriptionsByAnnouncementClasses 
		    at: aSubscription announcementClass.
	subscriptionCollection remove: aSubscription ifAbsent: nil.
	subscriptionCollection isEmpty 
	    ifTrue: 
		[subscriptionsByAnnouncementClasses 
		    removeKey: aSubscription announcementClass
		    ifAbsent: nil]
    ]

    removeSubscriptions: aCollection [
	<category: 'subscribing'>
	aCollection do: [:each | self removeSubscription: each]
    ]

    subscriptionClass [
	"This is the default subscription class. All new subscriptions are created with this class."

	<category: 'accessing'>
	^subscriptionClass
    ]

    subscriptionClass: aClass [
	"Set the default subscription class. All new subscriptions are created with this class.
	 aClass should be AXStrongSubscription or AXWeakSubscription."

	<category: 'accessing'>
	subscriptionClass := aClass
    ]

    subscriptionsFor: anAnnouncementClassOrCollection [
	<category: 'accessing'>
	| result |
	result := SubscriptionCollection new.
	anAnnouncementClassOrCollection do: 
		[:each | 
		subscriptionsByAnnouncementClasses at: each
		    ifPresent: [:subscriptionCollection | result addAll: subscriptionCollection]].
	^result
    ]

    subscriptionsFor: anAnnouncementClass announce: anAnnouncement [
	<category: 'private'>
	subscriptionsByAnnouncementClasses at: anAnnouncementClass
	    ifPresent: [:subscriptionCollection | subscriptionCollection value: anAnnouncement]
    ]

    subscriptionsOf: anObject [
	<category: 'accessing'>
	| result |
	result := SubscriptionCollection new.
	self 
	    allSubscriptionsDo: [:each | each subscriber == anObject ifTrue: [result add: each]].
	^result
    ]

    subscriptionsOf: anObject for: anAnnouncementClassOrCollection [
	<category: 'accessing'>
	^(self subscriptionsFor: anAnnouncementClassOrCollection) 
	    select: [:each | each subscriber == anObject]
    ]
]



OrderedCollection subclass: AnnouncementClassCollection [
    
    <category: 'Announcements'>
    <comment: nil>
    <shape: #inherit>

    , anAnnouncementClass [
	<category: 'adding'>
	^self
	    add: anAnnouncementClass;
	    yourself
    ]
]



OrderedCollection subclass: SubscriptionCollection [
    
    <category: 'Announcements'>
    <comment: nil>
    <shape: #inherit>

    interceptWith: aBlock while: anotherBlock [
	"Evaluate aBlock instead of the action for each of these subscriptions while anotherBlock is being evaluated."

	<category: 'intercept-suspend'>
	self do: [:each | each addInterceptor: aBlock].
	anotherBlock value.
	self do: [:each | each removeInterceptor]
    ]

    make: aSubscriptionClass [
	"Create and register a new subscription of aSubscriptionClass for all the subscriptions in this collection while removing the old subscriptions from the registry."

	<category: 'private'>
	^self collect: 
		[:each | 
		| registry subscription |
		registry := each announcer subscriptionRegistry.
		registry removeSubscription: each.
		subscription := each selector ifNil: 
				[aSubscriptionClass 
				    newWithAction: each action
				    announcer: each announcer
				    announcementClass: each announcementClass
				    subscriber: each subscriber]
			    ifNotNil: 
				[aSubscriptionClass 
				    newWithSelector: each selector
				    announcer: each announcer
				    announcementClass: each announcementClass
				    subscriber: each subscriber].
		registry register: subscription.
		subscription]
    ]

    makeStrong [
	"Create and register a new strong subscription for all the subscriptions in this collection, while removing the old subscriptions from the registry."

	<category: 'weak-strong'>
	^self make: StrongSubscription
    ]

    makeWeak [
	"Create and register a new weak subscription for all the subscriptions in this collection, while removing the old subscriptions from the registry."

	<category: 'weak-strong'>
	^self make: WeakSubscription
    ]

    suspendWhile: aBlock [
	"Suspend all the subscriptions in this collection while aBlock is being evaluated."

	<category: 'intercept-suspend'>
	self interceptWith: [] while: aBlock
    ]

    suspendWhile: aBlock ifAnyMissed: anotherBlock [
	"Suspend all the subscriptions in this collection while aBlock is being evaluated. If any would have been active, evaluate anotherBlock."

	<category: 'intercept-suspend'>
	| anyMissed |
	anyMissed := false.
	self interceptWith: [anyMissed := true] while: aBlock.
	anyMissed ifTrue: [anotherBlock value]
    ]

    value: anAnnouncement [
	<category: 'private'>
	self do: [:each | each value: anAnnouncement]
    ]
]

PK
     �Zh@�9:��   �             ��    package.xmlUT �XOux �  �  PK
     �Mh@�S���  ��            ��;  AnnouncementsTests.stUT cqXOux �  �  PK
     �Mh@A��JjE  jE            ��A�  Announcements.stUT cqXOux �  �  PK        ��    