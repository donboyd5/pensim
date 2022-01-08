module pensimFunctions

# export, using, import statements are usually here; we discuss these below
using Distributions

# include("file1.jl")
# include("file2.jl")

# "This is a docstring.?"



"""
    runit(nsims, nyears, p)

Run a simulation with `nsims` for each of `nyears`, using paramaters `p``.

The results from each year depend on results for the previous year.

# Examples
```julia-repl
julia> runit(10000, 10, p)
1
```
"""
function runit(nsims, nyears, p)
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

    ir = rand(Normal(p.irmean, p.irsd), p.nsims, p.nyears)

    assetsboy = Array{Float64, 2}(undef, p.nsims, p.nyears)  # uninitialized
    assetseoy = similar(assetsboy)
    ii = similar(assetsboy)

    payroll = Vector{Float64}(undef, p.nyears)
    payroll[1] = p.ipay * p.assets0
    for y = 2:p.nyears payroll[y] = payroll[y-1] * (1 + p.paygrow) end

    benefits = similar(payroll)
    benefits[1] = p.iben * p.assets0
    for y= 2:p.nyears benefits[y] = benefits[y-1] * (1 + p.bengrow) end

    contrib = similar(payroll)
    contrib[1] = p.icontrib * p.assets0
    for y = 2:p.nyears contrib[y] = contrib[y-1] * (1 + p.contribgrow) end

    # main loop
    for i = 1:p.nsims # sims
      #if mod(i,2000)==0 println(i) end
      assetsboy[i,1] = p.assets0
      assetseoy[i,1] = assetsboy[i,1] * (1 + ir[i,1])
        for y = 2:p.nyears # years
          assetsboy[i,y] = assetseoy[i,y-1]
          ii[i, y] = (assetsboy[i, y] + (contrib[y] - benefits[y])/2) * ir[i, y]
          assetseoy[i,y] = assetsboy[i, y] + ii[i, y]
          end
      end
      return assetsboy, assetseoy
  end

"""
    runit_old(nsims, nyears)

Run a simulation with `nsims` for each of `nyears`.

The results from each year depend on results for the previous year.

# Examples
```julia-repl
julia> runit_old(10000, 10)
1
```
"""
function runit_old(nsims, nyears)
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


end