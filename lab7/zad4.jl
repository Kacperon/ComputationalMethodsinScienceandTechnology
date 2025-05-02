using QuadGK, Polynomials

p = Polynomial([1, 2, 3])  # 1 + 2x + 3x^2

val, err = quadgk(p, -1, 2)
println("∫_{-1}^{2} (3x² + 2x + 1) dx = $val (błąd oszacowany: $err)")

gauss_pdf(x) = 1 / sqrt(2π) * exp(-x^2 / 2)

val, err = quadgk(gauss_pdf, -Inf, Inf)
println("∫_{-∞}^{∞} N(0,1)(x) dx = $val (błąd oszacowany: $err)")
