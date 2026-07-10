//
//  WelcomeView.swift
//  MyPills
//
//  Sits behind the login sheet while the user is signed out.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.accentColor.gradient)
                Image(systemName: "pills.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.white)
            }
            .frame(width: 120, height: 120)

            Text("My Pills")
                .font(.largeTitle.bold())
            Text("Keep track of your medications, organized into shareable folders.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

#Preview {
    WelcomeView()
}
