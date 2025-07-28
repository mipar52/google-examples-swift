//
//  CalendarView.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 28.07.2025..
//

import SwiftUI

struct CalendarView: View {
    private let calendarService = GoogleCalendarService()
    @State private var presentAlert: Bool = false
    @State private var alertMessage: String = ""
    var body: some View {
        VStack {
            
            Button {
                calendarService.getPrimaryCalendarInfo { calendar, error in
                    if (error == nil) {
                        alertMessage =
                    """
                    Calendar title: \(String(describing: calendar?.summary))
                    \nCalendar location: \(String(describing: calendar?.timeZone))
                    \nCalendar timezone: \(String(describing: calendar?.timeZone))
                    """
                    } else {
                        alertMessage = "Error fetching calendar info: \(error!.localizedDescription)"
                    }
                    presentAlert.toggle()
                }
            } label: {
                Text("Get info about your primary calendar")
            }
            
            Button {
                calendarService.getSubscribedCalendars { successString in
                    alertMessage = successString ?? "No subscribed calendars"
                    presentAlert.toggle()
                }
            } label: {
                Text("Get subsribed calendars")
            }
            
            Button {
                calendarService.listEvents { successString in
                    alertMessage = successString ?? "Did not find any events!"
                    presentAlert.toggle()
                }
            } label: {
                Text("List all events in primary calendar")
            }
            
            Button {
                calendarService.createEvent(userEmail: "your-email", participantEmail: "attendee-email", startDate: Date(), endDate: Date(), summary: "Urgent meeting", recurrenceRule: "") { successString in
                    alertMessage = successString ?? ""
                    presentAlert.toggle()
                }
            } label: {
                Text("Create an event in your calendar")
            }
            
            Button {
                calendarService.editEvent(eventId: "event-id", summary: "SUPER important meeting") { successString in
                    alertMessage = successString ?? ""
                    presentAlert.toggle()
                }
            } label: {
                Text("Edit an event in your calendar")
            }
            
            Button {
                calendarService.deleteEvent(eventId: "event-id") { successString in
                    alertMessage = successString
                    presentAlert.toggle()
                }
            } label: {
                Text("Delete an event in your calendar")
            }
        }
        .onAppear {
            calendarService.fetchAuthorization()
        }
        .alert("Google Calendar API result",
               isPresented: $presentAlert,
               actions: {},
               message: {
                    Text(alertMessage)
                })
    }
}

#Preview {
    CalendarView()
}
