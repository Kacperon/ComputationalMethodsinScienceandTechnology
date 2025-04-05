using CSV, DataFrames, Plots

# Wczytanie danych z plików CSV
df_c_no_opt = CSV.read("results_c_no_opt.csv", DataFrame)
df_rust = CSV.read("results_rust.csv", DataFrame)

p = plot(
    df_c_no_opt.size, df_c_no_opt.naive, 
    label="Naive (C - no opt)", marker=:circle, lw=2, ls=:solid
)
plot!(
    df_c_no_opt.size, df_c_no_opt.better, 
    label="Better (C - no opt)", marker=:square, lw=2, ls=:solid
)
plot!(
    df_c_no_opt.size, df_c_no_opt.blas, 
    label="BLAS (C - no opt)", marker=:diamond, lw=2, ls=:solid
)
plot!(
    df_rust.size, df_rust.naive, 
    label="Naive (Rust)", marker=:circle, lw=2, ls=:dash
)
plot!(
    df_rust.size, df_rust.better, 
    label="Better (Rust)", marker=:square, lw=2, ls=:dash
)
plot!(
    df_rust.size, df_rust.blas, 
    label="BLAS (Rust)", marker=:diamond, lw=2, ls=:dash
)

xlabel!("Rozmiar macierzy (n × n)")
ylabel!("Czas (s)")
title!("Porównanie czasów mnożenia macierzy")

# Zapisanie wykresu
savefig("matrix_multiplication_cvsrust.png")