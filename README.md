# notes
Notes is a canvas with ability to add drawing, writing, music and photos. All elements are enabled to resize and move around by user.
## Usage
Create a canvas:
```
    _noteViewController = [[NTNoteViewController alloc] initWithContentViewFrame:CGRectMake(0,0,908.0f, 768.0f)];
    [_noteViewController setAutomaticStop:![_settings stopRecordingManually]];
    [_noteViewController setAutomaticStopInterval:[_settings stopRecordingAfter]];
    [_noteViewController setDelegate:self];
    
    [self addChildViewController:_noteViewController];
    [_noteViewController didMoveToParentViewController:self];
    [_scrollView addSubview:_noteViewController.view];
    
    // you also need to set the frame somewhere
    [_noteViewController.view setFrame:self.view.bounds];
```
To export / inport data:
```
[_noteViewController setFileContents:[self dataFromNoteString:_json]];
[_noteViewController saveNoteItems];
```
To request a new note:
```
// remove note
[[NoteDataLoader sharedInstance] removeNote:noteItem];
// add different types of notes
[_noteViewController requestNewNoteTextItemWithFrame:CGRectMake(0, 0, 200, 100) selectText:NO];
[_noteViewController requestNewNoteAudioItem];
```
To change properties etc:
```
// set different font
if ([_noteViewController.currentNoteView.item respondsToSelector:@selector(setFont:)]) {
    [(NTNoteTextItem *)_noteViewController.currentNoteView.item setFont:font];
}
// set brush properties, check out NSNotePathItem setBrushAttributes: method for more details about dict
if ([_noteViewController.currentNoteView isKindOfClass:[NTPathView class]]) {
    NTNotePathItem *pathItem = (NTNotePathItem *)_noteViewController.currentNoteView.item;
    NSDictionary *brush = _toolBar.brush;
    [pathItem setBrushAttributes:brush];
    [_noteViewController.currentNoteView setNeedsDisplay];
}
// to change colors etc
if ([_noteViewController.currentNoteView.item respondsToSelector:@selector(setColor:)]){
    [(NTNoteTextItem *)_noteViewController.currentNoteView.item setColor:color];
    [_noteViewController updateCurrentNoteView];
} else if ([_noteViewController.currentNoteView isKindOfClass:[NTPathView class]]){
    NTNotePathItem *pathItem = (NTNotePathItem*)_noteViewController.currentNoteView.item;
    [pathItem setLineColor:color];
    [_noteViewController.currentNoteView setNeedsDisplay];
}
```
To clear the canvas:
```
[_noteViewController clearContent];
```
Also remember to implement delegates according to your needs.
## Requirements
AUAccount requires Xcode 4 or higher, targeting iOS 5.0 and above
## Installation
Clone the source project and run:
```ruby
git submodule init
git submodule update
```
## Authors
Emil Wojtaszek, emil@appunite.com;
Natalia Osiecka, natalia.osa@appunite.com;
Piotr Adamczak, piotr.adamczak@appunite.com;
AppUnite.com
## License
Notes is available under the MIT license.
