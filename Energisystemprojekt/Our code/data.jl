using CSV, DataFrames, AxisArrays
folder = dirname(@__FILE__)
#Sets
REGION = [:DE,:SE,:DK]
PLANT = [:Hydro, :Gas, :Wind, :PV ]#:Nuclear] # Add all plants
HOUR = 1:8760

#Parameters
numregions = length(REGION)
numhours = length(HOUR)
numplants = length(PLANT)

timeseries = CSV.read("$folder/TimeSeries.csv", DataFrame)
cf = AxisArray(ones(numregions, numplants, numhours), REGION, PLANT, HOUR)
load = AxisArray(zeros(numregions, numhours), REGION, HOUR)
hydro_inflow = timeseries[:, "Hydro_inflow"]
 
for r in REGION
    cf[r, :Wind, :]=timeseries[:, "Wind_"*"$r"]
    cf[r, :PV, :]=timeseries[:, "PV_"*"$r"]
    load[r, :]=timeseries[:, "Load_"*"$r"]                                        # [MWh]
end

MaxNuc=0
myinf = 1e8
maxcaptable = [                                                             # GW
# PLANT      DE             SE              DK       
:Hydro       0              14              0       
:Gas         myinf          myinf           myinf  
:Wind        180            280             90
:PV          460            75              60 
#:Nuclear     MaxNuc         MaxNuc          MaxNuc      
]
maxcap = AxisArray(maxcaptable[:, 2:end]'.*1000, REGION, PLANT) # MW

maxcap_water = 33*10^6
BatteriesCap = myinf

#RunningCost = AxisArray([0.1, 2, 0.1, 0.1, 4], PLANT)
#FuelCost = AxisArray([0, 22, 0, 0, 3.2], PLANT)
#Efficiency = AxisArray([1, 0.4, 1, 1, 0.4], PLANT)

RörligCost = AxisArray([0.1,2+22/0.4,0.1,0.1],PLANT) #,4+3.2/0.4


CO2cap=0.1*1.3877448499264726e8

dr = 0.05 #discountrate
IC = AxisArray([0, 55, 1100, 600]*1000, PLANT)
Lifetime = AxisArray([80, 30, 25, 25], PLANT)
AC = AxisArray(zeros(numplants), PLANT)
for p in PLANT
    AC[p] = IC[p] * dr/(1-1/((1+dr)^Lifetime[p])) #Beräknar avskrivningsvärdet
end
bAC = 150*1000*0.05/(1 - 1/(1.05)^10)
tAC = 2500*1000*0.05/(1 - 1/(1.05)^50)
