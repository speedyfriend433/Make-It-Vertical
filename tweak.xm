#import <UIKit/UIKit.h>

static BOOL isVertical = YES;  // Global flag for the current orientation state

%hook RootViewController

// Override the method reporting supported orientations based on our flag.
- (unsigned long long)supportedInterfaceOrientations {
    if (isVertical) {
        // Portrait – UIInterfaceOrientationMaskPortrait equals 2.
        return UIInterfaceOrientationMaskPortrait;
    } else {
        // Landscape – using UIInterfaceOrientationMaskLandscapeLeft.
        return UIInterfaceOrientationMaskLandscapeLeft;
    }
}

// Add a floating toggle button when the view appears.
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    
    // Cast self to UIViewController to gain access to the "view" property.
    UIViewController *vc = (UIViewController *)self;
    
    // Only add the button if it hasn't been added already.
    if (![vc.view viewWithTag:1001]) {
        UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        toggleButton.frame = CGRectMake(20, 40, 180, 40);
        toggleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        NSString *title = isVertical ? @"Switch to Landscape" : @"Switch to Portrait";
        [toggleButton setTitle:title forState:UIControlStateNormal];
        [toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        toggleButton.tag = 1001;
        
        // Add our toggle action.
        [toggleButton addTarget:self
                         action:@selector(toggleOrientationButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
        
        [vc.view addSubview:toggleButton];
    }
}

// This action toggles the orientation when the button is pressed.
- (void)toggleOrientationButtonTapped:(id)sender {
    // Toggle our orientation flag.
    isVertical = !isVertical;
    
    // Determine the target orientation.
    UIInterfaceOrientation targetOrientation = isVertical ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft;
    
    // Use NSInvocation to call the private setOrientation: selector on UIDevice.
    SEL setOrientationSelector = NSSelectorFromString(@"setOrientation:");
    if ([[UIDevice currentDevice] respondsToSelector:setOrientationSelector]) {
        NSMethodSignature *signature = [[UIDevice currentDevice] methodSignatureForSelector:setOrientationSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:setOrientationSelector];
        [invocation setTarget:[UIDevice currentDevice]];
        // The argument index starts at 2 (0 is self, 1 is _cmd).
        int orient = targetOrientation;
        [invocation setArgument:&orient atIndex:2];
        [invocation invoke];
    }
    
    // Ask the system to perform rotation based on the new allowed orientations.
    [UIViewController attemptRotationToDeviceOrientation];
    
    // Update the button title to reflect the new state.
    UIButton *toggleButton = (UIButton *)sender;
    NSString *newTitle = isVertical ? @"Switch to Landscape" : @"Switch to Portrait";
    [toggleButton setTitle:newTitle forState:UIControlStateNormal];
}

%end

%ctor {
    // No extra initialization required.
}
