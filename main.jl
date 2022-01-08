# Pension simulation
# Don Boyd
# 2022-01-07  -- prior was 2/11/2014

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
# using Printf
using Statistics

# %% load local modules
include("jl/pensim_functions.jl")
import .pensimFunctions as psf

include("jl/pensim_types.jl")
using .pensimTypes

# %% define Parameters
nsims = convert(Int64, 1e5)
nyears = 100
include("jl/test_params.jl")

params = PenParams(irmean=.09)
params
params.nsims = 10000
params.nsims = convert(Int64,1e7)
params.nyears = 50
params

# %% checks
# a, b = psf.runit(10, 20)
# typeof(a)
# check =  runit(10, 20)
# typeof(check)
# check[1]
# check[2]

# %% run main function
a, b = psf.runit(nsims, nyears, params)
a
b

# examine results
p = (0., .1, .25, .5, .75, .9, 1)
# typeof(p)
quantile(b[1:nsims, nyears], p)
quantile(assetseoy[1:nsims, nyears], p) # summary stats, final year

finalyear = assetseoy[1:nsims, nyears]
median(finalyear)
mean(finalyear)
std(finalyear)
quantile(finalyear, p)

# %% benchmark tests
# for loop
@benchmark include("jl/test_forloop.jl")

# loop function median ~ 159ms
@benchmark a, b = psf.runit_old(nsims, nyears) setup=(nsims=nsims, nyears=nyears)
# vectorized function median ~ 281ms
@benchmark c, d = psf.runitv(nsims, nyears) setup=(nsims=nsims, nyears=nyears)

# %% examine results from benchmark test
p = (0., .1, .25, .5, .75, .9, 1)
# typeof(p)
quantile(b[1:nsims, nyears], p)
quantile(assetseoy[1:nsims, nyears], p) # summary stats, final year

finalyear = assetseoy[1:nsims, nyears]
median(finalyear)
mean(finalyear)
std(finalyear)
quantile(finalyear, p)



