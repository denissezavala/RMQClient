import XCTest

class AMQEncodingTest: XCTestCase {

    func testFraming() {
        let encoder = AMQEncoder()
        
        let type = "\u{01}"
        let channel = "\u{00}\u{00}"
        let size = "\u{00}\u{00}\u{00}\u{08}"
        let classID = "\u{00}\u{0A}"
        let methodID = "\u{00}\u{0B}"
        let payload = "\u{03}foo"
        let unfinishedFrame = "\(type)\(channel)\(size)\(classID)\(methodID)\(payload)".dataUsingEncoding(NSUTF8StringEncoding)!
        var frameEnd = 0xce
        let expectedFrame = unfinishedFrame.mutableCopy() as! NSMutableData
        expectedFrame.appendBytes(&frameEnd, length: 1)

        encoder.encodeObject(["type" : "short-string", "value" : "foo"], forKey: "baz")
        let frame: NSData = encoder.frameForClassID(10, methodID: 11)
        TestHelper.assertEqualBytes(expectedFrame, actual: frame)
    }
    
    func testLongStringBecomesLengthPlusChars() {
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        let a = [0x00, 0x00, 0x00, 0x07]
        for var b in a {
            expectedData.appendBytes(&b, length: 1)
        }
        
        expectedData.appendData("abcdefg".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        let longString = [
            "type": "long-string",
            "value": "abcdefg",
        ]
        
        encoder.encodeObject(longString, forKey: "foo")
        XCTAssertEqual(expectedData, encoder.data)
    }
    
    func testShortStringBecomesLengthPlusChars() {
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        var a = 0x07
        expectedData.appendBytes(&a, length: 1)
        
        expectedData.appendData("abcdefg".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        let shortString = [
            "type": "short-string",
            "value": "abcdefg",
        ]
        
        encoder.encodeObject(shortString, forKey: "foo")
        XCTAssertEqual(expectedData, encoder.data)
    }
    
    func testShortBecomesTwoBytes () {
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        expectedData.appendData("\u{00}\u{05}".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        let short = ["type": "short", "value": 5]
        
        encoder.encodeObject(short, forKey: "foo")
        TestHelper.assertEqualBytes(expectedData, actual: encoder.data)
    }
    
    func testLongBecomesFourBytes () {
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        expectedData.appendData("\u{00}\u{00}\u{00}\u{05}".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        let long = ["type": "long", "value": 5]
        
        encoder.encodeObject(long, forKey: "foo")
        TestHelper.assertEqualBytes(expectedData, actual: encoder.data)
    }
    
    func testAppend() {
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        
        var shortLength = 0x03
        expectedData.appendBytes(&shortLength, length: 1)
        expectedData.appendData("abc".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        let a = [0x00, 0x00, 0x00, 0x04]
        for var b in a {
            expectedData.appendBytes(&b, length: 1)
        }
        expectedData.appendData("defg".dataUsingEncoding(NSASCIIStringEncoding)!)
        
        let shortString = [
            "type": "short-string",
            "value": "abc",
        ]
        let longString = [
            "type": "long-string",
            "value": "defg",
        ]
        
        encoder.encodeObject(shortString, forKey: "foo")
        encoder.encodeObject(longString, forKey: "bar")
        XCTAssertEqual(expectedData, encoder.data)
    }
    
    func testTrueBecomesOne(){
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        
        var trueVal = 0x01
        expectedData.appendBytes(&trueVal, length: 1)
        
        let boolType = [
            "type" : "boolean",
            "value" : true,
        ]
        
        encoder.encodeObject(boolType, forKey: "foo")
        XCTAssertEqual(expectedData, encoder.data)
    }
    
    func testFalseBecomesZero() {
        let encoder = AMQEncoder()
        
        let expectedData = NSMutableData()
        
        var falseVal = 0x00
        expectedData.appendBytes(&falseVal, length: 1)
        
        let boolType = [
            "type" : "boolean",
            "value" : false,
        ]
        
        encoder.encodeObject(boolType, forKey: "foo")
        XCTAssertEqual(expectedData, encoder.data)
    }
    
    func testClass10Method11ResponseIsEncodedAsCredentialsRFC2595() {
        let encoder = AMQEncoder()
        let credentials = AMQCredentials(username: "fido🔫﷽", password: "2easy2break📵")
        encoder.encodeObject(credentials, forKey: "10_11_response")
        let expectedData = "\u{00}\u{00}\u{00}\u{1c}\u{00}fido🔫﷽\u{00}2easy2break📵".dataUsingEncoding(NSUTF8StringEncoding)
        TestHelper.assertEqualBytes(expectedData!, actual: encoder.data)
    }
    
    func testFieldTableBecomesSeriesOfKeyValues() {
        let encoder = AMQEncoder()
        let fieldTableLength             = "\u{00}\u{00}\u{00}\u{57}"
        let cats                         = "\u{08}has_catst\u{01}"
        let dogs                         = "\u{08}has_dogst\u{00}"
        let massHysteriaKeyLength        = "\u{0D}"
        let massHysteriaTableLength      = "\u{00}\u{00}\u{00}\u{08}"
        let ghost                        = "\u{05}ghostt\u{00}"
        let sacrifice                    = "\u{09}sacrificeS\u{00}\u{00}\u{00}\u{17}forty years of darkness"
        
        let massHysteria = "\(massHysteriaKeyLength)mass_hysteriaF\(massHysteriaTableLength)\(ghost)"
        let fieldPairs = "\(cats)\(dogs)\(massHysteria)\(sacrifice)"
        let expectedData = "\(fieldTableLength)\(fieldPairs)".dataUsingEncoding(NSUTF8StringEncoding)
        
        let fieldTableType = [
            "type" : "field-table",
            "value" : [
                "has_cats": ["type": "boolean", "value": true],
                "has_dogs": ["type": "boolean", "value": false],
                "mass_hysteria": [
                    "type": "field-table",
                    "value": [
                        "ghost": ["type": "boolean", "value": false],
                    ]
                ],
                "sacrifice": ["type": "long-string", "value": "forty years of darkness"]
            ]
        ]
        
        encoder.encodeObject(fieldTableType, forKey: "murray")
        TestHelper.assertEqualBytes(expectedData!, actual: encoder.data)
    }
}
