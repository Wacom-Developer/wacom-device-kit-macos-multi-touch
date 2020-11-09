///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
// 	A view which displays finger data from the Wacom MultiTouch API.
//
// COPYRIGHT
//    Copyright (c) 2011 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import "FingerDataView.h"

//////////////////////////////////////////////////////////////////////////////

// Returns a copy of the finger collection.
//
// Since finger collections contain allocated pointers, we need a
//		special copy routine to ensure the memory stays valid. Structures
//		returned from the Wacom Touch API are only guaranteed to stay
//		valid for the lifetime of the callback.

static WacomMTFingerCollection *CopyFingerCollection(WacomMTFingerCollection *original_I)
{
	WacomMTFingerCollection  *copied  = new WacomMTFingerCollection;
	
	copied->Version      = original_I->Version;
	copied->DeviceID     = original_I->DeviceID;
	copied->FingerCount  = original_I->FingerCount;
	copied->Fingers      = new WacomMTFinger[original_I->FingerCount];
	
	// Copy all the finger structs
	memcpy(copied->Fingers, original_I->Fingers, sizeof(WacomMTFinger) * original_I->FingerCount);

	return copied;
}

//////////////////////////////////////////////////////////////////////////////

// Frees the memory pointed to by fingerCollection.

static void FreeFingerCollection(WacomMTFingerCollection *fingerCollection_I)
{
	if (fingerCollection_I)
	{
		// free allocated memory within the struct
		delete fingerCollection_I->Fingers;

		// free the struct itself.
		delete fingerCollection_I;
	}
}

//////////////////////////////////////////////////////////////////////////////

@implementation FingerDataView

#pragma mark -
#pragma mark INITIALIZATION
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(NSRect)frame_I
{
	self = [super initWithFrame:frame_I];
	if (self)
	{
		self->mFingerData           = [[NSMutableArray alloc] init];
		self->mLogicalSize          = NSZeroSize;
		self->mMaxPacketsToDisplay  = 1;
		mDisplayMode = eDM_Panel;
	}
	return self;
}

//////////////////////////////////////////////////////////////////////////////

-(void) setDisplayMode:(eDisplayMode)mode_I
{
	mDisplayMode = mode_I;
}

#pragma mark -
#pragma mark ACCESSORS
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

// Adds a new set of finger data to the display.

- (void) pushNewFingers:(WacomMTFingerCollection)fingerCollection_I
{
	// You should not spend too long responding to touch messages. The touch API
	// will automatically and silently purge hung applications, requiring a
	// re-registration.
	//	usleep(0.02 * 1000000);

	// Erase all previous fingers?
	if(self->mClearOnNextDown)
	{
		[self popAllFingers];
		self->mClearOnNextDown = NO;
	}

	// Since we store the finger data locally for the sake of redrawing it, we
	// must make a copy of the data. The Wacom MultiTouch API only guarantees the
	// lifetime of the structs it passes to callbacks for the lifetime of the
	// function call itself.

	WacomMTFingerCollection *localCollectionCopy = CopyFingerCollection(&fingerCollection_I);
	NSValue                 *collectionPointer   = [NSValue valueWithPointer:localCollectionCopy];

	// Push latest data onto the packet stack
	[self->mFingerData insertObject:collectionPointer atIndex:0];

	// Remove old packets
	if([self->mFingerData count] > self->mMaxPacketsToDisplay)
	{
		NSValue *bumpedValue = [self->mFingerData lastObject];
		FreeFingerCollection( (WacomMTFingerCollection*)[bumpedValue pointerValue] );
		[self->mFingerData removeLastObject];
	}

	// Count all down fingers
	size_t   fingerCount    = 0;
	for(size_t fingerCounter = 0; fingerCounter < fingerCollection_I.FingerCount; fingerCounter++)
	{
		WacomMTFinger *finger = &fingerCollection_I.Fingers[fingerCounter];
		if(finger->TouchState == WMTFingerStateDown || finger->TouchState == WMTFingerStateHold)
		{
			fingerCount++;
		}
	}
	if(fingerCount == 0)
	{
		// All fingers lifted; make sure the display is wiped on next touch
		mClearOnNextDown = YES;
	}

	[self setNeedsDisplay:YES];
}

//////////////////////////////////////////////////////////////////////////////

// Sets a bounds rect we maintain no matter what the size. By
//	setting the view bounds to the device coordinate space, we can
//	draw directly in device logical coordinates.

- (void) setBoundsFromLogicalSize:(NSSize)deviceSize_I
{
	if(mDisplayMode == eDM_Panel)
	{
		[self setBoundsSize:deviceSize_I];
		self->mLogicalSize = deviceSize_I;
	}
}

//////////////////////////////////////////////////////////////////////////////

// As the view is live resized, we force it to maintain the same
//	bounds rectangle (which has been set equal to device logical
//	coordinates).

- (void)setFrame:(NSRect)frameRect_I
{
	[super setFrame:frameRect_I];

	if(mDisplayMode == eDM_Panel)
	{
		if(NSEqualSizes(self->mLogicalSize, NSZeroSize) == NO)
		{
			[self setBoundsSize:mLogicalSize];
		}
	}
}

#pragma mark -
#pragma mark DRAWING
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

// Purpose:		Plot all the finger coordinates.

- (void)drawRect:(NSRect)dirtyRect_I
{
	#pragma unused(dirtyRect_I)
	
	[[NSColor blackColor] set];
	NSRectFill([self bounds]);

	for(NSUInteger packetCounter = 0; packetCounter < [self->mFingerData count]; packetCounter++)
	{
		WacomMTFingerCollection *collection    = (WacomMTFingerCollection*)[[self->mFingerData objectAtIndex:packetCounter] pointerValue];

		for (size_t fingerCounter = 0; fingerCounter < collection->FingerCount; fingerCounter++)
		{
			// Draw the finger ONLY if it is down
			WacomMTFinger *finger = &collection->Fingers[fingerCounter];
			if(finger->TouchState == WMTFingerStateDown || finger->TouchState == WMTFingerStateHold)
			{
				NSBezierPath   *pointPath  = nil;
				NSRect         pointRect   = NSZeroRect;
				if(mDisplayMode == eDM_Panel)
				{
					pointRect.origin  = NSMakePoint(finger->X , finger->Y);
				}
				else
				{
					//The coordinate systems are different in the window and the tablet. The tablet
					//coordinate system starts at the bottom left corner. The mac coordinate system
					//starts at the top right, therefore we have to convert between the two spaces using
					//the screen height and the frame height.
					pointRect.origin  = NSMakePoint(finger->X - self.window.frame.origin.x, finger->Y - (self.window.screen.frame.size.height - self.window.frame.size.height)+ self.window.frame.origin.y);
				}
				
				pointRect.size    = NSMakeSize(finger->Width * 2, finger->Height * 2); // expand to improve visibility

				pointRect = NSOffsetRect(pointRect, -NSWidth(pointRect)/2, -NSHeight(pointRect)/2);
				pointPath = [NSBezierPath bezierPathWithOvalInRect:pointRect];

				if (finger->Confidence)
				{
					[[self colorForFinger:fingerCounter] set];
				}
				else
				{
					[[NSColor darkGrayColor] set];
				}
				
				[pointPath fill];
			}
		}
	}
}

//////////////////////////////////////////////////////////////////////////////

// The tablet coordinate system has (0,0) in the upper-left. Cocoa's
//	coordinate system has the origin in the lower-left by default,
//	but this method allows us to use the tablet's system for drawing.

- (BOOL) isFlipped
{
	return YES;
}

//////////////////////////////////////////////////////////////////////////////

// Hard-codes a table of colors to distinguish fingers while
//	drawing.

- (NSColor *) colorForFinger:(size_t)fingerIndex_I
{
	NSColor *color = nil;

	switch(fingerIndex_I)
	{
		case 0:	color = [NSColor redColor];		break;
		case 1:	color = [NSColor greenColor];		break;
		case 2:	color = [NSColor blueColor];		break;
		case 3:	color = [NSColor cyanColor];		break;
		case 4:	color = [NSColor magentaColor];	break;
		case 5:	color = [NSColor yellowColor];	break;
		case 6:	color = [NSColor grayColor];		break;
		case 7:	color = [NSColor orangeColor];	break;
		case 8:	color = [NSColor purpleColor];	break;
		case 9:	color = [NSColor brownColor];		break;

		default: color = [NSColor whiteColor];		break;
	}
	return color;
}

#pragma mark -
#pragma mark UTILITIES
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

// Deletes all stored finger packets.

- (void) popAllFingers
{
	// Delete all the local copies we've stored
	for (NSUInteger counter = 0; counter < [self->mFingerData count]; counter++)
	{
		NSValue *value = [self->mFingerData objectAtIndex:counter];
		FreeFingerCollection( (WacomMTFingerCollection*)[value pointerValue] );
	}

	[self->mFingerData removeAllObjects];
}

#pragma mark -
#pragma mark DESTRUCTOR
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

- (void) dealloc
{
	[self popAllFingers];
}
@end


