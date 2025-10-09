//
//  CurrentHandBadge.swift
//  Pokerist
//
//  Created by Kerem Kirici on 5.10.2025.
//

import SwiftUI

struct CurrentHandBadge: View {
    let handType: PokerHandType
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: handType.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
            
            Text(handType.rawValue)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            ZStack {
                // Liquid glass effect
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Gradient overlay for depth
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.15),
                                Color.blue.opacity(0.08),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.blue.opacity(0.4), lineWidth: 1.5)
                
                // Inner glow
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
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

