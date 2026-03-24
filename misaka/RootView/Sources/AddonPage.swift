//
//  AddonPage.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/11.
//

import Foundation
import SwiftUI
import ScrollKit
import MarkdownUI
import SwiftUIImageViewer
import AlertToast

struct AddonPage: View {
    @Environment(\ .colorScheme)var colorScheme
    @State var RepositoryURL: String
    @State var Repository: RepositoryType = RepositoryType()
    @State var RepositoryContent: RepositoryContentType = RepositoryContentType()
    
    func header() -> some View {
        VStack {
            if UIDevice.current.isiPhone {
                ImageLoader((RepositoryContent.HeaderImage ?? Repository.Default.HeaderImage) ?? "", loadingAnim: true)
                    .scaledToFill()
                    .frame(height: 290)
                    .clipped()

                    .aspectRatio(contentMode: .fill)
                    .mask(LinearGradient(gradient: Gradient(stops: [
                        .init(color: .black, location: 0.7),
                        .init(color: .clear, location: 1)
                    ]), startPoint: .top, endPoint: .bottom))
            }else{
                ImageLoader((RepositoryContent.HeaderImage ?? Repository.Default.HeaderImage) ?? "", loadingAnim: true)
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 290)
                    .clipped()
                    .mask(LinearGradient(gradient: Gradient(stops: [
                        .init(color: .black, location: 0.7),
                        .init(color: .clear, location: 1)
                    ]), startPoint: .top, endPoint: .bottom))
            }
        }
        .contextMenu {
            Button(MILocalizedString("Save to Photos")){
                Requests(RequestsType(Method: "Get", URL: (RepositoryContent.HeaderImage ?? Repository.Default.HeaderImage) ?? "")) { data in
                    if let data = data,
                       let uiimage = UIImage(data: data) {
                        ImageSaver().writeToPhotoAlbum(image: uiimage)
                    }
                }
            }
            Button(MILocalizedString("Clip URL")){
                UIPasteboard.general.setString((RepositoryContent.HeaderImage ?? Repository.Default.HeaderImage) ?? "")
            }
        }
    }
    var body: some View {
        ZStack {
            Background(Shadow: true)
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ScrollViewHeader {
                        ZStack(alignment: .bottomLeading) {
                            header()
                        }
                    }.frame(height: 130)
                    top
                    li
                    md
                    sc
                    HStack {
                        Spacer()
                        Text(RepositoryContent.PackageID)
                            .contextMenu {
                                Button(MILocalizedString("Copy RepoURL & PackageID")) {
                                    let s = """
                            {
                              "RepositoryURL": "\(RepositoryURL)",
                              "PackageID": "\(RepositoryContent.PackageID)"
                            },
                        """
                                    UIPasteboard.general.string = s
                                }
                            }
                            .padding()
                    }
                }
            }
        }
    }
    
    
    @StateObject var MemorySingleton = Memory.shared
    var top: some View {
        HStack {
            ImageLoader(RepositoryContent.Icon, loadingAnim: true)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(20)
                .frame(width: 110, height: 110)
                .padding(.trailing, 13)
                .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2), radius: 3, x: 4, y: 4)
                .contextMenu {
                    Button(MILocalizedString("Save to Photos")){
                        Requests(RequestsType(Method: "Get", URL: RepositoryContent.Icon)) { data in
                            if let data = data,
                               let uiimage = UIImage(data: data) {
                                ImageSaver().writeToPhotoAlbum(image: uiimage)
                            }
                        }
                    }
                    Button(MILocalizedString("Clip URL")){
                        UIPasteboard.general.setString(RepositoryContent.Icon)
                    }
                }
            HStack {
                VStack(alignment: .leading) {
                    Text(RepositoryContent.Name)
                        .lineLimit(2)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2), radius: 3, x: 4, y: 4)
                    Text(RepositoryContent.Description)
                        .lineLimit(2)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .opacity(0.4)
                        .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2), radius: 3, x: 4, y: 4)
                    Spacer()
                    let Checker = QueueType(
                        Mode: "Install",
                        Releases: RepositoryContent.Releases.last ?? ReleasesType(),
                        RepositoryContentPack: RepositoryContentPackType(
                            RepositoryURL: RepositoryURL,
                            Repository: Repository,
                            RepositoryContent: RepositoryContent
                        )
                    )
                    let Support = isVersionInRange(check: iOSVer, min: RepositoryContent.MinIOSVersion ?? "0", max: RepositoryContent.MaxIOSVersion ?? "100")
                    let Build_Support = RepositoryContent.AdditionalSupportedIOS?.Build?.contains(ProductBuildVersion) ?? false
                    let compatibleExploit = compatibleExploitCheck(compatibleExploits: RepositoryContent.compatibleExploit)
                    let CompatibleOS = compatibleOSCheck(compatibleOSs: RepositoryContent.CompatibleOS)
                    let AppSupport = isVersionInRange(check: appver.replacingOccurrences(of: " Beta", with: ""), min: RepositoryContent.MinAppVersion ?? "0", max: "100")
                    
                    let supportOrBuild = Support || Build_Support
                    let canGet = repositoryInstallEligibleForGet(
                        supportOrBuild: supportOrBuild,
                        compatibleOS: CompatibleOS,
                        compatibleExploit: compatibleExploit,
                        appSupport: AppSupport
                    )
                    let misakaUpdate = repositoryShowMisakaUpdateRequiredInsteadOfUnsupported(
                        supportOrBuild: supportOrBuild,
                        compatibleOS: CompatibleOS,
                        compatibleExploit: compatibleExploit,
                        appSupport: AppSupport
                    )
                    let result: (String, Color) = MemorySingleton.Queue.contains { $0.isEqualIgnoringVersion(Checker) } ?
                        ("Queued", .red) :
                        InstalledPackages().contains(RepositoryContent.PackageID) ?
                        (!isVersionLessThan(check: InstalledPackageVersion(RepositoryContent.PackageID), min: RepositoryContent.Releases.last?.Version ?? "") ?
                            ("Uninstall", .pink) :
                            ("Update", .orange)) :
                        (canGet ?
                            ("GET", .blue) : misakaUpdate ?
                            ("Misaka update required", .blue) : ("Not Supported", .blue))

                    Button(MILocalizedString(result.0)) {
                        withAnimation(.linear(duration: 0.2)) {
                            switch result.0 {
                            case "GET":
                                MemorySingleton.Queue.append(Checker)
                            case "Uninstall":
                                var Uninstall = Checker
                                Uninstall.Mode = "Uninstall"
                                MemorySingleton.Queue.append(Uninstall)
                            case "Queued":
                                MemorySingleton.Queue.removeAll(where: { $0.isEqualIgnoringVersion(Checker) })
                            case "Update":
                                var Update = Checker
                                Update.Mode = "Update"
                                MemorySingleton.Queue.append(Update)
                            default: break
                            }
                            QueueCheck()
                        }
                    }
                    .padding(EdgeInsets(
                        top: 5,
                        leading: 22,
                        bottom: 5,
                        trailing: 22
                    ))
                    .background(result.1)
                    .foregroundColor(.white.opacity(0.9))
                    .cornerRadius(50)
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2), radius: 3, x: 4, y: 4)
                }
                Spacer()
                VStack {
                    Spacer()
                    Button {
                        let TextoCompartido = "https://straight-tamago.github.io/misaka/?repo=\(RepositoryURL)&tweak=\(RepositoryContent.PackageID)"
                        let AV = UIActivityViewController(activityItems: [TextoCompartido], applicationActivities: nil)
                        let scenes = UIApplication.shared.connectedScenes
                        let windowScene = scenes.first as? UIWindowScene
                        windowScene?.keyWindow?.rootViewController?.present(AV, animated: true, completion: nil)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                    }
                    .padding(.bottom, 1)
                }
            }
            .padding(.vertical, 1)
        }
        .padding(.top, 30)
        .padding(.bottom, 20)
        .padding(.horizontal, 30)
    }
    
    var md: some View {
        HStack {
            Markdown(RepositoryContent.Caption)
                .markdownTextStyle(\.code) {
                    FontFamilyVariant(.monospaced)
                    FontSize(.em(0.45))
                    ForegroundColor(.white)
                    BackgroundColor(.purple.opacity(0.25))
                }
                .padding(.horizontal, 33)
                .padding(.vertical, 15)
            Spacer()
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if RepositoryContent.ViewCount != nil {
                        Text(MILocalizedString("Views:")+" "+String(ViewCount))
                            .font(.caption)
                            .padding(.trailing, 10)
                            .opacity(0.7)
                    }else if Repository.Default.ViewCount == true {
                        Text(MILocalizedString("Views:")+" "+String(ViewCount))
                            .font(.caption)
                            .padding(.trailing, 10)
                            .opacity(0.7)
                    }
                }
            }
        )
    }
    
    @State private var showingActionSheet = false
    var sc: some View {
        VStack {
            ScrollView (.horizontal){
                HStack {
                    ForEach(0..<min(RepositoryContent.Screenshot.count , 10), id: \.self) { i in
                        ScreenShot(imgURL: RepositoryContent.Screenshot[i])
                    }
                }
            }
            .padding(.vertical, 5)
        }
        .padding(.leading, 30)
        .padding(.bottom, 15)
    }
    
    @State var ViewCount: Int = 0
    var li: some View {
        VStack {
            Rectangle()
                .frame(height: 0.9)
            ScrollView (.horizontal, showsIndicators: false){
                HStack {
//                    Rectangle()
//                        .frame(width: 0.3)
//                        .shadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
                    
                    Group {
                        Button(action: {
                            if (RepositoryContent.Author != nil) {
                                if RepositoryContent.Author?.Links.count != 0 {
                                    showingActionSheet = true
                                }
                            }else{
                                if Repository.Default.Author?.Links.count != 0 {
                                    showingActionSheet = true
                                }
                            }
                        }) {
                            VStack {
                                Text(MILocalizedString("AUTHOR"))
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                Text(RepositoryContent.Author?.Label ?? Repository.Default.Author?.Label ?? "Author")
                                    .font(.headline)
                            }
                            .padding(EdgeInsets(
                                top: 6,
                                leading: 25,
                                bottom: 6,
                                trailing: 25
                            ))
                        }
                        .actionSheet(isPresented: $showingActionSheet) {
                            let authorLinks = RepositoryContent.Author?.Links ?? Repository.Default.Author?.Links ?? []
                            let buttons = authorLinks.map { option in
                                ActionSheet.Button.default(Text(option.Label ?? "")) {
                                    if let url = URL(string: option.Link ?? "") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                            return ActionSheet(title: Text(MILocalizedString("Author")), buttons: buttons + [ActionSheet.Button.cancel()])
                        }
//                        Rectangle()
//                            .frame(width: 0.3)
//                            .shadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
                    }
                    Group {
                        NavigationLink {
                            AddonPageVersion(RepositoryURL: RepositoryURL, Repository: Repository, RepositoryContent: RepositoryContent)
                        } label: {
                            VStack {
                                Text(MILocalizedString("VERSION"))
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                Text(String(RepositoryContent.Releases.last?.Version ?? "0.0"))
                                    .font(.headline)
                            }
                            .padding(EdgeInsets(
                                top: 6,
                                leading: 25,
                                bottom: 6,
                                trailing: 25
                            ))
                        }
//                        Rectangle()
//                            .frame(width: 0.3)
//                            .shadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
                    }
                    Group {
                        VStack {
                            Text(MILocalizedString("REQUIRED iOS"))
                                .font(.system(size: 10, weight: .bold, design: .default))
                            HStack{
                                if (RepositoryContent.MaxIOSVersion != nil) || (RepositoryContent.MinIOSVersion != nil) {
                                    if (RepositoryContent.MinIOSVersion != nil) {
                                        Text(String(RepositoryContent.AdditionalSupportedIOS?.MinIOSVersion_CustomLabel ?? RepositoryContent.MinIOSVersion ?? "0.0"))
                                            .font(.headline)
                                    }
                                    Text("-")
                                    if (RepositoryContent.MaxIOSVersion != nil) {
                                        Text(String(RepositoryContent.AdditionalSupportedIOS?.MaxIOSVersion_CustomLabel ?? RepositoryContent.MaxIOSVersion ?? "0.0"))
                                            .font(.headline)
                                    }
                                }else{
                                    Text(("Unknown"))
                                        .font(.headline)
                                }
                            }
                        }
                        .padding(EdgeInsets(
                            top: 6,
                            leading: 25,
                            bottom: 6,
                            trailing: 25
                        ))
//                        Rectangle()
//                            .frame(width: 0.3)
//                            .shadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
                    }
                    if RepositoryContent.compatibleExploit != [] {
                        Group {
                            VStack {
                                Text(MILocalizedString("REQUIRED EXPLOITS"))
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                HStack{
                                    Text(RepositoryContent.compatibleExploit.joined(separator: ", "))
                                    .font(.headline)
                                }
                            }
                            .padding(EdgeInsets(
                                top: 6,
                                leading: 25,
                                bottom: 6,
                                trailing: 25
                            ))
                        }
                    }
                    if RepositoryContent.CompatibleOS != ["iOS", "iPadOS"] {
                        Group {
                            VStack {
                                Text(MILocalizedString("REQUIRED OS"))
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                HStack{
                                    Text(RepositoryContent.CompatibleOS.joined(separator: ", "))
                                    .font(.headline)
                                }
                            }
                            .padding(EdgeInsets(
                                top: 6,
                                leading: 25,
                                bottom: 6,
                                trailing: 25
                            ))
                        }
                    }
                    Group {
                        NavigationLink {
                            Addons(RepositoryURL: RepositoryURL, Repository: Repository)
                        } label: {
                            VStack {
                                Text(MILocalizedString("REPOSITORY"))
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                Text(Repository.RepositoryName)
                                    .font(.headline)
                            }
                            .padding(EdgeInsets(
                                top: 6,
                                leading: 25,
                                bottom: 6,
                                trailing: 25
                            ))
                        }
//                        Rectangle()
//                            .frame(width: 0.3)
//                            .shadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
                    }
                    Group {
                        NavigationLink {
                            Categorys(Category: RepositoryContent.Category)
                        } label: {
                            VStack {
                                Text(MILocalizedString("CATEGORY"))
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                Text(RepositoryContent.Category)
                                    .font(.headline)
                            }
                            .padding(EdgeInsets(
                                top: 6,
                                leading: 25,
                                bottom: 6,
                                trailing: 25
                            ))
                        }
//                        Rectangle()
//                            .frame(width: 0.3)
//                            .shadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            Rectangle()
                .frame(height: 0.7)
        }
        .foregroundColor(.primary)
        .opacity(0.4)
        .padding(.leading, 30)
        .shadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
        .onAppear {
            if RepositoryContent.ViewCount != nil {
                View_Count_ALL_Add(PackageID: RepositoryContent.PackageID)
                View_Count_ALL_Get(PackageID: RepositoryContent.PackageID)
            }else if Repository.Default.ViewCount == true {
                View_Count_ALL_Add(PackageID: RepositoryContent.PackageID)
                View_Count_ALL_Get(PackageID: RepositoryContent.PackageID)
            }
        }
    }
    
    func View_Count_ALL_Add(PackageID: String) {
        let url_str = "http://shimajiron.php.xdomain.jp/count/ViewCount/add.php?id="+PackageID
        Requests(RequestsType(Method: "Get", URL: url_str)) { data in }
    }
    func View_Count_ALL_Get(PackageID: String) {
        let url_str = "http://shimajiron.php.xdomain.jp/count/ViewCount/getm.php?id="+PackageID
        Requests(RequestsType(Method: "Get", URL: url_str)) { data in
            if let data = data, let count = Int(String(data: data, encoding: .utf8) ?? "0") {
                self.ViewCount = count
            }
        }
    }
}

struct ScreenShot: View {
    @Environment(\ .colorScheme)var colorScheme
    @State private var isImagePresented = false
    @State var imgURL: String
    @State var uiimage: UIImage = UIImage()
    var body: some View {
        if ["mp4", "mov"].contains(URL(string: imgURL)?.pathExtension){
            if let videoURL = URL(string: imgURL) {
                VideoPlayer(someVideoURL: videoURL)
                    .frame(width: 253, height: 550)
                    .clipped()
                    .cornerRadius(10)
                    .padding(EdgeInsets(
                        top: 6,
                        leading: 0,
                        bottom: 6,
                        trailing: 5
                    ))
                    .padding(.trailing, 5)
                    .contextMenu {
                        Button(MILocalizedString("Clip URL")){
                            UIPasteboard.general.string = imgURL
                        }
                    }
            }
        }else{
            ImageLoader(uiimage == UIImage() ? "zzz" : imgURL, loadingAnim: true)
                .aspectRatio(contentMode: .fit)
                .frame(width: 253, height: 550)
                .background(Color.black)
                .cornerRadius(10)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.4), lineWidth: 0.5))
                .shadow(radius: 0.5)
                .padding(EdgeInsets(
                    top: 6,
                    leading: 0,
                    bottom: 6,
                    trailing: 5
                ))
                .padding(.trailing, 5)
                .onTapGesture {
                    isImagePresented = true
                }
                .fullScreenCover(isPresented: $isImagePresented) {
                    SwiftUIImageViewer(image: image)
                        .overlay(alignment: .topTrailing) {
                            closeButton
                        }
                }
                .onAppear{
                    DispatchQueue.global().async {
                        uiimage = UIImage(url: imgURL)
                    }
                }
                .contextMenu {
                    Button(MILocalizedString("Save to Photos")){
                        ImageSaver().writeToPhotoAlbum(image: uiimage)
                    }
                    Button(MILocalizedString("Clip URL")){
                        UIPasteboard.general.setString(imgURL)
                    }
                }
        }
        
    }
    
    private var image: Image {
        Image(uiImage: uiimage)
    }
    
    private var closeButton: some View {
        Button {
            isImagePresented = false
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
        }
        .buttonStyle(.bordered)
        .clipShape(Circle())
        .tint(.purple)
        .padding()
    }
}

func compatibleExploitCheck(compatibleExploits: [String]) -> Bool {
    if compatibleExploits.isEmpty { return true }
    if compatibleExploits.contains(SettingsManager.shared.Exploit) { return true }
    // KRW: many repos still advertise only MDC/KFD; treat as compatible.
    if SettingsManager.shared.Exploit == "DarkSword" {
        if compatibleExploits.contains("DarkSword") || compatibleExploits.contains("MDC") || compatibleExploits.contains("KFD") {
            return true
        }
    }
    return false
}
func compatibleOSCheck(compatibleOSs: [String]) -> Bool {
    if UIDevice.current.isiPhone && compatibleOSs.contains("iOS") {
        return true
    }
    if UIDevice.current.isiPad && compatibleOSs.contains("iPadOS") {
        return true
    }
    return false
}

/// Developer Mode bypasses repo Min/Max iOS, build allowlist, and MinAppVersion for GET (exploit + OS family still enforced).
func repositoryVersionLimitsBypassEnabled() -> Bool {
    UserDefaults.standard.bool(forKey: "DeveloperMode")
}

/// Whether the package can show GET (before queue / install-state checks). With developer bypass: always true (repo iOS/app/OS/exploit metadata ignored).
func repositoryInstallEligibleForGet(
    supportOrBuild: Bool,
    compatibleOS: Bool,
    compatibleExploit: Bool,
    appSupport: Bool
) -> Bool {
    if repositoryVersionLimitsBypassEnabled() {
        return true
    }
    return supportOrBuild && compatibleOS && compatibleExploit && appSupport
}

/// When true, prefer "Misaka update required" over "Not Supported" (misaka app below MinAppVersion only; bypass disables this).
func repositoryShowMisakaUpdateRequiredInsteadOfUnsupported(
    supportOrBuild: Bool,
    compatibleOS: Bool,
    compatibleExploit: Bool,
    appSupport: Bool
) -> Bool {
    if repositoryVersionLimitsBypassEnabled() { return false }
    return !appSupport && supportOrBuild && compatibleOS && compatibleExploit
}

extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}
