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
    Boolean checked;
}

- (NSString*) Name;

- (Boolean) IsChecked;

- (void) Setup: (NSString*)InterfaceName;

- (void) Checked:(Boolean)status;

@end
