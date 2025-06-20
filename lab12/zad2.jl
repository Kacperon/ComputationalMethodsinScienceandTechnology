using FFTW, Plots, Random

# 1. Tworzymy sygnał z szumem
N = 1024
x = range(0, 2π, length=N)
signal = cos.(5 .* x) + 0.7*cos.(20 .*x) + 0.4*cos.(50 .*x)               # sygnał bazowy
noise = 2.5 .* randn(N) .- 0.5            # szum w zakresie [-0.5, 0.5]
noisy_signal = signal .+ noise            # sygnał zaszumiony

# 2. FFT
spectrum = fft(noisy_signal)

# 3. Odszumianie – filtracja widma
filtered_spectrum = copy(spectrum)
filtered_spectrum[abs.(spectrum) .< 200] .= 0

# 4. Odwrotna FFT
denoised_signal = real(ifft(filtered_spectrum))

# 5. Rysowanie wykresów
plot1 = plot(x, noisy_signal, label="Zaszumiony sygnał", title="Sygnał wejściowy")
plot2 = plot(abs.(spectrum), label="Widmo FFT", title="Widmo sygnału (FFT)")
plot3 = plot(abs.(filtered_spectrum), label="Widmo odszumione", title="Widmo po filtracji")
plot4 = plot(x, denoised_signal, label="Odszumiony sygnał", title="Sygnał po IFFT")

# Układanie wykresów 2x2
plot(plot1, plot2, plot3, plot4, layout=(2, 2), size=(900, 600))
savefig("zad2.png")