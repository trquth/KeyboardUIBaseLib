//
//  SupportedLanguesView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 17/8/25.
//

import SwiftUI

struct Language {
    let flag: String
    let name: String
    let isDefault: Bool
    
    static let supportedLanguages = [
        Language(flag: "usa", name: "English (American)", isDefault: true),
        Language(flag: "arabic", name: "Arabic (Modern Standard)", isDefault: false),
        Language(flag: "netherlands", name: "Dutch", isDefault: false),
        Language(flag: "uk", name: "English (British)", isDefault: false),
    ]
}

struct SupportedLanguagesView: View {
    let onSelectLanguage: ((Language) -> Void)?
    @State private var selectedLanguage: String = "English (American)"
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Language.supportedLanguages, id: \.name) { language in
                    LanguageRow(
                        language: language,
                        isSelected: selectedLanguage == language.name
                    ) {
                        selectedLanguage = language.name
                        onSelectLanguage?(language)
                    }
                }
            }
        }
        .background(.white)
    }
}

struct LanguageRow: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(language.flag)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)
                WText(language.name)
                    .customFont(isSelected ? .interSemiBold: .interMedium,size: 14.5)
                    .foregroundColor(isSelected ? .white : .black)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height:51)
            .background(
                Rectangle()
                    .fill(isSelected ? .black : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview(traits:.sizeThatFitsLayout) {
    SupportedLanguagesView{
         print("Selected language: \($0.name)")
    }
}
