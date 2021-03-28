using SmoothingSplines
idx = neigh[1]
df = find(data, idx) |> mkdf

spl = fit(SmoothingSpline, df.timeSinceLastSpike, df.previousIsi, 4000.)
Ypred = SmoothingSplines.predict(spl, df[df.trial .== 1, :nearest])
plot(Ypred)
