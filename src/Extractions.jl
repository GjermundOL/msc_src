using Muscade
using StaticArrays
using LinearAlgebra


function ExtractMeasurements(state, Vₑ::Vector{Muscade.EleID},t::Int64)

    req = @request S
    ax_strains = []
    for E in Vₑ[5:length(Vₑ)]

        eleobj_typ = typeof(state[t].model.eleobj[E.ieletyp][E.iele])

        if eleobj_typ == BarElement

            eleres = getresult(state[t], req, [E])

            append!(ax_strains, eleres[1].S)

        elseif eleobj_typ <: ElementCost
            
            eleres = getresult(state[t], @request(eleres), [E])
        
            append!(ax_strains, eleres[1].eleres.S)
        end
    end

    return ax_strains
end


function ExtractMeasurements(state, Vₑ::Vector{Muscade.EleID},t::Vector{Int64})
    req = @request S
    eleres = getresult(state, req, Vₑ[5:length(Vₑ)])
    ax_strains = []
    for tᵢ in t
        ax_strainsᵢ = [k.S for k in eleres[:,tᵢ]]
        append!(ax_strains, [ax_strainsᵢ])
    end
    return ax_strains
end

function MeasuredElements(measurements, Vₑₓ, Sₑᵣᵣ)
    Vₑₓⁱⁿ  = [El.iele for El in Vₑₓ]
    Sₑᵣᵣ⁻¹ = copy(Sₑᵣᵣ)
    if measurements == "every"
        Vₑₘ = Vₑₓⁱⁿ
        Sᵐ = Sₑᵣᵣ
        inds = collect(1:length(Sₑᵣᵣ))
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "second"
        Vₑₘ = Vₑₓⁱⁿ[1:2:length(Vₑₓⁱⁿ)]
        Sᵐ = Sₑᵣᵣ[1:2:length(Sₑᵣᵣ)]
        inds = collect(1:2:length(Sₑᵣᵣ))
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "fifth"
        Vₑₘ = Vₑₓⁱⁿ[1:5:length(Vₑₓⁱⁿ)]
        Sᵐ = Sₑᵣᵣ[1:5:length(Sₑᵣᵣ)]
        inds = collect(1:5:length(Sₑᵣᵣ))
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "tenth"
        Vₑₘ = Vₑₓⁱⁿ[5:10:length(Vₑₓⁱⁿ)]
        Sᵐ = Sₑᵣᵣ[5:10:length(Sₑᵣᵣ)]
        inds = collect(5:10:length(Sₑᵣᵣ))
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "fifteenth"
        Vₑₘ = Vₑₓⁱⁿ[10:15:length(Vₑₓⁱⁿ)]
        Sᵐ = Sₑᵣᵣ[10:15:length(Sₑᵣᵣ)]
        inds = collect(10:15:length(Sₑᵣᵣ))
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "twentieth"
        Vₑₘ = Vₑₓⁱⁿ[10:20:length(Vₑₓⁱⁿ)]
        Sᵐ = Sₑᵣᵣ[10:20:length(Sₑᵣᵣ)]
        inds = collect(10:20:length(Sₑᵣᵣ))
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "twentyfifth"
        Vₑₘ = Vₑₓⁱⁿ[10:25:length(Vₑₓⁱⁿ)]
        Sᵐ = Sₑᵣᵣ[10:25:length(Sₑᵣᵣ)]
        inds = collect(10:25:length(Sₑᵣᵣ))
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "thirtyfifth"
        Vₑₘ = Vₑₓⁱⁿ[10:35:length(Vₑₓⁱⁿ)]
        Sᵐ = Sₑᵣᵣ[10:35:length(Sₑᵣᵣ)]
        inds = collect(10:35:length(Sₑᵣᵣ))
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "fiftieth"
        Vₑₘ = Vₑₓⁱⁿ[10:50:length(Vₑₓⁱⁿ)]
        Sᵐ = Sₑᵣᵣ[10:50:length(Sₑᵣᵣ)]
        inds = collect(10:50:length(Sₑᵣᵣ))
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "seventyfifth"
        Vₑₘ = Vₑₓⁱⁿ[10:75:length(Vₑₓⁱⁿ)]
        Sᵐ = Sₑᵣᵣ[10:75:length(Sₑᵣᵣ)]
        inds = collect(10:75:length(Sₑᵣᵣ))
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "hundredth"
        Vₑₘ = Vₑₓⁱⁿ[10:100:length(Vₑₓⁱⁿ)]
        Sᵐ = Sₑᵣᵣ[10:100:length(Sₑᵣᵣ)]
        inds = collect(10:100:length(Sₑᵣᵣ))
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "tenth_most_low"
        inds = [4,8,13,17,21,26,31,36,42,49,57,66,75,86,97,109,124,145,158,186]
        Vₑₘ = [Vₑₓⁱⁿ[i] for i in inds]
        Sᵐ = [Sₑᵣᵣ[i] for i in inds]
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "tenth_low"
        inds = [1,2,3,5,6,8,10,13,15,17,20,24,28,34,39,46,53,72,86,93]
        Vₑₘ = [Vₑₓⁱⁿ[i] for i in inds]
        Sᵐ = [Sₑᵣᵣ[i] for i in inds]
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "thirtyfifth_most_low"
        inds = [11, 28, 49, 68, 87, 130]
        Vₑₘ = [Vₑₓⁱⁿ[i] for i in inds]
        Sᵐ = [Sₑᵣᵣ[i] for i in inds]
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "thirtyfifth_low"
        inds = [4, 11, 26, 47, 64, 86]
        Vₑₘ = [Vₑₓⁱⁿ[i] for i in inds]
        Sᵐ = [Sₑᵣᵣ[i] for i in inds]
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "thirtyfifth_very_low"
        inds = [2, 5, 9, 14, 20, 27]
        Vₑₘ = [Vₑₓⁱⁿ[i] for i in inds]
        Sᵐ = [Sₑᵣᵣ[i] for i in inds]
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "single_middle"
        Vₑₘ = [Vₑₓⁱⁿ[100]]
        Sᵐ = [Sₑᵣᵣ[100]]
        inds = [100]
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    elseif measurements == "single_high"
        Vₑₘ = [Vₑₓⁱⁿ[180]]
        Sᵐ = [Sₑᵣᵣ[180]]
        inds = [180]
        deleteat!(Sₑᵣᵣ⁻¹, inds)
    else
        throw(ArgumentError("No measurment method with name ", measurements, "."))
    end

    return Vₑₘ, Sᵐ, Sₑᵣᵣ⁻¹
end

function ExtractForces(state, Vₑₓ, Fᵁ, nNodes; t = 2)
    
    req = @request F
    Fₜₒₜ = zeros(𝕣, 2*nNodes)
    

    for E in Vₑₓ

        # eleobj
        eleobj_typ = typeof(state[t].model.eleobj[E.ieletyp][E.iele])

        if eleobj_typ == BarElement

            nods = state[t].model.ele[E].nodID

            nodsₙᵣ = [i.inod for i in nods]

            eleres = getresult(state[t], req, [E])
            
            # Forces on element E
            Fₑ = eleres[1].F

            # Forces on nod 1 in element E
            Fₑ¹ = Fₑ[1:2]
            # Forces on nod 2 in element E
            Fₑ² = Fₑ[3:4]

            Fₜₒₜ[nodsₙᵣ[1]*2-1] += Fₑ¹[1]
            Fₜₒₜ[nodsₙᵣ[1]*2] += Fₑ¹[2]
            Fₜₒₜ[nodsₙᵣ[2]*2-1] += Fₑ²[1]
            Fₜₒₜ[nodsₙᵣ[2]*2] += Fₑ²[2]

        elseif eleobj_typ <: ElementCost
            
            eleres = getresult(state[t], @request(eleres), [E])
            
            Fₑ = eleres[1].eleres.F
            # Forces on nod 1 in element E
            Fₑ¹ = Fₙₛ[1:2]
            # Forces on nod 2 in element E
            Fₑ² = Fₙₛ[3:4]
            
            Fₜₒₜ[nodsₙᵣ[1]*2-1] += Fₑ¹[1]
            Fₜₒₜ[nodsₙᵣ[1]*2] += Fₑ¹[2]
            Fₜₒₜ[nodsₙᵣ[2]*2-1] += Fₑ²[1]
            Fₜₒₜ[nodsₙᵣ[2]*2] += Fₑ²[2]
        end
    end

    Fₜₒₜ = Fₜₒₜ[5:length(Fₜₒₜ)] + Fᵁ

    return Fₜₒₜ
end