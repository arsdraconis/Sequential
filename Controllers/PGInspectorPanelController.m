/* Copyright © 2007-2009, The Sequential Project
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the the Sequential Project nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE SEQUENTIAL PROJECT ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE SEQUENTIAL PROJECT BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */
#import "PGInspectorPanelController.h"

#import "PGNode.h"
#import "PGResourceAdapter.h"
#import "PGDisplayController.h"
#import "PGDocumentController.h"
#import "PGFoundationAdditions.h"
#import "PGGeometry.h"
#import "PGZooming.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PGAdditions)

- (id)PG_replacementUsingObject:(id)replacement
                preserveUnknown:(BOOL)preserve
                 getTopLevelKey:(out id *)outKey;

@end

@interface NSDictionary (PGAdditions)

- (NSDictionary *)PG_flattenedDictionary;

@end

// MARK: -

@interface PGInspectorPanelController ()

@property (nonatomic, weak) IBOutlet NSTableView *propertiesTable;
@property (nonatomic, weak) IBOutlet NSTableColumn *labelColumn;
@property (nonatomic, weak) IBOutlet NSTableColumn *valueColumn;
@property (nonatomic, weak) IBOutlet NSSearchField *searchField;
@property (nonatomic, strong) NSDictionary *properties;
@property (nonatomic, strong) NSDictionary *matchingProperties;
@property (nonatomic, strong) NSArray *matchingLabels;

- (void)_updateColumnWidths;
- (NSDictionary *)_humanReadablePropertiesWithDictionary:(NSDictionary *)dict;
- (NSString *)_stringWithDateTime:(NSString *)dateTime subsecTime:(NSString *)subsecTime;

@end


//	MARK: -
@implementation PGInspectorPanelController

- (void)dealloc
{
    [_propertiesTable setDelegate:nil];
    [_propertiesTable setDataSource:nil];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self _updateColumnWidths];
}

- (IBAction)changeSearch:(nullable id)sender
{
    NSMutableDictionary * const matchingProperties = [NSMutableDictionary dictionary];
    NSArray * const terms                          = [_searchField.stringValue PG_searchTerms];
    for (NSString * const label in _properties)
    {
        NSString * const value = _properties[label];
        if ([label PG_matchesSearchTerms:terms] || [value.description PG_matchesSearchTerms:terms])
        {
            matchingProperties[label] = value;
        }
    }
    _matchingProperties = [matchingProperties copy];
    _matchingLabels =
        [[matchingProperties.allKeys sortedArrayUsingSelector:@selector(compare:)] copy];
    [_propertiesTable reloadData];
    [self _updateColumnWidths];
}

- (IBAction)copy:(nullable id)sender
{
    NSMutableString * const string = [NSMutableString string];
    NSIndexSet * const indexes     = _propertiesTable.selectedRowIndexes;
    NSUInteger i                   = indexes.firstIndex;
    for (; NSNotFound != i; i = [indexes indexGreaterThanIndex:i])
    {
        NSString * const label = _matchingLabels[i];
        [string appendFormat:@"%@: %@\n", label, _matchingProperties[label]];
    }
    NSPasteboard * const pboard = [NSPasteboard generalPasteboard];
    [pboard declareTypes:@[NSPasteboardTypeString] owner:nil];
    [pboard setString:string forType:NSPasteboardTypeString];
}

- (void)displayControllerActiveNodeWasRead:(nullable NSNotification *)aNotif
{
    NSDictionary *d = self.displayController.activeNode.resourceAdapter.imageProperties;
    _properties     = [self _humanReadablePropertiesWithDictionary:d];

    [self changeSearch:nil];
}

//	MARK: - PGInspectorPanelController(Private)

- (void)_updateColumnWidths
{
    //	[_labelColumn setWidth:[_labelColumn PG_zoomedWidth]];
    //	[_valueColumn setWidth:NSWidth([_propertiesTable bounds]) - [_labelColumn width]];
}

- (NSDictionary *)_humanReadablePropertiesWithDictionary:(NSDictionary *)dict
{
    NSDictionary * const keyLabels = @{
        (NSString *)kCGImagePropertyFileSize: @"File Size (bytes)", //	2022/10/15 added
//        (NSString *)kCGImagePropertyPixelHeight: @"Pixel Height",	[special case]
//        (NSString *)kCGImagePropertyPixelWidth: @"Pixel Width",		[special case]
//        (NSString *)kCGImagePropertyDPIHeight: @"DPI Height",		[special case]
//        (NSString *)kCGImagePropertyDPIWidth: @"DPI Width",			[special case]
//        (NSString *)kCGImagePropertyDepth: @"Bit Depth",			[special case]
        (NSString *)kCGImagePropertyIsFloat: @"Floating Point Pixels", //	2023/08/14 added
        (NSString *)kCGImagePropertyIsIndexed: @"Indexed (palette) Pixels", //	2023/08/14 added
//        (NSString *)kCGImagePropertyHasAlpha: @"Alpha Channel Present",
        (NSString *)kCGImagePropertyColorModel: @"Color Model",
        (NSString *)kCGImagePropertyProfileName: @"Profile Name",

        (NSString *)kCGImagePropertyTIFFDictionary: @{
            @".": @"TIFF",
            (NSString *)kCGImagePropertyTIFFCompression: @"Compression",
            (NSString *)kCGImagePropertyTIFFPhotometricInterpretation: @"Photometric Interpretation",
            (NSString *)kCGImagePropertyTIFFDocumentName: @"Document Name",
            (NSString *)kCGImagePropertyTIFFImageDescription: @"Image Description",
            (NSString *)kCGImagePropertyTIFFMake: @"Make",
            (NSString *)kCGImagePropertyTIFFModel: @"Model",
            (NSString *)kCGImagePropertyTIFFSoftware: @"Software",
            (NSString *)kCGImagePropertyTIFFTransferFunction: @"Transfer Function",
            (NSString *)kCGImagePropertyTIFFArtist: @"Artist",
            (NSString *)kCGImagePropertyTIFFHostComputer: @"Host Computer",
            (NSString *)kCGImagePropertyTIFFCopyright: @"Copyright",
            (NSString *)kCGImagePropertyTIFFWhitePoint: @"White Point",
            (NSString *)kCGImagePropertyTIFFPrimaryChromaticities: @"Primary Chromaticities"
        },

        (NSString *)kCGImagePropertyJFIFDictionary: @{
            @".": @"JFIF",
            (NSString *)kCGImagePropertyJFIFIsProgressive: @"Progressive"
        },

        //	TODO: add HEIC dictionary here...

        (NSString *)kCGImagePropertyExifDictionary: @{
            @".": @"Exif",
            (NSString *)kCGImagePropertyExifExposureTime: @"Exposure Time",
            (NSString *)kCGImagePropertyExifFNumber: @"F Number",
            (NSString *)kCGImagePropertyExifExposureProgram: @"Exposure Program",
            (NSString *)kCGImagePropertyExifSpectralSensitivity: @"Spectral Sensitivity",
//            (NSString *)kCGImagePropertyExifISOSpeedRatings: @"ISO Speed Ratings",
            (NSString *)kCGImagePropertyExifOECF: @"OECF",
//            kCGImagePropertyExifSensitivityType
//            kCGImagePropertyExifStandardOutputSensitivity
//            kCGImagePropertyExifRecommendedExposureIndex
//            kCGImagePropertyExifISOSpeed
//            kCGImagePropertyExifISOSpeedLatitudeyyy
//            kCGImagePropertyExifISOSpeedLatitudezzz
//            kCGImagePropertyExifVersion
//            kCGImagePropertyExifDateTimeOriginal
//            kCGImagePropertyExifDateTimeDigitize
//            kCGImagePropertyExifOffsetTime
//            kCGImagePropertyExifOffsetTimeOriginal
//            kCGImagePropertyExifOffsetTimeDigitized
            (NSString *)kCGImagePropertyExifComponentsConfiguration: @"Components Configuration",
            (NSString *)kCGImagePropertyExifCompressedBitsPerPixel: @"Compressed BPP",
            (NSString *)kCGImagePropertyExifShutterSpeedValue: @"Shutter Speed",
            (NSString *)kCGImagePropertyExifApertureValue: @"Aperture",
            (NSString *)kCGImagePropertyExifBrightnessValue: @"Brightness",
            (NSString *)kCGImagePropertyExifExposureBiasValue: @"Exposure Bias",
            (NSString *)kCGImagePropertyExifMaxApertureValue: @"Max Aperture",
            (NSString *)kCGImagePropertyExifSubjectDistance: @"Subject Distance",
            (NSString *)kCGImagePropertyExifMeteringMode: @"Metering Mode",
            (NSString *)kCGImagePropertyExifLightSource: @"Light Source",
            (NSString *)kCGImagePropertyExifFlash: @"Flash",
            (NSString *)kCGImagePropertyExifFocalLength: @"Focal Length",
            (NSString *)kCGImagePropertyExifSubjectArea: @"Subject Area",
            (NSString *)kCGImagePropertyExifMakerNote: @"Maker Note",
            (NSString *)kCGImagePropertyExifUserComment: @"User Comment",
//             kCGImagePropertyExifFlashPixVersion
            (NSString *)kCGImagePropertyExifColorSpace: @"Color Space",
//             kCGImagePropertyExifPixelXDimension
//             kCGImagePropertyExifPixelYDimension
            (NSString *)kCGImagePropertyExifRelatedSoundFile: @"Related Sound File",
            (NSString *)kCGImagePropertyExifFlashEnergy: @"Flash Energy",
            (NSString *)kCGImagePropertyExifSpatialFrequencyResponse: @"Spatial Frequency Response",
            (NSString *)kCGImagePropertyExifFocalPlaneXResolution: @"Focal Plane X Resolution",
            (NSString *)kCGImagePropertyExifFocalPlaneYResolution: @"Focal Plane Y Resolution",
            (NSString *)kCGImagePropertyExifFocalPlaneResolutionUnit: @"Focal Plane Resolution Unit",
            (NSString *)kCGImagePropertyExifSubjectLocation: @"Subject Location",
            (NSString *)kCGImagePropertyExifExposureIndex: @"Exposure Index",
            (NSString *)kCGImagePropertyExifSensingMethod: @"Sensing Method",
            (NSString *)kCGImagePropertyExifFileSource: @"File Source",
            (NSString *)kCGImagePropertyExifSceneType: @"Scene Type",
//             kCGImagePropertyExifCFAPattern
            (NSString *)kCGImagePropertyExifCustomRendered: @"Custom Rendered",
            (NSString *)kCGImagePropertyExifExposureMode: @"Exposure Mode",
            (NSString *)kCGImagePropertyExifWhiteBalance: @"White Balance",
            (NSString *)kCGImagePropertyExifDigitalZoomRatio: @"Digital Zoom Ratio",
            (NSString *)kCGImagePropertyExifFocalLenIn35mmFilm: @"Focal Length (35mm Film)",
            (NSString *)kCGImagePropertyExifSceneCaptureType: @"Scene Capture Type",
            (NSString *)kCGImagePropertyExifGainControl: @"Gain Control",
            (NSString *)kCGImagePropertyExifContrast: @"Contrast",
            (NSString *)kCGImagePropertyExifSaturation: @"Saturation",
            (NSString *)kCGImagePropertyExifSharpness: @"Sharpness",
            (NSString *)kCGImagePropertyExifDeviceSettingDescription: @"Device Setting Description",
            (NSString *)kCGImagePropertyExifSubjectDistRange: @"Subject Dist Range",
            (NSString *)kCGImagePropertyExifImageUniqueID: @"Image Unique ID",
//            kCGImagePropertyExifCameraOwnerName
//            kCGImagePropertyExifBodySerialNumber
//            kCGImagePropertyExifLensSpecification
//            kCGImagePropertyExifLensMake
//            kCGImagePropertyExifLensModel
//            kCGImagePropertyExifLensSerialNumber
            (NSString *)kCGImagePropertyExifGamma: @"Gamma"
//            kCGImagePropertyExifCompositeImage
//            kCGImagePropertyExifSourceImageNumberOfCompositeImage
//            kCGImagePropertyExifSourceExposureTimesOfCompositeImage
        },
        
        (NSString *)kCGImagePropertyExifAuxDictionary: @{
            @".": @"Exif (Aux)",
            //	kCGImagePropertyExifAuxLensInfo
            (NSString *)kCGImagePropertyExifAuxLensModel: @"Lens Model",
            (NSString *)kCGImagePropertyExifAuxSerialNumber: @"Serial Number",
            (NSString *)kCGImagePropertyExifAuxLensID: @"Lens ID",
            (NSString *)kCGImagePropertyExifAuxLensSerialNumber: @"Lens Serial Number",
            (NSString *)kCGImagePropertyExifAuxImageNumber: @"Image Number",
            (NSString *)kCGImagePropertyExifAuxFlashCompensation: @"Flash Compensation",
            (NSString *)kCGImagePropertyExifAuxOwnerName: @"Owner Name",
            (NSString *)kCGImagePropertyExifAuxFirmware: @"Firmware",
        },


        //	TODO: add GIF dictionary here...

        //	TODO: add PNG dictionary here...

        //	TODO: add APNG dictionary here...

        //	TODO: add WebP dictionary here...

        //	TODO: add GPS dictionary here...

        //	TODO: add IPTC dictionary here...

        //	TODO: add 8BIM dictionary here...

        //	TODO: add DNG dictionary here...

        //	TODO: add CIFF dictionary here...

        //	TODO: add Nikon dictionary here...

        //	TODO: add Canon dictionary here...

        //	TODO: add OpenEXR dictionary here...

        //	TODO: add TGA dictionary here...
    };

    //	the returned object:
    NSMutableDictionary * const properties = [[[dict PG_replacementUsingObject:keyLabels preserveUnknown:NO getTopLevelKey:NULL] PG_flattenedDictionary] mutableCopy];

    //	2023/08/14 any values whose type conforms to NSArray will be converted to a string
    //	because NSArrays are displayed as "(\n<val0>,\n<val1>,\n<val2>,\n ... <val-last>\n)"
    {
        NSMutableDictionary * const replacements = [NSMutableDictionary new];
        NSCharacterSet *invalidChars = [NSCharacterSet characterSetWithCharactersInString:@"() "];
        [properties enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:NSArray.class])
            {
                NSString *value = [obj description];
                value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                value = [value stringByTrimmingCharactersInSet:invalidChars];
                replacements[key] = value;
            }
        }];

        [properties addEntriesFromDictionary:replacements];
    }

    // TODO: Create special formatters for certain properties.
    /*
        kCGImagePropertyExifFNumber (?)
        kCGImagePropertyExifExposureProgram (?)
        kCGImagePropertyExifISOSpeedRatings (?)

        Check other properties as well.
    */

    NSNumber * const depth = dict[(NSString *)kCGImagePropertyDepth];
    if (depth)
    {
        properties[@"Depth"] = [NSString stringWithFormat:@"%lu bits per sample", depth.unsignedLongValue];
    }

    NSNumber * const pixelWidth  = dict[(NSString *)kCGImagePropertyPixelWidth];
    NSNumber * const pixelHeight = dict[(NSString *)kCGImagePropertyPixelHeight];
    if (pixelWidth && pixelHeight)
    {
        properties[@"Pixel Width x Height"] = [NSString stringWithFormat:@"%lu x %lu", pixelWidth.unsignedLongValue, pixelHeight.unsignedLongValue];
    }
    
    NSNumber * const densityWidth  = dict[(NSString *)kCGImagePropertyDPIWidth];
    NSNumber * const densityHeight = dict[(NSString *)kCGImagePropertyDPIHeight];
    if (densityWidth || densityHeight)
    {
        properties[@"DPI Width x Height"] = [NSString stringWithFormat:@"%lu x %lu", (unsigned long)round(densityWidth.doubleValue), (unsigned long)round(densityHeight.doubleValue)];
    }

    if ([dict[(NSString *)kCGImagePropertyHasAlpha] boolValue]) properties[@"Alpha"] = @"Yes";

    PGOrientation const orientation = PGOrientationWithTIFFOrientation([dict[(NSString *)kCGImagePropertyOrientation] unsignedIntegerValue]);
    if (PGUpright != orientation)
    {
        properties[@"Orientation"] = PGLocalizedStringWithOrientation(orientation);
    }

    NSDictionary * const TIFFDict = dict[(NSString *)kCGImagePropertyTIFFDictionary];
    NSDictionary * const exifDict = dict[(NSString *)kCGImagePropertyExifDictionary];

    // TODO: Replace date/time formatting with a DateFormatter
    NSString * const dateTime = [self _stringWithDateTime:TIFFDict[(NSString *)kCGImagePropertyTIFFDateTime]
                                               subsecTime:exifDict[(NSString *)kCGImagePropertyExifSubsecTime]];
    [properties PG_setObject:dateTime forKey:@"Date/Time (Created)"];

    NSString * const dateTimeOriginal = [self _stringWithDateTime:exifDict[(NSString *)kCGImagePropertyExifDateTimeOriginal]
                                                       subsecTime:exifDict[(NSString *)kCGImagePropertyExifSubsecTimeOriginal]];
    if (!PGEqualObjects(dateTime, dateTimeOriginal))
    {
        [properties PG_setObject:dateTimeOriginal forKey:@"Date/Time (Original)"];
    }

    NSString * const dateTimeDigitized = [self _stringWithDateTime:exifDict[(NSString *)kCGImagePropertyExifDateTimeDigitized]
                                                        subsecTime:exifDict[(NSString *)kCGImagePropertyExifSubsecTimeDigitized]];
    if (!PGEqualObjects(dateTime, dateTimeDigitized))
    {
        [properties PG_setObject:dateTimeDigitized forKey:@"Date/Time (Digitized)"];
    }

    return properties;
}

- (NSString *)_stringWithDateTime:(NSString *)dateTime subsecTime:(NSString *)subsecTime
{
    if (!dateTime) return nil;

    //	2023/08/12 change "2023:08:12 12:34:56" to "2023-08-12 12:34:56"
    NSError *error = nil;
    NSString *pattern = @"([0-9]{4}):([0-9]{2}):([0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:&error];
    NSRange range = NSMakeRange(0, dateTime.length);
    NSUInteger matches = [regex numberOfMatchesInString:dateTime options:0 range:range];
    if (1 == matches)
    {
        dateTime = [regex stringByReplacingMatchesInString:dateTime
                                                   options:0
                                                     range:range
                                              withTemplate:@"$1-$2-$3"];
    }

    if (!subsecTime) return dateTime;
    return [NSString stringWithFormat:@"%@.%@", dateTime, subsecTime];
}

//	MARK: PGFloatingPanelController

- (NSString *)nibName
{
    return @"PGInspector";
}

- (BOOL)setDisplayControllerReturningWasChanged:(nullable PGDisplayController *)controller
{
    PGDisplayController * const oldController = self.displayController;
    if (![super setDisplayControllerReturningWasChanged:controller]) return NO;
    [oldController PG_removeObserver:self name:PGDisplayControllerActiveNodeWasReadNotification];
    [self.displayController PG_addObserver:self
                                  selector:@selector(displayControllerActiveNodeWasRead:)
                                      name:PGDisplayControllerActiveNodeWasReadNotification];
    [self displayControllerActiveNodeWasRead:nil];
    return YES;
}

//	MARK: id<NSMenuValidation>

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
    SEL const action = anItem.action;
    if (@selector(copy:) == action && !_propertiesTable.selectedRowIndexes.count) return NO;
    return [self respondsToSelector:anItem.action];
}

//	MARK: id<NSTableViewDataSource>

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _matchingLabels.count;
}

/* This method is required for the "Cell Based" TableView, and is optional for the "View Based"
 * TableView. If implemented in the latter case, the value will be set to the view at a given
 * row/column if the view responds to -setObjectValue: (such as NSControl and NSTableCellView). Note
 * that NSTableCellView does not actually display the objectValue, and its value is to be used for
 * bindings. See NSTableCellView.h for more information.
 */
-  (nullable id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(nullable NSTableColumn *)tableColumn
                      row:(NSInteger)row
{
    NSString * const label = _matchingLabels[row];
    if (tableColumn == _labelColumn) { return label; }
    else if (tableColumn == _valueColumn) { return _matchingProperties[label]; }
    return nil;
}

//	MARK: id<NSTableViewDelegate>

- (nullable NSView *)tableView:(NSTableView *)tableView
            viewForTableColumn:(nullable NSTableColumn *)tableColumn
                           row:(NSInteger)row
{
    if (tableColumn == _labelColumn)
    {
        NSTextField *result    = [NSTextField new];
        result.drawsBackground = NO;
        result.bordered        = NO;
        result.bezeled         = NO;
        result.editable        = NO;
//        result.bezelStyle      = ;

        result.font      = [NSFont boldSystemFontOfSize:0.0];
        result.alignment = NSTextAlignmentRight;
        return result;
    }
    else if (tableColumn == _valueColumn)
    {
        NSTextField *result    = [NSTextField new];
        result.drawsBackground = NO;
        result.bordered        = NO;
        result.bezeled         = NO;
        result.editable        = NO;

        result.font      = [NSFont systemFontOfSize:0.0];
        result.alignment = NSTextAlignmentLeft;
        return result;
    }
    return nil;
}

@end

//	MARK: -
@implementation NSObject (PGAdditions)

- (id)PG_replacementUsingObject:(id)replacement
                preserveUnknown:(BOOL)preserve
                 getTopLevelKey:(out id *)outKey
{
    if (!replacement) return preserve ? self : nil;
    if (outKey) *outKey = replacement;
    return self;
}

@end

//	MARK: -
@implementation NSDictionary (PGAdditions)

- (NSDictionary *)PG_flattenedDictionary
{
    NSMutableDictionary * const results = [NSMutableDictionary dictionary];
    for (id const key in self)
    {
        id const obj = self[key];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            [results addEntriesFromDictionary:obj];
        }
        else
        {
            results[key] = obj;
        }
    }
    return results;
}

//	MARK: - NSObject(PGAdditions)

- (id)PG_replacementUsingObject:(id)replacement
                preserveUnknown:(BOOL)preserve
                 getTopLevelKey:(out id *)outKey
{
    if (![replacement isKindOfClass:[NSDictionary class]])
    {
        return [super PG_replacementUsingObject:replacement preserveUnknown:preserve
                                 getTopLevelKey:outKey];
    }
    
    NSMutableDictionary * const result = [NSMutableDictionary dictionary];
    for (id const key in self)
    {
        id replacementKey = key;
        id const replacementObj = [self[key] PG_replacementUsingObject:((NSDictionary *)replacement)[key]
                                                       preserveUnknown:preserve
                                                        getTopLevelKey:&replacementKey];
        if (replacementObj) result[replacementKey] = replacementObj;
    }

    if (outKey) *outKey = ((NSDictionary *)replacement)[@"."];

    return result;
}

@end

NS_ASSUME_NONNULL_END
