using Plots
using SpecialPolynomials
using LinearAlgebra
using Statistics

# Ustawienia
x = -5:0.005:5
dx = step(x)
n = 6  # liczba funkcji: 0..5

# Tworzenie wielomianów Hermite’a Hₙ(x)
H_polys = [Hermite([zeros(m)..., 1]) for m in 0:n-1]
H_vals = [p.(x) for p in H_polys]

# Znormalizowane funkcje bazowe Hermite’a (ψₙ(x) = Hₙ(x) * exp(-x^2/2) / sqrt(2ⁿ n! √π))
function normalized_hermite(H_vals::Vector{Float64}, n::Int)
    norm_const = sqrt(2.0^n * factorial(n) * sqrt(π))
    return H_vals .* exp.(-x.^2 ./ 2) ./ norm_const
end

ψ_vals = [normalized_hermite(H_vals[i], i-1) for i in 1:n]

# Macierz iloczynów skalarnych (funkcji H_n(x) bez wagi)
inner_H = zeros(n, n)
for i in 1:n, j in 1:n
    inner_H[i, j] = sum(H_vals[i] .* H_vals[j]) * dx
end

# Macierz iloczynów skalarnych (ψ_n, z wagą e^{-x²/2}, znormalizowane)
inner_ψ = zeros(n, n)
for i in 1:n, j in 1:n
    inner_ψ[i, j] = sum(ψ_vals[i] .* ψ_vals[j]) * dx
end

# Wyniki
println("Iloczyny skalarne wielomianów Hermite’a (bez wagi):")
display(round.(inner_H, digits=2))

println("\nIloczyny skalarne funkcji Hermite’a ψₙ(x) (z wagą, ortonormalne):")
display(round.(inner_ψ, digits=3))
