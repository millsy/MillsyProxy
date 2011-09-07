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
    IBOutlet NSMenuItem *clearProxy;
    IBOutlet NSMenuItem *setProxy;
    IBOutlet NSWindow *setProxyWindow;
    
    NSMutableArray* interfaces;
}


-(IBAction)helloWorld:(id)sender;

-(IBAction)EnableDisable:(id)sender;
-(IBAction)ClearProxy:(id)sender;
-(IBAction)SetProxy:(id)sender;

- (NSMutableArray*) GetInterfacesForMenu;

@end