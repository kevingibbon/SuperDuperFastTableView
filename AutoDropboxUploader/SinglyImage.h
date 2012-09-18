//
//  SinglyImage.h
//  AutoDropboxUploader
//
//  Created by Kevin Gibbon on 2012-09-17.
//  Copyright (c) 2012 Kevin Gibbon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SinglyImage : NSObject

@property (strong) NSURL *largeImageUrl;
@property (strong) NSURL *smallImageUrl;

+(NSArray*)imageUrlsFromArray:(NSArray*)singlyImages;

@end
