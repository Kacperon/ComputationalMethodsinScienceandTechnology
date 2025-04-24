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

# Funkcja do obliczania błędu aproksymacji
function approximation_error(poly, time, signal)
    predicted = [poly(t) for t in time]
    error = sum((predicted .- signal).^2) / length(time)
    return error
end

# Przechowywanie błędów dla różnych stopni
errors_N = Float64[]
errors_V = Float64[]

# Aproksymacja i obliczanie błędów dla stopni od 0 do 10
for degree in 0:12
    poly_N = fit(Polynomial, time, signalN, degree)
    poly_V = fit(Polynomial, time, signalV, degree)
    
    # Obliczanie błędu aproksymacji dla sygnału N i V
    push!(errors_N, approximation_error(poly_N, time, signalN))
    push!(errors_V, approximation_error(poly_V, time, signalV))
end

# Tworzenie wykresu błędu aproksymacji
plot(0:12, errors_N, label="Błąd aproksymacji N", xlabel="Stopień wielomianu", ylabel="Błąd", color=:blue)
plot!(0:12, errors_V, label="Błąd aproksymacji V", linestyle=:dash, color=:red)

# Wyświetlenie wykresu
display(plot)

# Zapisanie wykresu do pliku
savefig("approximation_error_plot.png")