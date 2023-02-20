//
//  YouTubeController.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 17.02.2023..
//

import UIKit
import MobileCoreServices
import GoogleAPIClientForREST
import GoogleSignIn
import GTMSessionFetcher

class YouTubeController: UIViewController {
    
    let youTubeService = GTLRYouTubeService()
    let utils = Utils()
    let queue = DispatchQueue(label: "video-picker")
    var videoPickerController : UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        youTubeService.apiKey = K.apiKey
        youTubeService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
    }
    
    
    @IBAction func getSearchList(_ sender: UIButton) {
       getSearchList()
    }
    
    @IBAction func getPlaylistVideos(_ sender: UIButton) {
        getPlaylistVideos()
    }
    
    
    @IBAction func uploadVideo(_ sender: UIButton) {
        openVideoPicker()
    }
    
    
    @IBAction func deleteVideo(_ sender: UIButton) {
        deleteVideo()
    }
    
    
    @IBAction func updateVideo(_ sender: UIButton) {
        updateVideo()
    }
    
    func getSearchList() {
        let query = GTLRYouTubeQuery_SearchList.query(withPart: ["id","snippet"])
        query.additionalHTTPHeaders = ["X-Ios-Bundle-Identifier" : getBundleId()]
        
        youTubeService.executeQuery(query) { ticket, searchList, ytError in
            if ytError == nil {
                var searchListItems = [String]()
                let searchList = searchList as? GTLRYouTube_SearchListResponse
                if let items = searchList?.items {
                    for item in items {
                        searchListItems.append((item.snippet?.channelTitle)!)
                    }
                    self.utils.showAlert(title: "Search list", message: searchListItems.joined(separator: "\n"), vc: self)
                } else {
                    self.utils.showAlert(title: "Search list", message: "Search list is empty!", vc: self)

                }
            } else {
                print("Youtube error: \(String(describing: ytError?.localizedDescription))")
                self.utils.showAlert(title: "Error", message: "Getting error with searching lists:\n\(String(describing: ytError?.localizedDescription))", vc: self)
            }
        }
        
    }
    
    func getPlaylistVideos() {
        
        let query = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: ["snippet", "contentDetails"])
        query.playlistId = "PLopY4n17t8RCflNiDpZcNKRmugF-W-S0o"
        //playlist from Binging with Babish channel -> https://www.youtube.com/watch?v=1-i_7K02S14&list=PLopY4n17t8RCflNiDpZcNKRmugF-W-S0o

        query.additionalHTTPHeaders = ["X-Ios-Bundle-Identifier" : getBundleId()]
        
        youTubeService.executeQuery(query) { ticket, playlistList, ytError in
            var playlistItems = [String]()
            let playlistList = playlistList as? GTLRYouTube_PlaylistItemListResponse
            if let playlistList = playlistList?.items {
                for item in playlistList {
                    
                    print("Video ID: \(item.identifier!)")
                    playlistItems.append((item.snippet?.title)!)
                }
                self.utils.showAlert(title: "Playlist videos", message: playlistItems.joined(separator: "\n"), vc: self)
                
            } else {
                self.utils.showAlert(title: "Error", message: "Getting error with playlist videos:\n\(String(describing: ytError?.localizedDescription))", vc: self)
            }
        }
    }
    
    func getChannelList() {
        
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: ["contentDetails"])
        query.mine = true
        
        youTubeService.executeQuery(query) { ticket, channelList, ytError in
            let channelList = channelList as? GTLRYouTube_ChannelListResponse
            
            if let channelList = channelList?.items {
                for list in channelList {
                    print(list.contentDetails?.relatedPlaylists?.watchHistory)
                    print(list.contentOwnerDetails?.debugDescription)
                }
            } else {
                print(ytError?.localizedDescription)
            }
        }
    }
    
    func uploadVideoFile(locationURL: URL) {
        
        let status = GTLRYouTube_VideoStatus()
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
        
        self.uploadVideo(video: video, locationURL: locationURL)
    }
    
    func uploadVideo(video: GTLRYouTube_Video?, locationURL: URL?) {

        let fileToUploadURL = locationURL!
        
        do {
            if !(try fileToUploadURL.checkResourceIsReachable()) {
                self.utils.showAlert(title: "Error", message: "No Upload File Found", vc: self)
            }
        } catch _ {
            self.utils.showAlert(title: "No Upload File Found", message: "Path: \(fileToUploadURL.path)", vc: self)
        }
        
        let filename = fileToUploadURL.lastPathComponent
        let mimeType = self.mimeTypeForPath(fileUrl: fileToUploadURL)
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
                    self.utils.showAlert(title: "Success", message: "Video \(String(describing: uploadedVideo.snippet?.title))!", vc: self)
                } else {
                    self.utils.showAlert(title: "Error", message: "Could not upload video!", vc: self)
                }
            } else {
                self.utils.showAlert(title: "Error", message: "Error with upload: \(String(describing: ytError?.localizedDescription))", vc: self)
            }
        }
    }
    
    func deleteVideo() {
        
        let query = GTLRYouTubeQuery_VideosDelete.query(withIdentifier: "your-video-id")
            youTubeService.executeQuery(query) { ticket, _, ytError in
                if ytError == nil {
                    self.utils.showAlert(title: "Success!", message: "Video deleted!", vc: self)
                    print("Deleted!")
                } else {
                    self.utils.showAlert(title: "Error", message: "Could not delete video: \(String(describing: ytError?.localizedDescription))", vc: self)
                }
        }
    }
    
    func updateVideo() {
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
        video.identifier = "your-video-id"
        video.status = status
        video.snippet = snippet
        
        let query = GTLRYouTubeQuery_VideosUpdate.query(withObject: video, part: ["snippet","status"])
        youTubeService.executeQuery(query) { ticket, updatedVideo, ytError in
            if ytError == nil {
                print("Updated!")
            } else {
                print("Error: \(ytError)")
            }
        }
    }
    
    func insertComment() {
        let comment = GTLRYouTube_Comment()
        let snippet = GTLRYouTube_CommentSnippet()
        
        snippet.videoId = "your-video-id"
        snippet.textOriginal = "Hello there!"
        snippet.parentId = "comment-parent-id" //This property is only set if the comment was submitted as a reply to another comment.
        
        comment.snippet = snippet
    
        let query = GTLRYouTubeQuery_CommentsInsert.query(withObject: comment, part: ["id","snippet"])
        query.additionalHTTPHeaders = ["X-Ios-Bundle-Identifier" : getBundleId()]

        youTubeService.executeQuery(query) { ticket, _, ytError in
            if ytError == nil {
                print("Comment posted")
            } else {
                print("Yt error: \(String(describing: ytError?.localizedDescription))")
            }
        }

    }
    
}

extension YouTubeController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
//MARK: - Upload video helper methods
    
    //video picker helper methods
    private func openVideoPicker() {
        let videoPicker = UIImagePickerController()

        videoPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? [""]
        videoPicker.mediaTypes = ["public.movie"]
        videoPicker.videoQuality = .typeHigh

        videoPicker.delegate = self
        present(videoPicker, animated: true) {() -> Void in }
        videoPickerController = videoPicker
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let movieUrl = info[.mediaURL] as? URL else { return }
        
        queue.async {
            self.uploadVideoFile(locationURL: movieUrl)
        }
            dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func mimeTypeForPath(fileUrl: URL) -> String {
        
        let pathExtension = fileUrl.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}

extension YouTubeController {
//Helper method for getting the apps Bundle ID
    func getBundleId() -> String {
        var bundleIdentifier = Bundle.main.bundleIdentifier
        bundleIdentifier = bundleIdentifier?.trimmingCharacters(in: .whitespaces)
        if let bundleIdentifier = bundleIdentifier {
            return bundleIdentifier
        } else {
            return ""
        }
    }
}
