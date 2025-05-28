using Plots

function jacobi_laplace_with_history(T; maxiter=10_000, tol=1e-6)
    n, m = size(T)
    T_next = copy(T)
    deltas = Float64[]
    
    for iter in 1:maxiter
        delta = 0.0
        for j in 2:n-1, i in 2:m-1
            T_next[i, j] = 0.25 * (T[i-1, j] + T[i+1, j] + T[i, j-1] + T[i, j+1])
            delta = max(delta, abs(T_next[i, j] - T[i, j]))
        end
        T, T_next = T_next, T
        push!(deltas, delta)
        
        if delta < tol
            return T, deltas
        end
    end
    return T, deltas
end

function gauss_seidel_laplace_with_history(T; maxiter=10_000, tol=1e-6)
    n, m = size(T)
    deltas = Float64[]
    
    for iter in 1:maxiter
        delta = 0.0
        for j in 2:n-1, i in 2:m-1
            old = T[i, j]
            T[i, j] = 0.25 * (T[i-1, j] + T[i+1, j] + T[i, j-1] + T[i, j+1])
            delta = max(delta, abs(T[i, j] - old))
        end
        push!(deltas, delta)
        
        if delta < tol
            return T, deltas
        end
    end
    return T, deltas
end

function sor_laplace_with_history(T; maxiter=10_000, tol=1e-6)
    n, m = size(T)
    N = n - 2
    ρ = cos(pi / N)^2
    ω = 2 / (1 + sqrt(1 - ρ))
    deltas = Float64[]
    
    for iter in 1:maxiter
        delta = 0.0
        for j in 2:n-1, i in 2:m-1
            old = T[i, j]
            T[i, j] = (1 - ω) * T[i, j] + ω * 0.25 * (T[i-1, j] + T[i+1, j] + T[i, j-1] + T[i, j+1])
            delta = max(delta, abs(T[i, j] - old))
        end
        push!(deltas, delta)
        
        if delta < tol
            return T, deltas
        end
    end
    return T, deltas
end

function chebyshev_laplace_with_history(T; maxiter=10_000, tol=1e-6)
    n, m = size(T)
    N = n - 2
    ρ = cos(pi / N)^2
    ω = 1.0
    T_next = copy(T)
    deltas = Float64[]

    for t in 1:maxiter
        norm = 0.0
        delta = 0.0
        
        # ODD and EVEN sweeps
        for parity in 0:1
            for j in 2:n-1, i in 2:m-1
                if (i + j) % 2 == parity
                    old = T[i, j]
                    res = (T[i-1,j] + T[i+1,j] + T[i,j-1] + T[i,j+1] - 4 * T[i,j])
                    T_next[i,j] = T[i,j] + ω * res / 4
                    delta = max(delta, abs(T_next[i,j] - old))
                    norm += res^2
                end
            end
            T, T_next = T_next, T
        end
        
        push!(deltas, delta)
        norm = sqrt(norm)
        
        if norm < tol
            return T, deltas
        end
        
        # Aktualizacja ω zgodnie z rekursją Czebyszewa
        if t == 1
            ω = 1.0 / (1.0 - 0.5 * ρ^2)
        else
            ω = 1.0 / (1.0 - 0.25 * ρ^2 * ω)
        end
    end
    
    return T, deltas
end

function calculate_error_ratios(deltas)
    # Obliczenie stosunku błędu zgodnie ze wzorem z zadania
    cumulative_deltas = reverse(cumsum(reverse(deltas)))
    total_delta = cumulative_deltas[1]
    return [delta_sum / total_delta for delta_sum in cumulative_deltas]
end


function create_initial_solution(n)
    T = zeros(n, n)
    hot_temp = 100
    cold_temp = 10
    T[1, :] .= hot_temp
    T[n, :] .= hot_temp
    T[:, 1] .= hot_temp
    T[:, n] .= cold_temp
    return T
end

function compare_convergence(size=150)
    println("Analiza zbieżności dla rozmiaru $size")
    T_init = create_initial_solution(size)
    
    # Ujednolicony próg tolerancji i maksymalna liczba iteracji
    maxiter = 30_000
    tol = 1e-12  # Bardzo mała tolerancja, aby wymusić więcej iteracji
    
    # Zbierz historie wszystkich metod
    _, deltas_jacobi = jacobi_laplace_with_history(copy(T_init), maxiter=maxiter, tol=tol)
    _, deltas_gs = gauss_seidel_laplace_with_history(copy(T_init), maxiter=maxiter, tol=tol)
    _, deltas_sor = sor_laplace_with_history(copy(T_init), maxiter=maxiter, tol=tol)
    _, deltas_cheb = chebyshev_laplace_with_history(copy(T_init), maxiter=maxiter, tol=tol)
    
    # Diagnostyka - pokaż długości list
    println("Długości historii:")
    println("Jacobi: $(length(deltas_jacobi)) iteracji")
    println("Gauss-Seidel: $(length(deltas_gs)) iteracji")
    println("SOR: $(length(deltas_sor)) iteracji")
    println("Czebyszew: $(length(deltas_cheb)) iteracji")
    
    # Oblicz stosunek błędów
    ratios_jacobi = calculate_error_ratios(deltas_jacobi)
    ratios_gs = calculate_error_ratios(deltas_gs)
    ratios_sor = calculate_error_ratios(deltas_sor)
    ratios_cheb = calculate_error_ratios(deltas_cheb)
    
    # Dla metod które zbiegają w mniej niż 10 iteracjach, dodaj sztuczne punkty do wykresu
    pad_to_length = 10
    
    if length(ratios_jacobi) < pad_to_length
        ratios_jacobi = vcat(ratios_jacobi, fill(ratios_jacobi[end], pad_to_length - length(ratios_jacobi)))
    end
    
    if length(ratios_gs) < pad_to_length
        ratios_gs = vcat(ratios_gs, fill(ratios_gs[end], pad_to_length - length(ratios_gs)))
    end
    
    if length(ratios_sor) < pad_to_length
        ratios_sor = vcat(ratios_sor, fill(ratios_sor[end], pad_to_length - length(ratios_sor)))
    end
    
    if length(ratios_cheb) < pad_to_length
        ratios_cheb = vcat(ratios_cheb, fill(ratios_cheb[end], pad_to_length - length(ratios_cheb)))
    end
    
    # Stwórz nowy wykres z wyraźnie różnymi stylami linii i kolorami
    p = plot(
        xlabel="Iteracja",
        ylabel="Stosunek błędu (ε)",
        title="Zbieżność metod dla rozmiaru siatki $size",
        yscale=:log10,
        legend=:topright,
        size=(800, 600),
        dpi=300
    )
    
    # Dodaj każdą metodę oddzielnie z różnymi stylami
    plot!(p, 1:length(ratios_jacobi), ratios_jacobi, 
          label="Jacobi", 
          linewidth=2, 
          color=:blue,
          marker=:circle,
          markersize=4, 
          markerstrokewidth=0,
          markeralpha=0.6)
    
    plot!(p, 1:length(ratios_gs), ratios_gs, 
          label="Gauss-Seidel", 
          linewidth=2, 
          color=:red, 
          linestyle=:dash,
          marker=:square,
          markersize=4, 
          markerstrokewidth=0,
          markeralpha=0.6)
    
    plot!(p, 1:length(ratios_sor), ratios_sor, 
          label="SOR", 
          linewidth=2, 
          color=:green, 
          linestyle=:dot,
          marker=:diamond,
          markersize=4, 
          markerstrokewidth=0,
          markeralpha=0.6)
    
    plot!(p, 1:length(ratios_cheb), ratios_cheb, 
          label="Czebyszew", 
          linewidth=2, 
          color=:purple, 
          linestyle=:dashdot,
          marker=:star5,
          markersize=4, 
          markerstrokewidth=0,
          markeralpha=0.6)
    
    # Zapisz wykres
    savefig(p, "zbieznosc_wszystkich_metod.png")
    
    return p
end

# Wywołanie funkcji
compare_convergence(150)