//
//  CategoryPage.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/12.
//

import Foundation
import SwiftUI
import ScrollKit

struct Categorys: View {
    @State var Category: String
    var body: some View {
        List {
            ForEach(CacheServices.shared.CachedRepository.CachedRepositoryContentWithCategory[Category]?.sorted(by: { $0.RepositoryContent.Name < $1.RepositoryContent.Name }) ?? [RepositoryContentPackType](), id: \.self) { item in
                Addon(RepositoryURL: item.RepositoryURL, Repository: item.Repository, RepositoryContent: item.RepositoryContent)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(Category)
    }
}
