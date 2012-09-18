//
//  SinglyEngine.m
//  AutoDropboxUploader
//
//  Created by Kevin Gibbon on 2012-09-16.
//  Copyright (c) 2012 Kevin Gibbon. All rights reserved.
//

#import "SinglyEngine.h"
#import "SinglyImage.h"

@implementation SinglyEngine

-(void) imagesForKey:(NSString*) key onCompletion:(SinglyImagesResponseBlock) imageURLBlock onError:(MKNKErrorBlock) errorBlock {
    
    MKNetworkOperation *op = [self operationWithPath:SINGLY_IMAGE_URL([key urlEncodedString]) params:nil httpMethod:@"GET" ssl:YES];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        NSMutableArray *singlyImages = [[NSMutableArray alloc] init];
        if (response != nil)
        {
            id nextObject;
            NSEnumerator *enumerator = [response objectEnumerator];
            while ((nextObject = [enumerator nextObject]) != nil)
            {
                NSDictionary *dataDict = nextObject;
                NSDictionary *oembedDict = [[dataDict objectForKey:@"data"] objectForKey:@"images"];
                if ([oembedDict isKindOfClass:[NSArray class]])
                {
                    id nextObject;
                    NSEnumerator *enumerator = [oembedDict objectEnumerator];
                    long largeSize = -1;
                    long smallSize = -1;
                    NSString *largeImageUrl;
                    NSString *smallImageUrl;
                    while ((nextObject = [enumerator nextObject]) != nil)
                    {
                        NSDictionary *imageDict = nextObject;
                        long height = [((NSNumber*)[imageDict objectForKey:@"height"]) longValue];
                        long width = [((NSNumber*)[imageDict objectForKey:@"width"]) longValue];
                        if ((largeSize == -1) || ((height * width) > largeSize))
                        {
                            largeSize = height * width;
                            largeImageUrl = [imageDict objectForKey:@"source"];
                        }
                        if ((smallSize == -1) || ((height * width) < smallSize))
                        {
                            smallSize = height * width;
                            smallImageUrl = [imageDict objectForKey:@"source"];
                        }
                    }
                    SinglyImage *singlyImage = [[SinglyImage alloc] init];
                    [singlyImage setLargeImageUrl:[NSURL URLWithString:largeImageUrl]];
                    [singlyImage setSmallImageUrl:[NSURL URLWithString:smallImageUrl]];
                    [singlyImages addObject:singlyImage];
                }
                else if ([oembedDict objectForKey:@"standard_resolution"])
                {
                    SinglyImage *singlyImage = [[SinglyImage alloc] init];
                    [singlyImage setLargeImageUrl:[NSURL URLWithString:[[oembedDict objectForKey:@"standard_resolution"] objectForKey:@"url"]]];
                    [singlyImage setSmallImageUrl:[NSURL URLWithString:[[oembedDict objectForKey:@"thumbnail"] objectForKey:@"url"]]];
                    [singlyImages addObject:singlyImage];
                }
                if (!oembedDict && [[[dataDict objectForKey:@"data"] objectForKey:@"entities"] objectForKey:@"media"])
                {
                    NSArray *mediaDict = [[[dataDict objectForKey:@"data"] objectForKey:@"entities"]objectForKey:@"media"];
                    NSDictionary *dict = [[mediaDict objectEnumerator] nextObject];
                    NSString *imageUrl = [dict objectForKey:@"media_url"];
                    //large or thumb
                    
                    SinglyImage *singlyImage = [[SinglyImage alloc] init];
                    [singlyImage setLargeImageUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@:large", imageUrl]]];
                    [singlyImage setSmallImageUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@:thumb", imageUrl]]];
                    [singlyImages addObject:singlyImage];
                }
            }
        }
        imageURLBlock(singlyImages);
        
    } onError:^(NSError *error) {
        
        errorBlock(error);
    }];
    
    [self enqueueOperation:op];
}

-(NSString*) cacheDirectoryName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:@"SinglyImages"];
    return cacheDirectoryName;
}

@end
