f_hard(x) = x^(1/3)
df_hard(x) = (1/3) * x^(-2/3)  # problem w 0
using Colors, Plots

function newton_fractal(f, df; xlims=(-2, 2), ylims=(-2, 2), res=500, max_iter=30, tol=1e-6)
    xs = range(xlims[1], xlims[2], length=res)
    ys = range(ylims[1], ylims[2], length=res)
    img = zeros(RGB{Float64}, res, res)

    roots = Complex[]
    for i in 1:res, j in 1:res
        z = complex(xs[j], ys[i])
        for k in 1:max_iter
            dz = df(z)
            if abs(dz) < tol
                break
            end
            z_new = z - f(z) / dz
            if abs(z_new - z) < tol
                break
            end
            z = z_new
        end

        matched = false
        for (k, r) in enumerate(roots)
            if abs(z - r) < tol
                img[i, j] = RGB((k % 3) / 2, (k % 2), (k % 4) / 3)
                matched = true
                break
            end
        end
        if !matched
            push!(roots, z)
            k = length(roots)
            img[i, j] = RGB((k % 3) / 2, (k % 2), (k % 4) / 3)
        end
    end

    heatmap(xs, ys, img, axis=false, title="Wstęga Newtona")
    savefig("newton_fractal.png")
end

# Przykład: wielomian z trzema pierwiastkami
f(z) = z^3 - 1
df(z) = 3z^2

newton_fractal(f, df)
