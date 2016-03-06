import Foundation

class AsyncDispatcher {
    static func main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    static func global(block: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
    }
}