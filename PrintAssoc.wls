#!/usr/bin/env wolframscript

PacletDirectoryLoad[Directory[]];
Get["WLJS`Internal`Console`"];


request = HTTPRequest["https://jsonplaceholder.typicode.com/todos/1", <|
    "Method" -> "POST",
    "Headers" -> <|"Content-Type" -> "application/json"|>,
    "Body" -> ExportString[<|"title" -> "foo", "body" -> "bar", "userId" -> 1|>, "JSON"]|>
];

ConsoleEcho["Print Assoc Example"] @
ExportString[request, "HTTPRequest"];