#import "MJRefresh/MJRefresh.h"

@interface SBBulletinViewController : UIViewController

@property(nonatomic, assign) id delegate;

@end

@interface SBNotificationCenterViewController
@property(readonly, nonatomic) NSSet *visibleContentViewControllers;
@end

@interface SBNotificationCenterController
@property(retain) SBNotificationCenterViewController *viewController;
+ (id)sharedInstance;
@end

@interface SBBulletinObserverViewController
@property(readonly, nonatomic) NSArray *orderedSectionIDs;
- (id)sectionWithIdentifier:(NSString *)identifier;
- (void)clearSection:(id)section;
- (BOOL)canShowPullToRefresh; //This should be added in the respective observer controllers which want to controll the PullBulletin.
@end

// ios10
@interface NCNotificationChronologicalList
@property (nonatomic,retain) NSArray * sections;
- (void)clearAllSections;
-(void)clearSectionWithIdentifier:(NSString *)identifier;
-(NSSet *)notificationRequestsForSectionIdentifier:(NSString *)identifier;
@end

@interface SBNotificationCenterDestination

-(void)notificationListViewController:(id)arg1 requestsClearingNotificationRequests:(NSSet *)arg2;
-(void)notificationListViewControllerDidSignificantUserInteraction:(id)arg1 ;

@end

@interface NCNotificationSectionListViewController
@property (nonatomic,retain) NCNotificationChronologicalList * sectionList;
@property (assign,nonatomic) SBNotificationCenterDestination * destinationDelegate;
-(void)notifyContentObservers;
@end

@interface NCNotificationListSection

@property (nonatomic,retain) NSString * title;
@property (nonatomic,readonly) NSString * identifier;

@end

@interface SBIcon
- (void)setBadge:(id)value;
- (id)badgeNumberOrString;
@end

@interface SBIconModel
- (SBIcon *)applicationIconForBundleIdentifier:(NSString *)bundleIdentifier; //iOS 8
@end

@interface SBIconViewMap
+ (SBIconViewMap *)homescreenMap;
- (SBIconModel *)iconModel;
@end


// ios9、8 clear notifications method.
// Inherited from https://github.com/autopear/Notification-Killer/blob/master/Tweak.mm#L118
static void clearAllBulletin()
{
    NSArray *allSections;
    SBBulletinObserverViewController *allCtrl;
    SBNotificationCenterController *self = [%c(SBNotificationCenterController) sharedInstance];
    NSSet *s = self.viewController.visibleContentViewControllers;
    // Set of SBBulletinObserverViewController subclass.
    for (id vc in s) {
        if ([vc isKindOfClass:%c(SBBulletinObserverViewController)]) {
            allCtrl = vc;
            allSections = allCtrl.orderedSectionIDs;
            break;
        }
    }

    for (NSString *identifier in allSections) {
        id sectionInfo = [allCtrl sectionWithIdentifier:identifier];
        if (sectionInfo)
            [allCtrl clearSection:sectionInfo];
        SBIconModel *iconModel = (SBIconModel *)[(SBIconViewMap *)[%c(SBIconViewMap) homescreenMap] iconModel];
        if (iconModel) {
            SBIcon *appIcon = [iconModel applicationIconForBundleIdentifier:identifier];
            if (appIcon && [appIcon badgeNumberOrString])
                [appIcon setBadge:nil];
        }
    }
}

%group NCGroup
%hook BulletinVC
- (void)viewDidLoad
{
    %orig;
     UIView *view1 = [(UIViewController *)self view];
     NSArray *views = [view1 subviews];
    __block UIScrollView * sbPageScrollView = nil;
    __weak NCNotificationSectionListViewController *weakSelf = self;
    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        if ([obj isKindOfClass:NSClassFromString(@"UICollectionView")]) {
            sbPageScrollView = obj;
        }
    }];
    if (sbPageScrollView == nil)
    {
        NSLog(@"TLog::::: not found");
    } else {
         MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            // clearAllBulletin();
            NCNotificationChronologicalList *chronologicalList = [weakSelf sectionList];
            NSArray *sections = [chronologicalList sections];
            for (int i = 0; i < [sections count]; i++) {
                NCNotificationListSection *obj = sections[i];
                // run main async
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue,^ {
                  NSSet *clearRequests = [chronologicalList notificationRequestsForSectionIdentifier:obj.identifier];
                  // ui refresh
                  [chronologicalList clearSectionWithIdentifier:obj.identifier];
                  [weakSelf notifyContentObservers];
                  NSLog(@"TLog::::: identifier %@",obj.identifier);
                  // clear local caches
                  SBNotificationCenterDestination *notificationCenterDestination = [weakSelf destinationDelegate];
                  [notificationCenterDestination notificationListViewController:weakSelf requestsClearingNotificationRequests:clearRequests];
                  [notificationCenterDestination notificationListViewControllerDidSignificantUserInteraction:weakSelf];
                });
            }
            [sbPageScrollView.mj_header endRefreshing];
        }];
        header.lastUpdatedTimeLabel.hidden = true;
        header.stateLabel.textColor = [UIColor whiteColor];
        sbPageScrollView.mj_header = header;
    }
}
%end
%end

%ctor {
    @autoreleasepool {
        Class $BulletinVC = objc_getClass("NCNotificationSectionListViewController");
        %init(NCGroup, BulletinVC = $BulletinVC);
    }
}
