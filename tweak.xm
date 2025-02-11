#import <UIKit/UIKit.h>

static BOOL isVertical = YES;  // Global flag to track orientation state

%hook RootViewController

// Override the supportedInterfaceOrientations method so that allowed orientations
// change depending on the current state.
- (unsigned long long)supportedInterfaceOrientations {
    if (isVertical) {
        // UIInterfaceOrientationMaskPortrait equals 2.
        return UIInterfaceOrientationMaskPortrait;
    } else {
        // For landscape, choose UIInterfaceOrientationMaskLandscapeLeft.
        return UIInterfaceOrientationMaskLandscapeLeft;
    }
}

// Add a floating toggle button when the view appears.
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    
    // Since RootViewController is a forward declaration, cast self to UIViewController
    UIViewController *vc = (UIViewController *)self;
    
    // Add the toggle button only once.
    if (![vc.view viewWithTag:1001]) {
        UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        toggleButton.frame = CGRectMake(20, 40, 180, 40);
        toggleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        // Set the initial title depending on the current state.
        NSString *title = isVertical ? @"Switch to Landscape" : @"Switch to Portrait";
        [toggleButton setTitle:title forState:UIControlStateNormal];
        [toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        toggleButton.tag = 1001;
        
        // When tapped, call our custom toggle method.
        [toggleButton addTarget:self
                         action:@selector(toggleOrientationButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
        [vc.view addSubview:toggleButton];
    }
}

// New method that toggles the orientation in real time.
- (void)toggleOrientationButtonTapped:(id)sender {
    // Toggle the global flag.
    isVertical = !isVertical;
    
    // Determine the new target orientation.
    UIInterfaceOrientation targetOrientation = isVertical ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft;
    
    // Force the device orientation using KVC (this uses a private API).
    [[UIDevice currentDevice] setValue:@(targetOrientation) forKey:@"orientation"];
    
    // Request the system to update the interface orientation.
    [UIViewController attemptRotationToDeviceOrientation];
    
    // Update the button's title to reflect the change.
    UIButton *toggleButton = (UIButton *)sender;
    NSString *newTitle = isVertical ? @"Switch to Landscape" : @"Switch to Portrait";
    [toggleButton setTitle:newTitle forState:UIControlStateNormal];
}

%end

%ctor {
    // No additional initialization is required.
}
