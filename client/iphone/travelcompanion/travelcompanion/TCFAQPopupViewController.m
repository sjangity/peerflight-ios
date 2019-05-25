//
//  TCFAQPopupViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 5/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCFAQPopupViewController.h"

@interface TCFAQPopupViewController () <UIScrollViewDelegate>

@end

@implementation TCFAQPopupViewController
@synthesize scrollView=_scrollView;
@synthesize imageView;
@synthesize popDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _scrollView.delegate = self;
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:YES];
    _scrollView.contentSize = CGSizeMake(280, 1010);

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(closeModal)];

    [imageView addGestureRecognizer:tap];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    DLog(@"Scroll view did scroll....");
}

- (void)closeModal
{
    DLog(@"close modal");
    [self.popDelegate flipsideViewControllerDidFinish:self];

//    [self dismissViewControllerAnimated:YES completion:nil];

}
//
//- (IBAction)closeModal:(id)sender
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

@end
