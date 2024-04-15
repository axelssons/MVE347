using Gurobi

include("model.jl")
m, Capacity, Electricity = buildmodel("data.jl")
print(m)

