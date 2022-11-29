const printGrid = (grid) => {
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

const drawCircle = (x, y, r, c) => {

}


const size = 25
const grid = Array.from({ length: size }, e => Array(size).fill("·"));

drawAxes(grid)
printGrid(grid)