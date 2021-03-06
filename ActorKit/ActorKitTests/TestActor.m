//
//  TestActor.m
//  ActorKitTests
//
//  Created by Julian Krumow on 04.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TestActor.h"

@implementation TestActor
@synthesize symbol = _symbol;

- (instancetype)init
{
    self = [super init];
    if (self) {
        srand ((unsigned int)time(NULL));
    }
    return self;
}

- (void)setSymbol:(NSNumber *)symbol
{
    _symbol = symbol;
    if (self.monitorBlock) {
        self.monitorBlock();
    }
}

- (NSNumber *)symbol
{
    return _symbol;
}

- (void)setSymbol:(NSNumber *)symbol withCompletion:(void (^)(NSNumber *))completion
{
    self.symbol = symbol;
    completion(symbol);
}

- (void)doSomething
{
    NSLog(@"%@ doSomething", self.uuid);
}

- (void)doSomething:(NSString *)stuff withCompletion:(void (^)(NSString *))completion
{
    [self doSomething];
    completion(stuff);
}

- (NSString *)address
{
    return [NSString stringWithFormat:@"%p", self];
}

- (NSString *)addressBlocking
{
    [self blockSomething];
    return [self address];
}

- (void)address:(void (^)(NSString *))completion
{
    NSString *address = [self address];
    completion(address);
}

- (void)addressBlocking:(void (^)(NSString *))completion
{
    [self blockSomething];
    [self address:completion];
}

- (NSNumber *)returnSomething
{
    return self.uuid;
}

- (NSNumber *)returnSomethingBlocking
{
    sleep([self _randomSleepInterval]);
    return [self returnSomething];
}

- (void)returnSomethingWithCompletion:(void (^)(NSNumber *))completion
{
    NSNumber *number = [self returnSomething];
    completion(number);
}

- (void)returnSomethingBlockingWithCompletion:(void (^)(NSNumber *))completion
{
    NSNumber *number = [self returnSomethingBlocking];
    completion(number);
}

- (void)handler:(id)payload
{
    self.symbol = payload;
}

- (void)handlerRaw:(NSDictionary *)payload
{
    self.symbol = payload[@"symbol"];
}

- (void)blockSomething
{
    sleep([self _randomSleepInterval]);
}

- (void)blockSomethingWithCompletion:(void (^)(void))completion
{
    [self blockSomething];
    completion();
}

- (void)doCrash
{
    @throw [NSException exceptionWithName:@"TestActorException" reason:@"doCrash" userInfo:nil];
}

- (double)_randomSleepInterval
{
    return (randomNumberInRange(0, 1000) / 1000.0);
}

NSInteger randomNumberInRange(NSInteger from, NSInteger to)
{
    return to + rand() / (RAND_MAX / (from - to + 1) + 1);
}

@end
