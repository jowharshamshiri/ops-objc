import XCTest
@testable import Ops

final class StructuredQueriesTests: XCTestCase {

    // TEST024: Build a flat ListingOutline with depth-0 entries and verify maxDepth, levels, and flatten count
    func test_024_simple_flat_outline() {
        var outline = ListingOutline()
        outline.entries = [
            OutlineEntry(title: "Introduction", page: "1", level: 0),
            OutlineEntry(title: "Chapter 1: Getting Started", page: "5", level: 0),
            OutlineEntry(title: "Chapter 2: Advanced Topics", page: "15", level: 0),
            OutlineEntry(title: "Conclusion", page: "25", level: 0),
        ]

        XCTAssertEqual(outline.maxDepth, 0)
        XCTAssertEqual(outline.entries(atLevel: 0).count, 4)
        XCTAssertEqual(outline.flatten().count, 4)
    }

    // TEST025: Build a two-level outline with chapters and sections and verify depth, level counts, and flatten
    func test_025_hierarchical_outline() {
        var outline = ListingOutline()

        var chapter1 = OutlineEntry(title: "Chapter 1: Basics", page: "10", level: 0)
            .withType("chapter")
        chapter1.addChild(OutlineEntry(title: "1.1 Introduction", page: "10", level: 1))
        chapter1.addChild(OutlineEntry(title: "1.2 Fundamentals", page: "15", level: 1))

        var chapter2 = OutlineEntry(title: "Chapter 2: Advanced", page: "20", level: 0)
            .withType("chapter")
        chapter2.addChild(OutlineEntry(title: "2.1 Complex Topics", page: "20", level: 1))

        outline.entries = [chapter1, chapter2]

        XCTAssertEqual(outline.maxDepth, 1)
        XCTAssertEqual(outline.entries(atLevel: 0).count, 2)
        XCTAssertEqual(outline.entries(atLevel: 1).count, 3)
        XCTAssertEqual(outline.flatten().count, 5)
    }

    // TEST026: Build a three-level part/chapter/section outline and verify depth and per-level entry counts
    func test_026_complex_part_based_outline() {
        var outline = ListingOutline()

        var part1 = OutlineEntry(title: "Part I: Foundations", page: "1", level: 0)
            .withType("part")

        var chapter1 = OutlineEntry(title: "Chapter 1: Introduction", page: "3", level: 1)
            .withType("chapter")
        chapter1.addChild(OutlineEntry(title: "1.1 Overview", page: "3", level: 2))
        chapter1.addChild(OutlineEntry(title: "1.2 Scope", page: "5", level: 2))

        let chapter2 = OutlineEntry(title: "Chapter 2: Background", page: "8", level: 1)
            .withType("chapter")

        part1.addChild(chapter1)
        part1.addChild(chapter2)

        let part2 = OutlineEntry(title: "Part II: Applications", page: "15", level: 0)
            .withType("part")

        outline.entries = [part1, part2]

        XCTAssertEqual(outline.maxDepth, 2)
        XCTAssertEqual(outline.entries(atLevel: 0).count, 2)
        XCTAssertEqual(outline.entries(atLevel: 1).count, 2)
        XCTAssertEqual(outline.entries(atLevel: 2).count, 2)
        XCTAssertEqual(outline.flatten().count, 6)
    }

    // TEST027: Flatten a nested outline and verify each entry's path reflects its ancestry correctly
    func test_027_flatten_preserves_hierarchy() {
        var outline = ListingOutline()

        var part = OutlineEntry(title: "Part I", page: "1", level: 0)
        var chapter = OutlineEntry(title: "Chapter 1", page: "3", level: 1)
        chapter.addChild(OutlineEntry(title: "Section 1.1", page: "3", level: 2))
        part.addChild(chapter)
        outline.entries = [part]

        let flat = outline.flatten()
        XCTAssertEqual(flat.count, 3)
        XCTAssertEqual(flat[0].path, ["Part I"])
        XCTAssertEqual(flat[1].path, ["Part I", "Chapter 1"])
        XCTAssertEqual(flat[2].path, ["Part I", "Chapter 1", "Section 1.1"])
    }

    // TEST028: Call generateOutlineSchema and verify the returned dictionary contains all required definitions
    func test_028_schema_generation() {
        let schema = generateOutlineSchema()
        XCTAssertNotNil(schema["properties"])
        let defs = schema["definitions"] as? [String: Any]
        XCTAssertNotNil(defs?["OutlineEntry"])
        XCTAssertNotNil(defs?["OutlineMetadata"])
    }
}
