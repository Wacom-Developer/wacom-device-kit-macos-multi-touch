///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
//    A subclassed version of OHitRectMon which enables the receipt of finger
//	   or blob data into the window.
//
// COPYRIGHT
//    Copyright (c) 2014 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import <WacomMultiTouch/WacomMultiTouch.h>

@interface OTouchableWindow :NSWindow<WacomMTWindowFingerRegistration>
{
	@private
		id mController;
}

-(void) setFingerController:(id)controller_I;
-(id) fingerController;

-(void) FingerDataAvailable:(WacomMTFingerCollection *)packet_I data:(void *)userData_I;

@end
