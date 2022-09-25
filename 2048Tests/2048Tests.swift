//
//  2048Tests.swift
//  2048Tests
//
//  Created by Alikhan on 25.09.2022.
//

import XCTest
@testable import _048

class _2048Tests: XCTestCase {
    private var sut: Game!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
    }
    
    func testMoveLeft() {
        let givenTilePowers = [
            [1, nil, nil, nil],
            [1, nil, 2, nil],
            [1, nil, nil, nil],
            [1, nil, 2, nil],
        ]
        
        sut = Game(
            tileNumbers: givenTilePowers
        )
        
        sut.move(.left)
        let expectedTilePowers = [
            [1, nil, nil, nil],
            [1, 2, nil, nil],
            [1, nil, nil, nil],
            [1, 2, nil, nil],
        ]
        
        XCTAssertTrue(tilesMatch(with: expectedTilePowers))
    }
    
    func testMoveUp() {
        let givenTilePowers = [
            [1, nil, nil, nil],
            [1, nil, 2, nil],
            [1, nil, nil, nil],
            [1, nil, 2, nil],
        ]
        
        sut = Game(
            tileNumbers: givenTilePowers
        )
        
        sut.move(.up)
        let expectedTilePowers = [
            [2, nil, 3, nil],
            [2, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
        ]
        
        XCTAssertTrue(tilesMatch(with: expectedTilePowers))
    }
    
    func testMoveRight() {
        let givenTilePowers = [
            [1, nil, nil, nil],
            [1, nil, 2, nil],
            [1, nil, nil, nil],
            [1, nil, 2, nil],
        ]
        
        sut = Game(
            tileNumbers: givenTilePowers
        )
        
        sut.move(.right)
        let expectedTilePowers = [
            [nil, nil, nil, 1],
            [nil, nil, 1, 2],
            [nil, nil, nil, 1],
            [nil, nil, 1, 2],
        ]
        
        XCTAssertTrue(tilesMatch(with: expectedTilePowers))
    }
    
    func testMoveDown() {
        let givenTilePowers = [
            [1, nil, nil, nil],
            [1, nil, 2, nil],
            [1, nil, nil, nil],
            [1, nil, 2, nil],
        ]
        
        sut = Game(
            tileNumbers: givenTilePowers
        )
        
        sut.move(.down)
        let expectedTilePowers = [
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [2, nil, nil, nil],
            [2, nil, 3, nil],
        ]
        
        XCTAssertTrue(tilesMatch(with: expectedTilePowers))
    }
    
    func tilesMatch(with expectedTilePowers: [[Int?]]) -> Bool {
        var mismatchCount = 0
        
        for i in sut.tileNumbers.indices {
            for j in sut.tileNumbers[i].indices {
                if sut.tileNumbers[i][j] != expectedTilePowers[i][j] {
                    mismatchCount += 1
                }
            }
        }
        return mismatchCount <= 1
    }
}
