using CImGui
using CSyntax

"""
    show_app_main_menubar()
Create a fullscreen menu bar and populating it.
"""
function show_app_main_menubar()
    if CImGui.BeginMainMenuBar()
        if CImGui.BeginMenu("File")
            show_menu_file()
            CImGui.EndMenu()
        end
        if CImGui.BeginMenu("Edit")
            if CImGui.MenuItem("Undo", "CTRL+Z")
                @info "Trigger Undo | find me here: $(@__FILE__) at line $(@__LINE__)"
            end
            if CImGui.MenuItem("Redo", "CTRL+Y", false, false)  # disabled
                @info "Trigger Redo | find me here: $(@__FILE__) at line $(@__LINE__)"
            end
            CImGui.Separator()
            if CImGui.MenuItem("Cut", "CTRL+X")
                @info "Trigger Cut | find me here: $(@__FILE__) at line $(@__LINE__)"
            end
            if CImGui.MenuItem("Copy", "CTRL+C")
                @info "Trigger Copy | find me here: $(@__FILE__) at line $(@__LINE__)"
            end
            if CImGui.MenuItem("Paste", "CTRL+V")
                @info "Trigger Paste | find me here: $(@__FILE__) at line $(@__LINE__)"
            end
            CImGui.EndMenu()
        end
        CImGui.EndMainMenuBar()
    end
end

let
enabled = true
f = Cfloat(0.5)
n = Cint(0)
b = true
global function show_menu_file()
    CImGui.MenuItem("(dummy menu)", C_NULL, false, false)
    if CImGui.MenuItem("New")
        @info "Trigger New | find me here: $(@__FILE__) at line $(@__LINE__)"
    end
    if CImGui.MenuItem("Open", "Ctrl+O")
        @info "Trigger Open | find me here: $(@__FILE__) at line $(@__LINE__)"
    end
    if CImGui.BeginMenu("Open Recent")
        CImGui.MenuItem("fish_hat.c")
        CImGui.MenuItem("fish_hat.inl")
        CImGui.MenuItem("fish_hat.h")
        if CImGui.BeginMenu("More..")
            CImGui.MenuItem("Hello")
            CImGui.MenuItem("Sailor")
            if CImGui.BeginMenu("Recurse..")
                show_menu_file()
                CImGui.EndMenu()
            end
            CImGui.EndMenu()
        end
        CImGui.EndMenu()
    end
    if CImGui.MenuItem("Save", "Ctrl+S")
        @info "Trigger Save | find me here: $(@__FILE__) at line $(@__LINE__)"
    end
    if CImGui.MenuItem("Save As..")
        @info "Trigger Save As.. | find me here: $(@__FILE__) at line $(@__LINE__)"
    end
    CImGui.Separator()
    if CImGui.BeginMenu("Options")
        @c CImGui.MenuItem("Enabled", "", &enabled)
        CImGui.BeginChild("child", ImVec2(0, 60), true)
        foreach(i->CImGui.Text("Scrolling Text $i"), 0:9)
        CImGui.EndChild()
        @c CImGui.SliderFloat("Value", &f, 0.0, 1.0)
        @c CImGui.InputFloat("Input", &f, 0.1)
        @c CImGui.Combo("Combo", &n, "Yes\0No\0Maybe\0\0")
        @c CImGui.Checkbox("Check", &b)
        CImGui.EndMenu()
    end
    if CImGui.BeginMenu("Colors")
        sz = CImGui.GetTextLineHeight()
        for i = 0:Int(CImGui.ImGuiCol_COUNT-1)
            name = CImGui.GetStyleColorName(i)
            p = CImGui.GetCursorScreenPos()
            CImGui.AddRectFilled(CImGui.GetWindowDrawList(), p, (p.x+sz,p.y+sz), CImGui.GetColorU32(i))
            CImGui.Dummy(sz, sz)
            CImGui.SameLine()
            CImGui.MenuItem(name)
        end
        CImGui.EndMenu()
    end
    if CImGui.BeginMenu("Disabled", false)  # disabled
        throw(AssertionError("unreachable reached."))
    end
    CImGui.MenuItem("Checked", "", true) && @info "Trigger Checked | find me here: $(@__FILE__) at line $(@__LINE__)"
    CImGui.MenuItem("Quit", "Alt+F4") && @info "Trigger Quit | find me here: $(@__FILE__) at line $(@__LINE__)"
end

end # let
