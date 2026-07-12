//
//  AppIconBadge.swift
//  MyPills
//
//  The app's gradient icon badge, reused wherever the app itself (not a
//  specific pill) needs representing: WelcomeView, LoginView, AboutView.
//

import SwiftUI

struct AppIconBadge: View {
    var size: CGFloat = 72
    var cornerRadius: CGFloat = 20
    var iconSize: CGFloat = 32

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.accentColor.gradient)
            Image(systemName: "pills.fill")
                .font(.system(size: iconSize))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: .accentColor.opacity(0.35), radius: size * 0.2, y: size * 0.1)
    }
}

#Preview {
    VStack(spacing: 24) {
        AppIconBadge(size: 120, cornerRadius: 28, iconSize: 56)
        AppIconBadge()
    }
    .padding()
}
