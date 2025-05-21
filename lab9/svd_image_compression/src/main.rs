use image::{GrayImage, Luma};
use ndarray::{Array1, Array2, ArrayBase, DataMut, Ix2, s};
use ndarray_linalg::svd::SVD;
use std::path::Path;
use std::env;

fn image_to_ndarray(img: &GrayImage) -> Array2<f64> {
    let (width, height) = img.dimensions();
    let mut array = Array2::<f64>::zeros((height as usize, width as usize));
    for (x, y, pixel) in img.enumerate_pixels() {
        array[[y as usize, x as usize]] = pixel[0] as f64;
    }
    array
}

fn ndarray_to_image(array: &ArrayBase<impl DataMut<Elem = f64>, Ix2>) -> GrayImage {
    let (rows, cols) = array.dim();
    let mut img = GrayImage::new(cols as u32, rows as u32);
    for ((y, x), value) in array.indexed_iter() {
        let clamped = value.clamp(0.0, 255.0) as u8;
        img.put_pixel(x as u32, y as u32, Luma([clamped]));
    }
    img
}

fn compress_svd(matrix: &Array2<f64>, k: usize) -> Array2<f64> {
    let (u, s, vt) = matrix.svd(true, true).unwrap();

    let u = u.unwrap();
    let vt = vt.unwrap();

    let u_k = u.slice(s![.., 0..k]);
    let s_k = Array2::from_diag(&s.slice(s![0..k]));
    let vt_k = vt.slice(s![0..k, ..]);

    u_k.dot(&s_k).dot(&vt_k)
}

fn decompress_svd(u: &Array2<f64>, s: &Array1<f64>, vt: &Array2<f64>) -> Array2<f64> {
    // Pobierz wymiary macierzy
    let (m, _) = u.dim();
    let (_, n) = vt.dim();
    
    // Utwórz prostokątną macierz diagonalną
    let mut s_diag = Array2::<f64>::zeros((m, n));
    let k = s.len().min(m).min(n);
    
    for i in 0..k {
        s_diag[[i, i]] = s[i];
    }
    
    // Mnożymy U × Σ × V^T aby zrekonstruować oryginalną macierz
    u.dot(&s_diag).dot(vt)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let mode = if args.len() > 1 { &args[1] } else { "compress" };
    
    let input_path = "example.png";
    let output_path = match mode {
        "compress" => "compressed.png",
        "decompress" => "decompressed.png",
        _ => {
            println!("Nieznany tryb. Użyj 'compress' lub 'decompress'");
            return;
        }
    };
    
    let k = 10; // wartość dla kompresji

    let img = match image::open(&Path::new(input_path)) {
        Ok(img) => img.to_luma8(),
        Err(e) => {
            eprintln!("Error opening image file: {}", e);
            eprintln!("Please make sure '{}' exists in the current directory", input_path);
            return;
        }
    };

    let array = image_to_ndarray(&img);
    
    // Zależnie od trybu, wykonaj kompresję lub pełną dekompozycję
    let result_array = if mode == "compress" {
        // Standardowa kompresja z redukcją rangi
        let compressed_array = compress_svd(&array, k);
        
        // Wyświetl statystyki kompresji
        let (height, width) = array.dim();
        let original_data_size = height * width;
        let compressed_data_size = height * k + k + k * width;
        let data_reduction = original_data_size as f64 - compressed_data_size as f64;
        let percentage = (data_reduction / original_data_size as f64) * 100.0;
        
        println!("Oryginalna ilość danych: {} wartości", original_data_size);
        println!("Ilość danych po kompresji SVD (k={}): {} wartości", k, compressed_data_size);
        println!("Redukcja danych: {} wartości ({:.2}%)", data_reduction, percentage);
        println!("Współczynnik kompresji: {:.2}:1", original_data_size as f64 / compressed_data_size as f64);
        
        compressed_array
    } else {
        // Pełna dekompozycja SVD do odtworzenia oryginalnego obrazu
        let (u, s, vt) = array.svd(true, true).unwrap();
        let u = u.unwrap();
        let vt = vt.unwrap();
        
        println!("Wykonuję pełną dekompozycję SVD do odtworzenia oryginalnego obrazu");
        decompress_svd(&u, &s, &vt)
    };
    
    let result_img = ndarray_to_image(&result_array);
    result_img.save(&Path::new(output_path)).expect("Cannot save image");
    
    println!("Saved {} image as {}", if mode == "compress" { "compressed" } else { "decompressed" }, output_path);
}
