//
//  ActiveChatsViewController.h
//  Monal
//
//  Created by Anurodh Pokharel on 6/14/13.
//
//

#import <UIKit/UIKit.h>
#import "MLConstants.h"
#import "MLContact.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

NS_ASSUME_NONNULL_BEGIN

@interface ActiveChatsViewController : UITableViewController  <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView* chatListTable;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* settingsButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* composeButton;

-(void) presentChatWithContact:(MLContact* _Nullable) contact;
-(void) refreshDisplay;

-(void) showContacts;
-(void) deleteConversation;
-(void) showSettings;
-(void) showDetails;
-(void) showRegisterWithUsername:(NSString*) username onHost:(NSString*) host withToken:(NSString* _Nullable) token usingCompletion:(monal_void_block_t) completion;

@end

NS_ASSUME_NONNULL_END
