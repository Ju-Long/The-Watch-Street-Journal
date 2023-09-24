//
//  GoogleNewsModel.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 24/6/23.
//

import Foundation
import Fuzi

class GoogleNewsModel: ObservableObject {
    //    HEADLINES_RSS = 'https://news.google.com/news/rss';
    //    TOPICS_RSS    = 'https://news.google.com/news/rss/headlines/section/topic/';
    //    GEO_RSS       = 'https://news.google.com/news/rss/headlines/section/geo/';
    //    SEARCH_RSS    = 'https://news.google.com/rss/search?q=';
    
    @Published var news: [GoogleNews] = []
    @Published var selected_topic: Topic = .latest
    @Published var error: String = ""
    
    private let scraper = Scraper()
    private let defaults = UserDefaults(suiteName: "group.com.BaBaSaMa.The-Watch-Street-Journal") ?? UserDefaults.standard
    private let file_manager = CustomFileManager()
    
    // MARK: - init
    init() {
        guard let google_news_url = URL(string: "https://news.google.com/rss?\(fillCountryLangParams())") else {
            error = "invalid google url, https://news.google.com/rss?\(fillCountryLangParams())"
            debugPrint(#file, #line)
            debugPrint(error)
            return
        }
        let filename = "\(self.selected_topic.rawValue)-news.txt"
        
        Task(priority: .high) {
            do {
                let retrieved_news = try await scraper.fetchNewsFromGoogle(url: google_news_url)
                
                if file_manager.fileExist(filename) {
                    let file_content = try file_manager.readFile(filename)
                    let stored_news = try scraper.fetchNewsFromXML(value: file_content)
                    
                    await MainActor.run {
                        self.news = stored_news
                    }
                    
                    let retrieved_xml = try XMLDocument(string: retrieved_news)
                    let stored_xml = try XMLDocument(string: file_content)
                    
                    if let retrieved_date = retrieved_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
                       let stored_date = stored_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
                       stored_date != retrieved_date {
                        
                        try file_manager.writeToFile(retrieved_news, filename)
                        let news = try scraper.fetchNewsFromXML(value: retrieved_news)
                        await MainActor.run {
                            self.news = news
                        }
                    }
                    return
                }
                
                let news = try scraper.fetchNewsFromXML(value: retrieved_news)
                await MainActor.run {
                    self.news = news
                }
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private func fillCountryLangParams(_ country: Country? = nil) -> String {
        if let country = country {
            return "hl=\(country.language_code.lowercased())-\(country.code.uppercased())&gl=\(country.code.uppercased())&ceid=\(country.code.uppercased()):\(country.language_code.lowercased())"
        }
        
        var locale = Locale.current
        if let language = defaults.string(forKey: "language"),
           let region = defaults.string(forKey: "region") {
            let components = Locale.Components(languageCode: Locale.LanguageCode(language), languageRegion: Locale.Region(region))
            locale = Locale(components: components)
        }
        
        guard let region = locale.region,
              region.isISORegion,
              let language_code = locale.language.languageCode?.identifier else {
            return ""
        }
        
        return "hl=\(language_code)-\(region.identifier)&gl=\(region.identifier)&ceid=\(region.identifier):\(language_code)"
    }
    
    // MARK: - Change topic of news
    public func changeTopic() {
        news.removeAll()
        let filename = "\(self.selected_topic.rawValue)-news.txt"
        
        Task(priority: .high) {
            guard var google_news_url = URL(string: "https://news.google.com/news/rss/headlines/section/topic/\(self.selected_topic.rawValue.uppercased())?\(fillCountryLangParams())") else {
                error = "invalid google url, https://news.google.com/news/rss/headlines/section/topic/\(self.selected_topic.rawValue.uppercased())?\(fillCountryLangParams())"
                debugPrint(#file, #line)
                debugPrint(error)
                return
            }
            do {
                if selected_topic == .latest {
                    google_news_url = URL(string: "https://news.google.com/rss?\(fillCountryLangParams())")!
                }
                
                let retrieved_news = try await scraper.fetchNewsFromGoogle(url: google_news_url)
                if file_manager.fileExist(filename) {
                    let file_content = try file_manager.readFile(filename)
                    let stored_news = try scraper.fetchNewsFromXML(value: file_content)
                    
                    await MainActor.run {
                        self.news = stored_news
                    }
                    
                    let retrieved_xml = try XMLDocument(string: retrieved_news)
                    let stored_xml = try XMLDocument(string: file_content)
                    
                    if let retrieved_date = retrieved_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
                       let stored_date = stored_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
                       stored_date != retrieved_date {
                        
                        try file_manager.writeToFile(retrieved_news, filename)
                        let news = try scraper.fetchNewsFromXML(value: retrieved_news)
                        await MainActor.run {
                            self.news = news
                        }
                    }
                    return
                }
                
                let news = try scraper.fetchNewsFromXML(value: retrieved_news)
                await MainActor.run {
                    self.news = news
                }
            } catch {
                debugPrint(error)
            }
        }
    }
    
    // MARK: - Change country of news
    public func changeCountry(_ country: Country) {
        news.removeAll()
        guard let google_news_url = URL(string: "https://news.google.com/rss?\(fillCountryLangParams(country))") else {
            error = "invalid google url, https://news.google.com/rss?\(fillCountryLangParams(country))"
            debugPrint(#file, #line)
            debugPrint(error)
            return
        }
        let filename = "\(country.code)-news.txt"
        
        Task(priority: .high) {
            do {
                let retrieved_news = try await scraper.fetchNewsFromGoogle(url: google_news_url)
                if file_manager.fileExist(filename) {
                    let file_content = try file_manager.readFile(filename)
                    let stored_news = try scraper.fetchNewsFromXML(value: file_content)
                    
                    await MainActor.run {
                        self.news = stored_news
                    }
                    
                    let retrieved_xml = try XMLDocument(string: retrieved_news)
                    let stored_xml = try XMLDocument(string: file_content)
                    
                    if let retrieved_date = retrieved_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
                       let stored_date = stored_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
                       stored_date != retrieved_date {
                        
                        try file_manager.writeToFile(retrieved_news, filename)
                        let news = try scraper.fetchNewsFromXML(value: retrieved_news)
                        await MainActor.run {
                            self.news = news
                        }
                    }
                    return
                }
                
                let news = try scraper.fetchNewsFromXML(value: retrieved_news)
                await MainActor.run {
                    self.news = news
                }
            } catch {
                debugPrint(error)
            }
        }
    }
    
    // MARK: - Search news
    public func searchNews(text: String) {
        news.removeAll()
        guard let google_news_url = URL(string: "https://news.google.com/rss/search?q=\(text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&\(fillCountryLangParams())") else {
            error = "invalid google url, https://news.google.com/rss/search?q=\(text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&\(fillCountryLangParams())"
            debugPrint(#file, #line)
            debugPrint(error)
            return
        }
        let filename = "\(text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)-news.txt"
        
        Task(priority: .high) {
            do {
                let retrieved_news = try await scraper.fetchNewsFromGoogle(url: google_news_url)
                if file_manager.fileExist(filename) {
                    let file_content = try file_manager.readFile(filename)
                    let stored_news = try scraper.fetchNewsFromXML(value: file_content)
                    
                    await MainActor.run {
                        self.news = stored_news
                    }
                    
                    let retrieved_xml = try XMLDocument(string: retrieved_news)
                    let stored_xml = try XMLDocument(string: file_content)
                    
                    if let retrieved_date = retrieved_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
                       let stored_date = stored_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
                       stored_date != retrieved_date {
                        
                        try file_manager.writeToFile(retrieved_news, filename)
                        let news = try scraper.fetchNewsFromXML(value: retrieved_news)
                        await MainActor.run {
                            self.news = news
                        }
                    }
                    return
                }
                
                let news = try scraper.fetchNewsFromXML(value: retrieved_news)
                await MainActor.run {
                    self.news = news
                }
            } catch {
                debugPrint(error)
            }
        }
    }
    
    public func latestNews() async throws -> GoogleNews? {
        guard news.isEmpty else {
            return news.first
        }
        
        guard let google_news_url = URL(string: "https://news.google.com/rss?\(fillCountryLangParams())") else {
            error = "https://news.google.com/rss?\(fillCountryLangParams())"
            debugPrint(#file, #line)
            debugPrint(error)
            throw ModelError.invalidGoogleURL(string: error)
        }
        let filename = "\(self.selected_topic.rawValue)-news.txt"
        
        let retrieved_news = try await scraper.fetchNewsFromGoogle(url: google_news_url)
        
        if file_manager.fileExist(filename) {
            let file_content = try file_manager.readFile(filename)
            let stored_news = try scraper.fetchNewsFromXML(value: file_content)
            
            await MainActor.run {
                self.news = stored_news
            }
            
            let retrieved_xml = try XMLDocument(string: retrieved_news)
            let stored_xml = try XMLDocument(string: file_content)
            
            if let retrieved_date = retrieved_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
               let stored_date = stored_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
               stored_date != retrieved_date {
                
                try file_manager.writeToFile(retrieved_news, filename)
                let news = try scraper.fetchNewsFromXML(value: retrieved_news)
                await MainActor.run {
                    self.news = news
                }
            }
            return self.news.first
        }
        
        let news = try scraper.fetchNewsFromXML(value: retrieved_news)
        await MainActor.run {
            self.news = news
        }
        return self.news.first
    }
    
    public func latestNewsWithTopic(_ topic: Topic = .latest) async throws -> GoogleNews? {
        news.removeAll()
        let filename = "\(topic.rawValue)-news.txt"
        
        guard var google_news_url = URL(string: "https://news.google.com/news/rss/headlines/section/topic/\(topic.rawValue.uppercased())?\(fillCountryLangParams())") else {
            error = " https://news.google.com/news/rss/headlines/section/topic/\(topic.rawValue.uppercased())?\(fillCountryLangParams())"
            debugPrint(#file, #line)
            debugPrint(error)
            throw ModelError.invalidGoogleURL(string: error)
        }
        
        if selected_topic == .latest {
            google_news_url = URL(string: "https://news.google.com/rss?\(fillCountryLangParams())")!
        }
        
        let retrieved_news = try await scraper.fetchNewsFromGoogle(url: google_news_url)
        if file_manager.fileExist(filename) {
            let file_content = try file_manager.readFile(filename)
            let stored_news = try scraper.fetchNewsFromXML(value: file_content)
            
            await MainActor.run {
                self.news = stored_news
            }
            
            let retrieved_xml = try XMLDocument(string: retrieved_news)
            let stored_xml = try XMLDocument(string: file_content)
            
            if let retrieved_date = retrieved_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
               let stored_date = stored_xml.firstChild(xpath: "/rss/channel/lastBuildDate")?.stringValue,
               stored_date != retrieved_date {
                
                try file_manager.writeToFile(retrieved_news, filename)
                let news = try scraper.fetchNewsFromXML(value: retrieved_news)
                await MainActor.run {
                    self.news = news
                }
            }
            return self.news.first
        }
        
        let news = try scraper.fetchNewsFromXML(value: retrieved_news)
        await MainActor.run {
            self.news = news
        }
        
        return self.news.first
    }
    
    private enum ModelError: Error {
        case invalidGoogleURL(string: String)
        case unknownTopic
    }
}


// MARK: - Topics
extension GoogleNewsModel {
    enum Topic: String, CaseIterable, Identifiable {
        var id: Self { self }
        
        case latest
        case world
        case business
        case technology
        case entertainment
        case sports
        case science
        case health
    }
}
