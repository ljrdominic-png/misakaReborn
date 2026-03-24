#ifndef DeviceLockStatus_h
#define DeviceLockStatus_h
#import <Foundation/Foundation.h>

@interface DeviceLockStatus : NSObject

@property (strong, nonatomic) id someProperty;

-(void)registerAppforDetectLockState;

@end
#endif /* DeviceLockStatus_h */

