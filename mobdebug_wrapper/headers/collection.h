#ifndef H_COLLECTION
#define H_COLLECTION
#include <stddef.h>

struct CollectionPair {
    char* key;
    void* value;
};

struct Collection {
    struct CollectionPair* data;
    size_t size;
    size_t capability;
};

struct Collection* collection_make();

void* collection_getValue(struct Collection* collection, const char* key);
void collection_addValue(struct Collection* collection, const char* key, const void* value);
void collection_destroy(struct Collection* collection);

void collectionPair_destroy(struct CollectionPair* collectionPair);

#endif