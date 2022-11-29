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

const drawCircle = (grid, x, y, r, c) => {
    let dx = r
    let dy = 0
    let err = 1 - r

    while (dx >= dy) {
        drawPixel(grid, x + dx, y + dy, c)
        drawPixel(grid, x - dx, y + dy, c)
        drawPixel(grid, x + dx, y - dy, c)
        drawPixel(grid, x - dx, y - dy, c)
        drawPixel(grid, x + dy, y + dx, c)
        drawPixel(grid, x - dy, y + dx, c)
        drawPixel(grid, x + dy, y - dx, c)
        drawPixel(grid, x - dy, y - dx, c)
        printGrid(grid)
        dy = dy + 1
    }

    if (err < 0) {
        err = err + 2 * dy + 1

    } else {
        dx = dx - 1
        err = err + 2 * (dy - dx) + 1
    }

}


const size = 25
const grid = Array.from({ length: size }, e => Array(size).fill("·"));

drawAxes(grid)
printGrid(grid)

drawCircle(grid, 12, 12, 11, "■")

printGrid(grid)