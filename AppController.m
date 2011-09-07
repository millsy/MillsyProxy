//
//  AppController.m
//  MillsyProxy
//
//  Created by Chris Mills on 31/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

#include <CoreServices/CoreServices.h>
#include <SystemConfiguration/SystemConfiguration.h>

#include <SystemConfiguration/SCDynamicStore.h>
#include <Security/Security.h>
#include "MInterface.h"

@implementation AppController

- (void) awakeFromNib{
    
    //Create the NSStatusBar and set its length
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    
    //Used to detect where our files are
    NSBundle *bundle = [NSBundle mainBundle];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"proxy" ofType:@"png"]];
    //statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];
    
    //Sets the images in our NSStatusItem
    [statusItem setImage:statusImage];
    //[statusItem setAlternateImage:statusHighlightImage];
    
    //Tells the NSStatusItem what menu to load
    [statusItem setMenu:statusMenu];
    //Sets the tooptip for our item
    [statusItem setToolTip:@"Millsy Proxy"];
    //Enables highlighting
    [statusItem setHighlightMode:NO];
    
   
    interfaces = [self GetInterfacesForMenu];
    NSEnumerator * enumerator = [interfaces objectEnumerator];
    id element;
    
    while(element = [enumerator nextObject])
    {
        MInterface* thisInterface = element;
        
        NSMenuItem *testItem = [[[NSMenuItem alloc] initWithTitle:[thisInterface Name] action:@selector(EnableDisable:) keyEquivalent:@""] autorelease];
        [testItem setTarget:self];
        [testItem setEnabled:TRUE];
        [testItem setState:NSOffState];
        
        [interfacesMenu addItem:testItem];
    }
}

-(IBAction)EnableDisable:(id)sender
{
    NSMenuItem *menuItem = sender;
    if([menuItem state] == NSOnState)
    {
        [menuItem setState:NSOffState]; 
    }else{
        [menuItem setState:NSOnState];
    }
}

- (NSMutableArray*) GetInterfacesForMenu
{
    NSMutableArray *names = [NSMutableArray array];
    
    SCDynamicStoreRef store = SCDynamicStoreCreate(nil,CFSTR("helloWorld"), nil, nil);
    if(store){
        CFArrayRef services = SCDynamicStoreCopyKeyList(store, CFSTR("^Setup:/Network/Service/[A-F0-9-]*$"));
        //check we have the proxy info
        
        //NSArray *names = [NSArray arrayWithObjects:@"", nil];
        
        for(int i = 0; i < CFArrayGetCount(services); i++){
            CFPropertyListRef props = SCDynamicStoreCopyValue(store, CFArrayGetValueAtIndex(services, i));
            NSLog(@"%@", CFDictionaryGetValue(props, kSCPropUserDefinedName));
            
            //serviceNames[i] = ;
            CFStringRef name = CFStringCreateCopy(NULL, CFDictionaryGetValue(props, kSCPropUserDefinedName));
            //[names addObject:(NSString *)name];
            
            MInterface *newInterface = [MInterface alloc];
            [newInterface Setup:(NSString*)name Path:CFArrayGetValueAtIndex(services, i)];
            [names addObject:newInterface];
            
            CFRelease(name);
            CFRelease(props);
        }
    }
    CFRelease(store);
    
    return names;
}

- (void) dealloc {
    //Releases the 2 images we loaded into memory
    [statusImage release];
    //[statusHighlightImage release];
    [super dealloc];
}

-(IBAction)ClearProxy:(id)sender
{
    
}

-(IBAction)SetProxy:(id)sender
{
    [setProxyWindow makeKeyAndOrderFront:self];
}

- (void) SetProxiesForInterfaces: (NSString*) url
{
    NSEnumerator * enumerator = [interfaces objectEnumerator];
    id element;
    
    while(element = [enumerator nextObject])
    {
        MInterface* thisInterface = element;
        
        //check if this is checked or not
        
        
    }
}

-(IBAction)helloWorld:(id)sender{
    /*

        
        CFPropertyListRef props2 = SCDynamicStoreCopyValue(store, CFSTR("State:/Network/Service"));
        if(props2)
        {
            
            
            //get the auto config info
            //CFStringRef autoConfig = (CFStringRef)CFDictionaryGetValue(props2, kSCPropNetProxiesProxyAutoConfigEnable);
            //CFStringRef autoConfigURL = (CFStringRef)CFDictionaryGetValue(props2, kSCPropNetProxiesProxyAutoConfigURLString);
            
            if(true)//autoConfig && autoConfigURL)
            {
                //auto config is set
                CFArrayRef interfaces = SCNetworkInterfaceCopyAll();
                CFIndex size = CFArrayGetCount(interfaces);
                
                for(int i = 0; i < size; i++)
                    {
                    SCNetworkInterfaceRef interface = CFArrayGetValueAtIndex(interfaces, i);
                    CFDictionaryRef config = SCNetworkInterfaceGetConfiguration(interface);
                    if(config){
                        CFStringRef outKeys[CFDictionaryGetCount(config)];
                        CFStringRef outValues[CFDictionaryGetCount(config)];
                        CFDictionaryGetKeysAndValues(config, (const void**)&outKeys, (const void**)&outValues);
                        
                        NSLog(@"%@", SCNetworkInterfaceGetLocalizedDisplayName(interface));
                        
                        for(int i = 0; i < CFDictionaryGetCount(config); i++){
                            NSLog(@"%@ %@\n", outKeys[i], CFDictionaryGetValue(config, outKeys[i]));
                        }
                    
                    }
                }
                
                CFRelease(interfaces);
            }
            else
            {
                
                AuthorizationRef myAuthorizationRef;
                
                // Get the authorization
                OSStatus err = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &myAuthorizationRef);
                if (err != errAuthorizationSuccess) NSLog(@"Auth failed");
                
                AuthorizationItem myItems = {kAuthorizationRightExecute, 0, NULL, 0};
                AuthorizationRights myRights = {1, &myItems};
                AuthorizationFlags myFlags = kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
                
                err = AuthorizationCopyRights(myAuthorizationRef, &myRights, NULL, myFlags, NULL);
                if (err != errAuthorizationSuccess) {
                    NSLog(@"Failed auth");
                    return;
                }
                
                SCPreferencesRef session = SCPreferencesCreateWithAuthorization(nil, CFSTR("ProgName"), nil, myAuthorizationRef);
                Boolean lock = SCPreferencesLock(session, TRUE);
                if(lock)
                {
                    CFStringRef path = CFStringCreateWithCString(NULL, "/NetworkServices/75F97D0E-946C-48AD-ABF2-900BD7565897/Proxies", kCFStringEncodingASCII);

                    CFDictionaryRef aProxy = SCPreferencesPathGetValue(session, path);
                    
                    CFStringRef outKeys[CFDictionaryGetCount(aProxy)];
                    CFStringRef outValues[CFDictionaryGetCount(aProxy)];
                    CFDictionaryGetKeysAndValues(aProxy, (const void**)&outKeys, (const void**)&outValues);
                    
                    for(int i = 0; i < CFDictionaryGetCount(aProxy); i++){
                        NSLog(@"%@ %@\n", outKeys[i], CFDictionaryGetValue(aProxy, outKeys[i]));
                    }
                    
                    CFMutableDictionaryRef dict = CFDictionaryCreateMutableCopy(NULL, 0, aProxy);
                    
                    int intValue = 1;
                    CFNumberRef enabled = CFNumberCreate(NULL, kCFNumberIntType, &intValue);
                    CFDictionarySetValue(dict, CFSTR("ProxyAutoConfigEnable"), enabled);
                    CFDictionarySetValue(dict, CFSTR("ProxyAutoConfigURLString"), CFSTR("http://anotherurl.pac"));
                    
                    SCPreferencesPathSetValue(session, path, dict);
                    
                    Boolean commit = SCPreferencesCommitChanges(session);
                    if(commit){
                        Boolean apply = SCPreferencesApplyChanges(session);
                        if(!apply){
                            NSLog(@"Failed to apply changes %@", SCCopyLastError());
                        }
                    }else{
                        NSLog(@"Failed to commit changes %@", SCCopyLastError());
                    }
                    
                    SCPreferencesUnlock(session);
                    
                    CFRelease(enabled);
                    CFRelease(dict);
                    CFRelease(path);
                }else{
                    NSLog(@"Failed to get lock %@", SCCopyLastError());
                }
                CFRelease(session);
                
                AuthorizationFree(myAuthorizationRef, kAuthorizationFlagDefaults);
            }            
        }
        CFRelease(props2);
    }
    CFRelease(store);
     */
}
@end
