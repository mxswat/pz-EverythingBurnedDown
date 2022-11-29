const printGrid = (grid) => {
    console.clear()
    console.log(grid.map((x) => x.join('')).join('\n'))
}

const drawAxes = (grid) => {
    const width = grid[0].length
    const height = grid.length

    let hw = Math.floor(width / 2);
    let hh = Math.floor(height / 2)

    for (let i = 0; i < width; i++) {
        grid[hh][i] = '-'
    }
    for (let i = 0; i < width; i++) {
        grid[i][hw] = '|'
    }

    grid[hh][hw] = '+'
}

const drawPixel = (grid, x, y, c) => {
    grid[y][x] = c
}

const drawLine = (grid, x0, x1, y, c) => {
    grid[y] = grid[y].fill(c, x0 + 1, x1)
}

const drawCircle = (grid, cx, cy, r, c) => {
    let x = r
    let y = 0
    let err = 1 - r

    while (x >= y) {
        const errBelowZero = err < 0

        drawPixel(grid, cx - x, cy + y, 1)
        drawPixel(grid, cx + x, cy + y, 2)
        // drawLine(grid, cx - x, cx + x, cy + y, c) // Center Bottom lines

        drawPixel(grid, cx - x, cy - y, 3)
        drawPixel(grid, cx + x, cy - y, 4)
        // drawLine(grid, cx - x, cx + x, cy - y, c) // Center Top lines

        drawPixel(grid, cx - y, cy + x, 5)
        drawPixel(grid, cx + y, cy + x, 6)

        drawPixel(grid, cx - y, cy - x, 7)
        drawPixel(grid, cx + y, cy - x, 8)

        printGrid(grid)
        y = y + 1

        // When err > 0 means that the circle is shrinking!

        if (err < 0) {
            err = err + 2 * y + 1;
        } else {
            x = x - 1;
            err = err + 2 * (y - x) + 1;
        }
    }
}


const size = 50
const grid = Array.from({ length: size }, e => Array(size).fill("·"));

drawAxes(grid)
printGrid(grid)

drawCircle(grid, Math.ceil(size / 2), Math.ceil(size / 2), 25, "■")

printGrid(grid)