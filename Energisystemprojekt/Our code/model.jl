using JuMP, AxisArrays, Gurobi, UnPack


function buildmodel(data_file)
    include(data_file)

    m = Model()

    @variable(m, Electricity[r in REGION, p in PLANT, h in HOUR] >=0)
    @variable(m, Capacity[r in REGION, p in PLANT] >=0)
    @variable(m, WaterLevel[h in HOUR] >= 0)

    @objective(m, Min, 
        sum(Capacity[r,p]*AC[p]+Electricity[r,p,h]*RunningCost[p]+Electricity[r,p,h]/Efficiency[p]*FuelCost[p] for p in PLANT for r in REGION for h in HOUR)
    )

    @constraint(m, waterlevel, WaterLevel[1] == WaterLevel[8760])
    for r in REGION
        for p in PLANT
            @constraint(m, capacity, Capacity[r, p] <= maxcaptable[r, p])
            for h in HOUR
                @constraint(m, load, Electricity[r, p, h] >= load[r, h])
                @constraint(m, production, Electricity[r, p, h] <= Capacity[r, p] * cf[r, p, h])
            end
        end
    end
    for h in 2:8759
        @constraint(m, waterchange, WaterLevel[h+1] == WaterLevel[h] + hydro_inflow[h] - Electricity[:SE, :Hydro, h])
    end

    return m, Capacity, Electricity
end