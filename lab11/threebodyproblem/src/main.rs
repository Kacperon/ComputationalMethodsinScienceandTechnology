mod physics;
mod visualization;
mod gif;

use physics::{three_body, euler, rk4};
// Remove unused import
use visualization::{draw_method_comparison_grid, plot_energy_errors_grid};
use gif::create_animation;
use chrono::Local;
use std::env;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Parse command line arguments
    let args: Vec<String> = env::args().collect();
    let mode = if args.len() > 1 { &args[1] } else { "plot" };  // Default to plot if no arg provided
    
    // Początkowe warunki: 3 ciała
    let y0 = vec![
        -1.0, 0.0, // x1, y1
        1.0, 0.0,  // x2, y2
        0.0, 0.5,  // x3, y3
        0.0, 1.0,  // vx1, vy1
        0.0, -1.0, // vx2, vy2
        0.0, 0.0,  // vx3, vy3
    ];

    let now = Local::now();
    let timestamp = now.format("%Y%m%d_%H%M%S").to_string();

    match mode {
        "gif" => {
            println!("Tryb animacji GIF");
            // For GIF we only need one simulation with reasonable parameters
            let dt = 0.001;
            let steps = 100000;
            
            println!("Running simulation with dt = {}", dt);
            let euler_result = euler(three_body, y0.clone(), 0.0, dt, steps);
            
            // Create animation
            let gif_filename = format!("three_body_animation_{}.gif", timestamp);
            println!("Generowanie animacji GIF...");
            create_animation(&euler_result, &gif_filename, 20)?;
            
            println!("Animacja zakończona. Wygenerowano:");
            println!("- {}", gif_filename);
        },
        _ => {  // Default to plots for any other input
            println!("Tryb statycznych wykresów");
            // Define 4 different time steps - from coarse to fine
            let dt_values = [0.001, 0.0001, 0.00001, 0.000001];
            let steps_values = [10000, 100000, 1000000, 10000000];
            
            let mut euler_results = Vec::new();
            let mut rk4_results = Vec::new();
            
            // Run simulations for each dt
            for (i, &dt) in dt_values.iter().enumerate() {
                println!("Running simulations with dt = {}", dt);
                let steps = steps_values[i];
                
                let euler_result = euler(three_body, y0.clone(), 0.0, dt, steps);
                let rk4_result = rk4(three_body, y0.clone(), 0.0, dt, steps);
                
                euler_results.push(euler_result);
                rk4_results.push(rk4_result);
            }
            
            // Create the comparison grids
            let euler_filename = format!("euler_grid_comparison_{}.png", timestamp);
            let rk4_filename = format!("rk4_grid_comparison_{}.png", timestamp);
            let energy_filename = format!("energy_error_grid_{}.png", timestamp);

            draw_method_comparison_grid("Metoda Eulera", &euler_results, &dt_values, &euler_filename)?;
            draw_method_comparison_grid("Metoda RK4", &rk4_results, &dt_values, &rk4_filename)?;
            
            // Create energy comparison grid
            plot_energy_errors_grid(&euler_results, &rk4_results, &dt_values, &energy_filename)?;

            println!("Symulacja zakończona. Wygenerowano:");
            println!("- {}", euler_filename);
            println!("- {}", rk4_filename);
            println!("- {}", energy_filename);
        }
    }
    
    Ok(())
}