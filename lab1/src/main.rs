use rand::Rng;
use ndarray::{Array1, Array2};
use std::error::Error;
use std::fs::File;
use std::io::Write;
use std::time::Instant;

fn generate_random_matrix(n: usize) -> Array2<f64> {
    let mut rng = rand::thread_rng();
    Array2::from_shape_fn((n, n), |_| rng.gen_range(-1.0..1.0))
}

fn generate_random_vector(n: usize) -> Array1<f64> {
    let mut rng = rand::thread_rng();
    Array1::from_shape_fn(n, |_| rng.gen_range(-1.0..1.0))
}

fn generalized_dot(x: &Array1<f64>, a: &Array2<f64>, y: &Array1<f64>) -> f64 {
    x.dot(&a.dot(y))
}

fn matrix_vector_product(a: &Array2<f64>, x: &Array1<f64>) -> Array1<f64> {
    a.dot(x)
}

fn main() -> Result<(), Box<dyn Error>> {
    let sizes = vec![100, 200, 500, 1000, 2000, 5000]; // Różne wartości n
    let num_trials = 10;
    
    let mut file = File::create("results.csv")?;
    writeln!(file, "n,trial,time_dot,time_mul")?;
    
    for &n in &sizes {
        for trial in 0..num_trials {
            let a = generate_random_matrix(n);
            let x = generate_random_vector(n);
            let y = generate_random_vector(n);

            // Pomiar czasu dla dot(x, A, y)
            let start = Instant::now();
            let _ = generalized_dot(&x, &a, &y);
            let duration_dot = start.elapsed().as_secs_f64();

            // Pomiar czasu dla A*x
            let start = Instant::now();
            let _ = matrix_vector_product(&a, &x);
            let duration_matvec = start.elapsed().as_secs_f64();

            // Zapis do pliku
            writeln!(file, "{},{},{:.6},{:.6}", n, trial, duration_dot, duration_matvec)?;
        }
        println!("Eksperyment dla n={} zakończony", n);
    }

    println!("Eksperyment zakończony. Wyniki zapisano do results.csv");
    Ok(())
}

