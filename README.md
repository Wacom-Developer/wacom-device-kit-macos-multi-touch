# Readme

## Introduction
This is a sandboxed macOS application, with hardened runtime enabled, that shows tablet touch points via the Multitouch framework.

This demo shows how an application can use the MutilTouch framework to:

* Find all touch-enabled tablets connected to the computer
* Capture touch points from a tablet
* Distinguish confident from non-confident touch points  

To run this application, a Wacom tablet driver must be installed and a supported Wacom tablet must be attached. All Wacom tablets supported by the Wacom driver are supported by this API. Get the driver that supports your device at: https://www.wacom.com/support/product-support/drivers.


## Application Details
The application uses an installed framework, WacomMultiTouch.framework, to communicate with the tablet driver. If the driver is not installed, is not communicating, or there is no supported Wacom tablet attached, then the application won't display any tablets when initialized.

You can download the Multi-Touch sample code and view the inline comments to find out detailed information about the sample code itself.


## See Also

For complete API details, see:  

[Multi-Touch Framework - Basics](https://developer-docs.wacom.com/intuos-cintiq-business-tablets/docs/multitouch-framework-basics)  

[Multi-Touch Framework - Reference](https://developer-docs.wacom.com/intuos-cintiq-business-tablets/docs/multitouch-framework-reference)  

[Multi-Touch Framework - FAQs](https://developer-docs.wacom.com/intuos-cintiq-business-tablets/docs/multitouch-framework-faqs)  

## Where To Get Help
If you have questions about this demo or please visit our support page: https://developer.wacom.com/developer-dashboard/support. 

## License
This sample code is licensed under the MIT License: https://choosealicense.com/licenses/mit/