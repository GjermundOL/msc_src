using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64

function ForwardAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, folder_name, folder_path; displayTower=false, saveTower=false, drawForces = false)

    model           = Model(:TestModel) 

    Vₙ, Vₑ = BuildTower(model, nNodes, tWidth, nHeight, E, cs_area, g, mass)

    Fᴱ = GenerateExFs(nNodes, ex_type, ex_scale)

    Vₑᶠ  = ApplyExFs(model, nNodes, Vₙ, Fᴱ)

    initialstate    = initialize!(model)

    state           = solve(SweepX{0};initialstate,time=[0.,1.], maxiter = 100, verbose = false)

    t = 2
    Sᵗ = ExtractMeasurements(state, Vₑ,t)

    Vₑₓ = Vₑ[5:length(Vₑ)]
    
    if displayTower || saveTower
        if drawForces
            DrawTower(state[1], "Forward analysis", folder_name, folder_path, 0.; displayTower = displayTower, saveTower = saveTower, externalForces = Fᴱ, externalElements = Vₑᶠ, ex_scale = ex_scale)
        else
            DrawTower(state[1], "Forward analysis", folder_name, folder_path, 0.; displayTower = displayTower, saveTower = saveTower)
        end
    end

    return state, Sᵗ, Vₑₓ, Fᴱ, Vₑᶠ
end 