PK
     �Mh@l�'  '    DebugTools.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Inferior process control
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002, 2006, 2007 Free Software Foundation, Inc.
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



Object subclass: Debugger [
    | debugProcess process breakpointContext stepSemaphore |
    
    <category: 'System-Debugging'>
    <comment: 'I provide debugging facilities for another inferior process.  I have
methods that allow the controlled process to proceed with varying
granularity.  In addition, I keep a cache mapping instruction
pointer bytecodes to line numbers.'>

    MethodLineMapCache := nil.

    Debugger class >> currentLineIn: aContext [
	<category: 'source code'>
	| lineMap method |
	method := aContext method.
	MethodLineMapCache isNil 
	    ifTrue: [MethodLineMapCache := WeakKeyIdentityDictionary new].
	lineMap := MethodLineMapCache at: method
		    ifAbsentPut: [method sourceCodeMap].
	^lineMap at: (aContext ip - 1 max: 1) ifAbsent: [1]
    ]

    Debugger class >> on: aProcess [
	"Suspend aProcess and return a new Debugger that controls aProcess.
	 aProcess must not be the currently running process."

	<category: 'instance creation'>
	aProcess == Processor activeProcess 
	    ifTrue: [self error: 'cannot attach to current process'].
	aProcess suspend.
	^self new initializeFor: aProcess
    ]

    Debugger class >> debuggerClass [
	<category: 'disabling debugging'>
	^nil
    ]

    isActive [
	"Answer true if the inferior process is still running."

	<category: 'inferior process properties'>
	^process notNil and: [process suspendedContext notNil]
    ]

    process [
	"Answer the inferior process."

	<category: 'inferior process properties'>
	^process
    ]

    currentLine [
	"Return the line number in traced process."

	<category: 'inferior process properties'>
	self isActive ifFalse: [^''].
	^self suspendedContext currentLine
    ]

    suspendedContext [
	"Answer the suspended execution state of the inferior process."

	<category: 'inferior process properties'>
	^process suspendedContext
    ]

    stopInferior [
	"Suspend the inferior process and raise a DebuggerReentered notification
	 in the controlling process."

	<category: 'stepping commands'>
	self stopInferior: nil
    ]

    stopInferior: anObject [
	"Suspend the inferior process and raise a DebuggerReentered notification
	 in the controlling process with anObject as the exception's message."

	<category: 'stepping commands'>
	| exception |
	
	[
	[process suspend.
	debugProcess
	    queueInterrupt: 
		    [self disableBreakpointContext.
		    SystemExceptions.DebuggerReentered signal: anObject];
	    resume] 
		on: Exception
		do: 
		    [:ex | 
		    exception := ex.
		    process resume]] 
		forkAt: Processor unpreemptedPriority.

	"Pass the exception on in the calling process."
	exception isNil ifFalse: [exception signal]
    ]

    stepBytecode [
	"Run a single bytecode in the inferior process."

	<category: 'stepping commands'>
	debugProcess := Processor activeProcess.
	process singleStepWaitingOn: stepSemaphore.
	process suspend.
	debugProcess := nil
    ]

    step [
	"Run to the end of the current line in the inferior process or to the
	 next message send."

	<category: 'stepping commands'>
	| context line |
	context := self suspendedContext.
	line := self currentLine.
	
	[self stepBytecode.
	self suspendedContext == context and: [line = self currentLine]] 
		whileTrue
    ]

    next [
	"Run to the end of the current line in the inferior process, skipping
	 over message sends."

	<category: 'stepping commands'>
	| context line |
	context := self suspendedContext.
	line := self currentLine.
	
	[self stepBytecode.
	(self suspendedContext notNil 
	    and: [self suspendedContext parentContext == context]) 
		ifTrue: [self finish: self suspendedContext].
	self suspendedContext == context and: [line = self currentLine]] 
		whileTrue
    ]

    finish [
	"Run to the next return."

	<category: 'stepping commands'>
	self finish: self suspendedContext
    ]

    finish: aContext [
	"Run up until aContext returns."

	<category: 'stepping commands'>
	"First, use the slow scheme for internal exception handling contexts.
	 These are more delicate and in general pretty small, so it is not
	 expensive."

	| proc cont context retVal |
	<debugging: true>
	aContext isInternalExceptionHandlingContext 
	    ifTrue: [^self slowFinish: aContext].
	[self suspendedContext isInternalExceptionHandlingContext] 
	    whileTrue: [self slowFinish: self suspendedContext].

	"Create a context that will restart the debugger and place it in the
	 chain.  We don't really use the continuation object directly but,
	 if we use the methods in Continuation, we are sure that contexts
	 are set up correctly."
	debugProcess := Processor activeProcess.
	retVal := Continuation currentDo: [:cc | cont := cc].
	Processor activeProcess == debugProcess 
	    ifTrue: 
		["Put our context below aContext and restart the debugged process."

		context := cont stack.
		context instVarAt: MethodContext instSize put: 2.
		context parentContext: aContext parentContext.
		aContext parentContext: context.
		
		[breakpointContext := aContext.
		debugProcess suspend.
		process resume] 
			forkAt: Processor unpreemptedPriority.

		"Finish the continuation context, which is at the `retVal' line
		 below."
		debugProcess := nil.
		self slowFinish: context]
	    ifFalse: 
		["We arrive here when we finish execution of aContext.  Put the
		 debugger process in control again."

		
		[breakpointContext := nil.
		process suspend.
		debugProcess resume] 
			forkAt: Processor unpreemptedPriority.
		^retVal]
    ]

    slowFinish [
	"Run in single-step mode up to the next return."

	<category: 'stepping commands'>
	self slowFinish: self suspendedContext
    ]

    slowFinish: aContext [
	"Run in single-step mode until aContext returns."

	<category: 'stepping commands'>
	| context newContext |
	context := self suspendedContext.
	
	[
	[self stepBytecode.
	self suspendedContext == context] whileTrue.
	newContext := self suspendedContext.
	newContext notNil and: 
		["no context? exit"

		"a send? go on"

		newContext parentContext == context or: 
			["aContext still in the chain? go on"

			self includes: aContext]]] 
		whileTrue
    ]

    continue [
	"Terminate the controlling process and continue execution of the
	 traced process."

	<category: 'stepping commands'>
	| theDebugProcess theProcess |
	theDebugProcess := Processor activeProcess.
	theProcess := process.
	
	[debugProcess := nil.
	process := nil.
	theDebugProcess terminate.
	theProcess resume] 
		forkAt: Processor unpreemptedPriority.

	"Just in case we get here."
	theDebugProcess primTerminate
    ]

    disableBreakpointContext [
	"Remove the context inserted set by #finish:."

	<category: 'private'>
	| theBreakpointContext |
	theBreakpointContext := breakpointContext.
	breakpointContext := nil.
	debugProcess := nil.
	theBreakpointContext isNil 
	    ifFalse: 
		[theBreakpointContext 
		    parentContext: theBreakpointContext parentContext parentContext]
    ]

    includes: aContext [
	"Answer whether aContext is still in the stack of the traced process."

	<category: 'private'>
	| context |
	context := self suspendedContext.
	
	[context isNil ifTrue: [^false].
	context == aContext ifTrue: [^true].
	context := context parentContext] 
		repeat
    ]

    initializeFor: aProcess [
	<category: 'private'>
	process := aProcess.
	stepSemaphore := Semaphore new
    ]
]



Namespace current: SystemExceptions [

Notification subclass: DebuggerReentered [
    
    <category: 'System-Debugging'>
    <comment: 'This notification is raised when the debugger is started on a process
that was already being debugged.  Trapping it allows the pre-existing
debugger to keep control of the process.'>

    description [
	"Answer a textual description of the exception."

	<category: 'description'>
	^'the debugger was started on an already debugged process'
    ]
]

]



ContextPart extend [

    currentLine [
	"Answer the 1-based number of the line that is pointed to by the receiver's
	 instruction pointer."

	<category: 'source code'>
	^Debugger currentLineIn: self
    ]

    debugger [
	"Answer the debugger that is attached to the given context.  It
	 is always nil unless the DebugTools package is loaded."

	<category: 'debugging'>
	| ctx home |
	ctx := self.
	[ctx isNil] whileFalse: 
		[home := ctx home.
		(home notNil 
		    and: [(home method attributeAt: #debugging: ifAbsent: [nil]) notNil]) 
			ifTrue: [^ctx receiver].
		ctx := ctx parentContext].
	^nil
    ]

]



BlockClosure extend [

    forkDebugger [
	"Suspend the currently running process and fork the receiver into a new
	 process, passing a Debugger object that controls the currently running
	 process."

	<category: 'instance creation'>
	| process |
	process := Processor activeProcess.
	
	[process suspend.
	Processor activeProcess priority: process priority.
	self value: (Debugger on: process)] 
		forkAt: Processor unpreemptedPriority
    ]

]

PK
     �Zh@�_��   �     package.xmlUT	 ��XO��XOux �  �  <package>
  <name>DebugTools</name>
  <test>
    <prereq>DebugTools</prereq>
    <prereq>SUnit</prereq>
    <sunit>DebuggerTest</sunit>
    <filein>debugtests.st</filein>
  </test>

  <filein>DebugTools.st</filein>
  <file>ChangeLog</file>
</package>PK    �Mh@'l��)  w  	  ChangeLogUT	 cqXO��XOux �  �  ���J�@F��Sx'lH��J)"BA��>�6�ĥ�����V����R�{�|�|�3�%i���ʦ +͖��ː��z�,j
1�zEW���P�1[���lZ�[��P�N���T#x�����x	�#T���P�(���ti��-<k���=��b	'��]7W�Z*&CPp���a�&P�<XC8"�f*�9��C���F����+6�%�$��*8�*cq^ףUr���({�aA�һ \�V��7(^;��J�Tb	�8���*����mO�U����:�O��?����'�C}PK
     �Mh@���-  -    debugtests.stUT	 cqXO��XOux �  �  "======================================================================
|
|   DebugTools package unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007, 2008 Free Software Foundation, Inc.
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



TestCase subclass: DebuggerTest [
    
    <comment: nil>
    <category: 'System-Debugging-Test'>

    debuggerOn: aBlock [
	"Attach aBlock to a debugger and step until aBlock's execution begins."

	<category: 'test'>
	| debugger |
	debugger := Debugger on: aBlock newProcess.
	[debugger suspendedContext method == aBlock block] 
	    whileFalse: [debugger stepBytecode].
	^debugger
    ]

    testOn [
	"Test that #debuggerOn: works as we intend."

	<category: 'test'>
	| debugger notReached |
	notReached := false.
	debugger := self debuggerOn: [notReached := true].
	self assert: debugger suspendedContext isBlock.
	self deny: notReached
    ]

    testStep [
	"Test that #step goes through the traced process a single line at a time."

	<category: 'test'>
	| debugger reached1 reached2 notReached |
	reached1 := reached2 := notReached := false.
	debugger := self debuggerOn: 
			[reached1 := true. reached2 := true.
			notReached := true].
	debugger step.
	self assert: reached1.
	self assert: reached2.
	self deny: notReached
    ]

    testCurrentLine [
	"Test that #currentLine does not do something completely bogus."

	<category: 'test'>
	| debugger a b c prevLine |
	debugger := self debuggerOn: 
			[a := 5.
			b := 6.
			c := 7].
	
	[debugger step.
	a = 5] whileFalse.
	prevLine := debugger currentLine.
	debugger step.
	self assert: prevLine + 1 = debugger currentLine
    ]

    testForkDebugger [
	"Test forking a debugger for the current process."

	<category: 'test'>
	| value |
	
	[:debugger | 
	
	[debugger step.
	debugger suspendedContext selector = #y] whileFalse.
	value := false.
	debugger finish.
	
	[debugger step.
	debugger suspendedContext selector = #y] whileFalse.
	value := true.
	debugger finish.
	
	[debugger step.
	debugger suspendedContext selector = #y] whileFalse.
	value := 42.
	debugger continue] 
		forkDebugger.
	self y.
	self deny: value.
	self y.
	self assert: value.
	self y.
	self assert: value = 42
    ]

    testStopInferior [
	"Test using #stopInferior to restart the debugger."

	<category: 'test'>
	| theDebugger value |
	
	[:debugger | 
	theDebugger := debugger.
	[[debugger step] repeat] on: SystemExceptions.DebuggerReentered
	    do: [:ex | ex return].
	value := 42.
	debugger continue] 
		forkDebugger.
	self assert: value isNil.
	theDebugger stopInferior.
	self assert: value = 42
    ]

    testStepIntoSend [
	"Test that #step stops at the next message send."

	<category: 'test'>
	| debugger reached notReached |
	reached := false.
	debugger := self debuggerOn: 
			[reached := true. notReached := 3 factorial].
	debugger step.
	self assert: reached.
	self assert: notReached isNil
    ]

    testFinish [
	"Test that #finish does not proceed further in the parent context."

	<category: 'test'>
	| debugger reached |
	debugger := self debuggerOn: [reached := 3 factorial].
	debugger step.
	self assert: reached isNil.
	debugger finish.
	"The assignment has not been executed yet."
	self assert: reached isNil.
	debugger finish.
	self assert: reached = 6
    ]

    testStepTooMuch [
	"Test that #stepBytecode eventually raises an error."

	<category: 'test'>
	| debugger reached toFinish |
	debugger := self debuggerOn: [3 factorial].
	self should: [[debugger stepBytecode] repeat] raise: Error.
	self deny: debugger isActive
    ]

    testFinishColon [
	"Test using #finish: to leave multiple contexts at once."

	<category: 'test'>
	| debugger reached toFinish |
	debugger := self debuggerOn: [self x: [:foo | reached := foo]].
	
	[debugger step.
	debugger suspendedContext selector = #x:] whileFalse.
	toFinish := debugger suspendedContext.
	
	[debugger step.
	debugger suspendedContext selector = #z:] whileFalse.
	debugger finish: toFinish.
	self assert: reached = 42.
	self deny: debugger suspendedContext selector = #x:
    ]

    testContinue [
	"Test that #continue terminates the controlling process."

	<category: 'test'>
	| debugger reached sema1 sema2 curtailed |
	debugger := self debuggerOn: 
			[reached := 3 factorial.
			sema1 signal].
	sema1 := Semaphore new.
	sema2 := Semaphore new.
	curtailed := true.
	
	["The controlling process is terminated, so we run the test in another
	 process."

	
	[debugger continue.
	curtailed := false] ensure: [sema2 signal]] 
		fork.
	sema1 wait.
	sema2 wait.
	self assert: reached = 6.
	self assert: curtailed.
	self deny: debugger isActive
    ]

    testStepOverPrimitive [
	"Test that #step does not go inside a primitive."

	<category: 'test'>
	| debugger reached notReached |
	debugger := self debuggerOn: [reached := Object new].
	debugger step.
	self assert: reached notNil
    ]

    testNext [
	"Test that #next runs a whole line independent of how many sends are there."

	<category: 'test'>
	| debugger reached1 reached2 |
	debugger := self debuggerOn: 
			[reached1 := 3 factorial. reached2 := 4 factorial].
	debugger next.
	self assert: reached1 = 6.
	self assert: reached2 = 24
    ]

    testCurtailFinish [
	"Test that finish is not fooled by method returns."

	<category: 'test'>
	| debugger notReached |
	notReached := false.
	debugger := self debuggerOn: 
			[self w. notReached := true].
	
	[debugger step.
	debugger suspendedContext selector = #z:] whileFalse.
	debugger finish.
	self assert: debugger suspendedContext selector = #y.
	debugger finish.
	self assert: debugger suspendedContext selector = #x:.
	debugger step.
	self assert: debugger suspendedContext isBlock.
	self assert: debugger suspendedContext selector = #w.
	debugger finish.
	self assert: debugger isActive.
	self deny: notReached
    ]

    w [
	<category: 'support'>
	self x: [:foo | ^foo]
    ]

    x: aBlock [
	<category: 'support'>
	aBlock value: self y
    ]

    y [
	<category: 'support'>
	^self z: 42
    ]

    z: anObject [
	<category: 'support'>
	^anObject
    ]
]

PK
     �Mh@l�'  '            ��    DebugTools.stUT cqXOux �  �  PK
     �Zh@�_��   �             ��e'  package.xmlUT ��XOux �  �  PK    �Mh@'l��)  w  	         ���(  ChangeLogUT cqXOux �  �  PK
     �Mh@���-  -            ��*  debugtests.stUT cqXOux �  �  PK      F  �E    