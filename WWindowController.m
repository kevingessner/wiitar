//
//  WWindowController.m
//  Wiitar
//
//  Created by Kevin Gessner on 11/7/07.
//  Copyright Kevin Gessner 2007. All rights reserved.
//


#import "WWindowController.h"
#import "WiiRemote.h";
#import "WiiRemoteDiscovery.h"

@implementation WWindowController

/*
 Set up the connection handlers and other initializations
 */
-(void)awakeFromNib{
	
	InitAscii2KeyCodeTable(&table);
	
	keysToSend = [[NSMutableSet setWithCapacity:5] retain];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(expansionPortChanged:)
												 name:@"WiiRemoteExpansionPortChangedNotification"
											   object:nil];
	
	discovery = [[WiiRemoteDiscovery alloc] init];
	[discovery setDelegate:self];
	
	[self connect:nil];
	
	doing_whammy = NO;
	
	send_key_method = SEND_KEY_STRUM;
}

/*
 Listen for changes to the Wiimote's expansion port and handle them
 */
- (void)expansionPortChanged:(NSNotification *)nc{
	WiiRemote* tmpWii = (WiiRemote*)[nc object];
	
	if ([tmpWii isExpansionPortAttached]){
		[tmpWii setExpansionPortEnabled:YES];
	}else{
		[tmpWii setExpansionPortEnabled:NO];
		
	}
	
}

/*
 Begins listening for connections
 */
- (IBAction)connect:(id)sender {
	[discovery stop];
	[discovery start];
	[self userMessage:@""];
	[self userMessage:@"To connect, please press the 1 and 2 buttons simultaneously."];
	[connectButton setEnabled:NO];
}

/*
 Changes the key-sending method
 */
- (IBAction)changeKeyMethod:(id)sender {
	//NSLog(@"%@", sender);
	send_key_method = [[sender selectedItem] tag];
	if(send_key_method == SEND_KEY_STRUM) {
		[strumKeyField setEnabled:NO];
		[strumKeyPopUp setEnabled:NO];
	} else {
		[strumKeyField setEnabled:YES];
		[strumKeyPopUp setEnabled:YES];
	}
}

// WiiRemoteDiscovery.h delegate methods

- (void) willStartWiimoteConnections {
	[self userMessage:@"===== Wiimote found. Connecting... ====="];
	[connectButton setEnabled:NO];
}

- (void) WiiRemoteDiscovered:(WiiRemote*)wiimote {
	[discovery stop];
	[connectButton setEnabled:NO];
	wii = wiimote;
	[wiimote setDelegate:self];
	[self userMessage:@"===== Connected to WiiRemote ====="];
	[wiimote setLEDEnabled1:YES enabled2:NO enabled3:YES enabled4:NO];
	//[wiimote setMotionSensorEnabled:NO];
	//	[wiimote setIRSensorEnabled:YES];
}

- (void) WiiRemoteDiscoveryError:(int)code {
	[self userMessage:[NSString stringWithFormat:@"===== Wiimote connection error (%d) =====", code]];
	[connectButton setEnabled:YES];
}

- (void) wiiRemoteDisconnected:(IOBluetoothDevice*)device {
	[self userMessage:@"===== Lost connection with Wiimote ====="];
	[connectButton setEnabled:YES];
}

// WiiRemote.h delegate methods

- (void) accelerationChanged:(WiiAccelerationSensorType)type accX:(unsigned char)accX accY:(unsigned char)accY accZ:(unsigned char)accZ {

}

- (void) buttonChanged:(WiiButtonType)type isPressed:(BOOL)isPressed {
	short keyCode = -1;

	if(type == B_GREEN) {
		if([[greenKeyPopUp selectedItem] tag]) // special keys have keycode as tag; otherwise it's 0 and use the field.
			keyCode = [[greenKeyPopUp selectedItem] tag];
		else {
			if([[greenKeyField stringValue] length]) {
				char c = [[greenKeyField stringValue] characterAtIndex:0];
				keyCode = AsciiToKeyCode(&table, c);
			}
		}
		if(keyCode >= 0) [self keyChange:keyCode keyDown:isPressed];
				
		[greenColor setColor:(isPressed ? [NSColor greenColor] : [NSColor controlColor])];
	} else if(type == B_RED) {
		if([[redKeyPopUp selectedItem] tag]) // special keys have keycode as tag; otherwise it's 0 and use the field.
			keyCode = [[redKeyPopUp selectedItem] tag];
		else {
			if([[redKeyField stringValue] length]) {
				char c = [[redKeyField stringValue] characterAtIndex:0];
				keyCode = AsciiToKeyCode(&table, c);
			}
		}
		if(keyCode >= 0) [self keyChange:keyCode keyDown:isPressed];

		[redColor setColor:(isPressed ? [NSColor redColor] : [NSColor controlColor])];
	} else if(type == B_YELLOW) {
		if([[yellowKeyPopUp selectedItem] tag]) // special keys have keycode as tag; otherwise it's 0 and use the field.
			keyCode = [[yellowKeyPopUp selectedItem] tag];
		else {
			if([[yellowKeyField stringValue] length]) {
				char c = [[yellowKeyField stringValue] characterAtIndex:0];
				keyCode = AsciiToKeyCode(&table, c);
			}
		}
		if(keyCode >= 0) [self keyChange:keyCode keyDown:isPressed];
		
		[yellowColor setColor:(isPressed ? [NSColor yellowColor] : [NSColor controlColor])];
	} else if(type == B_BLUE) {
		if([[blueKeyPopUp selectedItem] tag]) // special keys have keycode as tag; otherwise it's 0 and use the field.
			keyCode = [[blueKeyPopUp selectedItem] tag];
		else {
			if([[blueKeyField stringValue] length]) {
				char c = [[blueKeyField stringValue] characterAtIndex:0];
				keyCode = AsciiToKeyCode(&table, c);
			}
		}
		if(keyCode >= 0) [self keyChange:keyCode keyDown:isPressed];
		
		[blueColor setColor:(isPressed ? [NSColor blueColor] : [NSColor controlColor])];
	} else if(type == B_ORANGE) {
		if([[orangeKeyPopUp selectedItem] tag]) // special keys have keycode as tag; otherwise it's 0 and use the field.
			keyCode = [[orangeKeyPopUp selectedItem] tag];
		else {
			if([[orangeKeyField stringValue] length]) {
				char c = [[orangeKeyField stringValue] characterAtIndex:0];
				keyCode = AsciiToKeyCode(&table, c);
			}
		}
		if(keyCode >= 0) [self keyChange:keyCode keyDown:isPressed];
		
		[orangeColor setColor:(isPressed ? [NSColor orangeColor] : [NSColor controlColor])];
	} else if(type == B_UP || type == B_DOWN) {
		if(send_key_method == SEND_KEY_IMMEDIATELY) {
			if([[strumKeyPopUp selectedItem] tag]) // special keys have keycode as tag; otherwise it's 0 and use the field.
				keyCode = [[strumKeyPopUp selectedItem] tag];
			else {
				if([[strumKeyField stringValue] length]) {
					char c = [[strumKeyField stringValue] characterAtIndex:0];
					keyCode = AsciiToKeyCode(&table, c);
				}
			}
			if(keyCode >= 0) [self keyChange:keyCode keyDown:isPressed];
		} else if(send_key_method == SEND_KEY_STRUM) {
			if(isPressed) {
				[self sendKeys:keysToSend keyDown:NO];
				[self sendKeys:keysToSend keyDown:YES];
			}
		}
		
		[strumColor setColor:(isPressed ? [NSColor blackColor] : [NSColor controlColor])];
	} else 	if(type == B_MINUS) {
		if([[minusKeyPopUp selectedItem] tag]) // special keys have keycode as tag; otherwise it's 0 and use the field.
			keyCode = [[minusKeyPopUp selectedItem] tag];
		else {
			if([[minusKeyField stringValue] length]) {
				char c = [[minusKeyField stringValue] characterAtIndex:0];
				keyCode = AsciiToKeyCode(&table, c);
			}
		}
		if(keyCode >= 0) [self sendKeyboardEvent:keyCode keyDown:isPressed];
		
		[minusColor setColor:(isPressed ? [NSColor blackColor] : [NSColor controlColor])];
	} else if(type == B_PLUS) {
		if([[plusKeyPopUp selectedItem] tag]) // special keys have keycode as tag; otherwise it's 0 and use the field.
			keyCode = [[plusKeyPopUp selectedItem] tag];
		else {
			if([[plusKeyField stringValue] length]) {
				char c = [[plusKeyField stringValue] characterAtIndex:0];
				keyCode = AsciiToKeyCode(&table, c);
			}
		}
		if(keyCode >= 0) [self sendKeyboardEvent:keyCode keyDown:isPressed];
		
		[plusColor setColor:(isPressed ? [NSColor blackColor] : [NSColor controlColor])];
	} else {
		if(isPressed) NSLog(@"press: %d", type);
		else if(!isPressed) NSLog(@"release: %d", type);
	}

}

- (void) joyStickChanged:(WiiJoyStickType)type tiltX:(unsigned char)tiltX tiltY:(unsigned char)tiltY {
		
}

- (void) analogButtonChanged:(WiiButtonType)type amount:(unsigned char)pressure {
	char pressure_offset = 15; // neutral value of whammy bar
	if(type == B_WHAMMY) {
		[whammyIndicator setIntValue:(pressure - pressure_offset)];
		if(pressure > pressure_offset + [whammySlider floatValue] && !doing_whammy) {
			if([[whammyKeyPopUp selectedItem] tag]) // special keys have keycode as tag; otherwise it's 0 and use the field.
				[self sendKeyboardEvent:[[whammyKeyPopUp selectedItem] tag] keyDown:YES];
			else
				[self sendKey:[whammyKeyField stringValue] keyDown:YES];
			doing_whammy = YES;
		} else if(pressure <= pressure_offset + [whammySlider floatValue] && doing_whammy) {
			if([[whammyKeyPopUp selectedItem] tag]) // special keys have keycode as tag; otherwise it's 0 and use the field.
				[self sendKeyboardEvent:[[whammyKeyPopUp selectedItem] tag] keyDown:NO];
			else
				[self sendKey:[whammyKeyField stringValue] keyDown:NO];
			doing_whammy = NO;
		}
	}
	
}

// end delegate methods

- (void)userMessage:(NSString *)message {
	[textView setString:[NSString stringWithFormat:@"%@\n%@", message, [textView string]]];
}

- (void)keyChange:(short)keyCode keyDown:(BOOL)keyDown {
	if(send_key_method == SEND_KEY_IMMEDIATELY) {
		[self sendKeyboardEvent:keyCode keyDown:keyDown];
	} else if(send_key_method == SEND_KEY_STRUM) {
		if(keyDown) {
			[keysToSend addObject:[NSNumber numberWithShort:keyCode]];
		} else {
			[keysToSend removeObject:[NSNumber numberWithShort:keyCode]];
			[self sendKeyboardEvent:keyCode keyDown:NO];
		}
	}
}

/*
 Send successive keypresses for each key code (as an NSNumber) in the keys NSSet
 */
- (void)sendKeys:(NSSet *)keys keyDown:(BOOL)keyDown {	
	unsigned i;
	NSArray *k = [keys allObjects];
	if(![k count]) return;
	for(i = 0; i < [k count]; i++) {
		[self sendKeyboardEvent:[[k objectAtIndex:i] shortValue] keyDown:keyDown];
	}
}

/*
 Send a keypress event for the first character in the given string
 */
- (void)sendKey:(NSString *)key keyDown:(BOOL)keyDown {
	if(![key length]) return;
	char c = [key characterAtIndex:0];
	short keycode = AsciiToKeyCode(&table, c);
	[self sendKeyboardEvent:keycode keyDown:keyDown];
}

/*
 Use Carbon to create a keypress for the given keycode
 */
- (void)sendKeyboardEvent:(CGKeyCode)keyCode keyDown:(BOOL)keyDown{
	CFRelease(CGEventCreate(NULL));		
	// this is Tiger's bug.
	//see also: http://www.cocoabuilder.com/archive/message/cocoa/2006/10/4/172206
	
	
	CGEventRef event = CGEventCreateKeyboardEvent(NULL, keyCode, keyDown);
	CGEventPost(kCGHIDEventTap, event);
	CFRelease(event);
	usleep(10000);
}

/*
 Close the connection to the remote and terminate
 */
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender{
	
	[wii closeConnection];
		
	return NSTerminateNow;
}

@end
