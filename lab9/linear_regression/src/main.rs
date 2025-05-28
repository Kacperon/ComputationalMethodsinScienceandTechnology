use ndarray::{Array1, Array2};
use ndarray_linalg::{QR, Solve};
use rand_distr::{Normal, Distribution};
use plotters::prelude::*;
use std::env;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Pobierz liczbę punktów z argumentów wiersza poleceń
    let args: Vec<String> = env::args().collect();
    let num_points = if args.len() > 1 {
        match args[1].parse::<usize>() {
            Ok(n) => n,
            Err(_) => {
                println!("Nieprawidłowa liczba punktów. Używam domyślnej wartości 5000.");
                500
            }
        }
    } else {
        // Domyślna liczba punktów
        500
    };

    println!("Generuję {} punktów do regresji liniowej", num_points);

    // Przykładowe dane do regresji liniowej
    let mut rng = rand::rng();
    // Generuj punkty x w przedziale [0, 10] w równych odstępach, z szumem normalnym
    let normal = Normal::new(0.0, 2.0).unwrap();
    let x_data: Vec<f64> = (0..num_points)
        .map(|i| 10.0 * i as f64 / (num_points as f64 - 1.0) + normal.sample(&mut rng))
        .collect();
    let normal = Normal::new(0.0, 5.0).unwrap();
    let y_data: Vec<f64> = x_data
        .iter()
        .map(|&x| 2.0 + 2.0 * x + normal.sample(&mut rng))
        .collect();

    // Tworzymy macierz A (kolumna jedynek + x) i wektor b (y)
    let n = x_data.len();
    let a: Array2<f64> = Array2::from_shape_vec(
        (n, 2),
        x_data.iter().flat_map(|&x| vec![1.0, x]).collect(),
    )?;
    let b = Array1::from_vec(y_data.clone());

    // Faktoryzacja QR i rozwiązanie Rx = Qᵀb
    let (q, r) = a.qr()?;  // QR returns a tuple (Q, R) directly
    let qt_b = q.t().dot(&b);
    let x = r.solve_into(qt_b)?;

    println!("Współczynniki regresji (beta_0, beta_1): {:?}", x);

    // Wizualizacja danych i dopasowanej prostej
    let root = BitMapBackend::new("plot.png", (1600, 1200)).into_drawing_area();
    root.fill(&WHITE)?;

    // Znajdź min i max wartości dla skalowania wykresu
    let x_min = *x_data.iter().min_by(|a, b| a.partial_cmp(b).unwrap()).unwrap();
    let x_max = *x_data.iter().max_by(|a, b| a.partial_cmp(b).unwrap()).unwrap();
    let y_min = *y_data.iter().min_by(|a, b| a.partial_cmp(b).unwrap()).unwrap();
    let y_max = *y_data.iter().max_by(|a, b| a.partial_cmp(b).unwrap()).unwrap();

    // Dodaj margines dla lepszej czytelności
    let x_margin = (x_max - x_min) * 0.1;
    let y_margin = (y_max - y_min) * 0.1;

    let mut chart = ChartBuilder::on(&root)
        .caption("Dopasowanie liniowe (regresja QR)", ("sans-serif", 30))
        .margin(30)
        .x_label_area_size(40)
        .y_label_area_size(40)
        .build_cartesian_2d(
            (x_min - x_margin)..(x_max + x_margin),
            (y_min - y_margin)..(y_max + y_margin)
        )?;

    chart.configure_mesh().draw()?;

    // Punkty danych
    chart.draw_series(
        x_data
            .iter()
            .zip(y_data.iter().cloned()) // Use cloned() to avoid moving y_data
            .map(|(&x, y)| Circle::new((x, y), 1, RED.filled())),
    )?;

    // Linia regresji: y = beta_0 + beta_1 * x
    let beta_0 = x[0];
    let beta_1 = x[1];

    // Rysuj linię regresji dokładnie w zakresie danych
    chart.draw_series(LineSeries::new(
        vec![
            (x_min - x_margin, beta_0 + beta_1 * (x_min - x_margin)),
            (x_max + x_margin, beta_0 + beta_1 * (x_max + x_margin))
        ],
        &BLUE,
    ))?;

    println!("Wykres zapisany do plot.png");

    Ok(())
}
