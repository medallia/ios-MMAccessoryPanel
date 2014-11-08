#import <UIKit/UIKit.h>

/**
 * MMAccessoryBar is a floating view floating on top of a UIScrollView, similar to
 * the tool bar on top of Facebook timeline view. It is anchored just below UINavigationBar.
 *
 * The view collapse when scrollview scroll up and expanse when user scroll down.
 *
 * MMAccessoryBar frame is auto-calculated to the full width. Don't manually change it.
 *
 * To set the height, use maxHeight property.
 *
 * To use MMAccessoryBar, create one and simply attach it to a UIScrollView using attachToScrollView:
 */
@interface MMAccessoryPanel : UIView <UIScrollViewDelegate>

/** The height of MMAccessoryBar can be dynamic (expand/collapse as user scroll down/up
 *	this value control max height to expand when user scroll up
 */
@property (nonatomic, readonly) CGFloat maxHeight;

/** Array of subview stacked vertically within the panel
 */
@property (nonatomic, strong) NSArray *bars;

/** UIViewController that own this panel */
@property (nonatomic, weak) UIViewController *viewController;

/** Create a panel and add it to a view. The bar does not neccessary a a subview of scroll view it's attached to
 *	It actually a sibling of the scrollview and automatically sync its position
 *	with the scrollView.
 */
- (id)initWithBars:(NSArray *)bars;

/** Snap will either close or expand the panel fully */
- (void)snapToScrollView:(UIScrollView *)scrollView;

@end
