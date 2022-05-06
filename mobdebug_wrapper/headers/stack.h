#ifndef H_STACK
#define H_STACK

#include <stddef.h>

struct Node {
    struct Node** subnodes;
    size_t size;
    char* key;
    char* value;

    size_t capability;
    int destroyed;
};

struct Stack {
    struct Node* rootNode;
};

struct Stack* stack_make();

void stack_addNode(struct Node* self, struct Node* newNode);
void stack_removeNode(struct Node* self, struct Node* nodeForRemove);
size_t stack_findIndex(struct Node* self, struct Node* node, int* success);

struct Node* stack_createNode(const char* key, const char* value);
void stack_setNodeKey(struct Node* self, const char* key);
void stack_setNodeValue(struct Node* self, const char* value);
void stack_destroyNode(struct Node* self);

#endif