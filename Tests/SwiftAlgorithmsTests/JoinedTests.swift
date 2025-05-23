//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest

@testable import Algorithms

final class JoinedTests: XCTestCase {
  let stringArrays = [
    [],
    [""],
    ["", ""],
    ["foo"],
    ["foo", "bar"],
    ["", "", "foo", "", "bar", "baz", ""],
  ]

  func testJoined() {
    let expected = ["", "", "", "foo", "foobar", "foobarbaz"]

    for (strings, expected) in zip(stringArrays, expected) {
      // regular sequence
      expectEqualSequences(AnySequence(strings).joined(), expected)

      // lazy sequence
      expectEqualSequences(AnySequence(strings).lazy.joined(), expected)

      // regular collection
      expectEqualSequences(strings.joined(), expected)

      // lazy collection
      expectEqualSequences(
        strings.lazy.joined() as FlattenCollection, expected)
    }
  }

  func testJoinedByElement() {
    let separator: Character = " "
    let expected = ["", "", " ", "foo", "foo bar", "  foo  bar baz "]

    for (strings, expected) in zip(stringArrays, expected) {
      expectEqualSequences(
        AnySequence(strings).joined(by: separator), expected)
      expectEqualSequences(
        AnySequence(strings).lazy.joined(by: separator), expected)
      expectEqualSequences(strings.joined(by: separator), expected)
      expectEqualSequences(strings.lazy.joined(by: separator), expected)
    }
  }

  func testJoinedBySequence() {
    let separator = ", "
    let expected = ["", "", ", ", "foo", "foo, bar", ", , foo, , bar, baz, "]

    for (strings, expected) in zip(stringArrays, expected) {
      expectEqualSequences(
        AnySequence(strings).joined(by: separator), expected)
      expectEqualSequences(
        AnySequence(strings).lazy.joined(by: separator), expected)
      expectEqualSequences(strings.joined(by: separator), expected)
      expectEqualSequences(strings.lazy.joined(by: separator), expected)
    }
  }

  func testJoinedByElementClosure() {
    let separator = { (left: String, right: String) -> Character in
      left.isEmpty || right.isEmpty ? " " : "-"
    }

    let expected = ["", "", " ", "foo", "foo-bar", "  foo  bar-baz "]

    for (strings, expected) in zip(stringArrays, expected) {
      expectEqualSequences(
        AnySequence(strings).joined(by: separator), expected)
      expectEqualSequences(
        AnySequence(strings).lazy.joined(by: separator), expected)
      expectEqualSequences(strings.joined(by: separator), expected)
      expectEqualSequences(strings.lazy.joined(by: separator), expected)
    }
  }

  func testJoinedBySequenceClosure() {
    let separator = { (left: String, right: String) in
      "(\(left.count), \(right.count))"
    }

    let expected = [
      "",
      "",
      "(0, 0)",
      "foo",
      "foo(3, 3)bar",
      "(0, 0)(0, 3)foo(3, 0)(0, 3)bar(3, 3)baz(3, 0)",
    ]

    for (strings, expected) in zip(stringArrays, expected) {
      expectEqualSequences(
        AnySequence(strings).joined(by: separator), expected)
      expectEqualSequences(
        AnySequence(strings).lazy.joined(by: separator), expected)
      expectEqualSequences(strings.joined(by: separator), expected)
      expectEqualSequences(strings.lazy.joined(by: separator), expected)
    }
  }

  func testJoinedLazy() {
    requireLazySequence(AnySequence([[1], [2]]).lazy.joined())
    requireLazySequence(AnySequence([[1], [2]]).lazy.joined(by: 1))
    requireLazySequence(
      AnySequence([[1], [2]]).lazy.joined(by: { _, _ in 1 }))
    requireLazyCollection([[1], [2]].lazy.joined())
    requireLazyCollection([[1], [2]].lazy.joined(by: 1))
    requireLazyCollection([[1], [2]].lazy.joined(by: { _, _ in 1 }))
  }

  func testJoinedIndexTraversals() {
    let validator = IndexValidator<FlattenCollection<[String]>>()

    // the last test case takes too long to run
    for strings in stringArrays.dropLast() {
      validator.validate(strings.joined() as FlattenCollection)
    }
  }

  func testJoinedByIndexTraversals() {
    let validator1 = IndexValidator<JoinedByCollection<[String], String>>()
    let validator2 = IndexValidator<
      JoinedByClosureCollection<[String], String>
    >()

    // the last test case takes too long to run
    for (strings, separator) in product(
      stringArrays.dropLast(), ["", " ", ", "])
    {
      validator1.validate(strings.joined(by: separator))
      validator2.validate(strings.lazy.joined(by: { _, _ in separator }))
    }
  }
}
