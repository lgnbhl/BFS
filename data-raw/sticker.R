## Making a hex sticker for BFS
library(hexSticker)
library(magick)
library(magrittr)

hexSticker::sticker("https://upload.wikimedia.org/wikipedia/commons/b/b5/Wenger_EvoGrip_S17.JPG",
                    package="BFS",
                    p_color = "black",
                    p_size = 10,
                    p_y = 1.45,
                    spotlight = FALSE,
                    h_size = 2,
                    h_color = "black",
                    h_fill = "white",
                    s_x = 1.02, s_y = 0.95, s_width = 0.9,
                    url="BFS - R package",
                    u_size = 2,
                    u_y = 0.15,
                    u_x = 1.05,
                    u_color = "black",
                    filename="man/figures/BFS.png")

bfs <- magick::image_read("man/figures/BFS.png")
magick::image_scale(bfs, "130") %>%
  magick::image_write(path = "man/figures/logo.png", format = "png")
