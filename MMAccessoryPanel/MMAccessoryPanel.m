#import "MMAccessoryPanel.h"

/** Observed property names of the scrollview attached to */
#define kMMAccessoryBarContentOffsetPropertyName NSStringFromSelector(@selector(contentOffset))

@interface MMAccessoryPanel()
{
	// last processed scrollview contentOffset.y
	CGFloat _adjustedOffsetY;
	
	BOOL _needsSetupConstraints;
}

/** Scrollview that this accessory bar is attached to */
@property (nonatomic, strong) UIScrollView *targetScrollView;

/** Constraint to control panel height, updated as user scroll up/down */
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

/** Constraint to control panel max height, updated when the subview resized */
@property (nonatomic, strong) NSLayoutConstraint *maxHeightConstraint;

@end

@implementation MMAccessoryPanel

- (id)initWithBars:(NSArray *)bars
{
	if ((self = [super init])) {
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = YES;
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		
		self.bars = bars;
	}
	return self;
}

- (void)dealloc
{
	if (_targetScrollView) {
		[_targetScrollView removeObserver:self forKeyPath:kMMAccessoryBarContentOffsetPropertyName];
		if (_targetScrollView.delegate == self) _targetScrollView.delegate = nil;
	}
}

- (void)setBars:(NSArray *)bars
{
	[_bars makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];

	_bars = bars;
	for (UIView *bar in bars)
	{
		bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self insertSubview:bar atIndex:0]; // insert in reverse order
	}
	[self setNeedsLayout];
}

- (CGFloat)maxHeight
{
	CGFloat maxHeight = 0;
	for (UIView *bar in self.bars) {
		maxHeight += bar.frame.size.height;
	}
	return maxHeight;
}

- (void)setTargetScrollView:(UIScrollView *)targetScrollView
{
	if (_targetScrollView != targetScrollView) {
		if (_targetScrollView) {
			[_targetScrollView removeObserver:self forKeyPath:kMMAccessoryBarContentOffsetPropertyName];
			if (_targetScrollView.delegate == self) _targetScrollView.delegate = nil;
		}
		
		_targetScrollView = targetScrollView;
		
		if (_targetScrollView) {
			// update scrollview insets
			[_targetScrollView addObserver:self forKeyPath:kMMAccessoryBarContentOffsetPropertyName options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
			if (_targetScrollView.delegate == nil) _targetScrollView.delegate = self;
			[self.targetScrollView.superview insertSubview:self aboveSubview:self.targetScrollView];
			_needsSetupConstraints = YES;
			[self.targetScrollView.superview setNeedsUpdateConstraints];
		}
	}
}

- (void)snapToScrollView:(UIScrollView *)scrollView
{
	self.targetScrollView = scrollView;

	if (!self.targetScrollView.dragging && !self.targetScrollView.decelerating) {
		CGRect frame = self.frame;
		if (frame.size.width == 0) {
			frame = self.targetScrollView.frame;
			frame.size.height = [self maxHeight];
			[super setFrame:frame];
		} else if (frame.size.height > 0 && frame.size.height < self.maxHeight) {
			CGPoint offset = self.targetScrollView.contentOffset;
			if (frame.size.height > 0 && frame.size.height < self.maxHeight / 2) {
				offset.y += frame.size.height;
				frame.size.height = 0;
			} else {
				offset.y -= (self.maxHeight - frame.size.height);
				frame.size.height = self.maxHeight;
			}
			
			[UIView beginAnimations:@"Snap" context:nil];
			[super setFrame:frame];
			[self.targetScrollView setContentOffset:offset];
			[UIView commitAnimations];
		}
	}
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	if (newSuperview == nil) {
		self.targetScrollView = nil;
	}
}

#pragma mark - Layout Constraints

- (NSLayoutConstraint *)maxHeightConstraint
{
	if (_maxHeightConstraint == nil) {
		_maxHeightConstraint = [NSLayoutConstraint constraintWithItem:self
															attribute:NSLayoutAttributeHeight
															relatedBy:NSLayoutRelationLessThanOrEqual
															   toItem:nil
															attribute:NSLayoutAttributeNotAnAttribute
														   multiplier:1.0 constant:0];
		_maxHeightConstraint.priority = 2;
		[self addConstraint:_maxHeightConstraint];
	}
	
	return _maxHeightConstraint;
}

- (NSLayoutConstraint *)heightConstraint
{
	if (_heightConstraint == nil) {
		_heightConstraint = [NSLayoutConstraint constraintWithItem:self
														 attribute:NSLayoutAttributeHeight
														 relatedBy:NSLayoutRelationEqual
															toItem:nil
														 attribute:NSLayoutAttributeNotAnAttribute
														multiplier:1.0 constant:0];
		_heightConstraint.priority = 1;
		[self addConstraint:_heightConstraint];
	}
	
	return _heightConstraint;
}

- (void)setupConstraints
{
	if (_needsSetupConstraints) {
		_needsSetupConstraints = NO;

		// create layout constraints so the panel float on top of scrollview at the same left/top/right
		NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self
																		   attribute:NSLayoutAttributeLeft
																		   relatedBy:NSLayoutRelationEqual
																			  toItem:self.targetScrollView
																		   attribute:NSLayoutAttributeLeft
																		  multiplier:1.0 constant:0];
		NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self
																			attribute:NSLayoutAttributeRight
																			relatedBy:NSLayoutRelationEqual
																			   toItem:self.targetScrollView
																			attribute:NSLayoutAttributeRight
																		   multiplier:1.0 constant:0];
		[self.superview addConstraints:@[leftConstraint, rightConstraint]];

		UIViewController *viewController = self.viewController;
		if (viewController) {
			NSLayoutConstraint * topLayoutGuideConstraint = [NSLayoutConstraint constraintWithItem:self
																					  attribute:NSLayoutAttributeTop
																					  relatedBy:NSLayoutRelationEqual
																						 toItem:viewController.topLayoutGuide
																					  attribute:NSLayoutAttributeBottom
																					 multiplier:1.0
																					   constant:0.0];
			[self.superview addConstraint:topLayoutGuideConstraint];
			
			if (viewController.navigationController) { // There is a bug in ios layout so this extra constraint is neccessary
				NSLayoutConstraint * navBarConstraint = [NSLayoutConstraint constraintWithItem:self
																							 attribute:NSLayoutAttributeTop
																							 relatedBy:NSLayoutRelationEqual
																								toItem:viewController.navigationController.navigationBar
																							 attribute:NSLayoutAttributeBottom
																							multiplier:1.0
																							  constant:0.0];
				[viewController.navigationController.view addConstraint:navBarConstraint];
			}
		} else {
			NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self
															 attribute:NSLayoutAttributeTop
															 relatedBy:NSLayoutRelationEqual
																toItem:_targetScrollView
															 attribute:NSLayoutAttributeTop
															multiplier:1.0 constant:0];
			[self.superview addConstraint:topConstraint];
		}
	}
}

#pragma mark - Layouts

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self setupConstraints];
	[self updateMaxHeight];

	// Stacks bars vertically
	CGFloat y = 0;
	CGRect bounds = self.bounds;
	for (UIView *bar in self.bars) {
		CGRect frame = CGRectMake(0, y, bounds.size.width, bar.frame.size.height);
		CGFloat bottomSpace = bounds.size.height - y - frame.size.height;
		if (bottomSpace < 0) frame.origin.y += bottomSpace;
		bar.frame = frame;
		y = CGRectGetMaxY(frame);
	}
}

- (void)updateMaxHeight
{
	CGFloat maxHeight = [self maxHeight];
	
	if (self.maxHeightConstraint.constant != maxHeight) {
		CGFloat delta = maxHeight - self.maxHeightConstraint.constant;
		self.maxHeightConstraint.constant = maxHeight;
		
		if (self.targetScrollView) {
			// schedule it to run async so the resizing does not affect current
			// runloop performance, also when everything has the updated values
			dispatch_async(dispatch_get_main_queue(), ^{

				[UIView animateWithDuration:0.2 animations:^{
					UIEdgeInsets insets = self.targetScrollView.contentInset;
					insets.top += delta;
					self.targetScrollView.contentInset = insets;
					
					/** To make the scroll indicator not overlaping the bar. We need to adjust top inset */
					UIEdgeInsets scrollIndicatorInsets = self.targetScrollView.scrollIndicatorInsets;
					scrollIndicatorInsets.top = self.targetScrollView.contentInset.top;
					self.targetScrollView.scrollIndicatorInsets = insets;
					
					if (delta > 0) // if the panel is expanded
					{
						CGPoint contentOffset = self.targetScrollView.contentOffset;
						contentOffset.y -= delta;
						if (contentOffset.y < -insets.top) contentOffset.y = -insets.top;
						self.targetScrollView.contentOffset = contentOffset;
						_adjustedOffsetY = contentOffset.y + self.targetScrollView.contentInset.top;
					}
				}];
			});
		}
		self.heightConstraint.constant = maxHeight;
	}
}

#pragma mark KVO handler

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	assert(object == _targetScrollView);
	
	if ([kMMAccessoryBarContentOffsetPropertyName isEqualToString:keyPath]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			CGFloat height;
			CGFloat adjustedOffsetY = self.targetScrollView.contentOffset.y + self.targetScrollView.contentInset.top;
			if (adjustedOffsetY != _adjustedOffsetY) {
				if (adjustedOffsetY >= 0)
				{
					if (adjustedOffsetY > self.targetScrollView.contentSize.height - self.targetScrollView.frame.size.height + self.targetScrollView.contentInset.top) // bouncing bottom
						adjustedOffsetY = self.targetScrollView.contentSize.height - self.targetScrollView.frame.size.height + self.targetScrollView.contentInset.top;
					
					CGFloat deltaY = adjustedOffsetY - _adjustedOffsetY;
					// expand or collapse the view as the superview scrolls at half the speed
					height = MAX(0.0f, MIN(self.maxHeight, self.frame.size.height - deltaY));
				} else {
					height = self.maxHeight;
				}
				_adjustedOffsetY = adjustedOffsetY;
				self.heightConstraint.constant = roundf(height);
			}
		});
	}
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	if (scrollView == _targetScrollView) {
		CGPoint currentOffset = _targetScrollView.contentOffset;
		CGPoint targetOffset = *targetContentOffset;
		
		CGFloat delta = targetOffset.y - currentOffset.y;
		CGFloat height = self.heightConstraint.constant;
		CGFloat maxHeight = self.maxHeightConstraint.constant;
		
		if (height + delta > maxHeight / 2.0) {
			if (height + delta < maxHeight) targetContentOffset->y -= maxHeight - height;
		} else {
			if (height + delta > 0)  targetContentOffset->y += height + delta + 4;
		}
	}
}

@end
