//
//  TBActorSupervisor.m
//  ActorKit
//
//  Created by Julian Krumow on 09.10.15.
//  Copyright (c) 2015 Julian Krumow. All rights reserved.
//

#import "TBActorSupervisor.h"
#import "TBActorSupervisionPool.h"
#import "NSObject+ActorKit.h"

static NSString * const TBAKActorSupervisorQueue = @"com.tarbrain.ActorKit.TBActorSupervisor";

@interface TBActorSupervisor ()
@property (nonatomic, weak) TBActorSupervisionPool *supervisionPool;
@property (nonatomic, weak) NSObject *actor;
@end

@implementation TBActorSupervisor

- (instancetype)init
{
    return [self initWithPool:nil];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    return [self initWithPool:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithPool:nil];
}

- (instancetype)initWithPool:(TBActorSupervisionPool *)pool
{
    self = [super init];
    if (self) {
        self.actorQueue.name = TBAKActorSupervisorQueue;
        _supervisionPool = pool;
        _links = [NSMutableSet new];
    }
    return self;
}

- (void)dealloc
{
    [self.actor.actorQueue cancelAllOperations];
}

- (void)createActor
{
    NSObject *actor = nil;
    self.creationBlock(&actor);
    actor.supervisor = self;
    self.actor = actor;
    self.supervisionPool[self.Id] = actor;
    [self _createLinkedActors];
}

- (void)recreateActor
{
    // Save invocations in mailbox and update target
    self.actor.actorQueue.suspended = YES;
    NSOperationQueue *queue = self.actor.actorQueue;
    [self createActor];
    self.actor.actorQueue = queue;
    for (NSInvocationOperation *operation in queue.operations) {
        if (!operation.isExecuting && !operation.isCancelled && !operation.isFinished) {
            operation.invocation.target = self.actor;
        }
    }
    queue.suspended = NO;
}

#pragma mark - Internal methods

- (void)_createLinkedActors
{
    NSArray *linkedSupervisors = [self.supervisionPool supervisorsForIds:self.links];
    for (TBActorSupervisor *supervisor in linkedSupervisors) {
        [supervisor.sync recreateActor];
    }
}

#pragma mark - TBActorSupervison

- (void)actor:(NSObject *)actor didCrashWithError:(NSError *)error
{
    [self recreateActor];
}

@end