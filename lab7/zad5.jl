using Plots
using QuadGK

# Metoda prostokątów (środków)
function rectangle_rule(f, a, b, n)
    h = (b - a) / n
    x = a .+ h .* (0.5 .+ (0:n-1))
    return h * sum(f.(x))
end

# Metoda trapezów
function trapezoidal_rule(f, a, b, n)
    h = (b - a) / n
    x = range(a, stop=b, length=n+1)
    return h * (0.5*f(a) + sum(f.(x[2:end-1])) + 0.5*f(b))
end

# Metoda Simpsona (n musi być parzyste)
function simpson_rule(f, a, b, n)
    if n % 2 != 0
        error("Dla metody Simpsona liczba podprzedziałów (n) musi być parzysta")
    end
    h = (b - a) / n
    x = a .+ h .* (0:n)
    return h/3 * (f(a) + 2*sum(f.(x[2:2:end-2])) + 4*sum(f.(x[1:2:end])) + f(b))
end



function plot_errors(f, a, b, exact_val, max_n=1000; label="")
    ns = 2:2:max_n
    hs = (b - a) ./ ns
    err_rect = [abs(rectangle_rule(f, a, b, n) - exact_val) for n in ns]
    err_trap = [abs(trapezoidal_rule(f, a, b, n) - exact_val) for n in ns]
    err_simp = [abs(simpson_rule(f, a, b, n) - exact_val) for n in ns]

    plot(hs, err_rect, label="Prostokąty", xaxis=:log, yaxis=:log)
    plot!(hs, err_trap, label="Trapezy")
    plot!(hs, err_simp, label="Simpson")
    title!("Błąd vs h — $label")
    xlabel!("h = (b-a)/n")
    ylabel!("Błąd bezwzględny (log-log)")
end

f_exp(x) = exp(x)
exact_exp, _ = quadgk(f_exp, 0, 1)
plot_errors(f_exp, 0, 1, exact_exp, 1000, label="exp(x) na [0,1]")

savefig("zad5_exp.png")

f_sin(x) = sin(x)
exact_sin, _ = quadgk(f_sin, 0, 2π)
plot_errors(f_sin, 0, 2π, exact_sin, 1000, label="sin(x) na [0,2π]")

savefig("zad5_sin.png")