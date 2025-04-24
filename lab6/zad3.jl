using CSV
using DataFrames
using Plots
using Polynomials

# Wczytanie danych z pliku CSV
data = CSV.File("ecg_data.csv")
df = DataFrame(data)

# Wydzielenie sygnałów N i V
time = df.time
signalN = df.signalN
signalV = df.signalV

# Stopnie wielomianów do aproksymacji
degrees = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
colors = [:red, :orange, :purple, :brown, :pink, :cyan, :yellow, :magenta, :lime, :teal]

# Aproksymacja dla sygnału N z różnymi stopniami wielomianu
p_N = plot(time, signalN, label="Sygnał N", xlabel="Czas", ylabel="Amplituda", color=:blue, 
           title="Aproksymacja sygnału N", linewidth=2, legend=:topleft)

for (i, degree) in enumerate(degrees)
    poly = fit(Polynomial, time, signalN, degree)
    plot!(p_N, time, [poly(t) for t in time], label="Stopień $degree", 
          linestyle=:dash, color=colors[i], linewidth=1.5)
end

# Aproksymacja dla sygnału V z różnymi stopniami wielomianu
p_V = plot(time, signalV, label="Sygnał V", xlabel="Czas", ylabel="Amplituda", color=:green,
           title="Aproksymacja sygnału V", linewidth=2, legend=:topleft)

for (i, degree) in enumerate(degrees)
    poly = fit(Polynomial, time, signalV, degree)
    plot!(p_V, time, [poly(t) for t in time], label="Stopień $degree", 
          linestyle=:dash, color=colors[i], linewidth=1.5)
end

# Zapisanie wykresów do plików
savefig(p_N, "aproksymacja_N.png")
savefig(p_V, "aproksymacja_V.png")

# Wyświetlenie wykresów
display(p_N)
display(p_V)

# Zapisanie obu wykresów na jednym obrazku (opcjonalnie)
p_combined = plot(p_N, p_V, layout=(2,1), size=(800, 1000))
savefig(p_combined, "aproksymacje_N_V.png")