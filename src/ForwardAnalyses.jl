using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64

function ForwardAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale; displayTower=false, saveTower=false)


    model           = Model(:TestModel) 

    #println("BuildTower")

    Vₙ, Vₑ = BuildTower(model, nNodes, tWidth, nHeight, E, cs_area, g, mass)
    #println("GenerateExFs")

    Fᵁ = GenerateExFs(nNodes, ex_type, ex_scale) # Endre tittel

    #println("ApplyExFs")
    Vₑᵁ  = ApplyExFs(model, nNodes, Vₙ, Fᵁ)

    #println("initialize!")
    initialstate    = initialize!(model) # Initializes model


    #println("solve")
    state           = solve(SweepX{0};initialstate,time=[0.,1.])

    #println("getdof")
    #tx1,_           = getdof(state,field=:tx1,nodID=[Vₙ[3]]) # Returns: dofresidual, dofID


    t = 2
    #println("ExtractMeasurements")
    δLᵥ = ExtractMeasurements(state, Vₑ,t)

    Vₑₓ = Vₑ[5:length(Vₑ)]
    #println("Typeof(forward state): ", typeof(state))
    #println("forward state[1]: ", state[1])
    ## GLMakie ##
    #println("Draw")

    #println("Fᵁ: ", Fᵁ)
    DrawTower(state[1], "Forward analysis"; displayTower = displayTower, saveTower = saveTower)

    return state, δLᵥ, Vₑₓ, Fᵁ, Vₑᵁ
end 