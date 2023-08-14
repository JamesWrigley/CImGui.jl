# CImGui

[![Build Status](https://github.com/Gnimuc/CImGui.jl/workflows/CI/badge.svg)](https://github.com/Gnimuc/CImGui.jl/actions/workflows/ci.yml)
[![pkgeval](https://juliahub.com/docs/CImGui/pkgeval.svg)](https://juliahub.com/ui/Packages/CImGui/HqG2H)
[![version](https://juliahub.com/docs/CImGui/version.svg)](https://juliahub.com/ui/Packages/CImGui/HqG2H)
<!---[![Codecov](https://codecov.io/gh/Gnimuc/CImGui.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Gnimuc/CImGui.jl)--->
[![](https://img.shields.io/badge/design%20principle-KISS-orange)](https://en.wikipedia.org/wiki/KISS_principle)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://Gnimuc.github.io/CImGui.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://Gnimuc.github.io/CImGui.jl/dev)
![GitHub Discussions](https://img.shields.io/github/discussions/Gnimuc/CImGui.jl)
[![deps](https://juliahub.com/docs/CImGui/deps.svg)](https://juliahub.com/ui/Packages/CImGui/HqG2H?t=2)
[![Genie Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/CImGui)](https://pkgs.genieframework.com?packages=CImGui)

This package provides a Julia language wrapper for [cimgui](https://github.com/cimgui/cimgui): a thin c-api wrapper programmatically generated for the excellent C++ immediate mode gui [Dear ImGui](https://github.com/ocornut/imgui). Dear ImGui is mainly for creating content creation tools and visualization / debug tools. You could browse [Gallery](https://github.com/ocornut/imgui/issues/2265)
to get an idea of its use cases.

![demo](demo/demo.png)

## Installation

```julia
pkg> add CImGui
```

## How to start

### 1. Run `demo/demo.jl` to test whether the default backend works on your machine
```julia-repl
julia> using CImGui
julia> include(joinpath(pathof(CImGui), "..", "..", "demo", "demo.jl"))
```

### 2. Run `examples/demo.jl` and browse demos in the `examples` folder to learn how to use the API
```julia-repl
julia> using CImGui
julia> include(joinpath(pathof(CImGui), "..", "..", "examples", "demo.jl"))
```
[All of these examples](examples/) (except for
[large_meshes.jl](examples/large_meshes.jl), which is a port of a
[stress-test][stress-test-comment]) are one-to-one ported from [Dear ImGui's C++
examples][upstream-examples] and there is an [interactive
manual][interactive-manual] for quickly locating the code. You could also run `?
CImGui.xxx` to retrieve docs:
```
help?> CImGui.Button
  Button(label) -> Bool
  Button(label, size) -> Bool

  Return true when the value has been changed or when pressed/selected.
```

### 3. The rendering loop
One thing that is necessary but the package doesn't provide is the [rendering loop](https://github.com/Gnimuc/CImGui.jl/blob/master/examples/demo.jl#L76-L113). 
Note that all ImGui widgets should run within `CImGui.Begin()`...`CImGui.End()`, if not, a crash is waiting for you. For example, directly running `CImGui.Button("My button")` in REPL will crash Julia. 

An example rendering loop module is provided [here](https://github.com/Gnimuc/CImGui.jl/blob/master/examples/Renderer.jl) for those users who don't bother to study those boilerplate code and eager to draw some widgets on the screen.
```julia-repl
julia> using CImGui
julia> include(joinpath(pathof(CImGui), "..", "..", "examples", "Renderer.jl"))
Main.Renderer

julia> using .Renderer

julia> Renderer.render(width = 360, height = 480, title = "IMGUI Window") do
           CImGui.Begin("Hello ImGui")
           CImGui.Button("My Button") && @show "triggered"
           CImGui.End()
       end
Task (runnable) @0x00000001136bead0
```

Should you have any other questions, feel free to write a post at the [Discussions](https://github.com/Gnimuc/CImGui.jl/discussions) area.

## Usage
The API provided in this package is as close as possible to the original C++ API. When translating C++ code to Julia, please follow the tips below:
- Replace `ImGui::` to `CImGui.`;
- `using LibCImGui` to import all of the `ImGuiXXX` types into the current namespace;
- Member function calling should be translated in Julia style: `fonts.AddFont(cfg)` => `CImGui.AddFont(fonts, cfg)`;
- [`using CImGui.CSyntax`] provides two useful macros: `@c` for translating C's `&` operator on immutables and `@cstatic`-block for emulating C's `static` keyword;

As mentioned before, this package aims to provide the same user experience as the original C++ API, so any high-level abstraction should go into a more high-level package. [`Redux.jl`](https://github.com/Gnimuc/Redux.jl) might be of interest to you if you're looking for state management frameworks.

### LibCImGui
LibCImGui is a thin wrapper over cimgui. It's one-to-one mapped to the original cimgui APIs. By using CImGui.LibCImGui, all of the ImGui-prefixed types, enums and ig-prefixed functions will be imported into the current namespace. It's mainly for people who prefer to use original cimgui's interface.

### Backend
The default backend is based on [ModernGL](https://github.com/JuliaGL/ModernGL.jl) and [GLFW](https://github.com/JuliaGL/GLFW.jl) which are stable and under actively maintained. Other popular backends like [SFML](https://github.com/zyedidia/SFML.jl) and [SDL](https://github.com/ariejdl/SDL.jl) could be added in the future if someone should invest time to make these packages work in post Julia 1.0 era.

## License
Only the Julia code in this repo is released under MIT license. Other assets such as those fonts in the `fonts` folder are released under their own license.


[stress-test-comment]: https://github.com/ocornut/imgui/issues/2591#issuecomment-496954460
[upstream-examples]: https://github.com/ocornut/imgui/blob/master/imgui_demo.cpp
[interactive-manual]: https://pthom.github.io/imgui_manual_online/manual/imgui_manual.html
