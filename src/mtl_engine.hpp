//
//  mtl_engine.hpp
//  metal_workshop
//
//  Created by Jacob Curlin on 8/20/24.
//

#pragma once

#define GLFW_INCLUDE_NONE
#import <GLFW/glfw3.h>
#define GLFW_EXPOSE_NATIVE_COCOA
#import <GLFW/glfw3native.h>

#include <Metal/Metal.hpp>
#include <Metal/Metal.h>
#include <QuartzCore/CAMetalLayer.hpp>
#include <QuartzCore/CAMetalLayer.h>
#include <QuartzCore/QuartzCore.hpp>

class MTLEngine {
public:
    void init();
    void run();
    void cleanup();

private:
    void init_device();
    void init_window();
    
    MTL::Device* m_metal_device;
    GLFWwindow* m_glfw_window;
    NSWindow* m_metal_window;
    CAMetalLayer* m_metal_layer;
};
