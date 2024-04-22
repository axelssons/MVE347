using JuMP, AxisArrays, Gurobi, UnPack


function buildmodel(data_file)
    include(data_file)

    m = Model()

    @variable(m, Electricity[r in REGION, p in PLANT, h in HOUR] >=0)
    @variable(m, Capacity[r in REGION, p in PLANT] >=0)
    @variable(m, WaterLevel[h in HOUR] >= 0)
   
    #3
    @variable(m, Transmission[r1 in REGION, r2 in REGION, h in HOUR] >= 0)
    @variable(m, TransCap[r1 in REGION, r2 in REGION] >=0)


    #2b
    @variable(m, Batteries[r in REGION] >= 0)
    @variable(m, BatteriesCharge[r in REGION, h in HOUR]>=0)
    @variable(m, In[r in REGION, h in HOUR]>=0)
    @variable(m, Out[r in REGION, h in HOUR]>=0)

    @objective(m, Min,
        sum(Capacity[r, p]*AC[p] for r in REGION for p in PLANT) + sum(Electricity[r, p, h]*RörligCost[p] for p in PLANT for r in REGION for h in HOUR) 
        + bAC*sum(Batteries[r] for r in REGION) + sum(BatteriesCharge[r,h]*0.1 for r in REGION for h in HOUR) 
        + (tAC * sum(Transmission[r1,r2] for r1 in REGION for r2 in REGION))/2
    )

    
    @constraint(m, Cap[r in REGION, p in PLANT, h in HOUR], Electricity[r, p, h] <= Capacity[r, p] * cf[r, p, h])
    
    @constraint(m, Installed[r in REGION, p in PLANT], Capacity[r, p] <= maxcap[r, p])

    #LOAD
    #1
    #@constraint(m, Prod[r in REGION, h in HOUR], sum(Electricity[r, :, h]) >= load[r, h])
    #2b
    #@constraint(m, Prod[r in REGION, h in HOUR], sum(Electricity[r, :, h]) + 0.9*Out[r,h] - In[r,h] >= load[r, h])
    #3
    @constraint(m, Prod[r in REGION, h in HOUR], sum(Electricity[r, :, h]) + 0.9*Out[r,h] - In[r,h] + sum(0.98*Transmission[r2,r]-Transmission[r,r2] for r2 in REGION) >= load[r, h])

   

    @constraint(m, WaterLevel[1] == WaterLevel[8760])
    for h in 1:8759
        @constraint(m, WaterLevel[h+1] == WaterLevel[h] + hydro_inflow[h] - Electricity[:SE, :Hydro, h])
    end
    for h in HOUR
        @constraint(m, WaterLevel[h] <= maxcap_water)
    end

for h in HOUR
    for r1 in REGION
        for r2 in REGION
            if r1 == r2
                @constraint(m, Transmission[r1, r2, h] == 0)
            else
                @constraint(m, Transmission[r1, r2, h] <= TransCap[r1, r2])
            end
        end
    end
end


    #2a
    @constraint(m, 0.202/0.4*sum(Electricity[r,:Gas,h] for r in REGION for h in HOUR) <= CO2cap)

    #2b
    @constraint(m, BatFL[r in REGION], BatteriesCharge[r,1]==BatteriesCharge[r,8760])
    @constraint(m, BatCha[r in REGION, h in 1:8759], BatteriesCharge[r, h+1] == BatteriesCharge[r, h] + In[r,h] - Out[r,h])
    @constraint(m, BatChaLasth[r in REGION], Out[r,8760]<=BatteriesCharge[r,8759])
    @constraint(m, BatCap[r in REGION, h in HOUR], BatteriesCharge[r,h] <= Batteries[r])

    return m, Capacity, Electricity, Batteries, Transmission
end