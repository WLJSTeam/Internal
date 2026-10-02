#ifndef SIGNAL_H
#define SIGNAL_H

#include "internal.h"

#ifdef _WIN32

#include <windows.h>

#define SIGNAL_NAME "Local\\AsyncEvaluateSignal"
typedef HANDLE Signal;
#define INVALID_SIGNAL NULL

#else

#include <errno.h>
#include <fcntl.h>
#include <semaphore.h>

#define SIGNAL_NAME "/AsyncEvaluateSignal"
typedef sem_t *Signal;
#define INVALID_SIGNAL SEM_FAILED

#endif

#endif // SIGNAL_H