using Plots, FFTW

# Parametry sygnału – skoncentrowane na niskich częstotliwościach
fs = 5000                  
T = 2.0                    
t = 0:1/fs:T-1/fs
N = length(t)

# Sygnał: suma dwóch sinusoid
x = sin.(2π*200*t) .+ 2*sin.(2π*400*t)

# Wykres sygnału w czasie (dla pierwszych 0.05 s)
plot(t[t .<= 0.05], x[t .<= 0.05],
     xlabel="Czas [s]", ylabel="Amplituda", 
     title="Sygnał w dziedzinie czasu", label="x(t)",
     linewidth=2, size=(800, 400))
savefig("sygnal_czas_lowfs.png")

# FFT z normalizacją
X = fft(x) / N
f = fs * (0:div(N,2)) / N
X_half = X[1:div(N,2)+1]

# Wykres widma amplitudowego (całość już w zakresie 0–1000 Hz)
plot(f, 2 .* abs.(X_half),
     xlabel="Częstotliwość [Hz]", ylabel="Amplituda",
     title="Widmo amplitudowe sygnału (0–1000 Hz)",
     linewidth=2, legend=false,
     xlims=(0,1000),
     size=(800, 400),
     yscale=:log10)
savefig("widmo.png")
