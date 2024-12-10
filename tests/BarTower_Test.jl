using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

GLMakie.activate!()

# cross secitonal area (m²)
cs_area = 0.01 #eksempel
# Young's modulus - Steel
y_mod = 200e9
# mass - Steel (kg/m³)
mass = 7850.
# standard acceleration of gravity
g = 9.81
# Number of nodes in the tower
nNodes = 10
# Width of tower
tWidth = 2.0
# Distance between two vertically connected nodes. Distance between n₁ and n₃ is nHeight/2. 
nHeight=2.0
# Type of UDof
type = "test"
# Scale of UDof
scale = 1000000.
const 𝕣 = Float64

model           = Model(:TestModel) 


Vₙ, Vₑ = BuildTower(model, nNodes, tWidth, nHeight, y_mod, cs_area, g, mass)

Fᵁ = GenerateExFs(nNodes, type, scale) # Endre tittel

Vₑᵁ  = ApplyExFs(model, nNodes, Vₙ, Fᵁ)

initialstate    = initialize!(model) # Initializes model


state           = solve(SweepX{0};initialstate,time=[0.,1.],verbose=false)



## GLMakie ##

fig = Figure()
ax = Axis(fig[1, 1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1))
#hidedecorations!(ax)

println(typeof(state))

draw(ax,state[1])

## End of GLMakie ##########


tx1,_           = getdof(state,field=:tx1,nodID=[Vₙ[3]]) # Returns: dofresidual, dofID

#=
req1             = @request F
eleres1          = getresult(state,req1,[Vₑ[5]]) 
iele,istep      = 1,2
#println("eleres1: ", keys(eleres1[iele,istep]))
force_5           = eleres1[iele,istep].F
# Forces on element 5:
println("Forces on element 5: ", force_5)
=#

t = 2
ϵᵥ = ExtractMeasurements(state, Vₑ,t)

println(ϵᵥ)
#=
req2            = @request Fₐ
eleres2          = getresult(state,req2,[Vₑ[5]]) 
iele,istep      = 1,2
println("eleres2: ", keys(eleres2[iele,istep]))
f_5_direc   = eleres2[iele,istep].Fₐ   # Directional axial forces

println("Directional axial forces on element 5: ", f_5_direc)
=#


# Add error to axial stress to obtain measurements

# Inverse method


# Show GLMakie figure
fig
