//
//  ContactsViewController.m
//  dynamicTable
//
//  Created by Mac009 on 9/29/14.
//  Copyright (c) 2014 Tatva. All rights reserved.
//

#import "ContactsViewController.h"
#import "UIActionSheet+Blocks.h"
@interface ContactsViewController ()<UITextFieldDelegate>

@end

@implementation ContactsViewController
@synthesize viewLocation,viewExperience,viewCompany,tblContacts,viewTable;
- (void)viewDidLoad {
    [super viewDidLoad];
    sectionsDict = [[NSMutableDictionary alloc]init];
    
    if(self.isForCandidate){
        arrViews = @[@"Industry",@"Experience",@"Location",@"Company"];
    }
    else{
        arrViews = @[@"Industry",@"Position",@"Experience",@"Location",@"Company"];
    }
    arrContent = [[NSMutableArray alloc]init];
    arrSearch = [[NSMutableArray alloc]init];
    arrContent = [[NSMutableArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IndustryList" ofType:@"plist"]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    arrContent = [[arrContent sortedArrayUsingDescriptors:@[sort]] mutableCopy];

    
    if (self.isEdit) {
        [self addViewForEdit];
    }
    else{
        [self addViewFromType];
    }
    
    tblContacts.sectionIndexColor = RGBCOLOR_GREEN;
}

- (IBAction)btnAddloCationPressed:(id)sender {
    
    NSString *strCity = [[NSString stringWithFormat:@"%@",textCity.text] isNull];
    NSString *strState = [[NSString stringWithFormat:@"%@",textstate.text] isNull];
    NSString *strCountry = [[NSString stringWithFormat:@"%@",textCountry.text] isNull];

    
    if ([strCity isEqualToString:@""]) {
            //Show specific alert
        [CommonMethods displayAlertwithTitle:@"Please Enter City name" withMessage:nil withViewController:self];
        
    }
    else if([strCountry isEqualToString:@""])
    {
        [CommonMethods displayAlertwithTitle:@"Please Enter Country name" withMessage:nil withViewController:self];

    }
    else{
        if (self.isEdit) {
            self.editModel.city = strCity;
            self.editModel.state = strState;
            self.editModel.country = strCountry;
            [self cancelpressed:nil];
        }
        else{
        if ([self.delegate respondsToSelector:@selector(didselectCategory:WithType:)]) {
            ContactModel *model = [[ContactModel alloc]init];
            model.city = strCity;
            model.state = strState;
            model.country = strCountry;
            model.type = self.currentViewType;
            [self.delegate didselectCategory:model
                                    WithType:self.currentViewType];
        }
        }
    }
}

- (IBAction)btnExperiencePressed:(id)sender {
    NSString *strSelectedYears = [NSString stringWithFormat:@"%ld",(long)[sender tag]-99];
    if (self.isEdit)
    {
        self.editModel.experience = strSelectedYears;
        [self cancelpressed:nil];
    }
    else
    {
        ContactModel *model = [[ContactModel alloc]init];
        model.experience = strSelectedYears;
        model.type = self.currentViewType;
        [self.delegate didselectCategory:model
                                WithType:self.currentViewType];
    }
}
- (IBAction)btnDonePressed:(id)sender {
    //Used for adding company or position
        if (self.currentViewType==POSITION) {
            
        if (textName.text.length>0) {
            if (self.isEdit) {
                self.editModel.position = textName.text;
                [self cancelpressed:nil];
            }
            else{
            ContactModel *model = [[ContactModel alloc]init];
            model.position = textName.text;
            model.type = self.currentViewType;
            [self.delegate didselectCategory:model
                                    WithType:self.currentViewType];
            }
        }
        else{
            //Show specific alert
            [CommonMethods displayAlertwithTitle:@"Please Enter Position" withMessage:nil withViewController:self];
        }
    }
    else if (self.currentViewType==COMPANY){
        if (textName.text.length>0) {
            if (self.isEdit) {
                self.editModel.position = textName.text;
                [self cancelpressed:nil];
            }
            else{
            ContactModel *model = [[ContactModel alloc]init];
            model.company = textName.text;
            model.type = self.currentViewType;
            [self.delegate didselectCategory:model
                                    WithType:self.currentViewType];
            }
        }
        else{
            //Show specific alert
            [CommonMethods displayAlertwithTitle:@"Please Enter Company" withMessage:nil withViewController:self];

        }
    }
}
- (IBAction)cancelpressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(contactsCancelled)]) {
        [self.delegate contactsCancelled];
    }
}
#define btnWidth 64
-(void)addViewForEdit{
    
    viewLocation.hidden = YES;
    viewTable.hidden = YES;
    viewLocation.hidden = YES;
    viewCompany.hidden = YES;
    btnCancel.hidden = NO;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 10, btnWidth, 30);
    //btn.backgroundColor = [UIColor redColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.tag = 100+self.currentViewType;
    [btn addTarget:self action:@selector(btnTypePressed:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    NSString *strTitle;
    
    if (self.isForCandidate==YES && self.currentViewType!=0) {
        strTitle = arrViews[self.currentViewType-1];
    }
    else{
        strTitle = arrViews[self.currentViewType];
    }
    [btn setTitle:strTitle forState:UIControlStateNormal];
    
    [btn setBackgroundImage:[UIImage imageNamed:@"btnBG-Round"] forState:UIControlStateHighlighted];
    [btn setBackgroundImage:[UIImage imageNamed:@"btnBG-Round"] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    CGSize stringsize = [strTitle sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }];
    [btn setFrame:CGRectMake(btn.frame.origin.x,btn.frame.origin.y,stringsize.width+5, btn.frame.size.height)];
    btn.selected = YES;
    [viewButtons addSubview:btn];
    
    /*----------Fill Data------------*/
    switch (self.currentViewType) {
        case INDUSTRY:
        {
            //Show row selected if you want
        }
            break;
        case POSITION:
        {
            textName.text = self.editModel.position;
        }
            break;
        case COMPANY:
        {
            textName.text = self.editModel.company;
        }
            break;
        case LOCATION:
        {
            textCity.text = self.editModel.city;
            textCountry.text = self.editModel.country;
            textstate.text = self.editModel.state;
        }
            break;
        case EXPERIENCE:
        {
            //show button selected with using tag
        }
            break;
        default:
            break;
    }
    [self updateViewFromType];
}

-(void)addViewFromType{
        int count=0;
        float origin=0;
        viewLocation.hidden = YES;
        viewTable.hidden = YES;
        viewLocation.hidden = YES;
        viewCompany.hidden = YES;
   // NSLog(@"%@",self.arrRemainedInfo);
    NSArray *sorted = [self.arrRemainedInfo sortedArrayUsingSelector:@selector(compare:)];
    self.arrRemainedInfo = [NSMutableArray arrayWithArray:sorted];
    if(self.arrRemainedInfo.count == arrViews.count){
        btnCancel.hidden = YES;
    }
    else{
        btnCancel.hidden = NO;
    }
        for (id value in self.arrRemainedInfo) {
            int i = [value intValue];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(origin+5, 10, btnWidth, 30);
            //btn.backgroundColor = [UIColor redColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            btn.tag = 100+i;
            [btn addTarget:self action:@selector(btnTypePressed:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btn setTitle:arrViews[i] forState:UIControlStateNormal];
            
            [btn setBackgroundImage:[UIImage imageNamed:@"btnBG-Round"] forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[UIImage imageNamed:@"btnBG-Round"] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            //[btn sizeToFit];
            CGSize stringsize = [arrViews[i] sizeWithFont:[UIFont systemFontOfSize:12]];
            //or whatever font you're using
            
            [btn setFrame:CGRectMake(btn.frame.origin.x,btn.frame.origin.y,stringsize.width+5, btn.frame.size.height)];
            origin = btn.frame.origin.x+stringsize.width+5;
                        /*--------Update selection for candidates----*/
            if (i!=0 && self.isForCandidate) {
                 btn.tag = 100+i+1;
                if (i==self.currentViewType-1) {
                    btn.selected = YES;
                }
            }
            else{
                if (i==self.currentViewType) {
                    btn.selected = YES;
                }
            }
            [viewButtons addSubview:btn];
            count++;
        }
    [self updateViewFromType];
}


-(void)btnTypePressed:(UIButton*)sender{
    
    [self.view endEditing:YES];
    NSUInteger tag = [sender tag]-100;
    if ( self.isForCandidate==YES) {
        for (UIButton *btn in viewButtons.subviews) {
            btn.selected = NO;
        }
    }
    else{
    UIButton *btn = (UIButton*)[viewButtons viewWithTag:self.currentViewType+100];
    btn.selected = NO;
    }
    sender.selected = YES;
    self.currentViewType = (ViewType)tag;
    [self updateViewFromType];
}

-(void)updateViewFromType{
    switch (self.currentViewType) {
        case INDUSTRY:
        {
            viewTable.hidden = NO;
            viewLocation.hidden = YES;
            viewExperience.hidden = YES;
            viewCompany.hidden = YES;
            [tblContacts layoutIfNeeded];
            if ([self.delegate respondsToSelector:@selector(didChangeViewType:WithType:)]) {
                [self.delegate didChangeViewType:viewTable WithType:self.currentViewType];
            }
        }
            break;
        case POSITION:
        {
            viewTable.hidden = YES;
            viewLocation.hidden = YES;
            viewExperience.hidden = YES;
            viewCompany.hidden = NO;
            lblInstruction.text = @"Add your position.";
            textName.placeholder=lblCap.text = @"Position";
            
            if ([self.delegate respondsToSelector:@selector(didChangeViewType:WithType:)]) {
                [self.delegate didChangeViewType:viewCompany WithType:self.currentViewType];
            }
        }
            break;
        case COMPANY:
        {
            viewTable.hidden = YES;
            viewLocation.hidden = YES;
            viewExperience.hidden = YES;
            viewCompany.hidden = NO;
            lblInstruction.text = @"Add your company.";
            textName.placeholder=lblCap.text = @"Company";
            
            if ([self.delegate respondsToSelector:@selector(didChangeViewType:WithType:)]) {
                [self.delegate didChangeViewType:viewCompany WithType:self.currentViewType];
            }
        }
            break;
        case LOCATION:
        {
            viewTable.hidden = YES;
            viewLocation.hidden = NO;
            viewExperience.hidden = YES;
            viewCompany.hidden = YES;
            if ([self.delegate respondsToSelector:@selector(didChangeViewType:WithType:)]) {
                [self.delegate didChangeViewType:viewLocation WithType:self.currentViewType];
            }
        }
            break;
        case EXPERIENCE:
        {
            viewTable.hidden = YES;
            viewLocation.hidden = YES;
            viewExperience.hidden = NO;
            viewCompany.hidden = YES;
            if ([self.delegate respondsToSelector:@selector(didChangeViewType:WithType:)]) {
                [self.delegate didChangeViewType:viewExperience WithType:self.currentViewType];
            }
        }
            break;
        default:
            break;
    }
}



- (void)callSetSectionkeys:(NSArray*)array{
    //NSUInteger countNumber=[[sectionsDict allKeys] count];
    sectionsDict = [[NSMutableDictionary alloc]init];
    BOOL found;
    for (NSString *clg in array) {
        NSString *c = [clg substringToIndex:1];
        found = NO;
        for (NSString *str in[sectionsDict allKeys]) {
            if ([str caseInsensitiveCompare:c] == NSOrderedSame) {
                found = YES;
            }
        }
            if (!found) {
                [sectionsDict setValue:[[NSMutableArray alloc] init] forKey:[c uppercaseString]];
            }
            [sectionsDict setValue:[[NSMutableArray alloc] init] forKey:[c uppercaseString]];
        
    }
    
    for (NSString *clg in array) {
       [[sectionsDict objectForKey:[[clg substringToIndex:1]uppercaseString]] addObject:clg];
    }
    for (NSString *key in[sectionsDict allKeys]) {
        [[sectionsDict objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Name" ascending:YES]]];
    }
    
    [tblContacts reloadData];
}



#pragma mark - Table Delegate
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (isSearchBar)
        return [arrSearch valueForKey:@"key"];
    else
        return [arrContent valueForKey:@"key"];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (isSearchBar)
        return [[arrSearch valueForKey:@"key"] indexOfObject:title];
    else
        return [[arrContent valueForKey:@"key"] indexOfObject:title];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isSearchBar)
        return [arrSearch count];
    else
        return [arrContent count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (isSearchBar)
        return [arrSearch[section] objectForKey:@"key"];
    else
        return [arrContent[section] objectForKey:@"key"];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearchBar)
        return [[arrSearch[section] objectForKey:@"value"] count];
    else
        return [[arrContent[section] objectForKey:@"value"] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tblContacts dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    if (isSearchBar)
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
    if (isSearchBar)
        strText = arrSearch[indexPath.section][@"value"][indexPath.row];
    else{
        strText = arrContent[indexPath.section][@"value"][indexPath.row];
    }
    
    if (self.isEdit) {
        self.editModel.name = strText;
        [self cancelpressed:nil];
    }
    else{
        if ([self.delegate respondsToSelector:@selector(didselectCategory:WithType:)]) {
            ContactModel *model = [[ContactModel alloc]init];
            model.name = strText;
            model.type = self.currentViewType;
            [self.delegate didselectCategory:model WithType:self.currentViewType];
        }
    }
}
#pragma mark -
#pragma mark - Text Search
-(void)searchText:(NSString *) text
{
    [arrSearch removeAllObjects];
    arrSearch = [[self filterArrayUsingText:text] mutableCopy];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    return YES;
}                     // return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar1{
    //
    //    [UIView animateWithDuration:1.0 animations:^{
    //        self.edgesForExtendedLayout = UIRectEdgeNone;
    //        self.navigationController.navigationBarHidden = YES;
    //        [tblCollege reloadSectionIndexTitles];
    //    }];
    searchBar1.showsCancelButton = YES;
    [tblContacts reloadSectionIndexTitles];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar1{
    searchBar1.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar1{
    
    //    [UIView animateWithDuration:1.0 animations:^{
    //            [tblCollege setContentInset:UIEdgeInsetsZero];
    //    }];
    
    [searchBar1 resignFirstResponder];
    [tblContacts reloadSectionIndexTitles];
}
- (void)searchBar:(UISearchBar *)searchBar1 textDidChange:(NSString *)searchText{
    if (searchText.length>0) {
        isSearchBar = YES;
        arrSearch = [[self filterArrayUsingText:searchText] mutableCopy];
        [tblContacts reloadData];
    }
    else{
        
        isSearchBar = NO;
        [tblContacts reloadData];
        [searchBar1 resignFirstResponder];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar1{
    if (searchBar1.text.length>0) {
        isSearchBar = YES;
        arrSearch = [[self filterArrayUsingText:searchBar1.text] mutableCopy];
        [tblContacts reloadData];
    }
    else{
        
        isSearchBar = NO;
        [tblContacts reloadData];
        [searchBar1 resignFirstResponder];
    }
    [searchBar1 resignFirstResponder];
}

#pragma mark - Table Search Delegate

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
        if ([theWord rangeOfString:text  options:NSCaseInsensitiveSearch].location == NSNotFound) {
            return NO;
        } else {
            return YES;
        }
       // return [theWord containsString:text];
    }];
    
    NSArray *filteredArray = [wordArray filteredArrayUsingPredicate:predicate];
    
    return filteredArray.count == 0 ? nil : filteredArray;
}

#pragma mark - Text Field Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.currentViewType == LOCATION) {
        if (textField == textCity)
        {
            [textstate becomeFirstResponder];
        }
        else if(textField == textstate)
        {
            [textCountry becomeFirstResponder];
        }
        else
            [textField resignFirstResponder];
    }
    else
        [textField resignFirstResponder];
    
    
    
    return YES;
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
           return [[sectionsDict allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return [[sectionsDict valueForKey:[[[sectionsDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [[sectionsDict valueForKey:[[[sectionsDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - sectionIndex methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        return [[[sectionsDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[[sectionsDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tempArray replaceObjectAtIndex:idx withObject:[NSString stringWithFormat:@"%@",obj]];
        }];
        
        return arrSectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
        if ([title isEqualToString:@"#"] || [title isEqualToString:@"A"]) {
            return 0;
        }
        NSLog(@"%@,returned:%lu",title,(unsigned long)[[sectionsDict allKeys]  indexOfObject:[title uppercaseString]]);
        return [[sectionsDict allKeys]  indexOfObject:title];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isEdit) {
        self.editModel.name = [[sectionsDict valueForKey:[[[sectionsDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [self cancelpressed:nil];
    }
    else{
    if ([self.delegate respondsToSelector:@selector(didselectCategory:WithType:)]) {
        ContactModel *model = [[ContactModel alloc]init];
        model.name = [[sectionsDict valueForKey:[[[sectionsDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        model.type = self.currentViewType;

        [self.delegate didselectCategory:model WithType:self.currentViewType];
    }
    }
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation
 - (void) contactsCancelled;
 -(void)didselectString:(NSString*)string WithType:(ViewType)viewtype;
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end
