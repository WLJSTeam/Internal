(* :Package: *)

BeginPackage["WLJS`Internal`Library`"];


Begin["`Private`"];


createWaitLoopTask[] :=
Internal`CreateAsynchronousTask[createWaitLoop, {}, Echo[{##}]&];


$library = FileNameJoin[{DirectoryName[$InputFileName, 2], "LibraryResources", "Windows-x86-64-v8", "Internal.dll"}];


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