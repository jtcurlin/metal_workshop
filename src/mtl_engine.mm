//
//  mtl_engine.cpp
//  metal_workshop
//
//  Created by Jacob Curlin on 8/20/24.
//

#include "mtl_engine.hpp"

void MTLEngine::init()
{
    init_device();
    init_window();
}

void MTLEngine::run()
{
    while (!glfwWindowShouldClose(m_glfw_window))
    {
        glfwPollEvents();
    }
}

void MTLEngine::cleanup()
{
    glfwTerminate();
    m_metal_device->release();
}

void MTLEngine::init_device()
{
    m_metal_device = MTL::CreateSystemDefaultDevice();
}

void MTLEngine::init_window()
{
    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    m_glfw_window = glfwCreateWindow(800, 600, "Metal Engine", NULL, NULL);
    if (!m_glfw_window)
    {
        glfwTerminate();
        exit(EXIT_FAILURE);
    }
    m_metal_window = glfwGetCocoaWindow(m_glfw_window);
    m_metal_layer = [CAMetalLayer layer];
    m_metal_layer.device = (__bridge id<MTLDevice>)m_metal_device;
    m_metal_layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    m_metal_window.contentView.layer = m_metal_layer;
    m_metal_window.contentView.wantsLayer = YES;
}
