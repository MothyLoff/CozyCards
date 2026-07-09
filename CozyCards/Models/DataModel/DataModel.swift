import Observation



@Observable
@MainActor
final class DataModel {
    
    
    public private(set) var chats: [ChatEntity] = []
    

    public init() { }
    
    
}
