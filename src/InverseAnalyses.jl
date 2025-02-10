using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64

function InverseAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, Sᵐ, Vₑₘ, β, ex_scale, folder_name, folder_path, ϕ; displayTower=false, saveTower=false, drawForces = false)
    
    model           = Model(:TestModel) 
    Vₙ, Vₑ, Vᵤ = BuildInverseTower(model, nNodes, Sᵐ, Vₑₘ, β, tWidth, nHeight, E, cs_area, g, mass)

    initialstate    = initialize!(model)

    stateXUA           = solve(DirectXUA{0,0,0};initialstate,time=0:1.:7, maxiter = 100, verbose = false)

    Sⁱ = ExtractMeasurements(stateXUA, Vₑ,1)
    
    Fᴱᵢₙᵥᶸᵗˣ¹ = getdof(stateXUA[1];class=:U,field=:utx1)
    Fᴱᵢₙᵥᶸᵗˣ² = getdof(stateXUA[1];class=:U,field=:utx2)
    Fᴱᵢₙᵥ = collect(Iterators.flatten(zip(Fᴱᵢₙᵥᶸᵗˣ¹, Fᴱᵢₙᵥᶸᵗˣ²)))

    if displayTower || saveTower
        if drawForces
            DrawTower(stateXUA[2], "Inverse analysis", folder_name, folder_path, ϕ; displayTower = displayTower, saveTower = saveTower, externalForces = Fᴱᵢₙᵥ, externalElements = Vᵤ, ex_scale = ex_scale)
        else
            DrawTower(stateXUA[2], "Inverse analysis", folder_name, folder_path, ϕ; displayTower = displayTower, saveTower = saveTower)
        end
    end
    return stateXUA, Sⁱ, Fᴱᵢₙᵥ 
end