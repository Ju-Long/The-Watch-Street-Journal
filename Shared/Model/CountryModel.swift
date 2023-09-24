//
//  CountryModel.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 24/6/23.
//

import Foundation
import Combine
import CoreData
import SwiftyJSON

class CountryModel: ObservableObject {
    static let shared = CountryModel()
    
    @Published var countries = Set<Country>()
    @Published var selected_country: Country?
    @Published var previously_selected_countries: [Country] = []
    
    private var locale: Locale = Locale.current
    private var persistence = PersistenceController.shared
    
    private let defaults = UserDefaults(suiteName: "group.com.BaBaSaMa.The-Watch-Street-Journal") ?? UserDefaults.standard
    
    init() {
        do {
            guard let file = Bundle.main.url(forResource: "countries", withExtension: "json"),
                  try file.checkResourceIsReachable() else {
                return
            }
            
            @BundleFile(name: "countries", type: "json", decoder: { JSON($0) })
            var json: JSON
            for json_content in json.arrayValue {
                countries.insert(Country(
                    name: json_content["name"].stringValue,
                    code: json_content["code"].stringValue,
                    language: json_content["language"]["name"].stringValue,
                    language_code: json_content["language"]["code"].stringValue
                ))
            }
            
            loadSelectedCountry()
        } catch {
            debugPrint(error)
        }
    }
    
    private func loadSelectedCountry() {
        do {
            let request = NSFetchRequest<SelectedCountryHistory>(entityName: "SelectedCountryHistory")
            let result = try persistence.container.viewContext.fetch(request)
            
            for history in result {
                if let name = history.name,
                   let country = countries.first(where: { $0.name == name }) {
                    previously_selected_countries.append(country)
                }
            }
        } catch {
            debugPrint(error)
        }
        
        if let language = defaults.string(forKey: "language"),
           let region = defaults.string(forKey: "region") {
            
            let components = Locale.Components(languageCode: Locale.LanguageCode(language), languageRegion: Locale.Region(region))
            self.locale = Locale(components: components)
        }
        
        selected_country = countries.first(where: { locale.identifier.contains($0.code) })
    }
    
    public func selectCountry(_ country: Country) {
        if let selected_country = selected_country  {
        }
        
        selected_country = country
        defaults.setValue(country.language_code, forKey: "language")
        defaults.setValue(country.code, forKey: "region")
        
        if previously_selected_countries.contains(country) { return }
        
        let context = persistence.container.viewContext
        let country_history = SelectedCountryHistory(context: context)
        country_history.name = country.name
        
        do {
            try context.save()
            
            let request = NSFetchRequest<SelectedCountryHistory>(entityName: "SelectedCountryHistory")
            let result = try persistence.container.viewContext.fetch(request)
            
            previously_selected_countries.removeAll()
            for history in result {
                if let name = history.name,
                   let country = countries.first(where: { $0.name == name }) {
                    previously_selected_countries.append(country)
                }
            }
        } catch {
            debugPrint(error)
        }
    }
}

extension CountryModel {
    @propertyWrapper struct BundleFile<DataType> {
        let name: String
        let type: String
        let file_manager: FileManager = .default
        let bundle: Bundle = .main
        let decoder: (Data) -> DataType
        
        var wrappedValue: DataType {
            guard let path = bundle.path(forResource: name, ofType: type) else { fatalError("Resource not found: \(name).\(type)") }
            guard let data = file_manager.contents(atPath: path) else { fatalError("Can not load file at: \(path)") }
            return decoder(data)
        }
    }
}
