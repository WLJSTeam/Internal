(*:Package:*)

BeginPackage["WLJS`Internal`AsyncEvaluate`", {
    "LibraryLink`",
    "Parallel`Developer`",
    "WLJS`CSockets`"
}];


ClearAll["`*"];


AsyncEvaluate::usage =
"AsyncEvaluate[expr, callback] evaluates expression on parallel kernel and call callback[result] function on master kernel.";


$AsyncTasks::usage =
"$AsyncTasks - all async tasks.";


AsyncTaskObject::usag =
"AsyncTaskObject[id] - task representation.";


Begin["`Private`"];


Options[AsyncEvaluate] := {
    "Once" -> False
};


SetAttributes[AsyncEvaluate, HoldFirst];


AsyncEvaluate[expr_, handler_, OptionsPattern[]] :=
With[{id = If[#, Hash[Hold[expr]], Hash[CreateUUID[]]]& @ OptionValue["Once"]},
    initAsyncTools[];

    If[!KeyExistsQ[$AsyncTasks, id], $AsyncTasks[id] = <|
        "Task" -> ParallelSubmit[expr],
        "Id" -> id,
        "Handler" -> handler
    |>];

    AsyncTaskObject[id]
];


If[!ValueQ[$asyncToolsNeedInit], $asyncToolsNeedInit = True];


$asyncTaskCompleteHandler = Function[
    $AsyncTasks[ToExpression[#Data]]["Handler"]
];


initAsyncTools[] :=
If[$asyncToolsNeedInit,
    $AsyncTasks = <||>;

    LaunchKernels[];

    $asyncTaskServer = CSocketOpen[];
    $asyncTaskListener = SocketListen

    With[{port = $asyncTaskServer["DestinationPort"], host = "localhost"},
        ParallelEvaluate[
            Get["WLJS`CSockets`"];
            $$client = CSocketConnect[host, port];
            $$done[id_] := WriteString[$$client, ToString[id]];
        ];
    ];

    $asyncToolsNeedInit = False;
];


checkAsyncTasks[] :=
If[Length[$asyncTasks] > 0,
    Parallel`Developer`QueueRun[];
    Map[If[Parallel`Developer`DoneQ[#Task],
        KeyDropFrom[$asyncTasks, #Id];
        #Handler[ReleaseHold[#Task["Result"]]]
    ]&, $asyncTasks]
];


URLReadAsync[request_HTTPRequest, func_, "Stream"] :=
AsyncEvaluate[
    Module[{
        stream = URLRead[request, "Stream"], part = "", response = ""
    },
        While[True,
            part = ReadString[stream];
            If[part === EndOfFile, Break[]];
            response = response <> part;
        ];

        Close[stream];

        response
    ],
    func,
    "Once" -> True
];


URLReadAsync[request_HTTPRequest, func_] :=
AsyncEvaluate[
    URLRead[request],
    func,
    "Once" -> True
];


$asyncTasks =
<||>;


$directory =
DirectoryName[$InputFileName, 2];


$backgroundTaskLibrary =
LibraryResource[$directory, "backgroundTask"];


startBackgroundTask =
LibraryFunctionLoad[$backgroundTaskLibrary, "startBackgroundTask", {Integer, Integer}, Integer];


End[];


EndPackage[];