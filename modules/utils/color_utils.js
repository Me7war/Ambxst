function transparentize(color, opacity) {
    var c = Qt.color(color);
    c.a = opacity;
    return c;
}