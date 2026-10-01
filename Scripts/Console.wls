#!/usr/bin/env wolframscript

PacletDirectoryLoad[DirectoryName[$InputFileName, 2]];


Get["WLJS`Internal`Console`"];


ConsoleEcho["Test"] @ <|"test" -> {1, 2, 3}|>;