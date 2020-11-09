///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
//    Application controller for Wacom MultiTouch API sample application.
//
//	   This sample application connects to the Wacom MultiTouch API library and
//	   registers to receive touch events.
//
// COPYRIGHT
//    Copyright (c) 2011 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import "AppDelegate.h"
#import "FingerDataController.h"
#import <WacomMultiTouch/WacomMultiTouch.h>

// prototypes
void	MyAttachCallback(WacomMTCapability deviceInfo_I, void *userInfo_I);
void	MyDetachCallback(int deviceID_I, void *userInfo_I);
int	MyFingerCallback(WacomMTFingerCollection *fingerPacket_I, void *userData_I);

@implementation AppDelegate

#pragma mark - Initialization -

//////////////////////////////////////////////////////////////////////////////

// Initialize this controller object.

- (id) init
{
	self = [super init];
	
	mCapabilitiesDataSource  = [[NSMutableArray alloc] init];
	mFingerDataViewers       = [[NSMutableDictionary alloc] init];
	mDisplayMode             = eDM_Panel;
	return self;
}



#pragma mark -
#pragma mark ACTIONS
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

// Register this application with the Wacom touch API.

- (IBAction) initializeTouchAPI:(id)sender_I
{
	#pragma unused(sender_I)
	
	// The WacomMultiTouch framework is weak-linked. That means the application 
	// can load if the framework is not present. However, we must take care not 
	// to call framework functions if the framework wasn't loaded. 
	//
	// You can set WacomMultiTouch.framework to be weak-linked in your own 
	// project by opening the Info window for your target, going to the General 
	// tab. In the Linked Libraries list, change the Type of 
	// WacomMultiTouch.framework to "Weak".

	[initButton setEnabled: NO];
	unsigned int counter = 0;
	bool initialized = false;
	while (initialized == false && counter < 4)
	{
	if (WacomMTInitialize != NULL)
	{
		WacomMTError err = WacomMTInitialize(WACOM_MULTI_TOUCH_API_VERSION);

		if (err == WMTErrorSuccess)
		{
			mIsTouchAPIConnected = YES;
			
			[self displayAttachedDevices];
			[self setConstraints];
			
			// Listen for device connect/disconnect.
			// Note that the attach callback will be called for each connected device 
			// immediately after the callback is registered. 
			WacomMTRegisterAttachCallback(MyAttachCallback, (__bridge void *)self);
			WacomMTRegisterDetachCallback(MyDetachCallback, (__bridge void *)self);
		}
		else
		{
			[initButton setEnabled:YES];
		}
	}
		counter++;
	}
//	else
//	{
//		// WacomMultiTouch.framework is not installed.
//		NSBeep();
//		[initButton setEnabled:YES];
//	}
}

//////////////////////////////////////////////////////////////////////////////

// Create a callback for finger data. This will receive data from
//	all connected touch tablets. when a touch is made in the window

- (IBAction) registerWindowCallback:(id)sender_I
{
	#pragma unused(sender_I)

	int   deviceIDs[30]  = {};
	int   deviceCount    = 0;

	// Add a viewer for each device's data
	mDisplayMode = eDM_Window;
	deviceCount = WacomMTGetAttachedDeviceIDs(deviceIDs, sizeof(deviceIDs));
	if (deviceCount > 30)
	{
		// With a number as big as 30, this will never actually happen.
		NSLog(@"More tablets connected than would fit in the supplied buffer. Will need to reallocate buffer!");
	}
	else
	{
		for (int counter = 0; counter < deviceCount; counter++)
		{
			[self addFingerDataControllerForDeviceID:deviceIDs[counter]];
			FingerDataController * controller = [self->mFingerDataViewers objectForKey:[NSNumber numberWithInt:deviceIDs[counter]]];

			WacomMTRegisterFingerReadID(deviceIDs[counter], WMTProcessingModeNone, [controller window], 1);
		}
	}
	mIsWindowCallbackRegistered = YES;
	[self setConstraints];
}

//////////////////////////////////////////////////////////////////////////////

// Create a callback for finger data. This will receive data from
//	all connected touch tablets.

- (IBAction) registerFingerCallback:(id)sender_I
{
	#pragma unused(sender_I)

	int   deviceIDs[30]  = {};
	int   deviceCount    = 0;

	// Add a viewer for each device's data
	deviceCount = WacomMTGetAttachedDeviceIDs(deviceIDs, sizeof(deviceIDs));
	if (deviceCount > 30)
	{
		// With a number as big as 30, this will never actually happen.
		NSLog(@"More tablets connected than would fit in the supplied buffer. Will need to reallocate buffer!");
	}
	else
	{
		for (int counter = 0; counter < deviceCount; counter++)
		{
			[self addFingerDataControllerForDeviceID:deviceIDs[counter]];
			WacomMTRegisterFingerReadCallback(deviceIDs[counter], NULL, WMTProcessingModeNone, MyFingerCallback, (__bridge void *) self);
		}
	}

	self->mIsFingerCallbackRegistered = YES;
	[self setConstraints];
}

//////////////////////////////////////////////////////////////////////////////

// Un-register the Wacom API. All registered callbacks will go dead.

- (IBAction) quitTouchAPI:(id)sender_I
{
	#pragma unused(sender_I)

	if(WacomMTQuit != NULL) // check API framework availability
	{
		WacomMTQuit();
		
		mIsTouchAPIConnected			= NO;
		mIsFingerCallbackRegistered	= NO;
		mIsWindowCallbackRegistered	= NO;

		[self displayAttachedDevices];
		[mFingerDataViewers removeAllObjects];
		[self setConstraints];
	}
}

#pragma mark -
#pragma mark DELEGATES
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

// The application is loaded, complete with UI.

- (void) applicationDidFinishLaunching:(NSNotification *)notification_I
{
	#pragma unused(notification_I)

	[self setConstraints];
}

//////////////////////////////////////////////////////////////////////////////

// Application is quitting; clean up API connection. This avoids
//	forcing the driver to manually discard our connection.

- (void)applicationWillTerminate:(NSNotification *)notification_I
{
	#pragma unused(notification_I)

	if (self->mIsWindowCallbackRegistered)
	{
		int   deviceIDs[30]  = {};
		int   deviceCount    = 0;

		deviceCount = WacomMTGetAttachedDeviceIDs(deviceIDs, sizeof(deviceIDs));
		for (int counter = 0; counter < deviceCount; counter++)
		{
			FingerDataController * controller = [self->mFingerDataViewers objectForKey:[NSNumber numberWithInt:deviceIDs[counter]]];
			WacomMTUnRegisterFingerReadID([controller window]);
		}
		self->mIsWindowCallbackRegistered = NO;
	}
	[self quitTouchAPI:NSApp];
}

#pragma mark -
#pragma mark CALLBACKS
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

// Called by the touch API callback

- (void) deviceDidAttachWithCapabilities:(WacomMTCapability)deviceInfo_I
{
	[self displayAttachedDevices];
	
	if (mIsFingerCallbackRegistered)
	{
		[self addFingerDataControllerForDeviceID:deviceInfo_I.DeviceID];
		WacomMTRegisterFingerReadCallback(deviceInfo_I.DeviceID, NULL, WMTProcessingModeNone, MyFingerCallback, (__bridge void*)self);
	}
}

//////////////////////////////////////////////////////////////////////////////

// Called by the touch API callback.

- (void) deviceDidDetach:(int)deviceID_I
{
	[self displayAttachedDevices];
	
	[mFingerDataViewers removeObjectForKey:[NSNumber numberWithInt:deviceID_I]];
}

//////////////////////////////////////////////////////////////////////////////

// Finger data has arrived! Route to the correct viewer.

- (void) didReceiveFingerData:(WacomMTFingerCollection)fingerPacket_I
{
	int                  deviceID = fingerPacket_I.DeviceID;
	FingerDataController *viewer  = [self->mFingerDataViewers objectForKey:[NSNumber numberWithInt:deviceID]];

	[viewer pushNewFingers:fingerPacket_I];
}

#pragma mark -
#pragma mark TABLE DATA SOURCE
#pragma mark to display the tablet capabilities table
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

// Return the number of objects in the capabilities table (the
//	number of connected tablets)

- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView_I
{
	#pragma unused(aTableView_I)

	return [mCapabilitiesDataSource count];
}

//////////////////////////////////////////////////////////////////////////////

// Provide the data for the tablet capabilities table

- (id)            tableView:(NSTableView *)tableView_I
  objectValueForTableColumn:(NSTableColumn *)tableColumn_I
								row:(NSInteger)rowIndex_I
{
	#pragma unused(tableView_I)

	NSString       *identifier    = [tableColumn_I identifier];
	NSDictionary   *deviceRecord  = nil;
	id             objectValue    = nil;
	
	deviceRecord   = [mCapabilitiesDataSource objectAtIndex:rowIndex_I];
	objectValue    = [deviceRecord objectForKey:identifier];
	
	return objectValue;
}

#pragma mark -
#pragma mark UTILITIES
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

// Creates a new controller object to display finger data for the
//	given device ID.

- (void) addFingerDataControllerForDeviceID:(int)deviceID_I
{
	FingerDataController *viewer     = [[FingerDataController alloc] initWithDeviceID:deviceID_I displayMode:mDisplayMode];
	NSPoint              windowPoint = NSZeroPoint;
	
	// cascade the windows
	if ([mFingerDataViewers count] == 0)
	{
		NSRect screenRect = [[NSScreen mainScreen] visibleFrame];
		windowPoint = NSMakePoint(NSMinX(screenRect) + 20, NSMaxY(screenRect) + 20);
	}
	else
	{
		NSRect windowFrame = [[[NSApp windows] lastObject] frame];
		windowPoint = NSMakePoint(NSMinX(windowFrame), NSMaxY(windowFrame));
	}

	[mFingerDataViewers setObject:viewer forKey:[NSNumber numberWithInt:deviceID_I]];
	[[viewer window] cascadeTopLeftFromPoint:windowPoint];
	[viewer showWindow];
}

//////////////////////////////////////////////////////////////////////////////

// Gets a list of connected devices and displays them in the device
//	table.

- (void) displayAttachedDevices
{
	int   deviceIDs[30]  = {};
	int   deviceCount    = 0;
	
	// Ask the Wacom API for all connected touch API-capable devices.
	// Pass a comfortably large buffer so you don't have to call this method 
	// twice. 
	deviceCount = WacomMTGetAttachedDeviceIDs(deviceIDs, sizeof(deviceIDs));
	
	if (deviceCount > 30)
	{
		// with a number as big as 30, this will never actually happen
		NSLog(@"More tablets connected than would fit in the supplied buffer. Will need to reallocate buffer!");
	}
	else
	{
		// Display a list of devices in the table on the application's main window.
	
		[mCapabilitiesDataSource removeAllObjects];
		
		// Repopulate with current devices
		for (int counter = 0; counter < deviceCount; counter++)
		{
			int                  deviceID       = deviceIDs[counter];
			WacomMTCapability    capabilities   = {};
			NSMutableDictionary  *deviceRecord  = [[NSMutableDictionary alloc] init];

			WacomMTGetDeviceCapabilities(deviceID, &capabilities);
			
			[deviceRecord setObject:[NSNumber numberWithInt:deviceID] forKey:@"deviceID"];
			[deviceRecord setObject:[NSNumber numberWithInt:capabilities.FingerMax] forKey:@"fingerCount"];
			[deviceRecord setObject:[NSString stringWithFormat:@"%d x %d", capabilities.ReportedSizeX, capabilities.ReportedSizeY] forKey:@"scanSize"];
			
			switch(capabilities.Type)
			{
				case WMTDeviceTypeIntegrated:
				{
					[deviceRecord setObject:@"Integrated" forKey:@"type"];
					break;
				}
				
				case WMTDeviceTypeOpaque:
				{
					[deviceRecord setObject:@"Opaque" forKey:@"type"];
					break;
				}
				
				default:
				{
					NSLog(@"We should not get here");
					break;
				}
			}
			
			[mCapabilitiesDataSource addObject:deviceRecord];
		}
	}
	
	[capabilitiesTable reloadData];
}

//////////////////////////////////////////////////////////////////////////////

// Update the enabled/disabled state of UI widgets.

- (void) setConstraints
{
	[initButton						setEnabled:(mIsTouchAPIConnected == NO)];
	[quitButton						setEnabled:(mIsTouchAPIConnected == YES)];
	[fingerCallbackButton		setEnabled:(mIsTouchAPIConnected == YES && mIsFingerCallbackRegistered == NO)];
	[RegisterWindowCallBacks	setEnabled:(mIsTouchAPIConnected == YES && mIsWindowCallbackRegistered == NO)];
}

@end

#pragma mark -
#pragma mark WACOM TOUCH API C-FUNCTION CALLBACKS
#pragma mark -

//////////////////////////////////////////////////////////////////////////////

// A new device was connected.

void MyAttachCallback(WacomMTCapability deviceInfo_I, void *userInfo_I)
{
	AppDelegate *controller = (__bridge AppDelegate *)userInfo_I;
	[controller deviceDidAttachWithCapabilities:deviceInfo_I];
}

//////////////////////////////////////////////////////////////////////////////

// A device was unplugged.

void MyDetachCallback(int deviceID_I, void *userInfo_I)
{
	AppDelegate *controller = (__bridge AppDelegate *)userInfo_I;
	[controller deviceDidDetach:deviceID_I];
}

//////////////////////////////////////////////////////////////////////////////

// Purpose:		Fingers are moving on one of the connected devices.

int MyFingerCallback(WacomMTFingerCollection *fingerPacket_I, void *userInfo_I)
{
	AppDelegate *controller = (__bridge AppDelegate *)userInfo_I;
	[controller didReceiveFingerData:*fingerPacket_I];
	return 0;
}
