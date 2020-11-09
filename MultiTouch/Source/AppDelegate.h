///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
//    Application controller for Wacom MultiTouch API sample application.
//
// COPYRIGHT
//    Copyright (c) 2011 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import <WacomMultiTouch/WacomMultiTouch.h>

#import "DisplayModes.h"

@interface AppDelegate : NSObject
{
	@public
		IBOutlet NSButton    *initButton;
		IBOutlet NSButton    *quitButton;
		IBOutlet NSButton    *fingerCallbackButton;
		IBOutlet	NSButton		*RegisterWindowCallBacks;
		IBOutlet NSTableView *capabilitiesTable;
	
	@private
		NSMutableArray       *mCapabilitiesDataSource;	// used to display the capabilities table
	
		BOOL						mIsTouchAPIConnected;
		BOOL						mIsFingerCallbackRegistered;
		BOOL						mIsWindowCallbackRegistered;
		NSMutableDictionary	*mFingerDataViewers;
	
		eDisplayMode         mDisplayMode;
}

// Actions
- (IBAction) initializeTouchAPI:(id)sender_I;
- (IBAction) registerFingerCallback:(id)sender_I;
- (IBAction) quitTouchAPI:(id)sender_I;
- (IBAction) registerWindowCallback:(id)sender_I;

// Callbacks
- (void) deviceDidAttachWithCapabilities:(WacomMTCapability)capabilities_I;
- (void) deviceDidDetach:(int)deviceID_I;
- (void) didReceiveFingerData:(WacomMTFingerCollection)fingerPacket_I;

// Utilities
- (void) addFingerDataControllerForDeviceID:(int)deviceID_I;
- (void) displayAttachedDevices;
- (void) setConstraints;

@end

