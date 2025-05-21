using LinearAlgebra
using Polynomials
using Plots
using BenchmarkTools

# Pełny zbiór danych
x_all = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
y_all = [1.0, 2.2, 0.5, 5.1, 10.0, 7.0, 15.0, 30.0]

# Stopnie wielomianów
degrees = 2:7

# Czasy działania
times = Dict(:qr => Float64[], :inv => Float64[], :backslash => Float64[], :polyfit => Float64[])

# Układ wykresów 2×3
plot_layout = @layout [a b c; d e f]
p_all = plot(layout=plot_layout, size=(1000, 600))

# Główna pętla
for (i, n) in enumerate(degrees)
    # Wybranie pierwszych n+1 punktów
    x = x_all[1:n+1]
    y = y_all[1:n+1]

    # Macierz Vandermonde'a
    A = [x[i]^(j-1) for i in 1:length(x), j in 1:n+1]

    # QR
    t_qr = @belapsed begin
        Q, R = qr($A)
        R \ (Q' * $y)
    end
    Q, R = qr(A)
    coeff_qr = R \ (Q' * y)

    # inv
    t_inv = @belapsed inv($A' * $A) * $A' * $y
    coeff_inv = inv(A' * A) * A' * y

    # backslash
    t_backslash = @belapsed $A \ $y
    coeff_backslash = A \ y

    # polyfit
    t_polyfit = @belapsed Polynomials.fit($x, $y, $n)
    p = Polynomials.fit(x, y, n)
    coeff_polyfit = coeffs(p)

    # Zapis czasów
    push!(times[:qr], t_qr)
    push!(times[:inv], t_inv)
    push!(times[:backslash], t_backslash)
    push!(times[:polyfit], t_polyfit)

    # Przygotowanie wykresu
    x_plot = range(minimum(x), stop=maximum(x), length=200)

    function eval_poly(coeffs, x_vals)
        [sum(c * x^(i-1) for (i, c) in enumerate(coeffs)) for x in x_vals]
    end

    y_qr = eval_poly(coeff_qr, x_plot)
    y_inv = eval_poly(coeff_inv, x_plot)
    y_backslash = eval_poly(coeff_backslash, x_plot)
    y_polyfit = evalpoly.(x_plot, Ref(coeff_polyfit))

    # Create plot in the correct subplot position
    plot!(p_all, x, y, seriestype=:scatter, label="Dane", title="Stopień $n", subplot=i)
    plot!(p_all, x_plot, y_qr, label="QR", lw=2, subplot=i)
    plot!(p_all, x_plot, y_inv, label="inv()", lw=2, ls=:dot, subplot=i)
    plot!(p_all, x_plot, y_backslash, label="Backslash", lw=2, ls=:dashdot, subplot=i)
    plot!(p_all, x_plot, y_polyfit, label="Polynomial.fit", lw=2, ls=:dash, subplot=i)
end

# Wyświetlenie wykresów aproksymacji
savefig("porownanie_metod_1.png")

# Wykres porównujący czasy działania
p_times = plot(degrees, times[:qr], label="QR", lw=2, marker=:circle)
plot!(p_times, degrees, times[:inv], label="inv()", lw=2, marker=:square)
plot!(p_times, degrees, times[:backslash], label="Backslash", lw=2, marker=:diamond)
plot!(p_times, degrees, times[:polyfit], label="Polynomial.fit", lw=2, marker=:star)
title!(p_times, "Czas działania metod")
xlabel!(p_times, "Stopień wielomianu")
ylabel!(p_times, "Czas [s]")
savefig("porownanie_metod_2.png")
