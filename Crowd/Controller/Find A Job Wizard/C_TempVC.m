//
//  C_TempVC.m
//  Crowd
//
//  Created by MAC107 on 25/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_TempVC.h"
#import "ViewSelection.h"
#import "AppConstant.h"
@interface C_TempVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    __weak IBOutlet ViewSelection *viewSelect;
    
    IBOutlet UIView *viewTable;
    __weak IBOutlet UITableView *tblView;
    
    __weak IBOutlet UISearchBar *searchBar;
    
    NSMutableArray *arrContent;
    NSMutableArray *arrSearch;
    
    BOOL isSearching;
}
@end

@implementation C_TempVC

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UIView *v in viewSelect.subviews)
        for (UIButton *btnS in v.subviews)
            if ([btnS isKindOfClass:[UIButton class]])
                [btnS addTarget:self action:@selector(btnTypeSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self btnTypeSelected:viewSelect.btnIndustry];

    
    tblView.sectionIndexColor = RGBCOLOR_GREEN ;
    arrContent = [[NSMutableArray alloc]init];
    arrSearch = [[NSMutableArray alloc]init];
    arrContent = [[NSMutableArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IndustryList" ofType:@"plist"]];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    arrContent = [[arrContent sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    [tblView reloadData];
}

-(void)btnTypeSelected:(UIButton *)btnTapped
{
    [viewSelect.btnIndustry setBackgroundImage:nil forState:UIControlStateNormal];
    [viewSelect.btnPosition setBackgroundImage:nil forState:UIControlStateNormal];
    [viewSelect.btnExperience setBackgroundImage:nil forState:UIControlStateNormal];
    [viewSelect.btnLocation setBackgroundImage:nil forState:UIControlStateNormal];
    [viewSelect.btnCompany setBackgroundImage:nil forState:UIControlStateNormal];
    
    [btnTapped setBackgroundImage:[UIImage imageNamed:@"btnBG-Round"] forState:UIControlStateNormal];

    viewTable.translatesAutoresizingMaskIntoConstraints = NO;
    viewTable.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:viewTable];
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds)-64-40;
    
    
    
    /*--- View Table Start from top 40 pixel ---*/
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[viewTable(width)]|" options:0 metrics:@{@"width":@(width)} views:NSDictionaryOfVariableBindings(viewTable)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[viewTable(height)]-0-|" options:0 metrics:@{@"height":@(height-40)} views:NSDictionaryOfVariableBindings(viewTable)]];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if ([searchText isEqualToString:@""])
    {
        isSearching = NO;
    }
    else
    {
        isSearching = YES;
        [self searchText:searchText];
    }
    [tblView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBarT
{
    isSearching = YES;
    [searchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBarT
{
    isSearching = NO;
    searchBar.text = @"";
    [tblView reloadData];
    [searchBar resignFirstResponder];

}
#pragma mark - Table Delegate
#pragma mark - Table Delegate
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (isSearching)
        return [arrSearch valueForKey:@"key"];
    else
        return [arrContent valueForKey:@"key"];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (isSearching)
        return [[arrSearch valueForKey:@"key"] indexOfObject:title];
    else
        return [[arrContent valueForKey:@"key"] indexOfObject:title];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isSearching)
        return [arrSearch count];
    else
        return [arrContent count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (isSearching)
        return [arrSearch[section] objectForKey:@"key"];
    else
        return [arrContent[section] objectForKey:@"key"];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching)
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
    
    if (isSearching)
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
    
    NSLog(@"%@",strText);
    
//    if (_isUpdate)
//    {
//        if ([self.delegate respondsToSelector:@selector(updateText:)])
//            [self.delegate updateText:strText];
//    }
//    else
//    {
//        if ([self.delegate respondsToSelector:@selector(addText:)])
//            [self.delegate addText:strText];
//    }
   
}
#pragma mark -
#pragma mark - Text Search
-(void)searchText:(NSString *) text
{
    [arrSearch removeAllObjects];
    arrSearch = [[self filterArrayUsingText:text] mutableCopy];
}
//
//#pragma mark - Table Search Delegate
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    [self searchText:searchString];
//    return YES;
//}
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
}


@end
