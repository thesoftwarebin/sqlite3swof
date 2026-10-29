#include "loadembeddeddb.h"

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sqlite3.h"
#include "embeddeddbrc.h"

int LoadBinaryResourceIntoSqliteDb(sqlite3* db) {
    HRSRC hResource = FindResourceA(NULL, MAKEINTRESOURCEA(IDR_EMPBEDDEDDB), RT_RCDATA);
    if (!hResource) {
        printf("FindResource failed: %lu\n", GetLastError());
        return 0;
    }

    DWORD resourceSize = SizeofResource(NULL, hResource);
    if (resourceSize == 0) {
        printf("SizeofResource failed: %lu\n", GetLastError());
        return 0;
    }

    HGLOBAL hLoadedResource = LoadResource(NULL, hResource);
    if (!hLoadedResource) {
        printf("LoadResource failed: %lu\n", GetLastError());
        return 0;
    }

    const char* pResourceData = (const char*)LockResource(hLoadedResource);
    if (!pResourceData) {
        printf("LockResource failed: %lu\n", GetLastError());
        return 0;
    }

	unsigned char* binaryArray = (unsigned char*) sqlite3_malloc64(resourceSize);
    if (!binaryArray) {
        printf("Memory allocation failed\n");
        return 0;
    }

    memcpy(binaryArray, pResourceData, resourceSize);

	/*int result =*/ sqlite3_deserialize(
		db,
		"main",
		binaryArray,
		resourceSize,
		resourceSize,
		SQLITE_DESERIALIZE_FREEONCLOSE	// Safe now; SQLite frees the malloc'd copy
		| SQLITE_DESERIALIZE_RESIZEABLE
	);

    return 1;  // Success
}
