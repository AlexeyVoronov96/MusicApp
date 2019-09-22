//
//  LibraryView.swift
//  MusicApp
//
//  Created by Алексей Воронов on 16.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import SwiftUI

struct LibraryView: View {
    var transitionDelegate: TrackDetailViewTransitionDelegate
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: TrackLocal.entity(), sortDescriptors: [
        NSSortDescriptor(key: "savingDate", ascending: false)
    ]) var tracks: FetchedResults<TrackLocal>
    
    @State private var showingAlert: Bool = false
    @State private var track: TrackLocal!
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    Button(action: {
                        self.track = self.tracks[0]
                        let trackModel = self.performTrackModel(from: self.track)
                        self.transitionDelegate.maximizeTrackDetailView(with: trackModel)
                    }, label: {
                        Image(systemName: "play.fill")
                            .frame(width: geometry.size.width,
                                   height: 50)
                            .accentColor(Color(#colorLiteral(red: 0.9503687024, green: 0.2928149104, blue: 0.4626763463, alpha: 1)))
                            .background(Color("Button"))
                            .cornerRadius(10)
                            .imageScale(.large)
                    })
                }
                .padding()
                .frame(height: 50)
                
                Divider()
                    .padding([.leading, .trailing])
                List {
                    ForEach(tracks, id: \.self) { track in
                        LibraryCell(track: track)
                            .gesture(
                                LongPressGesture().onEnded { _ in
                                    self.track = track
                                    self.showingAlert = true
                                }
                                .simultaneously(with:
                                    TapGesture().onEnded { _ in
                                        self.track = track
                                        let keyWindow = UIApplication.shared.connectedScenes
                                            .filter { $0.activationState == .foregroundActive }
                                            .map { $0 as? UIWindowScene }
                                            .compactMap { $0 }
                                            .first?
                                            .windows
                                            .filter { $0.isKeyWindow }
                                            .first
                                        let tabBarVC = keyWindow?.rootViewController as? TabBarController
                                        tabBarVC?.trackDetailView.delegate = self
                                        let trackModel = self.performTrackModel(from: track)
                                        self.transitionDelegate.maximizeTrackDetailView(with: trackModel)
                                    }
                            ))
                    }
                }
            }
            .actionSheet(isPresented: $showingAlert, content: {
                ActionSheet(title: Text("Are you sure you want to delete this track?"),
                            buttons: [
                                .destructive(Text("Delete"), action: {
                                    self.delete(track: self.track)
                                }),
                                .cancel()
                    ]
                )
            })
                .navigationBarTitle("Library")
        }
    }
    
    private func delete(track: TrackLocal) {
        CoreDataManager.shared.managedObjectContext.delete(track)
        CoreDataManager.shared.saveContext()
    }
    
    private func performTrackModel(from track: TrackLocal) -> SearchViewModel.Cell {
        return SearchViewModel.Cell(trackId: track.trackId,
                                    iconURL: track.imageURL,
                                    trackName: track.trackName,
                                    collectionName: track.collectionName,
                                    artistName: track.artistName,
                                    previewUrl: track.previewURL)
    }
}

extension LibraryView: TrackDetailViewDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else {
            return nil
        }
        var previousTrack: SearchViewModel.Cell
        if myIndex - 1 < 0 {
            previousTrack = performTrackModel(from: tracks[tracks.count - 1])
            self.track = tracks[tracks.count - 1]
        } else {
            previousTrack = performTrackModel(from: tracks[myIndex - 1])
            self.track = tracks[myIndex - 1]
        }
        return previousTrack
    }
    
    func moveForwardForNextTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else {
            return nil
        }
        var nextTrack: SearchViewModel.Cell
        if myIndex + 1 >= tracks.count {
            nextTrack = performTrackModel(from: tracks[0])
            self.track = tracks[0]
        } else {
            nextTrack = performTrackModel(from: tracks[myIndex + 1])
            self.track = tracks[myIndex + 1]
        }
        return nextTrack
    }
}
