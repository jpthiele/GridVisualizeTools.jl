"""
$(SIGNATURES)

Create customized distinguishable colormap for interior regions.
For this we use a kind of pastel colors.
"""
function region_cmap(n)
    distinguishable_colors(max(5, n),
                           [RGB(0.85, 0.6, 0.6), RGB(0.6, 0.85, 0.6), RGB(0.6, 0.6, 0.85)];
                           lchoices = range(70; stop = 80, length = 5),
                           cchoices = range(25; stop = 65, length = 15),
                           hchoices = range(20; stop = 360, length = 15))
end

"""
$(SIGNATURES)

Create customized distinguishable colormap for boundary regions.
These use fully saturated colors.
"""
function bregion_cmap(n)
    distinguishable_colors(max(5, n),
                           [RGB(1.0, 0.0, 0.0), RGB(0.0, 1.0, 0.0), RGB(0.0, 0.0, 1.0)];
                           lchoices = range(50; stop = 75, length = 10),
                           cchoices = range(75; stop = 100, length = 10),
                           hchoices = range(20; stop = 360, length = 30))
end

"""
$(SIGNATURES)

Create RGB color from color name string.
"""
function Colors.RGB(c::String)
    c64 = Colors.color_names[c]
    RGB(c64[1] / 255, c64[2] / 255, c64[3] / 255)
end

"""
$(SIGNATURES)

Create RGB color from color name symbol.
"""
Colors.RGB(c::Symbol) = Colors.RGB(String(c))

"""
$(SIGNATURES)

Create RGB color from tuple
"""
Colors.RGB(c::Tuple) = Colors.RGB(c...)

"""
$(SIGNATURES)

Create color tuple from  color description (e.g. string)
"""
rgbtuple(c) = rgbtuple(Colors.RGB(c))

"""
$(SIGNATURES)

Create color tuple from  RGB color.
"""
rgbtuple(c::RGB) = (red(c), green(c), blue(c))
