using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64


function Draw(state, Title)
    GLMakie.activate!(title=Title)
    fig = Figure()
    ax = Axis(fig[1, 1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1))
    draw(ax,state)
    #wait(display(fig))
end