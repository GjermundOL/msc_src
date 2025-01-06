using Muscade
using StaticArrays
using LinearAlgebra

function ExtractMeasurement(state, Vₑ::Vector{Muscade.EleID},t::Int64)
    
    req = @request δL
    eleres = getresult(state, req, Vₑ[5:length(Vₑ)])
    ax_strains = [k.δL for k in eleres[:,t]]

    return ax_strains
end

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
    else
        throw(ArgumentError("No measurment method with name ", measurements, "."))
    end

    return Vₑₘ, δLₘ
end