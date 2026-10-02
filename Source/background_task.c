#include "background_task.h"


static void runBackgroundTask(mint taskId, void* args)
{
    ThreadArgs threadArgs = (ThreadArgs)args;
    WolframLibraryData libData = threadArgs->libData;
    mint interval = threadArgs->interval;
    mint count = threadArgs->count;

    DataStore ds;
    mint n = 0;

    while (libData->ioLibraryFunctions->asynchronousTaskAliveQ(taskId)) {
        ds = libData->ioLibraryFunctions->createDataStore();
        libData->ioLibraryFunctions->DataStore_addInteger(ds, n++);
        libData->ioLibraryFunctions->DataStore_addInteger(ds, count);
        libData->ioLibraryFunctions->raiseAsyncEvent(taskId, "BackgroundTaskEvent", ds);
        #ifdef _WIN32
        Sleep(interval);
        #else
        struct timespec req = {0, interval * 1000000L};
        nanosleep(&req, NULL);
        #endif
        if (n >= count) break;
    }

    free(threadArgs);
}


DLLEXPORT int startBackgroundTask(WolframLibraryData libData, mint Argc, MArgument *Args, MArgument Res)
{
    if (Argc != 2) {
        return LIBRARY_FUNCTION_ERROR;
    }

    int interval = MArgument_getInteger(Args[0]);
    int count = MArgument_getInteger(Args[1]);

    if (interval <= 0 || count <= 0) {
        return LIBRARY_FUNCTION_ERROR;
    }

    ThreadArgs threadArgs = (ThreadArgs)malloc(sizeof(struct ThreadArgs_st));
    if (threadArgs == NULL) {
        return LIBRARY_FUNCTION_ERROR;
    }

    threadArgs->libData = libData;
    threadArgs->interval = interval;
    threadArgs->count = count;

    int taskId = libData->ioLibraryFunctions->createAsynchronousTaskWithThread(runBackgroundTask, threadArgs);

    MArgument_setInteger(Res, taskId);
    return LIBRARY_NO_ERROR;
}