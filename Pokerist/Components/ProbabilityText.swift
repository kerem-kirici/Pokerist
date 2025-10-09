//
//  ProbabilityText.swift
//  Pokerist
//
//  Created by Kerem Kirici on 7.10.2025.
//

import SwiftUI

struct ProbabilityText: View {
    @State var probability: Double
    @State var decimalPointIndex: Int = 0
    
    private var probabilityText: String {
        let fullValue = probability * 100
        let wholePart = Int(floor(fullValue))
        let fullString = String(fullValue)
        
        if decimalPointIndex == 0 {
            return "\(Int(ceil(fullValue)))"
        }
        
        if let dotIndex = fullString.firstIndex(of: ".") {
            let decimalStart = fullString.index(after: dotIndex)
            let decimalPart = String(fullString[decimalStart...]).prefix(decimalPointIndex > 0 ? decimalPointIndex : 0)
            return "\(wholePart).\(decimalPart)"
        }
        
        return "\(wholePart).0"
    }
    
    
    var body: some View {
        Text("\(probabilityText)%")
            
    }
    
    
}

#Preview {
    ProbabilityText(probability: 0.513)
        .font(.system(size: 13, weight: .medium, design: .rounded))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule().fill(Color.purple.opacity(0.15))
        )
}
