///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
//    A view which displays finger data from the Wacom MultiTouch API.
//
// COPYRIGHT
//    Copyright (c) 2011 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import <WacomMultiTouch/WacomMultiTouch.h>
#import "DisplayModes.h"

@interface FingerDataView : NSView
{
	@private
		NSMutableArray *mFingerData; // NSValues of pointers to WMTFingerCollections; a first-in, last-out queue
		NSSize         mLogicalSize; // tablet coordinate system extents
		
		NSUInteger     mMaxPacketsToDisplay;
		BOOL				mClearOnNextDown;
		eDisplayMode   mDisplayMode;
}

// Accessors
- (void) pushNewFingers:(WacomMTFingerCollection)fingerCollection_I;
- (void) setBoundsFromLogicalSize:(NSSize)deviceSize_I;

// Drawing
- (NSColor *) colorForFinger:(size_t)fingerIndex_I;

// Utilities
- (void) popAllFingers;

- (void) setDisplayMode:(eDisplayMode)mode_I;

@end
