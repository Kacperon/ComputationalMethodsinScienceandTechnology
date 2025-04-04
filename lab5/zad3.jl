using CSV, DataFrames, Plots, Polynomials

# Wczytanie danych
df = CSV.read("results_c_opt.csv", DataFrame)
n = df.size
x = Float64.(n)

# Dopasuj wielomiany
fit_naive = fit(x, df.naive, 3)
fit_better = fit(x, df.better, 3)
fit_blas = fit(x, df.blas, 2)  # teoretycznie powinno być 2.5

# Wartości dopasowania
y_naive_fit = fit_naive.(x)
y_better_fit = fit_better.(x)
y_blas_fit = fit_blas.(x)

# Rysowanie
plot(x, df.naive, label="Naive", marker=:circle, lw=2)
plot!(x, y_naive_fit, label="Naive (fit)", ls=:dash, lw=2)

plot!(x, df.better, label="Better", marker=:square, lw=2)
plot!(x, y_better_fit, label="Better (fit)", ls=:dash, lw=2)

plot!(x, df.blas, label="BLAS", marker=:diamond, lw=2)
plot!(x, y_blas_fit, label="BLAS (fit)", ls=:dash, lw=2)

xlabel!("Matrix size (n x n)")
ylabel!("Time (s)")
title!("Matrix Multiplication in C with Polynomial Fit")

# Zapisz wykres
savefig("c_multiplication_fit.png")

println("Naive fit:   ", fit_naive)
println("Better fit:  ", fit_better)
println("BLAS fit:    ", fit_blas)

