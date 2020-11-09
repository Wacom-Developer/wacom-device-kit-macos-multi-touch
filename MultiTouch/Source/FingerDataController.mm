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

#import <WacomMultiTouch/WacomMultiTouch.h>
#import "FingerDataController.h"
#import "FingerDataView.h"

@implementation FingerDataController

///////////////////////////////////////////////////////////////////////////////

// UI has been loaded.

- (void) awakeFromNib
{
	// stash some window geometry for fancy resizing later.
	mMarginX  = NSWidth([[window contentView] bounds])  - NSWidth([dataView frame]);
	mMarginY  = NSHeight([[window contentView] bounds]) - NSHeight([dataView frame]);
}

///////////////////////////////////////////////////////////////////////////////

// Creates a new controller which displays data from a Finger read
//	callback.

- (instancetype) initWithDeviceID:(int)deviceID_I displayMode:(eDisplayMode)mode_I
{
	self = [super init];

	[[NSBundle mainBundle] loadNibNamed:@"FingerData" owner:self topLevelObjects:nil];
	
	WacomMTCapability capabilities      = {};
	CGSize            displaySizeInMM   = CGSizeZero;
	CGSize            touchSizeInMM     = CGSizeZero;
	CGRect            displayRectInPts  = CGRectZero;
	NSSize            contentSize       = NSZeroSize;
	NSSize            windowContentSize = NSZeroSize;
	
	WacomMTGetDeviceCapabilities(deviceID_I, &capabilities);

	// Display a view which is the exact size of the touch sensor area.
	
	mLogicalOriginX = capabilities.LogicalOriginX;
	mLogicalOriginY = capabilities.LogicalOriginY;
	
	touchSizeInMM     = CGSizeMake(capabilities.PhysicalSizeX, capabilities.PhysicalSizeY);
	displayRectInPts	= CGDisplayBounds(CGMainDisplayID());
	displaySizeInMM   = CGDisplayScreenSize(CGMainDisplayID()); // physical size in mm
	
	contentSize.width    = touchSizeInMM.width  * (displayRectInPts.size.width  / displaySizeInMM.width);
	contentSize.height   = touchSizeInMM.height * (displayRectInPts.size.height / displaySizeInMM.height);
	mDataViewAspectRatio	= contentSize.width / contentSize.height;

	// Size the window to physically match the sensor size
	windowContentSize = NSMakeSize(contentSize.width + mMarginX, contentSize.height + mMarginY);
	mDisplayMode = mode_I;
	[dataView setDisplayMode:mode_I];

	[window setContentSize:windowContentSize];
	[window setTitle:[NSString stringWithFormat:@"Finger Data / Device ID %d", deviceID_I]];
	[window setFingerController:self];
	
	// Make the coordinate system of the view use logical units, so the view can 
	// draw finger data directly without units conversion. 
	[dataView setBoundsFromLogicalSize:NSMakeSize(capabilities.LogicalWidth, capabilities.LogicalHeight)];

	return self;
}

#pragma mark -
#pragma mark ACCESSORS
#pragma mark -

///////////////////////////////////////////////////////////////////////////////

// Returns the viewer window.

- (NSWindow *) window
{
	return self->window;
}

///////////////////////////////////////////////////////////////////////////////

-(void) setDisplayMode:(eDisplayMode)mode_I
{
	mDisplayMode = mode_I;
	[dataView setDisplayMode:mode_I];
}

//////////////////////////////////////////////////////////////////////////////

// Adds a new set of finger data to the display.

- (void) pushNewFingers:(WacomMTFingerCollection)fingerCollection_I
{
	size_t   fingerCount    = 0;
	
	for(size_t fingerCounter = 0; fingerCounter < fingerCollection_I.FingerCount; fingerCounter++)
	{
		// Count the finger ONLY if it is down
		WacomMTFinger *finger = &fingerCollection_I.Fingers[fingerCounter];
		finger->X = finger->X - mLogicalOriginX;
		finger->Y = finger->Y - mLogicalOriginY;
		if(finger->TouchState == WMTFingerStateDown || finger->TouchState == WMTFingerStateHold)
		{
			fingerCount++;
			NSLog(@"ID:%i X:%f Y:%f W:%f H:%f Sens:%i Oren:%f Conf:%s State:%i", finger->FingerID, finger->X,
				finger->Y, finger->Width, finger->Height, finger->Sensitivity, finger->Orientation, finger->Confidence?"Yes":"No",
				finger->TouchState);
		}
	}
	[fingerCountField setIntValue:static_cast<int>(fingerCount)];
	[dataView pushNewFingers:fingerCollection_I];
}

#pragma mark -
#pragma mark ACTIONS
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

- (void) showWindow
{
		[self->window makeKeyAndOrderFront:nil];
}

#pragma mark -
#pragma mark DELEGATES
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

// This is just fancy resize code to make sure the window maintains
//	the aspect ratio of the tablet data view.

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
	NSRect   proposedContentRect  = [sender contentRectForFrameRect:NSMakeRect(0, 0, frameSize.width, frameSize.height)];
	NSSize   newSize              = NSZeroSize;
	
	proposedContentRect.size.width   -= self->mMarginX;
	proposedContentRect.size.height  -= self->mMarginY;
	
	proposedContentRect.size.width = NSHeight(proposedContentRect) * mDataViewAspectRatio;
	
	proposedContentRect.size.width   += self->mMarginX;
	proposedContentRect.size.height  += self->mMarginY;
	
	newSize = [sender frameRectForContentRect:proposedContentRect].size;
	
	return newSize;
}

#pragma mark -
#pragma mark DESTRUCTOR
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

- (void) dealloc
{
	[self->window close];
}

@end
