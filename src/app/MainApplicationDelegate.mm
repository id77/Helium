#import "MainApplicationDelegate.h"
#import "MainApplication.h"
#import "Helium-Swift.h"
#import "../extensions/FontUtils.h"
#import "../bridging/SwiftObjCPPBridger.h"
#import <notify.h>

@implementation MainApplicationDelegate

- (instancetype)init {
    if (self = [super init]) {
        os_log_debug(OS_LOG_DEFAULT, "- [MainApplicationDelegate init]");
        
        // Register for widget wakeup notification
        int token;
        notify_register_dispatch("com.leemin.helium.widget.wakeup", &token, dispatch_get_main_queue(), ^(int t) {
            os_log_info(OS_LOG_DEFAULT, "[Widget Wake-up] Received notification, auto-starting HUD...");
            if (!IsHUDEnabledBridger()) {
                SetHUDEnabledBridger(YES);
                // Update shared state for widget
                NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.leemin.helium"];
                [shared setBool:YES forKey:@"HUDIsRunning"];
                [shared synchronize];
            }
        });
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
        
        // Update shared state for widget
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.leemin.helium"];
        [shared setBool:IsHUDEnabledBridger() forKey:@"HUDIsRunning"];
        [shared setBool:YES forKey:@"AutoStartOnBoot"];  // Enable auto-start by default
        [shared synchronize];
    });

    return YES;
}

@end