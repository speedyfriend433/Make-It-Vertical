#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static BOOL isVertical = YES;  // Track whether the app is currently forced to vertical

// Hook the RootViewController to override its supported interface orientations.
%hook RootViewController

- (unsigned long long)supportedInterfaceOrientations {
    if (isVertical) {
        // UIInterfaceOrientationMaskPortrait equals 2.
        return UIInterfaceOrientationMaskPortrait;
    } else {
        // In this example we select a landscape orientation.
        // UIInterfaceOrientationMaskLandscapeLeft is typically used.
        return UIInterfaceOrientationMaskLandscapeLeft;
    }
}

%end

%ctor {
    // Listen for a custom notification to toggle the orientation.
    [[NSNotificationCenter defaultCenter] addObserverForName:@"com.myapp.toggleOrientation"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        // Toggle the orientation state.
        isVertical = !isVertical;
        
        // Determine the new target orientation.
        UIInterfaceOrientation targetOrientation = isVertical ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft;
        
        // Force the device to adopt the new orientation using KVC.
        [[UIDevice currentDevice] setValue:@(targetOrientation) forKey:@"orientation"];
        
        // Inform the view controller system to re-evaluate the orientation.
        [UIViewController attemptRotationToDeviceOrientation];
    }];
}
