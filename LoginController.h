//
//  LoginController.h
//  MillsyProxy
//
//  Created by Chris Mills on 08/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginController : NSObject
{
    IBOutlet NSMenuItem *autoStart;
}

-(IBAction)SetAutoLogin:(id)sender;

-(Boolean) addAppAsLoginItem;
-(Boolean) deleteAppFromLoginItem;
-(Boolean) isInLoginList;

@end
