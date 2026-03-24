//
//  Structs.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/09.
//

import Foundation

struct RepositoryType: Codable, Hashable {
    var RepositoryName: String
    var RepositoryDescription: String
    var RepositoryAuthor: String?
    var RepositoryIcon: String
    var RepositoryWebsite: String?
    var Default: DefaultType
    var RepositoryContents: [RepositoryContentType]
    init(
        RepositoryName: String = "Unknown Repository",
        RepositoryDescription: String = "",
        RepositoryIcon: String = "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoIcon.png",
        RepositoryContents: [RepositoryContentType] = [RepositoryContentType](),
        Default: DefaultType = DefaultType()
    ) {
        self.RepositoryName = RepositoryName
        self.RepositoryDescription = RepositoryDescription
        self.RepositoryIcon = RepositoryIcon
        self.RepositoryContents = RepositoryContents
        self.Default = Default
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.RepositoryName = try container.decodeIfPresent(String.self, forKey: .RepositoryName) ?? "RepositoryName"
        self.RepositoryDescription = try container.decodeIfPresent(String.self, forKey: .RepositoryDescription) ?? "RepositoryDescription"
        self.RepositoryIcon = try container.decodeIfPresent(String.self, forKey: .RepositoryIcon) ?? "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoIcon.png"
        self.RepositoryContents = try container.decodeIfPresent([RepositoryContentType].self, forKey: .RepositoryContents) ?? [RepositoryContentType]()
        self.Default = try container.decodeIfPresent(DefaultType.self, forKey: .Default) ?? DefaultType()
    }
}
struct RepositoryContentType: Codable, Hashable {
    var Name: String
    var Description: String
    var Author: AuthorType?
    var Icon: String
    var HeaderImage: String?
    var Category: String
    var Caption: String
    var Screenshot: [String]
    var compatibleExploit: [String]
    var CompatibleOS: [String]
    var MinIOSVersion: String?
    var MaxIOSVersion: String?
    var MinAppVersion: String?
    var AdditionalSupportedIOS: AdditionalSupportedIOSType?
    var ViewCount: Bool?
    var Releases: [ReleasesType]
    var PackageID: String
    var EmuVar: Bool
    var RepositoryURL: String
    var Depends: [RepositoryContentSimpleType]
    init(
        Name: String = "Name",
        Description: String = "",
        Author: AuthorType? = nil,
        Icon: String = "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoIcon.png",
        HeaderImage: String = "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoHeaderImage.png",
        Category: String = "No Category",
        Caption: String = "",
        Screenshot: [String] = [String](),
        compatibleExploit: [String] = [String](),
        CompatibleOS: [String] = [String](),
        Releases: [ReleasesType] = [ReleasesType](),
        PackageID: String = "PackageID",
        EmuVar: Bool = false,
        RepositoryURL: String = "RepositoryURL",
        Depends: [RepositoryContentSimpleType] = [RepositoryContentSimpleType]()
    ) {
        self.Name = Name
        self.Description = Description
        self.Author = Author
        self.Icon = Icon
        self.HeaderImage = HeaderImage
        self.Category = Category
        self.Caption = Caption
        self.Screenshot = Screenshot
        self.compatibleExploit = compatibleExploit
        self.CompatibleOS = CompatibleOS
        self.Releases = Releases
        self.PackageID = PackageID
        self.EmuVar = EmuVar
        self.RepositoryURL = RepositoryURL
        self.Depends = Depends
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.Name = try container.decodeIfPresent(String.self, forKey: .Name) ?? "Name"
        self.Description = try container.decodeIfPresent(String.self, forKey: .Description) ?? ""
        self.Icon = try container.decodeIfPresent(String.self, forKey: .Icon) ?? "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoIcon.png"
        self.HeaderImage = try container.decodeIfPresent(String.self, forKey: .HeaderImage)
        self.Category = try container.decodeIfPresent(String.self, forKey: .Category) ?? "No Category"
        self.Caption = try container.decodeIfPresent(String.self, forKey: .Caption) ?? ""
        self.Author = try container.decodeIfPresent(AuthorType.self, forKey: .Author) ?? nil
        self.Screenshot = try container.decodeIfPresent([String].self, forKey: .Screenshot) ?? [String]()
        self.compatibleExploit = try container.decodeIfPresent([String].self, forKey: .compatibleExploit) ?? [String]()
        self.CompatibleOS = try container.decodeIfPresent([String].self, forKey: .CompatibleOS) ?? ["iOS", "iPadOS"]
        self.MinAppVersion = try container.decodeIfPresent(String.self, forKey: .MinAppVersion)
        self.MinIOSVersion = try container.decodeIfPresent(String.self, forKey: .MinIOSVersion)
        self.MaxIOSVersion = try container.decodeIfPresent(String.self, forKey: .MaxIOSVersion)
        self.Releases = try container.decodeIfPresent([ReleasesType].self, forKey: .Releases) ?? [ReleasesType]()
        self.PackageID = try container.decodeIfPresent(String.self, forKey: .PackageID) ?? "PackageID"
        self.AdditionalSupportedIOS = try container.decodeIfPresent(AdditionalSupportedIOSType.self, forKey: .AdditionalSupportedIOS)
        self.ViewCount = try container.decodeIfPresent(Bool.self, forKey: .ViewCount)
        self.EmuVar = try container.decodeIfPresent(Bool.self, forKey: .EmuVar) ?? false
        self.RepositoryURL = try container.decodeIfPresent(String.self, forKey: .RepositoryURL) ?? "RepositoryURL"
        self.Depends = try container.decodeIfPresent([RepositoryContentSimpleType].self, forKey: .Depends) ?? [RepositoryContentSimpleType]()
    }
}

struct AuthorType: Codable, Hashable {
    var Label: String
    var Links: [AuthorLinkType]
    init(
        Label: String = "Label",
        Links: [AuthorLinkType] = [AuthorLinkType]()
    ) {
        self.Label = Label
        self.Links = Links
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.Label = try container.decodeIfPresent(String.self, forKey: .Label) ?? "Label"
        self.Links = try container.decodeIfPresent([AuthorLinkType].self, forKey: .Links) ?? [AuthorLinkType]()
    }
}
struct AuthorLinkType: Codable, Hashable {
    var Label: String?
    var Link: String?
}
struct ReleasesType: Codable, Hashable {
    var Version: String
    var Package: String?
    var Description: String?
    init(Version: String = "0.0", Package: String? = nil, Description: String? = nil) {
        self.Version = Version
        self.Package = Package
        self.Description = Description
    }
}
struct DefaultType: Codable, Hashable {
    var Author: AuthorType?
    var HeaderImage: String?
    var ViewCount: Bool?
    init(
        Author: AuthorType? = nil,
        HeaderImage: [AuthorLinkType] = [AuthorLinkType](),
        ViewCount: Bool = false
    ) {
        self.Author = Author
        self.HeaderImage = "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoHeaderImage.png"
        self.ViewCount = ViewCount
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.Author = try container.decodeIfPresent(AuthorType.self, forKey: .Author) ?? nil
        self.HeaderImage = try container.decodeIfPresent(String.self, forKey: .HeaderImage) ?? "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoHeaderImage.png"
        self.ViewCount = try container.decodeIfPresent(Bool.self, forKey: .ViewCount) ?? false
    }
}
struct AdditionalSupportedIOSType: Codable, Hashable {
    var MinIOSVersion_CustomLabel: String?
    var MaxIOSVersion_CustomLabel: String?
    var Build: [String]?
}


struct RepositoryContentSimpleType: Codable, Hashable {
    var RepositoryURL: String
    var PackageID: String
    init(
        RepositoryURL: String = "RepositoryURL",
        PackageID: String = "PackageID"
    ) {
        self.RepositoryURL = RepositoryURL
        self.PackageID = PackageID
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.RepositoryURL = try container.decodeIfPresent(String.self, forKey: .RepositoryURL) ?? "RepositoryURL"
        self.PackageID = try container.decodeIfPresent(String.self, forKey: .PackageID) ?? "PackageID"
    }
}
struct RepositoryContentPackType: Codable, Hashable {
    var RepositoryURL: String
    var Repository: RepositoryType
    var RepositoryContent: RepositoryContentType
    init(RepositoryURL: String = "RepositoryURL", Repository: RepositoryType = RepositoryType(), RepositoryContent: RepositoryContentType = RepositoryContentType()) {
        self.RepositoryURL = RepositoryURL
        self.Repository = Repository
        self.RepositoryContent = RepositoryContent
    }
}

struct QueueType: Hashable {
    var Mode: String
    var Releases: ReleasesType
    var RepositoryContentPack: RepositoryContentPackType
    var Extra: String?
    var DLProgress: DLProgressType

    init(Mode: String = "",
         Releases: ReleasesType = ReleasesType(),
         RepositoryContentPack: RepositoryContentPackType = RepositoryContentPackType(),
         Extra: String = "",
         DLProgress: DLProgressType = DLProgressType()
    ) {
        self.Mode = Mode
        self.Releases = Releases
        self.RepositoryContentPack = RepositoryContentPack
        self.Extra = Extra
        self.DLProgress = DLProgressType()
    }
    
    static func == (lhs: QueueType, rhs: QueueType) -> Bool {
        return (lhs.RepositoryContentPack.RepositoryContent.PackageID == rhs.RepositoryContentPack.RepositoryContent.PackageID) &&
            (lhs.Releases.Version == rhs.Releases.Version)
    }

    func isEqualIgnoringVersion(_ other: QueueType) -> Bool {
        return self.RepositoryContentPack.RepositoryContent.PackageID == other.RepositoryContentPack.RepositoryContent.PackageID
    }
}

struct DLProgressType: Hashable {
    var ProcessEnd: Bool
    var Message: String
    var Progress: CGFloat
    var dataTask: URLSessionDataTask?
    var observation: NSKeyValueObservation?
    init() {
        self.ProcessEnd = false
        self.Message = "Queued"
        self.Progress = 0.0
    }
}

struct DefaultRepositoriesType: Codable, Hashable {
    var Section: String
    var Repositories: [String]
    init() {
        self.Section = "Section"
        self.Repositories = [String]()
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.Section = try container.decodeIfPresent(String.self, forKey: .Section) ?? "Section"
        self.Repositories = try container.decodeIfPresent([String].self, forKey: .Repositories) ?? [String]()
    }
}




// pi
struct RepositoryType_PI: Codable, Hashable {
    var name: String
    var description: String
    var icon: String
    var packages: [RepositoryContentType_PI]
    init() {
        self.name = "RepositoryName"
        self.description = "RepositoryDescription"
        self.icon = "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoIcon.png"
        self.packages = [RepositoryContentType_PI]()
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "RepositoryName"
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? "RepositoryDescription"
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoIcon.png"
        self.packages = try container.decodeIfPresent([RepositoryContentType_PI].self, forKey: .packages) ?? [RepositoryContentType_PI]()
    }
}
struct RepositoryContentType_PI: Codable, Hashable {
    var name: String
    var bundleid: String
    var author: String
    var description: String
    var long_description: String
    var version: String
    var icon: String
    var path: String
    var banner: String
    var screenshots: [String]
    var accent: String
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Name"
        self.bundleid = try container.decodeIfPresent(String.self, forKey: .bundleid) ?? "PackageID"
        self.author = try container.decodeIfPresent(String.self, forKey: .author) ?? "Author"
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.long_description = try container.decodeIfPresent(String.self, forKey: .long_description) ?? ""
        self.version = try container.decodeIfPresent(String.self, forKey: .version) ?? "Version"
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoIcon.png"
        self.path = try container.decodeIfPresent(String.self, forKey: .path) ?? "Package"
        self.banner = try container.decodeIfPresent(String.self, forKey: .banner) ?? "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Assets/NoHeaderImage.png"
        self.screenshots = try container.decodeIfPresent([String].self, forKey: .screenshots) ?? [String]()
        self.accent = try container.decodeIfPresent(String.self, forKey: .accent) ?? "Accent"
    }
}
