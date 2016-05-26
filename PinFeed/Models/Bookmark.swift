import SwiftyJSON

struct Bookmark {
    enum Item: String {
        case Title = "d"
        case Tag = "t"
        case URL = "u"
        case DateTime = "dt"
        case Author = "a"
        case Description = "n"
    }

    let title: String
    let tags: [String]
    let url: NSURL
    let date: NSDate
    let author: String
    let description: String
    
    var dateTime: String {
        return NSDate.outputFormatter.stringFromDate(date);
    }
    
    var relativeDateTime: String {
        let calendar = NSCalendar.currentCalendar()
        calendar.locale = NSLocale.currentLocale()
        let now = NSDate()
        let options = NSCalendarOptions()

        let components = calendar.components([.Day, .Hour, .Minute], fromDate: date, toDate: now, options: options)
        
        if components.day == 0 {
            if components.hour == 0 {
                if components.minute == 1 {
                    return "a minute ago"
                }

                return "\(components.minute) minutes ago"
            } else if components.hour < 12 {
                if components.hour == 1 {
                    return "a hour ago"
                }
                
                return "\(components.hour) hours ago"
            }

            return "Today"
        }
        
        if components.day == 1 {
            return "Yesterday"
        }
        
        if components.day <= 7 {
            return "\(components.day) days ago"
        }

        return dateTime
    }
    
    init(json: JSON) {
        self.init(
            title: json[Item.Title.rawValue].string,
            tag: json[Item.Tag.rawValue].string,
            url: json[Item.URL.rawValue].string,
            dateTime: json[Item.DateTime.rawValue].string,
            author: json[Item.Author.rawValue].string,
            description: json[Item.Description.rawValue].string
        )
    }
    
    init(title: String?, tag: String?, url: String?, dateTime: String?, author: String?, description: String?) {
        self.title = title ?? ""
        self.tags = tag?.componentsSeparatedByString(" ") ?? []
        self.url = url.flatMap(NSURL.init) ?? NSURL()
        self.date = dateTime.flatMap(NSDate.inputFormatter.dateFromString) ?? NSDate()
        self.author = author ?? ""
        self.description = description ?? ""
    }
}