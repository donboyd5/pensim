# Pension simulation
# Don Boyd
# 2022-01-06  -- prior was 2/11/2014

# %% conclusions about speed and methods
# full loops within a function is fastest
# vectorized outside a function slower but also fast
# vectorized within a function considerably slower but still fast
# loops outside a function very slow

# %% imports
using BenchmarkTools
using CSV
using DataFrames
using Distributions
using Printf
using Statistics

# now load local modules

include("jl/pensim_functions.jl")
import .pensimFunctions as psf

# %% define Parameters
nsims = convert(Int64, 1e5)
nyears = 100
include("jl/test_params.jl")

# %% checks
a, b = psf.runit(10, 20)
typeof(a)
check =  runit(10, 20)
typeof(check)
check[1]
check[2]

# %% benchmark tests
# for loop
@benchmark include("jl/test_forloop.jl")

# loop function median ~ 159ms
@benchmark a, b = psf.runit(nsims, nyears) setup=(nsims=nsims, nyears=nyears)
# vectorized function median ~ 281ms
@benchmark c, d = psf.runitv(nsims, nyears) setup=(nsims=nsims, nyears=nyears)

# %% examine results
quantile(d[1:nsims, nyears])
quantile(assetseoy[1:nsims, nyears]) # summary stats, final year

finalyear = assetseoy[1:nsims, nyears]
median(finalyear)
mean(finalyear)
std(finalyear)


