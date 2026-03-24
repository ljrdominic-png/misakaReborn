#import "DeviceLockStatus.h"
#import "notify.h"
#import "misaka-Swift.h"


@implementation DeviceLockStatus

-(void)registerAppforDetectLockState {
 int notify_token;
    notify_register_dispatch("com.apple.springboard.lockstate", &notify_token,dispatch_get_main_queue(), ^(int token) {
        uint64_t state = UINT64_MAX;
        notify_get_state(token, &state);

        DeviceStatus * myOb = [DeviceStatus new];  //DeviceStatus is .swift file

        if(state == 0) {
            myOb.unlocked;
        } else {
            myOb.locked;
        }

    });
}
@end
