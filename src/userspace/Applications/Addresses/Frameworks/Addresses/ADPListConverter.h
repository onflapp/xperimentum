// ADPListConverter.h (this is -*- ObjC -*-)
// 
// \author: Bj�rn Giesler <giesler@ira.uka.de>
// 
// Address Book Framework for GNUstep
// 

#import <Addresses/ADConverter.h>

@interface ADPListConverter: NSObject<ADInputConverting>
{
  BOOL _done;
  id _plist;
}
- initForInput;
- (BOOL) useString: (NSString*) str;
- (ADRecord*) nextRecord;
@end

