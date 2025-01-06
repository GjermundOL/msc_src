using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64

function InverseAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, δLₘ, Vₑₘ, β; displayTower=false, saveTower=false)
    
    model           = Model(:TestModel) 

    Vₙ, Vₑ, Vᵤ = BuildInverseTower(model, nNodes, δLₘ, Vₑₘ, β, tWidth, nHeight, E, cs_area, g, mass)

    initialstate    = initialize!(model) # Initializes model

    E_s_typ = [initialstate.model.eleobj[j][i] for j=1:length(initialstate.model.eleobj) for i=1:length(initialstate.model.eleobj[j])]

    #println(E_s_typ)

    #println("typeof(initialstate.model.ele): ", typeof(initialstate.model.ele))

    stateXUA           = solve(DirectXUA{0,0,0};initialstate,time=0:1.:15)

    #t = 2
    #println("ExtractMeasurements")
    

    δLᵥ = ExtractMeasurements(stateXUA, Vₑ,1)
    
    

    #println("Typeof(inverse state): ", typeof(state))
    #println("inverse state[1]: ", state[5])
    #println("typeof(state)", typeof(state))
    #Draw(state[1], "Inverse analysis 1")
    DrawTower(stateXUA[2], "Inverse analysis, step 3"; displayTower = displayTower, saveTower = saveTower)
    

    #U = stateXUA[1].U
    #println("U: ", U)

    Fᵁᵢₙᵥᶸᵗˣ¹ = getdof(stateXUA[1];class=:U,field=:utx1)
    Fᵁᵢₙᵥᶸᵗˣ² = getdof(stateXUA[1];class=:U,field=:utx2)
    Fᵁᵢₙᵥ = collect(Iterators.flatten(zip(Fᵁᵢₙᵥᶸᵗˣ¹, Fᵁᵢₙᵥᶸᵗˣ²)))

    #println("Fᵁᵢₙᵥ: ", Fᵁᵢₙᵥ)

    return stateXUA, δLᵥ, Fᵁᵢₙᵥ
end