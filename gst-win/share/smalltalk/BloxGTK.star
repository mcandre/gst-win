PK
     �Mh@��#�@, @,   BloxWidgets.stUT	 cqXO�XOux �  �  "======================================================================
|
|   Smalltalk Tk-based GUI building blocks (basic widget classes).
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini and Robert Collins.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



BPrimitive subclass: BEdit [
    | callback |
    
    <comment: 'I am a widget showing one line of modifiable text.'>
    <category: 'Graphics-Windows'>

    Initialized := nil.

    BEdit class >> new: parent contents: aString [
	"Answer a new BEdit widget laid inside the given parent widget,
	 with a default content of aString"

	<category: 'instance creation'>
	^(self new: parent)
	    contents: aString;
	    yourself
    ]

    BEdit class >> initializeOnStartup [
	<category: 'private'>
	Initialized := false
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #background ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -background'
	    with: self connected
	    with: self container.
	^self properties at: #background put: self tclResult
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -background %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #background put: value
    ]

    callback [
	"Answer a DirectedMessage that is sent when the receiver is modified,
	 or nil if none has been set up."

	<category: 'accessing'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the receiver is modified.
	 If the method accepts an argument, the receiver is passed."

	<category: 'accessing'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := Array with: self].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    contents [
	"Return the contents of the widget"

	<category: 'accessing'>
	self tclEval: 'return ${var' , self connected , '}'.
	^self tclResult
    ]

    contents: newText [
	"Set the contents of the widget"

	<category: 'accessing'>
	self tclEval: 'set var' , self connected , ' ' , newText asTkString
    ]

    font [
	"Answer the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	self properties at: #font ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -font'
	    with: self connected
	    with: self container.
	^self properties at: #font put: self tclResult
    ]

    font: value [
	"Set the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -font %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #font put: value
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #foreground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -foreground'
	    with: self connected
	    with: self container.
	^self properties at: #foreground put: self tclResult
    ]

    foregroundColor: value [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -foreground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #foreground put: value
    ]

    selectBackground [
	"Answer the value of the selectBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self properties at: #selectbackground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -selectbackground'
	    with: self connected
	    with: self container.
	^self properties at: #selectbackground put: self tclResult
    ]

    selectBackground: value [
	"Set the value of the selectBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -selectbackground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #selectbackground put: value
    ]

    selectForeground [
	"Answer the value of the selectForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self properties at: #selectforeground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -selectforeground'
	    with: self connected
	    with: self container.
	^self properties at: #selectforeground put: self tclResult
    ]

    selectForeground: value [
	"Set the value of the selectForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -selectforeground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #selectforeground put: value
    ]

    create [
	"Private - Set up the widget and Tcl hooks to get callbacks from
	 it."

	<category: 'private'>
	self create: ' -width 0'.
	Initialized ifFalse: [self defineCallbackProcedure].
	self 
	    tclEval: '
	set var%1 {}
	bind %1 <<Changed>> {callback %2 invokeCallback}
	trace variable var%1 w doEditCallback
	%1 configure -textvariable var%1 -highlightthickness 0 -takefocus 1'
	    with: self connected
	    with: self asOop printString
    ]

    defineCallbackProcedure [
	"Private - Set up a Tcl hook to generate Changed events for entry widgets"

	<category: 'private'>
	Initialized := true.
	self 
	    tclEval: '
      proc doEditCallback { name el op } {
	regsub ^var $name {} widgetName
	event generate $widgetName <<Changed>>
      }'
    ]

    setInitialSize [
	"Make the Tk placer's status, the receiver's properties and the
	 window status (as returned by winfo) consistent. Occupy the
	 height indicated by the widget itself and the whole of the
	 parent's width, at the top left corner"

	<category: 'private'>
	self
	    x: 0 y: 0;
	    width: self parent width
    ]

    widgetType [
	<category: 'private'>
	^'entry'
    ]

    destroyed [
	"Private - The receiver has been destroyed, clear the corresponding
	 Tcl variable to avoid memory leaks."

	<category: 'widget protocol'>
	self tclEval: 'unset var' , self connected.
	super destroyed
    ]

    hasSelection [
	"Answer whether there is selected text in the widget"

	<category: 'widget protocol'>
	self tclEval: self connected , ' selection present'.
	^self tclResult = '1'
    ]

    insertAtEnd: aString [
	"Clear the selection and append aString at the end of the
	 widget."

	<category: 'widget protocol'>
	self 
	    tclEval: '%1 selection clear
	%1 insert end %2
	%1 see end'
	    with: self connected
	    with: aString asTkString
    ]

    insertText: aString [
	"Insert aString in the widget at the current insertion point,
	 replacing the currently selected text (if any)."

	<category: 'widget protocol'>
	self 
	    tclEval: 'catch { %1 delete sel.first sel.last }
	%1 insert insert %2
	%1 see insert'
	    with: self connected
	    with: aString asTkString
    ]

    invokeCallback [
	"Generate a synthetic callback."

	<category: 'widget protocol'>
	self callback isNil ifFalse: [self callback send]
    ]

    nextPut: aCharacter [
	"Clear the selection and append aCharacter at the end of the
	 widget."

	<category: 'widget protocol'>
	self insertAtEnd: (String with: aCharacter)
    ]

    nextPutAll: aString [
	"Clear the selection and append aString at the end of the
	 widget."

	<category: 'widget protocol'>
	self insertAtEnd: aString
    ]

    nl [
	"Clear the selection and append a linefeed character at the
	 end of the widget."

	<category: 'widget protocol'>
	self insertAtEnd: Character nl asString
    ]

    replaceSelection: aString [
	"Insert aString in the widget at the current insertion point,
	 replacing the currently selected text (if any), and leaving
	 the text selected."

	<category: 'widget protocol'>
	self 
	    tclEval: 'catch {
	  %1 icursor sel.first
	  %1 delete sel.first sel.last
	}
	%1 insert insert %2
	%1 select insert [expr %3 + [%1 index insert]]
	%1 see insert'
	    with: self connected
	    with: aString asTkString
	    with: aString size printString
    ]

    selectAll [
	"Select the whole contents of the widget."

	<category: 'widget protocol'>
	self tclEval: self connected , ' selection range 0 end'
    ]

    selectFrom: first to: last [
	"Sets the selection to include the characters starting with the one
	 indexed by first (the very first character in the widget having
	 index 1) and ending with the one just before last.  If last
	 refers to the same character as first or an earlier one, then the
	 widget's selection is cleared."

	<category: 'widget protocol'>
	self 
	    tclEval: '%1 selection range %2 %3'
	    with: self connected
	    with: (first - 1) printString
	    with: (last - 1) printString
    ]

    selection [
	"Answer an empty string if the widget has no selection, else answer
	 the currently selected text"

	<category: 'widget protocol'>
	| stream first |
	self 
	    tclEval: 'if [%1 selection present] {
	   return [string range ${var%1} [%1 index sel.first] [%1 index sel.last]]"
	 }'
	    with: self connected.
	^self tclResult
    ]

    selectionRange [
	"Answer nil if the widget has no selection, else answer
	 an Interval object whose first item is the index of the
	 first character in the selection, and whose last item is the
	 index of the character just after the last one in the
	 selection."

	<category: 'widget protocol'>
	| stream first |
	self 
	    tclEval: 'if [%1 selection present] {
	   return "[%1 index sel.first] [%1 index sel.last]"
	 }'
	    with: self connected.
	stream := ReadStream on: self tclResult.
	stream atEnd ifTrue: [^nil].
	first := (stream upTo: $ ) asInteger + 1.
	^first to: stream upToEnd asInteger + 1
    ]

    space [
	"Clear the selection and append a space at the end of the
	 widget."

	<category: 'widget protocol'>
	self insertAtEnd: ' '
    ]
]



BPrimitive subclass: BLabel [
    
    <comment: 'I am a label showing static text.'>
    <category: 'Graphics-Windows'>

    AnchorPoints := nil.

    BLabel class >> initialize [
	"Private - Initialize the receiver's class variables."

	<category: 'initialization'>
	(AnchorPoints := IdentityDictionary new: 15)
	    at: #topLeft put: 'nw';
	    at: #topCenter put: 'n';
	    at: #topRight put: 'ne';
	    at: #leftCenter put: 'w';
	    at: #center put: 'center';
	    at: #rightCenter put: 'e';
	    at: #bottomLeft put: 'sw';
	    at: #bottomCenter put: 's';
	    at: #bottomRight put: 'se'
    ]

    BLabel class >> new: parent label: label [
	"Answer a new BLabel widget laid inside the given parent widget,
	 showing by default the `label' String."

	<category: 'instance creation'>
	^(self new: parent)
	    label: label;
	    yourself
    ]

    alignment [
	"Answer the value of the anchor option for the widget.
	 
	 Specifies how the information in a widget (e.g. text or a bitmap) is to be
	 displayed in the widget. Must be one of the symbols #topLeft, #topCenter,
	 #topRight, #leftCenter, #center, #rightCenter, #bottomLeft, #bottomCenter,
	 #bottomRight. For example, #topLeft means display the information such that
	 its top-left corner is at the top-left corner of the widget."

	<category: 'accessing'>
	^self properties at: #alignment ifAbsent: [#topLeft]
    ]

    alignment: aSymbol [
	"Set the value of the anchor option for the widget.
	 
	 Specifies how the information in a widget (e.g. text or a bitmap) is to be
	 displayed in the widget. Must be one of the symbols #topLeft, #topCenter,
	 #topRight, #leftCenter, #center, #rightCenter, #bottomLeft, #bottomCenter,
	 #bottomRight. For example, #topLeft means display the information such that
	 its top-left corner is at the top-left corner of the widget."

	<category: 'accessing'>
	self anchor: (AnchorPoints at: aSymbol).
	self properties at: #alignment put: aSymbol
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #background ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -background'
	    with: self connected
	    with: self container.
	^self properties at: #background put: self tclResult
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -background %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #background put: value
    ]

    font [
	"Answer the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	self properties at: #font ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -font'
	    with: self connected
	    with: self container.
	^self properties at: #font put: self tclResult
    ]

    font: value [
	"Set the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -font %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #font put: value
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #foreground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -foreground'
	    with: self connected
	    with: self container.
	^self properties at: #foreground put: self tclResult
    ]

    foregroundColor: value [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -foreground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #foreground put: value
    ]

    label [
	"Answer the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	self properties at: #text ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -text'
	    with: self connected
	    with: self container.
	^self properties at: #text put: self tclResult
    ]

    label: value [
	"Set the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -text %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #text put: value
    ]

    anchor: value [
	"Private - Set the value of the Tk anchor option for the widget."

	<category: 'private'>
	self 
	    tclEval: '%1 configure -anchor %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #anchor put: value
    ]

    create [
	<category: 'private'>
	self create: '-anchor nw -takefocus 0'.
	self tclEval: 'bind %1 <Configure> "+%1 configure -wraplength %%w"'
	    with: self connected
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: parentWidget.
	parentWidget isNil 
	    ifFalse: [self backgroundColor: parentWidget backgroundColor]
    ]

    setInitialSize [
	"Make the Tk placer's status, the receiver's properties and the
	 window status (as returned by winfo) consistent. Occupy the
	 area indicated by the widget itself, at the top left corner"

	<category: 'private'>
	self x: 0 y: 0
    ]

    widgetType [
	<category: 'private'>
	^'label'
    ]
]



BPrimitive subclass: BButton [
    | callback |
    
    <comment: 'I am a button that a user can click. In fact I am at the head
of a small hierarchy of objects which exhibit button-like look
and behavior'>
    <category: 'Graphics-Windows'>

    BButton class >> new: parent label: label [
	"Answer a new BButton widget laid inside the given parent widget,
	 showing by default the `label' String."

	<category: 'instance creation'>
	^(self new: parent)
	    label: label;
	    yourself
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #background ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -background'
	    with: self connected
	    with: self container.
	^self properties at: #background put: self tclResult
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -background %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #background put: value
    ]

    callback [
	"Answer a DirectedMessage that is sent when the receiver is clicked,
	 or nil if none has been set up."

	<category: 'accessing'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the receiver is clicked.
	 If the method accepts an argument, the receiver is passed."

	<category: 'accessing'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := Array with: self].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    font [
	"Answer the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	self properties at: #font ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -font'
	    with: self connected
	    with: self container.
	^self properties at: #font put: self tclResult
    ]

    font: value [
	"Set the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	"self tclEval: '%1 configure -font %3'
	 with: self connected
	 with: self container
	 with: (value  asTkString).
	 self properties at: #font put: value"

	<category: 'accessing'>
	
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #foreground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -foreground'
	    with: self connected
	    with: self container.
	^self properties at: #foreground put: self tclResult
    ]

    foregroundColor: value [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -foreground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #foreground put: value
    ]

    invokeCallback [
	"Generate a synthetic callback"

	<category: 'accessing'>
	self callback isNil ifFalse: [self callback send]
    ]

    label [
	"Answer the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	^self connected getLabel
    ]

    label: value [
	"Set the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	self connected setLabel: value
    ]

    create [
	<category: 'private'>
	self connected: GTK.GtkButton new.
	self connected 
	    connectSignal: 'clicked'
	    to: self
	    selector: #onClicked:data:
	    userData: nil
    ]

    onClicked: aButton data: userData [
	<category: 'private'>
	self invokeCallback
    ]

    setInitialSize [
	"Make the Tk placer's status, the receiver's properties and the
	 window status (as returned by winfo) consistent. Occupy the
	 area indicated by the widget itself, at the top left corner"

	<category: 'private'>
	
    ]
]



BPrimitive subclass: BForm [
    
    <comment: 'I am used to group many widgets together.'>
    <category: 'Graphics-Windows'>

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	| style |
	style := self container getStyle.
	'FIXME ok, backGroundColor isn"t trivial to get' printNl
	"self properties at: #background ifPresent: [ :value | ^value ].
	 self tclEval: '%1 cget -background'
	 with: self connected
	 with: self container.
	 ^self properties at: #background put: (self tclResult )"
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	| color |
	value printNl.
	'fixme implement bg color, will need CStruct Color' printNl
	"color:=GTK.GdkColor new.
	 GTK.GdkColor parse: value color: color.
	 self container modifyBg: GTK.Gtk gtkStateNormal color: (nil)"
    ]

    defaultHeight [
	"Answer the value of the defaultHeight option for the widget.
	 
	 Specifies the desired height for the form in pixels. If this option
	 is less than or equal to zero then the window will not request any size at all."

	<category: 'accessing'>
	self properties at: #height ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -height'
	    with: self connected
	    with: self container.
	^self properties at: #height put: self tclResult asNumber
    ]

    defaultHeight: value [
	"Set the value of the defaultHeight option for the widget.
	 
	 Specifies the desired height for the form in pixels. If this option
	 is less than or equal to zero then the window will not request any size at all."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -height %3'
	    with: self connected
	    with: self container
	    with: value printString asTkString.
	self properties at: #height put: value
    ]

    defaultWidth [
	"Answer the value of the defaultWidth option for the widget.
	 
	 Specifies the desired width for the form in pixels. If this option
	 is less than or equal to zero then the window will not request any size at all."

	<category: 'accessing'>
	self properties at: #width ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -width'
	    with: self connected
	    with: self container.
	^self properties at: #width put: self tclResult asNumber
    ]

    defaultWidth: value [
	"Set the value of the defaultWidth option for the widget.
	 
	 Specifies the desired width for the form in pixels. If this option
	 is less than or equal to zero then the window will not request any size at all."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -width %3'
	    with: self connected
	    with: self container
	    with: value printString asTkString.
	self properties at: #width put: value
    ]

    create [
	<category: 'private'>
	self connected: GTK.GtkPlacer new
    ]

    addChild: child [
	<category: 'private'>
	(self connected)
	    add: child container;
	    moveRel: child container
		relX: 0
		relY: 0.
	^child
    ]

    child: child height: value [
	"Set the given child's height to value.  The default implementation of
	 this method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #height method.  You should not use this
	 method, which is automatically called by the child's #height: method,
	 but you might want to override it.  The child's property slots whose
	 name ends with `Geom' are reserved for this method. This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just do nothing."

	<category: 'geometry'>
	| relative heightParent |
	heightParent := self height.
	heightParent <= 0 ifTrue: [^self].
	relative := value * 32767 // heightParent.
	relative := relative min: 32767.
	relative := relative max: 0.
	self connected 
	    resizeRel: child container
	    relWidth: (child properties at: #widthGeom ifAbsent: [32767])
	    relHeight: (child properties at: #heightGeom put: relative)
    ]

    child: child heightOffset: value [
	"Adjust the given child's height by a fixed amount of value pixel.  This
	 is meaningful for the default implementation, using `rubber-sheet'
	 geometry management as explained in the comment to BWidget's #height and
	 #heightOffset: methods.  You should not use this method, which is
	 automatically called by the child's #heightOffset: method, but you
	 might want to override it.  if it doesn't apply to the kind of
	 geometry management that the receiver does, just add value to the
	 current height of the widget."

	<category: 'geometry'>
	self connected 
	    resize: child container
	    width: (child properties at: #widthGeomOfs ifAbsent: [0])
	    height: value
    ]

    child: child inset: pixels [
	<category: 'geometry'>
	^child
	    xOffset: self xOffset + pixels;
	    yOffset: self yOffset + pixels;
	    widthOffset: self widthOffset - (pixels * 2);
	    heightOffset: self heightOffset - (pixels * 2)
    ]

    child: child stretch: aBoolean [
	"This method is only used when on the path from the receiver
	 to its toplevel there is a BContainer.  It decides whether child is
	 among the widgets that are stretched to fill the entire width of
	 the BContainer; if this has not been set for this widget, it
	 is propagated along the widget hierarchy."

	<category: 'geometry'>
	self properties at: #stretch
	    ifAbsent: 
		[self parent isNil ifTrue: [^self].
		self parent child: self stretch: aBoolean]
    ]

    child: child width: value [
	"Set the given child's width to value.  The default implementation of
	 this method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #width method.  You should not use this
	 method, which is automatically called by the child's #width: method,
	 but you might want to override it.  The child's property slots whose
	 name ends with `Geom' are reserved for this method. This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just do nothing."

	<category: 'geometry'>
	| relative widthParent |
	widthParent := self width.
	widthParent <= 0 ifTrue: [^self].
	relative := value * 32767 // widthParent.
	relative := relative min: 32767.
	relative := relative max: 0.
	self connected 
	    resizeRel: child container
	    relWidth: (child properties at: #widthGeom put: relative)
	    relHeight: (child properties at: #widthGeom ifAbsent: [32767])
    ]

    child: child widthOffset: value [
	"Adjust the given child's width by a fixed amount of value pixel.  This
	 is meaningful for the default implementation, using `rubber-sheet'
	 geometry management as explained in the comment to BWidget's #width and
	 #widthOffset: methods.  You should not use this method, which is
	 automatically called by the child's #widthOffset: method, but you
	 might want to override it.  if it doesn't apply to the kind of
	 geometry management that the receiver does, just add value to the
	 current width of the widget."

	<category: 'geometry'>
	self connected 
	    resize: child container
	    width: value
	    height: (child properties at: #widthGeomOfs ifAbsent: [0])
    ]

    child: child x: value [
	"Set the given child's x to value.  The default implementation of
	 this method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #x method.  You should not use this
	 method, which is automatically called by the child's #x: method,
	 but you might want to override it.  The child's property slots whose
	 name ends with `Geom' are reserved for this method. This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just do nothing."

	<category: 'geometry'>
	| relative widthParent |
	widthParent := self width.
	widthParent <= 0 ifTrue: [^self].
	relative := value * 32767 // widthParent.
	relative := relative min: 32767.
	relative := relative max: 0.
	self connected 
	    moveRel: child container
	    relX: (child properties at: #xGeom put: relative)
	    relY: (child properties at: #yGeom ifAbsent: [0])
    ]

    child: child xOffset: value [
	"Adjust the given child's x by a fixed amount of value pixel.  This
	 is meaningful for the default implementation, using `rubber-sheet'
	 geometry management as explained in the comment to BWidget's #x and
	 #xOffset: methods.  You should not use this method, which is
	 automatically called by the child's #xOffset: method, but you
	 might want to override it.  if it doesn't apply to the kind of
	 geometry management that the receiver does, just add value to the
	 current x of the widget."

	<category: 'geometry'>
	self connected 
	    move: child container
	    x: value
	    y: (child properties at: #yGeomOfs ifAbsent: [0])
    ]

    child: child y: value [
	"Set the given child's y to value.  The default implementation of
	 this method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #y method.  You should not use this
	 method, which is automatically called by the child's #y: method,
	 but you might want to override it.  The child's property slots whose
	 name ends with `Geom' are reserved for this method. This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just do nothing."

	<category: 'geometry'>
	| relative heightParent |
	heightParent := self height.
	heightParent <= 0 ifTrue: [^self].
	relative := value * 32767 // heightParent.
	relative := relative min: 32767.
	relative := relative max: 0.
	self connected 
	    moveRel: child container
	    relX: (child properties at: #xGeom ifAbsent: [0])
	    relY: (child properties at: #yGeom put: relative)
    ]

    child: child yOffset: value [
	"Adjust the given child's y by a fixed amount of value pixel.  This
	 is meaningful for the default implementation, using `rubber-sheet'
	 geometry management as explained in the comment to BWidget's #y and
	 #yOffset: methods.  You should not use this method, which is
	 automatically called by the child's #yOffset: method, but you
	 might want to override it.  if it doesn't apply to the kind of
	 geometry management that the receiver does, just add value to the
	 current y of the widget."

	<category: 'geometry'>
	self connected 
	    move: child container
	    x: (child properties at: #xGeomOfs ifAbsent: [0])
	    y: value
    ]

    heightChild: child [
	"Answer the given child's height.  The default implementation of this
	 method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #height method.  You should not use this
	 method, which is automatically called by the child's #height method,
	 but you might want to override.  The child's property slots whose
	 name ends with `Geom' are reserved for this method.  This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just return 0."

	<category: 'geometry'>
	^(child properties at: #heightGeom ifAbsentPut: [32767]) * self height 
	    // 32767
    ]

    widthChild: child [
	"Answer the given child's width.  The default implementation of this
	 method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #width method.  You should not use this
	 method, which is automatically called by the child's #width method,
	 but you might want to override.  The child's property slots whose
	 name ends with `Geom' are reserved for this method.  This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just return 0."

	<category: 'geometry'>
	^(child properties at: #widthGeom ifAbsentPut: [32767]) * self width 
	    // 32767
    ]

    xChild: child [
	"Answer the given child's x.  The default implementation of this
	 method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #x method.  You should not use this
	 method, which is automatically called by the child's #x method,
	 but you might want to override.  The child's property slots whose
	 name ends with `Geom' are reserved for this method.  This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just return 0."

	<category: 'geometry'>
	^(child properties at: #xGeom ifAbsentPut: [0]) * self width // 32767
    ]

    yChild: child [
	"Answer the given child's y.  The default implementation of this
	 method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #y method.  You should not use this
	 method, which is automatically called by the child's #y method,
	 but you might want to override.  The child's property slots whose
	 name ends with `Geom' are reserved for this method.  This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just return 0."

	<category: 'geometry'>
	^(child properties at: #yGeom ifAbsentPut: [0]) * self height // 32767
    ]
]



BForm subclass: BContainer [
    | verticalLayout |
    
    <comment: 'I am used to group many widgets together. I can perform simple
management by putting widgets next to each other, from left to
right or from top to bottom.'>
    <category: 'Graphics-Windows'>

    addChild: child [
	"The widget identified by child has been added to the receiver.
	 This method is public not because you can call it, but because
	 it can be useful to override it to perform some initialization on
	 the children just added. Answer the new child."

	<category: 'accessing'>
	self connected 
	    packStart: child container
	    expand: false
	    fill: false
	    padding: 0.
	^child
    ]

    setVerticalLayout: aBoolean [
	"Answer whether the container will align the widgets vertically or
	 horizontally.  Horizontal alignment means that widgets are
	 packed from left to right, while vertical alignment means that
	 widgets are packed from the top to the bottom of the widget.
	 
	 Widgets that are set to be ``stretched'' will share all the
	 space that is not allocated to non-stretched widgets.
	 
	 The layout of the widget can only be set before the first child
	 is inserted in the widget."

	<category: 'accessing'>
	children isEmpty 
	    ifFalse: [^self error: 'cannot set layout after the first child is created'].
	verticalLayout := aBoolean
    ]

    create [
	<category: 'private'>
	self verticalLayout 
	    ifTrue: [self connected: (GTK.GtkVBox new: false spacing: 0)]
	    ifFalse: [self connected: (GTK.GtkHBox new: false spacing: 0)]
    ]

    verticalLayout [
	"answer true if objects should be laid out vertically"

	<category: 'private'>
	verticalLayout isNil ifTrue: [verticalLayout := true].
	^verticalLayout
    ]

    initialize: parentWidget [
	"This is called by #new: to initialize the widget (as the name
	 says...). The default implementation calls all the other
	 methods in the `customization' protocol and some private
	 ones that take care of making the receiver's status consistent,
	 so you should usually call it instead of doing everything by
	 hand. This method is public not because you can call it, but
	 because it might be useful to override it. Always answer the
	 receiver."

	<category: 'private'>
	parent := parentWidget.
	properties := IdentityDictionary new.
	children := OrderedCollection new
    ]

    child: child height: value [
	<category: 'private'>
	(child -> value -> (self heightChild: child)) printNl.
	^child container setSizeRequest: (self widthChild: child) height: value
    ]

    child: child heightOffset: value [
	<category: 'private'>
	
    ]

    child: child inset: value [
	<category: 'private'>
	| stretch |
	stretch := child properties at: #stretchGeom ifAbsent: [false].
	self connected 
	    setChildPacking: child container
	    expand: stretch
	    fill: stretch
	    padding: (child properties at: #paddingGeom put: value)
	    packType: GTK.Gtk gtkPackStart
    ]

    child: child stretch: aBoolean [
	<category: 'private'>
	child properties at: #stretchGeom put: aBoolean.
	self connected 
	    setChildPacking: child container
	    expand: aBoolean
	    fill: aBoolean
	    padding: (child properties at: #paddingGeom ifAbsent: [0])
	    packType: GTK.Gtk gtkPackStart
    ]

    child: child width: value [
	<category: 'private'>
	^child container setSizeRequest: value height: (self heightChild: child)
    ]

    child: child widthOffset: value [
	<category: 'private'>
	
    ]

    child: child x: value [
	<category: 'private'>
	
    ]

    child: child xOffset: value [
	<category: 'private'>
	
    ]

    child: child y: value [
	<category: 'private'>
	
    ]

    child: child yOffset: value [
	<category: 'private'>
	
    ]

    heightChild: child [
	<category: 'private'>
	^child container getSizeRequest at: 2
    ]

    widthChild: child [
	<category: 'private'>
	^child container getSizeRequest at: 1
    ]

    xChild: child [
	<category: 'private'>
	^child xAbsolute
    ]

    yChild: child [
	<category: 'private'>
	^child yAbsolute
    ]
]



BContainer subclass: BRadioGroup [
    | value |
    
    <comment: 'I am used to group many mutually-exclusive radio buttons together.
In addition, just like every BContainer I can perform simple management
by putting widgets next to each other, from left to right or (which is
more useful in this particular case...) from top to bottom.'>
    <category: 'Graphics-Windows'>

    value [
	"Answer the index of the button that is currently selected,
	 1 being the first button added to the radio button group.
	 0 means that no button is selected"

	<category: 'accessing'>
	^value
    ]

    value: anInteger [
	"Force the value-th button added to the radio button group
	 to be the selected one."

	<category: 'accessing'>
	value = anInteger ifTrue: [^self].
	self childrenCount = 0 ifTrue: [^self].
	value = 0 ifFalse: [(children at: value) connected setActive: false].
	value := anInteger.
	anInteger = 0 ifFalse: [(children at: value) connected setActive: true]
    ]

    addChild: child [
	<category: 'private'>
	super addChild: child.
	child assignedValue: self childrenCount.
	self childrenCount = 1 ifTrue: [self value: 1].
	child connected 
	    connectSignal: 'toggled'
	    to: self
	    selector: #onToggle:data:
	    userData: self childrenCount.
	^child
    ]

    onToggle: widget data: userData [
	<category: 'private'>
	value := userData.
	(children at: userData) invokeCallback
    ]

    group [
	"answer the radio group my children are in"

	<category: 'private'>
	| child |
	child := children at: 1.
	^child exists ifFalse: [nil] ifTrue: [child connected getGroup]
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: parentWidget.
	value := 0
    ]
]



BButton subclass: BRadioButton [
    | assignedValue |
    
    <comment: 'I am just one in a group of mutually exclusive buttons.'>
    <category: 'Graphics-Windows'>

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a selector accepting at most two arguments) when the receiver is
	 clicked.  If the method accepts two arguments, the receiver is
	 passed as the first parameter.  If the method accepts one or two
	 arguments, true is passed as the last parameter for interoperability
	 with BToggle widgets."

	<category: 'accessing'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := #(true)].
	numArgs = 2 
	    ifTrue: 
		[arguments := 
			{self.
			true}].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    value [
	"Answer whether this widget is the selected one in its radio
	 button group."

	<category: 'accessing'>
	^self parent value = assignedValue
    ]

    value: aBoolean [
	"Answer whether this widget is the selected one in its radio
	 button group.  Setting this property to false for a group's
	 currently selected button unhighlights all the buttons in that
	 group."

	<category: 'accessing'>
	aBoolean 
	    ifTrue: 
		[self parent value: assignedValue.
		^self].

	"aBoolean is false - unhighlight everything if we're active"
	self value ifTrue: [self parent value: 0]
    ]

    assignedValue: anInteger [
	<category: 'private'>
	assignedValue := anInteger
    ]

    create [
	<category: 'private'>
	self 
	    connected: (GTK.GtkRadioButton newWithLabel: self parent group label: '')
    ]
]



BButton subclass: BToggle [
    | value |
    
    <comment: 'I represent a button whose choice can be included (by checking
me) or excluded (by leaving me unchecked).'>
    <category: 'Graphics-Windows'>

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a selector accepting at most two arguments) when the receiver is
	 clicked.  If the method accepts two arguments, the receiver is
	 passed as the first parameter.  If the method accepts one or two
	 arguments, the state of the widget (true if it is selected, false
	 if it is not) is passed as the last parameter."

	<category: 'accessing'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := {nil}].
	numArgs = 2 
	    ifTrue: 
		[arguments := 
			{self.
			nil}].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    invokeCallback [
	"Generate a synthetic callback."

	<category: 'accessing'>
	self callback isNil ifTrue: [^self].
	self callback arguments size > 0 
	    ifTrue: 
		[self callback arguments at: self callback arguments size put: self value].
	super invokeCallback
    ]

    value [
	"Answer whether the button is in a selected (checked) state."

	<category: 'accessing'>
	self tclEval: 'return ${var' , self connected , '}'.
	^self tclResult = '1'
    ]

    value: aBoolean [
	"Set whether the button is in a selected (checked) state and
	 generates a callback accordingly."

	<category: 'accessing'>
	aBoolean 
	    ifTrue: [self tclEval: 'set var' , self connected , ' 1']
	    ifFalse: [self tclEval: 'set var' , self connected , ' 0']
    ]

    variable: value [
	"Set the value of Tk's variable option for the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -variable %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #variable put: value
    ]

    initialize: parentWidget [
	<category: 'private'>
	| variable |
	super initialize: parentWidget.
	self tclEval: self connected , ' configure -anchor nw'.
	self tclEval: 'variable var' , self connected.
	self variable: 'var' , self connected.
	self backgroundColor: parentWidget backgroundColor
    ]

    widgetType [
	<category: 'private'>
	^'checkbutton'
    ]
]



BPrimitive subclass: BImage [
    
    <comment: 'I can display colorful images.'>
    <category: 'Graphics-Windows'>

    BImage class >> downArrow [
	"Answer the XPM representation of a 12x12 arrow pointing downwards."

	<category: 'arrows'>
	^'/* XPM */
static char * downarrow_xpm[] = {
/* width height ncolors chars_per_pixel */
"12 12 2 1",
/* colors */
" 	c None    m None   s None",
"o	c black   m black",
/* pixels */
"            ",
"            ",
"            ",
"            ",
"  ooooooo   ",
"   ooooo    ",
"    ooo     ",
"     o      ",
"            ",
"            ",
"            ",
"            "};
'
    ]

    BImage class >> leftArrow [
	"Answer the XPM representation of a 12x12 arrow pointing leftwards."

	<category: 'arrows'>
	^'/* XPM */
static char * leftarrow_xpm[] = {
/* width height ncolors chars_per_pixel */
"12 12 2 1",
/* colors */
" 	c None    m None   s None",
"o	c black   m black",
/* pixels */
"            ",
"            ",
"       o    ",
"      oo    ",
"     ooo    ",
"    oooo    ",
"     ooo    ",
"      oo    ",
"       o    ",
"            ",
"            ",
"            "};
'
    ]

    BImage class >> upArrow [
	"Answer the XPM representation of a 12x12 arrow pointing upwards."

	<category: 'arrows'>
	^'/* XPM */
static char * uparrow_xpm[] = {
/* width height ncolors chars_per_pixel */
"12 12 2 1",
/* colors */
" 	c None    m None   s None",
"o	c black   m black",
/* pixels */
"            ",
"            ",
"            ",
"            ",
"     o      ",
"    ooo     ",
"   ooooo    ",
"  ooooooo   ",
"            ",
"            ",
"            ",
"            "};
'
    ]

    BImage class >> rightArrow [
	"Answer the XPM representation of a 12x12 arrow pointing rightwards."

	<category: 'arrows'>
	^'/* XPM */
static char * rightarrow_xpm[] = {
/* width height ncolors chars_per_pixel */
"12 12 2 1",
/* colors */
" 	c None    m None   s None",
"o	c black   m black",
/* pixels */
"            ",
"            ",
"    o       ",
"    oo      ",
"    ooo     ",
"    oooo    ",
"    ooo     ",
"    oo      ",
"    o       ",
"            ",
"            ",
"            "};
'
    ]

    BImage class >> gnu [
	"Answer the XPM representation of a 48x48 GNU."

	<category: 'GNU'>
	^'/* XPM */
/*****************************************************************************/
/* GNU Emacs bitmap conv. to pixmap by Przemek Klosowski (przemek@nist.gov)  */
/*****************************************************************************/
static char * image_name [] = {
/* width height ncolors chars_per_pixel */
"48 48 7 1",
/* colors */
" 	s mask	c none",
"B      c blue",
"x      c black",          	    
":      c SandyBrown",  	    
"+      c SaddleBrown",
"o      c grey",		       	    
".      c white",
/* pixels */
"                                                ",
"                                   x            ",
"                                    :x          ",
"                                    :::x        ",
"                                      ::x       ",
"          x                             ::x     ",
"         x:                xxx          :::x    ",
"        x:           xxx xxx:xxx         x::x   ",
"       x::       xxxx::xxx:::::xx        x::x   ",
"      x::       x:::::::xx::::::xx       x::x   ",
"      x::      xx::::::::x:::::::xx     xx::x   ",
"     x::      xx::::::::::::::::::x    xx::xx   ",
"    x::x     xx:::::xxx:::::::xxx:xxx xx:::xx   ",
"   x:::x    xx:::::xx...xxxxxxxxxxxxxxx:::xx    ",
"   x:::x   xx::::::xx..xxx...xxxx...xxxxxxxx    ",
"   x:::x   x::::::xx.xxx.......x.x.......xxxx   ",
"   x:::xx x:::x::xx.xx..........x.xx.........x  ",
"   x::::xx::xx:::x.xx....ooooxoxoxoo.xxx.....x  ",
"   xx::::xxxx::xx.xx.xxxx.ooooooo.xxx    xxxx   ",
"    xx::::::::xx..x.xxx..ooooooooo.xx           ",
"    xxx:::::xxx..xx.xx.xx.xxx.ooooo.xx          ",
"      xxx::xx...xx.xx.BBBB..xxooooooxx          ",
"       xxxx.....xx.xxBB:BB.xxoooooooxx          ",
"        xx.....xx...x.BBBx.xxxooooooxx          ",
"       x....xxxx..xx...xxxooooooooooxx          ",
"       x..xxxxxx..x.......x..ooooooooxx         ",
"       x.x xxx.x.x.x...xxxx.oooooooooxx         ",
"        x  xxx.x.x.xx...xx..oooooooooxx         ",
"          xx.x..x.x.xx........oooooooox         ",
"         xxo.xx.x.x.x.x.......ooooooooox        ",
"         xxo..xxxx..x...x.......ooooooox        ",
"         xxoo.xx.x..xx...x.......ooo.xxx        ",
"         xxoo..x.x.x.x.x.xx.xxxxx.o.xx+xx       ",
"         xxoo..x.xx..xx.x.x.x+++xxxxx+++x       ",
"         xxooo.x..xxx.x.x.x.x+++++xxx+xxx       ",
"          xxoo.xx..x..xx.xxxx++x+++x++xxx       ",
"          xxoo..xx.xxx.xxx.xxx++xx+x++xx        ",
"           xxooo.xx.xx..xx.xxxx++x+++xxx        ",
"           xxooo.xxx.xx.xxxxxxxxx++++xxx        ",
"            xxoo...xx.xx.xxxxxx++xxxxxxx        ",
"            xxoooo..x..xxx..xxxx+++++xx         ",
"             xxoooo..x..xx..xxxx++++xx          ",
"              xxxooooox.xx.xxxxxxxxxxx          ",
"               xxxooooo..xxx    xxxxx           ",
"                xxxxooooxxxx                    ",
"                  xxxoooxxx                     ",
"                    xxxxx                       ",
"                                                "
};'
    ]

    BImage class >> exclaim [
	"Answer the XPM representation of a 32x32 exclamation mark icon."

	<category: 'icons'>
	^'/* XPM */
static char * exclaim_xpm[] = {
/* width height ncolors chars_per_pixel */
"32 32 6 1",
/* colors */
" 	c None    m None   s None",
".	c yellow  m white",
"X	c black   m black",
"x	c gray50  m black",
"o	c gray    m white",
"b	c yellow4 m black",
/* pixels */
"             bbb                ",
"            b..oX               ",
"           b....oXx             ",
"           b.....Xxx            ",
"          b......oXxx           ",
"          b.......Xxx           ",
"         b........oXxx          ",
"         b.........Xxx          ",
"        b..........oXxx         ",
"        b...oXXXo...Xxx         ",
"       b....XXXXX...oXxx        ",
"       b....XXXXX....Xxx        ",
"      b.....XXXXX....oXxx       ",
"      b.....XXXXX.....Xxx       ",
"     b......XXXXX.....oXxx      ",
"     b......bXXXb......Xxx      ",
"    b.......oXXXo......oXxx     ",
"    b........XXX........Xxx     ",
"   b.........bXb........oXxx    ",
"   b.........oXo.........Xxx    ",
"  b...........X..........oXxx   ",
"  b.......................Xxx   ",
" b...........oXXo.........oXxx  ",
" b...........XXXX..........Xxx  ",
"b............XXXX..........oXxx ",
"b............oXXo...........Xxx ",
"b...........................Xxxx",
"b..........................oXxxx",
" b........................oXxxxx",
"  bXXXXXXXXXXXXXXXXXXXXXXXXxxxxx",
"    xxxxxxxxxxxxxxxxxxxxxxxxxxx ",
"     xxxxxxxxxxxxxxxxxxxxxxxxx  "};
'
    ]

    BImage class >> info [
	"Answer the XPM representation of a 32x32 `information' icon."

	<category: 'icons'>
	^'/* XPM */
static char * info_xpm[] = {
/* width height ncolors chars_per_pixel */
"32 32 6 1",
/* colors */
" 	c None    m None   s None",
".	c white   m white",
"X	c black   m black",
"x	c gray50  m black",
"o	c gray    m white",
"b	c blue    m black",
/* pixels */
"           xxxxxxxx             ",
"        xxxo......oxxx          ",
"      xxo............oxx        ",
"     xo................ox       ",
"    x.......obbbbo.......X      ",
"   x........bbbbbb........X     ",
"  x.........bbbbbb.........X    ",
" xo.........obbbbo.........oX   ",
" x..........................Xx  ",
"xo..........................oXx ",
"x..........bbbbbbb...........Xx ",
"x............bbbbb...........Xxx",
"x............bbbbb...........Xxx",
"x............bbbbb...........Xxx",
"x............bbbbb...........Xxx",
"xo...........bbbbb..........oXxx",
" x...........bbbbb..........Xxxx",
" xo..........bbbbb.........oXxxx",
"  x........bbbbbbbbb.......Xxxx ",
"   X......................Xxxxx ",
"    X....................Xxxxx  ",
"     Xo................oXxxxx   ",
"      XXo............oXXxxxx    ",
"       xXXXo......oXXXxxxxx     ",
"        xxxXXXo...Xxxxxxxx      ",
"          xxxxX...Xxxxxx        ",
"             xX...Xxx           ",
"               X..Xxx           ",
"                X.Xxx           ",
"                 XXxx           ",
"                  xxx           ",
"                   xx           "};
'
    ]

    BImage class >> question [
	"Answer the XPM representation of a 32x32 question mark icon."

	<category: 'icons'>
	^'/* XPM */
static char * question_xpm[] = {
/* width height ncolors chars_per_pixel */
"32 32 6 1",
/* colors */
" 	c None    m None   s None",
".	c white   m white",
"X	c black   m black",
"x	c gray50  m black",
"o	c gray    m white",
"b	c blue    m black",
/* pixels */
"           xxxxxxxx             ",
"        xxxo......oxxx          ",
"      xxo............oxx        ",
"     xo................ox       ",
"    x....................X      ",
"   x.......obbbbbbo.......X     ",
"  x.......obo..bbbbo.......X    ",
" xo.......bb....bbbb.......oX   ",
" x........bbbb..bbbb........Xx  ",
"xo........bbbb.obbbb........oXx ",
"x.........obbo.bbbb..........Xx ",
"x.............obbb...........Xxx",
"x.............bbb............Xxx",
"x.............bbo............Xxx",
"x.............bb.............Xxx",
"xo..........................oXxx",
" x...........obbo...........Xxxx",
" xo..........bbbb..........oXxxx",
"  x..........bbbb..........Xxxx ",
"   X.........obbo.........Xxxxx ",
"    X....................Xxxxx  ",
"     Xo................oXxxxx   ",
"      XXo............oXXxxxx    ",
"       xXXXo......oXXXxxxxx     ",
"        xxxXXXo...Xxxxxxxx      ",
"          xxxxX...Xxxxxx        ",
"             xX...Xxx           ",
"               X..Xxx           ",
"                X.Xxx           ",
"                 XXxx           ",
"                  xxx           ",
"                   xx           "};
'
    ]

    BImage class >> stop [
	"Answer the XPM representation of a 32x32 `critical stop' icon."

	<category: 'icons'>
	^'/* XPM */
static char * stop_xpm[] = {
/* width height ncolors chars_per_pixel */
"32 32 5 1",
/* colors */
" 	c None    m None   s None",
".	c red     m white",
"o	c DarkRed m black",
"X	c white   m black",
"x	c gray50  m black",
/* pixels */
"           oooooooo             ",
"        ooo........ooo          ",
"       o..............o         ",
"     oo................oo       ",
"    o....................o      ",
"   o......................o     ",
"   o......................ox    ",
"  o......X..........X......ox   ",
" o......XXX........XXX......o   ",
" o.....XXXXX......XXXXX.....ox  ",
" o......XXXXX....XXXXX......oxx ",
"o........XXXXX..XXXXX........ox ",
"o.........XXXXXXXXXX.........ox ",
"o..........XXXXXXXX..........oxx",
"o...........XXXXXX...........oxx",
"o...........XXXXXX...........oxx",
"o..........XXXXXXXX..........oxx",
"o.........XXXXXXXXXX.........oxx",
"o........XXXXX..XXXXX........oxx",
" o......XXXXX....XXXXX......oxxx",
" o.....XXXXX......XXXXX.....oxxx",
" o......XXX........XXX......oxx ",
"  o......X..........X......oxxx ",
"   o......................oxxxx ",
"   o......................oxxx  ",
"    o....................oxxx   ",
"     oo................ooxxxx   ",
"      xo..............oxxxxx    ",
"       xooo........oooxxxxx     ",
"         xxooooooooxxxxxx       ",
"          xxxxxxxxxxxxxx        ",
"             xxxxxxxx           "};
'
    ]

    BImage class >> new: parent data: aString [
	"Answer a new BImage widget laid inside the given parent widget,
	 loading data from the given string (Base-64 encoded GIF, XPM,
	 PPM are supported)."

	<category: 'instance creation'>
	^(self new: parent)
	    data: aString;
	    yourself
    ]

    BImage class >> new: parent image: aFileStream [
	"Answer a new BImage widget laid inside the given parent widget,
	 loading data from the given file (GIF, XPM, PPM are supported)."

	<category: 'instance creation'>
	^(self new: parent)
	    image: aFileStream;
	    yourself
    ]

    BImage class >> new: parent size: aPoint [
	"Answer a new BImage widget laid inside the given parent widget,
	 showing by default a transparent image of aPoint size."

	<category: 'instance creation'>
	^(self new: parent)
	    displayWidth: aPoint x;
	    displayHeight: aPoint y;
	    blank;
	    yourself
    ]

    BImage class >> directory [
	"Answer the Base-64 GIF representation of a `directory folder' icon."

	<category: 'small icons'>
	^'R0lGODdhEAAQAPIAAAAAAHh4eLi4uPj4+P///wAAAAAAAAAAACwAAAAAEAAQAAADPkixzPOD
yADrWE8qC8WN0+BZAmBq1GMOqwigXFXCrGk/cxjjr27fLtout6n9eMIYMTXsFZsogXRKJf6u
P0kCADv/'
    ]

    BImage class >> file [
	"Answer the Base-64 GIF representation of a `file' icon."

	<category: 'small icons'>
	^'R0lGODdhEAAQAPIAAAAAAHh4eLi4uPj4APj4+P///wAAAAAAACwAAAAAEAAQAAADPVi63P4w
LkKCtTTnUsXwQqBtAfh910UU4ugGAEucpgnLNY3Gop7folwNOBOeiEYQ0acDpp6pGAFArVqt
hQQAO///'
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #background ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -background'
	    with: self connected
	    with: self container.
	^self properties at: #background put: self tclResult
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -background %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #background put: value
    ]

    displayHeight [
	"Answer the value of the displayHeight option for the widget.
	 
	 Specifies the height of the image in pixels. This is not the height of the
	 widget, but specifies the area of the widget that will be taken by the image."

	<category: 'accessing'>
	self properties at: #displayHeight ifPresent: [:value | ^value].
	self 
	    tclEval: 'img%1 cget -width'
	    with: self connected
	    with: self container.
	^self properties at: #displayHeight put: self tclResult asNumber
    ]

    displayHeight: value [
	"Set the value of the displayHeight option for the widget.
	 
	 Specifies the height of the image in pixels. This is not the height of the
	 widget, but specifies the area of the widget that will be taken by the image."

	<category: 'accessing'>
	self 
	    tclEval: 'img%1 configure -width %3'
	    with: self connected
	    with: self container
	    with: value asFloat printString asTkString.
	self properties at: #displayHeight put: value
    ]

    displayWidth [
	"Answer the value of the displayWidth option for the widget.
	 
	 Specifies the width of the image in pixels. This is not the width of the
	 widget, but specifies the area of the widget that will be taken by the image."

	<category: 'accessing'>
	self properties at: #displayWidth ifPresent: [:value | ^value].
	self 
	    tclEval: 'img%1 cget -width'
	    with: self connected
	    with: self container.
	^self properties at: #displayWidth put: self tclResult asNumber
    ]

    displayWidth: value [
	"Set the value of the displayWidth option for the widget.
	 
	 Specifies the width of the image in pixels. This is not the width of the
	 widget, but specifies the area of the widget that will be taken by the image."

	<category: 'accessing'>
	self 
	    tclEval: 'img%1 configure -width %3'
	    with: self connected
	    with: self container
	    with: value asFloat printString asTkString.
	self properties at: #displayWidth put: value
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #foreground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -foreground'
	    with: self connected
	    with: self container.
	^self properties at: #foreground put: self tclResult
    ]

    foregroundColor: value [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -foreground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #foreground put: value
    ]

    gamma [
	"Answer the value of the gamma option for the widget.
	 
	 Specifies that the colors allocated for displaying the image widget
	 should be corrected for a non-linear display with the specified gamma exponent
	 value. (The intensity produced by most CRT displays is a power function
	 of the input value, to a good approximation; gamma is the exponent and
	 is typically around 2). The value specified must be greater than zero. The
	 default value is one (no correction). In general, values greater than one
	 will make the image lighter, and values less than one will make it darker."

	<category: 'accessing'>
	self properties at: #gamma ifPresent: [:value | ^value].
	self 
	    tclEval: 'img%1 cget -gamma'
	    with: self connected
	    with: self container.
	^self properties at: #gamma put: self tclResult asNumber
    ]

    gamma: value [
	"Set the value of the gamma option for the widget.
	 
	 Specifies that the colors allocated for displaying the image widget
	 should be corrected for a non-linear display with the specified gamma exponent
	 value. (The intensity produced by most CRT displays is a power function
	 of the input value, to a good approximation; gamma is the exponent and
	 is typically around 2). The value specified must be greater than zero. The
	 default value is one (no correction). In general, values greater than one
	 will make the image lighter, and values less than one will make it darker."

	<category: 'accessing'>
	self 
	    tclEval: 'img%1 configure -gamma %3'
	    with: self connected
	    with: self container
	    with: value asFloat printString asTkString.
	self properties at: #gamma put: value
    ]

    blank [
	"Blank the corresponding image"

	<category: 'image management'>
	self tclEval: 'img' , self connected , ' blank'
    ]

    data: aString [
	"Set the image to be drawn to aString, which can be a GIF
	 in Base-64 representation or an X pixelmap."

	<category: 'image management'>
	self tclEval: 'img' , self connected , ' configure -data ' 
		    , aString asTkImageString
    ]

    dither [
	"Recalculate the dithered image in the window where the
	 image is displayed.  The dithering algorithm used in
	 displaying images propagates quantization errors from
	 one pixel to its neighbors.  If the image data is supplied
	 in pieces, the dithered image may not be exactly correct.
	 Normally the difference is not noticeable, but if it is a
	 problem, this command can be used to fix it."

	<category: 'image management'>
	self tclEval: 'img' , self connected , ' redither'
    ]

    fillFrom: origin extent: extent color: color [
	"Fill a rectangle with the given origin and extent, using
	 the given color."

	<category: 'image management'>
	self 
	    fillFrom: origin
	    to: origin + extent
	    color: color
    ]

    fillFrom: origin to: corner color: color [
	"Fill a rectangle between the given corners, using
	 the given color."

	<category: 'image management'>
	self 
	    tclEval: 'img%1 put { %2 } -to %3 %4'
	    with: self connected
	    with: color
	    with: origin x printString , ' ' , origin y printString
	    with: corner x printString , ' ' , corner y printString
    ]

    fillRectangle: rectangle color: color [
	"Fill a rectangle having the given bounding box, using
	 the given color."

	<category: 'image management'>
	self 
	    fillFrom: rectangle origin
	    to: rectangle corner
	    color: color
    ]

    image: aFileStream [
	"Read a GIF or XPM image from aFileStream.  The whole contents
	 of the file are read, not only from the file position."

	<category: 'image management'>
	self 
	    tclEval: 'img' , self connected , ' read ' , aFileStream name asTkString
    ]

    imageHeight [
	"Specifies the height of the image, in pixels.  This option is useful
	 primarily in situations where you wish to build up the contents of
	 the image piece by piece.  A value of zero (the default) allows the
	 image to expand or shrink vertically to fit the data stored in it."

	<category: 'image management'>
	self tclEval: 'image height img' , self connected.
	^self tclResult asInteger
    ]

    imageWidth [
	"Specifies the width of the image, in pixels.  This option is useful
	 primarily in situations where you wish to build up the contents of
	 the image piece by piece.  A value of zero (the default) allows the
	 image to expand or shrink horizontally to fit the data stored in it."

	<category: 'image management'>
	self tclEval: 'image width img' , self connected.
	^self tclResult asInteger
    ]

    lineFrom: origin extent: extent color: color [
	"Draw a line with the given origin and extent, using
	 the given color."

	<category: 'image management'>
	self 
	    lineFrom: origin
	    to: origin + extent
	    color: color
    ]

    lineFrom: origin to: corner color: color [
	<category: 'image management'>
	self notYetImplemented
    ]

    lineFrom: origin toX: endX color: color [
	"Draw an horizontal line between the given corners, using
	 the given color."

	<category: 'image management'>
	self 
	    tclEval: 'img%1 put { %2 } -to %3 %4'
	    with: self connected
	    with: color
	    with: origin x printString , ' ' , origin y printString
	    with: endX printString , ' ' , origin y printString
    ]

    lineInside: rectangle color: color [
	"Draw a line having the given bounding box, using
	 the given color."

	<category: 'image management'>
	self 
	    lineFrom: rectangle origin
	    to: rectangle corner
	    color: color
    ]

    lineFrom: origin toY: endY color: color [
	"Draw a vertical line between the given corners, using
	 the given color."

	<category: 'image management'>
	self 
	    tclEval: 'img%1 put { %2 } -to %3 %4'
	    with: self connected
	    with: color
	    with: origin x printString , ' ' , origin y printString
	    with: origin x printString , ' ' , endY printString
    ]

    destroyed [
	"Private - The receiver has been destroyed, clear the corresponding
	 Tcl image to avoid memory leaks."

	<category: 'widget protocol'>
	'TODO' printNl.
	super destroyed
    ]

    create [
	<category: 'private'>
	self tclEval: 'image create photo img' , self connected.
	self create: '-anchor nw -image img' , self connected
    ]

    setInitialSize [
	"Make the Tk placer's status, the receiver's properties and the
	 window status (as returned by winfo) consistent. Occupy the
	 area indicated by the widget itself, at the top left corner"

	<category: 'private'>
	self x: 0 y: 0
    ]

    widgetType [
	<category: 'private'>
	^'label'
    ]
]



BViewport subclass: BList [
    | labels items callback gtkmodel connected gtkcolumn |
    
    <comment: 'I represent a list box from which you can choose one or more
elements.'>
    <category: 'Graphics-Windows'>

    add: anObject afterIndex: index [
	"Add an element with the given value after another element whose
	 index is contained in the index parameter.  The label displayed
	 in the widget is anObject's displayString.  Answer anObject."

	<category: 'accessing'>
	^self 
	    add: nil
	    element: anObject
	    afterIndex: index
    ]

    add: aString element: anObject afterIndex: index [
	"Add an element with the aString label after another element whose
	 index is contained in the index parameter.  This method allows
	 the client to decide autonomously the label that the widget will
	 display.
	 
	 If anObject is nil, then string is used as the element as well.
	 If aString is nil, then the element's displayString is used as
	 the label.
	 
	 Answer anObject or, if it is nil, aString."

	<category: 'accessing'>
	| elem label iter |
	label := aString isNil ifTrue: [anObject displayString] ifFalse: [aString].
	elem := anObject isNil ifTrue: [aString] ifFalse: [anObject].
	labels isNil 
	    ifTrue: 
		[index > 0 
		    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
		labels := OrderedCollection with: label.
		items := OrderedCollection with: elem]
	    ifFalse: 
		[labels add: label afterIndex: index.
		items add: elem afterIndex: index].
	iter := self gtkmodel insert: index.
	self gtkmodel 
	    setOop: iter
	    column: 0
	    value: label.
	^elem
    ]

    addLast: anObject [
	"Add an element with the given value at the end of the listbox.
	 The label displayed in the widget is anObject's displayString.
	 Answer anObject."

	<category: 'accessing'>
	^self 
	    add: nil
	    element: anObject
	    afterIndex: items size
    ]

    addLast: aString element: anObject [
	"Add an element with the given value at the end of the listbox.
	 This method allows the client to decide autonomously the label
	 that the widget will display.
	 
	 If anObject is nil, then string is used as the element as well.
	 If aString is nil, then the element's displayString is used as
	 the label.
	 
	 Answer anObject or, if it is nil, aString."

	<category: 'accessing'>
	^self 
	    add: aString
	    element: anObject
	    afterIndex: items size
    ]

    associationAt: anIndex [
	"Answer an association whose key is the item at the given position
	 in the listbox and whose value is the label used to display that
	 item."

	<category: 'accessing'>
	^(items at: anIndex) -> (labels at: anIndex)
    ]

    at: anIndex [
	"Answer the element displayed at the given position in the list
	 box."

	<category: 'accessing'>
	^items at: anIndex
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #background ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -background'
	    with: self connected
	    with: self container.
	^self properties at: #background put: self tclResult
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -background %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #background put: value
    ]

    contents: elementList [
	"Set the elements displayed in the listbox, and set the labels
	 to be their displayStrings."

	<category: 'accessing'>
	| newLabels |
	newLabels := elementList collect: [:each | each displayString].
	^self contents: newLabels elements: elementList
    ]

    contents: stringCollection elements: elementList [
	"Set the elements displayed in the listbox to be those in elementList,
	 and set the labels to be the corresponding elements in stringCollection.
	 The two collections must have the same size."

	<category: 'accessing'>
	| stream iter |
	(elementList notNil and: [elementList size ~= stringCollection size]) 
	    ifTrue: 
		[^self 
		    error: 'label collection must have the same size as element collection'].
	labels := stringCollection isNil 
		    ifTrue: 
			[elementList asOrderedCollection collect: [:each | each displayString]]
		    ifFalse: [stringCollection asOrderedCollection].
	items := elementList isNil 
		    ifTrue: [labels copy]
		    ifFalse: [elementList asOrderedCollection].
	self gtkmodel clear.
	iter := GTK.GtkTreeIter new.
	stringCollection do: 
		[:each | 
		self gtkmodel append: iter.
		self gtkmodel 
		    setOop: iter
		    column: 0
		    value: each]
    ]

    do: aBlock [
	"Iterate over each element of the listbox and pass it to aBlock."

	<category: 'accessing'>
	items do: aBlock
    ]

    elements [
	"Answer the collection of objects that represent the elements
	 displayed by the list box."

	<category: 'accessing'>
	^items copy
    ]

    elements: elementList [
	"Set the elements displayed in the listbox, and set the labels
	 to be their displayStrings."

	<category: 'accessing'>
	| newLabels |
	newLabels := elementList collect: [:each | each displayString].
	^self contents: newLabels elements: elementList
    ]

    font [
	"Answer the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	self properties at: #font ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -font'
	    with: self connected
	    with: self container.
	^self properties at: #font put: self tclResult
    ]

    font: value [
	"Set the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -font %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #font put: value
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #foreground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -foreground'
	    with: self connected
	    with: self container.
	^self properties at: #foreground put: self tclResult
    ]

    foregroundColor: value [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -foreground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #foreground put: value
    ]

    highlightBackground [
	"Answer the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the widget."

	<category: 'accessing'>
	self properties at: #selectbackground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -selectbackground'
	    with: self connected
	    with: self container.
	^self properties at: #selectbackground put: self tclResult
    ]

    highlightBackground: value [
	"Set the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -selectbackground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #selectbackground put: value
    ]

    highlightForeground [
	"Answer the value of the highlightForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected items
	 in the widget."

	<category: 'accessing'>
	self properties at: #selectforeground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -selectforeground'
	    with: self connected
	    with: self container.
	^self properties at: #selectforeground put: self tclResult
    ]

    highlightForeground: value [
	"Set the value of the highlightForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected items
	 in the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -selectforeground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #selectforeground put: value
    ]

    index [
	"Answer the value of the index option for the widget.
	 
	 Indicates the element that has the location cursor. This item will be
	 displayed in the highlightForeground color, and with the corresponding
	 background color."

	<category: 'accessing'>
	^self properties at: #index
	    ifAbsentPut: 
		[| iter |
		(iter := self connected getSelection getSelected) isNil 
		    ifTrue: [nil]
		    ifFalse: [(self gtkmodel getStringFromIter: iter) asInteger]]
    ]

    indexAt: point [
	"Answer the index of the element that covers the point in the
	 listbox window specified by x and y (in pixel coordinates).  If no
	 element covers that point, then the closest element to that point
	 is used."

	<category: 'accessing'>
	| pPath ok path index |
	pPath := GTK.GtkTreePath type ptrType gcNew.
	ok := self 
		    getPathAtPos: point x
		    y: point y
		    path: pPath
		    column: nil
		    cellX: nil
		    cellY: nil.
	path := pPath value.
	index := ok ifTrue: [path getIndices value] ifFalse: [self elements size].
	path free.
	^index
    ]

    isSelected: index [
	"Answer whether the element indicated by index is currently selected."

	<category: 'accessing'>
	| selected path |
	path := self pathAt: index.
	selected := self connected getSelection pathIsSelected: path.
	path free.
	^selected
    ]

    labelAt: anIndex [
	"Answer the label displayed at the given position in the list
	 box."

	<category: 'accessing'>
	^labels at: anIndex
    ]

    labels [
	"Answer the labels displayed by the list box."

	<category: 'accessing'>
	^labels copy
    ]

    labelsDo: aBlock [
	"Iterate over each listbox element's label and pass it to aBlock."

	<category: 'accessing'>
	labels do: aBlock
    ]

    mode [
	"Answer the value of the mode option for the widget.
	 
	 Specifies one of several styles for manipulating the selection. The value
	 of the option may be either single, browse, multiple, or extended.
	 
	 If the selection mode is single or browse, at most one element can be selected in
	 the listbox at once. Clicking button 1 on an unselected element selects it and
	 deselects any other selected item, while clicking on a selected element
	 has no effect. In browse mode it is also possible to drag the selection
	 with button 1. That is, moving the mouse while button 1 is pressed keeps
	 the item under the cursor selected.
	 
	 If the selection mode is multiple or extended, any number of elements may be
	 selected at once, including discontiguous ranges. In multiple mode, clicking button
	 1 on an element toggles its selection state without affecting any other elements.
	 In extended mode, pressing button 1 on an element selects it, deselects
	 everything else, and sets the anchor to the element under the mouse; dragging the
	 mouse with button 1 down extends the selection to include all the elements between
	 the anchor and the element under the mouse, inclusive.
	 
	 In extended mode, the selected range can be adjusted by pressing button 1
	 with the Shift key down: this modifies the selection to consist of the elements
	 between the anchor and the element under the mouse, inclusive. The
	 un-anchored end of this new selection can also be dragged with the button
	 down. Also in extended mode, pressing button 1 with the Control key down starts a
	 toggle operation: the anchor is set to the element under the mouse, and its
	 selection state is reversed. The selection state of other elements is not
	 changed. If the mouse is dragged with button 1 down, then the selection
	 state of all elements between the anchor and the element under the mouse is
	 set to match that of the anchor element; the selection state of all other
	 elements remains what it was before the toggle operation began.
	 
	 Most people will probably want to use browse mode for single selections and
	 extended mode for multiple selections; the other modes appear to be useful only in
	 special situations."

	<category: 'accessing'>
	| mode |
	^self properties at: #selectmode
	    ifAbsentPut: 
		[mode := self connected getSelection getMode.
		mode = GTK.Gtk gtkSelectionSingle 
		    ifTrue: [#single]
		    ifFalse: 
			[mode = GTK.Gtk gtkSelectionBrowse 
			    ifTrue: [#browse]
			    ifFalse: [mode = GTK.Gtk gtkSelectionExtended ifTrue: [#extended]]]]
    ]

    mode: value [
	"Set the value of the mode option for the widget.
	 
	 Specifies one of several styles for manipulating the selection. The value
	 of the option may be either single, browse, multiple, or extended.
	 
	 If the selection mode is single or browse, at most one element can be selected in
	 the listbox at once. Clicking button 1 on an unselected element selects it and
	 deselects any other selected item, while clicking on a selected element
	 has no effect. In browse mode it is also possible to drag the selection
	 with button 1. That is, moving the mouse while button 1 is pressed keeps
	 the item under the cursor selected.
	 
	 If the selection mode is multiple or extended, any number of elements may be
	 selected at once, including discontiguous ranges. In multiple mode, clicking button
	 1 on an element toggles its selection state without affecting any other elements.
	 In extended mode, pressing button 1 on an element selects it, deselects
	 everything else, and sets the anchor to the element under the mouse; dragging the
	 mouse with button 1 down extends the selection to include all the elements between
	 the anchor and the element under the mouse, inclusive.
	 
	 In extended mode, the selected range can be adjusted by pressing button 1
	 with the Shift key down: this modifies the selection to consist of the elements
	 between the anchor and the element under the mouse, inclusive. The
	 un-anchored end of this new selection can also be dragged with the button
	 down. Also in extended mode, pressing button 1 with the Control key down starts a
	 toggle operation: the anchor is set to the element under the mouse, and its
	 selection state is reversed. The selection state of other elements is not
	 changed. If the mouse is dragged with button 1 down, then the selection
	 state of all elements between the anchor and the element under the mouse is
	 set to match that of the anchor element; the selection state of all other
	 elements remains what it was before the toggle operation began.
	 
	 Most people will probably want to use browse mode for single selections and
	 extended mode for multiple selections; the other modes appear to be useful only in
	 special situations."

	<category: 'accessing'>
	| mode |
	value = #single 
	    ifTrue: [mode := GTK.Gtk gtkSelectionSingle]
	    ifFalse: 
		[value = #browse 
		    ifTrue: [mode := GTK.Gtk gtkSelectionBrowse]
		    ifFalse: 
			[value = #multiple 
			    ifTrue: [mode := GTK.Gtk gtkSelectionExtended]
			    ifFalse: 
				[value = #extended 
				    ifTrue: [mode := GTK.Gtk gtkSelectionExtended]
				    ifFalse: [^self error: 'invalid value for BList mode']]]].
	self connected getSelection setMode: mode.
	self properties at: #selectmode put: value
    ]

    numberOfStrings [
	"Answer the number of items in the list box"

	<category: 'accessing'>
	^labels size
    ]

    removeAtIndex: index [
	"Remove the item at the given index in the list box, answering
	 the object associated to the element (i.e. the value that #at:
	 would have returned for the given index)"

	<category: 'accessing'>
	| result |
	labels removeAtIndex: index.
	result := items removeAtIndex: index.
	self gtkmodel remove: (self iterAt: index).
	^result
    ]

    label [
	"assign a new label to the list"

	<category: 'accessing'>
	^self gtkcolumn getTitle
    ]

    label: aString [
	"assign a new label to the list"

	<category: 'accessing'>
	self gtkcolumn setTitle: aString
    ]

    size [
	"Answer the number of items in the list box"

	<category: 'accessing'>
	^labels size
    ]

    itemSelected: receiver at: index [
	<category: 'private - examples'>
	stdout
	    nextPutAll: 'List item ';
	    print: index;
	    nextPutAll: ' selected!';
	    nl.
	stdout
	    nextPutAll: 'Contents: ';
	    nextPutAll: (items at: index);
	    nl
    ]

    gtkcolumn [
	"answer the gtk column for the list"

	<category: 'private'>
	gtkcolumn isNil ifTrue: [self createWidget].
	^gtkcolumn
    ]

    gtkmodel [
	"answer the gtk list model"

	<category: 'private'>
	gtkmodel isNil ifTrue: [self createWidget].
	^gtkmodel
    ]

    onChanged: selection data: userData [
	<category: 'private'>
	| iter |
	(iter := selection getSelected) isNil 
	    ifFalse: [self invokeCallback: (self gtkmodel getStringFromIter: iter)]
    ]

    pathAt: anIndex [
	<category: 'private'>
	^GTK.GtkTreePath newFromIndices: anIndex - 1 varargs: #()
    ]

    iterAt: anIndex [
	<category: 'private'>
	^self gtkmodel iterNthChild: nil n: anIndex - 1
    ]

    create [
	<category: 'private'>
	| select renderer |
	renderer := GTK.GtkCellRendererText new.
	'phwoar... should not need the explicit calls, but something is bust in varargs passing' 
	    printNl.
	gtkcolumn := GTK.GtkTreeViewColumn new.
	gtkcolumn setTitle: 'List'.
	gtkcolumn packStart: renderer expand: true.
	gtkcolumn 
	    addAttribute: renderer
	    attribute: 'text'
	    column: 0.

	"gtkcolumn := GTK.GtkTreeViewColumn newWithAttributes: 'List' cell: renderer varargs: {'text'. 0. nil}."
	gtkmodel := GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString}.
	self connected: (GTK.GtkTreeView newWithModel: self gtkmodel).
	(self connected)
	    appendColumn: self gtkcolumn;
	    setSearchColumn: 0.
	select := self connected getSelection.
	select setMode: GTK.Gtk gtkSelectionSingle.
	select 
	    connectSignal: 'changed'
	    to: self
	    selector: #onChanged:data:
	    userData: nil
    ]

    show [
	<category: 'private'>
	super show.
	self container setShadowType: GTK.Gtk gtkShadowIn
    ]

    needsViewport [
	<category: 'private'>
	^false
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: parentWidget.
	self properties at: #index put: nil.
	labels := OrderedCollection new
    ]

    invokeCallback: indexString [
	<category: 'private'>
	| index |
	items isNil ifTrue: [^self].
	index := indexString asInteger.
	self properties at: #index put: index + 1.
	self invokeCallback
    ]

    callback [
	"Answer a DirectedMessage that is sent when the active item in
	 the receiver changes, or nil if none has been set up."

	<category: 'widget protocol'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a selector with at most two arguemtnts) when the active item in
	 the receiver changegs.  If the method accepts two arguments, the
	 receiver is  passed as the first parameter.  If the method accepts
	 one or two arguments, the selected index is passed as the last
	 parameter."

	<category: 'widget protocol'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := {nil}].
	numArgs = 2 
	    ifTrue: 
		[arguments := 
			{self.
			nil}].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    highlight: index [
	"Highlight the item at the given position in the listbox."

	<category: 'widget protocol'>
	index = self index ifTrue: [^self].
	(self mode = #single or: [self mode = #browse]) ifTrue: [self unhighlight].
	self select: index
    ]

    invokeCallback [
	"Generate a synthetic callback."

	<category: 'widget protocol'>
	self callback notNil 
	    ifTrue: 
		[self callback arguments isEmpty 
		    ifFalse: 
			[self callback arguments at: self callback arguments size
			    put: (self properties at: #index)].
		self callback send]
    ]

    select: index [
	"Highlight the item at the given position in the listbox,
	 without unhighlighting other items.  This is meant for
	 multiple- or extended-mode listboxes, but can be used
	 with other selection mode in particular cases."

	<category: 'widget protocol'>
	self properties at: #index put: index.
	self connected getSelection selectIter: (self iterAt: index)
    ]

    show: index [
	"Ensure that the item at the given position in the listbox is
	 visible."

	<category: 'widget protocol'>
	| path |
	path := self pathAt: index.
	self connected 
	    scrollToCell: path
	    column: self gtkcolumn
	    useAlign: false
	    rowAlign: 0.0e
	    colAlign: 0.0e.
	path free
    ]

    unhighlight [
	"Unhighlight all the items in the listbox."

	<category: 'widget protocol'>
	self connected getSelection unselectAll
    ]

    unselect: index [
	"Unhighlight the item at the given position in the listbox,
	 without affecting the state of the other items."

	<category: 'widget protocol'>
	self connected getSelection unselectIter: (self iterAt: index)
    ]
]



BForm subclass: BWindow [
    | isMapped callback x y width height container uiBox uiManager |
    
    <comment: 'I am the boss. Nothing else could be viewed or interacted with if
it wasn''t for me... )):->'>
    <category: 'Graphics-Windows'>

    TopLevel := nil.

    BWindow class >> initializeOnStartup [
	<category: 'private - initialization'>
	TopLevel := OrderedCollection new
    ]

    BWindow class >> new [
	"Answer a new top-level window."

	<category: 'instance creation'>
	^TopLevel add: (super new: nil)
    ]

    BWindow class >> new: label [
	"Answer a new top-level window with `label' as its title bar caption."

	<category: 'instance creation'>
	^self new label: label
    ]

    BWindow class >> popup: initializationBlock [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    callback [
	"Answer a DirectedMessage that is sent to verify whether the
	 receiver must be destroyed when the user asks to unmap it."

	<category: 'accessing'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the user asks to unmap the
	 receiver.  If the method accepts an argument, the receiver is passed.
	 
	 If the method returns true, the window and its children are
	 destroyed (which is the default action, taken if no callback is
	 set up).  If the method returns false, the window is left in
	 place."

	<category: 'accessing'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := Array with: self].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    invokeCallback [
	"Generate a synthetic callback, destroying the window if no
	 callback was set up or if the callback method answers true."

	<category: 'accessing'>
	| result |
	result := self callback isNil or: [self callback send].
	result 
	    ifTrue: 
		[self destroy.
		isMapped := false].
	^result
    ]

    label [
	"Answer the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the
	 window."

	<category: 'accessing'>
	^self container getTitle
    ]

    label: value [
	"Set the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the
	 window."

	<category: 'accessing'>
	self container setTitle: value
    ]

    menu: aBMenuBar [
	"Set the value of the menu option for the widget.
	 
	 Specifies a menu widget to be used as a menubar."

	<category: 'accessing'>
	self uiBox 
	    packStart: aBMenuBar connected
	    expand: false
	    fill: false
	    padding: 0.
	self properties at: #menu put: aBMenuBar
    ]

    resizable [
	"Answer the value of the resizable option for the widget.
	 
	 Answer whether the user can be resize the window or not. If resizing is
	 disabled, then the window's size will be the size from the most recent
	 interactive resize or geometry-setting method. If there has been no such
	 operation then the window's natural size will be used."

	<category: 'accessing'>
	^self container getResizable
    ]

    resizable: value [
	"Set the value of the resizable option for the widget.
	 
	 Answer whether the user can be resize the window or not. If resizing is
	 disabled, then the window's size will be the size from the most recent
	 interactive resize or geometry-setting method. If there has been no such
	 operation then the window's natural size will be used."

	<category: 'accessing'>
	^self container setResizable: value
    ]

    uiBox [
	"answer the top level container for this window"

	<category: 'accessing'>
	^uiBox
    ]

    uiManager [
	<category: 'accessing'>
	uiManager isNil ifTrue: [uiManager := GTK.GtkUIManager new].
	^uiManager
    ]

    cacheWindowSize [
	"save the window position from gtk"

	<category: 'private'>
	| px py |
	px := CIntType gcNew.
	py := CIntType gcNew.
	self container getPosition: px rootY: py.
	x := px value.
	y := py value.
	self isMapped 
	    ifTrue: [self container getSize: px height: py]
	    ifFalse: [self container getDefaultSize: px height: py].
	width := px value.
	height := py value.
	self isMapped 
	    ifTrue: [self container setDefaultSize: width height: height]
    ]

    container [
	<category: 'private'>
	container isNil ifTrue: [self error: 'GTK object not created yet'].
	^container
    ]

    container: aWidget [
	<category: 'private'>
	container := aWidget
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: nil.
	self isMapped: false.
	self createWidget
    ]

    create [
	<category: 'private'>
	self container: (GTK.GtkWindow new: GTK.Gtk gtkWindowToplevel).
	self container 
	    connectSignal: 'delete-event'
	    to: self
	    selector: #onDelete:data:
	    userData: nil.
	self container 
	    connectSignal: 'configure-event'
	    to: self
	    selector: #onConfigure:data:
	    userData: nil.
	uiBox := GTK.GtkVBox new: false spacing: 0.
	self container add: uiBox.

	"Create the GtkPlacer"
	super create.
	uiBox 
	    packEnd: self connected
	    expand: true
	    fill: true
	    padding: 0
    ]

    show [
	"Do not show the GtkWindow until it is mapped!"

	<category: 'private'>
	super show.
	uiBox show
    ]

    onConfigure: object data: data [
	<category: 'private'>
	self cacheWindowSize
    ]

    onDelete: object data: data [
	<category: 'private'>
	^self callback notNil and: [self callback send not]
    ]

    destroyed [
	"Private - The receiver has been destroyed, remove it from the
	 list of toplevel windows to avoid memory leaks."

	<category: 'private'>
	super destroyed.
	TopLevel remove: self ifAbsent: [].
	(TopLevel isEmpty and: [DoDispatchEvents = 1]) 
	    ifTrue: [Blox terminateMainLoop]
    ]

    isMapped: aBoolean [
	<category: 'private'>
	isMapped := aBoolean
    ]

    resetGeometry: xPos y: yPos width: xSize height: ySize [
	<category: 'private'>
	(x = xPos and: [y = yPos and: [width = xSize and: [height = ySize]]]) 
	    ifTrue: [^self].
	self isMapped 
	    ifFalse: [self container setDefaultSize: xSize height: ySize]
	    ifTrue: [self container resize: xSize height: ySize].
	x := xPos.
	y := yPos.
	width := xSize.
	height := ySize
	"mapped ifTrue: [ self map ]."
    ]

    resized [
	<category: 'private'>
	self isMapped ifFalse: [^self].
	x := y := width := height := nil
    ]

    setInitialSize [
	<category: 'private'>
	self 
	    x: 0
	    y: 0
	    width: 300
	    height: 300
    ]

    center [
	"Center the window in the screen"

	<category: 'widget protocol'>
	| screenSize |
	screenSize := Blox screenSize.
	self x: screenSize x // 2 - (self width // 2)
	    y: screenSize y // 2 - (self height // 2)
    ]

    centerIn: view [
	"Center the window in the given widget"

	<category: 'widget protocol'>
	self x: view x + (view width // 2) - (self parent width // 2)
	    y: view x + (view height // 2) - (self parent height // 2)
    ]

    height [
	"Answer the height of the window, as deduced from the geometry
	 that the window manager imposed on the window."

	<category: 'widget protocol'>
	height isNil ifTrue: [self cacheWindowSize].
	^height
    ]

    height: anInteger [
	"Ask the window manager to give the given height to the window."

	<category: 'widget protocol'>
	width isNil ifTrue: [self cacheWindowSize].
	self 
	    resetGeometry: x
	    y: y
	    width: width
	    height: anInteger
    ]

    heightAbsolute [
	"Answer the height of the window, as deduced from the geometry
	 that the window manager imposed on the window."

	<category: 'widget protocol'>
	height isNil ifTrue: [self cacheWindowSize].
	^height
    ]

    heightOffset: value [
	<category: 'widget protocol'>
	self shouldNotImplement
    ]

    iconify [
	"Map a window and in iconified state.  If a window has not been
	 mapped yet, this is achieved by mapping the window in withdrawn
	 state first, and then iconifying it."

	<category: 'widget protocol'>
	self container iconify.
	self isMapped: false
    ]

    isMapped [
	"Answer whether the window is mapped"

	<category: 'widget protocol'>
	isMapped isNil ifTrue: [isMapped := false].
	^isMapped
    ]

    isWindow [
	<category: 'widget protocol'>
	^true
    ]

    map [
	"Map the window and bring it to the topmost position in the Z-order."

	<category: 'widget protocol'>
	self container present.
	self isMapped: true
    ]

    modalMap [
	"Map the window while establishing an application-local grab for it.
	 An event loop is started that ends only after the window has been
	 destroyed."

	<category: 'widget protocol'>
	self container setModal: true.
	self map.
	Blox dispatchEvents: self.
	self container setModal: false
    ]

    state [
	"Set the value of the state option for the window.
	 
	 Specifies one of four states for the window: either normal, iconic,
	 withdrawn, or (Windows only) zoomed."

	<category: 'widget protocol'>
	self tclEval: 'wm state ' , self connected.
	^self tclResult asSymbol
    ]

    state: aSymbol [
	"Raise an error. To set a BWindow's state, use #map and #unmap."

	<category: 'widget protocol'>
	self error: 'To set a BWindow''s state, use #map and #unmap.'
    ]

    unmap [
	"Unmap a window, causing it to be forgotten about by the window manager"

	<category: 'widget protocol'>
	self isMapped ifFalse: [^self].
	self hide.
	self isMapped: false
    ]

    width [
	"Answer the width of the window, as deduced from the geometry
	 that the window manager imposed on the window."

	<category: 'widget protocol'>
	width isNil ifTrue: [self cacheWindowSize].
	^width
    ]

    width: anInteger [
	"Ask the window manager to give the given width to the window."

	<category: 'widget protocol'>
	height isNil ifTrue: [self cacheWindowSize].
	self 
	    resetGeometry: x
	    y: y
	    width: anInteger
	    height: height
    ]

    width: xSize height: ySize [
	"Ask the window manager to give the given width and height to
	 the window."

	<category: 'widget protocol'>
	self 
	    resetGeometry: x
	    y: y
	    width: xSize
	    height: ySize
    ]

    widthAbsolute [
	"Answer the width of the window, as deduced from the geometry
	 that the window manager imposed on the window."

	<category: 'widget protocol'>
	width isNil ifTrue: [self cacheWindowSize].
	^width
    ]

    widthOffset: value [
	<category: 'widget protocol'>
	self shouldNotImplement
    ]

    window [
	<category: 'widget protocol'>
	^self
    ]

    x [
	"Answer the x coordinate of the window's top-left corner, as
	 deduced from the geometry that the window manager imposed on
	 the window."

	<category: 'widget protocol'>
	x isNil ifTrue: [self cacheWindowSize].
	^x
    ]

    x: anInteger [
	"Ask the window manager to move the window's left border
	 to the given x coordinate, keeping the size unchanged"

	<category: 'widget protocol'>
	y isNil ifTrue: [self cacheWindowSize].
	self 
	    resetGeometry: anInteger
	    y: y
	    width: width
	    height: height
    ]

    x: xPos y: yPos [
	"Ask the window manager to move the window's top-left corner
	 to the given coordinates, keeping the size unchanged"

	<category: 'widget protocol'>
	self 
	    resetGeometry: xPos
	    y: yPos
	    width: width
	    height: height
    ]

    x: xPos y: yPos width: xSize height: ySize [
	"Ask the window manager to give the requested geometry
	 to the window."

	"XXX gtk deprecates this sort of thing"

	

	<category: 'widget protocol'>
	self 
	    resetGeometry: xPos
	    y: yPos
	    width: xSize
	    height: ySize
    ]

    xAbsolute [
	"Answer the x coordinate of the window's top-left corner, as
	 deduced from the geometry that the window manager imposed on
	 the window."

	<category: 'widget protocol'>
	x isNil ifTrue: [self cacheWindowSize].
	^x
    ]

    xOffset: value [
	<category: 'widget protocol'>
	self shouldNotImplement
    ]

    y [
	"Answer the y coordinate of the window's top-left corner, as
	 deduced from the geometry that the window manager imposed on
	 the window."

	<category: 'widget protocol'>
	y isNil ifTrue: [self cacheWindowSize].
	^y
    ]

    y: anInteger [
	"Ask the window manager to move the window's left border
	 to the given y coordinate, keeping the size unchanged"

	<category: 'widget protocol'>
	x isNil ifTrue: [self cacheWindowSize].
	self 
	    resetGeometry: x
	    y: anInteger
	    width: width
	    height: height
    ]

    yAbsolute [
	"Answer the y coordinate of the window's top-left corner, as
	 deduced from the geometry that the window manager imposed on
	 the window."

	<category: 'widget protocol'>
	y isNil ifTrue: [self cacheWindowSize].
	^y
    ]

    yOffset: value [
	<category: 'widget protocol'>
	self shouldNotImplement
    ]
]



BWindow subclass: BTransientWindow [
    
    <comment: 'I am almost a boss. I represent a window which is logically linked
to another which sits higher in the widget hierarchy, e.g. a dialog
box'>
    <category: 'Graphics-Windows'>

    BTransientWindow class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    BTransientWindow class >> new: parentWindow [
	"Answer a new transient window attached to the given
	 parent window and with nothing in its title bar caption."

	<category: 'instance creation'>
	^(self basicNew)
	    initialize: parentWindow;
	    yourself
    ]

    BTransientWindow class >> new: label in: parentWindow [
	"Answer a new transient window attached to the given
	 parent window and with `label' as its title bar caption."

	<category: 'instance creation'>
	^(self basicNew)
	    initialize: parentWindow;
	    label: label;
	    yourself
    ]

    map [
	"Map the window and inform the windows manager that the
	 receiver is a transient window working on behalf of its
	 parent.  The window is also put in its parent window's
	 window group: the window manager might use this information,
	 for example, to unmap all of the windows in a group when the
	 group's leader is iconified."

	<category: 'widget protocol'>
	self parent isNil 
	    ifFalse: [self container setTransientFor: self parent container].
	super map
    ]
]



BWindow subclass: BPopupWindow [
    
    <comment: 'I am a pseudo-window that has no decorations and no ability to interact
with the user.  My main usage, as my name says, is to provide pop-up
functionality for other widgets.  Actually there should be no need to
directly use me - always rely on the #new and #popup: class methods.'>
    <category: 'Graphics-Windows'>

    addChild: w [
	"Private - The widget identified by child has been added to the
	 receiver.  This method is public not because you can call it,
	 but because it can be useful to override it to perform some
	 initialization on the children just added. Answer the new child."

	<category: 'geometry management'>
	self uiBox 
	    packEnd: w
	    expand: true
	    fill: true
	    padding: 1.
	w onDestroySend: #destroy to: self
    ]

    child: child height: value [
	"Set the given child's height.  This is done by setting
	 its parent window's (that is, our) height."

	"Only act after #addChild:"

	<category: 'geometry management'>
	self childrenCount = 0 ifTrue: [^self].
	self height: value
    ]

    child: child heightOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    child: child width: value [
	"Set the given child's width.  This is done by setting
	 its parent window's (that is, our) width."

	"Only act after #addChild:"

	<category: 'geometry management'>
	self childrenCount = 0 ifTrue: [^self].
	self width: value
    ]

    child: child widthOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    child: child x: value [
	"Set the x coordinate of the given child's top-left corner.
	 This is done by setting its parent window's (that is, our) x."

	<category: 'geometry management'>
	self x: value
    ]

    child: child xOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    child: child y: value [
	"Set the y coordinate of the given child's top-left corner.
	 This is done by setting its parent window's (that is, our) y."

	<category: 'geometry management'>
	self y: value
    ]

    child: child yOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    heightChild: child [
	"Answer the given child's height, which is the height that
	 was imposed on the popup window."

	<category: 'geometry management'>
	^self height
    ]

    widthChild: child [
	"Answer the given child's width in pixels, which is the width that
	 was imposed on the popup window."

	<category: 'geometry management'>
	^self width
    ]

    xChild: child [
	"Answer the x coordinate of the given child's top-left corner,
	 which is desumed by the position of the popup window."

	<category: 'geometry management'>
	^self x
    ]

    yChild: child [
	"Answer the y coordinate of the given child's top-left corner,
	 which is desumed by the position of the popup window."

	<category: 'geometry management'>
	^self y
    ]

    create [
	<category: 'private'>
	super create.
	self container setDecorated: false.
	self container setResizable: false
    ]

    setInitialSize [
	<category: 'private'>
	self cacheWindowSize
    ]
]



BForm subclass: BDialog [
    | callbacks initInfo buttonBox entry |
    
    <comment: 'I am a facility for implementing dialogs with many possible choices
and requests. In addition I provide support for a few platform native
common dialog boxes, such as choose-a-file and choose-a-color.'>
    <category: 'Graphics-Windows'>

    BDialog class >> new: parent [
	"Answer a new dialog handler (containing a label widget and
	 some button widgets) laid out within the given parent window.
	 The label widget, when it is created, is empty."

	<category: 'instance creation'>
	^(self basicNew)
	    initInfo: '' -> nil;
	    initialize: parent
    ]

    BDialog class >> new: parent label: aLabel [
	"Answer a new dialog handler (containing a label widget and
	 some button widgets) laid out within the given parent window.
	 The label widget, when it is created, contains aLabel."

	<category: 'instance creation'>
	^(self basicNew)
	    initInfo: aLabel -> nil;
	    initialize: parent
    ]

    BDialog class >> new: parent label: aLabel prompt: aString [
	"Answer a new dialog handler (containing a label widget, some
	 button widgets, and an edit window showing aString by default)
	 laid out within the given parent window.
	 The label widget, when it is created, contains aLabel."

	<category: 'instance creation'>
	^(self basicNew)
	    initInfo: aLabel -> aString;
	    initialize: parent
    ]

    BDialog class >> chooseFile: operation parent: parent label: aLabel default: name defaultExtension: ext types: typeList action: action button: button [
	<category: 'private'>
	| dialog result filename |
	'FIXME: implement the default, defaultExtension and typesList portions' 
	    printNl.
	parent map.
	dialog := GTK.GtkFileChooserDialog 
		    new: aLabel
		    parent: parent container
		    action: action
		    varargs: 
			{GTK.Gtk gtkStockCancel.
			GTK.Gtk gtkResponseCancel.
			button.
			GTK.Gtk gtkResponseAccept.
			nil}.
	result := dialog run.
	^result = GTK.Gtk gtkResponseAccept 
	    ifFalse: 
		[dialog destroy.
		nil]
	    ifTrue: 
		[filename := dialog getFilename.
		filename isEmpty ifTrue: [filename := nil].
		dialog destroy.
		filename]
    ]

    BDialog class >> chooseColor: parent label: aLabel default: color [
	"Prompt for a color.  The dialog box is created with the given
	 parent window and with aLabel as its title bar text, and initially
	 it selects the color given in the color parameter.
	 
	 If the dialog box is canceled, nil is answered, else the
	 selected color is returned as a String with its RGB value."

	<category: 'prompters'>
	| result |
	parent map.
	self 
	    tclEval: 'tk_chooseColor -parent %1 -title %2 -initialcolor %3'
	    with: parent container
	    with: aLabel asTkString
	    with: color asTkString.
	result := self tclResult.
	result isEmpty ifTrue: [result := nil].
	^result
    ]

    BDialog class >> chooseFileToOpen: parent label: aLabel default: name defaultExtension: ext types: typeList [
	"Pop up a dialog box for the user to select a file to open.
	 Its purpose is for the user to select an existing file only.
	 If the user enters an non-existent file, the dialog box gives
	 the user an error prompt and requires the user to give an
	 alternative selection or to cancel the selection. If an
	 application allows the user to create new files, it should
	 do so by providing a separate New menu command.
	 
	 If the dialog box is canceled, nil is answered, else the
	 selected file name is returned as a String.
	 
	 The dialog box is created with the given parent window
	 and with aLabel as its title bar text.  The name parameter
	 indicates which file is initially selected, and the default
	 extension specifies  a string that will be appended to the
	 filename if the user enters a filename without an extension.
	 
	 The typeList parameter is an array of arrays, like
	 #(('Text files' '.txt' '.diz') ('Smalltalk files' '.st')),
	 and is used to construct a listbox of file types.  When the user
	 chooses a file type in the listbox, only the files of that type
	 are listed.  Each item in the array contains a list of strings:
	 the first one is the name of the file type described by a particular
	 file pattern, and is the text string that appears in the File types
	 listbox, while the other ones are the possible extensions that
	 belong to this particular file type."

	"e.g.
	 fileName := BDialog
	 chooseFileToOpen: aWindow
	 label: 'Open file'
	 default: nil
	 defaultExtension: 'gif'
	 types: #(
	 ('Text files'       '.txt' '.diz')
	 ('Smalltalk files'  '.st')
	 ('C source files'   '.c')
	 ('GIF files'	'.gif'))"

	<category: 'prompters'>
	^self 
	    chooseFile: 'Open'
	    parent: parent
	    label: aLabel
	    default: name
	    defaultExtension: ext
	    types: typeList
	    action: GTK.Gtk gtkFileChooserActionOpen
	    button: GTK.Gtk gtkStockOpen
    ]

    BDialog class >> chooseFileToSave: parent label: aLabel default: name defaultExtension: ext types: typeList [
	"Pop up a dialog box for the user to select a file to save;
	 this differs from the file open dialog box in that non-existent
	 file names are accepted and existing file names trigger a
	 confirmation dialog box, asking the user whether the file
	 should be overwritten or not.
	 
	 If the dialog box is canceled, nil is answered, else the
	 selected file name is returned as a String.
	 
	 The dialog box is created with the given parent window
	 and with aLabel as its title bar text.  The name parameter
	 indicates which file is initially selected, and the default
	 extension specifies  a string that will be appended to the
	 filename if the user enters a filename without an extension.
	 
	 The typeList parameter is an array of arrays, like
	 #(('Text files' '.txt' '.diz') ('Smalltalk files' '.st')),
	 and is used to construct a listbox of file types.  When the user
	 chooses a file type in the listbox, only the files of that type
	 are listed.  Each item in the array contains a list of strings:
	 the first one is the name of the file type described by a particular
	 file pattern, and is the text string that appears in the File types
	 listbox, while the other ones are the possible extensions that
	 belong to this particular file type."

	<category: 'prompters'>
	^self 
	    chooseFile: 'Save'
	    parent: parent
	    label: aLabel
	    default: name
	    defaultExtension: ext
	    types: typeList
	    action: GTK.Gtk gtkFileChooserActionSave
	    button: GTK.Gtk gtkStockSave
    ]

    addButton: aLabel receiver: anObject index: anInt [
	"Add a button to the dialog box that, when clicked, will
	 cause the #dispatch: method to be triggered in anObject,
	 passing anInt as the argument of the callback.  The
	 caption of the button is set to aLabel."

	<category: 'accessing'>
	^self 
	    addButton: aLabel
	    receiver: anObject
	    message: #dispatch:
	    argument: anInt
    ]

    addButton: aLabel receiver: anObject message: aSymbol [
	"Add a button to the dialog box that, when clicked, will
	 cause the aSymbol unary selector to be sent to anObject.
	 The caption of the button is set to aLabel."

	<category: 'accessing'>
	callbacks addLast: (DirectedMessage 
		    selector: aSymbol
		    arguments: #()
		    receiver: anObject).
	self addButton: aLabel
    ]

    addButton: aLabel receiver: anObject message: aSymbol argument: arg [
	"Add a button to the dialog box that, when clicked, will
	 cause the aSymbol one-argument selector to be sent to anObject,
	 passing arg as the argument of the callback.  The
	 caption of the button is set to aLabel."

	<category: 'accessing'>
	callbacks addLast: (DirectedMessage 
		    selector: aSymbol
		    arguments: {arg}
		    receiver: anObject).
	self addButton: aLabel
    ]

    contents: newText [
	"Display newText in the entry widget associated to the dialog box."

	<category: 'accessing'>
	entry setText: newText
    ]

    contents [
	"Answer the text that is displayed in the entry widget associated
	 to the dialog box."

	<category: 'accessing'>
	^entry getText
    ]

    addButton: aLabel [
	<category: 'private'>
	| button |
	self buttonBox add: (button := GTK.GtkButton newWithLabel: aLabel).
	button show.
	button 
	    connectSignal: 'clicked'
	    to: self
	    selector: #clicked:data:
	    userData: callbacks size
    ]

    clicked: button data: data [
	<category: 'private'>
	self invokeCallback: data.
	self toplevel destroy
    ]

    buttonBox [
	<category: 'private'>
	buttonBox isNil ifTrue: [self create].
	^buttonBox
    ]

    create [
	"We do not use BDialog.  Instead, we work in the toplevel's
	 uiBox, because Blox makes the BDialog live into a BWindow
	 that provides space for other widgets."

	<category: 'private'>
	| uiBox label separator |
	super create.
	uiBox := self toplevel uiBox.
	buttonBox := GTK.GtkHButtonBox new.
	buttonBox setSpacing: 5.
	buttonBox setLayout: GTK.Gtk gtkButtonboxEnd.
	uiBox 
	    packEnd: buttonBox
	    expand: false
	    fill: false
	    padding: 5.
	buttonBox show.
	separator := GTK.GtkHSeparator new.
	uiBox 
	    packEnd: separator
	    expand: false
	    fill: false
	    padding: 0.
	separator show.

	"Put the GtkPlacer at the end of the list of the end-packed widgets,
	 which puts it above our GtkHSeparator and GtkHButtonBox."
	uiBox reorderChild: self toplevel connected position: -1.
	initInfo isNil ifTrue: [^self].
	label := GTK.GtkLabel new: initInfo key.
	label setAlignment: 0 yalign: 0.
	uiBox 
	    packStart: label
	    expand: false
	    fill: false
	    padding: 5.
	label show.
	initInfo value isNil ifTrue: [^self].
	entry := GTK.GtkEntry new.
	entry setText: initInfo value.
	uiBox 
	    packStart: entry
	    expand: false
	    fill: false
	    padding: 0.
	entry show
    ]

    initInfo: assoc [
	<category: 'private'>
	initInfo := assoc
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: parentWidget.
	callbacks := OrderedCollection new
    ]

    center [
	"Center the dialog box's parent window in the screen"

	<category: 'widget protocol'>
	self parent center
    ]

    centerIn: view [
	"Center the dialog box's parent window in the given widget"

	<category: 'widget protocol'>
	self parent centerIn: view
    ]

    invokeCallback: index [
	"Generate a synthetic callback corresponding to the index-th
	 button being pressed, and destroy the parent window (triggering
	 its callback if one was established)."

	<category: 'widget protocol'>
	(callbacks at: index asInteger) send
	"self parent destroy"
    ]

    loop [
	"Map the parent window modally.  In other words, an event loop
	 is started that ends only after the window has been destroyed.
	 For more information on the treatment of events for modal windows,
	 refer to BWindow>>#modalMap."

	<category: 'widget protocol'>
	self toplevel container showAll.
	self toplevel modalMap
    ]
]



BMenuObject subclass: BMenuBar [
    | actionGroup uiManager |
    
    <comment: 'I am the Menu Bar, the top widget in a full menu structure.'>
    <category: 'Graphics-Windows'>

    add: aMenu [
	"Add aMenu to the menu bar"

	<category: 'accessing'>
	aMenu create.
	^aMenu
    ]

    remove: aMenu [
	"Remove aMenu from the menu bar"

	<category: 'accessing'>
	self 
	    tclEval: 'catch { %1 delete %2 }'
	    with: self connected
	    with: aMenu connected
    ]

    uiManager [
	<category: 'private'>
	uiManager isNil ifTrue: [self create].
	^uiManager
    ]

    create [
	<category: 'private'>
	uiManager := self parent isNil 
		    ifTrue: [GTK.GtkUIManager new]
		    ifFalse: [self toplevel uiManager].
	self uiManager 
	    addUi: self uiManager newMergeId
	    path: '/'
	    name: self name
	    action: self name
	    type: GTK.Gtk gtkUiManagerMenubar
	    top: false.
	self parent isNil ifFalse: [self parent menu: self].
	actionGroup := GTK.GtkActionGroup new: 'MenuActions'.
	self uiManager insertActionGroup: actionGroup pos: 0
    ]

    exists [
	<category: 'private'>
	^uiManager notNil
    ]

    name [
	"answer the name"

	<category: 'private'>
	^'MainMenu'
    ]

    path [
	"answer the menu path"

	<category: 'private'>
	^'/MainMenu'
    ]

    actionGroup [
	"answer an actiongroup that menu entries should go in"

	<category: 'private'>
	actionGroup isNil ifTrue: [self create].
	^actionGroup
    ]
]



BMenuObject subclass: BMenu [
    | connected label |
    
    <comment: 'I am a Menu that is part of a menu bar.'>
    <category: 'Graphics-Windows'>

    BMenu class >> new: parent label: label [
	"Add a new menu to the parent window's menu bar, with `label' as
	 its caption (for popup menus, parent is the widget over which the
	 menu pops up as the right button is pressed)."

	<category: 'instance creation'>
	^(self basicNew)
	    initialize: parent;
	    label: label;
	    yourself
    ]

    label [
	"Answer the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	^label
    ]

    label: value [
	"Set the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	"TODO: save the merge id we used, remove the ui, and re-add the ui with the new label"

	<category: 'accessing'>
	label := value
    ]

    addLine [
	"Add a separator item at the end of the menu"

	<category: 'callback registration'>
	^self addMenuItemFor: #() notifying: self	"self is dummy"
    ]

    addMenuItemFor: anArray notifying: receiver [
	"Add a menu item described by anArray at the end of the menu.
	 If anArray is empty, insert a separator line.  If anArray
	 has a single item, a menu item is created without a callback.
	 If anArray has two or three items, the second one is used as
	 the selector sent to receiver, and the third one (if present)
	 is passed to the selector."

	"Receiver will be sent the callback messages.  anArray
	 is something that responds to at: and size.  Possible types are:
	 #()		insert a seperator line
	 #(name)	        create a menu item with name, but no callback
	 #(name symbol)     create a menu item with the given name and
	 no parameter callback.
	 #(name symbol arg) create a menu item with the given name and
	 one parameter callback."

	<category: 'callback registration'>
	| item |
	item := self newMenuItemFor: anArray notifying: receiver.
	self exists ifFalse: [self create].
	item create
    ]

    callback: receiver using: selectorPairs [
	"Add menu items described by anArray at the end of the menu.
	 Each element of selectorPairs must be in the format described
	 in BMenu>>#addMenuItemFor:notifying:.  All the callbacks will
	 be sent to receiver."

	<category: 'callback registration'>
	selectorPairs do: [:pair | self addMenuItemFor: pair notifying: receiver]
    ]

    empty [
	"Empty the menu widget; that is, remove all the children"

	<category: 'callback registration'>
	self tclEval: self connected , ' delete 0 end'.
	children := OrderedCollection new.
	childrensUnderline := nil
    ]

    destroy [
	"Destroy the menu widget; that is, simply remove ourselves from
	 the parent menu bar."

	<category: 'callback registration'>
	self parent remove: self
    ]

    addChild: menuItem [
	<category: 'private'>
	self exists ifFalse: [self create].
	menuItem create.
	^menuItem
    ]

    actionGroup [
	"answer the menu action group"

	<category: 'private'>
	^self parent actionGroup
    ]

    name [
	"answer the name the menu should get"

	<category: 'private'>
	^self label , 'Menu'
    ]

    menuLabel [
	"answer the label the menu should get"

	<category: 'private'>
	^'_' , self label
    ]

    path [
	"answer the path for the menu"

	<category: 'private'>
	^self parent path , '/' , self name
    ]

    uiManager [
	"answer the ui manager"

	<category: 'private'>
	^self parent uiManager
    ]

    connected [
	<category: 'private'>
	connected isNil ifTrue: [connected := self uiManager getWidget: self path].
	^connected
    ]

    create [
	<category: 'private'>
	| s menu u |
	self actionGroup addAction: (GTK.GtkAction 
		    new: self name
		    label: self menuLabel
		    tooltip: nil
		    stockId: nil).
	self uiManager 
	    addUi: self uiManager newMergeId
	    path: self parent path
	    name: self name
	    action: self name
	    type: GTK.Gtk gtkUiManagerMenu
	    top: false.
	self childrenDo: [:each | each create]
    ]

    onDestroy: object data: data [
	<category: 'private'>
	self destroyed
    ]

    exists [
	<category: 'private'>
	^self connected notNil
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: parentWidget.
	label := ''
    ]

    newMenuItemFor: pair notifying: receiver [
	<category: 'private'>
	| item size |
	size := pair size.
	pair size = 0 ifTrue: [^BMenuItem new: self].
	(size >= 2 and: [pair last isArray]) 
	    ifTrue: 
		[size := size - 1.
		item := BMenu new: self label: (pair at: 1).
		pair last 
		    do: [:each | item add: (item newMenuItemFor: each notifying: receiver)]]
	    ifFalse: [item := BMenuItem new: self label: (pair at: 1)].
	size = 1 ifTrue: [^item].
	size = 2 ifTrue: [^item callback: receiver message: (pair at: 2)].
	^item 
	    callback: receiver
	    message: (pair at: 2)
	    argument: (pair at: 3)
    ]
]



BMenu subclass: BPopupMenu [
    | attachedWidget |
    
    <comment: 'I am a class that provides the ability to show popup menus when the
right button (Button 3) is clicked on another window.'>
    <category: 'Graphics-Windows'>

    PopupMenuBar := nil.
    PopupMenus := nil.

    BPopupMenu class >> initializeOnStartup [
	<category: 'private - accessing'>
	PopupMenuBar := nil.
	PopupMenus := WeakKeyIdentityDictionary new
    ]

    BPopupMenu class >> popupMenuBar [
	"answer the menubar this menu conceptually exists in"

	<category: 'private - accessing'>
	PopupMenuBar isNil ifTrue: [PopupMenuBar := BMenuBar new: nil].
	^PopupMenuBar
    ]

    initialize: parentWindow [
	"TODO: refactor so that 'self parent' is parentWindow.  Start by
	 writing (and using!) a menuBar method in BMenu and overriding it here."

	<category: 'private'>
	self class popupMenuBar exists ifFalse: [self class popupMenuBar create].
	super initialize: self class popupMenuBar.
	attachedWidget := parentWindow.
	PopupMenus at: parentWindow ifPresent: [:menu | menu destroy].
	PopupMenus at: attachedWidget put: self
    ]

    create [
	<category: 'private'>
	super create.
	attachedWidget connected 
	    connectSignal: 'button-press-event'
	    to: self
	    selector: #onPopup:event:data:
	    userData: nil
    ]

    destroyed [
	<category: 'private'>
	super destroyed.
	attachedWidget := nil
    ]

    onPopup: widget event: event data: data [
	<category: 'private'>
	| buttonEv |
	buttonEv := event castTo: GTK.GdkEventButton type.
	buttonEv button value = 3 ifFalse: [^false].
	self connected getSubmenu 
	    popup: nil
	    parentMenuItem: nil
	    func: nil
	    data: nil
	    button: 3
	    activateTime: buttonEv time value.
	^true
    ]

    popup [
	"Generate a synthetic menu popup event"

	<category: 'widget protocol'>
	self connected getSubmenu 
	    popup: attachedWidget connected
	    parentMenuItem: nil
	    func: nil
	    data: nil
	    button: 0
	    activateTime: GTK.Gtk getCurrentEventTime
    ]
]



BMenuObject subclass: BMenuItem [
    | index |
    
    <comment: 'I am the tiny and humble Menu Item, a single command choice in the
menu structure. But if it wasn''t for me, nothing could be done...
eh eh eh!!'>
    <category: 'Graphics-Windows'>

    BMenuItem class >> new: parent [
	"Add a new separator item to the specified menu."

	<category: 'instance creation'>
	^self basicNew initialize: parent
    ]

    BMenuItem class >> new: parent label: label [
	"Add a new menu item to the specified menu (parent) , with `label'
	 as its caption."

	<category: 'instance creation'>
	^self basicNew initialize: parent label: label
    ]

    label [
	"Answer the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	^self properties at: #label
    ]

    label: value [
	"Set the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	(self properties at: #label) isNil 
	    ifTrue: [^self error: 'no label for separator lines'].
	self parent exists 
	    ifTrue: 
		[self 
		    tclEval: self container , ' entryconfigure ' , self connected , ' -label ' 
			    , value asTkString].
	self properties at: #label put: value
    ]

    actionGroup [
	"answer the menu action group"

	<category: 'private'>
	^self parent actionGroup
    ]

    uiManager [
	<category: 'private'>
	^self parent uiManager
    ]

    name [
	"answer the name of the item"

	<category: 'private'>
	^self label
    ]

    menuLabel [
	"answer the gtk label"

	<category: 'private'>
	^'_' , self name
    ]

    path [
	"answer the gtk uiManager path"

	<category: 'private'>
	^self parent path , '/' , self name
    ]

    create [
	<category: 'private'>
	| s u mergeid action |
	self name isNil 
	    ifTrue: 
		[mergeid := self uiManager newMergeId.
		self properties at: #label put: 'separator' , (mergeid printString: 10).
		self uiManager 
		    addUi: mergeid
		    path: self parent path
		    name: self name
		    action: nil
		    type: GTK.Gtk gtkUiManagerSeparator
		    top: false]
	    ifFalse: 
		[action := GTK.GtkAction 
			    new: self name
			    label: self menuLabel
			    tooltip: 'FIXME'
			    stockId: nil.

		"FIXME, when to use stock options?  GTK.Gtk gtkStockOpen."
		action 
		    connectSignal: 'activate'
		    to: self
		    selector: #activated:data:
		    userData: nil.

		"FIXME when to trigger accelerators"
		"self actionGroup addActionWithAccel: foo accelerator: '<control>O'."
		self actionGroup addAction: action.
		self uiManager 
		    addUi: self uiManager newMergeId
		    path: self parent path
		    name: self name
		    action: self name
		    type: GTK.Gtk gtkUiManagerMenuitem
		    top: false]
    ]

    activated: action data: userData [
	<category: 'private'>
	self invokeCallback
    ]

    initialize: parentWidget [
	"initialize a separator item"

	<category: 'private'>
	super initialize: parentWidget.
	self properties at: #label put: nil
    ]

    initialize: parentWidget label: label [
	<category: 'private'>
	| s |
	super initialize: parentWidget.
	self properties at: #label put: label.
	parent exists ifTrue: [self create]
    ]
]



BMenuItem subclass: BCheckMenuItem [
    | status |
    
    <comment: 'I am a menu item which can be toggled between two states, marked
and unmarked.'>
    <category: 'Graphics-Windows'>

    BCheckMenuItem class >> new: parent [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    invokeCallback [
	"Generate a synthetic callback"

	<category: 'accessing'>
	self properties removeKey: #value ifAbsent: [].
	self callback isNil ifFalse: [self callback send]
    ]

    value [
	"Answer whether the menu item is in a selected (checked) state."

	<category: 'accessing'>
	^self properties at: #value ifAbsentPut: [false]
    ]

    value: aBoolean [
	"Set whether the button is in a selected (checked) state and
	 generates a callback accordingly."

	<category: 'accessing'>
	self properties at: #value put: aBoolean.
	self tclEval: 'set ' , self variable , self valueString.
	self callback isNil ifFalse: [self callback send]
    ]

    create [
	<category: 'private'>
	super create.
	self 
	    tclEval: '%1 entryconfigure %2 -onvalue 1 -offvalue 0 -variable %3'
	    with: self container
	    with: self connected
	    with: self variable
    ]

    destroyed [
	"Private - The receiver has been destroyed, clear the corresponding
	 Tcl variable to avoid memory leaks."

	<category: 'private'>
	self tclEval: 'unset ' , self variable.
	super destroyed
    ]

    valueString [
	<category: 'private'>
	^self value ifTrue: [' 1'] ifFalse: [' 0']
    ]

    variable [
	<category: 'private'>
	^'var' , self connected , self container copyWithout: $.
    ]

    widgetType [
	<category: 'private'>
	^'checkbutton'
    ]
]



"-------------------------- BEdit class -----------------------------"



"-------------------------- BLabel class -----------------------------"



Eval [
    BLabel initialize
]



"-------------------------- BButton class -----------------------------"



"-------------------------- BForm class -----------------------------"



"-------------------------- BContainer class -----------------------------"



"-------------------------- BRadioGroup class -----------------------------"



"-------------------------- BRadioButton class -----------------------------"



"-------------------------- BToggle class -----------------------------"



"-------------------------- BImage class -----------------------------"



"-------------------------- BList class -----------------------------"



"-------------------------- BWindow class -----------------------------"



"-------------------------- BTransientWindow class -----------------------------"



"-------------------------- BPopupWindow class -----------------------------"



"-------------------------- BDialog class -----------------------------"



"-------------------------- BMenuBar class -----------------------------"



"-------------------------- BMenu class -----------------------------"



"-------------------------- BPopupMenu class -----------------------------"



"-------------------------- BMenuItem class -----------------------------"



"-------------------------- BCheckMenuItem class -----------------------------"

PK
     �Mh@�Q^�  ^�    BloxExtend.stUT	 cqXO�XOux �  �  "======================================================================
|
|   Smalltalk Tk-based GUI building blocks, extended widgets.
|   This is 100% Smalltalk!
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
| Free Software Foundation, Inc.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



BExtended subclass: BProgress [
    | value filled label1 label2 |
    
    <comment: 'I show how much of a task has been completed.'>
    <category: 'Graphics-Examples'>

    backgroundColor [
	"Answer the background color of the widget.  This is used for
	 the background of the non-filled part, as well as for the
	 foreground of the filled part."

	<category: 'accessing'>
	^label1 backgroundColor
    ]

    backgroundColor: aColor [
	"Set the background color of the widget.  This is used for
	 the background of the non-filled part, as well as for the
	 foreground of the filled part."

	<category: 'accessing'>
	label1 backgroundColor: aColor.
	label2 foregroundColor: aColor
    ]

    filledColor [
	"Answer the background color of the widget's filled part."

	<category: 'accessing'>
	^label2 backgroundColor
    ]

    filledColor: aColor [
	"Set the background color of the widget's filled part."

	<category: 'accessing'>
	label2 backgroundColor: aColor
    ]

    foregroundColor [
	"Set the foreground color of the widget.  This is used for
	 the non-filled part, while the background color also works
	 as the foreground of the filled part."

	<category: 'accessing'>
	^label1 foregroundColor
    ]

    foregroundColor: aColor [
	"Set the foreground color of the widget.  This is used for
	 the non-filled part, while the background color also works
	 as the foreground of the filled part."

	<category: 'accessing'>
	label1 foregroundColor: aColor
    ]

    value [
	"Answer the filled percentage of the receiver (0..1)"

	<category: 'accessing'>
	^value
    ]

    value: newValue [
	"Set the filled percentage of the receiver and update the appearance.
	 newValue must be between 0 and 1."

	<category: 'accessing'>
	value := newValue.
	filled width: self value * self primitive widthAbsolute.
	label1 label: (value * 100) rounded printString , '%'.
	label2 label: (value * 100) rounded printString , '%'
    ]

    create [
	"Private - Create the widget"

	<category: 'private - gui'>
	| hgt |
	super create.
	self primitive onResizeSend: #resize: to: self.
	label1 := BLabel new: self primitive.
	filled := BForm new: self primitive.
	label2 := BLabel new: filled.
	hgt := self primitive height.
	label1
	    alignment: #center;
	    width: self primitive width height: hgt.
	label2
	    alignment: #center;
	    width: 0 height: hgt.
	self
	    backgroundColor: 'white';
	    foregroundColor: 'black';
	    filledColor: 'blue';
	    resize: nil;
	    value: 0
    ]

    newPrimitive [
	"Private - Create the BForm in which the receiver is drawn"

	<category: 'private - gui'>
	^BForm new: self parent
    ]

    resize: newSize [
	<category: 'private - gui'>
	label2 widthOffset: self primitive widthAbsolute
    ]
]



BExtended subclass: BButtonLike [
    | callback down |
    
    <comment: 'I am an object whose 3-D appearance resembles that of buttons.'>
    <category: 'Graphics-Examples'>

    callback [
	"Answer a DirectedMessage that is sent when the receiver is clicked,
	 or nil if none has been set up."

	<category: 'accessing'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the receiver is clicked.
	 If the method accepts an argument, the receiver is passed."

	<category: 'accessing'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := Array with: self].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    pressed [
	"This is the default callback for the widget; it does
	 nothing if you don't override it. Of course if a subclass
	 overriddes this you (user of the class) might desire to
	 call this method from your own callback."

	<category: 'accessing'>
	
    ]

    invokeCallback [
	"Generate a synthetic callback"

	<category: 'accessing'>
	self callback isNil ifFalse: [self callback send]
    ]

    down: point [
	"Private - Make the widget go down when the left button is
	 pressed inside it."

	<category: 'private - events'>
	down := true.
	self enter
    ]

    enter [
	"Private - Make the widget go down when the mouse enters with
	 the left button pressed."

	<category: 'private - events'>
	down ifTrue: [self primitive effect: #sunken]
    ]

    leave [
	"Private - Make the widget go up when the mouse leaves"

	<category: 'private - events'>
	down ifTrue: [self primitive effect: #raised]
    ]

    up: point [
	"Private - Make the widget go up when the left button is released
	 after being pressed inside it, and trigger the callback if the
	 button was released inside the widget."

	<category: 'private - events'>
	| inside |
	inside := self primitive effect == #sunken.
	inside ifTrue: [self leave].
	down := false.
	inside ifTrue: [self invokeCallback]
    ]

    create [
	"Ask myself to create the primitive widget and set up its
	 event handlers."

	<category: 'private'>
	super create.
	(self primitive)
	    borderWidth: 2;
	    effect: #raised;
	    onMouseEnterEventSend: #enter to: self;
	    onMouseLeaveEventSend: #leave to: self;
	    onMouseDownEvent: 1
		send: #down:
		to: self;
	    onMouseUpEvent: 1
		send: #up:
		to: self.
	down := false.
	callback := DirectedMessage 
		    selector: #pressed
		    arguments: #()
		    receiver: self
    ]
]



BButtonLike subclass: BColorButton [
    
    <comment: 'I am a button that shows a color and that, unless a different callback is
used, lets you choose a color when it is clicked.'>
    <category: 'Graphics-Examples'>

    color [
	"Set the color that the receiver is painted in."

	<category: 'accessing'>
	^self primitive backgroundColor
    ]

    color: aString [
	"Set the color that the receiver is painted in."

	<category: 'accessing'>
	self primitive backgroundColor: aString
    ]

    pressed [
	"This is the default callback; it brings up a `choose-a-color'
	 window and, if `Ok' is pressed in the window, sets the receiver
	 to be painted in the chosen color."

	<category: 'accessing'>
	| newColor |
	newColor := BDialog 
		    chooseColor: self window
		    label: 'Choose a color'
		    default: self color.
	newColor isNil ifFalse: [self color: newColor]
    ]

    newPrimitive [
	"Private - A BColorButton is implemented through a BLabel. (!)"

	"Make it big enough if no width is specified."

	<category: 'private - gui'>
	^BLabel new: self parent label: '        '
    ]
]



BEventSet subclass: BBalloon [
    | text |
    
    <comment: 'This event set allows a widget to show explanatory information when
the mouse lingers over it for a while.'>
    <category: 'Graphics-Examples'>

    BalloonDelayTime := nil.
    Popup := nil.
    Owner := nil.
    MyProcess := nil.

    BBalloon class >> balloonDelayTime [
	"Answer the time after which the balloon is shown (default is
	 half a second)."

	<category: 'accessing'>
	BalloonDelayTime isNil ifTrue: [BalloonDelayTime := 500].
	^BalloonDelayTime
    ]

    BBalloon class >> balloonDelayTime: milliseconds [
	"Set the time after which the balloon is shown."

	<category: 'accessing'>
	BalloonDelayTime := milliseconds
    ]

    BBalloon class >> shown [
	"Answer whether a balloon is displayed"

	<category: 'accessing'>
	^Popup notNil
    ]

    shown [
	"Answer whether the receiver's balloon is displayed"

	<category: 'accessing'>
	^self class shown and: [Owner == self]
    ]

    text [
	"Answer the text displayed in the balloon"

	<category: 'accessing'>
	^text
    ]

    text: aString [
	"Set the text displayed in the balloon to aString"

	<category: 'accessing'>
	text := aString
    ]

    initialize: aBWidget [
	"Initialize the event sets for the receiver"

	<category: 'initializing'>
	super initialize: aBWidget.
	self text: '<not set>'.
	self
	    onMouseEnterEventSend: #queue to: self;
	    onMouseLeaveEventSend: #unqueue to: self;
	    onMouseDownEventSend: #unqueue:button: to: self
    ]

    popup [
	"Private - Create the popup window showing the balloon."

	<category: 'private'>
	Popup := BLabel popup: 
			[:widget | 
			widget
			    label: self text;
			    backgroundColor: '#FFFFAA';
			    x: self widget yRoot + (self widget widthAbsolute // 2)
				y: self widget yRoot + self widget heightAbsolute + 4].

	"Set the owner *now*. Otherwise, the mouse-leave event generated
	 by mapping the new popup window will destroy the popup window
	 itself (see #unqueue)."
	Owner := self
    ]

    queue [
	"Private - Queue a balloon to be shown in BalloonDelayTime milliseconds"

	<category: 'private'>
	self shown ifTrue: [^self].
	MyProcess isNil 
	    ifTrue: 
		[MyProcess := 
			[(Delay forMilliseconds: self class balloonDelayTime) wait.
			MyProcess := nil.
			self popup] 
				fork]
    ]

    unqueue [
	"Private - Prevent the balloon from being displayed if we were waiting
	 for it to appear, or delete it if it was already there."

	<category: 'private'>
	MyProcess isNil 
	    ifFalse: 
		[MyProcess terminate.
		MyProcess := nil].
	self shown 
	    ifTrue: 
		[Popup window destroy.
		Owner := Popup := nil]
    ]

    unqueue: point button: button [
	"Private - Same as #unqueue: but the event handler for mouse-down
	 events needs two parameters."

	<category: 'private'>
	self unqueue
    ]
]



BExtended subclass: BDropDown [
    | list button widget callback |
    
    <comment: 'This class is an abstract superclass for widgets offering the ability
to pick items from a pre-built list.  The list is usually hidden, but
a button on the right of this widgets makes it pop up.  This widget
is thus composed of three parts: an unspecified text widget (shown on
the left of the button and always visible), the button widget (shown
on the right, it depicts a down arrow, and is always visible), and
the pop-up list widget.'>
    <category: 'Graphics-Examples'>

    backgroundColor [
	"Answer the value of the backgroundColor for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	^list backgroundColor
    ]

    backgroundColor: aColor [
	"Set the value of the backgroundColor for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	list backgroundColor: aColor
    ]

    droppedRows [
	"Answer the number of items that are visible at any time in
	 the listbox."

	<category: 'accessing'>
	^(list height - 8) / self itemHeight
    ]

    droppedRows: anInteger [
	"Set the number of items that are visible at any time in
	 the listbox."

	<category: 'accessing'>
	list height: anInteger * self itemHeight + 8
    ]

    font [
	"Answer the value of the font option for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	^list font
    ]

    font: value [
	"Set the value of the font option for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	list font: value
    ]

    foregroundColor [
	"Answer the value of the foregroundColor for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	^list foregroundColor
    ]

    foregroundColor: aColor [
	"Set the value of the foregroundColor for the widget, which
	 in this class is only set for the list widget (that is, the
	 pop-up widget). Subclasses should override this method so that
	 the color is set properly for the text widget as well.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	list foregroundColor: aColor
    ]

    highlightBackground [
	"Answer the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the list widget."

	<category: 'accessing'>
	^list highlightBackground
    ]

    highlightBackground: aColor [
	"Set the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the list widget."

	<category: 'accessing'>
	list highlightBackground: aColor
    ]

    highlightForeground [
	"Answer the value of the highlightForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected items
	 in the list widget."

	<category: 'accessing'>
	^list highlightForeground
    ]

    highlightForeground: aColor [
	"Set the value of the highlightForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected items
	 in the list widget."

	<category: 'accessing'>
	list highlightForeground: aColor
    ]

    callback [
	"Answer a DirectedMessage that is sent when the receiver is clicked,
	 or nil if none has been set up."

	<category: 'callbacks'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the receiver is clicked.
	 If the method accepts an argument, the receiver is passed."

	<category: 'callbacks'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := Array with: self].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    invokeCallback [
	"Generate a synthetic callback"

	<category: 'callbacks'>
	self callback isNil ifFalse: [self callback send]
    ]

    createList [
	"Create the popup widget to be used for the
	 `drop-down list'.  It is a BList by default, but you can
	 use any other widget, overriding the `list box accessing'
	 methods if necessary."

	<category: 'flexibility'>
	^BList new
    ]

    createTextWidget [
	"Create the widget that will hold the string chosen from
	 the list box and answer it. The widget must be a child of `self
	 primitive'."

	<category: 'flexibility'>
	self subclassResponsibility
    ]

    itemHeight [
	"Answer the height of an item in the drop-down list. The
	 default implementation assumes that the receiver understands
	 #font, but you can modify it if you want."

	<category: 'flexibility'>
	^1 + (self fontHeight: 'M')
    ]

    listCallback [
	"Called when an item of the listbox is highlighted. Do
	 nothing by default"

	<category: 'flexibility'>
	
    ]

    listSelectAt: aPoint [
	"Select the item lying at the given position in the list
	 box. The default implementation assumes that list is a BList, but
	 you can modify it if you want."

	<category: 'flexibility'>
	| newIndex |
	(list drawingArea containsPoint: aPoint) ifFalse: [^self].
	newIndex := list indexAt: aPoint.
	newIndex = list index ifTrue: [^self].
	self index: newIndex
    ]

    listText [
	"Answer the text currently chosen in the list box. The
	 default implementation assumes that list is a BList, but you can
	 modify it if you want."

	<category: 'flexibility'>
	^list labelAt: list index
    ]

    text [
	"Answer the text that the user has picked from the widget and/or
	 typed in the control (the exact way the text is entered will be
	 established by subclasses, since this is an abstract method)."

	<category: 'flexibility'>
	self subclassResponsibility
    ]

    text: aString [
	"Set the text widget to aString"

	<category: 'flexibility'>
	self subclassResponsibility
    ]

    create [
	<category: 'private - initialization'>
	super create.
	list := self createList.
	(self primitive)
	    defaultHeight: (self itemHeight + 6 max: 20);
	    effect: #sunken;
	    borderWidth: 2;
	    backgroundColor: 'white'.
	list borderWidth: 0.
	(widget := self createTextWidget)
	    inset: 1;
	    borderWidth: 0;
	    backgroundColor: 'white';
	    tabStop: true;
	    stretch: true.
	(button := BImage new: self primitive data: BImage downArrow)
	    effect: #raised;
	    borderWidth: 2.
	self droppedRows: 8.
	self setEvents
    ]

    newPrimitive [
	<category: 'private - initialization'>
	^(BContainer new: self parent)
	    setVerticalLayout: false;
	    yourself
    ]

    setEvents [
	<category: 'private - initialization'>
	self primitive onDestroySend: #destroy to: list.
	button 
	    onMouseDownEvent: 1
	    send: #value:
	    to: [:pnt | self toggle].
	list 
	    onKeyEvent: 'Tab'
	    send: #value
	    to: 
		[self unmapList.
		widget activateNext].
	list 
	    onKeyEvent: 'Shift-Tab'
	    send: #value
	    to: 
		[self unmapList.
		widget activatePrevious].
	list 
	    onKeyEvent: 'Return'
	    send: #unmapList
	    to: self.
	list 
	    onKeyEvent: 'Escape'
	    send: #unmapList
	    to: self.
	list 
	    onMouseUpEvent: 1
	    send: #value:
	    to: [:pnt | self unmapList].
	list onMouseMoveEventSend: #listSelectAt: to: self.
	list onFocusLeaveEventSend: #unmapList to: self.
	list callback: self message: #listCallback
    ]

    setInitialSize [
	<category: 'private - initialization'>
	self primitive x: 0 y: 0
    ]

    add: anObject afterIndex: index [
	"Add an element with the given value after another element whose
	 index is contained in the index parameter.  The label displayed
	 in the widget is anObject's displayString.  Answer anObject."

	<category: 'list box accessing'>
	^list add: anObject afterIndex: index
    ]

    add: aString element: anObject afterIndex: index [
	"Add an element with the aString label after another element whose
	 index is contained in the index parameter.  This method allows
	 the client to decide autonomously the label that the widget will
	 display.
	 
	 If anObject is nil, then string is used as the element as well.
	 If aString is nil, then the element's displayString is used as
	 the label.
	 
	 Answer anObject or, if it is nil, aString."

	<category: 'list box accessing'>
	^list 
	    add: aString
	    element: anObject
	    afterIndex: index
    ]

    addLast: anObject [
	"Add an element with the given value at the end of the listbox.
	 The label displayed in the widget is anObject's displayString.
	 Answer anObject."

	<category: 'list box accessing'>
	^list addLast: anObject
    ]

    addLast: aString element: anObject [
	"Add an element with the given value at the end of the listbox.
	 This method allows the client to decide autonomously the label
	 that the widget will display.
	 
	 If anObject is nil, then string is used as the element as well.
	 If aString is nil, then the element's displayString is used as
	 the label.
	 
	 Answer anObject or, if it is nil, aString."

	<category: 'list box accessing'>
	^list addLast: aString element: anObject
    ]

    associationAt: anIndex [
	"Answer an association whose key is the item at the given position
	 in the listbox and whose value is the label used to display that
	 item."

	<category: 'list box accessing'>
	^list associationAt: anIndex
    ]

    at: anIndex [
	"Answer the element displayed at the given position in the list
	 box."

	<category: 'list box accessing'>
	^list at: anIndex
    ]

    contents: stringCollection [
	"Set the elements displayed in the listbox, and set the labels
	 to be their displayStrings."

	<category: 'list box accessing'>
	list contents: stringCollection
    ]

    contents: stringCollection elements: elementList [
	"Set the elements displayed in the listbox to be those in elementList,
	 and set the labels to be the corresponding elements in stringCollection.
	 The two collections must have the same size."

	<category: 'list box accessing'>
	list contents: stringCollection elements: elementList
    ]

    do: aBlock [
	"Iterate over each element of the listbox and pass it to aBlock."

	<category: 'list box accessing'>
	list do: aBlock
    ]

    elements: elementList [
	"Set the elements displayed in the listbox, and set the labels
	 to be their displayStrings."

	<category: 'list box accessing'>
	list elements: elementList
    ]

    index: newIndex [
	"Highlight the item at the given position in the listbox, and
	 transfer the text in the list box to the text widget."

	<category: 'list box accessing'>
	list highlight: newIndex.
	self text: self listText.
	self isDropdownVisible ifFalse: [self invokeCallback]
    ]

    labelAt: anIndex [
	"Answer the label displayed at the given position in the list
	 box."

	<category: 'list box accessing'>
	^list labelAt: anIndex
    ]

    labelsDo: aBlock [
	"Iterate over the labels in the list widget and pass each of
	 them to aBlock."

	<category: 'list box accessing'>
	list labelsDo: aBlock
    ]

    numberOfStrings [
	"Answer the number of items in the list box"

	<category: 'list box accessing'>
	^list numberOfStrings
    ]

    removeAtIndex: index [
	"Remove the item at the given index in the list box, answering
	 the object associated to the element (i.e. the value that #at:
	 would have returned for the given index)"

	<category: 'list box accessing'>
	^list removeAtIndex: index
    ]

    size [
	"Answer the number of items in the list box"

	<category: 'list box accessing'>
	^list size
    ]

    dropdown [
	"Force the pop-up list widget to be visible."

	"Always reset the geometry -- it is harmless and *may*
	 actually get better appearance in some weird case."

	<category: 'widget protocol'>
	list window boundingBox: self dropRectangle.
	self isDropdownVisible ifTrue: [^self].
	list window map
    ]

    dropRectangle [
	"Answer the rectangle in which the list widget will pop-up.
	 If possible, this is situated below the drop-down widget's
	 bottom side, but if the screen space there is not enough
	 it could be above the drop-down widget's above side.  If
	 there is no screen space above as well, we pick the side
	 where we can offer the greatest number of lines in the
	 pop-up widget."

	<category: 'widget protocol'>
	| screen rectangle spaceBelow |
	screen := Rectangle origin: Blox screenOrigin extent: Blox screenSize.
	rectangle := Rectangle 
		    origin: self xRoot @ (self yRoot + self heightAbsolute)
		    extent: self widthAbsolute @ list height.
	spaceBelow := screen bottom - rectangle top.
	rectangle bottom > screen bottom ifFalse: [^rectangle].

	"Fine. Pop it up above the entry widget instead of below."
	rectangle moveTo: self xRoot @ self yRoot - rectangle extent.
	rectangle top < screen top ifFalse: [^rectangle].

	"How annoying, it doesn't fit in the screen.  Now we'll try
	 to be real clever and either pop it up or down, depending
	 on which way gives us the biggest list."
	spaceBelow < (rectangle bottom - screen top) 
	    ifTrue: [rectangle top: 0]
	    ifFalse: 
		[rectangle
		    moveTo: self xRoot @ (self yRoot + self heightAbsolute);
		    bottom: screen bottom].
	^rectangle
    ]

    isDropdownVisible [
	"Answer whether the pop-up widget is visible"

	<category: 'widget protocol'>
	^list window isMapped
    ]

    unmapList [
	"Unmap the pop-up widget from the screen, transfer its selected
	 item to the always visible text widget, and generate a callback."

	<category: 'widget protocol'>
	list window unmap.
	self text: self listText.
	self invokeCallback
    ]

    toggle [
	"Toggle the visibility of the pop-up widget."

	<category: 'widget protocol'>
	widget activate.
	self isDropdownVisible ifTrue: [self unmapList] ifFalse: [self dropdown]
    ]
]



BDropDown subclass: BDropDownList [
    | callback |
    
    <comment: 'This class resembles a list box widget, but its actual list shows up
only when you click the arrow button beside the currently selected item.'>
    <category: 'Graphics-Examples'>

    backgroundColor: aColor [
	"Set the value of the backgroundColor for the widget, which
	 in this class is set for the list widget and, when the focus is
	 outside the control, for the text widget as well.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	super backgroundColor: aColor.
	self highlight
    ]

    font: aString [
	"Set the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	widget font: aString.
	super font: aString
    ]

    foregroundColor: aColor [
	"Set the value of the foregroundColor for the widget, which
	 in this class is set for the list widget and, when the focus is
	 outside the control, for the text widget as well.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	super foregroundColor: aColor.
	self highlight
    ]

    highlightBackground: aColor [
	"Answer the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the list widget and, when the focus is inside the control, for the
	 text widget as well."

	<category: 'accessing'>
	super highlightBackground: aColor.
	self highlight
    ]

    highlightForeground: aColor [
	"Answer the value of the highlightForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected items
	 in the list widget and, when the focus is inside the control, for the
	 text widget as well."

	<category: 'accessing'>
	super highlightForeground: aColor.
	self highlight
    ]

    text [
	"Answer the text that the user has picked from the widget and/or
	 typed in the control (the exact way the text is entered will be
	 established by subclasses, since this is an abstract method)."

	<category: 'accessing'>
	^widget label
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a selector with at most two arguemtnts) when the active item in
	 the receiver changegs.  If the method accepts two arguments, the
	 receiver is  passed as the first parameter.  If the method accepts
	 one or two arguments, the selected index is passed as the last
	 parameter."

	<category: 'callbacks'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := {nil}].
	numArgs = 2 
	    ifTrue: 
		[arguments := 
			{self.
			nil}].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    invokeCallback [
	"Generate a synthetic callback."

	<category: 'callbacks'>
	self callback isNil ifTrue: [^self].
	self callback arguments isEmpty 
	    ifFalse: 
		[self callback arguments at: self callback arguments size put: self index].
	self callback send
    ]

    index [
	"Answer the value of the index option for the widget.  Since it is
	 not possible to modify an item once it has been picked from the
	 list widget, this is always defined for BDropDownList widgets."

	<category: 'list box accessing'>
	^list index
    ]

    highlight [
	<category: 'private'>
	| bg fg |
	widget isActive 
	    ifTrue: 
		[bg := list highlightBackground.
		fg := list highlightForeground]
	    ifFalse: 
		[bg := list backgroundColor.
		fg := list foregroundColor].
	widget
	    backgroundColor: bg;
	    foregroundColor: fg
    ]

    createTextWidget [
	<category: 'private-overrides'>
	^BLabel new: self primitive
    ]

    listCallback [
	<category: 'private-overrides'>
	self text: self listText
    ]

    text: aString [
	<category: 'private-overrides'>
	widget label: aString
    ]

    setEvents [
	<category: 'private-overrides'>
	super setEvents.

	"If we did not test whether the list box is focus, we would toggle
	 twice (once in the widget's mouseDownEvent, once in the list's
	 focusLeaveEvent)"
	widget 
	    onMouseDownEvent: 1
	    send: #value:
	    to: 
		[:pnt | 
		"list isActive ifFalse: ["

		self toggle	"]"].
	widget onFocusEnterEventSend: #highlight to: self.
	widget onFocusLeaveEventSend: #highlight to: self.
	widget 
	    onKeyEvent: 'Down'
	    send: #dropdown
	    to: self
    ]
]



BDropDown subclass: BDropDownEdit [
    
    <comment: 'This class resembles an edit widget, but it has an arrow button that 
allows the user to pick an item from a pre-built list.'>
    <category: 'Graphics-Examples'>

    backgroundColor: aColor [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	super backgroundColor: aColor.
	widget backgroundColor: aColor
    ]

    font: aString [
	"Set the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	widget font: aString.
	super font: aString
    ]

    foregroundColor: aColor [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	super foregroundColor: aColor.
	widget foregroundColor: aColor
    ]

    highlightBackground: aColor [
	"Set the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the list widget and the selection in the text widget."

	<category: 'accessing'>
	super highlightBackground: aColor.
	widget selectBackground: aColor
    ]

    highlightForeground: aColor [
	"Set the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the list widget and the selection in the text widget."

	<category: 'accessing'>
	super highlightForeground: aColor.
	widget selectForeground: aColor
    ]

    text [
	"Answer the text shown in the widget"

	<category: 'accessing-overrides'>
	^widget contents
    ]

    editCallback [
	<category: 'private'>
	self isDropdownVisible ifFalse: [self invokeCallback]
    ]

    createTextWidget [
	<category: 'private-overrides'>
	^(BEdit new: self primitive) callback: self message: #editCallback
    ]

    insertAtEnd: aString [
	"Clear the selection and append aString at the end of the
	 text widget."

	<category: 'text accessing'>
	widget insertAtEnd: aString
    ]

    replaceSelection: aString [
	"Insert aString in the text widget at the current insertion point,
	 replacing the currently selected text (if any), and leaving
	 the text selected."

	<category: 'text accessing'>
	widget replaceSelection: aString
    ]

    selectAll [
	"Select the whole contents of the text widget"

	<category: 'text accessing'>
	widget selectAll
    ]

    selectFrom: first to: last [
	"Sets the selection of the text widget to include the characters
	 starting with the one indexed by first (the very first character in
	 the widget having index 1) and ending with the one just before
	 last.  If last refers to the same character as first or an earlier
	 one, then the text widget's selection is cleared."

	<category: 'text accessing'>
	widget selectFrom: first to: last
    ]

    selection [
	"Answer an empty string if the text widget has no selection, else answer
	 the currently selected text"

	<category: 'text accessing'>
	^widget selection
    ]

    selectionRange [
	"Answer nil if the text widget has no selection, else answer
	 an Interval object whose first item is the index of the
	 first character in the selection, and whose last item is the
	 index of the character just after the last one in the
	 selection."

	<category: 'text accessing'>
	^widget selectionRange
    ]

    text: aString [
	"Set the contents of the text widget and select them."

	<category: 'text accessing'>
	widget
	    contents: aString;
	    selectAll
    ]
]



"-------------------------- BProgress class -----------------------------"



"-------------------------- BButtonLike class -----------------------------"



"-------------------------- BColorButton class -----------------------------"



"-------------------------- BBalloon class -----------------------------"



"-------------------------- BDropDown class -----------------------------"



"-------------------------- BDropDownList class -----------------------------"



"-------------------------- BDropDownEdit class -----------------------------"

PK
     �Mh@H�m��  ��    BloxText.stUT	 cqXO�XOux �  �  "======================================================================
|
|   Smalltalk Tk-based GUI building blocks (text widget).
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
| Written by Paolo Bonzini and Robert Collins.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



BViewport subclass: BText [
    | callback tagInfo images gtkbuffer |
    
    <comment: '
I represent a text viewer with pretty good formatting options.'>
    <category: 'Graphics-Windows'>

    BText class >> emacsLike [
	"Answer whether we are using Emacs or Motif key bindings."

	<category: 'accessing'>
	'FIXME: emacsLike should die?' printNl.
	^false
	"self tclEval: 'return $tk_strictMotif'.
	 ^self tclResult = '0'"
    ]

    BText class >> emacsLike: aBoolean [
	"Set whether we are using Emacs or Motif key bindings."

	<category: 'accessing'>
	'FIXME: emacsLike should die?' printNl
	"self tclEval:
	 'set tk_strictMotif ', (aBoolean ifTrue: [ '0' ] ifFalse: [ '1' ])."
    ]

    BText class >> newReadOnly: parent [
	"Answer a new read-only text widget (read-only is achieved simply
	 by setting its state to be disabled)"

	<category: 'instance creation'>
	| ctl |
	ctl := self new: parent.
	ctl tclEval: ctl connected , ' configure -state disabled'.
	^ctl
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #background ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -background'
	    with: self connected
	    with: self container.
	^self properties at: #background put: self tclResult
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -background %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #background put: value
    ]

    callback [
	"Answer a DirectedMessage that is sent when the receiver is modified,
	 or nil if none has been set up."

	<category: 'accessing'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the receiver is modified.
	 If the method accepts an argument, the receiver is passed."

	<category: 'accessing'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := Array with: self].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    contents [
	"Return the contents of the widget"

	<category: 'accessing'>
	| bounds |
	bounds := self gtkbuffer getBounds.
	^(bounds at: 1) getVisibleText: (bounds at: 2)
    ]

    contents: aString [
	"Set the contents of the widget"

	<category: 'accessing'>
	self gtkbuffer setText: aString
    ]

    font [
	"Answer the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	self properties at: #font ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -font'
	    with: self connected
	    with: self container.
	^self properties at: #font put: self tclResult
    ]

    font: value [
	"Set the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	"Change default font throughout the widget"

	<category: 'accessing'>
	self connected modifyFont: (GTK.PangoFontDescription fromString: value).
	self properties at: #font put: value
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #foreground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -foreground'
	    with: self connected
	    with: self container.
	^self properties at: #foreground put: self tclResult
    ]

    foregroundColor: value [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -foreground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #foreground put: value
    ]

    getSelection [
	"Answer an empty string if the widget has no selection, else answer
	 the currently selected text"

	<category: 'accessing'>
	| bounds |
	bounds := self gtkbuffer getSelectionBounds.
	^(bounds at: 1) getVisibleText: (bounds at: 2)
    ]

    selectBackground [
	"Answer the value of the selectBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self properties at: #selectbackground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -selectbackground'
	    with: self connected
	    with: self container.
	^self properties at: #selectbackground put: self tclResult
    ]

    selectBackground: value [
	"Set the value of the selectBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -selectbackground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #selectbackground put: value
    ]

    selectForeground [
	"Answer the value of the selectForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self properties at: #selectforeground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -selectforeground'
	    with: self connected
	    with: self container.
	^self properties at: #selectforeground put: self tclResult
    ]

    selectForeground: value [
	"Set the value of the selectForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -selectforeground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #selectforeground put: value
    ]

    wrap [
	"Answer the value of the wrap option for the widget.
	 
	 Specifies how to handle lines in the text that are too long to be displayed
	 in a single line of the text's window. The value must be #none or #char or
	 #word. A wrap mode of none means that each line of text appears as exactly
	 one line on the screen; extra characters that do not fit on the screen are
	 not displayed. In the other modes each line of text will be broken up into
	 several screen lines if necessary to keep all the characters visible. In
	 char mode a screen line break may occur after any character; in word mode a
	 line break will only be made at word boundaries."

	<category: 'accessing'>
	self properties at: #wrap ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -wrap'
	    with: self connected
	    with: self container.
	^self properties at: #wrap put: self tclResult asSymbol
    ]

    wrap: value [
	"Set the value of the wrap option for the widget.
	 
	 Specifies how to handle lines in the text that are too long to be displayed
	 in a single line of the text's window. The value must be #none or #char or
	 #word. A wrap mode of none means that each line of text appears as exactly
	 one line on the screen; extra characters that do not fit on the screen are
	 not displayed. In the other modes each line of text will be broken up into
	 several screen lines if necessary to keep all the characters visible. In
	 char mode a screen line break may occur after any character; in word mode a
	 line break will only be made at word boundaries."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -wrap %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #wrap put: value
    ]

    insertAtEnd: aString attribute: attr [
	"Clear the selection and append aString at the end of the
	 widget.  Use the given attributes to format the text."

	<category: 'attributes'>
	| start tmpMark end |
	attr isNil ifTrue: [^self insertAtEnd: aString].
	end := self gtkbuffer getEndIter.
	tmpMark := self gtkbuffer 
		    createMark: 'temporary'
		    where: end
		    leftGravity: true.
	self gtkbuffer beginUserAction.
	self gtkbuffer insert: end text: aString.
	start := self gtkbuffer getIterAtMark: tmpMark.
	end := self gtkbuffer getEndIter.
	self gtkbuffer placeCursor: end.
	self 
	    setAttributes: attr
	    start: start
	    end: end.
	self gtkbuffer endUserAction
    ]

    insertText: aString attribute: attr [
	"Insert aString in the widget at the current insertion point,
	 replacing the currently selected text (if any).  Use the
	 given attributes to format the text."

	<category: 'attributes'>
	| bounds start end tmpMark |
	attr isNil ifTrue: [^self insertText: aString].

	"We need a temporary mark to save the beginning of the selection."
	bounds := self gtkbuffer getSelectionBounds.
	tmpMark := self gtkbuffer 
		    createMark: 'temporary'
		    where: (bounds at: 1)
		    leftGravity: true.
	(self gtkbuffer)
	    beginUserAction;
	    deleteSelection: false defaultEditable: true;
	    insertAtCursor: aString.
	start := self gtkbuffer getIterAtMark: tmpMark.
	end := self gtkbuffer getIterAtMark: self gtkbuffer getInsert.
	self 
	    setAttributes: attr
	    start: start
	    end: end.
	self gtkbuffer endUserAction
    ]

    removeAttributes [
	"Remove any kind of formatting from the text in the widget"

	<category: 'attributes'>
	tagInfo isNil ifTrue: [^self].
	self removeAttributesInside: 
		{self gtkbuffer getStartIter.
		self gtkbuffer getEndIter}
    ]

    removeAttributesFrom: aPoint to: endPoint [
	"Remove any kind of formatting from the text in the widget
	 between the given endpoints.  The two endpoints are Point
	 objects in which both coordinates are 1-based: the first
	 line is line 1, and the first character in the first line
	 is character 1."

	<category: 'attributes'>
	tagInfo isNil ifTrue: [^self].
	self removeAttributesInside: (self from: aPoint to: endPoint)
    ]

    setAttributes: attr from: aPoint to: endPoint [
	"Add the formatting given by attr to the text in the widget
	 between the given endpoints.  The two endpoints are Point
	 objects in which both coordinates are 1-based: the first
	 line is line 1, and the first character in the first line
	 is character 1."

	<category: 'attributes'>
	| range tag tags tagtable |
	attr isNil ifTrue: [^self].
	range := self from: aPoint to: endPoint.
	self 
	    setAttributes: attr
	    start: (range at: 1)
	    end: (range at: 2)
    ]

    child: child height: value [
	"Set the height of the given child to be `value' pixels."

	<category: 'geometry management'>
	| width height |
	height := self at: #heightGeom put: value asInteger.
	width := self at: #widthGeom ifAbsentPut: [self widthAbsolute]
	"self
	 tclEval: 'wm geometry %1 =%2x%3'
	 with: child container
	 with: width printString
	 with: height printString"
    ]

    child: child heightOffset: value [
	"Adjust the height of the given child to be given by `value'
	 more pixels."

	<category: 'geometry management'>
	self child: child height: (self heightChild: child) + value
    ]

    child: child width: value [
	"Set the width of the given child to be `value' pixels."

	<category: 'geometry management'>
	| width height |
	width := self at: #widthGeom put: value asInteger.
	height := self at: #heightGeom ifAbsentPut: [child heightAbsolute]
	"self
	 tclEval: 'wm geometry %1 =%2x%3'
	 with: child container
	 with: width printString
	 with: height printString"
    ]

    child: child widthOffset: value [
	"Adjust the width of the given child to be given by `value'
	 more pixels."

	<category: 'geometry management'>
	self child: child width: (self widthChild: child) + value
    ]

    child: child x: value [
	"Never fail and do nothing, the children stay where
	 the text ended at the time each child was added in
	 the widget"

	<category: 'geometry management'>
	
    ]

    child: child xOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    child: child y: value [
	"Never fail and do nothing, the children stay where
	 the text ended at the time each child was added in
	 the widget"

	<category: 'geometry management'>
	
    ]

    child: child yOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    heightChild: child [
	"Answer the given child's height in pixels."

	<category: 'geometry management'>
	^child at: #heightGeom ifAbsentPut: [child heightAbsolute]
    ]

    widthChild: child [
	"Answer the given child's width in pixels."

	<category: 'geometry management'>
	^child at: #widthGeom ifAbsentPut: [child widthAbsolute]
    ]

    xChild: child [
	"Answer the given child's top-left border's x coordinate.
	 We always answer 0 since the children actually move when
	 the text widget scrolls"

	<category: 'geometry management'>
	^0
    ]

    yChild: child [
	"Answer the given child's top-left border's y coordinate.
	 We always answer 0 since the children actually move when
	 the text widget scrolls"

	<category: 'geometry management'>
	^0
    ]

    insertImage: anObject [
	"Insert an image where the insertion point currently lies in the widget.
	 anObject can be a String containing image data (either Base-64 encoded
	 GIF data, XPM data, or PPM data), or the result or registering an image
	 with #registerImage:"

	<category: 'images'>
	| key |
	key := self registerImage: anObject.
	self 
	    tclEval: '%1 image create insert -align baseline -image %2'
	    with: self connected
	    with: key value.
	^key
    ]

    insertImage: anObject at: position [
	"Insert an image at the given position in the widget.  The
	 position is a Point object in which both coordinates are 1-based:
	 the first line is line 1, and the first character in the first
	 line is character 1.
	 
	 anObject can be a String containing image data (either Base-64 encoded
	 GIF data, XPM data, or PPM data), or the result or registering an image
	 with #registerImage:"

	<category: 'images'>
	| key |
	key := self registerImage: anObject.
	self 
	    tclEval: '%1 image create %2.%3 -align baseline -image %4'
	    with: self connected
	    with: position y printString
	    with: (position x - 1) printString
	    with: key value.
	^key
    ]

    insertImageAtEnd: anObject [
	"Insert an image at the end of the widgets text.
	 anObject can be a String containing image data (either Base-64 encoded
	 GIF data, XPM data, or PPM data), or the result or registering an image
	 with #registerImage:"

	<category: 'images'>
	| key |
	key := self registerImage: anObject.
	self 
	    tclEval: '%1 image create end -align baseline -image %2'
	    with: self connected
	    with: key value.
	^key
    ]

    registerImage: anObject [
	"Register an image (whose data is in anObject, a String including
	 Base-64 encoded GIF data, XPM data, or PPM data) to be used
	 in the widget.  If the same image must be used a lot of times,
	 it is better to register it once and then pass the result of
	 #registerImage: to the image insertion methods.
	 
	 Registered image are private within each BText widget.  Registering
	 an image with a widget and using it with another could give
	 unpredictable results."

	<category: 'images'>
	| imageName |
	anObject class == ValueHolder ifTrue: [^anObject].
	self tclEval: 'image create photo -data ' , anObject asTkImageString.
	images isNil ifTrue: [images := OrderedCollection new].
	imageName := images add: self tclResult.
	^ValueHolder value: imageName
    ]

    insertAtEnd: aString [
	"Clear the selection and append aString at the end of the
	 widget."

	<category: 'inserting text'>
	(self gtkbuffer)
	    insert: self gtkbuffer getEndIter text: aString;
	    placeCursor: self gtkbuffer getEndIter
    ]

    insertText: aString [
	"Insert aString in the widget at the current insertion point,
	 replacing the currently selected text (if any)."

	<category: 'inserting text'>
	(self gtkbuffer)
	    beginUserAction;
	    deleteSelection: false defaultEditable: true;
	    insertAtCursor: aString;
	    endUserAction
    ]

    insertSelectedText: aString [
	"Insert aString in the widget at the current insertion point,
	 leaving the currently selected text (if any) in place, and
	 selecting the text."

	<category: 'inserting text'>
	| bounds selBound tmpMark |
	selBound := self gtkbuffer getSelectionBound.
	bounds := self gtkbuffer getSelectionBounds.

	"We need a temporary mark to keep the beginning of the selection
	 where it is."
	tmpMark := self gtkbuffer 
		    createMark: 'temporary'
		    where: (bounds at: 1)
		    leftGravity: true.
	(self gtkbuffer)
	    beginUserAction;
	    placeCursor: (bounds at: 2);
	    insertAtCursor: aString;
	    moveMark: selBound where: (self gtkbuffer getIterAtMark: tmpMark);
	    endUserAction;
	    deleteMark: tmpMark
    ]

    insertText: aString at: position [
	"Insert aString in the widget at the given position,
	 replacing the currently selected text (if any).  The
	 position is a Point object in which both coordinates are 1-based:
	 the first line is line 1, and the first character in the first
	 line is character 1."

	<category: 'inserting text'>
	self 
	    tclEval: '%1 delete sel.first sel.last
	%1 insert %2.%3 %4
	%1 see insert'
	    with: self connected
	    with: position y printString
	    with: (position x - 1) printString
	    with: aString asTkString
    ]

    insertTextSelection: aString [
	"Insert aString in the widget after the current selection,
	 leaving the currently selected text (if any) intact."

	<category: 'inserting text'>
	| bounds selBound tmpMark |
	selBound := self gtkbuffer getSelectionBound.
	bounds := self gtkbuffer getSelectionBounds.

	"We need a temporary mark to put the beginning of the selection
	 where the selection used to end."
	tmpMark := self gtkbuffer 
		    createMark: 'temporary'
		    where: (bounds at: 2)
		    leftGravity: true.
	(self gtkbuffer)
	    beginUserAction;
	    placeCursor: (bounds at: 2);
	    insertAtCursor: aString;
	    moveMark: selBound where: (self gtkbuffer getIterAtMark: tmpMark);
	    endUserAction;
	    deleteMark: tmpMark
    ]

    invokeCallback [
	"Generate a synthetic callback."

	<category: 'inserting text'>
	self callback isNil ifFalse: [self callback send]
    ]

    nextPut: aCharacter [
	"Clear the selection and append aCharacter at the end of the
	 widget."

	<category: 'inserting text'>
	self insertAtEnd: (String with: aCharacter)
    ]

    nextPutAll: aString [
	"Clear the selection and append aString at the end of the
	 widget."

	<category: 'inserting text'>
	self insertAtEnd: aString
    ]

    nl [
	"Clear the selection and append a linefeed character at the
	 end of the widget."

	<category: 'inserting text'>
	self insertAtEnd: Character nl asString
    ]

    refuseTabs [
	"Arrange so that Tab characters, instead of being inserted
	 in the widget, traverse the widgets in the parent window."

	<category: 'inserting text'>
	self 
	    tclEval: '
	bind %1 <Tab> {
	    focus [tk_focusNext %W]
	    break
	}
	bind %1 <Shift-Tab> {
	    focus [tk_focusPrev %W]
	    break
	}'
	    with: self connected
    ]

    replaceSelection: aString [
	"Insert aString in the widget at the current insertion point,
	 replacing the currently selected text (if any), and leaving
	 the text selected."

	<category: 'inserting text'>
	| bounds |
	bounds := self gtkbuffer getSelectionBounds.
	self gtkbuffer delete: (bounds at: 1) end: (bounds at: 2).
	self gtkbuffer insertAtCursor: aString
    ]

    searchString: aString [
	"Search aString in the widget.  If it is not found,
	 answer zero, else answer the 1-based line number
	 and move the insertion point to the place where
	 the string was found."

	<category: 'inserting text'>
	| result |
	self 
	    tclEval: self connected , ' search ' , aString asTkString , ' 1.0 end'.
	result := self tclResult.
	result isEmpty ifTrue: [^0].
	self 
	    tclEval: '
	%1 mark set insert %2
	%1 see insert'
	    with: self connected
	    with: result.

	"Sending asInteger removes the column"
	^result asInteger
    ]

    space [
	"Clear the selection and append a space at the end of the
	 widget."

	<category: 'inserting text'>
	self insertAtEnd: ' '
    ]

    charsInLine: number [
	"Answer how many characters are there in the number-th line"

	<category: 'position & lines'>
	| iter |
	iter := self gtkbuffer getIterAtLine: number.
	iter forwardToLineEnd.
	^1 + iter getLineOffset
    ]

    currentColumn [
	"Answer the 1-based column number where the insertion point
	 currently lies."

	<category: 'position & lines'>
	| mark iter |
	mark := self gtkbuffer getInsert.
	iter := self gtkbuffer getIterAtMark: mark.
	^1 + iter getLineOffset
    ]

    currentLine [
	"Answer the 1-based line number where the insertion point
	 currently lies."

	<category: 'position & lines'>
	| mark iter |
	mark := self gtkbuffer getInsert.
	iter := self gtkbuffer getIterAtMark: mark.
	^1 + iter getLine
    ]

    currentPosition [
	"Answer a Point representing where the insertion point
	 currently lies.  Both coordinates in the answer are 1-based:
	 the first line is line 1, and the first character in the first
	 line is character 1."

	<category: 'position & lines'>
	| mark iter |
	mark := self gtkbuffer getInsert.
	iter := self gtkbuffer getIterAtMark: mark.
	^(1 + iter getLine) @ (1 + iter getLineOffset)
    ]

    currentPosition: aPoint [
	"Move the insertion point to the position given by aPoint.
	 Both coordinates in aPoint are interpreted as 1-based:
	 the first line is line 1, and the first character in the first
	 line is character 1."

	<category: 'position & lines'>
	| iter |
	iter := self gtkbuffer getIterAtLineOffset: aPoint y - 1
		    charOffset: aPoint x - 1.
	self gtkbuffer placeCursor: iter
    ]

    gotoLine: line end: aBoolean [
	"If aBoolean is true, move the insertion point to the last
	 character of the line-th line (1 being the first line
	 in the widget); if aBoolean is false, move it to the start
	 of the line-th line."

	<category: 'position & lines'>
	| iter |
	iter := self gtkbuffer getIterAtLine: line - 1.
	aBoolean ifTrue: [iter forwardToLineEnd].
	self gtkbuffer placeCursor: iter
    ]

    indexAt: point [
	"Answer the position of the character that covers the
	 pixel whose coordinates within the text's window are
	 given by the supplied Point object."

	<category: 'position & lines'>
	self 
	    tclEval: self connected , ' index @%1,%2'
	    with: point x printString
	    with: point y printString.
	^self parseResult
    ]

    lineAt: number [
	"Answer the number-th line of text in the widget"

	<category: 'position & lines'>
	| start end |
	start := self gtkbuffer getIterAtLine: number - 1.
	end := self gtkbuffer getIterAtLine: number - 1.
	end forwardToLineEnd.
	^start getVisibleText: end
    ]

    numberOfLines [
	"Answer the number of lines in the widget"

	<category: 'position & lines'>
	^self gtkbuffer getLineCount
    ]

    selectFrom: first to: last [
	"Select the text between the given endpoints.  The two endpoints
	 are Point objects in which both coordinates are 1-based: the
	 first line is line 1, and the first character in the first line
	 is character 1."

	<category: 'position & lines'>
	| bounds |
	bounds := self from: first to: last.
	self gtkbuffer selectRange: (bounds at: 1) bound: (bounds at: 2)
    ]

    setToEnd [
	"Move the insertion point to the end of the widget"

	<category: 'position & lines'>
	self tclEval: '
	%1 mark set insert end-1c
	%1 see end'
	    with: self connected
    ]

    addChild: child [
	<category: 'private'>
	self 
	    tclEval: '%1 window create end -window %2'
	    with: self connected
	    with: child container
    ]

    setAttributes: attr start: startTextIter end: endTextIter [
	<category: 'private'>
	| tags |
	tagInfo isNil ifTrue: [tagInfo := BTextTags new: self].
	tags := attr tags: tagInfo.
	tags do: 
		[:each | 
		self gtkbuffer 
		    applyTag: each
		    start: startTextIter
		    end: endTextIter]
    ]

    gtkbuffer [
	"answer the gtk text buffer"

	<category: 'private'>
	gtkbuffer isNil ifTrue: [self createWidget].
	^gtkbuffer
    ]

    onChanged: userData data: unused [
	<category: 'private'>
	self invokeCallback
    ]

    create [
	"initialise a Text widget"

	<category: 'private'>
	self connected: GTK.GtkTextView new.
	gtkbuffer := self connected getBuffer.
	self gtkbuffer 
	    connectSignal: 'changed'
	    to: self
	    selector: #onChanged:data:
	    userData: nil
    ]

    defineTag: name as: options [
	<category: 'private'>
	options class = String 
	    ifTrue: 
		[options printNl.
		0 unconverted defineTag call].
	"FIXME/TODO: use g_object_set_property and recreate createTag"
	self gtkbuffer createTag: name varargs: options
    ]

    destroyed [
	<category: 'private'>
	super destroyed.
	images isNil ifTrue: [^self].
	images do: [:name | self tclEval: 'image delete ' , name].
	images := nil
    ]

    from: aPoint to: endPoint [
	<category: 'private'>
	| start end |
	start := self gtkbuffer getIterAtLineOffset: aPoint y - 1
		    charOffset: aPoint x - 1.
	end := self gtkbuffer getIterAtLineOffset: endPoint y - 1
		    charOffset: endPoint x - 1.
	^
	{start.
	end}
    ]

    removeAttributesInside: range [
	<category: 'private'>
	| start end |
	start := range at: 1.
	end := range at: 2.
	self gtkbuffer removeAllTags: start end: end
    ]

    tag: name bind: event to: aSymbol of: anObject parameters: params [
	<category: 'private'>
	self 
	    bind: event
	    to: aSymbol
	    of: anObject
	    parameters: params
	    prefix: '%1 tag bind %2' % 
			{self connected.
			name}
    ]
]



BEventTarget subclass: BTextBindings [
    | list tagName |
    
    <comment: 'This object is used to assign event handlers to particular sections of
text in a BText widget.  To use it, you simply have to add event handlers
to it, and then create a BTextAttributes object that refers to it.'>
    <category: 'Graphics-Windows'>

    BTextBindings class >> new [
	"Create a new instance of the receiver."

	<category: 'instance creation'>
	^self basicNew initialize
    ]

    defineTagFor: aBText [
	<category: 'private - BTextTags protocol'>
	list do: [:each | each sendTo: aBText]
    ]

    tagName [
	<category: 'private - BTextTags protocol'>
	^tagName
    ]

    initialize [
	<category: 'private'>
	tagName := 'ev' , (Time millisecondClockValue printString: 36).
	list := OrderedCollection new
    ]

    primBind: event to: aSymbol of: anObject parameters: params [
	<category: 'private'>
	| args |
	(args := Array new: 5)
	    at: 1 put: tagName;
	    at: 2 put: event;
	    at: 3 put: aSymbol;
	    at: 4 put: anObject;
	    at: 5 put: params.
	list add: (Message selector: #tag:bind:to:of:parameters: arguments: args)
    ]
]



Object subclass: BTextAttributes [
    | bgColor fgColor font styles events |
    
    <category: 'Graphics-Windows'>
    <comment: '
I help you creating wonderful, colorful BTexts.'>

    BTextAttributes class >> backgroundColor: color [
	"Create a new BTextAttributes object resulting in text
	 with the given background color."

	<category: 'instance-creation shortcuts'>
	^self new backgroundColor: color
    ]

    BTextAttributes class >> black [
	"Create a new BTextAttributes object resulting in black text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'black'
    ]

    BTextAttributes class >> blue [
	"Create a new BTextAttributes object resulting in blue text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'blue'
    ]

    BTextAttributes class >> center [
	"Create a new BTextAttributes object resulting in centered
	 paragraphs."

	<category: 'instance-creation shortcuts'>
	^self new center
    ]

    BTextAttributes class >> cyan [
	"Create a new BTextAttributes object resulting in cyan text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'cyan'
    ]

    BTextAttributes class >> darkCyan [
	"Create a new BTextAttributes object resulting in dark cyan text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'PureDarkCyan'
    ]

    BTextAttributes class >> darkGreen [
	"Create a new BTextAttributes object resulting in dark green text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'PureDarkGreen'
    ]

    BTextAttributes class >> darkMagenta [
	"Create a new BTextAttributes object resulting in dark purple text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'PureDarkMagenta'
    ]

    BTextAttributes class >> events: aBTextBindings [
	"Create a new BTextAttributes object for text that responds to
	 events according to the callbacks established in aBTextBindings."

	<category: 'instance-creation shortcuts'>
	^self new events: aBTextBindings
    ]

    BTextAttributes class >> font: font [
	"Create a new BTextAttributes object resulting in text with the given font.
	 The font can be given as either an X font name or a Blox font description
	 string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'instance-creation shortcuts'>
	^self new font: font
    ]

    BTextAttributes class >> foregroundColor: color [
	"Create a new BTextAttributes object resulting in text
	 with the given foreground color."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: color
    ]

    BTextAttributes class >> green [
	"Create a new BTextAttributes object resulting in green text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'green'
    ]

    BTextAttributes class >> magenta [
	"Create a new BTextAttributes object resulting in magenta text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'magenta'
    ]

    BTextAttributes class >> red [
	"Create a new BTextAttributes object resulting in red text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'red'
    ]

    BTextAttributes class >> strikeout [
	"Create a new BTextAttributes object resulting in struck-out text."

	<category: 'instance-creation shortcuts'>
	^self new strikeout
    ]

    BTextAttributes class >> underline [
	"Create a new BTextAttributes object resulting in underlined text."

	<category: 'instance-creation shortcuts'>
	^self new underline
    ]

    BTextAttributes class >> yellow [
	"Create a new BTextAttributes object resulting in yellow text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'yellow'
    ]

    BTextAttributes class >> white [
	"Create a new BTextAttributes object resulting in white text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'white'
    ]

    black [
	"Set the receiver so that applying it results in black text."

	<category: 'colors'>
	self foregroundColor: 'black'
    ]

    blue [
	"Set the receiver so that applying it results in blue text."

	<category: 'colors'>
	self foregroundColor: 'blue'
    ]

    cyan [
	"Set the receiver so that applying it results in cyan text."

	<category: 'colors'>
	self foregroundColor: 'cyan'
    ]

    darkCyan [
	"Set the receiver so that applying it results in dark cyan text."

	<category: 'colors'>
	self foregroundColor: 'PureDarkCyan'
    ]

    darkGreen [
	"Set the receiver so that applying it results in dark green text."

	<category: 'colors'>
	self foregroundColor: 'PureDarkGreen'
    ]

    darkMagenta [
	"Set the receiver so that applying it results in dark magenta text."

	<category: 'colors'>
	self foregroundColor: 'PureDarkMagenta'
    ]

    green [
	"Set the receiver so that applying it results in green text."

	<category: 'colors'>
	self foregroundColor: 'green'
    ]

    magenta [
	"Set the receiver so that applying it results in magenta text."

	<category: 'colors'>
	self foregroundColor: 'magenta'
    ]

    red [
	"Set the receiver so that applying it results in red text."

	<category: 'colors'>
	self foregroundColor: 'red'
    ]

    white [
	"Set the receiver so that applying it results in white text."

	<category: 'colors'>
	self foregroundColor: 'white'
    ]

    yellow [
	"Set the receiver so that applying it results in black text."

	<category: 'colors'>
	self foregroundColor: 'yellow'
    ]

    hasStyle: aSymbol [
	<category: 'private'>
	^styles notNil and: [styles includes: aSymbol]
    ]

    style: aSymbol [
	<category: 'private'>
	styles isNil ifTrue: [styles := Set new].
	styles add: aSymbol
    ]

    tags: aBTextTags [
	<category: 'private'>
	| s tagTable |
	tagTable := aBTextTags tagTable.
	s := OrderedCollection new.
	fgColor isNil 
	    ifFalse: [s add: (tagTable lookup: (aBTextTags fgColor: fgColor))].
	bgColor isNil 
	    ifFalse: [s add: (tagTable lookup: (aBTextTags bgColor: bgColor))].
	font isNil ifFalse: [s add: (tagTable lookup: (aBTextTags font: font))].
	events isNil 
	    ifFalse: [s add: (tagTable lookup: (aBTextTags events: events))].
	styles isNil 
	    ifFalse: [styles do: [:each | s add: (tagTable lookup: each)]].
	^s
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the text.
	 
	 Specifies the background color to use when displaying text with
	 these attributes.  nil indicates that the default value is not
	 overridden."

	<category: 'setting attributes'>
	^bgColor
    ]

    backgroundColor: color [
	"Set the value of the backgroundColor option for the text.
	 
	 Specifies the background color to use when displaying text with
	 these attributes.  nil indicates that the default value is not
	 overridden."

	<category: 'setting attributes'>
	bgColor := color
    ]

    center [
	"Center the text to which these attributes are applied"

	<category: 'setting attributes'>
	self style: #STYLEcenter
    ]

    events [
	"Answer the event bindings which apply to text subject to these
	 attributes"

	<category: 'setting attributes'>
	^events
    ]

    events: aBTextBindings [
	"Set the event bindings which apply to text subject to these
	 attributes"

	<category: 'setting attributes'>
	events := aBTextBindings
    ]

    font [
	"Answer the value of the font option for the text.
	 The font can be given as either an X font name or a Blox font description
	 string, or nil if you want the widget's default font to apply.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'setting attributes'>
	^font
    ]

    font: fontName [
	"Set the value of the font option for the text.
	 The font can be given as either an X font name or a Blox font description
	 string, or nil if you want the widget's default font to apply.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'setting attributes'>
	font := fontName
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the text.
	 
	 Specifies the foreground color to use when displaying text with
	 these attributes.  nil indicates that the default value is not
	 overridden."

	<category: 'setting attributes'>
	^fgColor
    ]

    foregroundColor: color [
	"Set the value of the foregroundColor option for the text.
	 
	 Specifies the foreground color to use when displaying text with
	 these attributes.  nil indicates that the default value is not
	 overridden."

	<category: 'setting attributes'>
	fgColor := color
    ]

    isCentered [
	"Answer whether the text to which these attributes are applied
	 is centered"

	<category: 'setting attributes'>
	^self hasStyle: #STYLEcenter
    ]

    isStruckout [
	"Answer whether the text to which these attributes are applied
	 is struckout"

	<category: 'setting attributes'>
	^self hasStyle: #STYLEstrikeout
    ]

    isUnderlined [
	"Answer whether the text to which these attributes are applied
	 is underlined"

	<category: 'setting attributes'>
	^self hasStyle: #STYLEunderline
    ]

    strikeout [
	"Strike out the text to which these attributes are applied"

	<category: 'setting attributes'>
	self style: #STYLEstrikeout
    ]

    underline [
	"Underline the text to which these attributes are applied"

	<category: 'setting attributes'>
	self style: #STYLEunderline
    ]
]



Object subclass: BTextTags [
    | client tags |
    
    <category: 'Graphics-Windows'>
    <comment: 'I am a private class. I sit between a BText and BTextAttributes, helping
the latter in telling the former which attributes to use.'>

    BTextTags class >> new [
	<category: 'private - instance creation'>
	self shouldNotImplement
    ]

    BTextTags class >> new: client [
	<category: 'private - instance creation'>
	^super new initialize: client
    ]

    bgColor: color [
	<category: 'private - BTextAttributes protocol'>
	^'b_' , (self color: color)
    ]

    events: aBTextBindings [
	<category: 'private - BTextAttributes protocol'>
	| tagName |
	tagName := aBTextBindings tagName.
	(tags includes: tagName) 
	    ifFalse: 
		[tags add: tagName.
		aBTextBindings defineTagFor: client].
	^tagName
    ]

    fgColor: color [
	<category: 'private - BTextAttributes protocol'>
	^'f_' , (self color: color)
    ]

    font: font [
	<category: 'private - BTextAttributes protocol'>
	| tagName |
	tagName := WriteStream on: (String new: 20).
	font substrings do: 
		[:each | 
		tagName
		    nextPutAll: each;
		    nextPut: $_].
	tagName := tagName contents.
	(tags includes: tagName) 
	    ifFalse: 
		[tags add: tagName.
		'FIXME fonts.. ' display.
		font printNl.
		client defineTag: tagName
		    as: 
			{'font'.
			font.
			nil}].
	^tagName
    ]

    color: color [
	<category: 'private'>
	| tagName |
	tagName := (color at: 1) = $# 
		    ifTrue: 
			[(color copy)
			    at: 1 put: $_;
			    yourself]
		    ifFalse: [color asLowercase].
	(tags includes: tagName) 
	    ifFalse: 
		[tags add: tagName.
		client defineTag: 'f_' , tagName
		    as: 
			{'foreground'.
			color.
			nil}.
		client defineTag: 'b_' , tagName
		    as: 
			{'background'.
			color.
			nil}].
	^tagName
    ]

    initialize: clientBText [
	"initialise for use with clientBText"

	<category: 'private'>
	client := clientBText.
	tags := Set new.
	client defineTag: 'STYLEstrikeout'
	    as: 
		{'strikethrough'.
		true.
		nil}.
	client defineTag: 'STYLEunderline'
	    as: 
		{'underline'.
		GTK.Pango pangoUnderlineSingle.
		nil}.
	client defineTag: 'STYLEcenter'
	    as: 
		{'justification'.
		GTK.Gtk gtkJustifyCenter.
		nil}
    ]

    tagTable [
	<category: 'private'>
	^client gtkbuffer getTagTable
    ]
]



"-------------------------- BText class -----------------------------"



"-------------------------- BTextBindings class -----------------------------"



"-------------------------- BTextAttributes class -----------------------------"



"-------------------------- BTextTags class -----------------------------"

PK
     �Mh@��~�  �    Blox.stUT	 cqXO�XOux �  �  "======================================================================
|
|   Smalltalk Gtk-based GUI building blocks (loading script).
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992, 1994, 1995, 1999, 2000, 2001, 2002
| Free Software Foundation, Inc.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Eval [
    ObjectMemory addDependent: BLOX.Blox.
    BLOX.Blox update: #returnFromSnapshot
]

PK
     1[h@�x>�      package.xmlUT	 �XO�XOux �  �  <package>
  <name>BloxGTK</name>
  <namespace>BLOX</namespace>
  <provides>Blox</provides>
  <prereq>GTK</prereq>

  <filein>BloxBasic.st</filein>
  <filein>BloxWidgets.st</filein>
  <filein>BloxText.st</filein>
  <filein>BloxExtend.st</filein>
  <filein>Blox.st</filein>
</package>PK
     �Mh@���H �H   BloxBasic.stUT	 cqXO�XOux �  �  "======================================================================
|
|   Smalltalk GTK-based GUI building blocks (abstract classes).
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini and Robert Collins.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: Gui [
    | blox |
    
    <category: 'Graphics-Windows'>
    <comment: 'I am a small class which serves as a base for complex objects which
expose an individual protocol but internally use a Blox widget for
creating their user interface.'>

    blox [
	"Return instance of blox subclass which implements window"

	<category: 'accessing'>
	^blox
    ]

    blox: aBlox [
	"Set instance of blox subclass which implements window"

	<category: 'accessing'>
	blox := aBlox
    ]
]



Object subclass: BEventTarget [
    | eventReceivers |
    
    <category: 'Graphics-Windows'>
    <comment: 'I track all the event handling procedures that you apply to an object.'>

    addEventSet: aBEventSetSublass [
	"Add to the receiver the event handlers implemented by an instance of
	 aBEventSetSubclass. Answer the new instance of aBEventSetSublass."

	<category: 'intercepting events'>
	^self registerEventReceiver: (aBEventSetSublass new: self)
    ]

    onAsciiKeyEventSend: aSelector to: anObject [
	"When an ASCII key is pressed and the receiver has the focus, send
	 the 1-argument message identified by aSelector to anObject,
	 passing to it a Character."

	<category: 'intercepting events'>
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	^self 
	    bind: '<KeyPress>'
	    to: #sendKeyEvent:oop:selector:
	    of: self
	    parameters: '*%A* ' , anObject asOop printString , ' ' 
		    , aSelector asTkString
    ]

    onDestroySend: aSelector to: anObject [
	"When the receiver is destroyed, send the unary message identified
	 by aSelector to anObject."

	<category: 'intercepting events'>
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	self 
	    connectSignal: 'destroy'
	    to: 
		[:widget :data | 
		data key perform: data value.
		false]
	    selector: #value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onFocusEnterEventSend: aSelector to: anObject [
	"When the focus enters the receiver, send the unary message identified
	 by aSelector to anObject."

	<category: 'intercepting events'>
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	self 
	    connectSignal: 'focus-in-event'
	    to: 
		[:widget :ev :data | 
		data key perform: data value.
		false]
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onFocusLeaveEventSend: aSelector to: anObject [
	"When the focus leaves the receiver, send the unary message identified
	 by aSelector to anObject."

	<category: 'intercepting events'>
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	self 
	    connectSignal: 'focus-out-event'
	    to: 
		[:widget :ev :data | 
		data key perform: data value.
		false]
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onKeyEvent: key send: aSelector to: anObject [
	"When the given key is pressed and the receiver has the focus,
	 send the unary message identified by aSelector to anObject.
	 Examples for key are:  'Ctrl-1', 'Alt-X', 'Meta-plus', 'enter'.
	 The last two cases include example of special key identifiers;
	 these include: 'backslash', 'exclam', 'quotedbl', 'dollar',
	 'asterisk', 'less', 'greater', 'asciicircum' (caret), 'question',
	 'equal', 'parenleft', 'parenright', 'colon', 'semicolon', 'bar' (pipe
	 sign), 'underscore', 'percent', 'minus', 'plus', 'BackSpace', 'Delete',
	 'Insert', 'Return', 'End', 'Home', 'Prior' (Pgup), 'Next' (Pgdn),
	 'F1'..'F24', 'Caps_Lock', 'Num_Lock', 'Tab', 'Left', 'Right', 'Up',
	 'Down'.  There are in addition four special identifiers which map
	 to platform-specific keys: '<Cut>', '<Copy>', '<Paste>', '<Clear>'
	 (all with the angular brackets!)."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	'onKeyEvent TODO implement own collection and check in that..' printNl.
	block := 
		[:widget :event :userData | 
		"anObject perform: aSelector asSymbol."

		false].
	self 
	    connectSignal: 'key-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: nil

	"(self getKeyPressEventNames: key) do: [ :each |
	 self
	 bind: each
	 to: aSelector
	 of: anObject
	 parameters: ''
	 ]"
    ]

    onKeyEventSend: aSelector to: anObject [
	"When a key is pressed and the receiver has the focus, send the
	 1-argument message identified by aSelector to anObject. The pressed
	 key will be passed as a String parameter; some of the keys will
	 send special key identifiers such as those explained in the
	 documentation for #onKeyEvent:send:to: Look at the #eventTest
	 test program in the BloxTestSuite to find out the parameters
	 passed to such an event procedure"

	<category: 'intercepting events'>
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	^self 
	    bind: '<KeyPress>'
	    to: aSelector
	    of: anObject
	    parameters: '%K'
    ]

    onKeyUpEventSend: aSelector to: anObject [
	"When a key has been released and the receiver has the focus, send
	 the 1-argument message identified by aSelector to anObject. The
	 released key will be passed as a String parameter; some of the keys
	 will send special key identifiers such as those explained in the
	 documentation for #onKeyEvent:send:to: Look at the #eventTest
	 test program in the BloxTestSuite to find out the parameters
	 passed to such an event procedure"

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	'key up TODO implement Tk''s %K and pass it' printNl.
	block := 
		[:widget :event :userData | 
		userData key perform: userData value with: nil.
		false].
	self 
	    connectSignal: 'key-release-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseDoubleEvent: button send: aSelector to: anObject [
	"When the given button is double-clicked on the mouse, send the
	 1-argument message identified by aSelector to anObject. The
	 mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		(buttonEv button value = button 
		    and: [buttonEv type value = GTK.Gdk gdk2buttonPress]) 
			ifTrue: 
			    [userData key perform: userData value
				with: buttonEv x value @ buttonEv y value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseDoubleEventSend: aSelector to: anObject [
	"When a button is double-clicked on the mouse, send the 2-argument
	 message identified by aSelector to anObject. The mouse
	 position will be passed as a Point in the first parameter,
	 the button number will be passed as an Integer in the second
	 parameter."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 2 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		buttonEv type value = GTK.Gdk gdk2buttonPress 
		    ifTrue: 
			[userData key 
			    perform: userData value
			    with: buttonEv x value @ buttonEv y value
			    with: buttonEv button value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseDownEvent: button send: aSelector to: anObject [
	"When the given button is pressed on the mouse, send the
	 1-argument message identified by aSelector to anObject. The
	 mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		(buttonEv button value = button 
		    and: [buttonEv type value = GTK.Gdk gdkButtonPress]) 
			ifTrue: 
			    [userData key perform: userData value
				with: buttonEv x value @ buttonEv y value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseDownEventSend: aSelector to: anObject [
	"When a button is pressed on the mouse, send the 2-argument
	 message identified by aSelector to anObject. The mouse
	 position will be passed as a Point in the first parameter,
	 the button number will be passed as an Integer in the second
	 parameter."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 2 ifFalse: [^self invalidArgsError: '2'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		buttonEv type value = GTK.Gdk gdkButtonPress 
		    ifTrue: 
			[userData key 
			    perform: userData value
			    with: buttonEv x value @ buttonEv y value
			    with: buttonEv button value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseEnterEventSend: aSelector to: anObject [
	"When the mouse enters the widget, send the unary message
	 identified by aSelector to anObject."

	<category: 'intercepting events'>
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	self 
	    connectSignal: 'enter-notify-event'
	    to: 
		[:widget :ev :data | 
		data key perform: data value.
		false]
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseLeaveEventSend: aSelector to: anObject [
	"When the mouse leaves the widget, send the unary message
	 identified by aSelector to anObject."

	<category: 'intercepting events'>
	aSelector numArgs = 0 ifFalse: [^self invalidArgsError: '0'].
	self 
	    connectSignal: 'leave-notify-event'
	    to: 
		[:widget :ev :data | 
		data key perform: data value.
		false]
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseMoveEvent: button send: aSelector to: anObject [
	"When the mouse is moved while the given button is pressed
	 on the mouse, send the 1-argument message identified by aSelector
	 to anObject. The mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| modMask block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	modMask := GTK.Gdk gdkButton1Mask bitShift: button - 1.
	block := 
		[:widget :event :userData | 
		| motionEv |
		motionEv := event castTo: GTK.GdkEventMotion type.
		(motionEv state value anyMask: modMask) 
		    ifTrue: 
			[userData key perform: userData value
			    with: motionEv x value @ motionEv y value].
		false].
	self 
	    connectSignal: 'motion-notify-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseMoveEventSend: aSelector to: anObject [
	"When the mouse is moved, send the 1-argument message identified
	 by aSelector to anObject. The mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| motionEv |
		motionEv := event castTo: GTK.GdkEventMotion type.
		userData key perform: userData value
		    with: motionEv x value @ motionEv y value.
		false].
	self 
	    connectSignal: 'motion-notify-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseTripleEvent: button send: aSelector to: anObject [
	"When the given button is triple-clicked on the mouse, send the
	 1-argument message identified by aSelector to anObject. The
	 mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		(buttonEv button value = button 
		    and: [buttonEv type value = GTK.Gdk gdk3buttonPress]) 
			ifTrue: 
			    [userData key perform: userData value
				with: buttonEv x value @ buttonEv y value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseTripleEventSend: aSelector to: anObject [
	"When a button is triple-clicked on the mouse, send the 2-argument
	 message identified by aSelector to anObject. The mouse
	 position will be passed as a Point in the first parameter,
	 the button number will be passed as an Integer in the second
	 parameter."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 2 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		buttonEv type value = GTK.Gdk gdk3buttonPress 
		    ifTrue: 
			[userData key 
			    perform: userData value
			    with: buttonEv x value @ buttonEv y value
			    with: buttonEv button value].
		false].
	self 
	    connectSignal: 'button-press-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseUpEvent: button send: aSelector to: anObject [
	"When the given button is released on the mouse, send the
	 1-argument message identified by aSelector to anObject. The
	 mouse position will be passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '1'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		buttonEv button value = button 
		    ifTrue: 
			[userData key perform: userData value
			    with: buttonEv x value @ buttonEv y value].
		false].
	self 
	    connectSignal: 'button-release-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onMouseUpEventSend: aSelector to: anObject [
	"When a button is released on the mouse, send the 2-argument
	 message identified by aSelector to anObject. The mouse
	 position will be passed as a Point in the first parameter,
	 the button number will be passed as an Integer in the second
	 parameter."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 2 ifFalse: [^self invalidArgsError: '2'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| buttonEv |
		buttonEv := event castTo: GTK.GdkEventButton type.
		userData key 
		    perform: userData value
		    with: buttonEv x value @ buttonEv y value
		    with: buttonEv button value.
		false].
	self 
	    connectSignal: 'button-release-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    onResizeSend: aSelector to: anObject [
	"When the receiver is resized, send the 1-argument message
	 identified by aSelector to anObject. The new size will be
	 passed as a Point."

	<category: 'intercepting events'>
	| block |
	aSelector numArgs = 1 ifFalse: [^self invalidArgsError: '2'].
	self registerEventReceiver: anObject.
	block := 
		[:widget :event :userData | 
		| configEv |
		configEv := event castTo: GTK.GdkEventConfigure type.
		userData key perform: userData value
		    with: configEv x value @ configEv y value.
		false].
	self 
	    connectSignal: 'configure-event'
	    to: block
	    selector: #value:value:value:
	    userData: anObject -> aSelector asSymbol
    ]

    connectSignal: aString to: anObject selector: aSymbol userData: userData [
	<category: 'private'>
	self subclassResponsibility
    ]

    getKeyPressEventNames: key [
	"Private - Given the key passed to a key event installer method,
	 answer the KeyPress event name as required by Tcl."

	<category: 'private'>
	| platform mod keySym |
	keySym := key isCharacter ifTrue: [String with: key] ifFalse: [key].
	(keySym at: 1) = $< ifTrue: [^{'<' , keySym , '>'}].
	mod := ''.
	(keySym includes: $-) 
	    ifTrue: 
		[mod := (ReadStream on: key) next: (key findLast: [:each | each = $-]) - 1.
		keySym := key copyFrom: mod size + 2 to: key size.
		platform := Blox platform.
		mod := (mod substrings: $-) inject: ''
			    into: [:old :each | old , (self translateModifier: each platform: platform) , '-']].
	^(keySym size = 1 and: [keySym first isLetter]) 
	    ifTrue: 
		["Use both the lowercase and uppercase variants"

		
		{'<%1KeyPress-%2>' % 
			{mod.
			keySym asLowercase}.
		'<%1KeyPress-%2>' % 
			{mod.
			keySym asUppercase}}]
	    ifFalse: [{'<%1KeyPress-%2>' % 
			{mod.
			keySym}}]
    ]

    translateModifier: mod platform: platform [
	<category: 'private'>
	| name |
	name := mod.
	name = 'Meta' ifTrue: [name := 'Alt'].
	name = 'Alt' & (platform == #macintosh) ifTrue: [name := 'Option'].
	name = 'Control' & (platform == #macintosh) ifTrue: [name := 'Cmd'].
	^name
    ]

    invalidArgsError: expected [
	"Private - Raise an error (as one could expect...) What is not
	 so expected is that the expected argument is a string."

	<category: 'private'>
	^self error: 'invalid number of arguments, expected ' , expected
    ]

    primBind: event to: aSymbol of: anObject parameters: params [
	"Private - Register the given event, to be passed to anObject
	 via the aSymbol selector with the given parameters"

	<category: 'private'>
	self subclassResponsibility
    ]

    registerEventReceiver: anObject [
	"Private - Avoid that anObject is garbage collected as long as
	 the receiver exists."

	<category: 'private'>
	eventReceivers isNil ifTrue: [eventReceivers := IdentitySet new].
	^eventReceivers add: anObject
    ]

    sendKeyEvent: key oop: oop selector: sel [
	"Private - Filter ASCII events from Tcl to Smalltalk. We receive
	 either *{}* for a non-ASCII char or *A* for an ASCII char, where
	 A is the character. In the first case the event is eaten, in the
	 second it is passed to a Smalltalk method"

	"key printNl.
	 oop asInteger asObject printNl.
	 '---' printNl."

	<category: 'private'>
	key size = 3 
	    ifTrue: [oop asInteger asObject perform: sel asSymbol with: (key at: 2)]
    ]

    sendPointEvent: x y: y oop: oop selector: sel [
	"Private - Filter mouse events from Tcl to Smalltalk. We receive two
	 strings, we convert them to a Point and then pass them to a Smalltalk
	 method"

	"oop printNl.
	 oop asInteger asObject printNl.
	 '---' printNl."

	<category: 'private'>
	oop asInteger asObject perform: sel asSymbol
	    with: x asInteger @ y asInteger
    ]
]



BEventTarget subclass: BEventSet [
    | widget |
    
    <category: 'Graphics-Windows'>
    <comment: 'I combine event handlers and let you apply them to many objects.
Basically, you derive a class from me, override the #initialize:
method to establish the handlers, then use the #addEventSet: method
understood by every Blox class to add the event handlers specified
by the receiver to the object.'>

    BEventSet class >> new [
	<category: 'initializing'>
	self shouldNotImplement
    ]

    BEventSet class >> new: widget [
	"Private - Create a new event set object that will
	 attach to the given widget. Answer the object. Note: this
	 method should be called by #addEventSet:, not directly"

	<category: 'initializing'>
	^(self basicNew)
	    initialize: widget;
	    yourself
    ]

    widget [
	"Answer the widget to which the receiver is attached."

	<category: 'accessing'>
	^widget
    ]

    initialize: aBWidget [
	"Initialize the receiver's event handlers to attach to aBWidget.
	 You can override this of course, but don't forget to call the
	 superclass implementation first."

	<category: 'initializing'>
	widget := aBWidget
    ]

    connectSignal: aString to: anObject selector: aSymbol userData: userData [
	"Private - Register the given event, to be passed to anObject
	 via the aSymbol selector with the given parameters; this method
	 is simply forwarded to the attached widget"

	<category: 'private'>
	self widget 
	    connectSignal: aString
	    to: anObject
	    selector: aSymbol
	    userData: userData
    ]
]



BEventTarget subclass: Blox [
    | properties parent children |
    
    <category: 'Graphics-Windows'>
    <comment: 'I am the superclass for every visible user interface object (excluding
canvas items, which are pretty different). I provide common methods and
I expose class methods that do many interesting event-handling things.'>

    Platform := nil.
    ClipStatus := nil.
    DoDispatchEvents := nil.

    Blox class >> dispatchEvents [
	"If this is the outermost dispatching loop that is started,
	 dispatch events until the number of calls to #terminateMainLoop
	 balances the number of calls to #dispatchEvents; return
	 instantly if this is not the outermost dispatching loop that
	 is started."

	<category: 'event dispatching'>
	| clipboard sem |
	DoDispatchEvents := DoDispatchEvents + 1.
	DoDispatchEvents = 1 ifFalse: [^self].

	"If we're outside the event loop, Tk for Windows is unable to
	 render the clipboard and locks up the clipboard viewer app.
	 So, we save the contents for the next time we'll start a
	 message loop.  If the clipboard was temporarily saved to ClipStatus,
	 restore it.
	 
	 ClipStatus is:
	 - true if we own the clipboard
	 - false if we don't
	 - nil if we don't and we are outside a message loop
	 - a String if we do and we are outside a message loop"
	clipboard := ClipStatus.
	ClipStatus := ClipStatus notNil and: [ClipStatus notEmpty].
	ClipStatus ifTrue: [self clipboard: clipboard].
	GTK.Gtk main.

	"Save the contents of the clipboard if we own it."
	ClipStatus := ClipStatus ifTrue: [self clearClipboard] ifFalse: [nil]
    ]

    Blox class >> dispatchEvents: mainWindow [
	"Dispatch some events; return instantly if this is not the outermost
	 dispatching loop that is started, else loop until the number of calls
	 to #dispatchEvents balance the number of calls to #terminateMainLoop.
	 
	 In addition, set up an event handler that will call #terminateMainLoop
	 upon destruction of the `mainWindow' widget (which can be any kind of
	 BWidget, but will be typically a BWindow)."

	<category: 'event dispatching'>
	| sem |
	sem := Semaphore new.
	mainWindow onDestroySend: #signal to: sem.
	Blox dispatchEvents.
	sem wait.
	Blox terminateMainLoop
    ]

    Blox class >> terminateMainLoop [
	"Terminate the event dispatching loop if this call to #terminateMainLoop
	 balances the number of calls to #dispatchEvents. Answer whether the
	 calls are balanced."

	<category: 'event dispatching'>
	DoDispatchEvents := DoDispatchEvents - 1.
	DoDispatchEvents = 0 ifTrue: [GTK.Gtk mainQuit]
    ]

    Blox class >> update: aspect [
	"Initialize the Tcl and Blox environments; executed automatically
	 on startup."

	<category: 'event dispatching'>
	| initResult |
	aspect == #returnFromSnapshot ifFalse: [^self].
	GTK.Gtk gstGtkInit.
	DoDispatchEvents := 0.
	ClipStatus := nil.
	Blox withAllSubclassesDo: 
		[:each | 
		(each class includesSelector: #initializeOnStartup) 
		    ifTrue: [each initializeOnStartup]]
    ]

    Blox class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    Blox class >> new: parent [
	"Create a new widget of the type identified by the receiver, inside
	 the given parent widget. Answer the new widget"

	<category: 'instance creation'>
	^self basicNew initialize: parent
    ]

    Blox class >> cursorNames [
	<category: 'private'>
	^#(#X_cursor #arrow #based_arrow_down #based_arrow_up #boat #bogosity #bottom_left_corner #bottom_right_corner #bottom_side #bottom_tee #box_spiral #center_ptr #circle #clock #coffee_mug #cross #cross_reverse #crosshair #diamond_cross #dot #dotbox #double_arrow #draft_large #draft_small #draped_box #exchange #fleur #gobbler #gumby #hand1 #hand2 #heart #icon #iron_cross #left_ptr #left_side #left_tee #leftbutton #ll_angle #lr_angle #man #middlebutton #mouse #pencil #pirate #plus #question_arrow #right_ptr #right_side #right_tee #rightbutton #rtl_logo #sailboat #sb_down_arrow #sb_h_double_arrow #sb_left_arrow #sb_right_arrow #sb_up_arrow #sb_v_double_arrow #shuttle #sizing #spider #spraycan #star #target #tcross #top_left_arrow #top_left_corner #top_right_corner #top_side #top_tee #trek #ul_angle #umbrella #ur_angle #watch #xterm)
    ]

    Blox class >> cursorNameForType: type [
	<category: 'private'>
	^self cursorNames at: type // 2 + 1
    ]

    Blox class >> cursorTypeForName: name [
	<category: 'private'>
	^##(| names |
	names := IdentityDictionary new.
	Blox cursorNames with: (0 to: 152 by: 2)
	    do: [:name :type | names at: name put: type].
	names) at: name
    ]

    Blox class >> tclEval: tclCode [
	"Private - Evaluate the given Tcl code; if it raises an exception,
	 raise it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclEval: tclCode with: arg1 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1; if
	 it raises an exception, raise it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclEval: tclCode with: arg1 with: arg2 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1
	 and %2 with arg2; if it raises an exception, raise it as a
	 Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclEval: tclCode with: arg1 with: arg2 with: arg3 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1,
	 %2 with arg2 and %3 with arg3; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclEval: tclCode with: arg1 with: arg2 with: arg3 with: arg4 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1,
	 %2 with arg2, and so on; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclEval: tclCode withArguments: anArray [
	"Private - Evaluate the given Tcl code, replacing %n with the
	 n-th element of anArray; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> tclResult [
	"Private - Return the result code for Tcl, as a Smalltalk String."

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    Blox class >> active [
	"Answer the currently active Blox, or nil if the focus does not
	 belong to a Smalltalk window."

	<category: 'utility'>
	self tclEval: 'focus'.
	^self fromString: self tclResult
    ]

    Blox class >> at: aPoint [
	"Answer the Blox containing the given point on the screen, or
	 nil if no Blox contains the given point (either because
	 no Smalltalk window is there or because it is covered by
	 another window)."

	<category: 'utility'>
	self 
	    tclEval: 'winfo containing %1 %2'
	    with: aPoint x printString
	    with: aPoint y printString.
	^self fromString: self tclResult
    ]

    Blox class >> atMouse [
	"Answer the Blox under the mouse cursor's hot spot, or nil
	 if no Blox contains the given point (either because no
	 Smalltalk window is there or because it is covered by
	 another window)."

	<category: 'utility'>
	self tclEval: 'eval winfo containing [winfo pointerxy .]'.
	^self fromString: self tclResult
    ]

    Blox class >> beep [
	"Produce a bell"

	<category: 'utility'>
	GTK.Gdk beep
    ]

    Blox class >> clearClipboard [
	"Clear the clipboard, answer its old contents."

	<category: 'utility'>
	| contents |
	contents := self clipboard.
	self tclEval: 'clipboard clear'.
	ClipStatus isString ifTrue: [ClipStatus := nil].
	ClipStatus == true ifTrue: [ClipStatus := false].
	^contents
    ]

    Blox class >> clipboard [
	"Retrieve the text in the clipboard."

	<category: 'utility'>
	self 
	    tclEval: '
	if { [catch { selection get -selection CLIPBOARD } clipboard] } {
	  return ""
	} else {
	  return $clipboard
	}'.
	^self tclResult
    ]

    Blox class >> clipboard: aString [
	"Set the contents of the clipboard to aString (or empty the clipboard
	 if aString is nil)."

	<category: 'utility'>
	self clearClipboard.
	(aString isNil or: [aString isEmpty]) ifTrue: [^self].
	ClipStatus isNil 
	    ifTrue: 
		[ClipStatus := aString.
		^self].
	self tclEval: 'clipboard append -- ' , aString asTkString.
	ClipStatus := true
    ]

    Blox class >> createColor: red green: green blue: blue [
	"Answer a color that can be passed to methods such as `backgroundColor:'.
	 The color will have the given RGB components (range is 0~65535)."

	"The answer is actually a String with an X color name, like
	 '#FFFFC000C000' for pink"

	<category: 'utility'>
	^(String new: 13)
	    at: 1 put: $#;
	    at: 2 put: (Character digitValue: ((red bitShift: -12) bitAnd: 15));
	    at: 3 put: (Character digitValue: ((red bitShift: -8) bitAnd: 15));
	    at: 4 put: (Character digitValue: ((red bitShift: -4) bitAnd: 15));
	    at: 5 put: (Character digitValue: (red bitAnd: 15));
	    at: 6 put: (Character digitValue: ((green bitShift: -12) bitAnd: 15));
	    at: 7 put: (Character digitValue: ((green bitShift: -8) bitAnd: 15));
	    at: 8 put: (Character digitValue: ((green bitShift: -4) bitAnd: 15));
	    at: 9 put: (Character digitValue: (green bitAnd: 15));
	    at: 10 put: (Character digitValue: ((blue bitShift: -12) bitAnd: 15));
	    at: 11 put: (Character digitValue: ((blue bitShift: -8) bitAnd: 15));
	    at: 12 put: (Character digitValue: ((blue bitShift: -4) bitAnd: 15));
	    at: 13 put: (Character digitValue: (blue bitAnd: 15));
	    yourself
    ]

    Blox class >> createColor: cyan magenta: magenta yellow: yellow [
	"Answer a color that can be passed to methods such as `backgroundColor:'.
	 The color will have the given CMY components (range is 0~65535)."

	<category: 'utility'>
	^self 
	    createColor: 65535 - cyan
	    green: 65535 - magenta
	    blue: 65535 - yellow
    ]

    Blox class >> createColor: cyan magenta: magenta yellow: yellow black: black [
	"Answer a color that can be passed to methods such as `backgroundColor:'.
	 The color will have the given CMYK components (range is 0~65535)."

	<category: 'utility'>
	| base |
	base := 65535 - black.
	^self 
	    createColor: (base - cyan max: 0)
	    green: (base - magenta max: 0)
	    blue: (base - yellow max: 0)
    ]

    Blox class >> createColor: hue saturation: sat value: value [
	"Answer a color that can be passed to methods such as `backgroundColor:'.
	 The color will have the given HSV components (range is 0~65535)."

	<category: 'utility'>
	| hue6 f val index components |
	hue6 := hue \\ 1 * 6.
	index := hue6 integerPart + 1.	"Which of the six slices of the hue circle"
	f := hue6 fractionPart.	"Where in the slice of the hue circle"
	val := 65535 * value.
	components := Array 
		    with: val
		    with: val * (1 - sat)
		    with: val * (1 - (sat * f))
		    with: val * (1 - (sat * (1 - f))).	"v"	"p"	"q"	"t"
	^self 
	    createColor: (components at: (#(1 3 2 2 4 1) at: index)) floor
	    green: (components at: (#(4 1 1 3 2 2) at: index)) floor
	    blue: (components at: (#(2 2 4 1 1 3) at: index)) floor
    ]

    Blox class >> fonts [
	"Answer the names of the font families in the system. Additionally,
	 `Times', `Courier' and `Helvetica' are always made available."

	<category: 'utility'>
	| stream result font ch |
	self tclEval: 'lsort [font families]'.
	stream := ReadStream on: self tclResult.
	result := WriteStream on: (Array new: stream size // 10).
	[stream atEnd] whileFalse: 
		[(ch := stream next) isSeparator 
		    ifFalse: 
			[ch = ${ 
			    ifTrue: [font := stream upTo: $}]
			    ifFalse: [font := ch asString , (stream upTo: $ )].
			result nextPut: font]].
	^result contents
    ]

    Blox class >> mousePointer [
	"If the mouse pointer is on the same screen as the application's windows,
	 returns a Point containing the pointer's x and y coordinates measured
	 in pixels in the screen's root window (under X, if a virtual root window
	 is in use on the screen, the position is computed in the whole desktop,
	 not relative to the top-left corner of the currently shown portion).
	 If the mouse pointer isn't on the same screen as window then answer nil."

	<category: 'utility'>
	| x y |
	x := CIntType gcNew.
	y := CIntType gcNew.
	GdkDisplay getDefault 
	    getPointer: nil
	    x: x
	    y: y
	    mask: nil.
	^x value @ y value.
    ]

    Blox class >> platform [
	"Answer the platform on which Blox is running; it can be either
	 #unix, #macintosh or #windows."

	<category: 'utility'>
	(Features includes: #WIN32) ifTrue: [^#windows].
	^#unix
    ]

    Blox class >> screenOrigin [
	"Answer a Point indicating the coordinates of the upper left point of the
	 screen in the virtual root window on which the application's windows are
	 drawn (under Windows and the Macintosh, that's always 0 @ 0)"

	<category: 'utility'>
	| x y |
	x := CIntType gcNew.
	y := CIntType gcNew.
	Gdk getDefaultRootWindow getOrigin: x y: y.
	^x value negated @ y value negated.
    ]

    Blox class >> screenResolution [
	"Answer a Point containing the resolution in dots per inch of the screen,
	 in the x and y directions."

	<category: 'utility'>
	| screen |
	screen := GdkScreen getDefault.
	^(screen getWidth * 25.4 / screen getWidthMm) 
	    @ (screen getHeight * 25.4 / screen getHeightMm)
    ]

    Blox class >> screenSize [
	"Answer a Point containing the size of the virtual root window on which the
	 application's windows are drawn (under Windows and the Macintosh, that's
	 the size of the screen)"

	<category: 'utility'>
	| height width |
	width := CIntType gcNew.
	height := CIntType gcNew.
	Gdk getDefaultRootWindow getSize: width height: height.
	^width value @ height value
    ]

    state [
	"Answer the value of the state option for the widget.
	 
	 Specifies one of three states for the button: normal, active, or disabled.
	 In normal state the button is displayed using the foreground and background
	 options. The active state is typically used when the pointer is over the
	 button. In active state the button is displayed using the activeForeground
	 and activeBackground options. Disabled state means that the button should
	 be insensitive: the application will refuse to activate the widget and
	 will ignore mouse button presses."

	<category: 'accessing'>
	| state |
	state := self connected getState.
	state = Gtk gtkStateActive ifTrue: [^#active].
	state = Gtk gtkStateInsensitive ifTrue: [^#disabled].
	state = Gtk gtkStateSelected ifTrue: [^#active].
	state = Gtk gtkStatePrelight ifTrue: [^#normal].
	^#normal
    ]

    state: value [
	"Set the value of the state option for the widget.
	 
	 Specifies one of three states for the button: normal, active, or disabled.
	 In normal state the button is displayed using the foreground and background
	 options. The active state is typically used when the pointer is over the
	 button. In active state the button is displayed using the activeForeground
	 and activeBackground options. Disabled state means that the button should
	 be insensitive: the application will refuse to activate the widget and
	 will ignore mouse button presses."

	<category: 'accessing'>
	| state |
	self state = value ifTrue: [^self].
	value = #disabled 
	    ifTrue: [self connected setSensitive: false]
	    ifFalse: 
		[value = #active 
		    ifTrue: [self connected setState: Gtk gtkStateActive]
		    ifFalse: 
			[value = #normal 
			    ifTrue: [self connected setState: Gtk gtkStateNormal]
			    ifFalse: [self error: 'invalid state value']]]
    ]

    deepCopy [
	"It does not make sense to make a copy, because it would
	 make data inconsistent across different objects; so answer
	 the receiver"

	<category: 'basic'>
	^self
    ]

    release [
	"Destroy the receiver if it still exists, then perform the
	 usual task of removing the dependency links"

	<category: 'basic'>
	self connected destroy.
	super release
    ]

    shallowCopy [
	"It does not make sense to make a copy, because it would
	 make data inconsistent across different objects; so answer
	 the receiver"

	<category: 'basic'>
	^self
    ]

    make: array [
	"Create children of the receiver. Answer a Dictionary of the children.
	 Each element of array is an Array including: a string which becomes
	 the Dictionary's key, a binding like #{Blox.BWindow} identifying the
	 class name, an array with the parameters to be set (for example
	 #(#width: 50 #height: 30 #backgroundColor: 'blue')), and afterwards
	 the children of the widget, described as arrays with this same format."

	<category: 'creating children'>
	^self make: array on: LookupTable new
    ]

    make: array on: result [
	"Private - Create children of the receiver, adding them to result;
	 answer result. array has the format described in the comment to #make:"

	<category: 'creating children'>
	array do: [:each | self makeChild: each on: result].
	^result
    ]

    makeChild: each on: result [
	"Private - Create a child of the receiver, adding them to result;
	 each is a single element of the array described in the comment to #make:"

	<category: 'creating children'>
	| current selector |
	current := result at: (each at: 1) put: ((each at: 2) value new: self).
	each at: 3
	    do: 
		[:param | 
		selector isNil 
		    ifTrue: [selector := param]
		    ifFalse: 
			[current perform: selector with: param.
			selector := nil]].
	each size > 3 ifFalse: [^result].
	each 
	    from: 4
	    to: each size
	    do: [:child | current makeChild: child on: result]
    ]

    addChild: child [
	"The widget identified by child has been added to the receiver.
	 This method is public not because you can call it, but because
	 it can be useful to override it to perform some initialization
	 on the children as they are added. Answer the new child."

	<category: 'customization'>
	
    ]

    basicAddChild: child [
	"The widget identified by child has been added to the receiver.
	 Add it to the children collection and answer the new child.
	 This method does nothing but is present for compatibility
	 with Tk."

	<category: 'customization'>
	
    ]

    primAddChild: child [
	"The widget identified by child has been added to the receiver.
	 Add it to the children collection and answer the new child."

	<category: 'customization'>
	^children addLast: child
    ]

    connected [
	"Private - Answer the name of Tk widget for the connected widget.
	 This widget is used for most options and for event binding."

	<category: 'private'>
	^self asPrimitiveWidget connected
    ]

    container [
	"Private - Answer the name of Tk widget for the container widget.
	 This widget is used for geometry management."

	<category: 'private'>
	^self asPrimitiveWidget connected
    ]

    destroyed [
	"Private - The receiver has been destroyed, clear the instance
	 variables to release some memory."

	<category: 'private'>
	children := parent := nil
    ]

    initialize: parentWidget [
	"This is called by #new: to initialize the widget (as the name
	 says...). The default implementation initializes the receiver's
	 instance variables. This method is public not because you can
	 call it, but because it might be useful to override it. Always
	 answer the receiver."

	<category: 'private'>
	parent := parentWidget.
	properties := IdentityDictionary new.
	children := OrderedCollection new.
	self parent isNil ifFalse: [self parent primAddChild: self]
    ]

    connectSignal: aString to: anObject selector: aSymbol userData: userData [
	<category: 'private'>
	self asPrimitiveWidget connected 
	    connectSignal: aString
	    to: anObject
	    selector: aSymbol
	    userData: userData
    ]

    properties [
	"Private - Answer the properties dictionary"

	<category: 'private'>
	^properties
    ]

    tclEval: tclCode [
	"Private - Evaluate the given Tcl code; if it raises an exception,
	 raise it as a Smalltalk error"

	<category: 'private - Tcl'>
	stdout
	    nextPutAll: tclCode;
	    nl;
	    flush.
	self notYetImplemented
    ]

    tclEval: tclCode with: arg1 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1; if
	 it raises an exception, raise it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    tclEval: tclCode with: arg1 with: arg2 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1
	 and %2 with arg2; if it raises an exception, raise it as a
	 Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    tclEval: tclCode with: arg1 with: arg2 with: arg3 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1,
	 %2 with arg2 and %3 with arg3; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    tclEval: tclCode with: arg1 with: arg2 with: arg3 with: arg4 [
	"Private - Evaluate the given Tcl code, replacing %1 with arg1,
	 %2 with arg2, and so on; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    tclEval: tclCode withArguments: anArray [
	"Private - Evaluate the given Tcl code, replacing %n with the
	 n-th element of anArray; if it raises an exception, raise
	 it as a Smalltalk error"

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    tclResult [
	"Private - Return the result code for Tcl, as a Smalltalk String."

	<category: 'private - Tcl'>
	self notYetImplemented
    ]

    asPrimitiveWidget [
	"Answer the primitive widget that implements the receiver."

	<category: 'widget protocol'>
	self subclassResponsibility
    ]

    childrenCount [
	"Answer how many children the receiver has"

	<category: 'widget protocol'>
	^children size
    ]

    childrenDo: aBlock [
	"Evaluate aBlock once for each of the receiver's child widgets, passing
	 the widget to aBlock as a parameter"

	<category: 'widget protocol'>
	children do: aBlock
    ]

    destroy [
	"Destroy the receiver"

	<category: 'widget protocol'>
	self container destroy
    ]

    drawingArea [
	"Answer a Rectangle identifying the receiver's drawing area.  The
	 rectangle's corners specify the upper-left and lower-right corners
	 of the client area.  Because coordinates are relative to the
	 upper-left corner of a window's drawing area, the coordinates of
	 the rectangle's corner are (0,0)."

	<category: 'widget protocol'>
	^0 @ 0 corner: self widthAbsolute @ self heightAbsolute
    ]

    enabled [
	"Answer whether the receiver is enabled to input. Although defined
	 here, this method is only used for widgets that define a
	 #state method"

	<category: 'widget protocol'>
	^self state ~= #disabled
    ]

    enabled: enabled [
	"Set whether the receiver is enabled to input (enabled is a boolean).
	 Although defined here, this method is only used for widgets that
	 define a #state: method"

	<category: 'widget protocol'>
	self state: (enabled ifTrue: [#normal] ifFalse: [#disabled])
    ]

    exists [
	"Answer whether the receiver has been destroyed or not (answer false
	 in the former case, true in the latter)."

	<category: 'widget protocol'>
	^self asPrimitiveWidget exists
    ]

    fontHeight: aString [
	"Answer the height of aString in pixels, when displayed in the same
	 font as the receiver.  Although defined here, this method is only
	 used for widgets that define a #font method"

	<category: 'widget protocol'>
	self tclEval: 'font metrics %1 -linespace' with: self font asTkString.
	^((aString occurrencesOf: Character nl) + 1) * self tclResult asNumber
    ]

    fontWidth: aString [
	"Answer the width of aString in pixels, when displayed in the same
	 font as the receiver.  Although defined here, this method is only
	 used for widgets that define a #font method"

	<category: 'widget protocol'>
	self 
	    tclEval: 'font measure %1 %2'
	    with: self font asTkString
	    with: aString asTkString.
	^self tclResult asNumber
    ]

    isWindow [
	"Answer whether the receiver represents a window on the screen."

	<category: 'widget protocol'>
	^false
    ]

    parent [
	"Answer the receiver's parent (or nil for a top-level window)."

	<category: 'widget protocol'>
	^parent
    ]

    toplevel [
	"Answer the top-level object (typically a BWindow or BPopupWindow)
	 connected to the receiver."

	<category: 'widget protocol'>
	self parent isNil ifTrue: [^self].
	^self parent toplevel
    ]

    window [
	"Answer the window in which the receiver stays. Note that while
	 #toplevel won't answer a BTransientWindow, this method will."

	<category: 'widget protocol'>
	^self parent window
    ]

    withChildrenDo: aBlock [
	"Evaluate aBlock passing the receiver, and then once for each of the
	 receiver's child widgets."

	<category: 'widget protocol'>
	self value: aBlock.
	self childrenDo: aBlock
    ]
]



Blox subclass: BWidget [
    | connected |
    
    <category: 'Graphics-Windows'>
    <comment: 'I am the superclass for every widget except those related to
menus. I provide more common methods and geometry management'>

    BWidget class >> new [
	"Create an instance of the receiver inside a BPopupWindow; do
	 not map the window, answer the new widget.  The created widget
	 will become a child of the window and be completely attached
	 to it (e.g. the geometry methods will modify the window's geometry).
	 Note that while the widget *seems* to be directly painted on
	 the root window, it actually belongs to the BPopupWindow; so
	 don't send #destroy to the widget to remove it, but rather
	 to the window."

	<category: 'popups'>
	^self new: BPopupWindow new
    ]

    BWidget class >> popup: initializationBlock [
	"Create an instance of the receiver inside a BPopupWindow; before
	 returning, pass the widget to the supplied initializationBlock,
	 then map the window.  Answer the new widget.  The created widget
	 will become a child of the window and be completely attached
	 to it (e.g. the geometry methods will modify the window's geometry).
	 Note that while the widget *seems* to be directly painted on
	 the root window, it actually belongs to the BPopupWindow; so
	 don't send #destroy to the widget to remove it, but rather
	 to the window."

	<category: 'popups'>
	| widget window |
	window := BPopupWindow new.
	widget := self new: window.
	initializationBlock value: widget.
	window map.
	^widget
    ]

    borderWidth [
	"Answer the value of the borderWidth option for the widget.
	 
	 Specifies a non-negative value indicating the width of the 3-D border to
	 draw around the outside of the widget (if such a border is being drawn; the
	 effect option typically determines this). The value may also be used when
	 drawing 3-D effects in the interior of the widget. The value is measured in
	 pixels."

	<category: 'accessing'>
	self properties at: #border ifPresent: [:value | ^value].
	self 
	    tclEval: '%2 cget -borderwidth'
	    with: self connected
	    with: self container.
	^self properties at: #border put: self tclResult asInteger
    ]

    borderWidth: value [
	"Set the value of the borderWidth option for the widget.
	 
	 Specifies a non-negative value indicating the width of the 3-D border to
	 draw around the outside of the widget (if such a border is being drawn; the
	 effect option typically determines this). The value may also be used when
	 drawing 3-D effects in the interior of the widget. The value is measured in
	 pixels."

	<category: 'accessing'>
	self 
	    tclEval: '%2 configure -borderwidth %3'
	    with: self connected
	    with: self container
	    with: value printString asTkString.
	self properties at: #border put: value
    ]

    cursor [
	"Answer the value of the cursor option for the widget.
	 
	 Specifies the mouse cursor to be used for the widget. The value of the
	 option is given by the standard X cursor cursor, i.e., any of
	 the names defined in cursorcursor.h, without the leading XC_."

	<category: 'accessing'>
	self properties at: #cursor ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -cursor'
	    with: self connected
	    with: self container.
	^self properties at: #cursor put: self tclResult asSymbol
    ]

    cursor: value [
	"Set the value of the cursor option for the widget.
	 
	 Specifies the mouse cursor to be used for the widget. The value of the
	 option is given by the standard X cursor cursor, i.e., any of
	 the names defined in cursorcursor.h, without the leading XC_."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -cursor %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #cursor put: value
    ]

    effect [
	"Answer the value of the effect option for the widget.
	 
	 Specifies the effect desired for the widget's border. Acceptable values are
	 raised, sunken, flat, ridge, solid, and groove. The value indicates how the
	 interior of the widget should appear relative to its exterior; for example,
	 raised means the interior of the widget should appear to protrude from the
	 screen, relative to the exterior of the widget. Raised and sunken give the
	 traditional 3-D appearance (for example, that of Xaw3D), while ridge and groove
	 give a ``chiseled'' appearance like that of Swing or GTK+'s Metal theme. Flat
	 and solid are not 3-D."

	<category: 'accessing'>
	self properties at: #effect ifPresent: [:value | ^value].
	self 
	    tclEval: '%2 cget -relief'
	    with: self connected
	    with: self container.
	^self properties at: #effect put: self tclResult asSymbol
    ]

    effect: value [
	"Set the value of the effect option for the widget.
	 
	 Specifies the effect desired for the widget's border. Acceptable values are
	 raised, sunken, flat, ridge, solid, and groove. The value indicates how the
	 interior of the widget should appear relative to its exterior; for example,
	 raised means the interior of the widget should appear to protrude from the
	 screen, relative to the exterior of the widget. Raised and sunken give the
	 traditional 3-D appearance (for example, that of Xaw3D), while ridge and groove
	 give a ``chiseled'' appearance like that of Swing or GTK+'s Metal theme. Flat
	 and solid are not 3-D."

	<category: 'accessing'>
	self 
	    tclEval: '%2 configure -relief %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #effect put: value
    ]

    tabStop [
	"Answer the value of the tabStop option for the widget.
	 
	 Determines whether the window accepts the focus during keyboard traversal
	 (e.g., Tab and Shift-Tab). Before setting the focus to a window, Blox
	 consults the value of the tabStop option. A value of false
	 means that the window should be skipped entirely during keyboard traversal.
	 true means that the window should receive the input focus as long as it is
	 viewable (it and all of its ancestors are mapped). If you do not set this
	 option, Blox makes the decision about whether or
	 not to focus on the window: the current algorithm is to skip the window if
	 it is disabled, it has no key bindings, or if it is not viewable. Of the
	 standard widgets, BForm, BContainer, BLabel and BImage have no key bindings
	 by default."

	<category: 'accessing'>
	self properties at: #takefocus ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -takefocus'
	    with: self connected
	    with: self container.
	^self properties at: #takefocus put: self tclResult == '1'
    ]

    tabStop: value [
	"Set the value of the tabStop option for the widget.
	 
	 Determines whether the window accepts the focus during keyboard traversal
	 (e.g., Tab and Shift-Tab). Before setting the focus to a window, Blox
	 consults the value of the tabStop option. A value of false
	 means that the window should be skipped entirely during keyboard traversal.
	 true means that the window should receive the input focus as long as it is
	 viewable (it and all of its ancestors are mapped). If you do not set this
	 option, Blox makes the decision about whether or
	 not to focus on the window: the current algorithm is to skip the window if
	 it is disabled, it has no key bindings, or if it is not viewable. Of the
	 standard widgets, BForm, BContainer, BLabel and BImage have no key bindings
	 by default."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -takefocus %3'
	    with: self connected
	    with: self container
	    with: value asCBooleanValue printString asTkString.
	self properties at: #takefocus put: value
    ]

    create [
	"Make the receiver able to respond to its widget protocol.
	 This method is public not because you can call it, but because
	 it can be useful to override it, not forgetting the call to
	 super, to perform some initialization on the primitive
	 widget just created; for an example of this, see the
	 implementation of BButtonLike."

	<category: 'customization'>
	self subclassResponsibility
    ]

    onDestroy: object data: data [
	<category: 'customization'>
	self destroyed
    ]

    setInitialSize [
	"This is called by #createWidget to set the widget's initial size.
	 The whole area is occupied by default. This method is public
	 not because you can call it, but because it can be useful to
	 override it."

	<category: 'customization'>
	
    ]

    container [
	"The outermost object implementing this widget is the same as the innermost
	 object, by default (the exception being mostly BViewport and subclasses)."

	<category: 'customization'>
	^self connected
    ]

    activate [
	"At any given time, one window on each display is designated
	 as the focus window; any key press or key release events for
	 the display are sent to that window. This method allows one
	 to choose which window will have the focus in the receiver's
	 display
	 
	 If the application currently has the input focus on the receiver's
	 display, this method resets the input focus for the receiver's
	 display to the receiver. If the application doesn't currently have the
	 input focus on the receiver's display, Blox will remember the receiver
	 as the focus for its top-level; the next time the focus arrives at the
	 top-level, it will be redirected to the receiver (this is because
	 most window managers will set the focus only to top-level windows,
	 leaving it up to the application to redirect the focus among the
	 children of the top-level)."

	<category: 'widget protocol'>
	self connected grabFocus
    ]

    activateNext [
	"Activate the next widget in the focus `tabbing' order.  The focus
	 order depends on the widget creation order; you can set which widgets
	 are in the order with the #tabStop: method."

	<category: 'widget protocol'>
	self tclEval: 'focus [ tk_focusNext %1 ]' with: self connected
    ]

    activatePrevious [
	"Activate the previous widget in the focus `tabbing' order.  The focus
	 order depends on the widget creation order; you can set which widgets
	 are in the order with the #tabStop: method."

	<category: 'widget protocol'>
	self tclEval: 'focus [ tk_focusPrev %1 ]' with: self connected
    ]

    bringToTop [
	"Raise the receiver so that it is above all of its siblings in the
	 widgets' z-order; the receiver will not be obscured by any siblings and
	 will obscure any siblings that overlap it."

	<category: 'widget protocol'>
	| w |
	w := self connected getWindow.
	w isNil ifTrue: [w := self container getWindow].
	w isNil ifFalse: [^w raise]
    ]

    sendToBack [
	"Lower the receiver so that it is below all of its siblings in the
	 widgets' z-order; the receiver will be obscured by any siblings that
	 overlap it and will not obscure any siblings."

	<category: 'widget protocol'>
	| w |
	w := self connected getWindow.
	w isNil ifTrue: [w := self container getWindow].
	w isNil ifFalse: [^w lower]
    ]

    isActive [
	"Return whether the receiver is the window that currently owns the focus
	 on its display."

	<category: 'widget protocol'>
	^(self connected flags bitAnd: Gtk gtkHasFocus) > 0
    ]

    boundingBox [
	"Answer a Rectangle containing the bounding box of the receiver"

	<category: 'geometry management'>
	^self x @ self y extent: self width @ self height
    ]

    boundingBox: rect [
	"Set the bounding box of the receiver to rect (a Rectangle)."

	<category: 'geometry management'>
	self 
	    left: rect left
	    top: rect top
	    right: rect right
	    bottom: rect bottom
    ]

    extent [
	"Answer a Point containing the receiver's size"

	<category: 'geometry management'>
	^self width @ self height
    ]

    extent: extent [
	"Set the receiver's size to the width and height contained in extent
	 (a Point)."

	<category: 'geometry management'>
	self width: extent x height: extent y
    ]

    height [
	"Answer the `variable' part of the receiver's height within the parent
	 widget. The value returned does not include any fixed amount of
	 pixels indicated by #heightOffset: and must be interpreted in a relative
	 fashion: the ratio of the returned value to the current size of the
	 parent will be preserved upon resize. This apparently complicated
	 method is known as `rubber sheet' geometry management.  Behavior
	 if the left or right edges are not within the client area of the
	 parent is not defined -- the window might be clamped or might be
	 positioned according to the specification."

	<category: 'geometry management'>
	^self parent heightChild: self
    ]

    height: value [
	"Set to `value' the height of the widget within the parent widget. The
	 value is specified in a relative fashion as an integer, so that the
	 ratio of `value' to the current size of the parent will be
	 preserved upon resize. This apparently complicated method is known
	 as `rubber sheet' geometry management."

	<category: 'geometry management'>
	self parent child: self height: value
    ]

    heightAbsolute [
	"Force a recalculation of the layout of widgets in the receiver's
	 parent, then answer the current height of the receiver in pixels."

	<category: 'geometry management'>
	| h |
	h := self container getAllocation height.
	^h = -1 ifTrue: [self height] ifFalse: [h]
    ]

    heightOffset [
	"Private - Answer the pixels to be added or subtracted to the height
	 of the receiver, with respect to the value set in a relative fashion
	 through the #height: method."

	<category: 'geometry management'>
	^self properties at: #heightGeomOfs ifAbsent: [0]
    ]

    heightOffset: value [
	"Add or subtract to the height of the receiver a fixed amount of `value'
	 pixels, with respect to the value set in a relative fashion through
	 the #height: method.  Usage of this method is deprecated; use #inset:
	 and BContainers instead."

	<category: 'geometry management'>
	self properties at: #heightGeomOfs put: value.
	self parent child: self heightOffset: value
    ]

    heightPixels: value [
	"Set the current height of the receiver to `value' pixels. Note that,
	 after calling this method, #height will answer 0, which is logical
	 considering that there is no `variable' part of the size (refer
	 to #height and #height: for more explanations)."

	<category: 'geometry management'>
	self
	    height: 0;
	    heightOffset: value
    ]

    inset: pixels [
	"Inset the receiver's bounding box by the specified amount."

	<category: 'geometry management'>
	self parent child: self inset: pixels
    ]

    left: left top: top right: right bottom: bottom [
	"Set the bounding box of the receiver through its components."

	<category: 'geometry management'>
	self 
	    x: left
	    y: top
	    width: right - left + 1
	    height: bottom - top + 1
    ]

    pos: position [
	"Set the receiver's origin to the width and height contained in position
	 (a Point)."

	<category: 'geometry management'>
	self x: position x y: position y
    ]

    posHoriz: aBlox [
	"Position the receiver immediately to the right of aBlox."

	<category: 'geometry management'>
	| x width |
	width := aBlox width.
	self x: width + aBlox x y: aBlox y.
	width = 0 
	    ifTrue: 
		[width := aBlox widthAbsolute.
		self xOffset: width.
		self width > 0 ifTrue: [self widthOffset: self widthOffset - width]]
    ]

    posVert: aBlox [
	"Position the receiver just below aBlox."

	<category: 'geometry management'>
	| y height |
	height := aBlox height.
	self x: aBlox x y: height + aBlox y.
	height = 0 
	    ifTrue: 
		[height := aBlox heightAbsolute.
		self yOffset: height.
		self height > 0 ifTrue: [self heightOffset: self heightOffset - height]]
    ]

    stretch: aBoolean [
	"This method is only considered when on the path from the receiver
	 to its toplevel there is a BContainer.  It decides whether we are
	 among the widgets that are stretched to fill the entire width of
	 the BContainer."

	<category: 'geometry management'>
	self parent child: self stretch: aBoolean.
	self properties at: #stretch put: aBoolean
    ]

    width [
	"Answer the `variable' part of the receiver's width within the parent
	 widget. The value returned does not include any fixed amount of
	 pixels indicated by #widthOffset: and must be interpreted in a relative
	 fashion: the ratio of the returned value to the current size of the
	 parent will be preserved upon resize. This apparently complicated
	 method is known as `rubber sheet' geometry management.  Behavior
	 if the left or right edges are not within the client area of the
	 parent is not defined -- the window might be clamped or might be
	 positioned according to the specification."

	<category: 'geometry management'>
	^self parent widthChild: self
    ]

    width: value [
	"Set to `value' the width of the widget within the parent widget. The
	 value is specified in a relative fashion as an integer, so that the
	 ratio of `value' to the current size of the parent will be
	 preserved upon resize. This apparently complicated method is known
	 as `rubber sheet' geometry management."

	<category: 'geometry management'>
	self parent child: self width: value
    ]

    width: width height: height [
	"change my dimensions"

	<category: 'geometry management'>
	self
	    width: width;
	    height: height
    ]

    widthAbsolute [
	"Force a recalculation of the layout of widgets in the receiver's
	 parent, then answer the current width of the receiver in pixels."

	<category: 'geometry management'>
	| w |
	w := self container getAllocation width.
	^w = -1 ifTrue: [self width] ifFalse: [w]
    ]

    widthOffset [
	"Private - Answer the pixels to be added or subtracted to the width
	 of the receiver, with respect to the value set in a relative fashion
	 through the #width: method."

	<category: 'geometry management'>
	^self properties at: #widthGeomOfs ifAbsent: [0]
    ]

    widthOffset: value [
	"Add or subtract to the width of the receiver a fixed amount of `value'
	 pixels, with respect to the value set in a relative fashion through
	 the #width: method.  Usage of this method is deprecated; use #inset:
	 and BContainers instead."

	<category: 'geometry management'>
	self properties at: #widthGeomOfs put: value.
	self parent child: self widthOffset: value
    ]

    widthPixels: value [
	"Set the current width of the receiver to `value' pixels. Note that,
	 after calling this method, #width will answer 0, which is logical
	 considering that there is no `variable' part of the size (refer
	 to #width and #width: for more explanations)."

	<category: 'geometry management'>
	self
	    width: 0;
	    widthOffset: value
    ]

    x [
	"Answer the `variable' part of the receiver's x within the parent
	 widget. The value returned does not include any fixed amount of
	 pixels indicated by #xOffset: and must be interpreted in a relative
	 fashion: the ratio of the returned value to the current size of the
	 parent will be preserved upon resize. This apparently complicated
	 method is known as `rubber sheet' geometry management.  Behavior
	 if the left or right edges are not within the client area of the
	 parent is not defined -- the window might be clamped or might be
	 positioned according to the specification."

	<category: 'geometry management'>
	^self parent xChild: self
    ]

    x: value [
	"Set to `value' the x of the widget within the parent widget. The
	 value is specified in a relative fashion as an integer, so that the
	 ratio of `value' to the current size of the parent will be
	 preserved upon resize. This apparently complicated method is known
	 as `rubber sheet' geometry management."

	<category: 'geometry management'>
	self parent child: self x: value
    ]

    x: xPos y: yPos [
	"Set the origin of the receiver through its components xPos and yPos."

	<category: 'geometry management'>
	self
	    x: xPos;
	    y: yPos
    ]

    x: xPos y: yPos width: xSize height: ySize [
	"Set the bounding box of the receiver through its origin and
	 size."

	<category: 'geometry management'>
	self
	    x: xPos y: yPos;
	    width: xSize height: ySize
    ]

    xAbsolute [
	"Force a recalculation of the layout of widgets in the receiver's
	 parent, then answer the current x of the receiver in pixels."

	<category: 'geometry management'>
	| x |
	x := self container getAllocation left.
	^x = -1 ifTrue: [self left] ifFalse: [x]
    ]

    xOffset [
	"Private - Answer the pixels to be added or subtracted to the x
	 of the receiver, with respect to the value set in a relative fashion
	 through the #x: method."

	<category: 'geometry management'>
	^self properties at: #xGeomOfs ifAbsent: [0]
    ]

    xOffset: value [
	"Add or subtract to the x of the receiver a fixed amount of `value'
	 pixels, with respect to the value set in a relative fashion through
	 the #x: method.  Usage of this method is deprecated; use #inset:
	 and BContainers instead."

	<category: 'geometry management'>
	self properties at: #xGeomOfs put: value.
	self parent child: self xOffset: value
    ]

    xPixels: value [
	"Set the current x of the receiver to `value' pixels. Note that,
	 after calling this method, #x will answer 0, which is logical
	 considering that there is no `variable' part of the size (refer
	 to #x and #x: for more explanations)."

	<category: 'geometry management'>
	self
	    x: 0;
	    xOffset: value
    ]

    xRoot [
	"Answer the x position of the receiver with respect to the
	 top-left corner of the desktop (including the offset of the
	 virtual root window under X)."

	<category: 'geometry management'>
	self tclEval: 'expr [winfo rootx %1] + [winfo vrootx %1]'
	    with: self container.
	^self tclResult asInteger
    ]

    y [
	"Answer the `variable' part of the receiver's y within the parent
	 widget. The value returned does not include any fixed amount of
	 pixels indicated by #yOffset: and must be interpreted in a relative
	 fashion: the ratio of the returned value to the current size of the
	 parent will be preserved upon resize. This apparently complicated
	 method is known as `rubber sheet' geometry management.  Behavior
	 if the left or right edges are not within the client area of the
	 parent is not defined -- the window might be clamped or might be
	 positioned according to the specification."

	<category: 'geometry management'>
	^self parent yChild: self
    ]

    y: value [
	"Set to `value' the y of the widget within the parent widget. The
	 value is specified in a relative fashion as an integer, so that the
	 ratio of `value' to the current size of the parent will be
	 preserved upon resize. This apparently complicated method is known
	 as `rubber sheet' geometry management."

	<category: 'geometry management'>
	self parent child: self y: value
    ]

    yAbsolute [
	"Force a recalculation of the layout of widgets in the receiver's
	 parent, then answer the current y of the receiver in pixels."

	<category: 'geometry management'>
	| y |
	y := self container getAllocation top.
	^y = -1 ifTrue: [self top] ifFalse: [y]
    ]

    yOffset [
	"Private - Answer the pixels to be added or subtracted to the y
	 of the receiver, with respect to the value set in a relative fashion
	 through the #y: method."

	<category: 'geometry management'>
	^self properties at: #yGeomOfs ifAbsent: [0]
    ]

    yOffset: value [
	"Add or subtract to the y of the receiver a fixed amount of `value'
	 pixels, with respect to the value set in a relative fashion through
	 the #y: method.  Usage of this method is deprecated; use #inset:
	 and BContainers instead."

	<category: 'geometry management'>
	self properties at: #yGeomOfs put: value.
	self parent child: self yOffset: value
    ]

    yPixels: value [
	"Set the current y of the receiver to `value' pixels. Note that,
	 after calling this method, #y will answer 0, which is logical
	 considering that there is no `variable' part of the size (refer
	 to #y and #y: for more explanations)."

	<category: 'geometry management'>
	self
	    y: 0;
	    yOffset: value
    ]

    yRoot [
	"Answer the y position of the receiver with respect to the
	 top-left corner of the desktop (including the offset of the
	 virtual root window under X)."

	<category: 'geometry management'>
	self tclEval: 'expr [winfo rooty %1] + [winfo vrooty %1]'
	    with: self container.
	^self tclResult asInteger
    ]
]



BWidget subclass: BPrimitive [
    
    <category: 'Graphics-Windows'>
    <comment: '
I am the superclass for every widget (except menus) directly
provided by the underlying GUI system.'>

    asPrimitiveWidget [
	"Answer the primitive widget that implements the receiver."

	<category: 'accessing'>
	^self
    ]

    exists [
	"Answer whether the receiver has been destroyed or not (answer false
	 in the former case, true in the latter)."

	<category: 'accessing'>
	^connected notNil
    ]

    destroyed [
	"Private - The receiver has been destroyed, clear the instance
	 variables to release some memory."

	<category: 'private'>
	super destroyed.
	connected := nil
    ]

    connected [
	"answer the gtk native object that is used for geometry mgmt & layout"

	<category: 'private'>
	connected isNil ifTrue: [self createWidget].
	^connected
    ]

    connected: anObject [
	"set the current gtk native object"

	<category: 'private'>
	connected := anObject
    ]

    createWidget [
	<category: 'private'>
	self create.
	self show.
	self setInitialSize.
	self parent notNil ifTrue: [self parent addChild: self]
    ]

    show [
	<category: 'private'>
	(self connected)
	    connectSignal: 'destroy'
		to: self
		selector: #onDestroy:data:
		userData: nil;
	    show
    ]
]



BWidget subclass: BExtended [
    | primitive |
    
    <category: 'Graphics-Windows'>
    <comment: 'Just like Gui, I serve as a base for complex objects which expose
an individual protocol but internally use a Blox widget for
creating their user interface. Unlike Gui, however, the
instances of my subclasses understand the standard widget protocol.
Just override my newPrimitive method to return another widget,
and you''ll get a class which interacts with the user like that
widget (a list box, a text box, or even a label) but exposes a
different protocol.'>

    asPrimitiveWidget [
	"Answer the primitive widget that implements the receiver."

	<category: 'accessing'>
	^primitive asPrimitiveWidget
    ]

    create [
	"After this method is called (the call is made automatically)
	 the receiver will be attached to a `primitive' widget (which
	 can be in turn another extended widget).
	 This method is public not because you can call it, but because
	 it can be useful to override it, not forgetting the call to
	 super (which only calls #newPrimitive and saves the result),
	 to perform some initialization on the primitive widget
	 just created; overriding #create is in fact more generic than
	 overriding #newPrimitive. For an example of this, see the
	 implementation of BButtonLike."

	<category: 'customization'>
	primitive := self newPrimitive
    ]

    newPrimitive [
	"Create and answer a new widget on which the implementation of the
	 receiver will be based. You should not call this method directly;
	 instead you must override it in BExtended's subclasses."

	<category: 'customization'>
	self subclassResponsibility
    ]
]



BPrimitive subclass: BViewport [
    | container horizontal vertical |
    
    <category: 'Graphics-Windows'>
    <comment: 'I represent an interface which is common to widgets that can be
scrolled, like list boxes or text widgets.'>

    container [
	"answer the gtk scrolled window"

	<category: 'accessing'>
	container isNil ifTrue: [self createWidget].
	^container
    ]

    container: aGtkWidget [
	<category: 'accessing'>
	container := aGtkWidget
    ]

    show [
	<category: 'creation'>
	self container: (GTK.GtkScrolledWindow new: nil vadjustment: nil).
	self container setPolicy: GTK.Gtk gtkPolicyAutomatic
	    vscrollbarPolicy: GTK.Gtk gtkPolicyAutomatic.
	horizontal := vertical := true.
	self needsViewport 
	    ifTrue: [self container addWithViewport: self connected]
	    ifFalse: [self container add: self connected].
	super show.
	self container show
    ]

    pickPolicy [
	<category: 'creation'>
	| hpolicy vpolicy |
	hpolicy := horizontal 
		    ifTrue: [GTK.Gtk gtkPolicyAutomatic]
		    ifFalse: [GTK.Gtk gtkPolicyNever].
	vpolicy := vertical 
		    ifTrue: [GTK.Gtk gtkPolicyAutomatic]
		    ifFalse: [GTK.Gtk gtkPolicyNever].
	self container setPolicy: hpolicy vscrollbarPolicy: vpolicy
    ]

    needsViewport [
	<category: 'creation'>
	^true
    ]

    horizontal [
	"Answer whether an horizontal scrollbar is drawn in the widget
	 if needed."

	<category: 'scrollbars'>
	^horizontal
    ]

    horizontal: aBoolean [
	"Set whether an horizontal scrollbar is drawn in the widget if
	 needed."

	<category: 'scrollbars'>
	horizontal := aBoolean.
	self pickPolicy
    ]

    horizontalNeeded [
	"Answer whether an horizontal scrollbar is needed to show all the
	 information in the widget."

	<category: 'scrollbars'>
	self 
	    tclEval: 'expr [lindex [%1 xview] 0] > 0 || [lindex [%1 xview] 1] < 1'
	    with: self connected.
	^self tclResult = '1'
    ]

    horizontalShown [
	"Answer whether an horizontal scrollbar is drawn in the widget."

	<category: 'scrollbars'>
	^self horizontal and: [self horizontalNeeded]
    ]

    vertical [
	"Answer whether a vertical scrollbar is drawn in the widget
	 if needed."

	<category: 'scrollbars'>
	^vertical
    ]

    vertical: aBoolean [
	"Set whether a vertical scrollbar is drawn in the widget if
	 needed."

	<category: 'scrollbars'>
	vertical := aBoolean.
	self pickPolicy
    ]

    verticalNeeded [
	"Answer whether a vertical scrollbar is needed to show all the
	 information in the widget."

	<category: 'scrollbars'>
	self 
	    tclEval: 'expr [lindex [%1 yview] 0] > 0 || [lindex [%1 yview] 1] < 1'
	    with: self connected.
	^self tclResult = '1'
    ]

    verticalShown [
	"Answer whether a vertical scrollbar is drawn in the widget."

	<category: 'scrollbars'>
	^self vertical and: [self verticalNeeded]
    ]
]



Blox subclass: BMenuObject [
    | childrensUnderline callback |
    
    <category: 'Graphics-Windows'>
    <comment: 'I am an abstract superclass for widgets which make up a menu structure.'>

    activeBackground [
	"Answer the value of the activeBackground option for the widget.
	 
	 Specifies background color to use when drawing active elements. An element
	 (a widget or portion of a widget) is active if the mouse cursor is positioned
	 over the element and pressing a mouse button will cause some action
	 to occur. For some elements on Windows and Macintosh systems, the active
	 color will only be used while mouse button 1 is pressed over the element."

	<category: 'accessing'>
	self properties at: #activebackground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -activebackground'
	    with: self connected
	    with: self container.
	^self properties at: #activebackground put: self tclResult
    ]

    activeBackground: value [
	"Set the value of the activeBackground option for the widget.
	 
	 Specifies background color to use when drawing active elements. An element
	 (a widget or portion of a widget) is active if the mouse cursor is positioned
	 over the element and pressing a mouse button will cause some action
	 to occur. For some elements on Windows and Macintosh systems, the active
	 color will only be used while mouse button 1 is pressed over the element."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -activebackground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #activebackground put: value
    ]

    activeForeground [
	"Answer the value of the activeForeground option for the widget.
	 
	 Specifies foreground color to use when drawing active elements. See above
	 for definition of active elements."

	<category: 'accessing'>
	self properties at: #activeforeground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -activeforeground'
	    with: self connected
	    with: self container.
	^self properties at: #activeforeground put: self tclResult
    ]

    activeForeground: value [
	"Set the value of the activeForeground option for the widget.
	 
	 Specifies foreground color to use when drawing active elements. See above
	 for definition of active elements."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -activeforeground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #activeforeground put: value
    ]

    asPrimitiveWidget [
	"Answer the primitive widget that implements the receiver."

	<category: 'accessing'>
	^self
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #background ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -background'
	    with: self connected
	    with: self container.
	^self properties at: #background put: self tclResult
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -background %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #background put: value
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #foreground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -foreground'
	    with: self connected
	    with: self container.
	^self properties at: #foreground put: self tclResult
    ]

    foregroundColor: value [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -foreground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #foreground put: value
    ]

    callback [
	"Answer a DirectedMessage that is sent when the receiver is modified,
	 or nil if none has been set up."

	<category: 'callback'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the receiver is clicked.
	 If the method accepts an argument, the receiver is passed."

	<category: 'callback'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := Array with: self].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    callback: aReceiver message: aSymbol argument: anObject [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a one- or two-argument selector) when the receiver is clicked.
	 If the method accepts two argument, the receiver is passed
	 together with anObject; if it accepts a single one, instead,
	 only anObject is passed."

	<category: 'callback'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	numArgs = 2 
	    ifTrue: 
		[arguments := 
			{self.
			anObject}]
	    ifFalse: [arguments := {anObject}].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    invokeCallback [
	"Generate a synthetic callback"

	<category: 'callback'>
	self callback isNil ifFalse: [self callback send]
    ]

    connected [
	<category: 'private'>
	^self uiManager getWidget: self path
    ]

    uiManager [
	<category: 'private'>
	self subclassResponsibility
    ]

    path [
	<category: 'private'>
	self subclassResponsibility
    ]

    underline: label [
	<category: 'private - underlining'>
	childrensUnderline isNil 
	    ifTrue: [childrensUnderline := ByteArray new: 256].
	label doWithIndex: 
		[:each :index | 
		| ascii |
		ascii := each asUppercase value + 1.
		(childrensUnderline at: ascii) = 0 
		    ifTrue: 
			[childrensUnderline at: ascii put: 1.
			^index - 1]].
	^0
    ]
]



"-------------------------- Gui class -----------------------------"



"-------------------------- BEventTarget class -----------------------------"



"-------------------------- BEventSet class -----------------------------"



"-------------------------- Blox class -----------------------------"



"-------------------------- BWidget class -----------------------------"



"-------------------------- BPrimitive class -----------------------------"



"-------------------------- BExtended class -----------------------------"



"-------------------------- BViewport class -----------------------------"



"-------------------------- BMenuObject class -----------------------------"



String extend [

    asTkString [
	"Private, Blox - Answer a copy of the receiver enclosed in
	 double-quotes and in which all the characters that Tk cannot read
	 are escaped through a backslash"

	<category: 'private - Tk interface'>
	self notYetImplemented
    ]

    asTkImageString [
	"Private, Blox - Look for GIF images; for those, since Base-64 data does
	 not contain { and }, is better to use the {} syntax."

	<category: 'private - Tk interface'>
	self notYetImplemented
    ]

]

PK
     �Mh@��#�@, @,           ��    BloxWidgets.stUT cqXOux �  �  PK
     �Mh@�Q^�  ^�            ���, BloxExtend.stUT cqXOux �  �  PK
     �Mh@H�m��  ��            ��-� BloxText.stUT cqXOux �  �  PK
     �Mh@��~�  �            ��2q Blox.stUT cqXOux �  �  PK
     1[h@�x>�              ��	w package.xmlUT �XOux �  �  PK
     �Mh@���H �H           ��hx BloxBasic.stUT cqXOux �  �  PK      �  ��   