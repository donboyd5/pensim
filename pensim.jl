# Pension simulation
# Don Boyd
# Jan 5, 2022  -- prior was 2/11/2014

using DataFrames
using Distributions
using BenchmarkTools
using Statistics
using Printf
using CSV

include("pensim_functions.jl")
import .pensimFunctions as psf

# %% conclusions
# full loops within a function is fastest
# vectorized outside a function slower but also fast
# vectorized within a function considerably slower but still fast
# loops outside a function very slow

# %% set up problem for loops
# nsims = 1e5
# nsims = convert(Int64, nsims)
nsims = convert(Int64, 1e5)
nyears = 100
irmean = .08
irsd = .12

ipay = .05
paygrow = .03

iben = .04
bengrow = .08

icontrib = .05
contribgrow = .01

assets0 = 100

@time ir = rand(Normal(irmean, irsd), nsims, nyears)
# @benchmark rand(Normal(irmean, irsd), nsims, nyears) setup=(irmean=irmean, irsd=irsd, nsims=nsims, nyears=nyears)

# array preallocation: https://stackoverflow.com/questions/56011774/julia-pre-allocate-array-vs-matlab-pre-allocate-array/56012875
assetsboy = Array{Float64, 2}(undef, nsims, nyears)  # uninitialized
assetseoy = similar(assetsboy)
ii = similar(assetsboy)

payroll = Vector{Float64}(undef, nyears)
payroll[1] = ipay * assets0
for y = 2:nyears payroll[y] = payroll[y-1] * (1 + paygrow) end

benefits = similar(payroll)
benefits[1] = iben * assets0
for y= 2:nyears benefits[y] = benefits[y-1] * (1 + bengrow) end

contrib = similar(payroll)
contrib[1] = icontrib * assets0
for y = 2:nyears contrib[y] = contrib[y-1] * (1 + contribgrow) end

# %%.. simple for loop median ~ 3.7 seconds
@benchmark for i = 1:nsims # sims
  #if mod(i,2000)==0 println(i) end
  # initialize assetsboy and assetseoy in year 1
  assetsboy[i,1] = assets0
  assetseoy[i,1] = assetsboy[i,1] * (1+ir[i,1])
    for y = 2:nyears # years
      assetsboy[i,y] = assetseoy[i,y-1]
      ii[i, y] = (assetsboy[i, y] + (contrib[y] - benefits[y])/2) * ir[i, y]
      assetseoy[i,y] = assetsboy[i, y] + ii[i, y]
      end
  end

# %% ..repeat, vectorized median ~ 188ms plus whatever setup time there is
assetsboy2 = similar(assetsboy)
assetseoy2 = similar(assetseoy)
ii2 = similar(ii)

# initialize assetsboy and assetseoy in year 1
fill!(assetsboy2[:,1], assets0)
assetseoy2[:, 1] = assetsboy2[:,1] .* (1 .+ ir[:,1])  # note the ., for broadcasting

# loop just through the years
@benchmark for y = 2:nyears # years
  assetsboy2[:,y] = assetseoy2[:,y-1]
  ii2[:, y] = (assetsboy2[:, y] .+ (contrib[y] - benefits[y])/2) .* ir[:, y]
  assetseoy2[:,y] = assetsboy2[:, y] .+ ii2[:, y]
  end # ~ 200 ms


# %% function approach median ~ 169ms
function runit(nsims, nyears)
  nsims = convert(Int64, nsims)
  irmean = .08
  irsd = .12
  ipay = .05
  paygrow = .03
  iben = .04
  bengrow = .08
  icontrib = .05
  contribgrow = .01
  assets0 = 100

  ir = rand(Normal(irmean, irsd), nsims, nyears)
  assetsboy = Array{Float64, 2}(undef, nsims, nyears)  # uninitialized
  assetseoy = similar(assetsboy)
  ii = similar(assetsboy)

  payroll = Vector{Float64}(undef, nyears)
  payroll[1] = ipay * assets0
  for y = 2:nyears payroll[y] = payroll[y-1] * (1 + paygrow) end

  benefits = similar(payroll)
  benefits[1] = iben * assets0
  for y= 2:nyears benefits[y] = benefits[y-1] * (1 + bengrow) end

  contrib = similar(payroll)
  contrib[1] = icontrib * assets0
  for y = 2:nyears contrib[y] = contrib[y-1] * (1 + contribgrow) end

  # main loop
  for i = 1:nsims # sims
    #if mod(i,2000)==0 println(i) end
    assetsboy[i,1] = assets0
    assetseoy[i,1] = assetsboy[i,1] * (1+ir[i,1])
      for y = 2:nyears # years
        assetsboy[i,y] = assetseoy[i,y-1]
        ii[i, y] = (assetsboy[i, y] + (contrib[y] - benefits[y])/2) * ir[i, y]
        assetseoy[i,y] = assetsboy[i, y] + ii[i, y]
        end
    end
    return assetsboy, assetseoy
end

a, b = runit(10, 20)

a, b = psf.runit(10, 20)

typeof(a)
typeof(b)
a
b

@benchmark c, d = runit(nsims, nyears) setup=(nsims=nsims, nyears=nyears)
typeof(c)
size(c)

check =  runit(10, 20)
typeof(check)
check[1]
check[2]

# %% function approach with vectorization within function median ~ 267ms
function runitv(nsims, nyears)
  nsims = convert(Int64, nsims)
  irmean = .08
  irsd = .12
  ipay = .05
  paygrow = .03
  iben = .04
  bengrow = .08
  icontrib = .05
  contribgrow = .01
  assets0 = 100

  ir = rand(Normal(irmean, irsd), nsims, nyears)
  assetsboy = Array{Float64, 2}(undef, nsims, nyears)  # uninitialized
  assetseoy = similar(assetsboy)
  ii = similar(assetsboy)

  payroll = Vector{Float64}(undef, nyears)
  payroll[1] = ipay * assets0
  for y = 2:nyears payroll[y] = payroll[y-1] * (1 + paygrow) end

  benefits = similar(payroll)
  benefits[1] = iben * assets0
  for y= 2:nyears benefits[y] = benefits[y-1] * (1 + bengrow) end

  contrib = similar(payroll)
  contrib[1] = icontrib * assets0
  for y = 2:nyears contrib[y] = contrib[y-1] * (1 + contribgrow) end

  # initialize assetsboy and assetseoy in year 1
  fill!(assetsboy[:,1], assets0)
  assetseoy[:, 1] = assetsboy[:,1] .* (1 .+ ir[:,1])  # note the ., for broadcasting

  # loop through years
  for y = 2:nyears # years
    assetsboy[:,y] = assetseoy[:,y-1]
    ii[:, y] = (assetsboy[:, y] .+ (contrib[y] - benefits[y])/2) .* ir[:, y]
    assetseoy[:,y] = assetsboy[:, y] .+ ii[:, y]
    end

  return assetsboy, assetseoy
end

a, b = runit(10, 20)
a, b = runitv(10, 20)

# vectorized function median ~ 281ms
@benchmark e, f = runitv(nsims, nyears) setup=(nsims=nsims, nyears=nyears)

# loop function median ~ 159ms
@benchmark c, d = runit(nsims, nyears) setup=(nsims=nsims, nyears=nyears)

# %% examine results
quantile(d[1:nsims, nyears])
quantile(assetseoy[1:nsims, nyears]) # summary stats, final year

finalyear = assetseoy[1:nsims, nyears]
median(finalyear)
mean(finalyear)
std(finalyear)


# %% misc notes and tests
h = 5, 10, 15 #
typeof(h)
h= 5, "a"
typeof(h)

# writing a short function without the word "function"
mse(y, ŷ) = mean((y - ŷ).^2)
mse([1, 2, 3], [4, 5, 6])

mae(y, ŷ) = mean(abs.(y - ŷ))
mae([1, 2, 3], [4, 5, 6])

# %%..broadcasting and vectorized operations
# https://towardsdatascience.com/vectorize-everything-with-julia-ad04a1696944
# You can use the broadcast operator . to apply an operation — in this case, addition — to all elements of an object.
x = [1, 2, 3]
x .+ 1  # vectorized - add 1 to each element of x

# arrays
A = [1 2;
     3 4]
A
A .+ 1
A[:, :] .+ 1
A[:, 2] .+ 1
A[:, 2] = [7, 9]
A

