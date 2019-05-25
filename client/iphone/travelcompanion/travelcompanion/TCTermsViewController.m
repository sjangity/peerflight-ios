//
//  TCTermsViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 5/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCTermsViewController.h"

@interface TCTermsViewController () <UIScrollViewDelegate>

@end

@implementation TCTermsViewController
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
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Terms of Service";
    
//
//    scrollView.delegate = self;
//    scrollView.scrollEnabled = YES;
//    scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width ,[UIScreen mainScreen].bounds.size.height );

    _scrollView.delegate = self;
//    _scrollView.bounces = NO;
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:YES];
    _scrollView.contentSize = CGSizeMake(280, 2900);
    
//    _scrollView.contentSize = _contentView.frame.size;

//    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 700);
    
    [self showBackButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(closeModal)];

    [imageView addGestureRecognizer:tap];    
}

- (void)closeModal
{
    DLog(@"close modal");
    [self.popDelegate flipsideViewControllerDidFinish:self];

//    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    DLog(@"Scroll view did scroll....");
//    if (_scrollView.contentOffset.y > 0)
//        _scrollView.contentOffset = CGPointMake(0, _scrollView.contentOffset.y);
    
//    if (_scrollView.contentOffset.y>_contentView.frame.origin.x) {
//        _scrollView.contentOffset = CGPointMake(0, 0);
//    }
}

- (void)showBackButton
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self  action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
