//
//  pixelwhisApp.swift
//  pixelwhis
//
//  Created by Arjun Varma on 20/11/25.
//

import SwiftUI

import SwiftData

@main
struct pixelwhisApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Pet.self, PetDNA.self, PlayerWallet.self])
    }
}
