/* Copyright © 2010, The Sequential Project
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

#import "PGResourceDataProvider.h"

#import "PGFoundationAdditions.h"
#import "PGResourceIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

@interface PGResourceDataProvider ()

@property (nonatomic, strong) NSString *displayableName;

@end

@implementation PGResourceDataProvider

@synthesize identifier = _identifier;

- (instancetype)initWithResourceIdentifier:(PGResourceIdentifier *)ident
                           displayableName:(NSString *)name
{
    if ((self = [super init]))
    {
        _identifier      = ident;
        _displayableName = [name copy];
    }
    return self;
}

- (nullable id)valueForResourceKey:(NSURLResourceKey)key
{
    NSError *error = nil;
    id value       = nil;
    if (![_identifier.URL getResourceValue:&value forKey:key error:&error] || error) return nil;
    return value;
}

- (nullable id)valueForFMAttributeName:(NSString *)name
{
    return _identifier.isFileIdentifier
               ? [[NSFileManager defaultManager] attributesOfItemAtPath:_identifier.URL.path
                                                                  error:NULL][name]
               : nil;
}

//	MARK: - PGDataProvider

- (NSString *)displayableName
{
    return _displayableName ? _displayableName : [self valueForResourceKey:NSURLLocalizedNameKey];
}

- (nullable NSData *)data
{
    return [NSData dataWithContentsOfURL:_identifier.URL
                                 options:NSDataReadingMapped | NSDataReadingUncached
                                   error:NULL];
}

- (uint64_t)dataByteSize
{
    return (uint64_t)[[self valueForFMAttributeName:NSFileSize] unsignedLongValue];
}

//	MARK: -

- (nullable NSString *)UTIType
{
    return [self valueForResourceKey:NSURLTypeIdentifierKey];
}

- (nullable NSString *)extension
{
    return _identifier.URL.pathExtension;
}

//	MARK: -

- (nullable NSDate *)dateModified
{
    return [self valueForFMAttributeName:NSFileModificationDate];
}

- (nullable NSDate *)dateCreated
{
    return [self valueForFMAttributeName:NSFileCreationDate];
}

//	MARK: -

- (BOOL)hasData
{
    return PGEqualObjects([self valueForFMAttributeName:NSFileType], NSFileTypeRegular);
}

- (NSImage *)icon
{
    return [[NSWorkspace sharedWorkspace] iconForFile:_identifier.URL.path];
}

@end

NS_ASSUME_NONNULL_END
