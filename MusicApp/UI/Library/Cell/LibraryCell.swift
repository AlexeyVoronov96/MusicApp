//
//  LibraryCell.swift
//  MusicApp
//
//  Created by Алексей Воронов on 16.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import URLImage
import SwiftUI

struct LibraryCell: View {
    var track: TrackLocal
    
    var body: some View {
        HStack {
            URLImage(track.imageURL ?? URL(string: "")!)
                .resizable()
                .frame(width: 60, height: 60)
                .cornerRadius(6)
            VStack(alignment: .leading) {
                Text(track.trackName)
                    .font(Font.system(size: 17))
                if track.collectionName != nil {
                    Text(track.collectionName ?? "")
                        .font(Font.system(size: 13))
                        .foregroundColor(Color(#colorLiteral(red: 0.7215686275, green: 0.7215686275, blue: 0.7294117647, alpha: 1)))
                }
                Text(track.artistName)
                    .font(Font.system(size: 13))
                    .foregroundColor(Color(#colorLiteral(red: 0.7215686275, green: 0.7215686275, blue: 0.7294117647, alpha: 1)))
            }
        }
    }
}
