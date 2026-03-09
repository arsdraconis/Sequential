//
//  InspectorPanelController.swift
//  Sequential
//
//  Created by nulldragon on 2026-03-04.
//

import Foundation

// MARK: Image Property Key Labels
@MainActor
fileprivate let keyLabels: [AnyHashable : Any] = [
    kCGImagePropertyFileSize: "File Size (bytes)",
    // Special cases
//    kCGImagePropertyPixelHeight: "Pixel Height",
//    kCGImagePropertyPixelWidth: "Pixel Width",
//    kCGImagePropertyDPIHeight: "DPI Height",
//    kCGImagePropertyDPIWidth: "DPI Width",
//    kCGImagePropertyDepth: "Bit Depth",
//    kCGImagePropertyHasAlpha: "Alpha Channel Present",
    kCGImagePropertyIsFloat: "Floating Point Pixels",
    kCGImagePropertyIsIndexed: "Indexed (palette) Pixels",
    kCGImagePropertyColorModel: "Color Model",
    kCGImagePropertyProfileName: "Profile Name",
    
    kCGImagePropertyExifDictionary: [
        ".": "Exif",
        kCGImagePropertyExifExposureTime: "Exposure Time",
        kCGImagePropertyExifFNumber: "F Number",
        kCGImagePropertyExifExposureProgram: "Exposure Program",
        kCGImagePropertyExifSpectralSensitivity: "Spectral Sensitivity",
//        kCGImagePropertyExifISOSpeedRatings: "ISO Speed Ratings",
        kCGImagePropertyExifOECF: "OECF",
//        kCGImagePropertyExifSensitivityType
//        kCGImagePropertyExifStandardOutputSensitivity
//        kCGImagePropertyExifRecommendedExposureIndex
//        kCGImagePropertyExifISOSpeed
//        kCGImagePropertyExifISOSpeedLatitudeyyy
//        kCGImagePropertyExifISOSpeedLatitudezzz
//        kCGImagePropertyExifVersion
//        kCGImagePropertyExifDateTimeOriginal
//        kCGImagePropertyExifDateTimeDigitized
//        kCGImagePropertyExifOffsetTime
//        kCGImagePropertyExifOffsetTimeOriginal
//        kCGImagePropertyExifOffsetTimeDigitized
        kCGImagePropertyExifComponentsConfiguration: "Components Configuration",
        kCGImagePropertyExifCompressedBitsPerPixel: "Compressed BPP",
        kCGImagePropertyExifShutterSpeedValue: "Shutter Speed",
        kCGImagePropertyExifApertureValue: "Aperture",
        kCGImagePropertyExifBrightnessValue: "Brightness",
        kCGImagePropertyExifExposureBiasValue: "Exposure Bias",
        kCGImagePropertyExifMaxApertureValue: "Max Aperture",
        kCGImagePropertyExifSubjectDistance: "Subject Distance",
        kCGImagePropertyExifMeteringMode: "Metering Mode",
        kCGImagePropertyExifLightSource: "Light Source",
        kCGImagePropertyExifFlash: "Flash",
        kCGImagePropertyExifFocalLength: "Focal Length",
        kCGImagePropertyExifSubjectArea: "Subject Area",
        kCGImagePropertyExifMakerNote: "Maker Note",
        kCGImagePropertyExifUserComment: "User Comment",
//        kCGImagePropertyExifFlashPixVersion
        kCGImagePropertyExifColorSpace: "Color Space",
//        kCGImagePropertyExifPixelXDimension
//        kCGImagePropertyExifPixelYDimension
        kCGImagePropertyExifRelatedSoundFile: "Related Sound File",
        kCGImagePropertyExifFlashEnergy: "Flash Energy",
        kCGImagePropertyExifSpatialFrequencyResponse: "Spatial Frequency Response",
        kCGImagePropertyExifFocalPlaneXResolution: "Focal Plane X Resolution",
        kCGImagePropertyExifFocalPlaneYResolution: "Focal Plane Y Resolution",
        kCGImagePropertyExifFocalPlaneResolutionUnit: "Focal Plane Resolution Unit",
        kCGImagePropertyExifSubjectLocation: "Subject Location",
        kCGImagePropertyExifExposureIndex: "Exposure Index",
        kCGImagePropertyExifSensingMethod: "Sensing Method",
        kCGImagePropertyExifFileSource: "File Source",
        kCGImagePropertyExifSceneType: "Scene Type",
//        kCGImagePropertyExifCFAPattern
        kCGImagePropertyExifCustomRendered: "Custom Rendered",
        kCGImagePropertyExifExposureMode: "Exposure Mode",
        kCGImagePropertyExifWhiteBalance: "White Balance",
        kCGImagePropertyExifDigitalZoomRatio: "Digital Zoom Ratio",
        kCGImagePropertyExifFocalLenIn35mmFilm: "Focal Length (35mm Film)",
        kCGImagePropertyExifSceneCaptureType: "Scene Capture Type",
        kCGImagePropertyExifGainControl: "Gain Control",
        kCGImagePropertyExifContrast: "Contrast",
        kCGImagePropertyExifSaturation: "Saturation",
        kCGImagePropertyExifSharpness: "Sharpness",
        kCGImagePropertyExifDeviceSettingDescription: "Device Setting Description",
        kCGImagePropertyExifSubjectDistRange: "Subject Dist Range",
        kCGImagePropertyExifImageUniqueID: "Image Unique ID",
//        kCGImagePropertyExifCameraOwnerName
//        kCGImagePropertyExifBodySerialNumber
//        kCGImagePropertyExifLensSpecification
//        kCGImagePropertyExifLensMake
//        kCGImagePropertyExifLensModel
//        kCGImagePropertyExifLensSerialNumber
        kCGImagePropertyExifGamma: "Gamma"
//        kCGImagePropertyExifCompositeImage
//        kCGImagePropertyExifSourceImageNumberOfCompositeImage
//        kCGImagePropertyExifSourceExposureTimesOfCompositeImage
    ],
    
    kCGImagePropertyExifAuxDictionary: [
        ".": "Exif (Aux)",
//        kCGImagePropertyExifAuxLensInfo
        kCGImagePropertyExifAuxLensModel: "Lens Model",
        kCGImagePropertyExifAuxSerialNumber: "Serial Number",
        kCGImagePropertyExifAuxLensID: "Lens ID",
        kCGImagePropertyExifAuxLensSerialNumber: "Lens Serial Number",
        kCGImagePropertyExifAuxImageNumber: "Image Number",
        kCGImagePropertyExifAuxFlashCompensation: "Flash Compensation",
        kCGImagePropertyExifAuxOwnerName: "Owner Name",
        kCGImagePropertyExifAuxFirmware: "Firmware",
    ],
    
    // See https://github.com/bestfx/IPTC-Photo-Metadata-Guide/blob/master/introduction.md
    kCGImagePropertyIPTCDictionary: [
        ".": "IPTC",
        kCGImagePropertyIPTCUrgency: "Urgency",
        kCGImagePropertyIPTCSubjectReference: "Subject Reference",
        kCGImagePropertyIPTCCategory: "Category",
        kCGImagePropertyIPTCSupplementalCategory: "Supplemental Category",
        kCGImagePropertyIPTCFixtureIdentifier: "Fixture Identifier",
        kCGImagePropertyIPTCKeywords: "Keywords",
        kCGImagePropertyIPTCContentLocationCode: "Content Location Code",
        kCGImagePropertyIPTCContentLocationName: "Content Location Name",
        kCGImagePropertyIPTCEditStatus: "Edit Status",
        kCGImagePropertyIPTCEditorialUpdate: "Editorial Update",
        kCGImagePropertyIPTCObjectCycle: "Object Cycle",
        
        kCGImagePropertyIPTCCopyrightNotice: "Copyright Notice",
        kCGImagePropertyIPTCRightsUsageTerms: "Rights Usage Terms",
        // TODO: Finish IPTC dictionary
    ],
    
    kCGImagePropertyGPSDictionary: [
        ".": "GPS",
        kCGImagePropertyGPSLongitude: "Longitude",
        kCGImagePropertyGPSLongitudeRef: "Longitude Ref",
        kCGImagePropertyGPSLatitude: "Latitude",
        kCGImagePropertyGPSLatitudeRef: "Latitude Ref",
        kCGImagePropertyGPSAltitude: "Altitude",
        kCGImagePropertyGPSAltitudeRef: "Altitude Ref",
        kCGImagePropertyGPSImgDirection: "Image Direction",
        kCGImagePropertyGPSImgDirectionRef: "Image Direction Ref",
        kCGImagePropertyGPSDateStamp: "Date Stamp",
        kCGImagePropertyGPSTimeStamp: "Time Stamp",
        kCGImagePropertyGPSDOP: "DOP",
    ],
        
    // TODO: add WebP dictionary here...
    
    // TODO: add CIFF dictionary here...
    
    // TODO: add DNG dictionary here...
    
    kCGImagePropertyGIFDictionary: [
        ".": "GIF",
        kCGImagePropertyGIFHasGlobalColorMap: "Has Global Color Map",
        kCGImagePropertyGIFImageColorMap: "Color Map",
        kCGImagePropertyGIFLoopCount: "Loop Count",
    ],
    
    
    kCGImagePropertyHEICSDictionary: [
        ".": "HEIC",
        kCGImagePropertyNamedColorSpace: "Named Color Space",
        kCGImagePropertyHEICSLoopCount: "Loop Count"
    ],
    
    kCGImagePropertyJFIFDictionary: [
        ".": "JFIF",
        kCGImagePropertyJFIFIsProgressive: "Progressive"
    ],
    
    kCGImagePropertyPNGDictionary: [
        ".": "PNG",
        kCGImagePropertyPNGTitle: "Title",
        kCGImagePropertyPNGDescription: "Description",
        kCGImagePropertyPNGComment: "Comment",
        kCGImagePropertyPNGDisclaimer: "Disclaimer",
        kCGImagePropertyPNGWarning: "Warning",
        kCGImagePropertyPNGAuthor: "Author",
        kCGImagePropertyPNGCopyright: "Copyright",
        kCGImagePropertyPNGCreationTime: "Creation Time",
        kCGImagePropertyPNGModificationTime: "Modification Time",
        kCGImagePropertyPNGSoftware: "Software",
        kCGImagePropertyPNGGamma: "Gamma",
        kCGImagePropertyPNGInterlaceType: "Interlace Type",
        kCGImagePropertyPNGsRGBIntent: "sRGB Intent",
        kCGImagePropertyPNGChromaticities: "Chromaticities",
        kCGImagePropertyAPNGLoopCount: "APNG Loop Count"
        // TODO: Add compression filter?
    ],
    
    // TODO: add APNG dictionary here...
    
    kCGImagePropertyTGADictionary: [
        ".": "TGA",
        kCGImagePropertyTGACompression: "Compression"
    ],
    
    kCGImagePropertyTIFFDictionary: [
        ".": "TIFF",
        kCGImagePropertyTIFFCompression: "Compression",
        kCGImagePropertyTIFFPhotometricInterpretation: "Photometric Interpretation",
        kCGImagePropertyTIFFDocumentName: "Document Name",
        kCGImagePropertyTIFFImageDescription: "Image Description",
        kCGImagePropertyTIFFMake: "Make",
        kCGImagePropertyTIFFModel: "Model",
        kCGImagePropertyTIFFSoftware: "Software",
        kCGImagePropertyTIFFTransferFunction: "Transfer Function",
        kCGImagePropertyTIFFArtist: "Artist",
        kCGImagePropertyTIFFHostComputer: "Host Computer",
        kCGImagePropertyTIFFCopyright: "Copyright",
        kCGImagePropertyTIFFWhitePoint: "White Point",
        kCGImagePropertyTIFFPrimaryChromaticities: "Primary Chromaticities"
    ],

    // TODO: add 8BIM dictionary here...

    // TODO: add Nikon dictionary here...

    // TODO: add Canon dictionary here...

    // TODO: add OpenEXR dictionary here...
]

// MARK: -
@objc(PGInspectorPanelController)
class InspectorPanelController : FloatingPanelController
{
    @IBOutlet
    var propertiesTable: NSTableView?
    
    @IBOutlet
    var labelColumn: NSTableColumn?
    
    @IBOutlet
    var valueColumn: NSTableColumn?
    
    @IBOutlet
    var searchField: NSSearchField?
    
    var properties: [String : Any]?
    
    var matchingProperties: [String : Any]?
    
    var matchingLabels: [String]?
    
    override var windowNibName: NSNib.Name? { return "PGInspector" }
    
    @MainActor
    deinit
    {
        propertiesTable?.delegate = nil
        propertiesTable?.dataSource = nil
    }
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        updateColumnWidths()
    }
    
    // MARK: Base Class Overrides
    override func setDisplayControllerReturningWasChanged(_ displayController: DocumentWindowController?) -> Bool
    {
        let oldController = self.documentWindowController
        if !super.setDisplayControllerReturningWasChanged(displayController) { return false }
        NotificationCenter.default.removeObserver(self,
                                                  name: .PGDisplayControllerActiveNodeWasRead,
                                                  object: oldController)
        
        if let newController = self.documentWindowController
        {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(displayControllerDidReadActiveNode(_:)),
                                                   name: .PGDisplayControllerActiveNodeWasRead,
                                                   object: newController)
        }
        
        displayControllerDidReadActiveNode(nil)
        return true
    }
    
    // MARK: Responding to Notifications
    @objc
    func displayControllerDidReadActiveNode(_ notification: Notification?)
    {
        if let imageProperties = documentWindowController?.activeNode.resourceAdapter.imageProperties as? [AnyHashable : Any]
        {
            properties = humanReadableProperties(from: imageProperties)
        }
        else
        {
            properties = [:]
        }
        changeSearch(nil)
    }
    
    // MARK: IBActions
    @IBAction
    func changeSearch(_ sender: Any?)
    {
        guard let properties = self.properties else { return }
        
        if let terms = searchField?.stringValue.pg_searchTerms()
        {
            var matchingProperties = [String : Any]()
            for (key, value) in properties
            {
                if key.pg_matchesSearchTerms(terms) || String(describing: value).pg_matchesSearchTerms(terms)
                {
                    matchingProperties[key] = value
                }
            }
            self.matchingProperties = matchingProperties
        }
        else
        {
            self.matchingProperties = properties
        }

        self.matchingLabels = Array(matchingProperties!.keys).sorted()
        propertiesTable?.reloadData()
        updateColumnWidths()
    }
    
    @IBAction
    func copy(_ sender: Any?)
    {
        if let matchingProperties = self.matchingProperties,
            let matchingLabels = self.matchingLabels,
            !matchingLabels.isEmpty
        {
            var result = ""
            for i in propertiesTable?.selectedRowIndexes ?? []
            {
                let label = matchingLabels[i]
                result.append(String(format: "%@: %@\n", label, String(describing: matchingProperties[label])))
            }
            
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(result, forType: .string)
        }
    }
    
    // MARK: Private Implementation
    func updateColumnWidths()
    {
        labelColumn?.sizeToFitLongestContent()
        valueColumn?.width = propertiesTable!.bounds.width - labelColumn!.width
    }
    
    // MARK: Managing Image Properties
    func humanReadableProperties(from dict: [AnyHashable : Any]) -> [String : Any]
    {
        var result = replaceKeys(in: dict, withKeysFrom: keyLabels)
        result = flattenDictionary(result)
        
        let convertedValues = convertArrayValuesToStrings(result)
        result.merge(convertedValues, uniquingKeysWith: { $1 })
                
        // TODO: Create special formatters for certain properties.
        /*
            kCGImagePropertyExifFNumber (?)
            kCGImagePropertyExifExposureProgram (?)
            kCGImagePropertyExifISOSpeedRatings (?)

            Check other properties as well.
        */
        
        if let depth = dict[kCGImagePropertyDepth] as? NSNumber
        {
            result["Depth"] = "\(depth.uintValue) bits per sample"
        }
        
        if let width = dict[kCGImagePropertyPixelWidth] as? NSNumber,
           let height = dict[kCGImagePropertyPixelHeight] as? NSNumber
        {
            result["Pixel Dimensions (Width x Height)"] = "\(width.uintValue) x \(height.uintValue)"
        }
        
        if let densityWidth = dict[kCGImagePropertyDPIWidth] as? NSNumber,
           let densityHeight = dict[kCGImagePropertyDPIHeight] as? NSNumber
        {
            result["DPI Dimensions (Width x Height)"] = "\(UInt(densityWidth.doubleValue.rounded())) x \(UInt(densityHeight.doubleValue.rounded()))"
        }
        
        if let hasAlpha = dict[kCGImagePropertyHasAlpha] as? NSNumber
        {
            result["Has Alpha Channel"] = hasAlpha.boolValue ? "Yes" : "No"
        }
        
        if let rawOrientation = dict[kCGImagePropertyOrientation] as? NSNumber
        {
            let orientation = Orientation(tiffOrientation: rawOrientation.intValue)
            result["Orientation"] = orientation.localizedDescription
        }
        
        if let exifDict = dict[kCGImagePropertyExifDictionary] as? [AnyHashable: Any]
        {
            var dateTime: String? = nil
            if let tiffDict = dict[kCGImagePropertyTIFFDictionary] as? [AnyHashable: Any],
                let tiffDateTime = tiffDict[kCGImagePropertyTIFFDateTime] as? String
            {
                dateTime = String(exifTimestamp: tiffDateTime, subsecondTime: exifDict[kCGImagePropertyExifSubsecTime] as? String)
                result["Date/Time (Created)"] = dateTime
            }
            
            var dateTimeOriginal: String? = nil
            if let exifDateTime = exifDict[kCGImagePropertyExifDateTimeOriginal] as? String
            {
                dateTimeOriginal = String(exifTimestamp: exifDateTime, subsecondTime: exifDict[kCGImagePropertyExifSubsecTimeOriginal] as? String)
                if dateTimeOriginal != dateTime
                {
                    result["Date/Time (Original)"] = dateTimeOriginal
                }
            }
            
            var dateTimeDigitized: String? = nil
            if let exifDateTimeDigitized = exifDict[kCGImagePropertyExifDateTimeDigitized] as? String
            {
                dateTimeDigitized = String(exifTimestamp: exifDateTimeDigitized, subsecondTime: exifDict[kCGImagePropertyExifSubsecTimeDigitized] as? String)
                if dateTimeDigitized != dateTime
                {
                    result["Date/Time (Digitized)"] = dateTimeDigitized
                }
            }
        }
        
        return result as! [String : Any]
    }
    
    private func replaceKeys(in original: [AnyHashable : Any], withKeysFrom new: [AnyHashable : Any]) -> [AnyHashable : Any]
    {
        var result = [AnyHashable: Any]()
        for (key, value) in original
        {
            if let dictValue = value as? [AnyHashable: Any],
                        let newSubDict = new[key] as? [AnyHashable : Any]
            {
                let subDict = replaceKeys(in: dictValue, withKeysFrom: newSubDict)
                result[key] = subDict
            }
            // If the replacement is not in the new dictionary, don't include it
            else if let replacementKey = new[key] as? AnyHashable
            {
                result[replacementKey] = value
            }
        }
        return result
    }
    
    private func flattenDictionary(_ dict: [AnyHashable : Any]) -> [AnyHashable : Any]
    {
        var result = [AnyHashable: Any]()
        for (key, value) in dict
        {
            // If the replacement is not in the new dictionary, don't include it
            if let value = value as? [AnyHashable : Any]
            {
                result.merge(value) { old, new in
                    return new
                }
            }
            else
            {
                result[key] = value
            }
        }
        return result
    }
    
    private func convertArrayValuesToStrings(_ dict: [AnyHashable: Any]) -> [AnyHashable: Any]
    {
        // 2023/08/14 any values whose type conforms to NSArray will be converted to a string
        // because NSArrays are displayed as "(\n<val0>,\n<val1>,\n<val2>,\n ... <val-last>\n)"
        var result = [AnyHashable: Any]()
        let invalidCharacters = CharacterSet(charactersIn: "() ")
        for (key, value) in dict
        {
            if let _ = value as? [Any]
            {
                result[key] = String(describing: value)
                    .replacingOccurrences(of: "\n", with: "")
                    .trimmingCharacters(in: invalidCharacters)
            }
        }
        return result
    }
}

// MARK: -
extension InspectorPanelController : NSMenuItemValidation
{
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
    {
        if menuItem.action == #selector(copy(_:)) && propertiesTable?.selectedRowIndexes.isEmpty ?? false
        {
            return false;
        }
        return responds(to: menuItem.action)
    }
}

// MARK: -
extension InspectorPanelController : NSTableViewDataSource, NSTableViewDelegate
{
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return matchingLabels?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
    {
        guard let label = matchingLabels?[row] else
        {
            return nil
        }
        if tableColumn == labelColumn
        {
            return label
        }
        else if tableColumn == valueColumn, let value = matchingProperties?[label]
        {
            return value
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        // TODO: Use makeView(withIdentifier:owner:)
        let result = NSTextField()
        result.drawsBackground = false
        result.isBordered = false
        result.isBezeled = false
        result.isEditable = false

        if (tableColumn == labelColumn)
        {
            result.font = .boldSystemFont(ofSize: 0.0)
            result.alignment = .right
        }
        else if (tableColumn == valueColumn)
        {
            result.font = .systemFont(ofSize: 0.0)
            result.alignment = .left
        }
        
        return result
    }
}
