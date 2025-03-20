# Wczytanie niezbędnych pakietów
library(ggplot2)
library(dplyr)

# Ustalenie rozmiarów wektorów oraz liczby powtórzeń
sizes <- c(10000, 50000, 100000, 500000, 1000000)
replicates <- 10

# Inicjalizacja pustej ramki danych na wyniki
results <- data.frame(Function = character(),
                      Size = integer(),
                      Replicate = integer(),
                      Time = double(),
                      stringsAsFactors = FALSE)

# Pętla dla różnych rozmiarów i powtórzeń

dumsum <- cumsum(vec)
dumsort <- sort(vec)
for (size in sizes) {
  for (rep in 1:replicates) {
    # Generacja losowego wektora o zadanym rozmiarze
    vec <- runif(size)
    
    # Eksperyment 1: Obliczanie sumy wektora
    dumsum <- cumsum(vec)

    t_sum <- system.time(cumsum(vec))["elapsed"]
    
    # Eksperyment 2: Sortowanie wektora
    dumsort <- sort(vec)

    t_sort <- system.time(sort(vec))["elapsed"]
    
    # Zapisanie wyników do tabeli
    results <- rbind(results,
                     data.frame(Function = "Cumsum",
                                Size = size,
                                Replicate = rep,
                                Time = t_sum))
    results <- rbind(results,
                     data.frame(Function = "Sort",
                                Size = size,
                                Replicate = rep,
                                Time = t_sort))
  }
}

# Obliczenie średniego czasu i odchylenia standardowego dla każdego eksperymentu i rozmiaru
summary_df <- results %>%
  group_by(Function, Size) %>%
  summarise(mean_time = mean(Time),
            sd_time = sd(Time))

# Wykres średnich czasów z słupkami błędów (odchylenie standardowe)
p <- ggplot(summary_df, aes(x = Size, y = mean_time, color = Function)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = mean_time - sd_time, ymax = mean_time + sd_time), width = 0.2) +
  scale_x_continuous(breaks = sizes) +
  labs(title = "Średni czas wykonania funkcji w zależności od rozmiaru wektora",
       x = "Rozmiar wektora",
       y = "Czas (s)") +
  theme_minimal()

# Wyświetlenie wykresu
print(p)
ggsave("wyniki_wykres.png", width = 8, height = 6, dpi = 300,bg="white")
