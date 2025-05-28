using Plots

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

function jacobi_laplace(T; maxiter=10_000, tol=1e-6)
    n, m = size(T)
    T_next = copy(T)
    for iter in 1:maxiter
        delta = 0.0
        for j in 2:n-1, i in 2:m-1
            T_next[i, j] = 0.25 * (T[i-1, j] + T[i+1, j] + T[i, j-1] + T[i, j+1])
            delta = max(delta, abs(T_next[i, j] - T[i, j]))
        end
        T, T_next = T_next, T
        if delta < tol
            return iter
        end
    end
    return maxiter
end

function gauss_seidel_laplace(T; maxiter=10_000, tol=1e-6)
    n, m = size(T)
    for iter in 1:maxiter
        delta = 0.0
        for j in 2:n-1, i in 2:m-1
            old = T[i, j]
            T[i, j] = 0.25 * (T[i-1, j] + T[i+1, j] + T[i, j-1] + T[i, j+1])
            delta = max(delta, abs(T[i, j] - old))
        end
        if delta < tol
            return iter
        end
    end
    return maxiter
end

function sor_laplace(T; maxiter=10_000, tol=1e-6)
    n, m = size(T)
    N = n - 2
    ρ = cos(pi / N)^2
    ω = 2 / (1 + sqrt(1 - ρ))
    for iter in 1:maxiter
        delta = 0.0
        for j in 2:n-1, i in 2:m-1
            old = T[i, j]
            T[i, j] = (1 - ω) * T[i, j] + ω * 0.25 * (T[i-1, j] + T[i+1, j] + T[i, j-1] + T[i, j+1])
            delta = max(delta, abs(T[i, j] - old))
        end
        if delta < tol
            return iter
        end
    end
    return maxiter
end

function chebyshev_laplace(T; maxiter=10_000, tol=1e-6)
    n, m = size(T)
    N = n - 2  # rozmiar wewnętrzny
    ρ = cos(pi / N)^2
    ω = 1.0
    T_next = copy(T)

    norm_b = 1.0  # ustalamy jako 1, bo nie mamy jawnej macierzy A ani b

    for t in 1:maxiter
        norm = 0.0

        # ODD and EVEN sweeps
        for parity in 0:1
            for j in 2:n-1, i in 2:m-1
                if (i + j) % 2 == parity
                    # Residuum lokalne (dla równania Poissona)
                    res = (T[i-1,j] + T[i+1,j] + T[i,j-1] + T[i,j+1] - 4 * T[i,j])
                    T_next[i,j] = T[i,j] + ω * res / 4  # dzielone przez -ep=q czyli -4
                    norm += res^2
                end
            end
            T, T_next = T_next, T
        end

        norm = sqrt(norm) / norm_b
        if norm < tol
            return t  # każda iteracja zawiera odd + even
        end

        # Aktualizacja ω zgodnie z rekursją Czebyszewa
        if t == 1
            ω = 1.0 / (1.0 - 0.5 * ρ^2)
        else
            ω = 1.0 / (1.0 - 0.25 * ρ^2 * ω)
        end
    end

    return maxiter
end




sizes = [10, 20, 40, 80, 100, 120]
iters_jacobi = Int[]
iters_gs = Int[]
iters_sor = Int[]
iters_cheb = Int[]

for size in sizes
    println("Rozmiar: $size")
    push!(iters_jacobi, jacobi_laplace(create_initial_solution(size)))
    push!(iters_gs, gauss_seidel_laplace(create_initial_solution(size)))
    push!(iters_sor, sor_laplace(create_initial_solution(size)))
    push!(iters_cheb, chebyshev_laplace(create_initial_solution(size)))
end

plot(sizes, iters_jacobi, label="Jacobi", lw=2, marker=:o)
plot!(sizes, iters_gs, label="Gauss-Seidel", lw=2, marker=:o)
plot!(sizes, iters_sor, label="SOR", lw=2, marker=:o)
plot!(sizes, iters_cheb, label="Czebyszew", lw=2, marker=:o)
xlabel!("Rozmiar siatki (N)")
ylabel!("Liczba iteracji")
title!("Porównanie metod iteracyjnych")
savefig("porownanie_metod.png")


