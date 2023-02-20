//
//  Constants.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 07.11.2021..
//

import Foundation

public struct K {
    static let clientID = "221523093975-3e37h6unj358l6oid9dn7uhppoi6pdi9.apps.googleusercontent.com"
    static let apiKey = "AIzaSyDvU-dCjHmT2CoZVou2uZL0yGhaXxJVDiE"
    
    static let grantedScopes = "https://www.googleapis.com/auth/spreadsheets"
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

}
