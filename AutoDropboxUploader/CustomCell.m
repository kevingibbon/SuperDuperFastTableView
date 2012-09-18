//
//  CustomCell.m
//  AutoDropboxUploader
//
//  Created by Kevin Gibbon on 2012-09-16.
//  Copyright (c) 2012 Kevin Gibbon. All rights reserved.
//

#import "CustomCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CustomCell()

@property (nonatomic, strong) MKNetworkOperation* largeImageLoadingOperation;
@property (nonatomic, strong) MKNetworkOperation* smallImageLoadingOperation;



@end

@implementation CustomCell
@synthesize picture = _picture;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.picture setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void) prepareForReuse {
    self.displayingSmallImage = YES;
    self.picture.image = nil;
    [self.smallImageLoadingOperation cancel];
    [self.largeImageLoadingOperation cancel];
}

-(void) setSinglyData:(SinglyImage*) singlyImageData imagesToLoad:(NSMutableArray*)imagesToLoad onlySmallImages:(BOOL)onlySmallImages {
    if (!singlyImageData) return;
    self.displayingSmallImage = onlySmallImages;
    if (singlyImageData.largeImageUrl && !singlyImageData.smallImageUrl)
    {
        self.loadingImageSmallURLString = singlyImageData.largeImageUrl;
        self.loadingImageLargeURLString = singlyImageData.largeImageUrl;
    }
    else if (!singlyImageData.largeImageUrl && singlyImageData.smallImageUrl)
    {
        self.loadingImageSmallURLString = singlyImageData.smallImageUrl;
        self.loadingImageLargeURLString = singlyImageData.smallImageUrl;
    }
    else if (singlyImageData.largeImageUrl && singlyImageData.smallImageUrl)
    {
        self.loadingImageSmallURLString = singlyImageData.smallImageUrl;
        self.loadingImageLargeURLString = singlyImageData.largeImageUrl;
    }
    else return;

    if (self.loadingImageSmallURLString)
    {
        self.smallImageLoadingOperation = [ApplicationDelegate.smallImageEngine imageAtURL:self.loadingImageSmallURLString retryAttempt:1 onCompletion:^(UIImage *fetchedImage, NSURL *url, BOOL isInCache) {
            if([[self.loadingImageSmallURLString absoluteString] isEqualToString:[url absoluteString]])
            {
                if (!self.picture.image)
                {
                    [self.picture setImage:fetchedImage];
                    self.parentViewController.prefetchSmallImages = YES;
                }
                [imagesToLoad removeObject:url];
            }
        }];
    }
    if (self.loadingImageLargeURLString && !onlySmallImages)
    {
        self.largeImageLoadingOperation = [ApplicationDelegate.largeImageEngine imageAtURL:self.loadingImageLargeURLString retryAttempt:1 onCompletion:^(UIImage *fetchedImage, NSURL *url, BOOL isInCache) {
            if([[self.loadingImageLargeURLString absoluteString] isEqualToString:[url absoluteString]])
            {
                [self.smallImageLoadingOperation cancel];
                [imagesToLoad removeObject:url];
                [self.picture setImage:fetchedImage];
                self.parentViewController.prefetchLargeImage = YES;
            }
        }];
    }
}

@end
