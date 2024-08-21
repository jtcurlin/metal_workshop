//
//  mtl_engine.cpp
//  metal_workshop
//
//  Created by Jacob Curlin on 8/20/24.
//

#include "mtl_engine.hpp"
#include <simd/simd.h>
#include <iostream>

void MTLEngine::init()
{
    init_device();
    init_window();
    
    create_triangle();
    create_default_library();
    create_command_queue();
    create_render_pipeline();
}

void MTLEngine::run()
{
    while (!glfwWindowShouldClose(m_glfw_window))
    {
        @autoreleasepool {
            m_metal_drawable = (__bridge CA::MetalDrawable*)[m_metal_layer nextDrawable];
            draw();
        }
        glfwPollEvents();
    }
}

void MTLEngine::cleanup()
{
    glfwTerminate();
    m_metal_device->release();
}

void MTLEngine::framebuffer_size_callback(GLFWwindow *window, int width, int height)
{
    MTLEngine* engine = (MTLEngine*)glfwGetWindowUserPointer(window);
    engine->resize_framebuffer(width, height);
}

void MTLEngine::resize_framebuffer(int width, int height)
{
    m_metal_layer.drawableSize = CGSizeMake(width, height);
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
    
    int width, height;
    glfwGetFramebufferSize(m_glfw_window, &width, &height);
    
    glfwSetWindowUserPointer(m_glfw_window, this);
    glfwSetFramebufferSizeCallback(m_glfw_window, framebuffer_size_callback);
    
    m_metal_window = glfwGetCocoaWindow(m_glfw_window);
    m_metal_layer = [CAMetalLayer layer];
    m_metal_layer.device = (__bridge id<MTLDevice>)m_metal_device;
    m_metal_layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    m_metal_layer.drawableSize = CGSizeMake(width, height);
    m_metal_window.contentView.layer = m_metal_layer;
    m_metal_window.contentView.wantsLayer = YES;
}

void MTLEngine::create_triangle()
{
    simd::float3 triangle_vertices[] = {
        {-0.5f, -0.5f, 0.0f},
        { 0.5f, -0.5f, 0.0f},
        { 0.0f,  0.5f, 0.0f}
    };
    
    m_triangle_vertex_buffer = m_metal_device->newBuffer(&triangle_vertices,
                                                       sizeof(triangle_vertices),
                                                       MTL::ResourceStorageModeShared);
}

void MTLEngine::create_default_library()
{
    // newDefaultLibrary() returns a new MTLLibrary instance containing all the compiled Metal source files (.metal) found by Xcode within the project
    m_metal_default_library = m_metal_device->newDefaultLibrary();
    if (!m_metal_default_library)
    {
        std::cout << "Failed to load default library.";
        std::exit(-1);
    }
}

void MTLEngine::create_command_queue()
{
    // create command queue, which contains command buffers, which in turn hold individual commands
    m_metal_command_queue = m_metal_device->newCommandQueue();
}

void MTLEngine::create_render_pipeline()
{
    // MTLFunction's are objects representing public shader functions within a Metal library
    MTL::Function* vertex_shader = m_metal_default_library->newFunction(NS::String::string("vertexShader", NS::ASCIIStringEncoding));
    assert(vertex_shader);
    MTL::Function* fragment_shader = m_metal_default_library->newFunction(NS::String::string("fragmentShader", NS::ASCIIStringEncoding));
    assert(fragment_shader);
    
    MTL::RenderPipelineDescriptor* render_pipeline_descriptor = MTL::RenderPipelineDescriptor::alloc()->init();
    render_pipeline_descriptor->setLabel(NS::String::string("Triangle Rendering Pipeline", NS::ASCIIStringEncoding));
    render_pipeline_descriptor->setVertexFunction(vertex_shader);
    render_pipeline_descriptor->setFragmentFunction(fragment_shader);
    assert(render_pipeline_descriptor);
    
    MTL::PixelFormat pixel_format = (MTL::PixelFormat)m_metal_layer.pixelFormat;
    render_pipeline_descriptor->colorAttachments()->object(0)->setPixelFormat(pixel_format);
    
    NS::Error* error;
    m_metal_render_pso = m_metal_device->newRenderPipelineState(render_pipeline_descriptor, &error);
    render_pipeline_descriptor->release();
}

void MTLEngine::draw()
{
    send_render_command();
}

void MTLEngine::send_render_command()
{
    m_metal_command_buffer = m_metal_command_queue->commandBuffer();
    
    MTL::RenderPassDescriptor* render_pass_descriptor = MTL::RenderPassDescriptor::alloc()->init();
    MTL::RenderPassColorAttachmentDescriptor* cd = render_pass_descriptor->colorAttachments()->object(0);
    cd->setTexture(m_metal_drawable->texture());
    cd->setLoadAction(MTL::LoadActionClear);
    cd->setClearColor(MTL::ClearColor(41.0f/255.0f, 42.0f/255.0f, 48.0f/255.0f, 1.0));
    cd->setStoreAction(MTL::StoreActionStore);
    
    MTL::RenderCommandEncoder* render_command_encoder = m_metal_command_buffer->renderCommandEncoder(render_pass_descriptor);
    encode_render_command(render_command_encoder);
    render_command_encoder->endEncoding();
    
    m_metal_command_buffer->presentDrawable(m_metal_drawable);
    m_metal_command_buffer->commit();
    m_metal_command_buffer->waitUntilCompleted();
    
    render_pass_descriptor->release();
}

void MTLEngine::encode_render_command(MTL::RenderCommandEncoder* render_command_encoder)
{
    render_command_encoder->setRenderPipelineState(m_metal_render_pso);
    render_command_encoder->setVertexBuffer(m_triangle_vertex_buffer, 0, 0);
    MTL::PrimitiveType typeTriangle = MTL::PrimitiveTypeTriangle;
    NS::UInteger vertex_start = 0;
    NS::UInteger vertex_count = 3;
    render_command_encoder->drawPrimitives(typeTriangle, vertex_start, vertex_count);
}
