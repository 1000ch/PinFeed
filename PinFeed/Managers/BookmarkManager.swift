import Alamofire
import SwiftyJSON
import RealmSwift

class BookmarkManager {
    class var sharedInstance: BookmarkManager {
        struct Static {
            static let instance = BookmarkManager()
        }
        return Static.instance
    }

    private let realm = try! Realm()
    
    var bookmark: [Bookmark] = []
    
    init() {
        for recent in realm.objects(Bookmarks.self) {
            bookmark.append(Bookmark(
                title: recent.d,
                tag: recent.t,
                url: recent.u,
                dateTime: recent.dt,
                author: recent.a,
                description: recent.n
            ))
        }
    }
    
    func fetch(block: (() -> ())?) {
        Alamofire
            .request(PinboardURLProvider.bookmark ?? "")
            .responseJSON { response in
                guard let data = response.result.value else {
                    block?()
                    return
                }
                
                self.bookmark.removeAll()
                
                JSON(data).forEach { (_, json) in
                    self.bookmark.append(Bookmark(json: json))
                }
                
                block?()

                try! self.realm.write {
                    self.realm.delete(self.realm.objects(Bookmarks.self))
                    for bookmark in self.bookmark {
                        self.realm.add(Bookmarks(bookmark: bookmark))
                    }
                }
        }
    }
    
    func clear(block: @escaping () -> ()) {
        DispatchQueue.global().async {
            try! self.realm.write {
                self.realm.delete(self.realm.objects(Bookmarks.self))
            }
            
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
