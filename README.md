# Computational Methods in Science and Technology

## Course Overview
This repository contains lab assignments for the **Computational Methods in Science and Technology** course. The course covers fundamental numerical algorithms and their properties, such as:

- conditioning,
- accuracy,
- stability,

in the context of computer arithmetic.

Labs are implemented in **Rust** and **Julia**.

## Repository Structure
```
📂 computational methods
│── 📂 lab1
│   ├── rust
│   ├── julia
│── 📂 lab2
│   ├── rust
│   ├── julia
│── ...
│── README.md
```
Each directory contains source code for the respective programming language.

## Requirements
To run the code, you need:

- **Rust** (recommended: `latest stable`)
- **Julia** (recommended: `latest stable`)

Additionally, install `cargo` for Rust and `Pkg` for Julia package management.

## Installation & Execution

### Rust
1. Install Rust via [rustup](https://rustup.rs/).
2. Navigate to the lab directory:
   ```sh
   cd lab1/rust
   ```
3. Build and run:
   ```sh
   cargo run
   ```

### Julia
1. Download and install [Julia](https://julialang.org/downloads/).
2. Navigate to the lab directory:
   ```sh
   cd lab1/julia
   ```
3. Run the script:
   ```sh
   julia main.jl
   ```

## Author
- **Kacperon** – (https://github.com/Kacperon)

## License
This project is released under the MIT License – see [LICENSE](LICENSE) for details.

