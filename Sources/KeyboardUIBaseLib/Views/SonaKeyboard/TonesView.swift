//
//  PersonaSelectionView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 16/8/25.
//

import SwiftUI

struct TonesView: View {
    @EnvironmentObject private var sonaVM: SonaViewModel
    @EnvironmentObject private var toastMessageVM: ToastMessageManager
    
    private func isSelectedTone(_ tone: String) -> Bool {
        return sonaVM.selectedTone == tone
    }
    
    private func isSelectedPersona(_ persona: String) -> Bool {
        return sonaVM.selectedPersona == persona
    }
    
    enum SelectionType {
        case tone(String)
        case persona(String)
    }
    
    private func onSelect(type: SelectionType) async{
        do {
            let input = sonaVM.input
            var selectedTone =  !sonaVM.selectedTone.isEmpty ? sonaVM.selectedTone : DEFAULT_SONA_TONE
            var selectedPersona = !sonaVM.selectedPersona.isEmpty ? sonaVM.selectedPersona : DEFAULT_SONA_PERSONA
            
            switch type {
            case .tone(let tone):
                sonaVM.selectTone(tone)
                selectedTone = tone
                
            case .persona(let persona):
                sonaVM.selectPersona(persona)
                selectedPersona = persona
            }
            print("Selected tone: \(selectedTone), persona: \(selectedPersona)")
            let params = RewriteRequestParam(message: input, tone: selectedTone, persona: selectedPersona)
            let data =   try await sonaVM.rewriteText(params)
            print("Rewritten text: \(data)")
        }catch {
            print("Error rewriting text: \(error)")
            if let appError = error as? AppError {
                toastMessageVM.showError("\(appError.message)")
            } else {
                toastMessageVM.showError("\(error.localizedDescription)")
            }
        }
        
    }
    
    
    private let linearGradientColors = [Color.black.opacity(0),
                                        Color.black.opacity(0.3),
                                        Color.black.opacity(0.6),
                                        Color.black.opacity(0.7),
                                        Color.red]
    
    private var leftBlurView: some View {
        HStack(spacing:0){
            Rectangle()
                .fill(.thinMaterial)
                .mask {
                    LinearGradient(colors:linearGradientColors,
                                   startPoint: .trailing,
                                   endPoint: .leading)
                    
                } .frame(width: 30)
            Spacer()
        }
    }
    
    private var rightBlurView: some View {
        HStack(spacing:0){
            Spacer()
            Rectangle()
                .fill(.thinMaterial)
                .mask {
                    LinearGradient(colors:linearGradientColors,
                                   startPoint: .leading,
                                   endPoint: .trailing)
                    
                } .frame(width: 30)
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing:5) {
                        ForEach(SONA_TONES, id: \.self) { option in
                            ChipView(option){
                                Task {
                                    await onSelect(type: .tone(option))
                                }
                            }.isSelected(isSelectedTone(option))
                                .small()
                        }
                    }
                    .padding(.horizontal, 25)
                    .frame(maxHeight:.infinity,alignment:.top)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing:5) {
                        ForEach(SONA_PERSONAS , id: \.self) { option in
                            ChipView(option){
                                Task {
                                    await onSelect(type: .persona(option))
                                }
                            }.isSelected(isSelectedPersona(option))
                        }
                    }
                    .padding(.horizontal, 25)
                    .frame(maxHeight:.infinity,alignment:.bottom)
                }
            }
            leftBlurView
            rightBlurView
        }.frame(height: 95)
            //.displayToastMessage(toastMessageVM)
    }
}

#Preview {
    @Previewable @StateObject var container = SonaAppContainer(container: DIContainer.shared)
    TonesView()
        .environmentObject(container.sonaVM)
        .environmentObject(container.loadingVM)
        .environmentObject(container.toastMessageVM)
}
