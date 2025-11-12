import Foundation
import CoreData

@objc(Tag)
public class Tag: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var entries: NSSet?

    convenience init(context: NSManagedObjectContext, name: String) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
    }
}

extension Tag {
    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: PatternEntry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: PatternEntry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)
}
