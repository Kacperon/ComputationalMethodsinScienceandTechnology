using GLMakie
using Dierckx

# Funkcja obliczająca bazową funkcję Lagrange'a
function lagrange_basis(x, x_nodes, k)
    Lk = 1.0
    for (i, xi) in enumerate(x_nodes)
        if i != k
            Lk *= (x - xi) / (x_nodes[k] - xi)
        end
    end
    return Lk
end

# Funkcja obliczająca wartość wielomianu interpolacyjnego Lagrange'a w punkcie x
function lagrange_interpolation(x, x_nodes, y_nodes)
    P_x = 0.0
    for k in 1:length(x_nodes)
        P_x += y_nodes[k] * lagrange_basis(x, x_nodes, k)
    end
    return P_x
end

# Globalna lista węzłów (każdy jako krotka (x, y))
nodes = Tuple{Float64, Float64}[]

# Tworzenie figury i osi z GLMakie
fig = Figure(resolution = (800,600), title = "Prawy przycisk: dodawanie punktu, Lewy przycisk: usuwanie punktu")
ax = Axis(fig[1, 1], xlabel = "x", ylabel = "y", limits = (-20, -2, 40, 4))
axislegend(ax)

# Inicjalizacja wykresów – scatter dla węzłów, linie dla interpolacji
node_scatter = scatter!(ax, Float64[], Float64[]; color = :red, markersize = 10)
lagrange_line = lines!(ax, Float64[], Float64[]; color = :blue, linestyle = :dash, label = "Interpolacja Lagrange'a")
cubic_line = lines!(ax, Float64[], Float64[]; color = :orange, linestyle = :dashdot, label = "Interpolacja sześcienna")

# Funkcja aktualizująca rysowanie węzłów
function redraw_nodes!()
    if !isempty(nodes)
        x_nodes = [p[1] for p in nodes]
        y_nodes = [p[2] for p in nodes]
        node_scatter[1] = x_nodes
        node_scatter[2] = y_nodes
    else
        node_scatter[1] = Float64[]
        node_scatter[2] = Float64[]
    end
    fig.canvas.update()
end

# Funkcja aktualizująca interpolacje na podstawie bieżących węzłów
function update_interpolations!()
    if length(nodes) < 1
        lagrange_line[1] = Float64[]
        lagrange_line[2] = Float64[]
        cubic_line[1] = Float64[]
        cubic_line[2] = Float64[]
        return
    end

    # Sortujemy węzły według x
    sorted_nodes = sort(nodes, by = p -> p[1])
    x_nodes = [p[1] for p in sorted_nodes]
    y_nodes = [p[2] for p in sorted_nodes]

    # Przedział interpolacji
    x_vals = range(-20, stop = 20, length = 500)
    # Obliczamy wartości Lagrange'a dla każdego x
    lagrange_vals = [lagrange_interpolation(x, x_nodes, y_nodes) for x in x_vals]
    lagrange_line[1] = collect(x_vals)
    lagrange_line[2] = lagrange_vals

    # Interpolacja sześcienna przy użyciu Dierckx (wymaga co najmniej 2 węzłów)
    if length(x_nodes) >= 2
        spline = Spline1D(x_nodes, y_nodes, k = 3)
        cubic_vals = spline.(x_vals)
        cubic_line[1] = collect(x_vals)
        cubic_line[2] = cubic_vals
    else
        cubic_line[1] = Float64[]
        cubic_line[2] = Float64[]
    end
    fig.canvas.update()
end

# Obsługa zdarzeń kliknięć myszy
on(fig.scene.events.mousebutton) do event
    # Sprawdzamy, czy pozycja myszy jest dostępna
    if isnothing(event.position)
        return
    end
    # Konwersja pozycji ekranu na współrzędne danych osi
    pos = event.position
    data_pos = to_world(ax, Point2f0(pos))
    xdata = data_pos[1]
    ydata = data_pos[2]

    # Lewy przycisk: usuń najbliższy punkt (jeśli odległość < 0.5)
    if event.button == Mouse.left && event.action == Mouse.down
        if !isempty(nodes)
            distances = [hypot(xdata - p[1], ydata - p[2]) for p in nodes]
            min_idx = argmin(distances)
            if distances[min_idx] < 0.5
                deleteat!(nodes, min_idx)
            end
        end
    # Prawy przycisk: dodaj punkt
    elseif event.button == Mouse.right && event.action == Mouse.down
        push!(nodes, (xdata, ydata))
    end

    redraw_nodes!
    update_interpolations!
end

# Wyświetlenie figury
display(fig)
