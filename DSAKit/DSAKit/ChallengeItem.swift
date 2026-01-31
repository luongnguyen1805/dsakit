//
//  DSAKit
//
//  Created by admin on 1/23/26.
//

import Foundation
import SwiftData

@Model
final class ChallengeItem: Equatable {
    
    static func == (lhs: ChallengeItem, rhs: ChallengeItem) -> Bool {
        lhs.challegeId == rhs.challegeId
    }

    var challegeId: String
    var title: String
    var url: String
    var src: String
    var timestamp: Date
    
    init(challegeId: String, title: String, url: String, src: String, timestamp: Date) {
        self.challegeId = challegeId
        self.title = title
        self.url = url
        self.src = src
        
        self.timestamp = timestamp
    }
    
}
