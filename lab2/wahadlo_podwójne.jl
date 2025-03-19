using DifferentialEquations
using Plots

# Parametry podwójnego wachadła
g = 9.81         # przyspieszenie ziemskie [m/s^2]
m1 = 1.0         # masa pierwszego wahadła [kg]
m2 = 1.0         # masa drugiego wahadła [kg]
l1 = 1.0         # długość pierwszego ramienia [m]
l2 = 1.0         # długość drugiego ramienia [m]

# Równania ruchu podwójnego wachadła
function double_pendulum!(du, u, p, t)
    θ1, ω1, θ2, ω2 = u
    Δ = θ1 - θ2
    den = 2*m1 + m2 - m2*cos(2θ1 - 2θ2)
    
    du[1] = ω1
    du[3] = ω2
    du[2] = (-g*(2*m1 + m2)*sin(θ1) - m2*g*sin(θ1-2θ2) - 2*sin(θ1-θ2)*m2*(ω2^2*l2 + ω1^2*l1*cos(θ1-θ2)))/(l1*den)
    du[4] = (2*sin(θ1-θ2)*(ω1^2*l1*(m1+m2) + g*(m1+m2)*cos(θ1) + ω2^2*l2*m2*cos(θ1-θ2)))/(l2*den)
end

# Warunki początkowe (drobne zaburzenie pozwoli ujawnić chaotyczne zachowanie)
u0 = [pi/2, 0.0, pi/2, 0.01]   # [θ1, ω1, θ2, ω2]

# Przedział czasowy symulacji
tspan = (0.0, 10.0)
t_eval = 0.0:0.01:10.0

# =====================================
# 1. Rozwiązanie metodą stabilną (Tsit5)
# =====================================
prob = ODEProblem(double_pendulum!, u0, tspan)
sol_stable = solve(prob, Tsit5(), saveat=t_eval)

# =====================================
# 2. Rozwiązanie metodą Eulera (niestabilną)
# =====================================
function euler_method(f, u0, tspan, h)
    t_values = collect(tspan[1]:h:tspan[2])
    u_values = zeros(length(t_values), length(u0))
    u_values[1, :] .= u0
    for i in 2:length(t_values)
        t = t_values[i-1]
        u = u_values[i-1, :]
        du = zeros(length(u))
        f(du, u, nothing, t)
        u_values[i, :] = u + h * du
    end
    return t_values, u_values
end

t_euler, sol_euler = euler_method(double_pendulum!, u0, tspan, 0.01)

# =====================================
# Tworzenie wykresów porównawczych
# =====================================
# Wykres dla kąta θ1 (pierwszy element układu)
plt1 = plot(sol_stable.t, sol_stable[1, :],
            xlabel = "Czas [s]", ylabel = "θ₁ [rad]",
            title = "Podwójne wachadło: θ₁ (stable vs Euler)",
            label = "Tsit5 (stable)", lw=2)
plot!(plt1, t_euler, sol_euler[:, 1],
      label = "Euler (niestabilna)", linestyle = :dash, lw=2)

# Wykres dla kąta θ2 (trzeci element układu)
plt2 = plot(sol_stable.t, sol_stable[3, :],
            xlabel = "Czas [s]", ylabel = "θ₂ [rad]",
            title = "Podwójne wachadło: θ₂ (stable vs Euler)",
            label = "Tsit5 (stable)", lw=2)
plot!(plt2, t_euler, sol_euler[:, 3],
      label = "Euler (niestabilna)", linestyle = :dash, lw=2)

# Wyświetlenie wykresów obok siebie
plot(plt1, plt2, layout = (1,2), size=(1000,400))

# Zapis wykresu do pliku PNG
savefig("double_pendulum_comparison.png")
println("Porównanie metod dla podwójnego wachadła zapisane jako double_pendulum_comparison.png")
