
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
for i = 1:nsims # sims
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
