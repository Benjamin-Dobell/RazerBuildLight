//
// Created by Benjamin Dobell on 13/03/2016.
// Copyright (c) 2016 Glass Echidna Pty Ltd. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSTableCellView+RACSignalSupport.h"
#import "SelectProjectViewController.h"
#import "ProjectBuildListViewModel.h"
#import "ProjectBuildViewModel.h"
#import "ConfigurationViewModel.h"

@interface SelectProjectViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) ProjectBuildListViewModel *projectBuildListViewModel;

@end

@implementation SelectProjectViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	[[self tableView] setDataSource:self];
	[[self tableView] setDelegate:self];

	ProjectBuildListViewModel *listViewModel = [[ProjectBuildListViewModel alloc] init];
	[self setProjectBuildListViewModel:listViewModel];

	[[[listViewModel reloadWithRemoteProjectBuilds] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
		[[self tableView] reloadData];
	}];

	__weak SelectProjectViewController *weak_self = self;

	RACCommand *addProjectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
		return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
			SelectProjectViewController *strong_self = weak_self;
			NSInteger selectedRow = [[strong_self tableView] selectedRow];

			if (selectedRow >= 0)
			{
				[[listViewModel projectBuildViewModelAtIndex:(NSUInteger) selectedRow] addToProjectBuildListViewModel:[[self configurationViewModel] projectBuildListViewModel]];
			}

			[subscriber sendCompleted];
			return nil;
		}];
	}];

	[[self addButton] setRac_command:addProjectCommand];
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

@end
