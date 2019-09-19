## Making a hex sticker for polyglot
library(hexSticker)
library(magick)
library(magrittr)

hexSticker::sticker("https://upload.wikimedia.org/wikipedia/commons/b/b5/Wenger_EvoGrip_S17.JPG",
                    package="",
                    spotlight = FALSE,
                    h_size = 1.5,
                    h_color = "black",
                    h_fill = "white",
                    s_x = 1.025, s_y = 1.05, s_width=0.9,
                    url="BFS - R package",
                    u_size = 2,
                    u_y = 0.15,
                    u_x = 1.05,
                    u_color = "black",
                    filename="man/figures/BFS.png")

graduate <- magick::image_read("man/figures/BFS.png")
magick::image_scale(graduate, "130") %>%
  magick::image_write(path = "man/figures/logo.png", format = "png")
