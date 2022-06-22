
# %% installs
# using Pkg
# Pkg.add("Downloads")
# Pkg.add("XLSX")


# %% imports
using Downloads
using HTTP

using DataFrames
using CSV
using XLSX

# %% notes
# https://docs.julialang.org/en/v1/stdlib/Downloads/
# https://juliabyexample.helpmanual.io/

# %% get actuarial tables
# https://www.soa.org/research/tables-calcs-tools/
# https://mort.soa.org/
# https://www.soa.org/globalassets/assets/files/research/exp-study/research-2014-rp-mort-tab-rates-exposure.xlsx
# 3123,	RP-2014, Rates-Total Dataset, RP-2014 Rates-Total Dataset Male,	Annuitant, Mortality, United States of America
#  Aggregate, [Excel Excel 2007 CSV XML]
# https://mort.soa.org/Export.aspx?Type=xls&TableIdentity=3123
# https://mort.soa.org/Export.aspx?Type=csv&TableIdentity=3123
urlc = "https://mort.soa.org/Export.aspx?Type=csv&TableIdentity=3123"
urlx = "https://mort.soa.org/Export.aspx?Type=xls&TableIdentity=3123"

Downloads.download(urlc, "data/actuarial/temp.csv")
Downloads.download(urlx, "data/actuarial/temp.xlsx")
Base.download(urlc, "data/actuarial/temp.csv")
Base.download(urlx, "data/actuarial/temp.xlsx")
HTTP.download(urlc, "data/actuarial/temp.csv")

# %% parse data
df = CSV.read("data/actuarial/Export.csv", DataFrame)
df

# xf = XLSX.readxlsx("data/actuarial/Export.xlsx")

xf = XLSX.readxlsx("data/actuarial/research-2014-rp-mort-tab-rates-exposure.xlsx")
XLSX.sheetnames(xf)
sh = xf["Total Dataset"] # get a reference to a Worksheet
sh[4, 2] # access element "B4" (4th row, 2nd column)
sh["B4"]
sh["B4:F107"]

# make a dataframe
DataFrame(sh["B4:F107"], :auto)
sh["B5:F107"]
# DataFrame(sh["B5:F107"], vec(sh["B4:F4"]))  # does not work

#
xfn = "data/actuarial/research-2014-rp-mort-tab-rates-exposure.xlsx"
XLSX.readdata(xfn, "Total Dataset", "B4:F107")  # get matrix
sh[:] # all data inside worksheet's dimension
xf["Total Dataset!B4:F107"] # you can also query values using a sheet reference

df = DataFrame(XLSX.readtable(xfn, "Total Dataset")...)
df = DataFrame(XLSX.readtable(xfn, "Total Dataset", "D:F"; first_row=4, stop_in_empty_row=false)...)
df


# https://stackoverflow.com/questions/51746403/julia-convert-array-to-dataframe-with-column-names
x = rand(4, 3)
df = DataFrame(x)
names!(df, [:Col_A, :Col_B, :Col_C])

