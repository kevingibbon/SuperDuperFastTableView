//
//  ViewController.m
//  AutoDropboxUploader
//
//  Created by Kevin Gibbon on 2012-09-16.
//  Copyright (c) 2012 Kevin Gibbon. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"
#import "SinglyImage.h"

#define FACEBOOK_KEY @"SndQKvjQYlc4gsQ3J1s2ukFwYJI=dAn_RXJj0072c3a5062f9902aadec411a65b786fdaa940e5f915f3b41e8954fe0ac7281864eec492d598c334cecbc9d4b173004ac6f94537bc7b931bf88c57ab76791420616f173f2c8b990c4c239f0fc66f88bc7e216e98367e4eac9f9cd5551697889cb3f11478f1806f6e5a79b6f6574f2a88"
#define INSTAGRAM_KEY @"vKhUIuVUPmBw5VVW4Gm9n9-Lfbc=P9m8G62Xcb4dbc938d68014bf85701b93bddcd7f3c7a9f90124f65250ad949357ae3b175c7c66ba4de91c549875868a398544d6a1407f5ffd8947803137fe556233d2ecfd6e8590170012d233c9244986936a06b28b8e43264322075c3ef9a904c11e5f9ccfaf8d9e6bde83055b11f9a36e735ab"
#define TWITTER_KEY @"TcJ4hjitilb6w1TgFPRVGZwA8T4=2Tw8zaR2c7909fe7d2de31a88cb9956b9887a0d842083cd1a593a8ec1f76d127b8f93f5863b3e42881c8f2d6317cad685a312924362bf346d8e1212032c4eee59e753fee8c49564a508c24fde3b05a99c7844da9f20cfa57d6733b4c2c1b2f1b2bbd360b8b524aff85165ed28fac774f29a88077"
#define kNumberOfImagesToPrefetch 6
#define kScrollBarVelocityTarget 3.0

@interface ViewController ()
{
    NSMutableArray *singlyImages;
    NSMutableArray *imagesNotLoaded;
    BOOL scrollingDown;
    NSArray *keys;
    NSInteger currentRow;
    CGFloat scrollBarVelocity;
    CGFloat lastScrollBarPosition;
    NSTimer *prefetchTimer;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentRow = 0;
    lastScrollBarPosition = -1;
    scrollingDown = YES;
    singlyImages = [[NSMutableArray alloc] init];
    imagesNotLoaded = [[NSMutableArray alloc] init];
    keys = [[NSArray alloc] initWithObjects:FACEBOOK_KEY,INSTAGRAM_KEY, TWITTER_KEY, nil];
	
}

- (void)viewDidAppear:(BOOL)animated
{
    __block int numberOfKeysCompleted = 0;
    for (NSString *key in keys)
    {
        [ApplicationDelegate.singlyEngine imagesForKey:key onCompletion:^(NSMutableArray* newImages) {
        
            [singlyImages addObjectsFromArray:newImages];
            [imagesNotLoaded addObjectsFromArray:[SinglyImage imageUrlsFromArray:newImages]];
            numberOfKeysCompleted++;
            if (numberOfKeysCompleted == [keys count])
            {
                self.prefetchSmallImages = YES;
                self.prefetchLargeImage = YES;
                [self.tableView reloadData];
                if (prefetchTimer) [prefetchTimer invalidate];
                prefetchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                 target:self
                                                               selector:@selector(checkForPrefetchImages)
                                                               userInfo:nil
                                                                repeats:YES];
            }
        }
                                           onError:^(NSError* error) {
                                               NSLog(@"%@", error);
                                           }];
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 350.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CustomCell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (scrollBarVelocity > kScrollBarVelocityTarget)
    {
        [cell setSinglyData:[singlyImages objectAtIndex:indexPath.row] imagesToLoad:imagesNotLoaded onlySmallImages:YES];
    }
    else
    {
        [cell setSinglyData:[singlyImages objectAtIndex:indexPath.row] imagesToLoad:imagesNotLoaded onlySmallImages:NO];
    }
    [cell setParentViewController:self];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [singlyImages count];
}

#warning TODO scroll to top by pressing clock does not load large images
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    for (CustomCell *cell in [self.tableView visibleCells])
    {
        if (cell.displayingSmallImage)
        {
            [cell setSinglyData:[singlyImages objectAtIndex:[self.tableView indexPathForCell:cell].row] imagesToLoad:imagesNotLoaded onlySmallImages:NO];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (lastScrollBarPosition == -1)
    {
        lastScrollBarPosition = _tableView.contentOffset.y;
    }
    if (scrollBarVelocity < kScrollBarVelocityTarget)
    {
        scrollBarVelocity = abs(_tableView.contentOffset.y - lastScrollBarPosition);
        if (scrollBarVelocity >= kScrollBarVelocityTarget)
        {
            for (CustomCell *cell in [self.tableView visibleCells])
            {
                [cell setSinglyData:[singlyImages objectAtIndex:[self.tableView indexPathForCell:cell].row] imagesToLoad:imagesNotLoaded onlySmallImages:YES];
            }
        }
    }
    else
    {
        scrollBarVelocity = abs(_tableView.contentOffset.y - lastScrollBarPosition);
        if (scrollBarVelocity <= kScrollBarVelocityTarget)
        {
            for (CustomCell *cell in [self.tableView visibleCells])
            {
                [cell setSinglyData:[singlyImages objectAtIndex:[self.tableView indexPathForCell:cell].row] imagesToLoad:imagesNotLoaded onlySmallImages:NO];
            }
        }
    }
    
    lastScrollBarPosition = _tableView.contentOffset.y;
    
    if ([imagesNotLoaded count] <= 0) return;
    int rowToDisplay = (int) fabsf(roundf(_tableView.contentOffset.y / 350.0));
    if (rowToDisplay < currentRow)
    {
        scrollingDown = NO;
    }
    else
    {
        scrollingDown = YES;
    }
    if (rowToDisplay != currentRow)
    {
        currentRow = rowToDisplay;
        self.prefetchLargeImage = YES;
        self.prefetchSmallImages = YES;
    }
}

-(void)checkForPrefetchImages
{
    if ([imagesNotLoaded count] <= 0)
    {
        [prefetchTimer invalidate];
        return;
    }
    if (self.prefetchSmallImages)
    {
        self.prefetchSmallImages = NO;
        [self prefetchImagesForEngine:ApplicationDelegate.smallImageEngine];
    }
    if (self.prefetchLargeImage)
    {
        self.prefetchLargeImage = NO;
        [self prefetchImagesForEngine:ApplicationDelegate.largeImageEngine];
    }
}

-(void)prefetchImagesForEngine:(MKNetworkEngine*)singlyImageEngine
{
    bool cellsImagesLoaded = YES;
    NSMutableArray *cancelImages = [[NSMutableArray alloc] initWithArray:imagesNotLoaded];
    for (CustomCell *cell in [self.tableView visibleCells])
    {
        [cancelImages removeObject:cell.loadingImageLargeURLString];
        [cancelImages removeObject:cell.loadingImageSmallURLString];
        if (!cell.picture.image)
        {
            cellsImagesLoaded = NO;
        }
    }
    NSMutableArray *preloadUrls = [[NSMutableArray alloc] init];
    NSMutableArray *finalPreloadUrls = [[NSMutableArray alloc] init];
    // if the current displayed cells are not loaded, do not prefetch
    if (cellsImagesLoaded)
    {
        int currentIndex = currentRow;
        while ([finalPreloadUrls count] < kNumberOfImagesToPrefetch)
        {
            int numToFetch = kNumberOfImagesToPrefetch - [finalPreloadUrls count];
            if (scrollingDown)
            {
                numToFetch = MIN([singlyImages count] - currentIndex, numToFetch);
                // reached end of list to prefetch
                #warning TODO start prefetch opposite way
                if (currentIndex > [singlyImages count])
                {
                    return;
                }
                [preloadUrls addObjectsFromArray:[singlyImages subarrayWithRange:NSMakeRange(currentIndex, numToFetch)]];
            }
            else
            {
                if (currentIndex - numToFetch < 0)
                {
                    numToFetch = currentIndex;
                }
                if (currentIndex + numToFetch > [singlyImages count])
                {
                    numToFetch = [singlyImages count] - currentIndex;
                }
                // reached end of list to prefetch
                #warning TODO start prefetch opposite way
                if (currentIndex - numToFetch > [singlyImages count])
                {
                    return;
                }
                [preloadUrls addObjectsFromArray:[singlyImages subarrayWithRange:NSMakeRange(currentIndex - numToFetch, numToFetch)]];
            }
            //Create list of Prefetch URLs that have not been loaded
        
            for (NSURL *notLoadedImage in imagesNotLoaded)
            {
                NSURL *urlToAdd;
                for (SinglyImage *image in preloadUrls)
                {
                    if (singlyImageEngine == ApplicationDelegate.smallImageEngine && [image.smallImageUrl isEqual:notLoadedImage])
                    {
                        urlToAdd = image.smallImageUrl;
                        break;
                    }
                    else if (singlyImageEngine == ApplicationDelegate.largeImageEngine && [image.largeImageUrl isEqual:notLoadedImage])
                    {
                        urlToAdd = image.largeImageUrl;
                        break;
                    }
                }
                if (urlToAdd)
                {
                    [finalPreloadUrls addObject:urlToAdd];
                }
            }
            currentIndex += kNumberOfImagesToPrefetch - [finalPreloadUrls count];
        }
    }
    
    for (SinglyImage *potentialPreloadImage in finalPreloadUrls)
    {
        if ([cancelImages containsObject:potentialPreloadImage])
        {
            [cancelImages removeObject:potentialPreloadImage];
        }
    }
    [singlyImageEngine cancelPreloadCacheOperations:cancelImages];
    
    [singlyImageEngine preloadOperationsIntoCache:finalPreloadUrls retryAttempt:1 onCompletion:^{
        for (NSURL *preloadedImage in finalPreloadUrls)
        {
            if ([imagesNotLoaded containsObject:preloadedImage])
            {
                [imagesNotLoaded removeObject:preloadedImage];
            }
        }
        if (singlyImageEngine == ApplicationDelegate.largeImageEngine)
        {
            self.prefetchLargeImage = YES;
        }
        else if (singlyImageEngine == ApplicationDelegate.smallImageEngine)
        {
            self.prefetchSmallImages = YES;
        }
    }];
}

@end
