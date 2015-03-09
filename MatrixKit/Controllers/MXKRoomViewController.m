/*
 Copyright 2015 OpenMarket Ltd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXKRoomViewController.h"

#import "MXKRoomBubbleCellData.h"
#import "MXKRoomIncomingBubbleTableViewCell.h"
#import "MXKRoomOutgoingBubbleTableViewCell.h"

@interface MXKRoomViewController () {

    MXSession *mxSession;
    MXRoom *room;
}

@property (nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) MXKRoomDataSource *dataSource;

@end

@implementation MXKRoomViewController

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([MXKRoomViewController class])
                          bundle:[NSBundle bundleForClass:[MXKRoomViewController class]]];
}

+ (instancetype)roomViewController
{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([MXKRoomViewController class])
                                          bundle:[NSBundle bundleForClass:[MXKRoomViewController class]]];
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[self class] nib] instantiateWithOwner:self options:nil];
    
    // Check whether a room has been defined
    [self setUpTableView];
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    _tableView = nil;
    _dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void)setUpTableView {

    // Set up table data source
    _tableView.dataSource = _dataSource;
    
    // Set up classes to use for cells
    [_tableView registerClass:MXKRoomIncomingBubbleTableViewCell.class forCellReuseIdentifier:kMXKIncomingRoomBubbleCellIdentifier];
    [_dataSource registerCellDataClass:MXKRoomBubbleCellData.class forCellIdentifier:kMXKIncomingRoomBubbleCellIdentifier];

    [_tableView registerClass:MXKRoomOutgoingBubbleTableViewCell.class forCellReuseIdentifier:kMXKOutgoingRoomBubbleCellIdentifier];
    [_dataSource registerCellDataClass:MXKRoomBubbleCellData.class forCellIdentifier:kMXKOutgoingRoomBubbleCellIdentifier];

    // Start showing history right now
    [_dataSource paginateBackMessagesToFillRect:self.view.frame success:^{
        // @TODO (hide loading wheel)
    } failure:^(NSError *error) {
        // @TODO
    }];
}

#pragma mark -

- (void)displayRoom:(MXRoom *)aRoom withMXSession:(MXSession *)session {
    room = aRoom;
    mxSession = session;
    
    // Set up table data source and listen to its changes
    _dataSource = [[MXKRoomDataSource alloc] initWithRoom:room andMatrixSession:mxSession];
    _dataSource.delegate = self;
    
    if (_tableView) {
        [self setUpTableView];
    }
}

- (void)registerCellDataClass:(Class)cellDataClass andCellViewClass:(Class)cellViewClass forCellIdentifier:(NSString *)identifier {

    // @TODO: Fix this assert
    NSAssert(_tableView, @"This operation must be called only when _tableView is available");

    // Configure the classes to use for the given cell type
    [_tableView registerClass:cellViewClass forCellReuseIdentifier:identifier];
    [_dataSource registerCellDataClass:cellDataClass forCellIdentifier:identifier];

    // Force refresh the table
    // @TODO: This does not work at runtime. The table view continues to use the class
    // previously registered
    [_tableView reloadData];
}

#pragma mark - MXKDataSourceDelegate
- (void)dataSource:(MXKDataSource *)dataSource didChange:(id)changes {
    // For now, do a simple full reload
    [_tableView reloadData];
}

@end
