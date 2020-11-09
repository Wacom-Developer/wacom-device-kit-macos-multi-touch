///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
//    Displays finger data from callbacks from the Wacom MultiTouch API.
//
// COPYRIGHT
//    Copyright (c) 2011 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import <WacomMultiTouch/WacomMultiTouch.h>
#import "OTouchableWindow.h"
#import "DisplayModes.h"

@class FingerDataView;

@interface FingerDataController : NSObject
{
	@public
		IBOutlet OTouchableWindow	*window;
		IBOutlet FingerDataView		*dataView;
		IBOutlet NSTextField			*fingerCountField;
	
	@private
		eDisplayMode					mDisplayMode;
		CGFloat							mMarginX;
		CGFloat							mMarginY;
		CGFloat							mDataViewAspectRatio;
		CGFloat							mLogicalOriginX;
		CGFloat							mLogicalOriginY;
}

- (id) initWithDeviceID:(int)deviceID_I displayMode:(eDisplayMode)mode_I;

- (NSWindow *) window;
- (void) pushNewFingers:(WacomMTFingerCollection)fingerCollection_I;
- (void) setDisplayMode:(eDisplayMode)mode_I;
- (void) showWindow;

@end
