include("zad1_2_3_5.jl")
using Plots
using Interpolations
using Polynomials

# Definicja funkcji Rungego
f(x) = 1/(1+25*x^2)

# Liczba punktów interpolacyjnych
n = 21
xs = LinRange(-1, 1, n)    # Changed: removed collect()
ys = f.(xs)

# Interpolacja funkcją składaną liniową
linear_itp = LinearInterpolation(xs, ys)

# Interpolacja funkcją składaną sześcienną (splajn naturalny)
cubic_itp = CubicSplineInterpolation(xs, ys)

# Interpolacja wielomianowa (stopień n-1)
p = fit(xs, ys, n-1)

# Punkty do rysowania wykresów
x_dense = LinRange(-1, 1, 500)
y_true    = f.(x_dense)
y_linear  = [linear_itp(x) for x in x_dense]
y_cubic   = [cubic_itp(x) for x in x_dense]
y_poly    = p.(x_dense)

# Rysowanie wykresów
plot(x_dense, y_true, lw=3, label="Funkcja Rungego", legend=:topright)
plot!(x_dense, y_linear, lw=2, ls=:dash, label="Sklejane liniowe")
plot!(x_dense, y_cubic, lw=2, ls=:dot, label="Sklejane sześcienne")
plot!(x_dense, y_poly, lw=2, ls=:dashdot, label="Interpolacja wielomianowa")
xlabel!("x")
ylabel!("f(x)")
title!("Porównanie interpolacji (efekt Rungego)")
savefig("zad6_1.png")

plot(x_dense, y_true, lw=3, label="Funkcja Rungego", legend=:topright)
plot!(x_dense, y_linear, lw=2, ls=:dash, label="Sklejane liniowe")
plot!(x_dense, y_cubic, lw=2, ls=:dot, label="Sklejane sześcienne")
xlabel!("x")
ylabel!("f(x)")
title!("Porównanie interpolacji liniowej i sześciennej")
savefig("zad6_2.png")