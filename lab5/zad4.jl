using CSV, DataFrames, Plots, Polynomials, LinearAlgebra
using Polynomials: ChebyshevT

df = CSV.read("results_c_opt.csv", DataFrame)
x = Float64.(df.size)
y = df.naive

# Normalizacja do [-1, 1]
function normalize_to_chebyshev(x)
    xmin, xmax = extrema(x)
    return 2 * (x .- xmin) / (xmax - xmin) .- 1
end

x_cheb = normalize_to_chebyshev(x)

# Dopasowanie: wielomian Czebyszewa 5. stopnia
# Create Chebyshev basis polynomials using current API
basis = [ChebyshevT([zeros(k)..., 1.0]) for k in 0:10]
V = hcat([p.(x_cheb) for p in basis]...)
coeffs = V \ y
poly_cheb = sum(coeffs[i] * basis[i] for i in 1:length(basis))
y_fit_cheb = poly_cheb.(x_cheb)

# Dla porównania: zwykłe dopasowanie
poly_normal = fit(x, y, 10)
y_fit_normal = poly_normal.(x)

# Wykres
plot(x, y, label="Dane (naive)", marker=:circle)
plot!(x, y_fit_normal, label="Zwykły wielomian", lw=2, ls=:dash)
plot!(x, y_fit_cheb, label="Czebyszew", lw=2, ls=:dot)
xlabel!("Rozmiar macierzy (n)")
ylabel!("Czas (s)")
title!("Zniwelowanie efektu Rungego - Czebyszew vs zwykły wielomian")
savefig("runge_chebyshev_fixed.png")

