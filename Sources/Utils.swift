//
//  Utils.swift
//  add-odr-tags
//
//  Created by Jonathan Kilzi on 28/07/2020.
//  Copyright © 2020 Jonathan Kilzi. All rights reserved.
//

import Foundation
import XcodeProj

struct Utils {
    static func findNativeTargetsBy(_ resourcesBuildPhase: PBXResourcesBuildPhase, _ pbxproj: PBXProj) -> [PBXNativeTarget] {
        return pbxproj.nativeTargets.filter { nativeTarget in
            return nativeTarget.buildPhases.contains { buildPhase in
                buildPhase.uuid == resourcesBuildPhase.uuid
            }
        }
    }

    static func findResourcesBuildPhasesBy(_ buildFile: PBXBuildFile, _ pbxproj: PBXProj) -> [PBXResourcesBuildPhase] {
        return pbxproj.resourcesBuildPhases.filter { resourcesBuildPhase in
            var result = false
            if let files = resourcesBuildPhase.files {
                result = files.contains { buildFileInResourcesBuildPhase in
                    buildFileInResourcesBuildPhase.uuid == buildFile.uuid
                }
            }
            
            return result
        }
    }

    static func findBuildFilesBy(_ fileRef: PBXFileReference, _ pbxproj: PBXProj) -> [PBXBuildFile] {
        return pbxproj.buildFiles.filter { buildFile in buildFile.file?.uuid == fileRef.uuid }
    }

    static func findFileReferencesBy(path: String, _ pbxproj: PBXProj) -> [PBXFileReference] {
        return pbxproj.fileReferences.filter { fileRef in fileRef.path == path }
    }
}
