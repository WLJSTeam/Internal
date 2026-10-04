(*:Package:*)

BeginPackage["WLJS`Internal`AsyncEvaluate`", {
    "LibraryLink`",
    "Parallel`Developer`",
    "WLJS`Internal`Library`"
}];


ClearAll["`*"];


AsyncEvaluate::usage =
"AsyncEvaluate[expr, callback] evaluates expression on parallel kernel and call callback[result] function on master kernel.";


$AsyncTasks::usage =
"$AsyncTasks - all async tasks.";


Begin["`Private`"];


Options[AsyncEvaluate] := {
    "Once" -> False
};


SetAttributes[AsyncEvaluate, HoldFirst];


AsyncEvaluate[expr_, handler_, OptionsPattern[]] :=
With[{id = If[#, Hash[Hold[expr]], Hash[CreateUUID[]]]& @ OptionValue["Once"]},
    initAsyncTools[];

    If[!KeyExistsQ[$AsyncTasks, id], $AsyncTasks[id] = <|
        "Task" -> ParallelSubmit[
            With[{result = expr},
                WLJS`Internal`Library`Private`notifySignal[];
                Return[result]
            ]
        ],
        "Id" -> id,
        "Handler" -> handler
    |>];

    While[Parallel`Developer`QueueRun[], {}];
];


If[!ValueQ[$asyncToolsNeedInit], $asyncToolsNeedInit = True];


With[{dir = DirectoryName[$InputFileName, 2]},
    initAsyncTools[] :=
    If[$asyncToolsNeedInit,
        $AsyncTasks = <||>;

        WLJS`Internal`Library`Private`createSignal[];

        LaunchKernels[];

        ParallelEvaluate[
            PacletDirectoryLoad[dir];
            Get["WLJS`Internal`Library`"];
        ];

        Internal`CreateAsynchronousTask[WLJS`Internal`Library`Private`createWaitLoop, {}, checkAsyncTasks[{##}]&];

        $asyncToolsNeedInit = False;
    ];
];


checkAsyncTasks[args_] :=
If[Echo[args[[2]]]; Length[$AsyncTasks] > 0,
    Map[If[Parallel`Developer`DoneQ[#Task],
        KeyDropFrom[$AsyncTasks, #Id];
        #Handler[ReleaseHold[#Task["Result"]]]
    ]&, $AsyncTasks]
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


End[];


EndPackage[];