//
//  CalendarController.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 21.07.2021..
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class CalendarController: UIViewController {
    
    let calendarService = GTLRCalendarService()
    let utils = Utils()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarService.apiKey = K.apiKey
        calendarService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
    }
    
    @IBAction func primaryCalendarInfoPressed(_ sender: UIButton) {
        getPrimaryCalendarInfo { calendar, error in
            if error == nil {
                let id = calendar?.identifier
                //let location = calendar?.location
                self.utils.showAlert(title: "Primary calendar info", message: "Got primary calendar info:\nID: \(id!)", vc: self)
            } else {
                self.utils.showAlert(title: "Error", message: "Error in getting primary calendar info:\n\(error?.localizedDescription)", vc: self)
            }
        }
    }
    
    @IBAction func subscribedCalendarsPressed(_ sender: UIButton) {
        getSubscribedCalendars { calendarList, error in
            if error == nil {
                let calendars = calendarList?.items
                var calendarIds : [String] = []
                if calendars!.count > 0 {
                    for calendar in calendars! {
                        calendarIds.append(calendar.summary!)
                    }
                    let calendarString = calendarIds.joined(separator: ", ")
                    self.utils.showAlert(title: "Subscribed calendars", message: calendarString, vc: self)
                }
            } else {
                self.utils.showAlert(title: "Error", message: error!.localizedDescription, vc: self)
            }
        }
    }
    
    @IBAction func listEventsPressed(_ sender: UIButton) {
        listEvents { events, error in
            if error == nil {
                let events = events
                var eventArray : [String] = []
                for event in events! {
                    eventArray.append(event.summary!)
                }
                let joinedEvents = eventArray.joined(separator: ", ")
                self.utils.showAlert(title: "Events", message: joinedEvents, vc: self)
            } else {
                self.utils.showAlert(title: "Error", message: error!.localizedDescription, vc: self)
            }
        }
    }
    
    @IBAction func createEventPressed(_ sender: UIButton) {
        createEvent(userEmail: "your-email", participantEmail: "attendee-email", startDate: Date(), endDate: Date(), summary: "Urgent meeting", recurrenceRule: "") { createdEvent, error in
            if error == nil {
                let summary = createdEvent?.summary
                self.utils.showAlert(title: "Event created", message: "Created event: \(summary!)", vc: self)
            } else {
                self.utils.showAlert(title: "Error", message: error!.localizedDescription, vc: self)
            }
        }
    }
    
    @IBAction func editEventPressed(_ sender: UIButton) {
        editEvent(eventId: "event-id", summary: "Changed summary") { changedEvent, error in
            if error == nil {
                let changedSummary = changedEvent?.summary
                self.utils.showAlert(title: "Event changed", message: "Changed event with summary: \(changedSummary!)", vc: self)
            } else {
                self.utils.showAlert(title: "Error", message: error!.localizedDescription, vc: self)
            }
        }
    }
    
    @IBAction func deleteEventPressed(_ sender: UIButton) {
        deleteEvent(eventId: "event-id") { string in
            self.utils.showAlert(title: "", message: string, vc: self)
        }
    }
}
    extension CalendarController {
        
//MARK: Calendar methods
    
    //Get your calendar info
    func getPrimaryCalendarInfo(completionHandler: @escaping (GTLRCalendar_Calendar?, Error?) -> Void) {
    
        let query = GTLRCalendarQuery_CalendarsGet.query(withCalendarId: K.calendarId)
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
    func getSubscribedCalendars(completionHandler: @escaping (GTLRCalendar_CalendarList?, Error?) -> Void) {
        let nesto = GTLRCalendarQuery_CalendarListList.query()
        calendarService.executeQuery(nesto) { ticket, result, error in
            if error != nil {
                completionHandler(nil, error)
            } else {
                let calendarList = result as! GTLRCalendar_CalendarList
                completionHandler(calendarList, nil)
            }
        }
    }
    
//List the events you're attending
    func listEvents(completionHandler: @escaping ([GTLRCalendar_Event]?, Error?) -> Void) {

        let startDateTime = GTLRDateTime(date: Calendar.current.startOfDay(for: Date()))
        let endDateTime = GTLRDateTime(date: Date().addingTimeInterval(60*60*24))
        let eventsListQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: K.calendarId)
        eventsListQuery.timeMin = startDateTime
        eventsListQuery.timeMax = endDateTime

        calendarService.executeQuery(eventsListQuery, completionHandler: { (ticket, result, error) in
            if error != nil {
                completionHandler(nil, error)
            } else {
                let events = (result as? GTLRCalendar_Events)?.items
                completionHandler(events, nil)
            }
        })
    }
    
//Create a new event
    func createEvent(userEmail: String, participantEmail: String, startDate: Date, endDate: Date, summary: String, recurrenceRule: String, completionHandler: @escaping (GTLRCalendar_Event?, Error?) -> Void) {
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
        
        let insertQuery = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: K.calendarId)
         calendarService.executeQuery(insertQuery) { (ticket, object, error) in
                    if error != nil {
                        completionHandler(nil, error)
                    } else {
                        let createdEvent = object as! GTLRCalendar_Event
                        completionHandler(createdEvent, nil)
                    }
                }
     }
//Edit an already created event
    func editEvent (eventId: String, summary: String, completionHandler: @escaping (GTLRCalendar_Event?, Error?) -> Void) {
        let query = GTLRCalendarQuery_EventsGet.query(withCalendarId: K.calendarId, eventId: eventId)
        calendarService.executeQuery(query, completionHandler: { (ticket, event, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else {
                let event = event as! GTLRCalendar_Event
                    event.summary = summary
                let query = GTLRCalendarQuery_EventsUpdate.query(withObject: event, calendarId: K.calendarId, eventId: eventId)
                self.calendarService.executeQuery(query) { ticket, result, error in
                    if error != nil {
                        completionHandler(nil, error)
                    } else {
                        let changedEvent = result as! GTLRCalendar_Event
                        completionHandler(changedEvent, nil)
                    }
                }
            }
        })
    }
 //Delete an already created event
    func deleteEvent(eventId: String, completionHandler: @escaping (String) -> Void) {
        
        let query = GTLRCalendarQuery_EventsDelete.query(withCalendarId: K.calendarId, eventId: eventId)
        calendarService.executeQuery(query, completionHandler: { (ticket, event, error) -> Void in
            if let error = error {
                completionHandler(error.localizedDescription)
            } else {
                completionHandler("Event deleted")
            }
        })
    }
}
