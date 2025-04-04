using CSV, DataFrames, Plots

# Wczytanie danych z plików CSV
df_c_no_opt = CSV.read("results_c_no_opt.csv", DataFrame)
df_c_opt = CSV.read("results_c_opt.csv", DataFrame)
df_c_fastopt = CSV.read("results_c_fastopt.csv", DataFrame)


# Utworzenie wykresu z wszystkimi 6 implementacjami
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
    df_c_opt.size, df_c_opt.naive, 
    label="Naive (C - O2)", marker=:circle, lw=2, ls=:dash
)
plot!(
    df_c_opt.size, df_c_opt.better, 
    label="Better (C - O2)", marker=:square, lw=2, ls=:dash
)
plot!(
    df_c_opt.size, df_c_opt.blas, 
    label="BLAS (C - O2)", marker=:diamond, lw=2, ls=:dash
)
plot!(
    df_c_fastopt.size, df_c_fastopt.naive, 
    label="Naive (C - Ofast)", marker=:circle, lw=2, ls=:dot
)
plot!(
    df_c_fastopt.size, df_c_fastopt.better, 
    label="Better (C - Ofast)", marker=:square, lw=2, ls=:dot
)
plot!(
    df_c_fastopt.size, df_c_fastopt.blas, 
    label="BLAS (C - Ofast)", marker=:diamond, lw=2, ls=:dot
)

# Dodanie etykiet i tytułu
xlabel!("Rozmiar macierzy (n × n)")
ylabel!("Czas (s)")
title!("Porównanie czasów mnożenia macierzy")

# Zapisanie wykresu
savefig("matrix_multiplication_comparison.png")
display(p)  # Wyświetlenie wykresu


