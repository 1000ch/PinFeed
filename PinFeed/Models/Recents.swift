import RealmSwift

class Recents: Object {
    @objc dynamic var d: String = ""
    @objc dynamic var t: String = ""
    @objc dynamic var u: String = ""
    @objc dynamic var dt: String = ""
    @objc dynamic var a: String = ""
    @objc dynamic var n: String = ""
    
    convenience init(bookmark: Bookmark) {
        self.init()
        self.d = bookmark.title
        self.t = bookmark.tags.joined(separator: " ")
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
