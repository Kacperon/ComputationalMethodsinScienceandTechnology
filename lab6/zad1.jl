using Plots
using SpecialPolynomials

# Zakres x
x = -4:0.01:4

# Generowanie wielomianów Hermite’a H₀ do H₅
hermite_polys = [Hermite([zeros(n)..., 1]) for n in 0:5]
H_vals = [p.(x) for p in hermite_polys]  # Ewaluacja Hₙ(x)
weighted_H = [H .* exp.(-x.^2 ./ 2) for H in H_vals]  # Hₙ(x) * exp(-x² / 2)

# Wykres 1: Hermite H_m(x)
p1 = plot(layout = (2, 3), size=(900, 600), title="Wielomiany Hermite'a Hₘ(x)")
for m in 0:5
    plot!(p1[m+1], x, H_vals[m+1], label = "H_$m(x)", legend = :topright)
end

# Wykres 2: H_m(x) * exp(-x^2 / 2)
p2 = plot(layout = (2, 3), size=(900, 600), title="Bazowe funkcje Hermite’a: Hₘ(x)e^{-x²/2}")
for m in 0:5
    plot!(p2[m+1], x, weighted_H[m+1], label = "ψ_$m(x)", legend = :topright)
end

# Zapisz wykresy
savefig(p1, "hermite_polynomials1.png")
savefig(p2, "hermite_polynomials2.png")
