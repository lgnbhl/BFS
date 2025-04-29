# icon from: https://www.svgrepo.com/svg/434772/database-plus

library(hexSticker)
library(magick)
library(showtext)

font_add_google(name = "Exo 2", regular.wt = "600")
showtext_auto()

sticker <- hexSticker::sticker(
  subplot = "data-raw/database-icon.png", #android-samba-client-white.png
  s_x = 1.02,
  s_y = 1.2,
  s_width = 0.4,
  package = "BFS",
  p_color = "white",
  p_family = "Exo 2",
  p_size = 30,
  p_y = 0.58,
  spotlight = FALSE,
  h_size = 0,
  h_fill = "#DA291C",
  h_color = "gray70",
  filename="man/figures/logo.png"
)

# MOD with Gimp: removing red borders.

logo <- magick::image_read("man/figures/logo.png")
magick::image_scale(logo, "800") %>%
  magick::image_write(path = "man/figures/logo.png", format = "png")

