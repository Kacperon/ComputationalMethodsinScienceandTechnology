using LinearAlgebra
using Random
using Plots

function metoda_czebyszewa(A, b, x0, max_iter, tol, λmin, λmax)
    x = copy(x0)
    r = b - A * x
    residuals = [norm(r)]

    c = (λmax + λmin) / 2
    dλ = (λmax - λmin) / 2

    α_prev = 0.0
    β_prev = 0.0

    for k in 1:max_iter
        if k == 1
            α = 1 / c
        else
            β = (dλ / (2 * c))^2
            α = 1 / (c - β_prev * α_prev / 2)
            β_prev = β
        end

        x_new = x + α * r
        r_new = b - A * x_new

        push!(residuals, norm(r_new))
        if norm(r_new) < tol
            println("Zbieżność osiągnięta po $k iteracjach.")
            return x_new, residuals
        end

        x = x_new
        r = r_new
        α_prev = α
    end

    println("Osiągnięto maksymalną liczbę iteracji.")
    return x, residuals
end

function create_initial_solution(n)
    T = zeros(n, n)
    hot_temp = 100
    cold_temp = 10
    T[1, :] .= hot_temp  # Górna krawędź
    T[n, :] .= hot_temp  # Dolna krawędź
    T[:, 1] .= hot_temp  # Lewa krawędź
    T[:, n] .= cold_temp # Prawa krawędź
    return T
end

function setup_heat_equation(n)
    # Tworzenie macierzy współczynników dla równania ciepła
    # Równanie Laplace'a w różnicach skończonych: (T[i+1,j] + T[i-1,j] + T[i,j+1] + T[i,j-1] - 4*T[i,j]) = 0
    
    # Liczba niewiadomych (temperatura w punktach wewnętrznych)
    internal_points = (n-2)^2
    
    # Macierz układu równań
    A = zeros(internal_points, internal_points)
    
    # Wektor prawych stron
    b = zeros(internal_points)
    
    # Tworzenie równań dla każdego wewnętrznego punktu
    for i in 2:n-1
        for j in 2:n-1
            # Mapowanie indeksu 2D na indeks 1D
            idx = (i-2)*(n-2) + (j-2) + 1
            
            # Współczynniki dla punktu centralnego
            A[idx, idx] = 4
            
            # Punkt na górze
            if i > 2
                A[idx, idx-(n-2)] = -1
            else  # Brzeg górny
                b[idx] += 100  # Hot temperature
            end
            
            # Punkt na dole
            if i < n-1
                A[idx, idx+(n-2)] = -1
            else  # Brzeg dolny
                b[idx] += 100  # Hot temperature
            end
            
            # Punkt po lewej
            if j > 2
                A[idx, idx-1] = -1
            else  # Brzeg lewy
                b[idx] += 100  # Hot temperature
            end
            
            # Punkt po prawej
            if j < n-1
                A[idx, idx+1] = -1
            else  # Brzeg prawy
                b[idx] += 10   # Cold temperature
            end
        end
    end
    
    return A, b
end

function reconstruct_solution(x, n)
    # Odtworzenie macierzy temperatur z wektora rozwiązań
    T = create_initial_solution(n)
    
    # Przepisanie wyników do wewnętrznych punktów
    for i in 2:n-1
        for j in 2:n-1
            idx = (i-2)*(n-2) + (j-2) + 1
            T[i, j] = x[idx]
        end
    end
    
    return T
end

# Rozwiązywanie równania ciepła
n = 100  # Rozmiar siatki
A, b = setup_heat_equation(n)
x0 = zeros((n-2)^2)

# Szacowanie wartości własnych
evals = eigvals(Symmetric(A))
λmin = minimum(evals)
λmax = maximum(evals)

# Uruchomienie metody Czebyszewa
println("Rozwiązywanie równania ciepła metodą Czebyszewa...")
x, residuals = metoda_czebyszewa(A, b, x0, 400, 1e-6, λmin, λmax)

# Odtworzenie rozwiązania w formie macierzy temperatur
T = reconstruct_solution(x, n)

# Wizualizacja rozkładu temperatury
heatmap(T, 
        xlabel="Pozycja X", 
        ylabel="Pozycja Y", 
        title="Rozkład temperatury",
        c=:turbo,
        aspect_ratio=:equal,
        colorbar_title="Temperatura")
savefig("rozkład_temperatury.png")

# Wykres zbieżności
plot(residuals, 
     yscale=:log10, 
     xlabel="Iteracja", 
     ylabel="Norma residuum (log10)",
     title="Zbieżność metody Czebyszewa", 
     marker=:circle, 
     grid=true)
savefig("czebyszew_zbieżność.png")