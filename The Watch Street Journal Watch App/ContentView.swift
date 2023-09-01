//
//  ContentView.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 18/6/23.
//

import SwiftUI
import AuthenticationServices
import Kingfisher

struct ContentView: View {
    @StateObject private var model = GoogleNewsModel()
    
    @State private var search_text = ""
    let scalpel = Scraper()
    
    var body: some View {
        NavigationView {
            VStack {
                if model.news.count > 0 {
                    List {
                        ForEach(model.news) { new in
                            NewsCell(new: new)
                        }
                    }
                    .listStyle(.carousel)
                    .searchable(text: $search_text, placement: .navigationBarDrawer, prompt: Text("Search News"))
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)

                    Text("Loading up for you the \(model.selected_topic.rawValue) news...")
                }
            }
            .navigationTitle(Text("\(model.selected_topic.rawValue.capitalized)"))
            .toolbar {
                ToolbarItemGroup(placement: .confirmationAction) {
                    NavigationLink {
                        SettingsView(model: model)
                    } label: {
                        Label("Settings", systemImage: "gear.circle")
                    }
                }

                ToolbarItemGroup(placement: .primaryAction) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 5) {
                            ForEach(GoogleNewsModel.Topic.allCases) { topic in
                                Button(topic.rawValue.capitalized) {
                                    if search_text.isEmpty {
                                        model.selected_topic = topic
                                    } else {
                                        search_text = ""
                                        model.changeTopic()
                                    }
                                }
                                    .underline(topic == model.selected_topic)
                            }
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
        .onChange(of: model.selected_topic) { _ in
            search_text = ""
            model.changeTopic()
        }
        .onChange(of: search_text) { v in
            if v.isEmpty { return }
            model.searchNews(text: v)
        }
    }
}

struct NewsCell: View {
    let new: GoogleNews
    
    @State private var news_url: URL?
    @State private var news_img_url: URL?
    @State private var show: Bool = false
    
    let scalpel = Scraper()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    if let news_img_url = news_img_url {
                        KFImage(news_img_url)
                            .placeholder { progress in
                                ProgressView(value: progress.fractionCompleted)
                                    .progressViewStyle(.circular)
                            }
                            .loadDiskFileSynchronously()
                            .cacheOriginalImage()
                    }
                    
                    Text(new.source.source)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Text(new.source.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("Published \(Date() - new.publish_date) Ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.light)
                    .italic()
            }
            .onTapGesture {
                Task(priority: .high) {
                    guard let news_url = news_url else { return }
                    
                    let session = ASWebAuthenticationSession(url: news_url, callbackURLScheme: nil) { _, _ in }
                    session.prefersEphemeralWebBrowserSession = true
                    session.start()
                }
            }
        }
        .onAppear {
            Task(priority: .background) {
                do {
                    let news_url = try await scalpel.getNewsLinkFromGoogleRedirect(new.source.source_url)
                    self.news_url = news_url
                    
                    if let host = news_url.host,
                       let img_url = URL(string: "https://www.google.com/s2/favicons?sz=512&domain=\(host)") {
                        news_img_url = img_url
                    }
                } catch {
                    debugPrint(error)
                }
            }
        }
    }
}
