//
//  CQVoiceConverter.m
//  Chat
//
//  Created by 刘超群 on 2020/2/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import "CQVoiceConverter.h"
#import "hdwav.h"
#import "hdinterf_dec.h"
#import "hddec_if.h"
#import "hdinterf_enc.h"
#import "hdamrFileCodec.h"

@implementation CQVoiceConverter

+ (BOOL)isMP3File:(NSString *)filePath{
    const char *_filePath = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
    if (HDisMP3File(_filePath) == 0) {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)isAMRFile:(NSString *)filePath{
    const char *_filePath = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
    if (HDisAMRFile(_filePath) == 0) {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)amrToWav:(NSString*)amrPath wavSavePath:(NSString*)savePath{
    if (HDEM_DecodeAMRFileToWAVEFile([amrPath cStringUsingEncoding:NSASCIIStringEncoding], [savePath cStringUsingEncoding:NSASCIIStringEncoding])){
        return YES; // success
    }else{
        return NO;   // failed
    }
}

+ (BOOL)wavToAmr:(NSString*)wavPath amrSavePath:(NSString*)savePath{
    if (HDEM_EncodeWAVEFileToAMRFile([wavPath cStringUsingEncoding:NSASCIIStringEncoding], [savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16)){
        return YES;   // success
    }else{
        return NO;   // failed
    }
}
@end
