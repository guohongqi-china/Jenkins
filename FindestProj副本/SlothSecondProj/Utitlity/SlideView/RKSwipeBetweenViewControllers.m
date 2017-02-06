//
//  RKSwipeBetweenViewControllers.m
//  RKSwipeBetweenViewControllers
//
//  Created by Richard Kim on 7/24/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for regular updates

#import "RKSwipeBetweenViewControllers.h"
#import "UIViewExt.h"

//%%% customizeable button attributes
CGFloat X_BUFFER = 0.0; //%%% the number of pixels on either side of the segment
CGFloat Y_BUFFER = 0.0; //%%% number of pixels on top of the segment
CGFloat HEIGHT = 42.0; //%%% height of the segment

//%%% customizeable selector bar attributes (the black bar under the buttons)
CGFloat BOUNCE_BUFFER = 10.0; //%%% adds bounce to the selection bar when you scroll
CGFloat ANIMATION_SPEED = 0.2; //%%% the number of seconds it takes to complete the animation
CGFloat SELECTOR_Y_BUFFER = 40.0; //%%% the y-value of the bar that shows what page you are on (0 is the top)
CGFloat SELECTOR_HEIGHT = 2.0; //%%% thickness of the selector bar

CGFloat X_OFFSET = 0.0; //%%% for some reason there's a little bit of a glitchy offset.  I'm going to look for a better workaround in the future
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface RKSwipeBetweenViewControllers ()
{
    UIView *viewLine;
}

@property (nonatomic) UIScrollView *pageScrollView;
@property (nonatomic) BOOL isPageScrollingFlag; //%%% prevents scrolling / segment tap crash

@end

@implementation RKSwipeBetweenViewControllers
@synthesize viewControllerArray;
@synthesize selectionBar;
@synthesize pageController;
@synthesize navigationView;
@synthesize buttonText;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        viewControllerArray = [NSMutableArray array];
    }
    return self;
}

- (void)initView
{
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.view.frame = CGRectMake(0, 42, kScreenWidth, kScreenHeight);
    self.pageController.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [self addSubview:self.pageController.view];
    
    self.isPageScrollingFlag = NO;
    self.hasAppearedFlag = NO;
    self.pageScrollView.scrollsToTop = NO;
    
    [self viewWillAppear:YES];
    [self updateCurrentPageIndex:0];
}

- (void)refreshSkin
{
    self.pageController.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    navigationView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    for (int i=0; i<self.viewControllerArray.count; i++)
    {
        UIButton *button = [navigationView viewWithTag:i+1000];
        [button setTitleColor:[SkinManage colorNamed:@"Share_Swipe_Title_H"] forState:UIControlStateSelected];
        [button setTitleColor:[SkinManage colorNamed:@"Share_Swipe_Title"] forState:UIControlStateNormal];
    }
}

#pragma mark Customizables

//%%% color of the status bar
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//%%% sets up the tabs using a loop.  You can take apart the loop to customize individual buttons, but remember to tag the buttons.  (button.tag=0 and the second button.tag=1, etc)
-(void)setupSegmentButtons
{
    navigationView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width,42)];
    navigationView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    [self addSubview:navigationView];
    
    NSInteger numControllers = [viewControllerArray count];
    if (!buttonText)
    {
        buttonText = [[NSArray alloc]initWithObjects: @"first",@"second",@"third",@"fourth",@"etc",@"etc",@"etc",@"etc",nil]; //%%%buttontitle
    }
    
    for (int i = 0; i<numControllers; i++) {
        //UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(X_BUFFER+i*(self.frame.size.width-2*X_BUFFER)/numControllers-X_OFFSET, Y_BUFFER, (self.frame.size.width-2*X_BUFFER)/numControllers, HEIGHT)];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((self.frame.size.width-numControllers*self.fItemWidth)/2+i*self.fItemWidth, Y_BUFFER, self.fItemWidth, HEIGHT)];
        [navigationView addSubview:button];
        
        button.tag = 1000+i; //%%% IMPORTANT: if you make your own custom buttons, you have to tag them appropriately
        
        [button addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setTitleColor:[SkinManage colorNamed:@"Share_Swipe_Title_H"] forState:UIControlStateSelected];
        [button setTitleColor:[SkinManage colorNamed:@"Share_Swipe_Title"] forState:UIControlStateNormal];
        [button setTitle:[buttonText objectAtIndex:i] forState:UIControlStateNormal]; //%%%buttontitle
        
        button.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    
    //seperate line
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 41.5, kScreenWidth, 0.5)];
    viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [navigationView addSubview:viewLine];
    
    [self setupSelector];
}

//%%% sets up the selection bar under the buttons on the navigation bar
//设置选择器颜色
-(void)setupSelector
{
    selectionBar = [[UIView alloc]initWithFrame:CGRectMake(0, SELECTOR_Y_BUFFER,self.fSelectionWidth, SELECTOR_HEIGHT)];
    UIButton *button = [navigationView viewWithTag:self.currentPageIndex+1000];
    selectionBar.center = CGPointMake(button.center.x, selectionBar.center.y);
    
    selectionBar.backgroundColor = COLOR(239, 111, 88, 1.0); //%%% sbcolor
    selectionBar.alpha = 1.0; //%%% sbalpha
    [navigationView addSubview:selectionBar];
}

//generally, this shouldn't be changed unless you know what you're changing
#pragma mark Setup
-(void)viewWillAppear:(BOOL)animated
{
    if (!self.hasAppearedFlag)
    {
        [self setupPageViewController];
        [self setupSegmentButtons];
        self.hasAppearedFlag = YES;
    }
}

//%%% generic setup stuff for a pageview controller.  Sets up the scrolling style and delegate for the controller
-(void)setupPageViewController
{
    pageController.navigationController.navigationBar.hidden = YES;
    pageController.delegate = self;
    pageController.dataSource = self;
    [pageController setViewControllers:@[[viewControllerArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self syncScrollView];
}

//%%% this allows us to get information back from the scrollview, namely the coordinate information that we can link to the selection bar.
-(void)syncScrollView
{
    for (UIView* view in pageController.view.subviews)
    {
        if([view isKindOfClass:[UIScrollView class]])
        {
            self.pageScrollView = (UIScrollView *)view;
            self.pageScrollView.delegate = self;
            self.pageScrollView.scrollsToTop = NO;
        }
    }
}
- (void)changtuFirst{
    UIButton *button = [self viewWithTag:1000];
    [self tapSegmentButtonAction:button];
}

//%%% methods called when you tap a button or scroll through the pages
// generally shouldn't touch this unless you know what you're doing or
// have a particular performance thing in mind

#pragma mark Movement

//%%% when you tap one of the buttons, it shows that page,
//but it also has to animate the other pages to make it feel like you're crossing a 2d expansion,
//so there's a loop that shows every view controller in the array up to the one you selected
//eg: if you're on page 1 and you click tab 3, then it shows you page 2 and then page 3
-(void)tapSegmentButtonAction:(UIButton *)button
{
    NSInteger nBtnTag = button.tag - 1000;
    
    if (!self.isPageScrollingFlag)
    {
        NSInteger tempIndex = self.currentPageIndex;
        __weak typeof(self) weakSelf = self;
        
        //%%% check to see if you're going left -> right or right -> left
        if (nBtnTag > tempIndex)
        {
            //%%% scroll through all the objects between the two points
            for (int i = (int)tempIndex+1; i<=nBtnTag; i++)
            {
                [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL complete){
                    //%%% if the action finishes scrolling (i.e. the user doesn't stop it in the middle),
                    //then it updates the page that it's currently on
                    if (complete)
                    {
                        [weakSelf updateCurrentPageIndex:i];
                    }
                }];
            }
        }
        
        //%%% this is the same thing but for going right -> left
        else if (nBtnTag < tempIndex)
        {
            for (int i = (int)tempIndex-1; i >= nBtnTag; i--)
            {
                [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL complete){
                    if (complete)
                    {
                        [weakSelf updateCurrentPageIndex:i];
                    }
                }];
            }
        }
    }
}

//%%% makes sure the nav bar is always aware of what page you're on
//in reference to the array of view controllers you gave
-(void)updateCurrentPageIndex:(NSUInteger)newIndex
{
    self.currentPageIndex = newIndex;
    
    for (int i=0; i<self.viewControllerArray.count; i++)
    {
        UIButton *button = [navigationView viewWithTag:i+1000];
        if (i == newIndex)
        {
            button.selected = YES;
        }
        else
        {
            button.selected = NO;
        }
    }
    
    [self.navDelegate pageIndexChanged:self.currentPageIndex];
}

//%%% method is called when any of the pages moves.
//It extracts the xcoordinate from the center point and instructs the selection bar to move accordingly
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //Page的scrollView的偏移乘以button宽带，得到滑块的偏移量
    CGFloat fFromCenter = (self.frame.size.width-scrollView.contentOffset.x)*-1; //%%% positive for right swipe, negative for left
    CGFloat fSelectionOffset = (fFromCenter/kScreenWidth)*self.fItemWidth;
    UIButton *button = [navigationView viewWithTag:self.currentPageIndex+1000];
    selectionBar.center = CGPointMake(button.center.x+fSelectionOffset, selectionBar.center.y);
}

#pragma mark - Page View Controller Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [viewControllerArray indexOfObject:viewController];
    if ((index == NSNotFound) || (index == 0))
    {
        return nil;
    }
    index--;
    
    return [viewControllerArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [viewControllerArray indexOfObject:viewController];
    if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    
    if (index == [viewControllerArray count])
    {
        return nil;
    }
    
    return [viewControllerArray objectAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed)
    {
        [self updateCurrentPageIndex:[viewControllerArray indexOfObject:[pageViewController.viewControllers lastObject]]];
    }
}

#pragma mark - Scroll View Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isPageScrollingFlag = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isPageScrollingFlag = NO;
}

@end
