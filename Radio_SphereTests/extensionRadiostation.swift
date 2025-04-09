//
//  extensionRadiostation.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 06.05.25.
//


extension RadioStation {
    init(testID: String, testName: String, testTags: String, testCountry: String, testCountryCode: String) {
        self.id = testID
        self.name = testName
        self.url = "https://example.com"
        self.country = testCountry
        self.countrycode = testCountryCode
        self.state = nil
        self.language = "de"
        self.tags = testTags
        self.lastcheckok = 1
        self.imageURL = nil
        self.codec = nil
        self.clickcount = 100
        self.hasExtendedInfo = false
        self.geo_lat = nil
        self.geo_long = nil
    }
}
