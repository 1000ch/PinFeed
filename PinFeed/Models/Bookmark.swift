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

    var title: String = ""
    var tags: [String] = []
    var url: NSURL = NSURL.init()
    var date: NSDate = NSDate.init()
    var dateTime: String {
        get {
            return outputFormatter.stringFromDate(date);
        }
    }
    var author: String = ""
    var description: String = ""
    
    let inputFormatter = NSDateFormatter()
    let outputFormatter = NSDateFormatter()
    
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
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        outputFormatter.dateFormat = "yyyy/MM/dd HH:mm"

        if let title = title {
            self.title = title
        }
        
        if let tag = tag {
            self.tags = tag.componentsSeparatedByString(" ")
        }

        if let url = url {
            if let u = NSURL(string: url) {
                self.url = u
            }
        }
        
        if let dateTime = dateTime, date = inputFormatter.dateFromString(dateTime) {
            self.date = date
        }
        
        if let author = author {
            self.author = author
        }
        
        if let description = description {
            self.description = description
        }
    }
}