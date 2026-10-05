#include "signal.h"


static Signal receiver = INVALID_SIGNAL;


DLLEXPORT int createSignal(WolframLibraryData libData, mint Argc, MArgument *Args, MArgument Res)
{
    if (receiver != INVALID_SIGNAL) {
        return LIBRARY_FUNCTION_ERROR;
    }

#ifdef _WIN32
    Signal signal = CreateSemaphoreA(
        NULL, 0, 0x7fffffff, SIGNAL_NAME
    );

    if (signal == NULL) {
        return LIBRARY_FUNCTION_ERROR;
    }

    for (;;) {
        DWORD result = WaitForSingleObject(signal, 0);

        if (result == WAIT_OBJECT_0) {
            continue;
        }

        if (result == WAIT_TIMEOUT) {
            break; // Счётчик равен нулю.
        }

        CloseHandle(signal);
        return LIBRARY_FUNCTION_ERROR;
    }
#else
    Signal signal = sem_open(
        SIGNAL_NAME, O_CREAT, 0600, 0
    );

    if (signal == SEM_FAILED) {
        return LIBRARY_FUNCTION_ERROR;
    }

    for (;;) {
        if (sem_trywait(signal) == 0) {
            continue;
        }

        int error = errno;

        if (error == EINTR) {
            continue;
        }

        if (error == EAGAIN) {
            break; // Счётчик равен нулю.
        }

        sem_close(signal);
        return LIBRARY_FUNCTION_ERROR;
    }
#endif

    receiver = signal;
    return LIBRARY_NO_ERROR;
}


static void waitSignal(mint taskId, void *args)
{
    WolframLibraryData libData = (WolframLibraryData)args;

    if (receiver == INVALID_SIGNAL) {
        return;
    }

    DataStore ds;
    int n = 0;

    while (libData->ioLibraryFunctions->asynchronousTaskAliveQ(taskId)) {
#ifdef _WIN32
        if (WaitForSingleObject(receiver, INFINITE) != WAIT_OBJECT_0) {
            break;
        }
#else
        int result;

        do {
            result = sem_wait(receiver);
        } while (result == -1 && errno == EINTR);

        if (result == -1) {
            break;
        }
#endif
        ds = libData->ioLibraryFunctions->createDataStore();
        libData->ioLibraryFunctions->DataStore_addInteger(ds, n++);
        libData->ioLibraryFunctions->raiseAsyncEvent(taskId, "AsyncSignal", ds);
    }
}


DLLEXPORT int createWaitLoop(WolframLibraryData libData, mint Argc, MArgument *Args, MArgument Res)
{
    int taskId = libData->ioLibraryFunctions->createAsynchronousTaskWithThread(waitSignal, libData);
    MArgument_setInteger(Res, taskId);
    return LIBRARY_NO_ERROR;
}


DLLEXPORT int notifySignal(WolframLibraryData libData, mint Argc, MArgument *Args, MArgument Res)
{
#ifdef _WIN32
    Signal signal = OpenSemaphoreA(
        SEMAPHORE_MODIFY_STATE, FALSE, SIGNAL_NAME
    );

    if (signal == NULL) {
        return LIBRARY_FUNCTION_ERROR;
    }

    BOOL success = ReleaseSemaphore(signal, 1, NULL);
    CloseHandle(signal);

    return success ? LIBRARY_NO_ERROR : LIBRARY_FUNCTION_ERROR;
#else
    Signal signal = sem_open(SIGNAL_NAME, 0);

    if (signal == SEM_FAILED) {
        return LIBRARY_FUNCTION_ERROR;
    }

    int result = sem_post(signal);
    sem_close(signal);

    return result == 0 ? LIBRARY_NO_ERROR : LIBRARY_FUNCTION_ERROR;
#endif
}


DLLEXPORT int closeSignal(WolframLibraryData libData, mint Argc, MArgument *Args, MArgument Res)
{
    if (receiver == INVALID_SIGNAL) {
        return LIBRARY_NO_ERROR;
    }

#ifdef _WIN32
    if (!CloseHandle(receiver)) {
        return LIBRARY_FUNCTION_ERROR;
    }
#else
    if (sem_close(receiver) != 0) {
        return LIBRARY_FUNCTION_ERROR;
    }
#endif

    receiver = INVALID_SIGNAL;
    return LIBRARY_NO_ERROR;
}
