using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64

function InverseAnalysis(cs_area, y_mod, mass, g, nNodes, tWidth, nHeight, δLₘ, Vₑₘ, β; displayTower=false, saveTower=false)
    
    model           = Model(:TestModel) 

    Vₙ, Vₑ, Vᵤ = BuildInverseTower(model, nNodes, δLₘ, Vₑₘ, β, tWidth, nHeight, y_mod, cs_area, g, mass)

    initialstate    = initialize!(model) # Initializes model

    E_s_typ = [initialstate.model.eleobj[j][i] for j=1:length(initialstate.model.eleobj) for i=1:length(initialstate.model.eleobj[j])]

    #println(E_s_typ)

    #println("typeof(initialstate.model.ele): ", typeof(initialstate.model.ele))

    stateXUA           = solve(DirectXUA{0,0,0};initialstate,time=0:1.:15)

    #t = 2
    #println("ExtractMeasurements")
    for t=1:14

        #δLᵥ = ExtractMeasurements(stateXUA, Vₑ,t)
        #println("δLᵥ: ", δLᵥ)
    end
    

    #println("Typeof(inverse state): ", typeof(state))
    #println("inverse state[1]: ", state[5])
    #println("typeof(state)", typeof(state))
    #Draw(state[1], "Inverse analysis 1")
    Draw(stateXUA[2], "Inverse analysis, step 3"; displayTower = displayTower, saveTower = saveTower)
    

    return stateXUA
end