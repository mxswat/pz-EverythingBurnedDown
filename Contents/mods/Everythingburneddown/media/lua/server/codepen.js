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

    // this.steps = 0.25; // DEBUG OVERRIDE

    const TWO_PI = Math.PI * 2
    for (let a = 0; a < TWO_PI; a += this.steps) {
      let rngR = randomNum(Math.round(r * 1.8), r)
      let x = Math.round(cx + (rngR * Math.cos(a)));
      let y = Math.round(cy + (rngR * Math.sin(a)));

      if (!(prevY == 0 && prevX == 0)) {
        const vertices = [{ x, y }, { x: prevX, y: prevY }, { x: cx, y: cy }];
        this.fillTriangle(vertices);
        this.drawLine(x, y, prevX, prevY, 'red');
        // this.drawLine(x, y, cx, cy);
        // this.drawLine(prevX, prevY, cx, cy);

      } else {
        firstX = x;
        firstY = y;
      }

      prevX = x
      prevY = y
    }

    const vertices = [{ x: firstX, y: firstY }, { x: prevX, y: prevY }, { x: cx, y: cy }];
    this.fillTriangle(vertices);
    this.drawLine(firstX, firstY, prevX, prevY, 'red');
    // this.drawLine(prevX, prevY, cx, cy);
    // this.drawLine(firstX, firstY, cx, cy);

    console.log({ ...this })
  }

  drawPixel(x, y, fillColor) {
    this.ctx.fillStyle = fillColor || '#000';
    this.ctx.fillRect(x, y, 1, 1);
    this.pixelMatrix[y] = this.pixelMatrix[y] || {};
    this.pixelMatrix[y][x] = true;
  }

  drawScanline(x0, y0, x1, y1) {
    x0 = Math.round(x0);
    y0 = Math.round(y0);
    x1 = Math.round(x1);
    y1 = Math.round(y1);
    console.log({
      x0,
      y0,
      x1,
      y1,
    })

    const start = Math.min(x0, x1); 
    const end = Math.max(x0, x1);

    for (let i = start; i < end; i++) {
      this.drawPixel(i, y0)
    }
  }

  // Thank you to https://stackoverflow.com/a/4672319/10300983
  drawLine(x0, y0, x1, y1, fillColor) {
    x0 = Math.round(x0);
    y0 = Math.round(y0);
    x1 = Math.round(x1);
    y1 = Math.round(y1);
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

  // Fill functions thanks to https://stackoverflow.com/a/49051355/10300983
  fillTriangle(vertices) {
    vertices.sort((a, b) => a.y - b.y);
    if (vertices[1].y == vertices[2].y) {
      this.fillBottomFlatTriangle(vertices[0], vertices[1], vertices[2]);
    } else if (vertices[0].y == vertices[1].y) {
      this.fillTopFlatTriangle(vertices[0], vertices[1], vertices[2]);
    } else {
      let v4 = {
        x: vertices[0].x + (vertices[1].y - vertices[0].y) / (vertices[2].y - vertices[0].y) * (vertices[2].x - vertices[0].x),
        y: vertices[1].y
      };
      this.fillBottomFlatTriangle(vertices[0], vertices[1], v4);
      this.fillTopFlatTriangle(vertices[1], v4, vertices[2]);
    }
  }

  fillBottomFlatTriangle(v1, v2, v3) {
    let invslope1 = (v2.x - v1.x) / (v2.y - v1.y);
    let invslope2 = (v3.x - v1.x) / (v3.y - v1.y);

    let curx1 = v1.x;
    let curx2 = v1.x;

    for (let scanlineY = v1.y; scanlineY <= v2.y; scanlineY++) {
      this.drawScanline(curx1, scanlineY, curx2, scanlineY);
      curx1 += invslope1;
      curx2 += invslope2;
    }
  }

  fillTopFlatTriangle(v1, v2, v3) {
    let invslope1 = (v3.x - v1.x) / (v3.y - v1.y);
    let invslope2 = (v3.x - v2.x) / (v3.y - v2.y);

    let curx1 = v3.x;
    let curx2 = v3.x;

    for (let scanlineY = v3.y; scanlineY > v1.y; scanlineY--) {
      this.drawScanline(curx1, scanlineY, curx2, scanlineY);
      curx1 -= invslope1;
      curx2 -= invslope2;
    }
  }
}

const circle = new PixelCircle(canvasContext, 0, 0, parseFloat(input.value))

input.addEventListener('input', function () {
  canvasContext.clearRect(-200, -200, 400, 400);
  var rad = parseFloat(input.value);
  disp.value = rad;
  const circle = new PixelCircle(canvasContext, 0, 0, parseFloat(rad))
});