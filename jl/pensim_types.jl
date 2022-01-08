module pensimTypes

using Parameters
export PenParams

@with_kw mutable struct PenParams
    # Parameters package and macro @with_kw allow keywords and default values
    nsims = 10
    nyears = 30
    irmean = .07
    irsd = .12
    ipay = .05
    paygrow = .03
    iben = .04
    bengrow = .08
    icontrib = .05
    contribgrow = .01
    assets0 = 100
end

end