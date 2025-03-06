
using CSV, DataFrames, Statistics, Plots
# Wczytanie danych i analiza
df = CSV.read("results.csv", DataFrame)

# Obliczenie średniej i odchylenia standardowego
gdf = groupby(df, :n)
stats_dot = combine(gdf, :time_dot => mean => :mean_dot, :time_dot => std => :std_dot)
stats_mul = combine(gdf, :time_mul => mean => :mean_mul, :time_mul => std => :std_mul)
stats = innerjoin(stats_dot, stats_mul, on=:n)

# Tworzenie wykresów
p1 = plot(stats.n, stats.mean_dot, yerr=stats.std_dot,
    title="Uogólniony iloczyn skalarny", xlabel="Rozmiar n", ylabel="Czas (s)",
    label="Średni czas", marker=:circle, legend=:topleft)

p2 = plot(stats.n, stats.mean_mul, yerr=stats.std_mul,
    title="Mnożenie macierz-wektor", xlabel="Rozmiar n", ylabel="Czas (s)",
    label="Średni czas", marker=:circle, legend=:topleft)

plot(p1, p2, layout=(2, 1), size=(800, 600))
savefig("wykresyrust.png")