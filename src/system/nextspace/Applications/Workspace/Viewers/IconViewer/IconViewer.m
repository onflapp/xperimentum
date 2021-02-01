/* -*- mode: objc -*- */
//
// Project: Workspace
//
// Description: Icon Viewer.
//
// Copyright (C) 2018 Sergii Stoian
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

#import <DesktopKit/DesktopKit.h>

#import <DesktopKit/NXTDefaults.h>
#import <DesktopKit/NXTFileManager.h>

#import <Viewers/FileViewer.h>
#import <Viewers/PathIcon.h>
#import <Viewers/PathView.h>
#import "IconViewer.h"

//=============================================================================
// ViewerItemLoader implementation
//=============================================================================
@implementation ViewerItemsLoader

- (id)initWithIconView:(WMIconView *)view
                  path:(NSString *)dirPath
              contents:(NSArray *)dirContents
             selection:(NSArray *)filenames
                update:(BOOL)toUpdate
               animate:(BOOL)isDrawAnimation
{
  [super init];
  
  if (self != nil) {
    iconView = view;
    directoryPath = [[NSString alloc] initWithString:dirPath];
    directoryContents = [dirContents mutableCopy];
    selectedFiles = [[NSArray alloc] initWithArray:filenames];
    isUpdate = toUpdate;
    isAnimate = isDrawAnimation;
  }

  return self;
}

- (void)_updateItems:(NSMutableArray *)items
            fileView:(WMIconView *)view
{
  NXTIcon         *icon;
  NSMutableArray *itemsCopy = [items mutableCopy];
  NSArray        *iconsCopy = [[view icons] copy];

  // NSLog(@"_updateItems: %lu", [items count]);
  
  // Remove non-existing items
  for (NXTIcon *icon in iconsCopy) {
    if ([items indexOfObject:[[icon label] text]] == NSNotFound) {
      [view performSelectorOnMainThread:@selector(removeIcon:)
                             withObject:icon
                          waitUntilDone:YES];
    }
  }

  // Leave in `items` array items to add.
  for (NSString *filename in itemsCopy) {
    icon = [view iconWithLabelString:filename];
    if (icon) {
      [items removeObject:filename];
    }
  }
  [itemsCopy release];
  [iconsCopy release];
}

- (void)main
{
  NSString       *path;
  PathIcon       *anIcon;
  NSUInteger     x, y, slotsWide, slotsTallVisible;
  NSMutableSet   *selectedIcons = [NSMutableSet new];
  NSMutableArray *iconsToAdd = [NSMutableArray new];

  if (isAnimate != NO) {
    [iconView performSelectorOnMainThread:@selector(drawOpenAnimation)
                               withObject:nil
                            waitUntilDone:NO];
  }

  NSLog(@"IconView: Begin path loading... %@ [%@]", directoryPath, selectedFiles);

  x = y = 0;
  slotsWide = [iconView slotsWide];
  slotsTallVisible = [iconView slotsTallVisible];

  if (isUpdate != NO) {
    [self _updateItems:directoryContents fileView:iconView];
  }
  
  selectedIcons = [NSMutableSet new];
  iconsToAdd = [NSMutableArray new];
  
  for (NSString *filename in directoryContents) {
    path = [directoryPath stringByAppendingPathComponent:filename];

    anIcon = [[PathIcon alloc] init];
    [anIcon setLabelString:filename];
    [anIcon setIconImage:[[NSApp delegate] iconForFile:path]];
    [anIcon setPaths:[NSArray arrayWithObject:path]];

    [iconsToAdd addObject:anIcon];
    if ([selectedFiles containsObject:filename]) {
      [selectedIcons addObject:anIcon];
    }
    [anIcon release];

    x++;
    if (x == slotsWide) {
      y++;
      x = 0;
    }
    // Add icons on per page basis
    if (y == slotsTallVisible && [iconView isAnimating] == NO) {
      [iconView performSelectorOnMainThread:@selector(addIcons:)
                                 withObject:iconsToAdd
                              waitUntilDone:YES];
      [iconsToAdd removeAllObjects];
      x = y = 0;
    }
  }

  if ([iconsToAdd count] > 0) {
    [iconView performSelectorOnMainThread:@selector(addIcons:)
                               withObject:iconsToAdd
                            waitUntilDone:YES];
    [iconsToAdd removeAllObjects];
  }
  
  if ((isUpdate != NO) &&
      selectedFiles &&
      ([selectedFiles count] != [selectedIcons count])) {
    NXTIcon *icon;
    for (NSString *filename in selectedFiles) {
      if ((icon = [iconView iconWithLabelString:filename])) {
        [selectedIcons addObject:icon];
      }
    }
  }
  [iconView performSelectorOnMainThread:@selector(selectIcons:)
                             withObject:selectedIcons
                          waitUntilDone:YES];
  
  NSLog(@"IconView: End path loading...");
  [selectedIcons release];
  [iconsToAdd release];
  
  [directoryPath release];
  [directoryContents release];
  [selectedFiles release];
}

- (BOOL)isReady
{
  return YES;
}

@end

//=============================================================================
// WMIconView implementation
//=============================================================================
static NSRect boxRect;
static NSRect viewFrame;
@implementation WMIconView

- (id)validRequestorForSendType:(NSString *)st
                     returnType:(NSString *)rt
{
  NSString *currentPath = [[[self delegate] selectedPaths] firstObject];
  
  if (currentPath && [st isEqual:NSStringPboardType])
    return self;
  else
    return nil;
}

- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pb
                             types:(NSArray *)types
{
  NSString *currentPath = [[[self delegate] selectedPaths] firstObject];
  
  if (currentPath) {
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pb setString:currentPath forType:NSStringPboardType];
    return YES;
  }
  else {
    return NO;
  }
}


- (void)drawRect:(NSRect)r
{
  if (isDrawOpenAnimation) {
    NSFrameRect(boxRect);
  }
  else {
    [super drawRect:r];
  }
}
- (void)drawOpenAnimation
{
  NSUInteger step = 5;
  NSUInteger power = 1;

  isDrawOpenAnimation = YES;

  viewFrame = [self frame];
  // viewFrame = [[[self enclosingScrollView] contentView] frame];

  while (boxRect.size.width < viewFrame.size.width ||
         boxRect.size.height < viewFrame.size.height) {
      
    boxRect.origin.x -= step * power;
    if (boxRect.origin.x < 0 ) boxRect.origin.x = 0;
    boxRect.origin.y -= step * power;
    if (boxRect.origin.y < 0 ) boxRect.origin.y = 0;

    boxRect.size.width += (step * power) * 2;
    if (boxRect.size.width > viewFrame.size.width)
      boxRect.size.width = viewFrame.size.width;
    boxRect.size.height += (step * power) * 2;
    if (boxRect.size.height > viewFrame.size.height)
      boxRect.size.height = viewFrame.size.height;
    power++;

    [self displayRect:NSMakeRect(boxRect.origin.x, boxRect.origin.y,
                                 boxRect.size.width, 1)];
    [self displayRect:NSMakeRect(boxRect.origin.x, boxRect.origin.y,
                                 1, boxRect.size.height)];
    [self displayRect:NSMakeRect(boxRect.origin.x + boxRect.size.width - 1,
                                 boxRect.origin.y,
                                 1, boxRect.size.height)];
    [self displayRect:NSMakeRect(boxRect.origin.x,
                                 boxRect.origin.y + boxRect.size.height - 1,
                                 boxRect.size.width, 1)];
  }

  isDrawOpenAnimation = NO;
  [self setNeedsDisplay:YES];
}
- (BOOL)isAnimating
{
  return isDrawOpenAnimation;
}
@end

//=============================================================================
// IconViewer implementation
//=============================================================================
@implementation IconViewer

- (void)dealloc
{
  NSLog(@"[IconViewer](%@) -dealloc", rootPath);
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  if (itemsLoader != nil) {
    [itemsLoader cancel];
    [itemsLoader release];
  }
  
  TEST_RELEASE(_owner);
  TEST_RELEASE(rootPath);
  TEST_RELEASE(currentPath);
  TEST_RELEASE(selection);

  TEST_RELEASE(view);

  [super dealloc];
}

- init
{
  NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
  NSSize         iconSize;

  [super init];

  // IconView
  iconView = [[WMIconView alloc] initSlotsWide:3];
  [iconView setDelegate:self];
  [iconView setTarget:self];
  [iconView setDragAction:@selector(iconDragged:withEvent:)];
  [iconView setAllowsAlphanumericSelection:YES];
  [iconView setSendsDoubleActionOnReturn:YES];
  [iconView setDoubleAction:@selector(open:)];
  [iconView setAutoAdjustsToFitIcons:YES];
  iconSize = [NXTIconView defaultSlotSize];
  if ([[NXTDefaults userDefaults] objectForKey:@"IconSlotWidth"]) {
    iconSize.width = [[NXTDefaults userDefaults] floatForKey:@"IconSlotWidth"]; 
    [iconView setSlotSize:iconSize];
  }
  [iconView registerForDraggedTypes:@[NSFilenamesPboardType]];

  // ScrollView
  view = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
  [view setBorderType:NSBezelBorder];
  [view setHasVerticalScroller:YES];
  [view setHasHorizontalScroller:NO];

  [view setDocumentView:iconView];
  [iconView setFrame:NSMakeRect(0, 0, [[view contentView] frame].size.width, 0)];
  [iconView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
  
  // Operation
  operationQ = [[NSOperationQueue alloc] init];
  itemsLoader = nil;
  doAnimation = NO;
  
  [[NSNotificationCenter defaultCenter]
          addObserver:self
             selector:@selector(iconWidthDidChange:)
                 name:@"IconSlotWidthDidChangeNotification"
               object:nil];
  
  currentPath = nil;
  selection = nil;
  rootPath = @"/";
  
  [iconView release];
  
  return self;
}

//=============================================================================
// <Viewer> protocol methods
//=============================================================================
+ (NSString *)viewerType
{
  return _(@"Icon");
}

+ (NSString *)viewerShortcut
{
  return _(@"I");
}

- (NSView *)view
{
  return view;
}

- (NSView *)keyView
{
  return iconView;
}

- (void)setOwner:(FileViewer *)owner
{
  ASSIGN(_owner, owner);
}

- (void)setRootPath:(NSString *)path
{
  ASSIGN(rootPath, path);
}
- (NSString *)fullPath
{
  return [rootPath stringByAppendingPathComponent:currentPath];
}

- (CGFloat)columnWidth
{
  return [[NXTDefaults userDefaults] floatForKey:@"IconSlotWidth"];
}
- (void)setColumnWidth:(CGFloat)width
{
  // Implement
}
- (NSUInteger)columnCount
{
  return 3;
}
- (void)setColumnCount:(NSUInteger)num
{
  // 
}
- (NSInteger)numberOfEmptyColumns
{
  return 0;
}
- (void)setNumberOfEmptyColumns:(NSInteger)num
{
  // Do nothing: Viewer protocol method
}

- (NSArray *)selectedPaths
{
  NSMutableArray *pathList;
  NSString       *pathPrefix;
  
  if (!currentPath)
    return nil;

  pathList = [NSMutableArray new];
  pathPrefix = [rootPath stringByAppendingPathComponent:currentPath];
  
  if ([selection count] > 0) {
    for (NSString *path in selection) {
      path = [pathPrefix stringByAppendingPathComponent:path];
      [pathList addObject:path];
    }
    return pathList;
  }
  else {
    [pathList addObject:currentPath];
  }
  
  return pathList;
}

//=============================================================================
// Actions
//=============================================================================
- (void)displayPath:(NSString *)dirPath
          selection:(NSArray *)filenames
{
  NSArray  *dirContents;
  NSString *path;

  if (!dirPath || [dirPath isEqualToString:@""])
    return;
  
  if ([currentPath isEqualToString:dirPath]) {
    updateOnDisplay = YES;
  }
  
  if (updateOnDisplay == NO) {
    ASSIGN(currentPath, dirPath);
  }
  ASSIGN(selection, filenames);

  if (itemsLoader != nil) {
    [itemsLoader cancel];
    [itemsLoader release];
  }

  path = [rootPath stringByAppendingPathComponent:dirPath];
  NSLog(@"IconViewer(%@): display path: %@ updateOnDisplay:%i",
        rootPath, dirPath, updateOnDisplay);

  if (updateOnDisplay == NO) {
    [iconView removeAllIcons];
    // [iconView display];
  }
  dirContents = [_owner directoryContentsAtPath:dirPath forPath:nil];
  itemsLoader = [[ViewerItemsLoader alloc] initWithIconView:iconView
                                                       path:path
                                                   contents:dirContents
                                                  selection:filenames
                                                     update:updateOnDisplay
                                                    animate:doAnimation];
  [itemsLoader addObserver:self
                forKeyPath:@"isFinished"
                   options:0
                   context:self];
  [operationQ addOperation:itemsLoader];
  [_owner setWindowEdited:YES];
}
- (void)reloadPathWithSelection:(NSString *)relativePath
{
  NSRect r = [iconView visibleRect];

  [self displayPath:relativePath selection:selection];
  [iconView scrollRectToVisible:r];
}
- (void)reloadPath:(NSString *)reloadPath
{
  NSRect r;

  if ([reloadPath isEqualToString:currentPath] == NO)
    return;
  
  // r = [[iconView enclosingScrollView] documentVisibleRect];
  // NSLog(@"[IconViewer] reloadPath visible rect: %@", NSStringFromRect(r));
  updateOnDisplay = YES;
  [self displayPath:reloadPath selection:selection];
  // updateOnDisplay = NO;
  // [iconView scrollRectToVisible:r];
}
- (void)open:sender
{
  NSSet    *selected = [iconView selectedIcons];
  NSString *path, *fullPath;
  NSString *appName, *fileType;

  // NSLog(@"[IconViewer] open path:%@ selection:%@", currentPath, selection);

  if ([selected count] == 0) {
    [_owner displayPath:currentPath selection:nil sender:self];
  }
  else if ([selected count] == 1) {
    path = [currentPath stringByAppendingPathComponent:[selection objectAtIndex:0]];
    fullPath = [rootPath stringByAppendingPathComponent:path];
    [(NSWorkspace *)[NSApp delegate] getInfoForFile:fullPath
                                        application:&appName
                                               type:&fileType];

    if ([fileType isEqualToString:NSDirectoryFileType] ||
        [fileType isEqualToString:NSFilesystemFileType]) {
      doAnimation = YES;
      boxRect = [[[iconView selectedIcons] anyObject] frame];
      [self displayPath:path selection:nil];
      [_owner displayPath:path selection:nil sender:self];
    }
    else {
      [_owner open:sender];
    }
  }
}

- (void)scrollToRange:(NSRange)range
{
  // Do nothing
}
- (BOOL)becomeFirstResponder
{
  return YES;
}

// --- Events
- (void)currentSelectionRenamedTo:(NSString *)newName
{
  PathIcon *icon = [[iconView selectedIcons] anyObject];
  NSString *path;

  [icon setLabelString:[newName lastPathComponent]];
  path = [rootPath stringByAppendingPathComponent:newName];
  [icon setIconImage:[[NSApp delegate] iconForFile:path]];
}

// -- Notifications
- (void)iconWidthDidChange:(NSNotification *)notification
{
  NXTDefaults *df = [NXTDefaults userDefaults];
  NSSize     slotSize = [iconView slotSize];

  slotSize.width = [df floatForKey:@"IconSlotWidth"];
  [iconView setSlotSize:slotSize];
}

// -- NSOperation
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  NXTIconLabel *iconLabel;
  
  NSLog(@"IconView: Observer `%@` of '%@' was called.", [self className], keyPath);
  for (NXTIcon *icon in [iconView icons]) {
    [icon setEditable:YES];
    [icon setDelegate:self];
    [icon setTarget:self];
    [icon setDoubleAction:@selector(open:)];
    [icon setDragAction:@selector(iconDragged:withEvent:)];
    [icon registerForDraggedTypes:@[NSFilenamesPboardType]];
    iconLabel = [icon label];
    [iconLabel setNextKeyView:iconView];
    [iconLabel setIconLabelDelegate:_owner];
  }

  // [iconView scrollPoint:NSZeroPoint];
  [iconView performSelectorOnMainThread:@selector(adjustToFitIcons)
                             withObject:nil
                          waitUntilDone:YES];
  [[view window] makeFirstResponder:iconView];
  [_owner setWindowEdited:NO];
  updateOnDisplay = NO;
  doAnimation = NO;
}

//=============================================================================
// Local
//=============================================================================
//
// --- NXTIconView delegate
//
- (void)     iconView:(NXTIconView*)anIconView
 didChangeSelectionTo:(NSSet *)selectedIcons
{
  NSMutableArray *selected = [NSMutableArray array];
  BOOL           showsExpanded = ([selectedIcons count] == 1) ? YES : NO;

  if (anIconView != iconView)
    return;

  NSLog(@"IconViewer(%@): selection did change.", rootPath);

  for (NXTIcon *icon in selectedIcons) {
    [icon setShowsExpandedLabelWhenSelected:showsExpanded];
    [selected addObject:[icon labelString]];
  }

  ASSIGN(selection, [[selected copy] autorelease]);

  [_owner displayPath:currentPath selection:selection sender:self];
}

- (void)keyDown:(NSEvent *)ev
{
  NSString   *characters = [ev characters];
  NSUInteger charsLength = [characters length];
  unichar    ch = 0;
  NSUInteger modifierFlags = [ev modifierFlags];

  if (charsLength > 0) {
    ch = [characters characterAtIndex:0];
  }
  
  NSLog(@"[IconViewer] keyDown: %c", ch);

  if ((ch == NSUpArrowFunctionKey) && (modifierFlags & NSCommandKeyMask)) {
    [self displayPath:[currentPath stringByDeletingLastPathComponent]
            selection:@[[currentPath lastPathComponent]]];
    return;
  }
  else if ((ch == NSDownArrowFunctionKey) && modifierFlags & NSCommandKeyMask) {
    [self open:nil];
    return;
  }

  /*
  if (allowsAlphanumericSelection && (ch < 0xF700) && (charsLength > 0))
    {
      NSMatrix *matrix;
      NSString *sv;
      NSInteger i, n, s;
      NSInteger match;
      NSInteger selectedColumn;
      SEL lcarcSel = @selector(loadedCellAtRow:column:);
      IMP lcarc = [self methodForSelector:lcarcSel];

      // NSLog(@"selectedColumn: %i", selectedColumn);
      
      matrix = [self matrixInColumn:selectedColumn];
      n = [matrix numberOfRows];
      s = [matrix selectedRow];
          
      if (clickTimer && [clickTimer isValid]) {
        [clickTimer invalidate];
      }
      clickTimer =
        [NSTimer
              scheduledTimerWithTimeInterval:0.8
                                      target:self
                                    selector:@selector(_performClick:)
                                    userInfo:matrix
                                     repeats:NO];
      if (!_charBuffer)
        {
          _charBuffer = [characters substringToIndex:1];
          RETAIN(_charBuffer);
        }
      else
        {
          if (([ev timestamp] - _lastKeyPressed < 2.0)
              && (_alphaNumericalLastColumn == selectedColumn)
              && s >= 0)
            {
              NSString *transition;
              transition = [_charBuffer 
                                 stringByAppendingString:
                               [characters substringToIndex:1]];
              RELEASE(_charBuffer);
              _charBuffer = transition;
              RETAIN(_charBuffer);
            }
          else
            {
              RELEASE(_charBuffer);
              _charBuffer = [characters substringToIndex:1];
              RETAIN(_charBuffer);
            }
        }

      // NSLog(@"_charBuffer: %@ _lastKeyPressed:%f(%f) selected:%i",
      //       _charBuffer, _lastKeyPressed, [ev timestamp], s);

      _alphaNumericalLastColumn = selectedColumn;
      _lastKeyPressed = [ev timestamp];

      //[[self loadedCellAtRow:column:] stringValue]
      sv = [((*lcarc)(self, lcarcSel, s, selectedColumn)) stringValue];

      // selected cell aleady contains typed string - _charBuffer
      if (([sv length] > 0) && ([sv hasPrefix:_charBuffer]))
        {
          return;
        }

      // search row from selected to the bottom
      match = -1;
      for (i = s + 1; i < n; i++)
        {
          sv = [((*lcarc)(self, lcarcSel, i, selectedColumn)) stringValue];
          if (([sv length] > 0) && ([sv hasPrefix: _charBuffer]))
            {
              match = i;
              break;
            }
        }
      // previous search found nothing, start from top
      if (i == n)
        {
          for (i = 0; i < s; i++)
            {
              sv = [((*lcarc)(self, lcarcSel, i, selectedColumn))
                     stringValue];
              if (([sv length] > 0)
                  && ([sv hasPrefix: _charBuffer]))
                {
                  match = i;
                  break;
                }
            }
        }
      if (match != -1)
        {
          [matrix deselectAllCells];
          [matrix selectCellAtRow:match column:0];
          [matrix scrollCellToVisibleAtRow:match column:0];
          // click performed with timer
          // [matrix performClick:self];
          return;
        }
        
      _lastKeyPressed = 0.;
      return;
    }
  */
}

//=============================================================================
// Drag and Drop
//=============================================================================
// NXTIconView delegate
- (void)iconDragged:(PathIcon *)sender withEvent:(NSEvent *)ev
{
  NSArray      *paths;
  NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
  NSRect       iconFrame = [sender frame];
  NSPoint      iconLocation;
  PathIcon     *icon = [[iconView icons] lastObject];

  _dragSource = self;
  _dragIcon = sender;

  iconLocation.x = iconFrame.origin.x + 8;
  iconLocation.y = iconFrame.origin.y + (iconFrame.size.width - 16);

  [_dragIcon setSelected:NO];
  [_dragIcon setDimmed:YES];

  paths = [_dragIcon paths];
  _dragMask = [_owner draggingSourceOperationMaskForPaths:paths];

  [pb declareTypes:@[NSFilenamesPboardType] owner:nil];
  [pb setPropertyList:paths forType:NSFilenamesPboardType];

  [iconView dragImage:[_dragIcon iconImage]
                   at:iconLocation
               offset:NSZeroSize
                event:ev
           pasteboard:pb
               source:_dragSource
            slideBack:YES];
}

// NSDraggingSource
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
  return _dragMask;
}

- (void)draggedImage:(NSImage*)image
             endedAt:(NSPoint)screenPoint
           deposited:(BOOL)didDeposit
{
  [_dragIcon setSelected:YES];
  [_dragIcon setDimmed:NO];
}

@end
