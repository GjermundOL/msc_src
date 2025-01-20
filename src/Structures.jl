using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask


# cs_area:  cross secitonal area (m²)
# E:        Young's modulus
# mass:     Steel (kg/m³)
# g:        standard acceleration of gravity
# nNodes:   Number of nodes in the tower
# tWidth:   Width of tower
# nHeight:  Distance between two vertically connected nodes. Distance between n₁ and n₃ is nHeight/2. 
# ex_type:  Type of external forces
# ex_scale:    Scale of external forces
# σᵤʳᵉˡ:    Relative standard deviation of external forces
# σᵤ:       Standard deviation of external forces
# σₗ:        Relative standard deviation of measurements

function Structure(name)

    if name == "test"
        cs_area = 0.01 
        E = 200e9 # Steel
        mass = 7850. # Steel
        g = 9.81
        nNodes = 4
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e2
        σᵤʳᵉˡ = 1.
        σᵤ = ex_scale*σᵤʳᵉˡ
        σₗ = 1.e-8

    elseif name == "100_nodes"
        cs_area = 0.01 
        E = 200e9 # Steel
        mass = 7850. # Steel
        g = 9.81
        nNodes = 100
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e2
        σᵤʳᵉˡ = 1.
        σᵤ = ex_scale*σᵤʳᵉˡ
        σₗ = 1.e-7

    elseif name == "100_nodes_test"
        cs_area = 0.01 
        E = 200e9 # Steel
        mass = 7850. # Steel
        g = 9.81
        nNodes = 100
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e3
        σᵤʳᵉˡ = 1.
        σᵤ = ex_scale*σᵤʳᵉˡ
        σₗ = 1.e-7

    elseif name == "50_nodes"
        cs_area = 0.01 
        E = 200e9 # Steel
        mass = 7850. # Steel
        g = 9.81
        nNodes = 50
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e2
        σᵤʳᵉˡ = 1.
        σᵤ = ex_scale*σᵤʳᵉˡ
        σₗ = 1.e-7

    elseif name == "40_nodes"
        cs_area = 0.01 
        E = 200e9 # Steel
        mass = 7850. # Steel
        g = 9.81
        nNodes = 40
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e2
        σᵤʳᵉˡ = 1.
        σᵤ = ex_scale*σᵤʳᵉˡ
        σₗ = 1.e-7

    elseif name == "20_nodes"
        cs_area = 0.01 
        E = 200e9 # Steel
        mass = 7850. # Steel
        g = 9.81
        nNodes = 20
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e2
        σᵤʳᵉˡ = 1.
        σᵤ = ex_scale*σᵤʳᵉˡ
        σₗ = 1.e-7

    elseif name == "draw_tower_20"
        cs_area = 0.01 
        E = 200e9 # Steel
        mass = 7850. # Steel
        g = 9.81
        nNodes = 20
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e3
        σᵤʳᵉˡ = 1.
        σᵤ = ex_scale*σᵤʳᵉˡ
        σₗ = 1.e-6

    else
        println()
        throw(ArgumentError("No structure with name ", name, "."))
    end
    return cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σᵤʳᵉˡ, σᵤ, σₗ
end
