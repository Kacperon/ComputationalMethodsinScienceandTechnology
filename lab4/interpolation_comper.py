import matplotlib
matplotlib.use('Qt5Agg')

import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import CubicSpline

def lagrange_basis(x, x_nodes, k):
    """Oblicza k-tą bazową funkcję Lagrange'a w punkcie x."""
    L_k = 1
    for i in range(len(x_nodes)):
        if i != k:
            L_k *= (x - x_nodes[i]) / (x_nodes[k] - x_nodes[i])
    return L_k

def lagrange_interpolation(x, x_nodes, y_nodes):
    """Oblicza wartość wielomianu interpolacyjnego Lagrange'a w punkcie x."""
    P_x = 0
    for k in range(len(x_nodes)):
        P_x += y_nodes[k] * lagrange_basis(x, x_nodes, k)
    return P_x

# Lista przechowująca węzły jako krotki (x, y)
nodes = []

# Tworzenie wykresu
fig, ax = plt.subplots(figsize=(8, 6))
ax.set_title("Prawy przycisk: dodawanie punktu, Lewy przycisk: usuwanie punktu")
ax.set_xlabel("x")
ax.set_ylabel("y")
ax.grid(True)
ax.set_xlim(-20, 20)
ax.set_ylim(-2, 2)

# Inicjalizacja wykresu węzłów oraz obu interpolacji
node_scatter = ax.scatter([], [], color='red', label="Węzły interpolacji", zorder=3)
lagrange_line, = ax.plot([], [], 'b-', label="Interpolacja Lagrange'a", zorder=2)
cubic_line, = ax.plot([], [], color='orange', linestyle='--', label="Interpolacja sześcienna", zorder=2)
ax.legend()

def redraw_nodes():
    """Aktualizuje rysunek węzłów."""
    if nodes:
        x_nodes, y_nodes = zip(*nodes)
    else:
        x_nodes, y_nodes = [], []
    node_scatter.set_offsets(np.column_stack((x_nodes, y_nodes)))
    fig.canvas.draw_idle()

def update_interpolations():
    """Aktualizuje interpolacje Lagrange'a oraz sześcienną na podstawie bieżących węzłów."""
    if len(nodes) < 1:
        lagrange_line.set_data([], [])
        cubic_line.set_data([], [])
        fig.canvas.draw_idle()
        return

    # Sortowanie węzłów według współrzędnej x
    nodes.sort(key=lambda p: p[0])
    x_nodes, y_nodes = zip(*nodes)

    # Definiujemy przedział interpolacji na stałe: x w [-20,20]
    x_vals = np.linspace(-20, 20, 500)
    
    # Interpolacja Lagrange'a
    lagrange_vals = [lagrange_interpolation(x, x_nodes, y_nodes) for x in x_vals]
    lagrange_line.set_data(x_vals, lagrange_vals)
    
    # Interpolacja sześcienna (cubic)
    # Warunek: potrzebne są przynajmniej 2 węzły, aby CubicSpline działał
    if len(x_nodes) >= 2:
        cs = CubicSpline(x_nodes, y_nodes)
        cubic_vals = cs(x_vals)
        cubic_line.set_data(x_vals, cubic_vals)
    else:
        cubic_line.set_data([], [])
    
    # Utrzymanie stałego okna wykresu
    ax.set_xlim(-20, 20)
    ax.set_ylim(-2, 2)
    fig.canvas.draw_idle()

def on_click(event):
    """Obsługuje zdarzenia kliknięć:
       - Lewy przycisk (button 1): usuwa najbliższy punkt,
       - Prawy przycisk (button 3): dodaje nowy punkt."""
    if event.inaxes != ax:
        return

    if event.button == 1:  # Lewy przycisk: usuwanie
        if nodes:
            dists = [np.hypot(event.xdata - nx, event.ydata - ny) for nx, ny in nodes]
            min_idx = np.argmin(dists)
            # Próg odległości do usunięcia (dostosuj według potrzeb)
            if dists[min_idx] < 0.5:
                nodes.pop(min_idx)
    elif event.button == 3:  # Prawy przycisk: dodawanie
        nodes.append((event.xdata, event.ydata))
    
    redraw_nodes()
    update_interpolations()

fig.canvas.mpl_connect('button_press_event', on_click)

plt.show()
