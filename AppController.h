//
//  AppController.h
//  MillsyProxy
//
//  Created by Chris Mills on 31/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppController : NSObject
{
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *statusImage;
    IBOutlet NSMenu *interfacesMenu;
    IBOutlet NSMenu *recentsMenu;
    IBOutlet NSMenuItem *recentsMenuItem;
    IBOutlet NSMenuItem *clearProxy;
    IBOutlet NSMenuItem *setProxy;
    IBOutlet NSWindow *setProxyWindow;
    IBOutlet NSTextField *urlField;
    IBOutlet NSButton *btnOk;
    IBOutlet NSButton *btnCancel;
    IBOutlet NSTextField *errorMsg;
    
    NSMutableArray* interfaces;
}


-(IBAction)helloWorld:(id)sender;
-(IBAction)Close:(id)sender;
-(IBAction)EnableDisable:(id)sender;
-(IBAction)ClearProxy:(id)sender;
-(IBAction)ShowProxyWindow:(id)sender;
-(IBAction)ShowHelpAbout:(id)sender;
-(IBAction)ApplyRecent:(id)sender;

- (NSMutableArray*) GetInterfacesForMenu;
- (void) SetProxiesForInterfaces: (NSString*) url;
- (Boolean) UpdateProxy: (NSString*)interface WithUrl:(NSString*)url Authorisation:(AuthorizationRef)myAuthorizationRef;
- (void) GetAllRecents;
- (void) AddRecent: (NSString*) url;
- (void)AddRecentItem:(NSString*) url;

@end