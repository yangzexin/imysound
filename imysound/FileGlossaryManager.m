//
//  FileGlossaryManager.m
//  imysound
//
//  Created by yangzexin on 13-4-8.
//
//

#import "FileGlossaryManager.h"
#import "SimpleFileKeyValueManager.h"
#import "CodeUtils.h"

@interface FileGlossaryManager ()

@property(nonatomic, retain)id<KeyValueManager> keyValue;

@end

@implementation FileGlossaryManager

- (void)dealloc
{
    self.keyValue = nil;
    [super dealloc];
}

- (id)initWithSRTFilePath:(NSString *)srtFilePath
{
    self = [super init];
    
    self.keyValue = [[SimpleFileKeyValueManager alloc] initWithFilePath:[NSString stringWithFormat:@"%@.glossary", srtFilePath]];
    
    return self;
}

- (NSMutableArray *)mutableWordList
{
    NSMutableArray *wordList = [NSMutableArray array];
    NSString *existsWordList = [self.keyValue valueForKey:@"wordlist"];
    if(existsWordList.length != 0){
        NSData *data = [CodeUtils dataDecodedWithString:existsWordList];
        NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if(arr.count != 0){
            [wordList addObjectsFromArray:arr];
        }
    }
    
    return wordList;
}

- (void)saveWordList:(NSArray *)wordList
{
    if(wordList){
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:wordList];
        NSString *dataString = [CodeUtils encodeWithData:archivedData];
        [self.keyValue setValue:dataString forKey:@"wordlist"];
    }
}

- (BOOL)addWord:(NSString *)word
{
    NSMutableArray *wordList = [self mutableWordList];
    [wordList addObject:word];
    [self saveWordList:wordList];
    return YES;
}

- (void)removeWord:(NSString *)word
{
    NSMutableArray *wordList = [self mutableWordList];
    [wordList removeObject:word];
    [self saveWordList:wordList];
}

- (NSArray *)wordList
{
    return [NSArray arrayWithArray:[self mutableWordList]];
}

@end
