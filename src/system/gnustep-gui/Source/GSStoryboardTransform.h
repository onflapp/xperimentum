/* Interface of class GSStoryboardTransform
   Copyright (C) 2020 Free Software Foundation, Inc.
   
   By: Gregory John Casamento
   Date: Sat 04 Jul 2020 03:48:15 PM EDT

   This file is part of the GNUstep Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110 USA.
*/

#ifndef _GSStoryboardTransform_h_GNUSTEP_GUI_INCLUDE
#define _GSStoryboardTransform_h_GNUSTEP_GUI_INCLUDE

#import <Foundation/NSObject.h>

@class NSString;
@class NSMutableDictionary;
@class NSDictionary;
@class NSData;
@class NSMapTable;
@class NSXMLDocument;

#if	defined(__cplusplus)
extern "C" {
#endif

@interface GSStoryboardTransform : NSObject
{
  NSMutableDictionary *_scenesMap;
  NSMutableDictionary *_controllerMap;
  NSMutableDictionary *_identifierToSegueMap;
  NSString *_initialViewControllerId;
  NSString *_applicationSceneId;
}

- (instancetype) initWithData: (NSData *)data;

- (NSString *) initialViewControllerId;
- (NSString *) applicationSceneId;

- (NSData *) dataForIdentifier: (NSString *)identifier;
- (NSMapTable *) segueMapForIdentifier: (NSString *)identifier;

- (void) processStoryboard: (NSXMLDocument *)storyboardXml;
- (void) processSegues: (NSXMLDocument *)xml
       forControllerId: (NSString *)identifier;
@end

// Private classes used when parsing the XIB generated by the transformer...
@interface NSStoryboardSeguePerformAction : NSObject <NSCoding, NSCopying>
{
  id            _target;
  SEL           _action;
  id            _sender;
  NSString     *_identifier;
  NSString     *_kind;
  id            _popoverAnchorView;
  NSStoryboardSegue *_storyboardSegue;
  NSStoryboard *_storyboard;
}

- (id) target;
- (void) setTarget: (id)target;

- (NSString *) selector;
- (void) setSelector: (NSString *)s;

- (SEL) action;
- (void) setAction: (SEL)action;

- (id) sender;
- (void) setSender: (id)sender;

- (NSString *) identifier;
- (void) setIdentifier: (NSString *)identifier;

- (NSString *) kind;
- (void) setKind: (NSString *)kind;

- (void) setPopoverAnchorView: (id)view;
- (id) popoverAnchorView;

- (NSStoryboard *) storyboard;
- (void) setStoryboard: (NSStoryboard *)storyboard;

- (NSStoryboardSegue *) storyboardSegue;
- (void) setStoryboardSegue: (NSStoryboardSegue *)ss;
  
- (IBAction) doAction: (id)sender;
@end

@interface NSControllerPlaceholder : NSObject <NSCoding, NSCopying> 
{
  NSString *_storyboardName;
}

- (NSString *) storyboardName;
- (void) setStoryboardName: (NSString *)name;

- (id) instantiate;
@end

#if	defined(__cplusplus)
}
#endif

#endif	/* _GSStoryboardTransform_h_GNUSTEP_GUI_INCLUDE */
