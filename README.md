• Casting to UIViewController:
Since the compiler only sees a forward declaration of RootViewController (and therefore doesn’t know it has a “view” property), we cast “self” to UIViewController * when accessing “view”.
For example:
  UIViewController *vc = (UIViewController *)self;
  if (![vc.view viewWithTag:1001]) { … }
This makes the “view” property available for use in our code.

• Toggling Orientation:
The button toggles the state of a global Boolean (isVertical), changes the allowed interface orientation (based on the hooked –supportedInterfaceOrientations), forces the device to rotate using a KVC trick (via [[UIDevice currentDevice] setValue:@(targetOrientation) forKey:@"orientation"]), and then asks the system to update using [UIViewController attemptRotationToDeviceOrientation].

• Floating Button Setup:
The toggle button is added once in –viewDidAppear:, preventing duplicate buttons. Its title updates according to the orientation state so that the user understands the next toggle.
