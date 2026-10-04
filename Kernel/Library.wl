(* :Package: *)

BeginPackage["WLJS`Internal`Library`"];


Begin["`Private`"];


getLibraryLinkVersion[] := getLibraryLinkVersion[] =
Which[
    $VersionNumber >= 14.3,
        8,
    $VersionNumber >= 13.1,
        7,
    $VersionNumber >= 12.1,
        6,
    $VersionNumber >= 12.0,
        5,
    $VersionNumber >= 11.2,
        4,
    $VersionNumber >= 10.0,
        3,
    $VersionNumber >= 9.0,
        2,
    True,
        1
];


$library = FileNameJoin[{
    DirectoryName[$InputFileName, 2],
    "LibraryResources",
    $SystemID <> "-v" <> ToString[getLibraryLinkVersion[]],
    "internal." <> Internal`DynamicLibraryExtension[]
}];


(* :LibraryLoad: *)


startBackgroundTask::usage =
"startBackgroundTask[interval, count] -> taskId.";


startBackgroundTask =
LibraryFunctionLoad[$library, "startBackgroundTask", {Integer, Integer}, Integer];


byteMask::usage =
"byteMask[nMask, maskLen, nArr, arrLen] -> nResult.";


byteMask =
LibraryFunctionLoad[$library, "byteMask", {{"ByteArray", "Shared"}, Integer, {"ByteArray", "Shared"}, Integer}, "ByteArray"];


bytesPosition::usage =
"bytesPosition[ndata, dataLen, nsep, sepLen, count] -> npositions.";


bytesPosition =
LibraryFunctionLoad[$library, "bytesPosition", {{"ByteArray", "Shared"}, Integer, {"ByteArray", "Shared"}, Integer, Integer}, {Integer, 1}];


createSignal::usage =
"createSignal[].";


createSignal =
LibraryFunctionLoad[$library, "createSignal", {}, "Void"];


createWaitLoop::usage =
"createWaitLoop[] -> taskId.";


createWaitLoop =
LibraryFunctionLoad[$library, "createWaitLoop", {}, Integer];


notifySignal::usage =
"notifySignal[].";


notifySignal =
LibraryFunctionLoad[$library, "notifySignal", {}, "Void"];


closeSignal::usage =
"closeSignal[].";


closeSignal =
LibraryFunctionLoad[$library, "closeSignal", {}, "Void"];


End[];


EndPackage[];