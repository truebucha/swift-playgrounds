//
//  ContentView.swift
//  WeSplit
//
//  Created by Kanstantsin Bucha on 12/01/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("1")
                }
                Section {
                    Text("2")
                    Text("2")
                    Text("2")
                    Text("2")
                    Text("2")
                    Text("2")
                }
            }
            .navigationTitle("Swift")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
