//
// Created by Benjamin Dobell on 9/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <OctoKit/OctoKit.h>
#import "ConfigurationViewController.h"
#import "ProjectBuildListViewModel.h"
#import "ProjectBuildViewModel.h"
#import "NSTableCellView+RACSignalSupport.h"
#import "ConfigurationViewModel.h"
#import "MainRunLoopScheduler.h"
#import "SelectProjectViewController.h"

@interface ConfigurationViewController () <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>

@property (nonatomic, strong) ConfigurationViewModel *configurationViewModel;

@property (nonatomic, strong) ProjectBuildListViewModel *projectBuildListViewModel;

@end

@implementation ConfigurationViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
	if ((self = [super initWithCoder:coder]))
	{
		ConfigurationViewModel *configurationViewModel = [[ConfigurationViewModel alloc] init];
		[self setConfigurationViewModel:configurationViewModel];
		[self setProjectBuildListViewModel:[configurationViewModel projectBuildListViewModel]];
	}

	return self;
}

- (instancetype)init
{
	if ((self = [super init]))
	{
		ConfigurationViewModel *configurationViewModel = [[ConfigurationViewModel alloc] init];
		[self setConfigurationViewModel:configurationViewModel];
		[self setProjectBuildListViewModel:[configurationViewModel projectBuildListViewModel]];
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[[self tableView] setDataSource:self];
	[[self tableView] setDelegate:self];

	ConfigurationViewController *weak_self = self;

	RACCommand *selectProjectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
		return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
			ConfigurationViewController *strong_self = weak_self;
			MainRunLoopScheduler *runLoopScheduler = [[MainRunLoopScheduler alloc] init];

			[runLoopScheduler performAsCurrentScheduler:^{
				NSArray *topLevelObjects;
				NSWindowController *windowController = [[NSWindowController alloc] init];

				[[NSBundle mainBundle] loadNibNamed:@"SelectProjectWindow" owner:windowController topLevelObjects:&topLevelObjects];

				SelectProjectViewController *selectProjectViewController = [[topLevelObjects rac_sequence] objectPassingTest:^BOOL(id value) {
					return [value isKindOfClass:[SelectProjectViewController class]];
				}];
				[selectProjectViewController setConfigurationViewModel:[strong_self configurationViewModel]];

				[[[[strong_self projectBuildListViewModel] projectBuildAdded] take:1] subscribeNext:^(id x) {
					[NSApp stopModalWithCode:0];
				}];

				[[windowController window] setDelegate:strong_self];
				[NSApp runModalForWindow:[windowController window]];

				[subscriber sendCompleted];
			}];

			return nil;
		}];
	}];

	[[self addButton] setRac_command:selectProjectCommand];

	RACCommand *deleteProjectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
		return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
			ConfigurationViewController *strong_self = weak_self;
			NSInteger selectedRow = [[strong_self tableView] selectedRow];

			if (selectedRow >= 0)
			{
				[[[self projectBuildListViewModel] projectBuildViewModelAtIndex:(NSUInteger) selectedRow] removeFromProjectBuildListViewModel:[self projectBuildListViewModel]];
			}

			[subscriber sendCompleted];
			return nil;
		}];
	}];

	[[self removeButton] setRac_command:deleteProjectCommand];

	[[[RACSignal merge:@[
		[[self projectBuildListViewModel] projectBuildAdded],
		[[self projectBuildListViewModel] projectBuildRemoved],
		[[self projectBuildListViewModel] projectBuildChanged],
	]] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
		[[weak_self tableView] reloadData];
	}];

	[[[self projectBuildListViewModel] refreshProjectBuildStatuses] subscribeNext:^(id x) {}];
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[self projectBuildListViewModel] projectBuildCount];
}

#pragma mark NSTableViewDelegate

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
	ProjectBuildViewModel *viewModel = [[self projectBuildListViewModel] projectBuildViewModelAtIndex:(NSUInteger) row];
	NSTableCellView *cell = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
	__weak NSTableCellView *weak_cell = cell;

	if ([[tableColumn identifier] isEqualToString:@"project"])
	{
		[[RACObserve(viewModel, title) takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(NSString *title) {
			__strong NSTableCellView *strong_cell = weak_cell;
			[[strong_cell textField] setStringValue:title];
		}];
	}
	else if ([[tableColumn identifier] isEqualToString:@"status"])
	{
		[[RACObserve(viewModel, status) takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(NSString *status) {
			__strong NSTableCellView *strong_cell = weak_cell;

			if ([status length] == 0)
			{
				status = @"unknown";
			}

			[[strong_cell textField] setStringValue:status];
		}];
	}

	return cell;
}

- (void)tableView:(NSTableView *)tableView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
	for (NSInteger i = 0, count = [rowView numberOfColumns]; i < count; i++)
	{
		NSView *view = [rowView viewAtColumn:i];

		if ([view respondsToSelector:@selector(rac_prepareForReuse)])
		{
			[(id)view rac_prepareForReuse];
		}
	}
}

#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
	[[NSApplication sharedApplication] stopModal];
}

@end
