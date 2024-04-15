using Gurobi
using JuMP

include("model.jl")
m, Capacity, Electricity = buildmodel("data.jl")
print(m)

set_optimizer_attribute(m, "LogLevel", 1)
set_optimizer(m, Gurobi.Optimizer) #m is model from model file
set_optimizer_attribute(m, "NumericFocus", 2)

#optimizing
optimize!(m)


