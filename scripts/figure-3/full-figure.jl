# Run after running all other files
#
pyplot()

fig_a1, fig_a2 = figure_A(b₁, r₁, "Cell 437\nCover")
fig_a3, fig_a4 = figure_A(b₂, r₂, "Cell 438\nCover")

fib_b = figure_B(modulated, unmodulated)

fig_c = figure_C(neighbors)
fig_d = figure_D(distant)

fig_e = figure_E(folded_mod, scatter_mod, folded_unmod)

fig_f = figure_F(folded_sim_mean, folded_sim_sem)

fig_g = figure_G(folded_diff_mean, folded_diff_sem)

l = @layout [ [a1; a2] b c d ; [a3; a4] e f g ]
plot(fig_a1, fig_a2, fig_b, fig_c, fig_d, fig_a3, fig_a4, fig_e, fig_f, fig_g, layout=l, size=(2000, 1000))

savefig("plots/logbook/04-03/full-figure")
