#ifndef _MemoryManager_
#define _MemoryManager_

#include <stdexcept>

using namespace std;

class no_memory_left : public logic_error { public: no_memory_left(const char* what) : logic_error(what) {} };

class MemoryManager {
  private:
    unsigned varMem;
    unsigned nextVar;
  public:
    MemoryManager(unsigned mem);
    unsigned getVarDir(unsigned varSize);
};
#endif
