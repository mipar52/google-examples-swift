//
//  GoogleCalendarService.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 28.07.2025..
//

import Foundation
import GoogleAPIClientForREST_Calendar
import GoogleSignIn

struct GoogleCalendarService {
    private let calendarService = GTLRCalendarService()
    
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
            self.calendarService.additionalHTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
            
            // Or, get an object that conforms to GTMFetcherAuthorizationProtocol for
            // use with GTMAppAuth and the Google APIs client library.
            let authorizer = user.fetcherAuthorizer
            self.calendarService.authorizer = authorizer
        }
    }
    
    //Get your calendar info
    func getPrimaryCalendarInfo(completionHandler: @escaping (GTLRCalendar_Calendar?, Error?) -> Void) {
    
        let query = GTLRCalendarQuery_CalendarsGet.query(withCalendarId: Constants.calendarId)
        calendarService.executeQuery(query) { ticket, result, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                let calendar = result as! GTLRCalendar_Calendar
                completionHandler(calendar, nil)
                }
            }
        }
    
    //Get info of all subscribed calendars
    func getSubscribedCalendars(completionHandler: @escaping (String?) -> Void) {
        let calListquery = GTLRCalendarQuery_CalendarListList.query()
        calendarService.executeQuery(calListquery) { ticket, result, error in
            if error == nil {
                if let calendarList = result as? GTLRCalendar_CalendarList {
                    let calendars = calendarList.items
                    var calendarIds : [String] = []
                    if calendars!.count > 0 {
                        for calendar in calendars! {
                            calendarIds.append(calendar.summary!)
                        }
                        let calendarString = calendarIds.joined(separator: ", ")
                        completionHandler(calendarString)
                    }
                }
            } else {
                completionHandler(error?.localizedDescription)
            }
        }
    }
    
    // List the events you're attending
    func listEvents(completionHandler: @escaping (String?) -> Void) {

        let startDateTime = GTLRDateTime(date: Calendar.current.startOfDay(for: Date()))
        let endDateTime = GTLRDateTime(date: Date().addingTimeInterval(60 * 60 * 24))
        let eventsListQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: Constants.calendarId)
        eventsListQuery.timeMin = startDateTime
        eventsListQuery.timeMax = endDateTime

        calendarService.executeQuery(eventsListQuery, completionHandler: { (ticket, result, error) in
            if error != nil {
                completionHandler(error?.localizedDescription)
            } else {
                if let events = (result as? GTLRCalendar_Events)?.items {
                    var resultString = String()
                    events.forEach { event in
                        resultString +=
                        """
                        Name: \(String(describing: event.summary))
                        Location: \(String(describing: event.location))
                        Hangount link: \(String(describing: event.hangoutLink))
                        Attachment: \(String(describing: event.attachments?.first?.title))
                        """
                    }
                    completionHandler(resultString)
                }
            }
        })
    }
    
//Create a new event
    func createEvent(userEmail: String, participantEmail: String, startDate: Date, endDate: Date, summary: String, recurrenceRule: String, completionHandler: @escaping (String?) -> Void) {
        let event = GTLRCalendar_Event()
        
        print("Meeting start: \(startDate)\nMeeting end\(endDate)")
        event.summary = "Urgent meeting help"
        event.descriptionProperty = "Please come to my meeting"
        event.start = GTLRCalendar_EventDateTime()
        event.start!.dateTime = GTLRDateTime(rfc3339String: "2021-07-22T12:30:00+02:00")
        event.start!.timeZone = NSTimeZone.local.identifier
        event.end = GTLRCalendar_EventDateTime()
        event.end!.dateTime = GTLRDateTime(rfc3339String: "2021-07-22T14:00:00+02:00")
        event.end!.timeZone = NSTimeZone.local.identifier
        
        //event.conferenceData?.conferenceSolution = hangoutLink
        
        let attendee1 = GTLRCalendar_EventAttendee()
        let attendee2 = GTLRCalendar_EventAttendee()
             attendee1.email = userEmail
             attendee2.email = participantEmail
        event.attendees = [attendee1, attendee2]
        
        let insertQuery = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: Constants.calendarId)
         calendarService.executeQuery(insertQuery) { (ticket, event, error) in
                    if error != nil {
                        completionHandler(error?.localizedDescription)
                    } else {
                        if let createdEvent = event as? GTLRCalendar_Event {
                            let resultString =
                            """
                            Name: \(String(describing: createdEvent.summary))
                            Location: \(String(describing: createdEvent.location))
                            Attendee: \(String(describing: createdEvent.attendees?.first?.displayName))
                            Attachment: \(String(describing: createdEvent.attachments?.first?.title))
                            """
                            completionHandler(resultString)
                        }
                    }
                }
     }
    
    //Edit an already created event
    func editEvent (eventId: String, summary: String, completionHandler: @escaping (String?) -> Void) {
        let query = GTLRCalendarQuery_EventsGet.query(withCalendarId: Constants.calendarId, eventId: eventId)
        calendarService.executeQuery(query, completionHandler: { (ticket, event, error) -> Void in
            if let error = error {
                completionHandler(error.localizedDescription)
            } else {
                let event = event as! GTLRCalendar_Event
                    event.summary = summary
                let query = GTLRCalendarQuery_EventsUpdate.query(withObject: event, calendarId: Constants.calendarId, eventId: eventId)
                self.calendarService.executeQuery(query) { ticket, result, error in
                    if error != nil {
                        completionHandler(error?.localizedDescription)
                    } else {
                        if let changedEvent = result as? GTLRCalendar_Event {
                            let resultString =
                            """
                            Name: \(String(describing: changedEvent.summary))
                            Location: \(String(describing: changedEvent.location))
                            Attendee: \(String(describing: changedEvent.attendees?.first?.displayName))
                            Attachment: \(String(describing: changedEvent.attachments?.first?.title))
                            """
                            completionHandler(resultString)
                        }
                        
                    }
                }
            }
        })
    }
    
    //Delete an already created event
    func deleteEvent(eventId: String, completionHandler: @escaping (String) -> Void) {
        
        let query = GTLRCalendarQuery_EventsDelete.query(withCalendarId: Constants.calendarId, eventId: eventId)
        calendarService.executeQuery(query, completionHandler: { (ticket, event, error) -> Void in
            if let error = error {
                completionHandler(error.localizedDescription)
            } else {
                completionHandler("Event deleted")
            }
        })
    }
}
        
//MARK: Calendar methods
    
