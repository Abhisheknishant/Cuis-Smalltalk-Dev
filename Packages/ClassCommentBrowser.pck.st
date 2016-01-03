'From Cuis 4.2 of 25 July 2013 [latest update: #2568] on 5 November 2015 at 4:23:00.031262 pm'!
'Description Browse class comments for classes with names such as "Pluggable," "Morphic," "Text," or "Morph" which appear in a hierarchical list.'!
!provides: 'ClassCommentBrowser' 1 22!
!classDefinition: #CommentGuide category: #ClassCommentBrowser!
AbstractHierarchicalList subclass: #CommentGuide
	instanceVariableNames: 'window rootNames root browser subList index key'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'ClassCommentBrowser'!
!classDefinition: 'CommentGuide class' category: #ClassCommentBrowser!
CommentGuide class
	instanceVariableNames: 'topics'!

!classDefinition: #CommentGuideWrapper category: #ClassCommentBrowser!
ObjectExplorerWrapper subclass: #CommentGuideWrapper
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'ClassCommentBrowser'!
!classDefinition: 'CommentGuideWrapper class' category: #ClassCommentBrowser!
CommentGuideWrapper class
	instanceVariableNames: ''!

!classDefinition: #CommentGuideListMorph category: #ClassCommentBrowser!
HierarchicalListMorph subclass: #CommentGuideListMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'ClassCommentBrowser'!
!classDefinition: 'CommentGuideListMorph class' category: #ClassCommentBrowser!
CommentGuideListMorph class
	instanceVariableNames: ''!

!classDefinition: #CommentGuideWindow category: #ClassCommentBrowser!
SystemWindow subclass: #CommentGuideWindow
	instanceVariableNames: 'listMorph textMorph'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'ClassCommentBrowser'!
!classDefinition: 'CommentGuideWindow class' category: #ClassCommentBrowser!
CommentGuideWindow class
	instanceVariableNames: ''!


!CommentGuide commentStamp: 'jmv 9/19/2015 21:02' prior: 0!
Class comments browser for Cuis

To open, evaluate:
	CommentGuide open.

Class names are organized into "categories" according to whether a certain string can be found in the class name.

The categories appear in a hierarchical list whose elements can be expanded into class names. When a class name is selected, its class comment appears in an adjacent pane.

A pop-up menu enables browsing the class, the class' hierarchy, or its protocol. Searches of the comments of classes in a category can be done. Searches over the names of all classes can be done.

This class provides the model for browsing class comments based on class names which contain certain strings, such as:

	Pluggable
	Morphic
	Debug
	Text
	Morph!

!CommentGuideWrapper commentStamp: 'dhn 9/12/2015 12:35' prior: 0!
Provide the wrapper for a list item in CommentGuideWindow.

Removes the undesired cruft after the item name.!

!CommentGuideListMorph commentStamp: 'dhn 11/5/2015 12:19' prior: 0!
A list of terms and acronyms which occur in class names. Selection can be made by typed key, arrows, or clicks.!

!CommentGuideWindow commentStamp: '<historical>' prior: 0!
Show a window for browsing class comments based on class names which contain certain strings, such as:

	Pluggable
	Morphic
	Debug
	Text
	Morph
	
The window has a text pane with a list pane beside it. 

CommentGuide open.	
!

!CommentGuide methodsFor: 'accessing' stamp: 'dhn 10/6/2015 20:43'!
commentOf: aString
	"Answer the class comment of the class named aString"

	| className |
	
	window setLabel: 'Class Comment for ', aString.
	
	className _ Smalltalk at: aString asSymbol.
	browser setClass: className selector: nil.
	^ browser classCommentText
! !

!CommentGuide methodsFor: 'accessing' stamp: 'dhn 10/7/2015 13:29'!
editorClassFor: textGetter

	^ SmalltalkEditor
! !

!CommentGuide methodsFor: 'accessing' stamp: 'dhn 11/5/2015 14:58'!
getCurrentSelection
	"Send the class comment to the text pane"
	| str |

	super getCurrentSelection.
	currentSelection ifNotNil: [
		currentSelection withoutListWrapper class == String
			ifTrue: [str _ self commentOf: currentSelection item]
			ifFalse: [
				str _ ''.
				window setLabel: 'Class Comment Browser'.
				root _ currentSelection].
		window textMorph model actualContents: str].
	^ currentSelection
! !

!CommentGuide methodsFor: 'accessing' stamp: 'dhn 9/24/2015 09:08'!
getList
	"Answer the roots of the hierarchical list"
	| arr k |
	arr _ Array new: rootNames size.
	k _ 0.
	rootNames keys asSortedCollection do: [:ea |
		k _ k + 1.
		arr at: k put: (
			CommentGuideWrapper
				with: (rootNames at: ea) asSortedCollection
				name: ea
				model: self)].
	^ arr
! !

!CommentGuide methodsFor: 'accessing' stamp: 'dhn 11/5/2015 15:22'!
indexOf: aChar
	"Set the current selection to the root which starts with aChar"
	| sel ch |

	key = aChar
		ifTrue: [
			index _ index + 1.
			index > subList size
				ifTrue: [index _ 1]]
		ifFalse: [
			index _ 1.
			key _ aChar.
			ch _ key asString capitalized.
			subList _ self getList select: [:ea | ch  = ea itemName first asString].
			window setLabel: 'Class Comment Browser'.
			window textMorph model actualContents: ''].
	subList ifEmpty: [window listMorph flash.	^ 0].
	sel _ subList at: index.
	currentSelection _ sel.
	currentSelection ifNil: [^self].
	currentSelection sendSettingMessageTo: self
! !

!CommentGuide methodsFor: 'initialization' stamp: 'dhn 10/6/2015 20:40'!
initialize
	"Establish the database for the class comment browser"
	
	super initialize.
	
	self rootNames: self setList.
	browser _ Browser new
! !

!CommentGuide methodsFor: 'parsing' stamp: 'dhn 9/21/2015 16:50'!
parseClassNames
	"Answer a set of initial-caps terms and acronyms which appear in class names"
	| set terms |
	set _ Set new.
	Smalltalk classNames do: [:c |
		terms _ self parseName: c asString.
		terms do: [:ea | set add: ea]].
	^ set asSortedCollection! !

!CommentGuide methodsFor: 'parsing' stamp: 'dhn 9/21/2015 18:55'!
parseName: aString
	"Answer the initial-caps components and acronyms of aString"
	| tokens acronym str |
	tokens _ aString findTokens: self class caps keep: self class caps.
	str _ OrderedCollection new.
	acronym _ ''.
	tokens do: [:ea |
		ea first isUppercase 
			ifTrue: [acronym _ acronym, ea first asString]
			ifFalse: [
				(acronym size > 1) 
					ifTrue: [
						str add: (acronym copyFrom: 1 to: acronym size - 1).
						acronym _ acronym last asString].
				str add: acronym, ea.
				acronym _ '']].
	^ str! !

!CommentGuide methodsFor: 'accessing' stamp: 'dhn 9/15/2015 18:51'!
root
	"Answer the value of root"

	^ root! !

!CommentGuide methodsFor: 'accessing' stamp: 'dhn 9/22/2015 17:04'!
rootNames: anObject
	"Set the value of rootNames"

	rootNames _ anObject! !

!CommentGuide methodsFor: 'accessing' stamp: 'dhn 9/17/2015 21:01'!
selectedRoot
	"Answer the class names containing root as a substring"
	^ rootNames at: root itemName! !

!CommentGuide methodsFor: 'initialization' stamp: 'dhn 11/5/2015 12:15'!
setList
	"Answer the dictionary of roots and their children for the hierarchical list"
	| dx |
	dx _ Dictionary new.
	self parseClassNames do: [:n | dx at: n put: OrderedCollection new].
	
	Smalltalk classNames do: [:ea |
		| in |
		in _ ea asString.
		dx keysAndValuesDo: [:rootTerm :val |	"try to find a root for 'in' "
			(in findString: rootTerm asString) > 0 ifTrue: [val add: in]]].
	^ dx! !

!CommentGuide methodsFor: 'accessing' stamp: 'dhn 9/9/2015 18:24'!
window: anObject
	"Set the value of window"

	window _ anObject! !

!CommentGuide class methodsFor: 'parsing' stamp: 'dhn 9/18/2015 18:26'!
caps
	"Answer the alphabet, capitalized"
	^ $A to: $Z! !

!CommentGuide class methodsFor: 'instance creation' stamp: 'dhn 9/11/2015 21:05'!
how
"
	CommentGuide open.
"! !

!CommentGuide class methodsFor: 'instance creation' stamp: 'dhn 9/23/2015 18:29'!
open
"
	CommentGuide open.
"
	(CommentGuideWindow
		open: self new
		label: 'Class Comment Browser')
		setWindowColor:  Theme current browser! !

!CommentGuideWrapper methodsFor: 'access' stamp: 'dhn 9/12/2015 11:31'!
asString
	"Answer the string for the hierarchical list category"
	^ itemName! !

!CommentGuideListMorph methodsFor: 'events-processing' stamp: 'dhn 11/5/2015 14:52'!
update: aSymbol
	"React to list selection via typed key"
	| i |
	
	super update: aSymbol.
	aSymbol == #keySelection
		ifTrue: [
			model getCurrentSelection ifNil: [^self selectionIndex: 0].
			i _ scroller submorphs findFirst: [:m | m contents == model getCurrentSelection itemName].
			^ self selectionIndex: i]
! !

!CommentGuideWindow methodsFor: 'browsing' stamp: 'dhn 11/5/2015 14:53'!
browseClass
	"Open a browser on the selected class"
	model getCurrentSelection item class == String
		ifTrue: [
			BrowserWindow 
				fullOnClass: (Smalltalk at: model getCurrentSelection item asSymbol) 
				selector: nil]! !

!CommentGuideWindow methodsFor: 'browsing' stamp: 'dhn 11/5/2015 14:54'!
browseFullProtocol
	"Create and schedule a new protocol browser on the currently selected class"

	| aPBrowser class label |
	model getCurrentSelection item class == String
		ifTrue: [
			class _ Smalltalk at: model getCurrentSelection item asSymbol.
			aPBrowser _ ProtocolBrowser new on: class.
			label _ 'Entire protocol of: ', class name.
			MessageSetWindow open: aPBrowser label: label] ! !

!CommentGuideWindow methodsFor: 'browsing' stamp: 'dhn 11/5/2015 14:54'!
browseHierarchy
	"Create and schedule a class list browser on the selected class' hierarchy."

	model getCurrentSelection item class == String
		ifTrue: [
			HierarchyBrowserWindow
				onClass: (Smalltalk at: model getCurrentSelection item asSymbol)
				selector: nil]! !

!CommentGuideWindow methodsFor: 'browsing' stamp: 'dhn 11/5/2015 14:54'!
browseVersions
	"Open a browser on the versions of the selected class' comment"
	model getCurrentSelection item class == String
		ifTrue: [
			VersionsBrowserWindow 
				browseCommentOf: (Smalltalk at: model getCurrentSelection item asSymbol)]! !

!CommentGuideWindow methodsFor: 'instance creation' stamp: 'dhn 11/5/2015 11:12'!
buildMorphicWindow
	"Answer a window for the class comment browser"
	| row |
	listMorph _ CommentGuideListMorph
		model: model
		listGetter: #getList
		indexGetter: #getCurrentSelection
		indexSetter: #noteNewSelection:
		mainView: self
		menuGetter: #commentGuideMenu
		keystrokeAction: #respondToKey:.
	listMorph name: #Hierarchy.
	textMorph _ TextModelMorph textProvider: model.
	textMorph 
		name: 'Class Comment';
		askBeforeDiscardingEdits: false.
	row _ LayoutMorph newRow.
	row
		addMorph: listMorph fixedWidth: 250;
		addAdjusterAndMorph: textMorph proportionalWidth: 1.0.
	self layoutMorph
		addMorph: row.
	updatablePanes _ #(listMorph).
	model window: self! !

!CommentGuideWindow methodsFor: 'menu' stamp: 'dhn 10/2/2015 15:31'!
commentGuideMenu
	"Show the popup menu"
	
	| aMenu |
	aMenu _ MenuMorph new defaultTarget: self.
	model getCurrentSelection
		ifNil: [
			aMenu addList: #(
				('search all class names'		searchClassNames)
				('search all class comments'	searchAllComments))]
		ifNotNil: [
			aMenu addList: #(
				('search comments'		searchComment)	"comments, if selection"
				('comment versions'		browseVersions)
				('browse full'				browseClass)
				('browse hierarchy'		browseHierarchy)
				('browse protocol'		browseFullProtocol)).

				].
	^ aMenu! !

!CommentGuideWindow methodsFor: 'initialization' stamp: 'dhn 9/24/2015 08:47'!
initialize

	super initialize.

	SystemChangeNotifier uniqueInstance removeActionsWithReceiver: self.

	SystemChangeNotifier uniqueInstance
		when: #classAdded send: #refreshListAfterDelay to: self;
		when: #classCommented send: #refreshListAfterDelay to: self;
		when: #classDefinitionChanged send: #refreshListAfterDelay to: self;
		when: #classRecategorized send: #refreshListAfterDelay to: self;
		when: #classRemoved send: #refreshListAfterDelay to: self;
		when: #classRenamed send: #refreshListAfterDelay to: self
! !

!CommentGuideWindow methodsFor: 'accessing' stamp: 'dhn 10/27/2015 20:49'!
listMorph
	"Answer the value of listMorph"

	^ listMorph! !

!CommentGuideWindow methodsFor: 'instance creation' stamp: 'dhn 9/24/2015 09:35'!
refreshList
	"Re-build the hierarchical list"
	model 
		noteNewSelection: nil;
		rootNames: model setList.
	listMorph update: #getList! !

!CommentGuideWindow methodsFor: 'instance creation' stamp: 'dhn 9/24/2015 08:45'!
refreshListAfterDelay
	"The pause that refreshes"

	self addAlarm: #refreshList after: 20 "milliseconds" ! !

!CommentGuideWindow methodsFor: 'events' stamp: 'dhn 11/5/2015 11:33'!
respondToKey: aChar
	"Take action when a key is struck. The key value is aChar"

	model indexOf: aChar.
	listMorph update: #keySelection! !

!CommentGuideWindow methodsFor: 'searching' stamp: 'dhn 9/21/2015 19:31'!
searchAllComments
	"Search for a string in class comments of all classes"
	| arg hits menu |
	arg _ ''.
		arg _ FillInTheBlankMorph request: 'Search All Class Comments for:'.
		(menu _ MenuMorph entitled: 'Comments of All Classes with "', arg, '"')
			defaultTarget: self;
			addStayUpIcons.
			
		hits _ self searchIn: Smalltalk classNames for: arg.
		hits 
			ifEmpty: [listMorph flash]
			ifNotEmpty: [
				hits do: [:h | menu add: h selector: #showFind: argument: h].
				menu 
					openInWorld;
					morphPosition: self morphPosition + (-70@50)].
	^ nil! !

!CommentGuideWindow methodsFor: 'searching' stamp: 'dhn 9/21/2015 16:50'!
searchClassNames
	"Search class names for a string"
	| arg str hits menu |
	arg _ FillInTheBlankMorph request: 'Search Class Names for:'.
	arg 
		ifNotEmpty: [
			hits _ OrderedCollection new.
			(menu _ MenuMorph entitled: 'Class Names With "', arg, '"')
				defaultTarget: self;
				addStayUpIcons.
			Smalltalk classNames do: [:ea |
				str _ ea asString.
				(str findString: arg startingAt: 1 caseSensitive: false) > 0
					ifTrue: [
						hits addLast: ea asString.
			]].
		hits 
			ifEmpty: [listMorph flash]
			ifNotEmpty: [
				hits do: [:h | menu add: h selector: #showFind: argument: h].
				menu 
					openInWorld;
					morphPosition: self morphPosition + (-70@50)]]! !

!CommentGuideWindow methodsFor: 'searching' stamp: 'dhn 11/5/2015 16:21'!
searchComment
	"Search for a string in class comments of root siblings"
	| arg hits col nam menu |
	arg _ ''.
	(model getCurrentSelection item isKindOf: String)
		ifTrue: [	"searching from the leaf"
			col _ model selectedRoot.
			nam _ model root itemName]
		ifFalse: [	"searching from the root"
			col _ model getCurrentSelection item.	"gather every leaf"
			nam _ model getCurrentSelection itemName].
		arg _ FillInTheBlankMorph request: 'Search Root Named "', nam, '"'.
		(menu _ MenuMorph entitled: 'Comments in Root with "', arg, '"')
			defaultTarget: self;
			addStayUpIcons.

		hits _ self searchIn: col for: arg.
		hits 
			ifEmpty: [listMorph flash]
			ifNotEmpty: [
				hits do: [:h | menu add: h selector: #showFind: argument: h].
				menu 
					openInWorld;
					morphPosition: self morphPosition + (-70@50)].
	^ nil! !

!CommentGuideWindow methodsFor: 'searching' stamp: 'dhn 11/5/2015 16:13'!
searchIn: aCollection for: aString
	"Answer the names of classes in aCollection whose comments include aString"
	| str hits |
	hits _ OrderedCollection new.
	aCollection do: [:ea |
		str _ model commentOf: ea.
		(str findString: aString startingAt: 1 caseSensitive: false) > 0
			ifTrue: [hits addLast: ea]].
	^ hits! !

!CommentGuideWindow methodsFor: 'browsing' stamp: 'dhn 9/10/2015 21:11'!
showFind: aName
	"Cause the class comment for aName to display"
	| str |
	str _ model commentOf: aName.
	textMorph model actualContents: str! !

!CommentGuideWindow methodsFor: 'accessing' stamp: 'dhn 8/19/2015 19:47'!
textMorph
	"Answer the value of textMorph"

	^ textMorph! !

!CommentGuideWindow class methodsFor: 'instance creation' stamp: 'dhn 9/24/2015 08:48'!
how
"
	CommentGuide open.
"! !