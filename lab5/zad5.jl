using Plots
using Polynomials

# FUNKCJE

# Definicja funkcji dokładnej: f(z) = log(1+z)/z
f(z) = log(1 + z) / z

# Obliczenie współczynników szeregu Taylora f(z) do rzędu 4.
# Log(1+z) = z - z^2/2 + z^3/3 - z^4/4 + z^5/5 - ...,
# więc f(z) = log(1+z)/z = 1 - z/2 + z^2/3 - z^3/4 + z^4/5 - ...
a0 = 1.0
a1 = -1/2
a2 = 1/3
a3 = -1/4
a4 = 1/5

# Wielomian Taylora rzędu 4
P_taylor = Polynomial([a0, a1, a2, a3, a4])
println("Rozwinięcie Taylora (współczynniki):")
println(coeffs(P_taylor))  # wypisze współczynniki od stałej

# KONSTRUKCJA APROKSYMACJI PADÉ [2|2]
# Przyjmujemy postać:
#   f_pade(z) = (p0 + p1 z + p2 z^2) / (1 + q1 z + q2 z^2)
#
# Warunki dopasowania (rozszerzamy w szereg do z^4):
# 1) Dla z^0:    a0 - p0 = 0     =>  p0 = a0 = 1
# 2) Dla z^1:    a1 + q1 a0 - p1 = 0  =>  p1 = a1 + q1
# 3) Dla z^2:    a2 + q1 a1 + q2 a0 - p2 = 0  => p2 = a2 + q1 a1 + q2
# 4) Dla z^3:    a3 + q1 a2 + q2 a1 = 0
# 5) Dla z^4:    a4 + q1 a3 + q2 a2 = 0
#
# Rozwiążemy najpierw równania dla q1 i q2 (warunki dla z^3 i z^4)
#
# (4) a3 + q1 a2 + q2 a1 = 0   =>  -1/4 + q1*(1/3) + q2*(-1/2) = 0
# (5) a4 + q1 a3 + q2 a2 = 0   =>   1/5 + q1*(-1/4) + q2*(1/3) = 0
#
# Mnożymy (4) przez 12:  12*(-1/4) + 12*(q1/3) + 12*(-q2/2) =  -3 + 4q1 - 6q2 = 0
#   => 4q1 - 6q2 = 3
#
# Mnożymy (5) przez 12:  12*(1/5) + 12*(-q1/4) + 12*(q2/3) = 12/5 - 3q1 + 4q2 = 0
#   => -3q1 + 4q2 = -12/5
#
# Rozwiązując:
#   4q1 - 6q2 = 3   =>  q1 = (3 + 6q2) / 4.
# Podstawiamy do drugiego równania:
#   -3*((3+6q2)/4) + 4q2 = -12/5  =>  - (9 + 18q2)/4 + 4q2 = -12/5.
# Mnożymy przez 4:
#   -9 - 18q2 + 16q2 = -48/5  =>  -9 - 2q2 = -48/5  =>  -2q2 = -48/5 + 9.
# Obliczamy: 9 = 45/5, więc:
#   -2q2 = (-48 + 45)/5 = -3/5   =>  q2 = (3/5)/2 = 3/10.
#
# Następnie: q1 = (3 + 6*(3/10)) / 4 = (3 + 18/10) / 4 = (3 + 1.8) / 4 = 4.8/4 = 1.2 = 6/5.
#
q1 = 6/5      # 1.2
q2 = 3/10     # 0.3
#
# Teraz wyznaczamy p1 i p2:
p0 = a0  # = 1.0
p1 = a1 + q1  # = -0.5 + 1.2 = 0.7  czyli 7/10
p2 = a2 + q1*a1 + q2   # = 1/3 + (6/5)*(-1/2) + 3/10
# Obliczamy: 1/3 ≈ 0.3333, (6/5)*(-1/2) = -6/10 = -0.6, 3/10 = 0.3, więc p2 = 0.3333 - 0.6 + 0.3 = 0.03333 ≈ 1/30.
#
println("Współczynniki Padé:")
println("q1 = $q1, q2 = $q2")
println("p0 = $p0, p1 = $p1, p2 = $p2")

# Definicja funkcji aproksymującej Padé
f_pade(z) = (p0 + p1*z + p2*z^2) / (1 + q1*z + q2*z^2)

# WIZUALIZACJA

# Wybieramy zakres zmiennej z. Uważamy, że osobliwość przy z = -1 jest blisko, więc zaczynamy od -0.9.
z_vals = -0.9:0.01:10.0

# Tworzymy wykres, porównując:
# • funkcję dokładną,
# • rozwinięcie Taylora (w postaci wielomianu),
# • aproksymację Padé.
plt = plot(z_vals, f.(z_vals), label="Funkcja dokładna f(z)", lw=2)
plot!(plt, z_vals, P_taylor.(z_vals), label="Rozwinięcie Taylora (rząd 4)", lw=2, linestyle=:dash)
plot!(plt, z_vals, f_pade.(z_vals), label="Aproksymacja Padé [2|2]", lw=2, linestyle=:dot)
xlabel!("z")
ylabel!("f(z)")
title!("Porównanie Taylora i Padé dla f(z)=log(1+z)/z")

savefig(plt, "pade_taylor.png")
