//
//  Sources.swift
//  misaka
//
//  Created by straight-tamago☆ on 2023/09/09.
//

import SwiftUI
import AdvancedList
import ProgressIndicatorView
import AlertToast
import MediaPlayer

struct AddonSearch: View {
    @ObservedObject var CacheServicesSingleton = CacheServices.shared
    @State var searchText = ""
    @State var filterAddons: [RepositoryContentPackType] = [RepositoryContentPackType]()
    var body: some View {
        List {
            ForEach(filterAddons, id: \.self) { item in
                Addon(RepositoryURL: item.RepositoryURL, Repository: item.Repository, RepositoryContent: item.RepositoryContent)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Search")
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: MILocalizedString("Search")
        )
        .onChange(of: searchText) { newValue in
            Load()
        }.onAppear {
            Load()
        }
    }
    
    func Load() {
        DispatchQueue.global().async {
            withAnimation(.linear(duration: 1)) {
                let searchText = searchText.lowercased()
                if searchText.count >= 2 {
                    filterAddons = Array(CacheServicesSingleton.CachedRepository.CachedRepositoryContentWithCategory.keys)
                        .sorted()
                        .flatMap { key in
                            CacheServices.shared.CachedRepository.CachedRepositoryContentWithCategory[key]?.sorted(by: { $0.RepositoryContent.Name < $1.RepositoryContent.Name }) ?? [RepositoryContentPackType]()
                        }
                        .filter { item in
                            if !searchText.isEmpty {
                                let name = (item.RepositoryContent.Name).lowercased()
                                let description = (item.RepositoryContent.Description).lowercased()
                                let caption = (item.RepositoryContent.Caption).lowercased()
                                if !(name.contains(searchText) || description.contains(searchText) || caption.contains(searchText)) {
                                    return false
                                }
                            }
                            return true
                        }
                        .sorted(by: { $0.RepositoryContent.Name < $1.RepositoryContent.Name })
                }else{
                    filterAddons = Array(CacheServicesSingleton.CachedRepository.CachedRepositoryContentWithCategory.keys)
                        .sorted()
                        .flatMap { key in
                            CacheServices.shared.CachedRepository.CachedRepositoryContentWithCategory[key]?.sorted(by: { $0.RepositoryContent.Name < $1.RepositoryContent.Name }) ?? [RepositoryContentPackType]()
                        }
                        .filter { item in
                            if !searchText.isEmpty {
                                let name = (item.RepositoryContent.Name).lowercased()
                                let description = (item.RepositoryContent.Description).lowercased()
                                let caption = (item.RepositoryContent.Caption).lowercased()
                                if !(name.contains(searchText) || description.contains(searchText) || caption.contains(searchText)) {
                                    return false
                                }
                            }
                            return true
                        }
                        .sorted(by: { $0.RepositoryContent.Name < $1.RepositoryContent.Name })
                        .prefix(30).map { $0 }
                }
            }
        }
    }
}

struct AddonCategory: View {
    @ObservedObject var CacheServicesSingleton = CacheServices.shared
    var body: some View {
        List {
            ForEach(Array(CacheServicesSingleton.CachedRepository.CachedRepositoryContentWithCategory.keys).sorted(), id: \.self) { key in
                NavigationLink {
                    Categorys(Category: key)
                } label: {
                    Text(key)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Category")
        .listRowSeparator(.hidden)
    }
}

struct Sources: View {
    @State private var initialized = false
    @ObservedObject var MemorySingleton = Memory.shared
    @ObservedObject var CacheServicesSingleton = CacheServices.shared
    var body: some View {
        ZStack {
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
            List {
                NavigationLink {
                    AddonSearch()
                } label: {
                    Text(MILocalizedString("Search"))
                        .font(.headline)
                }
                .listRowBackground(Color.clear)
                NavigationLink {
                    AddonCategory()
                } label: {
                    Text(MILocalizedString("Category"))
                        .font(.headline)
                }
                .listRowBackground(Color.clear)
                ForEach(Memory.shared.RepositoriesURL, id: \.self) { url in
                    SourcesButton(
                        RepositoryURL: url,
                        Repository: CacheServices.shared.CachedRepository.CachedRepositoryWithURL[url] ?? RepositoryType()
                    )
                }
                .onDelete(perform: rowRemove)
                .listRowBackground(Color.clear)
            }
            .listStyle(PlainListStyle())
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 8)
            .refreshable {
                await Task.sleep(1000000)
                CacheServices.shared.BuildRepositoryCache()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        if let clipboardString = UIPasteboard.general.string {
                            MemorySingleton.RepositoriesURL.removeAll(where: {$0 == clipboardString})
                            MemorySingleton.RepositoriesURL.append(clipboardString)
                            CacheServices.shared.BuildRepositoryCache()
                            ToastController.shared.Toast_bannerSlide = AlertToast(displayMode: .banner(.slide), type: .regular, title: "Added Source")
                            ToastController.shared.Show_bannerSlide = true
                        }else{
                            ToastController.shared.Toast_bannerSlide = AlertToast(displayMode: .banner(.slide), type: .regular, title: "Clipboard is empty")
                            ToastController.shared.Show_bannerSlide = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink(
                        destination: DefaultSources(),
                        label: {
                            Image(systemName: "list.dash.header.rectangle")
                        }
                    )
                }
            }
            .onAppear {
                defer { initialized = true }
                guard initialized == false else { return }
                CacheServices.shared.BuildRepositoryCache()
            }
        }
    }
    func rowRemove(offsets: IndexSet) {
        MemorySingleton.RepositoriesURL.remove(atOffsets: offsets)
    }
}

struct DefaultSources: View {
    @State private var listState: ListState = .loading
    @State private var DefaultRepositories: [DefaultRepositoriesType] = [DefaultRepositoriesType]()
    @StateObject var memory = Memory.shared
    var body: some View {
        ZStack {
            Background(Shadow: true).opacity(0.4)
            AdvancedList(listState: listState, content: {
                List {
                    AnimatedNavigationTitle(title: "Default Sources")
                    ForEach(DefaultRepositories, id: \.self) { data in
                        Section(header: Text(MILocalizedString(data.Section))) {
                            ForEach(data.Repositories, id: \.self) { item in
                                if #available(iOS 15.0, *) {
                                    SourcesButton(RepositoryURL: item)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(MILocalizedString("Add to Sources")){
                                                memory.RepositoriesURL.removeAll(where: {$0 == item})
                                                memory.RepositoriesURL.append(item)
                                                CacheServices.shared.BuildRepositoryCache()
                                                ToastController.shared.Toast_bannerSlide = AlertToast(displayMode: .banner(.slide), type: .regular, title: "Added Source")
                                                ToastController.shared.Show_bannerSlide = true
                                            }
                                            .tint(.blue)
                                        }
                                        .contextMenu {
                                            Button {
                                                memory.RepositoriesURL.removeAll(where: {$0 == item})
                                                memory.RepositoriesURL.append(item)
                                                CacheServices.shared.BuildRepositoryCache()
                                                ToastController.shared.Toast_bannerSlide = AlertToast(displayMode: .banner(.slide), type: .regular, title: "Added Source")
                                                ToastController.shared.Show_bannerSlide = true
                                            } label: {
                                                Label(MILocalizedString("Add to Sources"), systemImage: "heart")
                                            }
                                        }
                                } else {
                                    SourcesButton(RepositoryURL: item)
                                        .contextMenu {
                                            Button {
                                                memory.RepositoriesURL.removeAll(where: {$0 == item})
                                                memory.RepositoriesURL.append(item)
                                                CacheServices.shared.BuildRepositoryCache()
                                                ToastController.shared.Toast_bannerSlide = AlertToast(displayMode: .banner(.slide), type: .regular, title: "Added Source")
                                                ToastController.shared.Show_bannerSlide = true
                                            } label: {
                                                Label(MILocalizedString("Add to Sources"), systemImage: "heart")
                                            }
                                        }
                                }
                            }
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 8)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
            }, errorStateView: { error in
                VStack(alignment: .leading) {
                    Text("Error").foregroundColor(.primary)
                    Text(error.localizedDescription).foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            }, loadingStateView: {
                VStack {
                    ProgressView()
                }
                .frame(maxHeight: .infinity)
                .task {
                    Requests(RequestsType(Method: "Get", URL: "https://github.com/shimajiron/Misaka_Network/raw/main/Server/DefaultRepositoriesDS.json")) { data in
                        do {
                            if let data = data {
                                let decoder = JSONDecoder()
                                decoder.allowsJSON5 = true
                                DefaultRepositories = try decoder.decode([DefaultRepositoriesType].self, from: data)
                                listState = .items
                            }
                        }catch{}
                    }
                }
            })
        }
    }
}

struct SourcesButton: View {
    @State var RepositoryURL: String
    @State var Repository: RepositoryType = RepositoryType()
    @State private var progress: CGFloat = 0
    @State private var progress0_1: CGFloat = 0.1
    @State private var showProgressIndicator: Bool = true
    @State private var initialized = false
    var body: some View {
        VStack {
            NavigationLink(
                destination: Addons(RepositoryURL: RepositoryURL, Repository: Repository),
                label: {
                    VStack {
                        if showProgressIndicator {
                            Rectangle()
                                .frame(height: 1.0)
                                .foregroundColor(.clear)
                        }
                        HStack {
                            ImageLoader(Repository.RepositoryIcon)
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 42)
                                .cornerRadius(10)
                                .padding(EdgeInsets(
                                    top: 0,
                                    leading: 0,
                                    bottom: 0,
                                    trailing: 5
                                ))
                            VStack(alignment: .leading) {
                                Text(Repository.RepositoryName)
                                    .font(.headline)
                                Text(Repository.RepositoryDescription)
                                    .font(.subheadline)
                                    .opacity(0.5)
                            }
                            Spacer()
                            Text(String(Repository.RepositoryContents.count))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        if self.progress == 0.1 {
                            ProgressIndicatorView(isVisible: $showProgressIndicator, type: .impulseBar(progress: $progress0_1, backgroundColor: .gray.opacity(0.25)))
                                .frame(height: 1.0)
                                .foregroundColor(.blue)
                        }else {
                            ProgressIndicatorView(isVisible: $showProgressIndicator, type: .impulseBar(progress: $progress, backgroundColor: .gray.opacity(0.25)))
                                .frame(height: 1.0)
                                .foregroundColor(.blue)
                        }
                    }
                }
            )
            .frame(height: 55)
            .task {
                defer { initialized = true }
                guard initialized == false else { return }
                showProgressIndicator = true
                self.progress = 0.1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    RepositoryRequest(url: RepositoryURL) { result in
                        switch result {
                        case .success(let Repository):
                            self.Repository = Repository
                            withAnimation(.linear(duration: 0.1)) {
                                self.progress = 1
                            }
                            withAnimation(.linear(duration: 1)) {
                                showProgressIndicator = false
                            }
                        case .failure(let error):
                            print("エラー: \(error)")
                        }
                    }
                }
            }
        }
        .frame(height: 55)
        .contextMenu {
            Button(MILocalizedString("Copy URL")){
                UIPasteboard.general.string = RepositoryURL
            }
        }
    }
}

