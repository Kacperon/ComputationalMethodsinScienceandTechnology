use image::{GrayImage, Luma};
use ndarray::{Array1, Array2, ArrayBase, DataMut, Ix2, s};
use ndarray_linalg::svd::SVD;
use std::path::Path;
use std::env;
use std::cmp::min;

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
    
    // W trybie kompresji użytkownik określa plik wejściowy, w dekompresji zawsze używamy compressed.png
    let input_path = if mode == "compress" {
        if args.len() > 2 { args[2].clone() } else { "example.png".to_string() }
    } else {
        "compressed.png".to_string()
    };
    
    let output_path = match mode {
        "compress" => "compressed.png",
        "decompress" => "decompressed.png",
        _ => {
            println!("Nieznany tryb. Użyj 'compress' lub 'decompress'");
            return;
        }
    };
    
    // Stopień kompresji - im mniejszy, tym większa kompresja
    let k = if args.len() > 3 { args[3].parse::<usize>().unwrap_or(10) } else { 10 };
    
    if mode == "compress" {
        let img = match image::open(&Path::new(&input_path)) {
            Ok(img) => img.to_luma8(),
            Err(e) => {
                eprintln!("Error opening image file: {}", e);
                eprintln!("Please make sure '{}' exists in the current directory", input_path);
                return;
            }
        };

        let array = image_to_ndarray(&img);
        let (height, width) = array.dim();
        
        // Standardowa kompresja z redukcją rangi
        let (u, s, vt) = array.svd(true, true).unwrap();
        let u = u.unwrap();
        let vt = vt.unwrap();
        
        // Zapisujemy oryginalną rozdzielczość i stopień kompresji do pliku metadanych
        let metadata_path = "image_metadata.txt";
        std::fs::write(metadata_path, format!("{} {} {}", width, height, k))
            .expect("Failed to save image metadata");
            
        // Oblicz nową rozdzielczość proporcjonalną do wartości k
        let resize_factor = ((k as f64) / (min(height, width) as f64)).sqrt().min(1.0);
        let new_height = (height as f64 * resize_factor).round() as usize;
        let new_width = (width as f64 * resize_factor).round() as usize;
        
        // Wyświetl statystyki kompresji
        let original_data_size = height * width;
        let compressed_data_size = new_height * new_width; // Dane obrazu o zredukowanej rozdzielczości
        let data_reduction = original_data_size as f64 - compressed_data_size as f64;
        let percentage = (data_reduction / original_data_size as f64) * 100.0;
        
        println!("Oryginalna rozdzielczość: {}x{} ({} pikseli)", width, height, original_data_size);
        println!("Skompresowana rozdzielczość: {}x{} ({} pikseli)", new_width, new_height, compressed_data_size);
        println!("Redukcja danych: {} pikseli ({:.2}%)", data_reduction, percentage);
        println!("Współczynnik kompresji: {:.2}:1", original_data_size as f64 / compressed_data_size as f64);
        
        // Zapisz składowe SVD do użycia przy dekompresji
        // W rzeczywistej aplikacji zapisalibyśmy je w binarnym formacie
        let u_k = u.slice(s![.., 0..k]);
        let s_k = Array2::from_diag(&s.slice(s![0..k]));
        let vt_k = vt.slice(s![0..k, ..]);
        let compressed_array = u_k.dot(&s_k).dot(&vt_k);
        let result_img = ndarray_to_image(&compressed_array);
        
        // Resize do nowej rozdzielczości
        let resized_img = image::imageops::resize(
            &result_img, 
            new_width as u32, 
            new_height as u32, 
            image::imageops::FilterType::Lanczos3
        );
        
        resized_img.save(&Path::new(output_path)).expect("Cannot save compressed image");
        println!("Zapisano skompresowany obraz jako {} ({}x{})", output_path, new_width, new_height);
    } else {
        // Dekompresja - używamy compressed.png jako wejścia
        let compressed_img = match image::open(&Path::new(&input_path)) {
            Ok(img) => img.to_luma8(),
            Err(e) => {
                eprintln!("Error opening compressed image: {}", e);
                eprintln!("Please make sure '{}' exists in the current directory", input_path);
                return;
            }
        };
        
        let (compressed_width, compressed_height) = compressed_img.dimensions();
        
        // Odczytujemy metadane lub obliczamy oryginalną rozdzielczość na podstawie stopnia kompresji
        let original_size = if std::path::Path::new("image_metadata.txt").exists() {
            // Czytaj z metadanych, jeśli istnieją
            let content = std::fs::read_to_string("image_metadata.txt").unwrap_or_default();
            let parts: Vec<&str> = content.split_whitespace().collect();
            
            if parts.len() >= 3 {
                let original_width = parts[0].parse::<u32>().unwrap_or(800);
                let original_height = parts[1].parse::<u32>().unwrap_or(600);
                // Możemy też sprawdzić, czy k jest zgodne z tym z metadanych
                (original_width, original_height)
            } else {
                // Oblicz na podstawie stopnia kompresji
                let min_dim = compressed_width.min(compressed_height) as f64;
                let resize_factor = (min_dim / k as f64).sqrt();
                let target_width = (compressed_width as f64 / resize_factor).round() as u32;
                let target_height = (compressed_height as f64 / resize_factor).round() as u32;
                println!("Obliczam oryginalną rozdzielczość na podstawie stopnia kompresji k={}", k);
                (target_width, target_height)
            }
        } else {
            // Oblicz na podstawie stopnia kompresji
            let min_dim = compressed_width.min(compressed_height) as f64;
            let resize_factor = (min_dim / k as f64).sqrt();
            let target_width = (compressed_width as f64 / resize_factor).round() as u32;
            let target_height = (compressed_height as f64 / resize_factor).round() as u32;
            println!("Obliczam oryginalną rozdzielczość na podstawie stopnia kompresji k={}", k);
            (target_width, target_height)
        };
        
        let (target_width, target_height) = original_size;
        
        // Używamy interpolacji Lanczos3 do zwiększenia rozdzielczości
        // do oryginalnego rozmiaru
        let upscaled_img = image::imageops::resize(
            &compressed_img,
            target_width,
            target_height,
            image::imageops::FilterType::Lanczos3
        );
        
        upscaled_img.save(&Path::new(output_path)).expect("Cannot save decompressed image");
        println!("Zapisano zdekompresowany obraz jako {} ({}x{})", 
                 output_path, target_width, target_height);
        
        // Dodaj opcjonalną ścieżkę dekompresji używająca SVD (tylko dla demonstracji)
        if args.len() > 4 && args[4] == "svd" {
            println!("Używam dekompresji SVD...");
            
            // W rzeczywistym przykładzie załadowalibyśmy te dane z pliku
            let array = image_to_ndarray(&compressed_img);
            let (u, s, vt) = array.svd(true, true).unwrap();
            let u = u.unwrap();
            let vt = vt.unwrap();
            
            let decompressed_array = decompress_svd(&u, &s, &vt);
            let result_img = ndarray_to_image(&decompressed_array);
            result_img.save(&Path::new(output_path)).expect("Cannot save decompressed image");
            println!("Zapisano zdekompresowany obraz (SVD) jako {}", output_path);
            return;
        }
    }
}
