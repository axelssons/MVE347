using JuMP, AxisArrays, Gurobi, UnPack


function buildmodel(data_file)
    include(data_file)

    m = Model()

    @variable(m, Electricity[r in REGION, p in PLANT, h in HOUR] >=0)
    @variable(m, Capacity[r in REGION, p in PLANT] >=0)
    @variable(m, WaterLevel[h in HOUR] >= 0)
    @variable(m, Transmission[r in REGION, r in REGION] >= 0)

    @objective(m, Min,
        sum(Capacity[r, p]*AC[p] for r in REGION for p in PLANT) + sum(Electricity[r, p, h]*RörligCost[p] for p in PLANT for r in REGION for h in HOUR)
    )

    for r in REGION
        for p in PLANT
            for h in HOUR
                @constraint(m, Electricity[r, p, h] <= Capacity[r, p] * cf[r, p, h])
            end
            @constraint(m, Capacity[r, p] <= maxcap[r, p])
        end
    end

    for r in REGION
        for h in HOUR
            @constraint(m, sum(Electricity[r, :, h]) >= load[r, h])
        end
    end

    @constraint(m, WaterLevel[1] == WaterLevel[8760])
    for h in 1:8759
        @constraint(m, WaterLevel[h+1] == WaterLevel[h] + hydro_inflow[h] - Electricity[:SE, :Hydro, h])
        @constraint(m, WaterLevel[h] <= maxcap_water)
    end

    for r1 in REGION
        for r2 in REGION
            if r1 == r2
                @constraint(m, Transmission[r1, r2] == 0)
            else
                @constraint(m, Transmission[r1, r2] <= myinf)
            end
        end
    end

    return m, Capacity, Electricity
end