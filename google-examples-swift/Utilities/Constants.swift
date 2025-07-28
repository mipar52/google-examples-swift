//
//  Constants.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 27.07.2025..
//

import Foundation

struct Constants {
    static let additionalScopes = ["https://www.googleapis.com/auth/spreadsheets",
                                   "https://www.googleapis.com/auth/drive",
                                   "https://www.googleapis.com/auth/drive.file",
                                   "https://www.googleapis.com/auth/calendar",
                                   "https://www.googleapis.com/auth/youtube",
                                   "https://www.googleapis.com/auth/youtube.force-ssl",
                                   "https://www.googleapis.com/auth/youtube.upload",
                                   "https://www.googleapis.com/auth/youtubepartner"]
                                    //"https://www.googleapis.com/auth/youtube.readonly"]
    
    static let sheetID = "1Nm9NvZ0TOa_ifFTo7YSn1EG3eVg1O32m7QrsVeorMQQ"
    static let calendarId = "primary"
    static let youTubePlaylistId = "PLopY4n17t8RCflNiDpZcNKRmugF-W-S0o"
    static let bingingWithBabishPlaylist = "https://www.youtube.com/watch?v=1-i_7K02S14&list=PLopY4n17t8RCflNiDpZcNKRmugF-W-S0o"
}
