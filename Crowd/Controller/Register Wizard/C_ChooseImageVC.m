//
//  C_ChooseImageVC.m
//  Crowd
//
//  Created by MAC107 on 08/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_ChooseImageVC.h"
#import "AppConstant.h"
#import "C_UserModel.h"
#import "C_LocationVC.h"
#import "C_ProfilePreviewVC.h"
#import "DownloadManager.h"
@interface C_ChooseImageVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    __weak IBOutlet UIImageView *imgV;
    
}
@end

@implementation C_ChooseImageVC
#pragma mark - View Did Load
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Profile Picture";
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton];
    
    if ([[UserDefaults objectForKey:PROFILE_PREVIEW]isEqualToString:@"yes"])
    {
        self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(btnDoneClicked:)];
    }
    
    
    imgV.layer.cornerRadius = (imgV.bounds.size.width)/2.0;
    imgV.layer.borderWidth = 0.25;
    imgV.layer.borderColor = [UIColor clearColor].CGColor;
    [imgV setContentMode:UIViewContentModeScaleAspectFill];
    [imgV setClipsToBounds:YES];
    
    if (myUserModel.imgUserPic)
        imgV.image = myUserModel.imgUserPic;
    else if(![myUserModel.pictureUrl isEqualToString:@""])
    {
        [[DownloadManager sharedManager]downloadImagewithURL:myUserModel.pictureUrl];
        [imgV sd_setImageWithURL:myUserModel.pictureUrl];
    }
    else
        imgV.image = nil;
}

-(void)btnDoneClicked:(id)sender
{
    [self saveImage];
#warning - SAVE IMAGE HERE
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[C_ProfilePreviewVC class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}
#pragma mark - IBAction
-(void)saveImage
{
    if (imgV.image != nil)
    {
        myUserModel.imgUserPic = imgV.image;
        [CommonMethods saveMyUser:myUserModel];
        myUserModel = [CommonMethods getMyUser];
    }
    else if(![myUserModel.pictureUrl isEqualToString:@""])
    {
        [[DownloadManager sharedManager]downloadImagewithURL:myUserModel.pictureUrl];
        [imgV sd_setImageWithURL:myUserModel.pictureUrl];
    }
}
-(IBAction)btnNextClicked:(id)sender
{
    [self saveImage];
    C_LocationVC *obj = [[C_LocationVC alloc]initWithNibName:@"C_LocationVC" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}
-(IBAction)btnTake_or_Choose_Clicked:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose Existing" ,nil];
    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self TakePhoto];
            break;
        case 1:
            [self ChoosePhoto];
            break;
        default:
            break;
    }
}
-(void)ChoosePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:^{
            
        }];
    }
    else
    {
        [CommonMethods displayAlertwithTitle:@"Your device doesn't support Photo library." withMessage:nil withViewController:self];
    }
}
-(void)TakePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        picker.cameraDevice= UIImagePickerControllerCameraDeviceFront;
        picker.showsCameraControls = YES;
        picker.navigationBarHidden = NO;
        picker.delegate = self;

        [self presentViewController:picker animated:YES completion:^{
            
        }];
    }
    else
    {
        [CommonMethods displayAlertwithTitle:@"Your device doesn't support Camera." withMessage:nil withViewController:self];

    }
}

#pragma mark - Image Picker Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    if (img)
    {

        [self dismissViewControllerAnimated:YES completion:^{
            imgV.image = img;
            
            /*--- Save image with local and update flag ---*/
            myUserModel.isUpdateProfilePic = YES;
            myUserModel.imgUserPic = imgV.image;
            myUserModel.pictureUrl = @"";
           
            [CommonMethods saveMyUser:myUserModel];
            myUserModel = [CommonMethods getMyUser];
        }];
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
