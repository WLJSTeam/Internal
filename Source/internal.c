#include "internal.h"


DLLEXPORT mint WolframLibrary_getVersion()
{
    return WolframLibraryVersion;
}


DLLEXPORT int WolframLibrary_initialize(WolframLibraryData libData)
{
    return LIBRARY_NO_ERROR;
}


DLLEXPORT void WolframLibrary_uninitialize(WolframLibraryData libData)
{
    return;
}
