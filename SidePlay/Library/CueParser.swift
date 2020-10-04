//
//  CueParser.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-10-03.
//

import Foundation

class CueParser {
    
    private let url: URL
    private let textContents: String
    init(url: URL) {
        self.url = url
        do {
            textContents = try String(contentsOf: url)
        } catch {
            textContents = ""
            print("Failed to read from .cue file at url: \(url.path)")
        }
    }
    
    func extractChapterArray() -> [Chapter] {
        var chapterArray = [Chapter]()
        
        let regex = try! NSRegularExpression(pattern: "TRACK \\d*.*", options: .caseInsensitive)
        // replace our matches with a *%* so we can split on that later
        let replacedText = regex.stringByReplacingMatches(in: textContents, options: [], range: NSRange(0..<textContents.utf16.count), withTemplate: "*%*")
        let splitText = replacedText.components(separatedBy: "*%*")
        
        // loop through and do some more trimming to get to the chapter title and start time
        for i in 0...splitText.count-1 {
            if splitText[i].contains("TITLE \"") {
                let trackRegex = try! NSRegularExpression(pattern: "TITLE \"", options: .caseInsensitive)
                var textReplacements = trackRegex.stringByReplacingMatches(in: splitText[i], options: [], range: NSRange(0..<splitText[i].utf16.count), withTemplate: "")
                let quoteAtEndOfLineRegex = try! NSRegularExpression(pattern: "\"$", options: [.caseInsensitive, .anchorsMatchLines])
                // no
                textReplacements = quoteAtEndOfLineRegex.stringByReplacingMatches(in: textReplacements, options: [], range: NSRange(0..<textReplacements.utf16.count), withTemplate: "")
                let indexRegex = try! NSRegularExpression(pattern: "INDEX \\d*\\s*", options: .caseInsensitive)
                textReplacements = indexRegex.stringByReplacingMatches(in: textReplacements, options: [], range: NSRange(0..<textReplacements.utf16.count), withTemplate: "")
                textReplacements = textReplacements.trimmingCharacters(in: .whitespacesAndNewlines)
                let chapterStartTimeArray = textReplacements.components(separatedBy: .newlines)
                
                // convert timestamp into seconds Double
                let timestampArray = chapterStartTimeArray[1].trimmingCharacters(in: .whitespaces).components(separatedBy: ":")
                
                let minutesInSeconds = (Double(timestampArray[0]) ?? 0.0) * 60
                let seconds =  Double(timestampArray[1]) ?? 0.0
                let milliseconds = ((Double(timestampArray[2]) ?? 0.0)/100)
                let chapterStartsSeconds: Double =  minutesInSeconds + seconds + milliseconds
                
                let chapter = Chapter(title: chapterStartTimeArray[0].trimmingCharacters(in: .whitespaces),
                                      begins: chapterStartsSeconds,
                                      ends: 0)
                chapterArray.append(chapter)
            }
        }
        
        // Set ends of the last chapter as the beginninf of this chapter
        for i in 1...chapterArray.count-1 {
            chapterArray[i-1].ends = chapterArray[i].begins
        }

        return chapterArray
    }
}

struct Chapter {
    var title: String
    var begins: Double
    var ends: Double
}
