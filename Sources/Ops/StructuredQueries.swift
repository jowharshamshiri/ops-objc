import Foundation

/// A hierarchical table of contents entry.
public struct OutlineEntry: Sendable {
    public var title: String
    public var page: String?
    public var level: UInt8
    public var entryType: String?
    public var children: [OutlineEntry]

    public init(title: String, page: String? = nil, level: UInt8) {
        self.title = title
        self.page = page
        self.level = level
        self.entryType = nil
        self.children = []
    }

    public func withType(_ type: String) -> OutlineEntry {
        var copy = self
        copy.entryType = type
        return copy
    }

    public func withChildren(_ children: [OutlineEntry]) -> OutlineEntry {
        var copy = self
        copy.children = children
        return copy
    }

    public mutating func addChild(_ child: OutlineEntry) {
        children.append(child)
    }

    public func flatten() -> [FlatOutlineEntry] {
        var result: [FlatOutlineEntry] = []
        flattenRecursive(into: &result, path: [])
        return result
    }

    private func flattenRecursive(into result: inout [FlatOutlineEntry], path: [String]) {
        var newPath = path
        newPath.append(title)
        result.append(FlatOutlineEntry(
            title: title,
            page: page,
            level: level,
            entryType: entryType,
            path: newPath
        ))
        for child in children {
            child.flattenRecursive(into: &result, path: newPath)
        }
    }
}

/// A flattened representation with full hierarchical path.
public struct FlatOutlineEntry: Sendable {
    public let title: String
    public let page: String?
    public let level: UInt8
    public let entryType: String?
    public let path: [String]
}

/// Metadata about the table of contents structure.
public struct OutlineMetadata: Sendable {
    public var numberingStyle: String?
    public var hasLeaders: Bool
    public var pageStyle: String?
    public var totalEntries: Int
    public var levels: UInt8
    public var structureType: String?

    public init(
        numberingStyle: String? = nil,
        hasLeaders: Bool = false,
        pageStyle: String? = nil,
        totalEntries: Int = 0,
        levels: UInt8 = 0,
        structureType: String? = nil
    ) {
        self.numberingStyle = numberingStyle
        self.hasLeaders = hasLeaders
        self.pageStyle = pageStyle
        self.totalEntries = totalEntries
        self.levels = levels
        self.structureType = structureType
    }
}

/// Complete table of contents structure.
public struct ListingOutline: Sendable {
    public var documentTitle: String?
    public var entries: [OutlineEntry]
    public var confidence: Double
    public var metadata: OutlineMetadata

    public init() {
        self.documentTitle = nil
        self.entries = []
        self.confidence = 0.0
        self.metadata = OutlineMetadata()
    }

    public func flatten() -> [FlatOutlineEntry] {
        entries.flatMap { $0.flatten() }
    }

    public func entries(atLevel level: UInt8) -> [OutlineEntry] {
        func collect(from entries: [OutlineEntry], target: UInt8, into result: inout [OutlineEntry]) {
            for entry in entries {
                if entry.level == target {
                    result.append(entry)
                }
                collect(from: entry.children, target: target, into: &result)
            }
        }
        var result: [OutlineEntry] = []
        collect(from: entries, target: level, into: &result)
        return result
    }

    public var maxDepth: UInt8 {
        func depth(of entries: [OutlineEntry]) -> UInt8 {
            entries.map { entry in
                let childDepth = entry.children.isEmpty ? 0 : depth(of: entry.children)
                return max(entry.level, childDepth)
            }.max() ?? 0
        }
        return depth(of: entries)
    }
}

/// Generate JSON schema for the outline structure.
public func generateOutlineSchema() -> [String: Any] {
    return [
        "$schema": "http://json-schema.org/draft-07/schema#",
        "title": "Table of Contents",
        "description": "Hierarchical table of contents structure",
        "type": "object",
        "properties": [
            "document_title": ["type": ["string", "null"]],
            "entries": [
                "type": "array",
                "items": ["$ref": "#/definitions/OutlineEntry"]
            ],
            "confidence": [
                "type": "number",
                "minimum": 0.0,
                "maximum": 1.0
            ],
            "metadata": ["$ref": "#/definitions/OutlineMetadata"]
        ],
        "required": ["entries", "confidence"],
        "definitions": [
            "OutlineEntry": [
                "type": "object",
                "properties": [
                    "title": ["type": "string"],
                    "page": ["type": ["string", "null"]],
                    "level": ["type": "integer", "minimum": 0, "maximum": 10],
                    "entry_type": ["type": ["string", "null"]],
                    "children": ["type": "array"]
                ],
                "required": ["title", "level"]
            ],
            "OutlineMetadata": [
                "type": "object",
                "properties": [
                    "numbering_style": ["type": ["string", "null"]],
                    "has_leaders": ["type": "boolean"],
                    "page_style": ["type": ["string", "null"]],
                    "total_entries": ["type": "integer", "minimum": 0],
                    "levels": ["type": "integer", "minimum": 1, "maximum": 10],
                    "structure_type": ["type": ["string", "null"]]
                ],
                "required": ["has_leaders", "total_entries", "levels"]
            ]
        ]
    ] as [String: Any]
}
