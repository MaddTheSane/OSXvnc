//
//  RFBBundleProtocol.h
//  OSXvnc
//
//  Created by Jonathan Gillaspie on Fri Aug 22 2003.
//  Copyright (c) 2003 RedstoneSoftware. All rights reserved.
//

#import "rfbserver.h"

// These work on the class but they aren't defined anywhere
@interface NSObject (ClassPerform)

+ performSelector:(SEL) aSelector;

+ performSelector:(SEL) aSelector withObject: (id) anObject;

@end

@protocol RFBBundleProtocol <NSObject>

/*! Print stuff to stderr if you want to add usage information */
+ (void) rfbUsage;

/*! This method is called during startup and should display with NSLog some information about the Bundle 
 * You can use NSProcessInfo to get access to the startup arguments */
+ (void) rfbStartup: (rfbserver *) theServer;

/*! This method is called after all of the core services are started -- immediately before listening for connects */
+ (void) rfbRunning;

/*! This method is called during each check the VNC system does for screen updates, etc. */
+ (void) rfbPoll;

/*! This method is called immediately as each event is received */
+ (void) rfbReceivedClientMessage;

/*! This method is called when we go to shutdown the server */
+ (void) rfbShutdown;

@end

@interface NSProcessInfo (VNCExtension)

- (CGDirectDisplayID) CGMainDisplayID;

@end
