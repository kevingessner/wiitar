//
//  WWindowController.h
//  Wiitar
//
//  Created by Kevin Gessner on 11/7/07.
//  Copyright Kevin Gessner 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WiiRemote;
@class WiiRemoteDiscovery;
#import "iGetKeys.h"

int B_GREEN = 15;
int B_RED = 16;
int B_YELLOW = 13;
int B_BLUE = 14;
int B_ORANGE = 19;
int B_UP = 21;
int B_DOWN = 22;
int B_WHAMMY = 18;
int B_MINUS = 25;
int B_PLUS = 27;
int SEND_KEY_STRUM = 1;
int SEND_KEY_IMMEDIATELY = 2;

@interface WWindowController : NSWindowController
{	
	WiiRemoteDiscovery *discovery;
	WiiRemote* wii;
	
	Ascii2KeyCodeTable table;
	
	NSMutableSet *keysToSend;
	
	IBOutlet NSTextView *textView;
	IBOutlet NSButton *connectButton;
	IBOutlet NSPopUpButton *sendKeyMethodPopUp;
	IBOutlet NSColorWell *greenColor, *redColor, *yellowColor, *blueColor, *orangeColor, *strumColor, *minusColor, *plusColor;
	IBOutlet NSPopUpButton *greenKeyPopUp, *redKeyPopUp, *yellowKeyPopUp, *blueKeyPopUp, *orangeKeyPopUp, *strumKeyPopUp, *whammyKeyPopUp, *minusKeyPopUp, *plusKeyPopUp;
	IBOutlet NSTextField *greenKeyField, *redKeyField, *yellowKeyField, *blueKeyField, *orangeKeyField, *strumKeyField, *whammyKeyField, *minusKeyField, *plusKeyField;
	IBOutlet NSLevelIndicator *whammyIndicator;
	IBOutlet NSSlider *whammySlider;
	
	bool doing_whammy;
	int send_key_method;
}

- (IBAction)connect:(id)sender;
- (IBAction)changeKeyMethod:(id)sender;

- (void)userMessage:(NSString *)message;
- (void)sendKeys:(NSSet *)keys keyDown:(BOOL)keyDown;
- (void)sendKeyboardEvent:(CGKeyCode)keyCode keyDown:(BOOL)keyDown;
- (void)sendKey:(NSString *)key keyDown:(BOOL)keyDown;
- (void)keyChange:(short)keyCode keyDown:(BOOL)keyDown;

@end
