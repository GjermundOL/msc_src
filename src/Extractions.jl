using Muscade
using StaticArrays
using LinearAlgebra

function ExtractMeasurements(state, Vₑ::Vector{Muscade.EleID},t::Int64)
    req = @request ϵ
    eleres = getresult(state, req, Vₑ[5:length(Vₑ)])
    ax_strains = [k.ϵ for k in eleres[:,t]]
    return ax_strains
end

function ExtractMeasurements(state, Vₑ::Vector{Muscade.EleID},t::Vector{Int64})
    req = @request ϵ
    eleres = getresult(state, req, Vₑ[5:length(Vₑ)])
    ax_strains = []
    for tᵢ in t
        ax_strainsᵢ = [k.ϵ for k in eleres[:,tᵢ]]
        append!(ax_strains, [ax_strainsᵢ])
    end
    return ax_strains
end