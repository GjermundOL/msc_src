using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64

function ForwardAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, folder_name, folder_path; displayTower=false, saveTower=false, drawForces = false)


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
    state           = solve(SweepX{0};initialstate,time=[0.,1.], maxiter = 100)

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
    
    if displayTower || saveTower
        if drawForces
            DrawTower(state[1], "Forward analysis", folder_name, folder_path, "forward"; displayTower = displayTower, saveTower = saveTower, externalForces = Fᵁ, externalElements = Vₑᵁ, ex_scale = ex_scale)
        else
            DrawTower(state[1], "Forward analysis", folder_name, folder_path, "forward"; displayTower = displayTower, saveTower = saveTower)
        end
    end

    return state, δLᵥ, Vₑₓ, Fᵁ, Vₑᵁ
end 