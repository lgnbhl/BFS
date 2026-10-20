// The footer's row of package stickers. The list is not kept here: the build of
// felixluginbuhl.com writes it to stickers.json (from its content/packages.yml),
// so a new package shows up on every package site without rebuilding them.
// Without JavaScript, or if the fetch fails, the footer keeps its plain link.
document.addEventListener("DOMContentLoaded", function () {
  var nav = document.querySelector(".hexfamily");
  if (!nav) return;
  var src = "https://felixluginbuhl.com/stickers.json";
  // The package this site documents stays in colour (.current in extra.css).
  var brand = document.querySelector(".navbar-brand");
  var here = brand ? brand.textContent.trim() : "";

  fetch(src)
    .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function (rows) {
      var links = rows.map(function (s) {
        var a = document.createElement("a");
        a.href = new URL(s.href, src);
        a.title = s.slug;
        if (s.slug === here) a.className = "current";
        var img = document.createElement("img");
        img.src = new URL(s.img, src);
        img.alt = s.slug;
        img.loading = "lazy";
        a.append(img);
        return a;
      });
      if (links.length) nav.replaceChildren.apply(nav, links);
    })
    .catch(function () {});
});
