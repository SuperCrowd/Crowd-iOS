//
//  MainViewController.m
//  dynamicTable
//
//  Created by Mac009 on 9/29/14.
//  Copyright (c) 2014 Tatva. All rights reserved.
//

#import "MainViewController.h"
#import "ContactsViewController.h"
#import "JobCell.h"
#import "UIActionSheet+Blocks.h"
#import "AppConstant.h"

#import "C_Find_CandidateListingVC.h"
#import "C_FindAJobListingVC.h"

#import "ContactsViewController.h"
#import "ContactModel.h"

#define MARGINIP4 0
#define MARGINIP5 0
@interface MainViewController ()<ContactsDelegate>
{
    NSMutableArray *arrResults;
    IBOutlet UITableView *tblCategory;
    IBOutlet UIView *viewinstruction;
    IBOutlet UIView *viewBtnCriteria;
    ContactsViewController *childContacts;
    NSMutableDictionary *dictCriteria;
    NSArray *arrViews;
    IBOutlet NSLayoutConstraint *hieghtTblView;
    IBOutlet UIButton *btnSearch;
    BOOL isEditMode;
}

@end

@implementation MainViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
}
-(void)btnMenuClicked:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isForCandidate)
        self.title = @"Find a Candidate";
    else
        self.title = @"Find a Job";
    self.navigationItem.leftBarButtonItem =  [CommonMethods leftMenuButton:self withSelector:@selector(btnMenuClicked:)];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    arrResults = [[NSMutableArray alloc]init];
    tblCategory.tableFooterView = viewBtnCriteria;
    dictCriteria = [[NSMutableDictionary alloc]init];
    //self.isForCandidate = YES;
    
    if (self.isForCandidate) {
            arrViews = @[@"Industry",@"Experience",@"Location",@"Company"];
    }
    else{
            arrViews = @[@"Industry",@"Position",@"Experience",@"Location",@"Company"];
    }
    [arrViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [dictCriteria setValue:[[NSMutableArray alloc] init] forKey:arrViews[idx]];
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self btnAddCriteriaPressed:nil];
    });
}


- (void)viewDidLayoutSubviews{
    [tblCategory layoutIfNeeded];
}

-(void)btnCanCelAllPressed
{
    if (ios8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"if you leave your search criteria will be lost. This can not be undone." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* CancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel  handler:^(UIAlertAction * action)
                                       {
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                       }];
        [alert addAction:CancelAction];
        
        UIAlertAction* LeaveAction = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                      {
                                          [self removeAllData];
                                      }];
        [alert addAction:LeaveAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"if you leave your search criteria will be lost. This can not be undone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave",nil];
        [alertView show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
            [self removeAllData];
            break;
            
        default:
            break;
    }
}

-(void)removeAllData
{
    [arrResults removeAllObjects];
    for (id key in  [dictCriteria allKeys]) {
        [[dictCriteria objectForKey:key]removeAllObjects];
    }
    tblCategory.tableHeaderView = viewinstruction;
    [tblCategory reloadData];
    [self btnAddCriteriaPressed:nil];
    self.navigationItem.rightBarButtonItem = nil;
}


-(IBAction)btnAddCriteriaPressed:(id)sender {
    
    isEditMode = NO;
    [tblCategory reloadData];
    
    [self removesearchBtn];
    if (self.isForCandidate) {
        if ([[dictCriteria objectForKey:arrViews[0]]count]<2) {
            [self addChildContactWithType:INDUSTRY];
            return;
        }
        else if ([[dictCriteria objectForKey:arrViews[1]]count]==0){
            [self addChildContactWithType:EXPERIENCE];
            return;
        }
        else if ([[dictCriteria objectForKey:arrViews[2]]count]==0){
            [self addChildContactWithType:LOCATION];
            return;
        }
        else if ([[dictCriteria objectForKey:arrViews[3]]count]==0){
            [self addChildContactWithType:COMPANY];
            return;
        }
    }
    else{
        if ([[dictCriteria objectForKey:arrViews[0]]count]<2) {
            [self addChildContactWithType:INDUSTRY];
            return;
        }
        else if ([[dictCriteria objectForKey:arrViews[1]]count]==0 && self.isForCandidate==NO){
            [self addChildContactWithType:POSITION];
            return;
        }
        else if ([[dictCriteria objectForKey:arrViews[2]]count]==0){
            [self addChildContactWithType:EXPERIENCE];
            return;
        }
        else if ([[dictCriteria objectForKey:arrViews[3]]count]==0){
            [self addChildContactWithType:LOCATION];
            return;
        }
        else if ([[dictCriteria objectForKey:arrViews[4]]count]==0){
            [self addChildContactWithType:COMPANY];
            return;
        }
    }
    
}

-(void)removesearchBtn{
    [tblCategory layoutIfNeeded];
    btnSearch.hidden = YES;
    hieghtTblView.constant = 0;
    [tblCategory needsUpdateConstraints];
//    [tblCategory setNeedsLayout];
//    [tblCategory layoutIfNeeded];
}

-(void)showSearchBtn{
    hieghtTblView.constant = 100;
    [tblCategory needsUpdateConstraints];
    [tblCategory layoutIfNeeded];
    [tblCategory setNeedsLayout];
    btnSearch.hidden = NO;
}

-(void)addChildContactWithType:(ViewType)viewType{
    childContacts =[[ContactsViewController alloc]initWithNibName:@"ContactsViewController" bundle:nil];
    [self addChildViewController:childContacts];
    NSMutableArray *arrSendForButtons = [[NSMutableArray alloc]init];
    for (id key in  [dictCriteria allKeys]) {
        if ([key isEqualToString:arrViews[INDUSTRY]]) {
            if ([[dictCriteria objectForKey:arrViews[INDUSTRY]]count]<2) {
                [arrSendForButtons addObject:[NSNumber numberWithInt:0]];
            }
        }
        else{
            if ([[dictCriteria objectForKey:key]count]==0) {
                [arrSendForButtons addObject:[NSNumber numberWithInt:(int)[arrViews indexOfObject:key]]];
            }
        }
    }
    
    childContacts.arrRemainedInfo = arrSendForButtons;
    childContacts.delegate = self;
    childContacts.isEdit = NO;
    childContacts.isForCandidate = self.isForCandidate;
    childContacts.currentViewType = viewType;
    [childContacts didMoveToParentViewController:self];
    tblCategory.tableFooterView = nil;
    tblCategory.tableFooterView = childContacts.view;
    
    if(arrResults.count>0){
        CGFloat h = tblCategory.contentSize.height - tblCategory.frame.size.height;
        if (h>0) {
            [tblCategory setContentOffset:CGPointMake(0, tblCategory.contentSize.height - tblCategory.frame.size.height) animated:YES];
        }
    }
}

-(void)editChildContactWithType:(ContactModel*)model{
    childContacts =[[ContactsViewController alloc]initWithNibName:@"ContactsViewController" bundle:nil];
    [self addChildViewController:childContacts];
    childContacts.editing = YES;
    childContacts.editModel =model;
    childContacts.isEdit = YES;
    childContacts.isForCandidate = self.isForCandidate;
    childContacts.delegate = self;
    childContacts.currentViewType = model.type;
    [childContacts didMoveToParentViewController:self];
    tblCategory.tableFooterView = nil;
    tblCategory.tableFooterView = childContacts.view;

    
    if(arrResults.count>0){
        CGFloat h = tblCategory.contentSize.height - tblCategory.frame.size.height;
        if (h>0) {
            [tblCategory setContentOffset:CGPointMake(0, tblCategory.contentSize.height - tblCategory.frame.size.height) animated:YES];
        }
    }
}

-(IBAction)btnDeletePressed:(UIButton*)sender{
    NSUInteger index = [sender tag]-2000;
    if (arrResults[index] != nil) {
        ContactModel *curModel = arrResults[index];
        NSString *strName;
        switch (curModel.type) {
            case INDUSTRY:
            {
                strName = curModel.name;
            }
                break;
            case POSITION:
            {
                strName = curModel.position;
            }
                break;
            case EXPERIENCE:
            {
                strName = curModel.experience;
            }
                break;
            case LOCATION:
            {
                strName = [NSString stringWithFormat:@"%@,%@,%@",curModel.city,curModel.state,curModel.country];
                NSArray *arr = [CommonMethods getTagArray:strName];
                strName = [arr componentsJoinedByString:@","];
            }
                break;
            case COMPANY:
            {
                strName = curModel.company;
            }
                break;

                
            default:
                break;
        }
        [UIActionSheet showInView:self.view withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:[NSString stringWithFormat:@"Delete %@",strName] otherButtonTitles:nil tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex==0) {
                if (curModel.type==INDUSTRY) {
                    [[dictCriteria objectForKey:arrViews[INDUSTRY]]removeObject:curModel];
                    [arrResults removeObject:curModel];
                }
                else{
                    NSString *key = self.isForCandidate ? arrViews[curModel.type-1] : arrViews[curModel.type];
                    if ([[dictCriteria objectForKey:key ] count]>0) {
                        [[dictCriteria objectForKey:key]removeAllObjects];
                        [arrResults removeObject:curModel];
                    }
                }
                
                
                if (self.isForCandidate) {
                    // Updating Criteria with index for candidate view
                    if([[dictCriteria objectForKey:arrViews[0]]count]<2 &&
                       [[dictCriteria objectForKey:arrViews[1]]count]==0 &&
                       [[dictCriteria objectForKey:arrViews[2]]count]==0 &&
                       [[dictCriteria objectForKey:arrViews[3]]count]==0){
                         self.navigationItem.rightBarButtonItem = nil;
                    }
                }
                else
                {
                    if([[dictCriteria objectForKey:arrViews[0]]count]<2 &&
                       [[dictCriteria objectForKey:arrViews[1]]count]==0 &&
                       [[dictCriteria objectForKey:arrViews[2]]count]==0 &&
                       [[dictCriteria objectForKey:arrViews[3]]count]==0 &&
                       [[dictCriteria objectForKey:arrViews[4]]count]==0)
                    {
                        self.navigationItem.rightBarButtonItem = nil;
                    }
                }

    
                
                tblCategory.tableFooterView = viewBtnCriteria;
                [tblCategory reloadData];
                
                if (arrResults.count==0) {
                        tblCategory.tableHeaderView = viewinstruction;
                        [self btnAddCriteriaPressed:nil];
                }
            }
        }];
    }
    
}

-(IBAction)btnEditPressed:(UIButton*)sender{
    NSUInteger index = [sender tag]-1000;
    if (arrResults[index]!=nil) {
        [self removesearchBtn];
        [self editChildContactWithType:arrResults[index]];
    }
}

- (IBAction)btnSearchPressed:(id)sender {
    
//    ="UserID" ni
//    ="UserToken"
//    PageNumber" nil

    NSMutableDictionary *dictSend = [[NSMutableDictionary alloc]init];
    [dictSend setValue:@"" forKey:@"Industry"];
    [dictSend setValue:@"" forKey:@"Industry2"];
    [dictSend setValue:@"" forKey:@"Position"];
    [dictSend setValue:@"" forKey:@"ExperienceLevel"];
    [dictSend setValue:@"" forKey:@"LocationCity"];
    [dictSend setValue:@"" forKey:@"LocationState"];
    [dictSend setValue:@"" forKey:@"LocationCountry"];
    [dictSend setValue:@"" forKey:@"Company"];

    for (id key in  [dictCriteria allKeys])
    {
        if ([key isEqualToString:arrViews[INDUSTRY]])
        {
            [[dictCriteria objectForKey:arrViews[INDUSTRY]] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
            {
                ContactModel *model = (ContactModel*)obj;
                if (idx==0)
                {
                    [dictSend setObject:[model.name isNull] forKey:@"Industry"];
                }
                else if (idx==1 && model.name!=nil)
                {
                    [dictSend setObject:[model.name isNull] forKey:@"Industry2"];
                }

            }];
        }
        else
        {
            if ([[dictCriteria objectForKey:key]count]>0) {
                ContactModel *model = [[dictCriteria objectForKey:key]objectAtIndex:0];
                switch (model.type) {
                    case POSITION:
                    {
                            [dictSend setObject:[model.position isNull] forKey:@"Position"];
                    }
                        break;
                    case EXPERIENCE:
                    {
                        [dictSend setObject:[model.experience isNull] forKey:@"ExperienceLevel"];
                    }
                        break;
                    case LOCATION:
                    {
                            [dictSend setObject:[model.city isNull] forKey:@"LocationCity"];
                            [dictSend setObject:[model.state isNull] forKey:@"LocationState"];
                            [dictSend setObject:[model.country isNull] forKey:@"LocationCountry"];
                    }
                        break;
                    case COMPANY:
                    {
                        [dictSend setObject:[model.company isNull] forKey:@"Company"];
                    }
                        break;

                    default:
                        break;
                }
            }
        }
    }
    
    
    
    
    if (_isForCandidate)
    {
        //candidate
        C_Find_CandidateListingVC *obj = [[C_Find_CandidateListingVC alloc]initWithNibName:@"C_Find_CandidateListingVC" bundle:nil];
        obj.dictInfoCandidate = dictSend;
        [self.navigationController pushViewController:obj animated:YES];
    }
    else
    {
        //job
        C_FindAJobListingVC *obj = [[C_FindAJobListingVC alloc]initWithNibName:@"C_FindAJobListingVC" bundle:nil];
        obj.dictInfoJob = dictSend;
        [self.navigationController pushViewController:obj animated:YES];
    }
}

#pragma mark - contactsDelegates


- (void) contactsCancelled{
    isEditMode = YES;
    if (childContacts!=nil) {
        [childContacts.view removeFromSuperview];
        [childContacts removeFromParentViewController];
    }
    [self setAnCheckEditMode];
    [tblCategory reloadData];
    [self showSearchBtn];
}



-(void)didselectCategory:(ContactModel*)contactModel WithType:(ViewType)viewtype{
    
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCanCelAllPressed)];
    if (childContacts!=nil) {
        [childContacts.view removeFromSuperview];
        [childContacts removeFromParentViewController];
    }
   
    if (self.isForCandidate) {
        if (viewtype!=0) {
            viewtype = viewtype-1;
        }
        
        [[dictCriteria objectForKey:arrViews[viewtype]] addObject:contactModel];
        [arrResults addObject:contactModel];
    }
    else{
        [[dictCriteria objectForKey:arrViews[viewtype]] addObject:contactModel];
        [arrResults addObject:contactModel];
    }
    
    
   
//    [arrResults removeAllObjects];
//    for (id key in  [dictCriteria allKeys]) {
//        if ([key isEqualToString:arrViews[INDUSTRY]]) {
//            [[dictCriteria objectForKey:arrViews[INDUSTRY]] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                [arrResults addObject:obj];
//            }];
//        }
//        else{
//            if ([[dictCriteria objectForKey:key]count]>0) {
//                [arrResults addObject:[[dictCriteria objectForKey:key] objectAtIndex:0]];
//            }
//        }
//    }
    isEditMode = YES;

    tblCategory.tableHeaderView = nil;
    [self showSearchBtn];
    [self setAnCheckEditMode];
   
    [tblCategory reloadData];

    if(arrResults.count>0){
        CGFloat h = tblCategory.contentSize.height - tblCategory.frame.size.height;
        if (h>0) {
            [tblCategory setContentOffset:CGPointMake(0, tblCategory.contentSize.height - tblCategory.frame.size.height) animated:YES];
        }
    }
    
}

/*-------For checking all values and updating Criteria related to that-----------*/
-(void)setAnCheckEditMode{
    if (self.isForCandidate) {
        // Updating Criteria with index for candidate view
        if([[dictCriteria objectForKey:arrViews[0]]count]<2 ||
           [[dictCriteria objectForKey:arrViews[1]]count]==0 ||
           [[dictCriteria objectForKey:arrViews[2]]count]==0 ||
           [[dictCriteria objectForKey:arrViews[3]]count]==0){
            tblCategory.tableFooterView = viewBtnCriteria;
        }
        else{
            isEditMode = YES;
            tblCategory.tableFooterView = nil;
        }
    }
    else{
        if([[dictCriteria objectForKey:arrViews[0]]count]<2 ||
           [[dictCriteria objectForKey:arrViews[1]]count]==0 ||
           [[dictCriteria objectForKey:arrViews[2]]count]==0 ||
           [[dictCriteria objectForKey:arrViews[3]]count]==0 ||
           [[dictCriteria objectForKey:arrViews[4]]count]==0){
            tblCategory.tableFooterView = viewBtnCriteria;
        }
        else{
            isEditMode = YES;
            tblCategory.tableFooterView = nil;
        }
    }
}

-(void)didChangeViewType:(UIView*)view WithType:(ViewType)viewtype{
    
   // Code for managing frames if want to
//    tblCategory.tableFooterView = nil;
//    UIView *viewFooter;
//    //viewFooter.backgroundColor = [UIColor redColor];
//    //childContacts.view.backgroundColor = [UIColor greenColor];
//    if (view == childContacts.tblContacts) {
//        viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
//    }
//    else{
//        viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height+50)];
//    }
////    childContacts.view.frame = CGRectMake(0, 0, childContacts.view.frame.size.width, childContacts.view.frame.size.height);
////    [viewFooter sizeToFit];
////    [viewFooter addSubview:childContacts.view];
////    tblCategory.tableFooterView = viewFooter ;
//    [view layoutIfNeeded];
//      tblCategory.tableFooterView = view ;
//    // NSLog(@"%@",NSStringFromCGRect(viewFooter.frame));
//     // NSLog(@"%@",NSStringFromCGRect(childContacts.view.frame));
    [view layoutIfNeeded];
    [childContacts.view layoutIfNeeded];
    [tblCategory layoutIfNeeded];
    [tblCategory needsUpdateConstraints];
    [tblCategory setNeedsLayout];
}

#pragma - mark Tableviewdelegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrResults.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"JobCell";
    
    JobCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JobCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    ContactModel *model = arrResults[indexPath.row];
    
    
    NSString *strTextTemporary;
    if (self.isForCandidate)
    {
        strTextTemporary = @"Search Crowd for";
    }
    else
    {
        strTextTemporary = @"Search Crowd for all jobs in the";
    }
    cell.lblSearch.adjustsFontSizeToFitWidth = YES;
    switch (model.type)
    {
        case INDUSTRY:
        {
            cell.lblSearch.text = [NSString stringWithFormat:@"%@ %@",strTextTemporary,arrViews[INDUSTRY]];
            cell.lblCategoryName.text = model.name;
        }
            break;
        case POSITION:
        {
            cell.lblSearch.text = [NSString stringWithFormat:@"%@ %@",strTextTemporary,arrViews[POSITION]];
            cell.lblCategoryName.text = model.position;

        }
            break;
        case EXPERIENCE:
        {
            NSString *strExp = model.experience;
            cell.lblSearch.text = [NSString stringWithFormat:@"%@ %@",strTextTemporary,self.isForCandidate?arrViews[EXPERIENCE-1]:arrViews[EXPERIENCE]];
            if ([strExp isEqualToString:@"1"]) {
                cell.lblCategoryName.text = @"0-1 year";
            }
            else if ([strExp isEqualToString:@"2"]) {
                cell.lblCategoryName.text = @"1-3 year";
            }
            else if ([strExp isEqualToString:@"3"]) {
                cell.lblCategoryName.text = @"3-5 year";
            }
            else if ([strExp isEqualToString:@"4"]) {
                cell.lblCategoryName.text = @"5-8 year";
            }
            else if ([strExp isEqualToString:@"5"]) {
                cell.lblCategoryName.text = @"8+ year";
            }
            else
                cell.lblCategoryName.text = @"";
            //cell.lblCategoryName.text = model.experience;

        }
            break;
        case COMPANY:
        {
            if (self.isForCandidate) {
                cell.lblSearch.text = [NSString stringWithFormat:@"%@ %@",strTextTemporary,arrViews[COMPANY-1]];
            }
            else{
                cell.lblSearch.text = [NSString stringWithFormat:@"%@ %@",strTextTemporary,arrViews[COMPANY]];
            }
            cell.lblCategoryName.text = model.company;
        }
            break;
        case LOCATION:
        {
            cell.lblSearch.text = [NSString stringWithFormat:@"%@ %@",strTextTemporary,self.isForCandidate?arrViews[LOCATION-1]:arrViews[LOCATION]];
            if ([[model.state isNull]isEqualToString:@""])
            {
                cell.lblCategoryName.text  = [NSString stringWithFormat:@"%@\n%@",model.city,model.country];
            }
            else
            {
                NSArray *arr = [CommonMethods getTagArray:[NSString stringWithFormat:@"%@ \n %@ , %@",model.city,model.state,model.country]];
                NSString *strName = [arr componentsJoinedByString:@","];
                cell.lblCategoryName.text  = strName;
            }
        }
            break;
        default:
            break;
    }
    cell.btnEdit.tag = indexPath.row + 1000;
    cell.btnDelete.tag = indexPath.row + 2000;

    cell.btnDelete.hidden = !isEditMode;
    cell.btnEdit.hidden = !isEditMode;
    
    [cell.btnDelete addTarget:self action:@selector(btnDeletePressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnEdit addTarget:self action:@selector(btnEditPressed:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
