using Muscade
using StaticArrays
using LinearAlgebra


function ExtractMeasurements(state, Vₑ::Vector{Muscade.EleID},t::Int64)
    #req = @request δL
    #eleres = getresult(state, req, Vₑ[5:length(Vₑ)])
    #ax_strains = [k.δL for k in eleres[:,t]]

    #eleobjs = state[t].model.eleobj

    #for i=1:length(eleobjs)

    #    println("nr: ", i,". eleobj: ", eleobjs[i])
    
    #end
    
    #println("X: ", state[t].X)


    req = @request δL
    ax_strains = []
    for E in Vₑ[5:length(Vₑ)]

        #describe(state[t].model, E)

        # eleobj
        eleobj_typ = typeof(state[t].model.eleobj[E.ieletyp][E.iele])
        #println("eleobj : ", eleobj_typ )

        

        #println("typeof(eleobj): ", eleobj_typ)


        if eleobj_typ == BarElement

            #println("innenfor if-statement BarElement")

            eleres = getresult(state[t], req, [E])
        
            #println("eleres: ", eleres)

            #println("Element type: ", state[t].model.ele[E].ieletyp)

            append!(ax_strains, eleres[1].δL)

        elseif eleobj_typ <: ElementCost

            #println("innenfor if-statement ElementCost")
            
            eleres = getresult(state[t], @request(eleres), [E])
        
            #println("eleres: ", eleres)

            #println("Element type: ", state[t].model.ele[E].ieletyp)

            append!(ax_strains, eleres[1].eleres.δL)
        end
    end

    #println("ax_strains: ", ax_strains)
    return ax_strains
end


function ExtractMeasurements(state, Vₑ::Vector{Muscade.EleID},t::Vector{Int64})
    req = @request δL
    eleres = getresult(state, req, Vₑ[5:length(Vₑ)])
    ax_strains = []
    for tᵢ in t
        ax_strainsᵢ = [k.δL for k in eleres[:,tᵢ]]
        append!(ax_strains, [ax_strainsᵢ])
    end
    return ax_strains
end

function MeasuredElements(measurements, Vₑₓ, δLₑᵣᵣ)
    Vₑₓⁱⁿ  = [El.iele for El in Vₑₓ]

    if measurements == "every"
        Vₑₘ = Vₑₓⁱⁿ
        δLₘ = δLₑᵣᵣ
    elseif measurements == "second"
        Vₑₘ = Vₑₓⁱⁿ[1:2:length(Vₑₓⁱⁿ)]
        δLₘ = δLₑᵣᵣ[1:2:length(δLₑᵣᵣ)]
    elseif measurements == "tenth"
        Vₑₘ = Vₑₓⁱⁿ[1:10:length(Vₑₓⁱⁿ)]
        δLₘ = δLₑᵣᵣ[1:10:length(δLₑᵣᵣ)]
    elseif measurements == "twentyfifth"
        Vₑₘ = Vₑₓⁱⁿ[1:25:length(Vₑₓⁱⁿ)]
        δLₘ = δLₑᵣᵣ[1:25:length(δLₑᵣᵣ)]
    elseif measurements == "single"
        Vₑₘ = [Vₑₓⁱⁿ[14]]
        δLₘ = [δLₑᵣᵣ[14]]
    else
        throw(ArgumentError("No measurment method with name ", measurements, "."))
    end

    return Vₑₘ, δLₘ
end

function ExtractForces(state, Vₑₓ, Fᵁ, nNodes; t = 2)
    
    req = @request F
    Fₜₒₜ = zeros(𝕣, 2*nNodes)
    

    for E in Vₑₓ

        # eleobj
        eleobj_typ = typeof(state[t].model.eleobj[E.ieletyp][E.iele])
        #println("eleobj : ", eleobj_typ )
        #println("typeof(eleobj): ", eleobj_typ)


        if eleobj_typ == BarElement

            #println("innenfor if-statement BarElement")

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

            #println("innenfor if-statement ElementCost")
            
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

    #sjekk tegn, print før og etter og sjekk
    Fₜₒₜ = Fₜₒₜ[5:length(Fₜₒₜ)] + Fᵁ

    return Fₜₒₜ
end

#function ExtractMeasurement(state, Vₑ::Vector{Muscade.EleID},t::Int64)
    
#    req = @request δL
#    eleres = getresult(state, req, Vₑ[5:length(Vₑ)])
#    ax_strains = [k.δL for k in eleres[:,t]]

#    return ax_strains
#end
