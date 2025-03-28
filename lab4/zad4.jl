include("zad1_2_3_5.jl")

using Plots
using Statistics
using Random
using Polynomials

# Upewnij się, że funkcje lagrange_interpolation, newton_divided_differences i newton_interpolation
# są już zdefiniowane (np. przez include("zad1_2_3.jl"))

# Definicje zakresu badanych liczby węzłów i liczby iteracji pomiarów
nvals = collect(100:100:1000)
num_iter = 10
x_range = (-5, 5)
x_eval = 1.0  # punkt ewaluacji

# Tablice na wyniki: średnie i std (dla poszczególnych rodzajów pomiarów)
lagrange_eval_means = Float64[]
lagrange_eval_stds  = Float64[]

newton_coeff_means = Float64[]
newton_coeff_stds  = Float64[]

newton_eval_means = Float64[]
newton_eval_stds  = Float64[]

poly_fit_means = Float64[]
poly_fit_stds  = Float64[]

poly_eval_means = Float64[]
poly_eval_stds  = Float64[]

# Dla każdej liczby węzłów wykonujemy num_iter pomiarów
for n in nvals
    times_lagrange = Float64[]
    times_newton_coeff = Float64[]
    times_newton_eval  = Float64[]
    times_poly_fit   = Float64[]
    times_poly_eval  = Float64[]
    
    for iter in 1:num_iter
        # Generujemy losowe węzły
        local x_vals = sort(rand(n) .* (x_range[2] - x_range[1]) .+ x_range[1])
        local y_vals = cos.(x_vals)
        
        # Pomiar: Lagrange - ewaluacja wartości interpolacji w punkcie x_eval
        t_lagrange = @elapsed begin
            y_lag = lagrange_interpolation(x_vals, y_vals, [x_eval])
        end
        push!(times_lagrange, t_lagrange)
        
        # Pomiar: Newton - obliczenie współczynników
        t_newton_coeff = @elapsed begin
            local newt_coef = newton_divided_differences(x_vals, y_vals)
        end
        push!(times_newton_coeff, t_newton_coeff)
        # Pomiar: Newton - ewaluacja wielomianu w punkcie x_eval
        t_newton_eval = @elapsed begin
            y_newt = newton_interpolation(newt_coef, x_vals, [x_eval])
        end
        push!(times_newton_eval, t_newton_eval)
        
        # Pomiar: Polynomials - dopasowanie (fit)
        t_poly_fit = @elapsed begin
            local p_poly = fit(Polynomial, x_vals, y_vals)
        end
        push!(times_poly_fit, t_poly_fit)
        # Pomiar: Polynomials - ewaluacja wielomianu w punkcie x_eval
        # Używamy wcześniej dopasowanego wielomianu
        local p_poly = fit(Polynomial, x_vals, y_vals)
        t_poly_eval = @elapsed begin
            y_pol = p_poly(x_eval)  # Użyj pojedynczej wartości, nie wektora
        end
        push!(times_poly_eval, t_poly_eval)        
    end
    
    push!(lagrange_eval_means, mean(times_lagrange))
    push!(lagrange_eval_stds, std(times_lagrange))
    
    push!(newton_coeff_means, mean(times_newton_coeff))
    push!(newton_coeff_stds, std(times_newton_coeff))
    
    push!(newton_eval_means, mean(times_newton_eval))
    push!(newton_eval_stds, std(times_newton_eval))
    
    push!(poly_fit_means, mean(times_poly_fit))
    push!(poly_fit_stds, std(times_poly_fit))
    
    push!(poly_eval_means, mean(times_poly_eval))
    push!(poly_eval_stds, std(times_poly_eval))
end

# Wykres 1: Czas EWALUACJI interpolacji (wartość w punkcie)
plot(nvals, lagrange_eval_means, yerror=lagrange_eval_stds, marker=:circle, label="Lagrange Eval")
plot!(nvals, newton_eval_means,   yerror=newton_eval_stds,   marker=:square, label="Newton Eval")
plot!(nvals, poly_eval_means,       yerror=poly_eval_stds,       marker=:diamond, label="Polynomials Eval")
xlabel!("Liczba węzłów")
ylabel!("Czas ewaluacji [s]")
title!("Porównanie czasu ewaluacji interpolacji")
savefig("evaluation_times.png")

# Wykres 2: Czas OBLICZENIA wielomianu (tylko metody, które to wyliczają osobno)
plot(nvals, newton_coeff_means, yerror=newton_coeff_stds, marker=:circle, label="Newton Coeff")
plot!(nvals, poly_fit_means,      yerror=poly_fit_stds,      marker=:square, label="Polynomials Fit")
xlabel!("Liczba węzłów")
ylabel!("Czas obliczenia wielomianu [s]")
title!("Porównanie czasu obliczenia wielomianu")
savefig("coeff_computation_times.png")

