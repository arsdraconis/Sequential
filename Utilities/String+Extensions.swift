//
//  String+Extensions.swift
//  Sequential
//
//  Created by nulldragon on 2026-03-04.
//

import Foundation

extension String
{
    /// Creates a string from the EXIF timestamp strings.
    init(exifTimestamp: String, subsecondTime: String? = nil)
    {
        // TODO: Convert to Swift RegEx once we're on a more recent SDK
        // Original implementation
//        NSError *error = nil;
//        NSString *pattern = @"([0-9]{4}):([0-9]{2}):([0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})";
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
//                                                                               options:0
//                                                                                 error:&error];
//        NSRange range = NSMakeRange(0, dateTime.length);
//        NSUInteger matches = [regex numberOfMatchesInString:dateTime options:0 range:range];
//        if (1 == matches)
//        {
//            dateTime = [regex stringByReplacingMatchesInString:dateTime
//                                                       options:0
//                                                         range:range
//                                                  withTemplate:@"$1-$2-$3"];
//        }
//
//        if (!subsecTime) return dateTime;
//        return [NSString stringWithFormat:@"%@.%@", dateTime, subsecTime];
        
        let pattern = "([0-9]{4}):([0-9]{2}):([0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: exifTimestamp.utf16.count)
        let matches = regex.matches(in: exifTimestamp, options: [], range: range)
        
        var result = exifTimestamp
        if matches.count == 1
        {
            result = regex.stringByReplacingMatches(in: exifTimestamp,
                                                  options: [],
                                                  range: range,
                                                  withTemplate: "$1-$2-$3")
        }
        
        if let subsecondTime
        {
            result = String(format: "%@.%@", result, subsecondTime)
        }
        
        self = result
    }
}
