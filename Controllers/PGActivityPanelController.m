/* Copyright © 2007-2009, The Sequential Project
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
#import "PGActivityPanelController.h"

#import "PGActivity.h"
#import "PGProgressIndicatorCell.h"
#import "PGFoundationAdditions.h"
#import "PGGeometry.h"

NS_ASSUME_NONNULL_BEGIN

@interface PGActivityPanelController ()

@property (nonatomic, weak) IBOutlet NSOutlineView *activityOutline;
@property (nonatomic, weak) IBOutlet NSTableColumn *identifierColumn;
@property (nonatomic, weak) IBOutlet NSTableColumn *progressColumn;
@property (nonatomic, weak) IBOutlet NSButton      *cancelButton;
@property (nonatomic, strong, nullable) NSTimer *updateTimer;

- (void)_update;

@end

//	MARK: -
@implementation PGActivityPanelController

- (IBAction)cancelLoad:(id)sender
{
	NSIndexSet *const indexes = _activityOutline.selectedRowIndexes;
	NSUInteger i = indexes.firstIndex;
	for(; NSNotFound != i; i = [indexes indexGreaterThanIndex:i])
    {
        [[_activityOutline itemAtRow:i] cancel:sender];
    }
}

//	MARK: PGActivityPanelController(Private)

- (void)_update
{
	[_activityOutline reloadData];
	[_activityOutline expandItem:nil expandChildren:YES];
}

- (void)_enableCancelButton
{
	_cancelButton.enabled = _activityOutline.selectedRowIndexes.count > 0;
}

//	MARK: NSObject(NSOutlineViewNotifications)

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	[self _enableCancelButton];	//	[_cancelButton setEnabled:[[_activityOutline selectedRowIndexes] count] > 0];
}

//	MARK: PGFloatingPanelController

- (NSString *)nibName
{
	return @"PGActivity";
}
- (void)windowWillShow
{
	_updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_update) userInfo:nil repeats:YES];
	[self _update];
}
- (void)windowWillClose
{
	[_updateTimer invalidate];
	_updateTimer = nil;
}

//	MARK: NSWindowController

- (void)windowDidLoad
{
	[super windowDidLoad];
	_progressColumn.dataCell = [PGProgressIndicatorCell new];
	[self _enableCancelButton];	//	[self outlineViewSelectionDidChange:nil];
}

//	MARK: NSObject

- (void)dealloc
{
	[self windowWillClose];
}

//	MARK: id<NSOutlineViewDataSource>

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
	return [(item ? item : [PGActivity applicationActivity]) childActivities:YES].count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
	return [(item ? item : [PGActivity applicationActivity]) childActivities:YES][index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return item ? [item childActivities:YES].count > 0 : YES;
}

// NOTE: this method is optional for the View Based OutlineView.
- (nullable id)outlineView:(NSOutlineView *)outlineView
 objectValueForTableColumn:(nullable NSTableColumn *)tableColumn
					byItem:(nullable id)item
{
	if(tableColumn == _identifierColumn)
	{
		static NSDictionary *attrs = nil;
		if(!attrs) {
			NSMutableParagraphStyle *const style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
			style.tighteningFactorForTruncation = 0.3f;
			style.lineBreakMode = NSLineBreakByTruncatingMiddle;
			attrs = @{NSParagraphStyleAttributeName: style};
		}
		return [[NSAttributedString alloc] initWithString:[item activityDescription] attributes:attrs];
	} else if(tableColumn == _progressColumn) {
		return @(((PGActivity*) item).progress);
	}
	return nil;
}

//	MARK: id<NSOutlineViewDelegate>

// View Based OutlineView: See the delegate method -tableView:viewForTableColumn:row: in NSTableView.
- (nullable NSView *)outlineView:(NSOutlineView *)outlineView
			  viewForTableColumn:(nullable NSTableColumn *)tableColumn
							item:(id)item
{
	NSTextField*	result = [NSTextField new];
	result.drawsBackground	=	NO;
	result.bordered			=	NO;
	result.bezeled			=	NO;
	result.editable			=	NO;

	result.font				=	[NSFont systemFontOfSize:0.0];
	result.alignment		=	NSTextAlignmentLeft;

	if(tableColumn == _progressColumn)
	{
		PGActivity*		ai		=	(PGActivity*) item;
		if(!ai.progress || 0 != [ai childActivities:YES].count)
			return nil;
	}
	return result;
}

@end

NS_ASSUME_NONNULL_END
