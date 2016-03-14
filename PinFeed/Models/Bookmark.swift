import SwiftyJSON

class Bookmark {
    enum Item: String {
        case Title = "d"
        case Tag = "t"
        case URL = "u"
        case DateTime = "dt"
        case Author = "a"
        case Description = "n"
    }

    var title: String
    var tags: [String]
    var url: NSURL
    var date: NSDate
    var dateTime: String {
        return outputFormatter.stringFromDate(date);
    }
    var author: String
    var description: String
    
    let inputFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    let outputFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()
    
    convenience init(json: JSON) {
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

        if let url = url, u = NSURL(string: url) {
            self.url = u
        } else {
            self.url = NSURL()
        }
        
        if let dateTime = dateTime, date = inputFormatter.dateFromString(dateTime) {
            self.date = date
        } else {
            self.date = NSDate()
        }
        
        self.author = author ?? ""
        self.description = description ?? ""
    }
}