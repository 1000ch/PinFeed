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
    let url: URL
    let date: Date
    let author: String
    let description: String
    
    var dateTime: String {
        return Date.formatter.string(from: date);
    }
    
    var relativeDateTime: String {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        
        guard let day = components.day else {
            return dateTime
        }

        guard let hour = components.hour else {
            return dateTime
        }

        guard let minute = components.minute else {
            return dateTime
        }
        
        if day == 0 {
            if hour == 0 {
                if minute == 1 {
                    return "a minute ago"
                }

                return "\(minute) minutes ago"
            } else if hour < 12 {
                if hour == 1 {
                    return "a hour ago"
                }
                
                return "\(hour) hours ago"
            }

            return "Today"
        }
        
        if day == 1 {
            return "Yesterday"
        }
        
        if day <= 7 {
            return "\(day) days ago"
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
        self.tags = tag?.components(separatedBy: " ") ?? []
        self.url = url.flatMap(URL.init) ?? URL(string: "https://apple.com")!
        self.date = dateTime.flatMap(Date.iso8601.date) ?? dateTime.flatMap(Date.formatter.date) ?? Date()
        self.author = author ?? ""
        self.description = description ?? ""
    }
}
