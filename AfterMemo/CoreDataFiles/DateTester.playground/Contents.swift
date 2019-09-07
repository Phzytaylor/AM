import UIKit

// The user's calendar incorporates the user's locale and
// time zone settings, which means it's the one you'll use
// most often.
let userCalendar = Calendar.current
//
//// Let's create a Date for the start of the Stevenote
//// where the iPhone was introduced (January 9, 2007, 10:00:00 Pacific time)
//// using DateComponents.
var iPhoneStevenoteDateComponents = DateComponents()
iPhoneStevenoteDateComponents.year = 2003
iPhoneStevenoteDateComponents.month = 6
iPhoneStevenoteDateComponents.day = 1
iPhoneStevenoteDateComponents.hour = 10
iPhoneStevenoteDateComponents.timeZone = TimeZone(abbreviation: "PST")
let iPhoneStevenoteDate = userCalendar.date(from: iPhoneStevenoteDateComponents)!
//
//// Let's create a Date for the start of the Stevenote
//// where the iPad was introduced (January 27, 2010, 10:00:00 Pacific time)
//// using DateFormatter.
//var dateMakerFormatter = DateFormatter()
//dateMakerFormatter.calendar = userCalendar
//dateMakerFormatter.dateFormat = "MMM d, yyyy, hh:mm a zz"
//let iPadStevenoteDate = dateMakerFormatter.date(from: "June 1, 2018, 10:00 AM PST")!
//
//// (Previous code goes here)
//
//// The result in the sidebar should be:
//// year: 3 month: 0 day: 18 hour: 0 minute: 0 isLeapMonth: false
//let yearsMonthsDaysHoursMinutesBetweenStevenotes = userCalendar.dateComponents([.year,.month],
//                                                                               from: iPhoneStevenoteDate,
//                                                                               to: Date())
//
//yearsMonthsDaysHoursMinutesBetweenStevenotes.year   // 0


let dateComponentsFormatter = DateComponentsFormatter()
let calendar = Calendar.current

let date1 = calendar.startOfDay(for: Date())
let date2 = calendar.startOfDay(for: iPhoneStevenoteDate)

let components = calendar.dateComponents([.year], from: date2, to: date1)
//guard let monthsAway = components.month else {
//    continue
//}
