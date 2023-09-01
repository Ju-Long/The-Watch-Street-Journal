//
//  Settings.swift
//  The Watch Street Journal Watch App
//
//  Created by BaBaSaMa on 22/6/23.
//

import SwiftUI
import Kingfisher

struct SettingsView: View {
    @StateObject var model: GoogleNewsModel
    
    @StateObject private var country_model = CountryModel.shared
    
    private let current_locale = Locale.current
    
    var body: some View {
        Form {
            Section {
                if let selected_country = country_model.selected_country {
                    Text("Language: \(selected_country.language)")
                    
                    NavigationLink {
                        CountryPicker()
                    } label: {
                        HStack {
                            KFImage(URL(string: "https://flagcdn.com/16x12/\(selected_country.code.lowercased()).png"))
                            
                            Text(selected_country.name)
                        }
                    }
                }
            } header: {
                Label("Language and Location", systemImage: "globe")
            }
        }
        .navigationTitle(Text("Settings"))
        .task {}
        .onChange(of: country_model.selected_country) { v in
            guard let v = v else {
                return
            }
            
            model.changeCountry(v)
        }
    }
}
