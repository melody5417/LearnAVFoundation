//
//  ViewController.m
//  LeranAVFoundation
//
//  Created by Yiqi Wang on 16/9/20.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

typedef void(^GifFromVideoCompletion)(NSString *path, NSError *error);

@interface ViewController ()
@property (weak) IBOutlet NSImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.animates = YES;
    self.imageView.canDrawSubviewsIntoLayer = YES;
    

    // Do any additional setup after loading the view.
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@".mov"];
    NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
    NSArray *keys = @[@"duration"];
    
    
    AVURLAsset *anAsset = [[AVURLAsset alloc] initWithURL:url options:options];
    
    //加载准确时间长度
    [anAsset loadValuesAsynchronouslyForKeys:keys
                           completionHandler:^{
                               NSError *error = nil;
                               AVKeyValueStatus tracksStatus = [anAsset statusOfValueForKey:keys.firstObject
                                                                                      error:&error];
                               switch (tracksStatus) {
                                   case AVKeyValueStatusLoaded:
                                       NSLog(@"loaded");
                                       break;
                                   case AVKeyValueStatusFailed:
                                       NSLog(@"failed %@", error);
                                       break;
                                       
                                   default:
                                       NSLog(@"default");
                                       break;
                               }
                           }];
    
    
//    //播放视频
//    AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:anAsset automaticallyLoadedAssetKeys:keys];
//    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playItem];
//    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
//    playerLayer.frame = self.view.frame;
//    [self.view setWantsLayer:YES];
//    [self.view.layer addSublayer:playerLayer];
//
//    [player play];
    
    //生成一张静态图
//    if ([[anAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
//        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:anAsset];
//        
//        Float64 DurationSeconds = CMTimeGetSeconds([anAsset duration]);
//        CMTime midPoint = CMTimeMakeWithSeconds(DurationSeconds / 2.0, 600);
//        NSError *error;
//        CMTime acturalTime;
//        
//        CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midPoint
//                                                         actualTime:&acturalTime
//                                                              error:&error];
//        
//        
//        if (halfWayImage != NULL) {
//            NSImage *image = [[NSImage alloc] initWithCGImage:halfWayImage size:NSZeroSize];
//            NSData *imageData = [image TIFFRepresentation];
//            [imageData writeToFile:@"/Users/melody5417/Desktop/videoImage.tiff" atomically:YES];
//            NSString *actualTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, acturalTime));
//            NSString *requestedTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, midPoint));
//            NSLog(@"Got halfWayImage: Asked for %@, got %@", requestedTimeString, actualTimeString);
//            
//            // Do something interesting with the image.
//            CGImageRelease(halfWayImage);
//        }
//    }
    
    
    
//    //生成一系列图片
//    if ([[anAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
//        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:anAsset];
//        
//        Float64 durationSeconds = CMTimeGetSeconds([anAsset duration]);
//        CMTime firstThird = CMTimeMakeWithSeconds(durationSeconds - 2.0, 600);
//        CMTime secondThird = CMTimeMakeWithSeconds(durationSeconds - 1.9, 600);
//        CMTime end = CMTimeMakeWithSeconds(durationSeconds - 1.8, 600);
//        NSArray *times = @[[NSValue valueWithCMTime:kCMTimeZero],
//                           [NSValue valueWithCMTime:firstThird],
//                           [NSValue valueWithCMTime:secondThird],
//                           [NSValue valueWithCMTime:end]];
//        
//        [imageGenerator generateCGImagesAsynchronouslyForTimes:times
//                                             completionHandler:^(CMTime requestedTime,
//                                                                 CGImageRef image,
//                                                                 CMTime actualTime,
//                                                                 AVAssetImageGeneratorResult result,
//                                                                 NSError *error) {
//                                                 static int i = 0;
//                                                 NSString *requestedTimeString = (NSString *)
//                                                 CFBridgingRelease(CMTimeCopyDescription(NULL, requestedTime));
//                                                 NSString *actualTimeString = (NSString *)
//                                                 CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
//                                                 NSLog(@"Requested: %@; actual %@", requestedTimeString, actualTimeString);
//                                                 
//                                                 if (result == AVAssetImageGeneratorSucceeded) {
//                                                     // Do something interesting with the image.
//                                                     NSImage *retImage = [[NSImage alloc] initWithCGImage:image size:NSZeroSize];
//                                                     NSData *imageData = [retImage TIFFRepresentation];
//                                                     [imageData writeToFile:[NSString stringWithFormat:@"/Users/melody5417/Desktop/videoImage%d.tiff", i++] atomically:YES];
//                                                 }
//                                                 
//                                                 if (result == AVAssetImageGeneratorFailed) {
//                                                     NSLog(@"Failed with error: %@", [error localizedDescription]);
//                                                 }
//                                                 if (result == AVAssetImageGeneratorCancelled) {
//                                                     NSLog(@"Canceled");
//                                                 }
//                                             }];
//
//    }
    
    
    /**
    [self gifFromVideoAsset:anAsset
              timeIncrement:0.1
                 completion:^(NSString *path, NSError *error) {
                     if (error) {
                         NSLog(@"error %@", error);
                     } else {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
                             [self.imageView setImage:image];
                         });
                         
                     }
                 }];
     */
    
    [self cropAsset:anAsset];
}

- (void)gifFromVideoAsset:(AVURLAsset *)video
            timeIncrement:(float)increment
               completion:(GifFromVideoCompletion)completion {
    //Instantiate an AVAssetImageGenerator for the target Movie.
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:video];
    
    //Calculate the frames in the final GIF by the movie's length and the given time incremen
    float videoLength = video.duration.value / video.duration.timescale;
    int frameCount = videoLength / increment;
    float tolerance = 0.1f;
    
    //Create a temp gif file as the output destination.
    //By adding all the thumbnails to this file, we could generate the desired gif file holding the data.
    NSString *tempFile = @"/Users/melody5417/Desktop/videoTemp.gif";
    NSURL *url = [NSURL fileURLWithPath:tempFile];
    CFURLRef fileURL = (__bridge CFURLRef)(url);
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(fileURL, kUTTypeGIF, frameCount, nil);
    
    
    
    //Set properties for the generator and gif.
    generator.requestedTimeToleranceBefore = CMTimeMakeWithSeconds(tolerance, 600);
    generator.requestedTimeToleranceAfter = CMTimeMakeWithSeconds(tolerance, 600);
    generator.appliesPreferredTrackTransform = YES;
    
    NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:increment] forKey:(NSString *)kCGImagePropertyGIFDelayTime] forKey:(NSString *)kCGImagePropertyGIFDictionary];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount] forKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    //Get the size of the target Movie;
    CGSize videoSize = [[[video tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
    
    //Set the out put size of thumbnails.
    generator.maximumSize = videoSize;
    
    //Perform the converting asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSError *error = nil;
        
        //Repeatly generate thumbnail of video and put them together
        for (int i = 0 ; i < frameCount; i++) {
            
            //Time for current thumbnail
            CMTime imageTime = CMTimeMakeWithSeconds(i*increment, 600);
            
            //Generate the thumbnail
            CGImageRef image = [generator copyCGImageAtTime:imageTime actualTime:nil error:&error];
            if (error) {
                //Once there is any error during converting, stop and call back.
                completion(nil,error);
                return;
            }
            //Add current thumbnail to the destination
            CGImageDestinationAddImage(destination, image,  (CFDictionaryRef)frameProperties);
        }
        
        //set gif properties (infinite loop)
        CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
        
        //Finalize temp file
        CGImageDestinationFinalize(destination);
        
        //Release the temp file
        CFRelease(destination);
        
        //callback
        completion(tempFile,error);
    });
}

/** 裁剪视频 */
- (void)cropAsset:(AVURLAsset *)anAsset {
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:anAsset presetName:AVAssetExportPresetHighestQuality];
        // Implementation continues.
        exportSession.outputURL = [NSURL fileURLWithPath:@"/Users/melody5417/Desktop/cropVideo.mov"];
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        CMTime start = CMTimeMakeWithSeconds(1, 600);
        CMTime duration = CMTimeMakeWithSeconds(1, 600);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    break;
            }
        }];
    }
}


@end
