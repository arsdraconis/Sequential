/* Copyright © 2007-2011, The Sequential Project
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the the Sequential Project nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE SEQUENTIAL PROJECT ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE SEQUENTIAL PROJECT BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */
#import "PGSubscription.h"

#import <sys/time.h>
#import <unistd.h>
#import <fcntl.h>

#import "PGFoundationAdditions.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const PGSubscriptionEventDidOccurNotification = @"PGSubscriptionEventDidOccur";

NSString *const PGSubscriptionPathKey = @"PGSubscriptionPath";
NSString *const PGSubscriptionRootFlagsKey = @"PGSubscriptionRootFlags";

@interface PGLeafSubscription : PGSubscription

- (instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

+ (void)threaded_sendFileEvents;
+ (void)mainThread_sendFileEvent:(NSDictionary *)info;

@end

// MARK: -
@interface PGBranchSubscription : PGSubscription

- (instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)subscribeWithPath:(NSString *)path;
- (void)unsubscribe;
- (void)rootSubscriptionEventDidOccur:(NSNotification *)aNotif;

@end

// MARK: -
@implementation PGSubscription

//	MARK: +PGSubscription

+ (instancetype)subscriptionWithPath:(NSString *)path descendents:(BOOL)flag
{
	id result;
	if(!flag) result = [PGLeafSubscription alloc];
	else result = [PGBranchSubscription alloc];
	return [result initWithPath:path];
}

+ (instancetype)subscriptionWithPath:(NSString *)path
{
	return [self subscriptionWithPath:path descendents:NO];
}

//	MARK: - PGSubscription

- (nullable NSString *)path
{
	return nil;
}

//	MARK: - NSObject<NSObject>

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %p: %@>", [self class], self, self.path];
}

@end

// MARK: -
static NSString *const PGLeafSubscriptionValueKey = @"PGLeafSubscriptionValue";
static NSString *const PGLeafSubscriptionFlagsKey = @"PGLeafSubscriptionFlags";

static int PGKQueue = -1;
static CFMutableSetRef PGActiveSubscriptions = nil;


@interface PGLeafSubscription ()

@property (nonatomic, assign) int descriptor;

@end


@implementation PGLeafSubscription

- (instancetype)initWithPath:(NSString *)path
{
    NSAssert([NSThread isMainThread], @"PGSubscription is not thread safe.");
    errno = 0;
    if((self = [super init])) {
        CFSetAddValue(PGActiveSubscriptions, (__bridge void *)self);
        char const *const rep = path.fileSystemRepresentation;
        _descriptor = open(rep, O_EVTONLY);
        if(-1 == _descriptor) {
            self = nil;
            return nil;
        }
        struct kevent const ev = {
            .ident = _descriptor,
            .filter = EVFILT_VNODE,
            .flags = EV_ADD | EV_CLEAR,
            //    2024/02/26 only request events which are to be acted upon
            //    under ARC builds, the PGLeafSubscription object can be
            //    deleted before the callback +mainThread_sendFileEvent:
            //    executes which results in it accessing a deleted object
            //    and then crashing. This can occur when a bookmarked
            //    folder is Resumed: doing so generates a NOTE_ATTRIB
            //    event which gets enqueued for execution by
            //    +mainThread_sendFileEvent but the object gets -delloc'd
            //    before it is dequeued.
        //    .fflags = NOTE_DELETE | NOTE_WRITE | NOTE_EXTEND | NOTE_ATTRIB | NOTE_LINK | NOTE_RENAME | NOTE_REVOKE,
            .fflags = NOTE_DELETE | NOTE_RENAME | NOTE_REVOKE,
            .data = 0,
            .udata = (__bridge void *)self,
        };
        struct timespec const timeout = {0, 0};
        if(-1 == kevent(PGKQueue, &ev, 1, NULL, 0, &timeout)) {
            self = nil;
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
//    NSLog(@"-[PGLeafSubscription dealloc]: %p", (__bridge void *)self);
    CFSetRemoveValue(PGActiveSubscriptions, (__bridge void *)self);
    if(-1 != _descriptor) close(_descriptor);
}

+ (void)initialize
{
    if([PGLeafSubscription class] != self) return;
    PGKQueue = kqueue();
    PGActiveSubscriptions = CFSetCreateMutable(kCFAllocatorDefault, 0, NULL);
    [NSThread detachNewThreadSelector:@selector(threaded_sendFileEvents) toTarget:self withObject:nil];
}


//	MARK: PGLeafSubscription

+ (void)threaded_sendFileEvents
{
	for(;;) {
		@autoreleasepool {
			struct kevent ev;
			(void)kevent(PGKQueue, NULL, 0, &ev, 1, NULL);

			// The original API documentation (pre-ARC) states "the
			// -performSelector:onThread:withObject:waitUntilDone: method retains the receiver
			// and the arg parameter until after the selector is performed."
            // <https://web.archive.org/web/20111006112505/http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/Reference/Reference.html>
			// As such, this code should not cause the dictionary to be invalid
			// when it is accessed in the main thread in -mainThread_sendFileEvent:
			[self performSelectorOnMainThread:@selector(mainThread_sendFileEvent:)
								   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
				[NSValue valueWithNonretainedObject:(__bridge PGLeafSubscription *)ev.udata], PGLeafSubscriptionValueKey,
				@(ev.fflags), PGLeafSubscriptionFlagsKey, nil]
								waitUntilDone:NO];
//NSLog(@"+[PGLeafSubscription threaded_sendFileEvents]: obj = %p", ev.udata);
		}
	}
}

+ (void)mainThread_sendFileEvent:(NSDictionary *)info
{
	NSParameterAssert(nil != info[PGLeafSubscriptionValueKey]);
	NSParameterAssert([info[PGLeafSubscriptionValueKey] isKindOfClass:NSValue.class]);
//NSLog(@"+[PGLeafSubscription mainThread_sendFileEvent]: obj = %p", info[PGLeafSubscriptionValueKey]);
	NSParameterAssert(nil != [info[PGLeafSubscriptionValueKey] nonretainedObjectValue]);
	PGSubscription *const subscription = [info[PGLeafSubscriptionValueKey] nonretainedObjectValue];
	if(!CFSetContainsValue(PGActiveSubscriptions, (__bridge CFTypeRef) subscription)) return;
	NSMutableDictionary *const dict = [NSMutableDictionary dictionary];
	NSString *const path = subscription.path;
	if(path) dict[PGSubscriptionPathKey] = path;
	NSNumber *const flags = info[PGLeafSubscriptionFlagsKey];
	if(flags) dict[PGSubscriptionRootFlagsKey] = flags;
	[subscription PG_postNotificationName:PGSubscriptionEventDidOccurNotification userInfo:dict];
}


//	MARK: PGSubscription

- (nullable NSString *)path
{
	NSString *result = nil;
	char *path = calloc(PATH_MAX, sizeof(char));
	if(-1 != fcntl(_descriptor, F_GETPATH, path)) result = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:path length:strlen(path)];
	free(path);
	return result;
}


@end

// MARK: -
static void PGEventStreamCallback(ConstFSEventStreamRef streamRef, PGBranchSubscription *subscription, size_t numEvents, NSArray *paths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[])
{
    for(NSString *const path in paths) [subscription PG_postNotificationName:PGSubscriptionEventDidOccurNotification userInfo:@{PGSubscriptionPathKey: path}];
}

@interface PGBranchSubscription ()

@property (nonatomic, assign, nullable) FSEventStreamRef eventStream;
@property (nonatomic, strong) PGSubscription *rootSubscription;

@end

// MARK: -
@implementation PGBranchSubscription

- (instancetype)initWithPath:(NSString *)path
{
    if((self = [super init])) {
        _rootSubscription = [PGSubscription subscriptionWithPath:path];
        [_rootSubscription PG_addObserver:self selector:@selector(rootSubscriptionEventDidOccur:) name:PGSubscriptionEventDidOccurNotification];
        [self subscribeWithPath:path];
    }
    return self;
}

- (void)dealloc
{
    [self PG_removeObserver];
    [self unsubscribe];
}

//	MARK: PGBranchSubscription

- (void)subscribeWithPath:(NSString *)path
{
	NSParameterAssert(!_eventStream);
	if(!path) return;
	FSEventStreamContext context = {.version = 0, .info = (__bridge void *)self};
	_eventStream = FSEventStreamCreate(kCFAllocatorDefault, (FSEventStreamCallback)PGEventStreamCallback,
		&context, (__bridge CFArrayRef) @[path], kFSEventStreamEventIdSinceNow,
		0.0f, kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagNoDefer);
	FSEventStreamScheduleWithRunLoop(_eventStream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopCommonModes);
	FSEventStreamStart(_eventStream);
}
- (void)unsubscribe
{
	if(!_eventStream) return;
	FSEventStreamStop(_eventStream);
	FSEventStreamInvalidate(_eventStream);
	FSEventStreamRelease(_eventStream);
	_eventStream = NULL;
}
- (void)rootSubscriptionEventDidOccur:(NSNotification *)aNotif
{
	NSParameterAssert(aNotif);
	NSUInteger const flags = [aNotif.userInfo[PGSubscriptionRootFlagsKey] unsignedIntegerValue];
	if(!(flags & (NOTE_RENAME | NOTE_REVOKE | NOTE_DELETE))) return;
	[self unsubscribe];
	//	only resubscribe when the object has not been deleted
	if(0 == (flags & (NOTE_DELETE | NOTE_REVOKE)))
		[self subscribeWithPath:aNotif.userInfo[PGSubscriptionPathKey]];
	[self PG_postNotificationName:PGSubscriptionEventDidOccurNotification userInfo:aNotif.userInfo];
}

//	MARK: PGSubscription

- (nullable NSString *)path
{
	return _rootSubscription.path;
}

@end

NS_ASSUME_NONNULL_END
