//
//  C_MP_SkillsVC.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_SkillsVC.h"
#import "AppConstant.h"
#import "UpdateProfile.h"
#import "C_MyProfileVC.h"
#import "DWTagList.h"
#import "C_MP_EditTagVC.h"

#import "C_MP_WorkHistoryVC.h"
@interface C_MP_SkillsVC ()<DWTagListDelegate,updateTag>
{
    __weak IBOutlet DWTagList *_tagList;
    __weak IBOutlet UILabel *lblNoTag;
    
    NSMutableArray *arrSkills;
}

@end

@implementation C_MP_SkillsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Skills";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(doneClicked)];

    arrSkills = [[NSMutableArray alloc]init];
    for (C_Model_Skills *mySkills in _obj_ProfileUpdate.arr_SkillsALL)
    {
        @try
        {
            [arrSkills addObject:mySkills.Skills];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
        }
        
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
-(void)back
{
    popView;
}
-(void)doneClicked
{
    UpdateProfile *profile = [[UpdateProfile alloc]init];
    [profile updateProfile_WithModel:_obj_ProfileUpdate withSuccessBlock:^{
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[C_MyProfileVC class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    } withFailBlock:^(NSString *strError) {
        [CommonMethods displayAlertwithTitle:strError withMessage:nil withViewController:self];
    }];
}


-(IBAction)btnEditClicked:(id)sender
{
    C_MP_EditTagVC *objC_SkillsEditVC = [[C_MP_EditTagVC alloc]initWithNibName:@"C_MP_EditTagVC" bundle:nil];
    objC_SkillsEditVC.strComingFrom = @"Skills";
    objC_SkillsEditVC.strTags = [arrSkills componentsJoinedByString:@","];
    objC_SkillsEditVC.delegate = self;
    [self.navigationController pushViewController:objC_SkillsEditVC animated:YES];
}
-(IBAction)btnNextClicked:(id)sender
{
    C_MP_WorkHistoryVC *obj = [[C_MP_WorkHistoryVC alloc]initWithNibName:@"C_MP_WorkHistoryVC" bundle:nil];
    obj.obj_ProfileUpdate = _obj_ProfileUpdate;
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
            C_Model_Skills *mySkills = [[C_Model_Skills alloc]init];
            @try
            {
                mySkills.Skills = [strSkill isNull];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            }
            @finally {
            }
            
            [arrTemp addObject:mySkills];
        }
        _obj_ProfileUpdate.arr_SkillsALL = arrTemp;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
}
#pragma mark - Tag Delegate
- (void)selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex
{
    [self btnEditClicked:nil];
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
