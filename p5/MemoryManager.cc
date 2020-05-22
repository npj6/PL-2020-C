#include "MemoryManager.h"

MemoryManager::MemoryManager(unsigned mem) {
  varMem = mem;
  nextVar = 0;
}
unsigned MemoryManager::getVarDir(unsigned varSize) {
  unsigned dir = nextVar;
  nextVar += varSize;
  if (varMem <= nextVar) {
    throw no_memory_left("Not enough VarMemory left.");
  }
  return dir;
}
