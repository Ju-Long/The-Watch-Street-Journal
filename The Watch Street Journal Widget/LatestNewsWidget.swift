
import WidgetKit
import SwiftUI

struct LatestNewsWidgetProvider: TimelineProvider {
    let scraper = Scraper()
    
    func placeholder(in context: Context) -> LatestNewsEntry {
        return LatestNewsEntry(date: Date(), size: context.displaySize)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LatestNewsEntry) -> Void) {
        if context.isPreview {
            completion(LatestNewsEntry(date: Date(), size: context.displaySize))
            return
        }
        
        Task(priority: .utility) {
            do {
                let news_model = GoogleNewsModel()
                guard let latest_news = try await news_model.latestNews() else {
                    completion(LatestNewsEntry(date: Date(), size: context.displaySize))
                    return
                }
                
                do {
                    let news_url = try await scraper.getNewsLinkFromGoogleRedirect(latest_news.source.source_url)
                    
                    if let host = news_url.host,
                       let img_url = URL(string: "https://www.google.com/s2/favicons?sz=512&domain=\(host)"),
                       let data = try? Data(contentsOf: img_url),
                       let image = UIImage(data: data) {
                        completion(LatestNewsEntry(date: Date(), latest_news: latest_news, image: image, size: context.displaySize))
                        return
                    }
                } catch {
                    debugPrint(error)
                    
                    completion(LatestNewsEntry(date: Date(), latest_news: latest_news, size: context.displaySize, image_error: error))
                    return
                }
                
                completion(LatestNewsEntry(date: Date(), latest_news: latest_news, size: context.displaySize))
                return
            } catch {
                debugPrint(error)
                
                completion(LatestNewsEntry(date: Date(), size: context.displaySize, error: error))
                return
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LatestNewsEntry>) -> Void) {
        let next_update = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
    
        if context.isPreview {
            let entry = LatestNewsEntry(date: Date(), size: context.displaySize)
            let timeline = Timeline(entries: [entry], policy: .after(next_update))
            completion(timeline)
            return
        }
        
        Task(priority: .utility) {
            do {
                let news_model = GoogleNewsModel()
                guard let latest_news = try await news_model.latestNews() else {
                    let entry = LatestNewsEntry(date: Date(), size: context.displaySize)
                    let timeline = Timeline(entries: [entry], policy: .after(next_update))
                    completion(timeline)
                    return
                }
                
                do {
                    let news_url = try await scraper.getNewsLinkFromGoogleRedirect(latest_news.source.source_url)
                    
                    if let host = news_url.host,
                       let img_url = URL(string: "https://www.google.com/s2/favicons?sz=512&domain=\(host)"),
                       let data = try? Data(contentsOf: img_url),
                       let image = UIImage(data: data) {
                        let entry = LatestNewsEntry(date: Date(), latest_news: latest_news, image: image, size: context.displaySize)
                        let timeline = Timeline(entries: [entry], policy: .after(next_update))
                        completion(timeline)
                        return
                    }
                } catch {
                    debugPrint(error)
                    
                    let entry = LatestNewsEntry(date: Date(), latest_news: latest_news, size: context.displaySize, image_error: error)
                    let timeline = Timeline(entries: [entry], policy: .after(next_update))
                    completion(timeline)
                    return
                }
                
                let entry = LatestNewsEntry(date: Date(), latest_news: latest_news, size: context.displaySize)
                let timeline = Timeline(entries: [entry], policy: .after(next_update))
                completion(timeline)
                return
            } catch {
                debugPrint(error)
                
                let entry = LatestNewsEntry(date: Date(), size: context.displaySize, error: error)
                let timeline = Timeline(entries: [entry], policy: .after(next_update))
                completion(timeline)
                return
            }
        }
    }
    
}

struct LatestNewsEntry: TimelineEntry {
    let date: Date
    var latest_news: GoogleNews? = nil
    var image: UIImage? = nil
    let size: CGSize
    var error: Error? = nil
    var image_error: Error? = nil
}

struct LatestNews_EntryView: View {
    var entry: LatestNewsWidgetProvider.Entry
    
    var body: some View {
        HStack {
            if let error = entry.error {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                
                Text(error.localizedDescription)
                    .lineLimit(3)
                    .font(.headline)
            } else if let latest_news = entry.latest_news {
                if entry.image_error != nil {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                } else {
                    Image(uiImage: entry.image!)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .aspectRatio(contentMode: .fit)
                        .widgetAccentable(true)
                }
                
                VStack(alignment: .leading) {
                    Text(latest_news.source.title)
                        .lineLimit(3)
                        .font(.caption2)
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.init(red: 1, green: 1, blue: 1, opacity: 0.2))
                    .frame(maxWidth: entry.size.width * 0.25)
                
                VStack(alignment: .leading) {
                    Text("Latest General News Headline")
                        .lineLimit(3)
                        .font(.caption2)
                        .fontWeight(.bold)
                }
            }
        }
    }
}

struct LatestNewsWidget: Widget {
    let kind: String = "TWSJ_LatestNews"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: LatestNewsWidgetProvider()) { entry in
                LatestNews_EntryView(entry: entry)
            }
            .configurationDisplayName(Text("TWSJ Latest General News"))
            .description(Text("Display the latest news retrieved from Google News"))
            .supportedFamilies([.accessoryRectangular])
    }
}
