import Alamofire
import SwiftyJSON
import RealmSwift

class BookmarkManager {
    static let shared = BookmarkManager()
    
    var bookmark: [Bookmark] = []
    
    init() {
        autoreleasepool {
            let realm = try! Realm()
            
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
    }
    
    func fetch(group: DispatchGroup?) {
        group?.enter()

        Alamofire
            .request(PinboardURLProvider.bookmark ?? "")
            .responseJSON(queue: .global()) { response in
                guard let data = response.result.value else {
                    group?.leave()
                    return
                }
                
                self.bookmark.removeAll()
                
                JSON(data).forEach { (_, json) in
                    self.bookmark.append(Bookmark(json: json))
                }
                
                group?.leave()
            }
    }
    
    func sync() {
        autoreleasepool {
            let realm = try! Realm()
            
            try! realm.write {
                realm.delete(realm.objects(Bookmarks.self))
                for bookmark in self.bookmark {
                    realm.add(Bookmarks(bookmark: bookmark))
                }
            }
        }
    }
    
    func clear() {
        autoreleasepool {
            let realm = try! Realm()

            try! realm.write {
                realm.delete(realm.objects(Bookmarks.self))
            }
        }
    }
}
