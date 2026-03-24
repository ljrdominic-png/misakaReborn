import Foundation
import AlertToast
import Combine
import UIKit

/// PiP/WebView stack removed; keep type for lock/unlock hooks.
final class PiPStubLoader: ObservableObject {
    @Published var path: String = ""
    func stop() {}
    func start() {}
}

final class PiPController: UIResponder, UIApplicationDelegate, ObservableObject {
    static var shared = PiPController()
    @Published var Loader = PiPStubLoader()
    @Published var height: Double = 18
    @Published var Active: Bool = false
}

class DeviceStatus : NSObject {
    @objc func locked(){
        print("device locked")
        ViewMemory.shared.DeviceLocked = true
        PiPController.shared.Loader.stop()
    }

    @objc func unlocked(){
        print("device unlocked")
        ViewMemory.shared.DeviceLocked = false
        PiPController.shared.Loader.start()
        
        if SettingsManager.shared.RuninBackground && SettingsManager.shared.Background_Apply && !Memory.shared.AdvancedSettings_isActive && !SmoothSheetController.shared.ShowBar {
            Memory.shared.BGRun_Applying = true
            ToastController.shared.Toast_Hud = AlertToast(displayMode: .hud, type: .loading, title: "Background Apply")
            ToastController.shared.Show_Hud = true
            DispatchQueue.global().async {
                print("Background Apply")
                if !ViewMemory.shared.DeviceLocked {
                    ApplyAll(Keep: true)
                }
                DispatchQueue.main.async {
                    Memory.shared.BGRun_Applying = false
                    ToastController.shared.Show_Hud = false
                }
            }
        }
    }
}
