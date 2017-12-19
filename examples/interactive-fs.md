
Automating things that might be too trivial to automate considering you'd have to write a program for it.

Like for instance,

	"show me 50 random files from this folder"
	"okay but not files from today"
	"alright, move those to a folder"
	"I meant copy - copy them to a folder!"
	"yes, undo and then copy them"

Or actually it might be more like

	> show me 50 random files from this folder
	< What folder? [Select folder]
	*selects a folder*
	*> show me 50 random files from *representation of folder*
	< *list of files*
	> okay but not files from today
	< *list of files*
	> alright, move those to a folder
	< What folder? [Select folder]
	*creates and selects a folder*
	*> alright, move those to *representation of the new folder*
	< 50 files moved to *representation of the new folder* [Undo]
	*clicks undo*
	> alright, copy those to *representation of the new folder*

with `*>` representing an automatically-amended input
