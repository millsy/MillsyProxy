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
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"earth-sm" ofType:@"png"]];
    //statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];
    
    //Sets the images in our NSStatusItem
    [statusItem setImage:statusImage];
    //[statusItem setAlternateImage:statusHighlightImage];
    
    //Tells the NSStatusItem what menu to load
    [statusItem setMenu:statusMenu];
    //Sets the tooptip for our item
    [statusItem setToolTip:@"Millsy Proxy"];
    //Enables highlighting
    [statusItem setHighlightMode:YES];
    
    [setProxyWindow makeFirstResponder:urlField];
   
    interfaces = [[self GetInterfacesForMenu]retain];
    NSEnumerator * enumerator = [interfaces objectEnumerator];
    id element;
    
    while(element = [enumerator nextObject])
    {
        MInterface* thisInterface = element;
        
        NSMenuItem *testItem = [[[NSMenuItem alloc] initWithTitle:[thisInterface Name] action:@selector(EnableDisable:) keyEquivalent:@""] autorelease];
        [testItem setTarget:self];
        [testItem setEnabled:TRUE];
        if([thisInterface IsChecked])
        {
            [testItem setState:NSOnState];
        }else{
            [testItem setState:NSOffState];
        }
        [interfacesMenu addItem:testItem];
    }
}

-(IBAction)ShowHelpAbout:(id)sender
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ConfigProperties" ofType:@"plist"];    
    NSMutableDictionary *templateDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    NSURL *url = [ [ NSURL alloc ] initWithString: [templateDictionary valueForKey:@"Help.URL"]];
    [[NSWorkspace sharedWorkspace] openURL:url];
    
    [url release];
}

-(IBAction)EnableDisable:(id)sender
{
    NSMenuItem* mi = sender;
    NSEnumerator * enumerator = [interfaces objectEnumerator];
    id element;    
    while(element = [enumerator nextObject])
    {
        MInterface* thisInterface = element;
        
        if([thisInterface Name] == [mi title])
        {
            NSMenuItem *menuItem = sender;
            if([menuItem state] == NSOnState)
            {
                [thisInterface Checked:false];
                [menuItem setState:NSOffState]; 
            }else{
                [thisInterface Checked:true];
                [menuItem setState:NSOnState];
            }
            
            break;
        }
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
        CFRelease(services);
        CFRelease(store);
    }
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
    [self SetProxiesForInterfaces:nil];
}

-(IBAction)ShowProxyWindow:(id)sender
{
    [setProxyWindow setLevel:NSPopUpMenuWindowLevel];
    [setProxyWindow makeKeyAndOrderFront:nil]; 
    //[setProxyWindow makeKeyWindow];
}

-(IBAction)SaveNewProxy:(id)sender
{
    [setProxyWindow orderOut:self];
    NSString* url = [[urlField stringValue] retain];
    [self SetProxiesForInterfaces:url];
    [url release];
}

-(IBAction)Close:(id)sender
{
    [setProxyWindow orderOut:self];
}

- (void) SetProxiesForInterfaces: (NSString*) url
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
    
    NSEnumerator * enumerator = [interfaces objectEnumerator];
    id element;
    
    while(element = [enumerator nextObject])
    {
        MInterface* thisInterface = element;
        
        //check if this is checked or not
        NSMenuItem* item = [interfacesMenu itemWithTitle:[thisInterface Name]];
        if([item state]==NSOnState)
        {
            [self UpdateProxy:[thisInterface Source] WithUrl:url Authorisation:myAuthorizationRef];
        }
    }
    
    AuthorizationFree(myAuthorizationRef, kAuthorizationFlagDefaults);
}

- (Boolean) UpdateProxy: (NSString*)interface WithUrl:(NSString*)url Authorisation:(AuthorizationRef)myAuthorizationRef
{
    Boolean result = false;
    
    SCPreferencesRef session = SCPreferencesCreateWithAuthorization(nil, CFSTR("MillsyProxy"), nil, myAuthorizationRef);
    Boolean lock = SCPreferencesLock(session, TRUE);
    if(lock)
    {
        NSString* path = [NSString stringWithFormat:@"/NetworkServices/%@/Proxies", interface];
        
        CFDictionaryRef aProxy = SCPreferencesPathGetValue(session, (CFStringRef)path);
        
        //CFStringRef outKeys[CFDictionaryGetCount(aProxy)];
        //CFStringRef outValues[CFDictionaryGetCount(aProxy)];
        //CFDictionaryGetKeysAndValues(aProxy, (const void**)&outKeys, (const void**)&outValues);
        
        //for(int i = 0; i < CFDictionaryGetCount(aProxy); i++){
        //    NSLog(@"%@ %@\n", outKeys[i], CFDictionaryGetValue(aProxy, outKeys[i]));
        //}
        
        if(aProxy)
        {
            CFMutableDictionaryRef dict = CFDictionaryCreateMutableCopy(NULL, 0, aProxy);
            
            int intValue = 1;
            
            if(url == nil)
            {
                intValue = 0;
            }
            
            CFNumberRef enabled = CFNumberCreate(NULL, kCFNumberIntType, &intValue);
            CFDictionarySetValue(dict, CFSTR("ProxyAutoConfigEnable"), enabled);
            if(intValue == 1){
                CFDictionarySetValue(dict, CFSTR("ProxyAutoConfigURLString"), url);
            }
            SCPreferencesPathSetValue(session, (CFStringRef)path, dict);
            
            Boolean commit = SCPreferencesCommitChanges(session);
            if(commit){
                Boolean apply = SCPreferencesApplyChanges(session);
                if(!apply){
                    CFErrorRef err = SCCopyLastError();
                    NSLog(@"Failed to apply changes %@", err);
                    CFRelease(err);
                }else{
                    result = true;
                }
            }else{
                CFErrorRef err = SCCopyLastError();
                NSLog(@"Failed to commit changes %@", err);
                CFRelease(err);
            }
            
            CFRelease(enabled);
            CFRelease(dict);
        }else{
            NSLog(@"Failed to find path %@", path);
        }
        SCPreferencesUnlock(session);
    }else{
        CFErrorRef err = SCCopyLastError();
        NSLog(@"Failed to get lock %@", err);
        CFRelease(err);
    }
    
    CFRelease(session);
    
    return result;
}

-(IBAction)helloWorld:(id)sender
{
}
@end
