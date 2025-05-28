import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from mpl_toolkits.mplot3d import Axes3D

# Parametry
L = 1.0           # długość boku kwadratu
N = 50            # liczba punktów siatki
dx = L / (N - 1)
dy = dx           # siatka równomierna
T = 10.0          # napięcie
p = 1.0           # ciśnienie

# Stała prawa strona równania
rhs = -p / T

# Inicjalizacja siatki
h = np.zeros((N, N))
h_new = np.zeros_like(h)

# Warunki brzegowe (wszystkie brzegi = 0 - już spełnione przez zerową inicjalizację)

# Gauss-Seidel Iteracje
def iterate(h, max_iter=1000, tol=1e-4):
    frames = []
    for it in range(max_iter):
        h_old = h.copy()
        for i in range(1, N-1):
            for j in range(1, N-1):
                h[i, j] = 0.25 * (h[i+1, j] + h[i-1, j] + h[i, j+1] + h[i, j-1] - dx**2 * rhs)
        if it % 10 == 0:
            frames.append(h.copy())
        if np.linalg.norm(h - h_old) < tol:
            break
    return h, frames

solution, frames = iterate(h)

# Wizualizacja końcowa
x = np.linspace(0, L, N)
y = np.linspace(0, L, N)
X, Y = np.meshgrid(x, y)

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
surf = ax.plot_surface(X, Y, solution, cmap='viridis')
ax.set_title('Statyczne odkształcenie membrany')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_zlabel('h(x, y)')
plt.show()

# Animacja
fig2 = plt.figure()
ax2 = fig2.add_subplot(111, projection='3d')

def update(frame):
    ax2.clear()
    ax2.plot_surface(X, Y, frame, cmap='viridis')
    ax2.set_zlim(np.min(solution), np.max(solution))
    ax2.set_title('Ewolucja rozwiązania')
    ax2.set_xlabel('x')
    ax2.set_ylabel('y')
    ax2.set_zlabel('h')

ani = FuncAnimation(fig2, update, frames=frames, interval=200)
plt.show()
