//
//  NetworkSetupWrapper.h
//  MillsyProxy
//
//  Created by Chris Mills on 14/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkSetupWrapper : NSObject


+(NSArray*) GetInterfaces;
+(Boolean) SetProxy:(NSString*)url forInterface:(NSString*)interface;
+(void) SetProxyInterface:(NSString*)interface State:(NSString*)state;

@end
