module MasterTask

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
    export DrawRegStratParameter
    export DrawErrors

    include("Structures.jl")
    export Structure

    include("Results.jl")
    export SaveResults
    export GenerateFileName
    export GenerateFolderName
    export SaveFullResults

    include("Tests.jl")
    export TestRegStratParameter
    export SecondDerivative
    export QuasiOptimality
    export TestRegStrat

end