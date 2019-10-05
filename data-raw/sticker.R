## Making a hex sticker for BFS
library(hexSticker)
library(magick)
library(magrittr)

hexSticker::sticker("https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Flag_of_Switzerland.svg/1000px-Flag_of_Switzerland.svg.png",
                    package="BFS",
                    p_color = "black",
                    p_size = 10,
                    p_y = 1,
                    spotlight = FALSE,
                    h_size = 2,
                    h_color = "black",
                    h_fill = "white",
                    s_x = 1, s_y = 1, s_width = 1,
                    url="felixluginbuhl.com/BFS",
                    u_size = 1.6,
                    u_color = "black",
                    filename="man/figures/BFS.png")

# MOD with Gimp: removing red borders.

bfs <- magick::image_read("man/figures/BFS_mod.png")
magick::image_scale(bfs, "130") %>%
  magick::image_write(path = "man/figures/logo.png", format = "png")
