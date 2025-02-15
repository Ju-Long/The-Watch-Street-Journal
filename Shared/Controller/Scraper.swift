//
//  Scraper.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 18/6/23.
//

// TODO: convert to fuzi one day https://github.com/cezheng/Fuzi.git

import Foundation
import Alamofire
import Fuzi

class Scraper {
    init() { }
    
    func fetchNewsFromGoogle(url: URL) async throws -> String {
        let request = await AF.request(url, method: .get).serializingString().response
        switch request.result {
        case .success(let value):
            return value
            
        case .failure(let error):
            debugPrint(error)
            throw error
        }
    }
    
    func fetchNewsFromXML(value: String) throws -> [GoogleNews] {
        let xml = try XMLDocument(string: value)
        var news: [GoogleNews] = []
        if var item = xml.firstChild(xpath: "/rss/channel/item") {
            
            news.append(try getGoogleNewsItem(item))
            while let _item = item.nextSibling {
                item = _item
                news.append(try getGoogleNewsItem(item))
            }
            
            news.sort(by: { $0.publish_date.timeIntervalSince1970 > $1.publish_date.timeIntervalSince1970 })
        }
        
        return news
    }
    
    private func getGoogleNewsItem(_ item: XMLElement) throws -> GoogleNews {
        guard let description = item.firstChild(xpath: "description")?.stringValue else {
            debugPrint("throw here", #line)
            throw ScaperError.invalidSyntax
        }

        var descriptions: [GoogleNews.GoogleNewsSource] = []
        let li_elements = try HTMLDocument(string: description, encoding: .utf8).css("li")
        for li in li_elements {
            let inner_doc = try HTMLDocument(string: li.rawXML)
            if let link = inner_doc.firstChild(css: "a"),
               let source = inner_doc.firstChild(css: "font") {

                descriptions.append(GoogleNews.GoogleNewsSource(
                    title: link.stringValue,
                    url: link["href"]!,
                    source: source.stringValue,
                    source_url: link["href"]!
                ))
            }
        }

        let dateformatter = DateFormatter()
        dateformatter.timeZone = TimeZone.gmt
        dateformatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zz"

        guard let title = item.firstChild(xpath: "title")?.stringValue,
              let source = item.firstChild(xpath: "source")?.stringValue,
              let news_url_string = item.firstChild(xpath: "link")?.stringValue,
              let source_url_string = item.firstChild(xpath: "source")?.attr("url"),
              URL(string: news_url_string) != nil,
              URL(string: source_url_string) != nil,
              let publish_date_string = item.firstChild(xpath: "pubDate")?.stringValue,
              let publish_date = dateformatter.date(from: publish_date_string) else {
            debugPrint("throw here", #line)
//            debugPrint("title", item.at_xpath("title")?.text)
//            debugPrint("source", item.at_xpath("source")?.text)
//            debugPrint("link", item.at_xpath("link")?.text)
//            debugPrint("pubDate", item.at_xpath("pubDate")?.text)
//            debugPrint(dateformatter.date(from: item.at_xpath("pubDate")!.text!))
            throw ScaperError.invalidSyntax
        }

        return GoogleNews(source: GoogleNews.GoogleNewsSource(
            title: title, url: news_url_string, source: source, source_url: source_url_string), publish_date: publish_date, description: descriptions)
    }
    
    public func getNewsLinkFromGoogleRedirect(_ link: String) async throws -> URL {
        let request = await AF.request(link, method: .get).serializingString().response
        switch request.result {
        case .success(let value):
            let html = try HTMLDocument(string: value, encoding: String.Encoding.utf8)
            
            for a in html.css("a") {
                if let link = a["href"],
                   let url = URL(string: link) {
                    return url
                }
            }
            
        case .failure(let error):
            debugPrint(error)
            throw error
        }
        
        throw ScaperError.noLinkAvailable
    }
    
    // MARK: - Error
    enum ScaperError: Error {
        case invalidSyntax
        case requestError
        case noLinkAvailable
        case unknownLinkDiscovered
        case imageNotFound
    }
}
