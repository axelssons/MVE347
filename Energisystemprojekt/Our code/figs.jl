using Plots, StatsPlots

PLANTB=[:Hydro, :Gas, :Wind, :PV, :Batteries]
annual_elec = AxisArray(zeros(numregions, numplants), REGION, PLANT)
installed_cap = AxisArray(zeros(numregions, numplants+1), REGION, PLANTB)
elec_germany = AxisArray(zeros(numplants, length(147:651)), PLANT, 147:651)
transmission_cap = AxisArray(zeros(6), [:SEDE, :DESE, :DKDE, :DEDK, :SEDK,:DKSE])
transmission = AxisArray(zeros(6), [:SEDE, :DESE, :DKDE, :DEDK, :SEDK,:DKSE])

for r in REGION
    for p in PLANT
        annual_elec[r, p] = sum(Electricity_result[r, p, :])
        installed_cap[r, p] = Capacity_result[r, p]
    end
    installed_cap[r, :Batteries] = Batteries_result[r]
end

for p in PLANT
    elec_germany[p, :] = Electricity_result[:DE, p, 147:651]
end

transmission_cap[:SEDE] = TransCap_result[:SE, :DE]
transmission_cap[:DKDE] = TransCap_result[:DK, :DE]
transmission_cap[:DESE] = TransCap_result[:DE, :SE]
transmission_cap[:DEDK] = TransCap_result[:DE, :DK]
transmission_cap[:SEDK] = TransCap_result[:SE, :DK]
transmission_cap[:DKSE] = TransCap_result[:DK, :SE]

transmission[:SEDE] = sum(Transmission_result[:SE, :DE, :])
transmission[:DKDE] = sum(Transmission_result[:DK, :DE, :])
transmission[:DESE] = sum(Transmission_result[:DE, :SE, :])
transmission[:DEDK] = sum(Transmission_result[:DE, :DK, :])
transmission[:SEDK] = sum(Transmission_result[:SE, :DK, :])
transmission[:DKSE] = sum(Transmission_result[:DK, :SE, :])

AnnualProd_fig = groupedbar(
    annual_elec,
    bar_position = :stack,
    bar_width = 0.7,
    xticks=(1:12, string.(collect(REGION))),
    labels = ["Hydro" "Gas" "Wind" "PV" "Nuclear"]
)
InstalledCapac_fig = groupedbar(
    installed_cap,
    bar_position = :stack,
    bar_width = 0.7,
    xticks=(1:12, string.(collect(REGION))),
    labels = ["Hydro" "Gas" "Wind" "PV" "Batteries" "Nuclear"]
)
InstalledTransmission_fig = bar(
    transmission_cap,
    bar_position = :stack,
    bar_width = 0.7,
    xticks=(1:12, string.(collect([:SEDE, :DESE, :DKDE, :DEDK, :SEDK,:DKSE]))),
    labels = "Transmission"
)
TotalTransmission_fig = bar(
    transmission_cap,
    bar_position = :stack,
    bar_width = 0.7,
    xticks=(1:12, string.(collect([:SEDE, :DESE, :DKDE, :DEDK, :SEDK,:DKSE]))),
    labels = "Transmission"
)

savefig(AnnualProd_fig, "AnnualProd3")
savefig(InstalledCapac_fig, "InstalledCapac3")
savefig(InstalledTransmission_fig, "InstalledTrans3")
savefig(TotalTransmission_fig, "TotalTrans3")

areaplot(
    147:641,
    elec_germany', 
    fillalpha = [0.4 0.4 0.4],
    labels = ["Hydro" "Gas" "Wind" "PV" "Nuclear"]
)
Ger_ProdLoad = plot!(
    147:651, 
    load[:DE, 147:651],
    linecolor = "black",
    labels = "Load"
)
savefig(Ger_ProdLoad, "Ger_ProdLoad3.png")