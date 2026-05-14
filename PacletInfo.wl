(* ::Package:: *)

PacletObject[
  <|
    "Name" -> "WLJS/Internal",
    "Description" -> "Internal",
    "Creator" -> "Kirill",
    "License" -> "MIT",
    "PublisherID" -> "WLJS",
    "Version" -> "1.0.10",
    "WolframVersion" -> "13+",
    "Extensions" -> {
      {
        "Kernel",
        "Root" -> "Kernel",
        "Context" -> {
          {"WLJS`Internal`", "Internal.wl"},
          {
            "WLJS`Internal`Compilation`",
            "Compilation.wl"
          },
          {
            "WLJS`Internal`Binary`",
            "Binary.wl"
          },
          {
            "WLJS`Internal`Tasks`",
            "Tasks.wl"
          },
          {
            "WLJS`Internal`Functions`",
            "Functions.wl"
          },
          {
            "WLJS`Internal`Console`",
            "Console.wl"
          },
          {
            "WLJS`Internal`Alpha`",
            "Alpha.wl"
          }
        },
        "Symbols" -> {}
      },
      {"Documentation", "Language" -> "English"},
      {"LibraryLink", "Root" -> "LibraryResources"},
      {
        "Asset",
        "Assets" -> {
          {"License", "./LICENSE"},
          {"ReadMe", "./README.md"}
        }
      }
    }
  |>
]