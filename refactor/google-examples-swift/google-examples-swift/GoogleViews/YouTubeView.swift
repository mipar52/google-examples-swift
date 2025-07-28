//
//  YouTubeView.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 28.07.2025..
//

import SwiftUI

struct YouTubeView: View {
    private let youTubeService = YouTubeService()
    
    @State private var presentAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var showingPicker = false
    @State private var selectedVideoURL: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Video API calls")
                .font(.headline)
                .foregroundStyle(.red)
            
            Button {
                youTubeService.getChannelList { successString in
                    presentAlert.toggle()
                    alertMessage = successString ?? "Unknown response"
                }
            } label: {
                Text("Get channel list")
            }
            
            Button {
                youTubeService.getPlaylistVideos { successString in
                    presentAlert.toggle()
                    alertMessage = successString ?? "Unknown response"
                }
            } label: {
                Text("Get playlist videos")
            }
            
            Button {
                youTubeService.getSearchList { successString in
                    presentAlert.toggle()
                    alertMessage = successString ?? "Unknown response"
                }
            } label: {
                Text("Get search list")
            }
            
            Button {
                youTubeService.updateVideo { successString in
                    presentAlert.toggle()
                    alertMessage = successString
                }
            } label: {
                Text("Update video")
            }
            
            Button {
                youTubeService.deleteVideo { successString in
                    presentAlert.toggle()
                    alertMessage = successString
                }
            } label: {
                Text("Delete video")
            }
            
            Button {
                showingPicker.toggle()
            } label: {
                Text("Upload video")
            }
            Text("Comment API calls")
                .font(.headline)
                .foregroundStyle(.red)
            Button {
                youTubeService.getAllCommentFromVideo { successString in
                    presentAlert.toggle()
                    alertMessage = successString
                }
            } label: {
                Text("Get top-level comments (thread) from video")
            }
            
            Button {
                youTubeService.getAllCommentRepliesFromThread { successString in
                    presentAlert.toggle()
                    alertMessage = successString
                }
            } label: {
                Text("Get comment replies from top-level comment (thread) from video")
            }
            
            Button {
                youTubeService.insertComment { successString in
                    presentAlert.toggle()
                    alertMessage = successString
                }
            } label: {
                Text("Insert comment")
            }
        }
        .onAppear {
            youTubeService.fetchAuthorization()
        }
        .sheet(isPresented: $showingPicker) {
            VideoPickerView { url in
                selectedVideoURL = url
                if let videoURL = url {
                    youTubeService.uploadVideoFile(locationURL: videoURL) { successString in
                        presentAlert.toggle()
                        alertMessage = successString
                    }
                }
            }
        }
        .alert("YouTube API result",
               isPresented: $presentAlert,
               actions: {},
               message: {
                    Text(alertMessage)
                })
    }
}

#Preview {
    YouTubeView()
}
