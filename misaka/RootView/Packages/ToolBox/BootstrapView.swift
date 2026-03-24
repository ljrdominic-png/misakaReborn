//
//  BootstrapViewV.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/12/17.
//

import Foundation
import SwiftUI

struct BootstrapView: View {
    @State var bootstrap: Bool = false
    @State var installing: Bool = false
    @State var message: String? = nil
    var body: some View {
        List {
            if !bootstrap {
                Button("Install Bootstrap") {
                    UIApplication.shared.confirmAlert(title: MILocalizedString("Bootstrap Installer"), body: MILocalizedString("Are you sure you want to install Bootstrap?\n\nIf you're using hotspot wifi/cellular data, it might takes about 230MB from data"), onOK: {
                        installing = true
                        message = "download..."
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let fileURL = URL(string: "https://github.com/34306/iPA/releases/download/bstr/jb.zip")!
                            try? FileManager.default.removeItem(atPath: DataPath("tmp")+"/jb.zip")
                            let downloadSuccess = synchronousDownloadFile(from: fileURL, to: URL(fileURLWithPath: DataPath("tmp")+"/jb.zip"))
                            message = "extract..."
                            if downloadSuccess {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    do {
                                        try? FileManager.default.removeItem(atPath: DataPath("jb"))
                                        let uz = Unzip(from: URL(fileURLWithPath: DataPath("tmp")+"/jb.zip"), to: URL(fileURLWithPath: DataPath("jb")))
                                        if !uz.success {
                                            UIApplication.shared.alert(title: "Bootstrap Installer", body: uz.errorMessage.isEmpty ? "Unzip error" : uz.errorMessage)
                                        }
                                    }catch{
                                        UIApplication.shared.alert(title: "Bootstrap Installer", body: "\(error.localizedDescription)")
                                    }
                                    bootstrap = FileManager.default.fileExists(atPath: DataPath("jb"))
                                    installing = false
                                    message = nil
                                }
                            }else{
                                UIApplication.shared.alert(title: "Bootstrap Installer", body: "donwload error")
                                bootstrap = FileManager.default.fileExists(atPath: DataPath("jb"))
                                installing = false
                                message = nil
                            }
                        }
                    }, noCancel: false)
                }
                .foregroundColor(.green)
                if installing {
                    ProgressView((message != nil) ? message ?? "" : "Please wait...")
                }
            }else{
                Button("Uninstall Bootstrap") {
                    UIApplication.shared.confirmAlert(title: MILocalizedString("Bootstrap Installer"), body: MILocalizedString("Are you sure you want to uninstall Bootstrap?"), onOK: {
                        installing = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            try? FileManager.default.removeItem(atPath: DataPath("jb"))
                            bootstrap = FileManager.default.fileExists(atPath: DataPath("jb"))
                            installing = false
                        }
                    }, noCancel: false)
                }
                .foregroundColor(.red)
                if installing {
                    ProgressView((message != nil) ? message ?? "" : "Please wait...")
                }
                
                Button("Install Settings") {
                    guard let url = URL(string: "apple-magnifier://install?url=https://github.com/34306/iPA/releases/download/bstr/prefs_fix.ipa") else { return }
                    UIApplication.shared.openURL(url)
                }
                
                Button("Install Terminal") {
                    guard let url = URL(string: "apple-magnifier://install?url=https://cdn.discordapp.com/attachments/1180087812754788394/1185641736584843384/Terminal_1.11.ipa?ex=659059ea&is=657de4ea&hm=d4d359c20fb17f8524401adf6c3d461942a0a062930b209a4cac446759c6bd9b&") else { return }
                    UIApplication.shared.openURL(url)
                }
                
                Button("Install Sileo") {
                    guard let url = URL(string: "apple-magnifier://install?url=https://cdn.discordapp.com/attachments/1180087812754788394/1185641717748207717/Sileo.ipa?ex=659059e5&is=657de4e5&hm=2a39996d802461b47c4b4b24a1b8007d575049b7517726805923e39c70237c1d&") else { return }
                    UIApplication.shared.openURL(url)
                }
            }
        }
        .navigationTitle("Install Bootstrap & Sileo")
        .onAppear {
            bootstrap = FileManager.default.fileExists(atPath: DataPath("jb"))
        }
    }
}

func synchronousDownloadFile(from url: URL, to: URL) -> Bool {
    let semaphore = DispatchSemaphore(value: 0)
    var success = false
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        defer { semaphore.signal() }
        
        if let error = error {
            return
        }
        
        guard let data = data else {
            return
        }
        
        do {
            try data.write(to: to)
            success = true
        } catch {}
    }
    
    task.resume()
    semaphore.wait()
    
    return success
}
