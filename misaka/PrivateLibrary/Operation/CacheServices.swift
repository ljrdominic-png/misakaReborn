//
//  CacheServices.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/11.
//

import Foundation
import UIKit

class CacheServices: UIResponder, UIApplicationDelegate, ObservableObject {
    static var shared = CacheServices()
    @Published var CachedRepository: CachedRepositoryType = CachedRepositoryType()
    
    func BuildRepositoryCache() {
        self.CachedRepository.CachedRepositoryWithURL = [String: RepositoryType]()
        self.CachedRepository.CachedRepositoryContent = [RepositoryContentType]()
        self.CachedRepository.CachedRepositoryContentWithCategory = [String: [RepositoryContentPackType]]()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var Initialized_Category: [String: String] = [String: String]()
            let semaphore = DispatchSemaphore(value: 0)
            Requests(RequestsType(Method: "Get", URL: "https://raw.githubusercontent.com/shimajiron/Misaka_Network/main/Server/Category.json")) { data in
                do {
                    Initialized_Category = try JSONSerialization.jsonObject(with: data ?? Data(), options: .mutableContainers) as! [String: String]
                }catch{}
                semaphore.signal()
            }
            semaphore.wait()
            for url in Memory.shared.RepositoriesURL {
                RepositoryRequest(url: url) { result in
                    switch result {
                    case .success(let Repository):
                        DispatchQueue.main.async {
                            self.CachedRepository.CachedRepositoryWithURL[url] = Repository
                            self.CachedRepository.CachedRepositoryContent += Repository.RepositoryContents
                            for item in Repository.RepositoryContents {
                                var copyitem = item
                                copyitem.Category = Initialized_Category[copyitem.Category] ?? copyitem.Category
                                let categoryKey = "\(copyitem.Category)"
                                if var categoryContentArray = self.CachedRepository.CachedRepositoryContentWithCategory[categoryKey] {
                                    categoryContentArray.append(
                                        RepositoryContentPackType(RepositoryURL: url, Repository: Repository, RepositoryContent: copyitem)
                                    )
                                    self.CachedRepository.CachedRepositoryContentWithCategory[categoryKey] = categoryContentArray
                                } else {
                                    self.CachedRepository.CachedRepositoryContentWithCategory[categoryKey] = [
                                        RepositoryContentPackType(RepositoryURL: url, Repository: Repository, RepositoryContent: copyitem)
                                    ]
                                }
                            }
                        }
                    case .failure(let error):
                        print("エラー: \(error)")
                    }
                }
            }
        }
    }
}

struct CachedRepositoryType: Codable, Hashable, Identifiable {
    var id = UUID()
    var CachedRepositoryContent:  [RepositoryContentType]
    var CachedRepositoryWithURL: [String: RepositoryType]
    var CachedRepositoryContentWithCategory: [String: [RepositoryContentPackType]]
    init() {
        self.CachedRepositoryContent = [RepositoryContentType]()
        self.CachedRepositoryWithURL = [String: RepositoryType]()
        self.CachedRepositoryContentWithCategory = [String: [RepositoryContentPackType]]()
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.CachedRepositoryContent = try container.decodeIfPresent([RepositoryContentType].self, forKey: .CachedRepositoryContent) ?? [RepositoryContentType]()
        self.CachedRepositoryWithURL = try container.decodeIfPresent([String: RepositoryType].self, forKey: .CachedRepositoryWithURL) ?? [String: RepositoryType]()
        self.CachedRepositoryContentWithCategory = try container.decodeIfPresent([String: [RepositoryContentPackType]].self, forKey: .CachedRepositoryContentWithCategory) ?? [String: [RepositoryContentPackType]]()
    }
}


func RepositoryRequest(url: String, completion: @escaping (Result<RepositoryType, Error>) -> Void) {
    Requests(RequestsType(Method: "Get", URL: url)) { data in
        if let data = data {
            do {
                let decoder = JSONDecoder()
                decoder.allowsJSON5 = true
                let Repository = try decoder.decode(RepositoryType.self, from: data)
                if Repository.RepositoryName != "RepositoryName" {
                    completion(.success(Repository))
                } else {
                    Requests(RequestsType(Method: "Post", URL: "http://shimajiron.php.xdomain.jp/misaka/repo.php", Data: data, Headers: ["repo": url])) { data2 in
                        if let data2 = data2 {
                            do {
                                let decoder = JSONDecoder()
                                decoder.allowsJSON5 = true
                                let Repository = try decoder.decode(RepositoryType.self, from: data2)
                                completion(.success(Repository))
                            }catch{}
                        }
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

func removeAfterLastSlash(_ inputString: String) -> String {
    if let lastIndex = inputString.lastIndex(of: "/") {
        let truncatedString = inputString[..<lastIndex]
        return String(truncatedString)
    } else {
        return inputString
    }
}
