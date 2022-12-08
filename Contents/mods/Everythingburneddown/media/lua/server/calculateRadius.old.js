// JS version of current code
// ----------------------------------

const drawLine = ({ x0, x1, y, matrix }) => {
    matrix[y] = matrix[y].fill('X', x1, x0)
    // console.log({x1, x0})
}

const fillCircle = ({ cx, cy, radius, matrix }) => {
    let x = radius - 1
    let y = 0
    let dx = 1
    let dy = 1
    let err = dx - (radius << 1)

    while (x >= y) {
        drawLine({ x0: cx + y, x1: cx - y, y: cy - x, matrix })
        drawLine({ x0: cx + x, x1: cx - x, y: cy - y, matrix })
        drawLine({ x0: cx + x, x1: cx - x, y: cy + y, matrix })
        drawLine({ x0: cx + y, x1: cx - y, y: cy + x, matrix })

        if (err <= 0) {
            y++
            err += dy
            dy += 2
        }

        if (err > 0) {
            x--
            dx += 2
            err += dx - (radius << 1)
        }
        console.clear()
        console.log(matrix.map((x) => x.join('')).join('\n'))
        console.log({ x, y })
    }

    console.log(matrix.map((x) => x.join('')).join('\n'))
}

const size = 21
const matrix = Array.from({ length: size }, e => Array(size).fill('.'));
fillCircle({
    cx: Math.round((size / 2)),
    cy: Math.round((size / 2)),
    radius: Math.round((size / 2) - 1),
    matrix,
})