# I den här filen kan ni stoppa all inputdata. 
# Läs in datan ni fått som ligger på Canvas genom att använda paketen CSV och DataFrames

using CSV, DataFrames

function read_input()
println("\nReading Input Data...")
folder = dirname(@__FILE__)

#Sets
REGION = [:DE, :SE, :DK]
PLANT = [:Hydro, :Gas, :Wind, :PV] # Add all plants
HOUR = 1:8760

#Parameters
numregions = length(REGION)
numhours = length(HOUR)

timeseries = CSV.read("$folder\\TimeSeries.csv", DataFrame)
cf = AxisArray(ones(numregions, numplants, numhours), REGION, PLANT, HOUR)
# wind_cf = AxisArray(ones(numregions, numhours), REGION, HOUR)
# pv_cf = AxisArray(ones(numregions, numhours), REGION, HOUR)
load = AxisArray(zeros(numregions, numhours), REGION, HOUR)
 
    for r in REGION
        cf[r, :Wind, :]=timeseries[:, "Wind_"*"$r"]
        cf[r, :PV, :]=timeseries[:, "PV_"*"$r"]
        # wind_cf[r, :]=timeseries[:, "Wind_"*"$r"]                                   # 0-1, share of installed cap
        # pv_cf[r, :]=timeseries[:, "PV_"*"$r"]
        load[r, :]=timeseries[:, "Load_"*"$r"]                                        # [MWh]
    end

myinf = 1e8
maxcaptable = [                                                             # GW
        # PLANT      DE             SE              DK       
        :Hydro       0              14              0       
        :Gas         myinf          myinf           myinf  
        :Wind       180             280             90
        :PV         460             75              60       
        ]

maxcap = AxisArray(maxcaptable[:,2:end]'.*1000, REGION, PLANT) # MW


discountrate=0.05


    return (; REGION, PLANT, HOUR, numregions, load, maxcap, cf)

end # read_input
