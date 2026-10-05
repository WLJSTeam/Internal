(*:Package:*)

BeginPackage["WLJS`Internal`AsyncEvaluate`", {
    "LibraryLink`",
    "Parallel`Developer`",
    "WLJS`Internal`Library`"
}];


ClearAll["`*"];


AsyncEvaluate::usage =
"AsyncEvaluate[expr, callback] evaluates expression on parallel kernel and call callback[result] function on master kernel.";


URLReadAsync::usage =
"URLReadAsync[request, func] execute request in async mode and call func on response.";


$AsyncTasks::usage =
"$AsyncTasks - all async tasks.";


Begin["`Private`"];


Options[AsyncEvaluate] := {
    "Once" -> False
};


SetAttributes[AsyncEvaluate, HoldFirst];


AsyncEvaluate[expr_, handler_, OptionsPattern[]] :=
Block[{$$task}, With[{id = If[#, Hash[Hold[expr]], Hash[CreateUUID[]]]& @ OptionValue["Once"]},
    initAsyncTools[];

    If[!KeyExistsQ[$AsyncTasks, id],
        $AsyncTasks[id] = <|
        "Task" -> ParallelSubmit[
            With[{result = expr},
                WLJS`Internal`Library`Private`notifySignal[];
                result
            ]
        ],
        "Id" -> id,
        "Handler" -> handler
    |>];

    $$task = $AsyncTasks[id];

    Parallel`Developer`QueueRun[];

    Return[$$task]
]];


If[!ValueQ[$asyncToolsNeedInit], $asyncToolsNeedInit = True];


If[!AssociationQ[$AsyncTasks], $AsyncTasks = <||>];


With[{dir = DirectoryName[$InputFileName, 2]},
    initAsyncTools[] :=
    If[$asyncToolsNeedInit,
        WLJS`Internal`Library`Private`createSignal[];

        If[Length[Kernels[]] === 0,
            LaunchKernels[]
        ];

        ParallelEvaluate[
            PacletDirectoryLoad[dir];
            Get["WLJS`Internal`Library`"];
        ];

        Internal`CreateAsynchronousTask[WLJS`Internal`Library`Private`createWaitLoop, {}, checkAsyncTasks[{##}]&];

        $asyncToolsNeedInit = False;
    ];
];


checkAsyncTasks[args_] :=
If[Length[$AsyncTasks] > 0,
    While[Parallel`Developer`QueueRun[],
        Map[If[Parallel`Developer`DoneQ[#Task],
            KeyDropFrom[$AsyncTasks, #Id];
            #Handler[ReleaseHold[#Task["Result"]]]
        ]&, $AsyncTasks]
    ]
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