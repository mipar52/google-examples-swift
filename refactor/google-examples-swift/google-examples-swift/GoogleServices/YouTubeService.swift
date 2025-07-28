//
//  YouTubeService.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 28.07.2025..
//

import Foundation
import GoogleAPIClientForREST_YouTube
import GoogleSignIn

struct YouTubeService {
    private let youTubeService = GTLRYouTubeService()
    
    func fetchAuthorization() {
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            print("No current user")
            return
        }

        currentUser.refreshTokensIfNeeded { user, error in
            guard error == nil else { return }
            guard let user = user else { return }

            // Get the access token to attach it to a REST or gRPC request.
            let accessToken = user.accessToken.tokenString
            self.youTubeService.additionalHTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
            
            // Or, get an object that conforms to GTMFetcherAuthorizationProtocol for
            // use with GTMAppAuth and the Google APIs client library.
            let authorizer = user.fetcherAuthorizer
            self.youTubeService.authorizer = authorizer
        }
    }
    
    func getSearchList(completionHandler: @escaping (String?) -> Void ) {
        let query = GTLRYouTubeQuery_SearchList.query(withPart: ["id","snippet"])
        query.additionalHTTPHeaders = ["X-Ios-Bundle-Identifier" : Utilities.getBundleId()]
        
        youTubeService.executeQuery(query) { ticket, searchList, ytError in
            if ytError == nil {
                var searchListItems = [String]()
                let searchList = searchList as? GTLRYouTube_SearchListResponse
                if let items = searchList?.items {
                    for item in items {
                        searchListItems.append((item.snippet?.channelTitle)!)
                    }
                    completionHandler(searchListItems.joined(separator: "\n"))
                } else {
                    completionHandler("Search list is empty!")
                }
            } else {
                completionHandler(ytError?.localizedDescription)
            }
        }
        
    }
    
    func getPlaylistVideos(completionHandler: @escaping (String?) -> Void) {
        
        let query = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: ["snippet", "contentDetails"])
        query.playlistId = Constants.youTubePlaylistId
        

        query.additionalHTTPHeaders = ["X-Ios-Bundle-Identifier" : Utilities.getBundleId()]
        
        youTubeService.executeQuery(query) { ticket, playlistList, ytError in
            var playlistItems = [String]()
            let playlistList = playlistList as? GTLRYouTube_PlaylistItemListResponse
            if let playlistList = playlistList?.items {
                for item in playlistList {
                    
                    print("Video ID: \(item.identifier!)")
                    playlistItems.append((item.snippet?.title)!)
                }
                completionHandler(playlistItems.joined(separator: "\n"))
                
            } else {
                completionHandler(ytError?.localizedDescription)
            }
        }
    }
    
    func getChannelList(completionHandler: @escaping (String?) -> Void) {
        
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: ["contentDetails"])
        query.mine = true
        
        youTubeService.executeQuery(query) { ticket, channelList, ytError in
            let channelList = channelList as? GTLRYouTube_ChannelListResponse
            
            if let channelList = channelList?.items {
                var stringResult = String()
                for list in channelList {
                    stringResult += "Likes: \(String(describing: list.contentDetails?.relatedPlaylists?.likes)), Title: \(String(describing: list.snippet?.title))"
                }
                completionHandler(stringResult)
            } else {
                completionHandler(ytError?.localizedDescription)
            }
        }
    }
    
    func uploadVideoFile(locationURL: URL, completionHandler: @escaping (String) -> Void) {
        
        let status = GTLRYouTube_VideoStatus()
        // don't worry, the uploaded video is set to private,
        // so only you can see it on your YouTube channel.
            status.privacyStatus = "private"
        
        let snippet = GTLRYouTube_VideoSnippet()
            snippet.title = "Random Video Title"
            snippet.tags = ["tag1", "tag2"]
        
        let desc = "Random Video Description"
        if desc.count > 0 {
            snippet.descriptionProperty = desc
        }
        
        snippet.categoryId = "22"
        
        let video = GTLRYouTube_Video()
        video.status = status
        video.snippet = snippet
        completionHandler(self.uploadVideo(video: video, locationURL: locationURL))
    }
    
    func uploadVideo(video: GTLRYouTube_Video?,
                     locationURL: URL?) -> String {

        let fileToUploadURL = locationURL!
        var stringResult = String()
        do {
            if !(try fileToUploadURL.checkResourceIsReachable()) {
                stringResult = "No Upload File Found"
            }
        } catch {
            stringResult = error.localizedDescription
        }
        
        let mimeType = Utilities.mimeTypeForPath(fileUrl: fileToUploadURL)
        print("mimeType: \(mimeType)")
        
        let uploadParameters = GTLRUploadParameters(fileURL: locationURL!, mimeType: mimeType)
        
        let query = GTLRYouTubeQuery_VideosInsert.query(withObject: video!, part: ["snippet","status"], uploadParameters: uploadParameters)
    
        var bundleIdentifier = Bundle.main.bundleIdentifier
        bundleIdentifier = bundleIdentifier?.trimmingCharacters(in: .whitespaces)
        query.additionalHTTPHeaders = ["X-Ios-Bundle-Identifier" : bundleIdentifier!]

        youTubeService.executeQuery(query) { ticket, uploadedVideo, ytError in
            if ytError == nil {
                if let uploadedVideo = uploadedVideo as? GTLRYouTube_Video {
                    print("Video ID: https://www.youtube.com/watch?v=\(uploadedVideo.identifier!)")
                    stringResult = "Video \(String(describing: uploadedVideo.snippet?.title)) uploaded!\nLink: https://www.youtube.com/watch?v=\(uploadedVideo.identifier!)"
                } else {
                    
                    stringResult = "Could not upload video!"
                }
            } else {
                stringResult = "Error with upload: \(String(describing: ytError?.localizedDescription))"
            }
        }
        return stringResult
    }
    
    func deleteVideo(completionHandler: @escaping (String) -> Void) {
        // the videoID is something like this: lXW7_oAcT84
        // https://www.youtube.com/watch?v=lXW7_oAcT84
        let query = GTLRYouTubeQuery_VideosDelete.query(withIdentifier: "lXW7_oAcT84")
            youTubeService.executeQuery(query) { ticket, _, ytError in
                if ytError == nil {
                    completionHandler("Video deleted!")
                } else {
                   completionHandler("Could not delete video: \(String(describing: ytError?.localizedDescription))")
                }
        }
    }
    
    func updateVideo(completionHandler: @escaping (String) -> Void) {
        //Updating the title of an already exisiting video
        let status = GTLRYouTube_VideoStatus()
        status.privacyStatus = "private"
        
        let snippet = GTLRYouTube_VideoSnippet()
        
        snippet.title = "Random Video Title New"
        snippet.tags = ["tag1", "tag2"]
        
        let desc = "Random Video Description"
        if desc.count > 0 {
            snippet.descriptionProperty = desc
        }
        
        snippet.categoryId = "22"
        
        let video = GTLRYouTube_Video()
        // the videoID is something like this: lXW7_oAcT84
        // https://www.youtube.com/watch?v=lXW7_oAcT84
        video.identifier = "lXW7_oAcT84"
        video.status = status
        video.snippet = snippet
        
        let query = GTLRYouTubeQuery_VideosUpdate.query(withObject: video, part: ["snippet","status"])
        youTubeService.executeQuery(query) { ticket, updatedVideo, ytError in
            if ytError == nil {
                completionHandler("Updated!")
            } else {
                completionHandler("Update error: \(String(describing: ytError?.localizedDescription))")
            }
        }
    }
    
    func getAllCommentFromVideo(completionHandler: @escaping (String) -> Void) {
        
        let query = GTLRYouTubeQuery_CommentThreadsList.query(withPart: ["snippet"])
        query.videoId = "FXrcFeuYtq8"
        query.order = "relevance" // "time" is default
        query.additionalHTTPHeaders = ["X-Ios-Bundle-Identifier" : Utilities.getBundleId()]

        youTubeService.executeQuery(query) { ticket, result, ytError in
            if ytError == nil {
                var stringResult = String()
                if let commentsResult = result as? GTLRYouTube_CommentThreadListResponse {
                    commentsResult.items?.forEach {
                        print($0.snippet?.topLevelComment?.identifier)
                        stringResult += "Comment: \(String(describing: $0.snippet?.topLevelComment?.snippet?.textOriginal)) - number of likes: \($0.snippet?.topLevelComment?.snippet?.likeCount?.intValue ?? 0)\n\n"
                    }
                }
                completionHandler(stringResult)
            } else {
                completionHandler("Insert comment error: \(String(describing: ytError?.localizedDescription))")
            }
        }
    }
    func getAllCommentRepliesFromThread(completionHandler: @escaping (String) -> Void) {
        
        let query = GTLRYouTubeQuery_CommentsList.query(withPart: ["snippet"])
        // ID of the top-comment (thread)
        query.parentId = "Ugzwpx68YLrjZIrIIGh4AaABAg"
        query.additionalHTTPHeaders = ["X-Ios-Bundle-Identifier" : Utilities.getBundleId()]

        youTubeService.executeQuery(query) { ticket, result, ytError in
            if ytError == nil {
                var stringResult = String()
                if let commentsResult = result as? GTLRYouTube_CommentListResponse {
                    commentsResult.items?.forEach {
                        stringResult += "Comment Author: \(String(describing: $0.snippet?.authorDisplayName)) - Text: \(String(describing: $0.snippet?.textOriginal))\n\n"
                    }
                }
                completionHandler(stringResult)
            } else {
                completionHandler("Insert comment error: \(String(describing: ytError?.localizedDescription))")
            }
        }
    }
    
    func insertComment(completionHandler: @escaping (String) -> Void) {
        let commentThread = GTLRYouTube_CommentThread()
        let threadSnippet = GTLRYouTube_CommentThreadSnippet()
        // the videoID is something like this: ojMsPVVZqdg
        // https://www.youtube.com/watch?v=ojMsPVVZqdg
        threadSnippet.videoId = "ojMsPVVZqdg"
        threadSnippet.channelId = "@babishculinaryunivers"
        
        let comment = GTLRYouTube_Comment()
        let commentSnippet = GTLRYouTube_CommentSnippet()
        commentSnippet.textOriginal = "Hello world!"
        comment.snippet = commentSnippet
        
        threadSnippet.topLevelComment = comment
        commentThread.snippet = threadSnippet
        
        // watch out, this will post a comment
        // on the https://www.youtube.com/watch?v=ojMsPVVZqdg video :)
    
        let query = GTLRYouTubeQuery_CommentThreadsInsert.query(withObject: commentThread, part: ["snippet"])
        query.additionalHTTPHeaders = ["X-Ios-Bundle-Identifier" : Utilities.getBundleId()]

        youTubeService.executeQuery(query) { ticket, _, ytError in
            if ytError == nil {
                completionHandler("Comment posted")
            } else {
                completionHandler("Insert comment error: \(String(describing: ytError?.localizedDescription))")
            }
        }
    }
}
