//
//  C_SkillsVC.m
//  Crowd
//
//  Created by MAC107 on 09/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_SkillsVC.h"
#import "AppConstant.h"
#import "DWTagList.h"
#import "C_EditTagVC.h"
#import "C_UserModel.h"

#import "C_WorkHistory.h"
#import "C_ProfilePreviewVC.h"
@interface C_SkillsVC ()<DWTagListDelegate,updateTag>
{
    __weak IBOutlet DWTagList *_tagList;
    __weak IBOutlet UILabel *lblNoTag;
    
    
    NSMutableArray *arrSkills;
}
@end

@implementation C_SkillsVC
#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Skills";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton];
    if ([[UserDefaults objectForKey:PROFILE_PREVIEW]isEqualToString:@"yes"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
    }
    
    arrSkills = [[NSMutableArray alloc]init];
    for (Skills *mySkills in myUserModel.arrSkillsUser)
    {
        [arrSkills addObject:mySkills.name];
    }
    
    if (arrSkills.count > 0)
    {
        lblNoTag.alpha = 0.0;
        //_tagList.alpha = 1.0;
        [_tagList setAutomaticResize:YES];
        
        [_tagList setTags:arrSkills];
        [_tagList setTagDelegate:self];
        
        // Customisation
        [_tagList setCornerRadius:4.0f];
        [_tagList setHighlightedBackgroundColor:RGBCOLOR_DARK_BROWN];
        [_tagList setTextColor:[UIColor blackColor]];
        [_tagList setBorderColor:RGBCOLOR_DARK_BROWN.CGColor];
        [_tagList setTagBackgroundColor:RGBCOLOR_DARK_BROWN];
        [_tagList setBorderWidth:0.0f];
        [_tagList setTextShadowOffset:CGSizeMake(0, 0)];
        
        _tagList.translatesAutoresizingMaskIntoConstraints = NO;
    }
    else
    {
        lblNoTag.alpha = 1.0;
        _tagList.alpha = 0.0;
    }
}

-(void)btnDoneClicked:(id)sender
{
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[C_ProfilePreviewVC class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

-(IBAction)btnEditClicked:(id)sender
{
    C_EditTagVC *objC_SkillsEditVC = [[C_EditTagVC alloc]initWithNibName:@"C_EditTagVC" bundle:nil];
    objC_SkillsEditVC.strComingFrom = @"Skills";
    objC_SkillsEditVC.strTags = [arrSkills componentsJoinedByString:@","];
    objC_SkillsEditVC.delegate = self;
    [self.navigationController pushViewController:objC_SkillsEditVC animated:YES];
}
-(IBAction)btnNextClicked:(id)sender
{
    C_WorkHistory *obj = [[C_WorkHistory alloc]initWithNibName:@"C_WorkHistory" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}
#pragma mark - Protocol
-(void)updateTags:(NSString *)strText
{
    [arrSkills removeAllObjects];
    arrSkills = [[strText componentsSeparatedByString:@","] mutableCopy];
    [_tagList setTags:arrSkills];
    
    @try
    {
        NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
        for (NSString *strSkill in arrSkills)
        {
            Skills *mySkills = [[Skills alloc]init];
            mySkills.name = [strSkill isNull];
            [arrTemp addObject:mySkills];
        }
        
        myUserModel.arrSkillsUser = arrTemp;
        [CommonMethods saveMyUser:myUserModel];
        myUserModel = [CommonMethods getMyUser];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        myUserModel = [CommonMethods getMyUser];
    }
    @finally {
    }
    
}
#pragma mark - Tag Delegate
- (void)selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex
{
    NSLog(@"%@",[NSString stringWithFormat:@"You tapped tag %@ at index %ld", tagName,(long)tagIndex]);
    [self btnEditClicked:nil];
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
