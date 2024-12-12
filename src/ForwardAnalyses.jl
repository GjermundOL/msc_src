using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64

function ForwardAnalysis(cs_area, y_mod, mass, g, nNodes, tWidth, nHeight, type, scale)


    model           = Model(:TestModel) 

    println("BuildTower")

    Vₙ, Vₑ = BuildTower(model, nNodes, tWidth, nHeight, y_mod, cs_area, g, mass)
    println("GenerateExFs")

    Fᵁ = GenerateExFs(nNodes, type, scale) # Endre tittel

    println("ApplyExFs")
    Vₑᵁ  = ApplyExFs(model, nNodes, Vₙ, Fᵁ)

    println("initialize!")
    initialstate    = initialize!(model) # Initializes model


    println("solve")
    state           = solve(SweepX{0};initialstate,time=[0.,1.])

    println("getdof")
    tx1,_           = getdof(state,field=:tx1,nodID=[Vₙ[3]]) # Returns: dofresidual, dofID


    t = 2
    println("ExtractMeasurements")
    ϵᵥ = ExtractMeasurements(state, Vₑ,t)

    Vₑₓ = Vₑ[5:length(Vₑ)]
    
    ## GLMakie ##
    println("Draw")
    Draw(state[1], "Forward analysis")

    return state, ϵᵥ, Vₑₓ
end 