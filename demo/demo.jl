using CImGui
using CImGui.Renderer
import CImGui.CSyntax: @c
import CImGui.CSyntax.CStatic: @cstatic
using Printf

let
    fonts_dir = joinpath(@__DIR__, "..", "fonts")
    show_demo_window = true
    show_another_window = false
    clear_color = Cfloat[0.45, 0.55, 0.60, 1.00]

    render(; fonts=[(joinpath(fonts_dir, "Roboto-Medium.ttf"), 16)]) do
        # show the big demo window
        if show_demo_window
            @c CImGui.ShowDemoWindow(&show_demo_window)
        end

        # Show a simple window that we create ourselves.
        # We use a Begin/End pair to created a named window.
        @cstatic f=Cfloat(0.0) counter=Cint(0) begin
            if CImGui.Begin("Hello, world!")  # create a window called "Hello, world!" and append into it.
                CImGui.Text("This is some useful text.")  # display some text
                @c CImGui.Checkbox("Demo Window", &show_demo_window)  # edit bools storing our window open/close state
                @c CImGui.Checkbox("Another Window", &show_another_window)

                @c CImGui.SliderFloat("float", &f, 0, 1)  # edit 1 float using a slider from 0 to 1
                CImGui.ColorEdit3("clear color", clear_color)  # edit 3 floats representing a color
                CImGui.Button("Button") && (counter += 1)

                CImGui.SameLine()
                CImGui.Text("counter = $counter")

                framerate = unsafe_load(CImGui.GetIO().Framerate)
                CImGui.Text(@sprintf("Application average %.3f ms/frame (%.1f FPS)", 1000 / framerate, framerate))

                CImGui.End()
            end
        end

        # show another simple window.
        if show_another_window
            if @c CImGui.Begin("Another Window", &show_another_window)  # pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
                CImGui.Text("Hello from another window!")
                CImGui.Button("Close Me") && (show_another_window = false;)
                CImGui.End()
            end
        end
    end
end
