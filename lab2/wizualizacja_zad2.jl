using CSV
using Plots

# Wczytanie danych z pliku CSV
data = CSV.File("zad2.csv")

# Stworzenie wykresu
plot(data.value, data.distance, xlabel="Wartość liczby", ylabel="Odległość", label="Odległość", title="Zmiana odległości między liczbami zmiennoprzecinkowymi w skali 10x")

# Zapisanie wykresu do pliku PNG
savefig("distance_plot.png")


