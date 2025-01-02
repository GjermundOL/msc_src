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

    eleobjs = state[t].model.eleobj

    for i=1:length(eleobjs)

        println("nr: ", i,". eleobj: ", eleobjs[i])
    
    end
    
    #println("X: ", state[t].X)


    req = @request δL
    ax_strains = []
    for E in Vₑ[5:length(Vₑ)]
        eleres = getresult(state, req, [E])
        
        println("eleres: ", eleres)

        println("Element type: ", state[t].model.ele[E].ieletyp)

        append!(ax_strains, eleres[t].δL)
    end

    println("ax_strains: ", ax_strains)
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