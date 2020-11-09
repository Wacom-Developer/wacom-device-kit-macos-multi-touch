# Getting Started

## Test Environment
The MultiTouch sample requires Xcode 10 or higher.

To test the application, a Wacom tablet driver must be installed and a supported Wacom tablet must be attached. All Wacom tablets supported by the Wacom driver are supported by this API. Get the driver that supports your device at: https://www.wacom.com/support/product-support/drivers.

## Install the Wacom tablet driver and verify tablet operation
In order to run a sample application, it is necessary to install a Wacom tablet driver, which installs the necessary framework to support MultiTouch. The driver can be found at: https://www.wacom.com/support/product-support/drivers. 

Once the driver has installed, and you have rebooted your system, check your tablet driver installation by doing the following:

1. Attach a supported Wacom tablet.
1. Either open the Wacom Tablet System Preferences, or the Wacom Desktop Center to determine if your tablet is recognized by the driver.
1. Use a tablet pen to see if you can move the system cursor.
1. If all of the above checks out, proceed to the next section to build the sample application.

## Build/run the sample application
To build the sample application:

1. Open the MultiTouch.xcodeproj file in Xcode 10 or newer.
2. Select MultiTouch in the files list, then select the MultiTouch target.
3. Change the bundle identifier and signing settings as appropriate for your development.
4. Open the MultiTouch.entitlements file.
under com.apple.security.temporary-exception.mach-register.global-name, change the string in Item 0 to be your bundle identifier with .WacomTouch appended.
5. Press Xcode's Build and Run button.
6. Once running, click the initialize button.  You should get a list of connected tablets.
7. Next click the Show All Finger Callbacks button.  A window should open for each tablet.
8. As you touch one of the tablets you should see contact points appear in the window.  When a contact is not confident it's a finger, it will turn grey.


## See Also  

For complete API details, see:  

[Multi-Touch Framework - Basics](https://developer-docs.wacom.com/wacom-device-api/docs/multitouch-framework-basics)  

[Multi-Touch Framework - Reference](https://developer-docs.wacom.com/wacom-device-api/docs/multitouch-framework-reference)  

[Multi-Touch Framework - FAQs](https://developer-docs.wacom.com/wacom-device-api/docs/multitouch-framework-faqs)  

## Where to get help
If you have questions about the sample application or any of the setup process, please visit our Support page at: https://developer.wacom.com/developer-dashboard/support 