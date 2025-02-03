module MasterTask

    #using  Printf,SparseArrays,StaticArrays,LinearAlgebra
    using StaticArrays, LinearAlgebra
    
    include("BarElements.jl")
    export BarElement

    include("Towers.jl")
    export BuildTower
    export BuildInverseTower
    export elcost

    include("ExternalForces.jl")
    export GenerateExFs
    export ApplyExFs

    include("ForwardAnalyses.jl")
    export ForwardAnalysis

    include("InverseAnalyses.jl")
    export InverseAnalysis

    include("Extractions.jl")
    export ExtractMeasurements
    export MeasuredElements
    export ExtractForces

    include("Drawings.jl")
    export DrawTower
    export DrawSingleErrors
    export DrawDiscrepancy
    export DrawLCurve
    export DrawSingleBar
    export DrawRegStrat
    export DrawErrors

    include("Structures.jl")
    export Structure

    include("Results.jl")
    export SaveResults
    export GenerateFileName
    export GenerateFolderName

    include("Tests.jl")
    export TestRegStrat

end