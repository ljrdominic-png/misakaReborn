//
//  misakaApp.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/09.
//

import SwiftUI
import AudioToolbox
import CoreLocation
import AVFoundation
import AlertKit
import AlertToast
import MachO

/// App version string used for repo MinAppVersion checks (keep in sync with marketing version when needed).
var appver = "10.0 Beta"

@main
struct misakaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            MainSheetBridge()
                .onAppear{
                    FileManager.default.createFile(atPath: "\(DataPath("Settings"))/.misaka", contents: nil, attributes: nil)
                    // 初期設定
                    ApplyDefaultSettings()
                    // 対応チェックとExploit実行
                    RunExploit(MemorySingleton: Memory.shared)
                    
                    FileManager.default.createFile(atPath: "\(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)/SendCommand", contents: nil, attributes: nil)
                }
        }
    }
}


class SettingsManager: UIResponder, UIApplicationDelegate, ObservableObject {
    static var shared = SettingsManager()
    @AppStorage("Exploit") var Exploit: String = "DarkSword"
    @AppStorage("KFD_Mode2") var KFD_Mode2: Bool = false
    @AppStorage("NoVar") var NoVar: Bool = false
    @AppStorage("LocalizationVersion") var LocalizationVersion: Double = 0.0
    @AppStorage("AppLang") var AppLang: String = "en (Bundle)"
    @AppStorage("SpringLang") var SpringLang: String = "en"
    var TelephonyUI_Selection: [String] = ["TelephonyUI-9", "TelephonyUI-8", "TelephonyUI-7"]
    @AppStorage("TelephonyUI") var TelephonyUI: String = ""
    @AppStorage("RespringType") var RespringType: String = "FrontBoard"
    var SpringLang_Selection: [String] = ["ar","ca","cs","da","de","el","en","en_AU","en_GB","es","es_419","fi","fr","fr_CA","he","hi","hr","hu","id","it","ja","ko","ms","nl","no","pl","pt","pt_PT","ro","ru","sk","sv","th","tr","uk","vi","zh_CN","zh_HK","zh_TW"]
    var RespringType_Selection: [String] = ["FrontBoard", "BackBoard"]
    @AppStorage("DeveloperMode") var DeveloperMode: Bool = false
    @AppStorage("RuninBackground_Interval") var RuninBackground_Interval: Double = 120
    @AppStorage("RuninBackground") var RuninBackground: Bool = false
    @AppStorage("Background_Apply") var Background_Apply: Bool = false
    @AppStorage("StatusBarIndicator") var StatusBarIndicator: Bool = false
    @AppStorage("ShortcutApp") var ShortcutApp: Bool = false
    /// Single exploit path: always Sandboxed / VirtualRoot (emu/var).
    let ExploitInfo = [
        "DarkSword": "Sandboxed",
    ]
    @AppStorage("MemoryClean") var MemoryClean: Bool = true
    @AppStorage("LogStream") var LogStream: Bool = false
}
class ViewMemory: UIResponder, UIApplicationDelegate, ObservableObject {
    static var shared = ViewMemory()
    @Published var Applying: Bool = false
    @Published var Reloading: Bool = false
    @Published var AppLoading: Bool = false
    @Published var AppLoading_Progress: String = ""
    @Published var Applying_Addon: String = ""
    @Published var DeviceLocked: Bool = false
    
    @Published var semaphoreApply = DispatchSemaphore(value: 1)
    
    func Reload() {
        ViewMemory.shared.Reloading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ViewMemory.shared.Reloading = false
        }
    }
    @Published var Details: DetailsType = DetailsType()
}

class Memory: UIResponder, UIApplicationDelegate, ObservableObject {
    static var shared = Memory()
    @AppStorage("FirstStartup") var FirstStartupA: Bool = true
    @AppStorage("RepositoriesURL") var RepositoriesURL: [String] = [String]()
    @Published var TabOffset: CGFloat = 0
    @Published var DebugLogs_isActive: Bool = false
    @Published var AddonPage_isActive: Bool = false
    @Published var AddonPage_RepositoryContentPack: RepositoryContentPackType = RepositoryContentPackType()
    @Published var AdvancedSettings_isActive: Bool = false
    @Published var AdvancedSettings_Addon: String = ""
    @Published var ConfigEditMode: Bool = false
    @Published var ToolBox_IsActive: Bool = false
    @Published var TabSelection: Int = 0
    @AppStorage("DisplayType") var DisplayType: Int = 0
    @Published var Queue: [QueueType] = [QueueType]()
    @Published var QueueDepends: [QueueType] = [QueueType]()
    
    @Published var TermsOfService_IsActive: Bool = false
    @Published var AppIconSelecter_IsActive: Bool = false
    @Published var SettingsView_IsActive: Bool = false
    @Published var WebsiteView_IsActive: Bool = false
    @Published var RespringConfirm: Bool = false
    @Published var BGRun_Applying: Bool = false
    @Published var FirstBoot: Bool = true
    @Published var ShowViewF0: Bool = false
    @Published var ShowViewF1: Bool = true
    @Published var ShowViewFB: Bool = true
    @Published var lastTimeInterval: Double = 0
    
    @Published var Welcome_IsActive: Bool = false
    @AppStorage("CurrentVersion") var CurrentVersion: String = ""
    @Published var FirstBootKFD: Bool = true
    
    // KFD
    var puaf_pages_options = [16, 32, 64, 128, 256, 512, 1024, 2048, 3072, 4096, 65536, 131072]
    var puaf_method_options = ["physpuppet", "smith", "landa"]
    var kread_method_options = ["kqueue_workloop_ctl", "sem_open"]
    var kwrite_method_options = ["dup", "sem_open"]
    @AppStorage("puaf_pages_index") var puaf_pages_index = 7
    @AppStorage("puaf_method") var puaf_method = 2
    @AppStorage("kread_method") var kread_method = 1
    @AppStorage("kwrite_method") var kwrite_method = 1
    @Published var kfd: UInt64 = 0
    @Published var puaf_pages = 0
}


class Location: UIResponder, UIApplicationDelegate, ObservableObject {
    static var shared = Location()
    @Published var coordinates = CLLocationCoordinate2D(latitude: 37.333747, longitude: -122.011448)
    @Published var showSheet = false
    
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
}

class ColorManager: UIResponder, UIApplicationDelegate, ObservableObject {
    static var shared = ColorManager()
    @AppStorage("W_Box_Base_ON") var W_Box_Base_ON: Color = HexToColor("#FFFFFFFF")
    @AppStorage("W_Box_Base_OFF") var W_Box_Base_OFF: Color = HexToColor("#000000FF")
    @AppStorage("W_Box_Text_ON") var W_Box_Text_ON: Color = HexToColor("#000000FF")
    @AppStorage("W_Box_Text_OFF") var W_Box_Text_OFF: Color = HexToColor("#FFFFFFFF")
    @AppStorage("W_Box_Shadow_ON") var W_Box_Shadow_ON: Color = HexToColor("#00000000")
    @AppStorage("W_Box_Shadow_OFF") var W_Box_Shadow_OFF: Color = HexToColor("#00000000")
    @AppStorage("W_Box_Other_ON") var W_Box_Other_ON: Color = HexToColor("#000000FF")
    @AppStorage("W_Box_Other_OFF") var W_Box_Other_OFF: Color = HexToColor("#FFFFFFFF")
    // OFF
    @AppStorage("D_Box_Base_ON") var D_Box_Base_ON: Color = HexToColor("#FFFFFFFF")
    @AppStorage("D_Box_Base_OFF") var D_Box_Base_OFF: Color = HexToColor("#000000FF")
    @AppStorage("D_Box_Text_ON") var D_Box_Text_ON: Color = HexToColor("#000000FF")
    @AppStorage("D_Box_Text_OFF") var D_Box_Text_OFF: Color = HexToColor("#FFFFFFFF")
    @AppStorage("D_Box_Shadow_ON") var D_Box_Shadow_ON: Color = HexToColor("#00000000")
    @AppStorage("D_Box_Shadow_OFF") var D_Box_Shadow_OFF: Color = HexToColor("#00000000")
    @AppStorage("D_Box_Other_ON") var D_Box_Other_ON: Color = HexToColor("#000000FF")
    @AppStorage("D_Box_Other_OFF") var D_Box_Other_OFF: Color = HexToColor("#FFFFFFFF")
    
    @AppStorage("D_AccentColor") var D_AccentColor: Color = HexToColor("#3777DDFF")
    @AppStorage("W_AccentColor") var W_AccentColor: Color = HexToColor("#3777DDFF")
    
    @AppStorage("W_Box_Blur") var W_Box_Blur: Bool = false
    @AppStorage("D_Box_Blur") var D_Box_Blur: Bool = false
    @AppStorage("W_BG_Blur") var W_BG_Blur: Double = 0
    @AppStorage("D_BG_Blur") var D_BG_Blur: Double = 0
    @AppStorage("W_BG_Type") var W_BG_Type: String = "Gradient"
    @AppStorage("D_BG_Type") var D_BG_Type: String = "Gradient"
    
    @AppStorage("appearanceMode") var appearanceMode: Int = 0
}


extension UNNotificationCategory
{
    static let clipboardReaderIdentifier = "Misaka"
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if SettingsManager.shared.RuninBackground == true {
            ApplicationMonitor.shared.start()
        }
        self.registerForNotifications()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate start")
        print("applicationWillTerminate end")
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    private func registerForNotifications() {
        let category = UNNotificationCategory(identifier: UNNotificationCategory.clipboardReaderIdentifier, actions: [], intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard response.notification.request.content.categoryIdentifier == UNNotificationCategory.clipboardReaderIdentifier else { return }
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }
    }
}
