//
//  C_DashBoardVC.m
//  Crowd
//
//  Created by MAC107 on 18/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_DashBoardVC.h"
#import "AppConstant.h"
#import "C_PostJob_NameVC.h"
@interface C_DashBoardVC ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
}
@end

@implementation C_DashBoardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home";
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    
    
    if (_isGointToJobPostVC)
    {
        C_PostJob_NameVC *obj = [[C_PostJob_NameVC alloc]initWithNibName:@"C_PostJob_NameVC" bundle:nil];
        obj.isComeFromTutorial = YES;
        [self.navigationController pushViewController:obj animated:NO];
        return;
    }
}


-(void)btnMenuClicked:(id)sender
{
//    [UserDefaults removeObjectForKey:APP_USER_INFO];
//    [UserDefaults removeObjectForKey:PROFILE_PREVIEW];
//    [UserDefaults synchronize];
//    
//    [appDel.navC popToRootViewControllerAnimated:YES];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Table Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        /*--- For Custom Cell ---*/
        //[[NSBundle mainBundle]loadNibNamed:@"" owner:self options:nil];
        //cell = myCell;
    }
    cell.textLabel.text = @"Dashboard";
    return cell;
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
