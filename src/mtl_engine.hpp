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
    
    static void framebuffer_size_callback(GLFWwindow *window, int width, int height);
    void resize_framebuffer(int width, int height);

private:
    void init_device();
    void init_window();
    
    void create_triangle();
    void create_default_library();
    void create_command_queue();
    void create_render_pipeline();
    
    void encode_render_command(MTL::RenderCommandEncoder* render_encoder);
    void send_render_command();
    void draw();
    
    MTL::Device*        m_metal_device;
    GLFWwindow*         m_glfw_window;
    NSWindow*           m_metal_window;
    CAMetalLayer*       m_metal_layer;
    CA::MetalDrawable*  m_metal_drawable;
    
    MTL::Library*               m_metal_default_library;
    MTL::CommandQueue*          m_metal_command_queue;
    MTL::CommandBuffer*         m_metal_command_buffer;
    MTL::RenderPipelineState*   m_metal_render_pso;
    MTL::Buffer*                m_triangle_vertex_buffer;
};
