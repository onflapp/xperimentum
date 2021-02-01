/*
    SyntaxDefinition.h

    Interface declaration of the SyntaxDefinition class for the
    ProjectManager application.

    Copyright (C) 2005  Saso Kiselkov

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import <Foundation/NSObject.h>

#import "TextPattern.h"

@class NSTextStorage, NSColor, NSArray;

@interface SyntaxDefinition : NSObject
{
  NSTextStorage * textStorage;

  TextPattern ** contextBeginnings;
  char contextBeginningChars[128];

  TextPattern *** contextSkips;
  char ** contextSkipChars;

  TextPattern ** contextEndings;
  NSArray * contextGraphics;

  // First indirection is context number, second is keyword
  // number, third is the keyword itself. Both lists are NULL pointer
  // terminated.
  TextPattern *** keywords;

  NSArray * keywordGraphics;
}

+ syntaxDefinitionForFileType: (NSString *) fileType
                  textStorage: (NSTextStorage *) textStorage;

- initWithContextList: (NSArray *) contexts
          textStorage: (NSTextStorage *) aTextStorage;

// Obtaining context starting, ending and skips
- (TextPattern **) contextBeginnings;
- (const char *) contextBeginningCharacters;
- (unsigned int) numberOfContextBeginningCharacters;

- (const char *) contextSkipCharactersForContext: (unsigned int) ctxt;
- (unsigned int) numberOfContextSkipCharactersForContext: (unsigned int) ctxt;

- (TextPattern **) contextSkipsForContext: (unsigned int) ctxt;
- (TextPattern *) contextEndingForContext: (unsigned int) ctxt;

// Inquiring about graphical attributes of contexts
- (NSColor *) foregroundColorForContext: (unsigned int) context;
- (NSColor *) backgroundColorForContext: (unsigned int) context;
- (BOOL) isItalicFontForContext: (unsigned int) context;
- (BOOL) isBoldFontForContext: (unsigned int) context;

// Obtaining keyword patterns
- (TextPattern **) keywordsInContext: (unsigned int) context;

// Inquiring about graphical attributes of keywords
- (NSColor *) foregroundColorForKeyword: (unsigned int) keyword
                              inContext: (unsigned int) context;
- (NSColor *) backgroundColorForKeyword: (unsigned int) keyword
                              inContext: (unsigned int) context;
- (BOOL) isItalicFontForKeyword: (unsigned int) keyword
                      inContext: (unsigned int) context;
- (BOOL) isBoldFontForKeyword: (unsigned int) keyword
                    inContext: (unsigned int) context;

@end
