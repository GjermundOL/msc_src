using Muscade
using StaticArrays
using LinearAlgebra

const 𝕣 = Float64

function GenerateExFs(nNodes::Integer, ex_type::String, ex_scale::𝕣)
    
    Fᵁ_dir = rand(-1:0.001:1,2) # Direction of Fᵁ

    Fᵁ_dir_unit = Fᵁ_dir/norm(Fᵁ_dir) # Unit vector of Fᵁ
    
    Fᵁ = Array{𝕣}(undef, 0)

    if ex_type == "random"

        dev = ex_scale*0.3 # Deviation
        
        for i = 1:nNodes-2
            θ = rand(-2*pi/8 : pi/1000 : 2*pi/8)
            rot_mat = Matrix{𝕣}(undef, 2, 2)
            rot_mat[1,1], rot_mat[1,2], rot_mat[2,1], rot_mat[2,2] = cos(θ), -sin(θ), sin(θ), cos(θ)
            
            Fᵁᵢ = rand(ex_scale - dev: dev/100 : ex_scale + dev) * rot_mat*Fᵁ_dir_unit
            
            append!(Fᵁ, [Fᵁᵢ[1], Fᵁᵢ[2]])
        end
    end
    
    if ex_type == "test"

        Fᵁ_dir = [0.5, 0.5] # Direction of Fᵁ

        Fᵁ_dir_unit = Fᵁ_dir/norm(Fᵁ_dir) # Unit vector of Fᵁ
        
        Fᵁᵢ = ex_scale*Fᵁ_dir_unit
        
        for i = 1:nNodes-2
            append!(Fᵁ, [Fᵁᵢ[1], Fᵁᵢ[2]])
        end
    end

    return Fᵁ

end


function ApplyExFs(model::Model, nNodes::Integer, Vₙ::Vector{Muscade.NodID}, Fᵁ::Vector{𝕣})
    Vₑ = []

    for i = 3:nNodes

        eᵢˣ = addelement!(model, DofLoad, [Vₙ[i]];field=:tx1,value=t->Fᵁ[2*i-5])
        eᵢʸ = addelement!(model, DofLoad, [Vₙ[i]];field=:tx2,value=t->Fᵁ[2*i-4])

        append!(Vₑ, [eᵢˣ, eᵢʸ])
    end
    
    return Vₑ
end