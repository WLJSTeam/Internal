#ifndef BACKGROUND_TASK_H
#define BACKGROUND_TASK_H


#include "internal.h"


typedef struct ThreadArgs_st {
    WolframLibraryData libData;
    mint interval;
    mint count;
}* ThreadArgs;


#endif