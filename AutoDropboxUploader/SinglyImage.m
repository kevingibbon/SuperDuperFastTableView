//
//  SinglyImage.m
//  AutoDropboxUploader
//
//  Created by Kevin Gibbon on 2012-09-17.
//  Copyright (c) 2012 Kevin Gibbon. All rights reserved.
//

#import "SinglyImage.h"

@implementation SinglyImage

+(NSArray*)imageUrlsFromArray:(NSArray*)singlyImages
{
    NSMutableArray *singlyImageLargeUrls = [[NSMutableArray alloc] init];
    for (SinglyImage* singlyImage in singlyImages)
    {
        if (singlyImage.largeImageUrl)
        {
            [singlyImageLargeUrls addObject:singlyImage.largeImageUrl];
        }
        if (singlyImage.smallImageUrl)
        {
             [singlyImageLargeUrls addObject:singlyImage.smallImageUrl];
        }
    }
    return singlyImageLargeUrls;
}

-(BOOL) isEqual:(id)object {
    SinglyImage *otherObject = object;
    NSString *uniqueId = [NSString stringWithFormat:@"%@%@", [self.largeImageUrl absoluteString], [self.smallImageUrl absoluteString]];
    NSString *otherUniqueId = [NSString stringWithFormat:@"%@%@", [otherObject.largeImageUrl absoluteString], [otherObject.smallImageUrl absoluteString]];
    return [uniqueId isEqualToString:otherUniqueId];
}

@end
