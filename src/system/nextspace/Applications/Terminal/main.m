/*
  Copyright (c) 2002, 2003 Alexander Malmberg <alexander@malmberg.org>
  Copyright (c) 2015-2017 Sergii Stoian <stoyan255@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; version 2 of the License.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#import <Foundation/NSDebug.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSView.h>

#import "Defaults.h"
#import "TerminalServices.h"
#import "TerminalView.h"
#import "TerminalWindow.h"

@interface Terminal : NSObject

@end

/* TODO */
#import <AppKit/NSWindow.h>
#import <AppKit/NSEvent.h>

@interface NSWindow (avoid_warnings)
- (void)sendEvent:(NSEvent *)e;
@end

@interface TerminalApplication : NSApplication
@end

@implementation TerminalApplication
- (void)sendEvent:(NSEvent *)e
{
  if ([e type] == NSKeyDown && 
      [e modifierFlags] & NSCommandKeyMask &&
      [[Defaults shared] alternateAsMeta])
    {
      NSDebugLLog(@"key",@"intercepting key equivalent");
      [[e window] sendEvent:e];
      return;
    }

  [super sendEvent: e];
}
@end


int main(int argc, const char **argv)
{
/*  CREATE_AUTORELEASE_POOL(arp);

  [TerminalApplication sharedApplication];

  [NSApp setDelegate: [[Terminal alloc] init]];
  [NSApp run];

  DESTROY(arp);
  return 0;*/
  
  return NSApplicationMain(argc, argv);
}

