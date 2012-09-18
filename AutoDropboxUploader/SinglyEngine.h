//
//  SinglyEngine.h
//  AutoDropboxUploader
//
//  Created by Kevin Gibbon on 2012-09-16.
//  Copyright (c) 2012 Kevin Gibbon. All rights reserved.
//

#import "MKNetworkEngine.h"

@interface SinglyEngine : MKNetworkEngine

#define SINGLY_IMAGE_URL(__KEY__) [NSString stringWithFormat:@"v0/types/photos_feed?access_token=%@", __KEY__]

typedef void (^SinglyImagesResponseBlock)(NSMutableArray* imageURLs);
-(void) imagesForKey:(NSString*) key onCompletion:(SinglyImagesResponseBlock) imageURLBlock onError:(MKNKErrorBlock) errorBlock;

@end
