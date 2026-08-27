library(visNetwork)

set.seed(42)

# Small toy graph with FIXED positions (physics = FALSE) -- this matters:
# it means we KNOW the "data space" range up front (roughly -150..150),
# so we can scatter stars in a matching range without needing to query
# the physics-settled layout, which is the real-world wrinkle we flagged
# for later.
nodes <- data.frame(
  id = 1:6,
  label = c("A", "B", "C", "D", "E", "F"),
  x = c(-150, 150, -150, 150, 0, 0),
  y = c(-100, -100, 100, 100, 0, -180)
)

edges <- data.frame(
  from = c(1, 1, 2, 3, 4, 5),
  to   = c(2, 3, 4, 4, 5, 6)
)

# A handful of stars, scattered a bit WIDER than the node layout so some
# are visible even when zoomed out.
n_stars <- 1000
stars <- data.frame(
  x = runif(n_stars, -800, 800),
  y = runif(n_stars, -800, 800),
  r = runif(n_stars, 1, 4)
)

star_js <- paste0(
  "[",
  paste0("{x:", stars$x, ",y:", stars$y, ",r:", stars$r, "}", collapse = ","),
  "]"
)

ctxfill <-
  rep(
    c(
      "red", "blue",
      "green", "pink",
      "purple"
    ),
    length.out = n_stars
  )

# Didn't work, maybe ctx.fillStyle = sample(ctxfill,1)?
#   "  ctx.fillStyle = ", ctxfill[5], ";",

before_drawing_js <- paste0(
  "function(ctx) {",
  "  var stars = ", star_js, ";",
  "  ctx.save();",
  "  ctx.fillStyle = 'purple';",
  "  ctx.strokeStyle = 'white';",
  "  stars.forEach(function(s) {",
  "    ctx.beginPath();",
  "    ctx.arc(s.x, s.y, s.r, 0, 2 * Math.PI);",
  "    ctx.fill();",
  "    ctx.stroke();",
  "  });",
  "  ctx.restore();",
  "}"
)

visNetwork(
  nodes, edges,
  width = "100%", height = "500px",
  background = "#04050f"
) |>
  visNodes(
    physics = FALSE,
    color = list(background = "#8ec6ff", border = "#ffffff"),
    font = list(color = "white", size = 20)
  ) |>
  visEdges(color = "#5577aa") |>
  visEvents(beforeDrawing = before_drawing_js)

stars$col <- ctxfill

ggplot(stars, (aes(x, y, size = r, color = "white"))) +
  geom_point() +
  theme_void(paper = "black", ink = "white") +
  scale_color_identity() +
  xlim(-100, 100) +
  ylim(-100, 100)
