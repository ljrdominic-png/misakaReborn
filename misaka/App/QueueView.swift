//
//  Queue.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/13.
//

import Foundation
import SwiftUI
import ProgressIndicatorView


func QueueCheck() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        withAnimation(.interpolatingSpring(stiffness: 600, damping: 100)) {
            if Memory.shared.Queue.count == 0 {
                SmoothSheetController.shared.ShowBar = false
            }else{
                SmoothSheetController.shared.ShowBar = true
            }
        }
    }
}

struct QueueHeader: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @ObservedObject var SmoothSheetControllerSingleton = SmoothSheetController.shared
    @Binding var isPresent: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Queued")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                Text("\(SmoothSheetControllerSingleton.ShowBar ? MemorySingleton.Queue.count+MemorySingleton.QueueDepends.count : MemorySingleton.Queue.count+MemorySingleton.QueueDepends.count) Packages")
                    .foregroundColor(.secondary)
                    .font(.headline)
            }
            Spacer()
        }
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 8)
        .padding(EdgeInsets(
            top: 12,
            leading: 20,
            bottom: 12,
            trailing: 8
        ))
        .border(width: 1, edges: [.top, .bottom], color: .gray.opacity(0.3))
    }
}


struct QueueContent: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @Binding var isPresent: Bool
    @State var Message: String = ""
    @State var Confirmed = false
    @State private var progress: Double = 0
    private let total: Double = 1
    @State var scrollable = true

    private func queueModeCounts() -> (
        mainInstall: Int,
        mainUpdate: Int,
        mainUninstall: Int,
        depInstall: Int,
        depUninstall: Int
    ) {
        var mi = 0, mu = 0, mun = 0, di = 0, du = 0
        for x in MemorySingleton.Queue {
            switch x.Mode {
            case "Install": mi += 1
            case "Update": mu += 1
            case "Uninstall": mun += 1
            default: break
            }
        }
        for x in MemorySingleton.QueueDepends {
            switch x.Mode {
            case "Install": di += 1
            case "Uninstall": du += 1
            default: break
            }
        }
        return (mi, mu, mun, di, du)
    }

    var li: some View {
        let mc = queueModeCounts()
        return ZStack {
            List {
                if mc.mainInstall != 0 {
                    Section(header: Text(MILocalizedString("Install"))) {
                        ForEach(MemorySingleton.Queue.indices, id: \.self) { i in
                            if (MemorySingleton.Queue[i].Mode == "Install"){
                                QueueRow(Queue: $MemorySingleton.Queue[i], Confirmed: $Confirmed)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                if mc.mainUpdate != 0 {
                    Section(header: Text(MILocalizedString("Update"))) {
                        ForEach(MemorySingleton.Queue.indices, id: \.self) { i in
                            if (MemorySingleton.Queue[i].Mode == "Update"){
                                QueueRow(Queue: $MemorySingleton.Queue[i], Confirmed: $Confirmed)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                if mc.depInstall != 0 {
                    Section(header: Text(MILocalizedString("Depends"))) {
                        ForEach(MemorySingleton.QueueDepends.indices, id: \.self) { i in
                            if (MemorySingleton.QueueDepends[i].Mode == "Install"){
                                QueueRow(Queue: $MemorySingleton.QueueDepends[i], Confirmed: $Confirmed)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                if mc.depUninstall != 0 {
                    Section(header: Text(MILocalizedString("Uninstall"))) {
                        ForEach(MemorySingleton.QueueDepends.indices, id: \.self) { i in
                            if (MemorySingleton.QueueDepends[i].Mode == "Uninstall"){
                                QueueRow(Queue: $MemorySingleton.QueueDepends[i], Confirmed: $Confirmed)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                if mc.mainUninstall != 0 {
                    Section(header: Text(MILocalizedString("Uninstall"))) {
                        ForEach(MemorySingleton.Queue.indices, id: \.self) { i in
                            if (MemorySingleton.Queue[i].Mode == "Uninstall"){
                                QueueRow(Queue: $MemorySingleton.Queue[i], Confirmed: $Confirmed)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listBackground(.clear)
            .listStyle(SidebarListStyle())
        }
        .allowsHitTesting(scrollable)
    }
    
    @State var semaphore = DispatchSemaphore(value: 1)
    var body: some View {
        VStack {
            if #available(iOS 16.0, *) {
                li.scrollContentBackground(.hidden)
            } else {
                li
            }
            VStack {
                if !Confirmed {
                    Button(action: {
                        ViewMemory.shared.AppLoading = true
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                ViewMemory.shared.AppLoading = false
                            }
                            ClearFolder(DataPath("Download"))
                            if MemorySingleton.Queue.filter({ $0.Mode == "Update" }).count != 0 {
                                UIApplication.shared.confirmAlert(title: MILocalizedString("Warning"), body: MILocalizedString("Settings will not be transferred. Taking a screencap beforehand will be recommended. Would you like to continue?"), onOK: {
                                    DispatchQueue.global().async {
                                        withAnimation(.interpolatingSpring(stiffness: 600, damping: 100)) {
                                            DispatchQueue.main.async {
                                                Confirmed = true
                                            }
                                        }
                                        ViewMemory.shared.AppLoading = true
                                        DispatchQueue.global().async {
                                            RestoreAll()
                                            DispatchQueue.main.async {
                                                ViewMemory.shared.AppLoading = false
                                            }
                                            if MemorySingleton.QueueDepends.count != 0 {
                                                processDepends()
                                            }else{
                                                process()
                                            }
                                        }
                                    }
                                }, noCancel: false)
                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                                return
                            }
                            DispatchQueue.global().async {
                                withAnimation(.interpolatingSpring(stiffness: 600, damping: 100)) {
                                    DispatchQueue.main.async {
                                        Confirmed = true
                                    }
                                }
                                DispatchQueue.main.async {
                                    ViewMemory.shared.AppLoading = true
                                }
                                DispatchQueue.global().async {
                                    RestoreAll()
                                    DispatchQueue.main.async {
                                        ViewMemory.shared.AppLoading = false
                                    }
                                    if MemorySingleton.QueueDepends.count != 0 {
                                        processDepends()
                                    }else{
                                        process()
                                    }
                                }
                            }
                        }
                    }){
                        Text(MILocalizedString("Confirm"))
                            .frame(maxWidth: 320)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(Color(UIColor.rgb(red: 0, green: 160, blue: 255)))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 8)
                    }
                    
                    Button(action: {
                        MemorySingleton.Queue = [QueueType]()
                        MemorySingleton.QueueDepends = [QueueType]()
                        isPresent = false
                        QueueCheck()
                    }){
                        Text(MILocalizedString("Clear Queue"))
                            .frame(maxWidth: 320)
                            .padding()
                            .foregroundColor(Color(UIColor.rgb(red: 0, green: 160, blue: 255)))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 8)
                    }
                }else{
                    if MemorySingleton.Queue.allSatisfy({ $0.DLProgress.ProcessEnd }) && MemorySingleton.QueueDepends.allSatisfy({ $0.DLProgress.ProcessEnd }) {
                        Button(action: {
                            MemorySingleton.Queue = [QueueType]()
                            MemorySingleton.QueueDepends = [QueueType]()
                            isPresent = false
                            Confirmed = false
                            QueueCheck()
                        }){
                            Text(MILocalizedString("Close"))
                                .frame(maxWidth: 320)
                                .padding()
                                .foregroundColor(Color.white)
                                .background(Color(UIColor.rgb(red: 0, green: 160, blue: 255)))
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 8)
                        }
                        .padding(.top, 20)
                    }else{
                        Button(action: {
                            //                    MemorySingleton.Queue = [QueueType]()
                            //                    isPresent = false
                            //                    Confirmed = false
                        }){
                            Text(MILocalizedString("Cancel Downloads"))
                                .frame(maxWidth: 320)
                                .padding()
                                .foregroundColor(Color.white)
                                .background(Color(UIColor.rgb(red: 0, green: 160, blue: 255)))
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 8)
                        }
                        .padding(.top, 20)
                    }
                }
            }
        }
        .onChange(of: MemorySingleton.Queue) { newValue in
            DispatchQueue.global().async {
                if !Confirmed {
                    DispatchQueue.main.async {
                        MemorySingleton.QueueDepends = [QueueType]()
                    }
                    for data in newValue {
                        if let PackageID = data.Releases.Package {
                            if PackageID.contains(".purekfd") || PackageID.contains(".picasso") {
                                RepositoryContentSimpleTypeDirectOpen(
                                    RepositoryContentSimpleType(RepositoryURL: "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/repo.json", PackageID: "com.shimajiron.p2loader")
                                ) { repositoryContentPack in
                                    if InstalledPackageVersion("com.shimajiron.p2loader") != (repositoryContentPack?.RepositoryContent.Releases.last ?? ReleasesType()).Version {
                                        if data.Mode == "Install" {
                                            if let repositoryContentPack = repositoryContentPack {
                                                let Checker = QueueType(
                                                    Mode: "Install",
                                                    Releases: repositoryContentPack.RepositoryContent.Releases.last ?? ReleasesType(),
                                                    RepositoryContentPack: repositoryContentPack
                                                )
                                                DispatchQueue.main.async {
                                                    MemorySingleton.QueueDepends.append(Checker)
                                                    MemorySingleton.QueueDepends = Array(Set(MemorySingleton.QueueDepends))
                                                }
                                            }else{
                                                MemorySingleton.Queue.removeLast()
                                                UIApplication.shared.alert(body: MILocalizedString("Could not obtain required package"), withButton: true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if data.Mode != "Install" { continue }
                        for depends in data.RepositoryContentPack.RepositoryContent.Depends {
                            RepositoryContentSimpleTypeDirectOpen(
                                RepositoryContentSimpleType(RepositoryURL: depends.RepositoryURL, PackageID: depends.PackageID)
                            ) { repositoryContentPack in
                                if let repositoryContentPack = repositoryContentPack {
                                    if !InstalledPackages().contains(repositoryContentPack.RepositoryContent.PackageID) && data.Mode == "Install" {
                                        let Checker = QueueType(
                                            Mode: "Install",
                                            Releases: repositoryContentPack.RepositoryContent.Releases.last ?? ReleasesType(),
                                            RepositoryContentPack: repositoryContentPack
                                        )
                                        DispatchQueue.main.async {
                                            MemorySingleton.QueueDepends.append(Checker)
                                            MemorySingleton.QueueDepends = Array(Set(MemorySingleton.QueueDepends))
                                        }
                                    }
                                }else{
                                    MemorySingleton.Queue.removeLast()
                                    UIApplication.shared.alert(body: MILocalizedString("Could not obtain required package"), withButton: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func processDepends() {
        for i in 0..<MemorySingleton.QueueDepends.count {
            MemorySingleton.QueueDepends[i].DLProgress.Message = "Installing"
            let RepositoryContent = MemorySingleton.QueueDepends[i].RepositoryContentPack.RepositoryContent
            if MemorySingleton.QueueDepends[i].Mode == "Install" {
                guard let url_str = MemorySingleton.QueueDepends[i].Releases.Package else {
                    MemorySingleton.QueueDepends[i].DLProgress.Message = MILocalizedString("URL Error")
                    return
                }
                guard let url = URL(string: url_str) else {
                    MemorySingleton.QueueDepends[i].DLProgress.Message = MILocalizedString("URL Error")
                    return
                }
                MemorySingleton.QueueDepends[i].DLProgress.dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            MemorySingleton.QueueDepends[i].DLProgress.Message = MILocalizedString("Extract...")
                        }
                        
                        // Data Write
                        guard let zip = URLwithEncode(string: "\(DataPath("Download"))/\(RepositoryContent.PackageID).zip") else { return }
                        do {
                            try data?.write(to: zip)
                        }catch{
                            print(error.localizedDescription)
                            UIApplication.shared.alert(body: MILocalizedString("Unknown error. You don't have access to this directory\n\(error.localizedDescription)"), withButton: true)
                            DispatchQueue.main.async {
                                MemorySingleton.QueueDepends[i].DLProgress.ProcessEnd = true
                            }
                            return
                        }
                        
                        let Message = AddonImport(zip, MemorySingleton.QueueDepends[i])
                        
                        DispatchQueue.main.async {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if i >= 0 && i < MemorySingleton.QueueDepends.count {
                                    MemorySingleton.QueueDepends[i].DLProgress.Progress = 100
                                    MemorySingleton.QueueDepends[i].DLProgress.Message = Message
                                    MemorySingleton.QueueDepends[i].DLProgress.ProcessEnd = true
                                    if MemorySingleton.QueueDepends.allSatisfy({ $0.DLProgress.ProcessEnd }) {
                                        process()
                                    }
                                }
                            }
                        }
                    }
                }
                MemorySingleton.QueueDepends[i].DLProgress.observation = MemorySingleton.QueueDepends[i].DLProgress.dataTask?.progress.observe(\.fractionCompleted) { observationProgress, _ in
                    DispatchQueue.main.async {
                        MemorySingleton.QueueDepends[i].DLProgress.Progress = (observationProgress.fractionCompleted / 120) * 100
                    }
                }
                MemorySingleton.QueueDepends[i].DLProgress.dataTask?.resume()
            }
        }
    }

    
    func process() {
        for i in 0..<MemorySingleton.Queue.count {
            MemorySingleton.Queue[i].DLProgress.Message = "Installing"
            let RepositoryContent = MemorySingleton.Queue[i].RepositoryContentPack.RepositoryContent
            if MemorySingleton.Queue[i].Mode == "Install" || MemorySingleton.Queue[i].Mode == "Update" {
                guard let url_str = MemorySingleton.Queue[i].Releases.Package else {
                    MemorySingleton.Queue[i].DLProgress.Message = MILocalizedString("URL Error")
                    return
                }
                guard let url = URL(string: url_str) else {
                    MemorySingleton.Queue[i].DLProgress.Message = MILocalizedString("URL Error")
                    return
                }
                MemorySingleton.Queue[i].DLProgress.dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            MemorySingleton.Queue[i].DLProgress.Message = MILocalizedString("Extract...")
                        }
                        
                        // Data Write
                        guard let zip = URLwithEncode(string: "\(DataPath("Download"))/\(RepositoryContent.PackageID).zip") else { return }
                        do {
                            try data?.write(to: zip)
                        }catch{
                            print(error.localizedDescription)
                            UIApplication.shared.alert(body: MILocalizedString("Unknown error. You don't have access to this directory\n\(error.localizedDescription)"), withButton: true)
                            DispatchQueue.main.async {
                                MemorySingleton.Queue[i].DLProgress.ProcessEnd = true
                            }
                            return
                        }
                        if let hashcheck = FileManager.default.contents(atPath: zip.path) {
                            print("sha256(data: hashcheck)")
                            print(sha256(data: hashcheck))
                        }
                        
                        let Message = AddonImport(zip, MemorySingleton.Queue[i])
                        
                        DispatchQueue.main.async {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if i >= 0 && i < MemorySingleton.Queue.count {
                                    MemorySingleton.Queue[i].DLProgress.Progress = 100
                                    MemorySingleton.Queue[i].DLProgress.Message = Message
                                    MemorySingleton.Queue[i].DLProgress.ProcessEnd = true
                                }
                            }
                        }
                        
                    }
                }
                MemorySingleton.Queue[i].DLProgress.observation = MemorySingleton.Queue[i].DLProgress.dataTask?.progress.observe(\.fractionCompleted) { observationProgress, _ in
                    DispatchQueue.main.async {
                        MemorySingleton.Queue[i].DLProgress.Progress = (observationProgress.fractionCompleted / 120) * 100
                    }
                }
                MemorySingleton.Queue[i].DLProgress.dataTask?.resume()
            }else if MemorySingleton.Queue[i].Mode == "Uninstall" {
                MemorySingleton.Queue[i].DLProgress.Progress = 90
                MemorySingleton.Queue[i].DLProgress.Message = "Uninstalling"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    do {
                        if MemorySingleton.Queue[i].RepositoryContentPack.RepositoryContent.PackageID == "" { return }
                        let folder = MemorySingleton.Queue[i].RepositoryContentPack.RepositoryContent.PackageID == "PackageID" ? MemorySingleton.Queue[i].Extra : MemorySingleton.Queue[i].RepositoryContentPack.RepositoryContent.PackageID
                        if "\(DataPath("Packages"))/\(folder ?? "sss")" == "\(DataPath("Packages"))" { return }
                        try FileManager.default.removeItem(atPath: "\(DataPath("Packages"))/\(folder ?? "sss")")
                        DispatchQueue.main.async {
                            MemorySingleton.Queue[i].DLProgress.Progress = 100
                            MemorySingleton.Queue[i].DLProgress.Message = "Uninstalled"
                            MemorySingleton.Queue[i].DLProgress.ProcessEnd = true
                        }
                    }catch{
                        print(error.localizedDescription)
                        MemorySingleton.Queue[i].DLProgress.Message = "Failed"
                        MemorySingleton.Queue[i].DLProgress.ProcessEnd = true
                    }
                }
            }
        }
    }
}

struct QueueRow: View {
    @Binding var Queue: QueueType
    @Binding var Confirmed: Bool
    @State private var showProgressIndicator: Bool = true
    var body: some View {
        VStack {
            Rectangle()
                .frame(height: 1.0)
                .foregroundColor(.clear)
            HStack {
                if !Confirmed {
                    ImageLoader(Queue.RepositoryContentPack.RepositoryContent.Icon)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .padding(EdgeInsets(
                            top: 0,
                            leading: 0,
                            bottom: 0,
                            trailing: 5
                        ))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(Queue.RepositoryContentPack.RepositoryContent.Name == "Name" ? Queue.Extra ?? "" : Queue.RepositoryContentPack.RepositoryContent.Name)
                        .font(.headline)
                    Text(Queue.Releases.Version)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(MILocalizedString(Queue.DLProgress.Message))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .frame(height: 50)
            ProgressIndicatorView(isVisible: $showProgressIndicator, type: .bar(progress: $Queue.DLProgress.Progress, backgroundColor: .gray.opacity(0.25)))
                .frame(height: 1.0)
                .foregroundColor(.blue)
                .padding(.top, 2)
        }
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 8)
    }
}

