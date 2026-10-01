#include "event_loop.h"


DLLEXPORT mint WolframLibrary_getVersion() {
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


void eventLoop(mint taskId, void *taskArgs)
{

}


DLLEXPORT int createEventLoop(WolframLibraryData libData, mint Argc, MArgument *Args, MArgument Res)
{
    return LIBRARY_NO_ERROR;
}
