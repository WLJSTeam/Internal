(*:Package:*)

BeginPackage["WLJS`Internal`Tasks`", {
    "LibraryLink`",
    "WLJS`Internal`Compilation`",
    "WLJS`Internal`Library`"
}];


ClearAll["`*"];


CreateBackgroundTask::usage =
"CreateBackgroundTask[expr, {interval, count}] run expr in background like in ScheduledTask where interval in seconds.";


$BackgroundEvent::usage =
"Current background task event.";


Begin["`Private`"];


SetAttributes[CreateBackgroundTask, HoldFirst];


Options[CreateBackgroundTask] = {
    "StopCondition" -> Function[False]
};


CreateBackgroundTask[expr_, {interval_?NumericQ, count_Integer?Positive}, OptionsPattern[]] /; interval >= 0.001 :=
With[{
    intervalMs = Round[interval * 1000],
    stopCondition = OptionValue["StopCondition"]
},
    Internal`CreateAsynchronousTask[
        WLJS`Internal`Library`Private`startBackgroundTask,
        {intervalMs, count},
        (
            PreemptProtect[
                $BackgroundEvent = {##};
                expr;

                If[stopCondition[##],
                    StopAsynchronousTask[#1];
                    RemoveAsynchronousTask[#1];
                ];
            ];
        )&
    ]
];


End[];


EndPackage[];