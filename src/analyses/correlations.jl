using DrWatson
@quickactivate :ens

function searchsortednearest(a,x)
	idx = searchsortedfirst(a,x)
	if (idx==1); return idx; end
	if (idx>length(a)); return length(a); end
	if (a[idx]==x); return idx; end
	if (abs(a[idx]-x) < abs(a[idx-1]-x))
		return idx
	else
		return idx-1
	end
end

struct TimeCourseGroup
	landmark::Symbol
	group::Symbol
	around::Vector
end

struct Correlation
	around::Vector
end

TimeCourseGroup(d::Dict) = TimeCourseGroup(d[:landmark], d[:group], [d[:around]...])


# Wilcox test for signifcancy

function compute(A::TimeCourseGroup, data)
	group = couple(data, A.group)
	couples = find.(Ref(data), group)

	tc1 = Vector{Float64}[]
	tc2 = Vector{Float64}[]
	for c in couples
		cuts1 = cut(c[1, :t], c[1, A.landmark], A.around)
		cuts2 = cut(c[2, :t], c[2, A.landmark], A.around)

		bins1 = bin.(cuts1, diff(A.around)[1])
		bins2 = bin.(cuts2, diff(A.around)[1])

		conv1 = convolve(bins1, 10)
		conv2 = convolve(bins2, 10)

		push!(tc1, conv1...)
		push!(tc2, conv2...)
	end
	tc1, tc2
end


function compute(A::Correlation, data)
	c = Dict(
			 :landmark => [:lift, :cover, :grasp],
			 :group => [:n, :d],
			 :around => Tuple(A.around),
			 )

	d = TimeCourseGroup.(dict_list(c))
	tc = compute.(d, Ref(data))
	[cor.(x[1], x[2]) for x in tc]
end

function visualise!(A::Correlation, fig::Figure, x::Vector, plot_params)
	ax = Axis(fig, title="Average time course of firing rate")

	xval = [1, 2, 4, 5, 7, 8]
	yval = [mean(drop(i)) for i in x]
	err = [sem(drop(i)) for i in x]
	colorscheme = ColorSchemes.RdBu_11
	# colorscheme = plot_params[:colors]
	colors = [colorscheme[i] for i in [1, 11, 1, 11, 1, 11]]

	barplot!(ax, xval, yval,
			dodge = [1, 2, 1, 2, 1, 2],
			color = colors,
			labels = ["Neighbors", "Distant"])

	errorbars!(ax, xval, yval, err)

	ax.xticks = ([1.5, 4.5, 7.5], ["lift", "cover", "grasp"])
	ax.xlabel = "Landmark"
	ax.ylabel = "Correlation coefficient"

	ax
end

function visualise!(A::TimeCourseGroup, fig::Figure, x::Tuple, plot_params)
	ax1 = Axis(fig)
	ax2 = Axis(fig)
	ax3 = Axis(fig)

	c = cor.(x[1], x[2])

	medi = searchsortednearest(c, 0.3)
	mini = searchsortednearest(c, 0)
	c[isnan.(c)] .= 0
	maxi = argmax(c)

	lines!(ax1, x[1][maxi]; color = plot_params[:color][1], label="Cell 1", plot_params[:kwargs]...)
	lines!(ax2, x[1][medi]; color = plot_params[:color][1], plot_params[:kwargs]...)
	lines!(ax3, x[1][mini]; color = plot_params[:color][1], plot_params[:kwargs]...)

	lines!(ax1, x[2][maxi]; color = plot_params[:color][2], label = "Cell 2", plot_params[:kwargs]...)
	lines!(ax2, x[2][medi]; color = plot_params[:color][2], plot_params[:kwargs]...)
	lines!(ax3, x[2][mini]; color = plot_params[:color][2], plot_params[:kwargs]...)

	axislegend(ax1)

	ax1, ax2, ax3
end

