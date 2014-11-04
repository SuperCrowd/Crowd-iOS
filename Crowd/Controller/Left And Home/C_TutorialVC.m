//
//  C_TutorialVC.m
//  Crowd
//
//  Created by MAC107 on 19/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_TutorialVC.h"
#import "AppConstant.h"
#import "C_DashBoardVC.h"
#import "C_LeftMenuVC.h"

typedef NS_ENUM(NSInteger, btnNext) {
    Tutorial_1 = 1,
    Tutorial_2 = 2,
    Tutorial_3 = 3,
    Tutorial_4 = 4
    //Tutorial_5 = 5

};

@interface C_TutorialVC ()<UIScrollViewDelegate>
{
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIPageControl *pageControl;
    
    IBOutlet UIView *view1;
    IBOutlet UIView *view2;
    IBOutlet UIView *view3;
    IBOutlet UIView *view4;
    //IBOutlet UIView *view5;

    
    /*--- For view 1 only ---*/
    IBOutlet NSLayoutConstraint *constraint_btnNextBottom_1;
    __weak IBOutlet UILabel *lbl_Static_Crowd_1;
}
@end

@implementation C_TutorialVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*--- Disable mask constraint ---*/
    self.automaticallyAdjustsScrollViewInsets = NO;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    view1.translatesAutoresizingMaskIntoConstraints = NO;
    view2.translatesAutoresizingMaskIntoConstraints = NO;
    view3.translatesAutoresizingMaskIntoConstraints = NO;
    view4.translatesAutoresizingMaskIntoConstraints = NO;
    //view5.translatesAutoresizingMaskIntoConstraints = NO;

    
    view1.backgroundColor = [UIColor clearColor];
    view2.backgroundColor = [UIColor clearColor];
    view3.backgroundColor = [UIColor clearColor];
    view4.backgroundColor = [UIColor clearColor];
   // view5.backgroundColor = [UIColor clearColor];

//    UILabel *lbl = [[UILabel alloc]init];
//    lbl.layer.cornerRadius
    
    /*--- add views ---*/
    [self.view addSubview:scrollView];
    
    
    [scrollView addSubview:view1];
    [scrollView addSubview:view2];
    [scrollView addSubview:view3];
    [scrollView addSubview:view4];
    //[scrollView addSubview:view5];

    [self.view bringSubviewToFront:pageControl];
    /*--- setup scrollview ---*/
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    [self setFonts];
    [self setScrollViewConstraint];
}
-(void)setFonts
{
    lbl_Static_Crowd_1.font = kFONT_OSWALD(50.0);
    if (IS_DEVICE_iPHONE_5)
    {
        constraint_btnNextBottom_1.constant = 55.0;
    }
}
-(void)setScrollViewConstraint
{
    /*--- get screen size and set scroll and view height---*/
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    /*--- Scrollview Constraint ---*/
    NSDictionary *dictScrollConst       = NSDictionaryOfVariableBindings(scrollView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView(width)]|" options:0 metrics:@{@"width":@(width)} views:dictScrollConst]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView(height)]|" options:0 metrics:@{@"height":@(height)} views:dictScrollConst]];
    
    /*--- Subviews Constraint ---*/
    NSDictionary *viewsDictionary   = NSDictionaryOfVariableBindings(view1, view2, view3, view4);
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view1(width)]-0-[view2(width)]-0-[view3(width)]-0-[view4(width)]-0-|" options:0 metrics:@{@"width":@(width)} views:viewsDictionary]];
    
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view1(height)]-0-|" options:0 metrics:@{@"height":@(height)} views:NSDictionaryOfVariableBindings(view1)]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view2(height)]-0-|" options:0 metrics:@{@"height":@(height)} views:NSDictionaryOfVariableBindings(view2)]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view3(height)]-0-|" options:0 metrics:@{@"height":@(height)} views:NSDictionaryOfVariableBindings(view3)]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view4(height)]-0-|" options:0 metrics:@{@"height":@(height)} views:NSDictionaryOfVariableBindings(view4)]];

}

-(IBAction)btnNextClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btnNext btnSelected = btn.tag;
    switch (btnSelected) {
        case Tutorial_1:
            pageControl.currentPage = 1;
            [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width*1, 0) animated:YES];
            break;
        case Tutorial_2:
            pageControl.currentPage = 2;
            [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width*2, 0) animated:YES];
            break;
        case Tutorial_3:
            pageControl.currentPage = 3;
            [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width*3, 0) animated:YES];

            break;
        case Tutorial_4:
            //pageControl.currentPage = 4;
            //[scrollView setContentOffset:CGPointMake(scrollView.frame.size.width*4, 0) animated:YES];
            [self pushToHome];
            break;
        //case Tutorial_5:
            //go to job posting
            
            break;
            
        default:
            break;
    }
}
-(void)pushToHome
{
//    self.navigationController.navigationBarHidden = YES;
    C_DashBoardVC *objDashBoardVC = [[C_DashBoardVC alloc] initWithNibName:@"C_DashBoardVC" bundle:nil];
    objDashBoardVC.isGointToJobPostVC = YES;
    C_LeftMenuVC *objleftVC = [[C_LeftMenuVC alloc] initWithNibName:@"C_LeftMenuVC" bundle:nil];
    
    /*--- Init navigation ---*/
    UINavigationController *_navC = [[UINavigationController alloc] initWithRootViewController:objDashBoardVC];
    _navC.navigationBarHidden = YES;
    _navC.navigationBar.translucent = NO;
    /*--- Right controller ---*/
    MMDrawerController *drawerController = [[MMDrawerController alloc]
                                            initWithCenterViewController:_navC
                                            leftDrawerViewController:objleftVC
                                            rightDrawerViewController:nil];
    [drawerController setShowsShadow:NO];
    [drawerController setRestorationIdentifier:@"MMDrawer"];
    [drawerController setMaximumLeftDrawerWidth:screenSize.size.width-45.0];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [drawerController setShouldStretchDrawer:NO];

    [drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    selectedLeftControllerIndex = 0;
    [self.navigationController pushViewController:drawerController animated:NO];
}

#pragma mark - Scroll Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollViewD {
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollViewD.frame.size.width;
    float fractionalPage = scrollViewD.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        // Page has changed, do your thing!
        // ...
        // Finally, update previous page
        previousPage = page;
        pageControl.currentPage = previousPage;
    }
}

#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
