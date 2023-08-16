module Renderer

export ImGuiApp, render


import CImGui
import ImGuiGLFWBackend
import ImGuiOpenGLBackend as GLBackend
import ImGuiGLFWBackend.LibGLFW as GLFW


# Callback function for GLFW errors
error_callback(err::Exception) = @error "GLFW ERROR: code $(err.code) msg: $(err.description)"

const FontList = Vector{Tuple{String, Int}}

"""Abstract type for ImGui programs that need to be cleaned up on exit."""
abstract type AbstractImGuiApp end

"""Container for the various objects required for an ImGui program."""
struct ImGuiApp <: AbstractImGuiApp
    window::Ptr{ImGuiGLFWBackend.GLFWwindow}
    imgui_ctx::Ptr{CImGui.ImGuiContext}
    glfw_ctx::ImGuiGLFWBackend.Context
    opengl_ctx::GLBackend.Context

    """Initialize the renderer and app state."""
    function ImGuiApp(width=1280, height=720, title::AbstractString="Demo"; fonts::FontList=FontList())
        # Setup GLFW error callback
        GLFW.glfwSetErrorCallback(Ref(error_callback))

        # Reset the window hints. Otherwise repeated calls to this function will
        # fail in mysterious ways, like the GLFW window not appearing and the render
        # loop getting stuck waiting for it to close.
        GLFW.glfwDefaultWindowHints()
        GLFW.glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MAJOR, 3)
        glsl_version = -1
        if Sys.isapple()
            glsl_version = 150
            GLFW.glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MINOR, 2)
            GLFW.glfwWindowHint(GLFW.GLFW_OPENGL_PROFILE, GLFW.GLFW_OPENGL_CORE_PROFILE) # 3.2+ only
            GLFW.glfwWindowHint(GLFW.GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE) # required on Mac
        else
            glsl_version = 130
            GLFW.glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MINOR, 0)
        end

        # Create window
        window = GLFW.glfwCreateWindow(width, height, title, C_NULL, C_NULL)
        @assert window != C_NULL
        GLFW.glfwMakeContextCurrent(window)

        # Enable vsync
        GLFW.glfwSwapInterval(1)

        glfw_ctx = ImGuiGLFWBackend.create_context(window, install_callbacks = true)
        opengl_ctx = GLBackend.create_context(glsl_version)

        # Setup Dear ImGui context
        imgui_ctx = CImGui.CreateContext()
        CImGui.SetCurrentContext(imgui_ctx)

        # Setup Dear ImGui style
        CImGui.StyleColorsDark()

        # Load fonts
        font_atlas = unsafe_load(CImGui.GetIO().Fonts)
        for (font, font_size) in fonts
            CImGui.AddFontFromFileTTF(font_atlas, font, font_size)
        end

        # Enable viewports before initializing the GLFW backend. This is necessary
        # because it does some extra steps during initialization if viewports are
        # enabled, and enabling viewports later without those extra steps will cause
        # a segfault.
        io = CImGui.GetIO()
        io.ConfigFlags = unsafe_load(io.ConfigFlags) | CImGui.ImGuiConfigFlags_ViewportsEnable

        # Setup Platform/Renderer bindings
        ImGuiGLFWBackend.init(glfw_ctx)
        GLBackend.init(opengl_ctx)

        # Now that we know the stuff for the viewports have been enabled we can
        # disable it again by default.
        io.ConfigFlags = unsafe_load(io.ConfigFlags) & ~CImGui.ImGuiConfigFlags_ViewportsEnable

        return new(window, imgui_ctx, glfw_ctx, opengl_ctx)
    end
end

# Functions that should be implemented by subtypes of AbstractImGuiApp
get_window(app::ImGuiApp) = app.window
get_imgui_ctx(app::ImGuiApp) = app.imgui_ctx
get_glfw_ctx(app::ImGuiApp) = app.glfw_ctx
get_opengl_ctx(app::ImGuiApp) = app.opengl_ctx
DestroyApp(app::ImGuiApp) = CImGui.DestroyContext(app.imgui_ctx)

function renderloop(app::AbstractImGuiApp, ui=()->nothing; hotloading=false)
    io = CImGui.GetIO()
    window = get_window(app)
    imgui_ctx = get_imgui_ctx(app)
    glfw_ctx = get_glfw_ctx(app)
    opengl_ctx = get_opengl_ctx(app)

    try
        while GLFW.glfwWindowShouldClose(window) == 0
            GLFW.glfwPollEvents()

            # Start the Dear ImGui frame
            GLBackend.new_frame(opengl_ctx)
            ImGuiGLFWBackend.new_frame(glfw_ctx)
            CImGui.NewFrame()

            # Build the interface
            hotloading ? Base.invokelatest(ui) : ui()

            # Render it
            CImGui.Render()
            GLFW.glfwMakeContextCurrent(window)

            width, height = Ref{Cint}(), Ref{Cint}()
            GLFW.glfwGetFramebufferSize(window, width, height)
            display_w = width[]
            display_h = height[]

            GLBackend.glViewport(0, 0, display_w, display_h)
            GLBackend.glClearColor(0.2, 0.2, 0.2, 1)
            GLBackend.glClear(GLBackend.GL_COLOR_BUFFER_BIT)
            GLBackend.render(opengl_ctx)

            if unsafe_load(CImGui.GetIO().ConfigFlags) & CImGui.ImGuiConfigFlags_ViewportsEnable == CImGui.ImGuiConfigFlags_ViewportsEnable
                backup_current_context = GLFW.glfwGetCurrentContext()
                CImGui.igUpdatePlatformWindows()
                GC.@preserve opengl_ctx CImGui.igRenderPlatformWindowsDefault(C_NULL, pointer_from_objref(opengl_ctx))
                GLFW.glfwMakeContextCurrent(backup_current_context)
            else
                GLFW.glfwMakeContextCurrent(window)
            end

            GLFW.glfwSwapBuffers(window)
            yield()
        end
    catch e
        @error "Error in renderloop!" exception=e
        Base.show_backtrace(stderr, catch_backtrace())
    finally
        GLBackend.shutdown(opengl_ctx)
        ImGuiGLFWBackend.shutdown(glfw_ctx)
        DestroyApp(app)
        GLFW.glfwDestroyWindow(window)
    end
end

"""Create an ImGuiApp and render it in a task."""
function render(ui, args...; hotloading=false, kwargs...)
    return render(ui, ImGuiApp, args...; hotloading, kwargs...)
end

"""Generic helper function for creating an app of type `T <: AbstractImGuiApp` and running it."""
function render(ui, ::Type{T}, args...; hotloading=false, kwargs...) where {T <: AbstractImGuiApp}
    app = T(args...; kwargs...)
    return render(ui, app; hotloading)
end

"""Render an existing AbstractImGuiApp in a task."""
function render(ui, app::AbstractImGuiApp; hotloading=false)
    if VERSION >= v"1.9"
        t = Threads.@spawn :interactive renderloop(app, ui; hotloading)
    else
        t = Threads.@spawn renderloop(app, ui; hotloading)
    end

    return errormonitor(t)
end

end # module
