PK
     �Mh@ec�       Menu.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI wrapper for menus
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003 Free Software Foundation, Inc.
| Written by Brad Diller.
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
 ======================================================================
"



BLOX.Gui subclass: Menu [
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    Menu class >> new: view label: title [
	<category: 'initializing'>
	| aMenu |
	aMenu := Menu new.
	aMenu blox: (BMenu new: view menuBar label: title).
	^aMenu
    ]

    replaceArgWith: arg in: selectorsArray [
	<category: 'initializing'>
	| selectors |
	selectors := selectorsArray deepCopy.

	"(label unarySelector (... submenu ...)) should not be changed
	 (label keywordSelector arg) should be changed
	 (label keywordSelector arg (... submenu ...)) should be changed"
	selectorsArray with: selectors
	    do: 
		[:item :changed | 
		(item size > 2 and: [(item at: 2) numArgs >= 1]) 
		    ifTrue: [changed at: 3 put: arg].
		(item size > 1 and: [item last isArray]) 
		    ifTrue: 
			[changed at: changed size put: (self replaceArgWith: arg in: item last)]].
	^selectors
    ]

    selectors: selectors receiver: receiver [
	<category: 'initializing'>
	blox callback: receiver using: selectors
    ]

    selectors: selectors receiver: receiver argument: arg [
	<category: 'initializing'>
	blox callback: receiver using: (self replaceArgWith: arg in: selectors)
    ]
]



Menu subclass: PopupMenu [
    | windowMenu |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    PopupMenu class >> new: view [
	<category: 'initializing'>
	^self new: view label: nil
    ]

    PopupMenu class >> new: view label: title [
	<category: 'initializing'>
	| aMenu blox theTitle |
	aMenu := self new.
	theTitle := (title notNil and: [title isEmpty]) 
		    ifTrue: [nil]
		    ifFalse: [title].
	blox := theTitle isNil 
		    ifTrue: [BPopupMenu new: view blox label: '']
		    ifFalse: [BPopupMenu new: view blox label: theTitle].
	aMenu blox: blox.

	"We were given a menu name, add to the menu bar as well"
	theTitle isNil 
	    ifFalse: 
		[aMenu windowMenu: (Menu new: view rootView label: theTitle).
		view rootView menu: aMenu windowMenu].
	^aMenu
    ]

    windowMenu [
	<category: 'initializing'>
	^windowMenu
    ]

    windowMenu: aMenu [
	<category: 'initializing'>
	windowMenu := aMenu
    ]

    selectors: selectorsArray receiver: receiver [
	<category: 'initializing'>
	super selectors: selectorsArray receiver: receiver.
	windowMenu isNil 
	    ifFalse: [windowMenu selectors: selectorsArray receiver: receiver]
    ]

    selectors: selectorsArray receiver: receiver argument: arg [
	<category: 'initializing'>
	super 
	    selectors: selectorsArray
	    receiver: receiver
	    argument: arg.
	windowMenu isNil 
	    ifFalse: 
		[windowMenu 
		    selectors: selectorsArray
		    receiver: receiver
		    argument: arg]
    ]
]

PK
     �Mh@����  �    Load.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI browser initialization script
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller.
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
 ======================================================================
"



Eval [
    Class allSubclassesDo: 
	    [:each | 
	    (each instanceClass notNil 
		and: [each instanceClass includesSelector: #inspect]) 
		    ifTrue: [each instanceClass removeSelector: #inspect]].
    (BLOX.BLOXBrowser includesKey: #BrowserMain) 
	ifTrue: [BLOX.BLOXBrowser.BrowserMain close]
]

PK
     �Mh@���
  
    PList.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI wrapper for list boxes
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003 Free Software Foundation, Inc.
| Written by Brad Diller.
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
 ======================================================================
"



Primitive subclass: PList [
    | selection selectionMsg listMsg dataMsg label |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    PList class >> new: aString in: view [
	<category: 'instance creation'>
	| result |
	result := super new: aString in: view.
	result label: aString.
	^result
    ]

    display [
	"Update list widget based on list"

	<category: 'displaying'>
	| contents elements |
	elements := data perform: self dataMsg.
	selection := 0.
	contents := listMsg isNil 
		    ifTrue: [elements collect: [:each | each displayString]]
		    ifFalse: [data perform: listMsg].
	blox contents: contents elements: elements.

	"Select item returned by initialSelection message"
	selectionMsg notNil ifTrue: [self select: (data perform: selectionMsg)]
    ]

    dataMsg [
	<category: 'private - accessing'>
	^dataMsg isNil ifTrue: [listMsg] ifFalse: [dataMsg]
    ]

    label: aString [
	<category: 'initializing'>
	label := aString
    ]

    changedSelection: stateChangeKey [
	"Install message handler for stateChangeKey to select the item based on the
	 initial selection"

	<category: 'initializing'>
	self stateChange: stateChangeKey
	    updateWith: [self select: (data perform: selectionMsg)]
    ]

    dataMsg: dataSelector [
	"Return array of list items"

	<category: 'initializing'>
	dataMsg := dataSelector
    ]

    handleUserChange: changeSelector [
	<category: 'initializing'>
	super handleUserChange: changeSelector.
	blox callback: self message: #selection:at:
    ]

    selectionMsg: selectionSelector [
	"Save data object selector which will retrieve initial list selection in the
	 variable, selectionMsg"

	<category: 'initializing'>
	selectionMsg := selectionSelector
    ]

    initialize [
	<category: 'initializing'>
	selection := 0.
	blox := BList new: parentView blox.
	self blox label: label
    ]

    listMsg: listSelector [
	"Return array of list labels"

	<category: 'initializing'>
	listMsg := listSelector
    ]

    stateChange: stateChangeKey [
	"Install message handler to redraw list in response to an update: message"

	<category: 'initializing'>
	self stateChange: stateChangeKey updateWith: [self display]
    ]

    selection: aPList at: itemPosition [
	"Change list selection based on new selection"

	<category: 'message selectors'>
	| value |
	selection = itemPosition ifTrue: [^itemPosition].

	"If this is a new selection, ask the data object whether the view can
	 update itself.  There may be text which has been modified in the text
	 view associated with the current list selection"
	self canChangeState 
	    ifFalse: 
		[blox highlight: selection.
		^selection].
	selection := itemPosition.
	stateChangeMsg isNil 
	    ifFalse: 
		[value := (data perform: self dataMsg) at: itemPosition ifAbsent: [nil].
		data perform: stateChangeMsg with: selection -> value].
	^itemPosition
    ]

    select: item [
	"Select item named, aSymbol, in list"

	<category: 'modifying'>
	| newSelection |
	item isNil ifTrue: [^self].
	newSelection := item isInteger 
		    ifTrue: [item]
		    ifFalse: [(data perform: self dataMsg) indexOf: item].
	newSelection = 0 ifTrue: [^self].
	newSelection = selection ifTrue: [^self].
	blox highlight: newSelection.
	self selection: self at: newSelection
    ]

    unselect [
	<category: 'modifying'>
	selection := 0.
	blox unhighlight
    ]

    copyAll [
	<category: 'clipboard'>
	| ws |
	ws := WriteStream on: String new.
	blox elements do: [:each | ws nextPutAll: each printString]
	    separatedBy: [ws nextPut: Character nl].
	Blox clipboard: ws contents
    ]

    copySelection [
	<category: 'editing'>
	Blox clipboard: (blox at: blox index) printString
    ]
]

PK
     �Mh@�����3  �3    Inspector.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI generic inspectors
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003 Free Software Foundation, Inc.
| Written by Brad Diller and Paolo Bonzini.
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
 ======================================================================
"



GuiData subclass: Inspector [
    | listView textView topView fieldList fieldLists diveList |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    text [
	"Return string representation of currently selected instance or indexed
	 variable"

	<category: 'accessing'>
	fieldList currentField == 0 ifTrue: [^''].
	^fieldList currentFieldString
    ]

    object [
	<category: 'accessing'>
	^textView object
    ]

    object: anObject [
	<category: 'accessing'>
	textView object: anObject.
	fieldLists do: [:each | each value: anObject].
	self changeState: #fieldList.
	self changeState: #text.
	Primitive updateViews
    ]

    fields [
	"Return list of variable names displayed in the variable list pane"

	<category: 'accessing'>
	^fieldList fields
    ]

    currentField: field [
	<category: 'accessing'>
	fieldList currentField: field.
	self changeState: #text.
	Primitive updateViews
    ]

    currentField [
	<category: 'accessing'>
	^fieldList currentField
    ]

    fieldLists [
	<category: 'initializing'>
	^fieldLists
    ]

    fieldLists: aCollection [
	<category: 'initializing'>
	fieldLists := aCollection.
	self fieldList: aCollection first value
    ]

    fieldList: aFieldList [
	<category: 'initializing'>
	fieldList := aFieldList.
	fieldList inspector: self.
	textView isNil 
	    ifFalse: 
		[textView object: fieldList value.
		listView menuInit: ((fieldList inspectMenu: listView) 
			    selectors: #(#() #('Dive' #dive) #('Pop' #pop) #('Browse class' #browse) #())
			    receiver: self
			    argument: nil).
		self initFieldListsMenu.
		self changeState: #fieldList.
		self changeState: #text.
		Primitive updateViews]
    ]

    initFieldListsMenu [
	<category: 'initializing'>
	fieldLists do: 
		[:each | 
		listView menu selectors: 
			{
			{each key.
			#fieldList:.
			each value}}
		    receiver: self]
    ]

    open [
	<category: 'initializing'>
	| pane |
	topView := BrowserShell 
		    new: 'Inspecting %1%2' % 
				{fieldList value isClass 
				    ifFalse: [fieldList value class article , ' ']
				    ifTrue: [''].
				fieldList value class nameIn: Namespace current}.
	topView data: self.
	topView blox 
	    x: 20
	    y: 330
	    width: 300
	    height: 100.
	pane := Form new: 'forms' in: topView.
	topView addChildView: pane.
	self openIn: pane menuName: 'Edit'.
	topView display
    ]

    openIn: pane [
	<category: 'initializing'>
	self openIn: pane menuName: 'Edit'
    ]

    openIn: pane menuName: label [
	"Initialize Inspector and open an Inspector window on anObject"

	"Initialize instance variable, fields, which governs display of
	 variable list pane"

	<category: 'initializing'>
	"Create a Form manager which will contain the variable and text pane"

	| listWidth container |
	container := pane blox.
	listWidth := pane blox width // 3 min: 100.

	"Create a text window and position it in first third of window"
	pane addChildView: ((listView := PList new: 'InstanceVars' in: pane)
		    initialize;
		    data: self;
		    stateChange: #fieldList;
		    handleUserChange: #currentField:;
		    listMsg: #fields;
		    selectionMsg: #currentField;
		    yourself).
	(listView blox)
	    width: listWidth height: pane blox height;
	    inset: 2.

	"Create text pane and position it in right 2/3s of window"
	pane addChildView: ((textView := PText new: pane)
		    data: self;
		    stateChange: #text;
		    handleUserChange: #setArg:from:;
		    textMsg: #text;
		    canBeDirty: false;
		    setEvaluationKeyBindings;
		    object: fieldList value;
		    yourself).
	(textView blox)
	    width: pane blox width - listWidth height: pane blox height;
	    inset: 2.
	textView blox posHoriz: listView blox.
	"Initialize popup for text pane"
	textView menuInit: ((PopupMenu new: textView label: label)
		    selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste) #() #('Clear' #gstClear) #() #('Line...' #line) #('Find...' #find))
			receiver: textView
			argument: nil;
		    selectors: #(#() #('Do it' #eval: #textView) #('Print it' #evalAndPrintResult: #textView) #('Inspect' #inspectValue: #textView))
			receiver: self
			argument: textView;
		    selectors: #(#() #('Accept' #compileIt) #('Cancel' #revert) #() #('Close' #close))
			receiver: textView
			argument: nil;
		    yourself).
	self fieldLists: self fieldLists.
	self changeState: #fieldList.
	Primitive updateViews
    ]

    browse [
	<category: 'list view menu'>
	ClassBrowser new openOn: self object class asClass
    ]

    dive [
	<category: 'list view menu'>
	diveList isNil ifTrue: [diveList := OrderedCollection new].
	diveList addLast: fieldLists.
	self fieldLists: fieldList currentFieldValue inspectorFieldLists
    ]

    pop [
	<category: 'list view menu'>
	diveList isNil ifTrue: [^self].
	diveList isEmpty ifTrue: [^self].
	self fieldLists: diveList removeLast
    ]

    eval: aView [
	"Invoked from text pane popup.  Evaluate selected expression in text pane"

	<category: 'text view menu'>
	| pos aStream text |
	text := aView blox getSelection.
	(text isNil or: [text size = 0]) ifTrue: [^aView beep].
	aStream := WriteStream on: (String new: 0).
	fieldList value class evaluate: text to: fieldList value
    ]

    evalAndPrintResult: aView [
	"Print result of evaluation of selected expression to its right"

	<category: 'text view menu'>
	| pos result text |
	text := aView blox getSelection.
	(text isNil or: [text size = 0]) ifTrue: [^aView beep].
	result := fieldList value class 
		    evaluate: text
		    to: fieldList value
		    ifError: [:fname :lineNo :errorString | errorString].
	aView blox insertTextSelection: result printString
    ]

    inspectValue: aView [
	"Open an inspector for evaluated selected expression.  If selected expression
	 contains parsing error(s), the error description is selected and printed at end
	 of selection"

	<category: 'text view menu'>
	| obj text |
	text := aView blox getSelection.
	(text isNil or: [text size = 0]) ifTrue: [^aView beep].
	obj := fieldList value class 
		    evaluate: text
		    to: fieldList value
		    ifError: 
			[:fname :lineNo :errorString | 
			aView displayError: errorString.
			^nil].
	obj inspect
    ]

    setArg: aString from: aView [
	"Store result of evaluation of selected expression in selected instance or
	 indexed variable"

	<category: 'text view menu'>
	| obj |
	(aString isNil or: [aString size = 0]) ifTrue: [^aView beep].
	fieldList currentField <= 1 ifTrue: [^aView beep].

	"Evaluate selected expression.  If expression contains a parsing error, the
	 description is output at end of expression and nil is returned"
	obj := fieldList value class 
		    evaluate: aString
		    to: fieldList value
		    ifError: 
			[:fname :lineNo :errorString | 
			aView displayError: errorString at: lineNo.
			^nil].
	fieldList currentFieldValue: obj
    ]
]



ValueHolder subclass: InspectorFieldList [
    | inspector fields currentField |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    evalAndInspectResult: listView [
	<category: 'field list menu'>
	currentField == 0 ifTrue: [^listView beep].
	self currentFieldValue inspect
    ]

    inspector [
	<category: 'private'>
	^inspector
    ]

    inspector: anInspector [
	<category: 'private'>
	inspector := anInspector
    ]

    inspectMenu: listView [
	"Initialize menu for variable list pane"

	<category: 'private'>
	^(PopupMenu new: listView) 
	    selectors: #(#('Inspect' #evalAndInspectResult: #listView))
	    receiver: self
	    argument: listView
    ]

    currentField [
	<category: 'private'>
	^currentField
    ]

    currentField: assoc [
	"Set variable list index to 'index'."

	<category: 'private'>
	currentField := assoc key
    ]

    currentFieldValue: obj [
	<category: 'private'>
	self subclassResponsibility
    ]

    currentFieldValue [
	<category: 'private'>
	self subclassResponsibility
    ]

    currentFieldString [
	<category: 'private'>
	^[self currentFieldValue printString] on: Error
	    do: [:ex | ex return: '[%1 exception raised while printing item]' % {ex class}]
    ]

    fieldsSortBlock [
	"nil = use OrderedCollection, else a block to be used as fields'
	 sort block."

	<category: 'private'>
	^nil
    ]

    fields [
	<category: 'private'>
	^fields
    ]

    value: anObject [
	<category: 'private'>
	super value: anObject.
	fields := self fieldsSortBlock ifNil: [OrderedCollection new]
		    ifNotNil: [:block | SortedCollection sortBlock: block].
	currentField := 0.
	self computeFieldList: anObject
    ]

    computeFieldList: anObject [
	"Store a string representation of the inspected object, anObject, in fields.
	 The first string is self.  The subsequent values are the object's complete set
	 of instance variables names.  If the object is a variable class, append
	 numerical indices from one to number of indexed variables"

	<category: 'private'>
	self subclassResponsibility
    ]
]



InspectorFieldList subclass: ObjectInspectorFieldList [
    | base |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    currentFieldValue: obj [
	<category: 'accessing'>
	currentField > base 
	    ifTrue: [self value basicAt: currentField - base put: obj]
	    ifFalse: [self value instVarAt: currentField - 1 put: obj]
    ]

    currentFieldValue [
	<category: 'accessing'>
	currentField == 0 ifTrue: [^nil].
	currentField == 1 ifTrue: [^self value].
	^currentField > base 
	    ifTrue: [self value basicAt: currentField - base]
	    ifFalse: [self value instVarAt: currentField - 1]
    ]

    computeFieldList: anObject [
	"Store a string representation of the inspected object, anObject, in fields.
	 The first string is self.  The subsequent values are the object's complete
	 set of instance variables names.  If the object is a variable class,
	 append numerical indices from one to number of indexed variables"

	<category: 'accessing'>
	| instVarNames |
	fields add: 'self'.
	instVarNames := anObject class allInstVarNames.
	1 to: instVarNames size
	    do: [:x | fields add: (instVarNames at: x) asString].
	base := fields size.
	anObject class isVariable 
	    ifTrue: [1 to: anObject validSize do: [:x | fields add: x printString]]
    ]
]



ObjectInspectorFieldList subclass: CollectionInspectorFieldList [
    | array |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    currentFieldValue: obj [
	<category: 'initializing'>
	(self value isKindOf: SequenceableCollection) not 
	    | (self value class == SortedCollection) 
		ifTrue: 
		    [(self value)
			remove: self currentFieldValue ifAbsent: [];
			add: obj.
		    array := self value asArray.
		    ^self].
	self value at: currentField - 1 put: obj.
	array == self value ifFalse: [array at: currentField - 1 put: obj]
    ]

    currentFieldValue [
	<category: 'initializing'>
	currentField == 0 ifTrue: [^nil].
	currentField == 1 ifTrue: [^self value].
	^array at: currentField - 1
    ]

    computeFieldList: anObject [
	"Use this so that the user doesn't see implementation-dependant details"

	<category: 'initializing'>
	array := (anObject isKindOf: ArrayedCollection) 
		    ifFalse: [anObject asArray]
		    ifTrue: [anObject].
	super computeFieldList: array
    ]
]



Object extend [

    inspectorFieldLists [
	<category: 'debugging'>
	^{'Basic' -> (BLOX.BLOXBrowser.ObjectInspectorFieldList new value: self)}
    ]

    basicInspect [
	"Open an Inspector window on self"

	<category: 'debugging'>
	^(BLOX.BLOXBrowser.Inspector new)
	    fieldLists: 
		    {'Basic' -> (BLOX.BLOXBrowser.ObjectInspectorFieldList new value: self)};
	    open;
	    yourself
    ]

    inspect [
	"Open an inspection window on self -- by default, the same Inspector used
	 in #basicInspect."

	<category: 'debugging'>
	^(BLOX.BLOXBrowser.Inspector new)
	    fieldLists: self inspectorFieldLists;
	    open;
	    yourself
    ]

]



Collection extend [

    inspectorFieldLists [
	<category: 'debugging'>
	^
	{'Elements' 
	    -> (BLOX.BLOXBrowser.CollectionInspectorFieldList new value: self).
	'Basic' -> (BLOX.BLOXBrowser.ObjectInspectorFieldList new value: self)}
    ]

]

PK
     �Mh@���)  �)    NamespBrow.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI namespace browser
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002, 2003 Free Software Foundation, Inc.
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
 ======================================================================
"



ClassHierarchyBrowser subclass: NamespaceBrowser [
    | curNamespace byCategory namespacesMap namespaces categories |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    byCategory [
	"If categories are being viewed, return true"

	<category: 'accessing'>
	^byCategory
    ]

    byCategory: aBoolean [
	"Change instance/class representation and record data state changes"

	<category: 'accessing'>
	byCategory = aBoolean ifTrue: [^self].
	curNamespace := nil.
	byCategory := aBoolean.
	self updateNamespaceList
    ]

    namespaceList [
	<category: 'accessing'>
	^byCategory ifTrue: [categories] ifFalse: [namespaces]
    ]

    namespaceSelection: assoc [
	<category: 'accessing'>
	| name |
	name := assoc value.
	curNamespace := name isNil | byCategory 
		    ifTrue: [name]
		    ifFalse: [namespacesMap at: name].
	curClass := nil.
	self updateClassList
    ]

    namespaceString [
	"Return name of selected class indented by 'n' spaces, where 'n' is the number
	 of class' superclasses"

	<category: 'accessing'>
	| spaces |
	curNamespace isNil ifTrue: [^nil].
	byCategory ifTrue: [^curNamespace].
	spaces := String new: curNamespace allSuperspaces size.
	spaces atAllPut: Character space.
	^spaces , curNamespace name
    ]

    readCategories [
	<category: 'accessing'>
	categories := Set new.
	Class allSubclassesDo: 
		[:each | 
		each isMetaclass ifTrue: [categories add: each instanceClass category]].
	categories := categories asSortedCollection
    ]

    readNamespaces [
	<category: 'accessing'>
	| stack top indent namespace subspaces |
	stack := OrderedCollection new.
	namespacesMap := Dictionary new: 17.
	namespaces := OrderedCollection new.
	subspaces := {Smalltalk} , RootNamespace allInstances.
	
	[subspaces isNil 
	    ifFalse: 
		[top := stack 
			    addLast: (subspaces asSortedCollection: [:a :b | a name <= b name])].
	[top isEmpty] whileTrue: 
		[stack removeLast.
		stack isEmpty ifTrue: [^self].
		top := stack last].
	namespace := top removeFirst.
	subspaces := namespace subspaces.
	indent := String new: stack size - 1 withAll: Character space.
	namespacesMap at: indent , namespace name put: namespace.
	namespaces add: indent , namespace name] 
		repeat
    ]

    addSubNamespace: listView [
	<category: 'namespace list blue button menu'>
	| newNamespace |
	curNamespace isNil ifTrue: [^listView beep].
	curNamespace isNamespace ifFalse: [^listView beep].
	newNamespace := (Prompter message: 'Enter a new namespace' in: listView) 
		    response.
	newNamespace = '' ifTrue: [^self].
	curNamespace addSubspace: newNamespace asSymbol.
	self updateNamespaceList
    ]

    blueButtonMenuForNamespaces: theView [
	"Install popup for namespace list popup"

	<category: 'namespace list blue button menu'>
	^(PopupMenu new: theView label: 'Namespace') 
	    selectors: #(#('Namespaces' #namespaces: #theView) #('Categories' #categories: #theView) #() #('File out...' #fileOutNamespace: #theView) #('File into namespace' #fileIntoNamespace: #theView) #() #('Add namespace' #addSubNamespace: #theVIew) #('Rename...' #renameNamespace: #theView) #('Update' #updateNamespaceList))
	    receiver: self
	    argument: theView
    ]

    categories: namespaceList [
	<category: 'namespace list blue button menu'>
	namespaceList canChangeState ifFalse: [^self].
	self byCategory: true
    ]

    fileIntoNamespace: listView [
	"File in a file to a currently selected namespace"

	<category: 'namespace list blue button menu'>
	| oldCurrent className fileName stream |
	curNamespace isNil ifTrue: [^listView beep].
	fileName := Prompter 
		    openFileName: 'Which file do you want me to read?'
		    default: '*.st'
		    in: listView.
	fileName isNil ifTrue: [^listView beep].
	oldCurrent := Namespace current.
	Namespace current: curNamespace.
	FileStream fileIn: fileName.
	Namespace current: oldCurrent
    ]

    fileoutName [
	<category: 'namespace list blue button menu'>
	byCategory ifTrue: [^curNamespace].
	^((curNamespace nameIn: Smalltalk) asString)
	    replaceAll: Character space with: $-;
	    yourself
    ]

    fileOutNamespace: listView [
	"File out a description of the currently selected namespace"

	<category: 'namespace list blue button menu'>
	| oldCurrent className fileName stream |
	curNamespace isNil ifTrue: [^listView beep].
	fileName := self fileoutDir , self fileoutName , '.st'.
	fileName := Prompter 
		    saveFileName: 'File out namespace'
		    default: fileName
		    in: listView.
	fileName isNil ifTrue: [^self].
	stream := FileStream open: fileName mode: FileStream write.
	byCategory 
	    ifFalse: 
		[curNamespace superspace isNil 
		    ifFalse: 
			[stream
			    nextPutAll: (curNamespace superspace nameIn: Smalltalk);
			    nextPutAll: ' addSubspace: #';
			    nextPutAll: curNamespace name;
			    nextPutAll: '!';
			    nl;
			    nextPutAll: 'Namespace current: ';
			    nextPutAll: (curNamespace nameIn: Smalltalk);
			    nextPutAll: '!';
			    nl;
			    nl]
		    ifTrue: 
			[stream
			    nextPutAll: 'Namespace current: (RootNamespace new: #';
			    nextPutAll: (curNamespace nameIn: Smalltalk);
			    nextPutAll: ')!';
			    nl;
			    nl].
		oldCurrent := Namespace current.
		Namespace current: curNamespace].
	classList do: 
		[:each | 
		(each trimSeparators includes: $() 
		    ifFalse: [(shownClasses at: each) fileOutOn: stream]].
	byCategory 
	    ifFalse: 
		[Namespace current: oldCurrent.
		stream
		    nextPutAll: 'Namespace current: Smalltalk!';
		    nl].
	stream close.
	self setFileoutDirFromFile: fileName
    ]

    namespaces: namespaceList [
	<category: 'namespace list blue button menu'>
	namespaceList canChangeState ifFalse: [^self].
	self byCategory: false
    ]

    renameNamespace: listView [
	"Rename currently selected namespace"

	<category: 'namespace list blue button menu'>
	| methods oldName newName prompter oldAssoc referrer |
	curNamespace isNil ifTrue: [^listView beep].
	oldName := self namespaceString trimSeparators.

	"Prompt user for new name"
	prompter := Prompter message: 'Rename namespace: ' , curNamespace name
		    in: listView.
	prompter response = '' ifTrue: [^self].
	self byCategory 
	    ifTrue: 
		[shownClasses do: [:each | each category: prompter response].
		self updateNamespaceList.
		^self].
	oldName := oldName asSymbol.
	newName := prompter response asSymbol.
	(newName at: 1) isUppercase 
	    ifFalse: [^self error: 'Namespace name must begin with an uppercase letter'].
	referrer := curNamespace superspace isNil 
		    ifTrue: [Smalltalk]
		    ifFalse: [curNamespace superspace].
	(referrer includesKey: newName) 
	    ifTrue: [^self error: newName , ' already exists'].

	"Save old Association and remove namespace temporarily"
	oldAssoc := referrer associationAt: oldName.
	referrer removeKey: oldName.

	"Rename the namespace now and re-add it"
	curNamespace name: newName asSymbol.
	referrer at: newName asSymbol put: curNamespace.

	"Notify programmer of all references to renamed namespace"
	methods := SortedCollection new.
	CompiledMethod allInstancesDo: 
		[:method | 
		((method refersTo: oldAssoc) or: [method refersTo: oldAssoc key]) 
		    ifTrue: [methods add: method]].
	methods isEmpty 
	    ifFalse: 
		[ModalDialog new 
		    alertMessage: 'Rename all references to 
		    namespace ' , oldName 
			    , Character nl asSymbol , 'to the new name: ' 
			    , newName
		    in: listView.
		MethodSetBrowser new 
		    openOn: methods
		    title: 'References to ' , oldName
		    selection: oldName].

	"Update namespace list"
	self updateNamespaceList
    ]

    topClasses [
	<category: 'namespace list blue button menu'>
	^self topMetas collect: [:each | each instanceClass]
    ]

    topMetas [
	<category: 'namespace list blue button menu'>
	curNamespace isNil ifTrue: [^#()].
	^byCategory 
	    ifTrue: [Class allSubclasses select: [:each | each category = curNamespace]]
	    ifFalse: 
		[Class allSubclasses select: [:each | each environment = curNamespace]]
    ]

    updateNamespaceList [
	"Invoked from class list pane popup.  Update class list pane through the
	 change/update mechanism"

	<category: 'namespace list blue button menu'>
	byCategory ifTrue: [self readCategories] ifFalse: [self readNamespaces].
	self changeState: #namespaceList.
	self updateClassList
    ]

    createNamespaceListIn: upper [
	<category: 'initializing'>
	| list |
	upper addChildView: ((list := PList new: 'Namespaces' in: upper)
		    initialize;
		    data: self;
		    stateChange: #namespaceList;
		    changedSelection: #newNamespaceSelection;
		    handleUserChange: #namespaceSelection:;
		    listMsg: #namespaceList;
		    selectionMsg: #namespaceString;
		    menuInit: (self blueButtonMenuForNamespaces: list);
		    yourself).
	"Register three types of messages"
	self layoutUpperPaneElement: list blox num: -1
    ]

    createUpperPanesIn: upper [
	<category: 'initializing'>
	self createNamespaceListIn: upper.
	super createUpperPanesIn: upper
    ]

    createTopView [
	<category: 'initializing'>
	^BrowserShell new: 'Namespace Browser'
    ]

    initialize [
	<category: 'initializing'>
	self updateNamespaceList
    ]

    layoutUpperPaneElement: blox num: n [
	<category: 'initializing'>
	blox 
	    x: 150 * n + 150
	    y: 0
	    width: 150
	    height: 200
    ]

    open [
	<category: 'initializing'>
	byCategory := false.
	super open
    ]

    currentNamespace [
	<category: 'overriding'>
	^byCategory ifTrue: [Namespace current] ifFalse: [curNamespace]
    ]
]

PK
     �Mh@���u(  (    DebugSupport.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI debugger support
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Free Software Foundation, Inc.
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
 ======================================================================
"



STInST.STInST.RBProgramNodeVisitor subclass: VariableNames [
    | varNames current optimizedBlocks |
    
    <category: 'System-Compiler'>
    <comment: nil>

    VariableNames class >> on: method [
	"Parse aString and return a collection of collections of variable
	 names.  Each collection corresponds to a site where arguments
	 and/or temporaries can be defined (that is, the method and each
	 of the non-optimized blocks).  The first, in particular, lists
	 arguments and temporaries for the method, the second lists them
	 for the first non-optimized block, and so on."

	<category: 'visiting RBSequenceNodes'>
	^(self new)
	    initialize;
	    visitNode: (method parserClass parseMethod: method methodSourceString);
	    varNames
    ]

    addScope [
	"Add a new collection of variable names."

	<category: 'initializing'>
	varNames add: (current := OrderedCollection new)
    ]

    initialize [
	<category: 'initializing'>
	optimizedBlocks := 0.
	varNames := OrderedCollection new.
	self addScope
    ]

    varNames [
	<category: 'accessing'>
	^varNames
    ]

    visitArgument: node [
	"Found a variable definition.  Record it."

	<category: 'visiting nodes'>
	current addLast: node name
    ]

    acceptBlockNode: aBlockNode [
	"Check if the block is open-coded.  If not, add an item to
	 varNames which will record arguments and temporaries for
	 aBlockNode.  If it is open coded, instead, variables are
	 added to the current list of variable names."

	<category: 'visiting nodes'>
	| optBlocks |
	optBlocks := optimizedBlocks.
	optimizedBlocks := 0.
	optBlocks > 0 ifTrue: [optBlocks := optBlocks - 1] ifFalse: [self addScope].
	super acceptBlockNode: aBlockNode.
	optimizedBlocks := optBlocks
    ]

    acceptMessageNode: node [
	"Check which of the receiver and arguments are open-coded blocks.
	 Before visiting the children of the node, we set optimizedBlocks
	 to a number > 0 if we find an open-coded block."

	<category: 'visiting nodes'>
	node receiver isBlock 
	    ifTrue: [self checkIfOptimizedBlockClosureMessage: node].
	self visitNode: node receiver.
	self checkIfOptimizedTest: node.
	node arguments do: 
		[:each | 
		each isBlock ifTrue: [self checkIfOptimizedToDo: node].
		self visitNode: each]
    ]

    checkIfOptimizedToDo: node [
	"Increase optimizedBlocks if node is an open-coded #to:do:,
	 #timesRepeat: or #to:by:do: message send."

	<category: 'visiting nodes'>
	(node selector == #to:do: or: 
		[node selector == #timesRepeat: 
		    or: [node selector == #to:by:do: and: [(node arguments at: 2) isLiteral]]]) 
	    ifFalse: [^self].
	(self isOptimizedBlockClosure: node arguments last args: 1) 
	    ifFalse: [^self].
	optimizedBlocks := optimizedBlocks + 1
    ]

    isOptimizedBlockClosure: block args: numArgs [
	"Answer whether block is an RBBlockNode with no temporaries and
	 numArgs arguments."

	<category: 'visiting nodes'>
	^block isBlock 
	    and: [block body temporaries isEmpty and: [block arguments size = numArgs]]
    ]

    checkIfOptimizedTest: node [
	"Increase optimizedBlocks if node is an open-coded Boolean test."

	<category: 'visiting nodes'>
	(#(#ifTrue: #ifTrue:ifFalse: #ifFalse:ifTrue: #ifFalse: #and: #or:) 
	    includes: node selector) ifFalse: [^self].
	(node arguments 
	    allSatisfy: [:each | self isOptimizedBlockClosure: each args: 0]) 
		ifFalse: [^self].
	optimizedBlocks := optimizedBlocks + node arguments size
    ]

    checkIfOptimizedBlockClosureMessage: node [
	"Increase optimizedBlocks if node is an open-coded while loop."

	<category: 'visiting nodes'>
	(#(#whileTrue #whileTrue: #whileFalse #whileFalse: #repeat) 
	    includes: node selector) ifFalse: [^self].
	(self isOptimizedBlockClosure: node receiver args: 0) ifFalse: [^self].
	(node arguments 
	    allSatisfy: [:each | self isOptimizedBlockClosure: each args: 0]) 
		ifFalse: [^self].
	optimizedBlocks := optimizedBlocks + node arguments size + 1
    ]
]



ContextPart extend [

    variableNames [
	<category: 'debugging'>
	^self method variableNames
    ]

]



CompiledCode extend [

    variableNames [
	"Answer the names of the arguments and temporaries in the receiver.
	 By default, only numbers are produced."

	<category: 'debugging'>
	^(1 to: self numArgs + self numTemps) collect: [:each | each printString]
    ]

]



CompiledMethod extend [

    variableNames [
	"Answer the names of the arguments and temporaries in the receiver."

	<category: 'debugging'>
	| source |
	source := self methodSourceString.
	source isNil ifTrue: [^super variableNames].
	^(BLOX.BLOXBrowser.VariableNames on: self) at: 1
    ]

]



CompiledBlock extend [

    variableNames [
	"Answer the names of the arguments and temporaries in the receiver."

	<category: 'debugging'>
	| source index |
	self numArgs + self numTemps = 0 ifTrue: [^#()].
	source := self methodSourceString.
	source isNil ifTrue: [^super variableNames].

	"Find how many blocks are there in the method before the receiver."
	index := 2.
	self literals keysAndValuesDo: 
		[:i :each | 
		each class == BlockClosure 
		    ifTrue: 
			[each block == self 
			    ifTrue: 
				["Ok, now parse the source code."

				^(BLOX.BLOXBrowser.VariableNames on: self method) at: index].
			index := index + 1]].
	^super variableNames
    ]

]

PK
     �Mh@�O:B  B    ButtonForm.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI wrapper for button groups
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
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
 ======================================================================
"



Primitive subclass: PButton [
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    PButton class >> parentView: sv data: anObject label: label handleUserChange: changeSelector [
	<category: 'instance creation'>
	| view |
	view := self new.
	view data: anObject.
	view parentView: sv.
	view handleUserChange: changeSelector.
	view initBlox: label.
	^view
    ]

    initBlox: aLabel [
	<category: 'initialize-delete'>
	blox := BButton new: parentView blox label: aLabel.
	blox callback: self message: 'pressed'
    ]

    pressed [
	"Send the modification message to the data object"

	<category: 'message selectors'>
	(stateChangeMsg notNil and: [self canChangeState]) 
	    ifTrue: [data perform: stateChangeMsg]
    ]
]



Form subclass: ButtonForm [
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    ButtonForm class >> new: aString in: view [
	<category: 'instance creation'>
	| aView |
	aView := self new.
	aView parentView: view.
	aView blox: (BForm new: view blox).
	^aView
    ]

    replaceArgWith: arg in: selectorsArray [
	<category: 'initializing'>
	| selectors |
	selectors := selectorsArray deepCopy.

	"(label unarySelector)) should not be changed
	 (label keywordSelector arg) should be changed"
	selectorsArray with: selectors
	    do: 
		[:item :changed | 
		(item size > 2 and: [(item at: 2) numArgs >= 1]) 
		    ifTrue: [changed at: 3 put: arg]].
	^selectors
    ]

    selectors: selectorsArray receiver: receiver [
	<category: 'initializing'>
	| selectors size |
	selectors := selectorsArray reject: [:each | each isEmpty].
	size := self blox width / selectors size.
	selectors keysAndValuesDo: 
		[:x :sel | 
		| msg buttonView |
		msg := sel size = 2 
			    ifTrue: [sel at: 2]
			    ifFalse: [Message selector: (sel at: 2) arguments: {sel at: 3}].
		buttonView := PButton 
			    parentView: self
			    data: receiver
			    label: (sel at: 1)
			    handleUserChange: msg.
		buttonView blox 
		    x: (x - 1) * size
		    y: 0
		    width: size
		    height: self blox height]
    ]

    selectors: selectors receiver: receiver argument: arg [
	<category: 'initializing'>
	self selectors: (self replaceArgWith: arg in: selectors) receiver: receiver
    ]
]

PK
     �Zh@�^��      package.xmlUT	 ��XO��XOux �  �  <package>
  <name>BLOXBrowser</name>
  <namespace>BLOX.BLOXBrowser</namespace>
  <provides>Browser</provides>
  <prereq>Blox</prereq>
  <prereq>DebugTools</prereq>
  <prereq>Parser</prereq>

  <filein>Load.st</filein>
  <filein>GuiData.st</filein>
  <filein>View.st</filein>
  <filein>Manager.st</filein>
  <filein>RadioForm.st</filein>
  <filein>Menu.st</filein>
  <filein>ModalDialog.st</filein>
  <filein>PList.st</filein>
  <filein>PText.st</filein>
  <filein>PCode.st</filein>
  <filein>ButtonForm.st</filein>
  <filein>BrowShell.st</filein>
  <filein>BrowserMain.st</filein>
  <filein>ClassHierBrow.st</filein>
  <filein>ClassBrow.st</filein>
  <filein>NamespBrow.st</filein>
  <filein>MethSetBrow.st</filein>
  <filein>Inspector.st</filein>
  <filein>DictInspect.st</filein>
  <filein>MethInspect.st</filein>
  <filein>StrcInspect.st</filein>
  <filein>DebugSupport.st</filein>
  <filein>Debugger.st</filein>
  <filein>Notifier.st</filein>
  <file>ChangeLog</file>
  <start>BLOX.BLOXBrowser.BrowserMain new initialize</start>
</package>PK
     �Mh@�l+  +    ModalDialog.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI wrapper for modal dialogs
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller.
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
 ======================================================================
"



BLOX.Gui subclass: ModalDialog [
    | dialogShell messageDispatch |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    display: parent [
	<category: 'displaying'>
	dialogShell map.
	blox loop
    ]

    addButton: label message: block [
	<category: 'initialization'>
	messageDispatch at: messageDispatch size + 1 put: block.
	blox 
	    addButton: label
	    receiver: self
	    index: messageDispatch size
    ]

    alertMessage: queryString in: parent [
	<category: 'initialization'>
	self message: queryString in: parent.
	self addButton: 'Ok' message: [].
	self display: parent
    ]

    message: queryString in: parent [
	"Initialize dialog and button actions"

	<category: 'initialization'>
	messageDispatch := LookupTable new.
	dialogShell := BTransientWindow new: 'Modal dialog'
		    in: parent rootView blox.
	dialogShell width: 200 height: 140.
	blox := BDialog 
		    new: dialogShell
		    label: queryString
		    prompt: nil
    ]

    dispatch: index [
	<category: 'private'>
	(messageDispatch at: index) value
    ]
]



BLOX.Gui subclass: Prompter [
    | defaultResponse |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    Prompter class >> message: aString default: aResponse in: view [
	<category: 'instance creation'>
	^self new 
	    message: aString
	    default: aResponse
	    in: view
    ]

    Prompter class >> message: aString in: view [
	<category: 'instance creation'>
	^self new 
	    message: aString
	    default: ''
	    in: view
    ]

    Prompter class >> openFileName: aString default: default in: view [
	<category: 'instance creation'>
	^BDialog 
	    chooseFileToOpen: view rootView blox
	    label: aString
	    default: default
	    defaultExtension: 'st'
	    types: #(#('Smalltalk files' '.st') #('Text files' '.txt'))
    ]

    Prompter class >> saveFileName: aString default: default in: view [
	<category: 'instance creation'>
	^BDialog 
	    chooseFileToSave: view rootView blox
	    label: aString
	    default: default
	    defaultExtension: 'st'
	    types: #(#('Smalltalk files' '.st') #('Text files' '.txt'))
    ]

    accept [
	"Truncate string after newline character"

	<category: 'accessing'>
	| index |
	defaultResponse := blox contents.
	(index := defaultResponse findFirst: [:ch | ch == Character nl]) > 0 
	    ifTrue: [defaultResponse := defaultResponse copyFrom: 1 to: index - 1]
    ]

    cancel [
	<category: 'accessing'>
	defaultResponse := ''
    ]

    response [
	"Return default response"

	<category: 'accessing'>
	^defaultResponse
    ]

    message: queryString default: aResponse in: view [
	"Prompt user for string input.  The default response, queryString, is displayed in
	 text portion"

	<category: 'initialize-delete'>
	| dialogShell |
	defaultResponse := aResponse.
	dialogShell := BTransientWindow new: 'Prompter dialog'
		    in: view rootView blox.
	dialogShell width: 300 height: 180.
	self blox: (BDialog 
		    new: dialogShell
		    label: queryString
		    prompt: aResponse).
	blox 
	    addButton: 'OK'
	    receiver: self
	    message: #accept.
	blox 
	    addButton: 'Cancel'
	    receiver: self
	    message: #cancel.
	dialogShell map.
	self blox loop
    ]
]

PK
     �Mh@t8M��  �    ClassBrow.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI class hierarchy browser
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2002 Free Software Foundation, Inc.
| Written by Brad Diller and Paolo Bonzini.
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
 ======================================================================
"



ClassHierarchyBrowser subclass: ClassBrowser [
    | startingClass |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    createTopView [
	<category: 'initializing'>
	^BrowserShell new: 'Class Browser on %1' % {startingClass}
    ]

    openOn: aClass [
	"Create and open a class hierarchy browser on startingClass"

	<category: 'initializing'>
	startingClass := aClass.
	super open
    ]

    topClasses [
	<category: 'overrides'>
	^{startingClass}
    ]
]

PK
     �Mh@�F,  ,    BrowserMain.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI `outside the classes' method
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller.
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
 ======================================================================
"



GuiData subclass: BrowserMain [
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    Shell := nil.
    SavedState := nil.
    Windows := nil.
    HandleErrorsWithGui := nil.

    BrowserMain class >> addWindow: toplevel [
	<category: 'accessing'>
	Windows add: toplevel
    ]

    BrowserMain class >> checkExit [
	<category: 'accessing'>
	^Windows isNil or: [Windows allSatisfy: [:w | w canClose]]
    ]

    BrowserMain class >> close [
	"This method is invoked before quitting the browser and before saving the
	 Smalltalk image.  When the system is launched subsequently, it is important
	 that the shell be nil until the browser is initialized.  Other methods use the
	 state of this variable (Shell) to probe the browser's initialization status"

	<category: 'accessing'>
	Shell := nil
    ]

    BrowserMain class >> handleErrorsWithGui [
	<category: 'accessing'>
	^HandleErrorsWithGui
    ]

    BrowserMain class >> handleErrorsWithGui: aBoolean [
	<category: 'accessing'>
	HandleErrorsWithGui := aBoolean
    ]

    BrowserMain class >> removeWindow: toplevel [
	<category: 'accessing'>
	Windows remove: toplevel
    ]

    BrowserMain class >> shell [
	"Return application widget pointer.  This method is used to determine whether
	 the Tk and browser environment is initialized.  If 'shell' is non-nil, the
	 environment is completely initialized"

	<category: 'accessing'>
	^Shell
    ]

    BrowserMain class >> update: aspect [
	"There is no guarantee that the image will be loaded running the
	 browser. So some variables must be nil'ed out.
	 
	 The class variable, 'Shell', is used, secondarily as a flag to
	 indicate initialization status.  If it is nil, the browser does
	 not attempt to display a Notifier or some other type of window
	 before the Tk and Smalltalk system has been initialized"

	<category: 'accessing'>
	aspect == #aboutToSnapshot 
	    ifTrue: 
		[SavedState := Transcript message -> Shell.
		Transcript message: stdout -> #nextPutAllFlush:.
		self handleErrorsWithGui: false.
		Shell := nil].
	aspect == #finishedSnapshot 
	    ifTrue: 
		[SavedState isNil ifTrue: [^self].
		Shell := SavedState value.
		self handleErrorsWithGui: true.
		Transcript message: SavedState key.
		SavedState := nil]
    ]

    BrowserMain class >> windowsDo: aBlock [
	<category: 'accessing'>
	Windows do: aBlock
    ]

    BrowserMain class >> directQuit [
	<category: 'blue button messages'>
	self checkExit ifFalse: [^self beep].
	self shell release.
	Blox terminateMainLoop.
	ObjectMemory quit
    ]

    BrowserMain class >> garbageCollect [
	"Force a full garbage collection in order to dispose of all unreferenced
	 instances"

	<category: 'blue button messages'>
	ObjectMemory compact
    ]

    BrowserMain class >> fileIn [
	<category: 'blue button messages'>
	| fileName |
	fileName := Prompter 
		    openFileName: 'Which file do you want me to read?'
		    default: '*.st'
		    in: Shell.
	fileName isNil ifFalse: [FileStream fileIn: fileName]
    ]

    BrowserMain class >> openBrowser [
	<category: 'blue button messages'>
	ClassHierarchyBrowser new open
    ]

    BrowserMain class >> openNamespaceBrowser [
	<category: 'blue button messages'>
	NamespaceBrowser new open
    ]

    BrowserMain class >> openWorksheet [
	<category: 'blue button messages'>
	^BrowserShell openWorksheet: 'Worksheet'
    ]

    BrowserMain class >> openWorksheet: label [
	<category: 'blue button messages'>
	^BrowserShell openWorksheet: label
    ]

    BrowserMain class >> quit [
	"Quit Smalltalk browser"

	<category: 'blue button messages'>
	| exit |
	self checkExit ifFalse: [^self beep].
	exit := false.
	(ModalDialog new)
	    message: 'Save image before quitting?' in: self shell;
	    addButton: 'Yes'
		message: 
		    [self saveImage.
		    exit := true];
	    addButton: 'No' message: [exit := true];
	    addButton: 'Cancel' message: [];
	    display: self shell.
	exit ifFalse: [^false].
	self shell release.
	Blox terminateMainLoop.
	ObjectMemory quit.
	^true
    ]

    BrowserMain class >> saveImageAs [
	"Save a snapshot on a file the user chooses."

	<category: 'blue button messages'>
	| fileName |
	fileName := Prompter 
		    saveFileName: 'Save image as'
		    default: ImageFileName
		    in: Shell.
	fileName isNil 
	    ifFalse: 
		[ObjectMemory snapshot: fileName.
		ImageFileName := fileName	"Are we sure?"]
    ]

    BrowserMain class >> saveImage [
	"Save a snapshot"

	<category: 'blue button messages'>
	ObjectMemory snapshot
    ]

    initialize [
	"Initialize Tk environment.  Create a transcript which will be used to
	 operate the browser.  It has a menu from which the user can select the
	 desired menu option"

	<category: 'initializing'>
	| win transcriptAndShell |
	self class handleErrorsWithGui: false.
	Smalltalk addFeature: #EventLoop.
	Shell := nil.
	Windows := Set new.
	transcriptAndShell := BrowserShell openWorksheet: 'Smalltalk Transcript'
		    withText: (Version copyWith: Character nl).
	(Smalltalk includesKey: #GTK) 
	    ifTrue: ['FIXME GTK bindings not ready for GUI transcript' printNl]
	    ifFalse: [Transcript message: transcriptAndShell value -> #insertAtEnd:].
	Shell := transcriptAndShell key.
	Shell data: self.
	win := Shell blox.
	win callback: self class message: #quit.
	self class handleErrorsWithGui: true.
	Shell display.
	Blox dispatchEvents.
	Shell blox exists ifTrue: [Shell blox destroy].
	self class handleErrorsWithGui: false.
	Shell := nil
    ]

    addWindow: toplevel [
	<category: 'window maintenance'>
	^Windows add: toplevel
    ]

    removeWindow: toplevel [
	<category: 'window maintenance'>
	^Windows remove: toplevel
    ]
]



Eval [
    BrowserMain handleErrorsWithGui: false.
    ObjectMemory addDependent: BrowserMain
]

PK
     �Mh@Tl��(  (    BrowShell.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI window base classs
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
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
 ======================================================================
"



Object subclass: BrowserShellMenuTemplate [
    | label selectors handler |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    BrowserShellMenuTemplate class >> label: label selectors: anArray handler: aOneArgumentBlock [
	<category: 'instance creation'>
	^self new 
	    label: label
	    selectors: anArray
	    handler: aOneArgumentBlock
    ]

    defineIn: aShell [
	<category: 'custom menus'>
	aShell menu: ((Menu new: aShell label: label) 
		    selectors: selectors
		    receiver: (handler value: aShell)
		    argument: aShell)
    ]

    label: aString selectors: anArray handler: aOneArgumentBlock [
	<category: 'private'>
	label := aString.
	selectors := anArray.
	handler := aOneArgumentBlock
    ]
]



TopLevelShell subclass: BrowserShell [
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    Menus := nil.

    BrowserShell class >> openWorksheet: label [
	<category: 'browsing'>
	| aBText |
	aBText := (self openWorksheet: label withText: (String with: Character nl)) 
		    value.
	^TextCollector message: aBText -> #insertAtEnd:
    ]

    BrowserShell class >> openWorksheet: label withText: startText [
	"Open a worksheet window."

	<category: 'browsing'>
	| worksheet textView |
	worksheet := self new: label.
	worksheet addChildView: ((textView := PWorksheetText new: worksheet)
		    menuInit: ((PopupMenu new: textView label: 'Edit') 
				selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste) #() #('Clear' #gstClear) #() #('Line...' #line) #('Find...' #find) #() #('Do it' #eval) #('Print it' #evalAndPrintResult) #('Inspect' #evalAndInspectResult) #() #('Senders' #senders) #('Implementors' #implementors))
				receiver: textView
				argument: nil);
		    textMsg: #text;
		    canBeDirty: false;
		    yourself).
	textView blox contents: startText.
	textView setEvaluationKeyBindings.
	worksheet blox x: 0.
	worksheet blox y: 75.
	worksheet blox height: 175.
	worksheet blox width: 300.
	worksheet blox map.
	^worksheet -> textView blox
    ]

    BrowserShell class >> addMenu: label selectors: anArray handler: aOneArgumentBlock [
	<category: 'custom menus'>
	Menus addLast: (BrowserShellMenuTemplate 
		    label: label
		    selectors: anArray
		    handler: aOneArgumentBlock)
    ]

    BrowserShell class >> initialize [
	<category: 'custom menus'>
	Menus := OrderedCollection new.
	self 
	    addMenu: 'Smalltalk'
	    selectors: #(#('Worksheet' #openWorksheet) #('Class Hierarchy Browser' #openBrowser) #('Namespace Browser' #openNamespaceBrowser) #() #('Save image' #saveImage) #('Save image as...' #saveImageAs) #('Garbage collect' #garbageCollect) #() #('File in...' #fileIn) #() #('Exit without saving image' #directQuit) #('Exit...' #quit))
	    handler: [:shell | BrowserMain]
    ]

    initialize: aLabel [
	<category: 'initialize'>
	super initialize: aLabel.
	Menus do: [:each | each defineIn: self]
    ]
]



Eval [
    BrowserShell initialize
]

PK
     �Mh@d��  �    DictInspect.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI inspector for Dictionaries
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller.
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
 ======================================================================
"



InspectorFieldList subclass: DictionaryInspectorFieldList [
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    currentField: assoc [
	"Set list selection to value of index.  Force a text view update"

	<category: 'accessing'>
	assoc key <= 1 
	    ifTrue: [currentField := assoc key]
	    ifFalse: [currentField := fields at: assoc key]
    ]

    fieldsSortBlock [
	<category: 'accessing'>
	^[:a :b | a = 'self' or: [b ~= 'self' and: [a displayString <= b displayString]]]
    ]

    computeFieldList: anObject [
	"Return sorted list of keys from set of Associations stored in fields"

	<category: 'accessing'>
	fields add: 'self'.
	fields addAll: anObject keys
    ]

    inspectMenu: listView [
	"Initialize menu for variable list pane"

	<category: 'initializing'>
	^(PopupMenu new: listView) 
	    selectors: #(#('Inspect' #evalAndInspectResult: #listView) #('References' #references: #listView) #() #('Add key...' #addField: #listView) #('Remove...' #removeField: #listView))
	    receiver: self
	    argument: listView
    ]

    currentFieldValue: obj [
	<category: 'private'>
	self value at: currentField put: obj
    ]

    currentFieldValue [
	<category: 'private'>
	currentField == 0 ifTrue: [^nil].
	currentField == 1 ifTrue: [^self value].
	^self value at: currentField
    ]

    addField: listView [
	"Prompt user for the name of new dictionary key.  If name is valid, add it
	 to dictionary"

	<category: 'variable list menu'>
	| key |
	listView canChangeState ifFalse: [^self].
	key := (Prompter message: 'Enter a new field' in: listView) response.
	key isEmpty ifTrue: [^self].
	(key at: 1) == $# 
	    ifTrue: [key := (key copyFrom: 2 to: key size) asSymbol]
	    ifFalse: [key isNumeric ifTrue: [key := key asNumber]].

	"If new key already exists, reject"
	(self value includesKey: key) 
	    ifTrue: 
		[^ModalDialog new 
		    alertMessage: 'Invalid name: the key, ' , key , ', already exists.'
		    in: listView].

	"Update variable selection"
	currentField := key.
	"Update dictionary"
	self value at: key put: nil.
	"Update instance variable governing variable list pane display"
	fields add: key.
	"Update text view"
	inspector
	    changeState: #fieldList;
	    changeState: #text.
	Primitive updateViews
    ]

    references: listView [
	"Open a method set browser on all methods which reference selected key"

	<category: 'variable list menu'>
	| alert keyRefs theKey |
	currentField <= 1 ifTrue: [^listView beep].
	keyRefs := SortedCollection new.
	Namespace current allClassObjectsDo: 
		[:subclass | 
		(subclass whichSelectorsReferTo: (self value associationAt: currentField)) 
		    do: [:sel | keyRefs add: subclass printString , ' ' , sel]].
	keyRefs isEmpty 
	    ifTrue: 
		[^alert := ModalDialog new 
			    alertMessage: 'No references to ' , currentField printString
			    in: listView].
	MethodSetBrowser new 
	    openOn: keyRefs
	    title: 'References to ' , currentField printString
	    selection: currentField displayString
    ]

    removeField: listView [
	"Remove selected key from dictionary"

	<category: 'variable list menu'>
	| cancel |
	currentField isNil ifTrue: [^listView beep].
	(ModalDialog new)
	    message: 'Are you sure you want to remove, ' , currentField displayString 
			, '?'
		in: listView;
	    addButton: 'Yes' message: [cancel := false];
	    addButton: 'No' message: [cancel := true];
	    display: listView.
	cancel ifTrue: [^self].
	"Remove key from dictionary"
	self value removeKey: currentField.
	"Remove the association composed of the key and the value from the data object"
	fields remove: currentField.
	currentField := 0.
	"Force a text view update to reflect deleted key"
	inspector
	    changeState: #fieldList;
	    changeState: #text.
	Primitive updateViews
    ]
]



Dictionary extend [

    inspectorFieldLists [
	"Open a DictionaryInspectorFieldList window on self"

	<category: 'debugging'>
	^
	{'Keys' -> (BLOX.BLOXBrowser.DictionaryInspectorFieldList new value: self).
	'Basic' -> (BLOX.BLOXBrowser.ObjectInspectorFieldList new value: self)}
    ]

]

PK
     �Mh@�l�c  c    View.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI base class for widget wrappers with publish/subscribe
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller.
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
 ======================================================================
"



BLOX.Gui subclass: View [
    | data parentView childViews |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    View class >> new: aString in: view [
	<category: 'instance creation'>
	| aView |
	aView := self new.
	aView parentView: view.
	^aView
    ]

    data [
	"Return view's data object"

	<category: 'accessing'>
	^data
    ]

    allPrimitivesDo: aBlock [
	"Note that this test is a necessary but not a sufficient condition of a
	 Primitive view -- a partially created window can have a Manager which has
	 no children"

	<category: 'change management'>
	childViews notNil 
	    ifTrue: [childViews do: [:view | view allPrimitivesDo: aBlock]]
	    ifFalse: [aBlock value: self]
    ]

    canChangeState [
	<category: 'change management'>
	| aCollection |
	aCollection := OrderedCollection new.
	self rootView 
	    allPrimitivesDo: [:view | view == self ifFalse: [view canUpdate ifFalse: [^false]]].
	^true
    ]

    canUpdate [
	"Default is to return true"

	<category: 'change management'>
	^true
    ]

    collectPrimitives: aCollection [
	"Note that this test is a necessary but not a sufficient condition of a
	 Primitive view -- a partially created window can have a Manager which has
	 no children"

	<category: 'change management'>
	childViews notNil 
	    ifTrue: [childViews do: [:view | view collectPrimitives: aCollection]]
	    ifFalse: [aCollection add: self]
    ]

    childViews [
	"Return the view's collection of childViews"

	<category: 'childViews and parentViews'>
	^childViews
    ]

    parentView [
	"Return view's parentView.  If view is a rootView, nil is returned"

	<category: 'childViews and parentViews'>
	^parentView
    ]

    parentView: aView [
	"Set parentView to aView"

	<category: 'childViews and parentViews'>
	parentView := aView
    ]

    rootView [
	"Return rootView in view's hierarchy"

	<category: 'childViews and parentViews'>
	^parentView isNil ifTrue: [self] ifFalse: [parentView rootView]
    ]

    beep [
	"Beep once -- usually called when some user error is detected"

	<category: 'display'>
	Blox beep
    ]

    remove [
	<category: 'initialize-delete'>
	data := nil.
	childViews isNil ifFalse: [childViews do: [:view | view remove]].
	parentView := childViews := nil
    ]
]



View subclass: Primitive [
    | menu dirty stateChangeMsg messageDispatch |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    Primitive class >> updateViews [
	"Update all the primitive views"

	<category: 'displaying'>
	BrowserMain windowsDo: [:i | i allPrimitivesDo: [:view | view update]]
    ]

    Primitive class >> new [
	<category: 'initialize'>
	^(super new)
	    dirty: false;
	    yourself
    ]

    data: aData [
	<category: 'accessing'>
	data := aData
    ]

    dirty: aBoolean [
	<category: 'accessing'>
	dirty := aBoolean
    ]

    isDirty [
	<category: 'accessing'>
	^dirty
    ]

    menu [
	<category: 'accessing'>
	^menu
    ]

    close [
	<category: 'blue button menu items'>
	^self rootView close
    ]

    display [
	"Overridden in subclasses.  This method is used to support change/update
	 mechanism.  In the normal case, this method redraws entire view"

	<category: 'displaying'>
	^self subclassResponsibility
    ]

    getViewState [
	<category: 'displaying'>
	^messageDispatch
    ]

    update: stateChanges [
	"Update object based on stateChanges"

	<category: 'displaying'>
	stateChanges do: 
		[:sc | 
		| viewState |
		viewState := messageDispatch at: sc state.
		viewState updateTo: sc counter]
    ]

    update [
	"Send a getStateChanges: currentViewState message to data object to compute state
	 changes. Send a update: stateChanges message to self to update object"

	<category: 'displaying'>
	| stateChanges |
	data isNil ifTrue: [^self].
	stateChanges := data getStateChanges: self getViewState.
	stateChanges notNil ifTrue: [self update: stateChanges]
    ]

    handleUserChange: changeSelector [
	"This is used to update the data object in response to a user
	 modification of the view"

	<category: 'initialize-delete'>
	stateChangeMsg := changeSelector
    ]

    menuInit: theMenu [
	"The popup menu, theMenu, is stored in menu"

	<category: 'initialize-delete'>
	menu := theMenu
    ]

    stateChange: theStateChange updateWith: block [
	<category: 'initialize-delete'>
	messageDispatch isNil ifTrue: [messageDispatch := LookupTable new].
	messageDispatch at: theStateChange
	    put: (GuiState 
		    state: theStateChange
		    counter: 0
		    action: block)
    ]
]

PK
     �Mh@[ʛ�+  �+    PText.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI wrapper for text widgets
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003 Free Software Foundation, Inc.
| Written by Brad Diller.
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
 ======================================================================
"



Primitive subclass: PText [
    | textMsg selection canBeDirty object |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    PText class >> bloxClass [
	<category: 'instance creation'>
	^BText
    ]

    PText class >> new: parent [
	<category: 'instance creation'>
	| view |
	view := self new.
	view canBeDirty: true.
	view parentView: parent.
	view blox: (self bloxClass new: parent blox).
	view blox callback: view message: 'setDirtyFlag'.
	^view
    ]

    PText class >> newReadOnly: parent [
	<category: 'instance creation'>
	| view |
	view := self new.
	view parentView: parent.
	view blox: (self bloxClass newReadOnly: parent blox).
	"view blox backgroundColor: 'LemonChiffon'."
	^view
    ]

    getSelectionOrLine [
	"Answer the text currently selected or the text on the current line if
	 there's no text selected.  This enables Do It, Print It, and Inspect It
	 to be used without manually selecting text."

	<category: 'private'>
	| text |
	text := blox getSelection.
	(text isNil or: [text isEmpty]) ifTrue: [^blox lineAt: blox currentLine].
	^text
    ]

    compileIt [
	"Activated when the user selects 'accept' from the popup menu.  Send a
	 stateChangeMsg to the data object"

	<category: 'blue button menu items'>
	| text rejected |
	text := blox contents.
	(text isNil or: [text size = 0]) ifTrue: [^self beep].
	self canChangeState 
	    ifTrue: 
		[rejected := stateChangeMsg numArgs = 1 
			    ifTrue: 
				["One parameter selector"

				(data perform: stateChangeMsg with: blox contents) isNil]
			    ifFalse: 
				["Two parameter selector"

				(data 
				    perform: stateChangeMsg
				    with: blox contents
				    with: self) isNil].
		dirty := rejected & canBeDirty]
    ]

    eval [
	<category: 'blue button menu items'>
	| text pos |
	pos := blox currentLine.
	text := self getSelectionOrLine.
	(text isNil or: [text size = 0]) ifTrue: [^self beep].
	self doEval: text
	    ifError: [:fname :lineNo :errorString | self displayError: errorString at: lineNo + pos]
    ]

    doLine [
	"Perform a single line of code in a Worksheet or the Transcript window.
	 This actually executes the _previous_ line because Tcl/Tk passes through
	 the Return of the Control-Return keybinding to its text editor widget
	 before we get here."

	<category: 'blue button menu items'>
	| endPt |
	endPt := 1 @ blox currentLine.
	blox selectFrom: 1 @ (blox currentLine - 1) to: endPt.
	self eval.
	blox selectFrom: endPt to: endPt
    ]

    evalAndInspectResult [
	"Open an inspector on the result of the evaluation of the selected Smalltalk expression"

	<category: 'blue button menu items'>
	| obj text pos |
	pos := blox currentLine.
	text := self getSelectionOrLine.
	(text isNil or: [text size = 0]) ifTrue: [^self beep].
	obj := self doEval: text
		    ifError: 
			[:fname :lineNo :errorString | 
			self displayError: errorString at: lineNo + pos.
			^nil].
	obj inspect
    ]

    evalAndPrintResult [
	"Display and select result of evaluation of selected expression to right of
	 selection"

	<category: 'blue button menu items'>
	| text obj pos |
	pos := blox currentLine.
	text := self getSelectionOrLine.
	(text isNil or: [text size = 0]) ifTrue: [^self beep].
	obj := self doEval: text
		    ifError: 
			[:fname :lineNo :errorString | 
			self displayError: errorString at: lineNo + pos.
			^nil].
	blox insertTextSelection: obj printString
    ]

    find [
	<category: 'blue button menu items'>
	| prompter |
	prompter := Prompter message: 'Search...' in: self.
	prompter response ~= '' ifTrue: [blox searchString: prompter response]
    ]

    gstClear [
	<category: 'blue button menu items'>
	blox replaceSelection: ''
    ]

    gstCopy [
	<category: 'blue button menu items'>
	Blox clipboard: blox getSelection
    ]

    gstCut [
	<category: 'blue button menu items'>
	self gstCopy.
	self gstClear
    ]

    gstPaste [
	<category: 'blue button menu items'>
	| clip |
	clip := Blox clipboard.
	clip isEmpty ifFalse: [blox replaceSelection: clip]
    ]

    implementors [
	"Maybe getSelectionOrWord?"

	<category: 'blue button menu items'>
	self getSelectionOrLine 
	    ifNotNil: [:sel | MethodSetBrowser implementorsOf: sel asSymbol parent: self]
    ]

    line [
	"Prompt user to enter a line number.  If a valid number, attempt
	 to scroll to entered line number"

	<category: 'blue button menu items'>
	| prompter |
	prompter := Prompter message: 'Goto line...' in: self.
	prompter response isEmpty ifTrue: [^self].
	(prompter response allSatisfy: [:ch | ch isDigit]) 
	    ifTrue: [blox gotoLine: prompter response asInteger end: false]
    ]

    revert [
	"Revert text changes and replace current text with original text"

	<category: 'blue button menu items'>
	self display
    ]

    senders [
	"Maybe getSelectionOrWord?"

	<category: 'blue button menu items'>
	self getSelectionOrLine 
	    ifNotNil: [:sel | MethodSetBrowser sendersOf: sel asSymbol parent: self]
    ]

    canBeDirty [
	<category: 'displaying'>
	^canBeDirty
    ]

    canBeDirty: aBoolean [
	<category: 'displaying'>
	canBeDirty := aBoolean.
	dirty := dirty & canBeDirty
    ]

    canUpdate [
	"If text has been modified, display a prompter.  If the No button is
	 selected, return true"

	<category: 'displaying'>
	| cancel |
	data isNil ifTrue: [^true].
	canBeDirty ifFalse: [^true].
	dirty ifFalse: [^true].
	cancel := self 
		    confirm: 'The text has been altered.' , (String with: Character nl) 
			    , 'Do you wish to discard those changes?'.
	^cancel
    ]

    confirm: aString [
	"Used by canUpdate when the text has been modified.  If the user wishes to
	 discard the editing changes by pressing 1, the dirty flag is reset"

	<category: 'displaying'>
	(ModalDialog new)
	    message: aString in: self;
	    addButton: 'Yes' message: [dirty := false];
	    addButton: 'No' message: [];
	    display: self.
	^dirty not
    ]

    display [
	"Update text view.  Dirty flag is reset"

	<category: 'displaying'>
	textMsg isNil ifFalse: [self contents: (data perform: textMsg)].
	dirty := false
    ]

    displayError: errorString [
	"Insert error string at cursor and select it"

	<category: 'displaying'>
	self blox insertTextSelection: errorString
    ]

    displayError: errorString at: lineNo [
	"Display error string at end of line indicated by lineNo"

	<category: 'displaying'>
	(self blox gotoLine: lineNo end: true) = 0 
	    ifFalse: [self blox insertSelectedText: errorString]
	    ifTrue: [self beep]
    ]

    findString: aString [
	"Select aString in the text view.  If not found, beep"

	<category: 'displaying'>
	(blox searchString: aString) = 0 ifTrue: [self beep]
    ]

    selection: aString [
	<category: 'initializing'>
	selection := aString
    ]

    setBrowserKeyBindings [
	"Add key bindings for Accept, etc."

	<category: 'initializing'>
	#('Control-S') with: #(#compileIt)
	    do: 
		[:key :sel | 
		self blox 
		    onKeyEvent: key
		    send: sel
		    to: self]
    ]

    setEvaluationKeyBindings [
	"Add key bindings for Doit, Print it, etc."

	<category: 'initializing'>
	#('Meta-D' 'Meta-P' 'Meta-I' 'Control-Return') 
	    with: #(#eval #evalAndPrintResult #evalAndInspectResult #doLine)
	    do: 
		[:key :sel | 
		self blox 
		    onKeyEvent: key
		    send: sel
		    to: self]
    ]

    setDirtyFlag [
	"Set modification state of text view"

	<category: 'initializing'>
	dirty := canBeDirty
    ]

    stateChange: stateChangeKey [
	"Install message handler to redraw text pane in response to an stateChangeKey
	 message.  If there is text which is initially selected, select the text.  This
	 feature is utilized by some types of message set browsers"

	<category: 'initializing'>
	self stateChange: stateChangeKey
	    updateWith: 
		[self display.
		selection notNil ifTrue: [self findString: selection]]
    ]

    textMsg: textSelector [
	"The textSelector is supplied by the view's data object.  When invoked
	 from computeText, the text to be displayed is returned"

	<category: 'initializing'>
	textMsg := textSelector
    ]

    contents: text [
	<category: 'polymorphism'>
	blox contents: text
    ]

    object [
	<category: 'evaluation'>
	^object
    ]

    object: anObject [
	<category: 'evaluation'>
	object := anObject
    ]

    doEval: text ifError: aBlock [
	<category: 'evaluation'>
	^Behavior 
	    evaluate: text
	    to: object
	    ifError: aBlock
    ]
]



STInST.STInST.RBProgramNodeVisitor subclass: WorksheetVariableTracker [
    | vars class |
    
    <category: 'Graphics-Windows'>
    <comment: nil>

    initialize [
	<category: 'initialization'>
	vars := #('self' 'super' 'true' 'false' 'nil' 'thisContext') asSet.
	class := (Behavior new)
		    superclass: Object;
		    yourself
    ]

    objectClass [
	<category: 'accessing'>
	^class
    ]

    includesVariable: aString [
	<category: 'operation'>
	^aString first isUppercase or: [vars includes: aString]
    ]

    defineVariable: aString [
	<category: 'operation'>
	vars add: aString.
	class addInstVarName: aString
    ]

    acceptAssignmentNode: anRBAssignmentNode [
	<category: 'operation'>
	(self includesVariable: anRBAssignmentNode variable name) 
	    ifFalse: [self defineVariable: anRBAssignmentNode variable name].
	self visitNode: anRBAssignmentNode value
    ]
]



PText subclass: PWorksheetText [
    | variableTracker |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    PWorksheetText class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    initialize [
	"Use a lightweight class to evaluate the workspace expressions,
	 so that variables are kept across evaluations."

	<category: 'initialization'>
	variableTracker := WorksheetVariableTracker new.
	self object: variableTracker objectClass new
    ]

    doEval: text ifError: aBlock [
	<category: 'initialization'>
	| nodes |
	nodes := STInST.RBParser parseExpression: text
		    onError: [:s :p | ^super doEval: text ifError: aBlock].
	variableTracker visitNode: nodes.
	^super doEval: text ifError: aBlock
    ]
]

PK
     �Mh@'@��  �  
  Manager.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI wrapper for windows with children
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller.
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
 ======================================================================
"



View subclass: Manager [
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    addChildView: aChildView [
	"Add childView to list of childViews of a view"

	<category: 'childViews'>
	childViews isNil 
	    ifTrue: 
		["Initialize childViews collection"

		childViews := OrderedCollection new].
	childViews add: aChildView.
	"Set parentView of aChildView to self"
	aChildView parentView: self
    ]

    addLabel: aString at: aPoint [
	<category: 'childViews'>
	(BLabel new: self blox label: aString) origin: aPoint
    ]

    addLabel: aString below: aPrimitive [
	<category: 'childViews'>
	(BLabel new: self blox label: aString) posVert: aPrimitive blox
    ]

    addLabel: aString rightOf: aPrimitive [
	<category: 'childViews'>
	(BLabel new: self blox label: aString) posHoriz: aPrimitive blox
    ]

    allPrimitivesDo: aBlock [
	<category: 'childViews'>
	childViews isNil ifTrue: [^self].
	super allPrimitivesDo: aBlock
    ]

    deleteChildView: aChildView [
	<category: 'childViews'>
	childViews notNil 
	    ifTrue: 
		[childViews remove: aChildView.
		aChildView remove]
    ]
]



Manager subclass: Form [
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    Form class >> new: aString in: view [
	<category: 'instance creation'>
	| aView |
	aView := super new: aString in: view.
	aView blox: (BForm new: view blox).
	^aView
    ]
]



Manager subclass: OrderedForm [
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    OrderedForm class >> new: aString in: view [
	<category: 'instance creation'>
	| aView |
	aView := super new: aString in: view.
	aView blox: (BContainer new: view blox).
	^aView
    ]

    OrderedForm class >> horizontal: aString in: view [
	<category: 'instance creation'>
	| result |
	result := self new: aString in: view.
	result blox setVerticalLayout: false.
	^result
    ]
]



Manager subclass: TopLevelShell [
    | menuBar |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    TopLevelShell class >> new: aLabel [
	"Initialize TopLevelShell"

	<category: 'instance creation'>
	| view |
	view := self new initialize: aLabel.
	BrowserMain shell isNil ifFalse: [BrowserMain addWindow: view].
	^view
    ]

    canClose [
	<category: 'closing'>
	self rootView allPrimitivesDo: [:view | view canUpdate ifFalse: [^false]].
	^true
    ]

    close [
	<category: 'closing'>
	| canClose |
	canClose := self canClose.
	canClose 
	    ifTrue: 
		[self blox destroy.
		self remove].
	^canClose
    ]

    destroyed [
	"This method is invoked from the callback which is activated when the
	 user closes a window.  Each view is sent an canUpdate message.  If
	 there is some information which has been cached and not incorporated
	 into the data object (modified text which has not been compiled), this
	 method will inform the callback by returning nil.  If the window can
	 be closed, the top level widget is returned.  The widget value is
	 needed so that the view's supporting widget hierarchy can be disposed
	 properly"

	<category: 'closing'>
	^self canClose
    ]

    remove [
	<category: 'closing'>
	super remove.
	BrowserMain removeWindow: self
    ]

    display [
	<category: 'displaying'>
	self blox map
    ]

    data: aData [
	"Even though this view is not properly a data view, the data view
	 is associated with a TopLevelShell to support change control. When a
	 user attempts to close the window, the close method which is invoked can
	 communicate this to the data objects's views by sending a message to the data
	 object associated with it."

	<category: 'initialize'>
	data := aData
    ]

    initialize: aLabel [
	<category: 'initialize'>
	blox := BWindow new: aLabel.
	self blox callback: self message: #destroyed.
	#('Control-1' 'Control-2' 'Control-3') 
	    with: #(#openWorksheet #openBrowser #openNamespaceBrowser)
	    do: 
		[:key :sel | 
		self blox 
		    onKeyEvent: key
		    send: sel
		    to: BrowserMain]
    ]

    menu: aMenu [
	<category: 'initialize'>
	self menuBar add: aMenu blox
    ]

    menuBar [
	<category: 'initialize'>
	menuBar isNil ifTrue: [menuBar := BMenuBar new: self blox].
	^menuBar
    ]
]

PK
     �Mh@��|5��  ��    ClassHierBrow.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI class hierarchy browser
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003,2007,2008 Free Software Foundation, Inc.
| Written by Brad Diller and Paolo Bonzini.
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
 ======================================================================
"



GuiData subclass: ClassHierarchyBrowser [
    | curClass curCategory curSelector textMode textView meta classList sortedMethodsByCategoryDict categoriesForClass topClasses shownClasses fileoutDir |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    classList [
	<category: 'accessing'>
	^classList
    ]

    classList: curClassList message: aMessage [
	"This method is used to implement selective updates of the class list
	 pane.  Currently the selected class, curClass, is unselected and the
	 instance variables, curSelector and curCategory, which are related
	 to the selected class, are reinitialized.  The message type, aMessage,
	 is sent to the data object.  The update method for the affected class
	 pane will update the portion which needs to be updated based on the
	 message type parameter, aMessage.  Other messages are posted through
	 the change/update mechanism so that the rest of the window will be
	 appropriately updated."

	<category: 'accessing'>
	classList := curClassList.
	curSelector := nil.
	curCategory := nil.
	textMode := #source.
	self
	    changeState: aMessage;
	    changeState: #methodCategories;
	    changeState: #methods.
	self changeState: #text.
	Primitive updateViews
    ]

    classSelection: assoc [
	"assoc contains current class selection.  Find the class associated with
	 the selected string in shownClasses dictionary.  Save the class in the
	 instance variable, curClass.  Update other related instance variables.  Since
	 the other panes in the browser descend from the class, the instance variables
	 associated with each pane must be nilled out.  Send update messages to the
	 data object"

	<category: 'accessing'>
	curClass := (assoc isNil or: [assoc value isNil]) 
		    ifTrue: [nil]
		    ifFalse: [shownClasses at: assoc value].
	textView object: curClass.
	curSelector := nil.
	curCategory := nil.
	textMode := #source.
	self
	    changeState: #methodCategories;
	    changeState: #methods.
	self changeState: #text.
	Primitive updateViews
    ]

    classString [
	"Return name of selected class indented by 'n' spaces, where 'n' is the number
	 of class' superclasses"

	<category: 'accessing'>
	| spaces |
	curClass isNil ifTrue: [^nil].
	spaces := String 
		    new: curClass allSuperclasses size * self indentString size.
	spaces atAllPut: Character space.
	^spaces , curClass name
    ]

    indentString [
	<category: 'accessing'>
	^'  '
    ]

    listMethodCategory: assoc [
	<category: 'accessing'>
	curCategory := assoc value.
	self methodCategory: curCategory
    ]

    meta [
	"If class methods are being viewed, return true"

	<category: 'accessing'>
	^meta
    ]

    meta: aBoolean [
	"Change instance/class representation and record data state changes"

	<category: 'accessing'>
	meta = aBoolean ifTrue: [^self].
	meta := aBoolean.
	curCategory := nil.
	curSelector := nil.
	self
	    changeState: #methodCategories;
	    changeState: #methods;
	    changeState: #text.
	Primitive updateViews
    ]

    method [
	"Return the selected method which is stored in curSelector"

	<category: 'accessing'>
	^curSelector
    ]

    method: assoc [
	"Set curSelector to aMethod, update text mode, and record state change"

	<category: 'accessing'>
	curSelector := assoc value.
	textMode := #source.
	self changeState: #text.
	Primitive updateViews
    ]

    methodCategories [
	"This method is invoked by the change/update mechanism when a new class is
	 selected.  To improve efficiency, method dictionary is cached.  Methods are
	 sorted by category and saved in a dictionary, sortedMethodByCategoryDict.
	 When a new category is selected, this dictionary is consulted.  The class's
	 method categories sorted by name are returned"

	<category: 'accessing'>
	| deClass category catSet |
	curClass isNil ifTrue: [^SortedCollection new].
	deClass := self getClass.
	categoriesForClass = deClass 
	    ifTrue: [^sortedMethodsByCategoryDict keys asSortedCollection].
	categoriesForClass := deClass.
	sortedMethodsByCategoryDict := Dictionary new.
	catSet := Set new.
	deClass selectors do: 
		[:aSelector | 
		catSet 
		    add: (category := (deClass compiledMethodAt: aSelector) methodCategory).
		(sortedMethodsByCategoryDict at: category
		    ifAbsent: [sortedMethodsByCategoryDict at: category put: SortedCollection new]) 
			add: aSelector].
	^catSet asSortedCollection
    ]

    methodCategory [
	<category: 'accessing'>
	^curCategory
    ]

    methodCategory: listItem [
	"Update curCategory.  Reinitialize the instance variable,
	 curSelector.  Notify affected panes through the change/update mechanism"

	<category: 'accessing'>
	curCategory := listItem.
	textMode := #source.
	self changeState: #methods.
	curSelector notNil ifTrue: [curSelector := nil].

	"Ask the data object whether the selector list view can
	 change it.  Deselect currently selected method and force
	 text pane, record state change and force update"
	textMode := #addMethod.
	self changeState: #text.
	Primitive updateViews
    ]

    methods [
	"Return the sorted methods for selected category"

	<category: 'accessing'>
	curCategory isNil ifTrue: [^Array new: 0].
	^sortedMethodsByCategoryDict at: curCategory ifAbsent: [Array new: 0]
    ]

    getAddMethodTemplate [
	"Return add method template"

	<category: 'accessing'>
	^'method: selectors and: arguments
    "Comment describing purpose and answered value."
    | temporary variables |
    statements
'
    ]

    text [
	"Return a text string depending on the text mode (textMode) of the data object"

	<category: 'accessing'>
	| aStream count |
	textMode == #addClass ifTrue: [^self getAddClassTemplate].
	curClass isNil 
	    ifTrue: 
		["If no class is selected, return empty string"

		^String new: 0].
	textMode == #comment 
	    ifTrue: 
		["Return comment associated with selected class"

		^self getClass comment isNil ifTrue: [''] ifFalse: [curClass comment]].
	textMode == #addMethod 
	    ifTrue: [^self getClass -> self getAddMethodTemplate].
	curSelector isNil 
	    ifTrue: 
		[aStream := WriteStream on: (String new: 0).
		curClass fileOutDeclarationOn: aStream.
		^aStream contents].
	"Display method source for selected class"
	^self getClass -> (self getClass >> curSelector) methodRecompilationSourceString
    ]

    addCategory: listView [
	"If a class is selected, prompt the user to enter a new message category.  If
	 a legitimate category is entered, update the method list pane (listView) and
	 System classes"

	<category: 'category list blue button menu'>
	| newCategory |
	curClass isNil ifTrue: [^listView beep].
	newCategory := (Prompter message: 'Enter a new message category'
		    in: listView) response.
	newCategory = '' ifTrue: [^self].

	"If new category already exists, reject"
	(sortedMethodsByCategoryDict includesKey: newCategory) 
	    ifTrue: 
		[^ModalDialog new 
		    alertMessage: 'Invalid name: the category, ' , newCategory 
			    , ', already exists.'
		    in: listView].
	sortedMethodsByCategoryDict at: newCategory put: SortedCollection new.
	self changeState: #methodCategories.
	self methodCategory: newCategory
    ]

    blueButtonMenuForCategories: theView [
	"Install popup menu for category pane"

	<category: 'category list blue button menu'>
	^(PopupMenu new: theView label: 'Protocol') 
	    selectors: #(#('File out...' #fileOutCategory: #theView) #() #('Add...' #addCategory: #theView) #('Rename...' #renameCategory: #theView) #('Remove...' #removeCategory: #theView))
	    receiver: self
	    argument: theView
    ]

    fileOutCategory: listView [
	"File out a description of the methods which belong to the selected method
	 category.  A file selection dialog is displayed which prompts the user for the
	 name and directory location of the file"

	<category: 'category list blue button menu'>
	| fileName deClass |
	curCategory isNil ifTrue: [^listView beep].
	deClass := self getClass.
	deClass name notNil 
	    ifTrue: [fileName := deClass name]
	    ifFalse: [fileName := deClass asClass name , '-class'].

	"If the name is too long, maybe truncate it?"
	fileName := self fileoutDir , fileName , '.' , curCategory , '.st'.
	fileName := Prompter 
		    saveFileName: 'File out category'
		    default: fileName
		    in: listView.
	fileName isNil 
	    ifFalse: 
		[deClass fileOutCategory: curCategory to: fileName.
		self setFileoutDirFromFile: fileName]
    ]

    removeCategory: listView [
	"Remove currently selected message category"

	<category: 'category list blue button menu'>
	| cancel |
	curCategory isNil ifTrue: [^listView beep].
	(ModalDialog new)
	    message: 'Are you sure you want to remove the category, ' , curCategory 
			, '?'
		in: listView;
	    addButton: 'Yes' message: [cancel := false];
	    addButton: 'No' message: [cancel := true];
	    display: listView.
	cancel ifTrue: [^self].
	"Update category list"
	self methods notNil 
	    ifTrue: 
		["Update sorted cache of class's message dictionary"

		sortedMethodsByCategoryDict removeKey: curCategory ifAbsent: [^self].
		self getClass removeCategory: curCategory].

	"Nil out curCategory and notify affected panes through the change/update
	 mechanism"
	curCategory := nil.
	self
	    changeState: #methodCategories;
	    changeState: #methods;
	    changeState: #text.
	Primitive updateViews
    ]

    renameCategory: listView [
	"Change selected message category name"

	<category: 'category list blue button menu'>
	| newName |
	curCategory isNil ifTrue: [^listView beep].
	"Prompt the user for new name"
	newName := (Prompter message: 'Rename message category: ' , curCategory
		    in: listView) response.
	newName isEmpty 
	    ifTrue: [^self]
	    ifFalse: 
		["If new category already exists, reject"

		(sortedMethodsByCategoryDict includesKey: newName) 
		    ifTrue: 
			[^ModalDialog new alertMessage: 'Invalid name: the category, ' , newName 
				    , ', already exists.'
			    in: listView]].

	"If new name is entered, update cache of sorted methods"
	sortedMethodsByCategoryDict at: newName
	    put: (sortedMethodsByCategoryDict at: curCategory).
	sortedMethodsByCategoryDict removeKey: curCategory.

	"Update system"
	self getClass methodDictionary do: 
		[:method | 
		method methodCategory = curCategory 
		    ifTrue: [method methodCategory: newName]].

	"Update instance variable and directly update the category pane (listView)"
	curCategory := newName.
	self changeState: #methodCategories.
	Primitive updateViews
    ]

    currentNamespace [
	<category: 'class hierarchy'>
	^Namespace current
    ]

    hierarchyNames: startingClasses [
	<category: 'class hierarchy'>
	| collection topMetas |
	shownClasses := Dictionary new: 100.
	^self makeDescendentsDictionary: (self makeFullTree: startingClasses)
	    thenPutOn: (WriteStream on: (Array new: 75))
    ]

    makeDescendentsDictionary: dict thenPutOn: stream [
	"From the dict Dictionary, created by #makeFullTree:, create
	 another with the same keys.  Each key is associated to a set of
	 classes which are all the immediate subclasses which are also
	 keys of dict.  Then this dictionary is passed to the recursive
	 method #printHierarchyOf:hierarchy:startAt:on:"

	<category: 'class hierarchy'>
	| descendents |
	descendents := dict collect: [:each | Set new].
	descendents at: #none put: Set new.
	dict keysDo: 
		[:each | 
		each superclass isNil 
		    ifTrue: [(descendents at: #none) add: each]
		    ifFalse: [(descendents at: each superclass) add: each]].
	^self 
	    printHierarchyOf: dict
	    hierarchy: descendents
	    startAt: #none
	    on: stream
	    indent: ''
    ]

    makeFullTree: classes [
	"From the classes collection, create a Dictionary in which we ensure
	 that every key's superclass is also a key.  For example, if
	 classes contained Object and Array, the dictionary would also have
	 Collection, SequenceableCollection and ArrayedCollection as keys.
	 For every key, its value is true if classes includes it, else it is
	 false."

	<category: 'class hierarchy'>
	| dict newClasses checkClasses |
	dict := IdentityDictionary new: classes size.
	classes do: [:each | dict at: each put: true].
	checkClasses := dict keys.
	
	[newClasses := Set new.
	checkClasses do: 
		[:each | 
		each superclass isNil 
		    ifFalse: 
			[(dict includesKey: each superclass) 
			    ifFalse: [newClasses add: each superclass]]].
	newClasses isEmpty] 
		whileFalse: 
		    [newClasses do: [:each | dict at: each put: false].
		    checkClasses := newClasses].
	^dict
    ]

    printHierarchyOf: dict hierarchy: desc startAt: root on: stream indent: indent [
	"Recursive worker method for #printHierarchyOf:on:
	 dict is the classes Dictionary as obtained by makeFullTree:,
	 desc is the classes Dictionary as passed by
	 makeDescendentsDictionary:thenCollectOn:"

	<category: 'class hierarchy'>
	| subclasses string |
	subclasses := desc at: root.
	subclasses := subclasses asSortedCollection: [:a :b | a name <= b name].
	subclasses do: 
		[:each | 
		| template |
		template := (dict at: each) ifTrue: ['%1%2'] ifFalse: ['%1(%2)'].
		string := template % 
				{indent.
				each nameIn: self currentNamespace}.
		shownClasses at: string put: each.
		stream nextPut: string.
		self 
		    printHierarchyOf: dict
		    hierarchy: desc
		    startAt: each
		    on: stream
		    indent: indent , self indentString].
	^stream contents
    ]

    addClass: classList [
	"When 'add' is selected from class pane popup menu, this action is invoked.
	 Update mode of text pane.  Nil out currently selected method and method
	 category.  Record state change"

	<category: 'class list blue button menu'>
	(curClass notNil and: [classList canChangeState]) 
	    ifFalse: [^classList beep].
	textMode := #addClass.
	curCategory := nil.
	curSelector := nil.
	self
	    changeState: #removeCategorySelection;
	    changeState: #methods;
	    changeState: #text.
	Primitive updateViews
    ]

    blueButtonMenuForClasses: theView [
	"Install popup for class list popup"

	<category: 'class list blue button menu'>
	^(PopupMenu new: theView label: 'Class') 
	    selectors: #(#('File out...' #fileOutClass: #theView) #('Update' #updateClassList) #() #('Compile' #compileClass: #theView) #('Compile all' #compileAll: #theView) #() #('Comment' #comment: #theView) #('References' #classRefs: #theView) #() #('Add' #addClass: #theView) #('Rename...' #renameClass: #theView) #('Remove...' #removeClass: #theView) #('Search...' #searchClass: #theView) #() #(#Inspect #inspectClass: #theView))
	    receiver: self
	    argument: theView
    ]

    classRefs: listView [
	"Activated from class pane popup menu.  Open a message set browser on all
	 methods that refer to currently selected class"

	<category: 'class list blue button menu'>
	| methods assoc |
	curClass isNil ifTrue: [^listView beep].
	methods := SortedCollection new.
	assoc := curClass environment associationAt: curClass name asSymbol.
	"For all selectors which refer to the selected class, add the class name
	 concatenated with selector name in the sorted collection 'methods'"
	CompiledMethod 
	    allInstancesDo: [:method | (method refersTo: assoc) ifTrue: [methods add: method]].
	methods isEmpty 
	    ifTrue: 
		[^ModalDialog new alertMessage: 'No references to ' , curClass name
		    in: listView].
	MethodSetBrowser new 
	    openOn: methods
	    title: 'References to ' , curClass name
	    selection: curClass name
    ]

    comment: aPList [
	"Change text mode to comment mode.  Trigger an update to the text and selector
	 panes"

	<category: 'class list blue button menu'>
	curClass isNil ifTrue: [^aPList beep].

	"Ask the data object whether the class list view can change itself"
	aPList canChangeState ifFalse: [^self].
	textView canChangeState ifFalse: [^self].
	textMode := #comment.

	"Deselect currently selected category and selector"
	curCategory := nil.
	curSelector := nil.
	self
	    changeState: #methodCategories;
	    changeState: #methods;
	    changeState: #text.
	Primitive updateViews
    ]

    compileAll: listView [
	"Activated from class list popup.  Recompile the selected class and its
	 subclasses.  The Metaclasses are recompiled as well"

	<category: 'class list blue button menu'>
	curClass isNil ifTrue: [^listView beep].
	curClass compileAll.
	curClass class compileAll.
	curClass compileAllSubclasses.
	curClass class compileAllSubclasses.
	self changeState: #methodCategories
    ]

    compileClass: listView [
	"Recompile selected class and its Metaclass"

	<category: 'class list blue button menu'>
	curClass isNil ifTrue: [^listView beep].
	curClass compileAll.
	curClass class compileAll.
	self changeState: #methodCategories
    ]

    inspectClass: listView [
	"Bring up an inspector on a Class"

	<category: 'class list blue button menu'>
	curClass inspect
    ]

    fileOutClass: listView [
	"File out a description of the currently selected class"

	<category: 'class list blue button menu'>
	| className fileName |
	curClass isNil ifTrue: [^listView beep].
	curClass name notNil 
	    ifTrue: [className := curClass name]
	    ifFalse: [className := curClass asClass name , '-class'].
	fileName := self fileoutDir , className , '.st'.
	fileName := Prompter 
		    saveFileName: 'File out class'
		    default: fileName
		    in: listView.
	fileName isNil 
	    ifFalse: 
		[curClass fileOut: fileName.
		self setFileoutDirFromFile: fileName]
    ]

    fileoutDir [
	<category: 'class list blue button menu'>
	| home |
	fileoutDir isNil 
	    ifTrue: 
		["If the image directory is a subdirectory of the home directory, the default is
		 the image directory. Else the default is the home directory"

		fileoutDir := Directory image name , '/'.
		home := Directory home name.
		home isEmpty 
		    ifFalse: 
			[fileoutDir size < home size ifTrue: [^fileoutDir := home , '/'].
			home = (fileoutDir copyFrom: 1 to: home size) 
			    ifTrue: [^fileoutDir := home , '/']]].
	^fileoutDir
    ]

    getAddClassTemplate [
	"Return add class template"

	<category: 'class list blue button menu'>
	| curClassName |
	curClassName := curClass isNil 
		    ifTrue: ['NameOfSuperClass']
		    ifFalse: [curClass printString].
	^curClassName 
	    , ' subclass: #NameOfClass
	instanceVariableNames:  ''''
	classVariableNames: ''''
	poolDictionaries: ''''
	category: nil
'
    ]

    removeClass: listView [
	"Remove selected class from system"

	<category: 'class list blue button menu'>
	| badClasses assoc classes cancel |
	curClass isNil ifTrue: [^listView beep].
	curClass subclasses isEmpty 
	    ifFalse: [^self error: 'Must delete subclasses first'].
	(ModalDialog new)
	    message: 'Are you sure you want to remove the class, ' , curClass name 
			, '?'
		in: listView;
	    addButton: 'Yes' message: [cancel := false];
	    addButton: 'No' message: [cancel := true];
	    display: listView.
	cancel ifTrue: [^self].

	"If there are any instance of curClass, disallow curClass to be removed.  Force
	 a garbage collection to get rid of unreferenced instances"
	(curClass instanceCount > 0 and: 
		[ObjectMemory compact.
		curClass instanceCount > 0]) 
	    ifTrue: [^self error: 'Cannot remove because class has instances.'].

	"Search system for all external references to class"
	badClasses := 
		{curClass.
		curClass class}.
	assoc := curClass environment associationAt: curClass name.
	Class allSubclassesDo: 
		[:subclass | 
		(badClasses includes: subclass) 
		    ifFalse: 
			[(subclass instanceClass whichSelectorsReferTo: assoc) do: 
				[:sel | 
				"Ignore references in transitory selector -- executeStatements"

				sel ~= #executeStatements 
				    ifTrue: 
					[^self error: 'External references remain to class which is to be deleted']].
			(subclass whichSelectorsReferTo: assoc) do: 
				[:sel | 
				"Ignore references in transitory selector -- executeStatements"

				sel ~= #executeStatements 
				    ifTrue: 
					[^self error: 'External references remain to class which is to be deleted']]]].
	curClass allSuperclassesDo: 
		[:each | 
		each removeSubclass: curClass.
		each class removeSubclass: curClass class].

	"Update namespace"
	curClass environment removeKey: curClass name asSymbol.
	self updateClassList.
	self classSelection: nil
    ]

    renameClass: listView [
	"Rename currently selected class"

	<category: 'class list blue button menu'>
	| methods oldName newName prompter oldAssoc |
	curClass isNil ifTrue: [^listView beep].
	oldName := curClass name.
	"Prompt user for new name"
	prompter := Prompter message: 'Rename class: ' , curClass name in: listView.
	prompter response isEmpty 
	    ifTrue: [^self]
	    ifFalse: 
		[newName := prompter response asSymbol.
		(newName at: 1) isUppercase 
		    ifFalse: 
			[^self error: 'Class name should begin with 
				   an uppercase letter'].
		(curClass environment includesKey: newName) 
		    ifTrue: [^self error: newName , ' already exists']].

	"Save old Association"
	oldAssoc := curClass environment associationAt: oldName.

	"Rename the class now"
	curClass setName: newName asSymbol.

	"Fix up namespace"
	curClass environment at: curClass name put: oldAssoc value.
	curClass environment removeKey: oldName.

	"Notify programmer of all references to renamed class"
	methods := SortedCollection new.
	CompiledMethod 
	    allInstancesDo: [:method | (method refersTo: oldAssoc) ifTrue: [methods add: method]].
	methods isEmpty 
	    ifFalse: 
		[ModalDialog new 
		    alertMessage: 'Rename all references to 
		    class ' , oldName 
			    , Character nl , 'to the new name: ' 
			    , newName
		    in: listView.
		MethodSetBrowser new 
		    openOn: methods
		    title: 'References to ' , oldName
		    selection: oldName].


	"Update class list"
	self updateClassList
    ]

    searchClass: listView [
	<category: 'class list blue button menu'>
	| newClass found |
	newClass := (Prompter message: 'Enter the class to be searched'
		    in: listView) response.
	newClass isEmpty ifTrue: [^self].
	"First pass, search for a qualified name."
	found := self searchClassIn: listView
		    suchThat: [:class | newClass sameAs: (class nameIn: self currentNamespace)].

	"Second pass, only look for the name."
	(found or: [newClass includes: $.]) 
	    ifFalse: 
		[found := self searchClassIn: listView
			    suchThat: [:class | newClass sameAs: class name]].
	found ifTrue: [^self].
	^ModalDialog new 
	    alertMessage: 'Invalid name: the class, ' , newClass , ', does not exist.'
	    in: listView
    ]

    searchClassIn: listView suchThat: aBlock [
	<category: 'class list blue button menu'>
	| class indent i listBlox numClasses |
	class := shownClasses detect: aBlock ifNone: [nil].
	class isNil ifTrue: [^false].
	curClass := class.
	textView object: curClass.
	listView select: self classString.
	^true
    ]

    setFileoutDirFromFile: fileName [
	<category: 'class list blue button menu'>
	fileoutDir := fileName copyFrom: 1 to: (fileName findLast: [:c | c = $/])
    ]

    topClasses [
	<category: 'class list blue button menu'>
	^Array streamContents: 
		[:stream | 
		Namespace current allClassesDo: [:each | stream nextPut: each]]
    ]

    updateClassList [
	"Invoked from class list pane popup.  Update class list pane through the
	 change/update mechanism"

	<category: 'class list blue button menu'>
	topClasses := self topClasses.
	topClasses size >= 2 
	    ifTrue: 
		[topClasses := topClasses asSortedCollection: [:a :b | a name <= b name]].
	self classList: (self hierarchyNames: topClasses) message: #classList
    ]

    createClassesListIn: upper [
	<category: 'initializing'>
	| list |
	upper addChildView: ((list := PList new: 'Classes' in: upper)
		    initialize;
		    data: self;
		    stateChange: #classList;
		    changedSelection: #newClassSelection;
		    handleUserChange: #classSelection:;
		    listMsg: #classList;
		    selectionMsg: #classString;
		    menuInit: (self blueButtonMenuForClasses: list);
		    yourself).
	"Register three types of messages"
	self layoutUpperPaneElement: list blox num: 0
    ]

    createLowerPaneIn: topView below: upper [
	<category: 'initializing'>
	topView addChildView: ((textView := PCode new: topView)
		    data: self;
		    stateChange: #text;
		    handleUserChange: #compile:from:;
		    setBrowserKeyBindings;
		    menuInit: (self blueButtonMenuForText: textView);
		    textMsg: #text;
		    yourself).
	(textView blox)
	    width: 600 height: 200;
	    posVert: upper blox;
	    inset: 2
    ]

    createProtocolListIn: upper [
	<category: 'initializing'>
	| pane list radioForm radioGroup |
	upper addChildView: (pane := OrderedForm new: 'Middle' in: upper).
	pane blox setVerticalLayout: true.
	self layoutUpperPaneElement: pane blox num: 1.

	"Add method categories list pane in middle third of window"
	pane addChildView: ((list := PList new: 'Categories' in: pane)
		    initialize;
		    data: self;
		    stateChange: #methodCategories;
		    changedSelection: #removeCategorySelection;
		    handleUserChange: #listMethodCategory:;
		    listMsg: #methodCategories;
		    selectionMsg: #methodCategory;
		    menuInit: (self blueButtonMenuForCategories: list);
		    yourself).
	list blox stretch: true.
	pane addChildView: (radioForm := RadioForm new: 'RadioGroup' in: pane).
	radioGroup := radioForm blox.
	radioForm addChildView: (PRadioButton 
		    on: self
		    parentView: radioGroup
		    isPressed: #meta
		    label: 'instance'
		    handleUserChange: #meta:
		    value: false).
	radioForm addChildView: (PRadioButton 
		    on: self
		    parentView: radioGroup
		    isPressed: #meta
		    label: 'class'
		    handleUserChange: #meta:
		    value: true)
    ]

    createSelectorListIn: upper [
	"Add selectors list pane in top right third of window"

	<category: 'initializing'>
	| list |
	upper addChildView: ((list := PList new: 'Selectors' in: upper)
		    initialize;
		    data: self;
		    stateChange: #methods;
		    handleUserChange: #method:;
		    listMsg: #methods;
		    selectionMsg: #method;
		    menuInit: (self blueButtonMenuForMethods: list);
		    yourself).
	self layoutUpperPaneElement: list blox num: 2
    ]

    createUpperPanesIn: upper [
	<category: 'initializing'>
	self createClassesListIn: upper.
	self createProtocolListIn: upper.
	self createSelectorListIn: upper
    ]

    initialize [
	<category: 'initializing'>
	self updateClassList
    ]

    layoutUpperPaneElement: blox num: n [
	<category: 'initializing'>
	blox 
	    x: 200 * n
	    y: 0
	    width: 200
	    height: 200
    ]

    createTopView [
	<category: 'initializing'>
	^BrowserShell new: 'Class Hierarchy Browser'
    ]

    open [
	"Create and open a class browser"

	<category: 'initializing'>
	| topView upper container win |
	meta := false.

	"Create top view"
	topView := self createTopView.
	topView data: self.
	win := topView blox.
	win 
	    x: 20
	    y: 50
	    width: 604
	    height: 404.
	upper := Form new: 'ListForms' in: topView.
	topView addChildView: upper.
	container := upper blox.
	container
	    x: 0
		y: 0
		width: 600
		height: 200;
	    inset: 2.
	self createUpperPanesIn: upper.
	self createLowerPaneIn: topView below: upper.
	self initialize.
	topView display
    ]

    compileMethod: aString for: aView [
	"Compile the method source, aString, for the selected class.  Compilation
	 class is set according to the radio button state.  If 'meta' is true, set
	 aClass to selected class, curClass, to its Metaclass.  If method is
	 successfully compiled, related instance variables are updated."

	<category: 'private'>
	| compiledMethod selector dupIndex collection aClass |
	aClass := meta ifTrue: [curClass class] ifFalse: [curClass].
	curCategory isNil 
	    ifTrue: 
		[curCategory := (Prompter 
			    message: 'Enter method category'
			    default: 'As yet unclassified'
			    in: aView) response.
		curCategory isEmpty ifTrue: [curCategory := 'As yet unclassified']].

	"The exception block will be invoked if aString contains parsing errors.  The
	 description of the error will be displayed and selected at the end of the line
	 in which the error is detected by the parser.  Nil is returned"
	compiledMethod := aClass 
		    compile: aString
		    classified: curCategory
		    ifError: 
			[:fname :lineNo :errorString | 
			aView displayError: errorString at: lineNo.
			^nil].

	"Retrieve selector"
	(compiledMethod selector = curSelector 
	    and: [compiledMethod methodCategory = curCategory]) 
		ifTrue: [^compiledMethod].

	"Need to do additional housekeeping to keep internal version of
	 method dictionary, sortedMethodsByCategoryDict, in synch with the class's
	 method dictionary. Remove duplicates stored in the internal version of
	 method dictionary"
	curSelector := compiledMethod selector.
	curCategory := compiledMethod methodCategory.
	sortedMethodsByCategoryDict 
	    do: [:methods | methods remove: curSelector ifAbsent: []].

	"Now add selector to internal copy"
	(sortedMethodsByCategoryDict at: curCategory
	    ifAbsentPut: [SortedCollection new]) add: curSelector.
	self changeState: #methods.
	self changeState: #methodCategories.
	Primitive updateViews.
	^compiledMethod
    ]

    getClass [
	"If 'meta' is true, return selected class's Metaclass; otherwise, selected
	 class is returned"

	<category: 'private'>
	meta ifTrue: [^curClass class] ifFalse: [^curClass]
    ]

    inspectMethod: listView [
	"Bring up an inspector on a Class"

	<category: 'selector list blue button menu'>
	curSelector isNil ifTrue: [^listView beep].
	(self getClass >> curSelector) inspect
    ]

    blueButtonMenuForMethods: theView [
	"Create method list pane menu"

	<category: 'selector list blue button menu'>
	^(PopupMenu new: theView label: 'Method') 
	    selectors: #(#('File out...' #fileOutSelector: #theView) #() #('Senders' #senders: #theView) #('Implementors' #implementors: #theView) #() #('Remove...' #removeMethod: #theView) #() #(#Inspect #inspectMethod: #theView))
	    receiver: self
	    argument: theView
    ]

    fileOutSelector: listView [
	"Creates a file containing description of selected method"

	<category: 'selector list blue button menu'>
	| deClass fileName |
	curSelector isNil ifTrue: [^listView beep].
	deClass := self getClass.
	deClass name notNil 
	    ifTrue: [fileName := deClass name]
	    ifFalse: [fileName := deClass asClass name , '-class'].

	"If the name is too long, maybe truncate it"
	fileName := self fileoutDir , fileName , '.' , curSelector , '.st'.
	fileName := Prompter 
		    saveFileName: 'File out selector'
		    default: fileName
		    in: listView.
	fileName isNil 
	    ifFalse: 
		[deClass fileOutSelector: curSelector to: fileName.
		self setFileoutDirFromFile: fileName]
    ]

    implementors: listView [
	"Open a message set browser that sends the currently selected message"

	<category: 'selector list blue button menu'>
	curSelector isNil ifTrue: [^listView beep].
	MethodSetBrowser implementorsOf: curSelector parent: listView
    ]

    removeMethod: listView [
	"Removes selected method"

	<category: 'selector list blue button menu'>
	| cancel |
	curSelector isNil ifTrue: [^listView beep].
	(ModalDialog new)
	    message: 'Are you sure you want to remove the method, ' , curSelector , '?'
		in: listView;
	    addButton: 'Yes' message: [cancel := false];
	    addButton: 'No' message: [cancel := true];
	    display: listView.
	cancel ifTrue: [^self].
	"Remove method from system"
	self getClass removeSelector: curSelector.
	(sortedMethodsByCategoryDict at: curCategory) remove: curSelector.
	"Update listView"
	curSelector := nil.
	"Record state change"
	self
	    changeState: #methods;
	    changeState: #text.
	Primitive updateViews
    ]

    senders: listView [
	"Open a message set browser that sends the currently selected message"

	<category: 'selector list blue button menu'>
	curSelector isNil ifTrue: [^listView beep].
	MethodSetBrowser sendersOf: curSelector parent: listView
    ]

    blueButtonMenuForText: theView [
	"Create menu for text pane"

	<category: 'text view blue button menu'>
	^(PopupMenu new: theView label: 'Edit') 
	    selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste) #() #('Clear' #gstClear) #() #('Line...' #line) #('Find...' #find) #() #('Do it' #eval) #('Print it' #evalAndPrintResult) #('Inspect' #evalAndInspectResult) #() #('Senders' #senders) #('Implementors' #implementors) #() #('Accept' #compileIt) #('Cancel' #revert) #() #('Close' #close))
	    receiver: theView
	    argument: nil
    ]

    compile: aString from: aView [
	"Compile aString derived from the text pane (aView).  The way aString is
	 compiled depends on the text mode"

	<category: 'text view blue button menu'>
	| aClass |
	curClass isNil ifTrue: [^aView beep].

	"If the text in the text pane is method source code, compile it"
	(curSelector notNil or: [textMode == #addMethod]) 
	    ifTrue: [^self compileMethod: aString for: aView].
	textMode == #comment 
	    ifTrue: 
		[curClass comment: aString.
		^aString].

	"Otherwise, evaluate the text.  If no method source is displayed, then
	 aString is evaluated independently.  If the string constitutes a legal
	 class definition, the class is returned in aClass"
	curClass environment whileCurrentDo: 
		[aClass := Behavior evaluate: aString ifError: [:file :line :msg | ^nil]].
	aClass isClass ifFalse: [^self].

	"If ClassHierarchyBrowser is modified, force an immediate exit
	 because this method context is still referencing it by the old memory
	 model"
	(self isKindOf: aClass) | (aClass == curClass) ifTrue: [^self].
	curClass := aClass.
	textView object: curClass.

	"Update class pane"
	(classList includes: aClass) 
	    ifTrue: 
		["If the class already exists, inform the class pane indirectly
		 through the change/update mechanism that the selection only
		 needs to be updated"

		self classList: classList message: #newClassSelection]
	    ifFalse: 
		["If the class does not exist, update instance variables
		 and inform the affected panes through the change/update mechanism"

		self updateClassList].
	textMode := #source
    ]
]

PK
     �Mh@�xR?�0  �0    Debugger.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI debugger window
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003,2007
| Free Software Foundation, Inc.
| Written by Brad Diller and Paolo Bonzini.
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
 ======================================================================
"



GuiData subclass: Debugger [
    | stacktrace contexts debugger activeContext receiverInspector stackInspector listView theClass theMethod textView topView |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    Debugger class >> debuggerClass [
	<category: 'class attributes'>
	^nil
    ]

    Debugger class >> debuggingPriority [
	<category: 'class attributes'>
	^1
    ]

    Debugger class >> new: notifier [
	<category: 'instance creation'>
	^self new init: notifier
    ]

    init: notifier [
	<category: 'initialize/release'>
	debugger := notifier debugger.
	[debugger suspendedContext isInternalExceptionHandlingContext] 
	    whileTrue: [debugger slowFinish].
	self createWindowFrom: notifier
    ]

    createWindowFrom: notifier [
	<category: 'initialize/release'>
	| toplevel container text buttonView lowerpane pane list context urpane lrpane |
	topView := (BrowserShell new: 'Debugger') data: self.
	toplevel := topView blox.
	toplevel 
	    x: 20
	    y: 50
	    width: 500
	    height: 350.
	pane := Form new: 'panes' in: topView.
	topView addChildView: pane.
	pane blox width: 500 height: 125.
	pane addChildView: ((listView := PList new: 'MethodSet' in: pane)
		    initialize;
		    data: self;
		    listMsg: #stacktrace;
		    dataMsg: #contexts;
		    handleUserChange: #contextSelectedFrom:;
		    stateChange: #stacktrace;
		    yourself).
	listView menuInit: ((PopupMenu new: listView label: 'Debug') 
		    selectors: self debugSelectors
		    receiver: self).
	listView blox width: 300 height: 100.
	pane addChildView: ((buttonView := ButtonForm new: 'Debugging' in: pane)
		    selectors: self debugSelectors receiver: self;
		    yourself).
	buttonView blox 
	    x: 0
	    y: 100
	    width: 300
	    height: 25.
	urpane := Form new: 'panes' in: pane.
	pane addChildView: urpane.
	urpane blox width: 200 height: 125.
	urpane blox posHoriz: listView blox.
	lowerpane := Form new: 'panes' in: topView.
	lowerpane blox posVert: pane blox.
	lowerpane blox width: 500 height: 225.
	topView addChildView: lowerpane.
	lowerpane addChildView: ((textView := PCode new: lowerpane)
		    data: self;
		    stateChange: #text;
		    handleUserChange: #compile:from:;
		    setBrowserKeyBindings;
		    textMsg: #text;
		    yourself).
	textView menuInit: ((PopupMenu new: textView label: 'Edit') 
		    selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste) #() #('Clear' #gstClear) #() #('Line...' #line) #('Find...' #find) #() #('Do it' #eval) #('Print it' #evalAndPrintResult) #('Inspect' #evalAndInspectResult) #() #('Senders' #senders) #('Implementors' #implementors) #() #('Accept' #compileIt) #('Cancel' #revert) #() #('Close' #close))
		    receiver: textView
		    argument: nil).
	text := textView blox.
	text width: 300 height: 225.
	lrpane := Form new: 'panes' in: lowerpane.
	lowerpane addChildView: lrpane.
	lrpane blox width: 200 height: 225.
	lrpane blox posHoriz: textView blox.
	stackInspector := (Inspector new)
		    fieldLists: (self stackFieldListsFor: notifier currentContext);
		    openIn: urpane menuName: 'Stack'.
	receiverInspector := (Inspector new)
		    fieldLists: (self receiverFieldListsFor: notifier currentContext receiver);
		    openIn: lrpane menuName: 'Receiver'.
	self updateContextList.
	self currentContext: notifier currentContext.
	topView display
    ]

    receiverFieldListsFor: anObject [
	<category: 'inspector panes'>
	^{'Primitive' -> (PrimitiveInspectorFieldList new value: anObject)} 
	    , anObject inspectorFieldLists
    ]

    stackFieldListsFor: context [
	<category: 'inspector panes'>
	^
	{'Variables' -> (StackInspectorFieldList new value: context).
	'Stack' -> (ObjectInspectorFieldList new value: context)}
    ]

    compile: aString from: aView [
	"Compile aString derived from text in text view for the selected selector"

	<category: 'text pane'>
	theMethod notNil 
	    ifTrue: 
		[theClass 
		    compile: aString
		    classified: theMethod methodCategory
		    ifError: 
			[:fname :lineNo :errorString | 
			aView displayError: errorString at: lineNo.
			^nil]]
    ]

    contextSelectedFrom: assoc [
	<category: 'text pane'>
	self currentContext: assoc value
    ]

    highlight: context [
	<category: 'text pane'>
	| line |
	line := context currentLine.
	(textView blox)
	    gotoLine: line end: false;
	    selectFrom: 1 @ line to: 1 @ (line + 1)
    ]

    contexts [
	<category: 'text pane'>
	^contexts
    ]

    stacktrace [
	<category: 'text pane'>
	^stacktrace
    ]

    text [
	"Return source code for the selected method"

	<category: 'text pane'>
	| source |
	^(theMethod notNil and: [(source := theMethod methodSourceString) notNil]) 
	    ifTrue: [theClass -> source]
	    ifFalse: ['']
    ]

    debugSelectors [
	<category: 'button pane'>
	^#(#('Step' #stepButtonCallback) #('Next' #nextButtonCallback) #('Finish' #finishButtonCallback) #('Continue' #continueButtonCallback) #() #('Kill' #killButtonCallback) #() #('Terminate' #terminateButtonCallback))
    ]

    updateAfter: aBlock [
	"If there's an exception, replace this window with another
	 notifier."

	<category: 'button pane'>
	aBlock on: SystemExceptions.DebuggerReentered
	    do: 
		[:ex | 
		topView close.
		Notifier openOn: debugger process.
		^self].
	self updateContextList
    ]

    stepButtonCallback [
	<category: 'button pane'>
	self updateAfter: [debugger step]
    ]

    nextButtonCallback [
	<category: 'button pane'>
	self updateAfter: [debugger next]
    ]

    finishButtonCallback [
	<category: 'button pane'>
	self updateAfter: [debugger finish: activeContext]
    ]

    continueButtonCallback [
	<category: 'button pane'>
	topView close.
	debugger continue
    ]

    killButtonCallback [
	<category: 'button pane'>
	topView close.
	debugger process primTerminate
    ]

    terminateButtonCallback [
	<category: 'button pane'>
	topView close.
	debugger process terminate.
	debugger continue
    ]

    updateContextList [
	<category: 'list pane'>
	| context lastContext |
	context := debugger suspendedContext.
	lastContext := context environment.
	stacktrace := OrderedCollection new.
	contexts := OrderedCollection new.
	[context == lastContext] whileFalse: 
		[context isDisabled 
		    ifFalse: 
			[stacktrace add: context printString.
			contexts add: context].
		context := context parentContext].
	self changeState: #stacktrace.
	self currentContext: debugger suspendedContext
    ]

    currentContext: context [
	<category: 'list pane'>
	activeContext := context.
	theMethod := context method.
	theClass := context methodClass.
	stackInspector fieldLists: (self stackFieldListsFor: context).
	receiverInspector 
	    fieldLists: (self receiverFieldListsFor: context receiver).
	self changeState: #text.
	Primitive updateViews.
	self highlight: context
    ]
]



ObjectInspectorFieldList subclass: PrimitiveInspectorFieldList [
    
    <comment: nil>
    <category: 'System-Compilers'>

    validSize: anObject [
	<category: 'primitives'>
	^((self primClass: anObject) inheritsFrom: ContextPart) 
	    ifTrue: [self prim: anObject instVarAt: ContextPart spIndex]
	    ifFalse: [self primBasicSize: anObject]
    ]

    prim: anObject instVarAt: anIndex [
	"Answer the index-th indexed variable of anObject."

	<category: 'primitives'>
	<primitive: VMpr_Object_instVarAt>
	self primitiveFailed
    ]

    prim: anObject instVarAt: anIndex put: value [
	"Store value in the index-th instance variable of anObject."

	<category: 'primitives'>
	<primitive: VMpr_Object_instVarAtPut>
	self primitiveFailed
    ]

    prim: anObject basicAt: anIndex [
	"Answer the index-th indexed instance variable of anObject."

	<category: 'primitives'>
	<primitive: VMpr_Object_basicAt>
	self primitiveFailed
    ]

    prim: anObject basicAt: anIndex put: value [
	"Store value in the index-th indexed instance variable of anObject."

	<category: 'primitives'>
	<primitive: VMpr_Object_basicAtPut>
	self primitiveFailed
    ]

    primBasicAt: anIndex [
	<category: 'primitives'>
	^((self primClass: self value) inheritsFrom: Object) 
	    ifTrue: [self value basicAt: anIndex]
	    ifFalse: [self prim: self value basicAt: anIndex]
    ]

    primBasicAt: anIndex put: anObject [
	<category: 'primitives'>
	^((self primClass: self value) inheritsFrom: Object) 
	    ifTrue: [self value basicAt: anIndex put: anObject]
	    ifFalse: 
		[self 
		    prim: self value
		    basicAt: anIndex
		    put: anObject]
    ]

    primBasicSize: anObject [
	"Answer the number of indexed instance variable in anObject"

	<category: 'primitives'>
	<primitive: VMpr_Object_basicSize>
	
    ]

    primClass: anObject [
	"Answer the class of anObject"

	<category: 'primitives'>
	<primitive: VMpr_Object_class>
	
    ]

    currentFieldValue: obj [
	<category: 'accessing'>
	currentField > base 
	    ifTrue: [self primBasicAt: currentField - base put: obj]
	    ifFalse: 
		[self 
		    prim: self value
		    instVarAt: currentField - 1
		    put: obj]
    ]

    currentFieldValue [
	<category: 'accessing'>
	currentField == 0 ifTrue: [^nil].
	currentField == 1 ifTrue: [^self value].
	^currentField > base 
	    ifTrue: [self primBasicAt: currentField - base]
	    ifFalse: [self prim: self value instVarAt: currentField - 1]
    ]

    computeFieldList: anObject [
	"Store a string representation of the inspected object, anObject, in fields.
	 The first string is self.  The subsequent values are the object's complete
	 set of instance variables names.  If the object is a variable class,
	 append numerical indices from one to number of indexed variables"

	<category: 'accessing'>
	| instVarNames class |
	fields add: 'self'.
	class := self primClass: anObject.
	instVarNames := class allInstVarNames.
	1 to: instVarNames size
	    do: [:x | fields add: (instVarNames at: x) asString].
	base := fields size.
	class isVariable 
	    ifTrue: 
		[1 to: (self validSize: anObject) do: [:x | fields add: x printString]]
    ]
]



InspectorFieldList subclass: StackInspectorFieldList [
    | vars |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    currentFieldValue: obj [
	<category: 'private'>
	| variable |
	currentField < 2 ifTrue: [^self].
	variable := vars at: currentField - 1.
	^variable key at: variable value put: obj
    ]

    currentFieldValue [
	"Return value at currently selected key"

	<category: 'private'>
	| variable |
	currentField == 0 ifTrue: [^nil].
	currentField == 1 ifTrue: [^self value].
	variable := vars at: currentField - 1.
	^variable key at: variable value
    ]

    computeFieldList: anObject [
	<category: 'private'>
	vars := OrderedCollection new.
	fields add: 'thisContext'.
	self setFieldsIn: anObject
    ]

    setFieldsIn: context [
	<category: 'private'>
	| prefix numVars prefixSize |
	numVars := context numArgs + context numTemps.
	(context home == context or: [context outerContext == nil]) 
	    ifTrue: [prefixSize := -2]
	    ifFalse: [prefixSize := self setFieldsIn: context outerContext].
	numVars > 0 ifTrue: [prefixSize := prefixSize + 2].
	prefix := String new: (prefixSize max: 0) withAll: $-.
	(1 to: numVars) with: context variableNames
	    do: 
		[:i :varName | 
		fields add: prefix , varName.
		vars add: context -> i].
	^prefixSize
    ]
]

PK
     �Mh@y�0�;  ;    PCode.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI wrapper for method source code widgets
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002,2003,2007
| Free Software Foundation, Inc.
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
 ======================================================================
"



BLOX.BText subclass: BCode [
    | class line highlighted source variables pools temps isMethod highlightBlock |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    Colors := nil.
    Highlight := nil.

    BCode class >> highlight [
	<category: 'choosing behavior'>
	^Highlight
    ]

    BCode class >> highlight: aBoolean [
	<category: 'choosing behavior'>
	Highlight := aBoolean
    ]

    BCode class >> colorAt: aSymbol [
	<category: 'event handlers'>
	^Colors at: aSymbol ifAbsent: [nil]
    ]

    BCode class >> colorAt: aSymbol put: aColor [
	<category: 'event handlers'>
	^Colors at: aSymbol put: (BTextAttributes foregroundColor: aColor)
    ]

    BCode class >> initializeColors [
	<category: 'event handlers'>
	Colors := IdentityDictionary new: 32.
	self highlight: true.
	self
	    colorAt: #classVar put: 'cyan4';
	    colorAt: #globalVar put: 'cyan4';
	    colorAt: #poolVar put: 'cyan4';
	    colorAt: #undeclaredVar put: 'red';
	    colorAt: #instanceVar put: 'black';
	    colorAt: #argument put: 'black';
	    colorAt: #temporary put: 'black';
	    colorAt: #specialId put: 'grey50';
	    colorAt: #literal put: 'grey50';
	    colorAt: #temporaries put: 'magenta';
	    colorAt: #methodHeader put: 'magenta';
	    colorAt: #primitive put: 'magenta';
	    colorAt: #arguments put: 'magenta';
	    colorAt: #special put: 'magenta';
	    colorAt: #unaryMsg put: 'magenta4';
	    colorAt: #binaryMsg put: 'chocolate4';
	    colorAt: #keywordMsg put: 'NavyBlue';
	    colorAt: #comment put: 'SpringGreen4'
    ]

    checkLine: unused [
	<category: 'event handlers'>
	| oldLine |
	oldLine := line.
	line := self currentLine.
	line ~= oldLine & highlighted not ifTrue: [self rehighlight]
    ]

    create [
	<category: 'event handlers'>
	super create.
	self inClass: UndefinedObject.
	highlighted := false.
	self onKeyUpEventSend: #checkLine: to: self.
	self 
	    onMouseUpEvent: 1
	    send: #checkLine:
	    to: self
    ]

    invokeCallback [
	<category: 'event handlers'>
	highlighted ifTrue: [self blackLine].
	super invokeCallback
    ]

    highlightAs: kind from: start to: end [
	<category: 'mediating protocol'>
	highlightBlock 
	    value: (BCode colorAt: kind)
	    value: start
	    value: end
    ]

    highlightAs: kind pos: pos [
	<category: 'mediating protocol'>
	pos isNil ifTrue: [^self].
	self 
	    highlightAs: kind
	    from: pos
	    to: pos
    ]

    highlightNewVariable: name from: start to: end as: kind [
	<category: 'mediating protocol'>
	temps at: name put: kind.
	self 
	    highlightAs: kind
	    from: start
	    to: end
    ]

    highlightVariable: name from: start to: end [
	<category: 'mediating protocol'>
	self 
	    highlightAs: (self variableKind: name)
	    from: start
	    to: end
    ]

    blackLine [
	<category: 'syntax highlighting'>
	highlighted := false.
	self removeAttributesFrom: 1 @ line to: 1 @ (line + 1)
    ]

    classifyNewVariable: var [
	<category: 'syntax highlighting'>
	pools 
	    keysAndValuesDo: [:pool :kind | (pool includesKey: var) ifTrue: [^kind]].
	^(var at: 1) isUppercase ifTrue: [#globalVar] ifFalse: [#undeclaredVar]
    ]

    declareVariables: aCollection in: dictionary as: kind [
	<category: 'syntax highlighting'>
	aCollection do: [:each | dictionary at: each asString put: kind]
    ]

    rehighlight [
	<category: 'syntax highlighting'>
	self class highlight ifFalse: [^self].
	self
	    removeAttributes;
	    highlight
    ]

    highlight [
	<category: 'syntax highlighting'>
	self class highlight ifFalse: [^self].
	self highlightSyntax.
	highlighted := true
    ]

    highlightBlockClosure [
	<category: 'syntax highlighting'>
	| sourceStream nlPos lineNumber |
	lineNumber := 0.
	sourceStream := ReadStream on: source.
	^
	[:color :start :end | 
	| startPos endPos |
	[start > sourceStream position] whileTrue: 
		[lineNumber := lineNumber + 1.
		nlPos := sourceStream position.
		sourceStream skipTo: Character nl].
	startPos := (start - nlPos) @ lineNumber.
	[end > sourceStream position] whileTrue: 
		[lineNumber := lineNumber + 1.
		nlPos := sourceStream position.
		sourceStream skipTo: Character nl].
	endPos := (end - nlPos + 1) @ lineNumber.
	self 
	    setAttributes: color
	    from: startPos
	    to: endPos]
    ]

    parserClass [
	<category: 'syntax highlighting'>
	^STInST.RBBracketedMethodParser
    ]

    highlightSyntax [
	<category: 'syntax highlighting'>
	| parser |
	source = self contents 
	    ifFalse: 
		["FIXME: this is wrong, something is being dropped
		 elsewhere with respect to content updates"
		source := self contents].
	parser := (self parserClass new)
		    errorBlock: [:string :pos | ^self];
		    initializeParserWith: source type: #on:errorBlock:;
		    yourself.
	isMethod 
	    ifTrue: [self highlight: parser parseMethod]
	    ifFalse: 
		[[parser atEnd] whileFalse: 
			[self highlight: (parser parseStatements: false).
			parser step	"gobble doit terminating bang"]]
    ]

    highlight: node [
	<category: 'syntax highlighting'>
	
	[| color commentsNode |
	temps := LookupTable new.
	highlightBlock := self highlightBlockClosure.
	SyntaxHighlighter highlight: node in: self.
	commentsNode := STInST.RBProgramNode new copyCommentsFrom: node.
	commentsNode comments isNil ifTrue: [^self].
	color := BCode colorAt: #comment.
	highlightBlock := self highlightBlockClosure.
	commentsNode comments do: 
		[:each | 
		highlightBlock 
		    value: color
		    value: each first
		    value: each last]] 
		ensure: [temps := highlightBlock := nil]
    ]

    inClass: aClass [
	<category: 'syntax highlighting'>
	class == aClass ifTrue: [^self].
	class := aClass.
	self initVariableClassification.
	self 
	    declareVariables: class allClassVarNames
	    in: variables
	    as: #classVar.
	self 
	    declareVariables: class allInstVarNames
	    in: variables
	    as: #instanceVar.
	class withAllSuperclassesDo: 
		[:each | 
		pools at: class environment put: #globalVar.
		class sharedPools 
		    do: [:pool | pools at: (class environment at: pool) put: #poolVar]]
    ]

    initVariableClassification [
	<category: 'syntax highlighting'>
	variables := LookupTable new.	"variable String -> its kind"
	pools := IdentityDictionary new.	"Dictionary -> kind of variables in it"
	variables
	    at: 'self' put: #specialId;
	    at: 'super' put: #specialId;
	    at: 'thisContext' put: #specialId
    ]

    variableKind: var [
	<category: 'syntax highlighting'>
	^temps at: var
	    ifAbsentPut: [variables at: var ifAbsent: [self classifyNewVariable: var]]
    ]

    contents: textOrAssociation [
	<category: 'widget protocol'>
	| newClass |
	line := 1.
	highlighted := false.
	(textOrAssociation isKindOf: Association) 
	    ifTrue: 
		[source := textOrAssociation value.
		newClass := textOrAssociation key.
		isMethod := true]
	    ifFalse: 
		[source := textOrAssociation.
		newClass := UndefinedObject.
		isMethod := false].
	super contents: source.
	self
	    inClass: newClass;
	    highlight
    ]
]



STInST.STInST.RBProgramNodeVisitor subclass: SyntaxHighlighter [
    | widget |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    SyntaxHighlighter class >> highlight: node in: aBCodeWidget [
	<category: 'instance creation'>
	(self new)
	    widget: aBCodeWidget;
	    visitNode: node
    ]

    widget: aBCodeWidget [
	<category: 'initialize-release'>
	widget := aBCodeWidget
    ]

    acceptArrayNode: anArrayNode [
	"widget highlightAs: #special at: anArrayNode left."

	<category: 'visitor-double dispatching'>
	self visitNode: anArrayNode body
	"widget highlightAs: #special at: anArrayNode right"
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>
	self acceptVariableNode: anAssignmentNode variable.
	"widget highlightAs: #special
	 from: anAssignment assignment
	 to: anAssignmentNode assignment + 1."
	self visitNode: anAssignmentNode value
    ]

    acceptBlockNode: aBlockNode [
	"widget highlightAs: #special at: aBlockNode left."

	<category: 'visitor-double dispatching'>
	aBlockNode colons with: aBlockNode arguments
	    do: 
		[:colonPos :argument | 
		"widget highlightAs: #special at: colonPos."

		self highlightNewVariable: argument as: #argument].

	"aBlockNode bar isNil ifFalse: [
	 widget highlightAs: #special at: aBlockNode bar.
	 ]."
	self visitNode: aBlockNode body
	"widget highlightAs: #special at: aBlockNode right"
    ]

    acceptCascadeNode: aCascadeNode [
	<category: 'visitor-double dispatching'>
	| n |
	n := 0.
	self visitNode: aCascadeNode messages first receiver.
	aCascadeNode messages do: 
		[:each | 
		self highlightMessageSend: each
		"separatedBy: [ | semi |
		 semi := aCascadeNode semicolons at: (n := n + 1)
		 widget highlightAs: #special at: semi ]"]
    ]

    acceptLiteralNode: aLiteralNode [
	<category: 'visitor-double dispatching'>
	widget 
	    highlightAs: #literal
	    from: aLiteralNode start
	    to: aLiteralNode stop
    ]

    acceptMessageNode: aMessageNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aMessageNode receiver.
	self highlightMessageSend: aMessageNode
    ]

    acceptMethodNode: aMethodNode [
	"A pity we cannot share this code with highlightMessageSend: ..."

	<category: 'visitor-double dispatching'>
	aMethodNode isUnary 
	    ifTrue: 
		[widget 
		    highlightAs: #unaryMsg
		    from: aMethodNode selectorParts first start
		    to: aMethodNode selectorParts first stop].
	aMethodNode isBinary 
	    ifTrue: 
		[widget 
		    highlightAs: #binaryMsg
		    from: aMethodNode selectorParts first start
		    to: aMethodNode selectorParts first stop.
		self highlightNewVariable: aMethodNode arguments first as: #argument].
	aMethodNode isKeyword 
	    ifTrue: 
		[aMethodNode selectorParts with: aMethodNode arguments
		    do: 
			[:sel :arg | 
			widget 
			    highlightAs: #binaryMsg
			    from: sel start
			    to: sel stop.
			self highlightNewVariable: arg as: #argument]].
	self visitNode: aMethodNode body
    ]

    acceptOptimizedNode: aBlockNode [
	"widget highlightAs: #special from: aBlockNode left to: aBlockNode + 2."

	<category: 'visitor-double dispatching'>
	self visitNode: aBlockNode body
	"widget highlightAs: #special at: aBlockNode right"
    ]

    acceptReturnNode: aReturnNode [
	"widget highlightAs: #special at: anArrayNode start."

	<category: 'visitor-double dispatching'>
	self visitNode: aReturnNode value
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>
	| n |
	n := 0.
	"widget highlightAs: #special at: aSequenceNode leftBar."
	aSequenceNode temporaries do: 
		[:temporary | 
		"widget highlightAs: #special at: colonPos."

		self highlightNewVariable: temporary as: #temporary].
	"widget highlightAs: #special at: aSequenceNode rightBar."
	aSequenceNode statements do: 
		[:each | 
		self visitNode: each
		"separatedBy: [ | period |
		 period := aSequenceNode periods at: (n := n + 1)
		 widget highlightAs: #special at: period ]"

		"n < aSequenceNode periods size ifTrue: [
		 widget highlightAs: #special at: aSequenceNode periods last ]."]
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>
	widget 
	    highlightVariable: aVariableNode name
	    from: aVariableNode start
	    to: aVariableNode stop
    ]

    highlightMessageSend: aMessageNode [
	<category: 'visitor-double dispatching'>
	aMessageNode isUnary 
	    ifTrue: 
		[widget 
		    highlightAs: #unaryMsg
		    from: aMessageNode selectorParts first start
		    to: aMessageNode selectorParts first stop.
		^self].
	aMessageNode isBinary 
	    ifTrue: 
		[widget 
		    highlightAs: #binaryMsg
		    from: aMessageNode selectorParts first start
		    to: aMessageNode selectorParts first stop.
		self visitNode: aMessageNode arguments first.
		^self].
	aMessageNode selectorParts with: aMessageNode arguments
	    do: 
		[:sel :arg | 
		widget 
		    highlightAs: #binaryMsg
		    from: sel start
		    to: sel stop.
		self visitNode: arg]
    ]

    highlightNewVariable: node as: kind [
	<category: 'visitor-double dispatching'>
	widget 
	    highlightNewVariable: node name
	    from: node start
	    to: node stop
	    as: kind
    ]
]



PText subclass: PCode [
    
    <import: STInST>
    <comment: nil>
    <category: 'Graphics-Browser'>

    PCode class >> bloxClass [
	<category: 'instance creation'>
	^BCode
    ]

    implementorsFrom: position [
	<category: 'limited parsing'>
	| symbol |
	symbol := self getMessageAt: position.
	symbol isNil 
	    ifTrue: 
		[Blox beep.
		^self].
	MethodSetBrowser implementorsOf: symbol parent: self
    ]

    sendersFrom: position [
	<category: 'limited parsing'>
	| symbol |
	symbol := self getMessageAt: position.
	symbol isNil 
	    ifTrue: 
		[Blox beep.
		^self].
	MethodSetBrowser sendersOf: symbol parent: self
    ]

    getMessageAt: position [
	"This is so easy to do with the Refactoring Browser's
	 parse nodes!!!"

	<category: 'limited parsing'>
	"First, we must map line/row to the actual index in
	 the source code."

	| stream pos parser node |
	stream := ReadStream on: blox contents.
	position y - 1 timesRepeat: [stream nextLine].
	stream skip: position x - 1.
	pos := stream position.
	stream reset.
	parser := RBParser new.
	parser errorBlock: [:message :position | ^nil].
	parser 
	    scanner: (parser scannerClass on: stream errorBlock: parser errorBlock).
	node := parser parseMethod body.
	node := node bestNodeFor: (pos to: pos + 1).
	[node isMessage] whileFalse: 
		[node := node parent.
		node isNil ifTrue: [^nil]].
	^node selector
    ]

    implementors [
	<category: 'blue button menu'>
	^self implementorsFrom: blox currentPosition
    ]

    senders [
	<category: 'blue button menu'>
	^self sendersFrom: blox currentPosition
    ]

    compileIt [
	<category: 'blue button menu'>
	super compileIt.
	self blox rehighlight
    ]
]



Eval [
    BCode initializeColors
]

PK
     �Mh@�i<2�	  �	    StrcInspect.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI inspector for CStruct derivatives
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
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
 ======================================================================
"



InspectorFieldList subclass: CCompoundInspectorFieldList [
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    currentField: assoc [
	"Set list selection to value of index.  Force a text view update"

	<category: 'accessing'>
	assoc key == 0 
	    ifTrue: [currentField := 0]
	    ifFalse: [currentField := (fields at: assoc key) value]
    ]

    inspectMenu: listView [
	"Initialize menu for variable list pane"

	<category: 'initializing'>
	^(PopupMenu new: listView label: 'Field') 
	    selectors: #(#('Inspect' #evalAndInspectResult: #listView))
	    receiver: self
	    argument: listView
    ]

    currentFieldValue: obj [
	"Cannot change!"

	<category: 'private'>
	
    ]

    currentFieldValue [
	<category: 'private'>
	currentField == 0 ifTrue: [^nil].
	^(self value perform: currentField asSymbol) value
    ]

    computeFieldList: anObject [
	"Initialize instance variable, fields, which governs display of
	 variable list pane."

	<category: 'private'>
	self value inspectSelectorList 
	    do: [:aKey | fields add: (Association key: aKey asString value: aKey)]
    ]
]



CCompound extend [

    inspectorFieldLists [
	"Open a CCompoundInspectorFieldList window on self"

	<category: 'debugging'>
	^{'Basic' -> BLOX.BLOXBrowser.CCompoundInspectorFieldList new value: self}
    ]

]

PK    �Mh@��l4$  ��  	  ChangeLogUT	 cqXO��XOux �  �  �\ks���,�
�U�Zʊ�(�N�d]���n,[e)NR[[	8����yH���n`f0�#%��K@ht�~������xz4>|"ą4��&��c-�O3���".&&]��v��Vr�&���D|Vks�DlnDV$*�G�)2��\G���"��FG�����x��,�i�-�@l|��@z�#�e?k����f��'��L��X����\�B��2/ĵL��E�-��1�s4}�D�U� �e�H�ڄ�����r���V�҄�U`։�d�M|��.����s��TyE�^��)n� ��5�i7�i�R^Ł(�G�OxaoԬX\IbҜ��˕_�^?��h؋�&>a~$�hG�׼4��R���ICp,7n��1m�5����Vo�Hc�����3HάU�WdqO��=/TZ8qeL�1�>�\����F���FEz�sA�A6�+:?y�&������~֋e��r�X����T�:���\�֛6>�y>������]��gq�� 7i�!WY��έ�x|t�`�x�T�J��ȗJ2W�nD���B�V1G;V5H3���b'Ơ5��}'��4�z��ɱHU�d�*J��t���Ԉ?�Z����7��˕̃�$V���m?'̤M��847�6�|��eEn�q��9m>�!$�i`@��MwbGC��b����P�=-����L�v��6!SyN����g]�\�M�Lz�A;�ڂi�E3�U���2f*h��1 l�D�@Ť�h'_�\0�Y1,�M����QD�5�����(Y��"����������0���1 !���v�m�\ފe�E,�1��hg���]7��`Am&5���Ж�䨥/��������*~Zg2�{�r#��L3)V�(�s&ƕ+d�%��ad����6F���p��-��y2L+noq*�@�p��W�>���||i�X��Ζ&�q(n�*&q$��,����E$f�V�T����~|��+�b�ꚧ�����::#�`��k {�n���.��ul��jS�Kƀ}�� �ܤ:�i�]*�i'��b�]~N79ܪPeV=h	�}���V0��y18`֍5:�&��V*�Z��I���i�1��`��5�u�K&�lS/r� ���xֽ"-a?��R�%��τ��Q�)���"7E�d:�b;&���q)?��
��;�8�W�T~�ئ���-l[nw�Z),���Ō��1�p�c�"�V�B�sZ��������h�c��r���ES�i=�:�
� {E�*��EE�<4�)���c ��Y��$�O�������=S��h��9��RE�7�s g�x'!�gkD?�Uַ��f�T�Bts� +�ʪ'ɓ�E����Z�܈��CMF��Ս���V�=kP+�Yd�:Z+xxĴ@�4�_nQ[���
;���x9�}-��E�G��\�g��,��YgYݩ�l ȶ;O̞4퐁���+yy�0��y�j����@X�w����H{Y���I.3rd�|cg�/���^ �Ȉ��S毕`��Ц�pq�ݎo�!W@G�m����=�(-'�9�{&SH�=��#Pry:\�<;��=-��(wf�3�z뒓��㤗?���3��,�|������'Y^�����%��u�ƴ�蚝|0�Y����y�G��A|Lж�{:����DN�':�ʧ��~��=Pk�B5�TlR`_���\Q�Z΢c�0��}0q�6��IXSqD1��`Y���j@{���\���m�dHN�k�j���R�s�<�!Y|c ��"�p��^|��24�T/e-�zRҸW.������ x�!�;���FW�J$&��h5��l�b����K�$*f��֢K[�r��&��XG��+Ь$�N�h-�e��¬کio7U���#p�CH��"a�2�����u"	�{� �4�Ur%���p���[}�J�d�B��6d�j��i,�Z��}E��"S�d�� ��@��J��
9�;vc�z	sRe0aJ�ƉA���:����,=1+��O}�S�����)2���qIB3��F�3ڨ�A�^	a���>*��ʜ�뾔e-D@�������Z f��_Um���3_���-:��b�zFn�[����T�V=��q25��|��~�6�>b�\����sv�<������m^{'��*�my��_R\�f�U�T*'�:ר��A�z�����LF_!�_�ԭ���p���}������������Z=R��<|���\�A~Gs��k57�F%!�	Bg�%��9��0 �0rO����Y�|�H��p9ځ�Z㔯U��wZE!�F��-zV�-�Mc��%��W��2Ԧ
i.^ڰl�W�O!��2�A�Vd �#�q���o����%��k�Rg��(�Pb�:(��o:\�<���|
L�T���� D�g�t�S�mͪF+�Y1� ;;Pjj!��9a��`'@�$S�ؾ�@�
�&�d�ǈ\��~8Zh�Vv]%��;��=�r��gS۶�k���=}`{����ѷ�ۻ��`{�& n��e���H�WjS�zY�j�s��|��eA�O�	�Q�IS��� ^M�/F%+�݄+��2�)B�uv༣^�zr�!0i4���4[���Iwl��r至�o'�l�(E�>�zmC�AKc8:|c�d*&ZL�%2f^������e,��V����G��+.�"U���Z$��K���YEl� >U{��0(�ړ!����0{!,@drn�yn|=y���S�0���4d�
�,��&N�٥Vs��kl�u�Z��j�1�~��B����k�z���vS	���;ּ��M��&��-#��knaU���V[o�*K�P)U��i�[�=����E���k1�yh\�N��)��&�YK�j�����AN��I��HN��:e�ڌv�-�  2�4�ː�ƚ �4�V� \]��S2�,�����r�:�-��d;��G�a���Gqh��K���)�EN?_�f���Gt��3�i�j��w���ד�2�i
�J'8ˌ�Z_T�w#ߎ/�r������;�.wxYG�V��Ӈ0q:y����ؠ4Fm��n�n�@�7&�.#'ZM������@$Eʕ Q$b��(���6����о1�����î��AR���x�sjk�z1fk ݸ��>�ȓ��-�����?f�ؓ.���m�X���:X-�k��%�km��l�����- )l�L�D,��QY���	����z͐��iV�MP�s���<����P�y����Ԍo�vm�ye05,�o\�tr�m���XE���q[Q_tu}�����Hx�|�vUͶ��oS��n��K�I�~����S�;X>�.<uB�
*��q!�ˡ�	�Tr8_�X,T�(GR�D�6�چ�=��=]��i�fx�-�#�n��5�?����	�O	`�ط�P7�V��J�ξ��s7\7W�R�l�-[�qyyu��\�:�[��1ɭ�V�`e�?�s3��f`����� I��
z��F��O�ĆŴ� 3��3 ����f=3��DHS�ɺ@2d@iƀ!Md0�<����!lпy�, ]���>�搉���q�ݯ�Dެ��hԷ�Xi�O�Rg
��|>��E�]?ӥ8aC���t�=ǹE.؃~v
-�kE:9�wwU�_K�K��>Wg.+�ˡ�p Dtr��,3j櫲�n��x�j[��.~K������Ơ����ΐP��M��r0�$��ߥ��Y��a�.��PA�ƻ-��`�vP��v]�i�Q�'���)w��U_zP�^��V��#d��`�Q�#&��iT�N���.����[���#��}����l�^��H��ܪ��|�,ur����^۫v��\c�T��7�I0EܦTK���I ��,M�J v� z{-�*�;q�g�qw�|�]V�I}�b�X��������
pj���� �;:�ώH�(��g!UP8#����7�S��R%�(�\G�t8ј�J`����*;W:�.J�B���Y��/�S����6��Q7���>(��Q�TD�\Vc0q�-�wd� ۺ3�7T�"1��͚m�S��*�bS'R�����z����:��yp��zx�����5�q���Ejn9�X`YAY%@�����	��é�vH��`�U���_Љ�{��%��i|G����T��H�Rz�������??��~~����)�:�S�NML>��.��C]�&�Y�~m"W>P�����p��TƬ�IBO'�{y�r��=����T�� ����a3�|����۴��3T��qO���R�ʫ��T�C0����?��w]Ң���Uvӷ�HuH�$ц�n�C���r ����Y:��6_���%y�Dm/�3EY����䇧�'���<'�}���1e0nL��dW�ȵ�p����^lH	6��W���vz4ڙ�')�CA�o[��nUP0�{�@/
Ddb�2\Jz �A:U�6��������������m��Wջ�3Z�������2)sH^��?W�lrsc�ju�I�(���7<����s�-�Ǯ.>{�^DN���fy��wJ�_j*��.���n��3���]�*�(����G�Ie"$a��%W�׳;����<��K~X����ۣ�!y(d-;��}������h�o'l����㣁�g�tS�wr����{m��:� otc�F�E	�1��/��T4G:<�?¶7�ц�D���A�/:�8�~6��J��Y%�0�KcV�m �Y9{����ֽ��:��������A7/X�x\��h�wQdB�-�Uz�J�xEK^c���*I5{2�I^��h�]��5���g��sy���Y�-�Gvb���E1C�%���d�sqv�e����/��g�{�Šh���R|��"�;!,���+[gG�S����V,��ʩ9g/�E��Kz�r�#et#7D /R�l��RS����e�����"Ѵ�S]�5���}(��1�7V�l]w(�]��S��_�����`7���2��豚�۲�������}g'<d|��D��e���ƛ���]p|�<�~�@)H&�RG�z�vƙ#z3������Փ	:G��ԬT��8���W~16YkyI.�	Bq~�b�H�2�#s��W�&$?1Z��<a5�`�|>k�F�33��z
���8��`��_n�I^�N�d�M�KT�?�0?28��r �đVHN���u���{�E�Z�ᰅ�8�]K�Q��|x�<�)E���3�G��:T��f�Z��߮���N�t���~�U���Z���=�`|k�A��u��*��K� !�-a��4��ǁظp(u�/�_<p�@����X�O��I�J���Ɂ�Mӫ�X�����NQΉ���{2�%7����=�zi�	�/�M}|��%�>�*9�c[/�s��v�´ �����Z��H5�&���Qy�UO��j���;JOb������Ǐ���k|�pNof(��(.�3�E�O�>�}�ѩ0t�3>�2��{?}�� ��w����_��U��o��"��ˡM�O�\�zP���CN�燀sC_v2�������/�7?"d�97�Ed����P�|jM�8%��0�Ԥ�A����_����v텋]��Ĺm*U#�mO�G{L$�B�� u�j���DfMD�j��ٞ�ߥ���\��K��c�Ũ��F�f��m;)r�ng��V�}�T��N�;�%���.�؃�˾�+�ZDok
R�N`�/��24����*`�d��q�V��6+[��0h�xʏ5�t'}��Ѷ��Kz�S/l;�v���<�e�>f�S����VX�v�%�:����m�j���_����?Ω��u��nz*-��H�]~�MW�����qu=$��RG�6��>�؆8I���n���Z�B�(���=/�{Z�����$���D�]}:�E�8�"u��9i(�7����ߵ�9{�I,}��7hҏ�DF���osz
�5�;����}˧ӷ�c���wSM��W�Jpa�]���G���mp�s{���vq-$')f�g[�/��_z�M�,b��P�Mֹ�$��yY����|�,2�P8Eک�OM�Xr�)��5He��&���*�#h�"�V�keSP�����'Ŕ4�g���4�A	���ۄ�H���k�/ՙ��cCϸ^�#�'L�qF��1d��O�#��	3���a<%������v�M�I���ڢ��)���$o�:prG*���6{�.2F��\�/�믟�ь4�Ǘ]cK�>=���3P�pӹZt$��5x���M,�����w�������^��&�{����u&jBC��i�o��D;��H ����X�� ��el6z��r�l�Z�<j�Gu�լ�W��Zs�:�֜EC��%�uH��"���N�;���zԄ��\�(�����bm�̂���uz�Db��H�K���"�ԦG؊w�.2��X.[m��}��i&�מ�0����GD�OM�o��+f��p�y@����Qs3���j��+*d�i[�S�����I�>8����KN"���!��|�͕���<ʨ�Gg�:�{v����Y��a�\VXl��7%]z�W����?��; ��Ms�'���������kF���A\�.�9,^��a�E\����/���|��͐f������������b0�e�ęz���H�y���,T�d&���EZ�J�r��d� ��%G����y�A����nl`,���R5��!�}�c��Oͳ����ȎޔX�Ftf
#�L�3$$�Aׂ{)'�%���K�v�|y�cK!H���8�H����[{�O�~1�-^_��(+8�ap���k�_�kXs��I=]��W6��EF�1K�����8�,�+���m�M���J�]+���{R�?�L�Oʬ��B�ۘ��r�׫K�:~HFsRVy�({F�ξ���m�A��X�/������R�^���Ŭ�g #��6����H��;��� ���bI��y��=66ZL�+��ɋ)<���T��[v��>��Cw��iU���BeA��2N`�1�c{=��:_��;�wf:��	5\�6�2 ��]`��c�f]�������I�x?��V�? !"t�urX0�t�=��ݳ���9�*7�]�� ��r�`EJ/zX�gO�u����bx�~c�|g�����V�3gݵK��N�^�Xx.N[3�c�qY���J�g���#�qS�.�����!��������u�{S�1��-;��﷝)�|7�(vS+{u��h����u�B��;�|*�	^�@�?ZMy�L�j>�ON�XƙĪ'w�V�Z3�*����ӋI6wz����͡����r������Ύ�SRR��3d&��xE*� ���!�:�H1q����U��KTw'h���}cL��+k�
b�Ru�K��4}'�+L�	Ƙ��%��k:��,�`���@�)V����5�����,8���F��~��5��8�4�}�갓����/Wx�ZwI��}8e�v�w�s�[�/���>?>�/�|���v�g;�o:_-�����zW�If��f-�9��G{=dn��F�1D�4rs�#�Xz��}��3F W���[��$�~�"}�?�e����š /�s5,Ŗ�~���\�Cj�@S.83V��'#�2������1�e��ӝ�_S���!��mXƷ�3�[�R��X�4��B�){+J_;��j�}����U-���&K�!��c'/�T{O6"��P�{>�@9��JPP��X�h�h����Zx��>�ˣL�fC�܊��b��PeL:������v A�P�]箱��l�0���]����L#ߏ��O��;��&}�^.%N`��9�ۗ�^n�IV����v����b�~ �z5�:���J�3/G2/���4_J�R9K��H�#��>�[�f�2����'x}��ǁ��2`c�ׄ���E�^�2�t�B�L�K��H��3�{u�>����f�p��N�H�g4�0�͝�m�PN�]�������z�ˍd���׼��%u�X�#�^c
�⻾ܲ9�u��<���ف�ez����qkc�KN�g��A���{=�Ut�l@Y.U��sv��A�������+C���t"]�is��Y��B�J���#����h�����:��#���,�ꁭ`
�)�| ����El�ض��(��M�g���חx�f,Sb2�A�T�C��v/MmH��(n�-�6�n�&%�%��� ����B�f� $�c��(�
6�NOy���S���* ����%�;�q�u�`�\��W�P8#�vl.��l8�D`XoؘOKU�ɺ���r't��qaNk�3����n �����0���og��	vm���HC������������ѲzN|{˛C���X���/�� ��^GMr�K�6��?p����i�����S:h�OM�p�������a�>;Gf�Z��w�cۜCKW���8*e(���8:G�zxZ���gU����+�:�x�v�i"JZ��7�w�Ad��f�,5��A���+�_�i�C�!��`����q^	�����V��f[��rϳǡ���'�\�i$H�v㷕���t.7�Ks�q0<��=rZpwxܔ�II����,:LF��� �'J|����u�v=7}��$^�t��M��^���(���ʬ���Q�)����M�M����6<�t�,#'_Z���Bߙ8��J���b	��r6{��q�	��R�T��6�L3Kˁ6�O�e��[I��d�hH�&@��q��VrO��U_� �Oغ�_�K\6�^�����ֱ�Inn���X���%�vg��rt�k���=�n�N}��ƪ�M�ҹbҢOOi�i���F~Ԫ�_��̎��s��GH%)�mz�t�`��h_�6��/�������_���_�L��[��dn�F'����ZȦ�*ԓ%/T�wZ�P�����t�c{��ek�h� �sE�o&Q���ۂ����w�m�4an�!$7վ�J������}k�p�N��iY��I�K����%��)�[m��>��[��g�4v
�uI'�ͽLGZr���Ϡ�TR9a���������Te�6M�o�3��e����V�~�:��1�M���Cג�)#���Uڵ 
٭��)�ڕM���_t�[pܹ�"k�w9w+��zʹ"���W��_ǲ��Vu+�PK
     �Mh@^]�F�
  �
    RadioForm.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI wrapper for radio button groups
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller.
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
 ======================================================================
"



Primitive subclass: PRadioButton [
    | state isPressedMsg |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    PRadioButton class >> on: data parentView: sv isPressed: isPressedSelector label: label handleUserChange: changeSelector value: onValue [
	<category: 'instance creation'>
	| view |
	view := self new.
	view parentView: sv.
	view data: data.
	view
	    isPressed: isPressedSelector;
	    state: onValue.
	view handleUserChange: changeSelector.
	view initBlox: label.
	^view
    ]

    isPressed [
	"Return current switch state."

	<category: 'access'>
	^(data perform: isPressedMsg) = state
    ]

    state [
	<category: 'access'>
	^state
    ]

    state: value [
	<category: 'access'>
	state := value
    ]

    initBlox: aLabel [
	<category: 'initialize-delete'>
	blox := BRadioButton new: parentView label: aLabel.
	blox value: self isPressed.
	blox callback: self message: 'toggle:'
    ]

    isPressed: isPressedSelector [
	<category: 'initialize-delete'>
	isPressedMsg := isPressedSelector
    ]

    toggle: btnState [
	"Send the modification message to the data object"

	<category: 'message selectors'>
	self isPressed ifTrue: [^self].
	(stateChangeMsg notNil and: [self canChangeState]) 
	    ifTrue: [data perform: stateChangeMsg with: state]
    ]
]



Form subclass: RadioForm [
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    RadioForm class >> new: aString in: view [
	<category: 'instance creation'>
	| aView |
	aView := self new.
	aView parentView: view.
	aView blox: (BRadioGroup new: view blox).
	^aView
    ]
]

PK
     �Mh@�d?N'  N'    MethSetBrow.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI method set browser
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller and Paolo Bonzini.
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
 ======================================================================
"



GuiData subclass: MethodSetBrowser [
    | methodList theClass theSelector selection |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    MethodSetBrowser class >> referencesTo: anObject parent: listView [
	<category: 'instance creation'>
	| col value selection |
	col := SortedCollection 
		    sortBlock: [:a :b | a displayString <= b displayString].
	(anObject isKindOf: Association) 
	    ifTrue: 
		[selection := anObject key.
		value := anObject value]
	    ifFalse: 
		[selection := nil.
		value := anObject].
	Class allSubclassesDo: 
		[:meta | 
		(meta whichSelectorsReferTo: anObject) do: [:sel | col add: meta >> sel].
		(meta instanceClass whichSelectorsReferTo: anObject) 
		    do: [:sel | col add: meta instanceClass >> sel]].
	col isEmpty 
	    ifTrue: 
		[^ModalDialog new alertMessage: 'No references to ' , value printString
		    in: listView].
	^self new 
	    openOn: col
	    title: 'References to ' , value printString
	    selection: selection
    ]

    MethodSetBrowser class >> implementorsOf: aSymbol parent: listView [
	"Opens a message set browser on all methods that implement selected method"

	<category: 'instance creation'>
	| col |
	col := SortedCollection 
		    sortBlock: [:a :b | a displayString <= b displayString].
	"Collect all methods which implement selected method.  Collection is sorted
	 alphabetically"
	Class allSubclassesDo: 
		[:meta | 
		(meta includesSelector: aSymbol) ifTrue: [col add: meta >> aSymbol].
		(meta instanceClass includesSelector: aSymbol) 
		    ifTrue: [col add: meta instanceClass >> aSymbol]].
	col isEmpty 
	    ifTrue: 
		[^ModalDialog new alertMessage: 'No implementors for ' , aSymbol
		    in: listView].
	^self new 
	    openOn: col
	    title: 'Implementors of ' , aSymbol
	    selection: nil
    ]

    MethodSetBrowser class >> sendersOf: aSymbol parent: listView [
	<category: 'instance creation'>
	| col |
	col := SortedCollection 
		    sortBlock: [:a :b | a displayString <= b displayString].
	Class allSubclassesDo: 
		[:meta | 
		(meta whichSelectorsReferTo: aSymbol) do: [:sel | col add: meta >> sel].
		(meta instanceClass whichSelectorsReferTo: aSymbol) 
		    do: [:sel | col add: meta instanceClass >> sel]].
	col isEmpty 
	    ifTrue: 
		[^ModalDialog new alertMessage: 'No senders for ' , aSymbol in: listView].
	^self new 
	    openOn: col
	    title: 'Senders of ' , aSymbol
	    selection: aSymbol
    ]

    methodList [
	<category: 'accessing'>
	^methodList
    ]

    methodSelection: assoc [
	"Derive class and selector from list selection.  The selection is derived
	 from an item in the method list pane.  A list item may be of two
	 forms: 1) className class selector, or 2) className selector. Form (1)
	 contains 3 string tokens and form (2) contains 2.  To derive the class
	 from form (1), the instance class is derived from the Smallltalk
	 dictionary using the first string token as a key.  Then class is sent
	 to the instance class to derive the class of the instance class.  The
	 selector is derived from the third token.  In form (2), the instance
	 class is derived directly from the first string token.  The selector
	 is obtained from the second token"

	<category: 'accessing'>
	| parsing className |
	assoc value isNil ifTrue: [^theSelector := nil].
	theClass := assoc value methodClass.
	theSelector := assoc value selector.
	self changeState: #text.
	Primitive updateViews
    ]

    text [
	"Return source code for the selected method"

	<category: 'accessing'>
	theSelector notNil 
	    ifTrue: [^theClass -> (theClass >> theSelector) methodRecompilationSourceString].
	^''
    ]

    openOn: aSortedCollection title: name selection: aSymbol [
	"Open a method set browser.  The argument aMethodDictionary consists of
	 alpha-sorted collection of strings.  Each element is of two forms: 1) className
	 class selector, or 2) className selector.  This browser consists of two
	 vertically placed panes.  The top pane is a list which displays the sorted
	 methods in aMethodDictionary.  The bottom pane is a text view which will
	 display the source code for a selector which is selected from the top pane.
	 In general, aSymbol denotes a selector.  If this parameter is non-nil, the
	 first occurence of aSymbol will be selected in the text view when a
	 selector is first selected from the top pane"

	<category: 'initializing'>
	| topView childView aStream listView textView container |
	aSymbol notNil 
	    ifTrue: 
		["Parse selector expression, aSymbol, inclusive of first colon"

		aStream := WriteStream on: (String new: 0).
		aSymbol detect: 
			[:ch | 
			aStream nextPut: ch.
			ch == $:]
		    ifNone: [0].
		selection := aStream contents].
	topView := BrowserShell 
		    new: name , ' (' , aSortedCollection size printString , ')'.
	topView data: self.
	topView blox x: 20.
	topView blox y: 330.
	topView blox height: 308.
	topView blox width: 408.

	"Use Form class to manage the list and text view panes"
	childView := Form new: 'Form' in: topView.
	topView addChildView: childView.
	container := childView blox.

	"Create a list in top half of window"
	childView 
	    addChildView: ((listView := PList new: 'MethodSet' in: childView)
		    initialize;
		    data: self;
		    stateChange: #methodList;
		    handleUserChange: #methodSelection:;
		    dataMsg: #methodList;
		    menuInit: (self blueButtonMenuForMethods: listView);
		    yourself).
	(listView blox)
	    inset: 2;
	    width: 400 height: 150.

	"Create a text view and install in lower half of window"
	childView addChildView: ((textView := PCode new: childView)
		    data: self;
		    stateChange: #text;
		    handleUserChange: #compile:from:;
		    textMsg: #text;
		    setBrowserKeyBindings;
		    selection: selection;
		    yourself).
	textView menuInit: ((PopupMenu new: textView label: 'Edit') 
		    selectors: #(#('Cut' #gstCut) #('Copy' #gstCopy) #('Paste' #gstPaste) #() #('Clear' #gstClear) #() #('Line...' #line) #('Find...' #find) #() #('Do it' #eval) #('Print it' #evalAndPrintResult) #('Inspect' #evalAndInspectResult) #() #('Senders' #senders) #('Implementors' #implementors) #() #('Accept' #compileIt) #('Cancel' #revert) #() #('Close' #close))
		    receiver: textView
		    argument: nil).
	textView blox width: 400 height: 150.
	textView blox posVert: listView blox.
	textView blox inset: 2.
	"Initialize instance variable, methodList, which governs list display"
	methodList := aSortedCollection.
	self changeState: #methodList.
	Primitive updateViews.
	"Initialize all the manufactured widgets"
	topView display
    ]

    inspectMethod: listView [
	"Bring up an inspector on a Class"

	<category: 'selector list blue button menu'>
	theSelector isNil ifTrue: [^listView beep].
	(theClass >> theSelector) inspect
    ]

    blueButtonMenuForMethods: theView [
	"Create method list pane menu"

	<category: 'selector list blue button menu'>
	^(PopupMenu new: theView label: 'Method') 
	    selectors: #(#('File out...' #fileOutSelector: #theView) #() #('Senders' #senders: #theView) #('Implementors' #implementors: #theView) #() #(#Inspect #inspectMethod: #theView))
	    receiver: self
	    argument: theView
    ]

    fileOutSelector: listView [
	"Creates a file containing description of selected method"

	<category: 'selector list blue button menu'>
	| fileName |
	theSelector isNil ifTrue: [^listView beep].
	theClass name notNil 
	    ifTrue: [fileName := theClass name]
	    ifFalse: [fileName := theClass asClass name , '-class'].

	"If the name is too long, maybe truncate it"
	fileName := self fileoutDir , fileName , '.' , theSelector , '.st'.
	fileName := Prompter 
		    saveFileName: 'File out selector'
		    default: fileName
		    in: listView.
	fileName isNil 
	    ifFalse: 
		[theClass fileOutSelector: theSelector to: fileName.
		self setFileoutDirFromFile: fileName]
    ]

    implementors: listView [
	"Open a message set browser that sends the currently selected message"

	<category: 'selector list blue button menu'>
	theSelector isNil ifTrue: [^listView beep].
	MethodSetBrowser implementorsOf: theSelector parent: listView
    ]

    senders: listView [
	"Open a message set browser that sends the currently selected message"

	<category: 'selector list blue button menu'>
	theSelector isNil ifTrue: [^listView beep].
	MethodSetBrowser sendersOf: theSelector parent: listView
    ]

    compile: aString from: aView [
	"Compile aString derived from text in text view for the selected selector"

	<category: 'text view blue button menu'>
	theSelector isNil ifTrue: [^aView beep].
	theClass 
	    compile: aString
	    classified: (theClass compiledMethodAt: theSelector) methodCategory
	    ifError: 
		[:fname :lineNo :errorString | 
		aView displayError: errorString at: lineNo.
		^nil]
    ]

    selection [
	<category: 'text view blue button menu'>
	^selection
    ]
]

PK
     �Mh@�AS  S    MethInspect.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI inspector for CompiledMethods
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
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
 ======================================================================
"



InspectorFieldList subclass: MethodInspectorFieldList [
    | lastVar |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    inspectMenu: listView [
	"Initialize menu for variable list pane"

	<category: 'initializing'>
	^(PopupMenu new: listView label: nil) 
	    selectors: #(#('Inspect' #evalAndInspectResult: #listView) #('References' #references: #listView))
	    receiver: self
	    argument: listView
    ]

    currentFieldValue: obj [
	<category: 'private'>
	Blox beep
    ]

    currentFieldValue [
	<category: 'private'>
	| s |
	self currentField == 0 ifTrue: [^nil].
	self currentField = 2 
	    ifTrue: 
		[s := WriteStream on: (String new: 100).
		self value printHeaderOn: s.
		^s contents].
	self currentField = 1 
	    ifTrue: 
		[s := WriteStream on: (String new: 100).
		self value printByteCodesOn: s.
		^s contents].
	^self currentField <= lastVar 
	    ifTrue: [self value instVarAt: self currentField]
	    ifFalse: [self value literalAt: self currentField - lastVar]
    ]

    computeFieldList: anObject [
	"Initialize instance variable, fields, which governs display of
	 variable list pane."

	<category: 'private'>
	| string instVarNames |
	instVarNames := self value class allInstVarNames.
	fields add: '- bytecodes'.
	fields add: '- header'.
	3 to: instVarNames size
	    do: 
		[:x | 
		string := (instVarNames at: x) asString.
		fields add: string].
	lastVar := fields size.
	1 to: self value numLiterals do: [:x | fields add: x printString]
    ]

    currentFieldString [
	<category: 'private'>
	self currentField < 3 ifTrue: [^self currentFieldValue].
	^self currentFieldValue printString
    ]

    references: listView [
	"Open a method set browser on all methods which reference selected key"

	<category: 'variable list menu'>
	currentField isNil ifTrue: [^listView beep].
	currentField <= lastVar ifTrue: [^listView beep].
	MethodSetBrowser 
	    referencesTo: (self value literalAt: currentField - lastVar)
	    parent: listView
    ]
]



CompiledCode extend [

    inspectorFieldLists [
	"Open a MethodInspectorFieldList window on self"

	<category: 'debugging'>
	^{'Basic' -> (BLOX.BLOXBrowser.MethodInspectorFieldList new value: self)}
    ]

]

PK
     �Mh@f��h�  �    Notifier.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI notifier window
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller and Paolo Bonzini.
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
 ======================================================================
"



GuiData subclass: Notifier [
    | callstackList debugger stacktrace currentSelection errMessage topView listView |
    
    <comment: nil>
    <category: 'Graphics-Browser'>

    Notifier class >> debuggerClass [
	<category: 'debugging attributes'>
	^nil
    ]

    Notifier class >> debuggingPriority [
	<category: 'debugging attributes'>
	^1
    ]

    Notifier class >> openOn: aProcess message: message [
	<category: 'instance creation'>
	self new init: message debugger: (Smalltalk.Debugger on: aProcess)
    ]

    Notifier class >> open [
	<category: 'instance creation'>
	self open: 'Notifier on %1' % {Processor activeProcess}
    ]

    Notifier class >> open: message [
	<category: 'instance creation'>
	| handleErrorsWithGui |
	handleErrorsWithGui := BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui.
	BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui: false.
	
	[:debugger | 
	Processor activeProcess name: 'Notifier/Debugger'.
	self new init: message debugger: debugger.
	BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui: handleErrorsWithGui] 
		forkDebugger
    ]

    currentContext [
	<category: 'accessing'>
	currentSelection isNil ifTrue: [currentSelection := 1].
	^callstackList at: currentSelection
    ]

    process [
	<category: 'callback'>
	^debugger process
    ]

    debugger [
	<category: 'callback'>
	^debugger
    ]

    contextSelectedFrom: assoc [
	<category: 'callback'>
	currentSelection := assoc key
    ]

    debug [
	<category: 'callback'>
	Debugger new: self
    ]

    stacktrace [
	<category: 'callback'>
	^stacktrace
    ]

    close: aView [
	<category: 'private'>
	| tv |
	tv := aView rootView blox.
	aView rootView close ifTrue: [tv destroy]
    ]

    init: aString debugger: aDebugger [
	<category: 'private'>
	| context lastContext contexts |
	errMessage := aString.
	debugger := aDebugger.
	context := debugger suspendedContext.
	lastContext := context environment.
	stacktrace := OrderedCollection new.
	contexts := OrderedCollection new.

	"Skip top contexts that are internal to the exception-handling
	 system."
	[context ~~ lastContext and: [context isInternalExceptionHandlingContext]] 
	    whileTrue: [context := context parentContext].
	[context == lastContext] whileFalse: 
		[context isDisabled 
		    ifFalse: 
			[stacktrace add: context printString.
			contexts add: context].
		context := context parentContext].
	self createWindow.
	callstackList contents: stacktrace elements: contexts.
	topView display.
	listView update.
	listView select: 1
    ]

    createWindow [
	<category: 'private'>
	| topLevel |
	topView := (BrowserShell new: errMessage) data: self.
	topLevel := topView blox.
	topLevel 
	    x: 20
	    y: 50
	    width: 300
	    height: 100.
	topView addChildView: ((listView := PList new: 'MethodSet' in: topView)
		    initialize;
		    data: self;
		    listMsg: #stacktrace;
		    handleUserChange: #contextSelectedFrom:;
		    menuInit: ((PopupMenu new: listView label: 'Context')
				selectors: #(#('Debug' #debug))
				    receiver: self
				    argument: listView;
				selectors: #(#() #('Copy Trace' #copyAll) #('Copy Selection' #copySelection))
				    receiver: listView
				    argument: nil;
				selectors: #(#() #('Close' #close))
				    receiver: listView
				    argument: nil;
				yourself);
		    yourself).
	callstackList := listView blox
    ]
]



Behavior extend [

    debuggerClass [
	<category: 'overriding'>
	^BLOX.BLOXBrowser.BrowserMain handleErrorsWithGui 
	    ifTrue: [BLOX.BLOXBrowser.Notifier]
	    ifFalse: [nil]
    ]

]

PK
     �Mh@u&�(  (  
  GuiData.stUT	 cqXO��XOux �  �  "======================================================================
|
|   Smalltalk GUI publish-subscribe framework
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1992,94,95,99,2000,2001,2002 Free Software Foundation, Inc.
| Written by Brad Diller and Paolo Bonzini.
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
 ======================================================================
"



Object subclass: GuiState [
    | state counter action |
    
    <category: 'Graphics-Windows'>
    <comment: nil>

    GuiState class >> state: aSymbol counter: anInteger [
	<category: 'accessing'>
	^self new 
	    initState: aSymbol
	    counter: anInteger
	    action: ValueHolder null
    ]

    GuiState class >> state: aSymbol counter: anInteger action: aBlock [
	<category: 'accessing'>
	^self new 
	    initState: aSymbol
	    counter: anInteger
	    action: aBlock
    ]

    counter [
	<category: 'accessing'>
	^counter
    ]

    updateTo: newCounter [
	<category: 'accessing'>
	counter := newCounter.
	^action value
    ]

    state [
	<category: 'accessing'>
	^state
    ]

    initState: aSymbol counter: anInteger action: aBlock [
	<category: 'private - accessing'>
	state := aSymbol.
	counter := anInteger.
	action := aBlock
    ]
]



BLOX.Gui subclass: GuiData [
    | checkpoints |
    
    <comment: nil>
    <category: 'Graphics-Windows'>

    changeState: anObject [
	"Record the state change denoted by anObject"

	<category: 'change management'>
	| updateCount |
	checkpoints isNil ifTrue: [checkpoints := LookupTable new].
	updateCount := checkpoints at: anObject ifAbsent: [0].
	checkpoints at: anObject put: updateCount + 1
    ]

    getCurrentState [
	<category: 'change management'>
	^checkpoints copy
    ]

    getStateChanges: viewState [
	"Compare current state with viewState and return an object which describes
	 differences"

	<category: 'change management'>
	| stateChanges |
	viewState isNil | checkpoints isNil ifTrue: [^nil].
	viewState keysAndValuesDo: 
		[:stateId :state | 
		| stateValue |
		stateValue := checkpoints at: stateId ifAbsent: [0].
		state counter < stateValue 
		    ifTrue: 
			[stateChanges isNil ifTrue: [stateChanges := Set new].
			stateChanges add: (GuiState state: stateId counter: stateValue)]].
	^stateChanges
    ]
]

PK
     �Mh@ec�               ��    Menu.stUT cqXOux �  �  PK
     �Mh@����  �            ��C  Load.stUT cqXOux �  �  PK
     �Mh@���
  
            ��g  PList.stUT cqXOux �  �  PK
     �Mh@�����3  �3            ���(  Inspector.stUT cqXOux �  �  PK
     �Mh@���)  �)            ���\  NamespBrow.stUT cqXOux �  �  PK
     �Mh@���u(  (            ����  DebugSupport.stUT cqXOux �  �  PK
     �Mh@�O:B  B            ��0�  ButtonForm.stUT cqXOux �  �  PK
     �Zh@�^��              ����  package.xmlUT ��XOux �  �  PK
     �Mh@�l+  +            ���  ModalDialog.stUT cqXOux �  �  PK
     �Mh@t8M��  �            ����  ClassBrow.stUT cqXOux �  �  PK
     �Mh@�F,  ,            ��J�  BrowserMain.stUT cqXOux �  �  PK
     �Mh@Tl��(  (            ����  BrowShell.stUT cqXOux �  �  PK
     �Mh@d��  �            ��,�  DictInspect.stUT cqXOux �  �  PK
     �Mh@�l�c  c            �� View.stUT cqXOux �  �  PK
     �Mh@[ʛ�+  �+            ���! PText.stUT cqXOux �  �  PK
     �Mh@'@��  �  
          ���M Manager.stUT cqXOux �  �  PK
     �Mh@��|5��  ��            ���b ClassHierBrow.stUT cqXOux �  �  PK
     �Mh@�xR?�0  �0            ���� Debugger.stUT cqXOux �  �  PK
     �Mh@y�0�;  ;            ��� PCode.stUT cqXOux �  �  PK
     �Mh@�i<2�	  �	            ��Y StrcInspect.stUT cqXOux �  �  PK    �Mh@��l4$  ��  	         ��'c ChangeLogUT cqXOux �  �  PK
     �Mh@^]�F�
  �
            ���� RadioForm.stUT cqXOux �  �  PK
     �Mh@�d?N'  N'            ��Ē MethSetBrow.stUT cqXOux �  �  PK
     �Mh@�AS  S            ��Z� MethInspect.stUT cqXOux �  �  PK
     �Mh@f��h�  �            ���� Notifier.stUT cqXOux �  �  PK
     �Mh@u&�(  (  
          ���� GuiData.stUT cqXOux �  �  PK      D  3�   