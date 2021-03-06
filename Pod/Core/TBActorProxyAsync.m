//
//  TBActorProxyAsync.m
//  ActorKit
//
//  Created by Julian Krumow on 03.08.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorProxyAsync.h"
#import "NSObject+ActorKit.h"
#import "TBActorOperation.h"

@implementation TBActorProxyAsync

- (void)forwardInvocation:(NSInvocation *)invocation
{
    invocation.target = self.actor;
    TBActorOperation *operation = [[TBActorOperation alloc] initWithInvocation:invocation];
    operation.completionBlock = ^{
        [self relinquishActor];
    };
    [self.actor.actorQueue addOperation:operation];
}

@end
