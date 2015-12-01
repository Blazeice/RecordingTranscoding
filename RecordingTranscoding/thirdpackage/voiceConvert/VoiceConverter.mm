//
//  VoiceConverter.m
//  RecordingTranscoding
//
//  Created by 白冰 on 15/1/3.
//  Copyright © 2015年 lezhixing. All rights reserved.
//

#import "VoiceConverter.h"
#import "wav.h"
#import "interf_dec.h"
#import "dec_if.h"
#import "interf_enc.h"
#import "amrFileCodec.h"

@implementation VoiceConverter

+ (int)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath{
    
    if (! DecodeAMRFileToWAVEFile([_amrPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding]))
        return 0;
    
    return 1;
}

+ (int)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath{
    
    if (EncodeWAVEFileToAMRFile([_wavPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
        return 0;
    
    return 1;
}

+ (int) changeStu
{
    return changeState();
}
+(void)mixMusic:(NSString*)wavPath1 andPath:(NSString*)wavePath2 toPath:(NSString *)outpath
{
    mix([wavPath1 cStringUsingEncoding:NSASCIIStringEncoding], [wavePath2 cStringUsingEncoding:NSASCIIStringEncoding],[outpath cStringUsingEncoding:NSASCIIStringEncoding]);
}

void mix(const char* FileName1, const char* Filename2,const char* output)
{
    unsigned int temp;
    
    FILE *fin1,*fin2,*fout;
    fin1 = fopen( FileName1, "rb" );
    fin2 = fopen( Filename2, "rb" );
    fout = fopen( output, "wb" );
    fseek(fin1,0,SEEK_SET);
    fseek(fin2,0,SEEK_SET);

    int length=0;
    WriteWAVEFileHeader(fout,length);
    SkipToPCMAudioData(fin2);//到数据区
    fread(&temp, 4, 1, fin2);
    length ++;
    while(!feof(fin2))//复制第一个文件
    {
        fwrite(&temp, 4, 1, fout);
        fread(&temp, 4, 1, fin2);
        length ++;
    }
    fclose(fin2);
    
    SkipToPCMAudioData(fin1);//到数据区
    fread(&temp,4,1,fin1);//读取
    length++;
    while(!feof(fin1))//复制第二个文件
    {
        fwrite(&temp,4,1,fout);
        fread(&temp,4,1,fin1);
        length++;
    }
    fclose(fin1);
    fclose(fout);
    fout = fopen(output, "r+");
    WriteWAVEFileHeader(fout,length);
    fclose(fout);
}
+(void)mixAmr:(NSString *)amrPath1 andPath:(NSString *)amrPath2
{
    WriteTwoAMRFileToOneAMRFile([amrPath1 cStringUsingEncoding:NSASCIIStringEncoding], [amrPath2 cStringUsingEncoding:NSASCIIStringEncoding]);
}
void WriteTwoAMRFileToOneAMRFile(const char* AMROneFileNameA,const char* AMROneFileNameB) {
    FILE *fpamrA;
    FILE *fpamrB;
    char magic[8];
    unsigned char amrFrame[MAX_AMR_FRAME_SIZE];
	fpamrA = fopen(AMROneFileNameA, "ab+");
    if (fpamrA == NULL) {
        return;
    }
	fpamrB = fopen(AMROneFileNameB, "rb");
    if (fpamrB == NULL) {
        return;
    }
    // 检查amr文件头
	fread(magic, sizeof(char), strlen(AMR_MAGIC_NUMBER), fpamrB);
	if (strncmp(magic, AMR_MAGIC_NUMBER, strlen(AMR_MAGIC_NUMBER)))
	{
		fclose(fpamrB);
        return;
	}
    fseek(fpamrB, 6L, 0);
    while (1) {
        long i = (long)fread(amrFrame, sizeof(char), strlen(AMR_MAGIC_NUMBER), fpamrB);
        if (i) {
            fwrite(amrFrame, sizeof (unsigned char), strlen(AMR_MAGIC_NUMBER), fpamrA);
        }
        else break;
    }
    fclose(fpamrA);
    fclose(fpamrB);
}
@end
