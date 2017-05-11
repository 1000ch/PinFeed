import Alamofire
import SwiftyJSON
import RealmSwift

class TimelineManager {
    static let shared = TimelineManager()
    
    var timeline: [Bookmark] = []
    
    init() {
        autoreleasepool {
            let realm = try! Realm()

            for recent in realm.objects(Recents.self) {
                timeline.append(Bookmark(
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
            .request(PinboardURLProvider.network ?? "")
            .responseJSON(queue: .global()) { response in
                guard let data = response.result.value else {
                    group?.leave()
                    return
                }
                
                self.timeline.removeAll()
                
                JSON(data).forEach { (_, json) in
                    self.timeline.append(Bookmark(json: json))
                }
                
                group?.leave()
        }
    }
    
    func sync() {
        autoreleasepool {
            let realm = try! Realm()
            
            try! realm.write {
                realm.delete(realm.objects(Recents.self))
                
                for timeline in self.timeline {
                    realm.add(Recents(bookmark: timeline))
                }
            }
        }
    }
    
    func clear() {
        autoreleasepool {
            let realm = try! Realm()
            
            try! realm.write {
                realm.delete(realm.objects(Recents.self))
            }
        }
    }
}
