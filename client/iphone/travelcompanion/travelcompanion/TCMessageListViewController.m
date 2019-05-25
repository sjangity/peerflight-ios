//
//  TCMessageListViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/20/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCMessageListViewController.h"

#import "TCSyncManager.h"
#import "TCCoreDataController.h"
#import "Person.h"
//#import "TCMessageContentTableViewController.h"

#define CONTENT_VIEW_HEIGHT     300
#define CONTENT_VIEW_SPACING    0
#define SCROLL_VIEW_PADDING     0

#define FIRST_PAGE              0
#define LAST_PAGE               self.numberOfPages - 1

#define TITLE                   @"Messages"

@interface TCMessageListViewController ()

//@property (nonatomic, assign) NSArray *contentVCs;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) BOOL pageControlUsed;

@end

@implementation TCMessageListViewController

//@synthesize contentVCs;
@synthesize numberOfPages;
@synthesize pageControlUsed;
@synthesize pageControls;
@synthesize contentScrollView;
@synthesize contentVCs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = TITLE;

    self.numberOfPages = [self.contentVCs count];
    
    pageControls.numberOfPages = self.numberOfPages;
    pageControls.currentPageIndicatorTintColor = [UIColor blackColor];
//    pageControls.backgroundColor = [UIColor lightGrayColor];
    
    [self setupContentViews];
    
//    [self.view exploreViewAtLevel:1];
//    [self.view logViewHierarchy];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( !pageControlUsed )
    {
        CGFloat pageWidth = contentScrollView.frame.size.width;
        int page = floor((contentScrollView.contentOffset.x - pageWidth / 2 ) / pageWidth) + 1;
        pageControls.currentPage = page;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
    [self changeContentPage:pageControls];
}

#pragma mark -
#pragma mark Methods

- (void)setupContentViews
{
//    contentScrollView.contentSize = CGSizeMake(( self.numberOfPages * ([UIScreen mainScreen].bounds.size.width - 2 * SCROLL_VIEW_PADDING) ) + ( self.numberOfPages + 1 ) * CONTENT_VIEW_SPACING, [UIScreen mainScreen].bounds.size.height) ;
    [contentScrollView setContentSize:CGSizeMake(( self.numberOfPages * ([UIScreen mainScreen].bounds.size.width - 2 * SCROLL_VIEW_PADDING) ) + ( self.numberOfPages + 1 ) * CONTENT_VIEW_SPACING, contentScrollView.frame.size.height)];

//    [contentScrollView setShowsVerticalScrollIndicator:NO];
    [contentScrollView setPagingEnabled:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//if(pinch.state == UIGestureRecognizerStateBegan) contentScrollView.panGestureRecognizer.enabled = NO;
//if(pinch.state == UIGestureRecognizerStateEnded) contentScrollView.panGestureRecognizer.enabled = YES;
    
    for( int i = 0; i < self.numberOfPages; i++ )
    {
        UIView *contentView = ((UIViewController *)[self.contentVCs objectAtIndex:i]).view;
        contentView.frame = CGRectMake( ((i+1) * CONTENT_VIEW_SPACING) + i * contentView.frame.size.width, SCROLL_VIEW_PADDING, contentView.frame.size.width, contentView.frame.size.height);
        
        [contentScrollView addSubview:contentView];
    }
}

#pragma mark Gesture recognizer
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
//    if(event.allTouches.count > 2)panGestureRecognizer.enabled = NO;
//}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
//    if(event.allTouches.count > 2)panRecognizer.enabled = YES;
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer {
    DLog(@"inside gesture recognizer");
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
        CGPoint velocity = [panRecognizer velocityInView:contentScrollView];
        return ABS(velocity.x) > ABS(velocity.y); // Horizontal panning
        //return ABS(velocity.x) < ABS(velocity.y); // Vertical panning
    } else {
        return YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    DLog(@"Touch begain");
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    DLog(@"Touch Moved");

}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    DLog(@"Touch Ended");

}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    DLog(@"Touch Cancelled");

}

#pragma mark
#pragma mark Actions

- (IBAction)changeContentPage:(id)sender
{
    DLog(@"Changing content page");
    CGRect pageRect;
    UIView *contentView = ((UIViewController *)[self.contentVCs objectAtIndex:pageControls.currentPage]).view;
    NSInteger currentPage = pageControls.currentPage;
    
    if( pageControls.currentPage == FIRST_PAGE || pageControls.currentPage == LAST_PAGE )
    {
        pageRect = CGRectMake( (currentPage * CONTENT_VIEW_SPACING) + currentPage *  contentView.frame.size.width, contentScrollView.frame.origin.y , contentScrollView.frame.size.width, contentScrollView.frame.size.height);
    }
    else
    {
        pageRect = CGRectMake( (currentPage * CONTENT_VIEW_SPACING) + currentPage *  contentView.frame.size.width - CONTENT_VIEW_SPACING, contentScrollView.frame.origin.y , contentScrollView.frame.size.width, contentScrollView.frame.size.height);
    }
//    DLog(@"page rect = %@", NSStringFromCGRect(pageRect));
    [contentScrollView scrollRectToVisible:pageRect animated:YES];
}

@end