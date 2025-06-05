use plotters::prelude::*;
use gif::{Frame, Encoder, Repeat};
use std::fs::File;

const BODY_RADIUS: i32 = 5;  // Rozmiar kul

pub fn create_animation(data: &Vec<Vec<f64>>, filename: &str, frame_skip: usize) -> Result<(), Box<dyn std::error::Error>> {
    // Ustal parametry obrazu - explicitly as usize
    let width: usize = 800;
    let height: usize = 600;
    
    // Znajdź zakres danych dla skalowania
    let (x_vals, y_vals): (Vec<_>, Vec<_>) = data
        .iter()
        .flat_map(|s| vec![s[0], s[2], s[4]])
        .zip(data.iter().flat_map(|s| vec![s[1], s[3], s[5]]))
        .unzip();

    let x_min = x_vals.iter().cloned().fold(f64::INFINITY, f64::min);
    let x_max = x_vals.iter().cloned().fold(f64::NEG_INFINITY, f64::max);
    let y_min = y_vals.iter().cloned().fold(f64::INFINITY, f64::min);
    let y_max = y_vals.iter().cloned().fold(f64::NEG_INFINITY, f64::max);

    // Przygotuj kodek GIF
    let mut image = File::create(filename)?;
    let mut encoder = Encoder::new(&mut image, width as u16, height as u16, &[])?;
    encoder.set_repeat(Repeat::Infinite)?;
    
    // Iteruj przez dane, tworząc klatki
    let total_frames = (data.len() + frame_skip - 1) / frame_skip;
    for (i, step) in (0..data.len()).step_by(frame_skip).enumerate() {
        if i % (total_frames / 10).max(1) == 0 {
            println!("Generowanie klatki: {}/{}", i, total_frames);
        }
        
        let state = &data[step];
        
        // Stwórz nową klatkę
        let root = BitMapBackend::new("temp_frame.png", (width as u32, height as u32)).into_drawing_area();
        root.fill(&WHITE)?;
        
        // Przygotuj wykres
        let mut chart = ChartBuilder::on(&root)
            .caption(format!("Symulacja 3 ciał (krok: {})", step), ("sans-serif", 20))
            .margin(20)
            .x_label_area_size(40)
            .y_label_area_size(40)
            .build_cartesian_2d(x_min..x_max, y_min..y_max)?;
        
        chart.configure_mesh().draw()?;
        
        // Rysuj tory - jako linie od początku do obecnej pozycji
        let mut x1 = vec![];
        let mut y1 = vec![];
        let mut x2 = vec![];
        let mut y2 = vec![];
        let mut x3 = vec![];
        let mut y3 = vec![];
        
        // Zbierz dane historyczne dla torów
        for s in data.iter().take(step + 1) {
            x1.push(s[0]);
            y1.push(s[1]);
            x2.push(s[2]);
            y2.push(s[3]);
            x3.push(s[4]);
            y3.push(s[5]);
        }
        
        // Rysuj tory
        chart.draw_series(LineSeries::new(
            x1.iter().zip(y1.iter()).map(|(&x, &y)| (x, y)),
            &RED.mix(0.3) // Półprzezroczyste linie
        ))?;
        chart.draw_series(LineSeries::new(
            x2.iter().zip(y2.iter()).map(|(&x, &y)| (x, y)),
            &BLUE.mix(0.3)
        ))?;
        chart.draw_series(LineSeries::new(
            x3.iter().zip(y3.iter()).map(|(&x, &y)| (x, y)),
            &GREEN.mix(0.3)
        ))?;
        
        // Rysuj ciała jako koła
        chart.draw_series(std::iter::once(Circle::new(
            (state[0], state[1]),
            BODY_RADIUS,
            RED.filled(),
        )))?;
        chart.draw_series(std::iter::once(Circle::new(
            (state[2], state[3]),
            BODY_RADIUS,
            BLUE.filled(),
        )))?;
        chart.draw_series(std::iter::once(Circle::new(
            (state[4], state[5]),
            BODY_RADIUS,
            GREEN.filled(),
        )))?;
        
        root.present()?;
        
        // Dodaj klatkę do GIFa - poprawiona obsługa
        let png_data = std::fs::read("temp_frame.png")?;
        let decoder = png::Decoder::new(std::io::Cursor::new(png_data));
        let mut reader = decoder.read_info()?;
        let mut buf = vec![0; reader.output_buffer_size()];
        let info = reader.next_frame(&mut buf)?;
        
        // Przekonwertuj do formatu RGBA, którego oczekuje gif (upewnij się, że dane mają właściwy format)
        let mut rgba = vec![0u8; width * height * 4]; 
        
        // Konwersja w zależności od formatu źródłowego PNG
        if info.color_type == png::ColorType::Rgba {
            // Jeśli już mamy RGBA, po prostu kopiujemy
            rgba.copy_from_slice(&buf[0..(width * height * 4)]);
        } else if info.color_type == png::ColorType::Rgb {
            // Konwersja z RGB na RGBA - z poprawnym typem usize
            for y in 0..height {
                for x in 0..width {
                    let src_idx: usize = (y * width + x) * 3;
                    let dst_idx: usize = (y * width + x) * 4;
                    rgba[dst_idx] = buf[src_idx];
                    rgba[dst_idx + 1] = buf[src_idx + 1];
                    rgba[dst_idx + 2] = buf[src_idx + 2];
                    rgba[dst_idx + 3] = 255; // Pełna nieprzezroczystość
                }
            }
        } else {
            return Err(format!("Nieobsługiwany format koloru: {:?}", info.color_type).into());
        }

        // Teraz mamy poprawny bufor RGBA
        let mut frame = Frame::from_rgba_speed(width as u16, height as u16, &mut rgba, 10);
        frame.delay = 5;  // 1/20 sekundy
        encoder.write_frame(&frame)?;
    }
    
    // Usuń plik tymczasowy
    std::fs::remove_file("temp_frame.png")?;
    
    println!("Animacja GIF zapisana: {}", filename);
    Ok(())
}