using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64

function ForwardAnalysis(cs_area, y_mod, mass, g, nNodes, tWidth, nHeight, type, scale)


    model           = Model(:TestModel) 


    Vₙ, Vₑ = BuildTower(model, nNodes, tWidth, nHeight, y_mod, cs_area, g, mass)

    Fᵁ = GenerateExFs(nNodes, type, scale) # Endre tittel

    Vₑᵁ  = ApplyExFs(model, nNodes, Vₙ, Fᵁ)

    initialstate    = initialize!(model) # Initializes model


    state           = solve(SweepX{0};initialstate,time=[0.,1.],verbose=false)

    tx1,_           = getdof(state,field=:tx1,nodID=[Vₙ[3]]) # Returns: dofresidual, dofID


    t = 2
    ϵᵥ = ExtractMeasurements(state, Vₑ,t)

    Vₑₓ = Vₑ[5:length(Vₑ)]
    
    ## GLMakie ##
    Draw(state[1], "Forward analysis")

    return state, ϵᵥ, Vₑₓ
end 