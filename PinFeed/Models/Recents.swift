import RealmSwift

class Recents: Object {
    dynamic var d: String = ""
    dynamic var t: String = ""
    dynamic var u: String = ""
    dynamic var dt: String = ""
    dynamic var a: String = ""
    dynamic var n: String = ""
    
    convenience init(bookmark: Bookmark) {
        self.init()
        self.d = bookmark.title
        self.t = bookmark.tags.joinWithSeparator(" ")
        self.u = bookmark.url.absoluteString
        self.dt = bookmark.dateTime
        self.a = bookmark.author
        self.n = bookmark.description
    }
    
    convenience init(d: String?, t: String?, u: String?, dt: String?, a: String?, n: String?) {
        self.init()
        self.d = d ?? ""
        self.t = t ?? ""
        self.u = u ?? ""
        self.dt = dt ?? ""
        self.a = a ?? ""
        self.n = n ?? ""
    }
}