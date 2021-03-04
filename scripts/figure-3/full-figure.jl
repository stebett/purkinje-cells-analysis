# Run after running all other files
#

l = @layout [ a b c d ; e f g h ]
plot(fig_a1, fig_b, fig_c, fig_d, fig_a3, fig_e, fig_f, fig_g, layout=l, size=(2200, 1100))
