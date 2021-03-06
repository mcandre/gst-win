PK
     �Mh@�䩆�
  �
    StreamStack.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Stack of streams object.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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



Stream subclass: #StreamStack
       instanceVariableNames: 'stack'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


StreamStack comment:
'I hold a stack of open streams.  Elements are read from the most recently
pushed stream, until that reaches end of stream, at which point it is closed
and the next most recently pushed stream is read from.  When all the
streams have been exhausted, my atEnd method returns true.'!

!StreamStack class methodsFor: 'stack creation'!

new
    ^super new init
! !


!StreamStack methodsFor: 'pushstream operations'!

next
    | char |
    self atEnd
	ifTrue: [ ^nil ]
	ifFalse: [ ^self topStream next ].
!

peek
    self atEnd
	ifTrue: [ ^nil ]
	ifFalse: [ ^self topStream peek ].
!

atEnd
    self popFinishedStreams.
    ^self hasStreams not
!

close
    " ??? Not sure whether just the top should be closed or all"
    '$$$ Attempting to close stream stack' printNl.
    Smalltalk backtrace.
    [ self hasStreams ]
	whileTrue: [ self popStream ]
! !


!StreamStack methodsFor: 'stack manipulation'!

pushStream: aStream
    stack addFirst: aStream.
!

topStream
    ^stack at: 1
!

popStream
    self topStream close.
    stack removeFirst.
!

hasStreams
    ^stack size > 0
!

popFinishedStreams
    [ self hasStreams and: [ self topStream atEnd ]]
	whileTrue: [ self popStream ]
! !

!StreamStack methodsFor: 'hacks'!

peekChar
    ^self topStream peekChar
!

nextLine
    ^self topStream nextLine
! !



!StreamStack methodsFor: 'private'!

init
    stack _ OrderedCollection new.
! !
PK
     �Mh@?`J�g  g    CPStrConc.stUT	 cqXO��XOux �  �  "======================================================================
|
|   C preprocessor adjacent string concatenator layer
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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

StreamWrapper subclass: #StringConcatStream
	       instanceVariableNames: ''
	       classVariableNames: ''
	       poolDictionaries: ''
	       category: nil
!

StringConcatStream comment:
'I process a sequence of tokens, looking for adjacent strings to put together
into one long string token.'
!


!StringConcatStream methodsFor: 'accessing'!

next
    | result nextTok |
    result _ super next.
    (result isKindOf: CStringToken)
	ifTrue: 
	    [ [ stream atEnd not and: 
		    [ (nextTok _ super peek) isKindOf: CStringToken ] ]
		  whileTrue: [ super next. "gobble the string"
			       result _ CStringToken value: (result value, 
							      nextTok value) ].
	      ].
    ^result
! !
PK
     �Mh@[{h�M  �M    CPP.stUT	 cqXO��XOux �  �  "======================================================================
|
|   C Preprocessor object definition
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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


"Overall structure of the scanner:

  raw character stream, {maybe with pushback}

| LineStream
  
  stream of lines, with \ newline removed

| tokenizer, and comment remover

  lines of tokens, including whitespace tokens 

| preprocessor, conditional handling, macros expanded, etc.

  stream of tokens, with whitespace tokens removed

| string simplification: escape characters in string and char literals 
   removed

  stream of tokens

| String concatenator

  pure token stream, adjacent string literals concatenated, ready for parser

"

Stream subclass: #PreprocessorStream
       instanceVariableNames: 'streamStack lineStream stateStack state cppSymbols'
       classVariableNames: 'DirectiveHandlers Defines SystemDefines IncludePaths SystemIncludePaths'
       poolDictionaries: 'CToks'
       category: nil
! 

Object subclass: #PPState
       instanceVariableNames: 'ignoring handled'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

PPState comment:
'I am a helper class for the preprocessor.  I maintain information about
the current state of the preprocessor in terms of what level of ifdef
processing we are at.  The preprocessor can be in one of several states.
Ignoring is turned on for the contents of some part of processing a
conditional region.
If it''s in ignoring state, all non-preprocessor and 
non-preprocessor-conditional directives are simply skipped.  

When it runs into a conditional directive other than if (like else or elif),
it examine asks me whether some part of the current if expression has
been handled.  If not, either it examines the expression in the elif, or
just turns ignoring off (for else), and proceeds.

Nested #ifs are found even in ignoring mode, so that #endifs can be balanced
properly.'!


Object subclass: #PPMacroDefinition
       instanceVariableNames: 'params definition'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!PPMacroDefinition class methodsFor: 'instance creation'!

params: parameterList definition: macroDefinition
    ^self new init: parameterList definition: macroDefinition
! !

!PPMacroDefinition methodsFor: 'accessing'!

params
    ^params
!

definition
    ^definition
! !



!PPMacroDefinition methodsFor: 'private'!

init: parameterList definition: macroDefinition
    params _ parameterList.
    definition _ macroDefinition
! !




!PPState class methodsFor: 'instance creation'!

ignoring: ignoringFlag handled: handledFlag
    
    ^self new ignoring: ignoringFlag; handled: handledFlag; yourself
! !

!PPState methodsFor: 'accessing'!

ignoring: aBoolean
    ignoring _ aBoolean
!

isIgnoring
    ^ignoring
!

handled: aBoolean
    handled _ aBoolean
!

isHandled
    ^handled
! !


!PreprocessorStream class methodsFor: 'accessing'!

addSystemIncludePath: path
    SystemIncludePaths addLast: path.
    IncludePaths addLast: path.
!

addUserIncludePath: path
    IncludePaths addLast: path.
!

includePaths
    ^IncludePaths
!

resetUserIncludePaths
    IncludePaths := SystemIncludePaths copy
! !

!PreprocessorStream class methodsFor: 'test'!

testInit
    PreprocessorStream addUserIncludePath: '/usr/openwin/include'.
    PreprocessorStream addUserIncludePath: '/usr/lib/gcc-lib/i486-linux/2.4.5/include'.
!

test: aFilename
    | s str |
    self resetSymbols.
    s := self on: (FileStream open: aFilename mode: 'r').
    s inspect.
    s do: [ :line | line printNl. ].
!

test1
    PreprocessorStream test: 'lib/sym.c'.
    "PreprocessorStream test: '/usr/openwin/include/X11/Xlib.h'."
!

test2
    | s str |
    s := PreprocessorStream on: (FileStream open: 'lib/sym.c' mode: 'r').
    s inspect.
    s do: [ :line | line printNl. ].
!

test3
    | s |
    "s := FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r'."
    s := FileStream open: 'lib/sym.c' mode: 'r'.
    s := PreprocessorStream onStream: s.
    s printNl.
    s do: [ :line | line printNl. ].
!

test4
    | s |
    "s := FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r'."
    "s := FileStream open: 'xl.h' mode: 'r'."
    s := FileStream open: 'lib/sym.c' mode: 'r'.
    s := LineTokenStream onStream: s.
    s inspect.
    s printNl.
    s do: [ :line | line printNl. ].
!

test5
    | s expStream |
    "s := FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r'."
    "s := FileStream open: 'xl.h' mode: 'r'."
    s := FileStream open: 'lib/sym.c' mode: 'r'.
    s := LineTokenStream onStream: s.
    s do: [ :line |
	expStream := ExpansionStreamStack new.
	expStream pushStream: line readStream.
	s printNl.
        line printNl ].
! !

!PreprocessorStream class methodsFor: 'instance creation'!

test: aFilename
    | s str |
    self resetSymbols.
    s _ self on: (FileStream open: aFilename mode: 'r').
    s inspect.
    s do: [ :line | line printNl. ].
!

define: symbol
    Defines
	at: symbol
	put: (PPMacroDefinition params: nil definition: (CIntegerToken value: 1))
!

systemDefine: symbol
    SystemDefines
	at: symbol
	put: (PPMacroDefinition params: nil definition: (CIntegerToken value: 1)).

    Defines
	at: symbol
	put: (PPMacroDefinition params: nil definition: (CIntegerToken value: 1))
!

resetSymbols
    "Put the symbol table back to its original state"
    Defines := SystemDefines copy.
!

symbols
    ^Defines copy
!

initialize
    SystemIncludePaths := OrderedCollection new.
    self resetUserIncludePaths.
    self addSystemIncludePath: '/usr/include'.

    SystemDefines := Dictionary new.
    Defines := Dictionary new.
    Features do: [ :each |
	(each at: 1) = $_ ifTrue: [ self systemDefine: each ]
    ].

    DirectiveHandlers _ Dictionary new.
    DirectiveHandlers 
	at: 'if'  put: #handleIf;
	at: 'ifdef' put: #handleIfdef;
	at: 'ifndef' put: #handleIfndef;
	at: 'include' put: #handleInclude;
	at: 'else' put: #handleElse;
	at: 'elif' put: #handleElif;
	at: 'endif' put: #handleEndif;
	at: 'define' put: #handleDefine;
	at: 'undef' put: #handleUndef.
!

on: aCollection
    ^self onStream: aCollection readStream
!

onStream: aStream
    "This works by stacking different kinds of preprocessing streams
     one on top of another, each doing a specific task.  Additional
     layers are in LineTokenStream and StreamStack.  As in Unix, 
     this sacrifices performance for some elegance/simplicity."
    | str |
    str _ StringUnquoteStream on: aStream.
    str _ self new setStream: str.
    ^StringConcatStream on: str.
! !



!PreprocessorStream methodsFor: 'scanning'!

atEnd
    [ (lineStream isNil or: [ lineStream atEnd ]) ]
	  whileTrue: [
	       lineStream _ self nextLine.
	       lineStream isNil ifTrue: [ ^true ].
	  ].

    ^false
!

next
    self atEnd ifTrue: [ ^nil ].

    "lineStream is already macro-expanded for us.  thanks nextLine."
    ^lineStream next
!

expandDefinedFrom: expStream
    "Either 'defined/\ <anIdent>' or 'defined/\(<anIdent>)'"
    | ident tok result|
    tok _ expStream next.
    tok == OpenParenTok
	ifTrue: [ ident _ expStream next.
		  expStream next "gobble ')' " ]
	ifFalse: [ ident _ tok ].
    
   "'expanding defined' print. ident printNl.  "

    ^{ CIntegerToken value: ((cppSymbols includesKey: ident)
			    ifTrue: [ 1 ] 
			    ifFalse: [ 0 ]) }
!

nextLine
    | ch |
    [ streamStack atEnd ] whileFalse: 
	  [ ch _ streamStack peek.
	    (self isSharp: ch)
		ifTrue: 
		    [ "It's for us!!!"
		      streamStack next. "gobble '#'"
		      self dispatchDirective.
		      ]
		ifFalse: [
			  state isIgnoring
				ifTrue: [ streamStack nextLine ]
				ifFalse: [ ^self macroExpandRemainder ]
		 ]
	].
    ^nil
!




macroExpandRemainder
    | result lineTokens expStream expansion token |
    lineTokens _ streamStack nextLine.
    result _ WriteStream on: (Array new: lineTokens size).
    expStream _ ExpansionStreamStack new.
    expStream pushStream: lineTokens readStream.
    [ expStream atEnd ] whileFalse:
	[ token _ expStream next.
	   "'reading from exp: ' print. token printNl."
   
	  ((token isMemberOf: CIdentifierToken) and: 
	       [ (cppSymbols includesKey: token) and: 
		     [ (expStream isAlreadyExpanded: token ) not ] ])
	      ifTrue: [ expansion _ self expandMacro: token from: expStream.
			expStream pushStream: expansion readStream
				  forMacro: token ]
	      ifFalse: [ result nextPut: token ]
	 ].
    lineStream _ nil.		"force a reload"
    "'expanded into: ' print. result printNl."
    ^result readStream
!
	      


expandMacro: macroName from: expStream
    | defn body params result str paramName |
    macroName value = 'defined'
	ifTrue: [ ^self expandDefinedFrom: expStream ].
    defn _ cppSymbols at: macroName.
    defn params isNil ifTrue: "No parameters -- easy substitution!"
	[ ^defn definition ].
    
    "Assume we're looking at: 'foo/\ (...'"
    params _ self parseMacroActuals: defn params fromStream: expStream.
     
    "  '%%%%% macro actuals: ' print. params printNl."

    body _ defn definition.
    
    result _ OrderedCollection new: body size.
    str _ ReadStream on: body.
    str do: 
	[ :token | self processMacroToken: token
			into: result 
			fromStream: str
			withParams: params
		   ].
    ^result
!

processMacroToken: token into: result fromStream: expStream withParams: params
    | paramName lastToken nextToken nextParams |
    
    (token class == CBinaryOperatorToken 
	and: [ token value = '##' ]) 
	ifTrue: 
	    [ lastToken _ result removeLast.
	      nextToken _ expStream next.
	      "'[[[[[[[[[ next is ' print. nextToken printNl."
	      (nextToken class == CIdentifierToken
		   and: [ params includesKey: nextToken ])
		  ifTrue: [ nextParams _ params at: nextToken.
			    "!!! Here we assume we always have identifiertokens"
			    lastToken class == CIdentifierToken
				ifFalse: [^self error: '## called with non identifier' ].
			    lastToken _ CIdentifierToken value: 
				lastToken value , nextParams removeFirst valueString.
			    nextParams addFirst: lastToken.
			    ^result addAllLast: nextParams ]
		  ifFalse: [ lastToken _ CIdentifierToken value: 
				 lastToken value, nextToken valueString.
			     ^result addLast: lastToken ]
	      ].
    (self isSharp: token)
	ifTrue: [ paramName _ expStream next.
		  ^result addLast: 
		      (self stringifyActual: 
			   (params at: paramName)) ].
    (token class == CIdentifierToken
	 and: [ params includesKey: token ])
	ifTrue: [ ^result addAllLast: 
		      (params at: token) ].
    result addLast: token
!
		      


stringifyActual: macroActualParam
    | result tokenString |
    result _ WriteStream on: (String new: 1).
    macroActualParam do:
	[ :token | 
		   "Whitespace are already present and their value is a 
		    single space, so it works out ok."
		   tokenString _ self toString: token.
		   result nextPutAll: tokenString.
		       ].
    ^CStringToken value: result contents
!

toString: token
    (token isKindOf: CStringoidToken)
	  ifTrue: [ ^token quotedStringValue ].
    ^token valueString
!

parseMacroActuals: names fromStream: expStream
    "this has to work with whatever stream is sitting below it, essentially
     the stream stack.  This means that the line stream has to be wrapped into
     something that behaves like a normal stream"
    | paramDict actual |
    " expecting scanner to be at foo/\ (arg1, arg2, ...), leaves after eating
     the close paren"
    paramDict _ Dictionary new.
    expStream next.		"gobble ("

    names do: 
	[ :name | actual _ self parseMacroActual: expStream.
		  paramDict at: name put: actual.
		  expStream next. "gobble the trailing delimiter" 
		  ].
    "!!! should put back the remainder of the queue (if any)"
    ^paramDict
!

"!!! still have to build lineStream -> simple token translator
 !!! build stream stack extension with macro prohibition
     (can use this as what our next operation does too...just push the
     right stream in the way, and the right thing will happen).
"

parseMacroActual: expStream
    "parses a paren balanced series of tokens, up to (and either a close paren
	 or a comma, returning the list, minus white spaces at either end"
    | result token parenLevel |
    result _ OrderedCollection new.
    parenLevel _ 0.
    
    [ token _ expStream peek.
      parenLevel == 0
	  and: [ (token == CloseParenTok)
		     or: [ token class == CBinaryOperatorToken and: 
			       [ token value = ',' ] ] ] ]
	whileFalse: [ result addLast: token.
		      expStream next. "gobble it"
		      token == OpenParenTok
			  ifTrue: [ parenLevel _ parenLevel + 1 ].
		      token == CloseParenTok
			  ifTrue: [ parenLevel _ parenLevel - 1 ]. 
		      ].

    ^result
!

"
input stream: ls (line stream)


parse actuals (may involve fetching several input lines), produces a
dictionary mapping actual names to token sequences.  this actual
parsing may also be useful elsewhere

expand macro body
put expansion into input stream, prohibiting recursive expansion






tokens out the top, ws removed

"



isSharp: token
    ^token class == COperatorToken and: [ token value = '#' ]
!

dispatchDirective
    | directive |
    directive := streamStack next.

    self perform: (DirectiveHandlers
	at: directive value
	ifAbsent: [ #skipDirective ]).
! !


!PreprocessorStream methodsFor: 'handling directives'!

handleUndef
    | symbol |
    state isIgnoring
	ifTrue: [ ^true ].

    symbol _ streamStack next.
    "'undefining' print. symbol value printNl."
    cppSymbols removeKey: symbol ifAbsent: [].
!
    
handleDefine
    | symbol tok definition params macroDef |
    state isIgnoring
	ifTrue: [ ^true ].

    symbol _ streamStack next.

    "'defining' print. symbol value printNl."
    streamStack peekChar = $(
	ifTrue: [
	    "'doing parameters' printNl." params _ self parseMacroParams ].

    macroDef _ PPMacroDefinition params: params
				 definition: streamStack nextLine.
    cppSymbols at: symbol put: macroDef.
!

parseMacroParams
    "scanner at #define foo/\(...) "
    | params ident tok |
    streamStack next.		"gobble paren"
    params _ OrderedCollection new.
    tok _ streamStack peek.
    tok class ~~ CloseParenTok 
	ifTrue: 
	    [ [ ident _ streamStack next.
		params addLast: ident.
		tok _ streamStack next.
		tok value = ',' ] whileTrue: [ ] ]
	ifFalse: [ streamStack next ].
    "must have gobbled the close paren already (we're not a full C
     language, and we presume syntactically correct C programs), so we
     are done."
    ^params
!


handleIfdef
    | symbol isDefined |
    stateStack addFirst: state.
    state isIgnoring
	ifTrue: [ state _ PPState ignoring: true handled: true.
		  "we continue ignoring and do no further processing"
		  ^self ].
		  
    symbol _ streamStack next.
    
    isDefined _ (cppSymbols includesKey: symbol).
    "'ifdef' print. symbol value printNl.  isDefined printNl."
    state _ PPState ignoring: isDefined not handled: isDefined
! 

handleIfndef
    | symbol isDefined |
    stateStack addFirst: state.
    state isIgnoring
	ifTrue: [ state _ PPState ignoring: true handled: true.
		  "we continue ignoring and do no further processing"
		  ^self ].
		  
    symbol _ streamStack next.
    
    isDefined _ (cppSymbols includesKey: symbol).
    "'ifndef' print. symbol value printNl.  isDefined printNl."
    state _ PPState ignoring: isDefined handled: isDefined not
!

handleInclude
    | token fileName searchLocal fileStream |
    state isIgnoring
	ifTrue: [ ^true ].

    token _ streamStack next.
    token class == CStringToken
	ifTrue: [ fileName _ token value.
		  searchLocal _ true ]
	ifFalse:
	    [ "should be < dir/dir/dir.../filename > "
	      searchLocal _ false.
	      fileName _ ''.
	      [ token _ streamStack next.
		token value ~= '>' ] whileTrue:
		    [ fileName _ fileName, token value ].
	      ].
  Transcript nextPutAll: 'including: '; nextPutAll: fileName; nl.
    fileStream _ self findIncludeFile: fileName locally: searchLocal.
    fileStream notNil
	ifTrue: [ self pushStream: fileStream ]
	ifFalse: [ ^self error: 'Could not locate include file "', fileName, 
		       '"' ].
!

pushStream: aStream
    streamStack pushStream: (LineTokenStream onStream: aStream).
!

findIncludeFile: fileName locally: locally
    | paths file |
    " !!! should this be smarter and search the current directory by default,
     that is, the directory of the includer, or not?.  GNU CPP uses for quote
     delimited include file names the directory of the current input file (as 
     opposed to the current working directory, so we'll probably have to do
     this as well at some point.  The angle bracket variant just pays 
     attention to the -I files and the standard directories."
    "'@@@@@@@@@@@@ file name ' print. fileName printNl."
    paths _ self includePaths.
    locally ifTrue: [ paths addFirst: '.' ].
    paths do: 
	[ :path | file _ path / fileName.
		  file exists ifTrue: [ ^file readStream ] ].
    ^nil
!

includePaths
    ^PreprocessorStream includePaths
!

addIncludePath: aPath
    ^PreprocessorStream addUserIncludePath: aPath
!

handleIf
    | expr exprBool |
    stateStack addFirst: state.
    state isIgnoring
	ifTrue: [ state _ PPState ignoring: true handled: true.
		  "we continue ignoring and do no further processing"
		  ^self ].
		  
    expr _ self parseExpression.
    
    exprBool _ (expr evaluate) ~= 0.
    "'if' print. exprBool printNl."
    state _ PPState ignoring: exprBool not
		    handled: exprBool
! 

parseExpression
    " parse a line of stuff from streamStack and return it as an expression
     tree"
    | exprParser expr cleanedLine |
    
    cleanedLine _ self macroExpandRemainder.

    "'parsing. ' print. cleanedLine copy upToEnd printNl."

    exprParser _ CExpressionParser onStream: cleanedLine.
    expr _ exprParser parseExpression.
    ^expr
!

handleElse
    state isHandled
	ifTrue: [ state ignoring: true ]
	ifFalse: [ state ignoring: false.
		   state handled: true ].
    "'else ' print. state isIgnoring printNl."
!

handleElif
    | expr | 
    state isHandled
	ifTrue: [ state ignoring: true ]
	ifFalse:
	    [ expr _ self parseExpression.
	      (expr evaluate) ~= 0
		  ifTrue: [ state handled: true; ignoring: false ]
		  ifFalse: [ state ignoring: true ] ].
    "'elif ' print. state isIgnoring printNl."
!

handleEndif
    "'endif ' printNl."
    state _ stateStack removeFirst.
! 

skipDirective
    "does doing nothing work for pragmas etc.?"
    streamStack nextLine
! !


!PreprocessorStream methodsFor: 'private'!

setStream: aStream
    streamStack := StreamStack new.
    self pushStream: aStream.
    state _ PPState ignoring: false handled: false.
    stateStack _ OrderedCollection new.
    cppSymbols _ PreprocessorStream symbols.
    cppSymbols at: (CIdentifierToken value: 'defined') put: 1. "value does not matter"
! !


PreprocessorStream initialize!
PK
     �Mh@K�B�  �    CPStrUnq.stUT	 cqXO��XOux �  �  "======================================================================
|
|   C preprocessor string literal unquoter layer 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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

StreamWrapper subclass: #StringUnquoteStream
	       instanceVariableNames: ''
	       classVariableNames: ''
	       poolDictionaries: ''
	       category: nil
!

StringUnquoteStream comment:
'I process a sequence of tokens, looking for strings or character literals.
When I find them, I scan them for any occurance of quoted characters, and
remove the quoting character, converting any special characters (such as
"\n") into their internal representation.  I yield a stream of tokens where
strings and chars are "fixed"'!


!StringUnquoteStream methodsFor: 'accessing'!

next
    | result nextTok |
    result _ super next.
    ((result isKindOf: CStringToken) or: 
	 [ result isKindOf: CCharacterToken ])
	ifTrue: [ ^self processQuotedChars: result ]
	ifFalse: [ ^result ]     
! !


!StringUnquoteStream methodsFor: 'private'!

processQuotedChars: aLiteral
    "Note that characters are also represented as strings"
    | string changed rStream wStream ch |
    string _ aLiteral value.
    changed _ false.
    rStream _ ReadStream on: string.
    wStream _ WriteStream on: (String new: string size).
    [ rStream atEnd ]
	whileFalse: [ ch _ rStream next.
		      ch == $\
			  ifTrue: [ changed _ true.
				    ch _ self parseEscapedChar: rStream. ].
		      wStream nextPut: ch. ].
    changed 
	ifTrue: [ ^(aLiteral class) value: wStream contents ]
	ifFalse: [ ^aLiteral ]
!

parseEscapedChar: aStream
    "called right after \ in a string or a character literal"
    | ch num count | 
    ch _ aStream next.
    ch == $b ifTrue: [ ^Character value: 8 ].
    ch == $n ifTrue: [ ^Character value: 10 ].
    ch == $r ifTrue: [ ^Character value: 13 ].
    ch == $f ifTrue: [ ^Character value: 12 ].
    ch == $t ifTrue: [ ^Character value: 9 ].
    ch == $v ifTrue: [ ^Character value: 11 ].
    " this should probably go away "
    ch == (Character nl) ifTrue: 
	[ ch _ aStream next.
	  ch == $\
	      ifTrue: [ ^self parseEscapedChar: aStream ]
	      ifFalse: [ ^ch ]
	      ].
    ch == $\ ifTrue: [ ^$\ ].
    ch == $' ifTrue: [ ^$' ].
    ch == $" ifTrue: [ ^$" ].
    ch == $x ifTrue: [ "have \xhhh"
		       ch _ aStream next.
		       num _ 0.	
		       count _ 0.
		       [ (self isDigit: ch base: 16) and:
			     [ count < 3 ] 
			   ] whileTrue:
			   [ num _ num * 16 + ch digitValue.
			     aStream next. 
			     ch _ aStream peek.
			     count _ count + 1
			     ].
		       ^Character value: num ].
    (self isDigit: ch base: 8)
	ifTrue: [ "have \ooo"
		  num _ 0.	
		  count _ 0.
		  [ (self isDigit: ch base: 8) and:
			[ count < 3 ] 
			] whileTrue:
			    [ num _ num * 8 + ch digitValue.
			      aStream next. 
			      ch _ aStream peek.
			      count _ count + 1 ].
		  ^Character value: num ].
    self error: 'Illegal quoted character'
! !
PK
     �Mh@�f"#  "#  	  CToken.stUT	 cqXO��XOux �  �  "======================================================================
|
|   C lexical token classes.
|   Usable separately as well.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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

Object subclass: #CToken
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries:''
       category: 'Compiler'
!



CToken comment:
'My instances are returned from the lexer stream.  If you ask them (nicely,
mind you) they will report their kind (a symbol, such as #Identifier) and
their value (such as ''foobar'').' !


!CToken methodsFor: 'printing'!

printOn: aStream
    "not done yet"
    super printOn: aStream
!

storeOn: aStream
    aStream 
	nextPutAll: self class name;
	nextPutAll: ' new '.
! !



CToken subclass: #CValueToken
      instanceVariableNames: 'value'
      classVariableNames: ''
      poolDictionaries: ''
      category: 'Compiler'
!

!CValueToken class methodsFor: 'instance creation'!

value: aValue
    ^self new init: aValue
! !

!CValueToken methodsFor: 'accessing'!

value
    ^value
!

= differentToken
    ^value = differentToken value
!

hash
    ^value hash
!

valueString
    ^value			"most are strings"
!

evaluate
    ^value
! !


!CValueToken methodsFor: 'printing'!

storeOn: aStream
    aStream nextPut: $(;
	nextPutAll: self class name; nextPutAll: ' value: '; store: value;
	nextPut: $).
! !


!CValueToken methodsFor: 'private'!

init: aValue
    value _ aValue
!

printOn: aStream
    super printOn: aStream.
    aStream nextPutAll: '::'.
    value printOn: aStream
! !


    
CValueToken subclass: #COperatorToken
	    instanceVariableNames: ''
	    classVariableNames: ''
	    poolDictionaries: ''
	    category: nil
!

!COperatorToken methodsFor: 'accessing'!

isBinary
    ^true
!

isUnary
    ^true
! !

COperatorToken subclass: #CBinaryOperatorToken
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CBinaryOperatorToken methodsFor: 'accessing'!

isUnary
    ^false
! !

"unary only"
COperatorToken subclass: #CUnaryOperatorToken
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CUnaryOperatorToken methodsFor: 'accessing'!

isBinary
    ^false
! !

CValueToken subclass: #CIdentifierToken
	   instanceVariableNames: ''
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Compiler'
!
CValueToken subclass: #CStringoidToken
	   instanceVariableNames: ''
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Compiler'
!
CValueToken subclass: #CFloatToken
	   instanceVariableNames: ''
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Compiler'
!
CValueToken subclass: #CIntegerToken
	   instanceVariableNames: ''
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Compiler'
!


!CStringoidToken methodsFor: 'interpretation'!

quotedStringValue
    "Returns the value as a string, with an extra level of C style quotes
     (backslash) present"
    | result valueStream delim |
    result _ WriteStream on: (String new: 4).
    valueStream _ ReadStream on: (self value).
    delim _ self delimiterChar.
    result nextPut: $\.
    result nextPut: delim.
    valueStream do: 
	[ :ch | (ch == self delimiterChar ) | (ch == $\)
		    ifTrue: [ result nextPut: $\ ].
		result nextPut: ch ].
    result nextPut: $\.
    result nextPut: delim.
    
    ^result contents
!

delimiterChar
    ^self subclassResponsibility
! !



CStringoidToken subclass: #CStringToken
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CStringToken methodsFor: 'interpretation'!

delimiterChar
    ^$"
! !


CStringoidToken subclass: #CCharacterToken
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CCharacterToken methodsFor: 'interpretation'!

quotedStringValue
    "Returns the value as a string, with an extra level of C style quotes
     (backslash) present"
    | result valueStream delim |
    result _ WriteStream on: (String new: 4).
    valueStream _ ReadStream on: (self value).
    delim _ self delimiterChar.
    result nextPut: $'.
    valueStream do: 
	[ :ch | ch == $\ ifTrue: [ result nextPut: ch ].
		result nextPut: ch ].
    result nextPut: $'.
    
    ^result contents
!

delimiterChar
    ^$'
! !



!CIntegerToken methodsFor: 'accessing'!

valueString
    ^value printString
! !

!CFloatToken methodsFor: 'accessing'!

valueString
    ^value printString
! !


Object subclass: #CKeyword
       instanceVariableNames: 'value'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CKeyword comment:
'I exist only to provide unique instances which correspond to C keywords.
.' !

!CKeyword class methodsFor: 'instance creation'!

value: aName
    ^self new init: aName
! !

!CKeyword methodsFor: 'accessing'!

value
    ^value
! !

!CKeyword methodsFor: 'private'!

init: aName
    value _ aName.
!

printOn: aStream
    aStream nextPutAll: 'Keyword:'.
    value printOn: aStream
! !



Namespace current at: #CKeywords put: Dictionary new!

CKeywords at: #AutoKey put: (CKeyword value: 'auto').
CKeywords at: #BreakKey put: (CKeyword value: 'break').
CKeywords at: #CaseKey put: (CKeyword value: 'case').
CKeywords at: #CharKey put: (CKeyword value: 'char').
CKeywords at: #ConstKey put: (CKeyword value: 'const').
CKeywords at: #ContinueKey put: (CKeyword value: 'continue').
CKeywords at: #DefaultKey put: (CKeyword value: 'default').
CKeywords at: #DoKey put: (CKeyword value: 'do').
CKeywords at: #DoubleKey put: (CKeyword value: 'double').
CKeywords at: #ElseKey put: (CKeyword value: 'else').
CKeywords at: #EnumKey put: (CKeyword value: 'enum').
CKeywords at: #ExternKey put: (CKeyword value: 'extern')!

CKeywords at: #FloatKey put: (CKeyword value: 'float').
CKeywords at: #ForKey put: (CKeyword value: 'for').
CKeywords at: #GotoKey put: (CKeyword value: 'goto').
CKeywords at: #IfKey put: (CKeyword value: 'if').
CKeywords at: #IntKey put: (CKeyword value: 'int').
CKeywords at: #LongKey put: (CKeyword value: 'long').
CKeywords at: #RegisterKey put: (CKeyword value: 'register').
CKeywords at: #ReturnKey put: (CKeyword value: 'return').
CKeywords at: #ShortKey put: (CKeyword value: 'short').
CKeywords at: #SignedKey put: (CKeyword value: 'signed').
CKeywords at: #SizeofKey put: (CKeyword value: 'sizeof').
CKeywords at: #StaticKey put: (CKeyword value: 'static').
CKeywords at: #StructKey put: (CKeyword value: 'struct').
CKeywords at: #SwitchKey put: (CKeyword value: 'switch').
CKeywords at: #TypedefKey put: (CKeyword value: 'typedef').
CKeywords at: #UnionKey put: (CKeyword value: 'union').
CKeywords at: #UnsignedKey put: (CKeyword value: 'unsigned').
CKeywords at: #VoidKey put: (CKeyword value: 'void').
CKeywords at: #VolatileKey put: (CKeyword value: 'volatile').
CKeywords at: #WhileKey put: (CKeyword value: 'while')!

Namespace current at: #CPPKeywords put: Dictionary new!

CPPKeywords at: #IfdefKey put: (CKeyword value: 'ifdef').
CPPKeywords at: #DefinedKey put: (CKeyword value: 'defined').
CPPKeywords at: #ElifKey put: (CKeyword value: 'elif').
CPPKeywords at: #EndifKey put: (CKeyword value: 'endif').
CPPKeywords at: #IfndefKey put: (CKeyword value: 'ifndef').

Namespace current at: #CToks put: Dictionary new!

CToks at: #DotTok put: (CValueToken value: '.').
CToks at: #ColonTok put: (CValueToken value: ':').
CToks at: #OpenParenTok put: (CValueToken value: '(').
CToks at: #CloseParenTok put: (CValueToken value: ')').
CToks at: #SemiTok put: (CValueToken value: ';').
CToks at: #QuestionTok put: (CValueToken value: '?').
CToks at: #OpenBracketTok put: (CValueToken value: '[').
CToks at: #CloseBracketTok put: (CValueToken value: ']').
CToks at: #OpenBraceTok put: (CValueToken value: '{').
CToks at: #CloseBraceTok put: (CValueToken value: '}').
CToks at: #DotDotDotTok put: (CValueToken value: '...')!

PK
     �Zh@i5(vw  w    package.xmlUT	 ��XO��XOux �  �  <package>
  <name>CParser</name>
  <namespace>CParser</namespace>

  <filein>StreamWrapper.st</filein>
  <filein>PushBackStream.st</filein>
  <filein>CToken.st</filein>
  <filein>LineTokenStream.st</filein>
  <filein>CPStrUnq.st</filein>
  <filein>CPStrConc.st</filein>
  <filein>StreamStack.st</filein>
  <filein>ExpansionStreamStack.st</filein>
  <filein>CExpressionNode.st</filein>
  <filein>CParseExpr.st</filein>
  <filein>CPP.st</filein>
  <filein>CSymbol.st</filein>
  <filein>CDeclNode.st</filein>
  <filein>CSymbolTable.st</filein>
  <filein>CParseType.st</filein>
  <file>README</file>
  <file>ChangeLog</file>
</package>PK    �Mh@=m��   J    READMEUT	 cqXO��XOux �  �  -�Aj�0D�>���B1�EO��_�Pb%6q� +?����K!潙�\:RQ�M�Fُ�;7� |�P>Tf�]4�iH�M�^V�Z����NC1�,gMإ[�q�n1�~�R�R�H������Ņig�"��̔�11�ۋN*7�p�*�[G�'{uQ�f���8�Ҿ��w\�}�L4y1�n�%1���||�#>��G�n9=�<mUd������3.����PK
     �Mh@	���x  �x    CParseType.stUT	 cqXO��XOux �  �  "======================================================================
|
|   C type declaration parser, part of the C header parser.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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



"Here's the probelm:

at what level is the symbol table management done?  we could do it here,
just parsing whatever we come to, and recording the declarations into the
symbol table.  

Alternatively (the way the code is set up), this code just returns the
 declarations in some form (symbol table entries would be ok), and allows
the higher level code to make the determinatino about how to deal with them.
 This allows for some degree of reentrancy to the system.

The symbol table itself is available to both levels, and is kept as up to date
 as possible.

I like the reentrancy aspect enough more than the pain of having to hang onto
 some partially formed declaration, so that's what we'll go with.

"

"
OOPS -- seems that the direct tree building trick won't work quite right -- 
looks like we need to build a parse tree and then scan it for declarations.
Sigh.
"

"Another problem: how to typedefs work?  They are currently stored exactly 
 like normal variable declarations.  We need to detect them (relatively easy),
 and then use them (somewhat hard).  

The issue is that they are correct, except that they may have a scope 
 (which we don't need), they are marked as being a typedef, which means
that if we use them direclty, we can mistakenly interpret their 
instantiations as typedefs, and, where we logically need to plug them into
the type chain is at the bottom of the typedef, where the typedef name is.

When we use them, we can create a a new node which has the specifier, and
the raw type (somehow remove the name part, and possibly replace it ...
hmm... the problem is that we are at the right place when we replace the name, 
but at the wrong time.  And, when we are at the right time (like when the 
CDeclaration node is being created with the specifier and the declarator, 
we have already removed the name. 

If there was a way to get code to recurse through the specifier (hierarchy) 
I guess last, then that would work.  If the type-building (or whatever)
operation returned the built type, and then passing that type on as the 
base type (in place of the specifier) to the declarator.  This means
that the specifier accessing protocol might need to be a little more complex 
to account for this case.

Somehow, it does not feel general enough -... so what would feel general
 enough?  There are a bunch of different types of objects: type definitions,
 struct definitions, enum definitions, variable definitions, function
 declarations, (function definitions), variable declarations.

{note that we have to be somewhat careful -- variable declarations can
occur in the .h files, but probably not variable definitions.  Although,
some struct declarations may appear before the struct declaration, if used as a
 pointer, -- may need to be careful about merging them into the symbol table.}

You'd be able to tell a typedef right off.  You'd have a way to get the
type out, and use it as the base type for the rest of what you are
declaring.  

"


Object subclass: #CTypeParser
       instanceVariableNames: 'stream'
       classVariableNames: 'SymbolTable'
       poolDictionaries: 'CKeywords CToks'
       category: nil
!


CTypeParser comment:
'I parse C declarations (and some simple definitions), and yield useful
structures.  I appear to my caller to be a stream of declaration objects,
which can have "declare" invoked on them to make them register themselves
with the symbol table.  I return nil if I cannot parse, including eof.'
!

!CTypeParser class methodsFor: 'instance creation'!

on: aStream
    ^self new init: aStream
!

test: aFilename
    | s declarations |
    s _ self on: (PreprocessorStream on: (FileStream open: aFilename mode: 'r')).
    [ declarations _ s next.
      declarations notNil ] whileTrue: 
	[ declarations do: [ :decl | decl store ].
	  Transcript next: 70 put: $- ; nl; nl ].
! 

test2: aFilename
    | s declarations |
    s _ self on: (PreprocessorStream on: (FileStream open: aFilename mode: 'r')).
    [ declarations _ s next.
      declarations notNil ] whileTrue: 
	[ declarations do: [ :decl | decl declareInto: s symbolTable ].
	  Transcript next: 70 put: $- ; nl; nl ].
! 

testJust2: aFilename
    | s declarations |
    s _ self on: (PreprocessorStream on: (FileStream open: aFilename mode: 'r')).
    
    2 timesRepeat: 
	[ s next do: [ :decl | decl declareInto: s symbolTable.
			       decl store ].
	  Transcript next: 70 put: $- ; nl; nl. ].
! !


!CTypeParser methodsFor: 'accessing'!

next
    "Yields nil at end of stream, otherwise, yields the next
     declaration"
    stream atEnd
	ifTrue: [ ^ nil ].
    
    ^self parseDeclaration
! !



!CTypeParser methodsFor: 'parsing'!

    "grammar:
     <decl> ::= <declaration specifier>* [ <declarator list> ] ';'
     <declaration specifier> ::=
     	<storage class specifier>
     	| <type specifier>
     	| 'typedef'
     <storage class specifier> ::=
	'static'
	| 'auto'
	| 'register'
	| 'extern'  
     <type specifier> ::= 
     	<simple type name>
     	| <structoid specifier>
     	| <enum specifier>
     	| <elaborated type specifier>
     <simple type name> ::=
     	<ident (symbol table type)>
	| void | unsigned | ... (a list)
     <structoid specifier> ::= 
	<structoid start> '{' <member>* '}'
     <structoid start> ::= 
     	{ 'struct' | 'union' } [ <ident> ] 
     <member> ::= 
	<declaration specifier>* [ <member declarator list> ] ';'
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression>
     <enum specifier> ::=
     	'enum' [ <ident> ] '{' [ <enum list> ] '}'
     <enum list> ::=
	{ <enumerator> # ',' }+
     <enumerator> ::=
     	<ident>
     	| <ident> '=' <constant expression>
     <elaborated type specifier> ::= 
     	{ 'struct' | 'union' } <ident>
     	| 'enum' <ident (enum name)>
     <declarator list> ::= 
     	{ <init declarator> # ',' }+
     <init declarator> ::=
     	<declarator> [ <initializer> ]
     <declarator> ::=
     	<ident>
     	| '*' <declarator>
     	| <declarator> '(' <argument declaration list> ')'
     	| <declarator> '[' [ <constant expression> ] ']'
     	| '(' <declarator> ')'
     <initializer> ::= 
     	'=' <assignment expression> ??? <constant expression>?
     	| '=' '{' <initializer list> [ ',' ] '}'
     	| '(' <expression list> ')'  ???
     <initializer list> ::= 
     	{ <assignment expression> # ',' }+
     	| '{' <initializer list> [ ',' ] '}'
     "

parseDeclaration
     "<decl> ::= <declaration specifier>* [ <declarator list> ] ';'"
    | specifier declaration |
    specifier _ self parseDeclarationSpecifierList.
    declaration _ self parseDeclaratorList: specifier.
    stream next.		"gobble ';'"
    ^declaration
!      
     	

parseDeclarationSpecifierList
    | specifier |

    specifier _ CDeclarationSpecifier storageClass: nil type: CLangInt new.	"right?"
    [ (self parseDeclarationSpecifier: specifier) notNil ] whileTrue: [ ].
    ^specifier
!

parseDeclarationSpecifier: specifier
    | token |

    "parses:
     <declaration specifier> ::=
     	<storage class specifier>
     	| <type specifier>
     	| 'typedef'
     <storage class specifier> ::=
	'static'
	| 'auto'
	| 'register'
	| 'extern'  
     <type specifier> ::= 
     	<simple type name>
     	| <structoid specifier>
     	| <enum specifier>
     	| <elaborated type specifier>
     <simple type name> ::=
     	<ident (symbol table type)>
	| void | unsigned | ... (a list)
     <structoid specifier> ::= 
	<structoid start> '{' <member>* '}'
     <structoid start> ::= 
     	{ 'struct' | 'union' } [ <ident> ] 
     <member> ::= 
	<declaration specifier>* [ <member declarator list> ] ';'
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression>
     <enum specifier> ::=
     	'enum' [ <ident> ] '{' [ <enum list> ] '}'
     <enum list> ::=
	{ <enumerator> # ',' }+
     <enumerator> ::=
     	<ident>
     	| <ident> '=' <constant expression>
     <elaborated type specifier> ::= 
     	{ 'struct' | 'union' } <ident>
     	| 'enum' <ident (enum name)>
     "

    token _ stream peek.
    token isNil ifTrue: [ ^nil ]. "hit end of file"

    (self isStorageClassToken: token) ifTrue: 
	[ ^specifier storageClass: stream next ].
    
    token == EnumKey ifTrue: 
	[ ^specifier type: self parseEnumSpecifier ].

    token == TypedefKey ifTrue:
	[ stream next.
	  ^specifier isTypedef: true ].

    (self isStructoidToken: token) ifTrue:
	[ ^specifier type: self parseStructoid ].

    'here goes ' print. token printNl.
    (self isTypeName: token) ifTrue:
	[ '!!! Got atypedef' printNl.
	  ^specifier type: (self tokenToType: stream next) ].
    
    (self isSimpleType: token) ifTrue:
	[ ^specifier type: self parseSimpleTypeName ].
    ^nil			"nothing that we recognize, continue on"
!

isStorageClassToken: token
    ^(token == StaticKey) | (token == AutoKey) | (token == RegisterKey)
	| (token == ExternKey) 
!


isStructoidToken: token
    ^(token == StructKey) | (token == UnionKey)
!

isTypeName: token
    | symbol |
    token class == CIdentifierToken ifTrue: 
	[ symbol _ SymbolTable at: token.
	  symbol notNil ifTrue: 
	      [ ^symbol isTypedef ].
	 ].
    ^false
!

tokenToType: token
    | symbol |

    "Get this guy from the symbol table."
    symbol _ SymbolTable at: token.
    ^symbol typedefIntoType
!


isSimpleType: token
    ^(token == UnsignedKey) |
	(token == SignedKey) |
	(token == CharKey) |
	(token == ShortKey) |
	(token == IntKey) | 
	(token == LongKey) |
	(token == FloatKey) |
	(token == DoubleKey) |
	(token == VoidKey )
!

parseSimpleTypeName
    | token signedModifier sizeModifier |
    
    token _ stream peek.
    (token == UnsignedKey) | (token == SignedKey)
	ifTrue: [ signedModifier _ token.
		  stream next.
		  token _ stream peek ].
    "now, can have short, long, float, double, char, void or int.  We try for the 
     size modifiers first "
    (token == ShortKey) | (token == LongKey)
	ifTrue: [ sizeModifier _ token.
		  stream next.
		  token _ stream peek. ].
    "now just float, double, char, void, or int (or nothing)"
    token == FloatKey
	ifTrue: [ "hack the modifier here"
		  stream next.
		  ^CLangFloat new].
    token == DoubleKey
	ifTrue: [ "hack the modifier here" 
		  stream next.
		  ^CLangDouble new ].
    token == CharKey
	ifTrue: [ stream next.
		  signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedChar new ]
		      ifFalse: [ ^CLangChar new ]].
    token == VoidKey
	ifTrue: [ stream next.
		  ^CLangVoid new ].
    token == IntKey
	ifTrue: [ stream next. ].
    
    "Whether or not int was present doesn't matter here "
    sizeModifier == ShortKey
	ifTrue: [ signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedShort new ]
		      ifFalse: [ ^CLangShort new ] ].
    sizeModifier == LongKey
	ifTrue: [ signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedLong new ]
		      ifFalse: [ ^CLangLong new ] ].

    "In the default case, we're just an int"
    
    signedModifier == UnsignedKey
	ifTrue: [ ^CLangUnsignedInt new ]
	ifFalse: [ ^CLangInt new ]
!    


parseEnumSpecifier
    | token enumName enumList enumType |
    "Starts with stream before 'enum'
     <enum specifier> ::=
     	'enum' [ <ident> ] '{' [ <enum list> ] '}'
     <enum list> ::=
	{ <enumerator> # ',' }+
     <enumerator> ::=
     	<ident>
     	| <ident> '=' <constant expression>
     <elaborated type specifier> ::= 
	[ ... ]
     	| 'enum' <ident (enum name)>
     "
    stream next.		"gobble enum"
    token _ stream peek.

    "can have either ident or open curly"
    token class == CIdentifierToken ifTrue:
	[ enumName _ stream next.
	  token _ stream peek ].
    
    token == OpenBraceTok ifTrue: 
	[ enumList _ self parseEnumList ].
    
    enumName notNil
	ifTrue: [ enumType _ self lookupEnumName: enumName.
		  enumType isNil ifTrue:
		      [ enumType _ CDeclarationEnum name: enumName
						    literals: enumList ].
		  ^enumType ]
	ifFalse: [ "just a raw enum -- build the type and return it"
		   ^CDeclarationEnum name: nil literals: enumList ].
!
	
parseEnumList
    | token enumList |

    "Starts parsing before the brace:
     '{' [ <enum list> ] '}'
     <enum list> ::=
	{ <enumerator> # ',' }+
     <enumerator> ::=
     	<ident>
     	| <ident> '=' <constant expression>"

    enumList _ OrderedCollection new.
    self parseBracesWithCommas: [ enumList add: self parseEnumerator. ].
    ^enumList
!

parseEnumerator
    | name token value |

     "Starts before this production:
      <enumerator> ::=
     	<ident>
     	| <ident> '=' <constant expression>"

    name _ stream next.
    token _ stream peek.
    self gobbleEqualTok ifTrue: 
	[ value _ self parseConstantExpression. ].
    
    ^CDeclarationEnumerator name: name value: value
!


parseStructoid
    | token structType structName memberList |

    "We are at the start of this production, although we know it has to be 
     on one of the paths indicated:
     <type specifier> ::= 
     	<simple type name>
     	| *** <structoid specifier>
     	| <enum specifier>
     	| *** <elaborated type specifier>
     <structoid specifier> ::= 
	<structoid start> '{' <member>* '}'
     <structoid start> ::= 
     	{ 'struct' | 'union' } [ <ident> ] 
     <member> ::= 
	<declaration specifier>* [ <member declarator list> ] ';'
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression>
     <elaborated type specifier> ::= 
     	{ 'struct' | 'union' } <ident>
     	| 'enum' <ident (enum name)> "

     structType _ stream next.	"either 'struct' or 'union'"
     
     token _ stream peek.
     token class == CIdentifierToken ifTrue: 
	 [ structName _ stream next.
	   token _ stream peek ].
     
     memberList _ OrderedCollection new.

     token == OpenBraceTok ifTrue: 
	 [ memberList _ self parseStructoidMemberList ].
     
     structType == StructKey
	 ifTrue: [ ^CDeclarationStruct name: structName members: memberList ]
	 ifFalse: [ ^CDeclarationUnion name: structName members: memberList ]
!

parseStructoidMemberList
    | memberList |

    "Here is what we parse:
     '{' <member>* '}'
     <structoid start> ::= 
     	{ 'struct' | 'union' } [ <ident> ] 
     <member> ::= 
	<declaration specifier>* [ <member declarator list> ] ';'
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression> "
    
    stream next.		"gobble '{'"
     
    memberList _ OrderedCollection new.
    [ self gobbleCloseBraceTok ] whileFalse: 
	[ memberList add: self parseMember.  ].

    ^memberList
!

parseMember
    | declarationSpecifier  memberDeclaration |

    " parses 
     <member> ::= 
	<declaration specifier>* [ <member declarator list> ] ';'
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression> 
	| : <constant expression> "
    
    declarationSpecifier _ self parseDeclarationSpecifierList.
    memberDeclaration _ self parseMemberDeclaratorList: declarationSpecifier.
    stream next.		"gobble ';'"
    ^memberDeclaration
!

parseMemberDeclaratorList: declarationSpecifier
    | declarator token declarationList |
    "
     <member declarator list> ::=
     	{ <member declarator> # ',' }+
     <member declarator> ::=
     	<declarator>
     	| <declarator> ':' <constant expression> 
	| : <constant expression> "

    declarationList _ OrderedCollection new.
    [ declarator _ self parseMemberDeclarator.
      declarationList add: (CDeclaration specifier: declarationSpecifier
					 declarator: declarator).
      token _ stream peek.
      self gobbleCommaTok ] whileTrue: [ ].
   ^declarationList
!    


parseMemberDeclarator
    | token declarator bitSize |
    " parses
     <member declarator> ::=
     	<declarator> 
     	| <declarator> ':' <constant expression> 
	| : <constant expression> "
    
    "Hmm -- guessing about parseDeclarator: "
    declarator _ self parseDeclarator.
    token _ stream peek.
    token == ColonTok
	ifTrue: [ stream next.	"gobble it"
		  bitSize _ self parseConstantExpression.
		  "!!! this may not be the right way to use declaration 
		   specifier/ parentType -- I think the declaration specifier 
		   is applied last after building the rest of the thing."
		  declarator _ CDeclarationBitfield parentType: declarator
						    length: bitSize ].
    ^declarator
!

parseDeclaratorList: specifier
    | list token declarator |

    "Parsing starts here:
     <declarator list> ::= 
     	{ <init declarator> # ',' }+
     <init declarator> ::=
     	<declarator> [ <initializer> ]
     <declarator> ::=
     	<ident>
     	| '*' <declarator>
     	| <declarator> '(' <argument declaration list> ')'
     	| <declarator> '[' [ <constant expression> ] ']'
     	| '(' <declarator> ')'
     <initializer> ::= 
     	'=' <assignment expression> ??? <constant expression>?
     	| '=' '{' <initializer list> [ ',' ] '}'
     	| '(' <expression list> ')'  ???
     <initializer list> ::= 
     	{ <assignment expression> # ',' }+
     	| '{' <initializer list> [ ',' ] '}'
     "

    "We pretend that we have seen these declarations all on separate lines, 
     and return an ordered collection of declarations"

    list _ OrderedCollection new.
    [ declarator _ self parseInitDeclarator.
      list add: (CDeclaration specifier: specifier
			      declarator: declarator).
      token _ stream peek.
      self gobbleCommaTok ] whileTrue: [ ].
    ^list

!

parseInitDeclarator
    | declarator token initializer |
    "parses:
     <init declarator> ::=
     	<declarator> [ <initializer> ]
     <declarator> ::=
     	<ident>
     	| '*' <declarator>
     	| <declarator> '(' <argument declaration list> ')'
     	| <declarator> '[' [ <constant expression> ] ']'
     	| '(' <declarator> ')'
     <initializer> ::= 
     	'=' <assignment expression> ??? <constant expression>?
     	| '=' '{' <initializer list> [ ',' ] '}'
     <initializer list> ::= 
     	{ <assignment expression> # ',' }+
     	| '{' <initializer list> [ ',' ] '}'
     "
    
    declarator _ self parseDeclarator.
    self gobbleEqualTok ifTrue:
	[ initializer _ self parseInitializer.
	  ^CDeclarationInitialized declarator: declarator
				   initializer: initializer. ].
    ^declarator
!

parseInitializer
    | token initializerList |
    "We're just past the '=':
     <initializer> ::= 
     	'=' <assignment expression> ??? <constant expression>?
     	| '=' '{' <initializer list> [ ',' ] '}'
     <initializer list> ::= 
	<assignment expression>
	| <initializer list> ',' <assignment expression>
     	| '{' <initializer list> [ ',' ] '}'
     "

    token _ stream peek.
    token == OpenBraceTok
	ifTrue: [ ^self parseInitializerList. ]
	ifFalse: [ ^self parseAssignmentExpression ]
!

parseInitializerList
    | token initializerList initializer | 
    "We are just at the '*' (just a marker, not in the stream)
     <initializer> ::= 
     	'=' <assignment expression> ??? <constant expression>?
     	| '=' * '{' <initializer list> [ ',' ] '}'
     <initializer list> ::= 
	<assignment expression>
	| <initializer list> ',' <assignment expression>
     	| '{' <initializer list> [ ',' ] '}'
     "
    
    stream next.		"gobble '{'"
    initializerList _ OrderedCollection new.
    [ token _ stream peek.
      token == OpenBraceTok
	  ifTrue: [ initializer _ self parseInitializerList ]
	  ifFalse: [ initializer _ self parseAssignmentExpression ].
      initializerList add: initializer.
      self gobbleCommaTok.	"eat a ',' if there is one"
      self gobbleCloseBraceTok.	"terminate if '}' seen"
      ] whileFalse: [ ].
    ^initializerList
!

OBSOLETEparseListOfInitializers
    | initializerList initializer |
    "We are just at the '*':
     <initializer list> ::= 
     	{ <assignment expression> # ',' }+
     	| * '{' <initializer list> [ ',' ] '}'
     "
    
    stream next.		"gobble '{'"
    
    initializerList _ OrderedCollection new.
    [ initializer _ self parseInitializerList.
      initializerList add: initializer.
      self gobbleCommaTok ] whileTrue: [ ]. "not exactly right, but close "

    stream next.		"gobble '}'"
    ^initializerList
!

OBSOLETEparseListOfAssignmentExpressions
    | assignmentExprList assignmentExpr |
    
    "We are at the '*'
     <initializer list> ::= 
     	* { <assignment expression> # ',' }+
     	| '{' <initializer list> [ ',' ] '}'
     "

    assignmentExprList _ OrderedCollection new.
    [ assignmentExpr _ self parseAssignmentExpression.
      assignmentExprList add: assignmentExpr.
      self gobbleCommaTok ] whileTrue: [ ].

    ^assignmentExprList
!

parseDeclarator
    | token declarator |

    "Here we are at the core of the type parser.
     <declarator>
     	<ident>
     	| '*' <declarator>
     	| <declarator> '(' <argument declaration list> ')'
     	| <declarator> '[' [ <constant expression> ] ']'
     	| '(' <declarator> ')'
     "

    token _ stream peek.

    (self isStarTok: token) 
	ifTrue: [ stream next.	"gobble the token "
		  declarator _ self parseDeclarator.
		  ^CDeclarationPtr declarator: declarator ].
    token == OpenParenTok
	ifTrue: [ stream next.	"gobble '('"
		  declarator _ self parseDeclarator.
		  stream next.	"gobble ')'" ].
    "We can do this because token hasn't changed and the choices are mutex"
    token class == CIdentifierToken
	ifTrue: [ declarator _ CDeclarationName name: stream next.
		  "should be an ident" ].
    
    ^self parseDeclaratorSuffixList: declarator
!

parseDeclaratorSuffixList: baseDeclarator
    | token declarator |
					     
    "We are at the '*'
     	| <declarator> * '(' <argument declaration list> ')'
     	| <declarator> * '[' [ <constant expression> ] ']'
     "

    token _ stream peek.

    token == OpenParenTok
	ifTrue: 
	    [ declarator _ self parseFunctionDeclaration: baseDeclarator. 
	      ^self parseDeclaratorSuffixList: declarator ].
    token == OpenBracketTok
	ifTrue: 
	    [ declarator _ self parseArrayDimension: baseDeclarator. 
	      ^self parseDeclaratorSuffixList: declarator ].
    ^baseDeclarator
!

parseFunctionDeclaration: baseDeclarator
    | argList |

    "We are at '*'
     <declarator> * '(' <argument declaration list> ')'"

    stream next.		"skip '('"
    argList _ self parseArgumentDeclarationList.
    stream next.		"skip ')'"
    
    ^CDeclarationFunction parentType: baseDeclarator arguments: argList
!

parseArgumentDeclarationList
    | token argList |
    "This parses 
     <argument declaration list> ::=
	| <empty> 
     	| '...' 
     	| <arg decl list> 
     	| <arg decl list> ',' '...'
     <arg decl list> ::=
	{ <argument declaration> # ',' }+
     "

    token _ stream peek.
    token == DotDotDotTok
	ifTrue: [ argList _ OrderedCollection new.
		  argList add: (CDeclarationArgEllipses new).
		  ^argList ].
    ^self parseArgDeclList
!

parseArgDeclList
    | token argDecl argList | 
    
    "Parses the productions marked with '*'
     <argument declaration list> ::=
	| * <empty> 
     	| '...' 
     	| * <arg decl list> 
     	| * <arg decl list> ',' '...'
     <arg decl list> ::=
	{ <argument declaration> # ',' }+
     "
    
    
    argList _ OrderedCollection new.
    
    argDecl _ self parseArgumentDeclaration.
    argDecl isNil
	ifTrue: 
	    [ " <empty> "
	      ^argList ].
    
    argList add: argDecl.
    [ self gobbleCommaTok ] whileTrue:
	[ token _ stream peek.
	  token == DotDotDotTok
	      ifTrue: [ argList add: CDeclarationArgEllipses new.
			^argList ].
	  argDecl _ self parseArgumentDeclaration.
	  argList add: argDecl ].
    ^argList
!


parseArgumentDeclaration
    | specifier declarator |

    "Parses:
     <argument declaration> ::=
	<declaration specifier>* <declarator>
    "
    specifier _ self parseDeclarationSpecifierList.
    declarator _ self parseDeclarator.
    ^CDeclarationArgument specifier: specifier declarator: declarator
!

parseArrayDimension: baseDeclarator
    | length t |
    "parses '[' [ <constant expression> ']' "
    t _ stream next.		"skip '['"
    stream peek class ~~ CloseBracketTok ifTrue: 
	[ length _ self parseConstantExpression. ].
    stream next.		"skip ']'"
					 
    ^CDeclarationArray length: length parentType: baseDeclarator
!

parseConstantExpression
    | parser |
    "May not be best to be on the stream..."
    parser _ CExpressionParser onStream: stream.
    "I decided to do the evaluation because almost always we only care
     about the evaluated expression and not the expression itself. Also,
     if the expression is not evaludated immediately and involves things 
     which can change due to further declarations, we could get a bad value."
    ^parser conditionalExpression evaluate
!


parseAssignmentExpression
    | parser |
    parser _ CExpressionParser onStream: stream.
    "I decided to do the evaluation because almost always we only care
     about the evaluated expression and not the expression itself. Also,
     if the expression is not evaludated immediately and involves things 
     which can change due to further declarations, we could get a bad value."
    ^parser assignExpression evaluate	 "!!!not the best -- a temp hack"
!




"------------ Utility methods below here -------------"

"
parseBraceAndCommaList: aBlock
    
    | assignmentExprList assignmentExpr |
    
    ""Parses 
     <brace and comma list> ::= 
     	'{' <some nonterminal > [ ',' ] '}'
     ""

    stream next.		""gobble '{'""
    
    assignmentExprList _ OrderedCollection new.
    [ assignmentExpr _ self parseAssignmentExpression.
      assignmentExprList add: assignmentExpr.
      self gobbleCommaTok ] whileTrue: [ ].

    stream next.		""gobble '}'""
    ^assignmentExprList
"


" self ifNextIs: ColonTok
       then: [ ablock ] ' should be expressed in terms of the method below'


  self ifNextIs: [ :token | ... ]
       do: [ stream next. ]	'gobble it'
       andThen: [ a block ]     'the main body'

"


gobbleCommaTok
    | token |

    "Answers true if it was able to grab the comma, and false if not"

    token _ stream peek.
    (token class == CBinaryOperatorToken
	and: [ token value = ',' ]) ifTrue:
	[ stream next.		"gobble it!"
	  ^true ].
    ^false
!				    
    

gobbleCloseBraceTok
    | token |

    "Answers true if it was able to grab the comma, and false if not"

    token _ stream peek.

    token == CloseBraceTok ifTrue:
	[ stream next.		"gobble it!"
	  ^true ].
    ^false
!				    
    

gobbleEqualTok
    | token |
    "Answers true if it was able to grab the '=', and false if not"

    token _ stream peek.
    (token class == CBinaryOperatorToken
	and: [ token value = '=' ]) ifTrue:
	[ stream next.		"gobble it!"
	  ^true ].
    ^false
!

parseBracesWithCommas: aBlock
    | token |
    "parses
     '{' { <some production> # ',' }* '}' "

    stream next.		"gobble '{'"
     
    [ self gobbleCloseBraceTok ] whileFalse:
	  [ aBlock value.
	    self gobbleCommaTok. ].
!




isEqualTok: token
    ^token class == CBinaryOperatorToken
	and: [ token value = '=' ]
!

isStarTok: token
    ^token class == COperatorToken
	and: [ token value = '*' ]
!

lookupEnumName: enumName
    ^SymbolTable atEnum: enumName
!


parseBalancedBraces
    | count token |
     "Parses a balanced, possibly nested, set of braces"

    count _ 1.
    [ count > 0 ] whileTrue: 
	[ token _ stream next.
	  token == OpenBraceTok
	      ifTrue: [ count _ count + 1 ].
	  token == CloseBraceTok
	      ifTrue: [ count _ count - 1 ].
	  ].
! !

"
parseTypeList
    ""Parses a C type list, either a single type name, or a compound type 
     like 'unsigned short'.""
    | token type signedModifier sizeModifier |
    token _ stream peek.
    (type _ SymbolTable at: token)
	notNil ifTrue: [ ^type ].
    signedModifier _ SignedKey.
    token == UnsignedKey 
	ifTrue: [ signedModifier _ UnsignedKey.
		  stream next.
		  token _ stream peek ].
    ""now, can have short, long, float, double, char, void or int.  We try for the 
     size modifiers first ""
    (token == ShortKey) | (token == LongKey)
	ifTrue: [ sizeModifier _ token.
		  stream next.
		  token _ stream peek. ].
    ""now just float, double, char, void, or int (or nothing)""
    token == float 
	ifTrue: [ ""hack the modifier here""
		  stream next.
		  ^CLangFloat new].
    token == double
	ifTrue: [ ""hack the modifier here"" 
		  stream next.
		  ^CLangDouble new ].
    token == char
	ifTrue: [ stream next.
		  signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedChar new ]
		      ifFalse: [ ^CLangChar new ]].
    token == void
	ifTrue: [ stream next.
		  ^CLangVoid new ].
    token == int
	ifTrue: [ stream next. ].
    
    ""Whether or not int was present doesn't matter here ""
    sizeModifier == ShortKey
	ifTrue: [ signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedShort new ]
		      ifFalse: [ ^CLangShort new ] ].
    sizeModifier == LongKey
	ifTrue: [ signedModifier == UnsignedKey
		      ifTrue: [ ^CLangUnsignedLong new ]
		      ifFalse: [ ^CLangLong new ] ].

    ""In the default case, we're just an int""
    
    signedModifier == UnsignedKey
	ifTrue: [ ^CLangUnsignedInt new ]
	ifFalse: [ ^CLangInt new ]
!
"

!CTypeParser methodsFor: 'accessing'!

symbolTable
    ^SymbolTable
! !


!CTypeParser methodsFor: 'private'!

init: aStream
    stream _ aStream.
    SymbolTable _ CSymbolTable new.
! !

		      
    
    

"
| x |
     CTypeParser test: 'test.c'
!

"
PK
     �Mh@�]�'F  F    PushBackStream.stUT	 cqXO��XOux �  �  "======================================================================
|
|   A stream wrapper with unlimited push back capabilites
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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


StreamWrapper subclass: #PushBackStream
	   instanceVariableNames: 'queue '
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Examples-Useful'
!

PushBackStream comment:
'LIFO pushback capability on top of ReadStreams'
!


!PushBackStream methodsFor: 'accessing' !

next
    | char |
    queue size > 0 
	ifTrue: [ ^queue removeFirst ].
    ^self atEnd
	ifTrue: [ nil ]
	ifFalse: [ super next ]
!

peek
    self atEnd ifTrue: [ ^nil ].
    ^queue size == 0 
	ifTrue: [ self putBack: self next ]
	ifFalse: [ queue at: 1 ]
!

position
    ^super position - queue size
!

position: pos
    super position: pos.
    queue := OrderedCollection new
!

stream
    ^stream
!

atEnd
    ^(queue size == 0) and: [ super atEnd ]
!

putBack: anElement
    ^queue addFirst: anElement
! !






!PushBackStream methodsFor: 'private'!

init: aStream
    super init: aStream.
    queue _ OrderedCollection new.
! !
PK
     �Mh@���F�  �    CSymbolTable.stUT	 cqXO��XOux �  �  "======================================================================
|
|   C symbol table implementation, part of the C header parser.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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


"need to have an instance which is the symbol table.

need push scope, pop scope.

need symbol, with symbol kind (variable, function, type).

need separate struct/union tag space
need separate enum tag space

need lookup by name, and some kind of typeof operation

??? Should this be the keeper of whether its a variable or not?


"

Object subclass: #CSymbolScope
       instanceVariableNames: 'symbols structTags enumTags'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CSymbolScope class methodsFor: 'instance creation'!

new
    ^super new init
! !


!CSymbolScope methodsFor: 'accessing'!

at: aName
    | definition | 
    ^symbols at: aName ifAbsent: [ nil ].
!


at: aName put: aDefinition
    ^symbols at: aName put: aDefinition
!

atStruct: aName
    ^structTags at: aName ifAbsent: [ nil ].
!

atStruct: aName put: aDefinition
    ^structTags at: aName put: aDefinition
!

atEnum: aName
    ^enumTags at: aName ifAbsent: [ nil ].
!

atEnum: aName put: aDefinition
    ^enumTags at: aName put: aDefinition
! !


!CSymbolScope methodsFor: 'private'!

init
    symbols _ Dictionary new.
    structTags _ Dictionary new.
    enumTags _ Dictionary new.
! !




Object subclass: #CSymbolTable
       instanceVariableNames: 'scopeStack'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CSymbolTable class methodsFor: 'instance creation'!

new
    ^super new init
! !


!CSymbolTable methodsFor: 'scope control'!

saveScope
    ^scopeStack addFirst: CSymbolScope new
!

restoreScope
    ^scopeStack removeFirst.
! !

"!!! to be correct, there should be a scope type object which holds
 the symbols, etc, so lookup just tries looking up in each scope
 in the stack.  However, I am lazy."

!CSymbolTable methodsFor: 'accessing'!

at: aName
    | definition | 
    scopeStack do: 
	[ :scope | definition _ scope at: aName.
		   definition notNil ifTrue: [ ^definition ]. ].
    "!!! issue an error message?"
    ^nil
!

at: aName put: aDefinition
    ^scopeStack first at: aName put: aDefinition
!

atStruct: aName
    | definition |
    scopeStack do: 
	[ :scope | definition _ scope atStruct: aName.
		   definition notNil ifTrue: [ ^definition ]. ].
    "!!! issue an error message?"
    ^nil
!

atStruct: aName put: aDefinition
    ^scopeStack first atStruct: aName put: aDefinition
!

atEnum: aName
    | definition |
    scopeStack do: 
	[ :scope | definition _ scope atEnum: aName.
		   definition notNil ifTrue: [ ^definition ]. ].
    "!!! issue an error message?"
    ^nil
!

atEnum: aName put: aDefinition
    ^scopeStack first atEnum: aName put: aDefinition
! !


!CSymbolTable methodsFor: 'private'!

init
    scopeStack _ OrderedCollection new.
    scopeStack add: CSymbolScope new. 
! !

PK
     �Mh@�C˰"  �"    CExpressionNode.stUT	 cqXO��XOux �  �  "======================================================================
|
|   C expression node support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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


Object subclass: #CExpressionNode
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CExpressionNode subclass: #CBinaryExpressionNode
       instanceVariableNames: 'left op right'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CExpressionNode subclass: #CPrefixUnaryExpressionNode
       instanceVariableNames: 'op expr'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CExpressionNode subclass: #CPostfixUnaryExpressionNode
       instanceVariableNames: 'expr op'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CExpressionNode class methodsFor: 'subclass creation'!

subclass: subclassName
    ^self subclass: subclassName
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! !



!CExpressionNode methodsFor: 'evaluation'!

evaluate
    ^self subclassResponsibility
!

isCValueTrue: value
    ^value ~= 0
!

boolToCValue: aBoolean
    ^aBoolean ifTrue: [ 1 ] ifFalse: [ 0 ]
! !


!CPrefixUnaryExpressionNode class methodsFor: 'instance creation'!

op: operator expr: anExpression
    ^self new op: operator expr: anExpression
! !


!CPrefixUnaryExpressionNode methodsFor: 'assignment'!

op: operator expr: anExpression
    op _ operator.
    expr _ anExpression
! !


CPrefixUnaryExpressionNode subclass: #UMinusNode!
CPrefixUnaryExpressionNode subclass: #UPlusNode!
CPrefixUnaryExpressionNode subclass: #BitInvertNode!
CPrefixUnaryExpressionNode subclass: #LogicalComplementNode
    "Why Dr. McCoy, you are indeed today looking every bit the splendid
     example of humanity at its finest"  
    "What's got into you, you pointed eared Vulcan?"!
CPrefixUnaryExpressionNode subclass: #DereferenceNode!
CPrefixUnaryExpressionNode subclass: #AddressOfNode!
CPrefixUnaryExpressionNode subclass: #SizeOfNode!
CPrefixUnaryExpressionNode subclass: #CastNode!
CPrefixUnaryExpressionNode subclass: #PreIncrementNode!
CPrefixUnaryExpressionNode subclass: #PreDecrementNode!

!UMinusNode methodsFor: 'evaluation'!

evaluate
    ^expr evaluate negated
! !


!UPlusNode methodsFor: 'evaluation'!

evaluate
    ^expr evaluate
! !


!BitInvertNode methodsFor: 'evaluation'!

evaluate
    ^expr evaluate bitInvert
! !


!LogicalComplementNode methodsFor: 'evaluation'!

evaluate
    (self isCValueTrue: (expr evaluate))
	ifTrue: [ ^0 ]
	ifFalse: [ ^1 ]
! !


!DereferenceNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'Cannot yet evaluate a dereference!'

! !


!AddressOfNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'AddressOf operation not yet supported!'

! !


!SizeOfNode methodsFor: 'evaluation'!

evaluate
    | value |
    (expr isKindOf: CExpressionNode)
	ifTrue: [ value _ expr evaluate.
		  ^self error: 'sizeof expressions not yet done!' 
		  ]
	ifFalse: [ "must be a type, so ask the type what its size is"
		   ^expr sizeOf ]
! !


!CastNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'Cast evaluation not yet supported!'

! !

!PreIncrementNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'Cannot evaluate a prefix increment!'

! !


!PreDecrementNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'Cannot evaluate a prefix decrement!'

! !





!CPostfixUnaryExpressionNode class methodsFor: 'instance creation'!

expr: anExpression op: operator
    ^self new expr: anExpression op: operator
! !


!CPostfixUnaryExpressionNode methodsFor: 'assignment'!

expr: anExpression op: operator
    expr _ anExpression.
    op _ operator.
! !


!CPostfixUnaryExpressionNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'Cannot evaluate a postfix unary operator currently!'
! !

CPostfixUnaryExpressionNode subclass: #PostIncrementNode!
CPostfixUnaryExpressionNode subclass: #PostDecrementNode!


!CBinaryExpressionNode class methodsFor: 'instance creation'!

left: leftExpr op: operator right: rightExpr
    ^self new left: leftExpr op: operator right: rightExpr
!

left: leftExpr op: operator 
    ^self new left: leftExpr; op: operator; yourself
! !


!CBinaryExpressionNode methodsFor: 'assignment'!

left: leftExpr op: operator right: rightExpr
    left _ leftExpr.
    op _ operator.
    right _ rightExpr
!

left: leftExpr
    left _ leftExpr
!

op: operator
    op _ operator
!

right: rightExpr
    right _ rightExpr
! !


CBinaryExpressionNode subclass: #CommaNode! 

CBinaryExpressionNode subclass: #AssignNode!
CBinaryExpressionNode subclass: #ConditionalNode!
CBinaryExpressionNode subclass: #ColonNode!
CBinaryExpressionNode subclass: #CorNode!
CBinaryExpressionNode subclass: #CandNode!
CBinaryExpressionNode subclass: #BitorNode!
CBinaryExpressionNode subclass: #BitandNode!
CBinaryExpressionNode subclass: #BitxorNode!
CBinaryExpressionNode subclass: #EqNode!
CBinaryExpressionNode subclass: #RelationNode!
CBinaryExpressionNode subclass: #ShiftNode!
CBinaryExpressionNode subclass: #AddNode!
CBinaryExpressionNode subclass: #MultNode!

!AssignNode methodsFor: 'evaluation'!

evaluate
    ^self error: 'cannot assign in Smalltalk C expressions'
! !

!ConditionalNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue |
    leftValue _ left evaluate.
    (self isCValueTrue: leftValue)
	ifTrue: [ ^right evaluateLeft ]
	ifFalse: [ ^right evaluateRight ] .
! !

!ColonNode methodsFor: 'evaluation'!

evaluateLeft
    ^left evaluate.
! 

evaluateRight
    ^right evaluate.
! !



!CorNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue |
    leftValue _ left evaluate.
    (self isCValueTrue: leftValue)
	ifTrue: [ ^1 ].
    rightValue _ right evaluate.
    ^self boolToCValue: (self isCValueTrue: rightValue)
! !

!CandNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue |
    leftValue _ left evaluate.
    (self isCValueTrue: leftValue)
	ifFalse: [ ^0 ].
    rightValue _ right evaluate.
    ^self boolToCValue: (self isCValueTrue: rightValue)
! !

!BitorNode methodsFor: 'evaluation'!

evaluate
    ^left evaluate bitOr: right evaluate
! !

!BitandNode methodsFor: 'evaluation'!

evaluate
    ^left evaluate bitAnd: right evaluate
! !

!BitxorNode methodsFor: 'evaluation'!

evaluate
    ^left evaluate bitXor: right evaluate
! !

!EqNode methodsFor: 'evaluation'!

evaluate
    | result |
    result _ left evaluate = right evaluate.
    op value = '!='
	ifTrue: [ result _ result not ].
    ^self boolToCValue: result
! !

!RelationNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue |
    leftValue _ left evaluate.
    rightValue _ right evaluate.
    ^self boolToCValue: (leftValue perform: (op value asSymbol)
				   with: rightValue)
! !

!ShiftNode methodsFor: 'evaluation'!

evaluate
    | value shiftAmount |
    value _ left evaluate.
    shiftAmount _ right evaluate.
    op value = '>>'
	ifTrue: [ shiftAmount _ shiftAmount negated ].
    ^value bitShift: shiftAmount
    
! !

!AddNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue |
    leftValue _ left evaluate.
    rightValue _ right evaluate.
    ^leftValue perform: (op value asSymbol)
	       with: rightValue
! !

!MultNode methodsFor: 'evaluation'!

evaluate
    | leftValue rightValue opStr |
    leftValue _ left evaluate.
    rightValue _ right evaluate.
    opStr _ op value.
    opStr = '*' ifTrue: [ ^leftValue * rightValue ].
    opStr = '%' ifTrue: [ "??? not exactly sure about this, may have to do
			   more special casing"
			  ^leftValue \\ rightValue ].
    "must be / by this point"
    ((leftValue class isInteger)
	 and: [ rightValue class isInteger ])
	ifTrue: [ ^leftValue // rightValue ]
	ifFalse: [ ^leftValue / rightValue ]
! !


PK
     �Mh@�;      ExpansionStreamStack.stUT	 cqXO��XOux �  �  "======================================================================
|
|   C preprocessor macro expansion support
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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


StreamStack subclass: #ExpansionStreamStack
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!ExpansionStreamStack methodsFor: 'accessing'!

pushStream: aStream
    super pushStream: (aStream -> nil)
!

pushStream: aStream forMacro: macroName
    super pushStream: (aStream -> macroName)
! 

topStream
    ^super topStream key
!

isAlreadyExpanded: macroName
  "  '>>>>>>>> checking containing of: ' print. macroName printNl."
    ^(stack detect: [ :element | element value = macroName ]
	   ifNone: [ "'did not find it!!!' printNl. "nil ]) notNil
! !


PK
     �Mh@�A  A  
  CSymbol.stUT	 cqXO��XOux �  �  "======================================================================
|
|   C type declaration scalar data types, part of the C header parser.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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

"Base class for C symbol table entries"

Object subclass: #CSymbol
       instanceVariableNames: 'name type scope'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

"Not clear at the moment how these are created, so we will leave the creation
out for a while."

" See CSymbolTable for the right approach (enum name space, struct name space, etc. "

!CSymbol methodsFor: 'accessing'!

name
    ^name
!

name: aName
    name _ aName
!

type
    ^type
!

type: aType
    type _ aType
!

scope
    ^scope
!

scope: scopeType
    scope _ scopeType
! !





"base data types are

int, float, short, char, double, unsigned

struct, union (class) are types too?

aggregators are

ptr (to type)
array (of type, lengty)
function (returning type) (arg types)

Additional modifiers
const, volatile

why bother differentiating?  It's a CLangType instance, some of which may
be more complicated, some of which are not.
"


Object subclass: #CLangType
       instanceVariableNames: 'qualifier'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangType methodsFor: 'accessing'!

qualifier
    ^qualifier
!

qualifier: aSymbol
    qualifier _ aSymbol
! !


!CLangType methodsFor: 'declaring'!

declareInto: symbolTable
    "scalar data types do not store themselves in the symbol table"
    ^self
! !


!CLangType methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: self class name.
!

storeOn: aStream
    aStream nextPutAll: self class name; nextPutAll: ' new'.
! !


CLangType subclass: #CLangChar
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangUnsignedChar
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangShort
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangUnsignedShort
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


CLangType subclass: #CLangInt
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangUnsignedInt
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


CLangType subclass: #CLangLong
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangUnsignedLong
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangFloat
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangDouble
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

CLangType subclass: #CLangBitfield
       instanceVariableNames: 'baseType length'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangBitfield class methodsFor: 'instance creation'!

type: aBaseType length: anInteger
    ^self new init: aBaseType length: anInteger
! !

!CLangBitfield methodsFor: 'private'!

init: aBaseType length: anInteger
    baseType _ aBaseType.
    length _ anInteger
! !


CLangType subclass: #CLangStruct
       instanceVariableNames: 'typeName members'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangStruct methodsFor: 'accessing'!

typeName
    ^typeName
!

typeName: aName
    typeName _ aName
!

members
    ^members
!

members: aCollection
    members _ aCollection	"should this be 'a symbol table?'"
! !


CLangType subclass: #CLangArray
       instanceVariableNames: 'subType length'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangArray methodsFor: 'accessing'!

subType
    ^subType
!

subType: aType
    subType _ aType
!

length
    ^length
!

length: anInteger
    length _ anInteger
! !


CLangType subclass: #CLangPtr
       instanceVariableNames: 'subType'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangPtr methodsFor: 'accessing'!

subType
    ^subType
!

subType: aType
    subType _ aType
! !


CLangType subclass: #CLangFunction
       instanceVariableNames: 'returnType argTypes'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangFunction class methodsFor: 'instance creation'!

returnType: aType argList: argTypeList
    ^self new init: aType argList: argTypeList
! !


!CLangFunction methodsFor: 'accessing'!

returnType
    ^returnType
!

argTypes
    ^argTypes
! !

!CLangFunction methodsFor: 'private'!

init: aType argList: argTypeList
    returnType _ aType.
    argTypes _ argTypeList.
! !


CLangType subclass: #CLangEnum
       instanceVariableNames: 'literals' "counter?"
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangEnum methodsFor: 'accessing'!

literals
    ^literals
!

literals: anOrderedCollection
    literals _ anOrderedCollection
! !


CLangType subclass: #CLangEnumLiteral
       instanceVariableNames: 'name value'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CLangEnumLiteral methodsFor: 'accessing'!

name
    ^name
!

name: aName
    name _ aName
!

value
    ^value
!

value: anInteger
    value _ anInteger
! !


CLangType subclass: #CLangVoid
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


PK    �Mh@�\{   �   	  ChangeLogUT	 cqXO��XOux �  �  ��A
�0F�9�� (���D��b�)M�����������tm5m�%
���C����CH��:�VL�v���k��<ʃ��\&��X�d�����C6JY���״�sqr���%3֕QPK
     �Mh@�]�>=  =    StreamWrapper.stUT	 cqXO��XOux �  �  "======================================================================
|
|   A stream wrapper with unlimited push back capabilites
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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


Stream subclass: #StreamWrapper
	   instanceVariableNames: 'stream '
	   classVariableNames: ''
	   poolDictionaries: ''
	   category: 'Examples-Useful'
!

StreamWrapper comment:
'decorator capability for Streams'
!


!StreamWrapper class methodsFor: 'instance creation'!

on: aStream
    ^super new init: aStream
! !


!StreamWrapper methodsFor: 'accessing' !

atEnd
    ^stream atEnd
!

next
    ^stream next
!

position
    ^stream position
!

position: pos
    stream position: pos.
!

stream
    ^stream
!

species
    ^stream species
!

close
    stream close
! !



!StreamWrapper methodsFor: 'private'!

init: aStream
    stream _ aStream
! !
PK
     �Mh@���<W>  W>    CDeclNode.stUT	 cqXO��XOux �  �  "======================================================================
|
|   C declaration tree node definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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



"Issues:

Problem: directly referencing a possibly null parent type could cause 
problems.  We could plug in a dummy one which just terminates the recursions. 
Or, each could check for nil.   Or we bottle neck all through an inherited 
method which does the nil check.
"


Object subclass: #CDeclarationNode
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CDeclarationNode methodsFor: 'accessing'!

name
    ^self subclassResponsibility
!

getType: baseType
    ^self subclassResponsibility
! !


!CDeclarationNode methodsFor: 'printing'!

storeOn: aStream using: aBlock
    aStream nextPut: $(; nextPutAll: self class name; nl.
    aBlock value.
    aStream nextPut: $).
! !



CDeclarationNode subclass: #CDeclarationHierarchyNode
       instanceVariableNames: 'parentType'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CDeclarationHierarchyNode methodsFor: 'accessing'!

name
    ^parentType name
!

parentType: aType
    parentType _ aType
! !



CDeclarationNode subclass: #CDeclarationTypedefNameReplacement
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

"Don't know what methods go here yet"

!CDeclarationTypedefNameReplacement methodsFor: 'accessing'!

name
    ^nil			"we don't have a name, ad we want 
				|declaration things which check for a name to 
				|fail "
! !




CDeclarationNode subclass: #CDeclarationName
       instanceVariableNames: 'name'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationName class methodsFor: 'instance creation'!

name: aName
    ^self new init: aName
! !

!CDeclarationName methodsFor: 'accessing'!

name
    ^name
!

getType: baseType
    ^baseType
!

typedefIntoType
    "The usage here is that the type tree is rebuilt and returned."
    ^CDeclarationTypedefNameReplacement new
! !


!CDeclarationName methodsFor: 'printing'!

printOn: aStream
    "!!! fix me"
    super printOn: aStream
!

storeOn: aStream
    self storeOn: aStream using:
	[ aStream nextPutAll: '    name: '; store: name. ].
! !



!CDeclarationName methodsFor: 'private'!

init: aName
    name _ aName
! !


CDeclarationHierarchyNode subclass: #CDeclarationArray
       instanceVariableNames: 'length'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationArray class methodsFor: 'instance creation'!

length: anInteger parentType: aType
    ^self new init: anInteger parentType: aType
! !

!CDeclarationArray methodsFor: 'accessing'!

typedefIntoType
    ^CDeclarationArray length: length 
		       parentType: parentType typedefIntoType
!

getType: baseType
    ^parentType getType: (CLangArray length: length subType: baseType)
! !


!CDeclarationArray methodsFor: 'printing'!

printOn: aStream
    "!!! fix me!!!"
    super printOn: aStream.
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    length: '; store: length ; nl;
	nextPutAll: '    parentType: '; store: parentType; 
	nextPut: $).
! !



!CDeclarationArray methodsFor: 'private'!

init: anInteger parentType: aType
    length _ anInteger.
    self parentType: aType.
! !


CDeclarationHierarchyNode subclass: #CDeclarationPtr
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationPtr class methodsFor: 'instance creation'!

declarator: aType
    ^self new init: aType
! !

!CDeclarationPtr methodsFor: 'accessing'!

typedefIntoType
    ^CDeclarationPtr declarator: parentType typedefIntoType
!

getType: baseType
    ^parentType getType: (CLangPtr subType: baseType)
! !


!CDeclarationPtr methodsFor: 'printing'!

printOn: aStream
    self notYetImplemented
!

storeOn: aStream
    aStream nextPut: $(;
	nextPutAll: self class name; nextPutAll: ' declarator: ';
	store: parentType; nextPut: $).
! !



!CDeclarationPtr methodsFor: 'private'!

init: aType
    self parentType: aType.
! !


CDeclarationHierarchyNode subclass: #CDeclarationFunction
       instanceVariableNames: 'arguments'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationFunction class methodsFor: 'instance creation'!

parentType: aType arguments: argList
    ^self new init: aType arguments: argList
! !

!CDeclarationFunction methodsFor: 'accessing'!

typedefIntoType
    ^CDeclarationFunction parentType: parentType typedefIntoType
			  arguments: arguments
!

getType: baseType
    ^parentType getType: (CLangFunction returnType: baseType
					argList: arguments )
! !


!CDeclarationFunction methodsFor: 'printing'!

printOn: aStream
    self notYetImplemented
!

storeOn: aStream
    aStream nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    parentType: '; store: parentType; nl;
	nextPutAll: '    arguments: '; store: arguments;
	nextPut: $).
! !



!CDeclarationFunction methodsFor: 'private'!

init: aType arguments: argList
    self parentType: aType.
    arguments _ argList.
! !


CDeclarationNode subclass: #CDeclarationArgument
       instanceVariableNames: 'specifier declarator'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationArgument class methodsFor: 'instance creation'!

specifier: aSpecifier declarator: aDeclarator
    ^self new init: aSpecifier declarator: aDeclarator
! !

!CDeclarationArgument methodsFor: 'accessing'!

name
    self notYetImplemented
!

getType: baseType
    self notYetImplemented
! !


!CDeclarationArgument methodsFor: 'printing'!

printOn: aStream
    '>>>>>>>>>>CDeclarationArgument printOn: not done!!!' printNl.
    ^super printOn: aStream
!

storeOn: aStream
    aStream 
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    specifier: '; store: specifier; nl;
	nextPutAll: '    declartor: '; store: declarator;
	nextPut: $); nl.
! !


!CDeclarationArgument methodsFor: 'private'!

init: aSpecifier declarator: aDeclarator
    specifier _ aSpecifier.
    declarator _ aDeclarator.
! !


CDeclarationNode subclass: #CDeclarationArgEllipses
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationArgEllipses methodsFor: 'accessing'!

"I don't know what this does right yet..."
!



CDeclarationNode subclass: #CDeclaration
       instanceVariableNames: 'specifier declarator'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CDeclaration class methodsFor: 'instance creation'!

specifier: aSpecifier declarator: aDeclarator
    ^self new init: aSpecifier declarator: aDeclarator
! !


!CDeclaration methodsFor: 'accessing'!

"name, type, storage class, etc."
name
    ^declarator name
!

getType				"no need for the base type here; it is our 
				 specifier instance variable"

    ^declarator getType: specifier "get the type from the specifier?"
!

typedefIntoType
    ^CDeclaration specifier: specifier typedefIntoType
		  declarator: declarator typedefIntoType
!

storageClass
    ^specifier storageClass
!

isTypedef
    ^specifier isTypedef
! !


!CDeclaration methodsFor: 'declaring'!

declareInto: symbolTable
    | name |
    specifier declareInto: symbolTable.
    (declarator notNil and: 
	 [name _ declarator name. 
	  name notNil] ) ifTrue:
	[ symbolTable inspect.
	  name printNl.
	  symbolTable at: name put: self. ].
! !


!CDeclaration methodsFor: 'printing'!

printOn: aStream
    ^super printOn: aStream
!

storeOn: aStream
    aStream 
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    specifier: '; store: specifier; nl;
	nextPutAll: '    declarator: '; store: declarator; nl;
	nextPut: $); nl.
! !


!CDeclaration methodsFor: 'private'!

init: aSpecifier declarator: aDeclarator
    specifier _ aSpecifier.
    declarator _ aDeclarator.
! !



"It's not clear what class this should descend from."
Object subclass: #CDeclarationSpecifier
       instanceVariableNames: 'storageClass isTypedef type'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationSpecifier class methodsFor: 'instance creation'!

storageClass: aStorageClass type: aType
    ^self new init: aStorageClass type: aType
! !


!CDeclarationSpecifier methodsFor: 'accessing'!

storageClass
    ^storageClass
!

storageClass: aStorageClass
    storageClass _ aStorageClass
!

type
    ^type
!

type: aType
    type _ aType
!

isTypedef
    ^isTypedef
!

isTypedef: aBoolean
    isTypedef _ aBoolean
!

typedefIntoType
    ^CDeclarationSpecifier storageClass: nil type: type
! !


!CDeclarationSpecifier methodsFor: 'declaring'!

declareInto: symbolTable
    type declareInto: symbolTable
! !



!CDeclarationSpecifier methodsFor: 'printing'!

printOn: aStream
    storageClass notNil
	ifTrue: [ storageClass printOn: aStream; space ].
    isTypedef
	ifTrue: [ aStream nextPutAll: 'typedef ' ].
    type printOn: aStream.
!

storeOn: aStream
    aStream nextPutAll: '((';
	nextPutAll: self class name; nl;
	nextPutAll: '    storageClass: '; store: storageClass; nl;
	nextPutAll: '    type: '; store: type; nextPutAll: ');' ; nl;
	nextPutAll: '    isTypedef: '; store: isTypedef; nextPut: $; ; nl;
	nextPutAll: '    yourself)'.
! !



!CDeclarationSpecifier methodsFor: 'private'!

init: aStorageClass type: aType
    storageClass _ aStorageClass.
    type _ aType.
    isTypedef _ false.
! !


CDeclarationHierarchyNode subclass: #CDeclarationBitfield
       instanceVariableNames: 'length'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CDeclarationBitfield class methodsFor: 'instance creation'!

parentType: aType length: anInteger
    ^self new init: aType length: anInteger

! !

!CDeclarationBitfield methodsFor: 'accessing'!

getType: baseType
    ^parentType getType: (CLangBitfield type: baseType length: length)
! !


!CDeclarationBitfield methodsFor: 'printing'!

printOn: aStream
    aStream 
	print: parentType;
	nextPutAll: ' : ';
	print: length
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    parentType: '; store: parentType; nl;
	nextPutAll: '    length: '; store: length; nl;
	nextPut: $).
! !


!CDeclarationBitfield methodsFor: 'private'!

init: aType length: anInteger
    self parentType: aType.
    length _ anInteger.
! !


CDeclarationNode subclass: #CDeclarationEnum
       instanceVariableNames: 'name literals'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 


!CDeclarationEnum class methodsFor: 'instance creation'!

name: aName literals: literalCollection
    ^self new init: aName literals: literalCollection
! !


!CDeclarationEnum methodsFor: 'accessing'!

name
    ^name
!

literals
    ^literals
! !
    

!CDeclarationEnum methodsFor: 'declaring'!

declareInto: symbolTable
    (name notNil and: [ literals notNil ])
	ifTrue: [ symbolTable atEnum: name put: literals ].
! !


!CDeclarationEnum methodsFor: 'printing'!

printOn: aStream
    "!!!not there yet"
    super printOn: aStream
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    name: '; store: name; nl;
	nextPutAll: '    literals: '; store: literals; nl;
	nextPut: $).
! !


!CDeclarationEnum methodsFor: 'private'!

init: aName literals: literalCollection
    name _ aName.
    literals _ literalCollection.
! !




CDeclarationNode subclass: #CDeclarationEnumerator
       instanceVariableNames: 'name value'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationEnumerator class methodsFor: 'instance creation'!

name: aName value: aValue
    ^self new init: aName value: aValue
! !

!CDeclarationEnumerator methodsFor: 'accessing'!

name
    ^name
!

value
    ^value
! !

!CDeclarationEnumerator methodsFor: 'printing'!

printOn: aStream
    "!!! not done yet"
    super printOn: aStream
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    name: '; store: name; nl;
	nextPutAll: '    value: '; store: value; nl;
	nextPut: $).
! !


!CDeclarationEnumerator methodsFor: 'private'!

init: aName value: aValue
    name _ aName.
    value _ aValue.
! !


CDeclarationNode subclass: #CDeclarationStructoid
       instanceVariableNames: 'name members'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationStructoid class methodsFor: 'instance creation'!

name: aName members: memberCollection
    ^self new init: aName members: memberCollection
! !

"!!!Accessors"

!CDeclarationStructoid methodsFor: 'accessors'!

name
    ^name
!

members
    ^members
! !

!CDeclarationStructoid methodsFor: 'declaring'!

declareInto: symbolTable
    (name notNil and: [ members notNil ])
	ifTrue: [ symbolTable atStruct: name
			      put: self "maybe just the members?" ].
! !





!CDeclarationStructoid methodsFor: 'printing'!

printOn: aStream
    '{CDeclarationStructoid}' printNl.
    super printOn: aStream
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    name: '; store: name; nl;
	nextPutAll: '    members: '; store: members; nl;
	nextPut: $).
    
! !


!CDeclarationStructoid methodsFor: 'prviate'!

init: aName members: memberCollection
    name _ aName.
    members _ memberCollection.
! !


CDeclarationStructoid subclass: #CDeclarationStruct
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 



CDeclarationStructoid subclass: #CDeclarationUnion
       instanceVariableNames: ''
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 



CDeclarationNode subclass: #CDeclarationInitialized
       instanceVariableNames: 'declarator initializer'
       classVariableNames: ''
       poolDictionaries: ''
       category: nil
! 

!CDeclarationInitialized class methodsFor: 'instance creation'!

declarator: aDeclarator initializer: anInitializer
    ^self new init: aDeclarator initializer: anInitializer
! !


!CDeclarationInitialized methodsFor: 'accessing'!

declarator
    ^declarator
!

initializer
    ^initializer
!

name
    ^declarator name
! !

!CDeclarationInitialized methodsFor: 'printing'!

printOn: aStream
    aStream 
	print: declarator;
	nextPutAll: ' = ';
	print: initializer
!

storeOn: aStream
    aStream
	nextPut: $(;
	nextPutAll: self class name; nl;
	nextPutAll: '    declarator: '; store: declarator; nl;
	nextPutAll: '    initializer: '; store: initializer; nl;
	nextPut: $).
! !


!CDeclarationInitialized methodsFor: 'private'!

init: aDeclarator initializer: anInitializer
    declarator _ aDeclarator.
    initializer _ anInitializer.
! !
PK
     �Mh@v�\H�   �     CParseExpr.stUT	 cqXO��XOux �  �  "======================================================================
|
|   C expression parser and tree builder, part of the C header parser.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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

"Build expression trees for C"

"left or right recursive,
<delimiter or separator>
<include delim>
<next level parser>
<optional>
"

"key:
<node name> <left or right> <next node name> <delimiters>
"

Object subclass: #CExpressionParser
       instanceVariableNames: 'stream'
       classVariableNames: ''
       poolDictionaries: 'CToks'
       category: nil
! 


!CExpressionParser class methodsFor: 'instance creation'!

onStream: aStream
    ^self new init: aStream
! !


!CExpressionParser methodsFor: 'hacks r us'!

parseExpression
    ^self commaExpression
!

conditionalExpression
    | anExpr sym colonExpr |
    anExpr _ self corExpression.
    sym _ stream peek.
    sym == QuestionTok
	ifTrue: 
	    [ stream next.
	      anExpr _ ConditionalNode left: anExpr op: sym.
	      colonExpr _ ColonNode left: self corExpression.
	      sym _ stream peek.
	      sym == ColonTok
		  ifFalse: [ ^self error: 'expected '':''' ].
	      stream next.
	      colonExpr op: sym; right: self conditionalExpression.
	      anExpr right: colonExpr ].
    ^anExpr
!

unaryExpression
    "Parse a unary expression.  Binds right to left.
     First check for it being a prefix."
    | sym expr result |
    sym _ stream peek.
    "oneof - + ~ ! * & -- ++
     not in pp context: sizeof (cast)"

    (self isSimpleUnaryOp: sym)
	ifTrue: [ ^self parseSimpleUnaryExpression ].
    
    sym value = 'sizeof'
	ifTrue: [ ^self parseSizeof ].
    "!!! Ignoring casts for right now"
    sym class = OpenParenTok 
	ifTrue: [ "^self tryParsingCast" ].

    "Here we've made it through, so it must be a primary expression
     that we're after"
    
    expr _ self primaryExpression.
	      
    "now check for trailing, one of ++ or --"
    [ sym _ stream peek.
      sym notNil and: [ (sym value = '--' ) | (sym value = '++') ] ]
	whileTrue: 
	    [ sym value = '--'
		     ifTrue: [ expr _ PostDecrementNode expr: expr 
							op: stream next ]
		     ifFalse: [expr _ PostIncrementNode expr: expr 
							op: stream next ].
	      ].
    ^expr
!
	
isSimpleUnaryOp: anOperator
    ^#('-' '+' '~' '!' '*' '&' '--' '++') includes: anOperator value
!

parseSimpleUnaryExpression
    "Must be - + ~ ! * & -- ++"
    | sym value expr |
    sym _ stream next.
    value _ sym value.
    value = '-' ifTrue: [ ^UMinusNode op: sym expr: self unaryExpression ].
    value = '+' ifTrue: [ ^UPlusNode op: sym expr: self unaryExpression ].
    value = '~' ifTrue: [ ^BitInvertNode op: sym expr: self unaryExpression ].
    value = '!' ifTrue: [ ^LogicalComplementNode op: sym expr: self unaryExpression ].
    value = '*' ifTrue: [ ^DereferenceNode op: sym expr: self unaryExpression ].
    value = '&' ifTrue: [ ^AddressOfNode op: sym expr: self unaryExpression ].
    value = '--' ifTrue: [ ^PreIncrementNode op: sym expr: self unaryExpression ].
    value = '++' ifTrue: [ ^PreDecrementNode op: sym expr: self unaryExpression ].
    ^self error: 'Unhandled case in parseSimpleUnaryExpression'
!


	      
primaryExpression
    "can be one of <literal>,
     '(' <expression> ')'
     <primaryExpression> '(' <optional expression list> ')'
     <primaryExpression> '[' <expression> ']'
     <primaryExpression> '->' | '.' <primaryExpression>
     "
    | sym expr usedIt |
    sym _ stream peek.
    sym == OpenParenTok
	ifTrue:
	    [ stream next.	"gobble '('"
	      " !!! Where is casting handled"
	      expr _ self parseExpression.
	      expr printNl.
	      sym _ stream next.
	      sym printNl.
	      sym == CloseParenTok
		  ifFalse: [ ^self error: 'expecting '')''']. ]
	ifFalse: [ 
    "###should be sure to exclude comments if they could be in the stream"
		   (sym isKindOf: CValueToken)
		       ifFalse: [ ^self error: 'expecting literal value' ].
		   stream next.	"gobble the literal"
		   expr _ sym. ].
    [ sym _ stream peek.
      usedIt _ false.
      sym == OpenParenTok
	  ifTrue: [ expr _ self parseFunctionCall: expr.
		    usedIt _ true ].
      sym == OpenBracketTok
	  ifTrue: [ expr _ self parseSubscript: expr.
		    usedIt _ true ].
      (sym class == CBinaryOperatorToken and:
	   [ (sym value = '.') | (sym value = '->') ]) 
	  ifTrue: [ expr _ self parseStructureReference: expr.
		    usedIt _ true ].
      usedIt ] whileTrue: [ ].
    ^expr
!
	      
       
    
commaExpression
    ^self recurseRight: CommaNode
	  into: #assignExpression delimitedBy: ',' 
!


assignExpression
    ^self recurseRight: #AssignNode
	  into: #conditionalExpression 
	  delimitedBy: #('=' '*=' '/=' '%=' 
			     '+=' '-=' 
			     '&=' '^=' '|=' 
			     '>>=' '<<=')
!

corExpression
    ^self recurseLeft: CorNode
	  into: #candExpression delimitedBy: '||'
!

candExpression
    ^self recurseLeft: CandNode
	  into: #bitorExpression delimitedBy: '&&'
!

bitorExpression
    ^self recurseLeft: BitorNode
	  into: #bitxorExpression delimitedBy: '|'
!

bitxorExpression
    ^self recurseLeft: BitxorNode
	  into: #bitandExpression delimitedBy: '^'
!

bitandExpression
    ^self recurseLeft: BitandNode
	  into: #eqExpression delimitedBy: '&'
!

eqExpression
    ^self recurseLeft: EqNode
	  into: #relationExpression delimitedBy: #('==' '!=')
!

relationExpression
    ^self recurseLeft: RelationNode
	  into: #shiftExpression delimitedBy: #('>' '>=' '<' '<=')
!

shiftExpression
    ^self recurseLeft: ShiftNode
	  into: #addExpression delimitedBy: #('<<' '>>')
!

addExpression
    ^self recurseLeft: AddNode
	  into: #multExpression delimitedBy: #('+' '-')
!

multExpression
    ^self recurseLeft: MultNode
	  into: #unaryExpression delimitedBy: #('*' '/' '%')
!


recurseLeft: nodeClass into: builderMethod delimitedBy: delimiters
    | expr delim |
    expr _ self perform: builderMethod.
    [ delim _ stream peek.
      self inDelimiterSet: delim set: delimiters ]
	whileTrue: 
	    [ stream next.	"gobble it"
	      expr _ nodeClass left: expr op: delim 
			       right: (self perform: builderMethod) ].
    ^expr
!

recurseRight: nodeClass into: builderMethod delimitedBy: delimiters
    | expr delim |
    expr _ self perform: builderMethod.
    delim _ stream peek.
    (self inDelimiterSet: delim set: delimiters)
	ifTrue: 
	    [ stream next.	"gobble it"
	      expr _ nodeClass left: expr op: delim 
			       right: (self recurseRight: nodeClass
					    into: builderMethod 
					    delimitedBy: delimiters) ].
    ^expr
!

inDelimiterSet: delimiter set: delimiterSet
    delimiter isNil ifTrue: [ ^false ].
    (delimiterSet class == Array)
	ifTrue: [ ^delimiterSet includes: delimiter value ]
	ifFalse: [ ^delimiterSet = delimiter value ]
! !



!CExpressionParser methodsFor: 'private'!

init: aStream
    stream _ aStream
! !



"Keep this around just in case"
"foo _ #(
    comma right assign ',' 
    assign right conditional ('=' '*=' '/=' '%=' '+=' '-=' '&=' '^=' '|=' '>>=' '<<=')
    ""handle conditional directly with code""
    cor left cand '||'
    cand left bitor '&&'
    bitor left bitxor '|'
    bitxor left bitand '^'
    bitand left eq '&'
    eq left relation ('==' '!=')
    relation left shift ('>' '>= '<' '<=')
    shift left add ('<<' '>>')
    add left mult ('+' '-')
    mult left unary ('*' '/' '%')
    ""handle unary specially""

)!
"
PK
     �Mh@K� �B  B    LineTokenStream.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Maps a line stream into a series of C (and C preprocessor) tokens
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1993, 1999, 2008 Free Software Foundation, Inc.
| Written by Steve Byrne.
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


StreamWrapper subclass: #LineTokenStream
       instanceVariableNames: 'lineStream lookahead '
       classVariableNames: 'LexMethods LexExtra ReservedIds COperatorDict'
       poolDictionaries: 'CKeywords CToks'
       category: nil
!

LineTokenStream comment:
'I expect to read from a Stream of lines, and tokenize the characters that I 
find there.  I yield individual tokens via my #next method or, via #nextLine,
collections of tokens which correspond to those input lines' !


!LineTokenStream class methodsFor: 'initialization'!

initialize
    LexMethods _ Array new: 128.
    LexExtra _ Array new: 128.
    LexMethods atAllPut: #ignoreTok:.
    LexMethods at: (Character tab asciiValue) put: #whiteTok:.
    LexMethods at: (Character nl asciiValue) put: #whiteTok:.
    LexMethods at: (Character newPage asciiValue) put: #whiteTok:.
    LexMethods at: (Character cr asciiValue) put: #whiteTok:.
    #(
      ($  $  #whiteTok:)
	  ($! $! #opTok:)
    	  ($" $" #stringTok:)
	  ($# $# #opTok:)
    	  ($' $' #charLitTok:)
    	  ($% $& #opTok:)
    	  ($( $( #oneCharTok: #OpenParen)
    	  ($) $) #oneCharTok: #CloseParen)
    	  ($* $- #opTok:)
    	  ($. $. #floatTok:)
    	  ($/ $/ #opTok:)
    	  ($0 $9 #numberTok:)
	  ($: $: #oneCharTok: #Colon) "may make this an operator"
    	  ($; $; #oneCharTok: #Semi)
	  ($< $> #opTok:)
	  ($? $? #oneCharTok: #Question) "may make this an operator"
	  "@ is illegal"
	  ($A $Z #idTok:)
    	  ($[ $[ #oneCharTok: #OpenBracket)
	  ($\ $\ #quoteTok:)
    	  ($] $] #oneCharTok: #CloseBracket)
    	  ($^ $^ #opTok: )
    	  ($_ $_ #idTok:)
	  ($a $z #idTok:)
	  (${ ${ #oneCharTok: #OpenBrace)
	  ($| $| #opTok:)
	  ($} $} #oneCharTok: #CloseBrace)
	  ($~ $~ #opTok:)
	  )
	do: [ :range | self initRange: range ].
    self initKeywords.

    self initCOperators.
!

initKeywords
    ReservedIds _ Dictionary new.
    self initKeywords1.
    self initKeywords2.
    self initPreprocessorKeywords
!

initKeywords1
    ReservedIds at: 'auto' put: AutoKey.
    ReservedIds at: 'break' put: BreakKey.
    ReservedIds at: 'case' put: CaseKey.
    ReservedIds at: 'char' put: CharKey.
    ReservedIds at: 'const' put: ConstKey.
    ReservedIds at: 'continue' put: ContinueKey.
    ReservedIds at: 'default' put: DefaultKey.
    ReservedIds at: 'do' put: DoKey.
    ReservedIds at: 'double' put: DoubleKey.
    ReservedIds at: 'else' put: ElseKey.
    ReservedIds at: 'enum' put: EnumKey.
    ReservedIds at: 'extern' put: ExternKey.
    ReservedIds at: 'float' put: FloatKey.
    ReservedIds at: 'for' put: ForKey.
    ReservedIds at: 'goto' put: GotoKey.
    ReservedIds at: 'if' put: IfKey.
    ReservedIds at: 'int' put: IntKey.
!

initKeywords2
    ReservedIds at: 'long' put: LongKey.
    ReservedIds at: 'register' put: RegisterKey.
    ReservedIds at: 'return' put: ReturnKey.
    ReservedIds at: 'short' put: ShortKey.
    ReservedIds at: 'signed' put: SignedKey.
    ReservedIds at: 'sizeof' put: SizeofKey.
    ReservedIds at: 'static' put: StaticKey.
    ReservedIds at: 'struct' put: StructKey.
    ReservedIds at: 'switch' put: SwitchKey.
    ReservedIds at: 'typedef' put: TypedefKey.
    ReservedIds at: 'union' put: UnionKey.
    ReservedIds at: 'unsigned' put: UnsignedKey.
    ReservedIds at: 'void' put: VoidKey.
    ReservedIds at: 'volatile' put: VolatileKey.
    ReservedIds at: 'while' put: WhileKey.
!

initPreprocessorKeywords
    ReservedIds at: 'ifdef' put: IfdefKey.
    "ReservedIds at: 'defined' put: DefinedKey."
    ReservedIds at: 'elif' put: ElifKey.
    ReservedIds at: 'endif' put: EndifKey.
    ReservedIds at: 'ifndef' put: IfndefKey.

!

initCOperators
    COperatorDict _ Dictionary new.

    #(
	  '+'
	  '-'
	  '*'
	  '&'
	  '#' 
	  '\' "only passes through tokenizer as a macro argument"
      ) do: [ :op | COperatorDict at: op put: COperatorToken ].

    #('~'
	  '!'
	  '++'
	  '--'
      ) do: [ :op | COperatorDict at: op put: CUnaryOperatorToken ].
    #(
      '.'
	  '->'
	  '/'
	  '%'
	  '^'
	  ','
	  '|'
	  '||'
	  '&&'
	  '>'
	  '<'
	  '>>'
	  '<<'
	  '>='
	  '<='
	  '=='
	  '!='
	  '='
	  '##'
	  "The assignment guys are also binary operators"
	  '*='
	  '/='
	  '+='
	  '-='
	  '>>='
	  '<<='
	  '&='
	  '^='
	  '|='
	  '%='
      ) do: [ :op | COperatorDict at: op put: CBinaryOperatorToken ].
!

initRange: aRange
    | method |
    method _ aRange at: 3.
    (aRange at: 1) asciiValue to: (aRange at: 2) asciiValue do:
	[ :ch | LexMethods at: ch put: method.
    	    	aRange size = 4 ifTrue: 
		    [ LexExtra at: ch put: (aRange at: 4) ]
		]
! !


!LineTokenStream class methodsFor: 'instance creation'!

on: aString
    ^self onStream: (ReadStream on: aString) lines
!

onStream: aStream
    ^self new setStream: aStream lines
! !



!LineTokenStream methodsFor: 'basic'!

nextLine
    | tok result |
    result _ (Array new: 5) writeStream.

    "cases:
     we start on a line boundary (we guarantee that to ourselves)
     1) empty line
     2) only blanks on the line
     3) mixed stuff on the line

     nextToken yields white-uncompressed stream of tokens.
     
     on empty line, we yield an empty collection
     on line with blanks, we yield a collection containing a single white tok
     we compress out other white tokens into a single white token
     "

    lookahead notNil
	ifTrue: [ result nextPut: lookahead. lookahead := nil ].

    "collect and return a line of tokens"
    [ lineStream atEnd ]
	whileFalse: [
	   tok := self nextToken.
	   tok isNil ifFalse: [ result nextPut: tok ] ].

    ^result contents
!

next
    | result |
    lookahead isNil ifTrue: [ self peek ].
    result := lookahead.
    lookahead := nil.
    ^result
!

atEnd
    ^self peek isNil
!

peek
    [ lookahead isNil ] whileTrue: [
      lineStream atEnd ifTrue: [
          stream atEnd ifTrue: [ ^nil ].
	  self advanceLine ].

      lookahead _ self nextToken.
    ].
    ^lookahead
! !


!LineTokenStream methodsFor: 'token parsing'!

peekChar
    | ch |
    [
	lineStream atEnd ifTrue: [ ^Character nl ].
	ch := lineStream next.
	ch = $\ and: [ lineStream atEnd ] ]
	    whileTrue: [ self advanceLine ].
    lineStream putBack: ch.
    ^ch
!

nextChar
    | ch |
    [
	lineStream atEnd ifTrue: [ self advanceLine. ^Character nl ].
	ch := lineStream next.
	ch = $\ and: [ lineStream atEnd ] ]
	    whileTrue: [ self advanceLine ].
    ^ch
!

advanceLine
    lineStream _ PushBackStream on: (ReadStream on: stream next).
!

nextToken
    | ch |
    ch _ self nextChar.
    ^self perform: (LexMethods at: ch asciiValue) with: ch.
!

ignoreTok: aChar
    '[[[ IGNORING ]]]' printNl.
    aChar printNl.
    lineStream printNl.
    lineStream do: [ :ch | ch printNl ].
    stream next printNl.
    ^CCharacterToken value: '3'
!

whiteTok: aChar
    ^nil
!

charLitTok: aChar
    "Called with aChar == '"
    | ch value |
    value _ self parseStringoid: $'.
    ^CCharacterToken value: value.
!			     

idTok: aChar
    lineStream putBack: aChar.
    ^self parseIdent
!

stringTok: aChar
    | value |
    value _ self parseStringoid: $".
    ^CStringToken value: value

!

parseStringoid: delimitingChar
    | bs ch quoted |

    bs := WriteStream on: (String new: 10).
    [ ch := self nextChar.
      ch = delimitingChar ] whileFalse: [
      
      bs nextPut: ch.
      ch == $\ ifTrue: [
	  ch := self peekChar.
	  ch isNil ifFalse: [
	      self nextChar. "gobble the quoted guy"
	      bs nextPut: ch
	  ]
      ]
    ].
    ^bs contents 
!

oneCharTok: aChar
    ^CToks at: ((LexExtra at: (aChar asciiValue)), 'Tok') asSymbol
!

floatTok: aChar
    "got '.', either have a floating point number, or a structure member"
    | ch | 
    ch _ self peekChar.
    (self isDigit: ch base: 10) 
	ifTrue: [ "### revisit this "
		  ^CFloatToken value: (self parseFrac: 0.0) ].
    ch == $.			"seen .., could be ...?"
	ifFalse: [ ^DotTok ].
    self nextChar.		"eat it"
    ch _ self peekChar.
    ch == $.			"do we have '...'?"
	ifTrue: [ ^DotDotDotTok ].
	
    "nope, false alarm.  put things back the way they were."
    lineStream putBack: ch.
    lineStream putBack: $. .

    ^DotTok
!

"
unary operators
& ~ ! * - + ++ -- 

pure unary operators
~ ! ++ -- 

doubled operators
+-<>|&#=

binary operators 
-> . % ^ , + - * / & | == != >> << > < <= >= = 


assignment ops
*/%+->><<&^|
"


opTok: aChar
    | bs ch cont opStr |
    ch _ self peekChar.

    (aChar == $/ and: [ ch == $* ])
	ifTrue: [ ^self parseComment ].

    bs _ WriteStream on: (String new: 2).
    bs nextPut: aChar.
    self handleNormalOperators: bs firstChar: aChar secondChar: ch.
    "should be allowed to peek more than once, shouldn't I?"
    ch _ self peekChar.
    opStr _ bs contents.
    ch == $=
	ifTrue: [ (self isAssignable: opStr) 
		      ifTrue: [ "gobble assignment operator"
				bs nextPut: self nextChar.
				opStr _ bs contents ].
		  ].
    
    "now look up the operator and return "
   COperatorDict at: bs contents
		 ifAbsent: [ 'could not find' print. bs contents printNl ].
    ^(COperatorDict at: bs contents) value: opStr.
!


handleNormalOperators: bs firstChar: aChar secondChar: ch
    (self isDoublable: aChar)
	ifTrue: [ ch == aChar
		      ifTrue: [ self nextChar.
				^bs nextPut: aChar ] ].
    self handleTwoCharCases: bs firstChar: aChar secondChar: ch. 
!


isDoublable: aChar
    ^'+-<>|&#=' includes: aChar
!

handleTwoCharCases: bs firstChar: aChar secondChar: ch 
    (aChar == $- and: [ ch == $> ]) ifTrue: [ ^bs nextPut: self nextChar ].
    (aChar == $> and: [ ch == $= ]) ifTrue: [ ^bs nextPut: self nextChar ].
    (aChar == $< and: [ ch == $= ]) ifTrue: [ ^bs nextPut: self nextChar ].
    (aChar == $! and: [ ch == $= ]) ifTrue: [ ^bs nextPut: self nextChar ].
!

isAssignable: opStr
    ^#('*' '/' '+' '-' '>>' '<<' '&' '^' '|' '%') includes: opStr
!

numberTok: aChar
    | mantissaParsed isNegative dotSeen base exponent scale ch num 
      floatExponent |
    mantissaParsed _ isNegative _ dotSeen _ false.
    
    "note: no sign handling here"

    "integers are:
	  <digits>
	  0<octal_digits>
	  0x<hex_digits either case>
	  0X<hex_digits either case>
	  <whatever>[uUlL]
	  <whatever>[uUlL][uUlL]"
    "float are:
	  <mant_digits>.<frac_digits>e<sign><exponent><suffix>
	  mant_digits or frac_digits can be missing, but not both.
	  '.' or 'e' can be missing, but not both.
	  suffix is either empty or [lLfF]"
	  

    "first char:
       if 0, is next char x or X?
	    if so, parse remainder as hex integer and return
	    else parse remainder as octal integer and return
       assume integer.  parse some digits
       stopped at e or E?
	   if so, parse exponent and possible suffix and return
       stopped at .?
	   if so, know its a float. do the parseFrac thing as above

	   parseFrac: needs the accumulated decimal value
	      starts at char after .
	      parses digits
	      stopped at e or E?
		  if so, parse exponent and return
	      stopped at lLFf?
		  discard it, compute value and return

	   parseExponent mant_part, frac_part
	      start after e
		  is char -?
		     accumulate sign and keep going
		  parse decimal digits
		  stopped at lLfF?
		     discard it, compute value and return
	    "
		
	 
    ch _ aChar.
    lineStream putBack: ch.
    ch == $0 
	ifTrue: 
	     [ self nextChar. "gobble char"
	       lineStream atEnd
		   ifTrue: [ ^CIntegerToken value: 0 ].

	       ch _ self peekChar.
	       (ch == $x) | (ch == $X)
		   ifTrue: [ self nextChar.
			     ^self parseHexConstant ].
	       (self isDigit: ch base: 8)
		   ifTrue: [ ^self parseOctalConstant ].
	       "restore the flow"
	       ch _ aChar.
	       lineStream putBack: aChar ].
    
    
    
    num _ self parseDigits: ch base: 10.
    ch _ self peekChar.
    ch == $.
	ifTrue: [ self nextChar. "gobble '.'"
		  ^CFloatToken value: (self parseFrac: num) ].
		  
    (ch == $e) | (ch == $E)
	ifTrue: [ self nextChar. "gobble 'e'"
		  ^CFloatToken value: (self parseExponent: num) ].
					 
    "must have been an integer"
	     
    self gobbleIntegerSuffix.


    ^CIntegerToken value: num truncated.
! !




!LineTokenStream methodsFor: 'utility methods'!

parseComment
    "Scanner is at /*<> ... "
    | ch ch2 |
    ch _ self nextChar.
      
    [ ch isNil ifTrue: [ ^nil ].
      ch2 _ self nextChar.
      (ch == $* and: [ ch2 == $/ ]) ifTrue: [ ^nil ].
      ch _ ch2.
    ] repeat.
!

isSpecial: ch
    ^'%&*+,-/<=>?@\|~' includes: ch
! 

parseHexConstant
    "scanner at 0x<>..."
    | num ch |
    ch _ self peekChar.
    num _ self parseDigits: ch base: 16.
    self gobbleIntegerSuffix.
    ^CIntegerToken value: num truncated.
!


parseOctalConstant
    "scanner at 0<>..."
    | num ch |
    ch _ self peekChar.
    num _ self parseDigits: ch base: 8.
    self gobbleIntegerSuffix.
    ^CIntegerToken value: num truncated.
!

gobbleIntegerSuffix
    | ch |
    "scanner at <digits><>...  may be [luLU][luLU]"
    ch _ self peekChar.
    (ch == $l) | (ch == $L) | (ch == $U) | (ch == $u)
	ifTrue: [ self nextChar.  "ignore it"
		  ch _ self peekChar.
		  (ch == $l) | (ch == $L) | (ch == $U) | (ch == $u)
		      ifTrue: [ self nextChar.  "ignore it" ].
		  ].
    
!


parseFrac: aNumber
    "Scanner at ';;;;.<>;;;'"
    | ch scale num |

    num _ aNumber.
    scale _ 1.0.
    [ ch _ self peekChar. self isDigit: ch base: 10 ] whileTrue:
	[ num _ num * 10.0 + ch digitValue.
	  self nextChar. 
	  scale _ scale / 10.0 .
	  ].

    num _ num * scale.

    (ch == $e) | (ch == $E)
	ifTrue: 
	    [ self nextChar.	"gobble the 'e' "
	      num _ self parseExponent: num ]
	ifFalse: 
	    [ self gobbleFloatSuffix ].
    ^num
!

parseExponent: aNumber
    "scanner at ....e<>..."
    | ch isNegative exponent | 
    
    ch _ self peekChar.
    ch == $-
	ifTrue: [ self nextChar.	"gobble it"
		  isNegative _ true. ]
	ifFalse: [ isNegative _ false. ].
    
    exponent _ self parseDigits: ch base: 10.
    self gobbleFloatSuffix.
    ^aNumber raisedToInteger: (exponent truncated)
!

gobbleFloatSuffix
    | ch |
    ch _ self peekChar.
    (ch == $f) | (ch == $F) | (ch == $l) | (ch == $L)
	ifTrue: [ self nextChar. ]
! 

parseDigits: ch base: base
    | c num |
    "assumes ch is peeked"
    c _ ch.
    num _ 0.0.			"accumulate FP in case we're really getting FP"
    [ c notNil and: [ self isDigit: c base: base ] ] whileTrue:
	[ num _ num * base + c asUppercase digitValue.
	  self nextChar. 
	  c _ self peekChar ].
    ^num
!


isDigit: aChar base: base
    ^aChar class == Character
	and: [ 
	       ((aChar between: $0 and: $9)
		    | (aChar between: $A and: $F) 
		    | (aChar between: $a and: $f) )
		   and: [ aChar asUppercase digitValue < base ] ]
! !



!LineTokenStream methodsFor: 'stream stack hacking'!

pushStream: aStream
    "Del-e-ga-tion 
       -- a Milton Bradley game"
    stream pushStream: aStream
! !


!LineTokenStream methodsFor: 'private'!

parseIdent
    | s ch id reservedId |
    s _ WriteStream on: (String new: 1).
    [ lineStream atEnd not
	  and: [ ch _ self peekChar.
		 ch isLetter or: [ ch isDigit or: [ ch == $_ ] ] ] ]
	whileTrue: [ s nextPut: ch.
		     self nextChar ].
    id _ s contents.
    reservedId _ self isReserved: id.
    reservedId notNil
	ifTrue: [ ^reservedId ]
	ifFalse: [ ^CIdentifierToken value: id ]
! 

isReserved: aString
    ^ReservedIds at: aString ifAbsent: [ nil ]
! !


!LineTokenStream methodsFor: 'private'!

setStream: aStream
    super init: aStream.
    self advanceLine
! !



LineTokenStream initialize!


"
| s str |
 
     s _ FileStream open: '/usr/openwin/include/X11/Xlib.h' mode: 'r'.
     s _ LineTokenStream onStream: s.
    s printNl.
    s do: [ :line | line printNl. ].
!

     s _ FileStream open: 'xl.h' mode: 'r'.

"
PK
     �Mh@�䩆�
  �
            ��    StreamStack.stUT cqXOux �  �  PK
     �Mh@?`J�g  g            ���
  CPStrConc.stUT cqXOux �  �  PK
     �Mh@[{h�M  �M            ���  CPP.stUT cqXOux �  �  PK
     �Mh@K�B�  �            ���`  CPStrUnq.stUT cqXOux �  �  PK
     �Mh@�f"#  "#  	          ���p  CToken.stUT cqXOux �  �  PK
     �Zh@i5(vw  w            ���  package.xmlUT ��XOux �  �  PK    �Mh@=m��   J           ��˖  READMEUT cqXOux �  �  PK
     �Mh@	���x  �x            ���  CParseType.stUT cqXOux �  �  PK
     �Mh@�]�'F  F            �� PushBackStream.stUT cqXOux �  �  PK
     �Mh@���F�  �            ��� CSymbolTable.stUT cqXOux �  �  PK
     �Mh@�C˰"  �"            ��p) CExpressionNode.stUT cqXOux �  �  PK
     �Mh@�;              ��lL ExpansionStreamStack.stUT cqXOux �  �  PK
     �Mh@�A  A  
          ���S CSymbol.stUT cqXOux �  �  PK    �Mh@�\{   �   	         ��So ChangeLogUT cqXOux �  �  PK
     �Mh@�]�>=  =            ��p StreamWrapper.stUT cqXOux �  �  PK
     �Mh@���<W>  W>            ���w CDeclNode.stUT cqXOux �  �  PK
     �Mh@v�\H�   �             ��5� CParseExpr.stUT cqXOux �  �  PK
     �Mh@K� �B  B            ��J� LineTokenStream.stUT cqXOux �  �  PK      �  �   