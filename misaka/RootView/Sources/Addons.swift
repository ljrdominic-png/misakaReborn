//
//  Addon.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/11.
//

import Foundation
import SwiftUI
import ScrollKit

struct Addons: View {
    @Environment(\ .colorScheme)var colorScheme
    @State var RepositoryURL: String
    @State var Repository: RepositoryType = RepositoryType()
    
    func header() -> some View {
        VStack {
            if UIDevice.current.isiPhone {
                ImageLoader(Repository.RepositoryIcon)
                    .aspectRatio(contentMode: .fill)
                    .mask(LinearGradient(gradient: Gradient(stops: [
                        .init(color: .black, location: 0.7),
                        .init(color: .clear, location: 1),
                        .init(color: .black, location: 1),
                        .init(color: .clear, location: 1)
                    ]), startPoint: .top, endPoint: .bottom))
            }else{
                ImageLoader(Repository.RepositoryIcon)
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 440)
                    .clipped()
                    .mask(LinearGradient(gradient: Gradient(stops: [
                        .init(color: .black, location: 0.7),
                        .init(color: .clear, location: 1),
                        .init(color: .black, location: 1),
                        .init(color: .clear, location: 1)
                    ]), startPoint: .top, endPoint: .bottom))
            }
        }
    }
    
    @State var searchText = ""
    @State var displayType = 0
    var body: some View {
        ZStack {
            Background(Shadow: true)
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ScrollViewHeader {
                        ZStack(alignment: .bottomLeading) {
                            header()
                        }
                    }.frame(height: 250)
                    VStack {
                        HStack {
                            Text(Repository.RepositoryName)
                                .padding(.top, -76)
                                .font(.system(size: 40, weight: .bold, design: .default))
                            Spacer()
                        }
                        HStack {
                            Text(Repository.RepositoryDescription)
                                .font(.system(size: 20, weight: .bold, design: .default))
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        ScrollView {
                            var sortedRepositoryContents: [RepositoryContentType] {
                                switch displayType {
                                case 0: // "a" の場合
                                    return Repository.RepositoryContents.sorted(by: { $0.Name < $1.Name })
                                case 1: // "z" の場合
                                    return Repository.RepositoryContents.sorted(by: { $0.Name > $1.Name })
                                case 2: // "c" の場合
                                    return Repository.RepositoryContents
                                default: // デフォルトは "a" の場合
                                    return Repository.RepositoryContents.sorted(by: { $0.Name < $1.Name })
                                }
                            }
                            ForEach(sortedRepositoryContents, id: \.self) { item in
                                Addon(RepositoryURL: RepositoryURL, Repository: Repository, RepositoryContent: item)
                            }
                        }
                        .searchable(text: $searchText,
                                    placement: .navigationBarDrawer(displayMode: .automatic))
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    .onAppear{
                        if let r = CacheServices.shared.CachedRepository.CachedRepositoryWithURL[RepositoryURL] {
                            Repository = r
                        }
                    }
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 8)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.interpolatingSpring(stiffness: 600, damping: 100)) {
                            displayType = (displayType + 1) % 3
                        }
                    } label: {
                        Image(systemName: displayType == 0 ? "a.square.fill" : (displayType == 1 ? "z.square.fill" : "d.square.fill"))
                    }
                }
            }
        }
    }
}


struct Addon: View {
    @ObservedObject var MemorySingleton = Memory.shared
    @State var RepositoryURL: String
    @State var Repository: RepositoryType = RepositoryType()
    @State var RepositoryContent: RepositoryContentType = RepositoryContentType()
    var body: some View {
        let Support = isVersionInRange(check: iOSVer, min: RepositoryContent.MinIOSVersion ?? "0", max: RepositoryContent.MaxIOSVersion ?? "100")
        let Build_Support = RepositoryContent.AdditionalSupportedIOS?.Build?.contains(ProductBuildVersion) ?? false
        let compatibleExploit = RepositoryContent.compatibleExploit != [String]() ? compatibleExploitCheck(compatibleExploits: RepositoryContent.compatibleExploit) : true
        let CompatibleOS = compatibleOSCheck(compatibleOSs: RepositoryContent.CompatibleOS)
        let AppSupport = isVersionInRange(check: appver.replacingOccurrences(of: " Beta", with: ""), min: RepositoryContent.MinAppVersion ?? "0", max: "100")
        
        NavigationLink {
            AddonPage(
                RepositoryURL: RepositoryURL,
                Repository: Repository,
                RepositoryContent: RepositoryContent
            )
        } label: {
            HStack {
                ImageLoader(RepositoryContent.Icon)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                    .cornerRadius(10)
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 2,
                        trailing: 5
                    ))
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
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
                                let result: (String, Color) = MemorySingleton.Queue.contains { $0.isEqualIgnoringVersion(Checker) } ?
                                    ("Queued", .red) :
                                    InstalledPackages().contains(RepositoryContent.PackageID) ?
                                    (!isVersionLessThan(check: InstalledPackageVersion(RepositoryContent.PackageID), min: RepositoryContent.Releases.last?.Version ?? "") ?
                                        ("Uninstall", .pink) :
                                        ("Update", .orange)) :
                                    (canGet ?
                                        ("GET", .blue) : misakaUpdate ?
                                        ("Misaka update required", .blue) : ("Not Supported", .blue))
                                
                                if result.0 == "Queued" {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .foregroundColor(Color.pink)
                                        .background(Color.black)
                                        .cornerRadius(50)
                                }else if result.0 == "Update" {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .foregroundColor(Color.orange)
                                        .background(Color.black)
                                        .cornerRadius(50)
                                }else if result.0 == "Get" {
                                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                        .foregroundColor(Color.blue)
                                        .background(Color.black)
                                        .cornerRadius(50)
                                }else if result.0 == "Uninstall" {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.green)
                                        .background(Color.black)
                                        .cornerRadius(50)
                                }
                            }
                        }
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(RepositoryContent.Name)
                        .font(.headline)
                    HStack {
                        Text(RepositoryContent.Author?.Label ?? Repository.Default.Author?.Label ?? "Unknown")
                        Text(String(RepositoryContent.Releases.last?.Version ?? "0.0"))
                    }
                    .font(.system(size: 13, design: .default))
                    .opacity(0.5)
                    Text(RepositoryContent.Description)
                        .font(.caption2)
                        .opacity(0.5)
                }
                .foregroundColor(.primary)
                Spacer()
            }
            .frame(height: 60)
            .padding(.vertical, 5)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
            let result: (String, Color) = MemorySingleton.Queue.contains { $0.isEqualIgnoringVersion(Checker) } ?
                ("Queued", .red) :
                InstalledPackages().contains(RepositoryContent.PackageID) ?
                (!isVersionLessThan(check: InstalledPackageVersion(RepositoryContent.PackageID), min: RepositoryContent.Releases.last?.Version ?? "") ?
                    ("Uninstall", .pink) :
                    ("Update", .orange)) :
                (canGet ?
                    ("GET", .blue) : misakaUpdate ?
                    ("Misaka update required", .blue) : ("Not Supported", .blue))
            Button {
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
                        var Uninstall = Checker
                        Uninstall.Mode = "Update"
                        MemorySingleton.Queue.append(Uninstall)
                    default: break
                    }
                    QueueCheck()
                }
            } label: {
                Text(MILocalizedString(result.0))
            }
            .tint(result.1)
        }
        .opacity(repositoryInstallEligibleForGet(
            supportOrBuild: Support || Build_Support,
            compatibleOS: CompatibleOS,
            compatibleExploit: compatibleExploit,
            appSupport: AppSupport
        ) ? 1 : 0.3)
    }
}
