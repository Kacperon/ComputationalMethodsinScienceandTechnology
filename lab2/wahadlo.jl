using DifferentialEquations
using Plots

# Parametry wachadła
g = 9.81          # przyspieszenie ziemskie [m/s^2]
l = 1.0           # długość wachadła [m]
b = 0.1           # współczynnik tarcia
θ0 = 0.5          # początkowy kąt [rad]
ω0 = 0.0          # początkowa prędkość kątowa [rad/s]

# Definicja układu równań różniczkowych
function pendulum!(du, u, p, t)
    θ, ω = u
    du[1] = ω
    du[2] = -(g/l)*sin(θ) - b*ω  # równanie ruchu z tłumieniem
end

# Warunki początkowe i przedział czasowy
u0 = [θ0, ω0]
tspan = (0.0, 10.0)

# Rozwiązanie problemu z użyciem metody Tsitouras 5/4 (domyślnie)
prob = ODEProblem(pendulum!, u0, tspan)
sol = solve(prob, Tsit5(), saveat=0.01)

# Tworzenie wykresu położenia (kąta) wachadła
plot(sol.t, sol[1, :],
     xlabel = "Czas [s]",
     ylabel = "Kąt [rad]",
     title = "Położenie wachadła w funkcji czasu",
     label = "θ(t)")

# Zapis wykresu do pliku PNG
savefig("pendulum_position.png")
println("Wykres położenia wachadła zapisany jako pendulum_position.png")
