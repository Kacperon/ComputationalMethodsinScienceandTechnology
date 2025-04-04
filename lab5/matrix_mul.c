#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <gsl/gsl_blas.h>

// Alokacja macierzy
double* allocate_matrix(int n) {
    return (double*)calloc(n * n, sizeof(double));
}

// Inicjalizacja losowymi wartościami
void fill_matrix(double* A, int n) {
    for (int i = 0; i < n * n; i++) {
        A[i] = (double)rand() / RAND_MAX;
    }
}

// Naiwne mnożenie macierzy
void naive_multiplication(double* A, double* B, double* C, int n) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            for (int k = 0; k < n; k++)
                C[i * n + j] += A[i * n + k] * B[k * n + j];
}

// Ulepszona wersja (zamieniona kolejność pętli)
void better_multiplication(double* A, double* B, double* C, int n) {
    for (int i = 0; i < n; i++)
        for (int k = 0; k < n; k++)
            for (int j = 0; j < n; j++)
                C[i * n + j] += A[i * n + k] * B[k * n + j];
}

// GSL BLAS dgemm
void blas_multiplication(double* A, double* B, double* C, int n) {
    gsl_matrix_view mA = gsl_matrix_view_array(A, n, n);
    gsl_matrix_view mB = gsl_matrix_view_array(B, n, n);
    gsl_matrix_view mC = gsl_matrix_view_array(C, n, n);

    gsl_blas_dgemm(CblasNoTrans, CblasNoTrans, 1.0,
                   &mA.matrix, &mB.matrix, 0.0, &mC.matrix);
}

// Pomiar czasu w sekundach
double get_time_diff(clock_t start, clock_t end) {
    return (double)(end - start) / CLOCKS_PER_SEC;
}

// Główna funkcja testująca
int main() {
    FILE* file = fopen("results_c.csv", "w");
    fprintf(file, "size,naive,better,blas\n");

    srand(time(NULL));

    for (int n = 100; n <= 1000; n += 100) {
        double *A = allocate_matrix(n);
        double *B = allocate_matrix(n);
        double *C = allocate_matrix(n);

        fill_matrix(A, n);
        fill_matrix(B, n);

        // Naive
        clock_t start = clock();
        naive_multiplication(A, B, C, n);
        clock_t end = clock();
        double t_naive = get_time_diff(start, end);

        // Reset C
        for (int i = 0; i < n * n; i++) C[i] = 0;

        // Better
        start = clock();
        better_multiplication(A, B, C, n);
        end = clock();
        double t_better = get_time_diff(start, end);

        // Reset C
        for (int i = 0; i < n * n; i++) C[i] = 0;

        // BLAS
        start = clock();
        blas_multiplication(A, B, C, n);
        end = clock();
        double t_blas = get_time_diff(start, end);

        // Zapisz
        fprintf(file, "%d,%.6f,%.6f,%.6f\n", n, t_naive, t_better, t_blas);

        free(A); free(B); free(C);
    }

    fclose(file);
    return 0;
}
