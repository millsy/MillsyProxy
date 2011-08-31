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
}


-(IBAction)helloWorld:(id)sender;

@end