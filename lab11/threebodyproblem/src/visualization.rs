use plotters::prelude::*;
use crate::physics::calculate_energy;

// Wykres torów
pub fn draw_trajectories(data: &Vec<Vec<f64>>, filename: &str) -> Result<(), Box<dyn std::error::Error>> {
    let root = BitMapBackend::new(filename, (800, 600)).into_drawing_area();
    root.fill(&WHITE)?;

    let (x_vals, y_vals): (Vec<_>, Vec<_>) = data
        .iter()
        .flat_map(|s| vec![s[0], s[2], s[4]])
        .zip(data.iter().flat_map(|s| vec![s[1], s[3], s[5]]))
        .unzip();

    let x_range = x_vals.iter().cloned().fold(f64::INFINITY, f64::min)
        ..x_vals.iter().cloned().fold(f64::NEG_INFINITY, f64::max);
    let y_range = y_vals.iter().cloned().fold(f64::INFINITY, f64::min)
        ..y_vals.iter().cloned().fold(f64::NEG_INFINITY, f64::max);

    let mut chart = ChartBuilder::on(&root)
        .caption("Trajektorie 3 ciał (Euler)", ("sans-serif", 30))
        .margin(20)
        .x_label_area_size(40)
        .y_label_area_size(40)
        .build_cartesian_2d(x_range, y_range)?;

    chart.configure_mesh().draw()?;

    let mut x1 = vec![];
    let mut y1 = vec![];
    let mut x2 = vec![];
    let mut y2 = vec![];
    let mut x3 = vec![];
    let mut y3 = vec![];

    for s in data {
        x1.push(s[0]);
        y1.push(s[1]);
        x2.push(s[2]);
        y2.push(s[3]);
        x3.push(s[4]);
        y3.push(s[5]);
    }

    chart.draw_series(LineSeries::new(x1.iter().zip(y1.iter()).map(|(&x, &y)| (x, y)), &RED))?;
    chart.draw_series(LineSeries::new(x2.iter().zip(y2.iter()).map(|(&x, &y)| (x, y)), &BLUE))?;
    chart.draw_series(LineSeries::new(x3.iter().zip(y3.iter()).map(|(&x, &y)| (x, y)), &GREEN))?;

    Ok(())
}

pub fn draw_method_comparison_grid(method_name: &str, results: &[Vec<Vec<f64>>], dt_values: &[f64], filename: &str) -> Result<(), Box<dyn std::error::Error>> {
    let root = BitMapBackend::new(filename, (1000, 1000)).into_drawing_area();
    root.fill(&WHITE)?;
    
    // Split the drawing area into a 2x2 grid
    let areas = root.split_evenly((2, 2));
    
    for (idx, (area, result)) in areas.iter().zip(results.iter()).enumerate() {
        // Extract positions
        let (x_vals, y_vals): (Vec<_>, Vec<_>) = result
            .iter()
            .flat_map(|s| vec![s[0], s[2], s[4]])
            .zip(result.iter().flat_map(|s| vec![s[1], s[3], s[5]]))
            .unzip();

        // Calculate ranges
        let x_range = x_vals.iter().cloned().fold(f64::INFINITY, f64::min)
            ..x_vals.iter().cloned().fold(f64::NEG_INFINITY, f64::max);
        let y_range = y_vals.iter().cloned().fold(f64::INFINITY, f64::min)
            ..y_vals.iter().cloned().fold(f64::NEG_INFINITY, f64::max);

        // Create chart for this section
        let mut chart = ChartBuilder::on(area)
            .caption(format!("{} (dt = {})", method_name, dt_values[idx]), ("sans-serif", 20))
            .margin(10)
            .x_label_area_size(30)
            .y_label_area_size(30)
            .build_cartesian_2d(x_range, y_range)?;

        chart.configure_mesh().draw()?;

        // Extract trajectory data
        let mut x1 = vec![];
        let mut y1 = vec![];
        let mut x2 = vec![];
        let mut y2 = vec![];
        let mut x3 = vec![];
        let mut y3 = vec![];

        for s in result {
            x1.push(s[0]);
            y1.push(s[1]);
            x2.push(s[2]);
            y2.push(s[3]);
            x3.push(s[4]);
            y3.push(s[5]);
        }

        // Draw trajectories
        chart.draw_series(LineSeries::new(x1.iter().zip(y1.iter()).map(|(&x, &y)| (x, y)), &RED))?;
        chart.draw_series(LineSeries::new(x2.iter().zip(y2.iter()).map(|(&x, &y)| (x, y)), &BLUE))?;
        chart.draw_series(LineSeries::new(x3.iter().zip(y3.iter()).map(|(&x, &y)| (x, y)), &GREEN))?;
    }

    Ok(())
}

pub fn plot_energy_errors_grid(euler_results: &[Vec<Vec<f64>>], rk4_results: &[Vec<Vec<f64>>], dt_values: &[f64], filename: &str) -> Result<(), Box<dyn std::error::Error>> {
    let root = BitMapBackend::new(filename, (1000, 1000)).into_drawing_area();
    root.fill(&WHITE)?;
    
    // Split the drawing area into a 2x2 grid
    let areas = root.split_evenly((2, 2));
    
    for (idx, (area, (euler_data, rk4_data))) in areas.iter().zip(euler_results.iter().zip(rk4_results.iter())).enumerate() {
        // Calculate energy error for both methods
        let euler_energy: Vec<f64> = euler_data.iter().map(|state| calculate_energy(state)).collect();
        let rk4_energy: Vec<f64> = rk4_data.iter().map(|state| calculate_energy(state)).collect();
        
        // Calculate relative energy error
        let initial_energy_euler = euler_energy[0];
        let initial_energy_rk4 = rk4_energy[0];
        
        let euler_energy_error: Vec<f64> = euler_energy.iter()
            .map(|e| (e - initial_energy_euler).abs() / initial_energy_euler.abs())
            .collect();
        
        let rk4_energy_error: Vec<f64> = rk4_energy.iter()
            .map(|e| (e - initial_energy_rk4).abs() / initial_energy_rk4.abs())
            .collect();
        
        let time_points: Vec<f64> = (0..euler_energy.len()).map(|i| i as f64).collect();
        
        // Find the min/max error for Y axis scaling
        let min_error = euler_energy_error.iter()
            .chain(rk4_energy_error.iter())
            .cloned()
            .fold(f64::MAX, |a, b| a.min(b))
            .max(1e-15);
        
        let max_error = euler_energy_error.iter()
            .chain(rk4_energy_error.iter())
            .cloned()
            .fold(0.0, f64::max)
            .max(1e-12);
        
        // Create chart for this section
        let mut chart = ChartBuilder::on(area)
            .caption(format!("Błąd energii (dt = {})", dt_values[idx]), ("sans-serif", 20))
            .margin(10)
            .x_label_area_size(30)
            .y_label_area_size(40)
            .build_cartesian_2d(
                0.0..time_points.len() as f64,
                (min_error / 10.0..max_error * 10.0).log_scale()
            )?;
    
        chart.configure_mesh()
            .y_desc("Błąd (log)")
            .x_desc("Krok")
            .draw()?;
        
        // Draw energy error plots
        chart.draw_series(LineSeries::new(
            time_points.iter().zip(euler_energy_error.iter()).map(|(&t, &e)| (t, e)),
            &RED,
        ))?
        .label("Euler")
        .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], &RED));
        
        chart.draw_series(LineSeries::new(
            time_points.iter().zip(rk4_energy_error.iter()).map(|(&t, &e)| (t, e)),
            &BLUE,
        ))?
        .label("RK4")
        .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], &BLUE));
        
        // Add legend
        chart.configure_series_labels()
            .background_style(&WHITE.mix(0.8))
            .border_style(&BLACK)
            .draw()?;
    }

    Ok(())
}