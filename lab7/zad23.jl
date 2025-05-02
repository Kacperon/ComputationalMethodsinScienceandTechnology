using FastGaussQuadrature
using Polynomials
using Plots
using QuadGK

function gauss_integrate(f, k)
    xp, a = gauss(k)
    return sum(a .* f.(xp))
end

function test_gauss_accuracy(max_degree, max_k, filename="gauss_accuracy.png")
    errors = fill(NaN, max_degree+1, max_k)

    for deg in 0:max_degree
        coeffs = [1.0 for _ in 1:(deg+1)]  # wszystkie współczynniki = 1.0
        p = Polynomial(coeffs)
        exact, _ = quadgk(p, -1, 1)

        for k in 1:max_k
            approx = gauss_integrate(p, k)
            err = abs(exact - approx)
            errors[deg+1, k] = max(err, 1e-20)  # unikaj log10(0)
        end
    end

    plt = heatmap(
        1:max_k, 0:max_degree, log10.(errors),
        xlabel="Liczba punktów Gaussa (k)",
        ylabel="Stopień wielomianu",
        title="Log10 błędu całkowania Gaussa",
        colorbar_title="log₁₀(błąd)",
        yflip=true
    )

    savefig(plt, filename)
    println("Wykres zapisany jako $filename")
    return plt
end

test_gauss_accuracy(15, 10, "zad2.png")


function gauss_integrate(f, k, a=-1.0, b=1.0)
    xp, w = gauss(k)  # xp - węzły, w - wagi na [-1,1]
    # Zmiana zmiennej: x = (b+a)/2 + (b-a)/2 * z
    xz = (b + a)/2 .+ (b - a)/2 .* xp
    return (b - a)/2 * sum(w .* f.(xz))
end

f1(x) = x^2
f2(x) = sin(x)
f3(x) = exp(x)

println("Integral[0,2] x^2 dx = ", gauss_integrate(f1, 5, 0.0, 2.0), " (oczekiwane: 8/3 = ", 8/3, ")")
println("Integral[0,pi] sin(x) dx = ", gauss_integrate(f2, 5, 0.0, Float64(pi)), " (oczekiwane: 2)")
println("Integral[0,2] e^x dx = ", gauss_integrate(f3, 5, 0.0, 2.0), " (oczekiwane: e^2 - 1 = ", exp(2) - 1, ")")
