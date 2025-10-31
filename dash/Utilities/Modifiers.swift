//
//  Modifiers.swift
//  dash
//
//  Created by Gergo Csizmadia on 2025. 10. 19..
//

import SwiftUI

public struct GlassEffectIfAvailable: ViewModifier {
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect()
        } else {
            content.background(
                .ultraThinMaterial, in: RoundedRectangle(cornerRadius: .infinity, style: .continuous)
            )
        }
    }
}
