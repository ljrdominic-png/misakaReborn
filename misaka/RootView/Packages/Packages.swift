//
//  Packages.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/09.
//

import SwiftUI
import FilePicker
import AlertToast

struct Packages: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @ObservedObject var ViewMemorySingleton = ViewMemory.shared
    var body: some View {
        ZStack {
            VStack {
                if ViewMemorySingleton.Applying != true && ViewMemorySingleton.Reloading != true{
                    VStack {
                        if MemorySingleton.DisplayType == 0 {
                            PackagesRootAddon(Mode: "List")
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarLeading){
                                        FilePicker(types: [.item], allowMultiple: false, title: MILocalizedString("Import")) { urls in
//                                            ViewMemory.shared.AppLoading = true
                                            let res = AddonImport(urls.first!, nil)
                                            if res == "Installed" {
                                                ToastController.shared.Toast_complete = AlertToast(type: .complete(.green), title: "Imported", subTitle: "")
                                                ToastController.shared.Show_complete = true
                                            }else {
                                                ToastController.shared.Toast_error = AlertToast(type: .error(.red), title: "Error", subTitle: res)
                                                ToastController.shared.Show_error = true
                                            }
//                                            ViewMemory.shared.AppLoading = false
                                        }
                                    }
                                    ToolbarItem(placement: .navigationBarTrailing){
                                        HStack{
                                            TBModule(ModuleName: "Applying_Keep")
                                            TBModule(ModuleName: "Respring")
                                            TBModule(ModuleName: "Apply")
                                            TBModule(ModuleName: "DisplayType")
                                        }
                                    }
                                }
                        }else if MemorySingleton.DisplayType == 1 {
                            PackagesRootAddon(Mode: "Grid")
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarLeading){
                                        FilePicker(types: [.item], allowMultiple: false, title: MILocalizedString("Import")) { urls in
//                                            ViewMemory.shared.AppLoading = true
                                            let res = AddonImport(urls.first!, nil)
                                            if res == "Installed" {
                                                ToastController.shared.Toast_complete = AlertToast(type: .complete(.green), title: "Imported", subTitle: "")
                                                ToastController.shared.Show_complete = true
                                            }else {
                                                ToastController.shared.Toast_error = AlertToast(type: .error(.red), title: "Error", subTitle: res)
                                                ToastController.shared.Show_error = true
                                            }
//                                            ViewMemory.shared.AppLoading = false
                                        }
                                    }
                                    ToolbarItem(placement: .navigationBarTrailing){
                                        HStack{
                                            TBModule(ModuleName: "Applying_Keep")
                                            TBModule(ModuleName: "Respring")
                                            TBModule(ModuleName: "Apply")
                                            TBModule(ModuleName: "DisplayType")
                                        }
                                    }
                                }
                        }
                    }
//                    .actionSheet(isPresented: $EN.IconTheme_ActionSheet_IsActive) {
//                        return ActionSheet(title: Text(MILocalizedString("Select Theme")), buttons:
//                                            ((EN.IconTheme_Themes_ActionSheet.map { theme in
//                            ActionSheet.Button.default(Text(theme)) {
//                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
//                                EN.App_Loading = true
//                                DispatchQueue.global().async {
//                                    EN.IconTheme_Theme = theme
//                                    let _ = IconTheme(PackageID: EN.IconTheme_PackageID, Theme: theme, Mode: "Apply", EN: EN)
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                        EN.App_Loading = false
//                                    }
//                                }
//                            }
//                        }))
//                                           + [ActionSheet.Button.cancel()]
//                        )
//                    }
                }else{
                    if !ViewMemorySingleton.Reloading {
                        HStack {
                            BounceAnimationView(text: MILocalizedString("Applying..."), startTime: 0.0)
                            ActivityIndicator()
                        }
                    }
                }
            }
            .sheet(isPresented: $MemorySingleton.ToolBox_IsActive) {
                ToolBox()
            }
            FloatingToolbox()
        }
    }
}


struct PackagesRootAddon: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @State var Mode: String
    @State var Addons: [String] = [String]()
    @State var columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    @State var currentAddon: String?
    var body: some View {
        ZStack {
            NavigationLink(
                destination: DebugLogs(),
                isActive: $MemorySingleton.DebugLogs_isActive,
                label: {
                }
            )
            NavigationLink(
                destination: AdvancedSettings(),
                isActive: $MemorySingleton.AdvancedSettings_isActive,
                label: {
                }
            )
            NavigationLink(
                destination:
                    AddonPage(
                        RepositoryURL: MemorySingleton.AddonPage_RepositoryContentPack.RepositoryURL,
                        Repository: MemorySingleton.AddonPage_RepositoryContentPack.Repository,
                        RepositoryContent: MemorySingleton.AddonPage_RepositoryContentPack.RepositoryContent
                    ),
                isActive: $MemorySingleton.AddonPage_isActive,
                label: {
                }
            )
            if Mode == "List" {
                List {
                    ForEach (Addons, id: \.self) { Addon in
                        if FileManager.default.isDirectory("\(DataPath("Packages"))/\(Addon)/Overwrite") ||
                            FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(Addon)/Special") {
                            PackagesAddon(Mode: Mode, Details: DetailsType(Addon: Addon))
                            .cornerRadius(7)
                            .listRowBackground(Color.clear)
                            .onDrag {
                                return NSItemProvider()
                            }
                        }
                    }
                    .onMove(perform: moveRow)
                }
                .listStyle(PlainListStyle())
            }else if Mode == "Grid" {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(Addons, id: \.self){ Addon in
                            if FileManager.default.isDirectory("\(DataPath("Packages"))/\(Addon)/Overwrite") ||
                                FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(Addon)/Special") {
                                PackagesAddon(Mode: Mode, Details: DetailsType(Addon: Addon))
                                    .onDrag({
                                        self.currentAddon = Addon
                                        return NSItemProvider(object: Addon as NSString)
                                    })
                                    .onDrop(of: [.text], delegate: DropViewDelegate(Addons: $Addons, Addon: Addon, currentAddon: currentAddon))
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            do {
                var ary = [(String, String)]()
                let dirs = try FileManager.default.contentsOfDirectoryExploit(atPath: DataPath("Packages"))
                for i in 0..<dirs.count {
                    guard let url = URLwithEncode(string: "file://\(DataPath("Packages"))/\(dirs[i])/.system/.index") else { continue }
                    if FileManager.default.fileExists(atPath: url.path) {
                        let index = try String(contentsOf: url, encoding: String.Encoding.utf8)
                        ary.append((dirs[i], index))
                    }else{
                        ary.append((dirs[i], "0"))
                    }
                }
                let sortedData = ary.sorted { Int($0.1) ?? 0 < Int($1.1) ?? 0 }
                Addons = sortedData.map { $0.0 }
            }catch {
                print(error.localizedDescription)
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                columns = [
                    GridItem(.adaptive(minimum: 180, maximum: 250))
                ]
            }
        }
    }
    private func moveRow(from source: IndexSet, to destination: Int) {
        Addons.move(fromOffsets: source, toOffset: destination)
        for i in Addons.indices {
            if FileManager.default.isDirectory("\(DataPath("Packages"))/\(Addons[i])") {
                try? FileManager.default.createDirectory(atPath: "\(DataPath("Packages"))/\(Addons[i])/.system", withIntermediateDirectories: true, attributes: nil)
                let data = String(i).data(using: .utf8)!
                try? data.write(to: URLwithEncode(string: "file://\(DataPath("Packages"))/\(Addons[i])/.system/.index")!)
            }
        }
    }
}

struct DetailsType: Codable, Hashable {
    var Addon: String = ""
    var Version: String = ""
    var Applying: Bool = false
    var isOFF: Bool = false
    var isKeep: Bool = false
    var isSucceed: Bool = false
    var updateAvailable: Bool = false
    var Repository: RepositoryType?
    var RepositoryContent: RepositoryContentType?
    var Result: [ResultType] = [ResultType]()
}


struct PackagesAddon: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @ObservedObject var ViewMemorySingleton = ViewMemory.shared
    @ObservedObject var ColorManagerSingleton = ColorManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State var Mode: String
    @State var Details: DetailsType
    @State var FirstBoot = true
    
    func apply(Mode: String = "") {
        if Details.Applying == true { return }
        DispatchQueue.main.async {
            Details.Applying = true
        }
        let AddonDir = "\(DataPath("Packages"))/\(Details.Addon)"
        DispatchQueue.global().async {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            try? FileManager.default.createDirectory(atPath: "\(AddonDir)/.system/", withIntermediateDirectories: true, attributes: nil)
            if Details.isOFF || !Details.isSucceed || Mode == "Apply" {
                let Result = Apply(PackageID: Details.Addon, Mode: "Apply")
                DispatchQueue.main.async {
                    Details.Result = Result
                    DispatchQueue.global().async {
                        if Details.Result != [ResultType]() {
                            try? FileManager.default.removeItem(atPath: "\(AddonDir)/.system/.OFF")
                        }
                        if FileManager.default.fileExists(atPath: "\(AddonDir)/Special") {
                            FileManager.default.createFile(atPath: "\(AddonDir)/.system/.OFF", contents: nil, attributes: nil)
                        }
                    }
                }
            }else {
                let Result = Apply(PackageID: Details.Addon, Mode: "Restore")
                FileManager.default.createFile(atPath: "\(AddonDir)/.system/.OFF", contents: nil, attributes: nil)
                try? FileManager.default.removeItem(atPath: "\(DataPath("BackgroundApply"))/\(Details.Addon)")
                DispatchQueue.main.async {
                    Details.Result = Result
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: 0.3)) {
                        ViewMemory.shared.Details = Details
                    }
                }
            }
            let isSucceed = Apply(PackageID: Details.Addon, Mode: "IsSucceeded").allSatisfy({ $0.IsSuccess == true })
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 0.3)) {
                    Details.isSucceed = isSucceed
                    Details.isOFF = FileManager.default.fileExists(atPath: "\(AddonDir)/.system/.OFF")
                    Details.Applying = false
                }
            }
        }
    }
    
    
    var body: some View {
        ZStack {
            if Mode == "Grid" {
                Button(action: {
                    apply()
                }){
                    HStack{
                        Spacer()
                        VStack(alignment: .leading) {
                            HStack {
                                ImageLoader(Details.RepositoryContent?.Icon ?? "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoIcon.png")
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 50)
                                    .cornerRadius(10)
                                    .padding(EdgeInsets(
                                        top: 0,
                                        leading: 0,
                                        bottom: 2,
                                        trailing: 5
                                    ))
                                VStack(alignment: .leading) {
                                    Text(Details.RepositoryContent?.Name ?? Details.Addon)
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                }
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .frame(height: 110)
                    .padding(2)
                    .BoxBackground(isSucceeded: Details.isSucceed, colorScheme: colorScheme)
                    .cornerRadius(10)
                    .overlay(
                        VStack {
                            HStack{
                                Spacer()
                                if Details.updateAvailable {
                                    Image(systemName: "arrow.up.square.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(EdgeInsets(
                                            top: 8,
                                            leading: 0,
                                            bottom: 0,
                                            trailing: 1
                                        ))
                                        .foregroundColor(.orange)
                                }
                                if Details.Applying || ViewMemorySingleton.Applying_Addon == Details.Addon {
                                    ProgressView("")
                                        .frame(width: 20, height: 20)
                                        .padding(EdgeInsets(
                                            top: 14,
                                            leading: 0,
                                            bottom: 0,
                                            trailing: 8
                                        ))
                                        .foregroundColor(
                                            Details.isSucceed ? (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_ON : ColorManagerSingleton.W_Box_Other_ON) : (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_OFF : ColorManagerSingleton.W_Box_Other_OFF))
                                }else{
                                    Image(systemName: !Details.isOFF ? "checkmark.circle.fill" : "circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(EdgeInsets(
                                            top: 8,
                                            leading: 0,
                                            bottom: 0,
                                            trailing: 8
                                        ))
                                        .foregroundColor(Details.isKeep ? Color.green : Details.isSucceed ? (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_ON : ColorManagerSingleton.W_Box_Other_ON) : (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_OFF : ColorManagerSingleton.W_Box_Other_OFF))
                                }
                            }
                            Spacer()
                            HStack{
                                Spacer()
                                Text(Details.Version)
                                .padding(EdgeInsets(
                                    top: 0,
                                    leading: 0,
                                    bottom: 8,
                                    trailing: 8
                                ))
                                .foregroundColor(Details.isSucceed ? (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_ON : ColorManagerSingleton.W_Box_Other_ON) : (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_OFF : ColorManagerSingleton.W_Box_Other_OFF))
                                .font(.system(size: 14, weight: .bold, design: .default))
                            }
                        }
                    )
                }
            }else if Mode == "List" {
                Button(action: {
                    apply()
                }){
                    HStack{
                        Spacer()
                        VStack(alignment: .leading) {
                            HStack {
                                ImageLoader(Details.RepositoryContent?.Icon ?? "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoIcon.png")
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 50)
                                    .cornerRadius(10)
                                    .padding(EdgeInsets(
                                        top: 0,
                                        leading: 0,
                                        bottom: 2,
                                        trailing: 5
                                    ))
                                VStack(alignment: .leading) {
                                    Text(Details.RepositoryContent?.Name ?? Details.Addon)
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                }
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .frame(height: 70)
                    .padding(2)
                    .BoxBackground(isSucceeded: Details.isSucceed, colorScheme: colorScheme)
                    .cornerRadius(10)
                    .overlay(
                        VStack {
                            HStack{
                                Spacer()
                                if Details.updateAvailable {
                                    Image(systemName: "arrow.up.square.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(EdgeInsets(
                                            top: 8,
                                            leading: 0,
                                            bottom: 0,
                                            trailing: 1
                                        ))
                                        .foregroundColor(.orange)
                                }
                                if Details.Applying || ViewMemorySingleton.Applying_Addon == Details.Addon {
                                    ProgressView("")
                                        .frame(width: 20, height: 20)
                                        .padding(EdgeInsets(
                                            top: 14,
                                            leading: 0,
                                            bottom: 0,
                                            trailing: 8
                                        ))
                                        .foregroundColor(
                                            Details.isSucceed ? (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_ON : ColorManagerSingleton.W_Box_Other_ON) : (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_OFF : ColorManagerSingleton.W_Box_Other_OFF))
                                }else{
                                    Image(systemName: !Details.isOFF ? "checkmark.circle.fill" : "circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(EdgeInsets(
                                            top: 8,
                                            leading: 0,
                                            bottom: 0,
                                            trailing: 8
                                        ))
                                        .foregroundColor(Details.isKeep ? Color.green : Details.isSucceed ? (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_ON : ColorManagerSingleton.W_Box_Other_ON) : (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_OFF : ColorManagerSingleton.W_Box_Other_OFF))
                                }
                            }
                            Spacer()
                            HStack{
                                Spacer()
                                Text(Details.Version)
                                    .padding(EdgeInsets(
                                        top: 0,
                                        leading: 0,
                                        bottom: 8,
                                        trailing: 8
                                    ))
                                    .foregroundColor(Details.isSucceed ? (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_ON : ColorManagerSingleton.W_Box_Other_ON) : (colorScheme == .dark ? ColorManagerSingleton.D_Box_Other_OFF : ColorManagerSingleton.W_Box_Other_OFF))
                                    .font(.system(size: 14, weight: .bold, design: .default))
                            }
                        }
                    )
                }
            }
        }
        .onAppear {
            let decoder = JSONDecoder()
            decoder.allowsJSON5 = true
            if let data = FileManager.default.contents(atPath: "\(DataPath("Packages"))/\(Details.Addon)/.system/info.json"),
               let json = try? decoder.decode(RepositoryContentType.self, from: data) {
                Details.RepositoryContent = json
            }
            if let data = FileManager.default.contents(atPath: "\(DataPath("Packages"))/\(Details.Addon)/.system/Version.json") {
                Details.Version = String(data: data, encoding: .utf8) ?? ""
            }
            if FirstBoot != true { return }
            DispatchQueue.global().async {
                Details.isSucceed = Apply(PackageID: Details.Addon, Mode: "IsSucceeded").allSatisfy({ $0.IsSuccess == true })
                Details.isOFF = FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(Details.Addon)/.system/.OFF")
                Details.isKeep = FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(Details.Addon)/.system/.Keep")
                
                if let RepositoryURL = Details.RepositoryContent?.RepositoryURL,
                   let Repository = CacheServices.shared.CachedRepository.CachedRepositoryWithURL[RepositoryURL],
                   let RepositoryContent = Repository.RepositoryContents.first(where: { $0.PackageID == Details.RepositoryContent!.PackageID }){
                    if InstalledPackageVersion(Details.RepositoryContent!.PackageID) != (RepositoryContent.Releases.last ?? ReleasesType()).Version {
                        Details.updateAvailable = true
                    }
                }
            }
            FirstBoot = false
        }
        .contextMenu {
            if FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(Details.Addon)/config.plist") {
                Button {
                    MemorySingleton.AdvancedSettings_Addon = Details.Addon
                    MemorySingleton.AdvancedSettings_isActive = true
                }label: {
                    Image(systemName: "gear")
                    Text(MILocalizedString("Advanced Settings"))
                }
            }
//            if FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(Details.Addon)/Settings.plist") {
//                Button {
//                    MemorySingleton.AdvancedSettingsV2_Addon = Details.Addon
//                    MemorySingleton.AdvancedSettingsV2_isActive = true
//                }label: {
//                    Image(systemName: "gear")
//                    Text(MILocalizedString("Advanced Settings v2"))
//                }
//            }
            if Details.updateAvailable {
                Button {
                    if let RepositoryURL = Details.RepositoryContent?.RepositoryURL,
                       let Repository = CacheServices.shared.CachedRepository.CachedRepositoryWithURL[RepositoryURL],
                       let RepositoryContent = Repository.RepositoryContents.first(where: { $0.PackageID == Details.RepositoryContent!.PackageID }),
                       let Releases = RepositoryContent.Releases.last {
                        MemorySingleton.Queue.append(QueueType(
                            Mode: "Install",
                            Releases: Releases,
                            RepositoryContentPack: RepositoryContentPackType(
                                RepositoryURL: RepositoryURL,
                                Repository: Repository,
                                RepositoryContent: RepositoryContent
                            )
                        ))
                        QueueCheck()
                    }
                }label: {
                    Image(systemName: "arrow.up.square.fill")
                    Text(MILocalizedString("Update"))
                }
            }
            if let RepositoryURL = Details.RepositoryContent?.RepositoryURL,
               let Repository = CacheServices.shared.CachedRepository.CachedRepositoryWithURL[RepositoryURL],
               let RepositoryContent = Repository.RepositoryContents.first(where: { $0.PackageID == Details.RepositoryContent!.PackageID }){
                Button {
                    MemorySingleton.AddonPage_RepositoryContentPack = RepositoryContentPackType(
                        RepositoryURL: RepositoryURL,
                        Repository: Repository,
                        RepositoryContent: RepositoryContent
                    )
                    MemorySingleton.AddonPage_isActive = true
                }label: {
                    Image(systemName: "gear")
                    Text(MILocalizedString("See in Repo page"))
                }
            }
            Button {
                ViewMemory.shared.Details = Details
                MemorySingleton.DebugLogs_isActive = true
            } label: {
                Image(systemName: "doc.text.below.ecg")
                Text(MILocalizedString("Debug Logs"))
            }
            Button {
                let AddonDir = "\(DataPath("Packages"))/\(Details.Addon)"
                if FileManager.default.fileExists(atPath: "\(AddonDir)/.system/.Keep") {
                    try? FileManager.default.removeItem(atPath: "\(AddonDir)/.system/.Keep")
                }else{
                    FileManager.default.createFile(atPath: "\(AddonDir)/.system/.Keep", contents: nil, attributes: nil)
                }
                withAnimation(.linear(duration: 0.3)) {
                    Details.isKeep = FileManager.default.fileExists(atPath: "\(AddonDir)/.system/.Keep")
                    apply(Mode: "Apply")
                }
            }label: {
                Image(systemName: "clock.arrow.circlepath")
                Text(MILocalizedString("Run in Background"))
            }
            Button {
                if Details.Applying == true { return }
                Details.Applying = true
                let AddonDir = "\(DataPath("Packages"))/\(Details.Addon)"
                DispatchQueue.global().async {
                    Details.Result = Apply(PackageID: Details.Addon, Mode: "Restore")
                    FileManager.default.createFile(atPath: "\(AddonDir)/.system/.OFF", contents: nil, attributes: nil)
                    try? FileManager.default.removeItem(atPath: "\(DataPath("BackgroundApply"))/\(Details.Addon)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.linear(duration: 0.3)) {
                            ViewMemorySingleton.Details = Details
                        }
                    }
                    withAnimation(.linear(duration: 0.3)) {
                        Details.isSucceed = Apply(PackageID: Details.Addon, Mode: "IsSucceeded").allSatisfy({ $0.IsSuccess == true })
                        Details.isOFF = FileManager.default.fileExists(atPath: "\(AddonDir)/.system/.OFF")
                        Details.Applying = false
                    }
                }
            }label: {
                Image(systemName: "arrow.uturn.backward")
                Text(MILocalizedString("Force Restore & Disable"))
            }
            if FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(Details.Addon)/config.plist") && FileManager.default.fileExists(atPath: "\(DataPath("Packages"))/\(Details.Addon)/config_default.plist") {
                Button {
                    UIApplication.shared.confirmAlert(title: MILocalizedString("Reset Settings"), body: MILocalizedString("Are you sure you want to reset all settings?"), onOK: {
                        try? FileManager.default.removeItem(atPath: "\(DataPath("Packages"))/\(Details.Addon)/config.plist")
                        try? FileManager.default.copyItem(
                            atPath: "\(DataPath("Packages"))/\(Details.Addon)/config_default.plist",
                            toPath: "\(DataPath("Packages"))/\(Details.Addon)/config.plist"
                        )
                        UIApplication.shared.alert(title: "Reset Settings", body: MILocalizedString("Success"))
                    }, noCancel: false)
                }label: {
                    Image(systemName: "delete.left")
                    Text(MILocalizedString("Reset Settings"))
                }
            }
            if SettingsManager.shared.DeveloperMode {
                Button {
                    ShareAddon(Addon: Details.Addon)
                }label: {
                    Image(systemName: "square.and.arrow.up")
                    Text(MILocalizedString("Export"))
                }
            }
            Button(role: .destructive) {
                withAnimation(.linear(duration: 0.2)) {
                    MemorySingleton.Queue.append(
                        QueueType(
                            Mode: "Uninstall",
                            RepositoryContentPack: RepositoryContentPackType(
                                RepositoryContent: Details.RepositoryContent ?? RepositoryContentType()
                            ),
                            Extra: Details.Addon
                        )
                    )
                    MemorySingleton.Queue = Array(Set(MemorySingleton.Queue))
                    QueueCheck()
                }
            } label: {
                Label(MILocalizedString("Uninstall"), systemImage: "trash")
            }
        }
    }
}


struct DropViewDelegate: DropDelegate {
    @Binding var Addons: [String]
    var Addon: String
    var currentAddon: String?
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    func dropEntered(info: DropInfo) {
        let fromIndex = Addons.firstIndex { (grid) -> Bool in
            return grid == currentAddon
        } ?? 0
        let toIndex = Addons.firstIndex { (grid) -> Bool in
            return grid == self.Addon
        } ?? 0
        if fromIndex != toIndex{
            withAnimation(.default){
                let fromGrid = Addons[fromIndex]
                Addons[fromIndex] = Addons[toIndex]
                Addons[toIndex] = fromGrid
                for i in Addons.indices {
                    print("[* misaka] \(Addons[i]), \(i)")
                    if FileManager.default.isDirectory("\(DataPath("Packages"))/\(Addons[i])") {
                        try? FileManager.default.createDirectory(atPath: "\(DataPath("Packages"))/\(Addons[i])/.system", withIntermediateDirectories: true, attributes: nil)
                        let data : Data = String(i).data(using: .utf8)!
                        try? data.write(to: URL(string: "file://\(DataPath("Packages"))/\(Addons[i])/.system/.index")!)
                    }
                }
            }
        }
    }
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

extension View {
    func BoxBackground(isSucceeded: Bool, colorScheme: ColorScheme) -> some View {
        Group {
            if colorScheme == .dark {
                if ColorManager.shared.D_Box_Blur, #available(iOS 15, *)  {
                    self.background(.ultraThinMaterial.opacity(0.9))
                        .shadow(color: isSucceeded ? ColorManager.shared.D_Box_Shadow_ON : ColorManager.shared.D_Box_Shadow_OFF, radius: 3, x: 3, y: 3)
                        .foregroundColor(isSucceeded ? ColorManager.shared.D_Box_Text_ON : ColorManager.shared.D_Box_Text_OFF)
                }else{
                    self.background(isSucceeded ? ColorManager.shared.D_Box_Base_ON : ColorManager.shared.D_Box_Base_OFF)
                        .shadow(color: isSucceeded ? ColorManager.shared.D_Box_Shadow_ON : ColorManager.shared.D_Box_Shadow_OFF, radius: 3, x: 3, y: 3)
                        .foregroundColor(isSucceeded ? ColorManager.shared.D_Box_Text_ON : ColorManager.shared.D_Box_Text_OFF)
                }
            }else{
                if ColorManager.shared.W_Box_Blur, #available(iOS 15, *)  {
                    self.background(.ultraThinMaterial.opacity(0.9))
                        .shadow(color: isSucceeded ? ColorManager.shared.W_Box_Shadow_ON : ColorManager.shared.W_Box_Shadow_OFF, radius: 3, x: 3, y: 3)
                        .foregroundColor(isSucceeded ? ColorManager.shared.W_Box_Text_ON : ColorManager.shared.W_Box_Text_OFF)
                }else{
                    self.background(isSucceeded ? ColorManager.shared.W_Box_Base_ON : ColorManager.shared.W_Box_Base_OFF)
                        .shadow(color: isSucceeded ? ColorManager.shared.W_Box_Shadow_ON : ColorManager.shared.W_Box_Shadow_OFF, radius: 3, x: 3, y: 3)
                        .foregroundColor(isSucceeded ? ColorManager.shared.W_Box_Text_ON : ColorManager.shared.W_Box_Text_OFF)
                }
            }
        }
    }
}
