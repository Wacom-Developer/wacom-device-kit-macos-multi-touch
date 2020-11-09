///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
//    A subclassed version of OHitRectMon which enables the receipt of finger
//    or blob data into the window. This is where your methods would go to
//    register your window and get touch data.
//
// COPYRIGHT
//    Copyright (c) 2014 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import "OTouchableWindow.h"
#import "FingerDataController.h"

@implementation OTouchableWindow

-(void) setFingerController:(id)controller_I
{
	mController = controller_I;
}

///////////////////////////////////////////////////////////////////////////////

-(id) fingerController
{
	return mController;
}

///////////////////////////////////////////////////////////////////////////////

-(void) FingerDataAvailable:(WacomMTFingerCollection *)packet_I data:(void *)userData_I
{
	#pragma unused(userData_I)

	NSLog(@"OTouchableWindow::FingerDataAvailable finger data came in");
	
	[(FingerDataController *)mController pushNewFingers:*packet_I];
	return;
}

@end
