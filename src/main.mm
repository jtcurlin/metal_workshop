//
//  main.cpp
//  metal_workshop
//
//  Created by Jacob Curlin on 6/2/24.
//

// #include <iostream>
#include "mtl_engine.hpp"

int main(int argc, const char * argv[]) {
    MTLEngine engine;
    engine.init();
    engine.run();
    engine.cleanup();
    
    
    // insert code here...
    // std::cout << "Hello, World!\n";
    return 0;
}
