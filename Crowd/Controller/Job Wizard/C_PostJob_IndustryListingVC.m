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
    //    NSLog(@"%@",arrContent);
    [tblView reloadData];
    
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
}
-(void)done
{
    Class mtyC = nil;;
    if ([is_PostJob_Edit_update isEqualToString:@"edit"])
    {
        mtyC = [C_PostJob_PreviewVC class];
    }
    else
    {
        mtyC = [C_PostJob_UpdateVC class];
    }
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:mtyC])
        {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}
-(void)back
{
    popView;
}
-(void)btnCancelClicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
        // add industry 1 push view
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
        // add industry 2 and popview
        if ([self.delegate respondsToSelector:@selector(addText:)])
            [self.delegate addText:strText];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
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
