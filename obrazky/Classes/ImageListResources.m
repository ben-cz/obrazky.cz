//
//  ImageListResources.m
//  obrazky
//
//  Created by Jakub Dohnal on 19/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import "ImageListResources.h"

@implementation ImageListResources

-(id) initWithDelegate: (id<ImageListResourcesDelegate>) delegate{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

-(void)getImagesInfoListFilterName: (NSString *)filterName from: (NSInteger)from step: (NSInteger) step{
    RESTResources *resources = [[RESTResources alloc] initWithDelegate:self];
    NSString *fromStr = [NSString stringWithFormat:@"%d", from];
    NSString *stepStr = [NSString stringWithFormat:@"%d", step];
    
    NSDictionary *params = @{
      @"q" : filterName,
      @"step" : stepStr,
      @"from" : fromStr,
      @"size" : @"any",
      @"color" : @"any",
      @"filter" : @"true",
    };
    
    [resources startGetRequestWithUrl:URL_OBRAZKY params: params];
}

-(NSArray *)parserImageInfoHTML: (NSString *) imagesInfoHTML{
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:[imagesInfoHTML dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *imgsUrlXpathQueryString = @"//a";
    NSArray *imgsUrl = [tutorialsParser searchWithXPathQuery:imgsUrlXpathQueryString];
    
    NSString *imgsThbUrlXpathQueryString = @"//a//img";
    NSArray *imgsThbUrl = [tutorialsParser searchWithXPathQuery:imgsThbUrlXpathQueryString];
    
    NSString *imgsNameXpathQueryString = @"//a//span[@class='info_content']/span[1]/text()";
    NSArray *imgsName = [tutorialsParser searchWithXPathQuery:imgsNameXpathQueryString];
    
    NSString *imgsSizeStrXpathQueryString = @"//a//span[@class='info_content']/span[2]/text()";
    NSArray *imgsSizeStr = [tutorialsParser searchWithXPathQuery:imgsSizeStrXpathQueryString];
    
    NSMutableArray *imagesInfo = [[NSMutableArray alloc]init];
    if(true){
        for (NSUInteger i=0; i<[imgsUrl count]; i++) {
            ImageInfo *imgInfo = [[ImageInfo alloc] initWithName:
                                  [(TFHppleElement *)[imgsName objectAtIndex:i] content]
                                sizeStr:[(TFHppleElement *)[imgsSizeStr objectAtIndex:i] content]
                                url:[[(TFHppleElement *)[imgsUrl objectAtIndex:i] attributes] objectForKey:@"data-dot"]
                                urlThb:[[(TFHppleElement *)[imgsThbUrl objectAtIndex:i] attributes] objectForKey:@"src"]
                                  ];
            [imagesInfo addObject:imgInfo];
        }
    }

    return [NSArray arrayWithArray:imagesInfo];;
}

//FIX json string. Json don't allow escape aposthrope \'
-(NSData *)fixJsonData:(NSData *) jsonData{
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
    return [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
}


-(NSString *)unescapeString: (NSString *) escapeString{
    escapeString = [escapeString stringByReplacingOccurrencesOfString:@"\\\\" withString:@"&escp;"];
    escapeString = [escapeString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    escapeString = [escapeString stringByReplacingOccurrencesOfString:@"&amp;'" withString:@"&"];
    return [escapeString stringByReplacingOccurrencesOfString:@"&escp;" withString:@"\\"];
}

- (void)request:(RESTResources *)request didFinishWithData:(NSData *)resourceData{
    NSError *parserError;
    
    NSData *fixJsonData = [self fixJsonData:resourceData];
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:fixJsonData options:0 error:&parserError];
    if (parserError) {
        if ([self.delegate respondsToSelector:@selector(request:didFinishWithError:)]) {
            //[self.delegate request:self didFinishWithError:parserError];
        }
        return;
    }

    if([[jsonObject objectForKey:@"status"] isEqualToString:@"200"]){
        return;
    }
    
    NSString *htmlImagesList = [[jsonObject objectForKey:@"result"] objectForKey:@"boxes"];
    
    htmlImagesList = [self unescapeString: htmlImagesList];
    
    NSArray *imagesList = [self parserImageInfoHTML: htmlImagesList];
    
    [self.delegate request:self didFinishWithImageList:imagesList];
}

- (void)requestDidFailLoading:(RESTResources *)request{
    if ([self.delegate respondsToSelector:@selector(requestDidFailLoading:)]){
        [self.delegate requestDidFailLoading:self];
    }
}

- (void)request:(RESTResources *)request didFinishWithError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(request:didFinishWithError:)]){
        [self.delegate request:self didFinishWithError:error];
    }
}

@end
