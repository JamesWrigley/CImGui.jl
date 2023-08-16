using CImGui
using CImGui.Renderer
using CImGui.CSyntax
import ImGuiOpenGLBackend as gl_backend
import ImGuiOpenGLBackend.ModernGL


let
    fonts_dir = joinpath(@__DIR__, "..", "fonts")
    app = ImGuiApp(1280, 720, "Demo";
                   fonts=[
                       (joinpath(fonts_dir, "Recursive Mono Casual-Regular.ttf"), 16),
                       (joinpath(fonts_dir, "Recursive Mono Linear-Regular.ttf"), 16),
                       (joinpath(fonts_dir, "Recursive Sans Casual-Regular.ttf"), 16),
                       (joinpath(fonts_dir, "Recursive Sans Linear-Regular.ttf"), 16),
                       (joinpath(fonts_dir, "Cousine-Regular.ttf"), 15),
                       (joinpath(fonts_dir, "DroidSans.ttf"), 16),
                       (joinpath(fonts_dir, "Karla-Regular.ttf"), 10),
                       (joinpath(fonts_dir, "ProggyTiny.ttf"), 10),
                       (joinpath(fonts_dir, "Roboto-Medium.ttf"), 16)
                   ])

    # Enable docking and multi-viewport
    io = CImGui.GetIO()
    io.ConfigFlags = unsafe_load(io.ConfigFlags) | CImGui.ImGuiConfigFlags_DockingEnable
    io.ConfigFlags = unsafe_load(io.ConfigFlags) | CImGui.ImGuiConfigFlags_ViewportsEnable

    # When viewports are enabled we tweak WindowRounding/WindowBg so platform windows can look identical to regular ones.
    style = CImGui.GetStyle()
    if unsafe_load(io.ConfigFlags) & CImGui.ImGuiConfigFlags_ViewportsEnable > 0
        style.WindowRounding = 5.0f0
        col = CImGui.c_get(style.Colors, CImGui.ImGuiCol_WindowBg)
        CImGui.c_set!(style.Colors, CImGui.ImGuiCol_WindowBg, CImGui.ImVec4(col.x, col.y, col.z, 1.0f0))
    end

    # Create texture for image drawing
    img_width, img_height = 256, 256
    image_id = gl_backend.ImGui_ImplOpenGL3_CreateImageTexture(img_width, img_height)

    demo_open = true
    render(app) do
        demo_open && @c CImGui.ShowDemoWindow(&demo_open)

        # Show image example
        if CImGui.Begin("Image Demo")
            image = rand(ModernGL.GLubyte, 4, img_width, img_height)
            gl_backend.ImGui_ImplOpenGL3_UpdateImageTexture(image_id, image, img_width, img_height)
            CImGui.Image(CImGui.ImTextureID(image_id), CImGui.ImVec2(img_width, img_height))
            CImGui.End()
        end
    end
end
