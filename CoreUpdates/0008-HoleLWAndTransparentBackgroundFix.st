'From Squeak3.7 of ''4 September 2004'' [latest update: #5989] on 20 April 2008 at 7:27:44 pm'!
	"Draw in order:
	- background color
	- grid, if any
	- background sketch, if any
	- Update and draw the turtleTrails form. See the comment in updateTrailsForm.
	- cursor box if any

	Later (in drawSubmorphsOn:) I will skip drawing the background sketch."


	"draw background sketch."
	backgroundMorph ifNotNil: [
		self clipSubmorphs ifTrue: [
			aCanvas clipBy: self clippingBounds
				during: [ :canvas | canvas fullDrawMorph: backgroundMorph ]]
			ifFalse: [ aCanvas fullDrawMorph: backgroundMorph ]]! !