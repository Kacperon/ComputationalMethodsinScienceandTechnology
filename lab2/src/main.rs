// use half::f16;
// use std::error::Error;
// use std::fs::File;
// use std::io::Write;

// fn main() -> Result<(), Box<dyn Error>> {
//     let f16_val = f16::from_f32(1.0 / 3.0);
//     let f32_val: f32 = 1.0 / 3.0;
//     let f64_val: f64 = 1.0 / 3.0;
//     let f16_to_f64: f64 = f16_val.to_f64();

//     println!("Float16 (1/3)      : {:016b}", f16_val.to_bits());
//     println!("Float32 (1/3)      : {:032b}", f32_val.to_bits());
//     println!("Float64 (1/3)      : {:064b}", f64_val.to_bits());
//     println!("Float16 -> Float64 : {:064b}", f16_to_f64.to_bits());

//     // Wywołanie funkcji zapisującej do TXT
//     txt_write("zad1.txt", f16_val.to_bits(), f32_val.to_bits(), f64_val.to_bits(), f16_to_f64.to_bits())?;

//     println!("Dane zapisane do results.txt");

//     Ok(())
// }

// // Funkcja zapisująca wyniki do pliku tekstowego
// fn txt_write(
//     filename: &str,
//     f16_bits: u16,
//     f32_bits: u32,
//     f64_bits: u64,
//     f16_to_f64_bits: u64,
// ) -> Result<(), Box<dyn Error>> {
//     let mut file = File::create(filename)?;

//     // Zapisanie wyników w formacie tekstowym
//     writeln!(file, "Float16 (1/3)      : {:016b}", f16_bits)?;
//     writeln!(file, "Float32 (1/3)      : {:032b}", f32_bits)?;
//     writeln!(file, "Float64 (1/3)      : {:064b}", f64_bits)?;
//     writeln!(file, "Float16 -> Float64 : {:064b}", f16_to_f64_bits)?;

//     Ok(())
// }

use std::fs::File;
use std::io::{BufWriter, Write};

fn main() {
    // Tworzenie pliku CSV do zapisania wyników
    let file = File::create("zad2.csv").expect("Nie można utworzyć pliku");
    let mut writer = BufWriter::new(file);

    // Nagłówek pliku CSV
    writeln!(writer, "value,distance").expect("Nie można zapisać nagłówka");

    // Generowanie liczb w zadanym zakresie (mnożenie przez 10)
    let mut value: f64 = 1.0;
    while value <= 1000000.0 {

        let bits = value.to_bits();
        let next_bits = bits + 1;
        let next_value = f64::from_bits(next_bits);
        let distance = next_value - value;

        // Zapis do pliku CSV
        writeln!(writer, "{},{}", value, distance).expect("Nie można zapisać wartości");

        // Zmiana wartości na 10 razy większą
        value *= 1.0905077326652576592070106557606;
    }
}
