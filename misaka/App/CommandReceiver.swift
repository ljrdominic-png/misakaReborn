//
//  CommandReciver.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/10/20.
//

import Foundation
import AlertToast
import UserNotifications

func CommandReceiver() {
    func timer_start() {
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            timer.invalidate()
            if let cmd = try? String(contentsOfFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("SendCommand").path, encoding: .utf8) {
                if cmd == "ApplyAll" {
                    try?  "".write(toFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("SendCommand").path, atomically: false, encoding: .utf8)
                    let content = UNMutableNotificationContent()
                    content.title = "Command Received"
                    content.body = "Refreshing - \(cmd)"
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request)
                    
                    DispatchQueue.global().async {
                        ApplyAll(Keep: true)
                        let content = UNMutableNotificationContent()
                        content.title = "Command Received"
                        content.body = "Refreshed - \(cmd)"
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                        UNUserNotificationCenter.current().add(request)
                    }
                }else if cmd == "RestoreAll" {
                    try?  "".write(toFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("SendCommand").path, atomically: false, encoding: .utf8)
                    let content = UNMutableNotificationContent()
                    content.title = "Command Received"
                    content.body = "Refreshing - \(cmd)"
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request)
                    
                    DispatchQueue.global().async {
                        RestoreAll()
                        let content = UNMutableNotificationContent()
                        content.title = "Command Received"
                        content.body = "Refreshed - \(cmd)"
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                        UNUserNotificationCenter.current().add(request)
                    }
                }else if cmd == "Quit" {
                    try?  "".write(toFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("SendCommand").path, atomically: false, encoding: .utf8)
                    terminateApp()
                }else if cmd == "Respring" {
                    try?  "".write(toFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("SendCommand").path, atomically: false, encoding: .utf8)
                    Respring()
                }
            }
            DispatchQueue.main.async {
                timer_start()
            }
        }
    }
    if SettingsManager.shared.ShortcutApp {
        timer_start()
    }
}
