PK
     �Mh@�rR�a   a     GtkHSidebarWidget.stUT	 eqXO�XOux �  �  GtkSidebarWidget subclass: GtkHSidebarWidget [

    panedOrientation [
	^ GTK.GtkHPaned
    ]
]

PK
     &\h@              Implementors/UT	 �XO�XOux �  �  PK
     �Mh@�3:�  �  &  Implementors/GtkSenderResultsWidget.stUT	 eqXO�XOux �  �  GtkImageResultsWidget subclass: GtkSenderResultsWidget [

    GtkSenderResultsWidget class [ | LiteralsAndSpecialSelectors | ]

    GtkSenderResultsWidget class >> literalsAndSpecialSelectors [
        <category: 'accessing'>

        ^ LiteralsAndSpecialSelectors ifNil: [
            LiteralsAndSpecialSelectors := Dictionary new.
            [ CompiledMethod allInstancesDo: [ :each |
                each literalsAndSpecialSelectorsDo: [ :lit |
                    lit isSymbol
                        ifTrue: [ (LiteralsAndSpecialSelectors at: lit ifAbsentPut: [ OrderedCollection new ]) add: each ]
                        ifFalse: [  "lit isClass ifTrue: [ lit displayString printNl.
                                            (LiteralsAndSpecialSelectors at: lit displayString asSymbol ifAbsentPut: [ OrderedCollection new ]) add: each ]" ]
                                 ] ] ] fork.
            LiteralsAndSpecialSelectors ]
    ]

    buildTreeView [
        <category: 'user interface'>

	| widget |
	widget := super buildTreeView.
	model contentsBlock: [ :each | {each displayString} ].
	^ widget
    ]

    appendSenderResults: aDictionary [

	self
	    clear;
	    findInMethod: aDictionary values first element
    ]

    literalsAndSpecialSelectors [
        <category: 'accessing'>

        ^  self class literalsAndSpecialSelectors
    ]

    findInMethod: anObject [
        <category: 'find'>

        (self literalsAndSpecialSelectors at: anObject displaySymbol ifAbsent: [ #() ] ) do: [ :each |
            model append: each ].
    ]

    selectedResult: aBrowser [

        | currentMethod |
	self hasSelectedResult ifFalse: [ ^ self ].
        currentMethod := self selectedResult.

        aBrowser
                selectANamespace: currentMethod methodClass environment;
                selectAClass: (currentMethod methodClass isClass ifTrue: [ currentMethod methodClass ] ifFalse: [ currentMethod methodClass instanceClass ]).
        currentMethod methodClass isClass
                ifTrue: [ aBrowser selectAnInstanceMethod: currentMethod selector ]
                ifFalse: [ aBrowser selectAClassMethod: currentMethod selector  ]
    ]
]

PK
     �Mh@�B$�    +  Implementors/GtkImplementorResultsWidget.stUT	 eqXO�XOux �  �  GtkImageResultsWidget subclass: GtkImplementorResultsWidget [

    buildTreeView [
        <category: 'user interface'>

	| widget |
	widget := super buildTreeView.
	model contentsBlock: [ :each | {each key asString} ].
	^ widget
    ]

    appendImplementorResults: aDictionary [

	self clear.
	aDictionary associationsDo: [ :each | model append: each ]
    ]

    selectedResult: aBrowser [

        self hasSelectedResult ifFalse: [ ^ self ].
        self selectedResult value updateBrowser: aBrowser 
    ]

]

PK
     �Mh@|uʼ  �  %  Implementors/GtkImageResultsWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkImageResultsWidget [
    | result resultTree model |

    initialize [
        <category: 'initialization'>

        self mainWidget: self buildTreeView
    ]

    buildTreeView [
        <category: 'user interface'>

        resultTree := GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: 'Methods and Classes'}}.
        resultTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkListModel on: resultTree getModel)
                                        contentsBlock: [ :each | {each asString} ].
        ^ GTK.GtkScrolledWindow withChild: resultTree
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        resultTree getSelection
            connectSignal: 'changed' to: anObject selector: aSelector
    ]

    clear [
        <category: 'accessing'>

        model clear
    ]

    hasSelectedResult [
        <category: 'testing'>

        ^ resultTree hasSelectedItem
    ]

    selectedResult [
        <category: 'accessing'>

        self hasSelectedResult ifFalse: [ ^ self error: 'nothing is selected' ].
        ^ resultTree selection
    ]

    appendResults: aDictionary [

    ]

]

PK
     �Mh@��Z      GtkNamespaceSelectionChanged.stUT	 eqXO�XOux �  �  Announcement subclass: GtkNamespaceSelectionChanged [
    | selectedNamespace |

    selectedNamespace [
	<category: 'accessing'>

	^ selectedNamespace
    ]

    selectedNamespace: aSelectedNamespace [
	<category: 'accessing'>

	selectedNamespace := aSelectedNamespace
    ]
]
PK
     �Mh@Q�:	  	    GtkConcreteWidget.stUT	 eqXO�XOux �  �  GtkAbstractConcreteWidget subclass: GtkConcreteWidget [
    | child parentWindow popupMenu |

    GtkConcreteWidget class >> parentWindow: aGtkWindow [
	<category: 'instance creation'>

        ^ self new
            parentWindow: aGtkWindow;
            initialize;
            yourself
    ]

    GtkConcreteWidget class >> showAll [
	<category: 'instance creation'>

	^ self new
	    initialize;
	    showAll;
	    yourself
    ]

    initialize [
	<category: 'initialize'>

    ]

    parentWindow: aGtkWindow [
        <category: 'accessing'>

        parentWindow := aGtkWindow
    ]
    
    parentWindow [
	<category: 'accessing'>

	^ parentWindow
    ]

    mainWidget [
	<category: 'accessing'>

	^ child
    ]

    mainWidget: aGtkWidget [
	<category: 'accessing'>

	child ifNotNil: [ child hideAll  ].
	child := aGtkWidget
    ]

    showAll [
	<category: 'user interface'>

	child showAll
    ]

    hideAll [
	<category: 'user interface'>

	child hideAll
    ]

    isVisible [
	<category: 'testing'>

	^ child getVisible
    ]

    hasFocus [
	<category: 'testing'>

        | parent current |
        parent := child.
        [ (current := parent getFocusChild) notNil ] whileTrue: [
            parent := current ].
        ^ self parentWindow getFocus = parent

    ]

    focusedWidget [
	<category: 'focus'>

        self hasFocus ifTrue: [ ^ self ].
        ^ nil
    ]

    onFocusPerform: aSymbol [
        <category: 'widget'>

        ^ self focusedWidget perform: aSymbol
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := popupMenu asPopupMenu.
        menu attachToWidget: self treeView detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    connectToWhenPopupMenu: aMenuBuilder [
	<category: 'user interface'>

	popupMenu := aMenuBuilder.
	^ self treeView connectSignal: 'button-press-event' to: self selector: #'onPress:event:'
    ]

    grabFocus [
	<category: 'user interface'>

    ]

    close [
	<category: 'user interface'>
    ]
]
PK
     �Mh@\����	  �	    GtkTreeModel.stUT	 eqXO�XOux �  �  Object subclass: GtkTreeModel [

    GtkTreeModel class >> on: aGtkTreeStore [
	<category: 'instance creation'>

	^ super new
	    initialize;
	    gtkModel: aGtkTreeStore;
	    yourself
    ]

    | childrenBlock contentsBlock item model |

    initialize [
	<category: 'initialization'>

    ]

    gtkModel: aGtkTreeStore [
	<category: 'accessing'>

	model := aGtkTreeStore
    ]

    connectSignal: aString to: anObject selector: aSymbol [
	<category: 'events'>

	^ model connectSignal: aString to: anObject selector: aSymbol
    ]

    item: anObject [
	<category: 'accessing'>

	item := anObject
    ]

    item [
	<category: 'accessing'>

	^ item
    ]

    childrenBlock: aBlock [
	<category: 'accessing'>

	childrenBlock := aBlock
    ]

    childrenBlock [
	<category: 'accessing'>

	^ childrenBlock
    ]

    contentsBlock: aBlock [
	<category: 'accessing'>

	contentsBlock := aBlock
    ]

    contentsBlock [
	<category: 'accessing'>

	^ contentsBlock
    ]

    append: anObject [
        <category:' model'>

        self append: anObject with: nil
    ]

    append: anObject parent: aParentObject [
	<category:' model'>

	self append: anObject with: (self findIter: aParentObject)
    ]

    append: anItem with: aParentIter [
        <category:' model'>

        | iter |
        iter := model append: aParentIter item: ((self contentsBlock value: anItem) copyWith: anItem).
        (self childrenBlock value: anItem) do: [ :each | self append: each with: iter ]
    ]

    remove: anObject ifAbsent: aBlock [
	<category: 'model'>

        | iter |
        iter := self findIter: anObject ifAbsent: [ ^ aBlock value ].
        model remove: iter
    ]

    remove: anObject [
	<category: 'model'>

	self remove: anObject ifAbsent: [ self error: 'item not found' ]
    ]

    clear [
	<category: 'model'>

	model clear
    ]

    refresh [
	<category: 'model'>

	self clear.
	self item ifNil: [ ^ self ].
	(self childrenBlock value: self item) do: [ :each | self append: each with: nil ]
    ]

    hasItem: anObject [
        <category: 'item selection'>

        self findIter: anObject ifAbsent: [ ^ false ].
        ^ true
    ]

    findIter: anObject ifAbsent: aBlock [
	<category: 'item selection'>

	model do: [ :elem :iter |
	    elem last = anObject ifTrue: [ ^ iter ] ].
	aBlock value
    ]

    findIter: anObject [
	<category: 'item selection'>

	^ self findIter: anObject ifAbsent: [ self error: 'Item not found' ]
    ]

    includes: anObject [
	self findIter: anObject ifAbsent: [ ^ false ].
	^ true
    ]
]

PK
     �Mh@�u���  �    GtkWorkspaceWidget.stUT	 eqXO�XOux �  �  GtkTextWidget subclass: GtkWorkspaceWidget [

    | variableWidget variableTracker object |
    
    initialize [
	<category: 'intialization'>

	variableTracker := (WorkspaceVariableTracker new)
				initialize;
				yourself.
	object := variableTracker objectClass new.
	super initialize.
	self connectToWhenPopupMenu: (WorkspaceMenus on: self)
    ]

    postInitialize [
        <category: 'initialize'>

	variableWidget hideAll.
	super postInitialize
    ]

    buildWidget [
        <category: 'user interface'>

        ^ (GTK.GtkHPaned new)
		    add1: (variableWidget := GtkVariableTrackerWidget on: object) mainWidget;
		    add2: super buildWidget;
                    yourself
    ]

    object: anObject [
	<category: 'evaluation'>

        variableTracker := nil.
        object := anObject.
    ]

    targetObject [
	<category: 'evaluation'>

        ^ object
    ]

    beforeEvaluation [
        <category: 'smalltalk event'>

	| text nodes |
        variableTracker isNil ifTrue: [^self].
	text := self selectedText.
	nodes := STInST.RBParser parseExpression: text onError: [ :s :p | self error: s ].
	variableTracker visitNode: nodes
    ]

    afterEvaluation [
        <category: 'smalltalk event'>

	variableWidget refresh
    ]

    doIt [
	<category: 'smalltalk event'>

	DoItCommand executeOn: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand executeOn: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand executeOn: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand executeOn: self
    ]

    showIVar [
	<category: 'smalltalk event'>

	variableWidget mainWidget getVisible 
		ifFalse: [ variableWidget showAll ]
		ifTrue: [ variableWidget hideAll ].
    ]
]
PK
     �Mh@���  �    GtkBrowsingTool.stUT	 eqXO�XOux �  �  GtkVisualGSTTool subclass: GtkBrowsingTool [
    <comment: 'I am the base for various browsers of VisualGST.'>

    selectedText [
        <category: 'command protocols'>

        self subclassResponsibility
    ]

    acceptIt [
	<category: 'method events'>

	self subclassResponsibility
    ]

    browserHasFocus [
        <category: 'command protocols'>

        ^true
    ]

    onDelete: aGtkWidget event: aGdkEvent [
        <category: 'window events'>

        self saveCodeOr: [ window hideAll ].
        ^ true
    ]

    saveCodeOr: dropBlock [
        <category: 'saving'>

        | dialog |
        self hasChanged ifFalse: [ dropBlock value. ^self ].
        dialog := GTK.GtkMessageDialog
                                new: window
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Accept changes before exiting?'
                                tip: 'If you choose "drop", your changes to %1 will be lost...' % {self state}.

        dialog
            addButton: 'Drop' responseId: 0;
            addButton: 'Cancel' responseId: 2;
            addButton: 'Accept' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 1 ifTrue: [ self acceptIt ].
                res <= 1 ifTrue: dropBlock.
                dlg destroy ].
    ]

    checkCodeWidgetAndUpdate: aBlock [
        <category: 'text editing'>

        self saveCodeOr: [ aBlock value. self clearUndo ].
    ]

    hasChanged [
        <category: 'testing'>

        self subclassResponcibility
    ]

    clearUndo [
	<category: 'undo'>

	
        self subclassResponcibility
    ]
]

PK
     %\h@              Text/UT	 �XO�XOux �  �  PK
     �Mh@Iw_�D&  D&    Text/GtkTextWidget.stUT	 fqXO�XOux �  �  GtkConcreteWidget subclass: GtkTextWidget [
    | findWidget replaceWidget textWidget userAction undoStack lastCommand cut textSaved lastSavedCommand |

    GtkTextWidget class >> newWithBuffer: aGtkTextBuffer [
        <category: 'instance creation'>

	^ self new
	    initialize;
	    buffer: aGtkTextBuffer;
	    yourself
    ]

    connectToWhenPopupMenu: aMenu [
        <category: 'button event'>
        popupMenu := aMenu.
	textWidget
	    connectSignal: 'populate-popup' to: self selector: #'popupMenuOn:menu:'
    ]

    popupMenuOn: aWidget menu: aGtkMenu [
        <category: 'button event'>
        aGtkMenu append: (GTK.GtkMenuItem new show; yourself).
        popupMenu appendTo: aGtkMenu
    ]

    connectSignals [
	<category: 'initialization'>

	textWidget
	    connectSignal: 'paste-clipboard' to: self selector: #pasteFromClipboard;
            connectSignal: 'cut-clipboard' to: self selector: #cutFromClipboard.

	(self buffer)
            connectSignal: 'begin-user-action' to: self selector: #'beginUserAction';
            connectSignal: 'end-user-action' to: self selector: #'endUserAction';
            connectSignal: 'insert-text' to: self selector: #'insert:at:text:size:';
            connectSignal: 'delete-range' to: self selector: #'delete:from:to:'
    ]

    initialize [
        <category: 'initialization'>

	textSaved := false.
        cut := userAction := false.
        undoStack := (UndoStack new)
                        initialize;
                        yourself.
	textWidget := GTK.GtkTextView new.
	self 
	    mainWidget: self buildWidget;
	    connectSignals.
	
    ]

    postInitialize [
        <category: 'initialize'>

        findWidget mainWidget hide.
        replaceWidget mainWidget hide.
    ]

    buildWidget [
	<category: 'user interface'>

        | vbox |
        vbox := GTK.GtkVBox new: false spacing: 3.
        self packPluginsInto: vbox.
        vbox packStart: (GTK.GtkScrolledWindow withChild: textWidget) expand: true fill: true padding: 0.
        ^vbox
    ]

    packPluginsInto: vbox [
	<category: 'user interface'>
        vbox
            packEnd: ((findWidget := GtkFindWidget on: self) mainWidget) expand: false fill: false padding: 0;
            packEnd: ((replaceWidget := GtkReplaceWidget on: self)  mainWidget) expand: false fill: false padding: 0;
            yourself
    ]

    beginUserAction [
        <category: 'buffer events'>

        userAction := true
    ]

    endUserAction [
        <category: 'buffer events'>

        userAction := false
    ]

    pasteFromClipboard [
        <category: 'clipboard events'>

        lastCommand := nil
    ]

    cutFromClipboard [
        <category: 'clipboard events'>

        cut := true and: [ self buffer getHasSelection ].
        cut ifTrue: [ lastCommand := nil ]
    ]

    insert: aGtkTextBuffer at: aCObject text: aString size: anInteger [
        <category: 'buffer events'>

        | gtkTextIter offset |
        userAction ifFalse: [ ^ self ].
        gtkTextIter := GTK.GtkTextIter address: aCObject address.
	(aString size = 1 and: [ aString first = Character lf]) 
	    ifTrue: [ lastCommand := InsertTextCommand insert: aString at: gtkTextIter getOffset on: self buffer.
                undoStack push: lastCommand.
		lastCommand := nil.
		^ self ].
        (lastCommand isNil or: [ aString size > 1 ])
            ifTrue: [ lastCommand := InsertTextCommand insert: aString at: gtkTextIter getOffset on: self buffer.
                undoStack push: lastCommand.
                aString size > 1 ifTrue: [ lastCommand := nil ].
                ^ self ].
        ((gtkTextIter getOffset = (lastCommand offset + lastCommand size)) and: [ lastCommand isInsertCommand ])
            ifTrue: [ lastCommand string: (lastCommand string, aString).
                ^ self ].
        lastCommand := InsertTextCommand insert: aString at: gtkTextIter getOffset on: self buffer.
        undoStack push: lastCommand.
    ]

    delete: aGtkTextBuffer from: aStartCObject to: anEndCObject [
        <category: 'buffer events'>

        | startIter endIter text |
        userAction ifFalse: [ cut := false. ^ self ].
        startIter := GTK.GtkTextIter address: aStartCObject address.
        endIter := GTK.GtkTextIter address: anEndCObject address.
        text := self buffer getText: startIter end: endIter includeHiddenChars: false.
        (lastCommand isNil or: [ cut ])
            ifTrue: [ lastCommand := DeleteTextCommand from: startIter getOffset to: endIter getOffset text: text on: self buffer.
                undoStack push: lastCommand.
                cut ifTrue: [ lastCommand := nil ].
                cut := false.
                ^ self ].
        ((startIter getOffset = (lastCommand offset - lastCommand size)) and: [ lastCommand isDeleteCommand ])
            ifTrue: [ lastCommand string: (text, lastCommand string).
                ^ self ].
        lastCommand := DeleteTextCommand from: startIter getOffset to: endIter getOffset text: text on: self buffer.
        undoStack push: lastCommand.
    ]

    hasChanged [
        <category: 'testing'>

        ^ textSaved not and: [ undoStack hasUndo ]
    ]

    hasUndo [
	<category: 'buffer events'>

	^ undoStack hasUndo
    ]

    clearUndo [
	<category: 'buffer events'>

        textSaved := false.
        lastSavedCommand := nil.
	undoStack clear
    ]

    undo [
        <category: 'buffer events'>

        textSaved := self lastUndoCommand == lastSavedCommand.
        undoStack undo.
        lastCommand := nil.
    ]

    redo [
        <category: 'buffer events'>

        undoStack redo.
        lastCommand := nil.
        textSaved := self lastUndoCommand == lastSavedCommand.
    ]

    emptyStack [
	<category: 'stack events'>

	undoStack clear
    ]

    lastUndoCommand [
	<category: 'buffer events'>

	^ undoStack lastUndoCommand
    ]

    textSaved [
        <category: 'accessing'>

        textSaved := true.
        lastCommand := nil.
        lastSavedCommand := undoStack lastUndoCommand
    ]

    buffer [
	<category: 'accessing'>

	^ textWidget getBuffer
    ]

    buffer: aGtkTextBuffer [
	<category: 'accessing'>

	textWidget setBuffer: aGtkTextBuffer
    ]

    showFind [
        <category: 'user interface'>

        replaceWidget hideAll.
	findWidget showAll; grabFocus
    ]

    showReplace [
        <category: 'user interface'>

        findWidget hideAll.
	replaceWidget showAll; grabFocus
    ]

    replace: aSearchString by: aReplaceString [
        <category: 'text editing'>

	lastCommand := ReplaceTextCommand replace: aSearchString by: aReplaceString on: self buffer.
        undoStack push: lastCommand.
        lastCommand := nil
    ]

    copy [
        <category: 'text editing'>

        textWidget signalEmitByName: 'copy-clipboard' args: {}
    ]

    cut [
        <category: 'text editing'>

        textWidget signalEmitByName: 'cut-clipboard' args: {}
    ]

    paste [
        <category: 'text editing'>

        textWidget signalEmitByName: 'paste-clipboard' args: {}.
    ]

    selectAll [
        <category: 'text editing'>

        textWidget signalEmitByName: 'select-all' args: {true}.
    ]

    iterOfSelectedText [
        <category: 'text accessing'>

        ^ textWidget getBuffer iterOfSelectedText
    ]

    hasSelection [
        <category: 'text accessing'>

	^ self buffer getHasSelection
    ]

    selectedMethodSymbol [
	<category: 'accessing'>

        ^ STInST.RBParser selectedSymbol: self selectedText
    ]

    selectedText [
        <category: 'text accessing'>

        ^ self buffer selectedText
    ]

    clear [
        <category: 'updating'>

        self text: ''
    ]

    text [
        <category: 'text accessing'>

        ^ self buffer text
    ]

    text: aString [
        <category: 'text accessing'>

        self buffer setText: aString
    ]

    textview [
	<category: 'text widget'>

	^ textWidget
    ]

    cursorPosition [
	<category: 'accessing'>

	^ self buffer propertiesAt: 'cursor-position'
    ]

    cursorPosition: anInteger [
        <category: 'accessing'>

    ]

    selectRange: aStartInt bound: anEndInt [
	<category: 'accessing'>

	| start end |
	start := self buffer getIterAtOffset: aStartInt.
        end := self buffer getIterAtOffset: anEndInt.
	self buffer selectRange: start bound: end
    ]

    beforeEvaluation [
        <category: 'smalltalk event'>
    ]

    afterEvaluation [
        <category: 'smalltalk event'>
    ]

    doIt: object [
        <category: 'smalltalk event'>

	| result |
        self beforeEvaluation.
        result := Behavior
		    evaluate: self buffer selectedText
		    to: object
		    ifError: [ :fname :lineNo :errorString | self error: errorString ].
	self afterEvaluation.
	^ result
    ]

    debugIt: object [
        <category: 'smalltalk event'>

        self beforeEvaluation.
        object class
            compile: ('Doit [ ^ [ ', self selectedText , ' ] value ]')
            ifError:  [ :fname :lineNo :errorString |
                self error: errorString ].
        (GtkDebugger open)
            doItProcess: [ object perform: #Doit ] newProcess
    ]

    inspectIt: object [
        <category: 'smalltalk event'>

        GtkInspector openOn: (self doIt: object)
    ]

    printIt: object [
        <category: 'smalltalk event'>

        | iter start end result |
        iter := self buffer iterOfSelectedText second.
        result := ' ', ((self doIt: object) displayString), ' '.
        self buffer insertInteractive: iter text: result len: result size defaultEditable: true.
        start := self buffer getIterAtOffset: (iter getOffset - result size).
        end := self buffer getIterAtOffset: (iter getOffset).
        self buffer selectRange: start bound: end
    ]

]
PK
     �Mh@}M�*  *    Text/GtkTextPluginWidget.stUT	 fqXO�XOux �  �  GtkConcreteWidget subclass: GtkTextPluginWidget [
    | textWidget closeButton |

    GtkTextPluginWidget class >> on: aTextWidget [
	<category: 'instance creation'>

	^ self new
	    initialize;
	    textWidget: aTextWidget;
	    yourself
    ]

    initialize [
	<category: 'initialize'>

	self mainWidget: self buildWidget
    ]

    buildCloseButton [
        <category: 'user interface'>

	^(closeButton := GTK.GtkButton closeButton)
	    connectSignal: 'pressed' to: self selector: #'close' userData: nil;
	    yourself
    ]

    hBox [
        <category: 'user interface'>

        ^ (GTK.GtkHBox new: false spacing: 3)
            packEnd: self buildCloseButton expand: false fill: false padding: 0;
            yourself
    ]

    buildWidget [
	<category: 'user interface'>

	^ (GTK.GtkVBox new: false spacing: 3)
	    packStart: self hBox expand: false fill: false padding: 0;
	    yourself
    ]

    close [
	<category: 'events'>

	self mainWidget hide
    ]

    textWidget: aTextWidget [
	<category: 'accessing'>

	textWidget := aTextWidget
    ]
]

PK
     �Mh@��\u  u    Text/GtkSourceCodeWidget.stUT	 fqXO�XOux �  �  GtkTextWidget subclass: GtkSourceCodeWidget [
    | browser codeText saveWidget |

    initialize [
	<category: 'initialization'>

	super initialize.
	self initializeHighlighter
    ]

    initializeHighlighter [
	<category: 'initialization'>

	(self buffer)
	    createTag: #classVar varargs: #('foreground' 'cyan4' nil);
	    createTag: #globalVar varargs: #('foreground' 'cyan4' nil);
	    createTag: #poolVar varargs: #('foreground' 'cyan4' nil);
	    createTag: #undeclaredVar varargs: #('foreground' 'red' nil);
	    createTag: #instanceVar varargs: #('foreground' 'black' nil);
	    createTag: #argumentVar varargs: #('foreground' 'black' nil);
	    createTag: #temporary varargs: #('foreground' 'black' nil);
	    createTag: #specialId varargs: #('foreground' 'grey50' nil);
	    createTag: #literal varargs: #('foreground' 'grey50' nil);
	    createTag: #temporaries varargs: #('foreground' 'magenta' nil);
	    createTag: #methodHeader varargs: #('foreground' 'magenta' nil);
	    createTag: #primitive varargs: #('foreground' 'magenta' nil);
	    createTag: #arguments varargs: #('foreground' 'magenta' nil);
	    createTag: #special varargs: #('foreground' 'magenta' nil);
	    createTag: #unaryMsg varargs: #('foreground' 'magenta4' nil);
	    createTag: #binaryMsg varargs: #('foreground' 'chocolate4' nil);
	    createTag: #keywordMsg varargs: #('foreground' 'NavyBlue' nil);
	    createTag: #comment varargs: #('foreground' 'SpringGreen4' nil)
    ]

    sourceCode [
	<category: 'accessing'>

	^ self buffer text
    ]

    source: aSource [
	<category: 'accessing'>

        | string |
        string := aSource source.
	self emptyStack.
	self codeText: string. 
	self buffer setText: self codeText.
	aSource parser == STInST.RBBracketedMethodParser ifTrue: [
            self parseSource: string ifParsed: [ :node | SyntaxHighlighter highlight: node in: self buffer ] ]
    ]

    parseSource: aString ifParsed: aOneArgBlock [
	<category: 'parsing'>

	| node parser |
	parser := STInST.RBBracketedMethodParser new
                    errorBlock: [ :string :pos | ^ self ];
                    initializeParserWith: aString type: #'on:errorBlock:';
                    yourself.
        [ node := parser parseMethod ] on: Error do: [ :ex | stderr print: ex messageText; nl; print: ex signalingContext; nl; nl. ^ self ].
	^ aOneArgBlock value: node
    ]

    connectSignals [
        <category: 'initialization'>

	super connectSignals.
        self
            connectToWhenPopupMenu: (TextMenus on: self).
        (self buffer)
	    connectSignal: 'changed' to: self selector: #'changed' userData: nil
    ]

    buildWidget [
	<category: 'user interface'>
	
        ^ (GTK.GtkFrame new: 'Code')
            add: super buildWidget;
            yourself
    ]

    changed [
	<category: 'buffer changed'>

	| node text |
	(text := self buffer text) = '' ifTrue: [ ^ self ].
	self parseSource: text ifParsed: [ :node | SyntaxHighlighter highlight: node in: self buffer ]
    ]

    state [
	<category: 'state'>

        ^browser state
    ]

    packPluginsInto: vbox [
	<category: 'user interface'>
        vbox
            packStart: ((saveWidget := GtkSaveTextWidget on: self)  mainWidget) expand: false fill: false padding: 0.
        super packPluginsInto: vbox
    ]

    showSave: aString [
        <category: 'user interface'>

        saveWidget label: aString.
	saveWidget showAll
    ]

    postInitialize [
        <category: 'initialize'>

        super postInitialize.
        saveWidget mainWidget hide
    ]

    acceptIt [
	<category: 'buffer events'>

	browser acceptIt
    ]

    compileError: aString line: line [
	<category: 'class event'>

        self showSave: aString
    ]

    cancel [
	<category: 'buffer events'>

	self clearUndo.
        saveWidget hideAll.
	self buffer setText: self codeText
    ]

    doIt [
        <category: 'smalltalk event'>

        ^ browser doIt
    ]

    debugIt [
        <category: 'smalltalk event'>

        ^ browser debugIt
    ]

    inspectIt [
        <category: 'smalltalk event'>

        ^ browser inspectIt
    ]

    printIt [
        <category: 'smalltalk event'>

        ^ browser printIt
    ]

    codeSaved [
	<category: 'accessing'>

        saveWidget hideAll.
	self textSaved
    ]

    codeText [
	<category: 'accessing'>

	^ codeText ifNil: [ codeText := '' ]
    ]

    codeText: aString [
	<category: 'accessing'>

	codeText := aString copy
    ]

    browser: aGtkClassBrowserWidget [
	<category: 'accessing'>

	browser := aGtkClassBrowserWidget
    ]

    selectedMethodSymbol [
	<category: 'method'>

        | iters stream parser node |
	stream := self sourceCode readStream.
        iters := self buffer getSelectionBounds.
        parser := STInST.RBBracketedMethodParser new.
        parser errorBlock: [:message :position | ^nil].
        parser 
            scanner: (parser scannerClass on: stream errorBlock: parser errorBlock).
        node := parser parseMethod body.
        node := node bestNodeFor:
	    (iters first getOffset + 1 to: iters second getOffset + 1).
        [node isNil ifTrue: [^nil].
	node isMessage] whileFalse: 
                [node := node parent].
        ^node selector
    ]

    sourceCodeWidgetHasFocus [
	<category: 'browse'>

	^ true
    ]

    browserHasFocus [
	<category: 'browse'>

	^ false
    ]

    launcher [
	<category: 'browse'>

	^browser ifNotNil: [ browser launcher ]
    ]

    browseSenders [
	<category: 'browse'>

	OpenSenderCommand on: self
    ]

    browseImplementors [
	<category: 'browse'>

	^ browser ifNotNil: [ browser launcher ]
    ]

    appendTag: aSymbol description: anArray [
	<category: 'text buffer'>

	self buffer
            createTag: aSymbol varargs: anArray
    ]

    applyTag: aSymbol forLine: anInteger [
	<category: 'text buffer'>

	| start end |
	start := self buffer getIterAtLine: anInteger - 1.
	end := self buffer getIterAtLine: anInteger.
	self buffer applyTagByName: aSymbol start: start end: end
    ]
]

PK
     �Mh@��?
  ?
    Text/GtkFindWidget.stUT	 fqXO�XOux �  �  GtkTextPluginWidget subclass: GtkFindWidget [
    | entry matchCase next previous lastPosition |

    buildEntry [
	<category: 'user interface'>

	^ entry := GTK.GtkEntry new
			connectSignal: 'activate' to: self selector: #keyPressed;
			yourself
    ]

    buildPreviousButton [
	<category: 'user interface'>

        ^ previous := GTK.GtkButton previousButton
			connectSignal: 'clicked' to: self selector: #previousPressed;
			yourself
    ]

    buildNextButton [
        <category: 'user interface'>

        ^ next := GTK.GtkButton nextButton
			connectSignal: 'clicked' to: self selector: #keyPressed;
			yourself
    ]

    buildMatchCaseButton [
        <category: 'user interface'>

	^ matchCase := GTK.GtkCheckButton newWithLabel: 'match case'
    ]

    hBox [
	<category: 'user interface'>

	^ super hBox
	    packStart: (GTK.GtkLabel new: 'Find:') expand: false fill: false padding: 2;
	    packStart: self buildEntry expand: false fill: false padding: 15;
	    packStart: self buildPreviousButton expand: false fill: false padding: 0; 
	    packStart: self buildNextButton expand: false fill: false padding: 0;
	    packStart: self buildMatchCaseButton expand: false fill: false padding: 0;
	    yourself
    ]

    grabFocus [
	<category: 'focus'>

	entry grabFocus
    ]

    searchFrom: anInteger [
	<category: 'text searching'>

	^ textWidget text indexOf: entry getText matchCase: matchCase getActive startingAt: anInteger
    ]

    searchBackFrom: anInteger [
	<category: 'text searching'>

	^ textWidget text deindexOf: entry getText matchCase: matchCase getActive startingAt: anInteger
    ]

    keyPressed [
	<category: 'entry events'>

	| int |
	lastPosition := textWidget hasSelection 
					ifTrue: [ textWidget cursorPosition + 2 ]
					ifFalse: [ textWidget cursorPosition + 1 ].
	lastPosition > textWidget text size ifTrue: [ lastPosition := 1 ].
	int := self searchFrom: lastPosition.
	int ifNil: [ (int := self searchFrom: 1) ifNil: [ int := textWidget cursorPosition + 1 to: textWidget cursorPosition ] ].
	textWidget selectRange: int first - 1 bound: int last.
    ]

    previousPressed [
	<category: 'previous events'>

	| int |
	lastPosition := textWidget hasSelection 
					ifTrue: [ textWidget cursorPosition ]
					ifFalse: [ textWidget cursorPosition + 1 ].
	lastPosition = 0 ifTrue: [ lastPosition := textWidget text size ].
	int := self searchBackFrom: lastPosition.
	int ifNil: [ (int := self searchBackFrom: textWidget text size) ifNil: [ int := textWidget cursorPosition + 1 to: textWidget cursorPosition ] ].
	textWidget selectRange: int first - 1 bound: int last.
    ]
]

PK
     �Mh@K]E	  	    Text/GtkSaveTextWidget.stUT	 fqXO�XOux �  �  GtkTextPluginWidget subclass: GtkSaveTextWidget [ 
    | label |

    buildDropButton [
	<category: 'user interface'>

        ^(GTK.GtkButton newWithLabel: 'Drop')
	    connectSignal: 'pressed' to: self selector: #cancel;
            yourself
    ]

    buildAcceptButton [
        <category: 'user interface'>

        ^(GTK.GtkButton newWithLabel: 'Accept')
	    connectSignal: 'pressed' to: self selector: #acceptIt;
            yourself
    ]

    hBox [
	<category: 'user interface'>

	^ super hBox
	    packStart: (label := GTK.GtkLabel new: '') expand: false fill: false padding: 2;
	    packEnd: self buildAcceptButton expand: false fill: false padding: 0; 
	    packEnd: self buildDropButton expand: false fill: false padding: 0;
	    yourself
    ]

    label: aString [
	<category: 'state'>

	label setText: aString
    ]

    grabFocus [
	<category: 'focus'>

	closeButton grabFocus
    ]

    acceptIt [
	<category: 'events'>

	textWidget acceptIt
    ]

    cancel [
	<category: 'events'>

	textWidget cancel
    ]
]

PK
     �Mh@��L�K  K    Text/GtkReplaceWidget.stUT	 fqXO�XOux �  �  GtkFindWidget subclass: GtkReplaceWidget [
    | replaceWidget replaceButton replaceAllButton |

    replaceEntry [
	<category: 'user interface'>

	^ replaceWidget := GTK.GtkEntry new
			    connectSignal: 'activate' to: self selector: #replacePressed;
			    yourself
    ]

    replaceButton [
        <category: 'user interface'>

	^ replaceButton := (GTK.GtkButton newWithLabel: 'Replace')
			    connectSignal: 'clicked' to: self selector: #replacePressed;
			    yourself
    ]

    replaceAllButton [
        <category: 'user interface'>

	^ replaceAllButton := (GTK.GtkButton newWithLabel: 'Replace All')
			    connectSignal: 'clicked' to: self selector: #replaceAllPressed;
			    yourself
    ]

    replaceBox [
        <category: 'user interface'>

	| hBox |
	^ (GTK.GtkHBox new: false spacing: 3)
            packStart: (GTK.GtkLabel new: 'Replace with:') expand: false fill: false padding: 2;
            packStart: self replaceEntry expand: false fill: false padding: 15;
	    packStart: self replaceButton expand: false fill: false padding: 15;
            packStart: self replaceAllButton expand: false fill: false padding: 15;
	    yourself
    ]

    buildWidget [
	<category: 'user interface'>

	^ super buildWidget
	    packStart: self replaceBox expand: false fill: false padding: 0;
	    yourself

    ]

    replacePressed [
	<category: 'replace events'>

	| i iter |
	self keyPressed.
	textWidget hasSelection ifFalse: [ ^ self ].
	i := textWidget iterOfSelectedText first getOffset.
	textWidget cut.
	iter := textWidget buffer getIterAtOffset: i.
	textWidget buffer insertInteractive: iter text: replaceWidget getText len: replaceWidget getText size defaultEditable: true
    ]

    replaceAllPressed [
        <category: 'replace events'>

	"matching doesn't work now"
	textWidget replace: entry getText by: replaceWidget getText
    ]
]

PK
     �Mh@���  �    GtkAssistant.stUT	 eqXO�XOux �  �  GtkBrowsingTool subclass: GtkAssistant [

    GtkAssistant class >> open [
	<category: 'user interface'>

	^ self openSized: 450@375
    ]

    accelPath [
        <category: 'accelerator path'>

        ^ '<Assistant>'
    ]

    windowTitle [
	^ 'Assistant'
    ]

    aboutTitle [
	^ 'About Assistant'
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

        | webview |

        webview := GtkWebView new
                        openUrl: 'http://library.gnome.org/devel/gtk/stable/index.html';
                        showAll;
                        yourself.

	^ (GTK.GtkScrolledWindow withChild: webview)
	    showAll; 
	    yourself
    ]

    hasChanged [
	<comment: 'I have to implement that. But I have nothing to do.'>

	^ false
    ]
]

PK
     &\h@              Clock/UT	 �XO�XOux �  �  PK
     �Mh@�e�U�  �    Clock/GtkClock.stUT	 eqXO�XOux �  �  Smalltalk.Object subclass: GtkClock [
    | canvas hour minute process radius second window x y |

    GtkClock class >> open [
	<category: 'user interface'>

	^ (self new)
	    initialize;
	    showAll;
	    yourself
    ]

    GtkClock class >> openSized: aPoint [
	<category: 'user interface'>
	
	^ (self new)
	    initialize;
	    resize: aPoint;
	    showAll;
	    yourself
    ]

    quit [
	<category: 'events'>

	process terminate.
	window hide
    ]

    time [
	<category: 'time'>

	| now |
	now := DateTime now.
        hour := now hour.
        minute := now minute.
        second := now second.
    ]

    clearArea: aGtkAllocation [
	<category: 'drawing'>

	| res |
        res := aGtkAllocation castTo: (CIntType arrayType: 4).

        canvas saveWhile: [
            canvas
                rectangle: ((0@0) extent: ((res at: 2) @ (res at: 3)));
                operator: #clear;
                fill ]
    ]

    drawClockCircle: context [
	<category: 'drawing'>

        context
            lineWidth: 6;
            stroke: [ context arc: x@y radius: radius from: 0 to: Float pi * 2 ]
    ]

    drawHourMarker: context [
	<category: 'drawing'>

        1 to: 12 do: [ :i |
            context
                lineWidth: 4;
                stroke: [ | inset |
                    inset := 0.1 * radius.
                    context
                        moveTo: (x + ((radius - inset) * (i * Float pi / 6.0) cos)) @ (y + ((radius - inset) * (i * Float pi / 6.0) sin));
                        lineTo: (x + (radius * (i * Float pi / 6.0) cos)) @ (y + (radius * (i * Float pi / 6.0) sin)) ] ]
    ]

    drawClockLine: context angle: anAngFloat [
	<category: 'drawing'>

        context
            lineWidth: 4;
            paint: [
                context stroke: [
                    context
                        sourceRed: 1 green: 0.2 blue: 0.2 alpha: 1.0;
                        moveTo: x@y;
                        lineTo: (x + (radius * anAngFloat  cos)) @ (y + (radius * anAngFloat sin)) ] ]
            withAlpha: 0.64
    ]

    drawHourLine: context [
	<category: 'drawing'>

	self drawClockLine: context angle: (hour \\ 12 * (Float pi / 6.0)) - (Float pi / 2.0).
    ]

    drawMinuteLine: context [
	<category: 'drawing'>

	self drawClockLine: context angle: (minute * (Float pi / 30.0)) - (Float pi / 2.0)
    ]

    drawSecondLine: context [
	<category: 'drawing'>

	self drawClockLine: context angle: (second * (Float pi / 30.0)) - (Float pi / 2.0)
    ]

    drawClock: context [
	<category: 'drawing'>

	self
            drawClockCircle: context;
            drawHourMarker: context;
            drawHourLine: context;
            drawMinuteLine: context;
            drawSecondLine: context
    ]

    expose: aGtkWidget event: aGdkEventExpose [

	aGtkWidget getWindow withContextDo: [ :cr |
	    canvas := cr.

	    x := 128.
	    y := 128.

	    self 
		clearArea: aGtkWidget getAllocation;
		time;
		drawClock: cr ].

	^ true
    ]

    initialize [
	<category: 'intialization'>

	window := (GTK.GtkWindow new: GTK.Gtk gtkWindowToplevel).
	window 
	    setColormap: window getScreen getRgbaColormap;
	    connectSignal: 'expose_event' to: self selector: #'expose:event:';
	    connectSignal: 'delete-event' to: self selector: #'delete:event:';
	    setDecorated: false.
	radius := 100
    ]

    delete: aGtkWidget event: aGdkEvent [
        <category: 'windows event'>

        self quit.
        ^ true
    ]

    resize: aPoint [
	<category: 'user interface'>

	window resize: aPoint x height: aPoint y
    ]

    showAll [
	| delay |

	delay := Delay forSeconds: 1.
	window showAll.
	process := [ [ true ] whileTrue: [ window queueDraw. delay wait ] ] fork
    ]
]
PK
     �Mh@I��l  l    GtkSidebarWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkSidebarWidget [
    | activeWidget widgets widgetEvents paned |

    initialize [
	<category: 'initialization'>

	paned := GTK.GtkNotebook new
				setTabPos: GTK.Gtk gtkPosBottom;
				connectSignal: 'switch-page' to: self selector: #'switchPageOn:page:number:';
				yourself.
	self mainWidget: paned.
	widgetEvents := Dictionary new.
	activeWidget := GtkAbstractConcreteWidget new.
	widgets := OrderedCollection new
    ]

    postInitialize [
	<category: 'initialization'>

	self hideAll
    ]

    add: aGtkWidget labeled: aString [
	<category: 'notebook'>

	paned
            appendPage: aGtkWidget tabLabel: (GTK.GtkLabel new: aString).
	widgets add: aGtkWidget
    ]

    addAll: anArray [
	<category: 'notebook'>

	anArray do: [ :each | self add: each key labeled: each value ]
    ]

    show: anIndex [
	<category: 'notebook'>

	activeWidget hideAll.
	self mainWidget showAll.
	self mainWidget setCurrentPage: anIndex - 1.
	activeWidget := (widgets at: anIndex)
					showAll;
					yourself
    ]

    showAll [
	<category: 'notebook'>

	self mainWidget show
    ]

    hideTabs [
	<category: 'notebook'>

	self mainWidget setShowTabs: false
    ]

    hide [
	<category: 'notebook'>

	self hideMainPained
    ]

    hideAll [
	<category: 'notebook'>

	self hideMainPained
    ]

    hideMainPained [
	<category: 'notebook'>

	self mainWidget hideAll
    ]

    panedOrientation [
	<category: 'accessing'>

	^ self subclassResponsibility
    ]

    switchPageOn: aGtkNotebook page: aGtkNotebookPage number: anInteger [
        <category: 'notebook events'>

	widgetEvents at: (aGtkNotebook getNthPage: anInteger) ifPresent: [ :msg | msg value ]
    ]

    whenWidgetIsVisible: aGtkWidget send: aSymbol to: anObject [
	<category: 'notebook events'>

	widgetEvents at: aGtkWidget put: (DirectedMessage receiver: anObject selector: aSymbol arguments: #())
    ]
]

PK
     %\h@              State/UT	 �XO�XOux �  �  PK
     �Mh@� �s�  �    State/BrowserState.stUT	 fqXO�XOux �  �  Object subclass: BrowserState [
    | state |

    BrowserState class >> on: aBrowser with: aState [
	<category: 'instance creation'>

	^ self new
	    state: aState
    ]

    BrowserState class >> with: aState [
	<category: 'instance creation'>

	^ self new
	    state: aState
    ]

    state: aState [
	<category: 'initialize-release'>

	state := aState
    ]

    displayString [
        <category: 'printing'>

        ^ state displayString
    ]

    hasSelection [
	<category: 'testing'>

	^ ((self hasSelectedNamespace bitOr: self hasSelectedClass) bitOr: self hasSelectedCategory) bitOr: self hasSelectedMethod
    ]

    hasSelectedMethod [
        <category: 'testing'>

        ^ false
    ]

    hasSelectedCategory [
        <category: 'testing'>

        ^ false
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ false
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ false
    ]

    category [
        <category: 'accessing'>

        ^ nil
    ]

    method [
        <category: 'accessing'>

        ^ nil
    ]

    namespace [
        <category: 'accessing'>

        ^ nil
    ]

    classOrMeta [
        <category: 'accessing'>

        ^ nil
    ]

    classCategory [
        <category: 'accessing'>

        ^ ClassCategory extractClassCategory: self classOrMeta
    ]

    updateBrowser: aGtkClassBrowserWidget [
	<category: 'events'>

    ]
]

PK
     �Mh@Sr���  �    State/NamespaceState.stUT	 fqXO�XOux �  �  BrowserState subclass: NamespaceState [

    | classCategory |

    printOn: aStream [
	<category: 'printing'>

	aStream
	    print: self namespace
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ true
    ]

    classCategory: aCategory [
	<category: 'accessing'>

	classCategory := aCategory
    ]

    classCategory [
	<category: 'accessing'>

	^ classCategory
    ]

    namespace [
	<category: 'accessing'>

	^ state
    ]

    updateBrowser: aGtkClassBrowserWidget [
        <category: 'events'>
   
	aGtkClassBrowserWidget 
			updateNamespaceOfClass: self namespace classCategory: self classCategory;
			source: (NamespaceHeaderSource on: self namespace).
    ]
]

PK
     �Mh@��<�J  J    State/MethodState.stUT	 fqXO�XOux �  �  BrowserState subclass: MethodState [

    printOn: aStream [
	<category: 'printing'>

	aStream print: state
    ]

    namespace [
        <category: 'accessing'>

        ^ self classOrMeta environment
    ]

    classOrMeta [
        <category: 'accessing'>

        ^ state methodClass
    ]

    selector [
        <category: 'accessing'>

        ^ state selector
    ]

    method [
        <category: 'accessing'>

        ^ state method
    ]

    category [
        <category: 'accessing'>

        ^ state methodCategory
    ]

    selectedCategory [
        <category: 'accessing'>

        ^ self category
    ]

    hasSelectedMethod [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedCategory [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ true
    ]

    updateBrowser: aGtkClassBrowserWidget [
        <category: 'events'>

        aGtkClassBrowserWidget source: (BrowserMethodSource on: self method).
    ]
]

PK
     �Mh@	I\�j  j    State/CategoryState.stUT	 fqXO�XOux �  �  BrowserState subclass: CategoryState [

    printOn: aStream [
	<category: 'printing'>

	aStream
	    print: self classOrMeta;
	    nextPutAll: ' (';
	    display: self category;
	    nextPut: $)
    ]

    namespace [
	<category: 'accessing'>

	^ state key environment
    ]

    classOrMeta [
	<category: 'accessing'>

	^ state key
    ]

    category [
	<category: 'accessing'>

	^ state value
    ]

    selectedCategory [
	<category: 'accessing'>

	^ self category
    ]

    hasSelectedCategory [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ true
    ]

    displayString [
	<category: 'printing'>

	^ self classOrMeta displayString
    ]

    updateBrowser: aGtkClassBrowserWidget [
        <category: 'events'>

	self classOrMeta isClass 
			    ifTrue: [ aGtkClassBrowserWidget updateInstanceSideMethodCategory: self category ]
			    ifFalse: [ aGtkClassBrowserWidget updateClassSideMethodCategory: self category ].
        aGtkClassBrowserWidget clearSource
    ]
]

PK
     �Mh@p�®  �    State/ClassState.stUT	 fqXO�XOux �  �  BrowserState subclass: ClassState [

    printOn: aStream [
	<category: 'printing'>

	aStream
	    print: self classOrMeta
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ true
    ]

    namespace [
	<category: 'accessing'>

	^ state environment
    ]

    classOrMeta [
	<category: 'accessing'>

	^ state
    ]

    updateBrowser: aGtkClassBrowserWidget [
        <category: 'events'>

        aGtkClassBrowserWidget 
                        updateClassOfCategory: self classOrMeta asClass;
                        source: (ClassHeaderSource on: self classOrMeta asClass).
    ]
]

PK
     �Mh@�N�,�  �    GtkSimpleListWidget.stUT	 eqXO�XOux �  �  GtkScrollTreeWidget subclass: GtkSimpleListWidget [

    GtkSimpleListWidget class >> named: aString [
	<category: 'instance creation'>

	^ self createListWithModel: {{GtkColumnTextType title: aString}}
    ]

    buildTreeView [
        <category: 'user interface'>

        self treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (GtkListModel on: self treeView getModel)
                                        contentsBlock: [ :each | {each displayString} ]
    ]
]

PK
     &\h@              SUnit/UT	 �XO�XOux �  �  PK
     �Mh@��lc�  �    SUnit/GtkSUnitResultWidget.stUT	 fqXO�XOux �  �  GtkConcreteWidget subclass: GtkSUnitResult [
    | model resultTree results |
    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    buildTreeView [
        <category: 'user interface'>

        resultTree := (GTK.GtkTreeView newWithTextColumn: self model title: 'Results')
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:' userData: nil;
                            yourself.
        ^ GTK.GtkScrolledWindow withChild: resultTree
    ]

    model [
        <category: 'model'>

        ^ model ifNil: [
            model := GTK.GtkTreeStore new: 2 varargs: {GTK.GValue gTypeString. GLib.GType oopType} ]
    ]

    clearModel [
	<category: 'model'>

	self model clear
    ]

    results: aSet [
	<category: 'accessing'>

	self clearModel.
	results := aSet.
	results do: [ :each |
	    self model appendItem: {each displayString. each} ]
    ]

    popupMenuOn: aGtkWidget menu: aGtkMenu [
	<category: 'events'>
	| menuitem symbol |

        symbol := self selectedMethodSymbol.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Run test'.
        menuitem
            show;
            connectSignal: 'activate' to: self selector: #debugTest userData: nil.
        aGtkMenu append: menuitem.
	"TODO: show test"
        menuitem := GTK.GtkMenuItem new.
        menuitem show.
        aGtkMenu append: menuitem.
        menuitem := GTK.GtkMenuItem newWithLabel: 'Browse implementors'.
        menuitem
            setSensitive: symbol notNil;
            show;
            connectSignal: 'activate' to: self selector: #browseImplementors userData: nil.
        aGtkMenu append: menuitem.
    ]

    onPress: aGtkWidget event: aGdkEvent [
	<category: 'events'>
	| aGdkButtonEvent menu |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
	self popupMenuOn: aGtkWidget menu: menu.
        menu attachToWidget: resultTree detacher: nil.
        menu showAll.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        ^ true
    ]

    debugTest [
	<category: 'event'>
	
        DebugTestCommand executeOn: self
    ]

    hasSelectedMethod [
        <category: 'testing'>

        ^ resultTree hasSelectedItem
    ]

    state [
        <category: 'state'>
        resultTree hasSelectedItem ifTrue: [
            ^MethodState on: self selectedResult class >> self selectedResult selector ].
        ^BrowserState new
    ]
	
    selectedMethodSymbol [
        <category: 'accessing'>

        ^ self selectedResult ifNotNil: [ :result | result selector ]
    ]

    selectedMethod [
        <category: 'accessing'>

        self hasSelectedMethod ifFalse: [ self error: 'Nothing is selected' ].
        ^ self class compiledMethodAt: self selectedMethodSymbol
    ]

    selectedResult [
        <category: 'accessing'>

	| iter |
        (iter := resultTree selectedIter) ifNil: [ self error: 'Nothing is selected' ].
        ^ self model getOop: iter column: 1
    ]

    browseImplementors [
        OpenImplementorCommand executeOn: self
    ]
]

PK
     �Mh@��!6  6    SUnit/TestBacktraceLog.stUT	 fqXO�XOux �  �  Smalltalk.TestLogPolicy subclass: TestBacktraceLog [
    | logStatus hadSuccesses |

    initialize: aStream [
	<category: 'Initializing'>

	super initialize: aStream.
	hadSuccesses := false
    ]

    flush [
	<category: 'logging'>

	hadSuccesses := false
    ]

    logError: anException [
	<category: 'logging'>

	logStatus := anException
    ]

    logFailure: aFailure [
	<category: 'logging'>
	
	logStatus := thisContext.
    ]

    logSucces [
	<category: 'logging'>

	hadSuccesses := true
    ]

    logStatus [
	<category: 'logging'>

	^ logStatus
    ]
]

PK
     �Mh@���5�,  �,    SUnit/GtkSUnit.stUT	 fqXO�XOux �  �  GtkBrowsingTool subclass: GtkSUnit [
    | namespaceWidget classWidget methodWidget sourceCodeWidget successfullWidget failedWidget errorWidget namespace class state |

    accelPath [
        <category: 'accelerator path'>

        ^ '<SUnit>'
    ]

    createRunMenus [
        <category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'Load tests' connectTo: self selector: #loadTests.
	  GTK.GtkMenuItem menuItem: 'Run test' connectTo: self selector: #runTest.
	  GTK.GtkMenuItem menuItem: 'Debug test' connectTo: self selector: #debugTest}
    ]

    createMenus [
        <category: 'user interface'>

        self addMenuItem: 'File' withSubmenu: self createFileMenus.
        self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
	self addMenuItem: 'Run' withSubmenu: self createRunMenus.
        self addMenuItem: 'Smalltalk' withSubmenu: self createSmalltalkMenus.
        self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
        self addMenuItem: 'Help' withSubmenu: self createHelpMenus
    ]


    createToolbar [
	<category: 'user interface'>

	super createToolbar.
	self
	    appendSeparator;
            appendToolItem: ((GTK.GtkToolButton new: (GTK.GtkImage newFromFile: (GtkLauncher / 'Icons/go-run.png') file displayString) label: 'Run test')
                                connectSignal: 'clicked' to: self selector: #runTest userData: nil;
                                setTooltipText: 'Run test';
                                yourself)
    ]

    buildNamespaceAndClassWidget [
	<category: 'user interface'>

	^ (GTK.GtkHPaned new)
	    pack1: self buildNamespaceWidget resize: true shrink: false;
	    pack2: self buildClassWidget resize: true shrink: false;
	    yourself
    ]

    buildNamespaceAndClassAndMethodWidget [
	<category: 'user interface'>

	^ (GTK.GtkHPaned new)
	    pack1: self buildNamespaceAndClassWidget resize: true shrink: false;
	    pack2: self buildMethodWidget resize: true shrink: false;
	    yourself
    ]

    buildMiniBrowser [
	<category: 'user interface'>

	^ (GTK.GtkVPaned new)
	    pack1: self buildNamespaceAndClassAndMethodWidget resize: true shrink: false;
	    pack2: self buildSourceCodeWidget resize: true shrink: false;
	    yourself
    ]

    buildResultWidget [
	<category: 'user interface'>

	^ GTK.GtkNotebook new
	    appendPage: self buildSuccesfullWidget tabLabel: (GTK.GtkLabel new: 'Successful Tests');
	    appendPage: self buildFailedWidget tabLabel: (GTK.GtkLabel new: 'Failed Tests');
	    appendPage: self buildErrorWidget tabLabel: (GTK.GtkLabel new: 'Errors Tests');
	    yourself
    ]

    buildCentralWidget [
        <category: 'intialize-release'>

	^ (GTK.GtkVPaned new)
	    pack1: self buildMiniBrowser resize: true shrink: false;
	    pack2: self buildResultWidget resize: true shrink: false;
	    yourself
    ]

    initialize [
        <category: 'initialization'>

        super initialize.
	state := NamespaceState on: self with: Smalltalk
    ]

    postInitialize [
        <category: 'initialization'>

	super postInitialize.
	sourceCodeWidget postInitialize
    ]

    windowTitle [
	^ 'SUnit'
    ]

    aboutTitle [
	^ 'About SUnit'
    ]

    buildNamespaceWidget [
	<category: 'user interface'>

	namespaceWidget := GtkCategorizedNamespaceWidget showAll 
				whenSelectionChangedSend: #onNamespaceChanged to: self;
				yourself.
	^ namespaceWidget mainWidget
    ]

    buildClassWidget [
	<category: 'user interface'>

	classWidget := GtkClassSUnitWidget showAll 
				selectionMode: GTK.Gtk gtkSelectionMultiple;
				whenSelectionChangedSend: #onClassChanged to: self;
				yourself.
	^ classWidget mainWidget
    ]

    buildMethodWidget [
	<category: 'user interface'>

	methodWidget := GtkMethodSUnitWidget showAll
				whenSelectionChangedSend: #onMethodChanged to: self;
                                yourself.
        ^ methodWidget mainWidget
    ]

    buildSourceCodeWidget [
        <category: 'user interface'>

        sourceCodeWidget := GtkSourceCodeWidget showAll.
	sourceCodeWidget parentWindow: window.
	sourceCodeWidget browser: self.
        ^ sourceCodeWidget mainWidget
    ]

    buildSuccesfullWidget [
	<category: 'user interface'>

	successfullWidget := GtkSUnitResult new
				initialize;
				yourself.

	^ successfullWidget mainWidget
    ]

    buildFailedWidget [
	<category: 'user interface'>

	failedWidget := GtkSUnitResult new
				initialize;
				yourself.

	^ failedWidget mainWidget
    ]

    buildErrorWidget  [
	<category: 'user interface'>

	errorWidget := GtkSUnitResult new
				initialize;
				yourself.

	^ errorWidget mainWidget
    ]

    onNamespaceChanged [
	<category: 'namespace events'>

	self checkCodeWidgetAndUpdate: [
            namespaceWidget hasSelectedNamespace ifFalse: [ ^ self ].
	    self selectANamespace: namespaceWidget selectedNamespace ]
    ]

    selectANamespace: aNamespace [
	<category: 'browser methods'>

	(namespaceWidget hasSelectedNamespace and: [aNamespace = namespaceWidget selectedNamespace]) ifFalse: [
            namespaceWidget selectANamespace: aNamespace ].
        namespace := aNamespace.
	aNamespace isNil ifTrue: [ ^self ].
        classWidget namespace: aNamespace category: ''.
	state := NamespaceState on: self with: aNamespace
    ]

    onClassChanged [
	<category: 'class events'>

	self checkCodeWidgetAndUpdate: [
            classWidget hasSelectedClass ifFalse: [ ^ self ].
	    self selectAClass: classWidget selectedClass ]
    ]

    selectAClass: aClass [
	<category: 'browser methods'>

	(classWidget hasSelectedClass and: [aClass = classWidget selectedClass]) ifFalse: [
            classWidget selectAClass: aClass ].
        class := aClass.
	aClass isNil ifTrue: [ ^self ].
	methodWidget class: class withCategory: '*'.
	state := CategoryState on: self with: class -> '*'
    ]

    onMethodChanged [
	<category: 'method events'>

	self checkCodeWidgetAndUpdate: [
	    methodWidget hasSelectedMethod ifFalse: [^self].
	    self selectAnInstanceMethod: methodWidget selectedMethodSymbol ]
    ]

    selectAnInstanceMethod: aSymbol [
	<category: 'browser methods'>

	(methodWidget hasSelectedMethod and: [aSymbol = methodWidget selectedMethodSymbol]) ifFalse: [
            methodWidget selectAMethod: aSymbol asString ].
	sourceCodeWidget source: (BrowserMethodSource on: methodWidget selectedMethod).
	state := MethodState on: self with: methodWidget selectedMethod
    ]

    state [
	<category: 'browser methods'>

        ^state
    ]

    classOrMeta [
	<category: 'browser methods'>

	^class
    ]

    loadTest: aPackage [
	<category: 'private'>
	<comment: 'I load the unit tests for one package'>

	| test files |

	aPackage ifNil: [^self].

	test := aPackage test.
	test ifNil: [^self].

	test fileIn.
    ]

    loadTests [
        <category: 'run events'>
	<comment: 'I load the unit tests for the loaded packages'>

	Smalltalk Features do: [:each | |package|
		package := PackageLoader packageAt: each ifAbsent: [nil].
		self loadTest: package.
	]
    ]

    runTest [
	<category: 'run events'>

	| suite results name |
	classWidget hasSelectedClass ifFalse: [ ^ self ].
	suite := TestSuite named: classWidget allClassNames.
	classWidget selectedClasses do: [ :elem |
	    elem selectors do: [ :each |
		(each matchRegex: 'test' from: 1 to: 4)
		    ifTrue: [ suite addTest: (elem selector: each) ] ] ].
	suite logPolicy: TestBacktraceLog new.
	results := suite run.

	successfullWidget results: results passed.
	failedWidget results: results failures.
	errorWidget results: results errors.

	results failures do: [ :each | each "logPolicy logStatus inspect" printNl ].
    ]

    debugTest [
	<category: 'run events'>

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	classWidget selectedClasses do: [ :elem | | test |
	    test := elem new.
	    elem selectors do: [ :each |
		(each matchRegex: 'test' from: 1 to: 4)
		    ifTrue: [ test setTestSelector: each. test debug ] ] ].
    ]

    compileError: aString line: line [
        <category: 'method events'>

        sourceCodeWidget compileError: aString line: line
    ]

    focusedWidget [
	<category: 'events'>

	^sourceCodeWidget focusedWidget
    ]

    acceptIt [
        <category: 'smalltalk events'>

        AcceptItCommand executeOn: self
    ]
    
    cancel [
        <category: 'edit events'>

        self onFocusPerform: #cancel
    ]

    undo [
        <category: 'edit events'>

        self onFocusPerform: #undo
    ]

    redo [
        <category: 'edit events'>

        self onFocusPerform: #redo
    ]

    cut [
        <category: 'edit events'>

        self onFocusPerform: #cut
    ]

    copy [
        <category: 'edit events'>

        self onFocusPerform: #copy
    ]

    paste [
        <category: 'edit events'>

        self onFocusPerform: #paste
    ]

    selectAll [
        <category: 'edit events'>

        self onFocusPerform: #selectAll
    ]

    close [
        <category: 'file events'>

        self saveCodeOr: [ super close ]
    ]

    clearUndo [
        <category: 'source code'>

	sourceCodeWidget clearUndo
    ]

    hasChanged [
        <category: 'testing'>

        ^ sourceCodeWidget hasChanged
    ]

    sourceCode [
        <category: 'accessing'>

        ^ sourceCodeWidget sourceCode
    ]

    codeSaved [
	<category: 'code saved'>

	sourceCodeWidget codeSaved
    ]

    targetObject [
        <category: 'smalltalk event'>

        ^self state classOrMeta
    ]

    doIt: object [
        <category: 'smalltalk event'>

        sourceCodeWidget doIt: object
    ]

    debugIt: object [
        <category: 'smalltalk event'>

        sourceCodeWidget debugIt: object
    ]

    inspectIt: object [
        <category: 'smalltalk event'>

        sourceCodeWidget inspectIt: object
    ]

    printIt: object [
        <category: 'smalltalk event'>

        sourceCodeWidget printIt: object
    ]

    doIt [
        <category: 'smalltalk event'>

        DoItCommand executeOn: self
    ]

    debugIt [
        <category: 'smalltalk event'>

        DebugItCommand executeOn: self
    ]

    inspectIt [
        <category: 'smalltalk event'>

        InspectItCommand executeOn: self
    ]

    printIt [
        <category: 'smalltalk event'>

        PrintItCommand executeOn: self
    ]

    hasChanged [
	<category: 'testing'>

	^ sourceCodeWidget hasChanged
    ]

    cancel [
        <category: 'edit events'>

        self onFocusPerform: #cancel
    ]

    undo [
        <category: 'edit events'>

        self onFocusPerform: #undo
    ]

    redo [
        <category: 'edit events'>

        self onFocusPerform: #redo
    ]

    cut [
        <category: 'edit events'>

        self onFocusPerform: #cut
    ]

    copy [
        <category: 'edit events'>

        self onFocusPerform: #copy
    ]

    paste [
        <category: 'edit events'>

        self onFocusPerform: #paste
    ]

    selectAll [
        <category: 'edit events'>

        self onFocusPerform: #selectAll
    ]

    find [
        <category: 'edit events'>

        self onFocusPerform: #showFind
    ]

    replace [
        <category: 'edit events'>

        self onFocusPerform: #showReplace
    ]

    sourceCodeWidgetHasFocus [
        <category: 'focus'>

        ^ sourceCodeWidget hasFocus
    ]

    selectedText [
        <category: 'smalltalk events'>

        ^sourceCodeWidget selectedText
    ]

    hasSelection [
        <category: 'smalltalk events'>

        ^sourceCodeWidget hasSelection
    ]

]

PK
     �Mh@	+ѳ      GtkAnnouncer.stUT	 eqXO�XOux �  �  Announcer subclass: GtkAnnouncer [
    GtkAnnouncer class [ | current | ]

    GtkAnnouncer class >> current [
	<category: 'accessing'>

	^ current ifNil: [ current := super new ]
    ]

    GtkAnnouncer class >> new [
	<category: 'instance creation'>

	self shouldNotImplement
    ]
]
PK
     �Mh@����9  9    GtkClassSUnitWidget.stUT	 eqXO�XOux �  �  GtkCategorizedClassWidget subclass: GtkClassSUnitWidget [

    addToModel: aClass [

        (aClass superclass environment == self namespace and: [ (aClass superclass category = self category or: [ self category isEmpty ]) and: [ aClass superclass ~~ Smalltalk.TestCase ] ]) 
                    ifFalse: [ model append: aClass class ]
                    ifTrue: [ model append: aClass class parent: aClass superclass class ]
    ]

    root [
	<category: 'accessing'>

        ^ Smalltalk.TestCase
    ]

    selectionMode [
        <category: 'accessing'>

        ^ GTK.Gtk gtkSelectionMultiple
    ]

    allClassNames [
        <category: 'accessing'>

	| classes names |
	classes := self selectedClasses.
	names := classes collect: [ :each | each name asString ].
	^ names fold: [ :a :b | a, ', ', b ]
    ]

    hasSelectedClass [
        <category: 'testing'>

        ^ (classesTree treeView getSelection getSelectedRows: nil) ~= nil
    ]

    selectedClass [
        <category: 'accessing'>

	^ self selectedClasses first
    ]

    selectedClasses [
        <category: 'accessing'>

	self hasSelectedClass ifFalse: [ self error: 'Nothing is selected' ].
	^ classesTree treeView selections collect: [:each| each asClass]
    ]

    recategorizedEvent: anEvent [
        <category: 'model event'>

        (anEvent item inheritsFrom: TestCase) ifFalse: [ ^ self ].
        super recategorizedEvent: anEvent
    ]

    addEvent: anEvent [
        <category: 'model event'>

        (anEvent item inheritsFrom: TestCase) ifFalse: [ ^ self ].
        super addEvent: anEvent
    ]
]

PK
     �Mh@�%�.  .    ClassFinder.stUT	 eqXO�XOux �  �  AbstractFinder subclass: ClassFinder [
    | class |

    ClassFinder class >> on: aClass [
	<category: 'instance creation'>

	^ (self new)
	    class: aClass;
	    yourself
    ]

    class: aClass [
	<category: 'accessing'>

	class := aClass
    ]

    displayString [
	<category: 'printing'>

	^ class displayString
    ]

    element [
	<category: 'accessing'>

	^ class
    ]

    updateBrowser: aGtkClassBrowserWidget [
	<category: 'events'>

	aGtkClassBrowserWidget 
	    selectANamespace: class environment;
	    selectAClass: class asClass
    ]
]

PK
     �Mh@nҧ~�  �    HistoryStack.stUT	 eqXO�XOux �  �  Object subclass: HistoryStack [

    | previousStack nextStack browser |

    initialize: aGtkClassBrowserWidget [
	<category: 'initialization'>

	previousStack := OrderedCollection new.
	nextStack := OrderedCollection new.
	browser := aGtkClassBrowserWidget.
    ]

    clear [
	<category: 'stack'>

        previousStack empty.
        nextStack empty.
    ]

    current [
	<category: 'stack'>
        ^previousStack isEmpty ifTrue: [ nil ] ifFalse: [ previousStack first ]
    ]

    push: aClass [
	<category: 'stack'>

	(aClass isNil or: [self current == aClass]) ifTrue: [ ^ self ].
	nextStack empty.
	previousStack addFirst: aClass
    ]

    size [
        <category: 'iteration'>

        ^nextStack size + previousStack size
    ]

    do: aBlock [
        <category: 'iteration'>

        nextStack reverseDo: aBlock.
        previousStack do: aBlock.
    ]

    selectedIndex [
	<category: 'undo-redo'>

        ^nextStack size + 1
    ]

    selectItem: anInteger [
	<category: 'undo-redo'>

        | n |
        (anInteger between: 1 and: self size)
            ifFalse: [self error: 'index out of range'].

        [ self selectedIndex < anInteger ] whileTrue: [
            nextStack addFirst: previousStack removeFirst ].
        [ self selectedIndex > anInteger ] whileTrue: [
            previousStack addFirst: nextStack removeFirst ].

        browser selectANamespace: self current environment.
        browser selectAClass: self current
    ]

    previous [
	<category: 'undo-redo'>

	previousStack size <= 1 ifTrue: [ ^ self ].

	nextStack addFirst: previousStack removeFirst.
        browser selectANamespace: self current environment.
        browser selectAClass: self current
    ]

    next [
        <category: 'undo-redo'>

	nextStack isEmpty ifTrue: [ ^ self ].

	previousStack addFirst: nextStack removeFirst.
        browser selectANamespace: self current environment.
        browser selectAClass: self current
    ]
]

PK
     �Mh@X���`  �`    GtkLauncher.stUT	 eqXO�XOux �  �  GtkVisualGSTTool subclass: GtkLauncher [
    GtkLauncher class [ | uniqueInstance | ]

    | leftSidebar rightSidebar topSidebar packageBuilderWidget implementorResultWidget senderResultWidget senderWidget implementorWidget historyWidget browsers outputs saved imageName transcriptWidget windowsMenu systemChangeNotifier |

    GtkLauncher class >> uniqueInstance [
	<category: 'public'>

	uniqueInstance ifNil: [ self createInstance ].
        ^ uniqueInstance
    ]

    GtkLauncher class >> / path [
        <category: 'files'>

        ^ (PackageLoader packageAt: 'VisualGST') / path
    ]

    GtkLauncher class >> uniqueInstance: anObject [
        <category: 'private'>

	(uniqueInstance notNil and: [ anObject notNil ])
	    ifTrue: [ self error: 'cannot override uniqueInstance' ].
        uniqueInstance := anObject
    ]

    GtkLauncher class >> createInstance [
        <category: 'private'>

        ^ (uniqueInstance :=  self basicNew)
            initialize;
            showAll;
            postInitialize;
	    resize: 1024@600;
            yourself
    ]

    GtkLauncher class >> instanceCreationErrorString [
        <category: 'private'>

        ^ 'This is a singleton implementation, so you are not allowed to create instances yourself. Use #uniqueInstance to access the instance.'
    ]

    GtkLauncher class >> new [
        <category: 'instance creation'>

        ^ self error: self instanceCreationErrorString
    ]

    GtkLauncher class >> exit [
	<category: 'exit'>

	GTK.Gtk mainQuit.
	ObjectMemory quit	
    ]
 
    GtkLauncher class >> open [
	<category: 'user interface'>

        self uniqueInstance
    ]

    GtkLauncher class >> displayError: title message: error [
        <category: 'error'>

        | dialog |
        dialog := GTK.GtkMessageDialog
                                new: nil
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Error'
                                tip: error.

        dialog
            addButton: 'Ok' responseId: 1;
            showModalOnAnswer: [ :dlg :res | dlg destroy ].
    ]

    GtkLauncher class >> displayError: error [
        ^self displayError: 'Error' message: error
    ]

    GtkLauncher class >> compileError: aString line: anInteger [
	self uniqueInstance compileError: aString line: anInteger
    ]

    accelPath [
	<category: 'accelerator path'>

	^ '<VisualGST>'
    ]

    classBrowser [
	<category: 'tools events'>

	| widget |
	browsers addWidget: (widget := self buildClassBrowserWidget) labeled: 'Browser'.
        browsers showLastPage.
	widget postInitialize.
	^ widget
    ]

    newWorkspace [
	<category: 'tools events'>

        ^self newWorkspaceLabeled: 'Workspace'
    ]

    newWorkspaceLabeled: aString [
	<category: 'tools events'>

	| widget |
	widget := self buildWorkspaceWidget showAll.
	widget postInitialize.
	outputs addWidget: widget labeled: aString.
        outputs showLastPage.
        ^widget
    ]

    onDelete: aGtkWidget event: aGdkEvent [
	<category: 'window events'>

	self quit.
	^ true 
    ]

    quit [
	<category: 'file events'>

        | dialog |
        dialog := GTK.GtkMessageDialog
                                new: window
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Save the image before exiting?'
				tip: 'The image hosts all the code changes that you made %<since the last save|since starting VisualGST>1.  Unless you exported these changes, not saving the image will lose them.' % {saved}.

        dialog
            addButton: 'Exit without saving' responseId: 0;
            addButton: 'Cancel' responseId: 2;
            addButton: 'Save image' responseId: 1;
            setDefaultResponse: 2;
            showModalOnAnswer: [ :dlg :res |
                res = 0 ifTrue: [ self class exit ].
                res = 1 ifTrue: [ self saveImageAndQuit ].
                dlg destroy ].
    ]

    open [
	<category: 'file events'>

	| file string |
	(GTK.GtkFileChooserDialog load: 'Load Smalltalk source' parent: window)
	    showModalOnAnswer: [ :dlg :res |
		res = GTK.Gtk gtkResponseAccept 
				ifTrue: [ file := File name: dlg getFilename.
                                          FileStream open: dlg getFilename mode: FileStream read.
					  (self newWorkspaceLabeled: file stripPath) text: file contents ].
		dlg destroy ]
    ]

    save [
	<category: 'file events'>
    ]

    saveAs [
	<category: 'file events'>

	| file |
        (GTK.GtkFileChooserDialog save: 'Save Smalltalk source as...' parent: window)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept 
				ifTrue: [ file := FileStream open: dlg getFilename mode: FileStream write.
					  file nextPutAll: outputs currentWidget text ].
		dlg destroy ]
    ]

    print [
	<category: 'file events'>
    ]

    saveImageAndQuit [
        <category: 'file events'>

        "ObjectMemory>>#snapshot breaks hard links due to
         http://bugzilla.kernel.org/show_bug.cgi?id=9138, so we have to
         check the permission of the directory rather than the file."
        imageName ifNil: [ ^ self saveImageAs ].
        imageName asFile parent isWriteable ifFalse: [ self saveImageAsAndQuit ].
        self saveImage: [ ObjectMemory snapshot: imageName. self class exit ]
    ]

    saveImage [
        <category: 'file events'>

	"ObjectMemory>>#snapshot breaks hard links due to
	 http://bugzilla.kernel.org/show_bug.cgi?id=9138, so we have to
	 check the permission of the directory rather than the file."
	imageName asFile parent isWriteable ifFalse: [ ^ self saveImageAs ].
        self saveImage: [ ObjectMemory snapshot: imageName ]
    ]

    saveImageAs [
	<category: 'file events'>

	(GTK.GtkFileChooserDialog save: 'Save image as...' parent: window)
	    showModalOnAnswer: [ :dlg :res |
		imageName := dlg getFilename.
		dlg destroy.
		res = GTK.Gtk gtkResponseAccept ifTrue: [ self saveImage: [ ObjectMemory snapshot: imageName ] ] ]
    ]

    saveImageAsAndQuit [
        <category: 'file events'>

        (GTK.GtkFileChooserDialog save: 'Save image as...' parent: window)
            showModalOnAnswer: [ :dlg :res |
                imageName := dlg getFilename.
                dlg destroy.
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self saveImage: [ ObjectMemory snapshot: imageName ]. self class exit ] ]
    ]

    saveImage: aBlock [
	| oldMessage oldNotifier oldCatIcon oldNameIcon |
	oldNotifier := self systemChangeNotifier.
	oldMessage := Transcript message.

	oldCatIcon := ClassCategory icon.
	ClassCategory icon: nil.
	oldNameIcon := AbstractNamespace icon.
	AbstractNamespace icon: nil.

	Transcript message: stdout->#nextPutAllFlush:.
	SystemChangeNotifier root remove: oldNotifier.
	systemChangeNotifier := nil.
	self class uniqueInstance: nil.

	(saved := aBlock value not) ifTrue: [
            self class uniqueInstance: self.
	    ClassCategory icon: oldCatIcon.
	    AbstractNamespace icon: oldNameIcon.
	    systemChangeNotifier := oldNotifier.
	    SystemChangeNotifier root add: oldNotifier.
	    Transcript message: oldMessage ]
    ]

    systemChangeNotifier [
	<category: 'notifications'>

	^ systemChangeNotifier
    ]

    clearGlobalState [
	<category: 'initialization cleanup'>

    ]

    initialize [
	<category: 'initialization'>

	saved := false.
	imageName := File image asString.
        systemChangeNotifier := SystemChangeNotifier new.
        SystemChangeNotifier root add: systemChangeNotifier.
	self clearGlobalState.
	super initialize.
	window maximize.
	window setIcon: (GTK.GdkPixbuf newFromFile: (self class / 'Icons/visualgst.png') file displayString error: nil).
	self subscribe
    ]

    subscribe [
	<category: 'initialization'>

	GtkAnnouncer current on: GtkNamespaceSelectionChanged do: [ :ann |
	    browsers updateWidget: browsers currentWidget withLabel: ann selectedNamespace name asString].
	GtkAnnouncer current on: GtkClassSelectionChanged do: [ :ann |
	    browsers updateWidget: browsers currentWidget withLabel: ann selectedClass printString]
    ]

    windowTitle [
        <category: 'widget'>

        ^ 'VisualGST'
    ]

    browserPostInitialize [
	<category: 'initialization'>

        browsers grabFocus.
        browsers currentWidget postInitialize.
        browsers currentWidget selectANamespace: Smalltalk.
        browsers currentWidget selectAClass: Object.
	outputs hideAll
    ]

    postInitialize [
	<category: 'initialization'>

	super postInitialize.
        self browserPostInitialize.
	1 to: 2 do: [ :i | (outputs widgetAt: i) postInitialize ].
	leftSidebar mainWidget getParent setPosition: 270.
	topSidebar mainWidget getParent setPosition: 100.
	leftSidebar postInitialize.
	topSidebar postInitialize.
	rightSidebar postInitialize.
	window
	    connectSignal: 'key-press-event' to: self selector:  #'keyPressedOn:keyEvent:'
    ]

    buildNotebookWorkspaceWidget [
	<category: 'user interface'>

	outputs := GtkNotebookWidget new
				initialize;
				parentWindow: window;
				showAll;
				yourself.
	^ outputs
	    addPermanentWidget: (transcriptWidget := self buildTranscriptWidget) labeled: 'Transcript';
	    addWidget: self buildWorkspaceWidget labeled: 'Workspace';
	    yourself
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

	^ self buildBrowserAndWorkspaceWidget
    ]

    buildImplementorPaned [
       <category: 'user interface'>

	leftSidebar := GtkHSidebarWidget new
			    initialize;
			    addAll: {self buildImplementorView -> 'Implementor'. self buildSenderView -> 'Sender'. self buildHistoryView -> 'History'};
			    yourself.
	self registerLeftPaneEvents.
	^ leftSidebar mainWidget
    ]

    buildPackageBuilderView [
	<category: 'user interface'>

	packageBuilderWidget := GtkPackageBuilderWidget new
						    initialize;
						    yourself.
	^ packageBuilderWidget mainWidget
    ]

    buildRightSidebarPaned [
       <category: 'user interface'>

        rightSidebar := GtkHSidebarWidget new
                            initialize;
                            addAll: {self buildPackageBuilderView -> 'Package Builder'};
                            yourself.
        ^ rightSidebar mainWidget
    ]

    buildBrowserAndWorkspaceWidget [
        <category: 'intialize-release'>

        ^ GTK.GtkVPaned addAll: {
		    GTK.GtkHPaned addAll: {self buildImplementorPaned. self buildBottomPanedAndClassBrowser. self buildRightSidebarPaned}. 
		    self buildNotebookWorkspaceWidget mainWidget}
    ]

    buildImplementorView [
       <category: 'user interface'>

        implementorWidget := self buildImageView
			    whenSelectionChangedSend: #implementorSelected to: self;
			    yourself.
        ^ implementorWidget mainWidget
    ]

    buildSenderView [
       <category: 'user interface'>

        senderWidget := self buildImageView
			    whenSelectionChangedSend: #senderSelected to: self;
			    yourself.
        ^ senderWidget mainWidget
    ]

    buildImageView [
       <category: 'user interface'>

        ^ GtkImageWidget new
			initialize;
                        yourself
    ]

    buildHistoryView [
       <category: 'user interface'>

        historyWidget := GtkHistoryWidget new
                                    browser: self;
                                    yourself.
        ^ historyWidget mainWidget
    ]

    buildImplementorResultList [
        <category: 'user interface'>

        ^ implementorResultWidget := GtkImplementorResultsWidget new
					    initialize;
					    whenSelectionChangedSend: #resultImplementorSelected to: self;
					    yourself
    ]

    buildSenderResultList [
        <category: 'user interface'>

        ^ senderResultWidget := GtkSenderResultsWidget new
					    initialize;
					    whenSelectionChangedSend: #resultSenderSelected to: self;
					    yourself
    ]

    buildTopSidebar [
        <category: 'user interface'>

        topSidebar := GtkHSidebarWidget new
                            initialize;
                            addAll: {self buildImplementorResultList mainWidget -> ''. self buildSenderResultList mainWidget -> ''};
			    hideTabs;
                            yourself.
        ^ topSidebar mainWidget
    ]

    buildBottomPanedAndClassBrowser [
        <category: 'user interface'>

	^ GTK.GtkVPaned addAll: {self buildTopSidebar. self buildClassBrowserTabbedWidget mainWidget}
    ]

    buildClassBrowserTabbedWidget [
	<category: 'user interface'>

	^ (browsers := GtkNotebookWidget parentWindow: window)
				    showAll;
                                    whenSelectionChangedSend: #historyChanged to: self;
				    addWidget: self buildClassBrowserWidget labeled: 'Browser';
				    yourself
    ]

    buildClassBrowserWidget [
	<category: 'user interface'>

	^ (GtkClassBrowserWidget parentWindow: window)
             launcher: self;
             yourself
    ]

    buildTranscriptWidget [
	<category: 'user interface'>

	^ GtkTranscriptWidget parentWindow: window
    ]

    buildWorkspaceWidget [
	<category: 'user interface'>

	^ GtkWorkspaceWidget parentWindow: window
    ]

    registerLeftPaneEvents [
	<category: 'user interface'>

	leftSidebar 
	    whenWidgetIsVisible: implementorWidget mainWidget send: #switchToImplementor to: self;
	    whenWidgetIsVisible: senderWidget mainWidget send: #switchToSender to: self;
	    whenWidgetIsVisible: historyWidget mainWidget send: #switchToHistory to: self.
    ]

    createEditMenus [
	<category: 'user interface'>

	^ super createEditMenus, {
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Clear Transcript' connectTo: self selector: #clearTranscriptWidget}
    ]

    createNamespaceMenus [
        <category: 'user interface'>

	^ NamespaceMenus browserBuildOn: self
    ]

    createClassMenus [
        <category: 'user interface'>

	^ ClassMenus browserBuildOn: self
    ]

    createCategoryMenus [
        <category: 'user interface'>

	^ CategoryMenus browserBuildOn: self
    ]

    createMethodMenus [
        <category: 'user interface'>

	^ MethodMenus browserBuildOn: self
    ]

    createFileMenus [
	<category: 'user interface'>

        self accelGroup append: 
	    {{'<Control>O'. '<GtkLauncher>/File/Open'}.
	    {'<Control><Shift>S'. '<GtkLauncher>/File/SaveAs'}.
	    {'<Control>Q'. '<GtkLauncher>/File/Quit'}}.

	^{GTK.GtkMenuItem menuItem: 'New workspace' connectTo: self selector: #newWorkspace.
            GTK.GtkMenuItem new.
	    GTK.GtkMenuItem menuItem: 'Open' accelPath: '<GtkLauncher>/File/Open' connectTo: self selector: #open.
            GTK.GtkMenuItem menuItem: 'Save' connectTo: self selector: #save.
            GTK.GtkMenuItem menuItem: 'Save as...' accelPath: '<GtkLauncher>/File/SaveAs' connectTo: self selector: #saveAs.
            GTK.GtkMenuItem new}, super createFileMenus
    ]

    createHistoryMenus [
	<category: 'user interface'>

	^ HistoryMenus browserBuildOn: self
    ]

    createTabsMenus [
	<category: 'user interface'>

	^ TabsMenus browserBuildOn: self
    ]

    createToolbar [
	<category: 'user interface'>

	self
	    appendToolItem: ((GTK.GtkToolButton newFromStock: 'gtk-new')
				connectSignal: 'clicked' to: self selector: #newWorkspace;
				setTooltipText: 'Create a new workspace';
				yourself).
        super createToolbar
    ]

    createMenus [
	<category: 'user interface'>

	self createMainMenu: {#('File' #createFileMenus).
	    #('Edit' #createEditMenus).
	    #('History' #createHistoryMenus).
	    #('Namespace' #createNamespaceMenus).
	    #('Class' #createClassMenus).
	    #('Category' #createCategoryMenus).
	    #('Method' #createMethodMenus).
	    #('Smalltalk' #createSmalltalkMenus).
	    #('Tools' #createToolsMenus).
	    #('Tabs' #createTabsMenus).
	    #('Help' #createHelpMenus)}
    ]

    createToolsMenus [
	<category: 'user interface'>

        self accelGroup append: {{'<Control>B'. '<GtkLauncher>/Tools/TabbedClassBrowser'}}.

	^{GTK.GtkMenuItem menuItem: 'Browser' accelPath: '<GtkLauncher>/Tools/TabbedClassBrowser' connectTo: self selector: #newTabbedBrowser},
            super createToolsMenus.
    ]

    newTabbedBrowser [
	<category: 'tools events'>

	OpenTabbedBrowserCommand executeOn: self
    ]

    launcher [
	<category: 'accessing'>

	^ self
    ]

    cancel [
	<category: 'edit events'>

	self onFocusPerform: #cancel
    ]

    undo [
	<category: 'edit events'>

	self onFocusPerform: #undo
    ]

    redo [
	<category: 'edit events'>

	self onFocusPerform: #redo
    ]

    cut [
	<category: 'edit events'>

	self onFocusPerform: #cut
    ]

    copy [
	<category: 'edit events'>

	self onFocusPerform: #copy
    ]

    paste [
	<category: 'edit events'>

	self onFocusPerform: #paste
    ]

    selectAll [
	<category: 'edit events'>

	self onFocusPerform: #selectAll
    ]

    find [
	<category: 'edit events'>

	self onFocusPerform: #showFind
    ]

    replace [
	<category: 'edit events'>

	self onFocusPerform: #showReplace
    ]

    clearTranscriptWidget [
	<category: 'edit events'>

	transcriptWidget clear
    ]

    focusedWidget [
	<category: 'focus'>

	^browsers focusedWidget ifNil: [ outputs focusedWidget ]
    ]

    browserHasFocus [
	<category: 'testing'>

	^ browsers hasFocus
    ]

    sourceCodeWidgetHasFocus [
	<category: 'focus'>

	^ browsers currentWidget sourceCodeWidgetHasFocus
    ]

    state [
	<category: 'focus'>

	browsers currentWidget ifNil: [ ^ BrowserState new ].
	^ browsers currentWidget state
    ]

    selectedText [
	<category: 'smalltalk events'>

	^ self onFocusPerform: #selectedText
    ]

    selectedMethodSymbol [
        <category: 'text editing'>

        ^ self onFocusPerform: #selectedMethodSymbol
    ]

    hasSelection [
	<category: 'smalltalk events'>

        | widget |
	widget := self focusedWidget.
	^ widget notNil and: [widget hasSelection]
    ]

    targetObject [
	<category: 'smalltalk events'>

	^ self onFocusPerform: #targetObject
    ]

    doIt: anObject [
	<category: 'smalltalk events'>

	self onFocusPerform: #doIt: with: anObject
    ]

    printIt: anObject [
	<category: 'smalltalk events'>

	self onFocusPerform: #printIt: with: anObject
    ]

    inspectIt: anObject [
	<category: 'smalltalk events'>

	self onFocusPerform: #inspectIt: with: anObject
    ]

    debugIt: anObject [
	<category: 'smalltalk events'>

	self onFocusPerform: #debugIt: with: anObject
    ]

    acceptIt [
	<category: 'smalltalk events'>

	browsers currentWidget acceptIt
    ]

    codeSaved [
        <category: 'code saved'>

        browsers currentWidget codeSaved
    ]

    clearUndo [
        <category: 'code saved'>

        browsers currentWidget clearUndo
    ]

    sourceCode [
        <category: 'code saved'>

        ^ browsers currentWidget sourceCode
    ]

    showImplementorOn: aSymbol [
        <category: 'image events'>

	(self showHideWithSelectorOn: implementorWidget at: 1)
	    ifTrue: [ self imageSelectorForImplementor: aSymbol ]
    ]

    showHideImplementor [
        <category: 'image events'>

	self showHideOn: implementorWidget at: 1
    ]

    showSenderOn: aSymbol [
        <category: 'image events'>

	(self showHideWithSelectorOn: senderWidget at: 2)
	    ifTrue: [ self imageSelectorForSender: aSymbol ]
    ]

    showHideSender [
        <category: 'image events'>

	self showHideOn: senderWidget at: 2
    ]

    hideSidebars [

        leftSidebar hide.
        topSidebar hide.
        rightSidebar hide.
    ]

    showHideOn: aGtkWidget at: anIndex [

        | isVisible |
        isVisible := aGtkWidget isVisible.
	leftSidebar mainWidget getParent getPosition = 0 ifTrue: [ isVisible := false. leftSidebar mainWidget getParent setPosition: 270 ].
	topSidebar mainWidget getParent getPosition = 0 ifTrue: [ isVisible := false. topSidebar mainWidget getParent setPosition: 100 ].
	self hideSidebars.
        isVisible
            ifFalse: [
                topSidebar show: anIndex.
                leftSidebar show: anIndex ]
    ]

    showHideWithSelectorOn: aGtkWidget at: anIndex [
        <category: 'image events'>

        | isVisible |
        isVisible := aGtkWidget isVisible.
	self hideSidebars.
        isVisible ifTrue: [ ^ false ].
        leftSidebar show: anIndex.
        topSidebar show: anIndex.
	^ true
    ]

    showHidePackageBuilder [
        <category: 'image events'>

        | isVisible |
        isVisible := packageBuilderWidget isVisible.
	self hideSidebars.
        isVisible
            ifFalse: [
                rightSidebar show: 1 ]
    ]

    showHideBottomPane [
	<category: 'image events'>

	outputs isVisible 
		ifTrue: [ outputs hideAll ]
		ifFalse: [ outputs showPane ]
    ]

    back [
	<category: 'history events'>

	browsers currentWidget back
    ]

    forward [
	<category: 'history events'>

	browsers currentWidget forward
    ]

    showHideHistory [
	<category: 'history events'>

	| isVisible |
        isVisible := historyWidget isVisible.
	leftSidebar hide.
	topSidebar hide.
	isVisible ifFalse: [ leftSidebar show: 3 ]
    ]

    historyChanged [
	<category: 'public'>

	self currentWidgetOfBrowser ifNotNil: [ :w |
	    historyWidget refresh: w historyStack ]
    ]

    previousTab [
	<category: 'tabs events'>

	browsers currentPage > 0 
		    ifTrue: [ browsers currentPage: browsers currentPage - 1 ]
		    ifFalse: [ browsers currentPage: browsers numberOfPages - 1 ] 
    ]

    nextTab [
	<category: 'tabs events'>

	browsers currentPage: (browsers currentPage + 1 \\ browsers numberOfPages)
    ]

    closeTab [

	self close
    ]

    close [
	<category: 'tabs events'>

	browsers numberOfPages > 1 
			    ifTrue: [ browsers currentWidget checkCodeWidgetAndUpdate: [ browsers closeCurrentPage ] ]
			    ifFalse: [ browsers closeCurrentPage ].
    ]

    currentWidgetOfBrowser [
	<category: 'browsers'>

	^ browsers currentWidget
    ]

    notebookHasFocus [
	<category: 'testing'>

	^ outputs hasFocus
    ]

    switchToImplementor [
        <category: 'pane events'>

	implementorWidget isVisible ifFalse: [ ^ self ].
	topSidebar show: 1
    ]       
    
    switchToSender [
        <category: 'pane events'>

	senderWidget isVisible ifFalse: [ ^ self ].
	topSidebar show: 2
    ]       
            
    switchToHistory [
        <category: 'pane events'>

	historyWidget isVisible ifFalse: [ ^ self ].
	topSidebar hideAll
    ]

    senderSelected [
        <category: 'pane events'>

        senderWidget hasSelection ifFalse: [ ^ self ].
        self findInMethod: (senderWidget matchSelector: senderWidget selection) values first element
    ]

    implementorSelected [
        <category: 'pane events'>

        implementorWidget hasSelection ifFalse: [ ^ self ].
        self imageSelectorForImplementor: implementorWidget selection
    ]

    senderSelected [
	<category: 'pane events'>

        senderWidget hasSelection ifFalse: [ ^ self ].
        self imageSelectorForSender: senderWidget selection
    ]

    imageSelectorForImplementor: aSymbol [
        <category: 'pane events'>

	implementorResultWidget appendImplementorResults: (implementorWidget matchSelector: aSymbol)
    ]

    imageSelectorForSender: aSymbol [
        <category: 'pane events'>

	senderResultWidget appendSenderResults: (senderWidget matchSelector: aSymbol)
    ]

    resultImplementorSelected [
        <category: 'pane events'>

	implementorResultWidget selectedResult: self currentWidgetOfBrowser
    ]

    resultSenderSelected [
        <category: 'pane events'>

        senderResultWidget selectedResult: self currentWidgetOfBrowser
    ]

    keyPressedOn: aGtkWidget keyEvent: aGdkEventKey [
        <category: 'key event'>

        | event |
        event := aGdkEventKey castTo: GTK.GdkEventKey type.

	event keyval value = 65473 ifTrue: [ self showHideBottomPane. ^ true ].
	(event state value bitAnd: GTK.Gdk gdkControlMask) = 0 ifTrue: [ ^ false ].
	(#(65417 65289 65056) includes: event keyval value) ifFalse: [ ^ false ].
	(event state value bitAnd: GTK.Gdk gdkShiftMask) = 0  
					    ifFalse: [ self previousTab ]
					    ifTrue: [ self nextTab ].
        ^ true
    ]

    selectAnInstanceMethod: aMethod [

	browsers currentWidget selectAnInstanceMethod: aMethod	
    ]

    selectAClassMethod: aMethod [

	browsers currentWidget selectAClassMethod: aMethod
    ]

    compileError: aString line: anInteger [
	browsers currentWidget compileError: aString line: anInteger
    ]
]

PK
     #\h@W$��7  �7    package.xmlUT	 �XO�XOux �  �  <package>
  <name>VisualGST</name>
  <namespace>VisualGST</namespace>
  <test>
    <namespace>VisualGST</namespace>
    <prereq>SUnit</prereq>
    <prereq>VisualGST</prereq>
    <sunit>
      VisualGST.AddNamespaceUndoCommandTest
      VisualGST.GtkMethodWidgetTest
      VisualGST.CompiledMethodTest
      VisualGST.ExtractLiteralsTest
      VisualGST.CategoryTest
      VisualGST.GtkScrollTreeWidgetTest
      VisualGST.Test
      VisualGST.MenuBuilderTest
      VisualGST.GtkAssistantTest
      VisualGST.GtkSimpleListWidgetTest
      VisualGST.EmptyTest
      VisualGST.AddClassUndoCommandTest
      VisualGST.GtkCategoryWidgetTest
      VisualGST.StateTest
      VisualGST.FinderTest
      VisualGST.PragmasTest
      VisualGST.GtkCategorizedNamespaceWidgetTest
      VisualGST.GtkCategorizedClassWidgetTest
      VisualGST.#Test
      VisualGST.GtkConcreteWidgetTest
    </sunit>
  
    <filein>Tests/AddNamespaceUndoCommandTest.st</filein>
    <filein>Tests/GtkMethodWidgetTest.st</filein>
    <filein>Tests/CompiledMethodTest.st</filein>
    <filein>Tests/ExtractLiteralsTest.st</filein>
    <filein>Tests/CategoryTest.st</filein>
    <filein>Tests/GtkScrollTreeWidgetTest.st</filein>
    <filein>Tests/MenuBuilderTest.st</filein>
    <filein>Tests/GtkAssistantTest.st</filein>
    <filein>Tests/GtkSimpleListWidgetTest.st</filein>
    <filein>Tests/EmptyTest.st</filein>
    <filein>Tests/AddClassUndoCommandTest.st</filein>
    <filein>Tests/GtkCategoryWidgetTest.st</filein>
    <filein>Tests/StateTest.st</filein>
    <filein>Tests/FinderTest.st</filein>
    <filein>Tests/PragmaTest.st</filein>
    <filein>Tests/GtkCategorizedNamespaceWidgetTest.st</filein>
    <filein>Tests/GtkCategorizedClassWidgetTest.st</filein>
    <filein>Tests/GtkConcreteWidgetTest.st</filein>
  </test>
  <provides>Browser</provides>
  <prereq>Announcements</prereq>
  <prereq>Cairo</prereq>
  <prereq>DebugTools</prereq>
  <prereq>GTK</prereq>
  <prereq>Parser</prereq>
  <prereq>SUnit</prereq>

  <filein>Extensions.st</filein>
  <filein>Notification/AbstractEvent.st</filein>
  <filein>Notification/AddedEvent.st</filein>
  <filein>Notification/CommentedEvent.st</filein>
  <filein>Notification/DoItEvent.st</filein>
  <filein>Notification/SystemEventManager.st</filein>
  <filein>Notification/EventMultiplexer.st</filein>
  <filein>Notification/EventDispatcher.st</filein>
  <filein>Notification/ModifiedEvent.st</filein>
  <filein>Notification/ModifiedClassDefinitionEvent.st</filein>
  <filein>Notification/RecategorizedEvent.st</filein>
  <filein>Notification/RemovedEvent.st</filein>
  <filein>Notification/RenamedEvent.st</filein>
  <filein>Notification/ReorganizedEvent.st</filein>
  <filein>Notification/SystemChangeNotifier.st</filein>
  <filein>GtkAnnouncer.st</filein>
  <filein>GtkNamespaceSelectionChanged.st</filein>
  <filein>GtkClassSelectionChanged.st</filein>
  <filein>Commands/Command.st</filein>
  <filein>Commands/SmalltalkMenus/DoItCommand.st</filein>
  <filein>Commands/SmalltalkMenus/DebugItCommand.st</filein>
  <filein>Commands/SmalltalkMenus/PrintItCommand.st</filein>
  <filein>Commands/SmalltalkMenus/InspectItCommand.st</filein>
  <filein>Commands/SmalltalkMenus/AcceptItCommand.st</filein>
  <filein>Commands/SmalltalkMenus/CancelCommand.st</filein>
  <filein>Commands/HistoryCommands/HistoryBackCommand.st</filein>
  <filein>Commands/HistoryCommands/HistoryDisplayCommand.st</filein>
  <filein>Commands/HistoryCommands/HistoryForwardCommand.st</filein>
  <filein>Commands/TabsMenus/CloseTabCommand.st</filein>
  <filein>Commands/TabsMenus/NextTabCommand.st</filein>
  <filein>Commands/TabsMenus/PreviousTabCommand.st</filein>
  <filein>Commands/NamespaceMenus/NamespaceCommand.st</filein>
  <filein>Commands/NamespaceMenus/InspectNamespaceCommand.st</filein>
  <filein>Commands/NamespaceMenus/FileoutNamespaceCommand.st</filein>
  <filein>Commands/NamespaceMenus/AddNamespaceCommand.st</filein>
  <filein>Commands/NamespaceMenus/DeleteNamespaceCommand.st</filein>
  <filein>Commands/NamespaceMenus/RenameNamespaceCommand.st</filein>
  <filein>Commands/ClassMenus/ClassCommand.st</filein>
  <filein>Commands/ClassMenus/InspectClassCommand.st</filein>
  <filein>Commands/ClassMenus/FileoutClassCommand.st</filein>
  <filein>Commands/ClassMenus/AddClassCommand.st</filein>
  <filein>Commands/ClassMenus/DeleteClassCommand.st</filein>
  <filein>Commands/ClassMenus/RenameClassCommand.st</filein>
  <filein>Commands/CategoryMenus/CategoryCommand.st</filein>
  <filein>Commands/CategoryMenus/FileoutCategoryCommand.st</filein>
  <filein>Commands/CategoryMenus/AddCategoryCommand.st</filein>
  <filein>Commands/CategoryMenus/RenameCategoryCommand.st</filein>
  <filein>Commands/MethodMenus/MethodCommand.st</filein>
  <filein>Commands/MethodMenus/FileoutMethodCommand.st</filein>
  <filein>Commands/MethodMenus/InspectMethodCommand.st</filein>
  <filein>Commands/MethodMenus/DeleteMethodCommand.st</filein>
  <filein>Commands/MethodMenus/DebugTestCommand.st</filein>
  <filein>Commands/ToolsMenus/OpenAssistantCommand.st</filein>
  <filein>Commands/ToolsMenus/OpenWebBrowserCommand.st</filein>
  <filein>Commands/EditMenus/CancelEditCommand.st</filein>
  <filein>Commands/EditMenus/UndoEditCommand.st</filein>
  <filein>Commands/EditMenus/RedoEditCommand.st</filein>
  <filein>Commands/EditMenus/CutEditCommand.st</filein>
  <filein>Commands/EditMenus/CopyEditCommand.st</filein>
  <filein>Commands/EditMenus/PasteEditCommand.st</filein>
  <filein>Commands/EditMenus/SelectAllEditCommand.st</filein>
  <filein>Commands/EditMenus/FindEditCommand.st</filein>
  <filein>Commands/EditMenus/ReplaceEditCommand.st</filein>
  <filein>Commands/DebugMenus/DebugCommand.st</filein>
  <filein>Commands/DebugMenus/ContinueDebugCommand.st</filein>
  <filein>Commands/DebugMenus/StepIntoDebugCommand.st</filein>
  <filein>Commands/DebugMenus/StepToDebugCommand.st</filein>
  <filein>Menus/MenuBuilder.st</filein>
  <filein>Menus/MenuSeparator.st</filein>
  <filein>Menus/ToolbarSeparator.st</filein>
  <filein>Menus/LauncherToolbar.st</filein>
  <filein>Menus/DebuggerToolbar.st</filein>
  <filein>Menus/NamespaceMenus.st</filein>
  <filein>Menus/ClassMenus.st</filein>
  <filein>Menus/CategoryMenus.st</filein>
  <filein>Menus/ContextMenus.st</filein>
  <filein>Menus/MethodMenus.st</filein>
  <filein>Menus/EditMenus.st</filein>
  <filein>Menus/SmalltalkMenus.st</filein>
  <filein>Menus/ToolsMenus.st</filein>
  <filein>Menus/HistoryMenus.st</filein>
  <filein>Menus/TabsMenus.st</filein>
  <filein>Menus/InspectorMenus.st</filein>
  <filein>Menus/TextMenus.st</filein>
  <filein>Menus/WorkspaceVariableMenus.st</filein>
  <filein>Menus/SimpleWorkspaceMenus.st</filein>
  <filein>Menus/WorkspaceMenus.st</filein>
  <filein>FakeNamespace.st</filein>
  <filein>Category/ClassCategory.st</filein>
  <filein>Category/AbstractNamespace.st</filein>
  <filein>Category/Class.st</filein>
  <filein>GtkAbstractConcreteWidget.st</filein>
  <filein>GtkConcreteWidget.st</filein>
  <filein>GtkScrollTreeWidget.st</filein>
  <filein>GtkSimpleListWidget.st</filein>
  <filein>GtkEntryWidget.st</filein>
  <filein>GtkSidebarWidget.st</filein>
  <filein>GtkHSidebarWidget.st</filein>
  <filein>GtkVSidebarWidget.st</filein>
  <filein>Model/GtkColumnType.st</filein>
  <filein>Model/GtkColumnTextType.st</filein>
  <filein>Model/GtkColumnPixbufType.st</filein>
  <filein>Model/GtkColumnOOPType.st</filein>
  <filein>GtkListModel.st</filein>
  <filein>GtkTreeModel.st</filein>
  <filein>Text/GtkTextWidget.st</filein>
  <filein>GtkPackageBuilderWidget.st</filein>
  <filein>GtkMainWindow.st</filein>
  <filein>GtkVisualGSTTool.st</filein>
  <filein>GtkBrowsingTool.st</filein>
  <filein>GtkLauncher.st</filein>
  <filein>Text/GtkTextPluginWidget.st</filein>
  <filein>Text/GtkFindWidget.st</filein>
  <filein>Text/GtkReplaceWidget.st</filein>
  <filein>Text/GtkSaveTextWidget.st</filein>
  <filein>GtkNotebookWidget.st</filein>
  <filein>Image/GtkImageModel.st</filein>
  <filein>Image/GtkImageWidget.st</filein>
  <filein>Debugger/GtkContextWidget.st</filein>
  <filein>Debugger/GtkDebugger.st</filein>
  <filein>State/BrowserState.st</filein>
  <filein>State/NamespaceState.st</filein>
  <filein>State/ClassState.st</filein>
  <filein>State/CategoryState.st</filein>
  <filein>State/MethodState.st</filein>
  <filein>GtkWorkspaceWidget.st</filein>
  <filein>GtkTranscriptWidget.st</filein>
  <filein>StBrowser/GtkCategorizedNamespaceWidget.st</filein>
  <filein>StBrowser/GtkCategorizedClassWidget.st</filein>
  <filein>StBrowser/GtkCategoryWidget.st</filein>
  <filein>StBrowser/GtkMethodWidget.st</filein>
  <filein>Text/GtkSourceCodeWidget.st</filein>
  <filein>StBrowser/GtkClassHierarchyWidget.st</filein>
  <filein>GtkHistoryWidget.st</filein>
  <filein>Inspector/GtkInspector.st</filein>
  <filein>StBrowser/GtkClassBrowserWidget.st</filein>
  <filein>GtkEntryDialog.st</filein>
  <filein>HistoryStack.st</filein>
  <filein>Undo/UndoStack.st</filein>
  <filein>Undo/UndoCommand.st</filein>
  <filein>Undo/AddNamespaceUndoCommand.st</filein>
  <filein>Undo/RenameNamespaceUndoCommand.st</filein>
  <filein>Undo/DeleteNamespaceUndoCommand.st</filein>
  <filein>Source/SourceFormatter.st</filein>
  <filein>Source/NamespaceHeaderSource.st</filein>
  <filein>Source/NamespaceSource.st</filein>
  <filein>Source/ClassHeaderSource.st</filein>
  <filein>Source/ClassSource.st</filein>
  <filein>Source/CategorySource.st</filein>
  <filein>Source/MethodSource.st</filein>
  <filein>Source/PackageSource.st</filein>
  <filein>Source/BrowserMethodSource.st</filein>
  <filein>Undo/AddClassUndoCommand.st</filein>
  <filein>Undo/RenameClassUndoCommand.st</filein>
  <filein>Undo/DeleteClassUndoCommand.st</filein>
  <filein>AbstractFinder.st</filein>
  <filein>NamespaceFinder.st</filein>
  <filein>ClassFinder.st</filein>
  <filein>MethodFinder.st</filein>
  <filein>GtkWebBrowser.st</filein>
  <filein>GtkWebView.st</filein>
  <filein>GtkAssistant.st</filein>
  <filein>Undo/RenameCategoryUndoCommand.st</filein>
  <filein>Undo/AddMethodUndoCommand.st</filein>
  <filein>Undo/DeleteMethodUndoCommand.st</filein>
  <filein>WorkspaceVariableTracker.st</filein>
  <filein>GtkVariableTrackerWidget.st</filein>
  <filein>SyntaxHighlighter.st</filein>
  <filein>Undo/Text/InsertTextCommand.st</filein>
  <filein>Undo/Text/DeleteTextCommand.st</filein>
  <filein>Undo/Text/ReplaceTextCommand.st</filein>
  <filein>Clock/GtkClock.st</filein>
  <filein>Inspector/GtkInspectorSourceWidget.st</filein>
  <filein>Inspector/GtkInspectorBrowserWidget.st</filein>
  <filein>Inspector/GtkInspectorWidget.st</filein>
  <filein>Inspector/GtkObjectInspectorView.st</filein>
  <filein>Inspector/GtkCompiledMethodInspectorView.st</filein>
  <filein>Inspector/GtkCompiledBlockInspectorView.st</filein>
  <filein>Inspector/GtkSequenceableCollectionInspectorView.st</filein>
  <filein>Inspector/GtkSetInspectorView.st</filein>
  <filein>Inspector/GtkDictionaryInspectorView.st</filein>
  <filein>Inspector/GtkCharacterInspectorView.st</filein>
  <filein>Inspector/GtkIntegerInspectorView.st</filein>
  <filein>Inspector/GtkFloatInspectorView.st</filein>
  <filein>Implementors/GtkImageResultsWidget.st</filein>
  <filein>Implementors/GtkImplementorResultsWidget.st</filein>
  <filein>Implementors/GtkSenderResultsWidget.st</filein>
  <filein>Notification/Kernel/AbstractNamespace.st</filein>
  <filein>Notification/Kernel/Metaclass.st</filein>
  <filein>Notification/Kernel/Class.st</filein>
  <filein>Notification/Kernel/MethodDictionary.st</filein>
  <filein>Debugger/GtkStackInspectorView.st</filein>
  <filein>Debugger/GtkStackInspector.st</filein>
  <filein>Tetris/HighScores.st</filein>
  <filein>Tetris/Score.st</filein>
  <filein>Tetris/TetrisPieceWidget.st</filein>
  <filein>Tetris/BlockWidget.st</filein>
  <filein>Tetris/TetrisField.st</filein>
  <filein>Tetris/TetrisPiece.st</filein>
  <filein>Tetris/TetrisPieceI.st</filein>
  <filein>Tetris/TetrisPieceJ.st</filein>
  <filein>Tetris/TetrisPieceL.st</filein>
  <filein>Tetris/TetrisPieceO.st</filein>
  <filein>Tetris/TetrisPieceS.st</filein>
  <filein>Tetris/TetrisPieceT.st</filein>
  <filein>Tetris/TetrisPieceZ.st</filein>
  <filein>Tetris/Tetris.st</filein>
  <filein>SUnit/TestBacktraceLog.st</filein>
  <filein>SUnit/GtkSUnitResultWidget.st</filein>
  <filein>GtkClassSUnitWidget.st</filein>
  <filein>GtkMethodSUnitWidget.st</filein>
  <filein>SUnit/GtkSUnit.st</filein>
  <filein>Commands/OpenBrowserCommand.st</filein>
  <filein>Commands/OpenTabbedBrowserCommand.st</filein>
  <filein>Commands/ToolsMenus/OpenSUnitCommand.st</filein>
  <filein>Commands/ToolsMenus/OpenBottomPaneCommand.st</filein>
  <filein>Commands/OpenWorkspaceCommand.st</filein>
  <filein>Commands/ToolsMenus/OpenImplementorCommand.st</filein>
  <filein>Commands/ToolsMenus/OpenSenderCommand.st</filein>
  <filein>Commands/ToolsMenus/OpenPackageBuilderCommand.st</filein>
  <filein>Commands/SaveImageCommand.st</filein>
  <filein>Commands/SaveImageAsCommand.st</filein>
  <filein>Commands/InspectorMenus/InspectorBackCommand.st</filein>
  <filein>Commands/InspectorMenus/InspectorDiveCommand.st</filein>
  <filein>Commands/WorkspaceMenus/DeleteItemCommand.st</filein>
  <filein>Commands/WorkspaceMenus/InspectItemCommand.st</filein>
  <filein>Commands/WorkspaceMenus/WorkspaceVariableCommand.st</filein>
  <file>Icons/category.gif</file>
  <file>Icons/namespace.gif</file>
  <file>Icons/go-bottom.png</file>
  <file>Icons/go-down.png</file>
  <file>Icons/go-first.png</file>
  <file>Icons/go-home.png</file>
  <file>Icons/go-jump.png</file>
  <file>Icons/go-last.png</file>
  <file>Icons/go-next.png</file>
  <file>Icons/go-previous.png</file>
  <file>Icons/go-run.png</file>
  <file>Icons/go-top.png</file>
  <file>Icons/go-up.png</file>
  <file>Icons/NUnit.Failed.png</file>
  <file>Icons/NUnit.Loading.png</file>
  <file>Icons/NUnit.None.png</file>
  <file>Icons/NUnit.NotRun.png</file>
  <file>Icons/NUnit.Running.png</file>
  <file>Icons/NUnit.SuccessAndFailed.png</file>
  <file>Icons/NUnit.Success.png</file>
  <file>Icons/extension.png</file>
  <file>Icons/overridden.png</file>
  <file>Icons/override.png</file>
  <file>Icons/visualgst.png</file>
  <start>VisualGST.GtkLauncher open.
    GTK.Gtk main</start>
</package>PK
     �Mh@+}'��  �    GtkWebBrowser.stUT	 eqXO�XOux �  �  GtkBrowsingTool subclass: GtkWebBrowser [
    | webview |

    GtkWebBrowser class >> openOn: aString [
        <category: 'user interface'>

        ^ (self openSized: 450@375)
	    url: aString
    ]

    GtkWebBrowser class >> open [
	<category: 'user interface'>

	^ self openSized: 450@375
    ]

    accelPath [
        <category: 'accelerator path'>

        ^ '<Smallzilla>'
    ]

    windowTitle [
        ^ 'Smallzilla'
    ]

    aboutTitle [
	^ 'About Smallzilla'
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

        webview := GtkWebView new
                        openUrl: 'http://smalltalk.gnu.org/';
                        showAll;
                        yourself.

	^ (GTK.GtkScrolledWindow withChild: webview)
	    showAll; 
	    yourself
    ]

    url: aString [
	<category: 'webkit events'>

	webview openUrl: aString
    ]

    hasChanged [
	<category: 'testing'>

	^ false
    ]
]

PK
     '\h@              Icons/UT	 �XO�XOux �  �  PK
     �Mh@�i؟�  �    Icons/go-last.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         Ĵl;   sBIT|d�   tEXtSoftware www.inkscape.org��<  >IDAT8���]hU�����f�
)l��P
�(hh�EQ�����B���A$I�R���`��P�Tm7EiQ	&�jl*ZZc�6*m���M�5�����{|��:�d��t�p/w���s���\QU��c�	�rX��~���&����d��[��̒`u�ۙ^ٝ�w�l�j���܆͈ C�m�W%�3�mi�sU�1�e�����N�V�_�7>�lL�_�{�r�~�r�=�̀-��7:�G)�0y,?��+���ӝ�c;�f�톉���%�(��>� �EQuI�!�crf�m���������qf��2�z���` t_���D��P�D���פS���ϧ��p˺M�;����ȅ��K1⃈CM�J�j��̖������o&�<2uh�2p9�D~�'*QUG2�$���T2��Z�@�J�l��p>������6��|�b�/�)��&�Z!
�(V�6�g|D<"q�P	���j�n�H�<���
� gK��׷.cmg/?L�ʟ�|�En�剀��'_��x�M�.nK���}�_Μ�R4���1=}�O��R5c����W�cg��󅮶�h-u���]��ov������(M��熲��$�T^|jk�5I�Z����{��S�����'G�8в؉��r��p� ���?��F��O��^89���)�����y�.6: ��J��������w�[��{])�9��)R3س��R����w��!u��!P��A���S���rC�`5��ӹ���lt ,��Pv{G�*�H�'"�jAl-�W;E���r@����s�]�"bb�z����.��}�X;��3�    IEND�B`�PK
     �Mh@���wj  j    Icons/go-down.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         Ĵl;   sBIT|d�   tEXtSoftware www.inkscape.org��<  �IDAT8���OlU�?��LwV�����m8���L4m!i4!�8@01�1�^4&4%zE�4OrV#6�&D�h�"	Q4*�!�R����y~vv;]v[9�_��ͼ����w~�Q"����P��݋�����e�5M���{��z{�#�78o�>�y����K8t����ۃP���U�@�.����?�q�
��ǡP�k�
`AX���ZĳR5-^�x_{"�q�O��x�HtR<����JD|,��x��,u[n����955j�������G�޳��bD8���/�G���		��
�+�ވE��*'�fo�y��Sy������?�����׾�b�T��;�U���A"�N������W����5��x�=3��ƿ=w,ټ�� TU���V�!�5�&�5�b����8�lr�ƥ�<�.0�ڒ��������ٸ��ٴ���D0�:‾���^�?�~��ʼ{���Z�͖}�S����g_�����	B�J�㫶Q��21y��3���2��hYng�mm��䉣��*6��'�PD͆��(��|y���B�L+h[0��1�jS������h�|�f���|�\M��3���ŷ�"?F�;�|����"�'�}X�9{s�����▀�R
r���Z�����ᠠTi�t����u���ND�p��5L��l�O�����!3���h3�L6[���Q��7�Mbڬ�zKׯ��O�_Sg��]C���@*"����N�̯'��].��� �\ �H    IEND�B`�PK
     �Mh@�R�m  m    Icons/go-up.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         Ĵl;   sBIT|d�   tEXtSoftware www.inkscape.org��<  �IDAT8���Mh\U��~�y�1Fd,m1ŶBЅ��NRl)� ��#�.�Y�KlRAp�+?@\��u�"P�B�H��ݸ�
��2&L��N;3��ȼ�RK��9p��]����=��+��f���f��F7�t�l�6OMi�'�K���;�Aj�ۻ��z1�b`���T~�`�hihϑbϭ��{'�֋���bp,�K����(��ϒ���{�t��ƕV�ȷoD_޴�Gƥ�z7�āgK�W����j��X�|���=Y�Ν�w�xpR�Sgg�{�'�-.\�g�x~]��FRg�z����������U�����R�j~Y�k|������n)���C[�wӕQ��kw����C��wT�O���b��S|`P��x���Y�����C�]=�������}wU����?�f1N�aX =�i�
BP0�#��y���}�vW'��<k�+����;��;t��9����03�XZԯ�s-�g9J��Γh�h
�v��ӟ\�_���ٷ�� ��+�/�u���� X/�WO|���h/��P�w>z��5� �8V�g_��_W5��ϕ��`0AU�V��~�f$��w�Ff�Ј�Fm��ASE�y���^B+8o0N��)�6wuWȲ9)dk͸
�B�(I�h�JLQD
"�J�ˀ��|��U8�;�J�� ",������@$"q6w�6u@�����k�z&"g
$����<4�d������$S	������y6;Il�3��lIs�$W����I
�,��    IEND�B`�PK
     �Mh@��՘  �    Icons/go-run.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         Ĵl;   sBIT|d�   	pHYs  	  	"���   tEXtSoftware www.inkscape.org��<   tEXtTitle Media Playback Startp#   tEXtAuthor Lapo Calamandreiߑ*   ItEXtCopyright Public Domain http://creativecommons.org/licenses/publicdomain/Y���  wIDAT8����oE����nc�v�d۱�D��H�@UU�8q !��@ �D%āCBp� �_R�T��
PB
�U4i'��Mg�ޙ��n��k.������{og��AD}  J̼�{0��l<����SQ_��Nyfn����H�H��Hj�����}����]�$�f��e��������K��	"�Pef�# ���J"6��c�C�Õ/ӏ�����$�X�U_�vS1�%]��`Ў��H����������D���[���b�C�	I#�h"�^�K�<��k�4��[�\tn�'�}�%�@{^��"�GR��h㽁l���y����5�RV�v�&���A@�It�0�I��i=tt�P<]9{�tv�L������k33;h�Q A�i�S�B�;E��'�b����Ʃ¹���3����Ju  �@$@$ �@��!b��P�ʃ'[p[.\�AS5(�����H>ឋ���c�c��#��p��!U���"'!�;q������[(U��>	Z�2�z}'��N*�m�hw1f������R�Y�O��������*�	����NZ����3_�ԝ���EᙯD�ğ=�Wy��?Ԟ��6���n,^'v� ���/��أ7v�G�D���n�&� 0����G�jc� �@�����Ւ�z��}�>*�>:W��MK	��R
D]3 H��J�Z�Z?=4'�k�T�2�>���^A��oC�����U\Y��_;�`�)Q|)��M��0t�-�-\Y�j��޸�`�<H_���O�m�u\c��jAI5�90�D��ѨNf/��>��|�����1�@zq"����`��t�\�H�4��>�ǚxɰ&�J    IEND�B`�PK
     �Mh@����  �     Icons/NUnit.SuccessAndFailed.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         ;֕J   bKGD � � �����   	pHYs     ��   tIME�48��z~  $IDATxڕ��MQ���[��M��>�=�\���( ��I������e%�(�}�î���k)#��I��|�?R����$��ia(MU�o^��ia�Թ_F��ʻ���Nwj;-�,��*a#�U�ʋ��Nm�X*�>��䧸�O��L�`C?ͭU;`ө��7�����V-�I�F&0��>(�����8��m�Z3d_��,�U"�����17YԂ�ۂu\�͞(ߨ^��F�����&y`r��Vm��-�WvM���9CMA��Ϟ��P���ʙ�UЯ�    IEND�B`�PK
     �Mh@i���  �    Icons/go-next.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         Ĵl;   sBIT|d�   tEXtSoftware www.inkscape.org��<  4IDAT8���[hU��5���b�E))(�'o탅
5�ЂVAE��"R�|iII��`Q�>�EPKi�C�Z
)bK4�&�*�54�KԤ��ӓ��e�^>�9u�6чt��̆5���ڋ٢�\��
�������&����ձym�-�76v/)`��/T��y���5oo�&���}?����k6�����kM��e�b�&�hh��QwYu#�s����N7l�Z�lU��}m���ʖӯ�ȕ����=����2'Aա(N]C�w�i`l|��j��Z{��������]N�ԞAő�����YR��Vw7{���L),>u��1���J��D�DdK�iHdC�4"ICb�!�-���'�����;�Yq�궆=AӢ`�JI���1.�����ҟ��HBH*Nb��\�ah�����nz����p�|p1�dx�[�r��?���>S�3>�')j��SDnX��h4��0��<#x�,�)���gM�v><qdvjz�Pom�kAp>���<L�w��gO<֯ڊ?����ó�S3�NL��y`	����7�C �Hn�'�ޤ���;���)=v�ef�����]7P�T51� ������l�F��ϽX�����G9�����ý�}��5�;*"ie�>���끪LՕ��&��R宕O���}�˟>��.��P �f��Y���K!}���9�^K#fIwp���)�#�~�5����Cg�s�Yn�)ξ˫�
U�"B"g�&M���GZ���A*�(������A�ۀ��TH΁�s���K��.S�)���S�M��R��-'�����4    IEND�B`�PK
     �Mh@@���  �    Icons/go-home.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         Ĵl;   bKGD � � �����   	pHYs  �  �B(�x   tIME�
#o�UO  %IDAT8˥��oE����:��m�@]Dm!U4��@(4R/ �*j-YU"�_�S��`�TH' ����:R/=��B9A�5��B\����]��M�D�H�ݝ���7�yoVp�69�~�9��mޚ�c�zǶ�<��ѾM~-�v׸�8 '�a���<�ѝ;�xmq��Qu���A�ֽ{d�]󇁋����
�0��Bg�m��J)�/��E���j�NG�?'.�����0t����F.b�i�Ǣm���`��1\ǡ��Gl�~��^<Ω�6�W�R�m�+="��uѶ�ل�]�dp�'��}�##��J&i�Z���y03�]���|:d!�Hǁn6�������Af���/���y���ļu��R��r�u��sxF�LEڄо��3LΟò��@k�eYd��eal��r��t�~����h��o300���]��n��>��,���0;O ٥���gg.-͝[��O?�dO7���׿�E�>��BG��>�v�J:�Й3���oĥ`|i�˓���A1���F��o���Z����0����ȿ�~p�5�����~����h�H$0M�00M�T�n� ��ߛ���l����؈���H)I�UQC)�R
������c<��d��K���;(r4[4�����Q�OE��+M6ֈ������I&A)���&b{��R���T��m-�"�� �|���0�F����=�JEe� t(B)җ'K�������M��w����P�! ���ڝ�l���ؚ��X<%� �خ���a�OG�?ifV(\�&?    IEND�B`�PK
     �Mh@�O  O    Icons/extension.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         ��a   gAMA  ��7��   tEXtSoftware Adobe ImageReadyq�e<  �IDAT8˥�=H�q��f~\?��,��yoX�{KC��7�PcM�5�4EkS$�8V*w����J�B%��{�s^1㪋g9�����9IDp�8��ラ�%w%I�=���@]m�v�bS?��|b��~��?��Gժi�lT70���������p��,�@ۙ�ܘ^�Y3�$ՙO�<o�a ��x8A��܉�BW!������!JB�x8K?�Y�\����z܃S�<f����R�DKC�������Pf'� ��h����af��WãI��n�]�BW���)䎇�p��!Gos�A��MN���X���	�0eY[�ra�B�A���m����h=ڊ�I#͘�0���6�1;����Ū���3Q�@s�e
���p�k_�;+���?R15�S_?q���9�*�H�3��ɞ����`�!w������2/��L .�\��c�Ie��صf|��Ĕ�b��`���M �o��w=��_��m�6E�X    IEND�B`�PK    �Mh@�w	?S  n    Icons/visualgst.pngUT	 eqXO�XOux �  �  ewPN�fpw)V�h��Jp���R\�{q���w(�N��N��E�w+���f�ss���Ov������HuU<l*l  ���(��2��k��/�X���ˀ䪩 ����Q�M?*������I/,'�/�/��kH�l�/F�oJ*rKXd�x�#�g ��XIVJ�s���>�z���D�%z�ٖt\M
W��_���5�^BU�DE
&�!,T�iPAF�*����6�DV(5�S*0WJb�Ԋx� �(.i��lݻ�:��/�w��	�=a����\^>�̎)0������3wp��_�u?�y���2�������G��mr)|�'�"��V�ZD��#>���bf�7�
ݙ��
:��]7̛�R��ž�"�3$�E�ZZ;:���C-']�8qոͥ�F�^0���Xp련bN���UT��¸��*Ο4���J\(_�p�h-.|�v�{[�
@�L�^���v������;P/�d��;�w%�Z*3���y}�㘋�|O+sW0��\�1������$޹��Q��5����.P$�tfF��	]{�:�p��,�PpfGNhJ>ǹ�ǶD��]���e�򇑟�u;�7Qc���������7���c���"�d=��?���Y KRI��N?��Hڙ�����Զ�hD�km��+P�k
� ���-=}K��W�BB9^�p�"}���q* �ҹL̮Wpj8?���z-���.q޴�{��|��+L�dV{��6f"���ܰ�e�`fR���ӲP�A�����JgO[��J,�o���X8î jȺ����G���
�=$����||�5:edW05Q烙��֓�: ��"��N�t1������=��=<���l�x1g��J��S���HH.K�^����p~z�B���u����7�B��*m�sV�����dY8Aůwn����ѥҀ� A(/Z6���!��T v�:ĺ�"�0U�����F��s�ot��[�ݼO�������̖��1^+��f��KB�*ŚJ<�,΁΁Hs�XB�������l���S*����iy�`d3��g�uj���P�|{o��a!�ۃ����������*�ʢ ��K���j樣ĭ�}���9���Mx�B��R�LQY�X1d��f?�x��*I]$ǃ(6[��Ł�h��VOP�� y!�o�����n����9F@��|�V��c�08�
��	TNU�7％w=^)���(]�`�������y썓�\��Ů>��jŤ�=�Զ�@P��i9��<ي��h����DWd��#�&���q� �]wSy2���j%j:��K�$W�m�%JI��!�f�=~9�~<���r�P_D/]G{������(%�כ�x�~&�N��ݟ�[1PB)��X{x��"�_�Cj �T��yu+��`q4͡�}o� �	b �Z�_��J@�+�t�"�b��!P�����U�	Y��O�����-���0�S1љ���}Rۜ&��G�nm����O�q~gs��`b�:��jLI��]a��{+��n.����h��r�V��M��_{�w�7�@� >!����T}�P�j�ib��cv�Yk*�1�܂�ʠ���8&QvX��Ы��m���m�{q��ʙ����#��YH�t���me�*H?�8��p�E	V�j�`��ʸ{��?�,}e��֘>4����`r�&�<,jS�=P��dI�7�'o��TB���y���i�,���VU���0�%;�U+���rq��ட���}f�ǳ���e���@R�%
�2YB�W�B$q�者����^���]���:2��!���!��i�]�a��$*�4Jo}Z1L�����r��ذ�~
��/��Y�-T�Y�.�X����1������/�EsC�l@�R�0�W�cm��N�!��[Eq|��T�ڇƃj��y��-R�����������б�m�{�d��~�%����F?�m� ���PĀ��� �ٝ�����;��[�3��e l��3�Uá��`&�ⴚ��P�K��N�d��;hpu���g���{�|�� �\�(�|V~ Y�Y��ݩ��d����0&:���ب�*�D���,ќ�vu.��8��Cm�9N�����Q4e���^]]���K�HY#P�f)}�$J�����ὸ�f��nr}x�9���%�yX?� 3�WVh`G����7i�׍$Z�r,IHg��;������ԛt���Ӎ�ܡ%R�91܎���_�i�Y�e�� �k�3%��/��,��*���ö'�G�i��� ���Md�Fu#�1��I9�n\��B��C[K�a����e�a;R V���%j�q�f"�ԏ�>+�B�
���qݡ�4��zV��HQogu��/��\s���������<�tG��]�'.��1���J�Wu|i��GcN�<�������T�ㄫU�<O]S�k&K�-��@Ì��1/��>Ň\����o���?�~^Q����t��ǰ�?D�yu�B8�I��Sj�a��`�R�3>�rʭ㋑ʌ(V��\���E�� ��N�o��<�7��e=u�o����ICƌ�:)ZT>�xGT�2̥WNC�=Y�*���(XR:����knI�Z5趦���J"D~	�������g����MV^^>���K�+/������VL�>�b7í�dLS~����'����N�Y�k^M��#�fkR+��+٨g��w` ]Kۭ�063�Gf����р]9O�����/7�?�|�b�}�0�K+�W"fR:/:r���IX�R�X�f�bQ.��9�y&�� �����)BTf�l����q�%�W�Q'��Z��}��t"S��J�����{H�ok��N������|�#����0����tR6�I��bߎy����z�4MJ��Uʿ�[h^�E ���c�^l�����Կ|�_�u�e��$/�!Dn�j��m�g%]�jXz(+�^p{6��I�M�����t�@V���n�Z��pIb4ZT�`���"1�6̅��S�r�b�f�Np�'�F+�#Մ"(� �[I[�V������.c�A�o���M0^��_�ٯT�_�`��r��/M�^v�hZ��3DB&�V�*��N��j�����gqG	�֋���u���P���*�b[w�F��5�	��ʘc��eAS*�Q�8W�&���J�%LR�F='��
���x�!��]ז�L;]�s����l�9Q6������T�}���bV�?:u�Jz�oE�����J��m�x�D���T�M�{ЅÕ�w�a��Qr��f:`��nL5Zh����MA��r9���a��ڡ��do������.Q+�Z�Xԃl��g$�,s�M<�����(q~���;ۂ'�Q�̿K��p�}�,�=��cV�j��.Ф�K�KY��%��1o_B��Ϣ,�`��C����D�f�b��c�7�x@�׀ޔ�8������/���\�_��[+���vtd�k��&��MB�6����a�S�AZ6����Й�y��`�k�%�8���q>��W�	��qP##A�־��C-�h���VBsLj���.q��W�8GK�y0����jb}�ٟ������D,֙��F �J�E�����Õ,Q���\�S��;EW������졉?�a����V���h�׊pzE��R7��V�JVc;̱T��b�S`Ε-h��fs����H-�k�?��=�E�e�����C&a����Z@�Az�W�NS�@}�>k�f�$P�V�����Ǡ��pwP�ũ�R�E�ƕ�dDt��I���}�nb�>P��s��]e������&�����2XEW�����1!�ŉ�k��gQ�SY�u��C,]2�D�r�{c��H
�FK��a����B�D����Z���M��������/�u{Ӊʲ�74^��`r� �j�r��X��.���f�~��Y�S��-j�Y|H�$�[���W_��~x�(��t�z�����s�~G5)
����5���f�hI��?�dsn��"��T_�ΔTV�U�Yu�6u=��y��eY�"�|%]t*֕�Z��;RA��-����h����OZ\'wnF�e��;ϯ���}dR[��0��L(��h"�������%\��cN2.�B��#���+�7f�}Yg��~@;�68�J�|�a�_��<o��V�m���J{�e��%h���?�!q'�Z;�~��$Ƥ�!K:+�&c�I'2C:+��)�����f�S\з�$��|ڞ��I�b�A�oڟ۽�I��§C�yVo���a��q�w)�"�Ħ3�������2Uo�db�E�9Y�ǯ�ҥ����ؖ�*ɪ㿅�FCE�;o��<��ע��<��@�L�GH��(ki�u82��;�"�E)\2�����=�Cr/17lAͦ��[�u>1(D<U��e����ћ�ϐ����\N��hՁ�����v-5�l�ݠ;����)�y���w�7�K�31;�����������yRQY�-�v����j���������N�Ċ�1�qh+$Gh�-,}��G�x��i��I�/0��a����UdM꭭1�W���e�C�_�y%�k�Bi�#nH}�!��DM�����a��Z:y�K�%���w�S�EY��i|u�n���)����gس�:���4��o����atgpʾk����$�
X���b��,h�V�%*\Œi霿���P4�b4BMr�9�K��M��+b�L��"/IM?�j�,�tjUJ�J�T$���<�W�����Zg�� �#�8ę��:�.����a�ԉ��a���Gi�v���+�?����N����[L[�=��)��$�{�8����G�,_/dJ`o�Dˤ�b���E��o���By�fq�H:��p�^���.�`����B��5���Ʌ�U��}� #���s<��,��;rB�$}	�4�JO�B}
�4g%�@��_��H����$�L�+/Rd���k�N����-�g�%��)��Y�♬���]̡��KD�/X�Wm�ݪ'�i>8M$(2���t;;	9�H��B~=��� �H��(U$�����ъE��y���ӷ[~7�:ß�4�����5eSISL�{�۪�LM���~�\�E��������ӉǄ��)��1&(��,��E�s)�����<?վ�;����W��	��n/�����4-;�"��Å�?,���
5��m9�񡰻�/�3�-���)�D�K.�Y���ɾp��1\|�@-�=E&�`��x�4��N���*��{�R-���$1�h;;�e�ے ��t��7b�-�j��A�?J�-���0���9�W<���3/|�Y�f��٧�L�~X>[򇪭-���E�Uu��!����ٌ����Z��^]^���$D�Z�n�������ּ�Ge���=vKFE3U�LD��D��5��>
W6����9jf�����x?�l����ܜ�x�yI>�P�,@�)���p8���c��R���H6E@��AI_�X�K%"o}������1f�r�����N.�>,<E�Wc�>���ӣfo9a��ݜ*���=}��K/P]rBlȇ���PG �i7x$��l钭r��B�{g�;�{pq26��Gt�!�"�S��X� ��=���>V��[�@*���Bsɋ=P��+	���Q�:���s>J	'u2���/���:SƇ*���HC$ut�;�/��e��!<2�L��٩��O��m�-��܂b9Z�+!=�ІD�J�Y��o��c�aSw_����8��z9@����L�/|4�'��T��{n�'8��#��J�������9v������p����%�:���kaĨC���r�_���� Բ�ha=ehUp�I���s��rW����Zk��O9��t���	��D�]��]>�>1�L��&S%��[8ˣ��M���x�9wX��s�.�fD��{����O��W`�����?�/>s��e�a�Ϡ5�����_�K��Lӎj��Q�Y<��ĺ}�u��[j���*��!Kd�����m{xIr����D�s���2� �,İ =�K�#�����M��5>����c��fWMf�3 `V�h����O��X.Z�3#�}��ũMx��f�xNb���N���":]D��^	����	%����(�%h&�lE���=5�,+F���"�d�������eSQ)�s;��Be ��;/V~����G�rM�S�ؾ���[Z���$=�v�ZW�b�j��
�tF�x���X�ڣ�6M��d��(4���tzs^^�����(�+���wnI�PP��:������w%-E�+.�@$1W�O��	���p�V/EINU�J�8�PK
     �Mh@R��B  B    Icons/NUnit.None.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         ;֕J   bKGD � � �G���   	pHYs     ��   tIME�0Vkp�   �IDATxڥ��m�0F��8�٫`�	p�#ix���@��,�ZE8�r������p�eY��4M��<��ȫ�c�r�߁0֫X������j���U�a �9�R�4���֨8���#"��{B s����MUq�:�sU��ӄǽՖU�؃_�3�圻�շ��5�D)��R�_
{\׳�j����1����"������~ b>W�\��    IEND�B`�PK
     �Mh@�k�Ƌ  �    Icons/go-bottom.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         Ĵl;   sBIT|d�   tEXtSoftware www.inkscape.org��<  IDAT8���QlU��sgfw0bԢ(h�h$�X�H���E�6�}$�X�c5��'��m��J�QlR�bD�FCb+1��Dl��Ν�Ǉٝ.���7�ɜ;�|矓s抪r-��&T�o��o88��r�h�l4fo�*0��׷�K�,�KH\L�RgI�%N���{�e��຤��RK*Ԓ
qZ͟�ڲd�U�X�����(]��٪�vݴ$x�P\v��Mkm�5��P��[<��.Tu8N����&�O��A.]_z�>rX����ޭO����RM��%8M�8��8W�����x��Ы�*X[c�����/�ݕ'i�U�p0�}O�K������&vs$Ԩ�9��NSM.� 
��S�5������'ފ��+��X�����7?Mۮ�{�K�2Ϲ���#�����hxp� ���9�=u�0��f��dU���������5+�9��\A�����/W��cΨc0*Ym	�����x�{e�p����_X�����f����M�5e *��9��[T�3��C_�W�ݴ���V���hX�|�����gTlE%;��eG%;ui��������[6��Y\OO��|:5Y�X>?��T�xi7A�v{z{6>�������C����{�����rp�p�ʪ�|�g�2b`��������ǡ1{4�ݔ����1F<OO� ۶�7���{Y��������ot������e�6�� x�d�7x~=���S2`����ɮ����]������A��ɀ"����
�5T�a����5n�[MW�?���f ��)    IEND�B`�PK
     �Mh@�e���  �    Icons/go-top.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         Ĵl;   sBIT|d�   tEXtSoftware www.inkscape.org��<  'IDAT8���[he��M��E�m�����Ђ�x�v�S�AQ}+x{�!On�hAA0R��}((�dT�H�%���B����l	����|>��2�[�=�1����ϙo�x��E<��f&މ:Lkӳ���^�*�{��f�~2��A�w�Ҷn{�9����Q�4}����d%]��i1�`O��f�8c���gk�4�R����{�C]�mA��9�k�ԙ�?=�V�Z�0�C[;o���0�i�KNN�`G����M�����ò������da���4|�(�qr�szv��_s��l{�8,ے1�H��gSs���6��8�K�������n$,���e[�������~����hB�#*���0�����G��˶�&8,[��{�q�N���D+�s� p$RE[�u���g���w��NQ��e+�+�o/�
��ߞ���Qk�9���U�S'���r�m]�]ik�n��6T�W��[6�����3���$i���D,P��E;�6
Q���/�$�$�T�5>�������CG�� ���b�|��u����T�x�x�і�?��V���� Zx��7�q�w���(�v���h�z{%��GT��S(-�PFPZ��c�h�V�UoE[�D1_����e�Y3�`��X��4�Ȋ"WKӌ�)�(��=��c5�	>i�D$��Ni2 `ӵI�x�@� ʂN�tS�OZͫ4�HD����� �^;vh�e�x6�3�����3K��!i`��g*�:P��'��q�D�FթK���9��9ؿ\���^R    IEND�B`�PK
     �Mh@�[���  �    Icons/go-previous.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         Ĵl;   sBIT|d�   tEXtSoftware www.inkscape.org��<  MIDAT8���Mh\U���s�͟R�#�4����Ƙ�,�(����]H�+k�.����.L7�buQ�"B-�"�*(�A�Xӈ�6i�df��s1w�1�c\���9���{��{�U�J,sE���?Ž���m��Ԩ�F�kv�7�~S�Fl�Z�'X^�vo��q��{�X�ҵi�y`XZs�ƻoݚ���Ѧ��ka6矗v���{G�]��NN��A��R^p����?��0���Z���s#��4�ܶ��6�`'�>�$Mxa�[�F� ���������:��9�������[�n3�21�	F,�|1y##k,�AD�oy�q��`ߺ�7���W���)~>{k�	H5%M�q���`2�I�(�8?��o�xf �X���o���i�	����BE<�Ơ���Ux�Yy���1���e_$����cP��T�i�h	��E���W�������G'߽tӆn�����/���
.����X�Z-Qk�4R�\���~�������c�ׇ�t>D���BC�*|	jq��XA��s˼�(D$ ��7��=U�O�;r�����'�0�1j*<��Y�s�����^I|uG`�-"�j�2��L��'�ݘ��~���]�6�o��N�CSx��+�r1�V�.07�"���L��߾L�����ğ<8q�+�3j"�e
c���E�r�R��X��Oh~������B����N����F��+�9N2�:�@|	-��/V�~��T<��4��P�\�Y�_�j��E$��ڱ����G����̏�6��$f.���c`(��J���*= �lwuH&�T?e(�.�*r��TD,���֩6Mm�Ht��q�X��$έ    IEND�B`�PK
     �Mh@!<�PU  U    Icons/NUnit.NotRun.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         ;֕J   bKGD � �  �2�   	pHYs     ��   tIME�;	eMr�   �IDATxڝ���0E_R�LBo��t��Cnp荎�ԊR��搶
)� K>��ϊG�AS�;���_A���S"?� )��C�m��'=��[m�K�ܟ�/��[W냉6ȭA��f,���w�tCM[�"X�V�l̇W�ExH}n����|��^��>W��<C�N����l5#�\�������z]����[+ذВ�f���m �>�?���Q}��<�    IEND�B`�PK    �Mh@fe���   �     Icons/namespace.gifUT	 eqXO�XOux �  �  s�t��L``8�������==�p���f�����ҽ�s��R�����wLߞ���P����	ʓC��%�.�QZ��(R����B�y�����g��020H0�8 ;X��R2�iD.�������L��;�M�`TX����C�Y�C��,��-|S�Ew��<�ȩ\�6!��)2Ǔ�v�H_br3H�NX�E�U��M�E']�O�� PK
     �Mh@T{��      Icons/go-jump.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         Ĵl;   sBIT|d�   tEXtSoftware www.inkscape.org��<  �IDAT8���_LUƿ{gfv�Jd�-����҅��H�ƴTm���M�on���3��i�4&�D��HZ�8�bHK�#X�e-��]�e����=>tw3�[�KOrrf����o���2"���X� ��F ���𾤰�ɢ"8���GX�tUX�T׌�N`f�"T^���w`ykk�����B:�����\X����tF��,�s�f��}g���jw}x�swm��ik�)Y3٨�.��~�G.�o��}f��-8T�<QY3�~x�	�7�"1�CU��}{������5��XD6#P����1��t|#���K�{?���:B.�ݐ�'d�{ F��;ngM�Ձ3�T��$ב�Ԩ�8P�<.}�$!�u͈�e ��������Z�5#�{v�G��2�����=�G�G־��fiO{����[� |Q� ����e�i��f|�.�E"�h�����,��j+g}���jo�]3b�$��Zl-UYV[�%3q�\� �]j�l4J�F �H �p�>0_�g�;�Y+�2�
h���{���ҁ��2�+�ښ���'�2��@9?ϝ��������K��2��V4� �J�sp�mhhht����[����P���}צ��+��	�ꚑz�Y�kF��WW#+��c������Q&��o:���13�Z!�~]3R����	�����7��; ER �������M��4�O׌�'���1�s/� ء7%����vw�V��=�'�?���㈮���I=a����/�[d���1@�%�U�����f>�\ϱ���=l5�L#��mަ��o�9 ��""bD�W(m� k{�����:�7f��+�əAk*����rP.�n;�;���瓫��̠5�١v�#)�%y�3�?t��R�ID�#{�������j���V�fW�r����0{��r�M��Bt    IEND�B`�PK    �Mh@��,A  B    Icons/NUnit.Loading.pngUT	 eqXO�XOux �  �  ��s���b``���p	�� ��$��M�RlI��.�Ap��品"����� ��0k�P����ו�*����xG��?@��.�!��N�-:b��6���G֢�E��l�l����dw��p�5
��	xt&G�z�����.��Y�)5��M��훫�^��o��9�p�������Q�T��;&4ԾA��	�'s��w�ߘ����)�t�rNq���&���3.������'����r��W��޿���x��9�^�����3Kc����cb�몲P߉'bC��}S>�O������^�S����z�����e�SB PK
     �Mh@��{  {    Icons/overridden.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         ��a   gAMA  ��7��   tEXtSoftware Adobe ImageReadyq�e<  IDAT8˥�?KQ���i�����
�H*�.���E��A��!X�X�	vc!v��{;��,�ӻ�\�}Ï��7I���b���c�0u����2�B���^��h�
gw`4�+��@j�ɥ  s��5"H h��Pǁ��h�"H.E��BF�����ݜ���&�
5E������Ƀ���Zn���+��;��l���8r9�~�c��$	��h��>�*����k���>�����h�L�Lj���ƳR�w��U�d�:�<$��hݸ    IEND�B`�PK
     �Mh@��U�t  t    Icons/override.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         ��a   gAMA  ��7��   tEXtSoftware Adobe ImageReadyq�e<  IDAT8˥�?/Q�ϲ��hg5��j%�'��F,[
���LH��	3�(���v��w�=�fcoN{O~9���VM4Q7ܿ�)v/�WQ������=��&���b����p�S�O��������^��'&^:\˨6���eND!&� ���9꒣�_|�?\����s���r�x�,�����g�*,(F�#d[��O� ��aAA�*�Pp1����O+C�$`�)����*�w`A��#�0�$���	�*�?�����b&N�R    IEND�B`�PK    �Mh@פ��6  7    Icons/NUnit.Success.pngUT	 eqXO�XOux �  �  ��s���b``���p	�� ��$��M�RlI��.@�?����I@g�Gd1�032̚#d/��ue��&�ma��4s%P舧�cHŭ��7�e2�i{�\�WـS7{NôF����$3n2ap��X�۹HȢH�y���R;]K��n���䧔��1���5<&*o���o�g��h�yT�%���ݸVaW���[��y�=������v��詇�?=&?�\�S�jYS"���õ�y�ڜ/}�P�$�����%����9���o�,�Ol�c����+_Ux�IYSO�;@�0x����sJh PK    �Mh@u�b{�  J    Icons/category.gifUT	 eqXO�XOux �  �  s�t��L``x�����Ѹ�׬�ߡ3©;ʭ?.dFV�삘9�u�'4n�t���2;�7�Fo˶��9���
��/:�N��E��U��͠(��=)�kB\���/�5���xY���w��e��o�`�����4-){yU��Y��|��iд��Y)a3Sb�d�>�yύC!��g�D�L���u���g_M����S̚M-��[w�������ș�K��'�K�wl�Ww�e�.+(_WѰ��zcU������k�0q_��K��ܹ�����g-8>{�����?v������}��OF�('������%����{���=&92r����F����x�Lk����\�"Ћ����)xE�@����P3��K���!w77�fFq�H-QQ	9%�=�ґ�
**�j'���M-#5#��u�ex�l�V�ۙ�k��U-y�b��qFN=��Z���uT���8���,�e񉍋���212X PK
     �Mh@�Q�      Icons/NUnit.Failed.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         ;֕J   bKGD � �  �2�   	pHYs     ��   tIME�8<�=�   �IDATxڭ���0E_�2@�a	ȥW�a���� � �=4�ȍ#�jɇ��Y��8�	�9�\��"�,����@�14��_=�� �+�>ޥZ� ����e/�7�Eݸm�*�J4Q��4\�
C��ڂO��ǹ ���g�~ ��CԘ�u���;�$�/���z%�T�����    IEND�B`�PK
     �Mh@,���  �    Icons/NUnit.Running.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         ;֕J   bKGD � � �����   	pHYs     ��   tIME��	ӕ  +IDATxڥ��j�0E���?Ji�l����<{��5i?�����.���o�J�B[A�:�L��^�s��t�8�s�K�֎�9	�-����� nφKh*@�x1���D�Ea� z0c�yQ,+���; u��'�������x&E�| 6��4�{O۶ OM��>��D&W�L��)˒,�PJ��"�2ʲ�3�><^��1��فj�1� ���'�����I�\X�����ཿ�w�s}�\u۶�΂!���ka��ۊ�*�7��u'%���X��d'%��l�����?Ɛ�-[�&�i�z    IEND�B`�PK
     �Mh@����  �    Icons/go-first.pngUT	 eqXO�XOux �  �  �PNG

   IHDR         Ĵl;   sBIT|d�   tEXtSoftware www.inkscape.org��<  TIDAT8���oh�U�?������jT�ڔb��DB�gMA��� �I������Sd�"�R� zc��o��7�Y!�T�&��ԢV�rmc��<����Ӌ��|��l�������=�����r)�\* ���	�ֳ;��wK�^/�X��ó�lNOv(�O�y	 U�ݝg�
��k���ܟ��8]œ����Mu����Y�o�۱��{7L�V<�K�1�-�m�̅�E�F��;5�X��;װsՒǚ�ni�_p���R.���$�ݒ�M	.>m��y�+���m���2^}|[��A�   ���Ó"�X:_�>k�9w�=�=M�#��k���`�Ê��sx��5S��z0�uܵp~g������2�3A���CM�J�`5�*YH���%��������v�i�5J �yR9��	YV&	�'R���܂f��B�ˈTP�X���D@�R�����0�yҊ�e_o8�ˑ��9pyC�lo*`3\l�q�7q�%*X���`�҃?}�U߾]��q}��+'�H������.LN[�߾�J��_?vj�3w/ZU�qE+?�����}C	���)>UB6)�XD��t�����O�'�7/�Z�T��G�����%>���,�d^��6�=���X�����qkWKq��.x�'�{+�*��kVH=p <�O������ɞׇ�O޴�kE!��5r�3����^�f�$T��a|�t�V�.}�Ⱥ���� L�qi͚��z�0���7�~�p<���<�j���7%=�h�eNY0&T5��g��D@�C`��J���}� ���IN�a*"�js?�U�_,�?�V�ɵq�    IEND�B`�PK
     &\h@              Undo/UT	 �XO�XOux �  �  PK
     �Mh@l�¥W  W    Undo/AddClassUndoCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: AddClassUndoCommand [

    | first namespace newClassName parentClass newClass classCategory |

    AddClassUndoCommand class >> add: aSymbol to: aNamespace classCategory: aCategory withSuperclass: aClass [
	<category: 'instance creation'>

	^ (self new)
	    add: aSymbol to: aNamespace classCategory: aCategory withSuperclass: aClass;
	    precondition;
	    yourself
    ]

    add: aSymbol to: aNamespace classCategory: aCategory withSuperclass: aClass [
	<category: 'initialize'>

	first := true.
	newClassName := aSymbol.
	namespace := aNamespace.
	classCategory := aCategory.
	parentClass := aClass
    ]

    description [
	<category: 'accessing'>

	^ 'Add a class'
    ]

    precondition [
	<category: 'checking'>

	newClassName = #Smalltalk ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name'  ].
	Smalltalk subspacesDo: [ :each | each name = newClassName ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name'  ] ].
	(namespace findIndexOrNil: newClassName) ifNotNil: [ ^ self preconditionFailed: 'class exist in the namespace' ].
	^ true
    ]

    undo [
	<category: 'events'>

	parentClass removeSubclass: newClass.
	namespace removeClass: newClass name
    ]

    redo [
	<category: 'events'>

	first 
	    ifTrue: [
		newClass := parentClass subclass: newClassName environment: namespace.
		namespace at: newClass name put: newClass.
                newClass category: classCategory fullname.
		first := false ]
	    ifFalse: [ 
		parentClass addSubclass: newClass.
		namespace insertClass: newClass ]
    ]
]

PK
     &\h@            
  Undo/Text/UT	 �XO�XOux �  �  PK
     �Mh@�8o��  �    Undo/Text/InsertTextCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: InsertTextCommand [
    | first string offset buffer |

    InsertTextCommand class >> insert: aString at: anOffset on: aGtkTextBuffer [
	<category: 'instance creation'>

	^ (self new)
	    insert: aString at: anOffset on: aGtkTextBuffer;
	    yourself
    ]

    insert: aString at: anOffset on: aGtkTextBuffer [
	<category: 'initialize'>

	first := true.
	string := aString.
	offset := anOffset.
	buffer := aGtkTextBuffer
    ]

    isInsertCommand [
	<category: 'testing'>

	^ true
    ]

    isDeleteCommand [
	<category: 'testing'>

	^ false
    ]

    offset [
	<category: 'accessing'>

	^ offset
    ]

    string [
	<category: 'accessing'>

	^ string
    ]

    string: aString [
	<category: 'accessing'>

	string := aString
    ]

    size [
	<category: 'accessing'>

	^ string size
    ]

    description [
	<category: 'accessing'>

	^ 'Insert a string'
    ]

    undo [
	<category: 'events'>

	buffer delete: (buffer getIterAtOffset: self offset) end: (buffer getIterAtOffset: self offset + self string size)
    ]

    redo [
	<category: 'events'>

	first ifTrue: [ first:= false. 
	    ^ self ].
	buffer insert: (buffer getIterAtOffset: self offset) text: self string len: self string size
    ]
]

PK
     �Mh@
v�K1  1    Undo/Text/DeleteTextCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: DeleteTextCommand [
    | first start end string buffer |

    DeleteTextCommand class >> from: aStartOffset to: anEndOffset text: aString on: aGtkTextBuffer [
	<category: 'instance creation'>

	^ (self new)
	    from: aStartOffset to: anEndOffset text: aString on: aGtkTextBuffer;
	    yourself
    ]

    from: aStartOffset to: anEndOffset text: aString on: aGtkTextBuffer [
	<category: 'initialize'>

	first := true.
	start := aStartOffset.
	end := anEndOffset.
	string := aString.
	buffer := aGtkTextBuffer
    ]

    isInsertCommand [
	<category: 'testing'>

	^ false
    ]

    isDeleteCommand [
	<category: 'testing'>

	^ true
    ]

    offset [
	<category: 'accessing'>

	^ start
    ]

    string [
	<category: 'accessing'>

	^ string
    ]

    string: aString [
	<category: 'accessing'>

	string := aString
    ]

    size [
	<category: 'accessing'>

	^ string size
    ]

    description [
	<category: 'accessing'>

	^ 'Delete a string'
    ]

    undo [
	<category: 'events'>

	buffer insert: (buffer getIterAtOffset: end - self string size) text: self string len: self string size
    ]

    redo [
	<category: 'events'>

        first ifTrue: [ first:= false.
            ^ self ].
	buffer delete: (buffer getIterAtOffset: end - self string size) end: (buffer getIterAtOffset: end)
    ]
]

PK
     �Mh@"I���  �    Undo/Text/ReplaceTextCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: ReplaceTextCommand [
    | search replace oldText buffer |

    ReplaceTextCommand class >> replace: aSearchString by: aReplaceString on: aGtkTextBuffer [
	<category: 'instance creation'>

	^ (self new)
	    replace: aSearchString by: aReplaceString on: aGtkTextBuffer;
	    yourself
    ]

    replace: aSearchString by: aReplaceString on: aGtkTextBuffer [
	<category: 'initialize'>

	search := aSearchString.
	replace := aReplaceString.
	oldText := aGtkTextBuffer text.
	buffer := aGtkTextBuffer
    ]

    isInsertCommand [
	<category: 'testing'>

	^ false
    ]

    isDeleteCommand [
	<category: 'testing'>

	^ false 
    ]

    description [
	<category: 'accessing'>

	^ 'Replace all the occurences of a string by an other'
    ]

    undo [
	<category: 'events'>

	buffer setText: oldText
    ]

    redo [
	<category: 'events'>

	buffer setText: (oldText copyReplaceAll: search with: replace)
    ]
]

PK
     �Mh@Փ��      Undo/DeleteMethodUndoCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: DeleteMethodUndoCommand [

    | selector classOrMeta compiledMethod |

    DeleteMethodUndoCommand class >> delete: aSymbol in: aClass [
	<category: 'instance creation'>

	^ (self new)
	    delete: aSymbol in: aClass;
	    "precondition;"
	    yourself
    ]

    delete: aSymbol in: aClass [
	<category: 'initialize'>

	selector := aSymbol.
	classOrMeta := aClass.
    ]

    description [
	<category: 'accessing'>

	^ 'Delete a method'
    ]

    precondition [
        <category: 'checking'>

	^ true
    ]

    undo [
	<category: 'events'>

	classOrMeta methodDictionary insertMethod: compiledMethod.
    ]

    redo [
	<category: 'events'>

	compiledMethod := classOrMeta >> selector.
	classOrMeta methodDictionary removeMethod: compiledMethod.
    ]
]

PK
     �Mh@���2B  B    Undo/DeleteClassUndoCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: DeleteClassUndoCommand [

    |  class |

    DeleteClassUndoCommand class >> delete: aClass [
	<category: 'instance creation'>

	^ (self new)
	    delete: aClass;
	    "precondition;"
	    yourself
    ]

    delete: aClass [
	<category: 'initialize'>

	class := aClass.
    ]

    description [
	<category: 'accessing'>

	^ 'Delete a class'
    ]

    precondition [
	<category: 'checking'>

        class subclasses isEmpty ifFalse: [ ^ self preconditionFailed: 'class has subclasses' ].
	^ true
    ]

    undo [
	<category: 'events'>

	class superclass ifNotNil: [ class superclass addSubclass: class ].
	class environment insertClass: class
    ]

    redo [
	<category: 'events'>

	class superclass ifNotNil: [ class superclass removeSubclass: class ].
	class environment removeClass: class name
    ]
]

PK
     �Mh@3[��  �    Undo/AddNamespaceUndoCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: AddNamespaceUndoCommand [
    | parentNamespace namespaceName newNamespace |

    AddNamespaceUndoCommand class >> add: aSymbol to: aNamespace [
	<category: 'instance creation'>

	^ (self new)
	    add: aSymbol to: aNamespace;
	    yourself
    ]

    add: aSymbol to: aNamespace [
	<category: 'initialize'>

	parentNamespace := aNamespace.
	namespaceName := aSymbol.
    ]

    description [
	<category: 'accessing'>

	^ 'Add a namespace'
    ]

    precondition [
        <category: 'checking'>

        namespaceName = #Smalltalk ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name' ].
        parentNamespace subspacesDo: [ :each |
	    each name = namespaceName ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name' ] ].
	(parentNamespace includesKey: namespaceName) ifTrue: [ ^ self preconditionFailed: 'parent namespace can''t be the same has a namespace name' ].
	newNamespace := Namespace gstNew: parentNamespace name: namespaceName asSymbol.
	^ true
    ]

    undo [
	<category: 'events'>

	parentNamespace removeSubspace: newNamespace name
    ]

    redo [
	<category: 'events'>

	parentNamespace insertSubspace: newNamespace
    ]
]

PK
     �Mh@B��!(  (    Undo/UndoStack.stUT	 fqXO�XOux �  �  Object subclass: UndoStack [

    | undoStack redoStack |

    initialize [
	<category: 'initialization'>

	undoStack := OrderedCollection new.
	redoStack := OrderedCollection new.
    ]

    clear [
	<category: 'stack'>

	redoStack empty.
	undoStack empty
    ]

    push: aCommand [
	<category: 'stack'>

	aCommand redo.
	redoStack empty.
	undoStack addFirst: aCommand
    ]

    pop [
	<category: 'stack'>

	undoStack first undo.
	undoStack removeFirst
    ]

    lastUndoCommand [
	<category: 'stack'>

	^ self hasUndo 
	    ifFalse: [ nil ]
	    ifTrue: [ undoStack first ]
    ]

    hasUndo [
	<category: 'testing'>

	^ undoStack isEmpty not
    ]

    undo [
	<category: 'undo-redo'>

	| cmd |
	undoStack isEmpty ifTrue: [ ^ self ].

	cmd := undoStack first
		    undo;
		    yourself.
	redoStack addFirst: undoStack removeFirst.
    ]

    redo [
        <category: 'undo-redo'>

        | cmd |
	redoStack isEmpty ifTrue: [ ^ self ].

        cmd := redoStack first
		    redo;
		    yourself.
        undoStack addFirst: redoStack removeFirst.
    ]
]

PK
     �Mh@u�R+-  -    Undo/RenameClassUndoCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: RenameClassUndoCommand [

    | class newClassName oldClassName |

    RenameClassUndoCommand class >> rename: aClass as: aSymbol [
	<category: 'instance creation'>

	^ (self new)
	    rename: aClass as: aSymbol;
	    "precondition;"
	    yourself
    ]

    rename: aClass as: aSymbol [
	<category: 'initialize'>

	class := aClass.
	oldClassName := class name.
	newClassName := aSymbol.
    ]

    description [
	<category: 'accessing'>

	^ 'Rename a class'
    ]

    precondition [
        <category: 'checking'>

        newClassName = #Smalltalk ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name'  ].
        class environment subspacesDo: [ :each | each name = newClassName ifTrue: [ ^ self preconditionFailed: 'class name can''t be the same has a namespace name'  ] ].
        (class environment findIndexOrNil: newClassName) ifNotNil: [ :class | ^ self preconditionFailed: 'class exist in the namespace' ].
	^ true
    ]

    undo [
	<category: 'events'>
	
        class environment removeClass: newClassName.
        class setName: oldClassName.
	class environment insertClass: class
    ]

    redo [
	<category: 'events'>

        class environment removeClass: oldClassName.
	class setName: newClassName.
	class environment insertClass: class
    ]
]

PK
     �Mh@&ҿ�E  E  "  Undo/DeleteNamespaceUndoCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: DeleteNamespaceUndoCommand [

    |  namespace treeStore |

    DeleteNamespaceUndoCommand class >> delete: aNamespace [
	<category: 'instance creation'>

	^ (self new)
	    delete: aNamespace;
	    yourself
    ]

    delete: aNamespace [
	<category: 'initialize'>

	namespace := aNamespace
    ]

    description [
	<category: 'accessing'>

	^ 'Delete a namespace'
    ]

    undo [
	<category: 'events'>

	namespace superspace insertSubspace: namespace
    ]

    redo [
	<category: 'events'>

	namespace superspace removeSubspace: namespace name
    ]
]

PK
     �Mh@H���|  |  !  Undo/RenameCategoryUndoCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: RenameCategoryUndoCommand [

    | category class newCategory treeStore |

    RenameCategoryUndoCommand class >> rename: aString in: aClass as: aNewName onModel: aGtkTreeStore [
	<category: 'instance creation'>

	^ (self new)
	    rename: aString in: aClass as: aNewName onModel: aGtkTreeStore;
	    "precondition;"
	    yourself
    ]

    rename: aString in: aClass as: aNewName onModel: aGtkTreeStore [
	<category: 'initialize'>

	category := aString.
	class := aClass.
	newCategory := aNewName.
	treeStore := aGtkTreeStore
    ]

    description [
	<category: 'accessing'>

	^ 'Rename a category'
    ]

    precondition [
        <category: 'checking'>

	newCategory = '*' ifTrue: [ ^ self preconditionFailed: 'Can''t create a * category' ].
        (treeStore hasCategory: newCategory asString) ifTrue: [ ^ self preconditionFailed: 'Category is present' ].
	^ true
    ]

    undo [
	<category: 'events'>

	class methodDictionary do: [ :each |
	    each methodCategory = newCategory
		ifTrue: [ each methodCategory: category ] ].
	treeStore
	    removeCategory: newCategory;
	    appendCategory: category
    ]

    redo [
	<category: 'events'>

	class methodDictionary do: [ :each |
            each methodCategory = category
                ifTrue: [ each methodCategory: newCategory ] ].
	treeStore
	    removeCategory: category;
	    appendCategory: newCategory
    ]
]

PK
     �Mh@�ƁV8  8    Undo/AddMethodUndoCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: AddMethodUndoCommand [

    | selector method category classOrMeta oldCompiledMethod browserWidget compiledMethod |

    AddMethodUndoCommand class >> add: aString classified: aCategory in: aClass [
	<category: 'instance creation'>

	^ (self new)
	    add: aString classified: aCategory in: aClass;
	    yourself
    ]

    AddMethodUndoCommand class >> add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget [
        <category: 'instance creation'>

        ^ (self new)
            add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget;
            yourself
    ]

    compileError: aString line: anInteger [
	<category: 'error printing'>

	browserWidget isNil ifFalse: [ GtkLauncher compileError: aString line: anInteger ].
	^ self preconditionFailed: aString
    ]

    compileError: aString pos: pos [
	<category: 'error printing'>

	^ self compileError: aString line: nil
    ]

    add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget [
        <category: 'initialize'>

	self add: aString classified: aCategory in: aClass.
	browserWidget := aGtkBrowserWidget.
    ]

    add: aString classified: aCategory in: aClass [
	<category: 'initialize'>

	method := aString.
        category := (#('still unclassified' '*') includes: (aCategory))
					    ifTrue: [ nil ]
					    ifFalse: [ aCategory ].
	classOrMeta := aClass
    ]

    description [
	<category: 'accessing'>

	^ 'Add a method'
    ]

    precondition [
        <category: 'checking'>

	| parser node |
        parser := STInST.RBBracketedMethodParser new
                    errorBlock: [ :string :pos | self compileError: string pos: pos. ^false ];
                    initializeParserWith: method type: #'on:errorBlock:';
                    yourself.

	selector := parser parseMethod selector.
	oldCompiledMethod := classOrMeta methodDictionary ifNotNil: [ classOrMeta methodDictionary at: selector ifAbsent: [ nil ] ].
	" TODO: use compile:classified:ifError: if there is no category "
	compiledMethod := classOrMeta
				compile: method
				ifError: [ :fname :lineNo :errorString |
				    self compileError: errorString line: lineNo.
                                    ^ false ].
	^ true
    ]

    undo [
	<category: 'events'>

	| selector |
        browserWidget ifNotNil: [ browserWidget codeSaved ].

	classOrMeta methodDictionary removeMethod: compiledMethod.
	oldCompiledMethod 
	    ifNotNil: [
		classOrMeta methodDictionary insertMethod: oldCompiledMethod.
		selector := oldCompiledMethod selector ]
	    ifNil: [ selector := nil ].
    ]

    redo [
	<category: 'events'>

	browserWidget ifNotNil: [ browserWidget codeSaved ].

	oldCompiledMethod ifNotNil: [ classOrMeta methodDictionary removeMethod: oldCompiledMethod ].
	classOrMeta methodDictionary insertMethod: compiledMethod.

	browserWidget ifNotNil: [ classOrMeta isClass 
						    ifTrue: [ browserWidget selectAnInstanceMethod: compiledMethod selector ]
						    ifFalse: [ browserWidget selectAClassMethod: compiledMethod selector ] ]
    ]

    displayError [
        <Category: 'error'>

    ]
]

PK
     �Mh@��$��  �  "  Undo/RenameNamespaceUndoCommand.stUT	 fqXO�XOux �  �  UndoCommand subclass: RenameNamespaceUndoCommand [

    | namespace oldName newName |

    RenameNamespaceUndoCommand class >> rename: aNamespace as: aSymbol [
	<category: 'instance creation'>

	^ (self new)
	    rename: aNamespace as: aSymbol;
	    "precondition;"
	    yourself
    ]

    rename: aNamespace as: aSymbol [
	<category: 'initialize'>

	namespace := aNamespace.
	oldName := namespace name.
	newName := aSymbol.
    ]

    description [
	<category: 'accessing'>

	^ 'Rename a namespace'
    ]

    precondition [
        <category: 'checking'>

        newName = #Smalltalk ifTrue: [ ^ self preconditionFailed: 'Namespace name can''t be the same has a namespace name'  ].
        namespace subspacesDo: [ :each | each name = newName ifTrue: [ ^ self preconditionFailed: 'Namespace name can''t be the same has a namespace name'  ] ].
	^ true
    ]

    undo [
	<category: 'events'>

	namespace superspace removeSubspace: namespace name.
	namespace name: oldName.
	namespace superspace insertSubspace: namespace
    ]

    redo [
	<category: 'events'>

	namespace superspace removeSubspace: namespace name.
        namespace name: newName.
        namespace superspace insertSubspace: namespace
    ]
]

PK
     �Mh@�<Cfx  x    Undo/UndoCommand.stUT	 fqXO�XOux �  �  Object subclass: UndoCommand [
    | description preconditionError |

    UndoCommand class >> undoStack [
	<category: 'accessing'>

	^ GtkClassBrowserWidget undoStack 
    ]

    description [
	<category: 'accessing'>

	^ self subclassResponsibility 
    ]

    precondition [
	<category: 'checking'>

	^ true
    ]

    preconditionFailed: aString [
	<category: 'checking'>

	preconditionError := aString.
	^ false
    ]

    error [
	<category: 'checking'>

	^ preconditionError
    ]

    undo [
	<category: 'events'>

	self subclassResponsibility
    ]

    redo [
	<category: 'events'>

	self subclassResponsibility 
    ]

    displayError [
        <Category: 'error'>

        GtkLauncher displayError: self description message: self error
    ]

    push [
	<category: 'accessing'>

	self precondition ifFalse: [ ^ self displayError ].
	self class undoStack push: self
    ]
]

PK
     �Mh@��H��  �    GtkEntryWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkEntryWidget [

    GtkEntryWidget class >> labeled: aString [
	<category: 'instance creation'>

	^ self new
	    initialize: aString;
	    yourself
    ]

    | entry label |

    initialize: aString [
        <category: 'initialization'>

	label := aString.
        self mainWidget: self buildMainWidget
    ]

    buildMainWidget [
        <category: 'user interface'>

        entry := GTK.GtkEntry new.
        ^ (GTK.GtkHBox new: true spacing: 3)
			add: (GTK.GtkLabel new: label);
			add: entry;
			yourself
    ]

    completion: aGtkEntryCompletion [

	entry setCompletion: aGtkEntryCompletion
    ]

    text [

	^ entry getText
    ]
]

PK
     %\h@              Source/UT	 �XO�XOux �  �  PK
     �Mh@�~w�  �    Source/ClassSource.stUT	 fqXO�XOux �  �  ClassHeaderSource subclass: ClassSource [
    
    sourceOf: aMethod [
	<category: 'accessing'>

        ^ (aMethod methodSourceString
                    ifNil: [ aMethod selector asString, ' [', Character nl asString, '    ]', Character nl asString ])
	    copyReplacingAllRegex: '\t' with: '    '
    ]

    outputMethod: aMethod [
	<category: 'printing'>

	| lines |
	lines := (self sourceOf: aMethod) lines.
	1 to: lines size do: [ :i |
	    stream
		space: 4;
		nextPutAll: (lines at: i);
		nl ].
	stream nl
    ]

    outputMethodWithoutFirstTab: aMethod [
        <category: 'printing'>

        | lines |
        lines := (self sourceOf: aMethod) lines.
        stream 
	    nextPutAll: (lines at: 1);
	    nl.
        2 to: lines size do: [ :i |
            stream
                space: 4;
                nextPutAll: (lines at: i);
                nl ].
        stream nl
    ]

    outputClassMethod: aMethod [
	<category: 'printing'>

        stream
            space: 4;
            nextPutAll: printClass name, ' class >> '.
	self outputMethodWithoutFirstTab: aMethod
    ]

    outputMethodsWith: aOneArgBlock in: aClass [

        aClass methodDictionary ifNotNil: [
            (aClass methodDictionary asSortedCollection: [ :a :b |
                    a methodCategory < b methodCategory ]) do: [ :each |
                        each methodCategory
                            ifNil: [ aOneArgBlock value: each ]
                            ifNotNil: [ :aCategoryString |  aCategoryString first ~= $* ifTrue: [ aOneArgBlock value: each ] ] ] ]
    ]

    outputMethodsFor: aClass [
	<category: 'printing'>

	self outputMethodsWith: [ :each | each printNl. self outputMethod: each ] in: aClass
    ]

    outputClassMethodsFor: aClass [
        <category: 'printing'>

	self outputMethodsWith: [ :each | self outputClassMethod: each ] in: aClass
    ]

    outputMethods [
	<category: 'printing'>

	self 
	    outputClassMethodsFor: printClass class;
	    outputMethodsFor: printClass
    ]
]

PK
     �Mh@�u��|  |    Source/MethodSource.stUT	 fqXO�XOux �  �  SourceFormatter subclass: MethodSource [
    | printMethod |

    MethodSource class >> write: aCompiledMethod on: aStream [
	<category: 'instance creation'>

	^(self for: aStream)
	    printMethod: {aCompiledMethod};
	    output;
            yourself
    ]

    MethodSource class >> writeMethods: aCollection on: aStream [
        <category: 'instance creation'>

	(self for: aStream)
            printMethod: aCollection;
	    output;
            yourself
    ]

    printMethod: aCollection [
	<category: 'accessing'>

	printMethod := aCollection
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    header [
        <category: 'accessing'>

	^ printMethod methodSourceString 
    ]

    methodSourceFor: aCompiledMethod [
        <category: 'accessing'>

        ^ (aCompiledMethod methodSourceString
                    ifNil: [ printMethod selector asString, ' [', Character nl asString, '    ]', Character nl asString ])
            copyReplacingAllRegex: '\t' with: '    '
    ]

    outputMethod: aString [
        <category: 'printing'>

        | lines |
        lines := aString lines.
        1 to: lines size - 1 do: [ :i |
            stream
                space: 4;
                nextPutAll: (lines at: i);
                nl ].
        stream 
            nextPutAll: lines last;
            nl  
    ]

    output [
	<category: 'accessing'>

        stream
            nextPutAll: printMethod first methodClass displayString;
            nextPutAll: ' extend [';
            nl.

	printMethod do: [ :each |
	    self outputMethod: (self methodSourceFor: each) ].

	stream
            nextPutAll: ']';
            nl.
    ]

    outputWithoutClassHeader [
        <category: 'accessing'>

	printMethod do: [ :each |
	    self outputMethod: (self methodSourceFor: each) ].

        stream nl. 
    ]

    parser [
        ^ STInST.RBBracketedMethodParser
    ]
]

PK
     �Mh@�'��  �    Source/NamespaceHeaderSource.stUT	 fqXO�XOux �  �  SourceFormatter subclass: NamespaceHeaderSource [
    | namespace |

    NamespaceHeaderSource class >> write: aNamespace on: aStream [
	<category: 'instance creation'>

	^(self for: aStream)
	    namespace: aNamespace;
	    output;
            yourself
    ]

    namespace: aNamespace [
	<category: 'accessing'>

	namespace := aNamespace
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    output [
	<category: 'accessing'>

	namespace superspace isNil
            ifFalse: [
		stream
                    nextPutAll: (namespace superspace nameIn: Smalltalk);
                    nextPutAll: ' addSubspace: #';
                    nextPutAll: namespace name;
                    nextPutAll: '!';
                    nl;
                    nextPutAll: 'Namespace current: ';
                    nextPutAll: (namespace nameIn: Smalltalk);
                    nextPutAll: '!';
                    nl;
                    nl ]
            ifTrue: [
		stream
                    nextPutAll: 'Namespace current: (RootNamespace new: #';
                    nextPutAll: (namespace nameIn: Smalltalk);
                    nextPutAll: ')!';
                    nl;
		    nl ].
    ]

    parser [
        ^ STInST.GSTParser
    ]
]
PK
     �Mh@��ˀ  �    Source/CategorySource.stUT	 fqXO�XOux �  �  SourceFormatter subclass: CategorySource [
    | printCategory class |

    CategorySource class >> write: aSymbol of: aClass on: aStream [
	<category: 'instance creation'>

	^(self for: aStream)
	    printCategory: aSymbol of: aClass;
	    output;
            yourself
    ]

    printCategory: aSymbol of: aClass [
	<category: 'accessing'>

	printCategory := aSymbol.
	class := aClass
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    output [
	<category: 'accessing'>

        stream
            nextPutAll: class displayString;
            nextPutAll: ' extend [';
            nl.

	class methodDictionary do: [ :each |
	    each methodCategory = printCategory ifTrue: [
		(MethodSource write: each on: stream)
		    outputWithoutClassHeader ] ].

	stream
            nextPutAll: ']';
            nl.
    ]

    parser [
        ^ STInST.GSTParser
    ]
]

PK
     �Mh@��fH  H    Source/PackageSource.stUT	 fqXO�XOux �  �  SourceFormatter subclass: PackageSource [

    PackageSource class >> write: aPackage on: stream [
        <category: 'instance creation'>

        ^ (self for: stream)
            package: aPackage;
            output;
            yourself
    ]

    | package |

    package: aPackage [
        <category: 'accessing'>

        package := aPackage
    ]

    printSelector: aSelectorString with: anArgString [
	<category: 'printing'>

        stream
            nextPutAll: aSelectorString;
            nextPutAll: anArgString;
            nextPutAll: ';';
            nl;
            space: 4
    ]

    printSelector: aSelectorString withArray: anArgArray [
        <category: 'printing'>

        anArgArray do: [ :each | self printSelector: aSelectorString with: each ]
    ]

    printName [

        package name ifNil: [ ^ self ].
	self printSelector: ' name: ' with: package name displayString
    ]

    printPackageUrl [

	package url ifNil: [ ^ self ].
	self printSelector: ' url: ' with: package url displayString
    ]

    printPackageNamespace [

        package namespace ifNil: [ ^ self ].
	self printSelector: ' namespace: ' with: package namespace displayString
    ]

    printPackageTest [

        "self test isNil
            ifFalse:
                [stream space: 2.
                self test
                    printOn: stream
                    tag: 'test'
                    indent: 4 + 2.
                stream
                    nl;
                    space: 4]."
    ]

    printPackageProvide [

	self printSelector: ' provides: ' withArray: package features asSortedCollection displayString
    ]

    printPackagePrereq [

	self printSelector: ' prereq: ' withArray: package prerequisites asSortedCollection displayString
    ]

    printPackageSUnit [

	self printSelector: ' sunit: ' withArray: package sunitScripts asSortedCollection displayString
    ]

    printPackageCallout [

	self printSelector: ' callout: ' withArray: package callouts asSortedCollection displayString
    ]

    printPackageLibrary [

	self printSelector: ' library: ' withArray: package libraries asSortedCollection displayString
    ]

    printPackageModule [

	self printSelector: ' module: ' withArray: package modules asSortedCollection displayString
    ]

    printPackageRelativeDirectory [

        package relativeDirectory ifNil: [ ^ self ].
	stream
            nextPutAll: ' directory: ';
            nextPutAll: package relativeDirectory displayString;
	    nextPutAll: ';';
            nl;
            space: 4
    ]

    printPackageFiles [

        package files size + package builtFiles size > 1 ifTrue: [
	    stream
                nl;
                space: 4 ]
    ]

    printPackageFileins [

        stream
            nextPutAll: ' filein: #';
            nextPutAll: package fileIns displayString;
	    nextPutAll: ';';
            nl;
            space: 4
    ]

    printPackageFile [

        stream
            nextPutAll: ' file: #';
            nextPutAll: (package files copy removeAll: package fileIns ifAbsent: []; yourself) displayString;
	    nextPutAll: ';';
            nl;
            space: 4
    ]

    printPackageBuiltFile [

        stream
            nextPutAll: ' built-file: #';
            nextPutAll: package builtFiles displayString;
	    nextPutAll: ';';
            nl;
            space: 4
    ]

    printPackageStartScript [

        package startScript ifNil: [ ^ self ].
        stream
	    nextPutAll: '  start: ''';
            nextPutAll: package startScript displayString;
	    nextPutAll: ''';';
            nl;
            space: 4
    ]

    printPackageStopScript [

        package stopScript ifNil: [ ^ self ].
        stream
            nextPutAll: '  stop: ''';
	    nextPutAll: package stopScript displayString;
	    nextPutAll: ''';';
            nl;
            space: 4
    ]

    printYourself [
	<category: 'accessing'>

        stream
            nextPutAll: 'yourself';
            nl;
            space: 4
    ]

    output [
        <category: 'accessing'>

        stream
            nextPutAll: 'Package new';
            nl;
            space: 4.

        self 
	    printName;
	    printPackageUrl;
	    printPackageNamespace;
	    printPackageTest;
	    printPackageProvide;
	    printPackagePrereq;
	    printPackageSUnit;
	    printPackageCallout;
	    printPackageLibrary;
	    printPackageModule;
	    printPackageRelativeDirectory;
	    printPackageFiles;
	    printPackageFileins;
	    printPackageFile;
	    printPackageBuiltFile;
	    printPackageStartScript;
	    printPackageStopScript;
	    printYourself
    ]

    parser [
        ^ STInST.GSTParser
    ]
]

PK
     �Mh@d�=P  P    Source/BrowserMethodSource.stUT	 fqXO�XOux �  �  SourceFormatter subclass: BrowserMethodSource [
    | method |

    BrowserMethodSource class >> write: aCompiledMethod on: aStream [
	<category: 'instance creation'>

	^(self for: aStream)
	    method: aCompiledMethod;
	    output;
            yourself
    ]

    method: aCompiledMethod [
	<category: 'accessing'>

	method := aCompiledMethod
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    output [
	<category: 'accessing'>

	stream nextPutAll: method methodRecompilationSourceString
    ]

    parser [
        ^ STInST.RBBracketedMethodParser
    ]
]
PK
     �Mh@Q4C��  �    Source/NamespaceSource.stUT	 fqXO�XOux �  �  NamespaceHeaderSource subclass: NamespaceSource [

    NamespaceSource class >> write: aNamespace on: aStream [
	<category: 'instance creation'>

	^(self for: aStream)
	    namespace: aNamespace;
	    output;
            yourself
    ]

    output [
	<category: 'accessing'>

	super output.
	namespace do: [ :each |
	    (each isNil not and: [ each isClass and: [ each environment = namespace ] ])
		ifTrue: [ (ClassSource write: each on: stream)
			    source ] ].
    ]
]
PK
     �Mh@�)>      Source/SourceFormatter.stUT	 fqXO�XOux �  �  Object subclass: SourceFormatter [
    | stream |

    SourceFormatter class >> for: aStream [
	<category: 'instance creation'>

	^ self new stream: aStream; yourself
    ]

    SourceFormatter class >> on: anObject [
	<category: 'instance creation'>

	^ self write: anObject on: (WriteStream on: String new)
    ]

    SourceFormatter class >> write: anObject on: aStream [
	<category: 'instance creation'>

	self subclassResponsibility
    ]

    stream [
	<category: 'accessing'>

	^ stream
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    output [
	<category: 'accessing'>

	self subclassResponsibility
    ]

    parser [
	self subclassResponsibility
    ]

    source [
	^ stream contents
    ]
    
    close [
	self stream close
    ]
]
PK
     �Mh@��'��  �    Source/ClassHeaderSource.stUT	 fqXO�XOux �  �  SourceFormatter subclass: ClassHeaderSource [
    | printClass |
    
    ClassHeaderSource class >> write: aClass on: aStream [
	<category: 'instance creation'>

	^ (self for: aStream)
	    printClass: aClass;
	    output;
            yourself
    ]

    printClass: aClass [
	<category: 'accessing'>

	printClass := aClass
    ]

    stream: aStream [
	<category: 'accessing'>

	stream := aStream
    ]

    outputClassHeader [
	<category: 'printing'>

	| superclassName |
        superclassName := printClass superclass isNil
            ifTrue: [ 'nil' ]
            ifFalse: [ printClass superclass nameIn: printClass environment ].

         stream
	    nextPutAll: superclassName;
	    space;
            nextPutAll: 'subclass: ';
            nextPutAll: printClass name;
            space;
            nextPut: $[;
            nl;
	    space: 4
    ]

    outputInstVarNamesArray [
	<category: 'printing'>

	printClass instVarNames do: [ :each |
	    stream
		nextPutAll: each asString;
		space
	]
    ]

    outputInstVarNames [
	<category: 'printing'>

	printClass instVarNames isEmpty ifTrue: [ ^ self ].
	stream
	    nextPutAll: '| '.
	self outputInstVarNamesArray.
	stream
	    nextPutAll: ' |';
	    nl;
	    space: 4
    ]

    outputShape [
	<category: 'printing'>

	| inheritedShape |
	inheritedShape := printClass superclass isNil ifTrue: [ nil ] ifFalse: [ printClass superclass shape ].
	printClass shape ~~ (printClass inheritShape ifTrue: [ inheritedShape ] ifFalse: [ nil ])
		ifTrue: [ 
		stream
		    nl;
		    space: 4;
		    nextPutAll: '<shape: #';
		    nextPutAll: printClass shape;
		    nextPut: $>;
		    nl;
		    space: 4 ]
    ]

    outputSharedPool [
	<category: 'printing'>

        printClass sharedPools do: [ :element |
	    stream
		nl;
		space: 4;
		nextPutAll: '<import: ';
		nextPutAll: element;
		nextPut: $> ].

        stream nl
    ]

    outputPragmas [
	<category: 'printing'>

        printClass classPragmas do: [ :selector |
	    stream
		space: 4;
		nextPut: $<;
		nextPutAll: selector;
		nextPutAll: ': '.
	    (printClass perform: selector) storeLiteralOn: stream.
	    stream
		nextPut: $>;
		nl ]
    ]

    outputClassInstanceVariablesArray [
	<category: 'printing'>

	printClass asMetaclass instVarNames do: [ :each |
	    stream
		nextPutAll: each asString;
		space ]
    ]

    outputClassInstanceVariables [
	<category: 'printing'>

        printClass asMetaclass instVarNames isEmpty ifTrue: [ ^ self ].
	stream
	    nl;
	    space: 4;
	    nextPutAll: printClass name;
	    nextPutAll: ' class [';
	    nl;
	    space: 8;
	    nextPutAll: '| '.
	self outputClassInstanceVariablesArray.
	stream
	    nextPutAll: ' |';
	    nl;
	    space: 4;
	    nextPut: $];
	    nl
    ]

    outputClassVariables [
	<category: 'printing'>

	stream nl.
	printClass classVarNames isEmpty ifTrue: [ ^ self ].
	printClass classVarNames do: [ :var |
	    stream
		space: 4;
		nextPutAll: var;
		nextPutAll: ' := nil.';
		nl ].
	stream nl
    ]

    outputMethods [
	<category: 'printing'>

    ]

    outputFinalBracket [
	<category: 'printing'>

        stream
            nextPut: $];
            nl;
            nl
    ]

    output [
	<category: 'printing'>

        self
            outputClassHeader;
            outputInstVarNames;
            outputShape;
            outputSharedPool;
            outputPragmas;
            outputClassInstanceVariables;
            outputClassVariables;
	    outputMethods;
	    outputFinalBracket.
    ]

    parser [
        ^ STInST.GSTParser
    ]
]

PK
     &\h@            	  Commands/UT	 �XO�XOux �  �  PK
     �Mh@�&ߍ   �     Commands/SaveImageAsCommand.stUT	 eqXO�XOux �  �  Command subclass: SaveImageAsCommand [

    execute [
        <category: 'command'>

        GtkLauncher uniqueInstance saveImageAs
    ]
]

PK
     &\h@              Commands/InspectorMenus/UT	 �XO�XOux �  �  PK
     �Mh@pn���   �   /  Commands/InspectorMenus/InspectorBackCommand.stUT	 eqXO�XOux �  �  Command subclass: InspectorBackCommand [

    item [

	^ 'Back'
    ]

    valid [
	<category: 'command'>

        ^ target isStackEmpty not
    ]

    execute [
	<category: 'command'>

        ^ target back
    ]
]

PK
     �Mh@��x��   �   /  Commands/InspectorMenus/InspectorDiveCommand.stUT	 eqXO�XOux �  �  Command subclass: InspectorDiveCommand [

    item [

	^ 'Dive'
    ]

    valid [
	<category: 'command'>

        ^ target canDive
    ]

    execute [
	<category: 'command'>

        ^ target dive
    ]
]

PK
     %\h@              Commands/DebugMenus/UT	 �XO�XOux �  �  PK
     �Mh@28y�   �   +  Commands/DebugMenus/ContinueDebugCommand.stUT	 eqXO�XOux �  �  DebugCommand subclass: ContinueDebugCommand [

    item [
        <category: 'menu item'>

        ^ 'Continue'
    ]

    stockIcon [

        ^ 'Icons/go-run.png'
    ]

    execute [
        <category: 'command'>

        target run
    ]

]

PK
     �Mh@���M�  �  #  Commands/DebugMenus/DebugCommand.stUT	 eqXO�XOux �  �  Command subclass: DebugCommand [

    iconPath [

	^ (GtkLauncher / self stockIcon) file displayString
    ]

    buildToolItem [
        <category: 'build'>

        ^ (GTK.GtkToolButton new: (GTK.GtkImage newFromFile: self iconPath) label: self item)
                                connectSignal: 'clicked' to: self selector: #executeIfValid;
                                setTooltipText: self tooltip;
                                yourself
    ]
]

PK
     �Mh@^����   �   )  Commands/DebugMenus/StepToDebugCommand.stUT	 eqXO�XOux �  �  DebugCommand subclass: StepToDebugCommand [

    item [
        <category: 'menu item'>

        ^ 'Step To Here'
    ]

    stockIcon [

        ^ 'Icons/go-jump.png'
    ]

    execute [
        <category: 'command'>

        target step
    ]

]

PK
     �Mh@z>A'�   �   +  Commands/DebugMenus/StepIntoDebugCommand.stUT	 eqXO�XOux �  �  DebugCommand subclass: StepIntoDebugCommand [

    item [
        <category: 'menu item'>

        ^ 'Step Into'
    ]

    stockIcon [

        ^ 'Icons/go-next.png'
    ]

    execute [
        <category: 'command'>

        target stepInto
    ]

]

PK
     $\h@              Commands/SmalltalkMenus/UT	 �XO�XOux �  �  PK
     �Mh@��J  J  )  Commands/SmalltalkMenus/DebugItCommand.stUT	 eqXO�XOux �  �  DoItCommand subclass: DebugItCommand [

    item [
        <category: 'menu item'>

        ^ 'Debug It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Alt>D'
    ]

    stockIcon [

        ^ 'gtk-sort-descending'
    ]

    execute [
        <category: 'command'>

        target debugIt: target targetObject
    ]
]

PK
     �Mh@�|	�   �   (  Commands/SmalltalkMenus/CancelCommand.stUT	 eqXO�XOux �  �  Command subclass: CancelCommand [

    item [
	<category: 'menu item'>

	^ 'Cancel'
    ]

    execute [
        <category: 'command'>

        target cancel
    ]
]

PK
     �Mh@��P�  �  *  Commands/SmalltalkMenus/AcceptItCommand.stUT	 eqXO�XOux �  �  Command subclass: AcceptItCommand [

    item [
        <category: 'menu item'>

        ^ 'Accept It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Control>S'
    ]

    stockIcon [

        ^ 'gtk-apply'
    ]

    acceptClassDefinitionOn: aNamespace [
        <category: 'class event'>

        Namespace current: aNamespace.
        "TODO: show errors as in AddMethodUndoCommand."
        target 
	    codeSaved;
	    clearUndo.
        STInST.STEvaluationDriver new
		    parseSmalltalkStream: (ReadStream on: target sourceCode) with: STInST.GSTFileInParser
    ]

    acceptClassDefinition [
        <category: 'class event'>

        ^ self acceptClassDefinitionOn: target state namespace
    ]

    execute [
	<category: 'command'>

        target state hasSelectedCategory ifFalse: [ ^ self acceptClassDefinition ].
        (AddMethodUndoCommand
	    add: target sourceCode
	    classified: target state category 
	    in: target state classOrMeta
	    browser: target) push
    ]
]

PK
     �Mh@��L  L  +  Commands/SmalltalkMenus/InspectItCommand.stUT	 eqXO�XOux �  �  DoItCommand subclass: InspectItCommand [

    item [
        <category: 'menu item'>

        ^ 'Inspect It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Control>I'
    ]

    stockIcon [

        ^ 'gtk-convert'
    ]

    execute [
        <category: 'command'>

        target inspectIt: target targetObject
    ]
]

PK
     �Mh@̾D  D  )  Commands/SmalltalkMenus/PrintItCommand.stUT	 eqXO�XOux �  �  DoItCommand subclass: PrintItCommand [

    item [
        <category: 'menu item'>

        ^ 'Print It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Control>P'
    ]

    stockIcon [

        ^ 'gtk-print'
    ]

    execute [
        <category: 'command'>

        target printIt: target targetObject
    ]
]

PK
     �Mh@�봅$  $  &  Commands/SmalltalkMenus/DoItCommand.stUT	 eqXO�XOux �  �  Command subclass: DoItCommand [

    item [
	<category: 'menu item'>

	^ 'Do It'
    ]

    accel [
        <category: 'menu item'>

	^ '<Control>D'
    ]

    stockIcon [

	^ 'gtk-execute'
    ]

    execute [
        <category: 'command'>

        target doIt: target targetObject
    ]
]

PK
     $\h@              Commands/CategoryMenus/UT	 �XO�XOux �  �  PK
     �Mh@Y�t!u   u   )  Commands/CategoryMenus/CategoryCommand.stUT	 eqXO�XOux �  �  Command subclass: CategoryCommand [

    valid [
	<category: 'command'>

	^target state hasSelectedCategory
    ]
]

PK
     �Mh@Tc��  �  /  Commands/CategoryMenus/RenameCategoryCommand.stUT	 eqXO�XOux �  �  CategoryCommand subclass: RenameCategoryCommand [

    item [

	^ 'Rename a category'
    ]

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Rename a category' text: 'Name of the category'.
        dlg hasPressedOk: [
            (RenameCategoryUndoCommand rename: target state category in: target state classOrMeta as: dlg result onModel: target viewedCategoryModel) push ]
    ]
]

PK
     �Mh@kf뢙  �  0  Commands/CategoryMenus/FileoutCategoryCommand.stUT	 eqXO�XOux �  �  CategoryCommand subclass: FileoutCategoryCommand [

    item [

	^ 'File out a category'
    ]

    execute [
	<category: 'command'>

        | file |
        (GTK.GtkFileChooserDialog save: 'Save Smalltalk category as...' parent: nil)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutCategory: dlg getFilename ].
                dlg destroy ]
    ]

    fileoutCategory: aString [
        <category: 'class events'>

        | stream |
        stream := FileStream open: aString mode: FileStream write.
        CategorySource write: target state category of: target classOrMeta on: stream
    ]
]

PK
     �Mh@��P�    ,  Commands/CategoryMenus/AddCategoryCommand.stUT	 eqXO�XOux �  �  ClassCommand subclass: AddCategoryCommand [

    item [

	^ 'Add a category'
    ]

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Add a category' text: 'Name of the category'.
        dlg hasPressedOk: [ 
            self addCategory: dlg result onWidget: target viewedCategoryWidget ]

    ]

    addCategory: category onWidget: categoryWidget [
	<category: 'events'>

	category = '*' ifTrue: [ ^GtkLauncher displayError: 'Can''t create a * category' ].
	(categoryWidget classOrMeta methodDictionary ifNil: [ false ] ifNotNil: [ :each | each includes: category asString ] ) ifFalse: [
	    SystemChangeNotifier root categoryAdded: category asString inClass: categoryWidget classOrMeta ].
	categoryWidget selectACategory: category asString
    ]
]
PK
     �Mh@����|   |      Commands/OpenWorkspaceCommand.stUT	 eqXO�XOux �  �  Command subclass: OpenWorkspaceCommand [

    execute [
        <category: 'command'>

        target newWorkspace
    ]
]

PK
     $\h@              Commands/MethodMenus/UT	 �XO�XOux �  �  PK
     �Mh@z3)�   �   ,  Commands/MethodMenus/InspectMethodCommand.stUT	 eqXO�XOux �  �  MethodCommand subclass: InspectMethodCommand [

    item [

	^ 'Inspect a method'
    ]

    execute [
	<category: 'command'>

        GtkInspector openOn: target state method
    ]
]

PK
     �Mh@}�]ٗ   �   (  Commands/MethodMenus/DebugTestCommand.stUT	 eqXO�XOux �  �  MethodCommand subclass: RunTestCommand [

    execute [
	<category: 'command'>

        target state classOrMeta debug: target state selector
    ]
]

PK
     �Mh@�˝�  �  ,  Commands/MethodMenus/FileoutMethodCommand.stUT	 eqXO�XOux �  �  MethodCommand subclass: FileoutMethodCommand [

    item [

	^ 'File out a method'
    ]

    execute [
	<category: 'command'>

	self chooseFile
    ]

    chooseFile [

        | file |
        (GTK.GtkFileChooserDialog save: 'Save Smalltalk method as...' parent: nil)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutMethod: dlg getFilename ].
                dlg destroy ]
    ]

    fileoutMethod: aString [
        <category: 'class events'>

        | stream |
        stream := FileStream open: aString mode: FileStream write.
        MethodSource write: target state method on: stream
    ]
]

PK
     �Mh@r��q   q   %  Commands/MethodMenus/MethodCommand.stUT	 eqXO�XOux �  �  Command subclass: MethodCommand [

    valid [
	<category: 'command'>

	^target state hasSelectedMethod
    ]
]

PK
     �Mh@���   �   +  Commands/MethodMenus/DeleteMethodCommand.stUT	 eqXO�XOux �  �  MethodCommand subclass: DeleteMethodCommand [

    item [

	^ 'Delete a method'
    ]

    execute [
	<category: 'command'>

        (DeleteMethodUndoCommand delete: target state selector in: target state classOrMeta) push
    ]
]

PK
     &\h@              Commands/WorkspaceMenus/UT	 �XO�XOux �  �  PK
     �Mh@�0\��   �   ,  Commands/WorkspaceMenus/DeleteItemCommand.stUT	 eqXO�XOux �  �  Command subclass: DeleteItemCommand [

    item [

	^ 'Delete variable'
    ]

    valid [
	<category: 'command'>

        ^ target hasSelectedItem
    ]

    execute [
	<category: 'command'>

        target deleteVariable.
    ]
]

PK
     �Mh@�%m)�   �   3  Commands/WorkspaceMenus/WorkspaceVariableCommand.stUT	 eqXO�XOux �  �  Command subclass: WorkspaceVariableCommand [

    item [
        <category: 'menu item'>

        ^ 'Show/Hide workspace variable(s)'
    ]

    execute [
        <category: 'command'>

	target showIVar
    ]
]

PK
     �Mh@Q���   �   -  Commands/WorkspaceMenus/InspectItemCommand.stUT	 eqXO�XOux �  �  InspectItCommand subclass: InspectItemCommand [

    item [

	^ 'Inspect variable'
    ]

    valid [
	<category: 'command'>

        ^ target hasSelectedValue
    ]
]

PK
     &\h@              Commands/ToolsMenus/UT	 �XO�XOux �  �  PK
     �Mh@��>C1  1  0  Commands/ToolsMenus/OpenPackageBuilderCommand.stUT	 eqXO�XOux �  �  Command subclass: OpenPackageBuilderCommand [

    item [
        <category: 'menu item'>

        ^ 'PackageBuilder'
    ]

    accel [
        <category: 'accel'>

        ^ '<Alt>P'
    ]

    execute [
        <category: 'command'>

        ^ GtkLauncher uniqueInstance showHidePackageBuilder
    ]
]
PK
     �Mh@�K�5�   �   +  Commands/ToolsMenus/OpenAssistantCommand.stUT	 eqXO�XOux �  �  Command subclass: OpenAssistantCommand [

    item [
        <category: 'menu item'>

        ^ 'Assistant'
    ]

    execute [
        <category: 'command'>

	GtkAssistant open
    ]
]

PK
     �Mh@��   �   ,  Commands/ToolsMenus/OpenWebBrowserCommand.stUT	 eqXO�XOux �  �  Command subclass: OpenWebBrowserCommand [

    item [
        <category: 'menu item'>

        ^ 'Smallzilla'
    ]

    execute [
        <category: 'command'>

	GtkWebBrowser open
    ]
]

PK
     �Mh@����  �  -  Commands/ToolsMenus/OpenImplementorCommand.stUT	 eqXO�XOux �  �  Command subclass: OpenImplementorCommand [

    item [
	<category: 'menu item'>

	^ 'Implementors'
    ]

    accel [
	<category: 'accel'>

	^ '<Control>M'
    ]

    selection [
        <category: 'focus checking'>

        target isNil ifTrue: [^nil].

        ((target browserHasFocus not and: [target hasSelection])
            or: [ target sourceCodeWidgetHasFocus ])
                ifTrue: [^target selectedMethodSymbol].

        ^target state hasSelectedMethod
                ifTrue: [ target state selector ]
                ifFalse: [ nil ]
    ]

    valid [
        <category: 'checking'>

        ^ target launcher notNil or: [ self selection notNil ]
    ]

    execute [
        <category: 'command'>

        | selection |
        selection := self selection.
        selection isNil ifTrue: [ ^ target launcher showHideImplementor ].
	target launcher showImplementorOn: selection
    ]
]
PK
     �Mh@e����  �  '  Commands/ToolsMenus/OpenSUnitCommand.stUT	 eqXO�XOux �  �  OpenBrowserCommand subclass: OpenSUnitCommand [

    item [
        <category: 'menu item'>

        ^ 'SUnit'
    ]

    defaultDestination [
        <category: 'selection'>

	^Smalltalk->nil
    ]

    selection [
        <category: 'selection'>

        | selection |
	selection := super selection printNl.
        selection value isNil ifTrue: [^selection].
        (selection value inheritsFrom: TestCase) ifTrue: [^selection].
        ^selection key->nil
    ]

    execute [
        <category: 'command'>

	| browser selection |
	browser := GtkSUnit open.
	selection := self selection.
	browser selectANamespace: selection key.
	selection value ifNotNil: [ browser selectAClass: selection value ]
    ]
]

PK
     �Mh@�n8�  �  (  Commands/ToolsMenus/OpenSenderCommand.stUT	 eqXO�XOux �  �  Command subclass: OpenSenderCommand [

    item [
        <category: 'menu item'>

        ^ 'Senders'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>N'
    ]

    selection [
        <category: 'focus checking'>

        target isNil ifTrue: [^nil].

        ((target browserHasFocus not and: [target hasSelection])
            or: [ target sourceCodeWidgetHasFocus ])
                ifTrue: [^target selectedMethodSymbol].

        ^target state hasSelectedMethod
                ifTrue: [ target state selector ]
                ifFalse: [ nil ]
    ]

    valid [
        <category: 'checking'>

        ^ target launcher notNil or: [ self selection notNil ]
    ]

    execute [
        <category: 'command'>

        | selection |
        selection := self selection.
        selection isNil ifTrue: [ ^ target launcher showHideSender ].
	target launcher showSenderOn: selection
    ]
]

PK
     �Mh@\��O      ,  Commands/ToolsMenus/OpenBottomPaneCommand.stUT	 eqXO�XOux �  �  Command subclass: OpenBottomPaneCommand [

    item [
        <category: 'menu item'>

        ^ 'Bottom Pane'
    ]

    accel [
        <category: 'accel'>

        ^ ''
    ]

    execute [
        <category: 'command'>

        ^ GtkLauncher uniqueInstance showHideBottomPane
    ]
]
PK
     $\h@              Commands/TabsMenus/UT	 �XO�XOux �  �  PK
     �Mh@�r� �   �   (  Commands/TabsMenus/PreviousTabCommand.stUT	 eqXO�XOux �  �  Command subclass: PreviousTabCommand [

    item [
	<category: 'menu item'>

	^ 'Previous Tab'
    ]

    execute [
        <category: 'command'>

        target shell previousTab
    ]
]
PK
     �Mh@g�n]�   �   $  Commands/TabsMenus/NextTabCommand.stUT	 eqXO�XOux �  �  Command subclass: NextTabCommand [

    item [
	<category: 'menu item'>

	^ 'Next Tab'
    ]

    execute [
        <category: 'command'>

        target shell nextTab
    ]
]
PK
     �Mh@�=���   �   %  Commands/TabsMenus/CloseTabCommand.stUT	 eqXO�XOux �  �  Command subclass: CloseTabCommand [

    item [
	<category: 'menu item'>

	^ 'Close Tab'
    ]

    execute [
        <category: 'command'>

        target closeTab
    ]
]
PK
     �Mh@�E��  �  $  Commands/OpenTabbedBrowserCommand.stUT	 eqXO�XOux �  �  OpenBrowserCommand subclass: OpenTabbedBrowserCommand [

    buildBrowserAndSelect: anAssociation [
	<category: 'user interface'>

	| browser |
        browser := target classBrowser.
        browser selectANamespace: anAssociation key.
        anAssociation value ifNotNil: [ browser selectAClass: anAssociation value ].
    ]

    execute [
        <category: 'command'>

	self buildBrowserAndSelect: self selection
    ]
]

PK
     $\h@              Commands/HistoryCommands/UT	 �XO�XOux �  �  PK
     �Mh@]#z�   �   .  Commands/HistoryCommands/HistoryBackCommand.stUT	 eqXO�XOux �  �  Command subclass: HistoryBackCommand [

    item [
	<category: 'menu item'>

	^ 'Back'
    ]

    accel [
	<category: 'menu item'>

	^ '<Alt>Left'
    ]

    execute [
        <category: 'command'>

        target back
    ]
]
PK
     �Mh@��w    1  Commands/HistoryCommands/HistoryDisplayCommand.stUT	 eqXO�XOux �  �  Command subclass: HistoryDisplayCommand [

    item [
	<category: 'menu item'>

	^ 'Show/Hide history pane'
    ]

    accel [
        <category: 'menu item'>

        ^ '<Control>H'
    ]

    execute [
        <category: 'command'>

        target showHideHistory
    ]
]
PK
     �Mh@�j��   �   1  Commands/HistoryCommands/HistoryForwardCommand.stUT	 eqXO�XOux �  �  Command subclass: HistoryForwardCommand [

    item [
	<category: 'menu item'>

	^ 'Forward'
    ]

    accel [
        <category: 'menu item'>

        ^ '<Alt>Right'
    ]

    execute [
        <category: 'command'>

        target forward
    ]
]
PK
     �Mh@���ov  v    Commands/OpenBrowserCommand.stUT	 eqXO�XOux �  �  Command subclass: OpenBrowserCommand [

    defaultDestination [
	<category: 'parsing'>

        ^ self namespace->nil
    ]

    namespace [
        ^ target state namespace ifNil: [ Smalltalk ]
    ]

    extractNamespaceAndClassFrom: aString [
	<category: 'parsing'>

	| node token start |
	[ node := STInST.RBParser parseExpression: aString ] on: Error do: [ ^ self defaultDestination ].
	node isVariable ifFalse: [ ^ self defaultDestination ].

        start := self namespace.
        (node name subStrings: $.) do: [ :each |
            start := start at: each asSymbol ifAbsent: [ ^ self checkDestination: start ] ].
        ^ self checkDestination: start
    ]

    checkDestination: anObject [
	<category: 'parsing'>

        anObject isClass ifTrue: [ ^ anObject environment -> anObject ].
        anObject isNamespace ifTrue: [ ^ anObject -> nil ].
        ^ self defaultDestination
    ]

    extractFromSelection [
	<category: 'parsing'>

	| result |
        target hasSelection
                ifTrue: [ result := self extractNamespaceAndClassFrom: target selectedText]
                ifFalse: [ result := self defaultDestination ].
	^ result
    ]

    selection [
	<category: 'accessing'>

        target isNil ifTrue: [^ self defaultDestination].

        ((target browserHasFocus not or: [ target sourceCodeWidgetHasFocus ])
            and: [target hasSelection])
                ifTrue: [ ^ self extractNamespaceAndClassFrom: target selectedText ].

	^ target state hasSelectedClass
                ifTrue: [ target state namespace -> target state classOrMeta asClass ]
                ifFalse: [ self defaultDestination ]
    ]
]

PK
     �Mh@QcSI*  *    Commands/Command.stUT	 eqXO�XOux �  �  Object subclass: Command [

    Command class >> execute [
	<category: 'instance creation'>

	^ self new
	    executeIfValid
    ]

    Command class >> target: anObject [
        <category: 'instance creation'>

	^ self new
	    target: anObject;
	    yourself
    ]

    Command class >> executeOn: anObject [
	<category: 'instance creation'>
    
	^ (self on: anObject)
		    executeIfValid
    ]

    Command class >> on: aGtkBrowser [
        <category: 'instance creation'>

        ^ self new
	    target: aGtkBrowser;
            yourself
    ]

    | target |
    
    target: anObject [
	<category: 'accessing'>

	target := anObject
    ]

    execute [
	<category: 'command'>

	self subclassResponisibility 
    ]

    valid [
	<category: 'command'>

	^ true
    ]

    executeIfValid [
	<category: 'command'>

        self valid ifFalse: [ ^ self ].
        ^ self
            execute;
            yourself
    ]

    item [
        <category: 'accessing'>

	self subclassResponsibility 
    ]

    accel [
        <category: 'accessing'>

	^ nil
    ]

    tooltip [
	<category: 'accessing'>

	^ ''
    ]

    stockIcon [
	<category: 'accessing'>

	^ ''
    ]

    buildMenuItem [
        <category: 'build'>

        ^ (GTK.GtkMenuItem newWithLabel: self item)
                show;
                connectSignal: 'activate' to: self selector: #executeIfValid;
                yourself
    ]

    buildToolItem [
        <category: 'build'>

	^ (GTK.GtkToolButton newFromStock: self stockIcon label: self item)
                                connectSignal: 'clicked' to: self selector: #executeIfValid;
                                setTooltipText: self tooltip;
                                yourself
    ]

    setState: aGtkMenuItem [
        <category: 'build'>

	aGtkMenuItem setSensitive: self valid
    ]
]

PK
     �Mh@���P�   �     Commands/SaveImageCommand.stUT	 eqXO�XOux �  �  Command subclass: SaveImageCommand [

    execute [
        <category: 'command'>

        GtkLauncher uniqueInstance saveImage
    ]
]

PK
     $\h@              Commands/ClassMenus/UT	 �XO�XOux �  �  PK
     �Mh@��l�^  ^  )  Commands/ClassMenus/RenameClassCommand.stUT	 eqXO�XOux �  �  ClassCommand subclass: RenameClassCommand [

    item [

	^ 'Rename a class'
    ]

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Rename a class' text: 'Name of the class'.
        dlg hasPressedOk: [
            (RenameClassUndoCommand rename: target state classOrMeta as: dlg result asSymbol) push ]
    ]
]

PK
     �Mh@1V��d  d  &  Commands/ClassMenus/AddClassCommand.stUT	 eqXO�XOux �  �  NamespaceCommand subclass: AddClassCommand [

    item [

	^ 'Add a class'
    ]

    execute [
	<category: 'command'>

	| dlg superclass |
	superclass := target state hasSelectedClass
            ifTrue: [ target state classOrMeta ]
            ifFalse: [ Object ].
        dlg := GtkEntryDialog title: 'Add a class' text: 'Name of the new class'.
        dlg hasPressedOk: [
            (AddClassUndoCommand
                add: dlg result asSymbol
                to: target state namespace
                classCategory: target state classCategory
                withSuperclass: superclass) push ]
    ]
]

PK
     �Mh@`��   �   *  Commands/ClassMenus/InspectClassCommand.stUT	 eqXO�XOux �  �  ClassCommand subclass: InspectClassCommand [

    item [

	^ 'Inspect a class'
    ]

    execute [
	<category: 'command'>

        GtkInspector openOn: target state classOrMeta
    ]
]
PK
     �Mh@�;�[p   p   #  Commands/ClassMenus/ClassCommand.stUT	 eqXO�XOux �  �  Command subclass: ClassCommand [

    valid [
	<category: 'command'>

	^ target state hasSelectedClass
    ]
]

PK
     �Mh@�����   �   )  Commands/ClassMenus/DeleteClassCommand.stUT	 eqXO�XOux �  �  ClassCommand subclass: DeleteClassCommand [

    item [

	^ 'Delete a class'
    ]

    execute [
	<category: 'command'>

        (DeleteClassUndoCommand delete: target state classOrMeta) push
    ]
]
PK
     �Mh@�;��]  ]  *  Commands/ClassMenus/FileoutClassCommand.stUT	 eqXO�XOux �  �  ClassCommand subclass: FileoutClassCommand [

    item [

	^ 'File out a class'
    ]

    execute [
	<category: 'command'>

        | file |
        (GTK.GtkFileChooserDialog save: 'Save Smalltalk class as...' parent: nil)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutClass: dlg getFilename ].
                dlg destroy ]
    ]

    fileoutClass: aString [

        | stream |
        stream := FileStream open: aString mode: FileStream write.
        (ClassSource write: target state classOrMeta asClass on: stream) close
    ]
]

PK
     $\h@              Commands/NamespaceMenus/UT	 �XO�XOux �  �  PK
     �Mh@�΀�_  _  1  Commands/NamespaceMenus/DeleteNamespaceCommand.stUT	 eqXO�XOux �  �  NamespaceCommand subclass: DeleteNamespaceCommand [

    item [

	^ 'Delete a namespace'
    ]

    execute [
	<category: 'command'>

	| namespace |
        namespace := target state namespace.
        namespace subspaces isEmpty ifFalse: [ self error: 'Namespace has subspaces' ].
        (DeleteNamespaceUndoCommand delete: namespace) push
    ]
]

PK
     �Mh@�2sj  j  .  Commands/NamespaceMenus/AddNamespaceCommand.stUT	 eqXO�XOux �  �  NamespaceCommand subclass: AddNamespaceCommand [

    item [

	^ 'Add a namespace'
    ]

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Add a namespace' text: 'Name of the new namespace'.
        dlg hasPressedOk: [ 
            (AddNamespaceUndoCommand add: dlg result asSymbol to: target state namespace) push ]
    ]
]

PK
     �Mh@�년w   w   +  Commands/NamespaceMenus/NamespaceCommand.stUT	 eqXO�XOux �  �  Command subclass: NamespaceCommand [

    valid [
	<category: 'command'>

	^target state hasSelectedNamespace
    ]
]

PK
     �Mh@R��y  y  1  Commands/NamespaceMenus/RenameNamespaceCommand.stUT	 eqXO�XOux �  �  NamespaceCommand subclass: RenameNamespaceCommand [

    item [

	^ 'Rename a namespace'
    ]

    execute [
	<category: 'command'>

	| dlg |
        dlg := GtkEntryDialog title: 'Rename a namespace' text: 'Name of the new namespace'.
        dlg hasPressedOk: [ 
            (RenameNamespaceUndoCommand rename: target state namespace as: dlg result asSymbol) push ]
    ]
]

PK
     �Mh@�~$&  &  2  Commands/NamespaceMenus/FileoutNamespaceCommand.stUT	 eqXO�XOux �  �  NamespaceCommand subclass: FileoutNamespaceCommand [

    | namespace |

    item [

	^ 'File out a namespace'
    ]

    execute [
	<category: 'command'>

	self chooseDirectory
    ]

    chooseDirectory [
	| file |
        (GTK.GtkFileChooserDialog selectFolder: 'Save namespace as...' parent: nil)
            showModalOnAnswer: [ :dlg :res |
                res = GTK.Gtk gtkResponseAccept ifTrue: [ self fileoutNamespace: dlg getCurrentFolder ].
                dlg destroy ].
    ]

    fileoutNamespace: aDirectory [

        namespace := target state namespace.
        self 
	    fileoutNamespaceOn: (File name: aDirectory) / namespace name;
	    fileoutNamespaceExtendsOn: (File name: aDirectory) / namespace name
    ]

    fileoutNamespaceOn: aDirectory [
        <category: 'namespace events'>

        | stream |
        aDirectory exists ifFalse: [ aDirectory createDirectory ].
        stream := FileStream open: (aDirectory / 'self.st') asString mode: FileStream write.
        NamespaceHeaderSource write: namespace on: stream.
        namespace allClassesDo: [ :each | self fileoutClass: each from: aDirectory ]
    ]

    fileoutNamespaceExtendsOn: aDirectory [
        <category: 'namespace events'>

        | stream |
        aDirectory exists ifFalse: [ aDirectory createDirectory ].
	self fileoutExtensionsTo: aDirectory
    ]

    fileoutClass: aClass from: aDirectory [

	| directory stream |
	directory := self createCategories: aClass category from: aDirectory.
	stream := FileStream open: (directory / ((aClass name asString) , '.st')) asString mode: FileStream write.
	(ClassSource write: aClass on: stream) close
    ]

    checkFileoutExtensions [

        | extName dic |
        dic := Dictionary new.
        extName := '*', namespace name.
        CompiledMethod allInstancesDo: [ :each |
            (each methodCategory startsWith: extName) ifTrue: [
                ((dic at: each methodCategory ifAbsentPut: [ Dictionary new ]) at: each methodClass ifAbsentPut: [ OrderedCollection new ]) add: each ] ].
        ^ dic
    ]

    fileoutExtensionsTo: aDirectory [

        | dic written |
        written := Set new.
        dic := self checkFileoutExtensions.
        dic keysAndValuesDo: [ :aMethodCategory :aDictionary |
	    | stream |
	    stream := ((self createCategories: (aMethodCategory copyFrom: 2 to: aMethodCategory size) from: aDirectory) / 'Extensions.st') writeStream.
	    aDictionary keysDo: [ :aBehavior |
		(written includes: aBehavior asClass) ifFalse: [
		    written add: aBehavior asClass.
		    aDictionary at: aBehavior asClass ifPresent: [ :anOrderedCollection | MethodSource writeMethods: anOrderedCollection on: stream ].
		    aDictionary at: aBehavior asMetaclass ifPresent: [ :anOrderedCollection | MethodSource writeMethods: anOrderedCollection on: stream ] ] ].
		stream close ]
    ]

    createCategories: aString from: aDirectory [

        | categories directory |
	(aString isNil or: [ aString isEmpty ]) ifTrue: [ ^ aDirectory ].
        categories := (aString tokenize: '-') asOrderedCollection.
        categories first = namespace name asString ifTrue: [ categories removeFirst ].
        directory := aDirectory.
        categories do: [ :each |
            directory := directory / each.
            directory exists ifFalse: [ directory createDirectory ] ].
	^ directory
    ]
]

PK
     �Mh@r�n�   �   2  Commands/NamespaceMenus/InspectNamespaceCommand.stUT	 eqXO�XOux �  �  NamespaceCommand subclass: InspectNamespaceCommand [

    item [

	^ 'Inspect a namespace'
    ]

    execute [
	<category: 'command'>

        GtkInspector openOn: target state namespace
    ]
]

PK
     $\h@              Commands/EditMenus/UT	 �XO�XOux �  �  PK
     �Mh@��z    &  Commands/EditMenus/PasteEditCommand.stUT	 eqXO�XOux �  �  Command subclass: PasteEditCommand [

    item [
	<category: 'menu item'>

	^ 'Paste'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>V'
    ]

    stockIcon [

	^ 'gtk-paste'
    ]

    execute [
        <category: 'command'>

        target paste
    ]
]
PK
     �Mh@�b7�   �   *  Commands/EditMenus/SelectAllEditCommand.stUT	 eqXO�XOux �  �  Command subclass: SelectAllEditCommand [

    item [
	<category: 'menu item'>

	^ 'Select all'
    ]

    execute [
        <category: 'command'>

        target selectAll
    ]
]
PK
     �Mh@��82�   �   %  Commands/EditMenus/FindEditCommand.stUT	 eqXO�XOux �  �  Command subclass: FindEditCommand [

    item [
	<category: 'menu item'>

	^ 'Find'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>F'
    ]

    execute [
        <category: 'command'>

        target find
    ]
]
PK
     �Mh@~����   �   '  Commands/EditMenus/CancelEditCommand.stUT	 eqXO�XOux �  �  Command subclass: CancelEditCommand [

    item [
	<category: 'menu item'>

	^ 'Cancel edits'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control><shift>Z'
    ]

    execute [
        <category: 'command'>

        target cancel
    ]
]
PK
     �Mh@��    %  Commands/EditMenus/RedoEditCommand.stUT	 eqXO�XOux �  �  Command subclass: RedoEditCommand [

    item [
	<category: 'menu item'>

	^ 'Redo'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>Y'
    ]

    stockIcon [

	^ 'gtk-redo'
    ]

    execute [
        <category: 'command'>

        target redo
    ]
]
PK
     �Mh@��Qk    $  Commands/EditMenus/CutEditCommand.stUT	 eqXO�XOux �  �  Command subclass: CutEditCommand [

    item [
	<category: 'menu item'>

	^ 'Cut'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>X'
    ]

    stockIcon [

	^ 'gtk-cut'
    ]

    execute [
        <category: 'command'>

        target cut
    ]
]
PK
     �Mh@�n��   �   (  Commands/EditMenus/ReplaceEditCommand.stUT	 eqXO�XOux �  �  Command subclass: ReplaceEditCommand [

    item [
	<category: 'menu item'>

	^ 'Replace'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>R'
    ]

    execute [
        <category: 'command'>

        target replace
    ]
]
PK
     �Mh@K�Z�    %  Commands/EditMenus/UndoEditCommand.stUT	 eqXO�XOux �  �  Command subclass: UndoEditCommand [

    item [
	<category: 'menu item'>

	^ 'Undo'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>Z'
    ]

    stockIcon [

	^ 'gtk-undo'
    ]

    execute [
        <category: 'command'>

        target undo
    ]
]
PK
     �Mh@���m    %  Commands/EditMenus/CopyEditCommand.stUT	 eqXO�XOux �  �  Command subclass: CopyEditCommand [

    item [
	<category: 'menu item'>

	^ 'Copy'
    ]

    accel [
        <category: 'accel'>

        ^ '<Control>C'
    ]

    stockIcon [

	^ 'gtk-copy'
    ]

    execute [
        <category: 'command'>

        target copy
    ]
]
PK
     '\h@              Tests/UT	 �XO�XOux �  �  PK
     �Mh@�-M  M    Tests/CategoryTest.stUT	 fqXO�XOux �  �  Smalltalk.Object subclass: CategoryA [
    <category: nil>
]

Smalltalk.Object subclass: CategoryB [
    <category: 'Language-Implementation'>
]

Smalltalk.Object subclass: CategoryC [
    <category: 'Foo-Bar'>
]

Smalltalk.TestCase subclass: CategoryTest [

    testExtraction [
	<category: 'testing'>

	| p |
	p := ClassCategory new.
	ClassCategory extractCategory: CategoryA for: p into: CategoryA environment.
        self assert: p categories isEmpty.
	ClassCategory extractCategory: CategoryB for: p into: CategoryB environment.
	self assert: (p categories includesKey: 'Language').
	self assert: (p at: 'Language') isCategory.
	self assert: (p at: 'Language') isNamespace not.
	self assert: ((p at: 'Language') classes isEmpty).
	self assert: ((p at: 'Language') categories includesKey: 'Implementation').
	self assert: ((p at: 'Language') at: 'Implementation') isCategory.
	self assert: ((p at: 'Language') at: 'Implementation') isNamespace not.
	self assert: (((p at: 'Language') at: 'Implementation') classes includes: CategoryB).
    ]

    testCategories [
	<category: 'testing'>

	| categories |
	categories := CategoryC environment categories.
	self assert: (categories at: 'Foo') isCategory.
	self assert: (categories at: 'Foo') isNamespace not.
	self assert: (categories at: 'Foo') name = 'Foo'.
	self assert: Smalltalk isNamespace.
	self assert: Smalltalk isCategory not.
	self assert: (categories at: 'Foo') category == (categories at: 'Foo').
	self assert: (categories at: 'Foo') subspaces isEmpty.
	self assert: (((categories at: 'Foo') at: 'Bar') classes includes: CategoryC).
	self assert: (((categories at: 'Foo') at: 'Bar') parent == (categories at: 'Foo')).
	self assert: (categories at: 'Foo') parent parent isNil.
    ]

    testNamespace [

	| categories |
	categories := CategoryC environment categories.
	self assert: categories namespace = CategoryC environment.
	self assert: (categories at: 'Foo') namespace = CategoryC environment.
    ]

    testCategoryOfClass [
	<category: 'testing'>

	| p |
	p := Object classCategory.
	self assert: p name = 'Implementation'.
	p := Kernel.Stat classCategory.
	self assert: p name isEmpty.
    ]

    testChangeCategory [
	<category: 'testing'>

	| p language implementation |
	p := ClassCategory new.
        ClassCategory extractCategory: CategoryB for: p into: CategoryB environment.
        ClassCategory extractCategory: CategoryC for: p into: CategoryC environment.
        (implementation := (language := p at: 'Language') at: 'Implementation') removeClass: CategoryB.
        self assert: implementation classes isEmpty.
        self assert: implementation parent isNil.
        self assert: language classes isEmpty.
        self assert: language parent isNil.
        self assert: (language categories includes: implementation) not.
        self assert: (p categories includes: language) not.
        self assert: (p categories includesKey: 'Foo').
    ]

    testUpdateCategory [
	<category: 'testing'>

	| p |
	p := CategoryC classCategory.
	self assert: (p classes includes: CategoryC).
	p removeClass: CategoryC.
	self assert: (p classes includes: CategoryC) not.
	self assert: p parent isNil.
        ClassCategory extractCategory: CategoryC for: CategoryC environment categories into: CategoryC environment.
	self assert: (((CategoryC environment categories at: 'Foo') at: 'Bar') classes includes: CategoryC)
    ]
]
PK
     �Mh@c2ʞ�  �    Tests/ExtractLiteralsTest.stUT	 fqXO�XOux �  �  Smalltalk.TestCase subclass: ExtractLiteralsTest [

    testObject [
	<category: 'testing'>

	| obj int dic |
	obj := Object new.
	int := 123.
	dic := Dictionary new.
	self assert: obj hasLiterals = false.
	self assert: int hasLiterals = false.
	self assert: dic hasLiterals = false.
    ]

    testSymbol [
	<category: 'testing'>

	self assert: #'at:put:' hasLiterals.
	self assert: #'at:put:' symbolFromliterals asArray = {#'at:put:'}
    ]

    testArray [
	<category: 'testing'>

	self assert: #(1 2 3) hasLiterals = false.
	self assert: #(1 'foo' #'at:put:') hasLiterals = true.
	self assert: #(1 'foo' #'at:put:') symbolFromliterals asArray = {#'at:put:'}
    ]
]
PK
     �Mh@i"_8	  8	    Tests/StateTest.stUT	 fqXO�XOux �  �  TestCase subclass: StateTest [

    testNamespaceState [
	<category: 'testing'>

	| st |
	st := NamespaceState on: self with: Kernel.
	self assert: st hasSelectedNamespace.
	self assert: st hasSelectedClass not.
	self assert: st hasSelectedCategory not.
	self assert: st hasSelectedMethod not.
	self assert: st namespace == Kernel.
	self assert: st classOrMeta isNil.
	self assert: st category isNil.
	self assert: st method isNil
    ]

    testClassState [
        <category: 'testing'>

        | st |
        st := ClassState on: self with: Object.
        self assert: st hasSelectedNamespace.
        self assert: st hasSelectedClass.
        self assert: st hasSelectedCategory not.
        self assert: st hasSelectedMethod not.
        self assert: st namespace == Smalltalk.
        self assert: st classOrMeta == Object.
        self assert: st category isNil.
        self assert: st method isNil
    ]

    testCategoryState [
        <category: 'testing'>

        | st |
        st := CategoryState on: self with: Object->'foo'.
        self assert: st hasSelectedNamespace.
        self assert: st hasSelectedClass.
        self assert: st hasSelectedCategory.
        self assert: st hasSelectedMethod not.
        self assert: st namespace == Smalltalk.
        self assert: st classOrMeta == Object.
        self assert: st category = 'foo'.
        self assert: st method isNil
    ]

    testMethodState [
        <category: 'testing'>

        | st |
        st := MethodState on: self with: Object>>#at:.
        self assert: st hasSelectedNamespace.
        self assert: st hasSelectedClass.
        self assert: st hasSelectedCategory.
        self assert: st hasSelectedMethod.
        self assert: st namespace == Smalltalk.
        self assert: st classOrMeta == Object.
        self assert: st category = 'built ins'.
        self assert: st method == (Object>>#at:)
    ]

    testBrowserState [
	<category: 'testing'>

	| st |
	st := BrowserState on: self with: 123.
        self assert: st hasSelectedNamespace not.
        self assert: st hasSelectedClass not.
        self assert: st hasSelectedCategory not.
        self assert: st hasSelectedMethod not.
        self assert: st namespace isNil.
        self assert: st classOrMeta isNil.
        self assert: st category isNil.
        self assert: st method isNil
    ]
]

PK
     �Mh@��9![  [  $  Tests/AddNamespaceUndoCommandTest.stUT	 fqXO�XOux �  �  TestCase subclass: AddNamespaceUndoCommandTest [

    testAddNamespace [
        <category: 'testing'>

        | cmd |
        cmd := AddNamespaceUndoCommand
                    add: #Kernel to: Smalltalk.
        self assert: cmd precondition not.

        cmd := AddNamespaceUndoCommand
                    add: #Object to: Smalltalk.
        self assert: cmd precondition not.

        cmd := AddNamespaceUndoCommand
                    add: #Foo to: Smalltalk.
        self assert: cmd precondition.

        cmd redo.
        self assert: (Smalltalk includesKey: #Foo).
        self assert: (Smalltalk at: #Foo) isNamespace.

        cmd undo.
        self assert: (Smalltalk includesKey: #Foo) not.

        cmd redo.
        self assert: (Smalltalk includesKey: #Foo).
        self assert: (Smalltalk at: #Foo) isNamespace.

        cmd undo
    ]
]

PK
     �Mh@d�ؾ  �  *  Tests/GtkCategorizedNamespaceWidgetTest.stUT	 fqXO�XOux �  �  TestCase subclass: GtkCategorizedNamespaceWidgetTest [

    | changed |

    namespaceChanged [

        changed := true
    ]

    testModelBuilding [
        <category: 'testing'>

        | namespace |
        namespace := GtkCategorizedNamespaceWidget new.
        namespace mainWidget: namespace buildTreeView
    ]

    testState [
        <category: 'testing'>

        | namespace |
        namespace := GtkCategorizedNamespaceWidget new.
        namespace mainWidget: namespace buildTreeView.
        self assert: namespace state namespace isNil.
        self assert: namespace state classOrMeta isNil.
        self assert: namespace state category isNil.
        self assert: namespace state method isNil.
	namespace selectANamespace: Kernel.
        self assert: namespace state namespace == Kernel.
        self assert: namespace state classOrMeta isNil.
        self assert: namespace state category isNil.
        self assert: namespace state method isNil
    ]

    testSelectionEvents [

        | namespace |
        namespace := GtkCategorizedNamespaceWidget new.
        namespace mainWidget: namespace buildTreeView.
        self assert: namespace hasSelectedNamespace not.
        self should: [ namespace selectedNamespace ] raise: Error.
        namespace selectANamespace: Kernel.
        self assert: namespace hasSelectedNamespace.
        self assert: namespace selectedNamespace == Kernel
    ]

    testConnectionEvents [

        | namespace |
        namespace := GtkCategorizedNamespaceWidget new.
        namespace 
	    mainWidget: namespace buildTreeView;
            whenSelectionChangedSend: #namespaceChanged to: self;
	    selectANamespace: Kernel.
        self assert: changed
    ]
]

PK
     �Mh@y��}P  P     Tests/AddClassUndoCommandTest.stUT	 fqXO�XOux �  �  TestCase subclass: AddClassUndoCommandTest [

    testAddClass [
	<category: 'testing'>

	| cmd |
	cmd := AddClassUndoCommand 
		    add: #Object to: Smalltalk classCategory: 'bar' withSuperclass: Object.
	self assert: cmd precondition not.
	cmd := AddClassUndoCommand 
		    add: #Foo to: Smalltalk classCategory: Object classCategory withSuperclass: Object.
	self assert: cmd precondition.
	cmd redo.
	self assert: (Smalltalk includesKey: #Foo).
	self assert: (Smalltalk at: #Foo) superclass == Object.
	self assert: (Smalltalk at: #Foo) classCategory == Object classCategory.

	cmd undo.
	self assert: (Smalltalk includesKey: #Foo) not.

	cmd redo.
	self assert: (Smalltalk includesKey: #Foo).
	self assert: (Smalltalk at: #Foo) superclass == Object.
	self assert: (Smalltalk at: #Foo) classCategory == Object classCategory.

	cmd undo
    ]
]

PK
     �Mh@
���  �    Tests/GtkConcreteWidgetTest.stUT	 fqXO�XOux �  �  TestCase subclass: GtkConcreteWidgetTest [

    | show |

    showAll [

	show := true
    ]

    hideAll [

	show := false
    ]

    getVisible [
	
	^ false
    ]

    testAbstractWidget [
	<category: 'testing'>

	self should: [ GtkAbstractConcreteWidget new hideAll. true ]
    ]

    testConcreteWidget [
	<category: 'testing'>

	| widget |
	widget := GtkConcreteWidget parentWindow: #foo.
	self assert: widget parentWindow = #foo.
	widget mainWidget: self.
	self assert: widget mainWidget = self.
	widget showAll.
	self assert: show.
	widget hideAll.
	self assert: show not.
	self assert: widget isVisible not.
	self should: [ widget grabFocus. true ].
	self should: [ widget close. true].
    ]
]

PK
     �Mh@Y�#;�  �    Tests/PragmaTest.stUT	 fqXO�XOux �  �  TestCase subclass: PragmasTest [

    testNamespaceExtend [
	<category: 'testing'>
   
	self assert: Smalltalk namespaceExtends isEmpty.
	self assert: Kernel namespaceExtends isEmpty.
	self assert: Kernel namespaceExtends ~~ Smalltalk namespaceExtends
    ]

    testPragma [
	<category: 'testing'>

	| behavior |
	behavior := Behavior new.
	Smalltalk addSubspace: #Foo.
	behavior superclass: Object.
	behavior compile: 'test [ <namespace: Foo classCategory: ''foo-bar'' category: ''xork''> ]'.
	self assert: (behavior>>#test) methodCategory = 'xork'.
	self assert: (((Smalltalk at: #Foo) namespaceExtends at: 'foo-bar') includes: (behavior>>#test)).
	behavior compile: 'test [ <namespace: Foo category: ''bar''> ]'.
	self assert: (behavior>>#test) methodCategory = 'bar'.
	self assert: (((Smalltalk at: #Foo) namespaceExtends at: '') includes: (behavior>>#test)).
	Smalltalk removeSubspace: #Foo
    ]
]

PK
     �Mh@1�z  z    Tests/GtkCategoryWidgetTest.stUT	 fqXO�XOux �  �  TestCase subclass: GtkCategoryWidgetTest [

    | changed |

    categoryChanged [

	changed := true
    ]

    testModelBuilding [
	<category: 'testing'>

	| category |
	category := GtkCategoryWidget new.
	category
	    mainWidget: category buildTreeView;
	    initializeCategories;
	    classOrMeta: Object
    ]

    testState [
        <category: 'testing'>

	| category |
	category := GtkCategoryWidget new.
	category
	    mainWidget: category buildTreeView;
	    initializeCategories;
	    classOrMeta: Object.
        self assert: category state namespace == Smalltalk.
        self assert: category state classOrMeta == Object.
	category selectACategory: 'built ins'.
        self assert: category state namespace == Smalltalk.
        self assert: category state classOrMeta == Object
    ]

    testSelectionEvents [

        | category |
        category := GtkCategoryWidget new.
        category
            mainWidget: category buildTreeView;
            initializeCategories;
            classOrMeta: Object.
        self assert: category hasSelectedCategory not.
        self should: [ category selectedCategory ] raise: Error.
	category selectACategory: 'built ins'.
        self assert: category hasSelectedCategory.
        self assert: category selectedCategory = 'built ins'
    ]

    testConnectionEvents [

        | category |
        category := GtkCategoryWidget new.
        category
            mainWidget: category buildTreeView;
            initializeCategories;
	    whenSelectionChangedSend: #categoryChanged to: self;
            classOrMeta: Object;
	    selectACategory: 'built ins'.
        self assert: changed
    ]
]

PK
     �Mh@�~�#  #    Tests/MenuBuilderTest.stUT	 fqXO�XOux �  �  Command subclass: FakeCommandA [

    item [
	^ 'FakeA'
    ]
]

Command subclass: FakeCommandB [

    item [
        ^ 'FakeB'
    ]
]

MenuBuilder subclass: TestMenuBuilderA [

    TestMenuBuilderA class >> menus [

        ^ {FakeCommandA.
        MenuSeparator.
	FakeCommandB}
    ]

]

TestCase subclass: MenuBuilderTest [

    | accelGroup |

    accelGroup [
        <category: 'accessing'>

        ^ accelGroup ifNil: [ accelGroup := GTK.GtkAccelGroup new ]
    ]

    accelPath [
        <category: 'accelerator path'>

        ^ '<Assistant>'
    ]

    testMenuBuilder [
	<category: 'testing'>

	| menu result |
	menu := TestMenuBuilderA browserBuildOn: self.
	result := #('FakeA' '' 'FakeB').
	1 to: result size do: [ :i |
	    self assert: (menu at: i) getLabel = (result at: i) ]
    ]
]
PK
     �Mh@�V�  �     Tests/GtkScrollTreeWidgetTest.stUT	 fqXO�XOux �  �  TestCase subclass: GtkScrollTreeWidgetTest [

    testAccessing [
	<category: 'testing'>

	| widget |
	widget := GtkScrollTreeWidget basicNew.
	widget treeView: 123.
	self assert: widget treeView = 123
    ]

    testPopupConnection [
	<category: 'testing'>

        | widget |
        widget := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'aString'}}.
    ]
]

PK
     �Mh@�D���  �  &  Tests/GtkCategorizedClassWidgetTest.stUT	 fqXO�XOux �  �  TestCase subclass: GtkCategorizedClassWidgetTest [

    | changed |

    classChanged [

        changed := true
    ]

    testModelBuilding [
        <category: 'testing'>

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: ''
    ]

    testState [
        <category: 'testing'>

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: nil category: ''.
	self assert: class state namespace isNil.
	self assert: class state classOrMeta isNil.
	self assert: class state category isNil.
	self assert: class state method isNil.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: ''.
        self assert: class state namespace == Kernel.
        self assert: class state classCategory fullname = ''.
	self assert: class state classOrMeta isNil.
        self assert: class state category isNil.
        self assert: class state method isNil.
	class selectAClass: Kernel.CollectingStream class.
        self assert: class state namespace == Kernel.
        self assert: class state classCategory fullname = 'Examples-Useful tools'.
        self assert: class state classOrMeta == Kernel.CollectingStream.
        self assert: class state category isNil.
        self assert: class state method isNil
    ]

    testSelectionEvents [

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: ''.
        self assert: class hasSelectedClass not.
        self should: [ class selectedClass ] raise: Error.
	class selectAClass: Kernel.CollectingStream class.
        self assert: class hasSelectedClass.
        self assert: class selectedClass == Kernel.CollectingStream
    ]

    testConnectionEvents [

        | class |
        class := GtkCategorizedClassWidget new.
        class
            mainWidget: class buildTreeView;
            namespace: Kernel category: '';
            whenSelectionChangedSend: #classChanged to: self;
            selectAClass: Kernel.CollectingStream class.
        self assert: changed
    ]

    testNotification [
	<category: 'testing'>

        | widget notifier |
        widget := GtkCategorizedClassWidget new.
	widget
            mainWidget: widget buildTreeView;
            namespace: Smalltalk category: ''.

	notifier := SystemChangeNotifier new.
	notifier
            notify: widget ofSystemChangesOfItem: #class change: #Added using: #'addEvent:';
            notify: widget ofSystemChangesOfItem: #class change: #Removed using: #'removeEvent:';
            notify: widget ofSystemChangesOfItem: #class change: #Recategorized using: #'recategorizedEvent:';
            notify: widget ofSystemChangesOfItem: #class change: #Modified using: #'modificationEvent:'.

	"Object subclass: #TestA.
	widget selectAClass: TestA"
    ]
]

PK
     �Mh@3���      Tests/FinderTest.stUT	 fqXO�XOux �  �  TestCase subclass: FinderTest [

    | namespace class imethod cmethod |

    selectANamespace: anObject [

	namespace := anObject
    ]

    selectAClass: anObject [

        class := anObject
    ]

    selectAnInstanceMethod: anObject [

	imethod := anObject
    ]

    selectAClassMethod: anObject [

	cmethod := anObject
    ]

    testAbstractFinder [
	<category: 'testing'>

	| finder |
	finder := AbstractFinder new.
	self should: [ finder updateBrowser: nil ] raise: Error.
	self should: [ finder element ] raise: Error
    ]

    testNamespaceFinder [
	<category: 'testing'>

        | finder |
        finder := NamespaceFinder on: Smalltalk.
	self assert: finder displayString = 'Smalltalk'.
        finder updateBrowser: self.
	self assert: namespace == Smalltalk.
	self assert: finder element == Smalltalk.
	finder namespace: Kernel.
	self assert: finder element == Kernel
    ]

    testClassFinder [
        <category: 'testing'>
    
        | finder |
        finder := ClassFinder on: Object.
        self assert: finder displayString = 'Object'.
        finder updateBrowser: self.
        self assert: namespace == Smalltalk.
        self assert: class == Object.
        self assert: finder element == Object.
        finder class: String class.
        self assert: finder element == String class
    ]

    testMethodFinder [
        <category: 'testing'>

        | finder |
        finder := MethodFinder on: Object with: #at:.
        self assert: finder displayString = 'Object >> #at:'.
        finder updateBrowser: self.
        self assert: namespace == Smalltalk.
        self assert: class == Object.
        self assert: imethod == #at:.
        self assert: finder element == #at:.

        finder := MethodFinder on: String class with: #new:.
        self assert: finder displayString = 'String class >> #new:'.
        finder updateBrowser: self.
        self assert: namespace == Smalltalk.
        self assert: class == String.
        self assert: cmethod == #new:.
        self assert: finder element == #new:
    ]
]

PK
     �Mh@^����   �      Tests/GtkSimpleListWidgetTest.stUT	 fqXO�XOux �  �  TestCase subclass: GtkSimpleListWidgetTest [

    testInstanceCreation [
	<category: 'testing'>

	| widget |
	widget := GtkSimpleListWidget named: 'foo'.
	self assert: widget treeView isNil not
    ]
]

PK
     �Mh@��,  ,    Tests/GtkAssistantTest.stUT	 fqXO�XOux �  �  TestCase subclass: GtkAssistantTest [

    testAssistant [
	<category: 'testing'>

	| assistant |
	assistant := GtkAssistant new.
	self assert: assistant windowTitle isString.
	self assert: assistant aboutTitle isString.
	self assert: (assistant hasChanged or: [ assistant hasChanged not ])
    ]
]

PK
     �Mh@��3�   �     Tests/EmptyTest.stUT	 fqXO�XOux �  �  Smalltalk.TestCase subclass: EmptyTest [

    testA [
	<category: 'testing'>

    ]

    testB [
	<category: 'testing'>

    ]

    testC [
	<category: 'testing'>

    ]
]
PK
     �Mh@2)�8  8    Tests/CompiledMethodTest.stUT	 fqXO�XOux �  �  TestCase subclass: CompiledMethodTest [

    testOverride [
	<category: 'testing'>

	self assert: (String>>#at:) override.
	self assert: (Object>>#at:) override not.
    ]

    testOverridden [
        <category: 'testing'>

        self assert: (SmallInteger>>#at:) overridden not.
        self assert: (Object>>#at:) overridden
    ]

    testoverrideIcon [
        <category: 'testing'>

	self assert: CompiledMethod overrideIcon isNil not
    ]

    testoverridenIcon [
        <category: 'testing'>

	self assert: CompiledMethod overriddenIcon isNil not
    ]
]

PK
     �Mh@!3<�'  '    Tests/GtkMethodWidgetTest.stUT	 fqXO�XOux �  �  TestCase subclass: GtkMethodWidgetTest [

    | changed |

    methodChanged [

	changed := true
    ]

    testModelBuilding [
	<category: 'testing'>

	| method |
	method := GtkMethodWidget new.
	method mainWidget: method buildTreeView.
	method class: Object withCategory: 'built ins'.
	self assert: method selectedCategory = 'built ins'
    ]

    testState [
        <category: 'testing'>

        | method |
        method := GtkMethodWidget new.
        method mainWidget: method buildTreeView.
        method class: Object withCategory: 'built ins'.
        self assert: method state namespace isNil.
        self assert: method state classOrMeta isNil.
        self assert: method state method isNil.
	method selectAMethod: #'at:'.
        self assert: method state namespace == Smalltalk.
        self assert: method state classOrMeta == Object.
        self assert: method state method == (Object>>#'at:').
    ]

    testSelectionEvents [

        | method |
        method := GtkMethodWidget new.
        method mainWidget: method buildTreeView.
        method class: Object withCategory: 'built ins'.
        self assert: method hasSelectedMethod not.
        self should: [ method selectedMethod ] raise: Error.
        self should: [ method sourceCode ] raise: Error.
	method selectAMethod: #'at:'.
        self assert: method hasSelectedMethod.
        self assert: method selectedMethod == (Object>>#'at:').
        self assert: method sourceCode = (Object>>#'at:') methodRecompilationSourceString.
    ]

    testConnectionEvents [

        | method |
        method := GtkMethodWidget new.
        method 
	    mainWidget: method buildTreeView;
	    whenSelectionChangedSend: #methodChanged to: self;
	    class: Object withCategory: 'built ins';
	    selectAMethod: #'at:'.
        self assert: changed
    ]
]

PK
     %\h@              Model/UT	 �XO�XOux �  �  PK
     �Mh@Z��  �    Model/GtkColumnOOPType.stUT	 eqXO�XOux �  �  GtkColumnType subclass: GtkColumnOOPType [

    GtkColumnOOPType class >> kind [
	<category: 'accessing'>

	^ GLib.GType oopType
    ]

    GtkColumnOOPType class >> kindName [
        <category: 'accessing'>

        ^ self error: 'OOP type should not be displayed'
    ]

    GtkColumnOOPType class >> cellRenderer [
        <category: 'accessing'>

        ^ self error: 'OOP type has no cell renderer'
    ]
]

PK
     �Mh@���M  M    Model/GtkColumnType.stUT	 eqXO�XOux �  �  Object subclass: GtkColumnType [
    | visible title |

    GtkColumnType class >> kind [
	<category: 'accessing'>

	^ self subclassResponsibility
    ]

    GtkColumnType class >> kindName [
        <category: 'accessing'>

        ^ self subclassResponsibility
    ]

    GtkColumnType class >> cellRenderer [
	<category: 'accessing'>

	^ self subclassResponsibility
    ]

    GtkColumnType class >> new [
	<category: 'instance creation'>

	^ self error: 'should not call new'
    ]

    GtkColumnType class >> hidden [
        <category: 'instance creation'>

        ^ self basicNew
            initialize;
            yourself
    ]

    GtkColumnType class >> visible [
        <category: 'instance creation'>

        ^ self basicNew
            initialize;
	    visible: true;
            yourself
    ]

    GtkColumnType class >> title: aString [
	<category: 'instance creation'>

	^ self basicNew
	    title: aString;
	    visible: true;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	visible := false
    ]

    kind [
	<category: 'accessing'>

	^ self class kind
    ]

    kindName [
        <category: 'accessing'>

        ^ self class kindName
    ]

    cellRenderer [
        <category: 'accessing'>

        ^ self class cellRenderer
    ]

    visible: aBoolean [
	<category: 'accessing'>

	visible := aBoolean
    ]

    isVisible [
	<category: 'testing'>

	^ visible
    ]

    hasTitle [
	<category: 'testing'>

	^ title isNil not
    ]

    title: aString [
	<category: 'accessing'>

	title := aString
    ]

    title [
	<category: 'accessing'>

	^ title
    ]
]
PK
     �Mh@�l�v  v    Model/GtkColumnPixbufType.stUT	 eqXO�XOux �  �  GtkColumnType subclass: GtkColumnPixbufType [

    GtkColumnPixbufType class >> kind [
	<category: 'accessing'>

	^ GTK.GdkPixbuf getType
    ]

    GtkColumnPixbufType class >> kindName [
        <category: 'accessing'>

        ^ 'pixbuf'
    ]

    GtkColumnPixbufType class >> cellRenderer [
        <category: 'accessing'>

        ^ GTK.GtkCellRendererPixbuf
    ]
]

PK
     �Mh@�by�k  k    Model/GtkColumnTextType.stUT	 eqXO�XOux �  �  GtkColumnType subclass: GtkColumnTextType [

    GtkColumnTextType class >> kind [
	<category: 'accessing'>

	^ GTK.GValue gTypeString
    ]

    GtkColumnTextType class >> kindName [
        <category: 'accessing'>

        ^ 'text'
    ]

    GtkColumnTextType class >> cellRenderer [
        <category: 'accessing'>

        ^ GTK.GtkCellRendererText
    ]
]

PK
     %\h@              Image/UT	 �XO�XOux �  �  PK
     �Mh@���  �    Image/GtkImageWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkImageWidget [

    | imageTree image model searchEntry |


    initialize [
	<category: 'initialization'>

	self mainWidget: self buildMainWidget
    ]

    buildMainWidget [
        <category: 'user interface'>

        ^ GTK.GtkVPaned new
            add1: self buildFinderEntry;
            add2: self buildClassAndMethodList;
            yourself
    ]

    buildFinderEntry [
        <category: 'user interface'>

        searchEntry := GTK.GtkEntry new
			    connectSignal: 'activate' to: self selector: #searchValidate;
			    yourself.
        ^ (GTK.GtkHBox new: true spacing: 3)
            add: (GTK.GtkLabel new: 'Class or method :');
            add: searchEntry;
            yourself
    ]

    buildClassAndMethodList [
        <category: 'user interface'>

        imageTree := (GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: 'Methods and Classes'}}).
        imageTree setSearchEntry: searchEntry.
        [ (model := GtkListModel on: imageTree getModel)
					item: (image := GtkImage new);
                                        contentsBlock: [ :each | {each displayString} ];
					refresh ] fork.
        ^ GTK.GtkScrolledWindow withChild: imageTree
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        imageTree getSelection
            connectSignal: 'changed' to: anObject selector: aSelector
    ]

    whenTextChangedSend: aSelector to: anObject [
	<category: 'events'>

        searchEntry connectSignal: 'activate' to: anObject selector: aSelector
    ]

    grabFocus [
	<category: 'focus events'>

	searchEntry grabFocus
    ]

    text [
	<category: 'accessing'>

	^ searchEntry getText
    ]

    searchValidate [
	<category: 'search entry events'>

	searchEntry getText isEmpty 
		    ifTrue: [ model item: image ]
		    ifFalse: [ model item: (image matchRegex: searchEntry getText) ].
	model refresh
    ]

    hasSelection [
	<category: 'accessing'>

	^ imageTree hasSelectedItem
    ]

    selection [
	<category: 'accessing'>

        self hasSelection ifFalse: [ ^ self error: 'Nothing is selected' ].
        ^ imageTree selection
    ]

    matchSelector: aSymbol [
	<category: 'matching'>

	^ image matchSelector: aSymbol
    ]
]

PK
     �Mh@L�f�      Image/GtkImageModel.stUT	 eqXO�XOux �  �  Object subclass: GtkImage [

    GtkImage class >> new [
	<category: 'instance creation'>

	^ self basicNew
		initialize;
		yourself
    ]

    | finderDic |

    initialize [
	<category: 'initialize-release'>

	finderDic := Dictionary new.
	self
	    registerNotifier;
            buildNamespaceModel;
            buildClassModel;
            buildMethodModel
    ]

    registerNotifier [
	<category: 'initialize-release'>

	(GtkLauncher uniqueInstance systemChangeNotifier)
	    notify: self ofSystemChangesOfItem: #namespace change: #Added using: #'addNamespaceEvent:';
	    notify: self ofSystemChangesOfItem: #namespace change: #Removed using: #'removeNamespaceEvent:';
	    notify: self ofSystemChangesOfItem: #class change: #Added using: #'addClassEvent:';
	    notify: self ofSystemChangesOfItem: #class change: #Removed using: #'removeClassEvent:';
	    notify: self ofSystemChangesOfItem: #method change: #Added using: #'addMethodEvent:';
	    notify: self ofSystemChangesOfItem: #method change: #Removed using: #'removeMethodEvent:'
    ]

    buildNamespaceModel [
        <category: 'model builder'>

        self appendNamespace: Smalltalk
    ]

    appendNamespace: aNamespace [
        <category: 'model builder'>

	| namespace |
        finderDic at: aNamespace displayString ifAbsentPut: [ Dictionary new ].
	self at: aNamespace displayString addToFinder: (NamespaceFinder on: aNamespace).

        aNamespace subspacesDo: [ :each | self appendNamespace: each ].
	Processor activeProcess yield
    ]

    buildClassModel [
        <category: 'model builder'>

        | class string |
        Class allSubclassesDo: [ :each |
	    Processor activeProcess yield.
            string := each asClass name asString, ' '.
            finderDic at: string ifAbsentPut: [ Dictionary new ].
	    self at: string addToFinder: (ClassFinder on: each) ]
    ]

    buildMethodModel [
        <category: 'model builder'>

	| method |
        CompiledMethod allInstancesDo: [ :each | | selector |
	    Processor activeProcess yield.
            selector := each selector asString.
            finderDic at: selector ifAbsentPut: [ Dictionary new ].
	    self at: selector addToFinder: (MethodFinder on: each methodClass with: each selector) ]
    ]

    at: aSelector addToFinder: aFinderObject [
	<category: 'finder accessing'>

	(finderDic at: aSelector)
                at: aFinderObject displayString
                put: aFinderObject
    ]

    matchSelector: aSymbol [
	<category: 'item selection'>

        ^ finderDic at: aSymbol asString ifAbsent: [ self error: 'Element not found' ].
    ]

    matchRegex: aString [
	<category: 'item selection'>

	| result |
	result := Dictionary new.
	finderDic keysAndValuesDo: [ :key :value |
	    (key matchRegex: aString) ifTrue: [ result at: key put: value ] ].
	^ (self class new)
	    image: result;
	    registerNotifier;
	    yourself
    ]

    image: aDictionary [
	<category:'accessing'>

	finderDic := aDictionary
    ]

    do: aBlock [
	<category: 'model'>

	(finderDic keys asArray "sort: [ :a :b | a <= b ]") do: aBlock
    ]

    addNamespaceEvent: anEvent [
	<category: 'events'>

        finderDic at: anEvent item displayString ifAbsentPut: [ Dictionary new ].
	self at: anEvent item displayString addToFinder: (NamespaceFinder on: anEvent item).
    ]

    removeNamespaceEvent: anEvent [
	<category: 'events'>
    ]

    addClassEvent: anEvent [
	<category: 'events'>

	| string |
        string := ((anEvent item displayString) substrings: $.) last.
        finderDic at: string ifAbsentPut: [ Dictionary new ].
	self at: string addToFinder: (ClassFinder on: anEvent item) 
    ]

    removeClassEvent: anEvent [
	<category: 'events'>
    ]

    addMethodEvent: anEvent [
	<category: 'events'>
    ]

    removeMethodEvent: anEvent [
	<category: 'events'>
    ]
]
PK
     �Mh@z�"p�  �    GtkEntryDialog.stUT	 eqXO�XOux �  �  Object subclass: GtkEntryDialog [
    | dialog labelWidget entryWidget hasPressedOk buttons defaultButton |

    GtkEntryDialog class >> title: aTitle text: aDescription [
	<category: 'instance creation'>

	^ (self new)
	    title: aTitle text: aDescription;
	    yourself
    ]

    beOkCancel [
        buttons := #( ('Ok' #gtkResponseOk) ('Cancel' #gtkResponseCancel))
    ]

    beYesNo [
        buttons := #( ('Yes' #gtkResponseYes) ('No' #gtkResponseNo))
    ]

    title: aTitle text: aDescription [
	<category: 'initialization'>

	hasPressedOk := false.
	dialog := GTK.GtkDialog newWithButtons: aTitle parent: nil flags: 0 varargs: {nil}.
	self buildCentralWidget: aDescription on: dialog.
	"dialog showModalOnAnswer: [ :dlg :res |
		res = GTK.Gtk gtkResponseYes ifTrue: [ hasPressedOk := true ].
		dlg destroy ]"
    ]

    hasPressedOk: aBlock [
	<category: 'testing'>

        dialog showModalOnAnswer: [ :dlg :res |
                res = defaultButton ifTrue: [ aBlock value ].
                dlg destroy ]
    ]

    result [
	<category: 'accessing'>

	^ entryWidget getText
    ]

    buildCentralWidget: aString on: aGtkDialog [
	<category: 'user interface'>

	| hbox |
        buttons isNil ifTrue: [ self beOkCancel ].
        buttons do: [ :each |
	    aGtkDialog addButton: each first responseId: (GTK.Gtk perform: each second) ].

        defaultButton := GTK.Gtk perform: buttons first second.
        aGtkDialog setDefaultResponse: defaultButton.
	hbox := GTK.GtkHBox new: true spacing: 0.
	labelWidget := GTK.GtkLabel new: aString.
	entryWidget := GTK.GtkEntry new.
        entryWidget setActivatesDefault: true.
	hbox
	    add: labelWidget;
	    add: entryWidget;
	    showAll.
	aGtkDialog getVBox add: hbox
    ]
]

PK
     �Mh@��ƣ�  �    SyntaxHighlighter.stUT	 fqXO�XOux �  �  STInST.STInST.RBProgramNodeVisitor subclass: SyntaxHighlighter [
    | textBuffer variable |
    
    <category: 'Graphics-Browser'>
    <comment: nil>

    SyntaxHighlighter class >> highlight: node in: aGtkTextBuffer [
	<category: 'instance creation'>

	(self new)
	    initialize;
	    textBuffer: aGtkTextBuffer;
	    visitNode: node;
	    acceptComments: node comments
    ]

    initialize [
	<category: 'initialize-release'>

	variable := Dictionary new.
	variable
	    at: 'self' put: #specialId;
	    at: 'super' put: #specialId;
	    at: 'thisContext' put: #specialId
    ]

    textBuffer: aGtkTextBuffer [
	<category: 'initialize-release'>

	textBuffer := aGtkTextBuffer
    ]

    acceptComments: anArray [
	<category: 'visitor-double dispatching'>

	anArray ifNil: [ ^ self ].
	anArray do: [ :each |
	    textBuffer applyTagByName: #comment startOffset: (each first - 1) endOffset: each last ]
    ]

    acceptArrayNode: anArrayNode [
	<category: 'visitor-double dispatching'>

	self visitNode: anArrayNode body
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>

	self acceptVariableNode: anAssignmentNode variable.
	self visitNode: anAssignmentNode value
    ]

    acceptBlockNode: aBlockNode [
	<category: 'visitor-double dispatching'>

	aBlockNode colons with: aBlockNode arguments
	    do: [ :colonPos :argument | 
		self highlightNewVariable: argument as: #arguments ].

	self visitNode: aBlockNode body
    ]

    acceptCascadeNode: aCascadeNode [
	<category: 'visitor-double dispatching'>

	| n |
	n := 0.
	self visitNode: aCascadeNode messages first receiver.
	aCascadeNode messages do: [ :each | 
		self highlightMessageSend: each ]
    ]

    acceptLiteralNode: aLiteralNode [
	<category: 'visitor-double dispatching'>

	textBuffer applyTagByName: #literal startOffset: (aLiteralNode start - 1) endOffset: aLiteralNode stop
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
		[ textBuffer applyTagByName: #unaryMsg startOffset: (aMethodNode selectorParts first start - 1) endOffset: aMethodNode selectorParts first stop ].
	aMethodNode isBinary 
	    ifTrue: 
		[ textBuffer applyTagByName: #binaryMsg startOffset: (aMethodNode selectorParts first start - 1) endOffset: aMethodNode selectorParts first stop.
		self highlightNewVariable: aMethodNode arguments first as: #arguments ].
	aMethodNode isKeyword 
	    ifTrue: 
		[ aMethodNode selectorParts with: aMethodNode arguments
		    do: [ :sel :arg | 
			textBuffer applyTagByName: #binaryMsg startOffset: (sel start - 1) endOffset: sel stop.
			self highlightNewVariable: arg as: #arguments ] ].
	self visitNode: aMethodNode body
    ]

    acceptOptimizedNode: aBlockNode [
	<category: 'visitor-double dispatching'>

	self visitNode: aBlockNode body
    ]

    acceptReturnNode: aReturnNode [
	<category: 'visitor-double dispatching'>

	self visitNode: aReturnNode value
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>

	| n |
	n := 0.
	aSequenceNode temporaries do: [ :temporary | 
	    self highlightNewVariable: temporary as: #temporary].
	aSequenceNode statements do: [ :each |
	    self visitNode: each ]
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>

	| tag |
	tag := variable at: aVariableNode name ifAbsentPut: [ #undeclaredVar ].
	textBuffer applyTagByName: tag startOffset: (aVariableNode start - 1) endOffset: aVariableNode stop
    ]

    highlightMessageSend: aMessageNode [
	<category: 'visitor-double dispatching'>

	aMessageNode isUnary 
	    ifTrue: 
		[ textBuffer applyTagByName: #unaryMsg startOffset: (aMessageNode selectorParts first start - 1) endOffset: aMessageNode selectorParts first stop ].
	aMessageNode isBinary 
	    ifTrue: 
		[ textBuffer applyTagByName: #binaryMsg startOffset: (aMessageNode selectorParts first start - 1) endOffset: aMessageNode selectorParts first stop.
		self visitNode: aMessageNode arguments first ].
	aMessageNode isKeyword
	    ifTrue: [
		aMessageNode selectorParts with: aMessageNode arguments
		    do: [ :sel :arg |
			textBuffer applyTagByName: #binaryMsg startOffset: (sel start - 1) endOffset: sel stop.
			self visitNode: arg ] ]
    ]

    highlightNewVariable: node as: kind [
	<category: 'visitor-double dispatching'>

	variable at: node name ifAbsentPut: [ kind ].
	textBuffer applyTagByName: kind startOffset: (node start - 1) endOffset: node stop
    ]
]

PK
     �Mh@Kh��  �    GtkVariableTrackerWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkVariableTrackerWidget [
    | model object widget |

    GtkVariableTrackerWidget class >> on: anObject [
	<category: 'instance creation'>

	^ self new
		initialize;
		object: anObject;
		yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildListView
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject.
	self refresh
    ]

    buildListView [
	<category: 'user interface'>

        widget := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'Variable'}. {GtkColumnTextType title: 'Value'}}.
        widget connectToWhenPopupMenu: (WorkspaceVariableMenus on: self).
        widget treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkListModel on: widget treeView getModel)
                                        contentsBlock: [ :each | {each asString. (object instVarNamed: each) displayString} ].
        ^ widget mainWidget
    ]

    refresh [
	<category: 'user interface'>

	model
	    item: object class allInstVarNames;
	    refresh
    ]

    targetObject [
        <category: 'evaluation'>

        ^ object instVarNamed: self selectedValue
    ]

    hasSelectedValue [
        <category: 'smalltalk event'>

        ^widget treeView hasSelectedValue
    ]

    selectedValue [
        <category: 'smalltalk event'>

        ^widget treeView selection
    ]

    inspectIt: anObject [
        <category: 'smalltalk event'>

        GtkInspector openOn: anObject
    ]

    deleteVariable [
	<category: 'event'>

	| ivar |
	widget treeView hasSelectedValue ifFalse: [ ^ self ].
	ivar := self selectedValue.
	model remove: ivar.
	object class removeInstVarName: ivar.
    ]
]

PK
     %\h@            	  Category/UT	 �XO�XOux �  �  PK
     �Mh@a�x[�  �    Category/AbstractNamespace.stUT	 eqXO�XOux �  �  AbstractNamespace class extend [
    Icon := nil.
    Categories := nil.

    categories [
        <category: '*VisualGST'>

        ^ Categories ifNil: [ Categories := WeakKeyIdentityDictionary new ]
    ]

    icon [
        <category: '*VisualGST'>

        ^ Icon ifNil: [ Icon := GTK.GdkPixbuf newFromFile: (VisualGST.GtkLauncher / 'Icons/namespace.gif') file displayString error: nil ]
    ]

    icon: aGdkPixbuf [
        <category: '*VisualGST'>

        Icon := aGdkPixbuf
    ]
]

AbstractNamespace extend [

    namespace [
	<category: 'accessing'>

	^ self
    ]

    category [
	<category: 'accessing'>

	^ VisualGST.ClassCategory basicNew
    ]

    categories [
	<category: 'accessing'>

        ^ self class categories at: self
            ifAbsentPut: [ VisualGST.ClassCategory for: self ]
    ]

    icon [
        <category: '*VisualGST'>

        ^ self class icon
    ]

    isCategory [
	<category: 'testing'>

	^ false
    ]
]

PK
     �Mh@Ic���  �    Category/ClassCategory.stUT	 eqXO�XOux �  �  Object subclass: ClassCategory [
    | categories classes name namespace parent |

    <category: 'Language-Implementation'>

    ClassCategory class [ | icon | ]

    ClassCategory class >> icon [
	<category: '*VisualGST'>
	
	^ icon ifNil: [ icon := GTK.GdkPixbuf newFromFile: (GtkLauncher / 'Icons/category.gif') file displayString error: nil ]
    ]

    ClassCategory class >> icon: aGdkPixbuf [
        <category: '*VisualGST'>

        icon := aGdkPixbuf
    ]

    ClassCategory class >> namespace: aNamespace [
        <category: 'instance creation'>

        ^ self basicNew
		    namespace: aNamespace;
		    yourself
    ]

    ClassCategory class >> named: aString [
	<category: 'instance creation'>

	^ self named: aString parent: nil 
    ]

    ClassCategory class >> named: aString parent: aClassCategory [
        <category: 'instance creation'>

	^ self named: aString parent: aClassCategory namespace: nil 
    ]

    ClassCategory class >> named: aString parent: aClassCategory namespace: aNamespace [
        <category: 'instance creation'>

        ^ self basicNew
                    name: aString;
                    parent: aClassCategory;
		    namespace: aNamespace;
                    yourself
    ]

    ClassCategory class >> for: aNamespace [
	<category: 'instance creation'>

	| category classes |
	category := self namespace: aNamespace.
        classes := aNamespace definedKeys.
        classes do: [ :each | (aNamespace at: each) isClass ifTrue: [ self extractCategory: (aNamespace at: each) for: category into: aNamespace ] ].
	^ category 
    ]

    ClassCategory class >> named: name for: aParentCategory into: aNamespace [
	<category: 'instance creation'>

        | token category |
        token := name ifNil: [ #() ] ifNotNil: [ (name tokenize: '-') asOrderedCollection ].
        category := aParentCategory.
	token isEmpty ifFalse: [ token first = aNamespace name asString ifTrue: [ token removeFirst ] ].
        token do: [ :each |
            category at: each ifAbsentPut: [ self named: each parent: category namespace: aNamespace ].
            category := category at: each ].
        ^category
    ]

    ClassCategory class >> named: name into: aNamespace [
	<category: 'instance creation'>

        ^ self named: name for: aNamespace categories into: aNamespace
    ]

    ClassCategory class >> extractCategory: aClass for: aParentCategory into: aNamespace [
        <category: 'extraction'>

	| cat |
        (cat := (self named: aClass category for: aParentCategory into: aNamespace)) classes add: aClass asClass.
	^ cat
    ]

    ClassCategory class >> extractClassCategory: aClass [
        <category: 'extraction'>

	^ self extractCategory: aClass for: aClass environment categories into: aClass environment
    ]

    = anObject [
        <category: 'testing'>
    
        ^ self class == anObject class and: [
	   self parent == anObject parent and: [
           self namespace == anObject namespace and: [
           self name = anObject name ]]]
    ]

    hash [
        <category: 'testing'>
    
	^ (self parent identityHash
           + self namespace identityHash)
               bitXor: self name hash
    ]

    at: aString ifAbsentPut: aBlock [
        <category: 'accessing'>
    
	^ self at: aString ifAbsent: [ self at: aString put: aBlock value ]
    ]

    at: aString put: aCategory [
        <category: 'accessing'>

	self categories at: aString put: aCategory.
	"SystemChangeNotifier root classCategoryAdded: aCategory."
        ^ aCategory
    ]

    at: aString [
	<category: 'accessing'>

	^ self at: aString ifAbsent: [ SystemExceptions.NotFound signalOn: aString what: 'Category ', aString, ' not found' ]
    ]

    at: aString ifAbsent: aBlock [
	<category: 'accessing'>

	^ self categories at: aString ifAbsent: aBlock
    ]

    registerNotifier [
        <category: 'initialize-release'>

        "TODO: do not go through GtkLauncher's notifier
        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'classRecategorizedEvent:'"
    ]

    "classRecategorizedEvent: anEvent [
        <category: 'model event'>

        | namespace oldCat newCat |
        namespace := anEvent item environment.
        oldCat := ClassCategory named: anEvent oldCategory into: namespace.
        oldCat removeClass: anEvent item
    ]"

    initialize [
        <category: 'initialize-release'>

        self registerNotifier
    ]

    values [
	<category: 'accessing'>

	^ self categories values
    ]

    namespace [
        <category: 'accessing'>

        ^ namespace
    ]

    namespace: aNamespace [
        <category: 'accessing'>

        namespace := aNamespace
    ]

    name: aString [
	<category: 'accessing'>

	name := aString
    ]

    name [
	<category: 'accessing'>

	^ name ifNil: [ name := String new ]
    ]

    fullname [
	<category: 'accessing'>

	| r p |
	p := self parent.
	r := self name.
	[ p isNil or: [ p name isEmpty ] ] whileFalse: [ r := p name, '-', r.
	    p := p parent ].
	^ r 
    ]

    parent: aCategory [
	<category: 'category accessing'>

	parent := aCategory
    ]

    parent [
	<category: 'category accessing'>

	^ parent
    ]

    category [
	<category: 'category accessing'>

	^ self
    ]

    removeCategory: aCategory [
	<category: 'category accessing'>

	self at: aCategory name ifAbsent: [ ^ self ].
	aCategory parent: nil.
	self categories removeKey: aCategory name.
	"SystemChangeNotifier root classCategoryRemoved: aCategory."
	(self classes isEmpty and: [ self parent isNil not ]) ifTrue: [ self parent removeCategory: self ]
    ]

    categories [
	<category: 'category accessing'>

	^ categories ifNil: [ categories := Dictionary new ]
    ]
    
    subspaces [
	<category: 'accessing'>

	^ #()
    ]

    classes [
	<category: 'class accessing'>

	^ classes ifNil: [ classes := IdentitySet new ]
    ]

    removeClass: aClass [
	<category: 'class accessing'>

	(self classes includes: aClass) ifFalse: [ ^ self ].
	self classes remove: aClass.
	(self classes isEmpty and: [ self parent isNil not ]) ifTrue: [ self parent removeCategory: self ]
    ]

    isCategory [
	<category: 'testing'>

	^ true
    ]

    isNamespace [
	<category: 'testing'>

	^ false
    ]

    icon [
	<category: '*VisualGST'>

	^ self class icon
    ]
]
PK
     �Mh@�|o�|   |     Category/Class.stUT	 eqXO�XOux �  �  Class extend [

    classCategory [
	<category: 'accessing'>

	^ VisualGST.ClassCategory extractClassCategory: self
    ]
]
PK
     �Mh@��<��   �     GtkClassSelectionChanged.stUT	 eqXO�XOux �  �  Announcement subclass: GtkClassSelectionChanged [
    | selectedClass |

    selectedClass [
	<category: 'accessing'>

	^ selectedClass
    ]

    selectedClass: aSelectedClass [
	<category: 'accessing'>

	selectedClass := aSelectedClass
    ]
]
PK
     �Mh@��u�x  x    GtkMethodSUnitWidget.stUT	 eqXO�XOux �  �  GtkMethodWidget subclass: GtkMethodSUnitWidget [

    category: aString [
        <category: 'accessing'>

        category := aString.
        self classOrMeta methodDictionary ifNil: [
                model clear.
                ^ self].
        model
            item: ((self classOrMeta methodDictionary select: [ :each | self category = '*' or: [ each methodCategory = self category and: [ each selector matchRegex: 'test' from: 1 to: 4 ] ] ])
                                                                                                    asArray sort: [ :a :b | a selector <= b selector ]);
            refresh
    ]
]

PK
     �Mh@-u<M  M    MethodFinder.stUT	 eqXO�XOux �  �  AbstractFinder subclass: MethodFinder [
    | class selector |

    MethodFinder class >> on: aClass with: aSelector [
	<category: 'instance creation'>

	^ (self new)
	    on: aClass with: aSelector;
	    yourself
    ]

    on: aClass with: aSelector [
	<category: 'accessing'>

	class := aClass.
	selector := aSelector
    ]

    displayString [
	<category: 'printing'>

	^ class displayString, ' >> ', selector displayString
    ]

    element [
        <category: 'accessing'>

        ^ selector 
    ]

    updateBrowser: aGtkClassBrowserWidget [
	<category: 'events'>

	aGtkClassBrowserWidget
	    selectANamespace: class environment;
	    selectAClass: class asClass.
	class isClass 
	    ifTrue: [ aGtkClassBrowserWidget selectAnInstanceMethod: selector ]
	    ifFalse: [ aGtkClassBrowserWidget selectAClassMethod: selector  ]
    ]
]

PK
     �Mh@��a�  �    GtkNotebookWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkNotebookWidget [
    | currentWidget selectMessage notebook pages labels |

    initialize [
	<category: 'initialization'>

	labels := OrderedCollection new.
	pages := OrderedCollection new.
	self mainWidget: self buildNotebookWidget
    ]

    buildNotebookWidget [
	<category: 'user interface'>

        ^ notebook := GTK.GtkNotebook new
			    connectSignal: 'switch-page'
			    to: self
			    selector: #'switchPageOn:page:number:'
			    userData: nil;
			    setShowTabs: false;
			    yourself
    ]

    whenSelectionChangedSend: aSymbol to: anObject [
        selectMessage := DirectedMessage receiver: anObject selector: aSymbol arguments: #()
    ]

    addWidget: aWidget labeled: aString [
	<category: 'user interface'>

	self addWidget: aWidget labelWidget: (self buildLabelWidget: aString withIcon: GTK.Gtk gtkStockClose at: aWidget)
    ]


    updateWidget: aWidget withLabel: aString [
	<category: 'user interface'>

	notebook setTabLabel: aWidget mainWidget tabLabel: (self buildLabelWidget: aString withIcon: GTK.Gtk gtkStockClose at: aWidget)
    ]

    addPermanentWidget: aWidget labeled: aString [
        <category: 'user interface'>

	self addWidget: aWidget labelWidget: (labels add: (GTK.GtkLabel new: aString))
    ]

    addWidget: aWidget labelWidget: aLabelWidget [
	<category: 'user interface'>

	currentWidget ifNil: [ currentWidget := aWidget ].
        pages addLast: aWidget.
        notebook
            appendPage: aWidget mainWidget tabLabel: aLabelWidget.
        pages size > 1 ifTrue: [ notebook setShowTabs: true ]
    ]

    buildLabelWidget: aString withIcon: aStockString at: aSmallInteger [
        <category: 'user interface'>

        | image close |
        image := GTK.GtkImage newFromStock: aStockString size: GTK.Gtk gtkIconSizeMenu.
        close := (GTK.GtkButton new)
                    setImage: image;
                    setRelief: GTK.Gtk gtkReliefNone;
                    connectSignal: 'pressed' to: self selector: #'closeIt:at:' userData: aSmallInteger;
                    yourself.
        ^ (GTK.GtkHBox new: false spacing: 0)
            add: (labels add: (GTK.GtkLabel new: aString));
            add: close;
            showAll;
            yourself
    ]

    switchPageOn: aGtkNotebook page: aGtkNotebookPage number: anInteger [
        <category: 'notebook events'>

        currentWidget := pages at: anInteger + 1.
        selectMessage ifNotNil: [ selectMessage send ]
    ]

    closeIt: aGtkButton  at: aGtkConcreteWidget [
        <category: 'notebook events'>

        | pageNb |
        pageNb := notebook pageNum: aGtkConcreteWidget mainWidget.
	aGtkConcreteWidget close.
        pages removeAtIndex: pageNb + 1.
	labels removeAtIndex: pageNb + 1.
        notebook removePage: pageNb.
	pages size = 1 ifTrue: [ notebook setShowTabs: false ]
    ]

    widgetAt: anInteger [
	<category: 'accessing'>

	^ pages at: anInteger
    ]

    currentWidget [
	<category: 'accessing'>

	^ currentWidget
    ]

    focusedWidget [
	<category: 'accessing'>

	^ currentWidget focusedWidget
    ]

    currentPage [
	<category: 'pages'>

	^ notebook getCurrentPage
    ]

    currentPage: aSmallInteger [
	<category: 'pages'>

	notebook setCurrentPage: aSmallInteger
    ]

    showLastPage [
	<category: 'pages'>

	self currentPage: self numberOfPages - 1
    ]

    numberOfPages [
	<category: 'pages'>

	^ notebook getNPages
    ]

    closeCurrentPage [
	<category: 'pages'>

	self numberOfPages = 1 ifTrue: [ ^ self ].
        pages removeAtIndex: self currentPage + 1.
	labels removeAtIndex: self currentPage + 1.
	notebook removePage: self currentPage.
	pages size = 1 ifTrue: [ notebook setShowTabs: false ]
    ]

    showPane [
	<category: 'widget'>

	notebook showAll.
	pages do: [ :each | each postInitialize ]
    ]
]

PK
     �Mh@b���  �    GtkMainWindow.stUT	 eqXO�XOux �  �  Smalltalk.Object subclass: GtkMainWindow [
    | window container menuBar toolBar centralWidget statusBar accelGroup |

    GtkMainWindow class >> open	[
	<category: 'user interface'>

	^ (self new)
	    initialize;
	    showAll;
	    postInitialize;
	    yourself
    ]

    GtkMainWindow class >> openSized: aPoint [
	<category: 'user interface'>
	
	^ (self new)
	    initialize;
	    resize: aPoint;
	    showAll;
	    postInitialize;
	    yourself
    ]

    centralWidget [
	<category: 'accessing'>

	^ centralWidget
    ]

    centralWidget: aGtkWidget [
	<category: 'accessing'>

	centralWidget := aGtkWidget
    ]

    container [
	<category: 'accessing'>

	^ container ifNil: [ container := GTK.GtkVBox new: false spacing: 0 ]
    ]

    accelGroup [
	<category: 'accessing'>

	^ accelGroup ifNil: [ accelGroup := GTK.GtkAccelGroup new ]
    ]

    menuBar [
	<category: 'accessing'>

	^ menuBar ifNil: [ menuBar := GTK.GtkMenuBar new ]
    ]

    menuBar: aGtkMenuBar [
	<category: 'accessing'>

	menuBar := aGtkMenuBar
    ]

    statusBar [
	<category: 'accessing'>

	^ statusBar ifNil: [ statusBar := GTK.GtkStatusbar new ] 
    ]

    statusBar: aGtkStatusBar [
	<category: 'accessing'>

	statusBar := aGtkStatusBar
    ]

    title [
	<category: 'accessing'>

	^ window title
    ]

    title: aString [
	<category: 'accessing'>

	window setTitle: aString
    ]

    toolBar [
	<category: 'accessing'>

	^ toolBar ifNil: [ toolBar := GTK.GtkToolbar new ]
    ]

    toolBar: aGtkToolBar [
	<category: 'accessing'>

	toolBar := aGtkToolBar
    ]

    aboutGst [
	<category: 'events'>

	(GTK.GtkAboutDialog new)
	    setProgramName: 'GNU Smalltalk';
	    setVersion: (Smalltalk version =~ 'version (.*)' at: 1);
	    setLicense: 'GNU Smalltalk is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2, or (at your option) any later version.

GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You should have received a copy of the GNU General Public License along with
GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  

Please consult the GNU Smalltalk source code for additional permissions
that are specific to this version of GNU Smalltalk.';
	    setWebsite: 'http://smalltalk.gnu.org/';
	    showModalDestroy
    ]

    close [
	<category: 'events'>

	window hideAll
    ]

    initialize [
	<category: 'intialization'>
	
	window := GTK.GtkWindow	new: GTK.Gtk gtkWindowToplevel.
	window addAccelGroup: self accelGroup.
        self
            title: self windowTitle;
            createMenus;
            createToolbar;
            createStatusBar;
            centralWidget: self buildCentralWidget.
    ]

    buildCentralWidget [
	<category: 'initialization'>
        ^nil
    ]

    createStatusBar [
        <category: 'user interface'>

        self statusMessage: self windowTitle
    ]

    windowTitle [
	<category: 'initialization'>
        ^self class name
    ]

    createToolbar [
	<category: 'initialization'>
    ]

    createMenus [
	<category: 'initialization'>
    ]

    postInitialize [
	<category: 'initialization'>

        window
            connectSignal: 'delete-event' to: self selector: #'onDelete:event:'
    ]

    onDelete: aGtkWidget event: aGdkEvent [
	<category: 'events'>

        window hideAll.
        ^ true
    ]

    addMenuItem: aString [
	<category: 'menubar'>

	self menuBar append: (GTK.GtkMenuItem newWithLabel: aString)
    ]

    addMenuItem: aString withSubmenu: aGtkMenuItemArray [
	<category: 'menubar'>

	self menuBar append:
	    ((GTK.GtkMenuItem newWithLabel: aString)
		setSubmenu: (self createNewMenuEntry: aGtkMenuItemArray))
    ]

    createMainMenu: anArray [
	<category: 'menubar'>

	anArray do: [ :each |
	    self addMenuItem: each first withSubmenu: (self perform: each second) ]
    ]

    createNewMenuEntry: anArray [
        <category: 'menubar'>

        | menu |
        menu := (GTK.GtkMenu new)
                    setAccelGroup: self accelGroup;
                    yourself.
        anArray do: [ :each |
            menu append: each ].
        ^ menu
    ]

    statusMessage: aString [
	<category: 'statusbar'>

	self statusBar
	    push: 0 text: aString
    ]

    appendSeparator [
	<category: 'toolbar'>

	self appendToolItem: GTK.GtkSeparatorToolItem new
    ]

    appendToolItem: aGtkToolItem [
	<category: 'toolbar'>

	self toolBar insert: aGtkToolItem pos: -1
    ]

    appendWidget: aGtkWidget [
	<category: 'toolbar'>

	self appendToolItem: ((GTK.GtkToolItem new) add: aGtkWidget)
    ]

    resize: aPoint [
	<category: 'user interface'>

	window resize: aPoint x height: aPoint y
    ]

    showAll [
	{menuBar->false. toolBar->false. centralWidget->true. statusBar->false} do: [ :each |
	    each key ifNotNil: [ self container 
		packStart: each key expand: each value fill: true padding: 0 ] ].

	window 
	    add: self container;
	    showAll
    ]

    focusedWidget [
        <category: 'focus'>

        self subclassResponsibility
    ]

    onFocusPerform: aSymbol [
        <category: 'widget'>

        | widget |
        widget := self focusedWidget.
        widget isNil ifTrue: [ ^ self ].
        ^ widget perform: aSymbol
    ]

    onFocusPerform: aSymbol with: anObject [
        <category: 'widget'>

        | widget |
        widget := self focusedWidget.
        widget isNil ifTrue: [ ^ self ].
        ^ widget perform: aSymbol with: anObject
    ]
]
PK
     &\h@            	  Debugger/UT	 �XO�XOux �  �  PK
     �Mh@�_��      Debugger/GtkStackInspector.stUT	 eqXO�XOux �  �  GtkInspectorWidget subclass: GtkStackInspector [

    object: aContext [
        <category: 'accessing'>

        object := aContext.
        objectView := object stackInspectorView openOn: self object.
        model
            item: objectView;
            refresh
    ]
]

PK
     �Mh@�;��>%  >%    Debugger/GtkDebugger.stUT	 eqXO�XOux �  �  GtkBrowsingTool subclass: GtkDebugger [
    | codeWidget contextWidget debugger inspectorWidget stackInspectorWidget |

    GtkDebugger class >> open: aString [
	<category: 'user interface'>

        "The current process might be processing an event.  Gtk will
         block inside g_main_loop_dispatch and won't deliver any
         other events until this one is processed.  So, fork into a
         new process and return nil without executing #ensure: blocks."
        Processor activeProcess detach.

	[ :debugger |
	    Processor activeProcess name: 'Notifier/Debugger'.
	    (self openSized: 1024@600)
		title: ('VisualGST Debugger ', aString);
		debugger: debugger ] forkDebugger
    ]
    
    GtkDebugger class >> debuggerClass [
        <category: 'debugging interface'>

        ^ nil
    ]

    GtkDebugger class >> debuggingPriority [
	<category: 'debugging interface'>

	^ 1
    ]

    accelPath [
        <category: 'accelerator path'>

        ^ '<VisualGST>'
    ]

    windowTitle [
	^ 'Debugger'
    ]

    aboutTitle [
	^ 'About Debugger'
    ]

    postInitialize [
        <category: 'initialization'>

        super postInitialize.
	codeWidget postInitialize.
	inspectorWidget postInitialize.
	stackInspectorWidget postInitialize.
    ]
 
    buildContextWidget [
	<category: 'user interface'>

	^ contextWidget := (GtkContextWidget parentWindow: window)
				whenSelectionChangedSend: #contextChanged to: self;
				yourself
    ]

    buildInspectorWidget [
	<category: 'user interface'>

	^ inspectorWidget := GtkInspectorWidget parentWindow: window
    ]

    buildSourceWidget [
	<category: 'user interface'>

	^ codeWidget := (GtkSourceCodeWidget parentWindow: window) 
			    appendTag: #debug description: #('paragraph-background' 'grey83' 'foreground' 'black' nil);
			    browser: self;
			    yourself
    ]

    buildStackInspectorWidget [
	<category: 'user interface'>

	^ (stackInspectorWidget := GtkStackInspector new)
            parentWindow: window;
	    initialize;
	    mainWidget
    ]

    buildInspectorsWidget [
	<category: 'user interface'>

	^ GTK.GtkHPaned addAll: {self buildInspectorWidget mainWidget. self buildStackInspectorWidget}
    ]

    buildCodeAndStateWidget [
	<category: 'intialize-release'>

	^ GTK.GtkVPaned addAll: {self buildSourceWidget mainWidget. self buildInspectorsWidget}
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

	^ GTK.GtkVPaned addAll: {self buildContextWidget mainWidget. self buildCodeAndStateWidget}
    ]

    createExecuteMenus [
	<category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'Step' connectTo: self selector: #step.
            GTK.GtkMenuItem menuItem: 'Step into' connectTo: self selector: #stepInto.
            GTK.GtkMenuItem menuItem: 'Step over' connectTo: self selector: #stepOver.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: 'Run' connectTo: self selector: #run}
    ]

    createMenus [
	<category: 'user interface'>

	self createMainMenu: {#('File' #createFileMenus).
	    #('Edit' #createEditMenus).
	    #('Execute' #createExecuteMenus).
	    #('Smalltalk' #createSmalltalkMenus).
	    #('Tools' #createToolsMenus).
	    #('Help' #createHelpMenus)}
    ]

    createToolbar [
	<category: 'user interface'>

	super createToolbar.
	DebuggerToolbar buildToolbarOn: self
    ]

    debugger: aDebugger [
        <category: 'context'>

	debugger := aDebugger.
	self 
	    updateContextWidget
    ]

    skipTopContext [
        <category: 'context'>

        | context lastContext contexts |
        context := debugger suspendedContext.
        lastContext := context environment.
        "stacktrace := OrderedCollection new."
        contexts := OrderedCollection new.

        [ context ~~ lastContext and: [ context isInternalExceptionHandlingContext ] ]
            whileTrue: [ context := context parentContext ].
        [ context == lastContext ] whileFalse:
                [ context isDisabled
                    ifFalse:
                        [ "stacktrace add: context printString."
                        contexts add: context ].
                context := context parentContext ].
    ]

    initializeProcess: aProcess [
        <category: 'context'>

        debugger := Debugger on: aProcess suspend.
    ]

    updateInspectorWidget: aContext [
	<category: 'context'>

        inspectorWidget object: aContext receiver.
        stackInspectorWidget object: aContext
    ]

    updateContextWidget [
	<category: 'context'>

	contextWidget
            context: debugger suspendedContext;
            selectFirstContext.

	self updateInspectorWidget: debugger suspendedContext
    ]

    doItProcess: aProcess [
	<category: 'context'>

	self initializeProcess: aProcess.
	3 timesRepeat: [ debugger step ].
	debugger myStepInto.
	self updateContextWidget
    ]

    process: aProcess [
	<category: 'context'>
	
	self 
	    initializeProcess: aProcess;
	    updateContextWidget
    ]

    browserHasFocus [
        <category: 'command protocols'>

        ^self focusedWidget == codeWidget
    ]

    sourceCodeWidgetHasFocus [ 
        <category: 'focus'>
        
        ^ codeWidget hasFocus
    ]   
    
    selectedText [
        <category: 'smalltalk events'>
        
        ^codeWidget selectedText
    ]
    
    hasSelection [ 
        <category: 'smalltalk events'>
        
        ^codeWidget hasSelection
    ]

    contextChanged [
	<category: 'context events'>

	| iter |
	self checkCodeWidgetAndUpdate: [
	    contextWidget hasSelectedContext ifFalse: [ ^ self ].
	    codeWidget source: (BrowserMethodSource on: contextWidget selectedContext method).
	    codeWidget applyTag: #debug forLine: contextWidget selectedContext currentLine.
	    self updateInspectorWidget: contextWidget selectedContext ]
    ]

    step [
	<category: 'execute events'>

	contextWidget isLastContextSelected
	    ifTrue: [ debugger myStep ]
	    ifFalse: [ debugger finish: contextWidget selectedContext ].
	self updateContextWidget
    ]

    stepInto [
	<category: 'execute events'>

	contextWidget isLastContextSelected
	    ifTrue: [ debugger myStepInto ]
	    ifFalse: [ debugger finish: contextWidget selectedContext ].
	self updateContextWidget
    ]

    stepOver [
	<category: 'execute events'>

	debugger step.
	self updateContextWidget
    ]

    run [
	<category: 'execute events'>

	self close.
	debugger continue
    ]

    codeSaved [
	<category: 'method events'>

	codeWidget codeSaved
    ]

    selectedClass [
	<category: 'method events'>

	^ self state classOrMeta
    ]

    sourceCode [
	<category: 'method events'>

	^ codeWidget sourceCode
    ]

    selectedCategory [
	<category: 'method events'>

	^ self state selectedCategory
    ]

    compileError: aString line: line [
        <category: 'method events'>

        codeWidget compileError: aString line: line
    ]

    acceptIt [
	<category: 'method events'>

	AcceptItCommand executeOn: self.
    ]

    targetObject [
        <category: 'smalltalk event'>

        inspectorWidget hasFocus ifTrue: [^inspectorWidget object].

        "TODO: make ContextState so that targetObject can be
         moved to the BrowserState hierarchy."
	^contextWidget hasSelectedContext ifTrue: [contextWidget selectedContext receiver] ifFalse: [nil]
    ]

    focusedWidget [
        <category: 'widget'>

        inspectorWidget hasFocus ifTrue: [ ^ inspectorWidget ].
        stackInspectorWidget hasFocus ifTrue: [ ^ stackInspectorWidget ].
        ^ codeWidget
    ]

    onFocusPerform: aSymbol [
        <category: 'widget'>

        ^self focusedWidget perform: aSymbol
    ]

    doIt: object [
        <category: 'smalltalk event'>

        self focusedWidget doIt: object
    ]

    debugIt: object [
        <category: 'smalltalk event'>

        self focusedWidget debugIt: object
    ]

    inspectIt: object [
        <category: 'smalltalk event'>

        self focusedWidget inspectIt: object
    ]

    printIt: object [
        <category: 'smalltalk event'>

        self focusedWidget printIt: object
    ]

    state [
        <category: 'actions'>

        ^contextWidget state
    ]

    clearUndo [
        <category: 'smalltalk event'>

        codeWidget clearUndo
    ]

    doIt [
        <category: 'smalltalk event'>

        DoItCommand executeOn: self
    ]

    debugIt [
        <category: 'smalltalk event'>

        DebugItCommand executeOn: self
    ]

    inspectIt [
        <category: 'smalltalk event'>

        InspectItCommand executeOn: self
    ]

    printIt [
        <category: 'smalltalk event'>

        PrintItCommand executeOn: self
    ]

    hasChanged [
	<category: 'testing'>

	^ codeWidget hasChanged
    ]

    cancel [
        <category: 'edit events'>

        self onFocusPerform: #cancel
    ]

    undo [
        <category: 'edit events'>

        self onFocusPerform: #undo
    ]

    redo [
        <category: 'edit events'>

        self onFocusPerform: #redo
    ]

    cut [
        <category: 'edit events'>

        self onFocusPerform: #cut
    ]

    copy [
        <category: 'edit events'>

        self onFocusPerform: #copy
    ]

    paste [
        <category: 'edit events'>

        self onFocusPerform: #paste
    ]

    selectAll [
        <category: 'edit events'>

        self onFocusPerform: #selectAll
    ]

    find [
        <category: 'edit events'>

        self onFocusPerform: #showFind
    ]

    replace [
        <category: 'edit events'>

        self onFocusPerform: #showReplace
    ]

]

PK
     �Mh@F>�	  �	    Debugger/GtkContextWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkContextWidget [
    | column contextTree model context contextList |

    GtkContextWidget class >> on: aContext [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    context: aContext;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildTreeView
    ]

    context: aContext [
	<category: 'accessing'>

	context := aContext.
	model
	    item: self buildListOfContexts;
	    refresh
    ]

    buildListOfContexts [
	<category: 'model'>

	| ctxt |
	contextList := OrderedCollection new.
        ctxt := context.
        [ ctxt isNil ] whileFalse: [
            contextList add: ctxt.
            ctxt := ctxt parentContext ].
	^ contextList
    ]

    buildTreeView [
        <category: 'user interface'>
    
        contextTree := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'Contexts'}}.
        contextTree connectToWhenPopupMenu: (ContextMenus on: self).
        contextTree treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkListModel on: contextTree treeView getModel)
                                        contentsBlock: [ :each | {each printString} ].
        ^ contextTree mainWidget
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	contextTree treeView getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    isLastContextSelected [
        <category: 'item selection'>

	^ self selectedContext == context
    ]

    selectLastContext [
        <category: 'item selection'>

	contextTree treeView selectLastItem
    ]

    selectFirstContext [
        <category: 'item selection'>

	contextTree treeView selectFirstItem
    ]

    hasSelectedContext [
	<category: 'testing'>

	^ contextTree treeView hasSelectedItem
    ]

    selectedContext [
	<category: 'accessing'>


	self hasSelectedContext ifFalse: [ self error: 'Nothing is selected' ].
        ^ contextTree treeView selection
    ]

    state [
        <category: 'actions'>

        "TODO: add ContextState."
        contextTree treeView hasSelectedItem ifTrue: [
            ^MethodState with: contextTree treeView selection method method ].
        ^BrowserState new
    ]

    positionOfSelectedContext [
	<category: 'accessing'>

	self hasSelectedContext ifFalse: [ self error: 'Nothing is selected' ].
	^ contextList findFirst: [ :each | each == self selectedContext ].
    ]
]

PK
     �Mh@�
V��  �  !  Debugger/GtkStackInspectorView.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkStackInspectorView [
    | object variables |

    GtkStackInspectorView class >> openOn: aContext [
	<category: 'instance creation'>

	^ (super new)
	    object: aContext;
	    yourself
    ]

    object [
	<category: 'accessing'>
	
	^ object
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject.
    ]

    do: aBlock [
	<category: 'iterating'>

	| i |
        variables := Dictionary new.
        i := 1.
	aBlock value: 'thisContext'.
        self object variablesDo: [ :each |
                variables at: each displayString put: i.
		aBlock value: each displayString.
                i := i + 1 ].
    ]

    selectedValue: aString [
	<category: 'item selection'>

        ^ aString = 'thisContext'
            ifTrue: [ self object ]
            ifFalse: [ self object at: (variables at: aString) ]
    ]

    canDive [
	<category: 'testing'>

	^ false
    ]
]

PK
     �Mh@n��f�  �    GtkScrollTreeWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkScrollTreeWidget [

    GtkScrollTreeWidget class >> createListWithModel: anObject [
	<category: 'instance creation'>

	^ self basicNew
		treeView: (GTK.GtkTreeView createListWithModel: anObject);
		initialize;
		yourself
    ]

    GtkScrollTreeWidget class >> createTreeWithModel: anObject [
        <category: 'instance creation'>

        ^ self basicNew
                treeView: (GTK.GtkTreeView createTreeWithModel: anObject);
                initialize;
                yourself
    ]

    | treeView |

    initialize [
	<category:'initialize'>

	popupMenu := [ :value | ].
	self buildTreeView.
	self mainWidget: (GTK.GtkScrolledWindow withChild: self treeView)
    ]

    buildTreeView [
	<category: 'user interface'>

    ]

    treeView: aGtkTreeView [
	<category: 'accessing'>

	treeView := aGtkTreeView.
    ]

    treeView [
	<category: 'accessing'>

	^ treeView
    ]
]

PK
     �Mh@@�^hjG  jG    Extensions.stUT	 eqXO�XOux �  �  Eval [
    "Huge hack for compatibility with the separate GLib package
     in newer gst."
    (GTK definesKey: #GLib) ifTrue: [
        GTK GLib addClassVarName: #GType.
        GTK GLib classPool at: #GType put: GTK GLib.
        Smalltalk at: #GLib put: GTK GLib.
    ]
]

Object extend [

    gtkInspect [
	"Open a GtkInspector on self"
	<category: '*VisualGST'>

	VisualGST.GtkInspector openOn: self
    ]

    inspectorView [
	<category: '*VisualGST'>

	^ VisualGST.GtkObjectInspectorView
    ]

    hasLiterals [
	<category: '*VisualGST'>

	^ false
    ]
]

CompiledMethod class extend [
    ExtensionIcon := nil.
    OverrideIcon := nil.
    OverriddenIcon := nil.

    extensionIcon [
        <category: '*VisualGST'>

        ^ ExtensionIcon ifNil: [ ExtensionIcon := GTK.GdkPixbuf newFromFile: (VisualGST.GtkLauncher / 'Icons/extension.png') file displayString error: nil ]
    ]

    extensionsIcon: aGdkPixbuf [
        <category: '*VisualGST'>

        ExtensionIcon := aGdkPixbuf
    ]

    overrideIcon [
        <category: '*VisualGST'>

        ^ OverrideIcon ifNil: [ OverrideIcon := GTK.GdkPixbuf newFromFile: (VisualGST.GtkLauncher / 'Icons/override.png') file displayString error: nil ]
    ]

    overrideIcon: aGdkPixbuf [
        <category: '*VisualGST'>

        OverrideIcon := aGdkPixbuf
    ]

    overriddenIcon [
        <category: '*VisualGST'>

        ^ OverriddenIcon ifNil: [ OverriddenIcon := GTK.GdkPixbuf newFromFile: (VisualGST.GtkLauncher / 'Icons/overridden.png') file displayString error: nil ]
    ]

    overriddenIcon: aGdkPixbuf [
        <category: '*VisualGST'>

        OverriddenIcon := aGdkPixbuf
    ]
]

CompiledMethod extend [
    override [
	<category: '*VisualGST'>

	self methodClass superclass ifNil: [ ^ false ].
	^ (self methodClass superclass lookupSelector: self selector) isNil not
    ]

    overridden [
        <category: '*VisualGST'>

	| set |
	set := Set new.
	set addAll: self methodClass subclasses.
	set do: [ :each |
	    each methodDictionary ifNotNil: [ :dic | dic at: self selector ifPresent: [ :mth | ^ true ] ] ].
	^ false
    ]

    methodViewIcon [
        <category: '*VisualGST'>

	self methodCategory first = $* ifTrue: [ ^ self class extensionIcon ].
        self overridden ifTrue: [ ^ self class overriddenIcon ].
        self override ifTrue: [ ^ self class overrideIcon ].
        ^ nil
    ]

    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkCompiledMethodInspectorView
    ]
]

CompiledBlock extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkCompiledBlockInspectorView
    ]

    methodRecompilationSourceString [
	<category: '*VisualGST'>

	^ self method methodRecompilationSourceString
    ]
]

SequenceableCollection extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkSequenceableCollectionInspectorView
    ]
]

Set extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkSetInspectorView
    ]
]

Dictionary extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkDictionaryInspectorView
    ]
]

Character extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkCharacterInspectorView
    ]
]

Integer extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkIntegerInspectorView
    ]
]

Float extend [
    inspectorView [
        <category: '*VisualGST'>

        ^ VisualGST.GtkFloatInspectorView
    ]
]

Symbol extend [
    hasLiterals [
	<category: '*VisualGST'>

	^ true
    ]

    symbolFromliterals [
	<category: '*VisualGST'>

	^ {self}
    ]
]

Array extend [
    hasLiterals [
	<category: '*VisualGST'>

	self do: [ :each |
	    each hasLiterals ifTrue: [ ^ true ] ].
	^ false
    ]

    symbolFromliterals [
        <category: '*VisualGST'>

	| result |
	result := OrderedCollection new.
	self do: [ :each |
	    each hasLiterals ifTrue: [ result add: each symbolFromliterals first ] ].
        ^ result
    ]
]

Class extend [

    subclass: classNameString environment: aNamespace [
	<category: '*VisualGST'>

        "Define a subclass of the receiver with the given name.  If the class
	 is already defined, don't modify its instance or class variables
         but still, if necessary, recompile everything needed."

	| meta |
	KernelInitialized ifFalse: [^Smalltalk at: classNameString].
	meta := self metaclassFor: classNameString.
	^ meta 
	    name: classNameString
	    environment: aNamespace
	    subclassOf: self
    ]
]

CompiledCode extend [

    hasLiterals [
	<category: '*VisualGST'>

	^ self literals isEmpty not
    ]

    isSendingWithSpecialSelector: aByteCode [
	<category: '*VisualGST'>

	^ aByteCode <= 31
    ]

    specialSelectorSended: aByteCode and: anOperand [
	<category: '*VisualGST'>

	(self isSendingWithSpecialSelector: aByteCode) ifFalse: [ ^ self error: 'bad byte code' ].
	aByteCode <= 26 ifTrue: [ ^ self class specialSelectors at: aByteCode + 1 ].
        (aByteCode = 30 or: [ aByteCode = 31 ]) ifTrue: [ ^ self class specialSelectors at: anOperand + 1 ].
    ]

    extractSpecialSelectors [
	<category: '*VisualGST'>

	| result |
	result := Set new.
        self allByteCodeIndicesDo: [ :i :bytecode :operand |
	    (self isSendingWithSpecialSelector: bytecode) ifTrue: [
		result add: (self specialSelectorSended: bytecode and: operand) ] ].
	^ result
    ]

    literalsAndSpecialSelectors [
	<category: '*VisualGST'>

	"Answer whether the receiver refers to the given object"

        | result |
	result := Set new.
	self literalsDo: [ :each |
	    each hasLiterals ifTrue: [ result addAll: each symbolFromliterals ] ].

        ^ result + self extractSpecialSelectors
    ]

    literalsAndSpecialSelectorsDo: aOneArgBlock [
	<category: '*VisualGST'>

	self literalsAndSpecialSelectors do: aOneArgBlock
    ]

]

CompiledBlock extend [
    symbolFromliterals [
	<category: '*VisualGST'>

	^ self extractSpecialSelectors
    ]
]

MethodContext extend [
    variables [
        <category: '*VisualGST'>

        | variables method |
        method := self method method parserClass parseMethod: self method method methodSourceString onError: [ :aString :position | ^ variables:= #() ].
        (variables := method argumentNames asOrderedCollection) addAll: method body temporaryNames.
        ^ variables
    ]
]

BlockContext extend [
    variables [
        <category: '*VisualGST'>

        | variables method |
        method := self method method parserClass parseMethod: self method method methodSourceString.
        variables := method argumentNames,  method body temporaryNames.
        ^ variables
    ]
]

ContextPart extend [
    parentContextAt: anInteger [
	<category: '*VisualGST'>

	| ctxt i |
	anInteger <= 0 ifTrue: [ self error: 'Error indice <= 0' ].
	self parentContext ifNil: [ self error: 'Error indice too high' ].
	anInteger = 1 ifTrue: [ ^ self ].
	i := 2.
	ctxt := self parentContext.
	[ i < anInteger and: [ ctxt parentContext isNil not ] ] whileTrue: [
	    ctxt := ctxt parentContext.
	    i := i + 1 ].
	^ i = anInteger 
	    ifTrue: [ ctxt ]
	    ifFalse: [ self error: 'Error indice too high' ]
    ]

    variables [
	<category: '*VisualGST'>

	^ 1 to: self numArgs + self numTemps collect: [ :each |
	    each displayString ]
    ]

    variablesDo: aBlock [
	<category: '*VisualGST'>

	^ self variables do: aBlock
    ]

    stackInspectorView [
        <category: '*VisualGST'>

        ^ GtkStackInspectorView
    ]
]

Debugger extend [

    receiver [
	<category: '*VisualGST'>

	^ self suspendedContext receiver
    ]

    myStepInto [
        "Run to the end of the current line in the inferior process or to the
         next message send."

	"TODO: Stop when affectation (get the current bytecode)"
        <category: '*VisualGST'>
        | context |
        context := self suspendedContext.

        [ self stepBytecode.
          self suspendedContext == context ]
                whileTrue
    ]

    myStep [
        "Run to the end of the current line in the inferior process, skipping
         over message sends."

	"TODO: Stop when affectation (get the current bytecode)"
        <category: '*VisualGST'>
        | context |
        context := self suspendedContext.

        [ self stepBytecode.
         (self suspendedContext notNil and: [ self suspendedContext parentContext == context ])
                ifTrue: [ self finish: self suspendedContext. ^ self ].
         self suspendedContext == context ]
                whileTrue
    ]
]

Behavior extend [

    debuggerClass [
	<category: '*VisualGST'>

	"^ nil"
	^ VisualGST.GtkDebugger
    ]
]

VariableBinding extend [

    hasLiterals [
	<category: '*VisualGST'>

	^ true
    ]

    symbolFromliterals [
	<category: '*VisualGST'>

	^ {self key}
    ]
]

GTK.GtkButton class extend [

    createButton: aStockId [
        <category: 'instance creation'>

        | image |
        image := GTK.GtkImage newFromStock: aStockId size: GTK.Gtk gtkIconSizeMenu.
        ^ (GTK.GtkButton new)
                setImage: image;
                setRelief: GTK.Gtk gtkReliefNone;
                yourself
    ]

    closeButton [
	<category: 'instance creation'>

        ^ self createButton: GTK.Gtk gtkStockClose
    ]

    previousButton [
	<category: 'instance creation'>

        ^ self createButton: GTK.Gtk gtkStockGoBack
    ]

    nextButton [
	<category: 'instance creation'>

         ^ self createButton: GTK.Gtk gtkStockGoForward
    ]

    replaceButton [
        <category: 'instance creation'>

         ^ self createButton: GTK.Gtk gtkStockFindAndReplace
    ]
]

Metaclass extend [
    displaySymbol [
	<category: '*VisualGST'>

	^ self instanceClass name
    ]
]

AbstractNamespace extend [
    displaySymbol [
	<category: '*VisualGST'>

	^ self displayString asSymbol
    ]
]

Symbol extend [
    displaySymbol [
	<category: '*VisualGST'>

	^ self
    ]
]

CharacterArray extend [

    deindexOf: aCharacterArray matchCase: aBoolean startingAt: anIndex [
	"Answer an Interval of indices in the receiver which match the aCharacterArray
	 pattern. # in aCharacterArray means 'match any character', * in aCharacterArray means
	 'match any sequence of characters'. The first item of the returned interval
	 is >= anIndex. If aBoolean is false, the search is case-insensitive, 
	 else it is case-sensitive. If no Interval matches the pattern, answer nil."

	<category: '*VisualGST'>
	| result |
	aBoolean 
	    ifFalse: 
		[ ^ self asLowercase 
		   deindexOf: aCharacterArray asLowercase
		   matchCase: true
		   startingAt: anIndex ].
	1 to: anIndex do: 
		[ :i | 
		    result := aCharacterArray 
				matchSubstring: 1
				in: self
				at: anIndex - i + 1.
		    result notNil ifTrue: [ ^ anIndex - i + 1 to: result ] ].
	^ nil
    ]
]

STInST.RBParser class extend [

    selectedSymbol: aString [
	<category: '*VisualGST'>

        | stream parser node |
        stream := aString readStream.
        parser := STInST.RBBracketedMethodParser new.
        parser errorBlock: [ :message :position | ^ nil ].
        parser scanner: (parser scannerClass on: stream errorBlock: parser errorBlock).
        node := parser parseExpression.
        node := node bestNodeFor: (1 to: aString size).
        [ node isNil ifTrue: [ ^ nil ].
          node isMessage] whileFalse: [ node := node parent ].
        ^ node selector
    ]	
]

GTK.GtkTreeModel class extend [
    createModelWith: anArray [
        <category: '*VisualGST'>

        | model |
        model := OrderedCollection new.
        anArray do: [ :each | model addAll: (each collect: [ :elem | elem kind ]) ].
        model addLast: VisualGST.GtkColumnOOPType kind.
        ^ self new: model size varargs: model asArray
    ]
]

GTK.GtkListStore class extend [
    createModelWith: anArray [
        <category: '*VisualGST'>

        | model |
        model := OrderedCollection new.
        anArray do: [ :each | model addAll: (each collect: [ :elem | elem kind ]) ].
        model addLast: VisualGST.GtkColumnOOPType kind.
        ^ self new: model size varargs: model asArray
    ]
]

GTK.GtkTreeStore class extend [
    createModelWith: anArray [
        <category: '*VisualGST'>

        | model |
        model := OrderedCollection new.
        anArray do: [ :each | model addAll: (each collect: [ :elem | elem kind ]) ].
        model addLast: VisualGST.GtkColumnOOPType kind.
        ^ self new: model size varargs: model asArray
    ]
]

GTK.GtkTreeView class extend [

    createModel: aGtkStoreClass with: anArray [
	<category: '*VisualGST'>

	^ self newWithModel: (aGtkStoreClass createModelWith: anArray)
    ]

    createTreeViewWith: anArray [
	<category: '*VisualGST'>

        ^ self createModel: GtkTreeStore with: anArray
    ]

    createListViewWith: anArray [
        <category: '*VisualGST'>

        ^ self createModel: GtkListStore with: anArray
    ]

    createColumnsOn: aGtkTreeView with: anArray [
        <category: '*VisualGST'>

        | colView i render |
        i := 0.
        anArray do: [ :each |
            colView := GtkTreeViewColumn new.
            each do: [ :column |
            column isVisible ifTrue: [
                colView
                    packStart: (render := column cellRenderer new) expand: false;
                    addAttribute: render attribute: column kindName column: i.
                column hasTitle ifTrue: [ colView setTitle: column title ].
                i := i + 1 ] ].
            aGtkTreeView insertColumn: colView position: -1 ]
    ]

    createListWithModel: anArray [
        <category: '*VisualGST'>

        | view |
        view := self createListViewWith: anArray.
        self createColumnsOn: view with: anArray.
	^ view 
    ]

    createTreeWithModel: anArray [
	<category: '*VisualGST'>

	| view |
        view := self createTreeViewWith: anArray.
        self createColumnsOn: view with: anArray.
	^ view
    ]
]

GTK.GtkTreeView extend [
    | model |

    model: aGtkModel [
	<category: 'accessing'>

	model := aGtkModel
    ]

    model [
	<category: 'accessing'>

	^ model
    ]

    selection [
	<category: 'accessing'>

        | iter string |
        (iter := self selectedIter) ifNil: [ ^ self error: 'nothing is selected' ].
	^ (self getModel at: iter) last
    ]

    selections [
	<category: 'accessing'>

	| glist result |
	result := OrderedCollection new.
	(glist := self getSelection getSelectedRows: nil) ifNil: [ ^ result ].
	glist do: [ :each | | iter path |
	    path := each castTo: GTK.GtkTreePath type.
	    iter := self getModel getIter: path.
	    result add: ((self getModel at: iter) last) ].
	^ result
    ]

    select: anObject [
	<category: 'accessing'>

        self getSelection unselectAll.
	self getModel do: [ :elem :iter |
	    elem last = anObject ifTrue: [
                    self scrollToCell: (self getModel getPath: iter) column: nil useAlign: false rowAlign: 0.5 colAlign: 0.5.
                    ^ self getSelection selectIter: iter ] ].
    ]

    selectNth: anInteger [
	<category: 'accessing'>

        | path iter |
        self getSelection unselectAll.
        anInteger = 0 ifTrue: [^self].
        path := GtkTreePath newFromIndices: {anInteger - 1. -1}.
	(self getModel getIter: path) isNil ifTrue: [^self].
        self scrollToCell: path column: nil useAlign: false rowAlign: 0.5 colAlign: 0.5.
        self getSelection selectPath: path
    ]

    selectFirstItem [
	<category: 'accessing'>

	| selection |
	(selection := self getSelection) unselectAll.
        selection unselectAll.
        selection selectIter: self getModel getIterFirst
    ]

    selectLastItem [
	<category: 'accessing'>

	| selection |
	(selection := self getSelection) unselectAll.	
	selection unselectAll.
        selection selectIter: self getModel getIterLast
    ]
]

GTK.GtkDialog extend [

    showModal [
        <category: '*VisualGST'>

        self
            setModal: true;
            showAll 
    ]

    destroy: aGtkDialog [
        <category: '*VisualGST'>

	self destroy
    ]

    showModalOnAnswer: aBlock [
        <category: '*VisualGST'>

        self
            setModal: true;
            connectSignal: 'response' to: aBlock selector: #cull:cull:;
            showAll 
    ]
    
    showModalDestroy [
        <category: '*VisualGST'>

        self
            setModal: true;
            connectSignal: 'response' to: self selector: #destroy:;
            showAll 
    ]

    showOnAnswer: aBlock [
        <category: '*VisualGST'>

        self
            setModal: false;
            connectSignal: 'response' to: aBlock selector: #cull:cull:;
            showAll 
    ]
]

GTK.GtkWidget extend [
    getFocusChild [
        <category: '*VisualGST'>
        ^nil
    ]
]

GTK.GtkPaned class extend [

    addAll: anArray [

	^ self addAll: anArray from: 1
    ]

    addAll: anArray from: anInteger [

        ^ anArray size - anInteger = 0 
                ifTrue: [ self new
                                pack1: (anArray at: anInteger) resize: true shrink: true;
                                yourself ]
                ifFalse: [ 
                    anArray size - anInteger > 1 ifTrue: [ 
					    self new
                                                    pack1: (anArray at: anInteger) resize: true shrink: true;
                                                    pack2: (self addAll: anArray from: anInteger + 1) resize: true shrink: false;
                                                    yourself ]
                                    ifFalse: [ self new
                                                    pack1: (anArray at: anInteger) resize: true shrink: true;
                                                    pack2: (anArray at: anInteger + 1) resize: true shrink: false;
                                                    yourself ] ]
    ]

]

GTK.GtkScrolledWindow class extend [

    withViewport: aGtkWidget [
	<category: 'instance creation'>

	^ (GTK.GtkScrolledWindow new: nil vadjustment: nil)
	    addWithViewport: aGtkWidget;
	    setPolicy: GTK.Gtk gtkPolicyAutomatic vscrollbarPolicy: GTK.Gtk gtkPolicyAutomatic;
	    yourself
    ]
]

Smalltalk.PackageLoader class extend [
    root [
	<category: 'accessing'>

	^ root
    ]
]
PK
     �Mh@���6      GtkListModel.stUT	 eqXO�XOux �  �  Object subclass: GtkListModel [

    GtkListModel class >> on: aGtkListStore [
	<category: 'instance creation'>

	^ super new
	    initialize;
	    gtkModel: aGtkListStore;
	    yourself
    ]

    | contentsBlock item model |

    initialize [
	<category: 'initialization'>

    ]

    gtkModel: aGtkListStore [
	<category: 'accessing'>

	model := aGtkListStore
    ]

    item: anObject [
	<category: 'accessing'>

	item := anObject
    ]

    item [
	<category: 'accessing'>

	^ item
    ]

    contentsBlock: aBlock [
	<category: 'accessing'>

	contentsBlock := aBlock
    ]

    contentsBlock [
	<category: 'accessing'>

	^ contentsBlock
    ]

    append: anItem [
	<category: 'model'>

	model appendItem: ((self contentsBlock value: anItem) copyWith: anItem)
    ]

    remove: anObject [
	<category: 'model'>

	| iter |
	(iter := self findIter: anObject) ifNil: [ self error: 'item not found' ].
	model remove: iter
    ]

    clear [
	<category: 'model'>

	model clear
    ]

    refresh [
	<category: 'model'>

	self clear.
	self item ifNil: [ ^ self ].
	self item do: [ :each | self append: each ]
    ]

    hasItem: anObject [
        <category: 'item selection'>

        self findIter: anObject ifAbsent: [ ^ false ].
        ^ true
    ]

    findIter: anObject ifAbsent: aBlock [
	<category: 'item selection'>

	model do: [ :elem :iter |
	    elem last = anObject ifTrue: [ ^ iter ] ].
	aBlock value
    ]

    findIter: anObject [
	<category: 'item selection'>

	^ self findIter: anObject ifAbsent: [ self error: 'Item not found' ]
    ]
]

PK
     �Mh@�s��      WorkspaceVariableTracker.stUT	 fqXO�XOux �  �  STInST.STInST.RBProgramNodeVisitor subclass: WorkspaceVariableTracker [
    | keyword class |

    initialize [
        <category: 'initialization'>

        keyword := #('self' 'super' 'true' 'false' 'nil' 'thisContext') asSet.
	class := (Behavior new)
                    superclass: Object;
                    yourself
    ]

    objectClass [
        <category: 'accessing'>

        ^ class
    ]

    includesVariable: aString [
        <category: 'operation'>

        ^ aString first isUppercase or: [ (keyword includes: aString) or: [ class allInstVarNames includes: aString asSymbol ] ]
    ]

    defineVariable: aString [
        <category: 'operation'>

        class addInstVarName: aString
    ]

    removeVariable: aString [
	<category: 'operation'>

        class removeInstVarName: aString
    ]

    checkAndAdd: aString [
	<category: 'operation'>

        (self includesVariable: aString)
            ifFalse: [ self defineVariable: aString ].
    ]

    acceptAssignmentNode: anRBAssignmentNode [
        <category: 'operation'>

	self checkAndAdd: anRBAssignmentNode variable name.
        self visitNode: anRBAssignmentNode value
    ]

    acceptVariableNode: anRBVariableNode [
        <category: 'operation'>

	self checkAndAdd: anRBVariableNode name
    ]

]
PK
     %\h@              Menus/UT	 �XO�XOux �  �  PK
     �Mh@��&�  �    Menus/LauncherToolbar.stUT	 eqXO�XOux �  �  MenuBuilder subclass: LauncherToolbar [
    LauncherToolbar class >> menus [

        ^ {CutEditCommand.
        CopyEditCommand.
        PasteEditCommand.
        ToolbarSeparator.
        UndoEditCommand.
        RedoEditCommand.
        ToolbarSeparator.
        DoItCommand.
        PrintItCommand.
        InspectItCommand.
        DebugItCommand.
        ToolbarSeparator.
        AcceptItCommand}
    ]
]
PK
     �Mh@���י   �     Menus/ContextMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: ContextMenus [

    ContextMenus class >> menus [

	^ {InspectMethodCommand.
	MenuSeparator.
        FileoutMethodCommand}
    ]
]
PK
     �Mh@]Ƭ      Menus/NamespaceMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: NamespaceMenus [

    NamespaceMenus class >> menus [

	^ {AddNamespaceCommand.
        DeleteNamespaceCommand.
        RenameNamespaceCommand.
	MenuSeparator.
        FileoutNamespaceCommand.  
	MenuSeparator.
        InspectNamespaceCommand}
    ]
]
PK
     �Mh@;* �   �     Menus/ToolbarSeparator.stUT	 eqXO�XOux �  �  Command subclass: ToolbarSeparator [

    buildToolItem [
        <category: 'build'>

        ^ GTK.GtkSeparatorToolItem new show;
		yourself
    ]
]

PK
     �Mh@��%��   �     Menus/WorkspaceMenus.stUT	 eqXO�XOux �  �  SimpleWorkspaceMenus subclass: WorkspaceMenus [

    WorkspaceMenus class >> menus [

	^ super menus, {MenuSeparator.
			WorkspaceVariableCommand}
    ]
]
PK
     �Mh@��,(�  �    Menus/TextMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: TextMenus [

    TextMenus class >> menus [

	^{OpenSenderCommand.
		OpenImplementorCommand.
                MenuSeparator.
                AcceptItCommand.
                CancelCommand.
                MenuSeparator.
                UndoEditCommand.
                RedoEditCommand.
                MenuSeparator.
                DoItCommand.
                PrintItCommand.
                DebugItCommand.
                InspectItCommand}.
    ]
]
PK
     �Mh@�P,�   �     Menus/DebuggerToolbar.stUT	 eqXO�XOux �  �  MenuBuilder subclass: DebuggerToolbar [
    DebuggerToolbar class >> menus [

        ^ {ContinueDebugCommand.
        StepIntoDebugCommand.
        StepToDebugCommand}
    ]
]
PK
     �Mh@�V�      Menus/MethodMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: MethodMenus [

    MethodMenus class >> menus [

	^ {OpenSenderCommand.
        OpenImplementorCommand.
	MenuSeparator.
        DeleteMethodCommand.
	MenuSeparator.
        FileoutMethodCommand.
	MenuSeparator.
        InspectMethodCommand}
    ]
]
PK
     �Mh@����  �    Menus/MenuBuilder.stUT	 eqXO�XOux �  �  Object subclass: MenuBuilder [

    | commands target |

    MenuBuilder class >> on: aGtkBrowser [
        <category: 'menu-building'>

        ^ self new 
	    target: aGtkBrowser; 
	    connect;
	    yourself
    ]

    MenuBuilder class >> browserBuildOn: aGtkBrowser [
        <category: 'menu-building'>

        ^ (self on: aGtkBrowser) asMenuItems
    ]

    MenuBuilder class >> buildToolbarOn: aGtkBrowser [
        <category: 'menu-building'>

        ^ (self on: aGtkBrowser) asToolItems
    ]

    asPopupMenu [

        | menu |
        menu := GTK.GtkMenu new.
        self appendTo: menu.
        ^ menu
    ]

    asMenuItems [

        ^ commands collect: [ :each | | item accelPath |
            item := each buildMenuItem.
            each accel isNil ifFalse: [
                accelPath := target accelPath, '/', each class name.
                target accelGroup append: {{each accel. accelPath}}.
                item setAccelPath: accelPath ].
            item ]
    ]

    asToolItems [

        ^ commands collect: [ :each | self target appendToolItem: each buildToolItem ]
    ]

    appendTo: aGtkMenu [

        commands do: [ :each | | item |
            item := each buildMenuItem.
            each setState: item.
            aGtkMenu append: item ]
    ]

    target [

        ^ target
    ]

    target: anObject [

        target := anObject.
    ]

    connect [

        commands := self class menus collect: [ :each | each on: self target ]
    ]
]

PK
     �Mh@�PRfF  F    Menus/EditMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: EditMenus [

    EditMenus class >> menus [

	^ {CancelEditCommand.
        UndoEditCommand.
	RedoEditCommand.
	MenuSeparator.
        CutEditCommand.
	CopyEditCommand.
	PasteEditCommand.
	MenuSeparator.
        SelectAllEditCommand.
	MenuSeparator.
        FindEditCommand.
	ReplaceEditCommand}
    ]
]
PK
     �Mh@\L��|   |     Menus/MenuSeparator.stUT	 eqXO�XOux �  �  Command subclass: MenuSeparator [

    buildMenuItem [
	<category: 'build'>

	^ GTK.GtkMenuItem new show; yourself
    ]
]

PK
     �Mh@�VR�   �     Menus/CategoryMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: CategoryMenus [

    CategoryMenus class >> menus [

	^ {AddCategoryCommand.
        RenameCategoryCommand.
	MenuSeparator.
        FileoutCategoryCommand}
    ]
]

PK
     �Mh@'4��   �     Menus/ClassMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: ClassMenus [

    ClassMenus class >> menus [

	^ {AddClassCommand.
        RenameClassCommand.
        DeleteClassCommand.
	MenuSeparator.
        FileoutClassCommand.
	MenuSeparator.
        InspectClassCommand}
    ]
]

PK
     �Mh@݊uʘ   �     Menus/WorkspaceVariableMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: WorkspaceVariableMenus [

    WorkspaceVariableMenus class >> menus [

	^ {InspectItemCommand.
        DeleteItemCommand}
    ]
]
PK
     �Mh@>��   �     Menus/HistoryMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: HistoryMenus [

    HistoryMenus class >> menus [

	^ {HistoryBackCommand.
        HistoryForwardCommand.
	MenuSeparator.
        HistoryDisplayCommand}
    ]
]
PK
     �Mh@Ʃ��4  4    Menus/SimpleWorkspaceMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: SimpleWorkspaceMenus [

    SimpleWorkspaceMenus class >> menus [

	^{UndoEditCommand.
                RedoEditCommand.
                MenuSeparator.
                DoItCommand.
                PrintItCommand.
                DebugItCommand.
                InspectItCommand}
    ]
]
PK
     �Mh@�1/l�   �     Menus/InspectorMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: InspectorMenus [

    InspectorMenus class >> menus [

	^ {InspectItemCommand.
        MenuSeparator.
        InspectorDiveCommand.
        InspectorBackCommand}
    ]
]
PK
     �Mh@y���   �     Menus/TabsMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: TabsMenus [

    TabsMenus class >> menus [

	^ {PreviousTabCommand.
        NextTabCommand.
	CloseTabCommand}
    ]
]
PK
     �Mh@��n?�   �     Menus/SmalltalkMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: SmalltalkMenus [

    SmalltalkMenus class >> menus [

	^ {DoItCommand.
        PrintItCommand.
	InspectItCommand.
	DebugItCommand.
	MenuSeparator.
	AcceptItCommand}
    ]
]
PK
     �Mh@qn�_�  �    Menus/ToolsMenus.stUT	 eqXO�XOux �  �  MenuBuilder subclass: ToolsMenus [

    ToolsMenus class >> menus [

	| menu |
	menu := {OpenSenderCommand.
		OpenImplementorCommand.
                OpenSUnitCommand.
		OpenPackageBuilderCommand.
		MenuSeparator.
		OpenBottomPaneCommand} asOrderedCollection.

        GtkWebView hasWebkit ifTrue: [ menu := menu, {MenuSeparator.
            OpenAssistantCommand.
            MenuSeparator.
            OpenWebBrowserCommand} ].

        ^menu
    ]
]
PK
     &\h@            
  Inspector/UT	 �XO�XOux �  �  PK
     �Mh@u��V�  �  *  Inspector/GtkCompiledBlockInspectorView.stUT	 eqXO�XOux �  �  GtkObjectInspectorView subclass: GtkCompiledBlockInspectorView [

    GtkCompiledBlockInspectorView class [ | fields | ]

    GtkCompiledBlockInspectorView class >> fields [
	<category: 'accessing'>

	^ fields ifNil: [ fields := Dictionary from: {'clean-ness flags'->#flags. 
					    'Number Of Arguments'->#arguments.
					    'Number Of Temporaries'->#temporaries.
					    'Number Of Literals'->#numLiterals.
					    'Needed Stack Slots'->#stack.
					    'Byte Codes'->#byte.
					    'Source Code'->#source} ]
    ]

    do: aBlock [
	<category: 'accessing'>

	super do: aBlock.
        self class fields keys do: aBlock
    ]

    selectedValue: anObject [
	<category: 'events'>

        ^ (self class fields includesKey: anObject)
	    ifFalse: [ super selectedValue: anObject ]
            ifTrue: [ self perform: (self class fields at: anObject) ]
    ]

    flags [
	<category: 'event'>

	^ self object flags
    ]

    arguments [
	<category: 'event'>

	^ self object numArgs 
    ]

    temporaries [
	<category: 'event'>

	^ self object numTemps
    ]

    numLiterals [
	<category: 'event'>

	^ self object numLiterals
    ]

    stack [
	<category: 'event'>

	^ self object stackDepth
    ]

    literals [
	<category: 'event'>

	| stream |
	stream := WriteStream on: String new.
	1 to: self numLiterals do: [ :i | 
		self object bytecodeIndex: i with: stream. 
		stream tab. 
		stream print: (self object literalAt: i) ].
	^ stream contents
    ]

    byte [
	<category: 'event'>

	| stream |
	stream := WriteStream on: String new.
	self object numBytecodes > 0 ifTrue: [ self object printByteCodesOn: stream ].
	^ stream contents
    ]

    source [
	<category: 'event'>

	^ self object methodSourceString
    ]
]

PK
     �Mh@Q���  �  +  Inspector/GtkCompiledMethodInspectorView.stUT	 eqXO�XOux �  �  GtkObjectInspectorView subclass: GtkCompiledMethodInspectorView [

    GtkCompiledMethodInspectorView class [ | fields | ]

    GtkCompiledMethodInspectorView class >> fields [
	<category: 'accessing'>

	^ fields ifNil: [ fields := Dictionary from: {'Flags'->#flags. 
					    'Primitive Index'->#primitive.
					    'Number Of Arguments'->#arguments.
					    'Number Of Temporaries'->#temporaries.
					    'Number Of Literals'->#numLiterals.
					    'Needed Stack Slots'->#stack.
					    'Literals'->#literals.
					    'Byte Codes'->#byte.
					    'Source Code'->#source} ]
    ]

    do: aBlock [
	<category: 'accessing'>

	super do: aBlock.
        self class fields keys do: aBlock
    ]

    selectedValue: anObject [
	<category: 'events'>

        ^ (self class fields includesKey: anObject)
	    ifFalse: [ super selectedValue: anObject ]
            ifTrue: [ self perform: (self class fields at: anObject) ]
    ]

    flags [
	<category: 'event'>

	^ self object flags
    ]

    primitive [
	<category: 'event'>

	self object flags = 4 ifTrue: [ VMPrimitives keyAtValue: self object primitive ifAbsent: [ 'unknown' ] ].
	^ self object primitive 
    ]

    arguments [
	<category: 'event'>

	^ self object numArgs 
    ]

    temporaries [
	<category: 'event'>

	^ self object numTemps
    ]

    numLiterals [
	<category: 'event'>

	^ self object numLiterals
    ]

    stack [
	<category: 'event'>

	^ self object stackDepth
    ]

    literals [
	<category: 'event'>

	| stream |
	stream := WriteStream on: String new.
	1 to: self numLiterals do: [ :i | 
		self object bytecodeIndex: i with: stream. 
		stream tab. 
		stream print: (self object literalAt: i) ].
	^ stream contents
    ]

    byte [
	<category: 'event'>

	| stream |
	stream := WriteStream on: String new.
	self object numBytecodes > 0 ifTrue: [ self object printByteCodesOn: stream ].
	^ stream contents
    ]

    source [
	<category: 'event'>

	^ self object methodSourceString
    ]
]

PK
     �Mh@oJ!�d  d     Inspector/GtkSetInspectorView.stUT	 eqXO�XOux �  �  GtkObjectInspectorView subclass: GtkSetInspectorView [

    do: aBlock [
	<category: 'accessing'>

	super do: aBlock.
        self object do: aBlock
    ]

    selectedValue: anObject [
        <category: 'events'>

        ^ (self object includes: anObject)
            ifFalse: [ super selectedValue: anObject ]
            ifTrue: [ anObject ]
    ]
]

PK
     �Mh@~1��  �  '  Inspector/GtkDictionaryInspectorView.stUT	 eqXO�XOux �  �  GtkObjectInspectorView subclass: GtkDictionaryInspectorView [

    do: aBlock [
	<category: 'accessing'>

	super do: aBlock.
        self object keys do: aBlock
    ]

    selectedValue: anObject [
        <category: 'events'>

        ^ (self object includesKey: anObject)
            ifFalse: [ super selectedValue: anObject ]
            ifTrue: [ self object at: anObject ]
    ]
]

PK
     �Mh@���i  i  %  Inspector/GtkInspectorSourceWidget.stUT	 eqXO�XOux �  �  GtkTextWidget subclass: GtkInspectorSourceWidget [
    | object |
    
    GtkInspectorSourceWidget class >> openOn: anObject [
	<category: 'instance creation'>

	^ (self new)
	    object: anObject;
	    yourself
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject
    ]

    connectSignals [
        <category: 'initialization'>

	super connectSignals.
        self
            connectToWhenPopupMenu: (SimpleWorkspaceMenus on: self).
    ]

    targetObject [
	<category: 'smalltalk event'>

	^object
    ]

    doIt [
	<category: 'smalltalk event'>

	DoItCommand executeOn: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand executeOn: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand executeOn: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand executeOn: self
    ]
]
PK
     �Mh@\D[  [  #  Inspector/GtkObjectInspectorView.stUT	 eqXO�XOux �  �  Object subclass: GtkObjectInspectorView [
    | object model |

    GtkObjectInspectorView class >> openOn: anObject [
	<category: 'instance creation'>

	^ (super new)
	    object: anObject;
	    yourself
    ]

    object [
	<category: 'accessing'>
	
	^ object
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject.
    ]

    do: aBlock [ 
	<category: 'iterating'>

	aBlock value: 'self'.
        self object class allInstVarNames do: aBlock
    ]

    values [
	<category: 'accessing'>

	^Array streamContents: [:s | self do: [:value | s nextPut: value]]
    ]

    selectedValue: aString [
	<category: 'item selection'>

	| iter string instVar |
        ^ aString = 'self'
            ifTrue: [ self object ]
            ifFalse: [ self object
			instVarNamed: aString ]
    ]

    canDive [
	<category: 'testing'>

	^ true
    ]
]

PK
     �Mh@PJ0  0  &  Inspector/GtkCharacterInspectorView.stUT	 eqXO�XOux �  �  GtkObjectInspectorView subclass: GtkCharacterInspectorView [

    do: aBlock [
	super do: aBlock.
        #('hexadecimal' 'octal' 'binary') do: aBlock
    ]

    selectedValue: aString [
	<category: 'events'>

	| base |
	base := 0.
	aString = 'hexadecimal' ifTrue: [ base := 16 ].
	aString = 'octal' ifTrue: [ base := 8 ].
	aString = 'binary' ifTrue: [ base := 2 ].
	^ base = 0 
	    ifTrue: [ super selectedValue: aString ]
	    ifFalse: [ self object asInteger printString: base ]
    ]

    canDive [
        <category: 'testing'>

        ^ false
    ]
]

PK
     �Mh@�`�c�!  �!  &  Inspector/GtkInspectorBrowserWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkInspectorBrowserWidget [
    | checkCode namespaceWidget classHierarchyWidget classHierarchyUpdate iCategoryWidget iMethodWidget cCategoryWidget cMethodWidget codeWidget state |

    GtkInspectorBrowserWidget class >> title [
	<category: 'accessing'>

	^ 'Gtk class browser'
    ]

    postInitialize [
	<category: 'initialization'>

	codeWidget postInitialize
    ]

    buildBrowser [

	^ GTK.GtkHPaned addAll: {self buildHierarchy. self buildProtocolAndMethod}
    ]

    buildClassBrowser [

	^ GTK.GtkHPaned addAll: {self buildClassMethodView}
    ]

    buildInstanceBrowser [

	^ GTK.GtkHPaned addAll: {self buildInstanceMethodView}
    ]

    buildProtocolAndMethod [

	^  (GTK.GtkNotebook new)
	    appendPage: self buildInstanceBrowser tabLabel: (GTK.GtkLabel new: 'Instance');
	    appendPage: self buildClassBrowser tabLabel: (GTK.GtkLabel new: 'Class');
	    showAll;
	    setCurrentPage: 0;
	    connectSignal: 'switch-page' to: self selector: #'classInstanceSwitchOn:page:number:' userData: nil;
	    yourself
    ]

    buildCodeView [
	<category: 'user interface'>

	codeWidget := (GtkSourceCodeWidget parentWindow: self parentWindow)
			browser: self;
			showAll;
			yourself.
    
	^ codeWidget mainWidget
    ]

    buildHierarchy [
	<category: 'user interface'>

	classHierarchyWidget := GtkClassHierarchyWidget showAll
				    whenSelectionChangedSend: #onClassHierarchyChanged to: self;
				    yourself.

	^ classHierarchyWidget mainWidget
    ]

    buildClassMethodView [
	<category: 'user interface'>

	cMethodWidget := GtkMethodWidget showAll
			    whenSelectionChangedSend: #onClassSideMethodChanged to: self;
			    yourself.

	^ cMethodWidget mainWidget
    ]

    buildInstanceMethodView [
        <category: 'user interface'>

        iMethodWidget := GtkMethodWidget showAll 
                            whenSelectionChangedSend: #onInstanceSideMethodChanged to: self;
                            yourself.

        ^ iMethodWidget mainWidget
    ]

    initialize [
	<category: 'initialize-release'>

	classHierarchyUpdate := false.
	checkCode := true.
	state := NamespaceState on: self with: Smalltalk.
	self mainWidget: (GTK.GtkVPaned addAll: {self buildBrowser. self buildCodeView})
    ]

    classInstanceSwitchOn: aGtkNotebook page: aGtkNotebookPage number: aSmallInteger [
	<category: 'events'>

	self checkCodeWidgetAndUpdate: [
	    aSmallInteger = 0 
		ifTrue: [
		    iMethodWidget hasSelectedMethod 
			ifTrue: [ codeWidget source: (BrowserMethodSource on: iMethodWidget selectedMethod) ]
			ifFalse: [ codeWidget clear ] ]
		ifFalse: [
                    cMethodWidget hasSelectedMethod
                        ifTrue: [ codeWidget source: (BrowserMethodSource on: cMethodWidget selectedMethod) ]
                        ifFalse: [ codeWidget clear ] ] ]
    ]

    onClassHierarchyChanged [
	<category: 'events'>

	| aClass |
	self checkCodeWidgetAndUpdate: [
	    classHierarchyWidget hasSelectedClass ifFalse: [ ^ self ].
	    classHierarchyUpdate := true.
            aClass := classHierarchyWidget selectedClass.

            iMethodWidget class: aClass withCategory: '*'.
            cMethodWidget class: aClass class withCategory: '*'.

            codeWidget clear.
	    state := CategoryState on: self with: classHierarchyWidget selectedClass -> '*' ]
    ]

    onInstanceSideMethodChanged [
	<category: 'events'>

	| method |
	self checkCodeWidgetAndUpdate: [
	    iMethodWidget hasSelectedMethod ifFalse: [ ^ self ].
	    method := iMethodWidget selectedMethod.
	    codeWidget source: (BrowserMethodSource on: method).
	    state := MethodState on: self with: method ]
    ]

    onClassSideMethodChanged [
	<category: 'events'>

	| method |
	self checkCodeWidgetAndUpdate: [
	    cMethodWidget hasSelectedMethod ifFalse: [ ^ self ].
	    method := cMethodWidget selectedMethod.
	    codeWidget source: (BrowserMethodSource on: method).
	    state := MethodState on: self with: method ]
    ]

    selectAClass: aClass [
	<category: 'selection'>

	classHierarchyWidget classOrMeta: aClass.

	iMethodWidget class: aClass withCategory: '*'.
	cMethodWidget class: aClass class withCategory: '*'.
	state := CategoryState on: self with: aClass -> '*'
    ]

    selectAnInstanceMethod: aSelector [
        <category: 'selection'>

        | class |
        class := classHierarchyWidget selectedClass.

        class := (class selectors includes: aSelector) ifFalse: [ class class ] ifTrue: [ class ].
        iMethodWidget
            class: class withCategory: (class compiledMethodAt: aSelector) methodCategory.
	state := CategoryState on: self with: class -> '*'
    ]

    selectAClassMethod: aSelector [
	<category: 'selection'>

        | class |
        class := classHierarchyWidget selectedClass.

	class := (class selectors includes: aSelector) ifFalse: [ class class ] ifTrue: [ class ].
        cMethodWidget
            class: class withCategory: (class compiledMethodAt: aSelector) methodCategory.
	state := CategoryState on: self with: class -> '*'
    ]

    targetObject [
        <category: 'target'>

        ^self state classOrMeta
    ]

    doIt: object [
	<category: 'smalltalk event'>

	codeWidget doIt: object
    ]

    debugIt: object [
	<category: 'smalltalk event'>

        codeWidget debugIt: object
    ]

    inspectIt: object [
	<category: 'smalltalk event'>

        codeWidget inspectIt: object
    ]

    printIt: object [
	<category: 'smalltalk event'>

        codeWidget printIt: object
    ]

    doIt [
	<category: 'smalltalk event'>

	DoItCommand executeOn: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand executeOn: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand executeOn: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand executeOn: self
    ]

    cancel [
        <category: 'buffer events'>

	codeWidget hasFocus ifTrue: [ codeWidget cancel ]
    ]

    undo [
        <category: 'buffer events'>

	codeWidget hasFocus ifTrue: [ codeWidget undo ]
    ]

    redo [
        <category: 'buffer events'>

	codeWidget hasFocus ifTrue: [ codeWidget redo ]
    ]

    copy [
        <category: 'text editing'>

	codeWidget hasFocus ifTrue: [ codeWidget copy ]
    ]

    cut [
        <category: 'text editing'>

	codeWidget hasFocus ifTrue: [ codeWidget cut ]
    ]

    paste [
        <category: 'text editing'>

	codeWidget hasFocus ifTrue: [ codeWidget paste ]
    ]

    selectAll [
        <category: 'text editing'>

	codeWidget hasFocus ifTrue: [ codeWidget selectAll ]
    ]

    doNotCheckCode [
        <category: 'text editing'>

        checkCode := false
    ]

    checkCodeWidgetAndUpdate: aBlock [
        <category: 'text editing'>

        self saveCodeOr: aBlock.
    ]

    saveCodeOr: dropBlock [
        <category: 'saving'>

        | dialog |
        checkCode ifFalse: [ checkCode := true. dropBlock value. ^ self ].
        self hasChanged ifFalse: [ dropBlock value. ^ self ].
        dialog := GTK.GtkMessageDialog
                                new: self parentWindow
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Accept changes to this method?'
                                tip: 'If you do not accept them, your changes to %1 will be lost...' % {self state}.

        dialog
            addButton: 'Drop' responseId: 0;
            addButton: 'Cancel' responseId: 2;
            addButton: 'Accept' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 1 ifTrue: [ self acceptIt ].
                res <= 1 ifTrue: dropBlock.
                dlg destroy ].
    ]

    acceptIt [
	<category: 'smalltalk events'>

        AcceptItCommand executeOn: self
    ]

    hasChanged [
	<category: 'testing'>

	^ codeWidget hasChanged
    ]

    state [
	<category: 'text editing'>

	^ state
    ]

    sourceCode [
	<category: 'accessing'>

	^ codeWidget sourceCode
    ]

    clearUndo [
	<category: 'code saved'>

	codeWidget clearUndo
    ]

    codeSaved [
	<category: 'code saved'>

	codeWidget codeSaved
    ]

    selectedText [
        <category: 'smalltalk events'>

        ^ codeWidget selectedText
    ]

    hasSelection [
        <category: 'smalltalk events'>

        ^ codeWidget hasSelection
    ]

    hasChanged [
        <category: 'close events'>

        ^ codeWidget hasChanged
    ]
]

PK
     �Mh@�� �h  h  3  Inspector/GtkSequenceableCollectionInspectorView.stUT	 eqXO�XOux �  �  GtkObjectInspectorView subclass: GtkSequenceableCollectionInspectorView [

    do: aBlock [
	super do: aBlock.
	1 to: self object size do: [ :each | aBlock value: each ]
    ]

    selectedValue: aString [
	<category: 'events'>

	^ aString asNumber = 0 
	    ifTrue: [ super selectedValue: aString ]
	    ifFalse: [ self object at: aString asNumber ]
    ]
]

PK
     �Mh@�?���  �    Inspector/GtkInspector.stUT	 eqXO�XOux �  �  GtkBrowsingTool subclass: GtkInspector [
    | object notebookWidget inspectorWidget browserWidget workspaceWidget |

    GtkInspector class >> openOn: anObject [
	<category: 'user interface'>

	^ (self new)
	    initialize;
	    object: anObject;
	    showAll;
	    postInitialize;
	    yourself
    ]

    accelPath [
        <category: 'accelerator path'>

        ^ '<Inspector>'
    ]

    postInitialize [
        <category: 'initialization'>

	super postInitialize.
	browserWidget postInitialize.
	inspectorWidget postInitialize.
	workspaceWidget postInitialize.
    ]

    object: anObject [
	<category: 'accessor'>

	| objectClass |
	object == anObject ifFalse: [
	    object := anObject.
            inspectorWidget object: object.
	    workspaceWidget object: object ].
	objectClass := object isClass ifTrue: [ object ] ifFalse: [ object class ].
	self title: 'Inspector on ', objectClass article, ' ', objectClass name.
	browserWidget
	    selectAClass: objectClass
    ]

    windowTitle [
	<category: 'initialization'>
	
	^'Inspector'
    ]

    buildCentralWidget [
	<category: 'intialize-release'>

	| trWidget wkWidget |
	notebookWidget := GTK.GtkNotebook new.
	trWidget := self buildInspectorView.
	wkWidget := self buildBrowserWidget mainWidget.
	^ notebookWidget
	    appendPage: trWidget tabLabel: (GTK.GtkLabel new: 'Basic');
	    appendPage: wkWidget tabLabel: (GTK.GtkLabel new: 'Methods');
	    showAll;
	    setCurrentPage: 0;
	    yourself
    ]

    buildInspectorView [
	<category: 'user interface'>

	^ GTK.GtkVPaned new
            pack1: self buildInspectorWidget mainWidget resize: true shrink: false;
            pack2: self buildWorkspaceWidget mainWidget resize: false shrink: true;
            yourself
    ]

    buildInspectorWidget [
	<category: 'user interface'>

	^ inspectorWidget := (GtkInspectorWidget new)
				parentWindow: window;
				initialize;
				inspector: self;
				showAll;
				yourself
    ]

    buildWorkspaceWidget [
	<category: 'user interface'>

	^ workspaceWidget := (GtkInspectorSourceWidget new)
				parentWindow: window;
				initialize;
				showAll;
				yourself
    ]

    buildBrowserWidget [
	<category: 'user interface'>

	^ browserWidget := (GtkInspectorBrowserWidget new)
				parentWindow: window;
				initialize;
				showAll;
				yourself
    ]

    createMenus [
	<category: 'user interface'>

        self createMainMenu: {#('File' #createFileMenus).
            #('Edit' #createEditMenus).
            #('Smalltalk' #createSmalltalkMenus).
            #('Tools' #createToolsMenus).
            #('Help' #createHelpMenus)}
    ]

    focusedWidget [
        <category: 'focus'>

        ^notebookWidget getCurrentPage = 0
            ifTrue: [ workspaceWidget focusedWidget ]
            ifFalse: [ browserWidget focusedWidget ]
    ]

    cancel [
        <category: 'edit events'>

        self onFocusPerform: #cancel
    ]

    undo [
        <category: 'edit events'>

        self onFocusPerform: #undo
    ]

    redo [
        <category: 'edit events'>

        self onFocusPerform: #redo
    ]

    cut [
        <category: 'edit events'>

        self onFocusPerform: #cut
    ]

    copy [
        <category: 'edit events'>

        self onFocusPerform: #copy
    ]

    paste [
        <category: 'edit events'>

        self onFocusPerform: #paste
    ]

    selectAll [
        <category: 'edit events'>

        self onFocusPerform: #selectAll
    ]

    close [
        <category: 'file events'>

        browserWidget doNotCheckCode.
        self saveCodeOr: [ super close ]
    ]

    targetObject [
        <category: 'smalltalk events'>

        ^ self onFocusPerform: #targetObject
    ]

    targetObject [
        <category: 'smalltalk events'>

        ^ self onFocusPerform: #targetObject
    ]

    doIt: anObject [
        <category: 'smalltalk events'>

        self onFocusPerform: #doIt: with: anObject
    ]

    printIt: anObject [
        <category: 'smalltalk events'>

        self onFocusPerform: #printIt: with: anObject
    ]

    inspectIt: anObject [
        <category: 'smalltalk events'>

        self onFocusPerform: #inspectIt: with: anObject
    ]

    debugIt: anObject [
        <category: 'smalltalk events'>

        self onFocusPerform: #debugIt: with: anObject
    ]

    doIt [
	<category: 'smalltalk event'>

	DoItCommand executeOn: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand executeOn: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand executeOn: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand executeOn: self
    ]

    acceptIt [
        <category: 'smalltalk events'>

        browserWidget acceptIt
    ]

    find [
	<category: 'user interface'>

	self onFocusPerform: #showFind
    ]

    replace [
	<category: 'user interface'>

	self onFocusPerform: #showReplace
    ]

    browserHasFocus [
        <category: 'command protocols'>

        ^notebookWidget getCurrentPage = 1
    ]

    sourceCodeWidgetHasFocus [
        <category: 'focus'>

        ^ browserWidget sourceCodeWidgetHasFocus
    ]

    selectedText [
        <category: 'smalltalk events'>

        ^self onFocusPerform: #selectedText
    ]

    hasSelection [
        <category: 'smalltalk events'>

        | widget |
        widget := self focusedWidget.
        widget isNil ifTrue: [ ^ false ].
        ^ widget hasSelection
    ]

    clearUndo [
	<category: 'undo'>

	browserWidget clearUndo
    ]

    hasChanged [
	<category: 'close events'>

	^ browserWidget hasChanged
    ]
]

PK
     �Mh@�`�g  g  "  Inspector/GtkFloatInspectorView.stUT	 eqXO�XOux �  �  GtkObjectInspectorView subclass: GtkFloatInspectorView [

    do: aBlock [
	super do: aBlock.
	1 to: self object size do: [ :each | aBlock value: each ]
    ]

    selectedValue: aString [
	<category: 'events'>

        ^ aString asNumber = 0
            ifTrue: [  super onVariableChanged ]
            ifFalse: [ self object at: aString asNumber ]
    ]
]

PK
     �Mh@=l���  �    Inspector/GtkInspectorWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkInspectorWidget [
    | inspector model object inspectorTree workspaceWidget objectView stack |

    GtkInspectorWidget >> openOn: anObject [
	<category: 'instance creation'>

	^ (super new)
	    initialize;
	    object: anObject;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	stack := OrderedCollection new.
	self mainWidget: self buildView.
	self whenSelectionChangedSend: #onVariableChanged to: self.
    ]

    postInitialize [
	<category: 'initialization'>

	workspaceWidget postInitialize
    ]

    inspector: aGtkInspector [
	<category: 'accessing'>

	inspector := aGtkInspector	
    ]

    object [
	<category: 'accessing'>
	
	^ object
    ]

    object: anObject [
	<category: 'accessing'>

	object := anObject.
	objectView := object inspectorView openOn: anObject.
	workspaceWidget object: anObject.
	inspector isNil ifFalse: [ inspector object: anObject ].
	model 
	    item: objectView;
	    refresh
    ]

    buildTreeWidget [
	<category: 'user interface'>

        inspectorTree := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'Variables'}}.
        inspectorTree connectToWhenPopupMenu: (InspectorMenus on: self).
        (model := GtkListModel on: inspectorTree treeView getModel)
                                        contentsBlock: [ :each | {each displayString} ].
        ^ inspectorTree mainWidget
    ]

    buildWorkspaceWidget [
	<category: 'user interface'>

	^ workspaceWidget := (GtkWorkspaceWidget new)
			    initialize;
			    showAll;
			    yourself
    ]

    buildView [
        <category: 'user interface'>
   
	^ GTK.GtkHPaned new
	    pack1: self buildTreeWidget resize: true shrink: false;
            pack2: self buildWorkspaceWidget mainWidget resize: true shrink: false;
            yourself
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        inspectorTree treeView getSelection
            connectSignal: 'changed' to: anObject selector: aSelector userData: nil
    ]

    hasSelectedValue [
        <category: 'testing'>

        ^ inspectorTree treeView hasSelectedItem 
    ]

    onVariableChanged [
	<category: 'events'>

	self hasSelectedValue ifFalse: [ workspaceWidget text: ''. ^ self ].
	workspaceWidget text: self selectedValue displayString
    ]

    selectedItem [
	<category: 'item selection'>

        self hasSelectedValue ifFalse: [ self error: 'Nothing is selected' ].
        ^ inspectorTree treeView selection
    ]

    targetObject [

	^ self selectedValue
    ]

    selectedValue [
	<category: 'item selection'>

	^ objectView selectedValue: self selectedItem
    ]

    canDive [
	<category: 'events'>

	^ self hasSelectedValue and: [ self selectedItem ~= 'self' and: [ objectView canDive ] ]
    ]

    isStackEmpty [
	<category: 'events'>

        ^ stack isEmpty
    ]

    dive [
	<category: 'events'>

	stack addFirst: self object.
        self object: self selectedValue
    ]

    back [
	<category: 'events'>

	self object: stack removeFirst
    ]

    doIt: object [
        <category: 'smalltalk event'>

        workspaceWidget doIt: object
    ]

    debugIt: object [
        <category: 'smalltalk event'>

        workspaceWidget debugIt: object
    ]

    inspectIt: object [
        <category: 'smalltalk event'>

        GtkInspector openOn: object
    ]

    printIt: object [
        <category: 'smalltalk event'>

        workspaceWidget printIt: object
    ]

    copy [
        <category: 'text editing'>

	workspaceWidget copy
    ]

    cut [
        <category: 'text editing'>

	workspaceWidget cut
    ]

    paste [
        <category: 'text editing'>

	workspaceWidget paste
    ]

    selectAll [
        <category: 'text editing'>

	workspaceWidget selectAll
    ]
 
    hasSelection [
	<category:'text testing'>

	^ workspaceWidget hasSelection
    ]
 
    selectedText [
	<category: 'text editing'>

	^ workspaceWidget selectedText
    ]

]

PK
     �Mh@��uj  j  $  Inspector/GtkIntegerInspectorView.stUT	 eqXO�XOux �  �  GtkObjectInspectorView subclass: GtkIntegerInspectorView [

    do: aBlock [
	super do: aBlock.
        #('hexadecimal' 'octal' 'binary') do: aBlock
    ]

    selectedValue: aString [
        <category: 'item selection'>

        | base iter string instVar |
	base := 0.
        aString = 'hexadecimal' ifTrue: [ base := 16 ].
        aString = 'octal' ifTrue: [ base := 8 ].
        aString = 'binary' ifTrue: [ base := 2 ].
        ^ base = 0 
	    ifTrue: [ super selectedValue: aString ]
	    ifFalse: [ self object printString: base ]
    ]

    canDive [
        <category: 'testing'>

        ^ false
    ]
]

PK
     �Mh@e#̰  �    GtkWebView.stUT	 eqXO�XOux �  �  GTK.GtkWidget subclass: GtkWebView [

    WebKitAvailable := nil.

    GtkWebView class >> initialize [
        <category: 'initialize'>

        DLD addLibrary: 'libwebkit-1.0'.
        DLD addLibrary: 'libwebkitgtk-1.0'.
        ObjectMemory addDependent: self.
    ]

    GtkWebView class >> update: aSymbol [
        <category: 'initialize'>

        aSymbol == #returnFromSnapshot ifTrue: [ WebKitAvailable := nil ].
    ]

    GtkWebView class >> hasWebkit [
        <category: 'testing'>

        ^ WebKitAvailable ifNil: [
            WebKitAvailable :=
                CFunctionDescriptor isFunction: 'webkit_web_view_new' ]
    ]

    GtkWebView class >> new [
	<category: 'C call-outs'>

	<cCall: 'webkit_web_view_new' returning: #{GtkWebView} args: #( )>
    ]

    openUrl: aString [
	<category: 'C call-outs'>

	<cCall: 'webkit_web_view_open' returning: #void args: #( #self #string )>
    ]
]

Eval [
    GtkWebView initialize
]
PK
     �Mh@�y��      GtkVisualGSTTool.stUT	 eqXO�XOux �  �  GtkMainWindow subclass: GtkVisualGSTTool [
    <comment: 'I am the base for various tools of VisualGST.'>

    GtkVisualGSTTool class >> version [
        <category: 'accessing'>

        ^ '0.8.0'
    ]

    GtkVisualGSTTool class >> website [
        <category: 'accessing'>

        ^ 'http://github.com/MrGwen/gst-visualgst'
    ]

    GtkVisualGSTTool class >> gstWebsite [
        <category: 'accessing'>

        ^ 'http://smalltalk.gnu.org/'
    ]

    GtkVisualGSTTool class >> license [
        <category: 'accessing'>

        ^
'Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
    ]

    aboutTitle [
        <category: 'widget-skeleton'>
        <comment: 'I return the visible name for the Help->About entry'>
        ^'About VisualGST...'
    ]

    showAboutDialog [
        (GTK.GtkAboutDialog new)
            setVersion: VisualGST.GtkVisualGSTTool version;
            setLicense: VisualGST.GtkVisualGSTTool license;
            setWebsite: VisualGST.GtkVisualGSTTool website;
            setComments: 'This is a GTK+ wrapper for GNU Smalltalk.';
            setProgramName: 'VisualGST'; 
            showModalDestroy
    ] 

    createFileMenus [
        <category: 'user interface'>

        | menu |
        self accelGroup append:
            {{'<Control>W'. '<GtkVisualGSTTool>/File/Close'}.
             {'<Control>Q'. '<GtkVisualGSTTool>/File/Quit'}}.

        menu := OrderedCollection withAll: {
            GTK.GtkMenuItem menuItem: 'Save image' connectTo: self selector: #saveImage.
            GTK.GtkMenuItem menuItem: 'Save image as...' connectTo: self selector: #saveImageAs.
            GTK.GtkMenuItem new}.
            menu add: (GTK.GtkMenuItem menuItem: 'Close' accelPath: '<GtkVisualGSTTool>/File/Close' connectTo: self selector: #close).
        menu add: (GTK.GtkMenuItem menuItem: 'Quit' accelPath: '<GtkVisualGSTTool>/File/Quit' connectTo: self selector: #quit).
        ^menu
    ]

    exitOnClose [
        <category: 'file events'>

        ^ self == GtkLauncher uniqueInstance
    ]

    quit [
        <category: 'file events'>

        GtkLauncher uniqueInstance quit
    ]

    createEditMenus [
        <category: 'user interface'>

	^ EditMenus browserBuildOn: self
    ]

    createSmalltalkMenus [
        <category: 'user interface'>

	^ SmalltalkMenus browserBuildOn: self
    ]

    createToolsMenus [
        <category: 'user interface'>

	^ ToolsMenus browserBuildOn: self
    ]

    state [
	<category: 'tools events'>

	^BrowserState new
    ]

    selectedText [
        <category: 'tools events'>

        "Since #hasSelection returns false, this will never be called."
        self shouldNotImplement
    ]

    selectedMethodSymbol [
        <category: 'tools events'>

        ^STInST.RBParser selectedSymbol: self selectedText
    ]

    hasSelection [
	<category: 'tools events'>

	^false
    ]

    sourceCodeWidgetHasFocus [
	<category: 'tools events'>

	^false
    ]

    browserHasFocus [
	<category: 'tools events'>

	^false
    ]

    launcher [
	<category: 'tools events'>

	^nil
    ]

    newSUnitBrowser [
	<category: 'tools events'>

	OpenSUnitCommand executeOn: self
    ]

    newSenderBrowser [
	<category: 'tools events'>

	OpenSenderCommand executeOn: self
    ]

    newImplementorBrowser [
	<category: 'tools events'>

	OpenImplementorCommand executeOn: self
    ]

    packageBuilder [
        <category: 'tools events'>

        OpenPackageBuilderCommand executeOn: self
    ]

    helpContents [
	<category: 'help events'>

	GtkWebBrowser openOn: 'http://smalltalk.gnu.org/documentation'
    ]

    createHelpMenus [
        <category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'Help Contents' connectTo: self selector: #helpContents.
            GTK.GtkMenuItem new.
            GTK.GtkMenuItem menuItem: self aboutTitle connectTo: self selector: #showAboutDialog.
            GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createMenus [
        <category: 'user interface'>

        self addMenuItem: 'File' withSubmenu: self createFileMenus.
        self addMenuItem: 'Edit' withSubmenu: self createEditMenus.
        self addMenuItem: 'Tools' withSubmenu: self createToolsMenus.
        self addMenuItem: 'Help' withSubmenu: self createHelpMenus
    ]

    createToolbar [
        <category: 'user interface'>

	LauncherToolbar buildToolbarOn: self
    ]
]

PK
     �Mh@#Zu��   �     FakeNamespace.stUT	 eqXO�XOux �  �  Object subclass: FakeNamespace [

    FakeNamespace class >> subspaces [
	<category: 'accessing'>

	^ {Smalltalk}
    ]

    FakeNamespace class >> categories [
	<category: 'accessing'>

	^ ClassCategory new
    ]
]
PK
     �Mh@���a   a     GtkVSidebarWidget.stUT	 eqXO�XOux �  �  GtkSidebarWidget subclass: GtkVSidebarWidget [

    panedOrientation [
	^ GTK.GtkVPaned
    ]
]

PK
     $\h@              Notification/UT	 �XO�XOux �  �  PK
     �Mh@ ^��  �    Notification/EventDispatcher.stUT	 eqXO�XOux �  �  SystemEventManager subclass: EventDispatcher [
    | events |

    removeActionsWithReceiver: anObject forEvent: anEvent [
	"Stop sending system notifications to an object"

	| dict |
	dict := events keys at: anEvent ifAbsent: [ ^ self ].
	dict removeKey: anObject ifAbsent: [ ^ self ].
    ]

    when: eachEvent send: oneArgumentSelector to: anObject [
	"Notifies an object of any events in the eventsCollection. Send it back a message 
	#oneArgumentSelector, with as argument the particular system event instance"

	| dict |
	dict := events at: eachEvent ifAbsentPut: [ WeakKeyIdentityDictionary new ].
	dict at: anObject put: oneArgumentSelector
    ]

    triggerEvent: anEventSelector with: anEvent [

	| dict |
	dict := events at: anEventSelector ifAbsent: [ ^ self ].
	dict associationsDo: [ :each |
	    each key perform: each value with: anEvent ]
    ]

    releaseActionMap [
	"Release all the dependents so that nobody receives notifications anymore."

	events := Dictionary new
    ]
]

PK
     �Mh@qU��7  �7    Notification/AbstractEvent.stUT	 eqXO�XOux �  �  Object subclass: AbstractEvent [
    | item itemKind environment |

    item [
	<category: 'accessing'>
	"Return the item that triggered the event (typically the name of a class, a category, a protocol, a method)."

	^ item
    ]

    itemCategory [
	<category: 'accessing'>

	^ self environmentAt: self class categoryKind
    ]

    itemClass [
	<category: 'accessing'>

	^ self environmentAt: self class classKind
    ]

    itemExpression [
	<category: 'accessing'>

	^ self environmentAt: self class expressionKind
    ]

    itemKind [
	<category: 'accessing'>
	"Return the kind of the item of the event (#category, #class, #protocol, #method, ...)"

	^ itemKind
    ]

    itemMethod [
	<category: 'accessing'>

	^ self environmentAt: self class methodKind
    ]

    itemProtocol [
	<category: 'accessing'>

	^ self environmentAt: self class protocolKind
    ]

    itemRequestor [
	<category: 'accessing'>

	^ self environmentAt: #requestor
    ]

    itemSelector [
	<category: 'accessing'>

	^ self environmentAt: #selector
    ]

    printOn: aStream [
	<category: 'printing'>

	self printEventKindOn: aStream.
	aStream
	    nextPutAll: ' Event for item: ';
	    print: self item;
	    nextPutAll: ' of kind: ';
	    print: self itemKind
    ]

    isAdded [
	<category: 'testing'>

	^ false
    ]

    isCategoryKnown [
	<category: 'testing'>

	^ self itemCategory notNil
    ]

    isCommented [
	<category: 'testing'>

	^ false
    ]

    isDoIt [
	<category: 'testing'>

	^ false
    ]

    isModified [
	<category: 'testing'>

	^ false
    ]

    isProtocolKnown [
	<category: 'testing'>

	^ self itemCategory notNil
    ]

    isRecategorized [
	<category: 'testing'>

	^ false
    ]

    isRemoved [
	<category: 'testing'>

	^ false
    ]

    isRenamed [
	<category: 'testing'>

	^ false
    ]

    isReorganized [
	<category: 'testing'>

	^ false
    ]

    trigger: anEventManager [
	<cateogyr: 'triggering'>
	"Trigger the event manager."

	anEventManager triggerEvent: self eventSelector with: self
    ]

    changeKind [
	<category: 'private-accessing'>

	^ self class changeKind
    ]

    environmentAt: anItemKind [
	<category: 'private-accessing'>

	(self itemKind = anItemKind) ifTrue: [^self item].
	^ environment at: anItemKind ifAbsent: [nil]
    ]

    eventSelector [
	<category: 'private-accessing'>

	^ self class eventSelectorBlock value: itemKind value: self changeKind
    ]

    item: anItem kind: anItemKind [
	<category: 'private-accessing'>

	item := anItem.
	itemKind := anItemKind.
	environment := Dictionary new
    ]

    itemCategory: aCategory [
	<category: 'private-accessing'>

	environment at: self class categoryKind put: aCategory
    ]

    itemClass: aClass [
	<category: 'private-accessing'>

	environment at: self class classKind put: aClass
    ]

    itemExpression: anExpression [
	<category: 'private-accessing'>

	environment at: self class expressionKind put: anExpression
    ]

    itemMethod: aMethod [
	<category: 'private-accessing'>

	environment at: self class methodKind put: aMethod
    ]

    itemProtocol: aProtocol [
	<category: 'private-accessing'>

	environment at: self class protocolKind put: aProtocol
    ]

    itemRequestor: requestor [
	<category: 'private-accessing'>

	environment at: #requestor put: requestor
    ]

    itemSelector: aSymbol [
	<category: 'private-accessing'>

	environment at: #selector put: aSymbol
    ]

    AbstractEvent class >> allChangeKinds [
	<category: 'accessing'>
	"AbstractEvent allChangeKinds"

	^ AbstractEvent allSubclasses collect: [:cl | cl changeKind]
    ]

    AbstractEvent class >> allItemKinds [
	<category: 'accessing'>
	"self allItemKinds"

	| result |
	result := OrderedCollection new.
	AbstractEvent class methodDictionary do: [ :each | 
	    each methodCategory = 'item kinds' ifTrue: [ result add: (self perform: each selector) ] ].
	^ result
    ]

    AbstractEvent class >> changeKind [
	<category: 'accessing'>
	"Return a symbol, with a : as last character, identifying the change kind."

	self subclassResponsibility
    ]

    AbstractEvent class >> eventSelectorBlock [
	<category: 'accessing'>

	^ [:itemKind :changeKind | itemKind, changeKind, 'Event:']
    ]

    AbstractEvent class >> itemChangeCombinations [
	<category: 'accessing'>

	^ self supportedKinds collect: [:itemKind | self eventSelectorBlock value: itemKind value: self changeKind]
    ]

    AbstractEvent class >> supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take. By default this is all the kinds in the system. But subclasses can override this to limit the choices. For example, the SuperChangedEvent only works with classes, and not with methods, instance variables, ..."

	^ self allItemKinds
    ]

    AbstractEvent class >> systemEvents [
	<category: 'accessing'>
	"Return all the possible events in the system. Make a cross product of 
	the items and the change types."
	"self systemEvents"

	^self allSubclasses
	    inject: OrderedCollection new
	    into: [:allEvents :eventClass | allEvents addAll: eventClass itemChangeCombinations; yourself]
    ]

    AbstractEvent class >> namespace: aNamespace [
	<category: 'instance creation'>

	^ self item: aNamespace kind: AbstractEvent namespaceKind
    ]

    AbstractEvent class >> classCategory: aName [
	<category: 'instance creation'>

	^ self item: aName kind: AbstractEvent categoryKind
    ]

    AbstractEvent class >> class: aClass [
	<category: 'instance creation'>

	^ self item: aClass kind: AbstractEvent classKind
    ]

    AbstractEvent class >> method: aCompiledMethod [
        <category: 'instance creation'>

        ^ self item: aCompiledMethod kind: AbstractEvent methodKind
    ]

    AbstractEvent class >> class: aClass category: cat [
	<category: 'instance creation'>
 
	| instance |
	instance := self class: aClass.
	instance itemCategory: cat.
	^ instance
    ]

    AbstractEvent class >> item: anItem kind: anItemKind [
	<category: 'instance creation'>

	^ self basicNew item: anItem kind: anItemKind
    ]

    AbstractEvent class >> category: aCategory class: aClass [
        <category: 'instance creation'>

        | instance |
        instance := self item: aCategory kind: self categoryKind.
        instance itemClass: aClass.
        ^ instance
    ]

    AbstractEvent class >> method: aMethod class: aClass [
	<category: 'instance creation'>

	| instance |
	instance := self item: aMethod kind: self methodKind.
	instance itemClass: aClass.
	^ instance
    ]

    AbstractEvent class >> method: aMethod protocol: prot class: aClass [
	<category: 'instance creation'>

	| instance |
	instance := self method: aMethod class: aClass.
	instance itemProtocol: prot.
	^ instance
    ]

    AbstractEvent class >> method: aMethod selector: aSymbol class: aClass [
	<category: 'instance creation'>

	| instance |
	instance := self item: aMethod kind: self methodKind.
	instance itemSelector: aSymbol.
	instance itemClass: aClass.
	^ instance
    ]

    AbstractEvent class >> method: aMethod selector: aSymbol class: aClass requestor: requestor [
	<category: 'instance creation'>

	| instance |
	instance := self method: aMethod selector: aSymbol class: aClass.
	instance itemRequestor: requestor.
	^ instance
    ]

    AbstractEvent class >> method: aMethod selector: aSymbol protocol: prot class: aClass [
	<category: 'instance creation'>

	| instance |
	instance := self method: aMethod selector: aSymbol class: aClass.
	instance itemProtocol: prot.
	^ instance
    ]

    AbstractEvent class >> method: aMethod selector: aSymbol protocol: prot class: aClass requestor: requestor [
	<category: 'instance creation'>

	| instance |
	instance := self method: aMethod selector: aSymbol protocol: prot class: aClass.
	instance itemRequestor: requestor.
	^ instance
    ]

    AbstractEvent class >> new [
	<category: 'instance creation'>
	"Override new to trigger an error, since we want to use specialized methods to create basic and higher-level events."

	^ self error: 'Instances can only be created using specialized instance creation methods.'
    ]

    AbstractEvent class >> categoryKind [
	<category: 'item kinds'>

	^ #category
    ]

    AbstractEvent class >> classKind [
	<category: 'item kinds'>

	^ #class
    ]

    AbstractEvent class >> namespaceKind [
        <category: 'item kinds'>

        ^ #namespace
    ]

    AbstractEvent class >> expressionKind [
	<category: 'item kinds'>

	^ #expression
    ]

    AbstractEvent class >> methodKind [
	<category: 'item kinds'>

	^ #method
    ]

    AbstractEvent class >> protocolKind [
	<category: 'item kinds'>

	^ #protocol
    ]

    AbstractEvent class >> comment1 [
	<category: 'temporary'>

"Smalltalk organization removeElement: #ClassForTestingSystemChanges3
Smalltalk garbageCollect 
Smalltalk organizati

classify:under:


SystemChangeNotifier root releaseAll
SystemChangeNotifier root noMoreNotificationsFor: aDependent.


aDependent := SystemChangeNotifierTest new.
SystemChangeNotifier root
    notifyOfAllSystemChanges: aDependent
    using: #event:

SystemChangeNotifier root classAdded: #Foo inCategory: #FooCat



| eventSource dependentObject |
eventSource := EventManager new.
dependentObject := Object new.

register - dependentObject becomes dependent:
eventSource
    when: #anEvent send: #error to: dependentObject.

unregister dependentObject:
eventSource removeDependent: dependentObject.

[eventSource triggerEvent: #anEvent]
    on: Error
    do: [:exc | self halt: 'Should not be!!']."
    ]

    AbstractEvent class >> comment2 [
	<category: 'temporary'>

"HTTPSocket useProxyServerNamed: 'proxy.telenet.be' port: 8080
TestRunner open

--------------------
We propose two orthogonal groups to categorize each event:
(1) the 'change type':
    added, removed, modified, renamed
    + the composite 'changed' (see below for an explanation)
(2) the 'item type':
    class, method, instance variable, pool variable, protocol, category
    + the composite 'any' (see below for an explanation).
The list of supported events is the cross product of these two lists (see below for an explicit enumeration of the events).

Depending on the change type, certain information related to the change is always present (for adding, the new things that was added, for removals, what was removed, for renaming, the old and the new name, etc.).

Depending on the item type, information regarding the item is present (for a method, which class it belongs to). 

Certain events 'overlap', for example, a method rename triggers a class change. To capture this I impose a hierarchy on the 'item types' (just put some numbers to clearly show the idea. They don't need numbers, really. Items at a certain categories are included by items one category number higher):
level 1 category
level 2 class
level 3 instance variable, pool variable, protocol, method.

Changes propagate according to this tree: any 'added', 'removed' or 'renamed' change type in level X triggers a 'changed' change type in level X - 1. A 'modified' change type does not trigger anything special.
For example, a method additions triggers a class modification. This does not trigger a category modification.

Note that we added 'composite events': wildcards for the 'change type' ('any' - any system additions) and for the 'item type' ('Changed' - all changes related to classes), and one for 'any change systemwide' (systemChanged).

This result is this list of Events:

classAdded
classRemoved
classModified
classRenamed (?)
classChanged (composite)

methodAdded
methodRemoved
methodModified
methodRenamed (?)
methodChanged (composite)

instanceVariableAdded
instanceVariableRemoved
instanceVariableModified 
instanceVariableRenamed (?)
instanceVariableChanged (composite)

protocolAdded
protocolRemoved
protocolModified
protocolRenamed (?)
protocolChanged (composite)

poolVariableAdded
poolVariableRemoved
poolVariableModified
poolVariableRenamed (?)
poolChanged (composite)

categoryAdded
categoryRemoved
categoryModified
categeryRenamed (?)
categoryChanged (composite)

anyAdded (composite)
anyRemoved (composite)
anyModified (composite)
anyRenamed (composite)

anyChanged (composite)



To check: can we pass somehow the 'source' of the change (a browser, a file-in, something else) ? Maybe by checking the context, but should not be too expensive either... I found this useful in some of my tools, but it might be too advanced to have in general. Tools that need this can always write code to check it for them.  But is not always simple...


Utilities (for the recent methods) and ChangeSet are the two main clients at this moment.

Important: make it very explicit that the event is send synchronously (or asynchronously, would we take that route).


		    category
			class
			    comment
			    protocol
				method
OR
		category
		Smalltalk
		    class
			comment
			protocol
			method
??



			Smalltalk   category
				\   /
				class
			    /	  | \
			comment  |  protocol
				  | /
				method

"
    ]

    AbstractEvent class >> comment3 [
	<category: 'temporary'>
"Things to consider for trapping:
ClassOrganizer>>#changeFromCategorySpecs:
    Problem: I want to trap this to send the appropriate bunch of ReCategorization events, but ClassOrganizer instances do not know where they belong to (what class, or what system); it just uses symbols. So I cannot trigger the change, because not enough information is available. This is a conceptual problem: the organization is stand-alone implementation-wise, while conceptually it belongs to a class. The clean solution could be to reroute this message to a class, but this does not work for all of the senders (that would work from the browserm but not for the file-in).

Browser>>#categorizeAllUncategorizedMethods
    Problem: should be trapped to send a ReCategorization event. However, this is model code that should not be in the Browser. Clean solution is to move it out of there to the model, and then trap it there (or reroute it to one of the trapped places).

Note: Debugger>>#contents:notifying: recompiles methods when needed, so I trapped it to get updates. However, I need to find a way to write a unit test for this. Haven't gotten around yet for doing this though...
"
    ]
]
PK
     �Mh@{�ub�  �    Notification/AddedEvent.stUT	 eqXO�XOux �  �  AbstractEvent subclass: AddedEvent [

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Added'
    ]

    isAdded [
	<category: 'testing'>

	^ true
    ]

    AddedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Added
    ]

    AddedEvent class >> supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take."
    
	^ Array with: self classKind with: self methodKind with: self categoryKind with: self protocolKind
    ]
]

PK
     �Mh@��T�  �  "  Notification/SystemEventManager.stUT	 fqXO�XOux �  �  Object subclass: SystemEventManager [

    SystemEventManager class >> new [
	<category: 'instance creation'>

	^ super new
	    initialize;
	    yourself
    ]
   
    initialize [
	<category: 'initialize-release'>

        self releaseActionMap
    ]

    triggerEvent: anEventSelector with: anEvent [

	self subclassResponsibility
    ]

    releaseActionMap [
	"Release all the dependents so that nobody receives notifications anymore."

	self subclassResponsibility
    ]
]

PK
     �Mh@:x�H  H     Notification/EventMultiplexer.stUT	 eqXO�XOux �  �  SystemEventManager subclass: EventMultiplexer [
    | sources |

    add: anObject [
	"Start sending system notifications to a manager"

        ^ sources add: anObject
    ]

    remove: anObject [
	"Stop sending system notifications to a manager"

        ^ sources remove: anObject ifAbsent: [ nil ]
    ]

    triggerEvent: anEventSelector with: anEvent [

	sources do: [ :each | each triggerEvent: anEventSelector with: anEvent ]
    ]

    releaseActionMap [
	"Release all the dependents so that nobody receives notifications anymore."

	sources := WeakIdentitySet new
    ]
]

PK
     �Mh@w��      Notification/DoItEvent.stUT	 eqXO�XOux �  �  AbstractEvent subclass: DoItEvent [
    | context |

    context [
	<category: 'accessing'>

	^ context
    ]

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'DoIt'
    ]

    isDoIt [
	<category: 'testing'>

	^ true
    ]

    context: aContext [
	<category: 'private-accessing'>

	context := aContext
    ]

    DoItEvent class >> changeKind [
	<category: 'accessing'>

	^ #DoIt
    ]

    DoItEvent class >> supportedKinds [
	<category: 'accessing'>

	^ Array with: self expressionKind
    ]

    DoItEvent class >> expression: stringOrStream context: aContext [
	<category: 'instance creation'>

	| instance |
	instance := self item: stringOrStream kind: AbstractEvent expressionKind.
	instance context: aContext.
	^ instance
    ]
]

PK
     �Mh@7l��,  �,  $  Notification/SystemChangeNotifier.stUT	 fqXO�XOux �  �  EventMultiplexer subclass: SystemChangeNotifier [
    SystemChangeNotifier class [ | root | ]

    | eventSource silenceLevel |

    initialize [
	<category: 'initialize'>

        super initialize.
	eventSource := EventDispatcher new.
        self add: eventSource.
	silenceLevel := 0
    ]

    doSilently: aBlock [
        "Perform the block, and ensure that no system notification are broadcasted while doing so."
	<category: 'public'>

	| result |
	silenceLevel := silenceLevel + 1.
	[result := aBlock value] ensure: [silenceLevel > 0 ifTrue: [silenceLevel := silenceLevel - 1]].
	^ result
    ]

    isBroadcasting [
	<category: 'public'>

	^ silenceLevel = 0
    ]

    noMoreNotificationsFor: anObject [
	"Stop sending system notifications to an object."

	eventSource removeActionsWithReceiver: anObject
    ]

    notify: anObject ofAllSystemChangesUsing: oneArgumentSelector [
	"Notifies an object of any system changes."
	<category: 'public'>

	self 
	    notify: anObject
	    ofEvents: self allSystemEvents
	    using: oneArgumentSelector
    ]

    notify: anObject ofSystemChangesOfChange: changeKind using: oneArgumentSelector [
	"Notifies an object of system changes of the specified changeKind (#added, #removed, ...). Evaluate 'AbstractEvent allChangeKinds' to get the complete list."
	<category: 'public'>

	self 
	    notify: anObject
	    ofEvents: (self systemEventsForChange: changeKind)
	    using: oneArgumentSelector
    ]

    notify: anObject ofSystemChangesOfItem: itemKind change: changeKind using: oneArgumentSelector [
	"Notifies an object of system changes of the specified itemKind (#class, #category, ...) and changeKind (#added, #removed, ...). This is the finest granularity possible.
	Evaluate 'AbstractEvent allChangeKinds' to get the complete list of change kinds, and 'AbstractEvent allItemKinds to get all the possible item kinds supported."
	<category: 'public'>

	self 
	    notify: anObject
	    ofEvents: (Bag with: (self systemEventsForItem: itemKind change: changeKind))
	    using: oneArgumentSelector
    ]

    notify: anObject ofSystemChangesOfItem: itemKind  using: oneArgumentSelector [
	"Notifies an object of system changes of the specified itemKind (#class, #method, #protocol, ...). Evaluate 'AbstractEvent allItemKinds' to get the complete list."
	<category: 'public'>

	self 
	    notify: anObject
	    ofEvents: (self systemEventsForItem: itemKind)
	    using: oneArgumentSelector
    ]

    namespaceAdded: aNamespace [
	<category: 'system triggers'>

	self trigger: (AddedEvent namespace: aNamespace)
    ]

    namespaceRemoved: aNamespace [
        <category: 'system triggers'>

        self trigger: (RemovedEvent namespace: aNamespace)
    ]

    classCategoryAdded: aClassCategory [
	<category: 'system triggers'>

        self trigger: (AddedEvent
			    classCategory: aClassCategory)
    ]

    classCategoryRemoved: aClassCategory [
	<category: 'system triggers'>

        self trigger: (RemovedEvent
			    classCategory: aClassCategory)
    ]

    classCategoryRenamedFrom: anOldClassCategoryName to: aNewClassCategoryName [
	<category: 'system triggers'>

        self trigger: (RenamedEvent
		    classCategoryRenamedFrom: anOldClassCategoryName 
		    to: aNewClassCategoryName)
    ]

    class: aClass recategorizedFrom: oldCategory to: newCategory [
	<category: 'system triggers'>

        self trigger: (RecategorizedEvent 
		class: aClass
		category: newCategory
		oldCategory: oldCategory)
    ]

    classAdded: aClass [
        <category: 'system triggers'>

        self trigger: (AddedEvent class: aClass)
    ]

    classRemoved: aClass [
	<category: 'system triggers'>

        self trigger: (RemovedEvent class: aClass)
    ]

    classAdded: aClass inCategory: aCategoryName [
	<category: 'system triggers'>

	self trigger: (AddedEvent class: aClass category: aCategoryName)
    ]

    classCommented: aClass [
	"A class with the given name was commented in the system."
	<category: 'system triggers'>

	self trigger: (CommentedEvent class: aClass)
    ]

    classCommented: aClass inCategory: aCategoryName [
	"A class with the given name was commented in the system."
	<category: 'system triggers'>

	self trigger: (CommentedEvent class: aClass category: aCategoryName)
    ]

    classDefinitionChangedFrom: oldClass to: newClass [
	<category: 'system triggers'>

	self trigger: (ModifiedEvent classDefinitionChangedFrom: oldClass to: newClass)
    ]

    classRemoved: aClass fromCategory: aCategoryName [
	<category: 'system triggers'>

	self trigger: (RemovedEvent class: aClass category: aCategoryName)
    ]

    classRenamed: aClass from: oldClassName to: newClassName inCategory: aCategoryName [
	<category: 'system triggers'>

        self trigger: (RenamedEvent 
		class: aClass
		category: aCategoryName
		oldName: oldClassName
		newName: newClassName)
    ]

    classReorganized: aClass [
	<category: 'system triggers'>

	self trigger: (ReorganizedEvent class: aClass)
    ]

    evaluated: textOrStream [
	<category: 'system triggers'>

	^ self evaluated: textOrStream context: nil
    ]

    evaluated: expression context: aContext [
	<category: 'system triggers'>

	self trigger: (DoItEvent 
		expression: expression
		context: aContext)
    ]

    categoryAdded: aCategory inClass: aClass [
        "A category was added to aClass"
        <category: 'system triggers'>

        self trigger: (AddedEvent
                category: aCategory
                class: aClass)
    ]

    categoryRemoved: aCategory inClass: aClass [
        "A category was removed to aClass"
        <category: 'system triggers'>

        self trigger: (RemovedEvent
                category: aCategory
                class: aClass)
    ]

    methodAdded: aCompiledMethod [
	<category: 'system triggers'>

	self trigger: (AddedEvent method: aCompiledMethod)
    ]

    methodRemoved: aCompiledMethod [
        <category: 'system triggers'>

        self trigger: (RemovedEvent method: aCompiledMethod)
    ]

    methodAdded: aMethod selector: aSymbol inClass: aClass [
	"A method with the given selector was added to aClass, but not put in a protocol."
	<category: 'system triggers'>

	self trigger: (AddedEvent
		method: aMethod 
		selector: aSymbol
		class: aClass)
    ]

    methodAdded: aMethod selector: aSymbol inClass: aClass requestor: requestor [
	"A method with the given selector was added to aClass, but not put in a protocol."
	<category: 'system triggers'>

	self trigger: (AddedEvent
		method: aMethod 
		selector: aSymbol
		class: aClass
		requestor: requestor)
    ]

    methodAdded: aMethod selector: aSymbol inProtocol: aCategoryName class: aClass [
	"A method with the given selector was added to aClass in protocol aCategoryName."
	<category: 'system triggers'>

    self trigger: (AddedEvent
		method: aMethod
		selector: aSymbol
		protocol: aCategoryName
		class: aClass)
    ]

    methodAdded: aMethod selector: aSymbol inProtocol: aCategoryName class: aClass requestor: requestor [
        "A method with the given selector was added to aClass in protocol aCategoryName."
	<category: 'system triggers'>

	self trigger: (AddedEvent
		method: aMethod
		selector: aSymbol
		protocol: aCategoryName
		class: aClass
		requestor: requestor)
    ]

    methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass [
	<category: 'system triggers'>

        self trigger: (ModifiedEvent
		    methodChangedFrom: oldMethod
		    to: newMethod
		    selector: aSymbol 
		    inClass: aClass)
    ]

    methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass requestor: requestor [
	<category: 'system triggers'>

        self trigger: (ModifiedEvent
		    methodChangedFrom: oldMethod
		    to: newMethod
		    selector: aSymbol 
		    inClass: aClass
		    requestor: requestor)
    ]

    methodRemoved: aMethod selector: aSymbol class: aClass [
        "A method with the given selector was removed from the class."
	<category: 'system triggers'>

        self trigger: (RemovedEvent
		method: aMethod 
		selector: aSymbol
		class: aClass)
    ]

    methodRemoved: aMethod selector: aSymbol inProtocol: protocol class: aClass [
        "A method with the given selector was removed from the class."
	<category: 'system triggers'>

        self trigger: (RemovedEvent
		method: aMethod 
		selector: aSymbol
		protocol: protocol
		class: aClass)
    ]

    selector: selector recategorizedFrom: oldCategory to: newCategory inClass: aClass [
	<category: 'system triggers'>

	self trigger: (RecategorizedEvent 
		method: (aClass compiledMethodAt: selector ifAbsent: [nil])
		protocol: newCategory
		class: aClass
		oldProtocol: oldCategory)
    ]

    notify: anObject ofEvents: eventsCollection using: oneArgumentSelector [
	"Notifies an object of any events in the eventsCollection. Send it back a message #oneArgumentSelector, with as argument the particular system event instance."
	<category: 'private'>

	eventsCollection do: [:eachEvent |
	    eventSource when: eachEvent send: oneArgumentSelector to: anObject]
    ]

    releaseAll [
    "Release all the dependents so that nobody receives notifications anymore."

    "Done for cleaning up the system."
    "self uniqueInstance releaseAll"
	<category: 'private'>

	eventSource releaseActionMap
    ]

    setBroadcasting [
	<category: 'private'>

        silenceLevel := 0
    ]

    trigger: event [
	<category: 'private'>

        self isBroadcasting ifTrue: [event trigger: self]

"   | caughtExceptions |
    caughtExceptions := OrderedCollection new.
    self isBroadcasting ifTrue: [
	[(eventSource actionForEvent: event eventSelector) valueWithArguments: (Array with: event)] on: Exception do: [:exc | caughtExceptions add: exc]].
    caughtExceptions do: [:exc | exc resignalAs: exc class new]"
    ]

    allSystemEvents [
	<category: 'private-event lists'>

	^ AbstractEvent systemEvents
    ]

    systemEventsForChange: changeKind [
	<category: 'private-event lists'>

        | selectorBlock |
        selectorBlock := AbstractEvent eventSelectorBlock.
        ^AbstractEvent allItemKinds 
		collect: [:itemKind | selectorBlock value: itemKind value: changeKind]
    ]

    systemEventsForItem: itemKind [
	<category: 'private-event lists'>

        | selectorBlock |
	selectorBlock := AbstractEvent eventSelectorBlock.
        ^AbstractEvent allChangeKinds 
	   collect: [:changeKind | selectorBlock value: itemKind value: changeKind]
    ]

    systemEventsForItem: itemKind change: changeKind [
	<category: 'private-event lists'>

	^ AbstractEvent eventSelectorBlock value: itemKind value: changeKind
    ]

    SystemChangeNotifier class >> categoryKind [
	<category: 'item kinds'>

	^ AbstractEvent categoryKind
    ]

    SystemChangeNotifier class >> classKind [
	<category: 'item kinds'>

	^ AbstractEvent classKind
    ]

    SystemChangeNotifier class >> namespaceKind [
        <category: 'item kinds'>

        ^ AbstractEvent namespaceKind
    ]

    SystemChangeNotifier class >> expressionKind [
	<category: 'item kinds'>

        ^ AbstractEvent expressionKind
    ]

    SystemChangeNotifier class >> methodKind [
	<category: 'item kinds'>

	^ AbstractEvent methodKind
    ]

    SystemChangeNotifier class >> protocolKind [
	<category: 'item kinds'>

	^ AbstractEvent protocolKind
    ]


    SystemChangeNotifier class >> root [
	<category: 'public'>

        root ifNil: [root := self new].
	^root
    ]
]


PK
     �Mh@�m��  �    Notification/CommentedEvent.stUT	 eqXO�XOux �  �  AbstractEvent subclass: CommentedEvent [

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Commented'
    ]

    isCommented [
	<category: 'testing'>

	^ true
    ]

    CommentedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Commented
    ]

    CommentedEvent class >> supportedKinds [
	<category: 'accessing'>

	^ Array with: self classKind
    ]
]
PK
     �Mh@����  �    Notification/RemovedEvent.stUT	 fqXO�XOux �  �  AbstractEvent subclass: RemovedEvent [

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Removed'
    ]

    isRemoved [
	<category: 'testing'>

	^ true
    ]

    RemovedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Removed
    ]

    supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take."
    
	^ Array with: self classKind with: self methodKind with: self categoryKind with: self protocolKind
    ]
]

PK
     �Mh@���  �    Notification/RenamedEvent.stUT	 fqXO�XOux �  �  AbstractEvent subclass: RenamedEvent [
    | newName oldName |

    newName [
	<category: 'accessing'>

	^ newName
    ]

    newName: aName [
	<category: 'accessing'>

	newName := aName
    ]

    oldName [
	<category: 'accessing'>

	^ oldName
    ]

    oldName: aName [
	<category: 'accessing'>

	oldName := aName
    ]

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Renamed'
    ]

    isRenamed [
	<category: 'testing'>

	^true
    ]

    RenamedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Renamed
    ]

    RenamedEvent class >> supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take."
    
	^ Array with: self classKind with: self categoryKind with: self protocolKind
    ]

    RenamedEvent class >> classCategoryRenamedFrom: anOldClassCategoryName to: aNewClassCategoryName [
	<category: 'instance creation'>

	^ (self classCategory: anOldClassCategoryName) oldName: anOldClassCategoryName; newName: aNewClassCategoryName
    ]

    RenamedEvent class >> class: aClass category: cat oldName: oldName newName: newName [
	<category: 'instance creation'>

	^ (self class: aClass category: cat) oldName: oldName; newName: newName
    ]
]

PK
     �Mh@W�jE�  �  "  Notification/RecategorizedEvent.stUT	 fqXO�XOux �  �  AbstractEvent subclass: RecategorizedEvent [
    | oldCategory |

    oldCategory [
	<category: 'accessing'>

	^ oldCategory
    ]

    oldCategory: aCategoryName [
	<category: 'accessing'>

	oldCategory := aCategoryName
    ]

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Recategorized'
    ]

    isRecategorized [
	<category: 'testing'>

	^ true
    ]

    RecategorizedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Recategorized
    ]

    RecategorizedEvent class >> supportedKinds [
	<category: 'accessing'>

	^ Array with: self classKind with: self methodKind
    ]

    RecategorizedEvent class >> class: aClass category: cat oldCategory: oldName [
	<category: 'instance creation'>

	^ (self class: aClass category: cat) oldCategory: oldName
    ]

    RecategorizedEvent class>> method: aMethod protocol: prot class: aClass oldProtocol: oldName [
	<category: 'instance creation'>

	^ (self method: aMethod protocol: prot class: aClass) oldCategory: oldName
    ]
]
PK
     �Mh@�mk,%  %  ,  Notification/ModifiedClassDefinitionEvent.stUT	 fqXO�XOux �  �  ModifiedEvent subclass: ModifiedClassDefinitionEvent [

    anyChanges [
	<category: 'testing'>

	^ self isSuperclassModified or: [ self areInstVarsModified or: [ self areClassVarsModified or: [ self areSharedPoolsModified ] ] ]
    ]

    printOn: aStream [
	<category: 'printing'>

        super printOn: aStream.
        aStream
	   nextPutAll: ' Super: ';
	    print: self isSuperclassModified;
	    nextPutAll: ' InstVars: ';
	    print: self areInstVarsModified;
	    nextPutAll: ' ClassVars: ';
	    print: self areClassVarsModified;
	    nextPutAll: ' SharedPools: ';
	    print: self areSharedPoolsModified
    ]

    classVarNames [
	<category: 'accessing'>

	^ item classVarNames asSet
    ]

    instVarNames [
	<category: 'accessing'>

	^ item instVarNames asSet
    ]

    oldClassVarNames [
	<category: 'accessing'>

	^ oldItem classVarNames asSet
    ]

    oldInstVarNames [
	<category: 'accessing'>

	^ oldItem instVarNames asSet
    ]

    oldSharedPools [
	<category: 'accessing'>

	^ oldItem sharedPools
    ]

    oldSuperclass [
	<category: 'accessing'>

	^ oldItem superclass
    ]

    sharedPools [
	<category: 'accessing'>

	^ item sharedPools
    ]

    superclass [
	<category: 'accessing'>

	^ item superclass
    ]

    areClassVarsModified [
	<category: 'testing'>
    
	^ self classVarNames ~= self oldClassVarNames
    ]

    areInstVarsModified [
	<category: 'testing'>

	^ self instVarNames ~= self oldInstVarNames
    ]

    areSharedPoolsModified [
	<category: 'testing'>

	^ self sharedPools ~= self oldSharedPools
    ]

    isSuperclassModified [
	<category: 'testing'>

	^ item superclass ~~ oldItem superclass
    ]

    ModifiedClassDefinitionEvent class >> supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take."
    
	^ Array with: self classKind
    ]

    ModifiedClassDefinitionEvent class >> classDefinitionChangedFrom: oldClass to: newClass [
	<category: 'instance creation'>

	| instance |
	instance := self item: newClass kind: self classKind.
	instance oldItem: oldClass.
	^ instance
    ]
]

PK
     &\h@              Notification/Kernel/UT	 �XO�XOux �  �  PK
     �Mh@j���  �  (  Notification/Kernel/AbstractNamespace.stUT	 eqXO�XOux �  �  Smalltalk.AbstractNamespace class extend [

    primNew: parent name: spaceName [
	"Private - Create a new namespace with the given name and parent, and
	add to the parent a key that references it."

	<category: 'instance creation'>
	| namespace |
	(parent at: spaceName ifAbsent: [ nil ]) isNamespace 
	    ifTrue: [ ^ parent at: spaceName asGlobalKey ].
	namespace := parent 
			at: spaceName asGlobalKey
			put: ((super new: 24)
				    setSuperspace: parent;
				    name: spaceName asSymbol;
				    yourself).
	VisualGST.SystemChangeNotifier root namespaceAdded: namespace.
	^ namespace
    ]

    gstNew: parent name: spaceName [
	<category: '*VisualGST'>

	^ (super new: 24)
		    setSuperspace: parent;
		    name: spaceName asSymbol;
		    yourself
    ]
]

Smalltalk.AbstractNamespace extend [

    removeSubspace: aSymbol [
	"Remove my subspace named aSymbol from the hierarchy."

	<category: 'namespace hierarchy'>
	| namespace spaceName |
	spaceName := aSymbol asGlobalKey.	"as with primNew:name:"
	namespace := self hereAt: spaceName.
	self subspaces remove: namespace
	    ifAbsent: 
	    [SystemExceptions.InvalidValue signalOn: aSymbol
		reason: 'aSymbol must name a subspace'].
	VisualGST.SystemChangeNotifier root namespaceRemoved: namespace.
	^ self removeKey: spaceName
    ]

    removeClass: aSymbol [

	<category: '*VisualGST'>
	| class className |
	className := aSymbol asGlobalKey.
	class := self hereAt: className.
	VisualGST.SystemChangeNotifier root classRemoved: class.
	^ self removeKey: className
    ]

    insertClass: aClass [

        <category: '*VisualGST'>
	self at: aClass name put: aClass.
        VisualGST.SystemChangeNotifier root classAdded: aClass.
    ]

    insertSubspace: aNamespace [
	"Insert an existing namespace"

	<category: '*VisualGST'>

        self
            at: aNamespace name asGlobalKey
            put: aNamespace.

	subspaces add: aNamespace.

	VisualGST.SystemChangeNotifier root namespaceAdded: aNamespace.
	^ aNamespace
    ]
]

PK
     �Mh@>��       Notification/Kernel/Metaclass.stUT	 eqXO�XOux �  �  Smalltalk.Metaclass extend [

    newMeta: className environment: aNamespace subclassOf: theSuperclass instanceVariableArray: arrayOfInstVarNames shape: shape classPool: classVarDict poolDictionaries: sharedPoolNames category: categoryName [
	"Private - create a full featured class and install it"

	<category: 'basic'>
	| aClass |
	aClass := self new.
	classVarDict environment: aClass.
	instanceClass := aClass.
	aNamespace at: className put: aClass.
	theSuperclass isNil ifFalse: [theSuperclass addSubclass: aClass].
	Behavior flushCache.
	aClass := aClass
		    superclass: theSuperclass;
		    setName: className;
		    setEnvironment: aNamespace;
		    setInstanceVariables: arrayOfInstVarNames;
		    setInstanceSpec: shape instVars: arrayOfInstVarNames size;
		    setClassVariables: classVarDict;
		    setSharedPools: sharedPoolNames;
		    makeUntrusted: theSuperclass isUntrusted;
		    category: categoryName;
		    yourself.
	VisualGST.SystemChangeNotifier root classAdded: aClass.
	^ aClass
    ]

    name: className environment: aNamespace subclassOf: newSuperclass instanceVariableArray: variableArray shape: shape classPool: classVarDict poolDictionaries: sharedPoolNames category: categoryName [
    "Private - create a full featured class and install it, or change an
     existing one"

    <category: 'basic'>
    | oldClass aClass realShape needToRecompileMetaclasses needToRecompileClasses |
    realShape := shape == #word 
	    ifTrue: [CSymbols.CLongSize = 4 ifTrue: [#uint] ifFalse: [#uint64]]
	    ifFalse: [shape].

    "Look for an existing metaclass"
    aClass := aNamespace hereAt: className ifAbsent: [nil].
    aClass isNil 
        ifTrue: 
	[^self 
	    newMeta: className
	    environment: aNamespace
	    subclassOf: newSuperclass
	    instanceVariableArray: variableArray
	    shape: realShape
	    classPool: classVarDict
	    poolDictionaries: sharedPoolNames
	    category: categoryName].
    aClass isVariable & realShape notNil 
        ifTrue: 
	[aClass shape == realShape 
	    ifFalse: 
	    [SystemExceptions.MutationError 
	        signal: 'Cannot change shape of variable class']].
    newSuperclass isUntrusted & self class isUntrusted not 
        ifTrue: 
	[SystemExceptions.MutationError 
	    signal: 'Cannot move trusted class below untrusted superclass'].
    needToRecompileMetaclasses := false.
    oldClass := aClass copy.
    aClass classPool isNil 
        ifTrue: [aClass setClassVariables: classVarDict]
        ifFalse: 
	[classVarDict keysDo: 
	    [:key | 
	    (aClass classPool includesKey: key) ifFalse: [aClass addClassVarName: key]].
	aClass classPool keys do: 
	    [:aKey | 
	    (classVarDict includesKey: aKey) 
	        ifFalse: 
		[aClass removeClassVarName: aKey.
		needToRecompileMetaclasses := true]]].

    "If instance or indexed variables change, update
     instance variables and instance spec of the class and all its subclasses"
    (needToRecompileClasses := variableArray ~= aClass allInstVarNames 
	    | needToRecompileMetaclasses) | (aClass shape ~~ realShape) 
        ifTrue: 
	[aClass instanceCount > 0 ifTrue: [ObjectMemory globalGarbageCollect].
	aClass
	    updateInstanceVars: variableArray
	    superclass: newSuperclass
	    shape: realShape].

    "Now add/remove pool dictionaries.  FIXME: They may affect name binding,
     so we should probably recompile everything if they change."
    aClass sharedPoolDictionaries isEmpty
        ifTrue: [aClass setSharedPools: sharedPoolNames]
        ifFalse: 
	[sharedPoolNames do: 
	    [:dict | 
	    (aClass sharedPoolDictionaries includes: dict) 
	        ifFalse: [aClass addSharedPool: dict]].
	aClass sharedPoolDictionaries copy do: 
	    [:dict | 
	    (sharedPoolNames includes: dict) 
	        ifFalse: 
		[aClass removeSharedPool: dict.
		needToRecompileMetaclasses := true]]].
    aClass superclass ~~ newSuperclass 
        ifTrue: 
	["Mutate the class if the set of class-instance variables changes."

	self superclass allInstVarNames ~= newSuperclass class allInstVarNames 
	    ifTrue: 
	    [aClass class
	        updateInstanceVars:
		newSuperclass class allInstVarNames,
		aClass class instVarNames
	        superclass: newSuperclass class
	        shape: aClass class shape].

	"Fix references between classes..."
	aClass superclass removeSubclass: aClass.
	newSuperclass addSubclass: aClass.
	aClass superclass: newSuperclass.
	needToRecompileClasses := true.

	"...and between metaclasses..."
	self superclass removeSubclass: self.
	newSuperclass class addSubclass: self.
	self superclass: newSuperclass class.
	needToRecompileMetaclasses := true].
    aClass category: categoryName.

    "Please note that I need to recompile the classes in this sequence;
     otherwise, the same error is propagated to each selector which is compiled
     after an error is detected even though there are no further compilation
     errors. Apparently, there is a bug in the primitive #primCompile:.  This
     can be cleaned up later"
    needToRecompileClasses | needToRecompileMetaclasses 
        ifTrue: 
	[aClass compileAll.
	needToRecompileMetaclasses ifTrue: [aClass class compileAll].
	aClass compileAllSubclasses.
	needToRecompileMetaclasses ifTrue: [aClass class compileAllSubclasses]].
    Behavior flushCache.
    VisualGST.SystemChangeNotifier root classDefinitionChangedFrom: oldClass to: aClass.
    ^aClass
    ]
]

PK
     �Mh@C��  �  '  Notification/Kernel/MethodDictionary.stUT	 fqXO�XOux �  �  Smalltalk.MethodDictionary extend [

    insertMethod: aCompiledMethod [
	<category: '*VisualGST'>

	self at: aCompiledMethod selector put: aCompiledMethod.
	VisualGST.SystemChangeNotifier root methodAdded: aCompiledMethod.
	^ aCompiledMethod
    ]

    removeMethod: aCompiledMethod [
        <category: '*VisualGST'>

        self removeKey: aCompiledMethod selector.
        VisualGST.SystemChangeNotifier root methodRemoved: aCompiledMethod.
        ^ aCompiledMethod
    ]
]

PK
     �Mh@��k�[  [    Notification/Kernel/Class.stUT	 eqXO�XOux �  �  Smalltalk.Class extend [

    category: aString [
	"Change the class category to aString"

	<category: 'accessing instances and variables'>

	| oldCategory |
	category = aString ifTrue: [ ^ self ].
	oldCategory := category.
	category := aString.
	VisualGST.SystemChangeNotifier root class: self recategorizedFrom: oldCategory to: category
    ]
]
PK
     �Mh@G�iL  L    Notification/ModifiedEvent.stUT	 fqXO�XOux �  �  AbstractEvent subclass: ModifiedEvent [
    | oldItem |

    oldItem [
	<category: 'accessing'>

	^ oldItem
    ]

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Modified'
    ]

    printOn: aStream [
	<category: 'printing'>

        super printOn: aStream.
	aStream
	    nextPutAll: ' oldItem: ';
	    print: oldItem
    ]

    isModified [
	<category: 'testing'>

	^ true
    ]

    oldItem: anItem [
	<category: 'private-accessing'>

	oldItem := anItem
    ]

    ModifiedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Modified
    ]

    ModifiedEvent class >> supportedKinds [
	<category: 'accessing'>
	"All the kinds of items that this event can take."
    
	^ Array with: self classKind with: self methodKind with: self categoryKind with: self protocolKind
    ]

    ModifiedEvent class >> classDefinitionChangedFrom: oldClass to: newClass [
	<category: 'instance creation'>

	^ ModifiedClassDefinitionEvent classDefinitionChangedFrom: oldClass to: newClass
    ]

    ModifiedEvent class >> methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass [
	<category: 'instance creation'>

	| instance |
	instance := self method: newMethod selector: aSymbol class: aClass.
	instance oldItem: oldMethod.
	^ instance
    ]

    ModifiedEvent class >> methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass requestor: requestor [
	<category: 'instance creation'>

        | instance |
	instance := self method: newMethod selector: aSymbol class: aClass requestor: requestor.
	instance oldItem: oldMethod.
	^ instance
    ]
]

PK
     �Mh@�r�|  |     Notification/ReorganizedEvent.stUT	 fqXO�XOux �  �  AbstractEvent subclass: ReorganizedEvent [

    printEventKindOn: aStream [
	<category: 'printing'>

	aStream nextPutAll: 'Reorganized'
    ]

    isReorganized [
	<category: 'testing'>

	^ true
    ]

    ReorganizedEvent class >> changeKind [
	<category: 'accessing'>

	^ #Reorganized
    ]

    supportedKinds [
	<category: 'accessing'>

	^ Array with: self classKind
    ]
]

PK
     �Mh@��r=  =    NamespaceFinder.stUT	 eqXO�XOux �  �  AbstractFinder subclass: NamespaceFinder [
    | namespace |

    NamespaceFinder class >> on: aNamespace [
	<category: 'instance creation'>

	^ (self new)
	    namespace: aNamespace;
	    yourself
    ]

    namespace: aNamespace [
	<category: 'accessing'>

	namespace := aNamespace
    ]

    displayString [
	<category: 'printing'>

	^ namespace displayString
    ]

    element [
        <category: 'accessing'>

        ^ namespace 
    ]

    updateBrowser: aGtkClassBrowserWidget [
	<category: 'events'>

	aGtkClassBrowserWidget selectANamespace: namespace
    ]
]

PK
     �Mh@�0��l  l    GtkHistoryWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkHistoryWidget [
    | browser model widget |

    GtkHistoryWidget class >> new [
	<category: 'instance creation'>

	^ super new
		initialize;
		yourself
    ]

    initialize [
	<category: 'initialization'>

	self mainWidget: self buildListView
    ]

    browser: aBrowser [
	<category: 'accessing'>

	browser := aBrowser
    ]

    buildListView [
	<category: 'user interface'>

        widget := (GTK.GtkTreeView createListWithModel: {{GtkColumnTextType title: 'History'}})
                            connectSignal: 'button-press-event' to: self selector: #'onPress:event:';
                            yourself.
        widget getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        widget getSelection connectSignal: 'changed' to: self selector: #onSelectionChanged.
        (model := GtkListModel on: widget getModel)
                                        contentsBlock: [ :each | {each name displayString} ].
        ^ GTK.GtkScrolledWindow withChild: widget
    ]

    refresh: historyStack [
	<category: 'user interface'>

	model
	    item: historyStack;
	    refresh.

        widget selectNth: historyStack selectedIndex.
    ]

    onPress: aGtkWidget event: aGdkEvent [
        <category: 'button event'>

        | menu aGdkButtonEvent |
        aGdkButtonEvent := aGdkEvent castTo: GTK.GdkEventButton type.
        aGdkButtonEvent button value = 3 ifFalse: [ ^ false ].
        menu := GTK.GtkMenu new.
        menu appendMenuItems: {{'Inspect a class'. self. #inspectClass}.
            {'Open in new tab'. self. #browseTabbedClass}.
            "{'Open in new window'. self. #browseClass}"}.
        menu attachToWidget: widget detacher: nil.
        menu popup: nil parentMenuItem: nil func: nil data: nil button: 3 activateTime: aGdkButtonEvent time value.
        menu showAll.
        ^ true
    ]

    targetObject [
        <category: 'evaluation'>

        ^ widget selection
    ]

    updateBrowser: aBrowser [
	<category: 'event'>

        aBrowser 
	    selectANamespace: self targetObject environment;
	    selectAClass: self targetObject
    ]
    
    inspectIt: anObject [
        <category: 'smalltalk event'>

        GtkInspector openOn: anObject
    ]

    inspectClass [
	<category: 'event'>

	widget hasSelectedItem ifFalse: [ ^ self ].
	InspectItCommand executeOn: self
    ]

    onSelectionChanged [
	<category: 'event'>

	widget hasSelectedItem ifFalse: [ ^ self ].
        model item selectedIndex = widget selectedIndex ifTrue: [^self].
        model item selectItem: widget selectedIndex.
    ]

    browseTabbedClass [
	<category: 'event'>

        "TODO: should reuse OpenTabbedBrowserCommand by giving a state to
         GtkHistoryWidget."
	widget hasSelectedItem ifFalse: [ ^ self ].
        self updateBrowser: GtkLauncher uniqueInstance classBrowser
    ]

    state [
        <category: 'state'>

        ^model item current
    ]
]

PK
     %\h@            
  StBrowser/UT	 �XO�XOux �  �  PK
     �Mh@��F��@  �@  "  StBrowser/GtkClassBrowserWidget.stUT	 fqXO�XOux �  �  GtkConcreteWidget subclass: GtkClassBrowserWidget [
    GtkClassBrowserWidget class [ | Undo | ]

    | launcher checkCode namespaceWidget classWidget classHierarchyWidget classHierarchyUpdate iCategoryWidget iMethodWidget cCategoryWidget cMethodWidget classAndInstanceSide codeWidget historyStack state |

    GtkClassBrowserWidget class >> title [
	<category: 'accessing'>

	^ 'Gtk class browser'
    ]

    GtkClassBrowserWidget class >> undoStack [
	<category: 'accessing'>

        ^ Undo ifNil: [ Undo := (UndoStack new)
				    initialize;
				    yourself ]
    ]

    launcher: aGtkLauncher [
        <category: 'accessing'>

        launcher := aGtkLauncher
    ]
    
    launcher [
	<category: 'accessing'>

	^ launcher
    ]

    buildBrowser [

	^ GTK.GtkHPaned addAll: {self buildCategoryClassesAndHierarchy. self buildProtocolAndMethod}
    ]

    buildCategoryAndClass [

	^ GTK.GtkHPaned addAll: {self buildNamespaceView. self buildClassView}
    ]

    buildClassBrowser [

	^ GTK.GtkHPaned addAll: {self buildClassCategoryView. self buildClassMethodView}
    ]

    buildInstanceBrowser [

	^ GTK.GtkHPaned addAll: {self buildInstanceCategoryView. self buildInstanceMethodView}
    ]

    buildProtocolAndMethod [

	^ classAndInstanceSide := (GTK.GtkNotebook new)
	    appendPage: self buildInstanceBrowser tabLabel: (GTK.GtkLabel new: 'Instance');
	    appendPage: self buildClassBrowser tabLabel: (GTK.GtkLabel new: 'Class');
	    showAll;
	    setCurrentPage: 0;
	    connectSignal: 'switch-page' to: self selector: #'classInstanceSwitchOn:page:number:';
	    yourself
    ]

    buildCategoryClassesAndHierarchy [

	^ (GTK.GtkNotebook new)
	    appendPage: self buildCategoryAndClass tabLabel: (GTK.GtkLabel new: 'Class');
	    appendPage: self buildHierarchy tabLabel: (GTK.GtkLabel new: 'Hierarchy');
	    showAll;
	    setCurrentPage: 0;
	    connectSignal: 'switch-page' to: self selector: #'namespaceHierarchySwitchOn:page:number:';
	    yourself
    ]

    buildNamespaceView [
	<category: 'user interface'>

	^ (namespaceWidget := self buildWidget: GtkCategorizedNamespaceWidget whenSelectionChangedSend: #onNamespaceChanged)
	    mainWidget
    ]

    buildClassView [
	<category: 'user interface'>

	^ (classWidget := self buildWidget: GtkCategorizedClassWidget whenSelectionChangedSend: #onClassChanged)
	    mainWidget
    ]

    buildCodeView [
	<category: 'user interface'>

	codeWidget := GtkSourceCodeWidget showAll 
			parentWindow: self parentWindow;
			browser: self;
			yourself.
    
	^ codeWidget mainWidget
    ]

    buildWidget: aClass whenSelectionChangedSend: aSymbol [
	<category: 'user interface'>

	^ aClass showAll
                whenSelectionChangedSend: aSymbol to: self;
                yourself
    ]

    buildHierarchy [
	<category: 'user interface'>

	^ (classHierarchyWidget := self buildWidget: GtkClassHierarchyWidget whenSelectionChangedSend: #onClassHierarchyChanged)
	    mainWidget
    ]

    buildInstanceCategoryView [
        <category: 'user interface'>

        ^ (iCategoryWidget := self buildWidget: GtkCategoryWidget whenSelectionChangedSend: #onInstanceSideCategoryChanged)
	    mainWidget
    ]

    buildClassCategoryView [
	<category: 'user interface'>

	^ (cCategoryWidget := self buildWidget: GtkCategoryWidget whenSelectionChangedSend: #onClassSideCategoryChanged)
	    mainWidget
    ]

    buildClassMethodView [
	<category: 'user interface'>

	^ (cMethodWidget := self buildWidget: GtkMethodWidget whenSelectionChangedSend: #onClassSideMethodChanged)
            browser: self;
	    mainWidget
    ]

    buildInstanceMethodView [
        <category: 'user interface'>

        ^ (iMethodWidget := self buildWidget: GtkMethodWidget whenSelectionChangedSend: #onInstanceSideMethodChanged)
            browser: self;
	    mainWidget
    ]

    buildBrowserPaned [
        <category: 'user interface'>

	^ GTK.GtkVPaned new
	    pack1: self buildBrowser resize: true shrink: false;
	    pack2: self buildCodeView resize: true shrink: true ;
	    showAll;
	    yourself
    ]

    initializeHistory [
	<category: 'initialize-release'>

	historyStack := HistoryStack new
            initialize: self;
            yourself
    ]

    initialize [
	<category: 'initialize-release'>

	state := NamespaceState on: self with: Smalltalk.
	state classCategory: Smalltalk category.
	classHierarchyUpdate := false.
	checkCode := true.

	self 
	    initializeHistory;
	    mainWidget: self buildBrowserPaned
    ]

    postInitialize [
	<category: 'initialize'>

	codeWidget postInitialize
    ]

    updateHistory: aClass [
	<category: 'history'>

        historyStack push: aClass.
        launcher isNil ifFalse: [ launcher historyChanged ]
    ]

    historyStack [
	<category: 'history'>

        ^historyStack
    ]

    grabFocus [
	<category: 'user interface'>

	namespaceWidget mainWidget grabFocus
    ]

    namespaceHierarchySwitchOn: aGtkNotebook page: aGtkNotebookPage number: aSmallInteger [
	<category: 'events'>

	classWidget hasSelectedClass ifFalse: [ ^ self ].
	aSmallInteger = 0 ifTrue: [ classHierarchyWidget classOrMeta: classWidget selectedClass ].
    ]

    classInstanceSwitchOn: aGtkNotebook page: aGtkNotebookPage number: aSmallInteger [
	<category: 'events'>

	self checkCodeWidgetAndUpdate: [
	    aSmallInteger = 0 
		ifTrue: [
		    iMethodWidget hasSelectedMethod 
			ifTrue: [ codeWidget source: (BrowserMethodSource on: iMethodWidget selectedMethod) ]
			ifFalse: [ codeWidget clear ] ]
		ifFalse: [
		    cMethodWidget hasSelectedMethod
			ifTrue: [ codeWidget source: (BrowserMethodSource on: cMethodWidget selectedMethod) ]
			ifFalse: [ codeWidget clear ] ] ]
    ]

    onNamespaceChanged [
	<category: 'events'>

	self updateState: namespaceWidget state.
	namespaceWidget hasSelectedNamespace ifTrue: [
	    GtkAnnouncer current announce: (GtkNamespaceSelectionChanged new
		selectedNamespace: self selectedNamespace;
		yourself) ]
    ]

    onClassChanged [
	<category: 'events'>

	self updateState: classWidget state.
	classWidget hasSelectedClass ifTrue: [
	    GtkAnnouncer current announce: (GtkClassSelectionChanged new
		selectedClass: self selectedClass;
		yourself) ]
    ]

    onClassHierarchyChanged [
	<category: 'events'>

	[classHierarchyUpdate := true.
	self updateState: classHierarchyWidget state]
	    ensure: [classHierarchyUpdate := false ]
    ]

    onInstanceSideCategoryChanged [
	<category: 'events'>

	self updateState: iCategoryWidget state
    ]

    onClassSideCategoryChanged [
	<category: 'events'>

	self updateState: cCategoryWidget state
    ]

    onInstanceSideMethodChanged [
	<category: 'events'>

	self updateState: iMethodWidget state
    ]

    onClassSideMethodChanged [
	<category: 'events'>

	self updateState: cMethodWidget state
    ]

    undoStack [
	<category: 'accessings'>

	^ self class undoStack
    ]

    cancel [
	<category: 'edit events'>

	codeWidget hasFocus ifTrue: [ ^codeWidget cancel ]
    ]

    undo [
	<category: 'edit events'>

	codeWidget hasFocus 
	    ifTrue: [ codeWidget undo ]
	    ifFalse: [ self undoStack undo ]
    ]

    redo [
	<category: 'edit events'>

        codeWidget hasFocus
            ifTrue: [ codeWidget redo ]
            ifFalse: [ self undoStack redo ]
    ]

    acceptIt [
	<category: 'smalltalk events'>

        AcceptItCommand executeOn: self
    ]

    viewedCategoryWidget [
         <category: 'category events'>

        ^ classAndInstanceSide getCurrentPage = 0
            ifTrue: [ iCategoryWidget ]
            ifFalse: [ cCategoryWidget ]
   ]

    viewedCategoryModel [
	<category: 'category events'>

	^ self viewedCategoryWidget model 
    ]

    viewedMethodWidget [
         <category: 'category events'>

        ^ classAndInstanceSide getCurrentPage = 0
            ifTrue: [ iMethodWidget ]
            ifFalse: [ cMethodWidget ]
   ]

    sourceCode [
	<category: 'accessing'>

	^ codeWidget sourceCode
    ]

    compileError: aString line: line [
        <category: 'method events'>

        codeWidget compileError: aString line: line
    ]

    selectedNamespace [
	<category: 'selection'>

	^ namespaceWidget selectedNamespace
    ]

    selectedClass [
	<category: 'selection'>

	^ classWidget selectedClass
    ]

    selectedClassCategory [
	<category: 'selection'>

	^ namespaceWidget selectedCategory
    ]

    clearClass [
	<category: 'private-selection'>

	classWidget clear
    ]

    clearCategories [
	<category: 'private-selection'>

        iCategoryWidget clear.
        cCategoryWidget clear
    ]

    clearMethods [
	<category: 'private-selection'>

        iMethodWidget clear.
        cMethodWidget clear
    ]

    clearSource [
	<category: 'private-selection'>

	codeWidget clear
    ]

    updateNamespaceWidget: aNamespace [
	<category: 'private-selection'>

	namespaceWidget selectANamespace: aNamespace.
        classWidget namespace: aNamespace category: ''.
        classHierarchyWidget emptyModel
    ]

    updateClassWidget: aClass [
	<category: 'private-selection'>

        classWidget selectAClass: aClass class.
	classHierarchyWidget classOrMeta: aClass class
    ]

    updateClassHierarchyWidget [
	<category: 'private-selection'>

        namespaceWidget selectedNamespace ~= classHierarchyWidget selectedClass environment
                                                    ifTrue: [ namespaceWidget selectANamespace: classHierarchyWidget selectedClass environment ]
                                                    ifFalse: [ (namespaceWidget selectedCategory fullname ~= '' and: [ namespaceWidget selectedCategory ~= classHierarchyWidget selectedClass asClass classCategory ])
                                                                                        ifTrue: [ namespaceWidget selectANamespace: classHierarchyWidget selectedClass environment ] ].
        classWidget selectAClass: classHierarchyWidget selectedClass class
    ]

    updateCategoryWidget: aClass [
	<category: 'private-selection'>

        iCategoryWidget classOrMeta: aClass.
        cCategoryWidget classOrMeta: aClass class
    ]

    updateNamespaceOfClass: aNamespace classCategory: aClassCategory [
	<category: 'private-selection'>

	classWidget namespace: aNamespace category: aClassCategory fullname.
	classHierarchyUpdate ifFalse: [ classHierarchyWidget emptyModel ].
	self
	    clearCategories;
	    clearMethods
    ]

    updateClassOfCategory: aClass [
	<category: 'private-selection'>

        classHierarchyUpdate ifFalse: [ classHierarchyWidget classOrMeta: aClass ].
        self
	    updateCategoryWidget: aClass;
	    updateHistory: aClass;
	    clearMethods
	
    ]

    updateInstanceSideMethodCategory: aString [
	<category: 'private-selection'>

        iMethodWidget class: classWidget selectedClass withCategory: aString
    ]

    updateClassSideMethodCategory: aString [
        <category: 'private-selection'>

        cMethodWidget class: classWidget selectedClass class withCategory: aString
    ]

    selectANamespace: aNamespace [
	<Category: 'selection'>

	self
	    updateNamespaceWidget: aNamespace;
	    clearCategories;
	    clearMethods;
	    source: (NamespaceHeaderSource on: aNamespace)
    ]

    selectAClass: aClass [
	<category: 'selection'>

	self 
	    updateClassWidget: aClass;
	    updateCategoryWidget: aClass;
	    clearMethods
    ]

    selectMethod: aSelector in: aMethodWidget withCategory: aCategoryWidget from: aClass [
	<category: 'selection'>

	aCategoryWidget
	    classOrMeta: aClass;
	    selectACategory: (aClass compiledMethodAt: aSelector) methodCategory.
        aMethodWidget
            class: aClass withCategory: (aClass compiledMethodAt: aSelector) methodCategory.
	aMethodWidget selectAMethod: aSelector
    ]

    selectClass: aSelector in: aMethodWidget withCategory: aCategoryWidget [
        <category: 'selection'>

	| class |
        class := classWidget selectedClass.
	self selectMethod: aSelector in: aMethodWidget withCategory: aCategoryWidget from: class
    ]

    selectMetaclass: aSelector in: aMethodWidget withCategory: aCategoryWidget [
        <category: 'selection'>

	| class |
        class := classWidget selectedClass class.
	self selectMethod: aSelector in: aMethodWidget withCategory: aCategoryWidget from: class
    ]

    selectAnInstanceMethod: aSelector [
        <category: 'selection'>

	self selectClass: aSelector in: iMethodWidget withCategory: iCategoryWidget.
	classAndInstanceSide setCurrentPage: 0
    ]

    selectAClassMethod: aSelector [
	<category: 'selection'>

	self selectMetaclass: aSelector in: cMethodWidget withCategory: cCategoryWidget.
	classAndInstanceSide setCurrentPage: 1
    ]

    targetObject [
        <category: 'target'>

        ^ state classOrMeta
    ]

    doIt: object [
	<category: 'smalltalk event'>

	codeWidget doIt: object
    ]

    debugIt: object [
	<category: 'smalltalk event'>

        codeWidget debugIt: object
    ]

    inspectIt: object [
	<category: 'smalltalk event'>

        codeWidget inspectIt: object
    ]

    printIt: object [
	<category: 'smalltalk event'>

        codeWidget printIt: object
    ]

    doIt [
	<category: 'smalltalk event'>

	DoItCommand executeOn: self
    ]

    debugIt [
	<category: 'smalltalk event'>

	DebugItCommand executeOn: self
    ]

    inspectIt [
	<category: 'smalltalk event'>

	InspectItCommand executeOn: self
    ]

    printIt [
	<category: 'smalltalk event'>

	PrintItCommand executeOn: self
    ]

    forward [
	<category: 'history events'>

	historyStack next.
        launcher isNil ifFalse: [ launcher historyChanged ]
    ]

    back [
	<category: 'history events'>

	historyStack previous.
        launcher isNil ifFalse: [ launcher historyChanged ]
    ]

    sourceCodeWidgetHasFocus [
	<category: 'testing'>

	^ parentWindow getFocus address = codeWidget textview address
    ]

    copy [
        <category: 'text editing'>

	codeWidget copy
    ]

    cut [
        <category: 'text editing'>

	codeWidget cut
    ]

    paste [
        <category: 'text editing'>

	codeWidget paste
    ]

    selectAll [
        <category: 'text editing'>

	codeWidget selectAll
    ]
 
    hasSelection [
	<category:'text testing'>

	^ codeWidget hasSelection
    ]
 
    selectedMethodSymbol [
        <category: 'text editing'>

        ^ codeWidget selectedMethodSymbol
    ]

    selectedText [
	<category: 'text editing'>

	^ codeWidget selectedText
    ]

    doNotCheckCode [
	<category: 'text editing'>

	checkCode := false
    ]

    checkCodeWidgetAndUpdate: aBlock [
        <category: 'text editing'>

        self saveCodeOr: [ self clearUndo. aBlock value ]
    ]

    saveCodeOr: dropBlock [
        <category: 'saving'>

        | dialog |
        checkCode ifFalse: [ checkCode := true. dropBlock value. ^ self ].
        self hasChanged ifFalse: [ dropBlock value. ^ self ].
        dialog := GTK.GtkMessageDialog
                                new: self parentWindow
                                flags: GTK.Gtk gtkDialogDestroyWithParent
                                type: GTK.Gtk gtkMessageWarning
                                buttons: GTK.Gtk gtkButtonsNone
                                message: 'Accept changes before exiting?'
                                tip: 'If you do not accept them, your changes to %1 will be lost...' % {self state}.

        dialog
            addButton: 'Drop' responseId: 0;
            addButton: 'Cancel' responseId: 2;
            addButton: 'Accept' responseId: 1;
            showModalOnAnswer: [ :dlg :res |
                res = 1 ifTrue: [ self acceptIt ].
                res <= 1 ifTrue: dropBlock.
                dlg destroy ].
    ]

    state [
	<category: 'accessing'>

	^ state
    ]

    updateState: newState [
	<category: 'accessing'>

        newState isNil ifTrue: [ ^ self ].
        self checkCodeWidgetAndUpdate: [ self state: newState ]
    ]

    state: aState [
	<category: 'accessing'>

        aState updateBrowser: self.
	state := aState
    ]

    clearUndo [
	<category: 'code saved'>

	codeWidget clearUndo
    ]

    source: aSourceFormatter [
	<category: 'code saved'>

	codeWidget source: aSourceFormatter
    ]

    codeSaved [
	<category: 'code saved'>

	codeWidget codeSaved
    ]

    close [
	<category: 'user interface'>

	self checkCodeWidgetAndUpdate: []
    ]

    hasChanged [
	<category: 'testing'>

	^ codeWidget hasChanged
    ]

    showFind [
	<category: 'user interface'>

	codeWidget showFind
    ]

    showReplace [
	<category: 'user interface'>

	codeWidget showReplace
    ]
]

PK
     �Mh@?�s�  �  $  StBrowser/GtkClassHierarchyWidget.stUT	 fqXO�XOux �  �  GtkConcreteWidget subclass: GtkClassHierarchyWidget [
    | root dic classesTree model classOrMeta |

    GtkClassHierarchyWidget >> on: aClass [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    classOrMeta: aClass;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	dic := Dictionary new.
	self 
	    mainWidget: self buildTreeView;
	    registerNotifier
    ]

    registerNotifier [
        <category: 'initialize-release'>

       " (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #class change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Removed using: #'removeEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'recategorizedEvent:'
   " ]

    classOrMeta [
	<category: 'accessing'>
    
	^ classOrMeta
    ]

    classOrMeta: aClass [
	<category: 'accessing'>

	classOrMeta := aClass.
	dic := Dictionary new.
	self buildSuperclasses.
	model 
	    item: #root;
	    refresh.
	
	classesTree 
		expandAll;
		select: aClass
    ]

    emptyModel [
        classesTree getSelection unselectAll
    ]

    buildSuperclasses [
	| parent |

	parent := self classOrMeta asClass.
	[ parent isNil ] whileFalse: [
	    dic at: (parent superclass ifNil: [ #root ]) put: {parent}.
	    root := parent.
	    parent := parent superclass ].
    ]

    buildTreeView [
	<category: 'user interface'>
   
        classesTree := GTK.GtkTreeView createTreeWithModel: {{GtkColumnTextType title: 'Classes'}}.
        classesTree getSelection setMode: GTK.Gtk gtkSelectionBrowse.
        (model := GtkTreeModel on: classesTree getModel)
                                        item: #root;
                                        childrenBlock: [ :each |
					    dic at: each ifAbsent: [ | col |
                                                        col := SortedCollection sortBlock: [ :a :b | a asClass name <= b asClass name ].
							col addAll: each subclasses.
                                            col ] ];
                                        contentsBlock: [ :each | {each asClass name asString, ' '} ].
        ^ GTK.GtkScrolledWindow withChild: classesTree 
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	classesTree getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector
    ]

    hasSelectedClass [
	<category: 'testing'>

	^ classesTree hasSelectedItem
    ]

    selectedClass [
	<category: 'accessing'>

	self hasSelectedClass ifFalse: [ ^ self classOrMeta " self error: 'Nothing is selected' " ].
	^ classesTree selection asClass
    ]

    state [
        <category: 'testing'>

        self hasSelectedClass ifTrue: [ ^ ClassState with: self selectedClass ].
        ^ BrowserState new
    ]

    updateBrowser: aGtkClassBrowserWidget [
        <category: 'events'>

	self hasSelectedClass ifFalse: [ ^ self ].
	aGtkClassBrowserWidget updateClassHierarchyWidget
    ]
]

PK
     �Mh@ij�"  "  *  StBrowser/GtkCategorizedNamespaceWidget.stUT	 fqXO�XOux �  �  GtkConcreteWidget subclass: GtkCategorizedNamespaceWidget [
    | namespaceTree model |

    initialize [
        <category: 'initialization'>

        self mainWidget: self buildTreeView.
	self registerNotifier
    ]

    registerNotifier [
        <category: 'initialize-release'>

        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #namespace change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #namespace change: #Removed using: #'removeEvent:';
	    notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'classRecategorizedEvent:'
    ]

    buildTreeView [
        <category: 'user interface'>

	namespaceTree := GtkScrollTreeWidget createTreeWithModel: {{GtkColumnPixbufType visible. GtkColumnTextType title: 'Namespaces'}}.
	namespaceTree connectToWhenPopupMenu: (NamespaceMenus on: self).
	namespaceTree treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	(model := GtkTreeModel on: namespaceTree treeView getModel)
                                        item: FakeNamespace;
                                        childrenBlock: [ :each | (each subspaces asArray sort: [ :a :b | a name <= b name ]), (each categories values sort: [ :a :b | a name <= b name ]) ];
                                        contentsBlock: [ :each | {each icon. each name asString} ];
                                        connectSignal: 'row-has-child-toggled' to: self selector: #'childToggled:path:iter:';
                                        refresh.
	^ namespaceTree mainWidget
    ]

    whenSelectionChangedSend: aSelector to: anObject [
        <category: 'events'>

        namespaceTree treeView getSelection
            connectSignal: 'changed' to: anObject selector: aSelector
    ]

    selectANamespace: aNamespace [
        <category: 'item selection'>

	(self hasSelectedNamespace and: [ self selectedNamespace == aNamespace ]) ifTrue: [ ^ self ].
	(namespaceTree treeView)
			    expandAll;
			    select: aNamespace
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ namespaceTree treeView hasSelectedItem
    ]

    selectedNamespace [
        <category: 'accessing'>

	self hasSelectedNamespace ifFalse: [ self error: 'nothing is selected' ].
	^ namespaceTree treeView selection namespace
    ]

    selectedCategory [
        <category: 'accessing'>

        self hasSelectedNamespace ifFalse: [ self error: 'nothing is selected' ].
        ^ namespaceTree treeView selection category
    ]

    state [
        <category: 'events'>

        self hasSelectedNamespace ifFalse: [ ^ BrowserState new ].
        ^ (NamespaceState with: self selectedNamespace)
            classCategory: self selectedCategory;
            yourself
    ]

    childToggled: model path: path iter: iter [
	<category: 'signals'>

	namespaceTree treeView collapseRow: path.
	((model at: iter) at: 3) isNamespace ifTrue: [
	    ((model at: iter) at: 3) subspaces isEmpty ifFalse: [
		namespaceTree treeView expandRow: path openAll: false ] ]
    ]

    addEvent: anEvent [
        <category: 'model event'>

	model append: anEvent item parent: anEvent item superspace
    ]

    removeEvent: anEvent [
        <category: 'model event'>

        model remove: anEvent item
    ]

    classRecategorizedEvent: anEvent [
        <category: 'model event'>

        | namespace root toAdd |
        namespace := anEvent item environment.
	(anEvent item category isNil or: [ anEvent item category size = 0 ]) ifTrue: [ ^ self ].
        root := ClassCategory named: anEvent item category into: namespace.
	(model hasItem: root) ifTrue: [ ^ self ].
	[ root parent isNil or: [ (model hasItem: root) ] ] whileFalse: [ 
					toAdd := root.
					root := root parent ].
	root parent ifNil: [ root := namespace ].
	model append: toAdd parent: root
    ]
]

PK
     �Mh@'�iR�  �  &  StBrowser/GtkCategorizedClassWidget.stUT	 fqXO�XOux �  �  Smalltalk.String extend [

    fullname [

	^ self
    ]
]

GtkConcreteWidget subclass: GtkCategorizedClassWidget [
    | classesTree column model namespace category |

    GtkCategorizedClassWidget >> on: aNamespace [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    namespace: aNamespace;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self
	    category: '';
	    mainWidget: self buildTreeView;
	    registerNotifier
    ]

    registerNotifier [
        <category: 'initialize-release'>

        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #class change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Removed using: #'removeEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #'recategorizedEvent:';
            notify: self ofSystemChangesOfItem: #class change: #Modified using: #'modificationEvent:'
    ]

    category: aString [
        <category: 'accessing'>

        category := aString.
    ]

    category [
        <category: 'accessing'>

        ^ category
    ]

    namespace [
	<category: 'accessing'>
    
	^ namespace
    ]

    namespace: aNamespace [
	<category: 'accessing'>

	namespace := aNamespace.
    ]

    namespace: aNamespace category: aString [
        <category: 'accessing'>

	(aNamespace == self namespace and: [ aString = self category ]) ifTrue: [ ^ self ].
        self
            category: aString;
            namespace: aNamespace.
	model refresh.
	classesTree treeView expandAll
    ]

    appendClass: aClass to: anArray [
        <category: 'model builder'>

        (aClass environment = self namespace and: [ self category isEmpty or: [ self category = aClass category or: [ (self namespace displayString, '-', self category) = aClass category ] ] ]) 
		    ifTrue: [ anArray add: aClass ]
		    ifFalse: [ aClass subclassesDo: [ :each | self appendClass: each to: anArray ] ]
    ]

    root [
	<category: 'accessing'>

	^ Class
    ]

    selectionMode [
	<category: 'accessing'>

	^ GTK.Gtk gtkSelectionBrowse
    ]

    clear [
        <category: 'accessing'>

        model clear
    ]

    buildTreeView [
	<category: 'user interface'>
   
        classesTree := GtkScrollTreeWidget createTreeWithModel: {{GtkColumnTextType title: 'Classes'}}.
        classesTree connectToWhenPopupMenu: (ClassMenus on: self).
        classesTree treeView getSelection setMode: self selectionMode.
        (model := GtkTreeModel on: classesTree treeView getModel)
					item: self root;
					childrenBlock: [ :each | | col | 
							    col := SortedCollection sortBlock: [ :a :b | a asClass name <= b asClass name ]. 
							    each subclassesDo: [ :subclasses | self appendClass: subclasses to: col ]. 
							    col ];
                                        contentsBlock: [ :each | {each asClass name asString, ' '} ].
        ^ classesTree mainWidget
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	classesTree treeView getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector
    ]

    selectionMode: aSelectionMode [
	<category: 'user interface'>

	classesTree treeView getSelection setMode: aSelectionMode.
    ]

    selectedNamespace [
	<category: 'accessing'>

	^ namespace
    ]

    hasSelectedNamespace [
        <category: 'testing'>

        ^ true
    ]

    hasSelectedClass [
	<category: 'testing'>

	^ classesTree treeView hasSelectedItem
    ]

    state [
        <category: 'testing'>

        self hasSelectedClass ifTrue: [ ^ ClassState with: self selectedClass ].
        namespace ifNotNil: [ ^ (NamespaceState with: namespace)
				    classCategory: self category;
				    yourself ].
        ^ BrowserState new
    ]

    selectedClass [
	<category: 'accessing'>

	self hasSelectedClass ifFalse: [ self error: 'nothing is selected' ].
	^ classesTree treeView selection asClass
    ]

    selectAClass: aClass [
	<category: 'item selection'>

	classesTree treeView select: aClass
    ]

    addToModel: aClass [

	(model includes: aClass class) ifTrue: [ ^ self ].
	(aClass superclass environment == self namespace and: [ aClass superclass category = self category or: [ self category isEmpty ] ]) 
				    ifFalse: [ model append: aClass class ] 
				    ifTrue: [ model append: aClass class parent: aClass superclass class ]
    ]

    addEvent: anEvent [
        <category: 'model event'>

        anEvent item environment == self namespace ifFalse: [ ^ self ].
        (anEvent item category = self category or: [ self category isEmpty ]) ifFalse: [ ^ self ].
	self addToModel: anEvent item
    ]

    removeEvent: anEvent [
        <category: 'model event'>

        anEvent item environment == self namespace ifFalse: [ ^ self ].
        (anEvent item category = self category or: [ self category isEmpty ]) ifFalse: [ ^ self ].
        model remove: anEvent item class
    ]

    modificationEvent: anEvent [
        <category: 'model event'>

        (anEvent item environment == self namespace or: [ anEvent isSuperclassModified not ]) ifFalse: [ ^ self ].
        (anEvent oldItem category = self category or: [ anEvent oldItem category isNil and: [ self category isEmpty ] ])
		    ifTrue: [ model remove: anEvent item class ifAbsent: [ nil ] ].
        (anEvent item category = self category or: [ anEvent item category isNil and: [ self category isEmpty ] ]) 
		    ifTrue: [ self addToModel: anEvent item ]
    ]

    recategorizedEvent: anEvent [
        <category: 'model event'>

        anEvent item environment == self namespace ifFalse: [ ^ self ].
        (anEvent oldCategory = self category or: [ anEvent oldCategory isNil and: [ self category isEmpty and: [ model includes: anEvent item ] ] ]) ifTrue: [ model remove: anEvent item class ].
        (anEvent item category = self category or: [ anEvent item category isNil and: [ self category isEmpty ] ]) ifTrue: [ self addToModel: anEvent item ]
    ]
]

PK
     �Mh@r�p  p    StBrowser/GtkCategoryWidget.stUT	 fqXO�XOux �  �  GtkConcreteWidget subclass: GtkCategoryWidget [
    | categoryTree categories model class |

    GtkCategoryWidget >> on: aClass [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    classOrMeta: aClass;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self initializeCategories.
	self mainWidget: self buildTreeView.
	self registerNotifier
    ]

    initializeCategories [

	categories := Set new.
    ]

    registerNotifier [
        <category: 'initialize-release'>

        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #method change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #method change: #Removed using: #'removeEvent:'
    ]

    classOrMeta [
	<category: 'accessing'>
    
	^ class
    ]

    classOrMeta: aClass [
	<category: 'accessing'>

	class := aClass.
	categories empty.
	model
	    item: (self buildCategory: categories);
	    refresh
    ]

    buildCategory: aSet [
        <category: 'model builder'>

        aSet add: '*'.
	self classOrMeta methodDictionary ifNil: [ ^ aSet ].
        self classOrMeta methodDictionary do: [ :each | aSet add: each methodCategory ].
        ^ aSet asSortedCollection
    ]

    emptyModel [
	<category: 'accessing'>

	self clear
    ]

    clear [
        <category: 'accessing'>

        model clear
    ]

    buildTreeView [
        <category: 'user interface'>
    
	categoryTree := GtkScrollTreeWidget createListWithModel: {{GtkColumnTextType title: 'Method categories'}}.
	categoryTree treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	categoryTree connectToWhenPopupMenu: (CategoryMenus on: self).
        (model := GtkListModel on: categoryTree treeView getModel)
                                        contentsBlock: [ :each | {each displayString} ].
	^ categoryTree mainWidget
    ]

    unselectAll [
	<category: 'selection'>

	categoryTree treeView getSelection unselectAll
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	categoryTree treeView getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector
    ]

    state [
        <category: 'testing'>

        ^ self hasSelectedCategory 
			ifFalse: [ ClassState with: self classOrMeta ]
			ifTrue: [ CategoryState with: self classOrMeta->self selectedCategory ]
    ]

    hasSelectedCategory [
	<category: 'testing'>

	^ categoryTree treeView hasSelectedItem
    ]

    selectedCategory [
	<category: 'accessing'>

	self hasSelectedCategory ifFalse: [ self error: 'nothing is selected' ].
	^ categoryTree treeView selection
    ]

    selectACategory: aString [
        <category: 'item selection'>

	categoryTree treeView select: aString
    ]

    findIterInACategory: aString [
        <category: 'item selection'>

        | result |
        result := model findIterInACategory: aString.
        categoryTree treeView scrollToCell: (model gtkModel getPath: result) column: nil useAlign: false rowAlign: 0.5 colAlign: 0.5.
        ^ result
    ]

    viewedCategoryWidget [
	<category: 'accessing'>

	^ self
    ]

    viewedCategoryModel [
	<category: 'accessing'>

	^ model
    ]

    removeEmptyCategory [
	<category: 'update'>

	| set |
	set := Set new.
	self buildCategory: set.
	(categories - set) do: [ :each | 
			model remove: each.
			categories remove: each ifAbsent: [] ]
    ]

    addEvent: anEvent [
        <category: 'event'>

        (anEvent item methodClass == self classOrMeta and: [ (model hasItem: anEvent item methodCategory) not ]) ifFalse: [ ^ self ].
        categories add: anEvent item methodCategory.
	model append: anEvent item methodCategory.
	self removeEmptyCategory
    ]

    removeEvent: anEvent [
        <category: 'event'>

        (anEvent item methodClass == self classOrMeta and: [ (model hasItem: anEvent item methodCategory) not ]) ifFalse: [ ^ self ].
	self removeEmptyCategory
    ]
]

PK
     �Mh@���A      StBrowser/GtkMethodWidget.stUT	 fqXO�XOux �  �  GtkConcreteWidget subclass: GtkMethodWidget [
    | browser model methodTree class category |

    GtkMethodWidget >> on: aClass withCategory: aCategory [
	<category: 'instance creation'>

	^ (self new)
	    initialize;
	    class: aClass withCategory: aCategory;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	self 
	    mainWidget: self buildTreeView;
	    registerNotifier
    ]

    registerNotifier [
        <category: 'initialize-release'>

        (GtkLauncher uniqueInstance systemChangeNotifier)
            notify: self ofSystemChangesOfItem: #method change: #Added using: #'addEvent:';
            notify: self ofSystemChangesOfItem: #method change: #Removed using: #'removeEvent:'
    ]

    browser [
	<category: 'accessing'>

	^ browser
    ]

    browser: anObject [
	<category: 'accessing'>

	browser := anObject.
    ]

    category [
	<category: 'accessing'>

	^ category
    ]

    category: aString [
	<category: 'accessing'>

	category := aString.
	self classOrMeta methodDictionary ifNil: [ 
		model clear. 
		^ self].
	model 
	    item: ((self classOrMeta methodDictionary select: [ :each | self category = '*' or: [ each methodCategory = self category ] ]) 
												    asArray sort: [ :a :b | a selector <= b selector ]);
	    refresh
    ]

    classOrMeta [
	<category: 'accessing'>

	^ class
    ]

    class: aClass withCategory: aString [
	<category: 'accessing'>

	class := aClass.
	self category: aString
    ]

    gtkModel [
	^ methodTree treeView getModel
    ]

    emptyModel [
        <category: 'accessing'>

	self clear
    ]

    clear [
        <category: 'accessing'>

	model clear
    ]

    includesCategory: aSymbol [
        <category: 'testing'>

        self category = '*' ifTrue: [ ^ true ].
        (self category = 'still unclassified' and: [ aSymbol isNil ]) ifTrue: [ ^ true ].
        ^ self category = aSymbol
    ]

    buildTreeView [
        <category: 'user interface'>
    
	methodTree := GtkScrollTreeWidget createListWithModel: {{GtkColumnPixbufType visible. GtkColumnTextType title: 'Methods'}}.
        methodTree connectToWhenPopupMenu: (MethodMenus on: self).
	methodTree treeView getSelection setMode: GTK.Gtk gtkSelectionBrowse.
	(model := GtkListModel on: methodTree treeView getModel)
					contentsBlock: [ :each | {each methodViewIcon. each selector asString} ].
	^ methodTree mainWidget
    ]

    hasSelectedTestMethod [
	<category: 'button event'>

	self ifNoSelection: [ ^ false ].
	^ (self classOrMeta inheritsFrom: TestCase)
	    and: [ self selectedMethodSymbol startsWith: 'test' ]
    ]

    whenSelectionChangedSend: aSelector to: anObject [
	<category: 'events'>

	methodTree treeView getSelection
	    connectSignal: 'changed' to: anObject selector: aSelector
    ]

    launcher [
	<category: 'accessing'>

	^ browser ifNotNil: [ browser launcher ]
    ]

    browserHasFocus [
	<category: 'accessing'>

	^ true
    ]

    sourceCodeWidgetHasFocus [
	<category: 'accessing'>

	^ false
    ]

    classOrMeta [
	<category: 'accessing'>

	^ class
    ]

    selectedCategory [
	<category: 'accessing'>

	^ category = '*' 
	    ifTrue: [ nil ]
	    ifFalse: [ category ]
    ]

    hasSelectedMethod [
	<category: 'testing'>

	^ methodTree treeView hasSelectedItem
    ]

    ifNoSelection: aBlock [
        <category: 'testing'>

        self hasSelectedMethod ifFalse: aBlock
    ]

    selectedMethodSymbol [
	<category: 'accessing'>

        ^ self selectedMethod selector
    ]

    selectedMethod [
	<category: 'accessing'>

	self ifNoSelection: [ self error: 'nothing is selected' ].
        ^ methodTree treeView selection 
    ]

    selectAMethod: aSymbol [
        <category: 'item selection'>

	methodTree treeView select: (self classOrMeta methodDictionary at: aSymbol)
    ]

    sourceCode [
	<category: 'accessing'>

	self ifNoSelection: [ self error: 'Nothing is selected' ].
	^ (self classOrMeta compiledMethodAt: self selectedMethodSymbol) methodRecompilationSourceString
    ]

    state [
        <category: 'testing'>

        self ifNoSelection: [ ^ BrowserState new ].
        ^ MethodState with: self selectedMethod
    ]

    addEvent: anEvent [
        <category: 'event'>

        (anEvent item methodClass == self classOrMeta and: [ self includesCategory: anEvent item methodCategory ] ) ifFalse: [ ^ self ].
        model append: anEvent item
    ]

    removeEvent: anEvent [
        <category: 'event'>

        (anEvent item methodClass == self classOrMeta and: [ self includesCategory: anEvent item methodCategory ]) ifFalse: [ ^ self ].
        model remove: anEvent item
    ]
]

PK
     �Mh@jȒ�   �     GtkTranscriptWidget.stUT	 eqXO�XOux �  �  GtkWorkspaceWidget subclass: GtkTranscriptWidget [

    initialize [
	<category: 'initialization'>

	Transcript message: self->#update:.
	super initialize
    ]

    update: aString [
	<category: 'updating'>

	self buffer insertAtEnd: aString
    ]
]
PK
     &\h@              Tetris/UT	 �XO�XOux �  �  PK
     �Mh@����  �    Tetris/TetrisPieceZ.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

TetrisPiece subclass: TetrisPieceZ [
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    TetrisPieceZ class >> piece [
	<category: 'pieces'>

	^#( #( #(1 0 0 0)
	       #(1 1 0 0)
	       #(0 1 0 0)
	       #(0 0 0 0))
	    #( #(0 1 1 0)
	       #(1 1 0 0)
	       #(0 0 0 0)
	       #(0 0 0 0))
	    #( #(1 0 0 0)
	       #(1 1 0 0)
	       #(0 1 0 0)
	       #(0 0 0 0))
	    #( #(0 1 1 0)
	       #(1 1 0 0)
	       #(0 0 0 0)
	       #(0 0 0 0)))
    ]

    TetrisPieceZ class >> color [
	<category: 'pieces'>

	^ Cairo.Color r: 0.99 g: 0.55 b: 0 "DarkOrange"
    ]
]

PK
     �Mh@�*���  �    Tetris/TetrisPieceWidget.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"

Object subclass: TetrisPieceWidget [

    | position size color |

    position: aPoint [
	<category: 'accessing'>

	position := aPoint
    ]

    size: anInteger [
	<category: 'accessing'>

	size := anInteger
    ]
    
    color: aColor [
	<category: 'accessing'>

	color := aColor
    ]

    drawOn: aCanvas [
	<category: 'drawing'>

	self subclassResponsibility
    ]
]
PK
     �Mh@����  �    Tetris/TetrisPieceL.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

TetrisPiece subclass: TetrisPieceL [
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    TetrisPieceL class >> piece [
	<category: 'pieces'>

	^#( #( #(1 0 0 0)
	       #(1 0 0 0)
	       #(1 1 0 0)
	       #(0 0 0 0)) 
	    #( #(1 1 1 0)
	       #(1 0 0 0)
	       #(0 0 0 0)
	       #(0 0 0 0))
	    #( #(1 1 0 0)
	       #(0 1 0 0)
	       #(0 1 0 0)
	       #(0 0 0 0))
	    #( #(0 0 1 0)
	       #(1 1 1 0)
	       #(0 0 0 0)
	       #(0 0 0 0)))
    ]

    TetrisPieceL class >> color [
	<category: 'pieces'>

	^ Cairo.Color r: 0.74 g: 0.71 b: 0.42 "DarkKhaki"
    ]
]

PK
     �Mh@"O�  �    Tetris/TetrisPieceT.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

TetrisPiece subclass: TetrisPieceT [
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    TetrisPieceT class >> piece [
	<category: 'pieces'>
	^#( #( #(0 1 0 0)
	       #(1 1 1 0)
	       #(0 0 0 0)
	       #(0 0 0 0))
	    #( #(1 0 0 0)
	       #(1 1 0 0)
	       #(1 0 0 0)
	       #(0 0 0 0)) 
	    #( #(1 1 1 0)
	       #(0 1 0 0)
	       #(0 0 0 0)
	       #(0 0 0 0))
	    #( #(0 1 0 0)
	       #(1 1 0 0)
	       #(0 1 0 0)
	       #(0 0 0 0)))
    ]

    TetrisPieceT class >> color [
	<category: 'pieces'>

	^ Cairo.Color r: 0.13 g: 0.54 b: 0.13 "ForestGreen"
    ]
]
PK
     �Mh@�b�)  )    Tetris/TetrisPiece.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: TetrisPiece [
    | rotation origin |
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    Pieces := nil.

    TetrisPiece class >> pieces [
	<category: 'accessing'>

	^ Pieces ifNil: [ Pieces := self subclasses asOrderedCollection ]
    ]

    TetrisPiece class >> random [
	<category: 'pieces'>

	| piece |
	piece := Random between: 1 and: 7.
	^ (self pieces at: piece) new
	    initialize;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	rotation := 1.
	origin := Point new
    ]

    piece [
	<category: 'accessing'>

	^ self class piece
    ]

    color [
	<category: 'drawing'>

	^ self class color
    ]

    cementOn: field [
	<category: 'blocks'>

        | point x y |
        point := Point new.
        y := 0.
        (self piece at: rotation) do: [ :line |
                    x := 0.
                    line do: [ :elem |
                        elem = 1 ifTrue: [
                            point
                                x: self origin x + x;
                                y: self origin y + y.
                            (field at: point) = 0 ifTrue: [ field at: point put: elem ] ].
			x := x + 1 ].
		    y := y + 1].
    ]

    canMoveInto: field [
	<category: 'moving'>

	| point x y |
	point := Point new.
	y := 0.
	(self piece at: rotation) do: [ :line |
		    x := 0.
		    line do: [ :elem | 
			elem = 1 ifTrue: [ 
			    point
				x: self origin x + x;
				y: self origin y + y.
			    (field at: point) > 0 ifTrue: [ ^ false ] ].
			x := x + 1 ].
		    y := y + 1 ].
	^ true
    ]

    moveInto: field ifFail: aBlock [
	<category: 'moving'>

	(self canMoveInto: field) ifFalse: [ aBlock value.
				    ^ false ].
	^ true
    ]

    rotate: howMany [
	"Three lines are necessary because rotation is in the 1..4 range,
	 while \\ likes a 0..3 range"

	<category: 'moving'>
	rotation := rotation - 1.
	rotation := (rotation + howMany) \\ 4.
	rotation := rotation + 1
    ]

    origin [
	<category: 'accessing'>

	^ origin
    ]

    x [
	<category: 'accessing'>

	^ self origin x
    ]

    x: x [
	<category: 'accessing'>

	self origin x: x
    ]

    y [
	<category: 'accessing'>

	^ self origin y
    ]

    y: y [
	<category: 'accessing'>

	self origin y: y
    ]

    drawOn: aCanvas [
	<category: 'drawing'>

	| y |
	y := 0.
        (self piece at: rotation) do: [ :line |
	    y := y + 1.
            1 to: 4 do: [ :x |
                (line at: x) ~= 0 ifTrue: [
                    BlockWidget new
                        position: (50 + ((self x + x - 1) * 15))@(50 + ((self y + y - 1) * 15));
                        size: 15;
			color: self color;
                        drawOn: aCanvas ] ] ]
    ]

]

PK
     �Mh@ �H]�  �    Tetris/Tetris.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

GtkMainWindow subclass: Tetris [
    | canvasWidget canvas process pause delay grid movingBlocks level score level lines |
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    Tetris class [ | highScores | ]

    Tetris class >> highScores [
	<category: 'accessing'>

	^ highScores ifNil: [ highScores := HighScores newSized: 10 ]
    ]

    Tetris class >> open [
	<category: 'user interface'>

	TetrisPiece initialize.

	^ super open
	    play;
	    yourself
    ]

    initialize [
	<category: 'initialization'>

	movingBlocks := false.
	super initialize.
    ]

    windowTitle [
	<category: 'initialization'>

	^'Tetris'
    ]

    postInitialize [
	<category: 'initialization'>

	super postInitialize.
        canvasWidget grabFocus.
	window
	    connectSignal: 'key-press-event' to: self selector: #'keyPressedOn:keyEvent:'
    ]

    onDelete [
	<category: 'windows event'>

	self quit.
	^ true
    ]

    createHelpMenus [
        <category: 'user interface'>

        ^{GTK.GtkMenuItem menuItem: 'About Tetris' connectTo: self selector: #aboutLauncher.
            GTK.GtkMenuItem menuItem: 'About GNU Smalltalk' connectTo: self selector: #aboutGst}
    ]

    createMenus [
        <category: 'user interface'>

        self createMainMenu: #(#('Help' #createHelpMenus))
    ]

    buildCentralWidget [
	<category: 'user interface'>
	
	^ canvasWidget := GTK.GtkDrawingArea new
	    setSizeRequest: 400 height: 700;
	    connectSignal: 'expose_event' to: self selector: #'expose:event:';
	    yourself
    ]

    clearArea: aGtkAllocation [
        <category: 'drawing'>

        | res |
        res := aGtkAllocation castTo: (CIntType arrayType: 4).

        canvas saveWhile: [ 
	    canvas
                rectangle: ((0@0) extent: ((res at: 2) @ (res at: 3)));
                operator: #clear;
                fill ]
    ]

    drawArea [
	<category: 'drawing'>

	1 to: 22 do: [ :i |
	    BlockWidget new
		position: 50@(50 + ((i - 1) * 15));
		size: 15;
		color: Cairo.Color white;
		drawOn: canvas.

            BlockWidget new
                position: (50 + (11 * 15))@(50 + ((i - 1) * 15));
                size: 15;
		color: Cairo.Color white;
                drawOn: canvas ].

	1 to: 12 do: [ :i |
            BlockWidget new
                position: (50 + ((i - 1) * 15))@50;
                size: 15;
		color: Cairo.Color white;
                drawOn: canvas.

            BlockWidget new
                position: (50 + ((i - 1) * 15))@(50 + (22 * 15));
                size: 15;
		color: Cairo.Color white;
                drawOn: canvas ]
    ]

    drawGrid [
	<category: 'drawing'>

	grid ifNil: [ ^ self ].
	grid drawOn: canvas
    ]

    drawScore [
	<category: 'drawing'>

	canvas
	    moveTo: 300@100;
	    sourceRed: 1 green: 1 blue: 1;
	    showText: 'Score : ', (self score displayString);
	    moveTo: 300@150;
	    showText: 'Level : ', (self level displayString);
	    stroke.
    ]

    expose: aGtkWidget event: aGdkEventExpose [
	<category: 'drawing event'>

	aGtkWidget getWindow withContextDo: [ :cr |
            canvas := cr.
            self
                clearArea: aGtkWidget getAllocation;
		drawArea;
		drawGrid;
		drawScore ].

        ^ true
    ]

    keyPressedOn: aGtkWidget keyEvent: aGdkEventKey [
	<category: 'key event'>

	| event |
	movingBlocks ifFalse: [ ^ false ].

	event := aGdkEventKey castTo: GTK.GdkEventKey type.

	event keyval value = 65361 ifTrue: [ self movePieceLeft. ^ true ].
	event keyval value = 65363 ifTrue: [ self movePieceRight. ^ true ].
	event keyval value = 65362 ifTrue: [ self rotatePiece. ^ true ].
	event keyval value = 65364 ifTrue: [ self dropPiece. ^ true ].

	^ false
    ]

    refresh [
	<category: 'drawing'>

	canvasWidget queueDraw
    ]

    cycle [
	<category: 'game'>
	
	| result filledLines |
	grid := TetrisField new.
	[ movingBlocks := true.
	  result := grid currentPiece: TetrisPiece random.
	  result ifTrue: [ self 
			    refresh;
			    delay ].
	  result ] whileTrue: [ 
		[ result := self slidePiece.
		  self refresh.
		  result ] whileTrue: [ self delay ].
		  filledLines := self 
				    resetMovingBlocks;
				    cementPiece;
				    removeLines.
		  self updateScore: filledLines.
		  Processor yield ].

	^ self gameOver 
    ]

    initializeGame [
	<category: 'game'>

	self 
	    level: 1;
	    lines: 0;
	    score: 0.
	movingBlocks := true
    ]

    play [
	<category: 'game'>

	process := [ self
			initializeGame;
			cycle ] fork.
    ]

    quit [
	<category: 'game'>

	process terminate.
	window hideAll
    ]

    gameOver [
	<category: 'game'>

	self highScores addScore: (Score score: self score)
    ]

    resetMovingBlocks [
	<category: 'game'>

	movingBlocks := false
    ]

    delay [
	"I like this method a lot!"

	<category: 'private'>
	delay wait.

	"Especially this semaphore!!
	pause wait.
	pause signal"
    ]

    highScores [
	<category: 'accessing'>

	^ self class highScores
    ]

    level [
	<category: 'accessing'>

	^ level
    ]

    level: nextLevel [
	<category: 'private'>

	level := nextLevel min: 10.
	delay := Delay forMilliseconds: 825 - (75 * level).
    ]

    lines [
	<category: 'private'>

	^ lines
    ]

    lines: newLines [
	<category: 'private'>

	lines := newLines
    ]

    score [
	<category: 'private'>

	^ score
    ]

    score: newScore [
	<category: 'private'>

	score := newScore
    ]

    updateScore: filledLines [
	<category: 'private'>

	self lines: self lines + filledLines.
        (self lines - 1) // 10 > (self level - 1) ifTrue: [ self advanceLevel ].
        self score: 2 * self level squared + (#(0 50 150 400 900) at: filledLines + 1) + self score
    ]

    advanceLevel [
	<category: 'events'>

	self level: self level + 1
    ]

    movePieceLeft [
	<category: 'events'>

	grid movePieceLeft.
	self refresh
    ]

    movePieceRight [
	<category: 'events'>

	grid movePieceRight.
	self refresh
    ]

    pause [
	<category: 'events'>

	"I like this semaphore a lot!"
	pause wait
    ]

    restart [
	<category: 'events'>

	"I like this semaphore a lot!"
	pause signal
    ]

    rotatePiece [
	<category: 'events'>

	grid rotatePiece.
	self refresh
    ]

    slidePiece [
	<category: 'events'>

	^ grid slidePiece
    ]

    cementPiece [
	<category: 'events'>

	^ grid cementPiece
    ]

    removeLines [
	<category: 'game'>

	^ grid removeLines
    ]

    dropPiece [
	<category: 'events'>

	^ grid dropPiece
    ]
]

PK
     �Mh@	�l��  �    Tetris/HighScores.stUT	 fqXO�XOux �  �  Object subclass: HighScores [

    | highScores maxScores |

    HighScores class >> newSized: anInteger [
	<category: 'instance creation'>

	^ self new
	    maxScores: anInteger;
	    yourself
    ]

    highScores [
	<category: 'accessing'>

	^ highScores ifNil: [ highScores := OrderedCollection new ]
    ]

    maxScores: anInteger [
	<category: 'accessing'>

	maxScores := anInteger
    ]

    addScore: aScore [
	<category: 'updating'>

	| pos |
	pos := 0.
	self highScores doWithIndex: [ :each :index |
	    each < index ifTrue: [ pos := index ] ].
	pos = 0 ifTrue: [ ^ self ].
	self highScores add: aScore after: pos.
	self highScores size > self maxScores ifTrue: [ self highScores removeLast ]
    ]
]

PK
     �Mh@=>�.  .    Tetris/Score.stUT	 fqXO�XOux �  �  Object subclass: Score [

    Score class >> score: anInteger [
	<category: 'instance creation'>

	^ self new
	    score: anInteger;
	    yourself
    ]

    | score |

    score: anInteger [
	<category: 'accessing'>

	score := anInteger
    ]

    score [
	<category: 'acccessing'>

	^ score
    ]
]

PK
     �Mh@8���O  O    Tetris/TetrisField.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: TetrisField [
    | rows currentPiece |
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    TetrisField class >> new [
	<category: 'instance creation'>

	^ self basicNew initialize
    ]

    at: point [
	<category: 'accessing'>

	^ (rows at: point y) at: point x
    ]

    at: point put: value [
	<category: 'accessing'>

	^ (rows at: point y) at: point x put: value
    ]

    initialize [
	<category: 'initializing'>
	
	rows := (1 to: 22) collect: [:each | ByteArray new: 10].
	rows do: [:each | self initializeLine: each].
	(rows at: 22) atAll: (1 to: 10) put: 1
    ]

    initializeLine: line [
	<category: 'initializing'>

	line
	    atAll: (1 to: 10) put: 0
    ]

    checkLine: y [
	<category: 'removing filled lines'>

	^ (rows at: y) allSatisfy: [:each | each ~~ 0]
    ]

    removeLines [
	<category: 'removing filled lines'>

	| removed lastLine firstLine |
	removed := 0.
	firstLine := self currentPiece y.
	lastLine := 21 min: firstLine + 3.
	lastLine - firstLine + 1 timesRepeat: 
		[(self checkLine: lastLine) 
		    ifTrue: 
			[removed := removed + 1.
			self removeLine: lastLine]
		    ifFalse: [lastLine := lastLine - 1]].
	^ removed
    ]

    removeLine: filledY [
	<category: 'removing filled lines'>

	| saved y shift line |
	saved := rows at: filledY.
	filledY to: 2
	    by: -1
	    do: [:each | rows at: each put: (rows at: each - 1)].
	self initializeLine: saved.
	rows at: 1 put: saved
    ]

    cementPiece [
	<category: 'piece'>

	self currentPiece cementOn: self
    ]

    dropPiece [
	<category: 'moving pieces'>

	[ self slidePiece ] whileTrue: []
    ]

    movePieceLeft [
	<category: 'moving pieces'>

	self currentPiece x: self currentPiece x - 1.
	^ self currentPiece moveInto: self
	    ifFail: [self currentPiece x: self currentPiece x + 1]
    ]

    movePieceRight [
	<category: 'moving pieces'>

	self currentPiece x: self currentPiece x + 1.
	^ self currentPiece moveInto: self
	    ifFail: [ self currentPiece x: self currentPiece x - 1 ]
    ]

    rotatePiece [
	<category: 'moving pieces'>

	self currentPiece rotate: 1.
	^ self currentPiece moveInto: self ifFail: [ self currentPiece rotate: 3 ]
    ]

    slidePiece [
	<category: 'moving pieces'>

	self currentPiece y: self currentPiece y + 1.
	^ self currentPiece moveInto: self
	    ifFail: [self currentPiece y: self currentPiece y - 1]
    ]

    currentPiece [
	<category: 'accessing piece variables'>

	^ currentPiece
    ]

    currentPiece: piece [
	<category: 'accessing piece variables'>

	currentPiece := piece.
	(self currentPiece)
	    x: 4;
	    y: 1.

	self currentPiece moveInto: self
            ifFail: [ ^ false ].
	^ true
    ]

    drawOn: aCanvas [
	<category: 'drawing'>

	1 to: 21 do: [ :y |
	    1 to: 10 do: [ :x |
		((rows at: y) at: x) ~= 0 ifTrue: [
		    BlockWidget new
			position: (50 + (x * 15))@(50 + (y * 15));
			size: 15;
			color: Cairo.Color white;
			drawOn: aCanvas ] ] ].
	self currentPiece drawOn: aCanvas
    ]
]

PK
     �Mh@b"p7�  �    Tetris/TetrisPieceJ.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

TetrisPiece subclass: TetrisPieceJ [
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    TetrisPieceJ class >> piece [
	<category: 'pieces'>

	^#( #( #(0 1 0 0)
	       #(0 1 0 0)
	       #(1 1 0 0)
	       #(0 0 0 0))
	    #( #(1 0 0 0)
	       #(1 1 1 0)
	       #(0 0 0 0)
	       #(0 0 0 0))
	    #( #(1 1 0 0)
	       #(1 0 0 0)
	       #(1 0 0 0)
	       #(0 0 0 0))
	    #( #(1 1 1 0)
	       #(0 0 1 0)
	       #(0 0 0 0)
	       #(0 0 0 0)))
    ]

    TetrisPieceJ class >> color [
	<category: 'pieces'>

	^ Cairo.Color magenta
    ]
]

PK
     �Mh@����  �    Tetris/TetrisPieceO.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

TetrisPiece subclass: TetrisPieceO [
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    TetrisPieceO class >> piece [
	<category: 'pieces'>

	^#( #( #(1 1 0 0)
	       #(1 1 0 0)
	       #(0 0 0 0)
	       #(0 0 0 0))
	    #( #(1 1 0 0)
	       #(1 1 0 0)
	       #(0 0 0 0)
	       #(0 0 0 0))
	    #( #(1 1 0 0)
	       #(1 1 0 0)
	       #(0 0 0 0)
	       #(0 0 0 0))
	    #( #(1 1 0 0)
	       #(1 1 0 0)
	       #(0 0 0 0)
	       #(0 0 0 0)))
    ]

    TetrisPieceO class >> color [
	<category: 'piece'>

	^ Cairo.Color r: 0.54 g: 0.17 b: 0.88 "BlueViolet"
    ]
]

PK
     �Mh@�J"��  �    Tetris/TetrisPieceI.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

TetrisPiece subclass: TetrisPieceI [

    <category: 'Graphics-Tetris'>
    <comment: nil>

    TetrisPieceI class >> piece [
	<category: 'pieces'>

	^#( #( #(1 0 0 0)
	       #(1 0 0 0)
	       #(1 0 0 0)
	       #(1 0 0 0))
	    #( #(0 0 0 0)
	       #(0 0 0 0)
	       #(0 0 0 0)
	       #(1 1 1 1))
	    #( #(1 0 0 0)
	       #(1 0 0 0)
	       #(1 0 0 0)
	       #(1 0 0 0))
	    #( #(0 0 0 0)
	       #(0 0 0 0)
	       #(0 0 0 0)
	       #(1 1 1 1)))
    ]

    TetrisPieceI class >> color [
	<category: 'pieces'>

	^ Cairo.Color red
    ]
]

PK
     �Mh@LPH$%  %    Tetris/BlockWidget.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"

TetrisPieceWidget subclass: BlockWidget [

    drawOn: aCanvas [
	<category: 'drawing'>

	| linear |
        linear := Cairo.LinearGradient from: position to: (position x + size@ position y + size).
        linear addStopAt: 0 color: color.
        linear addStopAt: 1 color: Cairo.Color black.

        aCanvas
            fill: [ aCanvas rectangle: (position extent: size@size) ]
            with: linear
    ]
]
PK
     �Mh@
��b�  �    Tetris/TetrisPieceS.stUT	 fqXO�XOux �  �  "======================================================================
|
|   GTK Tetris... why not?
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999 Free Software Foundation, Inc.
| Written by Paolo Bonzini, Gwenael Casaccio.
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
| GNU Smalltalk; see the file LICENSE.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"

TetrisPiece subclass: TetrisPieceS [
    
    <category: 'Graphics-Tetris'>
    <comment: nil>

    TetrisPieceS class >> piece [
	<category: 'pieces'>

	^#( #( #(0 1 0 0)
	       #(1 1 0 0)
	       #(1 0 0 0)
	       #(0 0 0 0))
	    #( #(1 1 0 0)
	       #(0 1 1 0)
	       #(0 0 0 0)
	       #(0 0 0 0)) 
	    #( #(0 1 0 0)
	       #(1 1 0 0)
	       #(1 0 0 0)
	       #(0 0 0 0)) 
	    #( #(1 1 0 0)
	       #(0 1 1 0)
	       #(0 0 0 0)
	       #(0 0 0 0)))
    ]

    TetrisPieceS class >> color [
	<category: 'pieces'>

	^ Cairo.Color cyan
    ]
]

PK
     �Mh@D(#T�   �     AbstractFinder.stUT	 eqXO�XOux �  �  Object subclass: AbstractFinder [
    updateBrowser: aGtkClassBrowserWidget [
	<category: 'events'>

	self subclassResponsibility
    ]

    element [
	<category: 'events'>

	self subclassResponsibility
    ]
]

PK
     �Mh@<mO   O     GtkAbstractConcreteWidget.stUT	 eqXO�XOux �  �  Smalltalk.Object subclass: GtkAbstractConcreteWidget [

    hideAll [
    ]
]

PK
     �Mh@��c�  �    GtkPackageBuilderWidget.stUT	 eqXO�XOux �  �  GtkConcreteWidget subclass: GtkPackageBuilderWidget [

    | classList ressourceList packName namespace provide provideList test classCategory prereq prereqList entries |

    initialize [
        <category: 'initialization'>

	entries := Dictionary new.
        self mainWidget: (GTK.GtkScrolledWindow withViewport: self buildMainWidget)
    ]

    buildMainWidget [
        <category: 'user interface'>

        ^ (GTK.GtkVBox new: false spacing: 3)
            add: self buildPackageNameEntry mainWidget;
	    add: self buildNamespaceEntry mainWidget;
            add: self buildPackageEntry mainWidget;
	    add: self buildPrereq;
	    add: self buildProvideEntry;
	    add: self buildTestsEntry mainWidget;
	    add: self buildClassCategoryEntry mainWidget;
	    add: self buildClassCategory;
	    add: self buildRessourcesEntry;
	    add: self buildButtons;
            yourself
    ]

    buildPackageNameEntry [
        <category: 'user interface'>

        | completion model |
        completion := GTK.GtkEntryCompletion new.
        completion 
            setModel: (model := GTK.GtkListStore createModelWith: {{GtkColumnTextType title: ''}});
            setTextColumn: 0.
	Smalltalk.PackageLoader root do: [ :each | model appendItem: {each name} ].
	^ packName := (GtkEntryWidget labeled: 'Package name :')
						completion: completion;
                                                yourself
    ]

    buildNamespaceCompletion: model [

	self buildNamespaceCompletion: Smalltalk on: model
    ]

    buildNamespaceCompletion: aNamespace on: model [

	model appendItem: {aNamespace name asString}.
	aNamespace subspaces do: [ :each |
	    self buildNamespaceCompletion: each on: model ]
    ]

    buildNamespaceEntry [
        <category: 'user interface'>

	| completion model |
	completion := GTK.GtkEntryCompletion new.
	completion 
	    setModel: (model := GTK.GtkListStore createModelWith: {{GtkColumnTextType title: ''}});
	    setTextColumn: 0.
	self buildNamespaceCompletion: model.
	^ namespace := (GtkEntryWidget labeled: 'Namespace :')
						completion: completion;
						yourself
    ]

    buildPackageEntry [
        <category: 'user interface'>

        | completion model |
        completion := GTK.GtkEntryCompletion new.
        completion
            setModel: (model := GTK.GtkListStore createModelWith: {{GtkColumnTextType title: ''}});
            setTextColumn: 0.
	Smalltalk.PackageLoader root do: [ :each | model appendItem: {each name} ].
        ^ prereq := (GtkEntryWidget labeled: 'Package :')
                                                completion: completion;
                                                yourself
    ]

    buildPrereqEntry [
        <category: 'user interface'>

	prereqList := GtkSimpleListWidget named: 'Packages prerequired :'.
	^ prereqList mainWidget
    ]

    buildPrereq [

        | hbox vbox add remove |
        hbox := GTK.GtkHBox new: false spacing: 0.

        hbox packStart: self buildPrereqEntry expand: true fill: true padding: 3.
        add := GTK.GtkButton createButton: GTK.Gtk gtkStockAdd.
        add
            setTooltipText: 'Add a file into the package';
            connectSignal: 'clicked' to: self selector: #addPrereq.

        vbox := GTK.GtkVBox new: false spacing: 0.
        vbox packStart: add expand: false fill: true padding: 3.

        remove := GTK.GtkButton createButton: GTK.Gtk gtkStockRemove.
        remove
            setTooltipText: 'Remove the selected file from the list'.
        vbox packStart: remove expand: false fill: true padding: 3.
        hbox packStart: vbox expand: false fill: true padding: 3.
        ^ hbox
    ]

    buildProvideEntry [
        <category: 'user interface'>

	provideList := GtkSimpleListWidget named: 'Provides :'.
	^ provideList mainWidget
    ]

    buildTestsEntry [
        <category: 'user interface'>

	^ test := GtkEntryWidget labeled: 'Tests :'
    ]

    buildClassCategoryCompletion: model [

	| set |
	set := Set new.
	Class allSubclassesDo: [ :each |
	    (set includes: each category)
		ifFalse: [
		    set add: each category.
		    model appendItem: {each category} ] ]
    ]

    buildClassCategoryEntry [
        <category: 'user interface'>

        | completion model |
        completion := GTK.GtkEntryCompletion new.
        completion
            setModel: (model := GTK.GtkListStore createModelWith: {{GtkColumnTextType title: ''}});
            setTextColumn: 0.
        self buildClassCategoryCompletion: model.
        ^ packName := (GtkEntryWidget labeled: 'Class category :')
                                                completion: completion;
                                                yourself
    ]

    buildClassCategory [

	| hbox vbox add remove |
	hbox := GTK.GtkHBox new: false spacing: 0.
	
	hbox packStart: self buildFilesEntry expand: true fill: true padding: 3.
        add := GTK.GtkButton createButton: GTK.Gtk gtkStockAdd.
        add
	    setTooltipText: 'Add a file into the package';
            connectSignal: 'clicked' to: self selector: #addCategory.

	vbox := GTK.GtkVBox new: false spacing: 0.
        vbox packStart: add expand: false fill: true padding: 3.

        remove := GTK.GtkButton createButton: GTK.Gtk gtkStockRemove.
	remove 
	    setTooltipText: 'Remove the selected file from the list'.
        vbox packStart: remove expand: false fill: true padding: 3.
        hbox packStart: vbox expand: false fill: true padding: 3.
	^ hbox
    ]

    buildFilesEntry [
        <category: 'user interface'>

        classList := GtkSimpleListWidget named: 'Class category :'.
        ^ classList mainWidget
    ]

    buildRessourcesEntry [
        <category: 'user interface'>

        ressourceList := GtkSimpleListWidget named: 'Ressources :'.
        ^ ressourceList mainWidget
    ]

    buildButtons [
        <category: 'user interface'>

        | hbox add cancel |
        hbox := GTK.GtkHBox new: false spacing: 0.

        add := GTK.GtkButton createButton: GTK.Gtk gtkStockAdd.
        add
            setTooltipText: 'Save the package';
            connectSignal: 'clicked' to: self selector: #buildPackage.

        hbox packStart: add expand: false fill: true padding: 3.

        cancel := GTK.GtkButton createButton: GTK.Gtk gtkStockRemove.
        cancel
            setTooltipText: 'Cancel'.
        hbox packStart: cancel expand: false fill: true padding: 3.
        ^ hbox
    ]

    addPrereq [

	prereqList getModel appendItem: {prereq text}
    ]

    addCategory [
    ]

    buildPackage [
    ]
]

PK
     �Mh@�rR�a   a             ��    GtkHSidebarWidget.stUT eqXOux �  �  PK
     &\h@                     �A�   Implementors/UT �XOux �  �  PK
     �Mh@�3:�  �  &          ���   Implementors/GtkSenderResultsWidget.stUT eqXOux �  �  PK
     �Mh@�B$�    +          ���	  Implementors/GtkImplementorResultsWidget.stUT eqXOux �  �  PK
     �Mh@|uʼ  �  %          ��>  Implementors/GtkImageResultsWidget.stUT eqXOux �  �  PK
     �Mh@��Z              ��Y  GtkNamespaceSelectionChanged.stUT eqXOux �  �  PK
     �Mh@Q�:	  	            ���  GtkConcreteWidget.stUT eqXOux �  �  PK
     �Mh@\����	  �	            ��  GtkTreeModel.stUT eqXOux �  �  PK
     �Mh@�u���  �            ��U&  GtkWorkspaceWidget.stUT eqXOux �  �  PK
     �Mh@���  �            ���-  GtkBrowsingTool.stUT eqXOux �  �  PK
     %\h@                     �A�4  Text/UT �XOux �  �  PK
     �Mh@Iw_�D&  D&            ��5  Text/GtkTextWidget.stUT fqXOux �  �  PK
     �Mh@}M�*  *            ���[  Text/GtkTextPluginWidget.stUT fqXOux �  �  PK
     �Mh@��\u  u            ��`  Text/GtkSourceCodeWidget.stUT fqXOux �  �  PK
     �Mh@��?
  ?
            ���w  Text/GtkFindWidget.stUT fqXOux �  �  PK
     �Mh@K]E	  	            ��q�  Text/GtkSaveTextWidget.stUT fqXOux �  �  PK
     �Mh@��L�K  K            ��͆  Text/GtkReplaceWidget.stUT fqXOux �  �  PK
     �Mh@���  �            ��j�  GtkAssistant.stUT eqXOux �  �  PK
     &\h@                     �A��  Clock/UT �XOux �  �  PK
     �Mh@�e�U�  �            ���  Clock/GtkClock.stUT eqXOux �  �  PK
     �Mh@I��l  l            ��   GtkSidebarWidget.stUT eqXOux �  �  PK
     %\h@                     �A{�  State/UT �XOux �  �  PK
     �Mh@� �s�  �            ����  State/BrowserState.stUT fqXOux �  �  PK
     �Mh@Sr���  �            ����  State/NamespaceState.stUT fqXOux �  �  PK
     �Mh@��<�J  J            ����  State/MethodState.stUT fqXOux �  �  PK
     �Mh@	I\�j  j            ��:�  State/CategoryState.stUT fqXOux �  �  PK
     �Mh@p�®  �            ����  State/ClassState.stUT fqXOux �  �  PK
     �Mh@�N�,�  �            ���  GtkSimpleListWidget.stUT eqXOux �  �  PK
     &\h@                     �A&�  SUnit/UT �XOux �  �  PK
     �Mh@��lc�  �            ��f�  SUnit/GtkSUnitResultWidget.stUT fqXOux �  �  PK
     �Mh@��!6  6            ��S�  SUnit/TestBacktraceLog.stUT fqXOux �  �  PK
     �Mh@���5�,  �,            ����  SUnit/GtkSUnit.stUT fqXOux �  �  PK
     �Mh@	+ѳ              ���  GtkAnnouncer.stUT eqXOux �  �  PK
     �Mh@����9  9            ��y�  GtkClassSUnitWidget.stUT eqXOux �  �  PK
     �Mh@�%�.  .            �� ClassFinder.stUT eqXOux �  �  PK
     �Mh@nҧ~�  �            ��x HistoryStack.stUT eqXOux �  �  PK
     �Mh@X���`  �`            ��g GtkLauncher.stUT eqXOux �  �  PK
     #\h@W$��7  �7            ��Xp package.xmlUT �XOux �  �  PK
     �Mh@+}'��  �            ��>� GtkWebBrowser.stUT eqXOux �  �  PK
     '\h@                     �A*� Icons/UT �XOux �  �  PK
     �Mh@�i؟�  �            ��j� Icons/go-last.pngUT eqXOux �  �  PK
     �Mh@���wj  j            ��a� Icons/go-down.pngUT eqXOux �  �  PK
     �Mh@�R�m  m            ��� Icons/go-up.pngUT eqXOux �  �  PK
     �Mh@��՘  �            ��̷ Icons/go-run.pngUT eqXOux �  �  PK
     �Mh@����  �             ���� Icons/NUnit.SuccessAndFailed.pngUT eqXOux �  �  PK
     �Mh@i���  �            ���� Icons/go-next.pngUT eqXOux �  �  PK
     �Mh@@���  �            ���� Icons/go-home.pngUT eqXOux �  �  PK
     �Mh@�O  O            ��o� Icons/extension.pngUT eqXOux �  �  PK    �Mh@�w	?S  n            ��� Icons/visualgst.pngUT eqXOux �  �  PK
     �Mh@R��B  B            ���� Icons/NUnit.None.pngUT eqXOux �  �  PK
     �Mh@�k�Ƌ  �            ��;� Icons/go-bottom.pngUT eqXOux �  �  PK
     �Mh@�e���  �            ��� Icons/go-top.pngUT eqXOux �  �  PK
     �Mh@�[���  �            ���� Icons/go-previous.pngUT eqXOux �  �  PK
     �Mh@!<�PU  U            ���� Icons/NUnit.NotRun.pngUT eqXOux �  �  PK    �Mh@fe���   �             ���� Icons/namespace.gifUT eqXOux �  �  PK
     �Mh@T{��              ���� Icons/go-jump.pngUT eqXOux �  �  PK    �Mh@��,A  B            ��.� Icons/NUnit.Loading.pngUT eqXOux �  �  PK
     �Mh@��{  {            ���� Icons/overridden.pngUT eqXOux �  �  PK
     �Mh@��U�t  t            ���� Icons/override.pngUT eqXOux �  �  PK    �Mh@פ��6  7            ��I� Icons/NUnit.Success.pngUT eqXOux �  �  PK    �Mh@u�b{�  J            ���� Icons/category.gifUT eqXOux �  �  PK
     �Mh@�Q�              ��  Icons/NUnit.Failed.pngUT eqXOux �  �  PK
     �Mh@,���  �            ��s Icons/NUnit.Running.pngUT eqXOux �  �  PK
     �Mh@����  �            ��b Icons/go-first.pngUT eqXOux �  �  PK
     &\h@                     �Ap Undo/UT �XOux �  �  PK
     �Mh@l�¥W  W            ��� Undo/AddClassUndoCommand.stUT fqXOux �  �  PK
     &\h@            
         �A[ Undo/Text/UT �XOux �  �  PK
     �Mh@�8o��  �            ��� Undo/Text/InsertTextCommand.stUT fqXOux �  �  PK
     �Mh@
v�K1  1            ��� Undo/Text/DeleteTextCommand.stUT fqXOux �  �  PK
     �Mh@"I���  �            ��S Undo/Text/ReplaceTextCommand.stUT fqXOux �  �  PK
     �Mh@Փ��              ��P Undo/DeleteMethodUndoCommand.stUT fqXOux �  �  PK
     �Mh@���2B  B            ���  Undo/DeleteClassUndoCommand.stUT fqXOux �  �  PK
     �Mh@3[��  �            ��Q$ Undo/AddNamespaceUndoCommand.stUT fqXOux �  �  PK
     �Mh@B��!(  (            ���) Undo/UndoStack.stUT fqXOux �  �  PK
     �Mh@u�R+-  -            ���- Undo/RenameClassUndoCommand.stUT fqXOux �  �  PK
     �Mh@&ҿ�E  E  "          ��}3 Undo/DeleteNamespaceUndoCommand.stUT fqXOux �  �  PK
     �Mh@H���|  |  !          ��6 Undo/RenameCategoryUndoCommand.stUT fqXOux �  �  PK
     �Mh@�ƁV8  8            ���; Undo/AddMethodUndoCommand.stUT fqXOux �  �  PK
     �Mh@��$��  �  "          ���H Undo/RenameNamespaceUndoCommand.stUT fqXOux �  �  PK
     �Mh@�<Cfx  x            ���M Undo/UndoCommand.stUT fqXOux �  �  PK
     �Mh@��H��  �            ��dQ GtkEntryWidget.stUT eqXOux �  �  PK
     %\h@                     �AUT Source/UT �XOux �  �  PK
     �Mh@�~w�  �            ���T Source/ClassSource.stUT fqXOux �  �  PK
     �Mh@�u��|  |            ���\ Source/MethodSource.stUT fqXOux �  �  PK
     �Mh@�'��  �            ���d Source/NamespaceHeaderSource.stUT fqXOux �  �  PK
     �Mh@��ˀ  �            ���i Source/CategorySource.stUT fqXOux �  �  PK
     �Mh@��fH  H            ���m Source/PackageSource.stUT fqXOux �  �  PK
     �Mh@d�=P  P            ��;� Source/BrowserMethodSource.stUT fqXOux �  �  PK
     �Mh@Q4C��  �            ��� Source/NamespaceSource.stUT fqXOux �  �  PK
     �Mh@�)>              ��� Source/SourceFormatter.stUT fqXOux �  �  PK
     �Mh@��'��  �            ��o� Source/ClassHeaderSource.stUT fqXOux �  �  PK
     &\h@            	         �A�� Commands/UT �XOux �  �  PK
     �Mh@�&ߍ   �             ��� Commands/SaveImageAsCommand.stUT eqXOux �  �  PK
     &\h@                     �AƗ Commands/InspectorMenus/UT �XOux �  �  PK
     �Mh@pn���   �   /          ��� Commands/InspectorMenus/InspectorBackCommand.stUT eqXOux �  �  PK
     �Mh@��x��   �   /          ��Z� Commands/InspectorMenus/InspectorDiveCommand.stUT eqXOux �  �  PK
     %\h@                     �A�� Commands/DebugMenus/UT �XOux �  �  PK
     �Mh@28y�   �   +          ��� Commands/DebugMenus/ContinueDebugCommand.stUT eqXOux �  �  PK
     �Mh@���M�  �  #          ��<� Commands/DebugMenus/DebugCommand.stUT eqXOux �  �  PK
     �Mh@^����   �   )          ��c� Commands/DebugMenus/StepToDebugCommand.stUT eqXOux �  �  PK
     �Mh@z>A'�   �   +          ���� Commands/DebugMenus/StepIntoDebugCommand.stUT eqXOux �  �  PK
     $\h@                     �A"� Commands/SmalltalkMenus/UT �XOux �  �  PK
     �Mh@��J  J  )          ��t� Commands/SmalltalkMenus/DebugItCommand.stUT eqXOux �  �  PK
     �Mh@�|	�   �   (          ��!� Commands/SmalltalkMenus/CancelCommand.stUT eqXOux �  �  PK
     �Mh@��P�  �  *          ��*� Commands/SmalltalkMenus/AcceptItCommand.stUT eqXOux �  �  PK
     �Mh@��L  L  +          ��z� Commands/SmalltalkMenus/InspectItCommand.stUT eqXOux �  �  PK
     �Mh@̾D  D  )          ��+� Commands/SmalltalkMenus/PrintItCommand.stUT eqXOux �  �  PK
     �Mh@�봅$  $  &          ��ҫ Commands/SmalltalkMenus/DoItCommand.stUT eqXOux �  �  PK
     $\h@                     �AV� Commands/CategoryMenus/UT �XOux �  �  PK
     �Mh@Y�t!u   u   )          ���� Commands/CategoryMenus/CategoryCommand.stUT eqXOux �  �  PK
     �Mh@Tc��  �  /          ��� Commands/CategoryMenus/RenameCategoryCommand.stUT eqXOux �  �  PK
     �Mh@kf뢙  �  0          ���� Commands/CategoryMenus/FileoutCategoryCommand.stUT eqXOux �  �  PK
     �Mh@��P�    ,          ���� Commands/CategoryMenus/AddCategoryCommand.stUT eqXOux �  �  PK
     �Mh@����|   |              ��	� Commands/OpenWorkspaceCommand.stUT eqXOux �  �  PK
     $\h@                     �A߷ Commands/MethodMenus/UT �XOux �  �  PK
     �Mh@z3)�   �   ,          ��.� Commands/MethodMenus/InspectMethodCommand.stUT eqXOux �  �  PK
     �Mh@}�]ٗ   �   (          ��M� Commands/MethodMenus/DebugTestCommand.stUT eqXOux �  �  PK
     �Mh@�˝�  �  ,          ��F� Commands/MethodMenus/FileoutMethodCommand.stUT eqXOux �  �  PK
     �Mh@r��q   q   %          ��H� Commands/MethodMenus/MethodCommand.stUT eqXOux �  �  PK
     �Mh@���   �   +          ��� Commands/MethodMenus/DeleteMethodCommand.stUT eqXOux �  �  PK
     &\h@                     �Ae� Commands/WorkspaceMenus/UT �XOux �  �  PK
     �Mh@�0\��   �   ,          ���� Commands/WorkspaceMenus/DeleteItemCommand.stUT eqXOux �  �  PK
     �Mh@�%m)�   �   3          ��� Commands/WorkspaceMenus/WorkspaceVariableCommand.stUT eqXOux �  �  PK
     �Mh@Q���   �   -          ��G� Commands/WorkspaceMenus/InspectItemCommand.stUT eqXOux �  �  PK
     &\h@                     �AW� Commands/ToolsMenus/UT �XOux �  �  PK
     �Mh@��>C1  1  0          ���� Commands/ToolsMenus/OpenPackageBuilderCommand.stUT eqXOux �  �  PK
     �Mh@�K�5�   �   +          ��@� Commands/ToolsMenus/OpenAssistantCommand.stUT eqXOux �  �  PK
     �Mh@��   �   ,          ��a� Commands/ToolsMenus/OpenWebBrowserCommand.stUT eqXOux �  �  PK
     �Mh@����  �  -          ���� Commands/ToolsMenus/OpenImplementorCommand.stUT eqXOux �  �  PK
     �Mh@e����  �  '          ��x� Commands/ToolsMenus/OpenSUnitCommand.stUT eqXOux �  �  PK
     �Mh@�n8�  �  (          ���� Commands/ToolsMenus/OpenSenderCommand.stUT eqXOux �  �  PK
     �Mh@\��O      ,          ���� Commands/ToolsMenus/OpenBottomPaneCommand.stUT eqXOux �  �  PK
     $\h@                     �A� Commands/TabsMenus/UT �XOux �  �  PK
     �Mh@�r� �   �   (          ��k� Commands/TabsMenus/PreviousTabCommand.stUT eqXOux �  �  PK
     �Mh@g�n]�   �   $          ���� Commands/TabsMenus/NextTabCommand.stUT eqXOux �  �  PK
     �Mh@�=���   �   %          ���� Commands/TabsMenus/CloseTabCommand.stUT eqXOux �  �  PK
     �Mh@�E��  �  $          ���� Commands/OpenTabbedBrowserCommand.stUT eqXOux �  �  PK
     $\h@                     �A�� Commands/HistoryCommands/UT �XOux �  �  PK
     �Mh@]#z�   �   .          ���� Commands/HistoryCommands/HistoryBackCommand.stUT eqXOux �  �  PK
     �Mh@��w    1          ��J� Commands/HistoryCommands/HistoryDisplayCommand.stUT eqXOux �  �  PK
     �Mh@�j��   �   1          ���� Commands/HistoryCommands/HistoryForwardCommand.stUT eqXOux �  �  PK
     �Mh@���ov  v            ��-� Commands/OpenBrowserCommand.stUT eqXOux �  �  PK
     �Mh@QcSI*  *            ���� Commands/Command.stUT eqXOux �  �  PK
     �Mh@���P�   �             ��r� Commands/SaveImageCommand.stUT eqXOux �  �  PK
     $\h@                     �AQ� Commands/ClassMenus/UT �XOux �  �  PK
     �Mh@��l�^  ^  )          ���� Commands/ClassMenus/RenameClassCommand.stUT eqXOux �  �  PK
     �Mh@1V��d  d  &          ��`� Commands/ClassMenus/AddClassCommand.stUT eqXOux �  �  PK
     �Mh@`��   �   *          ��$� Commands/ClassMenus/InspectClassCommand.stUT eqXOux �  �  PK
     �Mh@�;�[p   p   #          ��B� Commands/ClassMenus/ClassCommand.stUT eqXOux �  �  PK
     �Mh@�����   �   )          ��� Commands/ClassMenus/DeleteClassCommand.stUT eqXOux �  �  PK
     �Mh@�;��]  ]  *          ��;� Commands/ClassMenus/FileoutClassCommand.stUT eqXOux �  �  PK
     $\h@                     �A�� Commands/NamespaceMenus/UT �XOux �  �  PK
     �Mh@�΀�_  _  1          ��N� Commands/NamespaceMenus/DeleteNamespaceCommand.stUT eqXOux �  �  PK
     �Mh@�2sj  j  .          ��� Commands/NamespaceMenus/AddNamespaceCommand.stUT eqXOux �  �  PK
     �Mh@�년w   w   +          ���� Commands/NamespaceMenus/NamespaceCommand.stUT eqXOux �  �  PK
     �Mh@R��y  y  1          ���� Commands/NamespaceMenus/RenameNamespaceCommand.stUT eqXOux �  �  PK
     �Mh@�~$&  &  2          ���� Commands/NamespaceMenus/FileoutNamespaceCommand.stUT eqXOux �  �  PK
     �Mh@r�n�   �   2          ��< Commands/NamespaceMenus/InspectNamespaceCommand.stUT eqXOux �  �  PK
     $\h@                     �Am Commands/EditMenus/UT �XOux �  �  PK
     �Mh@��z    &          ��� Commands/EditMenus/PasteEditCommand.stUT eqXOux �  �  PK
     �Mh@�b7�   �   *          ��/ Commands/EditMenus/SelectAllEditCommand.stUT eqXOux �  �  PK
     �Mh@��82�   �   %          ��G Commands/EditMenus/FindEditCommand.stUT eqXOux �  �  PK
     �Mh@~����   �   '          ��� Commands/EditMenus/CancelEditCommand.stUT eqXOux �  �  PK
     �Mh@��    %          ��� Commands/EditMenus/RedoEditCommand.stUT eqXOux �  �  PK
     �Mh@��Qk    $          ��` Commands/EditMenus/CutEditCommand.stUT eqXOux �  �  PK
     �Mh@�n��   �   (          ��� Commands/EditMenus/ReplaceEditCommand.stUT eqXOux �  �  PK
     �Mh@K�Z�    %          ��! Commands/EditMenus/UndoEditCommand.stUT eqXOux �  �  PK
     �Mh@���m    %          ��� Commands/EditMenus/CopyEditCommand.stUT eqXOux �  �  PK
     '\h@                     �A Tests/UT �XOux �  �  PK
     �Mh@�-M  M            ��A Tests/CategoryTest.stUT fqXOux �  �  PK
     �Mh@c2ʞ�  �            ���' Tests/ExtractLiteralsTest.stUT fqXOux �  �  PK
     �Mh@i"_8	  8	            ���* Tests/StateTest.stUT fqXOux �  �  PK
     �Mh@��9![  [  $          ��U4 Tests/AddNamespaceUndoCommandTest.stUT fqXOux �  �  PK
     �Mh@d�ؾ  �  *          ��8 Tests/GtkCategorizedNamespaceWidgetTest.stUT fqXOux �  �  PK
     �Mh@y��}P  P             ��0? Tests/AddClassUndoCommandTest.stUT fqXOux �  �  PK
     �Mh@
���  �            ���B Tests/GtkConcreteWidgetTest.stUT fqXOux �  �  PK
     �Mh@Y�#;�  �            ���E Tests/PragmaTest.stUT fqXOux �  �  PK
     �Mh@1�z  z            ���I Tests/GtkCategoryWidgetTest.stUT fqXOux �  �  PK
     �Mh@�~�#  #            ���P Tests/MenuBuilderTest.stUT fqXOux �  �  PK
     �Mh@�V�  �             ��T Tests/GtkScrollTreeWidgetTest.stUT fqXOux �  �  PK
     �Mh@�D���  �  &          ���U Tests/GtkCategorizedClassWidgetTest.stUT fqXOux �  �  PK
     �Mh@3���              ��%b Tests/FinderTest.stUT fqXOux �  �  PK
     �Mh@^����   �              ��j Tests/GtkSimpleListWidgetTest.stUT fqXOux �  �  PK
     �Mh@��,  ,            ���k Tests/GtkAssistantTest.stUT fqXOux �  �  PK
     �Mh@��3�   �             ��#m Tests/EmptyTest.stUT fqXOux �  �  PK
     �Mh@2)�8  8            ��n Tests/CompiledMethodTest.stUT fqXOux �  �  PK
     �Mh@!3<�'  '            ���p Tests/GtkMethodWidgetTest.stUT fqXOux �  �  PK
     %\h@                     �A%x Model/UT �XOux �  �  PK
     �Mh@Z��  �            ��ex Model/GtkColumnOOPType.stUT eqXOux �  �  PK
     �Mh@���M  M            ��Wz Model/GtkColumnType.stUT eqXOux �  �  PK
     �Mh@�l�v  v            ��� Model/GtkColumnPixbufType.stUT eqXOux �  �  PK
     �Mh@�by�k  k            ���� Model/GtkColumnTextType.stUT eqXOux �  �  PK
     %\h@                     �A� Image/UT �XOux �  �  PK
     �Mh@���  �            ���� Image/GtkImageWidget.stUT eqXOux �  �  PK
     �Mh@L�f�              ��� Image/GtkImageModel.stUT eqXOux �  �  PK
     �Mh@z�"p�  �            ��>� GtkEntryDialog.stUT eqXOux �  �  PK
     �Mh@��ƣ�  �            ��X� SyntaxHighlighter.stUT fqXOux �  �  PK
     �Mh@Kh��  �            ��/� GtkVariableTrackerWidget.stUT eqXOux �  �  PK
     %\h@            	         �AC� Category/UT �XOux �  �  PK
     �Mh@a�x[�  �            ���� Category/AbstractNamespace.stUT eqXOux �  �  PK
     �Mh@Ic���  �            ���� Category/ClassCategory.stUT eqXOux �  �  PK
     �Mh@�|o�|   |             ���� Category/Class.stUT eqXOux �  �  PK
     �Mh@��<��   �             ���� GtkClassSelectionChanged.stUT eqXOux �  �  PK
     �Mh@��u�x  x            ���� GtkMethodSUnitWidget.stUT eqXOux �  �  PK
     �Mh@-u<M  M            ���� MethodFinder.stUT eqXOux �  �  PK
     �Mh@��a�  �            ��2� GtkNotebookWidget.stUT eqXOux �  �  PK
     �Mh@b���  �            ��|� GtkMainWindow.stUT eqXOux �  �  PK
     &\h@            	         �A^
 Debugger/UT �XOux �  �  PK
     �Mh@�_��              ���
 Debugger/GtkStackInspector.stUT eqXOux �  �  PK
     �Mh@�;��>%  >%            �� Debugger/GtkDebugger.stUT eqXOux �  �  PK
     �Mh@F>�	  �	            ���1 Debugger/GtkContextWidget.stUT eqXOux �  �  PK
     �Mh@�
V��  �  !          ���; Debugger/GtkStackInspectorView.stUT eqXOux �  �  PK
     �Mh@n��f�  �            ���? GtkScrollTreeWidget.stUT eqXOux �  �  PK
     �Mh@@�^hjG  jG            ���C Extensions.stUT eqXOux �  �  PK
     �Mh@���6              ��5� GtkListModel.stUT eqXOux �  �  PK
     �Mh@�s��              ���� WorkspaceVariableTracker.stUT fqXOux �  �  PK
     %\h@                     �A� Menus/UT �XOux �  �  PK
     �Mh@��&�  �            ��2� Menus/LauncherToolbar.stUT eqXOux �  �  PK
     �Mh@���י   �             �� � Menus/ContextMenus.stUT eqXOux �  �  PK
     �Mh@]Ƭ              ��� Menus/NamespaceMenus.stUT eqXOux �  �  PK
     �Mh@;* �   �             ��k� Menus/ToolbarSeparator.stUT eqXOux �  �  PK
     �Mh@��%��   �             ��V� Menus/WorkspaceMenus.stUT eqXOux �  �  PK
     �Mh@��,(�  �            ��B� Menus/TextMenus.stUT eqXOux �  �  PK
     �Mh@�P,�   �             ��h� Menus/DebuggerToolbar.stUT eqXOux �  �  PK
     �Mh@�V�              ��k� Menus/MethodMenus.stUT eqXOux �  �  PK
     �Mh@����  �            ��ȡ Menus/MenuBuilder.stUT eqXOux �  �  PK
     �Mh@�PRfF  F            ��� Menus/EditMenus.stUT eqXOux �  �  PK
     �Mh@\L��|   |             ��z� Menus/MenuSeparator.stUT eqXOux �  �  PK
     �Mh@�VR�   �             ��F� Menus/CategoryMenus.stUT eqXOux �  �  PK
     �Mh@'4��   �             ��Q� Menus/ClassMenus.stUT eqXOux �  �  PK
     �Mh@݊uʘ   �             ���� Menus/WorkspaceVariableMenus.stUT eqXOux �  �  PK
     �Mh@>��   �             ���� Menus/HistoryMenus.stUT eqXOux �  �  PK
     �Mh@Ʃ��4  4            ���� Menus/SimpleWorkspaceMenus.stUT eqXOux �  �  PK
     �Mh@�1/l�   �             ��� Menus/InspectorMenus.stUT eqXOux �  �  PK
     �Mh@y���   �             ��&� Menus/TabsMenus.stUT eqXOux �  �  PK
     �Mh@��n?�   �             ���� Menus/SmalltalkMenus.stUT eqXOux �  �  PK
     �Mh@qn�_�  �            ��� Menus/ToolsMenus.stUT eqXOux �  �  PK
     &\h@            
         �A%� Inspector/UT �XOux �  �  PK
     �Mh@u��V�  �  *          ��i� Inspector/GtkCompiledBlockInspectorView.stUT eqXOux �  �  PK
     �Mh@Q���  �  +          ���� Inspector/GtkCompiledMethodInspectorView.stUT eqXOux �  �  PK
     �Mh@oJ!�d  d             ���� Inspector/GtkSetInspectorView.stUT eqXOux �  �  PK
     �Mh@~1��  �  '          ��n� Inspector/GtkDictionaryInspectorView.stUT eqXOux �  �  PK
     �Mh@���i  i  %          ��R� Inspector/GtkInspectorSourceWidget.stUT eqXOux �  �  PK
     �Mh@\D[  [  #          ��� Inspector/GtkObjectInspectorView.stUT eqXOux �  �  PK
     �Mh@PJ0  0  &          ���� Inspector/GtkCharacterInspectorView.stUT eqXOux �  �  PK
     �Mh@�`�c�!  �!  &          ��b� Inspector/GtkInspectorBrowserWidget.stUT eqXOux �  �  PK
     �Mh@�� �h  h  3          ��D� Inspector/GtkSequenceableCollectionInspectorView.stUT eqXOux �  �  PK
     �Mh@�?���  �            ��� Inspector/GtkInspector.stUT eqXOux �  �  PK
     �Mh@�`�g  g  "          ��5 Inspector/GtkFloatInspectorView.stUT eqXOux �  �  PK
     �Mh@=l���  �            ��� Inspector/GtkInspectorWidget.stUT eqXOux �  �  PK
     �Mh@��uj  j  $          ��� Inspector/GtkIntegerInspectorView.stUT eqXOux �  �  PK
     �Mh@e#̰  �            ���  GtkWebView.stUT eqXOux �  �  PK
     �Mh@�y��              ���$ GtkVisualGSTTool.stUT eqXOux �  �  PK
     �Mh@#Zu��   �             ���9 FakeNamespace.stUT eqXOux �  �  PK
     �Mh@���a   a             ��; GtkVSidebarWidget.stUT eqXOux �  �  PK
     $\h@                     �A�; Notification/UT �XOux �  �  PK
     �Mh@ ^��  �            ��< Notification/EventDispatcher.stUT eqXOux �  �  PK
     �Mh@qU��7  �7            ��J@ Notification/AbstractEvent.stUT eqXOux �  �  PK
     �Mh@{�ub�  �            ��Hx Notification/AddedEvent.stUT eqXOux �  �  PK
     �Mh@��T�  �  "          ���z Notification/SystemEventManager.stUT fqXOux �  �  PK
     �Mh@:x�H  H             ���| Notification/EventMultiplexer.stUT eqXOux �  �  PK
     �Mh@w��              ��j Notification/DoItEvent.stUT eqXOux �  �  PK
     �Mh@7l��,  �,  $          ���� Notification/SystemChangeNotifier.stUT fqXOux �  �  PK
     �Mh@�m��  �            ��ٯ Notification/CommentedEvent.stUT eqXOux �  �  PK
     �Mh@����  �            ���� Notification/RemovedEvent.stUT fqXOux �  �  PK
     �Mh@���  �            ���� Notification/RenamedEvent.stUT fqXOux �  �  PK
     �Mh@W�jE�  �  "          ��� Notification/RecategorizedEvent.stUT fqXOux �  �  PK
     �Mh@�mk,%  %  ,          ��q� Notification/ModifiedClassDefinitionEvent.stUT fqXOux �  �  PK
     &\h@                     �A�� Notification/Kernel/UT �XOux �  �  PK
     �Mh@j���  �  (          ��J� Notification/Kernel/AbstractNamespace.stUT eqXOux �  �  PK
     �Mh@>��               ��|� Notification/Kernel/Metaclass.stUT eqXOux �  �  PK
     �Mh@C��  �  '          ���� Notification/Kernel/MethodDictionary.stUT fqXOux �  �  PK
     �Mh@��k�[  [            ��'� Notification/Kernel/Class.stUT eqXOux �  �  PK
     �Mh@G�iL  L            ���� Notification/ModifiedEvent.stUT fqXOux �  �  PK
     �Mh@�r�|  |             ��{� Notification/ReorganizedEvent.stUT fqXOux �  �  PK
     �Mh@��r=  =            ��Q� NamespaceFinder.stUT eqXOux �  �  PK
     �Mh@�0��l  l            ���� GtkHistoryWidget.stUT eqXOux �  �  PK
     %\h@            
         �A�� StBrowser/UT �XOux �  �  PK
     �Mh@��F��@  �@  "          ���� StBrowser/GtkClassBrowserWidget.stUT fqXOux �  �  PK
     �Mh@?�s�  �  $          ���? StBrowser/GtkClassHierarchyWidget.stUT fqXOux �  �  PK
     �Mh@ij�"  "  *          ��L StBrowser/GtkCategorizedNamespaceWidget.stUT fqXOux �  �  PK
     �Mh@'�iR�  �  &          ���[ StBrowser/GtkCategorizedClassWidget.stUT fqXOux �  �  PK
     �Mh@r�p  p            ���s StBrowser/GtkCategoryWidget.stUT fqXOux �  �  PK
     �Mh@���A              ��e� StBrowser/GtkMethodWidget.stUT fqXOux �  �  PK
     �Mh@jȒ�   �             ��Ε GtkTranscriptWidget.stUT eqXOux �  �  PK
     &\h@                     �A� Tetris/UT �XOux �  �  PK
     �Mh@����  �            ��Z� Tetris/TetrisPieceZ.stUT fqXOux �  �  PK
     �Mh@�*���  �            ���� Tetris/TetrisPieceWidget.stUT fqXOux �  �  PK
     �Mh@����  �            ��ܤ Tetris/TetrisPieceL.stUT fqXOux �  �  PK
     �Mh@"O�  �            ��� Tetris/TetrisPieceT.stUT fqXOux �  �  PK
     �Mh@�b�)  )            ��D� Tetris/TetrisPiece.stUT fqXOux �  �  PK
     �Mh@ �H]�  �            ���� Tetris/Tetris.stUT fqXOux �  �  PK
     �Mh@	�l��  �            ���� Tetris/HighScores.stUT fqXOux �  �  PK
     �Mh@=>�.  .            ���� Tetris/Score.stUT fqXOux �  �  PK
     �Mh@8���O  O            ��T� Tetris/TetrisField.stUT fqXOux �  �  PK
     �Mh@b"p7�  �            ���� Tetris/TetrisPieceJ.stUT fqXOux �  �  PK
     �Mh@����  �            ��	� Tetris/TetrisPieceO.stUT fqXOux �  �  PK
     �Mh@�J"��  �            ��< Tetris/TetrisPieceI.stUT fqXOux �  �  PK
     �Mh@LPH$%  %            ��K Tetris/BlockWidget.stUT fqXOux �  �  PK
     �Mh@
��b�  �            ��� Tetris/TetrisPieceS.stUT fqXOux �  �  PK
     �Mh@D(#T�   �             ��� AbstractFinder.stUT eqXOux �  �  PK
     �Mh@<mO   O             ��� GtkAbstractConcreteWidget.stUT eqXOux �  �  PK
     �Mh@��c�  �            ��� GtkPackageBuilderWidget.stUT eqXOux �  �  PK    //�r  �4   