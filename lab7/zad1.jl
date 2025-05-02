using Polynomials
using Plots

# Funkcja generująca wielomiany Legendre'a do stopnia n
function legendre_polynomials(n)
    P = [Polynomial{Float64}([1.0]), Polynomial{Float64}([0.0, 1.0])]  # P₀(x) = 1, P₁(x) = x

    for k in 1:n-1
        Pk = P[end]
        Pkm1 = P[end - 1]
        coeff1 = (2k + 1) / (k + 1)
        coeff2 = k / (k + 1)
        nextP = coeff1 * Polynomial{Float64}([0.0, 1.0]) * Pk - coeff2 * Pkm1
        push!(P, nextP)
    end
    return P
end

# Rysowanie i zapisywanie wykresu
function plot_legendre_and_save(n, filename)
    P = legendre_polynomials(n)
    x = -1:0.01:1
    plt = plot(title="Wielomiany Legendre'a", xlabel="x", ylabel="Pₙ(x)", legend=:topright)
    for (i, p) in enumerate(P)
        plot!(plt, x, p.(x), label="P_$((i - 1))(x)")
    end
    savefig(plt, filename)
    println("Wykres zapisany jako $filename")
end

plot_legendre_and_save(5, "zad1.png")
