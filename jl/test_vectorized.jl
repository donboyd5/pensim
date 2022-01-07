
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
