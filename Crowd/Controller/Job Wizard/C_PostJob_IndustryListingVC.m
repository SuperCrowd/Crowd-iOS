//
//  C_PostJob_IndustryListingVC.m
//  Crowd
//
//  Created by MAC107 on 22/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_PostJob_IndustryListingVC.h"
#import "AppConstant.h"
#import "C_PostJob_IndustryVC.h"
#import "C_PostJob_PreviewVC.h"
#import "C_PostJob_UpdateVC.h"
#import "C_PostJobModel.h"
#import "Update_PostJob.h"
@interface C_PostJob_IndustryListingVC ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
    
    
    NSMutableArray *arrContent;
    NSMutableArray *arrSearch;
}


@end

@implementation C_PostJob_IndustryListingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Job Listing";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    if([is_PostJob_Edit_update isEqualToString:@"edit"]||
       [is_PostJob_Edit_update isEqualToString:@"update" ])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(done)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Cancel" withSelector:@selector(btnCancelClicked:)];
    }
    
    arrContent = [[NSMutableArray alloc]init];
    arrSearch = [[NSMutableArray alloc]init];
    
    tblView.sectionIndexColor = RGBCOLOR_GREEN ;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
    self.searchDisplayController.searchResultsTableView.separatorStyle = tblView.separatorStyle;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    arrContent = [[NSMutableArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IndustryList" ofType:@"plist"]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    arrContent = [[arrContent sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    [tblView reloadData];
    
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
}
-(void)done
{
    if ([is_PostJob_Edit_update isEqualToString:@"update"])
    {
        Update_PostJob *job = [[Update_PostJob alloc]init];
        [job update_JobPost_with_withSuccessBlock:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"updateJobListModel" object:nil];
            for (UIViewController *vc in self.navigationController.viewControllers)
            {
                if ([vc isKindOfClass:[C_PostJob_UpdateVC class]])
                {
                    [self.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
        } withFailBlock:^(NSString *strError) {
            [CommonMethods displayAlertwithTitle:strError withMessage:nil withViewController:self];
        }];
    }
    else
    {
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[C_PostJob_PreviewVC class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    }
}
-(void)back
{
    popView;
}

#pragma mark - Table Delegate
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [arrSearch valueForKey:@"key"];
    else
        return [arrContent valueForKey:@"key"];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [[arrSearch valueForKey:@"key"] indexOfObject:title];
    else
        return [[arrContent valueForKey:@"key"] indexOfObject:title];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [arrSearch count];
    else
        return [arrContent count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [arrSearch[section] objectForKey:@"key"];
    else
        return [arrContent[section] objectForKey:@"key"];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [[arrSearch[section] objectForKey:@"value"] count];
    else
        return [[arrContent[section] objectForKey:@"value"] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.adjustsFontSizeToFitWidth = YES;

    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        NSMutableDictionary *dict = arrSearch[indexPath.section];
        NSMutableArray *allInfoArray= dict[@"value"];
        cell.textLabel.text = allInfoArray [indexPath.row];
    }
    else
    {
        NSMutableDictionary *dict = arrContent[indexPath.section];
        NSMutableArray *allInfoArray= dict[@"value"];
        cell.textLabel.text = allInfoArray [indexPath.row];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strText;
    if (tableView == self.searchDisplayController.searchResultsTableView)
        strText = arrSearch[indexPath.section][@"value"][indexPath.row];
    else
        strText = arrContent[indexPath.section][@"value"][indexPath.row];
    
    
    if (_isAdd_1)
    {
        // add industry 1 push view no need to compare industry
        if ([is_PostJob_Edit_update isEqualToString:@"update"])
        {
            postJob_ModelClass.Industry = strText;
        }
        else
        {
            [dictPostNewJob setValue:strText forKey:@"Industry"];
            [dictPostNewJob setValue:@"" forKey:@"Industry2"];
        }
        
        C_PostJob_IndustryVC *obj = [[C_PostJob_IndustryVC alloc]initWithNibName:@"C_PostJob_IndustryVC" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    else if (_isAdd_2)
    {
        // if add 2 then compare industry with 2
        if ([is_PostJob_Edit_update isEqualToString:@"update"])
        {
            if ([postJob_ModelClass.Industry isEqualToString:strText])
            {
                [CommonMethods displayAlertwithTitle:@"Please choose different Industry" withMessage:nil
                                  withViewController:self];
                return;
            }
        }
        else
        {
            if ([dictPostNewJob[@"Industry"] isEqualToString:strText])
            {
                [CommonMethods displayAlertwithTitle:@"Please choose different Industry" withMessage:nil
                                  withViewController:self];
                return;
            }
        }

        // add industry 2 and popview
        if ([self.delegate respondsToSelector:@selector(addText:)])
            [self.delegate addText:strText];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        // if update any of industry then compare both 
        if ([is_PostJob_Edit_update isEqualToString:@"update"])
        {
            if ([postJob_ModelClass.Industry isEqualToString:strText] ||
                [postJob_ModelClass.Industry2 isEqualToString:strText])
            {
                [CommonMethods displayAlertwithTitle:@"Please choose different Industry" withMessage:nil
                                  withViewController:self];
                return;
            }
        }
        else
        {
            if ([dictPostNewJob[@"Industry"] isEqualToString:strText] ||
                [dictPostNewJob[@"Industry2"] isEqualToString:strText])
            {
                [CommonMethods displayAlertwithTitle:@"Please choose different Industry" withMessage:nil
                                  withViewController:self];
                return;
            }
        }

        // update text with delegate and popview
        if ([self.delegate respondsToSelector:@selector(updateText:)])
            [self.delegate updateText:strText];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -
#pragma mark - Text Search
-(void)searchText:(NSString *) text
{
    [arrSearch removeAllObjects];
    arrSearch = [[self filterArrayUsingText:text] mutableCopy];
}

#pragma mark - Table Search Delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searchText:searchString];
    return YES;
}
- (NSArray *)filterArrayUsingText:(NSString *)text
{
    NSMutableArray *filteredWordArray = [NSMutableArray array];
    for (NSDictionary *dictionary in arrContent)
    {
        NSArray *filteredWords = [self filterWordsFromArray:dictionary[@"value"] usingText:text];
        
        if (filteredWords) {
            [filteredWordArray addObject:@{@"key":dictionary[@"key"], @"value":filteredWords}];
        }
    }
    
    return filteredWordArray;
}

- (NSArray *)filterWordsFromArray:(NSArray *)wordArray usingText:(NSString *)text
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^(NSString *theWord, NSDictionary *bindings) {
        return [theWord containsString:text];
    }];
    
    NSArray *filteredArray = [wordArray filteredArrayUsingPredicate:predicate];
    
    return filteredArray.count == 0 ? nil : filteredArray;
}

#pragma mark - Cancel Clicked
-(void)btnCancelClicked:(id)sender
{
    if (ios8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Your job has not been posted yet. if you leave it will be lost. This can not be undone." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* CancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel  handler:^(UIAlertAction * action)
                                       {
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                       }];
        [alert addAction:CancelAction];
        
        UIAlertAction* LeaveAction = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                      {
                                          is_PostJob_Edit_update = @"no";
                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                      }];
        [alert addAction:LeaveAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your job has not been posted yet. if you leave it will be lost. This can not be undone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave",nil];[alertView show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
            is_PostJob_Edit_update = @"no";
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}

#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
