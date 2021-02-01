/* -*- mode: objc -*- */
//
// Project: Workspace
//
// Copyright (C) 2014 Sergii Stoian
//
// This application is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License as published by the Free Software Foundation; either
// version 2 of the License, or (at your option) any later version.
//
// This application is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with this library; if not, write to the Free
// Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
//

#import <AppKit/AppKit.h>
#import <DesktopKit/DesktopKit.h>

#import <Preferences/PrefsModule.h>

/**
   Defaults keys:
     @"IconSlotWidth"
 */
@interface IconPrefs : NSObject <PrefsModule>
{
  id bogusWindow;
  id button;
  id iconImage;
  id iconLabel;
  id leftArr;
  id rightArr;
  id resizableSwitch;

  NSBox  *box;
  NSBox  *box2;
  NXTIcon *icon;
}

- (void)revert:sender;

// - (BOOL)arrowView:(NXTSizer *)sender shouldMoveByDelta:(float)delta;
// - (void)arrowViewStoppedMoving:(NXTSizer *)sender;

- (void)changedSelection:(NSNotification *)notif;

@end
