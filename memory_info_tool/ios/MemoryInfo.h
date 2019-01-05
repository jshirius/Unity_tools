//
//  MemoryInfo.h
//  memory_test
//
#import <UIKit/UIKit.h>

#ifndef MemoryInfo_h
#define MemoryInfo_h



@interface MemoryInfo:NSObject{
    bool memoryWarningFlag;
}
    -(void)_setupObservers;
    +(MemoryInfo*)sharedInstance;
    - (NSString*) getMemoryInfo;
@end
    
#endif /* MemoryInfo_h */
