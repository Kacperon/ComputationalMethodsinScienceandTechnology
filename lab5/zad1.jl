using LinearAlgebra
using Statistics
using BenchmarkTools
using Plots

# Naiwna metoda mnożenia macierzy O(n^3)
function naive_multiplication(A,B)
    C = zeros(Float64, size(A,1), size(B,2))
    for i=1:size(A,1)
        for j=1:size(B,2)
            for k=1:size(A,2)
                C[i,j] = C[i,j] + A[i,k]*B[k,j]
            end
        end
    end
    C
end

# Lepsza metoda – np. z zamienioną kolejnością pętli (lepsza lokalność danych)
function better_multiplication(A, B)
    C = zeros(Float64, size(A,1), size(B,2))
    for j=1:size(B,2)
        for k=1:size(A,2)
            for i=1:size(A,1)
                C[i,j] = C[i,j] + A[i,k]*B[k,j]
            end
        end
    end
    C
end

# Testowane rozmiary macierzy
sizes = 50:50:500

# Liczba powtórzeń dla statystyk
repeats = 5

# Przechowywanie wyników
times_naive = Float64[]
times_better = Float64[]
times_blas = Float64[]

errors_naive = Float64[]
errors_better = Float64[]
errors_blas = Float64[]

for n in sizes
    A = randn(n, n)
    B = randn(n, n)

    # Naiwne
    t_naive = [@elapsed naive_multiplication(A, B) for _ in 1:repeats]
    push!(times_naive, mean(t_naive))
    push!(errors_naive, std(t_naive))

    # Lepsze
    t_better = [@elapsed better_multiplication(A, B) for _ in 1:repeats]
    push!(times_better, mean(t_better))
    push!(errors_better, std(t_better))

    # BLAS
    t_blas = [@elapsed A * B for _ in 1:repeats]
    push!(times_blas, mean(t_blas))
    push!(errors_blas, std(t_blas))
end

# Rysowanie wykresu
plot(sizes, times_naive, yerror=errors_naive, label="Naive", lw=2, marker=:circle)
plot!(sizes, times_better, yerror=errors_better, label="Better", lw=2, marker=:square)
plot!(sizes, times_blas, yerror=errors_blas, label="BLAS (A*B)", lw=2, marker=:diamond)
xlabel!("Matrix size (n x n)")
ylabel!("Time (s)")
title!("Matrix Multiplication Time vs Size")
savefig("matrix_multiplication.png")