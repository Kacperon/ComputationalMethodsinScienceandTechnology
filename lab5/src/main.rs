use rand::Rng;
use ndarray::{Array2};
use std::error::Error;
use std::fs::File;
use std::io::Write;
use std::time::Instant;

// Create a random matrix of size n x n
fn create_random_matrix(n: usize) -> Array2<f64> {
    let mut rng = rand::thread_rng();
    Array2::from_shape_fn((n, n), |_| rng.r#gen::<f64>())
}

// Naive matrix multiplication (i-j-k loop order)
fn naive_multiplication(a: &Array2<f64>, b: &Array2<f64>) -> Array2<f64> {
    let n = a.nrows();
    let mut c = Array2::<f64>::zeros((n, n));
    
    for i in 0..n {
        for j in 0..n {
            for k in 0..n {
                c[[i, j]] += a[[i, k]] * b[[k, j]];
            }
        }
    }
    
    c
}

// Improved matrix multiplication (i-k-j loop order)
fn better_multiplication(a: &Array2<f64>, b: &Array2<f64>) -> Array2<f64> {
    let n = a.nrows();
    let mut c = Array2::<f64>::zeros((n, n));
    
    for i in 0..n {
        for k in 0..n {
            let a_ik = a[[i, k]];
            for j in 0..n {
                c[[i, j]] += a_ik * b[[k, j]];
            }
        }
    }
    
    c
}

// BLAS multiplication using ndarray's dot
fn blas_multiplication(a: &Array2<f64>, b: &Array2<f64>) -> Array2<f64> {
    a.dot(b)
}

fn main() -> Result<(), Box<dyn Error>> {
    // Open file for writing results
    let mut file = File::create("results_rust.csv")?;
    writeln!(file, "size,naive,better,blas")?;
    
    for n in (100..=1000).step_by(100) {
        println!("Computing for size {}x{}", n, n);
        
        // Create random matrices
        let a = create_random_matrix(n);
        let b = create_random_matrix(n);
        
        // Naive multiplication
        let start = Instant::now();
        let _c = naive_multiplication(&a, &b);
        let naive_time = start.elapsed().as_secs_f64();
        
        // Better multiplication
        let start = Instant::now();
        let _c = better_multiplication(&a, &b);
        let better_time = start.elapsed().as_secs_f64();
        
        // BLAS multiplication
        let start = Instant::now();
        let _c = blas_multiplication(&a, &b);
        let blas_time = start.elapsed().as_secs_f64();
        
        // Write results to file
        writeln!(file, "{},{:.6},{:.6},{:.6}", n, naive_time, better_time, blas_time)?;
    }
    
    Ok(())
}

