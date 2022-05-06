#include "collection.h"

struct Collection* collection_make() {
    struct Collection* result = (struct Collection*)malloc(sizeof(struct Collection));
    result->data = NULL;
    result->size = 0;
    result->capability = 0;
    return result;
}

void* collection_getValue(struct Collection* collection, const char* key) {
    for(size_t i = 0; i < collection->size; ++i) {
        if(strcmp(collection->data[i].key, key) == 0) {
            return collection->data[i].value;
        }
    }
    return NULL;
}

void collection_addValue(struct Collection* collection, const char* key, const void* value) {
    size_t newSize = collection->size + 1;
    if(collection->capability < newSize) {
        struct CollectionPair* oldData = collection->data;
        collection->data = (struct CollectionPair*)malloc(sizeof(struct CollectionPair)*newSize);
        memcpy(collection->data, oldData, sizeof(struct CollectionPair) * collection->size);
        free(oldData);
        collection->capability = newSize;
        collection->data[collection->size].key = NULL;
        collection->data[collection->size].value = NULL;
    }
    if(collection->data[collection->size].key != NULL) {
        free(collection->data[collection->size].key);
        collection->data[collection->size].key = NULL;
    }
    if(collection->data[collection->size].value != NULL) {
        free(collection->data[collection->size].value);
        collection->data[collection->size].value = NULL;
    }
    size_t keySize = strlen(key);
    collection->data[collection->size].key = (char*)malloc(sizeof(char)*(keySize+1));
    strcpy(collection->data[collection->size].key, key);

    collection->data[collection->size].value = value;
    // size_t valueSize = strlen(value);
    // collection->data[collection->size].value = (char*)malloc(sizeof(char)*(valueSize+1));
    // strcpy(collection->data[collection->size].value, value);

    collection->size = newSize;
}

void collection_destroy(struct Collection* collection) {
    for(size_t i = 0; i < collection->capability; ++i) {
        collectionPair_destroy(&collection->data[i]);
    }
    if(collection->data != NULL) {
        free(collection->data);
    }
}

void collectionPair_destroy(struct CollectionPair* collectionPair) {
    if(collectionPair->key != NULL) {
        free(collectionPair->key);
    }
    if(collectionPair->value != NULL) {
        free(collectionPair->value);
    }
}