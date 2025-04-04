CC = gcc
CFLAGS = 
OPTFLAGS = -O2
FASTOPTFLAGS = -Ofast
LIBS = -lgsl -lgslcblas -lm
SRC = matrix_mul.c

# Output binaries
OUT_NO_OPT = matrix_mul
OUT_OPT = matrix_mul_opt
OUT_FAST_OPT = matrix_mul_fastopt

# Default target
all: run

# Kompilacja bez optymalizacji
no_opt: $(SRC)
	$(CC) $(CFLAGS) -o $(OUT_NO_OPT) $(SRC) $(LIBS)

# Kompilacja z optymalizacją O2
opt: $(SRC)
	$(CC) $(OPTFLAGS) -o $(OUT_OPT) $(SRC) $(LIBS)

# Kompilacja z optymalizacją Ofast
fastopt: $(SRC)
	$(CC) $(FASTOPTFLAGS) -o $(OUT_FAST_OPT) $(SRC) $(LIBS)

# Uruchomienie wszystkich trzech wersji i zapis do CSV
run: no_opt opt fastopt
	./$(OUT_NO_OPT)
	mv results_c.csv results_c_no_opt.csv
	./$(OUT_OPT)
	mv results_c.csv results_c_opt.csv
	./$(OUT_FAST_OPT)
	mv results_c.csv results_c_fastopt.csv
	@echo "Wyniki zapisane w: results_c_no_opt.csv, results_c_opt.csv i results_c_fastopt.csv"

# Usuwanie plików
clean:
	rm -f $(OUT_NO_OPT) $(OUT_OPT) $(OUT_FAST_OPT) results_c*.csv
