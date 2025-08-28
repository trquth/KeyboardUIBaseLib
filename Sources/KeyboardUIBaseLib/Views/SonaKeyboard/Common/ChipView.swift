//
//  ChipView.swift
//  BaseKeyboard
//
//  Created by Thien Tran-Quan on 16/8/25.
//

import SwiftUI

enum ChipSize {
    case small
    case normal
    
    var height: CGFloat {
        switch self {
        case .small: return 35
        case .normal: return 46
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 15
        case .normal: return 40
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small: return 9
        case .normal: return 14
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 14
        case .normal: return 15
        }
    }
}

struct ChipView: View {
  private let title: String
    private var isSelected: Bool
    private var isDisabled: Bool
    private var isLoading: Bool
    private var size: ChipSize = .normal
    private var action: () -> Void
    
    init(_ title: String,
            isSelected: Bool = true,
            isDisabled: Bool = false,
            isLoading: Bool = false,
            size: ChipSize = .normal,
         action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self.size = size
        self.action = action
    }
    
    var body: some View {
        WTextButton(title, action: action)
            .buttonStyle(.contained)
            .foregroundColor((isDisabled == true || isLoading == true) ? .black.opacity(0.3) : (isSelected ? .white : .black))
            .backgroundColor((isDisabled == true || isLoading == true) ? Color(hex: "#F6F5F4") : (isSelected ? .black : Color(hex: "#F6F5F4")))
            .customFont(.interMedium, size: size.fontSize)
            .height(size.height)
            .cornerRadius(106)
            .horizontalPadding(size.horizontalPadding)
            .verticalPadding(size.verticalPadding)
            .disable(isDisabled || isLoading)
            .overlay(
                // Show activity indicator when loading
                Group {
                    if isLoading {
                        RoundedRectangle(cornerRadius: 106)
                            .fill(isSelected ? .black : Color(hex: "#F6F5F4"))
                            .frame(height: size.height)
                            .overlay(
                                ActivityIndicator(
                                    size: size == .small ? 16 : 20,
                                    color: isSelected ? .white : .black,
                                    style: .dots
                                )
                            )
                    }
                }
            )
    }
}

// MARK: - Chain Modifier Extensions
extension ChipView {
    func isSelected(_ isSelected: Bool) -> ChipView {
        var copy = self
        copy.isSelected = isSelected
        return copy
    }
    
    func disable(_ isDisabled: Bool = true) -> ChipView {
        var copy = self
        copy.isDisabled = isDisabled
        return copy
    }
    
    func loading(_ isLoading: Bool) -> ChipView {
        var copy = self
        copy.isLoading = isLoading
        return copy
    }
    
   private func size(_ size: ChipSize) -> ChipView {
        var copy = self
       copy.size = size
        return copy
    }
    
    func small() -> ChipView {
        size(.small)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            // Basic Usage Examples
            VStack(spacing: 16) {
                Text("Basic ChipView Examples")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    // Default state (selected by default)
                    HStack(spacing: 12) {
                        ChipView("Default Selected") {
                            print("Default chip tapped")
                        }
                        
                        ChipView("Unselected", isSelected: false) {
                            print("Unselected chip tapped")
                        }
                        
                        ChipView("Disabled", isDisabled: true) {
                            print("This won't be called")
                        }
                    }
                    
                    Text("Default Selected • Unselected • Disabled")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Size Examples
            VStack(spacing: 16) {
                Text("Size Variations")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ChipView("Normal Size") {
                            print("Normal size tapped")
                        }
                        
                        ChipView("Small Size", size: .small) {
                            print("Small size tapped")
                        }
                        
                        ChipView("Small Chain") {
                            print("Small chain tapped")
                        }
                        .small()
                    }
                    
                    Text("Normal • Small (init) • Small (chain)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // State Combinations
            VStack(spacing: 16) {
                Text("State Combinations")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    // Selected states
                    HStack(spacing: 12) {
                        ChipView("Selected Normal") {
                            print("Selected normal tapped")
                        }
                        
                        ChipView("Selected Small", size: .small) {
                            print("Selected small tapped")
                        }
                    }
                    
                    // Loading states
                    HStack(spacing: 12) {
                        ChipView("Loading Selected", isLoading: true) {
                            print("Loading selected tapped")
                        }
                        
                        ChipView("Loading Unselected", isSelected: false, isLoading: true) {
                            print("Loading unselected tapped")
                        }
                        
                        ChipView("Loading Small", isLoading: true, size: .small) {
                            print("Loading small tapped")
                        }
                    }
                    
                    // Unselected states  
                    HStack(spacing: 12) {
                        ChipView("Unselected Normal", isSelected: false) {
                            print("Unselected normal tapped")
                        }
                        
                        ChipView("Unselected Small", isSelected: false, size: .small) {
                            print("Unselected small tapped")
                        }
                    }
                    
                    // Disabled states
                    HStack(spacing: 12) {
                        ChipView("Disabled Selected", isDisabled: true) {
                            print("Won't be called")
                        }
                        
                        ChipView("Disabled Unselected", isSelected: false, isDisabled: true) {
                            print("Won't be called")
                        }
                    }
                    
                    Text("Various state combinations including loading")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Chaining Methods
            VStack(spacing: 16) {
                Text("Chaining Methods")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ChipView("Chain to Unselect") {
                            print("Chained unselected tapped")
                        }
                        .isSelected(false)
                        
                        ChipView("Chain to Disable", isSelected: false) {
                            print("Won't be called")
                        }
                        .disable(true)
                        
                        ChipView("Chain to Small") {
                            print("Chained small tapped")
                        }
                        .small()
                        
                        ChipView("Chain Loading") {
                            print("Chained loading tapped")
                        }
                        .loading(true)
                    }
                    
                    Text("Using chaining methods including loading")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Complex Chaining
            VStack(spacing: 16) {
                Text("Complex Chaining")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ChipView("Multi Chain 1") {
                            print("Multi chain 1 tapped")
                        }
                        .isSelected(false)
                        .small()
                        
                        ChipView("Multi Chain 2") {
                            print("Multi chain 2 tapped")
                        }
                        .small()
                        .disable(false)
                        
                        ChipView("All Methods", isSelected: false, isDisabled: true, size: .normal) {
                            print("This will be enabled")
                        }
                        .isSelected(true)
                        .disable(false)
                        .small()
                    }
                    
                    Text("Multiple chaining examples")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Interactive Loading Demo
            VStack(spacing: 16) {
                Text("Interactive Loading Demo")
                    .font(.headline)
                
                LoadingChipDemo()
                
                Text("Tap chip to see loading state")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Interactive Examples
            VStack(spacing: 16) {
                Text("Interactive Examples")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ChipView("Language") {
                            print("Language selected")
                        }
                        
                        ChipView("Theme", isSelected: false) {
                            print("Theme selected")
                        }
                        
                        ChipView("Settings", isSelected: false) {
                            print("Settings selected")
                        }
                        .small()
                    }
                    
                    HStack(spacing: 12) {
                        ChipView("English") {
                            print("English selected")
                        }
                        .small()
                        
                        ChipView("Vietnamese", isSelected: false) {
                            print("Vietnamese selected")
                        }
                        .small()
                        
                        ChipView("Japanese", isSelected: false) {
                            print("Japanese selected")
                        }
                        .small()
                    }
                    
                    Text("Practical usage examples")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

struct LoadingChipDemo: View {
    @State private var isLoading = false
    @State private var isSelected = true
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 12) {
                ChipView("Process Data", isSelected: isSelected, isLoading: isLoading) {
                    isLoading = true
                    
                    // Simulate API call
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isLoading = false
                    }
                }
                
                ChipView("Small Process", isSelected: false, isLoading: isLoading, size: .small) {
                    isLoading = true
                    
                    // Simulate API call
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isLoading = false
                    }
                }
            }
            
            Button("Toggle Selection") {
                isSelected.toggle()
            }
            .font(.caption)
            
            Text(isLoading ? "Processing..." : "Ready to process")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
