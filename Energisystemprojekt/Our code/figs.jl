using Plots, StatsPlots
annual_elec = AxisArray(zeros(numregions, numplants), REGION, PLANT)
installed_cap = AxisArray(zeros(numregions, numplants), REGION, PLANT)
elec_germany = AxisArray(zeros(numplants, length(147:651)), PLANT, 147:651)
for r in REGION
    for p in PLANT
        annual_elec[r, p] = sum(Electricity_result[r, p, :])
        installed_cap[r, p] = Capacity_result[r, p]
    end
end
for p in PLANT
    elec_germany[p, :] = Electricity_result[:DE, p, 147:651]
end

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
    labels = ["Hydro" "Gas" "Wind" "PV" "Nuclear"]
)
savefig(AnnualProd_fig, "AnnualProd.png")
savefig(InstalledCapac_fig, "InstalledCapac.png")

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
savefig(Ger_ProdLoad, "Ger_ProdLoad.png")