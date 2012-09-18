//
//  CustomCell.h
//  AutoDropboxUploader
//
//  Created by Kevin Gibbon on 2012-09-16.
//  Copyright (c) 2012 Kevin Gibbon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "SinglyImage.h"

@interface CustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (nonatomic) BOOL displayingSmallImage;
@property (nonatomic, strong) NSURL *loadingImageSmallURLString;
@property (nonatomic, strong) NSURL *loadingImageLargeURLString;
@property (weak, nonatomic) ViewController *parentViewController;
-(void) setSinglyData:(SinglyImage*) singlyImageData imagesToLoad:(NSMutableArray*)imagesToLoad onlySmallImages:(BOOL)onlySmallImages;

@end
