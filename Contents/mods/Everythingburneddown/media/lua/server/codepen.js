var canvasContext = c.getContext('2d');
canvasContext.translate(c.height / 2, c.height / 2);
canvasContext.scale(3, 3);

function randomNum(max, min) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

//let notRandom = 0
/* Overrides random gen, for debugging purpose */
// function randomNum(max, min) {
//   notRandom = (notRandom + 1) % 2
//   return min * (notRandom + 1)
// }

class PixelCircle {
  constructor(ctx, cx, cy, r, steps = 0.03) {
    this.ctx = ctx;
    this.cx = cx;
    this.cy = cy;
    this.r = r;
    this.steps = steps;
    this.pixelMatrix = {};
    this.borderPixels = {};
    this.drawSelf();
  }

  isInMatrix(x, y) {
    return this.pixelMatrix[y] && this.pixelMatrix[y][x] || false
  }

  isOnBorder(x, y) {
    return this.borderPixels[y] && this.borderPixels[y][x] || false
  }

  // Thank you to https://youtu.be/ZI1dmHv3MeM
  drawSelf() {
    const { cx, cy, r } = this;

    let prevX = 0
    let prevY = 0
    let firstX = 0
    let firstY = 0

    // this.steps = 0.1; // DEBUG OVERRIDE

    const TWO_PI = Math.PI * 2
    for (let a = 0; a < TWO_PI; a += this.steps) {
      let rngR = randomNum(Math.round(r * 1.8), r)
      let x = Math.round(cx + (rngR * Math.cos(a)));
      let y = Math.round(cy + (rngR * Math.sin(a)));

      if (!(prevY == 0 && prevX == 0)) {
        this.drawLine(x, y, prevX, prevY);
      } else {
        firstX = x;
        firstY = y;
      }

      this.drawPixel(x, y, 'red');

      prevX = x
      prevY = y
    }

    this.drawLine(prevX, prevY, firstX, firstY);

    console.log({ ...this })

    this.recursiveFill(this.cx, this.cy);
  }

  drawborder(x, y, fillColor) {
    this.drawPixel(x, y, fillColor);
    this.borderPixels[y] = this.borderPixels[y] || {};
    this.borderPixels[y][x] = true;
  }

  drawPixel(x, y, fillColor) {
    this.ctx.fillStyle = fillColor || '#000';
    this.ctx.fillRect(x, y, 1, 1);
    this.pixelMatrix[y] = this.pixelMatrix[y] || {};
    this.pixelMatrix[y][x] = true;
  }

  // Thank you to https://stackoverflow.com/a/4672319/10300983
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

  recursiveFill(x, y, strayCount) {
    if (!isNaN(strayCount)) {
      strayCount = strayCount - 1;
      if (strayCount == 0) {
        return;
      }
    }

    if (this.isInMatrix(x, y)) {
      return;
    }

    this.drawPixel(x, y, 'green');

    this.recursiveFill(x + 1, y);
    this.recursiveFill(x - 1, y);
    this.recursiveFill(x, y + 1);
    this.recursiveFill(x, y - 1);
  }
}

const circle = new PixelCircle(canvasContext, 0, 0, parseFloat(input.value))

input.addEventListener('input', function () {
  canvasContext.clearRect(-200, -200, 400, 400);
  var rad = parseFloat(input.value);
  disp.value = rad;
  const circle = new PixelCircle(canvasContext, 0, 0, parseFloat(rad))
});