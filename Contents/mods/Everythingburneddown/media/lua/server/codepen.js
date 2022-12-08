var canvasContext = c.getContext('2d');
canvasContext.translate(c.height / 2, c.height / 2);
canvasContext.scale(3, 3);

function randomNum(max, min) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

let notRandom = 0
/* Overrides random gen, for debugging purpose */
function randomNum(max, min) {
  notRandom = (notRandom + 1) % 2
  return min * (notRandom + 1)
}

class PixelCircle {
  constructor(ctx, cx, cy, r) {
    this.ctx = ctx;
    this.cx = cx;
    this.cy = cy;
    this.r = r;
    this.borderPixels = {};
    this.drawSelf();
  }

  drawSelf() {
    const { cx, cy, r } = this;
    let rngR = randomNum(Math.round(r * 1.5), r)
    let prevX = Math.round(cx + (rngR * Math.cos(0)));
    let prevY = Math.round(cy + (rngR * Math.sin(0)));

    this.drawPixel(this.ctx, prevX, prevY, 'blue');

    const firstX = prevX
    const firstY = prevY
    let x = 0
    let y = 0

    const steps = 0.1; // 0.03 seems good
    const TWO_PI = Math.PI * 2

    for (let a = steps; a < TWO_PI; a += steps) {
      let rngR = randomNum(Math.round(r * 1.8), r)
      x = Math.round(cx + (rngR * Math.cos(a)));
      y = Math.round(cy + (rngR * Math.sin(a)));

      this.drawLine(x, y, prevX, prevY);
      this.drawPixel(x, y, 'red');

      prevX = x;
      prevY = y;
    }

    this.drawLine(x, y, firstX, firstY);

    console.log({...this})

    this.fillCircle(this.cx, this.cy);
  }

  drawPixel(x, y, fillColor) {
    this.ctx.fillStyle = fillColor || '#000';
    this.ctx.fillRect(x, y, 1, 1);
    this.borderPixels[y] = this.borderPixels[y] || {};
    this.borderPixels[y][x] = true;
  }

  drawLine(x0, y0, x1, y1, fillColor) {
    var dx = Math.abs(x1 - x0);
    var dy = Math.abs(y1 - y0);
    var sx = (x0 < x1) ? 1 : -1;
    var sy = (y0 < y1) ? 1 : -1;
    var err = dx - dy;

    while (true) {
      if ((x0 === x1) && (y0 === y1)) break;
      // Break before draw to keep the red stroke on point
      this.drawPixel(x0, y0, fillColor);

      var e2 = 2 * err;
      if (e2 > -dy) { err -= dy; x0 += sx; }
      if (e2 < dx) { err += dx; y0 += sy; }
    }
  }

  fillCircle(cx, cy) {
    if (this.borderPixels[cy] && this.borderPixels[cy][cx]) {
      return;
    }

    this.drawPixel(cx, cy, 'green');

    this.fillCircle(cx + 1, cy);
    this.fillCircle(cx - 1, cy);
    this.fillCircle(cx, cy + 1);
    this.fillCircle(cx, cy - 1);
  }
}

const circle = new PixelCircle(canvasContext, 0, 0, parseFloat(input.value))

input.addEventListener('input', function () {
  canvasContext.clearRect(-200, -200, 400, 400);
  var rad = parseFloat(input.value);
  disp.value = rad;
  const circle = new PixelCircle(canvasContext, 0, 0, parseFloat(rad))
});