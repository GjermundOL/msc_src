using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64

function InverseAnalysis(cs_area, y_mod, mass, g, nNodes, tWidth, nHeight, ϵₘ, Vₑₘ)
    
    model           = Model(:TestModel) 
    
    Vₙ, Vₑ, Vᵤ = BuildInverseTower(model, nNodes, ϵₘ, Vₑₘ, tWidth, nHeight, y_mod, cs_area, g, mass)

    initialstate    = initialize!(model) # Initializes model


    state           = solve(SweepX{0};initialstate,time=[0.,1.],verbose=false)

    Draw(state[1], "Inverse analysis")

    return state
end