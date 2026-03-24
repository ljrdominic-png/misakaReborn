//
//  FN.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/19.
//

import Foundation
import SwiftUI

struct FN_ContentView: View {
    @State var RepositoryContentSimple: RepositoryContentSimpleType = RepositoryContentSimpleType()
    @State var RepositoryContentPack: RepositoryContentPackType?
    @State var DisplayType: String
    var body: some View {
        if DisplayType == "Header" {
            if let RepositoryContentPack = RepositoryContentPack {
                NavigationLink {
                    AddonPage(
                        RepositoryURL: RepositoryContentPack.RepositoryURL,
                        Repository: RepositoryContentPack.Repository,
                        RepositoryContent: RepositoryContentPack.RepositoryContent
                    )
                } label: {
                    ZStack {
                        ImageLoader(RepositoryContentPack.RepositoryContent.Icon)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 270, height: 170)
                            .cornerRadius(15)
                        VStack {
                            Spacer()
                            ZStack {
                                Color.black
                                HStack(alignment: .bottom) {
                                    VStack {
                                        Spacer()
                                        Text(RepositoryContentPack.RepositoryContent.Name)
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .bold, design: .default))
                                            .padding(.bottom, 9)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                            }
                            .frame(height: 45)
                            .mask(LinearGradient(gradient: Gradient(stops: [
                                .init(color: .black.opacity(0.7), location: 0),
                                .init(color: .clear, location: 1)
                            ]), startPoint: .bottom, endPoint: .top))
                        }
                        .cornerRadius(15)
                    }
                }
                .cornerRadius(15)
                .padding(.trailing, 5)
            }else{
                ImageLoader("")
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 270, height: 170)
                    .cornerRadius(15)
                    .padding(.trailing, 5)
                    .redacted(reason: .placeholder)
                    .task {
                        RepositoryContentSimpleTypeDirectOpen(RepositoryContentSimple) { repositoryContentPack in
                            if let repositoryContentPack = repositoryContentPack {
                                RepositoryContentPack = repositoryContentPack
                            } else {
                                DisplayType = ""
                            }
                        }
                    }
                    .cornerRadius(15)
                    .padding(.trailing, 5)
            }
        }else if DisplayType == "Popular" {
            if let RepositoryContentPack = RepositoryContentPack {
                NavigationLink {
                    AddonPage(
                        RepositoryURL: RepositoryContentPack.RepositoryURL,
                        Repository: RepositoryContentPack.Repository,
                        RepositoryContent: RepositoryContentPack.RepositoryContent
                    )
                } label: {
                    HStack {
                        ImageLoader(RepositoryContentPack.RepositoryContent.Icon)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .cornerRadius(15)
                            .padding(EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: 2,
                                trailing: 15
                            ))
                        VStack(alignment: .leading) {
                            Text(RepositoryContentPack.RepositoryContent.Name)
                                .bold()
                                .font(Font.system(size: 20))
                                .foregroundColor(.primary)
                            Text(RepositoryContentPack.RepositoryContent.Description)
                                .font(Font.system(size: 15))
                                .opacity(0.7)
                                .foregroundColor(.primary)
                            Spacer()
                            HStack{
                                Spacer()
                                Text(RepositoryContentPack.RepositoryContent.Author?.Label ?? RepositoryContentPack.Repository.Default.Author?.Label ?? "Unknown")
                                    .font(Font.system(size: 15))
                                    .opacity(0.7)
                                    .foregroundColor(.primary)
                            }
                        }
                        .frame(height: 60)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .opacity(0.3)
                }
            }else{
                HStack {
                    ImageLoader("")
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .cornerRadius(15)
                        .padding(EdgeInsets(
                            top: 0,
                            leading: 0,
                            bottom: 2,
                            trailing: 15
                        ))
                    VStack(alignment: .leading) {
                        Text("Name")
                            .bold()
                            .font(Font.system(size: 20))
                        Text("Description")
                            .font(Font.system(size: 15))
                            .opacity(0.7)
                        Spacer()
                        HStack{
                            Spacer()
                            Text("Label")
                                .font(Font.system(size: 15))
                                .opacity(0.7)
                        }
                    }
                    .frame(height: 60)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .opacity(0.3)
                }
                .redacted(reason: .placeholder)
                .task {
                    RepositoryContentSimpleTypeDirectOpen(RepositoryContentSimple) { repositoryContentPack in
                        if let repositoryContentPack = repositoryContentPack {
                            RepositoryContentPack = repositoryContentPack
                        } else {
                            DisplayType = ""
                        }
                    }
                }
            }
        }
    }
}
let semaphoreRepo = DispatchSemaphore(value: 1)
var RepoCache: [String: [String: RepositoryContentPackType]] = [:]
func RepositoryContentSimpleTypeDirectOpen(_ RepositoryContentSimple: RepositoryContentSimpleType, completion: @escaping (RepositoryContentPackType?) -> Void) {
    semaphoreRepo.wait()
    defer {
        semaphoreRepo.signal()
    }
    if RepoCache.keys.contains(RepositoryContentSimple.RepositoryURL) {
        completion(RepoCache[RepositoryContentSimple.RepositoryURL]?[RepositoryContentSimple.PackageID])
        return
    }
    RepositoryRequest(url: RepositoryContentSimple.RepositoryURL) { result in
        switch result {
        case .success(let Repository):
            if let RepositoryContent = Repository.RepositoryContents.first(where: { $0.PackageID == RepositoryContentSimple.PackageID }) {
                let repositoryContentPack = RepositoryContentPackType(
                    RepositoryURL: RepositoryContentSimple.RepositoryURL,
                    Repository: Repository,
                    RepositoryContent: RepositoryContent
                )
                RepoCache[RepositoryContentSimple.RepositoryURL]?[RepositoryContentSimple.PackageID] = repositoryContentPack
                completion(repositoryContentPack)
            } else {
                completion(nil)
            }
        case .failure(let error):
            print("エラー: \(error)")
        }
    }
}
