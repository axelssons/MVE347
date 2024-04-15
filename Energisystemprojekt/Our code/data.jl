using CSV, DataFrames, AxisArrays
folder = dirname(@__FILE__)
#Sets
REGION = [:DE, :SE, :DK]
PLANT = [:Hydro, :Gas, :Wind, :PV] # Add all plants
HOUR = 1:8760

#Parameters
numregions = length(REGION)
numhours = length(HOUR)
numplants = length(PLANT)

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


myinf=1e8
maxcaptable = [                                                             # GW
# PLANT      DE             SE              DK       
:Hydro       0              14              0       
:Gas         myinf          myinf           myinf  
:Wind       180             280             90
:PV         460             75              60       
]
maxcap = AxisArray(maxcaptable[:,2:end]'.*1000, REGION, PLANT) # MW

RunningCost=AxisArray([0.1, 2, 0.1, 0.1], PLANT)
FuelCost=AxisArray([0,22,0,0], PLANT)
Efficiency=AxisArray([1,0.4,1,1], PLANT)

dr=0.05 #discountrate
IC=AxisArray([0, 550, 1100, 600],PLANT)
Lifetime=AxisArray([80, 30, 25, 25],PLANT)
AC=AxisArray(zeros(numplants), PLANT)
for p in PLANT
    AC[p]=IC[p]*dr/(1-1/(1+dr)^Lifetime[p])#Beräknar avskrivningsvärdet
end

