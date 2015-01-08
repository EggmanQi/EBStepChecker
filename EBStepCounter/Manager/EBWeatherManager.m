//
//  EBWeatherManager.m
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/25.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBWeatherManager.h"
#import "AFNetworking.h"

static NSString *const urlStr = @"http://www.stateair.net/web/rss/1/";

@interface EBWeatherManager () <NSXMLParserDelegate>
{
    getPM25Success          innerPM25;

    NSMutableArray      *dataArr;
    NSMutableData       *dataXML;
    NSMutableDictionary *itemRootDic;
    
    NSString            *currentElement;
    NSString            *currentValue;
    
    NSString            *currentCity;
    NSString            *language;
    NSString            *ttl;
    NSString            *logLoadingTime;
}

@end

@implementation EBWeatherManager

+ (EBWeatherManager *)sharedManager
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)getPMDataInCity:(EB_City)city
                success:(getPM25Success)success
                failure:(void(^)(NSError *error))failure
{
    if (success) {
        innerPM25 = success;
    }
    
    NSString *targetUrl = [NSString stringWithFormat:@"%@%d.xml", urlStr, city];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFXMLParserResponseSerializer new]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];
    
    [manager GET:targetUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {

             dataArr = [NSMutableArray array];
             
             NSXMLParser *parser = (NSXMLParser *)responseObject;
             parser.delegate = self;
             [parser parse];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (failure) {
                 failure(error);
             }
         }];
}

- (void)getWeatherData
{
    
}

#pragma mark -
#pragma mark - Parsing lifecycle

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"item"]) {
        itemRootDic = nil;
        itemRootDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }else{
        currentElement = elementName;
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (currentElement) {
        currentValue = string;
        [itemRootDic setObject:string forKey:currentElement];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    currentElement = nil;
    currentValue = nil;
    
    if (dataArr.count>0) {
        return;
    }
    
    if ([elementName isEqualToString:@"item"]) {
        if (itemRootDic) {
            NSString *title = [itemRootDic objectForKey:@"title"];
            
            if ([title isEqualToString:@"State Department Air Monitoring Website"] || [itemRootDic allKeys].count<7) {
                return;
            }else{
                [dataArr addObject:itemRootDic];
            }
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"%@", dataArr);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (innerPM25) {
            NSDictionary *dic = dataArr[0];
            NSInteger returnAQI = [[dic objectForKey:@"AQI"] integerValue];
            NSInteger returnPM = [[dic objectForKey:@"Conc"] integerValue];
            NSString *returnDesc = [dic objectForKey:@"Desc"];
            
            NSRange range = [returnDesc rangeOfString:@" ("];
            returnDesc = [returnDesc substringToIndex:range.location];
            innerPM25(returnPM, returnAQI, returnDesc);
        }
    });
}

@end
