using Colors, Plots


function visualize_steps(f, df, a, b; tol=1e-6, max_iter=10, name="Function")
    # Zmodyfikowane wersje algorytmów zapisujące pośrednie kroki
    
    # Bisekcja z zapisem kroków
    function bisekcja_steps(f, a, b; tol=tol, max_iter=max_iter)
        if f(a) * f(b) >= 0
            error("Znaki f(a) i f(b) muszą być przeciwne")
        end
        
        steps = [(a, b)]
        iter = 0
        
        while (b - a) > tol && iter < max_iter
            c = (a + b) / 2
            fc = f(c)
            
            if abs(fc) < tol
                push!(steps, (c, c))
                return steps
            end
            
            if f(a) * fc < 0
                b = c
            else
                a = c
            end
            
            push!(steps, (a, b))
            iter += 1
        end
        
        return steps
    end
    
    # Newton z zapisem kroków
    function newton_steps(f, df, x0; tol=tol, max_iter=max_iter)
        x = x0
        steps = [x]
        
        for iter in 1:max_iter
            fx = f(x)
            if abs(fx) < tol
                return steps
            end
            
            dfx = df(x)
            if abs(dfx) < tol
                return steps
            end
            
            x_new = x - fx / dfx
            push!(steps, x_new)
            
            if abs(x_new - x) < tol
                return steps
            end
            
            x = x_new
        end
        
        return steps
    end
    
    # Sieczne z zapisem kroków
    function sieczne_steps(f, a, b; tol=tol, max_iter=max_iter)
        x0, x1 = a, b
        steps = [x0, x1]
        
        for iter in 1:max_iter
            f0, f1 = f(x0), f(x1)
            
            if abs(f1) < tol
                return steps
            end
            
            if abs(f1 - f0) < tol
                return steps
            end
            
            x = x1 - f1 * (x1 - x0) / (f1 - f0)
            push!(steps, x)
            
            if abs(x - x1) < tol
                return steps
            end
            
            x0, x1 = x1, x
        end
        
        return steps
    end
    
    # Zbierz kroki dla każdej metody
    bisection_steps = bisekcja_steps(f, a, b)
    newton_steps = newton_steps(f, df, (a + b) / 2)
    secant_steps = sieczne_steps(f, a, b)
    
    # Przygotuj wartości x do wykresu funkcji
    x_vals = range(a, b, length=500)
    y_vals = f.(x_vals)
    
    # Stwórz wykresy dla każdej metody
    bisection_plot = plot(x_vals, y_vals, label="f(x)", title="Metoda bisekcji", 
                          xlabel="x", ylabel="f(x)", legend=:topright)
    plot!(bisection_plot, [a, b], [0, 0], color=:black, linestyle=:dash, label="oś x")
    
    newton_plot = plot(x_vals, y_vals, label="f(x)", title="Metoda Newtona", 
                      xlabel="x", ylabel="f(x)", legend=:topright)
    plot!(newton_plot, [a, b], [0, 0], color=:black, linestyle=:dash, label="oś x")
    
    secant_plot = plot(x_vals, y_vals, label="f(x)", title="Metoda siecznych", 
                      xlabel="x", ylabel="f(x)", legend=:topright)
    plot!(secant_plot, [a, b], [0, 0], color=:black, linestyle=:dash, label="oś x")
    
    # Narysuj kroki dla metody bisekcji
    for (i, (left, right)) in enumerate(bisection_steps)
        mid = (left + right) / 2
        scatter!(bisection_plot, [left], [0], color=:red, label=i==1 ? "lewy brzeg" : "")
        scatter!(bisection_plot, [right], [0], color=:blue, label=i==1 ? "prawy brzeg" : "")
        scatter!(bisection_plot, [mid], [f(mid)], color=:green, label=i==1 ? "środek" : "")
        annotate!(bisection_plot, mid, f(mid), text(string(i), 8, :black))
    end
    
    # Narysuj kroki dla metody Newtona
    for (i, x) in enumerate(newton_steps)
        fx = f(x)
        scatter!(newton_plot, [x], [fx], color=:green, label=i==1 ? "iteracje" : "")
        annotate!(newton_plot, x, fx, text(string(i), 8, :black))
        
        if i < length(newton_steps)
            # Narysuj styczną
            dfx = df(x)
            x_next = newton_steps[i+1]
            x_line = [x - 0.1*(b-a), x + 0.1*(b-a)]
            y_line = [fx - 0.1*(b-a)*dfx, fx + 0.1*(b-a)*dfx]
            plot!(newton_plot, x_line, y_line, color=:red, label=i==1 ? "styczna" : "")
            
            # Narysuj linię do osi x
            plot!(newton_plot, [x_next, x_next], [0, f(x_next)], 
                  color=:blue, linestyle=:dash, label=i==1 ? "następny punkt" : "")
        end
    end
    
    # Narysuj kroki dla metody siecznych
    for (i, x) in enumerate(secant_steps)
        fx = f(x)
        scatter!(secant_plot, [x], [fx], color=:green, label=i==1 ? "iteracje" : "")
        annotate!(secant_plot, x, fx, text(string(i), 8, :black))
        
        if i < length(secant_steps) - 1
            # Narysuj sieczną
            x1, x2 = secant_steps[i], secant_steps[i+1]
            f1, f2 = f(x1), f(x2)
            plot!(secant_plot, [x1, x2], [f1, f2], color=:red, label=i==1 ? "sieczna" : "")
            
            # Narysuj linię do osi x dla następnego punktu
            if i + 2 <= length(secant_steps)
                x_next = secant_steps[i+2]
                plot!(secant_plot, [x_next, x_next], [0, f(x_next)], 
                      color=:blue, linestyle=:dash, label=i==1 ? "następny punkt" : "")
            end
        end
    end
    
    # Połącz wykresy
    plot(bisection_plot, newton_plot, secant_plot, layout=(3,1), size=(800, 1200), 
         title="Znajdowanie pierwiastków dla funkcji $name")
    savefig("fractal_vis.png")
end


f1(x) = x^3 - x - 2            # Pierwiastek około 1.521
df1(x) = 3x^2 - 1


# Przykład 1: Funkcja f1 (x^3 - x - 2)
visualize_steps(f1, df1, 1.25, 2.0, max_iter=8, name="x^3 - x - 2")
