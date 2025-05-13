use image::{Rgb, RgbImage};
use num_complex::Complex;
use rayon::prelude::*;
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::time::Instant;
use std::sync::atomic::{AtomicUsize, Ordering};

fn newton_fractal<F, DF>(
    f: F,
    df: DF,
    xlims: (f64, f64),
    ylims: (f64, f64),
    width: u32,
    height: u32,
    max_iter: u32,
    tol: f64,
    expected_roots: usize,  // Added parameter for expected number of roots
    filename: &str,
)
where
    F: Fn(Complex<f64>) -> Complex<f64> + Send + Sync,
    DF: Fn(Complex<f64>) -> Complex<f64> + Send + Sync,
{
    let img = Arc::new(Mutex::new(RgbImage::new(width, height)));
    let roots_map = Arc::new(Mutex::new(HashMap::<(i32, i32), usize>::new()));
    let converged_count = Arc::new(AtomicUsize::new(0));
    
    // Define a set of vibrant, visually distinct colors
    let root_colors = vec![
        Rgb([255, 0, 128]),    // Bright pink
        Rgb([0, 168, 255]),    // Azure blue
        Rgb([106, 255, 0]),    // Lime green
        Rgb([255, 211, 0]),    // Golden yellow
        Rgb([128, 0, 255]),    // Purple
        Rgb([255, 106, 0]),    // Orange
        Rgb([0, 255, 170]),    // Turquoise
        Rgb([255, 0, 0]),      // Red
        Rgb([0, 140, 70]),     // Forest green
        Rgb([200, 80, 255]),   // Violet
    ];
    
    println!("Generowanie fraktala...");
    let start = Instant::now();

    // Total number of pixels
    let total_pixels = (width * height) as usize;

    // Create a vector of pixel coordinates
    let pixels: Vec<(u32, u32)> = (0..height)
        .flat_map(|y| (0..width).map(move |x| (y, x)))
        .collect();

    // Process pixels in parallel
    pixels.par_iter().for_each(|&(i, j)| {
        let y = ylims.0 + (ylims.1 - ylims.0) * (i as f64) / (height as f64);
        let x = xlims.0 + (xlims.1 - xlims.0) * (j as f64) / (width as f64);
        let mut z = Complex::new(x, y);
        
        let mut converged = false;
        let mut iterations = 0;
        
        for iter in 0..max_iter {
            iterations = iter;
            let dz = df(z);
            
            if dz.norm() < tol {
                // Derivative too small, might be a problem point
                break;
            }
            
            let z_new = z - f(z) / dz;
            
            if (z_new - z).norm() < tol {
                // Successfully converged
                converged = true;
                z = z_new;
                break;
            }
            
            z = z_new;
        }
        
        if converged {
            // Increment the converged counter
            converged_count.fetch_add(1, Ordering::Relaxed);
        }

        // Round the root to a fixed precision to avoid floating point issues
        let rounded_real = (z.re * 1e6).round() as i32;
        let rounded_imag = (z.im * 1e6).round() as i32;
        let key = (rounded_real, rounded_imag);
        
        // Determine color for this pixel
        let color = {
            let mut roots = roots_map.lock().unwrap();
            
            if let Some(&idx) = roots.get(&key) {
                root_colors[idx % root_colors.len()]
            } else {
                let idx = roots.len();
                roots.insert(key, idx);
                root_colors[idx % root_colors.len()]
            }
        };
        
        // Update pixel in the shared image
        img.lock().unwrap().put_pixel(j, i, color);
    });

    let duration = start.elapsed();
    println!("Fraktal wygenerowany w czasie: {:?}", duration);
    
    // Calculate root identification effectiveness
    let root_count = roots_map.lock().unwrap().len();
    
    // Calculate pixel convergence effectiveness
    let converged = converged_count.load(Ordering::Relaxed);
    let pixel_effectiveness = (converged as f64 / total_pixels as f64) * 100.0;
    println!("Skuteczność zbieżności: {:.2}% (zbiegło {} z {} pikseli)", 
             pixel_effectiveness, converged, total_pixels);
    
    // Save the final image
    let final_img = Arc::try_unwrap(img).unwrap().into_inner().unwrap();
    final_img.save(filename).unwrap();
}

fn main() {
    // For z⁴ - 1 (four roots)
    let f1 = |z: Complex<f64>| z.powu(4) - Complex::new(1.0, 0.0);
    let df1 = |z: Complex<f64>| Complex::new(4.0, 0.0) * z.powu(3);

    newton_fractal(
        f1,
        df1,
        (-2.0, 2.0),
        (-2.0, 2.0),
        3000,  // width
        3000,  // height
        30,    // max_iter
        1e-6,  // tolerance
        4,     // expected roots
        "newton_fractal_4.png",
    );

    println!("Fraktal zapisany jako newton_fractal_4.png");

    // For z³ - 1 (three roots)
    let f2 = |z: Complex<f64>| z.powu(3) - Complex::new(1.0, 0.0);
    let df2 = |z: Complex<f64>| Complex::new(3.0, 0.0) * z.powu(2);

    newton_fractal(
        f2,
        df2,
        (-2.0, 2.0),
        (-2.0, 2.0),
        3000,  // width
        3000,  // height
        30,    // max_iter
        1e-6,  // tolerance
        3,     // expected roots
        "newton_fractal_3.png",
    );

    println!("Fraktal zapisany jako newton_fractal_3.png");

    // For z⁵ - 1 (five roots)
    let f3 = |z: Complex<f64>| z.powu(5) - Complex::new(1.0, 0.0);
    let df3 = |z: Complex<f64>| Complex::new(5.0, 0.0) * z.powu(4);

    newton_fractal(
        f3,
        df3,
        (-2.0, 2.0),
        (-2.0, 2.0),
        3000,  // width
        3000,  // height
        30,    // max_iter
        1e-6,  // tolerance
        5,     // expected roots
        "newton_fractal_5.png",
    );

    println!("Fraktal zapisany jako newton_fractal_5.png");
}