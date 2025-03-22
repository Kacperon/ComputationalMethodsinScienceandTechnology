using DifferentialEquations
using Plots

# Parametry podwójnego wahadła
g = 9.81         # przyspieszenie ziemskie [m/s^2]
m1 = 1.0         # masa pierwszego wahadła [kg]
m2 = 1.0         # masa drugiego wahadła [kg]
l1 = 1.2         # długość pierwszego ramienia [m]
l2 = 0.8         # długość drugiego ramienia [m]

# Równania ruchu podwójnego wahadła
function double_pendulum!(du, u, p, t)
    θ1, ω1, θ2, ω2 = u
    Δ = θ1 - θ2
    den = 2*m1 + m2 - m2*cos(2θ1 - 2θ2)
    du[1] = ω1
    du[3] = ω2
    du[2] = (-g*(2*m1+m2)*sin(θ1) - m2*g*sin(θ1-2θ2) -
             2*sin(θ1-θ2)*m2*(ω2^2*l2 + ω1^2*l1*cos(θ1-θ2)))/(l1*den)
    du[4] = (2*sin(θ1-θ2)*(ω1^2*l1*(m1+m2) + g*(m1+m2)*cos(θ1) +
             ω2^2*l2*m2*cos(θ1-θ2)))/(l2*den)
end

# Warunki początkowe oraz przedział czasowy
u0 = [pi/2, 0.0, pi/2, 0.01]   # [θ₁, ω₁, θ₂, ω₂]
tspan = (0.0, 10.0)
t_eval = 0.0:0.01:10.0

# Rozwiązanie problemu metodą Tsit5 (stabilną)
prob = ODEProblem(double_pendulum!, u0, tspan)
sol = solve(prob, Tsit5(), saveat=t_eval)

# Obliczanie pozycji ciał:
# Pozycja pierwszego wahadła (punkt zaczepienia w (0,0))
x1 = [l1 * sin(θ) for θ in sol[1, :]]
y1 = [-l1 * cos(θ) for θ in sol[1, :]]
# Pozycja drugiego wahadła (relatywnie do pierwszego)
x2 = [x1[i] + l2 * sin(sol[3, i]) for i in 1:length(sol.t)]
y2 = [y1[i] - l2 * cos(sol[3, i]) for i in 1:length(sol.t)]

# Tworzenie animacji za pomocą @animate
anim = @animate for i in 1:length(sol.t)
    p = plot([0, x1[i]], [0, y1[i]],
             lw = 2, label = "", xlims = (-2, 2), ylims = (-2, 0.5),
             xlabel = "x [m]", ylabel = "y [m]")
    plot!(p, [x1[i], x2[i]], [y1[i], y2[i]], lw = 2, label = "")
    scatter!(p, [0, x1[i], x2[i]], [0, y1[i], y2[i]], markersize = 4,
             color = :red, label = "")
    title!(p, "Podwójne wahadło, t = $(round(sol.t[i], digits=2)) s")
    p
end

# Zapis animacji do pliku GIF (fps = 30)
println("Zapisywanie animacji jako double_pendulum_animation.gif")
gif(anim, "double_pendulum_animation_$(l1)_$(l2).gif", fps = 30)
println("Animacja zapisana jako double_pendulum_animation.gif")
