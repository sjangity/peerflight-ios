//
//  SpringTransitioningDelegate.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 5/18/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "SpringTransitioningDelegate.h"
#import "PresentingSpringAnimator.h"
#import "LinearDismissalAnimator.h"
#import "DynamicDismissalAnimator.h"

@implementation SpringTransitioningDelegate
- (id)initWithDelegate:(UIViewController *)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.transitioningDirection = TransitioningDirectionLeft;
    }
    return self;
}

- (void)presentViewController:(UIViewController *)modalViewController
{
    modalViewController.modalPresentationStyle = UIModalPresentationCustom;
    modalViewController.transitioningDelegate = self;
    [self.delegate presentViewController:modalViewController animated:YES completion:^{
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [modalViewController.view addGestureRecognizer:gestureRecognizer];
    }];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    PresentingSpringAnimator *animator = [[PresentingSpringAnimator alloc] initWithTransitioningDirection:[self convertedTransitioningDirection]];
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    id<UIViewControllerAnimatedTransitioning> animator;
    if (self.interactive)
        animator = [[LinearDismissalAnimator alloc] initWithTransitioningDirection:[self convertedTransitioningDirection]];
    else
        animator = [[DynamicDismissalAnimator alloc] initWithTransitioningDirection:[self convertedTransitioningDirection]];
    return animator;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if (self.interactive) {
        self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
        return self.interactiveTransition;
    }
    return nil;
}


- (void)handleGesture:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            self.interactive = YES;
            [self.delegate dismissViewControllerAnimated:YES completion:^{
                self.interactive = NO;
            }];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            UIView *containerView = gesture.view.superview;
            CGPoint translation = [gesture translationInView:containerView];
            CGFloat percent = [self percentForTranslation:translation inFrame:containerView.frame];
            [self.interactiveTransition updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            if (self.interactiveTransition.percentComplete > 0.25)
                [self.interactiveTransition finishInteractiveTransition];
            else
                [self.interactiveTransition cancelInteractiveTransition];
            break;
        }
        case UIGestureRecognizerStateCancelled:{
            [self.interactiveTransition cancelInteractiveTransition];
            break;
        }
        default:
            break;
    }
}

- (CGFloat)percentForTranslation:(CGPoint)translation inFrame:(CGRect)frame
{
    CGFloat percent;
    TransitioningDirection convertedDirection = [self convertedTransitioningDirection];
    if (convertedDirection == TransitioningDirectionDown || convertedDirection == TransitioningDirectionUp) {
        percent = translation.y/CGRectGetHeight(frame);
    } else {
        percent = translation.x/CGRectGetWidth(frame);
    }
    
    if (convertedDirection == TransitioningDirectionUp || convertedDirection == TransitioningDirectionLeft)
        percent *= -1.0f;
    
    return percent;
}

- (TransitioningDirection)convertedTransitioningDirection
{
    TransitioningDirection direction;
    switch([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            direction = self.transitioningDirection;
            break;
        case UIDeviceOrientationLandscapeLeft:
            direction = (self.transitioningDirection + 3) % kTransitionDirectionCount;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            direction = (self.transitioningDirection + 2) % kTransitionDirectionCount;
            break;
        case UIDeviceOrientationLandscapeRight:
            direction = (self.transitioningDirection + 1) % kTransitionDirectionCount;
            break;
        default:
            direction = self.transitioningDirection;
            break;
    }
    
    return direction;
}

@end
