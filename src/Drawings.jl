using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64


function Draw(state, Title; displayTower = false, saveTower = false)
    GLMakie.activate!(title=Title)
    fig = Figure()
    ax = Axis(fig[1, 1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1))


    println(Title)
    model = state.model
    nod_vec = model.nod

    coords = [n.coord for n in nod_vec]

    #println("node coords: ", coords)

    X = state.X
    U = state.U
    #println("State: ", state)
    #println("X: ", X)


    X₀ = ∂0(X)
    #println("length(X₀): ", length(X₀))
    #println("nNodes: ", length(nod_vec))
    #println("X₀: ", X₀)
    #GETDOF
    println("U: ", U)

    draw(ax,state)

    Title = replace(Title, " " => "_")
    Title = replace(Title, "," => "")

    if displayTower
        wait(display(fig))
    end

    if saveTower
        save("./results/towers/$(Title)_$(length(nod_vec))_nodes.png", fig)
    end

end