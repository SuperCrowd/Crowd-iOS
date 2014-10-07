//
//  C_SearchVC.m
//  Crowd
//
//  Created by MAC107 on 08/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_SearchVC.h"
#import "AppConstant.h"
#import "C_UserModel.h"
@interface C_SearchVC ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblView;
    
    
    NSMutableArray *arrContent;
    NSMutableArray *arrSearch;
}
@end

@implementation C_SearchVC
@synthesize delegate;
#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Industry";
    
    tblView.sectionIndexColor = RGBCOLOR_GREEN ;
    /*--- back bar button ---*/
    UIImage *buttonImage = [UIImage imageNamed:@"back_icon"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:self action:@selector(dismissME) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem =  retVal;
    
    arrContent = [[NSMutableArray alloc]init];
    arrSearch = [[NSMutableArray alloc]init];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
    self.searchDisplayController.searchResultsTableView.separatorStyle = tblView.separatorStyle;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
/*
 [arrContent addObject:@{@"key":@"W",@"value":@[@"Whale", @"Whale Shark", @"Wombat"]}];
 
 [arrContent addObject:@{@"key":@"A",@"value":@[@"Accounting",@"Acting",@"Administrator",@"Another Industry"]}];
 [arrContent addObject:@{@"key":@"B",@"value":@[@"Basketball",@"Baseball",@"Bowling"]}];
 [arrContent addObject:@{@"key":@"C",@"value":@[@"Cricket", @"Cow",@"Cat"]}];
 [arrContent addObject:@{@"key":@"D",@"value":@[@"Dog", @"Donkey"]}];
 [arrContent addObject:@{@"key":@"L",@"value":@[@"Lion"]}];
 [arrContent addObject:@{@"key":@"M",@"value":@[@"Man", @"Woman"]}];
 [arrContent addObject:@{@"key":@"P",@"value":@[@"Panda", @"Peacock", @"Pig"]}];
 [arrContent addObject:@{@"key":@"T",@"value":@[@"Tasmania Devil"]}];
 */
    
    arrContent = [[NSMutableArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IndustryList" ofType:@"plist"]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    arrContent = [[arrContent sortedArrayUsingDescriptors:@[sort]] mutableCopy];
//    NSLog(@"%@",arrContent);
    [tblView reloadData];
}
-(void)dismissME
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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

    if ([myUserModel.industry isEqualToString:strText] ||
        [myUserModel.industry2 isEqualToString:strText])
    {
        [CommonMethods displayAlertwithTitle:@"Please choose different Industry" withMessage:nil
                          withViewController:self];
        return;
    }
    
    if (_isUpdate)
    {
        if ([self.delegate respondsToSelector:@selector(updateText:)])
            [self.delegate updateText:strText];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(addText:)])
            [self.delegate addText:strText];
    }
    
    [self dismissME];
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
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
@end
