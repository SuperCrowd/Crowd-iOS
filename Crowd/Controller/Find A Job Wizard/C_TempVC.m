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
#import "C_ScrollViewKeyboard.h"

typedef NS_ENUM(NSInteger, txtSelected){
    position_company = 100,
    city = 101,
    state = 102,
    country = 103,
};

@interface C_TempVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UITextFieldDelegate>
{
    __weak IBOutlet ViewSelection *viewSelect;
    __weak IBOutlet UILabel *lbl_Static_SelectCategory;
    __weak IBOutlet NSLayoutConstraint *con_lblHeight;

    
    /*--- industry tableview ---*/
    IBOutlet UIView *viewTable;
    __weak IBOutlet UITableView *tblView;
    __weak IBOutlet UISearchBar *searchBar;
    
    NSMutableArray *arrContent;
    NSMutableArray *arrSearch;
    
    BOOL isSearching;
    
    /*--- for Position and Company ---*/
    IBOutlet UIView *viewText;
    __weak IBOutlet UITextField *txt_Position_Company;
    __weak IBOutlet UILabel *lbl_Position_Company;
    __weak IBOutlet UILabel *lblCaption;

    /*--- for Experience ---*/
    IBOutlet UIView *viewExperience;
 
    /*--- Location ---*/
    IBOutlet UIView *viewLocation;
    __weak IBOutlet C_ScrollViewKeyboard *scrlLocation;
    IBOutlet UITextField *txtCity;
    IBOutlet UITextField *txtState;
    __weak IBOutlet UITextField *txtCountry;

    UIButton *btnSelected;
}
@end

@implementation C_TempVC
@synthesize delegate;
#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];

    viewSelect.translatesAutoresizingMaskIntoConstraints = NO;
    lbl_Static_SelectCategory.translatesAutoresizingMaskIntoConstraints = NO;
    if (!_isFirstTime)
    {
        con_lblHeight.constant = 0.0;
    }
    for (UIView *v in viewSelect.subviews)
        for (UIButton *btnS in v.subviews)
            if ([btnS isKindOfClass:[UIButton class]])
                [btnS addTarget:self action:@selector(btnTypeSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self set_TableView];
    [self set_Position_Company];
    [self set_Experience];
    [self set_Location];
    
    
    [self btnTypeSelected:viewSelect.btnIndustry];
    
    tblView.sectionIndexColor = RGBCOLOR_GREEN ;
    arrContent = [[NSMutableArray alloc]init];
    arrSearch = [[NSMutableArray alloc]init];
    arrContent = [[NSMutableArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IndustryList" ofType:@"plist"]];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    arrContent = [[arrContent sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    [tblView reloadData];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}
-(void)set_TableView
{
    /*--- Talbe View - Industry ---*/
    viewTable.translatesAutoresizingMaskIntoConstraints = NO;
    viewTable.backgroundColor = [UIColor purpleColor];
    tblView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:viewTable];
    [self setupView:viewTable];
}
-(void)set_Position_Company
{
    /*--- Talbe View - Industry ---*/
    txt_Position_Company.text = @"";;
    lbl_Position_Company.text = @"";
    lblCaption.text = @"";
    
    viewText.translatesAutoresizingMaskIntoConstraints = NO;
    viewText.backgroundColor = [UIColor redColor];
    [self.view addSubview:viewText];
     [self setupView:viewText];
}
-(void)set_Experience
{
    /*--- Talbe View - Industry ---*/
    viewExperience.translatesAutoresizingMaskIntoConstraints = NO;
    viewExperience.backgroundColor = [UIColor greenColor];
    [self.view addSubview:viewExperience];
    [self setupView:viewExperience];

}
-(void)set_Location
{
    /*--- Talbe View - Industry ---*/
    viewLocation.translatesAutoresizingMaskIntoConstraints = NO;
    viewLocation.backgroundColor = [UIColor greenColor];
    [self.view addSubview:viewLocation];
    [self setupView:viewLocation];

}
-(void)setupView:(UIView *)myView
{
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    //CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds)-64.0-40.0-40.0;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:(_isFirstTime)?80:40]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:width]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];

}
-(void)btnTypeSelected:(UIButton *)btnTapped
{
    btnSelected = btnTapped;
    [viewSelect.btnIndustry setBackgroundImage:nil forState:UIControlStateNormal];
    [viewSelect.btnPosition setBackgroundImage:nil forState:UIControlStateNormal];
    [viewSelect.btnExperience setBackgroundImage:nil forState:UIControlStateNormal];
    [viewSelect.btnLocation setBackgroundImage:nil forState:UIControlStateNormal];
    [viewSelect.btnCompany setBackgroundImage:nil forState:UIControlStateNormal];
    
    [btnTapped setBackgroundImage:[UIImage imageNamed:@"btnBG-Round"] forState:UIControlStateNormal];

    
    [self.view endEditing:YES];
    viewTable.alpha = 0.0;
    viewText.alpha = 0.0;
    viewExperience.alpha = 0.0;
    viewLocation.alpha = 0.0;
    if (btnTapped == viewSelect.btnIndustry)
    {
        viewTable.alpha = 1.0;
    }
    else if (btnTapped == viewSelect.btnPosition)
    {
        viewText.alpha = 1.0;
        txt_Position_Company.text = @"";;
        lbl_Position_Company.text = @"Enter your position";
        lblCaption.text = @"Position";
    }
    else if (btnTapped == viewSelect.btnCompany)
    {
        viewText.alpha = 1.0;
        txt_Position_Company.text = @"";;
        lbl_Position_Company.text = @"Enter your company name";
        lblCaption.text = @"Company";
    }
    else if (btnTapped == viewSelect.btnExperience)
    {
        viewExperience.alpha = 1.0;
    }
    else
    {
        viewLocation.alpha = 1.0;
    }

}


-(IBAction)btnEditTextField:(id)sender
{
    txtSelected selectedTxt = ((UIButton *)sender).tag;
    switch (selectedTxt) {
        case position_company:
            [txt_Position_Company becomeFirstResponder];
            break;
        case city:
            [txtCity becomeFirstResponder];
            break;
        case state:
            [txtState becomeFirstResponder];
            break;
        case country:
            [txtCountry becomeFirstResponder];
            break;
        default:
            break;
    }
}
#pragma mark -
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
    if (isSearching)
        strText = arrSearch[indexPath.section][@"value"][indexPath.row];
    else
        strText = arrContent[indexPath.section][@"value"][indexPath.row];
    
    NSLog(@"%@",strText);
    if ([self.delegate respondsToSelector:@selector(IndustrySelected:)])
    {
            [self.delegate IndustrySelected:strText];
    }
    [self.view removeFromSuperview];
    //[self removeFromParentViewController];;
    
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
#pragma mark - Searchbar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""])
        isSearching = NO;
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
-(void)searchText:(NSString *) text
{
    [arrSearch removeAllObjects];
    arrSearch = [[self filterArrayUsingText:text] mutableCopy];
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


#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(updateContentOffsetWhenSelectTextfield)])
    {
        [self.delegate updateContentOffsetWhenSelectTextfield];
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (btnSelected == viewSelect.btnLocation)
    {
        if (textField == txtCity)
        {
            [txtState becomeFirstResponder];
        }
        else if(textField == txtState)
        {
            [txtCountry becomeFirstResponder];
        }
        else
        {
            [textField resignFirstResponder];
        }

    }
    
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
