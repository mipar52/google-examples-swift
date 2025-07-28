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
    
    var body: some View {
        VStack(spacing: 20) {
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
                youTubeService.uploadVideoFile(locationURL: URL(string: "")!) { successString in
                    presentAlert.toggle()
                    alertMessage = successString
                }
            } label: {
                Text("Upload video")
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
