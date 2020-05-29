#include "MemoryManager.h"

MemoryManager::MemoryManager(unsigned varMem, unsigned tempMem) {
  this->varMem = varMem;
  nextVar = 0;
  this->tempMem = tempMem;
  nextTemp = 0;
}
unsigned MemoryManager::getVarDir(unsigned varSize) {
  unsigned dir = nextVar;
  nextVar += varSize;
  if (varMem < nextVar) {
    throw no_memory_left("Not enough VarMemory left.");
  }
  return dir;
}


unsigned MemoryManager::getTempDir(unsigned tempSize) {
  unsigned dir = nextTemp + varMem; //la memoria para temporales está después de la memoria de variables
  nextTemp += tempSize;
  if (tempMem < nextTemp) {
    throw no_memory_left("Not enough TempMemory left.");
  }
  return dir;
}
void MemoryManager::resetTempDir() {
  nextTemp = 0;
}
