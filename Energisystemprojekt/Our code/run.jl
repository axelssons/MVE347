using Gurobi
using JuMP


include("model.jl")
include("data.jl")
#1
m, Capacity, Electricity= buildmodel("data.jl")

#2
#m, Capacity, Electricity, Batteries = buildmodel("data.jl")

set_optimizer_attribute(m, "LogLevel", 1)
set_optimizer(m, Gurobi.Optimizer) #m is model from model file
#set_optimizer_attribute(m, "NumericFocus", 2)

#optimizing
status = optimize!(m)

if termination_status(m) == MOI.OPTIMAL
    println("\nSolve status: Optimal")   
elseif termination_status(m) == MOI.TIME_LIMIT && has_values(m)
    println("\nSolve status: Reached the time-limit")
else
    error("The model was not solved correctly.")
end

Cost_result = objective_value(m)/1000000 # M€
Capacity_result = value.(Capacity)
Electricity_result = value.(Electricity)
Batteries_result = value.(Batteries)
CO2 = 0.202/0.4*sum(Electricity_result[r,:Gas,h] for r in REGION for h in HOUR)

println("Cost (M€): ", Cost_result)
println("Annual Electricity production: ", annual_elec)
print(installed_cap)
println("\n CO2 emissions: ",CO2)
