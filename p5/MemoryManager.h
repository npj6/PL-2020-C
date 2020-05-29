#ifndef _MemoryManager_
#define _MemoryManager_

#include <stdexcept>

using namespace std;

class no_memory_left : public logic_error { public: no_memory_left(const char* what) : logic_error(what) {} };

class MemoryManager {
  private:
    unsigned varMem;
    unsigned nextVar;
    unsigned tempMem;
    unsigned nextTemp;
  public:
    MemoryManager(unsigned varMem, unsigned tempMem);
    unsigned getVarDir(unsigned varSize);
    unsigned getTempDir(unsigned tempSize);
    void resetTempDir();
};
#endif
