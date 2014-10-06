//
//  ContactsViewController.h
//  dynamicTable
//
//  Created by Mac009 on 9/29/14.
//  Copyright (c) 2014 Tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstant.h"
#import "ContactModel.h"
#import "UITextFieldExtended.h"
@protocol ContactsDelegate <NSObject>
@required
- (void) contactsCancelled;
-(void)didselectCategory:(ContactModel*)contactModel WithType:(ViewType)viewtype;
-(void)didChangeViewType:(UIView*)view WithType:(ViewType)viewtype;
@end

@interface ContactsViewController : UIViewController<UISearchBarDelegate>
{
    id <ContactsDelegate> _delegate;
    NSMutableArray *arrSectionTitles,*arrSearch;
    NSMutableDictionary *sectionsDict;
    NSMutableArray *arrContent;
    NSArray *arrViews;

    BOOL isSearchBar;
    IBOutlet UISearchBar *searchBarCategory;
    
    IBOutlet UIButton *btnCancel;
    
    //----------ViewSelections------------//
    IBOutlet UIView *viewButtons;

    //----------ViewLocation------------//
    
    IBOutlet UITextFieldExtended *textCity;
    IBOutlet UITextFieldExtended *textstate;
    IBOutlet UITextFieldExtended *textCountry;
    
    //----------ViewCompany------------//
    
    IBOutlet UILabel *lblCap;
    IBOutlet UILabel *lblInstruction;
    IBOutlet UITextFieldExtended *textName;
}
@property (strong, nonatomic) IBOutlet UIView *viewExperience;
@property (nonatomic,strong)IBOutlet UIView *viewLocation;
@property (strong, nonatomic) IBOutlet UIView *viewCompany;
@property(strong,nonatomic)IBOutlet UITableView *tblContacts;
@property (strong, nonatomic) IBOutlet UIView *viewTable;
@property (nonatomic,strong) id delegate;
@property(nonatomic)ViewType currentViewType;
@property(nonatomic,strong)ContactModel *editModel;
@property(nonatomic)BOOL isEdit,isForCandidate;
@property (nonatomic,strong)NSMutableArray *arrRemainedInfo;

- (IBAction)cancelpressed:(id)sender;
- (IBAction)btnAddloCationPressed:(id)sender;
- (IBAction)btnExperiencePressed:(id)sender;
- (IBAction)btnDonePressed:(id)sender;

@end
