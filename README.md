MMAccessoryPanel (iOS 6+)
=========================

MMAccessoryPanel is a iOS Cocoa Touch class that creates and manages collapsible bars on top of any UIScrollView, just below the navigation bar. MMAccessoryPanel collapses to invisible when user scroll down, and expand when when user scroll up.

MMAccessoryPanel helps maximize usable screen estate for scroll view. The behavior is some what similar to the top bar in Facebook app.

![Crappy gif ahoy!](images/demo.gif)

##Installation
Copy the `MMAccessoryPanel` folder that has the `.h` and `.m` into you project.

If you are using CocoaPods, add: pod 'MMAccessoryPanel' to the Podfile.

##Sample code:

To add the bar to any scroll view:

In viewDidLoad, add:

	UIToolbar *bar1 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40.0)];
	bar1.barTintColor = [UIColor colorWithRed:0.1 green:0.8 blue:1.0 alpha:1.0];
	
	UIToolbar *bar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40.0)];
	bar2.barTintColor = [UIColor colorWithRed:0.8 green:0.8 blue:8.0 alpha:1.0];
	
	self.accessoryPanel = [[MMAccessoryPanel alloc] initWithBars:@[bar1, bar2]];
	self.accessoryPanel.viewController = self;

In viewDidAppear, add:

	[self.accessoryPanel snapToScrollView:self.tableView];

Please See the attached sample project for details.

##Credits
MMAccessoryPanel was originally developed by Medallia mobile team for Medallia mobile app. 
http://www.medallia.com/
https://itunes.apple.com/us/app/medallia-mobile-2/id675309749?mt=8
