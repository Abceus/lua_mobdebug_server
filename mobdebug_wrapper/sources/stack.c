#include <stack.h>

struct Stack* stack_make() {
    struct Stack* result;
    result = (struct Stack*)malloc(sizeof(struct Stack));
    result->rootNode = NULL;
    return result;
}

void stack_addNode(struct Node* self, struct Node* newNode) {
    if(self->subnodes == NULL) {
        self->subnodes = (struct Node**)malloc(sizeof(struct Node*));
        self->capability = 1;
    }
    else if(self->capability < self->size+1) {
        struct Node** oldSubnodes = self->subnodes;
        self->subnodes = (struct Node**)malloc(sizeof(struct Node*)*self->size+1);
        memcpy(self->subnodes, oldSubnodes, sizeof(struct Node*)*self->size);
        self->capability++;
    }
    self->subnodes[self->size] = newNode;
    self->size++;
}

void stack_removeNode(struct Node* self, struct Node* nodeForRemove) {
    int success = 0;
    size_t found = stack_findIndex(self, nodeForRemove, &success);
    if(success == 1) {
        memcpy(self->subnodes+found, self->subnodes+found+1, self->size-found);
        self->size--;
    }
}

size_t stack_findIndex(struct Node* self, struct Node* node, int* success) {
    for(size_t i = 0; i < self->size; ++i) {
        if(self->subnodes[i] == node) {
            *success = 1;
            return i;
        }
    }
    *success = 0;
    return 0;
}

struct Node* stack_createNode(const char* key, const char* value) {
    struct Node* result = (struct Node*)malloc(sizeof(struct Node));
    result->key = NULL;
    result->value = NULL;
    stack_setNodeKey(result, key);
    stack_setNodeValue(result, value);

    result->subnodes = NULL;
    result->capability = 0;
    result->size = 0;
    result->destroyed = 0;
    return result;
}

void stack_setNodeKey(struct Node* self, const char* key) {
    if(self->key != NULL) {
        free(self->key);
    }
    self->key = NULL;
    if(key != NULL) {
        size_t keyLength = strlen(key);
        self->key = (char*)malloc(sizeof(char)*(keyLength+1));
        strcpy(self->key, key);
    }
}

void stack_setNodeValue(struct Node* self, const char* value) {
    if(self->value != NULL) {
        free(self->value);
    }
    self->value = NULL;
    if(value != NULL) {
        size_t valueLength = strlen(value);
        self->value = (char*)malloc(sizeof(char)*(valueLength+1));
        strcpy(self->value, value);
    }
}

void stack_destroyNode(struct Node* self) {
    free(self->key);
    free(self->value);
    self->destroyed = 1;
    for(size_t i = 0; i < self->capability; ++i) {
        if(self->subnodes[i]->destroyed == 0) {
            stack_destroyNode(self->subnodes[i]);
        }
    }
}
