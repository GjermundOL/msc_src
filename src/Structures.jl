using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask


# Aᶜˢ:  cross secitonal area (m²)
# E:        Young's modulus
# density:     Steel (kg/m³)
# g:        standard acceleration of gravity
# nNodes:   Number of nodes in the tower
# tWidth:   Width of tower
# nHeight:  Distance between two vertically connected nodes. Distance between n₁ and n₃ is nHeight/2. 
# ex_type:  Type of external forces
# ex_scale:    Scale of external forces
# σᶠʳᵉˡ:    Relative standard deviation of external forces
# σᶠ:       Standard deviation of external forces
# σˢ:        Relative standard deviation of measurements

function Structure(name)

    if name == "test"
        Aᶜˢ = 0.01 
        E = 200e9 # Steel
        density = 7850. # Steel
        g = 9.81
        nNodes = 4
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e2
        σᶠʳᵉˡ = 1.
        σᶠ = ex_scale*σᶠʳᵉˡ
        σˢ = 1.e-8

    elseif name == "100_nodes"
        Aᶜˢ = 0.01 
        E = 200e9 # Steel
        density = 7850. # Steel
        g = 9.81
        nNodes = 100
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e2
        σᶠʳᵉˡ = 1.
        σᶠ = ex_scale*σᶠʳᵉˡ
        σˢ = 1.e-7

    elseif name == "100_nodes_random"
        Aᶜˢ = 0.01 
        E = 200e9 # Steel
        density = 7850. # Steel
        g = 9.81
        nNodes = 100
        tWidth = 2.0
        nHeight=2.0
        ex_type = "random"
        ex_scale = 1.e2
        σᶠʳᵉˡ = 1.
        σᶠ = ex_scale*σᶠʳᵉˡ
        σˢ = 1.e-7

    elseif name == "100_nodes_test"
        Aᶜˢ = 0.01 
        E = 200e9 # Steel
        density = 7850. # Steel
        g = 9.81
        nNodes = 100
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e3
        σᶠʳᵉˡ = 1.
        σᶠ = ex_scale*σᶠʳᵉˡ
        σˢ = 1.e-7

    elseif name == "100_nodes_test2"
        Aᶜˢ = 0.01 
        E = 200e9 # Steel
        density = 7850. # Steel
        g = 9.81
        nNodes = 100
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e4
        σᶠʳᵉˡ = 1.
        σᶠ = ex_scale*σᶠʳᵉˡ
        σˢ = 1.e-6

    elseif name == "100_nodes_test_soft"
        Aᶜˢ = 0.01 
        E = 200e7 # dunno
        density = 1000. # dunno
        g = 9.81
        nNodes = 100
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e4
        σᶠʳᵉˡ = 1.
        σᶠ = ex_scale*σᶠʳᵉˡ
        σˢ = 1.e-4

    elseif name == "50_nodes"
        Aᶜˢ = 0.01 
        E = 200e9 # Steel
        density = 7850. # Steel
        g = 9.81
        nNodes = 50
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e2
        σᶠʳᵉˡ = 1.
        σᶠ = ex_scale*σᶠʳᵉˡ
        σˢ = 1.e-7

    elseif name == "40_nodes"
        Aᶜˢ = 0.01 
        E = 200e9 # Steel
        density = 7850. # Steel
        g = 9.81
        nNodes = 40
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e2
        σᶠʳᵉˡ = 1.
        σᶠ = ex_scale*σᶠʳᵉˡ
        σˢ = 1.e-7

    elseif name == "20_nodes"
        Aᶜˢ = 0.01 
        E = 200e9 # Steel
        density = 7850. # Steel
        g = 9.81
        nNodes = 20
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e2
        σᶠʳᵉˡ = 1.
        σᶠ = ex_scale*σᶠʳᵉˡ
        σˢ = 1.e-7

    elseif name == "draw_tower_50"
        Aᶜˢ = 0.01 
        E = 200e9 # Steel
        density = 7850. # Steel
        g = 9.81
        nNodes = 50
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e4
        σᶠʳᵉˡ = 1.
        σᶠ = ex_scale*σᶠʳᵉˡ
        σˢ = 1.e-6

    elseif name == "draw_tower_20"
        Aᶜˢ = 0.01 
        E = 200e9 # Steel
        density = 7850. # Steel
        g = 9.81
        nNodes = 20
        tWidth = 2.0
        nHeight=2.0
        ex_type = "test"
        ex_scale = 1.e4
        σᶠʳᵉˡ = 1.
        σᶠ = ex_scale*σᶠʳᵉˡ
        σˢ = 1.e-6

    else
        throw(ArgumentError("No structure with name ", name, "."))
    end
    return Aᶜˢ, E, density, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σᶠʳᵉˡ, σᶠ, σˢ
end
