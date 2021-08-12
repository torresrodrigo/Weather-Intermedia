//
//  String+Extensions.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 28/06/2021.
//

import Foundation

extension String {
    //Search the index of a char
    func firstIndexOf(char: Character) -> Int? {
        guard let firstIndex = firstIndex(of: char) else { return nil}
        let index = firstIndex.utf16Offset(in: self)
        return index
    }
    
    //Create a new string droping an indeces
    func newText() -> String? {
        guard let checkChar = firstIndex(of: "/") else {return ""}
        let index = (checkChar.utf16Offset(in: self) + 1)
        let newText = self.dropFirst(index)
        return String(newText)
    }
    
    //Get a first text of string
    func firstText() -> String? {
        guard let checkChar = firstIndex(of: "/") else {return self}
        let index = (checkChar.utf16Offset(in: self) + 1)
        let newText = self.prefix(index).dropLast()
        return String(newText)
    }
    
    //Get a second text of string
    func secondText() -> String? {
        guard let checkChar = firstIndex(of: "/") else {return ""}
        let index = (checkChar.utf16Offset(in: self) + 1)
        let newText = self.dropFirst(index)
        return String(newText)
    }
    
    func toClearSpaces() -> String {
        return self.replacingOccurrences(of: "_", with: " ")
    }
    
    func toClearComa() -> String {
        guard let checkChar = lastIndex(of: ",") else {return self}
        let index = (checkChar.utf16Offset(in: self) + 1)
        let newText = self.prefix(index).dropLast()
        return String(newText)
    }
    
}
