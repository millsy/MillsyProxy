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

#include "MInterface.h"
#include "NetworkSetupWrapper.h"

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
    
    //setup growl
    growlHandler = [[[GrowlHandler new]init]autorelease];
        
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
    
    [self GetAllRecents];
}

-(IBAction)ApplyRecent:(id)sender
{
    NSMenuItem* item = sender;
    [self SetProxiesForInterfaces:[item title]];
}

- (void) GetAllRecents
{
    NSUserDefaults *preferences = [[NSUserDefaults standardUserDefaults] retain];
    NSMutableArray* dict = [preferences objectForKey:@"recents"];
    if(dict)
    {
        NSEnumerator * enumerator = [dict objectEnumerator];
        id element;
        
        while(element = [enumerator nextObject])
        {
            NSString* url = element;
            //recentsMenu
            [self AddRecentItem:url];
        }
        
        [clearRecentMI setEnabled:YES];
    }else{
        [recentsMenuItem setEnabled:NO];
    }
    
    [preferences release];
}

-(IBAction)ClearRecent:(id)sender
{
    NSUserDefaults *preferences = [[NSUserDefaults standardUserDefaults] retain];

    [preferences removeObjectForKey:@"recents"];
    
    [preferences synchronize];
    
    [preferences release];
    
    [recentsMenu removeAllItems];
    
    [clearRecentMI setEnabled:NO];
    [recentsMenuItem setEnabled:NO];
}

- (void) AddRecent: (NSString*) url
{
    NSUserDefaults *preferences = [[NSUserDefaults standardUserDefaults] retain];
    NSMutableArray* dict = [preferences objectForKey:@"recents"];
    if(!dict)
    {
        dict = [NSMutableArray array];
    }
    
    [dict addObject:url];
    
    [self AddRecentItem:url];
    
    [clearRecentMI setEnabled:YES];
    
    [preferences setObject:dict forKey:@"recents"];
    
    [preferences synchronize];
    
    [preferences release];
}

-(void)AddRecentItem:(NSString*) url
{
    if(![recentsMenuItem isEnabled])
    {
        [recentsMenuItem setEnabled:YES];
    }
    
    NSMenuItem *testItem = [[[NSMenuItem alloc] initWithTitle:url action:@selector(ApplyRecent:) keyEquivalent:@""] autorelease];
    [testItem setTarget:self];
    [testItem setEnabled:TRUE];    
    [recentsMenu addItem:testItem];
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
    NSMutableArray* names = [NSMutableArray array];
    NSArray* myArray = [NetworkSetupWrapper GetInterfaces];
    for(int i = 0; i < (int)[myArray count]; i++){
        if([myArray objectAtIndex:i] != nil && [[myArray objectAtIndex:i]length] > 0 ){
            MInterface *newInterface = [MInterface alloc];
            [newInterface Setup:[myArray objectAtIndex:i]];
            [names addObject:newInterface];
        }
    }

    return names;
}

- (void) dealloc {
    //Releases the 2 images we loaded into memory
    [statusImage release];
    [interfaces release];
    [growlHandler release];
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
    NSString* url = [[urlField stringValue] retain];
    
    //validate proxy url here
    NSURL* validURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if(validURL && [validURL scheme] && [validURL host] && ([[validURL path]length]> 0) && ([[validURL pathExtension]length]> 0))
    { 
        //url is valid
        //[setProxyWindow orderOut:self];
        [self Close:nil];
        [self SetProxiesForInterfaces:url];
        [self AddRecent:url];
    }else
    {
        [errorMsg setStringValue:@"Invalid URL (http(s)://server/file.pac)"];
        [growlHandler ProxySettingsFailed:@" invalid URL"];
    }
    
    [url release];
}

-(IBAction)Close:(id)sender
{
    [urlField setStringValue:@""];
    [errorMsg setStringValue:@""];
    [setProxyWindow orderOut:self];
}

- (void) SetProxiesForInterfaces: (NSString*) url
{    
    NSEnumerator * enumerator = [interfaces objectEnumerator];
    id element;
    
    while(element = [enumerator nextObject])
    {
        MInterface* thisInterface = element;
        
        //check if this is checked or not
        NSMenuItem* item = [interfacesMenu itemWithTitle:[thisInterface Name]];
        if([item state]==NSOnState)
        {
            if(url)
            {
                [NetworkSetupWrapper SetProxy:url forInterface:[thisInterface Name]];
                [NetworkSetupWrapper SetProxyInterface: [thisInterface Name] State:@"on"];
            }else{
                [NetworkSetupWrapper SetProxyInterface: [thisInterface Name] State:@"off"];
            }
        }
    }
}

@end
