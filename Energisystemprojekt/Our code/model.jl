using JuMP, AxisArrays, Gurobi, UnPack


function buildmodel(data_file)
    include(data_file)


    m = Model()

    @variables m begin
        Electricity[r in REGION, p in PLANT, h in HOUR] >=0 #production
        Capacity[r in REGION, p in PLANT] >=0 #built in capacity
    end

    @objective(m, Min, 
        sum(Capacity[r,p]*AC[p]+Electricity[r,p,h]*RunningCost[p]+Electricity[r,p,h]/Efficiency[p]*FuelCost[p] for p in PLANT for r in REGION for h in HOUR)
    )

    @constraints m begin
        Electricity[r in REGION, p in PLANT, h in HOUR] <= Capacity[r in REGION, p in PLANT] * cf[r in REGION, p in PLANT, h in HOUR]  
        Electricity[r in REGION, p in PLANT, h in HOUR] >= load[r in REGION, h in HOUR]
    end

    return m, Capacity, Electricity
end