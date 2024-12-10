using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask

#include("bar_element_dev.jl")


# cross secitonal area (m²)
cs_area = 0.01 #eksempel
# Young's modulus - Steel
y_mod = 200e9
# mass - Steel (kg/m³)
mass = 7850.
# standard acceleration of gravity
g = 9.81

const 𝕣 = Float64

model           = Model(:TestModel) 
n1              = addnode!(model,[0., 0.])
n2              = addnode!(model,[1., 0.])
n3              = addnode!(model,[-0.3, 1.])

e1 = addelement!(model, Hold, [n1]; field=:tx1)
e2 = addelement!(model, Hold, [n1]; field=:tx2)
e3 = addelement!(model, Hold, [n2]; field=:tx1)
e4 = addelement!(model, Hold, [n2]; field=:tx2)
e5 = addelement!(model, BarElement, [n2, n3]; y_mod, cs_area, g, mass)
e6 = addelement!(model, BarElement, [n1, n3]; y_mod, cs_area, g, mass)

initialstate    = initialize!(model) # Initializes model
state           = solve(SweepX{0};initialstate,time=[0.,1.],verbose=false)

tx1,_           = getdof(state,field=:tx1,nodID=[n3]) # Returns: dofresidual, dofID


req             = @request F
eleres          = getresult(state,req,[e5]) 
iele,istep      = 1,2
force           = eleres[iele,istep].F

# Forces on element 5:

eleres          = getresult(state,req,[e5]) 
iele,istep      = 1,2
force_5           = eleres[iele,istep].F

println("Forces on element 5: ", force_5)

# Forces on element 6:

eleres          = getresult(state,req,[e6]) 
iele,istep      = 1,2
force_6           = eleres[iele,istep].F

println("Forces on element 6: ", force_6)


println("No bugs!")