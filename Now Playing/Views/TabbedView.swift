//
//  TabbedView.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 3/9/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI

struct TabbedView: View {
    var body: some View {
        TabView {
            PlayingView()
                .tabItem {
                    Image(systemName: "music.house.fill")
                    Text("Now Playing")
            }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
            }
        }
    }
}

struct TabbedView_Previews: PreviewProvider {
    static var previews: some View {
        TabbedView()
    }
}
