//
//  CCUploadFile.m
//  CCClassRoom
//
//  Created by cc on 17/8/8.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCUploadFile.h"
#import "CCPhotoNotPermissionVC.h"
#import <Photos/Photos.h>
#import <AFNetworking.h>
#import <CCClassRoom/CCClassRoom.h>
#import "CCDoc.h"
#import "CCDocListViewController.h"
#import "TZImagePickerController.h"
#import "AppDelegate.h"

@interface CCUploadFile()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CCUploadFileBlock _completion;
}
@property (strong, nonatomic)UINavigationController *navigationController;
@property (strong, nonatomic)UIImagePickerController *picker;
@property (strong, nonatomic)NSString *roomID;
@property (assign, nonatomic)BOOL isUploading;
@end

@implementation CCUploadFile
- (void)uploadImage:(UINavigationController *)nav roomID:(NSString *)roomID completion:(CCUploadFileBlock)completion
{
    if (self.isUploading)
    {
        if (completion)
        {
            completion(NO);
        }
    }
    else
    {
        _completion = completion;
        self.navigationController = nav;
        self.roomID = roomID;
        [self selectImage];
    }
}

- (void)selectImage
{
    __block CCPhotoNotPermissionVC *_photoNotPermissionVC;
    WS(ws)
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch(status) {
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if(status == PHAuthorizationStatusAuthorized) {
                    [ws pickImage];
                } else if(status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                    _photoNotPermissionVC = [CCPhotoNotPermissionVC new];
                    [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized: {
            [ws pickImage];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied: {
            NSLog(@"4");
            _photoNotPermissionVC = [CCPhotoNotPermissionVC new];
            [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
        }
            break;
        default:
            break;
    }
}

-(void)pickImage {
#ifndef USELOCALPHOTOLIBARY
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
       [ws pushImagePickerController];
    });
#else
    if([self isPhotoLibraryAvailable]) {
        _picker = [[UIImagePickerController alloc]init];
        _picker.view.backgroundColor = [UIColor clearColor];
        UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        _picker.sourceType = sourcheType;
        _picker.delegate = self;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController presentViewController:_picker animated:YES completion:nil];
        });
    }
#endif
}

//支持相片库
- (BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __block UIImage *image= [info objectForKey:UIImagePickerControllerOriginalImage];
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        //发送图片
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"%@", info);
            NSString *name = [self randomName:0];
            NSString *url = @"http://document.csslcloud.net/servlet/image/upload";
            url = [NSString stringWithFormat:@"%@?roomid=%@&file=%@", url,ws.roomID,name];
            [ws sendImage:image url:url name:name];
        });
        ws.picker = nil;
    }];
}

- (void)sendImage:(UIImage *)image url:(NSString *)url name:(NSString *)name
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:url relativeToURL:manager.baseURL] absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSData *data = [CCUploadFile zipImageWithImage:image];
            NSLog(@"send pic size :%lu", (unsigned long)data.length);
             [formData appendPartWithFileData:data name:@"file" fileName:name mimeType:@"image/jpeg"];
//            NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pptx"];
//            NSData *data = [NSData dataWithContentsOfFile:path];
//            [formData appendPartWithFileData:data name:@"file" fileName:name mimeType:@"application/vnd.sealed-ppt"];
        });
    } error:&serializationError];
    
    if (serializationError)
    {
        NSLog(@"%s__%d__%@", __func__, __LINE__, serializationError);
    }
    WS(ws);
    NSProgress *progress = nil;
    __block NSURLSessionDataTask *task = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        [progress removeObserver:ws forKeyPath:@"fractionCompleted"];
        if (error) {
            if (_completion)
            {
                _completion(NO);
            }
        } else {
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            NSLog(@"%s__%d__%@", __func__, __LINE__, info);
            NSError *err;
            id jsonValue = [NSJSONSerialization JSONObjectWithData:responseObject
                                                           options:NSJSONReadingMutableLeaves
                                                             error:&err];
            if ([jsonValue[@"result"] isEqualToString:@"OK"])
            {
                NSString *docid = [jsonValue objectForKey:@"docId"];
                [ws getProWithDocID:docid];
            }
            CCLog(@"dic:%@__%@", jsonValue, err);
        }
    }];
    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    [task resume];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        ws.picker = nil;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"])
    {
        NSLog(@"%s__%@__%@", __func__, change, object);
        NSProgress *pro = object;
        CGFloat percent = pro.fractionCompleted;
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiUploadFileProgress object:nil userInfo:@{@"pro":@(percent)}];
        if (percent == 1)
        {
            [pro removeObserver:self forKeyPath:@"fractionCompleted"];
        }
    }
}

#pragma mark - get progress
- (void)getProWithDocID:(NSString *)docID
{
    WS(ws);
    [[CCStreamer sharedStreamer] getRoomDoc:docID roomID:nil completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSString *result = [info objectForKey:@"result"];
            if ([result isEqualToString:@"OK"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiUploadFileProgress object:nil userInfo:@{@"pro":@(2)}];
                NSLog(@"%s__%@", __func__, info);
                NSDictionary *dic = info;
                NSString *picDomain = [dic objectForKey:@"picDomain"];
                NSDictionary *doc = [dic objectForKey:@"doc"];
                CCDoc *newDoc = [[CCDoc alloc] initWithDic:doc picDomain:picDomain];
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":newDoc, @"page":@(0)}];
                ws.isUploading = NO;
                if (_completion)
                {
                    _completion(YES);
                }
            }
            else if ([result isEqualToString:@"CONVERT"])
            {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    sleep(0.5f);
                   [ws getProWithDocID:docID];
                });
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiUploadFileProgress object:nil userInfo:@{@"pro":@(2)}];
                if (_completion)
                {
                    _completion(NO);
                }
            }
        }
    }];
}

- (NSString *)randomName:(int)len
{
    return [NSString stringWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970]];
}

+ (NSData *)zipImageWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGFloat maxFileSize = 5*1024*1024;
    CGFloat compression = 0.9f;
    NSData *compressedData = UIImageJPEGRepresentation(image, compression);
    while ([compressedData length] > maxFileSize) {
        compression *= 0.9;
        compressedData = UIImageJPEGRepresentation([[self class] compressImage:image newWidth:image.size.width*compression], compression);
    }
    return compressedData;
}

+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

- (void)pushImagePickerController {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.allowEdited = NO;
    __weak typeof(self) weakSelf = self;
    __weak typeof(TZImagePickerController *) weakPicker = imagePickerVc;
//    if (self.isLandSpace)
//    {
//        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        appdelegate.shouldNeedLandscape = NO;
//        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
//    }
    WS(ws);
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [weakPicker dismissViewControllerAnimated:YES completion:^{
//            if (ws.isLandSpace)
//            {
//                AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                appdelegate.shouldNeedLandscape = YES;
//                NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
//                [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
//            }
            if (photos.count > 0)
            {
                weakSelf.isUploading = YES;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSString *name = [self randomName:0];
                    NSString *url = @"http://document.csslcloud.net/servlet/image/upload";
                    url = [NSString stringWithFormat:@"%@?roomid=%@&file=%@", url,weakSelf.roomID,name];
                    [weakSelf sendImage:photos.lastObject url:url name:name];
                });
            }
        }];
    }];
    [imagePickerVc setImagePickerControllerDidCancelHandle:^{
//        if (ws.isLandSpace)
//        {
//            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            appdelegate.shouldNeedLandscape = YES;
//            NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
//            [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//            [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
//        }
    }];
    
    [self.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
}
@end
