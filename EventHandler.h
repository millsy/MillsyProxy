//
//  EventHandler.h
//  MillsyProxy
//
//  Created by Chris Mills on 07/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface EventHandler : NSApplication


- (void) sendEvent:(NSEvent *)event;

@end
