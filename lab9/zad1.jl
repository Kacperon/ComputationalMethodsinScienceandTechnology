using LinearAlgebra
using BenchmarkTools
using Plots

# Ustal losowe dane
n = 1000
x_ref = rand(n)
A = rand(n, n)
b = A * x_ref

println("Drugi przebieg dla każdego sposobu - pomiar czasu i jakości")

# --- Metoda 1: inv() ---
@time x1 = inv(A) * b # pierwszy przebieg (pomijamy)
inv_time = @belapsed x1 = inv($A) * $b
error1 = norm(x1 - x_ref)

# --- Metoda 2: operator "\" ---
@time x2 = A \ b # pierwszy przebieg (pomijamy)
backslash_time = @belapsed x2 = $A \ $b
error2 = norm(x2 - x_ref)

# --- Metoda 3: factorize() ---
@time F = factorize(A) # pierwszy przebieg (pomijamy)
factorize_time = @belapsed F = factorize($A)
@time x3 = F \ b  # Add this line to compute x3
solve_time = @belapsed x3 = $F \ $b
total_factorize_time = factorize_time + solve_time
error3 = norm(x3 - x_ref)

# Wyniki
println("\nPorównanie błędów:")
println("inv():      $(error1)")
println("\\ operator: $(error2)")
println("factorize():$(error3)")

println("\nPorównanie czasów (ms):")
println("inv():      $(round(inv_time * 1000, digits=2))")
println("\\ operator: $(round(backslash_time * 1000, digits=2))")
println("factorize() + solve: $(round(total_factorize_time * 1000, digits=2))")
println("factorize() tylko: $(round(factorize_time * 1000, digits=2))")
println("solve po factorize(): $(round(solve_time * 1000, digits=2))")

# Wizualizacja wyników
methods = ["inv()", "\\ operator", "factorize()"]

# Wykres czasów wykonania
p1 = bar(methods, [inv_time, backslash_time, total_factorize_time] .* 1000,
    title="Czas wykonania (ms)",
    ylabel="Czas (ms)",
    legend=false,
    color=[:red, :blue, :green],
    lw=2)

# Wykres błędów
p2 = bar(methods, [error1, error2, error3],
    title="Błąd rozwiązania",
    ylabel="Norma błędu",
    legend=false,
    color=[:red, :blue, :green],
    lw=2,
    yaxis=:log)  # Skala logarytmiczna dla lepszej wizualizacji

# Wykres łączony
plot(p1, p2, layout=(2,1), size=(800, 600))
savefig("porownanie_metod.png")
