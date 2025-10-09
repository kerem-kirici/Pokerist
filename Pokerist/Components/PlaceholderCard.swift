//
//  PlaceholderCard.swift
//  Pokerist
//
//  Created by Kerem Kirici on 5.10.2025.
//

import SwiftUI

struct PlaceholderCard: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "hand.point.up.left.fill")
                .font(.system(size: 24))
                .foregroundStyle(.blue.opacity(0.7))
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding()
        .background(
            ZStack {
                // Liquid glass effect
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Gradient overlay for depth
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.1),
                                Color.blue.opacity(0.05),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                
                // Inner glow
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.2),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .blur(radius: 0.5)
            }
        )
    }
}
