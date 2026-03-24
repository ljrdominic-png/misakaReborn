//
//  Sources_Content_Version.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/03/08.
//

import Foundation
import SwiftUI

struct AddonPageVersion: View {
    @StateObject var MemorySingleton = Memory.shared
    @State var RepositoryURL: String
    @State var Repository: RepositoryType = RepositoryType()
    @State var RepositoryContent: RepositoryContentType = RepositoryContentType()
    
    var body: some View {
        List(RepositoryContent.Releases.reversed(), id: \.self) { item in
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.Version)
                        Text(item.Description ?? MILocalizedString("No update log"))
                    }
                    Spacer()
                    AddonPageVersion_Button(
                        RepositoryURL: RepositoryURL,
                        Repository: Repository,
                        RepositoryContent: RepositoryContent,
                        Releases: item
                    )
                }
            }
        }
    }
}

struct AddonPageVersion_Button: View {
    @StateObject var MemorySingleton = Memory.shared
    @State var RepositoryURL: String
    @State var Repository: RepositoryType
    @State var RepositoryContent: RepositoryContentType
    @State var Releases: ReleasesType
    
    var body: some View {
        let Checker = QueueType(
            Mode: "Install",
            Releases: Releases,
            RepositoryContentPack: RepositoryContentPackType(
                RepositoryURL: RepositoryURL,
                Repository: Repository,
                RepositoryContent: RepositoryContent
            )
        )
        
        let Support = isVersionInRange(check: iOSVer, min: RepositoryContent.MinIOSVersion ?? "0", max: RepositoryContent.MaxIOSVersion ?? "100")
        let Build_Support = RepositoryContent.AdditionalSupportedIOS?.Build?.contains(ProductBuildVersion) ?? false
        let compatibleExploit = RepositoryContent.compatibleExploit != [String]() ? compatibleExploitCheck(compatibleExploits: RepositoryContent.compatibleExploit) : true
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
        let result: (String, Color) = MemorySingleton.Queue.contains(Checker) ?
            ("Queued", .red) :
        InstalledPackages().contains(RepositoryContent.PackageID) && InstalledPackageVersion(RepositoryContent.PackageID) == Releases.Version ?
                ("Uninstall", .pink) :
            (canGet ?
                ("GET", .blue) : misakaUpdate ?
                ("Misaka update required", .blue) : ("Not Supported", .blue))
        
        Button(MILocalizedString(result.0)) {
            withAnimation(.interpolatingSpring(stiffness: 500, damping: 500)) {
                MemorySingleton.Queue.removeAll(where: { $0.isEqualIgnoringVersion(Checker) })
                switch result.0 {
                case "GET":
                    MemorySingleton.Queue.append(Checker)
                case "Uninstall":
                    var Uninstall = Checker
                    Uninstall.Mode = "Uninstall"
                    MemorySingleton.Queue.append(Uninstall)
                case "Queued":
                    MemorySingleton.Queue.removeAll(where: { $0 == Checker})
                default: break
                }
            }
            QueueCheck()
        }
        .padding(EdgeInsets(
            top: 6,
            leading: 25,
            bottom: 6,
            trailing: 25
        ))
        .font(.subheadline)
        .background(result.1)
        .foregroundColor(.white)
        .cornerRadius(50)
    }
}

