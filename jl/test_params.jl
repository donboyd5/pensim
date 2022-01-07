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

ir = rand(Normal(irmean, irsd), nsims, nyears)
