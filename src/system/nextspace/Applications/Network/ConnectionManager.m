/* All Rights reserved */

#import <AppKit/AppKit.h>
#import <DBusKit/DBusKit.h>
#import "NetworkManager/NetworkManager.h"
#import "AppController.h"
#import "ConnectionManager.h"

@implementation ConnectionManager

- (void)showAddConnectionPanel
{
  if (window == nil) {
    if ([NSBundle loadNibNamed:@"AddConnection" owner:self] == NO) {
      NSLog(@"Error loading AddConnection model.");
      return;
    }
  }
  [window center];
  [window makeFirstResponder:connectionName];
  [window makeKeyAndOrderFront:self];
  [NSApp runModalForWindow:window];
}

- (void)awakeFromNib
{
  DKProxy<NetworkManager> *networkManager;

  [deviceList removeAllItems];
  networkManager = ((AppController *)[NSApp delegate]).networkManager;
  for (DKProxy<NMDevice> *device in [networkManager GetAllDevices]) {
    if ([device.DeviceType intValue] != 14) {
      [deviceList addItemWithTitle:device.Interface];
      [[deviceList itemWithTitle:device.Interface]
        setRepresentedObject:device];
    }
  }
}

- (void)addConnection:(id)sender
{
  DKProxy<NetworkManager> *networkManager;
  NSMutableDictionary     *settings = [NSMutableDictionary dictionary];
  NSDictionary            *connection;
  DKProxy                 *device;

  networkManager = ((AppController *)[NSApp delegate]).networkManager;
  
  connection = @{@"id":[connectionName stringValue]};
  [settings setObject:connection forKey:@"connection"];
  device = [[deviceList selectedItem] representedObject];

  [networkManager AddAndActivateConnection:settings
                                          :device
                                          :device];
  [window close];
}

@end
