//
//  UnityBridgeMemoryInfo.m
//  Unityからの呼び出し用に作成した
//

#import <Foundation/Foundation.h>
#import "MemoryInfo.h"
#import "UnityBridgeMemoryInfo.h"

//Memory情報取得
char* _UnityMemoryInfo()
{
    MemoryInfo *memoryInfo = [MemoryInfo sharedInstance];
    NSString *data = [memoryInfo getMemoryInfo];
    
    //Unityに文字列を返すためにcharに変換する
    char* resultString = CharStringCopy(data);
    
    
    return resultString;
}

char* CharStringCopy(NSString* s)
{
    char* ret = NULL;
    
    const char* src = [s UTF8String];
    if(src){
        ret = (char*)malloc(strlen(src) + 1);
        strcpy(ret, src);
    }
    return ret;
}

