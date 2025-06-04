pub const G: f64 = 1.0; // Stała grawitacji

// Funkcja opisująca dynamikę układu 3 ciał w 2D
pub fn three_body(y: &Vec<f64>, _t: f64) -> Vec<f64> {
    let m1 = 1.0;
    let m2 = 1.0;
    let m3 = 1.0;

    // pozycje
    let (x1, y1, x2, y2, x3, y3) = (y[0], y[1], y[2], y[3], y[4], y[5]);
    // prędkości
    let (vx1, vy1, vx2, vy2, vx3, vy3) = (y[6], y[7], y[8], y[9], y[10], y[11]);

    let dx12 = x2 - x1;
    let dy12 = y2 - y1;
    let dx13 = x3 - x1;
    let dy13 = y3 - y1;
    let dx23 = x3 - x2;
    let dy23 = y3 - y2;

    let r12 = (dx12.powi(2) + dy12.powi(2)).sqrt().powi(3);
    let r13 = (dx13.powi(2) + dy13.powi(2)).sqrt().powi(3);
    let r23 = (dx23.powi(2) + dy23.powi(2)).sqrt().powi(3);

    let ax1 = G * (m2 * dx12 / r12 + m3 * dx13 / r13);
    let ay1 = G * (m2 * dy12 / r12 + m3 * dy13 / r13);

    let ax2 = G * (-m1 * dx12 / r12 + m3 * dx23 / r23);
    let ay2 = G * (-m1 * dy12 / r12 + m3 * dy23 / r23);

    let ax3 = G * (-m1 * dx13 / r13 - m2 * dx23 / r23);
    let ay3 = G * (-m1 * dy13 / r13 - m2 * dy23 / r23);

    vec![
        vx1, vy1, vx2, vy2, vx3, vy3, // pochodne pozycji = prędkości
        ax1, ay1, ax2, ay2, ax3, ay3, // pochodne prędkości = przyspieszenia
    ]
}

// Metoda Eulera
pub fn euler<F>(f: F, y0: Vec<f64>, t0: f64, dt: f64, steps: usize) -> Vec<Vec<f64>>
where
    F: Fn(&Vec<f64>, f64) -> Vec<f64>,
{
    let mut y = y0.clone();
    let mut result = vec![y.clone()];
    let mut t = t0;

    for _ in 0..steps {
        let dy = f(&y, t);
        for i in 0..y.len() {
            y[i] += dt * dy[i];
        }
        result.push(y.clone());
        t += dt;
    }

    result
}

// Runge-Kutta 4th order method
pub fn rk4<F>(f: F, y0: Vec<f64>, t0: f64, dt: f64, steps: usize) -> Vec<Vec<f64>>
where
    F: Fn(&Vec<f64>, f64) -> Vec<f64>,
{
    let mut y = y0.clone();
    let mut result = vec![y.clone()];
    let mut t = t0;

    for _ in 0..steps {
        let k1 = f(&y, t);
        
        let mut y_temp = y.clone();
        for i in 0..y.len() {
            y_temp[i] += dt * k1[i] / 2.0;
        }
        let k2 = f(&y_temp, t + dt / 2.0);
        
        let mut y_temp = y.clone();
        for i in 0..y.len() {
            y_temp[i] += dt * k2[i] / 2.0;
        }
        let k3 = f(&y_temp, t + dt / 2.0);
        
        let mut y_temp = y.clone();
        for i in 0..y.len() {
            y_temp[i] += dt * k3[i];
        }
        let k4 = f(&y_temp, t + dt);
        
        for i in 0..y.len() {
            y[i] += dt * (k1[i] + 2.0 * k2[i] + 2.0 * k3[i] + k4[i]) / 6.0;
        }
        
        result.push(y.clone());
        t += dt;
    }

    result
}

// Add this function to calculate total energy
pub fn calculate_energy(state: &Vec<f64>) -> f64 {
    let m1 = 1.0;
    let m2 = 1.0;
    let m3 = 1.0;

    // Positions
    let (x1, y1, x2, y2, x3, y3) = (state[0], state[1], state[2], state[3], state[4], state[5]);
    // Velocities
    let (vx1, vy1, vx2, vy2, vx3, vy3) = (state[6], state[7], state[8], state[9], state[10], state[11]);

    // Kinetic energy
    let kinetic = 0.5 * m1 * (vx1*vx1 + vy1*vy1) + 
                  0.5 * m2 * (vx2*vx2 + vy2*vy2) + 
                  0.5 * m3 * (vx3*vx3 + vy3*vy3);

    // Distances between bodies
    let r12 = ((x2-x1).powi(2) + (y2-y1).powi(2)).sqrt();
    let r13 = ((x3-x1).powi(2) + (y3-y1).powi(2)).sqrt();
    let r23 = ((x3-x2).powi(2) + (y3-y2).powi(2)).sqrt();

    // Potential energy
    let potential = -G * ((m1*m2/r12) + (m1*m3/r13) + (m2*m3/r23));

    kinetic + potential
}