## Making a hex sticker for BFS
library(hexSticker)
library(magick)
library(magrittr)

hexSticker::sticker("man/figures/logo_icon.svg",
                    package = "",
                    #p_color = "black",
                    #p_size = 7,
                    #p_y = 1.5,
                    spotlight = FALSE,
                    h_size = 1.5,
                    h_color = "#E05F63",
                    h_fill = "white",
                    s_x = 1.02, 
                    s_y = 1, 
                    s_width = 0.85,
                    url="felixluginbuhl.com/BFS",
                    u_size = 6.8,
                    u_color = "black",
                    filename="man/figures/logo.png")

# MOD with Gimp: removing red borders.

bfs <- magick::image_read("man/figures/logo.png")
magick::image_scale(bfs, "130") %>%
  magick::image_write(path = "man/figures/logo.png", format = "png")
