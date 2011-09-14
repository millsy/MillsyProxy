//
//  NetworkSetupWrapper.m
//  MillsyProxy
//
//  Created by Chris Mills on 14/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkSetupWrapper.h"

@implementation NetworkSetupWrapper

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(NSArray*) GetInterfaces
{
    NSTask *task = [NSTask new];
    [task setLaunchPath:@"/usr/sbin/networksetup"];
    [task setArguments:[NSArray arrayWithObjects:@"-listallnetworkservices", nil]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    [task launch];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    
    [task waitUntilExit];
    [task release];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray* lines = [string componentsSeparatedByString: @"\n"];
    NSMutableArray* finalVer = [NSMutableArray arrayWithArray:lines];
    
    if([[finalVer objectAtIndex:0] hasPrefix:@"An asterisk"])
    {
        [finalVer removeObjectAtIndex:0];
    }
    
    [string release];
    
    return finalVer;
}

+(Boolean) SetProxy:(NSString*)url forInterface:(NSString*)interface{
    
    NSTask *task = [NSTask new];
    [task setLaunchPath:@"/usr/sbin/networksetup"];
    [task setArguments:[NSArray arrayWithObjects:@"-setautoproxyurl", interface, url, nil]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    [task launch];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    
    [task waitUntilExit];
    [task release];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [string release];
    
    return true;
}

+(void) SetProxyInterface:(NSString*)interface State:(NSString*)state
{
    NSTask *task = [NSTask new];
    [task setLaunchPath:@"/usr/sbin/networksetup"];
    [task setArguments:[NSArray arrayWithObjects:@"-setautoproxystate", interface, state, nil]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    [task launch];
    
    NSData *data2 = [[pipe fileHandleForReading] readDataToEndOfFile];
    
    [task waitUntilExit];
    [task release];
    
    NSString *string2 = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
    
    [string2 release];
}

@end
