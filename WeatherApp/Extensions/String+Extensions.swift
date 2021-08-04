//
//  String+Extensions.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 28/06/2021.
//

import Foundation

extension String {
    //Search the index of a char
    func firstIndexOf( char: Character) -> Int? {
        return ((firstIndex(of: char)?.utf16Offset(in: self))! + 1)
    }
    
    //Create a new string droping a indeces
    func newText(char: Character) -> String {
        let index = ((firstIndex(of: char)?.utf16Offset(in: self))! + 1)
        let newText = self.dropFirst(index)
        return String(newText)
    }
    
    //Get a first text of string
    func firstText() -> String {
        let index = ((firstIndex(of: "/")?.utf16Offset(in: self))! + 1)
        let text = self.prefix(index).dropLast()
        return String(text)
    }
    
    //Get a second text of string
    func secondText() -> String {
        let index = ((firstIndex(of: "/")?.utf16Offset(in: self))! + 1)
        let text = self.dropFirst(index)
        return String(text)
    }
}
