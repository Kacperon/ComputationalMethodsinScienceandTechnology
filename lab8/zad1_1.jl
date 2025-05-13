using Colors, Plots
# Przykład: wielomian z trzema pierwiastkami
f(z) = z^3 - 1
df(z) = 3z^2

newton_fractal(f, df)


f1(x) = x^3 - x - 2            # Pierwiastek około 1.521
df1(x) = 3x^2 - 1

f2(x) = exp(-x) - x            # Pierwiastek około 0.567
df2(x) = -exp(-x) - 1

f3(x) = x * cos(x) - sin(x)    # Pierwiastek około 0
df3(x) = cos(x) - x*sin(x) - cos(x)

f4(x) = sin(x) - 0.5           # Pierwiastek około π/6
df4(x) = cos(x)

f5(x) = log(x + 2) - x         # Pierwiastek około 0.158
df5(x) = 1 / (x + 2) - 1

f6(x) = x^5 - x^4 + x^3 - x^2 + x - 1
df6(x) = 5x^4 - 4x^3 + 3x^2 - 2x + 1


# Metoda bisekcji
function bisekcja(f, a, b; tol=1e-6, max_iter=100)
    if f(a) * f(b) >= 0
        error("Znaki f(a) i f(b) muszą być przeciwne")
    end
    
    iter = 0
    f_calls = 2  # Rozpoczynamy od f(a) i f(b)
    
    while (b - a) > tol && iter < max_iter
        c = (a + b) / 2
        fc = f(c)
        f_calls += 1
        
        if abs(fc) < tol
            return c, iter, f_calls, fc
        end
        
        if f(a) * fc < 0
            b = c
        else
            a = c
        end
        
        iter += 1
    end
    
    x = (a + b) / 2
    fx = f(x)
    f_calls += 1
    return x, iter, f_calls, fx
end

# Metoda Newtona
function newton(f, df, x0; tol=1e-6, max_iter=100)
    x = x0
    iter = 0
    f_calls = 0
    df_calls = 0
    
    while iter < max_iter
        fx = f(x)
        f_calls += 1
        
        if abs(fx) < tol
            return x, iter, f_calls + df_calls, fx
        end
        
        dfx = df(x)
        df_calls += 1
        
        if abs(dfx) < tol
            error("Pochodna bliska zeru")
        end
        
        x_new = x - fx / dfx
        
        if abs(x_new - x) < tol
            x = x_new
            fx = f(x)
            f_calls += 1
            return x, iter, f_calls + df_calls, fx
        end
        
        x = x_new
        iter += 1
    end
    
    error("Osiągnięto maksymalną liczbę iteracji")
end

# Metoda siecznych
function sieczne(f, a, b; tol=1e-6, max_iter=100)
    x0, x1 = a, b
    f0, f1 = f(x0), f(x1)
    f_calls = 2
    iter = 0
    
    while iter < max_iter
        if abs(f1) < tol
            return x1, iter, f_calls, f1
        end
        
        if abs(f1 - f0) < tol
            error("Metoda siecznych: dzielenie przez zero")
        end
        
        x = x1 - f1 * (x1 - x0) / (f1 - f0)
        
        if abs(x - x1) < tol
            fx = f(x)
            f_calls += 1
            return x, iter, f_calls, fx
        end
        
        x0, x1 = x1, x
        f0, f1 = f1, f(x)
        f_calls += 1
        iter += 1
    end
    
    error("Osiągnięto maksymalną liczbę iteracji")
end


function test_all()
    functions = [
        ("f1", f1, df1, 1.0, 2.0),
        ("f2", f2, df2, 0.0, 1.0),
        ("f3", f3, df3, -1.0, 1.0),
        ("f4", f4, df4, 0.0, 1.0),
        ("f5", f5, df5, 0.0, 1.0),
        ("f6", f6, df6, 0.0, 1.0)
    ]

    println("| Funkcja | Metoda | Iteracje | Wywołania | f(x*) |")
    println("|---------|--------|----------|------------|-------|")

    for (name, f, df, a, b) in functions
        try
            x, i, c, fx = bisekcja(f, a, b)
            println("| $name | Bisekcja | $i | $c | $(fx) |")
        catch e
            println("| $name | Bisekcja | Błąd | - | - |")
        end

        try
            x, i, c, fx = newton(f, df, (a + b) / 2)
            println("| $name | Newton | $i | $c | $(fx) |")
        catch e
            println("| $name | Newton | Błąd | - | - |")
        end

        try
            x, i, c, fx = sieczne(f, a, b)
            println("| $name | Sieczne | $i | $c | $(fx) |")
        catch e
            println("| $name | Sieczne | Błąd | - | - |")
        end
    end
end

test_all()


function test_hard()
    # A better test function with a "hard" root but more stable behavior
    f_hard(x) = sign(x) * abs(x)^(1/3)  # Smoother version of cube root
    df_hard(x) = x == 0 ? 100.0 : (1/3) * abs(x)^(-2/3)  # Protected derivative
    
    println("| Function | Method | Iterations | Calls | f(x*) |")
    println("|---------|--------|----------|------------|-------|")
    
    try
        # Use interval that crosses zero
        x, i, c, fx = bisekcja(f_hard, -1.0, 1.0)
        println("| f_hard | Bisekcja | $i | $c | $(fx) |")
    catch e
        println("| f_hard | Bisekcja | Błąd | - | - |")
    end
    
    try
        # Start away from x=0 to avoid derivative issues
        x, i, c, fx = newton(f_hard, df_hard, 0.5)
        println("| f_hard | Newton | $i | $c | $(fx) |")
    catch e
        println("| f_hard | Newton | Błąd | - | - |")
    end
    
    try
        # Use interval that crosses zero
        x, i, c, fx = sieczne(f_hard, -0.5, 0.5)
        println("| f_hard | Sieczne | $i | $c | $(fx) |")
    catch e
        println("| f_hard | Sieczne | Błąd | - | - |")
    end
end

test_hard()
