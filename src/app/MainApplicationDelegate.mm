#import "MainApplicationDelegate.h"
#import "MainApplication.h"
#import "Helium-Swift.h"
#import "../extensions/FontUtils.h"
#import "../bridging/SwiftObjCPPBridger.h"

@implementation MainApplicationDelegate

- (instancetype)init {
    if (self = [super init]) {
        os_log_debug(OS_LOG_DEFAULT, "- [MainApplicationDelegate init]");
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary <UIApplicationLaunchOptionsKey, id> *)launchOptions {
    os_log_debug(OS_LOG_DEFAULT, "- [MainApplicationDelegate application:%{public}@ didFinishLaunchingWithOptions:%{public}@]", application, launchOptions);

    // load fonts from app
    [FontUtils loadFontsFromFolder:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath],  @"/fonts"]];
    // load fonts from documents
    [FontUtils loadFontsFromFolder:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
    [FontUtils loadAllFonts];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:[[[ContentInterface alloc] init] createUI]];
    [self.window makeKeyAndVisible];

    // Auto-start HUD on app launch (for TrollStore)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!IsHUDEnabledBridger()) {
            os_log_info(OS_LOG_DEFAULT, "[Auto-start] HUD is not running, starting it now...");
            SetHUDEnabledBridger(YES);
        } else {
            os_log_info(OS_LOG_DEFAULT, "[Auto-start] HUD is already running, skipping auto-start");
        }
    });

    return YES;
}

@end