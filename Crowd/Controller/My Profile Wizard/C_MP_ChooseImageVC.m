//
//  C_MP_ChooseImageVC.m
//  Crowd
//
//  Created by MAC107 on 24/09/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "C_MP_ChooseImageVC.h"
#import "AppConstant.h"
#import "C_MyProfileVC.h"
#import "UpdateProfile.h"
#import "C_MP_LocationVC.h"
@interface C_MP_ChooseImageVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    __weak IBOutlet UIImageView *imgV;
    
}

@end

@implementation C_MP_ChooseImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    /*--- nil image object ---*/
    imgProfilePictureToUpdate = nil;
    
    self.title = @"Profile Picture";
    
    self.navigationItem.leftBarButtonItem =  [CommonMethods backBarButtton_NewNavigation:self withSelector:@selector(back)];
    self.navigationItem.rightBarButtonItem = [CommonMethods createRightButton_withVC:self withText:@"Done" withSelector:@selector(doneClicked)];

    
    imgV.layer.cornerRadius = (imgV.bounds.size.width)/2.0;
    imgV.layer.borderWidth = 0.25;
    imgV.layer.borderColor = [UIColor clearColor].CGColor;
    [imgV setContentMode:UIViewContentModeScaleAspectFill];
    [imgV setClipsToBounds:YES];
    
    if(![_obj_ProfileUpdate.PhotoURL isEqualToString:@""])
    {
        [imgV sd_setImageWithURL:[NSString stringWithFormat:@"%@%@",IMG_BASE_URL,[CommonMethods makeThumbFromOriginalImageString:_obj_ProfileUpdate.PhotoURL]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    }
    else
        imgV.image = nil;
}
-(void)back
{
    popView;
}
-(void)doneClicked
{
    UpdateProfile *profile = [[UpdateProfile alloc]init];
    [profile updateProfile_WithModel:_obj_ProfileUpdate withSuccessBlock:^{
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[C_MyProfileVC class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
    } withFailBlock:^(NSString *strError) {
        [CommonMethods displayAlertwithTitle:strError withMessage:nil withViewController:self];
    }];
}


#pragma mark - IBAction
-(IBAction)btnNextClicked:(id)sender
{
    C_MP_LocationVC *obj = [[C_MP_LocationVC alloc]initWithNibName:@"C_MP_LocationVC" bundle:nil];
    obj.obj_ProfileUpdate = _obj_ProfileUpdate;
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
            imgProfilePictureToUpdate = imgV.image;
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
    // Dispose of any resources that can be recreated.
}
@end
