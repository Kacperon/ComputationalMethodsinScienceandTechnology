using Plots
using Random
using CSV
using DataFrames
using Polynomials

# Funkcja do obliczania wartości wielomianu interpolacyjnego Lagrange'a
function lagrange_interpolation(x_vals, y_vals, x)
    n = length(x_vals)
    L = zeros(length(x))
    
    for i in 1:n
        li = ones(length(x))
        for j in 1:n
            if i != j
                li .*= (x .- x_vals[j]) / (x_vals[i] - x_vals[j])
            end
        end
        L .+= y_vals[i] * li
    end
    return L
end

# Funkcja do obliczania ilorazów różnicowych dla interpolacji Newtona
function newton_divided_differences(x_vals, y_vals)
    n = length(x_vals)
    coef = copy(y_vals)
    for j in 2:n
        for i in n:-1:j
            coef[i] = (coef[i] - coef[i-1]) / (x_vals[i] - x_vals[i-j+1])
        end
    end
    return coef
end

# Funkcja do obliczania wartości wielomianu Newtona (schemat Hornera)
function newton_interpolation(newt, x_vals, x)
    n = length(newt)
    p = newt[n]
    for i in (n-1):-1:1
        p = p .* (x .- x_vals[i]) .+ newt[i]
    end
    return p
end

# Algorytm Neville'a zmodyfikowany do pracy z pojedynczym punktem
function neville_point(x_vals, y_vals, x_point)
    n = length(x_vals)
    p = copy(y_vals)  # Inicjalizacja tablicy wartościami funkcji
    
    for k in 1:n-1
        for i in 1:n-k
            p[i] = ((x_point - x_vals[i+k]) * p[i] - (x_point - x_vals[i]) * p[i+1]) / 
                   (x_vals[i] - x_vals[i+k])
        end
    end
    
    return p[1]  # Wartość wielomianu interpolacyjnego w punkcie x_point
end

# Funkcja wektoryzująca obliczanie interpolacji Neville'a dla wielu punktów
function neville_interpolation(x_vals, y_vals, x)
    result = zeros(length(x))
    for i in 1:length(x)
        result[i] = neville_point(x_vals, y_vals, x[i])
    end
    return result
end

# Parametry
Random.seed!(420)  # Ustalamy ziarno losowości dla powtarzalności
n = 20  # Liczba węzłów
x_range = (-10, 10)  # Przedział interpolacji

# Losowe węzły interpolacji
x_vals = sort(rand(n) .* (x_range[2] - x_range[1]) .+ x_range[1])
y_vals = cos.(x_vals)  # Przykładowa funkcja do interpolacji

# Punkty do rysowania wykresu
x_plot = range(x_range[1], x_range[2], length=1000)

# Interpolacja Lagrange'a
y_lagrange = lagrange_interpolation(x_vals, y_vals, x_plot)

# Interpolacja Newtona
newt_coef = newton_divided_differences(x_vals, y_vals)
y_newton = newton_interpolation(newt_coef, x_vals, x_plot)

# Interpolacja Neville'a
y_neville = neville_interpolation(x_vals, y_vals, x_plot)

# Obliczenie wielomianu interpolacyjnego w postaci standardowej (Polynomials)
p_poly = fit(Polynomial, x_vals, y_vals)  # interpolacja wielomianowa z pakietu Polynomials
polynomials_coeffs = p_poly.coeffs         # współczynniki wielomianu

# Przyjmujemy, że współczynniki Newtona są zadane przez newt_coef,
exponents = 0:(n-1)
# Tworzymy DataFrame z trzema kolumnami: Newton, Lagrange i Polynomials (przyjmujemy, że Lagrange i Polynomials są równoważne)
df_poly = DataFrame(Potęga = exponents, 
                    Newton = newt_coef, 
                    #Lagrange = lagrange_coeffs, 
                    Polynomials = polynomials_coeffs)

# Zapis do pliku CSV
CSV.write("interpolation_polynomial_coefficients.csv", df_poly)

# Obliczenie wartości wielomianu z pakietu Polynomials dla wykresu
y_poly = p_poly.(x_plot)

# Rysowanie wykresów dla trzech metod interpolacji
plot(x_plot, y_lagrange, label="Interpolacja Lagrange'a (ręcznie)", linewidth=2, linestyle=:dash)
plot!(x_plot, y_newton, label="Interpolacja Newtona (ręcznie)", linewidth=2, linestyle=:solid)
plot!(x_plot, y_poly, label="Interpolacja Polynomials", linewidth=2, linestyle=:dot)
scatter!(x_vals, y_vals, label="Węzły interpolacji", markersize=5, color=:red)

# Zapis wykresu do pliku
savefig("interpolation_comparison.png")

# Obliczenie różnic między metodami interpolacji
diff_lagrange_poly = y_lagrange .- y_poly
diff_newton_poly   = y_newton   .- y_poly
diff_neville_poly  = y_neville  .- y_poly

# Dodaj małą wartość epsilon do różnic, aby uniknąć logarytmowania zera
eps = 1e-16  # wartość zbliżona do granicy dokładności maszynowej

# Rysowanie wykresu różnic z logarytmiczną skalą osi y
plot(x_plot, abs.(diff_lagrange_poly) .+ eps, label="|y_lagrange - y_poly|", linewidth=2, linestyle=:dash, yscale=:log10)
plot!(x_plot, abs.(diff_newton_poly) .+ eps, label="|y_newton - y_poly|", linewidth=2, linestyle=:solid, yscale=:log10)
plot!(x_plot, abs.(diff_neville_poly) .+ eps, label="|y_neville - y_poly|", linewidth=2, linestyle=:dot, yscale=:log10)
xlabel!("x")
ylabel!("Różnica (log10)")
title!("Różnice między interpolacjami (skala logarytmiczna)")
hline!([1e-16], linestyle=:dot, color=:black, label="Granica precyzji")  # linia odniesienia
savefig("interpolation_diff_log.png")
