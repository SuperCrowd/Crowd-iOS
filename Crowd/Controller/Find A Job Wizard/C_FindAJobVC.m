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

#import "C_FindAJobListingVC.h"

@interface C_FindAJobVC ()<TypeSelectedDelegate>
{
    NSMutableDictionary *dictFindAJob;
    
    
    __weak IBOutlet UIScrollView *scrlView;

    __weak IBOutlet UIButton *btnAddCriteria;
    
    __weak IBOutlet UIView *viewContainer;

    __weak IBOutlet ViewFindType *vIndustry_1;
    __weak IBOutlet ViewFindType *vIndustry_2;
    __weak IBOutlet ViewFindType *vPosition;
    __weak IBOutlet ViewFindType *vExperience;
    __weak IBOutlet ViewFindType *vLocation;
    __weak IBOutlet ViewFindType *vCompany;
    
    
    IBOutlet NSLayoutConstraint *con_Height;

    CGFloat yAxis;
    NSLayoutConstraint *constraintY;

    BOOL isIndustry1;
    NSArray *arrC;
}
@end

@implementation C_FindAJobVC
#pragma mark - View Did Load
-(void)CancelClicked
{
}
-(void)btnCancelShow:(BOOL)show
{
    if (show)
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(CancelClicked)];
    else
        self.navigationItem.rightBarButtonItem = nil;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Find a Job";
    self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    
    /*--- Do not show cancel button ---*/
    [self btnCancelShow:NO];
    
    
    C_FindAJobListingVC *obj = [[C_FindAJobListingVC alloc]initWithNibName:@"C_FindAJobListingVC" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    
    
    return;
    
    
    
    
    /*--- save all local data in dict ---*/
    dictFindAJob = [[NSMutableDictionary alloc]init];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    scrlView.translatesAutoresizingMaskIntoConstraints = NO;
    viewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    btnAddCriteria.translatesAutoresizingMaskIntoConstraints = NO;
    vIndustry_1.translatesAutoresizingMaskIntoConstraints = NO;
    vIndustry_2.translatesAutoresizingMaskIntoConstraints = NO;
    vPosition.translatesAutoresizingMaskIntoConstraints = NO;
    vExperience.translatesAutoresizingMaskIntoConstraints = NO;
    vLocation.translatesAutoresizingMaskIntoConstraints = NO;
    vCompany.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    /*--- Default settings ---*/
    con_Height.constant = 0.0;// viewcontainer height is zero
    yAxis = 0.0; // default yaxis is 0
    isIndustry1 = YES; // is industry select1
    [self setScrollViewConstraint:YES];// add constraint and add childview
}

-(void)setScrollViewConstraint:(BOOL)firsttime
{
    btnAddCriteria.alpha = 0.0;
    
    /*--- get screen size and set scroll and view height---*/
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds)-64.0;
        
    C_TempVC *objC_TempVC = [[C_TempVC alloc]initWithNibName:@"C_TempVC" bundle:nil];
    objC_TempVC.isFirstTime = firsttime;
    objC_TempVC.delegate = self;
    UIView *viewobjC_TempVC = objC_TempVC.view;
    [self addChildViewController:objC_TempVC];
    [scrlView addSubview:viewobjC_TempVC];
    [objC_TempVC didMoveToParentViewController:self];
    
    viewobjC_TempVC.translatesAutoresizingMaskIntoConstraints = NO;

    
    /*--- Set Child view constraint with Scrollview constraint ---*/
    
    NSDictionary *dictScrollConst = NSDictionaryOfVariableBindings(scrlView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrlView(width)]|" options:0 metrics:@{@"width":@(width)} views:dictScrollConst]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrlView(height)]|" options:0 metrics:@{@"height":@(height)} views:dictScrollConst]];
    
    
    /*--- when screen open first time show full length view for child after that specific height ---*/
    if (firsttime)
    {
       [scrlView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[viewobjC_TempVC]|" options:0 metrics:nil views: NSDictionaryOfVariableBindings(viewobjC_TempVC)]];

        arrC = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[viewobjC_TempVC(height)]" options:0 metrics:@{@"yAxis":@(yAxis),@"height":@(height)} views: NSDictionaryOfVariableBindings(scrlView,viewobjC_TempVC)];
        [scrlView addConstraints:arrC];
    }
    
    else
    {
        con_Height.constant = con_Height.constant - 29.0;// add criteria button remove height
        
        [scrlView removeConstraints:arrC];// remove old constraint
        
        
        /*--- add constraint for set bottom frame to view default = 0 ---*/
        arrC = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(yAxis)-[viewobjC_TempVC(height)]-0-|" options:0 metrics:@{@"yAxis":@(yAxis),@"height":@(height-40.0)} views: NSDictionaryOfVariableBindings(viewobjC_TempVC)];
        [scrlView addConstraints:arrC];
    }
    
    
    vIndustry_1.lblTitle.adjustsFontSizeToFitWidth = YES;
    vIndustry_2.lblTitle.adjustsFontSizeToFitWidth = YES;
    vPosition.lblTitle.adjustsFontSizeToFitWidth = YES;
    vCompany.lblTitle.adjustsFontSizeToFitWidth = YES;
    vExperience.lblTitle.adjustsFontSizeToFitWidth = YES;
    vLocation.lblTitle.adjustsFontSizeToFitWidth = YES;
    
    vIndustry_1.lblType.adjustsFontSizeToFitWidth = YES;
    vIndustry_2.lblType.adjustsFontSizeToFitWidth = YES;
    vPosition.lblType.adjustsFontSizeToFitWidth = YES;
    vCompany.lblType.adjustsFontSizeToFitWidth = YES;
    vExperience.lblType.adjustsFontSizeToFitWidth = YES;
    vLocation.lblType.adjustsFontSizeToFitWidth = YES;

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
-(IBAction)btnAddCriteriaClicked:(id)sender
{
    [self setScrollViewConstraint:NO];
}

#pragma mark -
#pragma mark - Custom Delegate
-(void)IndustrySelected:(NSString *)industryName
{
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    //CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds)-64;

    NSLog(@"Industry : %@",industryName);
    
    if (isIndustry1)
    {
        vIndustry_1.lblTitle.text = @"Selected Industy";
        vIndustry_1.lblTitle.backgroundColor = [UIColor redColor];
        vIndustry_1.lblType.text = industryName;
        vIndustry_1.lblType.backgroundColor  = [UIColor greenColor];
        vIndustry_1.backgroundColor = [UIColor purpleColor];
        
        isIndustry1 = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            con_Height.constant = 72.0 + 29.0;
            vIndustry_1.alpha = 0.0;
            vIndustry_1.frame = CGRectMake(0.0, 0.0, 320, 72.0);
            btnAddCriteria.alpha = 0.0;
            yAxis = 72.0;
            btnAddCriteria.frame = CGRectMake((width/2)-107.0, yAxis, 214.0, 29.0);
            [UIView animateWithDuration:0.5 animations:^{
                vIndustry_1.alpha = 1.0;
                btnAddCriteria.alpha = 1.0;
                
            } completion:^(BOOL finished) {
            }];
        });
    }
    
     else
     {
         vIndustry_2.lblTitle.text = @"Selected Industy";
         vIndustry_2.lblTitle.backgroundColor = [UIColor redColor];
         vIndustry_2.lblType.text = industryName;
         vIndustry_2.lblType.backgroundColor  = [UIColor greenColor];
         vIndustry_2.backgroundColor = [UIColor purpleColor];
         
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             
             NSLog(@"done");
             con_Height.constant = 144.0 + 29.0;

             vIndustry_2.alpha = 0.0;
             vIndustry_2.frame = CGRectMake(0, yAxis, 320, 72.0);
             btnAddCriteria.alpha = 0.0;
             yAxis = 144.0;
             btnAddCriteria.frame = CGRectMake((width/2)-107, yAxis, 214, 29.0);
             

             [UIView animateWithDuration:0.5 animations:^{
                 vIndustry_2.alpha = 1.0;
                 btnAddCriteria.alpha = 1.0;
                 
             } completion:^(BOOL finished) {
             }];
         });
     }

}
-(void)updateContentOffsetWhenSelectTextfield
{
    [scrlView setContentOffset:CGPointMake(0, scrlView.contentSize.height-scrlView.frame.size.height) animated:YES];
}

#pragma mark - Extra
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
