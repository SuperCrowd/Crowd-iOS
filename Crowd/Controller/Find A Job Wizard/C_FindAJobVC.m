//
//  C_FindAJobVC.m
//  Crowd
//
//  Created by MAC107 on 25/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_FindAJobVC.h"
#import "AppConstant.h"


#import "ViewFindType.h"

#import "C_TempVC.h"
@interface C_FindAJobVC ()
{
    __weak IBOutlet UIScrollView *scrlView;

}
@end

@implementation C_FindAJobVC
#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Find a Job";
    self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    scrlView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //scrlView.backgroundColor = [UIColor clearColor];
    [self setScrollViewConstraint];
    
    
    
}
-(void)setScrollViewConstraint
{
    /*--- get screen size and set scroll and view height---*/
    //CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds)-64;
    
    /*--- Scrollview Constraint ---*/
    NSDictionary *dictScrollConst       = NSDictionaryOfVariableBindings(scrlView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrlView]|" options:0 metrics:nil views:dictScrollConst]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrlView]|" options:0 metrics:nil views:dictScrollConst]];
    
    
    C_TempVC *objC_TempVC = [[C_TempVC alloc]initWithNibName:@"C_TempVC" bundle:nil];
    UIView *viewobjC_TempVC = objC_TempVC.view;
    viewobjC_TempVC.backgroundColor = [UIColor redColor];
    viewobjC_TempVC.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:objC_TempVC];
    [scrlView addSubview:viewobjC_TempVC];
    [objC_TempVC didMoveToParentViewController:self];
    
    /*--- Child ad controller width is fix ---*/
    [scrlView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[viewobjC_TempVC]|" options:0 metrics:nil views: NSDictionaryOfVariableBindings(viewobjC_TempVC)]];

    [scrlView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[viewobjC_TempVC(height)]-0-|" options:0 metrics:@{@"height":@(height-40)} views: NSDictionaryOfVariableBindings(viewobjC_TempVC)]];

}

-(void)addsubV
{
    ViewFindType *objViewFindType = [[ViewFindType alloc]initWithFrame:CGRectMake(0, 0, screenSize.size.width, 72.0)];
    objViewFindType.translatesAutoresizingMaskIntoConstraints = NO;
    objViewFindType.lblTitle.text = @"Selected Position";
    objViewFindType.lblTitle.backgroundColor = [UIColor redColor];
    objViewFindType.lblType.text = @"Computer";
    objViewFindType.lblType.backgroundColor  = [UIColor greenColor];
    objViewFindType.backgroundColor = [UIColor whiteColor];
    [scrlView addSubview:objViewFindType];
    
    /*--- ---*/
    [scrlView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[objViewFindType]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(objViewFindType)]];
    [scrlView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[objViewFindType(height)]-0-|" options:0 metrics:@{@"height":@72} views:NSDictionaryOfVariableBindings(objViewFindType)]];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)btnMenuClicked:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/*
 -(void)setScrollViewConstraint
 {
CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds)-64;

NSDictionary *dictScrollConst       = NSDictionaryOfVariableBindings(scrlView);
[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrlView(width)]|" options:0 metrics:@{@"width":@(width)} views:dictScrollConst]];

[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrlView(height)]-0-|" options:0 metrics:@{@"height":@(height)} views:dictScrollConst]];

NSDictionary *dictSelection   = NSDictionaryOfVariableBindings(viewSelect);
[scrlView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[viewSelect(width)]-0-|" options:0 metrics:@{@"width":@(width)} views:dictSelection]];
[scrlView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[viewSelect(height)]-0-|" options:0 metrics:@{@"height":@40} views:NSDictionaryOfVariableBindings(viewSelect)]];

for (UIView *v in viewSelect.subviews)
for (UIButton *btnS in v.subviews)
if ([btnS isKindOfClass:[UIButton class]])
[btnS addTarget:self action:@selector(btnTypeSelected:) forControlEvents:UIControlEventTouchUpInside];

[self btnTypeSelected:viewSelect.btnIndustry];
}

 */
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
