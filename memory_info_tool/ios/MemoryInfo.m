//
//  MemoryInfo.m
//  IOS端末のメモリー情報を取得する
//  シングルトンで実装した
//  MemoryWarningメッセージを受信したら、getMemoryInfo関数で返すlowMemoryは常にtrueになる
//

#import <Foundation/Foundation.h>
#import "MemoryInfo.h"
#import <mach/mach.h>
#import <mach/mach_host.h>

@implementation MemoryInfo
    
    static MemoryInfo *_instance = nil;
    
    
    
-(id)init {
    if ([super init]) {
        //_instance = self;
        [self _setupObservers];
    }
    memoryWarningFlag = false;
    
    NSLog(@"MemoryInfo init");
    return self;
}
    
- (void)dealloc{
 
    _instance = nil;
    NSLog(@"MemoryInfo dealloc");
}
    
    
+(MemoryInfo*)sharedInstance {
    if (_instance == nil) {
        _instance = [[MemoryInfo alloc] init];
    }
    return _instance;
}

//メッセージの設定
-(void)_setupObservers {
    
    //MemoryWarningを検出するための準備
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    
}

//MemoryWarningを検出したときのコールバック関数
- (void) handleMemoryWarning:(NSNotification *)notification
{
    NSLog(@"handleMemoryWarning");
    memoryWarningFlag = true;
    
    //ここに以下のようにしてUnity側にメッセージを送ってもよい
    //UnitySendMessage("GameObjectName1", "MethodName1", "Message to send");
}

//メモリ情報取得処理
- (NSString*) getMemoryInfo{
    struct host_basic_info host;
    mach_msg_type_number_t hCount = HOST_VM_INFO_COUNT;
    hCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&host, &hCount);
    
    //端末のRAM容量(MB)
    unsigned int memory_size =(unsigned int)host.memory_size / 1024 /1024;
    NSLog(@"memory_size:%u",memory_size);
    

    //タスク情報から使っているメモリ容量を取得する
    struct task_basic_info basicInfo;
    mach_msg_type_number_t basicInfoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kern =task_info(current_task(), TASK_BASIC_INFO, (task_info_t)&basicInfo, &basicInfoCount);
    if (kern != KERN_SUCCESS) {
        
        NSLog(@"getMemoryInfo error");
        
        return @"";
    }
    
    //端末で現在使用しているメモリ(MB)
    unsigned int resident_size =(unsigned int ) basicInfo.resident_size  / 1024 /1024;
    
    //メモリデータをJsonに変換する
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init] ;
    
    //使用メモリ(MB)
    [dict setObject:[NSNumber numberWithInt:resident_size] forKey:@"usageMemory"];

    //端末に積まれているRAM
    [dict setObject:[NSNumber numberWithInt:memory_size] forKey:@"deviceRam"];
    
    //MemoryWarningのフラグ
    [dict setObject:[NSNumber numberWithBool:memoryWarningFlag] forKey:@"lowMemory"];
    
    //Json変換本体
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted 
                                                         error:&error];
    NSString *jsonString = @"";
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
         jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSLog(@"memory_size:%@",jsonString);
    }
   
    return jsonString;
}
@end

