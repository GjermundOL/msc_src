using Muscade
using StaticArrays
using LinearAlgebra
using GLMakie


const 𝕣 = Float64

# vector projection
#vec_proj(vec::Vector{<:Number}, proj_vec::Vector{<:Number}) = dot(vec,proj_vec)/dot(proj_vec, proj_vec)*proj_vec

####

#når jeg tilfører element, kaller den funksjonen BarElement
struct BarElement <:AbstractElement
    length:: 𝕣
    axial_stiffness:: 𝕣 #google youngs modulus, youngs*areal/lengde
    weight:: 𝕣
    Vₚ :: Vector{𝕣} 
    coords :: Vector{Vector{Float64}}
end


function BarElement(nod::Vector{Node}; y_mod::𝕣, cs_area::𝕣, g::𝕣, mass::𝕣)
    coords = coord(nod)
    Vₚ = coords[2]-coords[1]
    length = sqrt(LinearAlgebra.dot(Vₚ, Vₚ))
    axial_stiffness = y_mod*cs_area/length
    weight = g*mass*cs_area*length
    return BarElement(length, axial_stiffness, weight, Vₚ, coords)
end



Muscade.doflist(::Type{<:BarElement})=(inod=(1,1,2,2),class=ntuple(i->:X,4), field=(:tx1,:tx2,:tx1,:tx2))

@espy function Muscade.residual(o::BarElement, X,U,A,t,SP,dbg)

    X₀  = ∂0(X)
    #println("delta_X: ", X₀)
    #println("Coords: ", o.coords)
    #println("delta_X type:", typeof(X₀))


    coord₁ = o.coords[1] + [X₀[1], X₀[2]]  # Coordinates of nᵢ 
    coord₂ = o.coords[2] + [X₀[3], X₀[4]]  # Coordinates of nⱼ 

    Vₚᵗ = coord₂ - coord₁   # Vector from nᵢ to nⱼ 
    Lᵗ = norm(Vₚᵗ)    # Length of element
    ΔL = Lᵗ - o.length      # Difference in length compared to original length
    ☼ϵ = ΔL/o.length        # Length change ratio
    ☼Fₐ = o.axial_stiffness * ϵ   # Axial forces
    uₚᵗ = Vₚᵗ / Lᵗ          # Unit vector parallel to Vₚᵗ

    Fᵥ = Fₐ * uₚᵗ   # Force vector acting on node₂. Force vector acting on node₁ is -Fᵥ.

    ☼F = SVector(-Fᵥ[1], o.weight/2 - Fᵥ[2], Fᵥ[1], o.weight/2 + Fᵥ[2])


    return F, noFB
end

function Muscade.draw(::Type{<:BarElement}, axe,o, Λ,X,U,A, t,SP,dbg;kwargs...)

    X₀ = ∂0(X) # Matrise, X₀[idof, iel]
    
    xs = []
    ys = []

    for j = 1:length(X₀[1,:])
        
        Δx₁ = X₀[1, j]
        Δy₁ = X₀[2, j]
        Δx₂ = X₀[3, j]
        Δy₂ = X₀[4, j]

        Δn₁ = [Δx₁, Δy₁]
        Δn₂ = [Δx₂, Δy₂]

        n₁, n₂ = o[j].coords[1] + Δn₁, o[j].coords[2] + Δn₂
        
        append!(xs, [n₁[1], n₂[1]])
        append!(ys, [n₁[2], n₂[2]])
        if j != length(X₀[1,:])
            append!(xs, [NaN])
            append!(ys, [NaN])
        end
        
        #println("j = ", j, ", xs: ", xs)
        #println("j = ", j, ", ys: ", ys)

    end
    
    lines!(axe, xs, ys ;kwargs...)
end

Muscade.draw(::Type{<:AbstractElement}, axe,o, Λ,X,U,A, t,SP,dbg;kwargs...) = nothing


#@show methods(Muscade.residual)


###### TEST  AV RESIDUAL ##############################################################
#=
elmnt = BarElement([model.nod[n1], model.nod[n2]])

node₁ = model.nod[elmnt.nodID[1]]   # Node element n1
node₂ = model.nod[elmnt.nodID[2]]   # Node element n2

coord₁ = node₁.coord -[0.00001,0.00001]   # Coordinates of n1
coord₂ = node₂.coord +[0.00001,0.00001]   # Coordinates of n2

Vₚᵗ = coord₂ - coord₁   # Vector from n1 to n2
Lᵗ = sqrt(dot(Vₚᵗ, Vₚᵗ))    # Length of element
ΔL = Lᵗ - elmnt.length      # Difference in length compared to original length
Fₐ = elmnt.axial_stiffness * ΔL     # Axial forces
uₚᵗ = Vₚᵗ / Lᵗ          # Unit vector parallel to Vₚᵗ

Fᵥ = Fₐ * uₚᵗ   # Force vector acting on node₂. Force vector acting on node₁ is -Fᵥ.

F = SVector(-Fᵥ[1], elmnt.weight/2 - Fᵥ[2], Fᵥ[1], elmnt.weight/2 + Fᵥ[2])
=#
########################################################################################################
