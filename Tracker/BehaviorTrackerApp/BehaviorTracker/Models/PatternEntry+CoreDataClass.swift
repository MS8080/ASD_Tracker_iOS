import Foundation
import CoreData

@objc(PatternEntry)
public class PatternEntry: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var category: String
    @NSManaged public var patternType: String
    @NSManaged public var intensity: Int16
    @NSManaged public var duration: Int32
    @NSManaged public var contextNotes: String?
    @NSManaged public var specificDetails: String?
    @NSManaged public var customPatternName: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var tags: NSSet?

    var patternCategoryEnum: PatternCategory? {
        PatternCategory(rawValue: category)
    }

    var patternTypeEnum: PatternType? {
        PatternType(rawValue: patternType)
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
        self.timestamp = Date()
        self.isFavorite = false
    }
    
    func configure(patternType: PatternType,
                   intensity: Int16 = 0,
                   duration: Int32 = 0,
                   contextNotes: String? = nil,
                   specificDetails: String? = nil) {
        self.category = patternType.category.rawValue
        self.patternType = patternType.rawValue
        self.intensity = intensity
        self.duration = duration
        self.contextNotes = contextNotes
        self.specificDetails = specificDetails
    }
}

extension PatternEntry {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}
