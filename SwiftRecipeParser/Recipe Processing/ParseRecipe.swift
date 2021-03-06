//
//  ParseRecipe.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/27/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation

class ParseRecipe {
    
    class func replaceString(stringToReplace:String, inputString:String, replacementString:String) -> String {
        let components = inputString.components(separatedBy: stringToReplace)
        
        return components.joined(separator: replacementString);
    }
    
    class func textBetweenStrings(inputString:NSString, startString:NSString, endString:NSString, keepStrings:Bool) -> Array<String> {
        var returnValue:Array<String> = Array()
        var returnString:String
        
        let stringToFind:String = "\(startString).*?\(endString)"
        do {
            let regex:NSRegularExpression = try NSRegularExpression(pattern: stringToFind, options: [NSRegularExpression.Options.dotMatchesLineSeparators, NSRegularExpression.Options.caseInsensitive])
            
            var matches:Array<NSTextCheckingResult>
            let entireStringRange:NSRange = NSMakeRange(0, inputString.length-1)
            
            //NSLog("entireStringRange = \(entireStringRange)")
            //NSLog("inputString = \(inputString)")
            
            matches = regex.matches(in: inputString as String, options: [], range: entireStringRange)
            
            if matches.count == 0
            {
                returnValue.append("")
            }
            else {
                var match:NSTextCheckingResult
                var rangeToReturn:NSRange = NSMakeRange(0, 0)
                
                for i in 0 ..< matches.count {
                    match = matches[i]
                    
                    if keepStrings {
                        returnString = inputString.substring(with: match.range)
                    }
                    else {
                        rangeToReturn.location = match.range.location + startString.length
                        rangeToReturn.length = match.range.length - startString.length - endString.length
                        
                        returnString = inputString.substring(with: rangeToReturn)
                    }
                    
                    returnValue.append(returnString)
                }
            }
        } catch let error as NSError {
            Logger.logDetails(msg: "error in regular expression \(error)")
        }
        
        return returnValue
    }
    
    //(NSArray *): (NSString *)inputString forStartString: (NSString *) startString andEndString: (NSString *) endString andKeepStrings: (BOOL)keepStrings
}
