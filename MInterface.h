//
//  MInterface.h
//  MillsyProxy
//
//  Created by Chris Mills on 07/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MInterface : NSObject
{
    NSString* name;
    NSString* source;
    NSString* path;
    Boolean checked;
}

- (NSString*) Name;

- (NSString*) Source;

- (NSString*) Path;

- (Boolean) IsChecked;

- (void) Setup: (NSString*)InterfaceName Path:(NSString*)InterfacePath;

- (void) Checked:(Boolean)status;

@end
