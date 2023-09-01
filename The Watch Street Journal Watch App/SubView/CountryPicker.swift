//
//  CountryPicker.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 24/6/23.
//

import SwiftUI

struct CountryPicker: View {
    @StateObject var model = CountryModel.shared
    
    @State private var suggested_countries: [Country] = []
    @State private var country_sections: [(Character, [Country])] = []
    
    private let current_locale = Locale.current
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        List {
            Section {
                ForEach(suggested_countries, id: \.self) { suggested_country in
                    Button("\(suggested_country.name)") {
                        model.selectCountry(suggested_country)
                        dismiss()
                    }
                }
            } header: {
                Text("Suggested")
            }
            
            ForEach(country_sections, id: \.0) { character, countries in
                Section {
                    ForEach(countries.sorted(by: <), id: \.self) { country in
                        Button("\(country.name)") {
                            model.selectCountry(country)
                            dismiss()
                        }
                    }
                } header: {
                    Text(String(character))
                }
            }
        }
        .navigationTitle(Text("Countries"))
        .listStyle(.elliptical)
        .task {
            suggested_countries.append(model.countries.first(where: { current_locale.identifier.contains($0.code) })!)
            
            for country in model.previously_selected_countries {
                if suggested_countries.contains(country) { continue }
                suggested_countries.append(country)
            }
            
            self.country_sections = Dictionary(grouping: model.countries) { (country) -> Character in
                return country.name.first!
            }
            .map { (key: Character, value: [Country]) -> (letter: Character, countries: [Country]) in
                (letter: key, countries: value)
            }
            .sorted { (left, right) -> Bool in
                left.letter < right.letter
            }
        }
    }
}
